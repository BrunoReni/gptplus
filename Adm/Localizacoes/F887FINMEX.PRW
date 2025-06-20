#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE 'FINA887.CH'

/*/{Protheus.doc} F887FIN
Clase responsable por el evento de reglas de negocio de 
localizaci�n M�xico

@type 		Class
@author 	raul.medina
@version	12.1.27 / Superior
@since		12/01/2021
/*/
Class F887FINMEX From FwModelEvent 

	DATA cCredInm
	
	Method New() 
	
	Method BeforeTTS() 
	
	Method ModelPosVld()

	Method ModelPreVld()

	Method InTTS() 
	
	Method FINUPDSEL()
	
	Method FINUPDSE()
	
	Method F887GRVIVA()
	
	Method FN887DELMEX()

	Method FINCXCVld()
	
	Method F887CFDIAnu()
	
	Method VldActivate()
	
	Method Destroy()

	Method F887UPDSE5()
	
	Method GridLinePosVld()

	Method FieldPosVld()
	
EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucci�n de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		19/04/2021 
/*/
Method New() Class F887FINMEX
	
Return Nil

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		30/04/2021
/*/
Method VldActivate(oModel) Class F887FINMEX
Local nOperation	:= oModel:GetOperation()
Local lRet			:= .T.
	
	self:GetEvent("F887FIN"):cDocCred := Substr(MVRECANT,1,3) // Sempre sera tipo RA no mexico
	self:GetEvent("F887FIN"):lVlCorre := .T.				  // Activa la correci�n monetaria
	
    If nOperation == MODEL_OPERATION_DELETE
		self:GetEvent("F887FIN"):lChaveSE1 	:= .F.
		self:GetEvent("F887FIN"):lDelRA 	:= .T.
		self:GetEvent("F887FIN"):lDelEAI	:= .T.
		
	EndIf 
	
Return lRet

/*/{Protheus.doc} Destroy
Metodo responsable de destruir el objeto

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		30/04/2021 
/*/
Method Destroy() Class F887FINMEX

Return Nil

/*/{Protheus.doc} BeforeTTS
Metodo responsabe por ejecutar reglas de negocio genericas antes de la transacci�n
del modelo de datos.

@type 		Method

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	raul.medina	
@version	12.2.27 / Superior
@since		19/04/2021 
/*/
Method BeforeTTS(oModel, cModelId) Class F887FINMEX
Local nOperation	:= oModel:GetOperation()

    If nOperation == MODEL_OPERATION_INSERT
		self:FINUPDSEL(oModel)
	EndIf 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
M�todo responsable por ejecutar las valida�ioes de las reglas de negocio
gen�ricas del cadastro antes de la grabaci�n del formulario.
Si retorna falso, no permite grabar.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@param 		cModelID ,caracter	,Identificador do sub-modelo.

@author 	eduardo.manriquez
@version	12.1.27 / Superior
@since		28/11/2022 
/*/
//-------------------------------------------------------------------

Method ModelPosVld(oModel,cModelID) Class F887FINMEX
	Local lValid 		:= .T.
	Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_DELETE 
		lValid:=self:FINCXCVld(oModel)	
	EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPreVld
M�todo responsable por ejecutar las pre valida�ioes de las reglas de negocio
gen�ricas del cadastro antes de la grabaci�n del formulario.
Si retorna falso, no permite grabar.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@param 		cModelID ,caracter	,Identificador do sub-modelo.

@author 	eduardo.manriquez
@version	12.1.27 / Superior
@since		28/11/2022 
/*/
//-------------------------------------------------------------------

Method ModelPreVld(oModel,cModelID) Class F887FINMEX
	Local lValid 		:= .T.
	Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_UPDATE
		lValid:=self:FINCXCVld(oModel)		
	EndIf

Return lValid
/*/{Protheus.doc} GridLinePosVld
Metodo responsabe por ejecutar reglas de negocio genericas para validaci�n de l�nea.

@type 		Method

@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@param 		nLine		,numerico	,N�mero de l�nea validada

@author 	Jose.gonzalez	
@version	12.2.27 / Superior
@since		13/03/2023 
/*/
Method GridLinePosVld(oSubModel, cModelID, nLine) Class F887FINMEX
Local lRet		As Logical
Local cError	As Character
Local cDocs		:= SubStr(MVRECANT,1,3)
Local nOperation := oSubModel:GetOperation() As Numeric

