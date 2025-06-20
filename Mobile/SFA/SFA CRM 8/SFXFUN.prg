#INCLUDE "SFXFUN.ch"
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � StoD		           矨utor: Fabio Garbin  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Converte uma string no formato (yyyymmdd) para data        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cData: Sring da data							 			  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function StoD(cData)
Local cDia := ""
Local cMes := ""
Local cAno := ""
Local dData := Date()

cData := AllTrim(cData)

cDia := SubStr(cData,7,2)
cMes := SubStr(cData,5,2)
cAno := SubStr(cData,3,2)

dData := CtoD(cDia + "/" + cMes + "/" + cAno)
Return dData      

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � aScan	           矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Procura umm valor dentro de um array    			          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aArray: Array onde sera feita a procura					  潮�
北�			 � vPesq: valor a ser pesquisado, nIni: Posicao inicial		  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function aScan(aArray,vPesq,nIni,nQtd)
Local i:=1
if nIni==0
	nIni:=1
Endif
if nQtd==0 .or. nQtd > len(aArray)
	nQtd:=Len(aArray)
Endif
for i:=nIni to nQtd
	if aArray[i] == vPesq
		Return Nil
	Endif
Next
Return i

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � aOrdena	           矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Ordena um array                        			          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aArray: Array que sera ordenado       					  潮�
北�			 � nIni: Posicao inicial		  							  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function aOrdena(aArray,nIni,nQtd)
Local aCopia:={}
Local i:=1, j:=1, l:=1
Local lFim:= .F.
Local oProx,oProx2

if nIni==0
	nIni:=1
Endif

if nQtd == 0 .or. nQtd > len(aArray)
	nQtd :=Len(aArray)
Endif

For i:=nIni to nQtd        
	lFim := .T.
	For j:=i to len(aCopia)
		if aArray[i] < aCopia[j]
			oProx:=aCopia[j]
			if (j+1)<=len(aCopia[j])
				oProx2:=aCopia[l+1]
			else
    			oProx2:=0
   			endif

			for l:=j to Len(aCopia)
				if l == j
					aCopia[l]:=aArray[i]
				else
					aCopia[l]:=oProx
					oProx:=oProx2    
					if (l+1)<=len(aCopia[j])
	        			oProx2:=aCopia[l+1]
	    			else
	    				oProx2:=0
	    			endif
	    		Endif
			Next               
			lFim:= .F.
			break
 
		Endif			

	Next

	if lFim
		AADD(aCopia,aArray[I])
    Else      
    	AADD(aCopia,oProx)
    Endif

Next
		
Return aCopia                      

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪哪哪勘�
北矲uncao    砈FConsPadrao 矨utor  �                 � Data �             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪哪幢�
北矰esc.     砊ela de consulta padrao                                     潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
//Function SFConsPadrao(cAlias,cVar,oObj,nIndice, aRet)  
Function SFConsPadrao(cAlias,cVar,oObj,aCamp,aInd, aRet, aFilter)
Local oDlg, oBrwCP, oBtnUp, oBtnDown, oBtnLeft, oBtnRight
Local oBtnOK, oBtnCanc, oBtnPesq,oInd,oPesq
Local cPesq:=""
Local aArray :={},aOrdem:={}, aCombo:= {}
Local nOrdem:=1, nTop:=0,nInd:=1, nX:=1
Local oCol

If aFilter = Nil
	aFilter := {}
EndIf

DEFINE DIALOG oDlg TITLE STR0001 //"Consulta Padr鉶:"
If lNotTouch
	@ 06,05 BROWSE oBrwCP SIZE 150,83 NO SCROLL of oDlg
Else
	@ 15,01 BROWSE oBrwCP SIZE 135,100 NO SCROLL of oDlg
EndIf

SET BROWSE oBrwCP ARRAY aArray                                    

For nI:=1 to Len(aCamp)
	ADD COLUMN oCol TO oBrwCP ARRAY ELEMENT nI HEADER aCamp[nI,1] WIDTH aCamp[nI,3]
Next                                                                    

