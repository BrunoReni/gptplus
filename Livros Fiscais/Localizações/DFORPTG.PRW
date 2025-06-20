#INCLUDE "DFORPTG.CH"
#INCLUDE "PROTHEUS.CH"

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �DFORPTG   � Autor � Gustavo G. Rueda       � Data �22/05/2008���
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
���             �        �-533     �de tablas temporales de manera fisica  ���
���             �        �         �en system.                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function DFORPTG()

	Local oReport	:= Nil
	Local cPerg		:= "DFORPT"
	Local nMVLIMFOR	:= GetNewPar("MV_LIMFOR", 5000)

	oReport := ReportDef(cPerg, nMVLIMFOR)
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
Static Function ReportDef(cPerg, nMVLIMFOR)
	
	Local aOrdem 	:= {STR0001} //"Prefixo + Nr. Ident. Fiscal"
	Local oReport	:= Nil      
	Local oContr	:= Nil
	Local oCampo20	:= Nil
	Local oCampo21	:= Nil
	Local oCampo22	:= Nil
	Local oCampo23	:= Nil
	Local oCampo24	:= Nil
	Local oAqInf	:= Nil
	Local oTotal	:= Nil
	Local cDesc		:= ""

	cDesc += STR0002 //"A Rela��o de fornecedores dever� ser entregue quando h� reembolso do saldo a cr�dito do IVA apurado no per�odo. Caso n�o exista esse pedido, n�o � necess�ria a sua gera��o."

	//�����������������������Ŀ
	//�Componente de impressao�
	//�������������������������
	oReport := TReport():New("DFORPTG", OemToAnsi(STR0003), cPerg, {|oReport| ReportPrint(oReport, nMVLIMFOR)}, cDesc)	//"RELA��O DE FORNECEDORES - al�nea b) do n� 1 do D. N. N� 53/2005 de 15/12"
	oReport:SetTotalInLine(.F.)
	oReport:SetPortrait(.T.)

	Pergunte(oReport:uParam, .F.)

	//Secao 1 - Contribuinte
	oContr := TRSection():New(oReport,OemToAnsi(STR0004),{"SM0"},aOrdem,,)	//"Informa��es sobre o contribuinte"
	oContr:SetLineStyle()
	TRCell():New(oContr, "M0_CGC"	, "SM0", OemToAnsi(STR0005), "@R 999.999.999"	, 040, , ) //"NIF"
	TRCell():New(oContr, "cPeriodo"	, "SM0", OemToAnsi(STR0006), 					, 040, , ) //"Per�odo de Imposto"

	//Secao 2 - CAMPO 20 - Rela��o de fornecedores cujas opera��es originaram imposto deduzido - Imobilizado
	oCampo20 := TRSection():New(oReport,OemToAnsi(STR0007), {"TMP"}, aOrdem, , ) //"CAMPO 20 - Imobilizado"
	oCampo20:SetTotalInLine(.F.)
	TRCell():New(oCampo20, "TMP_SEQ"	, "TMP", STR0008, "@!"						, 5						, , ) //"Linha"
	TRCell():New(oCampo20, "TMP_PREF"	, "TMP", STR0009, "@!"						, 2						, , ) //"Prefixo"
	TRCell():New(oCampo20, "TMP_NIF"	, "TMP", STR0010, "@!"						, TamSX3("A1_CGC")[01]	, , ) //"Nr. Ident. Fiscal"
	TRCell():New(oCampo20, "TMP_NUMLIQ"	, "TMP", STR0011, "@!"						, 20					, , ) //"Nr. Liquida��o"
	TRCell():New(oCampo20, "TMP_ANO"	, "TMP", STR0012, "@!"						, 4						, , ) //"Ano"
	TRCell():New(oCampo20, "TMP_MES"	, "TMP", STR0013, "@!"						, 2						, , ) //"Mes"
	TRCell():New(oCampo20, "TMP_IVAEXC"	, "TMP", STR0014, "@E 999,999,999,999.99"	, 19					, , ) //"Valor(IVA Excluido)"
	TRCell():New(oCampo20, "TMP_VLRDED"	, "TMP", STR0015, "@E 999,999,999,999.99"	, 15					, , ) //"IVA deduzido"

	//Secao 3 - CAMPO 21 - Rela��o de fornecedores cujas opera��es originaram imposto deduzido - Exist�ncias a taxa reduzida
	oCampo21 := TRSection():New(oReport, OemToAnsi(STR0016), {"TMP"}, aOrdem, , ) //"CAMPO 21 - Exist�ncias a taxa reduzida"
	oCampo21:SetTotalInLine(.F.)
	TRCell():New(oCampo21, "TMP_SEQ"	, "TMP", STR0008, "@!"						, 5						, , ) //"Linha"
	TRCell():New(oCampo21, "TMP_PREF"	, "TMP", STR0009, "@!"						, 2						, , ) //"Prefixo"
	TRCell():New(oCampo21, "TMP_NIF"	, "TMP", STR0010, "@!"						, TamSX3("A1_CGC")[01]	, , ) //"Nr. Ident. Fiscal"
	TRCell():New(oCampo21, "TMP_NUMLIQ"	, "TMP", STR0011, "@!"						, 20					, , ) //"Nr. Liquida��o"
	TRCell():New(oCampo21, "TMP_ANO"	, "TMP", STR0012, "@!"						, 4						, , ) //"Ano"
	TRCell():New(oCampo21, "TMP_MES"	, "TMP", STR0013, "@!"						, 2						, , ) //"Mes"
	TRCell():New(oCampo21, "TMP_IVAEXC"	, "TMP", STR0014, "@E 999,999,999,999.99"	, 19					, , ) //"Valor(IVA Excluido)"
	TRCell():New(oCampo21, "TMP_VLRDED"	, "TMP", STR0015, "@E 999,999,999,999.99"	, 15					, , ) //"IVA deduzido"

	//Secao 4 - CAMPO 22 - Rela��o de fornecedores cujas opera��es originaram imposto deduzido - Exist�ncias a taxa normal
	oCampo22 := TRSection():New(oReport,OemToAnsi(STR0017),{"TMP"},aOrdem,,) //"CAMPO 22 - Exist�ncias a taxa normal"
	oCampo22:SetTotalInLine(.F.)
	TRCell():New(oCampo22, "TMP_SEQ"	, "TMP", STR0008, "@!"						, 5						, , ) //"Linha"
	TRCell():New(oCampo22, "TMP_PREF"	, "TMP", STR0009, "@!"						, 2						, , ) //"Prefixo"
	TRCell():New(oCampo22, "TMP_NIF"	, "TMP", STR0010, "@!"						, TamSX3("A1_CGC")[01]	, , ) //"Nr. Ident. Fiscal"
	TRCell():New(oCampo22, "TMP_NUMLIQ"	, "TMP", STR0011, "@!"						, 20					, , ) //"Nr. Liquida��o"
	TRCell():New(oCampo22, "TMP_ANO"	, "TMP", STR0012, "@!"						, 4						, , ) //"Ano"
	TRCell():New(oCampo22, "TMP_MES"	, "TMP", STR0013, "@!"						, 2						, , ) //"Mes"
	TRCell():New(oCampo22, "TMP_IVAEXC"	, "TMP", STR0014, "@E 999,999,999,999.99"	, 19					, , ) //"Valor(IVA Excluido)"
	TRCell():New(oCampo22, "TMP_VLRDED"	, "TMP", STR0015, "@E 999,999,999,999.99"	, 15					, , ) //"IVA deduzido"

	//Secao 5 - CAMPO 23 - Rela��o de fornecedores cujas opera��es originaram imposto deduzido - Exist�ncias a interm�dia
	oCampo23 := TRSection():New(oReport,OemToAnsi(STR0018),{"TMP"},aOrdem,,) //"CAMPO 23 - Exist�ncias a interm�dia"
	oCampo23:SetTotalInLine(.F.)
	TRCell():New(oCampo23,"TMP_SEQ"		,"TMP"	,STR0008	,"@!"						, 5						, , ) //"Linha"
	TRCell():New(oCampo23,"TMP_PREF"	,"TMP"	,STR0009	,"@!"						, 2						, , ) //"Prefixo"
	TRCell():New(oCampo23,"TMP_NIF"		,"TMP"	,STR0010	,"@!"						, TamSX3("A1_CGC")[01]	, , ) //"Nr. Ident. Fiscal"
	TRCell():New(oCampo23,"TMP_NUMLIQ"	,"TMP"	,STR0011	,"@!"						, 20					, , ) //"Nr. Liquida��o"
	TRCell():New(oCampo23,"TMP_ANO"		,"TMP"	,STR0012	,"@!"						, 4						, , ) //"Ano"
	TRCell():New(oCampo23,"TMP_MES"		,"TMP"	,STR0013	,"@!"						, 2						, , ) //"Mes"
	TRCell():New(oCampo23,"TMP_IVAEXC"	,"TMP"	,STR0014	,"@E 999,999,999,999.99"	, 19					, , ) //"Valor(IVA Excluido)"
	TRCell():New(oCampo23,"TMP_VLRDED"	,"TMP"	,STR0015	,"@E 999,999,999,999.99"	, 15					, , ) //"IVA deduzido"

	//Secao 6 - CAMPO 24 - Rela��o de fornecedores cujas opera��es originaram imposto deduzido - Outros bens e servi�os
	oCampo24 := TRSection():New(oReport,OemToAnsi(STR0019),{"TMP"},aOrdem,,) //"CAMPO 24 - Outros bens e servi�os"
	oCampo24:SetTotalInLine(.F.)
	TRCell():New(oCampo24, "TMP_SEQ"	, "TMP", STR0008, "@!"						, 5						, , ) //"Linha"
	TRCell():New(oCampo24, "TMP_PREF"	, "TMP", STR0009, "@!"						, 2						, , ) //"Prefixo"
	TRCell():New(oCampo24, "TMP_NIF"	, "TMP", STR0010, "@!"						, TamSX3("A1_CGC")[01]	, , ) //"Nr. Ident. Fiscal"
	TRCell():New(oCampo24, "TMP_NUMLIQ"	, "TMP", STR0011, "@!"						, 20					, , ) //"Nr. Liquida��o"
	TRCell():New(oCampo24, "TMP_ANO"	, "TMP", STR0012, "@!"						, 4						, , ) //"Ano"
	TRCell():New(oCampo24, "TMP_MES"	, "TMP", STR0013, "@!"						, 2						, , ) //"Mes"
	TRCell():New(oCampo24, "TMP_IVAEXC"	, "TMP", STR0014, "@E 999,999,999,999.99"	, 19					, , ) //"Valor(IVA Excluido)"
	TRCell():New(oCampo24, "TMP_VLRDED"	, "TMP", STR0015, "@E 999,999,999,999.99"	, 15					, , ) //"IVA deduzido"

	//Secao 7 - Aquisi��es de montante inferior a 5.000 euros
	oAqInf	:= TRSection():New(oReport, OemToAnsi(STR0020), {"SM0"}, aOrdem, , ) //"Aquisi��es de montante inferior a 5.000 euros"
	oAqInf:SetLineStyle()
	TRCell():New(oAqInf, "nAqInfV", "SM0", OemToAnsi(STR0014), "@E 999,999,999,999.99", 020, , ) //"Valor(IVA Excluido)"
	TRCell():New(oAqInf, "nAqInfD", "SM0", OemToAnsi(STR0015), "@E 999,999,999,999.99", 020, , ) //"IVA deduzido"

	//Secao 8 - Totalizador
	oTotal	:= TRSection():New(oReport,OemToAnsi(STR0021), {"SM0"}, aOrdem, , )	//"Total"
	oTotal:SetLineStyle()
	TRCell():New(oTotal, "nTotalV", "SM0", OemToAnsi(STR0014), "@E 999,999,999,999.99", 020, , ) //"Valor(IVA Excluido)"
	TRCell():New(oTotal, "nTotalD", "SM0", OemToAnsi(STR0015), "@E 999,999,999,999.99", 020, , ) //"IVA deduzido"

