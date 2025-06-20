// 浜様様様曜様様様様�
// � Versao � 3      �
// 藩様様様擁様様様様�

#Include "VEICR550.CH"
#Include "PROTHEUS.CH"
#Include "FILEIO.CH"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � VEICR550 � Autor �  Fabio                � Data � 19/10/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Relacao do Consorciados                                    咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � (Veiculos)                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VEICR550
Local oReport
Local aArea := GetArea()

a := FG_FILSXB("BM2")

If FindFunction("TRepInUse") .and. TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	FS_VCR550R3()
EndIf
RestArea( aArea )
Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � ReportDef� Autor � Andre Luis Almeida    � Data � 28/06/06 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Relatorio usando o TReport                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function ReportDef()
Local oReport
Local oSection1
Local oCell

oReport := TReport():New("VEICR550",STR0001,"VCR550",{|oReport| VCR550IMP(oReport)})

oSection1 := TRSection():New(oReport,OemToAnsi("Secao 1"),{"VCC","SA1","VV2"})
TRCell():New(oSection1,"VCC_CODCLI","VCC",,,6)
TRCell():New(oSection1,"VCC_LOJA"  ,"VCC",,,2)
TRCell():New(oSection1,"A1_NOME"   ,"SA1",,,28)
TRCell():New(oSection1,"VCC_NOMCON","VCC",,,16)
TRCell():New(oSection1,"VCC_CODGRU","VCC")
TRCell():New(oSection1,"VCC_NUMCOT","VCC")
TRCell():New(oSection1,"VCC_CODMAR","VCC")
TRCell():New(oSection1,"VCC_MODVEI","VCC",,,13)
TRCell():New(oSection1,"VV2_DESMOD","VV2",,,22)
TRCell():New(oSection1,"VCC_DATVDA","VCC",,"@D")
TRCell():New(oSection1,"VCC_DATCTP","VCC",,"@D")
TRCell():New(oSection1,"VCC_SITCON",,,,,,{|| FS_VCR550VCC() })

TRPosition():New(oSection1,"SA1",1,{|| xFilial()+VCC->VCC_CODCLI+VCC->VCC_LOJA })
TRPosition():New(oSection1,"VV2",1,{|| xFilial()+VCC->VCC_CODMAR+VCC->VCC_MODVEI })

Return oReport

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � VCR550IMP� Autor � Andre Luis Almeida    � Data � 28/06/06 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Executa a impressao do relatorio do TReport                咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Oficina                                                    咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VCR550IMP(oReport)
Local oSection1 := oReport:Section(1)
Local cOpcao  := " "
PERGUNTE("VCR550",.F.)
If MV_PAR01 == 5 // Todas
	cOpcao := "0/1/2/3"
Else
	cOpcao := strzero(MV_PAR01-1,1)
EndIf
DbSelectArea("VCC")
DbSetOrder(1)
DbSeek(xFilial("VCC"))
oReport:SetMeter(RecCount())
oSection1:Init()
While !Eof() .and. !oReport:Cancel() .and. VCC_FILIAL == xFilial('VCC')
	oReport:IncMeter()
	If Empty( MV_PAR02 + MV_PAR03 ) .or. ( MV_PAR02 + MV_PAR03 == VCC->VCC_CODCLI + VCC->VCC_LOJA )
		If VCC->VCC_SITCON $ cOpcao
			oSection1:PrintLine()
		EndIf
	EndIf
	DbSelectArea("VCC")
	DbSkip()
EndDo
oSection1:Finish()
Return Nil

Static Function FS_VCR550VCC()
Local aStatus := {{STR0014,STR0015,STR0016,STR0017}}
Local cRet := ""
cRet := aStatus[1,Val(VCC->VCC_SITCON)+1]
Return(cRet)


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function FS_VCR550R3()

Private aReturn  := { OemToAnsi(STR0001), 1,OemToAnsi(STR0002), 2, 2, 2,,1 }

cTitulo:= STR0001
cAlias := "VCC"
cNomRel:= "VEICR550"
cPerg  := "VCR550"
cTitulo:= STR0001
cDesc1 := STR0001
cDesc2 := cDesc3 := ""
lHabil := .f.
wnRel  :=cTamanho:= "M"
nLin   := 1
NomeRel:= SetPrint(cAlias,cNomRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lHabil,,,cTamanho)

If nlastkey == 27
	Return
EndIf
Pergunte("VCR550",.F.)

SetDefault(aReturn,cAlias)

Set Printer to &NomeRel
Set Printer On
Set device to Printer

cbTxt   := Space(10)
cbCont  := 0
cString := "VC1"
Li      := 132
m_Pag   := 1
wnRel   := "VEICR550"
cTitulo := STR0001
cabec1  := STR0007+": "+If(MV_PAR01==1,STR0008,If(MV_PAR01==2,STR0009,If(MV_PAR01==3,STR0010,If(MV_PAR01==4,STR0011,STR0013))))
cabec2  := STR0012
nomeprog:="VEICR550"
tamanho :="M"
nCaracter:=15
aStatus := {{STR0014,STR0015,STR0016,STR0017}}
cOpcao  := " "
If MV_PAR01 == 5 // Todas
	cOpcao := "0/1/2/3"
Else
	cOpcao := strzero(MV_PAR01-1,1)
EndIf
nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
DbSelectArea("VCC")
DbSetOrder(1)
DbSeek(xFilial("VCC"))
Do While !Eof()
	If !Empty( MV_PAR02 + MV_PAR03 )
		If ( ( MV_PAR02 + MV_PAR03 ) # ( VCC->VCC_CODCLI + VCC->VCC_LOJA ) )
			DbSelectArea("VCC")
			DbSkip()
			Loop
		EndIf
	EndIf
	If VCC->VCC_SITCON $ cOpcao
		If nLin >= 58
			nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1
		EndIf
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+VCC->VCC_CODCLI+VCC->VCC_LOJA)
		DbSelectArea("VV2")
		DbSetOrder(1)
		DbSeek(xFilial("VV2")+VCC->VCC_CODMAR+VCC->VCC_MODVEI)
		@ nLin++,00 PSAY left(VCC->VCC_CODCLI+"-"+VCC->VCC_LOJA+" "+SA1->A1_NOME,34)+" "+left(VCC->VCC_NOMCON,16)+" "+VCC->VCC_CODGRU+" "+VCC->VCC_NUMCOT+" "+VCC->VCC_CODMAR+" "+left(VV2->VV2_MODVEI,13)+" "+left(VV2->VV2_DESMOD,22)+" "+Dtoc(VCC->VCC_DATVDA)+" "+Dtoc(VCC->VCC_DATCTP)+" "+If(Len(Dtoc(VCC->VCC_DATCTP))==10,aStatus[1,Val(VCC->VCC_SITCON)+1],Space(4)+aStatus[1,Val(VCC->VCC_SITCON)+1])
	EndIf
	DbSelectArea("VCC")
	DbSkip()
EndDo

Set Printer to
Set device to Screen
MS_FLUSH()
OurSpool(NomeRel)

Return
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
