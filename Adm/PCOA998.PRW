#Include "Protheus.ch"
#Include "Inkey.Ch"
#INCLUDE "PCOA998.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PCOA998  � Autor � Abel Ribeiro          � Data � 18/10/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Limites Contas Orcamentarias                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PCOA998                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCO                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function PCOA998()

Private aRotina := MenuDef()

Private cCadastro := OemToAnsi(STR0006)  //"Cadastro de Limites Projetos"

mBrowse(,,,,"AMV")

Return

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �PCOA998Mnt�  Autor �Abel Ribeiro         � Data �18/10/2010 �
�����������������������������������������������������������������������Ĵ
�Descri��o �Rotina de Manutencao nas opcoes Do Menu                     �
�          �                                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �PCOA998Mnt( cAlias , nReg , nOpc )							�
�����������������������������������������������������������������������Ĵ
�Parametros�cAlias = Alias do arquivo                                   �
�          �nReg   = Numero do registro                                 �
�          �nOpc   = Numero da opcao selecionada                        �
�����������������������������������������������������������������������Ĵ
� Uso      �GpeA670()	                                                �
�������������������������������������������������������������������������*/
Function PCOA998Mnt( cAlias , nReg , nOpc )
	Local aAlter  := {'AMV_PROJOR','AMV_DESPRO','AMV_CODCON','AMV_DESCTA','AMV_LIMITE'}

	If nOpc == 2 // Visualizar
		AxVisual(cAlias,nReg,nOpc,aAlter)
	ElseIf nOpc == 4 // Alterar
		AxAltera(cAlias,nReg,nOpc,aAlter,aAlter,,,,,,,,,,,)
	ElseIf nOpc == 3 // Incluir   
		AxInclui(cAlias,nReg,nOpc,aAlter,,,,,,,,,,,,,)
	ElseIf nOpc == 5
		If (AxVisual(cAlias,nReg,nOpc,aAlter)) == 1
	        RecLock("AMV",.F.)
    	    AMV->(DbDelete())
        	AMV->(MsUnLock())
  		EndIf
	EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |FVldCodCon�Autor  �Jair Ribeiro        � Data �  10/27/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o campo AMV_CODCON                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       | SIGAPCO					                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FVldCodCon(nOpc)
	Local llRet	:= .T.
	Local Area	:= AK5->(GetArea())
	If nOpc == 1
		If llRet:= NaoVazio(M->AMV_PROJOR)
			If llRet:= ExistCpo('AMX')
				DbSelectArea("AMV")
				AMV->(DbSetOrder(1))
				If AMV->(Dbseek(xFilial("AMV")+M->AMV_PROJOR+M->AMV_CODCON))
					Aviso(STR0007,STR0009,{STR0008}) //Aten��o#"Conta j� se encontra com Limite no projeto em quest�o"#Ok
					llRet :=.F.
				EndIf
			EndIf
		EndIf
	ElseIf nOpc == 2
		If llRet:= NaoVazio(M->AMV_CODCON)
			If llRet:= ExistCpo("AK5")
				DbSelectArea("AMV")
				AMV->(DbSetOrder(1))
				If AMV->(Dbseek(xFilial("AMV")+M->AMV_PROJOR+M->AMV_CODCON))
					Aviso(STR0007,STR0009,{STR0008}) //Aten��o#"Conta j� se encontra com Limite no projeto em quest�o"#Ok
					llRet :=.F.
				Else		
					DbSelectArea("AK5")
					CTT->(DbSetOrder(1))
					If AK5->(DbSeek(xFilial("AK5")+M->AMV_CODCON))
						If AK5->AK5_TIPO == '1' //Conta Sintetica
							Aviso(STR0007,STR0010,{STR0008})  //Aten��o#"N�o pode ser definido valor para Conta Sint�tica"#Ok
							llRet	:= .F.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(Area)
Return llRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MenuDef  �Autor  � Pedro Pereira Lima � Data �  09/28/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aRotina := {{ STR0001 , "PESQBRW"	    , 0 , 1 ,0, .F.} ,;	//"Pesquisar"
						{ STR0002 , "PCOA998Mnt"	, 0 , 2 ,0, Nil} ,;	//"Visualizar"
						{ STR0003 , "PCOA998Mnt"	, 0 , 3 ,0, Nil} ,;	//"Incluir"  
						{ STR0004 , "PCOA998Mnt"	, 0 , 4 ,0, Nil} ,;	//"Alterar"  
						{ STR0005 , "PCOA998Mnt"	, 0 , 5 ,0, Nil}} ;	//"Excluir"  
						
Return aRotina