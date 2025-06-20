#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAF92.CH"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} TMSAF92
Integra��o do Faturamento com Coleta/Entrega
@type Function
@author Valdemar Roberto Mognon
@since 06/11/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAF92()
(examples)
@see (links_or_references)
*/
Function TMSAF92()

Local cCadastro := STR0001
	If TM92VldInt()
		Private aRotina := MenuDef()

		oBrowse := FWmBrowse():New()
		oBrowse:SetAlias("DNE")
		oBrowse:SetDescription(cCadastro)

		oBrowse:AddLegend("DNE->DNE_STATUS=='1'","GREEN" ,STR0040)	//-- "Em Aberto"
		oBrowse:AddLegend("DNE->DNE_STATUS=='2'","BLUE"  ,STR0041)	//-- "Fechado"

		oBrowse:Activate()
	EndIf
Return

/*{Protheus.doc} MenuDef
Defini��o do aRotina (Menu funcional)
@type Static Function
@author Valdemar Roberto Mognon
@since 06/11/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example MenuDef()
(examples)
@see (links_or_references)
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0002 Action "AxPesqui"         OPERATION 1 ACCESS 0	//-- "Pesquisar"
ADD OPTION aRotina Title STR0003 Action "VIEWDEF.TMSAF92"  OPERATION 2 ACCESS 0	//-- "Visualizar"
ADD OPTION aRotina Title STR0004 Action "VIEWDEF.TMSAF92"  OPERATION 3 ACCESS 0	//-- "Incluir"
ADD OPTION aRotina Title STR0005 Action "VIEWDEF.TMSAF92"  OPERATION 4 ACCESS 0	//-- "Alterar"
ADD OPTION aRotina Title STR0006 Action "VIEWDEF.TMSAF92"  OPERATION 5 ACCESS 0	//-- "Excluir"
ADD OPTION aRotina Title STR0011 Action 'TMSAF92Sup(6,,)'  OPERATION 2 ACCESS 0	//-- 'Grava Hist'
ADD OPTION aRotina Title STR0012 Action 'TMSAF92Sup(7,,)'  OPERATION 2 ACCESS 0	//-- 'Env. Portal'
ADD OPTION aRotina Title STR0013 Action 'TMSAF92Sup(8,,)'  OPERATION 2 ACCESS 0	//-- 'Estorna'
ADD OPTION aRotina Title STR0014 Action 'TMSAF92Sup(9,,1)' OPERATION 2 ACCESS 0	//-- 'Env. Motoris.'
ADD OPTION aRotina Title STR0015 Action 'TMSAF92Sup(9,,2)' OPERATION 2 ACCESS 0	//-- 'Est. Motoris.'

Return aRotina

/*{Protheus.doc} ModelDef
Defini��o do Modelo
@type Static Function
@author Valdemar Roberto Mognon
@since 06/11/2022
@version P12 R12.1.20
@param param, param_type, param_descr
@return return, return_type, return_description
@example ModelDef()
(examples)
@see (links_or_references)
*/
Static Function ModelDef()
Local oStruCDNE  := FWFormStruct(1,"DNE")
Local oStruIDNF  := FWFormStruct(1,"DNF")
Local bLinPreDNF := {|oModel,nLine,cAction,cIDField,xValue,xCurrentValue| Tmsaf92Pre(oModel,nLine,cAction,cIDField,xValue,xCurrentValue)}
Local oModel

oStruIDNF:RemoveField("DNF_FILORI")
oStruIDNF:RemoveField("DNF_VIAGEM")

oModel := MpFormModel():New("TMSAF92",/*bPreValidacao*/,{|oModel| TMSAF92Pos(oModel)}/*bPosVld*/,{|oModel| TMSAF92Cmt( oModel ) }/*bCommit*/,/*bCancel*/)

oModel:SetDescription(STR0001)	//-- "Integra��o do Faturamento com Coleta/Entrega"

//-- Cabe�alho da Viagem
oModel:AddFields("MdFieldDNE",,oStruCDNE,,,)
oModel:SetPrimaryKey({"DNE_FILORI","DNE_VIAGEM"})
oModel:GetModel("MdFieldDNE"):SetDescription(STR0007)	//-- "Viagens do Faturamento"

