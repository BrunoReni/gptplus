#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*-------------------------------------------------------------------                                                                           
{Protheus.doc} GFEA062CTB
Copia a Tabela de Frete, necessário GVA posicionada

@author Israel A. Possoli
@since 18/03/2014
@version 1.0 
-------------------------------------------------------------------*/
Function GFECPYTBFR()
	Local aAreaGVA := GVA->(getArea())
	Local oDlg
	Local oCdTab
	Local oCdTransp
	Local oDsTab
	Local cDsTab := GVA->GVA_DSTAB
	Local oDsTransp
	Local cDsTransp := POSICIONE("GU3",1,XFILIAL("GU3")+GVA->GVA_CDEMIT,"GU3_NMEMIT")
	Local oFolder1
	Local oGroup1
	Local oGroup2
	Local oNovCdTransp
	Local oPanel1
	Local oPanel2
	Local oPanel3

	Private oNovDsTransp
	Private cNovDsTransp := Space(TamSX3("GU3_NMEMIT")[1])
	Private oNovTabDes
	Private cNovTabDes := PadR(GVA->GVA_DSTAB, TamSX3("GVA_DSTAB")[1])
	Private oChkTarifas
	Private oChkZerar
	Private lCopyRotas   := .T.
	Private lCopyFaixas  := .T.
	Private lCopyTarifas := .T.
	Private lCopyZerar   := .F.
	Private cCdTransp 	 := GVA->GVA_CDEMIT
	Private cCdTab 		 := GVA->GVA_NRTAB
	Private cNovCdTab 	 := Space(TamSX3("GVA_NRTAB")[1])
	Private cNovCdTransp := Space(TamSX3("GVA_CDEMIT")[1])
	Private oGetNeg
	Private aHeadNeg := {} 
	
	If GVA->GVA_TPTAB == "2"
		Help( ,, 'Help' ,, "Não é possível copiar uma tabela do tipo 'Vínculo'.", 1, 0 )
		Return .F.
	EndIf
	
	
	aHeadNeg := DefTabNeg()
	
  	DEFINE MSDIALOG oDlg TITLE "Cópia da Tabela de Frete" FROM 000, 000  TO 520, 700 PIXEL
  		CursorWait()
  		
		@ 000, 000 MSPANEL oPanel1 SIZE 350, 045 OF oDlg  RAISED
		@ 040, 000 MSPANEL oPanel2 SIZE 350, 065 OF oDlg  RAISED    
		@ 080, 000 MSPANEL oPanel3 SIZE 350, 120 OF oDlg  RAISED
		    
		@ 000, 000 GROUP oGroup1 TO 039, 349 PROMPT "Tabela de Frete Base " OF oPanel1 PIXEL
		@ 000, 000 GROUP oGroup2 TO 039, 349 PROMPT "Nova Tabela de Frete " OF oPanel2 PIXEL
			
		@ 010, 004 SAY oSay3 PROMPT "Transportador:" SIZE 037, 007 OF oGroup1 PIXEL
		@ 009, 046 MSGET oCdTransp VAR cCdTransp SIZE 055, 010 OF oGroup1 WHEN .F. PIXEL
		@ 009, 115 MSGET oDsTransp VAR cDsTransp SIZE 135, 010 OF oGroup1 WHEN .F. PIXEL
	    @ 025, 004 SAY oSay4 PROMPT "Tabela:" SIZE 025, 007 OF oGroup1 PIXEL
	    @ 023, 046 MSGET oCdTab VAR cCdTab SIZE 055, 010 OF oGroup1 WHEN .F. PIXEL
	    @ 023, 115 MSGET oDsTab VAR cDsTab SIZE 135, 010 OF oGroup1 WHEN .F. PIXEL
	    
	    @ 010, 004 SAY oSay5 PROMPT "Transportador:" SIZE 037, 007 OF oGroup2 PIXEL
	    @ 009, 046 MSGET oNovCdTransp VAR cNovCdTransp SIZE 055, 010 OF oGroup2 F3 "GU3TRP" VALID ValidTransp(cNovCdTransp) PIXEL
	    @ 009, 115 MSGET oNovDsTransp VAR cNovDsTransp SIZE 135, 010 OF oGroup2 WHEN .F. PIXEL
	    @ 025, 004 SAY oSay6 PROMPT "Tabela:" SIZE 025, 007 OF oGroup2 PIXEL
	    @ 023, 046 MSGET oNovCdTab VAR cNovCdTab SIZE 055, 010 OF oGroup2 PIXEL
	    
	    @ 040, 004 SAY oSay7 PROMPT "Descrição:" SIZE 037, 007 OF oGroup2 PIXEL
	    @ 038, 046 MSGET oNovTabDes VAR cNovTabDes SIZE 204, 010 PICTURE "@!" OF oGroup2  PIXEL
	    
	    @ 053, 046 CHECKBOX oCheckBo1   VAR lCopyRotas   PROMPT "Rotas" SIZE 048, 012 OF oGroup2 COLORS 0, 16777215 PIXEL ON CLICK(ChkOpCopy()) 
	    @ 053, 086 CHECKBOX oCheckBo2   VAR lCopyFaixas  PROMPT "Faixas" SIZE 048, 012 OF oGroup2 COLORS 0, 16777215 PIXEL ON CLICK(ChkOpCopy()) 
	    @ 053, 126 CHECKBOX oChkTarifas VAR lCopyTarifas PROMPT "Tarifas" SIZE 048, 012 OF oGroup2 COLORS 0, 16777215 PIXEL
	    @ 053, 166 CHECKBOX oChkZerar   VAR lCopyZerar   PROMPT "Zerar Tarifas" SIZE 048, 012 OF oGroup2 PIXEL
	    
	    
	    @ 000, 000 FOLDER oFolder1 SIZE 300, 119 OF oPanel3 ITEMS "Negociações" COLORS 0, 14215660 PIXEL
	    
	   	oGetNeg := MsNewGetDados():New(05, 05, 60, 160, GD_UPDATE, "AllwaysTrue", "AllwaysTrue",/*[ cIniCpos]*/, {"NDTVALI", "NDTVALF"}	,/* [ nFreeze]*/,/*[ nMax]*/,"AllwaysTrue",/*[ cSuperDel]*/,/*[ cDelOk]*/, oFolder1:ADialogs[1], aHeadNeg, /* aColsFil*/,,/*[ cTela]*/)
	   	oGetNeg:oBrowse:blDblClick 	:= { |x,nCol| IIf( nCol == 1, MrkLinha(), oGetNeg:EditCell()) }
	
	    oPanel1:Align  := CONTROL_ALIGN_TOP
	    oPanel2:Align  := CONTROL_ALIGN_TOP
	    oGroup1:Align  := CONTROL_ALIGN_ALLCLIENT
	    oGroup2:Align  := CONTROL_ALIGN_ALLCLIENT
	    oPanel3:Align  := CONTROL_ALIGN_ALLCLIENT
	    oFolder1:Align := CONTROL_ALIGN_ALLCLIENT
	    oGetNeg:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	    
	    CarregaDados(cCdTransp, cCdTab)
	    oGetNeg:oBrowse:GoBottom()
	    oGetNeg:oBrowse:GoTop()
	    oGetNeg:oBrowse:Refresh()
	    CursorArrow()
	    
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||btOK()}, {||ODlg:End()}) CENTERED

