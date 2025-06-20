#Include "Protheus.ch"
#Include 'topconn.ch'
#Include "FISA201.ch"

#DEFINE _SEPARADOR ","

/*��������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o    �FISA201   �Autor  �Ra�l Ortiz                  �Data  �10/10/2018���
������������������������������������������������������������������������������Ĵ��
���Descri��o �Rutina para Padron de Jujuy (IIBB y de Contribuyentes)           ���
������������������������������������������������������������������������������Ĵ��
���Uso       �FISA101                                                          ���
������������������������������������������������������������������������������Ĵ��
���                         ATUAIZACOES SOFRIDAS                               ���
������������������������������������������������������������������������������Ĵ��
���Programador �Data    �  BOPS    �          Motivo da Alteracao              ���
������������������������������������������������������������������������������Ĵ��
���            �        �          �                                           ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
��������������������������������������������������������������������������������*/
Function FISA201()
	
Local oFld		:= Nil
Local oTipo		:= Nil                                                       			
Local aTipo		:= {}

Private cPerVig		:= Space(6) 	
Private oGet		:= Nil
Private oDlg		:= Nil
Private lAct		:= .F.
Private cMes		:= StrZero(Month(dDataBase), 2)
Private cAno		:= StrZero(Year(dDataBase), 4)
Private lRet		:= .T.
Private cTipo		:= STR0004
Private aLinea		:= {}    
Private nAliqEmpP	:= 0
Private nAliqEmpR	:= 0
Private oTmpTable	:= Nil
Private dIniVig		:= CTOD("//")
Private dFimVig		:= CTOD("//")

Public aQry := {}

	aAdd( aTipo, STR0002 ) //"1- Fornecedor"
	aAdd( aTipo, STR0003 ) //"2- Cliente"
	aAdd( aTipo, STR0004 ) //"3- Ambos"	   

	DEFINE MSDIALOG oDlg TITLE STR0005 FROM 0,0 TO 250,450 OF oDlg PIXEL //"Padr�n Jujuy"
	
	@ 006,006 TO 050,170 LABEL STR0006 OF oDlg PIXEL //"Par�metros"
	@ 020,010 SAY STR0027 SIZE 065,008 PIXEL OF oFld //"�Tipo de Contribuyente?"
	@ 020,100 COMBOBOX oTipo VAR cTipo ITEMS aTipo SIZE 65,8 PIXEL OF oFld //"1- Proveedor", "2- Cliente", "3- Cliente" 
	
	@ 035,010 SAY STR0026 SIZE 150,008 PIXEL OF oFld //"�Periodo de Vigencia?"
	@ 035,100 MSGET cAno PICTURE "@E 9999" VALID !Empty(cMes) SIZE 020,008 PIXEL OF oFld                                          
	@ 035,125 SAY "/" SIZE  150, 8 PIXEL OF oFld
	@ 035,130 MSGET cMes PICTURE "@E 99" VALID !Empty(cMes) SIZE  015,008 PIXEL OF oFld
	
	@ 060,006 FOLDER oFld OF oDlg PROMPT STR0008 PIXEL SIZE 165,050 

	//+----------------
	//| Campos Folder 2
	//+----------------
	@ 003,005 SAY STR0009 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta rutina tiene como objetivo importar el Padr�n DGR 83-14: Padr�n Coeficientes "
	@ 013,005 SAY STR0010 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"o el Padr�n DGR 83-14: Padr�n de Contribuyentes. "
	//+-------------------
	//| Boton de MSDialog
	//+-------------------
	@ 055,178 BUTTON STR0012 SIZE 036,016 PIXEL ACTION ImpArq() //"&Importar"
	@ 075,178 BUTTON STR0013 SIZE 036,016 PIXEL ACTION oDlg:End() //"&Sair"

	ACTIVATE MSDIALOG oDlg CENTER
Return

/*��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ImpArq    �Autor  �Ra�l Ortiz           �Data  �10/10/2018  ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Procesa archivo.                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nulo													      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Fiscal - Provincia de Jujuy			                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
��������������������������������������������������������������������������?/*/
Static Function ImpArq()

Local nPos		:= 0
Local cLine		:= ""
Local cFile		:= ""
Local cTmp		:= "TMP"
Local cArq		:= ""
Local aStru		:= {}
Local lImp		:= .F.
Local aOrdem	:= {} 