If aInd != Nil
	For nX:=1 to Len(aInd)
		Aadd(aCombo,aInd[nX,1])
	Next
Endif

If lNotTouch

	@ 120,05 GET oPesq VAR cPesq SIZE 100,15 of oDlg
	@ 120,110 BUTTON oBtnPesq CAPTION STR0005 SIZE 40,12 ACTION CPPesq(cAlias,@cPesq,aArray,oBrwCP,@nTop,aCamp,aInd,nInd,aFilter) of oDlg //"Pesquisar"

	@ 140,05 BUTTON oBtnOK CAPTION STR0003 SIZE 45,12 ACTION CPRet(oBrwCP,aArray,@cVar,oObj, aCamp, aRet) of oDlg //"OK"
	@ 140,55 BUTTON oBtnCanc CAPTION STR0004 SIZE 45,12 ACTION CloseDialog() of oDlg //"Cancelar"
	
	@ 100,05 SAY STR0002 of oDlg //"Pesquisar por:"
	@ 095,70 COMBOBOX oInd VAR nInd ITEMS aCombo SIZE 80,35 of oDlg   
	
Else

	@ 34,140 BUTTON oBtnUp CAPTION UP_ARROW SYMBOL SIZE 12,12 ACTION CPUp(cAlias,aArray,oBrwCP,@nTop,aCamp,aInd,nInd, aFilter) of oDlg
	@ 48,140 BUTTON oBtnRight CAPTION RIGHT_ARROW SYMBOL SIZE 12,12 ACTION GridRight(oBrwCP) of oDlg
	@ 62,140 BUTTON oBtnLeft CAPTION LEFT_ARROW SYMBOL SIZE 12,12 ACTION GridLeft(oBrwCP) of oDlg
	@ 78,140 BUTTON oBtnDown CAPTION DOWN_ARROW SYMBOL SIZE 12,12 ACTION CPDown(cAlias,aArray,oBrwCP,@nTop,aCamp,aInd,nInd, aFilter) of oDlg

	@ 120,05 SAY STR0002 of oDlg //"Pesquisar por:"
	@ 120,70 COMBOBOX oInd VAR nInd ITEMS aCombo SIZE 79,50 of oDlg
	@ 132,05 GET oPesq VAR cPesq SIZE 150,15 of oDlg
	@ 146,05 BUTTON oBtnOK CAPTION STR0003 SIZE 45,12 ACTION CPRet(oBrwCP,aArray,@cVar,oObj, aCamp, aRet) of oDlg //"OK"
	@ 146,55 BUTTON oBtnCanc CAPTION STR0004 SIZE 45,12 ACTION CloseDialog() of oDlg //"Cancelar"
	@ 146,105 BUTTON oBtnPesq CAPTION STR0005 SIZE 45,12 ACTION CPPesq(cAlias,@cPesq,aArray,oBrwCP,@nTop,aCamp,aInd,nInd,aFilter) of oDlg //"Pesquisar"

EndIf

CPLoad(cAlias,aArray,oBrwCP,@nTop,aCamp,aInd,nInd, aFilter)

ACTIVATE DIALOG oDlg

Return Nil

Function CPRet(oBrwCP,aArray,cVar,oObj, aCamp, aRet)
Local nArray:=0
Local ni := 0

if Len(aArray) ==0 
	cVar:= ""
Else       
	nArray:= GridRow(oBrwCP)
	cVar:= aArray[nArray,1]
	If aRet != Nil
		aRet := Array(Len(aCamp))
		For ni := 1 To Len(aRet)
			aRet[ni,1] := aArray[nArray, ni]
		Next
	EndIf
Endif

If oObj != Nil
	SetText(oObj,cVar)
EndIf

CloseDialog()

Return Nil

Function CPDown(cAlias,aArray,oBrwCP,nTop,aCamp,aInd,nInd, aFilter)
Local nOrdem:=aInd[nInd,2]
dbSelectArea(cAlias)
dbSetOrder(nOrdem)
dbGoTo(nTop)
dbSkip(GridRows(oBrwCP))

