#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "LXINEST.CH"

/*/{Protheus.doc} LXINEST
Clase responsable por el evento de reglas de negocio de 
localizaci�n padr�n

@type 		Class
@author 	raul.medina
@version	12.1.2210 / Superior
@since		05/2023
/*/
Class LXINEST From FwModelEvent

    //Propiedades que pueden ser alteradas desde los eventos con localizaci�n
    DATA oTipoDoc as object

    Method New() CONSTRUCTOR
    Method Activate()
    Method VldActivate()
    Method ModelPosVld()
    Method GridPosVld()
    Method GridLinePosVld()
    Method SumRem()
    Method SumIdentB6()
    Method ValidPricePC()
    Method ValidTolRem()
    Method ValidTolPC()

EndClass


/*/{Protheus.doc} New
Metodo responsable de la contrucci�n de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.2210 / Superior
@since		05/2023
/*/
Method New() Class LXINEST 


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
Method Activate(oModel, lCopy) Class LXINEST

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
@since		05/2023
/*/
Method VldActivate(oModel, cModelId) Class LXINEST
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
Method ModelPosVld(oModel, cModelId) Class LXINEST
Local lRet      := .T. 

Return lRet

/*/{Protheus.doc} GridPosVld
Metodo responsabe por ejecutar reglas de negocio genericas para validaci�n de grid.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		05/2023
/*/
Method GridPosVld(oSubModel, cModelID) Class LXINEST
Local lRet      := .T.
Local nX        := 0
Local nD1line   := 0
Local oModel    := FwModelActivate()
Local oModelSF1 := oModel:GetModel("SF1_MASTER")

    If cModelID == "SD1_DETAIL"
        If self:oTipoDoc:ValidTolerance()
            nD1line := oSubModel:GetLine()
            For nX := 1 To oSubModel:Length()
                If !oSubModel:IsDeleted() //Validaci�n de l�nea eliminada.
                    If !Empty(oSubModel:GetValue("D1_REMITO", nX)) //Tolerancia en facturas vs remitos
                        lRet := self:ValidTolRem(oSubModel:GetValue("D1_REMITO", nX), oSubModel:GetValue("D1_SERIREM", nX), oModelSF1:GetValue("F1_FORNECE"), oModelSF1:GetValue("F1_LOJA"), oSubModel:GetValue("D1_COD", nX), oSubModel:GetValue("D1_ITEMREM", nX), oSubModel:GetValue("D1_QUANT", nX), oSubModel:GetValue("D1_VUNIT", nX), oSubModel:GetValue("D1_GRADE", nX), oSubModel:GetValue("D1_ITEMGRD", nX), oSubModel:GetValue("D1_PEDIDO", nX), oSubModel:GetValue("D1_ITEMPC", nX))
                    ElseIf !Empty(oSubModel:GetValue("D1_PEDIDO", nX)) //Tolerancia vs pedidos.
                        lRet := self:ValidTolPC(oSubModel:GetValue("D1_COD", nX), oSubModel:GetValue("D1_QUANT", nX), oSubModel:GetValue("D1_VUNIT", nX), oSubModel:GetValue("D1_GRADE", nX), oSubModel:GetValue("D1_ITEMGRD", nX), oSubModel:GetValue("D1_PEDIDO", nX), oSubModel:GetValue("D1_ITEMPC", nX))
                    EndIf
                EndIf
            Next
            oSubModel:GoLine(nD1line)
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
Method GridLinePosVld(oSubModel, cModelID, nLine) Class LXINEST
Local lRet      := .T.
Local lQtdeZero := .F.
Local lRevProd  := SuperGetMv("MV_REVPROD",.F.,.F.)
Local cCodProd  := ""
Local cRvSB5	:= ""
Local cBlqSG5	:= ""
Local cStatus	:= ""
Local cTesRem   := ""
Local cCliFor   := ""
Local cLoja     := ""
Local cFilSF4	:= xFilial("SF4")
Local oModel    := FwModelActivate()
Local oModelSF1 := oModel:GetModel("SF1_MASTER")
Local aArea     := {}
Local aAreaSN1  := {}
Local aAreaB6   := {}
Local nQuantB6  := 0
Local nQuantAux := 0
Local nQuantRem := 0

    If cModelID == "SD1_DETAIL"
        cCodProd    := oSubModel:GetValue("D1_COD", nLine)
        cTipoDoc    := oModelSF1:GetValue("F1_TIPODOC")
        cCliFor     := oModelSF1:GetValue("F1_FORNECE")
        cLoja       := oModelSF1:GetValue("F1_LOJA")
        self:oTipoDoc:SetTipoDoc(cTipoDoc)

        aArea := GetArea()
        SF4->(MsSeek(cFilSF4+oSubModel:GetValue("D1_TES", nLine)))

        //Verificaci�n de permisos de almacen.
        lRet := MaAvalPerm(3,{oSubModel:GetValue("D1_LOCAL", nLine), cCodProd}) 

        If lRet .and. !MaTesSel(oSubModel:GetValue("D1_TES", nLine)).AND. oSubModel:GetValue("D1_QUANT", nLine) <= 0
            oModel:SetErrorMessage(cModelID, 'D1_QUANT', cModelID, 'D1_QUANT', 'QuantZero', STR0001, '', '') //"�Cantidad no v�lida! Verifique el campo Cant. en cero (F4_QTDZERO) en el archivo de TES."
            lRet := .F.
        EndIf

        If lRet .and. ( SF4->F4_QTDZERO == "1" )
            lQtdeZero := .T.
        EndIf

        //Validaciones de lotes.
        If lRet .and. self:oTipoDoc:ValidStockReturns() .and. (Rastro(cCodProd, "S")) .and. Empty(oSubModel:GetValue("D1_NUMLOTE", nLine)) .and. !lQtdeZero
            If SF4->F4_ESTOQUE=="S"
                oModel:SetErrorMessage(cModelID, 'D1_NUMLOTE', cModelID, 'D1_NUMLOTE', 'ITNUMLOTE', STR0002, '', '') //Complete el sublote.
				lRet := .F.
			Endif
        EndIf

        If lRet .and. self:oTipoDoc:ValidStockReturns() .and. (Rastro(cCodProd, "L")) .and. Empty(oSubModel:GetValue("D1_LOTECTL", nLine)) .and. !lQtdeZero
            If SF4->F4_ESTOQUE=="S"
                oModel:SetErrorMessage(cModelID, 'D1_LOTECTL', cModelID, 'D1_LOTECTL', 'ITLOTECTL', STR0003, '', '') //Complete el lote.
				lRet := .F.
			Endif
        EndIf

        If lRet .and. Empty(oSubModel:GetValue("D1_REMITO", nLine))
            If SF4->F4_PODER3 == "D" .AND. Empty(oSubModel:GetValue("D1_IDENTB6", nLine))
                oModel:SetErrorMessage(cModelID, 'D1_IDENTB6', cModelID, 'D1_IDENTB6', 'ITIDENTB6', STR0004, '', '') //Falla en la cumplimentaci�n del campo 'XX_IDENTB6'.
                lRet := .F.
            Endif
        EndIf

        //Se verifica si el producto est� en revisi�n vigente y envia pata almacen de CQ para ser validado por ingenieria
        If lRet .and. lRevProd
            cRvSB5 := Posicione("SB5",1,xFilial("SB5")+cCodProd,"B5_REVPROD")
			cBlqSG5:= Posicione("SG5",1,xFilial("SG5")+cCodProd+oSubModel:GetValue("D1_REVISAO", nLine),"G5_MSBLQL")
			cStatus:= Posicione("SG5",1,xFilial("SG5")+cCodProd+oSubModel:GetValue("D1_REVISAO", nLine),"G5_STATUS")
			
            If Empty(cRvSB5)
					oModel:SetErrorMessage(cModelID, 'D1_COD', cModelID, 'D1_COD', 'ITREVPROD', STR0005, '', '') //No se encontr� registro del producto seleccionado en la rutina de complemento de producto.
					lRet:= .F.
            ElseIf cRvSB5 == "1"
				If Empty(cBlqSG5)
                    oModel:SetErrorMessage(cModelID, 'D2_REVISAO', cModelID, 'D2_REVISAO', 'ITREVISAO', STR0006, '', '') //El producto seleccionado no tiene revisi�n en uso. Verifique el registro de revisiones.
					lRet:= .F.
				ElseIf cBlqSG5 == "1"
					Help(" ",1,"REGBLOQ")
					lRet:= .F.
				ElseIf cStatus == "2" .and. oSubModel:GetValue("D1_TES", nLine) < "500"
                    oModel:SetErrorMessage(cModelID, 'D1_REVISAO', cModelID, 'D1_REVISAO', 'ITREVISAO', STR0007, '', '') //Esta revisi�n no se puede alimentar pues est� inactiva.
					lRet:= .F.
				EndIf
			EndIf
        EndIf

        //Para retorno simbolico es obligatorio  
        If lRet .and. self:oTipoDoc:ValidSymbolicReturn(oModelSF1:GetValue("F1_TIPO")) .and. Empty(oSubModel:GetValue("D1_IDENTB6", nLine)) 
            oModel:SetErrorMessage(cModelID, 'D1_IDENTB6', cModelID, 'D1_IDENTB6', 'ITIDENTB6', STR0010, '', '')
            lRet:= .F.
        EndIf

        //Verifica si el producto est� bloqueado.
        If lRet .and. SF4->F4_ESTOQUE == "S" .and. (BlqInvent(cCodProd, oSubModel:GetValue("D1_LOCAL", nLine)) .or. AvalBlqLoc(cCodProd, oSubModel:GetValue("D1_LOCAL", nLine), oSubModel:GetValue("D1_TES", nLine)))
            oModel:SetErrorMessage(cModelID, 'D1_LOCAL', cModelID, 'D1_LOCAL', 'ITLOCAL', STR0008+" ("+cCodProd+STR0009+oSubModel:GetValue("D1_LOCAL", nLine)+")", '', '') //Producto inventariado #  Dep�s.: 
			lRet:= .F.
        EndIf

        If lRet .and. self:oTipoDoc:ValidStockRemIn() .and. !Empty(oSubModel:GetValue("D1_REMITO", nLine))
            cTesRem := Posicione('SD1', 1, xFilial("SD1") + oSubModel:GetValue("D1_REMITO", nLine) + oSubModel:GetValue("D1_SERIREM", nLine) + cCliFor + cLoja + cCodProd + oSubModel:GetValue("D1_ITEMREM", nLine), "D1_TES")
			 //Valida si la factura de entrada usa TES con estoque = S, la TES del remito vinculado debe ser tambi�n estoque = S
            If SF4->F4_ESTOQUE == "S"
                If Posicione('SF4', 1, cFilSF4 + cTesRem, 'F4_ESTOQUE') =="N"
                    Help(" ",1,"A101FACTES")
                    lRet := .F.
                EndIf
            EndIf
            //Verifica si la factura de entrada usa TES con generaci�n de activo, no permite que la TES del remito viculado tambi�n use activo.
            If lRet .and. SF4->F4_ATUATF == "S"
                aAreaSN1 := SN1->(GetArea())
		        SN1->(DBSETORDER(RETORDEM("SN1","N1_FILIAL+N1_FORNEC+N1_LOJA+N1_NFESPEC+N1_NFISCAL+N1_NSERIE+N1_NFITEM")))
                If !(SN1->(MsSeek(xFilial("SN1") + cCliFor + cLoja + POSICIONE("SD1", 1, xFilial("SD1") + oSubModel:GetValue("D1_REMITO", nLine) + oSubModel:GetValue("D1_SERIREM", nLine) + cCliFor + cLoja + cCodProd + oSubModel:GetValue("D1_ITEMREM", nLine),"D1_ESPECIE") + oSubModel:GetValue("D1_REMITO", nLine) + oSubModel:GetValue("D1_SERIREM", nLine) + oSubModel:GetValue("D1_ITEMREM", nLine))))
                    If Posicione('SF4', 1, cFilSF4 + cTesRem, 'F4_ATUATF') == "S"
                        Help(" ",1,"A101ATFTES")
                        lRet := .F.
                    EndIf
                EndIf
                RestArea(aAreaSN1)
            EndIf
        EndIf

        //Validaci�n de cantidad maxima de devolucion en remitos.
        If lRet .and. self:oTipoDoc:ValidQuantRemIn(oModelSF1:GetValue("F1_TIPO")) .and. !Empty(oSubModel:GetValue("D1_REMITO", nLine))
            nQuantAux := self:SumRem(oSubModel, nLine, cCodProd, oSubModel:GetValue("D1_REMITO", nLine), oSubModel:GetValue("D1_SERIREM", nLine), oSubModel:GetValue("D1_ITEMREM", nLine))
            nQuantRem := Posicione('SD1', 1, xFilial("SD1") + oSubModel:GetValue("D1_REMITO", nLine) + oSubModel:GetValue("D1_SERIREM", nLine) + cCliFor + cLoja + cCodProd + oSubModel:GetValue("D1_ITEMREM", nLine),"D1_QTDACLA")       
            If nQuantRem < nQuantAux 
                oModel:SetErrorMessage(cModelID, 'D1_REMITO', cModelID, 'D1_REMITO', 'ITREMITO', STR0011 + " (" + oSubModel:GetValue("D1_SERIREM", nLine) + "/" + oSubModel:GetValue("D1_REMITO", nLine) + ")" +; //Cantidad clasificada excede la cantidad disponible. Doc.: 
                    CHR(13) + CHR(10) + STR0012 + STR(nQuantRem - (nQuantAux - oSubModel:GetValue("D1_QUANT", nLine))), '', '') //Cantidad m�xima: 
                lRet := .F.
            EndIf
        EndIf

        //Validaci�n de devoluciones con poder de terceros.
        If lRet .and. SF4->F4_PODER3 == 'D'
            nQuantB6  := self:SumIdentB6(oSubModel, nLine)
            aAreaB6 := GetArea()
            DBSelectArea("SB6")
			SB6->(DBSetOrder(3))
            If SB6->(MSSeek(xFilial("SB6")+oSubModel:GetValue("D1_IDENTB6", nLine)+cCodProd+"R", .F.))
                If nQuantB6 > SB6->B6_SALDO
					oModel:SetErrorMessage(cModelID, 'D1_IDENTB6', cModelID, 'D1_IDENTB6', 'ITIDENTB6', STR0013 +" ("+AllTrim(Str(nQuantB6))+"/"+AllTrim(Str(SB6->B6_SALDO))+")", '', '') //Cantidad superior al saldo que debe ser devuelto
					lRet := .F.
				EndIf
            EndIf
            RestArea(aAreaB6)
        EndIf

        //Validaci�n de liga a pedido de compras obligatorio.
        If lRet .and. SF4->F4_PODER3=="N" .and. self:oTipoDoc:ValidTESPcNf(oSubModel:GetValue("D1_PEDIDO", nLine), oSubModel:GetValue("D1_TES", nLine))
            If self:oTipoDoc:NfVsRemPC(oSubModel:GetValue("D1_REMITO", nLine), oSubModel:GetValue("D1_SERIREM", nLine), cCliFor, cLoja, cCodProd, oSubModel:GetValue("D1_ITEMREM", nLine))
                Help(" ",1,"A101NPCNFE")
                lRet := .F.
            EndIf
        EndIf

        //Validaci�n de orden de producci�n
        If lRet .and. !Empty(oSubModel:GetValue("D1_OP", nLine))
            If !ExistCpo("SC2", oSubModel:GetValue("D1_OP", nLine)) .or. !Empty(SC2->C2_DATRF)
                oModel:SetErrorMessage(cModelID, 'D1_OP', cModelID, 'D1_OP', 'ITOP', STR0014 +" ("+AllTrim(oSubModel:GetValue("D1_OP", nLine))+")", '', '') //'OP no v�lida '
                lRet := .F.
            EndIf
        EndIf

        RestArea(aArea)
    EndIf

Return lRet

/*/{Protheus.doc} SumRem
Metodo responsabe por realizar la sumatoria de cantidad en los items para verificar la cantidad disponible en el Remito
@type 		Method
@param 		oModelSD1	,caracter	,Identificador do sub-modelo.
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
Method SumRem(oModelSD1, nLine, cCodPro, cDocument, cSerie, cItem) Class LXINEST
Local nZ        := 0
Local nQuant    := 0

