#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "GPEA061.CH"

STATIC _CENTGPE_
STATIC _CLOCAL_
STATIC _CCODTFF_
STATIC _CTURNO_
STATIC _CESCALA_
STATIC _OMDLTFF_
STATIC _REGTUR_
STATIC _ATURNO
STATIC _CPLAN_ 
Static aBenefEx := {}
Static aBenRev	:= {}
Static _lFacilit_
Static _CCODTXS_
//------------------------------------------------------------------------------
/*/{Protheus.doc} AT352TDX()

Vinculo de beneficios

@sample 	AT352TDX() 
@param		ExpC1 Entidade
@return	ExpL	Verdadeiro / Falso
@since		18/05/2015       
@version	P12   
/*/
//------------------------------------------------------------------------------
Function AT352TDX(oMdl,lModo) 

Local oMdlTFL		:= Nil
Local oMdlTFF		:= Nil
Local nOperation	:= Nil
Local lOk			:= .T.
Local cCodCri
Local aRevisao	:= {}

Default lModo := .F.

_lFacilit_ := lModo

If _lFacilit_
	oMdlTFF		:= oMdl:GetModel("TXSDETAIL")
	nOperation	:= oMdl:GetOperation()
Else 
	oMdlTFL		:= oMdl:GetModel("TFL_LOC")
	oMdlTFF		:= oMdl:GetModel("TFF_RH")
	nOperation	:= oMdl:GetOperation()
EndIf

_CENTGPE_ := 'TDX' 
_OMDLTFF_ := oMdlTFF
_REGTUR_  := 0
_ATURNO_  := {}
_CPLAN_   := ''

cCodCri := fRetCriter(,_CENTGPE_)	// Retorna o codigo do criterio ativo

IF nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_INSERT

	// Valida local de atendimento
	IF !_lFacilit_ .And. Empty(oMdlTFL:GetValue("TFL_LOCAL"))
		lOk := .F.
		Help(,,'TECA352',,STR0043,1,0)	//"Local de Atendimento n�o informado."
	ENDIF

	// Valida turno
	IF lOk .And. !_lFacilit_
		IF Empty(oMdlTFF:GetValue("TFF_ESCALA"))
			IF Empty(oMdlTFF:GetValue("TFF_TURNO"))
				lOk := .F.
				Help(,,'TECA352',,STR0044,1,0)	//"O c�digo do turno ou o c�digo da escala deve ser informado."
			ELSE
				_CTURNO_  := oMdlTFF:GetValue("TFF_TURNO")
				_CESCALA_ := ''
			ENDIF
		ELSE
			_CTURNO_  := ''
			_CESCALA_ := oMdlTFF:GetValue("TFF_ESCALA")
		ENDIF
	ElseIf lOk .And. _lFacilit_ 
		If Empty(oMdlTFF:GetValue("TXS_ESCALA"))
			If Empty(oMdlTFF:GetValue("TXS_TURNO"))
				lOk := .F.
				Help(,,'TECA352',,STR0044,1,0)	//"O c�digo do turno ou o c�digo da escala deve ser informado."
			Else
				_CTURNO_  := oMdlTFF:GetValue("TXS_TURNO")
				_CESCALA_ := ''
			EndIf
		Else
			_CTURNO_  := ''
			_CESCALA_ := oMdlTFF:GetValue("TXS_ESCALA")
		EndIf
	EndIf	

	IF lOk
		DbSelectArea("SJS")
		SJS->(DbSetOrder(1)) //JS_FILIAL, JS_CDAGRUP, JS_TABELA, JS_SEQ
		SJS->(DbSeek(xFilial("SJS")+cCodCri+_CENTGPE_))

		If !_lFacilit_
			_CLOCAL_  := oMdlTFL:GetValue("TFL_LOCAL")
			_CCODTFF_ := oMdlTFF:GetValue("TFF_COD")
			_CPLAN_   := oMdlTFL:GetValue("TFL_PLAN")
		Else 
			_CCODTXS_ := oMdlTFF:GetValue("TXS_CODIGO")
		EndIf	
		
		aRevisao  := AT870GETRE()
		
		// Verifica se o contrato do orcamento de servicos ainda nao foi gerado
		IF _lFacilit_ .Or. Empty(oMdlTFF:GetValue("TFF_CONTRT"))
			FWExecView(STR0002,"VIEWDEF.TECA352", MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) //"Beneficios"
		ELSE
			IF Len(aRevisao) > 0
				// Se for revisao
				IF aRevisao[1][1]
					// Aditivo
					IF aRevisao[1][2] == '1'
						// Alteracao permitido somente para item do RH de um novo local de pagamento
						IF Empty(_CPLAN_)
							FWExecView(STR0002,"VIEWDEF.TECA352", MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) //"Beneficios"						
						ELSE
							FWExecView(STR0002,"VIEWDEF.TECA352", MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) //"Beneficios"
						ENDIF
					ELSE
						FWExecView(STR0002,"VIEWDEF.TECA352", MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) //"Beneficios"
					ENDIF
				ELSE
					FWExecView(STR0002,"VIEWDEF.TECA352", MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) //"Beneficios"
				ENDIF
			ELSE
				FWExecView(STR0002,"VIEWDEF.TECA352", MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) //"Beneficios"
			ENDIF
		ENDIF
	ENDIF
ELSE
	IF !_lFacilit_
		IF Empty(oMdlTFF:GetValue("TFF_ESCALA"))
			IF ! Empty(oMdlTFF:GetValue("TFF_TURNO"))
				_CTURNO_  := oMdlTFF:GetValue("TFF_TURNO")
				_CESCALA_ := ''
			ENDIF
		ELSE
			_CTURNO_  := ''
			_CESCALA_ := oMdlTFF:GetValue("TFF_ESCALA")
		ENDIF
	ElseIf lOk .And. _lFacilit_ 
		IF Empty(oMdlTFF:GetValue("TXS_ESCALA"))
			IF ! Empty(oMdlTFF:GetValue("TXS_TURNO"))
				_CTURNO_  := oMdlTFF:GetValue("TXS_TURNO")
				_CESCALA_ := ''
			ENDIF
		ELSE
			_CTURNO_  := ''
			_CESCALA_ := oMdlTFF:GetValue("TXS_ESCALA")
		ENDIF
	EndIf

	DbSelectArea("SJS")
	SJS->(DbSetOrder(1)) //JS_FILIAL, JS_CDAGRUP, JS_TABELA, JS_SEQ
	SJS->(DbSeek(xFilial("SJS")+cCodCri+_CENTGPE_))
	If !_lFacilit_
		_CLOCAL_  := oMdlTFL:GetValue("TFL_LOCAL")
		_CCODTFF_ := oMdlTFF:GetValue("TFF_COD")
	Else 
		_CCODTXS_ := oMdlTFF:GetValue("TXS_CODIGO")
	EndIf 	
	FWExecView(STR0002,"VIEWDEF.TECA352", MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) //"Beneficios"
