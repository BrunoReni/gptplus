#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"    
#INCLUDE "LOJA0046.CH"

// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA0046() ; Return
                            
/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJCFileServerConfigurationWizard  � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Assist�nte de configuara��o do servidor de arquivos do loja.           ���
���             �                                                                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJCFileServerConfigurationWizard
	Data oWizard
	Data oPanelConfiguration
	Data oPanelTest

	Data oBMPHC	
	Data oSayHC
	Data oMGPort
	Data cMGPort
	Data oMGEnvironment
	Data cMGEnvironment
	Data oBtnHCSetUp
	
	Data oBMPFS
	Data oSayFS
	Data oMGIP
	Data cMGIP
	Data oMGRepository
	Data cMGRepository
	Data oBtnFSPathSelect
	
	Data oBtnTest
	Data oSayTest
	Data oBMPTest

	Method New()
	Method Show()
	Method Initialize()
	Method PopulateConfiguration()
	Method UpdateHTTPConfiguration()
	Method UpdateConnectionTest()
	Method ButtonClick()
	Method SetUpHC()
	Method TestFS()
	Method SelectRepositoryPath()
EndClass

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � New                               � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Construtor.                                                            ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method New() Class LJCFileServerConfigurationWizard
Return
                     
/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � Show                              � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Exibe o assist�nte de configura��o.                                    ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method Show() Class LJCFileServerConfigurationWizard
	Self:Initialize()
	
	ACTIVATE WIZARD Self:oWizard CENTERED VALID {|| .T. } 	
Return
                     
