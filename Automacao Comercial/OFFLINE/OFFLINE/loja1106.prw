#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1106.CH"
#INCLUDE "FWMVCDEF.CH"
/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1106  �Autor  �Vendas Clientes     � Data �  22/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de WebServices.                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LOJA1106()
 
Local oBrowse 		:= Nil

Private oCadastro 	:= Nil 

If  GetRpoRelease("R7")
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('MD3')
	oBrowse:SetDescription(STR0001) // "Configuracao de Comunicacao"
	oBrowse:Activate() 	 
Else
	oCadastro := LjCCadWebServ():New()		//Instancia o objeto
	oCadastro:Show()
EndIf

Return NIL

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Classe�LjCCadProcesso �Autor  �Vendas Clientes  � Data � 25/02/08     ���
������������������������������������������������������������������������͹��
���Desc. � Responsavel pela montagem do Cadastro de Web Services         ���
���      �                                                               ���
������������������������������������������������������������������������͹��
���Uso   � SIGALOJA                                                      ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Class LjCCadWebServ From LjACadastro
	Method New()
	Method ValOK()
	Method ValFim()
	Method ValExc()
EndClass

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Metodo�New            �Autor  �Vendas Clientes  � Data � 25/02/08     ���
������������������������������������������������������������������������͹��
���Desc. � Instancia a Classe LjCCadProcXTab a partir da heranca da      ���
���      � Classe LjACadastro                                            ���
������������������������������������������������������������������������͹��
���Uso   � LjCCadWebServ                                                 ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method New() Class LjCCadWebServ
	//"Cadastro de WebServices"
	_Super:New("MD3", STR0001, "oCadastro:ValExc()", "oCadastro:ValOK()", {||oCadastro:ValFim()})
Return Self

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Metodo� ValOK         �Autor  �Vendas Clientes  � Data � 25/02/08     ���
������������������������������������������������������������������������͹��
���Desc. � Validacao do botao OK.                                        ���
������������������������������������������������������������������������͹��
���Ret.  � ExpL1 - Permite ou nao a confirmacao da Alteracao ou Inclusao ���
������������������������������������������������������������������������͹��
���Uso   � LjCCadWebServ                                                 ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method ValOK() Class LjCCadWebServ
Local aArea		:= GetArea()						//Guarda a Area
Local cCodAmb	:= M->MD3_CODAMB					//Codigo do Ambiente
Local cTipoWS	:= M->MD3_TIPO						//Tipo de WS
Local lRetorno	:= .T.								//Retorno da Funcao

If INCLUI
	DbSelectArea("MD3")
	DbSetOrder(1)	//Filial + Ambiente + Tipo WS
	
	If DbSeek(xFilial("MD3") + cCodAmb + cTipoWS)
		lRetorno := .F.
		MsgAlert(STR0002)		//"Ja existe um Registro com este Codigo."
	EndIf
EndIf

RestArea(aArea)
Return lRetorno

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Metodo� ValExc        �Autor  �Vendas Clientes  � Data � 25/02/08     ���
������������������������������������������������������������������������͹��
���Desc. � Validacao de exclusao da tabela de Processos                  ���
������������������������������������������������������������������������͹��
���Uso   � LjCCadWebServ                                                 ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method ValExc() Class LjCCadWebServ

	Local cAmb		:= MD3->MD3_CODAMB			//Codigo do Ambiente
	Local cTipoWs	:= MD3->MD3_TIPO			//Tipo do WS
	Local cTipo		:=	"DELETE"				//Como os dados vao ser integrados no processo offline    
	
	//Insere o registro no processo off-line
   	::ProcessOff("MD3", xFilial("MD3") + cAmb + cTipoWs, 1, cTipo, "003")

Return .T.

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Metodo� ValFim        �Autor  �Vendas Clientes  � Data � 25/02/08     ���
������������������������������������������������������������������������͹��
���Desc. � Validacao do fim do processo.                                 ���
������������������������������������������������������������������������͹��
���Uso   � LjCCadWebServ                                                 ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method ValFim() Class LjCCadWebServ
	
	Local cTipo := ""					//Como os dados vao ser integrados no processo offline    
	
	If INCLUI
		cTipo := "INSERT"
	ElseIf ALTERA
		cTipo := "UPDATE"
	EndIf
    
	If !Empty(cTipo)
	   	::ProcessOff("MD3", xFilial("MD3") + MD3->MD3_CODAMB + MD3->MD3_TIPO, 1, cTipo, "003")
	EndIf

