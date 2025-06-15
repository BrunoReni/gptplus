#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "APWIZARD.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TafAtuRec
Realiza a consulta do evento no TSS e retorna os registros transmitidos 
(Status 4) que n�o possuem recibo no TAF.

@author Ronaldo Tapia
@since 14/05/2018
@version 1.0 
/*/
//-------------------------------------------------------------------

Function TafAtuRec()

	Local oStepWiz    := Nil
	Private oPanel	  := Nil
	Private oNewPag   := Nil
	Private lChkTerm  := .F.
	Private oGetDLoc  := Nil

	cUserAc	:=	AllTrim(FWSFUser( __cUserId, "DATAUSER", "USR_CODIGO" ))
	cVerWeb   := GetRemoteType(@cVerWeb)
	lAdmin := FWIsAdmin( __cUserId )

	//Para ambiente Smart, o acesso somente eh permitido para o usuario Supervisor (fixo TAF1)
	If cVerWeb ==  5 // WebAPP
		If !( cUserAc == "TAF1" .OR. lAdmin )
			MsgStop(' O usu�rio [' + cUserAc + '] n�o � o supervisor, portanto n�o possui o acesso desejado!')
			Return()
		EndIf
	Endif

	// Verifica se usu�rio faz parte do grupo de administradores
	If lAdmin .Or. cVerWeb == 5
 
		oStepWiz:= FWWizardControl():New(,{500,600})//Instancia a classe FWWizard
		oStepWiz:ActiveUISteps()
 
		/*----------------------
		 Pagina 1
		----------------------*/
		oNewPag := oStepWiz:AddStep("1")
		//Altera a descri��o do step
		oNewPag:SetStepDescription("Processamento")
		//Define o bloco de constru��o
		oNewPag:SetConstruction({|Panel|TAFCriaPg1(Panel)})
		//Define o bloco ao clicar no bot�o Pr�ximo
		oNewPag:SetNextAction({||TAFVldPg1()})
 
		/*----------------------
		 Pagina 2
		----------------------*/
		oNewPag := oStepWiz:AddStep("2", {|Panel|TAFCriaPg2(Panel)})
		oNewPag:SetStepDescription("Consulta Log")
		oNewPag:SetNextAction({||.T. })
		oNewPag:SetPrevAction({||.F.})

		//Ativa Wizard
		oStepWiz:Activate()

		//Desativa Wizard
		oStepWiz:Destroy()
	
	Else
		MsgAlert("Para realizar esta a��o, o usu�rio deve pertencer ao grupo de Administradores do sistema")//'Para realizar esta a��o, o usu�rio deve pertencer ao grupo de Administradores do sistema.'
	EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCriaPg1
Constru��o da p�gina 1

@Param
oPanel - Painel de dados

@author Ronaldo Tapia
@since 24/05/2018
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function TAFCriaPg1(oPanel)

	Local oFontNeg  := TFont():New( 'Arial', , 14, , .T. )
	Local oFont   	:= TFont():New( 'Arial', , 14, , .F. )

	TSay():New(10,10,{||'Valida��o do n�mero de recibo de protocolo'},oPanel,,oFontNeg,,,,.T.,,,200,20)
	TSay():New(30,10,{||'Esse assistente far� uma consulta no TSS procurando eventos com as seguintes caratec�sticas:'},oPanel,,oFont,,,,.T.,,,500,20)
	TSay():New(40,10,{||'- Evento transmitido com sucesso - STATUS igual a 4.'},oPanel,,oFont,,,,.T.,,,500,20)
	TSay():New(50,10,{||'- Campo do �ltimo protocolo EM BRANCO.'},oPanel,,oFont,,,,.T.,,,500,20)
	TSay():New(60,10,{||'- O evento deve estar ATIVO.'},oPanel,,oFont,,,,.T.,,,500,20)
	TSay():New(80,10,{||'A T E N � � O: Essa altera��o ser� realizada para todas as EMPRESAS e FILIAIS do TAF.'},oPanel,,oFontNeg,,,,.T.,,,500,20)
	TSay():New(90,10,{||'Aguarde o final do processamento. Este processo pode demorar dependendo da quantidade de registros consultados.'},oPanel,,oFont,,,,.T.,,,500,20)
	TSay():New(100,10,{||'Aceite os termos para continur o processo.'},oPanel,,oFont,,,,.T.,,,500,20)

	TCheckBox():New( 130,008,"Li, compreendi e desejo prosseguir com a atualiza��o.",bSETGET(lChkTerm),oPanel,150,009,,,,,,,,.T.,,,) //"Li, compreendi e desejo prosseguir com a atualiza��o."
	TSay():New(140,10,{||'Ao clicar em "Avan�ar" o processo ser� iniciado'},oPanel,,oFontNeg,,,,.T.,,,500,20)
	
