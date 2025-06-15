#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1108.CH"
#INCLUDE "FWMVCDEF.CH"
/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1108  �Autor  �Vendas Clientes     � Data �  22/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de Ambientes                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LOJA1108()

Local oBrowse 		:= Nil

Private oCadastro 	:= Nil 

If  GetRpoRelease("R7")
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('MD5')
	oBrowse:SetDescription(STR0001) // "Ambientes X Processos"
	oBrowse:Activate() 	 
Else
	oCadastro := LJCCadAmbXProc():New()		//Instancia o objeto
	oCadastro:Show()
EndIf

Return NIL

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Classe�LJCCadAmbXProc �Autor  �Vendas Clientes  � Data � 25/02/08     ���
������������������������������������������������������������������������͹��
���Desc. � Responsavel pela montagem do Cadastro de Ambientes            ���
���      �                                                               ���
������������������������������������������������������������������������͹��
���Uso   � SIGALOJA                                                      ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Class LJCCadAmbXProc From LjACadastro
	Method New()
	Method ValOK()
	Method ValExc()
	Method ValFim()
EndClass

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Metodo�New            �Autor  �Vendas Clientes  � Data � 25/02/08     ���
������������������������������������������������������������������������͹��
���Desc. � Instancia a Classe LJCCadAmbXProc a partir da heranca da      ���
���      � Classe LjACadastro                                            ���
������������������������������������������������������������������������͹��
���Uso   � LjCCadAmbientes                                               ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method New() Class LJCCadAmbXProc
	//"Ambientes X Processos"
	_Super:New("MD5", STR0001, "oCadastro:ValExc()", "oCadastro:ValOK()", {||oCadastro:ValFim()})
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
���Uso   � LJCCadAmbXProc                                                ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method ValOK() Class LJCCadAmbXProc
Local aArea		:= GetArea()							//Guarda a Area
Local cAmbOri	:= M->MD5_AMBORI						//Ambiente Origem
Local cProces	:= M->MD5_PROCES						//Processo
Local cAmbDes	:= M->MD5_AMBDES						//Ambiente Destino
Local lRetorno	:= .T.									//Retorno da Funcao

If INCLUI
	DbSelectArea("MD5")
	DbSetOrder(1)	//Filial + Ambiente Origem + Processo + Ambiente Destino
	
	If DbSeek(xFilial("MD5") + cAmbOri + cProces + cAmbDes)
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
���Uso   � LJCCadAmbXProc                                                ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method ValExc() Class LJCCadAmbXProc

	Local cProcesso	:= MD5->MD5_PROCES			//Codigo do Processo
	Local cAmbOrig	:= MD5->MD5_AMBORI			//Ambiente origem
	Local cAmbDest	:= MD5->MD5_AMBDES			//Ambiente destino	
	Local cTipo		:=	"DELETE"				//Como os dados vao ser integrados no processo offline    
	
	//Insere o registro no processo off-line
   	::ProcessOff("MD5", xFilial("MD5") + cAmbOrig + cProcesso + cAmbDest, 1, cTipo, "005")

Return .T.

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Metodo� ValFim        �Autor  �Vendas Clientes  � Data � 25/02/08     ���
������������������������������������������������������������������������͹��
���Desc. � Validacao do fim do processo.                                 ���
������������������������������������������������������������������������͹��
���Uso   � LJCCadAmbXProc                                                ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method ValFim() Class LJCCadAmbXProc
	
	Local cTipo := ""					//Como os dados vao ser integrados no processo offline    
	
	If INCLUI
		cTipo := "INSERT"
	ElseIf ALTERA
		cTipo := "UPDATE"
	EndIf
    
	If !Empty(cTipo)
		::ProcessOff("MD5", xFilial("MD5") + MD5->MD5_AMBORI + MD5->MD5_PROCES + MD5->MD5_AMBDES, 1, cTipo, "005")
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
���Uso       � LOJA1108                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0003  	ACTION "PesqBrw" 		  OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.LOJA1108" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0005    ACTION "VIEWDEF.LOJA1108" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0006    ACTION "VIEWDEF.LOJA1108" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0007    ACTION "VIEWDEF.LOJA1108" OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Vendas CRM          � Data �  26/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados (MVC)                              ���
�������������������������������������������������������������������������͹��
���Uso       |LOJA1108                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oStruMD5 := FWFormStruct( 1, 'MD5',,)
Local bCommit  := { |oModel| LJ1108Grava( oModel ) } 	// Grava os dados e faz chamada para loja off line 
Local bPosVld  := { |oModel| LjVld1108( oModel ) } // Valida chave unica
Local oModel   := Nil

