#include "protheus.ch"
#include "totvs.ch"
#include "WizardTF.ch"

#DEFINE DEFAULT_MOTBX      "MPR"
#DEFINE DEFAULT_DESC_MOTBX "MAIS PRAZO"

/*/{Protheus.doc} WizardTF
Wizard para ativação da integração com a TechFin

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
/*/

Main Function WizardTF1()

	MsApp():New( "SIGAFIN" )
	oApp:cInternet  := Nil
	__cInterNet := NIL
	oApp:bMainInit  := { || ( oApp:lFlat := .F. , TechFinWiz() , Final( "Encerramento Normal" , "" ) ) } //"Encerramento Normal"
	oApp:CreateEnv()
	OpenSM0()

	PtSetTheme( "TEMAP10" )
	SetFunName( "WIZARDTF1" )
	oApp:lMessageBar := .T.

	oApp:Activate()

Return Nil


/*/{Protheus.doc} TechFinWiz
Montagem do Step do FWCarolWizard para ativação da integração com a TechFin

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
/*/

Static Function TechFinWiz()

	Local oWizard       As Object
	Local cDescription  As Character
	Local cReqMsg       As Character
	Local cReqDes       As Character
	Local cReqCont      As Character
	local cReqLib       As Character
	Local bConstruction As CodeBlock
	Local bProcess      As CodeBlock
	Local bNextAction   As CodeBlock
	Local bReqVld       As CodeBlock
	local bReqlib       As CodeBlock
	Private cStep       As Character

	nStep := 1

	oWizard := FWCarolWizard():New()

	cDescription   := STR0001
	bConstruction  := { | oPanel | cStep := StepProd(oPanel)}
	bProcess       := { | cGrpEmp, cMsg | IIf(cStep == "TOTVS Antecipa", FinTFWizPg(), IIf(cStep == "TOTVS Mais Prazo", ProcAnt( cGrpEmp, cStep), IIF(cStep == "TOTVS Mais Negócios", RSKA110(), .T.)))}
	bNextAction    := { || VldStep(cStep, oWizard)}
	cReqDes        := STR0002
	cReqCont       := GetRpoRelease()
	bReqVld        := { || GetRpoRelease() >= "12.1.025"}
	cReqMsg        := STR0003
	cReqLib        := FwtechfinVersion()
	bReqlib        := { || FwtechfinVersion() >= "2.4.0" }

	oWizard:SetWelcomeMessage( STR0004 )
	oWizard:AddRequirement( cReqDes, cReqCont, bReqVld, cReqMsg )
	oWizard:AddRequirement( STR0033, cReqLib, bReqlib, STR0034 )
	oWizard:AddStep( cDescription, bConstruction, bNextAction)
	oWizard:AddProcess( bProcess )
	oWizard:UsePlatformAccess(.T.)
    IF cReqLib >= "2.4.0"
		oWizard:SetExclusiveCompany(.F.)
	EndIf
	oWizard:Activate()
Return Nil

/*/{Protheus.doc} StepProd
Montagem tela para escolha do Produto a Ser configurado

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
@return     Character, Retorna o codigo do Produto
/*/

Static Function StepProd(oPanel) as Character

	Local oBmp as Object
	Local cRet as Character

	cRet := StepWiz()

	@ 005,135 BITMAP oBMP RESOURCE "Techfin.bmp" OF oPanel PIXEL NOBORDER
	oBmp:lAutoSize := .T.

	@ 072, 010 SAY STR0005 +Space(1)+ cRet SIZE 200,20 OF oPanel PIXEL
	@ 098, 010 SAY STR0006 SIZE 200,20 OF oPanel PIXEL

Return cRet


/*/{Protheus.doc} ProcAnt() 
Rotina de Processamento da gravalçao dos parâmetros

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
@param      cGrpEmp, character, código do grupo da Empresa
@param      cStep, character, produto a ser configurado
@return     Logical, Sucesso ou insucesso da operação
/*/

