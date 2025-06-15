#INCLUDE "SFPV004.ch"
Function PVQTde(oTxtQtde)
Keyboard(1,oTxtQtde)
SetFocus(oTxtQtde)
Return Nil

Function PVPrc(oTxtPrc)
Keyboard(1,oTxtPrc)
SetFocus(oTxtPrc)
Return Nil

Function PVDesc(oTxtDesc)
Keyboard(1,oTxtDesc)
SetFocus(oTxtDesc)
Return Nil

Function PVObs(cObs)
Local oObs
Local oTxtObs, oBtnRet

DEFINE DIALOG oObs TITLE STR0001 //"Obs. do Pedido"
@ 15,15 GET oTxtObs VAR cObs MULTILINE VSCROLL SIZE 156,125 of oObs
@ 142,5 BUTTON oBtnRet CAPTION STR0002 SIZE 154,12 ACTION CloseDialog() of oObs //"OK"

ACTIVATE DIALOG oObs

Return Nil


//Controla a troca da cond. de pagto
Function PVCond(aCabPed,aObj,aCmpPag,aIndPag,aColIte,aItePed,cCondInt)
Local cCondAnt := aCabPed[7,1]
Local cTabAnt  := aCabPed[8,1]
Local nTelaPed := 1
Local aFilter  := {}
Local lRecalc  := (SFGetMv("MV_SFRECPV",.F.,"F") == "T")

HA1->( dbSetOrder(1) )
HA1->( dbSeek(RetFilial("HA1") + aCabPed[3,1]+aCabPed[4,1]) )
If HA1->(FieldPos("HA1_CNDFIX")) <> 0
	If HA1->HA1_CNDFIX == 1 .And. HA1->HA1_STATUS <> "N"
		MsgAlert(STR0003,STR0004) //"A condi��o de pagto do cliente n�o poder� ser alterada"###"Condi��o Fixa"
		Return nil	
	Endif
Endif

// Ponto de Entrada criado para se passar filtro para a Consulta Padrao das Condicoes de Pagamento
If ExistBlock("SFAPV014")
	aFilter := ExecBlock("SFAPV014", .F., .F., {aCabPed})
EndIf

SFConsPadrao("HE4",aCabPed[7,1],aObj[2,1],aCmpPag,aIndPag,,aFilter)
If cCondAnt <> aCabPed[7,1]
	If !PVVldTab(aCabPed)
		aCabPed[7,1] := cCondAnt
		SetText(aObj[2,1],aCabPed[7,1])
	Else
	    //Condicao inteligente
	    If cCondInt == "T"
		    aCabPed[8,1] := RGCondInt(aCabPed[3,1],aCabPed[4,1],aCabPed[7,1])
		    SetText(aObj[2,3],aCabPed[8,1])
		    If cTabAnt <> aCabPed[8,1]
		    	lRecalc := .T.
		    EndIf
		EndIf
		If lRecalc
		    //Atualizar itens/precos
	     	PVRecalcula(aCabPed,aObj,aColIte,aItePed,nTelaPed) 
		EndIf
	Endif
Endif

Return nil


//Controla a alteracao da Tabela de Precos (atualiza os itens)
Function PVTrocaTab(aCabPed,aObj,aCmpTab,aIndTab,aColIte,aItePed,cCondInt,nTelaPed)

Local ni := 1, nItePed := 0
Local cTabAnt := aCabPed[8,1]
Local cResp:="Nao"
Local lVrfItem	:= .T.

SFConsPadrao("HTC",aCabPed[8,1],aObj[2,3],aCmpTab,aIndTab,)

// Ponto de Entrada no Inicio da Funcao que Troca a Tabela de Preco
If ExistBlock("SFAPV016")
	lVrfItem := ExecBlock("SFAPV016", .F., .F., {aCabPed,aObj})
	If !lVrfItem
		Return nil
	EndIf
EndIf

If cTabAnt <> aCabPed[8,1]
	If !PVVldTab(aCabPed)
		aCabPed[8,1] := cTabAnt 
	    SetText(aObj[2,3],aCabPed[8,1])
	Endif
Endif    

If Len(aItePed) > 0 .And. cTabAnt <> aCabPed[8,1]
	cResp:=if(MsgYesOrNo(STR0007,STR0008),STR0009,STR0010) //"Esta opera��o ir� recalcular os itens do pedido. Deseja continuar?"###"Aten��o"###"Sim"###"N�o"
	If cResp == STR0010 //"N�o"
    	aCabPed[8,1] := cTabAnt  
	    SetText(aObj[2,3],aCabPed[8,1])
	Else
		PVRecalcula(aCabPed,aObj,aColIte,aItePed,nTelaPed) 
	EndIf
