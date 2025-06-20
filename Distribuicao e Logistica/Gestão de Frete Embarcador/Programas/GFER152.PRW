#INCLUDE "PROTHEUS.CH"


/*---------------------------------------------------------
{Protheus.doc} GFER152
	
@author siegklenes.beulke
@since 23/07/2013
@version 1.0

@description
Relat�rio de Ocupa��o de Ve�culos por Filial,
Mostra o aproveitamento da capacidade dos ve�culos por Filial pela carga embarcada

-------------------------------------------------------------*/
Function GFER152()
	Local oReport
	Local aArea := GetArea()

	Private cTabOc // Registros referente a ocupa��o
	Private cTabTotOc // registros referentes a totalizadores
	Private cAliasOc // Registros referente a consultaSQL

	If TRepInUse()
		//+------------------------------------------------------------------------+
		//| "Interface de impressao                                                  |
		//+------------------------------------------------------------------------+
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf
	
	RestArea(aArea)
	GFEDelTab(cTabOc)	
	GFEDelTab(cTabTotOc)
	If Select(cAliasOc) > 0
		(cAliasOc)->(dbCloseArea())
	endif 	
Return Nil

//--------------------------------------------------------------------------------------------------------
/*/ {Protheus.doc}  ReportDef
A funcao estatica ReportDef devera ser criada para todos os relatorios que poderao ser agendados pelo usuario. 

@author siegklenes.beulke
@version 1.0
@since 23/07/2013
@return oReport Objeto do Relatorio.

/*/
//--------------------------------------------------------------------------------------------------------