Return

/*-------------------------------------------------------------------                                                                           
ValidTransp
Validação do campo Novo Transportador

@author Israel A. Possoli
@since 24/03/2014
@version 1.0
-------------------------------------------------------------------*/
Static Function ValidTransp(cNovCdTransp)
	Local lRet
	lRet := ExistCpo("GU3",cNovCdTransp)
	
	If lRet
		cNovDsTransp := POSICIONE("GU3",1,XFILIAL("GU3")+cNovCdTransp,"GU3_NMEMIT")
		oNovDsTransp:CtrlRefresh()
	Else
		cNovDsTransp := ""
		oNovDsTransp:CtrlRefresh()
	EndIf
	
Return (lRet)

/*-------------------------------------------------------------------                                                                           
ChkOpCopy
Validação dos CheckBoxs de Rota e Faixas

@author Israel A. Possoli
@since 24/03/2014
@version 1.0
-------------------------------------------------------------------*/
Static Function ChkOpCopy()
	If lCopyRotas == .F. .OR. lCopyFaixas == .F.
		lCopyTarifas := .F.
		lCopyZerar   := .F.
		
		oChkTarifas:Disable()
		oChkZerar:Disable()
		
		oChkTarifas:CtrlRefresh()
		oChkZerar:CtrlRefresh()
	Else
		lCopyTarifas := .T.
		lCopyZerar   := .F.
		
		oChkTarifas:SetColor(0, 16777215)
		oChkTarifas:Enable()
		oChkZerar:Enable()
		
		oChkTarifas:CtrlRefresh()
		oChkZerar:CtrlRefresh()	
	EndIf
