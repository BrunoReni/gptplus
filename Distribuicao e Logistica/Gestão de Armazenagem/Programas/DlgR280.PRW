#Include 'FIVEWIN.CH'
#Include 'DLGR280.CH'
/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    � DLGR280 � Autor � Flavio Luiz Vicco      矰ata  �20/06/2006潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矷ndicadores de Produtividade - Desempenho por Atividade     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � SIGAWMS                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
/*/
Function DLGR280()
Local oReport

If SuperGetMv("MV_WMSNEW",.F.,.F.)
	Return WMSR280()
EndIf

If FindFunction("TRepInUse") .And. TRepInUse()
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//矷nterface de impressao                                                  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	oReport:= ReportDef()
	oReport:PrintDialog()
Else
	DLGR280R3()
EndIf
Return NIL
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  � ReportDef矨utor  矲lavio Luiz Vicco      矰ata  �20/06/2006潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矷ndicadores de Produtividade - Desempenho por Atividade     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� nExp01: nReg = Registro posicionado do SC3 apartir Browse  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   � oExpO1: Objeto do relatorio                                潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function ReportDef()
Local cAliasNew := "SDB"
Local cTitle    := OemToAnsi(STR0005) //'Indicadores de Produtividade'
Local oReport 
Local oSection1
Local oSection2
Local oSection3
Local oSection4
dbSelectArea(cAliasNew)
dbSetOrder(1)
#IFDEF TOP
	cAliasNew := GetNextAlias()
#ENDIF
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矯riacao do componente de impressao                                      �
//�                                                                        �
//砊Report():New                                                           �
//矱xpC1 : Nome do relatorio                                               �
//矱xpC2 : Titulo                                                          �
//矱xpC3 : Pergunte                                                        �
//矱xpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//矱xpC5 : Descricao                                                       �
//�                                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oReport := TReport():New("DLGR280",cTitle,"DLR280",{|oReport| ReportPrint(oReport,cAliasNew)},STR0001) //'Relatorio de todos os Movimentos de Distribuicao cadastrados no armazem com as informacoes'
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Variaveis utilizadas como parametros p/filtrar as ordens de servico    �
//媚哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇
//� mv_par01	// Armazem       De  ?                                     �
//� mv_par02	//               Ate ?                                     �
//� mv_par03	// Servico       De  ?                                     �
//� mv_par04	//               Ate ?                                     �
//� mv_par05	// Tarefa        De  ?                                     �
//� mv_par06	//               Ate ?                                     �
//� mv_par07	// Atividade     De  ?                                     �
//� mv_par08	//               Ate ?                                     �
//� mv_par09	// Analitico/Sintetic? 1-Analitico                         �
//�                                    2-Sintetico                         �
//� mv_par10	// Indicador         ? 1-Recurso Humano                    �
//�                                    2-Recurso Fisico                    �
//�                                    3-Unitizador                        �
//� mv_par11	// Indicador     De  ?                                     �
//� mv_par12	//               Ate ?                                     �
//� mv_par13	// Refer.Cobranca    ?                                     �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Pergunte(oReport:uParam,.F.)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矯riacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//砊RSection():New                                                         �
//矱xpO1 : Objeto TReport que a secao pertence                             �
//矱xpC2 : Descricao da se鏰o                                              �
//矱xpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se玢o.                   �
//矱xpA4 : Array com as Ordens do relat髍io                                �
//矱xpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//矱xpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矯riacao da celulas da secao do relatorio                                �
//�                                                                        �
//砊RCell():New                                                            �
//矱xpO1 : Objeto TSection que a secao pertence                            �
//矱xpC2 : Nome da celula do relat髍io. O SX3 ser� consultado              �
//矱xpC3 : Nome da tabela de referencia da celula                          �
//矱xpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//矱xpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//矱xpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//矱xpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//矱xpB8 : Bloco de c骴igo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Sessao 1 - Armazem                                           �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oSection1:=TRSection():New(oReport,STR0020,{"SDB"},/*aOrdem*/) //"Movimentos por endereco"
oSection1:SetLineStyle()
TRCell():New(oSection1,"DB_LOCAL","SDB") //,,,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Sessao 2 - Servico / Tarefa / Atividade                      �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oSection2:=TRSection():New(oSection1,STR0020+"-"+STR0021,{"SDB"},/*aOrdem*/) //"Movimentos por endereco"###"Servico/Tarefa/Atividade"
oSection2:SetLineStyle()
TRCell():New(oSection2,"DSERVIC","",STR0024,,30,,{||(cAliasNew)->DB_SERVIC+" - "+TABELA("L4",(cAliasNew)->DB_SERVIC,.F.)}) //"Servico"
TRCell():New(oSection2,"DTAREFA","",STR0025,,30,,{||(cAliasNew)->DB_TAREFA+" - "+TABELA("L2",(cAliasNew)->DB_TAREFA,.F.)}) //"Tarefa"
TRCell():New(oSection2,"DATIVID","",STR0026,,30,,{||(cAliasNew)->DB_ATIVID+" - "+TABELA("L3",(cAliasNew)->DB_ATIVID,.F.)}) //"Atividade"
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Sessao 3 - Recurso Humano / Fisico / Unitizador              �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oSection3:=TRSection():New(oSection2,STR0020+"-"+STR0022,{"SDB"},/*aOrdem*/) //"Movimentos por endereco"###"Recurso Humano/Fisico/Unitizador"
oSection3:SetLineStyle()
TRCell():New(oSection3,"INDICADOR","",STR0027,,30)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Sessao 4 - Analitico + Totais                                �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
oSection4:=TRSection():New(oSection3,STR0020+"-"+STR0023,{"SDB"},/*aOrdem*/) //"Movimentos por endereco"###"Analitico/Totais"
oSection4:SetHeaderPage()
TRCell():New(oSection4,"DB_PRODUTO",	"SDB",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection4,"DB_QUANT",		"SDB",STR0018,   /*Picture*/,/*Tamanho*/,/*lPixel*/,{||DLGR280Calc(cAliasNew)}) //"Quantidade"
TRCell():New(oSection4,"DB_DATA",		"SDB")
TRCell():New(oSection4,"DB_HRINI",		"SDB")
TRCell():New(oSection4,"DB_DATAFIM",	"SDB")
TRCell():New(oSection4,"DB_HRFIM",		"SDB")
TRCell():New(oSection4,"NTOTHR",		"",STR0019,,,,{||IntToHora(SubtHoras((cAliasNew)->DB_DATA,(cAliasNew)->DB_HRINI,(cAliasNew)->DB_DATAFIM,(cAliasNew)->DB_HRFIM),3)}) //"Total de Horas"
Return(oReport)
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  砇eportPrint� Autor 矲lavio Luiz Vicco     矰ata  �20/06/2006潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矷ndicadores de Produtividade - Desempenho por Atividade     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   砃enhum                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros矱xpO1: Objeto Report do Relat髍io                           潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function ReportPrint(oReport,cAliasNew)
Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(1):Section(1)
Local oSection3  := oReport:Section(1):Section(1):Section(1)
Local oSection4  := oReport:Section(1):Section(1):Section(1):Section(1)
Local cQuebra	 := ""
Local cChave     := ""
Local cComp      := ""
Local oBreak1
#IFDEF TOP
	Local cSelect    := ""
	Local cWhere     := ""
	Local cOrder     := ""
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//砊ransforma parametros Range em expressao SQL                            �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	MakeSqlExpr(oReport:GetParam())
	If	mv_par10 == 1	//-- Recurso Humano
		cWhere  := "%AND DB_RHFUNC >= '"+mv_par11+"'"
		cWhere  += " AND DB_RHFUNC <= '"+mv_par12+"'%"
		cChave  := "DB_FILIAL,DB_LOCAL,DB_SERVIC,DB_TAREFA,DB_ATIVID,DB_RHFUNC"
	ElseIf mv_par10 == 2	//-- Recurso Fisico
		cWhere  := "%AND DB_RECFIS >= '"+mv_par11+"'"
		cWhere  += " AND DB_RECFIS <= '"+mv_par12+"'%"
		cChave  := "DB_FILIAL,DB_LOCAL,DB_SERVIC,DB_TAREFA,DB_ATIVID,DB_RECFIS"
	ElseIf mv_par10 == 3	//-- Unitizador
		cWhere  := "%AND DB_UNITIZ >= '"+mv_par11+"'"
		cWhere  += " AND DB_UNITIZ <= '"+mv_par12+"'%"
		cChave  := "DB_FILIAL,DB_LOCAL,DB_SERVIC,DB_TAREFA,DB_ATIVID,DB_UNITIZ"
	EndIf
	cOrder := "%"+cChave+"%"
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//砆uery do relat髍io da secao 1                                       �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	oSection1:BeginQuery()	
	BeginSql Alias cAliasNew
	//-->
	SELECT	SDB.DB_FILIAL,  SDB.DB_LOCAL,  SDB.DB_SERVIC,  SDB.DB_TAREFA, SDB.DB_ATIVID,
			SDB.DB_PRODUTO, SDB.DB_QUANT,  SDB.DB_QTSEGUM,
			SDB.DB_DATA,    SDB.DB_HRINI,  SDB.DB_DATAFIM, SDB.DB_HRFIM,
			SDB.DB_RHFUNC,  SDB.DB_RECFIS, SDB.DB_UNITIZ,
			SB1.B1_UM,      SB1.B1_PESO,   SB5.B5_ALTURLC, SB5.B5_LARGLC, SB5.B5_COMPRLC
	FROM %table:SDB% SDB
	LEFT JOIN %table:SB1% SB1  ON SB1.B1_FILIAL  = %xFilial:SB1% AND SB1.B1_COD = SDB.DB_PRODUTO AND SB1.%NotDel%
	LEFT JOIN %table:SB5% SB5  ON SB5.B5_FILIAL  = %xFilial:SB5% AND SB5.B5_COD = SDB.DB_PRODUTO AND SB5.%NotDel%
	WHERE DB_FILIAL   = %xFilial:SDB%
	AND   DB_LOCAL   >= %Exp:mv_par01%
	AND   DB_LOCAL   <= %Exp:mv_par02%
	AND   DB_SERVIC  >= %Exp:mv_par03%
	AND   DB_SERVIC  <= %Exp:mv_par04%
	AND   DB_TAREFA  >= %Exp:mv_par05%
	AND   DB_TAREFA  <= %Exp:mv_par06%
	AND   DB_ATIVID  >= %Exp:mv_par07%
	AND   DB_ATIVID  <= %Exp:mv_par08%
	AND   DB_ATUEST   = 'N'
	AND   DB_LOCAL   <> '  '
	AND   DB_DATA    <> %Exp:Space(Len(Dtos(SDB->DB_DATA)))%
	AND   DB_HRINI   <> '     '
	AND   DB_DATAFIM <> %Exp:Space(Len(Dtos(SDB->DB_DATAFIM)))%
	AND   DB_HRFIM   <> '     '
	AND   SDB.%NotDel%
	%Exp:cWhere%
	ORDER BY %Exp:cOrder%
	//-->
	EndSql
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//矼etodo EndQuery ( Classe TRSection )                                    �
	//�                                                                        �
	//砅repara o relat髍io para executar o Embedded SQL.                       �
	//�                                                                        �
	//矱xpA1 : Array com os parametros do tipo Range                           �
	//�                                                                        �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	oSection1:EndQuery(/*Array com os parametros do tipo Range*/)
