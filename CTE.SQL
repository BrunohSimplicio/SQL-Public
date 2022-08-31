CREATE VIEW VW_TABELA                      
                      
AS                      
                      
WITH CTE                      
                      
AS                      
(                      
                      
SELECT ROW_NUMBER() OVER(PARTITION BY A.EMP, B.PROD ORDER BY A.MOV DESC , A.NF DESC ) AS ID                       
     , A.NF  AS NF                
     , A.MOV AS MOVIMENTO                
     , A.EMP AS EMPRESA                          
     , B.PRO AS PRODUTO                             
  FROM NF         A WITH(NOLOCK)                              
  JOIN NF_PROD    B WITH(NOLOCK) ON A.NF = B.FN                              
  JOIN OP_FISCAIS C WITH(NOLOCK) ON C.OP = B.OP                                                 
                      
)                
                      
SELECT A.NF                  
     , A.MOVIMENTO                
     , A.EMPRESA                      
     , A.PRODUTO                
     , CASE WHEN A.NF = MAX( A.NF ) OVER ( PARTITION BY PRODUTO ORDER BY MOVIMENTO DESC ) THEN 1 ELSE 0 END AS ULTIMA_MOVIMENTACAO                
  FROM CTE   A                      
  WHERE ID = 1
