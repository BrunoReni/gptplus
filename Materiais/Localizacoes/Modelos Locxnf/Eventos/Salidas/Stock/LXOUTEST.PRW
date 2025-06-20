#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "LXOUTEST.CH"

/*/{Protheus.doc} LXOUTEST
Clase responsable por el evento de reglas de negocio de 
localizaci�n padr�n

@type 		Class
@author 	raul.medina
@version	12.1.2210 / Superior
@since		05/2023
/*/
Class LXOUTEST From FwModelEvent

    //Propiedades que pueden ser alteradas desde los eventos con localizaci�n
    DATA oTipoDoc as object

    Method New() CONSTRUCTOR
    Method Activate()
    Method VldActivate()
    Method ModelPosVld()
    Method GridPosVld()
    Method GridLinePosVld()
    Method LocxTravaSB2()
    Method SumIdentB6()
    Method SumDev()
    Method SumDevRem()
    Method SaldoOk()
    Method LocXAvStok()

EndClass


/*/{Protheus.doc} New
Metodo responsable de la contrucci�n de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.2210 / Superior
@since		05/2023
/*/
Method New() Class LXOUTEST 


Return Nil

/*/{Protheus.doc} Activate
Metodo activate

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		lCopy    ,caracter	,Informa si el model debe copiar los datos del registro posicionado.
@author 	raul.medina
@version	12.1.2210 / Superior
@since		05/2023
/*/
Method Activate(oModel, lCopy) Class LXOUTEST

    self:oTipodoc := TipoDoc():New()

Return

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		cModelID ,caracter	,Identificador do sub-modelo.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina
@version	12.1.2210 / Superior
@since		05/2021 
/*/
Method VldActivate(oModel, cModelId) Class LXOUTEST
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
@since		05/2023
/*/
Method ModelPosVld(oModel, cModelId) Class LXOUTEST
Local lRet      := .T. 
Local cTipoDoc  := ""
Local oModelSF2 := oModel:GetModel("SF2_MASTER")

    cTipoDoc    := oModelSF2:GetValue("F2_TIPODOC")
    self:oTipoDoc:SetTipoDoc(cTipoDoc)

    //Validaci�n de grupo de depositos.
    If self:oTipoDoc:ValidDepositGruop() .and. oModelSF2:GetValue("F2_TIPORET") == "1" .and. Empty(oModelSF2:GetValue("F2_GRPDEP"))
        oModel:SetErrorMessage("SF2_MASTER", 'F2_TIPORET', 'SF2_MASTER', 'F2_TIPORET', 'TIPORET', STR0017, '', '') //'Se debe informar el Grupo de dep�sitos.'
        lRet := .F.
    EndIf

Return lRet

