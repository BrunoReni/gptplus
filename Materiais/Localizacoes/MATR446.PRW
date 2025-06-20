#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATR446.CH"

/*���������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR446  � Autor �  Alex Hdez.           � Data �   08/03/2016   ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o � Informe del catalogo de Fracciones Arancelarias.(Mexico)         ���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe   � MATR446()                                                        ���
�������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                   ���
�������������������������������������������������������������������������������Ĵ��
���Programador � Data   � ISSUE    � Motivo da Alteracao                        ���
�������������������������������������������������������������������������������Ĵ��
���Jose Glez   �28/11/17�DMINA-1217�Se agrega validacion para detectar si       ���
���            �        �	       �la rutina se ejecuta de manera automatica   ���
���            �        �          �y no mostrar cuadros de usuario.            ���
���            �        �          �                                            ���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/
Function MATR446()

	Local oReport
	Local aGetArea		:= GetArea()
	Local lSalir		:= .F. 
	
	Private NomeProg	:= STR0009 //"MATR446" 

	If !TRepInUse()	//verifica se a op��o relat�rios personaliz�veis est� dispon�vel
		MsgStop(OemToAnsi(STR0001) )//"Para usar este inform debe tener MP8 R4 en adelante!"
		lSalir := .T.
	EndIf          
	If lSalir 
		RestArea(aGetArea)
		Return
	EndIf

	oReport := ReportDef()
	oReport:PrintDialog()	
	RestArea(aGetArea)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef   Autor �  Alex Hdez.           � Data �23/03/2016���
�������������������������������������������������������������������������Ĵ��
���Descri��o �  Def. Reporte De Fracciones Arancelarias                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �  MATR446                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

	Local oReport, oSection1, oSection2
	Local oBreak
	Local NProg    := "MATR446"
	Local lAutomato  := IsBlind()
	
	Private cTitulo := OemToAnsi(Trim(STR0002)) //"Fracciones Arancelarias"


	//������������������������������������������������������������������������Ŀ
	//�Criacao do componente de impressao                                      �
	//�TReport():New                                                           �
	//�ExpC1 : Nome do relatorio                                               �
	//�ExpC2 : Titulo                                                          �
	//�ExpC3 : Pergunte                                                        �
	//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
	//�ExpC5 : Descricao                                                       �
	//��������������������������������������������������������������������������
  If !lAutomato 
	Pergunte(NomeProg)
	oReport:=TReport():New(NomeProg, OemToAnsi(cTitulo), NomeProg, {|oReport| PrintReport(oReport)})	
  else
    Pergunte(NProg)
 	oReport:=TReport():New(NProg, OemToAnsi(cTitulo), NProg, {|oReport| PrintReport(oReport)})
  endif
	oReport:nColSpace := 3
	oReport:nFontBody := 7 // Define o tamanho da fonte.
	oReport:CFONTBODY := "COURIER NEW"

	//������������������������������������������������������������������������Ŀ
	//�Criacao da celulas da secao do relatorio                                �
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
	//��������������������������������������������������������������������������
	//��������������������������������������������������������������������������Ŀ
	//� Criacao da Primeira Secao: Encabezado                                    �
	//���������������������������������������������������������������������������� 
	oSection1 := TRSection():New(oReport, STR0008, {"RSB"}, , /*Campos do SX3*/, /*Campos do SIX*/) //"Fracciones Arancelarias"


	oSection1:SetHeaderPage(.T.)	//Exibe Cabecalho da Secao

	TRCell():New(oSection1, "RSB_FRACC"	, "RSB", STR0003, PesqPict("RSB", "RSB_FRACC")	, TamSx3("RSB_FRACC")[1]) //"Fraccion"
	TRCell():New(oSection1, "RSB_DESC"	, "RSB", STR0004, PesqPict("RSB", "RSB_DESC")	, TamSx3("RSB_DESC"	)[1]) //"Descripcion"
	TRCell():New(oSection1, "RSB_TASA"	, "RSB", STR0005, PesqPict("RSB", "RSB_TASA")	, TamSx3("RSB_TASA"	)[1]) //"% de Tasa"
	TRCell():New(oSection1, "RSB_UMT"	, "RSB", STR0006, PesqPict("RSB", "RSB_UMT")	, TamSx3("RSB_UMT"	)[1]) //"UMC" 

	//����������������������������������Ŀ
	//� Define a 2a. secao do relatorio	 �
	//������������������������������������
	oSection2 := TRSection():New( oSection1, STR0010, {"SYB"})
	oSection2:SetHeaderSection(.F.)	//Exibe Cabecalho da Secao
	oSection2:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
	TRCell():New(oSection2, STR0012    ,,,,,,{|| OemToAnsi(STR0012)}) //"Pais :"
	TRCell():New(oSection2, "YA_CODGI" , "SYA", STR0010, PesqPict("SYA","YA_CODGI") , TamSx3("YA_CODGI")[1]) 
	TRCell():New(oSection2, STR0011    ,,,,,,{|| OemToAnsi(STR0011)},,,,) //" - "
	TRCell():New(oSection2, "YA_DESCR" , "SYA", STR0004, PesqPict("SYA","YA_DESCR") , TamSx3("YA_DESCR")[1]) 

