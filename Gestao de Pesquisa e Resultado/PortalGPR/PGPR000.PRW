#INCLUDE "PGPR000.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

#DEFINE CRLF					Chr( 13 )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿎ampo Tipo Combobox - Utilizado como Logico�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
#DEFINE SIM					"1"		//Sim
#DEFINE NAO					"2"		//Nao

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿛GPR000   튍utor  쿗uiz Felipe Couto    � Data �  02/03/05   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Mostra as regras da pesquisa.                               볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros�                                                             볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞IGAGPR     						                           볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇튍nalista  � Data/Bops/Ver 쿘anutencao Efetuada                      	   볍�
굇勁袴袴袴袴曲袴袴袴袴佶袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇쿘ichel M. |19/04/07�912   쿍ops 124570 - Atualizacao de layout do MP10  볍�
굇훤袴袴袴袴賈袴袴袴袴鳩袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Web Function PGPR000()

Local cHtml 		:= ""					//Pagina WEB
Local cHtmlRegra	:= ""					//Tabela (HTML) dinamica das regras da pesquisa
Local cPesquisa		:= ""					//String contendo os dados da Pesquisa
Local cCodPesq		:= ""					//Codigo da Pesquisa
Local cCodQuest		:= ""					//Codigo do Questionario
Local cCodGrupo		:= ""					//Codigo do Grupo
Local cCodSubGrupo	:= ""					//Codigo do SubGrupo
Local cCodPerg		:= ""					//Codigo da Questao
Local cTipo			:= ""					//Tipo de apresentacao
Local cPreview		:= ""					//Preview
Local cObjetivo		:= ""					//Objetivo - Entrevistador
Local cErro			:= ""					//Mensagem de Erro

Local nI			:= 0					//Variavel de apoio

Local oObj									//Objeto WS - WSGPRRESEARCH

WEB EXTENDED INIT cHtml

