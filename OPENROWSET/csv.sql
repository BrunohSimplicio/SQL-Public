
SELECT * 
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Text;Database=C:\Users\caminho\',
    'SELECT * FROM nome_do_arquivo.csv'
);