/*/{Protheus.doc} GridPosVld
Metodo responsabe por ejecutar reglas de negocio genericas para validaci�n de grid.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@Return     lRet        ,logico    ,Retorno de las validaciones.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		05/2023
/*/
Method GridPosVld(oSubModel, cModelID) Class LXOUTEST
Local lRet      := .T.

    If cModelID == "SD2_DETAIL"
        lRet := self:LocxTravaSB2()
        //Validaci�n de saldo en stock.
        If lRet
            lRet := self:LocXAvStok()
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
@since		05/2023
/*/
Method GridLinePosVld(oSubModel, cModelID, nLine) Class LXOUTEST
Local lRet      := .T.
Local lVerLoca	:= .T.
Local lVldLocal := .F.
Local lQtdeZero := .F.
Local cCodProd  := ""
Local cAliasVld := ""
Local cRvSB5	:= ""
Local cBlqSG5	:= ""
Local cStatus	:= ""
Local cTipoDoc  := ""
Local nQuantB6  := 0
Local nQuantAux := 0
Local cFilSB1	:= xFilial("SB1")
Local cFilSF4	:= xFilial("SF4")
Local lLocaliz 	:= SuperGetMV("MV_LOCALIZ") == "S"
Local lRevProd  := SuperGetMv("MV_REVPROD",.F.,.F.)
Local oModel    := FwModelActivate()
Local oModelSF2 := oModel:GetModel("SF2_MASTER")
Local aArea     := {}
Local aAreaB6   := {}
Local aAreaD2   := {}
Local aAreaNNR  := {}

    If cModelID == "SD2_DETAIL"
        cCodProd    := oSubModel:GetValue("D2_COD", nLine)
        cTipoDoc    := oModelSF2:GetValue("F2_TIPODOC")
        self:oTipoDoc:SetTipoDoc(cTipoDoc)

        aArea := GetArea()
        SF4->(MsSeek(cFilSF4+oSubModel:GetValue("D2_TES", nLine)))

        //Verificaci�n de permisos de almacen.
        lRet := MaAvalPerm(3,{oSubModel:GetValue("D2_LOCAL", nLine), cCodProd}) 

        If lRet .and. !MaTesSel(oSubModel:GetValue("D2_TES", nLine)).AND. oSubModel:GetValue("D2_QUANT", nLine) <= 0
            oModel:SetErrorMessage(cModelID, 'D2_QUANT', cModelID, 'D2_QUANT', 'QuantZero', STR0001, '', '') //"�Cantidad no v�lida! Verifique el campo Cant. en cero (F4_QTDZERO) en el archivo de TES."
            lRet := .F.
        EndIf

        If lRet .and. lLocaliz .and. oSubModel:GetValue("D2_QUANT", nLine) > 0
            cAliasVld := Alias()
			DbSelectArea("SB1")
			DbSetOrder(1)
			MsSeek( cFilSB1 + cCodProd )

			lVerLoca := self:oTipoDoc:ValidVerLoca(cPaisLoc,oSubModel:GetValue("D2_SERVIC", nLine) )

            If ( RetFldProd(SB1->B1_COD,"B1_LOCALIZ") == "S" ) .And. lVerLoca
                If IIF(oSubModel:HasField("D2_PEDIDO"), Empty(oSubModel:GetValue("D2_PEDIDO", nLine)) ,.T. ) .and. Empty(oSubModel:GetValue("D2_LOCALIZ", nLine))
                    lVldLocal := .T.
                EndIf
                If lVldLocal
                    If SF4->F4_ESTOQUE == "S"
                        oModel:SetErrorMessage(cModelID, 'D2_LOCALIZ', cModelID, 'D2_LOCALIZ', 'ITLOCALIZ', STR0002, '', '') //"Infome la ubicaci�n para productos que utilizan el control de localizaci�n."
                        lRet := .F.
                    EndIf
                EndIf
            EndIf

            DbSelectArea(cAliasVld)
        EndIf

        If lRet .and. ( SF4->F4_QTDZERO == "1" )
            lQtdeZero := .T.
        EndIf
        //Validaciones de lotes.
        If lRet .and. self:oTipoDoc:ValidStockReturns() .and. (Rastro(cCodProd, "S")) .and. Empty(oSubModel:GetValue("D2_NUMLOTE", nLine)) .and. !lQtdeZero
            If SF4->F4_ESTOQUE=="S"
                oModel:SetErrorMessage(cModelID, 'D2_NUMLOTE', cModelID, 'D2_NUMLOTE', 'ITNUMLOTE', STR0003, '', '') //Complete el sublote.
				lRet := .F.
			Endif
        EndIf

        If lRet .and. self:oTipoDoc:ValidStockReturns() .and. (Rastro(cCodProd, "L")) .and. Empty(oSubModel:GetValue("D2_LOTECTL", nLine)) .and. !lQtdeZero
            If SF4->F4_ESTOQUE=="S"
                oModel:SetErrorMessage(cModelID, 'D2_LOTECTL', cModelID, 'D2_LOTECTL', 'ITLOTECTL', STR0004, '', '') //Complete el lote.
				lRet := .F.
			Endif
        EndIf

        If lRet .and. Empty(oSubModel:GetValue("D2_REMITO", nLine))
            If SF4->F4_PODER3 == "D" .AND. Empty(oSubModel:GetValue("D2_IDENTB6", nLine))
                oModel:SetErrorMessage(cModelID, 'D2_IDENTB6', cModelID, 'D2_IDENTB6', 'ITIDENTB6', STR0005, '', '') //Falla en la cumplimentaci�n del campo 'XX_IDENTB6'.
                lRet := .F.
            Endif
        EndIf

        If lRet .and. self:oTipoDoc:Valid3rdPartyShipment(oModelSF2:GetValue("F2_TIPOREM"))
            If !(SF4->F4_PODER3 == "R")
                oModel:SetErrorMessage(cModelID, 'D2_TES', cModelID, 'D2_TES', 'ITTES', STR0006+" ("+oSubModel:GetValue("D2_TES", nLine)+")"+Chr(13)+Chr(10)+STR0007, '', '') //�TES no v�lido para este documento! # Env�os de consignaci�n deben usar TES de 'Env�o a terceros'.
                lRet := .F.
            EndIf
        EndIf

        If lRet .and. self:oTipoDoc:ValidLiquidProdStock() .and. oModelSF2:GetValue("F2_LIQPROD") == "1"
            If !(SF4->F4_ESTOQUE == "N")
                oModel:SetErrorMessage(cModelID, 'D2_TES', cModelID, 'D2_TES', 'ITTES', STR0006+" ("+oSubModel:GetValue("D2_TES", nLine)+")"+Chr(13)+Chr(10)+STR0008, '', '') //�TES no v�lido para este documento! # Cuando se trate de un proceso de consignaci�n "Neto producto", la TES no puede actualizar stock.
                lRet := .F.
            EndIf
        EndIf

        //Se verifica si el producto est� en revisi�n vigente y envia pata almacen de CQ para ser validado por ingenieria
        If lRet .and. lRevProd
            cRvSB5 := Posicione("SB5",1,xFilial("SB5")+cCodProd,"B5_REVPROD")
			cBlqSG5:= Posicione("SG5",1,xFilial("SG5")+cCodProd+oSubModel:GetValue("D2_REVISAO", nLine),"G5_MSBLQL")
			cStatus:= Posicione("SG5",1,xFilial("SG5")+cCodProd+oSubModel:GetValue("D2_REVISAO", nLine),"G5_STATUS")
			
            If Empty(cRvSB5)
					oModel:SetErrorMessage(cModelID, 'D2_COD', cModelID, 'D2_COD', 'ITREVPROD', STR0009, '', '') //No se encontr� registro del producto seleccionado en la rutina de complemento de producto.
					lRet:= .F.
            ElseIf cRvSB5 == "1"
				If Empty(cBlqSG5)
                    oModel:SetErrorMessage(cModelID, 'D2_REVISAO', cModelID, 'D2_REVISAO', 'ITREVISAO', STR0010, '', '') //El producto seleccionado no tiene revisi�n en uso. Verifique el registro de revisiones.
					lRet:= .F.
				ElseIf cBlqSG5 == "1"
					Help(" ",1,"REGBLOQ")
					lRet:= .F.
				ElseIf cStatus == "2" .and. oSubModel:GetValue("D2_TES", nLine) > "500"
                    oModel:SetErrorMessage(cModelID, 'D2_REVISAO', cModelID, 'D2_REVISAO', 'ITREVISAO', STR0011, '', '') //Esta revisi�n no se puede alimentar pues est� inactiva.
					lRet:= .F.
				EndIf
			EndIf
        EndIf

        //Realiza validaci�n de saldo en stock cuando no existe pedido de ventas.
        If lRet .and. SF4->F4_ESTOQUE == "S" .and. self:oTipoDoc:ValidBalanceStock(cPaisLoc, oSubModel:GetValue("D2_REMITO", nLine), oSubModel:GetValue("D2_TPDCENV", nLine))
            If !self:SaldoOk(cCodProd, oSubModel:GetValue("D2_LOCAL", nLine), oSubModel:GetValue("D2_QUANT", nLine), oSubModel:GetValue("D2_LOTECTL", nLine), oSubModel:GetValue("D2_NUMLOTE", nLine), oSubModel:GetValue("D2_LOCALIZ", nLine), oSubModel:GetValue("D2_NUMSERI", nLine),  !Empty(oSubModel:GetValue("D2_PEDIDO", nLine)), oSubModel:GetValue("D2_PEDIDO", nLine), oSubModel:GetValue("D2_ITEMPV", nLine), oSubModel:GetValue("D2_SEQUEN", nLine), , .F.)
                lRet :=	.F.
            EndIf
        EndIf

        //Verifica si el producto est� bloqueado.
        If lRet .and. SF4->F4_ESTOQUE == "S" .and. (BlqInvent(cCodProd, oSubModel:GetValue("D2_LOCAL", nLine)) .or. AvalBlqLoc(cCodProd, oSubModel:GetValue("D2_LOCAL", nLine), oSubModel:GetValue("D2_TES", nLine)))
            oModel:SetErrorMessage(cModelID, 'D2_LOCAL', cModelID, 'D2_LOCAL', 'ITLOCAL', STR0012+" ("+cCodProd+STR0013+oSubModel:GetValue("D2_LOCAL", nLine)+")", '', '') //Producto inventariado #  Dep�s.: 
			lRet:= .F.
        EndIf

        //Verifica cantidad disponible en SB6.
        If lRet .and. SF4->F4_PODER3 == 'D'
            nQuantB6  := self:SumIdentB6(oSubModel, nLine)
            aAreaB6 := GetArea()
            DBSelectArea("SB6")
			SB6->(DBSetOrder(3))
            If SB6->(MSSeek(xFilial("SB6")+oSubModel:GetValue("D2_IDENTB6", nLine)+cCodProd+"R", .F.))
                If nQuantB6 > SB6->B6_SALDO
					oModel:SetErrorMessage(cModelID, 'D2_IDENTB6', cModelID, 'D2_IDENTB6', 'ITIDENTB6', STR0014 +" ("+AllTrim(Str(nQuantB6))+"/"+AllTrim(Str(SB6->B6_SALDO))+")", '', '') //Cantidad superior al saldo disponible para Devoluci�n
					lRet := .F.
				EndIf
            EndIf
            RestArea(aAreaB6)
        EndIf

        //Validaci�n de costo FIFO On-Line|
		If lRet .And. SF4->F4_ESTOQUE == "S" .And. IsFifoOnLine()
			If SaldoSBD("SD2", cCodProd, oSubModel:GetValue("D2_LOCAL", nLine), dDataBase, .F.)[1] < oSubModel:GetValue("D2_QUANT", nLine)
				Help(" ",1,"DIVFIFO2")
				lRet := .F.
			EndIf
		EndIf

        //Validaci�n de local
        If lRet .And. !Empty(oSubModel:GetValue("D2_LOCAL", nLine))
            aAreaNNR := GetArea()
            NNR->(DBSelectArea("NNR"))
            NNR->(dbSetOrder(1))
            If !NNR->(MSSeek(xFilial("NNR")+oSubModel:GetValue("D2_LOCAL", nLine)))
                Help(" ",1,"A430LOCAL")
                lRet:= .F.
            EndIf
            RestArea(aAreaNNR)
        EndIf

        //Validaci�n de la cantidad de devoluci�n.
        If lRet .and. self:oTipoDoc:ValidReturns() .and. !Empty(oSubModel:GetValue("D2_NFORI", nLine))
            aAreaD2 := GetArea()
            DBSelectArea("SD1")
		    SD1->(DBSetOrder(1))
            If SD1->(MsSeek(xFilial("SD1") + oSubModel:GetValue("D2_NFORI", nLine) + oSubModel:GetValue("D2_SERIORI", nLine) + oModelSF2:GetValue("F2_CLIENTE") + oModelSF2:GetValue("F2_LOJA") + cCodProd + oSubModel:GetValue("D2_ITEMORI", nLine)))
                nQuantAux := self:SumDev(oSubModel, nLine, SD1->D1_COD, SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_ITEM)
                If nQuantAux > Iif(!(self:oTipoDoc:ReturnSupplier()), SD1->D1_QTDACLA, SD1->D1_QUANT - SD1->D1_QTDEDEV ) .and. !(SuperGetMv("MV_RMTDEVF",.F.,"N") == "S")
                    oModel:SetErrorMessage(cModelID, 'D2_NFORI', cModelID, 'D2_NFORI', 'ITNFORI', STR0015 + "("+AllTrim(Str(nQuantAux))+"/"+AllTrim(Str(SD1->D1_QTDACLA))+" )", '', '') //'Cantidad no v�lida para devoluci�n. Verifique la cantidad disponible en la Factura Original '
                    lRet := .F.
                EndIf
            EndIf
            RestArea(aAreaD2)
        EndIf

        //Validaci�n para NCP ligada a un Remito de Devoluci�n.
        If lRet .and. self:oTipoDoc:ValidRemReturn(cPaisLoc) .and. !Empty(oSubModel:GetValue("D2_REMITO", nLine))
            aAreaD2 := GetArea()
            DBSelectArea("SD2")
		    SD2->(DBSetOrder(3))
            If SD2->(MsSeek(xFilial("SD2") + oSubModel:GetValue("D2_REMITO", nLine) + oSubModel:GetValue("D2_SERIREM", nLine) + oModelSF2:GetValue("F2_CLIENTE") + oModelSF2:GetValue("F2_LOJA") + cCodProd + oSubModel:GetValue("D2_ITEMREM", nLine)))
                nQuantAux := self:SumDevRem(oSubModel, nLine, SD2->D2_COD, SD2->D2_DOC, SD2->D2_SERIE, SD2->D2_ITEM)
                If lRet .And. nQuantAux > (SD2->D2_QUANT - SD2->D2_QTDEFAT)
                    //Avisa cuando la suda de la cantidad informada sobrepasa la cantidad disponible del remito original.
                    Help(" ",1,"A466NQTDIS")
                    lRet := .F.
                EndIf
            EndIf
            RestArea(aAreaD2)
        EndIf
        RestArea(aArea)
    EndIf

Return lRet

/*/{Protheus.doc} LocxTravaSB2
Metodo responsabe por verificar si existe alg�n bloqueo de los items para la SB2 y SA1.
@type 		Method
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		05/2023
/*/
Method LocxTravaSB2() Class LXOUTEST
Local lRet      := .T.
Local nI        := 0
Local aTrava    := {}
Local cCliFor   := ""
Local cLoja     := ""
Local oModel    := Nil
Local oModelSF2 := Nil
Local oModelSD2 := Nil

    If !InTransact()
        oModel    := FwModelActivate()
        oModelSF2 := oModel:GetModel("SF2_MASTER")
        oModelSD2 := oModel:GetModel("SD2_DETAIL")

        cCliFor    := oModelSF2:GetValue("F2_CLIENTE")
        cLoja      := oModelSF2:GetValue("F2_LOJA")

        For nI := 1 To oModelSD2:Length()
            If !oModelSD2:IsDeleted()
                AADD(aTrava, oModelSD2:GetValue("D2_COD", nI) + oModelSD2:GetValue("D2_LOCAL", nI))
            EndIf
        Next

        lRet := MultLock("SB2", aTrava, 1) .and. MultLock("SA1", {cCliFor+cLoja}, 1)
        If ( !lRet )
            SB2->(MsUnLock())
            SA1->(MsUnLock())
            SA2->(MsUnLock())
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} SumIdentB6
Metodo responsabe por realizar la sumatoria de cantidad en los items para verificar la disponibilidad en SB6
@type 		Method
@param 		oModelSD2	,objeto		,Modelo de dados.
@param 		nLine		,numerico	,N�mero de l�nea validada
@Return     nQuant      ,numerico   ,Retorno de las sumatorias.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		05/2023
/*/
Method SumIdentB6(oModelSD2, nLine) Class LXOUTEST
Local nZ        := 0
Local nQuant    := 0

