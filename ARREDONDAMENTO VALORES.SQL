CREATE FUNCTION FN_ARREDONDAMENTO_VALORES
(
    @VALOR NUMERIC(15,2)
)
RETURNS NUMERIC(15,2) AS
BEGIN
    DECLARE @DECIMAL           NUMERIC(15)
    DECLARE @FATOR             NUMERIC(15,2)
    DECLARE @VALOR_ARREDONDADO NUMERIC(15,2)
    SELECT
           @DECIMAL = SUBSTRING( CAST( @VALOR AS VARCHA R(20) ) , CHARINDEX('.',@VALOR) + 1 , LEN(@VALOR) - CHARINDEX('.',@VALOR) )
    SELECT
           @FATOR =
           CASE
                  WHEN @DECIMAL / 100 BETWEEN 0.01 AND 0.48
                         THEN 0.49
                  WHEN @DECIMAL / 100 BETWEEN 0.51 AND 0.98
                         THEN 0.99
                         ELSE 0
           END
    SELECT
           @VALOR_ARRED ONDADO =
           CASE
                  WHEN @DECIMAL            IN(0, 50)
                         THEN @VALOR        - 0.01
                         ELSE FLOOR(@VALOR) + @FATOR
           END
    RETURN @VALOR_ARREDONDADO
END
