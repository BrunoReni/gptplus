// 浜様様様曜様様様様�
// � Versao � 28     �
// 藩様様様擁様様様様�     

#INCLUDE "protheus.ch"
#INCLUDE "ofiOA300.ch"
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OFIOA300 � Autor � Rubens                � Data � 23/05/12 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Cadastro de Inconvenientes                                 咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
FUNCTION OFIOA300()

DbSelectArea("SX3")
DbSetOrder(1) 
DbSelectArea("VSL")

PRIVATE aRotina   := MenuDef()
Private cCadastro := (STR0006)

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Endereca a funcao de BROWSE                                  �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰

mBrowse( 6, 1,22,75,"VSL")

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OA300    � Autor � Rubens                � Data � 23/05/12 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Cadastro de Inconvenientes                                 咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OA300(cAlias, nReg, nOpc) 

//variaveis controle de janela
Local aObjects := {}
Local aPosObj := {}
Local aPosObjApon := {}
Local aInfo := {} 
Local aSizeAut := MsAdvSize(.t.)
//
Local nCntFor := 0
Local cTitulo
Local cAliasEnchoice

// Deve conter os campos para validacao de chave duplicada 
Local aCpoChvPec := { "VAJ_GRUMOD","VAJ_CODMOD","VAJ_APLICA","VAJ_GRUPEC","VAJ_CODPEC" }
Local aCpoChvSrv := { "VAJ_GRUMOD","VAJ_CODMOD","VAJ_APLICA","VAJ_CODSEG","VAJ_TIPSER","VAJ_CODSER"}
//

Private cChvPec
Private bChvPec

Private cChvSrv
Private bChvSrv

Private cLinOk
Private aCpoEnchoice  :={}

Private aColsSrv :={}
Private aHeaderSrv :={}
Private aColsPec :={}
Private aHeaderPec :={}

Private lVAJGRUMOD := (VAJ->(FieldPos("VAJ_GRUMOD")) <> 0)

VISUALIZA	:= nOpc==2
INCLUI 		:= nOpc==3
ALTERA 		:= nOpc==4
EXCLUI 		:= nOpc==5

lAltGruInc := .F.

If !INCLUI
	VSL->(dbGoTo(nReg))
EndIf

If (ALTERA .or. EXCLUI) .and. !SoftLock("VSL")
	Return .f.	
EndIf

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 1, 108 , .T., .f. } )  //Enchoice
AAdd( aObjects, { 1, 40, .T. , .T. } )  //Folder
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)    

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VSL")
While !Eof().and.(x3_arquivo=="VSL")
	If X3USO(x3_usado).and.cNivel >= x3_nivel
		AADD(aCpoEnchoice,x3_campo)
	Endif
	dbSkip()
End

If Inclui
	RegToMemory("VSL",.t.)
Else
	RegToMemory("VSL",.f.)
Endif

RegToMemory("VAJ",.f.)
cSrvnMostra := "VAJ_CODGRU/VAJ_CODINC/VAJ_CODSEG/VAJ_GRUPEC/VAJ_CODPEC/VAJ_DESPEC/VAJ_QTDPEC/VAJ_QTDCPA"
cPecnMostra := "VAJ_CODGRU/VAJ_CODINC/VAJ_TIPTEM/VAJ_CODSEG/VAJ_TIPSER/VAJ_CODSEC/VAJ_CODSER/VAJ_DESSER/VAJ_GRUSER/VAJ_TSCONC/VAJ_TSFABR/VAJ_TSOUTR"

dbSelectArea("SX3")
DbSetOrder(1)
dbSeek("VAJ")
While !Eof().And.(x3_arquivo=="VAJ")
	
	If X3USO(x3_usado) .And. cNivel>=x3_nivel 
		
		// Cria aHeader de Servicos 
		If !( Alltrim(X3_CAMPO) $ cSrvnMostra )
			Aadd(aHeaderSrv, {	AllTrim(X3Titulo()),	SX3->X3_CAMPO,		SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
								SX3->X3_DECIMAL,		SX3->X3_VALID,		SX3->X3_USADO,		SX3->X3_TIPO,;
								SX3->X3_F3,				SX3->X3_CONTEXT,	X3CBOX() })
		Endif

		// Cria aheader de Pecas 
		If !( Alltrim(X3_CAMPO) $ cPecnMostra)
			Aadd(aHeaderPec, {	AllTrim(X3Titulo()),	SX3->X3_CAMPO,		SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
								SX3->X3_DECIMAL,		SX3->X3_VALID,		SX3->X3_USADO,		SX3->X3_TIPO,;
								SX3->X3_F3,				SX3->X3_CONTEXT,	X3CBOX() })			
		Endif
		
	Endif
	
	dbSkip()
	
End

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VAJ")
ADHeadRec("VAJ",aHeaderSrv)
ADHeadRec("VAJ",aHeaderPec)
//

