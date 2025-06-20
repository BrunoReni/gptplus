#INCLUDE "acda040.ch" 
 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ACDA040  � Autor � Nilton Pereira        � Data � 05/04/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de tipos de embalagens                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nil                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ACDA040 

Private aRotina := Menudef()
AxCadastro("CB3",STR0001,/*cDel*/,/*cOk*/,/*aRotAdic*/,/*bPre*/,/*bOK*/,/*bTTS*/,/*bNoTTS*/,/*aAuto*/,/*nOpcAuto*/, /*Arotina*/,/*aACS*/,/*cTela*/,.T.) //"Tipos de embalagens"

Return

/*/{Protheus.doc} Menudef
	(long_description)
	@type  Static Function
	@author TOTVS
	@since 21/02/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function MenuDef()

Local aRotMenu := { }


aRotMenu := { { oemtoansi(STR0002),"AxPesqui", 0 , 1,,.F.},; // "Pesquisar"
	{ oemtoansi(STR0003),"AxCadVis", 0 , 2},; // "Visualizar"
	{ oemtoansi(STR0004),"AxCadInc", 0 , 3},; //"Incluir"
	{ oemtoansi(STR0005),"AxCadAlt", 0 , 4},; //"Alterar"
	{ oemtoansi(STR0006),"AxCadDel", 0 , 5}}  //"Excluir"

return aRotMenu
 
