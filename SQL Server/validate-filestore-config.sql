SELECT value FROM sys.configurations WHERE name = 'filestream access level' -- should be 2
SELECT SERVERPROPERTY ('FilestreamEffectiveLevel')  -- should be 3
SELECT SERVERPROPERTY ('FilestreamShareName')  -- SQLFILESTORE
SELECT SERVERPROPERTY ('ProductVersion')  -- greater than 11.x

