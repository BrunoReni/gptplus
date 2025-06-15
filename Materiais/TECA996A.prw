#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA996A.CH"

Static lTemSalBs := .F.

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA996A
@description	Configurações de calculo
@sample	 		TECA996A()
@author			Kaique Schiller
@since			19/07/2022
/*/
//------------------------------------------------------------------------------
Function TECA996A()
Local oMBrowse := FWmBrowse():New()

oMBrowse:SetAlias("TCW")
oMBrowse:SetDescription(STR0001)	//"Configurações de Calculo"
oMBrowse:Activate()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@description	Define o menu funcional.
@sample	 		MenuDef()
@return			Opções da Rotina.
@author			Kaique Schiller
@since			19/07/2022
/*/

//------------------------------------------------------------------------------
Static Function MenuDef(aRotina)
Default	aRotina	:= {}

ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw" 		   OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TECA996A" OPERATION MODEL_OPERATION_VIEW ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TECA996A" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TECA996A" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TECA996A" OPERATION MODEL_OPERATION_DELETE ACCESS 0 // "Excluir"
ADD OPTION aRotina TITLE STR0007 ACTION "At996aCopy" OPERATION 9 ACCESS 0 // "Copiar"

Return(aRotina)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@description	Definição do Model
@sample	 		ModelDef()
@author			Kaique Schiller
@since			19/07/2022
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oStrTCW	:= FWFormStruct( 1, "TCW")
Local oStrTCX1 	:= FWFormStruct( 1, "TCX")
Local oStrTCX2 	:= FWFormStruct( 1, "TCX")
Local oStrTDZ 	:= FWFormStruct( 1, "TDZ")
Local oStrTEX1 	:= FWFormStruct( 1, "TEX")
Local oStrTEX2 	:= FWFormStruct( 1, "TEX")
Local oStrTXN 	:= Nil 
Local oStrTXO	:= Nil 
Local lTXNtbl   := TableInDic("TXN") .And. TXN->( ColumnPos('TXN_CODIGO') ) > 0
Local lTXOtbl   := TableInDic("TXO") .And. TXO->( ColumnPos('TXO_COD') ) > 0
Local lTEXFormPo:= TEX->( ColumnPos('TEX_FORMPO') ) > 0
Local oModel
Local xAux

If lTXNtbl
	oStrTXN := FWFormStruct( 1, "TXN")
Endif

If lTXOtbl
	oStrTXO := FWFormStruct( 1, "TXO")
Endif

xAux := FwStruTrigger( 'TCW_CODCCT', 'TCW_DSCCCT', 'Posicione("SWY",1,xFilial("SWY")+FwFldGet("TCW_CODCCT"),"WY_DESC")', .F. )
	oStrTCW:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TCX_TIPTBL', 'TCX_TABELA', 'At996aGtTb("1")', .F. )
	oStrTCX1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TCX_TIPTBL', 'TCX_TABELA', 'At996aGtTb("2")', .F. )
	oStrTCX2:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TCX_TIPTBL', 'TCX_CODTBL', '""', .F. )
	oStrTCX1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	oStrTCX2:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TCX_CODTBL', 'TCX_PORCEN', 'At996aGtPc("1")', .F. )
	oStrTCX1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TCX_CODTBL', 'TCX_PORCEN', 'At996aGtPc("2")', .F. )
	oStrTCX2:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TCX_TIPTBL', 'TCX_PORCEN', '', .F. )
	oStrTCX1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
	oStrTCX2:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TCX_PORCEN', 'TCX_PORALT', 'FwFldGet("TCX_PORCEN")', .F. )
	oStrTCX2:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TCX_PORCEN', 'TCX_PORALT', 'FwFldGet("TCX_PORCEN")', .F. )
	oStrTCX1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TCW_CODCCT', 'TCW_CODCCT', 'At996aGCCT()', .F. )
	oStrTCW:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TDZ_TIPBEN', 'TDZ_CODSLY', 'At996aTpBen(FwFldGet("TCW_CODCCT"),FwFldGet("TDZ_TIPBEN"))', .F. )
	oStrTDZ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TDZ_TIPBEN', 'TDZ_DESCRI', 'At996aDsc(FwFldGet("TDZ_CODSLY"),FwFldGet("TDZ_TIPBEN"),.T.)', .F. )
	oStrTDZ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TDZ_TIPBEN', 'TDZ_DSCBEN', 'At996aDcTp(FwFldGet("TDZ_TIPBEN"),.T.)', .F. )
	oStrTDZ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TDZ_TIPBEN', 'TDZ_VALOR', 'At996aVlrB(FwFldGet("TDZ_CODSLY"),FwFldGet("TDZ_TIPBEN"),.T.)', .F. )
	oStrTDZ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TDZ_VALOR', 'TDZ_VLRDIF', 'FwFldGet("TDZ_VALOR")', .F. )
	oStrTDZ:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

If lTXOtbl

	xAux := FwStruTrigger( 'TXO_BENEFI', 'TXO_DSBENE', 'FWGetSX5("AZ", FwFldGet("TXO_BENEFI"))[1,4]',.F.)
	oStrTXO:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TXO_VERBA', 'TXO_DSVERB', 'ALLTRIM(POSICIONE("SRV",1,xFilial("SRV")+FwFldGet("TXO_VERBA"),"RV_DESC"))', .F. )
	oStrTXO:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

	xAux := FwStruTrigger( 'TXO_VERBA', 'TXO_TPVERB', 'AT996TpVer(FwFldGet("TXO_VERBA"))', .F. )
	oStrTXO:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

Endif

oStrTCX1:SetProperty('TCX_CODTBL',MODEL_FIELD_VALID, {|oMdl|At996aVlBn(oMdl,FwFldGet("TCW_CODCCT") )})
oStrTCX1:SetProperty('TCX_PORALT',MODEL_FIELD_VALID, {|oMdl|At996aPrAt(oMdl)})

oStrTCX2:SetProperty('TCX_CODTBL',MODEL_FIELD_VALID, {|oMdl|At996aVlBn(oMdl,FwFldGet("TCW_CODCCT") )})
oStrTCX2:SetProperty('TCX_PORALT',MODEL_FIELD_VALID, {|oMdl|At996aPrAt(oMdl)})

oStrTDZ:SetProperty('TDZ_VLRDIF',MODEL_FIELD_VALID, {|oMdl|At996aPrAt(,FwFldGet("TDZ_VALOR"),FwFldGet("TDZ_VLRDIF"))})

oStrTCW:SetProperty('TCW_CUSTO',MODEL_FIELD_VALID, {|oMdl|At996aVlFr(oMdl,"TCW_CUSTO","TCW_NCKCUS")})
oStrTCW:SetProperty('TCW_FORLIQ',MODEL_FIELD_VALID,{|oMdl|At996aVlFr(oMdl,"TCW_FORLIQ","TCW_NICKLI")})
oStrTCW:SetProperty('TCW_FORBRT',MODEL_FIELD_VALID,{|oMdl|At996aVlFr(oMdl,"TCW_FORBRT","TCW_NICKBR")})

oStrTDZ:SetProperty('TDZ_FORMUL',MODEL_FIELD_VALID, {|oMdl|At996aVlFr(oMdl,"TDZ_FORMUL","TDZ_NICK")})

If lTEXFormPo
	oStrTEX1:SetProperty('TEX_FORMPO',MODEL_FIELD_VALID, {|oMdl|At996aVlFr(oMdl,"TEX_FORMPO","TEX_NICKPO")})
Endif

oStrTEX1:SetProperty('TEX_FORMUL',MODEL_FIELD_VALID, {|oMdl|At996aVlFr(oMdl,"TEX_FORMUL","TEX_NICK")})
If lTEXFormPo
	oStrTEX2:SetProperty('TEX_FORMPO',MODEL_FIELD_VALID, {|oMdl|At996aVlFr(oMdl,"TEX_FORMPO","TEX_NICKPO")})
Endif
oStrTEX2:SetProperty('TEX_FORMUL',MODEL_FIELD_VALID, {|oMdl|At996aVlFr(oMdl,"TEX_FORMUL","TEX_NICK")})

If lTXNtbl
	oStrTXN:SetProperty('TXN_FORMUL',MODEL_FIELD_VALID, {|oMdl|At996aVlFr(oMdl,"TXN_FORMUL","TXN_NICK")})
Endif

oStrTCX1:SetProperty('TCX_TIPOPE',MODEL_FIELD_INIT, {|| "1" } )
oStrTCX2:SetProperty('TCX_TIPOPE',MODEL_FIELD_INIT, {|| "2" } )

oStrTCW:SetProperty( "TCW_NCKCUS", MODEL_FIELD_WHEN, { || IsInCallStack("InitDados") } )
oStrTCW:SetProperty( "TCW_NICKLI", MODEL_FIELD_WHEN, { || IsInCallStack("InitDados") } )
oStrTCW:SetProperty( "TCW_NICKBR", MODEL_FIELD_WHEN, { || IsInCallStack("InitDados") } )

