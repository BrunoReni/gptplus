#INCLUDE "PANELONLINE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RSPXPGL.CH"
#INCLUDE "MSGRAPHI.CH"

#DEFINE NUM_PICT "@E 999,999,999"
#DEFINE PER_PICT "@E 999.99"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � RSPPGOnl � Autor � Rogerio Ribeiro       � Data � 30/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao dos paineis on-line para modulo Rec. e Sele��o   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RSPPGOnl                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � NIL                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGARSP                                                    ���
�������������������������������������������������������������������������Ĵ��
���           ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � FNC  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�06/08/14�TQENRX�Incluido o fonte da 11 para a 12 e efetua-���
���            �        �      �da a limpeza.                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function RSPPGOnl(oPGOnline)
	Local aToolBar 	:= {}
	Local nTempo	:= SuperGetMV("MV_PGORFSH", .F., 60)//Tempo para atualizacao do painel
                                                                                   
	aToolBar:= {{"S4WB016N", "Help",	"{ || MsgInfo("+RspHelpPnl(1)+") }"}}
	PANELONLINE oPgOnLine ADDPANEL;
		TITLE STR0001; // "Indicativo de Vagas"
		DESCR STR0001; // "Indicativo de Vagas"
		TYPE 1;
		ONLOAD "RspPGOL001";
		REFRESH nTempo;
		TOOLBAR  aToolBar;	
		NAME	"RspPGOL001";
		PARAMETERS "RSPPG1"

	aToolBar:= {{"S4WB016N", "Help",	"{ || MsgInfo("+RspHelpPnl(2)+") }"}}
	PANELONLINE oPgOnLine ADDPANEL ;
		TITLE STR0002; // "Banco de Curr�culos"
		DESCR STR0002; // "Banco de Curr�culos"
		TYPE 2;
		ONLOAD "RspPGOL002";
		REFRESH nTempo;
		TOOLBAR aToolBar;	
		NAME "RspPGOL002";
		PARAMETERS "RSPPG2";
		DEFAULT 3

	aToolBar:= {{"S4WB016N", "Help",	"{ || MsgInfo("+RspHelpPnl(3)+") }"}}
	PANELONLINE oPgOnLine ADDPANEL;
		TITLE STR0003; // "Indicativo de Colaboradores"
		DESCR STR0003; // "Indicativo de Colaboradores"
		TYPE 1;
		ONLOAD "RspPGOL003";
		REFRESH nTempo;
		TOOLBAR aToolBar;
		NAME "RspPGOL003";
		PARAMETERS "RSPPG3";

Return


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � RspPGOL001 � Autor � Rogerio Ribeiro		  � Data � 30/01/07 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � 																���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 � RspPGOL001													���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum														���
���������������������������������������������������������������������������Ĵ��
���Retorno   � 																���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGARSP  			   										���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function RspPGOL001
	Local nAberto:= 0
	Local nRecrut:= 0
	Local cFilDe
	Local cFilAte

	Pergunte("RSPPG1", .F.)

	cFilDe	:= mv_par01
	cFilAte	:= mv_par02

	cQuery := "SELECT "
	cQuery += "		SUM(CASE WHEN (QS_NRVAGA - QS_VAGAFEC) > 0 THEN (QS_NRVAGA - QS_VAGAFEC) ELSE 0 END) AS QS_NRVAGA, "
	cQuery += "		SUM(QS_VAGAFEC) AS QS_VAGAFEC "
	cQuery += "FROM " 
	cQuery += "		" + RetSqlName("SQS") + " SQS "
	cQuery += "WHERE "
	cQuery += "		QS_FILIAL >= '" + cFilDe  + "' AND "
	cQuery += "		QS_FILIAL <= '" + cFilAte + "' AND "
	cQuery += "  	D_E_L_E_T_ = '' "
	
	dbUseArea(.T., 'TOPCONN', TCGENQRY(NIL, NIL, ChangeQuery(cQuery)), "QRYTMP", .T., .T.)
	dbSelectArea("QRYTMP")

	nAberto:= QRYTMP->QS_NRVAGA
	nRecrut:= QRYTMP->QS_VAGAFEC

	QRYTMP->(dbCloseArea())
                                                                                                        
