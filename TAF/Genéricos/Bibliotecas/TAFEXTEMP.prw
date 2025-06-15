#Include 'Protheus.ch'
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFEXTEMP.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} xMnuExtmp
Funcao responsavel por retornar o MENU dos eventos extempor�neos

@param cMenu   - Caractere, Nome da Rotina
@param lExtemp - Log�co   , Define se mostrar� o bot�o de movimentos extempor�neos

@return	aRotina - Array com as opcoes de MENU

@author Denis R. de Oliveira / Alceu Pereira
@since 22/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function xMnuExtmp( cMenu, cAliasX, lExtemp )

	Local aRotina  as array
	Local aRotExcl as array
	Local cRecno   as char

	Default cMenu   := ""
	Default cAliasX := ""
	Default lExtemp := .T.

	aRotina  := {}
	aRotExcl := {}
	cRecno   := cValToChar( (cAliasX)->(Recno()) )

	ADD OPTION aRotina Title 'Visualizar' 			Action "VIEWDEF." + cMenu									OPERATION 2 ACCESS 0

	If lExtemp

		ADD OPTION aRotina Title 'Inclus�o Extp.' 		Action "EvtExtmp('A','" + cMenu + "','" + cRecno + "')" 	OPERATION 3 ACCESS 0
		ADD OPTION aRotina Title 'Retifica��o Extp.' 	Action "EvtExtmp('R','" + cMenu + "','" + cRecno + "')" 	OPERATION 4 ACCESS 0
		ADD OPTION aRotina Title 'Excluir Extp.' 		Action	""													OPERATION 5 ACCESS 0
		ADD OPTION aRotina Title "Ajuste de Recibo"		Action 'xFunAltRec("' + cAliasX + '")'						OPERATION 3 ACCESS 0

		//Grupo de op��es para exclus�o
		Aadd(aRotExcl,{"Excluir Registro"					, "EvtExtmp('E','" + cMenu + "','" + cRecno + "','1')"	, 0, 3, 0, Nil, Nil, Nil} ) 
		Aadd(aRotExcl,{"Desfazer Exclus�o"					, "EvtExtmp('E','" + cMenu + "','" + cRecno + "','2')"	, 0, 5, 0, Nil, Nil, Nil} ) 
		Aadd(aRotExcl,{"Visualizar Registro de Exclus�o"	, "EvtExtmp('E','" + cMenu + "','" + cRecno + "','3')"  , 0, 2, 0, Nil, Nil, Nil} )   

		aRotina[4][2] := aRotExcl
		
	EndIf

Return( aRotina )

//-----------------------------------------------------------------------------
/*/{Protheus.doc} EvtExtmp
Funcao que possibilita a chamada do evento extemporaneo no menu das rotinas 

@Return 

@Author Denis R. Oliveira / Alceu Pereira
@Since 22/02/2018
@Version 1.0
/*/
//-----------------------------------------------------------------------------
Function EvtExtmp( cTpExtmp, cMenu, cRecno, cTpExcl )

	Local nExView	as numeric

	Default cTpExtmp := ""
	Default cMenu    := ""
	Default cRecno   := ""
	Default cTpExcl  := ""

	nExView	:=	-1

	Eval( {|| nExView := GoExtemp( cTpExtmp, cMenu, cRecno, cTpExcl ), Nil })

Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} GoSetExtemp
Funcao que possibilita o evento extemporaneo para os eventos do eSocial 

@Return nExView

