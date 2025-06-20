#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"                                           
#INCLUDE "COLORS.CH"
#INCLUDE "GPEA660.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPEA660   �Autor  �Valdeci Lira        � Data �  07/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Manutencao da tabela RGC [ Localidade de Pagamento ]       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������Ĺ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĺ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĺ��
���Cecilia Car.�15/05/14�TPPCSB�Incluido o fonte da 11 para a 12 e efetua-���
���            �        �      �da a limpeza.                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GPEA660()

    If( MV_MODFOL == "2" ) .OR. (cPaisLoc == "COL") .OR. (cPaisLoc == "BRA")
		Private cCadastro := OemToAnsi(STR0001)
		AxCadastro("RGC", cCadastro, "GP660Excl()" )
  	Else
		Help("",1,"NAO_DISPONIVEL",,OemToAnsi(STR0002),5,0 ) //"Verifique o parametro MV_MODFOL!"
  	EndIf

Return (.T.)

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �GP660Excl   �Autor�Mohanad Odeh     � Data �05/04/2012      �
�����������������������������������������������������������������������Ĵ
�Descri��o �Valida Exclus�o de Localidade do Pagamento verificando se   �
�          �est� em uso no cadastro de funcion�rios						�
�����������������������������������������������������������������������Ĵ
�Sintaxe   ��GP660Excl()										        �
�����������������������������������������������������������������������Ĵ
�Parametros�vide parametros formais 									�
�����������������������������������������������������������������������Ĵ
�Uso       �GPEA660()	                                                �
�������������������������������������������������������������������������/*/
Function GP660Excl(cAlias,nReg,nOpc)
Local lRet := .T.
Local aArea := GetArea()
Local aAreaSRA		:= SRA->( GetArea() )

DbSelectArea("SRA")
DbSetOrder(1)
While !Eof()  

If cPaisLoc <> "BRA"
	If xFilial("RGC", RA_FILIAL) == RGC->RGC_FILIAL .AND. SRA->RA_KEYLOC == RGC->RGC_KEYLOC
		lRet := .F.
		Exit
	EndIf
Else
	If xFilial("RGC", RA_FILIAL) == RGC->RGC_FILIAL .AND. SRA->RA_LOCBNF == RGC->RGC_KEYLOC
    	lRet := .F.
    	Exit
	EndIf
EndIf

DbSkip()
EndDo

If !lRet
	Alert(OemToAnsi(STR0003)) // "Este registro n�o pode ser exclu�do, pois est� em uso no cadastro de Funcion�rios"
EndIf

RestArea(aAreaSRA)
RestArea(aArea)
Return lRet