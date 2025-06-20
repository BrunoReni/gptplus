#INCLUDE "QMTR071.Ch"
#Include "PROTHEUS.CH"
#INCLUDE "Report.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QMTR071   �Autor  �Leandro Sabino      � Data �  13/07/06	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Calibracoes Previstas e nao realizadas - Tipo 2             ���
���          � (Versao Relatorio Personalizavel)                          ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                            
Function QMTR071()
Local oReport

If TRepInUse()
	Pergunte("QMR070",.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
    QMTR071R3()	// Executa vers�o anterior do fonte
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 13/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTR240                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local ctitulo  := OemToAnsi(STR0004) // "Calibracoes Previstas e Nao Realizadas"
Local cDesc1   := OemToAnsi(STR0001) // "Este programa ir� emitir o relat�rio de Calibracoes"
Local cDesc2   := OemToAnsi(STR0002) // "Previstas e nao relizadas dentro de um determinado"
Local cDesc3   := OemToAnsi(STR0003) // "per�odo."
Local oSection1 

DEFINE REPORT oReport NAME "QMTR071" TITLE cTitulo PARAMETER "QMR070" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1+cDesc2)
oReport:SetLandscape()

DEFINE SECTION oSection1 OF oReport TABLES "QM2"
DEFINE CELL NAME "cINSTR"   OF oSection1 ALIAS "QM2" TITLE TitSx3("QM2_INSTR")[1]  SIZE (TamSx3("QM2_INSTR")[1]) //Instrumento
DEFINE CELL NAME "cREVINS"  OF oSection1 ALIAS "QM2" TITLE TitSx3("QM2_REVINS")[1] SIZE (TamSx3("QM2_REVINS")[1])//Revisao
DEFINE CELL NAME "cTIPO"    OF oSection1 ALIAS "QM2" TITLE TitSx3("QM2_TIPO")[1]   SIZE (TamSx3("QM2_TIPO")[1])  //Familia
DEFINE CELL NAME "cDEPTO"   OF oSection1 ALIAS "QM2" TITLE TitSx3("QM2_DEPTO")[1]  SIZE (TamSx3("QM2_DEPTO")[1]) //Departamento                                  
DEFINE CELL NAME "cRESP"    OF oSection1 ALIAS "QM2" TITLE TitSx3("QM2_RESP")[1]   SIZE (TamSx3("QM2_RESP")[1]) //Usuario
DEFINE CELL NAME "cFREQAFE" OF oSection1 ALIAS "QM2" TITLE TitSx3("QM2_FREQAF")[1]SIZE (TamSx3("QM2_FREQAF")[1])//Frequencia em dias
DEFINE CELL NAME "cFABR"    OF oSection1 ALIAS "QM2" TITLE TitSx3("QM2_FABR")[1]   SIZE (TamSx3("QM2_FABR")[1]) //Fabricante
DEFINE CELL NAME "cLABOR"   OF oSection1 ALIAS "QM2" TITLE OemToAnsi("Orgao Calibrador")SIZE (TamSx3("QM9_ORGAFE")[1]) //Orgao Calibrador
DEFINE CELL NAME "cVALDAF"  OF oSection1 ALIAS "QM2" TITLE TitSx3("QM2_VALDAF")[1] SIZE (TamSx3("QM2_VALDAF")[1]) //Dt. Validade

Return oReport

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 13/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1)  	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTR240                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                  
Static Function PrintReport(oReport) 
Local oSection1     := oReport:Section(1)
Local cStrAnt		:= ""
Local lOk			:= .F.
Local nTotPrev		:= 0
Local nTotReal		:= 0
Local nPrevNaoReal	:= 0
Local nIndice		:= 0

MakeAdvplExpr(oReport:uParam)

dbSelectArea("QM2")

cFiltro := 'QM2_FILIAL == "' + cFilial  + '" .And. '
cFiltro += 'QM2_INSTR >= "'  + mv_par01 + '" .And. '
cFiltro += 'QM2_INSTR <= "'  + mv_par02 + '"'



