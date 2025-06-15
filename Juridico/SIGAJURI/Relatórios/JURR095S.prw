#INCLUDE "PROTHEUS.CH"
#INCLUDE "JURR095S.CH"
#INCLUDE "topconn.ch"
#INCLUDE "SHELL.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE IMP_SPOOL 2
#DEFINE IMP_PDF   6
#DEFINE nColIni   50   // Coluna inicial
#DEFINE nColFim   2350 // Coluna final
#DEFINE nSalto    40   // Salto de uma linha a outra
#DEFINE nFimL     3000 // Linha Final da p�gina de um relat�rio
#DEFINE nTamCarac 20.5 // Tamanho de um caractere no relat�rio

//-------------------------------------------------------------------
/*/{Protheus.doc} JURR095S(cUser, cThread, cTipos, lAutomato, cNomerel, cCaminho, cJsonRel)
Regras do relat�rio de Societ�rio

@param cUser     Usuario
@param cThread   Se��o
@param cTipos    Tipos de envolvidos
@param lAutomato Define se vem da automa��o de testes
@param cNomerel  Nome do relat�rio
@param cCaminho  Caminho do arquivo quando chamado pelo TOTVS LEGAL
@param cJsonRel  Dados da gest�o de relat�rio do Totvs Jur�dico

@author Wellington Coelho
@since 19/01/16
@version 1.0

/*/
//-------------------------------------------------------------------
Function JURR095S(cUser, cThread, cTipos, lAutomato, cNomerel, cCaminho, cJsonRel)

If !lAutomato
	Processa({|| JURRel095S(cUser, cThread, cTipos, lAutomato, cNomerel, cCaminho, cJsonRel)}, STR0041, STR0042) // "Aguarde" "Emitindo relat�rio"
Else
	JURRel095S(cUser, cThread, cTipos, lAutomato, cNomerel, , cJsonRel)
Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} JURRel095S(cUser, cThread, cTipos, lAutomato, cNomerel, cCaminho, cJsonRel)
Regras do relat�rio de Assuntos Jur�dicos

@param cUser     Usuario
@param cThread   Se��o
@param cTipos    Tipos de envolvidos
@param lAutomato Define se vem da automa��o de testes
@param cNomerel  Nome do relat�rio
@param cCaminho  Caminho do arquivo quando chamado pelo TOTVS LEGAL
@param cJsonRel  Dados da gest�o de relat�rio do Totvs Jur�dico

@since 10/09/2021
/*/
//-------------------------------------------------------------------
Function JURRel095S(cUser, cThread, cTipos, lAutomato, cNomerel, cCaminho, cJsonRel)

Local oFont      := TFont():New("Arial",,-20,,.T.,,,,.T.,.F.) // Fonte usada no nome do relat�rio
Local oFontDesc  := TFont():New("Arial",,-12,,.F.,,,,.T.,.F.)   // Fonte usada nos textos
Local oFontTit   := TFont():New("Arial",,-12,,.T.,,,,.F.,.F.)   // Fonte usada nos t�tulos do relat�rio (T�tulo de campos e t�tulos no cabe�alho)
Local oFontSub   := TFont():New("Arial",,-12,,.T.,,,,.F.,.F.)   // Fonte usada nos t�tulos das sess�es
Local aRelat     := {}
Local aCabec     := {}
Local aSessao    := {}
Local cRelat     := STR0001	//"Societ�rio"

Default lAutomato := .F.
Default cNomerel := ""
Default cCaminho := ""
Default cTipos   := ""

//T�tulo do Relat�rio
  // 1 - T�tulo,
  // 2 - Posi��o da descri��o,
  // 3 - Fonte do t�tulo
aRelat := {cRelat,((2300-(10*Len(cRelat)))/2),oFont}//"Relat�rio de Societ�rio"

//Cabe�alho do Relat�rio
  // 1 - T�tulo, 
  // 2 - Conte�do, 
  // 3 - Posi��o de in�cio da descri��o(considere 20,5 para cada caractere do t�tulo, ou seja se o t�tulo tiver 6 caracteres indique 6x20,5 = 123. 
  //     Indique esse n�mero para todos os itens do cabe�alho, para que todos tenham o mesmo alinhamento. 
  //     Para isso considere sempre a posi��o da maior descri��o),
  // 4 - Fonte do t�tulo, 
  // 5 - Fonte da descri��o
aCabec := {{STR0002,DToC(Date()) ,(nTamCarac*9),oFontTit,oFontDesc}}	//"Impress�o"	

//Campos do Relat�rio
  //Exemplo da primeira parte -> aAdd(aSessao, {"Relat�rio de Societ�rio",65,oFontSub,.F.,;// 
  // 1 - T�tulo da sess�o do relat�rio,
  // 2 - Posi��o de in�cio da descri��o, 
  // 3 - Fonte no quadro com t�tulo da sess�o,
  // 4 - Impress�o na horizontal -> T�tulo e descri��o na mesma linha (Ex: Data: 01/01/2016)
  // 5 - Query do subreport - Se for parte do relat�rio principal n�o precisa ser indicado
    // Arrays a partir da 6� posi��o
      // 1 - T�tulo do campo,
      // 2 - Tabela do campo,
      // 3 - Nome do campo no dicion�rio,
      // 4 - Nome do Campo na Query,
      // 5 - Tipo do Campo,
      // 6 - Indica a coordenada horizontal em pixels ou caracteres, 
      // 7 - Tamanho que o conte�do pode ocupar,
      // 8 - Fonte do t�tulo, 
      // 9 - Fonte da descri��o
      // 10 - Posi��o de in�cio da descri��o
      // 11 - Quebra Linha ap�s impress�o do conte�do?
aAdd(aSessao, {STR0003,65,oFontSub,.T.,,;	//"Detalhe"
                {STR0004 ,"SA1","A1_NOME"   ,"A1_NOME"   ,"C",65  ,1500 ,oFontTit,oFontDesc,(nTamCarac*18),.F.},;	//"Raz�o Social:"
                {STR0005 ,"NSZ","NSZ_NOMEFT","NSZ_NOMEFT","C",1200,1800 ,oFontTit,oFontDesc,(nTamCarac*14),.T.},;	//"Nome Fantasia:"
                {STR0006 ,"SX5","X5_DESCRI" ,"X5_DESCRI" ,"C",65  ,1000 ,oFontTit,oFontDesc,(nTamCarac*18),.T.},;	//"Tipo de Sociedade:"
                {STR0007 ,"NSZ","NSZ_DENOM" ,"RECNONSZ"  ,"M",65  ,1000 ,oFontTit,oFontDesc,(nTamCarac*18),.T.},;	//"Denom. Ant.:"
                {STR0008 ,"NSZ","NSZ_DTCONS","NSZ_DTCONS","D",65  ,1000 ,oFontTit,oFontDesc,(nTamCarac*18),.F.},;	//"Data Constitui��o:"
                {STR0009 ,"NSZ","NSZ_INSEST","NSZ_INSEST","C",1000,1000 ,oFontTit,oFontDesc,(nTamCarac*14),.F.},;	//"Inscr. Estadual:"
                {STR0010 ,"NSZ","NSZ_INSMUN","NSZ_INSMUN","C",1700,1000 ,oFontTit,oFontDesc,(nTamCarac*14),.T.},;	//"Inscr. Municipal:"
                {STR0011 ,"NSZ","NSZ_NIRE"  ,"NSZ_NIRE"  ,"C",65  ,1000 ,oFontTit,oFontDesc,(nTamCarac*18),.F.},;	//"NIRE Matriz:"
                {STR0012 ,"NSZ","NSZ_ALVARA","NSZ_ALVARA","C",1000,1000 ,oFontTit,oFontDesc,(nTamCarac*14),.F.},;	//"Alvar�:"
                {STR0013 ,"NSZ","NSZ_CNAE"  ,"NSZ_CNAE"  ,"C",1700,1000 ,oFontTit,oFontDesc,(nTamCarac*14),.T.},;	//"CNAE Principal:"
                {STR0014 ,"NSZ","NSZ_LOGRAD","NSZ_LOGRAD","C",65  ,1000 ,oFontTit,oFontDesc,(nTamCarac*18),.T.},;	//"Logradouro:"
                {STR0015 ,"NSZ","NSZ_LOGNUM","NSZ_LOGNUM","C",65  ,1000 ,oFontTit,oFontDesc,(nTamCarac*18),.F.},;	//"N�mero:"
                {STR0016 ,"NSZ","NSZ_COMPLE","NSZ_COMPLE","C",1000,1000 ,oFontTit,oFontDesc,(nTamCarac*14),.F.},;	//"Complemento:"
                {STR0017 ,"NSZ","NSZ_BAIRRO","NSZ_BAIRRO","C",1700,1000 ,oFontTit,oFontDesc,(nTamCarac*14),.T.},;	//"Bairro:"
                {STR0018 ,"CC2","CC2_MUN"   ,"CC2_MUN"   ,"C",65  ,1000 ,oFontTit,oFontDesc,(nTamCarac*18),.F.},;	//"Munic�pio:"
                {STR0019 ,"NSZ","NSZ_CEP"   ,"NSZ_CEP"   ,"C",1000,1000 ,oFontTit,oFontDesc,(nTamCarac*14),.F.},;	//"CEP:"
                {STR0020 ,"NSZ","NSZ_ESTADO","NSZ_ESTADO","C",1700,1000 ,oFontTit,oFontDesc,(nTamCarac*14),.T.},;	//"UF:"
                {STR0021 ,"CTO","CTO_SIMB"  ,"CTO_SIMB"  ,"C",65  ,800  ,oFontTit,oFontDesc,(nTamCarac*18),.F.},;	//"Capital Social:"
                {""      ,"NSZ","NSZ_VLCAPI","NSZ_VLCAPI","C",150 ,1000 ,oFontTit,oFontDesc,(nTamCarac*18),.T.},;	///*Valor*/
                {STR0022 ,"NSZ","NSZ_VLACAO","NSZ_VLACAO","C",65  ,1000 ,oFontTit,oFontDesc,(nTamCarac*18),.T.}})	//"Qtde. Quotas/A��es:"

