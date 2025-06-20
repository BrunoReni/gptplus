#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqMuni from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqMuni
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqMuni
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltMuni():New()
    self:oValidador := CenVldMuni():New()
    self:cPropLote   := "Muni"
Return self

Method applyFilter(nType) Class CenReqMuni
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("ibgeCityCode",self:oRest:ibgeCityCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("stateAcronym",self:oRest:stateAcronym)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("ibgeCityCode",self:oRest:ibgeCityCode)
            self:oCollection:setValue("providerRegister",self:oRest:providerRegister)
            self:oCollection:setValue("stateAcronym",self:oRest:stateAcronym)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqMuni
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqMuni

    Default oJson := self:jRequest
    self:oCollection:setValue("ibgeCityCode", self:oRest:ibgeCityCode)
    self:oCollection:setValue("providerRegister", self:oRest:providerRegister)
    self:oCollection:setValue("stateAcronym", self:oRest:stateAcronym)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqMuni

    Local lExiste := .F.
    If self:lSuccess
        If nType == BUSCA
            self:oCollection:buscar()
        Else
            lExiste := self:oCollection:bscChaPrim()
            If nType == INSERT
                self:lSuccess := !lExiste
            Else
                self:lSuccess := lExiste
            EndIf
        EndIf
    EndIf

Return self:lSuccess


