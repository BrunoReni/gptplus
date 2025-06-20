#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "LXOUTFIN.CH"

/*/{Protheus.doc} LXOUTFIN
Clase responsable por el evento de reglas de negocio de 
localizaci�n padr�n

@type 		Class
@author 	raul.medina
@version	12.1.2210 / Superior
@since		04/2023
/*/
Class LXOUTFIN From FwModelEvent

    //Propiedades que pueden ser alteradas desde los eventos con localizaci�n
    DATA oTipoDoc as object
    DATA lDuplicatas as logical
    DATA lAjustDup as logical
    DATA lCharDup as logical
    DATA cCharDup as character

    Method New() CONSTRUCTOR
    Method Activate()
    Method VldActivate()
    Method ModelPosVld()
    Method GridPosVld()
    Method GridLinePosVld()
    Method UpdNumberDetail()

EndClass


/*/{Protheus.doc} New
Metodo responsable de la contrucci�n de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.2210 / Superior
@since		04/2023
/*/
Method New() Class LXOUTFIN 


Return Nil

/*/{Protheus.doc} Activate
Metodo activate

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		lCopy    ,caracter	,Informa si el model debe copiar los datos del registro posicionado.
@author 	raul.medina
@version	12.1.2210 / Superior
@since		04/2023
/*/
Method Activate(oModel, lCopy) Class LXOUTFIN

    self:oTipodoc := TipoDoc():New()
    self:lDuplicatas := .T.
    self:lAjustDup := !(cPaisLoc == "EUA")
    self:lCharDup := cPaisLoc == "RUS"
    self:cCharDup :=  CHR(124)