//旼컴컴컴컴컴컴컴컴컴컴컴컴커
//쿣erifica integridade do Id�
//읕컴컴컴컴컴컴컴컴컴컴컴컴켸
If !Empty( HttpGet->cId )
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿣erifica intergridade do parametro cId�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If fURL2Pesq( HttpGet->cId, @cPesquisa )
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿐xemplo de string contendo os dados da Pesquisa�
		//�000001000001000001000001000001111xxx           �
		//�1     2     3     4     5     6789             �
		//�1 - Pesquisa                                   �
		//�2 - Questionario                               �
		//�3 - Grupo                                      �
		//�4 - SubGrupo                                   �
		//�5 - Questao                                    �
		//�6 - Tipo                                       �
		//�7 - Preview                                    �
		//�8 - Objetivo                                   �
		//�9 - Chave do Respondente                       �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		cCodPesq		:= SubStr( cPesquisa, 1, 6 )
		cCodQuest		:= SubStr( cPesquisa, 7, 6 )
		cCodGrupo 		:= SubStr( cPesquisa, 13, 6 )
		cCodSubGrupo	:= SubStr( cPesquisa, 19, 6 )
		cCodPerg		:= SubStr( cPesquisa, 25, 6 )
		cTipo			:= SubStr( cPesquisa, 31, 1 )
		cPreview		:= SubStr( cPesquisa, 32, 1 )
		cObjetivo		:= SubStr( cPesquisa, 33, 1 )
	
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿔nicializa o objeto WS - WSGPRRESEARCH�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		oObj := WSGPRRESEARCH():New()
		WsChgURL( @oObj, "GPRRESEARCH.APW" )
		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿛arametros do metodo GETRESEARCH�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		oObj:cUSERCODE		:= "MSALPHA"
		oObj:cRESEARCHCODE	:= cCodPesq
		
		//cUSERCODE,cRESEARCHCODE,cQUERYADDWHERE
		If oObj:GETRESEARCH()
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//쿝esultado do Metodo GETRESEARCH�
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			HttpSession->PGPR000RESULT := { oObj:oWSGETRESEARCHRESULT }

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//쿣erificacao da Ativacao, Data de Vigencia Inicial e Final�
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			If cPreview == "0"
				If !fChkPesq( oObj:oWSGETRESEARCHRESULT:cSTATUS, oObj:oWSGETRESEARCHRESULT:dINITIALDATE, ;
								oObj:oWSGETRESEARCHRESULT:cINITIALHOUR, oObj:oWSGETRESEARCHRESULT:dFINALDATE, ;
								oObj:oWSGETRESEARCHRESULT:cFINALHOUR, oObj:oWSGETRESEARCHRESULT:cDESCRIPTION, ;
								@cErro )
				
					Return fHtmlAlert( STR0001, '<td align="middle">' + cErro + '</td>' ) //"Aten豫o"
				EndIf
			EndIf
	
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//쿘ontagem da tabela (HTML) dinamica das regras da pesuisa�
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			cHtmlRegra += '<table width="260" border="0" align="right" cellpadding="0" cellspacing="0" bordercolor="#E5E5E5">' + CRLF
			cHtmlRegra += '  <tr>' + CRLF
			cHtmlRegra += '    <td bordercolor="#FFFFFF" class="titulo" valign="top">' + CRLF
			cHtmlRegra += '      <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">' + CRLF
			cHtmlRegra += '        <tr>' + CRLF
			cHtmlRegra += '          <td height="32" class="titulo">&nbsp;&nbsp;&nbsp;&nbsp;<span class="tituloLoginGde">' + STR0010 + '</span></td>' + CRLF
			cHtmlRegra += '        </tr>' + CRLF
			cHtmlRegra += '        <tr>' + CRLF
			cHtmlRegra += '          <td class="FundoPontilhado"><img src="../imagens/Por/transparente.gif" width="5" height="5"></td>' + CRLF
			cHtmlRegra += '        </tr>' + CRLF
			cHtmlRegra += '      </table>' + CRLF
			cHtmlRegra += '      <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0">' + CRLF
	
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//쿌rray com as Regras da Pesquisa�
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			For nI := 1 To Len( oObj:oWSGETRESEARCHRESULT:oWSLISTOFRULE:oWSRULEVIEW )
				cHtmlRegra += '        <tr>' + CRLF
				cHtmlRegra += '          <td width="50%" class="textopeq"><span class="TituloLogin">' + oObj:oWSGETRESEARCHRESULT:oWSLISTOFRULE:oWSRULEVIEW[nI]:cWEBTEXT + ':</span></td>' + CRLF
				cHtmlRegra += '          <td width="50%" class="titulo"><input name="R' + oObj:oWSGETRESEARCHRESULT:oWSLISTOFRULE:oWSRULEVIEW[nI]:cITEM + '" type="text" class="combo" value="" maxlength="40"></td>' + CRLF
				cHtmlRegra += '        </tr>' + CRLF
			Next nI
	
			cHtmlRegra += '        <tr>' + CRLF
			cHtmlRegra += '          <td height="33" class="TituloMenor">&nbsp;</td>' + CRLF
			cHtmlRegra += '          <td valign="bottom" class="titulo">' + CRLF
			cHtmlRegra += '            <input name="Button" type="button" class="Botoes" value="' + STR0002 + '" onClick="document.forms[0].submit()">' + CRLF //"enviar"
			cHtmlRegra += '            <input name="Submit2" type="reset" class="Botoes" value="' + STR0003 + '">' + CRLF //"limpar"
			cHtmlRegra += '          </td>' + CRLF
			cHtmlRegra += '        </tr>' + CRLF
			cHtmlRegra += '        <tr>' + CRLF
			cHtmlRegra += '          <td colspan="2">&nbsp;</td>' + CRLF
			cHtmlRegra += '        </tr>' + CRLF
			cHtmlRegra += '      </table>' + CRLF
			cHtmlRegra += '    </td>' + CRLF
			cHtmlRegra += '  </tr>' + CRLF
			cHtmlRegra += '</table>' + CRLF
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//쿞ession com a tabela (HTML) dinamica�
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			HttpSession->PGPR000INFO := cHtmlRegra
		Else
			Return fHtmlAlert( STR0001, "" ) //"Aten豫o"
		EndIf
		
		cHtml += ExecInPage( "PGPR000" )
	Else
		Return fHtmlAlert( STR0001, STR0004 ) //"Aten豫o"###"O ID n�o � v�lido. <br>Favor entrar em contato com os respons�veis t�cnicos da Pesquisa, ou com a Microsiga Software S/A."
	EndIf