#ELSE
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//砊ransforma parametros Range em expressao Advpl                          �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	MakeAdvplExpr(oReport:uParam)
	cCondicao  := 'DB_FILIAL == "'+xFilial('SDB')+'".And.'
	cCondicao  += 'DB_LOCAL  >= "'+mv_par01+'".And.'
	cCondicao  += 'DB_LOCAL  <= "'+mv_par02+'".And.'
	cCondicao  += 'DB_SERVIC >= "'+mv_par03+'".And.'
	cCondicao  += 'DB_SERVIC <= "'+mv_par04+'".And.'
	cCondicao  += 'DB_TAREFA >= "'+mv_par05+'".And.'
	cCondicao  += 'DB_TAREFA <= "'+mv_par06+'".And.'
	cCondicao  += 'DB_ATIVID >= "'+mv_par07+'".And.'
	cCondicao  += 'DB_ATIVID <= "'+mv_par08+'".And.'
	cCondicao  += 'DB_ATUEST == "N"       .And.'
	cCondicao  += '!Empty(SDB->DB_LOCAL)  .And.'
	cCondicao  += '!Empty(SDB->DB_DATA)   .And.'
	cCondicao  += '!Empty(SDB->DB_HRINI)  .And.'
	cCondicao  += '!Empty(SDB->DB_DATAFIM).And.'
	cCondicao  += '!Empty(SDB->DB_HRFIM)  .And.'
	If	mv_par10 == 1	//-- Recurso Humano
		cCondicao += 'DB_RHFUNC >= "'+mv_par11+'".And.'
		cCondicao += 'DB_RHFUNC <= "'+mv_par12+'"'
		cChave    := 'DB_FILIAL+DB_LOCAL+DB_SERVIC+DB_TAREFA+DB_ATIVID+DB_RHFUNC'
	ElseIf mv_par10 == 2	//-- Recurso Fisico
		cCondicao += 'DB_RECFIS >= "'+mv_par11+'".And.'
		cCondicao += 'DB_RECFIS <= "'+mv_par12+'"'
		cChave    := 'DB_FILIAL+DB_LOCAL+DB_SERVIC+DB_TAREFA+DB_ATIVID+DB_RECFIS'
	ElseIf mv_par10 == 3	//-- Unitizador
		cCondicao += 'DB_UNITIZ >= "'+mv_par11+'".And.'
		cCondicao += 'DB_UNITIZ <= "'+mv_par12+'"'
		cChave    := 'DB_FILIAL+DB_LOCAL+DB_SERVIC+DB_TAREFA+DB_ATIVID+DB_UNITIZ'
	EndIf
	oSection1:SetFilter(cCondicao,cChave)
