#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "WMSSGEN.CH"

#define INFO_ZOOM_TIPO_EXECUCAO_SQL   1
#define INFO_ZOOM_TIPO_EXECUCAO_ARRAY 2
#define INFO_ZOOM_OBJETO 2

Static aAlSARA := {}

/*/{Protheus.doc} SRAGENERICO
@author   Joao Victor Fidelix
@version  P12
@since    30/04/2012
@obs      LIB Generica do SARA
/*/

//-------------------------------------------------------------------
/*/{Protheus.doc} STransType
Converte o tipo da variavel.

@param oValue Variavel a ser convertida
@param oType Tipo que se deseja converter a variavel

@author  Joao Victor Fidelix
@since   30/04/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function STransType(oValue, oType)

	local cTipo := ""
	default oType := "C"

	cTipo := valtype(oValue)

	do case
		case cTipo == "N"
			do case
				case oType == "C"
					oValue := STrim(Str(oValue))
					return	oValue
				case oType == "F"
					return	oValue
				case oType == "N"
					return   oValue
				otherwise
					return nil
			endcase
		case cTipo == "D"
			do case
				case oType == "C"
			   		oValue := DToC(oValue)
			   	return	oValue
				otherwise
					return nil
			endcase
		case cTipo == "F"
			do case
				case oType == "C"
					oValue := STrim(Str(oValue))
					return	oValue
				case oType == "F"
					return   oValue
				case oType == "N"
					return   Val(Str(oValue))
				otherwise
					return nil
			endcase
		case cTipo == "U"
			do case
				case oType == "C"
			   	oValue := ""
			   	return	oValue
			 	case oType == "F"
			 		return   0
			 	case oType == "N"
			 		return   0
				otherwise
					return nil
			endcase
		case cTipo == "C"
			do case
				case oType == "N"
			   	oValue := Val(oValue)
			   	return	oValue
				case oType == "F"
			   	oValue := Val(oValue)
			   	return	oValue
				case oType == "D"
			   	oValue := CToD(oValue)
			   	return	oValue
				otherwise
					return oValue
			endcase
		otherwise
			return oValue
	endcase
return

//-------------------------------------------------------------------
/*/{Protheus.doc} STrim
Retira os espaços no inicio e no final.

@param oValue Valor que sera verificado

@author  Joao Victor Fidelix
@since   30/04/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function STrim(oValue)

	local cTipo := ""
	cTipo := valtype(oValue)

	if (SEmpty(oValue) .or. (cTipo != "C"))
		return oValue
	else
		return AllTrim(oValue)
	endif
return

//-------------------------------------------------------------------
/*/{Protheus.doc} SEmpty
Verifica se a variavel e vazia.

@param oValue Valor que sera verificado

@author  Joao Victor Fidelix
@since   30/04/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SEmpty(oValue)

	local cTipo := ""
	cTipo := valtype(oValue)

	if ((cTipo == "N") .or. (cTipo == "F") .or. (cTipo == "D"))
		if (oValue == nil)
			return .T.
		else
			return .F.
		endif
	elseif (cTipo == "C")
		if trim(lower(oValue)) == "null"
			return .T.
		else
			return empty(oValue)
		endif
	elseif (cTipo == "A")
		return IF (len(oValue) > 0, .F., .T.)
	elseif (cTipo == "O")
		return IF (oValue == NIL, .T., .F.)
	else
		return .T.
	endif
return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddFilParser
Realiza o parser de um filtro

@param  cField Campo
@param  cOper Operador
@param  xExpression Expressão do filtro
@param  aFilParser Parser do filtro
                                                               [n,1] String contendo o campo, operador ou expressão do filtro
                                                               [n,2] Indica o tipo do parser (FIELD=Campo,OPERATOR=Operador e EXPRESSION=Expressão)
@author  Eduardo Souza
@since   12/03/2009
@version 10.1.1.4
@protected
/*/
//-------------------------------------------------------------------
Function SAddFilPar(cField,cOper,xExpression,aFilParser)

	SAddParser(cField,"FIELD",@aFilParser)
	SAddParser(cOper,"OPERATOR",@aFilParser)
	SAddParser(xExpression,"EXPRESSION",@aFilParser)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddParser
Adiciona um nível do parser de um filtro

@param  cString String contendo o campo, operador ou expressão do filtro
@param  cTipo Indica o tipo do parser (FIELD=Campo,OPERATOR=Operador e EXPRESSION=Expressão)
@param  aFilParser Parser do filtro
                                                               [n,1] String contendo o campo, operador ou expressão do filtro
                                                               [n,2] Indica o tipo do parser (FIELD=Campo,OPERATOR=Operador e EXPRESSION=Expressão)
@author  Eduardo Souza
@since   12/03/2009
@version 10.1.1.4
@protected
/*/
//-------------------------------------------------------------------
Function SAddParser(cString,cTipo,aFilParser)

PARAMTYPE 0 VAR cString    AS CHARACTER,NUMERIC,LOGICAL,DATE
PARAMTYPE 1 VAR cTipo      AS CHARACTER OPTIONAL DEFAULT ""
PARAMTYPE 2 VAR aFilParser AS ARRAY

	Aadd( aFilParser, { cString , cTipo } )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SAddPField
Adicona as colunas do Zoom

@param aFields
@param cCampo Campo
@param cDesc Descricao do campo
@param cTipo Tipo do campo
@param nTamanho Tamanho do campo
@param nPrecisao Precisao do campo
@param cMascara Mascara do campo
@param lVisivel Se o campo irá ser visivel ou nao
@param lRetorna Se o campo retorna essa valor ou nao
@param lDefault Se o campo é o padrão de pesquisa
@param nTipoPesquisa Informa o tipo de pesquisa do campo default

@author  Joao Victor Fidelix
@since   30/04/2012
@version 10.1.1.4
@protected
/*/
//-------------------------------------------------------------------
Function SAddPField(aFields, cCampo, cDesc, cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna, lDefault, nTipoPesquisa)
	Local aProps := {}
	Default lDefault := .F.
	Default nTipoPesquisa := 1

	Aadd(aProps, cCampo)       //1 - Campo
	Aadd(aProps, cDesc)        //2 - Descricao
	Aadd(aProps, cTipo)        //3 - Tipo
	Aadd(aProps, nTamanho)     //4 - Tamanho
	Aadd(aProps, nPrecisao)    //5 - Precisao
	Aadd(aProps, cMascara)     //6 - Mascara
	Aadd(aProps, lVisivel)     //7 - Visivel
	Aadd(aProps, lRetorna)     //8 - Retorna
	Aadd(aProps, lDefault)     //9 - Pesquisa Padrao
	Aadd(aProps, nTipoPesquisa)//10 - Tipo pesquisa
										//1 => "LIKE '%   %'"
										//2 => "="
										//3 => ">="
										//4 => "<="
										//5 => "LIKE '%   '"
										//6 => "LIKE '   %'"

	Aadd(aFields, aProps)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SGetParam
Seleciona valor do parametro

@param cParam Nome do parametro a ser verificado.

@author  Joao Victor Fidelix
@since   25/06/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SGetParam(cParam)

      Local cAlias := SGetNAlias()
      Local cQuery := "select param_valor from tab_parametro where param_desc = '"+STransType(cParam)+"'"
      Local uRet := nil

      dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
      if (cAlias)->(!EOF())
            uRet := (cAlias)->(FieldGet(1))
      endif
      (cAlias)->(dbCloseArea())

return uRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SCriaTbTmp
Criar a tabela temporária com base na estrutura informada

@param aArrStr Array com duas posicoes
					[n,1] Estrutura da tabela a ser criada
					[n,2] Indices da tabela a ser criada

@author  Joao Victor Fidelix
@since   30/04/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SCriaTbTmp(aArrStr, cAliasTab)
	Local cFileTab 
	Local aAlfa := {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
	Local nI := 0
	Local nJ := 0	
	Local aCampos := {}	
	Local oTempTable := Nil	
	Local cBuild     := "" 	
	DEFAULT cAliasTab := SGetNAlias() // Obtem o alias para a tabela temporária

	cBuild := TCGetBuild()	

	If cBuild >= "20141119"  
		//-------------------
		//Criação do objeto
		//-------------------
		oTempTable := FWTemporaryTable():New(cAliasTab, aArrStr[1]) 
	
		For nI := 1 to len(aArrStr[2])
			
			aCampos := StrTokArr( StrTran(aArrStr[2,nI]," ",""), "+" )
			For nJ := 1 to len(aCampos)
				If At('(',aCampos[nJ]) > 0
					aCampos[nJ] := alltrim(SubStr(aCampos[nJ],At('(',aCampos[nJ]) + 1 , Rat(')',aCampos[nJ]) - At('(',aCampos[nJ]) - 1))
				EndIf
				aCampos[nJ] := StrTran(aCampos[nJ],Chr(09),"")//Remoção de tabulação
			Next nJ
			oTempTable:AddIndex( "IND"+cValToChar(nI), aCampos ) 
		Next nI
		oTempTable:Create()
		nI := aScan(aAlSARA,{|x|x[1] == cAliasTab})
		If nI == 0
			aAdd(aAlSARA,{cAliasTab,oTempTable})
		Else
			aAlSARA[nI,2] := oTempTable
		EndIf
		
	Endif	

Return cAliasTab

//-------------------------------------------------------------------
/*/{Protheus.doc} SDelTbTmp
Elimina a tabela temporaria e os respectivos indices

@param cAliasTab Recebe o alias da tabela a eliminar

@author  Joao Victor Fidelix
@since   30/04/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SDelTbTmp(cAliasTab)

	Local cFileTab
	Local nQtdInd
	Local aFileInd := {}	// Armazena os nomes completos dos arquivos de indice
	Local nI

	// Valores do parâmetro de dbOrderInfo
	// 7  - Retorna o nome do arquivo de índice
	// 9  - Retorna a quantidade de índices do alias corrente
	// 20 - Retorna o nome completo (caminho e extensão) do arquivo de índices

	if Select(cAliasTab) > 0
		dbSelectArea(cAliasTab)
		cFileTab := dbInfo(DBI_FULLPATH)
		nQtdInd  := dbOrderInfo(9 /* DBOI_ORDERCOUNT */)

		// Em ambientes com LocalFiles=CTREE, dbOrderInfo(9) considera um índice a mais nas tabelas,
		// correspondente à ordem de inserção na tabela. Quando LocalFiles=ADS, este índice não é contado.
		// LocalFiles é uma opção do arquivo AppServer.ini, informada na sessão correspondente ao ambiente
		// que se quer utilizar.
		if ("CTREE"$RealRDD())
			nQtdInd--
		EndIf

		For nI := 1 to nQtdInd
			dbSetOrder(nI)
			aAdd(aFileInd, dbOrderInfo(20 /* DBOI_FULLPATH */))
		Next nI

		// Fecha e elimina o arquivo correspondente à tabela temporária
		USE
		FErase(cFileTab)

		// Elimina os arquivos de índice da tabela temporária
		For nI := 1 to nQtdInd
			FErase(aFileInd[nI])
		Next nI
	EndIf

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} SCTBTMPG
Tabela temporaria para criacao do FWBrowse

@author  Joao Victor Fidelix
@since   30/04/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SCTBTMPG(cLocal)
	Local cAlias := SGetNAlias()
	Local aStruct := { {'CP1' ,'C',1 ,0} }
	DEFAULT cLocal := "TOPCONN"

	SDelTb(cAlias, cLocal)
	SCriaTb(cAlias, aStruct, nil, cLocal)

return cAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} SCriaTb
Cria tabela temporaria

@param cAlias Nome da tabela a ser criada
@param aStruct Estrutura da tabela a ser criada

@author  Joao Victor Fidelix
@since   30/04/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SCriaTb(cAlias, aStruct, cChave, cLocal)
	Local nMax := Len(aStruct)
	Local cCampo := ""
	Local nI := 0
	LOCAL _SQL	
	nMax := 0	
	DEFAULT cChave := ""
	DEFAULT cLocal := "TOPCONN"

	DBCreate(cAlias, aStruct, cLocal)
	DbUseArea(.T.,cLocal,cAlias,cAlias,.T.,.F.)

	if SEmpty(cChave)
		nMax := len(aStruct)
		if nMax > 2
			cChave := aStruct[1][1] + "+" + aStruct[2][1]
		else
			cChave := aStruct[1][1]
		endif
	endif

   (cAlias)->(DbCreateIndex(cAlias, cChave,{|| &cChave},.F.))
   (cAlias)->(DbClearInd())
   (cAlias)->(DbCloseArea())

   DbUseArea(.T.,cLocal,cAlias,cAlias,.T.,.F.)
   (cAlias)->(DbSetIndex(cAlias))
	
	_SQL := "exec proc_corrige_rec_del '" + cAlias +"'" 
	TCSQLExec(_SQL)
return
//-------------------------------------------------------------------
/*/{Protheus.doc} SDelTb
Cria tabela temporaria

@param cAliasTb Dropa a tabela informada.

@author  Joao Victor Fidelix
@since   30/04/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SDelTb(cAliasTb, cLocal)
	Local cStatement := ''
	DEFAULT cLocal := "TOPCONN"

	If Select(cAliasTb) > 0
		(cAliasTb)->(DbCloseArea())
	EndIf

	if cLocal == 'TOPCONN'
		If ("MSSQL"$TCGetDB())
			cStatement := "if exists(select name from sysobjects where name like '" + cAliasTb + "%' and xtype = 'U')" + CRLF
			cStatement += "begin" + CRLF
			cStatement += "  drop table " + cAliasTb + "" + CRLF
			cStatement += "end" + CRLF
			TCSQLExec(cStatement)
		endif
	else
		FErase(cAliasTb+GetDbExtension())
	endif
return
//-------------------------------------------------------------------
	/*/{Protheus.doc} SCBROWSE
Cria um componente de browse no window e informa a grid que terá filtro para utilizar

@param oOwner Objeto do painel da Janela
@param cAlias Alias da tabela que sera utilizada no Browse
@param aFields Campos que serao mostrados na janela

@author  Joao Victor Fidelix
@since   30/04/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SCBROWSE(oOwner, cAlias, aFields)

	Local oBrowse := nil
	Default aFields := {}

	//Cria um componente de browse no window
	oBrowse := FWBrowse():new(oOwner)
	oBrowse:SetDataTable()
	oBrowse:SetAlias(cAlias)

	//Adiciona os filros
	if aFields != nil
	   oBrowse:SetFieldFilter(aFields)
	endif
	//Informa a grid que terá filtro para utilizar
	oBrowse:SetUseFilter()
	oBrowse:SetLocate() 
return oBrowse

//-------------------------------------------------------------------
	/*/{Protheus.doc} SCBROWSE
Desabilita a edicao dos filtros do browse

@param oBrowse Objeto browse

@author  Marcelo Radulski Nunes
@since   05/03/2015
@version P11
@protected
/*/
//-------------------------------------------------------------------
Function DES_FIL_BW(oBrowse)
   oBrowse:FWFilter():DisableSave(.T.)
   oBrowse:FWFilter():DisableDel(.T.)   
   oBrowse:FWFilter():DisableAdd(.T.)
return

//-------------------------------------------------------------------
/*/{Protheus.doc} SGetNAlias
Busca um novo Alias de tabela disponivel

@author  Joao Victor Fidelix
@since   30/04/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SGetNAlias()

	Local cTmpAlias := ''

	//Verifica se o alias ja nao existe no banco.
	cTmpAlias := GetNextAlias()
	//-- Enquanto o Alias for encontrado busca outro.
	Do While TCCANOPEN(cTmpAlias,)
		cTmpAlias := GetNextAlias()
	EndDo
return cTmpAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} SDBDField
Transforma a data para o tipo de data BD

@param dDate Data que a ser modificada

@author  Joao Victor Fidelix
@since   25/06/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SDBDField(dDate)
	Local cParam := Upper(SuperGetMV('MV_WMSSPD', .F., 'YYYY-MM-DD'))
	Local aParD := {}
	Local cDate  := cMonth := cDay := cYear := ""
	Local cSep   := "-"
	Local nI     := 0
	Local nMax   := 0

	if ValType(dDate) == "C"
		dDate := CToD(dDate)
	endif

	cYear  := STransType(Year(dDate))
	cMonth := STransType(Month(dDate))
	cDay   := STransType(Day(dDate))

	if (At("/", cParam) > 0)
		cSep := '/'
	elseif (At("\", cParam) > 0)
		cSep := '/'
	elseif (At(".", cParam) > 0)
		cSep := '.'
	endif

	aParD := SEPARA(cParam, cSep)
	nMax := len(aParD)

	for nI := 1 to nMax
		if (At('Y', aParD[nI]) > 0)
			if (Len(aParD[nI]) >= 4)
				if (Len(cYear) >= 4)
					cParam := strtran(cParam, aParD[nI], cYear)
				else
					cParam := strtran(cParam, aParD[nI], '20' + cYear)
				endif
			else
				if (Len(cYear) >= 4)
					cParam := strtran(cParam, aParD[nI], substr(cYear, 3, 2))
				else
					cParam := strtran(cParam, aParD[nI], cYear)
				endif
			endif
		elseif (At('M', aParD[nI]) > 0)
			cParam := strtran(cParam, aParD[nI], StrZero(Val(cMonth), 2))
		elseif (At('D', aParD[nI]) > 0)
			cParam := strtran(cParam, aParD[nI], StrZero(Val(cDay), 2))
		endif
	next

return cParam

//-------------------------------------------------------------------
/*/{Protheus.doc} SDBDate
Transforma a data/hora para o tipo de data time do BD

@param dDate Data que a ser modificada
@param cTime Hora que a ser modificada

