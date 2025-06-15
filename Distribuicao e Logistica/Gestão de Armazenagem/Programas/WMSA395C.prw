#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA395C.CH"

/*
+---------+--------------------------------------------------------------------+
|Fun��o   | WMSA395C - Gera��o de Pedido Cross-Docking Monitor                 |
+---------+--------------------------------------------------------------------+
|Objetivo | Permite efetuar a sele��o de uma listagem de volumes cross-docking |
|         | para efetuar a gera��o de um pedido de vendas integrado com o WMS  |
|         | de forma direta a partir dos itens do volume via monitor.          |
+---------+--------------------------------------------------------------------+
*/

#DEFINE WMSA395C01 "WMSA395C01"
#DEFINE WMSA395C02 "WMSA395C02"
#DEFINE WMSA395C03 "WMSA395C03"
#DEFINE WMSA395C04 "WMSA395C04"
#DEFINE WMSA395C05 "WMSA395C05"
#DEFINE WMSA395C06 "WMSA395C06"
#DEFINE WMSA395C07 "WMSA395C07"
#DEFINE WMSA395C08 "WMSA395C08"
#DEFINE WMSA395C09 "WMSA395C09"
#DEFINE WMSA395C10 "WMSA395C10"
#DEFINE WMSA395C11 "WMSA395C11"
#DEFINE WMSA395C12 "WMSA395C12"
#DEFINE WMSA395C13 "WMSA395C13"

Static cAliasD0N  := GetNextAlias()
Static oTabTmpD0N := Nil
Static oBrowse    := Nil

//------------------------------------------------------------------------------
// Fun��o para aparecer no inspetor de objetos
//------------------------------------------------------------------------------
Function WMSA395C()
Return Nil

