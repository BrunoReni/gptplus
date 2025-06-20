// 浜様様様曜様様様様�
// � Versao � 02     �
// 藩様様様擁様様様様�
#include "Veivr030.ch"
#include "Protheus.ch"
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � VEIVR030 � Autor �  Manoel               � Data � 14/08/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Copia da Nota Fiscal de Entrada de Veiculos                咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe   �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Veiculos                                                   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VEIVR030

Local   aIndVVF    := {}
Private bFiltraBrw := {|| Nil}
Private cCadastro  := OemToAnsi(STR0003) //Copia da Nota Fiscal Entrada
Private aRotina    := MenuDef()
Inclui := .F.
nReg   := 0

dbSelectArea("VVF")
#IFDEF TOP
	set filter to
#ENDIF

cIndex    := CriaTrab(nil,.f.)
cCondicao := '!Empty(VVF->VVF_NUMNFI) .and. VVF->VVF_SITNFI == "1" .and. VVF->VVF_FORPRO == "1"'

bFiltraBrw := {|| FilBrowse("VVF",@aIndVVF,@cCondicao) }
Eval(bFiltraBrw)

mBrowse( 6, 1,22,75,"VVF")

#IFNDEF TOP
	If File(cIndex+OrdBagExt())
		fErase(cIndex+OrdBagExt())
	Endif
#ELSE
	dbSelectArea("VVF")
	Set Filter to
	dbClearFilter()
	aEval(aIndVVF,{|x| Ferase(x[1]+OrdBagExt())})
	dbsetOrder(1)
#ENDIF

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � VR030COP � Autor �  Manoel               � Data � 14/08/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Emite Copia da Nota Fiscal de Entrada de Veiculos          咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe   �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Veiculos                                                   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
FUNCTION VR030COP()
////////////////////
Local bCampo4           := { |nCPO| Field(nCPO) }
Local nCntFor,_ni  		:= 0
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)

dbSelectArea("SX3")
dbSeek("VVF")
While !Eof().and.(x3_arquivo=="VVF")
	wVar := "M->"+x3_campo
	IF !Alltrim(x3_campo) $ "VVF_NUMTRA#VVF_TRACPA"
		&wVar:= CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

if !Inclui
	RegToMemory("VVF",.f.)
	DbSelectArea("VVF")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo4,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Cria aHeader e aCols da GetDados                             �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
nUsado:=0
dbSelectArea("SX3")
dbSeek("VVG")
aHeader:={}
While !Eof().And.(x3_arquivo=="VVG")
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !Alltrim(x3_campo) $ [VVG_TRACPA/VVG_NUMTRA]
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
	Endif
	dbSkip()
End

nOpcE:=2
nOpcG:=2


Acols:={}
dbSelectArea("VVG")
dbSetOrder(1)
dbSeek(xFilial()+M->VVF_TRACPA)
While !eof() .and. VVG->VVG_FILIAL == xFilial("VVG") .and. M->VVF_TRACPA == VVG->VVG_TRACPA
	AADD(aCols,Array(nUsado+1))
	For _ni:=1 to nUsado
		aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
	Next
	aCols[Len(aCols),nUsado+1]:=.F.
	dbSkip()
EndDO

cTitulo    :=OemToAnsi(STR0003) //"Copia da Nota Fiscal Entrada"
cAliasEnch :="VVF"
cLinOk     :="FG_OBRIGAT"
cTudoOk     :="AllwaysTrue()"
cFieldOk   :="FG_MEMVAR()"

nOpca := 0
lVirtual := .f. //Iif(lVirtual==Nil,.F.,lVirtual)
nLinhas:= 99 //Iif(nLinhas==Nil,99,nLinhas)

aMyEncho     := {}
aAltEnchoice := {}
Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
nPosAnt:=9999,      nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0
cAlias2     := "VVG"

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 200 , .T., .F. } )  //Cabecalho
AAdd( aObjects, { 01, 200, .T. , .T. } )  //list box superior

aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL
EnChoice("VVF",nReg,nOpcE,,,,,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,2,,,,,,lVirtual)
oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",.T.,,,,nLinhas,cFieldOk)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||oDlg:End()})

if nOpca == 1
	_lRet := .t.
Else
	_lRet := .f.
Endif

DbSelectArea("VVF")
DbSetOrder(1)
if _lRet
	If ExistBlock("NFENTVEI")
		ExecBlock("NFENTVEI",.f.,.f.,{VVF->VVF_NUMNFI,VVF->VVF_SERNFI,VVF_CODFOR,VVF_LOJA})
	Endif
Endif

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � MenuDef  � Autor �  Manoel               � Data � 14/08/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Menu												          咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe   �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Veiculos                                                   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function MenuDef()
Local aRotina := {{OemToAnsi(STR0001),  "AxPesqui",0,1},; //Pesquisar
{OemToAnsi(STR0002), "VR030COP",0,2}}   //Emitir Copia
Return aRotina
