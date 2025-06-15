#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA395B.CH"

/*
+---------+--------------------------------------------------------------------+
|Fun��o   | WMSA395B - Modelo e View de Manipula��o de Volumes Cross-Docking   |
+---------+--------------------------------------------------------------------+
|Objetivo | Permite efetuar a montagem de volumes em endere�os cross-docking   |
|         | de forma manual atrav�s do monitor de volumes cross-docking.       |
+---------+--------------------------------------------------------------------+
*/

#DEFINE WMSA395B01 "WMSA395B01"

Static __lEstItVol := .F.

//------------------------------------------------------------------------------
// Fun��o para aparecer no inspetor de objetos
//------------------------------------------------------------------------------
Function WMSA395B()
Return Nil

Function WMSA395BIV(lEstItVol)
	If lEstItVol != Nil 
		__lEstItVol := lEstItVol
	EndIf
Return __lEstItVol

//-------------------------------------------------------------------//
//-------------------------Funcao ModelDef---------------------------//
//-------------------------------------------------------------------//
Static Function ModelDef()
Local oModel  := MPFormModel():New('WMSA395B',{|oModel| BeforeCMdl(oModel) },/*bValid*/,{|oModel| CommitMdl(oModel)})
Local oStrD0N := FWFormStruct(1,'D0N')
Local oStrD0O := FWFormStruct(1,'D0O')
Local aFilter := {}

	oStrD0N:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)
	oStrD0O:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)

	oModel:AddFields('A395D0N',,oStrD0N)
	oModel:AddGrid('A395D0O','A395D0N',oStrD0O)
	oModel:SetRelation('A395D0O', { { 'D0O_FILIAL', 'xFilial("D0O")' }, { 'D0O_CODVOL', 'D0N_CODVOL' } }, D0O->(IndexKey(1)) )
	
	If __lEstItVol
		AAdd(aFilter,{"D0O_PRDORI","'"+D0O->D0O_PRDORI+"'",MVC_LOADFILTER_EQUAL})
		AAdd(aFilter,{"D0O_CODPRO","'"+D0O->D0O_CODPRO+"'",MVC_LOADFILTER_EQUAL})
		AAdd(aFilter,{"D0O_LOTECT","'"+D0O->D0O_LOTECT+"'",MVC_LOADFILTER_EQUAL})
		AAdd(aFilter,{"D0O_NUMLOT","'"+D0O->D0O_NUMLOT+"'",MVC_LOADFILTER_EQUAL})
		oModel:GetModel( 'A395D0O' ):SetLoadFilter(aFilter)
	EndIf

	oModel:GetModel('A395D0N'):SetOnlyView(.T.)
	oModel:GetModel('A395D0O'):SetOnlyView(.T.)

Return oModel

//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()
Local oModel := ModelDef()
Local oView  := FWFormView():New()
Local oStrD0N := FWFormStruct(2,'D0N')
Local oStrD0O := FWFormStruct(2,'D0O')

	oStrD0N:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
	oStrD0O:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
	oStrD0O:RemoveField("D0O_CODVOL")

	oView:SetModel(oModel)
	oView:AddField( 'A395D0N', oStrD0N, 'A395D0N')
	oView:AddGrid( 'A395D0O', oStrD0O, 'A395D0O')

	oView:CreateHorizontalBox( 'BOXD0N', 30)
	oView:CreateHorizontalBox( 'BOXD0O', 70)

	oView:EnableTitleView('A395D0N', STR0001) // Volume
	oView:EnableTitleView('A395D0O', STR0002) // Itens Volume

	oView:SetOwnerView('A395D0N','BOXD0N')
	oView:SetOwnerView('A395D0O','BOXD0O')
Return oView

//------------------------------------------------------------------------------
// For�a a modifica��o do modelo
//------------------------------------------------------------------------------
Static Function BeforeCMdl(oModel)
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		oModel:lModify := .T.
	EndIf
Return .T.

