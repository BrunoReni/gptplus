#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"

#define INFO_ZOOM_TIPO_EXECUCAO 1
#define INFO_ZOOM_OBJETO 2
#define INFO_ZOOM_OBJETO_ORD 3
#define INFO_ZOOM_CAMPOS 4

#define INFO_ZOOM_CAMPO_NOME 1
#define INFO_ZOOM_CAMPO_DESC 2
#define INFO_ZOOM_CAMPO_TIPO 3
#define INFO_ZOOM_CAMPO_TAMANHO 4
#define INFO_ZOOM_CAMPO_PRECISAO 5
#define INFO_ZOOM_CAMPO_MASCARA 6
#define INFO_ZOOM_CAMPO_VISIVEL 7
#define INFO_ZOOM_CAMPO_RETORNA 8

#define INFO_ZOOM_CAMPO_DEF 9
#define INFO_ZOOM_CAMPO_TPPESQ 10

#define INFO_ZOOM_TIPO_EXECUCAO_SQL   1
#define INFO_ZOOM_TIPO_EXECUCAO_ARRAY 2

/*/{Protheus.doc} PRAC938
@author   João Victor Fidelix
@version  P12
@since    30/04/2012
@obs      Zoom genérico SARA
/*/

Function PRAC938(aZoom, cTexto, lRet, lExibeMSG, lLoteValida)
	Local oBrowse
	Local oColumn
	Local aFieFilter := {}
	Local aList      := {}
	Local aSeek      := {}
	Local nStart     := 0
	Local nMax       := 0
	Local cAlias     := nil
	Local aFieldsUsr := nil
	Local aStruct    := {}
	Local aFields    := {}
	Local cAliasTmp  := nil
	Local cSQL       := ''
	Local cDefault   := ''
	Local nTPPesq    := 1
	Local cTipo      := 'C'
	Local nTotReg    := 0
	Local cMostraDebug := Upper(SuperGetMV('MV_WMSSMD', .F., 'N'))
	Public oDlg
	Public aRet      := nil
	Default cTexto   := nil
	Default lRet     := nil
	Default lExibeMSG   := .F.
	Default lLoteValida := .F.
	If Empty(aZoom)
		Return {}
	EndIf
	
	If (Len(aZoom) < 2)
		Return {}
	EndIf
	
	aFieldsUsr := aZoom[INFO_ZOOM_CAMPOS]
	aRet      := nil
	aRet      := {}
	lRet := .T.

	aRet      := nil
	aRet      := {}
	lRet := .T.

	nMax := Len(aFieldsUsr)

	cTexto := STrim(STransType(cTexto))
	
	if (lExibeMSG == .T.) .And. (lLoteValida == .F.)
	    if(len(AllTrim(cTexto)) < 3)
		    MsgAlert("Informar três dígitos para efetuar a busca! ")
		    Return .F.
	    EndIf
	Elseif((lExibeMSG == .T.) .And. (lLoteValida == .T.))
	    if(len(AllTrim(cTexto)) < 9)
		    MsgAlert("É necessário informar o número do lote para efetuar a busca! ")
		    Return .F.
	    EndIf
	EndIf

	if (aZoom[INFO_ZOOM_TIPO_EXECUCAO] == INFO_ZOOM_TIPO_EXECUCAO_SQL)
		cAlias := SGetNAlias()

		for nStart := 1 to nMax
			if (SEmpty(cDefault) .AND. aFieldsUsr[nStart][INFO_ZOOM_CAMPO_DEF])
				cDefault := STrim(aFieldsUsr[nStart][INFO_ZOOM_CAMPO_NOME])
				nTPPesq  := aFieldsUsr[nStart][INFO_ZOOM_CAMPO_TPPESQ]
				cTipo    := aFieldsUsr[nStart][INFO_ZOOM_CAMPO_TIPO]
			endif

			Aadd(aStruct,    {"CP" + STrim(Str(nStart)), aFieldsUsr[nStart][INFO_ZOOM_CAMPO_TIPO], aFieldsUsr[nStart][INFO_ZOOM_CAMPO_TAMANHO], aFieldsUsr[nStart][INFO_ZOOM_CAMPO_PRECISAO]})
			Aadd(aFields,     "CP" + STrim(Str(nStart)))
			Aadd(aFieFilter, {"CP" + STrim(Str(nStart)), aFieldsUsr[nStart][INFO_ZOOM_CAMPO_DESC], aFieldsUsr[nStart][INFO_ZOOM_CAMPO_TIPO], aFieldsUsr[nStart][INFO_ZOOM_CAMPO_TAMANHO], aFieldsUsr[nStart][INFO_ZOOM_CAMPO_PRECISAO],aFieldsUsr[nStart][INFO_ZOOM_CAMPO_MASCARA]})
			Aadd(aSeek,      {aFieldsUsr[nStart][INFO_ZOOM_CAMPO_DESC], {{"",aFieldsUsr[nStart][INFO_ZOOM_CAMPO_TIPO], aFieldsUsr[nStart][INFO_ZOOM_CAMPO_TAMANHO], aFieldsUsr[nStart][INFO_ZOOM_CAMPO_PRECISAO], "CP" + STrim(Str(nStart))}} } )
		next

		cAliasTmp := SCriaTbTmp({aStruct, aFields})

		cSQL := Upper(aZoom[INFO_ZOOM_OBJETO])
		if At('WHERE', cSQL) <= 0
			cSQL += ' WHERE 1=1 '
		endif

		if ((!SEmpty(cTexto)) .AND. (!SEmpty(cDefault)))
			cSQL += ' AND ' + cDefault
			if nTPPesq == 1
				cSQL += " Like '%"+cTexto+"%'"
			elseif nTPPesq == 5
				cSQL += " Like '"+cTexto+"%'"
			elseif nTPPesq == 6
				cSQL += " Like '%"+cTexto+"'"
			else
				if nTPPesq == 2
					cSQL += " = "
				elseif nTPPesq == 3
			 		cSQL += " >= "
			 	elseif nTPPesq == 4
			 		cSQL += " <= "
				endif

				if cTipo == 'N'
					cSQL += STransType(cTexto)
				else
					cSQL += "'"+STransType(cTexto)+"'"
				endif
			endif
		endif

		if !SEmpty(aZoom[INFO_ZOOM_OBJETO_ORD])
			cSQL += ' ' + Upper(STransType(aZoom[INFO_ZOOM_OBJETO_ORD]))
		endif

 		if cMostraDebug == 'S'
 			SPrintCon(cSQL, 'ZOOM')
 		endif

		DbUseArea(.T., 'TOPCONN', TCGenQry(,,cSQL),cAlias, .F., .F.)

		(cAlias)->(DbGotop())
		While (cAlias)->(!Eof())
			(cAliasTmp)->(dbAppend())
			For nStart:=1 To nMax
				If aStruct[nStart][2] == "N"
					(cAliasTmp)->(FieldPut(nStart,val(Str((cAlias)->(FieldGet(nStart)),aStruct[nStart][3],aStruct[nStart][4]))))
				Else
					(cAliasTmp)->(FieldPut(nStart,STransType((cAlias)->(Fieldget(nStart)))))
				EndIf
			Next nI
			(cAlias)->(DbSkip())
			nTotReg += 1
		EndDo

		(cAlias)->(dbCloseArea())

	elseif aZoom[INFO_ZOOM_TIPO_EXECUCAO] == INFO_ZOOM_TIPO_EXECUCAO_ARRAY
		for nStart := 1 to nMax
			Aadd(aFieFilter,    {aFieldsUsr[nStart][INFO_ZOOM_CAMPO_NOME], aFieldsUsr[nStart][INFO_ZOOM_CAMPO_DESC], aFieldsUsr[nStart][INFO_ZOOM_CAMPO_TIPO], aFieldsUsr[nStart][INFO_ZOOM_CAMPO_TAMANHO], aFieldsUsr[nStart][INFO_ZOOM_CAMPO_PRECISAO],aFieldsUsr[nStart][INFO_ZOOM_CAMPO_MASCARA]})
			Aadd(aSeek     ,    {aFieldsUsr[nStart][INFO_ZOOM_CAMPO_DESC], {{"",aFieldsUsr[nStart][INFO_ZOOM_CAMPO_TIPO], aFieldsUsr[nStart][INFO_ZOOM_CAMPO_TAMANHO], aFieldsUsr[nStart][INFO_ZOOM_CAMPO_PRECISAO], aFieldsUsr[nStart][INFO_ZOOM_CAMPO_NOME]}} } )
		next

		aList := aZoom[INFO_ZOOM_OBJETO]
	endif

	if aZoom[INFO_ZOOM_TIPO_EXECUCAO] == INFO_ZOOM_TIPO_EXECUCAO_SQL
		if nTotReg == 0
			lRet := .F.
			MsgAlert('Nenhum registro encontrado.')
			return {}
		elseif nTotReg == 1
			C938SELREG(oBrowse, aList, aZoom, cAliasTmp, .F.)
			return aRet
		endif
	endif

	DEFINE MSDIALOG oDlg FROM 0,0 TO 500,500 PIXEL

		oBrowse := FWBrowse():new(oDlg)

		if (aZoom[INFO_ZOOM_TIPO_EXECUCAO] == INFO_ZOOM_TIPO_EXECUCAO_SQL)
			oBrowse:SetDataTable()
			oBrowse:SetAlias(cAliasTmp)
		elseif (aZoom[INFO_ZOOM_TIPO_EXECUCAO] == INFO_ZOOM_TIPO_EXECUCAO_ARRAY)
			oBrowse:SetDataArray()
			oBrowse:SetArray(aList)
		endif

		oBrowse:SetSeek(nil,aSeek)
		oBrowse:SetFieldFilter(aFieFilter)
		oBrowse:SetUseFilter()

		nMax := Len(aFieldsUsr)
		for nStart := 1 to nMax
			oColumn := nil

			if aZoom[INFO_ZOOM_CAMPOS][nStart][INFO_ZOOM_CAMPO_VISIVEL]
				oColumn := FWBrwColumn():New()
				if aZoom[INFO_ZOOM_TIPO_EXECUCAO] == INFO_ZOOM_TIPO_EXECUCAO_SQL
					oColumn:SetData( &("{|| "+aStruct[nStart][1]+"}") )
				else
					oColumn:SetData( &(" { || aList[oBrowse:At(),"+Str(nStart)+"]}") )
				endif
				oColumn:SetTitle(aFieldsUsr[nStart][INFO_ZOOM_CAMPO_DESC])
				oColumn:SetSize(aFieldsUsr[nStart][INFO_ZOOM_CAMPO_TAMANHO])

				oBrowse:SetColumns({oColumn})
			endif
		next

		oBrowse:SetDoubleClick({|| C938SELREG(oBrowse, aList, aZoom, cAliasTmp)})

		oBrowse:Activate()

	ACTIVATE MSDIALOG oDlg CENTERED

	if aZoom[INFO_ZOOM_TIPO_EXECUCAO] == INFO_ZOOM_TIPO_EXECUCAO_SQL
		If Select(cAliasTmp) > 0
			(cAliasTmp)->(DbCloseArea())
		EndIf
		FErase(cAliasTmp+GetDbExtension())
	elseif aZoom[INFO_ZOOM_TIPO_EXECUCAO] == INFO_ZOOM_TIPO_EXECUCAO_ARRAY
		aList := nil
	endif

	oBrowse    := nil
	oColumn    := nil
	aFieFilter := nil
	aList      := nil
	aSeek      := nil
	nStart     := nil
	nMax       := nil
	cAlias     := nil
	aFieldsUsr := nil
	aStruct    := nil
	aFields    := nil
	cAliasTmp  := nil