ENDIF

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Vinculo de Beneficios

@Return 	nil
@author	Servi�os
@since 		18/05/2015
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel   := fwloadModel("GPEA061")
Local bLoadTMP := { |oModel| At352FIL(1, cCodCri, cSeqAtu, '', oModel ) }
Local bLoadTUR := { |oModel| At352TUR(oModel) }
Local bLoadSLY := { |oModel| At352FIL(2, cCodCri, cSeqAtu, cChavEnt, oModel ) }

Local oStruSJS := FWFormModelStruct():New()
Local oStruTMP := FWFormStruct(1,"SLY")
Local oStruZZY := FWFormModelStruct():New()
Local oStruSLY := oModel:GetModel("GPEA061_SLY"):getstruct()//FWFormStruct(1,"SLY")

Local cCodCri
Local cChavEnt := Space(TAMSX3("LY_CHVENT")[1])	// Chave do Beneficio
Local cSeqAtu  := Space(TAMSX3("JS_SEQ")[1])		// Sequencia da Criterio da Entidade
Local cLocal   := Space(TAMSX3("TFF_LOCAL")[1])
Local cCodTFF  := Space(TAMSX3("TFF_COD")[1])
Local cTurno   := Space(TAMSX3("TFF_TURNO")[1])
LocaL cEscala  := Space(TAMSX3("TFF_ESCALA")[1])

Private cSeqAtu := ''

If VALTYPE(_CENTGPE_) == 'U'
	_CENTGPE_ := 'TDX'
EndIf

cCodCri  := fRetCriter(,_CENTGPE_)	// Retorna o codigo do criterio ativo

DbSelectArea("SJS")
SJS->(DbSetOrder(1)) //JS_FILIAL, JS_CDAGRUP, JS_TABELA, JS_SEQ
SJS->(DbSeek(xFilial("SJS")+cCodCri+_CENTGPE_))
cSeqAtu := SJS->JS_SEQ

cLocal  := _CLOCAL_
cCodTFF := _CCODTFF_
cTurno  := _CTURNO_
cEscala := _CESCALA_

// Carrega estrutura da entidade
oStruSJS:AddTable("ZZZ",{},STR0003) // "Entidades"
At352Stru( .F., oStruSJS, "ZZZ", .T. )

// Legenda Vistoria Tecnica

oStruTMP:AddField(	AllTrim("")			,;  	// [01] C Titulo do campo
						AllTrim(STR0003)		,;   	// [02] C ToolTip do campo "Legenda"
						"LY_LEGEND" 			,;    	// [03] C identificador (ID) do Field
						"C" 					,;    	// [04] C Tipo do campo
						15 						,;    	// [05] N Tamanho do campo
						0 						,;    	// [06] N Decimal do campo
						Nil 					,;    	// [07] B Code-block de valida��o do campo
						Nil						,;    	// [08] B Code-block de valida��o When do campo
						Nil 					,;    	// [09] A Lista de valores permitido do campo
                  	Nil 					,;  	// [10] L Indica se o campo tem preenchimento obrigat�rio
						{|| "BR_VERMELHO"}	,;   	// [11] B Code-block de inicializacao do campo
						Nil 					,;  	// [12] L Indica se trata de um campo chave
						Nil 					,;    	// [13] L Indica se o campo pode receber valor em uma opera��o de update.
						.T. )              			// [14] L Indica se o campo � virtual

// Carrega estrutura do turno
oStruZZY:AddTable("ZZY",{"ZZY_CHVENT"},"Turnos") // "Turnos"
At352Stru( .F., oStruZZY, "ZZY", .T. )

// Cria o inicializador padrao
oStruSJS:SetProperty("ZZZ_ENTID",MODEL_FIELD_INIT,{||At352CPL("ZZZ_ENTID") })

// Cria o inicializador padrao dos beneficios (VINCULO)
oStruSLY:SetProperty("LY_FILIAL",MODEL_FIELD_INIT,{||At352CPL("LY_FILIAL") })
oStruSLY:SetProperty("LY_AGRUP",MODEL_FIELD_INIT,{||At352CPL("LY_AGRUP") })
oStruSLY:SetProperty("LY_ALIAS",MODEL_FIELD_INIT,{||At352CPL("LY_ALIAS") })
oStruSLY:SetProperty("LY_FILENT",MODEL_FIELD_INIT,{||At352CPL("LY_FILENT") })
oStruSLY:SetProperty("LY_CHVENT",MODEL_FIELD_INIT,{||At352CPL("LY_CHVENT",oModel) })
oStruSLY:SetProperty("LY_DESCTIP",MODEL_FIELD_INIT,{ || "" })
oStruSLY:SetProperty("LY_DESBEN",MODEL_FIELD_INIT,{ || "" })

oStruSLY:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)

oStruSLY:SetProperty('LY_TIPO'  ,MODEL_FIELD_WHEN ,{|oModel|At352Res(oModel,_CPLAN_)})
oStruSLY:SetProperty('LY_CODIGO',MODEL_FIELD_WHEN ,{|oModel|At352Res(oModel,_CPLAN_)})
oStruSLY:SetProperty('LY_DTINI' ,MODEL_FIELD_WHEN ,{|oModel|At352Res(oModel,_CPLAN_)})

oStruZZY:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)

oStruTMP:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
oModel := MPFormModel():New("TECA352", /*bPreValid*/, /*bTudoOK*/, {|oModel| At352Cmt( oModel ) }/*bCommiM040*/, /*bCancel*/ )
oModel:SetDescription(STR0002) // "Crit�rios de benef�icios"

oModel:AddFields("SJSMASTER", /*cOwner*/, oStruSJS , /*Pre-Validacao*/,/*Pos-Validacao*/,{||})

//GRIDS - Beneficios Vinculados
oModel:AddGrid("TMPDETAIL", "SJSMASTER" , oStruTMP,/*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,bLoadTMP/*bLoad*/)
oModel:GetModel("TMPDETAIL"):SetDescription(STR0030)// "Beneficios Vinculados"
oModel:GetModel("TMPDETAIL"):SetOptional(.T.)
oModel:GetModel("TMPDETAIL"):SetOnlyQuery(.T.)  //Seta para n�o realizar a grava��o da tabela SLY

