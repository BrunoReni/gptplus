#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE 'FINA887.CH'

/*/{Protheus.doc} F887FINPER
Clase responsable por el evento de reglas de negocio de 
localización de Perú

@type 		Class
@author 	raul.medina
@version	12.1.27 / Superior
@since		19/05/2021
/*/
Class F887FINPER From FwModelEvent 

	Method New() CONSTRUCTOR
	
	Method VldActivate()

	Method Destroy()
	
	Method BeforeTTS()
	
	Method InTTS()

	Method GridLinePosVld()

	Method FieldPosVld()

	Method FINUPDSE()
	
EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		19/05/2021 
/*/
Method New() Class F887FINPER
	
Return Nil	

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		19/05/2021 
/*/
Method VldActivate(oModel) Class F887FINPER
Local nOperation	:= oModel:GetOperation()
Local lRet		:= .T.

	self:GetEvent("F887FIN"):cDocCred := Substr(MVRECANT,1,3) // Sempre sera tipo RA no Perú
	
	self:GetEvent("F887FIN"):lValidITF := .T.

Return lRet
/*/{Protheus.doc} GridLinePosVld
Metodo responsabe por ejecutar reglas de negocio genericas para validación de línea.

@type 		Method

@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@param 		nLine		,numerico	,Número de línea validada

@author 	Jose.gonzalez	
@version	12.2.27 / Superior
@since		13/03/2023 
/*/
Method GridLinePosVld(oSubModel, cModelID, nLine) Class F887FINPER
Local lRet		As Logical
Local cError	As Character
Local cDocs		:= SubStr(MVRECANT,1,3)
Local nOperation := oSubModel:GetOperation() As Numeric

lRet	  	:= .T.  
cError		:= ""

IF cModelID == 'SE1_DETAIL' .AND. (nOperation != MODEL_OPERATION_UPDATE)
	If X3Usado("ED_OPERADT")
		IF oSubModel:getvalue('E1_TIPO',nLine) $ cDocs .AND. GetAdvFVal("SED","ED_OPERADT",xFilial("SED")+oSubModel:getvalue('E1_NATUREZ'),1,"") == "1"	
			Help(" ",1,STR0119, NIL,STR0119, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0120}) // STR0119 "No es posible seleccionar registros que posean modalidades divergentes sobre el proceso de anticipo" STR0120 "Verifique en el archivo de modalidad el campo de operación de anticipo"
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
Method FieldPosVld(oSubModel, cModelID) Class F887FINPER
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

/*/{Protheus.doc} Destroy
Metodo responsable de destruir el objeto

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		19/05/2021 
/*/
Method Destroy() Class F887FINPER

Return Nil

/*/{Protheus.doc} BeforeTTS
Metodo responsabe por ejecutar reglas de negocio genericas antes de la transacción
del modelo de datos.

@type 		Method

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	raul.medina	
@version	12.1.27 / Superior
@since		19/05/2021 
/*/
Method BeforeTTS(oModel, cModelId) Class F887FINPER
Local nOperation	:= oModel:GetOperation()


Return Nil

/*/{Protheus.doc} InTTS
Metodo responsable por ejecutar reglas de negocio genericas 
dentro de la transacción del modelo de datos.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@param 		cModelId ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		19/05/2021 
/*/
Method InTTS(oModel, cModelId) Class F887FINPER
Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT
		Begin Transaction
			self:FINUPDSE(oModel)
		End Transaction
	EndIf

Return Nil


/*/{Protheus.doc} FINUPDSE
Metodo responsable por realizar las actualizaciones de las tablas SE1, SE5, FK1, Fk5
@type 		Method
@author 	luis.aboytes
@version	12.1.27 / Superior
@since		03/04/2023
/*/
Method FINUPDSE(oModel) Class F887FINPER
Local oModelSE1 	:= oModel:GetModel('SE1_DETAIL')
Local nX			:= 0

	FOR nX := 1 TO oModelSE1:Length()
		//Si la naturaleza del valor es un valor anticipado, ED_OPERADT = 1 genera el valor de tipo "RA" en función del valor anticipado.
		IF X3Usado("ED_OPERADT")
			IF GetAdvFVal("SED","ED_OPERADT",xFilial("SED")+oModelSE1:GetValue("E1_NATUREZ",nX),1,"") == "1"
				FI998NFRA(oModelSE1:GetValue("BAIXAR",nX),nX,oModel)
			ENDIF
		ENDIF
	NEXT
Return Nil
