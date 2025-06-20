#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "LOJA2166.CH"

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCCargaIntegracaoForm�Autor  �Vendas Clientes     � Data �28/09/09 ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe com o Wizard de integra��o para integra��es que n�o usam MVC.���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCCargaIntegracaoForm
	Data lCancel
	Data aoIntegrationsConfig	
	Data lLoaded
	Data lLoadData

	// GUI gen�rico
	Data oWizard
	
	// Pain�l da sele��o de integra��es poss�veis
	Data oPSelSup   
	Data oPSelRes
	Data oRadIntegrations 
	Data nSelectedIntegration		
	
	// Pain�l da configura��o da integra��o
	Data oPConSup
	Data oPConInf
	Data oPConInfSup
	Data oPConInfInf
	Data oSCon
	Data oSPCon
	Data oTMConfigText
	Data oTMConfigResu	
	Data cConfigText
	Data oBtnConfigurar	
	Data oBtnCanCon
	
	// Pain�l da valida��o da configura��o
	Data oPPreSup
	Data oPPreInf
	Data oTMConfigInf
	Data oBtnValidar
	Data oBtnCanVal
	
	// Pain�l de carga inicial
	Data oProcessText
	Data oProcess
	Data oTableText
	Data oTable 
	Data oRecordText
	Data oRecord  
	Data oBtnCarga
	Data oBtnCanCar
	
	// Pain�l de encerramento
	Data oSEnd
	Data oSPEnd
	Data oTMEncerrText
	Data cEndText

	Method New()
	Method Show()
	Method Initialize()
	Method IniciaCarga()
	Method IniciaConfig()
	Method VerificaConfig()
	Method Cancel()
	Method StartProcess()
	Method EndProcess()
	Method ResetProgress()
	Method EnableButtons()
	Method DisableButtons()
	Method RefreshProgress()
	Method AddIntegration()
	Method Update()
	Method LoadTextConfig()
	Method LoadEndText()
