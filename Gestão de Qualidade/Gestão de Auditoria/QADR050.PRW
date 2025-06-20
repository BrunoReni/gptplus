#include "QADR050.CH"
#INCLUDE "REPORT.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QADR050   �Autor  �Leandro Sabino      � Data �  14/06/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Listagem de Check List						              ���
���          � (Versao Relatorio Personalizavel)                          ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAQAD	                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                            
Function QADR050()
Local oReport
Private cChkIni  := ''
Private cChkFim  := ''
Private cRevIni  := ''
Private cRevFim  := ''
Private cTopIni  := ''
Private cTopFim  := ''  


If TRepInUse()
	Pergunte("QAR050",.F.) 

	cChkIni  := mv_par01
	cChkFim  := mv_par02
	cRevIni  := mv_par03
	cRevFim  := mv_par04
	cTopIni  := mv_par05
	cTopFim  := mv_par06
	
    oReport := ReportDef()
    oReport:PrintDialog()
Else
	 QADR050R3()	// Executa vers�o anterior do fonte
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 14/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADR050                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local cTitulo    := STR0003 //'Listagem de Check List' 
Local cDesc1     := STR0001 //"Este relatorio tem o objetivo de imprimir as quest�es agrupadas"
Local cDesc2     := STR0002 //"por Check List + Revisao + Topico"
Local oSection1
Local oSection2
Local oSection3
Local oSection4

DEFINE REPORT oReport NAME "QADR050" TITLE cTitulo PARAMETER "QAR050" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1+cDesc2)

DEFINE SECTION oSection1 OF oReport TABLES "QU4" TITLE TITSX3("QU4_CHKLST")[1]
DEFINE CELL NAME "QU4_QSTITE" OF oSection1 ALIAS "QU4"
DEFINE CELL NAME "QU4_CHKLST" OF oSection1 ALIAS "QU4"
DEFINE CELL NAME "QU4_REVIS"  OF oSection1 ALIAS "QU4" 
DEFINE CELL NAME "QU4_CHKITE" OF oSection1 ALIAS "QU4"
DEFINE CELL NAME "QU4_FAIXIN" OF oSection1 ALIAS "QU4"
DEFINE CELL NAME "QU4_FAIXFI" OF oSection1 ALIAS "QU4" 
DEFINE CELL NAME "QU4_PESO"   OF oSection1 ALIAS "QU4" 

DEFINE SECTION oSection2 OF oSection1 TITLE TITSX3("QU4_TXTQS1")[1]
DEFINE CELL NAME "cTXTCHV" OF oSection2 ALIAS "" TITLE TitSX3("QU4_TXTQS1")[1] SIZE 160 
oSection2:Cell("cTXTCHV"):SeTLineBREAK(.T.)

DEFINE SECTION oSection3 OF oSection2 TITLE TITSX3("QU4_OBSER1")[1]
DEFINE CELL NAME "cOBSCHV" OF oSection3 ALIAS "" TITLE TitSX3("QU4_OBSER1")[1] SIZE 160 
oSection3:Cell("cOBSCHV"):SeTLineBREAK(.T.)

DEFINE SECTION oSection4 OF oSection3 TITLE TITSX3("QU4_REQQS1")[1]
DEFINE CELL NAME "cREQCHV" OF oSection4 ALIAS "" TITLE TitSX3("QU4_REQQS1")[1] SIZE 160 
oSection4:Cell("cREQCHV"):SeTLineBREAK(.T.)

Return oReport

