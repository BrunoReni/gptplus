#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PPLSXF3   �Autor  �Totvs				  � Data �  07.07.2011 ���
��������������������������������������������������������������������������͹��
���Desc.     � Retorna os dados do F3 do sistema.                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PPLSXF3()
LOCAL oObj			:= NIL
LOCAL cHtml 		:= ""
LOCAL cMsgErro		:= ""
LOCAL aRet			:= {}
LOCAL aWebHeader 	:= {}
LOCAL aGetTemp	 	:= {}
LOCAL lOnBlur		:= .F.
LOCAL aCmpsGen    := Nil
Local cUrl := ""
Local aCustomHead := nil
Local nI := 1
WEB EXTENDED INIT cHtml //Aqui n�o tem o insite pq � utilizada no layout generico onde n�o tem login

//Verifica se o usuario esta logado/possui sessao
if ValType(HttpSession->USR_INFO) == 'U'
	Return W_PPLSOUT()
EndIf

//��������������������������������������������������������������������������������������
//�Recebendo os Gets F3 generica - No envio de busca nao retorna os parametros da chamada original
//��������������������������������������������������������������������������������������
If ValType(HttpGet->cAliasGen) <> 'U' .AND.  ;
		ValType(HttpGet->cCamposGen) <> 'U' .AND. ;
		ValType(HttpGet->cCodDesGen) <> 'U'
	aCmpsGen := {}
	aADD(aCmpsGen , HttpGet->cAliasGen)
	aADD(aCmpsGen , HttpGet->cCamposGen)
	aADD(aCmpsGen , iif( !Empty(HttpGet->cCondGen),HttpGet->cCondGen, "") )
	aADD(aCmpsGen , HttpGet->cCodDesGen)
EndIf
//������������������������������������������������������
//�Inclusao generica
//������������������������������������������������������
If ValType(HttpGet->cIncGen) <> 'U'
	HttpSession->cAphExecInc := HttpGet->cIncGen
Else
	HttpSession->cAphExecInc := ""
EndIf
//������������������������������������������������������
//�Para controle de erro
//������������������������������������������������������
If Empty( HttpSession->_HTMLERRO )
	HttpSession->_HTMLERRO := { NIL, NIL, NIL }
EndIf
//�������������������������������������������������������������������
//�Array para montagem da tela
//�������������������������������������������������������������������
HttpSession->PPLSXF3INFO := {}
//�������������������������������������������������������������������
//�Paginacao WEB
//�������������������������������������������������������������������
If Empty( HttpGet->cPagina ) .Or. HttpGet->cPagina == '0'
	HttpGet->cPagina := "1"
EndIf
//�������������������������������������������������������������������
//�Ws de Struturas
//�������������������������������������������������������������������
oObj := WSPLSXF3():New()
IIf (!Empty(PlsGetAuth()),oObj:_HEADOUT :=  { PlsGetAuth() },)
WsChgUrl( @oObj, "PLSXF3.APW" )
//�������������������������������������������������������������������
//�Parametros do metodo GetF3
//�������������������������������������������������������������������
oObj:cUserCode		:= "MSALPHA"
oObj:cUserPlsCode	:= getUsrWeb()
oObj:nTpPor			:= getTpPortal()
oObj:nRegPagina		:= 7
oObj:nPaginaIni		:= Val( HttpGet->cPagina )
oObj:cFunName		:= HttpGet->cFunName
oObj:cVldGen		:= HttpGet->cVldGen
oObj:cTpBusca		:= IiF(!Empty(HttpGet->Tipo) ,HttpGet->Tipo,"0")
oObj:cBusca			:= IIF(!empty(HttpGet->Busca),HttpGet->Busca,"")
oObj:cCampoOri		:= IIF(!empty(HttpGet->cCampoOri),HttpGet->cCampoOri,"")
oObj:cTpGuia		:= IIF(ValType(HttpSession->cTp) <> "U" ,HttpSession->cTp,"")
oObj:cBuscaVin		:= iIf(!empty(HttpGet->BuscaVin),HttpGet->BuscaVin,"") //busca vinculada - por exemplo f3 dente e face que s�o vinculados ao procedimento, portanto aqui vem o codigo do procedimento

//�������������������������������������������������������������������
//�Parametros do metodo GetF3 para F3 gen�rica
//�������������������������������������������������������������������
If ValType(aCmpsGen) != 'U'
	oObj:cAliasGen		:= aCmpsGen[1]
	oObj:cCamposGen		:= aCmpsGen[2]
	oObj:cCondGen			:= IIF(!Empty(aCmpsGen[3]),aCmpsGen[3],"")
	oObj:cCodDesGen		:= aCmpsGen[4]
