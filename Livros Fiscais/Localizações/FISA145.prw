#INCLUDE "FISA145.ch"   
#INCLUDE "Protheus.ch"   
#INCLUDE "TopConn.ch"

/*/苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � FISA145  � Autor � DANILO SANTOS       � Data � 25.08.2021 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escricao � Funcionalidad requerida por la RG 72/20 �                  潮�
北矲ormosa - Padr髇 de Retenciones, Percepciones y Riesgo Fiscales.       潮� 
北�                                                                       潮�
北滥哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北砋so       � Fiscal - Formosa- Argentina                                潮�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/   

Function FISA145()

Local   cCombo := ""
Local   aCombo := {}
Local	 aTipo:= {}
Local   oDlg   := Nil
Local   oFld   := Nil
Private cMes   := StrZero(Month(dDataBase),2)
Private cAno   := StrZero(Year(dDataBase),4)
Private cTipo := ""
Private lRet   := .T.
Private lPer   := .T.
Private dDatIni := CTOD("  /  /  ") 
Private dDatFim := CTOD("  /  /  ") 

aAdd( aTipo, STR0002 ) //Percepiciones
aAdd( aTipo, STR0003 ) //Retenciones
aAdd( aTipo, STR0004 ) //Ambos

DEFINE MSDIALOG oDlg TITLE STR0005 FROM 0,0 TO 250,450 OF oDlg PIXEL //RN 18-2018 � Ciudad de C髍doba - Padr髇 Riesgo Fiscal
	 
	@ 006,006 TO 040,170 LABEL STR0006 OF oDlg PIXEL //"Info. Preliminar"
	@ 011,010 SAY STR0017 SIZE 065,008 PIXEL OF oFld //"Arquivo :"
	@ 020,010 COMBOBOX oCombo VAR cTipo ITEMS aTipo SIZE 65,8 PIXEL OF oFld //ON CHANGE ValidChk(cCombo)
	
	//+----------------------   
	//| Campos Check-Up
	//+----------------------
	@ 041,006 FOLDER oFld OF oDlg PROMPT STR0011 PIXEL SIZE 165,075 //"&Importa玢o de Arquivo CSV"
	
	//+----------------
	//| Campos Folder 2
	//+----------------
	@ 005,005 SAY STR0012 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta opcao tem como objetivo atualizar o cadastro    "
	@ 015,005 SAY STR0013 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Fornecedor / Cliente                                 "
	@ 025,005 SAY STR0014 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"disponibilizado pelo governo                         "
	@ 045,005 SAY STR0015 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Informe o periodo:"
	@ 045,055 MSGET cMes PICTURE "@E 99" VALID !Empty(cMes) SIZE  015,008 PIXEL OF oFld:aDialogs[1]	                                          
	@ 045,070 SAY "/" SIZE  150, 8 PIXEL OF oFld:aDialogs[1]
	@ 045,075 MSGET cAno PICTURE "@E 9999" VALID !Empty(cMes) SIZE 020,008 PIXEL OF oFld:aDialogs[1]
	
	//+-------------------
	//| Boton de MSDialog
	//+-------------------
	@ 055,178 BUTTON STR0016 SIZE 036,016 PIXEL ACTION ImpArq(aCombo,cTipo) //"&Importar"
	@ 075,178 BUTTON STR0018 SIZE 036,016 PIXEL ACTION oDlg:End() //"&Sair"

ACTIVATE MSDIALOG oDlg CENTER

Return Nil

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲uncao    � ImpArq   � Autor � Danilo Santos       � Data � 25.08.2021 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escricao � Inicializa a importacao do arquivo.                        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aPar01 - Variavel com as opcoes do combo cliente/fornec.   潮�
北�          � cPar01 - Variavel com a opcao escolhida do combo.          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Fiscal - Formosa Argentina                                 潮�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function ImpArq(aCombo,cTipo)

Local   cLine    := ""
Local cAliasTMP	:= ""	// Alias atribuido ao arquivo temporario
Local lRet	 	:= .T.
Local lnoimp := .T.
Local lProcCli := .F.
Local lProcFor := .F.
Local lProCAmb := .F.
Local cImptxt := ""
Local cPesq	  := "\"
Local cfinal  := ""
Private  cFile    := ""
Private lFor     := .F.
Private lCli     := .F.
Private lImp     := .F.
Private	cStartPath := GetSrvProfString("StartPath","")
Private lCuitSM0 := .F.
Private lAutomato := isblind()
Private oTmpTable	:= Nil	// Arquivo temporario para importacao

Default aCombo := {}
Default cTipo := ""

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//矴era arquivo temporario a partir do XLS importado �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

// Seleciona o arquivo
IF !lAutomato
	cFile := FGetFile()
	If Empty(cFile)
		MsgStop(STR0023) //"Seleccione un archivo e intente nuevamente."
		Return Nil
	EndIf
else
	cFile:=cFileAut
EndIf

If !lAutomato
	// Seleciona o arquivo
	cStartPath := StrTran(cStartPath,"/","\")
	cStartPath +=If(Right(cStartPath,1)=="\","","\")
	cfinal:= cFile
	If !Empty(cFile) 	
		If ! cFile $ cStartPath
			If ":" $ cFile
				CpyT2S(cFile,cStartPath,.T.)
			Endif
		EndIf
	EndIF
Endif
If !File(cFile)
	Return Nil
EndIf

If !lAutomato		
	If !Substr(cFile,1,6) $ cStartPath
		While AT( cPesq, cfinal) > 0  		
			Naux:=AT( cPesq, cfinal ) 
			Naux:=Naux+1
			nTamArq:= Len(cfinal)
			cfinal:= SubStr(cfinal,Naux,nTamArq)		
		EndDo
	Endif
Endif

IF !lAutomato
	// Cria e alimenta a tabela temporaria 
	Processa({|| lRet := GeraTemp(@oTmpTable,cFile,cStartPath,cfinal)})
Else
	// Cria e alimenta a tabela temporaria 
	Processa({|| lRet := GeraTemp(@oTmpTable,cFile,cStartPath,"")})
Endif

dDatIni := CTOD("01/"+cMes+"/"+cAno) 
dDatFim := LastDay(dDatIni) 

If lRet
	If Substr(cTipo,1,1) $ "1|3" // Cliente/Fornecedor - Percep玢o Ambos.
		cImptxt := "P"
		//砅rocesso de valiadacao para Clientes�
		Processa({|| PercCliFor(cImptxt,"SA1")})
		
		If lCuitSM0 
			//砅rocesso de valiadacao para Fornecedores�
			Processa({|| PercCliFor(cImptxt,"SA2")})
		Endif
	Endif
	If SubStr(cTipo,1,1) $ "2|3"  //Fornecedor - Reten玢o
		cImptxt := "R"
		//砅rocesso de valiadacao para Fornecedores �
		Processa({|| ProcRetFor(cImptxt,"SA2")})
	EndIf
Endif	
Msginfo(STR0019)
oTmpTable:Delete()
If !lAutomato
	FERASE(cStartPath+cfinal)
Endif
Return Nil

/*/
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲uncao    � FGetFile �  Autor � Danilo Santos      � Data � 25.08.2021 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escricao � Tela de sele玢o do arquivo CSV a ser importado.            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   � cRet - Diretorio e arquivo selecionado.                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Fiscal - Formosa Argentina - MSSQL                         潮�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function FGetFile()

	Local cRet := Space(50)
	
	oDlg01 := MSDialog():New(000,000,100,500,STR0020,,,,,,,,,.T.)//"Selecionar arquivo"
	
		oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,,,,,,,.T.,,,,,,,,,,"cRet")
		oBtn01 := TBtnBmp2():New(017,458,025,028,"folder6","folder6",,,{|| FGetDir(oGet01)},oDlg01,STR0020,,.T.)//"Selecionar arquivo"
		
		oBtn02 := SButton():New(035,185,1,{|| oDlg01:End() }         ,oDlg01,.T.,,)
		oBtn03 := SButton():New(035,215,2,{|| cRet:="",oDlg01:End() },oDlg01,.T.,,)
	
	oDlg01:Activate(,,,.T.,,,)