Static Function ProcAnt( cGrpEmp as Character, cStep as Character) as Logical

	Local aMotBx      As Array
	Local aDescMotbx  As Array
	Local lRet        As Logical
	Local lExistBxMpr As Logical
	Local nI          As Numeric
	Local oDlg        As Object
	Local oCbx        As Object
	Local oGrp        As Object

	Local cMvPrefixo  As Character
	Local cMvTipo     As Character
	Local cMvMotBx    As Character
	Local cMvNaturez  As Character
	Local cMvFornece  As Character
	Local cMvLoja     As Character
	Local cMvValAce   As Character

	Private cPref     As Character
	Private cTipo     As Character
	Private cNat      As Character
	Private cForn     As Character
	Private cLoja     As Character
	Private cMotBx    As Character
	Private cCodVa    As Character
	Private cDescVa   As Character
	Private lExistSED   As Logical
	Private lExistSA2   As Logical
	Private lExistFKC   As Logical

	LimMotRead()
	aMotBx      := ReadMotBx()
	aDescMotbx  := {}
	nI          := 1
	lExistBxMpr := .T.
	lRet        := .T.

	SUPERGETMV() // Para Limpar o cache do Supergetmv

	//Retorna o Array aDescMotBx contendo apenas a descricao do motivo das Baixas
	For nI := 1 to Len( aMotBx )
		If SubStr(aMotBx[nI],34,01) == "P"
			aAdd(aDescMotbx,SubStr(aMotBx[nI],01,3))
		EndIf
	Next nI

	If aScan(aDescMotbx, {|x| x == DEFAULT_MOTBX}) == 0 //MPR
		lExistBxMpr := .F.
		aAdd(aDescMotbx, DEFAULT_MOTBX) //MPR
	EndIf

	cMvPrefixo := SuperGetMV("MV_PRETECF", .F., "")
	cMvTipo    := SuperGetMV("MV_TPTECF" , .F., "")
	cMvNaturez := SuperGetMV("MV_NTTECF" , .F., "")
	cMvFornece := SuperGetMV("MV_FNTECF" , .F., "")
	cMvLoja    := SuperGetMV("MV_LFTECF" , .F., "")
	cMvMotBx   := SuperGetMV("MV_MBXTECF", .F., "")
	cMvValAce  := SuperGetMV("MV_VATECF" , .F., "")

	cPref      := If(Empty(cMvPrefixo), Space(TamSX3("E2_PREFIXO")[1]), PadR(AllTrim(cMvPrefixo), TamSX3("E2_PREFIXO")[1]))
	cTipo      := If(Empty(cMvTipo)   , Space(TamSX3("E2_TIPO"   )[1]), PadR(AllTrim(cMvTipo)   , TamSX3("E2_TIPO"   )[1]))
	cNat       := If(Empty(cMvNaturez), Space(TamSX3("ED_CODIGO" )[1]), PadR(AllTrim(cMvNaturez), TamSX3("ED_CODIGO" )[1]))
	cForn      := If(Empty(cMvFornece), Space(TamSX3("A2_COD"    )[1]), PadR(AllTrim(cMvFornece), TamSX3("A2_COD"    )[1]))
	cLoja      := If(Empty(cMvLoja)   , Space(TamSX3("A2_LOJA"   )[1]), PadR(AllTrim(cMvLoja)   , TamSX3("A2_LOJA"   )[1]))
	cCodVa     := If(Empty(cMvValAce) , Space(TamSX3("FKC_CODIGO")[1]), PadR(AllTrim(cMvValAce) , TamSX3("FKC_CODIGO")[1]))
	cMotBx     := If(Empty(cMvMotBx)  , DEFAULT_MOTBX                 , PadR(AllTrim(cMvMotBx)  , 3))

	lExistSED  := If(Empty(cMvNaturez), .F., CheckParam("SED", {cMvNaturez}))
	lExistSA2  := If(Empty(cMvFornece) .And. Empty(cMvLoja), .F., CheckParam("SA2", {cMvFornece, cMvLoja}))
	lExistFKC  := If(Empty(cMvValAce), .F., CheckParam("FKC", {cMvValAce}))
	
	If ValidParam()

		DEFINE MSDIALOG oDlg TITLE STR0007 STYLE DS_MODALFRAME FROM 180,180 TO 470,700 PIXEL
		oDlg:lEscClose := .F.

		@ 000,005 GROUP oGrp TO 117,255 LABEL STR0008 PIXEL

		@ 012, 010 SAY STR0009 SIZE 200,20 OF oDlg PIXEL //"Prefixo"
		@ 010, 053 MSGET cPref SIZE 59, 09 OF oDlg PIXEL WHEN .T. PICTURE "@!" VALID !VAZIO()

		@ 027, 010 SAY STR0010 SIZE 200,20 OF oDlg PIXEL //"Tipo"
		@ 027, 053 MSGET cTipo SIZE 59, 09 OF oDlg  PIXEL F3 "05" WHEN .T. PICTURE "@!" VALID !VAZIO()

		@ 044, 010 SAY STR0011 SIZE 200,20 OF oDlg PIXEL //"Natureza"
		@ 044, 053 MSGET cNat SIZE 59, 09 OF oDlg PIXEL WHEN .T. VALID Vazio() .Or. ExistCpo("SED",cNat) PICTURE "@!"
		@ 044, 115 BUTTON oBtnClient PROMPT STR0044 SIZE 30, 11 OF oDlg PIXEL ;
			WHEN .T. ACTION ( SetAction( "SED", .T. ) )    //"Pesquisar"
		@ 044, 150 BUTTON oBtnClient PROMPT STR0045 SIZE 30, 11 OF oDlg PIXEL ;
			WHEN !lExistSED ACTION ( SetAction( "SED", .F. ) )    //"Incluir"

		@ 061, 010 SAY STR0012 SIZE 200,20 OF oDlg PIXEL //"Fornec./Loja"
		@ 061, 053 MSGET cForn SIZE 40, 09 OF oDlg PIXEL WHEN .T. VALID Vazio() .Or. ExistCpo("SA2",cForn) PICTURE "@!"
		@ 061, 095 MSGET cloja SIZE 15, 09 OF oDlg PIXEL WHEN !Empty(cForn) VALID Vazio() .Or. ExistCpo("SA2",cForn+cLoja) PICTURE "@!"
		@ 061, 115 BUTTON oBtnClient PROMPT STR0044 SIZE 30, 11 OF oDlg PIXEL ;
			WHEN .T. ACTION ( SetAction( "SA2", .T. ) )    //"Pesquisar"
		@ 061, 150 BUTTON oBtnClient PROMPT STR0045 SIZE 30, 11 OF oDlg PIXEL ;
			WHEN !lExistSA2 ACTION ( SetAction( "SA2", .F. ) )    //"Incluir"

		@ 078, 010 SAY STR0050 SIZE 200,20 OF oDlg PIXEL //"Valor Acessório"
		@ 078, 053 MSGET cCodVa SIZE 59, 09  OF oDlg PIXEL WHEN .T. VALID Vazio() .Or. ExistCpo("FKC",cCodVa) PICTURE "@!"
		@ 078, 115 BUTTON oBtnClient PROMPT STR0044 SIZE 30, 11 OF oDlg PIXEL ;
			WHEN .T. ACTION ( SetAction( "FKC", .T. ) )    //"Pesquisar"
		@ 078, 150 BUTTON oBtnClient PROMPT STR0045 SIZE 30, 11 OF oDlg PIXEL ;
			WHEN !lExistFKC ACTION ( SetAction( "FKC", .F. ) )    //"Incluir"

		@ 095, 010 SAY STR0014 SIZE 200,20 OF oDlg PIXEL //"Motivo Baixa"
		@ 095, 053 MSCOMBOBOX oCbx VAR cMotBx ITEMS aDescMotbx SIZE 59,35 OF oDlg PIXEL

		@ 120, 110 BUTTON STR0017 SIZE 030, 025 PIXEL OF oDlg ACTION ( If(GravaPar(lExistBxMpr), oDlg:End(),.F.))

		ACTIVATE DIALOG oDlg CENTERED

	Endif

	lRet := ValidParam()

Return lRet

/*/{Protheus.doc} Gravapar
Rotina de Validação e gravação dos parâmetros

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
@return     Logical, Sucesso ou insucesso da operação
/*/