oSection1:SetFilter(cFiltro)//,"QM2_FILIAL+QM2_DEPTO+QM2_INSTR+QM2_REVINV")
//DbGOTOP()
nIndice := RetIndex("QM2")
dbSetOrder(nIndice)
QM2->(dbSeek(cFilial))

osection1:Init()
    
While !oReport:Cancel() .And. QM2->(!Eof())
    
	// Verifica filial
	If cFilial != QM2->QM2_FILIAL
		Exit
	EndIF
	
	// Verifica instrumento
	If QM2->QM2_INSTR == cStrAnt
		QM2->(dbSkip())
		Loop
	EndIf
	cStrAnt := QM2->QM2_INSTR
	
	// Verifica departamento
	If ( QM2->QM2_DEPTO < mv_par05 .or. QM2->QM2_DEPTO > mv_par06 )
		QM2->(dbSkip())
		Loop
	EndIf
	
	// Verifica usuario
	If ( QM2->QM2_RESP < mv_par12 .or. QM2->QM2_RESP > mv_par13 )
		QM2->(dbSkip())
		Loop
	EndIf
	
	// Verifica fabricante
	If ( QM2->QM2_FABR < mv_par14 .or. QM2->QM2_RESP > mv_par15 )
		QM2->(dbSkip())
		Loop
	EndIf
	
	// Verifica status
	If QM2->QM2_STATUS < mv_par16 .Or. QM2->QM2_STATUS > mv_par17
		QM2->(dbSkip())
		Loop
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifica se status do instrumento esta ativo                    �
	//�������������������������������������������������������������������
	If !QMTXSTAT(QM2->QM2_STATUS)
		QM2->(dbSkip())
		loop
	EndIf
	
	// Verifica familia
	If ( QM2->QM2_TIPO < mv_par20 .or. QM2->QM2_TIPO > mv_par21 )
		QM2->(dbSkip())
		Loop
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. interno e externo                                 �
	//�������������������������������������������������������������������
	If mv_par07 == 1
		If ! Calibrador(0,mv_par08,mv_par09,mv_par10,mv_par11,QM2->QM2_INSTR,QM2->QM2_REVINS)
			QM2->(dbSkip())
			Loop
		EndIf
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. interno                                           �
	//�������������������������������������������������������������������
	If mv_par07 == 2
		If ! Calibrador(1,mv_par08,mv_par09,,,QM2->QM2_INSTR,QM2->QM2_REVINS)
			QM2->(dbSkip())
			Loop
		EndIf
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. externo                                           �
	//�������������������������������������������������������������������
	If mv_par07 == 3
		If ! Calibrador(2,,,mv_par10,mv_par11,QM2->QM2_INSTR,QM2->QM2_REVINS)
			QM2->(dbSkip())
			Loop
		EndIf
	EndIf
	
	// ����������������������������������������������������������������������Ŀ
	// �Verifica validacao mensal:														  �
	// �Para validade de afericao no mesmo mes, a previsao ainda nao venceu   �
	// �portanto, nao deve ser impresso.												  �
	// ������������������������������������������������������������������������
	If mv_par18 == 1
		
		// Fora dos parametros nao imprime
		If SubStr(DtoS(QM2->QM2_VALDAF),1,6) < SubStr(DtoS(mv_par03),1,6)
			QM2->(dbSkip())
			Loop
		EndIf
		
		If SubStr(DtoS(QM2->QM2_VALDAF),1,6) > SubStr(DtoS(mv_par04),1,6)
			QM2->(dbSkip())
			Loop
		EndIf
		
		// Somo aos previstos. Nao somo aos nao realizados porque esta dentro
		// do mesmo mes, mas devo somar aos previstos porque esta dentro do mes
		// de previsao.
		If SubStr(DtoS(QM2->QM2_VALDAF),1,6) == SubStr(DtoS(mv_par04),1,6)
			nTotPrev++
			QM2->(dbSkip())
			Loop
		EndIf
		
		// Somo realizado
		dbSelectArea("QM6")
		dbSetOrder(1)
		dbSeek(cFilial+QM2->QM2_INSTR+QM2->QM2_REVINS)
		lOk := .F.
		While ! Eof()
			
			If QM6->QM6_FILIAL+QM6->QM6_INSTR+QM6->QM6_REVINS != ;
				cFilial+QM2->QM2_INSTR+QM2->QM2_REVINS
				Exit
			EndIf
			
			If SubStr(DtoS(QM6->QM6_DATA),1,6) < SubStr(DtoS(mv_par03),1,6)
				QM6->(dbSkip())
				Loop
			EndIf
			
			If SubStr(DtoS(QM6->QM6_DATA),1,6) > SubStr(DtoS(mv_par04),1,6)
				Exit
			EndIf
			lOk := .T.
			nTotPrev ++
			nTotReal ++
			QM6->(dbSkip())
			
		EndDo
		
		dbSelectArea("QM2")
		If lOk
			QM2->(dbSkip())
			Loop
		EndIf
		
		nTotPrev ++
		
	EndIf
	
	// verifica validade por dia
	If mv_par18 == 2

		lOk := .F.
		
		If QM2->QM2_VALDAF < mv_par03 .or.;
			QM2->QM2_VALDAF > mv_par04
			
			// Somo realizado
			dbSelectArea("QM6")
			dbSetOrder(1)
			dbSeek(cFilial+QM2->QM2_INSTR+QM2->QM2_REVINS)
			lOk := .F.
			While QM6->QM6_FILIAL + QM6->QM6_INSTR+QM6->QM6_REVINS == ;
				QM2->QM2_FILIAL + QM2->QM2_INSTR+QM2->QM2_REVINS
				
				If QM6->QM6_DTPREV >= mv_par03 .and.;
					QM6->QM6_DTPREV <= mv_par04
					
					lOk := .T.
					nTotPrev ++
					nTotReal ++
					
				EndIf
				
				QM6->(DbSkip())
				
			EndDo
			
		EndIf
		
		DbSelectArea("QM2")
		// Somo a quantidade de dias para verificar se
		// est� dentro do per�odo
		If (QM2->QM2_VALDAF+mv_par19) < mv_par03
			QM2->(dbSkip())
			Loop
		EndIf
		
		// Somo a quantidade de dias para verificar se est� dentro
		// do per�odo
		If QM2->QM2_VALDAF + mv_par19 > mv_par04
			QM2->(dbSkip())
			Loop
		EndIf
		
		nTotPrev ++
		
		dbSelectArea("QM2")
		If lOk
			QM2->(dbSkip())
			lOk := .F.
			Loop
		EndIf
		
	EndIf

	nPrevNaoReal ++
  
	dbSelectArea("QMK")
	dbSetOrder(1)                                                      

	oSection1:Cell("cINSTR"):SetValue(QM2->QM2_INSTR)
	oSection1:Cell("cREVINS"):SetValue(QM2->QM2_REVINS)
	oSection1:Cell("cTIPO"):SetValue(QM2->QM2_TIPO)
	oSection1:Cell("cDEPTO"):SetValue(QM2->QM2_DEPTO)
	oSection1:Cell("cRESP"):SetValue(QM2->QM2_RESP)
	oSection1:Cell("cFREQAFE"):SetValue(QM2->QM2_FREQAF)
	oSection1:Cell("cFABR"):SetValue(QM2->QM2_FABR)
	oSection1:Cell("cVALDAF"):SetValue(QM2->QM2_VALDAF)

	If dbSeek(xFilial()+QM2->QM2_TIPO)
		dbSelectArea("QMR")
		dbSetOrder(1)
		If dbSeek(xFilial()+QM2->QM2_INSTR+QM2->QM2_REVINS+QMK->QMK_ESCALA)
			dbSelectArea("QM9")
			dbSetOrder(1)
			If dbSeek(xFilial()+QMR->QMR_ESCALA)
				If mv_par07 == 3 .or. ( mv_par07 == 1 .and. QM9->QM9_ORGAFE == "E" )
					oSection1:Cell("cLABOR"):SetValue(QM9->QM9_LABOR)// LABORATORIO EXTERNO
				ElseIf mv_par07 == 2  .or. ( mv_par07 == 1 .and. QM9->QM9_ORGAFE == "I" )
					oSection1:Cell("cLABOR"):SetValue(QM9->QM9_DEPTO)// LABORATORIO INTERNO
				Endif
			Endif
		Endif
	Endif	   	
    
 	osection1:PrintLine()
 	
	dbSkip()