oStrTCX1:SetProperty( "TCX_CODTBL", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TCX_CODTBL',"1" ) } )
oStrTCX1:SetProperty( "TCX_PORCEN", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TCX_PORCEN',"1" ) } )

oStrTCX1:SetProperty( "TCX_DESCRI", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TCX_DESCRI',"1" ) } )
oStrTCX1:SetProperty( "TCX_TIPTBL", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TCX_TIPTBL',"1" ) } )
oStrTCX1:SetProperty( "TCX_PORALT", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TCX_PORALT',"1" ) } )
oStrTCX1:SetProperty( "TCX_NICKPO", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TCX_NICKPO',"1" ) } )

If TCX->( ColumnPos('TCX_OBRGT') ) > 0
	oStrTCX1:SetProperty( "TCX_OBRGT" , MODEL_FIELD_WHEN, { || AT996When( oModel, 'TCX_OBRGT' ,"1" ) } )
EndIf

oStrTCX2:SetProperty( "TCX_CODTBL", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TCX_CODTBL',"2" ) } )
oStrTCX2:SetProperty( "TCX_PORCEN", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TCX_PORCEN',"2" ) } )

oStrTDZ:SetProperty(  "TDZ_TIPBEN", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TDZ_TIPBEN' ) } )

oStrTCX1:SetProperty( "TCX_NICK", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TCX_NICK',"1" ) } )
oStrTCX2:SetProperty( "TCX_NICK", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TCX_NICK',"2" ) } )
oStrTDZ:SetProperty(  "TDZ_NICK", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TDZ_NICK' ) } )
oStrTEX1:SetProperty( "TEX_NICK", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TEX_NICK',"1" ) } )
oStrTEX2:SetProperty( "TEX_NICK", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TEX_NICK',"2" ) } )

oStrTEX2:SetProperty('TEX_TIPOTX' , MODEL_FIELD_INIT, {|| "2" } )
oStrTEX2:SetProperty( "TEX_TIPOTX", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TEX_TIPOTX',"2" ) } )
oStrTEX2:SetProperty( "TEX_VALOR" , MODEL_FIELD_WHEN, { || AT996When( oModel, 'TEX_VALOR',"2" ) } )

oStrTEX1:SetProperty( "TEX_TIPOTX", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TEX_TIPOTX',"1" ) } )
oStrTEX1:SetProperty( "TEX_VALOR" , MODEL_FIELD_WHEN, { || AT996When( oModel, 'TEX_VALOR' ,"1" ) } )

oStrTEX1:SetProperty( "TEX_DESCRI", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TEX_DESCRI',"1" ) } )

oStrTEX1:SetProperty( "TEX_NICKPO", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TEX_NICKPO',"1" ) } )
If lTEXFormPo
	oStrTEX1:SetProperty( "TEX_FORMPO", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TEX_FORMPO',"1" ) } )
Endif
oStrTEX2:SetProperty( "TEX_DESCRI", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TEX_DESCRI',"2" ) } )
oStrTEX2:SetProperty( "TEX_NICKPO", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TEX_NICKPO',"2" ) } )
If lTEXFormPo
	oStrTEX2:SetProperty( "TEX_FORMPO", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TEX_FORMPO',"2" ) } )
Endif
If lTXOtbl
	oStrTXO:SetProperty( "TXO_NICK"  , MODEL_FIELD_WHEN, { || AT996When( oModel, 'TXO_NICK'  ,"1" ) } )
	oStrTXO:SetProperty( "TXO_BENEFI", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TXO_BENEFI',"1" ) } )
	oStrTXO:SetProperty( "TXO_VERBA" , MODEL_FIELD_WHEN, { || AT996When( oModel, 'TXO_VERBA' ,"1" ) } )
	oStrTXO:SetProperty( "TXO_PORALT", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TXO_PORALT',"1" ) } )
	oStrTXO:SetProperty( "TXO_NICKPO", MODEL_FIELD_WHEN, { || AT996When( oModel, 'TXO_NICKPO',"1" ) } )
Endif
oModel := MPFormModel():New("TECA996A", /*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )
oModel:AddFields("TCWMASTER",/*cOwner*/,oStrTCW, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:SetDescription(STR0001) //"Configurações de calculo"

oModel:AddGrid("TCXDETAIL1","TCWMASTER",oStrTCX1,{|oMdl,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTCX1(oMdl, nLine, cAcao, cCampo, xValue, xOldValue) },{|oMdl, nLine| PosLinTCX1(oMdl,nLine)},,, )
oModel:SetRelation("TCXDETAIL1", {{"TCX_FILIAL","xFilial('TCX')"}, {"TCX_CODTCW","TCW_CODIGO"}, {"TCX_TIPOPE",'"1"'}}, TCX->(IndexKey(1)))

oModel:AddGrid("TCXDETAIL2","TCWMASTER",oStrTCX2,{|oMdl,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTCX2(oMdl, nLine, cAcao, cCampo, xValue, xOldValue) },{|oMdl, nLine| PosLinTCX2(oMdl,nLine)},,, )
oModel:SetRelation("TCXDETAIL2", {{"TCX_FILIAL","xFilial('TCX')"}, {"TCX_CODTCW","TCW_CODIGO"}, {"TCX_TIPOPE",'"2"'} }, TCX->(IndexKey(1)))

oModel:AddGrid("TDZDETAIL","TCWMASTER",oStrTDZ,{|oMdl,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTDZ(oMdl, nLine, cAcao, cCampo, xValue, xOldValue) },{|oMdl, nLine| PosLinTDZ(oMdl,nLine)},,,)
oModel:SetRelation("TDZDETAIL", {{"TDZ_FILIAL","xFilial('TDZ')"}, {"TDZ_CODTCW","TCW_CODIGO"}}, TDZ->(IndexKey(1)))

oModel:AddGrid("TEXDETAIL1","TCWMASTER",oStrTEX1,{|oMdl,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTEX1(oMdl, nLine, cAcao, cCampo, xValue, xOldValue) },/*{|oMdl, nLine| PosLinTCX1(oMdl,nLine)}*/,,, )
oModel:SetRelation("TEXDETAIL1", {{"TEX_FILIAL","xFilial('TEX')"}, {"TEX_CODTCW","TCW_CODIGO"}, {"TEX_TIPOPE",'"1"'}}, TEX->(IndexKey(1)))

oModel:AddGrid("TEXDETAIL2","TCWMASTER",oStrTEX2,{|oMdl,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTEX2(oMdl, nLine, cAcao, cCampo, xValue, xOldValue) },/*{|oMdl, nLine| PosLinTCX2(oMdl,nLine)}*/,,, )
oModel:SetRelation("TEXDETAIL2", {{"TEX_FILIAL","xFilial('TEX')"}, {"TEX_CODTCW","TCW_CODIGO"}, {"TEX_TIPOPE",'"2"'} }, TEX->(IndexKey(1)))

If lTXNtbl
	oModel:AddGrid("TXNDETAIL","TCWMASTER",oStrTXN,/*{|oMdl,nLine,cAcao,cCampo, xValue, xOldValue| PreLinTEX2(oMdl, nLine, cAcao, cCampo, xValue, xOldValue) }*/,/*{|oMdl, nLine| PosLinTCX2(oMdl,nLine)}*/,,, )
	oModel:SetRelation("TXNDETAIL", {{"TXN_FILIAL","xFilial('TXN')"}, {"TXN_CODTCW","TCW_CODIGO"}}, TXN->(IndexKey(1)))
Endif

If lTXOtbl
	oModel:AddGrid("TXODETAIL", "TCWMASTER", oStrTXO, /*bLinePre */,{|oMdl, nLine| PosLinTXO(oMdl,nLine)}, /*bPre */, /*bLinePost */, /*bLoad */)
	oModel:SetRelation("TXODETAIL", {{"TXO_FILIAL","xFilial('TXO')"}, {"TXO_CODTCW","TCW_CODIGO"}}, TXO->(IndexKey(1)))
Endif

//Campos que não serão repetidos 
oModel:GetModel('TCXDETAIL1'):SetUniqueLine({'TCX_NICK'})

oModel:GetModel("TCXDETAIL1"):SetFldNoCopy( { "TCX_CODIGO" } )
oModel:GetModel("TCXDETAIL2"):SetFldNoCopy( { "TCX_CODIGO" } )
oModel:GetModel("TDZDETAIL"):SetFldNoCopy(  { "TDZ_CODIGO" } )
oModel:GetModel("TEXDETAIL1"):SetFldNoCopy( { "TEX_CODIGO" } )
oModel:GetModel("TEXDETAIL2"):SetFldNoCopy( { "TEX_CODIGO" } )
If lTXNtbl
	oModel:GetModel("TXNDETAIL"):SetFldNoCopy(  { "TXN_CODIGO" } )
Endif
If lTXOtbl
	oModel:GetModel("TXODETAIL"):SetFldNoCopy(  { "TXO_COD" } )
Endif
oModel:GetModel('TCXDETAIL1'):SetOptional(.T.)
oModel:GetModel('TCXDETAIL2'):SetOptional(.T.)
oModel:GetModel('TDZDETAIL'):SetOptional(.T.)
oModel:GetModel('TEXDETAIL1'):SetOptional(.T.)
oModel:GetModel('TEXDETAIL2'):SetOptional(.T.)
If lTXNtbl
	oModel:GetModel('TXNDETAIL'):SetOptional(.T.)
Endif
If lTXOtbl
	oModel:GetModel('TXODETAIL'):SetOptional(.T.)
Endif
oModel:SetActivate( {|oModel| InitDados( oModel ) } )

Return(oModel)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@description	Definição da View
@sample	 		ViewDef()
@author			Kaique Schiller
@since			19/07/2022
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView  
Local oModel  := FWLoadModel("TECA996A")
Local oStrTCW := FWFormStruct( 2,"TCW")  
Local oStrTCX1:= FWFormStruct( 2,"TCX",{ | cCampo | !(AllTrim(cCampo) $ "TCX_CODIGO|TCX_CODTCW|TCX_TIPOPE") })
Local oStrTCX2:= FWFormStruct( 2,"TCX",{ | cCampo | !(AllTrim(cCampo) $ "TCX_CODIGO|TCX_CODTCW|TCX_TIPOPE") })
Local oStrTDZ := FWFormStruct( 2,"TDZ",{ | cCampo | !(AllTrim(cCampo) $ "TDZ_CODIGO|TDZ_CODTCW") })
Local oStrTEX := FWFormStruct( 2,"TEX",{ | cCampo | !(AllTrim(cCampo) $ "TEX_CODIGO|TEX_CODTCW|TEX_TIPOPE") })
Local oStrTXN := Nil 
Local oStrTXO := Nil
Local lTXNtbl := TableInDic("TXN") .And. TXN->( ColumnPos('TXN_CODIGO') ) > 0
Local lTXOtbl := TableInDic("TXO") .And. TXO->( ColumnPos('TXO_COD') ) > 0

If lTXNtbl
	oStrTXN := FWFormStruct( 2,"TXN",{ | cCampo | !(AllTrim(cCampo) $ "TXN_CODIGO|TXN_CODTCW") })
Endif

If lTXOtbl
	oStrTXO := FWFormStruct( 2,"TXO", { | cCampo | !(AllTrim(cCampo) $ "TXO_COD|TXO_CODTCW") })
Endif

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_TCW" ,oStrTCW, "TCWMASTER")
oView:AddGrid("VIEW_TCX1" ,oStrTCX1, "TCXDETAIL1")
oView:AddGrid("VIEW_TCX2" ,oStrTCX2, "TCXDETAIL2")
oView:AddGrid("VIEW_TDZ"  ,oStrTDZ, "TDZDETAIL")
oView:AddGrid("VIEW_TEX1" ,oStrTEX, "TEXDETAIL1")
oView:AddGrid("VIEW_TEX2" ,oStrTEX, "TEXDETAIL2")
If lTXNtbl
	oView:AddGrid("VIEW_TXN"  ,oStrTXN, "TXNDETAIL")
Endif
If lTXOtbl
	oView:AddGrid("VIEW_TXO" , oStrTXO, "TXODETAIL")
EndIf
oView:CreateHorizontalBox( "TOP"   , 30 )
oView:CreateHorizontalBox( "MIDDLE", 70 )

oView:CreateFolder( "ABAS", "MIDDLE")
oView:AddSheet("ABAS","ABA01", STR0008) // "Mão de Obra"
oView:CreateHorizontalBox( 'ID_ABA01' , 100,,, 'ABAS','ABA01' )

oView:AddSheet("ABAS","ABA02", STR0009) // "Encargos Sociais"
oView:CreateHorizontalBox( 'ID_ABA02' , 100,,, 'ABAS','ABA02' )

oView:AddSheet("ABAS","ABA03", STR0053) // "Benefícios"
oView:CreateHorizontalBox( 'ID_ABA03' , 100,,, 'ABAS','ABA03' )

oView:AddSheet("ABAS","ABA04", STR0054) // "Taxas"
oView:CreateHorizontalBox( 'ID_ABA04' , 100,,, 'ABAS','ABA04' )

oView:AddSheet("ABAS","ABA05", STR0055) // "Impostos"
oView:CreateHorizontalBox( 'ID_ABA05' , 100,,, 'ABAS','ABA05' )

oView:AddSheet("ABAS","ABA06", "Parâmetros") // "Parâmetros"
oView:CreateHorizontalBox( 'ID_ABA06' , 100,,, 'ABAS','ABA06' )

If lTXOtbl
	oView:AddSheet("ABAS","ABA07", STR0097) //"Verbas Adicionais"
	oView:CreateHorizontalBox( 'ID_ABA07' , 100,,, 'ABAS','ABA07' )
EndIf

oView:SetOwnerView("VIEW_TCW"	,"TOP")			// Cabeçalho
oView:SetOwnerView("VIEW_TCX1"	,"ID_ABA01")	// Grid de Mão de Obra
oView:SetOwnerView("VIEW_TCX2"	,"ID_ABA02")	// Grid de Encargos Sociais
oView:SetOwnerView("VIEW_TDZ"	,"ID_ABA03")	// Grid de Encargos Sociais
oView:SetOwnerView("VIEW_TEX1"	,"ID_ABA04")	// Grid de Taxas
oView:SetOwnerView("VIEW_TEX2"	,"ID_ABA05")	// Grid de Impostos
If lTXNtbl
	oView:SetOwnerView("VIEW_TXN"	,"ID_ABA06")	// Grid de Impostos
Endif
If lTXOtbl
	oView:SetOwnerView("VIEW_TXO" ,"ID_ABA07")	// Grid de Verbas Adicionais
Endif
oView:AddIncrementField('VIEW_TCX1' , 'TCX_ITEM' )
oView:AddIncrementField('VIEW_TCX2' , 'TCX_ITEM' )
oView:AddIncrementField('VIEW_TDZ'  , 'TDZ_ITEM' )

If lTXNtbl
	oView:AddIncrementField('VIEW_TXN'  , 'TXN_ITEM' )
Endif

If lTXOtbl
	oView:AddIncrementField('VIEW_TXO'  , 'TXO_ITEM' )
Endif

oView:AddIncrementField('VIEW_TEX1'  , 'TEX_ITEM' )
oView:AddIncrementField('VIEW_TEX2'  , 'TEX_ITEM' )

If TCX->( ColumnPos('TCX_OBRGT') ) > 0
	oStrTCX2:RemoveField('TCX_OBRGT')
EndIf

oStrTEX:SetProperty( "TEX_ITEM", MVC_VIEW_ORDEM, "01" )

oView:AddUserButton(STR0068,"",{|oModel| At996aVCCT(oModel)},,,) //"Carregar Verbas CCT"

Return(oView)

//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados
@description	Inicialização dos dados
@sample	 		InitDados()
@author			Kaique Schiller
@since			19/07/2022
/*/
//------------------------------------------------------------------------------
Static Function InitDados(oMdl)
Local nOperation := oMdl:GetOperation()
Local oMdlTCX1   := oMdl:GetModel("TCXDETAIL1")

If !IsInCallStack("At996aCopy") .And. nOperation == MODEL_OPERATION_INSERT
	FwMsgRun(Nil,{|| At996GerLn(oMdl)}, Nil, STR0010) //"Gerando registros..."
Else
	// Verifica se existe linha SALARIO BASE da Aba Mão de Obra.
	lTemSalBs := oMdlTCX1:SeekLine({{"TCX_ITEM","002"}}) .And. AllTrim(oMdlTCX1:GetValue("TCX_NICK")) == "SLBS"
Endif

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aCopy
@description	Executar opção de copiar
@sample	 		At996aCopy()
@author			flavio.vicco
@since			24/03/2023
/*/
//------------------------------------------------------------------------------
Function At996aCopy()

FWExecView(STR0007,"TECA996A",9,,/*{ || .T. }*/,,,/*aButtons*/ ) //"Copiar"

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aGtTb
@description	Gatilho do campo TCX_TIPTBL
@sample	 		At996aGtTb()
@author			Kaique Schiller
@since			19/07/2022
/*/
//------------------------------------------------------------------------------
Function At996aGtTb(cTip)
Local cRet := ""
Local oMdl := FwModelActive()

If cTip == "1" .And. oMdl:GetValue('TCXDETAIL1',"TCX_TIPTBL") == "1"
	cRet := "1"
Elseif cTip == "2" .And. oMdl:GetValue('TCXDETAIL2',"TCX_TIPTBL") == "1"
	cRet := "1"
Endif

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996GerLn
@description	Geração de linhas no grid TCX
@sample	 		At996GerLn()
@author			Kaique Schiller
@since			19/07/2022
/*/
//------------------------------------------------------------------------------
Static Function At996GerLn(oMdl)

Local oMdlTCW  := oMdl:GetModel("TCWMASTER")
Local oMdlTCX1 := oMdl:GetModel("TCXDETAIL1")
Local oMdlTCX2 := oMdl:GetModel("TCXDETAIL2")
Local oMdlTDZ  := oMdl:GetModel("TDZDETAIL")
Local oMdlTEX1 := oMdl:GetModel("TEXDETAIL1")
Local oMdlTEX2 := oMdl:GetModel("TEXDETAIL2")
Local oMdlTXN  := Nil
Local oMdlTXO  := Nil
Local nX	   := 0
Local aImpostos:= At996aImp()
Local aParam   := At996aPar()
Local cFormula := ""
Local lTXNtbl  := TableInDic("TXN") .And. TXN->( ColumnPos('TXN_CODIGO') ) > 0
Local lTXOtbl  := TableInDic("TXO") .And. TXO->( ColumnPos('TXO_COD') ) > 0

If lTXNtbl
	oMdlTXN := oMdl:GetModel("TXNDETAIL")
Endif

If lTXOtbl
	oMdlTXO := oMdl:GetModel("TXODETAIL")
Endif
//Inciando as formulas e nome de celulas de totais
oMdlTCW:SetValue("TCW_NCKCUS","TOTAL_CUSTO")
oMdlTCW:SetValue("TCW_CUSTO","TOTAL_MAO_DE_OBRA+TOTAL_ENCARGOS+TOTAL_BENEFICIOS+TOTAL_INSUMOS")

oMdlTCW:SetValue("TCW_NICKLI","TOTAL_LIQUIDO")
oMdlTCW:SetValue("TCW_FORLIQ","TOTAL_CUSTO+TOTAL_TAXAS")

oMdlTCW:SetValue("TCW_NICKBR","TOTAL_BRUTO")
oMdlTCW:SetValue("TCW_FORBRT","TOTAL_LIQUIDO+TOTAL_IMPOSTOS")

//Adiciona o total no primeiro registro no grid de mão de obra
oMdlTCX1:Goline(1)
oMdlTCX1:SetValue("TCX_DESCRI",STR0077) //"TOTAL DE MÃO DE OBRA"
oMdlTCX1:SetValue("TCX_TIPTBL","2")
oMdlTCX1:SetValue("TCX_NICK","TOTAL_MAO_DE_OBRA")

//Adiciona o Salario Base no segundo registro no grid de mão de obra
oMdlTCX1:AddLine()
oMdlTCX1:SetValue("TCX_DESCRI","SALARIO BASE")
oMdlTCX1:SetValue("TCX_TIPTBL","2")
oMdlTCX1:SetValue("TCX_NICK","SLBS")
lTemSalBs := .T.

//Adiciona o total no primeiro registro no grid de encargos sociais
oMdlTCX2:Goline(1)
oMdlTCX2:SetValue("TCX_DESCRI",STR0078) //"TOTAL DE ENCARGOS"
oMdlTCX2:SetValue("TCX_TIPTBL","2")
oMdlTCX2:SetValue("TCX_NICK","TOTAL_ENCARGOS")

//Adiciona o total no primeiro registro no grid de beneficios
oMdlTDZ:Goline(1)
oMdlTDZ:SetValue("TDZ_DESCRI",STR0079 ) //"TOTAL DE BENEFICIOS"
oMdlTDZ:SetValue("TDZ_NICK","TOTAL_BENEFICIOS")

//Adiciona o total no primeiro registro no grid de taxas
oMdlTEX1:Goline(1)
oMdlTEX1:SetValue("TEX_DESCRI",STR0080 ) //"TOTAL DE TAXAS"
oMdlTEX1:SetValue("TEX_NICK","TOTAL_TAXAS")

//Adiciona o total no primeiro registro no grid de impostos
oMdlTEX2:Goline(1)
oMdlTEX2:SetValue("TEX_DESCRI",STR0081 ) //"TOTAL DE IMPOSTOS"
oMdlTEX2:SetValue("TEX_NICK","TOTAL_IMPOSTOS")

For nX := 1 To Len(aImpostos)
	If !Empty(oMdlTEX2:GetValue("TEX_DESCRI"))
		oMdlTEX2:AddLine()
	Endif
	oMdlTEX2:SetValue("TEX_DESCRI",aImpostos[nX,1])
	If !Empty(aImpostos[nX,2])
		oMdlTEX2:SetValue("TEX_VALOR",aImpostos[nX,2])
	Endif
	oMdlTEX2:SetValue("TEX_NICK",aImpostos[nX,3])	
	If Empty(cFormula)
		cFormula += aImpostos[nX,3]
	Else
		cFormula += "+"+aImpostos[nX,3]
	Endif
Next nX

oMdlTEX2:Goline(1)
oMdlTEX2:SetValue("TEX_FORMUL",cFormula)
If lTXNtbl
	For nX := 1 To Len(aParam)
		If !Empty(oMdlTXN:GetValue("TXN_DESCRI"))
			oMdlTXN:AddLine()
		Endif
		oMdlTXN:SetValue("TXN_DESCRI",aParam[nX,1])
		oMdlTXN:SetValue("TXN_NICK"  ,aParam[nX,2])
	Next nX
	oMdlTXN:Goline(1)
ENdif

If lTXOtbl
	//Adiciona o total no primeiro registro no grid de Verbas Adicionais
	oMdlTXO:Goline(1)
	oMdlTXO:SetValue("TXO_DESCRI","TOTAL DE VERBAS ADICIONAIS" ) //"TOTAL DE VERBAS ADICIONAIS"
	oMdlTXO:SetValue("TXO_NICK","TOT_VERAD")//"TOTAL VERBAS ADICIONAIS"
Endif
Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT996When
@description	When dos campos da TCX
@sample	 		AT996When()
@author			Kaique Schiller
@since			19/07/2022
/*/
//------------------------------------------------------------------------------
Function AT996When( oMdl, cCampo, cTip )
Local oMdlTCW  := oMdl:GetModel("TCWMASTER")
Local oMdlTCX1 := oMdl:GetModel("TCXDETAIL1")
Local oMdlTCX2 := oMdl:GetModel("TCXDETAIL2")
Local oMdlTEX1 := oMdl:GetModel("TEXDETAIL1")
Local oMdlTEX2 := oMdl:GetModel("TEXDETAIL2")
Local oMdlTDZ  := oMdl:GetModel("TDZDETAIL")
Local oMdlTXO  := Nil
Local aImpostos:= {}
Local nPos 	   := 0
Local lRet 	   := .T.
Local lTXOtbl  := TableInDic("TXO") .And. TXO->( ColumnPos('TXO_COD') ) > 0

If lTXOtbl
	oMdlTXO := oMdl:GetModel("TXODETAIL")
EndIf

If !IsInCallStack("InitDados") .And. !IsInCallStack("At996aGrMa")
	If cCampo == "TCX_CODTBL"
		If !Empty(oMdlTCW:GetValue("TCW_CODCCT"))
			If cTip == "1" .And. oMdlTCX1:GetValue("TCX_TABELA") <> "1"
				lRet := .F.
			Elseif cTip == "2" .And. oMdlTCX2:GetValue("TCX_TABELA") <> "1"
				lRet := .F.
			Endif
		Else
			lRet := .F.
		EndIf
	Elseif cCampo $ "TCX_DESCRI|TCX_TIPTBL|TCX_TABELA|TCX_PORALT|TCX_NICKPO|TCX_NICK|TCX_OBRGT"
		If cCampo == "TCX_NICK"
 			If cTip == "1"
				If oMdlTCX1:GetLine() == 1
					lRet := .F.
				ElseIf oMdlTCX1:GetLine() == 2 .And. lTemSalBs
					lRet := .F.
				Endif
			Elseif cTip == "2"
				If oMdlTCX2:GetLine() == 1
					lRet := .F.
				Endif
			Endif
		Else
			If cTip == "1
				If oMdlTCX1:GetLine() == 2 .And. lTemSalBs
					lRet := .F.
				EndIf
			EndIf
		EndIf
	Elseif cCampo == "TCX_PORCEN"
		lRet := .F.
	Elseif cCampo == "TEX_VALOR" .Or. cCampo == "TEX_TIPOTX"
		If cTip == "1"
			If oMdlTEX1:GetLine() == 1
				lRet := .F.
			Endif
		Elseif cTip == "2"
			aImpostos := At996aImp()
			nPos := aScan(aImpostos,{|x| x[1] == "ISS" })
			If oMdlTEX2:GetLine() == 1 .Or. oMdlTEX2:GetLine() == nPos+1
				lRet := .F.
			Endif
		Endif
	Elseif cCampo $ "TDZ_NICK|TDZ_TIPBEN
		If oMdlTDZ:GetLine() == 1
			lRet := .F.
		Endif
	Elseif cCampo $ "TEX_NICK|TEX_DESCRI|TEX_NICKPO|TEX_FORMPO"
 		If cTip == "1"
			If cCampo == "TEX_FORMPO"
				If oMdlTEX1:GetLine() <> 1
					lRet := .F.
				Endif
			Else
				If oMdlTEX1:GetLine() == 1
					lRet := .F.
				Endif
			Endif
		Elseif cTip == "2"
			If cCampo == "TEX_FORMPO"
				If oMdlTEX2:GetLine() <> 1
					lRet := .F.
				Endif
			Else
				If oMdlTEX2:GetLine() == 1
					lRet := .F.
				Endif
			Endif
		Endif
	Elseif cCampo $ "TXO_NICK|TXO_BENEFI|TXO_VERBA|TXO_PORALT|TXO_NICKPO"
		If oMdlTXO:GetLine() == 1
			lRet := .F.
		Endif
	EndIf
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTCX1
@description	Função de Prevalidacao do grid Mão de Obra
@sample	 		PreLinTCX2()
@author			Natacha Romeiro
@since			27/07/22
/*/
//------------------------------------------------------------------------------
Function PreLinTCX1(oMdl,nLine,cAcao,cCampo, xValue, xOldValue)
Local lRet := .T.

If cAcao == "DELETE" .And. (oMdl:GetLine() == 1 .Or. (oMdl:GetLine() == 2 .And. lTemSalBs))
	Help(,, "PreLinTCX1",,STR0011 ,1,0,,,,,,{STR0012}) //"Não é possível excluir um item incluso pelo sistema."##"Realize a inclusão de outro item."
	lRet := .F.
Endif

If lRet .And. cAcao == "UNDELETE"
	If oMdl:GetValue("TCX_TABELA") == "1" .And. !Empty(oMdl:GetValue("TCX_CODTBL")) .And. !AtCdTabOk(oMdl:GetValue("TCX_CODTBL"),FwFldGet("TCW_CODCCT"))
		Help(,, "PreLinTCX1",,STR0049,1,0,,,,,,{STR0050}) //"Não é possível retirar a deleção desse item, o código da CCT não está vinculado a essa verba."##"Realize a inclusão de um novo item."
		lRet := .F.
	Endif
Endif

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTCX2
@description	Função de Prevalidacao do grid Encargos Sociais 
@sample	 		PreLinTCX2()
@author			Kaique Schiller
@since			19/07/2022
/*/
//------------------------------------------------------------------------------
Function PreLinTCX2(oMdl,nLine,cAcao,cCampo, xValue, xOldValue)
Local lRet := .T.

If cAcao == "DELETE" .And. oMdl:GetLine() == 1
	Help(,, "PreLinTCX2",,STR0011 ,1,0,,,,,,{STR0012}) //"Não é possível excluir um item incluso pelo sistema."##"Realize a inclusão de outro item."
	lRet := .F.
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTDZ
@description	Função de Prevalidacao do grid Beneficios
@sample	 		PreLinTDZ()
@author			flavio.vicco
@since			05/04/2023
/*/
//------------------------------------------------------------------------------
Function PreLinTDZ(oMdl,nLine,cAcao,cCampo, xValue, xOldValue)
Local lRet := .T.

If cAcao == "DELETE" .And. oMdl:GetLine() == 1
	Help(,, "PreLinTCX2",,STR0011 ,1,0,,,,,,{STR0012}) //"Não é possível excluir um item incluso pelo sistema."##"Realize a inclusão de outro item."
	lRet := .F.
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTEX1
@description	Função de Prevalidacao do grid Taxas
@sample	 		PreLinTEX1()
@author			flavio.vicco
@since			05/04/2023
/*/
//------------------------------------------------------------------------------
Function PreLinTEX1(oMdl,nLine,cAcao,cCampo, xValue, xOldValue)
Local lRet := .T.

If cAcao == "DELETE" .And. oMdl:GetLine() == 1
	Help(,, "PreLinTEX1",,STR0011 ,1,0,,,,,,{STR0012}) //"Não é possível excluir um item incluso pelo sistema."##"Realize a inclusão de outro item."
	lRet := .F.
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aFlCCT
	Filtro da consulta padrão TCX_CODTBL
@author		Kaique Schiller
@since		20/06/2022
/*/
//-------------------------------------------------------------------------------
Function At996aFlCCT()
Local cFiltro := "@#"
Local cCodCCT :=  FwFldGet("TCW_CODCCT")

cFiltro += '(REB->REB_FILIAL == "' + xFilial("REB")  +'" .And. REB->REB_CODCCT == "' + cCodCCT+ '" )'

Return cFiltro+"@#"

//------------------------------------------------------------------------------
/*/{Protheus.doc} AtCdTabOk
	Verifica a existencia do codigo CCT na tabela REB
@author	Natacha Romeiro
@since		25/07/2022
/*/
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/ 
Function AtCdTabOk(cCodSRV,cCodCCT)
Local lRet 		:= .T.
Local cAlias    := GetNextAlias()

BeginSql Alias cAlias
	SELECT 1		
	FROM  %table:REB% REB 
	WHERE REB.%NotDel%
		AND REB.REB_FILIAL = %xFilial:REB%
		AND REB.REB_CODSRV = %exp:cCodSRV%
		AND REB.REB_FILCCT = %xFilial:SWY%
		AND REB.REB_CODCCT = %exp:cCodCCT%
EndSql
	
lRet := (cAlias)->(!Eof())
(cAlias)->(DbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aGtPc
	Retorna mesmo valor do campo RV_PERC para o campo TCX_PORCEN 
@author		Kaique Schiller
@since		28/06/2022
/*/
//-------------------------------------------------------------------------------
Function At996aGtPc(cTip)
Local nRet := 0
Local oMdl := FwModelActive()
Local cCodTbl := ""

If cTip == "1" 
	cCodTbl := oMdl:GetValue('TCXDETAIL1',"TCX_CODTBL")	
Elseif cTip == "2"
	cCodTbl := oMdl:GetValue('TCXDETAIL2',"TCX_CODTBL")
Endif

If !Empty(cCodTbl)
	nRet := Posicione("SRV",1,xFilial("SRV")+cCodTbl,"RV_PERC")
Endif

Return nRet

// ------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At996aVlBn
	Envia parametros para função de consulta no banco 
@author		Kaique Schiller
@since		28/07/2022
/*/

// ------------------------------------------------------------------------------------------------
Function At996aVlBn(oMdl,cCodCCT)
Local lRet := .T.

If !IsInCallStack("InitDados") .And. !AtCdTabOk(oMdl:GetValue("TCX_CODTBL"),cCodCCT)
	lRet := .F.
Endif

Return lRet

// ------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At996aGCCT
	-Restaura os valores dos grids caso o usuário altere o código da CCT.
	-Impossibilita o "UNDELETE" da linha caso o usuário tenha alterado o código da CCT e 
	 o código da tabela não estiver vinculado ao novo código CCT selecionado.
@author		Jack Junior
@since		28/07/2022
/*/
// ------------------------------------------------------------------------------------------------
Function At996aGCCT()
Local lRet := .T. 
Local oMdl := FwModelActive()
Local oMdlTCX1 := oMdl:GetModel( 'TCXDETAIL1' )
Local oMdlTCX2 := oMdl:GetModel( 'TCXDETAIL2' )
Local nI := 0
Local aSaveRows := FwSaveRows()
Local oView := FwViewActive()
Local lRefresh := .F.

For nI := 1 To oMdlTCX1:Length()
    oMdlTCX1:GoLine( nI )
    If !(oMdlTCX1:IsDeleted()) .And. oMdlTCX1:GetValue('TCX_TABELA') == "1" //Validação se pode ou não restaurar a linha
        oMdlTCX1:SetValue('TCX_TIPTBL', '2' )
		lRefresh := .T.
    EndIf    
Next nI 

For nI := 1 To oMdlTCX2:Length()
    oMdlTCX2:GoLine( nI ) 
    If  !(oMdlTCX2:IsDeleted()) .And. oMdlTCX2:GetValue('TCX_TABELA') == "1" //Validação se pode ou não restaurar a linha
        oMdlTCX2:SetValue('TCX_TIPTBL', '2' ) 
		lRefresh := .T.
    EndIf
Next nI

If lRefresh
	FwRestRows( aSaveRows )
	oView:Refresh("VIEW_TCX1")
	oView:Refresh("VIEW_TCX2")
Endif

Return lRet

// ------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At996aMaOb
Array com as posições de Mão de Obra
@author		Kaique Schiller
@since		01/08/2022
/*/
// ------------------------------------------------------------------------------------------------
Static Function At996aMaOb(oMdl)
Local oMdlTCW := oMdl:GetModel("TCWMASTER")
Local cCodCCT := oMdlTCW:GetValue("TCW_CODCCT")
Local cAlias  := GetNextAlias()
Local aMaoObra := {}

BeginSql Alias cAlias
	SELECT REB.REB_CODSRV	
	FROM  %table:REB% REB 
	WHERE REB.%NotDel%
		AND REB.REB_FILIAL = %xFilial:REB%
		AND REB.REB_FILCCT = %xFilial:SWY%
		AND REB.REB_CODCCT = %exp:cCodCCT%
EndSql
	
While (cAlias)->(!Eof())
	aadd(aMaoObra,{(cAlias)->REB_CODSRV,Posicione("SRV",1,xFilial("SRV")+(cAlias)->REB_CODSRV,"RV_DESC")})//Verbas
	(cAlias)->(DbSkip())
EndDo

(cAlias)->(DbCloseArea())

Return aMaoObra

// ------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At996aEcrg
Array com as posições de Mão de Obra
@author		Kaique Schiller
@since		01/08/2022
/*/
// ------------------------------------------------------------------------------------------------
Static Function At996aEcrg()
Local aEncargos := {{STR0025,"S001",At996aCrTb("001","S001")},; //"Desc INSS"
				   {STR0026,"S001",At996aCrTb("002","S001")},; //"Ded. Base IR"
				   {STR0027,"S037",At996aCrTb("003","S037")},; //"F.G.T.S"
				   {STR0028,"S038",At996aCrTb("004","S038")},; //"Salário Educação"
				   {STR0029,"S038",At996aCrTb("005","S038")},; //"SESI"
				   {STR0047,"S038",At996aCrTb("006","S038")},; //"SESC"
				   {STR0030,"S038",At996aCrTb("007","S038")},; //"SENAI"
				   {STR0048,"S038",At996aCrTb("008","S038")},; //"SENAC"
				   {STR0031,"S038",At996aCrTb("009","S038")},; //"INCRA"				   
				   {STR0032,""},; //"Riscos de Acidente de Trabalho"			   
				   {STR0033,"S038",At996aCrTb("011","S038")},; //"SEBRAE"
				   {STR0034,""},; //"Férias"
				   {STR0035,""},; //"Faltas Abonadas"
				   {STR0036,""},; //"Licença Paternidade"
				   {STR0037,""},; //"Faltas Legais"
				   {STR0038,""},; //"Acidente de trabalho"
				   {STR0039,""},; //"Aviso Previo Trabalhado"
				   {STR0040,""},; //"Adicional 1/3 Férias"
				   {STR0041,""},;//"13º Salário"										   
				   {STR0042,""},; //"Aviso Previo Inden. + 13º, Fériase 1/3 Const."									   
				   {STR0043,""},; //"FGTS Sobre Aviso Previo + 13º Inden."		 									   
				   {STR0044,""},; //"Inden. Compensa. Por Demissão S/Justa Causa"									   
				   {STR0045,""},; //"Aprovisionam. Feérias S/Licen. Maternidade"											   
				   {STR0046,""}} //"Aprovisionam. 1/3 Const. Férias S/Licen. Mat"

Return aEncargos

// ------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinTCX1
Realiza a validação do poslinha do grid de Mão de Obra
@author		Kaique Schiller
@since		01/08/2022
/*/
// ------------------------------------------------------------------------------------------------
Function PosLinTCX1(oMdl,nLine)
Local lRet := .T.

If oMdl:GetValue("TCX_TABELA") == "1" .And. Empty(oMdl:GetValue("TCX_CODTBL")) 
	Help(,, "PosLinTCX1",,STR0051,1,0,,,,,,{STR0052}) //"O campo Cod. Tabela é obrigatório com o tipo 1 de tabela selecionado."##"Realize o preenchimento do campo Cod. Tabela."
	lRet := .F.
Endif

Return lRet

// ------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinTCX2
Realiza a validação do poslinha do grid de Encargos Sociais
@author		Kaique Schiller
@since		01/08/2022
/*/
// ------------------------------------------------------------------------------------------------
Function PosLinTCX2(oMdl,nLine)
Local lRet := .T.

If oMdl:GetValue("TCX_TABELA") == "1" .And. Empty(oMdl:GetValue("TCX_CODTBL"))
	Help(,, "PosLinTCX2",,STR0051,1,0,,,,,,{STR0052}) //"O campo Cod. Tabela é obrigatório com o tipo 1 de tabela selecionado."##"Realize o preenchimento do campo Cod. Tabela."
	lRet := .F.
Endif

Return lRet

// ------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinTDZ
Realiza a validação do poslinha do grid de Benefícios
@author		Kaique Schiller
@since		01/08/2022
/*/
// ------------------------------------------------------------------------------------------------
Function PosLinTDZ(oMdl,nLine)
Local lRet := .T.

If oMdl:GetLine() > 1
	If Empty(oMdl:GetValue("TDZ_CODSLY")) 
		Help(,, "PosLinTDZ",,STR0056,1,0,,,,,,{STR0057}) //"O campo Cod. Benefic. é obrigatório."##"Realize o preenchimento do campo Cod. Benefic."
		lRet := .F.
	Endif

	If lRet .And. Empty(At996aDsc(oMdl:GetValue("TDZ_CODSLY"),oMdl:GetValue("TDZ_TIPBEN"),.T.))
		Help(,, "PosLinTDZ",,STR0058,1,0,,,,,,{STR0059}) //"Não existe esse Cod de Beneficio vinculado a esse Tipo de Beneficio."##"Utilize a consulta F3 para selecionar o registro corretamente."
		lRet := .F.
	Endif
Endif

Return lRet

// ------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinTXO
Realiza a validação do poslinha do grid de Verbas Adicionais
@author		Jack Junior
@since		31/05/2023
/*/
// ------------------------------------------------------------------------------------------------
Function PosLinTXO(oMdl,nLine)
Local lRet := .T.

If oMdl:GetLine() > 1
	If Empty(oMdl:GetValue("TXO_BENEFI")) 
		Help(,, "PosLinTXO",,STR0056,1,0,,,,,,{STR0057}) //"O campo Cod. Benefic. é obrigatório."##"Realize o preenchimento do campo Cod. Benefic."
		lRet := .F.
	Endif

	If lRet .And. Empty(oMdl:GetValue("TXO_VERBA"))
		Help(,, "PosLinTXO",,STR0098,1,0,,,,,,{STR0099}) //"O campo Verba de Pgto. é obrigatório."##"Realize o preenchimento do campo Verba de Pgto"
		lRet := .F.
	Endif

	If lRet .And. Empty(oMdl:GetValue("TXO_DESCRI"))
		Help(,, "PosLinTXO",,STR0100,1,0,,,,,,{STR0101}) //"O campo descrição da planilha é obrigatório."##"Realize o preenchimento do campo descrição da planilha"
		lRet := .F.
	Endif

	If lRet .And. Empty(oMdl:GetValue("TXO_NICKPO"))
		Help(,, "PosLinTXO",,STR0102,1,0,,,,,,{STR0103}) //"O campo de Nome do valor é obrigatório."##"Realize o preenchimento do campo Nome do valor."
		lRet := .F.
	Endif

	If lRet .And. Empty(oMdl:GetValue("TXO_NICK"))
		Help(,, "PosLinTXO",,STR0104,1,0,,,,,,{STR0105}) //"O campo de Nome da celula é obrigatório."##"Realize o preenchimento do campo Nome da celula."
		lRet := .F.
	Endif

	If lRet .And. Empty(oMdl:GetValue("TXO_FORMUL"))
		Help(,, "PosLinTXO",,STR0106,1,0,,,,,,{STR0107}) //"O campo de Fórmula é obrigatório."##"Realize o preenchimento do campo Fórmula."
		lRet := .F.
	Endif
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aFlBn
	Filtro da consulta padrão TDZ_TIPBEN
@author		Kaique Schiller
@since		20/06/2022
/*/
//-------------------------------------------------------------------------------
Function At996aFlBn()
Local cFiltro := "@#"
Local cTabela := "SWY"
Local cCodCCT :=  FwFldGet("TCW_CODCCT")

cFiltro += '(SLY->LY_FILIAL == "' + xFilial("SLY")  +'" .And. SLY->LY_ALIAS == "' +cTabela+ '" .And. SLY->LY_CHVENT == "' +cCodCCT+ '" )'

Return cFiltro+"@#"

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aDsc
	Descrição do beneficio.
@author		Kaique Schiller
@since		09/08/2022
/*/
//-------------------------------------------------------------------------------
Function At996aDsc(cChave,cTipoBen,lInic)
Local cRet 		:= ""
Local aArea 	:= {}
Default cChave	:= ""
Default cTipoBen := ""
Default lInic    := .F.

If !lInic
	cChave	:= Alltrim(SLY->LY_CODIGO)
	cTipoBen := Alltrim(SLY->LY_TIPO)
Endif

If !Empty(cChave)
	aArea := GetArea()
	cChave := AllTrim(cChave)
	If cTipoBen == "VR"
		//1=Vale Refeicao;2=Vale Alimentacao
		cRet  := Fdesc("RFO", "1"+cChave, "RFO_DESCR")
	ElseIf cTipoBen == "VA"
		//1=Vale Refeicao;2=Vale Alimentacao
		cRet  := Fdesc("RFO", "2"+cChave, "RFO_DESCR")
	ElseIf cTipoBen == "PS"
		cRet  := Fdesc("SG0", cChave, "G0_DESCR")
	Else
		cRet  := Fdesc("RIS", cTipoBen+cChave, "RIS_DESC")
	EndIf
	RestArea(aArea)
EndIf

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aDcTp
	Descrição do tipo de beneficio.
@author		Kaique Schiller
@since		09/08/2022
/*/
//-------------------------------------------------------------------------------
Function At996aDcTp(cChave,lInic)
Local aArea 	:= {}
Local aRet		:= {}
Local nPos		:= 0
Local cRet		:= "" 
Default cChave 	:= ""
Default lInic 	:= .F.

If !lInic
	cChave := Alltrim(SLY->LY_TIPO)
Endif

If !Empty(cChave)
	aArea:= GetArea()
	aRet := At996aCrg()
	nPos := ascan(aRet,{|x| x[2][1] == cChave})
	RestArea(aArea)
Endif
	
If nPos > 0
	cRet := aRet[nPos][2][2]
Endif

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aTpBen
	Retorna Tipo do Beneficio
@author		flavio.vicco
@since		17/05/2023
/*/
//-------------------------------------------------------------------------------
Function At996aTpBen(cCodCCT, cTipBen)
Local cRet    := "" 
Local cAlias  := GetNextAlias()

BeginSql Alias cAlias
	SELECT SLY.LY_CODIGO
	FROM  %table:SLY% SLY 
	WHERE SLY.%NotDel%
		AND SLY.LY_FILIAL = %xFilial:SLY%
		AND SLY.LY_FILENT = %xFilial:SWY%
		AND SLY.LY_ALIAS = "SWY"
		AND SLY.LY_CHVENT = %exp:cCodCCT%
		AND SLY.LY_TIPO =  %exp:cTipBen%
EndSql

If (cAlias)->(!Eof())
	cRet := (cAlias)->LY_CODIGO
EndIf

(cAlias)->(DbCloseArea())

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aCrg
	Carrega as informações dos tipos de beneficio.
@author		Kaique Schiller
@since		09/08/2022
/*/
//-------------------------------------------------------------------------------
Static Function At996aCrg()
Local aRet 	:= {}
Local aBen 	:= {}
Local nI	:= 1
Local aTb11	:= {}

aadd(aBen,{"VR",STR0060})//"Vale Refeição"
aadd(aBen,{"VA",STR0061})//"Vale Alimentação"
aadd(aBen,{"PS",STR0062})//"Plano de Saude"

For nI := 1 To Len(aBen)
	aadd(aRet,{1,1})
	aRet[nI][1]	:= 1
	aRet[nI][2]	:= {aBen[nI][1],aBen[nI][2]}
Next nI

fCarrTab(@aTb11,"S011" )
fVerVinc(@aTb11)

For nI := 1 To Len(aTb11)
	aadd(aRet,{1,1})
	aRet[len(aRet)][1]	:= 1
	aRet[len(aRet)][2]	:= {aTb11[nI][5],aTb11[nI][6]}
Next nI

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aVlrB
	Valor do beneficio.
@author		Kaique Schiller
@since		09/08/2022
/*/
//-------------------------------------------------------------------------------
Function At996aVlrB(cChave,cTipoBen,lInic)
Local nRet  := 0
Local aArea := {}

Default cChave   := ""
Default cTipoBen := ""
Default lInic    := .F.

If !lInic
	cChave	:= Alltrim(SLY->LY_CODIGO)
	cTipoBen := Alltrim(SLY->LY_TIPO)
Endif

If !Empty(cChave)
	aArea := GetArea()
	If cTipoBen == "VR"
		//1=Vale Refeicao                                                                                              
		nRet := Posicione("RFO",1,xFilial("RFO")+"1"+cChave,"RFO_VALOR")
	ElseIf cTipoBen == "VA"
		//1=Vale Refeicao                   
		nRet :=  Posicione("RFO",1,xFilial("RFO")+"2"+cChave,"RFO_VALOR")
	EndIf
	RestArea(aArea)
EndIf

Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aImp
	array da aba de Impostos
@author		Kaique Schiller
@since		07/10/2022
/*/
//-------------------------------------------------------------------------------
Static Function At996aImp()
Local aImpost := { 	{STR0063,1.65,"VALOR_PIS"},; //"PIS"
					{STR0064,7.60,"VALOR_COFINS"},; //"COFINS"
					{STR0065,1,"VALOR_CSLL"},; //"CSLL"
					{STR0066,1,"VALOR_IR"},; //"IR"
					{STR0067,0,"VALOR_ISS"} } //"ISS"

Return aImpost

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTEX2
@description	Função de Prevalidacao do grid Impostos
@sample	 		PreLinTCX2()
@author			Kaique Schiller
@since			07/10/2022
/*/
//------------------------------------------------------------------------------
Function PreLinTEX2(oMdl,nLine,cAcao,cCampo, xValue, xOldValue)
Local lRet := .T.
Local nLinhas := Len(At996aImp())

If cAcao == "DELETE" .And. oMdl:GetLine() <= nLinhas+1
	Help(,, "PreLinTEX2",,STR0011 ,1,0,,,,,,{STR0012}) //"Não é possível excluir um item incluso pelo sistema."##"Realize a inclusão de outro item."
	lRet := .F.
Endif

If !IsInCallStack("InitDados") .And. lRet .And. cAcao == "SETVALUE" .And. oMdl:GetLine() <= nLinhas 
	If cCampo == "TEX_DESCRI"
		Help(,, "PreLinTEX2",,STR0013,1,0,,,,,,{STR0012}) //"Não é possível alterar a descrição de um item incluso pelo sistema."##"Realize a inclusão de outro item."
		lRet := .F.
	Endif
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aVCCT
@description	Gerar linhas na mão de obra conforme as verbas da CCT
@sample	 		At996aVCCT()
@author			Kaique Schiller
@since			07/10/2022
/*/
//------------------------------------------------------------------------------
Function At996aVCCT(oMdl)
Local nOperation := oMdl:GetOperation()
Local oMdlTCW := oMdl:GetModel("TCWMASTER")
Local oMdlTCX1 := oMdl:GetModel("TCXDETAIL1")
Local lOk := .T.

If !Empty(oMdlTCW:GetValue("TCW_CODCCT"))
	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE 
		If oMdlTCX1:Length() > 0
			lOk := MsgYesNo(STR0069, STR0070)//"Ao realizar o carregamento das vernas da CCT o sistema sobrescreverá as linhas abaixo, gostaria de continuar?"##"Aviso importante"
		Endif
		If lOk
			FwMsgRun(Nil,{|| At996aGrMa(oMdl),At996aGrBn(oMdl),At996aGrPr(oMdl) }, Nil, STR0010)
		Endif
	Else
		Help(,, "At996aVCCT",,STR0071 ,1,0,,,,,,{STR0072}) //"Não é possível executar essa rotina nesse modo."##"Entre em incluir ou alterar."
	Endif
Else
	Help(,, "At996aVCCT",,STR0073 ,1,0,,,,,,{STR0074}) //"O campo do código da CCT está em branco."  ##"Preencha o campo."  
Endif

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aGrMa
@description	Gerar linhas na mão de obra
@sample	 		PreLinTCX2()
@author			Kaique Schiller
@since			07/10/2022
/*/
//------------------------------------------------------------------------------
Static Function At996aGrMa(oMdl)
Local aMaoObra  := At996aMaOb(oMdl)
Local oMdlTCX1 := oMdl:GetModel("TCXDETAIL1")
Local nX := 0
Local lRet := .T.

For nX := 1 To oMdlTCX1:Length()
    oMdlTCX1:GoLine(nX)
	If nX > 1 .And. !(nX == 2 .And. lTemSalBs)
		If !Empty(oMdlTCX1:GetValue("TCX_DESCRI"))
			lRet := lRet .And. oMdlTCX1:DeleteLine()
		Endif
	Endif
Next nX

If lRet
	For nX := 1 To Len(aMaoObra)
		If !Empty(oMdlTCX1:GetValue("TCX_DESCRI"))
			lRet := lRet .And. oMdlTCX1:AddLine()
		Endif
		lRet := lRet .And. oMdlTCX1:SetValue("TCX_TIPTBL","1")
		lRet := lRet .And. oMdlTCX1:SetValue("TCX_CODTBL",aMaoObra[nX,1])
		lRet := lRet .And. oMdlTCX1:SetValue("TCX_DESCRI",aMaoObra[nX,2])
	Next nX
Endif

oMdlTCX1:GoLine(1)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aGrBn
@description	Gerar linhas nos beneficios
@sample	 		PreLinTCX2()
@author			Kaique Schiller
@since			07/10/2022
/*/
//------------------------------------------------------------------------------
Static Function At996aGrBn(oMdl)
Local aBenefs  := At996aBnf(oMdl)
Local oMdlTDZ := oMdl:GetModel("TDZDETAIL")
Local nX := 0
Local lRet := .T.

For nX := 1 To oMdlTDZ:Length()
    oMdlTDZ:GoLine(nX)
	If nX > 1
		If !Empty(oMdlTDZ:GetValue("TDZ_TIPBEN"))
			lRet := lRet .And. oMdlTDZ:DeleteLine()
		Endif
	Endif
Next nX

If lRet
	For nX := 1 To Len(aBenefs)
		lRet := lRet .And. oMdlTDZ:AddLine()
		lRet := lRet .And. oMdlTDZ:SetValue("TDZ_TIPBEN",aBenefs[nX,1])
		lRet := lRet .And. oMdlTDZ:SetValue("TDZ_DESCRI",aBenefs[nX,2])
		lRet := lRet .And. oMdlTDZ:SetValue("TDZ_CODSLY",aBenefs[nX,3])
		lRet := lRet .And. oMdlTDZ:SetValue("TDZ_DSCBEN",aBenefs[nX,4])
		lRet := lRet .And. oMdlTDZ:SetValue("TDZ_VALOR" ,aBenefs[nX,5])
	Next nX
Endif

oMdlTDZ:GoLine(1)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aPrAt
@description	Validação da porcentagem alterada 
@sample	 		At996aPrAt()
@author			Kaique Schiller
@since			07/10/2022
/*/
//------------------------------------------------------------------------------
Static Function At996aPrAt(oMdl,nPerc,nPercAlt)
Local lRet := .T.
Default nPerc := 0
Default nPercAlt := 0
Default oMdl := Nil

If ValType(oMdl) == "O"
	nPerc := oMdl:GetValue("TCX_PORCEN") 
	nPercAlt := oMdl:GetValue("TCX_PORALT")
Endif

If nPercAlt <> 0 .And. nPerc <> 0
	If nPercAlt < nPerc
		Help(,, "At996aPrAlt",,STR0075 ,1,0,,,,,,{STR0076}) //"Não é permitido alerar a porcentagem."##"A porcentagem alterada tem que ser maior ou igual a porcentagem original." 
		lRet := .F.
	Endif
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aCrTb
@description	Carrega as informações das tabelas do RH
@sample	 		At996aCrTb()
@author			Kaique Schiller
@since			07/10/2022
/*/
//------------------------------------------------------------------------------
Static Function At996aCrTb(cItem,cCodTBL)
Local nPorcent := 0 
Local aTblVerb := {}
Local nTam1    := 0
Local nTam2    := 0
Default cItem := ""
Default cCodTBL := ""

fCarrTab(@aTblVerb,cCodTBL,dDataBase,.T.)
nTam1 := Len(aTblVerb) // Verifica se retornou vazio
If nTam1 > 0
	nTam2 := Len(aTblVerb[nTam1]) // Verifica total de itens retornados
	If cCodTBL == "S001"
		If cItem == "001" .And. nTam2 >= 8 //Desc INSS
			nPorcent := aTblVerb[nTam1,8]
		Elseif cItem == "002" .And. nTam2 >= 9 //Ded. Base IR
			nPorcent := aTblVerb[nTam1,9]
		Endif
	Elseif cCodTBL == "S037" .And. nTam2 >= 9 //F.G.T.S
		nPorcent := aTblVerb[nTam1,9]
	Elseif  cCodTBL == "S038"
		If cItem == "004" .And. nTam2 >=  7 //Salario Educação
			nPorcent := aTblVerb[nTam1,7]
		Elseif cItem == "005" .And. nTam2 >= 10 //SESI
			nPorcent := aTblVerb[nTam1,10]
		Elseif cItem == "006" .And. nTam2 >= 12 //SESC
			nPorcent := aTblVerb[nTam1,12]
		Elseif cItem == "007" .And. nTam2 >=  9 //SENAI
			nPorcent := aTblVerb[nTam1,9]
		Elseif cItem == "008" .And. nTam2 >= 11 //SENAC
			nPorcent := aTblVerb[nTam1,11]
		Elseif cItem == "009" .And. nTam2 >=  8 //INCRA
			nPorcent := aTblVerb[nTam1,8]
		Elseif cItem == "011" .And. nTam2 >= 13 //SEBRAE
			nPorcent := aTblVerb[nTam1,13]
		Endif
	Endif
Endif

Return nPorcent 

// ------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At996aBnf
Array com as posições de Beneficios atrelados a CCT
@author		Kaique Schiller
@since		01/08/2022
/*/
// ------------------------------------------------------------------------------------------------
Static Function At996aBnf(oMdl)
Local oMdlTCW := oMdl:GetModel("TCWMASTER")
Local cCodCCT := oMdlTCW:GetValue("TCW_CODCCT")
Local cAlias  := GetNextAlias()
Local aBenefs := {}

BeginSql Alias cAlias
	SELECT SLY.R_E_C_N_O_ SLYRECNO
	FROM  %table:SLY% SLY 
	WHERE SLY.%NotDel%
		AND SLY.LY_FILIAL = %xFilial:SLY%
		AND SLY.LY_FILENT = %xFilial:SWY%
		AND SLY.LY_ALIAS = "SWY"
		AND SLY.LY_CHVENT = %exp:cCodCCT%
EndSql

DbSelectArea("SLY")
While (cAlias)->(!Eof())
	SLY->(DbGoTo((cAlias)->SLYRECNO))
	aadd(aBenefs,{SLY->LY_TIPO,At996aDcTp(),SLY->LY_CODIGO,At996aDsc(),At996aVlrB()})//Beneficios
	(cAlias)->(DbSkip())
EndDo

(cAlias)->(DbCloseArea())

Return aBenefs

// ------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At996aPar
Array com os parametros de calculo
@author		Kaique Schiller
@since		21/02/2023
/*/
// ------------------------------------------------------------------------------------------------
Static Function At996aPar()
Local aRetParam := {{STR0082,"MES_COMERCIAL"},; //"Mês Comercial"
					{STR0083,"JORNADA_CALCULO"},; //"Jornada de Calculo"
					{STR0084,"FERIADO"},; //"Feriado"
					{STR0085,"INTERVALO"},; //"Intervalo"
					{STR0086,"AJUSTE_ESCALA"},; //"Ajuste de Escala"
					{STR0087,"JORNADA_COMERCIAL"},; //"Jornada Comercial"
					{STR0088,"TOTAL_HORAS"},; //"Total de Horas"
					{STR0089,"HORA_EXTRA"},; //"Horas Extas"
					{STR0090,"VALOR_HORA"},; //"Valor Hora"
					{STR0091,"VALOR_EXTRA"},; //"Valor Hora Extra"
					{STR0092,"VALOR_EXTRA_FERIADO"},;
					{STR0096,"HORAS_NOTURNAS"},; //"Horas Noturnas"
					{STR0095,"NUMERO_PESSOAS"} } //"Numero de Pessoas"

Return aRetParam

//------------------------------------------------------------------------------
/*/{Protheus.doc} At996aGrPr
@description	Gerar linhas nos parametros
@sample	 		At996aGrPr()
@author			Kaique Schiller
@since			21/02/2023
/*/
//------------------------------------------------------------------------------
Static Function At996aGrPr(oMdl)
Local aParam  := At996aPar()
Local oMdlTXN := Nil 
Local nX := 0
Local lRet := .T.
Local lTXNtbl := TableInDic("TXN") .And. TXN->( ColumnPos('TXN_CODIGO') ) > 0

If lTXNtbl
	oMdlTXN := oMdl:GetModel("TXNDETAIL")
	For nX := 1 To oMdlTXN:Length()
		oMdlTXN:GoLine(nX)
		If !Empty(oMdlTXN:GetValue("TXN_DESCRI"))
			lRet := lRet .And. oMdlTXN:DeleteLine()
		Endif
	Next nX

	If lRet
		For nX := 1 To Len(aParam)
			If !Empty(oMdlTXN:GetValue("TXN_DESCRI"))
				lRet := lRet .And. oMdlTXN:AddLine()
			Endif
			lRet := lRet .And. oMdlTXN:SetValue("TXN_DESCRI",aParam[nX,1])
			lRet := lRet .And. oMdlTXN:SetValue("TXN_NICK"  ,aParam[nX,2])
		Next nX
	Endif
Endif

Return lRet

/*/{Protheus.doc} At996aVlFr
	Validação de formula que faz referencia circular
	@type  Function 
	@author Kaique Schiller
	@since 15/03/2023
*/
Function At996aVlFr(oMdl,cCmpFor,cCmpNick)
Local lRet := .T.

If Alltrim(oMdl:GetValue(cCmpNick)) $ Alltrim(oMdl:GetValue(cCmpFor))
	Help(,, "At996aVlFr",,STR0093,1,0,,,,,,{STR0094}) //"Não é possível incluir uma referencia circular."##"Realize a correção da formula."
	lRet := .F.
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT996TpVer
	Função executada no gatilho do código da verba para captura do Tipo

@sample	AT996TpVer()
@author	jack junior
@since	31/05/2023
/*/
//------------------------------------------------------------------------------

Function AT996TpVer(cVerba)
Local cTipo := ""
Local cRet  := ""

cTipo := ALLTRIM(POSICIONE("SRV",1,xFilial("SRV")+cVerba,"RV_TIPO")) 

If cTipo == "H"
	cRet := "1"
ElseIf cTipo == "V"
	cRet := "2"
ElseIf cTipo == "D"
	cRet := "3"
EndIf

Return cRet
