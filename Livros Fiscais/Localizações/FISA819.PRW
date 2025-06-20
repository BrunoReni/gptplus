#INCLUDE "Protheus.ch"   
#INCLUDE "TopConn.ch"
#INCLUDE "Fisa819.ch"

#DEFINE _SEPARACSV ","
#DEFINE _SEPARATXT "	"
#DEFINE _BUFFER 16384

/*��������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o    �FISA819   �Autor  �Luis Samaniego              �Data  �04/12/2018���
������������������������������������������������������������������������������Ĵ��
���Descri��o �       RG 11-18 - Regimen Retenciones y Percepciones             ���
���          �                Nomina Sujetos Excluidos.                        ���
������������������������������������������������������������������������������Ĵ��
���Uso       �FISA819                                                          ���
������������������������������������������������������������������������������Ĵ��
���                         ATUAIZACOES SOFRIDAS                               ���
������������������������������������������������������������������������������Ĵ��
���Programador �Data    �  BOPS    �          Motivo da Alteracao              ���
������������������������������������������������������������������������������Ĵ��
���            �        �          �                                           ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
��������������������������������������������������������������������������������*/
Function FISA819()
Local oFld		:= Nil
Local oTipo		:= Nil                                                       			
Local aTipo		:= {}

Private oDlg		:= Nil
Private lAct		:= .F.
Private cMes		:= StrZero(Month(dDataBase), 2)
Private cAno		:= StrZero(Year(dDataBase), 4)
Private cTipo		:= STR0003 //"3- Ambos"
Private aLinea		:= {}    
Private oTmpTable	:= Nil
Private dIniVig		:= CTOD("//")
Private dFimVig		:= CTOD("//")
Private aStrutSFH	:= getStruct("SFH")
	
	aAdd( aTipo, STR0001 ) //"1- Proveedor"
	aAdd( aTipo, STR0002 ) //"2- Cliente"
	aAdd( aTipo, STR0003 ) //"3- Ambos"   

	DEFINE MSDIALOG oDlg TITLE STR0004 FROM 0,0 TO 250,450 OF oDlg PIXEL //"Comercio e Industria Ciudad de C�rdoba"
	
	@ 006,006 TO 050,175 LABEL STR0005 OF oDlg PIXEL //"Parametros"
	@ 020,010 SAY STR0022 SIZE 065,008 PIXEL OF oFld //"Tipo de Contribuyente"
	@ 020,100 COMBOBOX oTipo VAR cTipo ITEMS aTipo SIZE 65,8 PIXEL OF oFld //"1- Proveedor", "2- Cliente", "3- Cliente" 
	
	@ 035,010 SAY STR0021 SIZE 150,008 PIXEL OF oFld //"Periodo de vigencia"
	@ 035,100 MSGET cAno PICTURE "@E 9999" VALID !Empty(cMes) SIZE 020,008 PIXEL OF oFld                                          
	@ 035,125 SAY "/" SIZE  150, 8 PIXEL OF oFld
	@ 035,130 MSGET cMes PICTURE "@E 99" VALID !Empty(cMes) SIZE  015,008 PIXEL OF oFld
	
	@ 060,006 FOLDER oFld OF oDlg PROMPT STR0006 PIXEL SIZE 170,050 //"&Importacion de archivo TXT."

	//+----------------
	//| Campos Folder 2
	//+----------------
	@ 003,005 SAY STR0007 SIZE 175,008 PIXEL OF oFld:aDialogs[1] //"Esta rutina tiene como objetivo importar el Padron RG 11-18: "
	@ 013,005 SAY STR0008 SIZE 175,008 PIXEL OF oFld:aDialogs[1] //"R�gimen Retenciones y Percepciones - N�mina Sujetos Excluidos"
	//+-------------------
	//| Boton de MSDialog
	//+-------------------
	@ 055,185 BUTTON STR0009 SIZE 036,016 PIXEL ACTION ImpArq() //"&Importar"
	@ 075,185 BUTTON STR0010 SIZE 036,016 PIXEL ACTION oDlg:End() //"&Salir"

	ACTIVATE MSDIALOG oDlg CENTER
Return

