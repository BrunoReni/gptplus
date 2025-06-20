#include "msmgadd.ch"
#INCLUDE "pcoa481.ch"
#INCLUDE "protheus.ch"

/*
_F_U_N_C_苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲UNCAO    � PCOA481  � AUTOR � Acacio Egas           � DATA � 30/04/08   潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰ESCRICAO � Programa para manutencao do relacionamento de Receita/Custo  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� USO      � SIGAPCO                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡DOCUMEN_ � PCOA481                                                      潮�
北砡DESCRI_  � Programa para manutencao do Relacionamento de Receita/Custo  潮�
北砡FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal    潮�
北�          � partir do Menu ou a partir de uma funcao pulando assim o     潮�
北�          � browse principal e executando a chamada direta da rotina     潮�
北�          � selecionada.                                                 潮�
北�          � Exemplo: PCOA481(2) - Executa a chamada da funcao de visua-  潮�
北�          �                        zacao da rotina.                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/

Static aRecnos

Function PCOA481(nCallOpcx, lAuto, lProc)

Local xOldInt
Local lOldAuto
Local lRet := .T.
Local cFiltro := ""

Default lProc := .F.

Private cTipo := '1'


If lAuto
	If Type('__cInternet') != 'U'
		xOldInt := __cInternet
	EndIf
	If Type('lMsHelpAuto') != 'U'
		lOldAuto := lMsHelpAuto
	EndIf
	lMsHelpAuto := .T.
	If !lProc
		__cInternet := 'AUTOMATICO'
	Endif	
EndIf

Private cCadastro	:= STR0001 //"Relacionamento Receita/Custo"
Private aRotina := MenuDef()

dbSelectArea("AM8")
dbSetOrder(1)

	If nCallOpcx <> Nil
		lRet := A481DLG("AM8",AM8->(RecNo()),nCallOpcx,lAuto)
	Else

		cFiltro	:= PcoFilConf("AM8")
		
		If !Empty(cFiltro)
	
				mBrowse(6,1,22,75,"AM8",,,,,,,,,,,,,,"AM8_TIPO='" + cTipo + "' AND " + cFiltro )
		EndIf
	EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt

Return lRet


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨481DLG   篈utor  矨cacio Egas         � Data �  04/30/08   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Dialog para montar MsmGet com Alguns campos.               罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � SIGAPCO                                                   罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function A481DLG(cAlias,nReg,nOpc,lAuto)

Local nOkOpc := 3
Local aCampos,aCpos
LOcal _nX,_nI
Local aCposAM8
Local lInc
Local aCordW 	:= {0,0,305,635}

Default nReg := AM8->(Recno())
Default lAuto:= .F.

INCLUI 	:= nOpc==3
ALTERA 	:= nOpc==4
EXCLUI 	:= nOpc==5

aRecnos := {}

aCposAM8 := GetaHeader("AM8",,)
RegToMemory("AM8",INCLUI)

If nOpc == 3

	If !Empty(MV_PAR02)
		M->AM8_TPCOD	:= MV_PAR02
	Endif
	
	If !Empty(MV_PAR03)
		M->AM8_VARCOD	:= MV_PAR03
	Endif

EndIf

aHeader := GetaHeader("AM9",,)
aCols := {}

// Monta aCols
If !INCLUI
	DbSelectArea("AM8")
	DbGoTo(nReg)
	DbSelectArea("AM9")
	DbSetOrder(1)
	DbSeek(xFilial("AM9")+AM8->AM8_ID)
	Do While !Eof() .and. AM9->AM9_ID==AM8->AM8_ID
		aAdd( aCols , Array(Len(aHeader)+1) )
		AEval(aHeader, {|x,y| aCols[Len(aCols)][y] := If(Alltrim(x[2])$"AM9_ALI_WT|AM9_REC_WT",NIL,If(x[10]='V',CriaVar(AllTrim(x[2])),FieldGet(FieldPos(x[2])) ) ) })
		aCols[Len(aCols),Len(aHeader)+1] := .F.			
		aAdd( aRecnos , RECNO() )
		DbSkip()
	EndDo
EndIf

// Cria Linha em branco no aCols zerado
If Len(aCols)=0
	aAdd( aCols , Array(Len(aHeader)+1) )
	AEval(aHeader, {|x,y| aCols[Len(aCols)][y] := If(Alltrim(x[2])$"AM9_ALI_WT|AM9_REC_WT",NIL,CriaVar(AllTrim(x[2])) ) })
	aCols[1,Len(aHeader)+1] := .F.
EndIf

lOk := Modelo3(cCadastro,"AM8","AM9",/*aMyEncho*/,{|| A481Lok() }/*cLinOk*/,'Pco481Tok()'/*cTudoOk*/,nOpc,nOpc,/*cFieldOk*/,.T.,/*nLinhas*/,/*aAltEnchoice*/,/*nFreeze*/,/*aButtons*/,aCordW,/*nSizeHeader*/)

