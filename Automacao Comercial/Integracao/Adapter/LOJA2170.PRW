#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA2170.CH"

Function LOJA2170; Return  // "dummy" function - Internal Use 
          
/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCRM             �Autor  �Vendas Clientes     � Data �  14/10/09   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em configurar e validar a integra��o com o       ���
���          �produto RM da empresa TOTVS.			                              ���
���          �Essa classe � herda a classe abstrata LJAIntegrationConfig.         ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCRM From LJAIntegrationConfig
	
	Data lConfigured                          
	Data lValidated
	Data aProcesses
	Data aTables	

	Method New()
	Method GetClassInterface()
	Method GetDisplayName()
	Method GetConfigurationText()
	Method Configure()
	Method Validate()
	Method GetEndText()
    
	//Metodos internos
	Method ConfProcs()
	Method ConfTabs()
	Method ConfParans()
	Method ConfInt()
	Method ValProcs()
	Method ValTabs()
	Method ValParans()
	Method ValConfig()
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCBestSales.	                      ���
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
Method New() Class LJCRM
	
	_Super:New()
	
	Self:aPreRequisitesStatus	:= {}
	Self:cText					:= ""
	
	// Processos que devem ser cadastrados no MDO 
	Self:aProcesses :=	{										;
							{ "002", "CAD VENDEDOR"			}	,;
							{ "003", "CAD ESTACAO"		 	}	,;
							{ "005", "MAPA RESUMO"		 	}	,;
							{ "006", "CUPOM FISCAL"			}	,;
							{ "007", "SANGRIA"				}	,;
							{ "008", "SUPRIMENTO"			}	,;
							{ "016", "ITENS CF CANC"		}	;
						}
						
	// Tabelas que devem ser cadastradas no MDP
	Self:aTables :=	{						;
						{ "002", "SA3" }	,;
						{ "003", "SLG" }	,;
						{ "005", "SFI" }	,;
						{ "006", "SF2" }	,;
						{ "006", "SD2" }	,;
						{ "006", "SE1" }	,;
						{ "006", "SEF" }	,;
						{ "006", "SLX" }	,;						
						{ "007", "SE5" }	,;
						{ "008", "SE5" }	,;
						{ "016", "SLX" }	;
					}
								
	Self:lConfigured	:= .F.
	Self:lValidated		:= .F.
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetClassInterface�Autor  �Vendas Clientes� Data � 27/03/09  ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que retorna o nome da classe abstrata que a classe   ���
���          �herda.                                                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �String: Interface que esta classe herda.                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetClassInterface() Class LJCRM
Return "LJIIntegrationConfig"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetDisplayName   �Autor  �Vendas Clientes� Data � 27/03/09  ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que retorna o nome da integra��o que esta classe     ���
���          �representa.                                                 ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �String: Nome da integra��o que esta classe representa.      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetDisplayName() Class LJCRM
Return "RM Nucleus"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetConfigurationText�Autor�Vendas Clientes� Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que retorna o texto com informa��es das configura��es���
���          �efetuadas por essa classe.                                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �String: Texto com informa��es das configura��es efetuadas   ���
���          �por essa classe.                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetConfigurationText() Class LJCRM
	Local cText		:= ""
	Local nCount	:= 0
	Local nProcess	:= 0
	
	cText += "<p>"
	cText += STR0001 //"Para criar automaticamente as configura��es b�sicas para o funcionamento da integra��o com a RM, clique no bot�o 'Configurar'."
	cText += "<br>"
	cText += 	STR0002 //"As seguintes configura��es ser�o efetuadas:"
	cText += 	"<ul>"
	cText += 		"<li> " + STR0003 + "</li>" //"Processos de integra��o:"
	cText += 		"<ul>"
	For nCount := 1 To Len(Self:aProcesses)
		cText += 			"<li>" + " " + Self:aProcesses[nCount][1] + " - " + Self:aProcesses[nCount][2] + "</li>"
	Next

	cText += 		"</ul>"		
	cText += 		"<li> " + STR0004 + "</li>" //"Tabelas dos processos de integra��o:"
	cText += 		"<ul>"
	For nCount := 1 To Len(Self:aTables)
		nProcess := aScan( Self:aProcesses, { |x| x[1] == Self:aTables[nCount][1] } )
		cText += 			"<li> " + STR0005 + ": " + Self:aTables[nCount][2] + If(nProcess > 0, " - " + STR0006 + ": " + Self:aProcesses[nProcess][1] + " - " + Self:aProcesses[nProcess][2],"") + "</li>" //"Tabela:" ; "Processo"
	Next

	cText += 		"</ul>"			
	cText += 		"<li> " + STR0007 + "</li>" //"Par�metros:"
	cText += 		"<ul>"
	cText += 			"<li> " + "MV_LJGRINT " + STR0008 + "</li>" //"como .T. para a gera��o da integra��o"
	cText += 		"</ul>"		
	cText += 	"</ul>"
	cText += "</p>"	
	
