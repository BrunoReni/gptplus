#INCLUDE "PROTHEUS.CH"
#INCLUDE "QEPXFUN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � QEPXFUN  � Autor � Equipe Quality        � Data � 06/03/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotinas comuns aos modulos do SIGAQIE e SIGAQIP.           ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���			   � 		�      � 										  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 � QepAdmAne� Autor � Cleber Souza          � Data � 07/06/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Administra os arquivos anexos.               			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QepAdmAne(EXPC1,EXPN1)									  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� EXPC1 = Nome do Arquivo Anexo.   				 	      ���
���			 � EXPN2 = 1 - Inclui										  ���
���			 � 		   2 - Exclui										  ���
���			 � EXPC3 = Nome do Alias do Programa.   					  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � EXPC1 - Arquivo Anexo									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGAQIE													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QepAdmAne(cArqTMP,nOpc,cAlias)
Local   cQPathTrm   := Alltrim(Alltrim(QDOPATH()[3]))
Local   cDelAnexo   := Alltrim(GetMv("MV_QDELFNC")) // "Apagar Documentos Anexos no Diretorio Temporario"
Local   cQPathDoc   := IIF(cAlias == "QIE",Alltrim(GetMv("MV_QIEDOC")),Alltrim(GetMv("MV_QIPDOC")))
Local   nPos        := 0
Local   cArqAnexo   := " "

If !Right( cQPathTrm,1 ) == "\"
	cQPathTrm := cQPathTrm + "\"
Endif

If !Right( cQPathDoc,1 ) == "\"
	cQPathDoc := cQPathDoc + "\"
Endif

If nOpc == 1 //Inclui
	cArqAnexo:= Substr(cAlias,2,2)+StrZero(Val(QA_SEQU(Substr(cAlias,2,2),10,"N","")),10)      
	
	nPos  := RAT(".",cArqTmp)
    cArqAnexo := cArqAnexo + Substr(cArqTmp,nPos,(Len(Alltrim(cArqTmp))+1)-nPos)

	//Copia TMP para o nome correto. 
	If File(cQPathTrm+cArqTmp)
		__CopyFile(cQPathTrm + cArqTmp,cQPathTrm + cArqAnexo)
		If !File(cQPathTrm + cArqAnexo)
			Help(" ",1,"QEPNAOCOP")
			Return(cArqAnexo)
		Endif				
	EndIf	
                                
	If cDelAnexo == "1"	
		FErase(cQPathTrm+cArqTmp)
	EndIf

	//Copia para o Server
	If !CpyT2S(cQPathTrm + cArqAnexo,cQPathDoc,.T.)
		Help(" ",1,"QEPNAOCOP")
		Return(cArqAnexo)
	Endif

ElseIf nOpc == 2  //Exclui
    
	//Apaga o arquivo no servidor
	If File(cQPathDoc+Alltrim(cArqTmp))
		FErase(cQPathDoc+Alltrim(cArqTmp))
    EndIf
	                             
	//Verifica se existe local e apaga.
	If File(cQPathTrm+Alltrim(cArqTmp))
		FErase(cQPathTrm+Alltrim(cArqTmp))
    EndIf
EndIf

Return(cArqAnexo)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CalcHora  � Autor � Marcelo Pimentel      � Data � 06.10.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna o numero de horas.                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �QIPA010()                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CalcHora(nHrIni,nHrFim,cLimite,lVrfHrNeg)
Local nVar		:= 0
Local nInt		:= 0
Local nDec		:= 0
Local cResult	:= 0
Local nPosTmpI	:= At(":",nHrIni)
Local nPosTmpF	:= At(":",nHrFim)

Default lVrfHrNeg := .F.

nIni := (Val(Left(nHrIni,nPosTmpI-1)) * 60) + Val(Right(AllTrim(nHrIni),2))
nFim := (Val(Left(nHrFim,nPosTmpF-1)) * 60) + Val(Right(AllTrim(nHrFim),2))

//��������������������������������������������������������������������������Ŀ
//�Limite Inferior ou Carregando Ensaio da Especificacao Inferior/Superior.  �
//����������������������������������������������������������������������������
If cLimite == "I"
	nFim := Val(StrTran(Str(nFim),"-",""))
	nVar := nIni - nFim
	//��������������������������������������������������������������������������Ŀ
	//�Caso o hora final seja menor que a Incial, o sinal devera ser negativo.   �
	//����������������������������������������������������������������������������
	If lVrfHrNeg
		If nFim < nIni
			If At("-",Str(nVar)) == 0
				nVar:= -nVar
			EndIf
		EndIf
	EndIf
Else
	nVar := nIni + nFim
EndIf

nInt := Int(nVar / 60)
nDec := Mod(nVar , 60)

