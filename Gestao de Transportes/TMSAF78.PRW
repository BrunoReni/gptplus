#Include "TMSAF78.CH"
#Include "Protheus.ch"

Static cNumThread := StrZero(ThreadId(),20)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAVerAge � Autor � Valdemar Roberto  � Data � 02.02.2016 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se o agendamento esta sendo utilizado ou nao      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAVerAge(cExp01,cExp02,cExp03,cExp04,cExp05,cExp06,      ���
���          �            cExp07,cExp08,cExp09,cExp10,cExp11,cExp12,      ���
���          �            cExp13,lExp01,lExp02,cExp14,cExp15,cExp16,      ���
���          �            cExp17,cExp18)                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp01 := Tipo do Documento (1=Conhecimento/2=Nota Fiscal  ���
���          �           /3=Coleta/4=Agendamento/5=Lote/6=Viagem          ���
���          �           /7=Manifesto                                     ���
���          � cExp02 := Filial de Origem do Documento                    ���
���          � cExp03 := Numero do Documento                              ���
���          � cExp04 := Serie do Documento                               ���
���          � cExp05 := C�digo do Cliente Remetente                      ���
���          � cExp06 := Loja do Cliente Remetente                        ���
���          � cExp07 := Numero da Nota Fiscal                            ���
���          � cExp08 := Serie da Nota Fiscal                             ���
���          � cExp09 := Codigo do Produto                                ���
���          � cExp10 := Filial de Origem da Solicitacao de Coleta        ���
���          � cExp11 := Numero da Solicitacao de Coleta                  ���
���          � cExp12 := Numero do Agendamento                            ���
���          � cExp13 := Tipo de Registro (1=Usados/2=Nao Usados)         ���
���          � lExp01 := Reserva/Libera Agendamento                       ���
���          � lExp02 := Exibe Mensagem                                   ���
���          � cExp14 := Numero do Lote                                   ���
���          � cExp15 := Numero da Viagem                                 ���
���          � cExp16 := Thread Valida                                    ���
���          � cExp17 := Item do Agendamento                              ���
���          � cExp18 := Numero do Manifesto                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TMSAVerAge(cTipDoc,cFilDoc,cDoc,cSerie,cCliRem,cLojRem,cNumNFc,cSerNFc,cCodPro,cFilOri,cNumSol,cNumAge,cTipReg,lResLib,;
					lExbMsg,cLotNFc,cViagem,cThrVal,cIteAge,cManife)
Local aAreas    := {GetArea()}
Local cQuery    := ""
Local cAliasDF1 := ""
Local lRet      := .T.
Local aListaThr := {}

DEFAULT cTipDoc := "" //-- 1=Conhecimento / 2=Nota Fiscal / 3=Coleta / 4=Agendamento / 5=Lote / 6=Viagem
DEFAULT cFilDoc := ""
DEFAULT cDoc    := ""
DEFAULT cSerie  := ""
DEFAULT cCliRem := ""
DEFAULT cLojRem := ""
DEFAULT cNumNFc := ""
DEFAULT cSerNFc := ""
DEFAULT cCodPro := ""
DEFAULT cFilOri := ""
DEFAULT cNumSol := ""
DEFAULT cNumAge := ""
DEFAULT cTipReg := "" //-- 1=Usados / 2=N�o Usados
DEFAULT lResLib := .F.
DEFAULT lExbMsg := .F.
DEFAULT cLotNFc := ""
DEFAULT cViagem := ""
DEFAULT cThrVal :=  StrZero(ThreadId(),20)
DEFAULT cIteAge := ""
DEFAULT cManife := ""

Return (.T.)

If !IsInCallStack("TMSAF76") .And. cTipDoc $ "1234567" .And. cTipReg $ "12"
	aRegAge   := {}
	cAliasDF1 := GetNextAlias()
	cQuery    := "SELECT DISTINCT DF1.R_E_C_N_O_ DF1_RECNO,DF1.DF1_MRKPAN "

	cQuery += "  FROM " + RetSqlName("DF1") + " DF1 "

	If cTipDoc $ "67" //-- Viagem ou Manifesto
		DTQ->(DbSetOrder(1))
		DTQ->(DbSeek(xFilial("DTQ") + cViagem))
		cQuery += "  JOIN " + RetSqlName("DUD") + " DUD "
		cQuery += "    ON DUD_FILIAL = '" + xFilial("DUD") + "' "
		If cTipDoc == "6" //-- Viagem
			cQuery += "   AND DUD_VIAGEM = '" + cViagem + "' "
		Else //-- Manifesto
			cQuery += "   AND DUD_MANIFE = '" + cManife + "' "
		EndIf
		cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
	EndIf

	If cTipDoc == "1" .Or. (cTipDoc $ "67" .And. DTQ->DTQ_SERTMS != StrZero(1,Len(DTQ->DTQ_SERTMS))) //-- Conhecimento ou Viagem/Manifesto (Exceto de coletas)
		cQuery += "  JOIN " + RetSqlName("DT6") + " DT6 "
		cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
		If cTipDoc == "1" //-- Conhecimento
			cQuery += "   AND DT6_FILDOC = '" + cFilDoc + "' "
			cQuery += "   AND DT6_DOC    = '" + cDoc + "' "
			cQuery += "   AND DT6_SERIE  = '" + cSerie + "' "
		Else //-- Viagem
			cQuery += "   AND DT6_FILDOC = DUD_FILDOC"
			cQuery += "   AND DT6_DOC    = DUD_DOC"
			cQuery += "   AND DT6_SERIE  = DUD_SERIE"
		EndIf
		cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
	EndIf

	If cTipDoc $ "125" .Or. (cTipDoc $ "67" .And. DTQ->DTQ_SERTMS != StrZero(1,Len(DTQ->DTQ_SERTMS))) //-- Conhecimento, Nota Fiscal, Lote ou Viagem/Manifesto (Exceto de coletas)
		cQuery += "  JOIN " + RetSqlName("DTC") + " DTC "
		cQuery += "    ON DTC_FILIAL = '" + xFilial("DTC") + "' "
		If cTipDoc $ "16" //-- Conhecimento ou Viagem
			cQuery += "   AND DTC_FILDOC = DT6_FILDOC "
			cQuery += "   AND DTC_DOC    = DT6_DOC "
			cQuery += "   AND DTC_SERIE  = DT6_SERIE "
		ElseIf cTipDoc == "5" //-- Lote
			cQuery += "   AND DTC_LOTNFC = '" + cLotNFc + "' "
		ElseIf cTipDoc == "2" //-- Nota Fiscal
			cQuery += "   AND DTC_CLIREM = '" + cCliRem + "' "
			cQuery += "   AND DTC_LOJREM = '" + cLojRem + "' "
			cQuery += "   AND DTC_NUMNFC = '" + cNumNFc + "' "
			cQuery += "   AND DTC_SERNFC = '" + cSerNFc + "' "
			If !Empty(cCodPro)
				cQuery += "   AND DTC_CODPRO = '" + cCodPro + "' "
			EndIf
		EndIf
		cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
	EndIf

	If cTipDoc $ "123567" //-- Conhecimento, Nota Fiscal, Solicitacao de Coletas, Lote ou Viagem/Manifesto
		cQuery += "  JOIN " + RetSqlName("DT5") + " DT5 "
		cQuery += "    ON DT5_FILIAL = '" + xFilial("DT5") + "' "
		If cTipDoc $ "125" .Or. (cTipDoc $ "67" .And. DTQ->DTQ_SERTMS != StrZero(1,Len(DTQ->DTQ_SERTMS))) //-- Conhecimento, Nota Fiscal, Lote ou Viagem/Manifesto (Exceto de coletas)
			cQuery += "   AND (CASE WHEN DTC_FILCFS <> '" + Space(Len(DTC->DTC_FILCFS)) + "' THEN DTC_FILCFS "
			cQuery += "             WHEN DTC_FILCFS =  '" + Space(Len(DTC->DTC_FILCFS)) + "' THEN DTC_FILORI "
			cQuery += "   END) = DT5_FILORI "
			cQuery += "   AND DT5_NUMSOL = DTC_NUMSOL "
		ElseIf cTipDoc $ "67" .And. DTQ->DTQ_SERTMS == StrZero(1,Len(DTQ->DTQ_SERTMS)) //-- Viagem de Coletas/Manifesto
			cQuery += "   AND DT5_FILORI = DUD_FILDOC "
			cQuery += "   AND DT5_NUMSOL = DUD_DOC "
		ElseIf cTipDoc $ "3" //-- Solicitacao de Coletas
			cQuery += "   AND DT5_FILORI = '" + cFilOri + "' "
			cQuery += "   AND DT5_NUMSOL = '" + cNumSol + "' "
		EndIf
		cQuery += "   AND DT5.D_E_L_E_T_ = ' ' "
	EndIf

	cQuery += " WHERE DF1.DF1_FILIAL = '" + xFilial("DF1") + "' "
	If cTipDoc == "4" //-- Agendamento
		cQuery += "   AND DF1.DF1_NUMAGE = '" + cNumAge + "' "
		If Empty(cIteAge)
	        cQuery += "    AND NOT EXISTS (SELECT 1 "
			cQuery += "   FROM " + RetSqlName("DF1") + " DF1AUX "
			cQuery += "  WHERE DF1AUX.DF1_FILIAL = '" + xFilial("DF1") + "' "
			cQuery += "    AND DF1AUX.DF1_NUMAGE = '" + cNumAge + "' "

			If cTipReg == "1" //-- Usados
				cQuery += "    AND DF1AUX.DF1_MRKPAN = '" + Space(Len(DF1->DF1_MRKPAN)) + "' "
			Else //-- N�o Usados
				cQuery += "    AND DF1AUX.DF1_MRKPAN <> '" + Space(Len(DF1->DF1_MRKPAN)) + "' "
			EndIf

			cQuery += "    AND DF1AUX.D_E_L_E_T_ = ' ') "
		Else
			cQuery += "   AND DF1.DF1_ITEAGE = '" + cIteAge + "' "
		EndIf
	Else //-- Conhecimento, Nota Fiscal, Solicitacao de Coletas, Lote ou Viagem
		cQuery += "   AND DF1.DF1_FILDOC = DT5_FILORI "
		cQuery += "   AND DF1.DF1_DOC    = DT5_NUMSOL "
		cQuery += "   AND DF1.DF1_SERIE  = 'COL' "
	EndIf
	cQuery += "   AND DF1.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDF1,.T.,.T.)

	If (cAliasDF1)->(!Eof())
		(cAliasDF1)->(DbCloseArea())
		cAliasDF1 := GetNextAlias()

		If cTipReg == "1" //-- Usados
			cQuery += "   AND DF1.DF1_MRKPAN <> '" + Space(Len(DF1->DF1_MRKPAN)) + "' "
		Else //-- N�o Usados
			cQuery += "   AND (DF1.DF1_MRKPAN = '" + Space(Len(DF1->DF1_MRKPAN)) + "' "
			If !Empty(cThrVal)
				cQuery += "   OR DF1.DF1_MRKPAN = '" + cThrVal + "' "
			EndIf
			cQuery += ") "
		EndIf
		
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDF1,.T.,.T.)
	
		If (cAliasDF1)->(Eof())
			lRet := .F.
			If cTipReg == "1" //-- Usados
				If lExbMsg
					MsgAlert(STR0001,STR0002) //"Registro n�o localizado ou n�o est� utilizado."###"Aten��o"
				EndIf
			Else //-- N�o Usados
				If lExbMsg
					MsgAlert(STR0003,STR0002) //"Registro n�o localizado ou est� utilizado."###"Aten��o"
				EndIf
			EndIf
		ElseIf lResLib
			If (cAliasDF1)->DF1_MRKPAN != cNumThread .And. cTipReg == "1" //-- Usado
				aListaThr := GetUserInfoArray()
				If Ascan(aListaThr,{|x| StrZero(x[3],20) ==  (cAliasDF1)->DF1_MRKPAN}) == 0
					TMSALimAge((cAliasDF1)->DF1_MRKPAN)
					TMSAStaAge(cTipReg,(cAliasDF1)->DF1_RECNO)
				Else
					MsgAlert(STR0004,STR0002) //"Registro n�o pode ser liberado pois est� para outro usu�rio."###"Aten��o"
					lRet := .F.
				EndIf
			Else
				While (cAliasDF1)->(!Eof())
					TMSAStaAge(cTipReg,(cAliasDF1)->DF1_RECNO)
					(cAliasDF1)->(DbSkip())
				EndDo
			EndIf
		EndIf

	EndIf

	(cAliasDF1)->(DbCloseArea())
	
