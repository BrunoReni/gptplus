#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFREINFFUNCOES.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFMenuReinf
@type			function
@description	Fun��o respons�vel por retornar o menu padr�o das rotinas do TAF.
@author			Felipe C. Seolin
@since			30/01/2018
@version		1.0
@param			cMenu	-	Nome da Rotina
				aFuncao	-	Array com rotinas adicionais. Posi��es do array:
								1 - C - T�tulo da rotina, caso n�o seja predefinida
								2 - C - Fun��o a ser executada
								3 - C - Op��o de t�tulo predefinida
								4 - N - N�mero da opera��o
@return			aRotina	-	Array com as op��es de menu
/*/
//---------------------------------------------------------------------
Function TAFMenuReinf( cMenu, aFuncao, lMenuDef )

Local nI			as numeric
Local nDel			as numeric
Local nCont			as numeric
Local nPos			as numeric
Local cAlias	 	as char
Local aRotina		as array
Local aRotExc		as array
Local aEvento		as array

Default aFuncao	 :=	{} 
Default lMenuDef := .T.

nI		:=	0
nDel	:=	0
nCont	:=	8 //Par�metro nOpc do aRotina
nPos	:=	0
aRotina	:=	FWMVCMenu( cMenu )
aRotExc	:=	{}
aEvento	:=	TAFRotinas( cMenu, 1, .F., 5, ,lMenuDef)
cAlias		:= aEvento[3] 

//*********************************************************
//Remove todas as op��es do menu padr�o, exceto Visualizar
//*********************************************************
For nI := Len( aRotina ) to 1 Step - 1
	If cMenu == "TAFA490" //R-9000
		If aRotina[nI,1] == STR0020 //"Alterar"
			aRotina[nI,2] := "TAF490Pre( 'Alterar' )"
		ElseIf aRotina[nI,1] == STR0021 //"Excluir"
			aRotina[nI,2] := "TAF490Pre( 'Excluir' )"
		ElseIf !( aRotina[nI,1] $ STR0022 + "|" + STR0023 ) //##"Incluir" ##"Visualizar"
			aDel( aRotina, nI )
			nDel ++
		EndIf
	Else
		//Tratamento para situa��es especificas em eventos
		If cMenu $ "TAFA496|TAFA502|TAFA548" .And. aRotina[nI,1] == STR0021 //"Excluir"
			aRotina[nI,2] := "TAFVMsgReinf('" + cAlias + "')" //Dispara mensagens na tela dependendo da a��o executada
		EndIf
	
		If ( aRotina[nI,1] <> STR0023 .and. aRotina[nI,1] <> STR0021 ) .or. ( aRotina[nI,1] == STR0021 .and. Len( aEvento ) >= 12 .and. aEvento[12] == "C" ) //##"Visualizar" ##"Excluir" ##"Excluir"					
			aDel( aRotina, nI )
			nDel ++
		EndIf
	EndIf
Next nI

If nDel > 0
	aSize( aRotina, Len( aRotina ) - nDel )
EndIf

If Len( aEvento ) >= 12 .and. !(aEvento[12] $ "C|T")
	If !( cMenu $ "TAFA490|TAFA496|TAFA502|TAFA548" ) //R-9000|R-2099
		//**************************************************
		//Adiciona op��o de Excluir pelo Evento de Exclus�o
		//**************************************************
		aAdd( aRotExc, { STR0001, "TAFR9000", 0, nCont, 0, Nil } ) //"Excluir Registro"
		nCont ++
		aAdd( aRotExc, { STR0002, "TAFR9000", 0, nCont, 0, Nil } ) //"Desfazer Exclus�o"
		nCont ++
		aAdd( aRotExc, { STR0003, "TAFR9000", 0, nCont, 0, Nil } ) //"Visualizar Registro de Exclus�o"
		nCont ++

		If ( nPos := aScan( aRotina, { |x| AllTrim( x[1] ) == STR0021 } ) ) > 0 //"Excluir"
			aRotina[nPos][2] := aRotExc
		EndIf
	EndIf
EndIf

//*****************************
//Adiciona op��es customizadas
//*****************************
If !Empty( aFuncao )

	For nI := 1 to Len( aFuncao )

		//O terceiro par�metro do array aFuncao recebe um caracter contendo as informa��es abaixo:
		//"1" - T�tulo predefinido -> "Gerar XML Reinf"
		//"2" - T�tulo predefinido -> "Validar Registro"
		//"3" - T�tulo predefinido -> "Exibir Hist�rico de Altera��es"
		//"4" - T�tulo predefinido -> Reservado caso utilize mesma estrutura do eSocial
		//"5" - T�tulo predefinido -> "Gerar XML em Lote"
		//Caso seja informado, o primeiro par�metro receber� o conte�do predefinido.
		//Foi desenvolvido para que as strings sejam criadas em �nico local, em situa��es que os t�tulos forem usados com frequ�ncia.
		If Len( aFuncao[nI] ) > 2
			If aFuncao[nI,3] <> Nil
				If aFuncao[nI,3] == "1"
					aFuncao[nI,1] := STR0004 //"Gerar XML Reinf"
				ElseIf aFuncao[nI,3] == "2"
					aFuncao[nI,1] := STR0005 //"Validar Registro"
				ElseIf aFuncao[nI,3] == "3" .And. !( cMenu $ "TAFA490|TAFA496|TAFA548" )
					aFuncao[nI,1] := STR0006 //"Exibir Hist�rico de Altera��es"
				ElseIf aFuncao[nI,3] == "5"
					aFuncao[nI,1] := STR0007 //"Gerar XML em Lote"
				ElseIf aFuncao[nI,3] == '6'
					aFuncao[nI,1] := STR0024 //"Gerar exclus�o do Evento"
				ElseIf aFuncao[nI,3] == '7'
					aFuncao[nI,1] := STR0025//"Log de Apura��o"
				ElseIf aFuncao[nI,3] == '8'
					aFuncao[nI,1] := STR0026//"Legenda"
				ElseIf aFuncao[nI,3] == '9'
					aFuncao[nI,1] := 'Desfazer Exclus�o'//"Desfazer Exclus�o"					
				EndIf
			EndIf
		EndIf

		aAdd( aRotina, { aFuncao[nI,1], aFuncao[nI,2], 0, Iif( Len( aFuncao[nI] ) >= 4, aFuncao[nI,4], nCont ), 0, Nil } )
		nCont += 1
	Next nI
EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFR9000
@type			function
@description	Cria uma interface para a Exclus�o do Registro R-9000 e
@description	realiza as valida��es e manuten��es necess�rias no envento gerador.
@author			Felipe C. Seolin
@since			30/01/2018
@version		1.0
@param			cAlias	-	Alias da tabela
@param			nRecno	-	Recno do registro
@param			nOpc	-	Op��o de menu executada
@param			lRest	-	.T. se a execu��o est� sendo chamada pelo Painel Reinf, .F. = chamada pelo menu do MVC
@param			aRetorno-	array passado como referencia para retorno sucesso ou erro e a mensagem
@param 			cFuncEv -	Nome da fun��o MVC do evento excluido

/*/
//---------------------------------------------------------------------
Function TAFR9000( cAlias, nRecno, nOpc, lRest, aRetorno, cFuncEv )