/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � Initialize                        � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Inicializa e configura os objetos que comp�em o assist�nte de          ���
���             � configura��o.                                                          ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method Initialize() Class LJCFileServerConfigurationWizard
	Local nHCRow	:= 0
	Local nHCCol	:= 0
	Local nFSRow	:= 0
	Local nFSCol	:= 0
	
	// Configura o tamanho dos Gets
	Self:cMGPort 		:= Space(20)
	Self:cMGEnvironment := Space(60)
	Self:cMGIP			:= Space(20)
	Self:cMGRepository	:= Space(60)
		

	DEFINE WIZARD Self:oWizard TITLE STR0001 HEADER STR0002 MESSAGE STR0003; // "Assistente de configura��o" "Assistente de configura��o do servidor de arquivos do Controle de Lojas" "Introdu��o"
			TEXT STR0004 + CRLF + CRLF + STR0005 PANEL ; // "Esse assistente lhe auxiar� na configura��o do servidor de arquivos utilizado no processo de transfer�ncia da carga inicial." "* Importante: A configura��o do servidor de arquivos do Controle de Lojas e do servidor HTTP � feita diretamente no .ini do Protheus, a configura��o existente ser� sobrescrita."
			NEXT {|| Self:PopulateConfiguration() } FINISH {|| .T.}				
			
	CREATE PANEL Self:oWizard HEADER STR0006 MESSAGE STR0007 PANEL; // "Assistente de configura��o do servidor de arquivos do Controle de Lojas" "Sess�es e configura��es do INI"
		BACK {|| .T.} NEXT {|| .T. } FINISH {|| .T.} EXEC {|| .T.}											
			
	Self:oPanelConfiguration := TPanel():New( 0, 0, , Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)], , , , , , 0, 0 )
	Self:oPanelConfiguration:Align := CONTROL_ALIGN_ALLCLIENT
	
	nPanelRow := 000
	nPanelCol := 000
	
	nHCRow := nPanelRow + 00
	nHCCol := nPanelCol + 90
	@ nHCRow	,nHCCol TO nHCRow+090,nHCCol+109 LABEL STR0008 PIXEL OF Self:oPanelConfiguration	 // "Configura��o HTTP"
	@ nHCRow+9	,nHCCol+8 Bitmap Self:oBMPHC RESOURCE "OK" Size 008,008 PIXEL ADJUST NO BORDER OF Self:oPanelConfiguration
	@ nHCRow+9	,nHCCol+20 Say Self:oSayHC Prompt "" Size 060,008 COLOR CLR_BLACK PIXEL OF Self:oPanelConfiguration   
	@ nHCRow+23	,nHCCol+12 Say STR0013 Size 028,008 COLOR CLR_BLACK PIXEL OF Self:oPanelConfiguration // "IP local:"
	@ nHCRow+22	,nHCCol+35 MsGet Self:oMGIP Var Self:cMGIP Size 060,009 COLOR CLR_BLACK Picture "@!" PIXEL OF Self:oPanelConfiguration	
	@ nHCRow+35	,nHCCol+6 Say STR0009 Size 028,008 COLOR CLR_BLACK PIXEL OF Self:oPanelConfiguration // "Porta Http:"
	@ nHCRow+34	,nHCCol+34 MsGet Self:oMGPort Var Self:cMGPort Size 060,009 COLOR CLR_BLACK Picture Replicate("9",Len(Self:cMGPort)) PIXEL OF Self:oPanelConfiguration	
	@ nHCRow+47	,nHCCol+8 Say STR0010 Size 025,008 COLOR CLR_BLACK PIXEL OF Self:oPanelConfiguration // "Ambiente:"
	@ nHCRow+46	,nHCCol+34 MsGet Self:oMGEnvironment Var Self:cMGEnvironment Size 060,009 COLOR CLR_BLACK Picture "@!" PIXEL OF Self:oPanelConfiguration	
	@ nHCRow+59	,nHCCol+3 Say STR0014 Size 030,008 COLOR CLR_BLACK PIXEL OF Self:oPanelConfiguration // "Reposit�rio:"	
	@ nHCRow+58	,nHCCol+34 MsGet Self:oMGRepository Var Self:cMGRepository Size 060,009 COLOR CLR_BLACK Picture "@!" PIXEL OF Self:oPanelConfiguration	
	@ nHCRow+57	,nHCCol+94 Bitmap Self:oBtnFSPathSelect Resource "bmpcons" Tooltip STR0015 Size 012,012 ON LEFT CLICK Self:ButtonClick( Self:oBtnFSPathSelect ) NOBORDER DESIGN PIXEL OF Self:oPanelConfiguration	// "Selecionar diret�rio"
	@ nHCRow+72	,nHCCol+56 Button Self:oBtnHCSetUp Prompt STR0011 Size 037,012 Action Self:ButtonClick( Self:oBtnHCSetUp ) PIXEL OF Self:oPanelConfiguration // "Configurar"
	@ nHCRow+72	,nHCCol+93 Say "*" Size 030,008 COLOR CLR_BLACK PIXEL OF Self:oPanelConfiguration	
	
	@ nPanelRow+123,nPanelCol+45 Say STR0017 Size 250,008 COLOR CLR_BLACK PIXEL OF Self:oPanelConfiguration // "* O servidor dever� ser reiniciado para que o HTTP seja iniciado e o teste executado."
	
	nFSTRow := nPanelRow+95
	nFSTCol := nPanelCol+45			
	
	@ nFSTRow+7	,nFSTCol+5 Say STR0018 Size 100,008 COLOR CLR_BLACK PIXEL OF Self:oPanelConfiguration // "Testar conex�o no servidor de arquivo:"
	@ nFSTRow+5	,nFSTCol+103 Button Self:oBtnTest Prompt STR0019 Size 037,012 Action Self:ButtonClick( Self:oBtnTest ) PIXEL OF Self:oPanelConfiguration // "Testar"
	@ nFSTRow+7	,nFSTCol+145 Bitmap Self:oBMPTest RESOURCE "OK" Size 008,008 PIXEL ADJUST NO BORDER OF Self:oPanelConfiguration
	@ nFSTRow+7	,nFSTCol+157 Say Self:oSayTest Prompt "" Size 060,008 COLOR CLR_BLACK PIXEL OF Self:oPanelConfiguration	
	
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � PopulateConfiguration             � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Inicializa e atualiza a tela com as configura��es do servidor de carga ���
���             � do loja.                                                               ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � .T.                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method PopulateConfiguration() Class LJCFileServerConfigurationWizard
	Self:UpdateHTTPConfiguration()
	Self:UpdateConnectionTest()
