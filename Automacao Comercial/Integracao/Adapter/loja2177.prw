#INCLUDE "PROTHEUS.CH"                              
#INCLUDE "LOJA2177.CH"
/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCSoftSite       �Autor  �Vendas Clientes     � Data �  12/04/2011 ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em configurar e validar a integra��o com o       ���
���          �produto SoftSite.                                                   ���
���          �Essa classe � herda a classe abstrata LJAIntegrationConfig.         ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCSoftSite From LJAIntegrationConfig
	Data aCamposObrigatorios
	Data aCamposNumericos
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

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  27/03/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCSoftSite.	                      ���
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
Method New() Class LJCSoftSite
	_Super:New()
	Self:aPreRequisitesStatus	:= {}
	Self:cText					:= ""
	
	// Processos que devem ser cadastrados no MDO 
	Self:aProcesses :=	{										;
		 					{ "001", STR0001	}	,;	// "Clientes"
							{ "002", STR0002	}	,;	// "Vendedores"
							{ "017", STR0003	}	,;	// "Tabelas gen�ricas"
							{ "018", STR0004	}	,;	// "Grupo de produtos"
							{ "019", STR0005	}	,;	// "Cab. tabela de pre�o"
							{ "020", STR0006	}	,;	// "Itens tabela de pre�o"
							{ "021", STR0007	}	,;	// "Condi��es de pagamento"
							{ "024", STR0008	}	,;	// "Empresas e filiais"
							{ "025", STR0009	}	;	// "Produtos e Grupo"
						}
						
	// Tabelas que devem ser cadastradas no MDP
	Self:aTables	:=	{						;
							{ "001", "SA1" }	,;
							{ "002", "SA3" }	,;
							{ "017", "SX5" }	,;
							{ "018", "SBM" }	,;
							{ "019", "DA0" }	,;
							{ "020", "DA1" }	,;
							{ "021", "SE4" }	,;
							{ "024", "SM0" }	,;
							{ "025", "SB1" }	,;
							{ "025", "SBM" }	;														
						}
							
	// Campos que devem estar configurados como obrigat�rios
	Self:aCamposObrigatorios :=	{					;
									"A1_COD"		,;
									"A1_NOME"		,;
									"A1_CGC"		,;
									"A1_MSBLQL"		,;									
									"A1_COND"		,;
									"A1_TABELA"		,;
									"A1_END"		,;
									"A1_BAIRRO"		,;
									"A1_MUN"		,;
									"A1_EST"		,;
									"A1_CEP"		,;
									"A1_CLASSE"		,;
									"A1_VEND"		,;
									"B1_COD"		,;
									"B1_GRUPO"		,;
									"B1_SITPROD"	,;
									"B1_ATIVO"		,;
									"B1_DESC"		,;
									"B1_UM"			,;
									"B1_SEGUM"		,;
									"B1_LM"			,;
									"B1_LE"			,;
									"BM_GRUPO"		,;
									"BM_TIPGRU"		,;
									"BM_DESC"		,;
									"DA0_CODTAB"	,;
									"DA0_DESCRI"	,;
									"DA0_DATDE"		,;
									"DA0_DATATE"	,;
									"DA0_HORADE"	,;
									"DA0_HORATE"	,;
									"DA1_CODPRO"	,;
									"DA1_CODTAB"	,;
									"DA1_PRCVEN"	,;
									"B2_COD"		,;
									"A3_NREDUZ"		,;
									"A3_SENHA"		,;
									"E4_CODIGO"		,;
									"E4_DESCRI"		,;
									"E4_COND"		,;
									"A4_COD"		,;
									"A4_NOME"		;
								}
									
	// Campos que devem estar configurados como numericos
	Self:aCamposNumericos :=	{					;
								}
								
	Self:lConfigured	:= .F.
	Self:lValidated		:= .F.
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetClassInterface�Autor  �Vendas Clientes� Data � 12/04/2011���
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
Method GetClassInterface() Class LJCSoftSite
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
Method GetDisplayName() Class LJCSoftSite
Return "SoftSite"

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
Method GetConfigurationText() Class LJCSoftSite
	Local cText		:= ""
	Local nCount	:= 0
	Local nProcess	:= 0
	
	cText += "<p>"
	cText += STR0010 // "Para criar automaticamente as configura��es basicas para o funcionamento da integra��o com a BestSales, clique no bot�o 'Configurar'."
	cText += "<br>"
	cText += 	STR0011 // "As seguintes configura��es ser�o efetuadas:"
	cText += 	"<ul>"
	cText += 		"<li> " + STR0012 + "</li>" // "Processos de integra��o:"
	cText += 		"<ul>"
	For nCount := 1 To Len(Self:aProcesses)
		cText += 			"<li>" + " " + Self:aProcesses[nCount][1] + " - " + Self:aProcesses[nCount][2] + "</li>"
	Next

	cText += 		"</ul>"		
	cText += 		"<li> " + STR0013 + "</li>" // "Tabelas dos processos de integra��o:"
	cText += 		"<ul>"
	For nCount := 1 To Len(Self:aTables)
		nProcess := aScan( Self:aProcesses, { |x| x[1] == Self:aTables[nCount][1] } )
		cText += 			"<li> " + STR0014 + " " + Self:aTables[nCount][2] + If(nProcess > 0, " - " + STR0015 + " " + Self:aProcesses[nProcess][1] + " - " + Self:aProcesses[nProcess][2],"") + "</li>" // "Tabela:" "Processo:"
	Next

	cText += 		"</ul>"			
	cText += 		"<li> " + STR0016 + "</li>" // "Par�metros:"
	cText += 		"<ul>"
	cText += 			"<li> " + STR0017 + "</li>" // "MV_LJGRINT como .T. para a gera��o da integra��o"
	cText += 		"</ul>"		
	cText += 		"<li> " + STR0018 + "</li>" // "Obrigatoriedade dos sequintes campos:"
	cText += 		"<ul>"
	For nCount := 1 To Len( Self:aCamposObrigatorios )
		cText += 			"<li> " + Self:aCamposObrigatorios[nCount] + "</li>"
	Next
	cText += 		"</ul>"			
	cText += 		"<li> " + STR0019 + "</li>" // "Picture dos sequintes campos:"
	cText += 		"<ul>"
	For nCount := 1 To Len( Self:aCamposNumericos )
		cText += 			"<li>" + " " + Self:aCamposNumericos[nCount] + "</li>"
	Next	
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
Method Configure() Class LJCSoftSite
	Local nCount				:= 0	
	Local oLJCEntidadeFactory	:= LJCEntidadeFactory():New()
	Local oCampos				:= Nil
	Local oParametros			:= Nil
	Local oProcessos			:= Nil
	Local oTabelas				:= Nil	
	
	Self:cText		:= ""
	Self:lCancel	:= .F.
	
	//����������������������Ŀ
	//�Cadastra os processos.�
	//������������������������
	For nCount := 1 To Len(Self:aProcesses)
		If Self:lCancel
			Exit
		EndIf	
		
		oProcessos := oLJCEntidadeFactory:Create( "MDO" )
		oProcessos:DadosSet( "MDO_CODIGO", Self:aProcesses[nCount][1] )		
		If oProcessos:Consultar(1):Count() == 0
			oProcessos:DadosSet( "MDO_DESCRI", Self:aProcesses[nCount][2] )
			oProcessos:DadosSet( "MDO_HABINC", .T. )
			oProcessos:DadosSet( "MDO_HABALT", .T. )
			oProcessos:DadosSet( "MDO_HABEXC", .T. )
			oProcessos:DadosSet( "MDO_HABCAR", .T. )
			oProcessos:Incluir()
			Self:cText += STR0020 + " " + Self:aProcesses[nCount][1] + " - " +Self:aProcesses[nCount][2] + "<br>" // "Adicionado processo"
		Else
			Self:cText += STR0021 + " " + Self:aProcesses[nCount][1] + " " + STR0022 + ";" + "<br>" // "Processo" "j� cadastrado"
		EndIf
		
		Self:Notify()
	Next
	
	//����������������������������������Ŀ
	//�Cadastra as tabelas dos processos.�
	//������������������������������������
	For nCount := 1 To Len(Self:aTables)
		If Self:lCancel
			Exit
		EndIf		
	
		oTabelas := oLJCEntidadeFactory:Create( "MDP" )
		oTabelas:DadosSet( "MDP_PROCES", Self:aTables[nCount][1] )
		oTabelas:DadosSet( "MDP_TABELA", Self:aTables[nCount][2] )
		If oTabelas:Consultar(1):Count() == 0
			oTabelas:DadosSet( "MDP_HABILI", .T. )
			oTabelas:DadosSet( "MDP_HABCAR", .T. )
			oTabelas:Incluir()
			Self:cText += STR0023 + " " + Self:aTables[nCount][1] + ";<br>" // "Adicionada tabela"
		Else
			Self:cText += STR0024 + " " + Self:aTables[nCount][1] + " " + STR0025 + "<br>" // "Tabela" "j� cadastrada;"
		EndIf		
		
		Self:Notify()
	Next	
	
	//������������������������Ŀ
	//�Configura os par�metros.�
	//��������������������������
	oParametros := oLJCEntidadeFactory:Create( "SX6" )
	oParametros:DadosSet( "X6_FIL", Space(Len(SX6->X6_FIL)) )		
	oParametros:DadosSet( "X6_VAR", "MV_LJGRINT" )
	
	If oParametros:Consultar(1):Count() == 0
		oParametros:DadosSet( "X6_TIPO",  "L" )
		oParametros:DadosSet( "X6_CONTEUD", "T" )
		oParametros:DadosSet( "X6_CONTSPA", "T" )
		oParametros:DadosSet( "X6_CONTENG", "T" )
		oParametros:Incluir()
		Self:cText += STR0026 + ";<br>" // "Adicionado par�metro " + "MV_LJGRINT e configurado para .T."
	Else
		oParametros:DadosSet( "X6_CONTEUD", "T" )
		oParametros:DadosSet( "X6_CONTSPA", "T" )
		oParametros:DadosSet( "X6_CONTENG", "T" )
		oParametros:Alterar(1)
		Self:cText += STR0027 + ";<br>" // "Par�metro MV_LJGRINT configurado para .T."
	EndIf			
	
	Self:Notify()		
	
	//���������������������������������������Ŀ
	//�Configura a obrigatoriedade dos campos.�
	//�����������������������������������������
	oCampos := oLJCEntidadeFactory:Create( "SX3" )
	For nCount := 1 To Len( Self:aCamposObrigatorios )
		oCampos:Limpar()
		oCampos:DadosSet( "X3_CAMPO", Self:aCamposObrigatorios[nCount] )
		
		If oCampos:Consultar(2):Count() > 0
			oCampos:DadosSet( "X3_OBRIGAT", "�" )
			oCampos:Alterar(2)
			Self:cText += STR0028 + " " + Self:aCamposObrigatorios[nCount] + " " + STR0029 + ";<br>" // "Campo" "configurado como obrigat�rio."
		EndIf
	Next
	
	Self:Notify() 
	
	//�������������������������������������Ŀ
	//�Configura a picture dos campos chave.�
	//���������������������������������������
	oCampos := oLJCEntidadeFactory:Create( "SX3" )
	For nCount := 1 To Len( Self:aCamposNumericos )
		oCampos:Limpar()
		oCampos:DadosSet( "X3_CAMPO", Self:aCamposNumericos[nCount] )
		
		If oCampos:Consultar(2):Count() > 0
			oCampos:DadosSet( "X3_PICTURE", "@9" )
			oCampos:Alterar(2)
			Self:cText += STR0028 + " " + Self:aCamposNumericos[nCount] + " " + STR0030 + ";<br>" // "Campo" "configurado com picture num�rica."
		EndIf
	Next
	
	Self:Notify()
	
	Self:lConfigured	:= .T.					