If EOF() .Or. GridRows(oBrwCP) <> len(aArray)
	return nil
Else
   nTop := Recno()
Endif
Return CPLoad(cAlias,aArray,oBrwCP,nTop,aCamp,aInd,nInd, aFilter)

Function CPUp(cAlias,aArray,oBrwCP,nTop,aCamp,aInd,nInd, aFilter)
Local nOrdem:=aInd[nInd,2]
dbSelectArea(cAlias)
dbSetOrder(nOrdem)
dbGoTo(nTop)
dbSkip(-GridRows(oBrwCP))
if !Bof()
   nTop := Recno()
else
	//dbGoTop()
	dbSeek(RetFilial(cAlias))
    nTop := Recno()
endif
Return CPLoad(cAlias,aArray,oBrwCP,nTop,aCamp,aInd,nInd, aFilter)

Function CPLoad(cAlias,aArray,oBrwCP,nTop,aCamp,aInd,nInd, aFilter)
Local nOrdem:=If(aInd != Nil, aInd[nInd,2], 1)
Local nCargMax:=1,nX:=1,nJ:=1,nZ:=1             
Local aLocal:= {}
Local nFilField := 0
Local nPos := 0
Local cTableFil := RetFilial(cAlias)  // Filial da tabela

dbSelectArea(cAlias)
dbSetOrder(nOrdem)
If nTop == 0
	If cAlias $ "HM0/HHEMP"
		dbGoTop()
	Else
		dbSeek(cTableFil)
	EndIf
	If !Eof()
	    nTop := Recno()
	Endif
Else
	dbGoTo(nTop)
Endif
nFilField := FieldPos(cAlias + "_FILIAL")

aSize(aArray,0)       
nCargMax:=GridRows(oBrwCP)
For nX:=1 to nCargMax
	If Eof()
		Exit
	EndIf
	If cTableFil = FieldGet(nFilField) .Or. cAlias $ "HM0/HHEMP"
		// Verifica na Variavel aFilter as opcoes que serao utilizadas
		If Len(aFilter) > 0 		
			If ScanArray(aFilter,AllTrim(FieldGet(aCamp[1,2])),,,1) <= 0
				dbSkip()
				nX := nX - 1
				Loop
			EndIf
		EndIf
		AADD(aArray,Array(Len(aCamp)))
		For nZ := 1 to Len(aCamp)
			If aCamp[nZ,2] > 0 
			   aArray[Len(aArray),nZ] := FieldGet(aCamp[nZ,2])
			EndIf		
		Next
	EndIf
	dbSkip()
Next
aSize(aLocal,0)
If len(aArray) > 0
	SetArray(oBrwCP,aArray)
EndIf

Return Nil

Function CPPesq(cAlias,cPesq,aArray,oBrwCP,nTop,aCamp,aInd,nInd, aFilter)
Local nCargMax := GridRows(oBrwCP)
Local aPesq:={}     
Local nJ:=1, nZ:=1             
Local nOrdem:=aInd[nInd,2]
cPesq:=AllTrim(cPesq)

If Empty(cPesq)
	Return Nil	
EndIf

dbSelectArea(cAlias)
dbSetOrder(nOrdem)
if dbSeek(RetFilial(cAlias) + cPesq)
	aSize(aArray,0)                   
	nTop:=RecNo()
	
	CPLoad(cAlias,aArray,oBrwCP,nTop,aCamp,aInd,nInd, aFilter)
/*
	For nI:=1 to nCargMax
		if !Eof()
			// Verifica na Variavel aFilter as opcoes que serao utilizadas
			If Len(aFilter) > 0 
				If ScanArray(aFilter,AllTrim(FieldGet(aCamp[1,2])),,,1) <= 0
					dbSkip()
					Loop
				EndIf
			EndIf

			AADD(aArray,Array(Len(aCamp)))
			For nZ := 1 to Len(aCamp)
				aArray[Len(aArray),nZ] := FieldGet(aCamp[nZ,2])
			Next

			aSize(aPesq,0)
			For nJ:=1 to Len(aCamp)
				Aadd(aPesq,FieldGet(aCamp[nJ,2]))				
			Next
			AADD(aArray,Array(Len(aPesq)))
			For nZ := 1 to Len(aPesq)
			  aArray[Len(aArray),nZ] := aPesq[nZ,1]
			Next
			dbSelectArea(cAlias)
			dbSkip()
		else
			nI:=nCargMax +1
		endif          
	Next
*/
Else
	MsgAlert(STR0006 + cPesq + STR0007 + aInd[nInd,1] + STR0008) //"Pesquisa "###" por "###" n鉶 encontrada"
