#INCLUDE "PROTHEUS.CH"
#INCLUDE "QMTM400.CH"


/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o    � QMTM400	� Autor � Wanderley Goncalves   � Data � 23.06.98 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Rotina de Recalculo de Incerteza  				          潮�
北�          � (sempre sobre a ultima revisao)   				          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � Void QMTM400						                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so	     � SIGAQMT							                          潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 			          潮�
北媚哪哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� PROGRAMADOR  � DATA   � BOPS �	MOTIVO DA ALTERACAO		              潮�
北媚哪哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Antonio      �14/05/99�------�  Testa a tecla ESC e a opcao de        潮�
北�				 �		  �		 �	 CANCELAR na Pergunte()     	      潮�
北媚哪哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Antonio      �19/07/99�22057 � Parametro de, ate para Status          潮� 
北� Denis Martins�29/11/00矼elhor� Correcao de gravacao campos QM7_ADEQ,  潮� 
北�              �        �      � QM7_EXAT,QM7_ ACEIT.Correcao de grava- 潮�
北�              �        �      � cao do Arq. Temporario.                潮�
北滥哪哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/

Function QMTM400(cAlias,nReg,nOpcx)

Local aTMPStru := {}
Local nCntFor
Local nLastKey := 0
Local oTmpTable := NIL

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Privates para efetuar os calculos     �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Private Inclui		:= .F.
Private Altera		:= .T.
Private cMtInstr	:= ''
Private cMtRevIns := ''
Private dMtData
Private cMtResp	:= ''
Private cMtTotHr	:= ''
Private cMtRepRepr := ''
Private cPerg := "QMM400"
Private lEnd := .F.

Private nPosEsc	:= 01
Private nPosPad	:= 02
Private nPosEsp	:= 03
Private nPosMed	:= 04
Private nPosObs	:= 05
Private nPosSec	:= 06
Private nPosIns	:= 07
Private nPosNco	:= 08
Private nPosITB	:= 09
Private nPosCar	:= 10
Private nPosExt	:= 11
Private nPosGer	:= 12
Private nPosTp5	:= 13
Private aMedicoes := {}
Private dProxAfer
Private aResult := {}
Private  cSeql			:= "00"
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Inicializa as Variaveis da Enchoice							 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
dbSelectArea("QM6")
M->QM6_INSTR := QM6->QM6_INSTR
M->QM6_REVINS := QM6->QM6_REVINS
M->QM6_DATA  := QM6->QM6_DATA
M->QM6_REPEPR := QM6->QM6_REPEPR
M->QM6_CSEQ	  := QM6->QM6_CSEQ
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Variaveis utilizadas para parametros									  �
//� mv_par01				// Instrumento Inicial							  �
//� mv_par02				// Instrumento Final 							  �
//� mv_par03				// Periodo Inicial								  �
//� mv_par04				// Periodo Final								  �
//� mv_par05				// Departamento Inicial 						  �
//� mv_par06				// Departamento Final							  �
//� mv_par07				// Orgao Calibrador Todos/Interno/Externo		  �
//� mv_par08				// Org.Calib.Intr.Inicial  					  	  �
//� mv_par09				// Org.Calib.Intr.Final    					      �
//� mv_par10				// Org.Calib.Extr.Inicial  					      �
//� mv_par11				// Org.Calib.Extr.Final    					      �
//� mv_par12				// Familia Inicial                          	  �
//� mv_par13				// Familia Final 								  �
//� mv_par14				// Fabricante Inicial							  �
//� mv_par15				// Fabricante Final								  �
//� mv_par16				// Status de  			                          �
//� mv_par17             	// Status ate                               	  �
//� mv_par18				// Usu爎io Inicial 								  �
//� mv_par19				// Usu爎io Final 								  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Verifica as perguntas selecionadas                           �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If !Pergunte(cPerg,.T.)
	Return .F.
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Cria Arq. Temporario para guardar recalculos de incerteza  				 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
aadd(aTMPstru,{ "TMP_FILIAL", "C", TamSX3("QM7_FILIAL")[1 ],0})
aadd(aTMPstru,{ "TMP_INSTR" , "C", TamSX3("QM7_INSTR")[1]  ,0})
aadd(aTMPstru,{ "TMP_REVINS", "C", TamSX3("QM7_REVINS")[1] ,0})
aadd(aTMPstru,{ "TMP_DATA"  , "D", TamSX3("QM7_DATA")[1]   ,0})
aadd(aTMPstru,{ "TMP_ESCALA", "C", TamSX3("QM7_ESCALA")[1] ,0})
aadd(aTMPstru,{ "TMP_REVESC", "C", TamSX3("QM7_REVESC")[1] ,0})
aadd(aTMPstru,{ "TMP_PONTO" , "C", TamSX3("QM7_PONTO")[1]  ,0})
aadd(aTMPstru,{ "TMP_REVPAD", "C", TamSX3("QM7_REVPAD")[1] ,0})
aadd(aTMPstru,{ "TMP_EXAT"  , "C", TamSX3("QM7_EXAT")[1]   ,0})
aadd(aTMPstru,{ "TMP_ADEQ"  , "C", TamSX3("QM7_ADEQ")[1]   ,0})
aadd(aTMPstru,{ "TMP_ACEIT" , "C", TamSX3("QM7_ACEIT")[1]  ,0})
aadd(aTMPstru,{ "TMP_INCERT", "C", TamSX3("QM7_INCERT")[1] ,0})
aadd(aTMPstru,{ "TMP_ERSIST", "C", TamSX3("QM7_ERSIST")[1] ,0})
aadd(aTMPstru,{ "TMP_RESULT", "C", TamSX3("QM7_RESULT")[1] ,0})
aadd(aTMPstru,{ "TMP_CSEQ"  , "C", TamSX3("QM7_CSEQ")[1] ,0})

