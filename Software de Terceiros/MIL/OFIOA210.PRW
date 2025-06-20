// 浜様様様曜様様様様�
// � Versao � 14     �
// 藩様様様擁様様様様�

#Include "Protheus.ch"
#Include "OFIOA210.CH"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OFIOA210 � Autor � Andre Luis Almeida    � Data � 04/12/13 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Cadastro de Motivos                                        咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFIOA210()

Private cCadastro := STR0001 // Motivos
Private aRotina   := MenuDef()

mBrowse( 6, 1,22,75,"VS0")

Return .T.

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
臼敖陳陳陳陳賃陳陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳陳賃陳陳陳堕陳陳陳陳朕臼
臼�Funcao    � OFA210V    � Autor � Andre Luis Almeida       � Data � 04/12/13 咳�
臼団陳陳陳陳津陳陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳陳珍陳陳陳祖陳陳陳陳調臼
臼�Descricao � Visualizar                                                      咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰臼
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝
*/
Function OFA210V()
Local nReg := VS0->(RecNo())
Inclui     := .f.
Altera     := .f.
nOpc       := 2
OFA210("VS0",nReg,nOpc)
Return()

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
臼敖陳陳陳陳賃陳陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳陳賃陳陳陳堕陳陳陳陳朕臼
臼�Funcao    � OFA210I    � Autor � Andre Luis Almeida       � Data � 04/12/13 咳�
臼団陳陳陳陳津陳陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳陳珍陳陳陳祖陳陳陳陳調臼
臼�Descricao � Incluir                                                         咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰臼
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝
*/
Function OFA210I()
Local nReg := 0
Inclui     := .t.
Altera     := .f.
nOpc       := 3
OFA210("VS0",nReg,nOpc)
Return()

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
臼敖陳陳陳陳賃陳陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳陳賃陳陳陳堕陳陳陳陳朕臼
臼�Funcao    � OFA210A    � Autor � Andre Luis Almeida       � Data � 04/12/13 咳�
臼団陳陳陳陳津陳陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳陳珍陳陳陳祖陳陳陳陳調臼
臼�Descricao � Alterar                                                         咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰臼
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝
*/
Function OFA210A()
Local nReg := VS0->(RecNo())
Inclui     := .f.
Altera     := .t.
nOpc       := 4
OFA210("VS0",nReg,nOpc)
Return()

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OFA210   � Autor � Andre Luis Almeida    � Data � 04/12/13 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Tela de Cadastro de Motivos                                咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFA210(cAlias,nReg,nOpc)

Local bCampo := { |nCPO| Field(nCPO) } , nCntFor := 0 , _ni := 0 , _lRet := .t.
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cFieldOk

Private nLenaCols := 0
Private aTELA[0][0],aGETS[0]
Private aCols := {}, aHeader := {} , aCpoEnchoice  := {}
Private oAuxEnchoice
Private oAuxGetDados
Private oAuxDlg

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Opcoes de acesso para a Modelo 3                             �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
nOpcE := nOpc // 2-Visualizar / 3-Incluir / 4-Alterar
nOpcG := nOpc // 2-Visualizar / 3-Incluir / 4-Alterar

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Cria variaveis M->????? da Enchoice                          �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
RegToMemory("VS0",.T.)

aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VS0")
While !Eof().and.(x3_arquivo=="VS0")
	If X3USO(x3_usado).and.cNivel >=x3_nivel
		AADD(aCpoEnchoice,x3_campo)
		&("M->"+x3_campo):= CriaVar(x3_campo)
	Endif
	dbSkip()
End

If !(Inclui)
	DbSelectArea("VS0")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Cria aHeader e aCols da GetDados                             �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
nUsado:=0
dbSelectArea("SX3")
dbSeek("VDS")
aHeader:={}
aAlter:={}
While !Eof().And.(x3_arquivo=="VDS")
	If X3USO(x3_usado) .and. cNivel >= x3_nivel .and. !(x3_campo $ "VDS_FILIAL/VDS_TIPASS/VDS_CODMOT/")
		nUsado:=nUsado+1
		aAdd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_f3, x3_context, x3cbox(), x3_relacao } )
		&("M->"+x3_campo) := CriaVar(x3_campo)
		IF SX3->X3_VISUAL <> "V"
			Aadd(aAlter,SX3->X3_CAMPO)
		ENDIF
	Endif
	dbSkip()