Local oModel	as object
Local cTitulo	as char
Local cFunction	as char
Local cEvento	as char
Local cCodEvt	as char
Local cIDTpEvt	as char
Local cDescEvt	as char
Local cChave	as char
Local cRecibo	as char
Local cOption	as char
Local cFiltro	as char
Local cV48		as char
Local cInscReg  as char
Local nOper		as numeric
Local nRet		as numeric
Local nI		as numeric
Local oBrwRot	as Object

Local aRotinas	as array
Local lView		as logical
Local aArea 	as array


Default cAlias	:=	""
Default nRecno	:=	0
Default nOpc	:=	1
Default lRest	:= .F.
Default aRetorno := {}
Default cFuncEv	:= ""

oModel		:=	Nil
cTitulo		:=	STR0008 //"Exclus�o de Evento"
cFunction	:=	IIf(lRest, cFuncEv, FunName())
cEvento		:=	""
cCodEvt		:=	""
cIDTpEvt	:=	""
cDescEvt	:=	""
cChave		:=	""
cRecibo		:=	""
cOption		:=	""
cFiltro	:= ""
nOper		:=	3
nRet		:=	0
nI			:=	0
aArea		:= GetArea()
aRotinas	:=	TAFRotinas( cFunction, 1, .F., 5 )
lView		:=	.F.
cV48		:= Iif(cAlias == "V0S",cAlias + "->" + cAlias + "_PERAPU" + "|" + cAlias + "->" + cAlias + "_TPINSC" + "|" + cAlias + "->" + cAlias + "_NRINSC", "")
cEvento 	:= aRotinas[4]
cInscReg 	:= C9B->C9B_NRINSC
aFilReg		:= RetNrInsc(cInscReg)

If !lRest
	//Pesquisa da fun��o TAFR9000 na Pilha de Chamada para capturar a op��o selecionada no menu
	For nI := 1 to 99
		If "TAFR9000" $ ProcName( nI )
			If Upper( STR0001 ) $ Upper( ProcName( nI ) ) //"Excluir Registro"
				cOption := "1"
			ElseIf Upper( STR0002 ) $ Upper( ProcName( nI ) ) //"Desfazer Exclus�o"
				cOption := "2"
			ElseIf Upper( STR0003 ) $ Upper( ProcName( nI ) ) //"Visualizar Registro de Exclus�o"
				cOption := "3"
			EndIf

			Exit
		ElseIf Empty( ProcName( nI ) )
			Exit
		EndIf
	Next nI