Return {;
			{ STR0004, 	Transform(nAberto, NUM_PICT), CLR_BLACK, 	"{ || MsgInfo("+RspHelpPnl(4)+") }"},;	
			{ STR0005,	Transform(nRecrut, NUM_PICT), CLR_BLACK, 	"{ || MsgInfo("+RspHelpPnl(5)+") }"};	
		}


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � RspPGOL002 � Autor � Rogerio Ribeiro		  � Data � 30/01/07 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � 																���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 � RspPGOL002													���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum														���
���������������������������������������������������������������������������Ĵ��
���Retorno   � 																���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGARSP  			   										���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function RspPGOL002
	Local aRetorno	 
	Local aValores:= {}
	Local aEixoX:= {}
	Local aCodX:= {}
	
	Local nAtivos:= 0
	Local nTotal:= 0 
	Local cFilSQG:= xFilial("SQG")
	Local nPos

	Local cBlqCV	:= SuperGetMv("MV_BLQCV",,"1") 
	
	SX5->(dbSetOrder(1))
	SX5->(dbSeek(xFilial("SX5")+ "R3"))

	While (	SX5->(!EOF()) .AND.;
			SX5->X5_TABELA == "R3")
		AAdd(aEixoX, SX5->X5_DESCRI)
		AAdd(aCodX, TRIM(SX5->X5_CHAVE))
		
		SX5->(DBSkip())
	End While
	
	AAdd(aCodX, "")
	AAdd(aEixoX, "N�o Preenchida")

	aValores:= Array(Len(aEixoX))

	For nPos:= 1 to Len(aEixoX)
		aValores[nPos]:= {0}
	End For
	
	DbSelectArea("SQG")		
	SQG->(dbSeek(cFilSQG))

	While (	SQG->(!EOF()) .AND. SQG->QG_FILIAL == cFilSQG)
		IF (SQG->(Columnpos("QG_ACTRSP")) > 0 .and. SQG->QG_ACTRSP <> '1') .or. SQG->(Columnpos("QG_ACTRSP")) <= 0 //1- sem aceite e 2-com aceite
			IF cBlqCV == "2" .and. SQG->QG_ACEITE <> "2" ///BLOQUEAR O CV POR NAO ACEITE DO TERMO DE CONSENTIMENTO
				// 1=Sem aceite; 2=Aceite vigente gravado  
				SQG->(DBSkip())
			ELSE
				nPos:= AScan(aCodX, {|cCodigo| TRIM(SQG->QG_SITUAC) == cCodigo})
				
				aValores[nPos, 1]++
								
				SQG->(DBSkip())
			ENDIF
		else
			SQG->(DBSkip())
		ENDIF
	End While		
	
	aRetorno:=	{;
							GRP_BAR,;
							"{ || MsgInfo("+RspHelpPnl(6)+") }",;
							{STR0006},;
							aEixoX,;
							aValores;
						}

Return aRetorno                                                 


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � RspPGOL003 � Autor � Rogerio Ribeiro		  � Data � 30/01/07 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � 																���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 � RspPGOL003													���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum														���
���������������������������������������������������������������������������Ĵ��
���Retorno   � 																���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGARSP  			   										���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function RspPGOL003
	Local aRetorno	
	Local nDesligados:= 0
	Local nAdmitidos:= 0
	Local nTurnover:= 0
	Local cFilialDe 
	Local cFilialAte
	Local nMeses

	Pergunte("RSPPG3", .F.)	

	cFilialDe := MV_PAR01
	cFilialAte:= MV_PAR02
	nMeses	  := MV_PAR03

	nDesligados:= GetOutMonth(cFilialDe, cFilialAte)
	nAdmitidos:= GetInMonth(cFilialDe, cFilialAte)

   	nTurnover:= GetTurnoverValue(nMeses, cFilialDe, cFilialAte)

	aRetorno:={	{ STR0007, 	RTRIM(LTRIM(Transform(nDesligados, NUM_PICT))),		CLR_BLACK, "{ || MsgInfo("+RspHelpPnl(7)+") }" } ,;	
				{ STR0008, 	RTRIM(LTRIM(Transform(nAdmitidos , NUM_PICT))),  		CLR_BLACK, "{ || MsgInfo("+RspHelpPnl(8)+") }" } ,;
				{ STR0009,	RTRIM(LTRIM(Transform(nTurnover  , PER_PICT))) + "%",	CLR_BLACK, "{ || MsgInfo("+RspHelpPnl(9)+") }" } } 	
Return aRetorno


/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o	 � GetTurnoverValue � Autor � Rogerio Ribeiro	  � Data � 30/01/07	  ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o �																	  ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe	 � GetTurnoverValue(nMeses, cFilialDe, cFilialAte)					  ���
���������������������������������������������������������������������������������Ĵ��
���Parametros� nMeses, cFilialDe, cFilialAte									  ���
���������������������������������������������������������������������������������Ĵ��
���Retorno   � 																	  ���
���������������������������������������������������������������������������������Ĵ��
���Uso		 � SIGARSP  			   											  ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������*/
Static Function GetTurnoverValue(nMeses, cFilialDe, cFilialAte)
	Local nEntSai
	Local nEfMedio
	Local nTurnover

	nEntSai:= GetSumInOut(nMeses, cFilialDe, cFilialAte)
	nEfMedio:= GetAvgHeadCount(nMeses, cFilialDe, cFilialAte)
		  
	nTurnover:= ((nEntSai / 2) / nEfMedio) * 100