Endif
aSize(aPesq,0)
SetArray(oBrwCP,aArray)

Return Nil

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪哪哪勘�
北矲uncao    砇etFilial 矨utor  �                    � Data �             潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪哪幢�
北矰esc.     砇etorna a filial de uma tabela                              潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function RetFilial(cAlias)
Local cRetFilial := Space(2)
Local cAliasAtu  := Alias()
Local lAchouTbl  := .F.
Local cAnt		 := ""

If cAlias == "HM0" // HM0 esta como HHEMP no ADVTBL
	cAnt   := cAlias
	cAlias := "HHEMP"
EndIf
	
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Se a tabela for compartilhada entre empresas, devera fazer o �
//� seek com "@@" no ADV_TBL                                     �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
dbSelectArea("ADVTBL")
dbSetOrder(1)
lAchouTbl := ( (dbSeek(cEmpresa + cAlias)) .Or. (dbSeek("@@" + cAlias)) )

If lAchouTbl
	If ADVTBL->TBLTP = "2"
		cRetFilial := Space(2)
	Else
		cRetFilial := AllTrim(cFilial)
	EndIf
EndIf

If !Empty(cAliasAtu)
	dbSelectArea(cAliasAtu)
EndIf

cAlias := cAnt

Return cRetFilial


/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篎uncao    矼od       篈utor  砇odrigo A. Godinho  � Data �  08/28/06   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     砇etorna o resto da divisao entre dois numeros               罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篜arametros硁Dividendo - dividendo da operacao                          罕�
北�          硁Divisor - divisor da operacao                              罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � SFA                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function Mod(nDividendo,nDivisor)
Return nDividendo%nDivisor

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪哪哪勘�
北矲uncao    砈etPicture矨utor  �                    � Data �             潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪哪幢�
北矰esc.     矼onta a picture de acordo com o tamanho do campo            潮�
北�          砈omente para campos Numericos					              潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function SetPicture(cAlias, cFld)

Local cPict  := ""
Local nRec   := ADVCOLS->(Recno())
                       
dbSelectArea("ADVCOLS")
dbSetOrder(2)
If dbSeek(cFld)
	If ADVCOLS->FLDTYPE == "N"
		cPict := "@E " + Replicate("9", ADVCOLS->FLDLEN)
		If ADVCOLS->FLDLENDEC > 0
			cPict += "." + Replicate("9",ADVCOLS->FLDLENDEC)
		Endif
	EndIf
Else
	Alert("Campo " + Alltrim(cFld) + " nao encontrado no dicionario de dados")
EndIf
ADVCOLS->(dbGoTo(nRec))

Return cPict

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪哪哪勘�
北矲uncao    砈fGetMv   矨utor  矻iber De Esteban    � Data �  26/09/07   潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪哪幢�
北矰esc.     砇etorna valor de um parametro no HCF                        潮�
北�          砈imilar ao GetMv no Protheus                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砪Parametro -> Nome do Parametro                             潮�
北�          砽Msg -------> Indica se deve exibir mensagem quando nao     潮�
北�          �              encontrar o parametro passado                 潮�
北�          砪Default ---> Valor default caso o parametro nao exista     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � SFA                                                        潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function SFGetMv(cParametro,lMsg,cDefault)
//Todos os parametro no SFA sao tipo caracter
Local	cRet	 := ""
Default	lMsg 	 := .F.
Default	cDefault := ""

If HCF->(dbSeek(RetFilial("HCF") + cParametro))
	cRet := Alltrim(HCF->HCF_VALOR)
