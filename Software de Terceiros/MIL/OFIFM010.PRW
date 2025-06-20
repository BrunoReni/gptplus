// 浜様様様曜様様様様�
// � Versao � 12     �
// 藩様様様擁様様様様�

#INCLUDE "Ofifm010.ch"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � OFIFM010 � Autor �  Emilton              � Data � 17/02/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Digitacao de Kilometragens Rodadas                         咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe   �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Generico  (Modelo3)                                        咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFIFM010

Local aCores    := {{ 'VO5->VO5_VEIACO == "1"', 'ENABLE' },;	 // com acordo
{'VO5->VO5_VEIACO <> "1"', 'DISABLE'}}     // sem acordo

Private aRotina := MenuDef()

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Define o cabecalho da tela de atualizacoes                   �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
Private cCadastro := OemToAnsi(STR0006)   // //"Digitacao de Kilometragens Rodada"
Private nUsado    := 0

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Endereca a funcao de BROWSE                                  �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰

dbSelectArea("VO5")

mBrowse( 6, 1,22,75,"VO5",,,,,,aCores)

dbSelectArea("VO5")

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �FM010     �Autor  �Fabio               � Data �  10/10/00   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Monta Tela                                                  艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Oficina                                                    艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FM010(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor := 0 , _ni := 0
Local cTitulo, cAliasEnchoice, cAliasGetD, cLinOk, cTudOk, cFieldOk
Local aObjects := {}, aPosObj := {}, aInfo := {} // Vari�veis de controle da janela
Local aSizeAut := MsAdvSize(.T.) // Tamanho m�ximo da janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)

Private aTELA[0][0],aGETS[0]
Private aCols := {} , aHeader := {} , aCpoEnchoice  :={}
Private nLenAcols := 0

If nOpc == 3 // Quando for incluir trazer preenchido (dados do veiculo) na parte de cima da tela
	Altera := .t.
	Inclui := .f.
EndIf

DbSelectArea("VO5")

If bof() .And. eof()
	Help("  ",1,"SEMVEIACO")
	Return(.F.)
Endif

If VO5->VO5_VEIACO<>"1"
	Help(" ",1,"VEISEMACO")
	Return (.F.)
Endif

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Cria variaveis M->????? da Enchoice                          �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
RegToMemory("VO5",.t.)
DbSelectArea("VO5")

For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

if Inclui
	nOpcE := 2
	nOpcG := 3
elseif Altera
	nOpcE := 2
	nOpcG := 4
else
	nOpcE := 2
	nOpcG := 2
endif

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Cria aHeader e aCols da GetDados                             �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
nUsado:=0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VF4")
aHeader:={}
While !Eof().And.(x3_arquivo=="VF4")
	
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !(X3_CAMPO $ [VF4_CHAINT/VF4_CHASSI/VF4_PLAVEI/VF4_CODFRO/VF4_PROVEI/VF4_LOJPRO/VF4_NOMPRO])
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
	Endif
	
	&("M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
	
	dbSkip()
	
End

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VF4")
ADHeadRec("VF4",aHeader)
nUsado :=Len(aHeader)

dbSelectArea("VF4")
dbSetOrder(1)
dbSeek(xFilial()+VO5->VO5_CHAINT)

if nOpc == 3 .Or. !Found()
	
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	
	For _ni:=1 to nUsado
		&& verifica se e a coluna de controle do walk-thru
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VF4"
		Else
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		EndIf
	Next
	
Else
	
	aCols:={}
	
	While !eof() .and. VO5->VO5_CHAINT == VF4->VF4_CHAINT
		
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			&& verifica se e a coluna de controle do walk-thru
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := VF4->(RecNo())
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VF4"
			Else
				aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
			EndIf
		Next
		aCols[Len(aCols),nUsado+1]:=.F.
		dbSkip()
		
	End
	nLenaCols     := Len(aCols)
Endif

If Len(aCols)>0
	//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
	//� Executa a Modelo 3                                           �
	//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
	cTitulo       :=STR0006   //"Digitacao de Kilometragens Rodada"
	cAliasEnchoice:="VO5"
	cAliasGetD    :="VF4"
	cLinOk        :="FG_OBRIGAT()"
	cLinOk        :="If( FS_VLKMDIG() , FG_OBRIGAT() , .f. )"
	cTudOk        :="AllwaysTrue()"
	cFieldOk      :="AllwaysTrue()"
	aCpoEnchoice  :={}
	
	dbSelectArea("SX3")
	dbSeek("VO5")
	
	While !Eof().and.(x3_arquivo=="VO5")
		
		if X3USO(x3_usado).and.cNivel>=x3_nivel
			AADD(aCpoEnchoice,x3_campo)
		Endif
		
		dbSkip()
		
	End

	aObjects := {}
	AAdd(aObjects, {05, 130, .T. , .F.}) // Enchoice
	AAdd(aObjects, {01, 010, .T. , .T.}) // MsGetDados

	aInfo := {aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 2, 2}
	aPosObj := MsObjSize (aInfo, aObjects, .F.)

	DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL
	
	EnChoice(cAliasEnchoice, nReg, nOpcE,,,, aCpoEnchoice, {aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4]},, 3,,,,,, .F.)
	
	oGetDados := MsGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcG, cLinOk, cTudOk, "",;
		If(nOpcG > 2 .And. nOpcg < 5, .t., .f.),,,,, cFieldOk)
	
	oGetDados:oBrowse:bChange := {|| FG_AALTER("VF4", nLenaCols, oGetDados)}
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| If(oGetDados:TudoOk() .And. obrigatorio(aGets, aTela) .And. FS_GRAFM010(nOpc), oDlg:End(), .f.)}, {|| oDlg:End()})
Endif

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �FS_GRAFM01�Autor  �Fabio               � Data �  10/10/00   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Grava                                                       艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Oficina                                                    艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_GRAFM010(nOpc)