@Author Denis R. Oliveira / Alceu Pereira
@Since 22/02/2018
@Version 1.0
/*/
//-----------------------------------------------------------------------------
Static Function GoExtemp( cTpExtmp, cMenu, cRecno, cTpExcl ) 

	Local cTitulo     as char
	Local cAlsHist    as char
	Local cNomEvto    as char
	Local cStatEve    as char
	Local nOpera      as numeric
	Local nExView     as numeric
	Local nRecno      as numeric
	Local oModel      as object

	Private ALTERA
	Private INCLUI
	Private lGoExtemp as logical

	Default cTpExtmp := ""
	Default cMenu    := ""
	Default cRecno   := ""
	Default cTpExcl  := ""

	cTitulo   := ""
	cAlsHist  := TAFRotinas( cMenu, 1, .F., 2 )[3]
	cNomEvto  := TAFRotinas( cMenu, 1, .F., 2 )[4]			
	nOpera    := 0 //Opera��o a ser realizada 
	nExView   := -1
	nRecno    := 0
	oModel    := Nil
	lGoExtemp := .T.

	//Recebo o recno 
	nRecno	:= (cAlsHist)->(Recno())

	//Recebo o Model
	oModel	:= FWLoadModel(cMenu)

	//-- Inclus�o de Extempor�neo
	If cTpExtmp == "A" 

		//Posiciono no registro 
		(cAlsHist)->( DbGoTo(Val(cRecno)) )
		
		//Recebo o status do registro
		cStatEve	:= (cAlsHist)->&((cAlsHist) + "_STATUS")  

		If cStatEve $ "2|6"        

			Aviso(STR0001,STR0002,{STR0003})//("e-Social","Esta opera��o n�o � permitida para eventos aguardando retorno do Governo.",{"Ok"})

		ElseIf cStatEve == "4" 
			
			nOpera := MODEL_OPERATION_INSERT
			INCLUI := .T.
			ALTERA := .F.
			
			cTitulo	:= STR0004 + cNomEvto //"Inclus�o do Evento "
			
			oModel:SetOperation(4)
			oModel:Activate()
		
			//Efetuo a inclus�o do registro
			FWMsgRun(,{||nExView:=FWExecView(cTitulo,cMenu,nOpera,,{||.T.},,,,,,, oModel )},,"Executando Rotina do evento " + cNomEvto )
		Else
			Aviso(STR0001,STR0005,{STR0003}) //"e-Social","N�o � permitido incluir extempor�neo para eventos n�o trasmitidos com sucesso ao RET.",{"Ok"})
		EndIf

	//-- Retifica��o ou Exclus�o de Extempor�neo	
	Else

		//Posiciono no registro 
		(cAlsHist)->( DbGoTo(nRecno) )

		//Recebo o status do registro
		cStatEve	:= (cAlsHist)->&((cAlsHist) + "_STATUS")  

		If cTpExtmp == "1" .AND. cStatEve $ "2|6"        
			
			Aviso(STR0001,STR0002,{STR0003})//("e-Social","Esta opera��o n�o � permitida para eventos aguardando retorno do Governo.",{"Ok"})
		
		Else

			If cTpExtmp == "R"
			
				If cNomEvto == "S-2190" .AND. cStatEve == "4"
					Aviso(STR0001,STR0016,{STR0003}) //("e-Social","N�o � poss�vel retificar um evento S-2190 (Admiss�o de Trabalhador - Registro Preliminar) j� transmitido.",{"Ok"})
				Else
					nOpera := MODEL_OPERATION_UPDATE
					INCLUI := .F.
					ALTERA := .T.
					
					cTitulo	:= STR0007 + cNomEvto //"Altera��o do Evento "
				
					//Efetuo a altera��o no registro
					FWMsgRun(,{||nExView:=FWExecView(cTitulo,cMenu,nOpera,,{||.T.})},, STR0008 + cNomEvto ) //"Executando Rotina do evento "
				EndIf
			
			ElseIf cTpExtmp == "E"
			
				INCLUI := .F.
				ALTERA := .F.
			
				cTitulo	:= STR0009 + cNomEvto //"Exclus�o do Evento "
				
				//Efetuo a exclus�o no registro
				xTafVExc( cAlsHist, nRecno, Val(cTpExcl) )
		
			EndIf
			
		EndIf

	EndIf

Return( nExView )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafGrvExt
Funcao para Ser chamada genericamente antes de executar um commit de um modelo

@param	oModel  - Objeto do Model
		cModel  - Nome do Model
		cAliasX - Alias principal do Model

@return Nil

@Author Roberto Souza
@Author Denis R. Oliveira / Alceu Pereira
@Since 02/03/2018
@version 1.0

/*/
//-------------------------------------------------------------------
Function TafGrvExt( oModel, cModel, cAliasX )

	Local cEvtModel as char
	Local cEvento   as char
	Local cStatus   as char
	Local cAtivo    as char
	Local lEvtExtmp as logical
	Local dData     as date
	Local cProtul   as character

	Default oModel  := ""
	Default cModel  := ""
	Default cAliasX := ""

	If TafColumnPos( cAliasX + "_DINSIS" ) .AND. TAFColumnPos( cAliasX + "_STASEC" )	

		cEvtModel	:=	oModel:GetModel( "MODEL_" + cAliasX ):GetValue( (cAliasX) + "_EVENTO" )
			
		cEvento	:= (cAliasX)->&((cAliasX) + "_EVENTO" )
		cStatus	:= (cAliasX)->&((cAliasX) + "_STATUS" )
		cAtivo		:= (cAliasX)->&((cAliasX) + "_ATIVO" )
		
		lEvtExtmp	:= (cAliasX)->&((cAliasX) + "_STASEC" ) == "E"
		dData 		:= dDatabase
		
		oModel:LoadValue( cModel, cAliasX + "_DINSIS", dData )
		oModel:LoadValue( cModel, cAliasX + "_STASEC", "E" )
		
		If Empty(cEvtModel) .OR. !lEvtExtmp
			If !lEvtExtmp .AND. cAtivo == "1"
				If cEvtModel == "A"
					cProtul	:= (cAliasX)->&((cAliasX) + "_PROTUL" )
					oModel:LoadValue( cModel, cAliasX + "_EVENTO", "A" )
					oModel:LoadValue( cModel, cAliasX + "_PROTPN", cProtul ) 
				Else
					oModel:LoadValue( "MODEL_" + cAliasX, cAliasX + "_EVENTO", "I" )
					oModel:LoadValue( cModel, cAliasX + "_PROTPN", "" ) 
				EndIf
			ElseIf cStatus == "4"
				oModel:LoadValue( "MODEL_" + cAliasX, cAliasX + "_EVENTO", "R" )
			EndIf
		EndIf
		
		//Incluso tratamento para caso o extempor�neo seja S-2205 ou S-2206
		If cModel $ "|MODEL_T1V|MODEL_T1U|MODEL_T0F|MODEL_V73|MODEL_V76|MODEL_V77|MODEL_V78"
		
			oModel:LoadValue( cModel, cAliasX + "_ATIVO" , "1" )
		
		Else
		
			oModel:LoadValue( cModel, cAliasX + "_ATIVO" , "2" )
		
		EndIf

	EndIf	

