#INCLUDE "BADEFINITION.CH"
#INCLUDE "BAINSTALLER.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BAInstaller
Gatilho para instala��o do TOTVS Fast Analytics.

@author  Helio Leal
@since   17/10/2017
/*/
//-------------------------------------------------------------------
Main Function BAInstaller()
	Local cVersion  := GetSrvProfString("RpoVersion", "")
	
 	If (cVersion == '120')
 		//-------------------------------------------------------------------
		// Tela para sele��o de empresas.
		//-------------------------------------------------------------------
 		BASelectComp()
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BAInstaller
Classe Abstrata respons�vel por representar uma instala��o instala��o
do Fast Analytics, essa classe n�o deve ser instanciada, somente suas 
filhas devem ser instanciadas.

@author  Helio Leal
@since   12/04/2018
/*/
//-------------------------------------------------------------------
Class BAInstaller
	Data lExecution
	Data nStatus

	Method New() CONSTRUCTOR
	Method Install()
	Method Init()
	Method RunEntities()
	Method ClientInfo()
	Method Destroy()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo contrutor.

@Return Self, Inst�ncia da Classe. 

@author  Helio Leal
@since   12/04/2018
/*/
//-------------------------------------------------------------------
Method New() Class BAInstaller
	//--------------------------------------------------------------------
	// Propriedade para verificar se a execu��o ocorreu com sucesso.
	//--------------------------------------------------------------------
	::lExecution := .F.
	
	//--------------------------------------------------------------------
	// Propriedade para controle de tipo de erro:
	//	 * 1: Para erro ao gravar query na tabela de processos; 
	//   * 2: Erro de tamanho de query maior que o par�metro MaxQuerySize; 
	//   * 3: Erro de query em branco ou vazia.
	//--------------------------------------------------------------------
	::nStatus    := 0
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Install
Barra de Load. 
Exibe ao usuario uma tela com barra de load para identificar o progresso 
da instala��o das queries.

@param, aApp, array, �reas selecionadas para instala��o.

@author  henrique.cesar
@since   01/03/2018
/*/
//-------------------------------------------------------------------
Method Install( aApp, aCompany ) Class BAInstaller
	Local cMsg      := ""

	Default aApp := {}

	If Len( aApp ) > 0
		conout(STR0008 + Time()) //"Inicio do processo do BAInstaller as"
	
		FWMsgRun( ,{|| (::lExecution := ::Init( aApp, aCompany ),  cMsg := ::ClientInfo( aCompany ), Iif( ::lExecution, MsgInfo(cMsg), MsgAlert(cMsg)))}, STR0004, STR0005 ) // Instala��o concluida com sucesso.## Totvs Analytics ## Instala��o Totvs Analytics ## Instalando queries, aguarde.....
		
		conout(STR0009 + Time())	//"Fim do processo do BAInstaller as"	
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Inicia o processo de instala��o. 

@param, aApp, array, �rea selecionadas para instala��o.

@Return lSuccess, True para quando a execu��o do m�todo n�o houve erros, caso contr�rio False.

@author  Helio Leal
@since   31/08/2017
/*/
//-------------------------------------------------------------------
Method Init( aApp ) Class BAInstaller
    // M�todo deve ser sobrescrito nas classes filhas.
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} RunEntities
Executa todos os fontes cadastrados para instala��o.

@param, aCompany, array, vetor de empresas.
@param, aApp, array, �rea selecionadas para instala��o.

@Return lSuccess, True para quando a execu��o do m�todo n�o houve erros, caso contr�rio False.

@author  Helio Leal
@since   01/09/2017
/*/
//-------------------------------------------------------------------
Method RunEntities( aCompany, aApp ) Class BAInstaller
  // M�todo deve ser sobrescrito nas classes filhas.
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ClientInfo
Exibe os dados do ambiente de instala��o

@Return cMsg, String, Dados do ambiente

