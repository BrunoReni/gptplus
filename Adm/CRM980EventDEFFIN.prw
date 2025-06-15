#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "FWEVENTVIEWCONSTS.CH"   
#INCLUDE 'CRM980EVENTDEFFIN.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventDEFFIN
Classe respons�vel pelo evento das regras de neg�cio da 
localiza��o Padr�o Financeiro.
 
@type 		Classe
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Class CRM980EventDEFFIN From FwModelEvent 
	
	Method New() CONSTRUCTOR
	
	//Bloco com regras de neg�cio depois transa��o do modelo de dados.
	Method AfterTTS()	
	//Executa a p�s valida��o dos campos.
	Method FieldPosVld()	
	//Bloco com regras de neg�cio na p�s valida��o do modelo de dados.
	Method ModelPosVld()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo respons�vel pela constru��o da classe.

@type 		M�todo
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method New() Class CRM980EventDEFFIN
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AfterTTS
M�todo respons�vel por executar regras de neg�cio do Financeiro 
depois da transa��o do modelo de dados.


@type 		M�todo

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method AfterTTS(oModel,cID) Class CRM980EventDEFFIN
	
	Local aArea 		:= GetArea()
	Local aAreaSA1 		:= SA1->(GetArea())
	Local nOperation	:= oModel:GetOperation()
	Local oObj 		 	:= FWSX1Util():New()
	Local aPergunte	 	:= {}

	//--------------------
	// Integra��o Reserve
	//--------------------
	If SuperGetMV("MV_RESEXP",.F.,"0") <> "0" .And.;			//Verifica a forma de exportacao definida
		SubStr(SuperGetMV("MV_RESCAD",.F.,"111"),2,1) == "1"	//Verifica se a exportacao do cliente esta habilitada
		FINA659(nOperation)
	EndIf

	If nOperation == 3 .AND. !(IsBlind()) .AND. !Empty(SuperGetMV('MV_MINGTOK', .F., ''))
        //Verificar se o novo grupo de perguntas existe    
        oObj:AddGroup("CRMA980")
        oObj:SearchGroup()
        If Len(aPergunte := oObj:GetGroup("CRMA980")[2]) > 0 
			SaveInter()
			Pergunte("CRMA980",.F.)
            If Type("MV_PAR01") == "N" .AND. MV_PAR01 == 1 // F12 - CRMA980 -  MV_PAR01 - Cadastra Usuario Portal?
				FT220CadCli(oModel:GetValue('SA1MASTER', 'A1_COD') ,oModel:GetValue('SA1MASTER', 'A1_LOJA') , oModel:GetValue('SA1MASTER', 'A1_GRPVEN') )
            EndIf
			RestInter()
        Endif
    Endif
	
	RestArea(aAreaSA1)
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} FieldPosVld
Executa a p�s valida��o dos campos.

@author Sivaldo Oliveira
@since 30/10/2020
@version 12

@param oModel ,object, Modelo de dados de clientes
@return N�o possui retorno
/*/
Method FieldPosVld(oModel) Class CRM980EventDEFFIN
	Local lRet As Logical
	
	//inicializa vari�veis.
	lRet := .T.
	
	If oModel != Nil .And. AllTrim(oModel:CID) == "AI0CHILD" .And. FindFunction("FinRecPix")
		lRet := FinRecPix(oModel, .T.)
	EndIf	
Return lRet

/*/{Protheus.doc} ModelPosVld
M�todo respons�vel por executar regras de neg�cio do Financeiro 
na p�s valida��o do modelo de dados.

@type 		M�todo

@param 		oModel, objeto	, Modelo de dados de Clientes.
@param 		cID   , caracter, Identificador do sub-modelo.

@author 	alison.kaique
@version	12.1.33 / Superior
@since		23/04/2021 
/*/
Method ModelPosVld(oModel, cID) Class CRM980EventDEFFIN
	Local lRet       As Logical
	Local oMdlAI0    As Object
	Local nOperation As Numeric

	lRet       := .T.
	nOperation := oModel:GetOperation()

	// valida��o de opera��o
	If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE)
		// valida��o de e-mail para Boleto Registrado
		If (FindFunction('F713VldEmB') .AND. ValType(oMdlAI0 := oModel:GetModel('AI0CHILD')) == 'O')
			lRet := F713VldEmB(oMdlAI0)
		EndIf
	EndIf
Return lRet
