#INCLUDE "HSPAHRA0.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"
                                   
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � HSPAHRA0 � Autor � DANIEL PEIXOTO     � Data �  18/07/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � RELATORIO DA AGENDA AMBULATORIAL                           ���
���          � ESTATISTICA DAS MARCACOES NO PERIODO                       ���
�������������������������������������������������������������������������͹��
���Uso       � GESTAO HOSPITALAR.                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function HSPAHRA0()

Local oReport
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	If FunName() <> "HSPAHM29"
  	Pergunte("HSPRA0",.F.)
  Else
   MV_PAR01 := "01" 
   MV_PAR02 := "01" 
   MV_PAR03 := M->GM8_DATAGE
   MV_PAR04 := M->GM8_DATAGE
   MV_PAR05 := 1
  EndIf                                                
  oReport := ReportDef() 
  oReport:PrintDialog()  
 Else  
  HSPAHRA0R3()  
 EndIf    
 
Return(Nil) 

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �REPORTDEF � Autor � DANIEL PEIXOTO        � Data � 14/07/06 ���
��������������������������������������������������������������������������ٲ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

 Local oReport 
 Local oSection1, oSection2
 Local oCell
 Local oTotaliz1, oTotaliz2
 Local aOrdem  := {}
 Local cTitulo := ""
 Local bFormula

 cTitulo := HS_MontCabe(STR0008, MV_PAR03, MV_PAR04)  //"Marca��o no Per�odo" 
 
 oReport := TReport():New("HSPAHRA0", OemToAnsi(cTitulo), "HSPRA0", {|oReport| RA0IMP(oReport)}, "Este relatorio tem por objetivo a impressao da estatistica das marca��es ambulatoriais.")
 oReport:SetTotalText("Total Geral de Marca��es... ") // texto impresso antes da somatoria de oTotaliz
 
 oSection1 := TRSection():New(oReport, OemToAnsi("Usuario"), {"GM8"}, /*aOrdem*/)
 oCell := TRCell():New(oSection1, "GM8_CODUSU", "GM8", "Usu�rio")                           
 oCell := TRCell():New(oSection1, "TOTUSU", "   ", "Qtde"    , "@E 999,999", 7,, { || QRYGM8->TOTUSU })
 oCell := TRCell():New(oSection1, "PERUSU", "   ", "Perc.(%)", "@E 999.999", 7,, { || (QRYGM8->TOTUSU / nTotGer) * 100 })
 
 oTotaliz1 := TRFunction():new(oSection1:Cell("TOTUSU"), "TOTUSU", "SUM"    ,,"Total de Marcacoes    ==>",/*cPicture*/,/*uFormula*/, .F.)	

Return(oReport)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � RA0Imp   � Autor � DANIEL PEIXOTO        � Data � 18/07/06 ���
��������������������������������������������������������������������������ٲ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function RA0IMP(oReport)

Local cOrder  := "%%"
Local cCond   := "%%"
Local cCodUsu := ""

Private nTotGer := 0

 //������������������������������������������������������������������������Ŀ
 //�Transforma parametros Range em expressao SQL                            �
 //��������������������������������������������������������������������������
 MakeSqlExpr("HSPRA0")

		//������������������������������������������������������������������������Ŀ
		//�Query do relat�rio da secao 1                                           �
		//��������������������������������������������������������������������������
	oReport:Section(1):BeginQuery()		
 If MV_PAR05 == 1 
   cOrder := "%GM8_FILAGE, GM8_CODUSU%" 
 Else
   cOrder := "%GM8_FILAGE, TOTUSU DESC%" 
 EndIf 
 
 cCond := "%GM8_STATUS IN ('1','3','4','5','6')%"
 
	BeginSql Alias "QRYGM8"
 	SELECT COUNT(*) AS TOTGER
  FROM %table:GM8% GM8
  WHERE GM8_FILIAL = %xFilial:GM8% AND GM8.%NotDel%
        AND GM8_FILAGE BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
        AND GM8_DATCAD BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
        AND %Exp:cCond%
 EndSql 	
	
 oReport:Section(1):EndQuery(/*ExpA1*/)
 nTotGer := QRYGM8->TOTGER
 DbCloseArea()
	
	BeginSql Alias "QRYGM8"
 	SELECT GM8.GM8_FILAGE, GM8.GM8_CODUSU, COUNT(*) AS TOTUSU
  FROM %table:GM8% GM8
  WHERE GM8_FILIAL = %xFilial:GM8% AND GM8.%NotDel%
        AND GM8_FILAGE BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
        AND GM8_DATCAD BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
        AND %Exp:cCond%
  GROUP BY GM8_FILAGE, GM8_CODUSU 
  ORDER BY %Exp:cOrder%
 EndSql 	
	//������������������������������������������������������������������������Ŀ
	//�Metodo EndQuery ( Classe TRSection )                                    �
	//�                                                                        �
	//�Prepara o relat�rio para executar o Embedded SQL.                       �
	//�                                                                        �
	//�ExpA1 : Array com os parametros do tipo Range                           �
	//��������������������������������������������������������������������������
	oReport:Section(1):EndQuery(/*ExpA1*/)

	oReport:Section(1):SetParentQuery()
	
 oReport:SetMeter(RecCount())
 DbSelectArea("QRYGM8")
 oReport:Section(1):Init(.T.)

 Do While !QRYGM8->(Eof())
 	If oReport:Cancel()
	 	Exit
	 EndIf

	 If cCodUsu <> QRYGM8->GM8_CODUSU
   oReport:Section(1):PrintLine()			
   cCodUsu := QRYGM8->GM8_CODUSU
	 EndIf
	 
  oReport:IncMeter()
  QRYGM8->(dbskip())
 Enddo