Else
	cOption := Str(nOpc,1)	
EndIf
If cOption == "1"
	cRecibo := PadR( AllTrim( &( cAlias + "->" + cAlias + "_PROTUL" ) ), GetSX3Cache( cAlias + "_PROTUL", "X3_TAMANHO" ) )
ElseIf cOption == "2" .or. cOption == "3"
	cRecibo := PadR( AllTrim( &( cAlias + "->" + cAlias + "_PROTPN" ) ), GetSX3Cache( cAlias + "_PROTPN", "X3_TAMANHO" ) )
EndIf

DBSelectArea( "T9B" )
T9B->( DBSetorder( 2 ) )
If T9B->( MsSeek( xFilial( "T9B" ) + cEvento ) )
	cCodEvt  := T9B->T9B_CODIGO
	cDescEvt := T9B->T9B_DESCRI
	cIDTpEvt := T9B->T9B_ID
EndIf
T9B->( DBCloseArea() )

//Se selecionado op��o 1 ( Excluir Registro ) no menu
If cOption == "1"

	If &( cAlias + "->" + cAlias + "_STATUS" ) $ "4" .and. &( cAlias + "->" + cAlias + "_EVENTO" ) <> "E"
		DBSelectArea( cAlias )
		( cAlias )->( DBGoto( nRecno ) )

		If lRest .or. (!lRest .and. MsgYesNo( I18N( STR0009, { CRLF } ) ) ) //"Ao confirmar esta a��o, ser� exibido uma interface para inclus�o de um registro R-9000 ( Exclus�o ) para este evento.#1Confirma a a��o?"
			//Carrego no modelo as informa��es do evento de exclus�o
			If !GerEventEx( cEvento, cCodEvt, cAlias, cDescEvt, nRecno, nOper, cRecibo, cTitulo, cIDTpEvt, lRest ) .AND. lRest
				Aadd(aRetorno,{.F., "Erro ao excluir registro."})
			EndIf
		EndIf

	ElseIf &( cAlias + "->" + cAlias + "_STATUS" ) $ "2|6"
		If lRest
			Aadd(aRetorno,{.F., STR0010})
		Else
			Aviso( cTitulo, STR0010, { STR0011 }, 1 ) //##"N�o � possivel realizar a exclus�o de um evento que est� aguardando o retorno do RET." ##"Fechar"
		EndIf	

	ElseIf &( cAlias + "->" + cAlias + "_STATUS" ) == "7"
		If lRest
			Aadd(aRetorno,{.F., STR0012})
		Else
			Aviso( cTitulo, STR0012, { STR0011 }, 1 ) //##"N�o � poss�vel realizar a exclus�o de um evento que j� foi exclu�do e validado pelo RET." ##"Fechar"
		EndIf
	Else
		oModel := FWLoadModel( cFunction )
		oModel:SetOperation( 5 )
		oModel:Activate()
		cChave := &( cAlias + "->" + cAlias + "_ID" ) + &( cAlias + "->" + cAlias + "_VERANT" )
		If lRest
			If oModel:CommitData()
				nRet := 0 //Sucesso
			Else	 
				nRet := 1	  //Erro 
				Aadd(aRetorno,{.F., "Erro ao realizar a exlus�o do registro."})
			EndIf	
		Else
			nRet := FWExecView( cTitulo, cFunction, 5,, { || .T. },,,,,,, oModel )
		EndIf	
		
		If nRet == 0	
			dbSelectArea(cAlias)

			TAFLimpId( cAlias, cAlias + "->" + cAlias + "_PROCID", cFunction, "", cV48 , aFilReg)
			//Pegamos o filtro da tabela corrente.
			cFiltro := DbFilter()
			
			//Alteramos o filtro da tabela para alterar o registro anterior.
			SET FILTER TO &(cAlias + "_ATIVO == '2'")
			
			//Executa a "recupera��o" do registro anterior.
			oBrwRot := Nil
			If Type("oBrw") == "O"
				oBrwRot := oBrw
			ElseIf Type("oBrowse") == "O"	
				oBrwRot := oBrowse
			EndIf	
			TAFRastro( cAlias, 1, cChave, .T., .T., oBrwRot )
			
			//Retornamos o filtro original da tabela.
			Set Filter TO &(cFiltro)
			
		EndIf
	EndIf