Return oReport

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � Gustavo G. Rueda     � Data �22/05/2008���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Funcao que gera o relatorio pre-definido                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�oReport - Objeto TReport                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportPrint(oReport, nMVLIMFOR)
	
	Local oContr	:= oReport:Section(1)
	Local oCampo20	:= oReport:Section(2)
	Local oCampo21	:= oReport:Section(3)
	Local oCampo22	:= oReport:Section(4)
	Local oCampo23	:= oReport:Section(5)
	Local oCampo24	:= oReport:Section(6)
	Local oAqInf	:= oReport:Section(7)
	Local oTotal	:= oReport:Section(8)
	Local cPeriodo	:=	FormDate(MV_PAR01) + " a " + FormDate(MV_PAR02)
	Local cCondicao	:= "SM0->M0_CODFIL == '" + cFilAnt + "' .And. SM0->M0_CODIGO == '" + cEmpAnt + "'"
	Local lGerou	:= .F.
	Local nAqInfV	:= 0
	Local nAqInfD	:= 0
	Local nTotalV	:= 0 
	Local nTotalD	:= 0
	
	Private oTmpTable	:= Nil

	//Monta e alimenta o arquivo de trabalho
	TempFOR(1,oReport,.T.,MV_PAR01,MV_PAR02)

	//������������������������������������������������������������������������Ŀ
	//�Transforma parametros Range em expressao SQL                            �
	//��������������������������������������������������������������������������
	MakeSqlExpr(oReport:uParam)
	MakeAdvplExpr(oReport:uParam)

	dbSelectArea("TMP")
	oReport:SetMeter(TMP->(LastRec()))

	oContr:SetFilter(cCondicao)
	oContr:Cell("cPeriodo"):SetBlock({|| cPeriodo }) 
	oContr:Init()
	oContr:Print()
	oContr:Finish()

	//CAMPO 20
	lGerou := .F.
	oReport:ThinLine()
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText(STR0022)	//"Rela��o de fornecedores cujas opera��es originaram imposto deduzido no periodo"
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText(STR0007)	//"CAMPO 20 - Imobilizado"
	oReport:ThinLine()
	oCampo20:Init()
	TMP->(dbSeek("20"))
	Do While !oReport:Cancel() .And. !TMP->(Eof()) .And. TMP->TMP_CMP=="20"

		If oReport:Cancel()
			Exit
		EndIf

		oCampo20:IncMeter()

		If TMP->TMP_IVAEXC > 0
			//Inferior a 5000 entra em um quadro especifico
			If TMP->TMP_IVAEXC < nMVLIMFOR
				nAqInfV	+= TMP->TMP_IVAEXC
				nAqInfD	+= TMP->TMP_VLRDED
			Else
				oCampo20:PrintLine()
				lGerou	:=	.T.
			EndIf
			nTotalV	+= TMP->TMP_IVAEXC
			nTotalD	+= TMP->TMP_VLRDED
		EndIf

		TMP->(dbSkip())
	EndDo
	oCampo20:Finish()

	If !lGerou
		oReport:PrintText(STR0023)	//"*** Sem informa��o ***"
	EndIf

	//CAMPO 21
	lGerou := .F.
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText(STR0016)	//"CAMPO 21 (Exist�ncias a taxa reduzida)"
	oReport:ThinLine()
	oCampo21:Init()
	
	TMP->(dbSeek("21"))
	Do While !oReport:Cancel() .And. !TMP->(Eof()) .And. TMP->TMP_CMP == "21"

		If oReport:Cancel()
			Exit
		EndIf

		oCampo21:IncMeter()

		If TMP->TMP_IVAEXC > 0
			//Inferior a 5000 entra em um quadro especifico
			If TMP->TMP_IVAEXC < nMVLIMFOR
				nAqInfV	+= TMP->TMP_IVAEXC
				nAqInfD	+= TMP->TMP_VLRDED
			Else
				oCampo21:PrintLine()
				lGerou := .T.
			EndIf
			nTotalV	+=	TMP->TMP_IVAEXC
			nTotalD	+=	TMP->TMP_VLRDED
		EndIf

		TMP->(dbSkip())
	EndDo
	oCampo21:Finish()

	If !lGerou
		oReport:PrintText(STR0023)	//"*** Sem informa��o ***"
	EndIf

	//CAMPO 22
	lGerou	:=	.F.
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText(STR0017)	//"CAMPO 22 (Exist�ncias a taxa normal)"
	oReport:ThinLine()
	oCampo22:Init()
	
	TMP->(dbSeek("22"))
	Do While !oReport:Cancel() .And. !TMP->(Eof()) .And. TMP->TMP_CMP == "22"

		If oReport:Cancel()
			Exit
		EndIf

		oCampo22:IncMeter()

		If TMP->TMP_IVAEXC > 0
			//Inferior a 5000 entra em um quadro especifico
			If TMP->TMP_IVAEXC < nMVLIMFOR
				nAqInfV	+= TMP->TMP_IVAEXC
				nAqInfD	+= TMP->TMP_VLRDED
			Else
				oCampo22:PrintLine()
				lGerou := .T.
			EndIf
			nTotalV	+= TMP->TMP_IVAEXC
			nTotalD	+= TMP->TMP_VLRDED
		EndIf
		TMP->(dbSkip())
	EndDo
	oCampo22:Finish()

	If !lGerou
		oReport:PrintText(STR0023)	//"*** Sem informa��o ***"
	EndIf

	//CAMPO 23
	lGerou	:=	.F.
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText(STR0018)	//"CAMPO 23 (Exist�ncias a taxa interm�dia)"
	oReport:ThinLine()
	oCampo23:Init()
	
	TMP->(dbSeek("23"))
	Do While !oReport:Cancel() .And. !TMP->(Eof()) .And. TMP->TMP_CMP == "23"

		If oReport:Cancel()
			Exit
		EndIf

		oCampo23:IncMeter()

		//Inferior a 5000 entra em um quadro especifico
		If TMP->TMP_IVAEXC > 0
			If TMP->TMP_IVAEXC < nMVLIMFOR
				nAqInfV	+= TMP->TMP_IVAEXC
				nAqInfD	+= TMP->TMP_VLRDED
			Else
				oCampo23:PrintLine()
				lGerou := .T.
			EndIf
			nTotalV	+= TMP->TMP_IVAEXC
			nTotalD	+= TMP->TMP_VLRDED
		EndIf
		TMP->(dbSkip())
	EndDo
	oCampo23:Finish()

	If !lGerou
		oReport:PrintText(STR0023)	//"*** Sem informa��o ***"
	EndIf

	//CAMPO 24
	lGerou	:=	.F.
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText(STR0019)	//"CAMPO 24 (Outros bens e servi�os)"
	oReport:ThinLine()
	oCampo24:Init()
	
	TMP->(dbSeek("24"))
	Do While !oReport:Cancel() .And. !TMP->(Eof()) .And. TMP->TMP_CMP == "24"

		If oReport:Cancel()
			Exit
		EndIf

		oCampo24:IncMeter()

		If TMP->TMP_IVAEXC > 0
			//Inferior a 5000 entra em um quadro especifico
			If TMP->TMP_IVAEXC < nMVLIMFOR
				nAqInfV	+= TMP->TMP_IVAEXC
				nAqInfD	+= TMP->TMP_VLRDED
			Else
				oCampo24:PrintLine()
				lGerou := .T.
			EndIf
			nTotalV += TMP->TMP_IVAEXC
			nTotalD += TMP->TMP_VLRDED
		EndIf

		TMP->(dbSkip())
	EndDo
	oCampo24:Finish()

	If !lGerou
		oReport:PrintText(STR0023)	//"*** Sem informa��o ***"
	EndIf

	oReport:SkipLine()
	oReport:SkipLine()
	oReport:PrintText(STR0020)	//"Aquisi��es de montante inferior a 5.000 euros"
	oReport:ThinLine()
	oAqInf:Cell("nAqInfV"):SetBlock({|| nAqInfV}) 
	oAqInf:Cell("nAqInfD"):SetBlock({|| nAqInfD}) 
	oAqInf:Init()
	oAqInf:Print()
	oAqInf:Finish()

	oReport:SkipLine()
	oReport:SkipLine()
	oTotal:SetFilter(cCondicao)
	oReport:PrintText(STR0021)	//"Total"
	oReport:ThinLine()
	oTotal:Cell("nTotalV"):SetBlock({|| nTotalV}) 
	oTotal:Cell("nTotalD"):SetBlock({|| nTotalD}) 
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
���Programa  �TempFOR   � Autor � Gustavo G. Rueda      � Data �22/05/2008���
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
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TempFOR(nOpc, oReport, lRelat, dDataDe, dDataAte)
	
	Local cAls			:= GetNextAlias()
	Local nTam			:= 0
	Local aStr			:= {}
	Local nSeq			:= 0
	Local cDE			:= ""
	Local cMVRELPAIS	:= GetNewPar("MV_RELPAIS", "072=AT;876=BE;087=BE;111=BG;163=CY;647=CZ;023=DE;232=DK;251=EE;301=EL;245=ES;271=FI;275=FR;628=GB;355=HU;375=IE;386=IT;442=LT;445=LU;427=LV;467=MT;=NL;603=PL;607=PT;670=RO;764=SE;246=SI;247=SK")
	Local cPais			:= ""
	Local aMVRELPAIS	:= {}
	Local cWhere		:= ""
	Local cWhere1		:= ""
	Local cWhere2		:= ""
	Local lMov			:= .F.
	Local cChave		:= ""
	Local cMVCMP21		:= IIf(Empty(GetNewPar("MV_CMP21","4,5")),"4,5",AllTrim(GetNewPar("MV_CMP21","4,5")))
	Local cMVCMP22		:= IIf(Empty(GetNewPar("MV_CMP22","15,21")),"15,21",AllTrim(GetNewPar("MV_CMP22","15,21")))
	Local cMVCMP23		:= IIf(Empty(GetNewPar("MV_CMP23","8,12")),"8,12",AllTrim(GetNewPar("MV_CMP23","8,12")))
	Local aCampos		:= {}
	Local nI			:= 0
	Local aOrdem		:= {}

	If nOpc == 1
	
		aAdd(aStr,{"TMP_SEQ",		"C",	005,	0})
		aAdd(aStr,{"TMP_CMP",		"C",	002,	0})
		aAdd(aStr,{"TMP_PREF",		"C",	002,	0})
		nTam	:=	TamSx3("A2_CGC")[1]
		aAdd(aStr,{"TMP_NIF",		"C",	nTam,	0})
		nTam	:=	TamSx3("F1_LIQIMP")[1]
		aAdd(aStr,{"TMP_NUMLIQ",	"C",	nTam,	0})
		aAdd(aStr,{"TMP_ANO",		"C",	004,	0})
		aAdd(aStr,{"TMP_MES",		"C",	002,	0})
		aAdd(aStr,{"TMP_IVAEXC",	"N",	018,	2})	
		aAdd(aStr,{"TMP_VLRDED",	"N",	018,	2})
		
		aOrdem	:= {"TMP_CMP", "TMP_PREF", "TMP_NIF", "TMP_NUMLIQ", "TMP_ANO", "TMP_MES"}
		
		oTmpTable := FWTemporaryTable():New("TMP")
		oTmpTable:SetFields(aStr)
		oTmpTable:AddIndex("IN1", aOrdem)
		
		oTmpTable:Create()

		aMVRELPAIS	:=	LoadPais(cMVRELPAIS, @cPais)
		cWhereA		:=	"%A2_PAIS IN(" + IIf(Empty(cPais), "''", cPais) + ")%"
		cWhereB		:=	"%A1_PAIS IN(" + IIf(Empty(cPais), "''", cPais) + ")%"
		cWhere		:=	"%(D1_ALQIMP1 IN(" + AllTrim(cMVCMP21)
		cWhere		+=	"," + AllTrim(cMVCMP22)
		cWhere		+=	"," + AllTrim(cMVCMP23) + ") OR "
		cWhere		+=	"D1_ALQIMP3 IN(" + AllTrim(cMVCMP21)
		cWhere		+=	"," + AllTrim(cMVCMP22)
		cWhere		+=	"," + AllTrim(cMVCMP23) + ") OR "
		cWhere		+=	"D1_ALQIMP4 IN(" + AllTrim(cMVCMP21)
		cWhere		+=	"," + AllTrim(cMVCMP22)
		cWhere		+=	"," + AllTrim(cMVCMP23) + ") OR "
		cWhere		+=	"D1_ALQIMP5 IN(" + AllTrim(cMVCMP21)
		cWhere		+=	"," + AllTrim(cMVCMP22)
		cWhere		+=	"," + AllTrim(cMVCMP23) + ") OR "
		cWhere		+=	"D1_ALQIMP6 IN(" + AllTrim(cMVCMP21)
		cWhere		+=	"," + AllTrim(cMVCMP22)
		cWhere		+=	"," + AllTrim(cMVCMP23) + "))%"

		BeginSql Alias cAls
	
			COLUMN F1_EMISSAO AS DATE
	
			//DIFERENTES DE DEVOLUCAO
			SELECT A2_CGC CGC, A2_PAIS PAIS, F1_LIQIMP, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F4_CONSUMO, F4_ATUATF, F1_EMISSAO,
			D1_ALQIMP1, D1_BASIMP1, D1_VALIMP1, D1_ALQIMP3, D1_BASIMP3, D1_VALIMP3, D1_ALQIMP4, D1_BASIMP4, D1_VALIMP4,
			D1_ALQIMP5, D1_BASIMP5, D1_VALIMP5, D1_ALQIMP6, D1_BASIMP6, D1_VALIMP6
	
			FROM %table:SF1% SF1, %table:SD1% SD1, %table:SA2% SA2, %table:SF4% SF4
	
			WHERE 	SF1.%NotDel%          		        AND
			SD1.%NotDel%          		        AND
			SA2.%NotDel%          		        AND
			SF4.%NotDel%          		        AND
	
			SF1.F1_FILIAL	=	%xFilial:SF1% 	AND
			SF1.F1_EMISSAO 	>= %Exp:Dtos(dDataDe)% AND 
			SF1.F1_EMISSAO 	<= %Exp:Dtos(dDataAte)% AND
			SF1.F1_TIPO		NOT IN('D','B')		AND
	
			SD1.D1_FILIAL	=	%xFilial:SD1% 	AND
			SD1.D1_DOC		=	SF1.F1_DOC	 	AND
			SD1.D1_SERIE	=	SF1.F1_SERIE 	AND
			SD1.D1_FORNECE	=	SF1.F1_FORNECE	AND
			SD1.D1_LOJA		=	SF1.F1_LOJA 	AND
	
			SF4.F4_FILIAL	=	%xFilial:SF4% 	AND
			SF4.F4_CODIGO	=	SD1.D1_TES		AND
			(SF4.F4_CONSUMO	=	'S'				OR
			SF4.F4_ATUATF	=	'S'				OR
			%Exp:cWhere%)						AND
	
			SA2.A2_FILIAL  	=  %xFilial:SA2% 	AND
			SA2.A2_COD     	= 	SF1.F1_FORNECE 	AND
			SA2.A2_LOJA    	=   SF1.F1_LOJA 	AND
			%Exp:cWhereA%						AND
	
			//TEM QUE CONSTAR NOS LIVROS FISCAIS
			(SELECT COUNT(0) FROM %table:SF3% SF3 WHERE SF3.%NotDel% AND SF3.F3_FILIAL = %xFilial:SF3% AND 
			SF3.F3_NFISCAL = SF1.F1_DOC AND SF3.F3_SERIE = SF1.F1_SERIE AND SF3.F3_CLIEFOR = SF1.F1_FORNECE AND 
			SF3.F3_LOJA = SF1.F1_LOJA AND SF3.F3_TIPOMOV='C')>0
	
			UNION
	
			//DEVOLUCAO
			SELECT A1_CGC CGC, A1_PAIS PAIS, F1_LIQIMP, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F4_CONSUMO, F4_ATUATF, F1_EMISSAO,
			D1_ALQIMP1, D1_BASIMP1, D1_VALIMP1, D1_ALQIMP3, D1_BASIMP3, D1_VALIMP3, D1_ALQIMP4, D1_BASIMP4, D1_VALIMP4,
			D1_ALQIMP5, D1_BASIMP5, D1_VALIMP5, D1_ALQIMP6, D1_BASIMP6, D1_VALIMP6
	
			FROM %table:SF1% SF1, %table:SD1% SD1, %table:SA1% SA1, %table:SF4% SF4
	
			WHERE 	SF1.%NotDel%          		        AND
			SD1.%NotDel%          		        AND
			SA1.%NotDel%          		        AND
			SF4.%NotDel%          		        AND
	
			SF1.F1_FILIAL	=	%xFilial:SF1% 	AND
			SF1.F1_EMISSAO 	>= %Exp:Dtos(dDataDe)% AND 
			SF1.F1_EMISSAO 	<= %Exp:Dtos(dDataAte)% AND
			SF1.F1_TIPO		IN('D','B')			AND
	
			SD1.D1_FILIAL	=	%xFilial:SD1% 	AND
			SD1.D1_DOC		=	SF1.F1_DOC	 	AND
			SD1.D1_SERIE	=	SF1.F1_SERIE 	AND
			SD1.D1_FORNECE	=	SF1.F1_FORNECE	AND
			SD1.D1_LOJA		=	SF1.F1_LOJA 	AND
	
			SF4.F4_FILIAL	=	%xFilial:SF4% 	AND
			SF4.F4_CODIGO	=	SD1.D1_TES		AND
			(SF4.F4_CONSUMO	=	'S'				OR
			SF4.F4_ATUATF	=	'S'				OR
			%Exp:cWhere%)						AND
	
			SA1.A1_FILIAL  	=  %xFilial:SA1% 	AND
			SA1.A1_COD     	= 	SF1.F1_FORNECE 	AND
			SA1.A1_LOJA    	=   SF1.F1_LOJA 	AND
			%Exp:cWhereB%						AND
	
			//TEM QUE CONSTAR NOS LIVROS FISCAIS
			(SELECT COUNT(0) FROM %table:SF3% SF3 WHERE SF3.%NotDel% AND SF3.F3_FILIAL = %xFilial:SF3% AND 
			SF3.F3_NFISCAL = SF1.F1_DOC AND SF3.F3_SERIE = SF1.F1_SERIE AND SF3.F3_CLIEFOR = SF1.F1_FORNECE AND 
			SF3.F3_LOJA = SF1.F1_LOJA AND SF3.F3_TIPOMOV='C') > 0
	
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

			lMov :=	.T.     
			nPos := aScan(aMVRELPAIS, {|aX| (cAls)->PAIS $ aX[1]})

			For nI := 1 To 6
				If nI == 2 //Campos ...2 nao entram, pois se refere ao IRC
					Loop
				EndIf

				aCampos	:=	{"D1_BASIMP" + Str(nI, 1), "D1_ALQIMP" + Str(nI, 1), "D1_VALIMP" + Str(nI,1)}

				//Tratamento conforme especificacoes do layout
				If (cAls)->F4_ATUATF == "S"
					cCmp :=	"20"
				ElseIf (cAls)->F4_CONSUMO == "S"	//CONSUMO
					cCmp :=	"24"
				ElseIf AllTrim(Str((cAls)->&(aCampos[2])))$cMVCMP21
					cCmp :=	"21"
				ElseIf AllTrim(Str((cAls)->&(aCampos[2])))$cMVCMP22
					cCmp :=	"22"
				ElseIf AllTrim(Str((cAls)->&(aCampos[2])))$cMVCMP23
					cCmp :=	"23"
				EndIf

				If TMP->(dbSeek(cCmp+aMVRELPAIS[nPos,2]+PadR(aRetDig((cAls)->CGC,.F.),TamSx3("A2_CGC")[1])+(cAls)->F1_LIQIMP+StrZero(Year((cAls)->F1_EMISSAO),4)+StrZero(Month((cAls)->F1_EMISSAO),2)))
					RecLock("TMP",.F.)
				Else
					RecLock("TMP",.T.)
					TMP->TMP_SEQ	:= StrZero(Val(TMP_SEQ)+1,5)
					TMP->TMP_CMP	:= cCmp
					TMP->TMP_PREF	:= IIf(Empty((cAls)->F1_LIQIMP),aMVRELPAIS[nPos,2],"")
					TMP->TMP_NIF	:= IIf(Empty((cAls)->F1_LIQIMP),PadR(aRetDig((cAls)->CGC,.F.),TamSx3("A2_CGC")[1]),"")
					TMP->TMP_NUMLIQ	:= (cAls)->F1_LIQIMP
					TMP->TMP_ANO	:= StrZero(Year((cAls)->F1_EMISSAO),4)
					TMP->TMP_MES	:= StrZero(Month((cAls)->F1_EMISSAO),2)
				EndIf
				TMP->TMP_IVAEXC	+=	(cAls)->&(aCampos[1])
				TMP->TMP_VLRDED	+=	(cAls)->&(aCampos[3])
				MsUnLock()
				FkCommit()
			Next
			(cAls)->(dbSkip())
		EndDo
		(cAls)->(dbCloseArea())
			
	EndIf
	
Return lMov

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �LoadPais  � Autor � Gustavo G. Rueda      � Data �22/05/2008���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Funcao utilizada para montar um array de DEPARA para o      ���
���          � codigo do pais informado no campo A2_PAIS .                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �aPar - Array DEPARA                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cMVRELPAIS - Conteudo do paramento MV_RELPAIS               ���
���          �cPais - Paramentro passado por referencia para retornar uma ���
���          � string para montar a query.                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function LoadPais(cMVRELPAIS, cPais)
	
	Local nI	:= 1
	Local aPar	:= {}

	cMVRELPAIS := AllTrim(cMVRELPAIS)

	While nI <> 0
		aAdd(aPar, {SubStr(cMVRELPAIS, 1, 3), SubStr(cMVRELPAIS, 5, 2)})
		cPais		+= "'" + SubStr(cMVRELPAIS, 1, 3) + "',"
		nI			:= At(";", cMVRELPAIS)
		cMVRELPAIS	:= SubStr(cMVRELPAIS, nI + 1)
	End
	cPais	:=	SubStr(cPais,1,Len(cPais)-1)

Return aPar