lRet	  	:= .T.  
cError		:= ""

IF cModelID == 'SE1_DETAIL'  .AND. (nOperation != MODEL_OPERATION_UPDATE)
	If X3Usado("ED_OPERADT")
		IF oSubModel:getvalue('E1_TIPO',nLine) $ cDocs .AND. GetAdvFVal("SED","ED_OPERADT",xFilial("SED")+oSubModel:getvalue('E1_NATUREZ'),1,"") == "1"	
			Help(" ",1,STR0119, NIL,STR0119, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0120}) // STR0119 "No es posible seleccionar registros que posean modalidades divergentes sobre el proceso de anticipo" STR0120 "Verifique en el archivo de modalidad el campo de operaci�n de anticipo"
			lRet	:=	.F.
		ENDIF
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} FieldPosVld
Metodo responsabe por ejecutar reglas de negocio del campo.

@type 		Method

@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.

@author 	Jose.gonzalez	
@version	12.2.27 / Superior
@since		13/03/2023 
/*/
Method FieldPosVld(oSubModel, cModelID) Class F887FINMEX
Local lRet		As Logical
Local cError	As Character
Local cNature	As Character

lRet	  	:= .T.  
cError		:= ""

IF cModelID == 'FJT_MASTER'
	If X3Usado("ED_OPERADT")
		cNature := oSubModel:getvalue('FJT_NATURE') 
		If !(Alltrim(cNature)== "") 
			If GetAdvFVal("SED","ED_OPERADT",xFilial("SED")+cNature,1,"") == "1"
				Help(" ",1,"FA087VALNAT")
				lRet	:=	.F.
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} FINCXCVld
Metodo responsable por realizar la validaci�n. Si recibo de cobro genero una cuenta
por cobrar no ser� permitido el borrado o anulaci�n.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes..

@author 	raul.medina
@version	12.1.27 / Superior
@since		19/04/2021 
/*/
Method FINCXCVld(oModel) Class F887FINMEX
	Local lValid 		:= .T.
	Local oModelSEL		:= oModel:GetModel("SEL_DETAIL")
	Local nLine			:= 0
	Local nSelLine		:= 0
	Local aTitPode      := {}
	Local nI            := 0
	Local cCRLF	    := (chr(10)+chr(13))
	Local cMsg      := ""

	
	nSelLine := oModelSEL:GetLine()
	
	For nLine := 1 To oModelSEL:Length()
		oModelSEL:GoLine(nLine)	
		If !(AllTrim(oModelSEL:GetValue("EL_TIPODOC",nLine)) $ "TB|RI|RG|RB|RS|RR")  
			cPrefixoTemp	:= oModelSEL:GetValue("EL_PREFIXO",nLine)
			cNumeroTemp		:= oModelSEL:GetValue("EL_NUMERO",nLine)
			cParcelaTemp	:= oModelSEL:GetValue("EL_PARCELA",nLine)
			cTipoTemp		:= oModelSEL:GetValue("EL_TIPO",nLine)
			cClienteTemp	:= oModelSEL:GetValue("EL_CLIENTE",nLine)
			cLogaTemp		:= oModelSEL:GetValue("EL_LOJA",nLine)
			DbSelectArea("SE1")
			SE1->(DbSetOrder(2))//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			If SE1->(MsSeek(xFilial("SE1")+cClienteTemp+cLogaTemp+cPrefixoTemp+cNumeroTemp+cParcelaTemp+cTipoTemp))
				IF (IIf(Subs(oModelSEL:GetValue("EL_TIPODOC",nLine),1,2)=="RA",.F.,!SE1->E1_SITUACA$"0 ").OR.SE1->E1_SALDO<>SE1->E1_VALOR)
					If SE1->E1_STATUS == "B"
						Aadd(aTitPode, SE1->E1_PREFIXO +" - "+AllTrim(SE1->E1_NUM))
					EndIf
				EndIf
			Endif							
		EndIf
		
	Next nLine
	If len(aTitPode)> 0
		lValid := .F.
		cMsg += STR0083//"No se permite el anulado o borrado del recibo, ya cuenta con las siguientes cuentas por cobrar ya liquidadas: "
		For nI := 1 to Len(aTitPode)
			cMsg += cCRLF +aTitPode[nI]
		Next nI
		Help(NIL, NIL, "BORRADO", NIL, cMsg, 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsg})
	Endif
	oModelSEL:GoLine(nSelLine)
		

