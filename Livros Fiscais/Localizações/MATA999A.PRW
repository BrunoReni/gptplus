#INCLUDE "MATA999A.ch"
#INCLUDE "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA999A  � Autor � AP6 IDE            �Fecha �  12-09-03   ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo generado por el AP6 IDE.                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function MATA999A(xAutoCab,xAutoItens,nOpc)

//���������������������������������������������������������������������Ŀ
//� Declaracion de Variables                                            �
//�����������������������������������������������������������������������
Local cPerg      := "MTA999"
Local nSaveOrder := 0
Local nX

Private cCadastro := STR0001 //"Archivo de Ingresos Brutos"
Private cDelFunc  := ".T."   //Validaci�n para el borrado. Puede utilizarse ExecBlock
Private cString   := "SFH"
Private cCondicao := ""
Private aIndexADC := {}
Private bFiltraBrw:= {|| FilBrowse("SFH",@aIndexADC,@cCondicao) }

//��������������������������������������������������������������Ŀ
//� Definicao de variaveis utilizadas na rotina automatica       �
//����������������������������������������������������������������
Private Inclui     := .F.
Private Altera     := .F.
Private l999Auto   := ( xAutoCab <> NIL )
PRIVATE aAutoCab   := {}
PRIVATE aAutoItens := {}

//���������������������������������������������������������������������Ŀ
//� Monta un aRotina proprio                                            �
//�����������������������������������������������������������������������
Private aRotina := MenuDef()

Default nOpc := 3

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
If (Type("l999Auto") <> "U" .And. l999Auto )
	Inclui := If (nOpc == 3,.T.,.F.)
	Altera := If (nOpc == 4,.T.,.F.)
	For nX := 1 To Len(xAutoItens)
		AADD(aAutoItens,SFH->(MSArrayXDB(xAutoItens[nX],,nOpc,.T.)))
	Next nX
	aAutoCab := SFH->(MSArrayXDB(xAutoCab,,nOpc))

	MBrowseAuto(nOpc,Aclone(aAutoCab),"SFH")
Else
	//Determina se eh cadastro de cliente ou fornecedor...	Pergunte(cPerg,.T.)    
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
	
	dbSelectArea(cString)
	dbSetOrder(Iif(MV_PAR01 == 1,1,3))

	//����������������������������������������������������������������������Ŀ
	//� Processar filtro na MarkBrowse                                       �
	//������������������������������������������������������������������������
	cCondicao := "FH_FILIAL == '"+xFilial('SFH')+"' .And. !Empty("+Iif(MV_PAR01 == 1,"FH_CLIENTE","FH_FORNECE")+")" 
	Eval(bFiltraBrw)
	mBrowse(6,1,22,75,cString)

	//����������������������������������������������������������������������Ŀ
	//� Limpa Filtro e reabre indices com RetIndex                           �
	//������������������������������������������������������������������������
	EndFilBrw("SFH",aIndexADC)        
	dbSetOrder(Iif(MV_PAR01 == 1,1,3))
EndIf

Return                                               

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �999ACadSFH� Autor � Julio Cesar           � Data � 16.09.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Chama a rotina de cadastro do arquivo SFH. Essa funcao foi  ��� 
���          �criada para compatibilizar a chamada dessa rotina atraves   ��� 
���          �de outras funcoes.                                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �A999ACadSFH(cAlias,nReg,nOpc)                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA999A()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A999ACadSFH(cAlias,nReg,nOpc)

A999ACadGen(cAlias,nReg,nOpc)

Return
      
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �999ACadGen� Autor � Julio Cesar           � Data � 16.09.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Conforme o parametro nOpc realiza a inclusao, alteracao ou  ��� 
���          �delecao no arquivo SFH.                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �A999ACadSFH(cAlias,nReg,nOpc)                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA999A()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function A999ACadGen(cAlias,nReg,nOpc,cCodCliFor,cCodLoja,cNomeCliFor,;
                     lCliente,cRotina,xAutoCab,xAutoItens,lRetIB)

Local cChave     := ""
Local cCpos      := "FH_FILIAL|FH_FORNECE|FH_CLIENTE|FH_LOJA|FH_ITEM"
Local nOpcA      := 0
Local nI         := 0
Local nChave     := 0 
Local nY
Local aSizeAut   := MsAdvSize(,.F.,400)
Local aObjects   := {}
Local aInfo      := {}
Local aPosGet    := {}
Local aPosObj    := {}
Local aAreaSX3   := {}
Local aAreaAtu   := GetArea()
Local aAreaSFH   := {}
Local aCpos      := {}
Local aRecNoSFH  := {}
Local aLinha     := {}
Local lDelLin    := .T.
Local oDlg     
Local oFont