@author  Joao Victor Fidelix
@since   25/06/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SDBDate(dDate, cTime)
	Local cParam := Upper(SuperGetMV('MV_WMSSPDT', .F., 'YYYY-MM-DD HH:MM:SS.000'))
	Local cParamD := ""
	Local cParamT := ""
	Local aParD := {}
	Local aParDH := {}
	Local cDate  := cMonth := cDay := cYear := cHour := cMin := cSec := ""
	Local cSep   := "-"
	Local nI     := 0
	Local nMax   := 0
	Default cTime := '00:00:00'

	if ValType(dDate) == "C"
		dDate := CToD(dDate)
	endif

	cYear  := STransType(Year(dDate))
	cMonth := STransType(Month(dDate))
	cDay   := STransType(Day(dDate))

	aParDH := SEPARA(cParam, ' ')
	cParamD := aParDH[1]
	cParamT := aParDH[2]

	if (At("/", cParamD) > 0)
		cSep := '/'
	elseif (At("\", cParamD) > 0)
		cSep := '/'
	elseif (At(".", cParamD) > 0)
		cSep := '.'
	endif

	aParD := SEPARA(cParamD, cSep)
	nMax := len(aParD)

	for nI := 1 to nMax
		if (At('Y', aParD[nI]) > 0)
			if (Len(aParD[nI]) >= 4)
				if (Len(cYear) >= 4)
					cParamD := strtran(cParamD, aParD[nI], cYear)
				else
					cParamD := strtran(cParamD, aParD[nI], '20' + cYear)
				endif
			else
				if (Len(cYear) >= 4)
					cParamD := strtran(cParamD, aParD[nI], substr(cYear, 3, 2))
				else
					cParamD := strtran(cParamD, aParD[nI], cYear)
				endif
			endif
		elseif (At('M', aParD[nI]) > 0)
			cParamD := strtran(cParamD, aParD[nI], StrZero(Val(cMonth), 2))
		elseif (At('D', aParD[nI]) > 0)
			cParamD := strtran(cParamD, aParD[nI], StrZero(Val(cDay), 2))
		endif
	next

	cHour  := SubStr(cTime, 0, 2)
	cMin   := SubStr(cTime, 4, 2)
	cSec   := SubStr(cTime, 7, 2)

	cParamT := strtran(cParamT, 'HH', StrZero(Val(cHour), 2))
	cParamT := strtran(cParamT, 'MM', StrZero(Val(cMin), 2))
	cParamT := strtran(cParamT, 'SS', StrZero(Val(cSec), 2))

	cParam := cParamD + " " + cParamT

return cParam

//-------------------------------------------------------------------
/*/{Protheus.doc} SGetDBOwner
Seleciona o banco a ser utilizado

@author  Joao Victor Fidelix
@since   25/06/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SGetDBOwner()

return SuperGetMV('MV_WMSPOWN', .F., 'protheus115..')

//-------------------------------------------------------------------
/*/{Protheus.doc} SMSGERRO


@param
@param

@author  Felipe Machado de Oliveira
@since   06/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SMSGERRO(e,lError)
	Local cDesc :=  e:Description
	Local nCod := e:Gencode

	if nCod == 35
		Alert(STR0001)/*"Instrução SQL inválida!"*/
	else
		Alert(cDesc)
	endif

	lError := .T.
return

//-------------------------------------------------------------------
/*/{Protheus.doc} SCrtSpec
Retira caracteres especiais de uma string

@param cValor Variavel que sera retirada caracteres especiais

@author  Felipe Machado de Oliveira
@since   17/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SCrtSpec(cValor)

	cValor := StrTran(cValor,".")
	cValor := StrTran(cValor,":")
	cValor := StrTran(cValor,";")
	cValor := StrTran(cValor,"]")
	cValor := StrTran(cValor,"[")
	cValor := StrTran(cValor,"}")
	cValor := StrTran(cValor,"{")
	cValor := StrTran(cValor,",")
	cValor := StrTran(cValor,"|")
	cValor := StrTran(cValor,"/")
	cValor := StrTran(cValor,"\")
	cValor := StrTran(cValor,"-")
	cValor := StrTran(cValor,"*")
	cValor := StrTran(cValor,"+")
	cValor := StrTran(cValor,"ª")
	cValor := StrTran(cValor,"º")
	cValor := StrTran(cValor,"¹")
	cValor := StrTran(cValor,"²")
	cValor := StrTran(cValor,"³")
	cValor := StrTran(cValor,"£")
	cValor := StrTran(cValor,"¢")
	cValor := StrTran(cValor,"¬")
	cValor := StrTran(cValor,"'")
	cValor := StrTran(cValor,"?")
	cValor := StrTran(cValor,"!")
	cValor := StrTran(cValor,"@")
	cValor := StrTran(cValor,"#")
	cValor := StrTran(cValor,"$")
	cValor := StrTran(cValor,"%")
	cValor := StrTran(cValor,"¨")
	cValor := StrTran(cValor,"&")
	cValor := StrTran(cValor,"(")
	cValor := StrTran(cValor,")")
	cValor := StrTran(cValor,"§")
	cValor := StrTran(cValor,"=")
	cValor := StrTran(cValor,"<")
	cValor := StrTran(cValor,">")
	cValor := StrTran(cValor,"á","a")
	cValor := StrTran(cValor,"à","a")
	cValor := StrTran(cValor,"â","a")
	cValor := StrTran(cValor,"ã","a")
	cValor := StrTran(cValor,"é","e")
	cValor := StrTran(cValor,"è","e")
	cValor := StrTran(cValor,"ê","e")
	cValor := StrTran(cValor,"í","i")
	cValor := StrTran(cValor,"ì","i")
	cValor := StrTran(cValor,"ó","o")
	cValor := StrTran(cValor,"ò","o")
	cValor := StrTran(cValor,"ô","o")
	cValor := StrTran(cValor,"õ","o")
	cValor := StrTran(cValor,"ú","u")
	cValor := StrTran(cValor,"ù","u")
	cValor := StrTran(cValor,"ç","c")

	cValor := STrim(cValor)

Return(cValor)

//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomUsu
Zoom de usuários

@param lRetCod  Caso deseja retornar o Código
@param lRetCPF  Caso deseja retornar o CPF
@param lRetNome Caso deseja retornar o Nome


@author  Joao Victor Fidelix
@since   30/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomUsu(lRetCod, lRetCPF, lRetNome, lPesqCod, lPesqCPF, lPesqNome)
       Local aRet := {}
       Local aFields := {}
       Default lRetCod := .T.
       Default lRetCPF := .F.
       Default lRetNome := .F.

       Default lPesqCod := .T.
       Default lPesqCPF := .F.
       Default lPesqNome := .F.

       Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL) //Tipo de execução - 1: SQL 2: Array

       Aadd(aRet, "select usu_id,substring(usu_id,2,12) as usu_id2, usu_nome "+;
                         "from tab_usuarios where usu_id is not null " )
       Aadd(aRet, "")

              //aFields,  cCampo             , cDesc                    , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
       SAddPField(@aFields , "usu_id"           , STR0002/*"uCódigo"*/  , "C"   , 15      , 0        , ""      , .F.     , lRetCod , lPesqCod , 1)
       SAddPField(@aFields , "usu_id2"          , STR0002/*"Código"*/   , "C"   , 15      , 0        , ""      , .T.     , lRetCPF , lPesqCPF , 1)
       SAddPField(@aFields , "usu_nome"         , STR0003/*"Nome"*/     , "C"   , 50      , 0        , ""      , .T.     , lRetNome, lPesqNome, 1)

       Aadd(aRet, aFields)
return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomPess
Zoom de pessoas

@param lRetNome Caso deseja retornar o Nome
@param lRetCodigo Caso deseja retornar o Codigo
@param lRetTpDoc Caso deseja retornar o Tipo de documento
@param lRetDoc Caso deseja retornar o Documento

@author  Joao Victor Fidelix
@since   30/04/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomPess(lRetNome, lRetCodigo, lRetTpDoc, lRetDoc, lPesqNome, lPesqCod, lPesqTpDoc, lPesqDoc)

      Local aRet := {}
      Local aFields := {}
      default lRetNome := .F.
      default lRetCodigo := .F.
      default lRetTpDoc := .F.
      default lRetDoc := .F.
      default lPesqNome := .F.
      default lPesqCod := .F.
      default lPesqTpDoc := .F.
      default lPesqDoc := .F.

      Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL) //Tipo de execução - 1: SQL 2: Array

      Aadd(aRet, "select tab_pessoas.pes_id, tab_pessoas.pes_nome,(case when tab_pessoas.pes_cpf is not null "+;
                        "then 'CPF' else (case tab_pessoas.pes_tipo_doc when 0 then 'RG' when 1 then 'CNH' when 2 then 'CTPS' "+;
                        "when 3 then 'PASSAPORTE' when 4 then 'OUTROS' end) end) as tipo_doc, (case when tab_pessoas.pes_cpf is not null "+;
                        "then 'RFB' else tab_pessoas.pes_orgao_emissor end "+;
                        ")as pes_orgao_emissor, (case when tab_pessoas.pes_cpf is not null then substring(tab_pessoas.pes_cpf,1,3) ++'.'++ "+;
                        "substring(tab_pessoas.pes_cpf,4,3) ++'.'++substring(tab_pessoas.pes_cpf,7,3) ++ '-' ++substring(tab_pessoas.pes_cpf,10,2) "+;
                        "else (case tab_pessoas.pes_tipo_doc when 1 then tab_pessoas.pes_cnh else tab_pessoas.pes_rg end) "+;
                        "end) as documento from tab_pessoas where exists ( select distinct 1 from tab_acesso where tab_pessoas.pes_id = tab_acesso.pes_id and tab_acesso.ace_entrada > ( getdate() - 1780)  ) ")
   Aadd(aRet, "order by tab_pessoas.pes_id")

              //aFields,  cCampo             , cDesc                        , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
      SAddPField(@aFields , "pes_id"           , STR0002/*"Código"*/           , "N"  , 7       , 0        , ""      , .F.     , lRetCodigo, lPesqCod, 1) //Monta a estrutura de campos
      SAddPField(@aFields , "pes_nome"         , STR0003/*"Nome"*/             , "C"  , 30      , 0        , ""      , .T.     , lRetNome, lPesqNome, 1)
      SAddPField(@aFields , "tipo_doc"         , STR0004/*"Tipo de documento"*/, "C"  , 15      , 0        , ""      , .T.     , lRetTpDoc, lPesqTpDoc, 1)
      SAddPField(@aFields , "pes_orgao_emissor", STR0005/*"Orgão emissor"*/    , "C"  , 15      , 0        , ""      , .T.     , .F.)
      SAddPField(@aFields , "documento"        , STR0006/*"Documento"*/        , "C"  , 15      , 0        , ""      , .T.     , lRetDoc, lPesqDoc, 1)

      Aadd(aRet, aFields)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomTpDoc
Zoom dos tipos de documentos

@param lRG True para retornar e False para nao retornar o tipo de documento RG
@param lCNH True para retornar e False para nao retornar o tipo de documento CNH
@param lCTPS True para retornar e False para nao retornar o tipo de documento CTPS
@param lPassaporte True para retornar e False para nao retornar o tipo de documento Passaporte
@param lOutros True para retornar e False para nao retornar o tipo de documento Outros
@param lCPF True para retornar e False para nao retornar o tipo de documento CPF

@author  Joao Victor Fidelix
@since   30/04/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomTpDoc(lRG, lCNH, lCTPS, lPassaporte, lOutros, lCPF)

	Local aRet := {}
	Local aFields := {}
	Local aDataFields := {}
	Local aData := {}
	Default lRG := .T.
	Default lCNH := .T.
	Default lCTPS := .T.
	Default lPassaporte := .T.
	Default lOutros := .T.
	Default lCPF := .T.

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_ARRAY) //Tipo de execução - 1: SQL 2: Array

	if lRG
		Aadd(aDataFields, "0")
		Aadd(aDataFields, STR0007)/*"RG"*/
		Aadd(aData, aDataFields)
	endif

	if lCNH
		aDataFields := {}
		Aadd(aDataFields, "1")
		Aadd(aDataFields, STR0008)/*"CNH"*/
		Aadd(aData, aDataFields)
	endif

	if lCTPS
		aDataFields := {}
		Aadd(aDataFields, "2")
		Aadd(aDataFields, STR0009)/*"CTPS"*/
		Aadd(aData, aDataFields)
	endif

	if lPassaporte
		aDataFields := {}
		Aadd(aDataFields, "3")
		Aadd(aDataFields, STR0010)/*"Passaporte"*/
		Aadd(aData, aDataFields)
	endif

	if lOutros
		aDataFields := {}
		Aadd(aDataFields, "4")
		Aadd(aDataFields, STR0011)/*"Outros"*/
		Aadd(aData, aDataFields)
	endif

	if lCPF
		aDataFields := {}
		Aadd(aDataFields, "5")
		Aadd(aDataFields, STR0012)/*"CPF"*/
		Aadd(aData, aDataFields)
	endif

	Aadd(aRet, aData) //Instrucao ou Array com os dados
	Aadd(aRet, nil)

	SAddPField(@aFields, "codigo"   , STR0002/*"Código"*/   , "N",  7, 0, "", .T., .T., .T., 3) //Monta a estrutura de campos
	SAddPField(@aFields, "descricao", STR0006/*"Documento"*/, "C", 50, 0, "", .T., .F.)

	Aadd(aRet, aFields)

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomVeiculo
Zoom de veiculos

@param lvei_id True para retornar e False para nao retornar a Placo
@param lvei_tipo True para retornar e False para nao retornar o Tipo
@param lvei_modelo True para retornar e False para nao retornar o Modelo
@param lvei_ano True para retornar e False para nao retornar o Ano
@param lvei_marca True para retornar e False para nao retornar a Marca
@param lvei_cor True para retornar e False para nao retornar a Cor

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomVeiculo(lvei_id,lvei_tipo,lvei_modelo,lvei_ano,lvei_marca,lvei_cor)

	Local aRet := {}
	Local aFields := {}
	Default lvei_id     := .T.
	Default lvei_tipo   := .F.
	Default lvei_modelo := .F.
	Default lvei_ano    := .F.
	Default lvei_marca  := .F.
	Default lvei_cor    := .F.

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)
	
	Aadd(aRet, "select distinct vei_id, vei_tipo, vei_modelo, vei_ano, vei_marca, vei_cor "+;
               " from tab_veiculos where vei_id is not null and vei_id in (select b.vei_id from "+; 
               " tab_cesv b where b.vei_id = vei_id and b.cesv_cancelada is null and b.cesv_dt_entrada is not null)")
	
	Aadd(aRet, ' order by vei_id ')

              //aFields,   cCampo           ,  cDesc      , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
	SAddPField(@aFields , "vei_id"           , STR0013/*"Placa"*/     , "C"  , 10      , 0        , ""      , .T.     , lvei_id, .T., 1)
	SAddPField(@aFields , "vei_tipo"         , STR0014/*"Tipo"*/      , "C"  , 10      , 0        , ""      , .T.     , lvei_tipo)
	SAddPField(@aFields , "vei_modelo"       , STR0015/*"Modelo"*/    , "C"  , 10      , 0        , ""      , .T.     , lvei_modelo)
	SAddPField(@aFields , "vei_ano"          , STR0016/*"Ano"*/       , "C"  , 10      , 0        , ""      , .T.     , lvei_ano)
	SAddPField(@aFields , "vei_marca"        , STR0017/*"Marca"*/     , "C"  , 15      , 0        , ""      , .T.     , lvei_marca)
	SAddPField(@aFields , "vei_cor"          , STR0018/*"Cor"*/       , "C"  , 10      , 0        , ""      , .T.     , lvei_cor)

	Aadd(aRet, aFields)

return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomTransp
Zoom da transportadora

@param lTrans_id True para retornar e False para nao retornar o Codigo
@param lTrans_nome True para retornar e False para nao retornar a Transportadora

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomTransp(lTrans_id,lTrans_nome, lPID, lPNome, lTrans_cgc, lPCgc)
	Local aRet := {}
	Local aFields := {}
	Default lTrans_id := .F.
	Default lTrans_nome := .F.
	Default lTrans_cgc := .F.	
	Default lPID := .F.
	Default lPNome := .F.
	Default lPCgc  := .F.

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	Aadd(aRet, "select trans_id, trans_cgc, trans_nome, " +;
    			 "	case len(trans_cgc) " +; 
    	 		 "   when 14 then  " +;
   				 "       substring(trans_cgc,1,2)++'.'++substring(trans_cgc,3,3)++'.'++substring(trans_cgc,6,3)++'/' " +;
    			 "       ++substring(trans_cgc,9,4)++'-'++substring(trans_cgc,13,2) " +; 
    			 "   when 11 then  " +;
    			 "       substring(trans_cgc,1,3)++'.'++substring(trans_cgc,4,3)++'.'++substring(trans_cgc,7,3)++'-' " +;
    			 "       ++substring(trans_cgc,10,2) " +; 
				 "  else  " +;
    			 "      trans_cgc " +;
    	  		 "end as trans_cgc_mascara " +;     
				 "from " +;
				 "  tab_transportadora where trans_id is not null")
	
	
	
	Aadd(aRet, " order by trans_nome ")
              //aFields,   cCampo              ,  cDesc                     , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
	SAddPField(@aFields , "trans_id"           , STR0002/*"Código"*/         , "N"  , 10      , 0        , ""      , .F.     , lTrans_id, lPID, 1)
	SAddPField(@aFields , "trans_cgc_mascara"  , STR0026/*"CNPJ/CPF"*/       , "C"  , 20      , 0        , ""      , .T.     , lTrans_cgc, lPCgc, 1)	
	SAddPField(@aFields , "trans_nome"         , STR0019/*"Transportadora"*/ , "C"  , 50      , 0        , ""      , .T.     , lTrans_nome, lPNome, 1)

	Aadd(aRet, aFields)
return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomTran2
Zoom da transportadora

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomTran2()
	Local aRet := {}
	Local aFields := {}

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	Aadd(aRet, "select rel_trans_ben_com.trans_id, tab_clientes.cli_nome from tab_clientes "+;
				 "inner join rel_trans_ben_com on tab_clientes.cli_id = rel_trans_ben_com.ben_id where 1 = 1")
	Aadd(aRet, " order by tab_clientes.cli_nome ")
              //aFields,   cCampo            ,  cDesc                     , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
	SAddPField(@aFields , "trans_id"         , STR0002/*"Código"*/         , "N"  , 10      , 0        , ""      , .T.     , .T., .F., 1)
	SAddPField(@aFields , "cli_nome"         , STR0019/*"Transportadora"*/ , "C"  , 20      , 0        , ""      , .T.     , .T., .T., 1)

	Aadd(aRet, aFields)
return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomPais
Zoom dos Paises

