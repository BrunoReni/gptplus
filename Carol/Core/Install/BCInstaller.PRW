#INCLUDE "BCDEFINITION.CH"
#INCLUDE "BCINSTALLER.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BCInstaller
Gatilho para instalação  da  Carol

@author  Andreia Lima
@since   22/04/2019
/*/
//-------------------------------------------------------------------
Main Function BCInstaller()
	Local cVersion  := GetSrvProfString("RpoVersion", "")
	
 	If (cVersion == '120')
 		//-------------------------------------------------------------------
		// Tela para termo de aceite.
		//-------------------------------------------------------------------
 		//BCTermoAceite()
		BCSelectComp()
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BCInstaller
Classe Abstrata responsável por representar uma instalação instalação
da Carol, essa classe não deve ser instanciada, somente suas 
filhas devem ser instanciadas.

@author  Andreia Lima
@since   22/04/2019
/*/
//-------------------------------------------------------------------
Class BCInstaller
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
Método contrutor.

@Return Self, Instância da Classe. 

@author  Andreia Lima
@since   22/04/2019
/*/
//-------------------------------------------------------------------
Method New() Class BCInstaller
	//--------------------------------------------------------------------
	// Propriedade para verificar se a execução ocorreu com sucesso.
	//--------------------------------------------------------------------
	::lExecution := .F.
	
	//--------------------------------------------------------------------
	// Propriedade para controle de tipo de erro:
	//	 * 1: Para erro ao gravar query na tabela de processos; 
	//   * 2: Erro de tamanho de query maior que o parâmetro MaxQuerySize; 
	//   * 3: Erro de query em branco ou vazia.
	//--------------------------------------------------------------------
	::nStatus    := 0
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Install
Barra de Load. 
Exibe ao usuario uma tela com barra de load para identificar o progresso 
da instalação das queries.

@param, aApp, array, Áreas selecionadas para instalação.

@author  Andreia Lima
@since   22/04/2019
/*/
//-------------------------------------------------------------------
Method Install( aApp, aCompany ) Class BCInstaller
	Local cMsg      := ""

	Private oProcess:=nil
	Default aApp := {}

	If Len( aApp ) > 0
		
		conout(STR0008 + Time()) //"Inicio do processo do BCInstaller as"
	
		oProcess := MsNewProcess():New({|| (::lExecution := ::Init( aApp, aCompany ),  cMsg := ::ClientInfo(), Iif( ::lExecution, MsgInfo(cMsg, STR0039), MsgAlert(cMsg, STR0039)))}, STR0004, "Preparando dados",.F. ) // Instalação concluida com sucesso.## Totvs Carol ## Instalação Totvs Carol ## Gerando views, aguarde.....
		oProcess:Activate()
		conout(STR0009 + Time())	//"Fim do processo do BCInstaller as"	
	
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Inicia o processo de instalação. 

@param, aApp, array, Área selecionadas para instalação.

@Return lSuccess, True para quando a execução do método não houve erros, caso contrário False.

@author  Andreia Lima
@since   22/04/2019
/*/
//-------------------------------------------------------------------
Method Init( aApp, aCompany ) Class BCInstaller
    // Método deve ser sobrescrito nas classes filhas.
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} RunEntities
Executa todos os fontes cadastrados para instalação.

@param, aCompany, array, vetor de empresas.
@param, aApp, array, Área selecionadas para instalação.

@Return lSuccess, True para quando a execução do método não houve erros, caso contrário False.

@author  Andreia Lima
@since   22/04/2019
/*/
//-------------------------------------------------------------------
Method RunEntities( aCompany, aApp ) Class BCInstaller
  // Método deve ser sobrescrito nas classes filhas.
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ClientInfo
Exibe os dados do ambiente de instalação

@Return cMsg, String, Dados do ambiente

