CREATE FUNCTION dbo.fn_pascoa(@Ano INT)   
RETURNS TABLE  
AS   
RETURN   
  
--DECLARE @Ano INT = 2023;  
  
WITH x AS   
  (  
    SELECT Data = DATEFROMPARTS(@Ano, [Month], [Day])  
      FROM (SELECT [Month], [Day] = DaysToSunday + 28 - (31 * ([Month] / 4))  
      FROM (SELECT [Month] = 3 + (DaysToSunday + 40) / 44, DaysToSunday  
      FROM (SELECT DaysToSunday = paschal - ((@Ano + (@Ano / 4) + paschal - 13) % 7)  
      FROM (SELECT paschal = epact - (epact / 28)  
      FROM (SELECT epact = (24 + 19 * (@Ano % 19)) % 30)   
        AS epact) AS paschal) AS dts) AS m) AS d  
  )  

SELECT Data, Feriado = 'Páscoa' FROM x  
 UNION ALL 
SELECT DATEADD(DAY, -2, Data), 'Sexta-Feira Santa'   FROM x   
 UNION ALL 
SELECT DATEADD(DAY, -47, Data), 'Carnaval'   FROM x