Return lValid

/*/{Protheus.doc} InTTS
Metodo responsable por ejecutar reglas de negocio genericas 
dentro de la transacci�n del modelo de datos.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@param 		cModelId ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		12/04/2021 
/*/
Method InTTS(oModel, cModelId) Class F887FINMEX
Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT
		Begin Transaction
			self:FINUPDSE(oModel)
		End Transaction
	EndIf

Return Nil

/*/{Protheus.doc} FINUPDSEL
Metodo responsable por realizar el tratamiento de la tabla SEL

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes..

@author 	raul.medina
@version	12.1.27 / Superior
@since		19/04/2021 
/*/
Method FINUPDSEL(oModel) Class F887FINMEX
Local nOperation	:= oModel:GetOperation()
Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')
Local oModelSE1 	:= oModel:GetModel('SE1_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local oModelGEN		:= oModel:GetModel('GEN_DETAIL')
Local nX			:= 0
Local nY			:= 0
Local nSelLine		:= 0

	nSelLine := oModelSEL:GetLine()
	
	For nX := 1 To oModelSE1:Length()
		If oModelSE1:GetValue("RECNO",nX) <> 0
			SE1->(MsGoto(oModelSE1:GetValue("RECNO",nX)))
			If oModelSEL:SeekLine({{"EL_PREFIXO",oModelSE1:GetValue("E1_PREFIXO",nX)}, {"EL_NUMERO",oModelSE1:GetValue("E1_NUM",nX)},;
									{"EL_PARCELA",oModelSE1:GetValue("E1_PARCELA",nX)},{"EL_TIPO",oModelSE1:GetValue("E1_TIPO",nX)}})
				self:F887GRVIVA(.F., @oModelSEL, oModelSEL:GetLine())
			EndIf
		EndIf
	Next nX

	For nX := 1 To oModelSEL:Length()
		oModelSEL:GoLine(nX)
		If !(oModelSEL:GetValue("EL_TIPODOC",nX) $ 'RA')
			oModelSEL:SetValue("EL_HORA",oModelGEN:GetValue('HOURSAVERECEIPT'))
		ENDIF
	Next nX

	oModelSEL:GoLine(nSelLine)

Return Nil

/*/{Protheus.doc} FINUPDSE
Metodo responsable por realizar las actualizaciones de las tablas SE1, SE5, FK1, Fk5

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes..

@author 	raul.medina
@version	12.1.27 / Superior
@since		20/04/2021 
/*/
Method FINUPDSE(oModel) Class F887FINMEX
Local oModelSEL 	:= oModel:GetModel('SEL_DETAIL')
Local oModelSE1 	:= oModel:GetModel('SE1_DETAIL')
Local lFacoraje		:= IIF(oModelSEL:GetValue("EL_FACTOR")=="1",.T.,.F.)
Local nX			:= 0
Local nPosSEL		:= 0
Local nSelLine		As Numeric

	For nX := 1 To oModelSE1:Length()
		If oModelSE1:GetValue("RECNO",nX) <> 0
			SE1->(MsGoto(oModelSE1:GetValue("RECNO",nX)))

			//Si la naturaleza del valor es un valor anticipado, ED_OPERADT = 1 genera el valor de tipo "RA" en funci�n del valor anticipado.
			IF X3Usado("ED_OPERADT")
				IF GetAdvFVal("SED","ED_OPERADT",xFilial("SED")+oModelSE1:GetValue("E1_NATUREZ",nX),1,"") == "1"
					FI998NFRA(oModelSE1:GetValue("BAIXAR",nX),nX,oModel)
				ENDIF
			ENDIF
			
			nSelLine := 0
			For nPosSEL := 1 To oModelSEL:Length()
				If oModelSEL:GetValue("EL_NUMERO",nPosSEL) == oModelSE1:GetValue("E1_NUM", nX)
					SE5->(DbSetOrder(7)) //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
					If SE5->(DbSeek(xFilial("SE5") + oModelSEL:GetValue("EL_PREFIXO",nPosSEL) + oModelSEL:GetValue("EL_NUMERO",nPosSEL) + oModelSEL:GetValue("EL_PARCELA",nPosSEL) + oModelSEL:GetValue("EL_TIPO",nPosSEL) + oModelSEL:GetValue("EL_CLIORIG",nPosSEL) + oModelSEL:GetValue("EL_LOJORIG",nPosSEL) ))
						self:F887GRVIVA(.T., @oModelSEL, nPosSEL)
						IF lFacoraje
							self:F887UPDSE5(oModel,nPosSEL)
						ENDIF
					EndIf
				EndIf
			Next nPosSEL
			
		EndIf
	Next nX

Return Nil

/*/{Protheus.doc} F887GRVIVA
Metodo responsable de informar los impuestosL

@type 		Method

@param 		lTab	 	,lTab		,Indica si actualiza modelo o tabla.
@param 		oModelSEL	,objeto		,Modelo de dados de tabla SEL.
@param 		nPosLine	,n�merico	,Linea correspondiente a la tabla SEL.

@author 	raul.medina
@version	12.1.27 / Superior
@since		22/04/2021 
/*/
Method F887GRVIVA(lTab, oModelSEL, nPosLine) Class F887FINMEX

Local aArea      := GetArea()
LOCAL aAreaSE1   := SE1->( GetArea() )
LOCAL _ValorBx1  := 0
Local _ValorBx2  := 0
Local _ValorBx3  := 0
Local _ValorBx4  := 0
Local _ValorBx5  := 0
Local _ValorBx6  := 0
Local _PerBx     := 0
Local _PerDesc   := 0
Local _ValorDc1  := 0
Local _ValorDc2  := 0
Local _ValorDc3  := 0
Local _ValorDc4  := 0
Local _ValorDc5  := 0
Local _ValorDc6  := 0

LOCAL _BaseBx1  := 0
Local _BaseBx2  := 0
Local _BaseBx3  := 0
Local _BaseBx4  := 0
Local _BaseBx5  := 0
Local _BaseBx6  := 0
LOCAL _AliqBx1  := 0
Local _AliqBx2  := 0
Local _AliqBx3  := 0
Local _AliqBx4  := 0
Local _AliqBx5  := 0
Local _AliqBx6  := 0

Local aGrvSE   := {} //campos das tabelas SEL e SE5 a serem gravados.
Local nX

dbSelectArea("SE1")
dbSetOrder(1)
dbSeek(xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
If Found()

	// Calcula el percentual de valor baixado
	_PerBx   := (oModelSEL:GetValue("EL_VALOR", nPosLine)   * 100) / SE1->E1_VALOR

	// Calcula el percentual de valor de descuento
	_PerDesc := (oModelSEL:GetValue("EL_DESCONT", nPosLine) * 100) / SE1->E1_VALOR

	If SE1->E1_VALIMP1 > 0
		_ValorBx1 := SE1->E1_VALIMP1 * (_PerBx / 100)
    	_AliqBx1 := SE1->E1_ALQIMP1
		_BaseBx1 := SE1->E1_BASIMP1 * (_PerBx / 100)

	EndIf
	If SE1->E1_VALIMP2 > 0
		_ValorBx2 := SE1->E1_VALIMP2 * (_PerBx / 100)
	  	_AliqBx2 := SE1->E1_ALQIMP2
		_BaseBx2 := SE1->E1_BASIMP2 * (_PerBx / 100)
	EndIf
	If SE1->E1_VALIMP3 > 0
		_ValorBx3 := SE1->E1_VALIMP3 * (_PerBx / 100)
  		_AliqBx3 := SE1->E1_ALQIMP3
		_BaseBx3 := SE1->E1_BASIMP3 * (_PerBx / 100)
	EndIf
	If SE1->E1_VALIMP4 > 0
		_ValorBx4 := SE1->E1_VALIMP4 * (_PerBx / 100)
	  	_AliqBx4 := SE1->E1_ALQIMP4
		_BaseBx4 := SE1->E1_BASIMP4 * (_PerBx / 100)
	EndIf
	If SE1->E1_VALIMP5 > 0
		_ValorBx5 := SE1->E1_VALIMP5 * (_PerBx / 100)
  		_AliqBx5 := SE1->E1_ALQIMP5
		_BaseBx5 := SE1->E1_BASIMP5 * (_PerBx / 100)
	EndIf
	If SE1->E1_VALIMP6 > 0
		_ValorBx6 := SE1->E1_VALIMP6 * (_PerBx / 100)
	  	_AliqBx6 := SE1->E1_ALQIMP6
		_BaseBx6 := SE1->E1_BASIMP6 * (_PerBx / 100)
	EndIf
	If oModelSEL:GetValue("EL_DESCONT", nPosLine) > 0 .and. SE1->E1_VALIMP1 > 0
		_ValorDc1  := SE1->E1_VALIMP1 * (_PerDesc / 100)
	EndIf
	If oModelSEL:GetValue("EL_DESCONT", nPosLine) > 0 .and. SE1->E1_VALIMP2 > 0
		_ValorDc2  := SE1->E1_VALIMP2 * (_PerDesc / 100)
	EndIf
	If oModelSEL:GetValue("EL_DESCONT", nPosLine) > 0 .and. SE1->E1_VALIMP3 > 0
		_ValorDc3  := SE1->E1_VALIMP3 * (_PerDesc / 100)
	EndIf
	If oModelSEL:GetValue("EL_DESCONT", nPosLine) > 0 .and. SE1->E1_VALIMP4 > 0
		_ValorDc4  := SE1->E1_VALIMP4 * (_PerDesc / 100)
	EndIf
	If oModelSEL:GetValue("EL_DESCONT", nPosLine) > 0 .and. SE1->E1_VALIMP5 > 0
		_ValorDc5  := SE1->E1_VALIMP5 * (_PerDesc / 100)
	EndIf
	If oModelSEL:GetValue("EL_DESCONT", nPosLine) > 0 .and. SE1->E1_VALIMP6 > 0
		_ValorDc6  := SE1->E1_VALIMP6 * (_PerDesc / 100)
	EndIf

	If !lTab
		//Campos da tabela SEL
		//             Tab.      Campo        Valor
		Aadd(aGrvSE, {"SEL", "EL_VALIMP1", _ValorBx1})
		Aadd(aGrvSE, {"SEL", "EL_VALIMP2", _ValorBx2})
		Aadd(aGrvSE, {"SEL", "EL_VALIMP3", _ValorBx3})
		Aadd(aGrvSE, {"SEL", "EL_VALIMP4", _ValorBx4})
		Aadd(aGrvSE, {"SEL", "EL_VALIMP5", _ValorBx5})
		Aadd(aGrvSE, {"SEL", "EL_VALIMP6", _ValorBx6})
		Aadd(aGrvSE, {"SEL", "EL_BASIMP1", _BaseBx1})
		Aadd(aGrvSE, {"SEL", "EL_BASIMP2", _BaseBx2})
		Aadd(aGrvSE, {"SEL", "EL_BASIMP3", _BaseBx3})
		Aadd(aGrvSE, {"SEL", "EL_BASIMP4", _BaseBx4})
		Aadd(aGrvSE, {"SEL", "EL_BASIMP5", _BaseBx5})
		Aadd(aGrvSE, {"SEL", "EL_BASIMP6", _BaseBx6})
		Aadd(aGrvSE, {"SEL", "EL_ALQIMP1", _AliqBx1})
		Aadd(aGrvSE, {"SEL", "EL_ALQIMP2", _AliqBx2})
		Aadd(aGrvSE, {"SEL", "EL_ALQIMP3", _AliqBx3})
		Aadd(aGrvSE, {"SEL", "EL_ALQIMP4", _AliqBx4})
		Aadd(aGrvSE, {"SEL", "EL_ALQIMP5", _AliqBx5})
		Aadd(aGrvSE, {"SEL", "EL_ALQIMP6", _AliqBx6})
		Aadd(aGrvSE, {"SEL", "EL_IMPDES1", _ValorDc1})
		Aadd(aGrvSE, {"SEL", "EL_IMPDES2", _ValorDc2})
		Aadd(aGrvSE, {"SEL", "EL_IMPDES3", _ValorDc3})
		Aadd(aGrvSE, {"SEL", "EL_IMPDES4", _ValorDc4})
		Aadd(aGrvSE, {"SEL", "EL_IMPDES5", _ValorDc5})
		Aadd(aGrvSE, {"SEL", "EL_IMPDES6", _ValorDc6})
		
		For nX := 1 To Len(aGrvSE)
			If aScan(oModelSEL:aHeader, {|cpo| AllTrim(cpo[2]) == aGrvSE[nX,2]})
				oModelSEL:loadValue(aGrvSE[nX,2], aGrvSE[nX,3])
			EndIf
		Next nX
	Else

		//Campos da tabela SE5
		//             Tab.      Campo        Valor
		Aadd(aGrvSE, {"SE5", "E5_VALIMP1", _ValorBx1})
		Aadd(aGrvSE, {"SE5", "E5_VALIMP2", _ValorBx2})
		Aadd(aGrvSE, {"SE5", "E5_VALIMP3", _ValorBx3})
		Aadd(aGrvSE, {"SE5", "E5_VALIMP4", _ValorBx4})
		Aadd(aGrvSE, {"SE5", "E5_VALIMP5", _ValorBx5})
		Aadd(aGrvSE, {"SE5", "E5_VALIMP6", _ValorBx6})
		Aadd(aGrvSE, {"SE5", "E5_BASIMP1", _BaseBx1})
		Aadd(aGrvSE, {"SE5", "E5_BASIMP2", _BaseBx2})
		Aadd(aGrvSE, {"SE5", "E5_BASIMP3", _BaseBx3})
		Aadd(aGrvSE, {"SE5", "E5_BASIMP4", _BaseBx4})
		Aadd(aGrvSE, {"SE5", "E5_BASIMP5", _BaseBx5})
		Aadd(aGrvSE, {"SE5", "E5_BASIMP6", _BaseBx6})
		Aadd(aGrvSE, {"SE5", "E5_ALQIMP1", _AliqBx1})
		Aadd(aGrvSE, {"SE5", "E5_ALQIMP2", _AliqBx2})
		Aadd(aGrvSE, {"SE5", "E5_ALQIMP3", _AliqBx3})
		Aadd(aGrvSE, {"SE5", "E5_ALQIMP4", _AliqBx4})
		Aadd(aGrvSE, {"SE5", "E5_ALQIMP5", _AliqBx5})
		Aadd(aGrvSE, {"SE5", "E5_ALQIMP6", _AliqBx6})

		//verifica se o campo existe e grava o valor na tabela
		For nX := 1 to Len(aGrvSE)
			//aGrvSE[nX,1] = Tabela
			//aGrvSE[nX,2] = Campo
			//aGrvSE[nX,3] = Valor a ser atribuido no campo
	
			//verifica se o campo existe.
			If (aGrvSE[nX,1])->(FieldPos(aGrvSE[nX,2]))> 0
				RecLock(aGrvSE[nX,1], .F.)
				//atribui��o de valor no campo, caso o mesmo exista.
				(aGrvSE[nX,1])->&(aGrvSE[nX,2]) := aGrvSE[nX,3]
				MsUnlock()
			Endif
		Next nX
	EndIf

EndIf

RestArea( aAreaSE1)
RestArea( aArea )

RETURN Nil


Method FN887DELMEX() Class F887FINMEX
Local lRet			:= .T.
Local oModel 		:= FWModelActivate()
Local nOperation	:= oModel:GetOperation()
Local oModelSEL 	:= oModel:GetModel('SELDETAIL')
Local cSerie		:= ""
Local cRecibo		:= ""
Local lSELComp		:= .F.
Local cFilAnt		:= ""
Local nRegAnt		:= SM0->(RecNo())
Local nRegSM0 		:= SM0->(RecNo())
Local aChaveCH		:= {}
Local aChaveRet 	:= {}
Local aTitRec		:= {}
Local cFilSEF 		:= ""
Local cFilFRF		:= ""
Local nChaveCH		:= 0
Local cChaveSE1		:= ""
Local aChaveSE1		:= {}
Local oEventFin 	:= self:GetEvent("F887FIN")
Local lCfdi33   	:= .F.//SuperGetMv("MV_CFDI33",.F.,.F.)
Local aAnulados		:= {}
Local aNoAnulados	:= {}


	If nOperation == MODEL_OPERATION_DELETE
		cSerie	:=	FJT->FJT_SERIE
		cRecibo	:=	FJT->FJT_RECIBO
		
		If FJT->FJT_CANCEL <> '1'
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial("SA1")+FJT->FJT_CLIENT+FJT->FJT_LOJA))
			
			If lCfdi33 .and. !self:lBInteg .and. !self:lBDGA
				If !self:F887CFDIAnu(cSerie,cRecibo)
					oModel:SetErrorMessage('', '' , '' , '' , '', '', FJT->FJT_RECIBO + FJT->FJT_SERIE)
				EndIf
			EndIf
		EndIf
	EndIf