Else
	Return fHtmlAlert( STR0001, STR0005 ) //"Aten豫o"###"O ID n�o encontrado. <br>Favor entrar em contato com os respons�veis t�cnicos da Pesquisa, ou com a Microsiga Software S/A.</td>"
EndIf

WEB EXTENDED END

Return cHtml

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿛GPR001   튍utor  쿗uiz Felipe Couto    � Data �  02/03/05   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Valida Regras da Pesquisa.                                  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros�                                                             볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞IGAGPR     						                           볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇튍nalista  � Data/Bops/Ver 쿘anutencao Efetuada                      	   볍�
굇勁袴袴袴袴曲袴袴袴袴佶袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇훤袴袴袴袴賈袴袴袴袴鳩袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Web Function PGPR001()

Local cHtml 		:= ""						//Pagina WEB
Local cFunction		:= ""						//Funcao de validacao
Local cPesquisa		:= ""						//String contendo os dados da Pesquisa
Local cCodPesq		:= ""						//Codigo da Pesquisa
Local cCodQuest		:= ""						//Codigo do Questionario
Local cCodGrupo		:= ""						//Codigo do Grupo
Local cCodSubGrupo	:= ""						//Codigo do SubGrupo
Local cCodPerg		:= ""						//Codigo da Questao
Local cTipo			:= ""						//Tipo de apresentacao
Local cPreview		:= ""						//Preview
Local cObjetivo		:= ""						//Objetivo - Entrevistador
Local cCodResp		:= ""						//Chave do Respondente
Local cErro			:= ""						//Mensagem de Erro

Local nI			:= 0						//Variavel de apoio

Local lRet			:= .T.						//Retorno da Validacao

Local oObj										//Objeto WS - WSGPRRESEARCH

WEB EXTENDED INIT cHtml