Default nLine       := 1
Default cCodPro     := ""
Default cDocument   := ""
Default cSerie      := ""
Default cItem       := ""

    For nZ := 1 To oModelSD1:Length()
        If !oModelSD1:IsDeleted()
           If oModelSD1:GetValue("D1_COD", nZ) == cCodPro .and. ;
                oModelSD1:GetValue("D1_REMITO", nZ) == cDocument .and. ;
                oModelSD1:GetValue("D1_SERIREM", nZ) == cSerie .and. ;
                oModelSD1:GetValue("D1_ITEMREM", nZ) == cItem
                nQuant += oModelSD1:GetValue("D1_QUANT", nZ)
           EndIf
        EndIf
    Next

Return nQuant

/*/{Protheus.doc} SumIdentB6
Metodo responsabe por realizar la sumatoria de cantidad en los items para verificar la disponibilidad en SB6
@type 		Method
@param 		oModelSD1	,objeto		,Modelo de dados.
@param 		nLine		,numerico	,N�mero de l�nea validada
@Return     nQuant      ,numerico   ,Retorno de las sumatorias.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		05/2023
/*/
Method SumIdentB6(oModelSD1, nLine) Class LXINEST
Local nZ        := 0
Local nQuant    := 0

Default nLine   := 1

    For nZ := 1 To oModelSD1:Length()
        If !oModelSD1:IsDeleted()
           If oModelSD1:GetValue("D1_NFORI", nZ) == oModelSD1:GetValue("D1_NFORI", nLine) .and. ;
                oModelSD1:GetValue("D1_SERIORI", nZ) == oModelSD1:GetValue("D1_SERIORI", nLine) .and. ;
                oModelSD1:GetValue("D1_IDENTB6", nZ) == oModelSD1:GetValue("D1_IDENTB6", nLine)
                nQuant += oModelSD1:GetValue("D1_QUANT", nZ)
           EndIf
        EndIf
    Next

