--------------------------------------------------
------------------- RESEED -----------------------

USE {BANCO};  
GO  
DBCC CHECKIDENT ('TABELA', RESEED, 10);  
GO
