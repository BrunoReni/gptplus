#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA973.CH"

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MATA973   � Autor � Gustavo G. Rueda      � Data �13/12/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao cadastral da tabela CCC - Cadastro do reflexo dos    ���
���          � ajustes na Apura��o de ICMS                                ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MATA973
Local	lRet	:=	.T.

If AliasIndic("CCC")
	Private cCadastro   := STR0001	//"Cadastro do reflexo dos ajustes na Apura��o de ICMS"
	Private aRotina  := MenuDef()
	
	mBrowse( 6, 1,22,75,"CCC")
Else
	MsgAlert("CCC n�o encontrado no dicionario de dados!" + Chr(13)+Chr(10) + "Solu��o: Execute o UPDSPED para atualiza��o de dicion�rio")
EndIf

Return lRet                                                                                    


/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { { oemtoansi("Pesquisar"),"AxPesqui", 0 , 1},; // "Pesquisar"
	{ oemtoansi("Visualizar"),"AxVisual", 0 , 2},; // "Visualizar"
	{ oemtoansi("Incluir"),"A973IncSYP", 0 , 3},; //"Incluir"
	{ oemtoansi("Alterar"),"A973AltSYP", 0 , 4},; //"Alterar"
	{ oemtoansi("Excluir"),"A973DelSYP", 0 , 5}}  //"Excluir"

If ExistBlock("MA973MNU")
	ExecBlock("MA973MNU",.F.,.F.)
EndIf

Return(aRotina)

Function A973IncSYP(cAlias,nReg,nOpc,aAcho,cFunc,aCpos)
	AxInclui(cAlias,nReg,nOpc,aAcho,cFunc,aCpos,/*cOkFunc*/,/*lF3*/,"")
Return

Function A973AltSYP(cAlias,nReg,nOpc,aAcho,cFunc,aCpos)
	AxAltera(cAlias,nReg,nOpc,aAcho,cFunc,aCpos,/*cOkFunc*/,/*lF3*/,"")
Return

Function A973DelSYP(cAlias,nReg,nOpc,aAcho,cFunc,aCpos)
	AxDeleta(cAlias,nReg,nOpc,"",aCpos)
Return
