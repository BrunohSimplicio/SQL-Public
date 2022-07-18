
SELECT d.plan_handle ,
       d.sql_handle ,
       --d.creation_time,
       --d.last_execution_time,
       e.text

  FROM sys.dm_exec_query_stats d
       CROSS APPLY sys.dm_exec_sql_text(d.plan_handle) AS e
 WHERE text like '%GERAR_COMISSAO_TELEVENDAS_LIQUIDACOES%'
