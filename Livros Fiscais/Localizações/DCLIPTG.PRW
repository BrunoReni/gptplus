#INCLUDE "DCLIPTG.CH"
#INCLUDE "PROTHEUS.CH"

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �DCLIPTG   � Autor � Gustavo G. Rueda       � Data �22/05/2008���
��������������������������������������������������������������������������Ĵ��
���Descri�ao � Relatorio para demonstrar uma rela��o de clientes que deverᳱ�
���			 � ser entregue quando h� reembolso do saldo a cr�dito do IVA  ���
���			 � apurado no per�odo                                          ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.            ���
��������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR � DATA   �   BOPS  �  MOTIVO DA ALTERACAO                  ���
��������������������������������������������������������������������������Ĵ��
���   Marco A.  �26/12/16�SERINN001�Se aplica CTREE para evitar la creacion���
���             �        �-532     �de tablas temporales de manera fisica  ���
���             �        �         �en system.                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function DCLIPTG

	Local oReport	:= Nil
	Local cPerg		:= "DCLIPT"
	Local nMVLIMCLI	:= GetNewPar("MV_LIMCLI", 5000)

	oReport := ReportDef(cPerg, nMVLIMCLI)
	oReport:PrintDialog()

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Gustavo G. Rueda      � Data �22/05/2008���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Funcao que monta todas as secoes do relatorio               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �oReport - Objeto TReport                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cPerg - Nome do grupo de perguntas                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef(cPerg, nMVLIMCLI)
	
	Local aOrdem 	:= {STR0001} //"Nr. Ident. Fiscal + Nr. Decl. Exporta��o"
	Local oReport	:= Nil      
	Local oContr	:= Nil
	Local oMov		:= Nil
	Local oMovEx	:= Nil	
	Local oEstrang	:= Nil
	Local oOpEst	:= Nil
	Local cDesc		:= ""
	Local oTotPag	:= Nil
	Local oTotPag1	:= Nil

	cDesc += STR0002 //"A Rela��o de Clientes dever� ser entregue quando h� reembolso do saldo a cr�dito do IVA apurado no per�odo. Caso n�o exista esse pedido, n�o � necess�ria a sua gera��o."

	//�����������������������Ŀ
	//�Componente de impressao�
	//�������������������������
	oReport := TReport():New("DCLIPTG", OemToAnsi(STR0003), cPerg, {|oReport| ReportPrint(oReport, nMVLIMCLI)}, cDesc)	//"RELA��O DE CLIENTES - al�nea a) do n� 1 do D. N. N� 53/2005 de 15/12"
	oReport:SetTotalInLine(.F.)
	oReport:SetPortrait(.T.)

	Pergunte(oReport:uParam, .F.)       

	//Secao 1 - Contribuinte
	oContr := TRSection():New(oReport, OemToAnsi(STR0004), {"SM0"}, aOrdem, , )	//"Informa��es sobre o contribuinte"
	oContr:SetLineStyle()
	TRCell():New(oContr, "M0_CGC"	, "SM0", OemToAnsi(STR0005), "@R 999.999.999" , 040, , )	//"NIF"
	TRCell():New(oContr, "cPeriodo"	, "SM0", OemToAnsi(STR0006),                  , 040, , )	//"Per�odo de Imposto"

	//Secao 2 - Relacao de clientes com operacoes isentas - Operacoes efetuadas com clientes nacionais
	oMov := TRSection():New(oReport, OemToAnsi(STR0007), {"TMP"}, aOrdem, , ) //"Opera��es efetuadas com clientes nacionais"
	oMov:SetTotalInLine(.F.)
	TRCell():New(oMov, "TMP_SEQ", "TMP", STR0008, "@!"					, 5						, , ) //"Linha"
	TRCell():New(oMov, "TMP_NIF", "TMP", STR0009, "@!"					, TamSX3("A1_CGC")[01]	, , ) //"Nr. Ident. Fiscal"
	TRCell():New(oMov, "TMP_VLR", "TMP", STR0010, "@E 999,999,999.99"	, 14					, , ) //"Valor"

	oTotPag	:=	TRFunction():New(oMov:Cell("TMP_VLR"), /* cID */, "SUM", /*oBreak*/, "", "@E 999,999,999,999.99", /*uFormula*/, /*lEndSection*/, .F., .F.)
	oTotPag:ResetPage()

	//Secao 3 - Relacao de clientes com operacoes isentas - Operacoes com clientes nacionais de montante inferior a 5000 euros
	oOpEst := TRSection():New(oReport,OemToAnsi(STR0011),{"SM0"},aOrdem,,)	//"Opera��es com clientes nacionais"
	oOpEst:SetLineStyle()
	TRCell():New(oOpEst, "nOpEst", "SM0", OemToAnsi(STR0012), "@E 999,999,999,999.99", 030, , )	//"Opera��es com clientes nacionais de montante inferior a 5.000 euros"

	//Secao 4 - Relacao de clientes com operacoes isentas - Exportacao de bens
	oMovEx := TRSection():New(oReport,OemToAnsi(STR0013),{"TMP"},aOrdem,,) //"Exporta��o de bens"
	oMovEx:SetTotalInLine(.F.)
	TRCell():New(oMovEx, "TMP_SEQ"	, "TMP", STR0008, "@!"					, 5						, , ) //"Linha"
	TRCell():New(oMovEx, "TMP_DE"	, "TMP", STR0014, "@!"					, TamSx3("EE9_NRSD")[1]	, , ) //"Nr. Ident. Fiscal"
	TRCell():New(oMovEx, "TMP_EXP"	, "TMP", STR0010, "@E 999,999,999.99"	, 14					, , ) //"Valor"

	oTotPag1 :=	TRFunction():New(oMovEx:Cell("TMP_EXP"), /* cID */, "SUM", /*oBreak*/, "Soma desta p�gina", "@E 999,999,999,999.99", /*uFormula*/, /*lEndSection*/, .F., .F.)
	oTotPag1:ResetPage()

	//Secao 5 - Relacao de clientes com operacoes isentas - Operacoes efetuadas no estrangeiro
	oEstrang := TRSection():New(oReport,OemToAnsi(STR0015), {"SM0"}, aOrdem, , )	//"Opera��es efetuadas no estrangeiro"
	oEstrang:SetLineStyle()
	TRCell():New(oEstrang, "nEstrang", "SM0", OemToAnsi(STR0016), "@E 999,999,999,999.99", 020, , )	//"Opera��es efetuadas no estrangeiro"