//GRIDS - Turnos
oModel:AddGrid("ZZYDETAIL", "SJSMASTER" , oStruZZY,/*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,bLoadTUR/*bLoad*/)
oModel:GetModel("ZZYDETAIL"):SetDescription(STR0045)// "Turnos"

//GRIDS - Beneficios
oModel:AddGrid("GPEA061_SLY", "ZZYDETAIL" , oStruSLY,/*bLinePre*/, { |oModel| Iif(_lFacilit_,.T.,SLY_LinhaOK(oModel))}/* bLinePost*/, /*bPre*/,/*bPost*/,bLoadSLY/*bLoad*/)
oModel:GetModel("GPEA061_SLY"):SetDescription(STR0012)// "Beneficios"
oModel:GetModel( 'GPEA061_SLY'):SetOptional( .T. )

oModel:SetRelation( "GPEA061_SLY", {{ "LY_CHVENT", "ZZY_CHVENT" }}, "LY_CHVENT" )

oModel:SetPrimaryKey({})
oModel:SetVldActivate( {|oModel| At352Vld(oModel)} ) 
oModel:SetActivate( {|oModel| InitDados(oModel) } )

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Defini��o da interface
@since   	04/05/2015
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView   := Nil
Local oModel  := ModelDef()
Local oStruSJS
Local oStruTMP
Local oStruZZY
Local oStruSLY
Local aCamSLY  := {}
Local aCampos  := {}
Local nL         := 0
Local cX3Custo   := ""
Local cCamSLY    := ""

// Carrega estrutura da Entidade
oStruSJS := FWFormViewStruct():New()
At352Stru( .F., oStruSJS, "ZZZ", .F. )

aCamSLY :=  FWSX3Util():GetAllFields( 'SLY' ,.T. )

For nL := 1 to len(aCamSLY)
	cX3Custo := GetSx3Cache(aCamSLY[nL],"X3_PROPRI")
	iF  (aCamSLY[nL] $ ("LY_TIPO|LY_DESCTIP|LY_CODIGO|LY_DESBEN|LY_PGDUT|LY_PGSAB|LY_PGDOM|LY_PGFER|LY_PGSUBS|LY_PGFALT|LY_PGAFAS|LY_PGVAC|LY_DIAS|LY_DTINI|LY_DTFIM") .Or. cX3Custo == "U") 
			cCamSLY += aCamSLY[nL] + "+"
			AADD(aCampos,{aCamSLY[nL]})
	Endif
Next nL

cCamSLY :=  Left(cCamSLY,Len(cCamSLY)-1 )

oStruTMP := FWFormStruct(2, 'SLY', {|cCpo| AllTrim(cCpo)$cCamSLY})
oStruSLY := FWFormStruct(2, 'SLY', {|cCpo| AllTrim(cCpo)$cCamSLY})

// Carrega estrutura do Turno
oStruZZY := FWFormViewStruct():New()
At352Stru( .F., oStruZZY, "ZZY", .F. )

oStruSLY:SetProperty('LY_TIPO' , MVC_VIEW_CANCHANGE,.t. )

// Legenda Vistoria Tecnica

oStruTMP:AddField(	"LY_LEGEND" 			,;	// [01] C Nome do Campo
						"01" 					,; 	// [02] C Ordem
						AllTrim("")			,; 	// [03] C Titulo do campo
						AllTrim(STR0031)		,; 	// [04] C Descri��o do campo "Legenda"
						{STR0031} 	   			,; 	// [05] A Array com Help
						"C" 					,; 	// [06] C Tipo do campo
						"@BMP" 				,; 	// [07] C Picture
						Nil 					,; 	// [08] B Bloco de Picture Var
						"" 						,; 	// [09] C Consulta F3
						.F. 					,;	// [10] L Indica se o campo � evit�vel
                    	Nil 					,; 	// [11] C Pasta do campo
                    	Nil 					,;	// [12] C Agrupamento do campo
						Nil 					,; 	// [13] A Lista de valores permitido do campo (Combo)
						Nil 					,;	// [14] N Tamanho Maximo da maior op��o do combo
						Nil 					,;	// [15] C Inicializador de Browse
						.T. 					,;	// [16] L Indica se o campo � virtual
						Nil )               		// [17] C Picture Vari�vel 

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_SJS', oStruSJS, 'SJSMASTER')
oView:AddGrid('VIEW_TMP' , oStruTMP, 'TMPDETAIL')
oView:AddGrid('VIEW_SLY' , oStruSLY, 'GPEA061_SLY')
oView:AddGrid('VIEW_ZZY' , oStruZZY, 'ZZYDETAIL')

//Legenda
oView:AddUserButton(STR0031,"",{ || At352Leg()}) //"Legenda"

// Adiciona as vis�es na tela
oView:CreateHorizontalBox( 'TOP'    , 10 )
oView:CreateHorizontalBox( 'MIDDLE' , 35 )
oView:CreateHorizontalBox( 'MIDDLE2', 25 )
oView:CreateHorizontalBox( 'DOWN'   , 30 )

// Faz a amarra��o das VIEWs dos modelos com as divis�es na interface
oView:SetOwnerView('VIEW_SJS', 'TOP'    )

oView:SetOwnerView('VIEW_TMP', 'MIDDLE')
oView:EnableTitleView( "VIEW_TMP", STR0032 )	// "Benef�cios Superiores"

oView:SetOwnerView('VIEW_SLY', 'DOWN')
oView:EnableTitleView( "VIEW_SLY", STR0030 ) 	// "Benef�cios Vinculados"

oView:SetOwnerView('VIEW_ZZY', 'MIDDLE2')
oView:EnableTitleView( "VIEW_ZZY", STR0042 )	// "Turnos do Local de Atendimento"

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef
	Criacao do MenuDef.

@sample 	Menudef() 
@param		Nenhum
@return	 	aMenu, Array, Op��o para sele��o no Menu
@since		04/05/2015       
@version	P12   
/*/
//------------------------------------------------------------------------------
Static Function Menudef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0006 ACTION 'PesqBrw'       OPERATION 1 ACCESS 0	// "Pesquisar"
ADD OPTION aRotina TITLE STR0033 ACTION 'VIEWDEF.TECA352' OPERATION 4 ACCESS 0	// "Alterar"

Return (aRotina)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At352Stru
Carrega as estruturas para os grids da aloca��o

@sample 	At352Stru( oStruct, cTipo, lView )

@param		oStruct - Estrutura a ser alterada com os novos campos
@param		oPanel - Painel onde dever� ser criado e exibido o bot�o
@param		oPanel - Painel onde dever� ser criado e exibido o bot�o
	
@return	Nil 
@author	Servi�os
@since		05/05/2015       
@version	P12   	
/*/
//------------------------------------------------------------------------------
Static Function At352Stru( lEstr, oStruct, cTipo, lModel )
 
