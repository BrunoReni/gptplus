
#Include "QIPR100.ch"
#Include "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPR100  � Autor � Leandro S. Sabino     � Data � 31/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Amarracao Produto X Cliente 	              ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPR1001	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function QIPR100()
Local oReport
Private cPerg	:= "QPR100"
Private  __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
Private lProduto   := .F.
           
If TRepInUse()
	Pergunte(cPerg,.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
	Return QIPR100R3() //Executa vers�o anterior do fonte
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
��� Uso      � QIPR100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport                                             
Local oSection1 

oReport   := TReport():New("QIPR100",OemToAnsi(STR0003),"QPR100",{|oReport| PrintReport(oReport)},OemToAnsi(STR0001)+OemToAnsi(STR0002))
oReport:SetLandscape()
//"Amarracao Produto x Cliente"##"Serao relacionados os Clientes com seus "##"respectivos Produtos e ensaios associados."

oSection1 := TRSection():New(oReport,OemToAnsi(STR0007),{"QQ7"})//"Produto"
TRCell():New(oSection1,"QQ7_PRODUT","QQ7") 
TRCell():New(oSection1,"QQ7_CLIENT","QQ7") 
TRCell():New(oSection1,"QQ7_LOJA"  ,"QQ7") 

oSection2 := TRSection():New(oSection1,OemToAnsi(STR0008),{"QQ7"})//"Ensaio"
TRCell():New(oSection2,"QQ7_LABOR" ,"QQ7") 
TRCell():New(oSection2,"QQ7_ENSAIO","QQ7") 
TRCell():New(oSection2,"cDESCPO","   ",TitSX3("QP1_DESCPO")[1],"",TamSX3("QP1_DESCPO")[1])
TRCell():New(oSection2,"QQ7_CODREC","QQ7") 
TRCell():New(oSection2,"QQ7_OPERAC","QQ7") 

Return oReport


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 30.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1)  	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPR100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PrintReport( oReport )
Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(1):Section(1)
Local cChave := ""

MakeAdvplExpr("QPR100")
              
dbSelectArea("QQ7")                               
dbGoTop()                                                           
                                                                
While !Eof() .and.	QQ7_FILIAL == xFilial("QQ7")

	If 	QQ7_PRODUT >= mv_par01 .And.QQ7_PRODUT <= mv_par02 .And. ;
		QQ7_CLIENT >= mv_par03 .And.QQ7_CLIENT <= mv_par05 .And. ;
		QQ7_LOJA   >= mv_par04 .And.QQ7_LOJA   <= mv_par06

		If cChave <> QQ7->QQ7_PRODUT+QQ7->QQ7_CLIENT+QQ7->QQ7_LOJA
			cChave := (QQ7->QQ7_PRODUT+QQ7->QQ7_CLIENT+QQ7->QQ7_LOJA)
			oSection1:Finish()
			oSection2:Finish()
			oSection1:Init()
			oSection1:PrintLine()
			oSection2:Init()
		EndIf
		If QP1->(dbSeek(xFilial("QP1")+QQ7->QQ7_ENSAIO))
			oSection2:Cell("cDESCPO"):SetValue(QP1->QP1_DESCPO)
		Else
			oSection2:Cell("cDESCPO"):SetValue("")	
		EndIf

		
		oSection2:PrintLine()
	Endif	
	QQ7->(dbSkip())
EndDo

