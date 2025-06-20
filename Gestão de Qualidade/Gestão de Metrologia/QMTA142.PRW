#INCLUDE "PROTHEUS.CH"
#INCLUDE "QMTA142.CH"

#xcommand @ <nRow>, <nCol> [ COLUMN ] BROWSE  <oBrw>	;
					[ [ FIELDS ] <Flds,...>] ;
					[ ALIAS <cAlias> ] ;
					[ <sizes:FIELDSIZES, SIZES, COLSIZES> <aColSizes,...> ] ;
					[ <head:HEAD,HEADER,HEADERS> <aHeaders,...> ] ;
					[ SIZE <nWidth>, <nHeigth> ] ;
					[ <dlg:OF,DIALOG> <oDlg> ] ;
					[ SELECT <cField> FOR <uValue1> [ TO <uValue2> ] ] ;
					[ <change: ON CHANGE, ON CLICK> <uChange> ] ;
					[ ON [ LEFT ] DBLCLICK <uLDblClick> ] ;
					[ ON RIGHT CLICK <uRClick> ] ;
					[ FONT <oFont> ] ;
					[ CURSOR <oCursor> ] ;
					[ <color: COLOR, COLORS> <nClrFore> [,<nClrBack>] ] ;
					[ MESSAGE <cMsg> ] ;
					[ <update: UPDATE> ] ;
					[ <pixel: PIXEL> ] ;
					[ WHEN <uWhen> ] ;
					[ <design: DESIGN> ] ;
					[ VALID <uValid> ] ;
		=> ;
			 <oBrw> := TCBrowse():New( <nRow>, <nCol>, <nWidth>, <nHeigth>,;
									[\{|| \{<Flds> \} \}], ;
									[\{<aHeaders>\}], [\{<aColSizes>\}], ;
									<oDlg>, <(cField)>, <uValue1>, <uValue2>,;
									[<{uChange}>],;
									[\{|nRow,nCol,nFlags|<uLDblClick>\}],;
									[\{|nRow,nCol,nFlags|<uRClick>\}],;
									<oFont>, <oCursor>, <nClrFore>, <nClrBack>, <cMsg>,;
									<.update.>, <(cAlias)>, <.pixel.>, <{uWhen}>,;
									<.design.>, <{uValid}> )

// general data columns
#command ADD [ COLUMN ] TO [ BROWSE ] <oBrw> ;
				[ <dat: DATA, SHOWBLOCK> <uData> ] ;
				[ <tit: TITLE, HEADER> <cHead> [ <oem: OEM, ANSI, CONVERT>] ];
				[ <clr: COLORS, COLOURS> <uClrFore> [,<uClrBack>] ] ;
				[ ALIGN ] [ <align: LEFT, CENTERED, RIGHT> ] ;
				[ <wid: WIDTH, SIZE> <nWidth> [ PIXELS ] ] ;
				[ PICTURE <cPicture> ] ;
				[ <bit: BITMAP> ] ;
				[ <edit: EDITABLE> ] ;
				[ MESSAGE <cMsg> ] ;
				[ VALID <uValid> ] ;
				[ ERROR [MSG] [MESSAGE] <cErr> ] ;
				[ <lite: NOBAR, NOHILITE> ] ;
				[ <idx: ORDER, INDEX, TAG> <cOrder> ] ;
				=> ;
	 <oBrw>:AddColumn( TCColumn():New( ;
	 If(<.oem.>, OemToAnsi(<cHead>), <cHead>), ;
	 [ If( ValType(<uData>)=="B", <uData>, <{uData}> ) ], <cPicture>, ;
	 [ If( ValType(<uClrFore>)=="B", <uClrFore>, <{uClrFore}> ) ], ;
	 [ If( ValType(<uClrBack>)=="B", <uClrBack>, <{uClrBack}> ) ], ;
	 If(!<.align.>,"LEFT", Upper(<(align)>)), <nWidth>, <.bit.>, ;
	 <.edit.>, <cMsg>, <{uValid}>, <cErr>, <.lite.>, <(cOrder)> ) )