Return

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		cModelID ,caracter	,Identificador do sub-modelo.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina
@version	12.1.2210 / Superior
@since		04/2021 
/*/
Method VldActivate(oModel, cModelId) Class LXOUTFIN
Local lRet := .T.

Return lRet

/*/{Protheus.doc} ModelPosVld
M�todo responsable por ejecutar las valida�ioes de las reglas de negocio
gen�ricas del cadastro antes de la grabaci�n del formulario.
Si retorna falso, no permite grabar.

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		cModelID ,caracter	,Identificador do sub-modelo.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina
@version	12.1.2210 / Superior
@since		04/2023
/*/
Method ModelPosVld(oModel, cModelId) Class LXOUTFIN
Local lRet      := .T. 
Local oModelSF2 := oModel:GetModel("SF2_MASTER")
Local oModelDUP := oModel:GetModel("DUP_DETAIL")
Local oModelSEV := oModel:GetModel("SEV_DETAIL")
Local nBaseDup  := 0
Local nMonedaNF := 0
Local nTaxa     := 0
Local nValBrut  := 0
Local nI        := 0
Local nTotDup   := 0
Local nVend     := 0
Local nValMulNat:= 0
Local cCondicao := ""
Local cTipoDoc  := ""
Local cNatureza := ""
Local cVendedor := ""
Local cCpoVend  := ""
Local cSerie    := ""
Local cNFiscal  := ""
Local cCliFor   := ""
Local cLoja     := ""
Local cEspecie  := ""
Local cNumAnt   := ""
Local cEspAux   := ""
Local nUpdNum   := SuperGetMV("MV_ALTNUM",,1)
Local aArea     := {}
Local aDupli    := {}

    cTipoDoc    := oModelSF2:GetValue("F2_TIPODOC")
    nBaseDup    := IIf(oModelSF2:HasField("BASEDUP"),  oModelSF2:GetValue("BASEDUP"), 0)
    cCondicao   := oModelSF2:GetValue("F2_COND")
    cNatureza   := oModelSF2:GetValue("F2_NATUREZ")
    nMonedaNF   := oModelSF2:GetValue("F2_MOEDA")
    nTaxa       := oModelSF2:GetValue("F2_TXMOEDA")
    nValBrut    := oModelSF2:GetValue("F2_VALBRUT")
    cSerie      := oModelSF2:GetValue("F2_SERIE")
    cNFiscal    := oModelSF2:GetValue("F2_DOC")
    cCliFor     := oModelSF2:GetValue("F2_CLIENTE")
    cLoja       := oModelSF2:GetValue("F2_LOJA")
    cEspecie    := oModelSF2:GetValue("F2_ESPECIE")
    cEspAux     := PADR(cEspecie,GETSX3CACHE("E1_TIPO", "X3_TAMANHO"))
    self:oTipoDoc:SetTipoDoc(cTipoDoc)

    If self:oTipoDoc:ValidConditionPayment() .and. nBaseDup > 0 .and. Empty(cCondicao)
        oModel:SetErrorMessage("SF2_MASTER", 'F2_COND', 'SF2_MASTER', 'F2_COND', 'Condition', STR0001 + GetSx3Cache('F2_COND',"X3_TITULO"), '', '') //Complete el campo del encabezado:
        lRet := .F.
    EndIf

    If lRet
        //Verificaci�n de existencia del numero de documento usado.
        For nI := 1 To oModelDUP:Length()
            aAdd(aDupli, oModelDUP:GetValue("DUP",nI))
        Next
        lExist := !aDupNaoExiste("SF2", cSerie, cNFiscal, cCliFor, cLoja, cEspAux, aDupli, .F.)
        If lExist
            If self:oTipoDoc:UpdateNumberDoc() //Documentos de formulario propio.
                While lExist
                    cNFiscal    := Soma1(cNFiscal)
                    lExist      := !aDupNaoExiste("SF2", cSerie, cNFiscal, cCliFor, cLoja, cEspAux, aDupli, .F.)
                EndDo
                If nUpdNum == 1 //Realiza la actualizaci�n de la numeraci�n.
                    cNumAnt := oModelSF2:GetValue("F2_DOC")
                    self:UpdNumberDetail(cNFiscal)
                    MsgInfo(STR0010 + cNumAnt + STR0011 + cNFiscal, STR0012) //El n�mero del documento fue modificado de: #  a:  # N�mero
                ElseIf nUpdNum == 2 //Pregunta si debe realizar la actualizaci�n de la numeraci�n.
                    lRet:= MsgYesNo(STR0013 + oModelSF2:GetValue("F2_DOC") +  STR0014 + cNFiscal  ) //El documento N�:  #  existe, confirma modificaci�n de la numeraci�n a: 
                    If lRet
                        self:UpdNumberDetail(cNFiscal)
                    EndIf
                Else //No realiza la actualizaci�n de la numeraci�n.
                    oModel:SetErrorMessage("SF2_MASTER", 'F2_DOC', "SF2_MASTER", 'F2_DOC', 'NumDocument', STR0015 +"("+cNFiscal+"/"+cSerie+")" , '', '') //�Verifique la numeraci�n de la Factura! Esta Factura ya existe.
                    lRet := .F.
                EndIf
            Else //Documento de no formulario propio.
                oModel:SetErrorMessage("SF2_MASTER", 'F2_DOC', "SF2_MASTER", 'F2_DOC', 'NumDocument', STR0013 + "("+cNFiscal+" / "+cSerie+")" + STR0015, '', '') //El documento N�:  # ya existe
                lRet := .F.
            EndIf
        EndIf
    EndIf
    
    //Verificaci�n de existencia de vendedores.
    If lRet
        aArea := GetArea()
        SA3->(dbSetOrder(1))
        nVend := Fa440CntVen()
        For nI := 1 to nVend
            cCpoVend  := "F2_VEND"+AllTrim(Str(nI))
            cVendedor := oModelSF2:GetValue(cCpoVend)
            If !Empty(cVendedor)
                If !SA3->(MsSeek(xFilial("SA3")+cVendedor))
                    oModel:SetErrorMessage("SF2_MASTER", cCpoVend, 'SF2_MASTER', cCpoVend, cCpoVend, STR0004 + "(" + cVendedor + ")", '', '') //�C�digo de vendedor inv�lido!
                    lRet := .F.
                    exit
                EndIf
            EndIf
        Next nI
        RestArea(aArea)
    EndIf

    If lRet .and. self:lDuplicatas .and. self:oTipoDoc:ValidFinancialTitle(cPaisLoc) .and. oModelDUP:Length() > 0
        For nI := 1 To oModelDUP:Length()
            nTotDup += DesTrans(Extrae(oModelDUP:GetValue("DUP", nI),5,Iif(self:lCharDup,self:cCharDup,)))
        Next nI
        //Ajuste para permitir el valor financiero con impuestos provisionales del MATA462N y MATA462AN
        If self:lAjustDup .and. nTotDup > 0
            If Abs(xMoeda(nBaseDup,nMonedaNF,nMonedaNF,dDataBase,,nTaxa) - nTotDup) > SuperGetMV("MV_LIMPAG")
                oModel:SetErrorMessage("SF2_MASTER", 'F2_COND', 'SF2_MASTER', 'F2_COND', 'TitlesFin', STR0003, '', '') //Inconsistencias en los valores financieros.
                lRet	:= .F.
            EndIf
        EndIf
    EndIf
    
    //Validaci�n de monto no negativo
    If lRet .and. xMoeda(nValBrut,nMonedaNF,nMonedaNF,dDataBase,,nTaxa) < 0
        Help("  ",1,'TOTAL')
        lRet := .F.
    EndIf

    //Validaci�n para considerar el valor total de las multinaturalezas
    If lRet .and. (self:oTipoDoc:ValidMultiNatureSE1() .or. self:oTipoDoc:ValidMultiNatureSE2()) .and. nBaseDup > 0 
        For nI := 1 To oModelSEV:Length()
            nValMulNat += oModelSEV:GetValue("EV_VALOR", nI)
        Next
        If nValMulNat <> 0 .and. nValMulNat <> nValBrut
            lRet := .F.
            oModel:SetErrorMessage("SEV_DETAIL", 'EV_VALOR', "SEV_DETAIL", 'EV_VALOR', 'MultiNature', STR0009, '', '') //Valor de modalidades incorrecto.
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} GridPosVld
Metodo responsabe por ejecutar reglas de negocio genericas para validaci�n de grid.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		04/2023
/*/
Method GridPosVld(oSubModel, cModelID) Class LXOUTFIN
Local lRet      := .T.
Local nX        := 0
Local nPorcent  := 0
Local oModel    := FwModelActivate()

    //Verificaci�n del 100% de prorrateo en las multi naturalezas
    If cModelID == "SEV_DETAIL"
        For nX := 1 To oSubModel:Length()
            nPorcent += oSubModel:GetValue("EV_PERC", nX)
        Next
        If nPorcent <> 100 .And. nPorcent<> 0
            lRet := .F.
            oModel:SetErrorMessage(cModelID, 'EV_PERC', cModelID, 'EV_PERC', 'MultiPerc', STR0007 + STR0008 + TransForm(nPorcent,"@E 99.99%"), '', '') //La suma de los porcentajes informados de totalizar 100%. # Porcentaje alcanzado ==>
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} GridLinePosVld
Metodo responsabe por ejecutar reglas de negocio genericas para validaci�n de l�nea.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@param 		nLine		,numerico	,N�mero de l�nea validada
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		03/2023
/*/
Method GridLinePosVld(oSubModel, cModelID, nLine) Class LXOUTFIN
Local lRet      := .T.
Local cTes      := ""
Local nQuant    := 0
Local nUnValue  := 0
Local nTotal    := 0
Local nTotAux   := 0
Local nMonedaNF := 1
Local oModel    := FwModelActivate()
Local oModelSF2 := oModel:GetModel("SF2_MASTER")


    If cModelID == "SD2_DETAIL"

        cTes        := oSubModel:GetValue("D2_TES", nLine)
        nQuant      := oSubModel:GetValue("D2_QUANT", nLine)
        nUnValue    := oSubModel:GetValue("D2_PRCVEN", nLine)
        nTotal      := oSubModel:GetValue("D2_TOTAL", nLine)
        nMonedaNF   := oModelSF2:GetValue("F2_MOEDA")

        If lRet .and. nUnValue < 0
            lRet := .F.
            oModel:SetErrorMessage(cModelID, 'D2_PRCVEN', cModelID, 'D2_PRCVEN', 'UnitVal', STR0005, '', '') //Valor unitario no puede ser negativo.
        EndIf

        If lRet .and. self:oTipoDoc:ValidDecimals(cPaisLoc)
            If MaTesSel(cTes).And. nQuant == 0
                If !self:oTipoDoc:NoValidTotalZero() .and. nUnValue<>nTotal
                    oModel:SetErrorMessage(cModelID, 'D2_TOTAL', cModelID, 'D2_TOTAL', 'QuantZero', STR0006, '', '') //Inconsistencia en los valores del documento.
                    lRet := .F.
                EndIf
            Else
                nTotAux := Iif(self:oTipoDoc:ValidArred(cPaisLoc), A410Arred((nUnValue*nQuant),"D2_TOTAL",nMonedaNF),(nUnValue*nQuant))
                If Abs(nTotal - nTotAux) > (1/(10**(Iif(MsDecimais(nMonedaNF)==0,1,MsDecimais(nMonedaNF))-1)))/   IIF (MsDecimais(nMonedaNF)==0 ,1,  2) 
                    lRet := .F.
                    oModel:SetErrorMessage(cModelID, 'D2_TOTAL', cModelID, 'D2_TOTAL', 'D2_TOTAL', STR0006, '', '') //Inconsistencia en los valores del documento.
                EndIf
            EndIf
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} UpdNumberDetail
Metodo responsabe por realizar la actualizaci�n en caso de cambio de numeraci�n por duplicidad,
actualiza datos en SF2 y SD2.
@type 		Method
@param 		cNumDoc	,caracter	, numero a ser actualizado en el modelo, encabezado y detalle.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		05/2023
/*/
Method UpdNumberDetail(cNumDoc) Class LXOUTFIN
Local nX        := 0
Local nD2line   := 0
Local oModel    := FwModelActivate()
Local oModelSD2 := oModel:GetModel("SD2_DETAIL")

Default cNumDoc := ""

    oModel:GetModel("SF2_MASTER"):LoadValue("F2_DOC", cNumDoc)
    nD2line := oModelSD2:GetLine()
    For nX := 1 To oModelSD2:Length()
        oModelSD2:GoLine(nX)
        If !oModelSD2:IsDeleted()
            oModelSD2:LoadValue("D2_DOC", cNumDoc)
        EndIf
    Next
    oModelSD2:GoLine(nD2line)

Return