EndIf

AEval(aAreas,{|x,y| RestArea(x) })

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAStaAge � Autor � Valdemar Roberto  � Data � 02.02.2016 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Reserva/Libera o Agendamento                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSAResAge(cExp01,nExp01)                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp01 := Tipo de Registro (1=Usados/2=Nao Usados)         ���
���          � nExp01 := Numero do Registro do Agendamento                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TMSAStaAge(cTipReg,nRegistro)
Local aAreas := {DF1->(GetArea()),GetArea()}

DEFAULT cTipReg   := "" //-- 1=Usados / 2=N�o Usados
DEFAULT nRegistro := 0

If cTipReg $ "12"
	If nRegistro > 0
		DF1->(DbGoTo(nRegistro))
		RecLock("DF1",.F.)
		If cTipReg == "1" //-- Usados
			If DF1->DF1_MRKPAN == cNumThread
				DF1->DF1_MRKPAN := ""
			EndIf
		Else //-- N�o Usados
			DF1->DF1_MRKPAN := cNumThread
		EndIf
		DF1->(MsUnlock())
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x) })

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSALimAge � Autor � Valdemar Roberto  � Data � 18/03/2016 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Limpa marcas dos agendamentos                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSALimAge(cExp01)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp01 := Numero da thread                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSALimAge                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function TMSALimAge(cNumThr)
Local aAreas    := GetArea()
Local cQuery    := ""
Local cAliasDF1 := ""

cAliasDF1 := GetNextAlias()
cQuery := "SELECT DF1.R_E_C_N_O_ DF1REC "
cQuery += "  FROM " + RetSqlName("DF1") +" DF1 "
cQuery += " WHERE DF1_FILIAL = '" + xFilial("DF1") + "' "
cQuery += "   AND DF1_MRKPAN = '" + cNumThr + "' "
cQuery += "   AND D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasDF1,.F.,.T.)

While (cAliasDF1)->(!Eof())
	DF1->(dbGoto((cAliasDF1)->DF1REC))
	RecLock("DF1",.F.)
	DF1_MRKPAN :=  Space(Len(DF1->DF1_MRKPAN))
	DF1->(MsUnlock())
	(cAliasDF1)->(dbSkip())
EndDo

(cAliasDF1)->(DbCloseArea())

RestArea(aAreas)

Return