oTmpTable := FWTemporaryTable():New( "TMP" )
oTmpTable:SetFields( aTMPstru )
oTmpTable:AddIndex("indice1", {"TMP_INSTR","TMP_REVINS","TMP_DATA"} )
oTmpTable:Create()

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Verifica se apertou o botao cancela �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If nLastKey == 27
	Return
EndIf

dbSelectArea( "QM6" )
dbSetOrder(1)
dbSeek( xFilial() + mv_par01 )

While !Eof()
	
	If QM6->QM6_FILIAL != xfilial()
		Exit
	EndIf
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Verifica o cigo do instrumento.                               �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If ( QM6->QM6_INSTR > mv_par02 )
		Exit
	EndIf
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Se n刼 est� entre os periodos informados, n刼 imprime.          �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If ( QM6->QM6_DATA < mv_par03 .or. QM6->QM6_DATA > mv_par04 )
		dbSkip()
		Loop
	EndIf
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Procura o instrumento relacionado com o cabe嘺lho               �
	//� e posiciona os arquivos relacionados.                           �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	dbSelectArea( "QM2" )
	dbSetOrder(1)
	dbSeek( xFilial() + QM6->QM6_INSTR + Inverte(QM6->QM6_REVINS) )
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Procura o DEPARTAMENTO no QAD.                                  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	dbSelectArea( "QAD" )
	dbSetOrder(1)
	dbSeek( xFilial() + QM2->QM2_DEPTO )
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Procura o RESPONSAVEL NO SRA.                                   �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	dbSelectArea("QAA")
	dbSetOrder(1)
	dbSeek( cFilAnt + QM2->QM2_RESP )
	
	dbSelectArea( "QM6" )
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Se n刼 est� entre os departamentos informados, n刼 imprime.     �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If ( QM2->QM2_DEPTO < mv_par05 .or. QM2->QM2_DEPTO > mv_par06 )
		dbSkip()
		Loop
	EndIf
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Verifico O.C. interno e externo                                 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If mv_par07 == 1
		If ! Calibrador(0,mv_par08,mv_par09,mv_par10,mv_par11)
			dbSkip()
			Loop
		EndIf
	EndIf
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Verifico O.C. interno                                           �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If mv_par07 == 2
		If ! Calibrador(1,mv_par08,mv_par09)
			dbSkip()
			Loop
		EndIf
	EndIf
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Verifico O.C. externo                                           �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If mv_par07 == 3
		If ! Calibrador(2,,,mv_par10,mv_par11)
			dbSkip()
			Loop
		EndIf
	EndIf
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Se n刼 � a familia selecionada n刼 Imprime.                     �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If ( QM2->QM2_TIPO < mv_par12 .or. QM2->QM2_TIPO > mv_par13 )
		dbSkip()
		Loop
	EndIf
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� N刼 � o fabricante selecionado.                                 �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If ( QM2->QM2_FABR < mv_par14 .or. QM2->QM2_FABR > mv_par15 )
		dbSkip()
		Loop
	EndIf
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� Verifica o status.         												  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If QM2->QM2_STATUS < mv_par16 .Or. QM2->QM2_STATUS > mv_par17
		dbSkip()
		Loop
	EndIf
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� N刼 � o usu爎io selecionado.                                    �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If ( QM2->QM2_RESP < mv_par18 .or. QM2->QM2_RESP > mv_par19 )
		dbSkip()
		Loop
	EndIf
	
	//谀哪哪哪哪哪哪哪哪哪�
	//� Carrega aMedicoes �
	//滥哪哪哪哪哪哪哪哪哪�
	cMtInstr	:= QM6->QM6_INSTR
	cMtRevIns   := QM6->QM6_REVINS
	dMtData	    := QM6->QM6_DATA
	cMtResp	    := QM6->QM6_RESP
	cMtTotHr	:= QM6->QM6_TOTHOR
	cMtRepRepr  := QM6->QM6_REPEPR
    cSeql		:= QM6->QM6_CSEQ
 
	a140CarMed()
	
	For nCntFor := 1 to len(aMedicoes)
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		//� Calcula valores na GETDADOS �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
		aadd(aResult, a140Calc(nCntFor,.f.))
		dbSelectArea("QM7")
		If QM7->(DbSeek(xFilial("QM7")+cMtInstr+cMtRevIns+;
  			DtoS(dMtData)+cSeql+aMedicoes[nCntFor,nPosEsc]+aMedicoes[nCntFor,nPosGer,1,11]+;
  			aMedicoes[nCntFor,nPosPad]+aMedicoes[nCntFor,nPosGer,1,12]))		

			RecLock("QM7",.f.)
			
			If aMedicoes[nCntFor,nPosGer,1,6] == '1' // Incerteza c/ Confirmacao Metrologica
				Replace QM7_EXAT  with If(aResult[1,1,7],"A","R") // Exatidao
				Replace QM7_ACEIT with If(aResult[1,1,8],"A","R") // Aceitabilidade
				Replace QM7_ADEQ  with If(aResult[1,1,9],"A","R") // Adequacao
			EndIf
			
			If !empty(aResult)
				If ValType(aResult[1,1,5]) == "C"
					aResult[1,1,5] := SuperVal(aResult[1,1,5])
				Endif
				Replace QM7_INCERT with Padl(Ltrim(Str(aResult[1,1,5])),10) // Incerteza
				If ValType(aResult[1,1,2]) == "C"
					aResult[1,1,2] := SuperVal(aResult[1,1,2])
				Endif
				Replace QM7_ERSIST with Padl(Ltrim(Str(aResult[1,1,2])),10) // Desvio Medio (Maior Erro Sistematico)
			EndIf
			
			Replace QM7_RESULT with aResult[1,1,10] // Status Final
			MsUnlock()
		EndIf
		
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Grava registro de alteracao de calculo de incerteza			  �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		
		RecLock("TMP",.T.)
		
		Replace TMP_FILIAL  with xFilial()
  		Replace TMP_INSTR   with cMtInstr
  		Replace TMP_REVINS  with cMtRevIns
  		Replace TMP_DATA    with dMtData 
		Replace TMP_ESCALA  with aMedicoes[nCntFor,nPosEsc]
		Replace TMP_REVESC  with aMedicoes[nCntFor,nPosGer,1,11]
		Replace TMP_PONTO   with aMedicoes[nCntFor,nPosPad]
		Replace TMP_REVPAD  with aMedicoes[nCntFor,nPosGer,1,12]
		Replace TMP_EXAT    with If(aResult[1,1,7],"A","R")
       	Replace TMP_ADEQ    with If(aResult[1,1,8],"A","R")
       	Replace TMP_ACEIT   with If(aResult[1,1,9],"A","R")
		If Valtype(aResult[1,1,5]) = "N"
			Replace TMP_INCERT  with Padl(Ltrim(Str(aResult[1,1,5])),10)
		Else
			Replace TMP_INCERT  with Padl(Ltrim(aResult[1,1,5]),10)
		EndIf
		If Valtype(aResult[1,1,2]) = "N"
			Replace TMP_ERSIST  with Padl(Ltrim(Str(aResult[1,1,2])),10)
		Else
			Replace TMP_ERSIST  with Padl(Ltrim(aResult[1,1,2]),10)
		EndIf
		Replace TMP_RESULT  with aResult[1,1,10]
		Replace TMP_CSEQ	with cSeql
		
		MsUnLock()
		
	Next nCntFor
	
	DbSelectArea("QM6")
	DbSkip()
	
EndDo

If TMP->(Eof()) .and. TMP->(Bof())
	Help( " ", 1, "M400NEM" ) // N苚 foi efetuado nenhum recalculo
Else
	MessageDlg(OemToAnsi(STR0002),,2) //"Rec爈culo encerrado com sucesso"
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Desmonta arquivos temporarios										  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

If ( Select("TMP") != 0 )
	oTmpTable:Delete()
EndIf

Return(Nil)
