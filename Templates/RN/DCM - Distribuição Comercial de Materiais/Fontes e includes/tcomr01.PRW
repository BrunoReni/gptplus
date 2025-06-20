#INCLUDE "tcomr01.ch"
#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TCOMR01   � Autor � EWERTON C TOMAZ    * Data �  22/08/01   ���
�������������������������������������������������������������������������͹��
���Descricao � Relatorio do filtro criado atraves da tela de pesquisa de  ���
���          � pedidos                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP5 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Template Function TCOMR01(cTitAnt)

CHKTEMPLATE("DCM")  

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "TCOMR01" 
Private nTipo        := 15
Private aReturn      := { STR0001, 1, STR0002, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private cString      := "TC7"
Private wnrel        := "TCOMR01" 
Private aOrd           := {}
Private cDesc1         := STR0003 //"Este programa tem como objetivo imprimir relatorio "
Private cDesc2         := STR0004 //"de acordo com os parametros informados pelo usuario."
Private cDesc3         := STR0005 //"Pedidos"
Private cPict          := ""
Private imprime        := .T.
Private titulo         := IIF(cTitAnt==Nil, STR0006,cTitAnt) //"Relatorio do Filtro de Pedidos"
Private nLin           := 80
Private Cabec1         := STR0007 //"Pedido   Emissao    Entrega    Fornecedor   Nome Reduzido          Contato           Cond.Pag.   Comprador               Situacao"
Private Cabec2         := ""

//Pedido   Emissao    Entrega    Fornecedor   Nome Reduzido          Contato           Cond.Pag.   Comprador               Situacao
//999999   99/99/99   99/99/99   999999  99   12345678901234567890   123456789012345   123         12345678901234567890    12345678
//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//          1         2         3         4         5         6         7         8         9         0         1         2         3  

DbSelectArea("TC7")
DbSetOrder(1)

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � AP5 IDE            � Data �  09/08/01   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

DbSelectArea("TC7")
DbSetOrder(1)


SetRegua(RecCount())

DbGoTop()
While !EOF()

   If lAbortPrint
      @nLin,00 PSAY STR0008 //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   If nLin > 55 
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif
                                                                                                                           
   @ nLin,000 PSAY C7_NUM
   @ nLin,009 PSAY C7_EMISSAO
   @ nLin,020 PSAY C7_DATPRF
   @ nLin,031 PSAY C7_FORNECE
   @ nLin,039 PSAY C7_LOJA
   @ nLin,044 PSAY C7_NREDUZ
   @ nLin,067 PSAY C7_CONTATO
   @ nLin,085 PSAY C7_COND
   @ nLin,097 PSAY SubStr(Y1_NOME,1,20)
   @ nLin,121 PSAY If(C7_ENCER='E','Atendido',If(C7_QUJE=0,'Aberto',If(C7_QUJE>0.And.C7_ENCER<>'E','Atendido Pa','')))

   nLin := nLin + 1 

   DbSkip() 
End

SET DEVICE TO SCREEN

If aReturn[5]==1
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return
