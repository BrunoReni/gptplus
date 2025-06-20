#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
#Include "FISA803.CH"

/*�������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  � FISA803  �Autor  �Luis Samaniego          � Data �  20/11/15   ���
�����������������������������������������������������������������������������͹��
���Desc.     � Certificados de retencion del SUSS                             ���
�����������������������������������������������������������������������������͹��
���Uso       � SIGAFIS                                                        ���
�����������������������������������������������������������������������������Ĵ��
���             ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�����������������������������������������������������������������������������Ĵ��
���Programador  � Data   �   BOPS   �  Motivo da Alteracao                	  ���
�����������������������������������������������������������������������������Ĵ��
���Marco A. Glz �06/04/17� MMI-4476 �Se replica llamado(TTREB6 - V11.8), El   ���
���             �        �          �cual prevee la funcionalidad para Certi- ���
���             �        �          �ficados de Retencion SUSS. (ARG)         ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
��������������������������������������������������������������������������������*/
Function FISA803()

	Local oFld		:= Nil
	Local aCombo	:= {}
	
	Private cCombo		:= ""
	Private oDlg		:= Nil
	Private cCodP		:= ""
	Private cLoja		:= ""
	Private cNumComp	:= ""
	Private nTamOrdP	:= TamSx3("FE_ORDPAGO")[1]
	Private aSFE		:= {}
	
	aAdd( aCombo, STR0001 )
	aAdd( aCombo, STR0002 )

	DEFINE MSDIALOG oDlg TITLE STR0003 FROM 0,0 TO 125,450 OF oDlg PIXEL

	@ 006,006 TO 045,170 LABEL STR0004 OF oDlg PIXEL
	@ 020,010 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 100,8 PIXEL OF oFld
	
	@ 009,180 BUTTON STR0005 SIZE 036,016 PIXEL ACTION F803SUSS(Val(Subs(cCombo,1,1)))
	@ 029,180 BUTTON STR0006 SIZE 036,016 PIXEL ACTION oDlg:End()
	
	ACTIVATE MSDIALOG oDlg CENTER
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F803SUSS  �Autor  �Luis Samaniego      �Fecha �  20/11/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Actualiza certificados de retencion del SUSS               ���
�������������������������������������������������������������������������͹��
���Uso       � FIS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function F803SUSS(nOpc)

	Local cFile    := ""
	Local cPerg    := "FISA803"
	Local nOpcA    := 0
	Local aSays    := {}
	Local aButtons := {}
	
	If nOpc == 1
		cFile := FGetFile()
		If !Empty(cFile) .And. File(cFile)
			Processa({ || ImpCerSUSS(cFile) })
			MsgInfo(STR0024) //"Ha finalizado el proceso de Importaci�n."
		EndIf	
	ElseIf nOpc == 2
		oDlg:End()
		Pergunte( cPerg, .F. )
		aAdd(aSays,OemToAnsi( STR0003) ) 
		aAdd(aButtons, { 5,.T.,{ || Pergunte(cPerg,.T. ) } } )
		aAdd(aButtons, { 1,.T.,{ |o| IIf(VldParam(),(nOpcA := 1, o:oWnd:End()),)}} )
		aAdd(aButtons, { 2,.T.,{ |o| nOpcA := 2,o:oWnd:End() }} )             
		FormBatch( OEMToAnsi(STR0003), aSays , aButtons )
		If nOpcA == 1
			CursorWait()
			BrwCerSUSS()
			CursorArrow()
		EndIf
	EndIf
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpCerSUSS�Autor  �Luis Samaniego      �Fecha �  20/11/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Importa certificados de retencion del SUSS                 ���
�������������������������������������������������������������������������͹��
���Uso       � FIS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ImpCerSUSS(cFile)

	Local cEscape  := '","'
	Local cLinea   := ""
	Local nHandle  := 0
	Local nLoop    := 0
	Local nTotLn   := 0
	Local aLinea   := {}
	
	nHandle := FT_FUse(cFile)
	
	If nHandle = -1 
		MsgAlert(STR0009 + cFile + STR0010)	// "El archivo " - " no puede abrirse."
		return .F.	
	Else
		FT_FGoTop()
		nTotLn := FT_FLastRec()
		ProcRegua( nTotLn )
	
		Do  While !FT_FEOF() 
			nLoop ++
			
			IncProc(STR0011 + Str(nLoop))
			cLinea := FT_FReadLn()
			cLinea := AllTrim(cLinea)
			aLinea := {}
			aSFE   := {}
			
			If SubStr(cLinea,len(cLinea),1) == '"'
				cLinea += ',"'
			EndIf
			
			For nloop := 1 To Len(cLinea)
				aAdd(aLinea, AllTrim(SubStr(cLinea, 1, At(cEscape, cLinea) -1)))
				cLinea := SubStr(cLinea, At(cEscape, cLinea) + 3, Len(cLinea) - At(cEscape, cLinea))
				If Len(cLinea) == 0
					Exit
				EndIf
			Next nloop
			
			If Upper(AllTrim(aLinea[3])) == "EMITIDO"
				ObtCodProv(AllTrim(aLinea[5])) //Se le pasa el CUIT del Proveedor
				cNumComp := AllTrim(aLinea[15]) //Orden de Pago
				
				If !Empty(cCodP) .And. !Empty(cLoja)
				
					BuscaSFE(IIf(AllTrim(aLinea[12]) == "OP", .T., .F.))
					
					Begin Transaction
						For nLoop := 1 To Len(aSFE)
							SFE->(dbGoTo(aSFE[nLoop]))
							If SFE->(RECNO()) == aSFE[nLoop]
								RecLock("SFE",.F.)
								SFE->FE_SIRESEG := FormatText(AllTrim(aLinea[2]))
								SFE->FE_SIRECER := FormatText(AllTrim(aLinea[1]))
								MsUnLock()
							EndIf
						Next nLoop
					End Transaction
				EndIf
				
			EndIf
			FT_FSKIP()
		EndDo
	EndIf    
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ObtCodProv�Autor  �Luis Samaniego      �Fecha �  20/11/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Obtiene codigo de proveedor y tienda                       ���
�������������������������������������������������������������������������͹��
���Uso       � FIS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ObtCodProv(cCert)

	DBSelectArea("SA2")
	SA2->(DBSetOrder(3))//"A2_FILIAL+A2_CGC"
	
	If SA2->(MsSeek(xFilial("SA2") + cCert))
		cCodP := SA2->A2_COD
		cLoja := SA2->A2_LOJA
	Else
		cCodP := ""
		cLoja := ""
	EndIf
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BuscaSFE  �Autor  �Luis Samaniego      �Fecha �  20/11/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca registros en SFE                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � FIS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function BuscaSFE(lOp)
	
	Local cQuery  := ""
	Local cTmpSFE := CriaTrab(Nil, .F.)

	cQuery := " SELECT * "
	cQuery += " FROM " + RetSQLName("SFE") 
	cQuery += " WHERE (FE_FORNECE = '" + cCodP + "' AND"
	cQuery += " FE_LOJA = '" + cLoja + "' AND"
	cQuery += " FE_TIPO = 'S') AND"
	If lOp
		cQuery += " FE_ORDPAGO = '" + Strzero(Val(cNumComp), nTamOrdP) + "' AND"
	Else
		cQuery += " FE_NFISCAL = '" + cNumComp + "' AND"
	EndIf
	cQuery += " D_E_L_E_T_ = ''"
	cQuery += " ORDER BY R_E_C_N_O_	ASC"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpSFE,.F.,.T.)  
	(cTmpSFE)->(dbGoTop())
	
	While (cTmpSFE)->(!EOF())
		aAdd(aSFE, (cTmpSFE)->R_E_C_N_O_)	
		(cTmpSFE)->(dbSkip())
	EndDo
	
	(cTmpSFE)->(DBCloseArea())
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BrwCerSUSS�Autor  �Luis Samaniego      �Fecha �  20/11/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta Browse para modificar certificados del SUSS          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � FIS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function BrwCerSUSS()

	Local aIndex		:= {}
	Local cFiltro		:= ""
	Local cExprFilTop	:= ""
	
	Private cDeProv		:= AllTrim(MV_PAR01)
	Private cAProv		:= AllTrim(MV_PAR02)
	Private aRotina		:= MenuDef()
	Private cCadastro	:= OemToAnsi(STR0003)
	Private bFiltraBrw	
	
	cFiltro := "(FE_FORNECE >= '" + cDeProv + "' .AND. FE_FORNECE <= '" + cAProv + "') .AND. FE_TIPO == 'S'"
	
	bFiltraBrw := { || FilBrowse( "SFE" , @aIndex , @cFiltro ) }
	Eval( bFiltraBrw ) 
	mBrowse( 6, 1,22,75,"SFE",,,22)
	EndFilBrw( "SFE" , @aIndex )

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F803Manut �Autor  �Luis Samaniego      �Fecha �  20/11/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta ventana para modificar certificados del SUSS         ���
�������������������������������������������������������������������������͹��
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function F803Manut(cAlias,nReg,nOpc)
	
	Local nOpca	
	Local oFld	:= Nil
	
	Private cCertSIRE	:= ""
	Private cCSegSIRE	:= ""
	Private oDlg		:= Nil
	
	SFE->(dbGoTo(nReg))
	
	cCertSIRE := SFE->FE_SIRECER
	cCSegSIRE := SFE->FE_SIRESEG
	
	DEFINE MSDIALOG oDlg TITLE STR0003 FROM 0,0 TO 250,450 OF oDlg PIXEL
	
	@ 006,006 FOLDER oFld OF oDlg PROMPT STR0004 PIXEL SIZE 165,100
	
	@ 005,005 SAY STR0013 SIZE 50,008 PIXEL OF oFld:aDialogs[1]
	@ 005,070 SAY SFE->FE_FORNECE SIZE 50,008 PIXEL OF oFld:aDialogs[1]
	
	@ 015,005 SAY STR0014 SIZE 50,008 PIXEL OF oFld:aDialogs[1]
	@ 015,070 SAY SFE->FE_LOJA SIZE 50,008 PIXEL OF oFld:aDialogs[1]
	
	@ 025,005 SAY STR0018 SIZE 50,008 PIXEL OF oFld:aDialogs[1]
	@ 025,070 SAY SFE->FE_ORDPAGO SIZE 50,008 PIXEL OF oFld:aDialogs[1]
	
	@ 035,005 SAY STR0016 SIZE 50,008 PIXEL OF oFld:aDialogs[1]
	@ 035,070 SAY SFE->FE_EMISSAO SIZE 50,008 PIXEL OF oFld:aDialogs[1]
	
	@ 045,005 SAY STR0017 SIZE 50,008 PIXEL OF oFld:aDialogs[1]
	@ 045,070 SAY SFE->FE_TIPO SIZE 50,008 PIXEL OF oFld:aDialogs[1]
	
	@ 055,005 SAY STR0020 SIZE 50,008 PIXEL OF oFld:aDialogs[1]
	@ 055,070 MSGET cCertSIRE SIZE 50,008 PIXEL OF oFld:aDialogs[1]
	
	@ 068,005 SAY STR0021 SIZE 50,008 PIXEL OF oFld:aDialogs[1]
	@ 068,070 MSGET cCSegSIRE SIZE 50,008 PIXEL OF oFld:aDialogs[1]
	
	@ 040,180 BUTTON STR0005 SIZE 036,016 PIXEL ACTION F803Graba(cCertSIRE, cCSegSIRE) 
	@ 060,180 BUTTON STR0006 SIZE 036,016 PIXEL ACTION oDlg:End()
	
	ACTIVATE MSDIALOG oDlg CENTER
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BrwCerSUSS�Autor  �Luis Samaniego      �Fecha �  20/11/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Graba certificado del SUSS en SFE                          ���
�������������������������������������������������������������������������͹��
���Uso       � FIS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function F803Graba(cCertSIRE, cCSegSIRE)
	
	Local nLoop := 0

	cCodP		:= AllTrim(SFE->FE_FORNECE)
	cLoja		:= AllTrim(SFE->FE_LOJA)
	cNumComp	:= AllTrim(SFE->FE_ORDPAGO)
	
	BuscaSFE(.T.)
	
	Begin Transaction
		For nLoop := 1 To Len(aSFE)
			SFE->(dbGoTo(aSFE[nLoop]))
			If SFE->(RECNO()) == aSFE[nLoop]
				RecLock("SFE",.F.)
					SFE->FE_SIRESEG := FormatText(AllTrim(cCSegSIRE))
					SFE->FE_SIRECER := FormatText(AllTrim(cCertSIRE))
				MsUnLock()
			EndIf
		Next nLoop
	End Transaction
	
	oDlg:End()
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F803ImpC  �Autor  �Luis Samaniego      �Fecha �  20/11/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Imprimir constancia de retencion del SUSS                  ���
�������������������������������������������������������������������������͹��
���Uso       � FIS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function F803ImpC(cAlias,nReg,nOpc)

	Local lCertIvSus:= ExistBlock("CERTIVSUS") 

	SFE->(dbGoTo(nReg))
	If lCertIvSus .And. AllTrim(SFE->FE_TIPO) == "S"
		ExecBlock("CERTIVSUS",.F.,.F.,{{SFE->FE_NROCERT,"S"},SFE->FE_CODASS,.F.})
	EndIf
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �Luis Samaniego      �Fecha �  20/11/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Crea opciones del menu                                     ���
�������������������������������������������������������������������������͹��
���Uso       � FIS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
	
	Local aRotina := {}
	
	aRotina := {{ OemToAnsi(STR0022), "F803Manut", 0, 4}, {OemToAnsi(STR0023), "F803ImpC", 0, 2}}
	
