#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA203A.CH"

#DEFINE DEF_TITULO_DO_CAMPO		01	//Titulo do campo
#DEFINE DEF_TOOLTIP_DO_CAMPO	02	//ToolTip do campo
#DEFINE DEF_IDENTIFICADOR		03	//identificador (ID) do Field
#DEFINE DEF_TIPO_DO_CAMPO		04	//Tipo do campo
#DEFINE DEF_TAMANHO_DO_CAMPO	05	//Tamanho do campo
#DEFINE DEF_DECIMAL_DO_CAMPO	06	//Decimal do campo
#DEFINE DEF_CODEBLOCK_VALID		07	//Code-block de validação do campo
#DEFINE DEF_CODEBLOCK_WHEN		08	//Code-block de validação When do campo
#DEFINE DEF_LISTA_VAL			09	//Lista de valores permitido do campo
#DEFINE DEF_OBRIGAT				10	//Indica se o campo tem preenchimento obrigatório
#DEFINE DEF_CODEBLOCK_INIT		11	//Code-block de inicializacao do campo
#DEFINE DEF_CAMPO_CHAVE			12	//Indica se trata de um campo chave
#DEFINE DEF_RECEBE_VAL			13	//Indica se o campo pode receber valor em uma operação de update.
#DEFINE DEF_VIRTUAL				14	//Indica se o campo é virtual
#DEFINE DEF_VALID_USER			15	//Valid do usuario

#DEFINE DEF_ORDEM				16	//Ordem do campo
#DEFINE DEF_HELP				17	//Array com o Help dos campos
#DEFINE DEF_PICTURE				18	//Picture do campo
#DEFINE DEF_PICT_VAR			19	//Bloco de picture Var
#DEFINE DEF_LOOKUP				20	//Chave para ser usado no LooKUp
#DEFINE DEF_CAN_CHANGE			21	//Logico dizendo se o campo pode ser alterado
#DEFINE DEF_ID_FOLDER			22	//Id da Folder onde o field esta
#DEFINE DEF_ID_GROUP			23	//Id do Group onde o field esta
#DEFINE DEF_COMBO_VAL			24	//Array com os Valores do combo
#DEFINE DEF_TAM_MAX_COMBO		25	//Tamanho maximo da maior opção do combo
#DEFINE DEF_INIC_BROWSE			26	//Inicializador do Browse
#DEFINE DEF_PICTURE_VARIAVEL	27	//Picture variavel
#DEFINE DEF_INSERT_LINE			28	//Se verdadeiro, indica pulo de linha após o campo
#DEFINE DEF_WIDTH				29	//Largura fixa da apresentação do campo
#DEFINE DEF_TIPO_CAMPO_VIEW		30	//Tipo do campo

#DEFINE QUANTIDADE_DEFS			30	//Quantidade de DEFs

Static aCabec   := {}   //Array para popular o cabeçalho
Static aDados	:= {}	//Array para popular a tela de batidas

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Definição do modelo de Dados

@author	Luiz Gabriel
@since 27/09/2022
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel	
Local oStrCab		:= FWFormModelStruct():New()
Local oStrGrd		:= FWFormModelStruct():New()
Local aFields		:= {}
Local nX			:= 0
Local nY			:= 0
Local aTables 		:= {}
Local bCommit		:= {|oModel| At203ACmt( oModel )}
Local bTudoOk		:= {|oModel| At203TudoOk( oModel )}
Local bPosValid		:= {|oMdlG,nLine| PosLinABB(oMdlG, nLine)}

oStrCab:AddTable("   ",{}, STR0001) //"Ajuste de Marcação"
oStrGrd:AddTable("   ",{}, "   ")

AADD(aTables, {oStrCab, "CAB"}) //Tabela do cabeçalho
AADD(aTables, {oStrGrd, "GRD"}) //Tabela do Grid

