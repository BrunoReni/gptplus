#INCLUDE 'TMKA230.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �TMKA230   � Autor � Vendas CRM		      � Data �  12/12/11 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Atualiza��o do cadastro de promo��o de cobran�a.             ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   �Void TMKA230(void)                                           ���
��������������������������������������������������������������������������Ĵ��
���Uso       �SIGATMK                                                      ���
��������������������������������������������������������������������������Ĵ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Function TMKA230(xRotAuto,nOpcAuto)

Local oBrowse
Private aRotina   := MenuDef()
Private cCadastro := STR0006 							//"Atualizacao do Cadastro de Promocao de Cobranca"
//��������������������������������������������������������������Ŀ
//� Definicao de variaveis para rotina de inclusao automatica    �
//����������������������������������������������������������������
Private lTk230Auto := ( xRotAuto <> NIL )

If xRotAuto == NIL
	//���������������Ŀ
	//� Cria o Browse �
	//�����������������
	oBrowse := FWMBrowse():New()
	oBrowse :SetAlias('SK3')
	oBrowse :SetDescription(STR0006) // Atualiza��o do cadastro de promo��o de cobran�a
	oBrowse :DisableDetails()
	oBrowse:Activate()
Else
	aRotina := MenuDef()
	FWMVCRotAuto(ModelDef(),"SK3",nOpcAuto,{{"SK3MASTER",xRotAuto}})
Endif	

Return(.T.)

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �MenuDef   � Autor � Vendas CRM		      � Data �  12/12/11 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de definicao do aRotina                               ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   �aRotina   retorna a array com lista de aRotina               ���
��������������������������������������������������������������������������Ĵ��
���Uso       �TmkA230                                                      ���
��������������������������������������������������������������������������Ĵ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotAdic	:= {}		// Retorno do P.E. TK230ROT
Local lTk230Rot  	:= ExistBlock("TK230ROT")
Local aRotina 	:= {}

	ADD OPTION aRotina TITLE STR0001 ACTION 'PesqBrw' 			OPERATION 1	ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.TMKA230'	OPERATION 2	ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.TMKA230'	OPERATION 3	ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.TMKA230'	OPERATION 4	ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.TMKA230'	OPERATION 5	ACCESS 0 //"Excluir"

//��������������������������������������������������������������Ŀ
//� Ponto de entrada - Adiciona rotinas ao aRotina               �
//����������������������������������������������������������������
If lTk230Rot
	aRotAdic := ExecBlock( "TK230ROT", .F., .F. )
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	Endif
Endif

Return(aRotina)
					
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  � Autor � Vendas CRM         � Data � 12/12/11    ���
�������������������������������������������������������������������������͹��
���Desc.     �Define o modelo de dados (MVC)                              ���
�������������������������������������������������������������������������͹��
���Uso       �TmkA230                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
 
Static Function ModelDef()
Local oModel
Local bPosValidacao	:= {|oMdl|Tk230DelMVC(oMdl)}		//Exclus�o da regra de sele��o
Local oStruSK3 		:= FWFormStruct(1,'SK3',/*bAvalCampo*/,/*lViewUsado*/)

