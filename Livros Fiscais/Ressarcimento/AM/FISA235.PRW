#INCLUDE "PROTHEUS.CH"
Static lFsa235Und    := ExistBlock("FSA235UND")

/*/{Protheus.doc} FISA235
Fun��o que gera o arquivo de ressarcimento do ICMS ST DT-e
@type function
@version
@author raphael.augusto
@since 20/02/2020
@return return_type, return_description
/*/
Function FISA235(lAutomato)
Private cAliasPri	:= GetNextAlias()
Private cVersao 	:= "2.00"
DEFAULT lAutomato	:= .F.

// MV_PAR01   Data De ?
// MV_PAR02   Data Ate ?
// MV_PAR03   Nome Respons�vel ?
// MV_PAR04   Telefone Respons�vel ?
// MV_PAR05   Email Respons�vel ?
// MV_PAR06   Dir. Destino ?
// MV_PAR07   Gera XML ? 1-Lista Produto | 2-Lista Pedido
// MV_PAR08   Modalidade Ressarcimento ?  1-ICMS ST | 2-Baixa Estoque
// MV_PAR09   Vers�o ?  2.00
If lAutomato .Or. Pergunte("FISA235",.T.)
	getQryXML()
	Processa( { || XMLPedido(lAutomato) } , "Processando Arq. Lista de Pedido" )	//"Processando Arquivo XML"
EndIf
If Select(cAliasPri) > 0
	(cAliasPri)->(DbCloseArea())
EndIf
Return

/*/{Protheus.doc} XMLPedido
Gera o arquivo xml do pedido do ressarcimento DT-e.
A SEFAZ AM institiu que os arquivos gerados por essa rotina dever ser subtimetidos via upload no portal DT-e da SEFAZ AM
A fun��o XML pedido gera o XML de pedido (XMLPEDIDO) e produto (XMLPRODUTO).
Ambos s�o gerados juntos pois careciamos de informa��o por parte da SEFAZ para gerar os dois arquivos de forma distinta.
@type function
@version
@author raphael.augusto
@since 20/02/2020
@return return_type,
/*/
Static Function XMLPedido(lAutomato)
Local cXML			:= ""
Local aCHVNF		:= {}
Local aListProd     := {}
Local cNome			:= "RESSTAM_LISTA_PEDIDO"
Local cAno      	:= Str(Year( MV_PAR01 ),4)
Local cPeriodo     	:= StrZero(Month( MV_PAR01 ),2)
DEFAULT lAutomato	:= .F.

cXML	+=	'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
cXML	+=	'<enviOperacaoRessarcimento xmlns="http://www.sefaz.am.gov.br/ressarcimento">'
cXML	+=	'<versao>' + cVersao + '</versao>'
cXML	+= noDeclarant( cVersao , "2" , cAno , cPeriodo)
cXML	+= noListOper(@aCHVNF,@aListProd)
cXml	+= noListNFE(aCHVNF)
cXML	+= '</enviOperacaoRessarcimento>'
cNome   += cAno + cPeriodo
GravaArq(cXML, cNome , lAutomato)
XMLProduto( aListProd, lAutomato)
Return

/*/{Protheus.doc} XMLProduto
Gera o arquivo xml do produto do ressarcimento DT-e. Ser� feito upload no site da sefaz AM
@type function
@version
@author raphael.augusto
@since 20/02/2020
@return return_type,
/*/
Static Function XMLProduto(aListProd,lAutomato)
Local cXML	:= ""
Local cNome			:= "RESSTAM_LISTA_PRODUTO"
Local cAno      	:= Str(Year( MV_PAR01 ),4)
Local cPeriodo     	:= StrZero(Month( MV_PAR01 ),2)
Local nX            := 1
Local aUnico		:= {}
DEFAULT aListProd   := {}

