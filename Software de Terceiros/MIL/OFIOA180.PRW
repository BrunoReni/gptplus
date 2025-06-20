 浜様様様曜様様様様�
// � Versao � 29     �
// 藩様様様擁様様様様�

#include "PROTHEUS.CH"
#include "OFIOA180.CH"

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � OFIOA180 � Autor � Emilton Miranda       � Data � 21/02/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Programa de Manutencao no Cadastro de Tecnicos             咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼�Uso       � Generico                                                   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFIOA180()
Private aCampos := {}
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0006) //Cadastro de Tecnicos
Private aButtons := {}

/////////////////////////////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar os modulos de Veiculos, Oficina ou Auto-Pe�as //
/////////////////////////////////////////////////////////////////////////////////////////////////////
If !AMIIn(11,14,41) .or. !FMX_AMIIn({"OFIOA180"})
	Return()
EndIf

DbSelectArea("VAI")

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Endereca a funcao de BROWSE                                  �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
aCores := {	{'Empty(VAI->VAI_DATDEM).or. VAI->VAI_DATDEM >= DDATABASE','BR_VERDE'},{'VAI->VAI_DATDEM < DDATABASE','BR_VERMELHO'}}
mBrowse( 6, 1,22,75,"VAI",,,,,,aCores)
Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Funcao    � LEGOA180     � Autor � ANDRE             � Data � 08/03/06 咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descricao � Legenda do browse                                          咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function LEGOA180()

Local aLegenda := {{'BR_VERDE'       ,STR0015},; //Tecnico Valido
{'BR_VERMELHO'    ,STR0016}}//Tecnico Demitido

BrwLegenda(cCadastro,STR0014 ,aLegenda) //Legenda

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �OA180V    �Autor  �Fabio               � Data �  08/30/00   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Visualiza                                                   艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OA180V(cAlias,nReg,nOpc)
If FindFunction("VX005F3RET")
	aButtons := { {"BAIXATIT",{|| M->VAI_NIVRET := VX005F3RET(nOpc,M->VAI_NIVRET) },STR0018} } //Nivel de Retorno
EndIf

CAMPOA180()

AxVisual(cAlias,nReg,nOpc,aCampos,,,,aButtons)
Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �OA180I    �Autor  �Fabio               � Data �  08/30/00   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Inclui                                                      艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OA180I(cAlias,nReg,nOpc)
If FindFunction("VX005F3RET")
	aButtons := { {"BAIXATIT",{|| M->VAI_NIVRET := VX005F3RET(nOpc,M->VAI_NIVRET) },STR0018} } //Nivel de Retorno
EndIf

CAMPOA180()

If AxInclui(cAlias,nReg,nOpc,aCampos,,,"FS_VALTEC('I')",,,aButtons) == 1
	FS_GRCONTPROD(VAI->VAI_CODTEC)
EndIf
Return .t.

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �OA180A    �Autor  �Fabio               � Data �  08/30/00   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Altera                                                      艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OA180A(cAlias,nReg,nOpc)
If FindFunction("VX005F3RET")
	aButtons := { {"BAIXATIT",{|| M->VAI_NIVRET := VX005F3RET(nOpc,M->VAI_NIVRET) },STR0018} } //Nivel de Retorno
EndIf

CAMPOA180()

If AxAltera(cAlias,nReg,nOpc,aCampos,,,,"FS_VALTEC('A')",,,aButtons) == 1
	FS_GRCONTPROD(VAI->VAI_CODTEC)
EndIf
Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �FS_VALTEC �Autor  �Andre Luis Almeida  � Data �  01/08/07   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Verifica Chave Primaria                                     艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_VALTEC(cTipo)
Local lRet := .t.
Local aSlv := GetArea()
Local nRecVAI := VAI->(RecNo())
Local nQtdVAI := 0 

If !Empty(M->VAI_CC)
	DbSelectArea("CTT")
	DbSetOrder(1)
	if DbSeek( xFilial("CTT") + M->VAI_CC )
		If CTT->CTT_BLOQ == "1"
			Help('   ',1,"CTA_BLOQ")
			Return(.f.)
		Endif
	Else
		Return(.f.)
	Endif
Endif

if ExistBlock("OA180VLD") // Ponto de Entrada retorna TRUE ou FALSE ao clicar em Confirmar.
	if !ExecBlock("OA180VLD",.f.,.f.)
		Return(.f.)
	Endif
Endif

