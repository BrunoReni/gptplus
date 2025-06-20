// 浜様様様曜様様様様�
// � Versao � 02     �
// 藩様様様擁様様様様�

#INCLUDE "VEIVA330.CH"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � VEIVA330 � Autor � Andre Luis Almeida    � Data � 04/03/13 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Cadastro de Box de Entrega de Veiculos ( Atendimento )     咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Veiculos                                                   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VEIVA330
Private cCadastro := STR0001 // Cadastro de Box de Entrega de Veiculos
DbSelectArea("VDH")
axCadastro("VDH",cCadastro,"VEIVA330EX()","VEIVA330OK()")
Return .T.

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    �VEIVA330OK� Autor � Andre Luis Almeida    � Data � 04/03/13 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Ok da janela de Incluir e Alterar                          咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VEIVA330OK()
Local lRet   := .t.
Local cQuery := "SELECT VDH.R_E_C_N_O_ RECVDH FROM "+RetSQLName("VDH")+" VDH WHERE "
cQuery       += "VDH.VDH_FILIAL='"+xFilial("VDH")+"' AND VDH.VDH_FILBOX='"+M->VDH_FILBOX+"' AND "
cQuery       += "VDH.VDH_CODBOX='"+M->VDH_CODBOX+"' AND VDH.VDH_USUBOX='"+M->VDH_USUBOX+"' AND "
If Altera // Alterar
	cQuery   += "VDH.R_E_C_N_O_<>"+Alltrim( str( VDH->(RecNo()) ) )+" AND "
EndIf
cQuery       += "VDH.D_E_L_E_T_=' '"
If FM_SQL(cQuery) > 0
	MsgStop(STR0003,STR0002) // Impossivel continuar! J� existe cadastro com a mesma Filial, C�digo do Box e Usu�rio responsavel pelo Box! / Aten艫o
	lRet := .f.
Else
	If Altera 
		cQuery := "SELECT VVA.R_E_C_N_O_ AS RECVVA FROM "+RetSQLName("VVA")+" VVA WHERE "
		cQuery += "VVA.VVA_FIEPRV='"+VDH->VDH_FILBOX+"' AND "
		cQuery += "VVA.VVA_BOEPRV='"+VDH->VDH_CODBOX+"' AND "
		cQuery += "VVA.VVA_USEPRV='"+VDH->VDH_USUBOX+"' AND "
		cQuery += "VVA.VVA_DTEREA='        ' AND "
		cQuery += "VVA.D_E_L_E_T_=' '"
		If FM_SQL(cQuery) > 0
			MsgStop(STR0004,STR0002) // Impossivel alterar! Filial/Box/Usuario Responsavel pela Entrega j� esta sendo utilizado para entrega de um veiculo. / Atencao
			lRet := .f.
		EndIf
	EndIf
EndIf
Return lRet

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �VEIVA330EX� Autor � Andre Luis Almeida    � Data � 04/03/13 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Valida se pode ser feito a exclusao                        咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VEIVA330EX()
Local lRet   := .f.
Local cQuery := "SELECT VVA.R_E_C_N_O_ AS RECVVA FROM "+RetSQLName("VVA")+" VVA WHERE "
cQuery       += "VVA.VVA_FIEPRV='"+VDH->VDH_FILBOX+"' AND "
cQuery       += "VVA.VVA_BOEPRV='"+VDH->VDH_CODBOX+"' AND "
If Empty(VDH->VDH_USUBOX)
	cQuery   += "VVA.VVA_USEPRV='      ' AND "
Else
	cQuery   += "VVA.VVA_USEPRV='"+VDH->VDH_USUBOX+"' AND "
EndIf
cQuery       += "VVA.VVA_DTEREA='        ' AND "
cQuery       += "VVA.D_E_L_E_T_=' '"
If FM_SQL(cQuery) > 0
	MsgStop(STR0005,STR0002) // Impossivel excluir! Filial/Box/Usuario Responsavel pela Entrega j� esta sendo utilizado para entrega de um veiculo. / Atencao
Else
	lRet := .t.
	DbSelectArea("VDH")
	RecLock("VDH",.F.,.T.)
		VDH->(dbDelete())
	MsUnLock()
EndIf
Return lRet

Static Function MenuDef()
Return StaticCall(MATXATU,MENUDEF)