For nY := 1 To LEN(aTables)
	aFields := AT203ABTbl(aTables[nY][2])

	For nX := 1 TO LEN(aFields)
		aTables[nY][1]:AddField(aFields[nX][DEF_TITULO_DO_CAMPO],;
						aFields[nX][DEF_TOOLTIP_DO_CAMPO],;
						aFields[nX][DEF_IDENTIFICADOR	],;
						aFields[nX][DEF_TIPO_DO_CAMPO	],;
						aFields[nX][DEF_TAMANHO_DO_CAMPO],;
						aFields[nX][DEF_DECIMAL_DO_CAMPO],;
						aFields[nX][DEF_CODEBLOCK_VALID	],;
						aFields[nX][DEF_CODEBLOCK_WHEN	],;
						aFields[nX][DEF_LISTA_VAL		],;
						aFields[nX][DEF_OBRIGAT			],;
						aFields[nX][DEF_CODEBLOCK_INIT	],;
						aFields[nX][DEF_CAMPO_CHAVE		],;
						aFields[nX][DEF_RECEBE_VAL		],;
						aFields[nX][DEF_VIRTUAL			],;
						aFields[nX][DEF_VALID_USER		])
	Next nX
Next nY

oModel := MPFormModel():New('TECA203A',/*bPreValidacao*/,bTudoOk/*bPosValidacao*/,bCommit,/*bCancel*/)
oModel:AddFields('CABMASTER',/*cOwner*/,oStrCab,,/*bPosValidacao*/,/*bFieldAbp*/,/*bCarga*/,/*bFieldTfl*/)

oModel:addGrid('GRDDETAIL','CABMASTER',oStrGrd,/*bPreValid*/,bPosValid )

oModel:setDescription(STR0001) //"Ajuste de Marcação"

oModel:SetPrimaryKey({'CAB_CODTEC'})

oModel:GetModel('CABMASTER'):SetDescription(STR0001) //"Ajuste de Marcação"
oModel:GetModel('GRDDETAIL'):SetDescription(STR0002) //"Batidas do dia"

oModel:GetModel('CABMASTER'):SetOnlyView(.T.)
oModel:GetModel('CABMASTER'):SetOnlyQuery(.T.)
oModel:GetModel('GRDDETAIL'):SetOptional(.T.)

oModel:SetActivate( {|oModel| InitDados( oModel ) } )

//Zera as teclas de atalho para evitar erro
SetKey(VK_F8, {||})
SetKey(VK_F10, {||})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@author	Luiz Gabriel
@since 27/09/2022
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= Nil
Local oModel 	:= ModelDef()
Local oStrCab	:= FWFormViewStruct():New()
Local oStrGrd	:= FWFormViewStruct():New()
Local aTables 	:= {}
Local aFields	:= {}
Local nX		:= 0
Local nY		:= 0

AADD(aTables, {oStrCab, "CAB"}) //Tabela do cabeçalho
AADD(aTables, {oStrGrd, "GRD"}) //Tabela do Grid

For nY := 1 to LEN(aTables)
	aFields := AT203ABTbl(aTables[nY][2])

	For nX := 1 to LEN(aFields)
		aTables[nY][1]:AddField(aFields[nX][DEF_IDENTIFICADOR],;
						aFields[nX][DEF_ORDEM],;
						aFields[nX][DEF_TITULO_DO_CAMPO],;
						aFields[nX][DEF_TOOLTIP_DO_CAMPO],;
						aFields[nX][DEF_HELP],;
						aFields[nX][DEF_TIPO_CAMPO_VIEW],;
						aFields[nX][DEF_PICTURE],;
						aFields[nX][DEF_PICT_VAR],;
						aFields[nX][DEF_LOOKUP],;
						aFields[nX][DEF_CAN_CHANGE],;
						aFields[nX][DEF_ID_FOLDER],;
						aFields[nX][DEF_ID_GROUP],;
						aFields[nX][DEF_COMBO_VAL],;
						aFields[nX][DEF_TAM_MAX_COMBO],;
						aFields[nX][DEF_INIC_BROWSE],;
						aFields[nX][DEF_VIRTUAL],;
						aFields[nX][DEF_PICTURE_VARIAVEL],;
						aFields[nX][DEF_INSERT_LINE],;
						aFields[nX][DEF_WIDTH])
	Next nX
