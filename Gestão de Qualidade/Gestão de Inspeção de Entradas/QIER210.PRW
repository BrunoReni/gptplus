#INCLUDE "QIER210.CH"
#INCLUDE "PROTHEUS.CH"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Qier210  � Autor � Marcos Cesar          � Data � 15/01/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Permissao de Uso.                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Qier210()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���Vera        �14/04/99�------� Inclusao da Loja do Fornecedor           ���
�������������������������������������������������������������������������Ĵ��
���Antonio     �24/08/99������ĳ Inclusao funcao QA_AjusSX1() (QAXFUN.PRX)���
���            �        �      � Esta funcao corresponde a versao generica��� 
���            �        �      � da AjustaSX1                             ��� 
���Paulo Emidio�18/05/00�------�Retirada da Funcao de ajuste do SX1       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Qier210()

Local wnrel   := "QIER210"
Local cString := "QEK"
Local cDesc1  := OemToAnsi(STR0001)  // "Impressao da Permissao de Uso."
Local cDesc2  := ""
Local cDesc3  := ""

Private cTitulo  := OemToAnsi(STR0002)  // "Relatorio de Permissao de Uso"
Private cTamanho := "M"
Private aReturn  := { STR0003, 1, STR0004, 1, 2, 1, "", 1 }  // "Zebrado"###"Administracao"
Private nLastKey := 0
Private cPerg    := "QER210"
Private NomeProg := "QIER210"
Private Cabec1
Private Cabec2
Private nTipo
Private li       := 80
Private m_pag    := 1

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas p/ Parametros :                         �
//�                                                              �
//� mv_par01  // Fornecedor de                                   �
//� mv_par02  // Fornecedor ate                                  �
//� mv_par03  // Loja Fornecedor de                              �
//� mv_par04  // Loja Fornecedor ate                             �
//� mv_par05  // Produto de                                      �
//� mv_par06  // Produto ate                                     �
//� mv_par07  // Data de Entrada de                              �
//� mv_par08  // Data de Entrada ate                             �
//� mv_par09  // Lote de                                         �
//� mv_par10  // Lote ate                                        �
//� mv_par11  // Permissao Uso de                                �
//� mv_par12  // Permissao Uso ate                               �
//� mv_par13  // Status da Permissao (Aprovado   / Reprovado /   �
//�                                   Em Analise / Todos         �
//����������������������������������������������������������������
Pergunte(cPerg, .F.)

//��������������������������������������������������������������Ŀ
//� Envia Controle p/ a Funcao SetPrint.                         �
//����������������������������������������������������������������
wnrel := SetPrint(cString,wnrel,cPerg,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho)

If nLastKey == 27
	Set Filter To
	Return Nil
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter To
	Return Nil
EndIf

nTipo := Iif(aReturn[8] == 1, 15, 18)

RptStatus({|lEnd| R210Imp(@lEnd,wnRel,cString)},cTitulo)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R210Imp  � Autor � Marcos Cesar          � Data � 15/01/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao da Permissao de Uso.                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � R210Imp(ExpL1,ExpC1,ExpC2)                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpL1 : A��o do CodeBlock                                  ���
���          � ExpC1 : T�tulo do relat�rio                                ���
���          � ExpC2 : Mensagem                                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R210Imp(lEnd,wnRel,cString)

Local cbtxt  := Space(10)
Local cbcont := 0

//��������������������������������������������������������������Ŀ
//� Parametros.                                                  �
//����������������������������������������������������������������
Local cFornecDe  := mv_par01
Local cFornecAte := mv_par02
Local cLojForDe  := mv_par03
Local cLojForAte := mv_par04
Local cProdutDe  := mv_par05
Local cProdutAte := mv_par06
Local dDatEntDe  := mv_par07
Local dDatEntAte := mv_par08
Local cLoteDe    := mv_par09
Local cLoteAte   := mv_par10
Local cPermisDe  := mv_par11
Local cPermisAte := mv_par12
Local cStatus    

//��������������������������������������������������������������Ŀ
//� Dados da Entrada.                                            �
//����������������������������������������������������������������
Local cFornecAnt
Local cLojForAnt
Local cProdutAnt
Local dDatEntAnt
Local cLoteAnt

//��������������������������������������������������������������Ŀ
//� Identifica o Status Selecionado pelo Usuario.                �
//����������������������������������������������������������������
If mv_par13 == 1
	cStatus := "A"  // Aprovado

ElseIf mv_par13 == 2
	cStatus := "R"  // Reprovado

ElseIf mv_par13 == 3
	cStatus := "E"  // Em Analise