Return nQuant

/*/{Protheus.doc} ValidTolRem
Metodo responsabe de ejecutar las validaciones de tolerancia de facturas versus pedidos/remitos.
@type 		Method
@param 		cRemito, caracter		, numero del remito.
@param 		cSerRem, caracter		, serie del remito.
@param 		cCliFor, caracter		, codigo del proveedor.
@param 		cLoja,  caracter		, tienda del proveedor.
@param 		cCodProd, caracter		, codigo del producto.
@param 		cItemRem, caracter		, item del remito.
@param 		nQuant, numero		    , Cantidad.
@param 		nValUnit, numero		, valor unitario.
@param 		cGrade, caracter		, Grid S/N.
@param 		cItGrade, caracter		, Item del grid.
@param 		cPedido, caracter		, numero de pedido de compra.
@param 		cItemPC, caracter		, item del pedido de compra.
@Return     lRet     ,logico    ,Retorno de las validaciones.	
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		05/2023
/*/
Method ValidTolRem(cRemito, cSerRem, cCliFor, cLoja, cCodProd, cItemRem, nQuant, nValUnit, cGrade, cItGrade, cPedido, cItemPC) Class LXINEST
Local lRet      := .T.
Local aArea     := {}
Local lGeraBlq  := .F.
Local cFilSC7   := xFilial("SC7")