#ENDIF
oBreak1 := TRBreak():New(oSection4,{||(cAliasNew)->(&cChave) },STR0017,.F.,,.F.) //"Total Geral: "
TRFunction():New(oSection4:Cell("DB_QUANT"),NIL,"SUM",    oBreak1,,/*cPicture*/,/*uFormula*/,.F.,.F. )
TRFunction():New(oSection4:Cell("NTOTHR"),  NIL,"TIMESUM",oBreak1,,,,.F.,.F.)
If	mv_par09 == 2 //-- Sintetico
	oSection4:Hide()
EndIf
If	mv_par10 == 1	//-- Recurso Humano
	oSection3:Cell("INDICADOR"):SetTitle(STR0028) //"Recurso Humano"
	oSection3:Cell("INDICADOR"):SetBlock({||(cAliasNew)->DB_RHFUNC+' - '+Posicione('SRJ',1,xFilial('SRJ')+(cAliasNew)->DB_RHFUNC,'RJ_DESC')})
ElseIf mv_par10 == 2	//-- Recurso Fisico
	oSection3:Cell("INDICADOR"):SetTitle(STR0029) //"Recurso Fisico"
	oSection3:Cell("INDICADOR"):SetBlock({||(cAliasNew)->DB_RECFIS+' - '+AllTrim(Posicione("D05",1,xFilial("D05")+(cAliasNew)->DB_RECFIS,"D05_DESREC"))})  
