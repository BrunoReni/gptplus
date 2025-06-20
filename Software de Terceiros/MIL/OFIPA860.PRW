// 浜様様様曜様様様様�
// � Versao � 04     �
// 藩様様様擁様様様様�

#include "PROTHEUS.CH"
#include "OFIPA860.CH"
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � OFIPA860 � Autor � Emilton               � Data � 10/04/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Cadastro de Formulas (Siga Veiculos)                       咳�
臼団陳陳陳陳津陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳官�
臼� Uso      � Generico                                                   咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function OFIPA860()

Private aMemos  := {{"VEG_OCOMEM","VEG_OCORRE"}}
Private aCampos := {}
Private aRotina := MenuDef()
Private cCadastro := (STR0006) //Cadastro de Formulas

/////////////////////////////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar os modulos de Veiculos, Oficina ou Auto-Pe�as //
/////////////////////////////////////////////////////////////////////////////////////////////////////
If !AMIIn(11,14,41) .or. !FMX_AMIIn({"OFIPA860"}) 
	Return
EndIf

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� Endereca a funcao de BROWSE                                  �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
mBrowse( 6, 1,22,75,"VEG")

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼敖陳陳陳陳賃陳陳陳陳陳堕陳陳陳堕陳陳陳陳陳陳陳陳陳陳陳堕陳陳賃陳陳陳陳陳娠�
臼�Fun��o    � PA860V   � Autor � Emilton / Fabio       � Data � 10/04/00 咳�
臼団陳陳陳陳津陳陳陳陳陳祖陳陳陳祖陳陳陳陳陳陳陳陳陳陳陳祖陳陳珍陳陳陳陳陳官�
臼�Descri��o � Visualizar                                                 咳�
臼青陳陳陳陳珍陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳抉�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function PA860V(cAlias,nReg,nOpc)

CAMPOA860()
AxVisual(cAlias,nReg,nOpc,aCampos)

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �PA860I    �Autor  �Emilton/Fabio       � Data �  10/06/00   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     � Incluir                                                    艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function PA860I(cAlias,nReg,nOpc)

CAMPOA860()
AxInclui(cAlias,nReg,nOpc,aCampos,,,"FS_VALKEY()")

Return .t.

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �PA860A    �Autor  �Emilton/Fabio       � Data �  10/06/00   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     � Alterar                                                    艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function PA860A(cAlias,nReg,nOpc)

CAMPOA860()
AxAltera(cAlias,nReg,nOpc,aCampos,,,,"FS_VALKEY()")

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �PA860E    �Autor  �Emilton/Fabio       � Data �  08/23/00   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     � Excluir                                                    艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function PA860E(cAlias,nReg,nOpc)

Local aVetValid := {}

Aadd(aVetValid, {"VE4", "VE4_FOREXP" , VEG->VEG_CODIGO , NIL } )
Aadd(aVetValid, {"VE4", "VE4_FVLSGV" , VEG->VEG_CODIGO , NIL } )
Aadd(aVetValid, {"VE4", "VE4_FVLASS" , VEG->VEG_CODIGO , NIL } )
Aadd(aVetValid, {"VE4", "VE4_FVLFVD" , VEG->VEG_CODIGO , NIL } )

Aadd(aVetValid, {"VE5", "VE5_FORVDA" , VEG->VEG_CODIGO , NIL } )
Aadd(aVetValid, {"VE5", "VE5_FORGAR" , VEG->VEG_CODIGO , NIL } )
Aadd(aVetValid, {"VE5", "VE5_FORPRP" , VEG->VEG_CODIGO , NIL } )

Aadd(aVetValid, {"VE6", "VE6_FORMUL" , VEG->VEG_CODIGO , NIL } )

Aadd(aVetValid, {"VO3", "VO3_FORMUL" , VEG->VEG_CODIGO , NIL } )

Aadd(aVetValid, {"VOI", "VOI_VALPEC" , VEG->VEG_CODIGO , NIL } )

Aadd(aVetValid, {"VOQ", "VOQ_CODIGO" , VEG->VEG_CODIGO , NIL } )
Aadd(aVetValid, {"VOQ", "VOQ_CODIMF" , VEG->VEG_CODIGO , NIL } )

Aadd(aVetValid, {"VS1", "VS1_FORMUL" , VEG->VEG_CODIGO , NIL } )

Aadd(aVetValid, {"VS3", "VS3_FORMUL" , VEG->VEG_CODIGO , NIL } )

Aadd(aVetValid, {"VV6", "VV6_FORMUL" , VEG->VEG_CODIGO , NIL } )

