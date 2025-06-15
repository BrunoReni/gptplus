#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1107.CH"
#INCLUDE "FWMVCDEF.CH"

/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1107  �Autor  �Vendas Clientes     � Data �  22/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de Ambientes                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LOJA1107()  

Local oBrowse 		:= Nil

Private oCadastro 	:= Nil 

If  GetRpoRelease("R7")  
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('MD4')
	oBrowse:SetDescription(STR0001) // "Cadastro Ambientes"
	oBrowse:Activate() 	 
Else
	oCadastro := LjCCadAmbientes():New()		//Instancia o objeto
	oCadastro :Show()
EndIf

Return NIL

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Classe�LjCCadProcesso �Autor  �Vendas Clientes  � Data � 25/02/08     ���
������������������������������������������������������������������������͹��
���Desc. � Responsavel pela montagem do Cadastro de Ambientes            ���
���      �                                                               ���
������������������������������������������������������������������������͹��
���Uso   � SIGALOJA                                                      ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Class LjCCadAmbientes From LjACadastro
	Method New()
	Method ValExc()
	Method ValOK()
	Method ValFim()
EndClass

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Metodo�New            �Autor  �Vendas Clientes  � Data � 25/02/08     ���
������������������������������������������������������������������������͹��
���Desc. � Instancia a Classe LjCCadAmbientes a partir da heranca da     ���
���      � Classe LjACadastro                                            ���
������������������������������������������������������������������������͹��
���Uso   � LjCCadAmbientes                                               ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method New() Class LjCCadAmbientes
	//"Cadastro Ambientes"
	_Super:New("MD4", STR0001, "oCadastro:ValExc()", "oCadastro:ValOK()", {||oCadastro:ValFim()})
Return Self

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Metodo� ValExc        �Autor  �Vendas Clientes  � Data � 25/02/08     ���
������������������������������������������������������������������������͹��
���Desc. � Validacao de exclusao da tabela de Ambientes                  ���
������������������������������������������������������������������������͹��
���Ret.  � ExpL1 - Permite ou nao a exclusao do Registro                 ���
������������������������������������������������������������������������͹��
���Uso   � LjCCadAmbientes                                               ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method ValExc() Class LjCCadAmbientes
Local lRetorno	:= .T.								//Retorno da Funcao
Local cCodigo	:= MD4->MD4_CODIGO					//Codigo do Ambiente
Local cTipo 	:= "DELETE"								//Como os dados vao ser integrados no processo offline    
//�����������������������������������
//�Verifica se existe algum cadastro�
//�utilizando a Tabela de Processos.�
//�����������������������������������
If !ALTERA .AND. !INCLUI
	DbSelectArea("MD3")
	DbSetOrder(1)	//Filial + Ambiente
	If DbSeek(xFilial("MD3") + cCodigo)
		lRetorno := .F.
	Else
		DbSelectArea("MD5")
		DbSetOrder(1)	//Filial + Ambiente Origem
		If DbSeek(xFilial("MD5") + cCodigo)
			lRetorno := .F.
		Else
			DbSetOrder(3)	//Filial + Ambiente Destino
			If DbSeek(xFilial("MD5") + cCodigo)
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
	
	If !lRetorno
		MsgAlert(STR0002)	//"Nao sera possivel excluir este registro, pois ele esta sendo utilizado em outro cadastro."
	Else
		//Insere o registro no processo off-line
		::ProcessOff("MD4", xFilial("MD4") + cCodigo, 1, cTipo, "004")	
	EndIf
EndIf

Return lRetorno

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
���Uso   � LjCCadAmbientes                                               ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method ValOK() Class LjCCadAmbientes
Local aArea		:= GetArea()				//Guarda a Area
Local cCodigo	:= M->MD4_CODIGO			//Codigo do Ambiente
Local lRetorno	:= .T.						//Retorno da Funcao

If INCLUI
	DbSelectArea("MD4")
	DbSetOrder(1)	//Filial + Ambiente
	
	If DbSeek(xFilial("MD4") + cCodigo)
		lRetorno := .F.
		MsgAlert(STR0003)		//"Ja existe um Registro com este Codigo."
	EndIf
EndIf

RestArea(aArea)
Return lRetorno

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Metodo� ValFim        �Autor  �Vendas Clientes  � Data � 25/02/08     ���
������������������������������������������������������������������������͹��
���Desc. � Validacao do fim do processo.                                 ���
������������������������������������������������������������������������͹��
���Uso   � LjCCadAmbientes                                               ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method ValFim() Class LjCCadAmbientes
	
	Local cTipo := ""					//Como os dados vao ser integrados no processo offline    
	
	If INCLUI
		cTipo := "INSERT"
	ElseIf ALTERA
		cTipo := "UPDATE"
	EndIf
    
	If !Empty(cTipo)
	   	::ProcessOff("MD4", xFilial("MD4") + MD4->MD4_CODIGO, 1, cTipo, "004")
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
���Uso       � LOJA1107                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0004  	ACTION "PesqBrw" 		  OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.LOJA1107" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0006    ACTION "VIEWDEF.LOJA1107" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0007    ACTION "VIEWDEF.LOJA1107" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0008   	ACTION "VIEWDEF.LOJA1107" OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Vendas CRM          � Data �  26/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados (MVC)                              ���
�������������������������������������������������������������������������͹��
���Uso       |LOJA1107                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oStruMD4 := FWFormStruct( 1, 'MD4',,.F.)
Local bCommit  := { |oModel| LJ1107Grava( oModel ) } 	// Grava os dados e faz chamada para loja off line 
Local oModel   := Nil

oModel := MPFormModel():New('LOJA1107M',,, bCommit,)
oModel:AddFields( 'MD4MASTER',, oStruMD4,,,)
oModel:GetModel('MD4MASTER'):SetDescription( STR0001 )// "Cadastro Ambientes"
oModel:SetPrimaryKey({"MD4_FILIAL","MD4_CODIGO"})                                                                                                                                                                                                                                  

oStruMD4:SetProperty( 'MD4_FILIAL' , MODEL_FIELD_OBRIGAT,.F.)
	
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
���Uso       �LOJA1107                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef() 

Local oModel   := FWLoadModel( 'LOJA1107' )
Local oStruMD4 := FWFormStruct( 2, 'MD4',,.F.)
Local oView    := Nil

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_MD4', oStruMD4, 'MD4MASTER' )
oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_MD4', 'TELA' )

Return oView 
	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |LJ1107Grava    �Autor  �Vendas CRM          � Data �  26/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Bloco executado na gravacao dos dados do formulario.		  ���
�������������������������������������������������������������������������͹��
���Uso       �LOJA1107                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LJ1107Grava( oModel ) 
      
Local aArea		:= GetArea()
Local nOperation	:= oModel:GetOperation()
Local cCodAmb		:= oModel:GetValue( 'MD4MASTER', 'MD4_CODIGO' )  
	
// Grava os dados 
lRet := FWFormCommit( oModel )

// Chamada loja off line
If lRet
	Lj1107Of("004","MD4",cCodAmb, 1)
EndIf

RestArea( aArea )

Return lRet  
	
/*                         
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Lj1107Of  � Autor � IP-Vendas 			� Data � 27/01/12 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Define a operacao que sera realizada na tabela de 	      ���
���			 � integracao de acordo com o processo de replicacao executado���
�������������������������������������������������������������������������Ĵ��
���Uso       � Registros utilizados na integracao Off-line                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Lj1107Of( cProcess, cTabela, cChave, nOrdem, cTipo)
		
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
