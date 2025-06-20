#include "Protheus.ch"
#include "TMSAI30.ch"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSAI30  � Autor � Richard Anderson      � Data � 22.11.06   ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Percentual de Pagto Frete CIF/FOB                            ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATMS                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function TMSAI30()

Private cCadastro	:= STR0001 //-- Percentual de Pagto Frete CIF/FOB 
Private aRotina		:= {{ STR0002  , "AxPesqui" , 0, 1 },; //"Pesquisar"
				          { STR0003  , "TMAI30Mnt" , 0, 2 },; //"Visualizar"
 				          { STR0004  , "TMAI30Mnt" , 0, 3 },; //"Incluir"
				          { STR0005  , "TMAI30Mnt" , 0, 4 },; //"Alterar"
				          { STR0006  , "TMAI30Mnt" , 0, 5 }}  //"Excluir"

dbSelectArea("DI6")
dbSetOrder(1)
dbGoTop()

mBrowse(06,01,22,75,"DI6")

Return Nil

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI30Mnt � Autor � Richard Anderson     � Data �22.11.2006 ���
��������������������������������������������������������������������������Ĵ��
���          � Interface do Cadastro de Percentual de Pagto Frete CIF/FOB  ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Alias da tabela                                      ���
���          � ExpN2: Numero do Registro                                   ���
���          � ExpN3: Opcao do aRotina                                     ���
��������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function TMAI30Mnt(cAlias, nReg, nOpcx)

Local nUsado    := 0
Local nOpcA     := 0
Local aAreaDI6  := DI6->(GetArea())

Local aGet      := {}
Local aPosObj   := {} 
Local aObjects  := {}
Local aSize     := MsAdvSize( .F. )             
Local nCntFor   := 0
Local aNoFields := {}
Local oDlg
Local aFldDI6	:= {}
Local nI		:= 0
Local lLGPD		:= FindFunction('FWPDCanUse') .And. FWPDCanUse(.T.) .And. FindFunction('TMLGPDCpPr')

Private aHeader := {}
Private aCols   := {} 
Private cCliRem := IIf(!Inclui,DI6->DI6_CLIREM,CriaVar("DI6_CLIREM"))
Private cLojRem := IIf(!Inclui,DI6->DI6_LOJREM,CriaVar("DI6_LOJREM"))
Private cNomRem := CriaVar("DI6_NOMREM")
Private oNomRem := {}
Private cCliDes := IIf(!Inclui,DI6->DI6_CLIDES,CriaVar("DI6_CLIDES"))
Private cLojDes := IIf(!Inclui,DI6->DI6_LOJDES,CriaVar("DI6_LOJDES"))
Private cNomDes := CriaVar("DI6_NOMDES")
Private oNomDes := {}

Private oGetD   := {}

Aadd(aNoFields,"DI6_CLIREM")
Aadd(aNoFields,"DI6_LOJREM")
Aadd(aNoFields,"DI6_NOMREM")
Aadd(aNoFields,"DI6_CLIDES")
Aadd(aNoFields,"DI6_LOJDES")
Aadd(aNoFields,"DI6_NOMDES")
 
aadd(aGet,{FWX3Titulo("DI6_CLIREM"),GetSX3Cache("DI6_CLIREM", "X3_PICTURE"),GetSX3Cache("DI6_CLIREM", "X3_F3")})
aadd(aGet,{FWX3Titulo("DI6_LOJREM"),GetSX3Cache("DI6_LOJREM", "X3_PICTURE"),GetSX3Cache("DI6_LOJREM", "X3_F3")})
aadd(aGet,{FWX3Titulo("DI6_CLIDES"),GetSX3Cache("DI6_CLIDES", "X3_PICTURE"),GetSX3Cache("DI6_CLIDES", "X3_F3")})  
aadd(aGet,{FWX3Titulo("DI6_LOJDES"),GetSX3Cache("DI6_LOJDES", "X3_PICTURE"),GetSX3Cache("DI6_LOJDES", "X3_F3")})

//��������������������������������������������������������������Ŀ
//� Monta o Array aHeader.                                       �
//����������������������������������������������������������������
aFldDI6 := ApBuildHeader("DI6", aNoFields)
For nI := 1 To Len(aFldDI6)
	nUsado += 1
	Aadd(aHeader, aFldDI6[nI])
Next

aSize(aFldDI6, 0)
aFldDI6 := Nil
	