Return()


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCriaPg2
Constru��o da p�gina 3

@Param
oPanel - Painel de dados

@author Ronaldo Tapia
@since 24/05/2018
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function TAFCriaPg2(oPanel)

	Local oFontNeg  := TFont():New( 'Arial', , 14, , .T. )
	Local oFont   	:= TFont():New( 'Arial', , 14, , .F. )
	Local oBtlinks  := Nil

	TSay():New(10,10,{||'Atualiza��o finalizada com sucesso!'},oPanel,,oFontNeg,,,,.T.,,,200,20)
	TSay():New(20,10,{||'Consulte o log de atualiza��o no Menu --> Consultas --> Log Altera��o Protocolo'},oPanel,,oFont,,,,.T.,,,500,20)
	TSay():New(40,10,{||'A T E N � � O: O Log � exclusivo por empresa. Ser� gerado com as seguintes caratec�sticas:'},oPanel,,oFont,,,,.T.,,,500,20)
	TSay():New(50,10,{||' - Campo STATUS igual a 1: Recibo encontrado no TSS e atualizado na base TAF. '},oPanel,,oFont,,,,.T.,,,500,20)
	TSay():New(60,10,{||' - Campo STATUS igual a 2: Recibo n�o encontrado no TSS. '},oPanel,,oFont,,,,.T.,,,500,20)
	TSay():New(70,10,{||'Uma vez que o recibo n�o foi encontrado no TSS � recess�rio realizar o processo de'},oPanel,,oFontNeg,,,,.T.,,,500,20)
	TSay():New(80,10,{||'atualiza��o manual do n�mero do recibo para atualiza��o da base no TAF.'},oPanel,,oFontNeg,,,,.T.,,,500,20)
	
	// Link da ferramenta TOTVS CLONE no TDN
	@100,010 SAY oBtlinks PROMPT "<u>"+ 'Clique aqui para mais informa��es.' +"</u>" SIZE 300,010 OF oPanel HTML PIXEL
	oBtlinks:bLClicked := {|| ShellExecute("open","http://tdn.totvs.com/x/crJSDg","","",1) }

Return()
 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFVldPg1
Valida��o do bot�o Pr�ximo da p�gina 1

@author Ronaldo Tapia
@since 24/05/2018
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function TAFVldPg1()

	Local lRet := .T.
	
	If !lChkTerm
		FWAlertInfo("Aceite os termos antes de prosseguir.")
		lRet := .F.
	EndIf

	If lRet
		Processa( {|| TAFAtuEve() }, "Aguarde!", "Inicio do Processamento...",.F.)
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAtuEve
Faz a consulta no TSS e realiza a atualiza��o do n�mero do recibo no 
caso TAF caso encontrado no TSS.

