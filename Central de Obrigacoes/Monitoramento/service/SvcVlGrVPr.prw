#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Servi�o de valida��o em grupo das guias de valor pr�-estabelecido
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcVlGrVPr From Service
	   
    Method New() 
    Method runProc()
    
EndClass

Method New() Class SvcVlGrVPr
    _Super:New()
    self:cFila := "FILA_VLD_GUI_VPRE_GRP"
    self:cJob := "JobVlGrVPr"
    self:cObs := "Valida��o em grupo guias de valor pr�-estabelecido"
    self:oFila := CenFilaBd():New(CenCltBVT():New())
    self:oProc := CenVldVPre():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc() Class SvcVlGrVPr
    self:oProc:setOper(self:cCodOpe)
    self:oProc:vldGrupo(self:oFila:oCollection)
Return