EndClass     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCCargaIntegracaoForm.	              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto									   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class LJCCargaIntegracaoForm
	Self:lCancel				:= .F.
	Self:aoIntegrationsConfig	:= {}
	Self:lLoaded				:= .F.  
	Self:lLoadData				:= .T.
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Initialize�Autor �Vendas Clientes         � Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo respons�vel por inicializar os componentes gr�ficos. ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Initialize() Class LJCCargaIntegracaoForm 
	Local nCount 			:= 0
	Local aIntegrations		:= {}	
	Local nMeter1 := 1
	Local nMeter2 := 1
	Local nMeter3 := 1
	
	DEFINE WIZARD Self:oWizard TITLE IIF(Self:lLoadData, STR0001, STR0023 ) HEADER STR0002 MESSAGE " "; // "Assistente de Configura��o" "Assistente de configura��o e carga de integra��o"
			TEXT IIF(Self:lLoadData, STR0003, STR0024)  PANEL ; // )  PANEL ; // "Esse assistente lhe auxiar� no processo de configura��o de integra��o e na gera��o da carga inicial dos dados." /"Esse assistente lhe auxiliar� no processo de configura��o de integra��o."
			NEXT {|| .T.} FINISH {|| .T.}			

	//������������������������������������Ŀ
	//�Sele��o das integra��es dispon�veis.�
	//��������������������������������������
	CREATE PANEL Self:oWizard HEADER STR0004 MESSAGE STR0005 PANEL; // "Assistente de configura��o" "Sele��o de integra��es"
		BACK {|| .T.} NEXT {|| Self:LoadTextConfig() } FINISH {|| .T.} EXEC {|| .T.}								
		
	Self:oPSelSup := TPanel():New( 0, 0, , Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)], , , , , , 0, 10 )
	Self:oPSelSup:Align := CONTROL_ALIGN_TOP
	Self:oPSelRes := TPanel():New( 0, 0, , Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)], , , , , , 0, 0 )
	Self:oPSelRes:Align := CONTROL_ALIGN_ALLCLIENT
	
	@ 000,000 Say STR0006 Size 200,008 COLOR CLR_BLACK PIXEL OF Self:oPSelSup // "Selecione uma integra��o:"
	
	For nCount := 1 To Len(Self:aoIntegrationsConfig)
		aAdd( aIntegrations, Self:aoIntegrationsConfig[nCount]:GetDisplayName() )
	Next
		
	Self:oRadIntegrations := TRadMenu():New( 0, 0, aIntegrations, bSetGet(Self:nSelectedIntegration), Self:oPSelRes,,,,,,,,0, 0,,,,.T. )
	Self:oRadIntegrations:Align := CONTROL_ALIGN_ALLCLIENT

	//���������������������������Ŀ
	//�Configura��o da integra��o.�
	//�����������������������������	
	CREATE PANEL Self:oWizard HEADER STR0005 MESSAGE STR0007 PANEL; // "Assistente de configura��o" "Configura��o integra��o"
		BACK {|| .T.} NEXT {|| .T. } FINISH {|| .T.} EXEC {|| .T.}
	
	Self:oPConSup := TPanel():New( 0, 0, , Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)], , , , , , 0, 0 )
	Self:oPConSup:Align := CONTROL_ALIGN_ALLCLIENT
	Self:oPConInf := TPanel():New( 0, 0, , Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)], , , , , , 0, 50 )
	Self:oPConInf:Align := CONTROL_ALIGN_BOTTOM
	
	Self:oPConInfSup := TPanel():New( 0, 0, , Self:oPConInf, , , , , , 0, 0 )
	Self:oPConInfSup:Align := CONTROL_ALIGN_ALLCLIENT
	
	Self:oPConInfInf := TPanel():New( 0, 0, , Self:oPConInf, , , , , , 0, 10 )
	Self:oPConInfInf:Align := CONTROL_ALIGN_BOTTOM
	
	@ 000,000 Button Self:oBtnConfigurar PROMPT STR0008 Size 040,010  ACTION Self:IniciaConfig() PIXEL OF Self:oPConInfInf // "Configurar"
	
	@ 000,042 Button Self:oBtnCanCon PROMPT STR0009 Size 040,010 ACTION (Self:Cancel()) PIXEL OF Self:oPConInfInf // "Cancelar"
	Self:oBtnCanCon:Disable()	
	
	Self:oSCon := TScrollArea():New(Self:oPConSup,0,0,0,0,.T.,.T.,.T.)
	Self:oSCon:Align := CONTROL_ALIGN_ALLCLIENT
	
	Self:oSPCon := TPanel():New( 0, 0, , Self:oSCon, , , , , , 0, 500 )
	Self:oSPCon:Align := CONTROL_ALIGN_TOP
	
	Self:oSCon:SetFrame( Self:oSPCon )	
	
	Self:oTMConfigText := TSay():New( 0, 0, bSetGet( Self:cConfigText ), Self:oSPCon,,,,,,.T.,,,0,0,,,,,,.T.)
	Self:oTMConfigText:Align := CONTROL_ALIGN_ALLCLIENT
	
	Self:oTMConfigResu := TSimpleEditor():New( 0, 0, Self:oPConInfSup, 0, 0, , )
	Self:oTMConfigResu:Align := CONTROL_ALIGN_ALLCLIENT	
        
	//����������������������Ŀ
	//�Valida��o de ambiente.�
	//������������������������
	CREATE PANEL Self:oWizard HEADER IIF(Self:lLoadData, STR0010, STR0025) MESSAGE IIF(Self:lLoadData, STR0011, STR0026) PANEL; // "Assistente de carga"/"Assistente de Integra��o" "Valida��o das configura��es necess�rias para a carga" /"Valida��o das configura��es necess�rias para a integra��o." 
		BACK {|| .T.} NEXT {|| IIF(!Self:lLoadData, Self:LoadEndText() ,.T.) } FINISH {|| .T.} EXEC {|| .T.}
	
	Self:oPPreSup := TPanel():New( 0, 0, , Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)], , , , , , 0, 0 )
	Self:oPPreSup:Align := CONTROL_ALIGN_ALLCLIENT
	Self:oPPreInf := TPanel():New( 0, 0, , Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)], , , , , , 0, 10 )	
	Self:oPPreInf:Align := CONTROL_ALIGN_BOTTOM
	
	Self:oTMConfigInf := TSimpleEditor():New( 0, 0, Self:oPPreSup, 0, 0, , )
	Self:oTMConfigInf:Align := CONTROL_ALIGN_ALLCLIENT
	  	
	@ 000,000 Button Self:oBtnValidar PROMPT STR0012 Size 040,010  ACTION Self:VerificaConfig() PIXEL OF Self:oPPreInf // "Validar"
	@ 000,042 Button Self:oBtnCanVal PROMPT STR0013 Size 040,010 ACTION (Self:Cancel()) PIXEL OF Self:oPPreInf // "Cancelar"
	Self:oBtnCanVal:Disable()	
			
	//��������������Ŀ
	//�Carga inicial.�
	//���������������� 
	If Self:lLoadData
	
		CREATE PANEL Self:oWizard HEADER STR0010 MESSAGE STR0014 PANEL; // "Assistente de carga" "Gera��o de carga"
			BACK {|| .T.} NEXT {|| Self:LoadEndText() } FINISH {|| .T.} EXEC {|| .T.}		
			
		@ 010,008 Say Self:oProcessText PROMPT STR0015 Size 050,008 COLOR CLR_BLACK PIXEL OF Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)] // "Processo:"
		@ 020,008 METER Self:oProcess VAR nMeter1 Size 270,008 NOPERCENTAGE PIXEL OF Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)]
		@ 030,008 Say Self:oTableText PROMPT STR0016 Size 050,008 COLOR CLR_BLACK PIXEL OF Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)] // "Tabela:"
		@ 040,008 METER Self:oTable VAR nMeter2 Size 270,008 NOPERCENTAGE PIXEL OF Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)]
		@ 050,008 Say Self:oRecordText PROMPT STR0017 Size 050,008 COLOR CLR_BLACK PIXEL OF Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)] // "Registro:"
		@ 060,008 METER Self:oRecord VAR nMeter3 Size 270,008 NOPERCENTAGE PIXEL OF Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)]
		
		@ 070,008 Button Self:oBtnCarga PROMPT STR0018 Size 040,010  ACTION Self:IniciaCarga() PIXEL OF Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)] // "Iniciar carga"
		@ 070,050 Button Self:oBtnCanCar PROMPT STR0019 Size 040,010 ACTION (Self:CancelCarga()) PIXEL OF Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)] // "Cancelar"
		Self:oBtnCanCar:Disable()
	
	EndIf	  
	
	
	//�������������Ŀ
	//�Encerramento.�
	//���������������	
	CREATE PANEL Self:oWizard HEADER IIF(Self:lLoadData, STR0010, STR0025) MESSAGE STR0020 PANEL; // "Assistente de carga"/"Assistente de Integra��o" "Encerramento"
		BACK {|| .T.} NEXT {|| .T. } FINISH {|| .T.} EXEC {|| .T.}				
		
	Self:oSEnd := TScrollArea():New(Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)],0,0,0,0,.T.,.T.,.T.)
	Self:oSEnd:Align := CONTROL_ALIGN_ALLCLIENT
	
	Self:oSPEnd := TPanel():New( 0, 0, , Self:oSEnd, , , , , , 0, 500 )
	Self:oSPEnd:Align := CONTROL_ALIGN_TOP
	
	Self:oSEnd:SetFrame( Self:oSPEnd )			

	Self:oTMEncerrText := TSay():New( 0, 0, {|| Self:cEndText }, Self:oSPEnd,,,,,,.T.,,,0,0,,,,,,.T.)
	Self:oTMEncerrText:Align := CONTROL_ALIGN_ALLCLIENT				
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Show      �Autor �Vendas Clientes         � Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo respons�vel por exibir o wizard.                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Show() Class LJCCargaIntegracaoForm	
	Self:Initialize()
			
	ACTIVATE WIZARD Self:oWizard CENTERED VALID {|| .T. } 	
