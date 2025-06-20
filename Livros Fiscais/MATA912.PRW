#Include "PROTHEUS.CH"
#Include "MATA912.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MATA912   � Autor �Gustavo G. Rueda       � Data �25.05.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Consolidador da DIPJ, utilizado para agrupar registros dife-���
���          � rentes de arquivos distintos da DIPJ em um unico arquivo.  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATA912 ()
	Local	oDlg
	Local	oGrp1
	Local	oGrp2
	Local	oSay1
	Local	oSay2
	Local	oSay3
	Local	oSay4
	Local	oSay5
	Local	oRadio1
	Local	oGet1
	Local	oGet2
	Local	oGet3
	Local	oBt1
	Local	oBt2
	Local	oBt3
	Local	oBt4
	Local	oBt5
	Local	oTree1
	Local	aItRadio1	:=	{STR0001, STR0002}
	Local	lProcessa	:=	.F.
	Local	oMark1
	Local	lInverte	:=	.F.
	Local	cCmb1		:=	""
	Local	nRadio1		:=	1
	Local	cGet1		:=	Space (115)
	Local	cGet2		:=	Space (115)
	Local	cGet3		:=	Space (145)
	Local	aTrb		:=	CriaTrb (1)	//Cria TRB para o MsSelect (MarkBrowse)
	Local	cMarca		:=	GetMark ()
	Local	aCpos 		:= 	{{"TRB_OK"  , 	"", OemToAnsi (STR0003),	""},;
							{"TRB_CHAVE",	"", OemToAnsi (STR0004),	""},;
							{"TRB_FLAG",	"", OemToAnsi (STR0005),	""},;
							{"TRB_REG", 	"", OemToAnsi (STR0006), 	""}}
	Local	bProcura1
	Local	bProcura2
	Local	bConfirma
	Local	bFechar
	Local	bWhen
	Local	oPainel
	Local	lClickBt3	:=	.F.
	Local	lClickBt5	:=	.F.
	//
	DEFINE MSDIALOG oDlg FROM 1, 1 TO 480, 640 TITLE OemToAnsi (STR0007) PIXEL
		oGrp1 		:=	TGROUP ():New (5, 5, 70, 316, OemToAnsi (STR0008), oDlg, 0, 0, .T., .T.)
		//
		//Versao da DIPJ
		oSay2		:=	TSay ():New (15, 10, {|| OemToAnsi (STR0009)}, oDlg, , , .F., .F., .F., .T.,,, 50, 10, .F., .F., .F., .F., .F.)
		bRadio		:=	{|| oBt5:lActive := .F., lClickBt3	:=	.F.}
		oRadio1		:=	TRadMenu ():New (15, 35, aItRadio1, &("{ | u | Iif (PCount ()==0, nRadio1, nRadio1 := u )}"), oDlg,,bRadio,,,,,, 40, 10,,,, .T.)
		//
		//Arquivo destino
		oSay5		:=	TSay ():New (15, 165, {|| OemToAnsi (STR0010)}, oDlg, , , .F., .F., .F., .T.,,, 50, 10, .F., .F., .F., .F., .F.)
		oGet3		:=	TGet ():New (25, 165, &("{ | u | Iif (PCount ()==0, cGet3, cGet3 := u )}"), oDlg, 145, 10, "@!",,,,,,, .T.)
		//
		//Arquivo principal
		oSay3		:=	TSay ():New (40, 10, {|| OemToAnsi (STR0011)}, oDlg, , , .F., .F., .F., .T.,,, 50, 10, .F., .F., .F., .F., .F.)
		oGet1		:=	TGet ():New (50, 10, &("{ | u | Iif (PCount ()==0, cGet1, cGet1 := u )}"), oDlg, 115, 10, "@!",,,,,,, .T.)	
		//
		//Botao Procurar para o arquivo principal
		bProcura1	:=	{|| cGet1 := cGetFile ("", OemToAnsi (STR0012)), Iif (Empty (cGet1), cGet1 := Space (115), Nil)}
		oBt1		:=	TButton ():New (50, 125, OemToAnsi (STR0013), oDlg, bProcura1, 30, 12,, oDlg:oFont, .F., .T., .F.,, .F.,,, .F.)
		//
		//Arquivo secundario
		oSay4		:=	TSay ():New (40, 165, {|| OemToAnsi (STR0014)}, oDlg, , , .F., .F., .F., .T.,,, 50, 10, .F., .F., .F., .F., .F.)
		oGet2		:=	TGet ():New (50, 165, &("{ | u | Iif (PCount ()==0, cGet2, cGet2 := u )}"), oDlg, 115, 10, "@!",,,,,,, .T.)
		//
		//Botao procurar para o arquivo secundario
		bProcura2	:=	{|| cGet2 := cGetFile ("", OemToAnsi (STR0012)), Iif (Empty (cGet2), cGet2 := Space (115), Nil)}
		oBt2		:=	TButton ():New (50, 280, OemToAnsi (STR0013), oDlg, bProcura2, 30, 12,, oDlg:oFont, .F., .T., .F.,, .F.,,, .F.)	
		//
		//Botao processar
		bProcessa	:=	{|| lProcessa := MontMark (@oMark1, aTrb[1], cGet1, cGet2, nRadio1), oBt3:lActive := .F., lClickBt3 := Iif (lProcessa, .T., .F.), lClickBt5 := .F.}
		bWhen		:=	{||!Empty (cGet1) .And. !Empty (cGet2) .And. !Empty (cGet3) .And. !lClickBt3}
		oBt3		:=	TButton ():New (75, 213, OemToAnsi (STR0015), oDlg, bProcessa, 30, 12,, oDlg:oFont, .F., .T., .F.,, .F.,bWhen,, .F.)
		//
		//Botao confirmar
		bConfirma	:=	{|| lGerou := GeraDest (aTrb[1], cGet3, cMarca), LimpaBrw (aTrb[1]), FimProc (lGerou, cGet3), oBt5:lActive := .F., lClickBt5 := Iif (lProcessa, .T., .F.), lClickBt3 := .F.}
		bWhen		:=	{||!Empty (cGet1) .And. !Empty (cGet2) .And. !Empty (cGet3) .And. lProcessa .And. !lClickBt5}
		oBt5		:=	TButton ():New (75, 250, OemToAnsi (STR0016), oDlg, bConfirma, 30, 12,, oDlg:oFont, .F., .T., .F.,, .F.,bWhen,, .F.)	
		//
		//Botao Fechar
		bFechar		:=	{|| oDlg:End ()}
		oBt4		:=	TButton ():New (75, 287, OemToAnsi (STR0017), oDlg, bFechar, 30, 12,, oDlg:oFont, .F., .T., .F.,, .F.,,, .F.)	
		//
		//Painel para montar o MarkBrowse
		oPainel		:=	TPanel ():New (90, 5,, oDlg,,.F.,.F.,,, 316, 233, .F.,.F.)
		oGrp2 		:=	TGroup ():New (00, 0, 145, 311, OemToAnsi (STR0018), oPainel, 0, 0, .T., .T.)
		oMark1	:=	MsSelect():New (aTrb[1], "TRB_OK",,aCpos, @lInverte, @cMarca, {100, 11, 228, 310})
		oMark1:oBrowse:lHasMark 	:= 	.T.
		oMark1:oBrowse:lCanAllMark	:=	.T.
		oMark1:oBrowse:bAllMark 	:= 	{|| MarkAll (aTrb[1], cMarca, @oPainel)}
	ACTIVATE MSDIALOG oDlg CENTERED
	//
	CriaTrb (2, aTrb)
