// 浜様様様曜様様様様�
// � Versao � 13     �
// 藩様様様擁様様様様�
#Include "VEICR501.CH"
#Include "fileio.ch"
#Include "protheus.ch"
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � VEICR501 � Autor � Andre Luis Almeida    � Data � 18/10/04 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Ficha de Contato  C E V   (Apenas os Dados do Cliente)     咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VEICR501()
Private cPerg := "VCR501"
Private cPRW  := "VEICR501"
Private cNomePRW := "VEICR501"

Private cFiltroVX5 := "033"

GeraX1V501( cPerg )

DbSelectArea("SX1")
DbSetOrder(1)
If Pergunte(cPerg,.t.)
	If !Empty(MV_PAR11)
		cNomePRW := Alltrim(MV_PAR11)
	EndIf
	cPRW := cNomePRW
	If File(__RELDIR+cNomePRW+".##R")
		Dele File &(__RELDIR+cNomePRW+".##R")
	EndIf
	Processa({|| FS_VEICR500(cPerg)})
	Set Printer to
	Set Device  to Screen
EndIf
Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳陳堕陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼� Funcao    �VEICR501TP � Autor � Andre Luis Almeida  � Data � 29/07/04 咳�
臼団陳陳陳陳陳田陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼� Descricao � Atualiza Pergunte: VCR501                                 咳�
臼青陳陳陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VEICR501TP()
Local lRet := .f.
Local cSX1Perg := PADR("VCR501", Len(SX1->X1_GRUPO))
If !Empty(MV_PAR01)
	DbSelectArea("VC5")
	DbSetOrder(1)
	If DbSeek( xFilial("VC5") + MV_PAR01 )
		lRet := .t.
		MV_PAR04 := VC5->VC5_QTDFIC // Quadro de Informacoes
		MV_PAR08 := VC5->VC5_QTDHIS // Qtde de Historicos a Relacionar
		MV_PAR09 := VC5->VC5_MESHIS // Meses de Historicos a Relacionar
		MV_PAR10 := VC5->VC5_HISDEP // Historicos dos Departamentos a Relacionar
		DbSelectArea("SX1")
		DbSetOrder(1)
		DbSeek(cSX1Perg+"04")
		RecLock("SX1",.f.)
		X1_CNT01 := VC5->VC5_QTDFIC
		MsUnlock()
	EndIf
EndIf
Return(lRet)

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳陳堕陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼� Funcao    � VEICR501V � Autor � Andre Luis Almeida  � Data � 29/07/04 咳�
臼団陳陳陳陳陳田陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼� Descricao � Chama VEICR500 para visualizacao / impressao do relatorio 咳�
臼青陳陳陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function VEICR501V(cCodCli,cLojCli,cTipAge)
Private cPerg := "VCR501"
Private cPRW  := "VEICR501"
cPerg := PADR(cPerg, Len(SX1->X1_GRUPO))
DbSelectArea("VC5")
DbSetOrder(1)
If DbSeek( xFilial("VC5") + cTipAge )
	MV_PAR01 := cTipAge         // Tipo de Agenda
	MV_PAR02 := cCodCli         // Codigo do Cliente
	MV_PAR03 := cLojCli         // Loja do Cliente
	MV_PAR04 := VC5->VC5_QTDFIC // Quadro de Informacoes
	MV_PAR05 := ""              // Nivel de Importancia
	MV_PAR06 := ""              // Segmento do Cliente
	MV_PAR07 := ""              // Regiao de Atuacao
	MV_PAR08 := VC5->VC5_QTDHIS // Qtde de Historicos a Relacionar
	MV_PAR09 := VC5->VC5_MESHIS // Meses de Historicos a Relacionar
	MV_PAR10 := VC5->VC5_HISDEP // Historicos dos Departamentos a Relacionar
	DbSelectArea("SX1")
	DbSetOrder(1)
	DbSeek(cPerg+"04")
	RecLock("SX1",.f.)
	X1_CNT01 := VC5->VC5_QTDFIC
	MsUnlock()
	DbSelectArea("SX1")
	DbSetOrder(1)
	DbSeek(cPerg+"01")
	RecLock("SX1",.f.)
	X1_CNT01 := cTipAge
	MsUnlock()
	DbSelectArea("SX1")
	DbSetOrder(1)
	DbSeek(cPerg+"02")
	RecLock("SX1",.f.)
	X1_CNT01 := cCodCli
	MsUnlock()
	DbSelectArea("SX1")
	DbSetOrder(1)
	DbSeek(cPerg+"03")
	RecLock("SX1",.f.)
	X1_CNT01 := cLojCli
	MsUnlock()
	Processa({|| FS_VEICR500(cPerg)})
EndIf
Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �GeraX1V501�Autor  �Antonio Carlos(Boby)� Data �  13/10/2009 艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     � Gera arquivo no SX1                                        艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function GeraX1V501( cPerg )
Local aArea    := GetArea()
Local aRegs    := {}
Local i        := 0
Local j        := 0
// Cria grupo de perguntas
cPerg := PADR(cPerg, Len(SX1->X1_GRUPO))
//0             1           2           3           4           5           6           7           8           9                                                  1                                                       2                                           3                                                4
//0             X1_GRUPO    X1_ORDEM    X1_PERGUNT  X1_PERSPA   X1_PERENG   X1_VARIAVL  X1_TIPO     X1_TAMANHO  X1_DECIMAL
//1 X1_PRESEL   X1_GSC      X1_VALID    X1_VAR01    X1_DEF01    X1_DEFSPA1  X1_DEFENG1  X1_CNT01    X1_VAR02    X1_DEF02
//2 X1_DEFSPA2  X1_DEFENG2  X1_CNT02    X1_VAR03    X1_DEF03    X1_DEFSPA3  X1_DEFENG3  X1_CNT03    X1_VAR04    X1_DEF04
//3 X1_DEFSPA4  X1_DEFENG4  X1_CNT04    X1_VAR05    X1_DEF05    X1_DEFSPA5  X1_DEFENG5  X1_CNT05    X1_F3       X1_PYME
//4 X1_GRPSXG   X1_HELP     X1_PICTURE  X1_IDFIL
//               1       2    3                                  4                                5                                6         7    8   9   0   1    2    3           4      5   6   7   8    9     0   1   2   3     4     5   6   7   8   9   0    1   2   3   4   5   6   7    8     9        0    1   2   3   4
AAdd( aRegs, { cPerg, "06", STR0001, STR0001, STR0001, "MV_CH6", "C", 06, 00, 00, "G", "", "MV_PAR06", "   ", "", "", "", "", "   ", "", "", "", "", "   ", "", "", "", "", "     ", "", "", "", "", "", "", "", "", "VX5", "N", "", "", "", "" } )
AAdd( aRegs, { cPerg, "12", STR0004, STR0004, STR0004, "MV_CHC", "C", 06, 00, 00, "G", 'vazio() .or. FG_SEEK("SA3","MV_PAR12",1,.f.)', "MV_PAR12", "   ", "", "", "", "", "   ", "", "", "", "", "   ", "", "", "", "", "     ", "", "", "", "", "", "", "", "", "SA3", "N", "", "", "", "" } )
DbSelectArea("SX1")
DbSetOrder(1)
For i := 1 To Len(aRegs)
	If !dbSeek(cPerg + aRegs[i,2])
		RecLock("SX1", .T.)
	Else
		RecLock("SX1", .F.)
	EndIf
	For j := 1 to FCount()
		If j <= Len(aRegs[i])
			FieldPut(j,aRegs[i,j])
		Endif
	Next
	MsUnlock()
Next
RestArea(aArea)
Return