Default cRemito := ""
Default cSerRem := ""
Default cCliFor := ""
Default cLoja   := ""
Default cCodProd:= ""
Default cItemRem:= ""
Default nQuant  := 0
Default nValUnit:= 0
Default cGrade  := ""
Default cItGrade:= ""
Default cPedido := ""
Default cItemPC := ""

    aArea := GetArea()

    DbSelectArea("SD1")
    SD1->(DbSetOrder(1))
    SD1->(MSSeek(xFilial("SD1") + cRemito + cSerRem + cCliFor + cLoja + cCodProd + cItemRem))
    If SD1->(Found())
        //Validacion de tolerancia del cantidad.
        lGeraBlq := MaAvalToler(SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_COD, nQuant, SD1->D1_QUANT, nValUnit, SD1->D1_VUNIT, .F., .T., .F., .F.,.F.)[1]
        If lGeraBlq
            Help(" ", 1, "QTDLIBMAI")
            lRet := .F.
        Endif
        //Validacion de tolerancia del precio.
        If !lGeraBlq .AND. !Empty(nValUnit)
            If !Empty(SD1->D1_VUNIT)
                lGeraBlq := MaAvalToler(SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_COD, nQuant, SD1->D1_QUANT, nValUnit, SD1->D1_VUNIT, .F., .F., .T., .F.,.F.)[1]
            Else
                DbSelectArea("SC7")
                If cGrade == "S"  .And. !Empty(cItGrade) 
                    SC7->(DbSetOrder(4))
                    SC7->(MsSeek(cFilSC7 + cCodProd + cPedido + cItemPC))
                Else
                    SC7->(DbSetOrder(1))
                    SC7->(MsSeek(cFilSC7 + cPedido + cItemPC))
                EndIf
                If SC7->(Found())
                    lGeraBlq := MaAvalToler(SC7->C7_FORNECE, SC7->C7_LOJA, SC7->C7_PRODUTO, nQuant+SC7->C7_QUJE+SC7->C7_QTDACLA, SC7->C7_QUANT, nValUnit, SC7->C7_PRECO, .F., .F., .T., .F.,.T.)[1]
                End
            Endif
            If lGeraBlq
                Help(" ", 1, "PRCLIBMAI")
                lRet := .F.
            Endif
            //Validacion de tolerancia de la fecha.
            If !lgeraBlq
                lGeraBlq := MaAvalToler(SC7->C7_FORNECE, SC7->C7_LOJA, SC7->C7_PRODUTO, nQuant+SC7->C7_QUJE+SC7->C7_QTDACLA, SC7->C7_QUANT, nValUnit, SC7->C7_PRECO, .F., .F., .F., .T.,.T.)[1]
                If lGeraBlq
                    Help(" ", 1, "DATLIBMAI")
                    lRet := .F.
                Endif
            Endif
        Endif
    EndIf

    RestArea(aArea)