Return Nil

Method F887CFDIAnu(cSerie, cNumero) Class F887FINMEX

Local cNomXML	:= "ReciboPago" + Alltrim(cSerie) + Alltrim(cNumero)  + ".xml"
Local aPagos	:= {}
Local aRecibos	:= {{cNomXML, "", "", aPagos}}
Local lRet		:= .F.

Private cDir	:= &(SuperGetmv( "MV_CFDRECP" , .F. , "GetSrvProfString('startpath','')+'\cfd\recPagos\'" ))

lRet := CFDiRecPag(aRecibos, .F.)

Return lRet

/*/{Protheus.doc} F887FINMEX::F887UPDSE5
Metodo encargado de actualizar los campos de la tabla SE5 cuando hay una o varias compensaciones
@type method
@version  1
@author luis.aboytes
@since 12/9/2022
/*/
Method F887UPDSE5(oModel,nPosLine) Class F887FINMEX
Local aAreaAnt	:= GetArea()
Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
Local oModelCOM		:= oModel:GetModel('COM_DETAIL')
Local aAreaSE5	:= SE5->(GetArea())
Local aAreaFK1	:= FK1->(GetArea())
Local aAreaFK2	:= FK2->(GetArea())
Local nX 			:= 0  As Numeric

FK1->(DbSetorder(1))
FK2->(DbSetorder(1))

	FOR nX := 1 to oModelCOM:Length()
		// Actualiza en SE5 serie y numero de recibo
		SE5->(MsGoto(oModelCOM:GetValue('RECNO',nX)))
		RecLock("SE5",.F.)
		SE5->E5_SERCMP := oModelFJT:GetValue('FJT_SERIE')
		SE5->E5_RECCMP := oModelFJT:GetValue('FJT_RECIBO')
		cIdOrig := SE5->E5_IDORIG
		cTabOri := SE5->E5_TABORI
		SE5->(MsUnlock())

		If (cTabOri)->(DbSeek(xFilial(cTabOri)+cIdOrig))
			// Actualiza en nueva tabla de movimientos bancarios (FK1/FK2) serie y numero de recibo
			// Usa E5_TABORI para confirmar la tabla a actualizar (FK1==CxC)
			RecLock(cTabOri,.F.)

			If cTabOri == "FK1"
				FK1->FK1_SERCMP := oModelFJT:GetValue('FJT_SERIE')
				FK1->FK1_RECCMP := oModelFJT:GetValue('FJT_RECIBO')
			EndIf
			(cTabOri)->(MsUnlock())
		EndIf
	NEXT nX

		SE5->(RestArea(aAreaSE5))
		FK1->(RestArea(aAreaFK1))
		FK2->(RestArea(aAreaFK2))
		RestArea(aAreaAnt)
Return Nil
