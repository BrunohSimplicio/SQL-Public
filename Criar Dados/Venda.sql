CREATE TABLE [dbo].[Venda] (
[Id_Venda] INT IDENTITY(1,1),
[Dt_Venda] DATETIME,
[Vl_Venda] NUMERIC(15,2)
)
GO
INSERT INTO [dbo].[Venda] ([Dt_Venda], [Vl_Venda])
SELECT GETDATE(), CAST(1000000 * RAND() AS INT) % 1000
GO 1000
