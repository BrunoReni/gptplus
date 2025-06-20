#INCLUDE "HSPAHRB6.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "REPORT.CH"  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHRB6  � Autor � Daniel Peixoto     � Data �  19/07/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Relatorio de Enderecos das Solicitacoes                    ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function HSPAHRB6()
 Local oReport
 Private cPerg := "HSPRB6"
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	Pergunte(cPerg, .F.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 Else  
  HSPAHRB6R3()  
 EndIf    
Return(Nil)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �REPORTDEF � Autor � DANIEL PEIXOTO        � Data � 19/07/06 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

 Local oReport
 Local oSection1
 Local aOrdem := {}
 
 oReport := TReport():New("HSPAHRB6",STR0001, cPerg, {|oReport| RB6Imp(oReport)}, STR0002)  //"Relat�rio de Endere�os"###"Este relat�rio tem por objetivo imprimir o relat�rio de endere�os de prontu�rio"
 oReport:SetTotalText(STR0003) //"Total Geral de Endere�os... "
 
 oSection1 := TRSection():New(oReport,STR0004,{"GSD"},/*aOrdem*/)  //"Endere�os"

 oCell := TRCell():New(oSection1,"GSD_CODEND","GSD")
 oCell := TRCell():New(oSection1,"GSD_DESEND","GSD")
 oCell := TRCell():New(oSection1,"GSD_TIPEND","GSD",,,,, { || HS_RDescrB("GSD_TIPEND", QRYGSD->GSD_TIPEND)} )
 oCell := TRCell():New(oSection1,"GSD_ENDRUA","GSD")
 oCell := TRCell():New(oSection1,"GSD_NUMERO","GSD")
 oCell := TRCell():New(oSection1,"GSD_PRLNUM","GSD")
 
Return(oReport)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � RB6Imp   � Autor � DANIEL PEIXOTO        � Data � 19/07/06 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function RB6Imp(oReport)
 Local cOrderBy := ""
 
 If mv_par03 == 1
  cOrderBy := "%GSD.GSD_CODEND%"
 ElseIf mv_par03 == 2
  cOrderBy := "%GSD.GSD_TIPEND%"
 EndIf

 MakeSqlExp(cPerg)
	
 oReport:Section(1):BeginQuery()
 
BeginSql alias "QRYGSD"
 
 SELECT GSD.GSD_CODEND, GSD.GSD_DESEND, GSD.GSD_TIPEND, GSD.GSD_ENDRUA, GSD.GSD_NUMERO, GSD.GSD_PRLNUM
 FROM %table:GSD% GSD
 WHERE GSD.GSD_CODEND BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
 ORDER BY %Exp:cOrderBy%
 
EndSql

 oReport:Section(1):EndQuery()
 	
	oReport:Section(1):Print()

Return()


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHRB6  � Autor � PAULO JOSE         � Data �  20/10/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Relatorio de Enderecos das Solicitacoes                    ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function HSPAHRB6R3

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cDesc1  := STR0006 //"Este programa tem como objetivo imprimir relat�rio "
Local cDesc2  := STR0007 //"de acordo com os par�metros informados pelo usu�rio."
Local cDesc3  := STR0001 //"Relat�rio de Endere�os"
Local cPict   := ""
Local titulo  := STR0001 //"Relat�rio de Endere�os"
Local nLin    := 80 
Local Cabec1  := STR0008 //"Endere�o                                  Tipo Endere�o                 Rua     Num.    Prateleira"
Local Cabec2  := " "
Local imprime := .T.
Local aOrd    := {}

Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 80
Private tamanho     := "M"     // P M G
Private nomeprog    := "HSPAHRB6" // nome do programa para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := {STR0009 , 1, STR0010, 2, 2, 1, "", 1}   //"Zebrado"###"Administra��o"
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "HSPAHRB6" // nome do arquivo usado para impressao em disco
Private cCodIni     := ""
Private cCodFin     := ""
Private nOrdem      := 0
Private cString     := "GSD"
Private cCodImp     := ""
Private nMaxLin     := 0 // quantidade maxima de linhas p/ impressao

//���������������������������������������������������������������������Ŀ
//� Monta a Perguntas para o usuario...                                 �
//�����������������������������������������������������������������������
 cPerg := "HSPRB6"

 If !Pergunte(cPerg, .T.)
  Return
 EndIf         

 nMaxLin := HS_MaxLin(cCodImp)
 nLin    := nMaxLin * 2
	 
 cCodIni := MV_PAR01
 cCodFin := MV_PAR02
 nOrdem  := MV_PAR03
	   
//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������

wnrel := SetPrint(cString, NomeProg, "", @titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho,, .T.)

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn, cString)