@author  Andreia Lima
@since   22/04/2019
/*/
//-------------------------------------------------------------------
Method ClientInfo() Class BCInstaller
	Local cServerIP  := GetServerIp()
	Local cEnvServer := GetEnvServer()
	Local aTopInfo	 := FWGetTopInfo()
	Local cPort	     := BCGetSrvPort()
	Local cMsg		 := ""
	
	cMsg := STR0018 + Chr(13)+Chr(10)+Chr(13)+Chr(10) //"Detalhes da execução do BCInstaller: " 
	cMsg += STR0019 + cServerIP + Chr(13)+Chr(10) //"Servidor: "
	cMsg += STR0020 + cPort + Chr(13)+Chr(10) //"Porta do Servidor: "
	cMsg += STR0021 + cEnvServer + Chr(13)+Chr(10) //"Environment: "
	cMsg += STR0022 + aTopInfo[4] + Chr(13)+Chr(10) //"Tipo Banco de dados: "
	cMsg += STR0023 + aTopInfo[1] + Chr(13)+Chr(10) //"Servidor BD: "
	cMsg += STR0024 + aTopInfo[5]+ Chr(13)+Chr(10) //"Nome do banco de dados: "
	cMsg += STR0025 + alltrim(Str(aTopInfo[3])) + Chr(13)+Chr(10) + Chr(13)+Chr(10) //"Porta do DBAccess: " 

	//---------------------------------------------------------------------
	// Verifica se a execução do Fast Analytics ocorreu com sucesso.
	//---------------------------------------------------------------------
	If ::lExecution
		cMsg += STR0026 + " " + STR0029 //"Processo finalizado com sucesso."

	Else
		If ::nStatus == MSG_ERR_TABLE_NOT_EXIST
			cMsg += STR0026 + ". " + STR0030 //"Processo finalizado. Existe(m) registro(s) não gravado(s) no sistema. "
		ElseIf ::nStatus == MSG_ERR_EMPTY_QUERY
			cMsg += STR0026 + " " + STR0031 //"Processo finalizado com entidades em branco ou nulo. "
		Elseif ::nStatus == MSG_ERR_CREATE_VIEW
			cMsg += STR0026 + " " + STR0032 //"Erro ao criar view. "
		Else
			cMsg += STR0027 + Chr(13)+Chr(10) //"Ocorreram erros durante a execução."
		EndIf

		cMsg += STR0028 //"Para consultar os detalhes, verifique o arquivo de log do appserver."
	EndIf
	
	Conout(replicate("=", 50))
	Conout(cMsg)
	Conout(replicate("=", 50))
	
Return cMsg

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Destroi o objeto e libera a memória alocada.

@author  Andreia Lima
@since   22/04/2019
/*/
//------------------------------------------------------------------- 
Method Destroy() class BCInstaller
	::lExecution := Nil
	::nStatus    := Nil
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BCGetSrvPort
Retorna porta do ambiente de instalação

@Return cSrvPort, String, Porta do servidor de instalação

@author  Andreia Lima
@since   22/04/2019
/*/
//-------------------------------------------------------------------
Static Function BCGetSrvPort()
	Local cSrvPort	:= ""
		
	cSrvPort := GetPvProfString( "TCP", "Port", "0", GetAdv97())

Return cSrvPort

//-------------------------------------------------------------------
/*/{Protheus.doc} BCTermoAceite
Exibe o termo de aceite para o usuário antes da instalação
@author  Andreia Lima
@since   03/06/2019
/*/
//-------------------------------------------------------------------
Static Function BCTermoAceite()

	Local nBuild := BCGetBuild()
	
	If ( nBuild >= 17 )
		BCTermoWebEngine()
	Else
		BCTermoBrowser()
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BCGetBuild
Verifica a versao de build
@Return cBuild, String, Versão de build

@author  Andreia Lima
@since   04/06/2019
/*/
//-------------------------------------------------------------------
Static Function BCGetBuild()
	Local nRet := 0
	Local versaoBuild := GetBuild()
	Local nEnd
		
	While ( At( ".", versaoBuild ) > 0 )
		nEnd := At( ".", versaoBuild ) + 1
		versaoBuild := SubStr( versaoBuild, nEnd )		
	EndDo
	
	versaoBuild := SubStr(versaoBuild, 1, 2 )
	nRet := Val(versaoBuild)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} BCTermoBrowser