cResult := StrZero(nInt,Iif(Len(Alltrim(Str(nInt)))==1,2,Len(Alltrim(Str(nInt)))))+":"+StrZero(nDec,2)

Return(cResult)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �QA_Def5429� Autor � Marcos Cesar          � Data �05.08.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Calcula o Indice de Defeitos baseado na Norma NBR-5429.     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �ExpN1 := QA_Def5429(ExpA1,ExpN1,ExpN2,ExpN3)                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpA1 == Array com as medicoes.                             ���
���          �ExpN1 == Limite inferior com tolerancia.                    ���
���          �ExpN2 == Limite superior com tolerancia.                    ���
���          �ExpC1 == Codigo da Norma (Plano).                           ���
���          �ExpN3 == Tamanho da Amostra.                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpA1[1] = Media											  ���
���			 �     [2] = Desvio Padrao									  ���
���			 �     [3] = PI												  ���
���			 �     [4] = PS												  ���
���			 �     [5] = PI+PS											  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QA_Def5429(aMedicao,nLimInf,nLimSup,cPlano,nTamAmostra)
Local aMediaDV := {}
Local nIndQS   := 0
Local nIndQI   := 0
Local nIndDef  := 0                   
Local nPI      := 0
Local nPS      := 0

//�������������������������������������������������������������������������Ŀ
//� Calcula a Media e o Desvio Padrao. Retorno :                            �
//�                                                                         �
//� aMediaDV[1] : Media                                                     �
//� aMediaDV[2] : Desvio Padrao                                             �
//���������������������������������������������������������������������������
aMediaDV := QA_CalcDV(aMedicao)

If nLimInf > 0
	//�������������������������������������������������������������������������Ŀ
	//� Calcula o QI.                                                           �
	//���������������������������������������������������������������������������
	nIndQI := (aMediaDV[1] - nLimInf) / aMediaDV[2]
	nIndQI := Round(nIndQI,2)
	
	If nIndQI > 3.89
		nPI := 0
	ElseIf nIndQI < (3.89*-1)
		nPI := 100
	Else
		QA1->(dbSetOrder(1))
		QA1->(dbSeek(xFilial("QA1") + cPlano + Str(nTamAmostra,4) + Transform(Abs(nIndQI), "@E 99.99"), .T.))
		If nIndQI < 0
			nPI := Round(100-QA1->QA1_VLREPD,2)
		Else
			nPI := QA1->QA1_VLREPD
		EndIf
	EndIf
EndIF

If nLimSup > 0
	//�������������������������������������������������������������������������Ŀ
	//� Calcula o QS.                                                           �
	//���������������������������������������������������������������������������
	nIndQS := (nLimSup - aMediaDV[1]) / aMediaDV[2]
	nIndQS := Round(nIndQS,2)
	
	//�������������������������������������������������������������������������Ŀ
	//� Pesquisa o Arquivo QA1 com o valor do QI.                               �
	//���������������������������������������������������������������������������
	If nIndQS > 3.89
		nPS := 0
	ElseIf nIndQS < (3.89*-1)
		nPS := 100
	Else
		QA1->(dbSetOrder(1))
		QA1->(dbSeek(xFilial("QA1") + cPlano + Str(nTamAmostra,4) + Transform(Abs(nIndQS), "@E 99.99"), .T.))
		If nIndQS < 0
			nPS := Round(100-QA1->QA1_VLREPD,2)
		Else
			nPS := QA1->QA1_VLREPD
		EndIf
	EndIf
EndIf

nTamAmostra := If(nTamAmostra>140,140,nTamAmostra)
	
nIndDef  := (nPI+nPS)
aRetorno := {aMediaDV[1],aMediaDV[2],nPI,nPS,nIndDef}  
Return(aRetorno) 

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun�ao	 �QEP_RetAmostra� Autor � Paulo Emidio de Barros� Data �22/08/2003���
�����������������������������������������������������������������������������Ĵ��
���Descri�ao � Define a amostragem a ser aplicada de acordo com a selecao do  ���
���		     � Plano de Amostragem                                            ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � QEP_RetAmostra(cTipAmo,cPlaAmo,cNivel,cNQA,cTamAmo,cCpoAmo,;   ���
���			 � 				  lSeparaPlano)	  								  ���
�����������������������������������������������������������������������������Ĵ��
���Parametros� EXPC1 = Tipo do Plano de Amostragem							  ���
���			 � EXPC2 = Plano de Amostragem									  ���
���			 � EXPC3 = Nivel do Plano de Amostragem						      ���
���			 � EXPC4 = NQA													  ���
���			 � EXPC5 = Tamanho da Amostra									  ���
���			 � EXPC6 = Campo que define o Tamanho da Amostra				  ���
���			 � EXPL1 = Indica se as Amostragens definidas no Plano Interno se-���
���			 �         rao separadas.										  ���
�����������������������������������������������������������������������������Ĵ��
���Retorno	 � EXPA1 = Amostragens definidas no Plano						  ���
�����������������������������������������������������������������������������Ĵ��
���Uso		 � Generico														  ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/                              
Function QEP_RetAmostra(cTipAmo,cPlaAmo,cNivel,cNQA,cTamAmo,cCpoAmo,lSeparaPlano)
Local aAreaAnt   := GetArea()
Local aRetorno   := {}
Local cNorma     := ' '
Local cSequencia := ' '
Local cTipo      := ' '                     
Local cCodAmo    := ' '
Local nAmostra1  := 0
Local nAceite1   := 0
Local nRejeite1  := 0
Local nAmostra2  := 0
Local nAceite2   := 0
Local nRejeite2  := 0
Local cAmostra   := " "
Local aPlaInt1   := {} //Amostragem Simples
Local aPlaInt2   := {} //Amostragem Dupla
Local cTamFor    := " "  
Local nTamAmo    := 0
                