Next nY

oView := FWFormView():New()
oView:SetModel(oModel)

oStrGrd:RemoveField("GRD_ABBREC")

oView:AddField('VIEW_CAB', oStrCab, 'CABMASTER')

oView:AddGrid('VIEW_GRD',  oStrGrd, 'GRDDETAIL')
oView:EnableTitleView('VIEW_GRD', STR0002) //"Batidas do dia"

oView:CreateHorizontalBox('ATENDENTE',   20)
oView:CreateHorizontalBox('BATIDAS', 80)

oView:SetOwnerView('VIEW_CAB','ATENDENTE')
oView:SetOwnerView('VIEW_GRD','BATIDAS')

oView:SetDescription(STR0001) // "Ajuste de Marcação"

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT203ABTbl

@description Retorna em forma de Array as definições dos campos

@param cTable, string, define de qual tabela devem ser os campos retornados

@return aRet, array, definição dos campos

@author	Luiz Gabriel
@since	27/09/2022
/*/
//------------------------------------------------------------------------------
Function AT203ABTbl(cTable)
Local aRet := {}
Local nAux := 0

If cTable == "CAB"  //Cabeçalho

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0003	 //"Cod. Atend"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0003 //"Cod. Atend"
	aRet[nAux][DEF_IDENTIFICADOR] := "CAB_CODATE"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CODTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0004}	//"Codigo do Atendente"

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0005	 //"Nome Atend"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0005 //"Nome Atend"
	aRet[nAux][DEF_IDENTIFICADOR] := "CAB_NOMATE"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_NOMTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0006}	//"Nome do Atendente"

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0007	//"Dt Referencia"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0007	//"Dt Referencia"
	aRet[nAux][DEF_IDENTIFICADOR] := "CAB_DTREF"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

ElseIf cTable == "GRD" //Batidas do dia

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0008	//"Dt Batida"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0008	//"Dt Batida"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRD_DAT"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0009	//"Dia da Semana"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0009	//"Dia da Semana"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRD_DOW"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 20
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0010	//"Dt Ini Prev"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0010	//"Dt Ini Prev"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRD_DTIPREV"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0011 //"Hr Ent Prev"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0011 //"Hr Ent Prev"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRD_INPREV"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_HRINI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "99:99"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0012} //"Hora de Inicio Prevista"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0013 //"Hr Ent Rea"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0013 //"Hr Ent Rea"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRD_INREAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_HRINI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| At203AWhen("GRDDETAIL","GRD_INREAL",.T.,.F.) }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "99:99"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0014} //"Hora de Inicio Realizada"
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|| At203VldHora(1) }

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0015	//"Dt Fim Prev"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0015	//"Dt Fim Prev"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRD_DTFPREV"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0016 //"Hr Sai Prev"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0016 //"Hr Sai Prev"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRD_OUTPREV"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_HRFIM")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "07"
	aRet[nAux][DEF_PICTURE] := "99:99"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0017} //"Hora de saída Prevista"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0018 //"Hr Sai Rea"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0018 //"Hr Sai Rea"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRD_OUTREAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_HRFIM")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| At203AWhen("GRDDETAIL","GRD_OUTREAL",.F.,.T.) }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "08"
	aRet[nAux][DEF_PICTURE] := "99:99"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0019} //"Hora de Inicio Realizada"
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|| At203VldHora(2) }

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0020 //"Justificativa"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0020 //"Justificativa"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRD_JUSTIF"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "M"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "M"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABB_JUSTIF")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| At203WhJust("GRDDETAIL") }
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "09"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0021} //"Justificativa de ajuste de batida manual"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0022 //"Recno"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0022 //"Recno"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRD_ABBREC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 16
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "10"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0023} //"Recno da tabela ABB"

EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados

@description Bloco de código executado no activate
@param oModel, obj, modelo em ativação

@author	Luiz Gabriel
@since	27/09/2022
/*/
//------------------------------------------------------------------------------
Static Function InitDados(oModel)
Local oMdlCAB 	:= oModel:GetModel('CABMASTER')
Local oMdlGRD 	:= oModel:GetModel('GRDDETAIL')
Local aGrid 	:= {}
Local nX 		:= 0
Local nLinha 	:= 1

