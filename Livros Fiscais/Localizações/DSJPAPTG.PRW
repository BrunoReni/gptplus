#INCLUDE "DSJPAPTG.CH"
#INCLUDE "PROTHEUS.CH"

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �DSJPAPTG  � Autor � Gustavo G. Rueda       � Data �22/05/2008���
��������������������������������������������������������������������������Ĵ��
���Descri�ao �Relatorio para demonstrar uma rela��o de clientes que dever� ���
���			 � ser entregue quando h� reembolso do saldo a cr�dito do IVA  ���
���			 � apurado no per�odo                                          ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.              ���
��������������������������������������������������������������������������Ĵ��
���Programador �Data    � BOPS     � Motivo da Alteracao                   ���
��������������������������������������������������������������������������Ĵ��
���Jonathan Glz�08/07/15�PCREQ-4256�Se elimina la funcion AjustaSX1() que  ���
���            �        �          �hace modificacion a SX1 por motivo de  ���
���            �        �          �adecuacion a fuentes a nuevas estruc-  ���
���            �        �          �turas SX para Version 12.              ���
���M.Camargo   �09/11/15�PCREQ-4262�Merge v12.1.8                          ���
���  Marco A.  �27/12/16�SERINN001 �Se aplica CTREE para evitar la creacion���
���            �        �-535      �de tablas temporales de manera fisica  ���
���            �        �          �en system.                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function DSJPAPTG

	Local oReport	:= Nil
	Local cPerg		:= "DSJPPT"
	Local nMVLIMSJP	:= GetNewPar("MV_LIMSJP", 1000)

	oReport := ReportDef(cPerg, nMVLIMSJP)
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
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef(cPerg, nMVLIMSJP)

	Local aOrdem	:= {STR0001}	//"Nr. Ident. Fiscal"
	Local oReport	:= Nil     
	Local oContr	:= Nil
	Local oMov		:= Nil
	Local oInf		:= Nil
	Local oTotal	:= Nil
	Local cDesc		:= ""

	cDesc += STR0002 //"A Rela��o de sujeitos passivos dever� ser entregue quando h� reembolso do saldo a cr�dito do IVA apurado no per�odo. Caso n�o exista esse pedido, n�o � necess�ria a sua gera��o. Embasamento legal: al�nea c) do n� 1 do D. N. N� 53/2005 de 15/12."

	//Componente de impressao
	oReport := TReport():New("DSJPAPTG", OemToAnsi(STR0003), cPerg, {|oReport| ReportPrint(oReport, nMVLIMSJP)}, cDesc)	//"RELA��O DOS SUJEITOS PASSIVOS A QUE RESPEITAM AS REGULARIZA��ES"
	oReport:SetTotalInLine(.F.)
	oReport:SetPortrait(.T.)

	Pergunte(oReport:uParam, .F.)       

	//Secao 1 - Contribuinte
	oContr := TRSection():New(oReport,OemToAnsi(STR0004),{"SM0"},aOrdem,,)	//"Informa��es sobre o contribuinte"
	oContr:SetLineStyle()
	TRCell():New(oContr, "M0_CGC"	, "SM0", OemToAnsi(STR0005), "@R 999.999.999"	, 040, , ) //"NIF"
	TRCell():New(oContr, "cPeriodo"	, "SM0", OemToAnsi(STR0006), 					, 040, , ) //"Per�odo de Imposto"

	//Secao 2 - Regulariza��o a favor do do sujeito passivo - Opera��es efetuadas com sujeitos passivos nacionais
	oMov := TRSection():New(oReport,OemToAnsi(STR0007),{"TMP"},aOrdem,) //"Opera��es efetuadas com clientes nacionais"
	oMov:SetTotalInLine(.F.)
	TRCell():New(oMov, "TMP_SEQ"	, "TMP", STR0008, "@!"				 		, 05, , ) //"Linha"
	TRCell():New(oMov, "TMP_NIF"	, "TMP", STR0009, "@!"		   		 		, 20, , ) //"Nr. Ident. Fiscal"
	TRCell():New(oMov, "TMP_ANO"	, "TMP", STR0010, "@!"				 		, 04, , ) //"Ano"
	TRCell():New(oMov, "TMP_MES"	, "TMP", STR0011, "@!"						, 03, , ) //"Mes"
	TRCell():New(oMov, "TMP_BSREG"	, "TMP", STR0012, "@E 999,999,999,999.99"	, 18, , ) //"Base regulariza��o"
	TRCell():New(oMov, "TMP_VLR"	, "TMP", STR0013, "@E 999,999,999.99"		, 14, , ) //"IVA regularizado"

	//Secao 3 - Regulariza��o a favor do do sujeito passivo - Regulariza��es de impostos inferiores a 1.000 euros
	oInf := TRSection():New(oReport, OemToAnsi(STR0014), {"SM0"}, aOrdem, , )	//"Regulariza��es de impostos inferiores a 1.000 euros"
	oInf:SetLineStyle()
	TRCell():New(oInf, "nInfB", "SM0", OemToAnsi(STR0015), "@E 999,999,999,999.99"	, 020, , ) //"Base regulariza��o"
	TRCell():New(oInf, "nInfV", "SM0", OemToAnsi(STR0016), "@E 999,999,999.99"		, 020, , ) //"IVA regularizado"

	//Secao 4 - Regulariza��o a favor do do sujeito passivo - Totalizador
	oTotal	:= TRSection():New(oReport, OemToAnsi(STR0017), {"SM0"}, aOrdem, , )	//"Total"
	oTotal:SetLineStyle()
	TRCell():New(oTotal, "nTotalB", "SM0", OemToAnsi(STR0015), "@E 999,999,999,999.99", 020, , ) //"Base regulariza��o"
	TRCell():New(oTotal, "nTotalV", "SM0", OemToAnsi(STR0016), "@E 999,999,999,999.99", 020, , ) //"IVA regularizado"

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
��������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                          ���
��������������������������������������������������������������������������Ĵ��
���          �               �                                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportPrint(oReport, nMVLIMSJP)

	Local oContr	:= oReport:Section(1)
	Local oMov		:= oReport:Section(2)
	Local oInf		:= oReport:Section(3)
	Local oTotal	:= oReport:Section(4)
	Local cPeriodo	:= FormDate(MV_PAR01) + " a " + FormDate(MV_PAR02)
	Local cCondicao	:= "SM0->M0_CODFIL == '" + cFilAnt + "' .And. SM0->M0_CODIGO == '" + cEmpAnt + "'"
	Local lGerou	:= .F.
	Local nInfB		:= 0
	Local nInfV		:= 0
	Local nTotalB	:= 0
	Local nTotalV	:= 0
	
	Private oTmpTable := Nil

	Default nMVLIMSJP := 0

	//������������������������������������������������������������������������Ŀ
	//�Transforma parametros Range em expressao SQL                            �
	//��������������������������������������������������������������������������
	MakeSqlExpr(oReport:uParam)
	MakeAdvplExpr(oReport:uParam)

	//Monta e alimenta o arquivo de trabalho
	MontSJP(1, oReport, .T., MV_PAR01, MV_PAR02)

	dbSelectArea("TMP")
	oReport:SetMeter(TMP->(LastRec()))

	oContr:SetFilter(cCondicao)
	oContr:Cell("cPeriodo"):SetBlock({|| cPeriodo }) 
	oContr:Init()
	oContr:Print()
	oContr:Finish()

	lGerou := .F.
	oReport:ThinLine()
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText(STR0018) //"Regulariza��o a favor do do sujeito passivo"
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText(STR0019) //"Opera��es efetuadas com sujeitos passivos nacionais"
	oReport:ThinLine()
	oMov:Init()
	
	TMP->(dbGoTop())
	Do While !oReport:Cancel() .And. !TMP->(Eof())

		If oReport:Cancel()
			Exit
		EndIf

		oMov:IncMeter()

		//Inferior a 1000 entra em um quadro especifico
		If TMP->TMP_VLR < nMVLIMSJP
			nInfB += TMP->TMP_BSREG
			nInfV += TMP->TMP_VLR
		Else
			oMov:PrintLine()
			lGerou := .T.
		EndIf
		nTotalB	+= TMP->TMP_BSREG
		nTotalV	+= TMP->TMP_VLR

		TMP->(dbSkip())
	Enddo
	oMov:Finish()

	If !lGerou
		oReport:PrintText(STR0020)	//"*** Sem informa��o ***"
	EndIf

	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText(STR0021)	//"Regulariza��es de impostos inferiores a 1.000 euros"
	oReport:ThinLine()
	oInf:SetFilter(cCondicao)
	oInf:Cell("nInfB"):SetBlock({|| nInfB }) 
	oInf:Cell("nInfV"):SetBlock({|| nInfV }) 
	oInf:Init()
	oInf:Print()
	oInf:Finish()

	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText(STR0017)	//"Total"
	oReport:ThinLine()
	oTotal:SetFilter(cCondicao)
	oTotal:Cell("nTotalB"):SetBlock({|| nTotalB }) 
	oTotal:Cell("nTotalV"):SetBlock({|| nTotalV }) 
	oTotal:Init()
	oTotal:Print()
	oTotal:Finish()
	
	If oTmpTable <> Nil
		oTmpTable:Delete()
		oTmpTable := Nil
	EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MontSJP   � Autor � Gustavo G. Rueda      � Data �22/05/2008���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Funcao que monta e alimenta o arquivo de trabalho com base  ���
���          � no SF3.                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�nOpc - 1=Cria e alimenta, 2=Apaga                           ���
���          �oReport - Objeto TReport                                    ���
���          �lRelat - Flag que indica se a chamada da funcao e do relato-���
���          � rio ou nao.                                                ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function MontSJP(nOpc, oReport, lRelat, dDataDe, dDataAte)
	
	Local cAls		:= GetNextAlias()
	Local nTam		:= 0
	Local aStr		:= {}
	Local aOrdem	:= {}

	If nOpc == 1
	
		aAdd(aStr,{"TMP_SEQ"	, "C", 005	, 0})
		nTam :=	TamSx3("A1_CGC")[1]
		aAdd(aStr,{"TMP_NIF"	, "C", nTam	, 0})
		aAdd(aStr,{"TMP_ANO"	, "C", 004	, 0})
		aAdd(aStr,{"TMP_MES"	, "C", 002	, 0})
		aAdd(aStr,{"TMP_BSREG"	, "N", 018	, 2})	
		aAdd(aStr,{"TMP_VLR"	, "N", 018	, 2})
		
		aOrdem := {"TMP_NIF", "TMP_ANO", "TMP_MES"}
		
		oTmpTable := FWTemporaryTable():New("TMP")
		oTmpTable:SetFields(aStr)
		oTmpTable:AddIndex("IN1", aOrdem)
		
		oTmpTable:Create()

		BeginSql Alias cAls

			COLUMN F3_EMISSAO AS DATE
	
			SELECT 	A1_CGC, F3_EMISSAO, F3_BASIMP1 BASIMP1, F3_BASIMP3 BASIMP3, F3_BASIMP4 BASIMP4, F3_BASIMP5 BASIMP5, F3_BASIMP6 BASIMP6,
			F3_VALIMP1 VALIMP1, F3_VALIMP3 VALIMP3, F3_VALIMP4 VALIMP4, F3_VALIMP5 VALIMP5, F3_VALIMP6 VALIMP6
	
			FROM %table:SF3% SF3, %table:SA1% SA1
	
			WHERE 	SF3.%NotDel%          		        AND
			SA1.%NotDel%          		        		AND
			SF3.F3_FILIAL  		=  	%xFilial:SF3% 		AND
			SF3.F3_EMISSAO 		>= 	%Exp:Dtos(dDataDe)% AND 	//Deve ser pela emissao e nao pela data de entrada, conforme exigencia do relatorio(coluna 2)
			SF3.F3_EMISSAO 		<= 	%Exp:Dtos(dDataAte)% AND
			SF3.F3_TIPOMOV		=	'V' 				AND
			SF3.F3_DTCANC		=	' '					AND
			SUBSTRING(SF3.F3_ESPECIE,1,2)	IN('NC')	AND		//Notas de cr�dito ou Devoluca (em localizacoes a devolucao eh feita atraves de uma nota de credito)
			SA1.A1_FILIAL	  	=  	%xFilial:SA1% 		AND
			SA1.A1_COD   	  	= 	SF3.F3_CLIEFOR 		AND
			SA1.A1_LOJA    		=   SF3.F3_LOJA			AND
			SA1.A1_EST			NOT IN('98','99')		AND		//98=INTRACOMUNITARIO/99=EXTRACOMUNITARIO - SOMENTE OS NACIONAIS
			(SF3.F3_VALIMP1 > 0 OR SF3.F3_VALIMP3 > 0 OR SF3.F3_VALIMP4 > 0 OR SF3.F3_VALIMP5 > 0 OR SF3.F3_VALIMP6 > 0)
	
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

			If TMP->(dbSeek(PadR(aRetDig((cAls)->A1_CGC,.F.),TamSx3("A1_CGC")[1])+StrZero(Year((cAls)->F3_EMISSAO),4)+StrZero(Month((cAls)->F3_EMISSAO),2)))
				RecLock("TMP",.F.)
			Else
				RecLock("TMP",.T.)
				TMP->TMP_SEQ	:=	StrZero(Val(TMP->TMP_SEQ) + 1, 5)
				TMP->TMP_NIF	:=	PadR(aRetDig((cAls)->A1_CGC,.F.), TamSx3("A1_CGC")[1])
				TMP->TMP_ANO	:=	StrZero(Year((cAls)->F3_EMISSAO), 4)
				TMP->TMP_MES	:=	StrZero(Month((cAls)->F3_EMISSAO), 2)
			EndIf
			TMP->TMP_BSREG	+= ((cAls)->BASIMP1 + (cAls)->BASIMP3 + (cAls)->BASIMP4 + (cAls)->BASIMP5 + (cAls)->BASIMP6)
			TMP->TMP_VLR	+= ((cAls)->VALIMP3 + (cAls)->VALIMP4 + (cAls)->VALIMP4 + (cAls)->VALIMP5 + (cAls)->VALIMP6)
			MsUnLock()
			FkCommit()	

			(cAls)->(dbSkip())
		End
		(cAls)->(dbCloseArea())
	EndIf
	
Return