Return (.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �FimProc   � Autor �Gustavo G. Rueda       � Data �25.05.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Exibicao da tela de sucesso apos o processamento final da   ���
���          � rotina.                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�lGerou -> Informa se o arquivo foi gerado com conteudo.     ���
���          �cGet3 -> Caminho digitado para o arquivo destino.           ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FimProc (lGerou, cGet3)
	Local	aMensagem	:=	{}
	//
	If (lGerou)
		aAdd (aMensagem, STR0019)	//"Arquivo gerado com sucesso!"
		aAdd (aMensagem, STR0027+AllTrim (cGet3))	//"Caminho: "
		aAdd (aMensagem, "")
		aAdd (aMensagem, "")
		aAdd (aMensagem, "")
		aAdd (aMensagem, "")
		aAdd (aMensagem, STR0028)	//"Observa��o: Diret�rio padr�o para gera��o � o mesmo diret�rio dos SXs"
	Else
		aAdd (aMensagem, STR0026)	//"Arquivo gerado com conte�do zerado por n�o ser selecionado nenhum registro."
		aAdd (aMensagem, STR0027+AllTrim (cGet3))	//"Caminho: "
		aAdd (aMensagem, "")
		aAdd (aMensagem, "")
		aAdd (aMensagem, "")
		aAdd (aMensagem, "")
		aAdd (aMensagem, STR0028)	//"Observa��o: Diret�rio padr�o para gera��o � o mesmo diret�rio dos SXs"
	EndIf
	//
	FormBatch (OemToAnsi (STR0020), aMensagem,;
		{{ 1, .T., {|o| nOpcao := 1, o:oWnd:End()}}})
Return (.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �LimpaBrw  � Autor �Gustavo G. Rueda       � Data �25.05.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Efetua um ZAP no TRB                                        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cAlias -> Alias do TRB                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LimpaBrw (cAlias)
	DbSelectArea (cAlias)
	Zap
Return (.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �GeraDest  � Autor �Gustavo G. Rueda       � Data �25.05.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Geracao do arquivo texto de acordo com o TRB                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �lRet -> Identifica se o arquivo foi gerado com conteudo.    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cAlias -> Alias do TRB                                      ���
���          �cArqDest -> Nome do arquivo texto destino                   ���
���          �cMarca -> Caracter de marca do MarkBrowse                   ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GeraDest (cAlias, cArqDest, cMarca)
	Local	nHandle 	:= 0
	Local	cLinha		:=	""
	Local	nRec		:=	(cAlias)->(Recno ())
	Local	lRet	:=	.F.
	//
	If File (cArqDest)
		FErase (cArqDest)
	EndIf
	//
	nHandle 	:= FCreate (cArqDest, 0)
	ProcRegua ((cAlias)->(RecCount ()))
	(cAlias)->(DbGoTop ())
	//
	Do While !(cAlias)->(Eof ())		
		IncProc ()
		//
		If ((cAlias)->TRB_OK==cMarca)
			lRet	:=	.T.
			cLinha	:=	SubStr ((cAlias)->TRB_REG, 1, (cAlias)->TRB_LENREG)
			//
			FWrite (nHAndle, cLinha+Chr(13)+Chr(10))
		EndIf
		//
		(cAlias)->(DbSkip ())
	EndDo
	FClose (nHandle)
	(cAlias)->(DbGoTo (nRec))
Return (lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MontMark  � Autor �Gustavo G. Rueda       � Data �25.05.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Geracao do conteudo do TRB para exibicao do MarkBrowse      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �lRet -> .T. se o processamento foi efetuado com sucesso ou  ���
���          � .F. se nao processamento.                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�oMark -> Objeto MarkBrowse                                  ���
���          �cAlias -> Alias do TRB                                      ���
���          �cGet1 -> Nome do arquivo principal a ser comparado.         ���
���          �cGet2 -> Nome do arquivo secundario a ser comparado.        ���
���          �nRadio -> Opcao de versao selecionado, 1-Ano Anterior ou    ���
���          �2-Ano Atual.											      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MontMark (oMark, cAlias, cGet1, cGet2, nRadio)
	Local	cLinha	:=	""
	Local	cTxt	:=	""
	Local	nLi		:=	1
	Local	lFirst	:=	.T.
	Local	lAtual	:=	nRadio==2
	Local	lRet	:=	.F.
	//
	LimpaBrw (cAlias)
	//
	If File (cGet1) .And. File (cGet2)
		cTxt		:=	MemoRead (cGet1)
		//
		//Gero somente quando o arquivo principal for DIPJ e a versao selecionada for o do arquivo mencionado.
		If ("DIPJ"$SubStr (cTxt, 1, 4)) .And. (lAtual .And. StrZero(Year(dDataBase),4)$SubStr (cTxt, 9, 4)) .Or. (!lAtual .And. StrZero(Year(dDataBase)-1,4)$SubStr (cTxt, 9, 4))
			Do While nLi<=Len (cTxt)
				If (SubStr (cTxt, nLi, 1)==CHR (13))
					RecLock (cAlias, .T.)
						(cAlias)->TRB_CHAVE		:=	Iif (lFirst, "", SubStr (cLinha, 1, 3))
						(cAlias)->TRB_FLAG		:=	STR0021
						(cAlias)->TRB_REG		:=	cLinha
						(cAlias)->TRB_LENREG	:=	Len (cLinha)
					MsUnLock ()
					//
					lFirst	:=	.F.
					cLinha	:=	""
					nLi		+=	2
					lRet	:=	.T.
				EndIf
				//
				cLinha	+=	SubStr (cTxt, nLi, 1)
				nLi++
			EndDo
		EndIf
		//
		cLinha		:=	""
		nLi			:=	1
		cTxt		:=	MemoRead (cGet2)
		lFirst		:=	.T.
		//
		//Gero somente quando o arquivo secundario for DIPJ e a versao selecionada for o do arquivo mencionado.
		If ("DIPJ"$SubStr (cTxt, 1, 4)) .And. (lAtual .And. StrZero(Year(dDataBase),4)$SubStr (cTxt, 9, 4)) .Or. (!lAtual .And. StrZero(Year(dDataBase)-1,4)$SubStr (cTxt, 9, 4))
			Do While nLi<=Len (cTxt)
				If (SubStr (cTxt, nLi, 1)==CHR (13))
					If !((cAlias)->(DbSeek (Iif (lFirst, "", SubStr (cLinha, 1, 3)))) .And. "P"$(cAlias)->TRB_FLAG)
						RecLock (cAlias, .T.)
							(cAlias)->TRB_CHAVE		:=	Iif (lFirst, "", SubStr (cLinha, 1, 3))
							(cAlias)->TRB_FLAG		:=	STR0022
							(cAlias)->TRB_REG		:=	cLinha
							(cAlias)->TRB_LENREG	:=	Len (cLinha)
						MsUnLock ()
					EndIf
					//
					lFirst	:=	.F.
					cLinha	:=	""
					nLi		+=	2
					lRet	:=	.T.
				EndIf
				//
				cLinha	+=	SubStr (cTxt, nLi, 1)
				nLi++
			EndDo
		EndIf		
	EndIf
	//
	(cAlias)->(DbGoTop ())
	oMark:oBrowse:Refresh()
	//
	If !(lRet)
		cTitulo		:=	STR0023	//"Informa��es inconsistentes."
		cProblema 	:=	STR0024	//"As informa��es prestadas podem n�o estar coerentes causando nenhum efeito no processamento."
		cSolucao	:=	STR0025	//"Para funcionamento correto da rotina � necess�rio observar se a vers�o da DIPJ � a mesma selecionada para os arquivos correspondentes informado logo abaixo. Tamb�m deve-se observar se os arquivos a serem integrados est�o com o caminho correto e se o arquivo destino foi informado."
		xMagHelpFis (cTitulo, cProblema, cSolucao)
	EndIf
Return (lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MarkAll   � Autor �Gustavo G. Rueda       � Data �25.05.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao que marca todos os itens quando clicar no header da  ���
���          � coluna.                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cAlias -> Alias do TRB                                      ���
���          �cMarca -> Caracter de marca do MarkBrowse                   ���
���          �oDlg -> Dialog                                              ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MarkAll (cAlias, cMarca, oDlg)
	Local 	nReg	:=	(cAlias)->(RecNo ())
	//
	(cAlias)->(DbGoTop ())
		DbEval ({|| (RecLock (cAlias, .F.), (cAlias)->TRB_OK := Iif (Empty ((cAlias)->TRB_OK), cMarca, " "), MsUnLock ())})
	(cAlias)->(DbGoto (nReg))
	oDlg:Refresh ()
Return (.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CriaTrb   � Autor �Gustavo G. Rueda       � Data �25.05.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de criacao/remocao do TRB para utilizacao no MarkBrowse���
�������������������������������������������������������������������������Ĵ��
���Retorno   �aRet -> Nome arquivo e alias do TRB criado.                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�nOpcao -> 1 para criacao e 2 para remocao                   ���
���          �aTrb -> Nome arquivo e alias do TRB a ser removido.         ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CriaTrb (nOpcao, aTrb)	
	Local	cTrb	:=	""
	Local	aRet	:=	{}
	//
	Default	aTrb	:=	{}
	//
	If (nOpcao==1)
		aAdd (aTrb, {"TRB_OK",		"C",	002,	000})
		aAdd (aTrb, {"TRB_CHAVE",	"C",	003,	000})
		aAdd (aTrb, {"TRB_FLAG",	"C",	010,	000})
		aAdd (aTrb, {"TRB_REG",		"C",	999,	000})
		aAdd (aTrb, {"TRB_LENREG",	"N",	003,	000})     
		//	
		cTrb	:=	CriaTrab (aTrb)
		DbUseArea (.T., __LocalDriver, cTrb, "TRB", .F.)
		IndRegua ("TRB", cTrb, "TRB_CHAVE")
		//		
		aRet	:=	{"TRB", cTrb}
	Else
		DbSelectArea (aTrb[1])
			(aTrb[1])->(DbCloseArea ())
		Ferase (aTrb[2]+GetDBExtension ())
		Ferase (aTrb[2]+OrdBagExt ())
	EndIf
Return (aRet)