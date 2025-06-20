#INCLUDE "QMTR230.Ch"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QMTR230  � Autor � Wanderley Goncalves   � Data � 02.06.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ficha de Repe/Repro                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QMTR230(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QMTR230()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL cDesc1	:=OemToAnsi( STR0001 ) // "Este programa ira emitir a"
LOCAL cDesc2	:=OemToAnsi( STR0002 ) // "ficha de Repe/Repro."
LOCAL cDesc3	:=""
LOCAL wnrel
LOCAL lImpLin2	:= .T.
LOCAL cString	:="QM2"

PRIVATE titulo
PRIVATE cabec1	:= ""
PRIVATE cabec2 	:= ""
PRIVATE aReturn	:= { OemToAnsi(STR0003), 1,OemToAnsi(STR0004), 1, 2, 1, "",1 } // "Zebrado"###"Administra��o"
PRIVATE nomeprog	:="QMTR230"
PRIVATE nLastKey	:= 0
PRIVATE cPerg		:="QMR230"
PRIVATE cTamanho	:= "M"
Private Inclui		:= .F.

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("QMR230",.F.)
//�����������������������������������������������������������������Ŀ
//� vARIAVEIS UTILIZADAS PARA PARAMETROS                            �
//� mv_par01            // No.Ensaiadores                           �
//� mv_par02            // No.Ciclos (Medicoes)                     �
//� mv_par03            // No.Pecas                                 �
//� mv_par04            // No.Copias                                �
//�������������������������������������������������������������������

titulo := OemToAnsi( STR0005 ) // "FICHA REPE/REPRO"

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnrel:="QMTR230"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,cTamanho)

If nLastKey = 27
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
   Return
Endif

RptStatus({|lEnd| MTR230Imp(@lEnd,wnRel,cString,lImpLin2)},Titulo)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MTR230IMP� Autor � Wanderley Goncalves   � Data � 03.06.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Sugestao de Bloqueio                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MTR230IMP(lEnd,wnRel,cString)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd    - A��o do Codeblock                                ���
���          � wnRel   - T�tulo do relat�rio                              ���
���          � cString - Mensagem                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MTR230Imp(lEnd,wnRel,cString,lImpLin2)

LOCAL nOrder		:= IndexOrd()
LOCAL cAlias		:= Alias()
LOCAL nCopia      := mv_par04
PRIVATE TAMANHO   := "M"
PRIVATE nCol
PRIVATE li
Private nCtUser := 0
Private lNoImprs := .T.

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

SetRegua(RecCount())

If mv_par03 < 14  // Numero de pecas
   nCOL := 6
Else
   nCOL := 1
EndIf

Do While nCopia > 0 

	IF lEnd
		li++
		@ li  ,001 PSAY OemToAnsi(STR0006)  // "CANCELADO PELO OPERADOR"
		EXIT
	ENDIF

	IncRegua()

	IF li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
		@ li  ,000 PSAY Repl("*",132)
 	    R230Cabec(.f.,nCOL,0)
	End

	//��������������������������������������������������������������Ŀ
	//� Imprime corpo da ficha                                       �
	//����������������������������������������������������������������
	QMTXFRR(mv_par01,mv_par02,mv_par03,'I')

	//��������������������������������������������������������������Ŀ
	//� Quebra de c�pia                                              �
	//����������������������������������������������������������������
    nCopia := nCopia - 1
	li       := 80
	m_pag    := 1
	
EndDo

Roda( cbCont, cbTxt, Tamanho )

Set Device To Screen
Set Filter To

dbSelectArea(cAlias)
dbSetOrder(nOrder)

If aReturn[5] = 1
	Set Printer TO
	dbCommitall()
	ourspool(wnrel)
End
MS_FLUSH()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R230CABEC� Autor � Wanderley Goncalves   � Data � 03.06.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cabecalho de Ficha de Repe/Repro                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � R230CABEC()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTR230                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function R230Cabec(wCAB,nCOL,nCnt)
Local nCntFor,nCntFor2

li+=2
@ li  , nCOL PSAY alltrim(TitSx3("QM2_INSTR")[1])+' '+;  // 'Instrumento'
						repl('.',16-len(alltrim(TitSx3("QM2_INSTR")[1])))+;
                   ': ' + repl('_',60) +space(20)+;
                   'Data : _____ / _____ / _____'