@author Ronaldo Tapia
@since 24/05/2018
@version 1.0 
/*/
//-------------------------------------------------------------------
Static Function TAFAtuEve()

	Local aRetFil     := {}
	Local aFiliais	  := {}
	Local cStatus	  := .T.
	Local aSM0	      := FWAllGrpCompany() // Carrego os grupos de empresas
	Local cEmp		  := ""
	Local aEventos	  := {}
	Local aeSocial1   := {} // Eventos do eSocial
	Local aeSocial2   := {} // Eventos do eSocial
	Local nTotEven	  := 0
	Local aMatriz	  := {}
	Local cModoC1E	  := ""
	Local nx
	Local ni
	Local na
	Local nw

	//Carrego todos os eventos do eSocial
	aEventos := TAFRotinas( ,, .T., 2 )
	nTotEven := Iif(Valtype(aEventos) == "A", Len(aEventos) / 2,0) // Divido em dois o n�mero de elementos do array
	
	//Quebro os eventos do eSocial em dois arrays
	For na:= 1 to Len(aEventos)
		If na <= nTotEven
			aAdd(aeSocial1, aEventos[na])
		Else
			aAdd(aeSocial2, aEventos[na])
		EndIf
	Next na
	
	ProcRegua(Len(aSM0))
	
	For ni := 1 to Len( aSM0 )
		cEmp := aSM0[ni]
		
		IncProc("Validando Empresa: " + cEmp)
		IncProc("Empresa: " + cEmp + " Validando eventos no TSS...")
			
		If !TAFAlsInDic( "V1X" ) // Valida se a tabela existe no dicion�rio
			MsgInfo("Ambiente desatualizado. Execute o compatibilizador de dicionario de dados UPDTAF") //Ambiente desatualizado. Execute o compatibilizador de dicionario de dados UPDTAF
		Else
			// Retorna as filiais para o grupo de empresas, empresa e unidade de neg�cio informada
			aRetFil := FWLoadSM0() // Carrego as filiais do grupo de empresas
			aFiliais := {}
			For nx := 1 to Len(aRetFil)
				If aRetFil[nx][1] == cEmp
					// Pesquisa o status da filial posicionada.
					cStatus := FWFilialStatus()
					aAdd(aFiliais,{cStatus,aRetFil[nx][2]})
				EndIf
			Next nx
			
			If !Empty(cEmp) .And. len(aFiliais) > 0
			
				// Abro a tabela C1E da empresa que estou processando
				If EmpOpenFile("C1E","C1E",1,.T.,cEmp, @cModoC1E )
					For nw := 1 to Len(aFiliais)
						//Verifica qual � a filial matriz da empresa posicionada
						DBSelectArea("C1E")
						C1E->( DBSetOrder(3) )
						If C1E->( MSSeek( xFilial("C1E") + PadR( aFiliais[nw][2], TamSX3( "C1E_FILTAF" )[1] ) + "1" ) )
							If C1E->C1E_MATRIZ == .T.
								aMatriz := aFiliais[nw][2]
								nw := nw + Len(aFiliais) // S� pode ter 1 Filial Marcada como Matriz
			   								     		// por isso posso sair do la�o quando ha a ocorr�ncia.
							EndIf
						EndIf
					Next nw
				EndIf
			
				If Len(aMatriz) > 0
		
					TafRecPrcx(cEmp, aMatriz, aFiliais, aeSocial1, aeSocial2 )

				EndIf
			EndIf
		EndIf
	Next ni
	
	MsgInfo("Fim do processo de monitoramento do TSS x TAF.")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFGravLog
Realiza a consulta do evento no TSS e retorna os registros transmitidos 
(Status 4) que n�o possuem recibo no TAF.

@Param aDadosTSS - Retorno das informa��es do TSS
	aDadosTSS[1][1]:cAMBIENTE
	aDadosTSS[1][1]:cCHAVE
	aDadosTSS[1][1]:cCODIGO
	aDadosTSS[1][1]:cCODRECEITA
	aDadosTSS[1][1]:cDETSTATUS
	aDadosTSS[1][1]:cDSCRECEITA
	aDadosTSS[1][1]:cPROTOCOLO
	aDadosTSS[1][1]:cRECIBO
	aDadosTSS[1][1]:cSTATUS
	aDadosTSS[1][1]:cVERSAO
	aDadosTSS[1][1]:cXMLERRORET
	aDadosTSS[1][1]:cXMLEVENTO

@author Ronaldo Tapia
@since 15/05/2018
@version 1.0 
/*/
//-------------------------------------------------------------------