If !Empty(M->VAI_CODTEC)
	If cTipo <> 'A' // Incluir (Diferente de 'A'lterar)
		DbSelectArea("VAI")
		DbSetOrder(1)
		if DbSeek(xFilial("VAI")+M->VAI_CODTEC)
			Aviso(STR0010,M->VAI_CODTEC+" "+STR0010,{STR0009}) //"Tecnico ja existe!!"###"OK"
			lRet := .f.
		Endif
	Else // Alterar
		DbSelectArea("VAI")
		DbSetOrder(1)
		DbSeek(xFilial("VAI")+M->VAI_CODTEC)
		Do While !Eof() .and. xFilial("VAI") == VAI->VAI_FILIAL .and. M->VAI_CODTEC == VAI->VAI_CODTEC
			If nRecVAI # VAI->(RecNo())
				nQtdVAI++
			EndIf
			DbSkip()
		EndDo
		If nQtdVAI > 0
			Aviso(STR0010,M->VAI_CODTEC+" "+STR0010,{STR0009}) //"Tecnico ja existe!!"###"OK"
			lRet := .f.
		EndIf
		DbGoTo(nRecVAI)
	EndIf
	RestArea(aSlv)
ElseIf !Empty(M->VAI_CODUSR)
	If cTipo <> 'A' // Incluir (Diferente de 'A'lterar)
		DbSelectArea("VAI")
		DbSetOrder(4)
		if DbSeek(xFilial("VAI")+M->VAI_CODUSR)
			Aviso(STR0007,STR0008,{STR0009}) //"Usuario ja existe!!"###"Usuario ja esta cadastrado como outro tecnico"###"OK"
			lRet := .f.
		Endif
		DbSelectArea("VAI")
		DbSetOrder(1)
	Else // Alterar
		DbSelectArea("VAI")
		DbSetOrder(4)
		DbSeek(xFilial("VAI")+M->VAI_CODUSR)
		Do While !Eof() .and. xFilial("VAI") == VAI->VAI_FILIAL .and. M->VAI_CODUSR == VAI->VAI_CODUSR
			If nRecVAI # VAI->(RecNo())
				nQtdVAI++
			EndIf
			DbSkip()
		EndDo
		If nQtdVAI > 0
			Aviso(STR0007,STR0008,{STR0009}) //"Usuario ja existe!!"###"Usuario ja esta cadastrado como outro tecnico"###"OK"
			lRet := .f.
		EndIf
		DbSelectArea("VAI")
		DbSetOrder(1)
		DbGoTo(nRecVAI)
	EndIf
	RestArea(aSlv)
EndIf
if VAI->(FieldPos("VAI_TIPTEC")) > 0
	if M->VAI_TIPTEC == "5" .and. M->VAI_FATBAL != "1"
		MsgInfo(STR0017,STR0011)//Usuarios Faturistas devem possuir permissao para faturar venda balcao. O campo sera atualizado automaticamente. # atencao
		M->VAI_FATBAL := "1"
	endif
endif
if VAI->(fieldpos('VAI_DATINC')) > 0
	if cTipo == 'I'
		M->VAI_DATINC := FGX_Timestamp()
	else
		M->VAI_DATALT := FGX_Timestamp()
	endif
endif
if VAI->(fieldpos('VAI_UUID')) > 0 .and. empty(M->VAI_UUID)
	M->VAI_UUID := FWUUIDV4(.t.)
endif
Return(lRet)

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �OA180E    �Autor  �Fabio               � Data �  08/30/00   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Exclui                                                      艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OA180E(cAlias,nReg,nOpc)
Local aVetValid := {}
Local cCODTEC := VAI->VAI_CODTEC

Aadd(aVetValid, {"VO3", "VO3_PROREQ" , VAI->VAI_CODTEC  , NIL } )
Aadd(aVetValid, {"VO4", 2 , VAI->VAI_CODTEC  , NIL } )
Aadd(aVetValid, {"VOC", 1 , VAI->VAI_CODTEC  , NIL } )
Aadd(aVetValid, {"VOE", 1 , VAI->VAI_CODTEC  , NIL } )
Aadd(aVetValid, {"VOW", 1 , VAI->VAI_CODTEC  , NIL } )

If FG_DELETA( aVetValid )
	If FindFunction("VX005F3RET")
		M->VAI_NIVRET := VAI->VAI_NIVRET
		aButtons := { {"BAIXATIT",{|| M->VAI_NIVRET := VX005F3RET(nOpc,M->VAI_NIVRET) },STR0018} } //Nivel de Retorno
	EndIf

	AxDeleta(cAlias,nReg,nOpc,,,aButtons)
EndIf
Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �CAMPOA180 �Autor  �Fabio               � Data �  08/30/00   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Monta aCampos (campos do VAI)                               艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function CAMPOA180()
dbSelectArea("SX3")
dbSetOrder(1)
dbseek("VAI02")
aCampos := {}
do While !eof() .and. x3_arquivo == "VAI"
	If X3USO(x3_usado).and.cNivel>=x3_nivel .And. !( Alltrim(x3_campo) $ [VAI_REGIAO])
		aadd(aCampos,x3_campo)
	EndIf
	DbSkip()