Return


/*-------------------------------------------------------------------                                                                           
MrkLinha
Evento de duplo clique

@author Israel A. Possoli
@since 19/03/2014
@version 1.0
-------------------------------------------------------------------*/
Static Function MrkLinha()
	// Local nId := Val(AllTrim(oGet:aCols[oGet:nAt, Len(oGet:aCols[oGet:nAt]) - 1]))
		
	If GDFieldGet( 'MRK', oGetNeg:nAt,, oGetNeg:aHeader, oGetNeg:aCols ) == 'LBNO'
		GDFieldPut( 'MRK', 'LBOK', oGetNeg:nAt, oGetNeg:aHeader, oGetNeg:aCols )
	Else
		GDFieldPut( 'MRK'       , 'LBNO' , oGetNeg:nAt , oGetNeg:aHeader , oGetNeg:aCols )
	EndIf
Return

/*-------------------------------------------------------------------                                                                           
CarregaDados
Carre dados

@author Israel A. Possoli
@since 19/03/2014
@version 1.0
-------------------------------------------------------------------*/
Static Function CarregaDados(cCdTransp, cCdTab)
	Local aCols := {}
	
	GV9->(dbSetOrder(1))
	GV9->(dbSeek(xFilial("GV9") + cCdTransp + cCdTab))
	While !GV9->(Eof())						 .AND. ;
		   GV9->GV9_FILIAL == xFilial("GV9") .AND. ;
		   GV9->GV9_CDEMIT == cCdTransp		 .AND. ;
		   GV9->GV9_NRTAB  == cCdTab
		   
		AAdd(aCols, Array(Len(aHeadNeg)+2))
		
		aCols[Len(aCols), 1] := "LBOK"
		aCols[Len(aCols), 2] := GV9->GV9_NRNEG
		aCols[Len(aCols), 3] := GV9->GV9_CDCLFR
		aCols[Len(aCols), 4] := Posicione("GUB",1,xFilial("GUB")+GV9->GV9_CDCLFR,"GUB_DSCLFR")
		aCols[Len(aCols), 5] := GV9->GV9_CDTPOP
		aCols[Len(aCols), 6] := Posicione("GV4",1,xFilial("GV4")+GV9->GV9_CDTPOP,"GV4_DSTPOP")
		aCols[Len(aCols), 7] := DToC(GV9->GV9_DTVALI)
		aCols[Len(aCols), 8] := DToC(GV9->GV9_DTVALF)
		aCols[Len(aCols), 9] := GV9->GV9_DTVALI
		aCols[Len(aCols),10] := GV9->GV9_DTVALF
		aCols[Len(aCols),Len(aHeadNeg)+2] := .F.
		
		GV9->(dbSkip())	   
	EndDo

	
	oGetNeg:SetArray(aCols, .T.)
	
	oGetNeg:oBrowse:Refresh()
Return


/*-------------------------------------------------------------------                                                                           
{Protheus.doc} btOK
Ação do botão Confirmar da Janela

@author Israel A. Possoli
@since 24/03/2014
@version 1.0
-------------------------------------------------------------------*/
Static Function btOK()
	Local aAreaGVA
	Local aAreaGV9
	Private cErros := ""
	
	If Empty(cNovCdTransp) .OR. Empty(cNovCdTab)
		Help( ,, 'Help' ,, "Informe o Transportador e o Código da tabela para a cópia.", 1, 0 )
		Return .F.
	EndIf
	
	GVA->(dbSetOrder(1))
	If GVA->(dbSeek(xFilial("GVA") + PadR(cNovCdTransp, TamSX3("GVA_CDEMIT")[1]) + PadR(alltrim(cNovCdTab), TamSX3("GVA_NRTAB")[1])))
		Help( ,, 'Help' ,, "Já existe uma tabela cadastrada com este Transportador e Código.", 1, 0 )
		Return .F.
	EndIf
	
	aAreaGVA  := GVA->(getArea())
	aAreaGV9 := GV9->(getArea())
	
	Processa({|| CopyTabFrete()}, "Cópia")
	
	RestArea(aAreaGVA)
	RestArea(aAreaGV9)
	
	If Empty(cErros)
		MsgInfo("Tabela copiada", "Cópia")
	Else
		Alert("Processo concluído, porém ocorreram os seguintes erros: " + CHR(10) + CHR(13) + cErros, "Erros")
	EndIf
	
