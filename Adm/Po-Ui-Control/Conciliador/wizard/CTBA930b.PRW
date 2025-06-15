#Include "CTBA930B.ch"
#INCLUDE "protheus.ch"
#INCLUDE "apwizard.ch"

/*{Protheus.doc} CriaUUID
Cria os campos _MSUID para uso no conciliador contábil
Os campos devem ser criados a partir da configuração 
feita na tabela QLB

@author: TOTVS
@since 06/08/2021   
@version 1.0
*/
Function CTBA930b() 
Local aSM0		:= {}
Local aHeader	:= {}
Local aCols 	:= {}
Local lWizFinal := .F.
local cMens		:=	STR0001 + CRLF +; //"Essa rotina exportará um arquivo SDF para atualização do dicionários de dados."
					STR0002 + CRLF +; //"Serão criados campos de ID para uso na rotina de conciliação."
					STR0003 //"Os campos serão criados com base nas tabelas cadastradas na tabela: QLB - Chaves."
Local lVldDic   := .F.
Local cEmpAux := ""
Local cFilAux := ""

Private oWizard
Private lContinua  := .T.
Private lCriouSDF  := .F.
Private cListTab   := ""

RptStatus({|| lVldDic := C930IniDad(aHeader,aCols,aSM0) },STR0005, STR0004) //"Preparando os dados para o wizard..." //"Aguarde..."

If lVldDic

	cEmpAux := cEmpAnt
	cFilAux := cFilAnt
	
	//Painel 1 - Tela inicial do Wizard
	oWizard := APWizard():New(STR0006/*<chTitle>*/,; //"Conciliador - Wizard de Configuração"
	STR0007/*<chMsg>*/, ""/*<cTitle>*/, ;  //"Exportação do arquivo SDF para criação dos campos _MSUID"
	cMens, ;
	{||.T.} /*<bNext>*/ ,;
	{||.T.}/*<bFinish>*/,;
	.T./*<.lPanel.>*/, , , /*<.lNoFirst.>*/)

	//Painel 2 - Definição das Novas Entidades
	oWizard:NewPanel(STR0006/*<chTitle>*/,; //"Conciliador - Wizard de Configuração"
	STR0007/*<chMsg>*/,; //"Exportação do arquivo SDF para criação dos campos _MSUID"
	{||.T.}/*<bBack>*/,;
	{|| VldTabQLB(aCols)} /*<bNext>*/ ,;
	{||.T.}/*<bFinish>*/,;
	.T./*<.lPanel.>*/ ,;
	{|| C930GDQLB(aHeader,aCols,aSM0)}/*<bExecute>*/) //Montagem da tela


	//Painel 3 - Acompanhamento do Processo
	oWizard:NewPanel(STR0008/*<chTitle>*/,; //"Processamento..."
	STR0007/*<chMsg>*/,; //"Exportação do arquivo SDF para criação dos campos _MSUID"
	{||.F.} /*<bBack>*/,;
	{||.F.}/*<bNext>*/ ,;
	{||(lWizFinal := .T., .T.)}/*<bFinish>*/,;
	.T./*<.lPanel.>*/ ,;
	{|| WizGerSDF(aCols)}/*<bExecute>*/)

	oWizard:Activate( .T./*<.lCenter.>*/,;
	{||.T.}/*<bValid>*/,;
	{||.T.}/*<bInit>*/,;
	{||.T.}/*<bWhen>*/)

	If lCriouSDF .And. lWizFinal
		
		If MsgYesNo(STR0009+CRLF+STR0010,STR0011 ) //"Será necessário acesso exclusivo ao sistema." //"Deseja executar o UPDDISTR agora?" //"Atenção"
			RpcClearEnv()
			UPDDISTR()		
		EndIf
	EndIf
EndIf

Return