Static Function TAFGravLog(aDadosTSS)

	Local nx	   := 0
	Local aRetTRot := TafRotinas()
	Local cTabela  := ""
	local cQuery   := ""
	Local cEvento  := ""
	Default aDadosTSS := {}

	For nx := 1 to Len(aDadosTSS[1])
		If Alltrim(aDadosTSS[1][nx]:cSTATUS) = "6"
			nPos :=  aScan( aRetTRot, {|x| x[4] == Alltrim(aDadosTSS[1][nx]:cCODIGO) } )
			If nPos > 0
				cTabela := aRetTRot[nPos][3]
			EndIf
			
			// Fa�o um select na tabela procurando a filial do registro
			If !Empty(cTabela)
				cQuery := ""
				If cTabela == "C1E"
					cQuery += " SELECT " + cTabela	+ "_FILTAF FILIAL "
				Else
					cQuery += " SELECT " + cTabela	+ "_FILIAL FILIAL "
				EndIf
				cQuery += " FROM "   + RetSqlName((cTabela))
				cQuery += " WHERE "  + cTabela + "_PROTUL = '" + Alltrim(aDadosTSS[1][nx]:cRECIBO) + "' "
				cQuery += " AND D_E_L_E_T_ = '' "
				If (Select("FIlTAB") <> 0)
					dbSelectArea("FIlTAB")
					dbCloseArea()
				Endif
				 
				TCQuery cQuery NEW ALIAS "FIlTAB"
				Dbselectarea("FIlTAB")
			EndIf

			// Grava tabela de Log
			If RecLock( "V1X", .T. )
				If !Empty(FIlTAB->FILIAL)
					V1X->V1X_FILIAL     := FIlTAB->FILIAL
				Else
					V1X->V1X_FILIAL     := xFilial(cTabela)
				EndIf
				V1X->V1X_ID             := TAFGeraID( "TAF" )
				// Transformo o evento removendo o "-"
				If RAT("-", aDadosTSS[1][nx]:cCODIGO) > 0
					cEvento := Alltrim(LEFT(aDadosTSS[1][nx]:cCODIGO, 1)) + RIGHT(Alltrim(aDadosTSS[1][nx]:cCODIGO),4)
				EndIf
				V1X->V1X_EVENTO         := cEvento
				V1X->V1X_TABELA         := cTabela
				V1X->V1X_CHAVE          := Alltrim(aDadosTSS[1][nx]:cID)
				If !Empty(aDadosTSS[1][nx]:cRECIBO)
					V1X->V1X_STATUS         := "1" // Atualizado
					V1X->V1X_OBSERV         := "Registro encontrado no TSS e atualizado com sucesso na base TAF" // "Registro encontrado no TSS e atualizado com sucesso na base TAF"
				Else
					V1X->V1X_STATUS         := "2" // N�o Atualizado
					V1X->V1X_OBSERV         := "Recibo n�o encontrado no TSS, n�o foi poss�vel atualizar o registro no TAF. Verifique!" // "Recibo n�o encontrado no TSS, n�o foi poss�vel atualizar o registro no TAF. Verifique!"
				EndIf
				V1X->( MsUnlock() )
			EndIf
		EndIf
	Next nx

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafRecPrcx
Executa um Job para realizar o processamento do Recibo

@author Ronaldo Tapia
@since 29/05/2018
@version 1.0 
/*/
//-------------------------------------------------------------------

Function TafRecPrcx( cEmp, aMatriz, aFiliais, aeSocial1, aeSocial2 )

	Local aGetTSS	  := {}
	Local lProtul     := .T. // Indica que ser� realizado a pesquisa somente dos t�tulos com n�mero de protocolo (Recibo) em branco
	Local cStsConsult := "4"
	
	Default cEmp      := ""
	Default aMatriz   := {}
	Default aFiliais  := {}
	Default aeSocial1 := {}
	Default aeSocial2 := {}
	
	// Verifica se existe dicion�rio para a empresa em processamento
	OpenSxs( ,,,, cEmp, "SX2TAF", "SX2",, .F.,, .T., .F. )
	If Select( "SX2TAF" ) > 0

	//Redefino o ambiente para a empresa passada como par�metro
		RPCClearEnv()
		RPCSetType( 3 )
		RPCSetEnv( cEmp, aMatriz,,, "TAF" )

		//Realiza a consulta no TSS e atualiza campo de protocolo para os eventos contidos no array aeSocial1
		aGetTSS := TAFProc5Tss(.T.,aeSocial1,cStsConsult,,,.F.,,aFiliais,,,,.F.,,,lProtul)
		// Grava tabela de Log do processo executado via Job
		If Len(aGetTSS) > 0
			TAFGravLog(aGetTSS)
		EndIf
	
		//Realiza a consulta no TSS e atualiza campo de protocolo para os eventos contidos no array aeSocial2
		aGetTSS := {}
		aGetTSS := TAFProc5Tss(.T.,aeSocial2,cStsConsult,,,.F.,,aFiliais,,,,.F.,,,lProtul)
		// Grava tabela de Log do processo executado via Job
		If Len(aGetTSS) > 0
			TAFGravLog(aGetTSS)
		EndIf

	EndIf
		
Return()