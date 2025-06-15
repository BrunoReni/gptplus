#INCLUDE 'protheus.ch'
#INCLUDE 'MRPDominio.ch'

#DEFINE TAMANHO_TIPO  15
#DEFINE TAMANHO_VALOR 100

Static _lBloqueio

/*/{Protheus.doc} MrpDominio_Seletivos
Regras de Negocio - Filtros Seletivos Multivalorados
@author    brunno.costa
@since     27/05/2020
@version   12.1.27
/*/
CLASS MrpDominio_Seletivos FROM LongNameClass

	//Declaracao de propriedades da classe
	DATA cTabFiltros      AS CHARACTER
	DATA oDominio         AS OBJECT
	DATA oDados           AS OBJECT
	DATA lSeletivoProduto AS LOGICAL

	METHOD new() CONSTRUCTOR
	METHOD limpaInMemoria()

	//Metodos para Montagem de Script SQL
	METHOD criaTabelaFiltro()
	METHOD insereTabelaFiltro(cParametro)
	METHOD scriptExistsProdutoSQL(cProdCol, lOnlyBlock, lValidMRP, lUsaExists, lUsaSelPrd)
	METHOD scriptRecursivaEstrutura()
	METHOD scriptInSQL(cColuna, cParametro, cColConcat)

	//Metodos exclusivos da Regra Seletivo de Produtos
	METHOD consideraProduto(cFilAux, cProduto, oDados, lExpHWB)
	METHOD criaTabelaTemporariaProdutos()
	METHOD loadProdutosValidos()
	METHOD setaProdutoValido(cProduto)

ENDCLASS

/*/{Protheus.doc} New
Metodo construtor
@author    brunno.costa
@since     27/05/2020
@version   12.1.27
@param 01 - oDominio, objeto, inst�ncia da classe de dominio
/*/
METHOD New(oDominio) CLASS MrpDominio_Seletivos
	Self:cTabFiltros      := "PCPA712_FIL"
	Self:oDominio         := oDominio
	Self:oDados           := oDominio:oDados:oSeletivos
	Self:lSeletivoProduto := !Empty(oDominio:oDados:oParametros["cProducts"])
Return Self