//Carrega o cabeçalho
oMdlCAB:LoadValue("CAB_CODATE", aCabec[1][2])
oMdlCAB:LoadValue("CAB_NOMATE", aCabec[2][2])
oMdlCAB:LoadValue("CAB_DTREF", aCabec[3][2])

//Carrega o grid com as agendas
If !Empty(aDados)
	aGrid := At203AGetD(aDados, oMdlCAB:GetValue("CAB_DTREF"),oMdlCAB:GetValue("CAB_CODATE"))
	If Len(aGrid) > 0
		For nX := 1 To Len(aGrid)
			If nX > 1
				nLinha := oMdlGRD:AddLine()
			EndIf
			oMdlGRD:GoLine(nLinha)
			oMdlGRD:LoadValue("GRD_DAT", oMdlCAB:GetValue("CAB_DTREF"))
			oMdlGRD:LoadValue("GRD_DOW", TECCdow(DOW(oMdlCAB:GetValue("CAB_DTREF"))))
			oMdlGRD:LoadValue("GRD_DTIPREV", oMdlCAB:GetValue("CAB_DTREF"))
			oMdlGRD:LoadValue("GRD_DTFPREV", oMdlCAB:GetValue("CAB_DTREF"))
			oMdlGRD:LoadValue("GRD_INREAL",  aGrid[nX][1])
			oMdlGRD:LoadValue("GRD_OUTREAL", aGrid[nX][2])
			oMdlGRD:LoadValue("GRD_INPREV",  aGrid[nX][3])
			oMdlGRD:LoadValue("GRD_OUTPREV", aGrid[nX][4])
			oMdlGRD:LoadValue("GRD_ABBREC",  aGrid[nX][5])
			oMdlGRD:LoadValue("GRD_JUSTIF",  At203LdJust(aGrid[nX][5]))
		Next nX
		oMdlGRD:GoLine(1) 
	EndIf 
EndIf 	

//trava a criação de novas linhas e exclusão das linhas criadas
oMdlGRD:SetNoInsertLine(.T.)
oMdlGRD:SetNoDeleteLine(.T.)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} PosLinABB()

Função de Posvalidacao do grid de batidas

@author Luiz Gabriel
@since  27/09/2022
/*/
//------------------------------------------------------------------------------
Static Function PosLinABB(oMdlG, nLine)
Local lRet		:= .T.
Local aAreaABB 	:= ABB->(GetArea())

DbSelectArea("ABB")
ABB->(dbGoTo(oMdlG:GetValue("GRD_ABBREC")))

If ABB->ABB_HRCHIN <> oMdlG:GetValue("GRD_INREAL") .Or. ABB->ABB_HRCOUT <> oMdlG:GetValue("GRD_OUTREAL")
	If Empty(oMdlG:GetValue("GRD_JUSTIF"))
		Help( , , "PosValida", , STR0024, 1, 0,,,,,,{STR0025}) //"O campo de justificativa deve ser preenchido"##"Preencha o campo de justificativa"
		lRet := .F.
	ElseIf oMdlG:GetValue("GRD_OUTREAL") <= oMdlG:GetValue("GRD_INREAL") .And. ABB->ABB_DTINI == ABB->ABB_DTFIM
		Help( , , "PosValida", , STR0026, 1, 0,,,,,,{STR0027}) //"Horários de entrada e saída incompatíveis."###"Horário de saída não pode ser posterior ao horário de entrada."
		lRet := .F.
	EndIf
EndIf

RestArea(aAreaABB)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At203TudoOk()

Função de Posvalidacao do Model

@author flavio.vicco
@since  01/03/2023
/*/
//------------------------------------------------------------------------------
Static Function At203TudoOk(oModel)
Local lRet		:= .T.
Local oMdlG 	:= oModel:GetModel("GRDDETAIL")
Local aSaveLine := FwSaveRows()
Local cHrCOUT	:= ""
Local nX		:= 0

