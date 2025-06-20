#INCLUDE "PROTHEUS.CH"  
#INCLUDE "LOJA2515.CH"


#DEFINE _SIM 			"1"
#DEFINE _NAO 			"2"        
#DEFINE _SINCRONO 		"1"
#DEFINE _ASSINCRONO 	"2"   
#DEFINE _TODOS 			"1"   
#DEFINE _EAI 			"2"                      

          
/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCFinSer         �Autor  �Vendas Clientes     � Data �  02/04/12   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em configurar e validar a integra��o com o       ���
���          �produto Financial Services da empresa Financial Serbices.           ���
���          �Essa classe � herda a classe abstrata LJAIntegrationConfig.         ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCFinSer From LJAIntegrationConfig
	Data aCamposObrigatorios	// Campos que devem estar configurados como obrigat�rios
	Data lConfigured     		//Configurado                     
	Data lValidated      		//Validado
	Data aParametros     		//Parametros
	Data aProcesses      		//Processos de Integracao
	Data aTables         		//Tabelas
	Data aTamCampos      		//Tamanho dos campos
	Data aTabComp        		//Forma de compartilhamento das tabelas - Grupo, Regional , Unidade Negocio, Empresa, Filial
	Data aPicCampos			    //Picture dos campos  

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
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  02/04/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCFinSer.	                          ���
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
Method New() Class LJCFinSer
	Local cMvJurTipo := ""  //Tipo de calculo de juros
	Local aCompSE1				:= {"SE1",; //Alias
									"C",; //Empresa
									"C",; //Unidade de Neg�cio 
									"C";  //Filial
									}  //Forma de compartilhamento da SE1
	                                //Empresa
	
	_Super:New()
	Self:aPreRequisitesStatus	:= {}
	Self:cText					:= "" 

				
	// Campos que devem estar configurados como obrigat�rios
	Self:aCamposObrigatorios :=	{	} 
	
	Self:aParametros := { {	Space(Len(SX6->X6_FIL)),;  //"X6_FIL",
							"MV_LJINTFS",; //"X6_VAR"
							"L",; //"X6_TIPO"
					   		"T",; //"X6_CONTEUD"
							"T",; //"X6_CONTSPA"
							"T",; //"X6_CONTENG"  
							STR0001,; //"para gera��o da integra��o"
							.T.;  //Valor requerido
						},;
						{	Space(Len(SX6->X6_FIL)),;  //"X6_FIL",
							"MV_LJPARFA",; //"X6_VAR"
							"L",; //"X6_TIPO"
					   		"T",; //"X6_CONTEUD"
							"T",; //"X6_CONTSPA"
							"T",; //"X6_CONTENG"
							STR0002,;  //"para realizar o sequenciamento das parcelas das vendas do loja, igual � emiss�o NF"
							.T.;
						},;   
						{	Space(Len(SX6->X6_FIL)),;  //"X6_FIL",
							"MV_VALCNPJ",; //"X6_VAR"
							"C",; //"X6_TIPO"
					   		"2",; //"X6_CONTEUD"
							"2",; //"X6_CONTSPA"
							"2",; //"X6_CONTENG" 
							STR0003,;   //"para n�o permitir CNPJ duplicados no cadastro de clientes"
							"2";
						},; 
						{	Space(Len(SX6->X6_FIL)),;  //"X6_FIL",
							"MV_VALCPF",; //"X6_VAR"
							"C",; //"X6_TIPO"
					   		"2",; //"X6_CONTEUD"
							"2",; //"X6_CONTSPA"
							"2",; //"X6_CONTENG"
							STR0004,; //"para n�o permitir CPF duplicados no cadastro de clientes"
							"2";
						},;
						{	Space(Len(SX6->X6_FIL)),;  //"X6_FIL",
							"MV_TIPACRD",; //"X6_VAR"
							"N",; //"X6_TIPO"
					   		"3",; //"X6_CONTEUD"
							"3",; //"X6_CONTSPA"
							"3",; //"X6_CONTENG"  
							STR0005,; //"para utilizar o Financial Services para an�lise de cr�dito no or�amento"
							3;
						},;
						{	Space(Len(SX6->X6_FIL)),;  //"X6_FIL",
							"MV_VLBXREC",; //"X6_VAR"
							"C",; //"X6_TIPO"
					   		"3",; //"X6_CONTEUD"
							"3",; //"X6_CONTSPA"
							"3",; //"X6_CONTENG"  
							STR0073,; ////Define se permite baixar o titulo com o valor recebido  menor que a soma dos valores de multa, juros e descontos"
							"3";						
						},;		
						{	Space(Len(SX6->X6_FIL)),;  //"X6_FIL",
							"MV_LJCALJM",; //"X6_VAR"
							"L",; //"X6_TIPO"
					   		"F",; //"X6_CONTEUD"
							"F",; //"X6_CONTSPA"
							"F",; //"X6_CONTENG"  
						     STR0074,;//"Define se calcula juros e multa dos titulos a receber independente da data de vencimento do(s) titulos"
							.F.;
						},;						
						{	Space(Len(SX6->X6_FIL)),;  //"X6_FIL",
						  	"MV_LJIFSJU",; //"X6_VAR"
							"C",; //"X6_TIPO"
					   		cMvJurTipo,; //"X6_CONTEUD"
							cMvJurTipo,; //"X6_CONTSPA"
							cMvJurTipo,; //"X6_CONTENG"  
							STR0052 + STR0068,; //"para configurar qual o c�lculo de juros do Financial Services." + " Este parametro deve tambem ter seu conteudo igual ao parametro MV_JURTIPO."                                                                                                                                                                                                                                                                                                                                                                                                                                                    
							cMvJurTipo;
						};
						}						
						
								
	Self:lConfigured	:= .F.
	Self:lValidated		:= .F.        
	
	
	Self:aTamCampos     := { { "SE1", "E1_PREFIXO", "C", 3, 0, "" },;
							 { "SE1", "E1_NUM", "C", 9, 0, "" },;  
							 { "SE1", "E1_TIPO", "C", 3, 0, "" },; 
							 { "SE1", "E1_PARCELA", "C", 3, 0, "" },;
							 { "SL1", "L1_VALBRUT", "N", 14, 5, "" },;
							 { "SL1", "L1_DESCONT", "N", 14, 5, ""},;
							 { "SL1", "L1_JUROS", "N", 14, 5, "" },; 
							 { "SL2", "L2_QUANT", "N", 4, 0, "" },;
							 { "SL2", "L2_VRUNIT", "N", 9, 2, "" },;
							 { "SL2", "L2_VLRITEM", "N", 20, 5, "" },;	
							 { "SL2", "L2_VALIPI", "N", 20, 5, "" },;
							 { "SL2", "L2_ICMSRET", "N", 20, 5, "" },;						 
							 { "SL4", "L4_VALOR", "N", 14, 5 , ""},;
							 { "MA8", "MA8_RENDA", "N", 20, 5, ""},;
							 { "MA7", "MA7_CELULA", "C", 15, 0, "(999)XXXXXXXXXX"};							 							 
							  }        

	Self:aPicCampos := { {"MA7", "MA7_CELULA","(999)XXXXXXXXXX"}}
							 
	Self:aTabComp 		:=  { aClone(aCompSE1),;   //SE1
							  aClone(aCompSE1) ,;   //SE5
							  aClone(aCompSE1),;//MEQ
							  aClone(aCompSE1)}   //SEF  
	
	Self:aTabComp[2,1] := "SE5"
	Self:aTabComp[3,1] := "SEF"	
	Self:aTabComp[4,1] := "MEQ"					 
	
	_Super:SetEAI20(.T.) //Habilita o EAI 2.0 
	
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetClassInterface�Autor  �Vendas Clientes� Data � 02/04/12  ���
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
Method GetClassInterface() Class LJCFinSer
Return "LJIIntegrationConfig"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetDisplayName   �Autor  �Vendas Clientes� Data � 02/04/12  ���
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
Method GetDisplayName() Class LJCFinSer
Return "Financial Services"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetConfigurationText�Autor�Vendas Clientes� Data � 02/04/12 ���
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
Method GetConfigurationText() Class LJCFinSer
	Local cText		:= ""    //Texto a ser exibido
	Local nCount	:= 0     //Variavel contadora

	
	cText += "<p>"
	cText += STR0006 //"Para criar automaticamente as configura��es b�sicas para o funcionamento da integra��o com o Financial Services, clique no bot�o 'Configurar'."
	cText += "<br>"
	cText += 	STR0007 // "As seguintes configura��es ser�o efetuadas:"
	cText += 	"<ul>"
	cText += 		"<li> " + STR0008 + "</li>" // "Processos de integra��o:"
	cText += 		"<ul>"
	For nCount := 1 To Len(Self:aProcesses)
		cText += 			"<li>" + " " + Self:aProcesses[nCount][1] + " - " + Self:aProcesses[nCount][2] + "</li>"
	Next
	cText += 		"</ul>"			
   
    If  Len( Self:aParametros ) > 0
		cText += 		"<li> " + STR0009 + "</li>" // "Par�metros:"   
		cText += 		"<ul>"
		
		For nCount := 1 To Len( Self:aParametros )
			cText += 			"<li> " + Self:aParametros[nCount, 02] + STR0010 + cValToChar(Self:aParametros[nCount, 08]) + space(1)+ Self:aParametros[nCount, 07]+ "</li>"  //como
		Next	
		cText += 		"</ul>"		
	EndIf
    
	If Len( Self:aCamposObrigatorios ) > 0  
	
		cText += 		"<li> " + STR0011 + "</li>" // "Obrigatoriedade dos sequintes campos:"
		cText += 		"<ul>"
		For nCount := 1 To Len( Self:aCamposObrigatorios )
			cText += 			"<li> " + Self:aCamposObrigatorios[nCount] + "</li>"
		Next  
		cText += 		"</ul>" 
		
	EndIf
			
	cText += 	"</ul>"
	cText += "</p>"	
	
