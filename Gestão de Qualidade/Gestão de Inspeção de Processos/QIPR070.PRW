#INCLUDE "TOTVS.CH"
#INCLUDE "QIPR070.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPR070  � Autor � Leandro S. Sabino     � Data � 26/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Refer�ncia Cruzada : Nao Conformidade X Produto            ���
�������������������������������������������������������������������������Ĵ��
���Obs:      � (Versao Relatorio Personalizavel) 		                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPR070	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
Function QIPR070()
Local oReport
Private cPerg	   := "QPR070"
Private lSetRegua  := .F.           
Private  __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
Private lProduto   := .F.

If  TRepInUse()
	//��������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros                         �
	//� mv_par01            // Da Data da Producao       	         �
	//� mv_par02            // At� Data da Producao      	         �
	//� mv_par03            // Do  Produto             	           	 �
	//� mv_par04            // At� Produto              	         �
	//� mv_par05            // Da Revis�o               	         �
	//� mv_par06            // At� Revis�o              	         �
	//����������������������������������������������������������������
	Pergunte(cPerg,.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
	QIPR070R3() //Executa vers�o anterior do fonte
  	lSetRegua  := .T.
EndIf

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 26.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPR070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport                                             
Local oSection1 
Local cProdut 	 := ""
Local aOrdem     := {}

DEFINE REPORT oReport NAME "QIPR070" TITLE OemToAnsi(STR0002) PARAMETER "QPR070" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION OemToAnsi(STR0002)
//"Referencia Cruzada : NC x Produto" ##"Ser�o relacionadas as Nao Conformidades associadas a cada Produto"

DEFINE SECTION oSection1 OF oReport   TITLE OemToAnsi(STR0013) TABLES "TRB","QPR","QPU" //"Referencia Cruzada : NC x Produto"

DEFINE CELL NAME "cOP"   	OF oSection1  TITLE	TitSX3("QPR_OP")[1] SIZE   13//"Ordem de Producao"

DEFINE CELL NAME "cDTENTR"   	OF oSection1  TITLE TitSX3("QPR_DTENTR")[1]    			SIZE   08 //"Data de Producao"
DEFINE CELL NAME "cLOTE"   		OF oSection1  TITLE TitSX3("QPR_LOTE")[1] 	   			SIZE   16 //"Lote"
DEFINE CELL NAME "cENSAIO"   	OF oSection1  TITLE TitSX3("QPR_ENSAIO")[1]    			SIZE   08 //"Ensaio"
DEFINE CELL NAME "cDATA"   		OF oSection1  TITLE OemToAnsi(STR0009)  	   			SIZE   16 //"Data/Hora Medi�ao"
DEFINE CELL NAME "cNAOCON"   	OF oSection1  TITLE TitSX3("QPU_NAOCON")[1] 			SIZE   08 //"Nao-Conformidade"
DEFINE CELL NAME "cNUMNC"   	OF oSection1  TITLE Left(TitSX3("QPU_NUMNC")[1],10) 	SIZE   05 //"Num. Nao-Conf."  
DEFINE CELL NAME "cDEMIQI"   	OF oSection1  TITLE OemToAnsi(STR0010)					SIZE   03 //"Dem. IQI"

Return oReport


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 26.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1)  	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPR070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PrintReport( oReport )
Local oTempTable	:= NIL
Local oSection1  := oReport:Section(1)
Local cProdut    := ""
Local dDtEntr 	 := CToD("  /  /  ")
Local cLote   	 := ""
Local cCabec     := ""
Local aCampos 	 := {}
Local aTam		 := {}
Local cArqTemp	 := ""
Local aArea		 := GetArea()

