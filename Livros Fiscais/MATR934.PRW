#Include "Protheus.Ch"
#Include "MATR934.CH"

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    � MATR934  � Autor � Liber de Esteban      � Data � 24/05/2006 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Controle Trimestral de Vendas de Produtos Veterinarios.       ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
FUNCTION MATR934()

Local oReport
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

If lVerpesssen
	If TRepInUse()
		//������������������������������������������������������������������������Ŀ
		//�Interface de impressao                                                  �
		//��������������������������������������������������������������������������
		oReport := ReportDef()
		oReport:PrintDialog()
	Else
		MATR934R3()
	EndIf
EndIf

Return

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���FUNCAO    �ReportDef � Autor � Liber de Esteban      � Data � 24/05/2006 ���
���������������������������������������������������������������������������Ĵ��
���DESCRICAO � Definicao do componente                                      ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local oEmpresa
Local oProduto
Local oCliente
Local cPerg := "MTR934"



//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������

oReport := TReport():New("MATR934",STR0031,cPerg,; //"Controle de Produtos Veterin�rios"
{|oReport| ReportPrint(oReport)},STR0032)  //"Rela��o dos nomes dos compradores e quantitativos comercializados � ser encaminhado a Delegacia Federal de Agricultura"

oReport:SetTotalInLine(.F.)
Pergunte(cPerg,.F.)

//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//��������������������������������������������������������������������������

oEmpresa:=TRSection():New(oReport,STR0042,{"SM0"},{STR0033}/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/) //"Empresa"###"Produto + Cliente + Loja"
TRCell():New(oEmpresa,"M0_NOMECOM","SM0",STR0034,/*Picture*/,50,/*lPixel*/,/*{|| code-block de impressao }*/) //"Estabelecimento"
TRCell():New(oEmpresa,"PERIODO"   ,     ,STR0035,/*Picture*/,50,/*lPixel*/,{|| DTOC(mv_par01) + STR0041 + DTOC(mv_par02)}) //"Per�odo"###" a "

oProduto:=TRSection():New(oEmpresa,"Produto",{"TRB"},{STR0033}/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/) //""Produto""###"Produto + Cliente + Loja"
oProduto:SetEdit(.F.)
TRCell():New(oProduto,"TRB_CODPRO","TRB",STR0036,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/) //"Produto"
TRCell():New(oProduto,"TRB_DESCPR","TRB",STR0037,/*Picture*/,50,/*lPixel*/,/*{|| code-block de impressao }*/) //"Descri��o"

oCliente:=TRSection():New(oEmpresa,STR0043,{"SF2"},{STR0033}/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/) //""Movimentos""###"Produto + Cliente + Loja"
oCliente:SetNoFilter({"SF2"})
TRCell():New(oCliente,"TRB_CODCLI","TRB",STR0038,/*Picture*/     ,06,/*lPixel*/,/*{|| code-block de impressao }*/) //"Cliente"
TRCell():New(oCliente,"TRB_DESCCL","TRB",STR0039,/*Picture*/     ,50,/*lPixel*/,/*{|| code-block de impressao }*/) //"Nome"
TRCell():New(oCliente,"TRB_QUANT" ,"TRB",STR0040,"@E 99999999.99",11,/*lPixel*/,/*{|| code-block de impressao }*/) //"Quantidade"

oCliente:SetTotalInLine(.F.)
oCliente:SetTotalText(STR0044) //"Total do produto"

//Totaliza quantidade por produto
TRFunction():New(oCliente:Cell("TRB_QUANT"),NIL,"SUM",,,"@E 99999999.99",/*uFormula*/,.T.,.F.,.F.)

//Totaliza quantidade geral
TRFunction():New(oCliente:Cell("TRB_QUANT"),NIL,"SUM",,,"@E 99999999.99",/*uFormula*/,.F.,.T.,.F.)