cXML	+=	'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
cXML	+=	'<enviProdutoRessarcimento xmlns="http://www.sefaz.am.gov.br/ressarcimento">'
cXML	+=	'<versao>' + cVersao + '</versao>'
cXML	+= noDeclarant()
cXML	+= 	'<listaProdutos>'
For nX := 1 To Len(aListProd)
	// Controla registros �nicos - Baseado na estrutura do XML para n�o gerar informa��es repetidas estamos criando uma PK na lista de produto.
	// Caso a SEFAZ de amazonas crie um campo/tag que idenfique o documento na lista de produto essa PK pode ser retirara.
	If aScan(aUnico,{|x| x[1] == aListProd[nX,1] .And. x[2] == aListProd[nX,5]  .And. x[3] == aListProd[nX,6] .And. x[4] == aListProd[nX,7]   }) == 0
				     //Cod.Prod          CNPJ Fornecedor  Cod.Prod.Fornec   Uni.Fornecedor
		AADD(aUnico, { aListProd[nX,1] , aListProd[nX,5], aListProd[nX,6] , aListProd[nX,7]  })
	    cXML	+= noProduto( aListProd[nX][1], aListProd[nX][2], aListProd[nX][3], aListProd[nX][4] ,aListProd[nX][5] ,aListProd[nX][6] ,aListProd[nX][7])
	EndIf
Next nX
cXML	+= 	'</listaProdutos>'
cXML	+= 	'</enviProdutoRessarcimento>'
cNome   += 	cAno + cPeriodo
GravaArq(cXML, cNome , lAutomato)
Return

/*/{Protheus.doc} noProduto
Cria o n� do Produto do XML da lista de produtos
@type function
@version
@author raphael.augusto
@since 20/02/2020
@return return_type, Retorna uma string com as informa��es do n� do XML
/*/
Static Function noProduto(cCod,cDescri,cUni,cFator,cCNPJ,cCodFor,cUniFor)
Local cXML          := ""
cXML	+=	'<produto>'
cXML	+=	'	<codInternoProduto>'+AllTrim(cCod)+'</codInternoProduto>' // Protheus
cXML	+=	'	<descricaoProduto>'+AllTrim(cDescri)+'</descricaoProduto>' // Protheus
cXML	+=	'	<unidadeInternaProduto>'+AllTrim(cUni)+'</unidadeInternaProduto>' // Protheus
cXML	+=	'	<fatorConversao>'+AllTrim(cFator)+'</fatorConversao>' // Protheus
cXML	+=	'	<cnpjFornecedor>'+AllTrim(cCNPJ)+'</cnpjFornecedor>' // Protheus
cXML	+=	'	<codProdFornecedor>'+AllTrim(cCodFor)+'</codProdFornecedor>' // Protheus / Ponto de entrada
cXML	+=	'	<unidadeProdutoFornecedor>'+AllTrim(cUniFor)+'</unidadeProdutoFornecedor>' // Protheus / Ponto de entrada
cXML 	+=	'</produto>'
Return cXML


/*/{Protheus.doc} noListOper
Cria o n� do lista de opera��es do XML da lista de pedidos
@type function
@version
@author raphael.augusto
@since 20/02/2020
@return return_type, Retorna uma string com as informa��es do n� do XML
/*/
Static Function noListOper( aCHVNF , aListProd )
Local cXML          := ""
Local cChave		:= ""
Local aFsa235Und    := {}
DEFAULT aListProd   := {}
DEFAULT aCHVNF     	:= {}

