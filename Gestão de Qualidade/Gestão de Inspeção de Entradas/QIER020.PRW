#INCLUDE "PROTHEUS.CH"
#INCLUDE "QIER020.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TOTVS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIER020  � Autor � Leandro S. Sabino     � Data � 01/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Entradas           			                  ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIER020	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function QIER020()
Local oReport := ReportDef()
Private cPerg := "QER02A"  

Pergunte(cPerg,.F.) 
oReport:PrintDialog()
   
Return

/*/{Protheus.doc} SchedDef
Parametriza��es do SCHEDULE do relat�rio
@author brunno.costa
@since 01/07/2022
@version P12.1.2210
@return aParam, Array, Array com os par�metros para execu��o do schedule
/*/
Static Function SchedDef()
	Local aOrd   := {}
	Local aParam := { "R", "QER02A", "", aOrd, }
Return aParam


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 01/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIER020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport   := NIL                                          
Local oSection1 := NIL

DEFINE REPORT oReport NAME "QIER020" TITLE STR0003 PARAMETER "QER02A" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION OemToAnsi(STR0001)+OemToAnsi(STR0002)
oReport:SetLandscape(.T.)
//"Entradas"##"Neste relat�rio ser�o relacionadas as Entradas"##"dos Produtos/Fornecedores."
DEFINE SECTION oSection1 OF oReport TABLES "QEK","QEF","QEL" TITLE STR0013        
DEFINE CELL NAME "cPRODUT"      OF oSection1 ALIAS "" TITLE TitSX3("QEK_PRODUT")[1] SIZE TamSx3("QEK_PRODUT")[1]
DEFINE CELL NAME "cDESCPO"      OF oSection1 ALIAS "" TITLE TitSX3("QE6_DESCPO")[1] SIZE 10
oSection1:Cell("cDESCPO"):SeTLineBREAK(.T.)
DEFINE CELL NAME "cSKPLOT"      OF oSection1 ALIAS "" TITLE TitSX3("QEF_SKPLOT")[1] SIZE 15
DEFINE CELL NAME "QEK_DTENTR"   OF oSection1 ALIAS "QEK" 
DEFINE CELL NAME "QEL_DTVAL"    OF oSection1 ALIAS "QEL" 
DEFINE CELL NAME "QEK_LOTE"     OF oSection1 ALIAS "QEK" 
DEFINE CELL NAME "QEK_NNC"      OF oSection1 ALIAS "QEK" 
DEFINE CELL NAME "QEK_TAMLOT"   OF oSection1 ALIAS "QEK" 
DEFINE CELL NAME "QEL_QTREJ"    OF oSection1 ALIAS "QEL" 
DEFINE CELL NAME "QEK_NTFISC"   OF oSection1 ALIAS "QEK" 
DEFINE CELL NAME "QEK_DIASAT"   OF oSection1 ALIAS "QEK" 
DEFINE CELL NAME "QEK_DOCENT"   OF oSection1 ALIAS "QEK" 
DEFINE CELL NAME "cVERIFI"      OF oSection1 ALIAS "" TITLE TitSX3("QEK_VERIFI")[1] SIZE 09 
DEFINE CELL NAME "cLAUDO"       OF oSection1 ALIAS "" TITLE TitSX3("QEL_LAUDO")[1]  SIZE 02
DEFINE CELL NAME "cDTLAUD"      OF oSection1 ALIAS "" TITLE TitSX3("QEL_DTLAUD")[1] SIZE 10
DEFINE CELL NAME "QEL_JUSTLA"   OF oSection1 ALIAS "QEL" SIZE 20 
oSection1:Cell("QEL_JUSTLA"):SeTLineBREAK(.T.)

Return oReport

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 01/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1) 	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIER020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PrintReport( oReport )
Local cFiltro	:= ""
Local cFornec 	:= ""
Local cNiseri	:= ""
Local cSeek		:= ""
Local cVerif    := ""
Local lQReinsp	:= QieReinsp()
Local oSection1 := oReport:Section(1)

MakeAdvplExpr(oReport:uParam)

dbSelectArea("QEK")
QEK->(dbSetOrder(1))

cFiltro:= 'QEK_FILIAL  =="' +xFilial("QEK")+'" .And. '
If mv_par01 == 1
	cFiltro+= 'QEK_FORNEC >= "' +mv_par02      +'" .And. QEK_FORNEC <= "' +mv_par03+'"'
Else
	cFiltro+= 'QEK_FORNEC >= "' +mv_par04      +'" .And. QEK_FORNEC <= "' +mv_par05+'"'
Endif
oSection1:SetFilter(cFiltro)

oReport:SetTitle(OemToAnsi(STR0003)+"   "+Dtoc(mv_par06)+ " - " +Dtoc(mv_par07))

