#include 'PRAC867.ch'

//---------------------------------
/*/{Protheus.doc} 
Requisito 29 do Projeto de Virtualização.
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 08/02/2013
@return nil
@obs:
@sample
/*/
//---------------------------------


//---------------------------------
/*/{Protheus.doc}
Função PRAC867 apresenta a tela de parametros e chama a funcao C867GSTK
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 08/02/2013
@return Retorna um array de dois tamanhos {o Alias da tabela temp, um array definindo a estrutra da tabela temp.}
/*/
//---------------------------------
Function PRAC867(cCodSistema, cParent,aFiltro)
	Local aRet := {}
	Local aParambox := {}
	Local i := nil
	Local cRetornos := " "    // retorno Dos Campos e seus valores
	Local aReturnFunc := {}
	Local filterSistema := ''
	Local lOk := .F.

	//variaveis para alimentar o array aParambox
	Local iTipo := 1 				// Tipo 1 -> MsGet()
	Local sDescricao := nil 		// [2]-Descricao
	Local sInicio := nil			// [3]-String contendo o inicializador do campo
	Local sPicture := ''		   // [4]-String contendo a Picture do campo
	Local sValidacao := nil		// [5]-String contendo a validacao
	Local sConsulta := nil		// [6]-Consulta F3
	Local sValidacaoWhen := nil // [7]-String contendo a validacao When
	Local sMsGet := 50 			// [8]-Tamanho do MsGet
	Local bFlag := nil			// [9]-Flag .T./.F. Parametro Obrigatorio ?
	Local _MVSARACSV  := SUPERGETMV("MV_SARACSV", .T., "=")
	Local _MVSARACSC  := SUPERGETMV("MV_SARACSC ", .T., "|")
	
	If Empty(aFiltro)
		aFiltro := {}
	EndIf
	
	if len(cParent) > 0
		cRetornos := ' Parent = ' + "'" + cParent +  "'"
		lOk := .T.
	else
		//filterSistema := "DBV_SIS = " + "'" + cCodSistema + "'"
		filterSistema = "DBV_FILIAL = '"+xFilial('DBV')+"' .AND. DBV_SIS = " + "'" + cCodSistema + "'"
		DbSelectArea('DBV')
		DbSetOrder(2) //numero do indice
		DbSetFilter({||&filterSistema},filterSistema)
		DbGoTop()

		if cCodSistema == '' .or. cCodSistema == nil// .or. DbSeek(xFilial('DBV')+cCodSistema) == .F.
			Alert(STR0001)
			return aReturnFunc
		else
			//percorrer todos os registros
			while !EOF()

				//configurando sDescricao
				sDescricao := DBV_DESC

				//configurando sInicio
				if DBV_TIPO = "N"
					sInicio := "  "
				elseif DBV_TIPO == "D"
					sInicio := Ctod(Space(8))
				else
					sInicio := Space(DBV_TAM)
				endif

				//configurando sPicture
				if DBV_TIPO = "N"
					sPicture := "@E " + REPLICATE("9",DBV_TAM)
				elseif DBV_TIPO = "D"
					sPicture := ""
				else
					sPicture := ""
				endif

				//configurando sValidacao
				sValidacao := ""

				//configurando sConsulta
				sConsulta := ""

				//configurando sValidacaoWhen
				sValidacaoWhen := ""

				//configurando bFlag
				bFlag := .F.

				aadd(aParambox,{iTipo,sDescricao    ,sInicio,sPicture,sValidacao,sConsulta,sValidacaoWhen,sMsGet,bFlag})

				dbskip()
			end //fim do while

			//colher informacoes do cliente e montar string
			DBV->(DbGoTop())//iniciar novamente o registro no inicio
			ParamBox(aParamBox,STR0002,@aRet)

	    	For i:=1 To Len(aRet)
	    		lOk := .T.
		    	if DBV_TIPO == "C"
					if len(alltrim(cvaltochar(aRet[i]))) != 0
						cRetornos := cRetornos + alltrim(DBV_PAR) + _MVSARACSV +  "'" + alltrim(cvaltochar(aRet[i])) + alltrim("'") + _MVSARACSC
	    			endif

		    	elseif DBV_TIPO == "N"
					if len(alltrim(cvaltochar(aRet[i]))) != 0
						cRetornos := cRetornos + alltrim(DBV_PAR) + _MVSARACSV + alltrim(cvaltochar(aRet[i]))  +  _MVSARACSC
	    			endif
		    	else
		    		if len(alltrim(cvaltochar(aRet[i]))) > 4
						cRetornos := cRetornos + alltrim(DBV_PAR) + _MVSARACSV +  "'" + SDBDField(aRet[i]) + alltrim("'") + _MVSARACSC
	    			endif
	    		endif

				if !EOF()
    	  			dbskip()
      			endif
			Next
			For i:=1 To Len(aFiltro)
				cRetornos := cRetornos + aFiltro[i][1] + _MVSARACSV +  aFiltro[i][2] + _MVSARACSC
			Next i
		endif
	endif

	//retorna o alias da tabela temporaria e os seus campos para realizar a pesquisa
	if lOk
   		aReturnFunc := C867GSTOK(cCodSistema, cretornos)
	endif
	If Empty(aReturnFunc)
		aReturnFunc := {}
	EndIf
