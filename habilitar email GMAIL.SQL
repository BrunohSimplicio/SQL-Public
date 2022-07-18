---------------------------------------------------------------------------------
-- SQL Database Mail: Enviar e-mail por t-sql usando o Gmail
---------------------------------------------------------------------------------
-- Passo 1) Pré-requisito para usar GMAIL
-- Acessar: https://myaccount.google.com/security e configurar "Allow less secure apps: ON"
 
-- Passo 2) Pré-requisito para enviar e-mails do SQL - Habilitar "Database Mail XPs"
execute sp_configure 'Show Advanced Options', 1
reconfigure
execute sp_configure 'Database Mail XPs', 1
reconfigure
 
-- Passo 3) -- CONFIGURAR A CONTA DO GMAIL NO SQL
-- Adicionar conta de e-mail
execute msdb.dbo.sysmail_add_account_sp
    -- Dados fíxos
    @mailserver_name = 'EMAIL@EMAIL.com', -- endereço do servidor de envio de e-mails
    @port = 587, -- porta de comunicação
    @enable_ssl = 1, -- habilitar SSL (criptografia durante o envio de dados)
    -- Dados da sua conta
    @account_name = 'Gmail_Conta', -- nome da conta dentro do SQL
    @display_name = 'Banco SQL',   -- Nome que aparecerá como remetente do e-mail
    @email_address = 'EMAIL@EMAIL.com',
    @username = 'EMAIL@EMAIL.com',
    @password = 'SENHA'
 
-- Passo 4) Adicionar perfil e associar a conta
-- Adicionar perfil para envio de e-mail
execute msdb.dbo.sysmail_add_profile_sp
    @profile_name = 'Gmail_Perfil',
    @description = 'Perfil para envio de notificações do SQL.'
-- Associar o perfil a conta
execute msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = 'Gmail_Perfil',
    @account_name = 'Gmail_Conta',
    @sequence_number = 1
 
 
-- Feito! :-)
 
 
-- ENVIAR UM E-MAIL DE TESTES PELO SQL! (help: https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-send-dbmail-transact-sql)
execute msdb.dbo.sp_send_dbmail 
    @profile_name = 'Gmail_Perfil',
    @recipients = 'EMAIL@EMAIL.com.br',
    @subject = 'Assunto - Teste Database Mail',
    @body = 'Corpo da mensagem de teste.'
 
 
 
-- CONSULTAS / TROUBLESHOOTING
-- Contas cadastradas no SQL
select * from msdb.dbo.sysmail_account
 
-- Perfis existentes
select * from msdb.dbo.sysmail_profile
 
-- Associações Perfil & Conta
select * from msdb.dbo.sysmail_profileaccount
 
-- Emails enviados
select * from msdb.dbo.sysmail_mailitems
 
-- Consultar logs do gerenciador de e-mails
select * from msdb.dbo.sysmail_log
 
 
 
-- EXCLUIR AS CONFIGURAÇÕES:
/* 
-- Remover logs:
declare @hoje datetime = getdate()
execute msdb.dbo.sysmail_delete_mailitems_sp @sent_before = @hoje
execute msdb.dbo.sysmail_delete_log_sp 
 
-- Excluir profile:
execute msdb.dbo.sysmail_delete_profile_sp @profile_name = 'Gmail_Perfil'
 
-- Excluir conta:
execute msdb.dbo.sysmail_delete_account_sp @account_name = 'Gmail_Conta'
 
*/