cXml += '<listaOperacoes>
While (cAliasPri)->(!Eof())
	If Empty(cChave) .Or. cChave <>  (cAliasPri)->FT_CHVNFE
		cChave :=  (cAliasPri)->FT_CHVNFE
		cXml += '<operacao>
		cXml += '<chaveNFe>' + (cAliasPri)->FT_CHVNFE + '</chaveNFe>
		cXml += '<listaItens>'
		While (cAliasPri)->(!Eof()) .And. cChave ==  (cAliasPri)->FT_CHVNFE
			cXml += noListItem()

            // Retorna as informa��es da nota fiscal do fornecedor por ponto de entrada referente a unidade de medida.
            aadd( aListProd, { (cAliasPri)->B1_COD      ,;  // 1 C�digo do produto
                                (cAliasPri)->B1_DESC    ,;  // 2 Descri��o do produto
                                (cAliasPri)->B1_UM      ,;  // 3 Unidade de medida fiscal
                                (cAliasPri)->B1_CONV    ,;  // 4 Unidade de convers�o
                                (cAliasPri)->A2_CGC     ,;  // 5 C�digo do fornecedor
                                (cAliasPri)->B1_COD     ,;  // 6 C�digo do produto do fornecedor
                                (cAliasPri)->B1_UM     ,;  // 7 Unidade de medida do fornecedor
                                0                       ,;  // 8 Fator de convers�o entre o produto do Fornecedor e o principal do cliente
                                '' })                       // 9 Tipo de Convers�o M Multiplica��o  / Divis�o

			If lFsa235Und
				aFsa235Und := ExecBlock("FSA235UND", .F., .F., {cAliasPri})
				If ValType(aFsa235Und) == "A" .And. Len(aFsa235Und) == 4 .And. ValType(aFsa235Und[1]) == 'C' .And. ValType(aFsa235Und[2]) == 'C' .And. ValType(aFsa235Und[3]) == 'N' .And. ValType(aFsa235Und[4]) == 'C'
					 aListProd[Len(aListProd)][6]   := aFsa235Und[1]
                     aListProd[Len(aListProd)][7]   := aFsa235Und[2]
                     aListProd[Len(aListProd)][8]   := aFsa235Und[3]
                     aListProd[Len(aListProd)][9]   := aFsa235Und[4]
				Endif
			EndIf

            // Grava chaves de acessos �nicas (distinct)
			If ! aScan(aCHVNF, {|x| x == (cAliasPri)->FT_CHVNFE } ) > 0
				AADD(aCHVNF,(cAliasPri)->FT_CHVNFE)
			EndIf

			cChave :=  (cAliasPri)->FT_CHVNFE
			(cAliasPri)->(DbSkip())
		End
		cXml += '</listaItens>'
		cXml += '</operacao>

	EndIf
End
cXml += '</listaOperacoes>
Return cXML

/*/{Protheus.doc} noListNFE
Cria o n� do lista de lista de chaves de acesso do XML da lista de pedidos.
Essa tag retorna apenas as chaves de acesso. Pode ser de entrada ou sa�da pois a LEI x XSD x Exemplos da SEFAZ n�o deixam claro o conte�do esperado.
@type function
@version
@author raphael.augusto
@since 20/02/2020
@return return_type, Retorna uma string com as informa��es do n� do XML
/*/
Static Function noListNFE(aCHVNF)
Local cXML          := ""
Local nX 			:= 1
DEFAULT aCHVNF		:= {}

cXml += '<listaNFeEntrada>
For nX := 1 To Len(aCHVNF)
	cXml += '<chaveNFeEntrada>' + aCHVNF[nX]+ '</chaveNFeEntrada>
Next nX
cXml += '</listaNFeEntrada>
Return cXML

/*/{Protheus.doc} noListItem
Cria o n� do lista de NFE de entrada filho do listaOperacoes do XML da lista de pedidos.
@type function
@version
@author raphael.augusto
@since 20/02/2020
@return return_type, Retorna uma string com as informa��es do n� do XML
/*/
Static Function noListItem()
Local cXML          := ""
cXml += '<item>'
cXml += '<codInternoProduto>' + (cAliasPri)->CD0_COD + '</codInternoProduto>'
cXml += '<numItemNFe>' + (cAliasPri)->CD0_ITENFE + '</numItemNFe>'
//Nova reda��o dada ao Anexo II pela Resolu��o n� 002/2020-GSEFAZ, efeitos a partir de 13.1.2020.
//cXml += '<chaveNFeEntrada>' + (cAliasPri)->CD0_CHVNFE + '</chaveNFeEntrada>'
cXml += '</item>'
Return cXml


/*/{Protheus.doc} noDeclarant
Retorna o cabe�alho dos XMLS de lista de pedido e/ou produto.
Devido a semelhan�a criamos uma fun��o para retorna esse n� do XML
@type function
@version
@author raphael.augusto
@since 20/02/2020
@param cVersao, character, Vers�o do arquivo do ressarcimento
@param cTipoXML, character, 1 = lista de produto 2= lista de pedido
@param cAno, character, cAno do exerc�cio (somente para xTipoXML=2)
@param cPeriodo, character, cPeriodo do exerc�cio (somente para xTipoXML=2)
@return return_type, Retorna uma string com as informa��es do n� do XML
/*/
Static Function noDeclarant( cVersao , cTipoXML , cAno , cPeriodo )
Local cXML          := ""
DEFAULT cTipoXML   	:= "1"
DEFAULT cAno		:= ""
DEFAULT cPeriodo	:= ""