//Se selecionado op��o 2 ( Desfazer Exclus�o ) ou 3 ( Visualizar Registro de Exclus�o ) no menu
ElseIf cOption == "2" .or. cOption == "3"

	nOper := Iif( cOption == "2", MODEL_OPERATION_DELETE, MODEL_OPERATION_VIEW )

	DBSelectArea( "T9D" )
	T9D->( DBSetOrder( 2 ) )

	If T9D->( MsSeek( xFilial( "T9D" ) + cIDTpEvt + PadR( cRecibo, GetSX3Cache( "T9D_NRRECI", "X3_TAMANHO" ) ) + "1" ) )
		If cOption == "2"
			If T9D->T9D_STATUS $ "246"
				If lRest
					Aadd(aRetorno,{.F., STR0013})
				Else
					Aviso( cTitulo, STR0013, { STR0011 }, 2 ) //##"N�o foi poss�vel desfazer a exclus�o pois o evento j� foi transmitido." ##"Fechar"
				EndIf	
			Else
				If lRest
					lView := .T.
				Else
					lView := MsgYesNo( I18N( STR0014, { CRLF } ) ) //"Ao confirmar esta a��o, ser� exibida uma interface para a exclus�o do evento R-9000 vinculado a este registro.#1Confirma a a��o?"
				EndIf	
			EndIf
		ElseIf cOption = "3"
			lView := .T.
		EndIf
	Else
		If lRest
			Aadd(aRetorno,{.F., STR0015})
		Else
			Aviso( cTitulo, STR0015, { STR0011 }, 2 ) //##"N�o h� registro de exclus�o relacionado a este registro." ##"Fechar"
		EndIf	
	EndIf

	If lView
	
		If lRest

			BEGIN TRANSACTION

				oModelT9D := FWLoadModel( "TAFA490" )
				oModelT9D:SetOperation( 5 ) // DELETE
				oModelT9D:Activate()
				
				If Save490Model(oModelT9D)
					If !( FWFormCommit(oModelT9D) .and. CommitVerAnt( cAlias, nRecno, cFunction ) )
						Aadd(aRetorno,{.F., "Erro ao realizar a exlus�o do registro."})
						Disarmtransaction()
					EndIf
				EndIf

			END TRANSACTION

		Else
			nRet := FWExecView( cTitulo, "TAFA490", nOper,, { || .T. } )

			If nRet == 0 .and. nOper == 5
				CommitVerAnt( cAlias, nRecno, cFunction )
			EndIf
		
		EndIf

	EndIf

EndIf

RestArea(aArea)

Return( )


Static Function CommitVerAnt( cAlias, nRecno, cFunction )
	
	Local cChave := ""
	Local lRet   := .F.

	DBSelectArea( cAlias )
	( cAlias )->( DBGoTo( nRecno ) )
	cChave := &( cAlias + "->" + cAlias + "_ID" ) + &( cAlias + "->" + cAlias + "_VERANT" )

	oModel := FWLoadModel( cFunction )
	oModel:SetOperation( 5 )
	oModel:Activate()
	lRet := FWFormCommit( oModel )

	TAFRastro( cAlias, 1, cChave, .T., .T. )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} GerEventEx