oReport:Section(1):Finish()
 

Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � HSPAHRA0 � Autor � GILSON DA SILVA    � Data �Janeiro/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � RELATORIO DA AGENDA AMBULATORIAL                           ���
���          � ESTATISTICA DAS MARCACOES NO PERIODO                       ���
�������������������������������������������������������������������������͹��
���Uso       � GESTAO HOSPITALAR.                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function HSPAHRA0R3()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relat�rio "
 Local cDesc2 := STR0002 //"de acordo com os par�metros informados pelo usu�rio."
 Local cDesc3 := ""
 Local Titulo := STR0003 //"Estat�stica das Marca��es no Per�odo"
 Local Cabec1 := ""
 Local Cabec2 := STR0006 //"Usu�rio                                                  Qtde.                %"
 Local aOrd   := {}
 Local aArea  := GetArea()

 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 80
 Private tamanho     := "P"
 Private nomeprog    := "HSPAHRA0"
 Private nTipo       := 15
 Private aReturn     := {STR0004, 1, STR0005, 1, 2, 1, "", 1} //"Zebrado"###"Administra��o"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private m_pag       := 01
 Private wnrel       := "HSPAHRA0"
 Private cString     := ""
 Private aRegistros  := {}
 Private nLin        := 80
 Private aVetor      := {}
 Private cCodImp     := ""
 Private nMaxLin     := 0 // quantidade maxima de linhas p/ impressao

 //��������������������������������������������������������������������Ŀ
 //� PARAMETROS                                                         �
 //� MV_PAR01	Da Filial                                                 �
 //� MV_PAR02	Ate a Filial                                              �
 //� MV_PAR03 Data Inicial das Marcacoes                                �
 //� MV_PAR04	Data Final das Marcacoes                                  �
 //� MV_PAR05	Ordem de Impressao  1=Nome    2= Quantidade Decrescente   �
 //| MV_PAR06 Grafico ?                                                 |
 //| MV_PAR07 Impressora ?                                              |
 //����������������������������������������������������������������������
 cPerg := "HSPRA0"    
 
 If FunName() <> "HSPAHM29"
  Pergunte(cPerg, .T.)
 Else
  MV_PAR01 := "01" 
  MV_PAR02 := "01" 
  MV_PAR03 := M->GM8_DATAGE
  MV_PAR04 := M->GM8_DATAGE
  MV_PAR05 := 1
 EndIf                                                
                                                                                                  
 nMaxLin := HS_MaxLin(cCodImp)
 nLin    := nMaxLin * 2

 //���������������������������������������������������������������������Ŀ                        
 //� Monta a interface padrao com o usuario...                           �                        
 //�����������������������������������������������������������������������
 wnrel := SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., Tamanho,, .F.)
 If nLastKey == 27
  Return
 EndIf
 SetDefault(aReturn, cString)
 If nLastKey == 27
  Return
 EndIf
 
 //���������������������������������������������������������������������Ŀ
 //� Processamento. RPTSTATUS monta janela com a regua de processamento. �
 //�����������������������������������������������������������������������
 RptStatus({|| RunReport(Cabec1, Cabec2, Titulo)}, Titulo)
 
 RestArea(aArea)
 