Return		

/*-------------------------------------------------------------------                                                                           
{Protheus.doc} GFEA062CTB
Efetiva a cópia da tabela de frete

@author Israel A. Possoli
@since 19/03/2014
@version 1.0
-------------------------------------------------------------------*/
Static Function CopyTabFrete()
	Local aAreaCopy
	Local cNrNeg
	Local dNDTVALI
	Local dNDTVALF
	Local nI
	Local aCopyG	:= {}
	Local nCnt
	Local cAliasGV8	:= Nil
	Local cAliasGV7	:= Nil
	
	ProcRegua(0)
	GVA->( dbSetOrder(1) )
	If GVA->(dbSeek(xFilial("GVA") + cCdTransp + cCdTab))
		IncProc("Copiando Tabela de Frete...")
		
		aCopyG	:= {}
		For nCnt := 1 To GVA->(FCount())
			IF GFXRL12123("GVA",GVA->(Field(nCnt)))
				AAdd(aCopyG, GVA->(FieldGet(nCnt)))
			EndIf
		Next nCnt

		RecLock("GVA", .T.)
			For nCnt := 1 To Len(aCopyG)
				FieldPut(nCnt, aCopyG[nCnt])
			Next nCnt
			GVA->GVA_FILIAL	:= 	xFilial("GVA")
			GVA->GVA_CDEMIT	:= 	cNovCdTransp
			GVA->GVA_NRTAB	:= 	alltrim(cNovCdTab)
			GVA->GVA_DSTAB  	:= 	cNovTabDes
			GVA->GVA_DTCRIA	:= 	Date()
			GVA->GVA_HRCRIA	:= 	Time()
			GVA->GVA_USUCRI 	:= 	cUserName
			GVA->GVA_DTATU	:= 	Date()
			GVA->GVA_HRATU	:= 	Time()
			GVA->GVA_USUATU 	:= 	cUserName
			GVA->GVA_DTAPR  	:= 	Stod("  /  /  ")
			GVA->GVA_HRAPR  	:= 	""
			GVA->GVA_USUAPR 	:= 	""
			GVA->GVA_DTNEG  	:= 	DDATABASE
			GVA->GVA_SITVIN	:= 	"1"
			GVA->GVA_ENVAPR 	:= 	"2"
			GVA->GVA_MTVRPR 	:= 	""
			GVA->GVA_OBS    	:= 	"Cópia da tabela de frete pelo usuário '" + cUserName+ "'. Tabela base: Emitente: " + cCdTransp + ", Tabela: " + cCdTab
			If GFE61EXCPL()
				GVA->GVA_CPLSIT	:= "1" //Não enviada
			EndIf
		GVA->(MsUnLock())

		//Atualiza situação de integração do cockpit logístico
		GFE61ATDP(cNovCdTransp + alltrim(cNovCdTab))
		For nI := 1 To Len(oGetNeg:aCols)
			IncProc("Copiando Tabela de Frete...")
			If GDFieldGet( 'MRK', nI,, oGetNeg:aHeader, oGetNeg:aCols ) == 'LBOK'
				cNrNeg		:= GDFieldGet( 'NRNEG', nI,, oGetNeg:aHeader, oGetNeg:aCols )
				dNDTVALI 	:= GDFieldGet( 'NDTVALI', nI,, oGetNeg:aHeader, oGetNeg:aCols )
				dNDTVALF 	:= GDFieldGet( 'NDTVALF', nI,, oGetNeg:aHeader, oGetNeg:aCols )

					GV9->( dbSetOrder(1) )
					If GV9->(dbSeek(xFilial("GV9") + cCdTransp + cCdTab + cNrNeg))
						// -- Copia da Negociação -----------------------------------

						aCopyG	:= {}
						For nCnt := 1 To GV9->(FCount())
							IF GFXRL12123("GV9",GV9->(Field(nCnt)))
								AAdd(aCopyG, GV9->(FieldGet(nCnt)))
							EndIf
						Next nCnt
				
						RecLock("GV9", .T.)
							For nCnt := 1 To Len(aCopyG)
								FieldPut(nCnt, aCopyG[nCnt])
							Next nCnt

							GV9->GV9_FILIAL 	:= 	xFilial("GV9")
							GV9->GV9_CDEMIT 	:= 	cNovCdTransp
							GV9->GV9_NRTAB	:= 	alltrim(cNovCdTab)
							GV9->GV9_DTCRIA 	:= 	DDATABASE
							GV9->GV9_HRCRIA 	:= 	SubStr(TIME(), 1, 5)
							GV9->GV9_USUCRI 	:= 	cUserName
							GV9->GV9_ENVAPR 	:= 	"2"
							GV9->GV9_DTAPR  	:= 	Stod("  /  /  ")
							GV9->GV9_HRAPR  	:= 	""
							GV9->GV9_USUAPR 	:= 	""
							GV9->GV9_MTVRPR 	:= 	""
							GV9->GV9_SIT		:= 	"1"
							GV9->GV9_DTVALI 	:= 	dNDTVALI
							GV9->GV9_DTVALF 	:= 	dNDTVALF
							GV9->GV9_CODCOT := ""
							GV9->GV9_SEQCOT := ""
							GV9->GV9_SITMLA := "1"
							GV9->GV9_MOTMLA := ""
						GV9->(MsUnLock())
						
						// -- Copia dos Componentes ---------------------------------
						GUY->( dbSetOrder(1) )
						GUY->(dbSeek(xFilial("GUY") + cCdTransp + cCdTab + cNrNeg))
						While !GUY->(Eof()) .AND. ;
						       GUY->GUY_FILIAL == xFilial("GUY") .AND. ;
						       GUY->GUY_CDEMIT == cCdTransp  	 .AND. ;
						       GUY->GUY_NRTAB  == cCdTab 		 .AND. ;
						       GUY->GUY_NRNEG  == cNrNeg
						       
							aAreaCopy := GUY->(GetArea())						       
						       
							aCopyG	:= {}
							For nCnt := 1 To GUY->(FCount())
								IF GFXRL12123("GUY",GUY->(Field(nCnt)))
									AAdd(aCopyG, GUY->(FieldGet(nCnt)))
								EndIf
							Next nCnt
					
							RecLock("GUY", .T.)
								For nCnt := 1 To Len(aCopyG)
									FieldPut(nCnt, aCopyG[nCnt])
								Next nCnt

								GUY->GUY_FILIAL := xFilial("GUY")
								GUY->GUY_CDEMIT := cNovCdTransp
								GUY->GUY_NRTAB  := alltrim(cNovCdTab)
							GUY->(MsUnLock())
						    
						    RestArea(aAreaCopy)
							GUY->(dbSkip())
						EndDo
						
						// -- Copia das Rotas ---------------------------------------
						If lCopyRotas
							cAliasGV8 := GetNextAlias()
							BeginSql Alias cAliasGV8
								SELECT GV8.R_E_C_N_O_ RECNOGV8
								FROM %Table:GV8% GV8
								WHERE GV8.GV8_FILIAL = %xFilial:GV8%
								AND GV8.GV8_CDEMIT = %Exp:cCdTransp%
								AND GV8.GV8_NRTAB = %Exp:cCdTab%
								AND GV8.GV8_NRNEG = %Exp:cNrNeg%
								AND GV8.%NotDel%
							EndSql
							If (cAliasGV8)->(!Eof())
								Do While (cAliasGV8)->(!Eof())
									GV8->(dbGoTo((cAliasGV8)->RECNOGV8))
									aAreaCopy := Gv8->(GetArea())
									
									aCopyG	:= {}
									For nCnt := 1 To GV8->(FCount())
										If GFXRL12123("GV8",GV8->(Field(nCnt)))
											AAdd(aCopyG, GV8->(FieldGet(nCnt)))
										EndIf
									Next nCnt

									RecLock("GV8", .T.)
										For nCnt := 1 To Len(aCopyG)
											FieldPut(nCnt, aCopyG[nCnt])
										Next nCnt

										GV8->GV8_FILIAL := xFilial("GV8")
										GV8->GV8_CDEMIT := cNovCdTransp
										GV8->GV8_NRTAB  := alltrim(cNovCdTab)
									GV8->(MsUnLock())
									
									RestArea(aAreaCopy)
									(cAliasGV8)->(dbSkip())
								EndDo
							EndIf
							(cAliasGV8)->(dbCloseArea())
						EndIf

						// -- Copia das Faixas---------------------------------------
						If lCopyFaixas 
							cAliasGV7 := GetNextAlias()
							BeginSql Alias cAliasGV7
								SELECT GV7.R_E_C_N_O_ RECNOGV7
								FROM %Table:GV7% GV7
								WHERE GV7.GV7_FILIAL = %xFilial:GV7%
								AND GV7.GV7_CDEMIT = %Exp:cCdTransp%
								AND GV7.GV7_NRTAB = %Exp:cCdTab%
								AND GV7.GV7_NRNEG = %Exp:cNrNeg%
								AND GV7.%NotDel%
							EndSql
							If (cAliasGV7)->(!Eof())
								Do While (cAliasGV7)->(!Eof())
									GV7->(dbGoTo((cAliasGV7)->RECNOGV7))
									aAreaCopy := GV7->(GetArea())
									
									aCopyG	:= {}
									For nCnt := 1 To GV7->(FCount())
										If GFXRL12123("GV7",GV7->(Field(nCnt)))
											AAdd(aCopyG, GV7->(FieldGet(nCnt)))
										EndIf
									Next nCnt

									RecLock("GV7", .T.)
										For nCnt := 1 To Len(aCopyG)
											FieldPut(nCnt, aCopyG[nCnt])
										Next nCnt

										GV7->GV7_FILIAL := xFilial("GV7")
										GV7->GV7_CDEMIT := cNovCdTransp
										GV7->GV7_NRTAB  := alltrim(cNovCdTab)
									GV7->(MsUnLock())
							    									
									RestArea(aAreaCopy)
									(cAliasGV7)->(dbSkip())
								EndDo
							EndIf
							(cAliasGV7)->(dbCloseArea())
						EndIf
											
						// -- Copia das Faixas e Entrega ----------------------------
						GUZ->( dbSetOrder(1) )
						GUZ->(dbSeek(xFilial("GUZ") + cCdTransp + cCdTab + cNrNeg))
						While !GUZ->(Eof()) .AND. ;
						       GUZ->GUZ_FILIAL == xFilial("GUZ") .AND. ;
						       GUZ->GUZ_CDEMIT == cCdTransp  	 .AND. ;
						       GUZ->GUZ_NRTAB  == cCdTab 		 .AND. ;
						       GUZ->GUZ_NRNEG  == cNrNeg
							       
							aAreaCopy := GUZ->(GetArea())						       
							       
							aCopyG	:= {}
							For nCnt := 1 To GUZ->(FCount())
								IF GFXRL12123("GUZ",GUZ->(Field(nCnt)))
									AAdd(aCopyG, GUZ->(FieldGet(nCnt)))
								EndIf
							Next nCnt
					
							RecLock("GUZ", .T.)
								For nCnt := 1 To Len(aCopyG)
									FieldPut(nCnt, aCopyG[nCnt])
								Next nCnt

								GUZ->GUZ_FILIAL := xFilial("GUZ")
								GUZ->GUZ_CDEMIT := cNovCdTransp
								GUZ->GUZ_NRTAB  := alltrim(cNovCdTab)
							GUZ->(MsUnLock())
							    
						    RestArea(aAreaCopy)
							GUZ->(dbSkip())
						EndDo
						
						
						// -- Copia das Tarifas -------------------------------------
						If lCopyTarifas .AND. lCopyRotas .AND. lCopyFaixas
							GV6->( dbSetOrder(1) )
							GV6->(dbSeek(xFilial("GV6") + cCdTransp + cCdTab + cNrNeg))
							While !GV6->(Eof()) .AND. ;
							       GV6->GV6_FILIAL == xFilial("GV6") .AND. ;
							       GV6->GV6_CDEMIT == cCdTransp  	 .AND. ;
							       GV6->GV6_NRTAB  == cCdTab 		 .AND. ;
							       GV6->GV6_NRNEG  == cNrNeg
								       
								aAreaCopy := GV6->(GetArea())						       
								       
								aCopyG	:= {}
								For nCnt := 1 To GV6->(FCount())
									IF GFXRL12123("GV6",GV6->(Field(nCnt)))
										AAdd(aCopyG, GV6->(FieldGet(nCnt)))
									EndIf
								Next nCnt
						
								RecLock("GV6", .T.)
									For nCnt := 1 To Len(aCopyG)
										FieldPut(nCnt, aCopyG[nCnt])
									Next nCnt

									GV6->GV6_FILIAL := xFilial("GV6")
									GV6->GV6_CDEMIT := cNovCdTransp
									GV6->GV6_NRTAB  := alltrim(cNovCdTab)
									GV6->GV6_DTATU  := DDATABASE
									GV6->GV6_HRATU  := Time()
									GV6->GV6_USUATU := cUserName
								GV6->(MsUnLock())
							    
							    RestArea(aAreaCopy)
								GV6->(dbSkip())
							EndDo
							
							// -- Copia dos Componentes das Tarifas ---------------------
							GV1->(dbSetOrder(1))
							GV1->(dbSeek(xFilial("GV1") + cCdTransp + cCdTab + cNrNeg))
							While !GV1->(Eof()) .AND. ;
							       GV1->GV1_FILIAL == xFilial("GV1") .AND. ;
							       GV1->GV1_CDEMIT == cCdTransp  	 .AND. ;
							       GV1->GV1_NRTAB  == cCdTab 		 .AND. ;
							       GV1->GV1_NRNEG  == cNrNeg
								       
								aAreaCopy := GV1->(GetArea())						       
								       
								aCopyG	:= {}
								For nCnt := 1 To GV1->(FCount())
									IF GFXRL12123("GV1",GV1->(Field(nCnt)))
										AAdd(aCopyG, GV1->(FieldGet(nCnt)))
									EndIf
								Next nCnt
						
								RecLock("GV1", .T.)
									For nCnt := 1 To Len(aCopyG)
										FieldPut(nCnt, aCopyG[nCnt])
									Next nCnt

									GV1->GV1_FILIAL := xFilial("GV1")
									GV1->GV1_CDEMIT := cNovCdTransp
									GV1->GV1_NRTAB  := alltrim(cNovCdTab)
									
									If lCopyZerar
										GV1->GV1_VLFIXN := 0
										GV1->GV1_PCNORM := 0
										GV1->GV1_VLUNIN := 0
										GV1->GV1_VLFRAC := 0
										GV1->GV1_VLMINN := 0
										GV1->GV1_VLLIM  := 0
										GV1->GV1_VLFIXE := 0
										GV1->GV1_PCEXTR := 0
										GV1->GV1_VLUNIE := 0
									EndIf
								GV1->(MsUnLock())
								    
							    RestArea(aAreaCopy)
								GV1->(dbSkip())
							EndDo
							
							// -- Copia dos Componentes Adicionais das Tarifas ----------
							GUC->(dbSetOrder(1))
							GUC->(dbSeek(xFilial("GUC") + cCdTransp + cCdTab + cNrNeg))
							While !GUC->(Eof()) .AND. ;
							       GUC->GUC_FILIAL == xFilial("GUC") .AND. ;
							       GUC->GUC_CDEMIT == cCdTransp  	 .AND. ;
							       GUC->GUC_NRTAB  == cCdTab 		 .AND. ;
							       GUC->GUC_NRNEG  == cNrNeg
								       
								aAreaCopy := GUC->(GetArea())						       
								       
								aCopyG	:= {}
								For nCnt := 1 To GUC->(FCount())
									IF GFXRL12123("GUC",GUC->(Field(nCnt)))
										AAdd(aCopyG, GUC->(FieldGet(nCnt)))
									EndIf
								Next nCnt
						
								RecLock("GUC", .T.)
									For nCnt := 1 To Len(aCopyG)
										FieldPut(nCnt, aCopyG[nCnt])
									Next nCnt

									GUC->GUC_FILIAL := xFilial("GUC")
									GUC->GUC_CDEMIT := cNovCdTransp
									GUC->GUC_NRTAB  := alltrim(cNovCdTab)
									
									If lCopyZerar
										GUC->GUC_VLFIXN := 0
										GUC->GUC_PCNORM := 0
										GUC->GUC_VLUNIN := 0
										GUC->GUC_VLFRAC := 0
										GUC->GUC_VLMINN := 0
										GUC->GUC_PCLIM  := 0
										GUC->GUC_VLLIM  := 0
										GUC->GUC_VLFIXE := 0
										GUC->GUC_PCEXTR := 0
										GUC->GUC_VLUNIE := 0
									EndIf
								GUC->(MsUnLock())
								    
							    RestArea(aAreaCopy)
								GUC->(dbSkip())
							EndDo							
						EndIf
					Else
						cErros := cErros + "** Negociação não encontrada. Emitente: " + cCdTransp + ", Tabela: " + cCdTab + ", Negociação: " + cNrNeg + CHR(10) + CHR(13) + CHR(10) + CHR(13)
					EndIf
			EndIf
		Next
	Else
		cErros := cErros + "** Tabela não encontrada. Emitente: " + cCdTransp + ", Tabela: " + cCdTab + CHR(10) + CHR(13) + CHR(10) + CHR(13)
		Return .F.
	EndIf
	