EndDo

osection1:Finish()   	

oReport:SkipLine(1) 
oReport:ThinLine()

oReport:PrintText(STR0012 + Str( nTotPrev,4 ),oReport:Row(),025) // "Total Previsto no Periodo.....: "
oReport:SkipLine(1)	

oReport:PrintText(STR0013 + Str( nTotReal,4 ),oReport:Row(),025) // "Total Realizado no Periodo....: "
oReport:SkipLine(1)	

oReport:PrintText(STR0014 + Str((100/nTotPrev)*nPrevNaoReal,6,2) + "%",oReport:Row(),025) // "Previstas e nao realizadas....:"
oReport:SkipLine(1)	

oReport:ThinLine()
oReport:SkipLine(1)	

QM2->(DbCloseArea())
QMK->(DbCloseArea())
QMP->(DbCloseArea())  
QM9->(DbCloseArea())

Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
����������������������������������������������	���������������������������Ŀ��
���Fun��o	 � QMTR071R3� Autor � Denis Martins         � Data � 14.11.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calibracoes Previstas e nao realizadas - Tipo 2			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QMTr071(void)											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���Denis       �14/11/02�      � Inicio do relatorio...					  ��� 
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QMTR071R3()
//��������������������������������������������������������������Ŀ
//� Define Variaveis 											 �
//����������������������������������������������������������������
Local cDesc1		:= OemToAnsi(STR0001) // "Este programa ir� emitir o relat�rio de Calibracoes"
Local cDesc2		:= OemToAnsi(STR0002) // "Previstas e nao relizadas dentro de um determinado"
Local cDesc3		:= OemToAnsi(STR0003) // "per�odo."
Local cString		:="QM2"
Local aOrd			:= {}
Local wnrel