EndIf
//�������������������������������������������������������������������
//�Executa metodo para montar Header
//�������������������������������������������������������������������
If oObj:getF3()
	//���������������������������������������������������������������
	//�Monta matriz com campo e regra
	//���������������������������������������������������������������
	aRet 		:= PLSMWH(HttpGet->F3CmpDes,oObj:oWSGETF3RESULT:cCampos)
	aWebHeader := aRet[1]
	aGetTemp	:= aRet[2]
	//�������������������������������������������������������������������
	//�Funcao de montagem da descricao dos campos da tela
	//�������������������������������������������������������������������
	GridHeader(	HttpSession->PPLSXF3INFO, oObj:oWSGETF3RESULT:oWSHEADER:oWSBRWHEADER, aWebHeader )
	if !empty(oObj:oWSGETF3RESULT:cCustomHead)
		//muda a descri��o do SX3 para descri��o informada na query
		aCustomHead := {}
		aCustomHead := StrToArray( oObj:oWSGETF3RESULT:cCustomHead, ',' )
		for nI := 1 to len(aCustomHead)
			HttpSession->PPLSXF3INFO[1][nI] := aCustomHead[nI]
		next nI
	endIf

	if(empty(oObj:oWSGETF3RESULT:cTableEmpty))
		//������������������������������������������������������������������Ŀ
		//�Funcao de montagem dos campos da tela							 �
		//��������������������������������������������������������������������
		SetEstilo( { "#FFFFFF", "TituloMenor", "TituloMenorBold", "texto", "combo", "comboselect" } )
		GridLinesEx( { 	HttpSession->PPLSXF3INFO, oObj:oWSGETF3RESULT:oWSHEADER:oWSBRWHEADER,oObj:oWSGETF3RESULT:oWSMVIEWREG:oWSSVIEWREG, aWebHeader, .F.,"A", ,0 } )
		//������������������������������������������������������������������Ŀ
		//�Script para abertura da tela de F3								 �
		//��������������������������������������������������������������������
		HttpSession->PPLSXF3SCRIPT := GeraJSPls( aGetTemp[1], oObj:oWSGETF3RESULT:oWSMVIEWREG:oWSSVIEWREG, lOnBlur, .T. )
	else
		HttpGet->Tipo := "0"
		HttpGet->Busca := ""
	endif
Else
	cMsgErro := PWSGetWSError()
EndIf
//��������������������������������������������������������������������
//�Se nao tiver erro exibe f3
//��������������������������������������������������������������������
If Empty(cMsgErro)
	ExecInPage( "PPLSXF3FRAME" )
Else
	HttpSession->_HTMLERRO[1] := "Aten��o"
	HttpSession->_HTMLERRO[2] := cMsgErro
	HttpSession->_HTMLERRO[3] := ""

	cHtml += ExecInPage("PPLSMSG")
EndIf

WEB EXTENDED END

Return cHtml
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PPLSXF3GRID�Autor  �Totvs				   � Data �  07/07/11  ���
��������������������������������������������������������������������������͹��
���Desc.     � Retorna a tela com os dados do F3 do sistema.               ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PPLSXF3GRID()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

ExecInPage( "PPLSXF3GRID" )

WEB EXTENDED END

Return cHtml
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PPLSXF3INC �Autor  �Totvs				   � Data �  07/07/11  ���
��������������������������������������������������������������������������͹��
���Desc.     � Abre tela de inclus�o generica							   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PPLSXF3INC()
LOCAL cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"
//������������������������������������������������������������������Ŀ
//�Se vai para a pagina de inclusao ou retorna pra grid				 �
//��������������������������������������������������������������������
If !Empty(HttpSession->cAphExecInc)
	cHtml += ExecInPage( HttpSession->cAphExecInc )
Else
	Return ExecInPage( "PPLSXF3FRAME" )
EndIf

WEB EXTENDED END

Return cHtml
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PPLSXF3BUSCA�Autor  �Totvs		      � Data �  07/07/11   ���
��������������������������������������������������������������������������͹��
���Desc.     � Retorna a tela de busca dos dados do F3 do sistema.         ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PPLSXF3BUSCA()
Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

ExecInPage( "PPLSXF3BUSCA" )

WEB EXTENDED END

Return cHtml
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PLSMWH      �Autor  �Totvs		      � Data �  07/07/11   ���
��������������������������������������������������������������������������͹��
���Desc.     � Monta matriz Header										   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function PLSMWH(cDestino,cCampos)
	LOCAL nI		 := 0
	LOCAL aWebHeader := {}
	LOCAL aGetTemp	 := { {},{} }
	//��������������������������������������������������������������������������
	//�Ajuste para pegar o ultimo campo
	//��������������������������������������������������������������������������
	cDestino := cDestino + ','
	cCampos	 := cCampos  + ','
	//��������������������������������������������������������������������������
	//�Monta campos de destino da tela de chamada
	//��������������������������������������������������������������������������
	If !Empty(cDestino)
		//��������������������������������������������������������������������������
		//�Campos de destino
		//��������������������������������������������������������������������������
		While ( nAt := AT(",",cDestino) ) > 0
			nI++
			AaDd( aGetTemp[1], { 'cRegCamp'+AllTrim(Str(nI)), SubStr( cDestino, 1, AT( ",",cDestino)-1 ) } )
			cDestino := AllTrim(SubStr( cDestino, AT( ",",cDestino)+1,Len(cDestino) ))
		EndDo
	EndIf
	//��������������������������������������������������������������������������
	//�Monta grid do f3
	//��������������������������������������������������������������������������
	If !Empty(cCampos)
		nI := 0
		//��������������������������������������������������������������������������
		//�Campos do grid
		//��������������������������������������������������������������������������
		While ( nAt := AT(",",cCampos) ) > 0
			nI++

			AaDd( aGetTemp[2], 'cRegCamp' + AllTrim( Str(nI) ) )
			AaDd( aWebHeader, SubStr( 'cRegCamp' + AllTrim( Str(nI) ), 2 ) )

			cCampos := AllTrim( SubStr( cCampos, AT( ",",cCampos)+1,Len(cCampos) ) )
		EndDo
	EndIf
	//��������������������������������������������������������������������������
	//�Fim da Funcao
	//��������������������������������������������������������������������������
Return( {aWebHeader,aGetTemp} )
