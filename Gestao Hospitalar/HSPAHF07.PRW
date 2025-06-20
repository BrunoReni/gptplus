#INCLUDE "HSPAHF07.ch"
#include "protheus.CH"
#include "colors.CH"
/*      		
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FICHA007 � Autor � Gilson da Silva    � Data �  05/05/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � Formulario de Prescriscao Medica                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Modulo Gestao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHF07()
Local cCab01    := ""

cTitulo   := STR0002 //"PRESCRICAO MEDICA"
cNomeRel  := "HSPAHF07"
nLin      := 0

GCZ->(DbSetOrder(2))
GCZ->(DbSeek(xFilial("GCZ")+ GCY->GCY_REGATE))

If nLastKey == 27
	Return(nil)
Endif

nTipo := If(aReturn[4]==1,15,18)

cCAB01 := STR0001 //"F O R M U L A R I O     D E      P R E S C R I C A O     M E D I C A "

Cabec(cTitulo,	cCab01, "", cNomeRel, H44GetTam(), H44GetTip())

@ PROW(),00        PSAY STR0004 + GCY->GCY_REGGER + "-" + GCY->GCY_NOME + STR0005 + GCY->GCY_REGATE  // "Paciente: "  //  "  Registro: "
@ PROW()+01,00     PSAY STR0006 + GCY->GCY_CODCRM + "-" + POSICIONE("SRA", 11, XFILIAL("SRA") + GCY->GCY_CODCRM, "RA_NOME") //"Medico..: "
@ PROW()+01,00     PSAY STR0003 + GCZ->GCZ_CODCON + "-" + POSICIONE("GA9", 1, XFILIAL("GA9")  + GCZ->GCZ_CODCON, "GA9_NREDUZ") //"Convenio: "
@ PROW()+01,00     PSAY STR0009 + GCZ->GCZ_CODPLA + "-" + POSICIONE("GCM", 2, XFILIAL("GCM")  + GCZ->GCZ_CODPLA, "GCM_DESPLA") //"Plano: "
@ PROW()+01,00     PSAY "+------+-------------------------------------------------------------+----+----+"
@ PROW()+01,00     PSAY STR0007   //"| Item |                          Prescricao Medica                  |UTIL|DEV |"
@ PROW()+01,00     PSAY "+------+-------------------------------------------------------------+----+----+"
@ PROW()+01,00     PSAY "|      |                                                             |    |    |"
@ PROW()+01,00     PSAY "+------+-------------------------------------------------------------+----+----+"
@ PROW()+01,00     PSAY "|      |                                                             |    |    |"
@ PROW()+01,00     PSAY "+------+-------------------------------------------------------------+----+----+"
@ PROW()+01,00     PSAY "|      |                                                             |    |    |"
@ PROW()+01,00     PSAY "+------+-------------------------------------------------------------+----+----+"
@ PROW()+01,00     PSAY "|      |                                                             |    |    |"
@ PROW()+01,00     PSAY "+------+-------------------------------------------------------------+----+----+"
@ PROW()+01,00     PSAY "|      |                                                             |    |    |"
@ PROW()+01,00     PSAY "+------+-------------------------------------------------------------+----+----+"
@ PROW()+01,00     PSAY "|      |                                                             |    |    |"
@ PROW()+01,00     PSAY "+------+-------------------------------------------------------------+----+----+"
@ PROW()+01,00     PSAY "|      |                                                             |    |    |"
@ PROW()+01,00     PSAY "+------+-------------------------------------------------------------+----+----+"
@ PROW()+02,00     PSAY "+-----------+-----------------------------------------------------------------------------------------------------------------------+"
@ PROW()+01,00     PSAY STR0008   //"| Item      |                          Horario                                                                                      |"
@ PROW()+01,00     PSAY "+-----------+-----------------------------------------------------------------------------------------------------------------------+"  + chr(15)
//                    0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
@ PROW()+01,00     PSAY "              07   08   09   10   11   12   13   14   15   16   17   18   19   20   21   22   23   24   01   02   03   04   05   06  "
@ PROW()+01,00     PSAY "+-----------+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+"
@ PROW()+01,00     PSAY "|           |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |"
@ PROW()+01,00     PSAY "+-----------+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+"
@ PROW()+01,00     PSAY "|           |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |"
@ PROW()+01,00     PSAY "+-----------+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+"
@ PROW()+01,00     PSAY "|           |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |"
@ PROW()+01,00     PSAY "+-----------+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+"
@ PROW()+01,00     PSAY "|           |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |"
@ PROW()+01,00     PSAY "+-----------+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+"
@ PROW()+01,00     PSAY "|           |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |"
@ PROW()+01,00     PSAY "+-----------+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+"
@ PROW()+01,00     PSAY "|           |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |"
@ PROW()+01,00     PSAY "+-----------+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+"
@ PROW()+01,00     PSAY "|           |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |"
@ PROW()+01,00     PSAY "+-----------+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+" + chr(18)
@ PROW()+02,00     PSAY "+------------------------------------------------------------------------------+"
@ PROW()+01,00     PSAY "|  Equipamentos           UTI(  )       APT(  )        ENF (  )                |"
@ PROW()+01,00     PSAY "+-----------------+-------------+-------+---------------+-------------+--------+"
@ PROW()+01,00     PSAY "|   Descricao     |____Horas____| Total |  Descricao    |____Horas____| Total  |"
@ PROW()+01,00     PSAY "|                 | Lig  | Desl |       |               | Lig  | Desl |        |"
@ PROW()+01,00     PSAY "+-----------------+------+------+-------+---------------+------+------+--------+"
@ PROW()+01,00     PSAY "|Oxigenio Cateter |      |      |       |Bomba Infusao  |      |      |        |"
@ PROW()+01,00     PSAY "+-----------------+------+------+-------+---------------+------+------+--------+"
@ PROW()+01,00     PSAY "|Oxigenio Pressao |      |      |       |Monitorizacao  |      |      |        |"
@ PROW()+01,00     PSAY "+-----------------+------+------+-------+---------------+------+------+--------+"
@ PROW()+01,00     PSAY "|Macronebulizacao |      |      |       |Oximetro       |      |      |        |"
@ PROW()+01,00     PSAY "+-----------------+------+------+-------+---------------+------+------+--------+"
@ PROW()+01,00     PSAY "|                 |      |      |       |               |      |      |        |"
@ PROW()+01,00     PSAY "+-----------------+------+------+-------+---------------+------+------+--------+"
@ PROW()+01,00     PSAY "|                 |      |      |       |               |      |      |        |"
@ PROW()+01,00     PSAY "+-----------------+------+------+-------+---------------+------+------+--------+"
Return()