Return(oReport)

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor �Liber de Esteban       � Data �10/05/2006���
��������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os  ���
���          �relatorios que poderao ser agendados pelo usuario.           ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                            ���
��������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                          ���
��������������������������������������������������������������������������Ĵ��
���          �               �                                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function ReportPrint(oReport)

R934Trb()

DbSelectArea("TRB")
DbGoTop()

oReport:Section(1):Init()
oReport:Section(1):PrintLine()
oReport:Section(1):Finish()
oReport:SkipLine()

Do While !oReport:Cancel() .And. !("TRB")->(Eof())
	
	cCodProd := ("TRB")->TRB_CODPRO
	oReport:Section(1):Section(1):Init()
	oReport:Section(1):Section(1):PrintLine()
	
	oReport:Section(1):Section(2):Init()
	Do While (cCodProd == ("TRB")->TRB_CODPRO)
		oReport:Section(1):Section(2):PrintLine()
		dbSkip()
	EndDo
	oReport:Section(1):Section(2):Finish()
	
	oReport:Section(1):Section(1):Finish()
	oReport:SkipLine()
	oReport:SkipLine()
	
EndDo

dbSelectArea("TRB")
dbCloseArea()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MATR934R3 � Autor �Gustavo G. Rueda       � Data �03.01.2005|��
�������������������������������������������������������������������������Ĵ��
���Descri��o �Controle Trimestral de Vendas de Produtos Veterinarios.(R3) ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1 -> lRet = Retorno sempre .T.                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MATR934R3()
	Local 	NomeProg	:= 	"MATR934"
	Local 	aArea		:= 	GetArea ()
	Local 	cPerg		:= 	"MTR934"
	Local	lRet		:=	.T.
	Local 	cTitulo  	:= STR0001	//"Controle de Produtos Veterin�rios."
	Local 	cDesc1  	:= STR0002	//"Rela��o dos nomes dos compradores e quantitativos comercializados � ser encaminhado a Delegacia Federal de Agricultura do estado onde se localiza o estabelecimento."
	Local 	cDesc2  	:= ""
	Local 	cDesc3  	:= ""
	Local 	wnrel   	:= NomeProg
	Local	cString		:=	""
	Local 	Tamanho 	:= 	"P" 	// P/M/G
	Private Limite 	:= 	80		// 80/132/220
	Private lEnd    	:= 	.F.		// Controle de cancelamento do relatorio
	Private m_pag   	:= 	1  		// Contador de Paginas
	Private nLastKey	:=	0  		// Controla o cancelamento da SetPrint e SetDefault
	Private aReturn 	:= {STR0003, 1, STR0004, 2, 2, 1, "", 1 }	//"Zebrado"###"Administracao"
	//
	Pergunte (cPerg, .F.)
	//������������������������������������������������������������������������Ŀ
	//�Envia para a SetPrinter                                                 �
	//��������������������������������������������������������������������������
	wnrel	:=	SetPrint (cString, NomeProg, cPerg, @cTitulo, cDesc1, cDesc2, cDesc3, .F.,, .F., Tamanho,, .F.)
	//
	If (nLastKey==27)
		Return (lRet)
	Endif
	//
	SetDefault (aReturn, cString)
	//
	If (nLastKey==27)
		Return (lRet)
	Endif
	//������������������������������������������������������������������������Ŀ
	//�Preparacao do inicio de processamento do arquivo pre-formatado          �
	//��������������������������������������������������������������������������
	RptStatus ({|lEnd| R934Proc (@lEnd, cTitulo, wnrel, Tamanho)}, cTitulo)
	//
	If (aReturn[5]==1)
		Set Printer To 	
	   	ourspool(wnrel)
	Endif
	MS_FLUSH()
	//���������������Ŀ
	//� Restaura area �
	//�����������������
	RestArea (aArea)