@type			function
@description	Fun��o utilizada para gerar as informa��es de exclus�o no modelo.
@author			Felipe C. Seolin
@since			30/01/2018
@version		1.0
@param			cEvento		-	Sigla do Evento
@param			cCodEvt		-	C�digo do Evento
@param			cAlias		-	Alias da tabela
@param			cDescEvt	-	Descri��o do Evento
@param			nRecno		-	Recno do registro
@param			nOper		-	Indicador da opera��o a ser executada
@param			cRecibo		-	Recibo de transmiss�o do Evento
@param			cTitulo		-	T�tulo da View
@param			cIDTpEvt	-	ID do tipo de evento (T9B_ID)
@param			lRest		-	.T. se a execu��o est� sendo chamada pelo Painel Reinf, .F. = chamada pelo menu do MVC
@return			lReturn		-	Indica se a opera��o foi executada com sucesso
/*/
//---------------------------------------------------------------------
Static Function GerEventEx( cEvento, cCodEvt, cAlias, cDescEvt, nRecno, nOper, cRecibo, cTitulo, cIDTpEvt, lRest )

Local oModelT9D	as object
Local nRet		as numeric
Local lReturn	as logical
Local cDataPer	as character

oModelT9D	:=	Nil
nRet		:=	0
lReturn		:=	.F.

Default cIDTpEvt	:= ''
Default lRest	:= .F.

DBSelectArea( cAlias )
DBGoto( nRecno )

oModelT9D := FWLoadModel( "TAFA490" )
oModelT9D:SetOperation( 3 )
oModelT9D:Activate()

oModelT9D:LoadValue( "MODEL_T9D", "T9D_TPEVEN", cCodEvt )
oModelT9D:LoadValue( "MODEL_T9D", "T9D_IDTPEV", cIDTpEvt )
oModelT9D:LoadValue( "MODEL_T9D", "T9D_DTPEVE", cDescEvt )
oModelT9D:LoadValue( "MODEL_T9D", "T9D_PERAPU", &( cAlias + "->" + cAlias + "_PERAPU" ) )
oModelT9D:LoadValue( "MODEL_T9D", "T9D_REGREF", nRecno )
oModelT9D:LoadValue( "MODEL_T9D", "T9D_NRRECI", cRecibo )
If cEvento == "R-3010"
	cDataPer := DtoS(&( cAlias + "->" + cAlias + "_DTAPUR" ))
	oModelT9D:LoadValue( "MODEL_T9D", "T9D_PERAPR", &( cAlias + "->" + cAlias + "_DTAPUR" ) )
	oModelT9D:LoadValue( "MODEL_T9D", "T9D_PERAPU", SubStr(cDataPer,5,2) + SubStr(cDataPer,1,4))
EndIf	
If !lRest
	nRet := FWExecView( cTitulo, "TAFA490", nOper,, { || .T. },,,,,,, oModelT9D )
Else
	If Save490Model(oModelT9D)
		FWFormCommit(oModelT9D)
		nRet := 0
	Else	
		nRet := 1	
	EndIf	
EndIf	
lReturn := Iif( nRet == 0, .T., .F. )

Return( lReturn )


//---------------------------------------------------------------------
/*/{Protheus.doc} TafCkReinf
@type			function
@description	Fun��o utilizada para verificar a integridade das fun��es e tabelas do reinf informadas no TafaRotinas.
@author			Roberto Souza
@since			26/02/2018
@version		1.0
@param			
@return			aDiag		-	Retorna os dados de inconsistencia
/*/
//---------------------------------------------------------------------
Function TafCkReinf()
	Local aDiag 	as Array
	Local aRotinas	as Array 
	Local aRotReinf	as Array 
	Local Nx 		as numeric

	aDiag		:= {}
	aRotinas 	:= TAFRotinas()
	aRotReinf 	:= {}
	Nx 			:= 0

	For Nx := 1 To Len( aRotinas )
		If aRotinas[Nx][04]<> Nil .And. Substr(aRotinas[Nx][04],1,2) == "R-"
			AADD(aRotReinf,aRotinas[Nx] )
		EndIf
	Next
	For Nx := 1 To Len( aRotReinf )

		//Fun��o Principal
		If !Empty( aRotReinf[Nx][01] )
			If !FindFunction(aRotReinf[Nx][01])
				AADD( aDiag ,{aRotReinf[Nx][01],STR0016 })//"Rotina Principal n�o encontrada."	
			EndIf
		EndIf

		If !Empty( aRotReinf[Nx][08] )
			If !FindFunction(aRotReinf[Nx][08])
				AADD( aDiag ,{aRotReinf[Nx][08],STR0017})//"Rotina de XML n�o encontrada."	
			EndIf
		EndIf

		If !Empty( aRotReinf[Nx][16] )
			If !FindFunction(aRotReinf[Nx][16])
				AADD( aDiag ,{aRotReinf[Nx][16],STR0018})	//"Rotina de Apura��o n�o encontrada."
			EndIf
		EndIf

		If !Empty( aRotReinf[Nx][03] )
			If !TAFAlsInDic(aRotReinf[Nx][03])
				AADD( aDiag ,{aRotReinf[Nx][03],STR0019})	//"Tabela n�o encontrada."
			EndIf
		EndIf
	Next

Return( aDiag )
//---------------------------------------------------------------------
/*/{Protheus.doc} TAFLimpId
@description	Fun��o para limpar o campo _PROCID das tabelas do legado quando algum registro do espelho � exclu�do
@author		Henrique Pereira
@since			13/03/2018
@version		1.0
@param1		cAlias: Alias da tabelas espelho que est� sendo exclu�da
@param2		cId: _PROCID da tabela espelho que est� sendo exclu�da
@param3		cFunction: rotina (MVC) da tabela espelho que est� sendo exclu�da
@param4		cConSQL
@param5		cChave
@param6		aFilReg: Array com as filiais selecioandas para filtrar a query do R-2030 

