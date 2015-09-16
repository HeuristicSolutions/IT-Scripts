:: ---------------------------------------------------------
:: Script to backup a Subversion Repository
:: It performs a full backup one day per week, and a
:: differential every other day
:: ---------------------------------------------------------


:: ---------------------------------------------------------
::                      CONFIGURATION
:: ---------------------------------------------------------
@echo off
setlocal

:: file location of repository
set SVN_REPO=c:\svnrepo

:: contains the last revision of the last backup
set LAST_BAK_FILE=lastbackup.txt

:: location to put backups
set BAK_DIR=c:\svnbak

:: which day to perform a full backup (Mon, Tue, Wed, Thu, Fri, Sat, Sun)
set DAY_TO_DO_FULL=Fri

:: log file for this backup script
set LOG_FILE=svn_bak.log


:: ---------------------------------------------------------
::                      Main Program
:: ---------------------------------------------------------
:MAIN

	:: start the log output
	for /F "tokens=1-14 delims=" %%i in ('date /t') do set RAW_DATE=%%i
	for /F "tokens=1-8 delims=" %%i in ('time /t') do set RAW_TIME=%%i
	echo backup started %RAW_DATE% %RAW_TIME% >> %LOG_FILE%

	:: Make sure we have a backup directory
	if Not exist %BAK_DIR% mkdir %BAK_DIR%

	:: get today's date
	for /F "tokens=2-4 delims=/ " %%i in ('date /t') do set TODAY=%%k_%%i_%%j

	:: get the time
	for /F "tokens=1-6 delims=: " %%i in ('time /t') do set NOW=%%i_%%j_%%k

	:: Get the day of the week.
	FOR /F "tokens=1-3" %%i in ("%DATE%") do set TODAYS_NAME=%%i

	::If today is the day to do a full backup, perform a full backup
	if %TODAYS_NAME% == %DAY_TO_DO_FULL% (
		goto FULL_BACKUP
	) else (
		::If it is any other day, perform a differential backup
		goto DIFF_BACKUP
	)

	goto END

::end MAIN



:: ---------------------------------------------------------
:: Perform a dump of all svn revisions
:: ---------------------------------------------------------
:FULL_BACKUP

	set BAK_FILE=%BAK_DIR%\%TODAY%__%NOW%_svn_full.bak
	svnadmin dump %SVN_REPO% > %BAK_FILE%
	echo 	backed up all revisions >> %LOG_FILE%

	goto END

::end FULL_BACKUP




:: ---------------------------------------------------------
:: Perform a dump of all svn revisions since the last time
:: this was run. If it was never run, do a full backup.
:: ---------------------------------------------------------
:DIFF_BACKUP

	:: If we don't know what the last backed up revision is,
	:: then we should do a full backup. Under normal circumstances
	:: this will not happen, unless this is the first time this
	:: script has been run.
	if Not exist %LAST_BAK_FILE% goto FULL_BACKUP

	:: get the youngest revision in the repository
	FOR /F %%i in ('svnlook youngest %SVN_REPO%') do set YOUNGEST_REV=%%i

	:: get the last backed up revision
	set /p NEXT_REV=< %LAST_BAK_FILE%
	set /a NEXT_REV=NEXT_REV+1

	:: if the next revision to backup is greater than the
	:: youngest revision in the repository, then there were
	:: no changes, so we are done
	IF /I %NEXT_REV% GTR %YOUNGEST_REV% (
		echo 	nothing to backup >> %LOG_FILE%
		goto END
	)

	:: define the file to hold the backup
	set BAK_FILE=%BAK_DIR%\%TODAY%__%NOW%_svn_inc.bak

	:: execute the backup
	svnadmin dump %SVN_REPO% -r %NEXT_REV%:%YOUNGEST_REV% --incremental > %BAK_FILE%
	echo 	backed up revisions %NEXT_REV%-%YOUNGEST_REV% >> %LOG_FILE%
	goto END

::end DIFF_BACKUP




:END
	::write the most recent revision number to a text file
	svnlook youngest %SVN_REPO% > %LAST_BAK_FILE%

	for /F "tokens=1-14 delims=" %%i in ('date /t') do set RAW_DATE=%%i
	for /F "tokens=1-8 delims=" %%i in ('time /t') do set RAW_TIME=%%i
	echo backup completed %RAW_DATE% %RAW_TIME% >> %LOG_FILE%
	echo. >> %LOG_FILE%
	echo. >> %LOG_FILE%