//-- Grid das Notas da Viagem
oModel:AddGrid("MdGridDNF","MdFieldDNE",oStruIDNF,bLinPreDNF/*bLinPre*/,/*bLinPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridDNF",{{"DNF_FILIAL" ,"xFilial('DNF')"},;
								{"DNF_FILORI","DNE_FILORI"},;
								{"DNF_VIAGEM","DNE_VIAGEM"}},;
								 DNF->(IndexKey(1)))
oModel:GetModel("MdGridDNF"):SetDescription(STR0008)	//-- "Notas da Viagem"
oModel:GetModel("MdGridDNF"):SetUniqueLine({"DNF_FILIAL","DNF_DOC","DNF_SERIE"})

Return oModel

/*{Protheus.doc} ViewDef
Defini��o da View
@type Static Function
@author Valdemar Roberto Mognon
@since 06/11/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example ViewDef()
(examples)
@see (links_or_references)
*/
Static Function ViewDef()
Local oStruCDNE := FWFormStruct(2,"DNE")
Local oStruIDNF := FWFormStruct(2,"DNF")
Local oModel    := FwLoadModel("TMSAF92")
Local oView

oStruIDNF:RemoveField("DNF_FILORI")
oStruIDNF:RemoveField("DNF_VIAGEM")

oView := FwFormView():New()
oView:SetModel(oModel)

//-- Define a tela principal
oView:CreateHorizontalBox("TelaViagem",025)
oView:CreateHorizontalBox("TelaNotas" ,075)

oView:CreateVerticalBox("Botoes"    , 3,"TelaNotas")
oView:CreateVerticalBox("Documentos",97,"TelaNotas")

//-- Define o Field da Tela Principal
oView:AddField("VwFieldDNE",oStruCDNE,"MdFieldDNE")
oView:SetOwnerView("VwFieldDNE","TelaViagem")

//-- Define os Grids da Tela Principal
oView:AddGrid("VwGridDNF",oStruIDNF,"MdGridDNF")
oView:SetOwnerView("VwGridDNF","Documentos")
oView:AddIncrementField("VwGridDNF","DNF_ITEM")

//-- Define os Bot�es da Tela Principal
oView:AddOtherObject("VwButMan",{|oPanel| TM92ButMan(oPanel)})
oView:SetOwnerView("VwButMan","Botoes")

oView:SetViewAction("DELETELINE"  ,{|oView,cIDGrid,nLine| Tmsaf92Act(oView,cIDGrid,nLine,1)})
oView:SetViewAction("UNDELETELINE",{|oView,cIDGrid,nLine| Tmsaf92Act(oView,cIDGrid,nLine,2)})

Return oView

/*{Protheus.doc} TMSAF92Vld
Valida��o dos campos da tela
@type Static Function
@author Valdemar Roberto Mognon
@since 25/11/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
(examples)
@see (links_or_references)
*/
Function TMSAF92Vld(cCampo)
Local aAreas    := {SF2->(GetArea()),GetArea()}
Local lRet      := .T.
Local oModel    := FwModelActive()
Local oModelDNE := oModel:GetModel("MdFieldDNE")
Local oModelDNF := oModel:GetModel("MdGridDNF")

Default cCampo := ReadVar()

If "DNF_FILNFC" $ cCampo
	SF2->(DbSetOrder(1))
	If !( lRet := SF2->(MsSeek(M->DNF_FILNFC)) )
		Help("","","HELP",,STR0042,1,0) //-- "N�o h� notas para esta filial."
	EndIf
ElseIf Empty(oModelDNF:GetValue("DNF_FILNFC"))
	Help("","","HELP",,STR0043,1,0) //-- "Deve ser preenchido primeiro o campo Filial."
	lRet := .F.
ElseIf "DNF_DOC" $ cCampo
	If !Empty(oModelDNE:GetValue("DNE_CODVEI"))
		If !Empty(oModelDNF:GetValue("DNF_SERIE"))
			SF2->(DbSetOrder(1))
			lRet := (SF2->(DbSeek(oModelDNF:GetValue("DNF_FILNFC") + M->DNF_DOC + oModelDNF:GetValue("DNF_SERIE"))))
			If lRet
				If !Empty(SF2->F2_VEICUL1) .And. SF2->F2_VEICUL1 != oModelDNE:GetValue("DNE_CODVEI")
					Help("","","HELP",,STR0034,1,0)	//-- "Nota fiscal n�o pertence ao ve�culo."
					lRet := .F.
				Else
					lRet := !TM92SeekNF(oModelDNF:GetValue("DNF_FILNFC"),oModelDNF:GetValue("DNF_DOC"),oModelDNF:GetValue("DNF_SERIE"),"1",2,oModelDNE:GetValue("DNE_FILORI"),oModelDNE:GetValue("DNE_VIAGEM"))
				EndIf
			EndIf
		EndIf
	Else
		Help("","","HELP",,STR0035,1,0)	//-- "Ve�culo n�o preenchido."
		lRet := .F.
	EndIf

	If lRet .And. !Empty(oModelDNF:GetValue("DNF_SERIE"))
		If !Empty(SF2->F2_NUMMDF) .And. !Empty(SF2->F2_SERMDF) .And. !IsInCallStack("TM92PrcMan")
			TM92PrcMan(,,SF2->F2_FILIAL,SF2->F2_NUMMDF,SF2->F2_SERMDF)
		EndIf
	EndIf
ElseIf "DNF_SERIE" $ cCampo
	If !Empty(oModelDNE:GetValue("DNE_CODVEI"))
		If !Empty(oModelDNF:GetValue("DNF_DOC"))
			SF2->(DbSetOrder(1))
			lRet := (SF2->(DbSeek(oModelDNF:GetValue("DNF_FILNFC") + oModelDNF:GetValue("DNF_DOC") + M->DNF_SERIE)))
			If lRet
				If !Empty(SF2->F2_VEICUL1) .And. SF2->F2_VEICUL1 != oModelDNE:GetValue("DNE_CODVEI")
					Help("","","HELP",,STR0034,1,0)	//-- "Nota fiscal n�o pertence ao ve�culo."
					lRet := .F.
				Else
					lRet := !TM92SeekNF(oModelDNF:GetValue("DNF_FILNFC"),oModelDNF:GetValue("DNF_DOC"),oModelDNF:GetValue("DNF_SERIE"),"1",2,oModelDNE:GetValue("DNE_FILORI"),oModelDNE:GetValue("DNE_VIAGEM"))
				EndIf
			EndIf
		EndIf
	Else
		Help("","","HELP",,STR0035,1,0)	//-- "Ve�culo n�o preenchido."
		lRet := .F.
	EndIf
	
	If lRet .And. !Empty(oModelDNF:GetValue("DNF_DOC"))
		If !Empty(SF2->F2_NUMMDF) .And. !Empty(SF2->F2_SERMDF) .And. !IsInCallStack("TM92PrcMan")
			TM92PrcMan(,,SF2->F2_FILIAL,SF2->F2_NUMMDF,SF2->F2_SERMDF)
		EndIf
	EndIf
ElseIf "DNF_SERMDF" $ cCampo
	If !Empty(SF2->F2_NUMMDF) .And. !Empty(SF2->F2_SERMDF) .And. !IsInCallStack("TM92PrcMan") .And. ( lRet := TM92VldMrk(SF2->F2_NUMMDF,SF2->F2_SERMDF) )
		TM92PrcMan(,,SF2->F2_FILIAL,SF2->F2_NUMMDF,SF2->F2_SERMDF)
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TM92ButMan
Cria��o do bot�o de sele��o dos manifestos
@type Static Function
@author Valdemar Roberto Mognon
@since 25/11/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
(examples)
@see (links_or_references)
*/
Static Function TM92ButMan(oPanel)
Local oTBitmap1

oTBitmap1 := TBitmap():New(05,03,260,184,,"BMPVISUAL",.T.,oPanel,{|| TM92SelMan()},,.F.,.F.,,,.F.,,.T.,,.F.)
oTBitmap1:lAutoSize := .T.

Return NIL

/*{Protheus.doc} TM92SelMan
Seleciona manifestos
@type Static Function
@author Valdemar Roberto Mognon
@since 25/11/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
(examples)
@see (links_or_references)
*/
Function TM92SelMan()
Local aAreas     := {GetArea()}
Local aRotBak    := {}
Local oModel     := FwModelActive()
Local oModelDNE  := oModel:GetModel("MdFieldDNE")
Local cFiltro    := ""
Local oDlgMrk

If Empty(oModelDNE:GetValue("DNE_CODVEI"))
	Help("","","HELP",,STR0035,1,0)	//-- "Ve�culo n�o preenchido."

ElseIf Pergunte("TMSAF92")
	cFiltro := "CC0->CC0_FILIAL == '"+MV_PAR01+"' .And. "
	cFiltro += "CC0->CC0_STAINT != '1' .And. CC0->CC0_VEICUL == '" + oModelDNE:GetValue("DNE_CODVEI") + "'"
	aRotBak := Aclone(aRotina)
	aRotina := { { STR0009, "TM92PrcMan(oMrkBrowse,oMrkBrowse:Mark(),,)", 0, 1, 0, .F. } }	//-- "Confirma"
	
	oMrkBrowse:= FWMarkBrowse():New()
	oMrkBrowse:SetFieldMark("CC0_OK")
	oMrkBrowse:SetOwner(oDlgMrk)
	oMrkBrowse:SetAlias("CC0")
	oMrkBrowse:SetMenuDef("")
	oMrkBrowse:AddFilter("MANUAL",cFiltro,.T.,.T.)
	oMrkBrowse:SetDescription(STR0010)	//-- "Selecione o Manifesto"
	oMrkBrowse:bAllMark := {|| Tmsaf92All(oMrkBrowse,oMrkBrowse:Mark())}
	oMrkBrowse:DisableReport()
	oMrkBrowse:DisableConfig()
	oMrkBrowse:DisableDetails()
	oMrkBrowse:SetValid({|| TM92VldMrk()  })
	oMrkBrowse:Activate()
	
	aRotina := Aclone(aRotBak)
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} TM92PrcMan
Processa Manifestos
@type Static Function
@author Valdemar Roberto Mognon
@since 28/11/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
(examples)
@see (links_or_references)
*/
Function TM92PrcMan(oMarkBrw,cMark,cFilNFS,cNumMDF,cSerMDF)
Local aAreas     := {CC0->(GetArea()),GetArea()}
Local cQuery     := ""
Local cAliasSF2  := ""
Local cUltMan    := ""
Local oModel     := FwModelActive()
Local oView      := FwViewActive()
Local oMdlGrdDNF := oModel:GetModel("MdGridDNF")
Local nLinAtu    := 0
Local lSeek      := .T.
Local nLine      := oMdlGrdDNF:GetLine()