//�����������������������������Ŀ
//� Cria Arquivo de Trabalho.   �
//�������������������������������
aTam:=TamSX3("QP6_DESCPO")	;	AADD(aCampos,{"TRB_DESCPO","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_OP")		;	AADD(aCampos,{"TRB_OP",		"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_PRODUT")	;	AADD(aCampos,{"TRB_PRODUT","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_REVI")	;	AADD(aCampos,{"TRB_REVI",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_DTENTR")	;	AADD(aCampos,{"TRB_DTENTR","D",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_LOTE")	;	AADD(aCampos,{"TRB_LOTE",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_ENSAIO")	;	AADD(aCampos,{"TRB_ENSAIO","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_DTMEDI")	;	AADD(aCampos,{"TRB_DTMEDI","D",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_HRMEDI")	;	AADD(aCampos,{"TRB_HRMEDI","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_NAOCON")	;	AADD(aCampos,{"TRB_NAOCON","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_NUMNC")	;	AADD(aCampos,{"TRB_NUMNC",	"N",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_DEMIQI")	;	AADD(aCampos,{"TRB_DEMIQI","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_CODMED")	;	AADD(aCampos,{"TRB_CODMED","C",aTam[1],aTam[2]})

oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("indice1", {"TRB_OP"} )
oTempTable:Create()

//���������������������������������������������������Ŀ
//� Chamada da funcao para gerar arquivo de Trabalho. �
//�����������������������������������������������������
GeraTrab(.T.,oReport)

TRPosition():New(oSection1,"QPR",5,{|| xFilial("QPR") + TRB->TRB_PRODUT + TRB->TRB_REVI })
TRPosition():New(oSection1,"QPU",1,{|| xFilial("QPU") + TRB->TRB_CODMED + TRB->TRB_NAOCON})

cCabec := STR0005+Dtoc(mv_par01) + STR0006 + Dtoc(mv_par02)		//"Periodo da Producao : "###" a "

oReport:SkipLine(2)	  	
oReport:PrintText(cCabec,oReport:Row(),020)

TRB->(dbGoTop())
While TRB->(!EOF())		
  	If cProdut != TRB->TRB_PRODUT 
		oSection1:Init() 
		oSection1:Cell("cOP"):SetValue(" ")
		oSection1:Cell("cDTENTR"):SetValue(" ")
		oSection1:Cell("cLOTE"):SetValue(" ")	
		oSection1:Cell("cENSAIO"):SetValue(" ")
		oSection1:Cell("cDATA"):SetValue(" ")
		oSection1:Cell("cNAOCON"):SetValue(" ")
		oSection1:Cell("cNUMNC"):SetValue(" ")
		oSection1:Cell("cDEMIQI"):SetValue(" ")
		oSection1:PrintLine()		
		
		oReport:ThinLine() 
		oReport:PrintText(TitSX3("QPR_PRODUT")[1]+": "+ AllTrim(TRB->TRB_PRODUT) +" - "+AllTrim(TRB->TRB_REVI) +" - "+ AllTrim(TRB->TRB_DESCPO),oReport:Row(),025)
		oReport:SkipLine(2)	
		oReport:ThinLine()
		cProdut := TRB->TRB_PRODUT	
	EndIf
	
 	oSection1:Cell("cOP"):Show()
	oSection1:Cell("cDTENTR"):Show()
	oSection1:Cell("cLOTE"):Show()
	
	oSection1:Cell("cOP"):SetValue(TRB->TRB_OP)
	oSection1:Cell("cDTENTR"):SetValue(TRB->TRB_DTENTR)
	oSection1:Cell("cLOTE"):SetValue(TRB->TRB_LOTE)
	
	cProdut := TRB->TRB_PRODUT
	dDtEntr := TRB->TRB_DTENTR
	cLote   := TRB->TRB_LOTE
	
	oSection1:Cell("cENSAIO"):SetValue(TRB->TRB_ENSAIO)
	oSection1:Cell("cDATA"):SetValue(Dtoc(TRB->TRB_DTMEDI)+"-"+TRB->TRB_HRMEDI )
	oSection1:Cell("cNAOCON"):SetValue(TRB->TRB_NAOCON)
	oSection1:Cell("cNUMNC"):SetValue(Str(TRB->TRB_NUMNC,TamSx3("QPU_NUMNC")[1]))

	If TRB->TRB_DEMIQI=="S"
		oSection1:Cell("cDEMIQI"):SetValue(STR0011)
	Else
		oSection1:Cell("cDEMIQI"):SetValue(STR0012)
	Endif                                               
                   	
	oSection1:PrintLine()
	TRB->(dbSkip())
		
EndDo

oTempTable:Delete()
RestArea(aArea)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QIPR070R3 � Autor � Antonio Aurelio F C F �      � 20/08/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Refer�ncia Cruzada : N�o Conformidade X Produto            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QIPR070(Void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQIP                                                    ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���Paulo Emidio�18/05/00�------� Retirada da Funcao de Ajuste do SX1      ���
���Paulo Em�dio�16/08/00�Melhor� Revisao e compatibilizacao da funcao     ���
���            �        �      � CTOD().                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QIPR070R3()
//��������������������������������������������������������������Ŀ
//� Define Variaveis do relatorio                                �
//����������������������������������������������������������������
Local wnrel      := "QIPR070"
Local cDesc1     := STR0001	//"Ser�o relacionadas as Nao Conformidades associadas a cada Produto"
Local cDesc2     := ""
Local cDesc3  	 := ""
Local cString    := "SC2"
Local cTitulo    := STR0002	//"Referencia Cruzada : NC x Produto"
Local cTamanho   := "M"
Local cProg      := "QIPR070"
Local cAlias     := ""
Local nOldQP6    := 0
Local nOldQPU    := 0
Local nOldQPR    := 0
Local nOldOrder  := 0

//������������������������������������������������Ŀ
//� Vari�veis utilizadas pela fun��o SetDefault () �
//��������������������������������������������������
Private aReturn  := { STR0003, 1,STR0004, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private nLastKey := 0
Private cPerg    := "QPR070"

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01            // Da Data da Producao       	         �
//� mv_par02            // At� Data da Producao      	         �
//� mv_par03            // Do  Produto             	           	 �
//� mv_par04            // At� Produto              	         �
//� mv_par05            // Da Revis�o               	         �
//� mv_par06            // At� Revis�o              	         �
//����������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte(cPerg,.F.)                                             

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho)

If nLastKey == 27
	Set Filter To
	Return .F.
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter To
	Return .F.
Endif

//��������������������������������������������������������������Ŀ
//� Posiciona em outros arquivos                                 �
//����������������������������������������������������������������
cAlias := Alias()
nOldOrder := IndexOrd()

nOldQPR := QPR->(IndexOrd())
QPR->(dbSetOrder(5))

nOldQP6 := QP6->(IndexOrd())
QP6->(dbSetOrder(1))

nOldQPU := QPU->(IndexOrd())
QPU->(dbSetOrder(1))

RptStatus({|lEnd| R070Imp(@lEnd,wnrel,cString,cTitulo,cProg,cTamanho)},cTitulo)

//��������������������������������������������������������������Ŀ
//� Volta todas as areas como estavam antes                      �
//����������������������������������������������������������������
QPU->(dbSetOrder(nOldQPU))
QP6->(dbSetOrder(nOldQP6))
QPR->(dbSetOrder(nOldQPR))
dbSelectArea(cAlias)
dbSetOrder(nOldOrder)

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R070IMP  � Autor � Marcelo Pimentel      � Data � 26/08/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPR070			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function R070Imp(lEnd,wnrel,cString,cTitulo,cProg,cTamanho)
Local oTempTable	:= NIL
Local CbTxt, cbCont:=00,Cabec1:="",Cabec2:="",cComp := GetMV("MV_COMP")
Local cProdut := ""
Local dDtEntr := CToD("  /  /  ")
Local cLote   := ""
Local aCampos := {}
Local cArqTemp:=""

Cabec1 := STR0005+Dtoc(mv_par01) + STR0006 + Dtoc(mv_par02)		//"Periodo da Producao : "###" a "
cbtxt := Space(10)
Li    := 80
m_pag := 01

//��������������������������������������������������������������Ŀ
//� Cria Arquivo de Trabalho.                          			  �
//����������������������������������������������������������������
aTam:=TamSX3("QP6_DESCPO")	;	AADD(aCampos,{"TRB_DESCPO","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_OP")		;	AADD(aCampos,{"TRB_OP",		"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_PRODUT")	;	AADD(aCampos,{"TRB_PRODUT","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_REVI")	;	AADD(aCampos,{"TRB_REVI",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_DTENTR")	;	AADD(aCampos,{"TRB_DTENTR","D",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_LOTE")	;	AADD(aCampos,{"TRB_LOTE",	"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_ENSAIO")	;	AADD(aCampos,{"TRB_ENSAIO","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_DTMEDI")	;	AADD(aCampos,{"TRB_DTMEDI","D",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_HRMEDI")	;	AADD(aCampos,{"TRB_HRMEDI","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_NAOCON")	;	AADD(aCampos,{"TRB_NAOCON","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_NUMNC")	;	AADD(aCampos,{"TRB_NUMNC",	"N",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_DEMIQI")	;	AADD(aCampos,{"TRB_DEMIQI","C",aTam[1],aTam[2]})

oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("indice1", {"TRB_OP"} )
oTempTable:Create()

//��������������������������������������������������������������Ŀ
//� Chamada da funcao para gerar arquivo de Trabalho.            �
//����������������������������������������������������������������
GeraTrab()

If TRB->(BOF()) .and. TRB->(EOF())
	HELP(" ",1,"RECNO")
	//��������������������������������������������������������������Ŀ
	//� Apaga o arquivo de trabalho                                  �
	//����������������������������������������������������������������	
	oTempTable:Delete()  
	Return .T.
EndIf

TRB->(dbGoTop())
SetRegua(TRB->(RecCount()))

While TRB->(!EOF())
	IncRegua()
	If lEnd
		@PRow()+1,001 PSAY STR0008		//"CANCELADO PELO OPERADOR"
		Exit
	EndIf

	If cProdut != TRB->TRB_PRODUT 

		If Li > 58
			Cabec(cTitulo,cabec1,cabec2,cProg,cTamanho,cComp)
		EndIf	
		Li++

		@Li,00 PSAY TitSX3("QPR_PRODUT")[1] +": "+ AllTrim(TRB->TRB_PRODUT) +" - "+;
						AllTrim(TRB->TRB_REVI) +" - "+ AllTrim(TRB->TRB_DESCPO)
		cProdut := TRB->TRB_PRODUT
		Li+=2
		
		@Li,000 PSAY TitSX3("QPR_OP")[1]
		@Li,031 PSAY TitSX3("QPR_DTENTR")[1]
		@Li,044 PSAY TitSX3("QPR_LOTE")[1]
		@Li,060 PSAY Left(TitSX3("QPR_ENSAIO")[1],8)
		@Li,069 PSAY STR0009	//"Data/Hora Med."
		@Li,088 PSAY TitSX3("QPU_NAOCON")[1]
		@Li,101 PSAY Left(TitSX3("QPU_NUMNC")[1],10)
		@Li,113 PSAY STR0010	//"Dem. IQI"
		Li++
		@Li,000 PSAY "------------------------------ ------------ --------------- -------- ----------------   ------------ ---------- --------"
		Li++
	EndIf

	@Li,00 PSAY TRB->TRB_OP
	@Li,31 PSAY TRB->TRB_DTENTR		//Dtentr
	@Li,44 PSAY TRB->TRB_LOTE		//Lote
			
	cProdut := TRB->TRB_PRODUT
	dDtEntr := TRB->TRB_DTENTR
	cLote   := TRB->TRB_LOTE
		
	@Li,060 PSAY TRB->TRB_ENSAIO	                           //Nota Fiscal
	@Li,069 PSAY Dtoc(TRB->TRB_DTMEDI)+"-"+TRB->TRB_HRMEDI   //Data/Hora Medi��o
	@Li,090 PSAY TRB->TRB_NAOCON		               		   //N.Conf.
	@Li,104 PSAY Str(TRB->TRB_NUMNC,TamSx3("QPU_NUMNC")[1])
	@Li,115 PSAY Iif(TRB->TRB_DEMIQI=="S",STR0011,STR0012)	//"SIM"###"NAO"
	Li++
	TRB->(dbSkip())

EndDo

If Li != 80
	roda(CbCont,cbtxt)
EndIf

//��������������������������������������������������������������Ŀ
//� Apaga indice e o arquivo de trabalho                         �
//����������������������������������������������������������������
oTempTable:Delete()
Set device to Screen
If aReturn[5] == 1
	Set Printer To 
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()
Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GeraTrab  � Autor � Marcelo Pimentel      � Data � 31.08.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera arquivo de Trabalho                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GeraTrab()                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function GeraTrab(lR4, oReport)
Local cQuery			:= ''
Local cChaveInformix	:= ''
Local cCond				:= ''
Local aStru				:= {}
Local nC				:= 0
Local cCamposQPR		:= ''
Local cChave			:= ''
Local cInverte			:= ''
Local cCondR4 			:= ''
Default lR4  			:= .F.
Default oReport			:= Nil

dbSelectArea("QPR")
dbSetOrder(1)
aStru := dbStruct()
cQuery := "SELECT "
For nC:=1 to Len(aStru)
	if nC == 1
		cQuery += aStru[nC,1]
	else
		cQuery += ',' + aStru[nC,1]
	EndIf
Next
cQuery += " FROM " + RetSqlName("QPR")
cQuery += " QPR WHERE QPR_FILIAL = '" + xFilial("QPR") + "' AND "
cQuery += " QPR.QPR_DTENTR >= '"+ Dtos(mv_par01) + "' AND "
cQuery += " QPR.QPR_DTENTR <= '"+ Dtos(mv_par02) + "' AND "
cQuery += " QPR.QPR_PRODUT >= '"+ mv_par03 + "' AND "
cQuery += " QPR.QPR_PRODUT <= '"+ mv_par04 + "' AND "
cQuery += " QPR.QPR_REVI   >= '"+ mv_par05 + "' AND "
cQuery += " QPR.QPR_REVI   <= '"+ mv_par06 + "' AND "
    cQuery += " QPR.D_E_L_E_T_<>'*' "
    If lR4 
	If !Empty(AllTrim(oReport:Section(1):GetSqlExp("QPR")))
		cQuery += "AND "+oReport:Section(1):GetSqlExp("QPR")
	EndIf
    EndIf
cQuery += " ORDER BY " + SqlOrder(QPR->(IndexKey()))
dbSelectArea("QPR")
dbCloseArea()
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QPR", .F., .T.)
dbSelectArea("QPR")
For nC:=1 to Len(aStru)
	If aStru[nC,2] != 'C'
		TCSetField("QPR", aStru[nC,1], aStru[nC,2], aStru[nC,3], aStru[nC,4])
	EndIf
Next nC
cCond	:='!Eof()'


If	lSetRegua
	SetRegua(RecCount())
Endif

While &cCond
	If 	lSetRegua
		IncRegua()
	Endif	
	//��������������������������������������������������������������Ŀ
	//� Chave de ligacao com o QPU - Nao Conformidade das Producoes  �
	//����������������������������������������������������������������
	cChave := QPR->QPR_CHAVE
	cCondR4 := "'"+cChave +"' == QPU_CODMED"
	If lR4
		If !Empty(AllTrim(oReport:Section(1):GetAdvplExp("QPU")))
			cCondR4 += " .AND. "+oReport:Section(1):GetAdvplExp("QPU") 
		EndIf
	EndIf
	If QPU->(dbSeek(xFilial("QPU")+cChave))
		While QPU->(!Eof()) .And. xFilial("QPU") == QPU->QPU_FILIAL .AND. QPU->(&(cCondR4))
			cInverte := Inverte(QPR->QPR_REVI)
			cDesc := Posicione("QP6",1,xFilial("QP6")+QPR->QPR_PRODUT+cInverte,"QP6_DESCPO")
			RecLock("TRB",.T.)
			TRB->TRB_OP		:= QPR->QPR_OP
			TRB->TRB_PRODUT	:= QPR->QPR_PRODUT
			TRB->TRB_REVI	:= QPR->QPR_REVI
			TRB->TRB_DESCPO	:= cDesc
			TRB->TRB_DTENTR	:= QPR->QPR_DTENTR
			TRB->TRB_LOTE	:= QPR->QPR_LOTE
			TRB->TRB_ENSAIO	:= QPR->QPR_ENSAIO
			TRB->TRB_DTMEDI	:= QPR->QPR_DTMEDI
			TRB->TRB_HRMEDI	:= QPR->QPR_HRMEDI
			TRB->TRB_NAOCON	:= QPU->QPU_NAOCON
			TRB->TRB_NUMNC	:= QPU->QPU_NUMNC
			TRB->TRB_DEMIQI	:= QPU->QPU_DEMIQI 
			If lR4
				TRB->TRB_CODMED	:= QPU->QPU_CODMED 			
			EndIf
			MsUnLock()
			QPU->(dbSkip())
		EndDo
	EndIf
	dbSelectArea("QPR")
	dbSkip()
EndDo

dbSelectArea("QPR")
dbCloseArea()
ChKFile("QPR")

dbSelectArea("QPR")
dbSetOrder(1)
Return(.T.)