Return Nil 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MenuDef   � Autor �Vendas CRM             � Data �26/01/12  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de defini��o do aRotina                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina   retorna a array com lista de aRotina             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � LOJA1106                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0003  	ACTION "PesqBrw" 		  OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.LOJA1106" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0005    ACTION "VIEWDEF.LOJA1106" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0006    ACTION "VIEWDEF.LOJA1106" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0007    ACTION "VIEWDEF.LOJA1106" OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Vendas CRM          � Data �  26/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados (MVC)                              ���
�������������������������������������������������������������������������͹��
���Uso       |LOJA1106                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oStruMD3 := FWFormStruct( 1,'MD3',,.F.)
Local bCommit  := { |oModel| LJ1106Grava( oModel ) } 	// Grava os dados e faz chamada para loja off line 
Local oModel   := Nil

oModel := MPFormModel():New('LOJA1106M',,, bCommit,)

oModel:AddFields( 'MD3MASTER',, oStruMD3,,,)
oModel:GetModel( 'MD3MASTER' ):SetDescription( STR0001 )// "Configuracao de Comunicacao"
oModel:SetPrimaryKey({"MD3_FILIAL","MD3_CODAMB","MD3_TIPO"})

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Vendas CRM          � Data �  26/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define a interface para cadastro de Processos em MVC.       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �LOJA1106                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef() 

Local oModel   := FWLoadModel( 'LOJA1106' )
Local oStruMD3 := FWFormStruct( 2,'MD3',,.F.)
Local oView    := Nil

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_MD3', oStruMD3, 'MD3MASTER' )
oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_MD3', 'TELA' )

Return oView 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |LJ1106Grava    �Autor  �Vendas CRM          � Data �  26/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Bloco executado na gravacao dos dados do formulario.		  ���
�������������������������������������������������������������������������͹��
���Uso       �LOJA1106                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LJ1106Grava( oModel ) 
Local lRet			:= .T.  
Local aArea		:= GetArea()
Local nOperation	:= oModel:GetOperation()
Local cCodAmb		:= oModel:GetValue( 'MD3MASTER', 'MD3_CODAMB' ) 
Local cTipoWS		:= oModel:GetValue( 'MD3MASTER', 'MD3_TIPO' )   

// Grava os dados 
lRet := FWFormCommit( oModel )

// Chamada loja off line
If lRet
	Lj1106Of("003","MD3",cCodAmb + cTipoWS, 1)
EndIf  

RestArea( aArea )

Return lRet  

/*                         
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Lj1106Of  � Autor � IP-Vendas 			� Data � 27/01/12 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Define a operacao que sera realizada na tabela de 	      ���
���			 � integracao de acordo com o processo de replicacao executado���
�������������������������������������������������������������������������Ĵ��
���Uso       � Registros utilizados na integracao Off-line                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Lj1106Of( cProcess, cTabela, cChave, nOrdem, cTipo)
		
	Local oProcessOff 	:= Nil											//Objeto do tipo LJCProcessoOffLine
	Local lAmbOffLn		:= .F.	        
			
	lAmbOffLn	 		:= SuperGetMv("MV_LJOFFLN", Nil, .F.)	//Identifica se o ambiente esta operando em offline		

	//Verifica se o ambiente esta em off-line
	If lAmbOffLn
		//Instancia o objeto LJCProcessoOffLine
		oProcessOff := LJCProcessoOffLine():New(cProcess)
		
		//Determina o tipo de operacao 
		If Empty(cTipo)
			If INCLUI
				cTipo := "INSERT"
			ElseIf ALTERA
				cTipo := "UPDATE"
			Else
				cTipo := "DELETE"				
			EndIf
		Endif    
		
		If cTipo = "DELETE"				
			//Considera os registros deletados
			SET DELETED OFF
		EndIf
			    
		If !Empty(cTipo)
			//Insere os dados do processo (registro da tabela)
			oProcessOff:Inserir(cTabela, xFilial(cTabela) + cChave, nOrdem, cTipo)	
				
			//Processa os dados 
			oProcessOff:Processar()	
		EndIf
		
		//Desconsidera os registros deletados
		SET DELETED ON
	EndIf
	
Return Nil 