If lRet
	For nX := 1 To oMdlG:Length()
		oMdlG:GoLine(nX)
		If nX > 1
			If cHrCOUT >= oMdlG:GetValue("GRD_INREAL")
				Help( , , "PosValida", , STR0028, 1, 0,,,,,,{STR0027}) //"Horários de entrada e saída incompatíveis."###"Horário de saída não pode ser posterior ao horário de entrada do periodo seguinte."
				lRet := .F.
				Exit
			EndIf
		EndIf
		cHrCOUT := oMdlG:GetValue("GRD_OUTREAL")
	Next nX
EndIf

FWRestRows(aSaveLine)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At203VldHora()

Função de validação dos horarios

@author flavio.vicco
@since  01/03/2023
/*/
//------------------------------------------------------------------------------
Static Function At203VldHora(nOpc)
Local lRet		:= .T.
Local aAreaABB 	:= ABB->(GetArea())
Local oModel	:= FwModelActive()
Local oMdlG 	:= oModel:GetModel("GRDDETAIL")
Local nRecABB	:= oMdlG:GetValue("GRD_ABBREC")
Local cHoraABB	:= ""
Local cHoraDig	:= ""

DbSelectArea("ABB")
ABB->(dbGoTo(nRecABB))

If nOpc == 1
	cHoraDig := oMdlG:GetValue("GRD_INREAL")
	cHoraABB := ABB->ABB_HRCHIN
Else
	cHoraDig := oMdlG:GetValue("GRD_OUTREAL")
	cHoraABB := ABB->ABB_HRCOUT
EndIf

If (cHoraDig=="  :  " .Or. Empty(cHoraDig)) .And. Empty(cHoraABB)
	If nOpc == 1
		oMdlG:LoadValue("GRD_INREAL","")
	ElseIf nOpc == 2
		oMdlG:LoadValue("GRD_OUTREAL","")
	EndIf
Else
	lRet := AtVldHora(cHoraDig)
EndIf

RestArea(aAreaABB)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} Set203ACabec()

Seta Valores para o Cabeçalho na variavel statica aValores

@author Luiz Gabriel
@since  27/09/2022
/*/
//------------------------------------------------------------------------------
Function Set203ACabec(aValor)

aCabec := aValor

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Set203AGrid()

Seta Valores para o Grid de ajuste manual

@author Luiz Gabriel
@since  27/09/2022
/*/
//------------------------------------------------------------------------------
Function Set203AGrid(aValor)

aDados := aValor

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Set203ALimp()

Limpa as variaveis staticas

@author Luiz Gabriel
@since  27/09/2022
/*/
//------------------------------------------------------------------------------
Function Set203ALimp()
 aDados := {}
 aCabec := {}
Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} At203AGetD()

Realiza o filtro das agendas de acordo com a data de referencia para
preenchimento no grid

