#INCLUDE "pcoa462.ch"
#INCLUDE "PROTHEUS.CH"

/*
_F_U_N_C_苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲UNCAO    � PCOA462  � AUTOR � Paulo Carnelossi      � DATA � 26/03/08   潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰ESCRICAO � Programa para manutencao Relacionamento entre Grupos Verbas  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� USO      � SIGAPCO                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡DOCUMEN_ � PCOA462                                                      潮�
北砡DESCRI_  � Programa para manutencao de Relacionamento Entre Grupo Verbas潮�
北砡FUNC_    � Esta funcao podera ser utilizada com a sua chamada normal    潮�
北�          � partir do Menu ou a partir de uma funcao pulando assim o     潮�
北�          � browse principal e executando a chamada direta da rotina     潮�
北�          � selecionada.                                                 潮�
北�          � Exemplo: PCOA462(2) - Executa a chamada da funcao de visua-  潮�
北�          �                        zacao da rotina.                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砡PARAMETR_� ExpN1 : Chamada direta sem passar pela mBrowse               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function PCOA462(nCallOpcx, lAuto, lProc)
Local xOldInt
Local lOldAuto
Local lRet := .T.

Default lProc := .F.

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

Private cCadastro	:= STR0001 //"Relacionamento Entre Grupos de Verbas"
Private aRotina := MenuDef()

dbSelectArea("AM6")
dbSetOrder(1)

	If nCallOpcx <> Nil
		lRet := A462DLG("AM6",AM6->(RecNo()),nCallOpcx,lAuto)
	Else
		mBrowse(6,1,22,75,"AM6",,,,,, )
	EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt

Return lRet

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨462DLG   篈utor  矴uilherme C. Leal   � Data �  11/26/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Tratamento da tela de Inclusao/Alteracao/Exclusao/Visuali- 罕�
北�          � zacao                                                      罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP8                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function A462DLG(cAlias,nRecnoAM6,nCallOpcx,lAuto)
Local oDlg
Local lCancel  := .F.
Local aButtons	:= {}
Local aUsButtons := {}
Local oEnchAM6

Local aHeadAM6
Local aColsAM6
Local nLenAM6   := 0 // Numero de campos em uso no AM6
Local nLinAM6   := 0 // Linha atual do acols
Local aRecAM6   := {} // Recnos dos registros
Local nGetD

Local aCposEnch
Local aUsField
Local aAreaAM6 := AM6->(GetArea()) // Salva Area do AM6
Local aEnchAuto  // Array com as informacoes dos campos da enchoice qdo for automatico
Local xOldInt
Local lOldAuto
Local lOk := .F.
Local nX 
Local cGrpPai
Local lProc := .F.
Local bConfirma := {|| lOk := A462Ok(nCallOpcx,oGdAM6:Cargo,aEnchAuto,oGdAM6:aCols,oGdAM6:aHeader), If(lOk, oDlg:End(),NIL) }
Local bCancela 	:= {|| lCancel := .T., oDlg:End() }
Local aCposVisual := {}

If ValType(lAuto) != "L" 
	lAuto := .F.
EndIf

Private INCLUI  := (nCallOpcx = 3)

Private oGdAM6
PRIVATE aTELA[0][0],aGETS[0]

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

If lAuto .And. nCallOpcx != 4
	Return .F.
EndIf

If nCallOpcx != 3 .And. ValType(nRecnoAM6) == "N" .And. nRecnoAM6 > 0
	DbSelectArea(cAlias)
	DbGoto(nRecnoAM6)
	If EOF() .Or. BOF()
		HELP("  ",1,"PCOREGINV",,AllTrim(Str(nRecnoAM6)))
		Return .F.
	EndIf
	aAreaAM6 := AM6->(GetArea()) // Salva Area do AM6 por causa do Recno e do Indice
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Adiciona botoes do usuario na EnchoiceBar                              �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If ExistBlock( "PCOA4622" )
	//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//P_E� Ponto de entrada utilizado para inclusao de botoes de usuarios         �
	//P_E� na tela de Relacionamento entre Grupos de Grupos de Verbas             �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
	//P_E�  Ex. :  User Function PCOA4622                                         �
	//P_E�         Return { 'PEDIDO', {|| MyFun() },"Exemplo de Botao" }          �
	//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

	If ValType( aUsButtons := ExecBlock( "PCOA4622", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

If !lAuto
	DEFINE MSDIALOG oDlg TITLE STR0001 FROM 0,0 TO 480,650 PIXEL  //"Relacionamento Entre Grupos de Verbas"
	oDlg:lMaximized := .T.
EndIf

aCposEnch := {"AM6_GRPPAI","AM6_DESPAI","AM6_PERC", "NOUSER"}

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Ponto de entrada para adicionar campos no cabecalho                    �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If ExistBlock( "PCOA4623" )
	//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//P_E� Ponto de entrada utilizado para adicionar campos no cabecalho          �
	//P_E� Parametros : Nenhum                                                    �
	//P_E� Retorno    : Array contendo as os campos a serem adicionados           �
	//P_E�               Ex. :  User Function PCOA4623                            �
	//P_E�                      Return {"AM6_FIELD1","AM6_FIELD2"}                �
	//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If ValType( aUsField := ExecBlock( "PCOA4623", .F., .F. ) ) == "A"
		AEval( aUsField, { |x| AAdd( aCposEnch, x ) } )
	EndIf
EndIf

// Carrega dados do AM6 para memoria
RegToMemory("AM6",INCLUI)

If !lAuto
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Enchoice com os dados dos Lancamentos                                  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	oEnchAM6 := MSMGet():New('AM6',,nCallOpcx,,,,aCposEnch,{0,0,23,23},,,,,,oDlg,,,,,,,,,)
	oEnchAM6:oBox:Align := CONTROL_ALIGN_TOP
EndIf
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Montagem do aHeader do AM6                                             �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
aHeadAM6 := GetaHeader("AM6",,aCposEnch,@aEnchAuto,aCposVisual, .T. /*lWalk_Thru*/)
nLenAM6  := Len(aHeadAM6) + 1

