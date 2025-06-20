#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA2168.CH"
#INCLUDE "FWADAPTEREAI.CH"

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJAIntegrationConfig �Autor  �Vendas Clientes  � Data �  28/09/09   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe abstrata respons�vel por configurar e validar a uma          ���
���          �integra��o espec�fica.                                              ���
���          �Essa classe n�o pode ser instanciada diretamente.                   ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJAIntegrationConfig
	//������������������������������������������������������������Ŀ
	//�Array com as classes que observam a execu��o da configura��o�
	//�e valida��o da integra��o.                                  �
	//��������������������������������������������������������������
	Data aoObservers	
	//���������������������������������������������������������������������������������������������������������Ŀ
	//�Array com informa��es da valida��o das configura��es, sendo:                                             �
	//� aPreRequisitesStatus[n,1]: .T. se o pr�-requisito est� correto, .F. se o pr� requisito n�o est� correto;�
	//� aPreRequisitesStatus[n,2]: Texto informativo do pr�-requisito;                                          �
	//�Cada vez que os observadores s�o notificados eles l�em essa vari�vel.                                    �	
	//�����������������������������������������������������������������������������������������������������������
	Data aPreRequisitesStatus
	//������������������������������������������������������������Ŀ
	//�Texto que � apresentado durante a configura��o. Cada vez    �
	//�que os observadores s�o notificados eles l�em essa vari�vel.�
	//��������������������������������������������������������������
	Data cText
	Data lCancel
	Data lEAI20

	Method New()
	Method GetClassInterface()
	Method GetDisplayName()
	Method GetConfigurationText()
	Method Configure()
	Method Validate() 
	Method GetEndText()  
	Method SetEAI20()   //CRIADO NOVO METODO PARA INDICAR QUE A INTEGRACAO UTILIZA O NOVO EAI
	Method ADDPROCESS()
	Method AddTable()
	
	// M�todos para gerencia de observadores dessa classe
	Method Cancel()
	Method AddObserver()
	Method Notify()
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  28/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJAIntegrationConfig.	              ���
���          �Nesse m�todo s�o definidas as vari�veis do objeto com as    ���
���          �configura��es e valida��es que ser�o processadas.           ���
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
Method New() Class LJAIntegrationConfig 
	Self:aoObservers	:= {}
	Self:lCancel		:= .F.
	Self:aProcesses		:= {}
	Self:aTables		:= {}  
	Self:lEAI20			:= .F.  //INCLUIDA VALIACOES PARA O NOVO EAI
Return Self

//METODO QUE INDICA O NOVO EAI
Method SetEAI20( lHabilita ) Class LJAIntegrationConfig
	Self:lEAI20 := lHabilita
Return

Method AddProcess( aProcess ) Class LJAIntegrationConfig
	aAdd( Self:aProcesses, aProcess )
Return

Method AddTable( aTable ) Class LJAIntegrationConfig
	aAdd( Self:aTables, aTable )
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Cancel    �Autor  �Vendas Clientes     � Data �  28/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que cancela o processamento que est� sendo executado.���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Cancel() Class LJAIntegrationConfig
	Self:lCancel := .T.
Return           

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �AddObserver �Autor  �Vendas Clientes   � Data �  28/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que adiciona um objeto que ir� observar esse.        ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AddObserver( oObserver ) CLass LJAIntegrationConfig
	aAdd( Self:aoObservers, oObserver )
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �AddObserver �Autor  �Vendas Clientes   � Data �  28/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que notifica todos os observadores.                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Notify() Class LJAIntegrationConfig
	Local nCount := 0
	
	For nCount := 1 To Len(Self:aoObservers)
		Self:aoObservers[nCount]:Update( Self )
	Next
Return  

