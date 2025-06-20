#Include "QIPR110.ch"
#Include "PROTHEUS.CH"                                                      

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPR110  � Autor � Leandro S. Sabino     � Data � 31/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Listagem Produto X Grupo    				                  ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPR110	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function QIPR110()
Local oReport
Private cPerg	:= "QPR110"
Private  __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
Private lProduto   := .F.

If TRepInUse()
	Pergunte(cPerg,.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
    QIPR110R3() //Executa vers�o anterior do fonte
EndIf

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 31/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPR110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport 
Local oSection1 
Local oSection2 

oReport   := TReport():New("QIPR110" ,OemToAnsi(STR0003),"QPR110",{|oReport| PrintReport(oReport)},OemToAnsi(STR0001)+OemToAnsi(STR0002))
//"Produto X Grupo"##"Serao relacionados os Produto com os seus"##"respectivos Grupo."

oSection1 := TRSection():New(oReport,OemToAnsi(STR0009),{"QPA","QP3"})//"Grupo Produto" 
oSection1:SetTotalInLine(.F.)
TRCell():New(oSection1,"QPA_GRUPO"  ,"QPA")
TRCell():New(oSection1,"QP3_DESCRI" ,"QP3",,,,,{|| Posicione("QP3",1,xFilial("QP3")+QPA->QPA_GRUPO,"QP3_DESCRI") } ) 

oSection2 := TRSection():New(oSection1,OemToAnsi(STR0010),{"QPA","QP6"})//"Produto"
TRCell():New(oSection2,"QPA_PRODUT" ,"QPA")
TRCell():New(oSection2,"QP6_DESCPO" ,"QP6",,,,,{|| Posicione("QP6",1,xFilial("QP6")+QPA->QPA_PRODUT,"QP6_DESCPO") } ) 

Return oReport

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 31/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1)       	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPR110                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PrintReport(oReport)               
Local oSection1   := oReport:Section(1)
Local oSection2   := oReport:Section(1):Section(1)
Local cGrupoProd  := ""
     

MakeAdvplExpr("QPR110")
              
dbSelectArea("QPA")
dbSetOrder(2)

cFiltro := 'QPA_PRODUT >= "' + mv_par01 + '"'
cFiltro += '.And. QPA_PRODUT <= "' + mv_par02 + '"'
cFiltro += '.And. QPA_GRUPO  >= "' + mv_par03 + '"'
cFiltro += '.And. QPA_GRUPO  <= "' + mv_par04 + '"'

oSection1:SetFilter(cFiltro,"QPA_GRUPO+QPA_PRODUT")

While !oReport:Cancel() .And.  QPA->(!Eof())
	If 	cGrupoProd <> QPA->QPA_GRUPO
		oSection1:Init()
		oSection1:PrintLine()
		oSection2:Finish()
		oReport:SkipLine(1) 
		oSection2:Init()
		oSection1:Finish() 
	Endif
	cGrupoProd := QPA->QPA_GRUPO
	oSection2:PrintLine()
	
	QPA->(dbSkip())
Enddo

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPR110R3� Autor � Marcelo Pimentel      � Data � 26.08.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Listagem Produto X Grupo                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QIPR110(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQIE                                                    ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���Paulo Emidio�18/05/00�------�Retirada da Funcao de ajuste do SX1       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function QIPR110R3()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL wnrel
LOCAL cDesc1		:=STR0001	//"Serao relacionados os Produto com os seus"
LOCAL cDesc2		:=STR0002	//"respectivos Grupo."
LOCAL cDesc3		:=""
LOCAL cString		:="QPA" 
LOCAL cTitulo		:=STR0003 	//"Produto X Grupo"

PRIVATE ctamanho	:="M"
PRIVATE cPerg		:= "QPR110"
PRIVATE aReturn  	:= { STR0004, 1,STR0005, 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nomeprog	:= "QIPR110",nLastKey := 0

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
wnrel := "QIPR110"

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("QPR110",.F.)

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01             // Produto De              	           �
//� mv_par02             // Produto Ate                          �
//� mv_par02             // Grupo De                             �
//� mv_par02             // Grupo Ate                            �
//����������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnrel:=SetPrint(cString,wnrel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho)

If nLastKey == 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter To
	Return
Endif
	
RptStatus({|lEnd| R110Imp(@lEnd,wnrel,cString,cTitulo)},cTitulo)
Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R110IMP  � Autor � Marcelo Pimentel      � Data � 26.08.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPR110			                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function R110Imp(lEnd,wnrel,cString,cTitulo)

LOCAL CbTxt,cbCont:=00,cKey,cNomArq1,Cabec1:="",Cabec2:="",Cabec3:="",cCond:=""
LOCAL cGrupo :=""
Local nMVCOMP := GetMV("MV_COMP")

//		    				0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
// 						   		 1			  2			3			 4			  5			6			 7			  8			9    	   10			 11
Cabec1:= STR0006	//"GRUPO     DESCRI��O                                    PRODUTO          DESCRI��O"
cabec2:= ""
cabec3:= ""

cbtxt := SPACE(10)

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
li       := 80
m_pag    := 1
nTipo 	:= IIF(aReturn[04]==1,15,18)

dbSelectArea("QPA")
cKey:=IndexKey()

cCond := 'QPA_PRODUT >= "' + mv_par01 + '"'
cCond += '.And. QPA_PRODUT <= "' + mv_par02 + '"'
cCond += '.And. QPA_GRUPO  >= "' + mv_par03 + '"'
cCond += '.And. QPA_GRUPO  <= "' + mv_par04 + '"'

cNomArq1 := CriaTrab(NIL,.F.)
IndRegua("QPA",cNomArq1,cKey,,cCond,STR0007)		//"Selecionando Registros..."
nIndex := RetIndex("QPA")
dbSetOrder(nIndex+1)
dbGoTop()

SetRegua(RecCount())

While !Eof() .And. QPA_FILIAL == xFilial("QPA")

	If lEnd
		@PROW()+1,001 PSAY STR0008	//"CANCELADO PELO OPERADOR"
		Exit
	Endif

	IncRegua()

	//��������������������������������������������������������������Ŀ
	//� Posiciona em Registros de outros arquivos                    �
	//����������������������������������������������������������������
	QP3->(dbSeek(xFilial("QP3")+QPA->QPA_GRUPO))
	QP6->(dbSeek(xFilial("QP6")+QPA->QPA_PRODUT))
	If Li > 60
		cabec(cTitulo,cabec1,cabec2,nomeprog,ctamanho,nMVCOMP)
		If m_pag > 2
			@Li,00 PSAY QPA->QPA_GRUPO + " - " + QP3->QP3_DESCRI
		EndIf
	EndIf
	
	If cGrupo != QPA->QPA_GRUPO
		cGrupo := QPA->QPA_GRUPO
		Li++
		@Li,00 PSAY QPA->QPA_GRUPO + " - " + QP3->QP3_DESCRI
	Endif

	@Li,55 PSAY QPA->QPA_PRODUT + " - " + QP6->QP6_DESCPO
	
	Li++
	
	dbSkip()
EndDo

If Li != 80
	roda(CbCont,cbtxt)
EnDif

//��������������������������������������������������������������Ŀ
//� Restaura a Integridade dos dados                             �
//����������������������������������������������������������������

dbSelectArea("QPA")
cNomArq1 += OrdBagExt()
RetIndex("QPA")
Set Filter To
Ferase(cNomArq1)

Set device to Screen

If aReturn[5] == 1
	Set Printer To 
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()
Return .T.