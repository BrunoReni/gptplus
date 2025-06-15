IF OBJECT_ID(N'dbo.proc_portal_usu_menu_info_wx') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.proc_portal_usu_menu_info_wx
    IF OBJECT_ID(N'dbo.proc_portal_usu_menu_info_wx') IS NOT NULL
        PRINT N'<<< FAILED DROPPING PROCEDURE dbo.proc_portal_usu_menu_info_wx >>>'
    ELSE
        PRINT N'<<< DROPPED PROCEDURE dbo.proc_portal_usu_menu_info_wx >>>'
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
create PROCEDURE dbo.proc_portal_usu_menu_info_wx(
    @w_operacao int,
    @w_pumi_id  int = null,
    @w_puc_id   int,
    @w_pai_id   int,
    @w_pumi_dt_cadastro   varchar(19) = null
)
AS
begin

    exec proc_di_portal_usu_menu_info @w_operacao, @w_pumi_id, @w_puc_id, @w_pai_id, @w_pumi_dt_cadastro
    
return 0
end
go
IF OBJECT_ID(N'dbo.proc_portal_usu_menu_info_wx') IS NOT NULL
    PRINT N'<<< CREATED PROCEDURE dbo.proc_portal_usu_menu_info_wx >>>'
ELSE
    PRINT N'<<< FAILED CREATING PROCEDURE dbo.proc_portal_usu_menu_info_wx >>>'
go
