-- Replace all instances of 'dbname' with the name of the datbase 
-- for which you want to shrink the transaction log. On the last 
-- line you still need to replace dbname with your database name, 
-- and add the '_log' suffix.

USE dbname
GO
BACKUP LOG dbname WITH TRUNCATE_ONLY

-- Check that the logical name of the log file is the dbname with _log appended
-- The target size is in MegaBytes. A good rule of thumb is to make it half the size of the DB.
DBCC SHRINKFILE(dbname_log, 1)