Private titulo		:= OemToAnsi(STR0004) // "Calibracoes Previstas e Nao Realizadas"
Private cabec1		:= OemToAnsi(STR0005) // "Instrumento      Rev. Familia          Depto.    Usuario          Dias Fabricante       Orgao Calibrador Validade"

Private cabec2		:= "                                                                  Freq"
Private aReturn		:= {OemToAnsi(STR0006),1,OemToAnsi(STR0007),1,2,1,"",1} // "Zebrado"###"Administra��o"
Private nomeprog	:= "QMTR071"
Private nLastKey	:= 0
Private cPerg		:= "QMR070"
Private cTamanho	:= "M"

/*
1 		  2			3			 4 		  5			6			 7 		  8			9			 0 		  1			2			 3 		  4			5			 6 		  7			8			 9 		  0			1
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
Freq
Instrumento 	  Rev. Familia 			Depto.	 Usuario 			Dias Fabricante		 Orgao Calibrador Validade
xxxxxxxxxxxxxxxx	xx  xxxxxxxxxxxxxxxx xxxxxxxxx xxxxxxxxxxxxxxxx xxxx xxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxx xx/xx/xx
*/

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas 							 �
//����������������������������������������������������������������
pergunte("QMR070",.F.)

//�����������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros				�
//� mv_par01 : Instr. Inicial 							�
//� mv_par02 : Instr. Final								�
//� mv_par03 : Periodo Inicial							�
//� mv_par04 : Periodo Final							�
//� mv_par05 : Depto. Inicial 							�
//� mv_par06 : Depto. Final								�
//� mv_par07 : Orgao Calibrador Todos/Interno/Externo   �
//� mv_par08 : Org.Calib.Interno de						�
//� mv_par09 : Org.Calib.Interno ate					�
//� mv_par10 : Org.Calib.Externo de						�
//� mv_par11 : Org.Calib.Externo ate					�
//� mv_par12 : Usuario de								�
//� mv_par13 : Usuario ate								�
//� mv_par14 : Fabricante de							�
//� mv_par15 : Fabricante ate							�
//� mv_par16 : Status de                  				�
//� mv_par17 : Status ate                               �
//� mv_par18 : Plano de Calibr. Mensal / Diario 		�
//� mv_par19 : Dias										�
//� mv_par20 : Familia de								�
//� mv_par21 : Familia ate								�
//�������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT 						 �
//����������������������������������������������������������������
aOrd := {OemToAnsi(STR0008),OemToAnsi(STR0009)} // " Instrumento  "###" Departamento "
wnrel:="QMTR071"
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,cTamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| MTR071Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � MTR071IMP� Autor � Alessandro B.Freire   � Data � 23.03.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Padroes a Calibrar 								  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � MTr071IMP(lEnd,wnRel,cString) 							  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd		- Acao do Codeblock								  ���
���			 � wnRel	- T�tulo do relat�rio 							  ���
���			 � cString	- Mensagem										  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MTr071Imp(lEnd,wnRel,cString)