@author Marcia Junko  
@since 29/08/2017
/*/
//-------------------------------------------------------------------
Method ClientInfo( aCompany ) Class BAInstaller
	Local cServerIP  := GetServerIp()
	Local cEnvServer := GetEnvServer()
	Local aTopInfo	 := FWGetTopInfo()
	Local cPort	     := BAGetSrvPort()
	Local cMsg		 := ""
	Local cCompanies := BACompanyValues( aCompany )
	
	cMsg := STR0018 + Chr(13)+Chr(10)+Chr(13)+Chr(10) //"Detalhes da execu��o do BAInstaller: " 
	cMsg += STR0019 + cServerIP + Chr(13)+Chr(10) //"Servidor: "
	cMsg += STR0020 + cPort + Chr(13)+Chr(10) //"Porta do Servidor: "
	cMsg += STR0021 + cEnvServer + Chr(13)+Chr(10) //"Environment: "
	cMsg += STR0022 + aTopInfo[4] + Chr(13)+Chr(10) //"Tipo Banco de dados: "
	cMsg += STR0023 + aTopInfo[1] + Chr(13)+Chr(10) //"Servidor BD: "
	cMsg += STR0024 + aTopInfo[5]+ Chr(13)+Chr(10) //"Nome do banco de dados: "
	cMsg += STR0025 + alltrim(Str(aTopInfo[3])) + Chr(13)+Chr(10) //"Porta do DBAccess: " 
	cMsg += STR0033 + cCompanies + Chr(13)+Chr(10)+ Chr(13)+Chr(10) //"Empresa(s) instalada(s): " 
	
	//---------------------------------------------------------------------
	// Verifica se a execu��o do Fast Analytics ocorreu com sucesso.
	//---------------------------------------------------------------------
	If ::lExecution
		cMsg += STR0026 + " " + STR0029 //"Processo finalizado com sucesso."

	Else
		If ::nStatus == MSG_ERR_TABLE_NOT_EXIST
			cMsg += STR0026 + ". " + STR0030 //"Processo finalizado. Existe(m) registro(s) n�o gravado(s) no sistema. "
		ElseIf ::nStatus == MSG_ERR_EMPTY_QUERY
			cMsg += STR0026 + " " + STR0032 //"Processo finalizado com entidades em branco ou nulo. "
		Else
			cMsg += STR0027 + Chr(13)+Chr(10) //"Ocorreram erros durante a execu��o."
		EndIf

		cMsg += STR0028 //"Para consultar os detalhes, verifique o arquivo de log do appserver."
	EndIf
	
	Conout(replicate("=", 50))
	Conout(cMsg)
	Conout(replicate("=", 50))
	
Return cMsg

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Destroi o objeto e libera a mem�ria alocada.

@author  Helio Leal
@since   12/04/2018
/*/
//------------------------------------------------------------------- 
Method Destroy() class BAInstaller
	::lExecution := Nil
	::nStatus    := Nil
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BAGetSrvPort
Retorna porta do ambiente de instala��o

@Return cSrvPort, String, Porta do servidor de instala��o

@author Marcia Junko   
@since 29/08/2017
/*/
//-------------------------------------------------------------------
Static Function BAGetSrvPort()
	Local cSrvPort	:= ""
		
	cSrvPort := GetPvProfString( "TCP", "Port", "0", GetAdv97())

Return cSrvPort 


//-------------------------------------------------------------------
/*/{Protheus.doc} BASelectComp
Permite que o usu�rio selecione as empresas que deseja instalar.