Default lCliente := (MV_PAR01 == 1)
Default lRetIB   := .T.

Private oGetDados
Private lCliFor  := lCliente
Private nUsado   := 0
Private aHeader  := {}
Private aCols    := {}
Private aCposCab := {{"FH_CLIENTE","",Nil,Nil},;
                      {"FH_FORNECE","",Nil,Nil},;
				 	  {"FH_LOJA","",Nil,Nil},;
				 	  {"FH_NOME","",Nil,Nil}}

//Caso o fornecedor nao retenha IB sai da rotina...
If !lRetIB
	Return
EndIf

nChave := Iif(lCliFor,3,1)

If Type("bFiltraBrw") <> "U"
	Set Filter To
	dbSelectArea("SFH")
	dbSetOrder(nChave)
EndIf

If cRotina <> Nil
	dbSelectArea("SFH")
	aAreaSFH := GetArea()
	dbSetOrder(nChave)	
	If dbSeek(xFilial("SFH")+cCodCliFor+cCodLoja)
		nReg := Recno()
		nOpc := 4
	Else
		nOpc := 3
	EndIf
Else
	aAreaSFH := SFH->(GetArea())
EndIf

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas na rotina automatica                    �
//����������������������������������������������������������������
Inclui := (nOpc == 3)
Altera := (nOpc <> 3)
lDelLin:= (nOpc == 3 .Or. nOpc == 4)

//��������������������������������������������������������������Ŀ
//� Montagem do aHeader                                          �
//����������������������������������������������������������������          
dbSelectArea("SX3") 
aAreaSX3 := GetArea()
dbSetOrder(1)
dbSeek("SFH")
While !Eof() .And. (SX3->X3_ARQUIVO == "SFH")
	IF X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL 
		If (nPos := aScan(aCposCab,{|x| Trim(x[1])==Trim(X3_CAMPO)})) > 0 
			aCposCab[nPos][2] := TRIM(X3Titulo())  
			aCposCab[nPos][3] := CriaVar(X3_CAMPO) 
		Else
			nUsado++
			AADD(aHeader,{ TRIM(X3Titulo()),;
				 X3_CAMPO,;
				 X3_PICTURE,;
				 X3_TAMANHO,;
				 X3_DECIMAL,;
				 X3_VALID,;
				 X3_USADO,;
				 X3_TIPO,;
				 X3_ARQUIVO,;
				 X3_CONTEXT,;
				 X3Obrigat(X3_CAMPO)} )
					
			//Determina os campos que poderao ser editados...
			If (nOpc <> 3) .And. !(Trim(X3_CAMPO)$cCpos)
				AAdd(aCpos,X3_CAMPO)
			ElseIf nOpc == 3 .And. !(Trim(X3_CAMPO)$"FH_ITEM")
				AAdd(aCpos,X3_CAMPO)
			EndIf
		EndIf
	EndIf
	dbSkip()
End
RestArea(aAreaSX3)         
dbSelectArea("SFH")
	
DEFINE FONT oFnt  NAME "Arial" SIZE 09,11 BOLD

If nOpc <> 3 
	If nReg <> RecNo()
		MsGoTo(nReg)
	EndIf
		
	If lCliFor
		aCposCab[aScan(aCposCab,{|x| Trim(x[1])=="FH_CLIENTE"})][03] := FH_CLIENTE
		cCodCliFor := FH_CLIENTE
		cChave     := "FH_FILIAL+FH_CLIENTE+FH_LOJA"
	Else
		aCposCab[aScan(aCposCab,{|x| Trim(x[1])=="FH_FORNECE"})][03] := FH_FORNECE
		cCodCliFor := FH_FORNECE
		cChave     := "FH_FILIAL+FH_FORNECE+FH_LOJA"
	EndIf                                           
	aCposCab[aScan(aCposCab,{|x| Trim(x[1])=="FH_LOJA"})][03] := FH_LOJA
	cCodLoja := FH_LOJA
	aCposCab[aScan(aCposCab,{|x| Trim(x[1])=="FH_NOME"})][03] := FH_NOME