Return lRet 

/*/{Protheus.doc} ValidTolPC
Metodo responsabe de ejecutar las validaciones de tolerancia versus pedidos.
@type 		Method
@param 		cCodProd, caracter		, codigo del producto.
@param 		nQuant, numero		    , Cantidad.
@param 		nValUnit, numero		, valor unitario.
@param 		cGrade, caracter		, Grid S/N.
@param 		cItGrade, caracter		, Item del grid.
@param 		cPedido, caracter		, numero de pedido de compra.
@param 		cItemPC, caracter		, item del pedido de compra.
@Return     lRet     ,logico    ,Retorno de las validaciones. 		
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		05/2023
/*/
Method ValidTolPC(cCodProd, nQuant, nValUnit, cGrade, cItGrade, cPedido, cItemPC) Class LXINEST
Local lRet      := .T.
Local aArea     := {}
Local lGeraBlq  := .F.
Local cFilSC7   := xFilial("SC7")

Default cCodProd:= ""
Default nQuant  := 0
Default nValUnit:= 0
Default cGrade  := ""
Default cItGrade:= ""
Default cPedido := ""
Default cItemPC := ""

    aArea := GetArea()

    DbSelectArea("SC7")
    If cGrade == "S"  .And. !Empty(cItGrade) 
        SC7->(DbSetOrder(4))
        SC7->(MsSeek(cFilSC7 + cCodProd + cPedido + cItemPC))
    Else
        SC7->(DbSetOrder(1))
        SC7->(MsSeek(cFilSC7 + cPedido + cItemPC))
    EndIf
    If SC7->(Found())
        //Validacion de tolerancia del cantidad.
        lGeraBlq := MaAvalToler(SC7->C7_FORNECE, SC7->C7_LOJA, SC7->C7_PRODUTO, nQuant+SC7->C7_QUJE+SC7->C7_QTDACLA, SC7->C7_QUANT, nValUnit, SC7->C7_PRECO, .F., .T., .F., .F.,.T.)[1]
        If lGeraBlq
            Help(" ", 1, "QTDLIBMAI")
            lRet := .F.
        Endif
        //Validacion de tolerancia del precio.
        If !lGeraBlq .AND. !Empty(nValUnit)
            lGeraBlq := MaAvalToler(SC7->C7_FORNECE, SC7->C7_LOJA, SC7->C7_PRODUTO, nQuant+SC7->C7_QUJE+SC7->C7_QTDACLA, SC7->C7_QUANT, nValUnit, SC7->C7_PRECO, .F., .F., .T., .F.,.T.)[1]
            If lGeraBlq
                Help(" ", 1, "PRCLIBMAI")
                lRet := .F.
            Endif
        Endif
        //Validacion de tolerancia de la fecha.
        If !lgeraBlq
            lGeraBlq := MaAvalToler(SC7->C7_FORNECE, SC7->C7_LOJA, SC7->C7_PRODUTO, nQuant+SC7->C7_QUJE+SC7->C7_QTDACLA, SC7->C7_QUANT, nValUnit, SC7->C7_PRECO, .F., .F., .F., .T.,.T.)[1]
            If lGeraBlq
                Help(" ", 1, "DATLIBMAI")
                lRet := .F.
            Endif
        Endif
    EndIf

    RestArea(aArea)

Return lRet 