Static Function GravaPar(lExistBxMpr As Logical) As Logical

	Local lRet     as Logical
	Local cPeriod  as Character
	Local cAgend   as Character
	Local cMsgErro as Character

	cPeriod  := ""
	cAgend   := ""
	cMsgErro := ""
	lRet     := !Empty(cPref) .And. !Empty(cTipo) .And. !Empty(cNat) .And. !Empty(cForn) .And. !Empty(cLoja) .And. !Empty(cCodVa) .And. !Empty(cMotBx)

	If lRet
		If !lExistBxMpr .And. !IncMotBx()
			Help(Nil, Nil, "MOTBX", "", STR0051, 1,;
				,,,,,,{STR0052}) //"Não foi possível incluir o motivo de baixa MPR automaticamente." ## "Será necessário realizar o cadastro manualmente."
		EndIf

		If Len(alltrim(cPref)) > TamSX3("E2_PREFIXO")[1]
			Help(Nil, Nil, "NONAT", "", STR0018 + FWCompany() , 1,;
				,,,,,,{STR0019})
		else
			PUTMV("MV_PRETECF" , PADR(alltrim(cPref), TamSX3("E2_PREFIXO")[1]))   //Prefixo
		Endif

		dbSelectArea('SX5')
		dbSetOrder(1)
		If dbSeek(xFilial('SX5')+"05"+ PADR(alltrim(cTipo), TamSX3("E2_TIPO")[1]))
			PUTMV("MV_TPTECF"  , PADR(alltrim(cTipo), TamSX3("E2_TIPO")[1]))   //Tipo
		Else
			Help(Nil, Nil, "TIPTIT", "", STR0020 + FWCompany() , 1,;
				,,,,,,{STR0021})
		EndIf

		Dbselectarea("SED")
		dbSetOrder(1)
		Dbgotop()
		If dbseek(FwxFilial("SED")+ PADR(alltrim(cNat), TamSX3("ED_CODIGO")[1]))
			PUTMV("MV_NTTECF"  , PADR(alltrim(cNat), TamSX3("ED_CODIGO")[1]))   //Natureza
		else
			Help(Nil, Nil, "NONAT", "", STR0022 + FWCompany() , 1,;
				,,,,,,{STR0023})
		Endif

		DbSelectArea("SA2")
		DbSetorder(1)
		DbGotop()
		If dbseek(FwxFilial("SA2")+ PADR(alltrim(cForn), TamSX3("A2_COD")[1])+PADR(alltrim(cLoja), TamSX3("A2_LOJA")[1]))
			PUTMV("MV_FNTECF"  , PADR(alltrim(cForn), TamSX3("A2_COD")[1]))   //Fornecedor
			PUTMV("MV_LFTECF"  , PADR(alltrim(cLoja), TamSX3("A2_LOJA")[1]))   //Loja
		else
			Help(Nil, Nil, "NOFOR", "", STR0024 + FWCompany() , 1,;
				,,,,,,{STR0025})
		Endif

		PUTMV("MV_MBXTECF" , PADR(alltrim(cMotBx), TamSX3("FK1_MOTBX")[1]))   //Motivo de Baixa

		DbSelectArea("FKC")
		DbSetorder(1)
		DbGotop()

		PUTMV("MV_VATECF"  , PADR(alltrim(cCodVa), TamSX3("FKC_CODIGO")[1]))   //Codigo Valores AcessÃƒÂ³rios

		If !(ExisteJob())
			//Executa a cada 10 minutos
			cPeriod := "D(Each(.T.);Day(1);EveryDay(.F.););Execs(0144);Interval(00:10);"
			//(cFunction, cUserID, cParam, cPeriod, cTime, cEnv, cEmpFil, cStatus, dDate, nModule, aParamDef)
			cAgend := FwInsSchedule("FINA137F", "000000",, cPeriod, "00:00", Upper(GetEnvServer()), cEmpAnt + "/" + cFilAnt + ";","0", Date(), 6, {cEmpAnt, cFilAnt, "TESTE"})
			If Empty(cAgend)
				cMsgErro :=  STR0026
				FwLogMsg("INFO",, "SCHEDULER", FunName(), "", "01", cMsgErro, 0, 0, {})
			EndIf
		EndIf	
	EndIf

Return lRet

/*/{Protheus.doc} ValidParam
Rotina de Validação dos Parametros TOTVS Mais Prazo

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
@return     Logical, Sucesso ou insucesso da operação
/*/


Static Function ValidParam() As Logical

	Local lExiste   As Logical

	lExiste := .T.

	If !(GetMV("MV_PRETECF", .T.)) .Or. !(GetMV("MV_TPTECF", .T.)) .Or. !(GetMV("MV_NTTECF", .T.)) .Or.;
			!(GetMV("MV_FNTECF", .T.)) .Or. !(GetMV("MV_LFTECF", .T.)) .Or. !(GetMV("MV_MBXTECF", .T.)) .Or. !(GetMV("MV_VATECF", .T.))
		lExiste := .F.
		Help(Nil, Nil, "NOPARAM", "", STR0027 + FWCompany() , 1,; //"Um ou mais parÃƒÂ¢metros Financeiros do TOTVS Antecipa nÃƒÂ£o foram encontrados."
		,,,,,,{STR0028}) // "Execute o UPDDISTR de acordo com a ÃƒÂºltima expediÃƒÂ§ÃƒÂ£o contÃƒÂ­nua para criaÃƒÂ§ÃƒÂ£o dos parÃƒÂ¢metros Financeiros do TOTVS Antecipa."
	EndIf

Return lExiste

/*/{Protheus.doc} Stepwiz()
Rotina de Escolha do Produto

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
@return     Character, Codigo do produto a ser configurado
/*/

