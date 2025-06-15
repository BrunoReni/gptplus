IF OBJECT_ID(N'dbo.proc_diu_clientes1_wx') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.proc_diu_clientes1_wx
    IF OBJECT_ID(N'dbo.proc_diu_clientes1_wx') IS NOT NULL
        PRINT N'<<< FAILED DROPPING PROCEDURE dbo.proc_diu_clientes1_wx >>>'
    ELSE
        PRINT N'<<< DROPPED PROCEDURE dbo.proc_diu_clientes1_wx >>>'
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
create PROCEDURE dbo.proc_diu_clientes1_wx(
  @w_operacao       int        ,
  @w_cli_id        char(6)       = NULL,
  @w_cli_nome       varchar(50)     = NULL,
  @w_cli_cgc       char(14)      = NULL,
  @w_cli_cpf       char(12)      = NULL,
  @w_cli_ie        char(25)      = NULL,
  @w_cli_retorno   char(6)       = NULL OUTPUT,
  @w_arma_id       char(4)       = null,
  @w_cli_nomefan       char(30)      = null,
  @w_gru_id        char(6) = null
)
AS
begin

 If @w_cli_id = ''
    select @w_cli_id = null
 If @w_arma_id = ''
    select @w_arma_id = null
 If @w_gru_id = ''
    select @w_gru_id = null
 If @w_cli_ie = ''
    select @w_cli_ie = null 
 
    exec proc_diu_clientes1 @w_operacao, @w_cli_id  ,@w_cli_nome,@w_cli_cgc ,@w_cli_cpf,@w_cli_ie,@w_cli_retorno,@w_arma_id,@w_cli_nomefan,@w_gru_id
    
return 0
end
go
IF OBJECT_ID(N'dbo.proc_diu_clientes1_wx') IS NOT NULL
    PRINT N'<<< CREATED PROCEDURE dbo.proc_diu_clientes1_wx >>>'
ELSE
    PRINT N'<<< FAILED CREATING PROCEDURE dbo.proc_diu_clientes1_wx >>>'
go
