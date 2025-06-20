#include "GTPC300C.CH"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

Static GCB300File := ""

Static oGCC300Model
Static cCodViagem	:= ""
Static oTableTmp
//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ModelDef

Defini��o do Modelo do MVC

@return: 
	oModel:	Object. Objeto da classe MPFormModel

@sample: oModel := ModelDef()

@author Fernando Radu Muscalu

@since 18/08/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
function GTPC300C()

Local oModel		:= FWLoadModel("GTPC300C")
Local oViewMonitor	:= GC300GetMVC('V')

oModel:SetOperation(MODEL_OPERATION_VIEW)

If ValType(oViewMonitor) == 'O' .AND. oViewMonitor:IsActive()
	
	cCodViagem	:= oViewMonitor:GetModel("GYNDETAIL"):GetValue("GYN_CODIGO")
	
	GQF->(DbSetOrder(1))//GQF_FILIAL+GQF_VIACOD+GQF_SEQ+GQF_ITEM+GQF_REVISA
	GQF->(DbSeek(xFilial("GQF")+PadR(cCodViagem,TamSX3("GQF_VIACOD")[1])))
	
	oModel:Activate()
	
	FWExecView( STR0001, 'VIEWDEF.GTPC300C', MODEL_OPERATION_VIEW, , { || .T. },,,,,,,oModel ) //'Inclus�o de Recurso'
Else
	FwAlertHelp(STR0001,STR0002) //"Esta rotina s� funciona com monitor ativo"
Endif
	
return



/*
	MVC - Cadastro de Hist�rico de Viagens
*/

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ModelDef

Defini��o do Modelo do MVC

@return: 
	oModel:	Object. Objeto da classe MPFormModel

@sample: oModel := ModelDef()

@author Fernando Radu Muscalu

@since 18/08/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------

Static Function ModelDef()

Local oModel
Local oStrGQF	:= FWFormStruct(1, 'GQF')
Local oStrCab	:= FWFormModelStruct():New()
Local aLoadFilter	:=	{}
Local aRelation	:= {}

oStrGQF:SetProperty("*",MODEL_FIELD_OBRIGAT, .F.)

GCB300CabStruct(oStrCab, .T.)
oStrCab:AddTable(GCB300File:GetAlias(),{},"Master")	//oStrCab:AddTable("GQFTRB",{},"Master")

oModel := MPFormModel():New("GTPC300C")

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields("GQFMASTER", , oStrCab)

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
oModel:AddGrid("GQFDETAIL", "GQFMASTER", oStrGQF,,,,,{|oGrid| GC300CLoad(oGrid)})

aAdd(aRelation, {"GQF_FILIAL","XFILIAL('GQF')"})

oModel:SetRelation('GQFDETAIL', aRelation, GQF->(IndexKey(1)) )

oModel:SetDescription(STR0003)						//"Hist�rico Manuten��o Operacional"
oModel:GetModel("GQFMASTER"):SetDescription(STR0002)//"Hist�rico Operacional - Master"
oModel:GetModel("GQFDETAIL"):SetDescription(STR0003)//"Hist�rico Operacional - Detalhes"

// Grid somente dos impostos
aLoadFilter	:=	{ { "GQF_VIACOD", "'" + cCodViagem + "'", MVC_LOADFILTER_EQUAL } }
oModel:GetModel("GQFDETAIL"):SetLoadFilter(aLoadFilter,/*cLoadFilter*/ ) 

oModel:GetModel("GQFMASTER"):SetOnlyQuery(.t.)

oModel:SetPrimaryKey({})

//oModel:SetDeactivate({|| GCB300EncerraTRB() })

oGCC300Model := oModel

Return(oGCC300Model)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ViewDef

Defini��o da View do MVC

@return: 
	oView:	Object. Objeto da classe FWFormView

@sample: oView := ViewDef()

@author Fernando Radu Muscalu

@since 18/08/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= ModelDef()
Local oView		:= Nil
Local oStrCab	:= FWFormViewStruct():New()
Local oStrGQF	:= FwFormStruct(2, "GQF")

GCB300CabStruct(oStrCab, .f.)

oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)

oView:AddGrid('VW_GQFDETAIL', oStrGQF, 'GQFDETAIL')

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('CORPO', 100)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VW_GQFDETAIL', 'CORPO')

//Habitila os t�tulos dos modelos para serem apresentados na tela
oView:EnableTitleView('VW_GQFDETAIL')

Return(oView)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GCB300CabStruct

Fun��o respons�vel pela defini��o da estrutura utilizada no Model ou na View.

@Params: 
	oStrCab:	Objeto da Classe FWFormModelStruct ou FWFormViewStruct, dependendo do par�metro lModel 	
	lModel:		L�gico. .t. - Ser� criado/atualizado a estrutura do Model; .f. - ser� criado/atualizado a
	estrutura da View
	
