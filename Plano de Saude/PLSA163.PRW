
#include "PLSMGER.CH"
#INCLUDE "PLSA163.ch"
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSA163 � Autor � Tulio Cesar          � Data � 09.04.2003 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Cadastro de Tipos de Admissao                              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Advanced Protheus                                           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Altera噭o                     潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Function PLSA163

Private lNovGD0	:=.T.
Private lAchou	:=.F.
                 
                     


Private aRotAdic := {{"Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('BDR',BDR->BDR_CODTAD, 1)})", 0,2},;
				     {"Excluir Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('BDR',BDR->BDR_CODTAD, 0)})", 0,2}}

AxCadastro("BDR",PLSRETTIT("BDR"),"PLSA163Del()","PLSA163Int(nOpc)", aRotAdic)

	
Return





/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � PLSA256Del � Autor � 				      � Data � 13.08.10 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Validacao de exclusao Tabelas do modulo Gest鉶 Hospitalar    潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Function PLSA163Del()
Local lRet := .T.
local lEspelhar := GetNewPar("MV_INTADMP",.F.)  // Parametro integra玢o entre Tabelas GH e PLS

If lEspelhar
	DbSelectarea ("GD0")
	GD0->(DbSetOrder(1))
	If GD0->(MsSeek(xFilial("GD0")+BDR->BDR_CODTAD)) .and. HS_VEAA5() 
		DbSelectarea ("BBL")
		BBL->(DbSetOrder(2))
		If BBL->(MsSeek(xFilial("BBL")+"PLSA163   "+"BDR"+"GD0"))
			RecLock("GD0", .F.)
			DbDelete()
			MsUnlock()
		Else
			If GetNewPar("MV_PLSMSGS","1") == "1"
				MsgAlert(OemtoAnsi(STR0001)) //"Arquivo de sincronismo entre BDR x GD0 nao esta integro. Verifique!"
			Endif
		Endif
		
	Endif
Endif
Return(lRet)




/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � PLSA163Int � Autor � 				      � Data � 13.08.10 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Alteracao/Inclus鉶  Tabelas do Modulo GH com Sincronismo       潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Function PLSA163Int(nOpc)
Local lRet := .T.
local lEspelhar := GetNewPar("MV_INTADMP",.F.)  // Parametro integra玢o entre Tabelas GH e PLS

If nOpc == 3
	If lEspelhar
		If  ! Empty(M->BDR_CODTAD)
			DbSelectarea ("GD0")
			GD0->(DbSetOrder(1))
			lNovGD0 := (GD0->(MsSeek(xFilial("GD0")+M->BDR_CODTAD)))
		Else
			lNovGD0 := .T.
		Endif
	Endif
	
	If  ! LNovGD0
		DbSelectarea ("BBL")
		BBL->(DbSetOrder(2))
		If 	BBL->(MsSeek(xFilial("BBL")+"PLSA163   "+"BDR"+"GD0"))
			RecLock("GD0", .T.)
			GD0->GD0_FILIAL := xFilial("GD0")
			PlsSinc("PLSA163   ","BDR","GD0")
			GD0->GD0_LOGARQ := HS_LOGARQ()
			MsUnlock()
		Else
			If GetNewPar("MV_PLSMSGS","1") == "1"
				MsgAlert(OemtoAnsi(STR0001)) //"Arquivo de sincronismo entre BDR x GD0 nao esta integro. Verifique!"
			Endif
		Endif
	Endif
ElseIf nOpc == 4
	If lEspelhar
		DbSelectarea ("GD0")
		GD0->(DbSetOrder(1))
		If BDR->(FieldPos("BDR_REFIGH"))>0
			If !Empty(M->BDR_REFIGH) .and. GD0->(MsSeek(xFilial("GD0")+M->BDR_REFIGH))
				lAchou:= HS_VEAA5() // Fun玢o chamada no Gest鉶 hospitalar para Valida玢o de Sincronismo	 
			Else
				lAchou:= GD0->(MsSeek(xFilial("GD0")+M->BDR_CODTAD))
			Endif
			If lAchou
				DbSelectarea ("BBL")
				BBL->(DbSetOrder(2))
				If 	BBL->(MsSeek(xFilial("BBL")+"PLSA163   "+"BDR"+"GD0"))
					RecLock("GD0", .F.)
					PlsSinc("PLSA163   ","BDR","GD0")
					GD0->GD0_LOGARQ := HS_LOGARQ()
					MsUnlock()
				Else
					If GetNewPar("MV_PLSMSGS","1") == "1"
						MsgAlert(OemtoAnsi(STR0001)) //"Arquivo de sincronismo entre BDR x GD0 nao esta integro. Verifique!"
					Endif
					
				Endif
			Endif
		Endif
	Endif
Endif
Return(lRet)





/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘北
北矲uncao    � MenuDef � Autor � Henry Fila             � Data � 02/04/07 潮北
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢北
北矰escricao � Atualizacao do menu funcional                              潮北
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢北
北砈intaxe   � MenuDef()                                                  潮北
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢北
北� Uso      � Advanced Protheus                                          潮北
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/

Static Function MenuDef()

aRotina := StaticCall(MATXATU,MENUDEF)

AaDd( aRotina,{"Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('BDR',BDR->BDR_CODTAD, 1)})", 0,2} )
AaDd( aRotina,{"Excluir Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('BDR',BDR->BDR_CODTAD, 0)})", 0,2} )

Return aClone(aRotina)