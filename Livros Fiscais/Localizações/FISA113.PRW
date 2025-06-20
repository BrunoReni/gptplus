#Include "Protheus.ch"
#Include "FISA113.ch"
#Include 'topconn.ch'

#DEFINE _SEPARADOR "	"
#DEFINE _BUFFER 16384

Static _oFISA113
//Static _oFISA113R

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa   � FISA114  � Autor � Raul Ortiz          � Fecha � 19/01/16 ���
�������������������������������������������������������������������������Ĵ��
���Descripcion� Rutina para Padron de Ganancias - Entidades Exentas       ���   
�������������������������������������������������������������������������Ĵ��
���Uso        � FISA114                                                   ���
�������������������������������������������������������������������������Ĵ��
���                        ACTUALIZACIONES                                ���
�������������������������������������������������������������������������Ĵ��
��� Programador � Fecha  � Comentario                                     ���
�������������������������������������������������������������������������Ĵ��
���             �        �                                                ���
���             �        �                                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FISA113()
Local oFld :=		Nil
Local oPadron :=	Nil
Local oTipo :=	Nil
Private oGet := 	Nil
Private oDlg :=	Nil
Private lAct :=	Nil
Private aLinea :=	Nil

	DEFINE MSDIALOG oDlg TITLE STR0001 FROM 0,0 TO 120,370 OF oDlg PIXEL
	@ 005,006 FOLDER oFld OF oDlg PROMPT STR0002 PIXEL SIZE 130,045
	
	@ 003,005 SAY STR0003 SIZE 140,008 PIXEL OF oFld:aDialogs[1] //
	@ 013,005 SAY STR0004 SIZE 140,008 PIXEL OF oFld:aDialogs[1] //
	@ 024,005 SAY STR0005 SIZE 140,008 PIXEL OF oFld:aDialogs[1] //
	
	@ 005,145 BUTTON STR0006 SIZE 036,016 PIXEL ACTION ImpArq() //"&Importar"
	@ 025,145 BUTTON STR0007 SIZE 036,016 PIXEL ACTION oDlg:End() //"&Sair"
	
	ACTIVATE MSDIALOG oDlg CENTER


Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ImpArq   � Autor � Raul Ortiz          � Data � 19/01/2016 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Procesa archivo.                                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Fiscal - Entidades Exentas                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ImpArq()

