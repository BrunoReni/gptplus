#INCLUDE "FDPD102.ch"
#include "eADVPL.ch"
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � PD2Load()           矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Carrega List de Produto para a consulta avancada           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aProduto, nProduto - Array e Posicao de Produtos			  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function PD2Load(cProduto,nTop,aProduto,oBrwProd,nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet)
Local nI:=0
Local nCargMax:=0
HB1->(dbSetOrder(nOrder))
if nTop == 0 
  HB1->(dbGoTop())
  if !HB1->(Eof())
    nTop := HB1->(Recno())
  endif
else
  HB1->(dbGoTo(nTop))
endif
aSize(aProduto,0)
//nCargMax:=GetListRows(oBrwProd)
nCargMax:=GridRows(oBrwProd)
For nI:=1 to nCargMax
   if nI > nCargMax
   	  break
   Endif
   if !HB1->(Eof()) 
	  if nOrder == 1
	  	AADD(aProduto,{AllTrim(HB1->B1_COD),AllTrim(HB1->B1_DESC)})
	  Else
	  	AADD(aProduto,{AllTrim(HB1->B1_DESC),AllTrim(HB1->B1_COD)})
	  Endif
   else
	  break
   endif
   HB1->(dbSkip())     
Next
SetArray(oBrwProd,aProduto)
Return PD2Set(@cProduto,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet)

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � PD2Down()           矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Tratamento da navegacao do List de Produto                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aProduto - Array de Produtos								  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function PD2Down(cProduto,nTop,aProduto,oBrwProd,nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet)


HB1->(dbGoTo(nTop))
//HB1->(dbSkip(GetListRows(oBrwProd)))
HB1->(dbSkip(GridRows(oBrwProd)))
if !HB1->(Eof()) 
   nTop := HB1->(Recno())
else
   return nil
endif     
PD2Load(@cProduto,@nTop,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet)
Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � PD2Up()             矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Tratamento da navegacao do List de Produto                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aProduto - Array de Produtos								  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function PD2Up(cProduto,nTop,aProduto,oBrwProd,nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet)

HB1->(dbGoTo(nTop))
HB1->(dbSkip(-GridRows(oBrwProd)))
if !HB1->(Bof()) 
   nTop := HB1->(Recno())
else
	HB1->(dbGoTop())
    nTop := HB1->(Recno())
endif
PD2Load(@cProduto,@nTop,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet)
Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � PD2Set()            矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Tratamento da navegacao do List de Produto                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cProduto - Codgio do Produto, cDesc - Descr. do Produto	  潮�
北�          � aPrecos  - Array de Precos								  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function PD2Set(cProduto,aProduto,oBrwProd,nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet)
Local nLinha:=GridRow(oBrwProd)

HB1->(dbSetOrder(nOrder))
HB1->(dbSeek(aProduto[nLinha,1]))
cProduto := HB1->B1_COD

aSize(aPrecos,0)
HPR->(dbSeek(cProduto))
While (!HPR->(Eof()) .and. HPR->PR_PROD == cProduto)
  AADD(aPrecos,{ HPR->PR_TAB, HPR->PR_UNI } )
  HPR->(dbSkip())
end

SetArray(oBrwPrc,aPrecos)

aSize(aDetalhe,0)
AADD(aDetalhe,{ STR0001, HB1->B1_GRUPO } ) //"Grupo: "
AADD(aDetalhe,{ STR0002, HB1->B1_COD } ) //"C骴igo: "
AADD(aDetalhe,{ STR0003, HB1->B1_DESC } ) //"Descri玢o: "
AADD(aDetalhe,{ STR0004, HB1->B1_UM } ) //"Unidade: "
AADD(aDetalhe,{ STR0005, HB1->B1_QE } ) //"Qtd.Emb.: "
AADD(aDetalhe,{ STR0006, HB1->B1_PE } ) //"Entr.: "
AADD(aDetalhe,{ STR0007, HB1->B1_PICM } ) //"ICMS: "
AADD(aDetalhe,{ STR0008, HB1->B1_IPI } ) //"IPI: "
AADD(aDetalhe,{ STR0009, HB1->B1_EST } ) //"Estoque: "
SetArray(oBrwDet,aDetalhe)
nLastProd := HB1->(Recno())

Return nil
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � PD2Order()          矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Carrega List de Produtos na ordem desejada                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cProduto - Codigo do Produtos							  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function PD2Order(cProduto,nTop,aProduto,oBrwProd,nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet)
Local oCol
GridReset(oBrwProd)
nTop:=0     
PD2Load(@cProduto,@nTop,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet)
if nOrder==1
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 1 HEADER STR0010 WIDTH 50 //"C骴igo"
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 2 HEADER STR0011 WIDTH 125 //"Descri玢o"
Else
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 1 HEADER STR0011 WIDTH 125 //"Descri玢o"
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 2 HEADER STR0010 WIDTH 50 //"C骴igo"
Endif	

Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � PD2Find()           矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Busca do Produto								              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cProduto - Codigo do Produto								  潮�
北�          � aControls - Array de Controles							  潮�
北�          � lCodigo - Busca por Codigo (T ou F) 						  潮�
北�          � aPrecos - Array de Precos								  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function PD2Find(cProduto,nTop,cPesq,aProduto,oBrwProd, nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet, aPrdPrefix)
Local cPrefixo := ""
cPesq:=Upper(AllTrim(cPesq))

If !Empty(aPrdPrefix[1,1]) .And. nOrder = 1
	If Empty(aPrdPrefix[1,3])
		cPrefixo := Replicate(aPrdPrefix[1,1], aPrdPrefix[1,2])
	Else
		cPrefixo := Replicate(aPrdPrefix[1,1], Val(aPrdPrefix[1,3]) - Len(cPesq))		
	EndIf
	If At(cPrefixo, cPesq) = 0
		cPesq := cPrefixo + cPesq
	EndIf
EndIf

HB1->(dbSetOrder(nOrder))
if HB1->(dbSeek(cPesq))
    nTop:=HB1->(Recno())
	PD2Load(@cProduto,@nTop,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet)
else
    if nOrder == 1
    	MsgStop(STR0012,STR0013) //"Produto n鉶 localizado!"###"C骴igo do Produto"
	else
    	MsgStop(STR0012,STR0014) //"Produto n鉶 localizado!"###"Descri玢o do Produto"
	Endif
endif
Return nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � PD2End()            矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Atualiza o Codigo do Produto                               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cProduto - Codigo do Produtos							  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function PD2End(lRet,cProduto)
lRet := if ( Len(cProduto) > 0 , .T., .F.)
CloseDialog()
Return nil