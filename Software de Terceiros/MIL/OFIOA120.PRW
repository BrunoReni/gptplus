// 浜様様様曜様様様様�
// � Versao � 10     �
// 藩様様様擁様様様様�

#include "OFIOA120.CH"
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � OFIOA120 � Autor �  Emilton              � Data � 19/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Mapas de Avaliacao                                         咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Generico  (Modelo3)                                        咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFIOA120()

Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0006) // Mapas de Avaliacao
Private nUsado := 0
Private cGruFor := "01/02/03"

/////////////////////////////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar os modulos de Veiculos, Oficina ou Auto-Pe�as //
/////////////////////////////////////////////////////////////////////////////////////////////////////
If !AMIIn(11,14,41) .or. !FMX_AMIIn({"OFIOA120"})
	Return()
EndIf

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Endereca a funcao de BROWSE                                  �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
DbSelectArea("VS5")
mBrowse( 6, 1,22,75,"VS5")

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �OFA120     �Autor  �Fabio/Emilton       � Data �  08/25/00   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Monta Tela                                                  艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFA120(cAlias,nReg,nOpc)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntTam := 0
//
Local bCampo   := { |nCPO| Field(nCPO) } , nCntFor := 0 , _ni := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Local nPosRec := 0
Private nLenAcols := 0

Private aTELA[0][0],aGETS[0]
Private aCpoEnchoice  :={} , aCols := {} , aHeader := {}

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Cria variaveis M->????? da Enchoice                          �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
//RegToMemory("VS5",.T.)

aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VS5")
While !Eof().and.(x3_arquivo=="VS5")
	If X3USO(x3_usado).and.cNivel >=x3_nivel
		AADD(aCpoEnchoice,x3_campo)
	Endif
	&("M->"+x3_campo) := CriaVar(x3_campo)
	DbSkip()
End
If !(Inclui)
	DbSelectArea("VS5")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

if nOpc == 3
	nOpcE := 3
	nOpcG := 3
Elseif nOpc == 4
	nOpcE := 4
	nOpcG := 4
Elseif nOpc == 2
	nOpcE := 2
	nOpcG := 2
Else
	nOpcE := 5
	nOpcG := 5
Endif

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Cria aHeader e aCols da GetDados                             �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
nUsado:=0
DbSelectArea("SX3")
DbSeek("VOQ")
aHeader:={}
While !Eof().And.(x3_arquivo=="VOQ")
	
	&& Levanta configuracao das colunas do browse
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !(Alltrim(x3_campo) $ [VOQ_CODMAP])
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		
		&("M->"+x3_campo) := CriaVar(x3_campo)
	Endif
	DbSkip()
End

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VOQ")
ADHeadRec("VOQ",aHeader)
// Posicao do registro
nPosRec:=Len(aHeader)
nUsado :=Len(aHeader)

DbSelectArea("VOQ")
DbSetOrder(1)
DbSeek(xFilial()+M->VS5_CODMAP)

If Inclui .Or. !(Found())
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VOQ"
		Else
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		EndIf
	Next
Else
	aCols:={}
	While !eof() .And. VOQ->VOQ_FILIAL == xFilial("VOQ") .And. VS5->VS5_CODMAP == VOQ->VOQ_CODMAP
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := VOQ->(RecNo())
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VOQ"
			Else
				aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
			EndIf
		Next
		aCols[Len(aCols),nUsado+1]:=.F.
		DbSkip()
	End
	nLenaCols     := Len(aCols)
Endif

If Len(aCols)>0
	//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
	//� Executa a Modelo 3                                           �
	//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
	cTitulo       :=STR0006
	cAliasEnchoice:="VS5"
	cAliasGetD    :="VOQ"
	cLinOk        :="If( FS_VLCONTA() , OFA120LINOK() .and. FG_OBRIGAT() , .f. )"
	cTudOk        :="FS_VLFAIXA()"
	cFieldOk      :="FG_MEMVAR(),FS_VLDFAIXA()"
	
	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 05, 44 , .T. , .F. } ) 	//Enchoice
	AAdd( aObjects, { 01, 10 , .T. , .T. } )  	//Get Dados
	
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects,.F.)
	
	DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5]	of oMainWnd PIXEL
	
	EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{aPosObj[1,1]+002,aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.F.)
	oGetDados := MsGetDados():New(aPosObj[2,1]+002,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)
	oGetDados:oBrowse:bChange    := {|| FG_AALTER("VOQ",nLenaCols,oGetDados) }
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(if(len(aCols) == 1 .and.  acols[1,len(aCols[1])] == .f.,oGetDados:TudoOk(),.t.) .And.obrigatorio(aGets,aTela).And.FS_OA120GRA(nOpc),oDlg:End(),.f.) },{|| RollBackSx8(),oDlg:End() })
	