Enddo
DbSelectArea("VAI")
Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �FS_GRCONTP�Autor  �Fabio               � Data �  08/14/02   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �grava arquivo de controle                                   艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function FS_GRCONTPROD(cCodPro)
DbSelectArea("VAI")
DbSetOrder(1)
If DbSeek( xFilial("VAI") + cCodPro )
	DbSelectArea("VOF")
	DbSetOrder(2)
	DbSeek( xFilial("VOF") + cCodPro )
	If VAI->VAI_FUNPRO == "1"
		If !Found()
			dbSelectArea("VOF")
			RecLock("VOF",.t.)
			VOF_FILIAL := xFilial("VOF")
			VOF_FUNPRO := cCodPro
			VOF_SITBOX := "D"
			dbSelectArea("VAI")
		EndIf
	Else
		DbSelectArea("VOF")
		Do While !Eof() .And. VOF->VOF_FILIAL == xFilial("VOF") .And. VOF->VOF_FUNPRO == cCodPro
			RecLock("VOF",.F.,.T.)
			dbdelete()
			MsUnlock()
			WriteSx2("VOF")
			DbSelectArea("VOF")
			DbSkip()
		EndDo
	EndIf
EndIf
DbSelectArea("VAI")
Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �MenuDef	�Autor  �Fabio               � Data �  08/14/02   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Menu						                                  艮�
臼麺様様様様謡様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様恒�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function MenuDef()
Local aRotina := { { STR0001 ,"AxPesqui", 0 , 1} ,;     // Pesquisar
{ STR0002 ,"OA180V"  , 0 , 2}       ,;  // Visualizar
{ STR0003 ,"OA180I"  , 0 , 3}       ,;  // Incluir
{ STR0004 ,"OA180A"  , 0 , 4}       ,;  // Alterar
{ STR0020 ,"OA180D"  , 0 , 4}       ,;  // Duplicar Registro de T�cnico
{ STR0014 ,"LEGOA180", 0, 2 ,0,.f.} ,;  //LEGENDA
{ STR0005 ,"OA180E"  , 0 , 5        }}  // Excluir

Return aRotina

/*/
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �OA180_CPF � Autor � RAFAEL GONCALVES   � Data �  18/09/08   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Descricao � Valida a exixtencia do mesmo CPF no cadastro do VAI        艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
/*/
Function OA180_CPF()
Local cFilVAI := VAI->VAI_FILIAL
Local nRegVAI := VAI->(Recno())
Local lRet    := .t.
Local nCPF    := 1
M->VAI_CPF := left(M->VAI_CPF+space(11),len(VAI->VAI_CPF))
nCPF := len(M->VAI_CPF)
If ( M->VAI_CPF $ repl("1",nCPF)+"/"+repl("2",nCPF)+"/"+repl("3",nCPF)+"/"+repl("4",nCPF)+"/"+repl("5",nCPF)+"/"+repl("6",nCPF)+"/"+repl("7",nCPF)+"/"+repl("8",nCPF)+"/"+repl("9",nCPF)+"/"+repl("0",nCPF) )
	MsgStop(STR0013,STR0011)
	lRet := .f.
EndIf
If lRet
	DbSelectArea("VAI")
	DbGoTop()
	While !Eof()
		IF (nRegVAI <> VAI->(recno()).or.(Inclui))
			IF ((VAI->VAI_FILIAL == cFilVAI).and.(VAI->VAI_CPF == M->VAI_CPF))
				if !(MsgYesNo(STR0012+chr(13)+chr(10)+chr(13)+chr(10)+VAI->VAI_CODTEC+" - "+VAI->VAI_NOMTEC,STR0011))
					lRet := .F.      
					exit
				Endif
				//MsgStop(STR0012+chr(13)+chr(10)+chr(13)+chr(10)+VAI->VAI_CODTEC+" - "+VAI->VAI_NOMTEC,STR0011)
			endif
		endif
		DbSkip()
	enddo
	DbSelectArea("VAI")
	DbGoTo(nRegVAI)
EndIf
If lRet
	lRet := CGC(M->VAI_CPF)
EndIf
Return(lRet)

/*/
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �OA180_USR � Autor � RAFAEL GONCALVES   � Data �  18/10/10   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Descricao � Valida a exixtencia do mesmo codigo usuario no VAI.        艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
/*/
Function OA180_USR()
Local nQtdeVAI := 0
Local lRet     := .t.
nQtdeVAI := FM_SQL("SELECT COUNT(*) FROM " + RetSQLName("VAI") + " WHERE VAI_FILIAL='"+xFilial("VAI")+"' AND VAI_CODUSR='"+M->VAI_CODUSR+"' AND VAI_CODTEC<>'"+M->VAI_CODTEC+"' AND D_E_L_E_T_ = ' '")