If !EMPTY(cTipos)
	aAdd(aSessao, {STR0023,65,oFontSub,.F.,J95SQrySoc(),;// T�tulo da sess�o do relat�rio	//"S�cios Envolvidos"
                {STR0024 ,"NT9","NT9_NOME"  ,"NT9_NOME"  ,"C",65   ,1000,oFontTit,oFontDesc,(nTamCarac*4) ,.F.},;	//"Nome"
                {STR0025 ,"NT9","NT9_QTPARC","NT9_QTPARC","C",500  ,1000,oFontTit,oFontDesc,(nTamCarac*12),.F.},;	//"Quotas/A��es"
                {STR0026 ,"NT9","NT9_PRECO" ,"NT9_PRECO" ,"C",1000 ,1000,oFontTit,oFontDesc,(nTamCarac*5) ,.F.},;	//"Valor"
                {STR0027 ,"NT9","NT9_PERCAC","NT9_PERCAC","C",1800 ,2800,oFontTit,oFontDesc,(nTamCarac*14),.T.}})	//"% A��es/Quotas"
EndIf

aAdd(aSessao, {STR0028,65,oFontSub,.F.,J95SQryEnv(),;// T�tulo da sess�o do relat�rio	//"Outros Envolvidos"
                {STR0029 ,"NT9","NT9_NOME"  ,"NT9_NOME"   ,"C",65   ,1000,oFontTit,oFontDesc,(nTamCarac*4) ,.F.},;	//"Nome Envolvido"
                {STR0030 ,"NQA","NQA_DESC"  ,"NQA_DESC"   ,"C",1000 ,1000,oFontTit,oFontDesc,(nTamCarac*12),.F.},;	//"Tipo Envolvido"
                {STR0031 ,"NT9","NT9_DTENTR","NT9_DTENTR" ,"D",1400 ,1000,oFontTit,oFontDesc,(nTamCarac*5) ,.F.},;	//"Data Ini. Mandato"
                {STR0032 ,"NT9","NT9_DTSAID","NT9_DTSAID" ,"D",1800 ,2800,oFontTit,oFontDesc,(nTamCarac*14),.T.}})	//"Data Fim Mandato"

aAdd(aSessao, {"",65,oFontSub,.T.,,;// T�tulo da sess�o do relat�rio  
                {STR0033 ,"NSZ","NSZ_ULTCON","NSZ_ULTCON","C",65  ,1800 ,oFontTit,oFontDesc,(nTamCarac*16),.F.},;	//"Ult. Consolida��o:"
                {STR0034 ,"NSZ","NSZ_ALTPOS","NSZ_ALTPOS","C",1000,1800 ,oFontTit,oFontDesc,(nTamCarac*16),.T.},;	//"Alt. Posteriores:"
                {STR0035 ,"NSZ","NSZ_DESALT","RECNONSZ"  ,"M",65  ,2800 ,oFontTit,oFontDesc,(nTamCarac*16),.T.},;	//"Descr. Posterior:"
                {STR0036 ,"NSZ","NSZ_OBJSOC","NSZ_OBJSOC","C",65  ,2800 ,oFontTit,oFontDesc,(nTamCarac*16),.T.}})	//"Objeto Social:"

aAdd(aSessao, {STR0037,65,oFontSub,.T.,J95SQryUni(),;// T�tulo da sess�o do relat�rio	//"Unidades"  
                {STR0005 ,"NYJ","NYJ_NOMEFT","NYJ_NOMEFT","C",65  ,1500 ,oFontTit,oFontDesc,(nTamCarac*16),.F.},;	//"Nome Fantasia:"
                {STR0038 ,"NYJ","NYJ_UNIDAD","NYJ_UNIDAD","C",1500,1000 ,oFontTit,oFontDesc,(nTamCarac*8),.T.},;	//"Unidade:"
                {STR0006 ,"SX5","X5_DESCRI" ,"X5_DESCRI" ,"C",65  ,1000 ,oFontTit,oFontDesc,(nTamCarac*16),.T.},;	//"Tipo de Sociedade:"
                {STR0007 ,"NYJ","NYJ_DENOM" ,"RECNONYJ"  ,"M",65  ,1000 ,oFontTit,oFontDesc,(nTamCarac*16),.T.},;	//"Denom. Ant.:"
                {STR0008 ,"NYJ","NYJ_DTCONS","NYJ_DTCONS","D",65  ,1000 ,oFontTit,oFontDesc,(nTamCarac*16),.F.},;	//"Data Constitui��o:"
                {STR0009 ,"NYJ","NYJ_INSEST","NYJ_INSEST","C",1000,1000 ,oFontTit,oFontDesc,(nTamCarac*14),.F.},;	//"Inscr. Estadual:"
                {STR0010 ,"NYJ","NYJ_INSMUN","NYJ_INSMUN","C",1700,1000 ,oFontTit,oFontDesc,(nTamCarac*15),.T.},;	//"Inscr. Municipal:"
                {STR0011 ,"NYJ","NYJ_NIRE"  ,"NYJ_NIRE"  ,"C",65  ,1000 ,oFontTit,oFontDesc,(nTamCarac*16),.F.},;	//"NIRE Matriz:"
                {STR0012 ,"NYJ","NYJ_ALVARA","NYJ_ALVARA","C",1000,1000 ,oFontTit,oFontDesc,(nTamCarac*14),.F.},;	//"Alvar�:"
                {STR0013 ,"NYJ","NYJ_CNAE"  ,"NYJ_CNAE"  ,"C",1700,1000 ,oFontTit,oFontDesc,(nTamCarac*15),.T.},;	//"CNAE Principal:"
                {STR0014 ,"NYJ","NYJ_LOGRAD","NYJ_LOGRAD","C",65  ,1000 ,oFontTit,oFontDesc,(nTamCarac*16),.T.},;	//"Logradouro:"
                {STR0015 ,"NYJ","NYJ_LOGNUM","NYJ_LOGNUM","C",65  ,1000 ,oFontTit,oFontDesc,(nTamCarac*16),.F.},;	//"N�mero:"
                {STR0016 ,"NYJ","NYJ_COMPLE","NYJ_COMPLE","C",1000,1000 ,oFontTit,oFontDesc,(nTamCarac*14),.F.},;	//"Complemento:"
                {STR0017 ,"NYJ","NYJ_BAIRRO","NYJ_BAIRRO","C",1700,1000 ,oFontTit,oFontDesc,(nTamCarac*15),.T.},;	//"Bairro:"
                {STR0018 ,"NYJ","CC2_MUN"   ,"CC2_MUN"   ,"C",65  ,1000 ,oFontTit,oFontDesc,(nTamCarac*16),.F.},;	//"Munic�pio:"
                {STR0019 ,"NYJ","NYJ_CEP"   ,"NYJ_CEP"   ,"C",1000,1000 ,oFontTit,oFontDesc,(nTamCarac*14),.F.},;	//"CEP:"
                {STR0020 ,"NYJ","NYJ_ESTADO","NYJ_ESTADO","C",1700,1000 ,oFontTit,oFontDesc,(nTamCarac*15),.T.}})	//"UF:"


JRelatorio(aRelat, aCabec, aSessao, J095SQrPrin(cUser, cThread), lAutomato, cNomerel, cCaminho, cJsonRel) //Chamada da fun��o de impress�o do relat�rio em TMSPrinter

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J095SQrPrin(cUser, cThread)
Gera a query principal do relat�rio
 