Return cText

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Configure           �Autor�Vendas Clientes� Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que efetua as configura��es necess�rias para que essa���
���          �integra��o funcione corretamente.                           ���
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
Method Configure() Class LJCRM
		
	Self:cText		:= ""
	Self:lCancel	:= .F.	
		
	//Cadastra os processos
	Self:ConfProcs()
	
	//Cadastra as tabelas dos processos
	Self:ConfTabs()
		
	//Configura os par�metros
	Self:ConfParans()
	
	//Configuracao da integracao
	Self:ConfInt()

	Self:lConfigured	:= .T.					

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Validate            �Autor�Vendas Clientes� Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que efetua a valida��o das configura��es necess�rias ���
���          �para que essa integra��o funcione corretamente.             ���
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
Method Validate() Class LJCRM 
	
	Self:lCancel 				:= .F.
	Self:aPreRequisitesStatus 	:= {}
	
	//Chama as valida��es gen�ricas de integra��o
	_Super:Validate()
	
	//Verifica se os processos est�o cadastrados
	Self:ValProcs()

	//Verifica se as tabelas dos processos est�o cadastrados
	Self:ValTabs()

	//Verifica se os par�metros necess�rios est�o cadastrados
	Self:ValParans()
	
	//Verifica se as configura�oes da integra��o est�o cadastradas
	Self:ValConfig()
	
	Self:lValidated		:= .T.	

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetEndText          �Autor�Vendas Clientes� Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo que retorna o texto de encerramento da configura��o  ���
���          �e valida��o da integra��o.                                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�lLoaded := Se foi efetuada a carga inicial.                 ���
�������������������������������������������������������������������������͹��
���Retorno   �String: Texto de encerramento da configura��o e valida��o   ���
���          �da integ.                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetEndText( lLoaded ) Class LJCRM
	
	Local cText := ""
	
	cText += "<p>"
	cText += STR0009 //"A seguir um resumo das tarefas executadas:"
	cText += "<br>"		
	cText += 	"<ul>"
	cText += 		"<li>" + " " + STR0010 + " " + If( Self:lConfigured, "<font color='green'>" + STR0011 + "</font>", "<font color='red'>" + STR0012 + "</font>" ) + "</li>"	//"Configura��o do sistema:" ; "Efetuado" ; "N�o efetuado"
	cText += 		"<li>" + " " + STR0013 + " " + If( Self:lValidated, "<font color='green'>" + STR0011 + "</font>", "<font color='red'>" + STR0012 + "</font>" ) + "</li>" //"Valida��o do sistema:" ; "Efetuado" ; "N�o efetuado" 		
	cText += 		"<li>" + " " + STR0014 + " " + If( lLoaded, "<font color='green'>" + STR0011 + "</font>", "<font color='red'>" + STR0012 + "</font>" ) + "</li>" //"Carga inicial:" ; "Efetuado" ; "N�o efetuado" 		 			
	cText += 	"</ul>"	
	cText += "</p>"	