Return	
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � qipr100R3  � Autor � Marcelo Pimentel      � Data � 26.08.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emiss�o da Amarracao Produto X Cliente                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � qipr100(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���Paulo Emidio�18/05/00�      � Retirada da funcao de Ajuste do SX1      ���
���Marcelo Pim.�26/03/01�------�Inclusao da impressao grafica no relatorio���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                                                                 

Function qipr100R3()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL wnrel
LOCAL cDesc1		:=STR0001	//"Serao relacionados os Clientes com seus "
LOCAL cDesc2 		:=STR0002	//"respectivos Produtos e ensaios associados."
LOCAL cDesc3 		:=""
LOCAL cString		:="SA1" 

PRIVATE ctitulo	    := STR0003	//"Amarracao Produto x Cliente"
PRIVATE ntamanho	:= "P"
PRIVATE cPerg		:= "QPR100"
PRIVATE aReturn	    := { STR0004, 1,STR0005, 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE cnomprog	:= "QIPR100"
PRIVATE nLastKey	:= 0

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
wnrel := "QIPR100"

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("QPR100",.F.)

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01             // Do Produto              	           �
//� mv_par02             // Ate Produto                          �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnrel:=SetPrint(cString,wnrel,cPerg,@ctitulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,nTamanho)

If nLastKey == 27
	Set Filter To
	Return
Endif

//��������������������������������������������������������������Ŀ
//� Considera a configuracao do usuario                          �
//����������������������������������������������������������������
SetDefault(aReturn,cString)
If nLastKey == 27
	Set Filter To
Endif

RptStatus({|lEnd| R100Imp(@lEnd,wnrel,cString)},cTitulo)

Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R010IMP  � Autor � Vera Lucia S. Simoes  � Data � 21.01.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � qipr100			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function R100Imp(lEnd,wnrel,cString)

Local CbTxt,cbCont:=00
Local cChave		:= ''

Private Titulo 	 := cTitulo
Private Cabec1 	 := ""
Private Cabec2	 := ""
Private	nomeprog := "QIPR100"
Private cTamanho := "P"
Private nTipo	 := 0


cbtxt := SPACE(10)
Li    := 80
m_pag := 01

//��������������������������������������������������������������Ŀ
//� Verifica se deve comprimir ou nao                            �
//����������������������������������������������������������������
nTipo := If(aReturn[4]==1,15,18)

// 012345678901234567890123456789012345678901234567890123456789012345678901234567890
//           1         2         3         4         5         6         7         8
//  Laboratorio  Ensaio                                 Cod.Roteiro  Operacao
//  XXXXXX       XXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     XX          XX 
dbSelectArea("QQ7")
SetRegua(RecCount())
dbGoTop()
While !Eof() .and.	QQ7_FILIAL == xFilial("QQ7")
	If 	QQ7_PRODUT >= mv_par01 .And.QQ7_PRODUT <= mv_par02 .And. ;
		QQ7_CLIENT >= mv_par03 .And.QQ7_CLIENT <= mv_par05 .And. ;
		QQ7_LOJA   >= mv_par04 .And.QQ7_LOJA   <= mv_par06
		If lEnd
			@PROW()+1,001 PSAY STR0006	//"CANCELADO PELO OPERADOR"
			Exit
		Endif
		IncRegua()
		//��������������������������������������������������������������Ŀ
		//� Verifica se � nova pagina 								     �
		//����������������������������������������������������������������
		If Li > 55
			Cabec(cTitulo,Cabec1,Cabec2,nomeprog,cTamanho,nTipo)
		Endif
		
		If cChave <> QQ7->QQ7_PRODUT+QQ7_CLIENT+QQ7_LOJA
			cChave := QQ7->QQ7_PRODUT+QQ7_CLIENT+QQ7_LOJA
			Li++
			@ Li, 001 PSAY TitSX3("QQ7_PRODUT")[1]+" : "+AllTrim(QQ7->QQ7_PRODUT) +"  "+TitSX3("QQ7_CLIENT")[1]+" : "+QQ7->QQ7_CLIENT+"-"+QQ7->QQ7_LOJA	
			Li++
			@Li ,001 PSAY TitSX3("QQ7_LABOR")[1]
			@Li ,014 PSAY TitSX3("QQ7_ENSAIO")[1]
			@Li ,053 PSAY TitSX3("QQ7_CODREC")[1]
			@Li ,066 PSAY TitSX3("QQ7_OPERAC")[1]
			Li++
			@Li ,001 PSAY Replicate("=",80)
			Li++
		EndIf
		@Li ,001 PSAY QQ7->QQ7_LABOR
		@Li ,014 PSAY AllTrim(QQ7->QQ7_ENSAIO)
		If QP1->(dbSeek(xFilial("QP1")+QQ7->QQ7_ENSAIO))
			@Li ,023 PSAY Subs(QP1->QP1_DESCPO,1,30)
		EndIf
		@Li ,057 PSAY QQ7->QQ7_CODREC
		@Li ,069 PSAY QQ7->QQ7_OPERAC
		Li++
	EndIf
	QQ7->(dbSkip())
EndDo

If Li != 80
	roda(CbCont,cbtxt)
EnDif
//��������������������������������������������������������������Ŀ
//� Restaura a Integridade dos dados                             �
//����������������������������������������������������������������
 dbSelectArea("QQ7")
Set Filter To
dbSetOrder(1)

Set device to Screen
If aReturn[5] == 1
	Set Printer To 
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()
Return .T.