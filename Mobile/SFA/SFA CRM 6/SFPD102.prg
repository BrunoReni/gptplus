#INCLUDE "SFPD102.ch"
#include "eADVPL.ch"
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PD2Load()           �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega List de Produto para a consulta avancada           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aProduto, nProduto - Array e Posicao de Produtos			  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PD2Down()           �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Tratamento da navegacao do List de Produto                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aProduto - Array de Produtos								  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PD2Up()             �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Tratamento da navegacao do List de Produto                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aProduto - Array de Produtos								  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PD2Set()            �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Tratamento da navegacao do List de Produto                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cProduto - Codgio do Produto, cDesc - Descr. do Produto	  ���
���          � aPrecos  - Array de Precos								  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function PD2Set(cProduto,aProduto,oBrwProd,nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet)
Local nLinha := GridRow(oBrwProd)
Local cEst   := ""
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

If Select("HB2") != 0
    HB2->(dbSetOrder(1))
    HB2->(dbSeek(cProduto))
    cEst := Str(HB2->HB2_QTD,6,2) + " em " + DtoC(HB2->HB2_DATA)
Else
    cEst := HB1->B1_EST
EndIf

aSize(aDetalhe,0)
AADD(aDetalhe,{ STR0001, HB1->B1_GRUPO } ) //"Grupo: "
AADD(aDetalhe,{ STR0002, HB1->B1_COD } ) //"C�digo: "
AADD(aDetalhe,{ STR0003, HB1->B1_DESC } ) //"Descri��o: "
AADD(aDetalhe,{ STR0004, HB1->B1_UM } ) //"Unidade: "
AADD(aDetalhe,{ STR0005, HB1->B1_QE } ) //"Qtd.Emb.: "
AADD(aDetalhe,{ STR0006, HB1->B1_PE } ) //"Entr.: "
AADD(aDetalhe,{ STR0007, HB1->B1_PICM } ) //"ICMS: "
AADD(aDetalhe,{ STR0008, HB1->B1_IPI } ) //"IPI: "
AADD(aDetalhe,{ STR0009, cEst} ) //"Estoque: "
SetArray(oBrwDet,aDetalhe)
nLastProd := HB1->(Recno())

Return nil
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PD2Order()          �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega List de Produtos na ordem desejada                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cProduto - Codigo do Produtos							  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function PD2Order(cProduto,nTop,aProduto,oBrwProd,nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet)
Local oCol
GridReset(oBrwProd)
nTop:=0     
PD2Load(@cProduto,@nTop,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet)
if nOrder==1
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 1 HEADER STR0010 WIDTH 50 //"C�digo"
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 2 HEADER STR0011 WIDTH 125 //"Descri��o"
Else
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 1 HEADER STR0011 WIDTH 125 //"Descri��o"
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 2 HEADER STR0010 WIDTH 50 //"C�digo"
Endif	

Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PD2Find()           �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Busca do Produto								              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cProduto - Codigo do Produto								  ���
���          � aControls - Array de Controles							  ���
���          � lCodigo - Busca por Codigo (T ou F) 						  ���
���          � aPrecos - Array de Precos								  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
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
		cPesq := AllTrim(cPrefixo + cPesq)
	EndIf
EndIf

HB1->(dbSetOrder(nOrder))
if HB1->(dbSeek(cPesq))
    nTop:=HB1->(Recno())
	PD2Load(@cProduto,@nTop,aProduto,oBrwProd,@nOrder,aPrecos, oBrwPrc,aDetalhe, oBrwDet)
else
    if nOrder == 1
    	MsgStop(STR0012,STR0013) //"Produto n�o localizado!"###"C�digo do Produto"
	else
    	MsgStop(STR0012,STR0014) //"Produto n�o localizado!"###"Descri��o do Produto"
	Endif
endif
Return nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PD2End()            �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Atualiza o Codigo do Produto                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cProduto - Codigo do Produtos							  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function PD2End(lRet,cProduto)
lRet := if ( Len(cProduto) > 0 , .T., .F.)
CloseDialog()
Return nil