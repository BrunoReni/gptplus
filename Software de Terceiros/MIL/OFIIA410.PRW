#include "PROTHEUS.CH"
#include "OFIIA410.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � OFIIA410  � Autor � Luis Delorme         � Data � 21/01/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Cadastro de Negocios do Cliente                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � OFIIA410                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MP8                                                        ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function OFIIA410()

axCadastro("VZO", STR0001,,"OFIIA410OK()")

Return

Static Function MenuDef()
Return StaticCall(MATXATU,MENUDEF)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � OFIIA410OK � Autor � Thiago              � Data � 19/08/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Validacao do cadastro.			                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � OFIIA410                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
*/
Function OFIIA410OK()
      
dbSelectArea("VZO")
dbSetOrder(1)           
if dbSeek(xFilial("VZO")+M->VZO_CLIENT+M->VZO_LOJA+M->VZO_TIPO)
   MsgStop(STR0002)
   Return(.f.)
Endif
Return(.t.)

/*/{Protheus.doc} OIA410011_Tipos_de_Negocios_do_Cliente
	Visualiza todos os Tipos de Negocios de um determinado Cliente
	
	@author Andre Luis Almeida
	@since 08/03/2022
/*/
Function OIA410011_Tipos_de_Negocios_do_Cliente( cCodCli , cLojCli )
Local oTpNegCli
Local aSize      := FWGetDialogSize( oMainWnd )
Local cFiltroVZN := ""
Local cTitulo    := STR0003+": "+cCodCli+"-"+cLojCli+" " // Tipos de Neg�cios do Cliente
Private aRotina  := {}
//
If !Empty(cCodCli+cLojCli)
	//
	cTitulo += FM_SQL("SELECT A1_NOME FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+cCodCli+"' AND A1_LOJA='"+cLojCli+"' AND D_E_L_E_T_=' '")
	//
	cFiltroVZN := "@ EXISTS ( "
	cFiltroVZN += " SELECT VZO.VZO_CLIENT "
	cFiltroVZN += "   FROM "+RetSQLName("VZO")+" VZO"
	cFiltroVZN += "  WHERE VZO.VZO_FILIAL=VZN_FILIAL"
	cFiltroVZN += "    AND VZO.VZO_CLIENT='"+cCodCli+"'"
	cFiltroVZN += "    AND VZO.VZO_LOJA='"+cLojCli+"'"
	cFiltroVZN += "    AND VZO.VZO_TIPO=VZN_TIPO"
	cFiltroVZN += "    AND VZO.D_E_L_E_T_=' '"
	cFiltroVZN += " )"
	//
	oTpNegCli := MSDIALOG() :New(aSize[1],aSize[2],aSize[3],aSize[4],cTitulo,,,,128,,,,,.t.)
	//
	oBrwVZN:= FWMBrowse():New()
	oBrwVZN:SetOwner(oTpNegCli)
	oBrwVZN:SetAlias("VZN")
	oBrwVZN:SetMenuDef("")
	oBrwVZN:DisableLocate()
	oBrwVZN:DisableDetails()
	oBrwVZN:SetAmbiente(.F.)
	oBrwVZN:SetWalkthru(.F.)
	oBrwVZN:SetDescription(cTitulo)
	oBrwVZN:AddButton(STR0004,{ || oTpNegCli:End() }) // Fechar
	oBrwVZN:SetFilterDefault(cFiltroVZN)
	oBrwVZN:SetInsert(.f.)
	oBrwVZN:ForceQuitButton(.T.)
	oBrwVZN:SetUseFilter()
	oBrwVZN:Activate()
	//
	oTpNegCli:Activate()
	//
Else
	MsgStop(STR0005,STR0006) // Necess�rio informar um cliente. / Aten��o
EndIf
//
Return