Return aRet

Static function C938SELREG(oBrowse, aList, aZoom, cAliasTmp, lClose)
	Local aLine := nil
	Local nI := 0
	Local nMax := 0
	DEFAULT lClose := .T.

	aRet := {}

	if aZoom[INFO_ZOOM_TIPO_EXECUCAO] == INFO_ZOOM_TIPO_EXECUCAO_SQL
		nMax  := len(aZoom[INFO_ZOOM_CAMPOS])
	elseif aZoom[INFO_ZOOM_TIPO_EXECUCAO] == INFO_ZOOM_TIPO_EXECUCAO_ARRAY
		aLine := aList[oBrowse:At()]
		nMax  := len(aLine)
	endif

	for nI := 1 to nMax
		if aZoom[INFO_ZOOM_CAMPOS][nI][INFO_ZOOM_CAMPO_RETORNA]
			if aZoom[INFO_ZOOM_TIPO_EXECUCAO] == INFO_ZOOM_TIPO_EXECUCAO_SQL
				Aadd(aRet, (cAliasTmp)->(Fieldget(nI)))
			elseif aZoom[INFO_ZOOM_TIPO_EXECUCAO] == INFO_ZOOM_TIPO_EXECUCAO_ARRAY
				Aadd(aRet, aLine[nI])
			endif
		endif
	next

	if lClose
		oDlg:End()
	endif
return
