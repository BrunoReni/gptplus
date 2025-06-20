#INCLUDE "GFER040.ch"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFER040
Relatorio de Documentos de Carga
Generico.

@sample
GFER040()

@author Felipe M.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFER040()
	Local oReport                   //objeto que contem o relatorio
	Local aArea := GetArea()

	Private cAliasGW1, cAliasGWB, cAliasGWU
	Private aGWUPagar  := {}
	Private aGW8Tribp  := {}

	If TRepInUse() // teste padr�o
		//-- Interface de impressao
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf

	RestArea( aArea )

Return

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} ReportDef
Relatorio de Documentos de Carga
Generico.

@sample
ReportDef()

@author Felipe M.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/

Static Function ReportDef()
	Local oReport, oSection1, oSection2, oSection3, oSection4, oFldHid
	Local aOrdem    := {}


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
	oReport:= TReport():New("GFER040","Listagem de Documentos de Carga","GFER040", {|oReport| ReportPrint(oReport)},STR0002)  //"Documentos de Carga"###"Emite Documentos de Carga conforme os par�metros informados."
	oReport:SetLandscape()   // define se o relatorio saira deitado
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
	oReport:SetTotalInLine(.F.)
	oReport:SetColSpace(2,.F.)
	Pergunte("GFER040",.F.)
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


	Aadd( aOrdem, STR0003 ) // "Sequ�ncia" //"Codigo"

	/*Para exibi��o do gest�o de empresas com tabela tempor�ria:
	Deve-se usar obrigatoriamente uma tabela e n�o um alias (tabela tempor�ria).
	Segundo o FW, � porque � necess�rio saber o modo de acesso da tabela utilizada para construir a op��o.
	Com isso, usa-se GW1 na cria��o da TRSection.

	Quando usado gest�o de empresa, o relat�rio � executado 1 vez para cada empresa/grupo/unidade de neg�cio/filial.
	Com isso, devee-se usar xFilial(tabela) para filtrar as informa��es pertinentes � filial em quest�o.
	Caso contr�rio, o relat�rio ser� impresso com documentos de todas as filiais v�rias vezes, sempre com o mesmo conte�do,
	diferenciando apenas o cabe�alho.

	O SQL ser� montado de forma a otimizar a sele��o dos dados, considerando xFilial(tabela) conforme mencionado acima.

	Na cria��o de TRCell, usa-se o campo e a tabela como par�metros de forma a ser usado descri��o, formato etc do campo
	na tela de configura��o do relat�rio, usada para escolher os campos a serem impressos.
	Tamb�m � usado na impress�o do relat�rio, como t�tulo do campo ou da coluna, dependendo da forma de impress�o. */

	oSection1 := TRSection():New(oReport,STR0004,{"GW1"},aOrdem)  //"Documento de Cargas". Usar GW1 e n�o (cAliasGW1) para que o gest�o de empresas seja exibido.
	oSection1:SetLineStyle() //Define a impressao da secao em linha
	oSection1:SetTotalInLine(.F.)
	TRCell():New(oSection1,"GW1_FILIAL","GW1",/*cTitle*/,/*Picture*/,/*Size*/,/*lPixel*/)
	TRCell():New(oSection1,"GW1_SERDC" ,"GW1",/*cTitle*/,/*Picture*/,/*Size*/,/*lPixel*/)
	TRCell():New(oSection1,"GW1_NRDC"  ,"GW1",/*cTitle*/,/*Picture*/,/*Size*/,/*lPixel*/)
	TRCell():New(oSection1,"GW1_EMISDC","GW1",/*cTitle*/,/*Picture*/,/*Size*/,/*lPixel*/)
	TRCell():New(oSection1,"cNMEMIS"   ,"GW1"   ,STR0005   ,"@!",51,/*lPixel*/, {|| (cAliasGW1)->cNmEmis })   //"Nome Emis"
	TRCell():New(oSection1,"GW1_CDTPDC","GW1",/*cTitle*/,/*Picture*/,/*Size*/,/*lPixel*/,)
	TRCell():New(oSection1,"GW1_DTEMIS","GW1",/*cTitle*/,/*Picture*/,/*Size*/,/*lPixel*/)
	TRCell():New(oSection1,"GW1_SIT"   ,"GW1",/*cTitle*/,/*Picture*/,/*Size*/,/*lPixel*/)
	TRCell():New(oSection1,"GW1_DTIMPL","GW1",/*cTitle*/,/*Picture*/,/*Size*/,/*lPixel*/)
	TRCell():New(oSection1,"GW1_CDREM" ,"GW1",STR0006   ,"@!",/*Size*/,/*lPixel*/) //"Remetente"
	TRCell():New(oSection1,"cNMFANREM" ,"GW1",STR0007 ,"@!",51,/*lPixel*/,{||(cAliasGW1)->cNMFANREM} ) 	//"Nome Remet."
	TRCell():New(oSection1,"cUFREM"    ,"GW1",STR0008   ,"@!",3,/*lPixel*/,{||(cAliasGW1)->cUFREM} ) 	//"UF Remet."
	TRCell():New(oSection1,"GW1_CDDEST","GW1",STR0009,"@!",/*Size*/,/*lPixel*/) 		//"Destinatario"
	TRCell():New(oSection1,"cNMFANDEST","GW1",STR0010  ,"@!",51,/*lPixel*/,{||(cAliasGW1)->cNMFANDEST} ) 	//"Nome Dest."
	TRCell():New(oSection1,"cUFDEST"   ,"GW1",STR0011   ,"@!",3,/*lPixel*/,{||(cAliasGW1)->cUFDEST} ) 	//"UF Dest.."
	TRCell():New(oSection1,"GW1_NRROM","GW1",/*cTitle*/,/*Picture*/,/*Size*/,/*lPixel*/)
	TRCell():New(oSection1,"dDTSAID"  ,"GW1","Dt Sa�da","@!"       ,11      ,/*lPixel*/,{||SToD((cAliasGW1)->dDTSAID)} )
	TRCell():New(oSection1,"cHRSAID"  ,"GW1","Hr Sa�da","@!"       ,6       ,/*lPixel*/,{||(cAliasGW1)->cHRSAID      } )

	/***************************************************************************/

	oSection2 := TRSection():New(oSection1,STR0012,{"GW8"},aOrdem) //  //"Itens dos Documentos"
	oSection2:SetTotalInLine(.F.)
	oSection2:SetHeaderSection(.T.) //Define que imprime cabe�alho das c�lulas na quebra de se��o

	TRCell():New(oSection2,"GW8_ITEM"   ,"(cAliasGW1)",/*cTitle*/,/*Picture*/,TamSX3("GW8_ITEM")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_ITEM })
	TRCell():New(oSection2,"GW8_DSITEM" ,"(cAliasGW1)",/*cTitle*/,/*Picture*/,TamSX3("GW8_DSITEM")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_DSITEM })
	TRCell():New(oSection2,"GW8_CDCLFR" ,"(cAliasGW1)",/*cTitle*/,/*Picture*/,TamSX3("GW8_CDCLFR")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_CDCLFR })
	TRCell():New(oSection2,"GW8_QTDE"   ,"(cAliasGW1)",/*cTitle*/,/*Picture*/,TamSX3("GW8_QTDE")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_QTDE })
	TRCell():New(oSection2,"GW8_VOLUME" ,"(cAliasGW1)",/*cTitle*/,/*Picture*/,TamSX3("GW8_VOLUME")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_VOLUME })
	TRCell():New(oSection2,"GW8_PESOR"  ,"(cAliasGW1)",/*cTitle*/,/*Picture*/,TamSX3("GW8_PESOR")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_PESOR })
	TRCell():New(oSection2,"GW8_PESOC"  ,"(cAliasGW1)",/*cTitle*/,/*Picture*/,TamSX3("GW8_PESOC")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_PESOC })
	TRCell():New(oSection2,"GW8_VALOR"  ,"(cAliasGW1)",/*cTitle*/,/*Picture*/,TamSX3("GW8_VALOR")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_VALOR })

	oFldHid�:=�TRCell():New(oSection2,"GW8_QTDALT","GW8",/*cTitle*/,/*Picture*/,TamSX3("GW8_QTDALT")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_QTDALT })
	oFldHid:lUserEnabled�:=�.F.
	oFldHid�:=�TRCell():New(oSection2,"GW8_INFO1","GW8",/*cTitle*/,/*Picture*/,TamSX3("GW8_INFO1")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_INFO1 })
	oFldHid:lUserEnabled�:=�.F.
	oFldHid�:=�TRCell():New(oSection2,"GW8_INFO2","GW8",/*cTitle*/,/*Picture*/,TamSX3("GW8_INFO2")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_INFO2 })
	oFldHid:lUserEnabled�:=�.F.
	oFldHid�:=�TRCell():New(oSection2,"GW8_INFO3","GW8",/*cTitle*/,/*Picture*/,TamSX3("GW8_INFO3")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_INFO3 })
	oFldHid:lUserEnabled�:=�.F.
	oFldHid�:=�TRCell():New(oSection2,"GW8_INFO4","GW8",/*cTitle*/,/*Picture*/,TamSX3("GW8_INFO4")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_INFO4 })
	oFldHid:lUserEnabled�:=�.F.
	oFldHid�:=�TRCell():New(oSection2,"GW8_INFO5","GW8",/*cTitle*/,/*Picture*/,TamSX3("GW8_INFO5")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_INFO5 })
	oFldHid:lUserEnabled�:=�.F.
	oFldHid�:=�TRCell():New(oSection2,"GW8_UNINEG","GW8",/*cTitle*/,/*Picture*/,TamSX3("GW8_UNINEG")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_UNINEG })
	oFldHid:lUserEnabled�:=�.F.
	oFldHid�:=�TRCell():New(oSection2,"GW8_RATEIO","GW8",/*cTitle*/,/*Picture*/,TamSX3("GW8_RATEIO")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_RATEIO })
	oFldHid:lUserEnabled�:=�.F.
	oFldHid�:=�TRCell():New(oSection2,"GW8_TPITEM","GW8",/*cTitle*/,/*Picture*/,TamSX3("GW8_TPITEM")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_TPITEM })
	oFldHid:lUserEnabled�:=�.F.
	oFldHid�:=�TRCell():New(oSection2,"GW8_TRIBP","GW8",/*cTitle*/,/*Picture*/,TamSX3("GW8_TRIBP")[1]+1,/*lPixel*/,{|| GetSX3cBox("GW8_TRIBP", (cAliasGW1)->GW8_TRIBP) })
	oFldHid:lUserEnabled�:=�.F.
	oFldHid�:=�TRCell():New(oSection2,"GW8_ATUATF","GW8",/*cTitle*/,/*Picture*/,TamSX3("GW8_ATUATF")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_ATUATF })
	oFldHid:lUserEnabled�:=�.F.
	oFldHid�:=�TRCell():New(oSection2,"GW8_CRDICM","GW8",/*cTitle*/,/*Picture*/,TamSX3("GW8_CRDICM")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_CRDICM })
	oFldHid:lUserEnabled�:=�.F.
	oFldHid�:=�TRCell():New(oSection2,"GW8_DIFICM","Gw8",/*cTitle*/,/*Picture*/,TamSX3("GW8_DIFICM")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_DIFICM })
	oFldHid:lUserEnabled�:=�.F.
	oFldHid�:=�TRCell():New(oSection2,"GW8_CFOP","GW8",/*cTitle*/,/*Picture*/,TamSX3("GW8_CFOP")[1]+1,/*lPixel*/,{|| (cAliasGW1)->GW8_CFOP })
	oFldHid:lUserEnabled�:=�.F.

	/*************************************************************************/

	oSection3 := TRSection():New(oSection1,STR0013,{"(cAliasGWB)"},aOrdem) // //"Unitizadores"
	oSection3:SetTotalInLine(.F.)
	oSection3:SetHeaderSection(.T.) //Define que imprime cabe�alho das c�lulas na quebra de se��o
	TRCell():New(oSection3,"GWB_CDUNIT" ,"(cAliasGWB)",/*cTitle*/,/*Picture*/,TamSx3("GWB_CDUNIT")[1]+1,/*lPixel*/,{|| (cAliasGWB)->GWB_CDUNIT })
	TRCell():New(oSection3,"cDSUNIT" ,"(cAliasGWB)",STR0014,"@!",51,/*lPixel*/,{|| cDSUNIT }) //"Descri��o Unit."
	TRCell():New(oSection3,"GWB_QTDE"   ,"(cAliasGWB)",/*cTitle*/,/*Picture*/,TamSx3("GWB_QTDE")[1]+1,/*lPixel*/,{|| (cAliasGWB)->GWB_QTDE })

	/**************************************************************************/

	oSection4 := TRSection():New(oSection1,STR0015,{"(cAliasGWU)"},aOrdem) //  //"Trechos do Itiner�rio"
	oSection4:SetTotalInLine(.F.)
	oSection4:SetHeaderSection(.T.) //Define que imprime cabe�alho das c�lulas na quebra de se��o
	//oSection4:lVisible := .F.
	TRCell():New(oSection4,"GWU_SEQ"   ,"(cAliasGWU)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasGWU)->GWU_SEQ })
	TRCell():New(oSection4,"GWU_CDTRP" ,"(cAliasGWU)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasGWU)->GWU_CDTRP })
	TRCell():New(oSection4,"cNMTRP"    ,"(cAliasGWU)",STR0016   ,"@!",51,/*lPixel*/, {||(cAliasGWU)->cNMTRP}) //"Nome Transp."
	TRCell():New(oSection4,"GWU_NRCIDD","(cAliasGWU)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasGWU)->GWU_NRCIDD })
	TRCell():New(oSection4,"cNMCIDD"   ,"(cAliasGWU)","Cidade Destino"  ,"@!",51,/*lPixel*/, {||(cAliasGWU)->cNMCIDD}) //"Nome Transp."
	TRCell():New(oSection4,"GWU_DTPENT","(cAliasGWU)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| sToD((cAliasGWU)->GWU_DTPENT) })
	TRCell():New(oSection4,"GWU_DTENT" ,"(cAliasGWU)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| sToD((cAliasGWU)->GWU_DTENT) })
	TRCell():New(oSection4,"GWU_PAGAR" ,"(cAliasGWU)",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| GetSX3cBox("GWU_PAGAR", (cAliasGWU)->GWU_PAGAR) })

Return(oReport)
/*************************************************************************************************************************************/


/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} ReportPrint
Relatorio de Documentos de Carga
Generico.

@sample
ReportPrint(oReport,cAliasQry)

@author Felipe M.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function ReportPrint(oReport)
	Local oSection1  := oReport:Section(1)
	Local oSection2  := oReport:Section(1):Section(1)
	Local oSection3  := oReport:Section(1):Section(2)
	Local oSection4  := oReport:Section(1):Section(3)
	Local aSelFil	   := {}
	Local cAliasTot, cQuery, cSelect, cCount, cOrderBy, cFiltroSit
	Local lPrint

	//DC Atual
	Local cFilDcAtu	:= ''
	Local cCdTpDcAtu	:= ''
	Local cEmisDcAtu	:= ''
	Local cSerDcAtu	:= ''
	Local cNrDcAtu 	:= ''

	Private cAliasGW1
	Private cAliasGWB
	Private cAliasGWU
	Private aGWUPagar  := {}
	Private aGW8Tribp  := {}

	//Carrega o array com os campos que tem c�digo/descri��o (combobox)
	CrtSX3cBox()

	cFiltroSit := "''"
	cFiltroSit += If (MV_PAR19==1,",'1'","")
	cFiltroSit += If (MV_PAR20==1,",'2'","")
	cFiltroSit += If (MV_PAR21==1,",'3'","")
	cFiltroSit += If (MV_PAR22==1,",'4'","")
	cFiltroSit += If (MV_PAR23==1,",'5'","")
	cFiltroSit += If (MV_PAR24==1,",'6'","")
	cFiltroSit += If (MV_PAR25==1,",'7'","")

	aSelFil := oReport:GetGCList() //Utilizado pelo bot�o gest�o de empresas, caso houver

	cAliasGW1 := GetNextAlias()
	cAliasTot := GetNextAlias()
	cAliasGWB := GetNextAlias()
	cAliasGWU := GetNextAlias()

	cCount := "SELECT COUNT(*) nCount "

	cSelect := "GW1.*, GWN.GWN_DTSAI dDTSAID, GWN.GWN_HRSAI cHRSAID, TRANSP.GU3_NMEMIT cNMEMIS, "
	cSelect += "REM.GU3_NMFAN cNMFANREM, CIDREM.GU7_CDUF cUFREM, "
	cSelect += "DEST.GU3_NMFAN cNMFANDEST, CIDDEST.GU7_CDUF cUFDEST "
	cSelect += ", GW8.* "

	cQuery := " FROM " + RetSQLName("GW1") + " GW1 "

	cQuery += "LEFT JOIN " + RetSQLName("GWN") + " GWN "
	If GFXCP1212210('GW1_FILROM')
		cQuery += "ON GWN.GWN_FILIAL = GW1.GW1_FILROM "
	Else
		cQuery += "ON GWN.GWN_FILIAL = GW1.GW1_FILIAL "
	EndIf
	cQuery += "AND GWN.GWN_NRROM = GW1.GW1_NRROM "
	cQuery += "AND GWN.GWN_DTSAI >= '" + DTOS(MV_PAR13) + "' AND GWN.GWN_DTSAI  <= '" + DTOS(MV_PAR14) + "' "
	cQuery += "AND GWN.D_E_L_E_T_ = ' ' "

	cQuery += "INNER JOIN " + RetSQLName("GU3") + " TRANSP ON "
	cQuery += "TRANSP.GU3_FILIAL = '" + xFilial("GU3") + "' "
	cQuery += "AND TRANSP.GU3_CDEMIT = GW1.GW1_EMISDC "
	cQuery += "AND TRANSP.D_E_L_E_T_ = ' ' "

	cQuery += "INNER JOIN " + RetSQLName("GU3") + " REM ON "
	cQuery += "REM.GU3_FILIAL = '" + xFilial("GU3") + "' "
	cQuery += "AND REM.GU3_CDEMIT = GW1.GW1_CDREM "
	cQuery += "AND REM.D_E_L_E_T_ = ' ' "

	cQuery += "INNER JOIN " + RetSQLName("GU7") + " CIDREM ON "
	cQuery += "CIDREM.GU7_FILIAL = '" + xFilial("GU7") + "' "
	cQuery += "AND CIDREM.GU7_NRCID = REM.GU3_NRCID "
	cQuery += "AND CIDREM.D_E_L_E_T_ = ' ' "

	cQuery += "INNER JOIN " + RetSQLName("GU3") + " DEST ON "
	cQuery += "DEST.GU3_FILIAL = '" + xFilial("GU3") + "' "
	cQuery += "AND DEST.GU3_CDEMIT = GW1.GW1_CDDEST "
	cQuery += "AND DEST.GU3_NRCID >= '" + MV_PAR28 + "' "
	cQuery += "AND DEST.GU3_NRCID <= '" + MV_PAR29 + "' "
	cQuery += "AND DEST.D_E_L_E_T_ = ' ' "

	cQuery += "INNER JOIN " + RetSQLName("GU7") + " CIDDEST ON "
	cQuery += "CIDDEST.GU7_FILIAL = '" + xFilial("GU7") + "' "
	cQuery += "AND CIDDEST.GU7_NRCID = DEST.GU3_NRCID "
	cQuery += "AND CIDDEST.GU7_CDUF >= '" + MV_PAR30 + "' "
	cQuery += "AND CIDDEST.GU7_CDUF <= '" + MV_PAR31 + "' "
	cQuery += "AND CIDDEST.D_E_L_E_T_ = ' ' "

	cQuery += "INNER JOIN " + RetSQLName("GW8") + " GW8 ON "
	cQuery += "GW8.GW8_FILIAL = GW1.GW1_FILIAL "
	cQuery += "AND GW8.GW8_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += "AND GW8.GW8_EMISDC = GW1.GW1_EMISDC "
	cQuery += "AND GW8.GW8_SERDC = GW1.GW1_SERDC "
	cQuery += "AND GW8.GW8_NRDC = GW1.GW1_NRDC "

	cQuery += "WHERE GW1.GW1_FILIAL >= '" + MV_PAR01 + "' AND GW1.GW1_FILIAL <= '" + MV_PAR02 + "' "
	cQuery += "AND GW1.GW1_EMISDC   >= '" + MV_PAR03 + "' AND GW1.GW1_EMISDC <= '" + MV_PAR04 + "' "
	cQuery += "AND GW1.GW1_SERDC    >= '" + MV_PAR05 + "' AND GW1.GW1_SERDC  <= '" + MV_PAR06 + "' "
	cQuery += "AND GW1.GW1_NRDC     >= '" + MV_PAR07 + "' AND GW1.GW1_NRDC   <= '" + MV_PAR08 + "' "
	cQuery += "AND GW1.GW1_DTEMIS   >= '" + DTOS(MV_PAR09) + "' AND GW1.GW1_DTEMIS <= '" + DTOS(MV_PAR10) + "' "
	cQuery += "AND GW1.GW1_SIT IN (" + AllTrim(cFiltroSit) + ") "
	cQuery += "AND GW1.D_E_L_E_T_ = ' ' "

	If !Empty(aSelFil)
		cQuery += "AND GW1.GW1_FILIAL = '" + xFilial("GW1") + "' "
	EndIf

	//FILTRO DAS ROTAS.
	//Para OpenEdge dever� ser usado select individual para filtrar itens e trechos, pois a execu��o em uma �nica query 
	//ocasionava um erro na compara��o de string, tanto com >=/<= quando BETWEEN.
	If !(AllTrim(MV_PAR11) = "" .And. MV_PAR12 = "ZZZZZZZZZZZZZZ" .And. ;
		AllTrim(Dtos(MV_PAR15)) = "" .And. Dtos(MV_PAR16) = "20491231")	
		If TCGETDB() <> 'OPENEDGE'
			cQuery += "AND EXISTS (SELECT GWU.GWU_FILIAL FROM " + RetSQLName("GWU") + " GWU "
			cQuery += "WHERE GWU.GWU_FILIAL = GW1.GW1_FILIAL "
			cQuery += "AND GWU.GWU_CDTPDC   = GW1.GW1_CDTPDC "
			cQuery += "AND GWU.GWU_EMISDC   = GW1.GW1_EMISDC "
			cQuery += "AND GWU.GWU_SERDC    = GW1.GW1_SERDC "
			cQuery += "AND GWU.GWU_NRDC     = GW1.GW1_NRDC "
			cQuery += "AND GWU.GWU_CDTRP   >= '" + MV_PAR11 + "' "
			cQuery += "AND GWU.GWU_CDTRP   <= '" + MV_PAR12 + "' "
			cQuery += "AND GWU.GWU_DTENT   >= '" + Dtos(MV_PAR15) + "' "
			cQuery += "AND GWU.GWU_DTENT   <= '" + Dtos(MV_PAR16) + "' "
			cQuery += "AND GWU.D_E_L_E_T_ = ' ') "
		EndIf
	EndIf

	//FILTRO DOS ITENS DO DOC DE CARGA.
	//Para OpenEdge dever� ser usado select individual para filtrar itens e trechos, pois a execu��o em uma �nica query 
	//ocasionava um erro na compara��o de string, tanto com >=/<= quando BETWEEN.
	If !(AllTrim(MV_PAR17) = "" .And. MV_PAR18 = "99999" .And.;
		AllTrim(MV_PAR26) = "" .And. MV_PAR27 = "ZZZZZZZZZZZZZZZZ")	
		If TCGETDB() <> 'OPENEDGE'
			cQuery += "AND EXISTS (SELECT GW8.GW8_FILIAL FROM " + RetSQLName("GW8") + " GW8 "
			cQuery += "WHERE GW8.GW8_FILIAL = GW1.GW1_FILIAL "
			cQuery += "AND GW8.GW8_CDTPDC   = GW1.GW1_CDTPDC "
			cQuery += "AND GW8.GW8_EMISDC   = GW1.GW1_EMISDC "
			cQuery += "AND GW8.GW8_SERDC    = GW1.GW1_SERDC "
			cQuery += "AND GW8.GW8_NRDC     = GW1.GW1_NRDC "
			cQuery += "AND GW8.GW8_CDCLFR  >= '" + MV_PAR17 + "' "
			cQuery += "AND GW8.GW8_CDCLFR  <= '" + MV_PAR18 + "' "
			cQuery += "AND GW8.GW8_ITEM    >= '" + MV_PAR26 + "' "
			cQuery += "AND GW8.GW8_ITEM    <= '" + MV_PAR27 + "' "
			cQuery += "AND GW8.D_E_L_E_T_ = ' ')"
		EndIf
	EndIf

	cOrderBy := " ORDER BY GW1.GW1_FILIAL, GW1.GW1_CDTPDC, GW1.GW1_EMISDC, GW1.GW1_SERDC, GW1.GW1_NRDC"

	//Cursor cCount � usado para a barra de progress�o
	cCount := cCount + cQuery
	ChangeQuery(cCount)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cCount),cAliasTot, .F., .T.)
	dbSelectArea((cAliasTot))
	(cAliasTot)->( dbGoTop() )
	oReport:SetMeter ((cAliasTot)->nCount)

	//Deve ser incluso o "%" para o Protheus identificar como express�o
	cSelect := "%" + cSelect + cQuery + cOrderBy + "%"

	oSection1:BeginQuery()
		BeginSql Alias cAliasGW1
		SELECT %Exp:cSelect%
		EndSql
	oSection1:EndQuery()

	While !oReport:Cancel() .AND. !(cAliasGW1)->(Eof())
		lPrint := .T.		

		//Para OpenEdge dever� ser usado select individual para filtrar itens e trechos, pois a execu��o em uma �nica query 
		//ocasionava um erro na compara��o de string, tanto com >=/<= quando BETWEEN.	
		If TCGETDB() = 'OPENEDGE'
	
			If !(AllTrim(MV_PAR11) = "" .And. MV_PAR12 = "ZZZZZZZZZZZZZZ" .And. ;
				AllTrim(Dtos(MV_PAR15)) = "" .And. Dtos(MV_PAR16) = "20491231")
				cAliasQry := GetNextAlias()
				cQuery := " SELECT COUNT(*) AS QTD FROM " + RetSQLName("GWU")
				cQuery += " WHERE GWU_FILIAL = '" + (cAliasGW1)->GW1_FILIAL + "'"
				cQuery += " AND GWU_CDTPDC   = '" + (cAliasGW1)->GW1_CDTPDC + "'"
				cQuery += " AND GWU_EMISDC   = '" + (cAliasGW1)->GW1_EMISDC + "'"
				cQuery += " AND GWU_SERDC    = '" + (cAliasGW1)->GW1_SERDC  + "'"
				cQuery += " AND GWU_NRDC     = '" + (cAliasGW1)->GW1_NRDC   + "'"
				cQuery += " AND GWU_CDTRP   >= '" + MV_PAR11 + "'"
				cQuery += " AND GWU_CDTRP   <= '" + MV_PAR12 + "'"
				cQuery += " AND GWU_DTENT   >= '" + Dtos(MV_PAR15) + "'"
				cQuery += " AND GWU_DTENT   <= '" + Dtos(MV_PAR16) + "'"
				cQuery += " AND D_E_L_E_T_  <> '*'"

				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
				
				If (cAliasQry)->QTD = 0
					lPrint := .F.
				EndIf
				
				(cAliasQry)->(dbCloseArea())
			EndIf
						
			If lPrint .And.;
				!(AllTrim(MV_PAR17) = "" .And. MV_PAR18 = "99999" .And.;
				AllTrim(MV_PAR26) = "" .And. MV_PAR27 = "ZZZZZZZZZZZZZZZZ")	
				cAliasQry := GetNextAlias()
				cQuery := " SELECT COUNT(*) AS QTD FROM " + RetSQLName("GW8")
				cQuery += " WHERE GW8_FILIAL = '" + GW1->GW1_FILIAL + "'"
				cQuery += " AND GW8_CDTPDC   = '" + GW1->GW1_CDTPDC + "'"
				cQuery += " AND GW8_EMISDC   = '" + GW1->GW1_EMISDC + "'"
				cQuery += " AND GW8_SERDC    = '" + GW1->GW1_SERDC  + "'"
				cQuery += " AND GW8_NRDC     = '" + GW1->GW1_NRDC   + "'"
				cQuery += " AND GW8_CDCLFR  >= '" + MV_PAR17 + "'"
				cQuery += " AND GW8_CDCLFR  <= '" + MV_PAR18 + "'"
				cQuery += " AND GW8_ITEM    >= '" + MV_PAR26 + "'"
				cQuery += " AND GW8_ITEM    <= '" + MV_PAR27 + "'"
				cQuery += " AND D_E_L_E_T_  <> '*'"

				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

				If (cAliasQry)->QTD = 0 
					lPrint := .F.
				EndIf

				(cAliasQry)->(dbCloseArea())
			EndIf
		EndIf
		
		If lPrint

			//Sec��o 1
			//Essa valida��o � feita pois os itens s�o selecionados no mesmo cursor do doc. de carga.
			If (cAliasGW1)->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC) <> cFilDcAtu+cCdTpDcAtu+cEmisDcAtu+cSerDcAtu+cNrDcAtu
				cFilDcAtu	 := (cAliasGW1)->GW1_FILIAL
				cCdTpDcAtu	 := (cAliasGW1)->GW1_CDTPDC
				cEmisDcAtu	 := (cAliasGW1)->GW1_EMISDC
				cSerDcAtu	 := (cAliasGW1)->GW1_SERDC
				cNrDcAtu	 := (cAliasGW1)->GW1_NRDC

				oSection1:Init()
				oSection1:PrintLine()
			EndIf

			//Sec��o 2
			IIf (oSection2:lUserVisible = .T.,oSection2:Init(),)
			While !(cAliasGW1)->(EOF()) .And. (cAliasGW1)->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC) = cFilDcAtu+cCdTpDcAtu+cEmisDcAtu+cSerDcAtu+cNrDcAtu
				If oSection2:lUserVisible
					oSection2:PrintLine()
				EndIf

				(cAliasGW1)->(dbSkip())
			EndDo

			If oSection2:lUserVisible
				oSection2:Finish()
			EndIf

			//Sec��o 3
			If oSection3:lUserVisible = .T.
				cSelect := "SELECT GWB.*, GUG.GUG_DSUNIT cDSUNIT "
				cSelect += "FROM " + RetSQLName('GWB') + " GWB, " + RetSQLName('GUG') + " GUG "
				cSelect += "WHERE GWB.GWB_FILIAL = '" + cFilDcAtu + "' "
				cSelect += "AND GWB.GWB_CDTPDC   = '" + cCdTpDcAtu + "' "
				cSelect += "AND GWB.GWB_EMISDC   = '" + cEmisDcAtu + "' "
				cSelect += "AND GWB.GWB_SERDC    = '" + cSerDcAtu  + "' "
				cSelect += "AND GWB.GWB_NRDC     = '" + cNrDcAtu   + "' "
				cSelect += "AND GWB.D_E_L_E_T_  <> '*' "
				cSelect += "AND GUG.GUG_FILIAL   = '" + xFilial("GUG") + "' "
				cSelect += "AND GUG.GUG_CDUNIT   = GWB_CDUNIT "
				cSelect += "AND GUG.D_E_L_E_T_  <> '*' "

				ChangeQuery(cSelect)
				dbUseArea(.T., "TOPCONN", TCGENQRY(,,cSelect),cAliasGWB, .F., .T.)
				dbSelectArea((cAliasGWB))
				(cAliasGWB)->(dbGoTop())
				oSection3:Init()
				While !oReport:Cancel() .AND. !(cAliasGWB)->(Eof())
					oSection3:PrintLine()
					(cAliasGWB)->(dbSkip())
				EndDo
				oSection3:Finish()

				(cAliasGWB)->(dbCloseArea())
			EndIf

			//Sec��o 4
			If oSection4:lUserVisible = .T.
				cSelect := "SELECT GWU.*, GU3.GU3_NMEMIT cNMTRP, GU7.GU7_NMCID cNMCIDD "
				cSelect += "FROM " + RetSQLName('GWU') + " GWU, " + RetSQLName('GU3') + " GU3, " + RetSQLName('GU7') + " GU7 "
				cSelect += "WHERE GWU.GWU_FILIAL = '" + cFilDcAtu + "' "
				cSelect += "AND GWU.GWU_CDTPDC   = '" + cCdTpDcAtu + "' "
				cSelect += "AND GWU.GWU_EMISDC   = '" + cEmisDcAtu + "' "
				cSelect += "AND GWU.GWU_SERDC    = '" + cSerDcAtu  + "' "
				cSelect += "AND GWU.GWU_NRDC     = '" + cNrDcAtu   + "' "
				cSelect += "AND GWU.D_E_L_E_T_  <> '*' "
				cSelect += "AND GU3.GU3_FILIAL   = '" + xFilial("GU3") + "' "
				cSelect += "AND GU3.GU3_CDEMIT   = GWU_CDTRP "
				cSelect += "AND GU3.D_E_L_E_T_  <> '*' "
				cSelect += "AND GU7.GU7_FILIAL   = '" + xFilial("GU7") + "' "
				cSelect += "AND GU7.GU7_NRCID    = GWU_NRCIDD "
				cSelect += "AND GU7.D_E_L_E_T_  <> '*' "

				ChangeQuery(cSelect)
				dbUseArea(.T., "TOPCONN", TCGENQRY(,,cSelect),cAliasGWU, .F., .T.)
				dbSelectArea((cAliasGWU))
				(cAliasGWU)->(dbGoTop())
				oSection4:Init()
				While !oReport:Cancel() .AND. !(cAliasGWU)->(Eof())
					oSection4:PrintLine()
					(cAliasGWU)->(dbSkip())
				EndDo
				oSection4:Finish()
				(cAliasGWU)->(dbCloseArea())
			EndIf
		Else
			(cAliasGW1)->(dbSkip())		
		EndIf

    	oReport:Skipline()
    	oReport:IncMeter()

	EndDo

	oSection1:Finish()

	(cAliasGW1)->(dbCloseArea())
	(cAliasTot)->(dbCloseArea())

