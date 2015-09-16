setlocal

set REPO_PATH=C:\svnrepo\
set FULL_DUMP_FILE=full_dump.bak
set PART_DUMP_FILE=part_dump.bak
set FILTER_OPTIONS=include mpi heuristics vendorsrc

svnadmin dump %REPO_PATH% > %FULL_DUMP_FILE%

type %FULL_DUMP_FILE% | svndumpfilter %FILTER_OPTIONS% > %PART_DUMP_FILE%