Default oMarkBrw := Nil
Default cMark    := ""
Default cFilNFS  := CC0->CC0_FILIAL
Default cSerMDF  := CC0->CC0_SERMDF
Default cNumMDF  := CC0->CC0_NUMMDF

cAliasSF2 := GetNextAlias()
cQuery := " SELECT F2_FILIAL,F2_DOC,F2_SERIE,F2_SERMDF,F2_NUMMDF "
cQuery += "FROM " + RetSQLName("SF2") + " SF2 "

cQuery += "JOIN " + RetSQLName("CC0") + " CC0 "
cQuery +=   "ON CC0.CC0_FILIAL = '" + cFilNFS + "' "
cQuery +=  "AND CC0.CC0_NUMMDF = SF2.F2_NUMMDF "
cQuery +=  "AND CC0.CC0_SERMDF = SF2.F2_SERMDF "
If !Empty(cMark)
	cQuery += "AND CC0_OK = '" + cMark + "' "
EndIf
cQuery += "AND CC0.D_E_L_E_T_ = ' ' "

cQuery += "WHERE SF2.F2_FILIAL = '" + cFilNFS + "' "
cQuery +=   "AND SF2.F2_NUMMDF = '" + cNumMDF + "' "
cQuery +=   "AND SF2.F2_SERMDF = '" + cSerMDF + "' "
cQuery +=   "AND SF2.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY CC0_NUMMDF,CC0_SERMDF "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery ),cAliasSF2,.F.,.T.)

CC0->(DbSetOrder(1))

While (cAliasSF2)->(!Eof())
	cUltMan := (cAliasSF2)->(F2_NUMMDF + F2_SERMDF)

	While (cAliasSF2)->(!Eof()) .And. (cAliasSF2)->(F2_NUMMDF + F2_SERMDF) == cUltMan
		//-- Linha Posicionada na Grid
		lSeek:= oMdlGrdDNF:SeekLine({{"DNF_DOC",(cAliasSF2)->F2_DOC},{"DNF_SERIE",(cAliasSF2)->F2_SERIE}})
		If !lSeek
			If !oMdlGrdDNF:IsEmpty()
				oMdlGrdDNF:AddLine()
			EndIf
			nLinAtu:= oMdlGrdDNF:Length()
			oMdlGrdDNF:GoLine(nLinAtu)
			oMdlGrdDNF:SetValue( "DNF_FILNFC", cFilNFS )
			oMdlGrdDNF:SetValue( "DNF_DOC"	 , (cAliasSF2)->F2_DOC )
			oMdlGrdDNF:SetValue( "DNF_SERIE" , (cAliasSF2)->F2_SERIE )
		EndIf
	
		(cAliasSF2)->(DbSkip())
	EndDo
	
EndDo

(cAliasSF2)->(DbCloseArea())

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
oMdlGrdDNF:GoLine(nLine)
oView:Refresh()

If !Empty(oMarkBrw)
	oMarkBrw:GetOwner():End()
EndIf

Return

//-----------------------------------------------------------
/*/{Protheus.doc} Tmsaf92All
Marca/Desmarca todos os registros
@author Valdemar Roberto Mognon
@version P12
@Since 30/11/2022
@version 1.0
/*/
//-----------------------------------------------------------
Function Tmsaf92All(oMarkBrw,cMark)

CC0->(DbGoTop())

While CC0->(!Eof())
	If CC0->(MsRLock())
		If CC0->CC0_OK == cMark
			CC0->CC0_OK := "  "
			CC0->(MsUnlock())
		Else
			CC0->CC0_OK := cMark
		Endif
	Endif
	CC0->(DbSkip())
Enddo

CC0->(DbGoTop())

oMarkBrw:Refresh()

Return

//-----------------------------------------------------------
/*/{Protheus.doc} Tmsaf92Whe
Define o when dos campos
@author Valdemar Roberto Mognon
@version P12
@Since 30/11/2022
@version 1.0
/*/
//-----------------------------------------------------------
Function Tmsaf92Whe(cCampo)
Local lRet       := .T.
Local oModel     := FwModelActive()
Local oMdlGrdDNF := oModel:GetModel("MdGridDNF")

Default cCampo := ReadVar()

If !oMdlGrdDNF:IsEmpty()
	lRet := .F.