Endif

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �OFIOA120  �Autor  �Microsiga           � Data �  08/25/00   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Uso       � Gravacao                                                   艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function FS_OA120GRA(nOpc)

Private lMsHelpAuto := .t., lMsFinalAuto := .f.

If !FS_VALGRAOA120( nOpc , .t. )
	
	MostraErro()
	Return( .f. )
	
EndIf

Begin Transaction

FS_VALGRAOA120(nOpc)

End Transaction
lMsHelpAuto := .f.


Return( .t. )

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
臼浜様様様様用様様様様様様様曜様様様用様様様様様様様様様様僕様様用様様様様様様融臼
臼�Programa  �FS_VALGRAOA120 �Autor  �Emilton             � Data �  08/25/00   艮�
臼麺様様様様謡様様様様様様様擁様様様溶様様様様様様様様様様瞥様様溶様様様様様様郵臼
臼�Uso       � Validacao da Gravacao                                           艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕臼
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝
*/
Static Function FS_VALGRAOA120( nOpc , lValid )

Local lRet := .t. , i := 0 , aVetValid := {}
Private lMsHelpAuto := .t.

lValid := If( lValid == NIL , .f. , lValid )

If nOpc # 2
	
	DbSelectArea("VS5")
	
	If !lValid
		
		&& Grava arquivo pai
		If Inclui .or. Altera
			
			If !RecLock("VS5",If(Inclui,.T.,.F.))
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf
			
			FG_GRAVAR("VS5")
			MsUnlock()
			
			ConfirmSx8()
			
		EndIf
		
		&& grava arquivo filho
		for i:=1 to len(aCols)
			
			If i > nLenaCols .and. aCols[i,Len(aCols[i])]
				Loop
			EndIf
			
			DbSelectArea("VOQ")
			DbSetOrder(1)
			DbSeek(xFilial("VS5")+M->VS5_CODMAP+aCols[I,FG_POSVAR("VOQ_CLAAVA")])
			
			If (Inclui .or. Altera) .And. !aCols[i,len(aCols[i])]
				
				If !RecLock("VOQ", !Found() )
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				
				FG_GRAVAR("VOQ",aCols,aHeader,i)
				VOQ->VOQ_FILIAL := xFilial("VOQ")
				VOQ->VOQ_CODMAP := M->VS5_CODMAP
				MsUnlock()
				
			ElseIf Found()
				
				&& Deleta
				If !RecLock("VOQ",.F.,.T.)
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				DbDelete()
				MsUnlock()
				WriteSx2("VOQ")
			Endif
		Next
		
	EndIf
	
	// Exclui arquivo filho
	DbSelectArea("VS5")
	
	If !(Inclui .or. Altera)
		
		If lValid
			
			aVetValid := {}
			Aadd(aVetValid,{"VOI" , "VOI_CODMAP" , VS5->VS5_CODMAP  , NIL })
			Aadd(aVetValid,{"VOI" , "VOI_CDMPPC" , VS5->VS5_CODMAP  , NIL })
			Aadd(aVetValid,{"VOI" , "VOI_CDMPSV" , VS5->VS5_CODMAP  , NIL })
			
			If !FG_DELETA(aVetValid)
				Return( .f. )
			EndIf
			
		Else
			
			&& Deleta
			If !RecLock("VS5",.F.,.T.)
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf
			
			dbdelete()
			MsUnlock()
			WriteSx2("VS5")
			
		EndIf
		
	Endif
	
Endif

Return(lRet)

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �FS_VLCONTA�Autor  �Fabio               � Data �  02/21/01   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     � Valida se a conta ja foi informada                         艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_VLCONTA()

Local nReg    := 0
Local ix1     := 0
Local ix2     := 0

FG_MEMVAR()

For ix1 := 1 to len(aCols)
	
	If aCols[ix1,nUsado+1]
		loop
	EndIf
	ix2 ++
	
	If aCols[ix1,FG_POSVAR("VOQ_CLAAVA")] == M->VOQ_CLAAVA
		nReg ++
		If nReg > 1
			Help("  ",1,"EXISTCHAV")
			Return( .f. )
		EndIf
	Else
		Loop
	EndIf
	
Next