Local aCols := {}

Local nI, xRet

Default oStruct := Nil
Default lModel  := .T.

If lEstr

	xRet := {}	
	For nI:=1 To 1
		aAdd( aCols, Nil )
	Next nI	
	aAdd( xRet, { 1, aCols } )
		 
Else 

	If lModel
		If cTipo == "ZZZ"
			oStruct:AddField(	STR0020					,; 	// [01] C Titulo do campo
								STR0020					,; 	// [02] C ToolTip do campo
								"ZZZ_ENTID" 				,; 	// [03] C identificador (ID) do Field
								"C" 						,; 	// [04] C Tipo do campo
								30							,; 	// [05] N Tamanho do campo
								0 							,; 	// [06] N Decimal do campo
								Nil 						,; 	// [07] B Code-block de valida��o do campo
								Nil							,; 	// [08] B Code-block de valida��o When do campo
								Nil 						,; 	// [09] A Lista de valores permitido do campo
			                 	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigat�rio
								Nil							,; 	// [11] B Code-block de inicializacao do campo
								Nil 						,;	// [12] L Indica se trata de um campo chave
								.F.		 					,; 	// [13] L Indica se o campo pode receber valor em uma opera��o de update.
								.T. )  	            		// [14] L Indica se o campo � virtual								
		EndIf
		IF cTipo == "ZZY"

			oStruct:AddIndex( 1				,;	//[01] Ordem do indice
			                  "1"			,;	//[02] ID
			                  "ZZY_CHVENT"	,;	//[03] Chave do indice
			                  STR0046		,;	//[04] Descricao do indice
			                  ""				,;	//[05] Expressao de lookUp dos campos de indice
			                  ""				,;	//[06] Nickname do indice
			                  .T. )				//[07] Indica se o indice pode ser utilizado pela interface

			oStruct:AddField(	STR0046					,; 	// [01] C Titulo do campo
								STR0046					,; 	// [02] C ToolTip do campo
								"ZZY_CHVENT" 				,; 	// [03] C identificador (ID) do Field
								"C" 						,; 	// [04] C Tipo do campo
								TAMSX3("LY_CHVENT")[1]	,; 	// [05] N Tamanho do campo
								0 							,; 	// [06] N Decimal do campo
								Nil 						,; 	// [07] B Code-block de valida��o do campo
								Nil							,; 	// [08] B Code-block de valida��o When do campo
								Nil 						,; 	// [09] A Lista de valores permitido do campo
			                 	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigat�rio
								Nil							,; 	// [11] B Code-block de inicializacao do campo
								.T. 						,;	// [12] L Indica se trata de um campo chave
								.F.		 					,; 	// [13] L Indica se o campo pode receber valor em uma opera��o de update.
								.T. )  	            		// [14] L Indica se o campo � virtual

			oStruct:AddField(	STR0047					,; 	// [01] C Titulo do campo
								STR0047					,; 	// [02] C ToolTip do campo "Legenda"
								"ZZY_CODTFF" 				,; 	// [03] C identificador (ID) do Field
								"C" 						,; 	// [04] C Tipo do campo
								TAMSX3("TFF_COD")[1]		,; 	// [05] N Tamanho do campo
								0 							,; 	// [06] N Decimal do campo
								Nil 						,; 	// [07] B Code-block de valida��o do campo
								Nil							,; 	// [08] B Code-block de valida��o When do campo
								Nil 						,; 	// [09] A Lista de valores permitido do campo
			                 	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigat�rio
								Nil							,; 	// [11] B Code-block de inicializacao do campo
								Nil 						,;	// [12] L Indica se trata de um campo chave
								.F.		 					,; 	// [13] L Indica se o campo pode receber valor em uma opera��o de update.
								.T. )  	            		// [14] L Indica se o campo � virtual
														
			oStruct:AddField(	STR0045					,; 	// [01] C Titulo do campo
								STR0045					,; 	// [02] C ToolTip do campo 
								"ZZY_TURNO" 				,; 	// [03] C identificador (ID) do Field
								"C" 						,; 	// [04] C Tipo do campo
								TAMSX3("R6_TURNO")[1]	,; 	// [05] N Tamanho do campo
								0 							,; 	// [06] N Decimal do campo
								Nil 						,; 	// [07] B Code-block de valida��o do campo
								Nil							,; 	// [08] B Code-block de valida��o When do campo
								Nil 						,; 	// [09] A Lista de valores permitido do campo
			                 	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigat�rio
								Nil							,; 	// [11] B Code-block de inicializacao do campo
								Nil 						,;	// [12] L Indica se trata de um campo chave
								.F.		 					,; 	// [13] L Indica se o campo pode receber valor em uma opera��o de update.
								.T. )  	            		// [14] L Indica se o campo � virtual

			oStruct:AddField(	STR0048				,; 	// [01] C Titulo do campo
								STR0048				,; 	// [02] C ToolTip do campo "Legenda"
								"ZZY_DTURNO" 				,; 	// [03] C identificador (ID) do Field
								"C" 						,; 	// [04] C Tipo do campo
								TAMSX3("R6_DESC")[1]		,; 	// [05] N Tamanho do campo
								0 							,; 	// [06] N Decimal do campo
								Nil 						,; 	// [07] B Code-block de valida��o do campo
								Nil							,; 	// [08] B Code-block de valida��o When do campo
								Nil 						,; 	// [09] A Lista de valores permitido do campo
			                 	Nil 						,;	// [10] L Indica se o campo tem preenchimento obrigat�rio
								Nil							,; 	// [11] B Code-block de inicializacao do campo
								Nil 						,;	// [12] L Indica se trata de um campo chave
								.F.		 					,; 	// [13] L Indica se o campo pode receber valor em uma opera��o de update.
								.T. )  	            		// [14] L Indica se o campo � virtual																						
	                  
		ENDIF	                    		
	Else
		If cTipo == "ZZZ"
			oStruct:AddField(	"ZZZ_ENTID" 	,;	// [01] C Nome do Campo
								"01" 			,; 	// [02] C Ordem
								STR0020		,; 	// [03] C Titulo do campo
								STR0020		,; 	// [04] C Descri��o do campo
								Nil 	   		,; 	// [05] A Array com Help
								"C" 			,; 	// [06] C Tipo do campo
								"" 				,; 	// [07] C Picture
								Nil 			,; 	// [08] B Bloco de Picture Var
								"" 				,; 	// [09] C Consulta F3
								.F. 			,;	// [10] L Indica se o campo � evit�vel
			                 	Nil 			,; 	// [11] C Pasta do campo
			                 	Nil 			,;	// [12] C Agrupamento do campo
								Nil 			,; 	// [13] A Lista de valores permitido do campo (Combo)
								Nil 			,;	// [14] N Tamanho Maximo da maior op��o do combo
								Nil 			,;	// [15] C Inicializador de Browse
								.T. 			,;	// [16] L Indica se o campo � virtual
								Nil )        		// [17] C Picture Vari�vel 
		EndIf

		If cTipo == "ZZY"
			oStruct:AddField(	"ZZY_TURNO" 	,;	// [01] C Nome do Campo
								"01" 			,; 	// [02] C Ordem
								STR0047		,; 	// [03] C Titulo do campo
								STR0047		,; 	// [04] C Descri��o do campo "Legenda"
								Nil 	   		,; 	// [05] A Array com Help
								"C" 			,; 	// [06] C Tipo do campo
								"" 				,; 	// [07] C Picture
								Nil 			,; 	// [08] B Bloco de Picture Var
								"" 				,; 	// [09] C Consulta F3
								.F. 			,;	// [10] L Indica se o campo � evit�vel
			                 	Nil 			,; 	// [11] C Pasta do campo
			                 	Nil 			,;	// [12] C Agrupamento do campo
								Nil 			,; 	// [13] A Lista de valores permitido do campo (Combo)
								Nil 			,;	// [14] N Tamanho Maximo da maior op��o do combo
								Nil 			,;	// [15] C Inicializador de Browse
								.T. 			,;	// [16] L Indica se o campo � virtual
								Nil )        		// [17] C Picture Vari�vel	
																						
			oStruct:AddField(	"ZZY_DTURNO" 	,;	// [01] C Nome do Campo
								"02" 			,; 	// [02] C Ordem
								STR0048		,; 	// [03] C Titulo do campo
								STR0048		,; 	// [04] C Descri��o do campo "Legenda"
								Nil 	   		,; 	// [05] A Array com Help
								"C" 			,; 	// [06] C Tipo do campo
								"" 				,; 	// [07] C Picture
								Nil 			,; 	// [08] B Bloco de Picture Var
								"" 				,; 	// [09] C Consulta F3
								.F. 			,;	// [10] L Indica se o campo � evit�vel
			                 	Nil 			,; 	// [11] C Pasta do campo
			                 	Nil 			,;	// [12] C Agrupamento do campo
								Nil 			,; 	// [13] A Lista de valores permitido do campo (Combo)
								Nil 			,;	// [14] N Tamanho Maximo da maior op��o do combo
								Nil 			,;	// [15] C Inicializador de Browse
								.T. 			,;	// [16] L Indica se o campo � virtual
								Nil )        		// [17] C Picture Vari�vel															
		EndIf		
	EndIf	
		