If lOk

	// Grava AM8
	DbSelectArea("AM8")
	If ALTERA .or. EXCLUI
		DbGoTo(nReg)
	EndIf
	If ALTERA .or. INCLUI

			cId := MaxId()
			RecLock("AM8",INCLUI)
			// Grava campos que nao estao disponiveis na tela
			AM8->AM8_CFGPLN := AMB->AMB_CODIGO
			AM8->AM8_FILIAL	:= xFilial("AM8")
			AM8->AM8_TIPO	:= cTipo
			If INCLUI
				AM8->AM8_ID		:= StrZero(cId,6)
			EndIf
			AEval(aCposAM8, {|x,y|  If(!(Alltrim(x[2])$"AM8_ALI_WT|AM8_REC_WT") .and. x[10]<>"V" , FieldPut(FieldPos(x[2]),&("M->"+x[2])) , .F. )  })
		MsUnLock()

	ElseIf EXCLUI

		RecLock("AM8",INCLUI)
			DbDelete()
		MsUnLock()
	
	EndIf
	
	// Grava AM9
	DbSelectArea("AM9")
	For _nX := 1 To Len(aCols)
		
		If (aCols[_nX,Len(aHeader)+1] .and. Len(aRecnos)<=_nX) .or. EXCLUI // Deletado
		
			DbGoto(aRecnos[_nX])
			RecLock("AM9",.F.)
				DbDelete()
			MsUnLock()
		
		ElseIf INCLUI .or. Len(aRecnos) < _nX

			RecLock("AM9",.T.)
				AM9->AM9_FILIAL	:= xFilial("AM9")
				AM9->AM9_ID		:= AM8->AM8_ID
				AEval(aHeader, {|x,y|  If(!(Alltrim(x[2])$"AM9_ALI_WT|AM9_REC_WT") .and. x[10]<>"V" , FieldPut(FieldPos(x[2]),aCols[_nX,y]) , .F. )  })	
			MsUnLock()
		
		ElseIf ALTERA

			DbGoto(aRecnos[_nX])
			RecLock("AM9",.F.)
				AEval(aHeader, {|x,y|  If(!(Alltrim(x[2])$"AM9_ALI_WT|AM9_REC_WT") .and. x[10]<>"V" , FieldPut(FieldPos(x[2]),aCols[_nX,y]) , .F. )  })	
			MsUnLock()
		
		EndIf
	Next
EndIf

Return

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨481Lok 篈utor  矨cacio Egas         � Data �  04/30/08   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Valida玢o da Linha da GetDados.                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � SIGAPCO                                                   罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function A481Lok(nLin)

Local lRet 		:= .T.
Local lOk		:= .T.
Default nLin 	:= n

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Ponto de entrada para valida玢o da Linha Ok                            �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If ExistBlock( "PCOA4812" )
	//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//P_E� Ponto de entrada utilizado para valida玢o da linha da GetDados         �
	//P_E�                                                                        �
	//P_E� Parametros : Valida玢o Padr鉶                                          �
	//P_E� Retorno    : Logico                                                    �
	//P_E� Ex.        : User Function PCOA4812                                    �
	//P_E�              Return {.T.)						                      �
	//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If ValType( lOk := ExecBlock( "PCOA4812", .F., .F. , lRet ) ) == "L"
		lRet := lOk
	EndIf