@param lpais_id True para retornar e False para nao retornar o Codigo
@param lpais_nome True para retornar e False para nao retornar a Pais

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomPais(lpais_id,lpais_nome)

	Local aRet         := {}
	Local aFields      := {}
	Default lpais_id   := .F.
	Default lpais_nome := .F.

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	Aadd(aRet, "select distinct pais_id, pais_nome from tab_pais where pais_id is not null")
	Aadd(aRet, "")

              //aFields,   cCampo              ,  cDesc    , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
	SAddPField(@aFields , "pais_id"           , STR0002/*"Código"*/   , "C"  , 20      , 0        , ""      , .F.     , lpais_id)
	SAddPField(@aFields , "pais_nome"         , STR0020/*"País"*/     , "C"  , 20      , 0        , ""      , .T.     , lpais_nome, .T., 1)

	Aadd(aRet, aFields)

return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomContUni
Zoom de Container

@param lcnt_id True para retornar e False para nao retornar o Container
@param lcnt_tipo True para retornar e False para nao retornar a Tipo

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomContUni(lcnt_id,lcnt_tipo)

	Local aRet := {}
	Local aFields := {}
	Default lcnt_id := .T.
	Default lcnt_tipo := .F.

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	Aadd(aRet, "select cnt_id, cnt_tipo from tab_container where cnt_id is not null and cnt_id <> '-----------'")
	Aadd(aRet, "")

              //aFields,   cCampo              ,  cDesc     , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
	SAddPField(@aFields , "cnt_id"           , STR0021/*"Container"*/   , "C"  , 20      , 0        , ""      , .T.     , lcnt_id, .T., 1)
	SAddPField(@aFields , "cnt_tipo"         , STR0014/*"Tipo"*/        , "C"  , 20      , 0        , ""      , .T.     , lcnt_tipo)

	Aadd(aRet, aFields)

return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomPlaca
Zoom da Placa do veiculo

@author  Marcio Franklin Carvalho de Noronha
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomPlaca(lReboque)
	Local aRet := {}
	Local aFields := {}
	Local lSQL := ""
	Local cTipoCarrega := STrim(SGetParam('TIPO_CARRETA'))
	DEFAULT lReboque := .F.

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL) //Tipo de execução - 1: SQL 2: Array

	lSQL := " select tab_veiculos.vei_id " +;
           " from tab_veiculos, tab_tipo_veiculo "+;
           " where tab_veiculos.tipo_id = tab_tipo_veiculo.tipo_id "+;
           " and exists (select distinct 1 from tab_cesv a where a.cesv_dt_entrada > ( getdate() - 1780 ) and (a.vei_id = tab_veiculos.vei_id or  a.vei_id_rbq = tab_veiculos.vei_id) ) "
	if lReboque
		lSQL := lSQL + " and tab_tipo_veiculo.tipo_descricao = '"+ cTipoCarrega+"'"
   else
		lSQL := lSQL + " and tab_tipo_veiculo.tipo_descricao <> '"+ cTipoCarrega+"'"
   endif

   Aadd(aRet, lSQL)
   Aadd(aRet, " order by tab_veiculos.vei_id ")

              //aFields,  cCampo      , cDesc    , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
	SAddPField(@aFields , "vei_id"  , STR0013/*"Placa"*/  , "C"  , 20       , 0        , ""      , .T.     , .T., .T., 1) //Monta a estrutura de campos

	Aadd(aRet, aFields)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomLoteConhec
Zoom de Container

@param lRetLote True para retornar e False para nao retornar o Lote
@param lRetConhec True para retornar e False para nao retornar o Container

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
function SZoomLoteConhec(lRetLote, lRetConhec)

   	Local aRet := {}
	Local aFields := {}
	default lRetLote := .F.
	default lRetConhec := .F.

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	Aadd(aRet,'SELECT                                                                  ' +;
			  ' DISTINCT                                                               ' +;  
			  '  A.LOTE_CONHEC,                                                        ' +;  
			  '  SUBSTRING (A.LOTE_ID_RF,                                              ' +;
			  '             1,                                                         ' +; 
			  '             2) + "/" + SUBSTRING (A.LOTE_ID_RF,                        ' +;
			  '                                   3,                                   ' +;
			  '                                   6) + "-" + SUBSTRING (A.LOTE_ID_RF,  ' +;
			  '                                                         9,             ' +;  
			  '                                                       1) AS LOTE_ID_RF,' +;
			  '  A.LOTE_ID,                                                            ' +;
			  '  B.CLI_NOME                                                            ' +;
			  ' FROM                                                                   ' +; 
			  '  TAB_LOTE A                                                            ' +;
			  '    LEFT OUTER JOIN TAB_TIPO_CONHECIMENTO Z                             ' +;
			  '   ON A.CONHEC_ID = Z.CONHEC_ID AND  Z.CONHEC_NOME NOT IN ("NF", "RNF"),' +;
			  '  TAB_CLIENTES B                                                        ' +; 
			  ' WHERE                                                                  ' +;
			  '  A.BEN_ID  = B.CLI_ID AND                                              ' +;
			  '  A.LOTE_CANCELADO IS NULL                                              ' )

   SAddPField(@aFields , "lote_conhec"       , STR0022/*"Conhecimento"*/  , "C"  , 20  , 0  , ""  , .T.   , lRetConhec)
   SAddPField(@aFields , "lote_id"           , STR0023/*"Lote"*/          , "C"  , 20  , 0  , ""  , .T.   , lRetLote)
   SAddPField(@aFields , "cli_nome"          , STR0024/*"Nome Cliente"*/  , "C"  , 30  , 0  , ""  , .T.   , .F.)

	aadd(aRet, aFields)

return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SValLCFi
Validacao do conhecimento unitario

@param nVal Conteudo que seleciona determinado SELECT
@param nVal2 Conteudo a ser validado

@author  Marcio Franklin Carvalho de Noronha
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SValLCFi(xConteud, nOpc)
	Local cAlias := ''
	Local cQuery := ''
	Local lRet := .T.
	Default nOpc := 0

	if !SEmpty(xConteud)

		cQuery := 'select distinct tab_lote.lote_conhec ' +;
              ' from tab_lote , tab_clientes ' +;
              ' where tab_lote.ben_id = tab_clientes.cli_id ' +;
              ' and 0 < (select COUNT(*) from rel_lote where rel_lote.lote_filho = tab_lote.lote_id ) + ' +;
              ' (select COUNT(*) from rel_lote where rel_lote.lote_pai = tab_lote.lote_id ) + ' +;
              ' (select COUNT(*) from rel_lote_consolidacao where rel_lote_consolidacao.lote_id = tab_lote.lote_id )';

	   if nOpc == 0
          cQuery := cQuery + " and tab_lote.lote_conhec = '"+STrim(STransType(xConteud))+"'"
       elseif nOpc == 1
          cQuery := cQuery + " and tab_lote.lote_id = '"+STrim(STransType(xConteud))+"'"
       endif

		cAlias := SGetNAlias()

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		lRet := (cAlias)->(!EOF())

		(cAlias)->(dbCloseArea())
	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SZLConhecFi
Zoom conhecimento de transporte Filho

@author  João Victor Fidelix
@since   13/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
function SZLConhecFi(lConhec, lLote, lCli)
	Local aRet := {}
	Local aFields := {}
	Default lConhec := .T.
	Default lLote := .F.
	Default lCli := .F.

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	Aadd(aRet,"select tab_lote.lote_conhec, " +;
	          " substring(tab_lote.lote_id_rf,1,2)+'/'+"+;
              " substring(tab_lote.lote_id_rf,3,6)+'-'+"+;
              " substring(tab_lote.lote_id_rf,9,1) as lote_id_rf,"+;	          
	          " tab_lote.lote_id, tab_clientes.cli_nome " +;
              " from tab_lote , tab_clientes " +;
              " where tab_lote.ben_id = tab_clientes.cli_id " +;
              " and 0 < (select COUNT(*) from rel_lote where rel_lote.lote_filho = tab_lote.lote_id ) + " +;
              " (select COUNT(*) from rel_lote where rel_lote.lote_pai = tab_lote.lote_id ) + " +;
              " (select COUNT(*) from rel_lote_consolidacao where rel_lote_consolidacao.lote_id = tab_lote.lote_id ) ")
   Aadd(aRet," order by tab_lote.lote_id")

   SAddPField(@aFields , "lote_conhec"       , STR0022/*"Conhecimento"*/ , "C"  , 20  , 0  , ""  , .T.   , lConhec, lConhec, 1)
   SAddPField(@aFields , "tab_lote.lote_id_rf", STR0023/*"Lote"*/        , "C"  , 20  , 0  , "@R 99/999999-9"  , .T.   , lLote  , lLote  , 1)
   SAddPField(@aFields , "lote_id"           , STR0065/*"Lote sistema"*/  , "C"  , 20  , 0  , ""  , .T.   , .F.  , .F.  , 1)
   SAddPField(@aFields , "cli_nome"          , STR0024/*"Nome Cliente"*/  , "C"  , 30  , 0  , ""  , .T.   , lCli   , lCli   , 1)

	aadd(aRet, aFields)

return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomConta
Zoom de Container

@param lRetConta True para retornar e False para nao retornar o Container

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
function SZoomConta(lRetConta)

   	Local aRet := {}
	Local aFields := {}
	default lRetConta := .T.

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	Aadd(aRet, 	' select                        '+;
				' distinct                      '+;
				'    i.cnt_id,                  '+;
				'    i.cnt_tipo,                '+; 
				'    j.tiso_descricao           '+;  
				' from                          '+; 
				'   tab_lote a,                 '+; 
				'   tab_clientes b,             '+;
				'   vw_opr_GCI_LoteAtual e,     '+;
				'   tab_container i,            '+;
				'  tab_tipo_iso j               '+;
				' where                         '+;
				'   a.ben_id = b.cli_id         '+;
				'   and a.lote_cancelado is null'+;  
				'   and i.cnt_id = e.cnt_id     '+; 
				'   and j.tiso_id = i.tiso_id   ')

   SAddPField(@aFields , "cnt_id"         , STR0025/*"Numero"*/     , "C"  , 20  , 0  , ""  , .T.   , lRetConta)
   SAddPField(@aFields , "cnt_tipo"       , STR0014/*"Tipo"*/       , "C"  , 20  , 0  , ""  , .T.   , .F.)
   SAddPField(@aFields , "tiso_descricao" , STR0021/*"Container"*/  , "C"  , 30  , 0  , ""  , .T.   , .F.)

	aadd(aRet, aFields)

return aRet

Function SZoomConCli(lCli_id,lCli_nome,lCli_cnpj, lPesqID, lPesqNome, lPesqCNPJ)
	Local aRet := {}
	Local aFields := {}
	Local cQuery := ""
	Default lCli_nome := .T.
	Default lCli_cnpj := .F.
	Default lCli_id   := .F.
	Default lPesqNome := .T.
	Default lPesqCNPJ := .F.
	Default lPesqID   := .F.

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	cQuery := "select x.cli_nome, "+;
		"(case x.cli_cgc "+;
		"when null then "+;
		"substring(x.cli_cpf,1,3)++'.'++substring(x.cli_cpf,4,3)++'.'++substring(x.cli_cpf,7,3)++'-'++substring(x.cli_cpf,10,2) "+;
		"else "+;
		"case len(x.cli_cgc) "+;
		"when 14 then "+;
		"substring(x.cli_cgc,1,2)++'.'++substring(x.cli_cgc,3,3)++'.'++substring(x.cli_cgc,4,3)++'/'++substring(x.cli_cgc,9,4)++'-'++substring(x.cli_cgc,13,3) "+;
		"else x.cli_cgc "+;
		"end "+;
		"end) as cli_cnpj, "+;
		"cli_id "+;
		"from tab_clientes x "+;
		"where 1= 1 "+;
		" and exists (select distinct 1 "+;
		"               from tab_lote a, "+;
		"                    tab_documentos f, "+;
		"                    tab_di_item g, "+;
		"                    tab_regimes h, "+;
		"                    tab_moedas i "+;
		"              where a.lote_cancelado is null "+;
		"                and a.ben_id = x.cli_id "+;
		"                and substring(a.dent_id,5,1) = f.doc_ordem1 "+;
		"                and g.latu_lote = a.lote_id "+;
		"                and a.reg_id = h.reg_id "+;
		"                and isnull(h.reg_alfandegado,0) = 1 "+;
		"                and a.lote_moeda = i.moe_id )"

	Aadd(aRet, cQuery)
	Aadd(aRet, " ORDER BY x.cli_nome")

       			//aFields,    cCampo ,   cDesc , cTipo, nTamanho, nPrecisao, cMascara , lVisivel, lRetorna
	SAddPField(@aFields , "cli_nome" , STR0029/*"Cliente"*/  , "C"  , 50 , 0 , "" , .T. , lCli_nome, lPesqNome, 1)
	SAddPField(@aFields , "cli_cnpj" , STR0026/*"CNPJ/CPF"*/ , "C"  , 20 , 0 , "" , .T. , lCli_cnpj, lPesqCNPJ, 1)
	SAddPField(@aFields , "cli_id"   , STR0002/*"Código"*/   , "C"  , 10 , 0 , "" , .T. , lCli_id, lPesqID, 1)

	Aadd(aRet, aFields)

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomConsig
Zoom de Cosignatario

@param lcli_id True para retornar e False para nao retornar o Numero
@param lcli_cgc True para retornar e False para nao retornar o CNPJ\CPF
@param lcli_nome True para retornar e False para nao retornar o Nome

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomConsig(lcli_id,lcli_cgc,lcli_nome)

	Local   aRet      := {}
	Local   aFields   := {}
	Local   cQuery    := ''
	Default lcli_id   := .F.
	Default lcli_cgc  := .F.
	Default lcli_nome := .F.

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	cQuery  :=  " select distinct cli_id, cli_cgc, cli_nome, "+;
					"case len(cli_cgc) "+;
						"when 14 then "+;
							"substring(cli_cgc,1,2)++'.'++substring(cli_cgc,3,3)++'.'++substring(cli_cgc,6,3)++'/'++substring(cli_cgc,9,4)++'-'++substring(cli_cgc,13,2) "+;
						"when 11 then "+;
							"substring(cli_cgc,1,3)++'.'++substring(cli_cgc,4,3)++'.'++substring(cli_cgc,7,3)++'-'++substring(cli_cgc,10,2) "+;
						"else "+;
							"cli_cgc "+;
					"end as cli_cgc_mascara "+;
				" from tab_clientes "+;	
				"  inner join tab_doc_entrada a "+;
				"    on a.ben_id = tab_clientes.cli_id "+;
				"  inner join tab_doc_saida b "+;
				"    on a.ben_id = tab_clientes.cli_id "+;	
				" and exists (select distinct 1 from tab_doc_entrada a where a.ben_id = tab_clientes.cli_id and a.dent_dt_emissao > (getdate() - 1780 ) )"+;
				"    or exists (select distinct 1 from tab_doc_saida b where b.ben_id = tab_clientes.cli_id and b.dsai_dt_registro > (getdate() - 1780 ) )"+;
				"  where cli_id is not null     "

	Aadd(aRet, cQuery)
	Aadd(aRet, 'order by cli_id')

   SAddPField(@aFields , "cli_id"          , STR0025/*"Numero"*/   , "C"  , 20  , 0  , ""  , .F.   , lcli_id)
   SAddPField(@aFields , "cli_cgc_mascara" , STR0026/*"CNPJ/CPF"*/ , "C"  , 20  , 0  , ""  , .T.   , lcli_cgc)
   SAddPField(@aFields , "cli_nome"        , STR0003/*"Nome"*/     , "C"  , 30  , 0  , ""  , .T.   , lcli_nome, .T., 1)

	Aadd(aRet, aFields)

return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomReg
Zoom de Regime

@param lreg_id True para retornar e False para nao retornar o ID
@param lreg_nome True para retornar e False para nao retornar o Nome

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomReg(lreg_id,lreg_nome)

	Local   aRet      := {}
	Local   aFields   := {}
	Default lreg_id   := .F.
	Default lreg_nome := .F.

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	Aadd(aRet, "select reg_id,reg_nome from tab_regimes where reg_alfandegado = '1' ")
	Aadd(aRet, " union select 0, 'TODOS' from tab_regimes")

   SAddPField(@aFields , "reg_id"   , STR0045/*"ID"*/   , "C"  , 20  , 0  , ""  , .F.   , lreg_id)
   SAddPField(@aFields , "reg_nome" , STR0003/*"Nome"*/ , "C"  , 50  , 0  , ""  , .T.   , lreg_nome, .T., 1)

	Aadd(aRet, aFields)

return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomDocEnt
Zoom de Documento de entrada

@param ldent_id True para retornar e False para nao retornar o Documento
@param llote_id True para retornar e False para nao retornar o Codigo
@param lcli_nome True para retornar e False para nao retornar o Nome

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomDocEnt(ldent_id,llote_id,lcli_nome)

	Local aRet := {}
	Local aFields := {}
	Default ldent_id := .T.
	Default llote_id := .F.
	Default lcli_nome := .F.

   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL) //Tipo de execução - 1: SQL 2: Array
   Aadd(aRet, "select distinct rel_dent_cnt.dent_id,"+;
               "substring(tab_lote.lote_id_rf,1,2)+'/'+"+;
               "substring(tab_lote.lote_id_rf,3,6)+'-'+"+;
               "substring(tab_lote.lote_id_rf,9,1) as lote_id_rf,"+; 
               "rel_dent_cnt.lote_id, tab_clientes.cli_nome "+;
               "from rel_dent_cnt, tab_lote, tab_clientes where rel_dent_cnt.lote_id = tab_lote.lote_id and tab_clientes.cli_id = tab_lote.ben_id "+;
               " and exists(select distinct 1 from tab_doc_entrada a where a.dent_id = rel_dent_cnt.dent_id and a.dent_dt_emissao > (getdate() - 1780 ) ) ")
   Aadd(aRet, "")

               //aFields,  cCampo                          , cDesc                       , cTipo, nTamanho, nPrecisao, cMascara        , lVisivel, lRetorna
	SAddPField(@aFields , "rel_dent_cnt.dent_id"           , STR0006/*"Documento"*/        , "C"  , 50       , 0        , ""                 , .T.     , ldent_id , ldent_id , 1) //Monta a estrutura de campos
	SAddPField(@aFields , "tab_lote.lote_id_rf"            , STR0023/*"Código"*/           , "C"  , 30       , 0        , "@R 99/999999-9"  , .T.     , llote_id , llote_id , 1)
	SAddPField(@aFields , "rel_dent_cnt.lote_id"           , STR0065/*"Lote sistema"*/   , "C"  , 30       , 0        , ""                  , .T.     , .F.       , .F.      , 1)
	SAddPField(@aFields , "tab_clientes.cli_nome"          , STR0003/*"Nome"*/             , "C"  , 50       , 0        , ""                  , .T.     , lcli_nome, lcli_nome, 1)

	Aadd(aRet, aFields)

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomNF
Zoom de Nota Fiscal