EndIf

Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} Tmsaf92Act
Executa A��es na View
@author Valdemar Roberto Mognon
@version P12
@Since 01/12/2022
@version 1.0
/*/
//-----------------------------------------------------------
Function Tmsaf92Act(oView,cIDGrid,nLine,nAcao)
Local lRet      := .T.
Local oModel    := FwModelActive()
Local oMdGrdDNF := oModel:GetModel("MdGridDNF")
Local cNumMDF   := oMdGRdDNF:GetValue("DNF_NUMMDF",nLine)
Local cSerMDF   := oMdGrdDNF:GetValue("DNF_SERMDF",nLine)
Local nCntFor1

	If !Empty(cNumMDF)

		For nCntFor1 := 1 To oMdGrdDNF:Length()
			If oMdGrdDNF:GetValue("DNF_NUMMDF",nCntFor1) == cNumMDF .And. oMdGrdDNF:GetValue("DNF_SERMDF",nCntFor1) == cSerMDF
				If nCntFor1 != nLine
					oMdGrdDNF:GoLine(nCntFor1)
					If nAcao == 1 .And. !oMdGrdDNF:IsDeleted()    //-- Delete
						oMdGrdDNF:DeleteLine()
					ElseIf nAcao == 2 .And. oMdGrdDNF:IsDeleted() //-- Undelete
						oMdGrdDNF:UnDeleteLine()
					EndIf
				EndIf
			EndIf
		Next nCntFor1
		
		oMdGrdDNF:GoLine(nLine)
		oView:Refresh()

	EndIf

Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} Tmsaf92Pre
Pre valida a��es na linha
@author Valdemar Roberto Mognon
@version P12
@Since 01/12/2022
@version 1.0
/*/
//-----------------------------------------------------------
Function Tmsaf92Pre(oModel,nLine,cAction,cIDField,xValue,xCurrentValue)
Local lRet      := .T.
Local nCntFor1  := 0
Local nLinha    := 0

	If cAction == "DELETE"
		For nCntFor1 := 1 To oModel:Length()
			If oModel:SeekLine({{ "DNF_FILNFC", oModel:GetValue("DNF_FILNFC",nCntFor1) },;
								{ "DNF_DOC"   , oModel:GetValue("DNF_DOC"   ,nCntFor1) },;
								{ "DNF_SERIE" , oModel:GetValue("DNF_SERIE" ,nCntFor1) }})
				nLinha := oModel:GetLine()
				If oModel:IsDeleted(nLinha) .And. nLinha != nLine
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nCntFor1
	EndIf

	oModel:GoLine(nLine)

Return lRet

/*{Protheus.doc} TMSAF92Sup
Rotina de suporte que chama as fun��es da integra��o com coleta/entrega.
@author Carlos A. Gomes Jr.
@Since 06/12/2022
*/
Function TMSAF92Sup(nAcao,cProces,nEnvRet)
Local cTxtMsg := STR0021 //--"Enviando ao Motorista"

Default nAcao   := 0
DEFAULT cProces := DNE->(DNE_FILORI+DNE_VIAGEM)
Default nEnvRet := 0

	If nAcao == 6	//-- Grava��o da DN5
		FWMsgrun(,{|| TMSAF92His(cProces)}, STR0016, STR0017 ) //-- "Aguarde" //-- "Gerando Hist�rico de Integra��o"
	ElseIf nAcao == 7	//-- Envio ao Portal
		FWMsgrun(,{|| TMSAF92His(cProces,,.F.)}, STR0016, STR0017 ) //-- "Aguarde" //-- "Gerando Hist�rico de Integra��o"
		FWMsgrun(,{|| TMSAI86AUX(cProces)}, STR0018, STR0019 ) //-- "Job de Envio de Integra��o" //-- "Aguarde enquanto o Job � executado."
	ElseIf nAcao == 8	//-- Estorno
		FWMsgrun(,{|| TMSAF92His(cProces,2)}, STR0016, STR0020 ) //-- "Aguarde" //-- "Estornando Integra��o com Coleta/Entrega"
	ElseIf nAcao == 9	//-- Envio/Retirada do Motorista
		If nEnvRet == 1 .Or. nEnvRet == 2
			If nEnvRet != 1
				cTxtMsg := STR0022 //-- "Retirando do Motorista"
			EndIf
			FWMsgrun(,{|| OMSMotCoEn(nEnvRet,cProces)},STR0016, cTxtMsg ) //-- "Aguarde"
		EndIf
	EndIf

Return

/*{Protheus.doc} TMSAF92His
Rotina de gera��o da tabela hist�rico de integra��o
@author Carlos A. Gomes Jr.
@Since 06/12/2022
*/
Function TMSAF92His(cProces,nOpc,lHelp)

DEFAULT cProces := DNE->(DNE_FILORI+DNE_VIAGEM)
DEFAULT nOpc    := 1
DEFAULT lHelp   := .T.

	If nOpc == 1 //-- Inclus�o
		DNE->(DbSetOrder(1))
		If DNE->(MsSeek(xFilial("DNE")+cProces)) .And. DNE->DNE_STATUS == "1"
			Begin Transaction
			If TMC30GHist(cProces)
				RecLock("DNE",.F.)
				DNE->DNE_STATUS := "2"
				MsUnlock()
			EndIf
			End Transaction
		ElseIf lHelp
			Help("","","HELP",,STR0036,1,0) //-- "Hist�rico de viagem j� gravado. Para enviar novamente estorne a viagem, e o status deve estar em aberto."
		EndIf
	ElseIf nOpc == 2 //-- Estorno
		TM92EstHis(cProces)
	EndIf

Return

/*{Protheus.doc} TM92RetEnd
Rotina auxiliar para retornar os dados do destinatario da nota
@author Carlos A. Gomes Jr.
@Since 06/12/2022
*/
Static aVetEnd := {"",{},""}
Function TM92RetEnd(nTipo,cCodLoja)
Local cRet := ""
Local aAreas := {}