Return cText

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Configure           �Autor�Vendas Clientes� Data � 02/04/12 ���
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
Method Configure() Class LJCFinSer
	Local nCount				:= 0	                            //Vari�vel contadora
	Local oLJCEntidadeFactory	:= LJCEntidadeFactory():New()       //Objeto oLJCEntidadeFactory 
	Local oCampos				:= Nil                              //Objeto de Campos
	Local oParametros			:= Nil                              //Objeto de parametros
	
	Self:cText		:= ""
	Self:lCancel	:= .F.
	

	oParametros := oLJCEntidadeFactory:Create( "SX6" )
	For nCount := 1 To Len( Self:aParametros )
		//������������������������Ŀ
		//�Configura os par�metros.�
		//��������������������������

		oParametros:DadosSet( "X6_FIL", Self:aParametros[nCount, 01] )		
		oParametros:DadosSet( "X6_VAR", Self:aParametros[nCount, 02] )
		
		If oParametros:Consultar(1):Count() == 0
			oParametros:DadosSet( "X6_TIPO",  Self:aParametros[nCount, 03] )
			oParametros:DadosSet( "X6_CONTEUD", Self:aParametros[nCount, 04] )
			oParametros:DadosSet( "X6_CONTSPA", Self:aParametros[nCount, 05] )
			oParametros:DadosSet( "X6_CONTENG", Self:aParametros[nCount, 06] )
			oParametros:Incluir()
			Self:cText += STR0012 +Self:aParametros[nCount, 02] + STR0013 + cValToChar(Self:aParametros[nCount, 08]) + ";<br>" // "Adicionado par�metro " + "#########" + " e configurado para #####"
		Else
			oParametros:DadosSet( "X6_CONTEUD", Self:aParametros[nCount, 04] )
			oParametros:DadosSet( "X6_CONTSPA", Self:aParametros[nCount, 05] )
			oParametros:DadosSet( "X6_CONTENG", Self:aParametros[nCount, 06] )
			oParametros:Alterar(1)
			Self:cText += STR0014 +  Self:aParametros[nCount, 02] + STR0015 + cValToChar(Self:aParametros[nCount, 08]) + ";<br>" // "Par�metro " + ###### + " configurado para ######"
		EndIf
					
	Next
	
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
			Self:cText += STR0016 + " " + Self:aCamposObrigatorios[nCount] + " " + STR0017 + ";<br>" // "Campo" "configurado como obrigat�rio."
		EndIf
	Next   
	
	//���������������������������������������Ŀ
	//�Configura a picture dos campos.        �
	//�����������������������������������������
	oCampos := oLJCEntidadeFactory:Create( "SX3" )
	For nCount := 1 To Len( Self:aPicCampos )
		oCampos:Limpar()
		oCampos:DadosSet( "X3_CAMPO", Self:aPicCampos[nCount,2] )
		
		If oCampos:Consultar(2):Count() > 0
			oCampos:DadosSet( "X3_PICTURE", Self:aPicCampos[nCount,3])
			oCampos:Alterar(2)
			Self:cText += STR0016 + " " + Self:aPicCampos[nCount, 2] + " " + STR0070 + Self:aPicCampos[nCount,3] + ";<br>" // "Campo" " configurada a picture "
		EndIf
	Next
	
	Self:Notify() 
	
	Self:lConfigured	:= .T.					
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Validate            �Autor�Vendas Clientes� Data � 02/04/12 ���
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
Method Validate() Class LJCFinSer 
	Local nCount				:= 0    //Variavel contadora
	Local oLJCEntidadeFactory	:= LJCEntidadeFactory():New() //Objeto LJCEntidadeFactory
	Local oRegistros			:= Nil                        //Obejto registros
	Local lUpd90Ok				:= FindFunction("LjUpd90Ok") .AND. LjUpd90Ok() //Verifica a execu��o do Update U_UPD90
	Local cFilXX4 				:= xFilial("XX4") //Filial do XX4
	Local cMsgEAI				:= ""  //Mensagem de configura��o do EAI
	Local aTamSX3				:= {}  //Tamanho dos campos
	Local aCompTab				:= {}  //Comportilhamento das tabelas
	Local cMsgComp				:= "" //Mensagem de compartilhamento das tabelas  
	Local cTxtAdd				:= "" //Texto adicional ao par�metro de validacao do parametro de juros e multas	 
	Local cMvJurTipo			:= SuperGetMv("MV_JURTIPO",,"")   //Conteudo do parametro MV_JURTIPO
	Local nMvFinJrTp			:= SuperGetMv("MV_FINJRTP",,1)  
	Local aRotinas := {{ 	"LOJA2503",; //XX4_ROTINA,
							"MESACREDITO",; //XX4_MODEL (MENSAGEM)
							_NAO,; //XX4_SENDER
							_SIM,; //XX4_RECEIV
							_SINCRONO,; //XX4_METODO
							_EAI,;   //XX4_CHANNEL
							_SIM,;  //XX4_UNIMESS
							_TODOS },; //XX4_TOPOPER
					   {	"LOJA2507",;//XX4_ROTINA,
					   		"ANALISECREDITO", ; //XX4_MODEL (MENSAGEM)
					   		_SIM,; //XX4_SENDER
					   		_SIM,;//XX4_RECEIV
					   		_SINCRONO,;//XX4_METODO
					   		_EAI,;//XX4_CHANNEL
					   		_SIM,;//XX4_UNIMESS
					   		_TODOS},; //XX4_TOPOPER
					   {	"LOJA2510",;//XX4_ROTINA,
					   		"TITULOCAP",;//XX4_MODEL (MENSAGEM)
					   		_SIM,;//XX4_SENDER
					   		_NAO,;//XX4_RECEIV
					   		_SINCRONO,;//XX4_METODO
					   		_EAI,;//XX4_CHANNEL
					   		_SIM,;//XX4_UNIMESS
					   		_TODOS}, ;//XX4_TOPOPER
					   {	"LOJA2512",;//XX4_ROTINA,
					   		"BAIXATITULOCAP",;//XX4_MODEL (MENSAGEM)
					   		_SIM,;//XX4_SENDER
					   		_NAO,;//XX4_RECEIV
					   		_SINCRONO,;//XX4_METODO
					   		_EAI,;//XX4_CHANNEL
					   		_SIM,;//XX4_UNIMESS
					   		_TODOS}}//XX4_TOPOPER      //Rotinas cadastradas no Adapter
					   				
	Self:lCancel := .F.
	Self:aPreRequisitesStatus := {} 

	
	//��������������������������������������������Ŀ
	//�Chama as valida��es gen�ricas de integra��o.�
	//����������������������������������������������
	_Super:Validate() 
	
	oParametros := oLJCEntidadeFactory:Create( "XX4" )
  	For nCount := 1 To Len( aRotinas )  
        
  		cMsgEAI := STR0018 + aRotinas[nCount, 02] + space(5) +;  //"Mensagem: "
  					STR0019 + IIF(aRotinas[nCount, 03] == _SIM, STR0020, STR0021)+ space(2)+; //"Envia: " "Sim""N�o"
  					STR0022 + IIF(aRotinas[nCount, 04] == _SIM, STR0020, STR0021) + CRLF +;   //"Recebe: " "Sim""N�o"
  					STR0023 + IIF(aRotinas[nCount, 05] == _ASSINCRONO,STR0024, STR0025 )+ space(5)+;   //"M�todo: " //"Ass�ncrono" "S�ncrono"
  					STR0026 + IIF(aRotinas[nCount, 06] == _EAI,STR0027, "")  + CRLF +;    //"Canal Envio: ""EAI"
  					STR0028 +  IIF(aRotinas[nCount, 07] == _SIM, STR0020, STR0021)+ space(5)+;   //"Mensagem �nica: ""Sim""N�o"
  					STR0029 +  IIF(aRotinas[nCount, 08] == _TODOS,STR0030, "")    //"Opera��o: ""Todos"


		oParametros:DadosSet( "XX4_FILIAL", cFilXX4 )	
		oParametros:DadosSet( "XX4_ROTINA", aRotinas[nCount, 01] )
		
		oRegistros := oParametros:Consultar(1) //XX4_FILIAL + XX4_ROTINA

		If 	oRegistros:Count() > 0
	 		aAdd( Self:aPreRequisitesStatus, { .T., STR0031 + aRotinas[nCount, 01] +STR0032 , STR0033 + cMsgEAI } ) //"Adapter " "cadastrado" "Verifique o conte�do campos -  " 
		Else  			
	 		aAdd( Self:aPreRequisitesStatus, { .T., STR0031 + aRotinas[nCount, 01] +STR0034 , STR0035 + cMsgEAI } ) //"Adapter " " n�o cadastrado"	"Cadastre com o conte�do dos campos - "
		EndIf
	
	Next nCount

	
 	If lUpd90Ok
 		aAdd( Self:aPreRequisitesStatus, { .T., STR0036 , "" } ) // "Compatibilizador U_UPDLOJ90 executado ou campos criados, conforme Boletim T�cnico. Integra��o Protheus X Financial Service"
    Else 
    	aAdd( Self:aPreRequisitesStatus, { .F., STR0037 , STR0038} )    //"Compatibilizador U_UPDLOJ90 n�o executado.""Executar o compatibilizador U_UPDLOJ90 ou criar os campos manualmente, conforme Boletim T�cnico."
    EndIf



	For nCount := 1 To Len( Self:aTabComp )  
	
		If Self:lCancel
			Exit
		EndIf   
		
		
		cMsgComp := STR0053 + IIF( Self:aTabComp[nCount,2] == "C", STR0054, STR0055) +;  //"Empresa: ""(C)ompartilhado""(E)xclusivo"
					STR0056 + IIF( Self:aTabComp[nCount,2] == "C", STR0054, STR0055)+; //", Unidade de Negocio: ""(C)ompartilhado""(E)xclusivo"
					STR0057 + IIF( Self:aTabComp[nCount,2] == "C", STR0054, STR0055)   //", Filial: ""(C)ompartilhado""(E)xclusivo"
		
		aCompTab := {FWModeAccess(Self:aTabComp[nCount,1], 1), FWModeAccess(Self:aTabComp[nCount,1], 2) , FWModeAccess(Self:aTabComp[nCount,1], 3)  }
		
		If aCompTab[1]  <> Self:aTabComp[nCount,2]  .OR.  aCompTab[2]  <> Self:aTabComp[nCount,3] .OR. aCompTab[3]  <> Self:aTabComp[nCount,4]
		
			aAdd( Self:aPreRequisitesStatus, { .F., STR0058 +Self:aTabComp[nCount,1] + STR0059  , STR0060 + cMsgComp} ) // "Tabela "" com forma de compartilhamento incompat�vel para a integracao com o Financial Se "Para a integra��o as  formas de compartilhamento dever�o ser:  "
		Else 
			aAdd( Self:aPreRequisitesStatus, { .T., STR0058 +Self:aTabComp[nCount,1] + STR0061} ) // "Tabela "" com forma de compartilhamento correta."
			
		EndIf
		
    Next nCount		
	
	
	For nCount := 1 To Len( Self:aTamCampos )  
	
		If Self:lCancel
			Exit
		EndIf  
		
		aTamSX3 := (Self:aTamCampos[nCount,1])->(TamSX3(Self:aTamCampos[nCount,2]))
		
		If aTamSX3[1]  > Self:aTamCampos[nCount,4]  .OR.  ( aTamSX3[1]  > Self:aTamCampos[nCount,4] .AND. aTamSX3[2]  > Self:aTamCampos[nCount,5])
		
			aAdd( Self:aPreRequisitesStatus, { .F., STR0062 +Self:aTamCampos[nCount,2] + "(" + LTrim(Str(aTamSX3[1])) + "," + LTrim(Str(aTamSX3[2])) + ")" + STR0063 , STR0064 + cValToChar(Self:aTamCampos[nCount, 04]) + STR0065+ cValToChar(Self:aTamCampos[nCount, 05]) + STR0066} ) // "Campo ""com tamanho superior ao definido para integracao com o Financial" "Para a integra��o o tamanho do campo devera ser:  "  "inteiros e " " decimais"

			If !Empty(Self:aTamCampos[nCount,6])  .AND. ( RTrim(X3Picture( Self:aTamCampos[nCount,2] )) <> Self:aTamCampos[nCount,6] )
				aAdd( Self:aPreRequisitesStatus, { .F., STR0062 +Self:aTamCampos[nCount,2] + "[" + RTrim(X3Picture( Self:aTamCampos[nCount,2] ) ) +  "]" + STR0071 , STR0072 + Self:aTamCampos[nCount,6] } ) // "Campo "" com picture divergente da definida para integracao com o Financial""Para a integra��o a picture dever� ser: "
			EndIf

		Else 
			If Empty(Self:aTamCampos[nCount,6])  .OR. ( RTrim(X3Picture( Self:aTamCampos[nCount,2] ))   ==  Self:aTamCampos[nCount,6] )
				aAdd( Self:aPreRequisitesStatus, { .T., STR0062 +Self:aTamCampos[nCount,2] + STR0067 } ) // "Campo "" configurado corretamente."
			Else 
				aAdd( Self:aPreRequisitesStatus, { .F., STR0062 +Self:aTamCampos[nCount,2] + "[" + RTrim(X3Picture( Self:aTamCampos[nCount,2] ) ) +  "]" + STR0071 , STR0072 + Self:aTamCampos[nCount,6] } ) //  "Campo "" com picture divergente da definida para integracao com o Financial""Para a integra��o a picture dever� ser: "
			EndIf
		EndIf
		
    Next nCount	 
    
    	
	//��������������������������������������������������������Ŀ
	//�Verifica se os par�metros necess�rios est�o cadastrados.�
	//����������������������������������������������������������
	oParametros := oLJCEntidadeFactory:Create( "SX6" ) 
	
	For nCount := 1 To Len( Self:aParametros )  
	
		If Self:lCancel
			Exit
		EndIf
		
		oParametros:DadosSet( "X6_FIL", Self:aParametros[nCount, 01] )	
		oParametros:DadosSet( "X6_VAR", Self:aParametros[nCount, 02] )
		
		oRegistros := oParametros:Consultar(1)
		
		If Self:aParametros[nCount, 02] == "MV_LJIFSJU"  
			Self:aParametros[nCount, 08] := "S ou C"
			cTxtAdd := STR0069 //" e com o conte�do igual ao par�metro MV_JURTIPO."
		Else
			cTxtAdd := ""
		EndIf
		
		If oRegistros:Count() > 0                                                    //39
			If ( 	GetNewPar(Self:aParametros[nCount, 02]) == Self:aParametros[nCount, 08] .OR. ;
					(Self:aParametros[nCount, 02] == "MV_LJIFSJU" .AND. GetNewPar(Self:aParametros[nCount, 02]) $ Self:aParametros[nCount, 08]) ) .AND.;
				(Self:aParametros[nCount, 02] <> "MV_LJIFSJU" .OR. GetNewPar(Self:aParametros[nCount, 02]) == cMvJurTipo) //alterar para validar o conteudo
					
				aAdd( Self:aPreRequisitesStatus, { .T., STR0014 + Self:aParametros[nCount, 02] + STR0039, "" } ) //  "Par�metro " " configurado corretamente." 

			Else
				aAdd( Self:aPreRequisitesStatus, { .F., STR0014 +Self:aParametros[nCount, 02] + STR0040 , STR0041 + cValToChar(Self:aParametros[nCount, 08]) + cTxtAdd } ) // "Par�metro "" n�o configurado corretamente.""Configurar o par�metro para o valor: "
			EndIf
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0014 +Self:aParametros[nCount, 02] + STR0042 , STR0043 + cValToChar(Self:aParametros[nCount, 08]) + cTxtAdd } ) // ""Par�metro "" n�o configurado corretamente.""Criar o par�metro e configur�-lo com o valor: "
		EndIf    
	
	Next  
	
	//Valida o conteudo do parametro MV_FINJRTP
	//Que deve ser igual a 2
  
	If nMvFinJrTp <> 2 
		aAdd( Self:aPreRequisitesStatus, { .F., STR0014 +"MV_FINJRTP" + STR0040 , STR0075 } ) //"Parametro" ## "N�o configurado corretamente" "O conte�do do par�metro deve ser igual a 2."
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
			aAdd( Self:aPreRequisitesStatus, { .T., STR0016  + " " + Self:aCamposObrigatorios[nCount] + " " + STR0044 , "" } ) // "Campo" "configurado corretamente."
		Else
			aAdd( Self:aPreRequisitesStatus, { .F., STR0016 + " " + Self:aCamposObrigatorios[nCount] + " " + STR0045 , STR0046 } ) // "Campo"  "n�o configurado corretamente." "Configure o campo como obrigat�rio."
		EndIf
	Next
	
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
���Metodo    �GetEndText          �Autor�Vendas Clientes� Data � 02/04/12 ���
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
Method GetEndText( lLoaded ) Class LJCFinSer
	Local cText := ""   //Texto de Retorno
	
	cText += "<p>"
	cText += STR0047 // "A seguir um resumo das tarefas executadas:"
	cText += "<br>"		
	cText += 	"<ul>"
	cText += 		"<li>" + " " + STR0048 + " " + If( Self:lConfigured, "<font color='green'>" + STR0049 + "</font>", "<font color='red'>" + STR0050  + "</font>" ) + "</li>"	// "Configura��o do sistema:" "Efetuado" "N�o efetuado"
	cText += 		"<li>" + " " + STR0051 + " " + If( Self:lValidated, "<font color='green'>" + STR0049 + "</font>", "<font color='red'>" + STR0050 + "</font>" ) + "</li>" // "Valida��o do sistema:" "Efetuado" "N�o efetuado"
	cText += 	"</ul>"	
	cText += "</p>"	
Return cText