Return( .t. )

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
臼浜様様様様用様様様様様曜様様様用様様様様様様様様様様僕様様用様様様様様様融臼
臼�Programa  �FS_VLDFAIXA�Autor  �Andre               � Data �  05/10/01   艮�
臼麺様様様様謡様様様様様擁様様様溶様様様様様様様様様様瞥様様溶様様様様様様郵臼
臼�Desc.     � Valida se a FAIXA estao compativeis entre si                艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕臼
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝
*/
Function FS_VLDFAIXA()

Local lRet := .t.

if ReadVar() == "M->VOQ_PRIFAI"
	if !Empty(M->VOQ_SEGFAI)
		if M->VOQ_PRIFAI > M->VOQ_SEGFAI
			lRet := .f.
		Endif
	Endif
Endif

Return( lRet )
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �FS_VLFAIXA�Autor  �Fabio               � Data �  02/21/01   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     � Valida se a conta ja foi informada                         艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_VLFAIXA()

Local ix1     := 0

FG_MEMVAR()

For ix1 := 1 to len(aCols)
	
	If aCols[ix1,nUsado+1]
		loop
	EndIf
	If (aCols[ix1,FG_POSVAR("VOQ_PRIFAI")] + aCols[ix1,FG_POSVAR("VOQ_SEGFAI")]) == 0
		loop
	EndIf
	If aCols[ix1,FG_POSVAR("VOQ_PRIFAI")] >= aCols[ix1,FG_POSVAR("VOQ_SEGFAI")]
		Help("  ",1,"A120PRIFAI")
		Return( .f. )
	EndIf
Next

Return( .t. )

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �FS_VLDCOR �Autor  �Emilton             � Data �  05/10/01   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     � Valida se a COR   ja foi informada                         艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_VLDCOR()

Local lRet := .t.

Do Case
	Case ReadVar() == "M->VS5_PRICOR" .and. (M->VS5_PRICOR == M->VS5_SEGCOR .Or. M->VS5_PRICOR == M->VS5_TERCOR)
		Help("  ",1,"A120VALCOR")
		lRet := .f.
	Case ReadVar() == "M->VS5_SEGCOR" .and. (M->VS5_SEGCOR == M->VS5_PRICOR .Or. M->VS5_SEGCOR == M->VS5_TERCOR)
		Help("  ",1,"A120VALCOR")
		lRet := .f.
	Case ReadVar() == "M->VS5_TERCOR" .and. (M->VS5_TERCOR == M->VS5_SEGCOR .Or. M->VS5_TERCOR == M->VS5_PRICOR)
		Help("  ",1,"A120VALCOR")
		lRet := .f.
EndCase

Return( lRet )

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �FS_CTATOT �Autor  �Emilton             � Data �  05/10/01   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     � Valida se a conta totalizadora ja existe                   艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_CTATOT()

Local lRet := .f.
Local ix1  := 0

For ix1 := 1 to len(aCols)
	
	If aCols[ix1,nUsado+1]
		loop
	EndIf
	If M->VOQ_CTATOT == aCols[ix1,FG_POSVAR("VOQ_CLAAVA")]
		lRet := .t.
		Exit
	EndIf
	
Next

If !lRet
	Help("  ",1,"A120CTATOT")
EndIf

Return( lRet )

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �MenuDef   �Autor  �Emilton             � Data �  05/10/01   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     � Criacao do menu							                  艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function MenuDef()
Local aRotina := { 	{ STR0001 ,"axPesqui", 0 , 1},;   // Pesquisar
{ STR0002 ,"OFA120", 0 , 2},;   // Visualizar
{ STR0003 ,"OFA120", 0 , 3},;   // Incluir
{ STR0004 ,"OFA120", 0 , 4},;   // Alterar
{ STR0005 ,"OFA120", 0 , 5} }   // Excluir
Return aRotina

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
臼浜様様様様用様様様様様曜様様様用様様様様様様様様様様僕様様用様様様様様様融臼
臼�Programa  �OFA120LINOK�Autor  �Emilton             � Data �  05/10/01   艮�
臼麺様様様様謡様様様様様擁様様様溶様様様様様様様様様様瞥様様溶様様様様様様郵臼
臼�Desc.     � Validacao do linok	  					                   艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕臼
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝
*/
Function OFA120LINOK()

if aCols[n,FG_POSVAR("VOQ_ANASIN")] == "1"
	if Empty(aCols[n,FG_POSVAR("VOQ_CODIGO")])
		Help(" ",1,"OBRIGAT2",,RetTitle("VOQ_CODIGO"),4,1)
		Return .f.
	Endif
	if Empty(aCols[n,FG_POSVAR("VOQ_CODIMF")])
		Help(" ",1,"OBRIGAT2",,RetTitle("VOQ_CODIMF"),4,1)
		Return .f.
	endif
endif

return .t.
