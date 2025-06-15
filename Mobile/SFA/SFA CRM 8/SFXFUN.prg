#INCLUDE "SFXFUN.ch"
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � StoD		           �Autor: Fabio Garbin  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Converte uma string no formato (yyyymmdd) para data        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cData: Sring da data							 			  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � aScan	           �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Procura umm valor dentro de um array    			          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aArray: Array onde sera feita a procura					  ���
���			 � vPesq: valor a ser pesquisado, nIni: Posicao inicial		  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � aOrdena	           �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Ordena um array                        			          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aArray: Array que sera ordenado       					  ���
���			 � nIni: Posicao inicial		  							  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
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

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �SFConsPadrao �Autor  �                 � Data �             ���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Tela de consulta padrao                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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

DEFINE DIALOG oDlg TITLE STR0001 //"Consulta Padr�o:"
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
	MsgAlert(STR0006 + cPesq + STR0007 + aInd[nInd,1] + STR0008) //"Pesquisa "###" por "###" n�o encontrada"
Endif
aSize(aPesq,0)
SetArray(oBrwCP,aArray)

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �RetFilial �Autor  �                    � Data �             ���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Retorna a filial de uma tabela                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function RetFilial(cAlias)
Local cRetFilial := Space(2)
Local cAliasAtu  := Alias()
Local lAchouTbl  := .F.
Local cAnt		 := ""

If cAlias == "HM0" // HM0 esta como HHEMP no ADVTBL
	cAnt   := cAlias
	cAlias := "HHEMP"
EndIf
	
//��������������������������������������������������������������Ŀ
//� Se a tabela for compartilhada entre empresas, devera fazer o �
//� seek com "@@" no ADV_TBL                                     �
//����������������������������������������������������������������
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


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Mod       �Autor  �Rodrigo A. Godinho  � Data �  08/28/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o resto da divisao entre dois numeros               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�nDividendo - dividendo da operacao                          ���
���          �nDivisor - divisor da operacao                              ���
�������������������������������������������������������������������������͹��
���Uso       � SFA                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function Mod(nDividendo,nDivisor)
Return nDividendo%nDivisor

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �SetPicture�Autor  �                    � Data �             ���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Monta a picture de acordo com o tamanho do campo            ���
���          �Somente para campos Numericos					              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �SfGetMv   �Autor  �Liber De Esteban    � Data �  26/09/07   ���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Retorna valor de um parametro no HCF                        ���
���          �Similar ao GetMv no Protheus                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cParametro -> Nome do Parametro                             ���
���          �lMsg -------> Indica se deve exibir mensagem quando nao     ���
���          �              encontrar o parametro passado                 ���
���          �cDefault ---> Valor default caso o parametro nao exista     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SFA                                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
		MsgAlert("Parametro " + Alltrim(cParametro) + " n�o encontrado!","Aten��o")
	EndIf
EndIf

Return cRet

/*��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �LoadStatus�Autor  �Liber De Esteban    � Data �  27/09/07   ���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Retorna o status do pedido                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cCodSt  -> Codigo status                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �cStatus -> Status por extenso                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SFA                                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TamADVC   � Autor � Liber De Esteban      � Data � 17.10.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica tamanho, decimal e tipo do campo no ADV_COLS       ���
���          �Similar ao TamSx3 no Protheus                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cCampo: 		Nome do Campo a ser pesquisado                ���
���          � nRetorna:	0, ou NIL - Retorna array com os tres valores ���
���          �          	1 - Retorna tamanho do campo                  ���
���          �          	2 - Retorna decimal do campo                  ���
���          �          	3 - Retorna tipo do campo                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � {nTamanho,nDecimal,cTipo}, dependendo do nRetorna          ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ExistCpo  � Autor � Liber De Esteban      � Data � 29.11.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna se valor passado existe no alias passado            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cAlias:	Alias para verificacao                            ���
���          � cValor:	Chave                                             ���
���          � nOrdem:	Indice (default = 1)                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lRet:	Flag indicando se encontrou o valor               ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