ElseIf mv_par10 == 3	//-- Unitizador
	oSection3:Cell("INDICADOR"):SetTitle(STR0030) //"Unitizador"
	If WmsX212118("D0T")
		oSection3:Cell("INDICADOR"):SetBlock({||(cAliasNew)->DB_UNITIZ+' - '+Posicione('D0T',1,xFilial('D0T')+(cAliasNew)->DB_UNITIZ,'D0T_DESUNI')})
	Else
		oSection3:Cell("INDICADOR"):SetBlock({||(cAliasNew)->DB_UNITIZ+' - '+Posicione('DC1',1,xFilial('DC1')+(cAliasNew)->DB_UNITIZ,'DC1_DESUNI')})
	EndIf
EndIf
oSection2:SetParentQuery()
oSection3:SetParentQuery()
oSection4:SetParentQuery()
oReport:SetMeter(SDB->(RecCount()))
dbSelectArea(cAliasNew)
oSection1:Init()
oSection2:Init()
oSection3:Init()
While !oReport:Cancel() .And. !(cAliasNew)->(Eof())
	oReport:IncMeter()
	If	oReport:Cancel()
		Exit
	EndIf
	If	cComp != (cAliasNew)->(&cChave)
		cComp := (cAliasNew)->(&cChave)
		oSection4:Finish()
		oReport:SkipLine()
		oSection1:PrintLine()
		oSection2:PrintLine()
		oSection3:PrintLine()
	EndIf
	oSection4:Init()
	oSection4:PrintLine()
	(cAliasNew)->(dbSkip())