Else
	cRet := cDefault
	If lMsg
		MsgAlert("Parametro " + Alltrim(cParametro) + " n鉶 encontrado!","Aten玢o")
	EndIf
EndIf

Return cRet

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪哪哪勘�
北矲uncao    矻oadStatus矨utor  矻iber De Esteban    � Data �  27/09/07   潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪哪哪幢�
北矰esc.     砇etorna o status do pedido                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砪CodSt  -> Codigo status                                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   砪Status -> Status por extenso                               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � SFA                                                        潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function LoadStatus(cCodSt)
Local cStatus := ""

//Verifica se status eh parcial
If Len(Alltrim(cCodSt)) > 1 .And. SubStr(cCodSt,1,1) = "P"
	cStatus := "Parc. "
EndIf

//Define Status
If At("A", cCodSt) > 0
	cStatus += "Aberto"
ElseIf At("BE", cCodSt) > 0
	cStatus += "Bloqueado Estoque"
ElseIf At("BC", cCodSt) > 0
	cStatus += "Bloqueado Credito"
ElseIf At("E", cCodSt) > 0
	cStatus += "Encerrado"
ElseIf At("L", cCodSt) > 0
	cStatus += "Liberado"
ElseIf At("R", cCodSt) > 0
	cStatus += "Residuo"
ElseIf At("P", cCodSt) > 0
	cStatus += "Transmitido"
ElseIf At("N", cCodSt) > 0
	cStatus := "Novo"
ElseIf At("BS", cCodSt) > 0
	cStatus := "Bloqueado SFA"
ElseIf At("B", cCodSt) > 0
	cStatus += "Bloqueado"
Else
	cStatus := "Indefinido"
EndIf

Return cStatus

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    砊amADVC   � Autor � Liber De Esteban      � Data � 17.10.07 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 砎erifica tamanho, decimal e tipo do campo no ADV_COLS       潮�
北�          砈imilar ao TamSx3 no Protheus                               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cCampo: 		Nome do Campo a ser pesquisado                潮�
北�          � nRetorna:	0, ou NIL - Retorna array com os tres valores 潮�
北�          �          	1 - Retorna tamanho do campo                  潮�
北�          �          	2 - Retorna decimal do campo                  潮�
北�          �          	3 - Retorna tipo do campo                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   � {nTamanho,nDecimal,cTipo}, dependendo do nRetorna          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function TamADVC(cCampo,nRetorna)
Local aRet
Local uRet
Local nRec := ADVCOLS->(Recno())
DEFAULT nRetorna := 0
cCampo := Upper(cCampo)

dbSelectArea("ADVCOLS")
dbSetOrder(2)
If dbSeek(cCampo)
	aRet := {ADVCOLS->FLDLEN,ADVCOLS->FLDLENDEC,ADVCOLS->FLDTYPE}
	If nRetorna > 0
		uRet := aRet[nRetorna]
	Else
		uRet := aRet
	EndIf
Else
	Alert("Campo " + Alltrim(cCampo) + " nao encontrado no dicionario de dados")
EndIf

dbSetOrder(1)
ADVCOLS->(dbGoTo(nRec))

Return(uRet)

/*苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    矱xistCpo  � Autor � Liber De Esteban      � Data � 29.11.07 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 砇etorna se valor passado existe no alias passado            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cAlias:	Alias para verificacao                            潮�
北�          � cValor:	Chave                                             潮�
北�          � nOrdem:	Indice (default = 1)                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   � lRet:	Flag indicando se encontrou o valor               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function ExistCpo(cAlias,cValor,nOrdem)
Local cAliasAtu	:= Alias()
Local lRet 		:= .T.
DEFAULT nOrdem	:= 01
dbselectArea(cAlias)
dbSetOrder(nOrdem)
If dbSeek(RetFilial(cAlias)+cValor)
	lRet := .T.
Else
	lRet := .F.
EndIf
If !Empty(cAliasAtu)
	dbSelectArea(cAliasAtu)
EndIf
Return lRet