Static Function Stepwiz() as Character
	Local oDlg     	as Object
	Local oButton  	as Object
	Local oRadio   	as Object
	Local oGrp     	as Object
	Local oBmp     	as Object
	Local nRadio   	as Numeric
	Local aOptions 	as Array
	Local cRet     	as Character

	nRadio :=1

    aOptions:= {"TOTVS Mais Prazo","TOTVS Antecipa","Painel Financeiro","Gesplan","TOTVS Mais Negócios"}

	cRet := ""

	DEFINE MSDIALOG oDlg FROM 0,0 TO 220,280 STYLE DS_MODALFRAME PIXEL TITLE STR0029
	oDlg:lEscClose := .F.

	@ 00,12 BITMAP oBMP RESOURCE "Techfin.bmp" OF oDlg PIXEL NOBORDER
	oBmp:lAutoSize := .T.

    @ 031,012 GROUP oGrp TO 090,130 LABEL ("Escolha") PIXEL
	oRadio:= tRadMenu():New(40,15,aOptions, {|u|if(PCount()>0,nRadio:=u,nRadio)},oDlg,,,,,,,,100,20,,,,.T.)

	@ 95,45 BUTTON oButton PROMPT STR0030 OF oDlg PIXEL ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED

	cRet := aOptions[nRadio]

Return cRet 


/*/{Protheus.doc} ExisteJob
Verifica se o JOB existe no grupo de empresa atual.

@type       Function
@author     Victor Furukawa
@since      05/11/2020
@version    P12.1.27
@param      cAgendamen, character, código do agendamento
@return     logical, verdadeiro caso encontre o job para empresa desejada
@obs        rotina possui referência direta as tabelas de framework XX1 e XX2 pois não existe função que atenda a este requisito. A issue DFRM1-16827 foi aberta para este propósito
/*/
Static Function ExisteJob() As Logical

	Local aSchd       As Array

	Local lCriado     As Logical

	Local oDASched    As Object

	Local nX          As Numeric

	lCriado := .F.

	oDASched := FWDASchedule():New() //chama o objeto do schedule
	aSchd:=oDASched:readSchedules() //como voce não sabe quem é, tem que ler todos

	For nX := 1 to Len(aSchd)

		If Alltrim(aSchd[nX]:GetFunction())== 'FINA137F' .And. aSchd[nX]:GetEmpFil() == AllTrim(cEmpAnt) + "/" + AllTrim(cFilAnt) + ";"
			lCriado := .T.
		Endif

	Next

Return lCriado

/*/{Protheus.doc} VldStep
Retorna um aviso para que o usuario esteja ciente para verificar o compartilhamento das tabelas SA2 e SED.

@type       Function
@author     Victor Furukawa
@since      05/11/2020
@version    P12.1.27
@return     Character, Retorna o codigo do valor acessório
/*/

Static Function VldStep(cOpc As Character, oWizard As Object) As Logical

	Local lRet   As Logical
	Local lCheck AS Logical

	Local oDlg as Object
	Local oChkBox as Object
	
	Local cUser As Character
	Local cSenha As Character
	Local aGrpEmp As Array

	lRet := .T.
	lCheck := .F.
    lok     	:= .F.
	cUSer		:= Space(30)
	cSenha		:= Space(30)	

    If Alltrim(cOpc) == "Gesplan" 
		
		If GetApoInfo("finxnat.prx")[4] >=CtoD('07/11/2022') .And. GetApoInfo("finxfin.prx")[4]>=CtoD('07/11/2022')

			aGrpEmp		:= oWizard:GetSelectedGroups()

			DEFINE MSDIALOG oDlg FROM 0,0 TO 200,380 STYLE DS_MODALFRAME PIXEL TITLE STR0029
			oDlg:lEscClose := .F.

			@ 00,37 BITMAP oBMP RESOURCE "Techfin.bmp" OF oDlg PIXEL NOBORDER 
			oBmp:lAutoSize := .T. 		
			
			@ 37,29 SAY "[Gesplan] - UPDDISTR será executado em modo exclusivo " SIZE 200,20 OF oDlg PIXEL 
			@ 47,29 SAY "para criação dos campos da integração ." SIZE 200,20 OF oDlg PIXEL 					
			
			@59 , 10 say "Usuario" SIZE 200,20 OF oDlg PIXEL
			@ 59, 32 MSGET cUSer SIZE 45, 09 OF oDlg PIXEL WHEN .T. 
			@ 59 , 81 say "Senha" SIZE 200,20 OF oDlg PIXEL
			@ 59, 104 GET oSenha VAR cSenha PASSWORD  SIZE 45, 09 OF oDlg PIXEL WHEN .T.
			@ 75,10 CHECKBOX oChkBox VAR lok PROMPT "Estou Ciente!" SIZE 60,15 OF oDlg PIXEL 

			@ 85,40 BUTTON oButton PROMPT STR0030 OF oDlg PIXEL ACTION Iif(lok .and. VldStepUsr(Alltrim(cUSer),Alltrim(cSenha)) , oDlg:End(), Nil )

			ACTIVATE MSDIALOG oDlg CENTERED
			iF lok
				If (lRet:=MyOpenSm0Ex())
					FWMsgRun(,{|| lRet:=WzGerGes(aGrpEmp,Alltrim(cSenha))},STR0040,STR0039 )  //"Processando"  "Compatibilizando ambiente..."
					__cInternet		:= Nil
					oApp:cInternet	:= Nil
				EndIf
			EndIf
		Else
			//"A data dos fontes FINXFIN.PRW e FINXNAT.PRW deve ser superior ou igual a 07/11/2022. Atualize a lib para poder prosseguir.", "Integração Gesplan"
			MessageBox(STR0054, STR0053 , 0) 
			lRet:=.F.
		EndIF
	Else
		DEFINE MSDIALOG oDlg FROM 0,0 TO 200,380 STYLE DS_MODALFRAME PIXEL TITLE STR0029
		oDlg:lEscClose := .F.

		@ 00,37 BITMAP oBMP RESOURCE "Techfin.bmp" OF oDlg PIXEL NOBORDER
		oBmp:lAutoSize := .T.

		@ 37,29 SAY "Por favor verifique a compartilhamento dos Cadastros" SIZE 200,20 OF oDlg PIXEL
		@ 47,29 SAY "Os parâmetros foram criados de maneira Compartilhada" SIZE 200,20 OF oDlg PIXEL
		@ 57,29 SAY "Principalmente os cadastros de Natureza e Fornecedor" SIZE 200,20 OF oDlg PIXEL

		@ 75,29 CHECKBOX oChkBox VAR lCheck PROMPT "Estou Ciente!" SIZE 60,15 OF oDlg PIXEL

		@ 85,70 BUTTON oButton PROMPT STR0030 OF oDlg PIXEL ACTION Iif(lCheck, oDlg:End(), "")

		ACTIVATE MSDIALOG oDlg CENTERED
    EndIf

