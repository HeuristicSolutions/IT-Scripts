/* *************************************************************************
This script will move the FileStream data from one location to another. The 
approach used is to create a new FileStream file in the right location, and 
recreate the primary key constraint (a clustered index) on the new file. The 
process of recreating the clustered index causes the filestream data to be 
moved.

Process that always works:
1. Create a full DB backup.
2. Put the DB into Simple recovery mode.
3. Run the script to move the filestream group.
4. Move the files manually.
5. Run the last part of the script.
6. Put the DB back into Full recovery mode.
7. Create a full DB backup.


Process that sometimes doesn't work due to the file not being empty:
1. Create a full DB backup.
2. Run the script to move the filestream group.
3. Move the files manually.
4. Run the part of the script that deletes the tables.
5. Initiate a checkpoint and backup the log of the DB.
6. Run the part of the script that delets the file and filegroup.


************************************************************************* */


-- ****************************************
-- Add a new filegroup & file but rename old ones first
ALTER DATABASE ABO_LB_SUPPORT 
MODIFY FILEGROUP FileStreamFileGroup NAME=FileStreamFileGroupOLD

ALTER DATABASE ABO_LB_SUPPORT
ADD FILEGROUP FileStreamFileGroup
CONTAINS FILESTREAM


-- Add a new Filestream storage location. 
-- Make sure this folder does not exist
ALTER DATABASE ABO_LB_SUPPORT
MODIFY FILE (NAME=N'FileStreamData', NEWNAME=N'FileStreamDataOld')

ALTER DATABASE ABO_LB_SUPPORT
ADD FILE (
	NAME= FileStreamData,
	FILENAME = 'C:\Data\SqlFileStore\ABO_LB_SUPPORT'
) TO FILEGROUP FileStreamFileGroup


-- Make the new filegroup the default
ALTER DATABASE ABO_LB_SUPPORT MODIFY FILEGROUP FileStreamFileGroup DEFAULT
GO
-- ****************************************



-- ****************************************
-- Rename the tables and then create new ones on the 
-- new default file group
EXEC sp_rename 'CK_FILES', 'CK_FILES_OLD';
EXEC sp_rename 'CK_THUMBNAILS', 'CK_THUMBNAILS_OLD';

ALTER TABLE CK_FILES_OLD
    SET ( FILETABLE_DIRECTORY = N'CkFilesOld' );
GO
ALTER TABLE CK_THUMBNAILS_OLD
    SET ( FILETABLE_DIRECTORY = N'CkThumbnailsOld' );
GO


CREATE TABLE CK_FILES AS FileTable
WITH (
	  FileTable_Directory =   'CkFiles',
	  FileTable_Collate_Filename = database_default
);
GO
grant insert, update, delete on CK_FILES to LearningBuilder_web_role
go

CREATE TABLE CK_THUMBNAILS AS FileTable
WITH (
	  FileTable_Directory =   'CkThumbnails',
	  FileTable_Collate_Filename = database_default
);
GO
grant insert, update, delete on CK_THUMBNAILS to LearningBuilder_web_role
go
-- ****************************************


-- ****************************************
/*
Manual Steps
1. Manually copy the files from the old folders to the new ones
2. Check that the images are accessible from the web application

Once that is completed, you may run the last section of this script which is 
commented out to prevent you from deleting the old data before completing 
everything else.
*/


-- ****************************************
-- Remove the old tables, file and filegroup.

/*
DROP TABLE CK_FILES_OLD;
DROP TABLE CK_THUMBNAILS_OLD;
CHECKPOINT;

-- This part isn't working and I don't know why!
ALTER DATABASE ABO_LB_SUPPORT REMOVE FILE FileStreamDataOLD;
ALTER DATABASE ABO_LB_SUPPORT REMOVE FILEGROUP FileStreamFileGroupOLD;
*/
-- ****************************************