/*/
antigo A140VlPs
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o	 硄mt140VlPs� Autor � Wanderley Goncalves   � Data � 29/03/98 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Valida campo de Padrao Secundario						  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � QMTA140 - E' chamada no X3_VALID do cpo. QMS_PADSEC - SX3  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 					  潮�
北媚哪哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� PROGRAMADOR  � DATA   � BOPS �	MOTIVO DA ALTERACAO					  潮�
北媚哪哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北矰enis Martins �20/03/01矼elhor砊razer escala(s) de padroes secundarios 潮�
北�              �        �  --	硉endo como parametro a data de calibra-  潮�
北�              �        �  --	砪ao do instrumento que esta sendo cali-  潮�
北�              �        �  --	砨rado no momento.                        潮�
北滥哪哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function qmt140VlPs()

Local nRec
Local nOrder
Local cChave
Local lRetu 	:= .T.
LOcal cVar		:= &(readvar()) // Conteudo da variavel do campo Instr.Util.
Local nPos		:= ASCAN(aHeader,{|x| alltrim(x[2]) = "QMS_PADSEC" })
Local nPosPad 	:= ASCAN(aHeader,{|x| alltrim(x[2]) = "QMS_ESCPAD" })
Local nPosInc	:= ASCAN(aHeader,{|x| alltrim(x[2]) = "QMS_INCERT" })
Local aEscalas := {}
Local oDlgEscala
Local cEscala := ""
Local oLbx
Local cInstrQM6
Local dDataQM6
Local cRevQM6
Local cRevEsc
Local lRepro := .F.
Local cSta	:= ""
Local cSeqa	:= "00"
Local cEscalas
Local nRecsQM7
Local cRvQM6Ii

Local aArea
Local cKey
Local dDataPS
Local cQuery
Local nIndex

Private nIncert
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Verifica se mudou o Padrao Secund.  (Alterou o campo ja' digitado) �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If !Empty(oGetSec:aCols[oGetSec:oBrowse:nAt][nPos]) .and. !Empty(cVar) .and. oGetSec:aCols[oGetSec:oBrowse:nAt][nPos] <> cVar
	MessageDlg(STR0001,,3)	// "Campo n鉶 pode ser alterado. Caso desejar apagar o instrumento pressione a tecla DEL para deixar a linha em branco."
	lRetu := .F.
EndIf

If lRetu
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Verifica se o Padrao Secundario � o	�
	//� Instrumento que esta sofrendo medicao �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	oGetSec:aCols[oGetSec:oBrowse:nAt][nPos] := M->QMS_PADSEC
	If oGetSec:aCols[oGetSec:oBrowse:nAt][nPos] == cMtInstr  //M->QM6_INSTR
		MessageDlg(STR0002,,3)	//"O Padr鉶 Secund醨io n鉶 pode ser o mesmo que o instrumento que esta sofrendo a medi玢o. Escolha outro."
		lRetu := .F.
	EndIf
EndIf

If lRetu
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Verifica se o Padrao Secund.  esta' cadastrado  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	oGetSec:aCols[oGetSec:oBrowse:nAt][nPos] := M->QMS_PADSEC
	dbSelectArea("QM2")
	dbSetOrder(1)
	If !Empty(oGetSec:aCols[oGetSec:oBrowse:nAt][nPos])
		If !ExistCpo2("QM2",oGetSec:aCols[oGetSec:oBrowse:nAt][nPos],,STR0003) //"O Padrao Secundario informado nao se encontra no banco de dados. Informe um Instrumento valido."
			lRetu := .F.
		Else
			dbSeek(xFilial()+oGetSec:aCols[oGetSec:oBrowse:nAt][nPos])
			cSta := QM2->QM2_STATUS
		EndIf
	Else
		MsgInfo(STR0028,STR0029) //STR0028  "Informe/escolha um padrao secundario valido" # STR0029 "Padroes Secundarios"
		lRetu := .F.
	Endif
EndIf
If lRetu
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Verifica se o Padrao Secundario � v爈ido �
	//� Data de validade e Aprovado				 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	DbSelectArea("QM2")
	nOrder := QM2->(IndexOrd())
	nRec := QM2->(recno())
	DbSetOrder(1)
	DbSeek(xFilial("QM2")+oGetSec:aCols[oGetSec:oBrowse:nAt][nPos])

	If QM2->QM2_VALDAF < ddatabase .or. QM2->QM2_STATUS = "R"
		MessageDlg(STR0005,,3)	//"Padr鉶 Secund醨io com validade expirada ou reporvado. Informe um Padr鉶 v醠ido."
		lRetu := .F.
	EndIf
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Verifica se o Padrao Secundario pertence ao grupo �
//� de Tipos Secund爎ios.							  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If lRetu
	If !A140LISTPS()
		MessageDlg(STR0006,,3)	//"Instrumento n刼 pertence ao grupo de Padr鮡s Secundarios"
		lRetu := .F.
	EndIf
EndIf

If !lRetu
	M->QMS_PADSEC	:= Criavar("QMS_PADSEC")
	oGetSec:aCols[oGetSec:oBrowse:nAt][nPos] := Criavar("QMS_PADSEC")
Else
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//矼onta tabela de escalas com incerteza do instrumento selecionado�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	dbSelectArea("QM6")
	dbSetOrder(4)
	If QM6->(DbSeek(xFilial("QM6")+QM2->QM2_INSTR))

		aArea := GetArea()

		cKey := "QM6_FILIAL+QM6_INSTR+QM6_REVINV+QM6_DATINV"

		cQuery := "SELECT QM6.QM6_FILIAL,QM6.QM6_INSTR,QM6.QM6_REVINV,QM6.QM6_DATA,QM6.QM6_DATINV,QM6.QM6_REVINS,QM6.QM6_LAUDO,QM6.QM6_CSEQ "
		cQuery += " FROM " + RetSqlName("QM6") + " QM6"
		cQuery += " JOIN " + RetSqlName("QM2") + " QM2 ON"
		cQuery += " QM2.QM2_FILIAL = '" + xFilial("QM2") + "' AND "
		cQuery += " QM2.QM2_INSTR = '"  + QM2->QM2_INSTR +"'"
		cQuery += " WHERE QM6.QM6_FILIAL = '" + xFilial("QM6") + "' AND "
		cQuery += " QM6.QM6_INSTR = QM2.QM2_INSTR AND "
		cQuery += " QM6.D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY " + SqlOrder(cKey)

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QM6TRB", .F., .T.)

		TcSetField("QM6TRB","QM6_DATA","D",8,0)

		dbSelectArea("QM6TRB")

		dDataPS := QM6TRB->QM6_DATA

		While !Eof()
			If DtoS(QM6TRB->QM6_DATA) <= DtoS(dMtData) //dDataPS
				cInstrQM6:= QM6TRB->QM6_INSTR
				dDataQM6 := QM6TRB->QM6_DATA
				cRevQM6  := QM6TRB->QM6_REVINS
				cSeqa	 := QM6TRB->QM6_CSEQ
				Exit
			Endif
			dbSkip()
		Enddo

		If QM6TRB->QM6_FILIAL+QM6TRB->QM6_INSTR == QM2->QM2_FILIAL+QM2->QM2_INSTR
			If !QMTXSTAT(cSta)
				MessageDlg(STR0027,,3) //"Instrumento com Status Reprovado"
				lRepro := .T.
			Endif
		Endif
		dbCloseArea()
		RestArea(aArea)
		If !lRepro
			If cInstrQM6 <> NIL
				QM7->(DbSetOrder(1))
				If QM7->(DbSeek(xFilial("QM7")+cInstrQM6+cRevQM6+DtoS(dDataQM6)))

					nRecsQM7 := QM7->(RecNo())
					cSeqa	 := QM7->QM7_CSEQ
				//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
				//矻ocaliza a ultima sequencia de calibracao na mesma data�
				//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
					While cInstrQM6+cRevQM6+DtoS(dDataQM6) == QM7->QM7_INSTR+QM7->QM7_REVINS+;
						DtoS(QM7->QM7_DATA)
						If Val(QM7->QM7_CSEQ) > Val(cSeqa)
							nRecsQM7 := QM7->(RecNo())
							cSeqa	 := QM7->QM7_CSEQ
						Endif
						QM7->(dbSkip())
					Enddo
					QM7->(dbGoTo(nRecsQM7))
					cEscalas := ""
					While cInstrQM6+cRevQM6+DtoS(dDataQM6) == QM7->QM7_INSTR+QM7->QM7_REVINS+;
						DtoS(QM7->QM7_DATA)
						cChave := QM7->QM7_INSTR+QM7->QM7_REVINS+DtoS(QM7->QM7_DATA)+;
								  QM7->QM7_CSEQ+QM7->QM7_ESCALA
						nRecsQM7 := QM7->(RecNo())
						If QM7->QM7_ESCALA == cEscalas
							QM7->(dbSkip())
							nRecsQM7 := QM7->(RecNo())
							Loop
						Endif
						cEscalas := QM7->QM7_ESCALA
						nIncert := SuperVal(QM7->QM7_INCERT)
						Do while cChave == QM7->QM7_INSTR+QM7->QM7_REVINS+;
							DtoS(QM7->QM7_DATA)+QM7->QM7_CSEQ+QM7->QM7_ESCALA
							cEscala := QM7->QM7_ESCALA
							cRevEsc := QM7->QM7_REVESC
							If ( SuperVal(QM7->QM7_INCERT) > nIncert )
								nIncert := SuperVal(QM7->QM7_INCERT)
							EndIf
							QM7->(DbSkip())
						Enddo
						nIncert := Str(nIncert)
						QA_ENUM("nIncert")
						Aadd(aEscalas,{cEscala,nIncert,cRevEsc})
						Aadd(aGrvSeq,{cInstrQM6,cRevQM6,cSeqa,dDataQM6,nIncert,oCbxEsc:aItems[oCbxEsc:nAt],oCbxPad:aItems[oCbxPad:nAt]})
						dbSelectArea("QM7")
						dbGoTo(nRecsQM7)
						dbSkip()
					EndDo
				Else
					MessageDlg(OemToAnsi(STR0007),,3)
					M->QMS_PADSEC	:= Criavar("QMS_PADSEC")
					oGetSec:aCols[oGetSec:oBrowse:nAt][nPos]	:= Criavar("QMS_PADSEC")
					lRetu := .F.
				Endif
			Else
				MessageDlg(OemToAnsi(STR0025),,3)
				M->QMS_PADSEC	:= Criavar("QMS_PADSEC")
				oGetSec:aCols[oGetSec:oBrowse:nAt][nPos] := Criavar("QMS_PADSEC")
				lRetu := .F.
			EndIf
		Else
			M->QMS_PADSEC	:= Criavar("QMS_PADSEC")
			oGetSec:aCols[oGetSec:oBrowse:nAt][nPos] := Criavar("QMS_PADSEC")
		Endif
	Else
		MessageDlg(STR0007,,3)	//"O Instrumento informado ainda n鉶 sobreu medi玢o, sendo assim n鉶 poder� ser utilizado nesta op玢o. Inclua medi珲es para o mesmo primeiro."
		M->QMS_PADSEC	:= Criavar("QMS_PADSEC")
		oGetSec:aCols[oGetSec:oBrowse:nAt][nPos] := Criavar("QMS_PADSEC")
		lRetu := .F.
	Endif
EndIf

If ( !empty(aEscalas) )

	DEFINE MSDIALOG oDlgEscala TITLE STR0009 FROM 10,10 TO 135,335 ; //"Escalas"
	OF GetWndDefault() PIXEL

	@	05, 05 BROWSE oLbx SIZE 120, 55 OF oDlgEscala PIXEL;
	ON DBLCLICK ( a140RetEsc( aEscalas,oLbx,nPosPad, nPosInc, cRevQM6, oGetSec ),oDlgEscala:End() )

	oLbx:nClrBackFocus := GetSysColor( 13 )
	oLbx:nClrForeFocus := GetSysColor( 14 )
	oLbx:cToolTip := STR0010 //"Duplo click confirmar a escolha"
	oLbx:SetArray(aEscalas)
	ADD COLUMN TO oLbx HEADER STR0011 OEM DATA {|| aEscalas[oLbx:nAt,1] } ALIGN LEFT SIZE 100 PIXELS  //"Escala"
	ADD COLUMN TO oLbx HEADER STR0012 OEM DATA {|| aEscalas[oLbx:nAt,2] } ALIGN LEFT SIZE 40 PIXELS //"Incerteza"

	DEFINE SBUTTON FROM 04, 130 TYPE 1 ENABLE OF oDlgEscala Action (a140RetEsc( aEscalas,oLbx, nPosPad, nPosInc, cRevQM6, oGetSec ),oDlgEscala:End())
	DEFINE SBUTTON FROM 17, 130 TYPE 2 ENABLE OF oDlgEscala Action (oDlgEscala:End())

	ACTIVATE MSDIALOG oDlgEscala CENTERED

	If Empty(oGetSec:aCols[oGetSec:oBrowse:nAt][nPosPad])
	   lRetu := .F.
	Endif
Endif

Return(lRetu)

/*/
antigo A140VlIU
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o	 硄mt140VlIU� Autor � Wanderley Goncalves   � Data � 10/03/98 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Valida campo de Instrumento Utilizado					  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � QMTA140 - E' chamada no X3_VALID do cpo. QMI_INSUT  - SX3  潮�
北媚哪哪哪哪牧哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� PROGRAMADOR  � DATA   � BOPS �	MOTIVO DA ALTERACAO					  潮�
北媚哪哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北矷uri Seto     �01/09/00� 5874 矨certo p/ mostrar todas escalas do I.U. 潮�
北矰enis Martins �20/03/01矼elhor砊razer escala(s) de instrumentos utiliza潮�
北�              �        �  --	 砫os tendo como parametro a data de cali-潮�
北�              �        �  --	 砨racao do instrumento que esta sendo ca-潮�
北�              �        �  --	 砽ibrado no momento.                     潮�
北矰enis Martins �13/03/02矼elhor矼elhora de performance utilizacao de    潮�
北�              �        �  --	 硄uery para ambiente top.                潮�
北滥哪哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function qmt140VlIU()
Local nRec
Local nOrder
Local cChave
Local lRetu 	:= .t.
Local nI 		:= 0
Local cVar		:= &(readvar()) // Conteudo da variavel do campo Instr.Util.
Local nPos		:= ASCAN(aHeader,{|x| alltrim(x[2]) = "QMI_INSUT" })
Local nPosPad	:= ASCAN(aHeader,{|x| alltrim(x[2]) = "QMI_ESCPAD" })
Local nPosInc	:= ASCAN(aHeader,{|x| alltrim(x[2]) = "QMI_INCERT" })
Local aEscalas := {}
Local cEscala	:= ""
Local oDlgEscala
Local oLbx
Local cInstrQM6
Local dDataQM6
Local cRevQM6
Local cRevEsc
Local cSeqa	:= "00"
Local nRecsQM7
Local cSta := ""
Local lRepro := .F.
Local cRvQM6Ii := ""

