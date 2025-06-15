#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Servi�o de valida��o em grupo das guias de outras remunera��es
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcVlGrORe From Service
	   
    Method New() 
    Method runProc()
    
EndClass

Method New() Class SvcVlGrORe
    _Super:New()
    self:cFila := "FILA_VLD_GUI_OREM_GRP"
    self:cJob := "JobVlGrORe"
    self:cObs := "Valida��o em grupo outras remunera��es"
    self:oFila := CenFilaBd():New(CenCltBVT():New())
    self:oProc := CenVldORem():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc() Class SvcVlGrORe
    self:oProc:setOper(self:cCodOpe)
    self:oProc:vldGrupo(self:oFila:oCollection)
Return