Return (lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �R934Proc  � Autor �Gustavo G. Rueda       � Data �03/01/2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime a Relatorio.                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpL1 - Variavel de controle para cancelamento do relatorio ���
���          �ExpC1 - Titulo do Relatorio.                                ���
���          �ExpC2 - Nome do Arquivo.                                    ���
���          �ExpN3 - Tamanho do Relatorio (P)                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1 -> lRet = Retorno sempre .T.                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MATR934                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R934Proc (lEnd, cTitulo, wnrel, nTamanho)
	Local	lRet		:=	.T.
	Local	cCabec1		:=	STR0005+PadR (SM0->M0_NOMECOM, 50)
	Local	cDataDe		:=	StrZero (Day (MV_PAR01), 2)+"/"+StrZero (Month (MV_PAR01), 2)+"/"+StrZero (Year (MV_PAR01), 4)
	Local	cDataAte	:=	StrZero (Day (MV_PAR02), 2)+"/"+StrZero (Month (MV_PAR02), 2)+"/"+StrZero (Year (MV_PAR02), 4)
	Local	cCabec2		:=	Padr (STR0006+cDataDe+STR0007+cDataAte, 80)	//"Per�odo: "###" a "
	Local	aLayout		:=	{}
	Local	aTrb		:=	R934Trb ()	//Criacao do arquivo de trabalho ja alimentado e pronto para impressao.
	Local	nAcQuant	:=	0
	Local	nLinPag		:=	60
	Local 	nTipo		:= 	Iif (aReturn[4]==1, 15, 18)	//Inicializa os codigos de caracter Comprimido/Normal da impressora	
	Private 	m_pag  	:= 	1
	Private 	li   	:= 	99
	//���������������������������Ŀ
	//�Funcao para montar o layout�
	//�����������������������������
	Cabec (cTitulo, cCabec1, cCabec2, wnRel, nTamanho, nTipo)
	aLayout	:=	R934Lay ()
	//
	DbSelectArea (aTrb[1])
	(aTrb[1])->(DbGoTop ())
	//
	Do While !(aTrb[1])->(Eof ())
		cCodProd	:=	(aTrb[1])->TRB_CODPRO
		//
		FmtLin ({(aTrb[1])->TRB_DESCPR}, aLayout[1],,, li++)
		FmtLin (, aLayout[3],,, li++)
		FmtLin (, aLayout[2],,, li++)
		//
		Do While (cCodProd==(aTrb[1])->TRB_CODPRO)
			//
			If (li>nLinPag)
				li++
				FmtLin ({"", STR0008}, aLayout[4],,, li++)	//"A Transportar..."
				//
				li	:=	99
				Cabec (cTitulo, cCabec1, cCabec2, wnRel, nTamanho, nTipo)
				FmtLin ({(aTrb[1])->TRB_DESCPR}, aLayout[1],,, li++)
				FmtLin (, aLayout[3],,, li++)
				FmtLin (, aLayout[2],,, li++)
			EndIf
			//
			FmtLin ({(aTrb[1])->TRB_DESCCL, Transform ((aTrb[1])->TRB_QUANT, "@E  9,999,999,999.99")}, aLayout[4],,, li++)
			nAcQuant	+=	(aTrb[1])->TRB_QUANT
			//
			(aTrb[1])->(DbSkip ())
		EndDo
		FmtLin (, aLayout[2],,, li++)
		FmtLin ({"", Transform (nAcQuant, "@E  9,999,999,999.99")}, aLayout[4],,, li++)
		//
		li++
		nAcQuant	:=	0
		//
	EndDo
	//������������������Ŀ
	//�Apago arquivo TRB.�
	//��������������������
	DbSelectArea (aTrb[1])
	(aTrb[1])->(DbCloseArea ())
	Ferase (aTrb[2]+GetDBExtension ())
	Ferase (aTrb[2]+OrdBagExt ())
Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    R934Trb    � Autor �Gustavo G. Rueda       � Data �03/01/2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monto TRB com as informacoes a serem processadas.           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�nenhum.                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �TRB utilizado para impressao.                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MATR934                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R934Trb()
	Local	cAliasSf2	:=	"SF2"
	Local	cArqSf2		:=	""
	Local	cQuery		:=	""
	Local	cAliasSd2	:=	"SD2"
	Local	cArqSd2		:=	""
	Local	cArqTrb		:=	""
	Local	aStru		:=	{}
	Local	cDescCli	:=	""
	Local	aTrb		:=	{}
	Local	aStruSf2	:=	{}
	Local	aStruSd2	:=	{}
	Local	nX			:=	0
	Local	nRegsSf2	:=	0
	//���������������������������Ŀ
	//�Monto o TRB para impressao.�
	//�����������������������������
	aAdd (aStru, {"TRB_CODCLI",		"C",	TAMSX3 ("A1_COD")[1],		TAMSX3 ("A1_COD")[2]})
	aAdd (aStru, {"TRB_LOJCLI",		"C",	TAMSX3 ("A1_LOJA")[1],		TAMSX3 ("A1_LOJA")[2]})
	aAdd (aStru, {"TRB_CODPRO",		"C",	TAMSX3 ("B1_COD")[1],		TAMSX3 ("B1_COD")[2]})
	aAdd (aStru, {"TRB_DESCCL",		"C",	TAMSX3 ("A1_NOME")[1],		TAMSX3 ("A1_NOME")[2]})
	aAdd (aStru, {"TRB_DESCPR",		"C",	TAMSX3 ("B1_DESC")[1],		TAMSX3 ("B1_DESC")[2]})
	aAdd (aStru, {"TRB_QUANT",		"N",	TAMSX3 ("D2_QUANT")[1],		TAMSX3 ("D2_QUANT")[2]})
	//
	cArqTrb	:=	CriaTrab (aStru)
	DbUseArea (.T.,__LocalDriver, cArqTrb, "TRB")
	IndRegua ("TRB", cArqTrb, "TRB_CODPRO+TRB_CODCLI+TRB_LOJCLI")
	aTrb	:=	{"TRB", cArqTrb}
	//
	DbSelectArea ("SF2")
		SF2->(DbSetOrder (1))
	//
	#IFDEF TOP
		If (TcSrvType ()<>"AS/400")
			cAliasSf2	:=	"SF2Query"
			aStruSF2  	:= SF2->(DbStruct ())
			//
			cQuery	:=	"SELECT "
				cQuery	+=	"SF2.F2_FILIAL, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_EMISSAO, SF2.F2_TIPO "
			cQuery	+=	"FROM "
				cQuery	+=	RetSqlName ("SF2")+" SF2 "
			cQuery	+=	"WHERE "
				cQuery	+=	"SF2.F2_FILIAL='"+xFilial ("SF2")+"' AND "
				cQuery	+=	"SF2.F2_EMISSAO>='"+DToS (MV_PAR01)+"' AND "
				cQuery	+=	"SF2.F2_EMISSAO<='"+DToS (MV_PAR02)+"' AND "
				cQuery	+=	"SF2.F2_TIPO IN ('N','D','B') AND "
				cQuery	+=	"SF2.D_E_L_E_T_ = ' ' "
			cQuery	+=	"ORDER BY "	
				cQuery	+=	"SF2.F2_FILIAL, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA "
			//
			cQuery := ChangeQuery (cQuery)
			//
			dbUseArea (.T., "TOPCONN", TcGenQry (,,cQuery), cAliasSf2, .T., .T.)
			//
			For nX := 1 To Len (aStruSF2)
				If (aStruSF2[nX][2]<>"C") 
					TcSetField (cAliasSF2, aStruSF2[nX][1], aStruSF2[nX][2], aStruSF2[nX][3], aStruSF2[nX][4])
				EndIf
			Next (nX)
		Else
	#ENDIF
			cArqSf2 := CriaTrab (Nil, .F.)
			cQuery	:=	"F2_FILIAL=='"+xFilial ("SF2")+"' .And. DTOS (F2_EMISSAO)>='"+DTOS (MV_PAR01)+"' .And. DTOS (F2_EMISSAO)<='"+DTOS (MV_PAR02)+"' .And. "
			cQuery	+=	"F2_TIPO$'NDB' "
			IndRegua (cAliasSf2, cArqSf2, IndexKey (),, cQuery, STR0009)	//"Selecionando Documentos ..."
	#IFDEF TOP
		EndIf
	#ENDIF
	//
	DbSelectArea (cAliasSf2)
		nRegsSf2 := LastREc()
		(cAliasSf2)->(DbGoTop ())
	//
	Do While !(cAliasSf2)->(Eof ())
		If ((cAliasSf2)->F2_TIPO$"DB")
			SA2->(DbSeek (xFilial ("SA2")+(cAliasSf2)->F2_CLIENTE+(cAliasSf2)->F2_LOJA))
			cDescCli	:=	SA2->A2_NOME
		Else
			SA1->(DbSeek (xFilial ("SA1")+(cAliasSf2)->F2_CLIENTE+(cAliasSf2)->F2_LOJA))
			cDescCli	:=	SA1->A1_NOME
		EndIf
		//	
		DbSelectArea ("SD2")
			SD2->(DbSetOrder (3))
		//
		#IFDEF TOP
			If (TcSrvType ()<>"AS/400")
				cAliasSd2	:=	"SD2query"
				aStruSd2 	:= SD2->(DbStruct ())
				//
				cQuery	:=	"SELECT "
					cQuery	+=	"SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, SD2.D2_QUANT, SB1.B1_DESC "
				cQuery	+=	"FROM "
					cQuery	+=	RetSqlName ("SD2")+" SD2, "+RetSqlName ("SB1")+" SB1 "
				cQuery	+=	"WHERE "
					cQuery	+=	"SD2.D2_FILIAL='"+xFilial ("SD2")+"' AND "
					cQuery	+=	"SD2.D2_DOC='"+(cAliasSf2)->F2_DOC+"' AND "
					cQuery	+=	"SD2.D2_SERIE='"+(cAliasSf2)->F2_SERIE+"' AND "
					cQuery	+=	"SD2.D2_CLIENTE='"+(cAliasSf2)->F2_CLIENTE+"' AND "
					cQuery	+=	"SD2.D2_LOJA='"+(cAliasSf2)->F2_LOJA+"' AND "
					cQuery	+=	"SD2.D2_COD>='"+MV_PAR03+"' AND "
					cQuery	+=	"SD2.D2_COD<='"+MV_PAR04+"' AND "
					cQuery	+=	"SB1.B1_FILIAL='"+xFilial ("SB1")+"' AND "
					cQuery	+=	"SB1.B1_GRUPO>='"+MV_PAR05+"' AND "
					cQuery	+=	"SB1.B1_GRUPO<='"+MV_PAR06+"' AND "
					cQuery	+=	"SB1.B1_COD=SD2.D2_COD AND "
					cQuery	+=	"SB1.D_E_L_E_T_ = ' ' AND "
					cQuery	+=	"SD2.D_E_L_E_T_ = ' ' "
				cQuery	+=	"ORDER BY "	
					cQuery	+=	"SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD "
				//
				cQuery := ChangeQuery (cQuery)
				//
				dbUseArea (.T., "TOPCONN", TcGenQry (,,cQuery), cAliasSd2, .T., .T.)
				//
				For nX := 1 To Len (aStruSd2)
					If (aStruSd2[nX][2]<>"C")
						TcSetField (cAliasSd2, aStruSd2[nX][1], aStruSd2[nX][2], aStruSd2[nX][3], aStruSd2[nX][4])
					EndIf
				Next (nX)
			Else
		#ENDIF
				cArqSd2 := CriaTrab (Nil, .F.)
				cQuery	:=	"D2_FILIAL=='"+xFilial ("SD2")+"' .And. D2_DOC=='"+(cAliasSf2)->F2_DOC+"' .And. D2_SERIE=='"+(cAliasSf2)->F2_SERIE+"' .And. "
				cQuery	+=	"D2_CLIENTE=='"+(cAliasSf2)->F2_CLIENTE+"' .And. D2_LOJA=='"+(cAliasSf2)->F2_LOJA+"' .And. D2_COD>='"+MV_PAR03+"' .And. "
				cQuery	+=	"D2_COD<='"+MV_PAR04+"' "
				IndRegua (cAliasSd2, cArqSd2, IndexKey (),, cQuery, STR0009)	//"Selecionando Documentos ..."
		#IFDEF TOP
			EndIf
		#ENDIF
		//
		DbSelectArea (cAliasSd2)
			(cAliasSd2)->(DbGoTop ())
		//
		Do While !(cAliasSd2)->(Eof ())
			#IFNDEF TOP
				DbSelectArea ("SB1")
					SB1->(DbSetOrder (1))
				If !(SB1->(DbSeek (xFilial ("SB1")+(cAliasSd2)->D2_COD)) .And. (SB1->B1_GRUPO>=MV_PAR05) .And. (SB1->B1_GRUPO<=MV_PAR06))
					(cAliasSd2)->(DbSkip ())
					Loop
				EndIf
			#ENDIF
			//
			If !(TRB->(DbSeek ((cAliasSd2)->D2_COD+(cAliasSd2)->D2_CLIENTE+(cAliasSd2)->D2_LOJA)))
				RecLock ("TRB", .T.)
					TRB->TRB_CODCLI	:=	(cAliasSd2)->D2_CLIENTE
					TRB->TRB_LOJCLI	:=	(cAliasSd2)->D2_LOJA
					TRB->TRB_CODPRO	:=	(cAliasSd2)->D2_COD
					TRB->TRB_DESCCL	:=	cDescCli
					#IFDEF TOP
						TRB->TRB_DESCPR	:=	(cAliasSd2)->B1_DESC
					#ELSE
						TRB->TRB_DESCPR	:=	SB1->B1_DESC
					#ENDIF
			Else
				RecLock ("TRB", .F.)
			EndIf
					TRB->TRB_QUANT	+=	(cAliasSd2)->D2_QUANT
			MsUnLock ()
			//
			DbSelectArea (cAliasSd2)
			(cAliasSd2)->(DbSkip ())
		EndDo
		//���������������������������Ŀ
		//�Apago arquivo trabalho SD2.�
		//�����������������������������
		DbSelectArea (cAliasSd2)
		(cAliasSd2)->(DbCloseArea ())
		#IFNDEF TOP
			Ferase (cArqSd2+GetDBExtension ())
			Ferase (cArqSd2+OrdBagExt ())
		#ENDIF
		//
		DbSelectArea (cAliasSf2)
		(cAliasSf2)->(DbSkip ())
	EndDo
	//���������������������������Ŀ
	//�Apago arquivo trabalho SF2.�
	//�����������������������������
	DbSelectArea (cAliasSf2)
	(cAliasSf2)->(DbCloseArea ())
	#IFNDEF TOP
		Ferase (cArqSf2+GetDBExtension ())
		Ferase (cArqSf2+OrdBagExt ())
	#ENDIF
Return (aTrb)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �R934Lay   � Autor �Gustavo G. Rueda       � Data �03/01/2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta Layout de impressao.                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum.                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   |ExpA1 - Array contendo o layout a ser utilizado.            ���
�������������������������������������������������������������������������Ĵ��
���Uso       |MATR934                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R934Lay ()
	Local	aRet	:=	{}
	//	                   1         2         3         4         5         6         7         8
	//            12345678901234567890123456789012345678901234567890123456789012345678901234567890
	aAdd (aRet, STR0010)	//"Produto: ####################"
	aAdd (aRet, __PrtThinLine())
	aAdd (aRet, STR0011)	//"Clientes                                                              Quantidade"
	aAdd (aRet, STR0012)	//"############################################################### ################"
	//
Return (aRet)