@sample: GCB300CabStruct(oStrCab, lModel)

@author Fernando Radu Muscalu

@since 07/12/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function GCB300CabStruct(oStrCab, lModel)

Default lModel := .t.

If ( lModel )

	oStrCab:AddField(	STR0005,;								//Descri��o (Label) do campo //"C�digo"
						STR0005,;								//Descri��o Tooltip do campo//"Somat�ria dos Lan�amentos de Receita"//"C�digo"
						"CODIGO",;							//Identificador do campo
						"C",;									//Tipo de dado
						10,;				//Tamanho
						0,;										//Decimal
						nil,;									//Valid do campo
						nil,;									//When do campo
						{},;									//Lista de Op��es (Combo)
						.f.,;									//Indica se campo � obrigat�rio
						Nil,;									//inicializador Padr�o
						.f.,;									//Indica se o campo � chave
						.f.,;									//Indica se o campo pode receber um valor em uma opera��o update
						.f.)									//Indica se o campo � virtual

EndIf
//If ( Select("GQFTRB") == 0 )
	GCB300CriaTRB()
//Endif

Return()

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GCB300CriaTRB

Fun��o respons�vel pela cria��o do arquivo tempor�rio utilizado no cabe�alho da tela.

@Params: 
	oStrCab:	Objeto da Classe FWFormModelStruct, dependendo do par�metro lModel 	
	
@author Fernando Radu Muscalu

@since 18/08/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function GCB300CriaTRB()

Local aStruct	:= {}

aAdd(aStruct, {"CODIGO","C",10,0})

If ( ValType(GCB300File) <> "O" )

	GCB300File := FWTemporaryTable():New() //FWOpenTemp("GQFTRB",aStruct) GCB300File := FWTemporaryTable():New('GQFTRB') //FWOpenTemp("GQFTRB",aStruct)
	GCB300File:SetFields(aStruct)
	GCB300File:AddIndex("01", {"CODIGO"})
	GCB300File:Create()

Else
	GCB300File:ZAP()
EndIf

//IndRegua("GQFTRB", GCB300File, "CODIGO", , , STR0006)//"Indexando Registros GQFTRB..."

Return()

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GCB300SetData

Fun��o que atualiza o arquivo tempor�rio.

@Params: 
	cCodigo:	String. C�digo do Hist�rico 	
	cRevisao:	String. Revisao do Hist�rico
	cViagem:	String. C�digo da viagem

@Return:
	lRet:	L�gico. Atualiza��o do arquivo efetuada com sucesso (.t.)
	
@sample: lRet := GCB300SetData(cCodigo, cRevisao, cViagem)

@author Fernando Radu Muscalu

@since 07/12/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
// Function GCB300SetData(cCodigo, cRevisao, cViagem)

// Local lRet := .f.
// Local cAlias := GCB300File:GetAlias()

// //If ( Select("GQFTRB") == 0 )
// 	GCB300CriaTRB()
// //Endif

// (cAlias)->(DbSetOrder(1))

// If ( !(cAlias)->(DbSeek(PadR(cCodigo, TamSx3("GQF_CODIGO")[1])+PadR(cRevisao, TamSx3("GQF_REVISA")[1])+Padr(cViagem, TamSx3("GQF_VIACOD")[1]))) )

// 	RecLock(cAlias, .t.)
// 		CODIGO := cValToChar(Randomize(1,99999))
// 	(cAlias)->(MsUnlock())
	
// 	lRet := .t.
	
// Endif

// Return(lRet)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GCB300GetHist

Fun��o respons�vel por retornar o c�digo de hist�rico e revis�o mais atual da viagem.

@Params: 
	cCodViag:	String. C�digo da Viagem 	
	cCodHist:	String. C�digo do Hist�rico
	
@Return:
	Array. Array com o c�digo do hist�rico e revis�o mais atualizado 
	
@sample: lRet := GCB300GetHist(cCodViag, cCodHist)

@author Fernando Radu Muscalu

@since 07/12/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Function GCB300GetHist(cCodViag, cCodHist)

Local cAlias	:= GetNextAlias()
Local cHist		:= ""
Local cRevisao	:= ""
Local cWhere	:= ""

Local lRet		:= .f.

Default cCodHist	:= ""

If ( !Empty(cCodHist) )
	cWhere := "%GQF_CODIGO = '" + Alltrim(cCodHist) + "' "
	cWhere += " AND GQF_VIACOD = '" + Alltrim(cCodViag) + "'%"	
Else
	cWhere := "%GQF_VIACOD = '" + Alltrim(cCodViag) + "' %"
Endif

BeginSQL Alias cAlias
	
	SELECT
		DISTINCT
		GQF_CODIGO
	FROM
		%Table:GQF% GQF
	WHERE	
		GQF_FILIAL = %XFilial:GQF%
		AND %Exp:cWhere%
		AND GQF.%NotDel%
		
