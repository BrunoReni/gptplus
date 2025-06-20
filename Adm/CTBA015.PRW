#INCLUDE "CTBA015.CH"
#INCLUDE "PROTHEUS.CH"


// 17/08/2009 -- Filial com mais de 2 caracteres

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CTBA015  � Autor � Marco Bianchi         � Data � 16/18/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Cadastro de Contabilistas                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBA015()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MP8                                                        ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CTBA015(nOpcAuto,aAuto)

// rotina de atualiza��o do CVB
AxCadastro("CVB",STR0001,".T.",".T.",,,,,,,aAuto,nOpcAuto,,)	// "Cadastro do Contabilista"

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A015CGC   � Autor � Marco Bianchi         � Data � 17/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Validacao do campo CVB_CGC. Qd Pessoa="J" nao permitir      ���
���          �entrada de CPF                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Cadastro de Contabilistas                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/   
Function A015CGC(cTipPes,cCNPJ)

//��������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                      �
//����������������������������������������������������������������
Local aArea     := GetArea()
Local aAreaCVB  := CVB->(GetArea())
Local lRetorno  := .T.
Local cCNPJBase := ""
DEFAULT cCNPJ   := &(ReadVar())

//��������������������������������������������������������������Ŀ
//� Valida o tipo de pessoa                                      �
//����������������������������������������������������������������
If cTipPes == "F" .And. !(Len(AllTrim(cCNPJ))==11)
	Help(" ",1,"CPFINVALID")
	lRetorno := .F.
ElseIf cTipPes == "J" .And. !(Len(AllTrim(cCNPJ))==14)  
	Help(" ",1,"CGC")     
	lRetorno := .F.
EndIf
//��������������������������������������������������������������Ŀ
//� Valida a duplicidade do CGC                                  �
//����������������������������������������������������������������
If lRetorno .And. Pcount() > 1 
	If cTipPes == "J"
		dbSelectArea("CVB")
		dbSetOrder(2)
		If MsSeek(xFilial("CVB")+cCNPJ)
			Aviso(STR0002,STR0003+CVB->CVB_CODCTB+"/"+CVB->CVB_NOME+".",{"Ok"})//"Aten��o"###"O CNPJ informado j� foi utilizado para o contabilista "
			lRetorno := .F.
		EndIf
		If lRetorno
			cCNPJBase := SubStr(cCNPJ,1,8)
			dbSelectArea("CVB")
			dbSetOrder(2)
			If MsSeek(xFilial("CVB")+cCNPJBase) .And. M->CVB_CODCTB <> CVB->CVB_CODCTB
				If Aviso(STR0002,STR0003+CVB->CVB_CODCTB+" - "+CVB->CVB_NOME+".",{STR0004,STR0005},2)==2//"Aten��o"###"O CNPJ informado j� foi utilizado para o contabilista "###"Aceitar"###"Cancelar"
				   lRetorno := .F.
				EndIf
			EndIf
		EndIf
	Else
		dbSelectArea("CVB")
		dbSetOrder(3)
		If MsSeek(xFilial("CVB")+cCNPJ) .And. M->CVB_CODCTB <> CVB->CVB_CODCTB
			If Aviso(STR0002,STR0006+CVB->CVB_CODCTB+" - "+CVB->CVB_NOME+".",{STR0004,STR0005},2)==2//"Aten��o"###"O CPF informado j� foi utilizado no Contabilista "###"Aceitar"###"Cancelar"
			   lRetorno := .F.
			EndIf
		EndIf		
	EndIf
EndIf

RestArea(aAreaCVB)
RestArea(aArea)
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �Microsiga           � Data �  xx/xx/xx   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MenuDef()

Return StaticCall(MATXATU,MENUDEF)

