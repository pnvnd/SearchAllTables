-- Remove CREATE PROC to run search on demand
-- CREATE PROC SearchAllTables

-- Replace 'string' with whatever you text you need to search for
DECLARE @searchStr nvarchar(100) = 'conduit'

-- AS
-- BEGIN

-- Modified by: Peter Nguyen https://github.com/pnvnd/SearchAllTables
-- Tested with SQL Server: 2008, 2008 R2, 2012, 2014, 2017

-- Copyright © 2002 Narayana Vyas Kondreddi. All rights reserved.
-- Purpose: To search all columns of all tables for a given search string
-- Written by: Narayana Vyas Kondreddi
-- Site: http://vyaskn.tripod.com
-- Tested on: SQL Server 7.0 and SQL Server 2000
-- Date modified: 28th July 2002 22:50 GMT

-- Create a temporary table to select records out of when query complete
CREATE TABLE #Results
	(
		tableName nvarchar(256),
		columnName nvarchar(370),
		columnValue nvarchar(3630),
		searchStr nvarchar(110)
	)

SET NOCOUNT ON;

DECLARE
	@tableName nvarchar(256),
	@columnName nvarchar(128)

BEGIN
	DECLARE search CURSOR
	FOR
	-- Select columns in base tables where the data type is some kind of text
		SELECT tbl.TABLE_NAME, col.COLUMN_NAME
		FROM INFORMATION_SCHEMA.COLUMNS col
			INNER JOIN INFORMATION_SCHEMA.TABLES tbl
				ON col.TABLE_NAME = tbl.TABLE_NAME
		WHERE DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar')
			AND col.COLUMN_NAME <> 'DEX_ROW_ID'
			AND tbl.TABLE_TYPE = 'BASE TABLE'
		ORDER BY tbl.TABLE_NAME, col.COLUMN_NAME

	OPEN search
		FETCH NEXT FROM Search INTO @tableName, @columnName

		WHILE @@FETCH_STATUS = 0

			BEGIN

				DECLARE @sqlStmtStr1 varchar(1024)
				SET @sqlStmtStr1 = 'SELECT ''' + @tableName + ''', ''' + @columnName + ''', LEFT(' + @columnName + ', 3072), ''''  
									FROM ' + @tableName + ' (NOLOCK) ' + ' WHERE ' + @columnName + ' LIKE ' + '''%' +  @searchStr  + '%'''
		
				IF @columnName IS NOT NULL
						BEGIN
							INSERT INTO #results EXEC (@sqlStmtStr1)
						END
				
		FETCH NEXT FROM Search INTO @tableName, @columnName
		END
	CLOSE search
	DEALLOCATE search
END

SELECT DISTINCT tableName, columnName, columnValue FROM #results

-- Drop table so you can run search on demand again
DROP TABLE #results

-- Comment out last END since we don't want a stored procedure
-- END