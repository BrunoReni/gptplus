#Include "VEICM580.CH"
#Include "Protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � VEICM580 | Autor �  Ronaldo A. Ferreira  � Data � 09/08/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Segmento de Mercado para o CEV                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION VEICM580()

PRIVATE aCampos := {}
PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0001)

mBrowse( 6, 1,22,75,"VCH")

Return

Static Function MenuDef()
	Local aRotina := { { STR0002 ,"AxPesqui", 0 , 1},;		&& Pesquisar
								{ STR0003 ,"AXVISUAL", 0 , 2 },;	&& Visualizar
								{ STR0004 ,"AXINCLUI", 0 , 3 },;	&& Incluir
								{ STR0005 ,"AXALTERA", 0 , 4 },;	&& Alterar
								{ STR0006 ,"AXDELETA", 0 , 5 }}	&& Excluir
Return aRotina