/*��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ImpArq    �Autor  �Luis Samaniego       �Data  �29/11/2018  ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Procesa archivo.                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nulo													      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �FISA819                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
��������������������������������������������������������������������������?/*/
Static Function ImpArq()
Local cFile		:= ""
Local cTmpPdr	:= GetNextAlias()
Local aStru		:= {}
Local lImp		:= .F.
Local aOrdem	:= {}

Private lExistEmp	:= .F.
Private cTipoArch   := ""

	cTipo   := Subs(cTipo,1,1) //1 - Proveedor, 2 - Cliente y  3 - Ambos

	// Seleciona o arquivo
	cFile := FGetFile()

	If File(cFile) .And. !Empty(cFile)     

		//creamos la tabla temporal	
		AADD(aStru,{ "TMP_CUIT"    , "C",  14, 0})

		aOrdem := {"TMP_CUIT"}

		oTmpTable := FWTemporaryTable():New(cTmpPdr)
		oTmpTable:SetFields(aStru)
		oTmpTable:AddIndex("IN1", aOrdem)
		oTmpTable:Create()
		
		// Se procesa archivo de texto				
		Processa( {|| lImp:= ObtFile(cFile, cTmpPdr)},STR0011,Alltrim(cFile), .T. ) //"Leyendo archivo. Espere..."
		
		If  lImp // Si el archivo fue procesado
			dIniVig := CTOD("01/" + cMes + "/" + cAno )
			dFimVig := CTOD(AllTrim(STR(f_UltDia(dIniVig))) + "/" + cMes + "/" + cAno )
			
			If  cTipo == "1" .Or. cTipo == "3"      //Procesa Proveedores
				Processa( {|| lExistEmp := ProcEmp(cTmpPdr)} , STR0011,STR0016, .T. ) //"Leyendo archivo. Espere...", "Procesando clientes..."
				Processa( {|| ProcRegs(.F., cTmpPdr)}, STR0011,STR0017, .T. ) //"Leyendo archivo. Espere...", "Procesando Proveedores..."
			EndIf
			If  cTipo == "2" .Or. cTipo == "3"      //Procesa Clientes
				Processa( {|| ProcRegs(.T., cTmpPdr)} , STR0011,STR0016, .T. )//"Leyendo archivo. Espere...", "Procesando clientes..."
			EndIf		
		EndIf
		(cTmpPdr)->(dbCloseArea())  

		If lAct
			MsgAlert(STR0018) //"Registros actualizados"
		Else
			MsgAlert(STR0019) //"No hubo modificaciones en los registros."
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

	oDlg01 := MSDialog():New(000,000,100,500,STR0014,,,,,,,,,.T.) //"Seleccionar archivo"

	oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,{||ValExtFile(cRet)},,,,,,.T.,,,,,,,,,,"cRet")
	oBtn01 := TBtnBmp2():New(017,458,025,028,"folder6","folder6",,,{|| FGetDir(oGet01)},oDlg01,STR0014,,.T.) //"Seleccionar archivo"

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

	cDir := cGetFile(,STR0014,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE) //"Seleccionar archivo"
	If !Empty(cDir)
		oTGet:cText := cDir
		oTGet:Refresh()
	Endif
	oTGet:SetFocus()

Return Nil

/*��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ValExtFile�Autor  �Luis Samaniego       �Data  �10/10/2018  ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Valida extension del archivo seleccionado.                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cNomeFile - Nombre del archivo a validar.                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Logico: Si extension es correcta o no.                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �FISA819                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�������������������������������������������������������������������������� /*/
Static Function ValExtFile(cNomeFile)
Local lRet := .T.
Local cExt	:= Substr(cNomeFile,len(cNomeFile)-2)

	If Empty(UPPER(cNomeFile)) .or. !(cExt $ "csv|CSV|txt|TXT")
		MsgAlert(STR0020) //"Formato de archivo no valido."
		lRet := .F.
	Else
		IIf(cExt $ "csv|CSV", cTipoArch := "CSV", cTipoArch := "TXT")
	EndIf
Return lRet

