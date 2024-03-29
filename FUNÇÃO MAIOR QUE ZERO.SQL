CREATE FUNCTION [dbo].[MAIOR_ZERO] ( @VALOR_1 NUMERIC(15,2),  @VALOR_2 NUMERIC(15,2) ) RETURNS NUMERIC(15,2) AS  
  
BEGIN  
----------------------------------------------------------------------  
--ROTINA PARA CONCATENACAO DOS FILIAIS DO RECEBIMENTO  
----------------------------------------------------------------------  
  
DECLARE @VALOR_FINAL              NUMERIC(15,2)  
  
  
SELECT @VALOR_FINAL = ( CASE WHEN @VALOR_1 > 0  
                             THEN @VALOR_1  
                             ELSE @VALOR_2  
                         END  )  
  
  
     RETURN ( @VALOR_FINAL )  
  
END  