Endif

// Ponto de Entrada no Final da Funcao que Troca a Tabela de Preco
If ExistBlock("SFAPV008")
	ExecBlock("SFAPV008", .F., .F., {aCabPed, aObj})
EndIf
Return nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �PVTrocaTra�Autor  �Anderson            � Data �  04/06/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Efetua a escolha da Tranportadora e abre um ponto de entrada���
���          �para efetuar validacoes especificas                         ���
�������������������������������������������������������������������������͹��
���Uso       � SFA                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PvTrocaTra(cAlias,aCmpTra,aIndTra,aCabPed,aObj)

SFConsPadrao(cAlias,aCabPed[13,1],aObj[2,7],aCmpTra,aIndTra,)

// Ponto de Entrada no Final da Funcao que Troca da Trasnsportadora
If ExistBlock("SFAPV009")
	ExecBlock("SFAPV009", .F., .F., {aCabPed, aObj})
EndIf

Return Nil




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �PVVldTab  �Autor  �Rodrigo A. Godinho  � Data �  09/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Efetua a validacao da tabela de preco de acordo com a       ���
���          �condicao fixada a ela                                       ���
�������������������������������������������������������������������������͹��
���Uso       � SFA                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function PVVldTab(aCabPed)
Local lRet  := .T.
Local cCond := aCabPed[7,1]
Local cTab  := aCabPed[8,1]

If !Empty(cTab) 
	dbSelectArea("HTC")
	HTC->(dbSetOrder(1))
	If HTC->(dbSeek(RetFilial("HTC") + cTab))
		If HTC->(FieldPos("HTC_DATADE")) <> 0 .And. HTC->(FieldPos("HTC_HORADE")) <> 0 .And. HTC->(FieldPos("HTC_TPHORA")) <> 0
			If !Empty(HTC->HTC_DATADE) .And. (Date() < HTC->HTC_DATADE) .Or. (HTC->HTC_DATADE == Date() .And.  SubStr(Time(),1,5) < HTC->HTC_HORADE .And. HTC->HTC_TPHORA == "1" )
				MsgStop(STR0029,STR0013)//"A data de vig�ncia da Tabela de Pre�os n�o teve in�cio."#### "Aviso"
				lRet := .F.
			ElseIf (SubStr(Time(),1,5) < HTC->HTC_HORADE .And. HTC->HTC_TPHORA == "2")
				MsgStop(STR0030,STR0013)//"O hor�rio de vig�ncia da Tabela de Pre�os n�o teve in�cio." #### "Aviso"
				lRet := .F.			
			EndIf
		EndIf        
        If HTC->(FieldPos("HTC_DATATE")) <> 0 .And. HTC->(FieldPos("HTC_HORATE")) <> 0 .And. HTC->(FieldPos("HTC_TPHORA")) <> 0
			If !Empty(HTC->HTC_DATATE) .And. (Date() > HTC->HTC_DATATE) .Or. (HTC->HTC_DATATE == Date() .And.  SubStr(Time(),1,5) > HTC->HTC_HORATE .And. HTC->HTC_TPHORA == "1" )
			  	If MsgYesOrNo(STR0025+STR0027+cTab+" ?",STR0013)//"A data de vig�ncia da Tabela de Pre�os expirou."#### " Deseja excluir a Tabela de Pre�o "####"Aviso"
					HTC->(dbDelete())
					HTC->(dbCommit())
				EndIf
				lRet := .F.
			ElseIf (SubStr(Time(),1,5) > HTC->HTC_HORATE .And. HTC->HTC_TPHORA == "2")
				MsgStop(STR0028,STR0013)//"O hor�rio de vig�ncia da Tabela de Pre�os expirou." #### "Aviso"
				lRet := .F.			
			EndIf
		EndIf
	Else
		MsgStop(STR0026,STR0013)//"Tabela de Pre�os n�o encontrada." #### "Aviso"
		lRet := .F.
	EndIf
	
