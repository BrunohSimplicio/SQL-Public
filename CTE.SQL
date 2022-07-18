CREATE VIEW VW_TABELA                      
                      
AS                      
                      
WITH CTE                      
                      
AS                      
(                      
                      
SELECT ROW_NUMBER() OVER(PARTITION BY DBO.FN_EMPRESA_CONTABIL( A.EMPRESA ) , B.PRODUTO ORDER BY A.MOVIMENTO DESC , A.NF_COMPRA DESC ) AS ID                       
     , A.NF_COMPRA                                                                      AS NF_COMPRA                
     , A.MOVIMENTO                                                                      AS MOVIMENTO                
     , A.EMPRESA                                                                        AS EMPRESA                          
     , B.PRODUTO                                                                        AS PRODUTO                             
  FROM NOTAS_COMPRA       A WITH(NOLOCK)                              
  JOIN NOTAS_COMPRA_ITENS B WITH(NOLOCK) ON A.NF_COMPRA       = B.NF_COMPRA                              
  JOIN OP_FISCAIS         C WITH(NOLOCK) ON C.OPERACAO_FISCAL = B.OPERACAO_FISCAL                              
 WHERE C.TIPO_OPERACAO NOT IN( 10 )       
   AND ISNULL(C.AFETA_FORMACAO_PRECO,'N') = 'S'    
   AND A.EMPRESA NOT IN(500) --APENAS LICITACAÇÃO CONFORME FALADO POR GLAUCO      
   AND (     ( C.RECEBIMENTO = 'S' AND A.RECEBIMENTO IS NOT NULL )                              
         OR  ( C.RECEBIMENTO = 'N'                               )   )                              
   AND A.PROCESSAR = 'S'               
   --AND B.PRODUTO = 95772            
   AND A.ENTIDADE NOT IN( SELECT ENTIDADE FROM EMPRESAS_USUARIAS (NOLOCK) )                      
                      
)                
                      
SELECT A.NF_COMPRA                  
     , A.MOVIMENTO                
     , A.EMPRESA                      
     , A.PRODUTO                
     , CASE WHEN A.NF_COMPRA = MAX( A.NF_COMPRA ) OVER ( PARTITION BY PRODUTO ORDER BY MOVIMENTO DESC ) THEN 1 ELSE 0 END AS ULTIMA_MOVIMENTACAO                
  FROM CTE   A                      
  WHERE ID = 1