oModel := MPFormModel():New('TMKA230',/*bPreValidacao*/,bPosValidacao,/*bCommit*/,/*bCancel*/)
oModel :AddFields('SK3MASTER',/*cOwner*/,oStruSK3,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel :SetDescription(STR0006)

Return(oModel)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   � Autor � Vendas CRM         � Data �  12/12/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Define a interface para cadastro em MVC.                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �TmkA230                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ViewDef()

Local oView
Local oModel   := FWLoadModel('TMKA230')
Local oStruSK3 := FWFormStruct(2,'SK3')

oView := FWFormView():New()
oView :SetModel(oModel)
oView :AddField('VIEW_SK3', oStruSK3,'SK3MASTER')
oView :CreateHorizontalBox('TELA',100)
oView :SetOwnerView('VIEW_SK3','TELA')

Return(oView)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Tk230DelMV�Autor  �Vendas e CRM        � Data �  17/09/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao especifica de exclusao da regra de selecao SK3, para ���
���          �validacao da integridade referencial.                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Tk230DelMVC(oMdl)

Local nOpc 	:= oMdl:GetOperation()
Local cAlias 	:= "SK3"
Local nReg 	:= Recno()
Local aArea	:= GetArea()
Local lRet	:= .T.

if nOpc == MODEL_OPERATION_DELETE 
	
	If ( Type("lTk230Auto") == "U" )
		lTk230Auto := .F.
	Endif
	
	DbSelectArea("ACG")
	DbSetOrder(1)
	#IFDEF TOP
		cQuery	:=	" SELECT ACG_FILIAL, ACG_PROMOC " +;
					" FROM " +	RetSqlName("ACG") + " ACG " +;
					" WHERE	ACG.ACG_FILIAL = '" + xFilial("ACG") + "' AND" +;
					"		ACG.ACG_PROMOC = '" + SK3->K3_CODIGO + "' AND" +;
					"		ACG.D_E_L_E_T_ = ''" +;
					" ORDER BY " + SqlOrder(IndexKey())
			
		cQuery	:= ChangeQuery(cQuery)
		// MemoWrite("TK230Del.SQL", cQuery)
		DbSelectArea("ACG")
		DbCloseArea()
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'ACG', .F., .T.)
		
	#ELSE
		MsSeek(xFilial("ACG"))
	#ENDIF
	
	While !Eof() .AND. ACG->ACG_FILIAL == xFilial("ACG")
		
		If ACG->ACG_PROMOC == SK3->K3_CODIGO
			lRet := .F.
			Exit
		Endif
		
		DbSelectArea("ACG")
		DbSkip()
	End
	
	#IFDEF TOP
		DbSelectArea("ACG")
		DbCloseArea()
		ChkFile("ACG")
	#ENDIF
	
	RestArea(aArea)
	
	If lRet == .F.
		If !lTk230Auto
			Help("  ",1,"TMKNDELREL")
		EndIf
	EndIf
Endif

Return(lRet)					

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �TESTSU9 � Autor � Vendas Clientes         � Data � 24/01/12 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Testa a  Rotina automatica                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATMK                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function TESTSK3() 
Local aDadosSK3:= {} 

RpcSetType( 3 ) 
RpcSetEnv( 'T1', 'D MG 01 '  ) 
 
// Teste Inclusao 
aDadosSK3 := {}

aAdd( aDadosSK3, { "K3_CODIGO"    , "000022"            , NIL } )
aAdd( aDadosSK3, { "K3_DESC"    , "PROMOCAO COBRANCA 000021"            , NIL } )
aAdd( aDadosSK3, { "K3_INICIO"    ,STOD ("20120101") , NIL } )
aAdd( aDadosSK3, { "K3_FINAL" , 	STOD("20120210") ,	 NIL } )
aAdd( aDadosSK3, { "K3_VCTINI"  ,  STOD("20111201")  ,  NIL } )
aAdd( aDadosSK3, { "K3_VCTFIM" ,   STOD("20111230")  , NIL } )
aAdd( aDadosSK3, { "K3_DIADESC" , 2               , NIL } )

DbSelectArea("SK3")
DbSetOrder(1)
DBSeek(XFilial("SK3")+"000022")

lMsErroAuto := .F.
MSExecAuto( { | x, y | TMKA230( x, y ) } , aDadosSK3, 4 ) 

If lMsErroAuto
	If __lSX8
		RollBackSX8() 
	EndIf
	
	MostraErro() 
Else
	If __lSX8
		ConFirmSX8() 
	EndIf
	
	MsgInfo('PROMOCAO inserido com sucesso.')
EndIf
Return (.T.)
 