Exibe o termo de aceite no componente TIBrowser
@author  Andreia Lima
@since   04/06/2019
/*/
//-------------------------------------------------------------------
Static Function BCTermoBrowser()
	Local oDialog := Nil
	Local lOk     := .F.
	Local oBtnRecusar,oBtnAceitar, oTIBrowser

	DEFINE DIALOG oDialog TITLE STR0033 FROM 010, 011 TO 600, 1250 PIXEL
        oTIBrowser := TIBrowser():New(0,3,615,260, "http://tdn.totvs.com/x/nJ2cHQ", oDialog )

		@ 270,270  BUTTON oBtnRecusar PROMPT STR0034 SIZE 50,15 ACTION (oDialog:End()) OF oDialog PIXEL 
        @ 270,325  BUTTON oBtnAceitar PROMPT STR0035 SIZE 50,15 ACTION (lOk := .T. , oDialog:End()) OF oDialog PIXEL 
	
	ACTIVATE DIALOG oDialog CENTERED
                    
	If (lOk == .T.)
		BCSelectApp()
	Endif 
	  
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BCTermoWebEngine
Exibe o termo de aceite no componente TWebEngine
@author  Andreia Lima
@since   04/06/2019
/*/
//-------------------------------------------------------------------
Static Function BCTermoWebEngine()
    Local nPort
    Local lOk := .F.
    Local oWebChannel
    Local oWebEngine
	Local oDialog := Nil
	Local oBtnRecusar,oBtnAceitar, oPainel
	
	DEFINE DIALOG oDialog TITLE STR0033 FROM 010, 010 TO 600, 800 PIXEL	
    	oWebChannel := TWebChannel():New()
    	nPort := oWebChannel::connect()
    
    	oWebEngine := TWebEngine():New(oDialog, 0, 0, 395, 265,, nPort)
    	oWebEngine:navigate("http://tdn.totvs.com/x/nJ2cHQ")

	    @ 266, 000 MSPANEL oPainel SIZE 396, 030 OF oDialog
	    
		@ 8,270 BUTTON oBtnRecusar PROMPT STR0034 SIZE 50,15 ACTION (oDialog:End()) OF oPainel PIXEL 
	    @ 8,325 BUTTON oBtnAceitar PROMPT STR0035 SIZE 50,15 ACTION (lOk := .T. , oDialog:End()) OF oPainel PIXEL 
	
	ACTIVATE DIALOG oDialog CENTERED 

	If (lOk == .T.)
		BCSelectApp()
	Endif 

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BCSelectComp
Permite que o usuário selecione as empresas que deseja instalar.