Return nTurnover


/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o	 � GetAvgHeadCount  � Autor � Rogerio Ribeiro	  � Data � 30/01/07	  ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o �																	  ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe	 � GetAvgHeadCount(nMeses, cFilialDe, cFilialAte)					  ���
���������������������������������������������������������������������������������Ĵ��
���Parametros� nMeses, cFilialDe, cFilialAte									  ���
���������������������������������������������������������������������������������Ĵ��
���Retorno   � 																	  ���
���������������������������������������������������������������������������������Ĵ��
���Uso		 � SIGARSP  			   											  ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������*/
Static Function GetAvgHeadCount(nMeses, cFilialDe, cFilialAte)
	Local nRetorno:= 0
	Local cQuery
	Local dDataLimite
	Local nContador

	For nContador:= 1 to nMeses
		dDataLimite:= LastDate(MonthSub(dDataBase, nContador))
	
		cQuery:= "SELECT "
		cQuery+= "	COUNT(*) AS QTD_EFETIVO "
		cQuery+= "FROM 
		cQuery+= "	" + RetSqlName("SRA") + " SRA "
		cQuery+= "WHERE "
		cQuery+= "	RA_ADMISSA <= '" + DTOS(dDataLimite) + "' AND "
		cQuery+= "	(LTRIM(RA_DEMISSA) = '' OR RA_DEMISSA > '" + DTOS(dDataLimite) + "') AND "
		cQuery+= "	RA_FILIAL >= '" + cFilialDe + "' AND "
		cQuery+= "	RA_FILIAL <= '" + cFilialAte + "' AND "
		cQuery+= "	D_E_L_E_T_ = ''"
		
		dbUseArea(.T., "TOPCONN", TCGENQRY(NIL, NIL, ChangeQuery(cQuery)), "TMPQRY", .F., .T.)	
		
		TCSetField("TMPQRY", "QTD_EFETIVO", "N", 5, 0)
		nRetorno+= TMPQRY->QTD_EFETIVO		
		TMPQRY->( dbCloseArea() )
	End For
	
	nRetorno:= nRetorno / nMeses
Return nRetorno


/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o	 � GetInMonth		� Autor � Rogerio Ribeiro	  � Data � 30/01/07	  ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o �																	  ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe	 � GetInMonth(cFilialDe, cFilialAte)								  ���
���������������������������������������������������������������������������������Ĵ��
���Parametros� cFilialDe, cFilialAte											  ���
���������������������������������������������������������������������������������Ĵ��
���Retorno   � 																	  ���
���������������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGARSP  			   											  ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������*/
Static Function GetInMonth(cFilialDe, cFilialAte) 
	Local dDataIni := FirstDate(dDataBase)
	Local dDataFim := dDataBase
	
	Local nRetorno:= GetInOutValue(dDataIni, dDataFim, .T., .F., cFilialDe, cFilialAte)
Return nRetorno


/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o	 � GetOutMonth		� Autor � Rogerio Ribeiro	  � Data � 30/01/07	  ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o �																	  ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe	 � GetOutMonth(cFilialDe, cFilialAte)								  ���
���������������������������������������������������������������������������������Ĵ��
���Parametros� cFilialDe, cFilialAte											  ���
���������������������������������������������������������������������������������Ĵ��
���Retorno   � 																	  ���
���������������������������������������������������������������������������������Ĵ��
���Uso		 � SIGARSP  			   											  ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������*/                                  
Static Function GetOutMonth(cFilialDe, cFilialAte)
	Local dDataIni := FirstDate(dDataBase)
	Local dDataFim := dDataBase
                      
	Local nRetorno:= GetInOutValue(dDataIni, dDataFim, .F., .T., cFilialDe, cFilialAte)
Return nRetorno


/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o	 � GetSumInOut		� Autor � Rogerio Ribeiro	  � Data � 30/01/07	  ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o �																	  ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe	 � GetSumInOut(nMeses, cFilialDe, cFilialAte)						  ���
���������������������������������������������������������������������������������Ĵ��
���Parametros� nMeses, cFilialDe, cFilialAte									  ���
���������������������������������������������������������������������������������Ĵ��
���Retorno   � 																	  ���
���������������������������������������������������������������������������������Ĵ��
���Uso		 � SIGARSP  			   											  ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������*/
Static Function GetSumInOut(nMeses, cFilialDe, cFilialAte)
	Local dDataIni := FirstDate( MonthSub(dDataBase, nMeses - 1) )
	Local dDataFim := dDataBase

	Local nRetorno:= GetInOutValue(dDataIni, dDataFim, .T., .T., cFilialDe, cFilialAte)	