Else
	cStatus := "T"  // Todos os Status
EndIf

//��������������������������������������������������������������Ŀ
//� Pesquisa o Arquivo QF2 (Entradas).                           �
//����������������������������������������������������������������
dbSelectArea("QF2")
dbSetOrder(1)
SetRegua(LastRec())
If !Empty(cFornecDe) .And. !Empty(cProdutDe) .And. !Empty(dDatEntDe) .And.;
		!Empty(cLoteDe) .And. !Empty(cLojForde)
	dbSeek(xFilial("QF2")+cFornecDe+cLojForDe+cProdutDe+Dtos(dDatEntDe)+cLoteDe,.T.)
Else
	dbSeek(xFilial("QF2"))
EndIf

While QF2->QF2_FILIAL == xFilial("QF2") .And. QF2->QF2_FORNEC <= cFornecAte .And.;
	QF2->QF2_LOJFOR <= cLojForAte .And. QF2->QF2_PRODUT <= cProdutAte .And.;
	QF2->QF2_DTENTR <= dDatEntAte .And. QF2->QF2_LOTE   <= cLoteAte .And. QEF->(!Eof())

	//��������������������������������������������������������������Ŀ
	//� Dados da Entrada.                                            �
	//����������������������������������������������������������������
	cFornecAnt := QF2->QF2_FORNEC
	cLojForAnt := QF2->QF2_LOJFOR
	cProdutAnt := QF2->QF2_PRODUT
	dDatEntAnt := QF2->QF2_DTENTR
	cLoteAnt   := QF2->QF2_LOTE

	//��������������������������������������������������������������Ŀ
	//� Quebra por Entrada.                                          �
	//����������������������������������������������������������������
	While QF2->QF2_FILIAL == xFilial("QF2") .And. QF2->QF2_FORNEC == cFornecAnt .And.;
		QF2->QF2_LOJFOR == cLojForAnt .And. QF2->QF2_PRODUT == cProdutAnt .And.;
		QF2->QF2_DTENTR == dDatEntAnt .And. QF2->QF2_LOTE   == cLoteAnt .And. QF2->(!Eof())

		IncRegua()

		If QF2->QF2_NUMERO >= cPermisDe .And. QF2->QF2_NUMERO <= cPermisAte .And.;
			 (QF2->QF2_STATUS == cStatus .Or. cStatus == "T")
			//��������������������������������������������������������������Ŀ
			//� Monta as Variaveis do Cabecalho Padrao Microsiga.            �
			//����������������������������������������������������������������
			Cabec1 :=          "Fornecedor : "   + AllTrim(QF2->QF2_FORNEC)+"-"+QF2->QF2_LOJFOR+Space(2)
			Cabec1 := Cabec1 + "Produto : "      + AllTrim(QF2->QF2_PRODUT) + Space(5)
			Cabec1 := Cabec1 + "Data Entrada : " + Dtoc(QF2->QF2_DTENTR)    + Space(5)
			Cabec1 := Cabec1 + "Lote : "         + AllTrim(QF2->QF2_LOTE)
			Cabec2 := "Permissao de Uso : " + QF2->QF2_NUMERO
			If QF2->QF2_STATUS == "A"
				Cabec2+= " - Aprovada"
			Elseif QF2->QF2_STATUS == "R"
				Cabec2+= " - Reprovada"
			Elseif QF2->QF2_STATUS == "E"
				Cabec2+= " - Em aberto"
			EndIf

			//��������������������������������������������������������������Ŀ
			//� Impressao do Cabecalho.                                      �
			//����������������������������������������������������������������
			Cabec(cTitulo,Cabec1,Cabec2,NomeProg,cTamanho,nTipo)

			//��������������������������������������������������������������Ŀ
			//� Impressao do Solicitante da Permissao de Uso.                �
			//����������������������������������������������������������������
			R210Solici()

			//��������������������������������������������������������������Ŀ
			//� Impressao das Recomendacoes.                                 �
			//����������������������������������������������������������������
			R210Recome()

			//��������������������������������������������������������������Ŀ
			//� Impressao dos Responsaveis pela Aprovacao.                   �
			//����������������������������������������������������������������
			R210Respon()
		EndIf

		dbSelectArea("QF2")
		dbSkip()
	End  // Quebra por Entrada

	dbSelectArea("QF2")
End

//��������������������������������������������������������������Ŀ
//� Impressao do Rodape.                                         �
//����������������������������������������������������������������
If li <> 80
	Roda(cbcont, cbtxt)
EndIf