Return .T.
                  
/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � UpdateHTTPConfiguration           � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Atualiza a tela com as configura��es do servidor HTTP.                 ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method UpdateHTTPConfiguration() Class LJCFileServerConfigurationWizard
	Local oLJFSConfiguration := LJCFileServerConfiguration():New()
	
	// Valida a sess�o HTTP
	If oLJFSConfiguration:ValidHTTPSession() .And. oLJFSConfiguration:ValidHTTPJobResponse() .And. oLJFSConfiguration:ValidLJFileServerSession()
		Self:oBMPHC:SetBMP( "OK" )
		Self:oSayHC:SetText( STR0020 ) // "Configurado"
	Else
		Self:oBMPHC:SetBMP( "CANCEL" )	
		Self:oSayHC:SetText( STR0021 ) // "N�o configurado"
	EndIf
	
	Self:oMGPort:cText := PadR( oLJFSConfiguration:GetHTTPPort(), 20 )
	Self:oMGEnvironment:cText := PadR( oLJFSConfiguration:GetHTTPEnvironment(), 60 )
	Self:oMGIP:cText := PadR( oLJFSConfiguration:GetFSLocation(), 20 )
	Self:oMGRepository:cText := PadR( oLJFSConfiguration:GetPath(), 60 )
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � UpdateConnectionTest              � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Atualiza a tela com as informa��es do teste de conex�o com o servidor  ���
���             � de arquivos do loja.                                                   ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method UpdateConnectionTest() Class LJCFileServerConfigurationWizard
	If Self:TestFS()
		Self:oBMPTest:SetBMP( "OK" )
		Self:oSayTest:SetText( STR0022 ) // "Dispon�vel"
	Else
		Self:oBMPTest:SetBMP( "CANCEL" )
		Self:oSayTest:SetText( STR0023 ) // "N�o dispon�vel"
	EndIf
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � ButtonClick                       � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � M�todo chamado nos eventos de clique da tela.                          ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oSender: Inst�ncia do objeto que iniciou o evento de clique.           ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method ButtonClick( oSender ) Class LJCFileServerConfigurationWizard	
	If oSender == Self:oBtnHCSetUp
		Self:SetUpHC()
	ElseIf oSender == Self:oSayTest
		Self:UpdateConnectionTest()
	ElseIf oSender == Self:oBtnFSPathSelect
		Self:SelectRepositoryPath()
	ElseIf oSender == Self:oBtnTest
		Self:UpdateConnectionTest()
	EndIf
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � SetUpHC                           � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Configura o servidor HTTP de acordo com o configurado pelo usu�rio     ���
���             � atrav�s do assist�nte.                                                 ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method SetUpHC() Class LJCFileServerConfigurationWizard
	Local oLJFSConfiguration := LJCFileServerConfiguration():New()
	
	oLJFSConfiguration:SetUpFileServer( Self:oMGIP:cText , Val(Self:oMGPort:cText), Self:oMGEnvironment:cText, Self:oMGRepository:cText )
	
	Self:UpdateHTTPConfiguration()
Return
                                          
/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � TestFS                            � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Efetua o teste de conex�o com o servidor de arquivos do loja.          ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method TestFS() Class LJCFileServerConfigurationWizard	
	Local oLJFSConfiguration 	:= LJCFileServerConfiguration():New()
	Local lTestResult			:= .F.
	
	lTestResult := oLJFSConfiguration:TestConnection()
		
Return lTestResult

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � SelectRepositoryPath              � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Auxilia o usu�rio na sele��o do caminho onde ser�o armazenados os      ���
���             � arquivos servidos pelo servidor de arquivos do loja.                   ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum                                                                 ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method SelectRepositoryPath() Class LJCFileServerConfigurationWizard	
	Local cSelectedPath := Self:oMGRepository:cText
	
	cSelectedPath := cGetFile("",STR0024,1,cSelectedPath,.F.,GETF_RETDIRECTORY ) // "Selecionar diret�rio:"
	
	Self:oMGRepository:cText := cSelectedPath
Return