//��������������������������������������������������������������Ŀ
//� Monta o Array aCols.                                         �
//����������������������������������������������������������������
If !Inclui
	DI6->(dbSetOrder(1))
	DI6->(dbSeek(xFilial("DI6")+cCliRem+cLojRem+cCliDes+cLojDes))
	While DI6->(!Eof()) .And. DI6->(DI6_FILIAL+DI6_CLIREM+DI6_LOJREM+DI6_CLIDES+DI6_LOJDES) == xFilial("DI6")+cCliRem+cLojRem+cCliDes+cLojDes
		Aadd(aCols,Array(nUsado+1))
		For nCntFor := 1 To nUsado
			If ( aHeader[nCntFor][10] != "V" )
				aCols[Len(aCols)][nCntFor] := DI6->(FieldGet(FieldPos(aHeader[nCntFor][2])))
			Else
				aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
			EndIf
		Next
		aCols[Len(aCols)][nUsado+1] := .F.

		If lLGPD
			If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"A1_NOME"} )) == 0		
				cNomRem := Replicate('*',TamSX3('A1_NOME')[1])
				cNomDes := Replicate('*',TamSX3('A1_NOME')[1])
			EndIf
		EndIf

		DI6->(dbSkip())
	Enddo
Else
	If Empty(aCols)
		Aadd(aCols,Array(nUsado+1))

		For nCntFor := 1 To nUsado
			aCols[1][nCntFor] := CriaVar(aHeader[nCntFor][2])
		Next nCntFor

		aCols[Len(aCols)][nUsado+1] := .F.
	EndIf
EndIf

If	Empty(GDFieldGet('DI6_ITEM',1))
	GDFieldPut('DI6_ITEM',StrZero(1,Len(DI6->DI6_ITEM)),1)
EndIf
		
AAdd( aObjects, { 100, 60, .T., .F. } )
AAdd( aObjects, { 100, 80, .T., .T. } )
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 } 
aPosObj := MsObjSize( aInfo, aObjects ) 
	
DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 to aSize[6],aSize[5] Of oMainWnd PIXEL

	@ 32,005 SAY   aGet[1][1] SIZE 50,7 OF oDlg PIXEL	
	@ 32,040 MSGET cCliRem    PICTURE aGet[1][2] F3 aGet[1][3] VALID TMAI30Vld() WHEN Inclui SIZE 0,7 OF oDlg PIXEL	
	@ 32,080 MSGET cLojRem    PICTURE aGet[2][2] VALID TMAI30Vld() WHEN Inclui SIZE 0,7 OF oDlg PIXEL	
	@ 32,095 MSGET oNomRem    VAR cNomRem PICTURE "@!"     WHEN .F. SIZE 120,7 OF oDlg PIXEL	
	
	@ 46,005 SAY   aGet[3][1] SIZE 50,7 OF oDlg PIXEL	
	@ 46,040 MSGET cCliDes    PICTURE aGet[3][2] F3 aGet[3][3] VALID TMAI30Vld() WHEN Inclui SIZE 0,7 OF oDlg PIXEL	
	@ 46,080 MSGET cLojDes    PICTURE aGet[4][2] VALID TMAI30Vld() WHEN Inclui SIZE 0,7 OF oDlg PIXEL	
	@ 46,095 MSGET oNomDes    VAR cNomDes PICTURE "@!"     WHEN .F. SIZE 120,7 OF oDlg PIXEL		

	oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"TMAI30LOk()","TMAI30TOk()","+DI6_ITEM",.T.,,,,99)
			
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1, If(oGetd:TudoOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()})			

If nOpcA == 1 .And. nOpcx <> 2
	Begin Transaction
		TMAI30Grv(nOpcx)
	End Transaction
EndIf	

RestArea(aAreaDI6)
	
Return NIL

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI30LOk � Autor � Richard Anderson     � Data �22.11.2006 ���
��������������������������������������������������������������������������Ĵ��
���          � Validacao de digitacao de linha                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function TMAI30LOk()
Local lRet   := .T.
Local nTPerc := 0
//-- Nao avalia linhas deletadas.
If	!GDDeleted( n )
   If lRet := MaCheckCols(aHeader,aCols,n)
	   //-- Analisa se ha itens duplicados na GetDados.
	   lRet := GDCheckKey( { 'DI6_CODPAS' }, 4 )
	EndIf   
	If lRet
		nTPerc := GDFieldGet('DI6_PERCIF')+GDFieldGet('DI6_PERFOB')
		If nTPerc <> 100
			MsgAlert(STR0007)
			lRet := .F.
		EndIf
	EndIf					
EndIf
Return(lRet)

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI30TOk � Autor � Richard Anderson     � Data �22.11.2006 ���
��������������������������������������������������������������������������Ĵ��
���          � Validacao de confirmacao para gravacao                      ���
��������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function TMAI30TOk()

Local lRet := .T.

//-- Analisa se os campos obrigatorios da GetDados foram informados.
If	lRet
	lRet := oGetD:ChkObrigat( n )
EndIf
//-- Analisa o linha ok.
If lRet
	lRet := TMAI30LOk()
EndIf

//-- Analisa se todas os itens da GetDados estao deletados.
If lRet .And. Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
	Help( ' ', 1, 'OBRIGAT2') //Um ou alguns campos obrigatorios nao foram preenchidos no Browse.
	lRet := .F.
EndIf
		
Return(lRet)

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI30Vld � Autor � Richard Anderson     � Data �19.03.2006 ���
��������������������������������������������������������������������������Ĵ��
���          � Validacao de digitacao de campos                            ���
��������������������������������������������������������������������������Ĵ��
���Uso       � EAL                                                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function TMAI30Vld(cCampo)

