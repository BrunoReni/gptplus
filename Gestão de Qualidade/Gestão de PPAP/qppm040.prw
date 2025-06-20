#INCLUDE "PROTHEUS.ch"
#INCLUDE 'FILEIO.CH'    
#INCLUDE 'QPPM040.CH'    
                                                                             
#Define PARETO "6"      

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � QPPM040	  � Autor � Cleber Souza          � Data � 17/08/05 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Grafico de Pareto - FMEA磗 Processo e Projeto.        	    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   � QPPM040()                                                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� EXPC1 = Numero da Peca      								    潮�
北�			 � EXPC2 = Revisao da Pecao 								    潮�
北�			 � EXPC3 = Tipo do Grafico (1= Projeto, 2= Processo)		    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � SIGAPPAP				                 					    潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       潮�
北媚哪哪哪哪哪哪穆哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� PROGRAMADOR  � DATA   � BOPS  � MOTIVO DA ALTERACAO                     潮�
北媚哪哪哪哪哪哪呐哪哪哪哪拍哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪哪牧哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/
Function QPPM040(cPeca,cRevisao,cTipo)

Local cPerg     := "QPPM40"
Private aNPR    := {}
Private aDados  :={}

If Pergunte(cPerg,.T.) 
	QPPM40PROC(cPeca,cRevisao,cTipo)
EndIF

Return          

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砆PPM40PROC篈utor  矯leber Souza        � Data �  17/08/05   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     �  Gera玢o do Grafico de Pareto.                             罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � QPPM040                                                    罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function QPPM40PROC(cPeca,cRevisao,cTipo) 
Local aDad64      := {}
Local cArqSPC     := ""
Local cDir        := GetMv("MV_QDIRGRA") //Diretorio para geracao do grafico
Local cSenhas     := "1"
Local lExistChart := FindFunction("QIEMGRAFIC") .AND. GetBuild() >= "7.00.170117A"
Local nI          := 0
	      
// Verifica se o diretorio do grafico �  um  diretorio Local
If !QA_VerQDir(cDir) 
	Return
EndIf

If cTipo=="1"
	//Pesquisa dados referentes ao projeto
	DbSelectArea("QK6")
	DbSetOrder(4)
	DbSeek(xFilial("QK6")+cPeca+cRevisao)

	While !Eof() .and. cPeca+cRevisao == QK6->QK6_PECA+QK6->QK6_REV
    	AADD(aNPR,{QK6->QK6_SEQ,IIF(mv_par01==1,QK6->QK6_NPR,QK6->QK6_RNPR)})
    	QK6->(dbSkip())
    EndDo 
    
Else
	//Pesquisa dados referentes ao projeto
	DbSelectArea("QK8")
	DbSetOrder(4)
	DbSeek(xFilial("QK8")+cPeca+cRevisao)

	While !Eof() .and. cPeca+cRevisao == QK8->QK8_PECA+QK8->QK8_REV
    	AADD(aNPR,{QK8->QK8_SEQ,IIF(mv_par01==1,QK8->QK8_NPR,QK8->QK8_RNPR)})
    	QK8->(dbSkip())
    EndDo 

EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Organiza array com as NPRs.		     �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If mv_par02==2
	aNPR := aSort(aNPR,,, { | x,y | x[2] < y[2] })
ElseIf mv_par02==3
   	aNPR := aSort(aNPR,,, { | x,y | x[2] > y[2] })
EndIF

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Monta vetor com os dados do grafico  �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Aadd(aDados,"QACHART.DLL - PARETO")

//Define Texto do Titulo
aAdd( aDados,"[TITLE]" )

If cTipo=="1"
	aAdd( aDados,STR0001) //" - FMEA de Projeto"
Else
	aAdd( aDados,STR0002) //" - FMEA de Processo"
EndIF

Aadd(aDados,"[LANGUAGE]")
Aadd(aDados,Upper(__Language) )

//Tira a linha do Pareto
aAdd( aDados,"[LINHA PARETO]" )
aAdd( aDados,"FALSE" )

