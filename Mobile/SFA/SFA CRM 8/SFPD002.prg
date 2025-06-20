#INCLUDE "SFPD002.ch"
#include "eADVPL.ch"
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � GetPD2()            矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Tela de Consulta de Produtos                 			  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cProduto - Codigo do Produto								  潮�
北� 		 � lRet     - Retorno da Funcao   		 					  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function GetPD2(cProduto,lRet, aPrdPrefix)

Local oDlg, oProd, oDet, oPrc
Local oPesq
Local oBrwProd, oCbxOrder, oBrwPrc, oBrwDet
Local oBtnCanc, oBtnRet, oBtnBusc, oBtnSobe, oBtnDesce, oBtnDir, oBtnEsq
Local cDesc := "", cCod := "", cGrupo:="", cPesq:=Space(40)
Local lCod:=.F. , lDesc := .T.
Local nOrder:=1,  nTop:=0                        
Local aOrder := {}, aProduto := {}, aPrecos  := {}, aDetalhe := {}
Local oCol
Local cPesqFabr	:=	""
Local cPictVal	:= SetPicture("HPR","HPR_UNI")
//Variaveis de controle de tela
Local nPos		:=	0
Local nPosIni	:=	22
Local nPosBtn	:=	130
Local nSizeGet	:=	152
Local nColBrw	:=	60
Local nLinBrw    := 137

If lNotTouch
	nPosIni   := 25
	nPosBtn  := 140
	nSizeGet  := 115
	nColBrw  := 58
	nLinBrw  := 152
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//砎erifica o parametro MV_SFACPRF   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
cPesqFabr := SFGetMv("MV_SFACPRF",,"N")

AADD(aOrder,STR0001) //"Por C骴igo"
AADD(aOrder,STR0002) //"Por Descri玢o"
If cPesqFabr == "S"
	If Select("HA5")>0
		AADD(aOrder,STR0014) //"Por C騞. Forn."
	Else
		MsgAlert(STR0015+Chr(13)+Chr(10)+STR0016,STR0017)//"N鉶 ser� poss韛el a consulta por C骴. do Fabr."###"Tabela HA5 - Forn x Prod n鉶 existe!"###"Aten玢o!"		
	EndIf
EndIf

nTop := nLastProd

DEFINE DIALOG oDlg TITLE STR0003  //"Produto"

ADD FOLDER oProd CAPTION STR0006 OF oDlg //"Produtos"

@ 0,70 COMBOBOX oCbxOrder VAR nOrder ITEMS aOrder ACTION (PD2Order(@cProduto,@nTop,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet),PD2Load(@cProduto,@nTop,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet,.F.)) of oProd

nPos := nPosIni
@ nPos,1 TO (nPosBtn-5),157 CAPTION STR0006 OF oProd //"Produtos"

nPos += 10
@ nPos,3 GET oPesq VAR cPesq SIZE nSizeGet,15 OF oProd

If !lNotTouch
	nPos += 15
	@ nPos,3 BUTTON oBtnBusc CAPTION STR0007 ACTION PD2Find(@cProduto,@nTop,cPesq,aProduto, oBrwProd, @nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet, aPrdPrefix) SIZE 35,12 OF oProd //"Buscar"
	nPos += 15
	@ 60,140 BUTTON oBtnSobe CAPTION UP_ARROW SYMBOL ACTION PD2Up(@cProduto,@nTop,aProduto,oBrwProd,nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet) SIZE 13,10 OF oProd
	@ 74,140 BUTTON oBtnDir CAPTION RIGHT_ARROW SYMBOL ACTION GridRight(oBrwProd) SIZE 13,10 OF oProd
	@ 88,140 BUTTON oBtnEsq CAPTION LEFT_ARROW SYMBOL ACTION GridLeft(oBrwProd) SIZE 13,10 OF oProd
	@ 102,140 BUTTON oBtnDesce CAPTION DOWN_ARROW SYMBOL ACTION PD2Down(@cProduto,@nTop,aProduto,oBrwProd,nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet) SIZE 13,10 OF oProd
	//@ 54,3 LISTBOX oLbxProd VAR nProduto ITEMS aProduto ACTION PD2Set(@cProduto,aProduto[nProduto],aPrecos, oBrwPrc,aDetalhe, oBrwDet) SIZE 137,72 OF oProd
Else
	@ nPos,120 BUTTON oBtnBusc CAPTION STR0007 ACTION PD2Find(@cProduto,@nTop,cPesq,aProduto, oBrwProd, @nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet, aPrdPrefix) SIZE 35,12 OF oProd //"Buscar"
	nPos += 18
EndIf

@ nPos,3 BROWSE oBrwProd SIZE nLinBrw,nColBrw NO SCROLL OF oProd
SET BROWSE oBrwProd ARRAY aProduto
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 1 HEADER STR0008 WIDTH 125 //"Descri玢o"
ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 2 HEADER STR0009 WIDTH 50 //"C骴igo"


nPos := nPosIni
ADD FOLDER oDet CAPTION STR0010 ON ACTIVATE PD2SetDet(@cProduto,aProduto,oBrwProd,@nOrder,aDetalhe, oBrwDet) OF oDlg //"Detalhe"
@ nPos,1 TO (nPosBtn-5),157 CAPTION STR0010 OF oDet //"Detalhe"

nPos += 15
@ nPos,3 BROWSE oBrwDet SIZE 152,85 OF oDet
SET BROWSE oBrwDet ARRAY aDetalhe
ADD COLUMN oCol TO oBrwDet ARRAY ELEMENT 1 HEADER "" WIDTH 50
ADD COLUMN oCol TO oBrwDet ARRAY ELEMENT 2 HEADER "" WIDTH 130

nPos := nPosIni
ADD FOLDER oPrc CAPTION STR0011 ON ACTIVATE PD2SetPrc(@cProduto,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc) OF oDlg //"Pre鏾"
@ nPos,1 TO (nPosBtn-5),157 CAPTION STR0011 OF oPrc //"Pre鏾"

nPos += 15
@ nPos,3 BROWSE oBrwPrc SIZE 152,85 OF oPrc
SET BROWSE oBrwPrc ARRAY aPrecos
ADD COLUMN oCol TO oBrwPrc ARRAY ELEMENT 1 HEADER STR0012 WIDTH 40 //"Tabela"
ADD COLUMN oCol TO oBrwPrc ARRAY ELEMENT 2 HEADER STR0013 WIDTH 45 PICTURE cPictVal //"Valor"

PD2Order(@cProduto,@nTop,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet)
PD2Load(@cProduto,@nTop,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet,.T.)

@ nPosBtn,2 BUTTON oBtnCanc CAPTION STR0004 ACTION CloseDialog() SIZE 70,15 of oDlg //"Cancelar"
@ nPosBtn,77 BUTTON oBtnRet CAPTION STR0005 ACTION PD2End(lRet,@cProduto,aProduto,oBrwProd,@nOrder) SIZE 70,15 of oDlg //"Retornar"

ACTIVATE DIALOG oDlg

Return Nil
