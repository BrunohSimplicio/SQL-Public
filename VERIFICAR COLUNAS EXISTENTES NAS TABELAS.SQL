---- ENCONTRA O COLUNA EM TODAS AS TABELAS ----

SELECT TABLE_CATALOG
     , TABLE_NAME
     , COLUMN_NAME
  FROM INFORMATION_SCHEMA.COLUMNS
 WHERE COLUMN_NAME LIKE '%NOME_COLUNA%'

---- ENCONTRA O COLUNA EM TODAS AS TABELAS ----
Select a.name as 'Tabela', b.name as 'Coluna'
from sys.tables a inner join sys.columns b on a.object_id=b.object_id
where b.name='nmColuna'