/*/                                                                       
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 13/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1)  	     	                              ���
�������������������������������������������������������������������������Ĵ��        
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADR050                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
                 
Static Function PrintReport(oReport) 
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local oSection3 := oReport:Section(1):Section(1):Section(1)
Local oSection4 := oReport:Section(1):Section(1):Section(1):Section(1)
Local cChkLst 	:= ""
Local lChkLst 	:= .F.
Local cChkIte 	:= ""
Local lChkIte 	:= .F.
Local aUsrMat	:= QA_USUARIO()
Local lSoLider	:= GetMv("MV_AUDSLID", .T., .F.)
Local cCHKLIST  := ""
Local lFisrt    := .T.

Private cMatFil	:= aUsrMat[2]
Private cMatCod	:= aUsrMat[3]

If lSoLider
	DbSelectArea("QUH")
	DbSetOrder(1)

	DbSelectArea("QUJ")
	DbSetOrder(2)	
Endif

dbSelectArea("QU4")
dbSetOrder(1)

If !Empty(mv_par01)
	dbSeek(xFilial("QU4") + mv_par01, .T.)
Else
	dbSeek(xFilial("QU4"))
Endif

MakeAdvplExpr(oReport:uParam)

lImpTxt := (mv_par09=1 .or. mv_par10=1 .or. mv_par11=1)

While !oReport:Cancel() .And. QU4->(!Eof()) .And. QU4->QU4_FILIAL == xFilial("QU4") 
	
	oSection1:Init()
	
   	If ! Empty(mv_par02) .and. QU4->QU4_CHKLST > mv_par02
		Exit
	Endif

	If mv_par03 > QU4->QU4_REVIS .Or. QU4->QU4_REVIS > mv_par04
		dbSkip()
		Loop
	Endif
		
    If mv_par05 > QU4->QU4_CHKITE .Or. QU4->QU4_CHKITE > mv_par06
    	dbSkip()
    	Loop
    Endif
    
    If mv_par07 > QU4->QU4_QSTITE .Or. QU4->QU4_QSTITE > mv_par08
    	dbSkip()
    	Loop
    Endif		
    
    If lSoLider .And. ! Qad030Qau()
    	dbSkip()
    	Loop
    Endif		

    //�������������������������������������������������������������������Ŀ
    //�Verifica se houve interrupcao pelo operador                                                                         �
    //���������������������������������������������������������������������
	
	If (lChkLst := cChkLst # QU4->QU4_CHKLST)
		QU2->(dbSeek(xFilial("QU2") + QU4->QU4_CHKLST + QU4->QU4_REVIS))
		cChkLst := QU4->QU4_CHKLST
	Endif

	If (lChkIte := cChkIte # QU4->QU4_CHKITE)
		QU3->(dbSeek(xFilial("QU3") + QU4->QU4_CHKLST + QU4->QU4_REVIS + QU4->QU4_CHKITE))
		cChkIte := QU4->QU4_CHKITE
	Endif	

	
	If lChkLst
		oReport:ThinLine()
		oReport:PrintText(Pad(RetTitle("QU2_CHKLST"), 18) + ": " + QU2->QU2_CHKLST + "  " + RetTitle("QU2_REVIS") + ": " + QU2->QU2_REVIS,oReport:Row(),025)
		oReport:SkipLine(1)	
		oReport:PrintText(Pad(RetTitle("QU2_DESCRI"), 18) + ": " + QU2->QU2_DESCRI,oReport:Row(),025)
		oReport:SkipLine(1)	
		cCheck := QU4->QU4_CHKLST
	Endif

  				
	If lChkIte
		If !Empty(QU3->QU3_CHKITE)
			oReport:PrintText(Pad(AllTrim(RetTitle("QU3_CHKITE")),18) + ": " + QU3->QU3_CHKITE,oReport:Row(),025)
			oReport:SkipLine(1)		
		EndIf
		If !Empty(QU3->QU3_NORMA)
			oReport:PrintText(Pad(AllTrim(RetTitle("QU3_NORMA")),18) + ": " + QU3->QU3_NORMA	,oReport:Row(),025)
			oReport:SkipLine(1)	
        EndIf				
		If !Empty(QU3->QU3_DESCRI)
			oReport:PrintText(Pad(RetTitle("QU3_DESCRI"), 18) + ": " + QU3->QU3_DESCRI,oReport:Row(),025)
			oReport:SkipLine(1)	
		EndIf
	Endif

    oReport:SkipLine(1)
    oSection1:PrintLine()  
       
	If mv_par09 = 1
		oSection2:Init() 
		oSection2:CELL("cTXTCHV"):SetValue(MSMM(QU4->QU4_TXTCHV))
		oSection2:PrintLine()
	Endif

	If mv_par10 = 1
		oSection3:Init()
		oSection3:CELL("cOBSCHV"):SetValue(MSMM(QU4->QU4_OBSCHV))
		oSection3:PrintLine()
	Endif

	If mv_par11 = 1
		oSection4:Init()
		oSection4:CELL("cREQCHV"):SetValue(MSMM(QU4->QU4_REQCHV))
		oSection4:PrintLine()
	Endif                                   
	
	oReport:SkipLine(1)   
    oReport:ThinLine()		
	oReport:SkipLine(1)

	oSection1:Finish()
	oSection2:Finish()
	oSection3:Finish()
	oSection4:Finish()

	QU4->(dbSkip())	
    //Consistencia valida somente para a Primeira vez
    If lFisrt 
    	cChkList := QU4->QU4_CHKlST
    	lFisrt   := .F.
    Endif	
    	
	If  cChkList <> QU4->QU4_CHKlST   
		cChkList := QU4->QU4_CHKlST
		oSection1:SetPageBreak(.T.) 
	Else
    	oSection1:SetPageBreak(.F.) 
	Endif
		

Enddo

QU4->(DbCloseArea())
QU3->(DbCloseArea())

oSection1:Finish()

Return NIL
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QADR050  � Autor � Marcelo Iuspa			� Data � 19/12/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Listagem de Check List									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQAD                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Paulo Emidio�18/12/00�------�Foram ajustados e complementados os STR's ���
���            �	    �      �e os arquivos CH's, para que os mesmos pos���
���            �	    �      �sam ser traduzidos.						  ���
���Eduardo S.  �10/10/02�------�Alterado para apresentar o Topico e Norma.���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QADR050R3()

//��������������������������������������������������������������Ŀ
//� Define Variaveis Locais                                      �
//����������������������������������������������������������������
Local cDesc1     := STR0001 //"Este relatorio tem o objetivo de imprimir as quest�es agrupadas"
Local cDesc2     := STR0002 //"por Check List + Revisao + Topico"
Local cDesc3     := ''
Local cString    := 'QU4'
Local lEnd       := .F.
Local Tamanho    := 'M'
Local Titulo     := STR0003 //'Listagem de Check List' 
Local wnRel      := 'QADR050'
Local aImpTxt    := {}

Private aReturn  := {STR0004, 1, STR0005, 1, 2, 1, '', 1} //"Zebrado"###"Administracao"
Private cPerg    := 'QAR050' 
Private cChkIni  := ''
Private cChkFim  := ''
Private cRevIni  := ''
Private cRevFim  := ''
Private cTopIni  := ''
Private cTopFim  := ''  

Pergunte(cPerg, .F.)

cChkIni  := mv_par01
cChkFim  := mv_par02
cRevIni  := mv_par03
cRevFim  := mv_par04
cTopIni  := mv_par05
cTopFim  := mv_par06

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnRel := SetPrint(cString, wnRel, cPerg, Titulo, cDesc1, cDesc2, cDesc3, .F.,,, Tamanho)

If nLastKey == 27
	Set Filter To
	Return Nil
Endif

SetDefault(aReturn, cString)

If nLastKey == 27
	Set Filter To
	Return Nil
Endif

RptStatus({|lEnd| Q050Imp(@lEnd, wnRel, Tamanho, Titulo)}, Titulo)

Set Filter To

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Q050Imp   � Autor � Marcelo Iuspa			� Data �19/10/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do relatorio									  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q050Imp(lEnd, wnRel, Tamanho, Titulo)					  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 															  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADR050                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Q050Imp(lEnd, wnRel, Tamanho, Titulo)

//�������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape         �
//���������������������������������������������������������������������
Local cChkLst := ""
Local lChkLst := .F.
Local cChkIte := ""
Local lChkIte := .F.
Local aUsrMat	:= QA_USUARIO()
Local lSoLider	:= GetMv("MV_AUDSLID", .T., .F.)
Local x			:= 1
Local y			:= 1

Private cMatFil	:= aUsrMat[2]
Private cMatCod	:= aUsrMat[3]
Private Li     := 80
Private M_pag  := 1
Private cabec1 := ""
Private cabec2 := ""
//������������������������������������������������������������������������������Ŀ
//� Parametros utilizados                                                        �
//� mv_par01 - Check List de                                                     �
//� mv_par02 - Check List ate                                                    �
//� mv_par03 - Revisao de                                                        �
//� mv_par04 - Revisao ate                                                       �
//� mv_par05 - Topico de                                                         �
//� mv_par06 - Topico ate                                                        �
//� mv_par07 - Questao de                                                        �
//� mv_par08 - Questao ate                                                       �
//� mv_par09 - Impr. Texto Questao                                               �
//� mv_par10 - Impr. Observacao                                                  �
//� mv_par11 - Impr. Requisitos                                                  �
//��������������������������������������������������������������������������������

If lSoLider
	DbSelectArea("QUH")
	DbSetOrder(1)

	DbSelectArea("QUJ")
	DbSetOrder(2)	
Endif

nLargQst := 68

dbSelectArea("QU4")
dbSetOrder(1)

If ! Empty(mv_par01)
	dbSeek(xFilial("QU4") + mv_par01, .T.)
Else
	dbSeek(xFilial("QU4"))
Endif

SetRegua(QU4->(LastRec()))

aCampos := {"QU4_QSTITE", "QU4_CHKLST", "QU4_REVIS", "QU4_CHKITE", "QU4_FAIXIN", "QU4_FAIXFI", "QU4_PESO"}

aCampos := QADImpCampo(aCampos)

cTop    := ""

For x := 1 to Len(aCampos)
	cTop += aCampos[x, 1] + "  "
Next	

lImpTxt := (mv_par09=1 .or. mv_par10=1 .or. mv_par11=1)

While ! Eof() .and. QU4->QU4_FILIAL == xFilial("QU4") 

	If lEnd
		@Prow()+1,001 PSAY STR0006 //"CANCELADO PELO OPERADOR"
 		Exit
	Endif

	IncRegua()

	If ! Empty(mv_par02) .and. QU4->QU4_CHKLST > mv_par02
		Exit
	Endif

	If mv_par03 > QU4->QU4_REVIS .Or. QU4->QU4_REVIS > mv_par04
		dbSkip()
		Loop
	Endif
		
    If mv_par05 > QU4->QU4_CHKITE .Or. QU4->QU4_CHKITE > mv_par06
    	dbSkip()
    	Loop
    Endif
    
    If mv_par07 > QU4->QU4_QSTITE .Or. QU4->QU4_QSTITE > mv_par08
    	dbSkip()
    	Loop
    Endif		
    
    If lSoLider .And. ! Qad030Qau()
    	dbSkip()
    	Loop
    Endif		

    //�������������������������������������������������������������������Ŀ
    //�Verifica se houve interrupcao pelo operador                                                                         �
    //���������������������������������������������������������������������
	
	If (lChkLst := cChkLst # QU4->QU4_CHKLST)
		QU2->(dbSeek(xFilial("QU2") + QU4->QU4_CHKLST + QU4->QU4_REVIS))
		cChkLst := QU4->QU4_CHKLST
	Endif

	If (lChkIte := cChkIte # QU4->QU4_CHKITE)
		QU3->(dbSeek(xFilial("QU3") + QU4->QU4_CHKLST + QU4->QU4_REVIS + QU4->QU4_CHKITE))
		cChkIte := QU4->QU4_CHKITE
	Endif	

	If li > 58
		Cabec(titulo,cabec1,cabec2,wnRel,tamanho)
		li += 1

    	//�������������������������������������������������������������������Ŀ
	    //�continua��o do mesmo check list e mesmo topico sem impressao de    � 
	    //�textos (perguntas observacoes etc), imprimo cabe�alho na quebra    �
	    //�de pagina														  �
	    //���������������������������������������������������������������������
		If (! lImpTxt) .and. (! lChkLst) .and. (! lChkIte) 
			li++
			@ li, 00 pSay __prtfatline()
			li++
			@ li,00 pSay cTop
			li++
		Endif	
	EndIf

	If lChkLst .or. lChkIte
		li+=1
	Endif	

	If lChkLst
		li += 1
		If li > 58
			Cabec(titulo,cabec1,cabec2,wnRel,tamanho)
			li += 1
        Endif
		
		@ li++, 10 pSay Pad(RetTitle("QU2_CHKLST"), 18) + ": " + QU2->QU2_CHKLST + "  " + RetTitle("QU2_REVIS") + ": " + QU2->QU2_REVIS
		
		If li > 58
			Cabec(titulo,cabec1,cabec2,wnRel,tamanho)
			li += 1
        Endif

		@ li++, 10 pSay Pad(RetTitle("QU2_DESCRI"), 18) + ": " + QU2->QU2_DESCRI
	Endif
	
	If lChkIte
		li += 1	
		If !Empty(QU3->QU3_CHKITE)
			If li > 58
				Cabec(titulo,cabec1,cabec2,wnRel,tamanho)
				li += 1
	        Endif	
			@ li++, 10 pSay Pad(AllTrim(RetTitle("QU3_CHKITE")),18) + ": " + QU3->QU3_CHKITE
		EndIf
		If !Empty(QU3->QU3_NORMA)
			If li > 58
				Cabec(titulo,cabec1,cabec2,wnRel,tamanho)
				li += 1
	        Endif
			
			@ li++, 10 pSay Pad(AllTrim(RetTitle("QU3_NORMA")),18) + ": " + QU3->QU3_NORMA	
        EndIf				
		If !Empty(QU3->QU3_DESCRI)
			If li > 58
				Cabec(titulo,cabec1,cabec2,wnRel,tamanho)
				li += 1
	        Endif

			@ li++, 10 pSay Pad(RetTitle("QU3_DESCRI"), 18) + ": " + QU3->QU3_DESCRI
		EndIf
	Endif

	If lChkIte .Or. lChkLst
		li += 1
		If ! lImpTxt
			li ++
			@ li, 00 pSay __prtfatline()
			li++
			@ li,00 pSay cTop
			li++
		Endif	
	Endif	

	cReg := ""
	For y := 1 to Len(aCampos)
		cReg  += Eval(aCampos[y, 2]) + "  "
	Next
	
	If (mv_par09=1 .or. mv_par10=1 .or. mv_par11=1)
		li++
		@ li, 00 pSay __prtfatline()
		li++
		@ li,00 pSay cTop
		li++
	Endif	

	@ li++, 00 pSay cReg 
	@ li, 00 pSay __prtfatline()

	If mv_par09 = 1
		aImpTxt := JustificaTXT(MSMM(QU4->QU4_TXTCHV,TamSX3('QU4_TXTQS1')[1]),68,.T.)	  	
		QADR050ImpTxt(aImpTxt,'QU4_TXTQS1',titulo,cabec1,cabec2,wnRel,tamanho)
	Endif

	If mv_par10 = 1
		aImpTxt := JustificaTXT(MSMM(QU4->QU4_OBSCHV,TamSX3('QU4_OBSER1')[1]),68,.T.)	  	
		QADR050ImpTxt(aImpTxt,'QU4_OBSER1',titulo,cabec1,cabec2,wnRel,tamanho)
	Endif

	If mv_par11 = 1
		aImpTxt := JustificaTXT(MSMM(QU4->QU4_REQCHV,TamSX3('QU4_REQQS1')[1]),68,.T.)	  	
		QADR050ImpTxt(aImpTxt,'QU4_REQQS1',titulo,cabec1,cabec2,wnRel,tamanho)
	Endif

	dbSkip()
Enddo

//�������������������������������������������������������������������Ŀ
//� Devolve a condicao original do arquivo principal                  �
//���������������������������������������������������������������������

Set device to Screen

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QADR050ImpTxt� Autor � Marcelo Iuspa		   �Data �19/10/00���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Divide o texto em Linhas									  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QADR050ImpTxt(cCampo)									  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 															  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADR050                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function QADR050ImpTxt(aImpTxt,cCampo,titulo,cabec1,cabec2,wnRel,tamanho)
Local x
Local lLinha := .T.

For x := 1 to Len(aImpTxt)
	If li > 58
		Cabec(titulo,cabec1,cabec2,wnRel,tamanho)
		li += 1
		@ li,000 pSay RetTitle(cCampo)
		lLinha := .F.
	EndIf           
	If lLinha
		@ ++li,000 pSay If(x = 1, RetTitle(cCampo), "")	
	Else	 
		lLinha := .T.
	EndIf	
	@   li,020 pSay aImpTxt[x]
Next
li+=2
Return(NIL)