#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PLSA728.CH'
Function PLSA728()
Local oBrowse

// Instanciamento da Classe de Browse
oBrowse := FWMBrowse():New()

// Defini��o da tabela do Browse
oBrowse:SetAlias('B9H')

// Titulo da Browse
oBrowse:SetDescription(STR0001)

// Ativa��o da Classe
oBrowse:Activate()

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � ModelDef � Autor �Karine Limp           Data �  09/01/2015 ���
�������������������������������������������������������������������������͹��
��� Descricao� Define o modelo de dados da aplica��o                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � PLSA505                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()
// Cria as estruturas a serem usadas no Modelo de Dados
Local oStruB9H := FWFormStruct( 1, 'B9H' )
Local oStruB9K := FWFormStruct( 1, 'B9K' )
// Modelo de dados constru�do
Local oModel

// Cria o objeto do Modelo de Dados e insere a fun�ao de p�s-valida��o
oModel := MPFormModel():New( 'PLSA728', , {|| PLSA728OK(oModel) } )

// Adiciona ao modelo um componente de formul�rio
oModel:AddFields( 'B9HMASTER', /*cOwner*/, oStruB9H )

// Adiciona ao modelo uma componente de grid
oModel:AddGrid( 'B9KDETAIL', 'B9HMASTER', oStruB9K )

// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'B9KDETAIL', {	{ 'B9K_FILIAL'	, 'xFilial( "B9K" )'	},;
									{ 'B9K_CODINT'	, 'B9H_CODINT' },;
       								{ 'B9K_CODAGE'	, 'B9H_COD' } },;
       				   B9K->( IndexKey( 3 ) ) ) //B9K_FILIAL+B9K_CODINT+B9K_CODAGE 

// Adiciona a descri��o do Modelo de Dados
oModel:SetDescription( Fundesc() )

// Adiciona a descri��o dos Componentes do Modelo de Dados
oModel:GetModel( 'B9HMASTER' ):SetDescription( STR0001 )
oModel:SetPrimaryKey({"B9H_FILIAL","B9H_CODINT","B9H_COD"})

// Retorna o Modelo de dados
Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � MenuDef  � Autor �Karine Limp           Data �  09/01/2015 ���
�������������������������������������������������������������������������͹��
��� Descricao� Define o menu da aplica��o                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � PLSA445                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0007 /*'Visualizar'*/ Action 'VIEWDEF.PLSA728' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title STR0008 /*'Incluir'*/ 	 Action 'VIEWDEF.PLSA728' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title STR0009 /*'Alterar'*/ 	 Action 'VIEWDEF.PLSA728' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title STR0010 /*'Excluir'*/ 	 Action 'VIEWDEF.PLSA728' OPERATION 5 ACCESS 0
ADD OPTION aRotina Title STR0011 /*'Imprimir'*/ 	 Action 'VIEWDEF.PLSA728' OPERATION 8 ACCESS 0

Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � ViewDef  � Autor �Karine Limp           Data �  09/01/2015 ���
�������������������������������������������������������������������������͹��
��� Descricao� Define o modelo de dados da aplica��o                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � PLSA445                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel( 'PLSA728' )
// Cria as estruturas a serem usadas na View
Local oStruB9H := FWFormStruct( 2, 'B9H' ,{ |cCampo| PLSA728VI(cCampo) })
Local oStruB9K := FWFormStruct( 2, 'B9K' ,{ |cCampo| PLSA728VI(cCampo) })
// Interface de visualiza��o constru�da
Local oView

oModel:SetPrimaryKey( { "B9H_FILIAL", "B9H_COD" } )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual Modelo de dados ser� utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)
oView:AddField( 'VIEW_B9H', oStruB9H, 'B9HMASTER' )

//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'VIEW_B9K', oStruB9K, 'B9KDETAIL' )

//Adiciona campo incremental
oView:AddIncrementField( 'VIEW_B9K' , 'B9K_COD') 

//Nao deixa duplicar o campo B9K_CODCID
oModel:GetModel( 'B9KDETAIL' ):SetUniqueLine( { 'B9K_CODCID' } )

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 50 )
oView:CreateHorizontalBox( 'INFERIOR', 50 )