Default nLine   := 1

    For nZ := 1 To oModelSD2:Length()
        If !oModelSD2:IsDeleted()
           If oModelSD2:GetValue("D2_NFORI", nZ) == oModelSD2:GetValue("D2_NFORI", nLine) .and. ;
                oModelSD2:GetValue("D2_SERIORI", nZ) == oModelSD2:GetValue("D2_SERIORI", nLine) .and. ;
                oModelSD2:GetValue("D2_IDENTB6", nZ) == oModelSD2:GetValue("D2_IDENTB6", nLine)
                nQuant += oModelSD2:GetValue("D2_QUANT", nZ)
           EndIf
        EndIf
    Next

Return nQuant

/*/{Protheus.doc} SumDev
Metodo responsabe por realizar la sumatoria de cantidad en los items para verificar la cantidad disponible en la devoluci�n
@type 		Method
@param 		oModelSD2	,caracter	,Identificador do sub-modelo.
@param 		nLine		,numerico	,N�mero de l�nea validada
@param 		cCodPro     , caracter		, codigo del producto.
@param 		cDocument   , caracter		, numero del documento.
@param 		cSerie      , caracter		, serie del documento.
@param 		cItem       , caracter		, item del documento.
@Return     nQuant      ,numerico   ,Retorno de las sumatorias.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		05/2023
/*/
Method SumDev(oModelSD2, nLine, cCodPro, cDocument, cSerie, cItem) Class LXOUTEST
Local nZ        := 0
Local nQuant    := 0