@param lRetTipo_nota True para retornar e False para nao retornar o Tipo
@param lRetNumero True para retornar e False para nao retornar o Numero
@param lRetAno_nota_fiscal True para retornar e False para nao retornar o Ano
@param lRetNotaFiscal True para retornar e False para nao retornar a Nota Fiscal
@param lRetSer_nota_fiscal True para retornar e False para nao retornar a Serie
@param lRetCliente True para retornar e False para nao retornar o Cliente
@param lRetCnpj_cfp True para retornar e False para nao retornar o CNPJ/CPF
@param lRetData True para retornar e False para nao retornar a Data de Emissao

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
function SZoomNF(lRetTipo_nota,lRetNumero,lRetAno_nota_fiscal,lRetNotaFiscal,lRetSer_nota_fiscal,lRetCliente,lRetCnpj_cfp,lRetData)
	Local aRet := {}
	Local aFields := {}
	Default lRetTipo_nota       := .F.
	Default lRetNumero          := .F.
	Default lRetAno_nota_fiscal := .F.
	Default lRetNotaFiscal      := .T.
	Default lRetSer_nota_fiscal := .F.
	Default lRetCliente         := .F.
	Default lRetCnpj_cfp        := .F.
	Default lRetData            := .F.

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	Aadd(aRet,'select distinct '+;
				' tipo_nota, ' +;
              ' numero, ' +;
              ' ano_nota_fiscal, ' +;
              ' num_nota_fiscal, ' +;
              ' ser_nota_fiscal, ' +;
              ' cliente, ' +;
              ' cnpj_cfp, '+;
              " isnull(data_emissao, ' ') as data "+;
				' from '+;
				' vw_not_fisc_compil ')

   SAddPField(@aFields , "tipo_nota"        , STR0014/*"Tipo"*/               , "C"  , 20  , 0  , ""  , .T.   , lRetTipo_nota)
   SAddPField(@aFields , "numero"           , STR0025/*"Numero"*/             , "C"  , 20  , 0  , ""  , .T.   , lRetNumero)
   SAddPField(@aFields , "ano_nota_fiscal"  , STR0016/*"Ano"*/                , "C"  , 20  , 0  , ""  , .T.   , lRetAno_nota_fiscal)
   SAddPField(@aFields , "num_nota_fiscal"  , STR0027/*"Nota Fiscal"*/        , "C"  , 20  , 0  , ""  , .T.   , lRetNotaFiscal)
   SAddPField(@aFields , "ser_nota_fiscal"  , STR0028/*"Ser Nota Fiscal"*/    , "C"  , 20  , 0  , ""  , .T.   , lRetSer_nota_fiscal)
   SAddPField(@aFields , "cliente"          , STR0029/*"Cliente"*/            , "C"  , 20  , 0  , ""  , .T.   , lRetCliente)
   SAddPField(@aFields , "cnpj_cfp"         , STR0026/*"CNPJ/CPF"*/           , "C"  , 20  , 0  , ""  , .T.   , lRetCnpj_cfp)
   SAddPField(@aFields , "data"             , STR0030/*"Data Emissão"*/       , "C"  , 20  , 0  , ""  , .T.   , lRetData)

	aadd(aRet, aFields)

return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomConhec
Zoom de Conhecimento

@param lRetLote True para retornar e False para nao retornar o lote
@param lRetID True para retornar e False para nao retornar o Codigo
@param lRetCarga True para retornar e False para nao retornar a Carga

@author  Marcio Franklin Carvalho de Noronha
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomConhec(lRetLote, lRetID, lRetCarga)
	Local aRet := {}
	Local aFields := {}
	Default lRetLote  := .F.
	Default lRetID    := .F.
	Default lRetCarga := .F.

   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL) //Tipo de execução - 1: SQL 2: Array
   Aadd(aRet, " select a.lote_conhec, "+;              
               "        substring(a.lote_id_rf,1,2)+'/'+"+;
               "        substring(a.lote_id_rf,3,6)+'-'+"+;
               "        substring(a.lote_id_rf,9,1) as lote_id_rf,"+;
               "        a.lote_id, "+;
               "        b.cli_nome, "+;
               "        a.lote_pcarga "+;
               "   from tab_lote a, "+;
               "        tab_clientes b, "+;
			   "         rel_rnf_dent c "+;
               "  where a.ben_id = b.cli_id "+;
			   "    and a.dent_id = c.dent_id "+;
               "    and a.lote_dt_conhec > (getdate() - 3500 )")
   Aadd(aRet, "order by a.lote_id")

               //aFields,  cCampo             , cDesc                                 , cTipo, nTamanho, nPrecisao, cMascara       , lVisivel, lRetorna
	SAddPField(@aFields , "a.lote_conhec"     , STR0022/*"Conhecimento"*/               , "C"  , 30       , 0        , ""                , .T.      , lRetLote , lRetLote, 1 ) //Monta a estrutura de campos
	SAddPField(@aFields , "a.lote_id_rf"      , STR0023/*"Lote"*/                        , "C"  , 30       , 0        , "@R 99/999999-9", .T.       , lRetID   , lRetID, 1) //Monta a estrutura de campos
	SAddPField(@aFields , "a.lote_id"          , STR0065/*"Lote sistema"*/              , "C"  , 30       , 0        , ""                , .T.       , .F.   , .F., 2) //Monta a estrutura de campos
	SAddPField(@aFields , "b.cli_nome"         , STR0029/*"Cliente"*/                    , "C"  , 70       , 0        , ""                , .T.       , .F.) //Monta a estrutura de campos
	SAddPField(@aFields , "a.lote_pcarga"      , STR0031/*"Lote Carga/CE Mercadante"*/, "C"  , 50       , 0        , ""                , .T.       , lRetCarga, lRetCarga, 1) //Monta a estrutura de campos

	Aadd(aRet, aFields)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomConhec
Zoom de Conhecimento

@param lRetLote True para retornar e False para nao retornar o lote
@param lRetID True para retornar e False para nao retornar o Codigo
@param lRetCarga True para retornar e False para nao retornar a Carga

@author  Joao Victor
@since   31/10/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomConh2()
	Local aRet := {}
	Local aFields := {}
   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL) //Tipo de execução - 1: SQL 2: Array
   Aadd(aRet, " select a.lote_conhec, "+;
              " substring(a.lote_id_rf,1,2)+'/'+"+;
              " substring(a.lote_id_rf,3,6)+'-'+"+;
              " substring(a.lote_id_rf,9,1) as lote_rf_ma,"+; 
              " a.lote_id, "+;
              " d.cli_nome, "+;
              " c.lote_conhec as lote_con_f,"+;
              " substring(c.lote_id_rf,1,2)+'/'+"+;
              " substring(c.lote_id_rf,3,6)+'-'+"+;
              " substring(c.lote_id_rf,9,1) as lote_rf_fi, "+;
              " c.lote_id as lote_id_f "+;
              " from tab_lote a "+;
              " left join tab_clientes d "+;
              " on a.ben_id = d.cli_id, "+;
              " rel_lote b, "+;
              " tab_lote c "+;
              " where a.lote_id = b.lote_pai and b.lote_filho = c.lote_id")
   Aadd(aRet, "order by a.lote_id")
   
              //aFields,  cCampo              , cDesc                                 , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
	SAddPField(@aFields , "a.lote_conhec"     , STR0022/*"Conhecimento"*/              , "C"  , 30       , 0        , ""      , .T.     , .T., .T., 1 ) //Monta a estrutura de campos
    SAddPField(@aFields , "a.lote_id_rf"      , STR0023/*"Lote"*/                       , "C"  , 15       , 0        , "@R 99/999999-9"      , .T.     , .F., .F., 1) //Monta a estrutura de campos
	SAddPField(@aFields , "a.lote_id"          , STR0066/*"Lote master sistema"*/     , "C"  , 15       , 0        , ""      , .T.     , .F., .F., 1) //Monta a estrutura de campos
	SAddPField(@aFields , "d.cli_nome"         , STR0029/*"Cliente"*/                   , "C"  , 70       , 0        , ""      , .T.     , .F., .F., 1) //Monta a estrutura de campos
	SAddPField(@aFields , "c.lote_conhec"     , STR0031/*"Lote Carga/CE Mercadante"*/, "C"  , 50       , 0        , ""      , .T.     , .F., .F., 1) //Monta a estrutura de campos
	SAddPField(@aFields , "c.lote_id_rf"      , STR0041/*"Lote Filho"*/                , "C"  , 15       , 0        , "@R 99/999999-9"      , .T.     , .F., .F., 1) //Monta a estrutura de campos
	SAddPField(@aFields , "c.lote_id"         , STR0067/*"Lote Filho sistema"*/       , "C"  , 15       , 0        , ""      , .T.     , .F., .F., 1) //Monta a estrutura de campos
	
	Aadd(aRet, aFields)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomConh9

@param lRetLote True para retornar e False para nao retornar o lote
@param lRetID True para retornar e False para nao retornar o Codigo
@param lRetCarga True para retornar e False para nao retornar a Carga

@author  Ruan Ricardo Salvador
@since   23/08/2016
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomConh9(lRetLote, lRetID, lRetCarga, lRetOpcao)
	Local aRet := {}
	Local aFields := {}
	
	local Compsql := ''
	
	Default lRetLote  := .F.
	Default lRetID    := .F.
	Default lRetCarga := .F.
	
    if lRetOpcao  
      Compsql += " and z.conhec_nome not in ('NF', 'RNF') "
    else
      Compsql += " and z.conhec_nome in ('NF', 'RNF') "
    endif
	
   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL) //Tipo de execução - 1: SQL 2: Array
   Aadd(aRet,  " select a.lote_conhec, "+;              
               "        substring(a.lote_id_rf,1,2)+'/'+"+;
               "        substring(a.lote_id_rf,3,6)+'-'+"+;
               "        substring(a.lote_id_rf,9,1) as lote_id_rf,"+;
               "        a.lote_id, "+;
               "        b.cli_nome, "+;
               "        a.lote_pcarga "+;
               "   from tab_lote a "+;
               "        left outer join tab_tipo_conhecimento z "+;                              
               "         on a.conhec_id = z.conhec_id, "+;
               "        tab_clientes b "+;
               "  where a.ben_id = b.cli_id and a.lote_dt_conhec > (getdate() - 1780 )  " + Compsql)
   Aadd(aRet, "order by a.lote_id")

               //aFields,  cCampo             , cDesc                                 , cTipo, nTamanho, nPrecisao, cMascara       , lVisivel, lRetorna
	SAddPField(@aFields , "a.lote_conhec"     , STR0022/*"Conhecimento"*/               , "C"  , 30       , 0        , ""                , .T.      , lRetLote , lRetLote, 1 ) //Monta a estrutura de campos
	SAddPField(@aFields , "a.lote_id_rf"      , STR0023/*"Lote"*/                        , "C"  , 30       , 0        , "@R 99/999999-9", .T.       , lRetID   , lRetID, 1) //Monta a estrutura de campos
	SAddPField(@aFields , "a.lote_id"          , STR0065/*"Lote sistema"*/              , "C"  , 30       , 0        , ""                , .T.       , .F.   , .F., 2) //Monta a estrutura de campos
	SAddPField(@aFields , "b.cli_nome"         , STR0029/*"Cliente"*/                    , "C"  , 70       , 0        , ""                , .T.       , .F.) //Monta a estrutura de campos
	SAddPField(@aFields , "a.lote_pcarga"      , STR0031/*"Lote Carga/CE Mercadante"*/, "C"  , 50       , 0        , ""                , .T.       , lRetCarga, lRetCarga, 1) //Monta a estrutura de campos

	Aadd(aRet, aFields)

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomRelNF
Zoom de Relacao de notas fiscais

@author  Marcio Franklin Carvalho de Noronha
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomRelNF()

      Local aRet := {}
      Local aFields := {}

   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL) //Tipo de execução - 1: SQL 2: Array
   Aadd(aRet,"select rnf from vw_not_fisc_compil where tipo_nota in (0,1) and rnf is not null")
   Aadd(aRet," order by rnf ")

              //aFields,  cCampo  , cDesc      , cTipo, nTamanho, nPrecisao, cMascara      , lVisivel, lRetorna
      SAddPField(@aFields , "rnf" , STR0032/*"Rel. NF"*/  , "C"  , 10      , 0        , "@E 99/9999"  , .T.     , .T., .T., 1) //Monta a estrutura de campos

      Aadd(aRet, aFields)

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomNFs
Zoom de Notas Fiscais

@author  Marcio Franklin Carvalho de Noronha
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomNFs()

      Local aRet := {}
      Local aFields := {}

   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL) //Tipo de execução - 1: SQL 2: Array
   Aadd(aRet,"select ano_nota_fiscal, num_nota_fiscal, ser_nota_fiscal, rnf from vw_not_fisc_compil where tipo_nota in (0,1) and rnf is not null")
   Aadd(aRet,"")

              //aFields,  cCampo             , cDesc              , cTipo, nTamanho, nPrecisao, cMascara           , lVisivel, lRetorna
      SAddPField(@aFields , "ano_nota_fiscal"  , STR0033/*"Ano da NF"*/        , "C"  , 10       , 0        , ""                , .T.     , .F., .F., 1) //Monta a estrutura de campos
      SAddPField(@aFields , "num_nota_fiscal"  , STR0034/*"Nº da NF"*/         , "C"  , 20       , 0        , "@E 999999999"    , .T.     , .T., .T., 1) //Monta a estrutura de campos
      SAddPField(@aFields , "ser_nota_fiscal"  , STR0035/*"Série da NF"*/      , "C"  , 10       , 0        , ""                , .T.     , .F., .F., 1) //Monta a estrutura de campos
      SAddPField(@aFields , "rnf"              , STR0032/*"Rel. NF"*/          , "C"  , 20       , 0        , "@E 99/9999"      , .T.     , .F., .F., 1) //Monta a estrutura de campos

      Aadd(aRet, aFields)

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomLote
Zoom de Lote

@param lLote_id True para retornar e False para nao retornar o Lote
@param lDent_id True para retornar e False para nao retornar o Documento de Transporte

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomLote(lLote_id,lDent_id)
	Local aRet := {}
	Local aFields := {}
	Local cQuery := ""
	Default lLote_id := .T.
	Default lDent_id := .F.


	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	cQuery := "select distinct " +;
	           " substring(a.lote_id_rf,1,2)+'/'+"+;
               " substring(a.lote_id_rf,3,6)+'-'+"+;
               " substring(a.lote_id_rf,9,1) as lote_id_rf,"+;	           
	           "a.lote_id, "+;
			   "(substring(a.dent_id,1,4)++'/'++substring(a.dent_id,6,16)) "+;
		       " from tab_lote a "+;
			   "   left outer join rel_dent_doctrans b "+;
			   "   left outer join tab_doc_transporte c "+;
			   "     on b.dtran_id = c.dtran_id "+;
			   "     on a.dent_id  = b.dent_id, "+;
			   "  tab_doc_entrada h , "+;
			   "    rel_lote pai "+;
		       "  where a.lote_cancelado is null "+;
			   "  and a.dent_id = h.dent_id "+;
			   "  and a.lote_id = pai.lote_pai "+;
			   "  and a.lote_dt_conhec > (getdate() - 1780)"

	Aadd(aRet, cQuery)
	Aadd(aRet, '')

              //aFields,    cCampo ,   cDesc , cTipo, nTamanho, nPrecisao, cMascara , lVisivel, lRetorna
	SAddPField(@aFields , "a.lote_id_rf"   , STR0023/*"Lote"*/               , "C"  , 12 , 0 ,"@R 99/999999-9", .T. , lLote_id, .T., 1)
	SAddPField(@aFields , "a.lote_id"      , STR0065/*"Lote sistema"*/      , "C"  , 12 , 0 , "" , .T. , .F., .F., 1)
	SAddPField(@aFields , "a.dtran_nr_doc" , STR0036/*"Doc. de Transporte"*/ , "C"  , 30 , 0 , "" , .T. , lDent_id)

	Aadd(aRet, aFields)

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomNum
Zoom de Documento