Else
	If cCodCliFor <> Nil
		If lCliFor
			aCposCab[aScan(aCposCab,{|x| Trim(x[1])=="FH_CLIENTE"})][03] := cCodCliFor
		Else
			aCposCab[aScan(aCposCab,{|x| Trim(x[1])=="FH_FORNECE"})][03] := cCodCliFor
		EndIf
		aCposCab[aScan(aCposCab,{|x| Trim(x[1])=="FH_LOJA"})][03] := cCodLoja 
		aCposCab[aScan(aCposCab,{|x| Trim(x[1])=="FH_NOME"})][03] := cNomeCliFor
	EndIf
EndIf
		
//��������������������������������������������������������������Ŀ
//� Faz a montagem de uma linha em branco no aCols.              �
//����������������������������������������������������������������
If nOpc == 3
	AADD(aCols,Array(nUsado+1))
	aEval(aHeader,{|x,y| aCols[1][y] := Iif(Trim(x[2])=="FH_ITEM","01",CriaVar(x[2])) })
	aCols[1][nUsado+1] := .F.
Else 
	dbSetOrder(nChave)
	dbSeek(xFilial("SFH")+cCodCliFor+cCodLoja)
	While !Eof() .And. &cChave == xFilial("SFH")+cCodCliFor+cCodLoja
		AADD(aCols,Array(nUsado+1))	
		aEval(aHeader,{|x,y| aCols[Len(aCols)][y] := FieldGet(FieldPos(x[02]))})
		aCols[Len(aCols)][nUsado+1] := .F. 
		AAdd(aRecNoSFH,RecNo())
		dbSkip()
	End
EndIf

If (Type("l999Auto") == "U" .Or. !l999Auto )
	AAdd( aObjects, { 0,    41, .T., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 0,    75, .T., .F. } )
	aInfo   := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	aPosObj[2,3] := aPosObj[2,3]+30
	aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],305,{{10,30,55}} )
	//Descricao do array aPosGet
	// 1 - Nome do Campo
	// 2 - Titulo do Campo
	// 3 - Variavel 
	// 4 - Objeto
		
	DEFINE MSDIALOG oDlg FROM aSizeAut[4],0 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL
	//��������������������������������������������������������������Ŀ
	//�Define o cabecalho da rotina                                  �
		//����������������������������������������������������������������      
	@ aPosObj[1][1],aPosObj[1][2] TO aPosObj[1][3],aPosObj[1][4] LABEL '' OF oDlg PIXEL
	If lCliFor
		@ 020,aPosGet[1,1] SAY OemToAnsi(aCposCab[1][2]) OF oDlg PIXEL SIZE 031,006  // "Cliente"
		@ 019,aPosGet[1,2] MSGET aCposCab[1][4] VAR aCposCab[1][3] PICTURE PesqPict("SFH",aCposCab[1][1]);
		F3 "SA1" Valid NaoVazio() When (nOpc == 3 .And. cRotina == Nil) OF oDlg PIXEL SIZE 031,006
	Else
		@ 020,aPosGet[1,1] SAY OemToAnsi(aCposCab[2][2]) OF oDlg PIXEL SIZE 031,006  // "Fornecedor"
		@ 019,aPosGet[1,2] MSGET aCposCab[2][4] VAR aCposCab[2][3] PICTURE PesqPict("SFH",aCposCab[2][1]);
		F3 "FOR" Valid NaoVazio() When (nOpc == 3 .And. cRotina == Nil) OF oDlg PIXEL SIZE 031,006 
	EndIf
	@ 019,aPosGet[1,3] MSGET aCposCab[3][4] VAR aCposCab[3][3] PICTURE PesqPict("SFH",aCposCab[3][1]); // "Loja"
	Valid (NaoVazio() .And. A999ACli(aCposCab)) When (nOpc == 3 .And. cRotina == Nil) OF oDlg PIXEL SIZE 031,006
	
	@ 041,aPosGet[1,1] SAY aCposCab[4][4] VAR aCposCab[4][3] SIZE 300,14 OF oDlg PIXEL;
	FONT oFnt COLOR CLR_HBLUE
	
	//��������������������������������������������������������������Ŀ
	//�Define a area da getdados da rotina                           �
	//����������������������������������������������������������������
	oGetDados := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"A999ALinOk","A999ATudoOk",'+FH_ITEM',lDelLin,aCpos)
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(oGetDados:TudoOk(),(nOpcA:=1,oDlg:End()),nOpcA:=0)},{|| oDlg:End()})
Else
	nOpcA:= 1
	If nOpc <> 5
		msAuto2Acols(nOpc,,"FH_ITEM")
		
		aValidGet := {}
		If nOpc == 3
			AADD(aValidGet,{"aCposCab[1][3]",aAutoCab[ProcH("FH_CLIENTE"),2],"AlwaysTrue()"      ,.T.})
			AADD(aValidGet,{"aCposCab[2][3]",aAutoCab[ProcH("FH_FORNECE"),2],"AlwaysTrue()"      ,.T.})
			AADD(aValidGet,{"aCposCab[3][3]",aAutoCab[ProcH("FH_LOJA"),2]   ,"AlwaysTrue()"      ,.T.})
			AADD(aValidGet,{"aCposCab[4][3]",aAutoCab[ProcH("FH_NOME"),2]   ,"AlwaysTrue()"      ,.T.})
		EndIf 
		
		If !SFH->(MsVldGAuto(aValidGet)) // consiste os gets
			nOpcA := 0
		EndIf
		
		If !SFH->(MsVldAcAuto(aValidGet,"AlwaysTrue()","AlwaysTrue()",,nOpc))   // consiste o campos do Acols
			nOpcA := 0
		EndIf		
	EndIf