Private _cCont		:= 0
Private lExistEmp	:= .F.

	cTipo   := Subs(cTipo,1,1)  	//1 - Proveedor, 2 - Cliente y  3 - Ambos

	// Seleciona o arquivo
	cFile := FGetFile()

	If File(cFile) .And. !Empty(cFile)     

		//creamos la tabla temporal	
		AADD(aStru,{ "TMP_CUIT"    , "C",  12, 0})
		AADD(aStru,{ "TMP_FECHA"   , "C",  6, 0})
		AADD(aStru,{ "TMP_ALIQP"   , "C",  6,  0})
		AADD(aStru,{ "TMP_ALIQR"   , "C",  6,  0})

		aOrdem := {"TMP_CUIT"}

		oTmpTable := FWTemporaryTable():New("TMP")
		oTmpTable:SetFields(aStru)
		oTmpTable:AddIndex("IN1", aOrdem)
		oTmpTable:Create()
		// Se procesa archivo de texto	

					
		Processa( {|| lImp:= ObtFile(cFile,"TMP")},STR0014,Alltrim(cFile), .T. )
		
		
		
		If  lImp // Si el archivo fue procesado
			dIniVig := CTOD("01/" + cMes + "/" + cAno )
			dFimVig := CTOD(AllTrim(STR(f_UltDia(dIniVig))) + "/" + cMes + "/" + cAno )
			If  cTipo == "1" .Or. cTipo == "3"      //Procesa Proveedores
				Processa( {|| lExistEmp := ProcEmp()} , STR0014,STR0019, .T. )	//
				Processa( {|| ProcRegs(.F.)}, STR0014,STR0020, .T. )
			EndIf
			If  cTipo == "2" .Or. cTipo == "3"      //Procesa Clientes
				Processa( {|| ProcRegs(.T.)} , STR0014,STR0019, .T. )					
			EndIf		
		EndIf
		TMP->(dbCloseArea())  

		If lAct
			MsgAlert(STR0022)
		Else
			MsgAlert(STR0023)
		End If      	

		oDlg:End()	  

	Endif
	
	If oTmpTable <> Nil
		oTmpTable:Delete()
		oTmpTable := Nil
	EndIf

Return Nil

/*��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FGetFile  �Autor  �Ivan Haponczuk       �Data  �09.06.2011  ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Tela de sele��o do arquivo txt a ser importado.             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �cRet - Diretori e arquivo selecionado.                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Fiscal - Buenos Aires Argentina - MSSQL                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
��������������������������������������������������������������������������?/*/
Static Function FGetFile()

Local cRet := Space(50)

	oDlg01 := MSDialog():New(000,000,100,500,STR0018,,,,,,,,,.T.)//"Selecionar arquivo"

	oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,{||ValExtFile(cRet)},,,,,,.T.,,,,,,,,,,"cRet")
	oBtn01 := TBtnBmp2():New(017,458,025,028,"folder6","folder6",,,{|| FGetDir(oGet01)},oDlg01,STR0018,,.T.)//"Selecionar arquivo"

	oBtn02 := SButton():New(035,185,1,{|| oDlg01:End() }         ,oDlg01,.T.,,)
	oBtn03 := SButton():New(035,215,2,{|| cRet:="",oDlg01:End() },oDlg01,.T.,,)

	oDlg01:Activate(,,,.T.,,,)

Return cRet

/*��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FGetDir   �Autor  �Ivan Haponczuk       �Data  �09.06.2011  ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Tela para procurar e selecionar o arquivo nos diretorios    ���
���          �locais/servidor/unidades mapeadas.                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�oPar1 - Objeto TGet que ira receber o local e o arquivo     ���
���          �       selecionado.                                         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nulo                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Fiscal - Buenos Aires Argentina - MSSQL                     ���
��������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������?
��������������������������������������������������������������������������?/*/
Static Function FGetDir(oTGet)

Local cDir := ""

	cDir := cGetFile(,STR0019,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)//"Selecionar arquivo"
	If !Empty(cDir)
		oTGet:cText := cDir
		oTGet:Refresh()
	Endif
	oTGet:SetFocus()

Return Nil