If nQtdeVAI > 0
	lRet := .F.
	MsgAlert(STR0019) // Codigo do Usuario j� utilizado
ElseIf PswSeek(M->VAI_CODUSR)
	M->VAI_NOMUSU := PswRet(1)[1][2]
EndIf

Return(lRet)

/*/
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �OA180_VLD � Autor � Andre Luis Almeida � Data �  03/12/13   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Descricao � Validacao dos campos ( ReadVar )                           艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
/*/
Function OA180_VLD()
Local lRet := .t.
If ReadVar() == "M->VAI_VTLIAT"
	If !(M->VAI_VTLIAT $ "12")
		M->VAI_VABAON := "0"
	EndIf
EndIf
Return(lRet)

/*/
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �OA180CCTO � Autor � Thiago				  � Data �  23/02/16   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Descricao � Validacao centro de custo.				                       艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
/*/
Function OA180CCTO()
Local lRetorno := .t.

DbSelectArea("CTT")
DbSetOrder(1)
if DbSeek( xFilial("CTT") + M->VAI_CC )

	If CTT->CTT_BLOQ == "1"
		Help('   ',1,"CTA_BLOQ")
		lRetorno:=.F.
	Endif

Else
	lRetorno:=.F.
Endif

Return(lRetorno)

/*/{Protheus.doc} OA180D
Duplica Cadasdro do T�cnico
@author Manoel Filho
@since 23/11/2017
@version undefined
@param
@type function
/*/
Function OA180D(cAlias,nReg,nOpc)

Local oIHelp    := DMS_InterfaceHelper():New()
Local aObjects  := {}
Local nOpcEnc   := 0
Local lOk        := .f.
Local oStrHlp   := DMS_StringHelper():New()
Local oArrHlp   := DMS_ArrayHelper():New()
Local cCampos   := "VAI_CODTEC/VAI_NOMTEC/VAI_CODUSR/VAI_NOMUSU/VAI_EMAIL /VAI_CPF   /VAI_CODVEN/"
Local cCamposAdi:= GetNewPar("MV_MIL0112","")
Local aCamposAdi:= oStrHlp:StrtoKarr2(cCamposAdi, '/')
//
aCamposAdi := oArrHlp:Map(aCamposAdi, {|cCampo| padr(cCampo,10)  })
cCamposAdi := oArrHlp:Join(aCamposAdi, '/')
cCampos    := cCampos+cCamposADI
//
Private oArHelper    := Dms_ArrayHelper():New()
Private oSqlHelper   := Dms_SqlHelper():New()
//
//
DbSelectArea("VAI")
// CABEC ser� dividido conforme
aDivTela := { ;
	{ "SUPERIOR" ,  80, 120 , .T. , .F. } ,; // Enchoice
	{ "INFERIOR"  , 20, 30 , .T. , .T. } ; // GetDados
}
oOA180DefSize := oIHelp:CreateDefSize(.t., aDivTela)
oOA180DefSize:Process()

oIHelp:SetDefSize(oOA180DefSize)

oOA180Dialog  := oIHelp:CreateDialog(STR0020)
oIHelp:SetDialog(oOA180Dialog) // ACTIVATE
oIHelp:SetOwnerPvt("OA180D")

oIHelp:nOpc := 2
oIHelp:cAlias := cAlias
oIHelp:SetDefSize(oOA180DefSize, "SUPERIOR")
oIHelp:AddMGetTAB("VAI", { {"NAOMOSTRA" , cCampos } } )
RegToMemory("VAI")
oEnchParam1 := oIHelp:CreateMSMGet(.t., { {"VISUALIZA" , .T. } } )

oIHelp:Clean()
oIHelp:nOpc := 3
oIHelp:cAlias := cAlias
oIHelp:SetDefSize(oOA180DefSize, "INFERIOR")
oIHelp:AddHeaderTAB("VAI", { {"MOSTRA" , cCampos } , {"NAOMOSTRA" , "VAI_CODTEC/" }, { "WALKTHRU" , .T. } } )
oGetPecas := oIHelp:CreateNewGetDados("oGetPecas" , { ;
  { "OPERACAO" , GD_INSERT + GD_UPDATE + GD_DELETE       } })
//
ACTIVATE MSDIALOG oOA180Dialog CENTER ON INIT EnchoiceBar(oOA180Dialog,{|| lOk := OA180GrvDup(), oOA180Dialog:End()  },{||lOk := .f. , oOA180Dialog:End()} )
//
Return lOk

Static Function OA180GrvDup()
Local nCntFor   := 0
Local lGravar   := .f.
Local cMensagem := ""