//	If !Empty(HTC->HTC_COND) .And. !Empty(cCond) .And. (HTC->HTC_COND <> cCond) .And. lRet
//		MsgStop(STR0012 + HTC->HTC_COND,STR0013) //"Condi��o de Pagto. inv�lida para esta tabela de pre�os. A condi��o v�lida �: "###"Aviso"
//		lRet := .F.
//	Endif
Endif
Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �PVSimilar �Autor  �Rodrigo de A Godinho� Data �  03/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao que apresenta a lista de produtos similares a um     ���
���          �produto especifico escolhido pelo usuario.                  ���
�������������������������������������������������������������������������͹��
���Parametros�Recebe dois parametros:                                     ���
���          �cPesq - produto selecionado pelo usuario.                   ���
���          �aPrdPrefix - array de prefixos do produto.                  ���
�������������������������������������������������������������������������͹��
���Uso       � SFA                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PVSimilar(cPesq,aColIte,aObjIte,aCabPed,cManTes,cManPrc,aPrdPrefix)
Local cPrefixo	:=	""

If !Empty(aPrdPrefix[1,1])
	If Empty(aPrdPrefix[1,3])
		cPrefixo := Replicate(aPrdPrefix[1,1], aPrdPrefix[1,2])
	Else
		cPrefixo := Replicate(aPrdPrefix[1,1], Val(aPrdPrefix[1,3]) - Len(cPesq))		
	EndIf
	If At(cPrefixo, cPesq) = 0
		cPesq := cPrefixo + cPesq
	EndIf
EndIf
If !Empty(cPesq)
	PV4_BRW_SIMILAR(cPesq,aColIte,aObjIte,aCabPed,cManTes,cManPrc,aPrdPrefix)
Else
	MsgAlert(STR0022,STR0024)//"Nenhum produto foi informado!"###"Aten��o!"
EndIf
Return nil


/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PD1Browse()         �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Monta List com Produtos              			   		  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cProduto - Codigo do Produto, aPrecos - Array dos Precos,  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function PV4_BRW_SIMILAR(cProduto,aColIte,aObjIte,aCabPed,cManTes,cManPrc,aPrdPrefix)
Local oDlg
Local oBrwProd
Local nProduto	:=	1
Local nPos 		:=	0
Local nTop		:=	0
Local oBtn
Local oUp
Local oDown
Local oCol
Local oBtnDir, oBtnEsq
Local aSimilar	:=	{}
Local aItens	:=	{}
Local cGrupo	:=	""
Local cDesc		:=	""
Local cPictVal	:= SetPicture("HPR","HPR_UNI")

PV4Load(@aSimilar,cProduto,.T.,Space(Len(HCU->HCU_COD)))

If Len(aSimilar) == 0
	MsgAlert(STR0023,STR0024)//"N�o existem similares para este produto!"###"Aten��o!"
Else
	MsgStatus(STR0001) //"Aguarde..."


	DEFINE DIALOG oDlg TITLE STR0031  //Similares"

	@ 20,1 BROWSE oBrwProd SIZE 144,88 NO SCROLL OF oDlg
	SET BROWSE oBrwProd ARRAY aSimilar 
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 1 HEADER STR0014 	WIDTH 050//"C�digo"
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 2 HEADER STR0015	WIDTH 050//"Estoque"
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 3 HEADER STR0016	WIDTH 050 PICTURE cPictVal //"Pre�o" 
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 4 HEADER STR0017	WIDTH 125//"Descri��o"
		
	If !lNotTouch
		@ 20,146 BUTTON oUp		CAPTION Chr(5) SYMBOL ACTION PV4Up(@nTop,oBrwProd,@aSimilar,@aItens) SIZE 13,10  OF oDlg
		@ 40,146 BUTTON oBtnDir	CAPTION RIGHT_ARROW SYMBOL ACTION GridRight(oBrwProd) SIZE 13,10 OF oDlg
		@ 60,146 BUTTON oBtnEsq	CAPTION LEFT_ARROW SYMBOL ACTION GridLeft(oBrwProd) SIZE 13,10 OF oDlg
		@ 80,146 BUTTON oDown	CAPTION Chr(6) SYMBOL ACTION PV4Down(@nTop,oBrwProd,@aSimilar,@aItens) SIZE 13,10 OF oDlg
	EndIf

	@ 130,15 BUTTON oBtn CAPTION STR0002 SIZE 60,15 ACTION PV4Set(aObjIte,aSimilar,(nTop+GridRow(oBrwProd)),aColIte,aCabPed,cManTes,cManPrc,aPrdPrefix) OF oDlg //"Ok"
	@ 130,80 BUTTON oBtn CAPTION STR0018 SIZE 60,15 ACTION CloseDialog() OF oDlg //"Cancelar"

	PV4Load(@aSimilar,cProduto,.T.,Space(Len(HCU->HCU_COD)))

	ClearStatus()

	ACTIVATE DIALOG oDlg
