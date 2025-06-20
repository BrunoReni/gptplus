#Include "QIER260.ch"
#Include "PROTHEUS.CH"
#INCLUDE "Report.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIER260  � Autor � Leandro S. Sabino     � Data � 29/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Listagem Responsavel X Equipe			                  ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIER260	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function QIER260()
Local oReport
Private cPerg	:= "QER260"
              
Pergunte(cPerg,.F.)
oReport := ReportDef()
oReport:PrintDialog()
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 29/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIER260                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport 
Local oSection1 

oReport   := TReport():New("QIER260" ,OemToAnsi(STR0003),"QER260",{|oReport| PrintReport(oReport)},OemToAnsi(STR0001)+OemToAnsi(STR0002))
//"Responsavel X Grupo"##"Serao relacionados os Responsaveis e suas"##"respectivas Equipes."

oSection1 := TRSection():New(oReport,TITSX3("QE4_EQUIPE")[1],{"QE4","QE5"}) //"Responsavel X Grupo"
TRCell():New(oSection1,"QE4_EQUIPE","QE4")
TRCell():New(oSection1,"QE4_DESCRI","QE4")
TRCell():New(oSection1,"QE5_RESPON","QE5") 
TRCell():New(oSection1,"cNOME"    ,"",TitSX3("QAA_NOME")[1]   ,,30,,{|| })
TRCell():New(oSection1,"cAPELIDO" ,"",TitSX3("QAA_APELID")[1],,15,,{|| }) 

Return oReport

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 26/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1) 	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIER260                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PrintReport(oReport)               
Local oSection1   := oReport:Section(1)
Local CEQUIPE     := ""
Local lImp       

MakeAdvplExpr("QER260")
              
dbSelectArea("QE4")
DbSetOrder(1)
dbSeek(xFilial("QE4")+mv_par01,.T.)

While QE4->(!Eof()) .And. QE4->QE4_FILIAL == xFilial("QE4") .And. QE4->QE4_EQUIPE <= mv_par02
	//��������������������������������������������������������������Ŀ
	//� Posiciona no Responsavel pela equipe                         �
	//����������������������������������������������������������������
	cEquipe := QE4->QE4_EQUIPE
	lImp    := .T. 				
	If QE5->(dbSeek(xFilial("QE5")+QE4->QE4_EQUIPE,.T.))
		
		While QE5->(!EOF()) .And.  QE4->QE4_EQUIPE == QE5->QE5_EQUIPE ;
					.And. QE5->QE5_FILIAL == xFilial("QE5")

			If cEquipe = QE5->QE5_EQUIPE .And. lImp 
				oSection1:Init()
				oReport:SkipLine(1) 
				oSection1:Cell("QE4_EQUIPE"):Show() 
				oSection1:Cell("QE4_DESCRI"):Show()
				lImp := .F.
			Else
				oSection1:Cell("QE4_EQUIPE"):Hide() 
				oSection1:Cell("QE4_DESCRI"):Hide()
			Endif	
			
			If QAA->(dbSeek(QE5->QE5_FILRES+QE5->QE5_RESPON))
				oSection1:Cell("cNOME"):SetValue(QAA->QAA_NOME)
				IF(!Empty(QAA->QAA_APELID))
					oSection1:Cell("cAPELIDO"):SetValue(QAA->QAA_APELID)
				Else
					oSection1:Cell("cAPELIDO"):SetValue("")
				Endif	
			Else
				oSection1:Cell("cNOME"):SetValue("")
				oSection1:Cell("cAPELIDO"):SetValue("")			
			Endif
	
			oSection1:PrintLine()
			QE5->(dbSkip())

		EndDo	
		
	EndIf
	QE4->(dbSkip())

EndDo
oSection1:Finish()

Return