/*{Protheus.doc} VldTabQLB
Valida se pode avançar para a próxima tela

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function VldTabQLB(aCols)
Local aArea := GetArea()
Local lRet	:= .T.
Local cPath	 := GetSystemLoadDir()
Local cLocFiles := GetSrvProfString("StartSysInDB","undefined")

If GetRPORelease() < "12.1.2210"
	If ExistDir(cPath+"cfglog") .And. cLocFiles == "undefined"
		C930MsgBox(STR0029) //"Para prosseguir renomeie a pasta cfglog, localizado dentro da pasta protheus_data."
		lRet := .F.
	EndIf
EndIf

If lRet
	If Len(aCols) > 0
		If FILE(cPath+'sdfbra.txt') 
			lRet := MsgYesNo(STR0013+CRLF+STR0012 ,STR0011) //"Deseja sobrescrever?" //"Atenção" //"Já existe um arquivo SDF na pasta systemload."
			If lRet
				FERASE(cPath+'sdfbra.txt')
				FERASE(cPath+'manifest_update.txt')
			EndIf
		EndIf
	Else
		C930MsgBox(STR0014)  //"Não foram encontrados registros na tabela QLB."
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)

Return lRet

/*{Protheus.doc} WizCriaSDF
Cria o SDF para inclusão dos capos MSUID

@author: TOTVS
@since 06/08/2021  
@version 1.0
*/
Static Function WizGerSDF(aCols)
Local oX31
Local oPanel := oWizard:oMPanel[oWizard:nPanel]
Local oFont  := TFont():New(,,-14,,, )
Local nI     := 0
Local cCposOk:= ""
Local lContinua := .F. // Se todos os campos já foram incluídos não prossegue
Local lMsgErro  := .F.
Local lRetDif:= .F.
// Alterado função conforme sugestão do Sandro (Frame)
Local cBarra := If(issrvunix(), "/", "\")
Local cPath	 := GetSystemLoadDir()
Local cSNome := ""
Local cFileTxt := ""
Local nTamanho := If(AllTrim(Upper(TCGetDB())) == "ORACLE", 32, 36)
local tmp 	   := getTempPath()
local targetDir:= ""

If FindClass("MPX31Field")

	oX31 := MPX31Field():New(STR0015) //"Inclusao de Campos MSUID"

	If MethIsMemberOf( oX31, 'CreateUUID')

		For nI := 1 to Len(aCols)
			
			If aCols[nI,6]=="Ok"
				Loop
			EndIf

			If !aCols[nI,3] $ cCposOk				
				cCposOk += aCols[nI,3]+"|"
				cSNome := AllTrim(aCols[nI,3])	

				If !ExistDir(cPath+"cfglog")
					MakeDir(cPath+"cfglog")
				EndIf			

				oX31:SetAlias(aCols[nI,2])
				oX31:CreateUUID(SubStr(cSNome, Len(cSNome)))
				oX31:SetSize(nTamanho)
				
				If oX31:VldData()
					oX31:CommitData()
					lContinua := .T.
				Else	
					oSay1:= TSay():New(020,010,{||STR0030},oPanel,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) //"Falha na criação do dicionário diferencial"
					C930MsgBox(STR0017+aCols[nI,3]) //"Erro na criação do campo: "
					lContinua := .F. //Se der erro em algum item não prossigo
					lMsgErro := .T.
					Exit
				EndIf
			EndIf
		Next
		
		If lContinua	
			cCodPrj:=oX31:oPrjResult:cCodProj
			// Cria arquivo texto para verficar se usuário tem permissão na pasta
			cFileTxt := cPath+"conciliador.txt"
			nHandle := MsFCreate(cFileTxt)

			If nHandle < 0
				// Verifica se tem permissão na pasta
				If cValToChar( FError() ) == "13"
					C930MsgBox(STR0024) // "Sem permissão de acesso ao diretório, verifique!"
					oSay1:= TSay():New(020,010,{||STR0030},oPanel,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) //"Falha na criação do dicionário diferencial"
					lContinua := .F. //Se der erro em algum item não prossigo
				EndIf
			Else
				lRetDif := FWGnFlByTp(cCodPrj,cPath) // Crio o arquivo diferencial
				If !lRetDif		
					FWAtuStatus("1", cCodPrj)
					If MsgYesNo(STR0030+CRLF+STR0031,STR0011 ) //"Falha na criação do dicionário diferencial" //"Deseja selecionar uma pasta deferente para salvar o arquivo?" //"Atenção"
						targetDir := tFileDialog( "All Text files (*.txt) ",STR0032,, tmp, .F., GETF_RETDIRECTORY) //"Seleção de Arquivos"
						lRetDif := FWGnFlByTp(cCodPrj,targetDir+cBarra) // Crio o arquivo diferencial
						lContinua := .F. //Se der erro em algum item não prossigo
					EndIf
					If !lRetDif
						oSay1:= TSay():New(020,010,{||STR0030},oPanel,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,220,25) //"Falha na criação do dicionário diferencial"
						lContinua := .F. //Se der erro em algum item não prossigo
					Else
						oSay1:= TSay():New(020,010,{||STR0033},oPanel,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,220,25) //"Arquivo gerado com sucesso, copie o arquivo para dentro da pasta systemload e rode o UPDDISTR para criação dos campos"
						C930MsgBox(STR0033) //"Arquivo gerado com sucesso, copie o arquivo para dentro da pasta systemload e rode o UPDDISTR para criação dos campos"
					EndIf
				EndIf
			End

			FClose(nHandle)
			// Apago o arquivo
			If File(cFileTxt)				
				FERASE(cFileTxt)
			EndIf

			If lContinua .And. File(cPath+"sdfbra.txt")
				oSay1:= TSay():New(020,010,{||STR0018},oPanel,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) //"Arquivo SDF exportado com sucesso para a pasta systemload."
				lCriouSDF := .T.
			EndIf
		ElseIf !lMsgErro
			C930MsgBox(STR0019) //"Não existem campos para exportação."
		EndIf

		FreeObj(oX31)
		oX31 := Nil
	Else
		C930MsgBox(STR0020) //"Classe necessária não encontrada. Atualize a versão da LIB."
	EndIf
EndIf

If lContinua
	C930MsgBox(STR0021) //"Processo de atualização finalizado"
EndIf
Return