nPos_ALI_WT := AScan(aHeadAM6,{|x| Upper(AllTrim(x[2])) == "AM6_ALI_WT"})
nPos_REC_WT := AScan(aHeadAM6,{|x| Upper(AllTrim(x[2])) == "AM6_REC_WT"})


//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Montagem do aCols do AM6                                               �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

aColsAM6 := {}
DbSelectArea("AM6")
DbSetOrder(1)
DbSeek(xFilial()+AM6->AM6_GRPPAI)


cGrpPai := AM6->AM6_FILIAL + AM6->AM6_GRPPAI
While nCallOpcx != 3 .And. !Eof() .And. AM6->AM6_FILIAL + AM6->AM6_GRPPAI == cGrpPai
	AAdd(aColsAM6,Array( nLenAM6 ))
	nLinAM6++

	// Varre o aHeader para preencher o acols
	AEval(aHeadAM6, {|x,y| aColsAM6[nLinAM6][y] := If(Alltrim(x[2])$"AM6_ALI_WT|AM6_REC_WT",NIL,If(x[10] == "V" , CriaVar(AllTrim(x[2])), FieldGet(FieldPos(x[2])) )) })
	
	If nPos_ALI_WT > 0
		aColsAM6[nLinAM6][nPos_ALI_WT] := "AM6"
	EndIf

	If nPos_REC_WT > 0
		aColsAM6[nLinAM6][nPos_REC_WT] := AM6->(Recno())
	EndIf
	
	// Deleted
	aColsAM6[nLinAM6][nLenAM6] := .F.
	AAdd( aRecAM6, AM6->( Recno() ) )

	AM6->(DbSkip())
	
EndDo

// Verifica se n鉶 foi criada nenhuma linha para o aCols
If Len(aColsAM6) = 0
	AAdd(aColsAM6,Array( nLenAM6 ))
	nLinAM6++
	// Varre o aHeader para preencher o acols
	AEval(aHeadAM6, {|x,y| aColsAM6[nLinAM6][y] := If( ! (x[2]$"AM6_ALI_WT|AM6_REC_WT"), CriaVar(AllTrim(x[2])), NIL) } )
	
	If nPos_ALI_WT > 0
		aColsAM6[nLinAM6][nPos_ALI_WT] := "AM6"
	EndIf

	If nPos_REC_WT > 0
		aColsAM6[nLinAM6][nPos_REC_WT] := 0
	EndIf

	// Deleted
	aColsAM6[nLinAM6][nLenAM6] := .F.
EndIf

If !lAuto
	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	//� GetDados com os Lancamentos                   �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If nCallOpcx = 3 .Or. nCallOpcx = 4
		nGetD:= GD_INSERT+GD_UPDATE+GD_DELETE
	Else
		nGetD := 0
	EndIf
	oGdAM6:= MsNewGetDados():New(0,0,100,100,nGetd,"AM6LinOK",,"+AM6_ID",,,9999,,,,oDlg,aHeadAM6,aColsAM6)
	oGdAM6:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGdAM6:CARGO := AClone(aRecAM6)
	
	aButtons := aClone(AddToExcel(aButtons,{ 	{"ENCHOICE",,oEnchAM6:aGets,oEnchAM6:aTela},;
												{"GETDADOS",,oGdAM6:aHeader,oGdAM6:aCols} } ))

	If nCallOpcx != 3
		AM6->(RestArea(aAreaAM6)) // Retorna Area para que os dados da enchoice aparecam corretos
		oEnchAM6:Refresh()
	EndIf

	// Quando nao for MDI chama centralizada.
	If SetMDIChild()
		ACTIVATE MSDIALOG oDlg ON INIT ( oGdAM6:oBrowse:Refresh(), EnchoiceBar( oDlg, bConfirma, bCancela, , aButtons) )
	Else
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (oGdAM6:oBrowse:Refresh(),EnchoiceBar( oDlg, bConfirma, bCancela, , aButtons) )
	EndIf