Local ix1 := 0
Private lMsHelpAuto := .t.  , lMsErroAuto := .f.

if nOpc # 2
	
	Begin Transaction
	
	for ix1:=1 to len(aCols)
		
		If !Empty( aCols[ ix1 , FG_POSVAR("VF4_NUMOSV")] ) .and. aCols[ ix1 , Len(aCols[ix1]) ]
			
			Help("  ",1,"KMUSADOOS")
			DisarmTransaction()
			Break
			
		EndIf
		
		If ix1 > nLenaCols .and. aCols[ix1,Len(aCols[ix1])]
			Loop
		EndIf
		
		dbselectArea("VV1")
		dbSetOrder(1)
		dbseek( xFilial("VV1") + VO5->VO5_CHAINT )
		
		dbselectArea("VF4")
		dbSetOrder(1)
		dbseek( xFilial("VF4") + VO5->VO5_CHAINT + dtos(aCols[ix1,FG_POSVAR("VF4_DATKIL")]) )
		
		if ( nOpc == 3 .Or. nOpc == 4 ) .And. !aCols[ ix1 , Len(aCols[ix1]) ]
			
			RecLock("VF4", !Found() )
			FG_GRAVAR("VF4",aCols,aHeader,ix1)
			VF4->VF4_FILIAL := xFilial("VF4")
			VF4->VF4_CHAINT := VO5->VO5_CHAINT
			VF4->VF4_PROVEI := VV1->VV1_PROATU
			VF4->VF4_LOJPRO := VV1->VV1_LJPATU
			MsUnlock()
			
		ElseIf Found()
			
			RecLock("VF4",.F.,.T.)
			dbdelete()
			MsUnlock()
			WriteSx2("VF4")
			
		Endif
		
	next
	
	End Transaction
	
Endif

If lMsErroAuto
	MostraErro()