Return 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �EnableButtons�Autor �Vendas Clientes      � Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo para habilitar os bot�es de navega��o do wizard,     ���
���          �al�m dos bot�es espec�ficos.                                ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method EnableButtons() Class LJCCargaIntegracaoForm	
	// Gen�ricos
	Self:oWizard:oBack:Enable()
	Self:oWizard:oNext:Enable()
	Self:oWizard:oCancel:Enable()
	Self:oWizard:oFinish:Enable()
	
	// Espec�ficos
	If Self:lLoadData
		Self:oBtnCarga:Enable()	
	EndIf
	Self:oBtnConfigurar:Enable()	
	Self:oBtnValidar:Enable()	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �DisableButtons�Autor �Vendas Clientes     � Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo para desabilitar os bot�es de navega��o do wizard,   ���
���          �al�m dos bot�es espec�ficos.                                ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method DisableButtons() Class LJCCargaIntegracaoForm
	// Gen�ricos
	Self:oWizard:oBack:Disable()
	Self:oWizard:oNext:Disable()
	Self:oWizard:oCancel:Disable()
	Self:oWizard:oFinish:Disable()
	
	// Espec�ficos
	If Self:lLoadData
		Self:oBtnCarga:Disable()
	EndIf	
	Self:oBtnConfigurar:Disable()
	Self:oBtnValidar:Disable()	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �IniciaCarga�Autor �Vendas Clientes        � Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que executa o processamento de carga inicial.        ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method IniciaCarga() Class LJCCargaIntegracaoForm
	Local oCargaIni	:= Nil					//Objeto do tipo LJCCargaInicialInt
	
	// Reafirma que o processamento n�o est� cancelado.
	Self:lCancel := .F.
	
	Self:DisableButtons()
	Self:StartProcess()

	//Instancia o objeto LJCCargaInicialInt
	oCargaIni := LJCCargaInicialInt():New()
	
	// Se adiciona como observador
	oCargaIni:AddObserver(Self)
	
	// Executa a carga inicial
	Self:lLoaded := oCargaIni:Gerar() 
	
	// Atualiza tela
	Self:ResetProgress()
	Self:EnableButtons()
	Self:EndProcess()