End

dbSelectArea("VDS")
ADHeadRec("VDS",aHeader)
nUsado := Len(aHeader)

aCols:={}
dbSelectArea("VDS")
dbSetOrder(2)
dbSeek(xFilial("VDS")+M->VS0_TIPASS+M->VS0_CODMOT)

If nOpc == 3 .Or. !Found()
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VDS"
		Else
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		EndIf
	Next
Else
	While !eof() .and. VDS->VDS_FILIAL == xFilial("VDS") .and. VDS->VDS_TIPASS+VDS->VDS_CODMOT == M->VS0_TIPASS+M->VS0_CODMOT
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			&& verifica se e a coluna de controle do walk-thru
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := VDS->(RecNo())
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VDS"
			Else
				aCols[Len(aCols),_ni] := IIf(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
			EndIf
		Next
		aCols[Len(aCols),nUsado+1] := .F.
		dbSkip()
	End
	nLenaCols := Len(aCols)
Endif

If Len(aCols)>0
	//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
	//� Executa a Modelo 3                                           �
	//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
	cTitulo       := STR0001 // Motivos
	cAliasEnchoice:= "VS0"
	cAliasGetD    := "VDS"
	cLinOk        := "FG_OBRIGAT()"
	cFieldOk      := "FG_MEMVAR().and.OFA210FOK()"
	//
	FM_Mod3(cTitulo,cAliasEnchoice,cAliasGetD,@aCpoEnchoice,,@aHeader,@aCols,cFieldOk,cLinOk,,,nOpcE,nOpcG,,oMainWnd,@oAuxDlg,@oAuxEnchoice,@oAuxGetDados,,,,,,,,30,aAlter)
	oAuxGetDados:oBrowse:bDelete := {|| OFA210DEL() }
	/////////////////////////////////////////////////////////////
	ACTIVATE MSDIALOG oAuxDlg ON INIT EnchoiceBar(oAuxDlg,{|| IIf(OFA210TOK().and.OFA210GRV(nOpcG),oAuxDlg:End(),.f.) },{|| oAuxDlg:End() })
Endif

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OFA210TOK� Autor � Andre Luis Almeida    � Data � 04/12/13 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Tudo Ok janela                                             咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFA210TOK()
Local lRet        := .t.
Local ni          := 0
Local aVetValid   := {}
Local nTamSeq     := TamSX3("VDS_CPOSEQ")[1]
Local nVDS_CPOSEQ := FG_POSVAR("VDS_CPOSEQ")
Local nVDS_CPOCOD := FG_POSVAR("VDS_CPOCOD")
For ni := 1 to Len(aCpoEnchoice) // Verifica campos obrigatorios
	If X3Obrigat(aCpoEnchoice[ni]) .and. Empty(&("M->"+aCpoEnchoice[ni]))
		Help(" ",1,"OBRIGAT",,RetTitle(aCpoEnchoice[ni])+space(50),3,0 )
		lRet := .f.
		Exit
	EndIf
Next
For ni := 1 to len(oAuxGetDados:aCols)
	If Empty(oAuxGetDados:aCols[ni,nVDS_CPOSEQ])
		oAuxGetDados:aCols[ni,nVDS_CPOSEQ] := strzero(ni,nTamSeq)
	EndIf
	If oAuxGetDados:aCols[ni,Len(oAuxGetDados:aCols[ni])] .and. !Empty(oAuxGetDados:aCols[ni,nVDS_CPOCOD])
		Aadd(aVetValid, { "VDT" , "VDT_CPOCOD" , oAuxGetDados:aCols[ni,nVDS_CPOCOD]  , NIL } )
	EndIf
Next
If len(aVetValid) > 0
	If !FG_DELETA(aVetValid)
		lRet := .f.
	EndIf
EndIf
oAuxGetDados:Refresh()
Return(lRet)

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OFA210FOK� Autor � Andre Luis Almeida    � Data � 04/12/13 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � FieldOk                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFA210FOK(cRVar)
Default cRVar := ReadVar()
If cRVar == "M->VDS_CPOSEQ"
	M->VDS_CPOSEQ := oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDS_CPOSEQ")] := strzero(Val(M->VDS_CPOSEQ),TamSX3("VDS_CPOSEQ")[1])
ElseIf cRVar == "M->VDS_CPOTIP"
	If M->VDS_CPOTIP == "C"
		M->VDS_CPOPIC := "@!"
	ElseIf M->VDS_CPOTIP == "N"
		M->VDS_CPOPIC := left("@E "+repl("9",M->VDS_CPOTAM)+space(20),20)
	ElseIf M->VDS_CPOTIP == "D"
		M->VDS_CPOPIC := "@D"
		M->VDS_CPOTAM := oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDS_CPOTAM")] := 8
	EndIf
	oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDS_CPOPIC")] := M->VDS_CPOPIC
ElseIf cRVar == "M->VDS_CPOTAM"
	If M->VDS_CPOTIP == "N"
		OFA210FOK("M->VDS_CPOTIP") // Alterar Mascara do campo Numerico
	EndIf
EndIf
Return(.t.)

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � OFA210GRV� Autor � Andre Luis Almeida    � Data � 04/12/13 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Gravacao                                                   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFA210GRV(nOpc)
Local ix1 := 0
Private lMsHelpAuto := .t., lMsFinalAuto := .f.
//
If nOpc == 3 .or. nOpc == 4 // Incluir / Alterar
//
	Inclui := .f.
	Altera := .f.
	If nOpc == 3
		Inclui := .t.
	ElseIf nOpc == 4
		Altera := .t.
	EndIf
	Begin Transaction
	dbSelectArea("VS0")
	dbSetOrder(1)
	dbSeek(xFilial("VS0")+M->VS0_TIPASS+M->VS0_CODMOT)
	If Inclui .or. Altera
		RecLock("VS0",!Found())
		FG_GRAVAR("VS0")
		MsUnlock()
	EndIf
	For ix1 := 1 to len(oAuxGetDados:aCols)
		If !Empty(oAuxGetDados:aCols[ix1,FG_POSVAR("VDS_CPOCOD")]) .or. !Empty(oAuxGetDados:aCols[ix1,FG_POSVAR("VDS_CPOTIT")])
			If !oAuxGetDados:aCols[ix1,Len(oAuxGetDados:aCols[ix1])] .and. Empty(oAuxGetDados:aCols[ix1,FG_POSVAR("VDS_CPOCOD")])
				oAuxGetDados:aCols[ix1,FG_POSVAR("VDS_CPOCOD")] := M->VDS_CPOCOD := GetSXENum("VDS","VDS_CPOCOD")
				ConfirmSX8()
			EndIf
			dbselectArea("VDS")
			dbSetOrder(1)
			dbseek(xFilial("VDS")+M->VS0_TIPASS+M->VS0_CODMOT+oAuxGetDados:aCols[ix1,FG_POSVAR("VDS_CPOCOD")])
			If Found() .and. oAuxGetDados:aCols[ix1,Len(oAuxGetDados:aCols[ix1])]
				RecLock("VDS",.F.,.T.)
				VDS->(dbDelete())
				MsUnLock()
			Else
				RecLock("VDS",!Found())
				FG_GRAVAR("VDS",oAuxGetDados:aCols,aHeader,ix1)
				VDS->VDS_FILIAL := xFilial("VDS")
				VDS->VDS_TIPASS := M->VS0_TIPASS
				VDS->VDS_CODMOT := M->VS0_CODMOT
				MsUnlock()
			EndIf
		EndIf
	Next
	End Transaction
	lMsHelpAuto := .f.
//
EndIf
//
Return( .t. )

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  � OFA210DEL� Autor � Andre Luis Almeida � Data �  04/12/13   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Descricao � Delete - necessario informar motivo e exclui da aCols      艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFA210DEL()
Local aVetValid := {}
Local lRet      := .t.
If !oAuxGetDados:aCols[oAuxGetDados:nAt,Len(oAuxGetDados:aCols[oAuxGetDados:nAt])] .and. !Empty(oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDS_CPOCOD")])
	Aadd(aVetValid, { "VDT" , "VDT_CPOCOD" , oAuxGetDados:aCols[oAuxGetDados:nAt,FG_POSVAR("VDS_CPOCOD")]  , NIL } )
	If !FG_DELETA(aVetValid)
		lRet := .f.
	EndIf
EndIf
If lRet
	oAuxGetDados:aCols[oAuxGetDados:nAt,Len(oAuxGetDados:aCols[oAuxGetDados:nAt])] := !oAuxGetDados:aCols[oAuxGetDados:nAt,Len(oAuxGetDados:aCols[oAuxGetDados:nAt])]
	oAuxGetDados:Refresh()
EndIf
Return()

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  � MenuDef  � Autor � Andre Luis Almeida � Data �  04/12/13   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Descricao � MenuDef monta aRotina                                      艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function MenuDef()
Local aRotina := {	{ STR0002 ,"axPesqui", 0 , 1 },; 	// Pesquisar
					{ STR0003 ,"OFA210V" , 0 , 2 },;	// Visualizar
					{ STR0004 ,"OFA210I" , 0 , 3 },;	// Incluir
					{ STR0005 ,"OFA210A" , 0 , 4 }} 	// Alterar
Return aRotina

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  � OFA210MOT� Autor � Andre Luis Almeida � Data �  05/12/13   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Descricao � Selecao dos Motivos e Questinario pelo Motivo              艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Parametros� cTpAssunto = Tipo de Assunto ( antigo cMotivo )            艮�
臼�          � cTipOri = Tipo de Origem:                                  艮�
臼�          �               1 - Atendimento                              艮�
臼�          �               2 - OS                                       艮�
臼�          �               3 - Agendamento                              艮�
臼�          �               4 - Orcamento                                艮�
臼�          �               5 - CEV                                      艮�
臼�          �               6 - Oportunidade                             艮�
臼�          �               7 - Comissao Fat.Direto                      艮�
臼�          �               8 - Bonus de veiculos                        艮�
臼�          �               9 - Venda Veic.Atacado			              艮�
臼�          �               A - Comissao Consorcio/Serguro/Serv.Diversos 艮�
臼�          �               B - Servi�os Especializados                  艮�
臼�          � cFilOri = Filial da Origem                                 艮�
臼�          � cCodOri = Codigo da Origem (Atendimento/OS/Orcamento/...)  艮�
臼�          � lGrava  = Grava Respostas ?                                艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Retorno   � aRet[1] = Codigo do Motivo                                 艮�
臼�          � aRet[2] = Descricao Motivo                                 艮�
臼�          � aRet[3] = Gera CEV ? ( .t. / .f. )                         艮�
臼�          � aRet[4] = Vetor com o Questionario do Motivo respondido    艮�
臼�          �     [4,n,1] = Pergunta (Titulo)                            艮�
臼�          �     [4,n,2] = Resposta                                     艮�
臼�          �     [4,n,3] = Codigo do Campo                              艮�
臼�          �     [4,n,4] = Tipo do Campo                                艮�
臼�          �     [4,n,5] = Tamanho do Campo                             艮�
臼�          �     [4,n,6] = Mascara do Campo ( Picture )                 艮�
臼�          �     [4,n,7] = Campo Obrigatorio ( 0-Nao / 1-Sim )          艮�
臼�          �     [4,n,8] = Resposta digitada ( 0-Nao / 1-Sim )          艮�
臼�          �     [4,n,9] = VDT RecNo()                                  艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFA210MOT(cTpAssunto,cTipOri,cFilOri,cCodOri,lGrava,cCancParc)
Local aObjects     := {} , aPos := {} , aInfo := {} 
Local aSizeHalf    := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local ni           := 0
Local lOkTela      := .f.
Local lTrazBranco  := GetNewPar("MV_MIL0176",.f.) // Tela de Motivos - trazer em branco para o usu�rio ser obrigado a selecionar um dos motivos? Caso contr�rio o primeiro motivo ser� default.
Local cMotivos     := ""
Local aMotivos     := {}
Local cQuery       := ""
Local cQAlSQL      := "ALIASSQL"
Local aRet         := {}
Private aQuestMot  := {} // Questionario do Motivo
Private oObr0      := LoadBitmap( GetResources() , "XNADA" )	// Nao Obrigatorio
Private oObr1      := LoadBitmap( GetResources() , "BR_AZUL" )	// Obrigatorio
Private oDig0      := LoadBitmap( GetResources() , "LBNO" )		// Nao Digitado
Private oDig1      := LoadBitmap( GetResources() , "LBTIK" )	// Digitado
Default cTpAssunto := ""
Default cTipOri    := ""
Default cFilOri    := ""
Default cCodOri    := ""
Default lGrava     := .t.
Default cCancParc  := "T"
//
If lTrazBranco
	aAdd(aMotivos,"") // Adiciona um registro em branco para obrigar o usuario a selecionar um motivo
EndIf
//
cQuery := "SELECT DISTINCT VS0_CODMOT , VS0_DESMOT FROM "+RetSqlName("VS0")+" WHERE VS0_FILIAL='"+xFilial("VS0")+"' AND VS0_TIPASS='"+cTpAssunto+"' AND D_E_L_E_T_=' ' ORDER BY VS0_DESMOT"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	aAdd(aMotivos,( cQAlSQL )->( VS0_CODMOT )+"="+( cQAlSQL )->( VS0_DESMOT ))
	If !lTrazBranco .and. Empty(cMotivos)
		cMotivos := ( cQAlSQL )->( VS0_CODMOT )
	EndIf
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( DbCloseArea() )
//
For ni := 1 to Len(aSizeHalf)
	aSizeHalf[ni] := INT(aSizeHalf[ni] * 0.8) // Fator de reducao 80%
Next   
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0, 20, .T. , .F. } ) // Motivo
AAdd( aObjects, { 0,  0, .T. , .T. } ) // ListBox
AAdd( aObjects, { 0, 12, .T. , .F. } ) // Legenda
aPos := MsObjSize( aInfo, aObjects )
//
FS_MOTIVOS(.f.,cTpAssunto,cMotivos)
//
SX5->(DbSetOrder(1))
SX5->(DbSeek(xFilial("SX5")+"VM"+cTpAssunto))
DEFINE MSDIALOG oOFA210Que TITLE ( STR0001+": "+SX5->X5_DESCRI ) FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Motivos
	oOFA210Que:lEscClose := .F.
	//
	@ aPos[1,1]+007,aPos[1,2] MSCOMBOBOX oMotivos VAR cMotivos SIZE aPos[1,4],10 ITEMS aMotivos OF oOFA210Que ON CHANGE FS_MOTIVOS(.t.,cTpAssunto,cMotivos) PIXEL COLOR CLR_BLUE WHEN ( len(aMotivos) > 1 )
	//
	@ aPos[2,1],aPos[2,2] LISTBOX oQuestMot FIELDS HEADER "",STR0006,STR0008,"" COLSIZES 10,135,(aPos[2,4]-165),10 SIZE aPos[2,4],aPos[2,3]-aPos[2,1]-2 OF oOFA210Que PIXEL ON DBLCLICK FS_CLICK(oQuestMot:nAt)
	oQuestMot:SetArray(aQuestMot)
	oQuestMot:bLine := { || { &("oDig"+aQuestMot[oQuestMot:nAt,8]) , aQuestMot[oQuestMot:nAt,1] , Transform(aQuestMot[oQuestMot:nAt,2],aQuestMot[oQuestMot:nAt,6]) , &("oObr"+aQuestMot[oQuestMot:nAt,7]) }}
	//
	@ aPos[3,1],aPos[3,2]+10 BITMAP oxTik RESOURCE "LBTIK" OF oOFA210Que NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPos[3,1],aPos[3,2]+19 SAY STR0012 SIZE 150,8 OF oOFA210Que PIXEL COLOR CLR_BLACK // Resposta Digitada
	//
	@ aPos[3,1],(aPos[3,4]/2)+10 BITMAP oxAzul RESOURCE "BR_AZUL" OF oOFA210Que NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPos[3,1],(aPos[3,4]/2)+19 SAY STR0013 SIZE 150,8 OF oOFA210Que PIXEL COLOR CLR_BLACK // Resposta Obrigatoria
	//