//Define o Rodape do grafico.
aAdd( aDados,"[FOOT]" )
aAdd( aDados,STR0003+Alltrim(cPeca)+STR0004+Alltrim(cRevisao) ) //"Peca: "###" Revisao: "

Aadd(aDados,"[DADOS PARETO]")

For nI := 1 to Len(aNPR)
	Aadd(aDados,AllTrim(aNPR[nI,2])+";"+Alltrim(aNPR[nI,1]))
	If lExistChart
		Aadd(aDad64,{ AllTrim( aNPR[nI,2] ), aNPR[nI,1]})
	EndIf
Next nI

Aadd(aDados,"[FIM DADOS PARETO]")

// Gera o nome do arquivo SPC
cArqSPC := QPP40NoArq(cDir)

If !Empty(cArqSPC)
	If lExistChart	
		QIEMGRAFIC(aDad64, 2)
	Else
		//谀哪哪哪哪哪哪哪哪哪哪�
		//� Grava o arquivo SPC �
		//滥哪哪哪哪哪哪哪哪哪哪�
		QPP40GerAr(aDados ,cArqSPC, cDir)

		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//� Controle para abertura do grafico. Caso o grafico fique aberto por mais de 3 minutos �
		//� nao perca a conexao.																 �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		PtInternal(9,"FALSE")
			
		Calldll32("ShowChart",cArqSPC,PARETO,cDir,PARETO,Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO"))

		// Exclui o arquivo SPC gerado	
		Ferase(cArqSPC)
		PtInternal(9,"TRUE")
	EndIf
Else
	MessageDlg(STR0005,,3)  //"N鋙 foram encontradas NPRs, a partir dos dados solicitados."
EndIf

Return
          

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o	 砆PP40NoArq� Autor � Cleber Souza          � Data � 17/08/05 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Gera nome do arquivo SPC									  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � QPPM040													  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function QPP40NoArq(cDir)
Local cArq	:= ""
Local nI 	:= 0
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Verifica o arquivo disponivel com extensao SPC �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
For nI := 1 to 99999
	cArq := "QPP" + StrZero(nI,5) + ".SPC"
	If !File(Alltrim(cDir)+cArq)
		Exit
	EndIf
Next nI
Return cArq     

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噭o	 砆PP40GerAr� Autor � Cleber Souza      	� Data �17/08/05  潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o 矴rava um arquivo Txt no formato da OCX QC_CHART		      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros矱xpA1 - Array com os dados a gravar						  潮�
北�			 矱xpC1 - Arquivo para dados								  潮�
北�			 矱xpC2 - Diretorio para gerar o arquivo					  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno	 矱xpL1 - TRUE - caso criou o arquivo corretamente e FALSE	  潮�
北�			 � caso tenha havido alguma falha							  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so		 矴enerico													  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function QPP40GerAr( aDados , cFile , cDir )
Local lOk		:= .T.
Local nHandle	:= 0
Local nSec		:= 0

Default cFile	:= "QACHART.SPC"
Default aDados	:= { }

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Formato do array a ser passado		    �
//� Array de uma coluna contendo uma string �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
If File( cDir+cFile )
	If FErase(cDir+cFile) == 0
		lOk := .T.
	else
		nSec := Seconds()
		While FErase(cDir+cFile) <> 0
			if Seconds() > nSec + 5
				lOk := .F.
				Exit
			Endif
		EndDo
		if !lOk
			MsgStop(STR0006,STR0007)	//"Outro usu醨io utilizando o arquivo. Tente novamente" #### "Aten玢o"
		Endif
	Endif
Endif

If lOk
	IF (nHandle := FCREATE(cDir+cFile, FC_NORMAL)) == -1
		lOk := .F.
		MsgStop(STR0008 + cDir+cFile,STR0007) //"N鉶 foi poss韛el criar o arquivo para o gr醘ico " #### "Aten玢o" 
	Endif
Endif

If lOk
	aEval( aDados, { |cTexto,nX| FWrite( nHandle, cTexto + Chr(13)+Chr(10) ), Len(cTexto) } )
	FClose(nHandle)
Endif

Return lOk
