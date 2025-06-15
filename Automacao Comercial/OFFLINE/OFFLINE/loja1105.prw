#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1105.CH"
#INCLUDE "FWMVCDEF.CH"
/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1105  �Autor  �Vendas Clientes     � Data �  22/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de Processos X Tabelas.                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LOJA1105() 
 
Local oBrowse 		:= Nil

Private oCadastro 	:= Nil 
          
LjPopMD2() // Popula tabela de processos de integracao Off-Line

If  GetRpoRelease("R7") 
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('MD2')
	oBrowse:SetDescription(STR0001) // "Amarracao Processos x Tabelas"
	oBrowse:Activate() 	 
Else
	 oCadastro := LjCCadProcXTab():New()		//Instancia o objeto
	 oCadastro:Show()
EndIf

Return Nil
/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Classe�LjCCadProcesso �Autor  �Vendas Clientes  � Data � 25/02/08     ���
������������������������������������������������������������������������͹��
���Desc. � Responsavel pela montagem do Cadastro de Processos            ���
���      �                                                               ���
������������������������������������������������������������������������͹��
���Uso   � SIGALOJA                                                      ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Class LjCCadProcXTab From LjACadastro
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
���Desc. � Instancia a Classe LjCCadProcXTab a partir da heranca da      ���
���      � Classe LjACadastro                                            ���
������������������������������������������������������������������������͹��
���Uso   � LjCCadProcXTab                                                ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method New() Class LjCCadProcXTab
	//"Amarracao Processos x Tabelas"
	_Super:New("MD2", STR0001, "oCadastro:ValExc()", "oCadastro:ValOK()", {||oCadastro:ValFim()})
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
���Uso   � LjCCadProcesso                                                ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method ValOK() Class LjCCadProcXTab
Local aArea		:= GetArea()				//Guarda a Area
Local cProcesso	:= M->MD2_PROCESS			//Codigo do Processo
Local cTabela	:= M->MD2_TABELA			//Alias da Tabela
Local lRetorno	:= .T.						//Retorno da Funcao

If INCLUI
	DbSelectArea("MD2")
	DbSetOrder(1)	//Filial + Processo + Tabela
	
	If DbSeek(xFilial("MD2") + cProcesso + cTabela)
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
���Ret.  � ExpL1 - Permite ou nao a exclusao do Registro                 ���
������������������������������������������������������������������������͹��
���Uso   � LjCCadProcXTab                                                ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method ValExc() Class LjCCadProcXTab

	Local cProcesso	:= MD2->MD2_PROCESS			//Codigo do Processo
	Local cTabela	:= MD2->MD2_TABELA			//Alias da Tabela
	Local cTipo		:=	"DELETE"				//Como os dados vao ser integrados no processo offline    
	
	//Insere o registro no processo off-line
   	::ProcessOff("MD2", xFilial("MD2") + cProcesso + cTabela, 1, cTipo, "002")

Return .T.

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Metodo� ValFim        �Autor  �Vendas Clientes  � Data � 25/02/08     ���
������������������������������������������������������������������������͹��
���Desc. � Validacao do fim do processo.                                 ���
������������������������������������������������������������������������͹��
���Uso   � LjCCadProcXTab                                                ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method ValFim() Class LjCCadProcXTab
	
	Local cTipo := ""					//Como os dados vao ser integrados no processo offline    
	
	If INCLUI
		cTipo := "INSERT"
	ElseIf ALTERA
		cTipo := "UPDATE"
	EndIf
    
	If !Empty(cTipo)
		::ProcessOff("MD2", xFilial("MD2") + MD2->MD2_PROCESS + MD2->MD2_TABELA, 1, cTipo, "002")
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
���Uso       � LOJA1105                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0004	ACTION "PesqBrw" 		  OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.LOJA1105" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0006    ACTION "VIEWDEF.LOJA1105" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0007    ACTION "VIEWDEF.LOJA1105" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0008    ACTION "VIEWDEF.LOJA1105" OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Vendas CRM          � Data �  26/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados (MVC)                              ���
�������������������������������������������������������������������������͹��
���Uso       |LOJA1105                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oStruMD2 := FWFormStruct( 1, 'MD2')
Local bCommit  := { |oModel| LJ1105Grava( oModel ) } 	// Grava os dados e faz chamada para loja off line 
Local bPosVld  := { |oModel| LjVld1105( oModel ) } // Valida chave unica
Local oModel   := Nil

oModel:= MPFormModel():New('LOJA1105',,bPosVld, bCommit)
oModel:AddFields( 'MD2MASTER',, oStruMD2,,,)
oModel:GetModel('MD2MASTER'):SetDescription( STR0001 )// "Amarracao Processos x Tabelas"

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
���Uso       �LOJA1105                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef() 

Local oModel   := FWLoadModel( 'LOJA1105' )
Local oStruMD2 := FWFormStruct( 2, 'MD2',)
Local oView    := Nil

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_MD2', oStruMD2, 'MD2MASTER' )
oView:CreateHorizontalBox( 'TELA' , 100 )
oView:SetOwnerView( 'VIEW_MD2', 'TELA' )