EndIf
Return nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PD1Load()           �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega List de Produto para a consulta avancada           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aSimilar  - Array dos produtos similares					  ���
���          � cProduto  - Produto chave para consulta dos similares	  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function PV4Load(aSimilar,cProduto,lFirst,cCat)
Local i			:=	0       
//Local nCargMax	:=	GridRows(oBrwProd)
Local cCateg	:=	""
Local nRecAtual	:=	0
If lFirst
	aSize(aSimilar,0)
EndIf

If Empty(cCat)
	HCV->(dbSetOrder(2))
	If HCV->(dbSeek(RetFilial("HCV") + Space(Len(HCV->HCV_GRUPO)) + cProduto ))
		cCateg := HCV->(FieldGet(HCV->(FIELDPOS("HCV_CATEGO"))))//HCV->HCV_GATEGO	
	Else
		HB1->(dbSetOrder(1))
		If HB1->(dbSeek(RetFilial("HB1") + cProduto))
			If HCV->(dbSeek(RetFilial("HCV") + HB1->HB1_GRUPO))
				cCateg := HCV->(FieldGet(HCV->(FIELDPOS("HCV_CATEGO"))))//HCV->HCV_GATEGO		
			EndIf
		EndIf
	EndIf
	
Else
	cCateg := cCat
EndIf

HCV->(dbSetOrder(1))
HCV->(dbSeek(RetFilial("HCV") + cCateg ))

While !HCV->(EOF()) .And. HCV->HCV_FILIAL == RetFilial("HCV") .And. HCV->(FieldGet(HCV->(FIELDPOS("HCV_CATEGO"))))==cCateg//HCV->HCV_CATEGO == cCateg                   
	HB1->(dbSetOrder(1))
	If !(AllTrim(Upper(HCV->HCV_CODPRO)) == AllTrim(Upper(cProduto)) .And. lFirst) .And. !Empty(HCV->HCV_CODPRO) .And. HB1->(dbSeek(RetFilial("HB1") + HCV->HCV_CODPRO))
		HB2->(dbSetOrder(1))
		HB2->(dbSeek(RetFilial("HB2") + HB1->HB1_COD))
		HPR->(dbSetOrder(1))
		HPR->(dbSeek(RetFilial("HPR") + HB1->HB1_COD))
		If PV4_VerifProd(aSimilar,HB1->HB1_COD) == 0
			aAdd(aSimilar,{HB1->HB1_COD,HB2->HB2_QTD,HPR->HPR_UNI,HB1->HB1_DESC})
		EndIF
	Else
		If !Empty(HCV->HCV_GRUPO)
			HB1->(dbSetOrder(3))
			HB1->(dbSeek(RetFilial("HB1") + HCV->HCV_GRUPO))
			While !HB1->(EOF()) .And. HB1->HB1_FILIAL == RetFilial("HB1") .And. HB1->HB1_GRUPO == HCV->HCV_GRUPO
				If !(HB1->HB1_COD == cProduto .And. lFirst)
		   			HB2->(dbSetOrder(1))
		   			HB2->(dbSeek(RetFilial("HB2") + HB1->HB1_COD))
		   			HPR->(dbSetOrder(1))
		   			HPR->(dbSeek(RetFilial("HPR") + HB1->HB1_COD))
		   			If PV4_VerifProd(aSimilar,HB1->HB1_COD) == 0
			   			aAdd(aSimilar,{HB1->HB1_COD,HB2->HB2_QTD,HPR->HPR_UNI,HB1->HB1_DESC})		
					EndIf
				EndIf
				HB1->(dbSkip())
			End
		EndIf
	EndIf		
	HCV->(dbskip())
End
HCU->(dbSetOrder(2))
If HCU->(dbSeek(RetFilial("HCU") + cCateg)) 
	While !HCU->(EOF()) .And. HCU->HCU_FILIAL == RetFilial("HCU") .And. HCU->HCU_CODPAI == cCateg
		nRecAtual := HCU->(Recno())
		PV4Load(@aSimilar,"",.F.,HCU->HCU_COD)
		HCU->(dbGoTo(nRecAtual))
		HCU->(dbSkip())
	End
EndIf
Return nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PD1Down()           �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Tratamento da navegacao do List de Produto                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aProduto - Array de Produtos								  ���
���          � cGrupo   - Codigo do grupo  								  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function PV4Down(nTop,oBrwProd,aSimilar,aTemp)
Local i	:=	0