ACTIVATE MSDIALOG oOFA210Que CENTER ON INIT (EnchoiceBar(oOFA210Que,{|| IIf( FS_OKTELA(cMotivos) , ( lOkTela := .t. , oOFA210Que:End() ) , .t. ) },{ || oOFA210Que:End() },,))
DbSelectArea("VS0")
If lOkTela
	DbSetOrder(1)
	If DbSeek(xFilial("VS0")+cTpAssunto+cMotivos)
		If len(aQuestMot) == 1 .and. Empty(aQuestMot[1,1])
			aQuestMot[1,1] := "X" // Gravar um registro em Branco para possibilitar consulta
		EndIf
		If lGrava // Grava Arquivo    
			if FM_PILHA("OFIXA011") .or. FM_PILHA("OFIXA012") .or. FM_PILHA("OFIXA018")
				If MsgYesNo(STR0014)
					OX012MOT(cTpAssunto,cMotivos,cTipOri,cFilOri,cCodOri,aQuestMot,cCancParc)
    			Else
					OFA210VDT(cTpAssunto,cMotivos,cTipOri,cFilOri,cCodOri,aQuestMot)
				Endif	  
			Else
				OFA210VDT(cTpAssunto,cMotivos,cTipOri,cFilOri,cCodOri,aQuestMot)
			Endif	
		EndIf
		aRet := {cMotivos,VS0->VS0_DESMOT,(VS0->VS0_CRICEV=="1"),aQuestMot} // { Motivo, Descricao do Motivo, Gera CEV, { Questionario do Motivo } }
	EndIf
