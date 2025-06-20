#INCLUDE "hspahr76.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Report.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � HSPAHR76 �       �       Saude        � Data � 21/01/2008  ���
�������������������������������������������������������������������������͹��
���Descricao � RELATORIO DE MNEMONICOS                                   ���
�������������������������������������������������������������������������͹��
���Uso       � GESTAO HOSPITALAR.                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function HSPAHR76()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis Locais                                      �
//�����������������������������������������������������������������������
Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relat�rio "
Local cDesc2 := STR0002 //"de acordo com os par�metros informados pelo usu�rio."
Local cDesc3 := ""
Local aOrd   := {}
Local aArea  := GetArea()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis Privadas                                    �
//�����������������������������������������������������������������������
Private cTitulo := STR0003 //"Relat�rio de Mnem�nicos"
Private cCabec1 := ""
Private cCabec2 := ""
Private cCabec3 := ""                                    
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 132
Private cTamanho     := "G"
Private cNomeProg   := "HSPAHR76"
Private nTipo       := 15
Private aReturn     := {STR0004, 1, STR0005, 2, 2, 1, "", 1}  //PARAM 4, 1 RETRATO 2 PAISAGEM //"Zebrado"###"Administracao"
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private m_pag       := 01
Private wnrel       := "HSPAHR76"
Private cString     := ""
Private aRegistros  := {}
Private nLin        := 80
Private cCodImp := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

Private cDe  := ""
Private cAte := ""
cPerg := "HSPR76"

// Pergunta de mnemonico at� mnemonico
If !Pergunte(cPerg, .T.)
 Return()
EndIf
cDe  := MV_PAR01
cAte := MV_PAR02

nMaxLin := HS_MaxLin(cCodImp)
nLin := nMaxLin * 2

//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������
wnrel := SetPrint(cString, cNomeProg, cPerg, @cTitulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., cTamanho,, .F.)
If nLastKey == 27
	Return()
EndIf

SetDefault(aReturn, cString)
If nLastKey == 27
	Return()
EndIf

//���������������������������������������������������������������������Ŀ
//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
//�����������������������������������������������������������������������
RptStatus({|| RunReport(cCabec1, cCabec2, cCabec3, cTitulo)}, cTitulo)

RestArea(aArea)
Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � Gilson da Silva    � Data �Janeiro/2005 ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � GESTAO HOSPITALAR                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunReport(cCabec1, cCabec2, cCabec3, cTitulo)
//���������������������������������������������������������������������Ŀ
//� Definicao das vari�veis locais.                                     �
//�����������������������������������������������������������������������
Local nCont	      := 0
Local cSQL 	      := ""
Local cMemo	      := ""

cTitulo := HS_MontCabe(STR0003, , )  //"Relat�rio de Mnem�nicos"

cSQL := "SELECT GCQ_CODIGO, GCQ_MNEUMO, GCQ_DESMNE "
cSQL += " FROM " + RetSQLName("GCQ") + " GCQ"
cSQL += " WHERE "
cSQL += " GCQ.GCQ_FILIAL = '" + xFilial("GCQ") + "' AND GCQ.D_E_L_E_T_ <> '*' "
cSQL += " AND GCQ.GCQ_CODIGO BETWEEN '" + cDe + "' AND '" + cAte + "' "
cSQL += " ORDER BY GCQ_CODIGO"
cSQL := ChangeQuery(cSql) 
TCQUERY cSQL NEW ALIAS "QRYTMP"
DbSelectArea("QRYTMP")
DbGoTop()

If Eof()
	MsgStop(STR0006) //"Nenhum dado foi encontrado para a sele��o efetuada!"
EndIf

//���������������������������������������������������������������������Ŀ
//� SETREGUA -> Indica quantos registros serao processados para a regua �
//�����������������������������������������������������������������������
SetRegua(100)

//���������������������������������������������������������������������Ŀ
//� Carrega o vetor aRegistros com todos os dados a serem impressos.    �
//�����������������������������������������������������������������������
While !EOF()
	
	//���������������������������������������������������������������������Ŀ
	//� Verifica o cancelamento pelo usuario...                             �
	//�����������������������������������������������������������������������
	If lAbortPrint
		@nLin,000 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	EndIf
	
	//���������������������������������������������������������������������Ŀ
	//� Impressao do cabecalho do relatorio. . .                            �
	//�����������������������������������������������������������������������
	If nLin > nMaxLin // Salto de P�gina. Neste caso o formulario tem 55 linhas...
		ImpCabec(cCabec1, cCabec2, cCabec3, cTitulo)
	EndIf
	@nLin, 000 PSAY QRYTMP->GCQ_CODIGO //Codigo do Mnemonico
	@nLin, 008 PSAY QRYTMP->GCQ_MNEUMO  //Mnemonico
	@nLin, 025 PSAY QRYTMP->GCQ_DESMNE  //Descricao
	cMemo     := HS_IniPadr("GCQ", 1, QRYTMP->GCQ_CODIGO, "GCQ_TXTMNE",, .F.) 
	nLinTotal := MlCount(cMemo)   //Imprime o campo MEMO GCQ_TXTMNE
	For nCont := 1 To nLinTotal
		@ nLin, 067 PSAY MemoLine(cMemo, 140 , nCont)
		nLin++
		If nLin >= nMaxLin
			ImpCabec(cCabec1, cCabec2, cCabec3, cTitulo)
		EndIf
	Next nCont
	nLin++
	@nLin, 000 PSAY Repl("-", 220)
	nLin += 2
	DbSkip()
EndDo

//���������������������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                                 �
//�����������������������������������������������������������������������
SET DEVICE TO SCREEN

//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������

If aReturn[5] == 1
	DbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
EndIf

MS_FLUSH()
DbCloseArea()

Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �IMPCABEC  � Autor �        wsilva      � Data �Janeiro/2008 ���
�������������������������������������������������������������������������͹��
���Descri��o � Imprime o Cabecalho do relatorio.                          ���
�������������������������������������������������������������������������͹��
���Uso       � GESTAO HOSPITALAR                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ImpCabec(cCabec1, cCabec2, cCabec3, cTitulo)

			/*         1         2         3         4         5         6         7         8         9         10        11        12        13
				0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.12 */

 nLin := cabec(cTitulo, cCabec1, cCabec2, cNomeProg, cTamanho, nTipo)+1
	@nLin, 000 PSAY  STR0008 //"C�digo  Mnem�nico        Descri��o                                 Texto Mnem�nico"
	nLin++
	@nLin, 000 PSAY  Repl("-", 220)
	nLin++
Return()