cXML	+=	'<dadosDeclarante>'
cXML	+=	'<cnpjRaiz>' + SubStr(SM0->M0_CGC,1,8) + '</cnpjRaiz>'
cXML	+=	'<razaoSocial>' + AllTrim(SM0->M0_NOMECOM) + '</razaoSocial>'
cXML	+=	'<nomeResponsavel>' + Alltrim(MV_PAR03)+ '</nomeResponsavel>'
cXML	+=	'<foneResponsavel>' + AllTrim(MV_PAR04) +'</foneResponsavel>'
cXML	+=	'<emailResponsavel>'+ AllTrim(MV_PAR05) +'</emailResponsavel>'
If cTipoXML == "2"
    cXML	+=	'<anoPeriodoReferencia>' + cAno + '</anoPeriodoReferencia>'
    cXML	+=	'<mesPeriodoReferencia>' + cPeriodo + '</mesPeriodoReferencia>''
EndIf

cXML 	+=	'</dadosDeclarante>'
Return cXML


/*/{Protheus.doc} GetQryPri
Fun��o que retorna a query principal para gera��o dos arquivos XML
@type function
@version
@author raphael.augusto
@since 20/02/2020
@return return_type, Retorna a query
/*/
Static Function getQryXML()
Local cQuery	:= ""
Local cSelect 	:= ""
Local cFrom 	:= ""
Local cWhere	:= ""
Local cCampos	:= ""
Local cMotivo	:= ""

// Constru��o da query

cCampos := " CD0.CD0_COD, CD0.CD0_ITENFE, CD0.CD0_CHVNFE , SFT.FT_CHVNFE , CD0.CD0_DOCENT , CD0.CD0_SERENT , CD0.CD0_FORNE , CD0.CD0_LOJENT , CD0.CD0_COD , CD0.CD0_ITENFE,  "
cCampos += " SB1.B1_COD , SB1.B1_DESC , SB1.B1_UM , SB1.B1_CONV , SA2.A2_CGC "


/*
	MV_PAR08   Modalidade Ressarcimento ?  1-ICMS ST | 2-Baixa Estoque
	Ao subir o arquivo no site da SEFAZ Amazonas � feita uma divis�o para upload do arquivo
	Op��o de upload: 1- ICMS ST
	Op��o de upload:2 = Baixa de estoque (perda, roubo ....).
	Por essa raz�o efetuamos a divis�o atrav�s desse recurso do pergunte. CD0_MOTRES:
	1=Venda para outra UF;
	2=Sa�da por isen��o ou n�o incid�ncia;
	3=Perda ou deteriora��o;
	4=Furto ou roubo;
	5=Exporta��o;
	9=Outros
*/
If MV_PAR08 == 1
	cMotivo		:= "1,5"
ElseIf MV_PAR08 == 2
	cMotivo		:= "3,4"
EndIf

cSelect +=  cCampos

cFrom += RetSqlname("CD0") + " CD0"
cFrom += "    INNER JOIN " + RetSqlname("SFT") + " SFT ON"
cFrom += "        SFT.D_E_L_E_T_ = ' '"
cFrom += "        AND SFT.FT_FILIAL = CD0.CD0_FILIAL"
cFrom += "        AND SFT.FT_NFISCAL = CD0.CD0_DOC"
cFrom += "        AND SFT.FT_SERIE = CD0.CD0_SERIE"
cFrom += "        AND SFT.FT_ITEM = CD0.CD0_ITEM"
cFrom += "        AND SFT.FT_PRODUTO = CD0.CD0_COD"
cFrom += "    INNER JOIN " + RetSqlname("SB1") + " SB1 ON"
cFrom += "        SB1.D_E_L_E_T_ = ' '"
cFrom += "        AND SB1.B1_COD = SFT.FT_PRODUTO"
cFrom += "        AND SB1.B1_FILIAL = "+ ValtoSQL( xFilial("SB1") )
cFrom += "    INNER JOIN " + RetSqlname("SA2") + " SA2 ON "
cFrom += "          SA2.D_E_L_E_T_ = ' ' "
cFrom += "         AND SA2.A2_FILIAL = " + ValtoSQL( xFilial("SA2") )
cFrom += "         AND SA2.A2_COD = CD0.CD0_FORNE"