/*��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ValExtFile�Autor  �Ra�l Ortiz           �Data  �10/10/2018  ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Valida extension del archivo seleccionado.                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Logico: Si extension es correcta o no.                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Fiscal - Provincia de Jujuy			                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�������������������������������������������������������������������������� /*/
Static Function ValExtFile(cNomeFile)
	
Local lRet := .T.
Local cExt	:= Substr(cNomeFile,len(cNomeFile)-2)//Substr(cNomeFile,at(".",cNomeFile)+1)

	If Empty(UPPER(cNomeFile)) .or. !(cExt $ "txt|TXT")
		MsgAlert(STR0026)
		lRet := .F.
	EndIf

Return lRet

/*��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ObtFile   �Autor  �Ra�l Ortiz           �Data  �10/10/2018  ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Lee archivo (.txt) y coloca su contenido en tabla temporal  ���
���          �TMP.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �	lRet - L�gico - Indica si se import� el archivo		      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Fiscal - Provincia de Jujuy 			                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
��������������������������������������������������������������������������?/*/
Static Function ObtFile(cFile,cAlias)
	
Local nFor		:= 0
Local nHandle	:= 0
Local nX		:= 0
Local lRet		:= .F.
Local lBandera	:= .T.
Local dFechaAux	:= CTOD("//") 
Local cLinPadron:= "" 
Local cQry 		:= ""

	dbSelectArea(cAlias)
	(cAlias)->(dbGoTop())	

	nHandle := FT_FUse(cFile)

	// Se hay error al abrir el archivo
	If  nHandle != -1

		// Se posiciona en la primera l�nea
		FT_FGoTop()

		nFor := FT_FLastRec()

		ProcRegua(nFor)

		While !FT_FEOF()   
			nX++		
			//nRecno 	:= FT_FRecno()   
			aLinea  := {}

			IncProc(STR0018 + str(nX))  //"Procesando registros..."   
			
			cLinPadron := FT_FREADLN()
			If Len(cLinPadron) < 28
				FT_FSKIP() 
				Loop
			EndIf
			
			aLinea := Separa(cLinPadron,_SEPARADOR)  
			
			If  Empty(aLinea) //Es una linea vacia
				FT_FSKIP() 
				Loop
			Endif 

			If !(Substr(aLinea[1],1,1) $ '0123456789') //NO es un registro valido
				FT_FSKIP() 
				Loop
			Endif 

			If  lBandera //Solo valida una vez
				If (cAno+cMes) != (SubStr(aLinea[2],1,4) + SubStr(aLinea[2],5,2))
					MsgAlert(STR0024)
					Exit
				EndIf 
				lBandera := .F.
			Endif			
			If !Empty(aLinea) 
				Reclock(cAlias,.T.)
					(cAlias)->TMP_CUIT		:= aLinea[1]
					(cAlias)->TMP_ALIQP		:= aLinea[3]
					(cAlias)->TMP_ALIQR     := aLinea[4]
				(cAlias)->(MsUnlock())			
				lRet := .T.							
			Endif
			
			FT_FSKIP() // Salta a siguiente l�nea
			
		EndDo

		//Cerrar archivo
		FT_FUSE()
	Else
		MsgAlert(STR0015 + cFile + STR0016)	// El archivo XXX no puede abrirse.		
	EndIf

Return lRet

/*/
����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ProcEmp   �Autor  �Ra�l Ortiz           �Data  �10/10/2018  ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Procesa para empresa.                                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lRet - Logico - Si la empresa se encuentra en el padr�n    ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Fiscal - Provincia de Jujuy			                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
Static Function ProcEmp()

	Local lRet	:= .F.
	Local aArea	:= GetArea()     

	dbSelectArea("SM0")
	dbSetOrder(1)
	SM0->(dbgotop())

	While SM0->(!EOF()) .and. !lRet //Se recorre SM0
		dbSelectArea("TMP")
		dbSetOrder(1)
		TMP->(MsSeek(AllTrim(SM0->M0_CGC))) //Se busca registro en tab temporal(TMP) por CIUT)

		If Found() .and. !Empty(SM0->M0_CGC)//Si es encontrado el CUIT 			
			lRet     := .T.
			nAliqEmpP := TMP->TMP_ALIQP
			nAliqEmpR := TMP->TMP_ALIQR
		EndIf
		SM0->(DbSkip())
	EndDo

	RestArea(aArea)

Return lRet

/*��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ProcRegs  �Autor  �Ra�l Ortiz           �Data  �11/10/2018  ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Tela para procurar e selecionar o arquivo nos diretorios    ���
���          �locais/servidor/unidades mapeadas.                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�lCli = .T. si selecciono cliente                            ���
���          �       .F. si es Proveedor                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nulo                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Fiscal - Provincia de Jujuy                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
��������������������������������������������������������������������������/*/
Static Function ProcRegs(lCli)

