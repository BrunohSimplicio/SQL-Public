SELECT distinct B.name ,
case type when 'P' then 'Stored procedure'
when 'FN' then 'Function'
when 'TF' then 'Function'
when 'TR' then 'Trigger'
when 'V' then 'View'
else 'Outros Objetos'
end
FROM syscomments A (nolock)
JOIN sysobjects B (nolock) on A.Id = B.Id
WHERE A.Text like '%valor_base%'  --Objto a ser procurado
ORDER BY 2 DESC,1
 