Return nRetorno


/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun��o	 � GetInOutValue	� Autor � Rogerio Ribeiro	  � Data � 30/01/07	  ���
���������������������������������������������������������������������������������Ĵ��
���Descri��o �																	  ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe	 � GetInOutValue(dDataIni, dDataFim, lEntradas, lSaidas, cFilialDe,;  ���
���			 � 		cFilialAte)					 								  ���
���������������������������������������������������������������������������������Ĵ��
���Parametros� (dDataIni, dDataFim, lEntradas, lSaidas, cFilialDe, cFilialAte)	  ���
���������������������������������������������������������������������������������Ĵ��
���Retorno   � 																	  ���
���������������������������������������������������������������������������������Ĵ��
���Uso		 � SIGARSP  			   											  ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������*/
Static Function GetInOutValue(dDataIni, dDataFim, lEntradas, lSaidas, cFilialDe, cFilialAte)
	Local cQuery  
	Local nRetorno

	Default lEntradas:= .T.
	Default lSaidas:= .T.
		
	If !lEntradas .AND. !lSaidas
		Return 0
	EndIf

	cQuery:= "SELECT "
	cQuery+= "	COUNT(*) AS QTD_INOUT "
	cQuery+= "FROM "
	cQuery+= "	" + RetSqlName("SRA") + " SRA "
	cQuery+= "WHERE ("
	
	IF lEntradas 	
		cQuery+= "(RA_ADMISSA BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDataFim) + "') "	

		IF lSaidas
			cQuery+= "OR "
		EndIf	
	EndIf

	IF lSaidas
		cQuery+= "(RA_DEMISSA BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDataFim) + "') "
	EndIf
	
	cQuery+= ") AND "
	cQuery+= "	RA_FILIAL >= '" + cFilialDe + "' AND "
	cQuery+= "	RA_FILIAL <= '" + cFilialAte + "' AND "
	cQuery+= "	D_E_L_E_T_ = ''"
		
	dbUseArea(.T., "TOPCONN", TCGENQRY(NIL, NIL, ChangeQuery(cQuery)), "TMPQRY", .F., .T.)	
	TMPQRY->( dbGoTop() )	
		
	TCSetField("TMPQRY", "QTD_INOUT", "N", 5, 0)
	nRetorno:= TMPQRY->QTD_INOUT
	TMPQRY->( dbCloseArea() )
Return nRetorno


Function Turnover(cCodFilial, cCentroCusto, dData, nMeses)
	Local nEntSai
	Local nEfMedio
	Local nTurnover

	nEntSai:= GetSumInOut(nMeses, cFilialDe, cFilialAte)
	nEfMedio:= GetAvgHeadCount(nMeses, cFilialDe, cFilialAte)
		  
	nTurnover:= ((nEntSai / 2) / nEfMedio) * 100
Return nTurnover



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RspHelpPnl�Autor  �Joeudo Santana	     � Data �  09/04/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Apresenta Helps dos paineis do RSP                         ���
�������������������������������������������������������������������������͹��
���Uso       � PAINEL SIGARSP                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function RspHelpPnl(nPainel) 
Local cHelp

   Do Case
   		Case nPainel = 1 
   			cHelp := "'"+STR0010+"'" //"Neste painel s�o apresentados os indicadores de Vagas."
   		Case nPainel = 2
   			cHelp := "'"+STR0013+"'" //"Neste painel � apresentado um gr�fico indicando a situa��o do banco de curr�culos."
   		Case nPainel = 3
   			cHelp := "'"+STR0015+"'" //"Neste painel s�o apresentados os indicadores relacionados aos colaboradores."
   		Case nPainel = 4
   			cHelp := "'"+STR0011+"'" //"Vagas em aberto"
   		Case nPainel = 5
   			cHelp := "'"+STR0012+"'" //"Vagas recrutadas"   
   		Case nPainel = 6
   			cHelp := "'"+STR0014+"'" //"Exibe a quantidade de curr�culos, por situa��o, de acordo com os par�metros informados."   
   		Case nPainel = 7
   			cHelp := "'"+STR0016+"'" //"Desligados no m�s"
   		Case nPainel = 8
   			cHelp := "'"+STR0017+"'" //"Admitidos no m�s"
   		Case nPainel = 9
   			cHelp := "'"+STR0018+"'" //"Turnover"
     EndCase			

Return cHelp
