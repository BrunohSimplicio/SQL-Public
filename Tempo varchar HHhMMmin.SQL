CREATE FUNCTION FN_HORA (@TEMPO INT)      
       
RETURNS VARCHAR(20)      
AS      
BEGIN      
    
--DECLARE @TEMPO INT = 9302 -- teste    
    
DECLARE @HORARIO VARCHAR(20)      
    
       
DECLARE @HORA    INT      
DECLARE @MINUTO  INT      
DECLARE @SEGUNDO INT      
       
SET @HORA    = (@TEMPO / 3600)      
SET @MINUTO  = (@TEMPO % ( (@HORA + 1) * 3600) ) / 60      
SET @SEGUNDO = (@TEMPO % 3600) % 60      
       
    
--   select @TEMPO      AS TEMPO   ,     
--          @HORA       AS HORA    ,    
--          @MINUTO     AS MINUTO  ,    
--          @SEGUNDO    AS SEGUNDO ,    
--          @TEMPO/3600 AS TEMPO_2    
    
       
SELECT @HORARIO =      
    CASE     
     
 --WHEN @TEMPO/3600 >= 1 THEN      
       
 --       CASE LEN(CAST((@HORA)        AS VARCHAR)) WHEN 1 THEN '0' ELSE '' END      
 --     + CAST ((@HORA) AS VARCHAR) + 'h'      
       
 --     + CASE LEN(CAST((@MINUTO)        AS VARCHAR)) WHEN 1 THEN '0' ELSE '' END      
 --     + CAST((@MINUTO) AS VARCHAR) +  'min'      
       
 --     + CASE LEN(CAST((@SEGUNDO)    AS VARCHAR)) WHEN 1 THEN '0' ELSE '' END      
 --     + CAST((@SEGUNDO) AS VARCHAR)      
      
       
WHEN 1=1--@TEMPO >= 60     
     THEN      
      
        CASE LEN(CAST((@MINUTO)        AS VARCHAR)) WHEN 1 THEN '0' ELSE '' END      
      + CAST ((@MINUTO) AS VARCHAR) + 'h'      
       
      + CASE LEN(CAST((@SEGUNDO)        AS VARCHAR)) WHEN 1 THEN '0' ELSE '' END      
      + CAST((@SEGUNDO) AS VARCHAR) +  'min'      
      
      
    ELSE      
      --  CASE LEN(CAST((@MINUTO)        AS VARCHAR)) WHEN 1 THEN '0' ELSE '' END      
      --+ CAST((@MINUTO) AS VARCHAR) +  'h'      
       
      CASE WHEN LEN(CAST((@SEGUNDO)    AS VARCHAR)) >= 1 THEN      
        CASE WHEN LEN(CAST((@SEGUNDO)    AS VARCHAR)) = 1 THEN '0' ELSE '' END      
           + CAST((@SEGUNDO) AS VARCHAR) +  'min'      
      END      
    END      
    
--SELECT @HORARIO    
       
RETURN(@HORARIO)      
END