Default nLine       := 1
Default cCodPro     := ""
Default cDocument   := ""
Default cSerie      := ""
Default cItem       := ""


    For nZ := 1 To oModelSD2:Length()
        If !oModelSD2:IsDeleted()
           If oModelSD2:GetValue("D2_COD", nZ) == cCodPro .and. ;
                oModelSD2:GetValue("D2_NFORI", nZ) == cDocument .and. ;
                oModelSD2:GetValue("D2_SERIORI", nZ) == cSerie .and. ;
                oModelSD2:GetValue("D2_ITEMORI", nZ) == cItem
                nQuant += oModelSD2:GetValue("D2_QUANT", nZ)
           EndIf
        EndIf
    Next

Return nQuant

/*/{Protheus.doc} SumDev
Metodo responsabe por realizar la sumatoria de cantidad en los items para verificar la cantidad disponible en la devoluci�n con Remito de Devoluci�n
@type 		Method
@param 		oModelSD2	,caracter	,Identificador do sub-modelo.
@param 		nLine		,numerico	,N�mero de l�nea validada
@param 		cCodPro     , caracter		, codigo del producto.
@param 		cDocument   , caracter		, numero del documento.
@param 		cSerie      , caracter		, serie del documento.
@param 		cItem       , caracter		, item del documento.
@Return     nQuant      ,numerico   ,Retorno de las sumatorias.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		05/2023
/*/
Method SumDevRem(oModelSD2, nLine, cCodPro, cDocument, cSerie, cItem) Class LXOUTEST
Local nZ        := 0
Local nQuant    := 0