aColsSrv := {}
aColsPec := {}

dbSelectArea("VAJ")
dbSetOrder(1)
dbSeek( xFilial("VAJ") + M->VSL_CODMAR + M->VSL_CODGRU + M->VSL_CODINC )

While !eof() .And. VAJ->VAJ_FILIAL == xFilial("VAJ") .And. VAJ->VAJ_CODMAR + VAJ->VAJ_CODGRU + VAJ->VAJ_CODINC == M->VSL_CODMAR + M->VSL_CODGRU + M->VSL_CODINC
	
	// Servicos //
	If !Empty(VAJ->VAJ_CODSER)
		AADD(aColsSrv,Array(Len(aHeaderSrv)+1))
		For nCntFor:=1 to Len(aHeaderSrv)
			If IsHeadRec(aHeaderSrv[nCntFor,2])
				aColsSrv[Len(aColsSrv),nCntFor] := VAJ->(RecNo())
			ElseIf IsHeadAlias(aHeaderSrv[nCntFor,2])
				aColsSrv[Len(aColsSrv),nCntFor] := "VAJ"
			Else
				aColsSrv[Len(aColsSrv),nCntFor] := IIf(aHeaderSrv[nCntFor,10] # "V",FieldGet(FieldPos(aHeaderSrv[nCntFor,2])),CriaVar(aHeaderSrv[nCntFor,2]))
			EndIf
		Next
		aColsSrv[Len(aColsSrv),Len(aHeaderSrv)+1]:=.F.
	EndIf

    // Pecas //
	If !Empty(VAJ->VAJ_CODPEC)
		AADD(aColsPec,Array(Len(aHeaderPec)+1))
		For nCntFor:=1 to Len(aHeaderPec)
			If IsHeadRec(aHeaderPec[nCntFor,2])
				aColsPec[Len(aColsPec),nCntFor] := VAJ->(RecNo())
			ElseIf IsHeadAlias(aHeaderPec[nCntFor,2])
				aColsPec[Len(aColsPec),nCntFor] := "VAJ"
			Else
				aColsPec[Len(aColsPec),nCntFor] := IIf(aHeaderPec[nCntFor,10] # "V",FieldGet(FieldPos(aHeaderPec[nCntFor,2])),CriaVar(aHeaderPec[nCntFor,2]))
			EndIf
		Next
		aColsPec[Len(aColsPec),Len(aHeaderPec)+1]:=.F.
	EndIf
	
	dbSelectArea("VAJ")
	dbSkip()
EndDo

nLenSrv  :=Len(aColsSrv)
nLenPec  :=Len(aColsPec)

// Servico
If Len( aColsSrv ) == 0
	
	aColsSrv:={Array(Len(aHeaderSrv)+1)}
	aColsSrv[1,Len(aHeaderSrv)+1]:=.F.
	For nCntFor:=1 to Len(aHeaderSrv)
		If IsHeadRec(aHeaderSrv[nCntFor,2])
			aColsSrv[Len(aColsSrv),nCntFor] := 0
		ElseIf IsHeadAlias(aHeaderSrv[nCntFor,2])
			aColsSrv[Len(aColsSrv),nCntFor] := "VAJ"
		Else
			aColsSrv[1,nCntFor]:=CriaVar(aHeaderSrv[nCntFor,2],.t.)
		EndIf
	Next
	
EndIf

// Peca
If Len( aColsPec ) == 0
	
	aColsPec:={Array(Len(aHeaderPec)+1)}
	aColsPec[1,Len(aHeaderPec)+1]:=.F.
	For nCntFor:=1 to Len(aHeaderPec)
		If IsHeadRec(aHeaderPec[nCntFor,2])
			aColsPec[Len(aColsPec),nCntFor] := 0
		ElseIf IsHeadAlias(aHeaderPec[nCntFor,2])
			aColsPec[Len(aColsPec),nCntFor] := "VAJ"
		Else
			aColsPec[1,nCntFor]:=CriaVar(aHeaderPec[nCntFor,2],.t.)
		EndIf
	Next
	
EndIf

// Configura variaveis utilizadas na checagem de linha duplicada ...
// Para utilizar mais ou menos colunas � so alterar o conteudo das variaveis aCpoChvPec (Peca) ou aCpoChvSrv (Servicos)
OA300CFGCV(aCpoChvPec,"aHeaderPec",@cChvPec,@bChvPec)
OA300CFGCV(aCpoChvSrv,"aHeaderSrv",@cChvSrv,@bChvSrv)
//

cTitulo       :=STR0006
cAliasEnchoice:="VSL"

cFldOkPec := "OA300FPOK()"
cTudOkPec := "OA300TUDOK('P')"
cLinOkPec := "OA300LINOK('P')"

cFldOkSrv := "OA300FSOK()"
cTudOkSrv := "OA300TUDOK('S')"
cLinOkSrv := "OA300LINOK('S')"

DbSelectArea("VSL")

DEFINE MSDIALOG oDlg1 TITLE cTitulo From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

   	EnChoice(cAliasEnchoice,nReg,nOpc,,,,aCpoEnchoice,{aPosObj[1,1]+3,aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.F.)
	
	oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],{STR0007,STR0008},{},oDlg1,,,,.t.,.f.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
	oFolder:bSetOption := { |x| OA300MUDFOL(oFolder:nOption , x) } // Executa na mudanca da aba	

	oGetSrv := MsNewGetDados():New(;
		1,1,1,1,;
		Iif( VISUALIZA .or. EXCLUI, 0 , (GD_INSERT + GD_UPDATE + GD_DELETE) ) ,; // Operacao - 2 Visualizar / 3 Incluir / 4 Alterar / 5 Excluir
		cLinOkSrv,;
		cTudOkSrv,;
		,;
		,; 	// Campos alteraveis da GetDados
		/* nFreeze */,;	// Campos estaticos da GetDados
		2000, ;
		cFldOkSrv,;
		/* cSuperDel */,; 	// Funcao executada quando pressionado <Ctrl>+<Del>
		/* cDelOk */ ,; 		// Funcao executada para validar a exclusao de uma linha
		oFolder:aDialogs[1],;
		aHeaderSrv ,;
		aColsSrv )
	oGetSrv:oBrowse:bChange   := { || FG_MEMVAR( oGetSrv:aHeader , oGetSrv:aCols , oGetSrv:nAt),OA300CODMAR() }		//TESTE
	oGetSrv:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT		
		
	oGetPec := MsNewGetDados():New(;
		1,1,1,1,;
		Iif( VISUALIZA .or. EXCLUI , 0 , (GD_INSERT + GD_UPDATE + GD_DELETE) ) ,; // Operacao - 2 Visualizar / 3 Incluir / 4 Alterar / 5 Excluir
		cLinOkPec,;
		cTudOkPec,;
		,;
		,; 	// Campos alteraveis da GetDados
		/* nFreeze */,;	// Campos estaticos da GetDados
		2000, ;
		cFldOkPec,;
		/* cSuperDel */,; 	// Funcao executada quando pressionado <Ctrl>+<Del>
		/* cDelOk */ ,; 		// Funcao executada para validar a exclusao de uma linha
		oFolder:aDialogs[2],;
		aHeaderPec ,;
		aColsPec )
	oGetPec:oBrowse:bChange   := { || FG_MEMVAR( oGetPec:aHeader , oGetPec:aCols , oGetPec:nAt) }		
	oGetPec:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT		

ACTIVATE MSDIALOG oDlg1 ON INIT ( EnchoiceBar(oDlg1,{|| IIF( OA300OK(nOpc) .AND. OA300GRV(nOpc) , oDlg1:End() , .f. ) },{|| oDlg1:End() }) )

DbSelectArea("VSL")
DbSetOrder(1)

MsUnlockAll()

Return


/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OA300OK  � Autor � Rubens                � Data � 23/05/12 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Validacao na Confirmacao da Dialog                         咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OA300OK( nOpc )

Local nCntFor 

If VISUALIZA .OR. EXCLUI
	Return .t.
EndIf

For nCntFor := 1 to Len(aCpoEnchoice)
	If X3Obrigat(aCpoEnchoice[nCntFor]) .and. Empty(&("M->"+aCpoEnchoice[nCntFor]))
		Help(" ",1,"OBRIGAT2",,RetTitle(aCpoEnchoice[nCntFor]),4,1)
		Return .f.
	EndIf
Next

If M->VSL_KILOME > M->VSL_KILFIN
	MsgInfo(STR0010,STR0009)
	Return .f.
EndIf

If M->VSL_PERINI > M->VSL_PERFIN
	MsgInfo(STR0011,STR0009)
	Return .f.
EndIf

If !OA300TUDOK( "S" )
	Return .f.
EndIf

If !OA300TUDOK( "P" )
	Return .f.
EndIf


Return .t. 

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OA300FPOK � Autor � Rubens               � Data � 23/05/12 咳�
臼団陳陳陳陳津陳陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � FieldOK de Pecas                                           咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OA300FPOK()

Local lRet := .t.
Local cReadVar := ReadVar()

// Permite interfer�ncia no momento da Valida艫o de cada campo da GetDados
If ExistBlock("OA300VLD")
	lRet := ExecBlock("OA300VLD",.F.,.F.)
	If !lRet
		Return(lRet)
	Endif
EndIf

/*If M->VAJ_CODMAR != M->VSL_CODMAR .and. !Empty( M->VSL_CODMAR )
	M->VAJ_CODMAR := M->VSL_CODMAR
	oGetPec:aCols[oGetPec:nAt,FG_POSVAR("VAJ_CODMAR","aHeaderPec")] := M->VSL_CODMAR
EndIf
*/

If cReadVar == "M->VAJ_CODMOD"
	If lVAJGRUMOD .and. !Empty(M->VAJ_GRUMOD)
		M->VAJ_GRUMOD := oGetPec:aCols[oGetPec:nAt,FG_POSVAR("VAJ_GRUMOD","aHeaderPec")] := Space(TamSX3("VAJ_GRUMOD")[1])
	EndIf
EndIf

If cReadVar == "M->VAJ_GRUMOD"
	M->VAJ_CODMOD := oGetPec:aCols[oGetPec:nAt,FG_POSVAR("VAJ_CODMOD","aHeaderPec")] := Space(TamSX3("VAJ_CODMOD")[1])
EndIf

If ReadVar() == "M->VAJ_GRUPEC"
	If !Empty(M->VAJ_CODPEC)
		SB1->(DBSetOrder(7))
		If SB1->(DBSeek(xFilial("SB1")+M->VAJ_GRUPEC+M->VAJ_CODPEC))
			oGetPec:aCols[oGetPec:nAt,FG_POSVAR("VAJ_DESPEC","aHeaderPec")] := SB1->B1_DESC
		Else
			lRet := .f.
		EndIf
	Else
		oGetPec:aCols[oGetPec:nAt,FG_POSVAR("VAJ_DESPEC","aHeaderPec")] := ""
	EndIf
EndIf

If ReadVar() == "M->VAJ_CODPEC"
	SB1->(DBSetOrder(7))
	If SB1->(DBSeek(xFilial("SB1")+M->VAJ_GRUPEC+M->VAJ_CODPEC))
		oGetPec:aCols[oGetPec:nAt,FG_POSVAR("VAJ_GRUPEC","aHeaderPec")] := M->VAJ_GRUPEC
		oGetPec:aCols[oGetPec:nAt,FG_POSVAR("VAJ_DESPEC","aHeaderPec")] := SB1->B1_DESC
	Else
		lRet := .f.
	EndIf
EndIf

Return lRet

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OA300FSOK � Autor � Rubens               � Data � 23/05/12 咳�
臼団陳陳陳陳津陳陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � FieldOK de Servicos                                        咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OA300FSOK()

Local lRet := .t.
Local cMarcaPesq
Local cReadVar := ReadVar()

/*
If M->VAJ_CODMAR != M->VSL_CODMAR .and. !Empty( M->VSL_CODMAR )
	M->VAJ_CODMAR := M->VSL_CODMAR
	oGetSrv:aCols[oGetSrv:nAt,FG_POSVAR("VAJ_CODMAR","aHeaderSrv")] := M->VAJ_CODMAR
EndIf
*/
If cReadVar == "M->VAJ_CODMOD"
	If lVAJGRUMOD .and. !Empty(M->VAJ_GRUMOD)
		M->VAJ_GRUMOD := oGetSrv:aCols[oGetSrv:nAt,FG_POSVAR("VAJ_GRUMOD","aHeaderSrv")] := Space(TamSX3("VAJ_GRUMOD")[1])
	EndIf
EndIf

If cReadVar == "M->VAJ_GRUMOD"
	M->VAJ_CODMOD := oGetSrv:aCols[oGetSrv:nAt,FG_POSVAR("VAJ_CODMOD","aHeaderSrv")] := Space(TamSX3("VAJ_CODMOD")[1])
EndIf

If cReadVar == "M->VAJ_GRUSER"
	M->VAJ_CODSER := oGetSrv:aCols[oGetSrv:nAt,FG_POSVAR("VAJ_CODSER","aHeaderSrv")] := Space(TamSX3("VAJ_CODSER")[1])
	M->VAJ_DESSER := oGetSrv:aCols[oGetSrv:nAt,FG_POSVAR("VAJ_DESSER","aHeaderSrv")] := ""
EndIf

If cReadVar == "M->VAJ_CODSER"
	If !Empty( M->VAJ_CODMAR )
		cMarcaPesq := FG_MARSRV(M->VSL_CODMAR,M->VAJ_CODSER)
		VO6->(dbSetOrder(2))
		If VO6->(dbSeek(xFilial("VO6")+cMarcaPesq+M->VAJ_CODSER))
			oGetSrv:aCols[oGetSrv:nAt,FG_POSVAR("VAJ_DESSER","aHeaderSrv")] := VO6->VO6_DESSER
		Else
			lRet := .f.
		EndIf
	Else
		VO6->(dbSetOrder(4))
		If VO6->(dbSeek(xFilial("VO6")+M->VAJ_CODSER))
			oGetSrv:aCols[oGetSrv:nAt,FG_POSVAR("VAJ_DESSER","aHeaderSrv")] := VO6->VO6_DESSER
		Else
			lRet := .f.
		EndIf
	EndIf
EndIf

Return lRet



/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OA300TUDOK  � Autor � Rubens             � Data � 23/05/12 咳�
臼団陳陳陳陳津陳陳陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Tudo OK da GetDados de Pecas e Servicos                    咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametro � cPecSer = "P" - GetDados de Pecas                          咳�
臼�          �           "S" - GetDados de Servicos                       咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OA300TUDOK( cPecSer )

Local nCntFor 
Local nBkpnAt
Local lRet := .t.

If cPecSer == "P"
	nBkpnAt := oGetPec:nAt
	For nCntFor := 1 to Len(oGetPec:aCols)
		oGetPec:nAt := nCntFor 
		FG_MEMVAR( oGetPec:aHeader , oGetPec:aCols , oGetPec:nAt)		
		If !OA300LINOK( "P" )
			lRet := .f.
			Exit
		EndIf
	Next nCntFor
	oGetPec:nAt := nBkpnAt
	FG_MEMVAR( oGetPec:aHeader , oGetPec:aCols , oGetPec:nAt)
EndIf

If lRet .and. cPecSer == "S"
	nBkpnAt := oGetSrv:nAt
	For nCntFor := 1 to Len(oGetSrv:aCols)
		oGetSrv:nAt := nCntFor 
		FG_MEMVAR( oGetSrv:aHeader , oGetSrv:aCols , oGetSrv:nAt)			
		If !OA300LINOK( "S" )
			lRet := .f.
			Exit
		EndIf
	Next nCntFor
	oGetSrv:nAt := nBkpnAt
	FG_MEMVAR( oGetSrv:aHeader , oGetSrv:aCols , oGetSrv:nAt)	
EndIf

Return lRet

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OA300LINOK  � Autor � Rubens             � Data � 23/05/12 咳�
臼団陳陳陳陳津陳陳陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Linha OK da GetDados de Pecas e Servicos                   咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametro � cPecSer = "P" - GetDados de Pecas                          咳�
臼�          �           "S" - GetDados de Servicos                       咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OA300LINOK( cPecSer )

Local nCntFor := 0
Local lVazio

If cPecSer == "P"
	If oGetPec:aCols[oGetPec:nAt,Len(aHeaderPec)+1]
		Return .t.
	EndIf
	
	If Len(oGetPec:aCols) == 1
		lVazio := .t.
		For nCntFor := 1 to Len(aHeaderPec)
			If IsHeadRec(aHeaderPec[nCntFor,2]) .or. IsHeadAlias(aHeaderPec[nCntFor,2])
				Loop
			EndIf
			If !Empty(oGetPec:aCols[1,nCntFor])
				lVazio := .f.
			EndIf
		Next 
		If lVazio
			Return .t.
		EndIf
	EndIf
	
	For nCntFor:=1 to Len(aHeaderPec)
		If X3Obrigat(aHeaderPec[nCntFor,2]) .and. (Empty(oGetPec:aCols[oGetPec:nAt,nCntFor]))
			Help(" ",1,"OBRIGAT2",,RetTitle(aHeaderPec[nCntFor,2]),4,1)
			Return .f.
		EndIf
	Next

	// Valida chave duplicada ... 
	If !OA300DUPL( oGetPec , bChvPec , cChvPec )
		Return .f.
	EndIf
	//
EndIf

If cPecSer == "S"

	If oGetSrv:aCols[oGetSrv:nAt,Len(aHeaderSrv)+1]
		Return .t.
	EndIf
	
	If Len(oGetSrv:aCols) == 1 .and. Empty(oGetSrv:aCols[1,FG_POSVAR("VAJ_CODSER","aHeaderSrv")])
		lVazio := .t.
		For nCntFor := 1 to Len(aHeaderSrv)
			If IsHeadRec(aHeaderSrv[nCntFor,2]) .or. IsHeadAlias(aHeaderSrv[nCntFor,2])
				Loop
			EndIf
			If !Empty(oGetSrv:aCols[1,nCntFor])
				lVazio := .f.
			EndIf
		Next 
		If lVazio
			Return .t.
		EndIf	
	EndIf
	

	For nCntFor:=1 to Len(aHeaderSrv)
		If X3Obrigat(aHeaderSrv[nCntFor,2]) .and. (Empty(oGetSrv:aCols[oGetSrv:nAt,nCntFor]))
			Help(" ",1,"OBRIGAT2",,RetTitle(aHeaderSrv[nCntFor,2]),4,1)
			Return .f.
		EndIf
	Next 
	
	If !OA300DUPL( oGetSrv , bChvSrv , cChvSrv )
		Return .f.
	EndIf	

EndIf

Return .t.


/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OA300DUPL   � Autor � Rubens             � Data � 23/05/12 咳�
臼団陳陳陳陳津陳陳陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Verifica se existe linha duplicada na GetDados             咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametro � oObjGet = Objeto referente a GetDados de Pecas ou Servicos 咳�
臼�          � bChv = CodeBlock para verificacao de chave duplicada       咳�
臼�          � cChv = Campos para verificacao de chave duplicada          咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function OA300DUPL( oObjGet , bChv , cChv )

Local nCntForD

For nCntForD := 1 to Len(oObjGet:aCols)
	If !oObjGet:aCols[nCntForD,Len(oObjGet:aHeader)+1] .and. nCntForD <> oObjGet:nAt ;
		.and. Eval(bChv) == &(cChv)
		
		Help("  ",1,"EXISTCHAV")
		Return(.f.)
		
	EndIf
Next

Return .t. 


/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OA300LINOK  � Autor � Rubens             � Data � 23/05/12 咳�
臼団陳陳陳陳津陳陳陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Configura CodeBlock e String de Campos para verificacao de 咳�
臼�          � chave duplicada                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametro � aCpoChv = Matriz com os campos que serao utilizados        咳�
臼�          � cNomeaHeader = Nome do aHeader que sera utilizado          咳�
臼�          � cChv = String que sera utilizada para verificacao          咳�
臼�          � bChv = CodeBlock que sera utilizado para verificacao       咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function OA300CFGCV( aCpoChv , cNomeaHeader , cCpoChv , bChvAcols )

Local cChkaCols := ""
Local nCntFor

cCpoChv := ""

For nCntFor := 1 to Len(aCpoChv)
	
	If FG_POSVAR(aCpoChv[nCntFor],cNomeaHeader) <> 0
		cCpoChv += "M->" + aCpoChv[nCntFor] + " + "
		
		cChkaCols += "oObjGet:aCols[ nCntForD , " + AllTrim(Str(FG_POSVAR(aCpoChv[nCntFor],cNomeaHeader))) + " ] + "
	EndIf
Next nCntFor 
	
cCpoChv := Left(cCpoChv,RAT("+",cCpoChv)-1)
cChkaCols := Left(cChkaCols,RAT("+",cChkaCols)-1)

bChvAcols := &("{ || " + cChkaCols + " }")
	
Return 



/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OA300MUDFOL � Autor � Rubens             � Data � 23/05/12 咳�
臼団陳陳陳陳津陳陳陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Controla a mudanca de Aba da Folder                        咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametro � nFOrigem = Numero da Aba Atual                             咳�
臼�          � nFDestino = Numero da Aba de Destino                       咳�
臼�          � 1 - Servicos                                               咳�
臼�          � 2 - Pecas                                                  咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OA300MUDFOL(nFOrigem, nFDestino)
if !(INCLUI .or. ALTERA)
	return .t.
endif
//
if nFOrigem == 1 .and. !OA300LINOK('S')
	return .f.
endif
if nFOrigem == 2 .and. !OA300LINOK('P')
	return .f.
endif

if nFDestino == 1
	FG_MEMVAR( oGetSrv:aHeader , oGetSrv:aCols , oGetSrv:nAt)
endif
if nFDestino == 2
	FG_MEMVAR( oGetPec:aHeader , oGetPec:aCols , oGetPec:nAt)
endif

return




/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OA300GRV    � Autor � Rubens             � Data � 23/05/12 咳�
臼団陳陳陳陳津陳陳陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Gravacao do Registro                                       咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OA300GRV( nOpc )

Local aVetValid
Local lRet := .t.
Local nCntFor
Local nColRec

If VISUALIZA
	Return .t.
EndIf

If EXCLUI
	aVetValid := {}
	Aadd(aVetValid, { "VST" , 2 , M->VSL_CODMAR+M->VSL_CODGRU+M->VSL_CODINC , NIL } )
	
	If !FG_DELETA(aVetValid)
		Return( .f. )
	EndIf
	
	Begin Transaction
	
	dbSelectArea("VAJ")
	VAJ->(dbSetOrder(1))
	VAJ->(dbSeek( xFilial("VAJ") + M->VSL_CODMAR + M->VSL_CODGRU + M->VSL_CODINC ))
	While !VAJ->(Eof()) .And. VAJ->VAJ_FILIAL == xFilial("VAJ") .And. VAJ->VAJ_CODMAR + VAJ->VAJ_CODGRU + VAJ->VAJ_CODINC == M->VSL_CODMAR + M->VSL_CODGRU + M->VSL_CODINC
		If !RecLock("VAJ",.F.,.T.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf
		
		VAJ->(dbdelete())
		VAJ->(MsUnlock())
		
		VAJ->(dbSkip())
	End
	
	dbSelectArea("VSL")
	If !RecLock("VSL",.F.,.T.)
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf
	
	VSL->(dbdelete())
	VSL->(MsUnlock())
	
	END TRANSACTION
	
EndIf

If INCLUI .or. ALTERA
	
	BEGIN TRANSACTION
	
	// Grava Cabecalho
	DbSelectArea("VSL")
	DbSetOrder(1)
	DbSeek( xFilial("VSL") + M->VSL_CODMAR + M->VSL_CODGRU + M->VSL_CODINC )
	If !RecLock("VSL", !Found() )
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf
	
	FG_GRAVAR("VSL")
	//
	
	For nCntFor := 1 to Len(oGetSrv:aHeader)
		if IsHeadRec(oGetSrv:aHeader[nCntFor,2])
			nColRec := nCntFor
		endif
	Next I
	
	// Grava Servicos
	For nCntFor := 1 to len(oGetSrv:aCols)
		
		dbSelectArea("VAJ")
		
		// Linha Deletada
		If oGetSrv:aCols[nCntFor,Len(oGetSrv:aHeader)+1]
			
			If oGetSrv:aCols[nCntFor,nColRec] <> 0
				VAJ->(dbGoTo( oGetSrv:aCols[nCntFor,nColRec] ))
				If !RecLock("VAJ",.F.,.T.)
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				VAJ->(dbdelete())
				VAJ->(MsUnlock())
				
			EndIf
			
		// Inclusa / Alteracao de Item
		Else
			
			dbSelectArea("VAJ")
			If oGetSrv:aCols[nCntFor,nColRec] <> 0
				VAJ->(dbGoTo( oGetSrv:aCols[nCntFor,nColRec] ))
				If !RecLock("VAJ", .f. )
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
			Else
				// Linha em branco ...
				If Empty(oGetSrv:aCols[nCntFor,FG_POSVAR("VAJ_CODSER","aHeaderSrv")])
					Loop
				EndIf
				//
				RecLock("VAJ", .t. )
			EndIf
			
			FG_GRAVAR("VAJ",oGetSrv:aCols,oGetSrv:aHeader,nCntFor)
			VAJ->VAJ_FILIAL := xFilial("VAJ")
			VAJ->VAJ_CODMAR := M->VSL_CODMAR
			VAJ->VAJ_CODGRU := M->VSL_CODGRU
			VAJ->VAJ_CODINC := M->VSL_CODINC
			VAJ->(MsUnlock())
			
		EndIf
		
	Next
	
	For nCntFor := 1 to Len(oGetPec:aHeader)
		if IsHeadRec(oGetPec:aHeader[nCntFor,2])
			nColRec := nCntFor
		endif
	Next I
	
	// Grava Pecas
	For nCntFor:=1 to len(oGetPec:aCols)
		
		// Linha Deletada
		If oGetPec:aCols[nCntFor,Len(oGetPec:aHeader)+1]
			
			If oGetPec:aCols[nCntFor,nColRec] <> 0
				VAJ->(dbGoTo( oGetPec:aCols[nCntFor,nColRec] ))
				If !RecLock("VAJ",.F.,.T.)
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				VAJ->(dbdelete())
				VAJ->(MsUnlock())
				
			EndIf
			
		// Inclusa / Alteracao de Item
		Else
			
			dbSelectArea("VAJ")
			If oGetPec:aCols[nCntFor,nColRec] <> 0
				VAJ->(dbGoTo( oGetPec:aCols[nCntFor,nColRec] ))
				If !RecLock("VAJ", .f. )
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
			Else
				// Linha em branco ...
				If Empty(oGetPec:aCols[nCntFor,FG_POSVAR("VAJ_CODPEC","aHeaderPec")])
					Loop
				EndIf
				//
				RecLock("VAJ", .t. )
			EndIf
			
			FG_GRAVAR("VAJ" , oGetPec:aCols , oGetPec:aHeader , nCntFor)
			VAJ->VAJ_FILIAL := xFilial("VAJ")
			VAJ->VAJ_CODMAR := M->VSL_CODMAR
			VAJ->VAJ_CODGRU := M->VSL_CODGRU
			VAJ->VAJ_CODINC := M->VSL_CODINC
			VAJ->(MsUnlock())
			
		EndIf
		
	Next
	
	END TRANSACTION
	
EndIf

Return lRet


/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � FS_TPSTPT   � Autor �                    � Data � 23/05/12 咳�
臼団陳陳陳陳津陳陳陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Validacao do Tipo de Servico                               咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_TPSTPT(cTipTem,cTipSrv,lTpSrvBlq)
Local lRet    := .f.
Local oTipSer := DMS_Servico():New()

Default lTpSrvBlq := .f.

VOX->( DbSetOrder(2) )
lConsidera := .t.
if VOI->(FieldPos("VOI_CONVOX")) > 0
	VOI->(DbSetOrder(1))
	VOI->(DbSeek( xFilial("VOI") + cTipTem ))
	if VOI->VOI_CONVOX == "0"
		lConsidera := .f.
	endif
endif
If !lConsidera .or. VOX->( DbSeek( xFilial("VOX") + cTipTem + cTipSrv) )
	// A vari�vel lTpSrvBlq apenas ser� .f. quando a fun艫o for chamada pelo SXB
	If lTpSrvBlq .And. FindFunction("OFXFA0016_VerificaMetodoEmClasse") .And. OFXFA0016_VerificaMetodoEmClasse(oTipSer, "TipServBloqueado")
		// Tipo de Servi�o Bloqueado
		If !oTipSer:TipServBloqueado(cTipSrv)
			lRet := .t. // A mensagem j� � exibida dentro da fun艫o OFM0300026_TipSerBloqueado()
		EndIf
	Else
		lRet := .t.
	EndIf
EndIf

Return lRet

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � FS_DESSERX  � Autor �                    � Data � 23/05/12 咳�
臼団陳陳陳陳津陳陳陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Validacao do Codigo do Servico (VAJ_CODSER)                咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_DESSERX()
Local lRet := .f.

If FS_SERINA(M->VSL_CODMAR,M->VAJ_CODSER,M->VAJ_GRUSER,"M->VAJ_DESSER","M->VAJ_CODSER")
	lRet := .t.
EndIf

Return(lRet)

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � MenuDef     � Autor � Rubens             � Data � 23/05/12 咳�
臼団陳陳陳陳津陳陳陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Menu da Rotina                                              咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function MenuDef()
Local aRotina := { { STR0001 ,"AxPesqui"	, 0 , 1},; //Pesquisar
					{ STR0002 ,"OA300"		, 0 , 2},; //Visualizar
					{ STR0003 ,"OA300"		, 0 , 3},; //Incluir
					{ STR0004 ,"OA300"		, 0 , 4},; //Alterar
					{ STR0005 ,"OA300"		, 0 , 5}}  //Excluir
Return aRotina


/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OA300CODMAR � Autor � Carla Catiane F R  � Data � 30/06/14 咳�
臼団陳陳陳陳津陳陳陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Controla a atualizacao da marca.                           咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OA300CODMAR()

If (M->VAJ_CODMAR != M->VSL_CODMAR .or. Empty(M->VAJ_CODMAR)) 
	M->VAJ_CODMAR := M->VSL_CODMAR
	oGetPec:aCols[oGetPec:nAt,FG_POSVAR("VAJ_CODMAR","aHeaderPec")] := M->VSL_CODMAR
	oGetPec:Refresh()
	oGetSrv:aCols[oGetSrv:nAt,FG_POSVAR("VAJ_CODMAR","aHeaderPec")] := M->VSL_CODMAR
	oGetSrv:Refresh()	
EndIf

Return M->VSL_CODMAR

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OA300VALGRP � Autor � Thiago			    � Data � 24/09/14 咳�
臼団陳陳陳陳津陳陳陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Validacao do grupo do item.                                咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OA300VALGRP(cCodMar_,cGrpPec) 
Local lRet := .f.

dbSelectArea("SBM")
dbSetOrder(1)
dbSeek(xFilial("SBM")+cGrpPec)
if !Empty(cCodMar_)
	if SBM->BM_CODMAR == cCodMar_   
     	lRet := .t.
	Endif
Else
	lRet := .t.
Endif    

Return(lRet)


/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳陳賃陳陳陳賃陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OA300GRUSER � Autor � Thiago			    � Data � 24/09/14 咳�
臼団陳陳陳陳津陳陳陳陳陳陳珍陳陳陳珍陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Validacao do grupo do servico.                             咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OA300GRUSER(cCodMar,cGrpSer) 
Local lRet := .f.

dbSelectArea("VOS")
dbSetOrder(1)
if !dbSeek(xFilial("VOS")+cCodMar+cGrpSer)
	dbSelectArea("VOS")
	dbSetOrder(2)
	if dbSeek(xFilial("VOS")+cGrpSer)
		While !eof() .and. VOS->VOS_FILIAL + VOS->VOS_CODGRU == xFilial("VOS") + cGrpSer 
			if cCodMar == VOS->VOS_CODMAR .or. Empty(cCodMar)
				lRet := .t.
				exit
			Else
				lRet := .f.
			Endif 
			DbSkip()
		Enddo
	Else
		lRet := .f.
	Endif
Else
	lRet := .t.
Endif

Return(lRet)

/*/
{Protheus.doc} OFIOA030

@author Renato Vinicius
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function OA3000015_FiltroServicos()

	Local cRetorno := ""

	dbSelectArea("VO6")
	dbSetOrder(3)
	
	cRetorno := FMX_FILSXB("VAD")
	cRetorno += " AND VO6_CODMAR = '" + M->VAJ_CODMAR + "' AND VO6_GRUSER = '" + M->VAJ_GRUSER + "'"

Return cRetorno