oModel := MPFormModel():New('LOJA1108M',,bPosVld, bCommit,)
oModel:AddFields( 'MD5MASTER',, oStruMD5,,,)
oModel:GetModel( 'MD5MASTER' ):SetDescription( STR0001 )// "Ambientes X Processos"

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
���Uso       �LOJA1108                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef() 

Local oModel   := FWLoadModel( 'LOJA1108' )
Local oStruMD5 := FWFormStruct( 2, 'MD5',)
Local oView    := Nil

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_MD5', oStruMD5, 'MD5MASTER' )
oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_MD5', 'TELA' )

Return oView 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |LJ1108Grava    �Autor  �Vendas CRM          � Data �  26/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Bloco executado na gravacao dos dados do formulario.		  ���
�������������������������������������������������������������������������͹��
���Uso       �LOJA1108                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LJ1108Grava( oModel ) 
Local lRet			:= .T. 
Local aArea		:= GetArea()
Local nOperation	:= oModel:GetOperation()
Local cAmbOri		:= oModel:GetValue( 'MD5MASTER', 'MD5_AMBORI' )
Local cProcess		:= oModel:GetValue( 'MD5MASTER', 'MD5_PROCES' )
Local cAmbDes		:= oModel:GetValue( 'MD5MASTER', 'MD5_AMBDES' )

// Grava os dados 
lRet := FWFormCommit( oModel )

// Chamada loja off line
If lRet
	Lj1108Of("005","MD5",cAmbOri + cProcess + cAmbDes, 1)
EndIf  

RestArea( aArea )

Return lRet  

/*                         
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    |LjVld1108 � Autor � IP-Vendas 			� Data � 27/01/12 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Pos Validacao do Modelo				 	 	 	 	      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � LOJA1108 								                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                            
Static Function LjVld1108( oModel )
	
Local lRet       	:= .T.
Local nOperation 	:= oModel:GetOperation()
Local cAmbOri		:= oModel:GetValue( 'MD5MASTER', 'MD5_AMBORI' )
Local cProcess		:= oModel:GetValue( 'MD5MASTER', 'MD5_PROCES' )
Local cAmbDes		:= oModel:GetValue( 'MD5MASTER', 'MD5_AMBDES' )
			
If lRet
	If nOperation != 5
		If !ExistChav("MD5", cAmbOri + cProcess + cAmbDes,1) //Filial + Ambiente Origem + Processo + Ambiente Destino
			lRet := .F.
			Help( ,, 'Help',, STR0002, 1, 0 ) // "Ja existe um Registro com este Codigo."
		EndIf                                                                                                                                                                                                                     
	EndIf 
EndIf
	
Return lRet

/*                         
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Lj1108Of  � Autor � IP-Vendas 			� Data � 27/01/12 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Define a operacao que sera realizada na tabela de 	      ���
���			 � integracao de acordo com o processo de replicacao executado���
�������������������������������������������������������������������������Ĵ��
���Uso       � Registros utilizados na integracao Off-line                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Lj1108Of( cProcess, cTabela, cChave, nOrdem, cTipo)
		
	Local oProcessOff 	:= Nil	//Objeto do tipo LJCProcessoOffLine
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