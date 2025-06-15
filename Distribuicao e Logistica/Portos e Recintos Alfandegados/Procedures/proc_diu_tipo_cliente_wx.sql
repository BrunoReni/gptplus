IF OBJECT_ID(N'dbo.proc_diu_tipo_cliente_wx') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.proc_diu_tipo_cliente_wx
    IF OBJECT_ID(N'dbo.proc_diu_tipo_cliente_wx') IS NOT NULL
        PRINT N'<<< FAILED DROPPING PROCEDURE dbo.proc_diu_tipo_cliente_wx >>>'
    ELSE
        PRINT N'<<< DROPPED PROCEDURE dbo.proc_diu_tipo_cliente_wx >>>'
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
CREATE PROCEDURE dbo.proc_diu_tipo_cliente_wx
(   @w_operacao             int,
    @w_cli_id                   char(6)     = NULL,
    @w_tcli_id                  integer      = NULL,
    @w_gru_id                 char(6)
)
AS
begin

 if @w_tcli_id = ''
    select @w_tcli_id = null
    
 If @w_gru_id = ''
    select @w_gru_id = null

    exec proc_diu_tipo_cliente @w_operacao, @w_cli_id, @w_tcli_id, @w_gru_id
    
return 0
end
go
IF OBJECT_ID(N'dbo.proc_diu_tipo_cliente_wx') IS NOT NULL
    PRINT N'<<< CREATED PROCEDURE dbo.proc_diu_tipo_cliente_wx >>>'
ELSE
    PRINT N'<<< FAILED CREATING PROCEDURE dboproc_diu_tipo_cliente_wx >>>'
go
