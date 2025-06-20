#INCLUDE "PROTHEUS.CH"
#INCLUDE "RSPR002.CH"

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � RSPR002  � Autor � Cristina Ogura        � Data � 03.02.98 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Executa a pesquisa selecionada                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � RSPR002                                                    潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Alteracao                     潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北矯ecilia Car.�06/08/14砊QENRX矷ncluido o fonte da 11 para a 12 e efetua-潮�
北�            �        �      砫a a limpeza.                             潮�
北砄swaldo L.  �31/08/17矰HRPON� Ajuste p/ gerar csv nas novas pesquisas  潮�
北�            �        砊P1485� Mas abrir antigos PES tamb閙. SOYUZ      潮�
北�            �        �      � Ajuste nomes das extens鮡s de arquivos   潮�
北砄swaldo L.  �31/08/17矰HRPAG� Ajuste para ler informa珲es das novas    潮�
北�            �        �-7555 � tabelas RT0\RT1                          潮�
北�            �        �      � Manter ainda tratativas ctree no fonte   潮�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�/*/
Function RSPR002()
Local cFile			:= ""
Local cFileFPT		:= ""
Local cArquivo		:= ""
Local nPos			:= 0
Local aOK			:= {}
Local lArqLocal		:= .F.
Local cPathSrv		:= ""
Local cArqFPT		:= ""
Local cArqSrv		:= ""
Local cRDD			:= __LocalDriver
Private cExt		:= ""
Private cCsvFile	:= ""
Private oArqTRBTmp	:= Nil
Private cNomeTab	:= ""
Private lNvTab		:= TabNovaDic()

While .T.

	If lNvTab
		cNomeTab := TelaSelecao()
			
		If Empty(cNomeTab)
			MsgInfo(OemToAnsi(STR0009))	//"N鉶 existem pesquisas efetuadas em sua Base de dados. Caso existam arquivos de pesquisa (.PES ou .CSV) a serem consultados, utilize a rotina RSPM003 para importa玢o dos dados."
			Return .T.
		EndIf
		
		CriaTemp()
		Exit

	Else
	
		cFile:=cGetFile(STR0005,OemToAnsi(STR0001),0,,.T.,GETF_ONLYSERVER+GETF_LOCALFLOPPY) //"Selecione o Arquivo"
		If Empty(cFile)
			Return .T.
		EndIf
		If !File(cFile)
			Aviso("",OemtoAnsi(STR0002),{"OK"})    //"Nao existe arquivo selecionado"
			cFile:=""
			Loop
	    EndIf
	    
	   	If  AT(".",cFile) # 0
			nPos := AT(".",cFile)-1
		Else
			nPos := Len(cFile)
			cFile := cFile+".PES" //o programa original sempre tenta abrir um PES qdo n鉶 acha o caracter ".". Mantivemos desta forma
		EndIf
	
		If Len(cFile) > 2
			cExt := substr( cFile, Len(cFile)-2,  Len(cFile))
		EndIf
			
		cFileFPT 	:= Substr(cFile,1,nPos)+".FPT"
		If ( nPos := At(':', cFile) ) > 0	// Drive Local
			lArqLocal 	:= .T.
			
			IF !Empty ( AllTrim( cPathSrv := GetPvProfString( GetEnvServer(), "StartPath", "", GetADV97() ) ) )
				IF !( Subst( cPathSrv , 1 , 1 ) $ "\/" )
					cPathSrv := "\"+cPathSrv
				EndIF
				IF !( Subst( cPathSrv , -1	) $ "\/" )
					cPathSrv+= "\"
				EndIF  
				
				cArquivo 	:= cFile    
				cArqFPT		:= cFileFPT
				If ( nPos := At(':', cArquivo) ) > 0
					cArquivo := SubS(cArquivo, nPos+1) 
					cArqFPT	:= Subs(cArqFPT, nPos+1)
				EndIf
				Do While At('\', cArquivo) > 0 .Or. At('/', cArquivo)> 0
					If (nPos := At('\', cArquivo)) > 0 .Or. (nPos := At('/', cArquivo)) > 0
						cArquivo := SubS(cArquivo, nPos+1) 
						cArqFPT	:= Subs(cArqFPT, nPos+1)
					EndIf
				EndDo
		
				cArqSrv := RetArq( cRDD , cPathSrv + cArquivo , .T. )
				CpyT2S( cFile , cPathSrv  , .F. )
	
	       		If File(cFileFPT)
					cArqSrvFPT 	:= RetArq( cRDD , cPathSrv + cArqFPT , .T. )
					CpyT2S( cFileFPT, cPathSrv, .F. )
				EndIf
				
				IF File(cArqSrv)
					If Upper(cExt) == "CSV"
						cCsvFile := cArqSrv
					Else
						MsOpenDbf( .T. , cRDD , cArqSrv , "TRB" , .F. , .F. ) 
					EndIf
				Else
					Aviso("",OemtoAnsi(STR0002),{"OK"})    //"Nao existe arquivo selecionado"   
					Loop
				EndIF
			EndIf
		Else	// Servidor
			
			If Upper(cExt) == "CSV"
				cCsvFile := cFile
			Else	
				dbUseArea(.T.,cRDD, cFile,"TRB", .F., .F.)		//.PES
			EndIf
		EndIf	
		
		If NETERR()
			Aviso("",OemtoAnsi(STR0003),{"OK"}) //"Arquivo esta sendo usado"
			cFile:=""
			Loop
		EndIf
		
		
		If Upper(cExt) != "CSV"
			aOk:=DBSTRUCT()		
			If aOk[2][1] # "CURRIC" .And. aOK[3][1] # "NOME"
				Aviso("",OemtoAnsi(STR0004),{"OK"}) //"Este arquivo nao pertence a pesquisa"
				If Select("TRB") != 0
					dbSelectArea("TRB")
					dbCloseArea()
				EndIf
				cFile:=""
				Loop
			EndIf
		Else
			LerCSV()
		EndIf
		
		Exit
	
	EndIf
	
EndDo

// Chamada a funcao no programa RSPA090
If Select("TRB") != 0
	A090IMPRI("RSPR002")//esta funcao necessita de TRB sempre posicionado

	dbSelectArea("TRB")
	dbCloseArea()
EndIf

If oArqTRBTmp <> Nil
	oArqTRBTmp:Delete()
	Freeobj(oArqTRBTmp)
EndIf
		
If lArqLocal
	Ferase(cArquivo)
	Ferase(cArqFPT)
EndIf

dbSelectArea("SQG")

Return .T.


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矻erCSV        篈utor  砄swaldo L.   � Data � 30/08/2017     罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矻er CSV escolhido. A gera玢o de CSV passou a ser feita apos 罕�
北�          砅roj.Soyuz com autoriza玢o do frame                         罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       �                                                            罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
static function LerCSV ()
Local aLstRegs    := {} 
Local cSeparador  := ";"
Local nLinha      := 0
Local nCont       := 1
Local aLstIndices := {}
Local aCampos     := {}
Local cGrvCampo   := ''
Private aEstru    := {}
Private aCSVCabec := {}
    
FT_FUse( cCsvFile )//Abre o Arquivo
FT_FGoTop()

while !FT_FEof()
	nLinha += 1
	
    If nLinha == 1//cabe鏰lho
    	aCSVCabec :=  Separa( Substr(FT_FReadLn(),1,Len(FT_FReadLn())) ,cSeparador )
    	CriaTempDoCSV()//cria temporario
    Else
    	If oArqTRBTmp <> Nil //insere dados do CSV no tempor醨io
    		aLstRegs :=  Separa( Substr(FT_FReadLn(),1,Len(FT_FReadLn())) ,cSeparador )
    		
    		If Len(aLstRegs) > 0 
    		
    			dbselectarea('TRB')
	    	
	    		Reclock('TRB',.T.)
		    	For nCont := 1 to Len(aEstru)
					cGrvCampo     := "TRB->("  + AllTrim(aEstru[nCont][1]) + ")"
					
					If aEstru[nCont][2] $ "L"
						If aLstRegs[nCont] == "0"
							&cGrvCampo    := .F.
						Else
							&cGrvCampo    := .T.
						EndIf
					End
					
					If aEstru[nCont][2] $ "D"
						&cGrvCampo    := ctod(aLstRegs[nCont])
					EndIf
					
					If !(aEstru[nCont][2] $ "L|D")
					
						If (aEstru[nCont][2]) == "N"
							nCont := nCont
							&cGrvCampo    := Val(aLstRegs[nCont])
						Else
							&cGrvCampo    := aLstRegs[nCont]
						EndIf
						
					EndIf
				Next
		    	MsUnLock()
	    	EndIf
    	EndIf
    EndIf
    
    FT_FSkip()
End

FT_FUse()

return


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矯riaTempDoCSV 篈utor  砄swaldo L.   � Data � 30/08/2017     罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矯ria temporaria com base no CSV lido                        罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       �                                                            罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static function CriaTempDoCSV()
Local nCOnt   := 1
Local i  
Local aCampos := {}

For nCont := 1 to Len(aCSVCabec)

	dbSelectArea("SX3")
	dbSetOrder(2)
	If !(aCSVCabec[nCont] $ "SEL|CURRIC|NOME|FONE|VAGA") ; //arquivos da rspa090 tem estes campos sempre fixos no inicio  
		.And. dbSeek(aCSVCabec[nCont]) 
		Aadd(aCampos,{	aCSVCabec[nCont],;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_TIPO})
	EndIf
Next

If Len(aCSVCabec) > 0
	// Campos fixos do Arquivo
	aEstru:={}    
	Aadd(aEstru, { "SEL"	,"L",01, 0 } )
	Aadd(aEstru, { "CURRIC" ,"C",06, 0 } )
	Aadd(aEstru, { "NOME" 	,"C",40, 0 } )
	Aadd(aEstru, { "FONE"	,"C",40, 0 } )
	Aadd(aEstru, { "VAGA"	,"C",06, 0 } )

	
	// Campos diferentes de Memo
	For i:=1 To Len(aCampos) 
		If aCampos[i][4] != "M"	.and. !("RS6_" $ aCampos[i][1])	//Separar memos para adicionar no final, devido Linux colocar memos por ultimo no arquivo Temporario TRB 	 	
			cCampo := AllTrim(aCampos[i][1])
			If Ascan(aEstru,{|x| AllTrim(x[1]) == cCampo}) == 0
				Aadd(aEstru,{cCampo ,aCampos[i][4],aCampos[i][2],aCampos[i][3]})
				
			EndIf
		EndIf	
	Next i	
    
	// Campos Memos
	For i:=1 To Len(aCampos)
		If aCampos[i][4] == "M" .and. !("RS6_" $ aCampos[i][1])	//Separar memos para adicionar no final, devido Linux colocar memos por ultimo no arquivo Temporario TRB 	 	
			cCampo := AllTrim(aCampos[i][1])
			If Ascan(aEstru,{|x| AllTrim(x[1]) == cCampo}) == 0
				Aadd(aEstru,{cCampo ,aCampos[i][4],aCampos[i][2],aCampos[i][3]})
				
			EndIf
		EndIf	
	Next i	
	
    aLstIndices := {}

    AAdd( aLstIndices, {"CURRIC"})
    AAdd( aLstIndices, {"NOME"})
    oArqTRBTmp := RhCriaTrab('TRB', aEstru, aLstIndices)
    TRB->(DbSetOrder(1))
EndIf

return



/*                                                                           
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯脱屯屯屯屯屯屯突北
北篜rograma  � TelaSelecao 篈utor  砄swaldo L                   �  19/10/17    罕�
北掏屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯凸北
北矰escri噮o � Selecao da tabela existente                                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametro �                                                                 潮�
北�          �                                                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       � RSPR002                                                         潮�
北棠哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/

static function TelaSelecao ()
Local oDlgSel
Local oDlg 
Local oGet1
Local cGet1    := space(TamSx3("RT1_PERG")[1])
Local oButMarc1
Local oButMarc2 
Local lMantem  := .T.
Local lRet     := .F.
Local lIniciar := .T.
Local oGet, oPesquisa
Local aPesquisa	:= {}
Local cPesquisa	:= ""
Local nPesq		:= 0
Local lRet		:= .F.
Local cvar		:= ""
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Declara玢o de arrays para dimensionar tela		             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local cRT1Alias     := GetNextAlias()

While lMantem

	If lIniciar
		lIniciar := .F.
		
		BeginSql Alias cRT1Alias
			  SELECT DISTINCT(RT1.RT1_PERG)  FROM 	%table:RT1% RT1 
		       WHERE RT1.RT1_FILIAL  = %Exp:(Fwxfilial('RT1'))%
				 AND RT1.RT1_TELA    = 'RSPA090   '
				 AND RT1.%NotDel%
				 ORDER BY RT1.RT1_PERG   
		EndSql
			
		While (cRT1Alias)->(!Eof())
			Aadd(aPesquisa, (cRT1Alias)->(RT1_PERG)  )//SQU->QU_CODIGO+" - "+SQU->QU_DESCRIC)
				
			(cRT1Alias)->(dbSkip())
		EndDo
			
		(cRT1Alias)->(dbCloseArea())
			
		If Len(aPesquisa) == 0
			Return .F.
		EndIf	
	EndIf
		
	aAdvSize		:= MsAdvSize( , .T., 390)
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T., .T. } )
	aObjSize	    := MsObjSize( aInfoAdvSize , aObjCoords )
		
	SETAPILHA()
	DEFINE MSDIALOG oDlgSel TITLE OemToAnsi(STR0006) FROM aAdvSize[7],0 To aAdvSize[6],aAdvSize[5]  PIXEL//"Selecione uma pesquisa"
		
			@ aObjSize[1,1],aObjSize[1,2] LISTBOX oPesquisa VAR cVar FIELDS HEADER OemtoAnsi(STR0007) OF oDlgSel PIXEL SIZE aObjSize[1,3],aObjSize[1,4]-15; //"Pesquisas:"
			ON CHANGE (nPesq:=oPesquisa:nAt) ON DBLCLICK (lRet := .T.,oDlgSel:End())
			oPesquisa:SetArray(aPesquisa)
		  	oPesquisa:bLine := { || {aPesquisa[oPesquisa:nAt]}}
			
	ACTIVATE MSDIALOG oDlgSel ON INIT EnchoiceBar(oDlgSel, {|| lRet:= .T., oDlgSel:End()  },{|| lRet:=.F. ,oDlgSel:End()} ) CENTERED
	SETAPILHA()
		
	If nPesq > 0
		cGet1 := aPesquisa[nPesq]
	Else
		cGet1 := '' 
	EndIf
		
	If lRet 
		If Empty(cGet1)
			MsgInfo(OemtoAnsi(STR0008))
			lRet := .F.
		Else
			lMantem := .F.
		EndIf
	Else
		lMantem := .F.
	EndIf
End

return cGet1




/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矯riaTemp 篈utor  砄swaldo L.   � Data � 30/08/2017          罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     矯ria temporaria com base no arq lido                        罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       �                                                            罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static function CriaTemp()
	Local nCont      := 1
	Local i          := 0
	Local cCampo     := ""
	Local cCabecalho := ""
	Local cItemReg   := ""
	Local aCampos    := {}
	Local aCabec     := {}
	Local aItem      := {}
	Local cGrvCampo  := ""
	Local aEstru     := {}
	Local aLstIndices:= {}
	
	aEstru:={}    
	
	dbSelectArea('RT1')
	RT1->(DbSetOrder(1))
	RT1->(DbSeek( Fwxfilial('RT1') + "RSPA090   " + cNomeTab  + "S"  ))

	If RT1->(!Eof()) .And. AllTrim(RT1->(RT1_FILIAL+RT1_TELA+RT1_PERG + "S")) == AllTrim(Fwxfilial('RT1') + "RSPA090   " + cNomeTab + "S")

		cCabecalho := RHMSMM(RT1->RT1_CODM,,,,  ,,,,,,, 'RT1')	
		aCabec     := StrTokArr(cCabecalho,";")

		If Len(aCabec) > 0

			// Campos fixos do Arquivo
			Aadd(aEstru, { "SEL"	,"L",01, 0 } )
			Aadd(aEstru, { "CURRIC" ,"C",06, 0 } )
			Aadd(aEstru, { "NOME" 	,"C",40, 0 } )
			Aadd(aEstru, { "FONE"	,"C",40, 0 } )
			Aadd(aEstru, { "VAGA"	,"C",06, 0 } )

			For nCont := 1 to Len(aCabec)
			
				dbSelectArea("SX3")
				dbSetOrder(2)
				If !(aCabec[nCont] $ "SEL|CURRIC|NOME|FONE|VAGA") ; //arquivos da rspa090 tem estes campos sempre fixos no inicio  
					.And. dbSeek(aCabec[nCont]) 
					Aadd(aCampos,{	aCabec[nCont],;
									SX3->X3_TAMANHO,;
									SX3->X3_DECIMAL,;
									SX3->X3_TIPO})
				EndIf
			Next

			// Campos diferentes de Memo
			For i := 1 To Len(aCampos) 
				If aCampos[i][4] != "M"	.and. !("RS6_" $ aCampos[i][1])	//Separar memos para adicionar no final, devido Linux colocar memos por ultimo no arquivo Temporario TRB 	 	
					cCampo := AllTrim(aCampos[i][1])
					If Ascan(aEstru,{|x| AllTrim(x[1]) == cCampo}) == 0
						Aadd(aEstru,{cCampo ,aCampos[i][4],aCampos[i][2],aCampos[i][3]})
					EndIf
				EndIf	
			Next i	
			
			// Campos Memos
			For i := 1 To Len(aCampos)
				If aCampos[i][4] == "M" .and. !("RS6_" $ aCampos[i][1])	//Separar memos para adicionar no final, devido Linux colocar memos por ultimo no arquivo Temporario TRB 	 	
					cCampo := AllTrim(aCampos[i][1])
					If Ascan(aEstru,{|x| AllTrim(x[1]) == cCampo}) == 0
						Aadd(aEstru,{cCampo ,aCampos[i][4],aCampos[i][2],aCampos[i][3]})
					EndIf
				EndIf	
			Next i	

			aLstIndices := {}
		
			AAdd( aLstIndices, {"CURRIC"})
			AAdd( aLstIndices, {"NOME"})
			
			oArqTRBTmp := RhCriaTrab('TRB', aEstru, aLstIndices)
			TRB->(DbSetOrder(1))
			
			If oArqTRBTmp != Nil
				dbSelectArea('RT1')
				RT1->(DbSetOrder(1))
				RT1->(DbSeek( Fwxfilial('RT1') + "RSPA090   " + cNomeTab  + "N"  ))
			
				While RT1->(!Eof()) .And. AllTrim(RT1->(RT1_FILIAL+RT1_TELA+RT1_PERG+RT1_HEAD) ) == AllTrim(Fwxfilial('RT1') + "RSPA090   " + cNomeTab + "N") 
					
					cItemReg := RHMSMM(RT1->RT1_CODM,,,,  ,,,,,,, 'RT1')
					
					aItem    := StrTokArr2(cItemReg,";",.T.)
					
					dbselectarea('TRB')
				
					Reclock('TRB',.T.)
					
					For nCont := 1 to Len(aEstru)
						cGrvCampo     := "TRB->("  + AllTrim(aEstru[nCont][1]) + ")"
						
						If aEstru[nCont][2] $ "L"
							If aItem[nCont] == "0"
								&cGrvCampo    := .F.
							Else
								&cGrvCampo    := .T.
							EndIf
						End
						
						If aEstru[nCont][2] $ "D"
							&cGrvCampo    := ctod(aItem[nCont])
						EndIf
						
						If !(aEstru[nCont][2] $ "L|D")
						
							If (aEstru[nCont][2]) == "N"
								&cGrvCampo    := Val(aItem[nCont])
							Else
								&cGrvCampo    := aItem[nCont]
							EndIf
							
						EndIf
					Next
					
					MsUnLock()
					
					//===========================	
					RT1->(DbSkip())
				End
			EndIf
		EndIf
	EndIf

return

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � TabNovaDic � Autor � Oswaldo L      � Data � 03.10.17 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Testa exist阯cia da tabela no dicionario                   潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�           Esta rotina cria a tabela, por isto ela nao existe no banco 潮�
北�           neste ponto ainda. Entao, verificamos pelo dicionario.      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       �                                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�*/

Static function TabNovaDic ()
Local lRet := .F.

If TCCanOpen(  RETSQLNAME("RT1")   ) 
	lRet := .T.
EndIf

return lRet