@author Luiz Gabriel
@since  27/09/2022
/*/
//------------------------------------------------------------------------------
Static Function At203AGetD(aAllGrid,dData,cCodAtend)
Local aRet	:= {}
Local aAux	:= {}
Local nPos 	:= 0
Local nInd 	:= 0

nPos := AScan( aAllGrid, { |x| x[1] == DtoS(dData) .And. x[2] == cCodAtend })

While nPos > 0
	aAdd(aAux,AllTrim(aAllGrid[nPos][4])) //ABB_HRCHIN
	aAdd(aAux,AllTrim(aAllGrid[nPos][5])) //ABB_HRCOUT
	aAdd(aAux,AllTrim(aAllGrid[nPos][6])) //ABB_HRINI
	aAdd(aAux,AllTrim(aAllGrid[nPos][7])) //ABB_HRFIM
	aAdd(aAux,aAllGrid[nPos][11]) //Recno da ABB

	aAdd(aRet,aAux)
	aAux := {}
	nInd := nPos + 1
	nPos := 0
	nPos := AScan( aAllGrid, { |x| x[1] == DtoS(dData) .And. x[2] == cCodAtend }, nInd)
EndDo 

Return aRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} At203ACmt()

Realiza a gravação dos dados na ABB de acordo com os horarios alterados

@author Luiz Gabriel
@since  27/09/2022
/*/
//------------------------------------------------------------------------------
Function At203ACmt( oModel )
Local lRet		:= .T.
Local oMdlGRD 	:= oModel:GetModel('GRDDETAIL')
Local nX		:= 0
Local lJustf 	:= .F.
Local lCheckin	:= .F.
Local lCheckout	:= .F.
Local lExistTV3 := TableInDic("TV3")
Local lCodMar	:= ABB->(ColumnPos("ABB_MARENT")) > 0 .And. ABB->(ColumnPos("ABB_MARSAI")) > 0

Begin Transaction
	DbSelectArea("ABB")
	For nX := 1 To oMdlGRD:Length()
		lJustf := .F.
		lCheckin := .F.
		lCheckout	:= .F.
		oMdlGRD:GoLine(nX)
		If oMdlGRD:IsUpdated(nX)
			ABB->(dbGoTo(oMdlGRD:GetValue("GRD_ABBREC")))				
				RecLock("ABB",.F.)		
					
				If At203AAlt(oMdlGRD,"GRD_INREAL",ABB->ABB_HRCHIN)	
					ABB->ABB_CHEGOU := 'S'
					ABB->ABB_HRCHIN := oMdlGRD:GetValue("GRD_INREAL")
					lJustf := .T.
					lCheckin := .T.
				EndIf 

				If At203AAlt(oMdlGRD,"GRD_OUTREAL",ABB->ABB_HRCOUT)	
					ABB->ABB_SAIU := 'S'
					ABB->ABB_ATENDE := '1'
					ABB->ABB_HRCOUT := oMdlGRD:GetValue("GRD_OUTREAL")	
					lJustf := .T.
					lCheckout	:= .T.
				EndIf
				If lJustf
					ABB->ABB_JUSTIF := oMdlGRD:GetValue("GRD_JUSTIF")
				EndIf 
				ABB->(MsUnlock())

				// Gravacao do status de ajustado nas marcações entrada/saida
				If lCheckin .And. lCodMar .And. !Empty(ABB->ABB_MARENT)
					At203AMnt(ABB->ABB_MARENT)
				EndIf
				If lCheckout .And. lCodMar .And. !Empty(ABB->ABB_MARSAI)
					At203AMnt(ABB->ABB_MARSAI)
				EndIf

				If lExistTV3
					//Grava o historico do ajuste
					At203AHist(ABB->ABB_FILIAL,ABB->ABB_CODIGO, lCheckin, lCheckout , oMdlGRD )
				EndIf
		EndIf	 
	Next nX 
End Transaction

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At203AHist()

realiza a gravação do historico das batidas na tabela TV3