@param lDtran_nr_doc True para retornar e False para nao retornar o Numero do Documento
@param lSer True para retornar e False para nao retornar a Serie
@param lLote_id True para retornar e False para nao retornar o Lote
@param lCli_nome True para retornar e False para nao retornar o Cliente
@param lDtran_tp_id True para retornar e False para nao retornar o dtran_tp_id
@param lDtran_tp_ds True para retornar e False para nao retornar o Tipo Documento
@param lTrans_nome True para retornar e False para nao retornar a Transportadora

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomNum(lSer,lDtran_nr_doc,lLote_id,lCli_nome,lDtran_tp_id,lDtran_tp_ds,lTrans_nome)

	Local aRet := {}
	Local aFields := {}
	Local cQuery := ""
	Default lDtran_nr_doc := .T.
	Default lSer          := .F.
	Default lLote_id      := .F.
	Default lCli_nome     := .F.
	Default lDtran_tp_id  := .F.
	Default lDtran_tp_ds  := .F.
	Default lTrans_nome   := .F.


	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	cQuery := "select distinct "+;
			"a.dtran_nr_doc, "+;
			"a.dtran_nr_serie, "+;
			"e.lote_id, "+;
			"f.cli_nome, "+;
			"g.dtran_tp_id, "+;
			"g.dtran_tp_ds, "+;
			"h.trans_nome "+;
		"from tab_doc_transporte a "+;
			"left join rel_dent_doctrans b "+;
			"on b.dtran_id = a.dtran_id "+;
				"left join rel_cesv_dent c "+;
				"on b.dent_id = c.dent_id "+;
					"left join tab_cesv "+;
					"on tab_cesv.cesv_id = c.cesv_id "+;
						"left outer join tab_transportadora h "+;
						"on h.trans_id = tab_cesv.trans_id "+;
							"left join rel_dent_cnt d "+;
							"on c.dent_id = d.dent_id "+;
								"left join tab_lote e "+;
								"on d.lote_id = e.lote_id "+;
									"left join tab_clientes f "+;
									"on e.ben_id = f.cli_id, "+;
										"tab_doc_transporte_tipo g "+;
		"where a.dtran_tp_id = g.dtran_tp_id "

	Aadd(aRet, cQuery)
	Aadd(aRet, '')

              //aFields,    cCampo           , cDesc           , cTipo, nTamanho, nPrecisao, cMascara , lVisivel, lRetorna
		SAddPField(@aFields , "a.dtran_nr_doc"   , STR0037/*"Nr. Documento"*/  , "C"  , 10 , 0 , "" , .T. , lDtran_nr_doc, lDtran_nr_doc, 1)
		SAddPField(@aFields , "a.dtran_nr_serie" , STR0038/*"Série"*/          , "C"  , 10 , 0 , "" , .T. , lSer)
		SAddPField(@aFields , "e.lote_id"        , STR0023/*"Lote"*/           , "C"  , 10 , 0 , "" , .T. , lLote_id, lLote_id, 1)
		SAddPField(@aFields , "f.cli_nome"       , STR0029/*"Cliente"*/        , "C"  , 10 , 0 , "" , .T. , lCli_nome)
		SAddPField(@aFields , "g.dtran_tp_id"    , "dtran_tp_id"               , "C"  , 10 , 0 , "" , .F. , lDtran_tp_id)
		SAddPField(@aFields , "g.dtran_tp_ds"    , STR0039/*"Tipo Doc."*/      , "C"  , 10 , 0 , "" , .T. , lDtran_tp_ds)
		SAddPField(@aFields , "h.trans_nome"     , STR0019/*"Transportadora"*/ , "C"  , 10 , 0 , "" , .T. , lTrans_nome)

		Aadd(aRet, aFields)

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomDEnt
Zoom de Documento de Entrada

@param lDent_id True para retornar e False para nao retornar o Codigo do Documento
@param lDent_numero True para retornar e False para nao retornar o Numeto do Documento
@param lLote_id True para retornar e False para nao retornar o Lote
@param lLote_conhec True para retornar e False para nao retornar o Conhecimento
@param lCli_nome True para retornar e False para nao retornar o Cliente

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomDEnt(lDent_id,lDent_numero,lLote_id,lLote_conhec,lCli_nome)

	Local aRet := {}
	Local aFields := {}
	Local cQuery := ""
	Default lDent_id     := .F.
	Default lDent_numero := .T.
	Default lLote_id     := .F.
	Default lLote_conhec := .F.
	Default lCli_nome    := .F.

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	cQuery := "select distinct a.dent_id, "+;
			"a.dent_numero, "+;
			" substring(c.lote_id_rf,1,2)+'/'+"+;
            " substring(c.lote_id_rf,3,6)+'-'+"+;
            " substring(c.lote_id_rf,9,1) as lote_id_rf,"+;
			"b.lote_id, "+;
			"c.lote_conhec, "+;
			"d.cli_nome "+;
		"from tab_doc_entrada a "+;
			"left outer join tab_clientes d "+;
			"on a.ben_id = d.cli_id, "+;
				"rel_dent_cnt b, "+;
				"tab_lote c "+;
		"where a.dent_id = b.dent_id "+;
			"and c.lote_id = b.lote_id  "+;
			"and c.lote_dt_conhec > (getdate() - 1780)"

	Aadd(aRet, cQuery)
	Aadd(aRet, '')

              //aFields,    cCampo ,   cDesc , cTipo, nTamanho, nPrecisao, cMascara , lVisivel, lRetorna
	SAddPField(@aFields , "a.dent_id"     , "dent_id"                  , "C"  , 20 , 0 , "" , .F. , lDent_id, lDent_id, 1)
	SAddPField(@aFields , "a.dent_numero" , STR0037/*"Nr. Documento"*/ , "C"  , 20 , 0 , "" , .T. , lDent_numero, lDent_numero, 1)
	SAddPField(@aFields , "c.lote_id_rf"  , STR0023/*"Lote"*/          , "C"  , 15 , 0 , "@R 99/999999-9" , .T. , lLote_id, lLote_id, 1)
	SAddPField(@aFields , "b.lote_id"     , STR0065/*"Lote sistema"*/ , "C"  , 15 , 0 , "" , .T. , .F., .F., 1)
	SAddPField(@aFields , "c.lote_conhec" , STR0022/*"Conhecimento"*/  , "C"  , 20 , 0 , "" , .T. , lLote_conhec)
	SAddPField(@aFields , "d.cli_nome"    , STR0029/*"Cliente"*/       , "C"  , 30 , 0 , "" , .T. , lCli_nome)

	Aadd(aRet, aFields)

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomCigCli
Zoom de Cosignatario Cliente

@param lCli_nome True para retornar e False para nao retornar o Cliente
@param lCli_cnpj True para retornar e False para nao retornar o CNPJ/CPF
@param lCli_id True para retornar e False para nao retornar o Codigo

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomCigCli(lCli_id,lCli_nome,lCli_cnpj, lPesqID, lPesqNome, lPesqCNPJ)
	Local aRet := {}
	Local aFields := {}
	Local cQuery := ""
	Default lCli_nome := .T.
	Default lCli_cnpj := .F.
	Default lCli_id   := .F.
	Default lPesqNome := .T.
	Default lPesqCNPJ := .F.
	Default lPesqID   := .F.

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	cQuery := "select cli_nome, "+;
			"(case cli_cgc "+;
				"when null then "+;
					"substring(cli_cpf,1,3)++'.'++substring(cli_cpf,4,3)++'.'++substring(cli_cpf,7,3)++'-'++substring(cli_cpf,10,2) "+;
				"else "+;
					"case len(cli_cgc) "+;
						"when 14 then "+;
							"substring(cli_cgc,1,2)++'.'++substring(cli_cgc,3,3)++'.'++substring(cli_cgc,4,3)++'/'++substring(cli_cgc,9,4)++'-'++substring(cli_cgc,13,3) "+;
						"else cli_cgc "+;
					"end "+;
			"end) as cli_cnpj, "+;
			"cli_id "+;
		"from tab_clientes "+;
		"where 1= 1 "

	Aadd(aRet, cQuery)
	Aadd(aRet, " ORDER BY tab_clientes.cli_nome")

       			//aFields,    cCampo ,   cDesc , cTipo, nTamanho, nPrecisao, cMascara , lVisivel, lRetorna
	SAddPField(@aFields , "cli_nome" , STR0029/*"Cliente"*/  , "C"  , 50 , 0 , "" , .T. , lCli_nome, lPesqNome, 1)
	SAddPField(@aFields , "cli_cnpj" , STR0026/*"CNPJ/CPF"*/ , "C"  , 20 , 0 , "" , .T. , lCli_cnpj, lPesqCNPJ, 1)
	SAddPField(@aFields , "cli_id"   , STR0002/*"Código"*/   , "C"  , 10 , 0 , "" , .T. , lCli_id, lPesqID, 1)

	Aadd(aRet, aFields)

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomVei2
Zoom de Veiculo

@param lVei_id True para retornar e False para nao retornar a Placa do veiculo
@param lLote_master True para retornar e False para nao retornar o Lote master
@param lLote_filho True para retornar e False para nao retornar o Lote filho

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomVei2(lVei_id,lLote_master,lLote_filho)

	Local aRet := {}
	Local aFields := {}
	Local cQuery := ""
	Default lVei_id      := .T.
	Default lLote_master := .F.
	Default lLote_filho  := .F.

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	cQuery := "select distinct a.vei_id, "+;
  	                " substring(g.lote_id_rf,1,2)+'/'+"+;
                    " substring(g.lote_id_rf,3,6)+'-'+"+;
                    " substring(g.lote_id_rf,9,1) as lote_rf_master,"+;	
					"d.lote_id lote_master, "+;
					" substring(f.lote_id_rf,1,2)+'/'+"+;
                    " substring(f.lote_id_rf,3,6)+'-'+"+;
                    " substring(f.lote_id_rf,9,1) as lote_id_rf_filho,"+;	
					"f.lote_id lote_filho "+;
				"from tab_veiculos a, "+;
					"tab_cesv b, "+;
					"rel_cesv_dent c, "+;
					"rel_dent_cnt d, "+;
					"rel_lote e, "+;
					"tab_lote f, "+;
					"tab_lote g "+;
				"where a.vei_id = b.vei_id "+;
					"and b.cesv_id = c.cesv_id "+;
					"and c.dent_id = d.dent_id "+;
					"and d.lote_id = e.lote_pai "+;
					"and e.lote_filho = f.lote_id "+;
					"and e.lote_pai = g.lote_id "

	Aadd(aRet, cQuery)
	Aadd(aRet, '')

       		//aFields,    cCampo ,   cDesc , cTipo, nTamanho, nPrecisao, cMascara , lVisivel, lRetorna
	SAddPField(@aFields , "a.vei_id"    , STR0046/*"Placa Veículo"*/ , "C"  , 10 , 0 , "" , .T. , lVei_id, lVei_id, 1)
	SAddPField(@aFields , "g.lote_id_rf", STR0040/*"Lote Master"*/   , "C"  , 15 , 0 , "@R 99/999999-9" , .T. , lLote_master)
	SAddPField(@aFields , "d.lote_id"   , STR0066/*"Lote Master sistema"*/   , "C"  , 15 , 0 , "" , .T. , lLote_master)
	SAddPField(@aFields , "f.lote_id_rf", STR0041/*"Lote Filho"*/    , "C"  , 15 , 0 , "@R 99/999999-9" , .T. , lLote_filho)
	SAddPField(@aFields , "f.lote_id", STR0067/*"Lote Filho sistema"*/    , "C"  , 15 , 0 , "" , .T. , lLote_filho)

	Aadd(aRet, aFields)

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomCNTR
Zoom de Container

@param lCnt_id True para retornar e False para nao retornar o Codigo
@param lCnt_tipo True para retornar e False para nao retornar o Tipo

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
function SZoomCNTR(lCnt_id,lCnt_tipo)
	Local aRet := {}
	Local aFields := {}
	Local cQuery := ""
	Default lCnt_id := .T.
	Default lCnt_tipo := .F.

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	cQuery := "select distinct a.cnt_id, "+;
					"a.cnt_tipo "+;
				"from tab_container a, "+;
					"tab_mov_cnt b, "+;
					"rel_dent_cnt c, "+;
					"rel_lote d "+;
				"where a.cnt_id = b.cnt_id "+;
					"and b.mcnt_id = c.mcnt_id "+;
					"and c.lote_id = d.lote_pai "

	Aadd(aRet, cQuery)
	Aadd(aRet, '')

   				//aFields,    cCampo ,   cDesc , cTipo, nTamanho, nPrecisao, cMascara , lVisivel, lRetorna
	SAddPField(@aFields , "a.cnt_id"   , STR0002/*"Código"*/   , "C"  , 12 , 0 , "" , .T. , lCnt_id, lCnt_id, 1)
	SAddPField(@aFields , "a.cnt_tipo" , STR0014/*"Tipo"*/     , "C"  , 10 , 0 , "" , .T. , lCnt_tipo)

	Aadd(aRet, aFields)

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SZConhecDesUnit
Zoom de Conhecimento Unitario

@param lRetConhec True para retornar e False para nao retornar o Conhecimento
@param lRetLote True para retornar e False para nao retornar o Lote
@param lRetNome True para retornar e False para nao retornar a Descricao

@author  Marcio Franklin Carvalho de Noronha
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZConhecDesUnit(lRetConhec, lRetLote, lRetNome)

	Local aRet := {}
	Local aFields := {}

	Default lRetConhec := .F.
	Default lRetLote   := .F.
	Default lRetNome   := .F.

   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL) //Tipo de execução - 1: SQL 2: Array
   Aadd(aRet,"select distinct                                         "+;
			 "      a.lote_conhec,                                    "+;
			 "substring(a.lote_id_rf,1,2)+'/'+                        "+;
			 "              substring(a.lote_id_rf,3,6)+'-'+          "+;
			 "              substring(a.lote_id_rf,9,1) as lote_id_rf,"+;
			 "      a.lote_id,                                        "+;
			 "      b.cli_nome                                        "+; 
			 "from  tab_lote a,                                       "+;
			 "      tab_clientes b                                    "+;
			 " where  a.ben_id = b.cli_id                             "+; 
			 " and  a.lote_cancelado is null                          "+;
			 " and  a.lote_dt_conhec > (getdate() - 1780 )             ")
   Aadd(aRet,"")

              //aFields,  cCampo             , cDesc                       , cTipo, nTamanho, nPrecisao, cMascara           , lVisivel, lRetorna
	SAddPField(@aFields , "a.lote_conhec"    , STR0022/*"Conhecimento"*/   , "C"  , 30       , 0          , ""                   , .T.      , lRetConhec, lRetConhec, 1) //Monta a estrutura de campos
	SAddPField(@aFields , "a.lote_id_rf"     , STR0023/*"Lote"*/            , "C"  , 15       , 0          , "@R 99/999999-9"       , .T.      , lRetLote  , lRetLote  , 1) //Monta a estrutura de campos
	SAddPField(@aFields , "a.lote_id"        , STR0065/*"Lote sistema"*/   , "C"  , 15       , 0          , "@E 999999999999"  , .T.      , .F.        , .F.       , 2) //Monta a estrutura de campos
	SAddPField(@aFields , "b.cli_nome"       , STR0042/*"Descrição"*/       , "C"  , 50       , 0          , ""                   , .T.      , lRetNome  , lRetNome  , 1) //Monta a estrutura de campos
	


	Aadd(aRet, aFields)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ZConhecD2
Zoom de Conhecimento Unitario

@param lRetConhec True para retornar e False para nao retornar o Conhecimento
@param lRetLote True para retornar e False para nao retornar o Lote
@param lRetNome True para retornar e False para nao retornar a Descricao
@param lRetOpcao 1 = Doc. Intenacional / 2 = Doc. Nacional

@author  Ruan Ricardo Salvador
@since   23/08/2016
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function ZConhecD2(lRetConhec, lRetLote, lRetNome, lRetOpcao)

	Local aRet := {}
	Local aFields := {}
	
	local CompSql := ''

	Default lRetConhec := .F.
	Default lRetLote   := .F.
	Default lRetNome   := .F.
	
   if lRetOpcao  
      Compsql += " and z.conhec_nome not in ('NF', 'RNF') "
   else
      Compsql += " and z.conhec_nome in ('NF', 'RNF') "
   endif

   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL) //Tipo de execução - 1: SQL 2: Array
   Aadd(aRet,"select distinct "+;
             "       a.lote_conhec,  "+;             
             " substring(a.lote_id_rf,1,2)+'/'+"+;
             "               substring(a.lote_id_rf,3,6)+'-'+"+;
             "               substring(a.lote_id_rf,9,1) as lote_id_rf,"+;
             "       a.lote_id,  "+;
             "       b.cli_nome  "+;
             " from  tab_lote a  "+;
             "       left outer join tab_tipo_conhecimento z "+;                             
             "       on a.conhec_id = z.conhec_id, "+;
             "       tab_clientes b,  "+;
             "       rel_dent_cnt c,  "+;
             "       tab_mov_cnt d,  "+;
             "       vw_opr_GCI_LoteAtual e,  "+;
             "       tab_especie f,  "+;
             "       tab_armazem g,  "+;
             "       tab_celulas h,  "+;
             "       tab_container i,  "+;
             "       tab_tipo_iso j  "+;
             "where  a.ben_id = b.cli_id  "+;
             "  and  a.lote_id = c.lote_id  "+;
             "  and  d.mcnt_id = c.mcnt_id  "+;
             "  and  d.mcnt_dt_desova is null "+;
             "  and  d.mcnt_status = 1 "+;
             "  and  a.lote_cancelado is null "+;
             "  and  d.cnt_id = e.cnt_id  "+;
             "  and  e.esp_id = e.esp_id  "+;
             "  and  g.arm_id = d.arm_id  "+;
             "  and  g.arm_id = h.arm_id  "+;
             "  and  d.cel_id = h.cel_id  "+;
             "  and  i.cnt_id = e.cnt_id  "+;
             "  and  j.tiso_id = i.tiso_id" + compSql)
   Aadd(aRet,"")

              //aFields,  cCampo             , cDesc                       , cTipo, nTamanho, nPrecisao, cMascara           , lVisivel, lRetorna
	SAddPField(@aFields , "a.lote_conhec"    , STR0022/*"Conhecimento"*/   , "C"  , 30       , 0          , ""                   , .T.      , lRetConhec, lRetConhec, 1) //Monta a estrutura de campos
	SAddPField(@aFields , "a.lote_id_rf"     , STR0023/*"Lote"*/            , "C"  , 15       , 0          , "@R 99/999999-9"       , .T.      , lRetLote  , lRetLote  , 1) //Monta a estrutura de campos
	SAddPField(@aFields , "a.lote_id"        , STR0065/*"Lote sistema"*/   , "C"  , 15       , 0          , "@E 999999999999"  , .T.      , .F.        , .F.       , 2) //Monta a estrutura de campos
	SAddPField(@aFields , "b.cli_nome"       , STR0042/*"Descrição"*/       , "C"  , 50       , 0          , ""                   , .T.      , lRetNome  , lRetNome  , 1) //Monta a estrutura de campos
	


	Aadd(aRet, aFields)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomCont
Zoom de Container

@author  Marcio Franklin Carvalho de Noronha
@since   02/07/2012
@version P12
@protected
/*/ 	
//-------------------------------------------------------------------
Function SZoomCont()
	Local aRet := {}
	Local aFields := {}

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL) //Tipo de execução - 1: SQL 2: Array
	Aadd(aRet, 	' select                        '+;
				' distinct                      '+;
				'    i.cnt_id,                  '+;
				'    i.cnt_tipo,                '+; 
				'    j.tiso_descricao           '+;  
				' from                          '+; 
				'   tab_lote a,                 '+; 
				'   tab_clientes b,             '+;
				'   vw_opr_GCI_LoteAtual e,     '+;
				'   tab_container i,            '+;
				'  tab_tipo_iso j               '+;
				' where                         '+;
				'   a.ben_id = b.cli_id         '+;
				'   and a.lote_cancelado is null'+;  
				'   and i.cnt_id = e.cnt_id     '+; 
				'   and j.tiso_id = i.tiso_id   ')
				
	Aadd(aRet,"")

              //aFields,  cCampo             , cDesc              , cTipo, nTamanho, nPrecisao, cMascara           , lVisivel, lRetorna
	SAddPField(@aFields , "i.cnt_id"           , STR0043/*"Cód. Container"*/   , "C"  , 15       , 0        , ""                , .T.     , .T., .T., 1) //Monta a estrutura de campos
	SAddPField(@aFields , "i.cnt_tipo"         , STR0014/*"Tipo"*/             , "C"  , 15       , 0        , "@E 999999999"    , .T.     , .F., .F., 1) //Monta a estrutura de campos
	SAddPField(@aFields , "j.tiso_descricao"   , STR0042/*"Descrição"*/        , "C"  , 50       , 0        , ""                , .T.     , .F., .F., 1) //Monta a estrutura de campos

	Aadd(aRet, aFields)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomSQL
Zoom de SQLs cadastrados via protheus

@param lRetCod True para retornar e False para nao retornar o Codigo
@param lRetDesc True para retornar e False para nao retornar a Descrição
@param lRetSql True para retornar e False para nao retornar o SQL

@author  Felipe Machado de Oliveira
@since   06/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomSQL(lRetCod,lRetDesc,lRetSql)

	Local aRet       := {}
	Local aFields    := {}
	Local cSql       := ""
	Default lRetCod  := .F.
	Default lRetDesc := .F.
	Default lRetSql  := .F.

	cSql := "select dbs_cod,dbs_desc,dbs_sql from "+RETSQLNAME("DBS") +;
				" where dbs_filial = '"+xFilial("DBS")+"'"


	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)  //Tipo de execução - 1: SQL 2: Array
	Aadd(aRet,cSql)

	          //aFields , cCampo     , cDesc    , cTipo , nTamanho , nPrecisao , cMascara , lVisivel , lRetorna
	SAddPField(@aFields , "dbs_cod"  , STR0002/*"Código"*/    , "C"   , 15       , 0         , ""       , .T.      , lRetCod)
	SAddPField(@aFields , "dbs_desc" , STR0042/*"Descrição"*/ , "C"   , 15       , 0         , ""       , .T.      , lRetDesc)
	SAddPField(@aFields , "dbs_sql"  , STR0044/*"SQL"*/       , "C"   , 200      , 0         , ""       , .F.      , lRetSql)

	Aadd(aRet, aFields)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomArm
Zoom dos Armazéns

@author  Marcio Franklin Carvalho de Noronha
@since   24/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomArm()

	Local aRet := {}
	Local aFields := {}

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	Aadd(aRet, "select arm_id, arm_descricao from tab_armazem where arm_id <> '99999'")
	Aadd(aRet, "")

              //aFields,   cCampo           ,  cDesc           , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
	SAddPField(@aFields , "arm_id"           , STR0002/*"Código"*/          , "C"  , 5       , 0        , ""      , .F.     , .T.)
	SAddPField(@aFields , "arm_descricao"    , STR0019/*"Transportadora"*/  , "C"  , 30      , 0        , ""      , .T.     , .T., .T., 1)

	Aadd(aRet, aFields)

return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomTb
Zoom das tabelas

@author  Aline Briesemeister Xavier
@since   24/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomTb()

	Local aRet := {}
	Local aFields := {}
	Local aDataFields := {}
	Local aData := {}
	Local nIndice := 16
	Local nX      := 1
	Local nY      := 1
	Local nZ      := 1
	Local nNomeTabela := ''
	
	Local aChavesTabela := A927KEYTabela()
	Local aChaves := {}

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_ARRAY) //Tipo de execução - 1: SQL 2: Array

	//Tab_acesso
	Aadd(aDataFields, "ace_id")
	Aadd(aDataFields, "tab_acesso")
	Aadd(aDataFields, STR0047)/*"I  - Entrada ou saída de pessoa, veículo ou carga"*/
	Aadd(aDataFields, "1")
	Aadd(aData, aDataFields)

	//Tab_os
	aDataFields := {}
	Aadd(aDataFields, "os_id")
	Aadd(aDataFields, "tab_os")
	Aadd(aDataFields, STR0048)/*"IX - Ordem ou relatório de serviço"*/
	Aadd(aDataFields, "2")
	Aadd(aData, aDataFields)

	//Tab_Usuarios
	aDataFields := {}
	Aadd(aDataFields, "usu_sequencial")
	Aadd(aDataFields, "tab_usuarios")
	Aadd(aDataFields, STR0049)/*"XII- Habilitação de desabilitação de usuários"*/
	Aadd(aDataFields, "3")
	Aadd(aData, aDataFields)

	//Rel_Lote
	aDataFields := {}
	Aadd(aDataFields, "lote_sequencial")
	Aadd(aDataFields, "rel_lote")
	Aadd(aDataFields, STR0050)/*"II - Consolidação ou Desconsolidação de lote de carga"*/
	Aadd(aDataFields, "4")
	Aadd(aData, aDataFields)

	//Tab_Apreensao
	aDataFields := {}
	Aadd(aDataFields, "apr_sequencial")
	Aadd(aDataFields, "tab_apreensao")
	Aadd(aDataFields, STR0051)/*"VI - Apreensão ou devolução de mercadoria para fiscalização"*/
	Aadd(aDataFields, "5")
	Aadd(aData, aDataFields)

	//Tab_Cesv
	aDataFields := {}
	Aadd(aDataFields, "cesv_sequencial")
	Aadd(aDataFields, "tab_cesv")
	Aadd(aDataFields, STR0047)/*"I  - Entrada ou saída de pessoa, veículo ou carga"*/
	Aadd(aDataFields, "6")
	Aadd(aData, aDataFields)

	//Tab_Lote
	aDataFields := {}
	Aadd(aDataFields, "lote_sequencial")
	Aadd(aDataFields, "tab_lote")
	Aadd(aDataFields, STR0047)/*"I  - Entrada ou saída de pessoa, veículo ou carga"*/
	Aadd(aDataFields, "7")
	Aadd(aData, aDataFields)

	//Tab_Lacres
	aDataFields := {}
	Aadd(aDataFields, "lac_id")
	Aadd(aDataFields, "tab_lacres")
	Aadd(aDataFields, STR0047)/*"I  - Entrada ou saída de pessoa, veículo ou carga"*/
	Aadd(aDataFields, "8")
	Aadd(aData, aDataFields)

	//Tab_Doc_Entrada
	aDataFields := {}
	Aadd(aDataFields, "dent_sequencial")
	Aadd(aDataFields, "tab_doc_entrada")
	Aadd(aDataFields, STR0047)/*"I  - Entrada ou saída de pessoa, veículo ou carga"*/
	Aadd(aDataFields, "9")
	Aadd(aData, aDataFields)

	//Tab_Registro_Manifesto
	aDataFields := {}
	Aadd(aDataFields, "rgmf_id")
	Aadd(aDataFields, "tab_registro_manifesto")
	Aadd(aDataFields, STR0050)/*"II - Consolidação ou Desconsolidação de lote de carga"*/
	Aadd(aDataFields, "10")
	Aadd(aData, aDataFields)

	//Tab_hist_Benef_Lote
	aDataFields := {}
	Aadd(aDataFields, "hist_id")
	Aadd(aDataFields, "tab_hist_benef_lote")
	Aadd(aDataFields, STR0052)/*"IV - Transferência de propriedade de mercadoria"*/
	Aadd(aDataFields, "11")
	Aadd(aData, aDataFields)

	//Tab_Os_Item
	aDataFields := {}
	Aadd(aDataFields, "oitem_sequencial")
	Aadd(aDataFields, "tab_os_item")
	Aadd(aDataFields, STR0048)/*"IX - Ordem ou relatório de serviço"*/
	Aadd(aDataFields, "12")
	Aadd(aData, aDataFields)

	//Tab_Doc_Saida
	aDataFields := {}
	Aadd(aDataFields, "dsai_sequencial")
	Aadd(aDataFields, "tab_doc_saida")
	Aadd(aDataFields, STR0047)/*"I  - Entrada ou saída de pessoa, veículo ou carga"*/
	Aadd(aDataFields, "13")
	Aadd(aData, aDataFields)

	//Tab_Lote_Ova_cnt
	aDataFields := {}
	Aadd(aDataFields, "tloc_id")
	Aadd(aDataFields, "tab_lote_ova_cnt")
	Aadd(aDataFields, STR0053)/*"III- Unitização ou Desunitização de unidade de carga"*/
	Aadd(aDataFields, "14")
	Aadd(aData, aDataFields)

	//Tab_Consolidacao
	aDataFields := {}
	Aadd(aDataFields, "tc_id")
	Aadd(aDataFields, "tab_consolidacao")
	Aadd(aDataFields, STR0050)/*"II - Consolidação ou Desconsolidação de lote de carga"*/
	Aadd(aDataFields, "15")
	Aadd(aData, aDataFields)

	//Rel_Lote_Consolidacao
	aDataFields := {}
	Aadd(aDataFields, "rel_lote_sequencial")
	Aadd(aDataFields, "rel_lote_consolidacao")
	Aadd(aDataFields, STR0050)/*"II - Consolidação ou Desconsolidação de lote de carga"*/
	Aadd(aDataFields, "16")
	Aadd(aData, aDataFields)
	
	//Monta os campos da tabela 
	//Calcula as chaves e os indices para as tabelas de cadastros
	For nX := 1 To Len(aChavesTabela)
	   nNomeTabela := AllTrim(aChavesTabela[nX][1])
	   cChave      := AllTrim(aChavesTabela[nX][2])

	   aDataFields := {}
	   
	   Aadd(aDataFields, cChave)
	   Aadd(aDataFields, AllTrim(nNomeTabela))
	   Aadd(aDataFields, "Cadastros do sistema")
	   Aadd(aDataFields, cValTochar(nIndice))
	   Aadd(aData, aDataFields)
	   
	   nIndice := nIndice + 1
	   
	Next
	
	Aadd(aRet, aData) //Instrucao ou Array com os dados
	Aadd(aRet, nil)

	//Monta a estrutura de campos
	SAddPField(@aFields, "chave"    , STR0054/*"Chave"*/    , "C", 30,  0, "", .F., .T.)
	SAddPField(@aFields, "tabela"   , STR0055/*"Tabela"*/   , "C", 50,  0, "", .T., .T.)
	SAddPField(@aFields, "descricao", STR0042/*"Descrição"*/, "C", 100, 0, "", .T., .F.)
	SAddPField(@aFields, "indice"    ,STR0056/*"Indice"*/   , "C", 3 ,  0, "", .F., .T.)

	Aadd(aRet, aFields)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomCDA
Zoom de CDA

@author  Marcio Franklin Carvalho de Noronha
@since   30/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomCDA()
	Local aRet := {}
	Local aFields := {}

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL) //Tipo de execução - 1: SQL 2: Array
	Aadd(aRet,"select substring(dsai_id,7,9) as dsai_id_num, "+;
			   " dsai_id, "+;
			   " (convert(varchar(20),dsai_dt_registro,103) ++ ' ' ++ convert(varchar(20),dsai_dt_registro,108)) dsai_dt_registro, "+;
			   " (convert(varchar(20),dsai_dt_vencto,103) ++ ' ' ++ convert(varchar(20),dsai_dt_vencto,108)) dsai_dt_vencto "+;
			   " from tab_doc_saida "+;
				" where substring(dsai_id,5,2) = '91' ")
	Aadd(aRet," order by dsai_id_num")

              //aFields,  cCampo                  , cDesc                        , cTipo, nTamanho , nPrecisao, cMascara          , lVisivel, lRetorna , Def., TpPesq -> 1 Cont, 2 =, 3 >=, 4 <=, 5 Ini, 6 Fim
	SAddPField(@aFields , "substring(dsai_id,7,9)", STR0057/*"Nº CDA"*/           , "C"  , 09       , 0        , ""                , .T.     , .T.      , .T. , 1) //Monta a estrutura de campos
	SAddPField(@aFields , "dsai_id"               , STR0002/*"Código"*/           , "C"  , 30       , 0        , ""                , .T.     , .T.               ) //Monta a estrutura de campos
	SAddPField(@aFields , "dsai_dt_registro"      , STR0058/*"Data registro"*/    , "C"  , 30       , 0        , ""                , .T.     , .F.               ) //Monta a estrutura de campos
	SAddPField(@aFields , "dsai_dt_vencto"        , STR0059/*"Data vencimento"*/  , "C"  , 30       , 0        , ""                , .T.     , .F.               ) //Monta a estrutura de campos

	Aadd(aRet, aFields)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomCli
Zoom de Clientes

@author  Marcio Franklin Carvalho de Noronha
@since   30/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomCli(lRetCod, lRetNome, lPesqCod, lPesqNome)
	Local aRet := {}
	Local aFields := {}
	Default lRetCod := .T.
	Default lRetNome := .F.
	Default lPesqCod := .T.
	Default lPesqNome := .F.

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL) //Tipo de execução - 1: SQL 2: Array
	Aadd(aRet,"select cli_id, cli_cgc, cli_nome from tab_clientes where cli_id is not null")
	Aadd(aRet,"")

              //aFields,  cCampo             , cDesc              , cTipo, nTamanho, nPrecisao, cMascara           , lVisivel, lRetorna
	SAddPField(@aFields , "cli_id"           , STR0002/*"Código"*/           , "C"  , 06       , 0        , ""                , .T.     , lRetCod, lPesqCod, 1) //Monta a estrutura de campos
	SAddPField(@aFields , "cli_cgc"          , STR0026/*"CNPJ/CPF"*/         , "C"  , 14       , 0        , ""                , .T.     , .F., .F., 1) //Monta a estrutura de campos
	SAddPField(@aFields , "cli_nome"         , STR0003/*"Nome"*/             , "C"  , 50       , 0        , ""                , .T.     , lRetNome, lPesqNome, 1) //Monta a estrutura de campos

	Aadd(aRet, aFields)

Return aRet

Function SZoomTable()
	Local aRet := {}
	Local aFields := {}
	Local aDataFields := {}
	Local aData := {}

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_ARRAY) //Tipo de execução - 1: SQL 2: Array

	Aadd(aDataFields, "0")
	Aadd(aDataFields, "tab_cesv")
	Aadd(aData, aDataFields)

	aDataFields := {}
	Aadd(aDataFields, "1")
	Aadd(aDataFields, "tab_lote")
	Aadd(aData, aDataFields)

	aDataFields := {}
	Aadd(aDataFields, "2")
	Aadd(aDataFields, "tab_lote_item")
	Aadd(aData, aDataFields)

	aDataFields := {}
	Aadd(aDataFields, "3")
	Aadd(aDataFields, "tab_usuarios")
	Aadd(aData, aDataFields)

    aDataFields := {}
    Aadd(aDataFields, "4")
    Aadd(aDataFields, "tab_balanca")
    Aadd(aData, aDataFields)
    
    aDataFields := {}
    Aadd(aDataFields, "5")
    Aadd(aDataFields, "tab_di_item")
    Aadd(aData, aDataFields)   

	Aadd(aRet, aData) //Instrucao ou Array com os dados
	Aadd(aRet, nil)

	SAddPField(@aFields, "codigo"   , STR0002/*"Código"*/ , "N",  7, 0, "", .F., .F.)
	SAddPField(@aFields, "descricao", STR0055/*"Tabela"*/ , "C", 20, 0, "", .T., .T.)

	Aadd(aRet, aFields)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomTpBen
Zoom de usuários

@author  Marcio Franklin C. de Noronha
@since   14/08/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomTpBen()
	Local aRet := {}
	Local aFields := {}
	Local aDataFields := {}
	Local aData := {}

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_ARRAY) //Tipo de execução - 1: SQL 2: Array

	Aadd(aDataFields, "0")
	Aadd(aDataFields, "Comprador")
	Aadd(aData, aDataFields)

	aDataFields := {}
	Aadd(aDataFields, "1")
	Aadd(aDataFields, "Vendedor")
	Aadd(aData, aDataFields)

	aDataFields := {}
	Aadd(aDataFields, "2")
	Aadd(aDataFields, "Mandatário")
	Aadd(aData, aDataFields)

	Aadd(aRet, aData) //Instrucao ou Array com os dados
	Aadd(aRet, nil)

	SAddPField(@aFields, "Código"   , STR0002/*"Código"*/    , "N",  7, 0, "", .T., .T.)
	SAddPField(@aFields, "Descricao", STR0042/*"Descrição"*/ , "C", 20, 0, "", .T., .F.)

	Aadd(aRet, aFields)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SVALFILTRO
Validacao de Filtro que retorna quais as opcoes de filtro foram marcadas

@param oFilter Objeto que contem os filtros

@author  Joao Victor Fidelix
@since   30/04/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SVALFILTRO(oFilter)

	local nI := 0
	Local nMax := 0
	local nHasFilter := 0

	if (oFilter == nil)
		return .F.
	endif

	if (ValType(oFilter) == "C")
		return .T.
	endif

	//Propriedade que retorna quais as opções de filtro foram marcadas
	nMax := len(oFilter:aCheckFil)

	for nI := 1 to nMax
		if (oFilter:aCheckFil[nI])
			nHasFilter += 1
		endif
	next

return if(nHasFilter > 1,.F.,if(nHasFilter == 0,.F.,.T.))

//-------------------------------------------------------------------
/*/{Protheus.doc} SCHKFILTRO
Retorna a opção de filtro selecionada pelo usuário

@param oFilter Objeto que contem os filtros

@author  Joao Victor Fidelix
@since   25/10/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SCHKFILTRO(oFilter)
	local nI := 0
	Local nMax := 0
	local nHasFilter := -1

	if (oFilter == nil)
		return nHasFilter
	endif

	if (ValType(oFilter) == "C")
		return nHasFilter
	endif

	//Propriedade que retorna quais as opções de filtro foram marcadas
	nMax := len(oFilter:aCheckFil)

	for nI := 1 to nMax
		if (oFilter:aCheckFil[nI])
			nHasFilter := nI
		endif
	next

return nHasFilter

//-------------------------------------------------------------------
/*/{Protheus.doc} SValConsig
Validacao de Cosignatario

