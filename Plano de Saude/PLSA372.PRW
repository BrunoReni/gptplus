#Include "TOTVS.CH"
#Include "PLSA372.CH"
Function PLSA372
AxCadastro("BXW",STR0001,"PLSA372Del()","PLSA372Val(nOpc)")//"Titula��o Conselho Federal de Medicina"
Return

Function PLSA372Val(nOpc)
Local lRet := .T.

If nOpc == 3 //Incluir
	lRet := !BXW->(dbSeek(xFilial("BXW")+M->BXW_CODIGO))
	If !lRet
		MsgInfo(STR0002)//"J� existe uma titula��o cadastrada com esse c�digo!"
	EndIf
EndIf

If nOpc == 4 .And. M->BXW_CODIGO <> BXW->BXW_CODIGO //Alterar
	lRet := .F.
	MsgInfo(STR0003)//"N�o � permitido alterar o c�dgio da titula��o"
EndIf

Return lRet

Function PLSA372Del()
Local lDel := .F.

If BLJ->(FieldPos("BLJ_CODTIT")) <= 0
	lRet := .T.
EndIf

If !lDel
	cSql := ChangeQuery("SELECT BLJ_FILIAL FROM " + RetSqlName("BLJ") + " WHERE BLJ_FILIAL = '" +xFilial("BLJ")+ "' AND BLJ_CODTIT = '" +BXW->BXW_CODIGO+ "'" )
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBB",.F.,.T.)	

	If TRBB->(Eof())
		lRet := .T.
	Else
		lRet := .F.
		MsgInfo(STR0004)//"Existem registros relacionados a este cadastro. N�o ser� poss�vel concluir sua exclus�o."
	EndIf

	TRBB->(dbCloseArea())

EndIf

Return lRet