@return		NIL
/*/
//---------------------------------------------------------------------

Function TAFLimpId(cTblLeg, cId, cFunction, cConSQL, cChave , aFilReg)
	Local aGetArea 	as Array
	Local aAlsProc	as Array
	Local aKey		as Array
	Local cSelect	as Character
	Local cConteudo	as Character
	Local cAliasUPD	as Character
	Local cTabProc	as Character
	Local cProcId	as Character
	Local nX		as Numeric
	Local lV48		as Logical
	Local lBlc40	as logical

	aKey			:= {}
	aGetArea 		:= {}
	aAlsProc		:= {}
	cConteudo		:= &cId
	cAliasUPD		:= ""
	cTabProc		:= ""
	nX				:= 0
	lV48			:= TAFColumnPos("V48_PROCID")
	lBlc40			:= cFunction $ "TAFA545|TAFA546|TAFA543|TAFA602" //R-4010|R-4020|R-4040|R-4080
	cProcId			:= iif(lBlc40,'_PRID40','_PROCID')

	Default 	cConSQL	:= ''
	Default 	cChave	:= ''
	Default		aFilReg := ''
	// sempre adicionar a nova tabela em TAFRetAls()
	aAlsProc := TAFRetAls(cTblLeg, cFunction, cConSQL)

	If cTblLeg == "V0S" .AND. lV48
		aKey := RetReg(cChave)
	EndIf

	For nX := 1 to Len(aAlsProc)
		
		cSelect	:= "R_E_C_N_O_"
		
		If cTblLeg != "V0S" .OR. ( ( aScan(aKey, {|x| x == aAlsProc[nX][1]} ) > 0 ) .OR. !lV48 )
			cTabProc := aAlsProc[nX][1]
			aGetArea := (cTabProc)->(GetArea())
			DbSelectArea(cTabProc)
			
			cFrom 	:= RetSqlName(cTabProc) + " " + cTabProc
			cWhere	:= cTabProc +"." + cTabProc + cProcId + " = '" + cConteudo + "' "
			
			If !Empty(aAlsProc[nX][2])
				cWhere	+= aAlsProc[nX][2]
			EndIf 

			If lV48 .AND. !Empty(cChave)
				If aAlsProc[nX][1] == "V48" 
					cSelect	:=  aAlsProc[nX][1] + "." + cSelect
					cFrom	+= aKey[2]
					cWhere	+= aKey[3]
				ElseIf aAlsProc[nX][1] == "C5M" .AND. !Empty(cChave)
					cWhere	+= aKey[2]
				EndIf
			EndIf

			If !Empty(aFilReg) .and. cTblLeg == 'C9B'
				cWhere	+= "AND " + cTabProc + "_FILIAL in  ( " + aFilReg +  " ) "
			EndIf 

			cSelect	:= "%" +	cSelect		+ 	"%"
			cFrom 	:= "%" +	cFrom		+ 	"%"
			cWhere 	:= "%" +	cWhere		+ 	"%"
			
			cAliasUPD := GetNextAlias()	
			BeginSql Alias cAliasUPD
				SELECT 
					%Exp:cSelect% R_E_C_N_O_
				FROM
					%Exp:cFrom%
				WHERE 
					%Exp:cWhere%
			EndSql
			
			(cAliasUPD)->(DbGoTop())		
			While !(cAliasUPD)->(EOF())
			
				DbSelectArea(cTabProc)
				DbGoTo((cAliasUPD)->R_E_C_N_O_)
					
				If (Recno(cTabProc) == (cAliasUPD)->R_E_C_N_O_) .AND. !Empty(&(cTabProc+ "->" + cTabProc + cProcId))
						RecLock(cTabProc,.F.)
					&(cTabProc+ "->" + cTabProc + cProcId) := ' '
						(cTabProc)->(MsUnLock())
					EndIf

				(cAliasUPD)->(DBSKIP())
				
			EndDo
			
			RestArea( aGetArea )
			
			If Select(cAliasUPD) > 0
				(cAliasUPD)->(DbCloseArea())
			Endif

		EndIf	

	Next nX

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFRetAls
@description	Retorna um array com as tabelas do legado que devem ser verificadas para ter o seu campo _PROCID zerado o conte�do
@author		Henrique Pereira
@since			13/03/2018
@version		1.0
@param1		cAlias: Alias da tabelas espelho que est� sendo exclu�da
@param2		cFunction: rotina (MVC) da tabela espelho que est� sendo exclu�da
@return		Array com duas posi��es [1] nome da tabela legado a ter campo _PROCID zerado o conte�do [2] espess�o SQL a ser usada como WHERE para encontrar a tabela espelho
/*/
//---------------------------------------------------------------------

Static Function TAFRetAls(cAlias, cFunction, cConSQL)
Local aAlsProc	as Array
Local lApurBx	as Logical