@param xConteud Codigo do cosignatario a ser verificado

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SValConsig(xConteud, nTipo)
	Local cAlias := ''
	Local cQuery := ''
	Local lRet := .T.
	DEFAULT nTipo := 0

	if !SEmpty(xConteud)
		cAlias := SGetNAlias()

		if nTipo == 0
			cQuery := "select distinct cli_id	from tab_clientes where cli_id = '" +STrim(STransType(xConteud))+ "'"
		elseif nTipo == 1
			cQuery := "select distinct cli_id	from tab_clientes where cli_nome = '" +STrim(STransType(xConteud))+ "'"
		endif

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		lRet := (cAlias)->(!EoF())

		(cAlias)->(dbCloseArea())
	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SValDocEnt
Validação do documento de entrada

@param dent_id String

@author  João Victor
@since   13/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SValDocEnt(xConteud)
	Local cAlias := ''
	Local cQuery := ''
	Local lRet := .T.

	if !SEmpty(xConteud)
		cAlias := SGetNAlias()

		cQuery := "select rel_dent_cnt.dent_id from rel_dent_cnt, tab_lote, tab_clientes where rel_dent_cnt.lote_id = tab_lote.lote_id and tab_clientes.cli_id = tab_lote.ben_id and rel_dent_cnt.dent_id = '"+STrim(STransType(xConteud))+"'"

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		lRet := (cAlias)->(!EoF())

		(cAlias)->(dbCloseArea())
	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SValConsig
Validacao de Regime

@param xConteud Codigo do regime a ser verificado

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SValReg(xConteud)

	Local cAlias := ''
	Local cQuery := ''
	Local lRet   := .T.

	if !SEmpty(xConteud)
		cAlias := SGetNAlias()

		cQuery := "select distinct reg_id from tab_regimes "+;
				   " where reg_alfandegado = '1' and reg_id = " +STrim(STransType(xConteud))+ ""

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		lRet := (cAlias)->(!EoF())

		(cAlias)->(dbCloseArea())

	endif

return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SValTrans
Validacao da transportadora

@param nCodTrans Codigo da transportadora a ser verificada

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SValTrans(nCodTrans)

	Local cAlias := ''
	Local cQuery := ''
	Local lRet   := .T.

	if !SEmpty(nCodTrans)
		cAlias := SGetNAlias()

			cQuery := "select distinct trans_id from tab_transportadora "+;
			          " where trans_id = '" +STransType(nCodTrans)+ "'"

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		lRet := (cAlias)->(!EoF())

		(cAlias)->(dbCloseArea())
	endif

return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SValPlaca
Validacao da placa

@param xConteud Codigo da placa a ser verificada

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SValPlaca(xConteud)

	Local cAlias := ''
	Local cQuery := ''
	Local lRet   := .T.

	if !SEmpty(xConteud)
		cAlias := SGetNAlias()

			cQuery := "select vei_id from tab_veiculos where vei_id = '" +STransType(xConteud)+ "'"

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		lRet := (cAlias)->(!EoF())

		(cAlias)->(dbCloseArea())
	endif

return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SValPais
Validacao do pais

@param nCodPais Codigo do pais a ser verificado

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SValPais(nCodPais)

	Local cAlias := ''
	Local cQuery := ''
	Local lRet

	cAlias := SGetNAlias()

		cQuery := "select pais_id from tab_pais where pais_id = '" +STransType(nCodPais)+ "'"

	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

	lRet := (cAlias)->(!EoF())

	(cAlias)->(dbCloseArea())

return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SValTpDoc
Validacao do tipo de documento

@param oTpDoc Tipo do documento a ser verificado

@author  Joao Victor Fidelix
@since   30/04/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SValTpDoc(oTpDoc)

	Local aInfos := SZoomTpDoc(.T., .T.)
	Local aPos := 1

	if !Empty(oTpDoc)
		aPos := Ascan(aInfos[INFO_ZOOM_OBJETO], {|x,y| (x[1] == oTpDoc) })
	endif
return (aPos > 0)
//-------------------------------------------------------------------
/*/{Protheus.doc} SValLote
Validacao do Lote

@param nCod Codigo do lote a ser verificado
@param nOpcao Opcao de select para a validacao

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SValLote(nCod, nOpcao)

   Local cAlias := ''
   Local cQuery := ''
   Local lRet   := .T.

   if !SEmpty(nCod)
      cAlias := SGetNAlias()

      do case
         case nOpcao == 1
            cQuery := "select distinct lote_conhec from tab_lote where lote_conhec = '"

         case nOpcao == 2
            cQuery := "select distinct lote_id from tab_lote where lote_id = '"

         case nOpcao == 3
         	  cQuery := "select distinct "+;
							"b.lote_id "+;
						"from tab_doc_entrada a "+;
							"left outer join tab_clientes d "+;
							"on a.ben_id = d.cli_id, "+;
								"rel_dent_cnt b, "+;
								"tab_lote c "+;
						"where a.dent_id = b.dent_id "+;
							"and c.lote_id = b.lote_id "+;
							"and b.lote_id = '"

		  case nOpcao == 4
		     cQuery := "select distinct a.lote_id "+;
							"from tab_lote a "+;
								"left outer join rel_dent_doctrans b "+;
									"left outer join tab_doc_transporte c "+;
									"on b.dtran_id = c.dtran_id "+;
									"on a.dent_id  = b.dent_id, "+;
										"tab_doc_entrada h , "+;
										"rel_lote pai "+;
							"where a.lote_cancelado is null "+;
								"and a.dent_id = h.dent_id "+;
								"and a.lote_id = pai.lote_pai "+;
								"and a.lote_id = '"

         otherwise
            return .F.

      endcase

      cQuery += STrim(STransType(nCod))+"'"

      dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

      lRet := (cAlias)->(!EOF())

      (cAlias)->(dbCloseArea())
   endif

return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SValContai
Validacao do Container

@param nCod Codigo do container a ser verificado

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
function SValContai(nCod)

   Local cAlias := ''
   Local cQuery := ''
   Local lRet   := .T.

   if !SEmpty(nCod)
      cAlias := SGetNAlias()

      cQuery := "select distinct cnt_id from tab_container where cnt_id = '" + STransType(nCod) + "'"

      dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

      lRet := (cAlias)->(!EoF())

      (cAlias)->(dbCloseArea())
   endif

return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SValPess
Validacao de pessoa

@param nCodPes Codigo da pessoa a ser verificado

@author  Joao Victor Fidelix
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SValPess(nCodPes)

	Local cAlias := ''
	Local cQuery := ''
	Local lRet   := .T.

	if !SEmpty(nCodPes)
		cAlias := SGetNAlias()

		if (!SEmpty(nCodPes))
			cQuery := 'select distinct pes_id from tab_pessoas where pes_id = '+STransType(nCodPes)
		endif

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		lRet := (cAlias)->(!EOF())

		(cAlias)->(dbCloseArea())
	endif

return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SValConhec
Validacao de Conhecimento

@param nCodConhec Codigo do conhecimento a ser verificado

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SValConhec(nCodConhec, cOpcao)

	Local cAlias := ''
	Local cQuery := ''
	Local lRet   := .T.
	Default cOpcao := '1'

	if !SEmpty(nCodConhec)
		cAlias := SGetNAlias()

		if (!SEmpty(nCodConhec))
			do case
				case cOpcao == '1'
		   			cQuery := "select tab_lote.lote_conhec from tab_lote, tab_clientes where tab_lote.ben_id = tab_clientes.cli_id and tab_lote.lote_conhec = '"+STransType(nCodConhec)+"'"

		   		case cOpcao == '2'
		   			cQuery := "select distinct tab_lote.lote_conhec "+;
              				"  from tab_lote, "+;
              				"       tab_clientes "+;
              				" where tab_lote.ben_id = tab_clientes.cli_id"+;
              				"       and tab_lote.lote_conhec = '"+STransType(nCodConhec)+"'"
		   		case cOpcao == '3'
		   			cQuery := "select distinct tab_lote.lote_pcarga "+;
              				"  from tab_lote, "+;
              				"       tab_clientes "+;
              				" where tab_lote.ben_id = tab_clientes.cli_id"+;
              				"       and tab_lote.lote_pcarga = '"+STransType(nCodConhec)+"'"

		   	endcase
		endif

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		lRet := (cAlias)->(!EOF())

		(cAlias)->(dbCloseArea())
	endif

return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SValNF
Validacao da nota fiscal

@param xConteud Codigo da nota fiscal a ser verificada

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SValNF(xConteud)

	Local cAlias := ''
	Local cQuery := ''
	Local lRet   := .T.

	if !SEmpty(xConteud)
		cAlias := SGetNAliasa()

		cQuery := "select distinct numero from vw_not_fisc_compil "+;
					"where num_nota_fiscal = '"+STransType(xConteud)+"'"

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		lRet := (cAlias)->(!EOF())

		(cAlias)->(dbCloseArea())
	endif

return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SValVeic2
Validacao de veiculo

@param xConteud Codigo do veiculo a ser verificado

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SValVeic2(xConteud)

	Local cAlias := ''
	Local cQuery := ''
	Local lRet   := .T.

	if !SEmpty(xConteud)
		cAlias := SGetNAliasa()

		cQuery := "select distinct a.vei_id "+;
				"from tab_veiculos a, "+;
					"tab_cesv b, "+;
					"rel_cesv_dent c, "+;
					"rel_dent_cnt d, "+;
					"rel_lote e, "+;
					"tab_lote f "+;
				"where a.vei_id = b.vei_id "+;
					"and b.cesv_id = c.cesv_id "+;
					"and c.dent_id = d.dent_id "+;
					"and d.lote_id = e.lote_pai "+;
					"and e.lote_filho = f.lote_id "+;
					"and a.vei_id = '"+STransType(xConteud)+"'"

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		lRet := (cAlias)->(!EOF())

		(cAlias)->(dbCloseArea())
	endif

return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SValCNTR
Validacao do container

@param xConteud Codigo do container a ser verificado

@author  Felipe Machado de Oliveira
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SValCNTR(xConteud)

	Local cAlias := ''
	Local cQuery := ''
	Local lRet   := .T.

	if !SEmpty(xConteud)
		cAlias := SGetNAliasa()

		cQuery := "select distinct a.cnt_id "+;
				"from tab_container a, "+;
					"tab_mov_cnt b, "+;
					"rel_dent_cnt c, "+;
					"rel_lote d "+;
				"where a.cnt_id = b.cnt_id "+;
					"and b.mcnt_id = c.mcnt_id "+;
					"and c.lote_id = d.lote_pai "+;
					"and a.cnt_id = '"+STransType(xConteud)+"'"

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		lRet := (cAlias)->(!EOF())

		(cAlias)->(dbCloseArea())
	endif

return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SValCDesUn
Validacao do conhecimento unitario

@param nVal Conteudo que seleciona determinado SELECT
@param nVal2 Conteudo a ser validado

@author  Marcio Franklin Carvalho de Noronha
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SValCDesUn(nVal, nVal2)

	Local cAlias := ''
	Local cQuery := ''	
	Local lRet := .T.

	if !SEmpty(nVal2)

	   if nVal == 'lote_conhec'
          cQuery := "select  distinct  a.lote_conhec from  tab_lote a,  tab_clientes b,  rel_dent_cnt c,  tab_mov_cnt d,  vw_opr_GCI_LoteAtual e,  tab_especie f,  tab_armazem g,  tab_celulas h,  tab_container i,  tab_tipo_iso j  where  a.ben_id = b.cli_id  and a.lote_id = c.lote_id  and d.mcnt_id = c.mcnt_id  and d.mcnt_dt_desova is null and d.mcnt_status = 1 and d.cesv_id_sai is null and a.lote_cancelado is null and d.cnt_id = e.cnt_id  and e.latu_qt_saldo > 0  and e.esp_id = e.esp_id  and g.arm_id = d.arm_id  and g.arm_id = h.arm_id  and i.cnt_id = e.cnt_id  and j.tiso_id = i.tiso_id and a.lote_conhec = '"+STransType(nVal2, "C")+"'"
       else
          cQuery := "select  distinct  a.lote_id from  tab_lote a,  tab_clientes b,  rel_dent_cnt c,  tab_mov_cnt d,  vw_opr_GCI_LoteAtual e,  tab_especie f,  tab_armazem g,  tab_celulas h,  tab_container i,  tab_tipo_iso j  where  a.ben_id = b.cli_id  and a.lote_id = c.lote_id  and d.mcnt_id = c.mcnt_id  and d.mcnt_dt_desova is null and d.mcnt_status = 1 and d.cesv_id_sai is null and a.lote_cancelado is null and d.cnt_id = e.cnt_id  and e.latu_qt_saldo > 0  and e.esp_id = e.esp_id  and g.arm_id = d.arm_id  and g.arm_id = h.arm_id  and i.cnt_id = e.cnt_id  and j.tiso_id = i.tiso_id and a.lote_id = '"+STransType(nVal2, "C")+"'"
       endif

		cAlias := SGetNAlias()

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		lRet := (cAlias)->(!EOF())

		(cAlias)->(dbCloseArea())
	endif

return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SValCNT
Validacao de container

@param nVal Codigo do container a ser validado

@author  Marcio Franklin Carvalho de Noronha
@since   02/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SValCNT(nVal)

	Local cAlias := ''
	Local cQuery := ''
	Local lRet := .T.

	if !SEmpty(nVal)
		cAlias := SGetNAlias()

		if (!SEmpty(nVal))
		   cQuery := "select distinct  i.cnt_id from  tab_lote a,  tab_clientes b,  rel_dent_cnt c,  tab_mov_cnt d,  vw_opr_GCI_LoteAtual e,  tab_especie f,  tab_armazem g,  tab_celulas h,  tab_container i,  tab_tipo_iso j  where  a.ben_id = b.cli_id  and a.lote_id = c.lote_id  and d.mcnt_id = c.mcnt_id  and d.mcnt_dt_desova is null  and d.mcnt_status = 1  and d.cesv_id_sai is null  and a.lote_cancelado is null  and d.cnt_id = e.cnt_id  and e.latu_qt_saldo > 0  and e.esp_id = e.esp_id  and g.arm_id = d.arm_id  and g.arm_id = h.arm_id  and i.cnt_id = e.cnt_id  and j.tiso_id = i.tiso_id and i.cnt_id = '"+STransType(nVal, "C")+"'"
		endif

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		lRet := (cAlias)->(!EOF())

		(cAlias)->(dbCloseArea())
	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SValArm
Validacao de Regime

@param xConteud Codigo do armazém a ser verificado

@author  Marcio Franklin Carvalho de Noronha
@since   24/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SValArm(xConteud)

	Local cAlias := ''
	Local cQuery := ''
	Local lRet   := .T.

	if !SEmpty(xConteud)
		cAlias := SGetNAlias()
		cQuery := "select arm_id, arm_descricao from tab_armazem where arm_id ='" + STrim(STransType(xConteud)) + "'"

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		lRet := (cAlias)->(!EoF())

		(cAlias)->(dbCloseArea())

	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SValGen
Validação do conteudo

@param cSQL Variável que contém o SQL para a validação

@author  Felipe Machado de Oliveira
@since   26/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SValGen(cQuery)
	Local cAlias := ''
	Local lRet   := .T.

	if !SEmpty(cQuery)
		cAlias := SGetNAlias()

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		lRet := (cAlias)->(!EoF())

		(cAlias)->(dbCloseArea())
	else
		return .F.
	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SValCDA
Validacao de Regime

@param xConteud Codigo do CDA

@author  Marcio Franklin Carvalho de Noronha
@since   30/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SValCDA(xConteud)

	Local cAlias := ''
	Local cQuery := ''
	Local lRet   := .T.

	if !SEmpty(xConteud)
		cAlias := SGetNAlias()
		cQuery := "select substring(dsai_id,7,9) as dsai_id_num, dsai_id, dsai_dt_registro, dsai_dt_vencto from tab_doc_saida where substring(dsai_id,5,2) = '91' and dsai_id = '" + STrim(STransType(xConteud)) + "'"

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		lRet := (cAlias)->(!EoF())

		(cAlias)->(dbCloseArea())

	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SValCli
Validacao de Regime

@param xConteud Codigo do CDA

@author  Marcio Franklin Carvalho de Noronha
@since   30/07/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SValCli(xConteud)

	Local cAlias := ''
	Local cQuery := ''
	Local lRet   := .T.

	if !SEmpty(xConteud)
		cAlias := SGetNAlias()
		cQuery := "select cli_id, cli_cgc, cli_nome from tab_clientes where cli_id is not null and cli_id = '" + STrim(STransType(xConteud)) + "'"

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		lRet := (cAlias)->(!EoF())

		(cAlias)->(dbCloseArea())

	endif

return lRet

Function SValTable(oTable)

	Local aInfos := SZoomTable()
	Local aPos := 1

	if !Empty(oTable)
		aPos := Ascan(aInfos[INFO_ZOOM_OBJETO], {|x,y| (x[2] == STrim(oTable)) })
	endif

return (aPos > 0)

Function SExecSQL(cSQL)
	Local cMostraDebug := Upper(SuperGetMV('MV_WMSSMD', .F., 'N'))

	if cMostraDebug == 'S'
 		SPrintCon(cSQL, 'TcSqlExec')
 	endif
return TcSqlExec(cSQL)

Function SPrintCon(cTexto, cTitulo)
	Local cLogConsol := ''
	DEFAULT cTitulo := 'Geral'

	cLogConsol := '*********' + Chr(13) + Chr(10)
	cLogConsol := cLogConsol + 'Titulo: ' + cTitulo + Chr(13) + Chr(10)
	cLogConsol := cLogConsol + 'Conteudo: ' + STrim(cTexto) + Chr(13) + Chr(10)
	cLogConsol := cLogConsol + '*********' + Chr(13) + Chr(10)
	
	PRALogMsg(,cLogConsol) 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomDoc
Zoom de tipo de documento de conhecimento

@author  Joao Victor Fidelix
@since   08/11/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomDoc()
	Local aRet := {}
    Local aFields := {}

    Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL) //Tipo de execução - 1: SQL 2: Array

    Aadd(aRet, "select conhec_id, conhec_nome from tab_tipo_conhecimento " )
    Aadd(aRet, "order by conhec_nome")

                //aFields,  cCampo             , cDesc                   , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
    SAddPField(@aFields , "conhec_id"           , STR0002/*"uCódigo"*/  , "C"   , 15      , 0        , ""      , .T.     , .T. , .F. , 1)
    SAddPField(@aFields , "conhec_nome"         , STR0042/*"Código"*/   , "C"   , 30      , 0        , ""      , .T.     , .T. , .T. , 1)

    Aadd(aRet, aFields)
