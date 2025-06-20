#INCLUDE "CDAA080.ch"
#Include "FiveWin.Ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CdaA080  � Autor � Wagner Mobile Costa   � Data � 19/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Programa de manutencao do cadastro de licitacoes           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaCda                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function CdaA080
// a vari�vel aMemos � necess�ria para salvar o campo de observa��o
// quando utiliza-se a fun��o AxInclui()
// esses campos soh s�o validados em caso de existencia do templante CCT, pois 
// fazem parte desse template.
If HasTemplate("CCT")
	Private aMemos := {{"AH9_CODMEM", "AH9_OBS"}}
EndIf

PRIVATE aRotina 	:= MenuDef()

//��������������������������������������������������������������Ŀ
//� Define o titulo da manutencao					             �
//����������������������������������������������������������������
PRIVATE cCadastro := STR0006 //"Cadastro de licitacoes"

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
If AMIIn(44,45)
	mBrowse( 6, 1,22,75, "AH9")
EndIf

Return .T.

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()
     

Private aRotina 	:= { 	{ STR0001	, "AxPesqui"  	, 0 , 1, 0, .F.},; //"Pesquisar"
								{ STR0002	, "AxVisual"  	, 0 , 2, 0, NIL},; //"Visualizar"
								{ STR0003	, "AxInclui"  	, 0 , 3, 0, NIL},; //"Incluir"
								{ STR0004	, "AxAltera"  	, 0 , 4, 0, NIL},; //"Alterar"
								{ STR0005	, "CDA080DEL" 	, 0 , 5, 0, NIL},; //"Excluir"
								{ STR0007	, "MSDOCUMENT"	, 0 , 4, 0, NIL} } //"Conhecimento"


If ExistBlock("CD080MNU")
	ExecBlock("CD080MNU",.F.,.F.)
EndIf

Return(aRotina)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CdaA080  � Autor �Marivaldo				� Data � 09/08/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Validacao na exlcusao da licitacao                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaCda                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CDA080DEL()
Local cQuery    := ""
Local cAliasQry := GetNextAlias() 

DbSelectArea("SC5")
dbSetOrder(1) 

DbSelectArea("AH9")
dbSetOrder(1)

cQuery := "SELECT C5_NUM "		
cQuery += " FROM "
cQuery += RetSqlName( "SC5" ) + " SC5 "
cQuery += " WHERE "
cQuery += " SC5.C5_COTACAO = '" + AH9->AH9_CODLIC + "' AND "
cQuery += " SC5.D_E_L_E_T_  <> '*' "

cQuery := ChangeQuery( cQuery ) 
		
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

dbSelectArea(cAliasQry)
DbGoTop()		

If !Empty((cAliasQry)->C5_NUM) 
	MsgAlert(STR0008)
Else
	AxDeleta("AH9",AH9->(Recno()),5)
EndIf

dbCloseArea()	

Return