#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'LOJA730.CH'


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA730   �Autor  �Leandro Nogueira    � Data �  23/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de motivo de venda perdida		                  ���
�������������������������������������������������������������������������͹��
���Uso       �Sigaloja		                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} LOJA730
Cadastro de motivo de venda perdida
@author  	Leandro Nogueira
@version 	P11 R5
@since   	23/09/2010
@return  	NIL
/*/
Function LOJA730()
Local oBrowse
            
LA730INC()
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('MBQ')
oBrowse:SetDescription(STR0001)//'Cadastro de Motivo de Venda Perdida'
oBrowse:Activate()  

Return NIL

/*                                            
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �Leandro Nogueira    � Data �  23/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Menu de op��es							                  ���
�������������������������������������������������������������������������͹��
���Uso       �Sigaloja		                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} MenuDef 
Menu de op��es
@author  	Leandro Nogueira
@version 	P11 R5
@since   	23/09/2010
@return  	aRotina
/*/
Static Function MenuDef()
Local aRotina 	:= {}


ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.LOJA730' OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.LOJA730' OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.LOJA730' OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.LOJA730' OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.LOJA730' OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.LOJA730' OPERATION 9 ACCESS 0 //"Copiar"


Return aRotina

                                                 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Leandro Nogueira    � Data �  23/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Modelo de dados							                  ���
�������������������������������������������������������������������������͹��
���Uso       �Sigaloja		                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} ModelDef
Modelo de dados
@author  	Leandro Nogueira
@version 	P11 R5
@since   	23/09/2010
@return  	oModel - Modelo de dados
/*/
Static Function ModelDef()  

Local oStruMBQ 	:= FWFormStruct( 1, 'MBQ') 	// Estrutura do Modelo de Dados
Local oModel	:= MPFormModel ():New('LOJA730MODEL',,{ |oModel| LA730POST( oModel )},{  |oModel| LA730CON(oModel)})	// Modelo de Dados

oStruMBQ:SetProperty( "MBQ_CODVEP" , MODEL_FIELD_WHEN, {|| INCLUI })

//���������������������������������
//�Definicoes do modelo de dados  �
//���������������������������������
oModel:AddFields( 'MBQMASTER',   , oStruMBQ)
oModel:SetDescription( STR0011)							//"Modelo de Dados do Motivo de Venda Perdida"
oModel:GetModel( 'MBQMASTER' ):SetDescription( STR0012)//"Dados do Motivo de Venda Perdida" 

Return oModel


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef	�Autor  �Leandro Nogueira    � Data �  23/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Modelo de visualizacao					                  ���
�������������������������������������������������������������������������͹��
���Uso       �Sigaloja		                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} ViewDef
@author  	Leandro Nogueira
@version 	P11 R5
@since   	23/09/2010
@return  	oView - Modelo de visualizacao
/*/
Static Function ViewDef()

Local oModel   := FWLoadModel( 'LOJA730' )  	// Modelo de Dados baseado no ModelDef do fonte informado
Local oStruMBQ := FWFormStruct( 2, 'MBQ' )		// Objeto com a estrutura da View
Local oView    := FWFormView():New()			// Objeto que tem como funcionalidade instanciar os objetos graficos do modelo de dados