Return (aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FGetFile  �Autor  �Luis Samaniego      �Fecha �  20/11/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta ventana para seleccionar archivos                    ���
�������������������������������������������������������������������������͹��
���Uso       � FIS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FGetFile()
	
	Local cRet := Space(100)
	
	oDlg01 := MSDialog():New(000,000,100,500,STR0007,,,,,,,,,.T.)
	
	oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,{||ValExtFile(cRet)},,,,,,.T.,,,,,,,,,,"cRet")
	oBtn01 := TBtnBmp2():New(017,458,025,028,"folder6","folder6",,,{|| FGetDir(oGet01)},oDlg01,STR0007,,.T.)
		
	oBtn02 := SButton():New(035,185,1,{|| oDlg01:End() }         ,oDlg01,.T.,,)
	oBtn03 := SButton():New(035,215,2,{|| cRet:="",oDlg01:End() },oDlg01,.T.,,)
	
	oDlg01:Activate(,,,.T.,,,)

Return cRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FGetDir   �Autor  �Luis Samaniego      �Fecha �  20/11/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Monta ventana para seleccionar archivos                    ���
�������������������������������������������������������������������������͹��
���Uso       � FIS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FGetDir(oTGet)
	
	Local cDir := ""
	
	cDir := cGetFile(,STR0007,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)
	If !Empty(cDir)
		oTGet:cText := cDir
		oTGet:Refresh()
	Endif
	oTGet:SetFocus()

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValExtFile�Autor  �Luis Samaniego      �Fecha �  20/11/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida si es un archivo valido                             ���
�������������������������������������������������������������������������͹��
���Uso       � FIS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ValExtFile(cNomeFile)
	
	Local lRet	:= .T.
	Local cExt	:= SubStr(cNomeFile,Len(cNomeFile)-2)
	
	If Empty(UPPER(cNomeFile)) .or. !(cExt $"csv|CSV|txt|TXT")
		MsgAlert(STR0008)
		lRet := .F.
	End If

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FormatText�Autor  �Luis Samaniego      �Fecha �  20/11/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Elimina caracteres de una cadena de texto                  ���
�������������������������������������������������������������������������͹��
���Uso       � FIS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FormatText(cRet)

	cRet := Replace(cRet, '"', '')
	cRet := Replace(cRet, "'", '')
	
Return cRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VldParam  �Autor  �Luis Samaniego      �Fecha �  20/11/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida parametros                                          ���
�������������������������������������������������������������������������͹��
���Uso       � FIS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VldParam()
	
	Local lRet := .T.
	
	If Empty(MV_PAR01) .OR. Empty(MV_PAR02)
		lRet := .F.
	EndIf
	
Return lRet