Return cRet

/*/
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲uncao    � FGetDir  � Autor � Danilo Santos       � Data � 25.08.2021 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escricao � Tela para procurar e selecionar o arquivo nos diretorios   潮�
北�          � locais/servidor/unidades mapeadas.                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� oPar1 - Objeto TGet que ira receber o local e o arquivo    潮�
北�          �         selecionado.                                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   � Nulo                                                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Fiscal - Formosa Argentina - MSSQL                         潮�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function FGetDir(oTGet)

	Local cDir := ""
	
	cDir := cGetFile(,STR0020,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)//"Selecionar arquivo"
	If !Empty(cDir)
		oTGet:cText := cDir
		oTGet:Refresh()
	Endif
	oTGet:SetFocus()

Return Nil

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北矲un嘺o    矴eraTemp � Autor � Danilo Santos             � Data � 25.08.2021 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escri嘺o 矴era arquivo temporario a partir do XLS importado                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砈intaxe   矴eraTemp(ExpC1)                                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       矱specifico FISA145                                               潮�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/          
Static Function GeraTemp(oTmpTable,cFile,cStartPath,cfinal)
Local aInforma   := {} 									// Array auxiliar com as informacoes da linha lida no arquivo XLS
Local aCampos    := {}         							// Array auxiliar para criacao do arquivo temporario
Local aIteAge    := {}         							// Array de itens selecionaveis na tela de Wizard
Local cArqProc   := cFile									// Arquivo a ser importado selecionado na tela de Wizard
Local cTitulo    := STR0008								// "Problemas na Importa玢o de Arquivo"
Local cErro	     := ""   								// Texto de mensagem de erro ocorrido na validacao do arquivo a ser importado
Local cSolucao   := ""           						// Texto de solucao proposta em relacao a algum erro ocorrido na validacao do arquivo a ser importado
Local cLinha     := ""									// Informacao lida para cada linha do arquivo XLS
Local lArqValido := .T.                               	// Determina se o arquivo XLS esta ok para importacao
Local nInd       := 0                   				// Indexadora de laco For/Next
Local nHandle    := 0            						// Numero de referencia atribuido na abertura do arquivo XLS
Local nTam       := 0 									// Tamanho de buffer do arquivo XLS
Local cDelimit := ""  
Local cPeriod := "" 
Local lPrimi := .T.  
Local aOrdem := {"CUIT"}

Default oTmpTable  := Nil
Default cFile      := ""
Default cStartPath := ""
Default cfinal     := ""

lRet := .T. // Determina a continuidade do processamento como base nas informacoes da tela de Wizard 						

If !lAutomato
	FT_FUSE(cStartPath + cfinal)
Else		
	FT_FUSE(cFile)
Endif	
nUltArq:= FT_FLASTREC()

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//矯ria o arquivo temporario para a importacao�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

//*************Modelo do arquivo*************
//CUIT|DENOMINACI覰|CATEGOR虯|CATEGOR虯 DESCRIPCI覰|AL虲UOTA RETENCI覰|AL虲UOTA PERCEPCI覰|R蒅IMEN|FECHA EXCLUSI覰 RETENCI覰|FECHA EXCLUSI覰 PERCEPCI覰|EXENTO

AADD(aCampos,{"CUIT"	      ,"C",TamSX3("A2_CGC")[1],0}) //CUIT
AADD(aCampos,{"DENOM"         ,"C",80,0})   //DENOMINACI覰
AADD(aCampos,{"CATEG"         ,"C",20,0})   //CATEGOR虯
AADD(aCampos,{"CATEG_DESC"   ,"C",18,0})    //CATEGOR虯 DESCRIPCI覰
AADD(aCampos,{"ALIC_RET"      ,"C",03,0})    //AL虲UOTA RETENCI覰
AADD(aCampos,{"ALIC_PERC"     ,"C",03,0})    //AL虲UOTA PERCEPCI覰
AADD(aCampos,{"REGIMEN"       ,"C",80,0})    //R蒅IMEN
AADD(aCampos,{"FECEXCRET"  ,"C",10,0})    //FECHA EXCLUSI覰 RETENCI覰
AADD(aCampos,{"FECEXCPERC" ,"C",10,0})    //FECHA EXCLUSI覰 PERCEPCI覰
AADD(aCampos,{"EXENTO"        ,"C",02,0})   //EXENTO 

oTmpTable := FWTemporaryTable():New("RG7220",aCampos )
oTmpTable:AddIndex( "I1", aOrdem )
oTmpTable:Create()
cArqTmp := oTmpTable:GetAlias() 

aArqTmp := {cArqTmp,"RG7220"}
cPeriod := cMes + cAno

If !lAutomato
	cArqProc := cStartPath + cfinal
Endif	

If File(cArqProc) .And. lRet
	nHandle	:= FOpen(cArqProc) 
	If nHandle > 0 
		nTam := FSeek(nHandle,0,2)  
		FSeek(nHandle,0,0)
		FT_FUse(cArqProc)
		FT_FGotop()
	Else
		lArqValido := .F.	
		cErro	   := STR0009 + cArqProc	//"N鉶 foi poss韛el efetuar a abertura do arquivo: "
		cSolucao  := STR0010 			//"Verifique se foi informado o arquivo correto para importa玢o"
	EndIf
	If lArqValido 
		ProcRegua(nTam)
		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪��
		//矴era arquivo temporario a partir do arquivo XLS �
		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪��
		While (!FT_FEof())          
			cLinha   := FT_FREADLN()
			IncProc()
			aInforma := {} 			
   			If !("CUIT" $ cLinha) .And.  !("Cuit" $ cLinha)
   				If "," $ cLinha
					cDelimit := ","
				ElseIf ";" $ cLinha
					cDelimit := ";"
				Endif
        		RecLock("RG7220",.T.)
				For nInd := 1 to 10
					nPos := at(cDelimit,cLinha)
					If nPos > 0
						AADD (aInforma,Alltrim(SubStr(cLinha,1,(nPos-1))))
					Else
						AADD (aInforma,Alltrim(cLinha))
					Endif	
					cLinha := SubStr(cLinha,nPos+1,Len(cLinha))
				Next
				cCuit := SM0->M0_CGC
  	  			RG7220->CUIT		:= STRTRAN(aInforma[1],"", "")
  	  			If Alltrim(RG7220->CUIT) $ SM0->M0_CGC
  	  				lCuitSM0 := .T.
  	  			Endif 
				RG7220->DENOM 	   := Alltrim(aInforma[2])
				RG7220->CATEG      := Alltrim(aInforma[3])
				RG7220->CATEG_DESC := aInforma[4]
				RG7220->ALIC_RET   := aInforma[5]
				RG7220->ALIC_PERC  := aInforma[6]
				RG7220->REGIMEN    := aInforma[7]
				RG7220->FECEXCRET  := aInforma[8]
				RG7220->FECEXCPERC := aInforma[9]
				RG7220->EXENTO     := aInforma[10]

				MsUnLock()	
			Endif
			FT_FSkip()
		Enddo
	Endif	

	FT_FUse()
	FClose(nHandle)

	If Empty(cErro) .and. RG7220->(LastRec())==0     
		cErro		:= STR0011	//"A importa玢o n鉶 foi realizada por n鉶 existirem informa珲es no arquivo texto informado."
		cSolucao	:= STR0012	//"Verifique se foi informado o arquivo correto para importa玢o"
	Endif
	
Else

	cErro	 := STR0013+CHR(13)+cArqProc	//"O arquivo informado para importa玢o n鉶 foi encontrado: "
	cSolucao := STR0014 		   			//"Informe o diret髍io e o nome do arquivo corretamente e processe a rotina novamente."

EndIf
	 
If !Empty(cErro)

	xMagHelpFis(cTitulo,cErro,cSolucao)

	lRet := .F.
	
Endif

Return(lRet)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    砅ercCliFor� Autor � Danilo Santos       � Data � 25.08.2021 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao 砅rocessa os arquivos de clientes/fornecedores para          潮�
北�          砤plicacao das regras de validacao para agente retenedor     潮�
北�          砮m relacao ao arquivo enviado                               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   砅ercCliFor(ExpC1)                                           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros矱xpC1 = Tipo de imposto a ser processado Percepcao          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       矱specifico - FISA145                                        潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function PercCliFor(cImptxt,cAlias)
Local aArea     := GetArea()			// Salva area atual para posterior restauracao
Local lExistTXT := .F.					// Determina se o Clinte ou Fornecedor consta no arquivo importado
Local lCli      := (cAlias=="SA1")		// Determina se a rotina foi chamada para processar o arquivo de clientes ou fornecedores
Local cPrefTab  := Substr(cAlias,2,2)	// Prefixo para acesso dos campos

Default cImptxt := ""
Default cAlias := ""

dbSelectArea(cAlias)
(cAlias)->(dbGoTop())
    
ProcRegua(RecCount())

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//矻oop para varrer arquivo de Cliente ou Fornecedor e validar se existe no arquivo XLS�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
While !Eof() 

	IncProc(Iif(lCli,STR0015,STR0016))	//##"(15)Processando Clientes/(16)Processando Fornecedores"
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//砎erifica se o cliente/fornecedor consta no arquivo temporario - � 
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	
	If RG7220->(MsSeek((cAlias)->&(cPrefTab+"_CGC")))

		While RG7220->CUIT == (cAlias)->&(cPrefTab+"_CGC")
			If cAlias == 'SA1'		
					PesqSFH(Iif(cAlias=="SA1",3,1),(cAlias)->&(cPrefTab+"_COD")+(cAlias)->&(cPrefTab+"_LOJA")+"IBB",lCli,.T.,cImptxt)
			Else
					PesqSFH(Iif(cAlias=="SA1",3,1),(cAlias)->&(cPrefTab+"_COD")+(cAlias)->&(cPrefTab+"_LOJA")+"IBB",lCli,.T.,cImptxt)
			Endif
			RG7220->(dbSkip())
			
		EndDo
				
	Else 
		If cAlias == 'SA1'	
			PesqSFH(Iif(cAlias=="SA1",3,1),(cAlias)->&(cPrefTab+"_COD")+(cAlias)->&(cPrefTab+"_LOJA")+"IBB",lCli,.F.,cImptxt)
		Else		
			PesqSFH(Iif(cAlias=="SA1",3,1),(cAlias)->&(cPrefTab+"_COD")+(cAlias)->&(cPrefTab+"_LOJA")+"IBB",lCli,.F.,cImptxt)
		Endif
		
	EndIf
	
	If !lCli
		MsUnLock()
	EndIf

	dbSkip()
	
EndDo

RestArea(aArea)

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    砅rocRetFor�   Autor � Danilo Santos     � Data � 25.08.2021 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao 砅rocessa os arquivos de fornecedores para retenc鉶          潮�
北�          砤plicacao das regras de validacao                           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   砅rocCliFor(cImptxt,cAlias)                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cImptxt = tipo do imposto a ser processado                 潮�
               ExpC1 = Alias da tabela a ser processada(SA1/SA2)          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       矱specifico - FISA145                                        潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function ProcRetFor(cImptxt,cAlias)
Local aArea     := GetArea()			// Salva area atual para posterior restauracao
Local lExistTXT := .F.					// Determina se o Clinte ou Fornecedor consta no arquivo importado
Local lCli      := (cAlias=="SA1")		// Determina se a rotina foi chamada para processar o arquivo de clientes ou fornecedores
Local cPrefTab  := Substr(cAlias,2,2)	// Prefixo para acesso dos campos
Default cImptxt := ""
Default cAlias  := ""

dbSelectArea(cAlias)
(cAlias)->(dbGoTop())
    
ProcRegua(RecCount())

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//矻oop para varrer arquivo de Cliente ou Fornecedor e validar se existe no arquivo XLS�
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
While !Eof()  

		IncProc(Iif(lCli,STR0015,STR0016))	//##"(15)Processando Clientes/(16)Processando Fornecedores"

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//砎erifica se o cliente/fornecedor consta no arquivo temporario - � 
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	
	If RG7220->(MsSeek((cAlias)->&(cPrefTab+"_CGC")))

		While RG7220->CUIT == (cAlias)->&(cPrefTab+"_CGC")
			
			PesqSFH(Iif(cAlias=="SA1",3,1),(cAlias)->&(cPrefTab+"_COD")+(cAlias)->&(cPrefTab+"_LOJA")+"IBR",lCli,.T.,cImptxt)
			
			RG7220->(dbSkip())
			
		EndDo
				
	Else 
		
		PesqSFH(Iif(cAlias=="SA1",3,1),(cAlias)->&(cPrefTab+"_COD")+(cAlias)->&(cPrefTab+"_LOJA")+"IBR",lCli,.F.,cImptxt)	
		
	EndIf	
	
	If !lCli
		MsUnLock()
	EndIf
	dbSkip()
	
EndDo

RestArea(aArea)

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un嘺o    砅esqSFH     � Autor � Danilo Santos         � Data � 25.08.2021 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri嘺o 砅esquisa existencia de registros na tabela SFH(Ingressos Brutos)潮�
北�          硆eferente ao cliente ou forcedor passado como parametro         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   砅esqSFH(ExpN1,ExpC1,ExpL1,ExpL2)                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros矱xpN1 = Ordem do indice da tabela SFH                           潮�
北�          矱xpC1 = Chave de pesquisa para a tabela SFH                     潮�
北�          矱xpL1 = Determina se a pesquisa trata cliente ou fornecedor     潮�
北�          矱xpL2 = Determina se Cliente/Fornecedor consta no XLS/CSV       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       矱specifico - FISA145                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/          
Static Function PesqSFH(nOrd,cKeySFH,lCli,lExistTXT,cImptxt)
Local aArea    := GetArea()		// Salva area atual para posterior restauracao
Local lRet     := .T.			// Conteudo e retorno
Local lIncSFH  := lExistTXT		// Determina se deve ser incluido um novo registro na tabela SFH
Local lAtuSFH  := .F.			// Determina se deve atualizar a tabela SFH
Local nRegSFH  := 0				// Numero do registros correspondente ao ultimo periodo de vigencia na SFH
Local lFinPer  := .F.
Local cSitSFH  := ""
Local cFil     := ""
Local cTipo    := ""
Local cPerc    := ""
Local cIsent   := ""
Local cAperib  := ""
Local cImp     := ""
Local nPercent := ""
Local cAliq    := ""
Local cAgent   := ""
Local cSituac  := ""
Local cZonfis  := ""
Local dDatAux  := CTOD("  /  /  ")
Local cAuxCateg := ""
Local lPerctxt := cImptxt == "P"
Default cImptxt := ""
Private nUltimoReg := 0
dbSelectArea("SFH")
DbSetOrder(nOrd) 
SFH->(DbGoTo(1))

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//砎erifica se existe registro do Cliente ou Fornecedor na tabela SFH �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�	
cAuxCateg := IIf(RG7220->CATEG $ "A|B","2","1")
	
If SFH->(MsSeek(xFilial("SFH")+cKeySFH)) 
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//矻oop para pegar o registro referente ao periodo vigente do cliente ou fornecedor na tabela SFH �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If lExistTXT
		
		While xFilial("SFH")+cKeySFH==SFH->FH_FILIAL+Iif(lCli,SFH->FH_CLIENTE,SFH->FH_FORNECE)+SFH->FH_LOJA +SFH->FH_IMPOSTO
			If dDatIni <= FH_FIMVIGE
				lFinPer := .F.
				lAtuSFH := .F.
				lIncSFH := .F.
				cSitSFH := "0"
				nRegSFH := SFH->(Recno())
			ElseIf dDatIni == (SFH->FH_FIMVIGE + 1) .And. SFH->FH_ALIQ == IIF(lPerctxt,Val(RG7220->ALIC_PERC),Val(RG7220->ALIC_RET)) .And. SFH->FH_SITUACA == cAuxCateg .And. IIf(lPerctxt,Empty(RG7220->FECEXCPERC),Empty(RG7220->FECEXCRET))
				lFinPer := .F.
				lAtuSFH := .F.
				lIncSFH := .F.
				Reclock("SFH",.F.) 
					SFH->FH_FIMVIGE := dDatFim
					cSitSFH := "0" 
					nRegSFH := SFH->(Recno())
				MsUnLock()			
			Else
				lIncSFH := .F.
				cSitSFH := "3"
				nRegSFH := SFH->(Recno())		
			EndIf
			
			SFH->(DbSkip())
				
		EndDo
		
	Else

		While xFilial("SFH")+cKeySFH==SFH->FH_FILIAL+Iif(lCli,SFH->FH_CLIENTE,SFH->FH_FORNECE)+SFH->FH_LOJA +SFH->FH_IMPOSTO
			If dDatIni <= SFH->FH_FIMVIGE 
				lFinPer := .F.
				lAtuSFH := .F.
				lIncSFH := .F.
				cSitSFH := "0"
				nRegSFH := SFH->(Recno())		
			ElseIf lCli .And. dDatIni > SFH->FH_FIMVIGE .And. !Empty(SFH->FH_FIMVIGE)
				lFinPer := .F.
				lAtuSFH := .F.
				lIncSFH := .F.
				nRegSFH := SFH->(Recno())
				cSitSFH := "2" 
			ElseIf !lCli .And. dDatIni > SFH->FH_FIMVIGE .And. SFH->FH_INIVIGE <> dDatIni
				lFinPer := .F.
				lAtuSFH := .F.
				lIncSFH := .F.
				nRegSFH := SFH->(Recno())
				cSitSFH := "2" 
			Else
				lFinPer := .F.
				lAtuSFH := .F.
				lIncSFH := .F.
				nRegSFH := SFH->(Recno())
				cSitSFH := "0" 
			EndIf
			
			SFH->(DbSkip())
				
		EndDo
		
	Endif
	
	SFH->(dbGoto(nRegSFH))
		
	If lExistTXT
		cFil    := SFH->FH_FILIAL 
		cTipo   := "I"   
		cPerc   := SFH->FH_PERCIBI
		cIsent  := IIf(RG7220->EXENTO == "NO" ,"N","S") 
		cAperib := SFH->FH_APERIB 
		cImp    := SFH->FH_IMPOSTO			
		nPercent:= IIf(lPerctxt , IIf (!Empty(RG7220->FECEXCPERC),100,0) , IIf (!Empty(RG7220->FECEXCRET),100,0) )
		cAliq   := IIf(lPerctxt , Val(RG7220->ALIC_PERC),Val(RG7220->ALIC_RET))	 
		cAgent  := SFH->FH_AGENTE 
		cSituac := cAuxCateg
		cZonfis := SFH->FH_ZONFIS
	Else
		cFil    := SFH->FH_FILIAL 
		cTipo   := SFH->FH_TIPO   
		cPerc   := SFH->FH_PERCIBI
		cIsent  := SFH->FH_ISENTO 
		cAperib := SFH->FH_APERIB 
		cImp    := SFH->FH_IMPOSTO		
		nPercent:= SFH->FH_PERCENT
		cAliq   := SFH->FH_ALIQ	 
		cAgent  := SFH->FH_AGENTE 
		cSituac := SFH->FH_SITUACA
		cZonfis := SFH->FH_ZONFIS
	endif	
ElseIf !lCli .And. lExistTXT .And. cImptxt == "P"
 	lIncSFH := .F.
ElseIf !lCli .And. lExistTXT .And. cImptxt == "R"
	lIncSFH := .T.
EndIf

If lExistTXT	

	If lIncSFH
		Reclock("SFH",.T.)
		SFH->FH_FILIAL  := xFilial("SFH")
		SFH->FH_TIPO    := "I"
		SFH->FH_PERCIBI := IIf(lPerctxt ,"S","N")
		SFH->FH_ISENTO  := IIf(RG7220->EXENTO == "NO" ,"N","S")
		SFH->FH_APERIB  := IIf(lPerctxt,"S","N")
		SFH->FH_IMPOSTO := IIf(lPerctxt,"IBB","IBR")
		SFH->FH_PERCENT := IIf(lPerctxt,IIf (!Empty(RG7220->FECEXCPERC),100,0),IIf(!Empty(RG7220->FECEXCRET),100,0))
		SFH->FH_ALIQ	:= IIf(lPerctxt,Val(RG7220->ALIC_PERC),Val(RG7220->ALIC_RET))
		SFH->FH_INIVIGE := dDatIni
		SFH->FH_FIMVIGE := dDatFim
		SFH->FH_AGENTE  := "N"
		SFH->FH_SITUACA := IIf (RG7220->CATEG $ "A|B","2","1")
		SFH->FH_ZONFIS := "FO"	
		If lCli
			SFH->FH_CLIENTE := SA1->A1_COD
			SFH->FH_NOME    := SA1->A1_NOME
			SFH->FH_FORNECE := ""
			SFH->FH_LOJA    := SA1->A1_LOJA
		Else	
			SFH->FH_FORNECE := SA2->A2_COD
			SFH->FH_NOME    := SA2->A2_NOME
			SFH->FH_CLIENTE := ""
			SFH->FH_LOJA    := SA2->A2_LOJA
		EndIf
		MsUnLock()
		
	EndIf
	
	GrvSFH145(lCli,lExistTXT,cSitSFH,cFil,cTipo,cPerc,cIsent,cAperib,cImp,nPercent,cAliq,dDatIni,dDatFim,cAgent,cSituac,cZonfis,dDatAux)
Else

	GrvSFH145(lCli,lExistTXT,cSitSFH,cFil,cTipo,cPerc,cIsent,cAperib,cImp,nPercent,cAliq,dDatIni,dDatFim,cAgent,cSituac,cZonfis,dDatAux)	

Endif

RestArea(aArea)

Return(lRet)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un嘺o    矴rvSFH145     � Autor � Danilo Santos       � Data � 25.08.2021 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri嘺o 矲un玢o utilizada para gravar os dados da tabela SFH conforme    潮�
北�          硆egra informada na especifica玢o                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砈intaxe   矴rvSFH145(lCli,lExistTXT,cSitSFH,cFil,cTipo,cPerc,cIsent,       潮�
北砪Aperib,cImp,cPercent,cAliq,dDatIni,dDatFim,cAgent,cSituac,cZonfis)        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砽Cli = Indica se � cliente ou fornecedor                        潮�
北�          砽ExistTXT = Indica se o cliente ou fornecedor existe no arquivo 潮�
北�          砪SitSFH = Indicia a situa玢o do registro na tabela SFH          潮�
北�          砪Fil,cTipo,cPerc,cIsent,cAperib,cImp,cPercent,cAliq,dDatIni,    潮�    
北�          砫DatFim,cAgent,cSituac,cZonfis = informa珲es gravadas na tabela 潮�
北�          砈FH para criar um novo registro similar atualizado              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       矱specifico - FISA145                                           潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/ 

Static Function GrvSFH145(lCli,lExistTXT,cSitSFH,cFil,cTipo,cPerc,cIsent,cAperib,cImp,nPercent,cAliq,dDatIni,dDatFim,cAgent,cSituac,cZonfis,dDatAux)

Default lCli := .T.
Default lExistTXT := .T.
Default cSitSFH := .T.
Default cFil := ""
Default cTipo := ""
Default cPerc := ""
Default cIsent := ""
Default cAperib := "" 
Default cImp := ""
Default nPercent := 0
Default cAliq := ""
Default dDatIni := CTOD("  /  /  ")
Default dDatFim := CTOD("  /  /  ")
Default dDatAux := CTOD("  /  /  ")
Default cAgent:= ""
Default cSituac := ""
Default cZonfis := ""

If lExistTXT
	If cSitSFH $ "1|2|3" 
		Reclock("SFH",.T.)
		SFH->FH_FILIAL  := cFil
		SFH->FH_TIPO    := cTipo
		SFH->FH_PERCIBI := cPerc
		SFH->FH_ISENTO  := cIsent
		SFH->FH_APERIB  := cAperib
		SFH->FH_IMPOSTO := cImp
		SFH->FH_PERCENT := nPercent
		SFH->FH_ALIQ	  := cAliq
		SFH->FH_INIVIGE := dDatIni
		SFH->FH_FIMVIGE := dDatFim
		SFH->FH_AGENTE  := cAgent
		SFH->FH_SITUACA := cSituac
		SFH->FH_ZONFIS := cZonfis	
		If lCli
			SFH->FH_CLIENTE := SA1->A1_COD
			SFH->FH_LOJA    := SA1->A1_LOJA
			SFH->FH_NOME    := SA1->A1_NOME
		Else	
			SFH->FH_LOJA    := SA2->A2_LOJA
			SFH->FH_FORNECE := SA2->A2_COD
			SFH->FH_NOME    := SA2->A2_NOME
		EndIf
		MsUnLock()
	Endif
Else
	If cSitSFH $ "2" 
		Reclock("SFH",.T.)
		SFH->FH_FILIAL  := cFil
		SFH->FH_TIPO    := cTipo
		SFH->FH_PERCIBI := cPerc
		SFH->FH_ISENTO  := "N"
		SFH->FH_APERIB  := cAperib
		SFH->FH_IMPOSTO := cImp
		SFH->FH_PERCENT := 100
		SFH->FH_ALIQ	:= 0
		SFH->FH_INIVIGE := dDatIni
		SFH->FH_FIMVIGE := CTOD("  /  /  ")
		SFH->FH_AGENTE  := cAgent
		SFH->FH_SITUACA := "1"
		SFH->FH_ZONFIS := cZonfis	
		If lCli
			SFH->FH_CLIENTE := SA1->A1_COD
			SFH->FH_LOJA    := SA1->A1_LOJA
			SFH->FH_NOME    := SA1->A1_NOME
		Else	
			SFH->FH_LOJA    := SA2->A2_LOJA
			SFH->FH_FORNECE := SA2->A2_COD
			SFH->FH_NOME    := SA2->A2_NOME
		EndIf
		MsUnLock()
	Endif
Endif
			
Return

/*/{Protheus.doc} FIS145AUT
	funcion utilizada en la automatizacion de la FISA145
	@type  void
	@author Danilo Santos
	@since 30/08/2021
	@version version 1
	@param cArchivo,caracter,ruta del padron a cargar.
	@param cCombo,caracter,indica si es cliente proveedor o ambos("1- Proveedor","2- Cliente","3- Ambos" )
	@return nil, nil, no retorna nada
/*/
	
Function FIS145AUT(cArchivo,cCombo)
	Private cFileAut:=cArchivo
	Private aQry := {}
	Private aCombo:={}

	aAdd( aCombo, "1- Proveedor" ) //"1- Fornecedor"
	aAdd( aCombo, "2- Cliente" ) //"2- Cliente"
	aAdd( aCombo, "3- Ambos" ) //"3- Ambos"

	IF FILE(cArchivo)
		ImpArq(aCombo,cCombo)
	EndIf
Return nil