DEFAULT nTipo    := 0
DEFAULT cCodLoja := ""

	If !Empty(cCodLoja)
		aAreas := { SA1->(GetArea()), GetArea() }
		SA1->(DbSetOrder(1))
		SA1->(MsSeek(xFilial("SA1")+cCodLoja))
	EndIf

	If !SA1->(Eof())
		If aVetEnd[1] != SA1->(A1_COD+A1_LOJA)
			aVetEnd[1] := SA1->(A1_COD+A1_LOJA)
			aVetEnd[2] := FisGetEnd(AllTrim(SA1->A1_END))
			aVetEnd[3] := ""
			If SA1->A1_PESSOA == "J"
				If !Empty(SA1->A1_NREDUZ)
					aVetEnd[3] := '"nomeFantasia":"' + AllTrim(SA1->A1_NREDUZ) + '",'
				Else
					aVetEnd[3] := '"nomeFantasia":"' + AllTrim(SA1->A1_NOME) + '",'
				EndIf
			EndIf
		EndIf
		If nTipo == 0
			cRet := AllTrim(aVetEnd[2][1])+", "+AllTrim(aVetEnd[2][3])+" "+AllTrim(aVetEnd[2][4])+" - "+AllTrim(SA1->A1_BAIRRO)+", "+AllTrim(SA1->A1_MUN)+"-"+AllTrim(SA1->A1_EST)+", "+Left(SA1->A1_CEP,5)+"-"+Right(SA1->A1_CEP,3)+", "+AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR"))
		ElseIf nTipo == 5
			cRet := aVetEnd[3]
		Else
			cRet := AllTrim(aVetEnd[2][nTipo])
		EndIf
	EndIf

	If !Empty(cCodLoja)
		AEval( aAreas, {|X| RestArea(x) })
		FwFreeArray(aAreas)
	EndIf

Return cRet

/*{Protheus.doc} TM92RetSM0
Rotina auxiliar para retornar dados da empresa emissora da nota
@author Carlos A. Gomes Jr.
@Since 06/12/2022
*/
Static aSM0Data := {}
Function TM92RetSM0(nPos)
Local cRet     := ""
Local aFullSM0 := {}
Local aEndSep  := {}
Local cEndForm := ""
DEFAULT nPos := 1

	If Len(aSM0Data) == 0
		aFullSM0 := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{"M0_CGC","M0_NOMECOM","M0_NOME","M0_ENDENT","M0_COMPENT","M0_BAIRENT","M0_CIDENT","M0_ESTENT","M0_CEPENT","M0_TEL"})
		AAdd( aSM0Data, AllTrim( aFullSM0[1][2] ) )                              //1  CODIGO CGC
		AAdd( aSM0Data, AllTrim( aFullSM0[2][2] ) )                              //2  NOME
		AAdd( aSM0Data, AllTrim( aFullSM0[3][2] ) )                              //3  NOME FANTASIA
		If At(",",aFullSM0[4][2]) == 0
			aFullSM0[4][2] := AllTrim( aFullSM0[4][2] ) + ","
		EndIf
		aEndSep := FisGetEnd( AllTrim( aFullSM0[4][2] ) + " " + AllTrim( aFullSM0[5][2] ))
		AAdd( aSM0Data, AllTrim( aEndSep[1] ) )                                  //4  LOGRADOURO
		AAdd( aSM0Data, AllTrim( aEndSep[3] ) )                                  //5  NUMERO
		AAdd( aSM0Data, AllTrim( aEndSep[4] )  )                                 //6  Complemento
		AAdd( aSM0Data, AllTrim( aFullSM0[6][2] ) )                              //7  BAIRRO
		AAdd( aSM0Data, AllTrim( aFullSM0[7][2] ) )                              //8  MUNICIPIO
		AAdd( aSM0Data, AllTrim( aFullSM0[8][2] ) )                              //9  ESTADO
		AAdd( aSM0Data, Left(aFullSM0[9][2],5) + "-" + Right(aFullSM0[9][2],3) ) //10 CEP
		cEndForm := aSM0Data[4] + ", "+aSM0Data[5] + " " + aSM0Data[6] + " - " + aSM0Data[7] + ", " + aSM0Data[8] + " - " + aSM0Data[9] + ", " + aSM0Data[10] + ",BRASIL"
		AAdd( aSM0Data, cEndForm )                                               //11 END FORMATADO
		AAdd( aSM0Data, AllTrim( aFullSM0[10][2] ) )                             //12 TELEFONE
		FWFreeArray(aFullSM0)
		FWFreeArray(aEndSep)
	EndIf
	If Len(aSM0Data) >= nPos
		cRet := aSM0Data[nPos]
	EndIf

Return cRet

/*{Protheus.doc} TM92EstHis
Estorna os registros da tabela intermedi�ria de hist�rico que ainda n�o foram enviados � gest�o de entregas
@author Carlos A. Gomes Jr.
@Since	06/12/2022
*/
Static Function TM92EstHis(cProces)
Local aAreas     := {DNE->(GetArea()),DN4->(GetArea()),DN5->(GetArea()),DN1->(GetArea()),GetArea()}
Local aStruct    := {}
Local aStatusVia := {}
Local nRegPrinc  := 0
Local nRegistro  := 0
Local lOk        := .T.
Local lPrimeiro  := .T.
Local cAliasDN5  := ""
Local cQuery     := ""
Local oColEnt
Local aTarefas   := {}