EndIf
//
Return(aRet) // { Motivo, Descricao do Motivo, Gera CEV, { Questionario do Motivo } }


/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  � OFA210VDT� Autor � Andre Luis Almeida � Data �  05/12/13   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Descricao � Gravar VDT                                                 艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Parametros� cTpAssunto = Tipo de Assunto ( antigo cMotivo )            艮�
臼�          � cMotivos   = Motivo                                        艮�
臼�          � cTipOri    = Tipo de Origem:                               艮�
臼�          �               1 - Atendimento                              艮�
臼�          �               2 - OS                                       艮�
臼�          �               3 - Agendamento                              艮�
臼�          �               4 - Orcamento                                艮�
臼�          �               5 - CEV                                      艮�
臼�          �               6 - Oportunidade                             艮�
臼�          �               7 - Comissao Fat.Direto			          艮�
臼�          �               8 - Bonus de Veiculos			              艮�
臼�          �               9 - Venda Veic.Atacado			              艮�
臼�          �               A - Comissao Consorcio/Serguro/Serv.Diversos 艮�
臼�          �               B - Servi�os Especializados                  艮�
臼�          � cFilOri = Filial da Origem                                 艮�
臼�          � cCodOri = Codigo da Origem (Atendimento/OS/Orcamento/...)  艮� 
臼�          � aQuestMot = Vetor com o questionario (Perguntas/Respostas) 艮� 
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFA210VDT(cTpAssunto,cMotivos,cTipOri,cFilOri,cCodOri,aQuestMot)
Local ni    := 0
Local cTime := Time()
cTime := substr(cTime,1,2)+substr(cTime,4,2)
For ni := 1 to len(aQuestMot)
	If !Empty(aQuestMot[ni,1])
		DbSelectArea("VDT")
		RecLock("VDT",.t.)
			VDT->VDT_FILIAL := xFilial("VDT")
			VDT->VDT_CODIGO := GetSXENum("VDT","VDT_CODIGO")
			VDT->VDT_TIPASS := cTpAssunto
			VDT->VDT_CODMOT := cMotivos
            VDT->VDT_CPOCOD := aQuestMot[ni,3]
			VDT->VDT_RESPOS := Transform(aQuestMot[ni,2],aQuestMot[ni,6])
			VDT->VDT_TIPORI := cTipOri // 1=Atendimento / 2=OS / 3=Agendamento / 4=Orcamento / 5=CEV / 6=Oportunidade / 7=Comissao Fat.Direto / 8=Bonus de Veiculos / 9=Venda Veic.Atacado / A=Comissao Consorcio/Serguro/Serv.Diversos / B=Servicos Especializados
			VDT->VDT_FILORI := cFilOri
			VDT->VDT_CODORI := cCodOri
			VDT->VDT_DATMOV := dDataBase
			VDT->VDT_HORMOV := cTime
			VDT->VDT_USUMOV := __cUserID
			ConfirmSX8()
		MsUnLock()
		aQuestMot[ni,9] := VDT->(RecNo())
	EndIf
