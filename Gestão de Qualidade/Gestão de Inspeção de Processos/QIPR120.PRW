#INCLUDE "QIPR120.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Report.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QIPR120   �Autor  �Leandro Sabino      � Data �  01/08/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Refer�ncia Cruzada : N�o Conformidade X Ensaio             ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAQIP                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                            
Function QIPR120()
Local oReport
Private lRelR4 := .F.
Private  __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
Private lProduto   := .F.

If TRepInUse()
	lRelR4:= .T.
	Pergunte("QPR120",.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
	Return QIPR120R3()	// Executa vers�o anterior do fonte
EndIF    

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 20/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPR120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local cTitulo1	:= OemToAnsi(STR0002) //"Referencia Cruzada : NC x Ensaios"
Local cTitulo2	:= OemToAnsi(STR0005)+Dtoc(mv_par01)+OemToansi(STR0006)+Dtoc(mv_par02)//"Periodo da Producao : "###" a "
Local cDesc1	:= OemToAnsi(STR0001) //"Ser�o relacionadas as Nao Conformidades associadas aos Ensaios."
Local oSection1 

DEFINE REPORT oReport NAME "QIPR120" TITLE (cTitulo1+" "+cTitulo2) PARAMETER "QPR120" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1)
oReport:SetLandscape(.T.)

DEFINE SECTION oSection1 OF oReport TABLES "TRB" TITLE STR0009 //"Ord. Prod."
DEFINE CELL NAME "cOP"     OF oSection1 ALIAS "TRB" TITLE OemtoAnsi(STR0009) SIZE 11  //"Ord. Prod."
DEFINE CELL NAME "cLote"   OF oSection1 ALIAS "TRB" TITLE AllTrim(TitSX3("QPR_LOTE")[1])      SIZE (TamSx3("QPR_LOTE")[1])
DEFINE CELL NAME "cDt"     OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0010)                   SIZE 16 //"Data/Hora Med."
DEFINE CELL NAME "cNAOCON" OF oSection1 ALIAS "TRB" TITLE SubStr(TitSX3("QPU_NAOCON")[1],1,8) SIZE 02
DEFINE CELL NAME "cNCONF"  OF oSection1 ALIAS "TRB" TITLE OemToAnsi(STR0012)                   SIZE 10  // "No. NCs"
DEFINE CELL NAME "cTEM"    OF oSection1 ALIAS ""    TITLE AllTrim(TitSX3("QPU_TEMCRO")[1])     SIZE 80 

Return oReport

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 01/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Refer�ncia Cruzada : N�o Conformidade X Ensaio       	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1)  	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPR120                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                  
Static Function PrintReport(oReport) 
Local oTempTable	:= NIL
Local oSection1	:= oReport:Section(1)
Local cEspecie	:= "QIPA210C"
Local cEnsaio		:= ""
Local aCampos		:= {}
Local cArqTemp	 := ""

