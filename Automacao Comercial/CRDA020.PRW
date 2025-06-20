#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRDA020.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CRDA020   � Autor � Fernando Salvatori � Data �  17/06/2003 ���
�������������������������������������������������������������������������͹��
���Descricao � Script para classificacao de credito.                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.           ���
�������������������������������������������������������������������������͹��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������͹��
���              �        �      �                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CRDA020

Private cCadastro := STR0001//"Cadastro de script para classifica��o de cr�dito"

Private aRotina := MenuDef()

dbSelectArea("MAF")
dbSetOrder(1)

mBrowse(6,1,22,75,"MAF")

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Conrado Q. Gomes      � Data � 13.12.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CRDA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
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
	Local aRotina := {	{STR0002 ,"AxPesqui" ,0 ,1 ,0 ,.F.} ,;//"Pesquisar"
						{STR0003 ,"AxVisual" ,0 ,2 ,0 ,.T.} ,;//"Visualizar"
						{STR0004 ,"AxInclui" ,0 ,3 ,0 ,.T.} ,;//"Incluir"
						{STR0005 ,"AxAltera" ,0 ,4 ,0 ,.T.} ,;//"Alterar"
						{STR0006 ,"CA020Del" ,0 ,5 ,0 ,.T.} }//"Excluir"
Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CA020Del  �Autor  �Fernando Salvatori  � Data �  17/06/2003 ���
�������������������������������������������������������������������������͹��
���Desc.     � Exclusao de Script                                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CDRA020                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CA020Del(cAlias,nRecno,nOpc)
Local lFound  := .F.  //Consiste se foi encontrado a regra no arquivo SLJ.
Local cArqTmp := ""   //Indice tempor�rio.
Local nIndex  := 0    //Indices do SLJ

//��������������������������������������������������������������������������Ŀ
//�Cadastro de Identificacao de Lojas                                        �
//����������������������������������������������������������������������������
dbSelectArea( "SLJ" )
dbSetOrder( 1 )

//��������������������������������������������������������������������������Ŀ
//�Retiro um Alias para geracao do arquivo temporario                        �
//����������������������������������������������������������������������������
cArqTmp := GetNextAlias()
	
//��������������������������������������������������������������������������Ŀ
//�Criando indice para Codigo da Regra.                                      �
//����������������������������������������������������������������������������
IndRegua( "SLJ",cArqTmp,"LJ_FILIAL+LJ_CODREG" )
nIndex := RetIndex("SLJ")

#IFNDEF TOP
	dbSetIndex( cArqTmp + OrdBagExt() )
#ENDIF

dbSetOrder(nIndex+1)

//��������������������������������������������������������������������������Ŀ
//�Verificando a integridade referencial Regras X Ident. de Lojas            �
//����������������������������������������������������������������������������
If ( lFound := dbSeek( xFilial( "SLJ" )+MAF->MAF_CODREG ) )
	//"A Regra selecionada est� sendo utilizada por outra loja. Acesse a rotina de Identif. de Lojas e exclua a regra."//"Aten��o"
	MsgStop( STR0007,STR0008 )
EndIf

//��������������������������������������������������������������������������Ŀ
//�Restaurando filtro do arquivo.                                            �
//����������������������������������������������������������������������������
dbSelectArea("SLJ")
RetIndex("SLJ")
FErase( cArqTmp + OrdBagExt() )
dbSetOrder( 1 )

//��������������������������������������������������������������������������Ŀ
//�Efetuando a exclusao.                                                     �
//����������������������������������������������������������������������������
dbSelectArea( "MAF" )
If !lFound
	AxDeleta( cAlias,nRecno,nOpc )
EndIf

Return .T.