//��������������������������������������������������������������Ŀ
//� Spool de Impressao.                                          �
//����������������������������������������������������������������
If aReturn[5] == 1
	Set Printer To
	Commit
	OurSpool(wnrel)
EndIf

MS_FLUSH()

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R210Solici � Autor � Marcos Cesar        � Data � 15/01/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do Solicitante da Permissao de Uso.              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � R210Solici()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R210Solici()

Local nA := 0

@ li,000 PSAY "A - Solicitante :"

li := li + 2
@ li,000 PSAY "|" + Replicate("-",128) + "|"

//��������������������������������������������������������������Ŀ
//� Impressao do Nome do Solicitante.                            �
//����������������������������������������������������������������
li := li + 1
@ li,000 PSAY "| Solicitada por : " + R210Nome(QF2->QF2_FILMAT,QF2->QF2_MAT)
@ li,129 PSAY "|"

//��������������������������������������������������������������Ŀ
//� Impressao do Nome da Area do Solicitante.                    �
//����������������������������������������������������������������
li := li + 1
@ li,000 PSAY "| Processo       : " + R210Area(QF2->QF2_MAT)
@ li,129 PSAY "|"

//��������������������������������������������������������������Ŀ
//� Impressao do Motivo da Inclusao da Permissao de Uso.         �
//����������������������������������������������������������������
li := li + 1
@ li,000 PSAY "|"
@ li,129 PSAY "|"

li := li + 1
@ li,000 PSAY "| Motivo : "
@ li,129 PSAY "|"

li := li + 1
@ li,000 PSAY "|"
@ li,129 PSAY "|"

dbSelectArea("QA2")
dbSetOrder(1)
dbSeek(xFilial() + "Inclusao" + QF2->QF2_CHAVE)

If Found()
	While (QA2->QA2_FILIAL == xFilial("QA2")) .And. (QA2->QA2_ESPEC  == "Inclusao")    .And.;
		(QA2->QA2_CHAVE  == QF2->QF2_CHAVE) .And. !Eof()
		li := li + 1
		@ li,000 PSAY "| " + QA2->QA2_TEXTO
		@ li,129 PSAY "|"
		dbSelectArea("QA2")
		dbSkip()
	End
Else
	For nA := 1 To 3
		li := li + 1
		@ li,000 PSAY "| " + Replicate(".", 125)
		@ li,129 PSAY "|"
	Next nA
EndIf

//��������������������������������������������������������������Ŀ
//� Assinatura e Data.                                           �
//����������������������������������������������������������������
li := li + 1
@ li,000 PSAY "|"
@ li,129 PSAY "|"

li := li + 1
@ li,000 PSAY "| " + "Ass.: .........................................................."
@ li,108 PSAY "Data : " + Dtoc(QF2->QF2_DATENT)
@ li,129 PSAY "|"

li := li + 1
@ li,000 PSAY "|" + Replicate("-",128) + "|"

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R210Recome � Autor � Marcos Cesar        � Data � 15/01/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao das Recomendacoes.                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � R210Recome()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R210Recome()

Local lResponsavel := .F.
Local nA           := 0

li := li + 2
@ li,000 PSAY "B - Recomendacoes :"

li := li + 2
@ li,000 PSAY "|" + Replicate("-",128) + "|"

//��������������������������������������������������������������Ŀ
//� Pesquisa Arquivo QF3 (Destinatarios) p/ Obter o Responsavel. �
//����������������������������������������������������������������
dbSelectArea("QF3")
dbSetOrder(1)
dbSeek(xFilial()+QF2->QF2_FORNEC+QF2->QF2_LOJFOR+QF2->QF2_PRODUT+;
		Dtos(QF2->QF2_DTENTR)+QF2->QF2_LOTE+QF2->QF2_NUMERO)

While QF3->QF3_FILIAL == xFilial() .And.;
		QF3->QF3_FORNEC == QF2->QF2_FORNEC .And.;
		QF3->QF3_LOJFOR == QF2->QF2_LOJFOR .And.;
		QF3->QF3_PRODUT == QF2->QF2_PRODUT .And.;
		QF3->QF3_DTENTR == QF2->QF2_DTENTR .And.;
		QF3->QF3_LOTE   == QF2->QF2_LOTE   .And.;
		QF3->QF3_NUMERO == QF2->QF2_NUMERO

	If QF3->QF3_MAT <> QF2->QF2_MATQLD
		lResponsavel := .T.

		Exit
	EndIf

	dbSelectArea("QF3")
	dbSkip()
End