Return oReport

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � Gustavo G. Rueda      � Data �22/05/2008���
��������������������������������������������������������������������������Ĵ��
���Descri�ao �Funcao que gera o relatorio pre-definido                     ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Parametros�oReport - Objeto TReport                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function ReportPrint(oReport, nMVLIMCLI)
	
	Local oContr	:= oReport:Section(1)
	Local oMov		:= oReport:Section(2)
	Local oOpEst	:= oReport:Section(3)
	Local oMovEx	:= oReport:Section(4)
	Local oEstrang	:= oReport:Section(5)
	Local oTotal	:= oReport:Section(6)
	Local cPeriodo	:=	FormDate(MV_PAR01) + " a " + FormDate(MV_PAR02)
	Local cCondicao	:= "SM0->M0_CODFIL == '" + cFilAnt + "' .And. SM0->M0_CODIGO == '" + cEmpAnt + "'"
	Local lGerou	:=	.F.
	Local nOpEst	:=	0
	Local nEstrang	:=	0
	
	Private oTmpTable	:= Nil

	//������������������������������������������������������������������������Ŀ
	//�Transforma parametros Range em expressao SQL                            �
	//��������������������������������������������������������������������������
	MakeSqlExpr(oReport:uParam)

	oContr:SetFilter(cCondicao)
	oOpEst:SetFilter(cCondicao)
	oEstrang:SetFilter(cCondicao)
	oTotal:SetFilter(cCondicao)
	MakeAdvplExpr(oReport:uParam)

	//Monta e alimenta o arquivo de trabalho
	TempCLI(1, oReport, .T., MV_PAR01, MV_PAR02)

	dbSelectArea("TMP")
	oReport:SetMeter(TMP->(LastRec()))

	oContr:Cell("cPeriodo"):SetBlock({|| cPeriodo }) 
	oContr:Init()
	oContr:Print()
	oContr:Finish()

	lGerou	:=	.F.
	oReport:ThinLine()
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText(STR0018)	//"Opera��es efetuadas com clientes nacionais"
	oReport:ThinLine()
	oMov:Init()
	TMP->(dbGoTop())
	Do While !oReport:Cancel() .And. !TMP->(Eof())

		If oReport:Cancel()
			Exit
		EndIf

		oMov:IncMeter()
		If 	Empty(TMP->TMP_DE)

			//Inferior a 5000 entra em um quadro especifico
			If TMP->TMP_VLR<nMVLIMCLI
				nOpEst	+=	TMP->TMP_VLR
			Else
				oMov:PrintLine()
				lGerou	:=	.T.
			EndIf
		EndIf

		TMP->(dbSkip())
	Enddo
	If !lGerou
		oReport:PrintText(STR0019)	//"*** Sem informa��o ***"
	EndIf
	oMov:Finish()

	oOpEst:Cell("nOpEst"):SetBlock({|| nOpEst }) 
	oOpEst:Init()
	oOpEst:Print()
	oOpEst:Finish()

	lGerou	:=	.F.
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText(STR0020)	//"Exporta��o de bens"
	oReport:ThinLine()
	oMovEx:Init()
	TMP->(dbGoTop())
	Do While !oReport:Cancel() .And. !TMP->(Eof())       

		If oReport:Cancel()
			Exit
		EndIf

		oMovEx:IncMeter()
		If 	!Empty(TMP->TMP_DE)
			lGerou	:=	.T.
			oMovEx:PrintLine()
		EndIf

		TMP->(dbSkip())
	Enddo
	If !lGerou
		oReport:PrintText(STR0019)	//"*** Sem informa��o ***"
	EndIf
	oMovEx:Finish()

	If oTmpTable <> Nil
		oTmpTable:Delete()
		oTmpTable := Nil
	EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TempCLI   � Autor � Gustavo G. Rueda      � Data �22/05/2008���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Funcao que monta e alimenta o arquivo de trabalho com base  ���
���          � no SF3.                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�nOpc - 1=Cria e alimenta                                    ���
���          �oReport - Objeto TReport                                    ���
���          �lRelat - Flag que indica se a chamada da funcao e do relato-���
���          � rio ou nao.                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TempCLI(nOpc, oReport, lRelat, dDataDe, dDataAte)
	
	Local cAls		:= GetNextAlias()
	Local nTam		:= 0
	Local aStr		:= {}
	Local nSeqExp	:= 0
	Local nSeqNac	:= 0
	Local cMVOPEST	:= GetNewPar("MV_OPEST","MO")
	Local cChave	:= ""
	Local lExpBens	:= .F.
	Local aOrdem	:= {}
	 
	If nOpc == 1
		
		aAdd(aStr, {"TMP_SEQ",	"C", 005, 0})
		nTam :=	TamSx3("A1_CGC")[1]
		aAdd(aStr, {"TMP_NIF", "C", nTam, 0})
		nTam :=	TamSx3("F2_DECLEXP")[1]
		aAdd(aStr, {"TMP_DE"	, "C", nTam	, 0})
		aAdd(aStr, {"TMP_VLR"	, "N", 018	, 2})	
		aAdd(aStr, {"TMP_EXP"	, "N", 018	, 2})
		
		aOrdem := {"TMP_NIF", "TMP_DE"}

		oTmpTable := FWTemporaryTable():New("TMP")
		oTmpTable:SetFields(aStr)
		oTmpTable:AddIndex("IN1", aOrdem)
		oTmpTable:Create()

		BeginSql Alias cAls
			SELECT A1_CGC CGC, A1_EST EST, F2_CLIENTE, F2_LOJA, F2_DOC, F2_SERIE, F2_DECLEXP, B1_TIPO, D2_TOTAL
	
			FROM %table:SF2% SF2, %table:SA1% SA1, %table:SD2% SD2, %table:SB1% SB1
	
			WHERE SF2.%NotDel%						   		AND
			SA1.%NotDel%						   		AND
			SD2.%NotDel%						   		AND
			SB1.%NotDel%						   		AND
	
			SF2.F2_FILIAL	=	%xFilial:SF2%	   		AND
			SF2.F2_EMISSAO 	>= 	%Exp:Dtos(dDataDe)% 	AND 
			SF2.F2_EMISSAO 	<= 	%Exp:Dtos(dDataAte)% 	AND
			SF2.F2_TIPO		<>	'B'						AND
	
			SA1.A1_FILIAL	=  %xFilial:SA1% 			AND
			SA1.A1_COD   	= 	SF2.F2_CLIENTE 			AND
			SA1.A1_LOJA    	=   SF2.F2_LOJA				AND
	
			SD2.D2_FILIAL	=	%xFilial:SD2% 			AND
			SD2.D2_DOC		=	SF2.F2_DOC	 			AND
			SD2.D2_SERIE	=	SF2.F2_SERIE 			AND
			SD2.D2_CLIENTE	=	SF2.F2_CLIENTE			AND
			SD2.D2_LOJA		=	SF2.F2_LOJA 			AND
	
			SB1.B1_FILIAL	=	%xFilial:SB1% 			AND
			SB1.B1_COD		=	SD2.D2_COD				AND
	
			(SELECT SUM(F3_EXENTAS) FROM %table:SF3% SF3 WHERE SF3.%NotDel% AND SF3.F3_FILIAL = %xFilial:SF3% AND 
			SF3.F3_NFISCAL = SF2.F2_DOC AND SF3.F3_SERIE = SF2.F2_SERIE AND SF3.F3_CLIEFOR = SF2.F2_CLIENTE AND 
			SF3.F3_LOJA = SF2.F2_LOJA AND SF3.F3_TIPOMOV='V')>0
	
			UNION
	
			SELECT A2_CGC CGC, A2_EST EST, F2_CLIENTE, F2_LOJA, F2_DOC, F2_SERIE, F2_DECLEXP, B1_TIPO, D2_TOTAL
	
			FROM %table:SF2% SF2, %table:SA2% SA2, %table:SD2% SD2, %table:SB1% SB1
	
			WHERE SF2.%NotDel%						   		AND
			SA2.%NotDel%						   		AND
			SD2.%NotDel%						   		AND
			SB1.%NotDel%						   		AND
	
			SF2.F2_FILIAL	=	%xFilial:SF2%	   		AND
			SF2.F2_EMISSAO 	>= 	%Exp:Dtos(dDataDe)% 	AND 
			SF2.F2_EMISSAO 	<= 	%Exp:Dtos(dDataAte)% 	AND
			SF2.F2_TIPO		=	'B'						AND
	
			SA2.A2_FILIAL	=  %xFilial:SA2% 			AND
			SA2.A2_COD   	= 	SF2.F2_CLIENTE 			AND
			SA2.A2_LOJA    	=   SF2.F2_LOJA				AND
	
			SD2.D2_FILIAL	=	%xFilial:SD2% 			AND
			SD2.D2_DOC		=	SF2.F2_DOC	 			AND
			SD2.D2_SERIE	=	SF2.F2_SERIE 			AND
			SD2.D2_CLIENTE	=	SF2.F2_CLIENTE			AND
			SD2.D2_LOJA		=	SF2.F2_LOJA 			AND
	
			SB1.B1_FILIAL	=	%xFilial:SB1% 			AND
			SB1.B1_COD		=	SD2.D2_COD				AND
	
			(SELECT SUM(F3_EXENTAS) FROM %table:SF3% SF3 WHERE SF3.%NotDel% AND SF3.F3_FILIAL = %xFilial:SF3% AND 
			SF3.F3_NFISCAL = SF2.F2_DOC AND SF3.F3_SERIE = SF2.F2_SERIE AND SF3.F3_CLIEFOR = SF2.F2_CLIENTE AND 
			SF3.F3_LOJA = SF2.F2_LOJA AND SF3.F3_TIPOMOV='V')>0
	
			ORDER BY 1
		EndSql

		TMP->(dbSetOrder(1))

		If lRelat
			oReport:SetMeter((cAls)->(LastRec()))
		EndIf

		While !(cAls)->(Eof())

			If lRelat
				oReport:IncMeter()
			EndIf

			//INTRACOMUNITARIO/EXTRACOMUNITARIO e NAO considerar SERVICOS(Idendificado pelo B1_TIPO) e com o NUMERO DA DECLARACAO DE EXPORTACAO
			If (lExpBens := AllTrim((cAls)->EST) $ "98/99" .And. !AllTrim((cAls)->B1_TIPO)$cMVOPEST .And. !Empty((cAls)->F2_CLIENTE))
				cChave	:=	PadR("",TamSx3("A1_CGC")[1])+(cAls)->F2_DECLEXP
			Else
				cChave	:=	PadR(aRetDig((cAls)->CGC,.F.),TamSx3("A1_CGC")[1])+PadR("",TamSx3("F2_DECLEXP")[1])
			EndIf

			If TMP->(dbSeek(cChave))
				RecLock("TMP",.F.)
			Else
				RecLock("TMP",.T.)
				If lExpBens
					TMP->TMP_DE		:= (cAls)->F2_DECLEXP
					TMP->TMP_SEQ	:= StrZero(nSeqExp++,5)
				Else
					TMP->TMP_NIF	:= PadR(aRetDig((cAls)->CGC,.F.),TamSx3("A1_CGC")[1])
					TMP->TMP_SEQ	:= StrZero(nSeqNac++,5)
				EndIf
			EndIf

			If lExpBens
				TMP->TMP_EXP +=	(cAls)->D2_TOTAL //EXPORTACAO
			Else
				TMP->TMP_VLR +=	(cAls)->D2_TOTAL //OPERACOES NACIONAIS
			EndIf
			MsUnLock()
			FkCommit()	

			(cAls)->(dbSkip())
		End
		(cAls)->(dbCloseArea())
		
	EndIf
	
Return