return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomConh3
Zoom de Conhecimento

@author  João Victor
@since   08/11/2012
@version P12
@protected
/*/
//-------------------------------------------------------------------
function SZoomConh3(cAno, cTpConhec)
	Local aRet := {}
	Local aFields := {}
	DEFAULT cAno := ''
	DEFAULT cTpConhec := ''

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

   	if !SEmpty(cAno)
	  Aadd(aRet,"select " +;
              " lote_conhec, " +;
              " (convert(varchar(20),lote_dt_conhec,103) ++ ' ' ++ convert(varchar(20),lote_dt_conhec,108)) lote_dt_conhec, " +;
              " substring(lote_id_rf,1,2)+'/'+"+;
              " substring(lote_id_rf,3,6)+'-'+"+;
              " substring(lote_id_rf,9,1) as lote_id_rf,"+;
              " lote_id " +;
              "from " +;
              " tab_lote " +;
              "where " +;
              " lote_cancelado is null " +;
              " and year(lote_dt_conhec) = " + STrim(cAno) +;
              " and conhec_id = " + STrim(cTpConhec))
   else
	  Aadd(aRet,"select " +;
              " lote_conhec, " +;
              " (convert(varchar(20),lote_dt_conhec,103) ++ ' ' ++ convert(varchar(20),lote_dt_conhec,108)) lote_dt_conhec, " +;
              " substring(lote_id_rf,1,2)+'/'+"+;
              " substring(lote_id_rf,3,6)+'-'+"+;
              " substring(lote_id_rf,9,1) as lote_id_rf,"+;
              " lote_id " +;
              "from " +;
              " tab_lote " +;
              "where " +;
              " lote_cancelado is null " +;
              " and conhec_id = " + STrim(cTpConhec))
   endif

   Aadd(aRet, " order by lote_conhec ")

   SAddPField(@aFields , "lote_conhec"      , STR0022/*"Conhecimento"*/  , "C"  , 20  , 0  , ""  , .T.   , .T., .T., 1)
   SAddPField(@aFields , "lote_dt_conhec"   , STR0058/*"Data"*/          , "C"  , 20  , 0  , ""  , .T.   , .F., .F., 1)
   SAddPField(@aFields , "lote_id_rf"       , STR0023/*"Lote"*/           , "C"  , 30  , 0  , "@R 99/999999-9" , .T.   , .F., .F., 1)
   SAddPField(@aFields , "lote_id"          , STR0065/*"Lote sistema"*/  , "C"  , 30  , 0  ,"", .T.   , .F., .F., 1)

	aadd(aRet, aFields)

return aRet

function SZoomConh4(cAno, cTpConhec)
	Local aRet := {}
	Local aFields := {}
	DEFAULT cAno := ''
	DEFAULT cTpConhec := ''

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

   	if !SEmpty(cAno)
	  Aadd(aRet,"select " +;
              " a.lote_conhec, " +;
              " (convert(varchar(20),a.lote_dt_conhec,103) ++ ' ' ++ convert(varchar(20),a.lote_dt_conhec,108)) lote_dt_conhec, " +;
              " substring(a.lote_id_rf,1,2)+'/'+"+;
              " substring(a.lote_id_rf,3,6)+'-'+"+;
              " substring(a.lote_id_rf,9,1) as lote_id_rf,"+;
              " a.lote_id " +;
              "from " +;
              " tab_lote a, " +;
              " rel_lote b "+;
              "where " +;
              " a.lote_cancelado is null " +;
              " and year(a.lote_dt_conhec) = " + STrim(cAno) +;
              " and a.conhec_id = " + STrim(cTpConhec)+;
              " and b.lote_pai = a.lote_id")
   else
	  Aadd(aRet,"select " +;
              " a.lote_conhec, " +;
              " (convert(varchar(20),a.lote_dt_conhec,103) ++ ' ' ++ convert(varchar(20),lote_dt_conhec,108)) lote_dt_conhec, " +;
              " substring(a.lote_id_rf,1,2)+'/'+"+;
              " substring(a.lote_id_rf,3,6)+'-'+"+;
              " substring(a.lote_id_rf,9,1) as lote_id_rf,"+;
              " a.lote_id " +;
              "from " +;
              " tab_lote a, " +;
              " rel_lote b "+;
              "where " +;
              " a.lote_cancelado is null " +;
              " and a.conhec_id = " + STrim(cTpConhec)+;
              " and b.lote_pai = a.lote_id")
   endif

   Aadd(aRet, " order by a.lote_conhec ")

   SAddPField(@aFields , "lote_conhec"      , STR0022/*"Conhecimento"*/  , "C"  , 20  , 0  , ""  , .T.   , .T., .T., 1)
   SAddPField(@aFields , "lote_dt_conhec"   , STR0058/*"Data"*/          , "C"  , 20  , 0  , ""  , .T.   , .F., .F., 1)
   SAddPField(@aFields , "lote_id_rf"       , STR0023/*"Lote"*/           , "C"  , 30  , 0  , "@R 99/999999-9" , .T.   , .F., .F., 1)
   SAddPField(@aFields , "lote_id"          , STR0065/*"Lote sistema"*/  , "C"  , 30  , 0  ,"", .T.   , .F., .F., 1)

	aadd(aRet, aFields)

return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} SZoomDSAI1
Zoom de Documento de Saida

@author  Marcelo Radulski Nunes
@since   05/06/2013
@version P12
@protected
/*/
//-------------------------------------------------------------------
Function SZoomDSAI1()
	Local aRet := {}
	Local aFields := {}

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL) //Tipo de execução - 1: SQL 2: Array
    Aadd(aRet,"select " +;
                "  distinct " +;
                "  a.dsai_id, " +;
                "  substring(a.dsai_id, 1, 4) + '/' + substring(a.dsai_id , 7,9) as documento, " +;
                "  substring(e.lote_id_rf,1,2)+'/'+"+;
                "  substring(e.lote_id_rf,3,6)+'-'+"+;
                "  substring(e.lote_id_rf,9,1) as lote_id_rf,"+;                
                "  substring(c.latu_lote, 1, 4) + '/' + substring(c.latu_lote, 5, 8) as lote, " +;
                "  ben.cli_nome as beneficiario, " +;
                "  com.cli_nome as comissaria, " +;
                "  d.doc_familia " +;
                "from " +;
                "  tab_doc_saida a " +;
                "    left outer join tab_clientes ben on (ben.cli_id = a.ben_id) " +;
                "    left outer join tab_clientes com on (com.cli_id = a.com_id) " +;
                "    left outer join tab_di_item c on (a.dsai_id = c.dsai_id) " +;
                "    left outer join tab_lote e on (e.lote_id = c.latu_lote), " +;
                "  tab_documentos d " +;
                "where " +;
                "  substring(a.dsai_id, 5, 1) = d.doc_ordem1 and a.dsai_dt_registro > (getdate() - 1780 ) ")
	Aadd(aRet," order by 1")

               //aFields ,cCampo         ,cDesc   ,cTipo ,nTamanho ,nPrecisao ,cMascara          ,lVisivel ,lRetorna ,Def. ,TpPesq -> 1 Cont, 2 =, 3 >=, 4 <=, 5 Ini, 6 Fim
    SAddPField(@aFields ,"a.dsai_id"    ,STR0060 ,"C"    ,30        ,0          ,""                  ,.T.       ,.T.       ,.T.  ,1) //Monta a estrutura de campos
    SAddPField(@aFields ,"documento"    ,STR0061 ,"C"    ,14        ,0          ,""                  ,.T.       ,.F.       ,.F.  ,1) //Monta a estrutura de campos
	SAddPField(@aFields ,"e.lote_id_rf" ,STR0062 ,"C"    ,13        ,0          ,"@R 99/999999-9"  ,.T.       ,.F.       ,.F.  ,1) //Monta a estrutura de campos
	SAddPField(@aFields ,"lote"          ,STR0065 ,"C"    ,13        ,0          ,""                  ,.T.       ,.F.       ,.F.  ,1) //Monta a estrutura de campos
    SAddPField(@aFields ,"beneficiario" ,STR0063 ,"C"    ,50        ,0          ,""                  ,.T.       ,.F.       ,.F.  ,1) //Monta a estrutura de campos
	SAddPField(@aFields ,"comissaria"   ,STR0064 ,"C"    ,50        ,0          ,""                  ,.T.       ,.F.       ,.F.  ,1) //Monta a estrutura de campos
	SAddPField(@aFields ,"d.doc_familia",STR0039 ,"C"    ,10        ,0          , ""                 ,.T.       ,.F.       ,.F.  ,1) //Monta a estrutura de campos

	Aadd(aRet, aFields)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SZoomCliCJ
Zoom de clientes por CNPJ

@author  Marcelo Nunes
@since   29/07/2015
@version P11
@protected
/*/
//-------------------------------------------------------------------
Function SZoomCliCJ()

	Local   aRet      := {}
	Local   aFields   := {}
	Local   cQuery    := ''
	
	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	cQuery := "select cli_nome, cli_cgc, "+;
					"case len(cli_cgc) "+;
						"when 14 then "+;
							"substring(cli_cgc,1,2)++'.'++substring(cli_cgc,3,3)++'.'++substring(cli_cgc,6,3)++'/'++substring(cli_cgc,9,4)++'-'++substring(cli_cgc,13,2) "+;
						"when 11 then "+;
							"substring(cli_cgc,1,3)++'.'++substring(cli_cgc,4,3)++'.'++substring(cli_cgc,7,3)++'-'++substring(cli_cgc,10,2) "+;
						"else "+;
							"cli_cgc "+;
					"end as cli_cgc_mascara "+;
				"from tab_clientes where cli_id is not null"

	Aadd(aRet, cQuery)
	Aadd(aRet, 'ORDER BY tab_clientes.cli_nome')
   //          aFields , cCampo            , cDesc                 , cTipo ,nTamanho ,nPrecisao ,cMascara ,lVisivel ,lRetorna ,Def. ,TpPesq -> 1 Cont, 2 =, 3 >=, 4 <=, 5 Ini, 6 Fim
   SAddPField(@aFields , "cli_nome"        , STR0003/*"Nome"*/     , "C"   , 30      , 0        , ""      , .T.     , .F.)
   SAddPField(@aFields , "cli_cgc"         , STR0002/*"CNPJ/CPF"*/ , "C"   , 14      , 0        , ""      , .F.     , .T.     , .T. , 1)
   SAddPField(@aFields , "cli_cgc_mascara" , STR0026/*"CNPJ/CPF"*/ , "C"   , 18      , 0        , ""      , .T.     , .F.)
   

   Aadd(aRet, aFields)

return aRet

Function SGetRealName(cAliasT)
	Local cRealName := cAliasT
	Local oFwTbTemp
	Local nI := aScan(aAlSARA,{|x|x[1] == cAliasT})
	If nI != 0
		oFwTbTemp := aAlSARA[nI,2]
		cRealName := oFwTbTemp:GetRealName()
	EndIf
Return cRealName

Function SZoomLoteAvaria(lRetLote, lRetID, lRetCarga)
	Local aRet := {}
	Local aFields := {}
	Default lRetLote  := .F.
	Default lRetID    := .F.
	Default lRetCarga := .F.

   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL) //Tipo de execução - 1: SQL 2: Array
   Aadd(aRet, "SELECT DISTINCT"+;    
				"  SUBSTRING(A.LOTE_ID_RF,1,2)+'/'+ SUBSTRING(A.LOTE_ID_RF,3,6)+'-'+ SUBSTRING(A.LOTE_ID_RF,9,1) AS LOTE_ID_RF, "+;
				"  A.LOTE_ID, "+;
				"  A.LOTE_CONHEC, "+;    
				"  B.CLI_NOME, "+;    
				"  A.LOTE_PCARGA "+;  
				"FROM "+;    
				"  TAB_LOTE A, "+;    
				"  TAB_CLIENTES B "+;    
				"WHERE "+;    
				"  A.BEN_ID = B.CLI_ID "+;    
				"  AND (EXISTS (SELECT DISTINCT 1 FROM TAB_TERMO_LOTE C WHERE A.LOTE_ID = C.LOTE_ID AND C.TER_ID IS NOT NULL "+;
				"               AND C.TER_DT_GERACAO > ( GETDATE() - 1780)) "+;  
				"  OR   EXISTS (SELECT DISTINCT 1 FROM REL_DENT_CNT D, TAB_TERMO_CNT E WHERE A.LOTE_ID = D.LOTE_ID AND "+; 
				"               D.CNT_ID = E.CNT_ID AND E.TER_ID IS NOT NULL AND E.TER_DT_GERACAO > ( GETDATE() - 1780))) ")  		
				
				Aadd(aRet, "ORDER BY 1")
               
               //aFields,  cCampo             , cDesc                                 , cTipo, nTamanho, nPrecisao, cMascara       , lVisivel, lRetorna
	SAddPField(@aFields , "a.lote_id_rf"      , "Lote"                                 , "C"  , 15       , 0        , "@R 99/999999-9", .T.       , lRetID   , lRetID, 1) //Monta a estrutura de campos.               
	SAddPField(@aFields , "a.lote_id"         , "Lote sistema"                         , "C"  , 15       , 0        , ""                , .T.       , .F.   , .F., 2) //Monta a estrutura de campos               
	SAddPField(@aFields , "a.lote_conhec"     , "Conhecimento"                         , "C"  , 20       , 0        , ""                , .T.      , lRetLote , lRetLote, 1 ) //Monta a estrutura de campos	
	SAddPField(@aFields , "b.cli_nome"        , "Cliente"                              , "C"  , 30       , 0        , ""                , .T.       , .F.) //Monta a estrutura de campos
	SAddPField(@aFields , "a.lote_pcarga"     , "Lote Carga/CE Mercadante"             , "C"  , 30       , 0        , ""                , .T.       , lRetCarga, lRetCarga, 1) //Monta a estrutura de campos

	Aadd(aRet, aFields)

Return aRet

/*/{Protheus.doc} A927KEYTabela
//TODO Descrição auto-gerada.
Esta função busca e retorna o nome da tabela e as suas chaves primaria
@author MOHAMED S B DJALO
@since 04/08/2019
@version undefined

@return aResult, return_description
@example
(examples)
@see (links_or_references)
/*/
Function A927KEYTabela()
    Local i          := 1
    Local nY         := 1
    Local cAliasEmp  := GetNextAlias()
    Local aResult    := {}
    Local cTabCad    := ''
    Local aTabMov := A927MOV_TAB()
    Local cTabMov := ''
    Local cQuery  := ''
    Local aTabCad := A927TabCAD()

    For nY := 1 To Len(aTabCad)
       If(cTabCad <> '')
          cTabCad += ','
       EndIf 
       cTabCad += "'"+AllTrim(aTabCad[nY][1])+"'"
    Next
    
    For i := 1 To Len(aTabMov)
        If (!Empty(cTabMov))
            cTabMov += ','
        EndIf
        
        cTabMov += "'"+aTabMov[i][1]+"'"
    Next
    
    cQuery += ' select tab.[name] as table_name,                              '
	cQuery += '        col.[name] as column_name,                             '
	cQuery += '        schema_name(tab.schema_id) as [schema_name],           '  
	cQuery += '        pk.[name] as pk_name,                                  '
	cQuery += '        ic.index_column_id as column_id                        '
	cQuery += ' from sara_log.sys.tables tab                                  '
	cQuery += '     inner join sara_log.sys.indexes pk                        '
	cQuery += '         on tab.object_id = pk.object_id                       '
	cQuery += '         and pk.is_primary_key = 1                             '
	cQuery += '     inner join sara_log.sys.index_columns ic                  '
	cQuery += '         on ic.object_id = pk.object_id                        '
	cQuery += '         and ic.index_id = pk.index_id                         '
	cQuery += '     inner join sara_log.sys.columns col                       ' 
	cQuery += '         on pk.object_id = col.object_id                       '
	cQuery += '         and col.column_id = ic.column_id                      ' 
	cQuery += " WHERE substring(tab.[name],1,4) = 'tab_'                      "
	cQuery += '   and tab.[name] NOT IN ('+cTabMov+')                         '
	cQuery += '   and substring(tab.[name],5,3) = substring(col.[name],1,3)   '
	cQuery += '   ORDER BY TABLE_NAME                                         '  
	
	cQuery := ChangeQuery(cQuery)
    
    DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasEmp,.F.,.T.)
    
    dbSelectArea(cAliasEmp)
    (cAliasEmp)->(DbGoTop())
    while (cAliasEmp)->(!EOF())
         Aadd(aResult,{(cAliasEmp)->table_name,(cAliasEmp)->column_name})
        (cAliasEmp)->(DbSkip())
    EndDo
    (cAliasEmp)->(dbCloseArea())
    
Return aResult

/*/{Protheus.doc} A927MOV_TAB
//TODO Descrição auto-gerada.
O objetivo desta função é retornar as tabelas que são de movimentações no sistema
@author MOHAMED S B DJALO
@since 04/08/2019
@version undefined

@return aTabMov, return_description
@example
(examples)
@see (links_or_references)
/*/
Function A927MOV_TAB()
    Loca aTabMov     := {}
    Local cTabMov    := ''
    
    aadd(aTabMov,{'tab_usuarios',1,2})
	aadd(aTabMov,{'tab_lote',3,4})
	aadd(aTabMov,{'rel_lote',5,6})
	aadd(aTabMov,{'tab_cesv',7,8})
	aadd(aTabMov,{'tab_doc_entrada',9,10})
	aadd(aTabMov,{'tab_doc_saida',11,12})
	aadd(aTabMov,{'tab_acesso',13,14})
	aadd(aTabMov,{'tab_os',15,16})
	aadd(aTabMov,{'tab_registro_manifesto',17,18})
	aadd(aTabMov,{'tab_hist_benef_lote',19,20})
	aadd(aTabMov,{'tab_apreensao',21,22})
	aadd(aTabMov,{'tab_lacres',23,24})
	aadd(aTabMov,{'tab_os_item',25,26})
	aadd(aTabMov,{'tab_lote_ova_cnt',27,28})
	aadd(aTabMov,{'tab_consolidacao',29,30})
	aadd(aTabMov,{'rel_lote_consolidacao',31,32})
	
Return aTabMov
