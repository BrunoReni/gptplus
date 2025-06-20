#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AJSXCSA.CH"

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
�������������������������������������������������������������������������������ͱ�
���Programa    �AjSXACSA   �Autor    �Inova��o - RH       � Data �  29/06/2015 ���
������������������������������������������������������������������������������͹��
���Desc.       � Fonte respons�vels pelos ajustas na vers�o p12.               ���
���            �                                                               ���
������������������������������������������������������������������������������͹��
���Programador � DATA      � Chamado     �  MOTIVO DA ALTERACAO                ���
���Gabriel A.  �10/08/2016 �TVTQ84       �Ajuste no inicializador padr�o do    ���
���            �           �             �campo RBH_DIMPOR.                    ���
���Esther V.   �30/10/2016 �TVOH80       �Ajuste no usado dos campos RBD_FILIAL���
���            �           �             �e RB8_FILIAL.                        ���
���Oswaldo L   �27-04-17   �DRHPONTP300  �Entre os dias 24-04-17 e 26-04-17    ���
���            �           �             �baixamos os fontes do TFS das pastas ���
���            �           �             �MAIN, 12.1.14 e 12.1.16. Conforme    ���
���            �           �             �solicitado fizemos merge delas,depois���
���            �           �             �removemos alteracoes em SX           ���
���Esther V.   �08/05/2017 �DRHPONTP-330 �Incluida validacao de compartilhamen-���
���            �           �             �to p/ tabelas envolvendo campo _MAT. ���
���M. Silveira �09/05/2017 �DRHPONTP-444 �Ajuste p/ permitir alterar o tamanho ���
���            �           �             �do campo RB6_COEFIC.                 ���
�������������������������������������������������������������������������������ͱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/

Main function CSALoad()

	Local lRet		:= .T.

	lRet := fChkConv12()
	If !lRet
		Return
	EndIf

	ValCompSRA() //valida compartilhamento entre tabelas

Return (.T.)

/*/{Protheus.doc} ValCompSRA
Valida compartilhamento das tabelas que envolvem o campo Matr�cula.
@author esther.viveiro
@since 08/05/2017
@version P12
@return logico, .T. para valida��o OK; .F. para inconsist�ncia no compartilhamento.
/*/
Function ValCompSRA()

Local aCompart:= {}	//Varivael para verificar compartilhamento entre tabelas
Local cTabelas := ""
Local nX := 0

	//VERIFICA COMPARTILHAMENTO ENTRE AS TABELAS SRA/SQ8/SQC/SQ9/RAF/RBI/RBN/SR7/SR3/SR9/RAS
	aAdd(aCompart,{"SRA",FWModeAccess( "SRA", 1) + FWModeAccess( "SRA", 2) + FWModeAccess( "SRA", 3)})
	aAdd(aCompart,{"SQ8",FWModeAccess( "SQ8", 1) + FWModeAccess( "SQ8", 2) + FWModeAccess( "SQ8", 3)})
	aAdd(aCompart,{"SQC",FWModeAccess( "SQC", 1) + FWModeAccess( "SQC", 2) + FWModeAccess( "SQC", 3)})
	aAdd(aCompart,{"SQ9",FWModeAccess( "SQ9", 1) + FWModeAccess( "SQ9", 2) + FWModeAccess( "SQ9", 3)})
	aAdd(aCompart,{"RAF",FWModeAccess( "RAF", 1) + FWModeAccess( "RAF", 2) + FWModeAccess( "RAF", 3)})
	aAdd(aCompart,{"RBI",FWModeAccess( "RBI", 1) + FWModeAccess( "RBI", 2) + FWModeAccess( "RBI", 3)})
	aAdd(aCompart,{"RBN",FWModeAccess( "RBN", 1) + FWModeAccess( "RBN", 2) + FWModeAccess( "RBN", 3)})
	aAdd(aCompart,{"SR7",FWModeAccess( "SR7", 1) + FWModeAccess( "SR7", 2) + FWModeAccess( "SR7", 3)})
	aAdd(aCompart,{"SR3",FWModeAccess( "SR3", 1) + FWModeAccess( "SR3", 2) + FWModeAccess( "SR3", 3)})
	aAdd(aCompart,{"SR9",FWModeAccess( "SR9", 1) + FWModeAccess( "SR9", 2) + FWModeAccess( "SR9", 3)})
	aAdd(aCompart,{"RAS",FWModeAccess( "RAS", 1) + FWModeAccess( "RAS", 2) + FWModeAccess( "RAS", 3)})

	For nX := 2 to Len(aCompart)
		If aCompart[nX,2] != aCompart[1,2]
			cTabelas += aCompart[nX,1] + " ; "
		EndIf
	Next nX

	If !Empty(cTabelas)
		cTabelas := SUBSTR(cTabelas,1,(len(cTabelas)-2))
		//"O Modo de Acesso do relacionamento para as tabelas que envolvem o campo Matricula devem possuir um compartilhamento igual ao cadastro de Funcion�rios!"
		//"Altere o modo de acesso atrav�s do Configurador dos arquivos a seguir:"
		MsgInfo( oEmToAnsi( STR0001 );
		+ CRLF + CRLF + oEmToAnsi( STR0002 ) + CRLF + CRLF + oEmToAnsi( cTabelas ) )
		Return (.F.)
	EndIf

Return (.T.)