EndSQL

cHist := (cAlias)->GQF_CODIGO

If ( !Empty(cHist) )

	(cAlias)->(DbCloseArea())
	
	BeginSQL Alias cAlias
	
		SELECT
			MAX(GQF_REVISA) GQF_REVISA
		FROM	
			%Table:GQF% GQF
		WHERE	
			GQF_FILIAL = %XFilial:GQF%
			AND GQF_CODIGO = %Exp:cHist%
			AND GQF_VIACOD = %Exp:cCodViag%
			AND GQF.%NotDel%
	
	EndSQL
	
	cRevisao := (cAlias)->GQF_REVISA
	
	lRet := .t.
	
Else
	
	(cAlias)->(DbCloseArea())
	
	BeginSQL Alias cAlias
	
		SELECT 
			MAX(GQF_CODIGO) GQF_CODIGO
		FROM 
			%Table:GQF% GQF
		WHERE 
			GQF_FILIAL = %XFilial:GQF%
		  	AND GQF.%NotDel%
	EndSQL
	
	If ( !Empty((cAlias)->GQF_CODIGO) )
		cHist := Soma1((cAlias)->GQF_CODIGO)	
	Else
		cHist := StrZero(1,TamSx3("GQF_CODIGO")[1])
	Endif	 
	
	cRevisao := StrZero(1,TamSx3("GQF_REVISA")[1])
	
Endif

(cAlias)->(DbCloseArea())

Return({cHist,cRevisao,lRet})

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GCB300EncerraTRB

Fun��o respons�vel pela exclus�o do arquivo tempor�rio utilizado no cabe�alho da tela.

@author Fernando Radu Muscalu

@since 18/08/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function GCB300EncerraTRB()
Local cAlias := GCB300File:GetAlias()

If ( Select(cAlias) > 0 )

	If File(cAlias+OrdBagExt())
		Ferase(cAlias+OrdBagExt())
	Endif
	
	//Apaga os arquivos de dados tempor�rios
	FWCloseTemp(cAlias)
	
Endif

Return()

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GCB300GetModel

Fun��o respons�vel para pegar o modelo do GTPC300C

@author Fernando Radu Muscalu

@since 25/08/2017
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Function GCC300GetModel()

Return(oGCC300Model)
//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GCC300Destroy

Fun��o respons�vel para destruir o modelo GTPC300C

@author Fernando Radu Muscalu

@since 25/08/2017
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Function  GCC300Destroy()

If ( Valtype(oGCC300Model) == "O" )
	
	If ( oGCC300Model:IsActive() )
		oGCC300Model:DeActivate()
	EndIf	
	
	oGCC300Model:Destroy()
	
	oGCC300Model := nil
	
	FreeObj(oGCC300Model)
	
EndIf	
Return()

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GC300CLoad

Realiza o load do hist�rico da tabela GQF

@author Inova��o

@since 25/08/2017
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function GC300CLoad(oGrid)

Local aFldConv	:= {}
Local aRet		:= {}

Local cQry		:= ""
Local cField	:= GTPFld2Str(oGrid:GetStruct(),.t.,aFldConv)

AADD(aFldConv,{"RECNO","N",15})

cQry := "SELECT " + chr(13)
cQry += "	" +	Alltrim(cField) + ", GQF.R_E_C_N_O_ RECNO " + space(1) + chr(13)
cQry += "FROM " + chr(13)
cQry += "	" + RetSQLName("GQF") + " GQF " + chr(13)
cQry += "WHERE " + chr(13)
cQry += "	GQF_FILIAL = '" + xFilial("GQF") + "' " + chr(13)
cQry += "	AND GQF.D_E_L_E_T_ = ' ' " + chr(13)
cQry += "	AND GQF_VIACOD = '" + cCodViagem + "' " + chr(13) 
cQry += "ORDER BY " + chr(13)
cQry += "GQF_VIACOD, " + chr(13) 
cQry += "	GQF_SEQ, " + chr(13)
cQry += "	GQF_ITEM, " + chr(13)
cQry += "	GQF_REVISA DESC " + chr(13)
//RADU - JCA: DSERGTP-8012
GTPNewTempTable(cQry,"HIST",{{"INDEX1",{"GQF_VIACOD","GQF_SEQ","GQF_ITEM","GQF_REVISA"}}},aFldConv,@oTableTmp) //GTPTemporaryTable(cQry,"HIST",{{"INDEX1",{"GQF_VIACOD","GQF_SEQ","GQF_ITEM","GQF_REVISA"}}},aFldConv,@oTableTmp)

(oTableTmp:GetAlias())->(DbGoTop())

aRet := FWLoadByAlias(oGrid, oTableTmp:GetAlias())//, oTable:GetRealName())

// oTableTmp:Delete()

Return(aRet)