/*/{Protheus.doc} scriptExistsProdutoSQL
Retorna Script SQL EXISTS() para complemento a clausulas Where
@author    brunno.costa
@since     27/05/2020
@version   12.1.27
@param 01 cProdCol  , caracter, coluna referente ao c�digo do produto para compara��o com a tabela HWA
@param 02 lOnlyBlock, Logic   , identifica que ser� adicionado somente o filtro de produtos bloqueados.
@param 03 lValidMrp , Logic   , identifica se ser� validado o campo HWA_MRP para a query.
@param 04 lUsaExists, Logic   , Identifica se deve adicionar o EXISTS principal da tabela HWA.
@param 05 lUsaSelPrd, Logic   , Identifica se deve adicionar o filtro de seletivo de produto.
@return   cWhere  , caracter, cl�usula WHERE com o filtro do produto
/*/
METHOD scriptExistsProdutoSQL(cProdCol, lOnlyBlock, lValidMRP, lUsaExists, lUsaSelPrd) CLASS MrpDominio_Seletivos

	Local cWhere    := ""
	Local oMultiEmp := Self:oDominio:oMultiEmp

	Default lOnlyBlock := .F.
	Default lValidMrp  := .T.
	Default lUsaExists := .T.
	Default lUsaSelPrd := .T.

	If lUsaExists
		cWhere := " EXISTS (SELECT 1 "
		cWhere +=           " FROM " + RetSqlName("HWA") + " HWA "
		If Self:oDominio:oDados:oParametros["lUsesProductIndicator"] .And. !lOnlyBlock
			cWhere += 			" LEFT OUTER JOIN " + RetSqlName("HWE") + " HWE "
			cWhere += 					" ON HWA.HWA_PROD = HWE.HWE_PROD "
			cWhere += 					" AND HWE.D_E_L_E_T_ = ' ' "
			cWhere += 					" AND HWE.HWE_FILIAL = '" + xFilial("HWE") + "' "
		EndIf
		cWhere +=          " WHERE HWA.HWA_FILIAL = '" + xFilial("HWA") + "'"
		cWhere +=            " AND HWA.HWA_PROD   = "  + cProdCol
		cWhere +=            " AND HWA.D_E_L_E_T_ = ' ' "
	Else
		cWhere += " 1 = 1 "
	EndIf

	If !lOnlyBlock .And. lValidMRP
		If Self:oDominio:oDados:oParametros["lUsesProductIndicator"]
			cWhere +=        " AND ((HWE.HWE_MRP IS NULL AND HWA.HWA_MRP = '1') "
			cWhere += 		 " OR (HWE.HWE_MRP IS NOT NULL AND HWE.HWE_MRP = '1')) "
		Else
			cWhere +=        " AND HWA.HWA_MRP    = '1' "
		EndIf
	EndIf

	If prdBlock() .And. lValidMRP
		//Somente produtos com status diferente de bloqueado.
		cWhere +=        " AND HWA.HWA_BLOQUE <> '1' "
	EndIf

	//Seletivo de Grupos de Materiais
	If !lOnlyBlock .And. !Empty(Self:oDominio:oDados:oParametros["cProductGroups"])
		cWhere     += " AND " + Self:scriptInSQL("HWA.HWA_GRUPO", "cProductGroups")
	EndIf

	//Seletivo de Tipos de Materiais
	If !lOnlyBlock .And. !Empty(Self:oDominio:oDados:oParametros["cProductTypes"])
		cWhere += " AND " + Self:scriptInSQL("HWA.HWA_TIPO", "cProductTypes")
	EndIf

	//Seletivo de Produtos
	If Self:lSeletivoProduto .And. lUsaSelPrd
		cWhere += " AND EXISTS (SELECT PRODUTOS.HWA_PROD
		cWhere +=             " FROM (SELECT HWA_1.HWA_PROD HWA_PROD "
		cWhere +=                   " FROM " + RetSqlName("HWA") + " HWA_1 "
		cWhere +=                   " WHERE HWA_1.HWA_FILIAL = '" + xFilial("HWA") + "'"
		cWhere +=                     " AND HWA_1.D_E_L_E_T_ = ' ' "
		cWhere +=                     " AND " + Self:scriptInSQL("HWA_1.HWA_PROD", "cProducts")
		cWhere +=                    " UNION ALL"
		cWhere +=                      Self:scriptRecursivaEstrutura()
		cWhere +=                    " UNION ALL"
		cWhere +=                    " SELECT ALT.T4O_ALTERN FROM " + RetSqlName("T4O") + " ALT "
		cWhere +=                                    " INNER JOIN " + RetSqlName("T4N") + " EST "
		cWhere +=                                            " ON EST.T4N_FILIAL = ALT.T4O_FILIAL "
		cWhere +=                                           " AND EST.T4N_IDREG  = ALT.T4O_IDEST "
		cWhere +=                                           " AND EXISTS(SELECT 1 "
		cWhere +=                                                        " FROM " + Self:oDados:getFlag("PCPA712_PRD") + " PRD "
		cWhere +=                                                       " WHERE PRD.T4N_COMP = EST.T4N_COMP) "
		If oMultiEmp:utilizaMultiEmpresa()
			cWhere +=                 " WHERE " + oMultiEmp:queryFilial("ALT", "T4O_FILIAL", .T.)
		Else
			cWhere +=                 " WHERE ALT.T4O_FILIAL = '" + xFilial("T4O") + "' "
		EndIf
		cWhere +=                    ") PRODUTOS "
		cWhere +=             " WHERE PRODUTOS.HWA_PROD   = "  + cProdCol
		cWhere +=              ")"
	EndIf

	If lUsaExists
		cWhere += ")"
	EndIf

Return cWhere

