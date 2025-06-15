IF OBJECT_ID('dbo.proc_corrige_rec_del') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.proc_corrige_rec_del
    IF OBJECT_ID('dbo.proc_corrige_rec_del') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.proc_corrige_rec_del >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.proc_corrige_rec_del >>>'
END
go
/*VERSAO SCRIPT 012.001.000.000
-------------------------------------------------------------------------------
VERSAO............: 012.001.000.000
DATA ALTERACAO....: 24/03/2017
ALTERADOR POR.....: Rosiane de Avila.
RESUMO ALTERACAO..: Procedure para a correcao do erro de tabela temporaria no protheus.
-------------------------------------------------------------------------------
*/
create procedure dbo.proc_corrige_rec_del @w_name_table varchar(200) as
begin
  declare @sqlexecute varchar(200)
  
  BEGIN TRY  
    select @sqlexecute ='ALTER TABLE '+ @w_name_table + ' DROP  CONSTRAINT [' + @w_name_table + '_R_E_C_D_E_L__DF]'
	exec (@sqlexecute)
	
    select @sqlexecute ='alter table ' + @w_name_table + ' drop column R_E_C_D_E_L_'	
    exec (@sqlexecute)	  
  END TRY  
  BEGIN CATCH  		 
  END CATCH   
	
end
go
IF OBJECT_ID('dbo.proc_corrige_rec_del') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.proc_corrige_rec_del >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.proc_corrige_rec_del >>>'
go