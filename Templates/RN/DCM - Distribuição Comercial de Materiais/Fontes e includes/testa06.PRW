#INCLUDE "testa06.ch"
#INCLUDE "rwmake.ch" 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TESTA06   � Autor � Ewerton C Tomaz    � Data �  26/11/01   ���
�������������������������������������������������������������������������͹��
���Descricao � Programa de liberacao de itens nao aptos no estoque        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Template Function TESTA06()

CHKTEMPLATE("DCM")

Private aCampos1 := {}
Private aTam1    := {}
Private aEstru1  := {}
Private aEstru2  := {}
Private TMP    := ""
Private cIndTrb1 := ""
Private cMark    := GETMARK()

cPerg := Padr("TEST03",Len(SX1->X1_GRUPO))
If !Pergunte(cPerg)
	Return
Endif

DBSelectArea("SC9")
DBSetOrder(1)
If !(DBSeek(xFilial("SC9")+AllTrim(MV_PAR01)))
	MsgAlert(STR0001) //"Pedido nao Localizado !"
	Return
EndIF

Processa({|| CriaTmp() },STR0002) //"Gerando Arquivos Temporarios...."

Processa({|| GrvPV() } ,STR0003) //"Gerando dados do Pedido de Venda..."

// colunas do MarkBrow
AADD(aCampos1,{"TMP_EMITE"  ,"",""})
AADD(aCampos1,{"TMP_PEDIDO" ,"",STR0004}) //"Pedido"
AADD(aCampos1,{"TMP_ITEM"   ,"",STR0005}) //"Item"
AADD(aCampos1,{"TMP_SEQUEN" ,"",STR0006}) //"Sequen"
AADD(aCampos1,{"TMP_CLIE"   ,"",STR0007}) //"Cliente"
AADD(aCampos1,{"TMP_LOJA"   ,"",STR0008}) //"Loja"
AADD(aCampos1,{"TMP_PROD"   ,"",STR0009}) //"Produto"
AADD(aCampos1,{"TMP_LOCAL"  ,"",STR0010}) //"Local"
AADD(aCampos1,{"TMP_QTDLIB" ,"",STR0011,"@E 999999.99"}) //"Quant.Liberada"

DBSelectArea("TMP")
DBGoTop()
DBSetOrder(1)

// Declaracao das Variaveis
cCadastro  := STR0012 //"Liberacao de Pedidos Bloqueados por Estoque"
aRotina    := MenuDef()

Markbrow("TMP","TMP_EMITE",,aCampos1,,@cMark,,)

//��������������������������������������������������������������Ŀ
//� Finalize e deleta os arquivos temporarios criados.           �
//����������������������������������������������������������������

DBSelectArea("TMP")
use
DBCloseArea()
If File(TMP+OrdBagExt())
	FErase(TMP+OrdBagExt())
End
If File(Left(cIndTrb1,7)+"1"+ORDBAGEXT())
	FErase(Left(cIndTrb1,7)+"1"+ORDBAGEXT())
End
Return
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Conrado Q. Gomes      � Data � 11.12.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TESTA06                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := {{STR0013, "T_libSC9()", 0, 1, 0, .T.}}	//"Confirma"
Return(aRotina)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CriaTmp   �Autor  �Microsiga           � Data �  08/18/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CriaTmp()

aTam1 := TamSX3("C9_PEDIDO")
AADD(aEstru1, {"TMP_PEDIDO"  ,"C",aTam1[1],aTam1[2]})
aTam1 := TamSX3("C9_ITEM")
AADD(aEstru1, {"TMP_ITEM"    ,"C",aTam1[1],aTam1[2]})
aTam1 := TamSX3("C9_SEQUEN")
AADD(aEstru1, {"TMP_SEQUEN"  ,"C",aTam1[1],aTam1[2]})
aTam1 := TamSX3("C9_CLIENTE")
AADD(aEstru1, {"TMP_CLIE"    ,"C",aTam1[1],aTam1[2]})
aTam1 := TamSX3("C9_LOJA")
AADD(aEstru1, {"TMP_LOJA"    ,"C",aTam1[1],aTam1[2]})
aTam1 := TamSX3("C9_PRODUTO")
AADD(aEstru1, {"TMP_PROD"    ,"C",aTam1[1],aTam1[2]})
aTam1 := TamSX3("C9_LOCAL")
AADD(aEstru1, {"TMP_LOCAL"   ,"C",aTam1[1],aTam1[2]})
aTam1 := TamSX3("C9_QTDLIB")
AADD(aEstru1, {"TMP_QTDLIB"  ,"N",aTam1[1],aTam1[2]})
AADD(aEstru1, {"TMP_EMITE"   ,"C",2 ,0 })
AADD(aEstru1, {"TMP_TM"   ,"C",3 ,0 })

TMP   := CriaTrab(aEstru1,.T.)
DBUseArea(.T.,,TMP,"TMP",.F.,.F.)
cIndTrb1 := CriaTrab(,.F.)
cChave1 := "TMP_PEDIDO+TMP_ITEM+TMP_SEQUEN"

