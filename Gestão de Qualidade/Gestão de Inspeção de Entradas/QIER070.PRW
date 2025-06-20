#Include "QIER070.ch"
#Include "PROTHEUS.CH"


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIER070  � Autor � Leandro S. Sabino     � Data � 26/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Listagem Produto X Grupo					                  ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIER070	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function QIER070()
Local oReport
Private cPerg	:= "QER070"
              
Pergunte(cPerg,.F.) 
oReport := ReportDef()
oReport:PrintDialog()

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 26/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIER070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport 
Local oSection1 
Local oSection2 

oReport   := TReport():New("QIER070" ,OemToAnsi(STR0003),"QER070",{|oReport| PrintReport(oReport)},OemToAnsi(STR0001)+OemToAnsi(STR0002))
//"Serao relacionados os Produto com os seus"##"respectivos Grupo."

oSection1 := TRSection():New(oReport,TITSX3("QEA_GRUPO")[1],{"QEA"}) //"Ira imprimir os dados referentes aos Departamentos,"    
oSection1:SetTotalInLine(.F.)
TRCell():New(oSection1,"QEA_GRUPO"  ,"QEA")
TRCell():New(oSection1,"QE3_DESCRI" ,"QE3",,,,,{|| Posicione("QE3",1,xFilial("QE3")+QEA->QEA_GRUPO,"QE3_DESCRI") } ) 

oSection2 := TRSection():New(oSection1,TITSX3("QEA_PRODUT")[1],{"QEA"})
TRCell():New(oSection2,"QEA_PRODUT" ,"QEA")
TRCell():New(oSection2,"QE6_DESCPO" ,"QE6",,,,,{|| Posicione("QE6",1,xFilial("QE6")+QEA->QEA_PRODUT,"QE6_DESCPO") } ) 

Return oReport



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � RF070Imp      � Autor � Leandro Sabino   � Data � 26/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RF070Imp(ExpO1)   	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIER070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PrintReport(oReport)               
Local oSection1   := oReport:Section(1)
Local oSection2   := oReport:Section(1):Section(1)
Local cGrupoProd  := ""

MakeAdvplExpr("QER070")
              
dbSelectArea("QEA")
DbSetOrder(1)

cFiltro := 'QEA_FILIAL == "'+xFilial("QEA") +'"'
cFiltro += '.And. QEA_PRODUT >= "' + mv_par01 + '"'
cFiltro += '.And. QEA_PRODUT <= "' + mv_par02 + '"'
cFiltro += '.And. QEA_GRUPO  >= "' + mv_par03 + '"'
cFiltro += '.And. QEA_GRUPO  <= "' + mv_par04 + '"'

oSection1:SetFilter(cFiltro)

While !oReport:Cancel() .And. QEA->(!Eof())
	If 	cGrupoProd <> QEA->QEA_GRUPO
		oSection1:Init()
		oSection1:PrintLine()
		oSection2:Finish()
		oSection2:Init()
		oSection1:Finish() 
	Endif
	cGrupoProd := QEA->QEA_GRUPO
	oSection2:PrintLine()
	
	QEA->(dbSkip())
Enddo

Return