cWhere += " CD0.D_E_L_E_T_ = ' '"
cWhere += " AND CD0_EMISSA >=  " + ValtoSQL( MV_PAR01 )
cWhere += " AND CD0_EMISSA <= " + ValtoSQL( MV_PAR02 )
cWhere += " AND CD0_FILIAL = "+ ValtoSQL( xFilial("CD0") )
cWhere += " AND CD0_EMISSA >= '2015'" // Conforme portal DT-e Amazonas s� � poss�vel solicitar o ressarcimento das notas emitidas a partir de 2015
cWhere += " AND CD0_MOTRES IN " +  FormatIn(cMotivo,",")
cWhere += " AND CD0_TPMOV = 'S'"

cWhere += " ORDER BY FT_CHVNFE,FT_NFISCAL,FT_SERIE,FT_ITEM,FT_PRODUTO "


// Normatiza��o.
cSelect	:= "%"	+ cSelect + "%"
cFrom	:= "%"	+ cFrom + "%"
cWhere	:= "%"	+ cWhere + "%"

// Execu��o.
BeginSql Alias cAliasPri
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
EndSql

Return cQuery

/*/{Protheus.doc} MontaArq
Retorna o nome dompleto do arquivo que ser� gerado.
@type function
@version
@author raphael.augusto
@since 20/02/2020
@param cPath, character, Diret�rio
@param cFile, character, nome do arquivo
@param cExtension, character, extens�o do arquivo
@return return_type, return_description
/*/
Static Function MontaArq( cPath ,cFile ,cExtension , lAutomato )
Local cBarra := iIf(IsSrvUnix() ,"/" ,"\")
Local cCNPJ	 := AllTrim(SM0->M0_CGC)
Local cTime	 := AllTrim(STRTRAN(Alltrim(time()),":",'_'))
DEFAULT cPath := ""
DEFAULT cFile := ""
DEFAULT cExtension := ".xml"
DEFAULT lAutomato := .F.

	cPath := Alltrim(cPath)

	If IsSrvUnix()
		cPath := STRTRAN(cPath ,"\" ,"/")
	Else
		cPath := STRTRAN(cPath ,"/" ,"\")
	EndIF

	If !File(cPath)
		If !lAutomato
			MsgInfo("N�o foi poss�vel localizar o diret�rio informando", "DT-e Ressarcimento")
		EndIf
	EndIf

	If !(Right(cPath ,1) == cBarra)
		cPath += cBarra
	EndIf

	cFile := Alltrim(cFile) + cCNPJ + IIF( lAutomato ,'' , "_" + cTime)
	cExtension := Alltrim(cExtension)
	cFile += cExtension

Return(cPath+cFile)

/*/{Protheus.doc} GravaArq
Gravado o arquivo XML para que o usu�rio possa subir o arquivo no site da SEFAZ Amazonas
@type function
@version
@author raphael.augusto
@since 20/02/2020
@param cXML, character, string com o XML
@param cNome, character, nome do arquivo que ser� gerado.
@return return_type, return_description
/*/
Static Function GravaArq(cXML,cNome,lAutomato)
Local nBytes	:= 0
Local nHandle
Local  cFile	:= ""
DEFAULT lAutomato	:= .F.

cFile := MontaArq( MV_PAR06 , cNome , ,lAutomato)

nHandle := FCreate(cFile)

If nHandle == -1
	If !lAutomato
		MsgInfo("N�o foi criar o arquivo no diret�rio especificado: " + AllTrim(cFile) , "DT-e Ressarcimento")
	EndIf
	Return
EndIf

nBytes := fWrite(nHandle,cXML)
fClose(nHandle)
If nBytes > 0
	If !lAutomato
		MsgInfo("Arquivo gerado com sucesso: " + AllTrim(cFile) , "DT-e Ressarcimento")
	EndIf
EndIf

Return