lApurBx	:= SuperGetMv('MV_TAFRECD',.F.,"1") == "2" .and. TAFColumnPos("T5P_PROCID") .and. FindFunction("TafCalProp")
aAlsProc		:= {}
Default cFunction	:= ''
Default cConSQL	:= ''
		
		Do case
			Case (cAlias $ "T95|CMN|C9B|T9K|V5S") // tabelas ESPELHO			
				If cFunction $ "TAFA486" .or. (cFunction $ "TAFA491" .and. !lApurBx)// R-2010|R-2040
					AADD(aAlsProc,{'C20'," AND C20.C20_INDOPE = '0' "})
					AADD(aAlsProc,{'LEM'," AND LEM.LEM_NATTIT = '0' "})
				ElseIf	cFunction $ "TAFA478" .or. (cFunction $ "TAFA255" .and. !lApurBx)// R-2020|R-2030
					AADD(aAlsProc,{'C20'," AND C20.C20_INDOPE = '1' "})
					AADD(aAlsProc,{'LEM'," AND LEM.LEM_NATTIT = '1' "})
				ElseIf lApurBx .and. cFunction $ "TAFA491|TAFA255" //R-2040|R-2030 
					AADD(aAlsProc,{'T5P'," "})
				Else
					AADD(aAlsProc,{'C20'," "})
					AADD(aAlsProc,{'LEM'," "}) 			
				EndIf
			Case (cAlias $ "T9U")	// R-1000
				AADD(aAlsProc,{'C1E'," "})
			Case (cAlias $ "T9V")	// R-1070
				AADD(aAlsProc,{'C1G', cConSQL})
			Case (cAlias $ "V1D")	// R-2050
				AADD(aAlsProc,{'C20'," AND C20.C20_INDOPE = '1' "})
			Case (cAlias $ "V0S")	// R-2060
				AADD(aAlsProc,{'C5M',"  "})
				If TAFColumnPos("V48_PROCID")
					AADD(aAlsProc,{'V48',"  "})
				EndIf
			Case (cAlias $ "V0L")	// R-3010
				AADD(aAlsProc,{'T9F',"  "})			 	
	Case (cAlias $ "V4Q|V5C")		 	
		AADD(aAlsProc,{'C20'," AND C20.C20_INDOPE = '0' "})	
		AADD(aAlsProc,{'LEM'," AND LEM.LEM_NATTIT = '0' "})
		AADD(aAlsProc,{'V3U'," AND V3U.V3U_NATTIT = '0' "})
		If cFunction $ "TAFA545"
			AADD(aAlsProc,{'V4B',"  "})
		Endif
	Case (cAlias $ "V4N|V97")
		If cFunction $ "TAFA543"
			AADD(aAlsProc,{'V4K'," AND V4K.V4K_INDNAT = '0' "})	
		elseif cFunction $ "TAFA602"
			AADD(aAlsProc,{'V4K'," AND V4K.V4K_INDNAT = '1' "})	
		endif
		EndCase 		

Return aAlsProc	
/*/{Protheus.doc} TAFVMsgReinf
Funcao que verifica se exclus�o do evento � permitida e dispara mensagem na tela 
@param cAlias, character, (Alias do registro posicionado)
@Return .T.

@Author Vitor Henrique Ferreira
@Since 21/03/2018
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAFVMsgReinf(cAlias)
Local cNmFun  	:= FunName()
Local cTitulo  	:= STR0017

Default cAlias := ''

	/*---------------------------------------------------------
	Se o registro ja foi transmitido
	---------------------------------------------------------*/
	If (cAlias)->&(cAlias + '_STATUS') == ( "4" )
		MsgAlert(xValStrEr("001099")) //"N�o � poss�vel realizar a exclus�o de um registro j� transmitidos."		
	Else
		FWExecView(cTitulo,cNmFun,MODEL_OPERATION_DELETE)
	Endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafFReinfNum
@type			function
@description	Fun��o utilizada para formatar o valor n�mero recebido conforme o layout do reinf
@author			Vitor Siqueira
@since			26/02/2018
@version		1.0
@param			
@return			nNumFormat - n�mero formato
/*/
//---------------------------------------------------------------------
Function TafFReinfNum(nNum)
Local nNumFormat as numeric

nNumFormat :=  StrTran(Alltrim((TRANSFORM(nNum, "@E 9,999,999,999,999.99"))),"." ,"")

Return nNumFormat 



/*/{Protheus.doc} TAFLegReinf
Legenda para eventos Reinf
@param cAlias, character, (Alias do registro posicionado)
@param oBrowse, object, (Browse para adicao da legenda)

@Return .T.

@Author Roberto Souza
@Since 11/07/2018
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAFLegReinf( cAlias , oBrowse )

	oBrowse:AddLegend( cAlias+"_STATUS == ' ' ", "GREEN"	, TAFStReinf(" ") ) 
	oBrowse:AddLegend( cAlias+"_STATUS == '0' ", "WHITE"	, TAFStReinf("0") ) 
	oBrowse:AddLegend( cAlias+"_STATUS == '2' ", "YELLOW"	, TAFStReinf("2") ) 
	oBrowse:AddLegend( cAlias+"_STATUS == '3' ", "RED"		, TAFStReinf("3") ) 
	oBrowse:AddLegend( cAlias+"_STATUS == '4' ", "BLUE"		, TAFStReinf("4") ) 
	oBrowse:AddLegend( cAlias+"_STATUS == '6' ", "BROWN"	, TAFStReinf("6") ) 
	oBrowse:AddLegend( cAlias+"_STATUS == '7' ", "BLACK"	, TAFStReinf("7") ) 

Return