Return()


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � Gilson da Silva    � Data �Janeiro/2005 ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � GESTAO HOSPITALAR                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunReport(Cabec1, Cabec2, Titulo)

 Local nInt    := 0
 Local nTotal  := 0
 Local nCtaFor := 0
 Local cSQL    := ""
 
 cSQL := "SELECT GM8.GM8_FILAGE, GM8.GM8_CODUSU, COUNT(*) AS TOTUSU "
 cSQL += "FROM " + RetSQLName("GM8") + " GM8 "                                   
 cSQL += "WHERE GM8.GM8_FILIAL = '" + xFilial("GM8") + "' AND GM8.D_E_L_E_T_ <> '*' "
 cSQL += "AND GM8.GM8_FILAGE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
 cSQL += "AND GM8.GM8_DATCAD BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' "
 cSQL += "AND GM8.GM8_STATUS IN ('1', '3', '4', '5', '6') "
 cSQL += "GROUP BY GM8.GM8_FILAGE, GM8.GM8_CODUSU "

 If MV_PAR05 == 1
  cSQL += "ORDER BY GM8.GM8_FILAGE, GM8.GM8_CODUSU"
 Else
  cSQL += "ORDER BY GM8.GM8_FILAGE, TOTUSU DESC"
 EndIf 
                         
 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
 If EOF()
  HS_MsgInf(STR0012, STR0013, STR0014) //"Nenhum agendamento foi encontrado para a sele��o efetuada!"###"Aten��o"###"Verifique a sele��o"
 EndIf

 Titulo := STR0008 //"Marca��o no Per�odo"
 Cabec1 := STR0011 + Dtoc(MV_PAR03) + STR0009 + Dtoc(MV_PAR04) // "Per�odo de  " ###"  a  "
 
 SetRegua(1000)

 While !EOF()                                                                                
  aAdd(aRegistros, {QRY->GM8_FILAGE, QRY->GM8_CODUSU, QRY->TOTUSU})
  nTotal += QRY->TOTUSU
  DbSkip()
  IncRegua()    
 EndDo 

 If Len(aRegistros) <> 0
  
  If MV_PAR06 == 2 /* se visualiza grafico carteziano...*/
   For nCtaFor := 1 To Len(aRegistros) /* prepara um vetor contendo o percentual eixo y e usuarios + total de agendamento */
    aAdd(aVetor, {(Val(Str(((aRegistros[nCtaFor, 3] / nTotal) * 100), 6, 2))), AllTrim(SubStr(aRegistros[nCtaFor, 2], 1, 13)) + " " + AllTrim(Str(((aRegistros[nCtaFor, 3] / nTotal) * 100), 6, 2)) + "%"})
   Next   
   /* cria o objeto para contrucao do grafico */
   oGraf := hsGRAF():NEW("AGENDA AMBULATORIAL", "MARCACAO NO PERIODO " + DtoC(MV_PAR03) +" a " + DtoC(MV_PAR04) + "    totalizando " + Str(nTotal, 5, 0) + " marcacoes", "Percentual % dos usuarios", "", "USUARIOS ", "", aVetor, 1, 1, 0, 0, 2, 20, 6, 6, 25, 20)
  EndIf
  
  For nInt := 1 To Len(aRegistros)
   //���������������������������������������������������������������������Ŀ
   //� Verifica o cancelamento pelo usuario...                             �
   //�����������������������������������������������������������������������
   If lAbortPrint
    @nLin, 000 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
    Exit
   EndIf     
          
  //���������������������������������������������������������������������Ŀ
  //� Impressao do cabecalho do relatorio. . .                            �
  //�����������������������������������������������������������������������
   If nLin > nMaxLin // Salto de P�gina. Neste caso o formulario tem 55 linhas...
    Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
  	 nLin := 09   
   EndIf    
  
   @nLin, 000 PSAY aRegistros[nInt, 2] //Nome do Usuario  
   @nLin, 055 PSAY Transform(aRegistros[nInt, 3], "@E 999,999")
   @nLin, 074 PSAY Transform((aRegistros[nInt, 3] / nTotal) * 100, "@E 999.99")  //Percentual do Usuario.
   nLin++
  Next 
  
	 nLin++
  @nLin, 047 PSAY STR0010 + Transform(nToTal, "@E 999,999")//"Total : "
 EndIf
 
 SET DEVICE TO SCREEN
 DbCloseArea()

 If aReturn[5] == 1
  DbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 EndIf

 MS_FLUSH()
 
 DBSelectArea("GM8")
 DbClearFilter()
Return()