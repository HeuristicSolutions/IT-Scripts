-- Replace all instances of 'dbname' with the name of the datbase 
-- for which you want to shrink the transaction log. On the last 
-- line you still need to replace dbname with your database name, 
-- and add the '_log' suffix.

USE dbname
GO
BACKUP LOG dbname WITH TRUNCATE_ONLY
DBCC SHRINKFILE(dbname_log, 1)