Return( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} xTafExtmp

Funcao para verificar se a funcionalidade de eventos extemporaneos esta habilitada

@Param:  None
@Return: lRet			
				.T. Para validacao OK
				.F. Para validacao NAO OK

@author Roberto Souza
@since 04/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function xTafExtmp()
	
	Local lRet := .F.
		
	lRet := TafColumnPos( "T1V_STASEC" ) .And. TafColumnPos( "T1U_STASEC" ) .And. TafColumnPos( "C9V_STASEC" ) .And. TafColumnPos( "CM6_STASEC" )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} xNewHisAlt

Funcao para criar a tela de historico de alteracoes do registro.
O registro a ser filtrado eh o mesmo selecionado pelo usuario na Grid
Similar a xFunHisAlt, com as altera��es de novas colunas, legendas e itens para atender os eventos extemporaneos.

@Param:
cAlias  -  Alias da Tabela Principal ( Tabela onde a Grid eh baseada
                                       para montar as informacoes    )
cRotina - Rotina onde a ViewDef se encontra
cTitulo - Titulo da Janela
lCadTrab- Informa se trata-se de Eventos do Trabalhador

@Return:

@author Roberto Souza
@since 04/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function xNewHisAlt( cAlias, cRotina, aHeaderT, cTitulo, lCadTrab, oBrw, cEvento, cLayout, cFunXML, lCadBen, aCampos)

	Local aAreaAlias   := (cAlias)->(GetArea())
	Local cFilter      := cAlias + "_FILIAL + " + cAlias + "_ID"
	Local nRecCAli     := (cAlias)->(RECNO())
	Local aCoors       := FwGetDialogSize( oMainWnd )
	Local aFields      := {}
	Local aArea        := T9U->(getArea())
	Local oPanel       := Nil
	Local oBrowse      := Nil
	Local lLoop        := .F.
	Local cFiltBrw     := ""
	Local cFil         := ""
	Local cId          := ""
	Local cCpsExc	   := ""
	Local nRecno       := 0
	Local nX		   := 0
	Local oDlgPrinc    := Nil
	Local lLGPDperm    := .T.
	Local bXml	   	   := IIF( FunName() == "TAFA591" .Or. cRotina == "TAFA591", {||TafXmlret( "TAF591Xml", "2410", "V75" )}, {||TafXmlret( cFunXML, cLayout, cAlias )})
	Local bXmlTrab     := {||TAF421XmlVld( 1, "xNewHisAlt" )}
	Local bXmlBenef	   := {||TAF588XmlVld(1,"xNewHisAlt")}
	Local aSeek        := {}
	Local nY           := 0      

	Private lMenuDif   := .T.
	Private cAliasHist := cAlias //Alias do browse de historico para utilizacao nas extemporaneas

	Default aCampos    := {}
	Default cLayout    := ""
	Default oBrw       := Nil
	Default cTitulo    := STR0015 + (cAlias)->&( cAlias + "_ID" )
	Default lCadBen    := .F.

	// Bloqueia ou audita de acordo com a fun��o que est� chamando e acesso do usu�rio
	// LGPD

	lLGPDperm := TafHistLGPD()		

	If lLGPDperm 
		
		nRecno := (cAlias)->(Recno())
		aWindow := {095,000}
		aColumn := {092,008}

		oDlgPrinc := tDialog():New(aCoors[1] + 100, aCoors[2] + 100,aCoors[3] - 100, aCoors[4] - 100,cTitulo,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

		oAreaHist := FWLayer():New()
		oAreaHist:Init( oDlgPrinc, .F., .T. )
		
		oAreaHist:Init(oDlgPrinc,.F., .F. )

		//Mapeamento da area
		oAreaHist:AddLine("L01",100,.T.)

		//���������Ŀ
		//�Colunas  �
		//�����������
		oAreaHist:AddCollumn("L01C01",aColumn[01],.F.,"L01") //dados
		oAreaHist:AddCollumn("L01C02",aColumn[02],.F.,"L01") //botoes

		//���������Ŀ
		//�Paineis  �
		//�����������
		oAreaHist:AddWindow("L01C01","TEXT","Informa��es",aWindow[01],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
		oPanel	:= oAreaHist:GetWinPanel("L01C01","TEXT","L01")

		oAreaHist:AddWindow("L01C02","L01C02P01","Fun��es",aWindow[01],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
		oAreaBut := oAreaHist:GetWinPanel("L01C02","L01C02P01","L01")

		oButt1 := tButton():New(000,000,"&Sair",oAreaBut,{|| oDlgPrinc:End() }	,oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)
		oButt1 := tButton():New(025,000,"&Gerar XML",oAreaBut,IIF(FunName()=="TAFA421".OR.cRotina =="TAFA421",bXmlTrab, IIF(FunName()=="TAFA588".OR.cRotina =="TAFA588",bXmlBenef,bXml)),oAreaBut:nClientWidth/2,15,,/*oFont*/,,.T.,,,,/*bWhen*/)

		For nY := 1  to Len(aCampos) - 5  
			Aadd(aSeek, {aCampos[nY,2], aCampos[nY,1], aCampos[nY,4], aCampos[nY,3], 0, aCampos[nY,5]})
		Next

		oBrowse:= FWmBrowse():New()
		oBrowse:SetDBFFilter(.T.)
		oBrowse:SetFieldFilter(aSeek)
		oBrowse:SetUseFilter(.T.)
		oBrowse:SetOwner( oPanel )			
		oBrowse:SetDescription( cTitulo )
		
		If FWIsInCallStack("TAFA421") .And. FWIsInCallStack("XFUNNEWHIS") .OR. FWIsInCallStack("TAFPNFUNC") .OR. FWIsInCallStack("TAFMONTES") .Or. FWIsInCallStack("TAFA591")// Prote��o para error log.

			If ((Type("cAliasTrb") == "C" .AND. (FunName()=="TAFA421" .OR. FunName()=="TAFMONTES")) .OR.;
			((Type("cAliasTrb") == "C" .OR. Type("cAliasTrb") == "U") .AND. FunName()!="TAFA421")) .And.;
			(!FWIsInCallStack("FopenPnTrab") .OR. FWIsInCallStack("XFUNNEWHIS") .OR. FWIsInCallStack("TAFPNFUNC") .OR. FWIsInCallStack("TAFMONTES"))// Quando for chamado pelo hist�rico de altera��es
				oBrowse:SetAlias( cAlias )
				dbSelectArea(cAlias)
			EndIf

		Else

			//TRATAMENTO INCLUIDO PARA QUE O BROWSE PRINCIPAL N�O FA�A USO DO ALIAS,
			//CORRIGINDO ASSIM O PROBLEMA DO SETFILTERDEFAULT.
			(cAlias)->(dbCloseArea())	
			dbSelectArea(cAlias)

			If cAlias == "V73"
				(cAlias)->(dbSetOrder(4))
			Else
				(cAlias)->(dbSetOrder(1))
			EndIf

			(cAlias)->(dbGoto(nRecCAli))

			oBrowse:SetAlias( cAlias )

		EndIf	

		//Tratamento para o cadastro do Trabalhador
		If lCadTrab

			If !xTafExtmp()

				oBrowse:AddLegend( "EVENTO == 'I' " 														, "GREEN"	, "Inclus�o de Cadastro do Trabalhador" 			) //"Inclu�s�o de Cadastro do Trabalhador"
				oBrowse:AddLegend( "EVENTO == 'I' .AND. !(NOMEVE $('S2200|S2300')) "						, "LBLUE"	, "Inclus�o de Evento de Altera��o" 				) //"Inclu�s�o de Evento de Altera��o"
				oBrowse:AddLegend( "EVENTO == 'A' "									 						, "YELLOW"	, "Retifica��o de Informa��es do Trabalhador " 		) //"Retifica��o de Informa��es do Trabalhador "
				oBrowse:AddLegend( "EVENTO == 'E' "									 						, "RED"     , "Exclus�o de Evento (Altera��o/Retifica��o)" 		) //"Exclus�o de Evento (Altera��o/Retifica��o)"
			
			Else

				oBrowse:AddLegend( "EVENTO == 'I' .AND. STASEC <> 'E' .AND. (NOMEVE $('S2200|S2300'))"		, "GREEN"	, "Inclus�o de Cadastro do Trabalhador" 			) //"Inclu�s�o de Cadastro do Trabalhador"
				oBrowse:AddLegend( "EVENTO == 'I' .AND. STASEC <> 'E' .AND. !(NOMEVE $('S2200|S2300')) "	, "LBLUE"	, "Inclus�o de Evento de Altera��o" 				) //"Inclu�s�o de Evento de Altera��o"
				oBrowse:AddLegend( "EVENTO == 'A' .AND. STASEC <> 'E' "										, "YELLOW"	, "Retifica��o de Informa��es do Trabalhador " 		) //"Retifica��o de Informa��es do Trabalhador "
				oBrowse:AddLegend( "EVENTO == 'E' .AND. STASEC <> 'E' .AND. STATUS == '7'"					, "RED"     , "Exclus�o de Evento ( Altera��o / Retifica��o )" 	) //"Exclus�o de Evento (Altera��o/Retifica��o)"
				oBrowse:AddLegend( "EVENTO == 'E' .AND. STASEC <> 'E' .AND. STATUS == '6'"					, "ORANGE"  , "Aguardando Retorno da Exclus�o" 					) //"Aguardando Retorno da Exclus�o"
				oBrowse:AddLegend( "EVENTO == 'I' .AND. STASEC == 'E' "										, "BLUE"	, "Inclus�o ( Extempor�neo ) " 						) //"Exclus�o de Evento (Altera��o/Retifica��o)"
				oBrowse:AddLegend( "EVENTO == 'A' .AND. STASEC == 'E' "										, "GRAY"    , "Retifica��o ( Extempor�neo )" 					) //"Exclus�o de Evento (Altera��o/Retifica��o)"	
				oBrowse:AddLegend( "EVENTO == 'E' .AND. STASEC == 'E' .AND. STATUS == '6'"					, "VIOLET"  , "Aguardando Retorno da Exclus�o ( Extempor�neo )"	) //"Aguardando Retorno da Exclus�o ( Extempor�neo )"
			
			EndIf

			oBrowse:SetColumns(aHeaderT)

		// Historicos Reinf
		ElseIf 	cAlias $ "V1O"	

			cFiltBrw := ""

			If TafColumnPos( cAlias + "_STASEC" )
				cFiltBrw := " .AND. " + cAlias + "_STASEC <> 'E' "
			EndIf

			oBrowse:AddLegend( cAlias + "_EVENTO == 'I' " + cFiltBrw 			, "GREEN"	, "Inclus�o" ) 
			oBrowse:AddLegend( cAlias + "_EVENTO == 'A' " + cFiltBrw			, "YELLOW"	, "Altera��o" )

			cFilter := cAlias + "_FILIAL + " + cAlias + "_ID"
			aFields := xFunGetSX3( cAlias )
			oBrowse:SetFields( aFields )

			oBrowse:SetFilterDefault( cAlias + "_ATIVO == '2' .and. " + cFilter + "=='" + ( cAlias )->&( cFilter ) + "'" )
		

		ElseIf lCadBen

			If !xTafExtmp()

				oBrowse:AddLegend( "EVENTO == 'I' " 												, "GREEN"	, "Inclus�o de Benef�cio"							) //"Inclus�o de Benef�cio"
				oBrowse:AddLegend( "EVENTO == 'A' "									 				, "YELLOW"	, "Retifica��o de Informa��es de Benef�cio"			) //"Retifica��o de Informa��es de Benef�cio"
				oBrowse:AddLegend( "EVENTO == 'E' "									 				, "RED"     , "Exclus�o de Evento" 								) //"Exclus�o de Evento"

			Else

				oBrowse:AddLegend( "EVENTO == 'I' .AND. STASEC <> 'E' .AND. (NOMEVE $('S2410'))"	, "GREEN"	, "Inclus�o de Benef�cio" 							) //"Inclus�o de Benef�cio" 
				oBrowse:AddLegend( "EVENTO == 'I' .AND. STASEC <> 'E' .AND. !(NOMEVE $('S2410'))"	, "LBLUE"	, "Inclus�o de Evento de Altera��o" 				) //"Inclus�o de Evento de Altera��o" 
				oBrowse:AddLegend( "EVENTO == 'A' .AND. STASEC <> 'E' "								, "YELLOW"	, "Retifica��o de Informa��es de Benef�cio"			) //"Retifica��o de Informa��es de Benef�cio"
				oBrowse:AddLegend( "EVENTO == 'E' .AND. STASEC <> 'E' .AND. STATUS == '7'"			, "RED"     , "Exclus�o de Evento" 								) //"Exclus�o de Evento"
				oBrowse:AddLegend( "EVENTO == 'E' .AND. STASEC <> 'E' .AND. STATUS == '6'"			, "ORANGE"  , "Aguardando Retorno da Exclus�o" 					) //"Aguardando Retorno da Exclus�o"
				oBrowse:AddLegend( "EVENTO == 'I' .AND. STASEC == 'E' "								, "BLUE"	, "Inclus�o ( Extempor�neo ) " 						) //"Inclus�o ( Extempor�neo )"
				oBrowse:AddLegend( "EVENTO == 'A' .AND. STASEC == 'E' "								, "GRAY"    , "Retifica��o ( Extempor�neo )" 					) //"Retifica��o ( Extempor�neo )" 	
				oBrowse:AddLegend( "EVENTO == 'E' .AND. STASEC == 'E' .AND. STATUS == '6'"			, "VIOLET" 	, "Aguardando Retorno da Exclus�o ( Extempor�neo )"	) //"Aguardando Retorno da Exclus�o ( Extempor�neo )"

			EndIf

			oBrowse:SetColumns(aHeaderT)

		Else	

			If xTafExtmp() .And. TafColumnPos( cAlias + "_STASEC" )
				oBrowse:AddLegend( cAlias + "_EVENTO == 'I' .AND. " + cAlias + "_STASEC == 'E' " 			                            	, "BLUE"	, "Inclus�o ( Extempor�neo ) " ) 				 	//"Inclus�o( Extempor�neo )"
				oBrowse:AddLegend( "(" + cAlias + "_EVENTO == 'A' .OR. " + cAlias + "_EVENTO == 'R' ) .AND. " + cAlias + "_STASEC == 'E' "	, "GRAY"    , "Retifica��o / Altera��o ( Extempor�neo )" ) 	//"Retifica��o / Altera��o ( Extempor�neo )"
				oBrowse:AddLegend( cAlias + "_EVENTO == 'E' .AND. " + cAlias + "_STASEC == 'E' .AND. " + cAlias + "_STATUS == '6'"			, "VIOLET" 	, "Aguardando Retorno da Exclus�o ( Extempor�neo )"	) //"Aguardando Retorno da Exclus�o ( Extempor�neo )"		
			Endif
			
			cFiltBrw := ""

			If TafColumnPos( cAlias + "_STASEC" )
				cFiltBrw := " .AND. " + cAlias + "_STASEC <> 'E' "
			EndIf

			If TafColumnPos( cAlias + "_XMLREC" )
				oBrowse:AddLegend( cAlias + "_XMLREC == 'COMP' " + cFiltBrw		, "BROWN" 	, "Afastamento Completo (In�cio e T�rmino)" )
			EndIf

			oBrowse:AddLegend( cAlias + "_EVENTO == 'I' " + cFiltBrw 			, "GREEN"	, "Inclus�o de Cadastro do Evento" ) 			 	//"Inclus�o de Cadastro do Evento"
			oBrowse:AddLegend( cAlias + "_EVENTO == 'A' " + cFiltBrw			, "YELLOW"	, "Retifica��o das Informa��es do Evento" ) 	  	//"Retifica��o das Informa��es do Evento"
			oBrowse:AddLegend( cAlias + "_EVENTO == 'E' " + cFiltBrw			, "RED"  	, "Exclus�o de Evento (Altera��o/Retifica��o)" )	//"Exclus�o de Evento (Altera��o/Retifica��o)"
			
			If !(cAlias $ "V72|V73")
				oBrowse:AddLegend( cAlias + "_EVENTO == 'R' " + cFiltBrw		, "WHITE" 	, "Afastamento Retificado" )
				oBrowse:AddLegend( cAlias + "_EVENTO == 'F' " + cFiltBrw		, "BLACK" 	, "T�rmino do Afastamento" )
			EndIf
			
			cFilter := cAlias + "_FILIAL + " + cAlias + "_ID"
			cFil    := cAlias + "_FILIAL"
			cId     := cAlias + "_ID"
			
			If cAlias == "V73"
				cCpsExc	:= "V73_ATIVO|V73_BAIRRO|V73_CEP|V73_CODMUN|V73_CODPOS|V73_COMLOG|V73_DCODMU|V73_DISTRI|V73_DLOG|"
				cCpsExc	+= "V73_DPAISR|V73_DSCLOG|V73_DTINCF|V73_DTNASC|V73_DTPLOG|V73_DTRANS|V73_DTRECP|V73_DUF|V73_ESTCIV|"
				cCpsExc	+= "V73_HRRECP|V73_HTRANS|V73_INCFIS|V73_LOGOPE|V73_LOGRAD|V73_NMCIDE|V73_NRLOGR|V73_NUMLOG|V73_PAISRE|V73_RACA|"
				cCpsExc	+= "V73_SEXO|V73_TAFKEY|V73_TPLOG|V73_UF|V73_XMLID|V73_VERANT|V73_PROTPN|V73_STASEC|V73_VNOME|V73_EVENTO|"
			EndIf

			If cAlias == "V7C"
				cCpsExc	:= "V7C_ID|V7C_IDPROC|V7C_NRPROC|V7C_PERAPU|V7C_PROTPN|V7C_VERSAO|V7C_STATUS|V7C_ATIVO|V7C_VERANT|V7C_DTRAN|V7C_HTRANS"
				cCpsExc += "V7C_DTRECP|V7C_HRRECP|V7C_EVENTO|V7C_LAYOUT|V7C_DINSIS|V7C_XMLID|"
			EndIf

			aFields := xFunGetSX3( cAlias, cCpsExc )

			If cAlias $ "V73|V9U"
				For nX := 1 To Len(aFields)
					If aFields[nX][2] == cAlias + "_STATUS"
						aFields[nX][2] := "TAF421Sts("+aFields[nX][2]+")"
						aFields[nX][6] := 30
					EndIf
				Next
			EndIf

			oBrowse:SetFields( aFields )

			If cAlias $ "V73|CM0|CM9|C8B"
				cFiltBrw	:= cAlias + "_ATIVO == '1' .AND. "
			Else
				cFiltBrw	:= cAlias + "_ATIVO == '2' .AND. "
			EndIf
			
			cFiltBrw	+= cAlias + "_FILIAL == '" + (cAlias)->&( cFil ) + "' .AND. " + cAlias + "_ID == '" + (cAlias)->&( cId ) + "'" 
			oBrowse:SetFilterDefault(cFiltBrw)
		
		EndIf

		oBrowse:SetMenuDef( cRotina )
		oBrowse:SetProfileID( '1' )
		oBrowse:DisableDetails()

		oBrowse:Activate()

		oDlgPrinc:Activate(,,,.T.,/*valid*/,,/*On Init*/)
		RestArea(aArea)
		RestArea(aAreaAlias)
		oBrowse:Deactivate()
		oBrowse:Destroy()
		oBrowse:= Nil

		If oBrw != Nil
			oBrw:SetAlias(cAlias)//inclus�o para suprir a quest�o do dbclosearea incluido para corre��o do filtro.
			oBrw:SetFilterDefault(TAFBrwSetFilter(cAlias,cRotina,cEvento)) 
			If nRecno > 0 
				oBrw:GoTo(nRecno, .T.)
			EndIf
		EndIf 

	EndIf 

Return( lLoop )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafHistLGPD
Verifica se contem dados senss�veis e tamb�m verifica se o usuario tem acesso aos dados, se sim o log
� auditado. se n�o a tela(Ex: Historico) � bloqueada.
@author  TOTVS
@since   14/01/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TafHistLGPD()

	Local aArea		:= GetArea()
	Local aHistAlt 	:= {}
	Local lRet		:= .T.
	Local nPosTaf   := 0

	aHistAlt := TAFRotinas()

	If Len(aHistAlt) > 0
		nPosTaf := aScan(aHistAlt,{|x| x[1] == FunName()})
		If  nPosTaf > 0 .And. Len(aHistAlt[nPosTaf]) > 16 .And. aHistAlt[nPosTaf][17]  // verifica se contem dados senss�veis
			If ( lRet	:= IIf(FindFunction("PROTDATA"),ProtData(),.T.)  )
				IIf (FindFunction('FwPDLogUser'),FwPDLogUser('XFUNHISALT'),.T.)
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lRet