EndDo
oSection4:Finish()
oSection3:Finish()
oSection2:Finish()
oSection1:Finish()
Return NIL
/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    矰LGR280Calc� Autor � Flavio Luiz Vicco    矰ata  �20/06/2006潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矯alculo do campo Quantidade                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � SIGAWMS                                                    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
/*/
Static Function DLGR280Calc(cAliasNew)
Local aAreaAnt   := GetArea()
Local cUM        := ""
Local nPeso      := 0
Local nAlturLC   := 0
Local nLargLC    := 0
Local nCmprLC    := 0
Local nRet       := 0
#IFDEF TOP
		cUM        := (cAliasNew)->B1_UM
		nPeso      := (cAliasNew)->B1_PESO
		nAlturLC   := (cAliasNew)->B5_ALTURLC
		nLargLC    := (cAliasNew)->B5_LARGLC
		nCmprLC    := (cAliasNew)->B5_COMPRLC
#ELSE
	dbSelectArea('SB1')
	If SB1->(dbSeek(xFilial('SB1')+(cAliasNew)->DB_PRODUTO)) .And. SB5->(dbSeek(xFilial('SB5')+(cAliasNew)->DB_PRODUTO))
		cUM      := SB1->B1_UM
		nPeso    := SB1->B1_PESO
		nAlturLC := SB5->B5_ALTURLC
		nLargLC  := SB5->B5_LARGLC
		nCmprLC  := SB5->B5_COMPRLC
	EndIf
#ENDIF
// --- Calculo quantidade e horas
If AllTrim(mv_par13) == '0001'		//-- Peso
	If	Upper(AllTrim(cUM)) == 'KG'
		nRet := (cAliasNew)->DB_QUANT
	Else
		nRet := (cAliasNew)->DB_QUANT * nPeso
	EndIf
ElseIf AllTrim(mv_par13) == '0002'	//-- Volume M3
	nRet := (cAliasNew)->DB_QUANT * nAlturLC * nLargLC * nCmprLC
ElseIf AllTrim(mv_par13) == '0003'	//-- Itens
	nRet := (cAliasNew)->DB_QTSEGUM //-- embalagem com 4 garrafas e igual a 1 item
ElseIf AllTrim(mv_par13) == '0004'	//-- Movimentacoes
	nRet := 1
ElseIf AllTrim(mv_par13) == '0005'	//-- Paletes
	nRet := 1
ElseIf AllTrim(mv_par13) == '0006'	//-- Quantidade
	nRet := (cAliasNew)->DB_QUANT
EndIf
RestArea(aAreaAnt)
Return nRet
/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  �          � Autor �     Paullo Vieira     � Data � 10/07/01 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o 矷ndicadores de Produtividade - Desempenho por Atividade     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros�                                                            潮�
北�          �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Function DLGR280R3()
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矰efine Variaveis                                                        �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Local wnrel   := 'DLGR280'  // Nome do Arquivo utilizado no Spool
Local cDesc1  := STR0001 //'Relatorio de todos os Movimentos de Distribuicao cadastrados no armazem com as informacoes'
Local cDesc2  := STR0002 //'utilizadas no armazem'
Local cDesc3  := ''  // Descricao 3
Local Tamanho := 'M' // P/M/G
Private cPerg   := 'DLR280'
Private cString := 'SDB' // Alias utilizado na Filtragem
Private aReturn := { STR0003, 1,STR0004, 1, 2, 1, '',1 }  //'Zebrado'###'Administracao'
//[1] Reservado para Formulario
//[2] Reservado para N� de Vias
//[3] Destinatario
//[4] Formato => 1-Comprimido 2-Normal
//[5] Midia   => 1-Disco 2-Impressora
//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
//[7] Expressao do Filtro
//[8] Ordem a ser selecionada
//[9]..[10]..[n] Campos a Processar (se houver)
Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault
Private Titulo  := STR0005 //'Indicadores de Produtividade'
Private nomeprog:= 'DLGR280'  // nome do programa
Private lEnd    := .F.// Controle de cancelamento do relatorio

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Variaveis utilizadas como parametros p/filtrar as ordens de servico    �
//媚哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇
//� mv_par01	// Armazem       De  ?                                     �
//� mv_par02	//               Ate ?                                     �
//� mv_par03	// Servico       De  ?                                     �
//� mv_par04	//               Ate ?                                     �
//� mv_par05	// Tarefa        De  ?                                     �
//� mv_par06	//               Ate ?                                     �
//� mv_par07	// Atividade     De  ?                                     �
//� mv_par08	//               Ate ?                                     �
//� mv_par09	// Analitico/Sintetic? 1-Analitico                         �
//�                                    2-Sintetico                         �
//� mv_par10	// Indicador         ? 1-Recurso Humano                    �
//�                                    2-Recurso Fisico                    �
//�                                    3-Unitizador                        �
//� mv_par11	// Indicador     De  ?                                     �
//� mv_par12	//               Ate ?                                     �
//� mv_par13	// Refer.Cobranca    ?                                     �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Pergunte(cPerg,.F.)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//矱nvia para a SetPrinter                                                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,Tamanho)

If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	Set Filter to
	Return
Endif

RptStatus({|lEnd| ImpDet(@lEnd,wnRel,cString,nomeprog,Titulo,Tamanho)},Titulo)

Return(.T.)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rogram   � ImpDet   � Autor �                       � Data �          潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri嘺o 矯ontrole de Fluxo do Relatorio.                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   砃enhum                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砃enhum                                                      潮�
北�          �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/
Static Function ImpDet(lEnd,wnrel,cString,nomeprog,Titulo,Tamanho)
Local lImp		:= .F. // Indica se algo foi impresso
Local cQuebra	:= ''
Local nTotHora	:= 0
Local nTotQuant	:= 0
Local nIndex	:= 0
Local cChave	:= ''
Local cIndTmp	:= ''
Local cQuery	:= ''
Local nRet		:= 0

Private cbCont	:= 00
Private Cbtext	:= Space( 10 )
Private Cabec1	:= ''
Private li		:= 80
Private m_pag	:= 01

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Inicializa os codigos de caracter Comprimido/Normal da impressora �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Private nTipo	:= IIF(aReturn[4]==1,SuperGetMV('MV_COMP',.F.,0),SuperGetMV('MV_NORM',.F.,0))
Private nOrdem	:= aReturn[8]
If	mv_par09 == 1
	Cabec1	:= STR0006 //"           Produto         Quantidade         Data Inicial   Hora Inicial   Data Final   Hora Final   Total de Horas"
Else
	Cabec1	:= STR0007 //"                           Quantidade                                                                 Total de Horas"
EndIf
//                  0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//                  01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Private Cabec2	:= ''
Private Cabec3	:= ''

dbSelectArea(cString)
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Variaveis utilizadas como parametros p/filtrar as ordens de servico   �
//媚哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� mv_par01	// Armazem       De  ?                                    �
//� mv_par02	//               Ate ?                                    �
//� mv_par03	// Servico       De  ?                                    �
//� mv_par04	//               Ate ?                                    �
//� mv_par05	// Tarefa        De  ?                                    �
//� mv_par06	//               Ate ?                                    �
//� mv_par07	// Atividade     De  ?                                    �
//� mv_par08	//               Ate ?                                    �
//� mv_par09	// Analitico/Sintetic? 1-Analitico                        �
//�                                    2-Sintetico                        �
//� mv_par10	// Indicador         ? 1-Recurso Humano                   �
//�                                    2-Recurso Fisico                   �
//�                                    3-Unitizador                       �
//� mv_par11	// Indicador     De  ?                                    �
//� mv_par12	//               Ate ?                                    �
//� mv_par13	// Refer.Cobranca    ?                                    �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�


cIndTmp := CriaTrab(NIL,.F.)
cQuery  := 'DB_FILIAL == "'+xFilial('SDB')+'".And.'
cQuery  += 'DB_LOCAL  >= "'+mv_par01+'".And.'
cQuery  += 'DB_LOCAL  <= "'+mv_par02+'".And.'
cQuery  += 'DB_SERVIC >= "'+mv_par03+'".And.'
cQuery  += 'DB_SERVIC <= "'+mv_par04+'".And.'
cQuery  += 'DB_TAREFA >= "'+mv_par05+'".And.'
cQuery  += 'DB_TAREFA <= "'+mv_par06+'".And.'
cQuery  += 'DB_ATIVID >= "'+mv_par07+'".And.'
cQuery  += 'DB_ATIVID <= "'+mv_par08+'".And.'
cQuery  += 'DB_ATUEST == "N"       .And.'
cQuery  += '!Empty(SDB->DB_LOCAL)  .And.'
cQuery  += '!Empty(SDB->DB_DATA)   .And.'
cQuery  += '!Empty(SDB->DB_HRINI)  .And.'
cQuery  += '!Empty(SDB->DB_DATAFIM).And.'
cQuery  += '!Empty(SDB->DB_HRFIM)  .And.'

If	mv_par10 == 1	//-- Recurso Humano
	cQuery  += 'DB_RHFUNC >= "'+mv_par11+'".And.'
	cQuery  += 'DB_RHFUNC <= "'+mv_par12+'"'
	cChave  := 'DB_FILIAL + DB_LOCAL + DB_SERVIC + DB_TAREFA + DB_ATIVID + DB_RHFUNC'
ElseIf mv_par10 == 2	//-- Recurso Fisico
	cQuery  += 'DB_RECFIS >= "'+mv_par11+'".And.'
	cQuery  += 'DB_RECFIS <= "'+mv_par12+'"'
	cChave  := 'DB_FILIAL + DB_LOCAL + DB_SERVIC + DB_TAREFA + DB_ATIVID + DB_RECFIS'
ElseIf mv_par10 == 3	//-- Unitizador
	cQuery  += 'DB_UNITIZ >= "'+mv_par11+'".And.'
	cQuery  += 'DB_UNITIZ <= "'+mv_par12+'"'
	cChave  := 'DB_FILIAL + DB_LOCAL + DB_SERVIC + DB_TAREFA + DB_ATIVID + DB_UNITIZ'
EndIf

IndRegua('SDB',cIndTmp,cChave,,cQuery,OemToAnsi(STR0008)) //'Selecionando Registros ...'
nIndex := RetIndex('SDB')
#IFNDEF TOP
	dbSetIndex(cIndTmp+OrdBagExt())
#ENDIF	
dbSetOrder(nIndex+1)
SetRegua(LastRec())
dbGoTop()

While SDB->(!Eof())
	lImp := .T.
	If lEnd
		@ Prow()+1,001 PSAY STR0009 //'CANCELADO PELO OPERADOR'
		Exit
	EndIf
	IncRegua()

	If li > 55
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
		cQuebra := ''
	Endif

	If	cQuebra != SDB->(&(cChave))
		cQuebra := SDB->(&(cChave))
		li++
		@ Li,00 PSay STR0010+ SDB->DB_LOCAL  //'Armazem  : '
		li++
		@ Li,00 PSay STR0011+ SDB->DB_SERVIC +' - '+ AllTrim(Tabela('L4',SDB->DB_SERVIC,.F.)) + '     ' + STR0012+ SDB->DB_TAREFA +' - '+ AllTrim(Tabela('L2',SDB->DB_TAREFA,.F.)) + '     ' + STR0013+ SDB->DB_ATIVID +' - '+ AllTrim(Tabela('L3',SDB->DB_ATIVID,.F.)) //'Servico  : '###'Tarefa   : '###'Atividade: '
		li++
		If	mv_par10 == 1	//-- Recurso Humano
			@ Li,00 PSay STR0014 + SDB->DB_RHFUNC + ' - ' + Posicione('SRJ',1,xFilial('SRJ')+SDB->DB_RHFUNC,'RJ_DESC') //'Recurso Humano  : '
		ElseIf mv_par10 == 2	//-- Recurso Fisico
			@ Li,00 PSay STR0015+ SDB->DB_RECFIS + ' - ' + AllTrim(Posicione("D05",1,xFilial("D05")+SDB->DB_RECFIS,"D05_DESREC")) //'Recurso Fisico : ' 
		ElseIf mv_par10 == 3	//-- Unitizador
			If WmsX212118("D0T")
				@ Li,00 PSay STR0016+ SDB->DB_UNITIZ + ' - ' + Posicione('D0T',1,xFilial('D0T')+SDB->DB_UNITIZ,'D0T_DESUNI') //'Unitizador : '
			Else
				@ Li,00 PSay STR0016+ SDB->DB_UNITIZ + ' - ' + Posicione('DC1',1,xFilial('DC1')+SDB->DB_UNITIZ,'DC1_DESUNI') //'Unitizador : '
			EndIf			
		EndIf
		li++
	EndIf

	If	mv_par09 == 1				//-- Analitico
		Li++
		@ Li,11 PSay SDB->DB_PRODUTO				Picture PesqPict("SDB","DB_PRODUTO")

		dbSelectArea('SB1')
		If SB1->(dbSeek( xFilial('SB1') + SDB->DB_PRODUTO )) .And. SB5->(dbSeek( xFilial('SB5') + SDB->DB_PRODUTO ))
			If AllTrim(mv_par13) == '0001'		//-- Peso
				If	Upper(AllTrim(SB1->B1_UM)) == 'KG'
					nRet := SDB->DB_QUANT
				Else
					nRet := SDB->DB_QUANT * SB1->B1_PESO
				EndIf
			ElseIf AllTrim(mv_par13) == '0002'	//-- Volume M3
				nRet	:= SDB->DB_QUANT * (SB5->B5_ALTURLC * SB5->B5_LARGLC * SB5->B5_COMPRLC)
			ElseIf AllTrim(mv_par13) == '0003'	//-- Itens
				nRet	:= SDB->DB_QTSEGUM										//-- embalagem com 4 garrafas e igual a 1 item
			ElseIf AllTrim(mv_par13) == '0004'	//-- Movimentacoes
				nRet	:= 1
			ElseIf AllTrim(mv_par13) == '0005'	//-- Paletes
				nRet	:= 1
			ElseIf AllTrim(mv_par13) == '0006'	//-- Quantidade
				nRet	:= SDB->DB_QUANT
			EndIf
		EndIf
		@ Li, 28 PSay nRet Picture PesqPictQt("DB_QUANT")
		@ Li, 48 PSay SDB->DB_DATA
		@ Li, 65 PSay SDB->DB_HRINI				Picture PesqPict("SDB","DB_HRINI")
		@ Li, 77 PSay SDB->DB_DATAFIM
		@ Li, 91 PSay SDB->DB_HRFIM				Picture PesqPict("SDB","DB_HRFIM")
		@ Li,106 PSay IntToHora(SubtHoras(SDB->DB_DATA,SDB->DB_HRINI,SDB->DB_DATAFIM,SDB->DB_HRFIM),3)
	EndIf

	nTotHora  += SubtHoras(SDB->DB_DATA,SDB->DB_HRINI,SDB->DB_DATAFIM,SDB->DB_HRFIM)
	nTotQuant += nRet
	dbSelectArea(cString)
	dbSkip()

	If cQuebra != SDB->(&(cChave))
		If	mv_par09 == 1				//-- Analitico
			Li+=2
			@ Li,00 PSay STR0017//'Total Geral: '
		EndIf
		@ Li, 28 PSay nTotQuant Picture PesqPictQt('DB_QUANT')
		@ Li,106 PSay IntToHora(nTotHora,3)
		nTotHora := 0
		nTotQuant:= 0
		li+=2
	EndIf

EndDo

If ( lImp )
	Roda(cbCont,cbText,Tamanho)
EndIf

If ( aReturn[5] = 1 )
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
EndIf

MS_FLUSH()

If	File(cIndTmp+OrdBagExt())
	dbSelectArea('SDB')
	Set Filter to
	Ferase(cIndTmp+OrdBagExt())
EndIf
RetIndex('SDB')
Return(.T.)