While QEK->(!Eof())

	If QEK->QEK_DTENTR < mv_par06 .or. QEK->QEK_DTENTR > mv_par07 .or. ;
		QEK->QEK_PRODUT < mv_par08 .or. QEK->QEK_PRODUT > mv_par09
		QEK->(dbSkip())
		Loop					 
	Endif
	
	//��������������������������������������������������������������Ŀ
	//� Verifica o Tipo de Entrada selecionada						 �
	//����������������������������������������������������������������
	If mv_par01 == 1    
		If !(QEK->QEK_TIPONF == "N" .Or. QEK->QEK_TIPONF == " ")
			QEK->(dbSkip())
			Loop					 
		EndIf
	ElseIf mv_par01 == 2
 		If !(QEK->QEK_TIPONF == "B") 
			QEK->(dbSkip())
			Loop					 
		EndIf
	ElseIf mv_par01 == 3
 		If !(QEK->QEK_TIPONF == "D") 
			QEK->(dbSkip())
			Loop					 
		EndIf
	EndIF

   	If cFornec != QEK->(QEK_FORNEC+QEK_LOJFOR)
		cFornec := QEK->(QEK_FORNEC+QEK_LOJFOR)
		oSection1:Finish() 
		oSection1:Init() 
		oReport:SkipLine(1)
		oReport:ThinLine(1)
		oReport:SkipLine(1)
		If QEK->QEK_TIPONF $ "N "
			dbSelectArea("SA2")
			SA2->(dbSetOrder(1))
			SA2->(dbSeek(xFilial("SA2")+QEK->(QEK_FORNEC+QEK_LOJFOR)))				 
			oReport:PrintText(STR0008+" "+QEK->QEK_FORNEC+"/"+QEK->QEK_LOJFOR +" - " + SA2->A2_NOME,oReport:Row(),030)//"Fornecedor:"
		Else
			dbSelectArea("SA1")
			SA1->(dbSetorder(1))
			SA1->(dbSeek(xFilial("SA1")+QEK->(QEK_FORNEC+QEK_LOJFOR)))			 
			oReport:PrintText(STR0012+" "+QEK->QEK_FORNEC+"/"+QEK->QEK_LOJFOR +" - " + SA1->A1_NOME,oReport:Row(),030)//"Cliente...:"		 
		EndIf
		oReport:SkipLine(1)
		oReport:ThinLine(1)
		oReport:SkipLine(1)
	EndIf
    
   	If QEK->QEK_TIPONF $ "N "
		dbSelectArea("SA5")
		SA5->(dbSetOrder(2))
		If SA5->(dbSeek(xFilial("SA5")+QEK->(QEK_PRODUT+QEK_FORNEC+QEK_LOJFOR)))
			dbSelectArea("QEF")
			QEF->(dbSetOrder(1))
			If QEF->(dbSeek(xFilial("QEF")+SA5->A5_SKPLOT))
				If !Empty(AllTrim(oReport:Section(1):GetAdvplExp("QEF")))
					If !QEF->(&(oReport:Section(1):GetAdvplExp("QEF")))
						QEK->(dbSkip())
						Loop
					Endif
				EndIf
				oSection1:Cell("cSKPLOT"):SetValue(QEF->QEF_DESRES)				
			Else
			    oSection1:Cell("cSKPLOT"):SetValue("")
			EndIf
		EndIf
	EndIf

	If QEK->QEK_VERIFI == 1
		cVerif := STR0009	//"Inspec."
	Elseif QEK->QEK_VERIFI == 2
		cVerif := STR0010	//"Certifi."
	Else
		cVerif := STR0011	//"Lib.Urg."
	EndIf
	
	oSection1:Cell("cVERIFI"):SetValue(cVerif)
	
	dbSelectArea("QEL")

	cNiseri := QEK->(QEK_NTFISC+QEK_SERINF+QEK_ITEMNF)
	QEL->(dbSetOrder(3))
	cSeek := QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+cNiseri+QEK_TIPONF+DTOS(QEK_DTENTR)+QEK_LOTE)+Space(TamSX3("QEL_LABOR")[1])
	If lQReinsp
		cSeek += QEK->QEK_NUMSEQ
	Endif

	If QEL->(dbSeek(xFilial("QEL")+cSeek))
		If !Empty(AllTrim(oReport:Section(1):GetAdvplExp("QEL")))
			If !QEL->(&(oReport:Section(1):GetAdvplExp("QEL")))
				QEK->(dbSkip())
				Loop
			Endif
		EndIf

		oSection1:Cell("cLAUDO"):SetValue(QEL->QEL_LAUDO)
		oSection1:Cell("cDTLAUD"):SetValue(QEL->QEL_DTLAUD)
    Else
		oSection1:Cell("cLAUDO"):SetValue("")
		oSection1:Cell("cDTLAUD"):SetValue("")
    Endif
    
	dbSelectArea("QE6")
	QE6->(dbSetOrder(1))
	If QE6->(dbSeek(xFilial("QE6")+QEK->(QEK_PRODUT+Inverte(QEK_REVI))))
		oSection1:Cell("cPRODUT"):SetValue(AllTrim(QEK->QEK_PRODUT))
		oSection1:Cell("cDESCPO"):SetValue(Substr(QE6_DESCPO,1,37))
	Endif
		
	oSection1:PrintLine()
	QEK->(dbSkip()) 
	
EndDo
    
Return
                   
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QIER020   �Autor  �Microsiga           � Data �  10/23/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o dos par�metros, grupo QER02A                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Q020VLDX1(cPergun)
//A regra desta fun��o foi removida para permitir a nave��o entre os campos atrav�s da tecla TAB. Detalhes na DMANQUALI-5932.
Return(.T.)
