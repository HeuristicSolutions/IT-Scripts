@echo off
prompt $

::***************************************************
:: Configuration variables
::***************************************************

:: get the date format in YYYY_MM_DD
set FileDate=%date:~10,4%_%date:~4,2%_%date:~7,2%
set MyLogFile=.\logs\%FileDate%_CopyBackup.log
set TargetDirectory=\\LearnIIS1.learningbuilder.local\C$\ftp\support
::set TargetDirectory=c:\temp\dbcopy


::***************************************************
:: Output some context info in the log file
echo.------------------------------------------------------------- >> "%MyLogFile%"
echo Beginning the DB copy routine: %Date% %Time% >> "%MyLogFile%"
echo Will copy DB backups from: %FileDate% >> "%MyLogFile%"
echo.>> "%MyLogFile%"

@echo on

cd \Data\Backups\

for /D %%i in (*) do copy "%%i\*%FileDate%*.bak" %TargetDirectory%

:eof
@echo Finished running the DB copy routine. >>"%MyLogFile%"
@prompt $P$F