EndIf

If nOpcA == 1
	If cRotina == Nil
		Do Case
			Case nOpc == 3
				For nI := 1 To Len(aCols)
					If !aCols[nI][nUsado+1]
						RecLock("SFH",.T.)
						aEval(aCposCab,{|x,y| FieldPut(FieldPos(Trim(x[1])),x[3])})			
						aEval(aHeader,{|x,y| FieldPut(FieldPos(Trim(x[2])),aCols[nI][y])})
						MsUnLock()
					EndIf
				Next nI
			Case nOpc == 4
				For nI := 1 To Len(aCols)
					If nI <= Len(aRecNoSFH)
						MsGoTo(aRecNoSFH[nI])
						RecLock("SFH",.F.)
						If !aCols[nI][nUsado+1]
							aEval(aHeader,{|x,y| FieldPut(FieldPos(Trim(x[2])),aCols[nI][y])})
						Else
							dbDelete()
						EndIf
					Else
						If !aCols[nI][nUsado+1]
							RecLock("SFH",.T.)
							aEval(aCposCab,{|x,y| FieldPut(FieldPos(Trim(x[1])),x[3])})			
							aEval(aHeader,{|x,y| FieldPut(FieldPos(Trim(x[2])),aCols[nI][y])})
		                EndIf
					EndIf
					MsUnLock()
				Next nI
			Case nOpc == 5
				For nI := 1 To Len(aCols)
					MsGoTo(aRecNoSFH[nI])
					RecLock("SFH",.F.)
					dbDelete()
					MsUnLock()
				Next nI	
		EndCase
	Else 
		For nI := 1 To Len(aCposCab)
			AAdd(xAutoCab,{aCposCab[nI][01],aCposCab[nI][03],""})
		Next nI
					
		For nI := 1 To Len(aCols)
			Do Case
				Case nOpc == 4
					For nY := 1 To Len(aHeader)               
						AAdd(aLinha,{aHeader[nY][02],aCols[nI][nY],""})
					Next nY
				Case nOpc == 3
					If !aCols[nI][Len(aHeader)+1]
						For nY := 1 To Len(aHeader)               
							AAdd(aLinha,{aHeader[nY][02],aCols[nI][nY],""})
						Next nY
					EndIf
			EndCase
			
			If !Empty(aLinha)					
				AAdd(aLinha,{"AUTDELETA",Iif(!aCols[nI][Len(aHeader)+1],"N","S"),""})
				AAdd(xAutoItens,aClone(aLinha))
				aLinha := {}
			EndIf
		Next nI
	EndIf
EndIf

If Type("bFiltraBrw") <> "U"
	Set Filter to
	Eval(bFiltraBrw)
EndIf
RestArea(aAreaSFH)
RestArea(aAreaAtu)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A999ACli     �Autor � Julio Cesar          �Data� 13/05/03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Atualiza o nome do Cliente/Fornecedor                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A999ACli(aCposCab)

Local cNomeCliFor := ""
Local cCodCliFor  := ""
Local cCodLoja    := ""
Local aAreaSA     := {}
Local aAreaAtu    := GetArea()
Local nPos        := aScan(aCposCab,{|x| Trim(x[1])="FH_NOME"})
Local nPosCpo     := 0
Local cAliasSA    := Iif(lCliFor,"SA1","SA2")
Local cCpoNome    := Iif(lCliFor,"A1_NOME","A2_NOME")
Local lRet        := .T.
Local cCliFor     := Iif(lCliFor,STR0006,STR0007) //"Cliente"###"Proveedor"