EndIf

Return( !lMsErroAuto )

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �FS_NUMOSV �Autor  �Emilton/Fabio       � Data �  10/10/00   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     � When do km                                                 艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Oficina                                                    艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_NUMOSV()

If !Empty( aCols[ n , FG_POSVAR("VF4_NUMOSV")] )
	
	Help("  ",1,"KMUSADOOS")
	
	Return(.f.)
	
EndIf

Return(.t.)
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �FS_VLPLANO�Autor  �Fabio               � Data �  04/10/01   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     � Valida se a Opcional ja foi cadastrado                     艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Oficina                                                    艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_VLKMDIG()

Local nReg    := 0
Local ix1     := 0

FG_MEMVAR()

For ix1 := 1 to len(aCols)
	
	If aCols[ix1,nUsado+1]
		loop
	EndIf
	If aCols[ix1,FG_POSVAR("VF4_DATKIL")] == M->VF4_DATKIL
		nReg ++
		If nReg > 1
			Help("  ",1,"EXIDIGKIL")
			Return( .f. )
		EndIf
	Else
		Loop
	EndIf
	
Next

Return( .t. )

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �FM010LEG  �Autor  �Ricardo Farinelli   � Data �  12/17/01   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Legenda da Mbrowse                                          艮�
臼�          �                                                            艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Gestao de Concessionarias                                  艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/

Function FM010LEG()
Local aLegenda := { {"ENABLE",OemToAnsi(STR0007)},;
{"DISABLE",OemToAnsi(STR0008)}}

BrwLegenda(cCadastro,OemToAnsi(STR0009) ,aLegenda)

Return
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �MenuDef   �Autor  �Thiago			     � Data �  10/10/12   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Chamada do menu.							                  艮�
臼�          �                                                            艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Gestao de Concessionarias                                  艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0, 1},; 	//Pesquisar
{ STR0002 ,"FM010", 0 , 2},;   //VISUALIZAR
{ STR0003 ,"FM010", 0 , 3},;   //INCLUIR
{ STR0004 ,"FM010", 0 , 4},;  	//ALTERAR
{ STR0005 ,"FM010", 0 , 5},;   //ALTERAR
{OemtoAnsi(STR0010) ,"FM010PESQ", 0, 1 },;		// Pesquisa veiculo pelo chassi
{ STR0009,"FM010LEG" , 0 , 2, 0 , .f.} } //Legenda
Return aRotina
 
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �OFM010KIL �Autor  �Thiago			     � Data �  10/10/12   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Chamada na valida艫o do campo VF4_KILROD                    艮�
臼�          �                                                            艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Gestao de Concessionarias                                  艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFM010KIL()  
Local lAchou := .f.

dbSelectArea("VV1") 
dbSetOrder(1)
dbSeek(xFilial("VV1")+VO5->VO5_CHAINT)
dbSelectArea("VFA")                                                                                                    
dbSetOrder(1)
dbSeek(xFilial("VFA")+VV1->VV1_PROATU+VV1->VV1_LJPATU)     
While !Eof() .and. xFilial("VFA") == VFA->VFA_FILIAL .and. VV1->VV1_PROATU+VV1->VV1_LJPATU == VFA->VFA_CODCLI+VFA->VFA_LOJA
	if VFA->VFA_DATVAL >= M->VF4_DATKIL .and. M->VF4_KILROD <= VFA->VFA_KILFAI 
	   lAchou := .t.
	   Exit 
	Endif
    dbSelectArea("VFA")
    dbSkip()
Enddo 
if !lAchou          
	MsgInfo(STR0011)    
Endif
Return(lAchou)


/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �FM010PESQ �Autor  �Thiago              � Data �  02/12/14   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Pesquisa Chassi.                                            艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Oficina                                                    艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FM010PESQ(cAlias,nReg,nOpc)
nOpc := 1

OA010_LVEI()           

Return(.t.)