@author Luiz Gabriel
@since  27/09/2022
/*/
//------------------------------------------------------------------------------
Static Function At203AHist(cFilABB,cCodABB,lCheckin,lCheckout,oMdlGRD)
Local lHVerao		:= SuperGetMv("MV_HVERAO",.F.,.F.) 	// Verifica se o local fisico do servidor está em Horário de Verão  .F. Não / .T. Sim
Local aTimeUf       := {} 
Local aAreaSM0	    := Nil

DbSelectArea("TV3")
If lCheckin .Or. lCheckout 
	aAreaSM0 := SM0->(GetArea())
	dbSelectArea("SM0")
	SM0->(dbSetOrder(1))
	If SM0->(dbSeek(cEmpAnt+cFilAnt))
		aTimeUf := FwTimeUF(SM0->M0_ESTENT,,lHVerao,DTOS(dDataBase)) //Pega dia e horario do servidor
	EndIf
	RestArea(aAreaSM0)

	RecLock("TV3",.T.)

		TV3->TV3_FILIAL := xFilial("TV3")
		TV3->TV3_CODIGO := GetSXENum( "TV3", "TV3_CODIGO" )
		TV3->TV3_CODABB := cCodABB
		TV3->TV3_FILABB := cFilABB
		TV3->TV3_DTINI 	:= oMdlGRD:GetValue("GRD_DTIPREV")
		
		If lCheckin
			TV3->TV3_HRCHIN	:= oMdlGRD:GetValue("GRD_INREAL")
		EndIf 	
		
		TV3->TV3_DTFIM 	:= oMdlGRD:GetValue("GRD_DTFPREV")
		
		If lCheckout
			TV3->TV3_HRCOUT	:= oMdlGRD:GetValue("GRD_OUTREAL")	
		EndIf 
		
		TV3->TV3_JUSTIF := oMdlGRD:GetValue("GRD_JUSTIF")
		TV3->TV3_CODUSR := RetCodUsr()
		TV3->TV3_DTALT 	:= StoD(aTimeUF[1])
		TV3->TV3_HRALT  := aTimeUF[2]

	TV3->(MsUnlock())
EndIf 

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} At203LdJust()

realiza o carregamento do campo de justificativa

@author Luiz Gabriel
@since  27/09/2022
/*/
//------------------------------------------------------------------------------
Static Function At203LdJust(nRecABB)
Local cMemo 	:= ""
Local aAreaABB	:= ABB->(GetArea())

DbSelectArea("ABB")
ABB->(dbGoTo(nRecABB))

If !Empty(ABB->ABB_JUSTIF)
	cMemo := ABB->ABB_JUSTIF
EndIf 

RestArea(aAreaABB)
Return cMemo

//------------------------------------------------------------------------------
/*/{Protheus.doc} At203ATV3()

Verifica se o campo já foi editado em uma oportunidade anterior,
através da tabela TV3 que armazena o historico das alterações

@author Luiz Gabriel
@since  27/09/2022
/*/
//------------------------------------------------------------------------------
Static Function At203ATV3(nRecABB,lCheckIn,lCheckout)
Local lRet 		:= .F.
Local aAreaABB 	:= ABB->(GetArea())
Local cAliasQry	:= GetNextAlias()

DbSelectArea("ABB")
ABB->(dbGoTo(nRecABB))		

cCodABB := ABB->ABB_CODIGO
cFilABB := ABB->ABB_FILIAL

BeginSQL Alias cAliasQry
	SELECT TV3.TV3_HRCHIN,TV3.TV3_HRCOUT
		FROM %Table:TV3% TV3
		WHERE TV3.TV3_FILIAL = %xFilial:TV3%
		AND TV3.%NotDel%
		AND TV3.TV3_CODABB = %Exp:cCodABB%
		AND TV3.TV3_FILABB = %Exp:cFilABB%
EndSQL

While (cAliasQry)->(!Eof())
	If lCheckIn .And. !Empty((cAliasQry)->TV3_HRCHIN)
		lRet := .T. 
	EndIf 

	If lCheckout .And. !Empty((cAliasQry)->TV3_HRCOUT)
		lRet := .T. 
	EndIf 
	(cAliasQry)->(DbSkip())
End

(cAliasQry)->(DbCloseArea())