Else              
	lCancel := ! A462Ok(nCallOpcx,aRecAM6,aEnchAuto,aColsAM6,aHeadAM6)
EndIf

lMsHelpAuto := lOldAuto
__cInternet := xOldInt

RestArea(aAreaAM6)
Return !lCancel

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  � A462Ok   篈utor  矴uilherme C. Leal   � Data �  11/26/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Funcao do botao OK da enchoice bar, valida e faz o         罕�
北�          � tratamento adequado das informacoes.                       罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP8                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function A462Ok(nCallOpcx,aRecAM6,aEnchAuto,aColsAM6,aHeadAM6)
Local nI
Local nX
Local aValor
Local aAreaAM6	:= AM6->(GetArea())
Local lRegravou	:=	.F.
Local nPosField

If nCallOpcx = 1 .Or. nCallOpcx = 2 // Pesquisar e Visualizar
	Return .T.
EndIf

If INCLUI
	If !ExistChav('AM6',M->AM6_GRPPAI)
		Return .F.	
	Endif
Endif

If !A462Vld(nCallOpcx,aRecAM6,aEnchAuto,aColsAM6,aHeadAM6)
	Return .F.
EndIf

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Ponto de entrada para validacao ou acao programada por usuario         �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
If ExistBlock( "PCOA4624" )
	If !ExecBlock("PCOA4624",.f.,.f.,{nCallOpcx,aEnchAuto,aColsAM6,aHeadAM6})
		Return .F.
	EndIf	
EndIf

AM6->(DbSetOrder(1))

If nCallOpcx = 3 // Inclusao

	// Grava Lancamentos
	For nI := 1 To Len(aColsAM6)

		If aColsAM6[nI][Len(aColsAM6[nI])] // Verifica se a linha esta deletada
			Loop
		Else
			Reclock("AM6",.T.)
		EndIf

		// Varre o aHeader e grava com base no acols
		AEval(aHeadAM6,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsAM6[nI][y])), ) })

		// Grava Campos do Cabecalho
		For nX := 1 To Len(aEnchAuto)
			nPosField := FieldPos(aEnchAuto[nX][2])
			If nPosField > 0
				FieldPut(nPosField,&( "M->" + aEnchAuto[nX][2] ))
			EndIf	
		Next nX

		// Grava campos que nao estao disponiveis na tela
		Replace AM6_FILIAL With xFilial()
		MsUnlock()
		
	Next nI
	
ElseIf nCallOpcx = 4 // Alteracao

	// Grava Lancamentos
	For nI := 1 To Len(aColsAM6)
	
		lRegravou	:=	.F.
		If nI <= Len(aRecAM6) .And. aRecAM6[nI] > 0
			AM6->(DbGoto(aRecAM6[nI]))
			If aColsAM6[nI][Len(aColsAM6[nI])]
				lRegravou	:=	.T.
			EndIf
			Reclock("AM6",.F.)
		Else
			If aColsAM6[nI][Len(aColsAM6[nI])] // Verifica se a linha esta deletada
				Loop
			Else
				Reclock("AM6",.T.)
			EndIf
			lRegravou := .T.
		EndIf
	
		If aColsAM6[nI][Len(aColsAM6[nI])] // Verifica se a linha esta deletada
			AM6->(DbDelete())
		Else
            
			// Varre o aHeader e grava com base no acols
			AEval(aHeadAM6,{|x,y| If(x[10] != "V",( FieldPut(FieldPos(x[2]), aColsAM6[nI][y])), ) })
	
			// Grava Campos do Cabecalho
			For nX := 1 To Len(aEnchAuto)
				nPosField := FieldPos(aEnchAuto[nX][2])
				If nPosField > 0
					FieldPut(nPosField,&( "M->" + aEnchAuto[nX][2] ))
				EndIf	
			Next nX
	
			// Grava campos que nao estao disponiveis na tela
			Replace AM6_FILIAL With xFilial()
			MsUnlock()
			
			
			dbSelecTArea("AM6")
			
		EndIf

	Next nI