/*/{Protheus.doc} scriptInSQL
Retorna Script SQL IN para complemento a clausulas Where
@author    brunno.costa
@since     27/05/2020
@version   12.1.27
@param 01 cColuna   , caracter, coluna a ser montado o AND
@param 02 cParametro, caracter, par�metro a ser tratado
@param 03 cColConcat, caracter, coluna para concatena��o no IN.
@return cWhereIn    , data    , par�metro quebrado para utiliza��o no IN do SELECT
/*/
METHOD scriptInSQL(cColuna, cParametro, cColConcat) CLASS MrpDominio_Seletivos
	Local cBanco   := TcGetDB()
	Local cValPar  := ""
	Local cWhereIn := ""
	Local lUsaME   := Self:oDominio:oMultiEmp:utilizaMultiEmpresa()

	//Verifica se a tabela j� foi criada.
	Self:criaTabelaFiltro()

	//Verifica se os dados deste par�metro j� foram inclu�dos na tabela PCPA712_FIL
	Self:insereTabelaFiltro(cParametro)

	//Verifica se deve concatenar as colunas "cColuna" e "cColConcat"
	If lUsaME .And. !Empty(cColConcat) .And. !Empty(Self:oDominio:oParametros[cParametro])
		cValPar := StrTran(Self:oDominio:oParametros[cParametro], "|", "")

		If At(";", cValPar) == Self:oDominio:oMultiEmp:tamanhoFilial() + 1
			If cBanco == "ORACLE"
				cColuna := cColConcat + " || ';' || " + cColuna

			ElseIf cBanco == "POSTGRES"
				cColuna := "RTRIM(CONCAT(" + cColConcat + ", ';' ," + cColuna + "))"

			Else //SQL
				cColuna := cColConcat + " + ';' + " + cColuna

			EndIf
		EndIf
	EndIf

	//Monta query com o IN, fazendo o select na tabela PCPA712_FIL
	cWhereIn := cColuna + " IN (SELECT FILTRO.VALOR "
	cWhereIn +=                 " FROM " + Self:cTabFiltros + " FILTRO "
	cWhereIn +=                " WHERE FILTRO.TIPO = '" + cParametro + "') "

Return cWhereIn

/*/{Protheus.doc} criaTabelaFiltro
Cria a tabela para utiliza��o dos filtros seletivos.

@author lucas.franca
@since 14/12/2022
@version P12
@return Nil
/*/
METHOD criaTabelaFiltro() CLASS MrpDominio_Seletivos
	Local aFields := {}
	Local cFlag   := ""

	//Verifica se a tabela j� foi criada.
	Self:oDados:trava("PCPA712_FIL")
	cFlag := Self:oDados:getFlag("PCPA712_FIL")
	If Empty(cFlag)
		aAdd(aFields, {"TIPO" , "C", TAMANHO_TIPO, 0})
		aAdd(aFields, {"VALOR", "C", TAMANHO_VALOR , 0})

		//Deleta Tabela no Banco, caso exista
		If TcCanOpen(Self:cTabFiltros)
			TCDelFile(Self:cTabFiltros)
		EndIf

		//Cria Tabela no Banco
		dbCreate(Self:cTabFiltros, aFields, "TOPCONN")
		//Cria �ndice na tabela
		DBUseArea(.T., "TOPCONN", Self:cTabFiltros, (Self:cTabFiltros), .F., .F.)
		DBCreateIndex(Self:cTabFiltros + "_IDX1", "TIPO" , {|| TIPO  })
		(Self:cTabFiltros)->(dbCloseArea())
		Self:oDados:setFlag("PCPA712_FIL", "S")

		aSize(aFields, 0)
	EndIf
	Self:oDados:destrava("PCPA712_FIL")

Return

/*/{Protheus.doc} insereTabelaFiltro
Faz o insert dos dados na tabela de filtro de seletivos

@author lucas.franca
@since 14/12/2022
@version P12
@param cParametro, Caracter, Par�metro indicando o tipo de filtro (produtos,grupos,tipos, etc)
@return Nil
/*/
METHOD insereTabelaFiltro(cParametro) CLASS MrpDominio_Seletivos
	Local aLista    := {}
	Local aInsert   := {}
	Local cConteudo := ""
	Local cFlag     := ""
	Local cPar      := ""
	Local nIndex    := 0
	Local nTotal    := 0

	Self:oDados:trava(cParametro)
	cFlag := Self:oDados:getFlag(cParametro)
	If Empty(cFlag)
		//Insere os dados na tabela PCPA712_FIL
		cConteudo := Self:oDominio:oParametros[cParametro]
		aLista    := StrTokArr2(SubStr(cConteudo, 2, Len(cConteudo)-2), "|", .F.)
		If !Empty(aLista)
			cPar   := PadR(cParametro, TAMANHO_TIPO)
			nTotal := Len(aLista)
			For nIndex := 1 To nTotal
				aAdd(aInsert, {cPar, PadR(aLista[nIndex], TAMANHO_VALOR)})

				If Mod(nIndex, 1000) == 0 .Or. nIndex == nTotal
					TcDbInsert( Self:cTabFiltros, "TIPO,VALOR", aInsert )
					aSize(aInsert, 0)
				EndIf

			Next nIndex
			aSize(aLista, 0)
		EndIf
		Self:oDados:setFlag(cParametro, "S")
	EndIf
	Self:oDados:destrava(cParametro)