Return

/*-------------------------------------------------------------------                                                                           
DefTabNeg
Definição do Grid de Negociações

@author Israel A. Possoli
@since 19/03/2014
@version 1.0
-------------------------------------------------------------------*/
Static Function DefTabNeg()

	Local aHead    := {}	// Campos da temp-table de Tabela de Frete
	
	aAdd( aHead, { ;
		''                 , ;    // 01 - Titulo
		'MRK'            , ;    // 02 - Campo
		'@BMP'             , ;    // 03 - Picture
		10                 , ;    // 04 - Tamanho
		0                  , ;    // 05 - Decimal
		''                 , ;    // 06 - Valid
		''                 , ;    // 07 - Usado
		'C'                , ;    // 08 - Tipo
		''                 , ;    // 09 - F3
		'R'                , ;    // 10 - Contexto
		''                 , ;    // 11 - ComboBox
		''             , ;    // 12 - Relacao
		''                 , ;    // 13 - Alterar
		'V'                , ;    // 14 - Visual
		''                 } )    // 15 - Valid Usuario
		
	AddTabHead(@aHead, "Negociação"   ,	"NRNEG"  , "C", TamSX3("GV9_NRNEG")[1] , 0, "@!")
	AddTabHead(@aHead, "Class.Frete"  , "CDCLFR" , "C", TamSX3("GV9_CDCLFR")[1], 0, "@!")
	AddTabHead(@aHead, "Descrição"    , "DSCLFR" , "C", 30, 0, "@!")
	AddTabHead(@aHead, "Tipo Oper."	  , "CDTPOP" , "C", TamSX3("GV9_CDTPOP")[1], 0, "@!")
	AddTabHead(@aHead, "Descrição"    , "DSOPER" , "C", 30, 0, "@!")
	AddTabHead(@aHead, "Vigencia De"  , "DTVALI" , "D", 08, 0, "")
	AddTabHead(@aHead, "Vigencia Ate" , "DTVALF" , "D", 08, 0, "")
	AddTabHead(@aHead, "Nova Vigencia De"  , "NDTVALI" , "D", 08, 0, "")
	AddTabHead(@aHead, "Nova Vigencia Ate" , "NDTVALF" , "D", 08, 0, "")

