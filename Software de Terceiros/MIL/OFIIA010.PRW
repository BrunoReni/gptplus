// 浜様様様曜様様様様�
// � Versao � 10     �      
// 藩様様様擁様様様様�
#INCLUDE "Ofiia010.ch"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � OFIIA010 � Autor �  Renata               � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Gravacao dos dados do retorno da garantia VW               咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe   �                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Integracao montadora x concessionaria                      咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFIIA010

Local cCond
Local cPerg := "OFIMAR"
Private aCampos := {}
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0004)   //"Importacao do retorno da Garantia //"Importacao do Retorno de Garantia da Fabrica"
Private cIndex, nIndex
Private cCodMar
Private lExcluiImp := .F.
Private cNumOsv := ""

DbSelectArea("VGA")
DbSetOrder(1)

ValidPerg(cPerg)

If !Pergunte(cPerg,.t.)
	Return
EndIf

cCodMar := MV_PAR01
c3DigOS := MV_PAR02

DbSelectArea("VI1")

/*
cIndex  := CriaTrab(nil,.f.)
cChave  := 'VI1_FILIAL+VI1_CODMAR'
cCond   := 'VI1->VI1_CODMAR==cCodMar'

IndRegua("VI1",cIndex,cChave,,cCond,STR0013) //"Filtrando!!"

DbSelectArea("VI1")
nIndVI1 := RetIndex("VI1")
#IFNDEF TOP
dbSetIndex(cIndex+ordBagExt())
#ENDIF
dbSetOrder(nIndVI1+1)
*/
cCond := "VI1_CODMAR='"+cCodMar+"'"

mBrowse( 6, 1,22,75,"VI1",,,,,,,,,,,,,,cCond)
/*
DbSelectArea("VI1")
RetIndex()
DbsetOrder(1)
#IFNDEF TOP
If File(cIndex+OrdBagExt())
fErase(cIndex+OrdBagExt())
Endif
#ENDIF
*/
Return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �IA010V    � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � visualiza os dados dos arquivos                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � AxVisual(cAlias,nReg,nOpc,aCampos)                         咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � Generico                                                   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function IA010V(cAlias,nReg,nOpc)

CPOIA010()
AxVisual(cAlias,nReg,nOpc,aCampos)

return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �IA010I    � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � chama a funcao fs_segmen, feito dessa forma por causa do   咳�
臼�          � termometro                                                 咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � IA010I(cAlias,nReg,nOpc)                                   咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � INTEGRACAO                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function IA010I(cAlias,nReg,nOpc)

lExcluiImp := .F.
If MsgYesNo(OemToAnsi(STR0015),OemToAnsi(STR0016))  //##"Exclui registros importados?"###"Atencao"
	lExcluiImp := .T.
EndIf

Processa({|| FS_SEGMEN()})

If lExcluiImp

	DbSelectArea("VI1")
	DbCloseArea()
	If ChkFile("VI1",.T.)
		Pack
		DbCloseArea()
	EndIf
	ChkFile("VI1",.F.)

EndIf

return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_SEGMEN � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Chama funcoes de gravacoes do VI1 (GARANTAIA) nos arquivos 咳�
臼�          � VGA/VG5                                                    咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � FS_SEGMEN()                                                咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_SEGMEN()

Private lRet := .t. , lMsHelpAuto := .t.

DbSelectArea("VI1")
dbseek(xFilial("VI1"))

ProcRegua( RecCount() )

Begin Transaction

Do While !Eof() .And. VI1->VI1_FILIAL == xFilial("VI1")

	cNumOsv := c3DigOS+Right(strzero(val(VI1->VI1_NUMOSV),8),5)

	If VI1->VI1_TIPREG = "FG0"       //SOL. OK
		FS_FG0()
	ElseIf VI1->VI1_TIPREG = "FG1"   //SOL. ERRO
		FS_FG1()
	ElseIf VI1->VI1_TIPREG = "FG2"   //CRE/DEB SOL.
		FS_FG2()
	ElseIf VI1->VI1_TIPREG = "FG3"   //CUPOM ERRO
		FS_FG3()
	ElseIf VI1->VI1_TIPREG = "FG4"   //CRE/DEB CUPOM
		FS_FG4()
	ElseIf VI1->VI1_TIPREG = "FG5"   //PECAS DE RETORNA PARA FABRICA
		FS_FG5()
	ElseIf VI1->VI1_TIPREG = "FGA"   //DEBITO/CREDITO DE SG
		FS_FGA()
	ElseIf VI1->VI1_TIPREG = "FGD"   //DEBITO/CREDITO DE SG
		FS_FGD()
	EndIf

	IncProc(OemtoAnsi(STR0005))    //"Gravando dados da garantia!!"

	DbSelectArea("VI1")
	DbSkip()