EndIf	
	
Return(xRet)

/*/{Protheus.doc} At352Vld
Pre valida��o para a ativa��o do model

@since 05/05/2015
@version 12
@param oModel, objeto, Model
@return lRet

/*/
Static Function At352Vld(oModel)

Local lRet    := .T.
Local lTecxRh := SuperGetMV("MV_TECXRH",,.F.)	// Define se o Gestao de Servico esta integrado com Rh do Microsiga Protheus.
Local cCodCri := fRetCriter(,_CENTGPE_)					// Retorna o codigo do criterio ativo

IF !lTecxRh
	Help(,,'TECA352',,STR0034,1,0)//"O par�metro de sistema de integra��o com o m�dulo de RH (MV_TECXRH) dever� estar habilitado."
	lRet := .F.
ENDIF

IF lRet .AND. Empty(cCodCri)
	Help(,,'TECA352',,STR0035,1,0)//"N�o existe um crit�rio de benef�cios ativo no m�dulo SIGAGPE."
	lRet := .F.
ENDIF

IF lRet
	DbSelectArea("SJS")
	SJS->(DbSetOrder(1)) //JS_FILIAL, JS_CDAGRUP, JS_TABELA, JS_SEQ
	IF !SJS->(DbSeek(xFilial("SJS")+cCodCri+_CENTGPE_))
	   Help(,,'TECA352',, I18N( STR0020 + ' #1 ' + STR0036,{_CENTGPE_}),1,0) //'Entidade #1[Entidade]# n�o cadastrada no sequenciamento de crit�rio de benef�cios do m�dulo SIGAGPE.'
		lRet := .F.	
	ENDIF
ENDIF

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados()
Inicializa as informa��es da visualiza��o da escala

@sample 	InitDados()

@param  	oModel, Objeto, objeto geral do model que ser� alterado

@author 	Servi�os
@since 		09/06/2014
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function InitDados(oModel)

Local oMdlSJS := oModel:GetModel("SJSMASTER")
Local oMdlTMP := oModel:GetModel("TMPDETAIL")
Local oMdlZZY := oModel:GetModel("ZZYDETAIL")
Local oMdlSLY := oModel:GetModel("GPEA061_SLY")
Local nI      := 0

If oModel:GetOperation() <> MODEL_OPERATION_INSERT
	FOR nI := 1 To oMdlTMP:Length()
		oMdlTMP:GoLine(nI)
		If ! Empty(oMdlTMP:GetValue("LY_CODIGO"))
			oMdlTMP:LoadValue("LY_DESBEN" , fInitBen(oMdlTMP))
			oMdlTMP:LoadValue("LY_DESCTIP", fInitTip(oMdlTMP))
		EndIf
		
	NEXT nI
	
	FOR nI := 1 To oMdlSLY:Length()
		
		oMdlSLY:GoLine(nI)
		
		If ! Empty(oMdlSLY:GetValue("LY_CODIGO"))
			oMdlSLY:LoadValue("LY_DESBEN" , fInitBen(oMdlSLY))
			oMdlSLY:LoadValue("LY_DESCTIP", fInitTip(oMdlSLY))
		EndIf
		
	Next nI
EndIf

oMdlSJS:SetOnlyView(.T.)
oMdlTMP:SetOnlyView(.T.)
oMdlZZY:SetOnlyView(.T.)