Return

/*/{Protheus.doc} scriptRecursivaEstrutura
Retorna Script SQL IN para complemento a clausulas Where - Query Recursiva de Estruturas
@author    brunno.costa
@since     27/05/2020
@version   12.1.27
@return cScript, caracter, script para union referente query recursiva
/*/
METHOD scriptRecursivaEstrutura() CLASS MrpDominio_Seletivos

	Local cArqTrab := ""
	Local cScript  := ""

	Self:oDados:trava("PCPA712_PRD")
	cArqTrab := Self:oDados:getFlag("PCPA712_PRD")
	If Empty(cArqTrab)
		cArqTrab := Self:criaTabelaTemporariaProdutos()
		Self:oDados:setFlag("PCPA712_PRD", cArqTrab)
	EndIf
	Self:oDados:destrava("PCPA712_PRD")

	cScript := " SELECT T4N_COMP "
	cScript += " FROM " + cArqTrab

Return cScript

/*/{Protheus.doc} criaTabelaTemporariaProdutos
Cria a tabela tempor�ria para armazenar os poss�veis c�digos de produtos seletivos (estrutura)
@author brunno.costa
@since 27/05/2020
@version P12.1.30
@return cArqTrab, caracter, nome do arquivo de trabalho criado
/*/
METHOD criaTabelaTemporariaProdutos() CLASS MrpDominio_Seletivos

	Local aFields    := {}
	Local cArqTrab   := "PCPA712_PRD"
	Local cBanco     := TCGetDB()
	Local cQuery     := ""
	Local cInsert    := ""
	Local lUsaME     := .F.
	Local oMultiEmp  := Self:oDominio:oMultiEmp

	lUsaME := oMultiEmp:utilizaMultiEmpresa()

	//Adiciona Campos
	aAdd(aFields, {})
	aAdd(aFields[1], "T4N_COMP")
	aAdd(aFields[1], GetSX3Cache("T4N_COMP", "X3_TIPO"))
	aAdd(aFields[1], GetSX3Cache("T4N_COMP", "X3_TAMANHO"))
	aAdd(aFields[1], GetSX3Cache("T4N_COMP", "X3_DECIMAL"))

	//Deleta Tabela no Banco, caso exista
	If TcCanOpen(cArqTrab)
		TCDelFile(cArqTrab)
	EndIf

	//Cria Tabela no Banco
	dbCreate(cArqTrab, aFields, "TOPCONN")

	cInsert := " INSERT "
	cInsert += "  INTO " + cArqTrab + "(T4N_COMP, R_E_C_N_O_) "

	cQuery := " WITH EstruturaRecursiva(T4N_PROD, T4N_COMP, T4N_FILIAL)"
	cQuery += " AS ("

	cQuery +=       " SELECT T4N.T4N_PROD,"
	cQuery +=              " T4N.T4N_COMP,"
	cQuery +=              " T4N.T4N_FILIAL"
	cQuery +=        " FROM " + RetSqlName( "T4N" ) + " T4N "
	cQuery +=       " WHERE T4N.D_E_L_E_T_ = ' '"
	If lUsaME
		cQuery +=     " AND " + oMultiEmp:queryFilial("T4N", "T4N_FILIAL", .T.)
	Else
		cQuery +=     " AND T4N.T4N_FILIAL  = '" + xFilial("T4N") + "' "
	EndIf
	cQuery +=         " AND (" + Self:scriptInSQL("T4N.T4N_PROD", "cProducts") + ")"

	cQuery +=       " UNION ALL "

	cQuery +=       " SELECT T4N.T4N_PROD,"
	cQuery +=              " T4N.T4N_COMP,"
	cQuery +=              " T4N.T4N_FILIAL"
	cQuery +=        " FROM " + RetSqlName( "T4N" ) + " T4N "
	cQuery +=             " INNER JOIN EstruturaRecursiva Qry_Recurs"
	cQuery +=                    " ON Qry_Recurs.T4N_COMP = T4N.T4N_PROD  "
	If lUsaME
		cQuery +=     " AND Qry_Recurs." + oMultiEmp:queryFilial("T4N", "T4N_FILIAL", .F.)
	EndIf
	cQuery +=       " WHERE T4N.D_E_L_E_T_ = ' '"
	If lUsaME
		cQuery +=     " AND " + oMultiEmp:queryFilial("T4N", "T4N_FILIAL", .T.)
	Else
		cQuery +=     " AND T4N.T4N_FILIAL  = '" + xFilial("T4N") + "' "
	EndIf

	cQuery +=   " )"

	If cBanco != "ORACLE"
		cQuery += cInsert
	EndIf

	cQuery += " SELECT DADOS.T4N_COMP, "
	cQuery +=        " ROW_NUMBER() OVER(ORDER BY DADOS.T4N_COMP ASC) RECNO "
	cQuery += " FROM (SELECT DISTINCT Resultado.T4N_COMP "
	cQuery +=       " FROM EstruturaRecursiva Resultado) DADOS "

	If cBanco == "ORACLE"
		cQuery := cInsert + cQuery
	EndIf

	//Realiza ajustes da Query para cada banco
	If cBanco == "POSTGRES"

		//Altera sintaxe da clausula WITH
		cQuery := StrTran(cQuery, 'WITH ', 'WITH recursive ')

		//Corrige Falhas internas de Bin�rio - POSTGRES
		cQuery := StrTran(cQuery, CHR(13), " ")
		cQuery := StrTran(cQuery, CHR(10), " ")
		cQuery := StrTran(cQuery, CHR(09), " ")

	EndIf

	If TcSqlExec(cQuery) < 0
		Final(STR0168, tcSQLError() + cQuery) //"Erro ao carregar o seletivo de produtos."
	EndIf

