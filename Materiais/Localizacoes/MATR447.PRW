#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATR447.CH"

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR447  � Autor �  Alex Hdez.           � Data � 08/03/2016      ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o � Informe del catalogo de Impuestos de Importaci�n.(M�xico)         ���
��������������������������������������������������������������������������������Ĵ��
���Sintaxe   � MATR447()                                                         ���
��������������������������������������������������������������������������������Ĵ��
���               ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.              ���
��������������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                            ���
��������������������������������������������������������������������������������Ĵ��
���            �        �      �                                                 ���
���            �        �      �                                                 ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/

Function MATR447()

Local oReport
Local aGetArea  :=  GetArea()
Local lSalir    :=  .f. 
Private NomeProg:= STR0012//"MATR447"

If !TRepInUse()	//verifica se a op��o relat�rios personaliz�veis est� dispon�vel
	MSGSTOP(OEMTOANSI(STR0001) )//"Para usar este inform debe tener MP8 R4 en adelante!"
	lSalir:=.t.
endif          
if lSalir 
	RestArea(aGetArea)
	Return
endif

oReport := ReportDef()
oReport:PrintDialog()	
RestArea(aGetArea)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef   Autor � Alex Hdez.            � Data �08/03/2016���
�������������������������������������������������������������������������Ĵ��
���Descri��o �  Def. Reporte De Fracciones Arancelarias                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �  MATR447                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ReportDef()

Local   oReport, oSection1,oSection2
Local lAutomato  := IsBlind()
Private cTitulo	:= Trim(OEMTOANSI(STR0002)) //"Fracciones Arancelarias"

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������

If lAutomato
   NomeProg :="MATR447"
EndIf

oReport:=TReport():New(NomeProg,OemToAnsi(cTitulo), /*NomeProg */,{|oReport| PrintReport(oReport)})	
oReport:nColSpace := 3
oReport:nFontBody := 7 // Define o tamanho da fonte.
oReport:CFONTBODY :="COURIER NEW"
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

oSection1:= TRSection():New(oReport,STR0002,{"RSA"},{STR0003, STR0004, STR0005},/*Campos do SX3*/,/*Campos do SIX*/) //"Impuestos de Importaci�n"
oSection1:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection1:SetHeaderPage(.T.)	//Exibe Cabecalho da Secao

TRCell():New(oSection1,"RSA_CODIGO",      "RSA"   ,STR0003,            PesqPict("RSA","RSA_CODIGO"),    TamSx3("RSA_CODIGO")[1])//"C�digo"
TRCell():New(oSection1,"RSA_DESC",        "RSA"   ,STR0004 ,           PesqPict("RSA","RSA_DESC"),     TamSx3("RSA_DESC")[1])//"Descripcion"
TRCell():New(oSection1,"RSA_USOFRA",      "RSA"   ,STR0005,            PesqPict("RSA","RSA_USOFRA"),     15)//"Uso Fracc Ara?"
TRCell():New(oSection1,"RSA_TIPO",        "RSA"   ,STR0006,            PesqPict("RSA","RSA_TIPO"),      TamSx3("RSA_TIPO")[1])//"Cve. T. Tasa"
TRCell():New(oSection1,"RSA_TASIMP",      "RSA"	  ,STR0007,            PesqPict("RSA","RSA_TASIMP"),      TamSx3("RSA_TASIMP")[1])//"Tasa Imp." 
TRCell():New(oSection1,"RSA_IMPORT",     "RSA"	  ,STR0008,            PesqPict("RSA","RSA_IMPORT"),      TamSx3("RSA_IMPORT")[1])//"Importe" 
TRCell():New(oSection1,"RSA_FUNC",     "RSA"	  ,STR0009,            PesqPict("RSA","RSA_FUNC"),      TamSx3("RSA_FUNC")[1])//"Funci�n" 
 
Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PrintReport Autor �  Alex Hdez.           � Data �08/03/2016���
�������������������������������������������������������������������������Ĵ��
���Descri��o �   Impresi�n del Informe                                    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �    PrintReport(oExp)                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �  MATR447                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function PrintReport(oReport)

Local oSection1  := oReport:Section(1)
Local cTitle     := ""     
Local nTotal     := 0

//������������������������������������������������������������������Ŀ
//�  Altera o Titulo do Relatorio conforme o parametro selecionado   �
//��������������������������������������������������������������������
cTitle := If(AllTrim(oReport:Title())==AllTrim(cTitle), OemToansi(cTitulo),oReport:Title())
oReport:SetTitle(cTitle)

	DbSelectArea("RSA")
	count to nTotal
	oReport:SetMeter(nTotal) 
	If oReport:NORDER == 1
		RSA->(dbSetOrder(1)) //RSA_FILIAL + RSA_CODIGO
	ELSEIf oReport:NORDER == 2
		RSA->(dbSetOrder(2))//RSA_FILIAL + RSA_DESC
	ELSEIf oReport:NORDER == 3
	    RSA->(dbSetOrder(3))//RSA_FILIAL + RSA_USOFRA
	ENDIF
	dbseek(xFilial("RSA"))
	RSA->(DBGOTOP())
	
	osection1:init()
	
	While RSA->(!Eof()) .AND. !oReport:Cancel()
	    If  RSA->RSA_USOFRA == "1"
			oSection1:cell("RSA_USOFRA"):SetValue(STR0010)//"Si"
		Else
			oSection1:cell("RSA_USOFRA"):SetValue(STR0011)//"No"
		EndIf
		
		oSection1:printline()
		RSA->(DBSKIP())
		oReport:IncMeter()   //regla de avance
	EndDo
	
	oSection1:finish()  


Return ( Nil )