EndIf

Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨481Tok 篈utor  矨cacio Egas         � Data �  04/30/08     罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Valida玢o do tudo Ok da GetDados.                          罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � SIGAPCO                                                    罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function Pco481Tok()

Local lRet 		:= .T.
Local lOk		:= .T.
Local _nX,nTotPrc
Local nPosPerc := aScan(aHeader , {|x| ALLTRIM(x[2])== "AM9_PERC" })

If EXCLUI

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Valida玢o dos campos do cabe鏰lho.                                     �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

	If !VldDe(M->AM8_CO+M->AM8_CLASSE+M->AM8_OPER+M->AM8_CC+M->AM8_ITCTB+M->AM8_CLVLR)

		lRet := .F.
		Aviso( STR0002 , STR0003 ,{ STR0004 }) //"Aten玢o!"###"J� existe Relacionamento para est醩 Entidades!"###"OK"
	
	EndIf
	
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Valida玢o dos campos dos Itens.                                        �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If lRet
		nTotPrc	:= 0
		For _nX := 1 To Len(aCols)
		
			If !aCols[_Nx][Len(aCols[_Nx])] // N鉶 Deletada
				nTotPrc += aCols[_nX,nPosPerc]
			EndIf
		
		Next
	EndIf
	
	If lRet .and. nTotPrc<>100
	
		lRet := .F.
		Aviso( STR0002 , STR0005 ,{ STR0004 }) //"Aten玢o!"###"O total dos percentuais deve ser 100%."###"OK"
	
	EndIf

EndIf	

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Ponto de entrada para valida玢o do Tudo Ok.                            �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If ExistBlock( "PCOA4813" )
	//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//P_E� Ponto de entrada utilizado para valida玢o do tudo Ok da tela.          �
	//P_E�                                                                        �
	//P_E� Parametros : Valida玢o Padr鉶                                          �
	//P_E� Retorno    : Logico                                                    �
	//P_E� Ex.        : User Function PCOA4813                                    �
	//P_E�              Return {.T.)						                      �
	//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If ValType( lOk := ExecBlock( "PCOA4813", .F., .F. ,lRet) ) == "L"
		lRet := lOk
	EndIf
EndIf

Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矼enuDef   篈utor  矨cacio Egas         � Data �  04/30/08   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篣so       � PCOA481                                                   罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function MenuDef()
Local aUsRotina := {}
Local aRotina 	:= {		{ STR0006	,		"AxPesqui" , 0 , 1, ,.F.},; //"Pesquisar"
							{ STR0007	, 		"A481DLG"  , 0 , 2},;   	//"Visualizar"
							{ STR0008	, 		"A481DLG"  , 0 , 3},;   	//"Incluir"
							{ STR0009	, 		"A481DLG"  , 0 , 4},;   //"Alterar"
							{ STR0010	, 		"A481DLG"  , 0 , 5};	//"Excluir"
					} 

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Adiciona botoes do usuario no aRotina                                  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If ExistBlock( "PCOA4811" )
		//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de lan鏰mentos                                          �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOA4811                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		If ValType( aUsRotina := ExecBlock( "PCOA4811", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
Return(aRotina)

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  砎ldDe     篈utor  矨cacio Egas         � Data �  04/30/08   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Valida chave do AM8.                                       罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function VldDe(cChave)

LOcal lRet	:= .T.
Local aArea := GetArea()

DbSelectArea("AM8")
DbSetOrder(1)
If DbSeek(xFilial("AM8")+cTipo+cChave)

	If INCLUI .or. (aScan(aRecnos,Recno())==0 .and. ALTERA)
		lRet	:= .F.
	EndIf
	
EndIf
RestArea(aArea)

Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矼axId     篈utor  矨cacio Egas         � Data �  04/30/08   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Controla o ID para relacionamento AM8 e AM9.               罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function MaxId()

Local cQuery
cQuery := "SELECT MAX(AM8_ID) AS ID FROM " + RetSqlName("AM8") + " AM8"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAM8", .T., .T. )
nRet := If( VALTYPE(TMPAM8->ID)<>"N" , 1 , TMPAM8->ID + 1 )
TMPAM8->(dbCloseArea())

Return nRet