Local aArea
Local cKey
Local nIndex
Local cQuery


Private nIncert

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Verifica se mudou o Instr.Utilizado (Alterou o campo ja' digitado)   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If !Empty(oGetIns:aCols[oGetIns:oBrowse:nAt][nPos]) .and. !Empty(cVar) .and. oGetIns:aCols[oGetIns:oBrowse:nAt][nPos] <> cVar
	MessageDlg(STR0013,,3)	//"Campo n鉶 pode ser alterado. Caso desejar apagar o instrumento pressione a tecla DEL para deixar a linha em branco."
	lRetu := .F.
EndIf

If lRetu
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Verifica se o Instr.Utilizado � o Instrumento �
	//� que esta sofrendo medicao 					  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	oGetIns:aCols[oGetIns:oBrowse:nAt][nPos] := M->QMI_INSUT
	If oGetIns:aCols[oGetIns:oBrowse:nAt][nPos] == cMtInstr
		MessageDlg(STR0014,,3)	//"Instrumento Utilizado n鉶 pode ser o mesmo instrumento que esta sofrendo a medi玢o. Escolha outro."
		lRetu := .F.
	EndIf
EndIf

If lRetu
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Verifica se o Instr.Utilizado esta' cadastrado  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	oGetIns:aCols[oGetIns:oBrowse:nAt][nPos] := M->QMI_INSUT
	dbSelectArea("QM2")
	QM2->(dbSetOrder(1))
	If !Empty(oGetIns:aCols[oGetIns:oBrowse:nAt][nPos])
		If !dbSeek(xFilial("QM2")+oGetIns:aCols[oGetIns:oBrowse:nAt][nPos])
		    lRetu := .F.
	    	MessageDlg(STR0015,,3) //"O Instrumento informado n鉶 se encontra no banco de dados. Informe um Instrumento v醠ido."
		Else
			cSta := QM2->QM2_STATUS
		Endif
	Endif
EndIf

If lRetu
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Verifica se o Instr.Utilizado ja' existe        �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	For nI := 1 to len(oGetIns:aCols)
		If !oGetIns:aCols[nI][len(aHeader)+1]   // Verifica se ja foi deletado
			If cVar == oGetIns:acols[nI][nPos] .and. nI <> n // Se ja' existir este padrao sec.
				MessageDlg(STR0016,,3)	//"Instrumento Utilizado j� relacionado a esta medi玢o. Informe outro."
				lRetu := .F.
			EndIf
		EndIf
	Next nI
EndIf

If lRetu
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Verifica se o Instr.Utilizado � v爈ido �
	//� Data de validade e Aprovado			   �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	DbSelectArea("QM2")
	nOrder := QM2->(IndexOrd())
	nRec := QM2->(recno())
	DbSetOrder(1)
	DbSeek(xFilial("QM2")+oGetIns:aCols[oGetIns:oBrowse:nAt][nPos])
	If QM2->QM2_VALDAF < ddatabase .or. QM2->QM2_STATUS = "R"
		MessageDlg(STR0017,,3)	//"Instrumento com validade expirada ou reporvado. Informe um Instrumento v醠ido."
		lRetu := .F.
	EndIf
EndIf

If !lRetu
	M->QMI_INSUT	:= CriaVar("QMI_INSUT")
	oGetIns:aCols[oGetIns:oBrowse:nAt][nPos] := CriaVar("QMI_INSUT")
Else
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//矼onta tabela de escalas com incerteza do instrumento selecionado�
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	dbSelectArea("QM6")
	dbSetOrder(4)
	If QM6->(DbSeek(xFilial("QM6")+QM2->QM2_INSTR))
		aArea := GetArea()

		cKey := "QM6_FILIAL+QM6_INSTR+QM6_REVINV+QM6_DATINV"

		cQuery := "SELECT QM6.QM6_FILIAL,QM6.QM6_INSTR,QM6.QM6_REVINV,QM6.QM6_DATA,QM6.QM6_DATINV,QM6.QM6_REVINS,QM6.QM6_LAUDO,QM6.QM6_CSEQ "
		cQuery += " FROM " + RetSqlName("QM6") + " QM6"
		cQuery += " JOIN " + RetSqlName("QM2") + " QM2 ON"
		cQuery += " QM2.QM2_FILIAL = '" + xFilial("QM2") + "' AND"
		cQuery += " QM2.QM2_INSTR  = '" + QM2->QM2_INSTR + "'"
		cQuery += " WHERE QM6.QM6_FILIAL = '" + xFilial("QM6") + "' AND"
		cQuery += " QM6.QM6_INSTR = QM2.QM2_INSTR AND"
		cQuery += " QM6.D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY " + SqlOrder(cKey)

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QM6TRB", .F., .T.)

		TcSetField("QM6TRB","QM6_DATA","D",8,0)

		dbSelectArea("QM6TRB")

		dDataPS := QM6TRB->QM6_DATA

		While !Eof()
			If DtoS(QM6TRB->QM6_DATA) <= DtoS(dMtData) //dDataPS
				cInstrQM6:= QM6TRB->QM6_INSTR
				dDataQM6 := QM6TRB->QM6_DATA
				cRevQM6  := QM6TRB->QM6_REVINS
				cSeqa	 := QM6TRB->QM6_CSEQ
				Exit
			Endif
			dbSkip()
		Enddo

		If QM6TRB->QM6_FILIAL+QM6TRB->QM6_INSTR == QM2->QM2_FILIAL+QM2->QM2_INSTR
			If !QMTXSTAT(cSta)
				MessageDlg(STR0027,,3) //"Instrumento com Status Reprovado"
				lRepro := .T.
			Endif
		Endif
		dbCloseArea()
		RestArea(aArea)

		If !lRepro
			If cInstrQM6 <> NIL
				QM7->(DbSetOrder(1))
				If QM7->(DbSeek(xFilial("QM7")+cInstrQM6+cRevQM6+DtoS(dDataQM6)))

					nRecsQM7 := QM7->(RecNo())
					cSeqa	 := QM7->QM7_CSEQ
				//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
				//矻ocaliza a ultima sequencia de calibracao na mesma data�
				//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
					While cInstrQM6+cRevQM6+DtoS(dDataQM6) == QM7->QM7_INSTR+QM7->QM7_REVINS+;
						DtoS(QM7->QM7_DATA)
						If Val(QM7->QM7_CSEQ) > Val(cSeqa)
							nRecsQM7 := QM7->(RecNo())
							cSeqa	 := QM7->QM7_CSEQ
						Endif
						QM7->(dbSkip())
					Enddo
					QM7->(dbGoTo(nRecsQM7))
					cEscalas := ""
					While cInstrQM6+cRevQM6+DtoS(dDataQM6) == QM7->QM7_INSTR+QM7->QM7_REVINS+;
						DtoS(QM7->QM7_DATA)
						cChave := QM7->QM7_INSTR+QM7->QM7_REVINS+DtoS(QM7->QM7_DATA)+;
								  QM7->QM7_CSEQ+QM7->QM7_ESCALA
						nRecsQM7 := QM7->(RecNo())
						If QM7->QM7_ESCALA == cEscalas
							QM7->(dbSkip())
							nRecsQM7 := QM7->(RecNo())
							Loop
						Endif
						cEscalas := QM7->QM7_ESCALA
						nIncert := SuperVal(QM7->QM7_INCERT)
						Do while cChave == QM7->QM7_INSTR+QM7->QM7_REVINS+;
							DtoS(QM7->QM7_DATA)+QM7->QM7_CSEQ+QM7->QM7_ESCALA
							cEscala := QM7->QM7_ESCALA
							cRevEsc := QM7->QM7_REVESC
							If ( SuperVal(QM7->QM7_INCERT) > nIncert )
								nIncert := SuperVal(QM7->QM7_INCERT)
							EndIf
							QM7->(DbSkip())
						Enddo
						nIncert := Str(nIncert)
						QA_ENUM("nIncert")
						Aadd(aEscalas,{cEscala,nIncert,cRevEsc})
						Aadd(aGrvSeq,{cInstrQM6,cRevQM6,cSeqa,dDataQM6,nIncert,oCbxEsc:aItems[oCbxEsc:nAt],oCbxPad:aItems[oCbxPad:nAt]})
						dbSelectArea("QM7")
						dbGoTo(nRecsQM7)
						dbSkip()
					EndDo
				Else
					MessageDlg(OemToAnsi(STR0007),,3)
					M->QMI_INSUT	:= Criavar("QMI_INSUT")
					oGetIns:aCols[oGetIns:oBrowse:nAt][nPos]	:= Criavar("QMI_INSUT")
					lRetu := .F.
				Endif
			Else
				MessageDlg(OemToAnsi(STR0025),,3)
				M->QMI_INSUT	:= Criavar("QMI_INSUT")
				oGetIns:aCols[oGetIns:oBrowse:nAt][nPos] := Criavar("QMI_INSUT")
				lRetu := .F.
			EndIf
		Else
			M->QMI_INSUT	:= Criavar("QMI_INSUT")
			oGetIns:aCols[oGetIns:oBrowse:nAt][nPos] := Criavar("QMI_INSUT")
		Endif
	Else
		MessageDlg(STR0007,,3)	//"O Instrumento informado ainda n鉶 sobreu medi玢o, sendo assim n鉶 poder� ser utilizado nesta op玢o. Inclua medi珲es para o mesmo primeiro."
		M->QMI_INSUT	:= Criavar("QMI_INSUT")
		oGetIns:aCols[oGetIns:oBrowse:nAt][nPos] := Criavar("QMI_INSUT")
		lRetu := .F.
	Endif
EndIf

If ( !Empty(aEscalas) )

	DEFINE MSDIALOG oDlgEscala TITLE STR0009 FROM 10,10 TO 135,335 ;  //"Escalas"
	OF GetWndDefault() PIXEL

	@	05, 05 BROWSE oLbx SIZE 120, 55 OF oDlgEscala PIXEL;
	ON DBLCLICK ( a140RetEsc( aEscalas,oLbx,nPosPad,nPosInc,cRevQM6,oGetIns ),oDlgEscala:End() )

	oLbx:nClrBackFocus := GetSysColor( 13 )
	oLbx:nClrForeFocus := GetSysColor( 14 )
	oLbx:cToolTip := STR0010 //"Duplo click confirmar a escolha"
	oLbx:SetArray(aEscalas)
	ADD COLUMN TO oLbx HEADER STR0011 OEM DATA {|| aEscalas[oLbx:nAt,1] } ALIGN LEFT SIZE 100 PIXELS //"Escala"
	ADD COLUMN TO oLbx HEADER STR0023 OEM DATA {|| aEscalas[oLbx:nAt,2] } ALIGN LEFT SIZE 40 PIXELS //"Incerteza"

	DEFINE SBUTTON FROM 05, 130 TYPE 1 ENABLE OF oDlgEscala Action (a140RetEsc( aEscalas,oLbx,nPosPad,nPosInc,cRevQM6,oGetIns ),oDlgEscala:End())
	DEFINE SBUTTON FROM 17, 130 TYPE 2 ENABLE OF oDlgEscala Action (oDlgEscala:End())

	ACTIVATE MSDIALOG oDlgEscala CENTERED

	If Empty(oGetIns:aCols[oGetIns:oBrowse:nAt][nPosPad])
	   lRetu := .F.
	Endif
Endif

Return lRetu

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o	 矨140ChkIDm� Autor � Wanderley Goncalves Jr� Data � 6/18/1999潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 矯heca se existe medicao externa e verifica se usuario digi- 潮�
北�			 硉ou a incerteza e o desvio medio.       .					  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砃enhum 													  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno	 矱xpL1 - .T. Digitou e .F. nao digitou						  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so		 矨140GrvAll() 												  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function A140ChkIDm()
Local lRet	:= .T.
Local nLoop := 0

For nLoop := 1 To Len(aMedicoes)
	If aMedicoes[nLoop,nPosGer,1,4] == "E" .and. empty(aMedicoes[nLoop,nPosGer,1,6])
		If aMedicoes[nLoop,nPosGer,1,20] == "S"
			If Empty(aMedicoes[nLoop,nPosGer,1,9]) .Or. Empty(aMedicoes[nLoop,nPosGer,1,10])
				lRet := .F.
				Exit
			EndIf
		EndIf
	EndIf
Next nLoop

If !lRet
	MessageDlg(STR0024,,1)	//"Faltam informa鏾es nas medicoes. E obrigatorio a digita玢o do desvio medio e da incerteza encontrada."
EndIf

Return lRet
