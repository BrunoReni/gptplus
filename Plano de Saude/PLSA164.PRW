
#include "PLSMGER.CH"
#include "PLSA164.CH"
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSA164 � Autor � Tulio Cesar          � Data � 09.04.2003 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Cadastro de Tipos de Saida                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Advanced Protheus                                          潮�
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
Function PLSA164

                    
                     

Private aRotAdic := {{"Vinculo TISS" , "MsgRun('','V韓culo TISS',{||PLVINCTIS('BIY',BIY->BIY_CODSAI, 1)})", 0,2},;
				     {"Excluir Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('BIY',BIY->BIY_CODSAI, 0)})", 0,2}}

AxCadastro("BIY", PLSRETTIT("BIY"), "PLSA164Del()", "PLSA164Int(nOpc)", aRotAdic)

	
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

Function PLSA164Del()
LOCAL lRet := .T.
Local lEspelhar := GetNewPar("MV_INTSAIP",.F.)  // Parametro integra玢o entre Tabelas GH e PLS   

If lEspelhar
	DbSelectarea ("GF4")
	GF4->(DbSetOrder(1))
	If GF4->(MsSeek(xFilial("GF4")+BIY->BIY_CODSAI)) .and. HS_A16DOK()
		DbSelectarea ("BBL")
		BBL->(DbSetOrder(2))
		If BBL->(MsSeek(xFilial("BBL")+"PLSA164   "+"BIY"+"GF4")) 
			RecLock("GF4", .F.)
			DbDelete()
			MsUnlock()
		Else
			If GetNewPar("MV_PLSMSGS","1") == "1"
				MsgAlert(OemtoAnsi(STR0001)) //"Arquivo de sincronismo entre BIY x GF4 nao esta integro. Verifique!"
			Endif
		Endif
	
	Endif
Endif
Return(lRet)





/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲uncao    � PLSA164Int � Autor � 				      � Data � 13.08.10 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escricao � Alteracao/Inclus鉶  Tabelas do Modulo GH com Sincronismo       潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Function PLSA164Int(nOpc)
Local lRet 		:= .T.
Local lAchou	:=.F.
local lNovGF4   := .T.
Local lEspelhar := GetNewPar("MV_INTSAIP",.F.)  // Parametro integra玢o entre Tabelas GH e PLS   

If nOpc == 3
	If lEspelhar
		If  ! Empty(M->BIY_CODSAI)
			DbSelectarea ("GF4")
			GF4->(DbSetOrder(1))
			lNovGF4 := (GF4->(MsSeek(xFilial("GF4")+M->BIY_CODSAI)))
		Else
			lNovGF4 := .T.
		Endif
	Endif
	
	If  ! LNovGF4
		DbSelectarea ("BBL")
		BBL->(DbSetOrder(2))
		If 	BBL->(MsSeek(xFilial("BBL")+"PLSA164   "+"BIY"+"GF4"))
			RecLock("GF4", .T.)
			GF4->GF4_FILIAL := xFilial("GF4")
			PlsSinc("PLSA164   ","BIY","GF4")
			GF4->GF4_LOGARQ := HS_LOGARQ()
			MsUnlock()
		Else
			If GetNewPar("MV_PLSMSGS","1") == "1"
				MsgAlert(OemtoAnsi(STR0001)) //"Arquivo de sincronismo entre BIY x GF4 nao esta integro. Verifique!"
			Endif
		Endif
	Endif
ElseIf nOpc == 4
	If lEspelhar
		DbSelectarea ("GF4")
		GF4->(DbSetOrder(1))
		If BIY->(FieldPos("BIY_REFIGH"))>0
			If !Empty(M->BIY_REFIGH) .and. GF4->(MsSeek(xFilial("GF4")+M->BIY_REFIGH)) 
				lAchou:= HS_A16DOK(nOpc)  // Fun玢o para Valida玢o de Sincronismo no Gest鉶 Hospitalar
			Else
				lAchou:= GF4->(MsSeek(xFilial("GF4")+M->BIY_CODSAI))
			Endif
			If lAchou
				DbSelectarea ("BBL")
				BBL->(DbSetOrder(2))
				If 	BBL->(MsSeek(xFilial("BBL")+"PLSA164   "+"BIY"+"GF4"))
					RecLock("GF4", .F.)
					PlsSinc("PLSA164   ","BIY","GF4")
					GF4->GF4_LOGARQ := HS_LOGARQ()
					MsUnlock()
				Else
					If GetNewPar("MV_PLSMSGS","1") == "1"
						MsgAlert(OemtoAnsi(STR0001)) //"Arquivo de sincronismo entre BIY x GF4 nao esta integro. Verifique!"
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

AaDd( aRotina,{"Vinculo TISS" , "MsgRun('','V韓culo TISS',{||PLVINCTIS('BIY',BIY->BIY_CODSAI, 1)})", 0,2} )
AaDd( aRotina,{"Excluir Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('BIY',BIY->BIY_CODSAI, 0)})", 0,2} )

Return aClone(aRotina)