Return oView 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |LJ1105Grava    �Autor  �Vendas CRM     � Data �  26/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Bloco executado na gravacao dos dados do formulario.		  ���
�������������������������������������������������������������������������͹��
���Uso       �LOJA1105                                                    ���
�������������������������������������������������������������������������ͱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LJ1105Grava( oModel )  
Local lRet			:= .T.
Local aArea		:= GetArea()
Local nOperation	:= oModel:GetOperation()
Local cProcess	 	:= oModel:GetValue( 'MD2MASTER', 'MD2_PROCES' )
Local cTabela		:= oModel:GetValue( 'MD2MASTER', 'MD2_TABELA'  )  

// Grava os dados 
lRet := FWFormCommit( oModel )

// Chamada loja off line
If lRet
	Lj1105Of("002","MD2",cProcess + cTabela, 1)
EndIf  

RestArea( aArea )

Return lRet  

/*                         
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    |LjVld1105 � Autor � IP-Vendas 			� Data � 27/01/12 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Pos Validacao do Modelo				 	 	 	 	      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � LOJA1105 								                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LjVld1105( oModel )
	
Local lRet       	:= .T.
Local nOperation 	:= oModel:GetOperation()
Local cProcesso	:= oModel:GetValue( 'MD2MASTER', 'MD2_PROCES' ) 
Local cTabela		:= oModel:GetValue( 'MD2MASTER', 'MD2_TABELA' ) 

If nOperation != 5
	If !ExistChav("MD2",cProcesso + cTabela,1)
		Help('' ,1, 'JAGRAVADO',, STR0003, 1, 0 ) //"Ja existe este codigo de Processo relacionado com esta Tabela"
		lRet := .F.
	EndIf
EndIf
    
Return lRet

/*                         
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Lj1105Of  � Autor � IP-Vendas 			� Data � 27/01/12 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Define a operacao que sera realizada na tabela de 	      ���
���			 � integracao de acordo com o processo de replicacao executado���
�������������������������������������������������������������������������Ĵ��
���Uso       � Registros utilizados na integracao Off-line                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Lj1105Of( cProcess, cTabela, cChave, nOrdem, cTipo)
		
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

/*                         
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    |LjPopMD2  � Autor � IP-Vendas 			� Data � 27/01/12 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Popula Tabela de Processos de Integracao Off-Line 	      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � LOJA1105									                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LjPopMD2()
         
Local aArea	   	 := GetArea()			// Guarda a Area corrente  
Local aProcXTab	 := {}					// Array com processos X tabelas
Local aEstrut	 := {}					// Estrutura da MD2
Local nI 		 := 0					// Contador 
Local nX 		 := 0					// Contador 
Local nZ 		 := 0					// Cotador                                                                        
Local aEstTabXProc := {}				// Estrutura de relacao entre as posicoes dos campos da tabela MD2 com o array aProcessos
Local aProcessos := IIf(FindFunction("LjProcOff"),LjProcOff("MD2"),{}) 	// Carrega array com processos padraoLjProcOff("MD2")

//��������������������������������������������������������Ŀ
//�Array configurado com a posicao corespondente dos       |
//|campos da MD2 com os campos do array de processos padrao�
//����������������������������������������������������������
aEstTabXProc := {"MD2_FILIAL","MD2_PROCES","","","MD2_ENABLE","MD2_TABELA"}

//����������������������������������Ŀ
//�Processamento dos campos no MD1   �
//������������������������������������
ProcRegua(Len(aProcessos))
DbSelectArea("MD2")
aEstrut := DbStruct()
For nI := 1 To Len(aProcessos)
	IncProc()
	If !Empty(aProcessos[nI][2])
	MD2->(DbSetOrder(1)) // MD2_FILIAL + MD2_PROCESS + MD2_TABELA
		For nX := 1 To Len(aProcessos[nI][6]) // Tabelas
			If !(MD2->(DbSeek(aProcessos[nI][1] + aProcessos[nI][2] + aProcessos[nI][6][nX]))) 
				RecLock("MD2",.T.)
				For nZ := 1 To Len(aEstrut)
					nPos := 0						
					If MD2->(FieldPos(aEstrut[nZ][1])) > 0 
						nPos := Ascan(aEstTabXProc,{|x| x == aEstrut[nZ][1]}) // Posicao correspondente da Tabela com o Array de processos padrao
						If nPos > 0
							If nPos == 6 // Array com as Tabelas                   
								FieldPut(FieldPos(aEstrut[nZ][1]),aProcessos[nI][nPos][nX])
							Else
								FieldPut(FieldPos(aEstrut[nZ][1]),aProcessos[nI][nPos])
							EndIf	
						EndIf
					EndIf
				Next nZ
				DbCommit()
				MsUnLock()
			Endif 
		Next nX
	Endif
Next nI                  
                     

AjustaTab()
                     
RestArea( aArea )                   

Return Nil    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    |AjustaTab � Autor � Vendas Cliente		� Data � 10/06/13 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Alterar Tabela de Processos de Integracao Off-Line 	      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � LOJA1105									                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AjustaTab()
Local nProcTam	:= TamSx3("MD2_PROCESS")[1]
Local nTabTam	:= TamSx3("MD2_TABELA")[1]

MD2->(DbSetOrder( 1 )) // MD2_FILIAL + MD2_PROCESS + MD2_TABELA
If MD2->(DBSeek( xFilial("MD2") + PadR("009",nProcTam) + PadR("SF1",nTabTam) ))
	If RecLock("MD2", .F.)
		Replace MD2_TABELA With "SFI"
		MsUnLock()
	EndIf
EndIf

Return Nil