If Len(aSimilar)>(nTop + GridRows(oBrwProd)+1) 
	aTemp := {}
	nTop += (GridRows(oBrwProd)+1)
	For i := 1 to (GridRows(oBrwProd)+1)
		If (nTop+i) > len(aSimilar)
			Exit	
		EndIf	
		aAdd(aTemp,{aSimilar[nTop+i][1],aSimilar[nTop+i][2],aSimilar[nTop+i][3],aSimilar[nTop+i][4]})
	Next   
	SetArray(oBrwProd,aTemp)
EndIf
Return 

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PD1Up()             �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Tratamento da navegacao do List de Produto                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aProduto - Array de Produtos								  ���
���          � cGrupo   - Codigo do grupo  								  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function PV4Up(nTop,oBrwProd,aSimilar,aTemp)
Local i	:=	0

aTemp := {}

If (nTop - GridRows(oBrwProd)) > 0 
	nTop -= (GridRows(oBrwProd)+1) 
	For i := 1 to (GridRows(oBrwProd)+1)
		If (nTop+i) > len(aSimilar)
			Exit	
		EndIf
		aAdd(aTemp,{aSimilar[nTop+i][1],aSimilar[nTop+i][2],aSimilar[nTop+i][3],aSimilar[nTop+i][4]})
	Next   
	SetArray(oBrwProd,aSimilar)
Else   
	nTop := 0
	For i := 1 to (GridRows(oBrwProd)+1)
		If (nTop+i) > len(aSimilar)
			Exit	
		EndIf	
		aAdd(aTemp,{aSimilar[nTop+i][1],aSimilar[nTop+i][2],aSimilar[nTop+i][3],aSimilar[nTop+i][4]})
	Next   
	SetArray(oBrwProd,aTemp)
EndIf
Return
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PD1Up()             �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Tratamento da navegacao do List de Produto                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aProduto - Array de Produtos								  ���
���          � cGrupo   - Codigo do grupo  								  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function PV4Set(aObjIte,aSimilar,nPos,aColIte,aCabPed,cManTes,cManPrc,aPrdPrefix)
aColIte[1,1] := aSimilar[nPos,1]
aColIte[2,1] := aSimilar[nPos,4]
If !Empty(aCabPed[8,1])
	dbSelectArea("HPR")
	dbSetOrder(1)
	dbSeek(RetFilial("HPR") + aSimilar[nPos,1] + aCabPed[8,1])
	If HPR->(Found()) //!Eof()
		aColIte[6,1]:=HPR->HPR_UNI
		aColIte[16,1]:=HPR->HPR_UNI
		//nDesMax:=HPR->HPR_DESMAX	
	else
		If HB1->HB1_PRV1 <> 0
			aColIte[6,1]:=HB1->HB1_PRV1 
			aColIte[16,1]:=HB1->HB1_PRV1 
		Else
			MsgStop(STR0019 + aCabPed[8,1] + "!",STR0020) //"Pre�o n�o cadastrado na tabela "###"Aviso"
			If cManPrc == "N"	//Verifica se o vendedor pode incluir o preco
				PVLimpaColIte(aColIte,aObjIte)
				Return nil			
			Endif			        
			aColIte[6,1]:=0
			aColIte[16,1]:=0
		Endif
	Endif                       
Else
	If HB1->HB1_PRV1 == 0
		MsgStop(STR0021,STR0020) //"Pre�o n�o cadastrado!"###"Aviso"
		If cManPrc == "N"	//Verifica se o vendedor pode incluir o preco
			PVLimpaColIte(aColIte,aObjIte)
			Return nil
		Endif
	Endif
	aColIte[6,1]:=HB1->HB1_PRV1
	aColIte[16,1]:=HB1->HB1_PRV1
Endif	
SetText(aObjIte[1,2],aColIte[1,1])   
SetText(aObjIte[1,3],aColIte[2,1])   
SetText(aObjIte[1,7],aColIte[6,1])   
SetFocus(aObjIte[1,5])
CloseDialog()
Return nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao �PV4_VerifProd�Autor  �Rodrigo A. Godinho  � Data �  03/30/06   ���
�������������������������������������������������������������������������͹��
���Desc.  �Verifica se um produto j� foi incluso no array do browser de   ���
���       �produtos similares.                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PV4_VerifProd(aSimilar,cProduto)
Local nRet	:=	0
Local i		:=	0

For i := 1 To Len(aSimilar)
	If aSimilar[i][1] == cProduto
		nRet := i
		Exit
	EndIf
Next

Return nRet