Return 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �IniciaConfig�Autor �Vendas Clientes       � Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que executa o processamento de configura��o.         ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method IniciaConfig() Class LJCCargaIntegracaoForm
	// Reafirma que o processamento n�o est� cancelado.
	Self:lCancel := .F.
	
	// Atualiza tela
	Self:DisableButtons()		    
	Self:StartProcess()

	// Se tiver alguma configura��o selecionada	
	If Self:nSelectedIntegration > 0
		nSelectedIntegration := Self:aoIntegrationsConfig[Self:nSelectedIntegration]:Configure()
	EndIf
	
	// Atualiza tela
	Self:EnableButtons()
	Self:EndProcess()
Return   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �VerificaConfig�Autor �Vendas Clientes     � Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que executa o processamento de verifica��o de config.���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method VerificaConfig() Class LJCCargaIntegracaoForm
	// Reafirma que o processamento n�o est� cancelado.
	Self:lCancel := .F.
	
	// Atualiza tela
	Self:DisableButtons()
	Self:StartProcess()
	
	// Se tiver alguma configura��o selecionada
	If Self:nSelectedIntegration > 0
		nSelectedIntegration := Self:aoIntegrationsConfig[Self:nSelectedIntegration]:Validate()
	EndIf
	
	// Atualiza tela
	Self:EnableButtons()
	Self:EndProcess()
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Cancel    �Autor �Vendas Clientes         � Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que cancela o processamento ativo.                   ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Cancel() Class LJCCargaIntegracaoForm
	Self:lCancel := .T.  