Uso Geral.

@param cUser Usuario
@param cThread Se��o

@Return cQuery Query principal do relat�rio

@author Wellington Coelho
@since 21/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J095SQrPrin(cUser, cThread)
Local cQuery := ""

cQuery := " SELECT NSZ001.NSZ_FILIAL,NQ3001.NQ3_CUSER, NQ3001.NQ3_SECAO, SA1001.A1_NOME, NSZ001.NSZ_NOMEFT, SX5001.X5_DESCRI, " 
cQuery += "  NSZ001.NSZ_DTCONS, NSZ001.NSZ_INSEST, NSZ001.NSZ_INSMUN, NSZ001.NSZ_NIRE, NSZ001.NSZ_ALVARA, "
cQuery += "  NSZ001.NSZ_CNAE, NSZ001.NSZ_LOGRAD, NSZ001.NSZ_LOGNUM, NSZ001.NSZ_COMPLE, NSZ001.NSZ_BAIRRO, "
cQuery += "  CC2001.CC2_MUN, NSZ001.NSZ_CEP, NSZ001.NSZ_ESTADO,NSZ001.NSZ_VLACAO, NSZ001.NSZ_COD, "
cQuery += "  NSZ001.NSZ_ULTCON, NSZ001.NSZ_ALTPOS, NSZ001.NSZ_OBJSOC, SX5001.X5_TABELA, NSZ001.D_E_L_E_T_, "
cQuery += "  CTO001.CTO_SIMB, NSZ001.NSZ_VLCAPI, CC2001.CC2_FILIAL, CTO001.CTO_FILIAL, NQ3001.D_E_L_E_T_, "
cQuery += "  NSZ001.R_E_C_N_O_ RECNONSZ , NT9001.NT9_CAJURI, NT9001.NT9_CTPENV, NT9001.NT9_NOME, "
cQuery += "  NT9001.NT9_QTPARC, NT9001.NT9_PERCAC, NT9001.NT9_PRECO "

cQuery += " FROM " + RetSqlName("NQ3") + " NQ3001 " 

cQuery += "  INNER JOIN "  + RetSqlName("NSZ") + " NSZ001 "
cQuery += "   ON ( NSZ001.D_E_L_E_T_ = ' ' )"
cQuery += "   AND ( NSZ001.NSZ_FILIAL = NQ3001.NQ3_FILORI )"
cQuery += "   AND ( NSZ001.NSZ_COD = NQ3001.NQ3_CAJURI )"

cQuery += "  LEFT OUTER JOIN " + RetSqlName("SA1") + " SA1001 "
cQuery += "   ON ( SA1001.D_E_L_E_T_ = ' ' )"
cQuery += "   AND ( SA1001.A1_FILIAL = '" + xFilial("SA1") + "')"
cQuery += "   AND ( SA1001.A1_COD = NSZ001.NSZ_CCLIEN ) "
cQuery += "   AND ( SA1001.A1_LOJA = NSZ001.NSZ_LCLIEN ) " 

cQuery += "  INNER JOIN "  + RetSqlName("SX5") + " SX5001 "
cQuery += "   ON ( SX5001.D_E_L_E_T_ = ' ' )"
cQuery += "   AND ( SX5001.X5_FILIAL = '" + xFilial("SX5") + "')"
cQuery += "   AND ( SX5001.X5_CHAVE = NSZ001.NSZ_CTPSOC ) "

cQuery += "  LEFT OUTER JOIN "  + RetSqlName("CC2") + " CC2001 "
cQuery += "   ON ( CC2001.D_E_L_E_T_ = ' ' )"
cQuery += "   AND ( CC2001.CC2_FILIAL = '" + xFilial("CC2") + "')"
cQuery += "   AND ( CC2001.CC2_EST = NSZ001.NSZ_ESTADO) "
cQuery += "   AND ( CC2001.CC2_CODMUN = NSZ001.NSZ_CMUNIC ) "

cQuery += "  LEFT OUTER JOIN "  + RetSqlName("CTO") + " CTO001 "
cQuery += "   ON ( CTO001.D_E_L_E_T_ = ' ' )"
cQuery += "   AND ( CTO001.CTO_FILIAL = '" + xFilial("CTO") + "')"
cQuery += "   AND ( CTO001.CTO_MOEDA = NSZ001.NSZ_CMOCAP ) "

cQuery += "  INNER JOIN "  + RetSqlName("NT9") + " NT9001 "
cQuery += "   ON ( NT9001.D_E_L_E_T_ = ' ' )"
cQuery += "   AND ( NT9001.NT9_FILIAL = '" + xFilial("NT9") + "')"
cQuery += "   AND ( NT9001.NT9_CAJURI = NSZ001.NSZ_COD )"

cQuery += " WHERE  NQ3001.D_E_L_E_T_= ' '"
cQuery += "   AND NQ3001.NQ3_FILIAL = '" + xFilial("NQ3") + "'"
cQuery += "   AND NQ3001.NQ3_SECAO = '" +cThread+ "'"
cQuery += "   AND NQ3001.NQ3_CUSER = '" +cUser+ "'"
cQuery += "   AND SX5001.X5_TABELA = 'J4' "

cQuery += " ORDER BY NSZ001.NSZ_COD, NSZ001.NSZ_DTSOLI  " 

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J95SQrySoc(cCajuri)
Gera a query do sub relat�rio de Envolvidos
 
Uso Geral.

@param cCajuri Codigo do assunto juridico posicionado

@Return cQueryEnv Query do sub relat�rio de envolvidos

@author Wellington Coelho
@since 21/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J95SQrySoc(cCajuri)
Local cQueryEnv := ""

cQueryEnv := " SELECT NT9001.NT9_CAJURI, NT9001.NT9_CTPENV, NT9001.NT9_NOME, "
cQueryEnv += "  NT9001.NT9_QTPARC, NT9001.NT9_PERCAC, NT9001.NT9_PRECO "
cQueryEnv += " FROM " + RetSqlName("NT9") + " NT9001 "
cQueryEnv += " WHERE  NT9001.NT9_CAJURI = '@#NT9_CAJURI#@' AND NT9001.NT9_FILIAL = '@#NSZ_FILIAL#@'" 
cQueryEnv += "  AND  NT9001.D_E_L_E_T_ = ' '"

Return cQueryEnv

//-------------------------------------------------------------------
/*/{Protheus.doc} J95SQryEnv(cCajuri)
Gera a query do sub relat�rio de Responsaveis
 
Uso Geral. 

@param cQueryEnv Query do sub relat�rio de envolvidos

@Return cQueryEnv Query do sub relat�rio de envolvidos

@author Wellington Coelho
@since 21/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J95SQryEnv(cCajuri)
Local cQueryEnv := ""

cQueryEnv := " SELECT NT9001.NT9_CAJURI, NT9001.D_E_L_E_T_, NT9001.NT9_NOME, NQA001.NQA_DESC, "
cQueryEnv += "  NT9001.NT9_DTENTR, NT9001.NT9_DTSAID, NT9001.NT9_CTPENV "
cQueryEnv += " FROM " + RetSqlName("NT9") + " NT9001 "
cQueryEnv += " LEFT OUTER JOIN " + RetSqlName("NQA") + " NQA001 ON (NT9001.NT9_CTPENV = NQA001.NQA_COD) " 
cQueryEnv += " WHERE  NT9001.NT9_CAJURI = '@#NT9_CAJURI#@' "
cQueryEnv += "  AND NT9001.NT9_FILIAL = '@#NSZ_FILIAL#@' AND  NT9001.D_E_L_E_T_ = ' '"
 
Return cQueryEnv

//-------------------------------------------------------------------
/*/{Protheus.doc} J95SQryUni(cCajuri)
Gera a query do sub relat�rio de Unidades
 
Uso Geral.

@param cQueryUni Query do sub relat�rio de Unidades

@Return cQueryUni Query do sub relat�rio de Unidades

@author Wellington Coelho
@since 21/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J95SQryUni(cCajuri)
Local cQueryUni := ""
cQueryUni := " SELECT SX5001.X5_DESCRI, SX5001.X5_TABELA, CC2001.CC2_MUN, NYJ001.NYJ_INSEST, NYJ001.NYJ_ALVARA, " 
cQueryUni += "  NYJ001.NYJ_INSMUN, NYJ001.NYJ_CNAE, NYJ001.NYJ_NIRE, NYJ001.NYJ_LOGRAD, NYJ001.NYJ_LOGNUM, "
cQueryUni += "  NYJ001.NYJ_COMPLE, NYJ001.NYJ_BAIRRO, NYJ001.NYJ_CEP, NYJ001.NYJ_ESTADO, NYJ001.NYJ_NOMEFT, "
cQueryUni += "  NYJ001.NYJ_DTCONS, NYJ001.NYJ_CAJURI, NYJ001.D_E_L_E_T_, NYJ001.NYJ_UNIDAD, " 
cQueryUni += "  CC2001.CC2_FILIAL, NYJ001.R_E_C_N_O_ RECNONYJ "
cQueryUni += " FROM " + RetSqlName("NYJ") + " NYJ001 "