//��������������������������������������������������������������Ŀ
//� Cria Arquivo de Trabalho.                          			 �
//����������������������������������������������������������������
aTam:=TamSX3("QP6_DESCPO")	;	AADD(aCampos,{"TRB_DESCPO","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_OP")		;	AADD(aCampos,{"TRB_OP"    ,"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_PRODUT")	;	AADD(aCampos,{"TRB_PRODUT","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_REVI")	;	AADD(aCampos,{"TRB_REVI"  ,"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_DTENTR")	;	AADD(aCampos,{"TRB_DTENTR","D",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_LOTE")	;	AADD(aCampos,{"TRB_LOTE"  ,"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_ENSAIO")	;	AADD(aCampos,{"TRB_ENSAIO","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_DTMEDI")	;	AADD(aCampos,{"TRB_DTMEDI","D",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_HRMEDI")	;	AADD(aCampos,{"TRB_HRMEDI","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_NAOCON")	;	AADD(aCampos,{"TRB_NAOCON","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_NUMNC")	;	AADD(aCampos,{"TRB_NUMNC" ,"N",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_CHAVE")	;	AADD(aCampos,{"TRB_CHAVE" ,"C",aTam[1],aTam[2]})

oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("indice1", {"TRB_PRODUT"} )
oTempTable:Create()

//��������������������������������������������������������������Ŀ
//� Chamada da funcao para gerar arquivo de Trabalho.            �
//����������������������������������������������������������������
If !GeraTrab(.T.,oReport)
	//��������������������������������������������������������������Ŀ
	//� Apaga o arquivo de trabalho                                  �
	//����������������������������������������������������������������	
	oTempTable:Delete()
	Return Nil
EndIf

TRB->(dbGoTop())
While TRB->(!EOF()) 
	If cEnsaio != TRB->TRB_ENSAIO
		cEnsaio := TRB->TRB_ENSAIO

		QP1->(dbSetOrder(1))
		QP1->(dbSeek(xFilial("QP1")+cEnsaio))

		oSection1:Finish()
		oSection1:Init()
		oReport:SkipLine(1) 
		oReport:ThinLine()
		oReport:PrintText(TitSX3("QPR_ENSAIO")[1] +": "+ TRB->TRB_ENSAIO+" "+QP1->QP1_DESCPO,oReport:Row(),025) 
		oReport:SkipLine(1)	
		oReport:ThinLine()
    Endif

    oSection1:CELL("cOP"):SetValue(TRB->TRB_OP)  
	oSection1:CELL("cLote"):SetValue(TRB->TRB_LOTE)
	oSection1:CELL("cDt"):SetValue(Dtoc(TRB->TRB_DTMEDI)+"-"+TRB->TRB_HRMEDI)//Data/Hora Medi�ao
	oSection1:CELL("cNAOCON"):SetValue(TRB->TRB_NAOCON)
	oSection1:CELL("cNCONF"):SetValue(AllTrim(Str(TRB->TRB_NUMNC)))
	
	oSection1:CELL("cOP"):Show()  
	oSection1:CELL("cLote"):Show()  
	oSection1:CELL("cDt"):Show()  
	oSection1:CELL("cNAOCON"):Show()  
	oSection1:CELL("cNCONF"):Show()  

	//������������������������������������������������������Ŀ
	//�Imprime o Texto da Cronica.							 �
	//��������������������������������������������������������
	If QA2->(dbSeek(xFilial("QA2")+cEspecie+TRB->TRB_CHAVE))
		While QA2->(!Eof()) .And. 	QA2->QA2_FILIAL == xFilial("QA2") .And. ;
				QA2->QA2_CHAVE == TRB->TRB_CHAVE  .And. QA2->QA2_ESPEC == cEspecie
				
		  	If !Empty(StrTran(QA2->QA2_TEXTO, "\13\10", ""))
				oSection1:CELL("cTEM"):SetValue(StrTran(QA2->QA2_TEXTO, "\13\10", ""))
			Else
				oSection1:CELL("cTEM"):SetValue("")		
			EndIf
			oSection1:PrintLine()

		    oSection1:CELL("cOP"):Hide()  
			oSection1:CELL("cLote"):Hide()  
			oSection1:CELL("cDt"):Hide()  
			oSection1:CELL("cNAOCON"):Hide()  
			oSection1:CELL("cNCONF"):Hide()  
		
			QA2->(dbSkip())
		EndDo
	Else	
		oSection1:PrintLine()
	EndIf
	
	TRB->(dbSkip())

EndDo
	
oTempTable:Delete()

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QIPR120R3 � Autor � Marcelo Pimentel      �      � 20/08/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Refer�ncia Cruzada : N�o Conformidade X Ensaio             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QIPR120(Void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQIP                                                    ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function QIPR120R3()

Local wnrel			:= "QIPR120"
Local cDesc1		:= OemToAnsi(STR0001) //"Ser�o relacionadas as Nao Conformidades associadas aos Ensaios."
Local cDesc2		:= ""
Local cDesc3		:= ""
Local cString		:= "QPR"
Local cTitulo		:= OemToAnsi(STR0002) //"Referencia Cruzada : NC x Ensaios"
Local cTamanho		:= "M"
Local cProg			:= "QIPR120"

Private aReturn		:= {OemToAnsi(STR0003),1,OemToAnsi(STR0004),1,2,1,"",1} //"Zebrado"###"Administracao"
Private nLastKey	:= 0
Private cPerg		:= "QPR120"

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01            // Da Data da Producao       	         �
//� mv_par02            // At� Data da Producao      	         �
//� mv_par03            // Do  Produto             	             �
//� mv_par04            // At� Produto              	         �
//� mv_par05            // Do  Ensaio               	         �
//� mv_par06            // At� Ensaio              	             �
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

RptStatus({|lEnd| R120Imp(@lEnd,wnrel,cString,cTitulo,cProg,cTamanho)},cTitulo)

Return .T.

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R120IMP  � Autor � Marcelo Pimentel      � Data � 26/08/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QIPR120			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function R120Imp(lEnd,wnrel,cString,cTitulo,cProg,cTamanho)

Local oTempTable	:= NIL
Local CbTxt     := Space(10)
Local cbCont	:= 0
Local Cabec1	:= OemToAnsi(STR0005)+Dtoc(mv_par01)+OemToansi(STR0006)+Dtoc(mv_par02) //"Periodo da Producao : "###" a "
Local Cabec2	:= ""
Local cEnsaio	:= ""
Local aCampos	:= {}
Local cArqTemp	:= ""
Local nTipo		:= If(aReturn[4] == 1,15,18)
Local cEspecie  := "QIPA210C"

Li    := 80
m_pag := 1

//��������������������������������������������������������������Ŀ
//� Cria Arquivo de Trabalho.                          			 �
//����������������������������������������������������������������
aTam:=TamSX3("QP6_DESCPO")	;	AADD(aCampos,{"TRB_DESCPO","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_OP")		;	AADD(aCampos,{"TRB_OP"    ,"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_PRODUT")	;	AADD(aCampos,{"TRB_PRODUT","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_REVI")	;	AADD(aCampos,{"TRB_REVI"  ,"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_DTENTR")	;	AADD(aCampos,{"TRB_DTENTR","D",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_LOTE")	;	AADD(aCampos,{"TRB_LOTE"  ,"C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_ENSAIO")	;	AADD(aCampos,{"TRB_ENSAIO","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_DTMEDI")	;	AADD(aCampos,{"TRB_DTMEDI","D",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_HRMEDI")	;	AADD(aCampos,{"TRB_HRMEDI","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_NAOCON")	;	AADD(aCampos,{"TRB_NAOCON","C",aTam[1],aTam[2]})
aTam:=TamSX3("QPU_NUMNC")	;	AADD(aCampos,{"TRB_NUMNC" ,"N",aTam[1],aTam[2]})
aTam:=TamSX3("QPR_CHAVE")	;	AADD(aCampos,{"TRB_CHAVE" ,"C",aTam[1],aTam[2]})

oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aCampos )
oTempTable:AddIndex("indice1", {"TRB_PRODUT"} )
oTempTable:Create()

//��������������������������������������������������������������Ŀ
//� Chamada da funcao para gerar arquivo de Trabalho.            �
//����������������������������������������������������������������
If !GeraTrab()
	//��������������������������������������������������������������Ŀ
	//� Apaga o arquivo de trabalho                                  �
	//����������������������������������������������������������������	
	oTempTable:Delete()
	Return .T.
EndIf

If TRB->(BOF()) .and. TRB->(EOF())
	HELP(" ",1,"RECNO")
	//��������������������������������������������������������������Ŀ
	//� Apaga o arquivo de trabalho                                  �
	//����������������������������������������������������������������	
	dbSelectArea("TRB")
	dbCloseArea()
	Ferase(cArqTemp+GetDBExtension())  
	Return .T.
EndIf

TRB->(dbGoTop())
SetRegua(TRB->(RecCount()))
While TRB->(!EOF())

	IncRegua()

	If LastKey() == 286    //ALT_A
		lEnd := .T.
	EndIf
	
	If lEnd
		@PRow()+1,001 PSAY OemToAnsi(STR0007) //"CANCELADO PELO OPERADOR"
		Exit
	EndIf

	If cEnsaio != TRB->TRB_ENSAIO
		cEnsaio := TRB->TRB_ENSAIO
		If Li > 58
			Cabec(cTitulo,cabec1,cabec2,cProg,cTamanho,nTipo)
		EndIf		
		QP1->(dbSetOrder(1))
		QP1->(dbSeek(xFilial("QP1")+cEnsaio))
		@Li,00 PSAY TitSX3("QPR_ENSAIO")[1] +": "+ TRB->TRB_ENSAIO+" "+QP1->QP1_DESCPO
		Li+=2
		@Li,000 PSAY OemtoAnsi(STR0009) //"Ord. Prod."
		@Li,012 PSAY TitSX3("QPR_LOTE")[1]
		@Li,029 PSAY OemToAnsi(STR0010) //"Data/Hora Med."
		@Li,046 PSAY SubStr(TitSX3("QPU_NAOCON")[1],1,8)
		@Li,058 PSAY OemToAnsi(STR0012) // "No. NCs"
		@Li,066 PSAY TitSX3("QPU_TEMCRO")[1]
		Li++
		@Li,000 PSAY __PrtThinLine()
		Li++
	EndIf

	@Li,000 PSAY AllTrim(TRB->TRB_OP)
	@Li,012 PSAY TRB->TRB_LOTE
	@Li,029 PSAY Dtoc(TRB->TRB_DTMEDI)+"-"+TRB->TRB_HRMEDI   //Data/Hora Medi�ao
	@Li,048 PSAY TRB->TRB_NAOCON
	@Li,058 PSAY AllTrim(Str(TRB->TRB_NUMNC))
	
	//������������������������������������������������������Ŀ
	//�Imprime o Texto da Cronica.							 �
	//��������������������������������������������������������
	If QA2->(dbSeek(xFilial("QA2")+cEspecie+TRB->TRB_CHAVE))
		While QA2->(!Eof()) .And. 	QA2->QA2_FILIAL == xFilial("QA2") .And. ;
				QA2->QA2_CHAVE == TRB->TRB_CHAVE  .And. QA2->QA2_ESPEC == cEspecie
				
			If !Empty(StrTran(QA2->QA2_TEXTO, "\13\10", ""))
				@Li,064 PSAY StrTran(QA2->QA2_TEXTO, "\13\10", "")
				Li++
			EndIf
			QA2->(dbSkip())
		EndDo
	EndIf
	Li++
	TRB->(dbSkip())
EndDo

If Li != 80
	Roda(CbCont,cbtxt)
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

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �GeraTrab  � Autor � Marcelo Pimentel      � Data � 31.08.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera arquivo de Trabalho                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GeraTrab()                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function GeraTrab(lR4,oReport )
Local cDesc		:= ""
Local cNomArq1	:= ''
Local cCond		:= ''
Default lR4  			:= .F.
Default oReport			:= Nil

dbSelectArea("QPR")
dbSetOrder(2)

cCond := 'Dtos(QPR->QPR_DTENTR) >= "' + Dtos(mv_par01) 	+ '"'
cCond += '.And. Dtos(QPR->QPR_DTENTR) <= "' + Dtos(mv_par02) 	+ '"'
cCond += '.And. QPR->QPR_PRODUT		>= "' + mv_par03		+ '"'
cCond += '.And. QPR->QPR_PRODUT		<= "' + mv_par04		+ '"'
cCond += '.And. QPR->QPR_ENSAIO		>= "' + mv_par05		+ '"'
cCond += '.And. QPR->QPR_ENSAIO		<= "' + mv_par06		+ '"'

If lR4 
  If !Empty(AllTrim(oReport:Section(1):GetAdvplExp("QPR")))
	cCond += ".AND. "+oReport:Section(1):GetAdvplExp("QPR")
  EndIf
EndIf

cNomArq1 := CriaTrab(NIL,.F.)
IndRegua("QPR",cNomArq1,IndexKey(),,cCond,OemToAnsi(STR0011)) //"Selecionando Registros..."
nIndex := RetIndex("QPR")

dbSetOrder(nIndex+1)
dbGoTop()

If !lRelR4
	SetRegua(QPR->(RecCount()))
Endif
	
While QPR->(!Eof()) .And. xFilial("QPR") == QPR->QPR_FILIAL
	
	//��������������������������������������������������������������Ŀ
	//� Acrescenta na regua ate os registros descartados pela data e �
	//�  revisao                                                     �
	//����������������������������������������������������������������
	
	If !lRelR4
		IncRegua()
	Endif
		
	//��������������������������������������������������������������Ŀ
	//� Chave de ligacao com o QPU - Nao Conformidade das Producoes  �
	//����������������������������������������������������������������
	If QPU->(dbSeek(xFilial("QPU")+QPR->QPR_CHAVE))
		While QPU->(!Eof()) .And. xFilial("QPU") == QPU->QPU_FILIAL .And. QPR->QPR_CHAVE == QPU->QPU_CODMED
			cDesc:= " "		
			If QP6->(dbSeek(xFilial("QP6")+QPR->QPR_PRODUT+Inverte(QPR->QPR_REVI)))
				cDesc := QP6->QP6_DESCPO
			EndIf
			RecLock("TRB",.T.)
			TRB->TRB_OP     := QPR->QPR_OP
			TRB->TRB_PRODUT := QPR->QPR_PRODUT
			TRB->TRB_REVI   := QPR->QPR_REVI
			TRB->TRB_DESCPO := cDesc
			TRB->TRB_DTENTR := QPR->QPR_DTENTR
			TRB->TRB_LOTE   := QPR->QPR_LOTE
			TRB->TRB_ENSAIO := QPR->QPR_ENSAIO
			TRB->TRB_DTMEDI := QPR->QPR_DTMEDI
			TRB->TRB_HRMEDI := QPR->QPR_HRMEDI
			TRB->TRB_NAOCON := QPU->QPU_NAOCON
			TRB->TRB_NUMNC  := QPU->QPU_NUMNC
			TRB->TRB_CHAVE  := QPU->QPU_CHAVE
			MsUnLock()
			QPU->(dbSkip())
		EndDo
	EndIf
	QPR->(dbSkip())
EndDo

dbSelectArea("QPR")
dbSetOrder(1)

If !lRelR4
	FErase(cNomArq1+OrdBagExt())
Endif	

Return(.T.)