Local aArea		:= GetArea()
Local cQuery	:= ""	
Local cSA		:= Iif(lCli,InitSqlName("SA1"),InitSqlName("SA2"))	 
Local cMsg		:= Iif(lCli,STR0019,STR0020)       
Local cPref		:= Iif(lCli,"A1","A2")
Local cTmp 	    := Criatrab(nil,.F.)                               
Local aTmp		:= {}
Local nReg		:= 0
Local nI		:= 0
Local cClave	:= ""
Local nCont		:= 0 

	// Seleccionar clientes que no esten bloqueados y cuyo CUIT no este vacio y sean registros que no 
	// esten eliminados y para todas las filiales
	cQuery := " SELECT " + cPref + "_COD ," 
	cQuery +=		cPref + "_LOJA,"
	cQuery +=		cPref + "_CGC,  "
	cQuery +=		cPref + "_NOME, "
	cQuery +=		cPref + "_FILIAL "
	cQuery += " FROM "
	cQuery +=		cSA + " S"+ cPref + " " 
	cQuery += 	"WHERE "
	cQuery += 		cPref + "_CGC <> ' ' AND "
	cQuery += " D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY " + cPref + "_CGC "

	cQuery := ChangeQuery(cQuery)                    
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 

	Count to nCont
	(cTmp)->(dbGoTop())

	ProcRegua(nCont) 


	lExistEmp := ProcEmp()
	While (cTmp)->(!eof())      //Clientes/Proveedores
		nI++
		IncProc(cMsg + Str(nI))

		cClave := (cTmp)->&(cPref+"_CGC")

		dbSelectArea("TMP")
		dbSetOrder(1)

		//  Se realiza la busqueda por CUIT en la tabla Temporal 
		If (TMP->(MsSeek(cClave)))
			UPDSFH(cTmp,lCli,IiF(lCli,"C","P"),.T.)
		Else
			UPDSFH(cTmp,lCli,IiF(lCli,"C","P"),.F.)
		Endif

		IF !lCli
			UPDSFH(cTmp,lCli,"E",lExistEmp)
		EndIF

		(cTmp)->(dbSkip())	    
	EndDo

	(cTmp)->(dbCloseArea()) 

	RestArea(aArea)
	
Return

/*��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �UPDSFH    �Autor  �Ra�l Ortiz           �Data  �11/10/2018  ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Busca y actualiza registros en SFH 						  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cAlias - Tabla temp con los registros obtenidos de SA1/SA2  ���
���          �lCli   - Si .T. est?procesando Clientes					  ���
���          �			Si .F. est?procesandoProveedores				  ���
���          |lExiste- Si .T. se encuentra CUIT de Cliente/Prov en 	      ���
���          �			archivo ASCII 									  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nulo                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Fiscal - Argentina 			                  			  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�������������������������������������������������������������������������� /*/
Static Function UPDSFH(cAlias,lCli,cOrigen,lExist)