//��������������������������������������������������������������Ŀ
//� Impressao do Nome do Responsavel.                            �
//����������������������������������������������������������������
li := li + 1
@ li,000 PSAY "| Responsavel : " + Iif(lResponsavel, R210Nome(QF3->QF3_FILMAT,QF3->QF3_MAT), Space(1))
@ li,129 PSAY "|"

//��������������������������������������������������������������Ŀ
//� Impressao do Nome da Area do Responsavel.                    �
//����������������������������������������������������������������
li := li + 1
@ li,000 PSAY "| Processo    : " + Iif(lResponsavel, R210Area(QF3->QF3_MAT), Space(1))
@ li,129 PSAY "|"

//��������������������������������������������������������������Ŀ
//� Impressao da Acao Recomendada p/ o Lote.                     �
//����������������������������������������������������������������
li := li + 1
@ li,000 PSAY "|"
@ li,129 PSAY "|"

li := li + 1
@ li,000 PSAY "| Acao Recomendada p/ o Lote : "
@ li,129 PSAY "|"

li := li + 1
@ li,000 PSAY "|"
@ li,129 PSAY "|"

dbSelectArea("QA2")
dbSetOrder(1)
dbSeek(xFilial() + "Acao Rec" + QF2->QF2_CHAVE1)

If Found()
	While QA2->QA2_FILIAL == xFilial()       .And.;
			QA2->QA2_ESPEC  == "Acao Rec"      .And.;
			QA2->QA2_CHAVE  == QF2->QF2_CHAVE1 .And. !Eof()
		li := li + 1
		@ li,000 PSAY "| " + QA2->QA2_TEXTO
		@ li,129 PSAY "|"

		dbSelectArea("QA2")
		dbSkip()
	End
Else
	For nA := 1 To 2
		li := li + 1
		@ li,000 PSAY "| " + Replicate(".", 125)
		@ li,129 PSAY "|"
	Next nA
EndIf

//��������������������������������������������������������������Ŀ
//� Impressao da Acao Corretiva p/ o Problema.                   �
//����������������������������������������������������������������
li := li + 1
@ li,000 PSAY "|"
@ li,129 PSAY "|"

li := li + 1
@ li,000 PSAY "| Acao Corretiva p/ o Problema : "
@ li,129 PSAY "|"

li := li + 1
@ li,000 PSAY "|"
@ li,129 PSAY "|"

dbSelectArea("QA2")
dbSetOrder(1)
dbSeek(xFilial() + "Acao Cor" + QF2->QF2_CHAVE1)

If Found()
	While QA2->QA2_FILIAL == xFilial()       .And.;
			QA2->QA2_ESPEC  == "Acao Cor"      .And.;
			QA2->QA2_CHAVE  == QF2->QF2_CHAVE1 .And. !Eof()
		li := li + 1
		@ li,000 PSAY "| " + QA2->QA2_TEXTO
		@ li,129 PSAY "|"

		dbSelectArea("QA2")
		dbSkip()
	End
Else
	For nA := 1 To 2
		li := li + 1
		@ li,000 PSAY "| " + Replicate(".", 125)
		@ li,129 PSAY "|"
	Next nA
EndIf

//��������������������������������������������������������������Ŀ
//� Assinatura e Data.                                           �
//����������������������������������������������������������������
li := li + 1
@ li,000 PSAY "|"
@ li,129 PSAY "|"

li := li + 1
@ li,000 PSAY "| " + "Ass.: .........................................................."
@ li,108 PSAY "Data : " + Dtoc(QF3->QF3_DTGERA)
@ li,129 PSAY "|"

li := li + 1
@ li,000 PSAY "|" + Replicate("-",128) + "|"

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R210Respon � Autor � Marcos Cesar        � Data � 15/01/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao dos Responsaveis pela Aprovacao.                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � R210Respon()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R210Respon()

Local cCab1 := ""
Local cCab2 := ""
Local cCab3 := ""
Local cCab4 := ""
Local cCab5 := ""

//��������������������������������������������������������������Ŀ
//� Definicao do Cabecalho dos Responsaveis pela Aprovacao.      �
//����������������������������������������������������������������
//                  1         2         3         4         5         6         7         8         9        10        11        12        13        14
//        012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

cCab1 := "|--------------------------------------------------------------------------------------------------------------------------------|"
cCab2 := "| Nome                               | Unidade Negocio - Area        |Recons.  |    Data      | Assinatura                       |"
cCab3 := "|                                    |                               |---------|              |                                  |"
cCab4 := "|                                    |                               |Sim |Nao |              |                                  |"
cCab5 := "|================================================================================================================================|"                   

//        | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   | xxxxxxxxxxxxxxxxxxxxxxxxx     | x  | x  |  99/99/9999  |									       |