Return cArqTrab

/*/{Protheus.doc} loadProdutosValidos
Efetua Carga Inicial no Controle de Seletivo de Produtos
@author    brunno.costa
@since     27/05/2020
@version   12.1.27
/*/
METHOD loadProdutosValidos() CLASS MrpDominio_Seletivos

	Local cParametro := "cProductsX"
	Local cConteudo  := Self:oDominio:oParametros["cProducts"]
	Local aLista
	Local cCarregado := ""
	Local nIndexLis  := 1
	Local nLenLista  := 0

	If Self:lSeletivoProduto
		Self:oDados:trava(cParametro)

		cCarregado := Self:oDados:getFlag(cParametro)
		If Empty(cCarregado)
			cCarregado := ""
			aLista     := StrTokArr2(SubStr(cConteudo, 2, Len(cConteudo)-2), "|", .F.)
			nLenLista  := Len(aLista)
			For nIndexLis := 1 To nLenLista
				Self:setaProdutoValido(aLista[nIndexLis])
			Next nIndexLis
			cCarregado := "OK"
			Self:oDados:setFlag(cParametro, cCarregado)
		EndIf

		Self:oDados:destrava(cParametro)
	EndIf

Return

/*/{Protheus.doc} limpaInMemoria
Limpa Strings IN da Memoria
@author    brunno.costa
@since     27/05/2020
@version   12.1.27
/*/
METHOD limpaInMemoria() CLASS MrpDominio_Seletivos

	Local cArqTrab := Self:oDados:getFlag("PCPA712_PRD")

	Self:oDados:setFlag("cDemandCodes"  , "")
	Self:oDados:setFlag("cDocuments"    , "")
	Self:oDados:setFlag("cProductGroups", "")
	Self:oDados:setFlag("cProductTypes" , "")
	Self:oDados:setFlag("cWarehouses"   , "")
	Self:oDados:setFlag("cProducts"     , "")
	Self:oDados:setFlag("PCPA712_FIL"   , "")

	//Exclui tabela de produtos do banco
	If !Empty(cArqTrab) .And. TcCanOpen(Self:cTabFiltros)
		TCDelFile(cArqTrab)
	EndIf

	//Deleta Tabela de filtros no Banco, caso exista
	If TcCanOpen(Self:cTabFiltros)
		TCDelFile(Self:cTabFiltros)
	EndIf

Return

/*/{Protheus.doc} setaProdutoValido
Seta Produto Valido - Seletivo de Produtos
@author    brunno.costa
@since     27/05/2020
@version   12.1.27
@param 01 cProduto, caracter, c�digo do produto
/*/
METHOD setaProdutoValido(cProduto) CLASS MrpDominio_Seletivos
	If Self:lSeletivoProduto
		Self:oDados:setFlag("|" + AllTrim(cProduto) + "|", .T.)
	EndIf
