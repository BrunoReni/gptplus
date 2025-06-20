#INCLUDE "GFEA062.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*-------------------------------------------------------------------                                                                           
{Protheus.doc} GFEXVIEWLG
Visualiza��o de Logs

@author Israel A. Possoli
@since 18/07/12
@version 1.0
-------------------------------------------------------------------*/
Function GFEX002()
	Local nI
	
	Local oDlg
	Local aSize := MsAdvSize()
	Local windowHeight := (aSize[6] - aSize[7]) / 2
	
	Local cTipoLog						// Combo-box 'Tipo de Log'
	Local aItensCombo := {}				// Itens do Combo-box
	Local oDataIni, oDataFim			// Campos Data Inicial e Final
	
	Local nListDatas := 1
	Local aNewButton := {}
	
	Local oSize
	Local aPosEnch
	
	Private cDataIni := STOD("20000101")  // Valores dos campos Data Inicial
	Private cDataFim := STOD("20991231")	// Valores dos campos Data Final
	Private cDirLog := "\"
	Private cLogBody
	Private oLogBody
	Private oLayerLog
	Private aLogPattern := {} 			// Array com os tipos de log e seu pattern. [n,1] Descri��o, [n, 2] Pattern	
	Private oTipoLog
	Private oListDatas					// Lista dos logs mostrando as datas
	Private aListaArquivos := {}
	
	
	If !Empty(SuperGetMv("MV_DRTLOG",,""))
		cDirLog := SuperGetMv("MV_DRTLOG",,"")
	EndIf
	
	If Substr(cDirLog, Len(cDirLog), 1) != "\" .AND. Substr(cDirLog, Len(cDirLog), 1) != "/"
		cDirLog += "\"
	EndIf	
	
	/* ----------------------------------------------------------------------
		Cria��o dos tipos de logs que s�o visualizados pelo programa
		- Os logs devem seguir o padr�o "Titulo_data_hora". Ex: edi_doccob_importacao_20120717_143823.log
		- O padr�o (pattern) deve ser o t�tulo do log sem a hora e data e n�o necessita do �ltimo underline. Ex: edi_doccob_importacao
       ---------------------------------------------------------------------- */
	aADD(aLogPattern, {"EDI - Doccob (Importa��o)"		  , "edi_doccob_importacao"   })
	aADD(aLogPattern, {"EDI - Doccob (Processamento)"	  , "edi_doccob_processamento" })
	aADD(aLogPattern, {"EDI - Conemb (Importa��o)"		  , "edi_conemb_importacao"	})
	aADD(aLogPattern, {"EDI - Conemb (Processamento)"	  , "edi_conemb_processamento" })
	aADD(aLogPattern, {"EDI - Ocorr�ncia (Importa��o)"	  , "edi_ocorrencias_importacao" })
	aADD(aLogPattern, {"EDI - Ocorr�ncia (Processamento)" , "edi_ocorrencias_processamento"	})
	aADD(aLogPattern, {"Gera��o de Pr�-Fatura" 			  , "prefat_geracao"})
	
	/* Copia os itens para o combo-box */
	For nI := 1 To Len(aLogPattern) 
	   aADD(aItensCombo, aLogPattern[nI, 1])
	Next
	
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({aSize[7], 000,aSize[6],aSize[5]})
	oSize:lLateral     := .F.  // Calculo vertical	
	oSize:Process() //executa os calculos
	
	
	aPosEnch := {oSize:GetDimension("ENCHOICE","LININI"),;
                 oSize:GetDimension("ENCHOICE","COLINI"),;
                 oSize:GetDimension("ENCHOICE","LINEND"),;
                 oSize:GetDimension("ENCHOICE","COLEND")}
                 
	DEFINE MSDIALOG oDlg TITLE "Visualiza��o de Log" ;
							FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
							TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
							COLORS 0, 16777215 PIXEL							
		
		oLayerLog := FWLayer():new()
		oLayerLog:Init(oDlg, .F.)
		
		oLayerLog:AddLine('TOP', 12, .F.)
		oLayerLog:AddLine('BOTTOM', 84, .T.)
		
		oLayerLog:AddCollumn('COL_TOP',    100, .T., "TOP")
		
		oLayerLog:AddCollumn('COL_LEFT', 15, .T., "BOTTOM")
		oLayerLog:AddCollumn('COL_RIGHT', 85, .T., "BOTTOM")
		
		oLayerLog:AddWindow('COL_TOP'  , 'WIN_TOP',    "",  100, .T., .T.,,'TOP',)
		
		oLayerLog:AddWindow('COL_LEFT' , 'WIN_LEFT', "", 95, .T., .T.,,'BOTTOM',)
		oLayerLog:AddWindow('COL_RIGHT', 'WIN_RIGHT', "", 95, .T., .T.,,'BOTTOM',)
		
		/* Barra de op��es */
   		@ 8,8  Say "Tipo de Log:" Of oLayerLog:getWinPanel('COL_TOP', 'WIN_TOP','TOP') COLOR CLR_BLACK Pixel
   		oTipoLog := tComboBox():New(5,40, {|u| if(PCount()>0, cTipoLog:=u, cTipoLog)}, aItensCombo , 110, 20, oLayerLog:getWinPanel('COL_TOP', 'WIN_TOP','TOP'),,{||},,,,.T.,,,,{||},,,,,'oTipoLog')

   		@ 8, 160 Say 	 "Data:" Of oLayerLog:getWinPanel('COL_TOP', 'WIN_TOP','TOP') COLOR CLR_BLACK Pixel
   		@ 8, 175 MsGet oDataIni Var cDataIni When {|| } SIZE 45,7 PIXEL OF oLayerLog:getWinPanel('COL_TOP', 'WIN_TOP','TOP') PICTURE "9.99" hasbutton
   		@ 8, 225 Say 	 "At�:" Of oLayerLog:getWinPanel('COL_TOP', 'WIN_TOP','TOP') COLOR CLR_BLACK Pixel
   		@ 8, 240 MsGet oDataFIm Var cDataFim When {|| } SIZE 45,7 PIXEL OF oLayerLog:getWinPanel('COL_TOP', 'WIN_TOP','TOP') PICTURE "9.99" hasbutton
   		
   		TBtnBmp2():New(8, 588, 26, 26,'TK_REFRESH',,,,{|| Atualizar()}, oLayerLog:getWinPanel('COL_TOP', 'WIN_TOP','TOP'),"Atualizar",,.T. )
   		
   		/* Barra lateral com os logs e suas datas */
   		oListDatas := TListBox():New(0, 0, {|u|if(Pcount()>0,nListDatas:=u,nListDatas)}, {}, 0, 0, {|| SelectLog() } ,oLayerLog:getWinPanel('COL_LEFT', 'WIN_LEFT','BOTTOM'),,,,.T. )
   		oListDatas:Align := CONTROL_ALIGN_ALLCLIENT
   		
   		/* Memo */
   		oLogBody := TMultiget():New(0, 0, {|u|If(Pcount()>0,cLogBody:=u,cLogBody)}, oLayerLog:getWinPanel('COL_RIGHT', 'WIN_RIGHT','BOTTOM'), 0, 0,,,,,,.T.)
		oLogBody:EnableVScroll(.T.)
		oLogBody:EnableHScroll(.T.)
		oLogBody:oFont := TFont():New( 'Courier New', 8, 16 )
		oLogBody:Align := CONTROL_ALIGN_ALLCLIENT
		
	Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{|| ODlg:End() },{||ODlg:End()},,/* aNewButton */) Centered
