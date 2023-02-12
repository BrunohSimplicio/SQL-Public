IF (OBJECT_ID('dbo.Vendas') IS NOT NULL) DROP TABLE dbo.Vendas
CREATE TABLE dbo.Vendas (
    Id_Pedido INT IDENTITY(1,1),
    Dt_Pedido DATETIME,
    [Status] INT,
    Quantidade INT,
    Valor NUMERIC(18, 2)
)

CREATE CLUSTERED INDEX SK01_Pedidos ON dbo.Vendas(Id_Pedido)
CREATE NONCLUSTERED INDEX SK02_Pedidos ON dbo.Vendas ([Status], Dt_Pedido) INCLUDE(Quantidade, Valor)
GO


INSERT INTO dbo.Vendas ( Dt_Pedido, [Status], Quantidade, Valor )
SELECT
    DATEADD(SECOND, (ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0) * 199999999, '2015-01-01'),
    (ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0) * 9,
    (ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0) * 10,
    0.459485495 * (ABS(CHECKSUM(PWDENCRYPT(N''))) / 2147483647.0) * 1999
GO 10000


INSERT INTO dbo.Vendas ( Dt_Pedido, [Status], Quantidade, Valor )
SELECT Dt_Pedido, [Status], Quantidade, Valor FROM dbo.Vendas
GO 9