cQueryUni += "  INNER JOIN "  + RetSqlName("SX5") + " SX5001 "
cQueryUni += "   ON ( SX5001.D_E_L_E_T_ = ' ' )"
cQueryUni += "   AND ( SX5001.X5_FILIAL = '" + xFilial("SX5") + "')"
cQueryUni += "   AND ( SX5001.X5_CHAVE = NYJ001.NYJ_CTPSOC ) "

cQueryUni += "  LEFT OUTER JOIN "  + RetSqlName("CC2") + " CC2001 "
cQueryUni += "   ON ( CC2001.D_E_L_E_T_ = ' ' )"
cQueryUni += "   AND ( CC2001.CC2_FILIAL = '" + xFilial("CC2") + "')"
cQueryUni += "   AND ( CC2001.CC2_EST = NYJ001.NYJ_ESTADO) "
cQueryUni += "   AND ( CC2001.CC2_CODMUN = NYJ001.NYJ_CMUNIC ) " 

cQueryUni += " WHERE  NYJ001.NYJ_CAJURI = '@#NSZ_COD#@' " 
cQueryUni += "  AND SX5001.X5_TABELA='J4' "
cQueryUni += "  AND NYJ001.D_E_L_E_T_=' ' "
cQueryUni += " ORDER BY NYJ001.NYJ_UNIDAD "

Return cQueryUni 