//����������������������
//�Definicoes do view  �
//����������������������
oView:SetModel( oModel )
//������������������������������������������������������������
//�Adiciona um controle FormFields(antiga enchoice) na view  �
//������������������������������������������������������������
oView:AddField( 'VIEW_MBQ', oStruMBQ, 'MBQMASTER' )
//�������������������������������������������������������������Ŀ
//�Criar um "box" horizontal para receber algum elemento da view�
//���������������������������������������������������������������
oView:CreateHorizontalBox( 'TELA' , 100 )
//��������������������������������������������������
//�Relaciona o ID da View com o "box" para exibicao�
//��������������������������������������������������
oView:SetOwnerView( 'VIEW_MBQ', 'TELA' )
Return oView       


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LA730POST	�Autor  �Leandro Nogueira    � Data �  04/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Bloco de validacao do formulario de edicao                  ���
�������������������������������������������������������������������������͹��
���Uso       �Sigaloja		                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} LA730POST
Bloco de validacao do formulario de edicao
@author  	Leandro Nogueira
@version 	P11 R5
@since    	04/10/2010
/*/
Static Function LA730POST( oModel )

Local nOperation	:= oModel:GetOperation()  
Local lRet   	    := .T.    
Local cOldAlias 	:= Alias()

If nOperation == 5
	//�������������������������������������������������������Ŀ
	//�Impedir exclusao dos motivos de venda perdida 001 e 002�
	//���������������������������������������������������������
	If oModel:GetValue( 'MBQMASTER', 'MBQ_CODVEP')== "001" .OR. oModel:GetValue( 'MBQMASTER', 'MBQ_CODVEP')== "002"
		Help( ,, 'HELP',, STR0013, 1, 0)//"Este registro n�o pode ser exclu�do !"
		lRet := .F.    
	Else
		DbSelectArea("MBR")
		DbOrderNickName("MBRIND3")
		If DbSeek(xFilial("MBR")+oModel:GetValue('MBQMASTER', 'MBQ_CODVEP'))
			Help( ,, 'HELP',, STR0014, 1, 0)//"N�o � poss�vel excluir um Motivo de venda perdida em uso !"
			lRet := .F.    
		EndIf    			
	EndIf
	
	DbSelectArea(cOldAlias)

ElseIf nOperation == 3
	lRet := ExistChav("MBQ",oModel:GetValue('MBQMASTER', 'MBQ_CODVEP'),1,"JAGRAVADO")

EndIf

Return lRet 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LA730INC	�Autor  �Leandro Nogueira    � Data �  04/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inclusao dos motivos de venda perdida padrao				  ���
�������������������������������������������������������������������������͹��
���Uso       �Sigaloja		                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LA730INC()

Local cOldAlias := Alias()

//���������������������������������������������������������Ŀ
//�Verificar existencia dos motivos de venda perdida padrao:�
//�                                                         �
//�001 - Registro Indevido / Falha do usu�rio               �
//�002 - Produto indispon�vel no estoque.                   �
//�����������������������������������������������������������
DbSelectArea("MBQ")
DbOrderNickname("MBQIND1")

If !DbSeek(xFilial("MBQ")+"001")
	RecLock("MBQ", .T.)    
	
	REPLACE MBQ_FILIAL	WITH   xFilial ("MBQ")
	REPLACE MBQ_CODVEP 	WITH   "001"
	REPLACE MBQ_DSCVEP	WITH   STR0009 //"Registro Indevido / Falha do usu�rio"

	MsUnLock() 	
	LA730INT (3) //Inclus�o	
Endif

If !DbSeek(xFilial("MBQ")+"002")

	RecLock("MBQ", .T.)    
	
	REPLACE MBQ_FILIAL	WITH   xFilial ("MBQ")
	REPLACE MBQ_CODVEP 	WITH   "002"
	REPLACE MBQ_DSCVEP	WITH   STR0010 //"Produto indispon�vel no estoque."
	
	MsUnLock()	
	LA730INT (3) //Inclus�o
Endif

DbSelectArea(cOldAlias)



Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LA730CON	�Autor  �Leandro Nogueira    � Data �  19/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Confirmacao do regisro de motivo de venda perdida.  		  ���
�������������������������������������������������������������������������͹��
���Uso       �Sigaloja		                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} LA730CON 
Confirmacao do regisro de motivo de venda perdida.  
@author  	Leandro Nogueira
@version 	P11 R5
@since    	19/10/2010
/*/
Static Function LA730CON(oModel)
Local nOperation 	:= oModel:GetOperation()   						//Operacao executada no modelo de dados.

If FWFormCommit( oModel )
 	LA730INT (nOperation)	
EndIf

Return .T.
                  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LA730INT	�Autor  �Leandro Nogueira    � Data �  04/11/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Integra��o off-line do regisro de motivo de venda perdida.  ���
�������������������������������������������������������������������������͹��
���Uso       �Sigaloja		                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} LA730INT 
Integra��o off-line do regisro de motivo de venda perdida.
@author  	Leandro Nogueira
@version 	P11 R5
@since    	19/10/2010
/*/
Static Function LA730INT(nOperation)
Local aArea      	:= GetArea()
Local cTipo 		:= ""											//Como os dados serao integrados no processo offline    
Local oProcessOff 	:= Nil											//Objeto do tipo LJCProcessoOffLine
Local lAmbOffLn 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)			//Identifica se o ambiente esta operando em offline 
Local lRet			:= .F.  

Default nOperation 	:= 3


//Verifica se o ambiente esta em off-line
If lAmbOffLn
	//Instancia o objeto LJCProcessoOffLine
	oProcessOff := LJCProcessoOffLine():New("031")
	
	//Determina o tipo de operacao 
	Do Case
	Case nOperation == 3
		cTipo := "INSERT"
	Case nOperation == 4
		cTipo := "UPDATE"
	Otherwise
		cTipo := "DELETE"		
		//Considera os registros deletados
		SET DELETED OFF
	EndCase
		    
	If !Empty(cTipo)
		//Insere os dados do processo (registro da tabela)
		oProcessOff:Inserir("MBQ", xFilial("MBQ") + MBQ->MBQ_CODVEP, 1, cTipo)			
					
		//Processa os dados 
		oProcessOff:Processar()	
	EndIf
	
	//Desconsidera os registros deletados
	SET DELETED ON

EndIf
RestArea( aArea )	

Return NIL          