EndDo

End Transaction

If !lRet
	MostraErro()
EndIf

return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_FG0    � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Grava os dados dos registro FG0 do VI1 nos arquivos        咳�
臼�          � VGA/VG5                                                    咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � FS_FG0()                                                   咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_FG0()

If FG_SEEK("VGA","VI1->VI1_CODMAR+cNumOsv",1,.F.)

	If !RecLock("VGA",.F.)
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf

	VGA->VGA_DATRET := VI1->VI1_DATRET
	VGA->VGA_SITUAC := "00"
	//   VGA->VGA_DESSIT := OemtoAnsi(STR0006)   // //"GARANTIA SOLICITADA OK"
	VGA->VGA_DESSIT := VI1->VI1_MENSAG
	If Empty(VGA->VGA_DESSIT)
		VGA->VGA_DESSIT := OemtoAnsi(STR0006)
	EndIf
	MsUnlock()

	If lExcluiImp

		If !RecLock("VI1",.F.,.T.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf

		dbdelete()
		MsUnlock()
		WriteSx2("VI1")

	EndIf

EndIf

Return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_FG1    � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Grava os dados dos registro FG1 do VI1 nos arquivos        咳�
臼�          � VGA/VG5                                                    咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � FS_FG1()                                                   咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_FG1()

If FG_SEEK("VGA","VI1->VI1_CODMAR+cNumOsv",1,.F.)

	If !RecLock("VGA",.F.)
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf

	VGA->VGA_DATRET := VI1->VI1_DATRET
	VGA->VGA_SITUAC := "01"
	//   VGA->VGA_DESSIT := OemtoAnsi(STR0007)   //    //"GARANTIA SOLICITADA COM ERRO"
	VGA->VGA_DESSIT := STR0014+" "+VI1->VI1_CODMSG  //"SG COM ERRO" VI1->VI1_MENSAG
	MsUnlock()

	If lExcluiImp

		If !RecLock("VI1",.F.,.T.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf

		dbdelete()
		MsUnlock()
		WriteSx2("VI1")

	EndIf

EndIf

Return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_FG2    � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Grava os dados dos registro FG2 do VI1 nos arquivos        咳�
臼�          � VGA/VG5                                                    咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � FS_FG2()                                                   咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_FG2()

Local nServico := 0 , nAdicion := 0

if strzero(val(VI1->VI1_CODREG),2) = "03"        //CREDITO

	If FG_SEEK("VGA","VI1->VI1_CODMAR+cNumOsv",1,.F.)

		nAdicion := 0
		nServico := VGA->VGA_VALTPO

		FG_SEEK("VG5","VI1->VI1_CODMAR+cNumOsv",1,.F.)
		Do while VG5->(!Eof()) .and. cNumOsv == VG5->VG5_NUMOSV .and. VG5->VG5_FILIAL == xFilial("VG5")
			nAdicion := nAdicion + VG5->VG5_VALPEC
			VG5->(dbskip())
		Enddo

		If !RecLock("VGA",.F.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf

		VGA->VGA_VALCRE := VI1->VI1_VALPGT
		VGA->VGA_LANCRE := VI1->VI1_LANCTO
		VGA->VGA_DATCRE := VI1->VI1_DATLAN
		VGA->VGA_DATRET := VI1->VI1_DATRET
		VGA->VGA_SITUAC := "02"
		VGA->VGA_DESSIT := OemtoAnsi(STR0008)   //       //"CREDITO GARANTIA SOLICITADA"
		VGA->VGA_DIFPGT := VI1->VI1_VALPGT - (VGA->VGA_VALPEC + nAdicion + nServico)
		MsUnlock()

		If lExcluiImp

			If !RecLock("VI1",.F.,.T.)
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf

			dbdelete()
			MsUnlock()
			WriteSx2("VI1")

		endif

	endif

elseif strzero(val(VI1->VI1_CODREG),2) = "04"    //DEBITO

	if FG_SEEK("VGA","VI1->VI1_CODMAR+cNumOsv",1,.F.)

		nAdicion := 0

		FG_SEEK("VG5","VI1->VI1_CODMAR+cNumOsv",1,.F.)
		do while VG5->(!eof()) .and. cNumOsv == VG5->VG5_NUMOSV .and. VG5->VG5_FILIAL == xFilial("VG5")
			nAdicion := nAdicion + VG5->VG5_VALPEC
			VG5->(dbskip())
		enddo

		If !RecLock("VGA",.F.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf

		VGA->VGA_VALDEB := VI1->VI1_VALPGT
		VGA->VGA_LANDEB := VI1->VI1_LANCTO
		VGA->VGA_DATDEB := VI1->VI1_DATLAN
		VGA->VGA_DATRET := VI1->VI1_DATRET
		VGA->VGA_SITUAC := "03"
		VGA->VGA_DESSIT := OemtoAnsi(STR0009)   // //"DEBITO GARANTIA SOLICITADA"
		VGA->VGA_CODEST := VI1->VI1_CODEST
		VGA->VGA_DIFPGT := (VGA->VGA_VALCRE - VGA->VGA_VALDEB) - (VGA->VGA_VALPEC + nAdicion + VGA->VGA_VALTPO)
		MsUnlock()

		If lExcluiImp

			If !RecLock("VI1",.F.,.T.)
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf

			dbdelete()
			MsUnlock()
			WriteSx2("VI1")

		endif

	endif

endif

return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_FG3    � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Grava os dados dos registro FG3 do VI1 nos arquivos        咳�
臼�          � VGA/VG5                                                    咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � FS_FG3()                                                   咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_FG3()

if FG_SEEK("VGA","VI1->VI1_CODMAR+cNumOsv",1,.F.)

	If !RecLock("VGA",.F.)
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf

	VGA->VGA_DATRET := VI1->VI1_DATRET
	VGA->VGA_SITUAC := "04"
	VGA->VGA_DESSIT := OemtoAnsi(STR0010)+" "+VI1->VI1_CODERR  
	MsUnlock()

	If lExcluiImp

		If !RecLock("VI1",.F.,.T.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf

		dbdelete()
		MsUnlock()
		WriteSx2("VI1")

	endif

endif

return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_FG4    � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Grava os dados dos registro FG4 do VI1 nos arquivos        咳�
臼�          � VGA/VG5                                                    咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � FS_FG4()                                                   咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_FG4()

Local nServico := 0

if strzero(val(VI1->VI1_CODREG),2) = "05"        //CREDITO

	if FG_SEEK("VGA","VI1->VI1_CODMAR+cNumOsv",1,.F.) = .T.   //OS

		FG_SEEK("VV1","VGA->VGA_CHAINT",1,.F.)

		if VV1->VV1_CHASSI = VI1->VI1_CHASSI

			nServico := VGA->VGA_VALTPO

			If !RecLock("VGA",.F.)
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf

			VGA->VGA_VALCRE := VI1->VI1_VALPGT
			VGA->VGA_LANCRE := VI1->VI1_LANCTO
			VGA->VGA_DATCRE := VI1->VI1_DATLAN
			VGA->VGA_DATRET := VI1->VI1_DATRET
			VGA->VGA_SITUAC := "05"
			VGA->VGA_DESSIT := OemtoAnsi(STR0011)   // //"CREDITO GARANTIA CUPOM REVISAO"
			MsUnlock()

		else

			FS_CUPREP() //DN RESPONSAVEL NAO EXECUTANTE
			FS_VO5()    //GRAVA DATA DAS REVISOES

		endif

		If lExcluiImp

			If !RecLock("VI1",.F.,.T.)
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf

			dbdelete()
			MsUnlock()
			WriteSx2("VI1")

		endif

	endif

elseif strzero(val(VI1->VI1_CODREG),2) = "06"    //DEBITO

	if FG_SEEK("VGA","VI1->VI1_CODMAR+cNumOsv",1,.F.) = .T.   //os

		FG_SEEK("VV1","VGA->VGA_CHAINT",1,.F.)

		if VV1->VV1_CHASSI = VI1->VI1_CHASSI

			If !RecLock("VGA",.F.)
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf

			VGA->VGA_VALDEB := VI1->VI1_VALPGT
			VGA->VGA_LANDEB := VI1->VI1_LANCTO
			VGA->VGA_DATDEB := VI1->VI1_DATLAN
			VGA->VGA_DATRET := VI1->VI1_DATRET
			VGA->VGA_SITUAC := "06"
			VGA->VGA_DESSIT := OemtoAnsi(STR0012)   // //"DEBITO GARANTIA CUPOM REVISAO"
			VGA->VGA_CODEST := VI1->VI1_CODEST
			MsUnlock()

		else

			FS_CUPREP() //DN RESPONSAVEL NAO EXECUTANTE
			FS_VO5()    //GRAVA DATA DAS REVISOES

		endif

		If lExcluiImp

			If !RecLock("VI1",.F.,.T.)
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf

			dbdelete()
			MsUnlock()
			WriteSx2("VI1")

		endif

	endif

endif

return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_FG5    � Autor �Fabio                  � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Grava os dados dos registro FG4 do VI1 nos arquivos        咳�
臼�          � VGA/VG5                                                    咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � FS_FG5()                                                   咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_FG5()

if FG_SEEK("VGA","VI1->VI1_CODMAR+cNumOsv",1,.F.) = .T.   //OS

	FG_SEEK("VV1","VGA->VGA_CHAINT",1,.F.)

	DbSelectArea("VGA")

	If !RecLock("VGA",.F.)
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf

	If StrZero(Val(VI1->VI1_CODREG),2) = "06"        //DEBITO
		VGA->VGA_LANDEB := VI1->VI1_LANCTO
		//	   VGA->VGA_DATDEB := VIS->VIS_DATCRE
		VGA->VGA_DATDEB := VI1->VI1_DATLAN
	Else                                             //CREDITO
		VGA->VGA_LANCRE := VI1->VI1_LANCTO
		//	   VGA->VGA_DATCRE := VIS->VIS_DATCRE
		VGA->VGA_DATCRE := VI1->VI1_DATLAN
	EndIf

	//   VGA->VGA_DATLAN := VIS->VIS_DATLAN
	VGA->VGA_DATLAN := VI1->VI1_DATLAN
	VGA->VGA_DATRET := VI1->VI1_DATRET
	VGA->VGA_SITUAC := strzero(val(VI1->VI1_CODREG),2)
	MsUnlock()

	DbSelectArea("VE4")
	DbSetOrder(1)
	DbSeek( xFilial("VE4") + VI1->VI1_CODMAR )
	DbSelectArea("SB1")
	DbSetOrder(7)
	If DbSeek( xFilial("SB1") + VE4->VE4_GRUITE + VI1->VI1_CODITE )

		DbSelectArea("VG5")
		DbSetOrder(1)
		If DbSeek( xFilial("VG5") + VI1->VI1_CODMAR + cNumOsv + SB1->B1_COD )

			If !RecLock("VG5",.F.)
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf

			If StrZero(Val(VI1->VI1_CODREG),2) = "06"        //DEBITO
				VG5->VG5_LANDEB := VI1->VI1_LANCTO
				VG5->VG5_DATDEB := VI1->VI1_DATLAN
			Else                                             //CREDITO
				VG5->VG5_LANCRE := VI1->VI1_LANCTO
				VG5->VG5_DATCRE := VI1->VI1_DATLAN
			EndIf

			VG5->VG5_DATRET := VI1->VI1_DATRET
			MsUnlock()

		EndIf

	EndIf

	If lExcluiImp

		If !RecLock("VI1",.F.,.T.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf

		dbdelete()
		MsUnlock()
		WriteSx2("VI1")

	EndIf

EndIf

return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_FGA    � Autor �Fabio                  � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Grava os dados dos registro FGA do VI1 nos arquivos        咳�
臼�          � VGA/VG5                                                    咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � FS_FG5()                                                   咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_FGA()

if FG_SEEK("VGA","VI1->VI1_CODMAR+cNumOsv",1,.F.) = .T.   //OS

	FG_SEEK("VV1","VGA->VGA_CHAINT",1,.F.)

	DbSelectArea("VGA")

	If !RecLock("VGA",.F.)
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf

	If StrZero(Val(VI1->VI1_CODREG),2) = "06"        //DEBITO
		VGA->VGA_LANDEB := VI1->VI1_LANCTO
		VGA->VGA_DATDEB := VI1->VI1_DATLAN
		VGA->VGA_VALDEB := VI1->VI1_VALPGT
	Else                                             //CREDITO
		VGA->VGA_LANCRE := VI1->VI1_LANCTO
		VGA->VGA_DATCRE := VI1->VI1_DATLAN
		VGA->VGA_VALCRE := VI1->VI1_VALPGT
	EndIf
	MsUnlock()

	DbSelectArea("VE4")
	DbSetOrder(1)
	DbSeek( xFilial("VE4") + VI1->VI1_CODMAR )

	DbSelectArea("SB1")
	DbSetOrder(7)
	If DbSeek( xFilial("SB1") + VE4->VE4_GRUITE + VI1->VI1_CODITE )

		DbSelectArea("VG5")
		DbSetOrder(1)
		If DbSeek( xFilial("VG5") + VI1->VI1_CODMAR + cNumOsv + SB1->B1_COD )

			If !RecLock("VG5",.F.)
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf

			If StrZero(Val(VI1->VI1_CODREG),2) = "06"        //DEBITO
				VG5->VG5_LANDEB := VI1->VI1_LANCTO
				VG5->VG5_DATDEB := VI1->VI1_DATLAN
			Else	                                            //CREDITO
				VG5->VG5_LANCRE := VI1->VI1_LANCTO
				VG5->VG5_DATCRE := VI1->VI1_DATLAN
			EndIf
			MsUnlock()

		EndIf

	EndIf

	If lExcluiImp

		If !RecLock("VI1",.F.,.T.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf

		dbdelete()
		MsUnlock()
		WriteSx2("VI1")

	EndIf

EndIf

return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_FGD    � Autor �Fabio                  � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Grava os dados dos registro FGD do VI1 nos arquivos        咳�
臼�          � VGA/VG5                                                    咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � FS_FG5()                                                   咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_FGD()

DbSelectArea("VGA")
DbSetOrder(1)
If DbSeek( xFilial("VGA") + VI1->VI1_CODMAR + cNumOsv )

	DbSelectArea("VE4")
	DbSetOrder(1)
	DbSeek( xFilial("VE4") + VI1->VI1_CODMAR )

	If Val(VI1->VI1_DNEXEC) == Val(VE4->VE4_CODCON)

		DbSelectArea("VGA")

		If !RecLock("VGA", .f. )
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf

		VGA->VGA_DNEXEC := VI1->VI1_DNEXEC
		VGA->VGA_DNRESP := VI1->VI1_DNRESP

		If StrZero(Val(VI1->VI1_CODREG),2) == "06"        //DEBITO
			VGA->VGA_LANDEB := VI1->VI1_LANCTO
			VGA->VGA_DATDEB := VI1->VI1_DATLAN
			VGA->VGA_VALDEB := VI1->VI1_VALPGT
		Else                                             //CREDITO
			VGA->VGA_LANCRE := VI1->VI1_LANCTO
			VGA->VGA_DATCRE := VI1->VI1_DATLAN
			VGA->VGA_VALCRE := VI1->VI1_VALPGT
		EndIf

		VGA->VGA_DESSIT := VI1->VI1_MENSAG

		MsUnlock()

		If lExcluiImp

			If !RecLock("VI1",.F.,.T.)
				Help("  ",1,"REGNLOCK")
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf

			dbdelete()
			MsUnlock()
			WriteSx2("VI1")

		EndIf

	EndIf

EndIf

return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �CPOIA010  � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o �Pega os campos no SX3 para serem mostrados na visualizacao  咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � CPOIA010()                                                 咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function CPOIA010()

DbSelectArea("SX3")
dbgotop()
dbseek("VI1")
aCampos := {}

do While !eof() .and. x3_arquivo == "VI1"

	if X3USO(x3_usado) .And. cNivel>=x3_nivel   //.And. x3_campo $ [VI1_NUMOSV/VI1_NUMNFI/VI1_SERIEN/VI1_CHASSI/VI1_CODGAR/VI1_DESGAR/VI1_DESMAR/VI1_CODCLI/VI1_NOMCLI/VI1_ABEGAR/VI1_DATFEC/VI1_EXPGAR]
		aadd(aCampos,x3_campo)
	endif

	dbskip()

Enddo

DbSelectArea("VI1")

Return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_CUPREP � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Grava os dados do arquivo VI1 no arquivo VGB               咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � FS_CUPREP()                                                咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
FUNCTION FS_CUPREP()

If !RecLock("VGB",.T.)
	Help("  ",1,"REGNLOCK")
	lRet := .f.
	DisarmTransaction()
	Break
EndIf

VGB->VGB_FILIAL := xFilial("VGB")
VGB->VGB_NUMOSV := c3DigOS+Right(strzero(val(VI1->VI1_NUMOSV),8),5) //VI1->VI1_NUMOSV
VGB->VGB_TIPMOV := if(strzero(VAL(VI1->VI1_CODREG),2) = "05","C","D")
VGB->VGB_CODREV := strzero(val(VI1->VI1_CODREV),2)
VGB->VGB_CHASSI := VI1->VI1_CHASSI
VGB->VGB_LANCTO := VI1->VI1_LANCTO
VGB->VGB_DATMOV := VI1->VI1_DATLAN
VGB->VGB_VALLAN := VI1->VI1_VALPGT
VGB->VGB_CODMAR := VI1->VI1_CODMAR
MsUnlock()

return

/*
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    �FS_VO5    � Autor �Renata                 � Data � 25/11/99 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Grava os dados do arquivo VGA/VG5 no VO5                   咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Sintaxe e � FS_VO5                                                     咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Parametros�                                                            咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � integracao                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
FUNCTION FS_VO5()

FG_SEEK("VV1","VI1->VI1_CHASSI",2,.F.)

FG_SEEK("VGA","VI1->VI1_CODMAR+cNumOsv",1,.F.)

if FG_SEEK("VO5","VGA->VGA_CHAINT",1,.F.) = .T.

	if strzero(val(VI1->VI1_CODREV),2) $ "31/41/51"

		If !RecLock("VO5",.F.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf

		VO5->VO5_DATRV1 := VGA->VGA_ABEGAR
		VO5->VO5_DC_RV1 := if(strzero(val(VI1->VI1_CODREG),2) = "05","C","D")
		VO5->VO5_DTDCR1 := VI1->VI1_DATLAN
		MsUnlock()

	elseif strzero(val(VI1->VI1_CODREV),2) $ "32/42/52"

		If !RecLock("VO5",.F.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf

		VO5->VO5_DATRV2 := VGA->VGA_ABEGAR
		VO5->VO5_DC_RV2 := if(strzero(val(VI1->VI1_CODREG),2) = "05","C","D")
		VO5->VO5_DTDCR2 := VI1->VI1_DATLAN
		MsUnlock()

	elseif strzero(val(VI1->VI1_CODREV),2) $ "33/43/53"

		If !RecLock("VO5",.F.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf

		VO5->VO5_DATRV3 := VGA->VGA_ABEGAR
		VO5->VO5_DC_RV3 := if(strzero(val(VI1->VI1_CODREG),2) = "05","C","D")
		VO5->VO5_DTDCR3 := VI1->VI1_DATLAN
		MsUnlock()

	elseif strzero(val(VI1->VI1_CODREV),2) $ "34/44/54"

		If !RecLock("VO5",.F.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf

		VO5->VO5_DATRV4 := VGA->VGA_ABEGAR
		VO5->VO5_DC_RV4 := if(strzero(val(VI1->VI1_CODREG),2) = "05","C","D")
		VO5->VO5_DTDCR4 := VI1->VI1_DATLAN
		MsUnlock()

	endif

endif

return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Fun��o    �MenuDef     � Autor � Thiago		     � Data �  30/01/12   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Descri��o � Criacao do menu.											  艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Programa principal                                         艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},; //"Pesquisar"
{ STR0002 ,"IA010V"  , 0 , 2},;    //Vizualizar //"Visualizar"
{ STR0003 ,"IA010I"  , 0 , 3}}     //Importa //"Importar"
Return aRotina

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Fun��o    �VALIDPERG � Autor � Thiago		     � Data �  30/01/12   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Descri��o � Verifica a existencia das perguntas criando-as caso seja   艮�
臼�          � necessario (caso nao existam).                             艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼�Uso       � Programa principal                                         艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/

Static Function ValidPerg(cPerg)

Local _sAlias := ""
Local aRegs := {}
Local i,j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))

aAdd(aRegs,{cPerg,"01",STR0017,"","","mv_ch1","C",02,0,0,"G","FG_SEEK('VE1','MV_PAR01',1,.F.)","mv_par01","","","","","","","","","","","","","","","","","","","","","VE1","","","","",""})
Aadd(aRegs,{cPerg,"02",STR0018,"","","mv_ch2","C",03,0,0,"G","FG_STRZERO('MV_PAR02',3)","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

if Empty(_sAlias)
	_sAlias := alias()
Endif
dbSelectArea(_sAlias)

Return