Return(oReport)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PrintReport Autor � Alex Hdez.            � Data �23/03/2016���
�������������������������������������������������������������������������Ĵ��
���Descri��o �   Impresi�n del Informe                                    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �    PrintReport(oExp)                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �  MATR446                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function PrintReport(oReport)

	Local oSection1		:= oReport:Section(1)
	Local oSection2		:= oReport:Section(1):Section(1)
	Local cTitle		:= ""     
	Local nTotal		:= 0
	Local cAliasQry		:= GetNextAlias()
	Local cOrder		:= "%" + "RSB_FILIAL, RSB_PAIS, RSB_FRACC"  + "%"
	Local cPais			:= ""

	//������������������������������������������������������������������Ŀ
	//�  Altera o Titulo do Relatorio conforme o parametro selecionado   �
	//��������������������������������������������������������������������

	cTitle := If(AllTrim(oReport:Title())==AllTrim(cTitle), OemToansi(cTitulo),oReport:Title())
	oReport:SetTitle(cTitle)

	oSection1:BeginQuery()
	oSection2:BeginQuery()
	
	BeginSql alias cAliasQry
	SELECT RSB_FRACC ,RSB_DESC ,RSB_TASA ,RSB_UMT, RSB_PAIS, SYA.YA_CODGI, SYA.YA_DESCR
	FROM %table:RSB% RSB
	INNER JOIN %table:SYA% SYA ON
	RSB.RSB_PAIS = SYA.YA_CODGI 
	WHERE RSB.RSB_FILIAL =  %xfilial:RSB%  AND
	RSB.RSB_PAIS >= %exp:mv_par01% AND
	RSB.RSB_PAIS <= %exp:mv_par02% AND
	RSB.RSB_FRACC >= %exp:mv_par03% AND
	RSB.RSB_FRACC <= %exp:mv_par04% AND
	RSB.%notDel%
	ORDER BY %exp:cOrder%
	EndSql

	oSection1:EndQuery()
	oSection2:SetParentQuery()//EndQuery()
	oSection1:Init()

	oReport:SetMeter((cAliasQry)->(LastRec()))

	While !(cAliasQry)->(EOF()) .And. !oReport:Cancel()
		If (cAliasQry)->(RSB_PAIS) <> cPais
			oReport:SkipLine(1)
			oSection2:Init()	
			oSection2:PrintLine()
			oReport:SkipLine(1)
			cPais := (cAliasQry)->(RSB_PAIS)
		EndIf
		oSection1:PrintLine()
		(cAliasQry)->(DBSkip())
		oReport:IncMeter()
	EndDo
	oSection2:Finish() 	
	oSection1:Finish()  

Return (Nil)