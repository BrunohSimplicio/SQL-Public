SELECT ROW_NUMBER() OVER (ORDER BY nome) AS sequencia, 
       codigo, 
       nome 
FROM clientes ORDER BY nome



ROW_NUMBER() OVER(PARTITION BY A.ENTIDADE ORDER BY COUNT(A.ENTIDADE) DESC ) AS ID


--** criar id sem usar o grupo by
RANK() OVER (ORDER BY A.ENTIDADE)