Default cProces := DEN->(DNE_FILORI+DNE_VIAGEM)

	DNE->(DbSetOrder(1))
	If DNE->(MsSeek(xFilial("DNE")+cProces))
		If DNE->DNE_STATUS == "1"
			Help("","","HELP",,STR0037,1,0) //-- "Somente viagens fechadas podem ter o hist�rico estornado."

		ElseIf ( lOk := MsgYesNo( STR0023 + cProces ) ) //-- "Confirma Estorno do Envio da Viagem No. "
			oColEnt := TMSBCACOLENT():New("DN1")
			If oColEnt:DbGetToken()
				DN1->(DbGoTo(oColEnt:config_recno))
				//-- Inicializa a estrutura
				aStruct := TMSMntStru(DN1->DN1_CODFON,.T.)
				//-- Localiza primeiro registro da estrutura
				nRegPrinc := TMFirstReg(aStruct)
			
				If ExisteDN5(aStruct[nRegPrinc,1],aStruct[nRegPrinc,2],PadR(cProces,Len(DN5->DN5_PROCES)),{"1","2"},@nRegistro)
					DN5->(DbGoTo(nRegistro))
					If DN5->DN5_STATUS == "1" .Or. DN5->DN5_STATUS == "2"
						If DN5->DN5_STATUS == "1"
							If (aStatusVia := TMSAC30GDV(AllTrim(DN5->DN5_IDEXT),,.F.))[1]
								If aStatusVia[2] != "AGUARDANDO_DESPACHO"
									Help(" ", , STR0029, , STR0030 + aStatusVia[2], 2, 1) //-- "N�o � poss�vel estonar a viagem." //-- "Viagem j� manipulada no portal de Coleta/entrega com status diferente do esperado. Status atual: "
									lOk := .F.
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		If lOk
			If !Empty(DN5->DN5_IDEXT)
				aTarefas := TMSAC30GDV(AllTrim(DN5->DN5_IDEXT),,.T.)
			EndIf

			If Empty(DN5->DN5_IDEXT) .Or. (aTarefas[1] .And. TMSAC30ExA(AllTrim(DN5->DN5_IDEXT)))

				If !Empty(DN5->DN5_IDEXT)
					AEval(aTarefas[2],{|x| TMSAC30ExN(AllTrim(x[1])) })
				EndIf
				
				cAliasDN5 := GetNextAlias()
				cQuery := "SELECT DN5.DN5_CODFON DN5_CODFON, DN5.DN5_CODREG DN5_CODREG,DN5.R_E_C_N_O_ REGISTRO "
				cQuery += "FROM " + RetSqlName("DN5") + " DN5 "
				cQuery += "WHERE DN5.DN5_FILIAL = '" + xFilial("DN5") + "' "
				cQuery +=   "AND DN5.DN5_CODFON = '" + DN1->DN1_CODFON + "' "
				cQuery +=   "AND DN5.DN5_PROCES = '" + cProces + "' "
				cQuery +=   "AND DN5.DN5_STATUS IN('1','2') "
				cQuery +=   "AND DN5.D_E_L_E_T_ = ' ' "

				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDN5,.F.,.T.)

				DN4->(DbSetOrder(1))

				While (cAliasDN5)->(!Eof())
					//-- Estorna registro na DN5
					DN5->(DbGoTo((cAliasDN5)->REGISTRO))
					RecLock("DN5",.F.)
					DN5->DN5_STATUS := Iif(Empty(DN5->DN5_IDEXT),"6","5")	//-- Estornado Envio ou Estornado
					DN5->DN5_SITUAC := StrZero(3,Len(DN5->DN5_SITUAC))	//-- Estornado
					DN5->(MsUnLock())

					//-- Estorna registro na DN4
					DN4->(MsSeek(xFilial("DN4")+DN5->(DN5_CODFON+DN5_CODREG+DN5_CHAVE)))
					RecLock("DN4",.F.)
					DN4->DN4_IDEXT  := ""
					DN4->DN4_STATUS := '2'
					DN4->(MsUnLock())

					If lPrimeiro
						DNC->(DbSetOrder(1))
						If DNC->(DbSeek(xFilial("DNC") + DN5->(DN5_CODFON + DN5_PROCES)))
							Reclock("DNC",.F.)
							DNC->DNC_STATUS := DN5->DN5_STATUS	//-- Estornado Envio ou Estornado
							DNC->DNC_SITUAC := DN5->DN5_SITUAC	//-- Estornado
							DNC->DNC_DATULT := dDataBase
							DNC->DNC_HORULT := SubStr(Time(),1,2) + SubStr(Time(),4,2)
							DNC->(MsUnlock())
						EndIf
						lPrimeiro := .F.
					EndIf

					(cAliasDN5)->(DbSkip())
				EndDo

				(cAliasDN5)->(DbCloseArea())
				
				RecLock("DNE",.F.)
				DNE->DNE_STATUS := "1"
				MsUnlock()

			EndIf

		EndIf

		FWFreeObj( oColEnt )

		AEval( aAreas, {|x,y| RestArea(x), FwFreeArray(x) } )
		FWFreeArray( aAreas )
		FWFreeArray( aStruct )
		FWFreeArray( aStatusVia )
		FWFreeArray( aTarefas )

	EndIf

Return

/*{Protheus.doc} TM92SeekNF
Busca por nota fiscal em uma Viagem
@author Carlos A. Gomes Jr.
@Since	06/12/2022
*/
Function TM92SeekNF(cFilNf,cDocNF,cSerNF,cStatus,nTpBusca,cFilori,cViagem,lHelp)
Local lRet       := .F.
Local cAliasQry  := GetNextAlias()
Local cQuery     := ""
Local cCompTxt   := "="
Local nRecDNF    := 0
Local cDbAglut   := "+"
Local lIntViaFat := AliasInDic("DNE") .And. AliasInDic("DNF")
Local lIntNFFat  := AliasInDic("DNG")
Local aArea