IndRegua("TMP",Left(cIndTrb1,7)+"1",cChave1,,,STR0014 ) //"Criando Arquivo Temporario de Pedidos..."

DBClearIndex()
DBSetIndex(Left(cIndTrb1,7)+"1"+OrDBagExt())
DBSetOrder(1)

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Grvpv     �Autor  �Microsiga           � Data �  08/18/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Grvpv()

DBSelectArea("SC9")
DBSetOrder(1)
DBSeek(xFilial("SC9")+mv_par01)
lMens := .T.

While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_PEDIDO == MV_PAR01
	
	If SC9->C9_BLEST <> '10' .AND. SC9->C9_BLEST <> '' .AND. Empty(SC9->C9_NFISCAL)
		DBSelectArea("TMP")
		RecLock("TMP", .T.)
		REPLACE TMP_PEDIDO  with SC9->C9_PEDIDO
		REPLACE TMP_ITEM    with SC9->C9_ITEM
		REPLACE TMP_SEQUEN  with SC9->C9_SEQUEN
		REPLACE TMP_CLIE    with SC9->C9_CLIENTE
		REPLACE TMP_LOJA    with SC9->C9_LOJA
		REPLACE TMP_PROD    with SC9->C9_PRODUTO
		REPLACE TMP_LOCAL   with SC9->C9_LOCAL
		REPLACE TMP_QTDLIB  with SC9->C9_QTDLIB
		REPLACE TMP_EMITE   with " "            //cMark
		REPLACE TMP_TM   	  with MV_PAR02        //tipo de movimentacao
		
		MsUnlock()
	ENDIF
	
	DBSelectArea("SC9")
	DBSkip()
	
End

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LibSC9    �Autor  �Microsiga           � Data �  08/18/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function LibSC9()

Local nOpc    := 0
Local lPend   := .F.

PRIVATE cCusMed := GetMv("MV_CUSMED")

CHKTEMPLATE("DCM")

TMP->(DBGoTop())
While TMP->(!eof())
	
	If TMP->TMP_EMITE <> cMark
		TMP->(DBSkip())
		Loop
	EndIf
	
	cProduto := TMP->TMP_PROD
	nQtde    := TMP->TMP_QTDLIB
	nOpc     := 0
	@ 000,100 To 100,400 DIALOG oDlg1 TITLE STR0016 //"Qtde a ser Liberada"
	@ 005,005 Say STR0017                               SIZE 040,010  //"Produto ==>"
	@ 005,043 Say cProduto  Picture "@!"                SIZE 105,010
	@ 018,005 Say STR0018                               SIZE 040,010  //"Quantidade"
	@ 018,043 Get nQtde     Picture "@E 999,999,999.99" SIZE 060,010  Valid (nQtde<=TMP->TMP_QTDLIB)
	@ 032,090 BmpButton Type 1 Action Eval({|| nOpc := 1, Close(oDlg1)})
	@ 032,120 BmpButton Type 2 Action Eval({|| nOpc := 0, Close(oDlg1)})
	Activate Dialog oDlg1 Centered
	
	If nOpc == 0
		lPend	:= .T.
	ElseIf nOpc == 1
		lMsErroAuto := .F.
		_aArraySD3 	:= {{"D3_TM",      TMP->TMP_TM,     Nil},; //DE6
		                  {"D3_COD",     TMP->TMP_PROD,   Nil},;
		                  {"D3_QUANT",   nQtde,           Nil},;
		                  {"D3_UM",      Posicione("SB1",1,xFilial("SB1")+TMP->TMP_PROD,"B1_UM"), Nil},;
		                  {"D3_LOCAL",   TMP->TMP_LOCAL,  Nil},;
		                  {"D3_EMISSAO", ddatabase,       Nil},;
		                  {"D3_CUSTO1",  0,               Nil},;
		                  {"D3_NUMPDV",  TMP->TMP_PEDIDO, Nil},;
		                  {"D3_ITEMPV",  TMP->TMP_ITEM,   Nil}}
		MsExecAuto({|x,y| MATA240(x,y)}, _aArraySD3, 3)
		If lMsErroAuto
			MostraErro()
		Endif
	
		DbSelectArea("SB2")
		_aAreaSB2 := GetArea()
	
		l240 := .F.
		A240ATU()
	
		MsUnLock()
		RestArea(_aAreaSB2)
	
		DBSelectArea("TMP")
		RecLock("TMP",.F.)
		DBDELETE()
		MsUnlock()
	EndIf
	DBSkip()
End

If lPend
	MsgBox('Existe um ou mais pedidos que n�o foram liberados neste processamento!','Libera��o n�o apto','INFO')
Else
	MsgBox('Pedido liberado com sucesso !','Liberao Nao Apto','INFO')
EndIf
TMP->(dBGoTop())
Return