Begin Transaction

DbSelectArea("VAI")

cMensagem := STR0021 // Registro duplicado com sucesso!
cMensagem += 'PULALINHA' + 'PULALINHA'
cMensagem += STR0022 // Os seguintes t�cnicos foram criados:
cMensagem += 'PULALINHA' + 'PULALINHA'
cMensagem += Alltrim(RetTitle("VAI_CODTEC")) + "      "
cMensagem += Alltrim(RetTitle("VAI_CPF")) + "        "
cMensagem += Alltrim(RetTitle("VAI_NOMTEC"))
cMensagem += 'PULALINHA'

For nCntFor := 1 to Len(oGetPecas:aCols)
	lGravar := .t.

	M->VAI_CODTEC := GetSXENum("VAI","VAI_CODTEC") // Manipula o M->VAI_CODTEC para grava艫o na FG_GRAVAR("VAI")
	ConfirmSX8()

	RecLock("VAI",.t.)
	FG_GRAVAR("VAI") // Grava os M-> (CreateMSMGet)
	FG_GRAVAR("VAI", oGetPecas:aCols, oGetPecas:aHeader, nCntFor) // Grava aCols (CreateNewGetDados)
	if VAI->(fieldpos('VAI_DATINC')) > 0
		VAI->VAI_DATINC := FGX_Timestamp()
	endif
	if VAI->(fieldpos('VAI_UUID')) > 0
		VAI->VAI_UUID := FWUUIDV4(.t.)
	endif
	MsUnlock()
	ConfirmSX8()

	// Mensagem completa da duplica艫o
	cMensagem += M->VAI_CODTEC + "      "
	cMensagem += Alltrim(oGetPecas:aCols[nCntFor,1]) + "      "
	cMensagem += Alltrim(oGetPecas:aCols[nCntFor,2])
	cMensagem += 'PULALINHA'
Next

If lGravar
	AVISO(STR0011, StrTran(cMensagem, 'PULALINHA', CHR(13) + CHR(10)), { "Ok" }, 3) // Aten艫o
EndIf

End Transaction

Return .t.