Return lRet

/*/{Protheus.doc} SetAction
Função executada ao clicar no botão Pesquisar ou Incluir.
Esta função é responsável por chamar o MBrowse ou AxInclui.

@param cTabOri, character, tabela que será utilizada
@param lPesquisa, logical, informa se a ação é de pesquisa

@author  Claudio Yoshio Muramatsu
@since   01/11/2022
/*/
Static Function SetAction(cTabOri As Character, lPesquisa As Logical)
	Local aArea      As Array
	Local cFilBrowse As Character

	Private aRotina   As Array
	Private cCadastro As Character
	Private cTabAlias As Character

	Default lAutomato := .F.
	
	aArea      := GetArea()
	cFilBrowse := ""

	cCadastro := ""
	aRotina   := MenuDef()
	cTabAlias := cTabOri

	If cTabAlias == "SED"
		cCadastro  := STR0046 //"Configuração da Natureza"
		cFilBrowse := "ED_FILIAL == '" + xFilial("SED") + "'"
	ElseIf cTabAlias == "SA2"
	 	cCadastro := STR0047 //"Configuração do Fornecedor"
		cFilBrowse := "A2_FILIAL == '" + xFilial("SA2") + "'"
	ElseIf cTabAlias == "FKC"
	 	cCadastro := STR0048 //"Configuração do Valor Acessório"
		cFilBrowse := "FKC_FILIAL == '" + xFilial("FKC") + "'"
	EndIf

	If lPesquisa
		mBrowse(6,1,22,75,cTabAlias,,,,,,,,,,,,,,,,,,cFilBrowse)
	Else
		WizTFInclu()
	EndIf

	RestArea( aArea )

	FWFreeArray( aArea )
	FWFreeArray( aRotina )
Return

/*/{Protheus.doc} SetFldEnch
Função responsável em atribuir um conteúdo padrão aos campos da enchoice.

@author  Claudio Yoshio Muramatsu
@since   01/11/2022
/*/
Static Function SetFldEnch()
	Local aContent As Array
	Local nItem    As Numeric

	aContent := {}
	nItem    := 0

	If cTabAlias == "SED"
		aContent := { ;
						{ 'ED_CODIGO' , 'MAISPRAZO' }, ;
						{ 'ED_DESCRIC', 'MAIS PRAZO' }, ;
						{ 'ED_COND'   , 'D' } }
	ElseIf cTabAlias == "SA2"
		// Nunca traduzir estes dados, pois são os dados de cadastro da Supplier
		aContent := { ;
						{ 'A2_COD'    , 'SUPPLI' }, ;
						{ 'A2_LOJA'   , '01' }, ;
						{ 'A2_NOME'   , 'CARTAO DE COMPRA SUPPLIERCARD FUNDO DE INVESTIMENTO EM DIREITOS CREDITORIOS' }, ;
						{ 'A2_NREDUZ' , 'SUPPLIER' }, ;
						{ 'A2_CGC'    , '08692888000182' }, ;
						{ 'A2_END'    , 'AV DAS AMERICAS, 500' }, ;
						{ 'A2_COMPLEM', 'BL13 GRUPO 205 - COD. DOWNTOWN' }, ;
						{ 'A2_MUN'    , 'RIO DE JANEIRO' }, ;
						{ 'A2_BAIRRO' , 'BARRA DA TIJUCA' }, ;
						{ 'A2_EST'    , 'RJ' }, ;
						{ 'A2_CEP'    , '22640100' }, ;
						{ 'A2_TIPO'   , 'J' }, ;
						{ 'A2_INSCR'  , 'ISENTO' } }
	ElseIf cTabAlias == "FKC"
		aContent := { ;
						{ 'FKC_CODIGO' , 'MP0001' }, ;
						{ 'FKC_DESC'   , 'VA MAIS PRAZO' }, ;
						{ 'FKC_ACAO'   , '1' }, ;
						{ 'FKC_TPVAL'  , '2' }, ;
						{ 'FKC_APLIC'  , '3' }, ;
						{ 'FKC_PERIOD' , '1' }, ;
						{ 'FKC_ATIVO'  , '1' }, ;
						{ 'FKC_RECPAG' , '1' }, ;
						{ 'FKC_VARCTB' , 'MPR001' } }	
	EndIf

	For nItem := 1 to Len(aContent)
		M->&(aContent[nItem][1]) := aContent[nItem][2]
	Next

	FWFreeArray(aContent)
Return Nil

/*/{Protheus.doc} MenuDef
Menu funcional da rotina de cadastros (Natureza, Fornecedor, Valores Acessórios)

@type  Static Function
@author Daniel Moda
@since 19/07/2022
@return aRotina, Array, Opções do Menu
/*/
Static Function MenuDef() As Array
	Local aRotina As Array

	aRotina := {{"Selecionar" ,"WizTFSelec" ,0, 6, 0, Nil},; //"Selecionar"
				{"Visualizar" ,"AxVisual"   ,0, 2, 0, Nil}}  //"Visualizar"
Return aRotina

/*/{Protheus.doc} WizTFSelec
Botão chamado quando é selecionado um cadastro no Mbrowse
@type  Function
@author Claudio Yoshio Muramatsu
@since 01/11/2022
@return Nil
/*/
Function WizTFSelec()
	SetParamVar()	
	CloseBrowse()
Return Nil