li := li + 2
@ li,000 PSAY "C - Responsavel pela Aprovacao :"

li := li + 2
@ li,000 PSAY cCab1

li := li + 1
@ li,000 PSAY cCab2

li := li + 1
@ li,000 PSAY cCab3

li := li + 1
@ li,000 PSAY cCab4

li := li + 1
@ li,000 PSAY cCab5

//��������������������������������������������������������������Ŀ
//� Pesquisa Arquivo QF3 (Destinatarios) p/ Obter o Responsavel. �
//����������������������������������������������������������������
dbSelectArea("QF3")
dbSetOrder(1)
dbSeek(xFilial()+QF2->QF2_FORNEC+QF2->QF2_LOJFOR+QF2->QF2_PRODUT+;
		Dtos(QF2->QF2_DTENTR)+QF2->QF2_LOTE+QF2->QF2_NUMERO)

While QF3->QF3_FILIAL == xFilial() .And.;
		QF3->QF3_FORNEC == QF2->QF2_FORNEC .And.;
		QF3->QF3_LOJFOR == QF2->QF2_LOJFOR .And.;
		QF3->QF3_PRODUT == QF2->QF2_PRODUT .And.;
		QF3->QF3_DTENTR == QF2->QF2_DTENTR .And.;
		QF3->QF3_LOTE   == QF2->QF2_LOTE   .And.;
		QF3->QF3_NUMERO == QF2->QF2_NUMERO

	//��������������������������������������������������������������Ŀ
	//� Impressao do Cabecalho.                                      �
	//����������������������������������������������������������������
	If li > 80
		Cabec(cTitulo,Cabec1,Cabec2,NomeProg,cTamanho,nTipo)

		li := li + 2
		@ li,000 PSAY "C - Responsavel pela Aprovacao :"

		li := li + 2
		@ li,000 PSAY cCab1

		li := li + 1
		@ li,000 PSAY cCab2

		li := li + 1
		@ li,000 PSAY cCab3

		li := li + 1
		@ li,000 PSAY cCab4

		li := li + 1
		@ li,000 PSAY cCab5
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Impressao do Responsavel.                                    �
	//����������������������������������������������������������������
	li := li + 1
	@ li,000 PSAY "| " + R210Nome(QF3->QF3_FILMAT,QF3->QF3_MAT)
	@ li,037 PSAY "| " + R210Area(QF3->QF3_FILMAT,QF3->QF3_MAT)
	@ li,069 PSAY "| " + Iif(QF3->QF3_STATUS == "A", "x", " ")
	@ li,074 PSAY "| " + Iif(QF3->QF3_STATUS == "R", "x", " ")
	@ li,079 PSAY "| " + Dtoc(QF3->QF3_DTBAIX)
	@ li,094 PSAY "|"
	@ li,129 PSAY "|"

	li := li + 1
	@ li,000 PSAY "|" + Replicate("-",128) + "|"

	dbSelectArea("QF3")
	dbSkip()
End

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R210Nome   � Autor � Marcos Cesar        � Data � 15/01/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Obtem o Nome do Funcionario.                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � R210Nome(cFilUsu,cMatricula)								  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 := Filial do usuario								  ���
���			 � ExpC2 := Matricula do Funcionario                          ���				  
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpC2 : Nome do Funcionario                                ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R210Nome(cFilUsu,cMatricula)

//��������������������������������������������������������������Ŀ
//� Pesquisa o Arquivo QAA (Cadastro de Funcionarios).           �
//����������������������������������������������������������������
dbSelectArea("QAA")
dbSetOrder(1)
dbSeek(cFilUsu+cMatricula)

Return(QAA->QAA_NOME)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R210Area   � Autor � Marcos Cesar        � Data � 15/01/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Obtem o Nome da Area (Departamento) do Funcionario.        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ExpC2 := R210Area(ExpC1)                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Matricula do Funcionario                           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � ExpC2 : Nome da Area (Departamento) do Funcionario         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R210Area(cMatricula)

//��������������������������������������������������������������Ŀ
//� Pesquisa o Arquivo QAA (Cadastro de Funcionarios).           �
//����������������������������������������������������������������
dbSelectArea("QAA")
dbSetOrder(1)
dbSeek(xFilial('QAA')+cMatricula)

//��������������������������������������������������������������Ŀ
//� Pesquisa o Arquivo QAD (Centro de Custo).                    �
//����������������������������������������������������������������
dbSelectArea("QAD")
dbSetOrder(1)
dbSeek(xFilial('QAD')+QAA->QAA_CC)

Return(QAD->QAD_DESC)