/*��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ObtFile   �Autor  �Luis Samaniego       �Data  �10/10/2018  ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Lee archivo (.txt) y coloca su contenido en tabla temporal  ���
���          �TMP.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros�	cFile - Archivo a importar.		                          ���
���          �	cTmpPdr - Tabla temporal.                    		      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �	lRet - L�gico - Indica si se import� el archivo		      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �FISA819                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
��������������������������������������������������������������������������?/*/
Static Function ObtFile(cFile, cTmpPdr)
Local nFor		:= 0
Local nHandle	:= 0
Local nX		:= 0
Local lRet		:= .F.
Local cLinPadron:= "" 
Local oFile     := Nil

	nHandle := FT_FUse(cFile)
	If  nHandle = -1
		MsgAlert(STR0012 + cFile + STR0013)	//"El archivo", "no se pudo abrir"
		Return .F.
	EndIf
	
	FT_FGoTop()//Se posiciona en la primera l�nea
	nFor := FT_FLastRec() //Obtiene el numero de lineas	
	FT_FUSE()// Fecha o Arquivo
	
	oFile := FWFileReader():New(cFile)
	// Se hay error al abrir el archivo
	If !oFile:Open()
		MsgAlert(STR0012 + cFile + STR0013)	//"El archivo", "no se pudo abrir"
		Return .F.
	EndIf
	
	dbSelectArea(cTmpPdr)
	ProcRegua(nFor)
	oFile:setBufferSize(_BUFFER)
	While (!oFile:Eof())
		nX++		
		
		aLinea  := {}
		IncProc(STR0015 + str(nX)) //"Procesando registros..."
		cLinPadron := Alltrim(oFile:GetLine())		
		aLinea := Separa(cLinPadron,IIf(cTipoArch == "CSV", _SEPARACSV, _SEPARATXT))

		If !Empty(aLinea) 
			(cTmpPdr)->( DBAppend( .F. ) )
				(cTmpPdr)->TMP_CUIT		:= Alltrim(Replace(aLinea[1], "-", ""))
			(cTmpPdr)->( DBCommit() )
			lRet := .T.							
		Endif
		
	EndDo
	
	oFile:Close()
	
Return lRet

/*/
����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ProcEmp   �Autor  �Ra�l Ortiz           �Data  �10/10/2018  ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Procesa para empresa.                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cTmpPdr - Tabla temporal del padron                         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lRet - Logico - Si la empresa se encuentra en el padr�n    ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Fiscal - Provincia de Jujuy			                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
Static Function ProcEmp(cTmpPdr)
Local lRet	:= .F.

	dbSelectArea(cTmpPdr)
	dbSetOrder(1)
	(cTmpPdr)->(MsSeek(AllTrim(SM0->M0_CGC))) //Se busca registro en tab temporal(TMP) por CIUT)

	If Found() .And. !Empty(SM0->M0_CGC)//Si es encontrado el CUIT 			
		lRet := .T.
	EndIf

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
���          �cTmpPdr = Tabla temporal del padron                         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nulo                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Fiscal - Provincia de Jujuy                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
��������������������������������������������������������������������������/*/
Static Function ProcRegs(lCli, cTmpPdr)
Local aArea		:= GetArea()
Local cQuery	:= ""	
Local cSA		:= Iif(lCli, InitSqlName("SA1"), InitSqlName("SA2"))	 
Local cMsg		:= Iif(lCli, STR0016, STR0017) //"Procesando clientes...", "Procesando Proveedores..."
Local cPref		:= Iif(lCli, "A1", "A2")
Local cTmpSA 	    := GetNextAlias()                               
Local aTmp		:= {}
Local nReg		:= 0
Local nI		:= 0
Local cClave	:= ""
Local nCont		:= 0 

	// Seleccionar Clientes/Proveedores cuyo CUIT no este vacio y sean registros que no 
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
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpSA,.T.,.T.) 

	Count to nCont
	(cTmpSA)->(dbGoTop())
	ProcRegua(nCont) 
	While (cTmpSA)->(!eof())      //Clientes/Proveedores
		nI++
		IncProc(cMsg + Str(nI))

		cClave := Alltrim((cTmpSA)->&(cPref+"_CGC"))

		//  Se realiza la busqueda por CUIT en la tabla Temporal 
		If ((cTmpPdr)->(MsSeek(cClave)))
			UPDSFH(cTmpSA, lCli, IIf(lCli, "C", "P"), .T.)
		Else
			UPDSFH(cTmpSA, lCli, IIf(lCli, "C", "P"), .F.)
		Endif

		IF !lCli
			UPDSFH(cTmpSA,lCli,"E",lExistEmp)
		EndIF

		(cTmpSA)->(dbSkip())	    
	EndDo

	(cTmpSA)->(dbCloseArea()) 

	RestArea(aArea)
	