@author  Marcia Junko
@since   06/06/2019
/*/
//-------------------------------------------------------------------
Function BASelectComp(  )
	Local aCompany     := {}
	Local oLayer       := FWLayer():New()
	Local oDialog      := Nil
	Local oTop         := Nil
	Local oList        := Nil
	Local lContinue	   := .F.

	//-------------------------------------------------------------------
	// Lista empresas dispon�veis.
	//-------------------------------------------------------------------
	aCompany := BALoadComp()
	
	//-------------------------------------------------------------------
	// Monta tela de sele��o de empresas.
	//-------------------------------------------------------------------
	DEFINE DIALOG oDialog TITLE "TOTVS Fast Analytics" FROM 050, 051 TO 400,400 PIXEL
		//-------------------------------------------------------------------
		// Monta as sess�es da tela. 
		//-------------------------------------------------------------------  
		oLayer:Init( oDialog )
		oLayer:addLine( "TOP", 80, .F.)
		oLayer:addCollumn( "TOP_ALL",100, .T. , "TOP")
		oLayer:addWindow( "TOP_ALL", "TOP_WINDOW", STR0034 , 100, .F., .T.,, "TOP"    ) //"Selecione as empresas para instala��o"

		oTop := oLayer:getWinPanel( "TOP_ALL", "TOP_WINDOW", "TOP" ) 

		//-------------------------------------------------------------------
		// Monta a lista de empresas. 
		//-------------------------------------------------------------------  	
      	@ 000, 000 LISTBOX oList;
		 	FIELDS HEADER "", STR0035, STR0036 ; // "C�digo"###"Descri��o da Empresa"
		 	SIZE 160, 115 OF oTop PIXEL; 
		 	ON DBLCLICK (aCompany[oList:nAt, 1] := !aCompany[oList:nAt, 1], oList:Refresh(.f.)) 
			
			oList:SetArray( aCompany )
			oList:bLine := {|| { If(aCompany[oList:nAt, 1], LoadBitmap( GetResources(), "LBTIK" ), LoadBitmap( GetResources(), "LBNO" )), aCompany[oList:nAt, 2], aCompany[oList:nAt, 3] }}
		    oList:bHeaderClick := { |a, b| iif(b == 1 , BAMarkAll(aCompany, b),), oList:Refresh() }

	ACTIVATE DIALOG oDialog CENTERED ON INIT EnchoiceBar( oDialog, { || iif( BAValidArr( aCompany ), { lContinue := .T., oDialog:End() } , MsgInfo( STR0037, STR0005 ) )  }, { || oDialog:End() }, .F., {},,,.F.,.F.,.F.,.T., .F. ) // #"Favor selecionar ao menos uma empresa para continuar." #"Aten��o"

	If lContinue
		BICompanySelected(aCompany)
		BASelectApp(aCompany)
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BAMarkAll
Marca todos os apps (chamada no Header Click).

@author  Marcia Junko
@since   06/06/2019
/*/
//-------------------------------------------------------------------
Static Function BAMarkAll(aLista, nPos)
	Local lMark := .F.
	
	aEval(aLista, {|x| iif(!x[nPos], lMark := .T.,)  })
	aEval(aLista, {|x, i| aLista[i, nPos] := lMark })
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} BAValidArr
Valida se algum item do array foi selecionado.

@author  Marcia Junko
@since   06/06/2019
/*/
//-------------------------------------------------------------------
Static Function BAValidArr( aArray )
Return ( ! aScan( aArray, {|x| x[1] == .T. } ) == 0 )


//-------------------------------------------------------------------
/*/{Protheus.doc} BALoadComp
Monta um vetor com as empresas dispon�veis no sistema.

@author  Marcia Junko
@since   06/06/2019
/*/
//-------------------------------------------------------------------
Function BALoadComp()
	Local aCompany := {}
	
	SET DELET ON

    OpenSM0()

    aEval( FWAllGrpCompany(), {|oComp| AAdd(aCompany, { .F., oComp, FWEmpName(oComp) }) } )
     
Return aCompany


//-------------------------------------------------------------------
/*/{Protheus.doc} BACompanyValues
Retorna as informa��es das empresas instaladas.

@author  Marcia Junko
@since   06/06/2019
/*/
//-------------------------------------------------------------------
Static Function BACompanyValues( aCompany )
	Local cCompanyValues := ""
	
	aEval(aCompany, {|x| Iif(x[1], (cCompanyValues += x[2] + ' - ' + Alltrim(x[3]) + ", "),)  })
	cCompanyValues := Subs(cCompanyValues, 1, len(cCompanyValues) - 2)
	
Return cCompanyValues