li+=2
@ li  , nCOL PSAY alltrim(TitSx3("QM4_PECA")[1])+' '+; // 'Peca'
						repl('.',16-len(alltrim(TitSx3("QM4_PECA")[1])))+;
                   ': ' + repl('_',60)
li+=2
@ li  , nCOL PSAY alltrim(TitSx3("QM4_CARACT")[1])+' '+; // 'Caracteristica'
						repl('.',16-len(alltrim(TitSx3("QM4_CARACT")[1])))+;
                   ': ' + repl('_',60)
li+=2
@ li  , nCOL PSAY alltrim(TitSx3("QM4_NUMERO")[1])+' '+;  // Numero
						repl('.',16-len(alltrim(TitSx3("QM4_NUMERO")[1])))+;
                   ': ' + repl('_',60)
li+=2
@ li  , nCOL PSAY alltrim(TitSx3("QM4_LIE")[1])+' '+; // 'LIE' 
						repl('.',16-len(alltrim(TitSx3("QM4_LIE")[2])))+;
                  ': ' + repl('_',20)
@ li  , 43+nCOL PSAY alltrim(TitSx3("QM4_LSE")[1])+' '+; // 'LSE'
						repl('.',16-len(alltrim(TitSx3("QM4_LSE")[2])))+;
                  ': ' + repl('_',20)
li+=2
@ li  , nCOL PSAY alltrim(TitSx3("QM4_UM")[2])+' '+; //'Unidade Medida'
						repl('.',16-len(alltrim(TitSx3("QM4_UM")[2])))+;
                  ': ' + repl('_',30)

	@ li  , 55+nCOL PSAY alltrim(TitSx3("QM4_TOLESP")[2])+' '+; //'Tolerancia'
						repl('.',16-len(alltrim(TitSx3("QM4_TOLESP")[2])))+;
                  ': ' + repl('_',10)

li+=2

@ li  ,    nCOL PSAY OemToAnsi(STR0007)+" :  " + StrZero(mv_par01,2) // 'No.Ensaiadores'
@ li  , 49+nCOL PSAY OemToAnsi(STR0008)+" :  " + StrZero(mv_par02,2) // 'No.Medicoes'
@ li  , 93+nCOL PSAY OemToAnsi(STR0009)+" :  " + StrZero(mv_par03,2) // 'No.Pecas'

If wcab
   li+=2
   @ li  , nCOL PSAY repl('=',8*mv_par03+7)
   li++
   @ li  , nCOL PSAY '| ' + OemToAnsi(STR0010)+' '+StrZero(nCnt,2)+':' // 'Ensaiador'
   @ li  , nCOL+8*mv_par03+6 PSAY '|'
   li++
   @ li  , nCOL PSAY repl('-',8*mv_par03+7)
   For nCntFor := 1 to mv_par02
      If nCntFor == 1
		 li++
         @ li  , nCOL PSAY '|      |'
         For nCntFor2 := 1 to mv_par03   
            @ li  ,pcol() PSAY   subs(alltrim(OemToAnsi(STR0011)),1,4)+StrZero(nCntFor2,2)+'  |'  // "PECA"
         Next
		 li++
		 @ li  , nCOL     PSAY repl('-',8*mv_par03+7)
      EndIf    
   Next
EndIf

Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R230Valida � Autor �Wanderley Gon�alves  � Data � 03.06.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida quantidade de ensaiadores, pecas e ciclos           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � R230Valida(cVAR)                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cVar := indica tipo de campo                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Pergunte -> QMR230                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function R230Valida(cVar)

Local lMessage := .F.
Local lRet := .T.
Local _bck

If cVar == "ENSR" .and. (mv_par01 < 2 .or. mv_par01 > 15 )
	lMessage := .t.
ElseIf cVar == "PECA" .and. (mv_par03 < 2 .or. mv_par03 > 15 )
	lMessage := .t.
ElseIf cVar == "CICL" .and. (mv_par02 < 1 .or. mv_par02 > 15 )
      lMessage := .t.
EndIf

If lMessage
	_bck := __cSx1Hlp	
   Help(" ",1,"QMTRRAVISO")   // Para ensaios Especifica��o ou Processo:
										// Min. ensaiadores, pecas ou ciclos:  2
                            	// Max. ensaiadores, pecas ou ciclos: 15
										// Para ensaios m�todo curto:
									   // 2 ensaiadores, 1 ciclo, 5 a 15 pe�as
	__cSx1Hlp := _bck
   lRet := .F.
EndIf

Return(lRet)