Method Validate() Class LJAIntegrationConfig
	Local cJobs					:= ""
	Local oLJCEntidadeFactory	:= LJCEntidadeFactory():New()		
	Local oSchedule				:= Nil
	Local oTarefas				:= Nil		
	Local oAgentes				:= Nil	
	Local lTarefaConfigurada	:= .F.
	Local lAgentConfigurado		:= .F.	
	Local cURL					:= ""
	Local cChannel				:= ""	
	Local oErrorHandler			:= Nil	 
	Local oIntegrator			:= Nil
	Local nCount				:= 0  
	Local cEAIWS				:= "" //Nome do WebService do novo EAI  
	Local oSchedule2			:= Nil
	Local oTarefas2				:= Nil   
	Local nCount2				:= 0
		
	Self:aPreRequisitesStatus := {} 	
	Self:lCancel := .F.
	
	//������������������������������������������������Ŀ
	//�Verifica se o Schedule est� ativo e configurado.�
	//��������������������������������������������������
	cJobs := GetPvProfString( "ONSTART" , "JOBS" , "" , GetADV97() )
	If	"FWSCHDMANAG" $ cJobs .And.;
		"FWSCHDQUEUE" $ cJobs
		aAdd( Self:aPreRequisitesStatus, { .T., STR0001 , "" } ) // "Schedule ativo"
	Else
		aAdd( Self:aPreRequisitesStatus, { .F., STR0002 , STR0003 } )	// "Schedule inativo" "Utilize o boletim espec�fico para configurar o Schedule."
	EndIf
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf	
	
	//�����������������������������������������������Ŀ
	//�Verifica se h� tarefa para o EAI dessa empresa.�
	//�������������������������������������������������
	
	If !Self:lEAI20
		If FindFunction("FWCheckDic") .And. FWCheckDic( "_SCHDTSK", .T. )
			oSchedule := oLJCEntidadeFactory:Create( "_SCHDTSK" )
			
			oTarefas := oSchedule:Consultar(1)
			For nCount := 1 To oTarefas:Count()
				If	oTarefas:Elements(nCount):DadosGet( "TSK_EMP" ) == cEmpAnt .And.;
					AllTrim(oTarefas:Elements(nCount):DadosGet( "TSK_ROTINA" )) == "FWEAI"
					lTarefaConfigurada := .T.
					Exit
				EndIf			
			Next
			
			If lTarefaConfigurada
				aAdd( Self:aPreRequisitesStatus, { .T., STR0004 , "" } ) // "Tarefa do EAI configurada no Schedule"
			Else
				aAdd( Self:aPreRequisitesStatus, { .F., STR0005 , STR0006 } ) // "Tarefa do EAI n�o configurada no Schedule" "Utilize o boletim t�cnico do EAI para configur�-lo corretamente."
			EndIf
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0007 , STR0008 } ) // "N�o foi poss�vel abrir a tabela de tarefas do Schedule" "Utilize o boletim espec�fico para configurar o Schedule."
		EndIf	
	Else 
	    //NOVO EAI, UTILIZA O NOVO SCHEDULE
		If FindFunction("FWCheckDic") .And. FWCheckDic( "XX1", .T. ) .And. FWCheckDic( "XX2", .T. )
		
			oSchedule := oLJCEntidadeFactory:Create( "XX1" ) 
			oSchedule2 := oLJCEntidadeFactory:Create( "XX2" )
			
			oTarefas := oSchedule:Consultar(1)
			For nCount := 1 To oTarefas:Count()

				 If	AllTrim(Upper(oTarefas:Elements(nCount):DadosGet( "XX1_ROTINA" ))) == "FWEAI"
					
						oSchedule2:DadosSet( "XX2_AGEND", oTarefas:Elements(nCount):DadosGet( "XX1_CODIGO" ) )		
						oTarefas2 := oSchedule2:Consultar(1)
						
						For nCount2 := 1 To oTarefas2:Count()
					    	If cEmpAnt $ AllTrim(oTarefas2:Elements(nCount2):DadosGet( "XX2_EMPFIL"))
					    						    		
					    		lTarefaConfigurada := .T.
					    		Exit
					    	EndIf
					    Next nCount2
					    
					    If lTarefaConfigurada
							Exit
						EndIf
				EndIf			
			Next
			
			If lTarefaConfigurada
				aAdd( Self:aPreRequisitesStatus, { .T., STR0004 , "" } ) // "Tarefa do EAI configurada no Schedule"
			Else
				aAdd( Self:aPreRequisitesStatus, { .F., STR0005 , STR0006 } ) // "Tarefa do EAI n�o configurada no Schedule" "Utilize o boletim t�cnico do EAI para configur�-lo corretamente."
			EndIf
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0007 , STR0008 } ) // "N�o foi poss�vel abrir a tabela de tarefas do Schedule" "Utilize o boletim espec�fico para configurar o Schedule."
		EndIf		
	EndIf
	
	//�������������������������������������������Ŀ
	//�Verifica se h� agente para a tarefa do EAI.�
	//���������������������������������������������
	If FindFunction("FWCheckDic") .And. FWCheckDic( "XX0", .T. )
		oSchedule := oLJCEntidadeFactory:Create( "XX0" )
		
		oAgentes := oSchedule:Consultar(1)
		For nCount := 1 To oAgentes:Count()
			If	oAgentes:Elements(nCount):DadosGet( "XX0_EMP" ) == cEmpAnt
				lAgentConfigurado := .T.
				Exit
			EndIf			
		Next
		
		If lAgentConfigurado
			aAdd( Self:aPreRequisitesStatus, { .T., STR0009 , "" } ) // "Agente do EAI configurado no Schedule"
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0010 , STR0011 } ) // "Agente do EAI n�o configurado no Schedule" "Utilize o boletim t�cnico do EAI para configur�-lo corretamente."
		EndIf
	Else
		aAdd( Self:aPreRequisitesStatus, { .F., STR0012 , STR0013 } ) // "N�o foi poss�vel abrir a tabela de agentes do Schedule" "Utilize o boletim espec�fico para configurar o Schedule."
	EndIf	

	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf
	
	//��������������������������������������������������
	//�Verifica se o EAI est� configurado corretamente.�
	//��������������������������������������������������   
	
	If !Self:lEAI20
		cUrl := GetNewPar( "MV_EAIURL", "" )
		cChannel := GetNewPar( "MV_EAIPORT", "" )
		
		If !Empty(cUrl)
			aAdd( Self:aPreRequisitesStatus, { .T., STR0014 , "" } ) // "URL de comunica��o com TOTVS ESB configurado."
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0015 , STR0016 } ) // "URL de comunica��o com TOTVS ESB n�o configurado." "Utilize o boletim t�cnico do EAI para configur�-lo corretamente."
		EndIf
		
		If !Empty(cChannel)
			aAdd( Self:aPreRequisitesStatus, { .T., STR0017 , "" } ) // "O channel de comunica��o com TOTVS ESB configurado."
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0018 , STR0019 } ) // "O channel de comunica��o com TOTVS ESB n�o configurado." "Utilize o boletim t�cnico do EAI para configur�-lo corretamente."
		EndIf
	
	Else 
	
	
		/*BEGINDOC
		//����������������������������������������������������������A�
		//�Verifica os par�metros minimos necessarios do novo EAI 2.0�
		//����������������������������������������������������������A�
		ENDDOC*/      
		
		cUrl := GetNewPar( "MV_EAIURL2", "" )
		cEAIWS := GetNewPar( "MV_EAIWS", "" )              //Informe o nome do Client WebService do EAI para envio a outro EAI   
		
		If !Empty(cUrl)
			aAdd( Self:aPreRequisitesStatus, { .T., STR0025 , "" } ) // "URL de comunica��o com TOTVS EAI configurado."
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0026 , "" } ) // "URL de comunica��o com TOTVS EAI n�o configurado." 
		EndIf
		
		If !Empty(cEAIWS)
			aAdd( Self:aPreRequisitesStatus, { .T., STR0027 , "" } ) // "O Client WebService do EAI para envio a outro EAI configurado."
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0028 , "" } ) // "O Client WebService do EAI para envio a outro EAI n�o configurado."
		EndIf
			
		
	EndIf	
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf
	
	
	If !Self:lEAI20
		//���������������������������������������������������Ŀ
		//�Verifica se o EAI est� conversando com o TOTVS ESB.�
		//�����������������������������������������������������
		oErrorHandler := ErrorBlock( {|e| Break(e) } )
		Begin Sequence		           
			//FWEAI ChkSendChannel - verifica se o canal configurado existe no TOTVS ESB - ExistService.
			oIntegrator := FWEAI():New()                                                 
			oIntegrator:SetSendChannel(EAI_CHANNEL_ESB)
			If oIntegrator:ChkSendChannel()
				aAdd( Self:aPreRequisitesStatus, { .T., STR0020 , "" } ) // "O protheus est� se comunicando com TOTVS ESB configurado."
			Else
				aAdd( Self:aPreRequisitesStatus, { .F., STR0021 , STR0022 } ) // "O protheus n�o est� se comunicando com TOTVS ESB configurado." "Verificar se os par�metros do EAI est�o configurados corretamente."
			EndIf 
		Recover
			aAdd( Self:aPreRequisitesStatus, { .F., STR0023 , STR0024 } ) // "N�o foi poss�vel a tentativa de comunica��o com o TOTVS ESB." "Possivelmente faltam patchs a serem aplicados no sistema."
		End Sequence
		ErrorBlock(oErrorHandler)  
	Else   
	
		//���������������������������������������������������Ŀ
		//�Verifica se o EAI 2 est� conversando com o TOTVS ESB.�
		//�����������������������������������������������������
		oErrorHandler := ErrorBlock( {|e| Break(e) } )
		Begin Sequence		           
			//FWEAI ChkSendChannel - verifica se o canal configurado existe no TOTVS ESB - ExistService.
			oIntegrator := FWEAI():New()                                                 
			oIntegrator:DeActivate()  
	        oIntegrator:Read()
	        oIntegrator:Activate()		 
	        		
			If oIntegrator:nTrials <= 5
				aAdd( Self:aPreRequisitesStatus, { .T., STR0029 , "" } ) // "O protheus est� se comunicando com TOTVS ESB configurado."
			ElseIf oIntegrator:cStatus <> TRANS_FAILED 
				aAdd( Self:aPreRequisitesStatus, { .T., STR0029 , "" } ) // "O protheus est� se comunicando com TOTVS ESB configurado."		
			Else
			
				aAdd( Self:aPreRequisitesStatus, { .F., STR0030 , STR0022 } ) // "O protheus n�o est� se comunicando com TOTVS ESB configurado." "Verificar se os par�metros do EAI est�o configurados corretamente."
			EndIf 
		Recover
			aAdd( Self:aPreRequisitesStatus, { .F., STR0031  , STR0024 } ) // "N�o foi poss�vel a tentativa de comunica��o com o TOTVS ESB." "Possivelmente faltam patchs a serem aplicados no sistema."
		End Sequence
		ErrorBlock(oErrorHandler) 
	EndIf
		
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf  									
Return