Return Nil

/*��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �UPDSFH    �Autor  �Ra�l Ortiz           �Data  �11/10/2018  ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Busca y actualiza registros en SFH 						  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cTmpSA - Tabla temp con los registros obtenidos de SA1/SA2  ���
���          �lCli   - Si .T. est?procesando Clientes					  ���
���          �			Si .F. est?procesandoProveedores				  ���
���          �cOrigen - 'E'=Empresa, 'C'=Cliente, 'P'=Proveedor           ���
���          |lExiste- Si .T. se encuentra CUIT de Cliente/Prov en 	      ���
���          �			archivo ASCII 									  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nulo                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Fiscal - Argentina 			                  			  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�������������������������������������������������������������������������� /*/
Static Function UPDSFH(cTmpSA,lCli,cOrigen,lExist)
Local aArea		:= GetArea()
Local cQuery	:= ""	
Local cSFH		:= InitSqlName("SFH")
Local cTmpSFH		:= GetNextAlias()                               
Local cPref		:= IIf(lCli, "A1", "A2")
Local aTmp		:= {}
Local nReg		:= 0
Local lRegSFH   := .F.

	//Seleccionar cliente o proveedor de SFH  
	cQuery := "SELECT * "
	cQuery += "FROM " + cSFH + " SFH "
	cQuery += 	"WHERE " 
	cQuery += 	"FH_FILIAL ='" + xFilial("SFH") + "' AND "
	If  lCli	
		cQuery +=  	"FH_CLIENTE='" + (cTmpSA)->A1_COD	  	+ "' AND "
		cQuery += 	"FH_LOJA   ='" + (cTmpSA)->A1_LOJA   	+ "' AND "
	Else      
		cQuery +=  	"FH_FORNECE='" + (cTmpSA)->A2_COD		+ "' AND "
		cQuery += 	"FH_LOJA   ='" + (cTmpSA)->A2_LOJA   	+ "' AND "
	EndIF
	If cOrigen == "P"
		cQuery +=	"FH_IMPOSTO = 'MCO' AND "
	Else
		cQuery +=	"FH_IMPOSTO = 'CEI' AND "
	EndIf
	cQuery += 	"FH_ZONFIS  = 'CO'  AND " 
	cQuery +=	"D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY "//FH_FIMVIGE DESC, FH_INIVIGE DESC"
	cQuery += "CASE "
	cQuery += "When FH_FIMVIGE =  ' ' THEN '99999999' "
	cQuery += "Else FH_FIMVIGE "
	cQuery += "End DESC, "
	cQuery += "FH_INIVIGE DESC "  

	cQuery := ChangeQuery(cQuery)                    
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpSFH,.T.,.T.) 

	Count to nCont
	(cTmpSFH)->(dbGoTop())
	
	dbSelectArea("SFH")
	//Valida si existe registro en SFH
	If nCont > 0
		If lExist //Existe en padron
			If Empty((cTmpSFH)->FH_INIVIGE) .And. Empty((cTmpSFH)->FH_FIMVIGE) //Situacion 1
				If (cTmpSFH)->FH_ISENTO != "S"
					//Actualiza Registro
					SFH->(dbGoTo((cTmpSFH)->R_E_C_N_O_))
					Reclock("SFH",.F.)
						SFH->FH_FIMVIGE := (dIniVig - 1)
					MsUnlock()
					
					If !lRegSFH
						lAct := .T.
						lRegSFH := NewReg(cTmpSFH, lExist, .T.)//Nuevo Registro
					EndIf
				EndIf
			ElseIf Empty((cTmpSFH)->FH_INIVIGE) .And. !Empty((cTmpSFH)->FH_FIMVIGE) //Situacion 2
				If (cTmpSFH)->FH_ISENTO == "S"
					//Actualiza Registro
					SFH->(dbGoTo((cTmpSFH)->R_E_C_N_O_))
					Reclock("SFH",.F.)
						SFH->FH_FIMVIGE := dFimVig
					MsUnlock()
					
					lAct := .T.
				Else
					//Actualiza Registro
					SFH->(dbGoTo((cTmpSFH)->R_E_C_N_O_))
					If SFH->FH_FIMVIGE >= dIniVig
						Reclock("SFH",.F.)
							SFH->FH_FIMVIGE := (dIniVig - 1)
						MsUnlock()
					EndIf
					If !lRegSFH
						lAct := .T.
						lRegSFH := NewReg(cTmpSFH, lExist, .T.)//Nuevo Registro
					EndIf
				EndIf
			ElseIf !Empty((cTmpSFH)->FH_INIVIGE) .And. Empty((cTmpSFH)->FH_FIMVIGE) //Situacion 3
				If (cTmpSFH)->FH_ISENTO != "S"
					//Actualiza Registro
					SFH->(dbGoTo((cTmpSFH)->R_E_C_N_O_))
					Reclock("SFH",.F.)
						SFH->FH_FIMVIGE := (dIniVig - 1)
					MsUnlock()
					
					If !lRegSFH
						lAct := .T.
						lRegSFH := NewReg(cTmpSFH, lExist, .T.)//Nuevo Registro
					EndIf
				EndIf
			ElseIf !Empty((cTmpSFH)->FH_INIVIGE) .And. !Empty((cTmpSFH)->FH_FIMVIGE) //Situacion 4
				If (cTmpSFH)->FH_ISENTO == "S"
					//Actualiza Registro
					SFH->(dbGoTo((cTmpSFH)->R_E_C_N_O_))
					Reclock("SFH",.F.)
						SFH->FH_FIMVIGE := dFimVig
					MsUnlock()
					
					lAct := .T.
				Else
					//Actualiza Registro
					SFH->(dbGoTo((cTmpSFH)->R_E_C_N_O_))
					If SFH->FH_FIMVIGE >= dIniVig
						Reclock("SFH",.F.)
							SFH->FH_FIMVIGE := (dIniVig - 1)	
						MsUnlock()
					EndIf
					If !lRegSFH
						lAct := .T.
						lRegSFH := NewReg(cTmpSFH, lExist, .T.)//Nuevo Registro
					EndIf
				EndIf
			EndIf
		Else //No existe en padron
			If Empty((cTmpSFH)->FH_INIVIGE) .And. Empty((cTmpSFH)->FH_FIMVIGE) //Situacion 1
				If (cTmpSFH)->FH_ISENTO == "S"
					//Actualiza Registro
					SFH->(dbGoTo((cTmpSFH)->R_E_C_N_O_))
					Reclock("SFH",.F.)
						SFH->FH_FIMVIGE := (dIniVig - 1)
					MsUnlock()
					
					If !lRegSFH
						lAct := .T.
						lRegSFH := NewReg(cTmpSFH, lExist, .T.)//Nuevo Registro
					EndIf
				EndIf
			ElseIf Empty((cTmpSFH)->FH_INIVIGE) .And. !Empty((cTmpSFH)->FH_FIMVIGE) //Situacion 2
				If (cTmpSFH)->FH_ISENTO == "S"
					//Actualiza Registro
					SFH->(dbGoTo((cTmpSFH)->R_E_C_N_O_))
					If SFH->FH_FIMVIGE >= dIniVig
						Reclock("SFH",.F.)
							SFH->FH_FIMVIGE := (dIniVig - 1)
						MsUnlock()
					EndIf
					If !lRegSFH
						lAct := .T.
						lRegSFH := NewReg(cTmpSFH, lExist, .T.)//Nuevo Registro
					EndIf
				EndIf
			ElseIf !Empty((cTmpSFH)->FH_INIVIGE) .And. Empty((cTmpSFH)->FH_FIMVIGE) //Situacion 3
				If (cTmpSFH)->FH_ISENTO == "S"
					//Actualiza Registro
					SFH->(dbGoTo((cTmpSFH)->R_E_C_N_O_))
					Reclock("SFH",.F.)
						SFH->FH_FIMVIGE := (dIniVig - 1)
					MsUnlock()
					
					If !lRegSFH
						lAct := .T.
						lRegSFH := NewReg(cTmpSFH, lExist, .T.)//Nuevo Registro
					EndIf
				EndIf
			ElseIf !Empty((cTmpSFH)->FH_INIVIGE) .And. !Empty((cTmpSFH)->FH_FIMVIGE) //Situacion 4
				If (cTmpSFH)->FH_ISENTO == "S"
					//Actualiza Registro
					SFH->(dbGoTo((cTmpSFH)->R_E_C_N_O_))
					If SFH->FH_FIMVIGE >= dIniVig
						Reclock("SFH",.F.)
							SFH->FH_FIMVIGE := (dIniVig - 1)
						MsUnlock()
					EndIf
					If !lRegSFH
						lAct := .T.
						lRegSFH := NewReg(cTmpSFH, lExist, .T.)//Nuevo Registro
					EndIf
				EndIf
			EndIf
		EndIf
 	Else
		If cOrigen $ ("C|P") .And. lExist
			Reclock("SFH",.T.)
				SFH->FH_FILIAL := xFilial("SFH")
				SFH->FH_AGENTE := "N"
				If cOrigen == "C"
					SFH->FH_CLIENTE := (cTmpSA)->A1_COD
					SFH->FH_LOJA    := (cTmpSA)->A1_LOJA
					SFH->FH_NOME    := (cTmpSA)->A1_NOME
					SFH->FH_IMPOSTO := "CEI"
					SFH->FH_PERCIBI := "S"
				Else
					SFH->FH_FORNECE := (cTmpSA)->A2_COD
					SFH->FH_LOJA    := (cTmpSA)->A2_LOJA
					SFH->FH_NOME    := (cTmpSA)->A2_NOME
					SFH->FH_IMPOSTO := "MCO"
					SFH->FH_PERCIBI := "N"
				EndIf
				SFH->FH_ALIQ    := 0
				SFH->FH_PERCIBI := IIf(cOrigen == "C", "S", "N")
				SFH->FH_ISENTO  := "S"
				SFH->FH_APERIB  := "N"
				SFH->FH_ZONFIS := "CO"
				SFH->FH_TIPO    := "I"
				SFH->FH_PERCENT := 0
				SFH->FH_SITUACA := "1"
				SFH->FH_INIVIGE := dIniVig
				SFH->FH_FIMVIGE := CTOD("//")
			MsUnlock()
			lAct := .T.
		EndIf
	Endif 

	(cTmpSFH)->(dbCloseArea())
	RestArea(aArea)
	
