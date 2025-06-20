#INCLUDE "ofioa080.ch"
#Include 'Protheus.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OFIOA080 � Autor �  Fabio                � Data � 30/06/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Periodos                                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OFIOA080
PRIVATE cCadastro := OemToAnsi(STR0001) //"Periodos"

AxCadastro("VOH",cCadastro,"OA080E()")

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �OA080E    �Autor  �Fabio / Renata      � Data �  08/23/00   ���
�������������������������������������������������������������������������͹��
���Desc.     � Excluir   Periodo                                          ���
�������������������������������������������������������������������������͹��
���Uso       � Oficina                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OA080E(cAlias,nReg,nOpc)
Local aVetValid := {}
Aadd(aVetValid, { "VOE" , "VOE_CODPER" , VOH->VOH_CODPER  , NIL } )
Return FG_DELETA( aVetValid )

Static Function MenuDef()
Return StaticCall(MATXATU,MENUDEF)

/*/{Protheus.doc} OFA0800016_PeriodoBloqueado
Verificando Bloqueio do Per�odo (Hor�rios)
@author Fernando Vitor Cavani
@since 16/01/2020
@version undefined
@type function
@param  cCodigo  caracter C�digo VOH
@param  lShowHlp l�gico   Mostrar Mensagem de Bloqueio
@return lBloq    l�gico   Bloqueado (Sim / N�o)
/*/
Function OFA0800016_PeriodoBloqueado(cCodigo, lShowHlp)
Local cMsg       := ""
Local lBloq      := .F.
Local aArea
Local aAreaA1

Default cCodigo  := ""
Default lShowHlp := .T.

If VOH->(FieldPos("VOH_MSBLQL")) > 0
	aArea   := GetArea()
	aAreaA1 := VOH->(GetArea())

	dbSelectarea("VOH")
	If !Empty(cCodigo)
		dbSetOrder(1)
		msSeek(xFilial("VOH") + cCodigo)
	EndIf

	If VOH->(Found()) .And. VOH->VOH_MSBLQL == "1"
		lBloq := .T.
	EndIf

	If lBloq .And. lShowHlp
		cMsg := chr(13) + chr(10) + "VOH - " + STR0001 + chr(13) + chr(10) // Per�odos
		cMsg += RetTitle("VOH_CODPER") + ":" + VOH->VOH_CODPER + chr(13) + chr(10)

		HELP(" ", 1, "REGBLOQ",, cMsg, 3, 1)
	EndIf

	RestArea(aAreaA1)
	RestArea(aArea)
EndIf
Return lBloq