#Include "VEICM590.CH"
#Include "Protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � VEICM590 | Autor �  Ronaldo A. Ferreira  � Data � 09/08/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Operacao de Veiculo para o CEV                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION VEICM590()

PRIVATE aCampos := {}
PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0001)

mBrowse( 6, 1,22,75,"VCI")

Return

Static Function MenuDef()
Local aRotina := { { STR0002 ,"AxPesqui", 0 , 1},;		&& Pesquisar
                     { STR0003 ,"AXVISUAL", 0 , 2},;	&& Visualizar
                     { STR0004 ,"AXINCLUI", 0 , 3 },;	&& Incluir
                     { STR0005 ,"AXALTERA", 0 , 4 },;	&& Alterar
                     { STR0006 ,"AXDELETA", 0 , 5 }}	&& Excluir
Return aRotina