Aadd(aVetValid, {"VVT", "VVT_FORMUL" , VEG->VEG_CODIGO , NIL } )

If FG_DELETA( aVetValid )
	CAMPOA860()
	AxDeleta(cAlias,nReg,nOpc,,aCampos)
endif

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �CAMPOA860 �Autor  �Emilton/Fabio       � Data �  10/06/00   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     � Monta Campos                                               艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function CAMPOA860()

DbSelectArea("SX3")
DbSetOrder(1)
dbseek("VEG")
aCampos := {}

While !eof() .and. x3_arquivo == "VEG"
	
	If X3USO(x3_usado).And.cNivel>=x3_nivel
		aadd(aCampos,x3_campo)
	EndIf
	
	dbskip()
	
Enddo

DbSelectArea("VEG")

Return

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  �FS_VALKEY �Autor  �Emilton/Fabio       � Data �  10/06/00   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     �Valida chave duplicada                                      艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Function FS_VALKEY()
Local lRet := .t.
Local nRecVEG := VEG->(RecNo())
DbSelectArea("VEG")
DbSetOrder(1)
If DbSeek(xFilial("VEG")+M->VEG_CODIGO)
	If nRecVEG # VEG->(RecNo())
		Help(" ",1,"JAGRAVADO")
		lRet := .f.
	EndIf
EndIf
DbSelectArea("VEG")
DbGoTo(nRecVEG)
Return(lRet)

/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
臼浜様様様様用様様様様様僕様様様冤様様様様様様様様様曜様様様冤様様様様様様傘�
臼�Programa  � MenuDef  � Autor �Emilton/Fabio       � Data �  10/06/00   艮�
臼麺様様様様謡様様様様様瞥様様様詫様様様様様様様様様擁様様様詫様様様様様様恒�
臼�Desc.     � Montagem aRotina ( MENUDEF )                               艮�
臼藩様様様様溶様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様識�
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼�
烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝烝�
*/
Static Function MenuDef()
Local aRotina := {	{ STR0001 ,"AxPesqui", 0 , 1},;     // Pesquisar
					{ STR0002 ,"PA860V"  , 0 , 2},;  // Visualizar
					{ STR0003 ,"PA860I"  , 0 , 3},;  // Incluir
					{ STR0004 ,"PA860A"  , 0 , 4},;  // Alterar
					{ STR0005 ,"PA860E"  , 0 , 5}}   // Excluir
Return aRotina

/*/{Protheus.doc} OFP8600016_VerificacaoFormula
Verificando Exist�ncia ou Bloqueio da F�rmula
@author Fernando Vitor Cavani
@since 20/01/2020
@version undefined
@type function
@param  cCodigo  caracter Codigo VEG
@param  lShowHlp l�gico   Mostrar Mensagem
@return lRet     l�gico   Retorno (.t. / .f.)
/*/
Function OFP8600016_VerificacaoFormula(cCodigo, lShowHlp)
Local cMsg       := ""
Local lRet       := .T.
Local aArea
Local aAreaA1

Default cCodigo  := ""
Default lShowHlp := .T.

aArea   := GetArea()
aAreaA1 := VEG->(GetArea())

dbSelectarea("VEG")
If !Empty(cCodigo)
	dbSetOrder(1)
	If msSeek(xFilial("VEG") + cCodigo)
		// Verifica C�digo Bloqueado
		If VEG->(FieldPos("VEG_MSBLQL")) .And. VEG->VEG_MSBLQL == "1"
			lRet := .F.

			If lShowHlp
				cMsg := chr(13) + chr(10) + "VEG - " + STR0006 + chr(13) + chr(10) // Cadastro de Formulas
				cMsg += RetTitle("VEG_CODIGO") + ":" + VEG->VEG_CODIGO + chr(13) + chr(10)
				cMsg += RetTitle("VEG_DESCRI") + ":" + VEG->VEG_DESCRI + chr(13) + chr(10)
				cMsg += RetTitle("VEG_FORMUL") + ":" + VEG->VEG_FORMUL + chr(13) + chr(10)

				HELP(" ", 1, "REGBLOQ",, cMsg, 3, 1)
			EndIf
		EndIf
	Else
		lRet := .F.

		// C�digo Incorreto
		If lShowHlp
			cMsg := chr(13) + chr(10) + "VEG - " + STR0006 + chr(13) + chr(10) // Cadastro de Formulas
			cMsg += RetTitle("VEG_CODIGO") + ":" + cCodigo + chr(13) + chr(10)

			Help(" ", 1, "REGNOIS",, cMsg, 3, 1)
		EndIf
	EndIf
EndIf

RestArea(aAreaA1)
RestArea(aArea)
Return lRet