Local   lRet    := .T.
Local   lLGPD	:= ExistFunc('FWPDCanUse') .And. FWPDCanUse(.T.)
Default cCampo  := AllTrim(Upper(ReadVar()))

If "CCLIREM" $ cCampo .Or. "CLOJREM" $ cCampo
	lRet := ExistCpo("SA1",cCliRem+AllTrim(cLojRem),1) 
	If lRet .And. !Empty(cLojRem)
		If !Empty(cCliDes) .And. !Empty(cLojDes)
			lRet := ExistChav("DI6",cCliRem+cLojRem+cCliDes+cLojDes)
		EndIf
		If lRet
			If lLGPD 
				If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"A1_NOME"} )) > 0
					cNomRem := Posicione("SA1",1,xFilial("SA1")+cCliRem+cLojRem,"A1_NOME")
				Else
					cNomRem := Replicate('*',TamSX3('A1_NOME')[1])
				EndIf	
			Else	
				cNomRem := Posicione("SA1",1,xFilial("SA1")+cCliRem+cLojRem,"A1_NOME")
			EndIf	
			oNomRem:Refresh()
		EndIf
	EndIf
ElseIf "CCLIDES" $ cCampo .Or. "CLOJDES" $ cCampo
	lRet := ExistCpo("SA1",cCliDes+AllTrim(cLojDes),1) 
	If lRet .And. !Empty(cLojDes)
		If !Empty(cCliRem) .And. !Empty(cLojRem)
			lRet := ExistChav("DI6",cCliRem+cLojRem+cCliDes+cLojDes)
		EndIf
		If lRet
			If lLGPD
				If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"A1_NOME"} )) > 0
					cNomDes := Posicione("SA1",1,xFilial("SA1")+cCliDes+cLojDes,"A1_NOME")
				Else
					cNomDes := Replicate('*',TamSX3('A1_NOME')[1])
				EndIf
			Else
				cNomDes := Posicione("SA1",1,xFilial("SA1")+cCliDes+cLojDes,"A1_NOME")
			EndIf	
			oNomDes:Refresh()
		EndIf
	EndIf
ElseIf "DI6_CODPAS" $ cCampo
	lRet := ExistCpo("DT3",M->DI6_CODPAS,1)
	If lRet
		GDFieldPut('DI6_DESPAS',Posicione("DT3",1,xFilial("DT3")+M->DI6_CODPAS,"DT3_DESCRI"))
	EndIf		
	
ElseIf "DI6_PERCIF" $ cCampo
	lRet := (Positivo() .And. M->DI6_PERCIF <= 100)
	
ElseIf "DI6_PERFOB" $ cCampo
	lRet := (Positivo() .And. M->DI6_PERFOB <= 100)
EndIf
			
Return(lRet)

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � TMAI30Grv � Autor � Richard Anderson     � Data �22.11.2006 ���
��������������������������������������������������������������������������Ĵ��
���          � Gravacao                                                    ���
��������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function TMAI30Grv(nOpcx)

Local nI     := 0
Local nCnt   := 0
Local nUsado := Len(aHeader)

DI6->(dbSetOrder(1))

If nOpcx == 3 .Or. nOpcx == 4
	For nCnt := 1 To Len(aCols)
		If !GdDeleted(nCnt)
			If DI6->(!MsSeek(xFilial("DI6")+cCliRem+cLojRem+cCliDes+cLojDes+GdFieldGet("DI6_ITEM",nCnt)))
				RecLock("DI6",.T.)
				DI6->DI6_FILIAL := xFilial("DI6")
				DI6->DI6_CLIREM := cCliRem
				DI6->DI6_LOJREM := cLojRem
				DI6->DI6_CLIDES := cCliDes
				DI6->DI6_LOJDES := cLojDes
				DI6->DI6_ITEM   := GdFieldGet("DI6_ITEM",nCnt)
			Else
				RecLock("DI6",.F.)
			EndIf
			For nI := 1 To nUsado
				If aHeader[nI,10] != 'V'
					DI6->(FieldPut(FieldPos(aHeader[nI,2]),GDFieldGet(aHeader[nI,2],nCnt)))
				EndIf
			Next
			MsUnlock()
		ElseIf DI6->(MsSeek(xFilial("DI6")+cCliRem+cLojRem+cCliDes+cLojDes+GdFieldGet("DI6_ITEM",nCnt)))
			RecLock("DI6",.F.)
			dbDelete()
			MsUnLock()
		EndIf
	Next nCnt
ElseIf nOpcx == 5
	For nCnt := 1 To Len(aCols)
		If DI6->(MsSeek(xFilial("DI6")+cCliRem+cLojRem+cCliDes+cLojDes+GdFieldGet("DI6_ITEM",nCnt)))
			RecLock("DI6",.F.)
			dbDelete()
			MsUnLock()
		EndIf
	Next nCnt					
EndIf	
Return