//-------------------------------------------------------------------
/*/{Protheus.doc} JRelatorio(aRelat, aCabec, aSessao, cQuery, lAutomato, cNomerel, cCaminho, cJsonRel)
Executa a query principal e inicia a impress�o do relat�rio.
Ferramenta TMSPrinter
Uso Geral.

@param aRelat    Dados do t�tulo do relat�rio
@param aCabec    Dados do cabe�alho do relat�rio
@param aSessao   Dados do conte�do do relat�rio
@param cQuery    Query que ser� executada
@param lAutomato Define se vem da automa��o de testes
@param cNomerel  Nome do relat�rio
@param cCaminho  Caminho do arquivo quando chamado pelo TOTVS LEGAL
@param cJsonRel  Dados da gest�o de relat�rio do Totvs Jur�dico

@Return nil

@author Jorge Luis Branco Martins Junior
@since 07/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JRelatorio(aRelat, aCabec, aSessao, cQuery, lAutomato, cNomerel, cCaminho, cJsonRel)
Local lHori      := .F.
Local lQuebPag   := .F.
Local lValor     := .F.
Local lTitulo    := .T. 
Local lLinTit    := .F.
Local nI         := 0    // Contador
Local nJ         := 0    // Contador
Local nLin       := 0    // Linha Corrente
Local nLinCalc   := 0    // Contator de linhas - usada para os c�lculos de novas linhas
Local nLinCalc2  := 0
Local nLinFinal  := 0
Local oPrint     := Nil
Local aDados     := {}
Local cTMP       := GetNextAlias()
Local lO17       := FWAliasInDic('O17') .and. !Empty(cJsonRel)
Local oJsonRel   := NIL
Local cCajuris   := ""

Default lAutomato := .F.
Default cNomerel  := ""
Default cCaminho  := ""
Default cJsonRel  := ""

	If (lO17)
		oJsonRel := JsonObject():New()
		oJsonRel:FromJson(cJsonRel)
	EndIf

	cNomerel := Iif(EMPTY(cNomerel), AllTrim(aRelat[1]), cNomerel ) //Nome do Relat�rio

	If !lAutomato
		oPrint := FWMsPrinter():New( cNomeRel, IMP_PDF,,, .T.,,, "PDF" ) // Inicia o relat�rio
	Else
		oPrint := FWMsPrinter():New( cNomeRel, IMP_SPOOL,,, .T.,,,) // Inicia o relat�rio
		//Alterar o nome do arquivo de impress�o para o padr�o de impress�o automatica
		oPrint:CFILENAME  := cNomeRel
		oPrint:CFILEPRINT := oPrint:CPATHPRINT + oPrint:CFILENAME
	Endif

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTMP,.T.,.T.)

	If lO17
		J288GestRel(oJsonRel)
		oJsonRel["O17_MIN"] := 0
		oJsonRel["O17_MAX"] := (cTMP)->(ScopeCount())
		(cTMP)->(DbGoTop())
	EndIf

	If (cTMP)->(!EOF())
		While (cTMP)->(!EOF())
			If !(cTMP)->NSZ_FILIAL+(cTMP)->NSZ_COD $ cCajuris
				cCajuris := (cTMP)->NSZ_FILIAL+(cTMP)->NSZ_COD + "|"
				oPrint:EndPage() // Se for um novo assunto jur�dico, encerra a p�gina atual
				ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho
				nLinCalc := nLin // Inicia o controle das linhas impressas
				lTitulo := .T. // Indica que o t�tulo pode ser impresso 
				lLinTit := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada

				For nI := 1 To Len(aSessao) // Inicia a impress�o de cada sess�o do relat�rio
					
					lValor := .F.
					lHori  := aSessao[nI][4]
					
					If !Empty(aSessao[nI][5]) // Nessa posi��o � indicada a query de um subreport
						JImpSub(aSessao[nI][5], cTMP, aSessao[nI], @nLinCalc, @lQuebPag, aRelat, aCabec, @oPrint, @nLin, @lTitulo, @lLinTit) // Imprime os dados do subreport
					Else

						nLinCalc2 := nLinCalc // Backup da pr�xima linha a ser usada, pois na fun��o JDadosCpo abaixo a variavel tem seu conte�do alterado para
											// que seja realizada uma simula��o das linhas usadas para impress�o do conte�do. 

						nLinFinal := 0 // Limpa a vari�vel

						For nJ := 6 to Len(aSessao[nI]) // L� as informa��es de cada campo a ser impresso. O contador come�a em 6 pois � a partir dessa posi��o que est�o as informa��es sobre o campo
							cTabela  := aSessao[nI][nJ][2] //Tabela
							cCpoTab  := aSessao[nI][nJ][3] //Nome do campo na tabela
							cCpoQry  := aSessao[nI][nJ][4] //Nome do campo na query
							cTipo    := aSessao[nI][nJ][5] //Tipo do campo
							cValor := JTrataVal(cTabela,cCpoTab,cCpoQry,cTipo,cTMP,,.F.) // Retorna o conte�do/valor a ser impresso. Chama essa fun��o para tratar o valor caso seja um memo ou data
							If !lValor .And. !Empty(AllTrim(cValor))
								lValor := .T.
							EndIf
							aAdd(aDados,JDadosCpo(aSessao[nI][nJ],cValor,@nLinCalc,@lQuebPag)) // T�tulo e conte�do de cada campo s�o inseridos do array com os dados para serem impressos abaixo
						Next 
			
						nLinCalc := nLinCalc2 // Retorno do valor original da vari�vel
						
						If nI > 1 // Inclui uma linha em branco no final de cada sess�o do relat�rio principal, desde que n�o seja a primeira sess�o 
							nLin += nSalto
						EndIf		
						
						If lTitulo .And. !Empty(aSessao[nI][1])
							If (nLin + 80) >= nFimL // Verifica se o t�tulo da sess�o cabe na p�gina
								oPrint:EndPage() // Se for maior, encerra a p�gina atual
								ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho
								nLinCalc := nLin // Inicia o controle das linhas impressas
								lTitulo := .T. // Indica que o t�tulo pode ser impresso 
								lLinTit := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
							EndIf
							If lValor // Se existir valor a ser impresso na sess�o imprime o t�tulo da sess�o.
								JImpTitSes(@oPrint, @nLin, @nLinCalc, aSessao[nI]) //Imprime o t�tulo da sess�o no relat�rio
							EndIf
						EndIf
						
						If !lHori // Caso a impress�o dos t�tulos seja na vertical - Todos os t�tulos na mesma linha e os conte�dos vem em colunas abaixo dos t�tulos (Ex: Relat�rio de andamentos)
							// Os t�tulos devem ser impressos
							lTitulo := .T. // Indica que o t�tulo pode ser impresso 
							lLinTit := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
						EndIf
						
						//Imprime os campos do relat�rio
						JImpRel(aDados,@nLin,@nLinCalc,@oPrint, @nLinFinal,lHori, @lTitulo, @lLinTit, aRelat,aCabec)
						
						//Limpa array de dados
						aSize(aDados,0)
						aDados := {}
			
						If nLinFinal > 0
							nLinCalc := nLinFinal //Indica a maior ref�ncia de uso de linhas para que sirva como refer�ncia para come�ar a impress�o do pr�ximo registro
						EndIf
						
						nLinFinal := 0 // Limpa a vari�vel
						
						nLin := nLinCalc//+nSalto //Recalcula a linha de refer�ncia para impress�o

					EndIf

				Next

				oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relat�rio
				oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relat�rio
				
				nLin += nSalto //Adiciona uma linha em branco ap�s a linha impressa
				nLinCalc := nLin
			EndIf
			(cTMP)->(DbSkip())
		Enddo

		(cTMP)->(dbCloseArea())

		aSize(aDados,0)  //Limpa array de dados
		aSize(aRelat,0)  //Limpa array de dados do relat�rio
		aSize(aCabec,0)  //Limpa array de dados do cabe�alho do relat�rio
		aSize(aSessao,0) //Limpa array de dados das sess�es do relat�rio

		oPrint:EndPage() // Finaliza a p�gina

		If !lAutomato
			If Empty(cCaminho)
				oPrint:CFILENAME  := AllTrim(cNomeRel) + '-' + SubStr(AllTrim(Str(ThreadId())),1,4) + RetCodUsr() + StrTran(Time(),':','') + '.rel'
				oPrint:CFILEPRINT := oPrint:CPATHPRINT + oPrint:CFILENAME
			Else
				oPrint:CFILENAME  := cNomeRel
				oPrint:CFILEPRINT := cCaminho + cNomeRel
			EndIf
		Endif

		oPrint:Print()

		If !lAutomato .And. Empty(cCaminho)
			FErase(oPrint:CFILEPRINT)
		Endif

		lRelOk := FILE(cCaminho + cNomeRel)

		If lO17 .AND. !lRelOk
			oJsonRel['O17_DESC']   := STR0036 // "N�o foi poss�vel gerar o relat�rio."
			oJsonRel['O17_STATUS'] := "1" // Erro
			J288GestRel(oJsonRel)
		Endif

	EndIf

Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpCabec(oPrint, nLin, aRelat, aCabec)
Imprime cabe�alho do relat�rio
 
Uso Geral.

@param oPrint  Objeto do Relat�rio (TMSPrinter)
@param nLin    Linha Corrente
@param aRelat  Dados do t�tulo do relat�rio
@param aCabec  Dados do cabe�alho do relat�rio

@Return nil

@author Jorge Luis Branco Martins Junior
@since 07/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ImpCabec(oPrint, nLin, aRelat, aCabec)
Local cTit       := aRelat[1] // T�tulo
Local nColTit    := aRelat[2] // Posi��o da T�tulo
Local oFontTit   := aRelat[3] // Fonte do T�tulo
Local cTitulo    := ""
Local cValor     := ""
Local nPosValor  := 0
Local nSaltoCabe := 30
Local nI         := 0
Local oFontValor 
Local oFontRoda  := TFont():New("Arial",,-8,,.F.,,,,.T.,.F.) // Fonte usada no Rodap�

oPrint:SetPortrait()   // Define a orienta��o do relat�rio como retrato (Portrait).

oPrint:SetPaperSize(9) //A4 - 210 x 297 mm

// Inicia a impressao da pagina
oPrint:StartPage()
oPrint:Say( nFimL, nColFim - 100, alltochar(oPrint:NPAGECOUNT), oFontRoda )
oPrint:Line( nSaltoCabe, nColIni, nSaltoCabe, nColFim ) // Imprime uma linha na horizontal no relat�rio
oPrint:Line( nSaltoCabe, nColIni, nSaltoCabe, nColFim ) // Imprime uma linha na horizontal no relat�rio
nLin := 90

// Imprime o cabecalho
oPrint:Say( nLin, nColTit, cTit, oFontTit )

If Len(aCabec) > 0
	For nI := 1 to Len(aCabec)
		cTitulo    := aCabec[nI][1] // T�tulo
		cValor     := aCabec[nI][2] // Conte�do
		nPosValor  := aCabec[nI][3] // Posi��o do conte�do (considere 20,5 para cada caractere do t�tulo, ou seja se o t�tulo tiver 6 caracteres indique 6x20,5 = 123. Indique esse n�mero para todos os itens do cabe�alho, para que todos tenham o mesmo alinhamento. Para isso considere sempre a posi��o da maior descri��o)
		oFontTit   := aCabec[nI][4] // Fonte do t�tulo
		oFontValor := aCabec[nI][5] // Fonte do conte�do
		oPrint:Say( nLin += nSaltoCabe, 070                        , cTitulo + ":" , oFontTit   ) //Imprime o T�tulo
		oPrint:Say( nLin              , nPosValor + (nTamCarac * 4), cValor        , oFontValor ) //Imprime o Conte�do - Esse (nTamCarac * 4) � para dar um espa�o de 4 caracteres a mais do que o tamanho da descri��o
	Next
EndIf

nLin+= nSaltoCabe // Inclui duas linhas em branco ap�s a impress�o do cabe�alho
oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relat�rio
oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relat�rio

nLin+=40 //Recalcula a linha de refer�ncia para impress�o

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JTrataVal(cTabela,cCpoTab,cCpoQry,cTipo,TMP,SUB,lSub)
Trata os tipos de campos e imprime os valores
 
Uso Geral.

@param cTabela Nome da tabela
@param cCpoTab Nome do campo na tabela
@param cCpoQry Nome do campo na query
@param cTipo   Tipo do campo
@param TMP     Alias aberto da query principal
@param SUB     Alias aberto da query do sub relat�rio que esta sendo impresso
@param lSub    Indica se � um sub relat�rio

@return cValor Valor do campo na Query

@author Jorge Luis Branco Martins Junior
@since 15/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JTrataVal(cTabela,cCpoTab,cCpoQry,cTipo,TMP,SUB,lSub)
Local cValor := ""
Local cPicture := JURX3INFO(cCpoTab,"X3_PICTURE")
Local lPicture := Iif(Empty(cPicture),.F.,.T.)

If lSub
	If cTipo == "D" // Tipo do campo
		TCSetField(SUB, cCpoQry 	, "D") //Muda o tipo do campo para data.
		cValor   := AllTrim(AllToChar((SUB)->&(cCpoQry))) //Conte�do a ser gravado
	ElseIf cTipo == "M"
		DbSelectArea(cTabela)
		(cTabela)->(dbGoTo((SUB)->&(cCpoQry))) // Esse seek � para retornar o valor de um campo MEMO
		cValor := AllTrim(AllToChar((cTabela)->&(cCpoTab) )) //Retorna o valor do campo
	ElseIf cTipo == "O" // Lista de op��es
		cValor := JTrataCbox( cCpoTab, AllTrim(AllToChar((SUB)->&(cCpoQry))) ) //Retorna o valor do campo
	ElseIf cTipo == "N"
		TcSetField(SUB, cCpoQry, 'N', TamSX3(cCpoTab)[1], TamSX3(cCpoTab)[2] )
		If lPicture
			cValor   := TRANSFORM((SUB)->&(cCpoQry), cPicture)
			cValor   := AllTrim(CVALTOCHAR(cValor)) //Conte�do a ser gravado
		Else
			cValor := AllTrim(CVALTOCHAR((SUB)->&(cCpoQry)))
		EndIf
	Else
		cValor := AllTrim(AllToChar((SUB)->&(cCpoQry)))
	EndIf
Else 
	If cTipo == "D" // Tipo do campo
		TCSetField(TMP, cCpoQry 	, "D") //Muda o tipo do campo para data.
		cValor   := AllTrim(AllToChar((TMP)->&(cCpoQry))) //Conte�do a ser gravado
	ElseIf cTipo == "M"
		DbSelectArea(cTabela)
		(cTabela)->(dbGoTo((TMP)->&(cCpoQry))) // Esse seek � para retornar o valor de um campo MEMO
		cValor := AllTrim(AllToChar((cTabela)->&(cCpoTab) )) //Retorna o valor do campo
	ElseIf cTipo == "O" // Lista de op��es
		cValor := JTrataCbox( cCpoTab, AllTrim(AllToChar((TMP)->&(cCpoQry))) ) //Retorna o valor do campo
	ElseIf cTipo == "N"
		TcSetField(TMP, cCpoQry, 'N', TamSX3(cCpoTab)[1], TamSX3(cCpoTab)[2] )
		If lPicture
			cValor   := TRANSFORM((TMP)->&(cCpoQry), cPicture)
			cValor   := AllTrim(CVALTOCHAR(cValor)) //Conte�do a ser gravado
		Else
			cValor := AllTrim(CVALTOCHAR((TMP)->&(cCpoQry)))
		EndIf
	Else
		cValor := AllTrim(AllToChar((TMP)->&(cCpoQry)))
	EndIf
EndIf

Return cValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JImpSub(cQuerySub, TMP, aSessao, nLinCalc,lQuebPag, aRelat, aCabec, oPrint, nLin, lTitulo, lLinTit)
Imprime o sub relat�rio
 
Uso Geral.

@param cQuerySub  Query do sub Relat�rio
@param TMP         Alias aberto da query principal 
@param aSessao    Dados do conte�do do relat�rio
@param nLinCalc   Vari�vel de c�lculo de linhas
@param lQuebPag   Indica se deve existir quebra de pagina
@param aRelat     Dados do t�tulo do relat�rio
@param aCabec     Dados do cabe�alho do relat�rio
@param oPrint     Objeto do Relat�rio (TMSPrinter)
@param nLin       Linha Corrente
@param lTitulo    Indica se o titulo de ser impresso
@param lLinTit    Indica se a linha onde ser� impresso o titulo foi definida 

@return nil

@author Jorge Luis Branco Martins Junior
@since 18/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JImpSub(cQuerySub, TMP, aSessao, nLinCalc,lQuebPag, aRelat, aCabec, oPrint, nLin, lTitulo, lLinTit, lUltSes)
Local nJ           := 0
Local xValor       // Valor do campo
Local nConta       := 0
Local nLinFinal    := 0
Local cValor       := ""
Local cVar         := ""  // CAMPO
Local lTitSes      := .F. // Indica se j� imprimiu o t�tulo da sess�o
Local aDados       := {}
Local cTitSes      := aSessao[1]
Local lHori        := aSessao[4]
Local cTxt         := cQuerySub
Local SUB          := GetNextAlias()

While RAT("#@", cTxt) > 0 // Substitui os nomes dos campos passados na query por seus respectivos valores
	cVar     := SUBSTR(cTxt,AT("@#", cTxt) + 2,AT("#@", cTxt) - (AT("@#", cTxt) + 2))
	xValor   := (TMP)->(FieldGet(FieldPos(cVar)))
	cTxt     := SUBSTR(cTxt, 1,AT("@#", cTxt)-1) + ALLTRIM(xValor) + SUBSTR(cTxt, AT("#@", cTxt)+2)
End

cQuerySub := cTxt
cQuerySub := ChangeQuery(cQuerySub)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySub),SUB,.T.,.T.)

lUltSes := .F.

If (SUB)->(!EOF()) //.And. lIncLin
	If nLin+80 >= nFimL // Verifica se a linha corrente � maior que linha final permitida por p�gina
		oPrint:EndPage() // Se for maior, encerra a p�gina atual
		ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho
		nLinCalc := nLin // Inicia o controle das linhas impressas
		lTitulo := .T. // Indica que o t�tulo pode ser impresso 
		lLinTit := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
	EndIf
	oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relat�rio
	oPrint:Line( nLin, nColIni, nLin, nColFim ) // Imprime uma linha na horizontal no relat�rio
	nLin += 30 //Adiciona uma linha em branco ap�s a linha impressa
	nLinCalc := nLin
EndIf

While (SUB)->(!EOF())
	lUltSes := .T. //Indica que a sess�o atual tem registros - Usada na constru��o da pr�xima sess�o
	If nLin+80 >= nFimL // Verifica se a linha corrente � maior que linha final permitida por p�gina
		oPrint:EndPage() // Se for maior, encerra a p�gina atual
		ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho
		nLinCalc := nLin // Inicia o controle das linhas impressas
		lTitulo := .T. // Indica que o t�tulo pode ser impresso 
		lLinTit := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
	EndIf
		nLinCalc := nLin
		nLinCalc2 := nLinCalc // Backup da pr�xima linha a ser usada, pois na fun��o JDadosCpo abaixo a variavel tem seu conte�do alterado para
		                      // que seja realizada uma simula��o das linhas usadas para impress�o do conte�do. 
		
		For nJ := 6 to Len(aSessao) // L� as informa��es de cada campo a ser impresso. O contador come�a em 7 pois � a partir dessa posi��o que est�o as informa��es sobre o campo
			
			nLinFinal := 0 // Limpa a vari�vel
						
			cTabela  := aSessao[nJ][2] //Tabela
			cCpoTab  := aSessao[nJ][3] //Nome do campo na tabela
			cCpoQry  := aSessao[nJ][4] //Nome do campo na query
			cTipo    := aSessao[nJ][5] //Tipo do campo
			cValor   := JTrataVal(cTabela,cCpoTab,cCpoQry,cTipo,,SUB,.T.) // Retorna o conte�do/valor a ser impresso. Chama essa fun��o para tratar o valor caso seja um memo ou data
			
			aAdd(aDados,JDadosCpo(aSessao[nJ],cValor,@nLinCalc,@lQuebPag)) // T�tulo e conte�do de cada campo s�o inseridos do array com os dados para serem impressos abaixo
		Next
		
		nLinCalc := nLinCalc2 // Retorno do valor original da vari�vel

		If lTitulo .And. (!Empty(cTitSes) .And. !(cTitSes $ "Env|TotalPed|TotalCus|TotalGar")) // As sess�es indicadas na condi��o n�o ter�o seus t�tulos impressos
			If (nLin + 80) >= nFimL // Verifica se o t�tulo da sess�o cabe na p�gina
				oPrint:EndPage() // Se for maior, encerra a p�gina atual
				ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho
				nLinCalc := nLin // Inicia o controle das linhas impressas
				lTitulo := .T. // Indica que o t�tulo pode ser impresso 
				lLinTit := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
			EndIf
			If !lTitSes
				JImpTitSes(@oPrint, @nLin, @nLinCalc, aSessao) //Imprime o t�tulo da sess�o no relat�rio
				lTitSes := .T.
			EndIf
		EndIf

		If !lHori // Caso a impress�o dos t�tulos seja na vertical - Todos os t�tulos na mesma linha e os conte�dos vem em colunas abaixo dos t�tulos (Ex: Relat�rio de andamentos)
			// Os t�tulos devem ser impressos
			lTitulo := .T. // Indica que o t�tulo pode ser impresso 
			lLinTit := .F. // Essa vari�vel indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
		EndIf

		nConta  := 1

		//Imprime os campos do relat�rio
		JImpRel(aDados,@nLin,@nLinCalc,@oPrint, @nLinFinal,lHori, @lTitulo, @lLinTit, aRelat,aCabec)
		
		//Limpa array de dados
		aSize(aDados,0)
		aDados := {}

		If nLinFinal > 0
			nLinCalc := nLinFinal //Indica a maior ref�ncia de uso de linhas para que sirva como refer�ncia para come�ar a impress�o do pr�ximo registro
		EndIf
		
		nLinFinal := 0 // Limpa a vari�vel
		
		nLin := nLinCalc
	
	(SUB)->(DbSkip())
End

aSize(aDados,0)

(SUB)->(dbCloseArea())

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JDadosCpo(aSessao, cValor, nLinCalc, lQuebPag)
Fun��o para montar array com as descri��es e conte�dos dos campos que ser�o impressos, 
assim como suas coordenadas, fontes e quebra de linha ap�s a impress�o de cada campo. 
 
Uso Geral.

@param aSessao  Dados do conte�do do relat�rio
@param cValor   Conte�do do campo que ser� impresso
@param nLinCalc Vari�vel de c�lculo de linhas
@param lQuebPag Indica se deve existir quebra de pagina

@return aDados Array com a Sess�o formatada

@author Jorge Luis Branco Martins Junior
@since 18/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JDadosCpo(aSessao, cValor, nLinCalc, lQuebPag)
Local aDados    := {}
Local cTitulo   := ""
Local nPosTit   := 0
Local oFontTit  := Nil
Local nPos      := 0
Local nQtdCar   := 0
Local oFontVal  := Nil
Local nPosValor := 0
Local lQuebLin  := .F.

cTitulo  := aSessao[1] //T�tulo da Coluna
nPosTit  := aSessao[6] //Indica a coordenada horizontal em pixels ou caracteres
oFontTit := aSessao[8] //Fonte do t�tulo
nPos     := aSessao[6] //Indica a coordenada horizontal para imprimir o valor do campo
nQtdCar  := aSessao[7] //Quantidade de caracteres para que seja feita a quebra de linha
oFontVal := aSessao[9] //Fonte usada para impress�o do conte�do
nPosValor:= aSessao[10] //Fonte usada para impress�o do conte�do
lQuebLin := aSessao[11] //Indica se deve existir a quebra de linha

If !lQuebPag // Verifica se ser� necess�ria quebra de p�gina para essa sess�o
	lQuebPag := ((Int((Len(cValor)/nQtdCar) + 1) * nSalto) + nLinCalc) > nFimL
	nLinCalc += (Int((Len(cValor)/nQtdCar) + 1) * nSalto) // Indica a linha que ser� usada para cada valor quando forem impressos - Usado apenas para uma simula��o.
EndIf

aDados := {cTitulo, nPosTit, oFontTit, cValor, nQtdCar, oFontVal, nPos, nPosValor, lQuebLin}

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} JImpRel(aDados, nLin, nLinCalc, oPrint, nLinFinal, lHori, lTitulo, lLinTit, aRelat, aCabec, lSalta)
Fun��o que trata as quebras de pagina e imprime as Sess�es na vertical e horizontal 
 
Uso Geral.

@param aDados    Array com a Sess�o formatada
@param nLin      Linha Corrente
@param nLinCalc  Vari�vel de c�lculo de linhas
@param oPrint    Objeto do Relat�rio (TMSPrinter)
@param nLinFinal Ultima linha que tem conte�do impresso 
@param lHori     Indica se impress�o ser� na horizontal ou vertical
@param lTitulo   Indica se o titulo deve ser impresso
@param lLinTit   Indica se a linha onde ser� impresso o titulo foi definida
@param aRelat    Dados do t�tulo do relat�rio
@param aCabec    Dados do cabe�alho do relat�rio 
@param lSalta    Indica se precisa continuar a impress�o do conte�do atual na pr�xima p�gina

@return nil

@author Jorge Luis Branco Martins Junior
@since 18/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JImpRel(aDados, nLin, nLinCalc, oPrint, nLinFinal, lHori, lTitulo, lLinTit, aRelat, aCabec, lSalta, lRecursivo)
Local nJ        := 0
Local lQuebLin  := .F.
Local lImpTit   := .T.
Local cTitulo   := ""
Local cValor    := ""
Local nPosTit   := 0
Local nPos      := 0
Local nQtdCar   := 0
Local nPosValor := 0
Local nLinTit   := 0
Local nLinAtu   := 0
Local aSobra    := aClone(aDados)
Local oFontTit
Local oFontVal

Default lSalta  := .F.
Default lHori   := .T.
Default lRecursivo := .F.

If lRecursivo
	aSobra[4] := ""
Else
	aEval(aSobra,{|x| x[4] := ""}) // Limpa a posi��o de conte�do/valor dos campos no array de sobra, pois ele � preenchido com os dados do array aDados. Limpa para que seja preenchido com o conte�do da sobra.
EndIf

If lSalta // Se for continua��o de impress�o do conte�do que n�o coube na p�gina anterior 
	lImpTit := .F. // Indica que os t�tulos n�o precisam ser impressos
	lSalta  := .F. // Limpa vari�vel
EndIf

For nJ := 1 to Len(aDados)

If lRecursivo
	cTitulo  := aDados[1] //T�tulo da Coluna
	nPosTit  := aDados[2] //Indica a coordenada horizontal em pixels ou caracteres
	oFontTit := aDados[3] //Fonte do t�tulo
	cValor   := aDados[4] //Valor a ser impresso
	nQtdCar  := aDados[5] //Quantidade de caracteres para que seja feita a quebra de linha
	oFontVal := aDados[6] //Fonte usada para impress�o do conte�do
	nPos     := aDados[7] //Indica a coordenada horizontal para imprimir o valor do campo
	nPosValor:= aDados[8] + nPos //Indica a coordenada horizontal para imprimir o valor do campo
	lQuebLin := aDados[9] // Indica se deve existir quebra de linha ap�s a impress�o do campo
Else
	cTitulo  := aDados[nJ][1] //T�tulo da Coluna
	nPosTit  := aDados[nJ][2] //Indica a coordenada horizontal em pixels ou caracteres
	oFontTit := aDados[nJ][3] //Fonte do t�tulo
	cValor   := aDados[nJ][4] //Valor a ser impresso
	nQtdCar  := aDados[nJ][5] //Quantidade de caracteres para que seja feita a quebra de linha
	oFontVal := aDados[nJ][6] //Fonte usada para impress�o do conte�do
	nPos     := aDados[nJ][7] //Indica a coordenada horizontal para imprimir o valor do campo
	nPosValor:= aDados[nJ][8] + nPos //Indica a coordenada horizontal para imprimir o valor do campo
	lQuebLin := aDados[nJ][9] // Indica se deve existir quebra de linha ap�s a impress�o do campo
EndIf
If cTitulo == STR0005	//"Nome Fantasia:"
	lTitulo := .T.
EndIf
If cTitulo == STR0035	//"Unidade:"
	cValor := JTpUni(cValor)
EndIf
If cTitulo == STR0033	//"Ult. Consolida��o:"
	lTitulo := .T.
EndIf

	If lHori// Impress�o na horizontal -> t�tulo e descri��o na mesma linha (Ex: Data: 01/01/2016)
		If lImpTit
			nLinTit  := nLin
			nLinCalc := nLin
			oPrint:Say( nLinTit, nPosTit, cTitulo, oFontTit)// Imprime os t�tulos das colunas
		EndIf
	Else // Impress�o na vertical -> Todos os t�tulos na mesma linha e os conte�dos vem em colunas abaixo dos t�tulos (Ex: Data
	     //                                                                                                                01/01/2016 )
		
		If !Empty(cTitulo) .And. lImpTit // Essa vari�vel indica se deve imprimir o t�tulo dos campos - Ser� .F. somente quando ocorrer quebra de um conte�do em mais de uma p�gina (lSalta == .T.).
			If !lLinTit // Como a linha onde ser� impresso o t�tulo dos campos ainda n�o foi definida entrar� nessa condi��o
				nLinTit  := nLin
				nLin     += nSalto
				nLinCalc := nLin
				lLinTit := .T. // Indica que a linha onde ser� impresso o t�tulo dos campos j� foi definida e n�o ser� mais alterada
			EndIf
			
			If lTitulo // Indica que o t�tulo pode ser impresso
				oPrint:Say( nLinTit, nPosTit, cTitulo, oFontTit)// Imprime os t�tulos das colunas
				
				lTitulo := Len(aDados) <> nJ // Enquanto estiver preenchendo os t�tulos indica .T., para que os outros t�tulos sejam impressos. 
				                             // Ap�s o preenchimento do �ltimo t�tulo indica .F., n�o premitindo mais a impress�o dos t�tulos nessa p�gina.
				                             
				// Deve imprimir apenas uma vez por p�gina para que a letra n�o fique mais grossa.
				// Se n�o tiver esse tratamento a impress�o ser� feita v�rias vezes sobre a mesma palavra devido as condi��es do la�o, 
				// fazendo com que a grossura das letras nas palavras aumente e isso atrapalha.
				
			EndIf
		EndIf
		nPosValor := nPosTit // Indica que a posi��o (coluna) do conte�do/valor a ser impresso � a mesma que foi impresso o titulo, ou seja, o conte�do/valor ficar� logo abaixo do t�tulo
	EndIf

	nLinAtu := nLinCalc // Controle de linhas usadas para imprimir o conte�do atual

	JImpLin(@oPrint,@nLinAtu,nPosValor,cValor,oFontVal,nQtdCar,@aSobra[nJ], @lSalta, lImpTit) //Imprime as linhas com os conte�dos/valores

	// Verifica qual campo precisou de mais linhas para ser impresso
	// para usar esse valor como refer�ncia para come�ar a impress�o do pr�ximo registro
	If nLinAtu > nLinFinal
		nLinFinal := nLinAtu
	EndIf

	If lSalta .And. lQuebLin // Se precisa continuar a impress�o do conte�do atual na pr�xima p�gina 
		oPrint:EndPage() // Finaliza a p�gina atual
		ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho na pr�xima p�gina
		nLinCalc  := nLin // Inicia o controle das linhas a serem impressas
		nLinAtu   := nLinCalc // Atualiza vari�vel linha atual
		lQuebPag  := .F. // Indica que n�o � necess�rio ocorrer a quebra de pagina, pois j� est� sendo quebrada nesse momento.
		lTitulo   := .T. // Indica que o t�tulo pode ser impresso 
		lLinTit   := .F. // Indica que a linha de impress�o do t�tulo precisa ser definida, pois iniciar� uma nova linha.
		nLinFinal := 0 // Limpa vari�vel de controle da �ltima linha impressa.
		
		// Imprime o restante do conte�do que n�o coube na p�gina anterior.
		JImpRel(aSobra,@nLin,@nLinCalc,@oPrint, @nLinFinal,lHori, @lTitulo, @lLinTit, aRelat,aCabec, @lSalta)
		aEval(aSobra,{|x| x[4] := ""})
	EndIf

	If lQuebLin // Indica que � necess�ria quebra de linha, ou seja, o pr�ximo campo ser� impresso na pr�xima linha
		If nLinFinal >= nLin // Se a pr�xima linha a ser impressa (nLin) for menor que a �ltima linha que tem conte�do impresso (nLinFinal)
			nLin     := nLinFinal // Deve-se indicar a maior refer�ncia
		Else
			nLin     += nSalto // Caso contr�rio, pule uma linha.
		EndIf
		
		If nLin >= nFimL
			oPrint:EndPage() // Se for maior, encerra a p�gina atual
			ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho
			nLinCalc := nLin // Inicia o controle das linhas impressas
			lTitulo := .T. // Indica que o t�tulo pode ser impresso 
			lLinTit := .F. // Indica que a linha de impress�o do t�tulo precisa ser definida, pois iniciar� uma nova linha.
			nLinFinal := 0 // Limpa vari�vel de controle da �ltima linha impressa.
		Else
			nLinTit  := nLin // Recebe a pr�xima linha dispon�vel para impress�o do t�tulo
			nLinCalc := nLin // Atualiza vari�vel de c�lculo de linhas
			lLinTit  := .F.  // Indica que a linha de impress�o do t�tulo precisa ser definida, pois iniciar� uma nova linha.
		EndIf
	EndIf
	If lRecursivo
		Exit
	EndIf
Next nJ

If lSalta // Se precisa continuar a impress�o do conte�do atual na pr�xima p�gina 
	oPrint:EndPage() // Finaliza a p�gina atual
	ImpCabec(@oPrint, @nLin, aRelat, aCabec) // Cria um novo cabe�alho na pr�xima p�gina
	nLinCalc  := nLin // Inicia o controle das linhas a serem impressas
	nLinAtu   := nLinCalc // Atualiza vari�vel linha atual
	lQuebPag  := .F. // Indica que n�o � necess�rio ocorrer a quebra de pagina, pois j� est� sendo quebrada nesse momento.
	lTitulo   := .T. // Indica que o t�tulo pode ser impresso 
	lLinTit   := .F. // Indica que a linha de impress�o do t�tulo precisa ser definida, pois iniciar� uma nova linha.
	nLinFinal := 0 // Limpa vari�vel de controle da �ltima linha impressa.
	
	// Imprime o restante do conte�do que n�o coube na p�gina anterior.
	JImpRel(aSobra,@nLin,@nLinCalc,@oPrint, @nLinFinal,lHori, @lTitulo, @lLinTit, aRelat,aCabec, @lSalta)
EndIf

aSize(aSobra,0)

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JImpLin(oPrint, nLinAtu, nPosValor, cTexto, oFontVal, nQtdCar, aSobra, lSalta, lImpTit)
Fun��o para montar array de titulos das colunas
 
Uso Geral.

@param oPrint    Objeto do Relat�rio (TMSPrinter)
@param nLinAtu   Linha onde ser� impresso a pr�xima informa��o
@param nPosValor Posi��o do conte�do
@param cTexto    Conte�do completo de cada coluna
@param oFontVal  Fonte usada para impress�o do conte�do
@param nQtdCar   Quantidade de caracteres para que seja feita a quebra de linha
@param aSobra    Array com o valor que n�o coube em alguma das colunas da p�gina anterior, e falta ser impresso
@param lSalta    Indica se precisa continuar a impress�o do conte�do atual na pr�xima p�gina
@param lImpTit   Indica se o t�tulo precisa ser impresso

@return nil

@author Jorge Luis Branco Martins Junior
@since 18/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JImpLin(oPrint, nLinAtu, nPosValor, cTexto, oFontVal, nQtdCar, aSobra, lSalta, lImpTit)
Local nRazao    := oPrint:GetTextWidth( "oPrint:nPageWidth", oFontVal )
Local nTam      := (nRazao * nQtdCar) / 350
Local aCampForm := {} // Array com cada palavra a ser escrita.
Local cValor    := ""
Local cValImp   := "" // Valor impresso
Local nX        := 0

cTexto := StrTran(cTexto, Chr(13)+Chr(10), '')
cTexto := StrTran(cTexto, Chr(10), '')
aCampForm := STRTOKARR(cTexto, " ")

If Len(aCampForm) == 0 // Caso n�o exista conte�do/valor
	If lImpTit // E o t�tulo do campo foi impresso 
		oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal ) // Ser� inserida a linha com conte�do em branco
		nLinAtu += nSalto // Pula uma linha
	EndIf
Else // Caso exista conte�do/valor
	For nX := 1 To Len(aCampForm) // La�o para cada palavra a ser escrita
		If oPrint:GetTextWidth( cValor + aCampForm[nX], oFontVal ) <= nTam // Se a palavra atual for impressa e N�O passar do limite de tamanho da linha
			cValor += aCampForm[nX] + " " // Preenche a linha com a palavra atual
		
			If Len(aCampForm) == nX // Caso esteja na �ltima palavra
				oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal ) // Insere a linha com o conte�do que estava em cValor
				nLinAtu += nSalto // Pula para a pr�xima linha
			EndIf
	
		Else // Se a palavra atual for impressa e passar do limite de tamanho da linha
			oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal ) // Insere a linha com o conte�do que estava em cValor sem a palavra que ocasionou a quebra.
			nLinAtu += nSalto // Pula para a pr�xima linha
					
			If nLinAtu + 2*nSalto > nFimL // Se a pr�xima linha a ser impressa N�O couber na p�gina atual
				lSalta := .T. // Indica que precisa continuar a impress�o do conte�do atual na pr�xima p�gina 
				If Empty(SubStr(cTexto,Len(cValImp+cValor)+2,1))
					aSobra[4] := AllTrim(SubStr(cTexto,Len(cValImp+cValor)+3,Len(cTexto))) // Preenche o array aSobra com o valor que falta ser impresso
				ElseIf Empty(SubStr(cTexto,Len(cValImp+cValor)+1,1))
					aSobra[4] := AllTrim(SubStr(cTexto,Len(cValImp+cValor)+2,Len(cTexto))) // Preenche o array aSobra com o valor que falta ser impresso
				ElseIf Empty(SubStr(cTexto,Len(cValImp+cValor),1))
					aSobra[4] := AllTrim(SubStr(cTexto,Len(cValImp+cValor),Len(cTexto))) // Preenche o array aSobra com o valor que falta ser impresso
				EndIf
				Exit
			Else // Se a pr�xima linha a ser impressa couber na p�gina atual
				cValImp += cValor // Guarda todo o texto que j� foi impresso para que caso necessite de quebra o sistema saiba at� qual parte o texto j� foi impresso.
				cValor := aCampForm[nX] + " " // Preenche a linha com a palavra atual
			EndIf
			
			If Len(aCampForm) == nX
				oPrint:Say(nLinAtu,nPosValor,cValor, oFontVal ) // Insere a linha com o conte�do que estava em cValor sem a palavra que ocasionou a quebra.
				nLinAtu += nSalto // Pula para a pr�xima linha	
			EndIf
			
		EndIf
		
	Next
EndIf

//Limpa array
aSize(aCampForm,0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JImpTitSes()
Imprime o t�tulo da sess�o no relat�rio
 
Uso Geral.

@param cTabela  Nome da tabela
        cCpoTab  Nome do campo na tabela
        cCpoQry  Nome do campo na query
        cTipo    Tipo do campo
        TMP      Alias aberto

@return cValor Valor do campo na Query

@author Jorge Luis Branco Martins Junior
@since 18/01/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JImpTitSes(oPrint, nLin, nLinCalc, aSessao)
Local oBrush1

nLin := Iif (nLin<190,190,nLin)

oPrint:Box( nLin-20, nColIni, (nLin+30), nColFim)
oPrint:Box( nLin-20, nColIni, (nLin+30), nColFim)

oBrush1 := TBrush():New( , CLR_LIGHTGRAY )
oPrint:FillRect( {nLin-20, nColIni, (nLin + 30), nColFim}, oBrush1 )
oBrush1:End()
	
	//aSessao[1] - T�tulo da sess�o do relat�rio
	//aSessao[2] - Posi��o da descri��o
	//aSessao[3] - Fonte da sess�o
oPrint:Say( nLin+15, aSessao[2], aSessao[1], aSessao[3])
	
nLin+=80
nLinCalc := nLin

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JTpUni(cTipoUni)
Trata descri��o do tipo de unidade
 
Uso Geral.

@param cTipoUni Tipo de unidade

@Return cTipoUni Descri��o do tipo de unidade

@author Wellington Coelho
@since 18/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JTpUni(cTipoUni)

If cTipoUni == '1'
	cTipoUni := STR0039	//"Matriz"
ElseIf cTipoUni == '2'
	cTipoUni := STR0040	//"Filial"
EndIf
Return cTipoUni