@author  jose.delmondes
@since   29/09/2020
/*/
//-------------------------------------------------------------------
Function BCSelectComp(  )
	Local oLayer       	:= FWLayer():New()
	Local oDialog      	:= Nil
	Local oTop         	:= Nil
	Local oList        	:= Nil
	Local oBtnFind		:= Nil
	Local oCombo		:= Nil
	Local oGetPesq		:= Nil 
	Local lContinue	   	:= .F.
	Local aFiltros     	:= {"Incluir", "Alterar"}
	Local cCombo		:= aFiltros[1]
	Local aDados		:= {}
	Local cGetPesq		:=""
	Private oOK 		:= LoadBitmap(GetResources(),'LBTICK')
	Private oNO 		:= LoadBitmap(GetResources(),'LBNO')
	Private aCompany    := {}
	Private lInverte	:= .F.

	//-------------------------------------------------------------------
	// Lista empresas disponíveis.
	//-------------------------------------------------------------------
	
	aCompany := BCLoadComp()
	If Len(aCompany)>0
		cGetPesq:= Space(len(aCompany[1][2]))
	EndIf
	aDados	:=BCFilterArr(cCombo,aCompany)
	If Len(aDados)<1
		cCombo		:= aFiltros[2]
		aDados	:=BCFilterArr(cCombo,aCompany)
	EndIf
	//-------------------------------------------------------------------
	// Monta tela de seleção de empresas.
	//-------------------------------------------------------------------
	DEFINE DIALOG oDialog TITLE "TOTVS Carol" FROM 050, 051 TO 500,400 PIXEL
		oLayer:Init( oDialog )
		//-------------------------------------------------------------------
		// Monta as sessões da tela. 
		//-------------------------------------------------------------------  
		oLayer:addLine( "FIND", 20, .F.)
		oLayer:addCollumn( "FIND_ALL",100, .T. , "FIND")
		oLayer:addWindow( "FIND_ALL", "FIND_WINDOW", "Filtros" , 100, .F., .T.,, "FIND"    ) //"Filtros"
		
		oLayer:addLine( "TOP", 80, .F.)
		oLayer:addCollumn( "TOP_ALL",100, .T. , "TOP")
		oLayer:addWindow( "TOP_ALL", "TOP_WINDOW", STR0036 , 100, .F., .T.,, "TOP"    ) //"Selecione as empresas para instalação"

		//-------------------------------------------------------------------
		// Monta a busca e filtro. 
		//-------------------------------------------------------------------  	

		oFind := oLayer:getWinPanel( "FIND_ALL", "FIND_WINDOW", "FIND" )
		@005,000 Say "Busca:" Pixel Of oFind
		
		
		oTop := oLayer:getWinPanel( "TOP_ALL", "TOP_WINDOW", "TOP" ) 

		
		
        // Cria Browse
        oList := TCBrowse():New( 01 , 01, 160, 115,, {'','Codigo','Nome'},{20,50,50}, oTop,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
 
        // Seta vetor para a browse
        oList:SetArray(aDados)
		oList:bLine := {||{ If(aDados[oList:nAt,01],oOK,oNO),;
                                 aDados[oList:nAt,02],;
                                 aDados[oList:nAt,03], } }

		// Evento de clique no cabeçalho da browse
        oList:bHeaderClick := {|o, nCol| If((nCol==1),BCHdCLick(@oList),) }
 
        // Evento de duplo click na celula
        oList:bLDblClick := {|| oList:aArray[oList:nAt][1]:=!(oList:aArray[oList:nAt][1])}
 

		oGetPesq := TGet():New( 003,020,{|u|If(PCount() == 0,cGetPesq,cGetPesq:= u)},oFind,050,009, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cGetPesq,,,,.T. )
		oBtnFind := TBtnBmp2():New( 003,140,26,26,'Pesquisa',,,,{||BCFindEmp(@oList,@cGetPesq)},oFind,,,.T. )
		oGetPesq:SetNextFocus(oBtnFind) 
		oBtnFind:SetNextFocus(oList)
		
		oCombo := TComboBox():New(003,090,{|u|if(PCount()>0,cCombo:=u,cCombo)},;
        aFiltros,070,010,oFind,,{||FindInList(aCompany,@oList,@cCombo) };
        ,,,,.T.,,,,,,,,,'cCombo') 
		



	ACTIVATE DIALOG oDialog CENTERED ON INIT EnchoiceBar( oDialog, { || iif( BCValidArr( @oList ), { lContinue := .T., oDialog:End() } , MsgInfo( STR0038, STR0039 ) )  }, { || oDialog:End() }, .F., {},,,.F.,.F.,.F.,.T., .F. ) // #"Favor selecionar ao menos uma empresa para continuar." #"Atenção"

	If lContinue
		BICompanySelected(aCompany)
		BCSelectApp(aCompany)
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} BCLoadComp
Monta um vetor com as empresas disponíveis no sistema.

@author  jose.delmondes
@since   29/09/2019
/*/
//-------------------------------------------------------------------
Function BCLoadComp()
 	Local aCompany := {}
	Local cAliasI13 := GetNextAlias()
	Local nI := 0 
	SET DELET ON

    OpenSM0()
	
	//{lMark,CodCompany,DescCompany,lExistI13}
    aEval( FWAllGrpCompany(), {|oComp| AAdd(aCompany, { .F., oComp, FWEmpName(oComp),.F. }) } )
	//verifica se alguma filial já foi configurada
	//caso existente deixa marcada para manter as configuracoes
	If TCCanOpen( 'I13')
		BeginSql Alias cAliasI13
			SELECT I13_EMPRES  EMPRESAS FROM I13 
			WHERE I13.%notDel% GROUP BY I13_EMPRES
		EndSql
		While (cAliasI13)->(!EOF())
			For nI:=1 to Len(aCompany)
				If alltrim((cAliasI13)->EMPRESAS)== alltrim(aCompany[nI][2])
					aCompany[nI][4]:= .T.
				endIf
			Next
			(cAliasI13)->(DbSkip())
		EndDo
		(cAliasI13)->(dbCloseArea())
	Else
	EndIf 
     