/*/{Protheus.doc} WizTFInclu
Botão chamado na inclusão de um cadastro no Mbrowse
@type  Function
@author Claudio Yoshio Muramatsu
@since 01/11/2022
@return Nil
/*/
Function WizTFInclu()
	Local aParam  As Array

	aParam := Array(4)
	aParam[1] := {|| SetFldEnch()}
	aParam[2] := {|| .T. }
	aParam[3] := {|| .T. }
	aParam[4] := {|| .T. }
	
	If AxInclui( cTabAlias, , , , , , "WizTFTudOk()", , , , aParam ) == 1
		SetParamVar()
		If cTabAlias == "SED"
			lExistSED := .T.
		ElseIf cTabAlias == "SA2"
			lExistSA2 := .T.
		ElseIf cTabAlias == "FKC"
			lExistFKC := .T.
		EndIf
	EndIf

	FwFreeArray(aParam)
Return

/*/{Protheus.doc} SetParamVar
Atribui valor nas variáveis da tela com o conteúdo do registro selecionado

@type  Function
@author Claudio Yoshio Muramatsu
@since 01/11/2022
@return Nil
/*/
Static Function SetParamVar()
	If cTabAlias == "SED"
		cNat := SED->ED_CODIGO
	ElseIf cTabAlias == "SA2"
		cForn := SA2->A2_COD
		cLoja := SA2->A2_LOJA
	ElseIf cTabAlias == "FKC"
		cCodVa := FKC->FKC_CODIGO
	EndIf
Return

/*/{Protheus.doc} WizTFTudOk
Função para validação na confirmação da inclusão dos cadastros

@type  Function
@author Claudio Yoshio Muramatsu
@since 01/11/2022
@return boolean, indica se o registro em questão existe no banco de dados.
/*/
Function WizTFTudOk() As Logical
	Local lRet As Logical
	
	lRet := .T.

	If (cTabAlias == "SED" .And. CheckParam(cTabAlias,{M->ED_CODIGO})) .Or. ;
	   (cTabAlias == "SA2" .And. CheckParam(cTabAlias,{M->A2_COD,M->A2_LOJA})) .Or. ;
	   (cTabAlias == "FKC" .And. CheckParam(cTabAlias,{M->FKC_CODIGO}))
		
		lRet := .F.
		Help(" ", 1, "CADEXISTE",, STR0049, 1, 0) //"Já existe um cadastro com a chave informada."
	EndIf
Return lRet

/*/{Protheus.doc} CheckParam
Função que verifica se o registro existe no banco de dados.

@param aInfo, array, armezena os dados da entidade a ser pesquisada
@return boolean, indica se o registro em questão existe no banco de dados.
@author  Claudio Yoshio Muramatsu
@since   01/11/2022
/*/
Static Function CheckParam(cTabOri As Character, aInfo As Array)
	Local aArea      As Array
	Local cQuery     As Character
	Local cTempAlias As Character
	Local lExist     As Logical

	aArea      := GetArea()
	cQuery     := ""
	cTempAlias := ""
	lExist     := .F.

	If cTabOri == "SED"
		cQuery := "SELECT ED_CODIGO FROM " + RetSqlName("SED") + ;
			" WHERE ED_FILIAL = '" + xFilial("SED") + "' " + ;
			" AND ED_CODIGO = '" + aInfo[ 1 ] + "' " + ;
			" AND D_E_L_E_T_ = ' '"
	ElseIf cTabOri == "SA2"
		cQuery := "SELECT A2_COD FROM " + RetSqlName("SA2") + ;
			" WHERE A2_FILIAL = '" + xFilial("SA2") + "' " + ;
			" AND A2_COD = '" + aInfo[ 1 ] + "' " + ;
			" AND A2_LOJA = '" + aInfo[ 2 ] + "' " + ;
			" AND D_E_L_E_T_ = ' '"
	ElseIf cTabOri == "FKC"
		cQuery := "SELECT FKC_CODIGO FROM " + RetSqlName("FKC") + ;
			" WHERE FKC_FILIAL = '" + xFilial("FKC") + "' " + ;
			" AND FKC_CODIGO = '" + aInfo [ 1 ] + "' " + ;
			" AND D_E_L_E_T_ = ' '"
	EndIf

	IF !Empty(cQuery)
		cQuery := ChangeQuery(cQuery)

		cTempAlias := MPSysOpenQuery(cQuery)
		If (cTempAlias)->(!Eof())
			lExist := .T.
		EndIf
		(cTempAlias)->(DbCloseArea())
	EndIf

	RestArea(aArea)
	FWFreeArray(aArea)
Return lExist

/*/{Protheus.doc} IncMotBx
Inclui o motivo de baixa que será utilizado no Mais Prazo

@return Logico, Verdadeiro se for incluído.
@author Claudio Yoshio Muramatsu
@since  01/11/2022
/*/
Static Function IncMotBx() As Logical
	Local aArea      As Array
	Local aCampos    As Array
	Local aMotBaixas As Array
	Local cFile	     As Character
	Local lRet       As Logical

	aArea      := GetArea()
	aCampos    := {}
	aMotBaixas := {}
	cFile	   := "SIGAADV.MOT"
	lRet       := .T.

	// Executa a função de leitura das baixas para forçar a criação do arquivo, caso não exista.
	aMotBaixas := ReadMotBx()

	aCampos:={	{"SIGLA"	, "C", 03, 0 },;
				{"DESCR"	, "C", 10, 0 },;
				{"CARTEIRA"	, "C", 01, 0 },;
				{"MOVBANC"	, "C", 01, 0 },;
				{"COMIS"	, "C", 01, 0 },;
				{"CHEQUE"	, "C", 01, 0 },;
				{"ESPECIE"	, "C", 01, 0 }	}

	_oFINA4901 := FWTemporaryTable():New( "cArqTmp" )
	_oFINA4901:SetFields( aCampos )
	_oFINA4901:Create()

	cAlias := "cArqTmp"
	dbSelectArea( cAlias )

	APPEND FROM &cFile SDF
	DbGoTop()

	While CARQTMP->( !Eof() )
		If CARQTMP->SIGLA == 'MPR'
			lRet := .F.
			Exit
		EndIf

		CARQTMP->( dbSkip() )
	End

	If ( lRet )

		lRet := .F.

		BEGIN TRANSACTION
			RecLock( cAlias , .T. )
			CARQTMP->Sigla    := DEFAULT_MOTBX //MPR
			CARQTMP->Descr    := DEFAULT_DESC_MOTBX //MAIS PRAZO
			CARQTMP->Carteira := "P"
			CARQTMP->MovBanC  := "N"
			CARQTMP->Comis    := "N"
			CARQTMP->Cheque   := "N"
			CARQTMP->Especie  := "N"
			MsUnLock()

			dbSelectArea( "cArqTmp" )
			FERASE( cFile )
			Copy to &cFile SDF

			lRet := .T.
		END TRANSACTION
	Endif

	RestArea( aArea )

	FWFreeArray( aCampos )
	FWFreeArray( aArea )
	FWFreeArray( aMotBaixas )

	FwFreeObj( _oFINA4901 )