Return

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
Method Validate() Class LJCSoftSite 
	Local nCount				:= 0
	Local oLJCEntidadeFactory	:= LJCEntidadeFactory():New()	
	Local oRegistros			:= Nil
	Local oTabelaGenerica		:= Nil
	Local cPicture				:= ""
	Local lOnlyNumeric			:= .T.
	Local oGlobal				:= Nil
	Local oProcessos			:= Nil
	Local oTabelas				:= Nil		
	
	Self:lCancel := .F.
	Self:aPreRequisitesStatus := {}
	
	//��������������������������������������������Ŀ
	//�Chama as valida��es gen�ricas de integra��o.�
	//����������������������������������������������
	_Super:Validate()
	
	//�������������������������������������������Ŀ
	//�Verifica se os processos est�o cadastrados.�
	//���������������������������������������������
	oProcessos := oLJCEntidadeFactory:Create( "MDO" )
	For nCount := 1 To Len(Self:aProcesses)
		If Self:lCancel
			Exit
		EndIf	
		
		oProcessos:Limpar()
		oProcessos:DadosSet( "MDO_CODIGO", Self:aProcesses[nCount][1] )
		oRegistros := oProcessos:Consultar(1)
		
		If oRegistros:Count() > 0 
			If oRegistros:Elements(1):DadosGet( "MDO_HABINC" )			
				aAdd( Self:aPreRequisitesStatus, { .T., STR0031 + " " + Self:aProcesses[nCount][1] + " " + STR0032 , "" } ) // "Processo" "cadastrado corretamente."
			Else
				aAdd( Self:aPreRequisitesStatus, { .F., STR0031 + " " + Self:aProcesses[nCount][1] + " " + STR0033 , STR0034 + " " + Self:aProcesses[nCount][1] + " " + STR0035 } ) // "Processo" "n�o cadastrado corretamente." "� necess�rio que o processo" "esteja habilitado para inclus�o."
			EndIf
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0031 + " " + Self:aProcesses[nCount][1] + " " + STR0033 , STR0034 + " " + Self:aProcesses[nCount][1] + " " + STR0035 } ) // "Processo" "n�o cadastrado corretamente." "� necess�rio que o processo"
		EndIf
				
		Self:Notify()
	Next

	//�������������������������������������������������������Ŀ
	//�Verifica se as tabelas dos processos est�o cadastrados.�
	//���������������������������������������������������������
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
			If oRegistros:Elements(1):DadosGet( "MDP_HABILI" ) .And. oRegistros:Elements(1):DadosGet( "MDP_HABCAR" )
				aAdd( Self:aPreRequisitesStatus, { .T., STR0036 + " " + Self:aTables[nCount][1] + " " + STR0037 , "" } ) // "Tabela" "cadastrada corretamente."
			Else
				aAdd( Self:aPreRequisitesStatus, { .F., STR0036 + " " + Self:aTables[nCount][1] + " " + STR0038 , STR0039 + " " + Self:aTables[nCount][1] + " " + STR0040 } ) // "Tabela" "n�o cadastrada corretamente." "� necess�rio que a tabela" "esteja habilitada para inclus�o e carga."
			EndIf
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0036 + " " + Self:aTables[nCount][1] + " " + STR0038 , STR0039 + " " + Self:aTables[nCount][1] + " " + STR0041 } ) // "Tabela" "n�o cadastrada corretamente." "� necess�rio que a tabela" "esteja cadastrada, habilitada para inclus�o e carga."
		EndIf		
		
		Self:Notify()
	Next	

	//��������������������������������������������������������Ŀ
	//�Verifica se os par�metros necess�rios est�o cadastrados.�
	//����������������������������������������������������������
	oParametros := oLJCEntidadeFactory:Create( "SX6" )
	oParametros:DadosSet( "X6_FIL", Space(Len(SX6->X6_FIL)) )	
	oParametros:DadosSet( "X6_VAR", "MV_LJGRINT" )
	
	oRegistros := oParametros:Consultar(1)
	
	If oRegistros:Count() > 0
		If GetNewPar("MV_LJGRINT")
			aAdd( Self:aPreRequisitesStatus, { .T., STR0042 , "" } ) // "Par�metro MV_LJGRINT configurado corretamente."
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0043 , STR0044 } ) // "Par�metro MV_LJGRINT n�o configurado corretamente." "Configurar o par�metro para verdadeiro."
		EndIf
	Else
		aAdd( Self:aPreRequisitesStatus, { .F., STR0043 , STR0045 } ) // "Par�metro MV_LJGRINT n�o configurado corretamente." "Criar o par�metro e configur�-lo para verdadeiro."
	EndIf
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf
	
	//�������������������������������������������������������������������Ŀ
	//�Verifica se os campos obrigat�rios, est�o configurados corretmante.�
	//���������������������������������������������������������������������	
	For nCount := 1 To Len( Self:aCamposObrigatorios )
		If Self:lCancel
			Exit
		EndIf	
	
		If X3Obrigat( Self:aCamposObrigatorios[nCount] )
			aAdd( Self:aPreRequisitesStatus, { .T., STR0028  + " " + Self:aCamposObrigatorios[nCount] + " " + STR0046 , "" } ) // "Campo" "configurado corretamente."
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0028 + " " + Self:aCamposObrigatorios[nCount] + " " + STR0047 , STR0048 } ) // "Campo"  "n�o configurado corretamente." "Configure o campo como obrigat�rio."
		EndIf
	Next
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//�Verifica se as chaves da tabela SX5 tem conte�do para exporta��o.�
	//�������������������������������������������������������������������
	oTabelaGenerica := oLJCEntidadeFactory:Create( "SX5" )
	
	oTabelaGenerica:DadosSet( "X5_TABELA", "V0" )		
	oRegistros := oTabelaGenerica:Consultar(1)
	
	If oRegistros:Count() > 0
		aAdd( Self:aPreRequisitesStatus, { .T., STR0049 , "" } ) // "Tabela SX5 V0 com items."
	Else
		aAdd( Self:aPreRequisitesStatus, { .F., STR0050 , STR0051 } ) // "Tabela SX5 V0 sem items." "Cadastrar os itens b�sicos da tabela SX5 V0."
	EndIf
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf
	
	oTabelaGenerica:Limpar()	
	oTabelaGenerica:DadosSet( "X5_TABELA", "T2" )
	oRegistros := oTabelaGenerica:Consultar(1)
	
	If oRegistros:Count() > 0
		aAdd( Self:aPreRequisitesStatus, { .T., STR0052 , "" } ) // "Tabela SX5 T2 com items."
	Else
		aAdd( Self:aPreRequisitesStatus, { .F., STR0053 , STR0054 } ) // "Tabela SX5 T2 sem items." "Cadastrar os itens b�sicos da tabela SX5 T2."
	EndIf		
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf		      
	
	oTabelaGenerica:Limpar()	
	oTabelaGenerica:DadosSet( "X5_TABELA", "24" )
	oRegistros := oTabelaGenerica:Consultar(1)
	
	If oRegistros:Count() > 0
		aAdd( Self:aPreRequisitesStatus, { .T., STR0055 , "" } ) // "Tabela SX5 24 com items."
	Else
		aAdd( Self:aPreRequisitesStatus, { .F., STR0056 , STR0057 } ) // "Tabela SX5 24 sem items." "Cadastrar os itens b�sicos da tabela SX5 24."
	EndIf		
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf	
	
	oTabelaGenerica:Limpar()	
	oTabelaGenerica:DadosSet( "X5_TABELA", "12" )
	oRegistros := oTabelaGenerica:Consultar(1)
	
	If oRegistros:Count() > 0
		aAdd( Self:aPreRequisitesStatus, { .T., STR0058 , "" } ) // "Tabela SX5 12 com items."
	Else
		aAdd( Self:aPreRequisitesStatus, { .F., STR0059 , STR0060 } ) // "Tabela SX5 12 sem items." "Cadastrar os itens b�sicos da tabela SX5 12."
	EndIf		
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf		
	
	//����������������������������������������������������������������������������������������Ŀ
	//�Verifica se os campos que devem receber somente n�mero, est�o configurados corretamente.�
	//������������������������������������������������������������������������������������������
	oCampos := oLJCEntidadeFactory:Create( "SX3" )

	For nCount := 1 To Len( Self:aCamposNumericos )
		If Self:lCancel
			Exit
		EndIf	
	
		oCampos:Limpar()
		oCampos:DadosSet( "X3_CAMPO", Self:aCamposNumericos[nCount] )
		oRegistros := oCampos:Consultar(2)
		If oRegistros:Count() > 0
			cPicture := oRegistros:Elements(1):DadosGet( "X3_PICTURE" )
			If AllTrim(cPicture) == Replicate( "9", oRegistros:Elements(1):DadosGet( "X3_TAMANHO" ) ) .Or. AllTrim(cPicture) == "@9"
				aAdd( Self:aPreRequisitesStatus, { .T., STR0028 + " " + Self:aCamposNumericos[nCount] + " " + STR0061 , "" } )	// "Campo" "configurado corretamente."
			Else
				aAdd( Self:aPreRequisitesStatus, { .F., STR0028 + " " + Self:aCamposNumericos[nCount] + " " + STR0062 , STR0063 + " (Picture:" + " " + Replicate( "9", oRegistros:Elements(1):DadosGet( "X3_TAMANHO" ) ) + " " + STR0064 + " @9)." } )	// "Campo" "n�o configurado corretamente." "ou"
			EndIf
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0028 + " " + Self:aCamposNumericos[nCount] + " " + STR0065 , STR0066 } )			// "Campo" "n�o existe no dicion�rio de dados." "Adicione o campo ao dicion�rio."
		EndIf
	Next
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf
	
	//����������������������������������������������������������������������Ŀ
	//�Verifica se os campos da tabela SX5 V0 e T2 est�o somente com n�meros.�
	//������������������������������������������������������������������������
	oTabelaGenerica := oLJCEntidadeFactory:Create( "SX5" )
	oGlobal := LJCGlobal():Global()
	
	oTabelaGenerica:DadosSet( "X5_TABELA", "V0" )		
	oRegistros := oTabelaGenerica:Consultar(1)	
	For nCount := 1 To oRegistros:Count()
		If !oGlobal:Funcoes():IsNumeric(oRegistros:Elements(nCount):DadosGet( "X5_CHAVE"))
			lOnlyNumeric := .F.		
		EndIf
	Next	
	
	If lOnlyNumeric
		aAdd( Self:aPreRequisitesStatus, { .T., STR0067 , "" } )	// "Tabela SX5 V0 s� tem registros com chave n�merica."
	Else
		aAdd( Self:aPreRequisitesStatus, { .F., STR0068 , STR0069 } ) // "Tabela SX5 V0 n�o tem somente registros com chave n�merica." "Configure os registros da tabela SX5 V0 com chave �nica num�rica."
	EndIf
	
	lOnlyNumeric := .T. 
	
	oTabelaGenerica:DadosSet( "X5_TABELA", "T2" )		
	oRegistros := oTabelaGenerica:Consultar(1)	
	For nCount := 1 To oRegistros:Count()
		If !oGlobal:Funcoes():IsNumeric(oRegistros:Elements(nCount):DadosGet( "X5_CHAVE"))
			lOnlyNumeric := .F.		
		EndIf
	Next	
	
	If lOnlyNumeric
		aAdd( Self:aPreRequisitesStatus, { .T., STR0070 , "" } )  //	"Tabela SX5 T2 s� tem registros com chave n�merica."
	Else
		aAdd( Self:aPreRequisitesStatus, { .F., STR0071 , STR0072 } ) // "Tabela SX5 T2 n�o tem somente registros com chave n�merica." "Configure os registros da tabela SX5 T2 com chave �nica num�rica."
	EndIf	
	
	If Self:lCancel
		Return
	Else
 		Self:Notify()	
	EndIf	
	
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
Method GetEndText( lLoaded ) Class LJCSoftSite
	Local cText := ""
	
	cText += "<p>"
	cText += STR0073 // "A seguir um resumo das tarefas executadas:"
	cText += "<br>"		
	cText += 	"<ul>"
	cText += 		"<li>" + " " + STR0074 + " " + If( Self:lConfigured, "<font color='green'>" + STR0075 + "</font>", "<font color='red'>" + STR0076 + "</font>" ) + "</li>"	// "Configura��o do sistema:" "Efetuado" "N�o efetuado"
	cText += 		"<li>" + " " + STR0077 + " " + If( Self:lValidated, "<font color='green'>" + STR0075 + "</font>", "<font color='red'>" + STR0076 + "</font>" ) + "</li>" // "Valida��o do sistema:" "Efetuado" "N�o efetuado"
	cText += 		"<li>" + " " + STR0078 + " " + If( lLoaded, "<font color='green'>" + STR0075 + "</font>", "<font color='red'>" + STR0076 + "</font>" ) + "</li>" // "Carga inicial:" "Efetuado" "N�o efetuado"
	cText += 	"</ul>"	
	cText += "</p>"	
Return cText