/*/
{Protheus.doc} OA180FTEC
Esta fun艫o retorna um TPanel para que seja poss�vel pesquisar t�cnicos de outras filiais quando a tabela VAI est� exclusiva.
@type   Function
@author Ot�vio Favarelli
@since  22/12/2019
@param  cOkFunc,	Caractere,	Cont�m a fun艫o que ir� retornar os dados para os campos. Sendo assim, determina a origem da chamada da fun艫o OA180FTEC.
@return	nil
/*/
Function OA180FTEC( cOkFunc )

	Local cRetFunc
	Local cQuery
	
	// Esta vari�vel cOkFunc � utilizada para armazenar a fun艫o que realizar� o preenchimento dos campos no retorno da consulta.
	// Al�m disso, a vari�vel � utilizada para diferenciarmos quem est� chamando esta fun艫o e assim tratarmos as informa苺es e o retorno.
	Default cOkFunc := "OA201SEL"	

	Private cFilTec		:= Space(TamSX3("VAI_FILIAL")[1])
	Private cCodTec		:= Space(TamSX3("VAI_CODTEC")[1])
	Private cNomTec		:= Space(TamSX3("VAI_NOMTEC")[1])
	Private cCPFTec		:= Space(TamSX3("VAI_CPF")[1])
	Private cVAIFilial
	Private cVAIFilNom
	//
	Private lVAIComp
	
	// Vamos verificar se a tabela VAI est� compartilhada ou n�o para tratarmos posteriormente atrav�s da vari�vel private lVAIComp
	lVAIComp 	:= .f.
	cVAIFilial	:= ""
	cVAIFilNom	:= ""

	DbSelectArea("VAI")

	cQuery := " SELECT "
	cQuery +=   " COUNT(DISTINCT VAI.VAI_FILIAL) "
	cQuery += " FROM "
	cQuery +=   RetSQLName("VAI") + " VAI "
	cQuery += " WHERE "
	cQuery +=   " VAI.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND VAI.VAI_DATDEM = ' ' " // Data de demiss�o em branco (funcion�rio ainda est� admitido)
	If FM_SQL(cQuery) <= 1
		lVAIComp	:= .t.
		If !Empty(VAI->VAI_FILIAL)
			cVAIFilial	:= VAI->VAI_FILIAL
			cVAIFilNom	:= FWFilialName( , VAI->VAI_FILIAL )
		EndIf
	EndIf
	
	oInterface := DMS_InterfaceHelper():New()
	oInterface:nOpc := 3
	oInterface:SetOwnerPvt("OA180FTEC")

	//Tamanho do Form Superior onde ficar�o as TGets
	oSizePrinc := oInterface:CreateDefSize( .t. , 											; // Tem EnchoiceBar?
												{											; // Array com o tamanho to objeto
													{ "LINHA1" , 100 , 070 , .T. , .F. } ,	; // C�digo Id, Tam Obj X, Tam Obj Y, Perm Dimensionar X, Perm Dimensionar Y
													{ "LINHA2" , 130 , 100 , .T. , .T. }  	; // C�digo Id, Tam Obj X, Tam Obj Y, Perm Dimensionar X, Perm Dimensionar Y
												} ,											; // aWorkArea
												  ,											; // nMargem (padr�o 2)
											)
	oSizePrinc:aMargins := { 0 , 2 , 0 , 0 }
	oSizePrinc:Process()

	oInterface:SetDefSize(oSizePrinc)
	oDlgOA180FTEC := oInterface:CreateDialog(STR0023)	// T�cnicos por Filial
	oInterface:SetDialog(oDlgOA180FTEC)

	// Tamanho da coluna do Form Inferior onde ficar�o as colunas / listas
	oSizeL2 := oInterface:CreateDefSize( .f. ,											; // Tem EnchoiceBar?
											{											; // Array com o tamanho to objeto
												{ "COLUNA1" , 040 , 100 , .T. , .T. } ,	; // C�digo Id, Tam Obj X, Tam Obj Y, Perm Dimensionar X, Perm Dimensionar Y
												{ "COLUNA2" , 060 , 100 , .T. , .T. }  	; // C�digo Id, Tam Obj X, Tam Obj Y, Perm Dimensionar X, Perm Dimensionar Y
											} ,											; // aWorkArea
											oSizePrinc:GetNextCallArea("LINHA2") ,		; // nMargem (padr�o 2)
										)
	
	oSizeL2:lLateral := .t.
	oSizeL2:Process()

	// Campos que ser�o apresentados no form superior
	oInterface:SetDialog( oDlgOA180FTEC )
	oInterface:SetDefSize(oSizePrinc,"LINHA1")
	oPanModel := oInterface:CreateTPanel()
	oInterface:SetDialog( oPanModel )

	// Campo - Get = Filial do T�cnico VAI_FILIAL
	oInterface:CreateTGet({													;
							{"NOMEOBJ","oGetFilTec"} ,						;
							{"LINHA",04} ,									;
							{"COLUNA",10} ,									;
							{"NOMEVAR","cFilTec"} ,							;
							{"LARGURA",40} ,								;
							{"READONLY",lVAIComp} ,							;
							{"PICTURE",X3Picture("VAI_FILIAL")} ,			;
							{"VALID","OA1800017_ValidaGet('"+cOkFunc+"')"},	;
							{"HASBUTTON",.f.} ,								;
							{"LABEL",STR0024} /* Filial do T�cnico */		;
							})

	// Campo - Get = C�digo do T�cnico VAI_CODTEC
	oInterface:CreateTGet({;
							{"NOMEOBJ","oGetCodTec"},						;
							{"LINHA",20},									;
							{"COLUNA",10},									;
							{"NOMEVAR","cCodTec"},							;
							{"LARGURA",20},									;
							{"READONLY",.f.},								;
							{"PICTURE",X3Picture("VAI_CODTEC")},			;
							{"VALID","OA1800017_ValidaGet('"+cOkFunc+"')"},	;
							{"HASBUTTON",.f.},								;
							{"LABEL",STR0025} /* C�digo do T�cnico */		;
							})

	// Campo - Get = Nome do T�cnico VAI_NOMTEC
	oInterface:CreateTGet({;
							{"NOMEOBJ","oGetNomTec"},						;
							{"LINHA",36},									;
							{"COLUNA",10},									;
							{"NOMEVAR","cNomTec"},							;
							{"LARGURA",145},								;
							{"READONLY",.f.},								;
							{"PICTURE",X3PICTURE("VAI_NOMTEC")},			;
							{"VALID","OA1800017_ValidaGet('"+cOkFunc+"')"},	;
							{"HASBUTTON",.f.},								;
							{"LABEL",STR0026} /* Nome do T�cnico */			;
							})

	// Campo - Get = CPF do T�cnico VAI_CPF
	oInterface:CreateTGet({;
							{"NOMEOBJ","oGetCPFTec"},						;
							{"LINHA",52},									;
							{"COLUNA",10},									;
							{"NOMEVAR","cCPFTec"},							;
							{"LARGURA",50},									;
							{"READONLY",.f.},								;
							{"PICTURE",X3PICTURE("VAI_CPF")},				;
							{"VALID","OA1800017_ValidaGet('"+cOkFunc+"')"},	;
							{"HASBUTTON",.f.},								;
							{"LABEL",STR0027} /* CPF do T�cnico */			;
							})

	// List box de Filiais que ser� apresentada no form inferior do lado esquerdo (COLUNA1)
	oInterface:SetDialog( oDlgOA180FTEC )
	oInterface:SetDefSize(oSizeL2,"COLUNA1")
	oPanFilTec := oInterface:CreateMGroup( { { "TEXTO" , STR0028 } })	// Filiais

	oInterface:Clean()
	oInterface:SetDialog( oPanFilTec )
	oInterface:AddColLBox( { { "X3" , "VAI_FILIAL" 		} } )
	oInterface:AddColLBox( { { "X3" , "VFG_NOMFIL" 	} } )

	oGetFiliaisTec := oInterface:CreateLBox("oGetFiliaisTec", {												;
														{"ALINHAMENTO",CONTROL_ALIGN_ALLCLIENT}		;
														} )
	oGetFiliaisTec:SetArray(OA1800027_LevantaFiliais(cOkFunc))

	// List box de T�cnicos que ser� apresentada no form inferior do lado direito (COLUNA2)
	oInterface:Clean()
	oInterface:SetDialog( oDlgOA180FTEC )
	oInterface:SetDefSize(oSizeL2,"COLUNA2")
	oPanTec := oInterface:CreateMGroup( { { "TEXTO" , STR0029 } })	// T�cnicos
	
	oInterface:Clean()
	oInterface:SetDialog( oPanTec )
	oInterface:AddColLBox( { { "X3" , "VAI_FILIAL" } } )
	oInterface:AddColLBox( { { "X3" , "VAI_CODTEC" } } )
	oInterface:AddColLBox( { { "X3" , "VAI_NOMTEC" } } )
	oInterface:AddColLBox( { { "X3" , "VAI_CPF" } } )

	cRetFunc := AllTrim(cOkFunc) + "( oGetDTec:aArray[oGetDTec:nAt,1], oGetDTec:aArray[oGetDTec:nAt,2], oGetDTec:aArray[oGetDTec:nAt,3] )"

	//Complemento das configura苺es do form inferior
	oGetDTec := oInterface:CreateLBox("oGetDTec", {											;
													{"ALINHAMENTO",CONTROL_ALIGN_ALLCLIENT}	;
													} )
	oGetDTec:SetArray(OA1800037_LevantaTecnicos(cOkFunc))
	oGetDTec:bLDblClick := 	{ || 					;
								IIf ( &(cRetFunc),	;
								oDlgOA180FTEC:End(),;
								.t. )				;
							}

	oGetFiliaisTec:bChange := { || oGetDTec:SetArray(OA1800037_LevantaTecnicos(cOkFunc)) , oGetDTec:Refresh()}

	ACTIVATE MSDIALOG oDlgOA180FTEC 									;
									ON INIT EnchoiceBar(oDlgOA180FTEC ,	;
									{ || IIf( &(cRetFunc) ,				;
										oDlgOA180FTEC:End() ,			;
										.f. )							;
									},									;
									{ || oDlgOA180FTEC:End() },,)