cNorma := QA_Plano(cTipAmo)

lSeparaPlano := If(lSeparaPlano==NIL,.F.,lSeparaPlano)

//��������������������������������������������������������������Ŀ
//�Verifica tipo de Inspecao a ser aplicada de acordo c/ o Plano �
//����������������������������������������������������������������
If (cTipAmo == '1') .Or. (cTipAmo == 'N') .Or. ; //NBR5426 
   (cTipAmo == '3') .Or. (cTipAmo == 'I')        //Plano Interno
	cTipo := If(Right(cPlaAmo,1)=="A","AT",If(Right(cPlaAmo,1)=="N","NO","SE"))
ElseIf (cTipAmo == '2') .Or. (cTipAmo == 'Z') .Or.; //Zero Defeito (QS9000)
	   (cTipAmo == '4') .Or. (cTipAmo == 'T')       //Plano Texto	
	cTipo := "QS"
ElseIf (cTipAmo == '5') .Or. (cTipAmo == 'B') //NBR5429
	cTipo := If(AllTrim(cPlaAmo)=="A","AT",If(AllTrim(cPlaAmo)=="N","NO","SE"))
EndIf
        
//��������������������������������������������������������������Ŀ
//� Posiciona o Codigo das Amostras de acordo com o Plano        �
//����������������������������������������������������������������
cAmostra := Str(SuperVal(cTamAmo),8)
cNivel   := If(cPlaAmo=="QS",cPlaAmo,cNivel) //Verifica se o Plano e Zero Defeito

dbSelectArea("QA6")
dbSetOrder(2)
dbSeek(xFilial("QA6")+cNorma+cNivel+cAmostra,.T.)
If !Eof()
	cCodAmo := QA6_CODAMO
EndIf
   
//��������������������������������������������������������������Ŀ
//�Define a sequencia para que na amostragem dupla, seja retorna-�
//�das as sequencias 1 e 2.										 �
//����������������������������������������������������������������
cSequencia := If(Left(cPlaAmo,1)<>'D','0','1')

dbSelectArea("QA7") 
dbSetOrder(3)