DEFAULT cFilNf   := ""
DEFAULT cDocNF   := ""
DEFAULT cSerNF   := ""
DEFAULT cStatus  := ""
DEFAULT nTpBusca := 1
DEFAULT cFilori  := ""
DEFAULT cViagem  := ""
DEFAULT lHelp    := .T.

	If !Empty(cFilNf) .And. !Empty(cDocNF) .And. !Empty(cSerNF)
		If lIntViaFat
			aArea := GetArea()
			cQuery := "SELECT DNF.R_E_C_N_O_ DNFREC FROM " + RetSQLName("DNF") + " DNF "
			If !Empty(cStatus)
				cQuery += "INNER JOIN " + RetSQLName("DNE") + " DNE ON "
				cQuery += "DNE.DNE_FILIAL = '" + xFilial("DNE") + "' AND "
				cQuery += "DNE.DNE_FILORI = DNF.DNF_FILORI AND "
				cQuery += "DNE.DNE_VIAGEM = DNF.DNF_VIAGEM AND "
				cQuery += "DNE.DNE_STATUS = '" + cStatus + "' AND "
				cQuery += "DNE.D_E_L_E_T_ = ' ' "
			EndIf
			cQuery += "WHERE "
			cQuery += "DNF.DNF_FILIAL = '" + xFilial("DNF") + "' AND "
			cQuery += "DNF.DNF_FILNFC = '" + cFilNf + "' AND "
			cQuery += "DNF.DNF_DOC = '" + cDocNF + "' AND "
			cQuery += "DNF.DNF_SERIE = '" + cSerNF + "' AND "
			If !Empty(cViagem)
				If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		// Sinal de concatencao nesses ambientes
					cDbAglut := "||"
				Endif
				If nTpBusca == 2
					cCompTxt := "<>"
				EndIf
				cQuery += "DNF.DNF_FILORI " + cDbAglut + " DNF.DNF_VIAGEM " + cCompTxt + " '" + cFilori + cViagem + "' AND "
			EndIf
			cQuery += "DNF.D_E_L_E_T_ = ' ' "
			DbUseArea( .t., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQry, .f., .t. )
			If lRet := ( !(cAliasQry)->(Eof()) )
				nRecDNF := (cAliasQry)->DNFREC
			EndIf

			(cAliasQry)->(DbCloseArea())
			RestArea(aArea)
			FwFreeArray(aArea)

			If lRet
				DNF->(DbGoTo(nRecDNF))
			EndIf
			
			If lHelp
				If lRet .And. nTpBusca == 2
					Help(" ", , STR0024, , STR0025 + DNF->(DNF_FILORI + "/" + DNF_VIAGEM), 2, 1) //-- "Nota vinculada em outra viagem" //-- "Esta nota fiscal j� est� associada a viagem: "
				ElseIf lRet .And. nTpBusca == 1 .And. Empty(cViagem)
					Help(" ", , STR0031, , STR0025 + DNF->(DNF_FILORI + "/" + DNF_VIAGEM), 2, 1) //-- "Nota Fiscal vinculada em uma viagem" //-- "Esta nota fiscal j� est� associada a viagem: "
	//Habilitar esta parte quando for utilizado. Comentado para passar no rob�
	/*			Else !lRet .And. nTpBusca == 1 .And. !Empty(cViagem)
					Help(" ", , STR0024, , STR0026 + cFilori + "/" + cViagem, 2, 1) //-- "Nota vinculada em outra viagem" //-- "Esta nota fiscal n�o associada a viagem: "
	*/
				EndIf
			EndIf
		EndIf

		If !lRet .And. lIntNFFat
			aArea := GetArea()
			DNG->(DbSetOrder(1))
			If lRet := DNG->(MsSeek(xFilial("DNG",cFilNf)+cDocNF+cSerNF))
				If lHelp
					If lRet
						Help(" ", , STR0055, , STR0056, 2, 1) //-- "Nota Fiscal integrada no portal Coleta e Entrega." //-- "Esta Nota Fiscal est� cadastrada na integra��o de Notas sem Ve�culo do Portal Coleta e Entrega"
					EndIf
				EndIf
			EndIf
			RestArea(aArea)
			FwFreeArray(aArea)
		EndIf
		
	EndIf

Return lRet

/*{Protheus.doc} TM92SeekNF
Busca por nota fiscal em uma Viagem
@author Carlos A. Gomes Jr.
@Since	06/12/2022
*/
Function TM92VldInt(cCodMot,lHelp)
Local aAreas  := {}
Local lRet    := .F.
Local oColEnt

DEFAULT cCodMot := ""
DEFAULT lHelp   := .T.

If AliasInDic("DN1") .And. ExistFunc( "TMSAC30" )
	aAreas  := { DN1->(GetArea()), GetArea() }
	oColEnt := TMSBCACOLENT():New("DN1")
	If ( lRet := ( oColEnt:DbGetToken() .And. !Empty(oColEnt:filext) ) )
		DN1->(DbGoTo(oColEnt:config_recno))
		If !Empty(cCodMot) .And. ( lRet := ExistCpo("DA4",cCodMot) ) .And. Empty(BscIDMot( cCodMot, DN1->DN1_CODFON, ) )
			Help("","","HELP",,STR0038,1,0) //-- "Motorista sem ID relacionado ao Portal Coleta Entrega."
			lRet := .F.
		EndIf
	ElseIf lHelp
		Help("","","HELP",,STR0039,1,0) //-- "Verifique se a integra��o est� habilitada para este m�dulo e se h� uma filial relacionada para o Portal Coleta Entrega."
	EndIf
EndIf

Return lRet

/*{Protheus.doc} TMSAF92Pos
Fun��o de p�s valida��o do modelo
@author Carlos A. Gomes Jr.
@Since	06/12/2022
*/
Function TMSAF92Pos(oModel)
Local lRet := .T.
Local nOperation := oModel:GetOperation()

	If oModel:GetValue( 'MdFieldDNE', 'DNE_STATUS' ) == "2"
		If nOperation == MODEL_OPERATION_UPDATE
			Help("","","HELP",,STR0032,1,0) //-- 'Viagens fechadas n�o podem ser alteradas.'
			lRet := .F.
		ElseIf nOperation == MODEL_OPERATION_DELETE
			Help("","","HELP",,STR0033,1,0) //-- 'Viagens fechadas n�o podem ser excluidas.'
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*{Protheus.doc} TM92VldMrk
Fun��o de valida��o se as notas fiscais de um manifesto n�o est�o em outra viagem
@author Carlos A. Gomes Jr.
@Since	06/12/2022
*/
Function TM92VldMrk(cNumMDF,cSerMDF)
Local lRet      := .T.
Local cAliasQry := GetNextAlias()
Local aArea     := GetArea()
Local cQuery    := ""
Local oModel    := FwModelActive()
Local oModelDNE := oModel:GetModel("MdFieldDNE")
Local cChaveVia := oModelDNE:GetValue("DNE_FILORI") + oModelDNE:GetValue("DNE_VIAGEM")
Local cDbAglut  := "+"

DEFAULT cNumMDF := CC0->CC0_NUMMDF
DEFAULT cSerMDF := CC0->CC0_SERMDF

	cQuery := "SELECT DNF.DNF_FILORI, DNF.DNF_VIAGEM, DNF.DNF_FILNFC, DNF.DNF_DOC, DNF.DNF_SERIE FROM " + RetSQLName("DNF") + " DNF "
	cQuery += "INNER JOIN " + RetSQLName("DNE") + " DNE "
	cQuery +=      "ON DNE.DNE_FILIAL = '" + xFilial("DNE") + "' "
	cQuery +=     "AND DNE.DNE_FILORI = DNF.DNF_FILORI "
	cQuery +=     "AND DNE.DNE_VIAGEM = DNF.DNF_VIAGEM "
	cQuery +=     "AND DNE.DNE_STATUS = '1' "
	cQuery +=     "AND DNE.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSQLName("SF2") + " SF2 "
	cQuery +=      "ON SF2.F2_FILIAL = DNF.DNF_FILNFC "
	cQuery +=     "AND SF2.F2_DOC    = DNF.DNF_DOC "
	cQuery +=     "AND SF2.F2_SERIE  = DNF.DNF_SERIE "
	cQuery +=     "AND SF2.F2_NUMMDF = '" + cNumMDF + "' "
	cQuery +=     "AND SF2.F2_SERMDF = '" + cSerMDF + "' "
	cQuery +=     "AND SF2.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE "
	cQuery += "DNF.DNF_FILIAL = '" + xFilial("DNF") + "' AND "
	If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		// Sinal de concatencao nesses ambientes
		cDbAglut := "||"
	Endif
	cQuery += "DNF.DNF_FILORI " + cDbAglut + " DNF.DNF_VIAGEM <> '" + cChaveVia + "' AND "
	cQuery += "DNF.D_E_L_E_T_ = ' ' "

	DbUseArea( .t., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQry, .f., .t. )
	If !(lRet := (cAliasQry)->(Eof()) )
		(cAliasQry)->(Help(" ", , STR0024, , STR0027 + DNF_FILNFC + "-" + DNF_DOC + "/" + DNF_SERIE + STR0028 + DNF_FILORI + "/" + DNF_VIAGEM, 2, 1)) //-- "Nota vinculada em outra viagem." //-- " do manifesto j� est� associada a viagem: "
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
	FwFreeArray(aArea)

