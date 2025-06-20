#INCLUDE "AE_Hoteis.ch"
#INCLUDE "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AE_HOTEIS � Autor � Itamar Oliveira    � Data �  23/05/05   ���
�������������������������������������������������������������������������͹��
���Descricao �Cadastro de Hoteis 										  ���
�������������������������������������������������������������������������͹��
���Uso       �Template CDV - Controle de Despesas de Viagens              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Template Function AE_HOTEIS
Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := "T_ValExcHot()" // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "LJ3"

ChkTemplate("CDV")

dbSelectArea("LJ3")
LJ3->(dbSetOrder(1))

AxCadastro(cString,STR0001,cVldExc,cVldAlt) //"Cadastro de Hoteis"

Return          

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValExcHot �Autor �Pablo Gollan Carreras� Data �  09/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao da Exclusao do Hotel - Se estiver relacionada com ���
���          �alguma solicitacao nao sera apagada                         ���
�������������������������������������������������������������������������͹��
���Uso       �AE_HOTEIS                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Template Function ValExcHot()

Local lRet 		:= .T.
Local _aArea	:= GetArea()
Local cAlias	:= "TMP_AEHT"
Local lBDArq	:= .F.

#IFDEF TOP
	If TcGetDb() # "AS/400"
		BeginSQL Alias cAlias
			Column nTotal As Numeric(10,0)
			SELECT COUNT(LHP_CODIGO) nTotal
			FROM %table:LHP% 
			WHERE ((%notDel%) AND (LHP_FILIAL = %xFilial:LHP%) AND (LHP_CODHOT = %exp:LJ3->LJ3_CODIGO%))
		EndSQL              
		dbSelectArea(cAlias)
		If !(cAlias)->(Eof())
			If (cAlias)->nTotal > 0
				lRet := .F.
			Endif
		Endif
	Else
		lBDArq := .T.
	Endif
#ELSE               
	lBDArq := .T.
#ENDIF        
If lBDArq
	dbSelectArea("LHP")
	LHP->(dbSetOrder(1))	
	LHP->(dbGoTop())
	Do While !LHP->(Eof())
		If AllTrim(LHP->LHP_CODHOT) == AllTrim(LJ3->LJ3_CODIGO)
			lRet := .F.
			Exit
		Endif
		LHP->(dbSkip())
	EndDo
Endif
If !lRet
	MsgInfo(OemToAnsi(STR0002)) //"Este Hotel n�o poder� ser excluido por estar relacionado a solicita��es de viagens."
Endif
If Select(cAlias) # 0
	dbSelectArea(cAlias)
	dbCloseArea()
	fErase(cAlias + OrdBagExt())
	fErase(cAlias + GetDbExtension())
Endif
RestArea(_aArea)

Return lRet