If nLastKey == 27
   Return
EndIf

nTipo := If(aReturn[4] == 1, 15, 18)

//���������������������������������������������������������������������Ŀ
//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
//�����������������������������������������������������������������������

RptStatus({|| RunReport(Cabec1, Cabec2, Titulo, nLin)}, Titulo)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � AP6 IDE            � Data �  20/10/04   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunReport(Cabec1, Cabec2, Titulo, nLin)

    //                             1         2         3         4         5         6         7         8         9        10        11        12        13
    //                   0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

 cSQL := "SELECT GSD.GSD_CODEND, GSD.GSD_TIPEND,	GSD.GSD_DESEND, GSD.GSD_ENDRUA, GSD.GSD_NUMERO, "   																		
 cSQL += "	GSD.GSD_PRLNUM "
 cSQL += " FROM " + RetSQLName("GSD") + " GSD "                                   
 cSQL += " WHERE GSD.GSD_FILIAL = '" + xFilial("GSD") + "' AND GSD.D_E_L_E_T_ <> '*' "
 cSQL += " AND GSD.GSD_CODEND BETWEEN '" + cCodIni + "' AND '" + cCodFin + "' "

 If nOrdem == 1 //Codigo
  cSQL += "ORDER BY GSD_CODEND"
 ElseIf nOrdem == 2 //Tipo.
  cSQL += "ORDER BY GSD_TIPEND"
 EndIf 
                         
 cSQL := ChangeQuery(cSQL)
 
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")

 DbGoTop()

 If EOF()
  HS_MsgInf(STR0011, STR0012, STR0013) //"Nenhum dado foi encontrado para a sele��o efetuada!"###"Aten��o"###"Verifique a sele��o"
 EndIf

 While !EOF() 
   
  If lAbortPrint
   @nLin, 000 PSAY STR0014 //"*** CANCELADO PELO OPERADOR ***"
   Exit
  EndIf  
  
  //���������������������������������������������������������������������Ŀ
  //� Impressao do cabecalho do relatorio. . .                            �
  //�����������������������������������������������������������������������
  If nLin > nMaxLin // Salto de P�gina. Neste caso o formulario tem 55 linhas...
   Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)   
   nLin := 8  
  EndIf

  @nLin, 000 Psay QRY->GSD_CODEND + " - " + SUBSTR(QRY->GSD_DESEND, 1, 25)
  @nLin, 042 Psay PADR(HS_RDescrB("GSD_TIPEND", QRY->GSD_TIPEND), 25) 
  @nLin, 072 Psay QRY->GSD_ENDRUA              
  @nLin, 080 Psay QRY->GSD_NUMERO             
  @nLin, 088 Psay QRY->GSD_PRLNUM
  nLin ++

  DbSkip() // passa para o proximo registro da tabela
   
 EndDo

 //���������������������������������������������������������������������Ŀ
 //� Finaliza a execucao do relatorio...                                 �
 //�����������������������������������������������������������������������
 DbSelectArea("QRY")
 DbCloseArea()

 SET DEVICE TO SCREEN

 //���������������������������������������������������������������������Ŀ
 //� Se impressao em disco, chama o gerenciador de impressao...          �
 //�����������������������������������������������������������������������

 If aReturn[5] == 1
  DbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 EndIf

 MS_FLUSH()

Return()