Return

/*/
{Protheus.doc} OA1800017_ValidaGet
Esta fun艫o realiza a valida艫o da get preenchida pelo usu�rio na consulta de filial por t�cnico denominada OA180FTEC.
@type   Static Function
@author Ot�vio Favarelli
@since  22/12/2019
@param  cOkFunc,	Caractere,	Cont�m a fun艫o que ir� retornar os dados para os campos. Sendo assim, determina a origem da chamada da fun艫o OA180FTEC.
@return	nil
/*/
Static Function OA1800017_ValidaGet( cOkFunc )
	
	oGetFiliaisTec:nAt := 1
	oGetFiliaisTec:SetArray(OA1800027_LevantaFiliais(cOkFunc))
	oGetFiliaisTec:Refresh()
	oGetDTec:SetArray(OA1800037_LevantaTecnicos(cOkFunc))
	oGetDTec:Refresh()

Return

/*/
{Protheus.doc} OA1800027_LevantaFiliais
Esta fun艫o realiza o levantamento das filiais dispon�veis para serem considerados na pesquisa do t�cnico.
Esta fun艫o � utilizada na consulta de filial por t�cnico denominada OA180FTEC.
@type   Static Function
@author Ot�vio Favarelli
@since  22/12/2019
@param  cOkFunc,	Caractere,	Cont�m a fun艫o que ir� retornar os dados para os campos. Sendo assim, determina a origem da chamada da fun艫o OA180FTEC.
@return	aFilVAI,	Matriz,	Cont�m todas as filiais dispon�veis para serem selecionadas a partir dos t�cnicos existentes na tabela VAI
/*/
Static Function OA1800027_LevantaFiliais( cOkFunc )

	Local cAliasA
	//
	Local aFilVAI := {}

	If lVAIComp
		AAdd( aFilVAI, {			;
						cVAIFilial,	; // VAI_FILIAL
						cVAIFilNom	; // Nome da Filial
			} )
	Else
		cAliasA := GetNextAlias()
		cQuery := " SELECT DISTINCT"
		cQuery +=   " VAI.VAI_FILIAL "
		cQuery += " FROM "
		cQuery +=   RetSQLName("VAI") + " VAI "
		cQuery += " WHERE "
		cQuery +=   " VAI.D_E_L_E_T_ = ' ' "
		cQuery +=   " AND VAI.VAI_DATDEM = ' ' " // Data de demiss�o em branco (funcion�rio ainda est� admitido)
		cQuery +=	OA1800047_FiltraDadosVAI()
		DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasA, .f., .t.)

		While !(cAliasA)->(EoF())
			AAdd( aFilVAI, {										;
							(cAliasA)->VAI_FILIAL,					;
							FWFilialName( , (cAliasA)->VAI_FILIAL)	;
				} )
			(cAliasA)->(dbSkip())
		End
		(cAliasA)->(DbCloseArea())
	EndIf