Return

/*/--------------------------------------------------------------------------------------------------
Fun��o criada para carregar em arrays os campos que s�o c�digo/descri��o.
Isso evita de fazer um select para cada DC impresso.
--------------------------------------------------------------------------------------------------/*/
Static Function CrtSX3cBox()
Local cBox

	cBox := GetSx3Cache("GWU_PAGAR","X3_CBOX")
	aGWUPagar := StrToKArr(cBox, ";")
	
	cBox := GetSx3Cache("GW8_TRIBP","X3_CBOX")
	aGW8Tribp := StrToKArr(cBox, ";")

Return nil

/*/--------------------------------------------------------------------------------------------------
Fun��o criada para ler a descri��o de um campo a partir do c�digo para um determinado campo.
Isso evita de fazer um select para cada DC impresso.
--------------------------------------------------------------------------------------------------/*/
Static Function GetSX3cBox(cCampo, cValor)

	Do Case
		Case Upper(cCampo) == "GWU_PAGAR"
			Return GetArVal(aGWUPagar, cValor)
		Case Upper(cCampo) == "GW8_TRIBP"
			Return GetArVal(aGW8Tribp, cValor)
	EndCase

Return ''

/*/--------------------------------------------------------------------------------------------------
Fun��o criada para procurar um c�digo em um array passado por par�metro e retornar a descri��o.
Permite a reutiliza��o de c�digo.
--------------------------------------------------------------------------------------------------/*/
Static Function GetArVal(aArray, cValor)
Local nInd

	For nInd := 1 To Len(aArray)
		If Substr(aArray[nInd], 1, At("=",aArray[nInd]) - 1) == cValor
			Return Substr(aArray[nInd], At("=",aArray[nInd]) + 1, Len(aArray[nInd]))
		EndIf
	Next nInd

Return ''