RestArea(aAreaABB)

Return lRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} At203AWhen()

Faz a tratativa de bloquear ou desbloquear os campos de checkin e checkout

@author Luiz Gabriel
@since  27/09/2022
/*/
//------------------------------------------------------------------------------
Function At203AWhen(cForm,cCampo,lCheckin,lCheckout)
Local lRet 		:= .F.
Local oModel 	:= FwModelActive()
Local oSubModel	:= Nil
Local xValue	:= Nil
Local aAreaABB	:= Nil
Local cCpoRef	:= ""
Local lExistTV3 := TableInDic("TV3") 

If VALTYPE(oModel) == "O"
	oSubModel := oModel:GetModel(cForm)
	If VALTYPE(oSubModel) == "O"
		xValue := oSubModel:GetValue(cCampo)
	EndIf
EndIf

If IsInCallStack("At765Batida")
	lRet := .T.
ElseIf Empty(xValue) 
	If !lExistTV3
		lRet := .T.
	ElseIf Empty(xValue) .Or. At203ATV3(oSubModel:Getvalue("GRD_ABBREC"),lCheckin,lCheckout)	
		lRet := .T.
	EndIf
ElseIf lExistTV3 .And. At203ATV3(oSubModel:Getvalue("GRD_ABBREC"),lCheckin,lCheckout)
	lRet := .T.
Else
	If lCheckin .Or. lCheckout
		aAreaABB	:= ABB->(GetArea())
		DbSelectArea("ABB")
		ABB->(dbGoTo(oSubModel:Getvalue("GRD_ABBREC")))
		If lCheckin
			cCpoRef := ABB->ABB_HRCHIN
		Else 
			cCpoRef := ABB->ABB_HRCOUT
		EndIf 

		If At203AAlt(oSubModel,cCampo,cCpoRef)
			lRet := .T.
		EndIf 
		
		RestArea(aAreaABB)
	EndIf 
EndIf 

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At203WhJust()

Verifica se os campos de checkin ou checkout foram alterados para habilitar o campo de justificativa

@author Luiz Gabriel
@since  27/09/2022
/*/
//------------------------------------------------------------------------------
Function At203WhJust(cForm)
Local lRet 		:= .F.
Local oModel 	:= FwModelActive()
Local oSubModel	:= Nil
Local aAreaABB	:= Nil

If VALTYPE(oModel) == "O"
	oSubModel := oModel:GetModel(cForm)
	If VALTYPE(oSubModel) == "O"
		aAreaABB	:= ABB->(GetArea())
		DbSelectArea("ABB")
		ABB->(dbGoTo(oSubModel:Getvalue("GRD_ABBREC")))

		lRet := At203AAlt(oSubModel,"GRD_INREAL",ABB->ABB_HRCHIN)
		
		If !lRet
			lRet := At203AAlt(oSubModel,"GRD_OUTREAL",ABB->ABB_HRCOUT)
		EndIf 

		RestArea(aAreaABB)
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At203AAlt()

Verifica se houve alguma alteração nos campos de checkin ou checkout

@author Luiz Gabriel
@since  27/09/2022
/*/
//------------------------------------------------------------------------------
Static Function At203AAlt(oMdlGRD,cCampo,cCpoRef)
Local lRet := .F. 

If cCpoRef <> oMdlGRD:GetValue(cCampo)
	lRet := .T.
EndIf 

Return lRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} At203AMnt()

Registra alteração no registro de marcação Carol

@author flavio.vicco
@since  16/01/2023
/*/
//------------------------------------------------------------------------------
Static Function At203AMnt(cMarCod)

DbSelectArea("T40")
T40->(dbSetOrder(1)) //T40_FILIAL+T40_VALCON
If T40->(dbSeek(xFilial("T40")+cMarCod))
	RecLock("T40")
	T40->T40_AGEINT := "S"
	T40->(MsUnlock())
EndIf

Return