Return aHead


/*-------------------------------------------------------------------                                                                           
AddTabHead
Função para auxiliar a criação do Array de cabeçalho do Grid

@author Israel A. Possoli
@since 19/03/2014
@version 1.0
-------------------------------------------------------------------*/
Static Function AddTabHead(aHead, Titulo, Nome, TipoDado, Tamanho, Decimal, Mascara,cValid,cUsado,cF3)
	Default cValid := ''
	Default cUsado := ''
	Default cF3     := ''
	
	aAdd( aHead, { ;	
	Titulo			, ;    // 01 - Titulo
	Nome    		, ;    // 02 - Campo
	Mascara        	, ;    // 03 - Picture
	Tamanho        	, ;    // 04 - Tamanho
	Decimal        	, ;    // 05 - Decimal
	cValid         	, ;    // 06 - Valid
	cUsado          	, ;    // 07 - Usado
	TipoDado       	, ;    // 08 - Tipo
	cF3          	, ;    // 09 - F3
	'R'         	, ;    // 10 - Contexto
	''          	, ;    // 11 - ComboBox
	''      		, ;    // 12 - Relacao
	'.T.'          	, ;    // 13 - Alterar
	''         		, ;    // 14 - Visual
	''          	} )    // 15 - Valid Usuario
Return


