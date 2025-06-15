/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA099
Envio Pr�-Fatura ERP
Generico.

@sample
GFER099()

@author Felipe Mendes
@since 01/08/2011
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA099()
	Local oReport                   //objeto que contem o relatorio

	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()

Return      
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA099
Envio Pr�-Fatura ERP
Generico.

@sample
ReportDef()

@author Felipe Mendes
@since 01/08/2011
@version 1.0
--------------------------------------------------------------------------------------------------/*/

Static Function ReportDef()
	Local oReport, oSection1
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
	oReport:= TReport():New("GFEA099","Envio Pr�-Fatura","GFEA099", {|oReport| ReportPrint(oReport)},"Envio Pr�-Fatura")  
	oReport:SetLandscape()   // define se o relatorio saira deitado
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
	oReport:SetTotalInLine(.F.)
	oReport:nFontBody	:= 10 // Define o tamanho da fonte.
	oReport:nLineHeight	:= 50 // Define a altura da linha.

	If !IsBlind()
		Pergunte("GFEA099", .F.)
	EndIf

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


	//Aadd( aOrdem, "Codigo" ) // "Sequ�ncia"

	oSection1 := TRSection():New(oReport,"Envio Pr�-Fatura",{"GWJ"},aOrdem)  //"Documentos de Frete"
	oSection1:SetLineStyle() //Define a impressao da secao em linha
	oSection1:SetTotalInLine(.F.)
	TRCell():New(oSection1,"GWJ_NRPF"  , "GWJ", , /**/, , /*lPixel*/, /*{|| code-block de impressao }*/) 
	TRCell():New(oSection1,"GWJ_CDTRP" , "GWJ", , /**/, , /*lPixel*/, /*{|| code-block de impressao }*/) 
	TRCell():New(oSection1,"GWJ_CDTRP" , "GWJ", , /**/, , /*lPixel*/, /*{|| code-block de impressao }*/) 
	TRCell():New(oSection1,"GWJ_NMTRP"      ,  ""  , , /**/, , /*lPixel*/, {|| POSICIONE("GU3",1,XFILIAL("GU3")+GWJ->GWJ_CDTRP,"GU3_NMEMIT") }) 
	TRCell():New(oSection1,"GWJ_SIT"   , "GWJ", , /**/, , /*lPixel*/, /*{|| code-block de impressao }*/) 
	TRCell():New(oSection1,"GWJ_DTVCTO", "GWJ", , /**/, , /*lPixel*/, /*{|| code-block de impressao }*/) 
	TRCell():New(oSection1,"GWJ_DTIMPL", "GWJ", , /**/, , /*lPixel*/, /*{|| code-block de impressao }*/) 

	/*************************************************************************/ 

Return(oReport)
/*************************************************************************************************************************************/   
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA099
Envio Pr�-Fatura 
Generico.

@sample
ReportPrint(oReport,cAliasQry)

@author Felipe Mendes
@since 01/08/11                             
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local dData := Date()
	Local s_DTULFE := SuperGetMv("MV_DTULFE",,"20000101")

	If !Empty(MV_PAR10)
		dData := MV_PAR10
	EndIf

	If MV_PAR09 != 3 .And. dData <= s_DTULFE
		Return
	EndIf

	dbSelectArea("GWJ")
	GWJ->( dbSetOrder(1) )
	GWJ->( dbSeek(MV_PAR01, .T.) )

	oSection1:Init()
	While !GWJ->( Eof() ) .And. GWJ->GWJ_FILIAL >= MV_PAR01 .And. GWJ->GWJ_FILIAL <= MV_PAR02

		If GWJ->GWJ_CDTRP  >= MV_PAR03 .And. GWJ->GWJ_CDTRP  <= MV_PAR04 .And. ;
		GWJ->GWJ_NRPF   >= MV_PAR05 .And. GWJ->GWJ_NRPF   <= MV_PAR06 .And. ;
		GWJ->GWJ_DTIMPL >= MV_PAR07 .And. GWJ->GWJ_DTIMPL <= MV_PAR08 .And. ;
		GWJ->GWJ_SIT    == "3" .And. ; // Somente pr�-faturas confirmadas devem ser enviadas       
		((GWJ->GWJ_SITFIN == "1" .And. MV_PAR09 == 1) .Or. (GWJ->GWJ_SITFIN == "3" .And. MV_PAR09 == 2) .Or. ;
		(GWJ->GWJ_SITFIN == "4" .And. MV_PAR09 == 3)) .And. ;
		IIf(MV_PAR09 == 3, Empty(GWJ->GWJ_DTFIN) .Or. GWJ->GWJ_DTFIN > s_DTULFE, .T.) .And. !Empty(GWJ->GWJ_DTVCTO)

			If GFEA099In(dData)
				oSection1:PrintLine()
			EndIf

		EndIf

		GWJ->( dbSkip() )
	EndDo

	oSection1:Finish()
	Return

	//---------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} GFEA99In()
	Fun��o utilizada em Integra��o.
	Generico

	@sample
	GFEA99In()

	@author Felipe Mendes
	@since 01/08/2011
	@version 1.0
	/*///------------------------------------------------------------------------------------------------
Function GFEA099In(dData)
	Local aRet

	If MV_PAR09 == 3
		aRet := GFEA055In("5")
	Else
		aRet := GFEA055In("2",dData)
	EndIf

Return aRet[1]