Return aFilVAI

/*/
{Protheus.doc} OA1800037_LevantaTecnicos
Esta fun艫o realiza o levantamento dos t�cnicos dispon�veis para serem considerados na pesquisa do t�cnico.
Esta fun艫o � utilizada na consulta de filial por t�cnico denominada OA180FTEC.
@type   Static Function
@author Ot�vio Favarelli
@since  22/12/2019
@param  cOkFunc,	Caractere,	Cont�m a fun艫o que ir� retornar os dados para os campos. Sendo assim, determina a origem da chamada da fun艫o OA180FTEC.
@return	aTecnicos,	Matriz,	Cont�m todos t�cnicos dispon�veis para serem selecionados.
/*/
Static Function OA1800037_LevantaTecnicos( cFilPos )

	Local aTecnicos
	//
	Local cQuery
	Local cAliasB

	cAliasB := GetNextAlias()
	cQuery := " SELECT "
	cQuery +=   " VAI.VAI_FILIAL "
	cQuery +=   " , VAI.VAI_CODTEC "
	cQuery +=   " , VAI.VAI_NOMTEC "
	cQuery +=   " , VAI.VAI_CPF "
    cQuery += " FROM "
    cQuery +=   RetSQLName("VAI") + " VAI "
    cQuery += " WHERE "
    cQuery +=   " VAI.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND VAI.VAI_DATDEM = ' ' " // Data de demiss�o em branco (funcion�rio ainda est� admitido)
	cQuery +=	OA1800047_FiltraDadosVAI()
    cQuery += " ORDER BY "
    cQuery +=   " 1, 2 "
	DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasB, .f., .t.)
	
	aTecnicos := {}

	While !(cAliasB)->(EoF())
		AAdd( aTecnicos,{ 						;
						(cAliasB)->VAI_FILIAL,	;
						(cAliasB)->VAI_CODTEC,	;
						(cAliasB)->VAI_NOMTEC,	;
						(cAliasB)->VAI_CPF		;
			})
		(cAliasB)->(dbSkip())
	End
	(cAliasB)->(DbCloseArea())

	If Len(aTecnicos) == 0
		AAdd( aTecnicos,{ 	;
						" ",; // VAI_FILIAL
						" ",; // VAI_CODTEC
						" ",; // VAI_NOMTEC
						" ",; // VAI_CPF
			})
	EndIf

Return aTecnicos

/*/
{Protheus.doc} OA1800047_FiltraDadosVAI
Esta fun艫o realiza o filtro dos dados a serem considerados na query da VAI a partir do informado pelo usu�rio nas getdados do TPanel na consulta de filial por t�cnico denominada OA180FTEC.
@type   Static Function
@author Ot�vio Favarelli
@since  23/12/2019
@param  nil
@return	cFilQuery,	Caractere,	Cl�usulas a serem consideradas no WHERE
/*/
Static Function OA1800047_FiltraDadosVAI()

	Local cFilQuery

	cFilQuery := ""
	
	If !Empty(cFilTec)
		cFilQuery += " AND VAI.VAI_FILIAL = '" + cFilTec + "' "
	EndIf
	If !Empty(cCodTec)
		cFilQuery += " AND VAI.VAI_CODTEC = '" + cCodTec + "' "
	EndIf
	If !Empty(cNomTec)
		cFilQuery += " AND VAI.VAI_NOMTEC LIKE '%" + AllTrim(cNomTec) + "%' "
	EndIf
	If !Empty(cCPFTec)
		cFilQuery += " AND VAI.VAI_CPF = '" + cCPFTec + "' "
	EndIf 

Return cFilQuery