Return(Nil)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At352FIL
Retorna a lista de beneficios

@sample 	At352FIL( nTipo, cCdAgrup, cSeqCri, cChvCri )

@param		nTipo		- Tipo da Sequencia
@param		cCdAgrup	- Codigo do Agrupamento
@param		cSeqCri	- Sequencia Atual da Entidade
@param		cChvCri	- Chave da Entidade
	
@return	aRet - Array com as informacoes dos beneficios
 
@author	Servi�os
@since		06/05/2015       
@version	P12   
/*/
//------------------------------------------------------------------------------
Function At352FIL( nTipo, cCdAgrup, cSeqCri, cChvEnt, oMdl )

Local aBenef    := {}
Local cAliasSLY := GetNextAlias()
Local cTabela   := _CENTGPE_
Local cTabFaci	:= ""
Local cWhere	:= "% 1=1 %"
Local nI        := 0
Local nX
Local nPosLeg   := aScan(oMdl:aHeader,{|x| x[2] = 'LY_LEGEND'})
Local nPosTAB   := aScan(oMdl:aHeader,{|x| x[2] = 'LY_ALIAS'})
Local nPosCHV   := ''

cChvEnt := ''

IF nTipo = 1 // Sequencia Superior

	// Filtra os Beneficios da Sequencia Superior
	BeginSql Alias cAliasSLY
		COLUMN LY_DTINI AS DATE
		COLUMN LY_DTFIM AS DATE
		SELECT	*
		FROM %table:SLY% SLY 
		JOIN %table:SJS% SJS ON
			SJS.JS_FILIAL = %xFilial:SJS% AND 
			SJS.JS_CDAGRUP = %Exp:cCdAgrup% AND
			SJS.JS_TABELA = SLY.LY_ALIAS AND
			SJS.JS_SEQ < %Exp:cSeqCri% AND
			SJS.%NotDel%
		WHERE 
			SLY.LY_FILIAL = %xFilial:SLY% AND 
			SLY.LY_AGRUP = %Exp:cCdAgrup% AND
			SLY.%NotDel%
		ORDER BY 
			SJS.JS_SEQ
 	EndSql

	aBenef := FwLoadByAlias( oMdl, cAliasSLY )

	FOR nI := 1 TO LEN(aBenef)
		DO CASE
			CASE aBenef[nI][2][nPosTab] == 'SM0'
				aBenef[nI][2][nPosLeg] := "BR_VERMELHO"
			CASE aBenef[nI][2][nPosTab] == 'SA1'
				aBenef[nI][2][nPosLeg] := "BR_VERDE"
			CASE aBenef[nI][2][nPosTab] == 'ABS'
				aBenef[nI][2][nPosLeg] := "BR_AMARELO"
		ENDCASE
	NEXT nI
	
ELSE

	IF _REGTUR_ == 0
		_REGTUR_ := 1
	ENDIF

	nPosCHV := Ascan(_ATURNO_,{|X| X[1] = _REGTUR_ })
	
	IF nPosCHV > 0
		cChvEnt := _ATURNO_[nPosCHV][2]
	ENDIF

	If _lFacilit_
		cTabFaci := "TXS"
	Else 
		cTabFaci := "TDX"
	EndIf 

	If !Empty(aBenefEx)
		cWhere := ""
		cWhere += " SLY.LY_FILIAL||SLY.LY_TIPO||SLY.LY_AGRUP||SLY.LY_ALIAS||SLY.LY_FILENT||SLY.LY_CHVENT||SLY.LY_CODIGO||SLY.LY_DTINI NOT IN ( "
		cWhere += " SELECT SLY.LY_FILIAL||SLY.LY_TIPO||SLY.LY_AGRUP||SLY.LY_ALIAS||SLY.LY_FILENT||SLY.LY_CHVENT||SLY.LY_CODIGO||SLY.LY_DTINI FROM " + RetSqlName("SLY") + " SLY "
		cWhere += " WHERE "
		cWhere += " SLY.LY_FILIAL||SLY.LY_TIPO||SLY.LY_AGRUP||SLY.LY_ALIAS||SLY.LY_FILENT||SLY.LY_CHVENT||SLY.LY_CODIGO||SLY.LY_DTINI IN ( "
		For nX := 1 To Len(aBenefEx)
			cWhere += "'" + aBenefEx[nX][1]
			cWhere += aBenefEx[nX][2]
			cWhere += aBenefEx[nX][3]
			cWhere += aBenefEx[nX][4]
			cWhere += aBenefEx[nX][5]
			cWhere += aBenefEx[nX][6]
			cWhere += aBenefEx[nX][7]
			cWhere += DToS(aBenefEx[nX][8]) + "',"
		Next nX
		cWhere := LEFT(cWhere, LEN(cWhere) - 1) + ")"
		cWhere  := "%" + cWhere + ") %"
	EndIf
	// Filtra os Beneficios da Sequencia Atual
	BeginSql Alias cAliasSLY
		COLUMN LY_DTINI AS DATE
		COLUMN LY_DTFIM AS DATE
		SELECT	SLY.*
		FROM %table:SLY% SLY 
		JOIN %table:SJS% SJS ON
			SJS.JS_FILIAL = %xFilial:SJS% AND 
			SJS.JS_CDAGRUP = %Exp:cCdAgrup% AND
			SJS.JS_SEQ = %Exp:cSeqCri% AND
			SJS.JS_TABELA = %Exp:cTabela% AND
			SJS.%NotDel%
		WHERE 
			SLY.LY_FILIAL = %xFilial:SLY% AND 
			SLY.LY_AGRUP = %Exp:cCdAgrup% AND
			SLY.LY_ALIAS = %Exp:cTabFaci% AND
			SLY.LY_CHVENT = %Exp:cChvEnt% AND
			SLY.%NotDel%
			AND %Exp:cWhere%
		ORDER BY LY_ALIAS
 	EndSql

	aBenef := FwLoadByAlias( oMdl, cAliasSLY )
	
	_REGTUR_ := _REGTUR_ + 1
ENDIF

DbSelectArea(cAliasSLY)
(cAliasSLY)->(DbCloseArea())

Return aBenef 

//------------------------------------------------------------------------------
/*/{Protheus.doc} At352TUR
Retorna os turnos do item do RH

@sample 	At352TUR(oModel)
@param		oModel    	- Modelo
	
@return	aRet - Array com as informacoes dos beneficios
 