Return cText

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ConfProcs           �Autor�Vendas Clientes� Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �Configura os processos da integracao  					  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfProcs() Class LJCRM

	Local nCount				:= 0	
	Local oLJCEntidadeFactory	:= LJCEntidadeFactory():New()
	Local oProcessos			:= Nil
    
	oProcessos := oLJCEntidadeFactory:Create( "MDO" )

	For nCount := 1 To Len(Self:aProcesses)
		
		If Self:lCancel
			Exit
		EndIf	
		
		oProcessos:Limpar()
		oProcessos:DadosSet( "MDO_CODIGO", Self:aProcesses[nCount][1] )		
		
		If oProcessos:Consultar(1):Count() == 0
			oProcessos:DadosSet( "MDO_DESCRI", Self:aProcesses[nCount][2] )
			
			Do Case
			
				Case Self:aProcesses[nCount][1] == "002" .OR. Self:aProcesses[nCount][1] == "003"
					oProcessos:DadosSet( "MDO_HABINC", .T. )
					oProcessos:DadosSet( "MDO_HABALT", .T. )
					oProcessos:DadosSet( "MDO_HABEXC", .T. )
					oProcessos:DadosSet( "MDO_HABCAR", .T. )
					
				Case Self:aProcesses[nCount][1] == "005" .OR. Self:aProcesses[nCount][1] == "007" .OR. Self:aProcesses[nCount][1] == "008"
					oProcessos:DadosSet( "MDO_HABINC", .T. )
					oProcessos:DadosSet( "MDO_HABALT", .F. )
					oProcessos:DadosSet( "MDO_HABEXC", .F. )
					oProcessos:DadosSet( "MDO_HABCAR", .F. )
					
				Case Self:aProcesses[nCount][1] == "006" .OR. Self:aProcesses[nCount][1] == "016"
					oProcessos:DadosSet( "MDO_HABINC", .T. )
					oProcessos:DadosSet( "MDO_HABALT", .F. )
					oProcessos:DadosSet( "MDO_HABEXC", .T. )
					oProcessos:DadosSet( "MDO_HABCAR", .F. )

			EndCase
			
			oProcessos:Incluir()
			
			Self:cText += STR0015 + " " + Self:aProcesses[nCount][1] + " - " +Self:aProcesses[nCount][2] + "<br>" //"Adicionado processo"
		Else
			Self:cText += STR0006 + " " + Self:aProcesses[nCount][1] + " " + STR0017 + ";" + "<br>" //"Processo" ; "j� cadastrado"
		EndIf
		
		Self:Notify()
	Next

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ConfTabs            �Autor�Vendas Clientes� Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �Configura as tabelas dos processos da integracao  		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfTabs() Class LJCRM

	Local nCount				:= 0	
	Local oLJCEntidadeFactory	:= LJCEntidadeFactory():New()
	Local oTabelas				:= Nil	
	
	oTabelas := oLJCEntidadeFactory:Create( "MDP" )
		
	For nCount := 1 To Len(Self:aTables)
		
		If Self:lCancel
			Exit
		EndIf		
		
		oTabelas:Limpar()
		oTabelas:DadosSet( "MDP_PROCES", Self:aTables[nCount][1] )
		oTabelas:DadosSet( "MDP_TABELA", Self:aTables[nCount][2] )
		
		If oTabelas:Consultar(1):Count() == 0
			
			Do Case
			
				Case Self:aTables[nCount][1] == "002" .OR. Self:aTables[nCount][1] == "003"
					oTabelas:DadosSet( "MDP_HABILI", .T. )
					oTabelas:DadosSet( "MDP_HABCAR", .T. )
			    OtherWise
			    	oTabelas:DadosSet( "MDP_HABILI", .T. )
					oTabelas:DadosSet( "MDP_HABCAR", .F. )
			EndCase
			
			oTabelas:Incluir()
			
			Self:cText += STR0018 + " " + Self:aTables[nCount][2] + STR0019 + Self:aTables[nCount][1] + ";<br>" //"Adicionada tabela" ; " para o processo "
		Else
			Self:cText += STR0005 + " " + Self:aTables[nCount][2] + " " + STR0020 + Self:aTables[nCount][1] + ";<br>" //"Tabela" ; "j� cadastrada para o processo "
		EndIf		
		
		Self:Notify()
	Next		

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ConfParans          �Autor�Vendas Clientes� Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �Configura as tabelas dos processos da integracao  		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/	
Method ConfParans() Class LJCRM

	Local oLJCEntidadeFactory	:= LJCEntidadeFactory():New()
	Local oParametros			:= Nil
		
	oParametros := oLJCEntidadeFactory:Create( "SX6" )
	
	oParametros:DadosSet( "X6_FIL", Space(Len(SX6->X6_FIL)) )		
	oParametros:DadosSet( "X6_VAR", "MV_LJGRINT" )
	
	If oParametros:Consultar(1):Count() == 0
		oParametros:DadosSet( "X6_TIPO",  "L" )	
		oParametros:DadosSet( "X6_CONTEUD", "T" )
		oParametros:DadosSet( "X6_CONTSPA", "T" )
		oParametros:DadosSet( "X6_CONTENG", "T" )
		oParametros:Incluir()
		Self:cText += STR0021 + "MV_LJGRINT " + STR0022 + ";<br>" //"Adicionado par�metro " ; "e configurado para .T."
	Else
		oParametros:DadosSet( "X6_CONTEUD", "T" )
		oParametros:DadosSet( "X6_CONTSPA", "T" )
		oParametros:DadosSet( "X6_CONTENG", "T" )
		oParametros:Alterar(1)
		Self:cText += STR0023 + " MV_LJGRINT " + STR0024 + ";<br>" //"Par�metro" ; "configurado para .T."
	EndIf
	
	Self:Notify()	

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ConfInt             �Autor�Vendas Clientes� Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastra a configuracao da integracao  		  			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfInt() Class LJCRM

	Local oEntConfInt := Nil
	
	oEntConfInt := LJCEntParamInt():New()
	
	oEntConfInt:DadosSet("MDQ_CODIGO", "001")	

	If oEntConfInt:Consultar(1):Count() == 0
			
		oEntConfInt:Incluir()
			
		Self:cText += STR0025 + ";<br>" //"Adicionada configura��o da integra��o (Tabela - MDQ)
	Else
		Self:cText += STR0026 + ";<br>" //"Configura��o da integra��o j� cadastrado (Tabela - MDQ)
	EndIf		
		
	Self:Notify()
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ValProcs            �Autor�Vendas Clientes� Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida os processos da integracao  					  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ValProcs() Class LJCRM

	Local nCount				:= 0
	Local oLJCEntidadeFactory	:= LJCEntidadeFactory():New()	
	Local oProcessos			:= Nil
	Local oRegistros			:= Nil	
	
	oProcessos := oLJCEntidadeFactory:Create( "MDO" )
	
	For nCount := 1 To Len(Self:aProcesses)
		
		If Self:lCancel
			Exit
		EndIf	
		
		oProcessos:Limpar()
		oProcessos:DadosSet( "MDO_CODIGO", Self:aProcesses[nCount][1] )
		oRegistros := oProcessos:Consultar(1)
		
		If oRegistros:Count() > 0 
			
			Do Case
			
				Case Self:aProcesses[nCount][1] == "002" .OR. Self:aProcesses[nCount][1] == "003"
					
					If oRegistros:Elements(1):DadosGet( "MDO_HABINC" ) .AND. ;
					   oRegistros:Elements(1):DadosGet( "MDO_HABALT" )	.AND. ;
					   oRegistros:Elements(1):DadosGet( "MDO_HABEXC" )	.AND. ;
					   oRegistros:Elements(1):DadosGet( "MDO_HABCAR" )
					    			
						aAdd( Self:aPreRequisitesStatus, { .T., STR0006 + " " + Self:aProcesses[nCount][1] + " " + STR0027 , "" } ) //"Processo" ; "cadastrado corretamente para inclus�o."
					Else
						aAdd( Self:aPreRequisitesStatus, { .F., STR0006 + " " + Self:aProcesses[nCount][1] + " " + STR0028 , STR0029 + " " + Self:aProcesses[nCount][1] + " " + STR0030 } ) //"Processo" ; "n�o cadastrado corretamente." ; "� necess�rio que o processo" ; "esteja habilitado para inclus�o, altera��o, exclus�o e carga inicial."
					EndIf
															
				Case Self:aProcesses[nCount][1] == "005" .OR. Self:aProcesses[nCount][1] == "007" .OR. Self:aProcesses[nCount][1] == "008"
					
					If oRegistros:Elements(1):DadosGet( "MDO_HABINC" )			
						aAdd( Self:aPreRequisitesStatus, { .T., STR0006 + " " + Self:aProcesses[nCount][1] + " " + STR0027 , "" } ) //"Processo" ; "cadastrado corretamente para inclus�o."
					Else
						aAdd( Self:aPreRequisitesStatus, { .F., STR0006 + " " + Self:aProcesses[nCount][1] + " " + STR0028 , STR0029 + " " + Self:aProcesses[nCount][1] + " " + STR0031 } ) //"Processo" ; "n�o cadastrado corretamente." ; "� necess�rio que o processo" ; "esteja habilitado para inclus�o."
					EndIf
					
				Case Self:aProcesses[nCount][1] == "006" .OR. Self:aProcesses[nCount][1] == "016"
					
					If oRegistros:Elements(1):DadosGet( "MDO_HABINC" ) .AND. ;
					   oRegistros:Elements(1):DadosGet( "MDO_HABEXC" )			
						
						aAdd( Self:aPreRequisitesStatus, { .T., STR0006 + " " + Self:aProcesses[nCount][1] + " " + STR0027 , "" } ) //"Processo" ; "cadastrado corretamente para inclus�o."
					Else
						aAdd( Self:aPreRequisitesStatus, { .F., STR0006 + " " + Self:aProcesses[nCount][1] + " " + STR0028 , STR0029 + " " + Self:aProcesses[nCount][1] + " " + STR0032 } ) //"Processo" ; "n�o cadastrado corretamente." ; "� necess�rio que o processo" ; "esteja habilitado para inclus�o e exclus�o."
					EndIf
					
			EndCase
			
		Else
			
			Do Case
			
				Case Self:aProcesses[nCount][1] == "002" .OR. Self:aProcesses[nCount][1] == "003"
					
					aAdd( Self:aPreRequisitesStatus, { .F., STR0006 + " " + Self:aProcesses[nCount][1] + " " + STR0028 , STR0029 + " " + Self:aProcesses[nCount][1] + " " + STR0030 } ) //"Processo" ; "n�o cadastrado corretamente." ; "� necess�rio que o processo" ; "esteja habilitado para inclus�o, altera��o, exclus�o e carga inicial."			
										
				Case Self:aProcesses[nCount][1] == "005" .OR. Self:aProcesses[nCount][1] == "007" .OR. Self:aProcesses[nCount][1] == "008"
					
					aAdd( Self:aPreRequisitesStatus, { .F., STR0006 + " " + Self:aProcesses[nCount][1] + " " + STR0028 , STR0029 + " " + Self:aProcesses[nCount][1] + " " + STR0033 } ) //"Processo" ; "n�o cadastrado corretamente." ; "� necess�rio que o processo" ; "esteja cadastrado e habilitado para inclus�o."
					
				Case Self:aProcesses[nCount][1] == "006" .OR. Self:aProcesses[nCount][1] == "016"
					
					aAdd( Self:aPreRequisitesStatus, { .F., STR0006 + " " + Self:aProcesses[nCount][1] + " " + STR0028 , STR0029 + " " + Self:aProcesses[nCount][1] + " " + STR0034 } ) //"Processo" ; "n�o cadastrado corretamente." ; "� necess�rio que o processo" ; "esteja cadastrado e habilitado para inclus�o e exclus�o."
					
			EndCase

		EndIf
				
		Self:Notify()
	Next

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ValTabs             �Autor�Vendas Clientes� Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �valida as tabelas dos processos da integracao  		      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ValTabs() Class LJCRM

	Local nCount				:= 0
	Local oLJCEntidadeFactory	:= LJCEntidadeFactory():New()	
	Local oRegistros			:= Nil
	Local oTabelas				:= Nil			
	
	oTabelas := oLJCEntidadeFactory:Create( "MDP" )	
	
	For nCount := 1 To Len(Self:aTables)
		
		If Self:lCancel
			Exit
		EndIf		
	
		oTabelas:Limpar()
		
		oTabelas:DadosSet( "MDP_PROCES", Self:aTables[nCount][1] )
		oTabelas:DadosSet( "MDP_TABELA", Self:aTables[nCount][2] )		
        
		oRegistros := oTabelas:Consultar(1)
		
		If oRegistros:Count() > 0
			
			Do Case
			
				Case Self:aTables[nCount][1] == "002" .OR. Self:aTables[nCount][1] == "003"
						
					If oRegistros:Elements(1):DadosGet( "MDP_HABILI" ) .AND. ;
					   oRegistros:Elements(1):DadosGet( "MDP_HABCAR" )
						
						aAdd( Self:aPreRequisitesStatus, { .T., STR0005 + " " + Self:aTables[nCount][2] + " " + STR0035 , "" } ) //"Tabela" ; "cadastrada corretamente."
					Else
						aAdd( Self:aPreRequisitesStatus, { .F., STR0005 + " " + Self:aTables[nCount][2] + " " + STR0036 , STR0037 + " " + Self:aTables[nCount][2] + " " + STR0038 + Self:aTables[nCount][1] } ) //"Tabela" ; "n�o cadastrada corretamente." ; "� necess�rio que a tabela"; "esteja habilitada e carga inicial configurada para o processo "
					EndIf
					
				Case Self:aTables[nCount][1] == "005" .OR. ;
				     Self:aTables[nCount][1] == "007" .OR. ;
				     Self:aTables[nCount][1] == "008" .OR. ;
					 Self:aTables[nCount][1] == "006" .OR. ;
					 Self:aTables[nCount][1] == "016"
					
					If oRegistros:Elements(1):DadosGet( "MDP_HABILI" )						
						aAdd( Self:aPreRequisitesStatus, { .T., STR0005 + " " + Self:aTables[nCount][2] + " " + STR0035 , "" } )//"Tabela" ; "cadastrada corretamente."
					Else
						aAdd( Self:aPreRequisitesStatus, { .F., STR0005 + " " + Self:aTables[nCount][2] + " " + STR0036 , STR0037 + " " + Self:aTables[nCount][2] + " " + STR0039 + Self:aTables[nCount][1] } ) //"Tabela" ; "n�o cadastrada corretamente." ; "� necess�rio que a tabela"; "esteja habilitada para o processo "
					EndIf
					
			EndCase
		
		Else
			
			Do Case
			
				Case Self:aTables[nCount][1] == "002" .OR. Self:aTables[nCount][1] == "003"
					
					aAdd( Self:aPreRequisitesStatus, { .F., STR0005 + " " + Self:aTables[nCount][2] + " " + STR0036 , STR0037 + " " + Self:aTables[nCount][2] + " " + STR0038 + Self:aTables[nCount][1] } ) //"Tabela" ; "n�o cadastrada corretamente." ; "� necess�rio que a tabela"; "esteja habilitada e carga inicial configurada para o processo "
					
				Case Self:aTables[nCount][1] == "005" .OR. ;
				     Self:aTables[nCount][1] == "007" .OR. ;
				     Self:aTables[nCount][1] == "008" .OR. ;
					 Self:aTables[nCount][1] == "006" .OR. ;
					 Self:aTables[nCount][1] == "016"
					
					aAdd( Self:aPreRequisitesStatus, { .F., STR0005 + " " + Self:aTables[nCount][2] + " " + STR0036 , STR0037 + " " + Self:aTables[nCount][2] + " " + STR0039 + Self:aTables[nCount][1] } )//"Tabela" ; "n�o cadastrada corretamente." ; "� necess�rio que a tabela"; "esteja habilitada para o processo "
					
			EndCase
		
		EndIf		
		
		Self:Notify()
	Next		

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ValParans           �Autor�Vendas Clientes� Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida as tabelas dos processos da integracao  		      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/	
Method ValParans() Class LJCRM

	Local oLJCEntidadeFactory	:= LJCEntidadeFactory():New()	
	Local oRegistros			:= Nil
	Local oParametros			:= Nil
	
	oParametros := oLJCEntidadeFactory:Create( "SX6" )
	
	oParametros:DadosSet( "X6_FIL", Space(Len(SX6->X6_FIL)) )	
	oParametros:DadosSet( "X6_VAR", "MV_LJGRINT" )
	
	oRegistros := oParametros:Consultar(1)
	
	If oRegistros:Count() > 0
		If GetNewPar("MV_LJGRINT")
			aAdd( Self:aPreRequisitesStatus, { .T., STR0023 + " MV_LJGRINT " + STR0040 , "" } ) //"Par�metro" ; "configurado corretamente."
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0023 + " MV_LJGRINT " + STR0041 , STR0042 } )//"Par�metro" ; "n�o configurado corretamente."; "Configurar o par�metro para verdadeiro."		
		EndIf
	Else
		aAdd( Self:aPreRequisitesStatus, { .F., STR0023 + " MV_LJGRINT " + STR0041 , STR0043 } )//"Par�metro" ; "n�o configurado corretamente."; "Criar o par�metro e configur�-lo para verdadeiro."			
	EndIf
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ValConfig           �Autor�Vendas Clientes� Data � 27/03/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida as configuracoes da integracao (MDQ)	  		      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/	
Method ValConfig() Class LJCRM

	Local oEntConfInt			:= Nil	
	Local oRegistros			:= Nil
	
	oEntConfInt := LJCEntParamInt():New()
	
	oEntConfInt:DadosSet("MDQ_CODIGO", "001")	
	
	oRegistros := oEntConfInt:Consultar(1)
	
	If oRegistros:Count() == 0
		aAdd( Self:aPreRequisitesStatus, { .F., STR0044 , STR0045 } )	//"As configura��es da integra��o n�o est�o cadastradas (Tabela MDQ)." ; "Por favor, verificar."
	Else
		aAdd( Self:aPreRequisitesStatus, { .T., STR0046 , ""} )//"A configuracao da integra��o esta corretamente cadastrada (Tabela MDQ)."
	EndIf
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf

Return Nil