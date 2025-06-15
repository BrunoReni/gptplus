IF OBJECT_ID(N'dbo.proc_diu_cli_transportadora_wx') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.proc_diu_cli_transportadora_wx
    IF OBJECT_ID(N'dbo.proc_diu_cli_transportadora_wx') IS NOT NULL
        PRINT N'<<< FAILED DROPPING PROCEDURE dbo.proc_diu_cli_transportadora_wx >>>'
    ELSE
        PRINT N'<<< DROPPED PROCEDURE dbo.proc_diu_cli_transportadora_wx >>>'
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
create PROCEDURE proc_diu_cli_transportadora_wx(
  @w_operacao int,
  @w_cli_id   char(6),
  @w_trans_id int = null,
  @w_permisso varchar(5) = null,
  @w_status int  
)
AS
begin

     if @w_trans_id = 0
        select  @w_trans_id = null
        
    if @w_permisso = ''
       select @w_permisso = null

    exec proc_diu_cli_transportadora @w_operacao, @w_cli_id  ,@w_trans_id,@w_permisso ,@w_status
    
return 0
end
go
IF OBJECT_ID(N'dbo.proc_diu_cli_transportadora_wx') IS NOT NULL
    PRINT N'<<< CREATED PROCEDURE dbo.proc_diu_cli_transportadora_wx >>>'
ELSE
    PRINT N'<<< FAILED CREATING PROCEDURE proc_diu_cli_transportadora_wx >>>'
go
