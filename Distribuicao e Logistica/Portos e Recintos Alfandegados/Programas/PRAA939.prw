#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC904.CH"

#define INFO_ZOOM_TIPO_EXECUCAO_SQL   1 

/*/{Protheus.doc} PRAA939
@author   Felipe Machado de Oliveira
@version  P12
@since    10/07/2012
@obs      Entrada de parâmetros do SQL dinâmico
/*/
Function PRAA939(aParams)
	Local aValores        := {}
	Local i               := 1
	Local nN              := 0
	Local nMax            := 0
	Local oDlg            := nil
	Local nPosIniX        := 1
	Local nPosIniY        := 1
	Local nHeight         := 9
	Local nWidth          := 96
	Local cContEval       := ""
	Local cQuery          := ""
  	Local cFiltro         := ""
  	Local oScroll         := nil
  	Local oPanel          := nil
  	Local nTmpHeight      := 0
  	Local nTmpMinHeight   := 100
  	Local oOK             := nil
  	Local oCancel         := nil
  	Local nResult         := 0
  	Local cBegin          := ""
  	Local lReturn         := .T.
  	Local cDescTbla       := nil
  	Local cMaskTbla       := nil
  	Local cSqlTbla        := nil
  	Private aDescField    := {}
  	Private aDFieldTmp    := {}
  	Private cAlias        := SGetNAlias()

	if aParams == nil
		aParams := {}
	endif

	nMax := len(aParams)

	for i := 1 to nMax
		nTmpHeight += (nPosIniY * 2) + (nHeight*2) + 6
	next

	if nTmpMinHeight > nTmpHeight
		nTmpHeight := nTmpMinHeight
	endif

	DEFINE MSDIALOG oDlg FROM 0,0 TO 300,250 PIXEL STYLE DS_MODALFRAME

	for i := 1 to nMax
		cBegin := left(aParams[i],1)

		do case
			case cBegin == "D"
				if substr(aParams[i],2,1) == "1"
					Aadd(aDFieldTmp,{STR0006,"##/##/####",nil,'D'})
					Aadd(aDFieldTmp,{STR0007,"##/##/####",nil,'D'})
				else
					if substr(aParams[i],2,1) != "2"
						Aadd(aDFieldTmp,{STR0008,"##/##/####",nil,'D'})
					endif

				endif

			case cBegin == "S"
				nN := len(aParams[i])
				if left(substr(aParams[i],2,nN),1) == "_"
					Aadd(aDFieldTmp, {substr(aParams[i],3,nN),nil,nil,'S'})
				else
					Aadd(aDFieldTmp, {substr(aParams[i],2,nN),nil,nil,'S'})
				endif

			case cBegin == "I"
				nN := len(aParams[i])
				if left(substr(aParams[i],2,nN),1) == "_"
					Aadd(aDFieldTmp, {substr(aParams[i],3,nN),'@E 9999999999999999999999999999',nil,'I'})
				else
					Aadd(aDFieldTmp, {substr(aParams[i],2,nN),'@E 9999999999999999999999999999',nil,'I'})
				endif

			otherwise
				cFiltro := aParams[i]

				cQuery := " SELECT * FROM "+RETSQLNAME("DBP")+" WHERE D_E_L_E_T_ <> '*' AND "
				cQuery += " DBP_PAR = '"+cFiltro+"' "

				cQuery := ChangeQuery(cQuery)
				DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)
				cDescTbla := (cAlias)->DBP_DESC
				cMaskTbla := (cAlias)->DBP_MASK
				DbCloseArea()

				cQuery := " SELECT CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),DBP_SQL)) DBP_SQL FROM "+RETSQLNAME("DBP")+" "+;
							" WHERE DBP_PAR = '"+cFiltro+"' "

				cQuery := ChangeQuery(cQuery)
				DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)
				cSqlTbla := (cAlias)->(FieldGet(1))

				if Asc(cSqlTbla) == 32
					cSqlTbla := nil
				endif

				if Asc(cMaskTbla) == 32
					cMaskTbla := nil
				endif

				lReturn := (cAlias)->(!EOF())

				if !lReturn
					MsgInfo(STR0009," MsgInfo ")
					aValores := {}
					return aValores
				endif

				DbCloseArea()

				Aadd(aDFieldTmp, {cDescTbla,cMaskTbla,cSqlTbla,'C'})

		endcase

		Aadd(aDescField, aDFieldTmp)

	next

	oScroll := TScrollArea():New(oDlg,01,01,100,100,.T.,.F.,.T.)
  	oScroll:Align := CONTROL_ALIGN_ALLCLIENT
	@ 000,000 MSPANEL oPanel OF oScroll SIZE 0,1000 COLOR CLR_HRED
	oScroll:SetFrame( oPanel )

	oSay := nil

	for i := 1 to nMax

		oSay := tSay():New(nPosIniY,nPosIniX,{|| ''},oPanel,,,,,,.T.,CLR_RED,CLR_WHITE,nWidth,nHeight)
		oSay:SetText( StrTran(aDescField[1][i][1],"_"," ") )

		nPosIniY := nPosIniY + nHeight + 1

		if aDescField[1][i][4] == 'D'
			Eval(&("{|| cVar_" +STransType(i)+ SCrtSpec(STransType(STrim(aDescField[1][i][1]))) + " := '          ' }"))
			cContEval := "{|| oVar_"+STransType(i)+SCrtSpec(STransType(STrim(aDescField[1][i][1])))+" := TGet():New( nPosIniY,nPosIniX,{|u| if(PCount()>0,cVar_"+STransType(i)+;
							SCrtSpec(STransType(STrim(aDescField[1][i][1])))+":=u,cVar_"+STransType(i)+;
							SCrtSpec(STransType(STrim(aDescField[1][i][1])))+")},oPanel,nWidth,nHeight,'"+;
							STransType(STrim(aDescField[1][i][2]))+"',{|u| A939VLDT(u)},,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cVar_"+STransType(i)+;
							SCrtSpec(STransType(STrim(aDescField[1][i][1])))+",,,,) }"
		else
			Eval(&("{|| cVar_" +STransType(i)+ SCrtSpec(STransType(STrim(aDescField[1][i][1]))) + " := '                                                  ' }"))

			cContEval := "{|| oVar_"+STransType(i)+SCrtSpec(STransType(STrim(aDescField[1][i][1])))+" := TGet():New( nPosIniY,nPosIniX,{|u| if(PCount()>0,cVar_"+STransType(i)+;
							SCrtSpec(STransType(STrim(aDescField[1][i][1])))+":=u,cVar_"+STransType(i)+;
							SCrtSpec(STransType(STrim(aDescField[1][i][1])))+")},oPanel,nWidth,nHeight,'"+;
							STransType(STrim(aDescField[1][i][2]))+"',,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cVar_"+STransType(i)+;
							SCrtSpec(STransType(STrim(aDescField[1][i][1])))+",,,,) }"
		endif

		Eval(&(cContEval))

		if aDescField[1][i][3] != nil
			cContEval := "{|| oBtn_"+STransType(i)+SCrtSpec(STransType(STrim(aDescField[1][i][1])))+" := "+;
					      "TButton():New( nPosIniY, nPosIniX+100 ,'...',oPanel,{|| A939ZOOM1(oDlg,"+;
					      " "+STransType(i)+",oVar_" +STransType(i)+ SCrtSpec(STransType(STrim(aDescField[1][i][1]))) + ") },"+;
                        "10,10,,,.F.,.T.,.F.,,.F.,,,.F. )}"
			Eval(&(cContEval))
		endif

		nPosIniY := nPosIniY + nHeight + 5

	next

	oOK := TButton():New( nPosIniY, nPosIniX ,STR0010,oPanel,{|| A939VP(oDlg, nMax, aParams, @aValores) },;
                   40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	oCancel := TButton():New( nPosIniY, 45,STR0011,oPanel,{|| oDlg:End() },;
                   40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

  	oDlg:Activate(Nil,Nil,Nil, .T., {|| Empty(nResult) }, Nil, {|| oDlg:lEscClose := .F. }, Nil, Nil )

return aValores

Static Function A939VP(oDlg, nMax, aParams, aValores)
	Local i := 1
	Local cValor := ''

	for i := 1 to len(aParams)
		cValor := Eval(&("{|| cVar_"+STransType(i)+SCrtSpec(STransType(STrim(aDescField[1][i][1])))+"}"))
		if (SEmpty(cValor))
			//MsgInfo(STR0012," MsgInfo ")
			//return .F.
			cValor := 'null'
		endif
		Aadd(aValores, cValor)
	next

	oDlg:End()
return

Function A939ZOOM1(oDlg, i, oCampo)
	Local n        := 1
	Local aRet     := {}
	Local aFields  := {}
	Local aStruct  := {}
	local aRetZoom := {}
	Local lRet

	DbUseArea(.T., 'TOPCONN', TCGenQry(,,aDescField[1][i][3]),cAlias, .F., .F.)
	aStruct := DbStruct(cAlias)
	DbCloseArea()
	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)
	Aadd(aRet, aDescField[1][i][3])
	Aadd(aRet, '')

	for n := 1 to len(aStruct)
		if n == 1
			lRet := .T.
		else
			lRet := .F.
		endif
		SAddPField(@aFields , aStruct[n][1] , aStruct[n][1]  , aStruct[n][2]  , aStruct[n][3]  , 0  , ""  , .T.   , lRet)
	next

	aadd(aRet, aFields)

	aRetZoom := PRAC938(aRet)

	if !SEmpty(aRetZoom)
		oCampo:cText := aRetZoom[1]
	else
		oCampo:cText := nil
	endif

return

Function A939VLDT(o)
	if AllTrim(STransType(o:cText)) != ''
		if STrim(STransType(cToD(o:cText))) == '/  /'
			MsgInfo(STR0014," MsgInfo ")
			return .F.
		endif
	endif
return .T.