IF OBJECT_ID(N'dbo.proc_diu_portal_acesso_info_wx') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.proc_diu_portal_acesso_info_wx
    IF OBJECT_ID(N'dbo.proc_diu_portal_acesso_info_wx') IS NOT NULL
        PRINT N'<<< FAILED DROPPING PROCEDURE dbo.proc_diu_portal_acesso_info_wx >>>'
    ELSE
        PRINT N'<<< DROPPED PROCEDURE dbo.proc_diu_portal_acesso_info_wx >>>'
END
go
/*VERSAO SCRIPT 012.001.000.000
-------------------------------------------------------------------------------
VERSAO............: 012.001.000.000
DATA ALTERACAO....: 26/11/2015
ALTERADOR POR.....: MOHAMED S. B. DJALO
REQUISITO.........: PCREQ-3005
RESUMO ALTERACAO..: PORTAL - WEB: Cadastrar clientes durante o processo de agendamento
----------------------------------------------------------------------------------
*/
create PROCEDURE dbo.proc_diu_portal_acesso_info_wx(
    @w_operacao           int,
    @w_pai_id                int = null,
    @w_pcm_id              int,
    @w_gru_id               char(6) = null,
    @w_cli_id                 char(6) = null,
    @w_pai_dt_cadastro   varchar(19) = null,
    @w_pai_bloqueado     int,
    @w_pai_dt_bloqueio    varchar(19) = null
)
AS
begin

  If @w_pai_id = 0
    select @w_pai_id = null
  If @w_gru_id = 0
    select @w_gru_id = null
  If @w_cli_id = 0
    select @w_cli_id = null
  If @w_gru_id = ''
    select @w_gru_id = null
  If @w_pai_dt_cadastro = ''
    select @w_pai_dt_cadastro = null
  If @w_pai_dt_bloqueio = ''
    select @w_pai_dt_bloqueio = null

    exec proc_diu_portal_acesso_info @w_operacao, @w_pai_id  ,@w_pcm_id,@w_gru_id ,@w_cli_id,@w_pai_dt_cadastro,@w_pai_bloqueado,@w_pai_dt_bloqueio
    
return 0
end
go
IF OBJECT_ID(N'dbo.proc_diu_portal_acesso_info_wx') IS NOT NULL
    PRINT N'<<< CREATED PROCEDURE dbo.proc_diu_portal_acesso_info_wx >>>'
ELSE
    PRINT N'<<< FAILED CREATING PROCEDURE dbo.proc_diu_portal_acesso_info_wx >>>'
go