Next
Return()


/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  � FS_OKTELA� Autor � Andre Luis Almeida � Data �  06/12/13   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Descricao � OK da TELA de Motivos -> validacoes                        艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function FS_OKTELA(cMotivos)
Local ni   := 0
Local lRet := .f.
If Empty(cMotivos)
	MsgStop(STR0010,STR0009) // Necessario informar um motivo. / Atencao
Else
	lRet := .t.
	For ni := 1 to len(aQuestMot)
		If aQuestMot[ni,7] == "1" .and. Empty(aQuestMot[ni,2])
			MsgStop(STR0011,STR0009) // Existe(m) pergunta(s) obrigatoria(s) nao preenchida(s). Favor revisar questionario. / Atencao
			lRet := .f.
			Exit
		EndIf
	Next
EndIf
Return(lRet)

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �FS_MOTIVOS� Autor � Andre Luis Almeida � Data �  05/12/13   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Descricao � Levanta Questionario do Motivo                             艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function FS_MOTIVOS(lRefresh,cTpAssunto,cMotivos)
Local cQuery       := ""
Local xResp        := ""
Local cQAlSQL      := "ALIASSQL"
//
aQuestMot  := {} // Questionario do Motivo
//
cQuery := "SELECT VDS_CPOTIT , VDS_CPOCOD , VDS_CPOTIP , VDS_CPOTAM , VDS_CPOPIC , VDS_CPOOBR "
cQuery += "FROM "+RetSqlName("VDS")+" WHERE VDS_FILIAL='"+xFilial("VDS")+"' AND VDS_TIPASS='"+cTpAssunto+"' AND VDS_CODMOT='"+cMotivos+"' AND D_E_L_E_T_=' ' ORDER BY VDS_CPOSEQ"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() )
	Do Case
		Case ( cQAlSQL )->( VDS_CPOTIP ) == "C" // Caracter
			xResp := space(( cQAlSQL )->( VDS_CPOTAM ))
		Case ( cQAlSQL )->( VDS_CPOTIP ) == "N" // Numerico
			xResp := 0
		Case ( cQAlSQL )->( VDS_CPOTIP ) == "D" // Data
			xResp := ctod("")
	EndCase
	aAdd(aQuestMot,{ ( cQAlSQL )->( VDS_CPOTIT ) , xResp , ( cQAlSQL )->( VDS_CPOCOD ) , ( cQAlSQL )->( VDS_CPOTIP ) , ( cQAlSQL )->( VDS_CPOTAM ) , ( cQAlSQL )->( VDS_CPOPIC ) , ( cQAlSQL )->( VDS_CPOOBR ) , "0" , 0 })
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( DbCloseArea() )
If len(aQuestMot) <= 0
	aAdd(aQuestMot,{ "" , "" , "" , "C" , 1 , "@!" , "0" , "0" , 0 })