Return      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �StartProcess�Autor �Vendas Clientes       � Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que habilita os bot�es de cancelamento durante algum ���
���          �processamento.                                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method StartProcess() Class LJCCargaIntegracaoForm
	Self:oBtnCanCon:Enable()	
	Self:oBtnCanVal:Enable()			
	If Self:lLoadData
		Self:oBtnCanCar:Enable()
	EndIf			
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �EndProcess�Autor �Vendas Clientes         � Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que desabilita os bot�es de cancelamento no final    ���
���          �de algum processamento.                                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method EndProcess() Class  LJCCargaIntegracaoForm
	Self:oBtnCanCon:Disable()	
	Self:oBtnCanVal:Disable()		
	If Self:lLoadData
		Self:oBtnCanCar:Disable() 
	EndIf		
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ResetProgress�Autor �Vendas Clientes      � Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que reinicia os componentes de exibi��o de progresso ���
���          �da carga inicial.                                           ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ResetProgress() Class LJCCargaIntegracaoForm
	Self:oProcessText:SetText( STR0015 ) // "Processo:"
	Self:oProcess:SetTotal( 100 )
	Self:oProcess:Set( 0 )
	Self:oTableText:SetText( STR0016 ) // "Tabela:"
	Self:oTable:SetTotal( 100 )
	Self:oTable:Set( 0 )
	Self:oRecordText:SetText( STR0017 ) // "Registro:"
	Self:oRecord:SetTotal( 100 )
	Self:oRecord:Set( 0 )
	Self:RefreshProgress()
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �RefreshProgress�Autor �Vendas Clientes    � Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que atualiza os componentes de exibi��o de progresso ���
���          �da carga inicial.                                           ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method RefreshProgress() Class LJCCargaIntegracaoForm
	Self:oProcessText:Refresh()
	Self:oProcess:Refresh()
	Self:oTableText:Refresh()
	Self:oTable:Refresh()
	Self:oRecordText:Refresh()
	Self:oRecord:Refresh()
	Self:oWizard:oDlg:Refresh()
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Update         �Autor �Vendas Clientes    � Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que atualiza o progresso de alguma processamento.    ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�oSubject: Objeto que avisou da atualiza��o do progresso.    ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/	
Method Update( oSubject ) Class LJCCargaIntegracaoForm
	Local nCount	:= 0
	Local cTempText	:= ""

	// Se for o objeto de carga
	If oSubject:GetClassInterface() == "LJCCargaInicialInt"
		Self:oProcess:SetTotal( oSubject:nTotal )
		Self:oProcess:Set( oSubject:nValue )
		Self:oProcessText:SetText( STR0015 + " " + oSubject:cProcessText ) // "Processo:"
		Self:oTable:SetTotal( oSubject:nItemTotal )
		Self:oTable:Set( oSubject:nItemValue )
		Self:oTableText:SetText( STR0016 + " " + oSubject:cTableText) // "Tabela:"
		Self:oRecord:SetTotal( oSubject:nSubItemTotal )
		Self:oRecord:Set( oSubject:nSubItemValue )
		Self:oRecordText:SetText( STR0017 + " " + AllTrim(Str(oSubject:nSubItemValue)) + "/" + AllTrim(Str(oSubject:nSubItemTotal)) ) // "Registro:"
		Self:RefreshProgress()
	// Se for o objeto de configura��o de integra��o
	ElseIf oSubject:GetClassInterface() == "LJIIntegrationConfig"	
		// Atualiza o texto do processamento da configura��o
		Self:oTMConfigResu:Load( oSubject:cText )
		
		// Atualiza o processamento da verifica��o de requisitos
		For nCount := 1 To Len( oSubject:aPreRequisitesStatus )
			cTempText += If( oSubject:aPreRequisitesStatus[nCount][1], "<font color='green'>" + STR0021 + "</font>" + " - " + oSubject:aPreRequisitesStatus[nCount][2], "<font color='red'>" + STR0022 + "</font>" + " - " + oSubject:aPreRequisitesStatus[nCount][2] + " - " + oSubject:aPreRequisitesStatus[nCount][3] ) + "<BR>" // "OK" "N�o OK"
		Next
		Self:oTMConfigInf:Load( cTempText )		
		
		// Faz a atualiza��o da tela
		Self:oWizard:oDlg:Refresh()
	EndIf

	// Envia o cancelamento para o assunto	
	If Self:lCancel
		oSubject:Cancel()
	EndIf
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �AddIntegration �Autor �Vendas Clientes    � Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que adiciona um objeto de configura��o de integra��o ���
���          �ao wizard de integra��o.                                    ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AddIntegration( oIntegrationConfig ) Class LJCCargaIntegracaoForm
	aAdd( Self:aoIntegrationsConfig, oIntegrationConfig )
	oIntegrationConfig:AddObserver( Self )
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �AddIntegration �Autor �Vendas Clientes    � Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que carrega o texto com instru��es da configura��o   ���
���          �da integra��o selecionada.                                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LoadTextConfig() Class LJCCargaIntegracaoForm
	If Self:nSelectedIntegration > 0
		Self:cConfigText := Self:aoIntegrationsConfig[Self:nSelectedIntegration]:GetConfigurationText()
	Else
		Self:cConfigText := ""
	EndIf		
	
	Self:oTMConfigText:Refresh()
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �LoadEndText    �Autor �Vendas Clientes    � Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que carrega o texto de encerramento da configura��o  ���
���          �da integra��o selecionada.                                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LoadEndText() Class LJCCargaIntegracaoForm
	If Self:nSelectedIntegration > 0
		Self:cEndText := Self:aoIntegrationsConfig[Self:nSelectedIntegration]:GetEndText( Self:lLoaded )
	Else
		Self:cEndText := ""
	EndIf		
	
	Self:oTMConfigText:Refresh()
Return .T.