Return Nil

/*��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �NewReg    �Autor  �Luis Samaniego       �Data  �04/12/2018  ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Crea un nuevo registro en la SFH      					  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cTmpSFH - Tabla temporal SFH                                ���
���          �lExist - CUIT existe en el padron            		          ���
���          �lExistSFH - Hay registro en la tabla SFH    	    	      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nulo                                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Fiscal - Argentina 			                  			  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�������������������������������������������������������������������������� /*/
Static Function NewReg(cTmpSFH, lExist, lExistSFH)
Local nCpo := 0

Default cTmpSFH  := ""
Default lExist     := .F.
Default lExistSFH  := .F.

	Reclock("SFH",.T.)
		For nCpo := 1 To Len(aStrutSFH)
			If ColumnPos(aStrutSFH[nCpo]) > 0
				FieldPut(ColumnPos(aStrutSFH[nCpo]), (cTmpSFH)->&(aStrutSFH[nCpo]))
			EndIf
		Next nCpo
		If lExist .And. lExistSFH
			SFH->FH_ISENTO := "S"
		ElseIf !lExist .And. lExistSFH
			SFH->FH_ISENTO := "N"
		EndIf
		SFH->FH_INIVIGE  := dIniVig
		SFH->FH_FIMVIGE  := CTOD("//")
	SFH->(MsUnlock())
	
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao     � getStruct � Autor � Laura Medina        � Data � 19/11/13 ���
�������������������������������������������������������������������������Ĵ��
���Descripci�n� Obtiene la estructura de la SFH para generar un registro  ��� 
���           � nuevo.                                                    ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe    � getStruct()                                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/  
Static function getStruct(cTabla)
Local aStru := {}
Local aArea	:= getArea()

	dbSelectArea("SX3")
	SX3->(dbSetOrder(1))
	SX3->(MsSeek(cTabla))
	While !Eof() .and. SX3->X3_ARQUIVO == cTabla
		aadd(aStru,SX3->X3_campo)
		dbSkip()
	EndDo
	RestArea(aArea)
Return aStru