Local aArea		:= GetArea()
Local cQuery	:= ""	
Local cSFH		:= InitSqlName("SFH")
Local cTmp		:= criatrab(nil,.F.)                                
Local cPref		:= IIf(lCli,"A1","A2")
Local aTmp		:= {}
Local nReg		:= 0
Local j	   		:= 0
Local cPerAux	:= ""
Local aSFH		:= {} 
Local lRegSFH   := .F.

	//Seleccionar cliente o proveedor de SFH  
	cQuery := "SELECT * "
	cQuery += "FROM "
	cQuery +=		cSFH + " SFH " 
	cQuery += 	"WHERE " 
	cQuery += 	"FH_FILIAL ='" + xFilial("SFH") + "' AND "
	If  lCli	
		cQuery +=  	"FH_CLIENTE='" + (cAlias)->A1_COD	  	+ "' AND "
		cQuery += 	"FH_LOJA   ='" + (cAlias)->A1_LOJA   	+ "' AND "
	Else      
		cQuery +=  	"FH_FORNECE='" + (cAlias)->A2_COD		+ "' AND "
		cQuery += 	"FH_LOJA   ='" + (cAlias)->A2_LOJA   	+ "' AND "
	EndIF
	If cOrigen == "P"
		cQuery +=	"FH_IMPOSTO = 'IBR' AND "
	Else
		cQuery +=	"FH_IMPOSTO = 'IBC' AND "
	EndIf
	cQuery += 	"FH_ZONFIS  = 'JU'  AND " 
	cQuery +=	"D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY "//FH_FIMVIGE DESC, FH_INIVIGE DESC"
	cQuery += "CASE "
	cQuery += "When FH_FIMVIGE = '' THEN '99999999' "
	cQuery += "Else FH_FIMVIGE "
	cQuery += "End DESC, "
	cQuery += "FH_INIVIGE DESC "  

	cQuery := ChangeQuery(cQuery)                    
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 

	Count to nCont
	(cTmp)->(dbGoTop())

	//Valida si existe registro en SFH
	If nCont > 0
		If lExist //Existe en el padr�n
	 		If (dIniVig == STOD((cTmp)->FH_FIMVIGE) + 1) .and. (cTmp)->FH_ALIQ == Val(Iif(cOrigen == "C", TMP->TMP_ALIQP,Iif(cOrigen == "E",nAliqEmpP,TMP->TMP_ALIQR ))) 
	 			SFH->(DBGOTO((cTmp)->R_E_C_N_O_))
				Reclock("SFH",.F.)
					SFH->FH_FIMVIGE := dFimVig
				SFH->(MsUnlock())
				lAct := .T. 
	 		ElseIf !(dIniVig <= STOD((cTmp)->FH_FIMVIGE))
	 			If cOrigen == "C"
					NewReg((cTmp)->FH_AGENTE,(cAlias)->A1_COD,"",(cAlias)->A1_LOJA,(cAlias)->&(cPref+"_NOME"),(cTmp)->FH_TIPO,(cTmp)->FH_PERCIBI,"IBC",TMP->TMP_ALIQP,IIf(!(Val(TMP->TMP_ALIQP) > 0),100,0),"N","S",dIniVig,dFimVig)
				ElseIf cOrigen == "E"
					NewReg((cTmp)->FH_AGENTE,"",(cAlias)->A2_COD,(cAlias)->A2_LOJA,(cAlias)->&(cPref+"_NOME"),(cTmp)->FH_TIPO,"N","IBC",nAliqEmpP,IIf(!(Val(nAliqEmpP) > 0),100,0),"N","S",dIniVig,dFimVig)
				ElseIf cOrigen == "P"
					NewReg((cTmp)->FH_AGENTE,"",(cAlias)->A2_COD,(cAlias)->A2_LOJA,(cAlias)->&(cPref+"_NOME"),(cTmp)->FH_TIPO,(cTmp)->FH_PERCIBI,"IBR",TMP->TMP_ALIQR,IIf(!(Val(TMP->TMP_ALIQR) > 0),100,0),"N","S",dIniVig,dFimVig)
				EndIf
				lAct := .T.	
	 		EndIf
	 	Else //No existe en el padr�n
	 		If dIniVig > STOD((cTmp)->FH_FIMVIGE) .and. !(dIniVig == STOD((cTmp)->FH_INIVIGE))
	 			If cOrigen == "C"
					NewReg((cTmp)->FH_AGENTE,(cAlias)->A1_COD,"",(cAlias)->A1_LOJA,(cAlias)->&(cPref+"_NOME"),(cTmp)->FH_TIPO,(cTmp)->FH_PERCIBI,"IBC","0",100,"N",(cTmp)->FH_APERIB,dIniVig)
				ElseIf cOrigen == "E"
					NewReg((cTmp)->FH_AGENTE,"",(cAlias)->A2_COD,(cAlias)->A2_LOJA,(cAlias)->&(cPref+"_NOME"),(cTmp)->FH_TIPO,"N","IBC","0",100,"N",(cTmp)->FH_APERIB,dIniVig)
				ElseIf cOrigen == "P"
					NewReg((cTmp)->FH_AGENTE,"",(cAlias)->A2_COD,(cAlias)->A2_LOJA,(cAlias)->&(cPref+"_NOME"),(cTmp)->FH_TIPO,(cTmp)->FH_PERCIBI,"IBR","0",100,"N",(cTmp)->FH_APERIB,dIniVig)
				EndIf
				lAct := .T.
	 		EndIf
	 	EndIf
 	Else
		If lExist //Existe en el padr�n, pero no en SFH
			If cOrigen == "C"
				NewReg("N",(cAlias)->A1_COD,"",(cAlias)->A1_LOJA,(cAlias)->&(cPref+"_NOME"),"I","S","IBC",TMP->TMP_ALIQP,IIf(!(Val(TMP->TMP_ALIQP) > 0),100,0),"N","S",dIniVig,dFimVig)
				lAct := .T.
			ElseIf cOrigen == "P"
				NewReg("N","",(cAlias)->A2_COD,(cAlias)->A2_LOJA,(cAlias)->&(cPref+"_NOME"),"I","S","IBR",TMP->TMP_ALIQR,IIf(!(Val(TMP->TMP_ALIQR) > 0),100,0),"N","S",dIniVig,dFimVig)
				lAct := .T.
			EndIf
		EndIf 	
	Endif 

	(cTmp)->(dbCloseArea())
	RestArea(aArea)
	
	
