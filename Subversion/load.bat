setlocal

set REPO_PATH=C:\svnrepo\
set DUMP_FILE=partial_dump.bak

svnadmin load %REPO_PATH% < %DUMP_FILE%
