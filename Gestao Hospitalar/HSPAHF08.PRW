#INCLUDE "HSPAHF08.ch"
#include "protheus.CH"
#include "colors.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � HSPAHF08 � Autor � Gilson da Silva    � Data �  05/05/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � Ficha de Evolucao do Paciente                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Modulo Gestao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHF08()
Local nCont := 0
Local cCab01    := ""

cTitulo   := STR0002 //"EVOLUCAO CINICA"
cNomeRel  := "HSPAHF08"
nLin      := 0

If nLastKey == 27
	Return(nil)
Endif

nTipo := If(aReturn[4]==1,15,18)

cCAB01 := STR0001 //"F O R M U L A R I O     D E      E V O L U C A O     C L I N I C A "

Cabec(cTitulo,	cCab01, "", cNomeRel, H44GetTam(), H44GetTip())


@ PROW()+01,00     PSAY STR0003 + GCY->GCY_REGATE + "   " + GCY->GCY_NOME + "        " + STR0004 + GCY->GCY_QUAINT+"/"+GCY->GCY_LEIINT //"Registro.: "###"      Leito: "
@ PROW()+03,00     PSAY PADC(STR0005,132)//"E V O L U C A O   D O   P A C I E N T E" 
@ PROW()   ,00     PSAY PADC(STR0005,132)//"E V O L U C A O   D O   P A C I E N T E"
@ prow()+2,00      PSAY STR0006 //"+-------------+----------------------------------------------------------------------------------------------------------------+"
@ prow()+1,00      PSAY STR0007 //"|   DATA      |                                                                                                                |"
@ prow()+1,00      PSAY STR0006
For nCont = 1 To 25   
 @ prow()+1,00     PSAY STR0008 //"|             |                                                                                                                |"
 @ prow()+1,00     PSAY STR0006
Next
Return