Return lRet

/*{Protheus.doc} TM92CndGat()
Fun��o de Condi��o de Execu��o de Gatilho
@author Carlos A. Gomes Jr.
@Since	16/12/2022
*/
FuncTion TM92CndGat()
Local cCampo := Upper(AllTrim(ReadVar()))
Local lRet   := .T.
Local oModel, oModelDNF

	If cCampo == "M->DNF_DOC" .Or. cCampo == "M->DNF_SERIE"
	    oModel    := FwModelActive()
		oModelDNF := oModel:GetModel("MdGridDNF")
		lRet := !Empty(oModelDNF:GetValue("DNF_DOC")) .And. !Empty(oModelDNF:GetValue("DNF_SERIE"))
	EndIf

Return lRet


/*{Protheus.doc} TMSAF92Cmt()
Fun��o de Commit de modelo para atualizar status da CC0
@author Carlos A. Gomes Jr.
@Since	16/12/2022
*/
Static Function TMSAF92Cmt( oModel )
Local aArea      := GetArea()
Local nOperation := oModel:GetOperation()
Local nLine      := 0
Local lRet       := .F.
Local oModelDNF

	Begin Transaction
	If lRet := FWFormCommit( oModel )
		oModelDNF := oModel:GetModel( 'MdGridDNF' )
		For nLine := 1 To oModelDNF:Length()
			oModelDNF:GoLine(nLine)
			If !Empty(oModelDNF:GetValue( 'DNF_SERMDF', nLine ))
				CC0->( dbSetOrder( 1 ) )
				If CC0->(MsSeek(oModelDNF:GetValue( 'DNF_FILNFC', nLine )+oModelDNF:GetValue( 'DNF_SERMDF', nLine )+oModelDNF:GetValue( 'DNF_NUMMDF', nLine )))
					RecLock("CC0",.F.)
					CC0->CC0_OK := ""
					If nOperation == MODEL_OPERATION_INSERT .Or. (nOperation == MODEL_OPERATION_UPDATE .And. !oModelDNF:IsDeleted())
						CC0->CC0_STAINT := "1"
					ElseIf nOperation == MODEL_OPERATION_DELETE .Or. (nOperation == MODEL_OPERATION_UPDATE .And. oModelDNF:IsDeleted())
						CC0->CC0_STAINT := "2"
					EndIf
					MsUnLock()
				EndIf
			EndIf
		Next
	EndIf
	End Transaction
	
	RestArea( aArea )

Return lRet

/*{Protheus.doc} TMSAF92Cmt()
Pesquisa notas fiscais da Filial (F3 no DNF_DOC)
@author Carlos Alberto Gomes Junior
@Since	20/01/2023
*/
Function TMSAF92Psq()
Local lRet      := .F.
Local cQuery    := ""
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local aHeadFat  := {STR0044,STR0045,STR0046,STR0047,STR0048,STR0049,STR0050,STR0051}
Local aItemFat  := {}
Local nPosPesq  := 0
Local oModel    := FwModelActive()
Local oModelDNF := oModel:GetModel("MdGridDNF")

	If !Empty(oModelDNF:GetValue("DNF_FILNFC"))
		cQuery += "SELECT SF2.F2_DOC, "
		cQuery +=        "SF2.F2_SERIE, "
		cQuery +=        "SF2.F2_EMISSAO, "
		cQuery +=        "SF2.F2_CLIENTE, "
		cQuery +=        "SF2.F2_LOJA, "
		cQuery +=        "SA1.A1_NOME "
		cQuery += "FROM " + RetSQLName("SF2") + " SF2 "
		cQuery += "INNER JOIN " + RetSQLName("SA1") + " SA1 "
		cQuery +=    "ON SA1.A1_COD = SF2.F2_CLIENTE "
		cQuery +=   "AND SA1.A1_LOJA = SF2.F2_LOJA "
		cQuery +=   "AND SA1.D_E_L_E_T_ = '' "
		cQuery += "WHERE  SF2.F2_FILIAL = '" + oModelDNF:GetValue("DNF_FILNFC") + "' "
		cQuery +=    "AND SF2.D_E_L_E_T_ = ''  "
		DbUseArea( .t., "TOPCONN", TcGenQry( ,,cQuery ), cAliasQry, .f., .t. )
	
		If !(cAliasQry)->(Eof())
			Do While !(cAliasQry)->(Eof())
				(cAliasQry)->(AAdd( aItemFat, { F2_DOC, F2_SERIE, StoD(F2_EMISSAO), F2_CLIENTE, F2_LOJA, A1_NOME } ))
				(cAliasQry)->(DbSkip())
			EndDo
			If ( ( nPosPesq := TmsF3Array( aHeadFat, aItemFat, STR0054, , , aHeadFat ) ) > 0 ) //-- "Selecione o Dcoumento para integrar."
				VAR_IXB := { aItemFat[nPosPesq][1], aItemFat[nPosPesq][2],aItemFat[nPosPesq][4],aItemFat[nPosPesq][5] }
				lRet := .T.
			EndIf
		Else
			Help("","","HELP",,STR0052,1,0) //-- "N�o foram encontrados documentos para esta filial."
		EndIf
		(cAliasQry)->(DbCloseArea())
		RestArea(aArea)
	Else
		Help("","","HELP",,STR0053,1,0) //-- "Escolha a filial antes."
	EndIf

	FWFreeArray(aHeadFat)
	FWFreeArray(aItemFat)
	FWFreeArray(aArea)

Return lRet
