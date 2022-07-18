------- VERIFICAR SE TEM TRIGGER NA TABELA

select OBJECT_NAME(parent_id) as tabela,* 
from sys.triggers
where OBJECT_NAME(parent_id) = 'NOME_TABELA'