@author	Servi�os
@since		06/05/2015       
@version	P12   
/*/
//------------------------------------------------------------------------------
Function At352TUR(_oModel)

Local aRet 	  := {}
Local aTurno    := {}
Local _cAlias_  := GetNextAlias()
Local cAliasTDX := ''
Local cEscala   := _CESCALA_
Local cCodTFF   := Iif(_lFacilit_,_CCODTXS_,_CCODTFF_)
Local cTurno    := _CTURNO_
Local oMdlZZY
Local nI        := 0
// garante preenchimento em forma de string quando valor Nil nas vari�veis static
Default cEscala := ""
Default cCodTFF := ""
Default cTurno := ""

// Buscar o Turno da Escala
IF ! Empty(cEscala)
	BeginSql Alias _cAlias_
		SELECT	DISTINCT %Exp:cCodTFF% || SR6.R6_TURNO AS ZZY_CHVENT
		    , SR6.R6_TURNO AS ZZY_TURNO
		    , SR6.R6_DESC AS ZZY_DTURNO
		    , %Exp:cCodTFF% AS ZZY_CODTFF
			FROM %table:TDX% TDX
			JOIN %table:SR6% SR6 ON R6_FILIAL = %xFilial:SR6% AND
			     R6_TURNO = TDX_TURNO AND
			     SR6.%NotDel%
			WHERE 
				TDX.TDX_FILIAL = %xFilial:TDX% AND 
				TDX.TDX_CODTDW = %Exp:cEscala% AND
				TDX.%NotDel%
			ORDER BY ZZY_CHVENT
	EndSql	
ELSE
	BeginSql Alias _cAlias_
		SELECT	%Exp:cCodTFF% || SR6.R6_TURNO AS ZZY_CHVENT
		    , SR6.R6_TURNO AS ZZY_TURNO
		    , SR6.R6_DESC AS ZZY_DTURNO
		    , %Exp:cCodTFF% AS ZZY_CODTFF
			FROM %table:SR6% SR6
			WHERE 
			     R6_FILIAL = %xFilial:SR6% AND
			     R6_TURNO = %Exp:cTurno% AND
			     SR6.%NotDel%
			ORDER BY ZZY_CHVENT
	EndSql		
ENDIF

// Carrega Array Auxiliar dos Turno
DO WHILE (_cAlias_)->(!Eof())
	nI := nI + 1
	Aadd(_ATURNO_,{nI,(_cAlias_)->(ZZY_CHVENT)})	
	(_cAlias_)->(DbSkip())
END 

aTurno := FwLoadByAlias( _oModel, _cAlias_ )

DbSelectArea(_cAlias_)
(_cAlias_)->(DbCloseArea())

Return aTurno

//------------------------------------------------------------------------------
/*/{Protheus.doc} At352ALEG
Legenda

@sample 	At352ALEG()
@author	Servi�os
@since		08/05/2015       
@version	P12   
/*/
//------------------------------------------------------------------------------
Function At352Leg()

Local oLegenda  :=  FWLegend():New()

oLegenda:Add("","BR_VERMELHO"	,STR0039)	// "Filial"
oLegenda:Add("","BR_VERDE"		,STR0040)	// "Cliente"
oLegenda:Add("","BR_AMARELO"	,STR0041)	// "Local de Pagamento"

oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} At352CPL()
Efetua a inicializa��o dos campos

@sample 	At352CPL(cCampo,oModel)
@param		cCampo	Caracter Nome do campo
@param		oModel	Objeto
@author	Servi�os
@since		26/06/2015       
@version	P12   
/*/
//------------------------------------------------------------------------------
Static Function At352CPL(cCampo,oModel)

Local cCodCri := fRetCriter(,_CENTGPE_)
Local cRet    := ''
Local oMdlZZY

DO CASE
	CASE cCampo == "ZZZ_ENTID"
		cRet := "TURNO DO LOCAL DE ATENDIMENTO"
	CASE cCampo == "LY_FILIAL"
		cRet := xFilial("SLY")
	CASE cCampo == "LY_AGRUP"
		cRet := cCodCri
	CASE cCampo == "LY_ALIAS"
		cRet := _CENTGPE_
	CASE cCampo == "LY_FILENT"
		cRet := xFilial("TFF")	
	CASE cCampo == "LY_CHVENT"
		oMdlZZY:= oModel:GetModel("ZZYDETAIL")
		cRet := oMdlZZY:GetValue("ZZY_CHVENT")
ENDCASE

RETURN cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At352Res()
Efetua a edi��o dos campos do item do RH

@sample 	At352Res(oModel,cPlan)
@param		oModel	Objeto
@param		cPlan	Caracter Codigo do Planilha
@author	Servi�os
@since		26/06/2015       
@version	P12   
/*/
//------------------------------------------------------------------------------
Static Function At352Res(oModel,cPlan)
Local lRet 	:= .T.
Local aRevis  := AT870GETRE() // Retorna os dados da revisao

// Caso alteracao
IF oModel:GETOPERATION() = MODEL_OPERATION_UPDATE
	IF !oModel:IsInserted()
		// Verifica se existe uma planilha ja cadastrada para o local de atendimento
		IF !Empty(cPlan)
			IF Len(aRevis) > 0
				// Se o tipo de revisao Realinhamento nao pode ser alterado
				IF aRevis[1][2] <> '1'
					lRet := .F.
				ENDIF
			ENDIF
		ENDIF
	ENDIF
ENDIF

RETURN lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} At352Sly(oModel)

Valida��o das datas dos beneficios na efetiva��o da revis�o do contrato	 

@sample     At870Sly(oModel) 

@return      

@author     servi�os
@since      01/09/2015
@version    P12
/*/
Function At352Sly(oMdl740)

Local lRet:= .F.
Local lOk			:= .T.
Local cCodCri
Local aRevisao	:= {}
Local oMdlSly:= Nil
Local oMdl352:= Nil
Local xI:=0
Local nI:=0
Local oMdlTFJ:=oMdl740:GetModel('TFJ_REFER')
Local oMdlTFF:=oMdl740:GetModel('TFF_RH')
Local oMdlTFL:=oMdl740:GetModel('TFL_LOC')
Local dDtFim:=""
Local cTurno:=""
Local tmpSLY:=""
Local cChave:=""

_CENTGPE_ := 'TDX' 
_REGTUR_  := 0
_ATURNO_  := {}
_CPLAN_   := ''

cCodCri := fRetCriter(,_CENTGPE_)	// Retorna o codigo do criterio ativo

