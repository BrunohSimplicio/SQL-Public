USE master;
GO

CREATE TABLE LOG_DATA ( DATA DATETIME )
GO

CREATE PROCEDURE sp_FixSeeds2012
AS
BEGIN
    --foreach database
    DECLARE @DatabaseName varchar(255)
    DECLARE DatabasesCursor CURSOR READ_ONLY

   FOR
        SELECT name
        FROM sys.databases
        where name not in ('master','tempdb','model','msdb') and
        sys.databases.state_desc = 'online'
 
    OPEN DatabasesCursor

    FETCH NEXT FROM DatabasesCursor
    INTO @DatabaseName

    WHILE @@FETCH_STATUS = 0
    BEGIN

        EXEC ('USE '+@DatabaseName + '
        --foreach identity column
        DECLARE @tableName varchar(255)
        DECLARE @columnName varchar(255)
        DECLARE @schemaName varchar(255)
        DECLARE IdentityColumnCursor CURSOR READ_ONLY
        FOR
            select TABLE_NAME , COLUMN_NAME, TABLE_SCHEMA
            from INFORMATION_SCHEMA.COLUMNS
            where COLUMNPROPERTY(object_id(TABLE_NAME), COLUMN_NAME,
                                 ''IsIdentity'') = 1
 
        OPEN IdentityColumnCursor
        FETCH NEXT FROM IdentityColumnCursor
        INTO @tableName, @columnName, @schemaName
        WHILE @@FETCH_STATUS = 0
        BEGIN

            print ''['+@DatabaseName+'].[''+@tableName+''].[''+
                            @schemaName+''].[''+@columnName+'']''
            EXEC (''declare @MAX int = 0
                    select @MAX = max(''+@columnName+'')
                    from ['+@DatabaseName+'].[''+@schemaName+''].[''+@tableName+'']
                    if (@MAX IS NULL)
                    BEGIN
                        SET @MAX = 0
                    END
                    DBCC CHECKIDENT(['+@DatabaseName+'.''+
                                    @schemaName+''.''+@tableName+''],RESEED,@MAX)'')
 
            FETCH NEXT FROM IdentityColumnCursor
            INTO @tableName, @columnName, @schemaName
        END

        CLOSE IdentityColumnCursor
        DEALLOCATE IdentityColumnCursor')

        FETCH NEXT FROM DatabasesCursor
        INTO @DatabaseName

    END
    CLOSE DatabasesCursor
    DEALLOCATE DatabasesCursor

      insert log_data values ( getdate() )

END
GO
 

EXEC sp_configure 'show advanced options', 1 ;
GO

RECONFIGURE
GO

EXEC sp_configure 'scan for startup procs', 1 ;
GO

RECONFIGURE
GO

EXEC sp_procoption @ProcName = 'sp_FixSeeds2012'
    , @OptionName = 'startup'
    , @OptionValue = 'true'
GO