Return aCompany



//-------------------------------------------------------------------
/*/{Protheus.doc} BCValidArr
Valida se algum item do array foi selecionado.

@author  jose.delmondes
@since   29/09/2020
/*/
//-------------------------------------------------------------------
Static Function BCValidArr( oList )
		aCompany := oList:aArray
		aArray := aCompany

Return ( ! aScan( aArray, {|x| x[1] == .T. } ) == 0 )



 /*/{Protheus.doc} FindInList
	@type  Static Function
	@author leandro.oliveira
	@since 22/02/2021
	@version version
	@param aItems, array, Todos os itens da lista
	@param oList, object, Objeto TCBrowse a ser pesquisado
	@param cCombo, char, informa se a lista sera incluir ou alterar
	@return nil
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function FindInList(aItems,oList,cCombo)
	Local aSelect 	:= {}
	
	aSelect := BCFilterArr(cCombo,aItems)

	oList:SetArray(aSelect)
	oList:bLine := {||{ If(aSelect[oList:nAt,01],oOK,oNO),;
                                 aSelect[oList:nAt,02],;
                                 aSelect[oList:nAt,03], } }
	oList:Refresh()
	
Return nil


 /*/{Protheus.doc} BCFilterArr
	@type  Static Function
	@author leandro.oliveira
	@since 22/02/2021
	@version version
	@param aArray, array, Todos os itens da lista
	@param cCombo, char, informa se a lista sera incluir ou alterar
	@return aRet, array, itens filtrados
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function BCFilterArr(cCombo,aArray)
	Local lAltera 	:= .F.
	Local nI		:=0
	Local aRet 		:= {}
		DO CASE
			CASE cCombo == 'Incluir'
				lAltera := .F.
			CASE cCombo == 'Alterar'
				lAltera := .T.
		ENDCASE
			For nI:=1 to Len(aArray)
				If aArray[nI][4] == lAltera
					AAdd(aRet,aArray[nI])
				EndIf
			Next
Return aRet


 /*/{Protheus.doc} BCHdCLick
	@type  Static Function
	@author leandro.oliveira
	@since 22/02/2021
	@version version
	@param oList, object, Objeto TCBrowse 
	@return nil
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function BCHdCLick(oList)
	Local nI := 0
	lInverte := !lInverte
	For nI := 1 to oList:nLen
		oList:aArray[nI][1]:= lInverte
	Next
	oList:Refresh()
Return


 /*/{Protheus.doc} BCFindEmp
	@type  Static Function
	@author leandro.oliveira
	@since 22/02/2021
	@version version
	@param cGetPesq, char, valor a ser pesquisado
	@param oList, object, Objeto TCBrowse 
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function BCFindEmp(oList,cGetPesq)
	Local nI := 0
	If Len(AllTrim(cGetPesq))>0
		For nI:=1 to oList:nLen
			If AllTrim(oList:aArray[nI][2]) == AllTrim(cGetPesq)
				oList:goPosition(nI)
				oList:Refresh()
				Exit
			EndIf
		Next
	EndIf


Return