ElseIf nCallOpcx = 5 // Exclusao

	// Exclui Lancamentos
	For nI := 1 To Len(aColsAM6)

		If nI <= Len(aRecAM6) .And. aRecAM6[nI] > 0
			AM6->(DbGoto(aRecAM6[nI]))

			Reclock("AM6",.F.)
			AM6->(DbDelete())
			MsUnLock()
		EndIf		
		

	Next nI

EndIf

AM6->(RestArea(aAreaAM6))

Return .T.

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  � A462Vld  篈utor  矴uilherme C. Leal   � Data �  11/26/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Funcao de validacao dos campos.                            罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP8                                                        罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Static Function A462Vld(nCallOpcx,aRecAM6,aEnchAuto,aColsAM6,aHeadAM6)
Local nI

If !(nCallOpcx = 3 .Or. nCallOpcx = 4 .Or. nCallOpcx = 5)
	Return .T.
EndIf

If ( AScan(aEnchAuto,{|x| If(Alltrim(x[2])$"AM6_ALI_WT|AM6_REC_WT", .F., x[17] .And. Empty( &( "M->" + x[2] ) ) ) } ) > 0 )
	HELP("  ",1,"OBRIGAT")
	Return .F.
EndIf

For nI := 1 To Len(aColsAM6)
	If ! aColsAM6[nI,Len(aHeadAM6)+1] //valida somente os que nao estao deletados
		// Busca por campos obrigatorios que nao estejam preenchidos
		nPosField := AScanx(aHeadAM6,{|x,y| if(Alltrim(x[2])$"AM6_ALI_WT|AM6_REC_WT", .F. , x[17] .And. Empty(aColsAM6[nI][y])) })
		If nPosField > 0
			SX2->(dbSetOrder(1))
			SX2->(MsSeek("AM6"))
			HELP("  ",1,"OBRIGAT2",,X2NOME()+CHR(10)+CHR(13)+STR0002+ AllTrim(aHeadAM6[nPosField][1])+CHR(10)+CHR(13)+STR0003+Str(nI,3,0),3,1)  //"Campo: "###"Linha: "
			Return .F.
		EndIf
	EndIf	
Next nI

Return .T.

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北矲un噮o    砅coxGD1LinOK� Autor � Edson Maricate      � Data � 17-12-2003 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噮o 砎alidacao da LinOK da Getdados                                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      砅COXFUN                                                       潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function AM6LinOK()
Local lRet			:= .T.

If !aCols[n][Len(aCols[n])]

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Verifica os campos obrigatorios do SX3.              �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If lRet
		lRet := MaCheckCols(aHeader,aCols,n) 
	EndIf               

EndIf
	
Return lRet

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  矼enuDef   � Autor � Ana Paula N. Silva     � Data �17/11/06 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Utilizacao de menu Funcional                               潮�     
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   矨rray com opcoes da rotina.                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砅arametros do array a Rotina:                               潮�
北�          �1. Nome a aparecer no cabecalho                             潮�
北�          �2. Nome da Rotina associada                                 潮�
北�          �3. Reservado                                                潮�
北�          �4. Tipo de Transa噭o a ser efetuada:                        潮�
北�          �		1 - Pesquisa e Posiciona em um Banco de Dados     潮�
北�          �    2 - Simplesmente Mostra os Campos                       潮�
北�          �    3 - Inclui registros no Bancos de Dados                 潮�
北�          �    4 - Altera o registro corrente                          潮�
北�          �    5 - Remove o registro corrente do Banco de Dados        潮�
北�          �5. Nivel de acesso                                          潮�
北�          �6. Habilita Menu Funcional                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Static Function MenuDef()
Local aUsRotina := {}
Local aRotina 	:= {		{ STR0004	,		"AxPesqui" , 0 , 1, ,.F.},; //"Pesquisar"
							{ STR0005	, 		"A462DLG"  , 0 , 2},; //"Visualizar"
							{ STR0006	, 		"A462DLG"  , 0 , 3},; //"Incluir"
							{ STR0007	, 		"A462DLG"  , 0 , 4},; //"Alterar"
							{ STR0008	, 		"A462DLG"  , 0 , 5};  //"Excluir"
					} 

	//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
	//� Adiciona botoes do usuario no aRotina                                  �
	//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
	If ExistBlock( "PCOA4621" )
		//P_E谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
		//P_E� Ponto de entrada utilizado para inclusao de funcoes de usuarios no     �
		//P_E� browse da tela de lan鏰mentos                                          �
		//P_E� Parametros : Nenhum                                                    �
		//P_E� Retorno    : Array contendo as rotinas a serem adicionados na enchoice �
		//P_E�               Ex. :  User Function PCOA4621                            �
		//P_E�                      Return {{"Titulo", {|| U_Teste() } }}             �
		//P_E滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
		If ValType( aUsRotina := ExecBlock( "PCOA4621", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
Return(aRotina)