//------------------------------------------------------------------------------
// Efetua a grava��o dos dados do modelo nas tabelas oficiais
//------------------------------------------------------------------------------
Static Function CommitMdl(oModel)
Local lRet := .T.
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		lRet := FwFormCommit(oModel,,,,{|oModel| InTTSAtuMVC(oModel)})
	ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE
		lRet := FwFormCommit(oModel,,{|oModel,cID,cAlias| PosAtuMVC(oModel,cID,cAlias)})
	EndIf
Return lRet

//------------------------------------------------------------------------------
// Fun��o para atualiza��o das informa��es complementares com base no modelo
//------------------------------------------------------------------------------
Static Function PosAtuMVC(oModel,cID,cAlias)
Local lRet := .T.
Local oEstEnder := WMSDTCEstoqueEndereco():New()

	If cID == 'A395D0O' // Se est� excluindo os itens do volume
		// Carrega dados para LoadData EstEnder
		oEstEnder:ClearData()
		oEstEnder:oEndereco:SetArmazem(oModel:GetModel():GetModel("A395D0N"):GetValue("D0N_LOCAL"))
		oEstEnder:oEndereco:SetEnder(oModel:GetModel():GetModel("A395D0N"):GetValue("D0N_ENDER"))
		oEstEnder:oProdLote:SetArmazem(oModel:GetModel():GetModel("A395D0N"):GetValue("D0N_LOCAL")) // Armazem
		oEstEnder:oProdLote:SetPrdOri(oModel:GetValue("D0O_PRDORI"))   // Produto Origem - Componente
		oEstEnder:oProdLote:SetProduto(oModel:GetValue("D0O_CODPRO")) // Produto Principal
		oEstEnder:oProdLote:SetLoteCtl(oModel:GetValue("D0O_LOTECT")) // Lote do produto principal que dever� ser o mesmo no componentes
		oEstEnder:oProdLote:SetNumLote(oModel:GetValue("D0O_NUMLOT")) // Sub-Lote do produto principal que dever� ser o mesmo no componentes
		oEstEnder:SetQuant(oModel:GetValue("D0O_QUANT"))
		If !(lRet := oEstEnder:UpdSaldo("999",.F.,.F.,.F.,.F.,.T.)) //cTipo,lEstoque,lEntPrev,lSaiPrev,lEmpenho,lBloqueio,lEmpPrev
			oModel:GetModel():SetErrorMessage(oModel:GetId(),"D0O_CODPRO",,,WMSA395B01,oEstEnder:GetErro(),STR0003) // Verifique o saldo por endere�o do produto.
		EndIf
	EndIf
Return lRet

//------------------------------------------------------------------------------
// Realiza a grava��o do estorno na transla��o
//------------------------------------------------------------------------------
Static Function InTTSAtuMVC(oModel)
Local lRet := .T.
Local oModelD0N := oModel:GetModel("A395D0N")
Local oModelD0O := oModel:GetModel("A395D0O")
Local nI        := 0
Local oMntVolIt := Nil
Local aProdutos := {}

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If __lEstItVol
			oMntVolIt := WMSDTCVolumeCrossDockingItens():New() // Cross-Docking
			oMntVolIt:oVolume:SetArmazem(oModelD0N:GetValue("D0N_LOCAL"))
			oMntVolIt:oVolume:SetEnder(oModelD0N:GetValue("D0N_ENDER"))
			oMntVolIt:oVolume:SetCodVol(oModelD0N:GetValue("D0N_CODVOL"))
			For nI := 1 To oModelD0O:Length()
				oModelD0O:GoLine(nI)
				AAdd(aProdutos,{oModelD0O:GetValue("D0O_CODPRO"),oModelD0O:GetValue("D0O_LOTECT"),oModelD0O:GetValue("D0O_NUMLOT"),oModelD0O:GetValue("D0O_QUANT"),oModelD0O:GetValue("D0O_PRDORI")})
			Next
			If !(lRet := oMntVolIt:EstPrdVol(aProdutos,.F.))
				oModel:SetErrorMessage(oModelD0O:GetId(),"D0O_CODPRO",,,WMSA395A02,oMntVolIt:GetErro(),"Verifique os dados deste produto do volume.")
			EndIf
		EndIf
	EndIf
Return lRet
