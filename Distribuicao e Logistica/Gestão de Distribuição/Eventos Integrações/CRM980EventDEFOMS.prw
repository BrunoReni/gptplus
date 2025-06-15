#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"    

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventDEFOMS

Classe respons�vel pelo evento das regras de neg�cio de Gest�o de
Distrui��o.

@type 		Classe
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Class CRM980EventDEFOMS From FwModelEvent 
	
	Method New() CONSTRUCTOR
	
	//---------------------------------------------------------------------
	// Bloco com regras de neg�cio dentro da transa��o do modelo de dados.
	//---------------------------------------------------------------------
	Method InTTS()
	
	//-------------------------------------------------------------------
	// Bloco com regras de neg�cio depois transa��o do modelo de dados.
	//-------------------------------------------------------------------
	Method AfterTTS()
		
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
Method New() Class CRM980EventDEFOMS
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
M�todo respons�vel por executar regras de neg�cio do OMS dentro da
transa��o do modelo de dados.

@type 		M�todo

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method InTTS(oModel,cID) Class CRM980EventDEFOMS
		
	Local nOperation	:= oModel:GetOperation()
	Local cFilialAdm 	:= SuperGetMV("MV_APDLFOP")   // Aparametros de Funcionalidade Advpl
	Local lOperadorL 	:= SuperGetMV("MV_APDLOPE")	  // Aparametros de Funcionalidade Advpl
	Local lFilialCli 	:= cFilialAdm # cFilAnt       // controla filial do cliente
	Local lIntegraDL 	:= IntDL()                    // Aparametros de Funcionalidade Advpl
	
	If nOperation == MODEL_OPERATION_INSERT
		//------------------------------------------------------------
		// Caso utilize os modulos do APDL e esteja sendo utilizado
		// no ambiente de operador logistico avisa o usuario sobre o
		// procediemento de cadastro de clientes. 
		//------------------------------------------------------------
		If ( lIntegraDL .And. lOperadorL .And. lFilialCli )
			Mat030Oper(SA1->A1_COD,SA1->A1_LOJA,SA1->A1_CGC,cFilialAdm)
		EndIf
	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AfterTTS
M�todo respons�vel por executar regras de neg�cio do OMS depois da 
transa��o do modelo de dados.

@type 		M�todo

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method AfterTTS(oModel,cID) Class CRM980EventDEFOMS
	
	Local aDULRec 	:= {}
	Local cAliasQry	:= ""
	Local cQuery		:= ""
	Local nOperation	:= oModel:GetOperation()

	If ( nOperation == MODEL_OPERATION_INSERT .Or.  nOperation == MODEL_OPERATION_UPDATE )
		If SuperGetMv("MV_CPLINT",.F.,"2") == "1" .And. SuperGetMv("MV_CPLCLI",.F.,"2") == "1" 
			If ( SuperGetMv("MV_CPLEX",.F.,"2") == "2" .And. ( Empty(SA1->A1_PAIS) .Or. SA1->A1_PAIS == PadR('105',Len(SA1->A1_PAIS)) ) .And. SA1->A1_EST != PadR('EX',Len(SA1->A1_EST)) ) .Or. SuperGetMv("MV_CPLEX",.F.,"2") == "1"
		
				aAdd(aDULRec,{"SA1",SA1->(Recno())})
				
				cAliasQry := GetNextAlias()
				
				cQuery := "SELECT R_E_C_N_O_ DULRECNO FROM " + RetSqlName("DUL") + " WHERE D_E_L_E_T_ = ''"
				cQuery += " AND DUL_FILIAL = '" + xFilial("DUL") + "'"
				cQuery += " AND DUL_CODCLI = '" + SA1->A1_COD + "'"
				cQuery += " AND DUL_LOJCLI = '" + SA1->A1_LOJA + "'"
				
				DBUseArea( .T., "TOPCONN", TcGenQry(,,ChangeQuery(cQuery)), cAliasQry, .F., .T.)
				
				While !(cAliasQry)->(Eof())
					aAdd(aDULRec,{"DUL",(cAliasQry)->DULRECNO})
					(cAliasQry)->(DBSkip())
				EndDo
				
				(cAliasQry)->(DBCloseArea())
				
				OMSXJOBCAD(aDULRec,4)
				aSize(aDULRec,0)
				
			EndIf
		EndIf 
	ElseIf nOperation == MODEL_OPERATION_DELETE 
		If ExistFunc("TMSExcDAR") // Integra��o OMS / TMS x MapLink 
			TMSExcDAR(SA1->A1_COD, SA1->A1_LOJA)
		EndIf 
	EndIf
		
Return Nil
