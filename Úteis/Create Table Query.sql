DECLARE @TableName NVARCHAR(MAX) = 'Table_name' --nome da tabela 
      , @TempTable bit = 0
      , @TempTableGlobal bit = 0
      , @TableNameManual nvarchar(261) = '#Tabela_Destino'
      , @TargetTableName nvarchar(261) 
      , @PrintGeneratedCode bit = 1
      , @SQL NVARCHAR(MAX) = ''

If @TableNameManual is not null
Begin 
	set @TargetTableName = @TableNameManual
End 

If @TempTable = 1
Begin 
	set @TargetTableName = '#' + Isnull(@TableNameManual, @TableName)
End 

If @TempTableGlobal = 1
Begin 
	set @TargetTableName = '##' + isnull(@TableNameManual, @TableName)
End 


-- Criação da tabela e colunas com vírgulas na frente das colunas, exceto a primeira
SELECT @SQL = 'CREATE TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(isnull(@TargetTableName, t.name)) + ' (' + CHAR(13) +
    STUFF((
        SELECT CHAR(13) + '    ,' + QUOTENAME(c.name) + ' ' +
                CASE
                    WHEN tp.name IN ('varchar', 'char', 'nvarchar', 'nchar') THEN tp.name + '(' + 
                        CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length AS VARCHAR(5)) END + ')'
                    WHEN tp.name IN ('decimal', 'numeric') THEN tp.name + '(' + CAST(c.precision AS VARCHAR(5)) + ',' + CAST(c.scale AS VARCHAR(5)) + ')'
                    ELSE tp.name
                END +
                CASE WHEN c.is_nullable = 0 THEN ' NOT NULL' ELSE ' NULL' END +
                CASE WHEN c.is_identity = 1 THEN ' IDENTITY(1,1)' ELSE '' END
        FROM sys.columns c
        JOIN sys.types tp ON c.user_type_id = tp.user_type_id
        WHERE c.object_id = OBJECT_ID(@TableName)
        ORDER BY c.column_id
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 6, '') + CHAR(13) + ');'
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.name = @TableName;

-- PKs
SELECT @SQL = @SQL + CHAR(13) + 'ALTER TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(isnull(@TargetTableName, t.name)) + ' ADD CONSTRAINT ' + QUOTENAME(k.name) + ' PRIMARY KEY (' +
    STUFF((
        SELECT ', ' + QUOTENAME(c.name)
        FROM sys.index_columns ic
        JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE ic.object_id = k.parent_object_id AND ic.index_id = k.unique_index_id
        ORDER BY ic.key_ordinal
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') + ');'
FROM sys.key_constraints k
JOIN sys.tables t ON t.object_id = k.parent_object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE k.type = 'PK' AND t.name = @TableName;

-- FKs
SELECT @SQL = @SQL + CHAR(13) + 'ALTER TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(isnull(@TargetTableName, t.name)) + ' ADD CONSTRAINT ' + QUOTENAME(fk.name) + ' FOREIGN KEY (' +
    STUFF((
        SELECT ', ' + QUOTENAME(c.name)
        FROM sys.foreign_key_columns fkc
        JOIN sys.columns c ON fkc.parent_object_id = c.object_id AND fkc.parent_column_id = c.column_id
        WHERE fkc.constraint_object_id = fk.object_id
        ORDER BY fkc.constraint_column_id
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') + ') REFERENCES ' + QUOTENAME(rs.name) + '.' +  QUOTENAME(t.name) + ' (' +
    STUFF((
        SELECT ', ' + QUOTENAME(rc.name)
        FROM sys.foreign_key_columns fkc
        JOIN sys.columns rc ON fkc.referenced_object_id = rc.object_id AND fkc.referenced_column_id = rc.column_id
        WHERE fkc.constraint_object_id = fk.object_id
        ORDER BY fkc.constraint_column_id
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') + ');'
FROM sys.foreign_keys fk
JOIN sys.tables t ON t.object_id = fk.parent_object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
JOIN sys.tables rt ON rt.object_id = fk.referenced_object_id
JOIN sys.schemas rs ON rt.schema_id = rs.schema_id
WHERE t.name = @TableName;

-- Index non-cluster
SELECT @SQL = @SQL + CHAR(13) + 'CREATE ' + CASE WHEN i.is_unique = 1 THEN 'UNIQUE ' ELSE '' END + 'INDEX ' + QUOTENAME(i.name) + ' ON ' + QUOTENAME(s.name) + '.' +  QUOTENAME(isnull(@TargetTableName, t.name)) + ' (' +
    STUFF((
        SELECT ', ' + QUOTENAME(c.name) + CASE WHEN ic.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END
        FROM sys.index_columns ic
        JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id
        ORDER BY ic.key_ordinal
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') + ');'
FROM sys.indexes i
JOIN sys.tables t ON t.object_id = i.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE i.is_primary_key = 0 AND i.is_unique_constraint = 0 AND t.name = @TableName;

-- Query de Create
PRINT @SQL
--SELECT CAST(@SQL AS XML);