//��������������������������������������������������������������Ŀ
//� Realiza o tratamento para a Amostragem definida no Plano In- �
//� terno.														 �
//����������������������������������������������������������������
If (cTipAmo == "3") .Or. (cTipAmo == "I") //Plano Interno

	//��������������������������������������������������������������Ŀ
	//� aRetorno [x,1] = ACEITE 1                                    �
	//�          [x,2] = REJEITE 1                                   �
	//� 		 [x,3] = AMOSTRA 1 									 �
	//�          [x,4] = ACEITE 2 									 �
	//� 		 [x,5] = REJEITE 2									 �
	//� 		 [x,6] = AMOSTRA 2									 �
	//�          [x,7] = SEQUENCIA									 �
	//����������������������������������������������������������������
	aRetorno := {}

	dbseek(xFilial("QA7")+cNorma+cNQA+cCodAmo)
	While !Eof() .And. QA7_FILIAL==xFilial("QA7") .And. QA7_PLANO==cNorma .And. QA7_NQA==cNQA .And. QA7_CODAMO==cCodAmo

        Aadd(aRetorno,Array(7))
        
		If Empty(QA7_NO_FOR)
			nTamAmo := If(QA7_NO_AMO>SuperVal(cTamAmo),SuperVal(cTamAmo),QA7_NO_AMO) 
		Else       
			cTamFor := QA7->QA7_NO_FOR
			If !Empty(cTamFor) .And. !Empty(cTamAmo)
				cTamFor := AllTrim(StrTran(cTamFor,"#Tam.Lote#",cTamAmo))
				nTamAmo := &(cTamFor)                                    
			Else	
				nTamAmo := 0
			EndIf          
		EndIf	               
		
		//Armazena por sequencia, o Aceite e o Rejeite das Amostragens Simples 
		aRetorno[Len(aRetorno),1] := QA7_NO_ACE //Aceite 1
		aRetorno[Len(aRetorno),2] := QA7_NO_REJ //Rejeite 1
		aRetorno[Len(aRetorno),3] := nTamAmo    //Tamanho da Amostra 1	
		
		If Empty(QA7_SE_FOR)        
			nTamAmo := If(QA7_SE_AMO>SuperVal(cTamAmo),SuperVal(cTamAmo),QA7_SE_AMO)
	    Else         
			cTamFor := QA7->QA7_SE_FOR
			If !Empty(cTamFor) .And. !Empty(cTamAmo)
				cTamFor := AllTrim(StrTran(cTamFor,"#Tam.Lote#",cTamAmo))
				nTamAmo := &(cTamFor)
			Else          
				nTamAmo := 0
			EndIf	
	    EndIf    

		//Armazena por sequencia, o Aceite e o Rejeite das Amostragens Duplas
		aRetorno[Len(aRetorno),4] := QA7_SE_ACE //Aceite 2
		aRetorno[Len(aRetorno),5] := QA7_SE_REJ //Rejeite 2
		aRetorno[Len(aRetorno),6] := nTamAmo    //Tamanho da Amostra 2	
		aRetorno[Len(aRetorno),7] := QA7_SEQUE  //Sequencia
		
		dbSelectArea("QA7")
		dbSkip()
		
	EndDo
	
	//��������������������������������������������������������������Ŀ
	//� Formata o retorno do vetor para os Planos de Amostragens do  �
	//� Tipo Interno, devolvendo os mesmos em dois vetores, sendo:	 �
	//� x[1] = Sequencia											 �
	//�      = Aceite 1												 �
	//�      = Rejeite 1											 �
	//�      = Tamanho da Amostra 1									 �
	//� x[2] = Sequencia											 �
	//�      = Aceite 2												 �
	//�      = Rejeite 2											 �
	//�      = Tamanho a Amostra 2									 �
	//����������������������������������������������������������������
    If Len(aRetorno) == 0  //Verifica se o vetor nao esta definido com as Amostragens
    	Aadd(aRetorno,Afill(Array(7),0))
	    aRetorno[Len(aRetorno),7]:= " "
	EndIf        
	
	If lSeparaPlano
		Aeval(aRetorno,{|x,y|Aadd(aPlaInt1,{x[7],x[1],x[2],x[3]}),Aadd(aPlaInt2,{x[7],x[4],x[5],x[6]})})
		aRetorno := {aClone(aPlaInt1),aClone(aPlaInt2)}
	EndIf
		                                             
//��������������������������������������������������������������Ŀ
//� Posiciona o Tamanho das Amostras de acordo com o Codigo      �
//����������������������������������������������������������������
Else                               
	aRetorno := Afill(Array(6),0)
	
	dbseek(xFilial("QA7")+cNorma+cNQA+cCodAmo+cSequencia)
	If !Eof()
	
	    //Verifica se o Plano e QS-9000
	 	If cTipo == "QS"
			nAceite1  := 0
			nRejeite1 := 1
		Else		
			nAceite1  := &("QA7_"+cTipo+"_ACE")
			nRejeite1 := &("QA7_"+cTipo+"_REJ")
		EndIf                           
		nAmostra1 := &("QA7_"+cTipo+"_AMO")
		nAmostra1 := If(nAmostra1>SuperVal(cTamAmo),SuperVal(cTamAmo),nAmostra1)
		    
		//Caso a Amostragem seja dupla, considera a segunda Sequencia
		If cSequencia == '1'      
			dbSkip() //Considera a sequencia 2
		
			nAceite2  := &("QA7_"+cTipo+"_ACE")
		   	nRejeite2 := &("QA7_"+cTipo+"_REJ")
			nAmostra2 := &("QA7_"+cTipo+"_AMO")
			nAmostra2 := If(nAmostra2> SuperVal(cTamAmo),SuperVal(cTamAmo),nAmostra2)
		
		EndIf
		aRetorno[1] := nAmostra1 //Amostra 1
		aRetorno[2] := nAceite1  //Aceite  1
		aRetorno[3] := nRejeite1 //Rejeite 1
		aRetorno[4] := nAmostra2 //Amostra 2
		aRetorno[5] := nAceite2  //Aceite  2
		aRetorno[6] := nRejeite2 //Rejeite 2
	EndIf
EndIf

RestArea(aAreaAnt)
Return(aRetorno)      
