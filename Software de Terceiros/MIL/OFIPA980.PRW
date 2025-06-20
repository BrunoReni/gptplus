#INCLUDE "TOTVS.CH"
#include "OFIPA980.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OFIPA980 � Autor �  Emilton              � Data � 24/06/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Parametro da Fabrica                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OFIPA980()
Private cCadastro := OemToAnsi(STR0006)

/////////////////////////////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar os modulos de Veiculos, Oficina ou Auto-Pe�as //
/////////////////////////////////////////////////////////////////////////////////////////////////////
If !AMIIn(11,14,41) .or. !FMX_AMIIn({"OFIPA980"})
	Return()
EndIf

axCadastro("VE4", cCadastro,"FS_VERDEL()")

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FL_DESCRI980� Autor � Fabio               � Data � 13/07/99 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Retorno de Descricoes                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � wAliasO -> Aquivo que vai ser pesquisado                   ���
���          � cChave  -> Chave do arquivo pesquisado                     ���
���          � cOrdem  -> Ordem usada na pesquisa                         ���
���          � cCamposO-> Campos que serao retornados do arquivo de pesq. ���
���          � cCamposD-> Campos que receberao o conteudo das variaveis   ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_DESCRI980()
If FG_SEEK("SA1","M->VE4_CGCFAB",3,.f.) == .F.
	MsgStop(OemToAnsi(STR0007)) //"Montadora NAO cadastrada no cadastro de Clientes !"
	Return .f.
EndIf
M->VE4_CODFAB := SA1->A1_COD
M->VE4_LOJA   := SA1->A1_LOJA
M->VE4_NOMFAB := SA1->A1_NOME
If FG_SEEK("SA2","M->VE4_CGCFAB",3,.f.) == .F.
	MsgStop(OemToAnsi(STR0008)) //"Montadora NAO cadastrada no cadastro de Fornecedor!"
	Return .f.
EndIf
M->VE4_CODFOR := SA2->A2_COD
M->VE4_LOJFOR := SA2->A2_LOJA
Return .t.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FS_VERDEL� Autor �  Emilton              � Data � 11/10/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Alerta o usuario para a delecao deste registro             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_VERDEL()

Return MsgYesNo(OemToAnsi(STR0009),OemToAnsi(STR0010))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FS_VERSEG� Autor �  Emilton              � Data � 14/11/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica segmento do modelo                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FS_VERSEG()
Local lRet := .t.
Local aAlias := SGetArea()
Local lSegMod := M->VE4_SEGMOD == "0"
SGetArea(aAlias,"VV2")
// Analisa se existe algum modelo previamente cadastrado para manter compatibilidade com o que estiver parametrizado
// na marca em cadastramento.
DbselectArea("VV2")
DbsetOrder(1)
Dbseek(xFilial("VV2")+M->VE4_PREFAB)
Do While xFilial("VV2")+M->VE4_PREFAB == VV2->(VV2_FILIAL+VV2_CODMAR) .and. !VV2->(Eof())
	// se configurar para utilizar segmento e j� existe algum modelo cadastrado sem segmento, nao podera alterar o parametro
	If lSegMod .and. Empty(VV2->VV2_SEGMOD)
		lRet := .f.
		Exit
	Elseif !lSegMod .and. !Empty(VV2->VV2_SEGMOD)
		// se configurar para nao utilizar segmento e j� existe algum modelo cadastrado com segmento, nao podera alterar o parametro
		lRet := .f.
		Exit
	Endif
	VV2->(Dbskip())
Enddo
If !lRet
	Help("  ",1,"VERSEGMOD")
Endif
sRestArea(aAlias)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor �  Emilton              � Data � 14/11/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta MenuDef                                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Return StaticCall(MATXATU,MENUDEF)