Default nLine       := 1
Default cCodPro     := ""
Default cDocument   := ""
Default cSerie      := ""
Default cItem       := ""

    For nZ := 1 To oModelSD2:Length()
        If !oModelSD2:IsDeleted()
           If oModelSD2:GetValue("D2_COD", nZ) == cCodPro .and. ;
                oModelSD2:GetValue("D2_REMITO", nZ) == cDocument .and. ;
                oModelSD2:GetValue("D2_SERIREM", nZ) == cSerie .and. ;
                oModelSD2:GetValue("D2_ITEMREM", nZ) == cItem
                nQuant += oModelSD2:GetValue("D2_QUANT", nZ)
           EndIf
        EndIf
    Next

Return nQuant

/*/{Protheus.doc} SaldoOk
Metodo responsabe por realizar las validaciones de saldo del producto.
@type 		Method
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		05/2023
/*/
Method SaldoOk(cCod,cLocal,nQuant,cLoteCtl,cNumLote,cLocaliz,cNumSer,lBaixaEmp, cPedido, cItemPV, cSequen, lSaldo, lTesPeRemi) Class LXOUTEST
Local lRet	:=	.T.
Local aArea	:=	GetArea()
Local oModel    := FwModelActivate()

DEFAULT cCod        := ""
DEFAULT cLocal      := ""
DEFAULT nQuant      := 0
DEFAULT cLoteCtl    := ""
DEFAULT cNumLote    := ""
DEFAULT cLocaliz    := ""
DEFAULT cNumSer     := ""
DEFAULT lBaixaEmp   := .F.
DEFAULT cPedido     := ""
DEFAULT cItemPV     := ""
DEFAULT cSequen     := ""
DEFAULT lSaldo      := Nil
DEFAULT lTesPeRemi  := .F.

    //Verifca cantidades en reserva en la SB".
    If !(SuperGetMV("MV_ESTNEG") == "S") .AND. (!SB2->(MsSeek(xFilial("SB2")+cCod+cLocal)) .OR. SaldoSB2(,.F.) <  (nQuant  - Iif(lBaixaEmp,SB2->B2_RESERVA,0)))
        lRet	:=	.F.
    Endif

    If lBaixaEmp == .T.
        lSaldo  := .T.
    EndIf

    //Validaci�n cuando el producto usa rastreo.
    If lRet .AND. Rastro(cCod) .AND. SaldoLote(cCod,cLocal,cLoteCtl,cNumLote,lBaixaEmp,,,,,lSaldo) <  nQuant
        lRet	:=	.F.
    Endif

    If lRet .and. !Empty(cPedido+cItemPV+cSequen)
        dbSelectArea("SDC")
        dbSetOrder(1)
        SDC->(MsSeek(xFilial("SDC")+cCod+cLocal+"SC6"+cPedido+cItemPV+cSequen))
        If SDC->(Found()) .And. QtdComp(nQuant) == QtdComp(1)
            cLocaliz := SDC->DC_LOCALIZ
            cNumSer  := SDC->DC_NUMSERI
        EndIf
    EndIf

    //Validaci�n cuando el producto usa localizaci�n.
    If lRet	.AND. Localiza(cCod) .AND. SaldoSBF(cLocal,cLocaliz,cCod,cNumSer,cLoteCtl,cNumLote,Iif(lTesPeRemi,.F.,lBaixaEmp)) <  nQuant
        lRet := .F.
    Endif

    
    If !lRet
        oModel:SetErrorMessage('SD2_DETAIL', 'D2_TES', 'SD2_DETAIL', 'D2_TES', 'ITTES', STR0016, '', '') //'No se permite dejar el saldo en stock negativo'
    EndIf
    RestArea(aArea)