// Relaciona o identificador (ID) da View com o "box" para exibi��o
oView:SetOwnerView( 'VIEW_B9H', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_B9K', 'INFERIOR' )

// Retorna o objeto de View criado
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA728VI
Tratamento para definir os campos da B9H e B9K que n�o ser�o usados na View
@author Karine Riquena Limp
@since 19/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA728VI (cCampo)

Local lRet	:= .T.
cCampo := Alltrim(cCampo)

If cCampo == "B9H_CODINT" .OR. cCampo == "B9K_CODINT"
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA728OK
Validar bot�o confirmar

@author Karine Riquena Limp

@since 05/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA728OK(oModel)
LOCAL lRet     		:= .T.
LOCAL cMsg     		:= ""
LOCAL oModelMaster	:= oModel:GetModel( 'B9HMASTER' )
LOCAL nOpc				:= oModel:GetOperation()
LOCAL cCodAgente		:= ""
LOCAL cNome  			:= ""
LOCAL cTel  			:= ""
LOCAL cEmail 			:= ""
LOCAL cIntPad        := PLSINTPAD()
If (nOpc <> 5)
	cCodAgente := oModelMaster:GetValue('B9H_COD')
	cNome      := Alltrim(oModelMaster:GetValue('B9H_NOME'))
	cTel       := oModelMaster:GetValue('B9H_TEL')
	cEmail     := AllTrim(oModelMaster:GetValue('B9H_EMAIL'))

	B9H->(DbSelectArea("B9H"))
	B9H->(DbSetOrder(2)) // B9H_FILIAL + B9H_CODINT + B9H_COD
	If B9H->(MsSeek(XFilial("B9H") + cIntPad))

			While (B9H->(!Eof()) .AND. B9H->B9H_FILIAL == xFilial("B9H") .AND. lRet)
		
		       		If(Alltrim(B9H->B9H_NOME) == cNome .AND. Alltrim(B9H->B9H_EMAIL) == cEmail .AND. B9H->B9H_TEL == cTel .AND. B9H->B9H_COD != cCodAgente)
		       				cMsg := STR0002//Este Agente j� est� cadastrado
		   						Help( ,, 'HELP',, cMsg, 1, 0)
		   						lRet := .F.
		   				Else
		   		   			If(Alltrim(B9H->B9H_NOME) == cNome .AND. Alltrim(B9H->B9H_EMAIL) == cEmail .AND. B9H->B9H_COD != cCodAgente)
				  	   				cMsg := STR0003//J� existe um agente cadastrado com este nome e e-mail
				  	   				Help( ,, 'HELP',, cMsg, 1, 0)
				  	   				lRet := .F.
		   					Else 
		   		    			If(Alltrim(B9H->B9H_NOME) == cNome .AND. B9H->B9H_TEL == cTel .AND. B9H->B9H_COD != cCodAgente)
		   		    					cMsg := STR0004 //J� existe um agente cadastrado com este nome e telefone
		   			 					Help( ,, 'HELP',, cMsg, 1, 0)
		   			 					lRet := .F.
		   			 			Else
		   			 	   			If(Alltrim(B9H->B9H_EMAIL) == cEmail .AND. B9H->B9H_COD != cCodAgente)
		   		    	      			cMsg := STR0005//Este e-mail j� existe na base de dados cadastrado para outro agente
		   				      			Help( ,, 'HELP',, cMsg, 1, 0)
		   				      			lRet := .F.
		   			       		Else
		   			           		If(B9H->B9H_TEL == cTel .AND. B9H->B9H_COD != cCodAgente)
		   			    	        		cMsg := STR0006//Este telefone j� existe na base de dados cadastrado para outro agente
		   					        		Help( ,, 'HELP',, cMsg, 1, 0)
		   					        		lRet := .F. 		
		   				        		EndIf
		   		    	   			EndIf
		   		       		EndIf    
		   					EndIf
		   				EndIf      	
		       B9H->(dbSkip()) 
			EndDo
	
	EndIf
	B9H->(dbCloseArea())
	
EndIf

Return (lRet)