Return aReturnFunc


//---------------------------------
/*/{Protheus.doc}
Função C867GSTOK faz a consulta do estoque do banco do SARA
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 08/02/2013
@return Retorna um array de dois tamanhos {o Alias da tabela temp, um array definindo a estrutra da tabela temp.}
/*/
//---------------------------------

Function C867GSTOK(cCodSistema, cPesq)
	Local bStockSearch
	Local cXML := ''
	Local cError := ""
	Local cWarning := ""
	Local oWSStock
	Local oLines
	Local oFields
	Local aFields
	Local aLine
	Local oXML
	Local nI
	Local nJ
	Local nMax
	Local nMaxLines
	LOCAL cURL := ''
	Local aCampos := {}
	Local aDesc := {}
	Local aStruct := {}
	Local cFileTab
	Local lError := .F.
	Local bError := errorBlock({|e| C867MERR( e, @lError, @oWSStock ) })

	DBSelectArea('DBT')
	DBT->(DbGoTop())
	//DBT->(DBSetOrder(1))

	BEGIN SEQUENCE
		If AllTrim(DBT->DBT_URLWSE) != ''
			cURL := DBT->DBT_URLWSE
		else
			alert(STR0003)
			lError := .T.
			return .F.
		endif

		bStockSearch := { || oWSStock := WSIEstoqueservice():New(),oWSStock:cURL := cURL, oWSStock:ccPesq := cPesq, oWSStock:getStock() }

		MsgRun( STR0004, STR0005 , bStockSearch )

		cXML := EncodeUTF8(oWSStock:creturn)

		oXML := XmlParser( cXML , "_" , @cError , @cWarning )

		if AllTrim(oXML:_root:_status:text) == '0'
			alert(STR0006 + oXML:_root:_msg:text)
			lError := .T.
			return .f.
		endif

		oFields := XmlGetchild( oXML:_root , 3)

		if lError
			return .F.
		endif

		aFields := ClassDataArr(oFields)

		if lError
			return .F.
		endif

		nMax := len(aFields) - 3

		aAdd(aCampos, {'ID', 'C', 10, 0})
		aAdd(aDesc, 'ID')

		//Aqui vc tem a estrutura para criar a tabela temporaria
		for nI := 1 to nMax
			if ((alltrim(upper(aFields[nI][2]:realname)) = 'PARENT') .OR. (alltrim(upper(aFields[nI][2]:realname)) = 'IDLEG'))
				Aadd(aCampos, {substr(aFields[nI][2]:realname,1,10), 'C', 50, 0})
			else
				Aadd(aCampos, {substr(aFields[nI][2]:realname,1,10), 'C', 255, 0})
			endif
			Aadd(aDesc, aFields[nI][2]:text)
		next		
		
		//////criar tabela temporaria vazia para aliar com o oBrowse//////////////
		SCriaTbTmp({aCampos, {'ID', 'PARENT'}}, cAlias)
		/////////////fim cricao da tabela temporaria vazia///////////////////////

		oLines := XmlGetchild( oXML:_root , 4)

		//Verificando para ver se retornou alguma consulta. Se não trouxe nenhuma informção, deverá dar erro e lancar a exceção
		oLines:_line

	END SEQUENCE
	ErrorBlock(bError)
	if lError
		return .F.
	endif

	nMax := len(oLines:_line)

	//Aqui alimenta a tabela temporaria

	for nI := 1 to nMax
		aLine := ClassDataArr(oLines:_line[nI])
		nMaxLines := len(aLine) - 3
		RecLock( cAliasPesq, .T. )
		(cAliasPesq)->(FieldPut(1,AllTrim(Str(nI))))
		for nJ := 1 to nMaxLines
			(cAliasPesq)->(FieldPut(nJ+1,aLine[nJ][2]:text))
		next
		MsUnlock()
	next

	(cAliasPesq)->(DBCommit())
	(cAliasPesq)->(DBGoTop())

return {cAliasPesq, aDesc}


//---------------------------------
/*/{Protheus.doc}
Função C867MERR que apresenta em alert os erros lancados pela funcao C867GSTK
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 08/02/2013
@return nil
/*/
//---------------------------------
Function C867MERR(e,lError, oWSStock)
	Local cDesc :=  e:Description
	Local nCod := e:Gencode

	if lError == .T.
		return
	elseif nCod == 14  .and. lError == .F.
		Alert(STR0007)
	elseif nCod == 1 .and. lError == .F.
		Alert(STR0008)
	elseif nCod == 57	 .and. lError == .F.
		Alert(STR0009)
	else
		if lError == .F.
			Alert(cDesc)
		endif
	endif
	lError := .T.
return