Return

/*��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �NewReg    �Autor  �Ra�l Ortiz           �Data  �11/10/2018  ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Crea un nuevo registro en la SFH      					  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cAgente - Indica si es agente o no                          ���
���          �cCliente  - Si es cliente se informa el c�digo 		      ���
���          �cFornec   - Si es proveedor se informa el c�digo	    	  ���
���          �cLoja - Se informa la loja correspondiente Cliente/Proveedor���
���          �cNome   - Nombre Cliente/Proveedor     					  ���
���          �cTipo   - Tipo de contribuyente       					  ���
���          �cPercibi   - sistema es agente recaudador (S/N)   		  ���
���          �cImposto   - Clave del impuesto (IB2, IBP, IBR, etc.)	      ���
���          �nAliq   - Alicuota                     					  ���
���          �nPercent   - Porcentaje de exencion.    					  ���
���          �cIsento   - Exento (S/N)               					  ���
���          �cAperIb   - Agente de recaudaciones Cliente/Proveedor (S/N) ���
���          �dIniVige   - Fecha de inicio de vigencia					  ���
���          �dFimVige   - Fecha de fin de vigencia 					  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nulo                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Fiscal - Argentina 			                  			  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�������������������������������������������������������������������������� /*/
Static Function NewReg(cAgente,cCliente,cFornec,cLoja,cNome,cTipo,cPercibi,cImposto,nAliq,nPercent,cIsento,cAperIb,dIniVige,dFimVige)
Default cAgente		:= ""
Default cCliente	:= ""
Default cFornec		:= ""
Default cLoja		:= ""
Default cNome		:= ""
Default cTipo		:= ""
Default cPercibi	:= ""
Default cImposto	:= ""
Default nAliq		:= 0
Default nPercent	:= 0
Default cIsento		:= ""
Default cAperIb		:= ""
Default dIniVige	:= CTOD("//")
Default dFimVige	:= CTOD("//")

	Reclock("SFH",.T.)
		SFH->FH_FILIAL	:= xFilial("SFH")
		SFH->FH_AGENTE	:= cAgente
		SFH->FH_CLIENTE	:= cCliente
		SFH->FH_FORNECE	:= cFornec
		SFH->FH_LOJA	:= cLoja
		SFH->FH_NOME	:= cNome
		SFH->FH_TIPO	:= cTipo
		SFH->FH_PERCIBI	:= cPercibi
		SFH->FH_ZONFIS	:= "JU"
		SFH->FH_IMPOSTO	:= cImposto
		SFH->FH_ALIQ	:= Val(nAliq)
		SFH->FH_PERCENT	:= IiF(Val(nAliq)<>0,0,100)
		SFH->FH_ISENTO	:= cIsento
		SFH->FH_APERIB	:= cAperIb
		SFH->FH_INIVIGE	:= dIniVige
		SFH->FH_FIMVIGE	:= dFimVige
	SFH->(MsUnlock())
Return