//旼컴컴컴컴컴컴컴컴컴컴컴컴커
//쿣erifica integridade do Id�
//읕컴컴컴컴컴컴컴컴컴컴컴컴켸
If !Empty( HttpPost->cId )
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿣erifica intergridade do parametro cId�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If fURL2Pesq( HttpPost->cId, @cPesquisa )
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿐xemplo de string contendo os dados da Pesquisa�
		//�000001000001000001000001000001111xxx           �
		//�1     2     3     4     5     6789             �
		//�1 - Pesquisa                                   �
		//�2 - Questionario                               �
		//�3 - Grupo                                      �
		//�4 - SubGrupo                                   �
		//�5 - Questao                                    �
		//�6 - Tipo                                       �
		//�7 - Preview                                    �
		//�8 - Objetivo                                   �
		//�9 - Chave do Respondente                       �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		cCodPesq		:= SubStr( cPesquisa, 1, 6 )
		cCodQuest		:= SubStr( cPesquisa, 7, 6 )
		cCodGrupo 		:= SubStr( cPesquisa, 13, 6 )
		cCodSubGrupo	:= SubStr( cPesquisa, 19, 6 )
		cCodPerg		:= SubStr( cPesquisa, 25, 6 )
		cTipo			:= SubStr( cPesquisa, 31, 1 )
		cPreview		:= SubStr( cPesquisa, 32, 1 )
		cObjetivo		:= SubStr( cPesquisa, 33, 1 )
	
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿔nicializa o objeto WS - WSGPRRESEARCH�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		oObj := WSGPRRESEARCH():New()
		WsChgURL( @oObj, "GPRRESEARCH.APW" )

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿛arametros do metodo GETRESEARCH�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		oObj:cUSERCODE		:= "MSALPHA"
		oObj:cRESEARCHCODE	:= cCodPesq
		
		//cUSERCODE,cRESEARCHCODE,cQUERYADDWHERE
		If oObj:GETRESEARCH()
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//쿣erificacao da Ativacao, Data de Vigencia Inicial e Final�
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			If cPreview == "0"
				If !fChkPesq( oObj:oWSGETRESEARCHRESULT:cSTATUS, oObj:oWSGETRESEARCHRESULT:dINITIALDATE, ;
								oObj:oWSGETRESEARCHRESULT:cINITIALHOUR, oObj:oWSGETRESEARCHRESULT:dFINALDATE, ;
								oObj:oWSGETRESEARCHRESULT:cFINALHOUR, oObj:oWSGETRESEARCHRESULT:cDESCRIPTION, ;
								@cErro )
				
					Return fHtmlAlert( STR0001, '<td align="middle">' + cErro + '</td>' ) //"Aten豫o"
				EndIf
			EndIf
		Else
			Return fHtmlAlert( STR0001, "" ) //"Aten豫o"
		EndIf

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿍usca todos os campos do Post�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		For nI := 1 To Len( HttpPost->aPost )
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//쿙ome do Campo contendo o item da Regra da Pesquisa�
			//쿝XXXXXX                                           �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If SubStr( HttpPost->aPost[nI], 1, 1 ) == "R"
				nPos := aScan( oObj:oWSGETRESEARCHRESULT:oWSLISTOFRULE:oWSRULEVIEW, { |x| x:cITEM == SubStr( HttpPost->aPost[nI], 2, Len( HttpPost->aPost[nI] ) ) } )
				
				If nPos > 0
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
					//쿙ome da Funcao sem os parenteses�
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
					cFunction := SubStr( oObj:oWSGETRESEARCHRESULT:oWSLISTOFRULE:oWSRULEVIEW[nPos]:oWSVALIDATION:cVALFUNCTION, 1, At( "(", oObj:oWSGETRESEARCHRESULT:oWSLISTOFRULE:oWSRULEVIEW[nPos]:oWSVALIDATION:cVALFUNCTION ) - 1 )
	
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					//쿐xecuta a Funcao de Validacao�
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					If &( cFunction + "( '" + &( "HttpPost->" + HttpPost->aPost[nI] ) + "' )" )
						//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
						//쿢tiliza campo como Chave do Respondente�
						//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
						If Empty( oObj:oWSGETRESEARCHRESULT:oWSLISTOFRULE:oWSRULEVIEW[nPos]:cRESEARCHEDKEY ) .OR. ;
							oObj:oWSGETRESEARCHRESULT:oWSLISTOFRULE:oWSRULEVIEW[nPos]:cRESEARCHEDKEY == SIM
							
							cCodResp += &( "HttpPost->" + HttpPost->aPost[nI] )
						EndIf
						
						lRet := .T.
					Else
						//旼컴컴컴컴컴컴컴컴커
						//쿣alidacao invalida�
						//읕컴컴컴컴컴컴컴컴켸
						HttpPost->cErro := STR0006 + oObj:oWSGETRESEARCHRESULT:oWSLISTOFRULE:oWSRULEVIEW[nPos]:oWSVALIDATION:cDESCRIPTION + STR0007 //"Valida豫o <b>"###"</b> n�o efetuada."
						
						lRet := .F.
						
						Exit
					EndIf
				EndIf
			EndIf
		Next nI
	Else
		Return fHtmlAlert( STR0001, STR0008 ) //"Aten豫o"###"O ID n�o � v�lido. <br>Favor entrar em contato com os respons�veis t�cnicos da Pesquisa, ou com a Microsiga Software S/A.</td>"
	EndIf
	
	If lRet
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿙ovo Id para Realizacao da Pesquisa contendo a chave do Respondente�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		HttpPost->cId := fPesq2URL( cCodPesq + cCodQuest + 	cCodGrupo + cCodSubGrupo + ;
										cCodPerg + cTipo + cPreview + cObjetivo + ;
				  						cCodResp + DToC( Date() ) + SubStr( Time(), 1, 5 ) )
	
		//旼컴컴컴컴컴컴컴컴커
		//쿝etorna a Pesquisa�
		//읕컴컴컴컴컴컴컴컴켸
		cHtml := W_PGPR010()
	Else
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿛arametro cId vem por Post, mas ao voltar para a tela�
		//쿭e Regra de Pesquisa manter como Get                 �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		HttpGet->cId := HttpPost->cId
	
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿝etorna a Regra de Pesquisa com a Mensagem de Erro�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		cHtml := W_PGPR000()
	EndIf
Else
	Return fHtmlAlert( STR0001, STR0005 ) //"Aten豫o"###"O ID n�o encontrado. <br>Favor entrar em contato com os respons�veis t�cnicos da Pesquisa, ou com a Microsiga Software S/A.</td>"
EndIf

WEB EXTENDED END

Return cHtml