#Include "VEICM620.CH"
#Include "Protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � VEICM620 | Autor � Andre Luis Almeida    � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � RAIC - Tipo de Reclamacao                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION VEICM620()
PRIVATE aCampos := {}
PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0001)
mBrowse( 6, 1,22,75,"VAQ")
Return

Static Function MenuDef()
Local aRotina := { { STR0002 ,"AxPesqui", 0 , 1},;		&& Pesquisar
                     { STR0003 ,"AXVISUAL", 0 , 2},;	&& Visualizar
                     { STR0004 ,"AXINCLUI", 0 , 3 },;	&& Incluir
                     { STR0005 ,"AXALTERA", 0 , 4 },;	&& Alterar
                     { STR0006 ,"AXDELETA", 0 , 5 }}	&& Excluir
Return aRotina
