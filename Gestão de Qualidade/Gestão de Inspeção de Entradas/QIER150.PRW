#INCLUDE "QIER150.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Report.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIER150  � Autor � Leandro S. Sabino     � Data � 06/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Instrumento X Lotes 						                  ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIER150	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function QIER150()
Local oReport

Pergunte("QER150",.F.)
oReport := ReportDef()
oReport:PrintDialog()
Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 06/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIER150                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport                                             
Local oSection1 
																																			  
DEFINE REPORT oReport NAME "QIER150" TITLE STR0003 PARAMETER "QER150" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (OemToAnsi(STR0001)) //"Instrumento x Lote"
//"Instrumento x Lote"##"Serao relacionados os Instrumentos utilizados em cada Lote."

oSection1 := TRSection():New(oReport,OemToAnsi(STR0020),{"TRB","QET","QER"}) // "Instrumento"
TRCell():New(oSection1,"PRODUT"  ,"TRB",OemToAnsi(STR0013),,TamSx3("B1_COD")[1])//"Produto"
TRCell():New(oSection1,"REVI"    ,"TRB",OemToAnsi(STR0014),,02)//"Revisao"
TRCell():New(oSection1,"FORNEC"  ,"TRB",OemToAnsi(STR0015),,20)//"Fornecedor"
TRCell():New(oSection1,"LOJFOR"  ,"TRB",OemToAnsi(STR0016),,02)//"Loja"
TRCell():New(oSection1,"DTENTR"  ,"TRB",OemToAnsi(STR0017),,08)//"Data Entrada"
TRCell():New(oSection1,"LOTE"    ,"TRB",OemToAnsi(STR0018),,16)//"Numero do lote"
TRCell():New(oSection1,"DTMEDI"  ,"TRB",OemToAnsi(STR0019),,08)//"Data Medicao"

Return oReport

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 22.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1)  	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQIE                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PrintReport( oReport )
Local oSection1  := oReport:Section(1)
Local cChave     :=""
Local cInstr     :=""

oReport:SetTitle(OemToAnsi(STR0003)+"    "+OemToAnsi(STR0008)+"   "+Dtoc(mv_par01) +OemToAnsi(STR0009)+ Dtoc(mv_par02))

//���������������������������������������Ŀ
//� Cria do Arquivo de Trabalho Temporario�
//�����������������������������������������
QER150R3(oReport)

While !oReport:Cancel() .And. TRB->(!Eof())
	If cChave <> TRB->INSTR+TRB->PRODUT+TRB->REVI+TRB->FORNEC+TRB->DTENTR+TRB->LOTE+TRB->DTMEDI
		If cInstr != TRB->INSTR
			oSection1:Finish()
			oSection1:Init()
			oReport:SkipLine(1) 
			oReport:ThinLine()
			oReport:PrintText(TitSX3("QET_INSTR")[1]+": "+TRB->INSTR,oReport:Row(),025) 
			oReport:SkipLine(1)	
			oReport:ThinLine()
			cInstr := TRB->INSTR	
		EndIf                                                        
		oSection1:Cell("DTENTR"):SeTvalue(SUBSTR((TRB->DTENTR),7,2)+"/"+SUBSTR((TRB->DTENTR),5,2)+"/"+SUBSTR((TRB->DTENTR),1,4))//"Data Entrada"
		oSection1:Cell("DTMEDI"):SeTvalue(SUBSTR((TRB->DTMEDI),7,2)+"/"+SUBSTR((TRB->DTMEDI),5,2)+"/"+SUBSTR((TRB->DTMEDI),1,4))//"Data Medicao"
		cChave := TRB->INSTR+TRB->PRODUT+TRB->REVI+TRB->FORNEC+TRB->DTENTR+TRB->LOTE+TRB->DTMEDI
		oSection1:PrintLine()
	EndIf
	TRB->(dbSkip())
Enddo

//��������������������������������������������������������������Ŀ
//� Restaura a Integridade dos dados                             �
//����������������������������������������������������������������
dbSelectArea("QER")
Set Filter To
RetIndex("QER")
dbSelectArea("TRB")
dbCloseArea()

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �QER150R3  � Autor � Leandro Souza         � Data � 06/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Armazenamento e Tratamento arquivo de trabalho             ���
�������������������������������������������������������������������������Ĵ��
��� Uso 	 � SigaQIE                       				              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function QER150R3(oReport)  
Local oSection1  := oReport:Section(1)
cAlias  := "TRB"
    
MakeSqlExpr(oReport:uParam)
    
oSection1:BeginQuery()
			
BeginSQL alias cAlias
 	 
	SELECT QER.QER_DTENTR DTENTR, QET.QET_INSTR INSTR, QER.QER_PRODUT PRODUT,
	QER.QER_REVI REVI, QER.QER_FORNEC FORNEC, QER.QER_LOJFOR LOJFOR,
	QET.QET_CODMED CODMED, QER.QER_DTMEDI DTMEDI, QER.QER_LOTE LOTE

	FROM %table:QET% QET, %table:QER% QER
 
	WHERE QET_FILIAL  = %xFilial:QET% and
	QER_FILIAL  = %xFilial:QER% and
	QER_DTMEDI Between %Exp:DTOS(mv_par01)% and %Exp:DTOS(mv_par02)% and
	QET_INSTR Between %Exp:mv_par03% and %Exp:mv_par04% and
	QET_CODMED = QER.QER_CHAVE and
	QET.%notDel% and QER.%notDel%
	
	GROUP BY QER_DTENTR,QET_INSTR,QER_PRODUT,QER_REVI,
	QER_FORNEC,QER_LOJFOR,QET_CODMED,QER_DTMEDI,QER_LOTE

	ORDER BY QER_DTENTR,QET_INSTR,QER_PRODUT

EndSql
    
oSection1:EndQuery() 
Return(.T.)