cCodCliFor := aCposCab[Iif(lCliFor,aScan(aCposCab,{|x| Trim(x[1])=="FH_CLIENTE"}),;
                       aScan(aCposCab,{|x| Trim(x[1])=="FH_FORNECE"}))][03]

cCodLoja   := aCposCab[aScan(aCposCab,{|x| Trim(x[1])=="FH_LOJA"})][03] 

dbSelectArea(cAliasSA)
aAreaSA := GetArea()
dbSetOrder(1)
If dbSeek(xFilial(cAliasSA)+cCodCliFor+cCodLoja)
	nPosCpo := (cAliasSA)->(FieldPos(cCpoNome))
	aCposCab[nPos][03] := (cAliasSA)->(FieldGet(nPosCpo))
Else
	lRet := .F.
	aCposCab[nPos][03] := ""
	MsgAlert(OemtoAnsi(STR0008+cCliFor+STR0009),OemToAnsi(STR0010))	 //###### //"El "###" o tienda invalido"###"Atencion"
EndIf		

Return(lRet)

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �999ATudoOk� Autor � Julio Cesar           � Data � 16.09.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Consistencia do registro                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �A999TudoOk()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA999A()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A999ATudoOk()

Local cCodCliFor := ""
Local cCodLoja   := ""
Local nPosImp    := aScan(aHeader,{|x| Trim(x[2])="FH_IMPOSTO"})
Local nPosZFis   := aScan(aHeader,{|x| Trim(x[2])="FH_ZONFIS"})                                                         
Local nChave     := Iif(lCliFor,3,1)
Local nI
Local lRet       := .T.
Local cCliFor    := Iif(lCliFor,STR0006,STR0007) //"Cliente"###"Proveedor"

cCodCliFor := aCposCab[Iif(lCliFor,aScan(aCposCab,{|x| Trim(x[1])=="FH_CLIENTE"}),;
                       aScan(aCposCab,{|x| Trim(x[1])=="FH_FORNECE"}))][03]

cCodLoja   := aCposCab[aScan(aCposCab,{|x| Trim(x[1])=="FH_LOJA"})][03] 

//So realiza a validacao na inclusao de um novo registro...
If Inclui
	For nI := 1 To Len(aCols) 
		If !aCols[nI][nUsado+1]
			lRet := ExistChav("SFH",cCodCliFor+cCodLoja+aCols[nI][nPosImp]+aCols[nI][nPosZFis],nChave)
			If lRet
				Exit
			EndIf
		EndIf
	Next nI
EndIf

Return( lRet )

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A999ALinOk� Autor � Julio Cesar           � Data � 16.09.03 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Consistencia da linha                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �A999ALinOk()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA999A()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A999ALinOk()

Local lRet := .T.                                       
Local nI   := 0

For nI := 1 To Len(aHeader)
	If aHeader[nI][11]
		If Empty(aCols[oGetDados:oBrowse:nAt][nI])
			Help("",1,"Obrigat")
			lRet := .F.
			Exit
		EndIf
	EndIf

	If Trim(aHeader[nI][02]) == "FH_IMPOSTO"
		If aCols[oGetDados:oBrowse:nAt][nI] <> "IBR"
			lRet := ExistCpo('SFB',aCols[oGetDados:oBrowse:nAt][nI],1)
		EndIf
	EndIf
Next nI

Return(lRet)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � ProcH     � Autor � Thiago                � Data � 19.03.01 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Retora a posicao do campo dentro do aHeader                 ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Rotina automatica                                           ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function ProcH(cCampo)
Return aScan(aAutoCab,{|x|Trim(x[1])== cCampo })

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()
     
Private aRotina := { {STR0002,"PesqBrw"		,0,1,0,.F.},;		//"Buscar"
                     {STR0011,"A999ACadSFH"	,0,2,0,NIL},;		//"Visualizar"
                     {STR0003,"A999ACadSFH"	,0,3,0,NIL},;		//"Incluir"
                     {STR0004,"A999ACadSFH"	,0,4,0,NIL},;		//"Modificar"
                     {STR0005,"A999ACadSFH"	,0,5,0,NIL}}		//"Borrar"

If ExistBlock("M999AMNU")
	ExecBlock("M999AMNU",.F.,.F.)
EndIf

Return(aRotina)
