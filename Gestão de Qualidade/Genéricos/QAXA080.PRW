//#INCLUDE "QAXA080.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QAxA080  � Autor � Sandra Ribeiro Claudio� Data � 01/01/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Palavras             					      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPPAP                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QAXA080(aRotAuto, nOpc)

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
PRIVATE aRotina := {  {"Pesquisar","AxPesqui"  ,  0 , 1   },;  // "Pesquisar"
				  	  {"Visualizar","AxVisual"  ,  0 , 2   },;  // "Visualizar"
					  {"Incluir","QA80Inclui",  0 , 3   },;  // "Incluir"
					  {"Alterar","QA80Altera",  0 , 4   },;  // "Alterar"
					  {"Excluir","AxDeleta", 0 , 5, 3} }   // "Excluir"

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������

Private cCadastro := "Cadastro de Palavras"  //"Cadastro de Palavras"
Private nSaveSX8 := GetSX8Len()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������

mBrowse( 6, 1,22,75,"QAL")

Return(.T.)
       
/*     
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA80Inclui� Autor � Sandra Ribeiro Claudio� Data �01/01/09  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Palavras 						  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QA80Inclui(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QAxA080                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QA80Inclui(cAlias,nReg,nOpc)

Local nOpcA := 0

Private aTELA[0][0],aGETS[0]



//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������

While .T.
	
	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	nOpcA := 0
	
	Begin Transaction
		
	nOpcA := AxInclui( cAlias, nReg, nOpc,,,,"QA80TudoOk()")
	
	End Transaction
	
	Exit             
	
EndDo

dbSelectArea(cAlias)

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA80Altera� Autor � Paulo Emidio de Barros� Data �18/10/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualizacao de Palavras 									  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Qa80Altera(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QAXA080                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION QA80Altera(cAlias,nReg,nOpc)
Local nOpcA :=0 

Private aTELA[0][0],aGETS[0]

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������

While .T.
	
	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	nOpcA :=0
	
	Begin Transaction
		
		nOpcA:=AxAltera( cAlias, nReg, nOpc, , , , ,"AllwaysTrue()")
	
	End Transaction
	
	Exit
EndDo


dbSelectArea(cAlias)
Return(NIL)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QA10TudoOk� Autor �Paulo Emidio de Barros � Data � 20/07/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Realiza as consistencias antes da gravacao dos dados		  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADA010                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QA80TudoOk()

Local nEspaco
Local lRet     := .T. 
Local cSilaba  := ""
Local cPalavra := "" 

DbSelectArea ("QAL")
DbSetOrder(1)

If QAL->(DbSeek(xFilial("QAL")+(AllTrim(M->QAL_PALAV))))
	MsgAlert("Esta palavra j� foi cadastrada!","Aviso")
	lRet := .F.
EndIf 

cSilaba := M->QAL_SILABA
nEspaco := At(" ",AllTrim(cSilaba)) 

While nEspaco > 0 .OR. Len(cSilaba) <> 0
	If nEspaco > 0 .AND. Len(cSilaba) <>0
		cPalavra += AllTrim(SubStr(AllTrim(cSilaba),1,nEspaco))
		cSilaba := Alltrim(Stuff(cSilaba,1,nEspaco,""))
		nEspaco:= At(" ",AllTrim(cSilaba))
	ElseIf nEspaco == 0 .AND. Len(cSilaba) <>0
		cPalavra += AllTrim(cSilaba)
		cSilaba := ""
	EndIf
EndDo

If AllTrim(cPalavra) <> AllTrim(M->QAL_PALAV)
	MsgAlert("A palavra dividida n�o corresponde com a palavra cadastrada!","Aviso")
	lRet := .F.
EndIf  

Return(lRet)