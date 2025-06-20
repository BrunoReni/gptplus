#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA042.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FISA041  �Autor  � Vitor Felipe       � Data � 11/11/2011  ���
�������������������������������������������������������������������������͹��
���Desc.     �  Cadastro da tabela de Ajuste de Creditos SPED PIS/COFINS  ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FISA042()

	Local   oBrowse
	Private EAI_MESSAGE_MVC := ""
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("CF5")
	oBrowse:SetDescription(STR0001) //"Cadastro de Ajustes de Credito SPED PIS e COFINS"
	oBrowse:AddLegend( "CF5_INDAJU=='0'", "RED", STR0002 ) // "Ajuste de Redu��o"
	oBrowse:AddLegend( "CF5_INDAJU=='1'", "GREEN", STR0003 ) // "Ajuste de Acr�scimo"
	oBrowse:Activate()
	
Return

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � MenuDef       �Autor  � Vitor Felipe       � Data � 11/11/2011  ���
������������������������������������������������������������������������������͹��
���Desc.     � Definicao do MenuDef para o MVC                                 ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                         ���
������������������������������������������������������������������������������͹��
���Parametros�                                                                 ���
������������������������������������������������������������������������������͹��
���Retorno   �Array                                                            ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function MenuDef()

	Local aRotina := {}
	
	
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA042' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA042' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FISA042' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.FISA042' OPERATION 5 ACCESS 0 //'Excluir'
		
Return aRotina

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ModelDef      �Autor  � Vitor Felipe       � Data � 11/11/2011  ���
������������������������������������������������������������������������������͹��
���Desc.     � Definicao do ModelDef para o MVC.                               ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                         ���
������������������������������������������������������������������������������͹��
���Parametros�                                                                 ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ModelDef()

	Local oModel
	Local oStructCAB := FWFormStruct( 1 , "CF5" )
	
	oModel	:=	MPFormModel():New('FISA042MOD', ,{ |oModel| ValidForm(oModel) }  )
	
	oModel:AddFields( 'FISA042MOD' ,, oStructCAB )
	 
	oModel:SetPrimaryKey({"CF5_CODIGO"},{"CF5_INDAJU"},{"CF5_PISCOF"},{"CF5_CODAJU"},{"DTOS(CF5_DTREF)"})

	oModel:SetDescription(STR0009) // "Ajuste de Creditos PIS e Cofins"
	
Return oModel

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ViewDef       �Autor  � Vitor Felipe       � Data � 11/11/2011  ���
������������������������������������������������������������������������������͹��
���Desc.     � Definicao da Visualizacao para o MVC.                           ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                         ���
������������������������������������������������������������������������������͹��
���Parametros�                                                                 ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ViewDef()

	Local oView      := FWFormView():New()
	Local oModel     := FWLoadModel( "FISA042" )
	Local oStructCAB := FWFormStruct( 2 , "CF5" )

	oView:SetModel(oModel)

	oView:AddField( "VIEW_CAB" , oStructCAB , 'FISA042MOD')

	oView:CreateHorizontalBox( "CABEC" , 100 )

	oView:SetOwnerView( "VIEW_CAB" , "CABEC" )
	
Return oView

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � ValidForm     �Autor  � Erick G Dias       � Data � 03/0102011  ���
������������������������������������������������������������������������������͹��
���Desc.     � Valida��o das informa��es digitadas no form.                    ���
������������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                         ���
������������������������������������������������������������������������������͹��
���Parametros�                                                                 ���
������������������������������������������������������������������������������͹��
���Retorno   � Objeto                                                          ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ValidForm(oModel)

	Local lRet			:=	.T.
	Local cEndAju		:=	oModel:GetValue ('FISA042MOD','CF5_INDAJU')
	Local cPISCOF		:=	oModel:GetValue ('FISA042MOD','CF5_PISCOF')
	Local cCodAju		:=	oModel:GetValue ('FISA042MOD','CF5_CODAJU')
	Local cDtRef		:=	oModel:GetValue ('FISA042MOD','CF5_DTREF')
	Local cCodCred		:=	""
	Local cChave		:=	""
	Local nOperation	:=	oModel:GetOperation()
	
	If nOperation == 3  //Inclus�o de informa��es ou altera��es.
		DbSelectArea ("CF5")
		CF5->(DbSetOrder (1))
		
		cCodCred:= oModel:Getvalue('FISA042MOD','CF5_CODCRE')
		cChave  := oModel:Getvalue('FISA042MOD','CF5_CODIGO') + (cEndAju+cPISCOF+cCodAju+Dtos(cDtRef)+cCodCred) 
		If CF5->(DbSeek(xFilial("CF5")+cChave))
			lRet := .F.
			Help("",1,"Help","Help",STR0010,1,0) //"Ind. de Ajuste, Pis ou COFINS, Cod. de Ajuste e Data Referencial j� cadastrados!"
		EndIF
	EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A042TIPAJU
Cria opcoes e o valid para o campo CF5_TIPAJU (X3_CBOX)
Parametro: nOpc -> 0 retorna validacao para funcao pertence
                   1 retorna as opcoes de escolha para o usuario

@author flavio.luiz
@since 05/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function A042TIPAJU(nOpc)
Local nI   := 1
Local cRet := ""
Local aOpc := {}

AADD(aOpc,"01=Ajuste da CPRB: Ado��o do Regime de Caixa")
AADD(aOpc,"02=Ajuste da CPRB: Diferimento de Valores a recolher no per�odo")
AADD(aOpc,"03=Adi��o de valores Diferidos em Per�odo(s) Anteriores(es)")
AADD(aOpc,"04=Exporta��es diretas")
AADD(aOpc,"05=Transporte internacional de cargas")
AADD(aOpc,"06=Vendas canceladas e os descontos incondicionais concedidos")
AADD(aOpc,"07=IPI, se inclu�do na receita bruta")
AADD(aOpc,"08=ICMS, quando cobrado pelo vendedor dos bens ou prestador dos servi�os na condi��o de substituto tribut�rio")
AADD(aOpc,"09=Receita bruta reconhecida pela constru��o, recupera��o, reforma, amplia��o ou melhoramento da infraestrutura, cuja contrapartida seja ativo intang�vel representativo de direito de explora��o, no caso de contratos de concess�o de servi�os p�blicos")
AADD(aOpc,"10=O valor do aporte de recursos realizado nos termos do art 6 �3 inciso III da Lei 11.079/2004")
AADD(aOpc,"11=Demais ajustes oriundos da Legisla��o Tribut�ria, estorno ou outras situa��es")

For nI:=1 To Len(aOpc)
	If nOpc==0
		cRet += IIf(empty(cRet),' ',';') + Left(aOpc[nI],2)
	Else
		cRet += IIf(empty(cRet),'',';') + aOpc[nI]
	Endif
Next

If nOpc==0
	cRet := &("Pertence('"+cRet+"')")
Endif

Return (cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Mensagem Unica

@return aRet

@author Flavio L Vicco
@since 05/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage, cVersion)

Local aRet

// Chama a rotina que trata a parte principal
aRet := FISI042( cXML, nTypeTrans, cTypeMessage, cVersion )
//
Return aRet