/*/{Protheus.doc} TAFStReinf
Descritivo para Legenda de eventos Reinf
@param cAlias, character, (Alias do registro posicionado)
@param oBrowse, object, (Browse para adicao da legenda)

@Return .T.

@Author Roberto Souza
@Since 11/07/2018
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAFStReinf( cStatus )

	Local cRetStatus as character

	cRetStatus := ""
	
	Do Case

		Case Empty(cStatus)
			cRetStatus = STR0027 //"Evento Aguardando Transmiss�o"
		Case  cStatus == "0"
			cRetStatus = STR0028 //"Evento Pr�-Validado"
		Case cStatus == "1"
			cRetStatus = STR0029 //"Evento Inv�lido"
		Case cStatus == "2"
			cRetStatus = STR0030 //"Evento Transmitido (Aguardando retorno)"
		Case cStatus == "3"
			cRetStatus = STR0031 //"Evento Transmitido Rejeitado"
		Case cStatus == "4"
			cRetStatus = STR0032 //"Evento Transmitido Autorizado"
		Case cStatus == "6"
			cRetStatus = STR0033 //"Exclus�o Transmitida (Aguardando retorno)"
		Case cStatus == "7"
			cRetStatus = STR0034 //"Exclus�o Autorizada"
		OtherWise
			cRetStatus = STR0035 //"Indeterminado"
	End Case

Return( cRetStatus )

//-------------------------------------------------------------------
/*/{Protheus.doc} RetReg
@type			function
@description	Fun��o que ira retornar o V48_IDCNO no caso do tipo de inscri��o 4
				ou o C5M_ID quando o tipo de inscri��o for 1
@author			Matheus Prada
@since			26/02/2018
@version		1.0
@param			
/*/
//---------------------------------------------------------------------
Static Function RetReg(cChave)

Local	cWhere		as character
Local	cFrom		as character
Local	cKeyReg		as character
Local	nX			as numeric
Local	aChave		as array
Local	aKeyReg		as array
Local	aReg		as array

nX		:= 0
cWhere	:= ""
cFrom	:= ""
cKeyReg	:= ""
aReg 	:= {}
aChave	:= {}
aKeyReg	:= {}

If !Empty(cChave)
	aChave		:= STRTOKARR(cChave, "|")
	cKeyReg		:= ""
	cWhere		:= ""
	cFrom		:= ""
	aRet		:= {}
	aKeyReg		:= {}
	aReg		:= {}

	If Alltrim( &(aChave[2]) ) == '1'

		aKeyReg 	:= FWLoadSM0()
		nX			:= 0

		AADD(aReg, "C5M")

		For nX:=1 to Len(aKeyReg)
			
			If aKeyReg[nX][18] == &(aChave[3])
				cKeyReg += " '" + aKeyReg[nX][2] + "',"
			EndIf

		Next

		cKeyReg := " AND C5M.C5M_FILIAL IN (" + SubStr(cKeyReg, 1, ( Len(cKeyReg) - 1 ) ) + ")"

		AADD(aReg, cKeyReg)
	Else 

		AADD(aReg, "V48")


		cFrom := " INNER JOIN " + RetSqlName("C5M") + " C5M ON C5M.C5M_FILIAL = V48.V48_FILIAL "
		cFrom += " AND C5M.C5M_ID = V48.V48_ID AND C5M.D_E_L_E_T_='' INNER JOIN " + RetSqlName("T9C") + " T9C "
		cFrom += " ON T9C.T9C_FILIAL = V48.V48_FILIAL AND T9C.T9C_ID = V48.V48_IDCNO "
		cFrom += " AND T9C_NRINSC = " + "'" + &(aChave[3]) + "'" + " AND T9C.D_E_L_E_T_='' "
			
		cWhere := " AND V48.D_E_L_E_T_='' "

		AADD(aReg, cFrom)
		AADD(aReg, cWhere)

	EndIf
EndIf

Return aReg

//-------------------------------------------------------------------
/*/{Protheus.doc} RetReg

@type			function
@description	Retorna um array com os c�digos das filiais,
@description	Foi necessario um array para os casos em que 
@description	mais de uma filial tenha o mesmo CNPJ
@author			Katielly Rezende
@since			02/03/2020
@version		1.0
@param			cInscReg: N�mero de inscri��o do registro posicionado 
/*/
//---------------------------------------------------------------------
Static Function RetNrInsc(cInscReg)

	local aKeyReg as array
	local nX	  as numeric 
	local nCont	  as numeric 
	local cFilReg as character

	aKeyReg := FWLoadSM0()
	nX		:= 0	
	nCont	:= 0 	
	cFilReg := ""

	For nX:=1 to Len(aKeyReg)

		If aKeyReg[nX][18] == cInscReg
			If nCont==0
				cFilReg := "'" + aKeyReg[nX][2] + "'" 
				nCont++
			else
				cFilReg += ",'" + aKeyReg[nX][2] + "'" 
			EndIf
		EndIf

	Next

return cFilReg