IF Empty(oMdlTFF:GetValue("TFF_ESCALA"))
		IF ! Empty(oMdlTFF:GetValue("TFF_TURNO"))
			_CTURNO_  := oMdlTFF:GetValue("TFF_TURNO")
			_CESCALA_ := ''
		ENDIF
ELSE
	_CTURNO_  := ''
	_CESCALA_ := oMdlTFF:GetValue("TFF_ESCALA")
ENDIF

//Posiciona no model da TECA352
DbSelectArea("SJS")
SJS->(DbSetOrder(1)) //JS_FILIAL, JS_CDAGRUP, JS_TABELA, JS_SEQ
SJS->(DbSeek(xFilial("SJS")+cCodCri+_CENTGPE_))
	
_CLOCAL_  := oMdlTFL:GetValue("TFL_LOCAL")
_CCODTFF_ := oMdlTFF:GetValue("TFF_COD")

oMdl352:=FWLoadModel( 'TECA352' )
oMdl352:SetOperation(MODEL_OPERATION_UPDATE)
oMdl352:Activate()

oMdlSly:=oMdl352:GetModel('GPEA061_SLY')

For nI:= 1 to oMdlTFF:length()
	oMdlTFF:GoLine(nI)
	TFFDtFim:=oMdlTFF:GetValue("TFF_PERFIM")
	//se a TFF estiver encerrada altera a data final do recebimento dos beneficios
	If oMdlTFF:GetValue("TFF_ENCE") == '1'
		For xI:= 1 to oMdlSly:length()
			oMdlSly:GoLine(xI)
			//valida a datafim em rela��o a TFF
			If ! empty(oMdlSly:GetValue("LY_DTFIM"))
				If oMdlSly:GetValue("LY_DTFIM") > TFFDtFim
					oMdlSly:SetValue("LY_DTFIM",TFFDtFim )
				Endif
			Else
				oMdlSly:SetValue("LY_DTFIM",TFFDtFim )
			Endif
			lRet:=.T.
		Next xI
	Endif
	lRet:=.T.	 
Next nI

lRet := lRet .And. oMdl352:VldData() .And. oMdl352:CommitData()

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At352Cmt
@description Commit do modelo, realizado tratativa para quando for na revis�o n�o deletar a linha no or�amento anterior
@return aBenefEx
@author Augusto Albuquerque
@since  10/06/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At352Cmt( oModel )
Local lRet		:= .T.
Local lRevisa	:= IsInCallStack("At870Revis")
Local nX
Local oMdlSLY	:= oModel:GetModel('GPEA061_SLY')

If oModel:GetOperation() <> MODEL_OPERATION_DELETE .AND. lRevisa
	For nX := 1 to oMdlSly:length()
		oMdlSly:GoLine(nX)
		If SLY->(DbSeek(oMdlSly:GetValue("LY_FILIAL")+oMdlSly:GetValue("LY_TIPO")+oMdlSly:GetValue("LY_AGRUP")+oMdlSly:GetValue("LY_ALIAS")+oMdlSly:GetValue("LY_FILENT")+oMdlSly:GetValue("LY_CHVENT")+oMdlSly:GetValue("LY_CODIGO")+dTos(oMdlSly:GetValue("LY_DTINI"))))
			aAdd( aBenRev, {oMdlSly:IsDeleted(),;
							{ SLY->LY_FILIAL,oMdlSly:GetValue("LY_FILIAL") },;
							{ SLY->LY_TIPO	,oMdlSly:GetValue("LY_TIPO") },;
							{ SLY->LY_AGRUP	,oMdlSly:GetValue("LY_AGRUP") },;
							{ SLY->LY_ALIAS	,oMdlSly:GetValue("LY_ALIAS")},;
							{ SLY->LY_FILENT,oMdlSly:GetValue("LY_FILENT") },;
							{ SLY->LY_CHVENT,oMdlSly:GetValue("LY_CHVENT") },;
							{ SLY->LY_CODIGO,oMdlSly:GetValue("LY_CODIGO") },;
							{ SLY->LY_PGDUT	,oMdlSly:GetValue("LY_PGDUT") },;
							{ SLY->LY_PGSAB	,oMdlSly:GetValue("LY_PGSAB") },;
							{ SLY->LY_PGDOM	,oMdlSly:GetValue("LY_PGDOM") },;
							{ SLY->LY_PGFER	,oMdlSly:GetValue("LY_PGDOM") },;
							{ SLY->LY_PGSUBS,oMdlSly:GetValue("LY_PGSUBS") },;
							{ SLY->LY_PGFALT,oMdlSly:GetValue("LY_PGFALT") },;
							{ SLY->LY_PGVAC	,oMdlSly:GetValue("LY_PGVAC") },;
							{ SLY->LY_DIAS	,oMdlSly:GetValue("LY_DIAS") },;
							{ SLY->LY_DTINI	,oMdlSly:GetValue("LY_DTINI") },;
							{ SLY->LY_DTFIM	,oMdlSly:GetValue("LY_DTFIM") },;
							{ SLY->LY_PGAFAS,oMdlSly:GetValue("LY_PGAFAS")}})
		Else
			aAdd( aBenRev, {.T.} )
		Endif
		If oMdlSly:IsDeleted()
			AADD( aBenefEx, {oMdlSly:GetValue("LY_FILIAL"),;
							 oMdlSly:GetValue("LY_TIPO"),;
							 oMdlSly:GetValue("LY_AGRUP"),;
							 oMdlSly:GetValue("LY_ALIAS"),;
							 oMdlSly:GetValue("LY_FILENT"),;
							 oMdlSly:GetValue("LY_CHVENT"),;
							 oMdlSly:GetValue("LY_CODIGO"),;
							 oMdlSly:GetValue("LY_DTINI")})
			oMdlSly:UnDeleteLine()
		EndIf
	Next nX
EndIf

If _lFacilit_ .And. oMdlSly:GetValue("LY_ALIAS") <> "TXS"
	oMdlSly:LoadValue("LY_ALIAS","TXS")
EndIf 

lRet := FwFormCommit( oModel ) 

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At352LimpA
@description Limpa o Array estatico 
@return 
@author Augusto Albuquerque
@since  10/06/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At352LimpA()
aBenefEx := {}
aBenRev	:= {}
Return 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetABene
@description Retorna o array estatico
@return aBenefEx
@author Augusto Albuquerque
@since  10/06/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function GetABene()
Return aBenefEx

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetABene
@description Retorna o array estatico
@return aBenefEx
@author Augusto Albuquerque
@since  10/06/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function GetABenfs()
Return aBenRev