Return

/*/{Protheus.doc} consideraProduto
Avalia se o produto est� dentro das condi��es de filtro do c�lculo
@author    brunno.costa
@since     27/05/2020
@version   12.1.27
@param 01 cFilAux    , caracter, c�digo da filial para processamento
@param 02 cProduto   , caracter, c�digo do produto
@param 03 oDados     , logico  , classe de dados do MRP
@param 04 lExpHWB    , logico  , indica se a chamada � a partir da exportacao dos resultados da HWB
@return lConsidera, l�gico, indica se o produto deve ou n�o ser calculado
/*/
METHOD consideraProduto(cFilAux, cProduto, oDados, lExpHWB) CLASS MrpDominio_Seletivos

	Local aRetPrd     := {}
	Local aAreaPRD    := {}
	Local cChavProd   := cFilAux + cProduto
	Local lAtual      := .T.
	Local lConsidera  := .T.
	Local lError      := .F.
	Local lGet        := .F.
	Local oParametros

	Default oDados      := Self:oDominio:oDados
	Default lExpHWB := .F.

	If Self:lSeletivoProduto
		lGet := Self:oDados:getFlag("|" + AllTrim(cProduto) + "|", @lError)
		If lError .OR. !lGet
			lConsidera := .F.
			lError     := .F.
		EndIf
	Else
		If lExpHWB
			Return lConsidera
		EndIf
	EndIf

	If lConsidera
		lConsidera := Self:oDados:getFlag("|L|" + cChavProd)
		If lConsidera == Nil

			If oDados:oProdutos:nIndice == 2
				If oDados:oProdutos:cCurrentKey == Nil .Or. Right(oDados:oProdutos:cCurrentKey, Len(oDados:oProdutos:cCurrentKey)-2) != cChavProd
					lAtual := .F.
				EndIf
			ElseIf oDados:oProdutos:cCurrentKey == Nil .Or. oDados:oProdutos:cCurrentKey != cChavProd
				lAtual := .F.
			EndIf

			If !lAtual
				aAreaPRD := oDados:retornaArea("PRD")
			EndIf

			aRetPrd := oDados:retornaCampo("PRD", 1, cChavProd, {"PRD_TIPO", "PRD_GRUPO", "PRD_MRP", "PRD_BLOQUE"}, , lAtual , , , , , .T. /*lVarios*/)

			If !lAtual
				oDados:setaArea(aAreaPRD)
				aSize(aAreaPRD, 0)
			EndIf

			//Avalia se o produto n�o est� bloqueado (PRD_BLOQUE == 2), e se o produto deve ser utilizado no MRP ( PRD_MRP  == 1)
			If (Empty(aRetPrd[4]) .Or. aRetPrd[4] == "2") .And. (aRetPrd[3] == "1" .OR. Empty(aRetPrd[3]))
				oParametros := Self:oDominio:oParametros
				//Avalia se o produto est� dentro do filtro
				lConsidera := .T.

				If !Empty(oParametros["cProductTypes"]) .And. !(aRetPrd[1] $ oParametros["cProductTypes"])
					lConsidera := .F.
				Else
					If !Empty(oParametros["cProductGroups"]) .And. !("|"+aRetPrd[2]+"|" $ oParametros["cProductGroups"])
						lConsidera := .F.
					EndIf
				EndIf
			Else
				lConsidera := .F.
			EndIf

			Self:oDados:setFlag("|L|" + cChavProd, lConsidera)
		EndIf
	EndIf

Return lConsidera

/*/{Protheus.doc} prdBlock
Verifica se deve ser considerado o par�metro de produtos bloqueados da tabela HWA.

@type  Static Function
@author lucas.franca
@since 11/02/2020
@version P12.1.27
@return lBloqueio, Logic, Identifica se deve considerar o par�metro de produtos bloqueados.
/*/
Static Function prdBlock()
	Local lBloqueio := .F.

	If _lBloqueio == Nil
		If Empty(GetSX3Cache("HWA_BLOQUE", "X3_TAMANHO"))
			_lBloqueio := .F.
		Else
			_lBloqueio := .T.
		EndIf
	EndIf

	lBloqueio := _lBloqueio
Return lBloqueio