Return

/*-------------------------------------------------------------------
{Protheus.doc} Atualizar
Atualiza��o da lista de logs

@author Israel A. Possoli
@since 19/07/12
@version 1.0
-------------------------------------------------------------------*/
Static Function Atualizar()
	Local nCountFiles 
	Local aDirImpor  := {}
	Local aArquivos  := {}
	Local cPattern
	Local cData
	Local cHora
	
	cPattern := aLogPattern[oTipoLog:nAt, 2]
	If Substr(cPattern, Len(cPattern), 1) == "_"
		cPattern := Substr(cPattern, 1, Len(cPattern))
	EndIf
	aDirImpor := DIRECTORY(cDirLog + "\" + cPattern + "*.LOG" )
	
	//Se n�o encontrar nenhum arquivo
	If len(aDirImpor) == 0
		MsgAlert("Nenhum arquivo encontrado em " + cDirLog, "Aviso")
		Return
	Endif
	
	/* Leitura dos arquivos */
	aListaArquivos := {}
	For nCountFiles := 1 To Len(aDirImpor)
		cData := Substr(aDirImpor[nCountFiles][1], Len(cPattern) + 2, 8)
		cHora := Substr(aDirImpor[nCountFiles][1], Len(cPattern) + 11, 6)
		cHora := Substr(cHora, 1, 2) + ":" + Substr(cHora, 3, 2) + ":" + Substr(cHora, 5, 2)
		If cData >= DTOS(cDataIni) .AND. cData <= DTOS(cDataFim)
			aADD(aArquivos, cValToChar(STOD(cData)) + " - " + cHora) 
			aADD(aListaArquivos, aDirImpor[nCountFiles][1])
		EndIf
	Next
	
	oListDatas:SetArray(aArquivos)
	oLayerLog:setWinTitle('COL_RIGHT', 'WIN_RIGHT', aLogPattern[oTipoLog:nAt, 1], 'BOTTOM' )
Return .T.

/*-------------------------------------------------------------------                                                                           
{Protheus.doc} SelectLog
Sele��o do log

@author Israel A. Possoli
@since 19/07/12
@version 1.0
-------------------------------------------------------------------*/
Static Function SelectLog()
	If oListDatas:GetPos() <= 0 .OR. Len(aListaArquivos) <= 0 .OR. oListDatas:GetPos() > Len(aListaArquivos)
		Return .F.
	EndIf
	
	CursorWait()
	oLayerLog:setWinTitle('COL_RIGHT', 'WIN_RIGHT', aLogPattern[oTipoLog:nAt, 1] + " - " + aListaArquivos[oListDatas:GetPos()], 'BOTTOM' )
	cLogBody := MemoRead(cDirLog + aListaArquivos[oListDatas:GetPos()])
	oLogBody:Refresh()
	CursorArrow()
Return .T.