Return  lRet

/*/{Protheus.doc} LocXAvStok
Metodo responsabe por realizar las validaciones de saldo de los productos al momento de realizar las validaciones del grid.
@type 		Method
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		05/2023
/*/
Method LocXAvStok() Class LXOUTEST
Local lRet      := .T.
Local nI        := 0
Local aArea     := GetArea()
Local oModel    := Nil
Local oModelSF2 := Nil
Local oModelSD2 := Nil
Local lMVEstNeg := SuperGetMV("MV_ESTNEG") == "N"
Local cCodProd  := ""
Local cFilSF4	:= xFilial("SF4")

    oModel    := FwModelActivate()
    oModelSF2 := oModel:GetModel("SF2_MASTER")
    oModelSD2 := oModel:GetModel("SD2_DETAIL")

    For nI := 1 To oModelSD2:Length()
        If lRet .and. !oModelSD2:IsDeleted()
            cCodProd := oModelSD2:GetValue("D2_COD", nI)
            If lMVEstNeg .Or. Rastro(cCodProd) .Or. Localiza(cCodProd)
                SF4->(MsSeek(cFilSF4 + oModelSD2:GetValue("D2_TES", nI)))
                If SF4->F4_ESTOQUE == "S" .and. self:oTipoDoc:ValidBalanceStock(cPaisLoc, oModelSD2:GetValue("D2_REMITO", nI), oModelSD2:GetValue("D2_TPDCENV", nI))
                    lRet := self:SaldoOk(cCodProd, oModelSD2:GetValue("D2_LOCAL", nI), oModelSD2:GetValue("D2_QUANT", nI), oModelSD2:GetValue("D2_LOTECTL", nI), oModelSD2:GetValue("D2_NUMLOTE", nI), oModelSD2:GetValue("D2_LOCALIZ", nI), oModelSD2:GetValue("D2_NUMSERI", nI),  !Empty(oModelSD2:GetValue("D2_PEDIDO", nI)), oModelSD2:GetValue("D2_PEDIDO", nI), oModelSD2:GetValue("D2_ITEMPV", nI), oModelSD2:GetValue("D2_SEQUEN", nI), , .F.)
                EndIf
            EndIf
        EndIf
    Next

    RestArea(aArea)

Return lRet