Return lRet

/*{Protheus.doc} WzGerGes
Executa UPDDISTR para criação de MSUID na SEV e SEZ

@author: TOTVS
@since 21/09/2022
@version 1.0
*/
Static Function WzGerGes(aGrpEmp As Array, cSenha As Character) As Logical

Local oX31 		As Object
Local nI     	As Numeric
Local nJ     	As Numeric
Local lContinua As Logical
Local cMsg		As Character
Local cVlr 		As Character
Local cGrpEmp  	As Character
Local cPath	 	As Character
Local cCodPrj	As Character
Local cArquivo 	As Character
Local nHandle 	As Numeric
Local nTamanho	As Numeric
Local aCols 	As Array
Local aMarkedGrp As Array

nI     		:= 0
nJ     		:= 0 
lContinua 	:= .F.
cMsg		:= STR0035//"Classe necessária não encontrada. Atualize a versão da LIB."
cVlr 		:= ''
cGrpEmp  	:= ''
cCodPrj		:= ''
cPath	 	:= GetSystemLoadDir()
cArquivo 	:= cPath+"upddistr_param.json"
nHandle		:= 0
nTamanho 	:= If(AllTrim(Upper(TCGetDB())) == "ORACLE", 32, 36) 
aCols 		:= {{"EZ_MSUID","SEZ"},{"EV_MSUID","SEV"}}
aMarkedGrp	:= {}

For nI:=1 to Len(aGrpEmp)
	If aGrpEmp[nI,1]
		Aadd(aMarkedGrp,aGrpEmp[nI,2])
	EndIF
Next nI

RpcSetType(3)
RpcSetEnv(aMarkedGrp[1])

If !SuperGetMv("MV_PRJOVER",.F.,.F.) .Or. !SuperGetMv("MV_FINTGES",.F.,.F.)
	MessageBox(STR0037,STR0038, 0) // "Parâmetros MV_PRJOVER e MV_FINTGES (tipo L) não encontrados ou com conteúdo F.", "Crie ou ative esse parâmetro para prosseguir."
	Return .F.
EndIF

aEval( aMarkedGrp, {|x| Iif( !(x $ cGrpEmp) ,(cGrpEmp += x +'","'), Nil)}) 

cVlr += '{'
cVlr += '    "password":"'+alltrim(cSenha)+'",'
cVlr += '    "simulacao":false,'
cVlr += '    "localizacao":"BRA",'
cVlr += '    "sixexclusive":true,'
cVlr += '    "empresas":["'+Substr(cGrpEmp,1,Len(cGrpEmp)-3)+'"],' //empresas":["T1","T2"],
cVlr += '    "logprocess":true,'
cVlr += '    "logatualizacao":true,'
cVlr += '    "logwarning":true,'
cVlr += '    "loginclusao":true,'
cVlr += '    "logcritical":true,'
cVlr += '    "updstop":false,'
cVlr += '    "oktoall":true,'
cVlr += '    "deletebkp":false,'
cVlr += '    "keeplog":true'
cVlr += '    }'

If File(cArquivo)
	FErase(cArquivo)
EndIf	
If (nHandle := MSFCreate(cArquivo,0)) == -1
	MessageBox(STR0042, STR0041 ,0)//"Falha no processamento" "Falha na criação do dicionário diferencial"
    Return .F.
EndIf
    
FWrite(nHandle,cVlr+CRLF)
FClose(nHandle)

If FindClass("MPX31Field") 

	oX31 := MPX31Field():New("Inclusao de Campos MSUID") //"Inclusao de Campos MSUID"

	If MethIsMemberOf( oX31, 'CreateUUID')

		If File(cPath+'sdfbra.txt') 
			FErase(cPath+'sdfbra.txt')
		EndIf
		For nI := 1 to Len(aCols)
		    If !ExistDir("\cfglog")
                MakeDir("\cfglog")
            EndIf

            oX31:SetAlias(aCols[nI,2])
            oX31:CreateUUID()
            oX31:SetSize(nTamanho)
            oX31:SetOverWrite(.T.)
            If oX31:VldData()
                oX31:CommitData()
                lContinua := .T. 
            EndIf
		Next
		
		If lContinua	
			cCodPrj:=oX31:oPrjResult:cCodProj
			lRetDif:=FWGnFlByTp(cCodPrj,cPath) 

			If lRetDif
                DBCloseAll()
                StartJob("UPDDISTR",GetEnvServer(),.T.)
                For nJ := 1 to len(aMarkedGrp)
                   StartJob("WizGrvGes",GetEnvServer(),.T., aMarkedGrp[nJ] ) 
                Next    
			EndIf		
		EndIf

		FreeObj(oX31)
		oX31 := Nil	
	EndIf
EndIf

FErase(cArquivo)

Return lContinua

/*{Protheus.doc} WizGrvGes
Grava o UUID nos campos do rateio

@author: Fabio Zanchim
@since 06/08/2021
@version 1.0
*/
Function WizGrvGes(cGrpEmp As Character)

Local cSQL 		 As Character
Local cAliasQry  As Character
Local lFormatUID As Logical

RpcSetType(3)
RpcSetEnv(cGrpEmp,,,,,,{'SEV','SEZ'})

cSQL 		:= ""
cAliasQry 	:= GetNextAlias()
lFormatUID 	:= If(AllTrim(Upper(TCGetDB())) == "ORACLE", .F., .T.) 