Local CbCont
Local CbTxt
Local tamanho		:= " "
Local cStrAnt		:= ""

Local cIndice		:= CriaTrab(NIL,.F.)
Local nIndice		:= 0
Local cChave		:= ""
Local cFiltro		:= ""

Local nRecno		:= Recno()
Local nOrder		:= IndexOrd()
Local nTotPrev		:= 0
Local nTotReal		:= 0
Local nPrevNaoReal	:= 0
Local lOk			:= .F.

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape	  �
//����������������������������������������������������������������
cbtxt 	:= SPACE(10)
cbcont	:= 0
li 		:= 80
m_pag 	:= 1

//��������������������������������������������������������������Ŀ
//� Monta o indice temporario.											  �
//����������������������������������������������������������������
dbSelectArea("QM2")
If aReturn[8] == 1
	dbSetOrder(1)
	cChave := IndexKey()
Else
	cChave := "QM2_FILIAL+QM2_DEPTO+QM2_INSTR+QM2_REVINV"
EndIf

cFiltro := 'QM2_FILIAL == "' + cFilial  + '" .And. '
cFiltro += 'QM2_INSTR >= "'  + mv_par01 + '" .And. '
cFiltro += 'QM2_INSTR <= "'  + mv_par02 + '"'

IndRegua("QM2",cIndice,cChave,,cFiltro,OemToAnsi(STR0010)) // "Selecionando Registros"
nIndice := RetIndex("QM2")

dbSetOrder(nIndice+1)

dbGoTop()
If BOF() .and. EOF()
	Help(" ",1,"RECNO")
End

dbSelectArea("QM2")
dbSeek(cFilial)

SetRegua(RecCount())

