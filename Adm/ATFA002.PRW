#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ATFA002.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFA002     �Autor  �Renan Guedes      � Data �  12/09/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de opera��es com controle de aprova��o             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ATFA002()

Local oBrowse
Local lRet			:= .T.
Local aArea			:= GetArea()
Local aAreaSN0		:= {}
Local aAreaFNH		:= {}
Local cCadastro		:= STR0001		//"Opera��es com controle de aprova��o"
Local aOpera		:= {}
Local nX			:= 1
Local nTamRot, nTamOper

If lRet
	dbSelectArea("SN0")
	aAreaSN0 := SN0->(GetArea())
	SN0->(dbSetOrder(1))		//N0_FILIAL+N0_TABELA+N0_CHAVE

	dbSelectArea("FNH")
	aAreaFNH := FNH->(GetArea())
	FNH->(dbSetOrder(1))		//FNH_FILIAL+FNH_ROTINA+FNH_OPER

	nTamRot		:= TamSX3("FNH_ROTINA")[1]
	nTamOper	:= TamSX3("FNH_OPER")[1]

	//Rotinas e opera��es padr�es
	AADD(aOpera, {"ATFA006" , "06"} )
	AADD(aOpera, {"ATFA006" , "07"} )
	AADD(aOpera, {"ATFA006" , "08"} )
	AADD(aOpera, {"ATFA430" , "06"} )
	AADD(aOpera, {"ATFA430" , "10"} )
	AADD(aOpera, {"ATFA430" , "11"} )
	AADD(aOpera, {"ATFA440" , "06"} )

	//Ajusta as strings das rotinas e opera��es padr�es para os tamanhos dos campos da tabela FNH
	AEVAL(aOpera , { |aOp| aOp[1] := PADR(aOp[1] , nTamRot)  } )
	AEVAL(aOpera , { |aOp| aOp[2] := PADR(aOp[2] , nTamOper) } )

	For nX := 1 To Len(aOpera)
		//Verifica se a rotina/opera��o padr�o existe na tabela FNH
		If !FNH->(MsSeek(xFilial("FNH")+aOpera[nX,1]+aOpera[nX,2]))
			//Carrega as opera��es existentes nas rotinas
			//Se n�o existir, inclui a rotina com os dados padr�es
			RecLock("FNH",.T.)
			FNH->FNH_FILIAL	:= xFilial("FNH")
			FNH->FNH_ROTINA	:= aOpera[nX,1]
			FNH->FNH_OPER	:= aOpera[nX,2]
			FNH->FNH_STATUS	:= CriaVar("FNH_STATUS")
			MsUnlock()
		EndIf
	Next nX

	FNH->(dbGoTop())

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("FNH")
	oBrowse:SetDescription(cCadastro) 			//Descri��o do browse
	//Adicona legenda ao browse
	oBrowse:AddLegend( "FNH_STATUS == '1'", "GREEN"		, STR0002	)		//"Controle de aprova��o habilitado"
	oBrowse:AddLegend( "FNH_STATUS == '2'", "RED"		, STR0003	)		//"Controle de aprova��o desabilitado"
	//Adiciona um filtro ao browse
	//oBrowse:SetFilterDefault( "FNF_TPMOV == '1' .And. (FNF_STATUS == '1' .Or. FNF_STATUS == '2') .And. FNF_MSBLQL != '1'"	)
	//Desliga a exibi��o dos detalhes
	//oBrowse:DisableDetails()
	oBrowse:Activate()

	RestArea(aAreaFNH)
	RestArea(aAreaSN0)
EndIf

RestArea(aArea)

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MENUDEF   �Autor  �Renan Guedes        � Data �  11/07/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0004	Action 'VIEWDEF.ATFA002' 	OPERATION 2 ACCESS 0 		//"Visualizar"
ADD OPTION aRotina Title STR0005	Action 'VIEWDEF.ATFA002'	OPERATION 4 ACCESS 0 		//"Manuten��o"

Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFA002   �Autor  �Renan Guedes        � Data �  12/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Modelo de dados do cadastro de opera��es com controle de    ���
���          �aprova��o                                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oStruFNH		:= FWFormStruct( 1, 'FNH' )
Local oModel		// Modelo de dados que ser� constru�do

//oModel := MPFormModel():New( 'ATFA440' , { |oModel| AF440Pos(oModel) } )
oModel := MPFormModel():New( 'ATFA002' )
//Antiga enchoice
oModel:AddFields( 'FNHMASTER', /*cOwner*/, oStruFNH )
//Descri��o do modelo
oModel:SetDescription( STR0006 ) 		//"Cadastro de opera��es com controle de aprova��o"

Return oModel


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFA002   �Autor  �Renan Guedes        � Data �  12/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()

Local oModel 	:= FWLoadModel( 'ATFA002' ) 		// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruFNH 	:= FWFormStruct( 2, 'FNH' ) 		// Cria a estrutura a ser usada na View
Local oView  									// Interface de visualiza��o constru�da

// Cria o objeto de View
oView := FWFormView():New()
// Define qual o Modelo de dados ser� utilizado na View
oView:SetModel( oModel )
// Adiciona no nosso View um controle do tipo formul�rio
oView:AddField( 'VIEWFNH', oStruFNH, 'FNHMASTER' )
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )
// Relaciona o identificador (ID) da View com o "box" para exibi��o
oView:SetOwnerView( 'VIEWFNH', 'TELA' )
/* Desabilita o novo botao "salvar e criar novo" */
oView:SetCloseOnOK({ || .T. })

Return oView