//--------------------------------------
// Rateio Natureza
dbSelectArea('SEV')
If FieldPos('EV_MSUID') > 0 
	cSQL := "select SEV.R_E_C_N_O_ REC FROM "+ RetSqlName("SE1")
	cSQL += "    INNER JOIN "+ RetSqlName("SEV")  +" SEV"
	cSQL += "        ON EV_FILIAL=E1_FILIAL AND EV_PREFIXO=E1_PREFIXO AND EV_NUM=E1_NUM AND EV_PARCELA=E1_PARCELA   " 
	cSQL += "                                AND EV_TIPO=E1_TIPO AND EV_CLIFOR=E1_CLIENTE AND EV_LOJA=E1_LOJA AND EV_RECPAG='R' "
	cSQL += " WHERE E1_EMISSAO>='"+Str(Year(Date())-2,4)+"0101'" 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cAliasQry,.T.,.T.)
	WizGrvReg(cAliasQry,'SEV','EV_MSUID',lFormatUID)
	(cAliasQry)->(dbCloseArea())

	cSQL := "select SEV.R_E_C_N_O_ REC FROM "+ RetSqlName("SE2")
	cSQL += "    INNER JOIN "+ RetSqlName("SEV")  +" SEV" 
	cSQL += "        ON EV_FILIAL=E2_FILIAL AND EV_PREFIXO=E2_PREFIXO AND EV_NUM=E2_NUM AND EV_PARCELA=E2_PARCELA   " 
	cSQL += "                                AND EV_TIPO=E2_TIPO AND EV_CLIFOR=E2_FORNECE AND EV_LOJA=E2_LOJA AND EV_RECPAG='P'  "
	cSQL += " WHERE E2_EMISSAO>='"+Str(Year(Date())-2,4)+"0101'" 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cAliasQry,.T.,.T.)
	WizGrvReg(cAliasQry,'SEV','EV_MSUID',lFormatUID)
	(cAliasQry)->(dbCloseArea())
EndIf
//--------------------------------------
// Rateio C.Custo
dbSelectArea('SEZ')
If FieldPos('EZ_MSUID') > 0 
	cSQL := " select SEZ.R_E_C_N_O_ REC FROM "+ RetSqlName("SE1")     
	cSQL += " INNER JOIN "+ RetSqlName("SEZ")  +" SEZ"
	cSQL += " ON EZ_FILIAL=E1_FILIAL AND EZ_PREFIXO=E1_PREFIXO AND EZ_NUM=E1_NUM AND EZ_PARCELA=E1_PARCELA    "
	cSQL += "							AND EZ_TIPO=E1_TIPO AND EZ_CLIFOR=E1_CLIENTE AND EZ_LOJA=E1_LOJA AND EZ_RECPAG='R' "
	cSQL += " WHERE E1_EMISSAO>='"+Str(Year(Date())-2,4)+"0101'" 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cAliasQry,.T.,.T.)
	WizGrvReg(cAliasQry,'SEZ','EZ_MSUID',lFormatUID)
	(cAliasQry)->(dbCloseArea())

	cSQL := " select SEZ.R_E_C_N_O_ REC FROM "+ RetSqlName("SE2")     
	cSQL += " INNER JOIN "+ RetSqlName("SEZ")  +" SEZ"
	cSQL += " ON EZ_FILIAL=E2_FILIAL AND EZ_PREFIXO=E2_PREFIXO AND EZ_NUM=E2_NUM AND EZ_PARCELA=E2_PARCELA    "
	cSQL += "							AND EZ_TIPO=E2_TIPO AND EZ_CLIFOR=E2_FORNECE AND EZ_LOJA=E2_LOJA AND EZ_RECPAG='P' "
	cSQL += " WHERE E2_EMISSAO>='"+Str(Year(Date())-2,4)+"0101'" 

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cAliasQry,.T.,.T.)
	WizGrvReg(cAliasQry,'SEZ','EZ_MSUID',lFormatUID)
	(cAliasQry)->(dbCloseArea())
EndIF

//--------------------------------------
// Habilita controle da integração.
PUTMV('MV_FINTGES', .T.)

Return


/*{Protheus.doc} WizGrvReg
Grava campo MSUID

@author: Fabio Zanchim
@since 21/09/2022
@version 1.0
*/
Static Function WizGrvReg(cAliasQry As Character,cTabela As Character,cCpoUUID As Character,lFormatUID As Logical)

	(cAliasQry)->(dbGoTop())
	DbSelectArea((ctabela))
	While !(cAliasQry)->(Eof())
		(ctabela)->(dbGoTo((cAliasQry)->REC))
		If Empty(&(ctabela+"->"+cCpoUUID))
			RecLock(ctabela,.F.)
			&(ctabela+"->"+cCpoUUID) := FWUUIDV4(lFormatUID)
			(ctabela)->(MsUnlock())
		EndIF
		(cAliasQry)->(dbSkip())
	EndDo

Return

/*{Protheus.doc} VldStepUsr
Valida a senha do admin para prosseguir

@author: Fabio Zanchim
@since 21/09/2022
@version 1.0
*/
Static Function VldStepUsr(cUser As Character,cPass As Character) As Logical
	
	Local lRet As logical
	lRet := .F.	

	If FWIsAdmin(cUser) //Verifica se usuario é Admin
		PswOrder(2)
		If PswSeek(cUser)
			lRet := PswName(cPass)// Valida senha do usuario
		EndIf
	EndIF

	If !lRet
		MessageBox("Senha inválida.", "Atenção" , 0) 
	EndIf

Return lRet 

/*{Protheus.doc} MyOpenSM0Ex
Abre arquivo de empresas em modo exclusivo

@author: Fabio Zanchim
@since 21/09/2022
@version 1.0
*/
Static Function MyOpenSM0Ex() As Logical

Local lOpen As Logical
Local nLoop As Numeric

lOpen := .F. 
nLoop := 0 

For nLoop := 1 To 5
	OpenSM0Excl() 
	If !Empty( Select( "SM0" ) ) 
		lOpen := .T. 
		dbSetOrder(1)
		Exit	
	EndIf
Next nLoop                                

Return( lOpen )