While ! Eof()
	
	IncRegua()
	
	IF lEnd
		@Prow()+1,001 PSAY OemToAnsi(STR0011) // "CANCELADO PELO OPERADOR"
		EXIT
	ENDIF
	        
	// Verifica filial
	If cFilial != QM2->QM2_FILIAL
		Exit
	EndIF
	
	// Verifica instrumento
	If QM2->QM2_INSTR == cStrAnt
		dbSkip()
		Loop
	EndIf
	cStrAnt := QM2->QM2_INSTR
	
	// Verifica departamento
	If ( QM2->QM2_DEPTO < mv_par05 .or. QM2->QM2_DEPTO > mv_par06 )
		dbSkip()
		Loop
	EndIf
	
	// Verifica usuario
	If ( QM2->QM2_RESP < mv_par12 .or. QM2->QM2_RESP > mv_par13 )
		dbSkip()
		Loop
	EndIf
	
	// Verifica fabricante
	If ( QM2->QM2_FABR < mv_par14 .or. QM2->QM2_RESP > mv_par15 )
		dbSkip()
		Loop
	EndIf
	
	// Verifica status
	If QM2->QM2_STATUS < mv_par16 .Or. QM2->QM2_STATUS > mv_par17
		dbSkip()
		Loop
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifica se status do instrumento esta ativo                    �
	//�������������������������������������������������������������������
	If !QMTXSTAT(QM2->QM2_STATUS)
		dbskip()
		loop
	EndIf
	
	// Verifica familia
	If ( QM2->QM2_TIPO < mv_par20 .or. QM2->QM2_TIPO > mv_par21 )
		dbSkip()
		Loop
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. interno e externo                                 �
	//�������������������������������������������������������������������
	If mv_par07 == 1
		If ! Calibrador(0,mv_par08,mv_par09,mv_par10,mv_par11,QM2->QM2_INSTR,QM2->QM2_REVINS)
			dbSkip()
			Loop
		EndIf
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. interno                                           �
	//�������������������������������������������������������������������
	If mv_par07 == 2
		If ! Calibrador(1,mv_par08,mv_par09,,,QM2->QM2_INSTR,QM2->QM2_REVINS)
			dbSkip()
			Loop
		EndIf
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. externo                                           �
	//�������������������������������������������������������������������
	If mv_par07 == 3
		If ! Calibrador(2,,,mv_par10,mv_par11,QM2->QM2_INSTR,QM2->QM2_REVINS)
			dbSkip()
			Loop
		EndIf
	EndIf
	
	// ����������������������������������������������������������������������Ŀ
	// �Verifica validacao mensal:														  �
	// �Para validade de afericao no mesmo mes, a previsao ainda nao venceu   �
	// �portanto, nao deve ser impresso.												  �
	// ������������������������������������������������������������������������
	If mv_par18 == 1
		
		// Fora dos parametros nao imprime
		If SubStr(DtoS(QM2->QM2_VALDAF),1,6) < SubStr(DtoS(mv_par03),1,6)
			dbSkip()
			Loop
		EndIf
		
		If SubStr(DtoS(QM2->QM2_VALDAF),1,6) > SubStr(DtoS(mv_par04),1,6)
			dbSkip()
			Loop
		EndIf
		
		// Somo aos previstos. Nao somo aos nao realizados porque esta dentro
		// do mesmo mes, mas devo somar aos previstos porque esta dentro do mes
		// de previsao.
		If SubStr(DtoS(QM2->QM2_VALDAF),1,6) == SubStr(DtoS(mv_par04),1,6)
			nTotPrev++
			dbSkip()
			Loop
		EndIf
		
		// Somo realizado
		dbSelectArea("QM6")
		dbSetOrder(1)
		dbSeek(cFilial+QM2->QM2_INSTR+QM2->QM2_REVINS)
		lOk := .F.
		While ! Eof()
			
			If QM6->QM6_FILIAL+QM6->QM6_INSTR+QM6->QM6_REVINS != ;
				cFilial+QM2->QM2_INSTR+QM2->QM2_REVINS
				Exit
			EndIf
			
			If SubStr(DtoS(QM6->QM6_DATA),1,6) < SubStr(DtoS(mv_par03),1,6)
				dbSkip()
				Loop
			EndIf
			
			If SubStr(DtoS(QM6->QM6_DATA),1,6) > SubStr(DtoS(mv_par04),1,6)
				Exit
			EndIf
			lOk := .T.
			nTotPrev ++
			nTotReal ++
			dbSkip()
			
		EndDo
		
		dbSelectArea("QM2")
		If lOk
			dbSkip()
			Loop
		EndIf
		
		nTotPrev ++
		
	EndIf
	
	// verifica validade por dia
	If mv_par18 == 2

		lOk := .F.
		
		If QM2->QM2_VALDAF < mv_par03 .or.;
			QM2->QM2_VALDAF > mv_par04
			
			// Somo realizado
			dbSelectArea("QM6")
			dbSetOrder(1)
			dbSeek(cFilial+QM2->QM2_INSTR+QM2->QM2_REVINS)
			lOk := .F.
			While QM6->QM6_FILIAL + QM6->QM6_INSTR+QM6->QM6_REVINS == ;
				QM2->QM2_FILIAL + QM2->QM2_INSTR+QM2->QM2_REVINS
				
				If QM6->QM6_DTPREV >= mv_par03 .and.;
					QM6->QM6_DTPREV <= mv_par04
					
					lOk := .T.
					nTotPrev ++
					nTotReal ++
					
				EndIf
				
				QM6->(DbSkip())
				
			EndDo
			
		EndIf
		
		DbSelectArea("QM2")
		// Somo a quantidade de dias para verificar se
		// est� dentro do per�odo
		If (QM2->QM2_VALDAF+mv_par19) < mv_par03
			dbSkip()
			Loop
		EndIf
		
		// Somo a quantidade de dias para verificar se est� dentro
		// do per�odo
		If QM2->QM2_VALDAF + mv_par19 > mv_par04
			//		If QM2->QM2_VALDAF > ( mv_par04 + mv_par19 )
			dbSkip()
			Loop
		EndIf
		
		nTotPrev ++
		
		dbSelectArea("QM2")
		If lOk
			dbSkip()
			lOk := .F.
			Loop
		EndIf
		
	EndIf
	
	IF li > 53
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
	End
	
	nPrevNaoReal ++
	
	@li,000 PSAY QM2->QM2_INSTR
	@li,017 PSAY QM2->QM2_REVINS
	@li,022 PSAY QM2->QM2_TIPO
	@li,039 PSAY QM2->QM2_DEPTO
	@li,049 PSAY QM2->QM2_RESP
	@li,066 PSAY STR(QM2->QM2_FREQAF,4)
	@li,071 PSAY SubStr(QM2->QM2_FABR,1,16)
	
	// LABORATORIO EXTERNO
	If mv_par07 == 3 .or. ( mv_par07 == 1 .and. QM9->QM9_ORGAFE == "E" )
		@li,088 PSAY QM9->QM9_LABOR
		
		// LABORATORIO INTERNO
	ElseIf mv_par07 == 2  .or. ( mv_par07 == 1 .and. QM9->QM9_ORGAFE == "I" )
		@li,088 PSAY QM9->QM9_DEPTO
		
	EndIf
	
	@li,105 PSAY DTOC(QM2->QM2_VALDAF)
	
	li++
	
	dbSkip()
	Loop
	
EndDo

IF li > 53
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
EndIf

@li,00 PSAY Repl("-",132)
li++
@li,00 PSAY STR0012 + Str( nTotPrev,4 ) // "Total Previsto no Periodo.....: "
li++
@li,00 PSAY STR0013 + Str( nTotReal,4 ) // "Total Realizado no Periodo....: "
li++
@li,00 PSAY STR0014 + Str((100/nTotPrev)*nPrevNaoReal,6,2) + "%" // "Previstas e nao realizadas....:"

Roda( cbCont, cbTxt, Tamanho )

Set Device To Screen
Set Filter To

RetIndex("QM2")
dbSetOrder(nOrder)
dbGoto(nRecno)
FErase(cIndice+OrdBagExt())

If aReturn[5] = 1
	Set Printer TO
	dbCommitall()
	ourspool(wnrel)
End

MS_FLUSH()

Return(Nil)
