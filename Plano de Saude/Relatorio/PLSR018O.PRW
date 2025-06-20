#INCLUDE "plsr018o.ch"
#include "PROTHEUS.CH"
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR018O� Autor � Luciano Aparecido      � Data � 22.03.07 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Demonstrativo de Pagamento  (Odontol�gico)                 ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR018O()                                                 ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSR018O()

	//��������������������������������������������������������������������������Ŀ
	//� Define variaveis padroes para todos os relatorios...                     �
	//����������������������������������������������������������������������������
	Local cDesc1   := STR0001 //"Relat�rio de Pagamento RDA Odontol�gico"
	Local cDesc2   := ""
	Local cDesc3   := " "
	Local Tamanho  := "M"
	Local wRel     := "PLSR018O"
	Local cString  := "BD7"
	Local aOrd     := {}
	//��������������������������������������������������������������������������Ŀ
	//� Parametros do relatorio (SX1)...                                         �
	//����������������������������������������������������������������������������
	Local cCodOpe
	Local cRdaDe
	Local cRdaAte
	Local cAno
	Local cMes
	Local cClaPre
	Local nLayout

	Private cPerg    := "PL018O"
	Private Titulo   := FunDesc() //"Demonstrativo de Pagamentos"
	Private aReturn  := { "Zebrado", 1,"Administra��o", 2, 2, 1, "", 1 }
	Private nLastKey :=0
	Private cabec1   := ""
	Private cabec2   := ""

	//��������������������������������������������������������������������������Ŀ
	//� Acessa parametros do relatorio...                                        �
	//����������������������������������������������������������������������������
	Pergunte(cPerg,.F.)

	//��������������������������������������������������������������������������Ŀ
	//� Chama SetPrint                                                           �
	//����������������������������������������������������������������������������

	wnRel := SetPrint(cString, wRel,cPerg, @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .F., Tamanho)

	//��������������������������������������������������������������������������Ŀ
	//� Verifica se foi cancelada a operacao                                     �
	//����������������������������������������������������������������������������

	If nLastKey = 27
		Set Filter To
		Return
	EndIf

	cCodOpe   := mv_par01
	cRdaDe    := mv_par02
	cRdaAte   := mv_par03
	cAno      := mv_par04
	cMes      := mv_par05
	cClaPre   := mv_par06
    nLayout   := mv_par07

	RptStatus({|lEnd| R018OImp(@lEnd, wnRel, cString,cCodOpe,cRdaDe,cRdaAte,cAno,cMes,cClaPre,nLayout)}, Titulo)


Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R018OImp � Autor � Luciano Aparecido     � Data � 22.03.07 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Chamada do Relatorio                                       ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/

Static Function R018OImp(lEnd, wnRel, cString, cCodOpe, cRdaDe, cRdaAte, cAno, cMes, cClaPre, nLayout)
Local cTissVer := PLSTISSVER()
Local aDados    := {}

If (cTissVer == NIL) 
	Return
EndIf
aAdd(aDados, MtaDados(cCodOpe, cRdaDe, cRdaAte, cAno, cMes, cClaPre, cTissVer))


If (cTissVer < "3") 
	PLSTISSB(aDados, nLayout)
Else
	PLSTISSBB(aDados, nLayout)
EndIf

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � MtaDados  � Autor � Luciano Aparecido    � Data � 22.03.07 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � chama a funcao "PLSDPGTOD"                                 ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/

Static Function MtaDados(cCodOpe, cRdaDe, cRdaAte, cAno, cMes, cClaPre, cTissVer)

Local aDados := {}

If (cTissVer == "") 
	Return()
EndIf

// Funcao que monta o array com os dados da guia
If (cTissVer < "3")
	aDados := PLSDPGTOD(cCodOpe, cRdaDe, cRdaAte, cAno, cMes, cClaPre)
Else
	aDados := PLSDPGTODB(cCodOpe, cRdaDe, cRdaAte, cAno, cMes, cClaPre)
EndIf

Return aDados