Static Function ReportDef()
	Local oReport, oSection, oSection2, cTotal := "Total"
	
	//+--------------------------------------------------------------------------+
	//| "Criacao do componente de impressao                                      | "
	//| "                                                                        | "
	//| "TReport():New                                                           | "
	//| "ExpC1 : Nome do relatorio                                               | "
	//| "ExpC2 : Titulo                                                          | "
	//| "ExpC3 : Pergunte                                                        | "
	//| "ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  | "
	//| "ExpC5 : Descricao                                                       | "
	//| "                                                                        | "
	//+--------------------------------------------------------------------------+
	oReport := TReport():New("GFER152","Relat�rio de Ocupa��o de Ve�culo por Filial","GFER152", {|oReport| ReportPrint(oReport)},"Emite relat�rio de Ocupa��o de Ve�culos por Filial conforme os par�metros informados."/*Descricao do relat�rio*/)
	oReport:SetLandscape(.T.)   //Define a orienta��o de p�gina do relat�rio como paisagem  ou retrato. .F.=Retrato; .T.=Paisagem
	oReport:SetTotalInLine(.T.) //Define se os totalizadores ser�o impressos em linha ou coluna 
	oReport:HideParamPage() //Oculta p�gina de parametros
	If !Empty(oReport:uParam)
	    Pergunte(oReport:uParam,.F.)  
	EndIf
	oSection := TRSection():New(oReport,"Ocupa��o de Ve�culos",{"(cAliasOc)"},{"Ocupa��o de Ve�culos por Filial"}/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	//Exemplo utilizando a tabela de clientes.
	//oSection := TRSection():New(oReport,"Clientes",{"SA1"})
	oSection:SetTotalInLine(.T.)  //Define se os totalizadores ser�o impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//+------------------------------------------------------------------------+
	//|Criacao da celulas da secao do relatorio                                |
	//|                                                                        |
	//|TRCell():New                                                            |
	//|ExpO1 : Objeto TSection que a secao pertence                            |
	//|ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              |
	//|ExpC3 : Nome da tabela de referencia da celula                          |
	//|ExpC4 : Titulo da celula                                                |
	//|        Default : X3Titulo()                                            |
	//|ExpC5 : Picture                                                         |
	//|        Default : X3_PICTURE                                            |
	//|ExpC6 : Tamanho                                                         |
	//|        Default : X3_TAMANHO                                            |
	//|ExpL7 : Informe se o tamanho esta em pixel                              |
	//|        Default : False                                                 |
	//|ExpB8 : Bloco de c�digo para impressao.                                 |
	//|        Default : ExpC2                                                 |
	//|                                                                        |
	//+------------------------------------------------------------------------+
	//	GetSx3Inf @return aRetorno Array {cTitulo,cCbox,cPicture}
	//TRCell():New(oSection,/*X3_CAMPO*/,/*Tabela*/,/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	
	TRCell():New(oSection,"(cAliasOc)->GWN_FILIAL","(cAliasOc)","Filial",GetSx3Inf("GWN_FILIAL")[3],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"NOMEFILIAL","(cAliasOc)","Nome","@!",/*Tamanho*/,/*lPixel*/,{||FWFilialName(,(cAliasOc)->GWN_FILIAL,)}/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"(cAliasOc)->GWN_TOTROM", "(cAliasOc)", "Qtde Romaneios",,,,)
	
	TRCell():New(oSection,"(cAliasOc)->GU8_CARGUT", "(cAliasOc)", "Capacidade Total Peso",GetSx3Inf("GU8_CARGUT")[3] , , )
	TRCell():New(oSection,"(cAliasOc)->GW8_PESOR","(cAliasOc)","Peso Bruto Embarcado",GetSx3Inf("GW8_PESOR")[3],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"LOTACPESO","(cAliasOc)","% Lota��o Peso","@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,{||((cAliasOc)->GW8_PESOR/(cAliasOc)->GU8_CARGUT)*100}/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"PESOBRUMED","(cAliasOc)","Peso Bruto M�dio","@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,{||(cAliasOc)->GW8_PESOR/(cAliasOc)->GWN_TOTROM}/*{|| code-block de impressao }*/)
	
	TRCell():New(oSection,"(cAliasOc)->GU8_VOLUT", "(cAliasOc)","Capacidade Total Volume",GetSx3Inf("GU8_VOLUT")[3] , , )
	TRCell():New(oSection,"(cAliasOc)->GW8_VOLUME","(cAliasOc)","Volume Embarcado",GetSx3Inf("GW8_VOLUME")[3],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"LOTACVOLU","(cAliasOc)","% Ocupa��o Volume","@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,{||((cAliasOc)->GW8_VOLUME/(cAliasOc)->GU8_VOLUT)*100}/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"VOLUMED","(cAliasOc)","Volume M�dio","@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,{||(cAliasOc)->GW8_VOLUME/(cAliasOc)->GWN_TOTROM}/*{|| code-block de impressao }*/)
	
	TRCell():New(oSection,"(cAliasOc)->GW1_QTVOL","(cAliasOc)",GetSx3Inf("GW1_QTVOL")[1],GetSx3Inf("GW1_QTVOL")[3],/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"VOLUMED","(cAliasOc)","Qtde Vol M�dio","@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,{||(cAliasOc)->GW1_QTVOL/(cAliasOc)->GWN_TOTROM}/*{|| code-block de impressao }*/)
	
	oSection2 := TRSection():New(oSection,"Totalizadores",{"(cTabTotOc)"}) //  //"Totalizadores"
	oSection2:SetTotalInLine(.T.)
	oSection2:SetHeaderSection(.T.)
	TRCell():New(oSection2,"cTotal","","Totalizadores",,2,,{||cTotal})
	TRCell():New(oSection2,"cTotal","","",,2)
	TRCell():New(oSection2,"(cTabTotOc)->GWN_TOTROM"	, "(cTabTotOc)"	, "", , , , )
	
	TRCell():New(oSection2,"(cTabTotOc)->PESOCAPAC"	, "(cTabTotOc)"	, "", , , , )
	TRCell():New(oSection2,"(cTabTotOc)->GW8_PESOR"	, "(cTabTotOc)"	, "", , , , )
	TRCell():New(oSection2,"(cTabTotOc)->LOTACPESO"	, "(cTabTotOc)"	, "", , , , )
	TRCell():New(oSection2,"(cTabTotOc)->PESOBRUMED"	, "(cTabTotOc)"	, "", , , , )
	
	TRCell():New(oSection2,"(cTabTotOc)->VOLUCAPAC"	, "(cTabTotOc)"	, "", , , , )
	TRCell():New(oSection2,"(cTabTotOc)->GW8_VOLUME"	, "(cTabTotOc)"	, "", , , , )
	TRCell():New(oSection2,"(cTabTotOc)->LOTACVOLU"	, "(cTabTotOc)"	, "", , , , )
	TRCell():New(oSection2,"(cTabTotOc)->VOLUMED"	 	, "(cTabTotOc)"	, "", , , , )
	
	TRCell():New(oSection2,"(cTabTotOc)->GW1_QTVOL"	, "(cTabTotOc)"	, "", , , , )
	TRCell():New(oSection2,"(cTabTotOc)->QTVOLMED"	, "(cTabTotOc)"	, "", , , , )
	
Return oReport

//--------------------------------------------------------------------------------------------------------
/*/ {Protheus.doc}  ReportPrint
A funcao estatica ReportDef devera ser criada para todos os relatorios que poderao ser agendados pelo usuario.  

@param oReport Objeto do relat�rio  
@author Siegklenes.beulke
@version 1.0
@since 22/07/2013
@return Nil
/*/
//--------------------------------------------------------------------------------------------------------
Static Function ReportPrint(oReport)
	Local oSection  := oReport:Section(1)
	Local oSection2  := oReport:Section(1):Section(1)

	Private cTabOc 		// Registros referente a ocupa��o
	Private cTabTotOc 	// registros referentes a totalizadores
	Private cAliasOc 	// Registros referente a consultaSQL

	CarregaDados()
	
	If !IsBlind()
		oReport:SetMeter((cAliasOc)->(LastRec()))
	EndIf
	oSection:Init()
	RecLock((cTabTotOc), .T.)
	While !oReport:Cancel() .AND. !(cAliasOc)->( Eof() )
		(cTabTotOc)->GWN_TOTROM +=  (cAliasOc)->GWN_TOTROM
		
		(cTabTotOc)->PESOCAPAC +=  (cAliasOc)->GU8_CARGUT
		(cTabTotOc)->GW8_PESOR +=  (cAliasOc)->GW8_PESOR
		
		(cTabTotOc)->VOLUCAPAC +=  (cAliasOc)->GU8_VOLUT
		(cTabTotOc)->GW8_VOLUME +=  (cAliasOc)->GW8_VOLUME
		
		(cTabTotOc)->GW1_QTVOL +=  (cAliasOc)->GW1_QTVOL
		oSection:PrintLine()
		(cAliasOc)->(dbSkip())
		
	EndDo
	(cTabTotOc)->LOTACPESO := ((cTabTotOc)->GW8_PESOR/(cTabTotOc)->PESOCAPAC)*100
	(cTabTotOc)->PESOBRUMED := ((cTabTotOc)->GW8_PESOR/(cTabTotOc)->GWN_TOTROM)
	(cTabTotOc)->LOTACVOLU := ((cTabTotOc)->GW8_VOLUME/(cTabTotOc)->VOLUCAPAC)*100
	(cTabTotOc)->VOLUMED := ((cTabTotOc)->GW8_VOLUME/(cTabTotOc)->GWN_TOTROM)
	(cTabTotOc)->QTVOLMED := ((cTabTotOc)->GW1_QTVOL/(cTabTotOc)->GWN_TOTROM)
	MsUnlock((cTabTotOc))
	
	oSection2:Init()
	oSection2:PrintLine()
	oSection2:Finish()
		
	oSection:Finish()
Return Nil

//--------------------------------------------------------------------------------------------------------
/*/ {Protheus.doc}  CarregaDados
A funcao estatica CarregaDados Alimentam as tabelas tempor�rias cTabOc e cTabTotOc 
Faz a leitura do Pergunte GFER150
@author siegklenes.beulke
@version 1.0
@since 22/07/2013
@return Nil

/*/
//--------------------------------------------------------------------------------------------------------

Static Function CarregaDados()
	Local aArea := GetArea(), cQuery := ""
	Local cFltrGWN := "", cFltrGU3 := "" 
	Local cFltrOpen :=''
	CriaTabTemp()
	
	/*
		01 Filial de
		02 Filial ate
		03 Data Criacao de
		04 Data Criacao ate
		05 Data Liberacao de
		06 Data Liberacao ate
		07 Tranportadora Romaneio de
		08 Tranportadora Romaneio ate
		09 Tipo Transportadora Romaneio
		10 Tipo Veiculo de
		11 Tipo Veiculo ate
		12 Classificacao Frete de
		13 Classificacao Frete ate
	*/ 
	
	cFltrGWN += " AND GWN_FILIAL >='" + MV_PAR01 + "' AND GWN_FILIAL <='" + MV_PAR02 + "' "
	
	cFltrGWN += " AND GWN_DTIMPL >='" + DTOS(MV_PAR03) + "' AND GWN_DTIMPL <='" + DTOS(MV_PAR04) + "' "
	
	cFltrGWN += " AND GWN_DTSAI >='" + DTOS(MV_PAR05) + "' AND GWN_DTSAI <='" + DTOS(MV_PAR06) + "' "
	
	cFltrGWN += " AND GWN_CDTRP >='" + MV_PAR07 + "' AND GWN_CDTRP <='" + MV_PAR08 + "' "
	
	cFltrOpen += " AND GWN_FILIAL >='" + MV_PAR01 + "' AND GWN_FILIAL <='" + MV_PAR02 + "' "
	
	cFltrOpen += " AND GWN_DTIMPL >='" + DTOS(MV_PAR03) + "' AND GWN_DTIMPL <='" + DTOS(MV_PAR04) + "' "
	
	cFltrOpen += " AND GWN_DTSAI >='" + DTOS(MV_PAR05) + "' AND GWN_DTSAI <='" + DTOS(MV_PAR06) + "' "
	
	cFltrOpen += " AND GWN_CDTRP >='" + MV_PAR07 + "' AND GWN_CDTRP <='" + MV_PAR08 + "' "
	
	Do Case
		Case MV_PAR09 == 1
			cFltrGU3 += " AND GU3_AUTON IN('1','2') "
		Case MV_PAR09 == 2
			cFltrGU3 += " AND GU3_AUTON <>'1' "
		Case MV_PAR09 == 3
			cFltrGU3 += " AND GU3_AUTON ='1' "
	EndCase
	
	cFltrGWN += " AND GWN_CDTPVC >='" + MV_PAR10 + "' AND GWN_CDTPVC <='" + MV_PAR11 + "' "
	cFltrGWN += " AND GWN_CDCLFR >='" + MV_PAR12 + "' AND GWN_CDCLFR <='" + MV_PAR13 + "' "
	
	cAliasOc := GetNextAlias()
	
	cQuery += "SELECT	"
	cQuery += "	GWN_FILIAL," 
	cQuery += "		(SELECT	COUNT(GWN_NRROM)"
	cQuery += "		   FROM	" + RetSQLName("GWN") + ""
	cQuery += "		  INNER JOIN " + RetSQLName("GU3") + ""
	cQuery += "		     ON GU3_CDEMIT = GWN_CDTRP" 
	cQuery += "		  WHERE	" + RetSQLName("GU3") + ".D_E_L_E_T_ = ' ' AND " + RetSQLName("GWN") + ".D_E_L_E_T_ = ' '"
	cQuery += "		    AND GWN_FILIAL = GWN.GWN_FILIAL" + cFltrGWN + cFltrGU3
	cQuery += "		) GWN_TOTROM,"
	cQuery += "		SOMAPESO.GU8_CARGUT," 
	cQuery += "		ITENS.GW8_PESOR, "
	cQuery += "		SOMAPESO.GU8_VOLUT,"
	cQuery += "		ITENS.GW8_VOLUME,"
	cQuery += "		(SELECT	SUM(GW1_QTVOL)" 
	cQuery += "			FROM " + RetSQLName("GW1") + ""
	cQuery += "			INNER JOIN " + RetSQLName("GWN") + ""
	If GFXCP1212210('GW1_FILROM')
		cQuery += "		ON GWN_FILIAL = GW1_FILROM"
	Else
		cQuery += "		ON GWN_FILIAL = GW1_FILIAL"
	EndIf
	cQuery += "			AND GWN_NRROM = GW1_NRROM"
	cQuery += "			INNER JOIN " + RetSQLName("GU3") + ""
	cQuery += "			ON GU3_CDEMIT = GWN_CDTRP" 
	cQuery += "			WHERE " + RetSQLName("GW1") + ".D_E_L_E_T_ = ' ' "
	cQuery += "			AND " + RetSQLName("GU3") + ".D_E_L_E_T_ = ' '"
	cQuery += "			AND " + RetSQLName("GWN") + ".D_E_L_E_T_ = ' '"
	If GFXCP1212210('GW1_FILROM')
		cQuery += "		AND GW1_FILROM = GWN.GWN_FILIAL"
	Else
		cQuery += "		AND GW1_FILIAL = GWN.GWN_FILIAL"
	EndIf
	cQuery += 			cFltrGWN + cFltrGU3
	cQuery += "		) GW1_QTVOL"
	cQuery += "	FROM	(SELECT"	
	cQuery += "				GW1.GW1_FILIAL," 
	cQuery += "				GW1.GW1_FILROM," 
	cQuery += "				SUM(GW8.GW8_PESOR) GW8_PESOR," 
	cQuery += "				SUM(GW8.GW8_VOLUME) GW8_VOLUME"
	cQuery += "				FROM	" + RetSQLName("GW1") + " GW1 "
	cQuery += "				INNER JOIN " + RetSQLName("GW8") + " GW8" 
	cQuery += "				ON GW1.GW1_FILIAL = GW8.GW8_FILIAL" 
	cQuery += "				AND GW1.GW1_CDTPDC = GW8.GW8_CDTPDC"  
	cQuery += "				AND GW1.GW1_EMISDC = GW8.GW8_EMISDC "
	cQuery += "				AND GW1.GW1_SERDC = GW8.GW8_SERDC  "
	cQuery += "				AND GW1.GW1_NRDC = GW8.GW8_NRDC"
	cQuery += "				INNER JOIN " + RetSQLName("GWN")
	If GFXCP1212210('GW1_FILROM')
		cQuery += "			ON GWN_FILIAL = GW1_FILROM"
	Else
		cQuery += "			ON GWN_FILIAL = GW1_FILIAL"
	EndIf
	cQuery += "				AND GWN_NRROM = GW1_NRROM"
	cQuery += "				INNER JOIN " + RetSQLName("GU3")
	cQuery += "				ON GU3_CDEMIT = GWN_CDTRP" 
	cQuery += "				WHERE	GW1.D_E_L_E_T_ = ' ' AND GW8.D_E_L_E_T_ = ' '" 
	cQuery += "				AND " + RetSQLName("GWN") + ".D_E_L_E_T_ = ' ' AND " + RetSQLName("GU3") + ".D_E_L_E_T_ = ' ' " +  cFltrGWN + cFltrGU3
	cQuery += "				GROUP BY GW1.GW1_FILIAL, GW1.GW1_FILROM"
	cQuery += "			) ITENS"
	cQuery += "			INNER JOIN"
	cQuery += "			(SELECT "
	cQuery += "				GWN_FILIAL FILIAL,"
	cQuery += "				SUM(CASE WHEN (	CASE WHEN GU8_CARGUT = 0" 
	cQuery += "									THEN GV3.GV3_CARGUT "
	cQuery += "									ELSE GU8_CARGUT "
	cQuery += "			 						END) IS NULL "
	cQuery += "						  THEN GV3ROMAN.GV3_CARGUT"
	cQuery += "						  ELSE (	CASE WHEN GU8_CARGUT = 0" 
	cQuery += "									THEN GV3.GV3_CARGUT "
	cQuery += "									ELSE GU8_CARGUT "
	cQuery += "									END) "
	cQuery += "						  END) GU8_CARGUT,"
	cQuery += "				SUM(CASE WHEN (	CASE WHEN GU8_VOLUT = 0"
	cQuery += "									THEN GV3.GV3_VOLUT "
	cQuery += "									ELSE GU8_VOLUT "
	cQuery += "									END) IS NULL"
	cQuery += "						  THEN GV3ROMAN.GV3_VOLUT"
	cQuery += "						  ELSE (	CASE WHEN GU8_VOLUT = 0"
	cQuery += "						  			THEN GV3.GV3_VOLUT "
	cQuery += "									ELSE GU8_VOLUT "
	cQuery += "						  			END) "
	cQuery += "						  END) GU8_VOLUT"
	If TCGETDB() = 'OPENEDGE'		
		cQuery += "				FROM " + RetSQLName("GU8") + " GU8," + RetSQLName("GWN") + " GWN,"  + RetSQLName("GV3") + " GV3ROMAN,"  + RetSQLName("GU3") + " GU3"				 
		cQuery += "				INNER JOIN " + RetSQLName("GV3") + " GV3 ON (GU8_CDTPVC = GV3.GV3_CDTPVC OR GU8_CDTPVC IS NULL ) " 
	    cQuery += " 			WHERE  ( GU8.GU8_PLACA(+) = GWN.GWN_PLACAD "
	    cQuery += "          OR GU8.GU8_PLACA (+) = GWN.GWN_PLACAM "
	    cQuery += "          OR GU8.GU8_PLACA (+) = GWN.GWN_PLACAT ) "
	    cQuery += "          AND ( GV3ROMAN.GV3_CDTPVC (+) = GWN.GWN_CDTPVC ) "
	    cQuery += "		   AND ( GU3.GU3_CDEMIT = GWN.GWN_CDTRP) "
		cQuery += "          AND ( GU8.D_E_L_E_T_ = ' '  OR  GU8.D_E_L_E_T_ IS NULL)"
	Else
		cQuery += "				FROM " + RetSQLName("GU8") + " GU8"
		cQuery += "				INNER JOIN " + RetSQLName("GV3") + " GV3 ON GU8_CDTPVC = GV3_CDTPVC"
		cQuery += "				RIGHT OUTER JOIN " + RetSQLName("GWN") + "  GWN ON ( (GWN_PLACAD = GU8_PLACA OR GWN_PLACAM = GU8_PLACA OR GWN_PLACAT = GU8_PLACA))"
		cQuery += "				LEFT JOIN " + RetSQLName("GV3") + " GV3ROMAN ON GV3ROMAN.GV3_CDTPVC = GWN_CDTPVC"
		cQuery += "				LEFT JOIN " + RetSQLName("GU3")+ " GU3 ON GU3_CDEMIT = GWN_CDTRP"  
		cQuery += "				WHERE (GU8.D_E_L_E_T_ = ' ' OR GU8.D_E_L_E_T_ IS NULL) " 
	EndIf
	cQuery += "				AND (GV3.D_E_L_E_T_ = ' ' OR GV3.D_E_L_E_T_ IS NULL)  "
	cQuery += "				AND (GWN.D_E_L_E_T_ = ' ' OR GWN.D_E_L_E_T_ IS NULL)"  
	cQuery += "				AND (GV3ROMAN.D_E_L_E_T_ = ' ' OR GV3ROMAN.D_E_L_E_T_ IS NULL)" + cFltrGWN + cFltrGU3
	cQuery += "				GROUP BY GWN_FILIAL"
	cQuery += "			) SOMAPESO" 
	cQuery += "			ON SOMAPESO.FILIAL = ITENS.GW1_FILIAL"  
	cQuery += "			INNER JOIN " + RetSQLName("GWN") + " GWN" 
	If GFXCP1212210('GW1_FILROM')
		cQuery += "		ON GWN.GWN_FILIAL = ITENS.GW1_FILROM"
	Else
		cQuery += "		ON GWN.GWN_FILIAL = ITENS.GW1_FILIAL"
	EndIf
	cQuery += "			INNER JOIN " + RetSQLName("GU3") + " GU3"
	cQuery += "			ON GU3.GU3_CDEMIT = GWN.GWN_CDTRP" 
	If TCGETDB() = 'OPENEDGE'
		cQuery += "WHERE     GWN.D_E_L_E_T_ = ' ' AND GU3.D_E_L_E_T_ = ' '" + cFltrOpen
	Else 
		cQuery += "WHERE     GWN.D_E_L_E_T_ = ' ' AND GU3.D_E_L_E_T_ = ' '" + cFltrGWN + cFltrGU3
	EndIf
	cQuery += "GROUP BY GWN_FILIAL, SOMAPESO.GU8_CARGUT, ITENS.GW8_PESOR, SOMAPESO.GU8_VOLUT, ITENS.GW8_VOLUME"
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasOc, .F., .T.)
	dbSelectArea((cAliasOc))
	(cAliasOc)->( dbGoTop() )
	
	RestArea(aArea)
Return

//--------------------------------------------------------------------------------------------------------
/*/ {Protheus.doc}  CriaTabTemp
A funcao estatica CriaTabTemp Cria a struct dos dados do relat�rio e cria as tabelas tempor�rias, privadas em GFER152() 

@author siegklenes.beulke
@version 1.0
@since 22/07/2013
@return {aStruOpTot} Array com Struct dos campos

/*/
//--------------------------------------------------------------------------------------------------------

Static Function CriaTabTemp()
	Local  aStruOpTot
	
	aStruOpTot :=	{	{"GWN_TOTROM"	,"N",9,0},; // QUANTIDADE ROMANEIOS
						{"PESOCAPAC"	,"N",TamSX3("GWI_VLFRET"	)[1]+4,TamSX3("GWI_VLFRET" )[2]},; // CAPACIDADE PESO VE�CULOS OU VE�CULO
						{"GW8_PESOR"	,"N",TamSX3("GW8_PESOR" 	)[1]+4,TamSX3("GW8_PESOR" )[2]},; // PESO EMBARCADO
						{"LOTACPESO"	,"N",TamSX3("GWI_VLFRET" 	)[1]+4,2},; // LOTA��O DO PESO
						{"PESOBRUMED"	,"N",TamSX3("GWI_VLFRET" 	)[1]+4,2},; // PESO BRUTO M�DIO
						{"VOLUCAPAC"	,"N",TamSX3("GWI_VLFRET" 	)[1]+4,TamSX3("GWI_VLFRET" )[2]},; // CAPACIDADE VOLUME VE�CULOS OU VE�CULO
						{"GW8_VOLUME"	,"N",TamSX3("GW8_VOLUME" 	)[1]+4,TamSX3("GW8_VOLUME" )[2]},; // VOLUME EMBARCADO
						{"LOTACVOLU"	,"N",TamSX3("GWI_VLFRET" 	)[1]+4,2},; // LOTA��O DO PESO
						{"VOLUMED"		,"N",TamSX3("GWI_VLFRET" 	)[1]+4,2},; // VOLUME M�DIO
						{"GW1_QTVOL"	,"N",TamSX3("GW1_QTVOL" 	)[1]+4,TamSX3("GW1_QTVOL" )[2]},;
						{"QTVOLMED"		,"N",TamSX3("GW1_QTVOL" 	)[1]+4,2};
					}
	
	cTabTotOc :=  GFECriaTab({aStruOpTot,{"GWN_TOTROM"}})
Return {aStruOpTot}


/*/{Protheus.doc} GetSx3Inf
	
@author siegklenes.beulke
@since 16/07/2013
@version 1.0

@param cCampo, character, Campo  do Banco de dados 
@param aRetorno, array, Opcional, Informa��es de Retorno caso n�o encontre o Campo

@description

Fun��o que busca no sx3 as informa��es de titulo,cbox,picture e descri��o do campo
e retorna um array nessa ordem, ou caso n�o encontre o campo, retorna o segundo parametro

@example

GetSx3Inf("GW1_FILIAL") Retorno {"Filial","","@!","Filial"}
GetSx3Inf("GW1_FILI",{"Fila","1=Sim;2=Nao","","Fila de espera"})Retorno {"Fila","1=Sim;2=Nao","","Fila de espera"} 

@return aArray:={X3Titulo, X3Cbox,X3Picture,X3DESCRIC}
/*/

Static Function GetSx3Inf(cCampo,aRetorno)
Local nCont := 1
Local aArea := GetArea("SX3")
Default aRetorno := {"","","",""}
	For nCont := 1 to 4-Len(aRetorno)
		aAdd(aRetorno,"")
	Next
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek( cCampo )   
		aRetorno[1] := X3Titulo()
		aRetorno[2] := X3Cbox()
		aRetorno[3] := X3Picture()
		aRetorno[4] := X3DESCRIC()
	EndIf
	RestArea(aArea)
Return aRetorno