Local nPos 	:=	Nil
Local cLine 	:= 	""
Local cFile 	:= 	""
Local cTmp 	:= 	"TMP"
Local cArq 	:= 	""
Local aStru 	:= 	{}
Local lImp		:= .F.
Local lAct		:= .F.


	If SA2->(ColumnPos("A2_DTICALG")) > 0 .and. SA2->(ColumnPos("A2_DTFCALG")) > 0 .and. SA2->(ColumnPos("A2_PORGAN")) > 0
		cFile := FGetFile()
		
		If File(cFile) .And. !Empty(cFile)
			
			AADD(aStru,{"TMP_CUIT"	,"C",14,0})
			AADD(aStru,{"TMP_DESDE"	,"D", 8,0})
			AADD(aStru,{"TMP_HASTA"	,"D", 8,0})
			
			If _oFISA113 <> Nil
				_oFISA113:Delete()
				_oFISA113 := Nil
			Endif

			_oFISA113 := FWTemporaryTable():New( cTmp )  
			_oFISA113:SetFields(aStru) 
			_oFISA113:AddIndex("1", {"TMP_CUIT"})
			_oFISA113:Create() 	

			Processa( {|| lImp:= ObtFile(cFile,cTmp)},STR0009,AllTrim(cFile),.T.)

			If lImp
				Processa({|| lAct := ProcRegs()},STR0009,STR0013,.T.)
			EndIf
			TMP->(dbCloseArea())
			
		EndIf
	Else
		MsgAlert(STR0015 + STR0016)
	EndIF
	 
	If lAct
		MsgAlert(STR0017)
	Else
		MsgAlert(STR0018)
	EndIf
	 
Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ProcRegs � Autor � Raul Ortiz          � Data � 20/01/2016 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Obtiene los registros de proveedores y actualiza registros  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nulo                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Fiscal - Entidades Exentas                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ProcRegs()
Local aArea 	:= getArea()
Local cQuery 	:= ""
Local cSA		:= InitSqlName("SA2")
Local cTmp 		:= GetNextAlias() //Criatrab(nil,.F.)
Local aTmp		:= {}
Local nReg		:= 0
Local nI		:= 0
Local cClave	:= ""
Local nCont	:= 0
Local lRet		:= .F.

	cQuery := " SELECT A2_COD, "
	cQuery += " A2_LOJA, "
	cQuery += " A2_CGC, "
	cQuery += " A2_NOME, "
	cQuery += " A2_FILIAL, "
	cQuery += " R_E_C_N_O_ "
	cQuery += " FROM " + cSA + " SA2"
	cQuery += " WHERE "
	cQuery += " A2_CGC <> '' AND "
	cQuery += " D_E_L_E_T_ = '' "
	cQuery += " ORDER BY A2_CGC "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 
	
	Count to nCont
	(cTmp)->(dbGoTop())
	
	ProcRegua(nCont)
	
	dbSelectArea("TMP")
	dbSetOrder(1)
	dbSelectArea("SA2")
	
	While (cTmp)->(!eof())
	
		nI++
	   	IncProc(STR0014 + str(nI))
	   	
	   	cClave := (cTmp)->A2_CGC
	   	
	   	If (TMP->(dbSeek(cClave)))
	   		ActSA2((cTmp)->R_E_C_N_O_, TMP->TMP_DESDE, TMP->TMP_HASTA)
	   		lRet := .T.
	   	EndIf
	   	
	   	(cTmp)->(dbSkip())	
	
	EndDo
	
	(cTmp)->(dbCloseArea())
	SA2->(dbCloseArea()) 
      
	RestArea(aArea) 
Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ActSA2   � Autor � Raul Ortiz          � Data � 20/01/2016 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Actualiza los registros de proveedores (SA2)                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nulo                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Fiscal - Entidades Exentas                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ActSA2(nRecno,dFechaIni,dFechaFin)

	SA2->(DBGOTO(nRecno))
	Reclock("SA2",.F.)
		SA2->A2_DTICALG 	:= dFechaIni
		SA2->A2_DTFCALG 	:= dFechaFin
		SA2->A2_PORGAN	:= 0
	SA2->(MsUnlock()) 

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ObtFile  � Autor � Raul Ortiz          � Data � 19/01/2016 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Lee archivo (.txt) y coloca su contenido en tabla temporal ���
���          � TMP.                                                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���h?
�������������������������������������������������������������������������Ĵ��
���Uso       � Fiscal - Ganancias - Entidades Exentas                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ObtFile(cFile,cAlias)
Local nFor			:= 0
Local nHandle		:= 0
Local nX 			:= 1
Local lRet			:= .F.
Local aRegTxt		:= {}
Local oFile

	dbSelectArea(cAlias)
	(cAlias)->(dbGoTop())
	
	nHandle := FT_FUse(cFile)

		FT_FGoTop()
		
		nFor := FT_FLastRec()
		
		ProcRegua(nFor)

		oFile := ZFWReadTXT():New(cFile,,)
		// Se hay error al abrir el archivo
		If !oFile:Open()
			MsgAlert(STR0010 + cFile + STR0011)	
			lRet := .F.
		else
			While oFile:ReadArray(@aRegTxt,_SEPARADOR) 
				nX++
				IncProc(STR0013 + str(nX))
				IF substring(aRegTxt[1],1,1) $ "1,2,3,4,5,6,7,8,9,0"
					If aRegTxt[3] == "CE"
						Reclock(cAlias,.T.)
							(cAlias)->TMP_CUIT 		:= aRegTxt[1]
							(cAlias)->TMP_DESDE 	:= CTOD(aRegTxt[10])
							(cAlias)->TMP_HASTA 	:= CTOD(aRegTxt[11])
						(cAlias)->(MsUnlock()) 
						lRet := .T.
					EndIf
				EndIF
			EndDo
		
		EndIf
		oFile:Close()

Return lRet



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � FGetFile � Autor � Ivan Haponczuk      � Data � 09.06.2011 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Tela de sele��o do arquivo txt a ser importado.            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � cRet - Diretori e arquivo selecionado.                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Fiscal - Buenos Aires Argentina - MSSQL                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FGetFile()

	Local cRet := Space(50)
	
	oDlg01 := MSDialog():New(000,000,100,500,STR0008,,,,,,,,,.T.)//"Selecionar arquivo"
	
		oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,{||ValExtFile(cRet)},,,,,,.T.,,,,,,,,,,"cRet")
		oBtn01 := TBtnBmp2():New(017,458,025,028,"folder6","folder6",,,{|| FGetDir(oGet01)},oDlg01,STR0008,,.T.)//"Selecionar arquivo"
		
		oBtn02 := SButton():New(035,185,1,{|| oDlg01:End() }         ,oDlg01,.T.,,)
		oBtn03 := SButton():New(035,215,2,{|| cRet:="",oDlg01:End() },oDlg01,.T.,,)
	
	oDlg01:Activate(,,,.T.,,,)

Return cRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � FGetDir  � Autor � Ivan Haponczuk      � Data � 09.06.2011 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Tela para procurar e selecionar o arquivo nos diretorios   ���
���          � locais/servidor/unidades mapeadas.                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros� oPar1 - Objeto TGet que ira receber o local e o arquivo    ���
���          �         selecionado.                                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nulo                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Fiscal - Buenos Aires Argentina - MSSQL                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FGetDir(oTGet)

	Local cDir := ""
	
	cDir := cGetFile(,STR0008,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)//"Selecionar arquivo"
	If !Empty(cDir)
		oTGet:cText := cDir
		oTGet:Refresh()
	Endif
	oTGet:SetFocus()

Return Nil


Static Function ValExtFile(cNomeFile)
	Local lRet := .T.
	Local cExt	:= Substr(cNomeFile,len(cNomeFile)-2)//Substr(cNomeFile,at(".",cNomeFile)+1)
	
	If Empty(UPPER(cNomeFile)) .or. !(cExt $"txt|TXT")
		MsgAlert(STR0012)
		lRet := .F.
	End If

Return lRet