//------------------------------------------------------------------------------
// ModelDef
//------------------------------------------------------------------------------
Static Function ModelDef()
Local aColsSX3 := {}
Local oModel   := Nil
Local oStruct  := FWFormModelStruct():New()

	// Monta Struct da TEMP
	oStruct:AddTable(GetNextAlias(), {"TMP_LOCAL","TMP_ENDER"},"Cross-Docking")
	oStruct:AddIndex(1,'1','TMP_LOCAL+TMP_ENDER',BuscarSX3('D0N_LOCAL',,aColsSX3)+"+"+BuscarSX3('D0N_ENDER',,aColsSX3),'','',.T.)

	oStruct:AddField(BuscarSX3('D0N_LOCAL' ,,aColsSX3),aColsSX3[1],'TMP_LOCAL' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.T.,.F.,.T.)
	oStruct:AddField(BuscarSX3('D0N_ENDER' ,,aColsSX3),aColsSX3[1],'TMP_ENDER' ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.T.,.F.,.T.)
	oStruct:AddField(BuscarSX3('BE_DESCRIC',,aColsSX3),aColsSX3[1],'TMP_DESEND','C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.F.,,.T.,.F.,.T.)
	oStruct:AddField(BuscarSX3('C6_CLI'    ,,aColsSX3),aColsSX3[1],'TMP_CLIENT','C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.T.,,.T.,.F.,.T.)
	oStruct:AddField(BuscarSX3('C6_LOJA'   ,,aColsSX3),aColsSX3[1],'TMP_LOJA'  ,'C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.T.,,.T.,.F.,.T.)
	oStruct:AddField(BuscarSX3('C6_SERVIC' ,,aColsSX3),aColsSX3[1],'TMP_SERVIC','C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.T.,,.T.,.F.,.T.)
	oStruct:AddField(BuscarSX3('C6_ENDPAD' ,,aColsSX3),aColsSX3[1],'TMP_ENDDES','C',aColsSX3[3],aColsSX3[4],Nil,{||.T.},Nil,.T.,,.T.,.F.,.T.)

	oStruct:SetProperty("TMP_LOCAL" ,MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"SBE->BE_LOCAL"))
	oStruct:SetProperty("TMP_ENDER" ,MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"SBE->BE_LOCALIZ"))
	oStruct:SetProperty("TMP_DESEND",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"Posicione('SBE',1,xFilial('SBE')+SBE->BE_LOCAL+SBE->BE_LOCALIZ,'BE_DESCRIC')"))

	oStruct:SetProperty("TMP_CLIENT",MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"StaticCall(WMSA395C,ValidField,A,B,C)"))
	oStruct:SetProperty("TMP_LOJA"  ,MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"StaticCall(WMSA395C,ValidField,A,B,C)"))
	oStruct:SetProperty("TMP_SERVIC",MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"StaticCall(WMSA395C,ValidField,A,B,C)"))
	oStruct:SetProperty("TMP_ENDDES",MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID,"StaticCall(WMSA395C,ValidField,A,B,C)"))

	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost   Code-Block de valida��o do formul�rio de edi��o
	// bCommit Code-Block de persist�ncia do formul�rio de edi��o
	// bCancel Code-Block de cancelamento do formul�rio de edi��o
	oModel := MPFormModel():New('WMSA395C', /*bPre*/, {|oModel| ValidMdl(oModel)},{|oModel| CommitMdl(oModel)},/*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pr�-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost        Code-Block de valida��o do formul�rio de edi��o
	// bLoad        Code-Block de carga dos dados do formul�rio de edi��o
	oModel:AddFields('WMSA395CTMP', Nil, oStruct,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetDescription(STR0001) //"Cross-Docking"

	oModel:SetPrimaryKey({'TMP_LOCAL', 'TMP_ENDER'})
	oModel:SetActivate({|oModel| ActivMdl(oModel)})
Return oModel

//----------------------------------------------------------
// ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local aColsSX3 := {}
Local oModel   := FWLoadModel('WMSA395C')
Local oStruct  := FWFormViewStruct():New()
Local oView    := FWFormView():New()
	// Elimina Struct DCW
	// Monta Struct da TEMP
	oStruct:AddField('TMP_LOCAL' ,'01',BuscarSX3('D0N_LOCAL' ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,'NNR',.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStruct:AddField('TMP_ENDER' ,'02',BuscarSX3('D0N_ENDER' ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,'SBE',.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStruct:AddField('TMP_DESEND','03',BuscarSX3('BE_DESCRIC',,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  ,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStruct:AddField('TMP_CLIENT','04',BuscarSX3('C6_CLI'    ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,'SA1',.T.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStruct:AddField('TMP_LOJA'  ,'05',BuscarSX3('C6_LOJA'   ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,Nil  ,.T.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStruct:AddField('TMP_SERVIC','06',BuscarSX3('C6_SERVIC' ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,'DC5',.T.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStruct:AddField('TMP_ENDDES','07',BuscarSX3('C6_ENDPAD' ,,aColsSX3),aColsSX3[1],Nil,'GET',aColsSX3[2],Nil,'SBE',.T.,Nil,Nil,Nil,Nil,Nil,.T.)

	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	oView:CreateHorizontalBox( 'MASTER' , 25,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:AddField('WMSA395CTMP' , oStruct)
	oView:CreateHorizontalBox( 'DETAIL' , 75,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:AddOtherObject('WMSA395CD0N', {|oPanel| MontaBrw(oPanel,oView)})
	// Associa um View a um box
	oView:SetOwnerView('WMSA395CTMP', 'MASTER')
	oView:SetOwnerView('WMSA395CD0N', 'DETAIL')
	oView:SetUseCursor(.F.)
Return oView

//------------------------------------------------------------------------------
// Ao ativar o model, inicializa o objeto com os valores do model
//------------------------------------------------------------------------------
Static Function ActivMdl(oModel)
Local oModelTMP := oModel:GetModel("WMSA395CTMP")
	oModelTMP:LoadValue('TMP_LOCAL', oModelTMP:GetValue('TMP_LOCAL')) // Para for�ar a simula��o de altera��o
	// Pega os dados do cadastro de cliente x endere�o
	D10->(DbSetOrder(2)) // D10_FILIAL+D10_LOCAL+D10_ENDER
	If D10->(DbSeek(xFilial("D10")+oModelTMP:GetValue('TMP_LOCAL')+oModelTMP:GetValue('TMP_ENDER')))
		oModelTMP:SetValue('TMP_CLIENT',D10->D10_CLIENT) // C�digo do Cliente do Endere�o
		oModelTMP:SetValue('TMP_LOJA',D10->D10_LOJA)   // Loja do Cliente do Endere�o
	EndIf
Return .T.

//-----------------------------------------------------------------//
// Fun��o de valida��o dos campos
//-----------------------------------------------------------------//
Static Function ValidField(oModel,cField,xValue)
Local lRet := .T.

	If cField == "TMP_CLIENT"
		lRet := VldCliWMS(oModel,xValue,oModel:GetValue("TMP_LOJA"))
	ElseIf cField == "TMP_LOJA"
		lRet := VldCliWMS(oModel,oModel:GetValue("TMP_CLIENT"),xValue)
	ElseIf cField == "TMP_SERVIC"
		lRet := VldSerWMS(oModel,xValue)
	ElseIf cField == "TMP_ENDDES"
		lRet := VldEndWMS(oModel,oModel:GetValue("TMP_LOCAL"),xValue)
	EndIf
Return lRet

//-----------------------------------------------------------------------------
Static Function VldCliWMS(oModel,cCliente,cLoja)
Local lRet := .T.

	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1")+cCliente+Iif(Empty(cLoja),"",cLoja)))
		If Empty(cLoja)
			oModel:LoadValue("TMP_LOJA",SA1->A1_LOJA)
		Else
			If SA1->A1_MSBLQL == "1"
				oModel:GetModel():SetErrorMessage(oModel:GetId(),"TMP_CLIENT",,,WMSA395C02,STR0002,STR0003) //"Cliente/Loja n�o est� ativo (SA1).","Ative o cliente no cadastro ou escolha outro cliente."
				lRet := .F.
			EndIf
			If lRet .And. Empty(SA1->A1_COND)
				oModel:GetModel():SetErrorMessage(oModel:GetId(),"TMP_CLIENT",,,WMSA395C03,STR0004,STR0005) //"Condi��o de pagamento n�o informada para o Cliente/Loja (SA1).","Ajuste a condi��o de pagamento no cadastro do cliente."
				lRet := .F.
			EndIf
		EndIf
	Else
		oModel:GetModel():SetErrorMessage(oModel:GetId(),"TMP_CLIENT",,,WMSA395C04,STR0006,STR0007) //"Cliente/Loja n�o cadastrado (SA1).","Verifique se os dados informados est�o corretos."
		lRet := .F.
	EndIf

Return lRet

//-----------------------------------------------------------------------------
Static Function VldSerWMS(oModel,cServico)
Local lRet     := .T.
Local oServico := WMSDTCServicoTarefa():New()

	oServico:SetServico(cServico)
	oServico:ServTarefa()
	If !Empty(oServico:GetArrTar())
		oServico:SetOrdem(oServico:GetArrTar()[1][1])
	EndIf
	If oServico:LoadData()
		// Valida se o servi�o possui tarefa de separa��o na primeira sequ�ncia - obrigat�rio ter
		If !oServico:ChkSpCross()
			oModel:GetModel():SetErrorMessage(oModel:GetId(),"TMP_SERVIC",,,WMSA395C05,STR0008,STR0009) //"O servi�o informado deve possuir a fun��o de separa��o cross-docking na primeira tarefa.","Escolha outro servi�o ou ajuste o cadastro de Servi�os x Tarefa."
			lRet := .F.
		EndIf
		// Valida se o servi�o possui confer�ncia de sa�da via convoca��o - n�o pode ter
		If lRet .And. oServico:HasOperac({'7'})
			oModel:GetModel():SetErrorMessage(oModel:GetId(),"TMP_SERVIC",,,WMSA395C06,STR0010,STR0009) //"O servi�o informado n�o pode possuir tarefa de confer�ncia de sa�da.","Escolha outro servi�o ou ajuste o cadastro de Servi�os x Tarefa."
			lRet := .F.
		EndIf
		// Valida se o servi�o possui distribui��o de separa��o - n�o pode ter
		If lRet .And. oServico:ChkDisSep()
			oModel:GetModel():SetErrorMessage(oModel:GetId(),"TMP_SERVIC",,,WMSA395C07,STR0011,STR0009) //"O servi�o informado n�o pode possuir distribui��o de separa��o.","Escolha outro servi�o ou ajuste o cadastro de Servi�os x Tarefa."
			lRet := .F.
		EndIf
		// Valida se o servi�o possui montagem de volumes - obrigat�rio ter
		If lRet .And. !oServico:ChkMntVol()
			oModel:GetModel():SetErrorMessage(oModel:GetId(),"TMP_SERVIC",,,WMSA395C08,STR0012,STR0009) //"O servi�o informado deve possuir montagem de volumes.","Escolha outro servi�o ou ajuste o cadastro de Servi�os x Tarefa."
			lRet := .F.
		EndIf
		// O servi�o n�o pode ser execu��o autom�tica, pois ser� executado pela rotina atual
		If lRet .And. oServico:GetTpExec() == "2"
			oModel:GetModel():SetErrorMessage(oModel:GetId(),"TMP_SERVIC",,,WMSA395C09,STR0013,STR0009) //"O servi�o informado n�o deve ser execu��o autom�tica na integra��o. O mesmo ser� executado pela rotina atual."
			lRet := .F.
		EndIf
	Else
		oModel:GetModel():SetErrorMessage(oModel:GetId(),"TMP_SERVIC",,,WMSA395C10,oServico:GetErro(),STR0007) //"Verifique se os dados informados est�o corretos."
		lRet := .F.
	EndIf

Return lRet

/*------------------------------------------------------------------------------
Valida as informa��es de endere�o para servi�os do WMS
------------------------------------------------------------------------------*/
Static Function VldEndWMS(oModel,cArmazem,cEndereco)
Local lRet     := .T.
	SBE->(dbSetOrder(1))
	If SBE->(!MsSeek(xFilial('SBE')+cArmazem+cEndereco, .F.))
		oModel:GetModel():SetErrorMessage(oModel:GetId(),"TMP_ENDDES",,,WMSA395C11,STR0014,STR0007) //"Endere�o n�o cadastrado (SBE).","Verifique se os dados informados est�o corretos."
		lRet := .F.
	Else
		If DLTipoEnd(SBE->BE_ESTFIS) != 5
			oModel:GetModel():SetErrorMessage(oModel:GetId(),"TMP_ENDDES",,,WMSA395C12,STR0015,STR0016) //"Tipo da estrtura do endere�o inv�lida.","Para servi�os de sa�da somente endere�os de estrutura do tipo box/doca podem ser utilizados."
			lRet := .F.
		EndIf
	EndIf
Return lRet

//------------------------------------------------------------------------------
// Monta o browse para sele��o dos volumes
//------------------------------------------------------------------------------
Static Function MontaBrw(oPanel,oView)
Local oColumn  := Nil
Local aColsSX3 := {}
Local aBrwCols := {}
Local aFields  := {}
Local aIndex   := {}
Local aSeek    := {}
Local aArqTab  := {}
Local nX       := 0

	Aadd( aIndex, "D0N_CODVOL" )
	
	AAdd(aArqTab ,{"D0N_MARK","C",2,0})
	
	AAdd(aBrwCols,{"D0N_CODVOL",BuscarSX3("D0N_CODVOL", ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2],{||(cAliasD0N)->D0N_CODVOL}})
	AAdd(aFields ,{"D0N_CODVOL",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"D0N_CODVOL","C",aColsSX3[3],aColsSX3[4]})
	AAdd(aSeek   ,{ aColsSX3[1], {{"","C", aColsSX3[3], aColsSX3[4], aColsSX3[1],aColsSX3[2]}} })
	
	AAdd(aBrwCols,{"D0N_DATINI",BuscarSX3("D0N_DATINI", ,aColsSX3),"D",aColsSX3[3],aColsSX3[4],aColsSX3[2],{||(cAliasD0N)->D0N_DATINI}})
	AAdd(aFields ,{"D0N_DATINI",aColsSX3[1],"D",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"D0N_DATINI","D",aColsSX3[3],aColsSX3[4]})
	
	AAdd(aBrwCols,{"D0N_HORINI",BuscarSX3("D0N_HORINI", ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2],{||(cAliasD0N)->D0N_HORINI}})
	AAdd(aFields ,{"D0N_HORINI",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"D0N_HORINI","C",aColsSX3[3],aColsSX3[4]})
	
	AAdd(aBrwCols,{"D0N_DATFIM",BuscarSX3("D0N_DATFIM", ,aColsSX3),"D",aColsSX3[3],aColsSX3[4],aColsSX3[2],{||(cAliasD0N)->D0N_DATFIM}})
	AAdd(aFields ,{"D0N_DATFIM",aColsSX3[1],"D",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"D0N_DATFIM","D",aColsSX3[3],aColsSX3[4]})
	
	AAdd(aBrwCols,{"D0N_HORFIM",BuscarSX3("D0N_HORFIM", ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2],{||(cAliasD0N)->D0N_HORFIM}})
	AAdd(aFields ,{"D0N_HORFIM",aColsSX3[1],"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
	AAdd(aArqTab ,{"D0N_HORFIM","C",aColsSX3[3],aColsSX3[4]})
	
	AAdd(aBrwCols,{"D0N_TMPMNT",BuscarSX3("D0N_TMPMNT", ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2],{||CalcTmpMov((cAliasD0N)->D0N_DATINI, (cAliasD0N)->D0N_DATFIM, (cAliasD0N)->D0N_HORINI,(cAliasD0N)->D0N_HORFIM,3)}})
	
	CriaTabTmp(aArqTab,aIndex,cAliasD0N,@oTabTmpD0N)
	LoadData()

	oBrowse := FWMBrowse():New()
	oBrowse:SetOwner(oPanel)
	oBrowse:SetDescription(STR0017) //"Volumes Cross-Docking"
	oBrowse:SetTemporary(.T.)
	oBrowse:SetAlias(cAliasD0N)
	oBrowse:SetMenuDef('')
	oBrowse:AddMarkColumns( {|| Iif(!Empty((cAliasD0N)->D0N_MARK), "LBOK", "LBNO")}, {||MarkRec(oView)}, {||MarkAll(oView)}) // < bMark>, [ bLDblClick], [ bHeaderClick] ) -->
	// Adicionando os campos ao browse
	For nX := 1 To Len(aBrwCols)
		ADD COLUMN oColumn ID aBrwCols[nX,1] TITLE aBrwCols[nX,2] TYPE aBrwCols[nX,3] SIZE aBrwCols[nX,4] DECIMAL aBrwCols[nX,5] PICTURE aBrwCols[nX,6] DATA aBrwCols[nX,7] OF oBrowse
	Next
	oBrowse:DisableDetails()
	oBrowse:SetSeek(/*bSeek*/,aSeek)
	oBrowse:SetFieldFilter( aFields )
	oBrowse:SetUseFilter()
	oBrowse:Activate()
	
	//Seta vari�veis para posterior exclus�o da tabela tempor�ria
	Wms395Tab(cAliasD0N)
	Wms395Ali(oTabTmpD0N)
Return Nil
//------------------------------------------------------------------------------
// SQL para listagem dos dados no browse
//------------------------------------------------------------------------------
Static Function QueryD0N()
Local cQuery := ""

	cQuery := "SELECT '  ' AS D0N_MARK,"
	cQuery +=        " D0N_CODVOL, D0N_DATINI, D0N_HORINI, D0N_DATFIM, D0N_HORFIM"
	cQuery +=  " FROM "+RetSqlName("D0N")+" D0N"
	cQuery += " WHERE D0N.D0N_FILIAL = '"+xFilial("D0N")+"'"
	cQuery +=   " AND D0N.D0N_LOCAL  = '"+SBE->BE_LOCAL+"'"
	cQuery +=   " AND D0N.D0N_ENDER  = '"+SBE->BE_LOCALIZ+"'"
	cQuery +=   " AND D0N.D_E_L_E_T_ = ' '"
Return cQuery

//------------------------------------------------------------------------------
// Efetua a carga dos dados numa tempor�ria para utilizar no browse
//------------------------------------------------------------------------------
Static Function LoadData()
Local cQuery := QueryD0N()
	WmsQry2Tmp(cAliasD0N,oTabTmpD0N:oStruct:aFields,cQuery,oTabTmpD0N)
Return

//------------------------------------------------------------------------------
// Fun��o para marca��o dos registros
//------------------------------------------------------------------------------
Static __nMarkRec := 0
Static Function MarkRec(oView)
	RecLock(cAliasD0N,.F.)
	(cAliasD0N)->D0N_MARK := Iif(Empty((cAliasD0N)->D0N_MARK),"OK","  ")
	(cAliasD0N)->(MsUnlock())
	Iif(Empty((cAliasD0N)->D0N_MARK),__nMarkRec--,__nMarkRec++)
	__lMarkAll := __nMarkRec > 0 // Para for�ar se clicar no header marcar todos
	oView:SetModified(.T.)
Return !Empty((cAliasD0N)->D0N_MARK)

//------------------------------------------------------------------------------
// Fun��o para marca��o de todos os registros
//------------------------------------------------------------------------------
Static __lMarkAll := .T.
Static Function MarkAll(oView)
	
	(cAliasD0N)->(dbSetOrder(1))
	(cAliasD0N)->(dbGoTop() )

	__nMarkRec := 0
	While (cAliasD0N)->(!Eof())
		RecLock(cAliasD0N,.F.)
		(cAliasD0N)->D0N_MARK := Iif(__lMarkAll,"OK","  ")
		(cAliasD0N)->(MsUnlock())
		If __lMarkAll
			__nMarkRec++
		EndIf
		(cAliasD0N)->(DbSkip())
	EndDo
	__lMarkAll := !__lMarkAll
	oView:SetModified(.T.)
	oBrowse:Refresh (.T.)
Return .T.

//------------------------------------------------------------------------------
// Efetua as valida��es do model antes da inclus�o, reavaliando os volumes
//------------------------------------------------------------------------------
Static Function ValidMdl(oModel)
Local lRet := .T.
Local oModelTMP := oModel:GetModel("WMSA395CTMP")
	If __nMarkRec <= 0
		oModel:SetErrorMessage(oModelTMP:GetId(),"TMP_ENDER",,,WMSA395C01,STR0018,STR0019) //"N�o foi selecionado nenhum volume para gera��o de pedido.","Selecione ao menos um volume para gera��o do pedido."
		lRet := .F.
	EndIf
Return lRet

//------------------------------------------------------------------------------
// Efetua a grava��o dos dados do modelo nas tabelas oficiais gerando o pedido
//------------------------------------------------------------------------------
Static Function CommitMdl(oModel)
Local lRet := .T.
Local oModelTMP := oModel:GetModel("WMSA395CTMP")
Local aVolumes  := {}
Local oView     := FWViewActive()
Local nRecno    := (cAliasD0N)->(Recno()) // Salva a posi��o para restaurar por causa do browse

	(cAliasD0N)->(DbGoTop())
	While (cAliasD0N)->(!Eof())
		If !Empty((cAliasD0N)->D0N_MARK)
			AAdd(aVolumes,(cAliasD0N)->D0N_CODVOL)
		EndIf
		(cAliasD0N)->(DbSkip())
	EndDo
	(cAliasD0N)->(DbGoTo(nRecno))

	WmsMsgExibe(.F.) // Para n�o mostrar mensagens de erro
	Processa({|| ;
		lRet := WMSV083PED(oModelTMP:GetValue('TMP_LOCAL'),;
								 oModelTMP:GetValue('TMP_ENDER'),;
								 aVolumes,;
								 oModelTMP:GetValue('TMP_CLIENT'),;
								 oModelTMP:GetValue('TMP_LOJA'),;
								 oModelTMP:GetValue('TMP_SERVIC'),;
								 oModelTMP:GetValue('TMP_ENDDES')), lRet},;
		STR0020,STR0021,.F.) //"Gerar Pedido","Aguarde, processando..."
	 WmsMsgExibe(.T.)
	 If !lRet
		oModel:SetErrorMessage(oModelTMP:GetId(),"TMP_ENDER",,,WMSA395C13,WmsLastMsg(),STR0022) // Verifique os dados informados.
	Else
		If oView != Nil
			oView:setInsertMessage("SIGAWMS",WmsLastMsg()) // Recupera a mensagem do pedido
		EndIf
	EndIf
Return lRet