EndIf
//
If lRefresh
	oQuestMot:nAt := 1
	oQuestMot:SetArray(aQuestMot)
	oQuestMot:bLine := { || { &("oDig"+aQuestMot[oQuestMot:nAt,8]) , aQuestMot[oQuestMot:nAt,1] , Transform(aQuestMot[oQuestMot:nAt,2],aQuestMot[oQuestMot:nAt,6]) , &("oObr"+aQuestMot[oQuestMot:nAt,7]) }}
	oQuestMot:Refresh()
EndIf
//
Return()

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  � FS_CLICK � Autor � Andre Luis Almeida � Data �  05/12/13   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Descricao � Duplo-Click no ListBox - Responder                         艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function FS_CLICK(nLinha)
Local aRet      := {}
Local aParamBox := {}
If !Empty(aQuestMot[nLinha,3])
	AADD(aParamBox,{1,STR0007,aQuestMot[nLinha,1],"@!","","",".F.",120,.f.}) // Pergunta
	AADD(aParamBox,{1,STR0008,aQuestMot[nLinha,2],aQuestMot[nLinha,6],"","",".T.",120,IIf(aQuestMot[nLinha,7]=="1",.t.,.f.)}) // Resposta
	If ParamBox(aParamBox,STR0006,@aRet,,,,,,,,.f.) // Questionario
		aQuestMot[nLinha,2] := aRet[2]
		If !Empty(aQuestMot[nLinha,2])
			aQuestMot[nLinha,8] := "1" // Digitado
		Else
			If aQuestMot[nLinha,7] == "0" // Nao Obrigatorio
				aQuestMot[nLinha,8] := "1" // Digitado
			Else
				aQuestMot[nLinha,8] := "0" // Nao Digitado
			EndIf
		EndIf
	EndIf
EndIf
Return()