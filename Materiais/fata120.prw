#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATA120.CH"
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa뇙o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//�    6 - AlterACYo sem inclusao de registro                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿛rogram   쿑ATA120   � Autor 쿞ergio Silveira        � Data �13/02/2001낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Manutencao da Estrutura de clientes                        낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   � Nenhum                                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� Nenhum                                                     낢�
굇�          �                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�   DATA   � Programador   쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�          �               �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function FATA120( lVis, lSigaCRM )
Local aFieldsPD :={"A1_NOME"}
FATPDLoad(Nil, Nil, aFieldsPD)

Default lSigaCRM := .F.

Private cCadastro  := STR0001 									// "Estrutura de Regioes"
Private lVisual    := If( ValType( lVis ) == "L", lVis, .F. ) 	// Se � modo visual
Private lFiltroCRM := lSigaCRM

FT120Cons()
FATPDUnload()
Return(.T.)

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    쿑T120Cons � Autor � Sergio Silveira       � Data �13/02/2001낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Montagem da Estrutura de clientes                          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   � .t.                                                        낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� ExpC1 : Alias                                              낢�
굇�          � ExpN1 : Registro                                           낢�
굇�          � ExpN2 : Opcao                                              낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�   DATA   � Programador   쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� 10/08/07 � Conrado Q.    �-BOPS 127675: Substitui豫o do AddItem por   낢�
굇�          �               � AddTree, pois esse tem uma performance     낢�
굇�          �               � superior.                                  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Function Ft120Cons()

Local aArea     := GetArea()
Local aSizeAut  := MsAdvSize( .F. )
Local aObjects  := {}
Local aInfo     := {}
Local aObj      := {}

Local cDesc     := ""
Local cChave    := ""
Local cCampo    := ""
Local cConteudo := ""
Local cSeek     := ""
Local cLast     := ""
Local cTitulo   := ""
Local cQuery    := ""
Local cVar      := ""

Local nX        := 0
Local nY        := 0
Local nOpca     := 0

Local oDlg
Local oTree
Local oMenu
Local oCombo
Local oOpc

Private aGrupoAtu := {}
Private aGrupoExc := {}
Private aGrupoBmp := { "BMPGROUP", "BMPGROUP" }
Private lMoved    := .F.
Private aTemp     := {}

aAdd( aObjects, { 100, 100, .T., .T. } )
aAdd( aObjects, {  70, 100, .F., .T. } )

aInfo := { aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3 }
aObj  := MsObjSize( aInfo, aObjects, , .T. )

DEFINE MSDIALOG oDlg FROM aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL

oTree := DbTree():New( aObj[1,1], aObj[1,2], aObj[1,3], aObj[1,4],oDlg,,,.T.)

oTree:AddTree( PadR( STR0001, 100 ),, "FOLDER5","FOLDER5",,,"0MA-" + PadR( "MAINGR", Len( SA1->A1_COD + SA1->A1_LOJA ) ))

@ aObj[2,1] - 1, aObj[2,2] To aObj[2,3], aObj[2,4] PIXEL

nLin := aObj[2,1] +  8
nCol := aObj[2,2] + 10

MENU oMenu POPUP
	MENUITEM STR0002 Action FT120Menu( @oTree, "INCRP", oMenu ) //"Anexa Cliente"
	MENUITEM STR0003 Action FT120Menu( @oTree, "EXCRP", oMenu ) //"Exclui Cliente"
	MENUITEM STR0004 Action FT120Menu( @oTree, "VISUA", oMenu ) //"Visualiza"
	MENUITEM STR0005 Action FT120Menu( @oTree, "INCGR", oMenu ) //"Anexa grupo"
	MENUITEM STR0006 Action FT120Menu( @oTree, "EXCGR", oMenu ) //"Exclui grupo"
	MENUITEM STR0007 Action FT120Pesq( @oTree )  	 			//"Pesquisa"
	MENUITEM STR0015 Action FT120Menu( @oTree, "CUTCLI", oMenu )  //"Recortar"
	MENUITEM STR0016 Action FT120Menu( @oTree, "PASCLI", oMenu )  //"Colar"
	MENUITEM STR0017 Action FT120Menu( @oTree, "CLRTMP", oMenu ) 	 //"Limpa area temporaria"
ENDMENU

oTree:bRClicked  := { |o,x,y| FT120MAct( o, x, y, oMenu ) } // Posicao x,y em rela豫o a Dialog

@ aObj[2,1] + 24, aObj[2,4] - 32 BUTTON oOpc PROMPT STR0008 ACTION FT120MAct( oTree, oOpc:nRight - 5, oOpc:nTop - 118, oMenu ) SIZE 27, 12 OF oDlg PIXEL  //"Opcoes"

DEFINE SBUTTON FROM aObj[2,1] + 7, aObj[2,4] - 65 TYPE 1 ENABLE OF oDlg ACTION ( nOpca := 1, oDlg:End() )
DEFINE SBUTTON FROM aObj[2,1] + 7, aObj[2,4] - 33 TYPE 2 ENABLE OF oDlg ACTION ( nOpca := 0, oDlg:End() )
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Chama a rotina de construcao do Tree                         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

Processa( { || FT120Monta( @oTree ) }, ,STR0009 )  //"Construindo Estrutura..."

oTree:TreeSeek( "0MA-MAINGR" )
oTree:PTCollapse()

ACTIVATE MSDIALOG oDlg ON INIT Eval(oTree:bChange)

If nOpca == 1
	FT120Grava()
EndIf

RestArea(aArea)
aSize(aArea,0)
FwFreeArray(aSizeAut)
FwFreeArray(aObjects)
aSize(aInfo,0)
FwFreeArray(aObj)
FwFreeArray(aGrupoAtu)
FwFreeArray(aGrupoExc)
aSize(aGrupoBmp,0)
FwFreeArray(aTemp)
Return(.T.)
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    쿑t120Menu � Autor � Sergio Silveira       � Data �13/02/2001낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Acoes efetuadas pelo menu                                  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � FT120Menu( ExpO1, ExpC1, ExpO2 )                           낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   � Logico                                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� ExpO1 -> Objeto Tree / ExpC1 -> ACYo a ser efetuada        낢�
굇�          � ExpO2 -> Objeto Menu                                       낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�   DATA   � Programador   쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�          �               �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function Ft120Menu( oTree, cAction, oMenu )

Local cDesc        := ""
Local cCargo       := ""
Local nScan        := 0
Local nDeleted     := 0
Local nLoop        := 0
Local lFound       := .F.
Local cConsulta	   := "SA1"
Local lOfusca      := FATPDIsObfuscate("A1_NOME") 
Local cFATPDdado   :=""

Private aRotina
Private aGrpTmpExc := {}
Private Inclui     := .T. // Nao retirar


Do Case
Case cAction == "INCRP"
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Inclusao do representante                                    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If ConPad1( ,,,cConsulta, , , .F. )
	
		cCargo := oTree:GetCargo()
		lFound := oTree:TreeSeek( "1US-" + SA1->A1_COD + SA1->A1_LOJA )

		oTree:TreeSeek( cCargo )

		If lFound
			Help(" ",1,"FT120VLCLI")
		Else

			If lOfusca .AND. Empty(cFATPDdado)
				cFATPDdado := FATPDObfuscate(SA1->A1_NOME)
			EndIf

			cDesc := PadR( SA1->A1_COD + "/" + SA1->A1_LOJA + "-" + Iif(Empty(cFATPDdado),Capital( SA1->A1_NOME ),cFATPDdado), 100 )
			oTree:AddItem( cDesc, "1US-" + SA1->A1_COD + SA1->A1_LOJA,"BMPUSER","BMPUSER",,,2)
			oTree:Refresh()

			cGrupo := SubStr( cCargo, 5, Len( ACY->ACY_GRPVEN ) )

			FT120IncRep( cCargo, SA1->A1_COD + SA1->A1_LOJA )
		EndIf
	EndIf

Case cAction == "VISUA"

	cCargo := oTree:GetCargo()

	If Left( cCargo, 3 ) == "1US"

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� VisualizACYo do representante                                �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		aRotina := { { STR0007,"AxPesqui"  , 0 , 1},;  //"Pesquisar"
					{ STR0004,"AxVisual"  , 0 , 2} }  			//"Visualizar"

		SA1->( DbSetOrder( 1 ) )

		If SA1->( DbSeek( xFilial( "SA1" ) + SubStr( cCargo, 5, Len( SA1->A1_COD + SA1->A1_LOJA ) ) ) )
			AxVisual( "SA1", SA1->( Recno() ), 2 )
		EndIf

	ElseIf Left( cCargo, 3 ) == "2GR"

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� VisualizACYo do Grupo                                        �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		aRotina := { { STR0007,"AxPesqui"  , 0 , 1},;  //"Pesquisar"
					{ STR0004,"AxVisual"  , 0 , 2} }  			//"Visualizar"

		ACY->( DbSetOrder( 1 ) )
		If ACY->( DbSeek( xFilial( "ACY" ) + SubStr( cCargo, 5, Len( ACY->ACY_GRPVEN ) ) ) )
			AxVisual( "ACY", ACY->( Recno() ), 2 )
		EndIf

	EndIf

Case cAction == "EXCRP"

	cCargo := oTree:GetCargo()
	SA1->( DbSetOrder( 1 ) )
	SA1->( DbSeek( xFilial( "SA1" ) + SubStr( cCargo, 5, Len( SA1->A1_COD + SA1->A1_LOJA ) ) ) )

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Exclusao do representante                                    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	oTree:DelItem()
	oTree:Refresh()

	FT120ExcRep( cCargo, SA1->A1_COD + SA1->A1_LOJA )

Case cAction == "EXCGR"

	cCargo := oTree:GetCargo()
	ACY->( DbSetOrder( 1 ) )

	cGrupoExc := SubStr( cCargo, 5, Len( ACY->ACY_GRPVEN ) )
	ACY->( DbSeek( xFilial( "ACY" ) + cGrupoExc ) )

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Exclusao do Grupo                                            �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	oTree:DelItem()
	oTree:Refresh()

	aGrpTmpExc := {}

	FT120ExcGrp( cGrupoExc )

	nDeleted := 0

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Exclui do grupo atual os grupos do array de exclusao         �
	//� temporario                                                   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	For nLoop := 1 To Len( aGrpTmpExc )
		If !( Empty( nScan := AScan( aGrupoAtu, { |x| x[1] == aGrpTmpExc[ nLoop ] } ) ) )
			aDel( aGrupoAtu, nScan )
			nDeleted++
		EndIf
	Next nLoop

	ASize( aGrupoAtu, Len( aGrupoAtu ) - nDeleted )
	aGrpTmpExc := {}
	FtRefazACY(aGrupoAtu,"MAINGR")
Case cAction == "INCGR"
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Inclusao do Grupo                                            �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

	If ConPad1( ,,,"ACY", , , .F. )

		cCargo := oTree:GetCargo()
		lFound := oTree:TreeSeek( "2GR-" + ACY->ACY_GRPVEN )

		oTree:TreeSeek( cCargo )

		If lFound
			Help(" ",1,"FT120VLGRP")
		Else

			cDesc := PadR( ACY->ACY_GRPVEN + "-" + Capital( ACY->ACY_DESCRI ), 100 )
			oTree:AddItem( cDesc, "2GR-" + ACY->ACY_GRPVEN, aGrupoBmp[1],aGrupoBmp[2],,,2)
			oTree:TreeSeek( "2GR-" + ACY->ACY_GRPVEN )
			oTree:Refresh()

			FT120IncGrp( cCargo, ACY->ACY_GRPVEN )

		EndIf
	EndIf

Case cAction == "VISGR"

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� VisualizACYo do Grupo                                        �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	aRotina := { { STR0007,"AxPesqui"  , 0 , 1},;  //"Pesquisar"
				{ STR0004,"AxVisual"  , 0 , 2} }  			//"Visualizar"

	ACY->( DbSetOrder( 1 ) )
	cCargo := oTree:GetCargo()
	If ACY->( DbSeek( xFilial( "ACY" ) + SubStr( cCargo, 5, Len( ACY->ACY_GRPVEN ) ) ) )
		AxVisual( "ACY", ACY->( Recno() ), 2 )
	EndIf

Case cAction == "CUTCLI"

	cCargo := oTree:GetCargo()
	SA1->( DbSetOrder( 1 ) )
	SA1->( DbSeek( xFilial( "SA1" ) + SubStr( cCargo, 5, Len( SA1->A1_COD + SA1->A1_LOJA ) ) ) )

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Exclusao do representante                                    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	oTree:DelItem()
	oTree:Refresh()

	Ft120Cut( cCargo, SA1->A1_COD + SA1->A1_LOJA )

Case cAction == "PASCLI"

	Ft120Paste( @oTree )

Case cAction == "CLRTMP"

	Ft120ClTmp()

Case cAction == "RESET"
	oTree:Reset()
EndCase


Return( .T. )

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    쿑t120Chang� Autor � Sergio Silveira       � Data �13/02/2001낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Validacao da TudoOk                                        낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   � Logico                                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� Nenhum                                                     낢�
굇�          �                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�   DATA   � Programador   쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�          �               �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/

Function Ft120Change( oTree )

cLast := oTree:GetCargo()

Return( .T. )

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    쿑T120MAct � Autor � Sergio Silveira       � Data �13/02/2001낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Funcao de chamada do menu                                  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � FT120MAct( ExpO1, ExpN1, ExpN2, ExpO2 )                    낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   � Logico                                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� ExpO1 -> Objeto Tree / ExpN1 -> Dimensao X                 낢�
굇�          � ExpN2 -> Dimensao Y  / ExpO2 -> Objeto Menu                낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�   DATA   � Programador   쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� 13/08/07 � Conrado Q.    �-BOPS 127675: Corre豫o da posi豫o do PopUp. 낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/

Function FT120MAct( oTree, nX, nY, oMenu )
Local lPDWhen := FATPDIsObfuscate("A1_NOME")    
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Desabilita todos os itens do menu                            �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
AEval( oMenu:aItems, { |x| x:Disable() } )

cCargo := oTree:GetCargo()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Habilita as opcoes de acordo com a entidade do tree          �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

If Left( cCargo, 3 ) == "1US"
	
	oMenu:aItems[3]:enable()	
	If !lPDWhen
		oMenu:aItems[2]:enable()
		oMenu:aItems[7]:enable()
	EndIf	
	
ElseIf Left( cCargo, 3 ) == "2GR"
	
	oMenu:aItems[3]:enable()
	
	If !lPDWhen
		If !Empty( aTemp )
			oMenu:aItems[8]:enable()
		EndIf
		oMenu:aItems[1]:enable()
		oMenu:aItems[4]:enable()
		oMenu:aItems[5]:enable()
	EndIf	

ElseIf Left( cCargo, 3 ) == "0MA"
	If !lPDWhen
		oMenu:aItems[4]:enable()		
	EndIf
EndIf

oMenu:aItems[6]:enable()

If !Empty( aTemp )
	oMenu:aItems[9]:enable()
EndIf

If lVisual
	oMenu:aItems[2]:Enable()
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Ativa o Menu PopUp                                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
oMenu:Activate( nX - 5, nY - 130, oTree )

Return(.T.)

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    쿑T120Pesq � Autor � Sergio Silveira       � Data �14/02/2001낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Pesquisa por entidades no Tree                             낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   � Nenhum                                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� oTree: Objeto Tree                                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�   DATA   � Programador   쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�          �               �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/

Function FT120Pesq( oTree )

Local aItems     := {}
Local aSeek      := {}

Local cChavePesq := Space( 20 )
Local cChave     := Space( 20 )
Local cVar       := ""
Local cPictCli   := "@R " + Replicate( "X", Len( SA1->A1_COD ) ) + "/" + Replicate( "X", Len( SA1->A1_LOJA ) )

Local nCombo     := 1
Local nOpca      := 0

Local oCombo
Local oDlg
Local oBut1
Local oBut2
Local oGetPesq

aAdd( aItems, STR0010) // "Cliente"
aAdd( aItems, STR0011) // "Grupo"

aAdd( aSeek, { "1US", 1, cPictCli    , STR0022, "CLL" } )  //"Cliente / Loja"
aAdd( aSeek, { "2GR", 1, "@R XXXXXX" , STR0011, "ACY" } )  //"Grupo"

DEFINE MSDIALOG oDlg TITLE CCADASTRO FROM 09,0 To 21.2,43.5 OF oMainWnd

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
@   0, 0 BITMAP oBmp RESNAME "LOGIN" oF oDlg SIZE 30, 120 NOBORDER WHEN .F. PIXEL

@ 03, 40 SAY STR0012 FONT oBold PIXEL //"Pesquisar Entidade"

@ 14, 30 To 16 ,400 LABEL "" OF oDlg   PIXEL

@ 23, 40 SAY STR0013 SIZE 40, 09 PIXEL //"Entidade"
@ 23, 80 COMBOBOX oCombo VAR cVar ITEMS aItems SIZE 80, 10 OF oDlg PIXEL

@ 35, 40 SAY STR0014  SIZE 40, 09    PIXEL //"Chave"
@ 35, 80 MSGET oGetPesq1 VAR cChave WHEN .F. SIZE 80, 10 VALID .T. PIXEL

@ 48, 40 SAY STR0007 SIZE 40, 09    PIXEL //"Pesquisa"
@ 48, 80 MSGET oGetPesq VAR cChavePesq SIZE 80, 10 VALID .T. PIXEL F3 "XYZZYX"

oGetPesq:bGotFocus := { || oGetPesq:oGet:Picture := aSeek[ oCombo:nAt, 3 ],;
		 cChave := aSeek[ oCombo:nAt, 4 ], oGetPesq:cF3 := aSeek[ oCombo:nAt, 5 ],;
		 oGetPesq1:Refresh() }

DEFINE SBUTTON oBut1 FROM 67,  99  TYPE 1 ACTION ( nOpca := 1, nCombo := oCombo:nAt,;
		oDlg:End() ) ENABLE of oDlg

DEFINE SBUTTON oBut2 FROM 67, 132   TYPE 2 ACTION ( nOpca := 0,;
		oDlg:End() ) ENABLE of oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1
	cChavePesq := RTrim( cChavePesq )
	If !oTree:TreeSeek( aSeek[ nCombo, 1 ] + "-" + cChavePesq )
		Help(" ",1,"FT120VLENT")
	EndIf
EndIf

aSize(aItems,0)
FwFreeArray(aSeek)
Return( .T. )

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    쿑T120IncGrp� Autor � Sergio Silveira      � Data �15/02/2001낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Inclui um grupo nos arrays de controle                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   � Nenhum                                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� oTree: Objeto Tree                                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�   DATA   � Programador   쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�          �               �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/

Function FT120IncGrp( cCargo, cGrupoNovo )

Local cGrupoSup := SubStr( cCargo, 5, Len( ACY->ACY_GRPVEN ) )
Local nScan     := 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Adiciona ao array de grupos atuais                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If Empty( nScan := AScan( aGrupoAtu, { |x| x[1] == cGrupoNovo } )  )
	cChave	:=	FtChaveACY(aGrupoAtu,cGrupoSup)
	aAdd( aGrupoAtu, { cGrupoNovo, cGrupoSup, {}, {}, {}, cChave } )
EndIf

Return( .T. )

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    쿑T120ExcGrp� Autor � Sergio Silveira      � Data �15/02/2001낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Exclui grupos dos arrays de controle                       낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   � Nenhum                                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� oTree: Objeto Tree                                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�   DATA   � Programador   쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�          �               �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/

Function FT120ExcGrp( cGrupoExc )

Local aBackGrpAtu  := AClone( aGrupoAtu )

Local cGrpExcRec := ""
Local cGrpSupRec := ""
Local nScanGrp  := 0
Local nScanSup  := 0
Local nLoop     := 0

nScanGrp := AScan( aGrupoAtu, { |x| x[1] == cGrupoExc } )

If !Empty( nScanGrp )
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Inclui no array de exclusao temporaria                       �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

	aAdd( aGrpTmpExc, cGrupoExc )

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Adiciona ao grupo de excluidos                               �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If Empty( AScan( aGrupoExc, cGrupoExc ) )
		aAdd( aGrupoExc, cGrupoExc )
	EndIf

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Verifica se outros grupos estavam abaixo deste e os exclui tambem �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	ASort( aGrupoAtu,,, { |x,y| y[2] > x[2] } )

	If !Empty( nScanSup := AScan( aGrupoAtu, { |x| x[2] == cGrupoExc } ) )
		For nLoop := nScanSup To Len( aGrupoAtu )
			If aGrupoAtu[ nLoop, 2 ] <> cGrupoExc .OR. Empty( aGrupoAtu[ nLoop, 2 ] )
				Exit
		    EndIf
		    cGrpExcRec := aGrupoAtu[ nLoop,1 ]
		    FT120ExcGrp( cGrpExcRec )
		Next nLoop
	EndIf
EndIf

aGrupoAtu := aClone( aBackGrpAtu )

Return( .T. )

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    쿑T120IncRep� Autor � Sergio Silveira      � Data �15/02/2001낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Inclui os clientes nos arrays de controle                  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   � Nenhum                                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� oTree: Objeto Tree                                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�   DATA   � Programador   쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�          �               �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/

Function FT120IncRep( cCargo, cCodCli )

Local nScanGrp  := 0
Local cGrupoAtu := SubStr( cCargo, 5, Len( ACY->ACY_GRPVEN ) )

If !Empty( nScanGrp := AScan( aGrupoAtu, { |x| x[1] == cGrupoAtu } ) )

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Exclui do array de excluidos deste grupo ( se existir )           �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If !Empty( nScanRepExc := AScan( aGrupoAtu[ nScanGrp, 4 ], cCodCli ) )
		aDel( aGrupoAtu[ nScanGrp, 4 ], nScanRepExc )
	EndIf

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Inclui no array de incluidos                                      �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If Empty( nScanRepInc := AScan( aGrupoAtu[ nScanGrp, 3 ], cCodCli ) )
		aAdd( aGrupoAtu[ nScanGrp, 3 ], cCodCli )
	EndIf

EndIf

Return
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    쿑T120ExcRep� Autor � Sergio Silveira      � Data �15/02/2001낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Exclui os clientes dos arrays de controle                  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � FT120ExcRep( ExpC1, ExpC2 )                                낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   � Nenhum                                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� ExpC1 -> Cargo do Tree / ExpC2 -> Codigo do cliente / Loja 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�   DATA   � Programador   쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�          �               �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/

Function FT120ExcRep( cCargo, cCodCli )

Local nScanGrp     := 0
Local nScanRepInc  := 0
Local nScanRepAtu  := 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Pesquisa primeiro o grupo no array de atuais                      �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
nScanGrp := AScan( aGrupoAtu, { |x| !Empty( nScanRepInc := AScan( x[5], cCodCli ) ) } )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Se nao achar, pesquisa no de incluidos                            �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If Empty( nScanGrp )
	nScanGrp := AScan( aGrupoAtu, { |x| !Empty( nScanRepInc := AScan( x[3], cCodCli ) ) } )
EndIf

If !Empty( nScanGrp )

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Apaga do array incluidos                                          �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If !Empty( nScanRepInc := AScan( aGrupoAtu[ nScanGrp, 3 ], cCodCli ) )
		aDel( aGrupoAtu[ nScanGrp, 3 ], nScanRepInc )
	EndIf

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Apaga do array atuais                                             �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If !Empty( nScanRepAtu := AScan( aGrupoAtu[ nScanGrp, 5 ], cCodCli ) )
		aDel( aGrupoAtu[ nScanGrp, 5 ], nScanRepAtu )
	EndIf

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Inclui no array excluidos                                         �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If Empty( AScan( aGrupoAtu[ nScanGrp, 4 ], cCodCli ) )
		aAdd( aGrupoAtu[ nScanGrp, 4 ], cCodCli )
	EndIf

EndIf

Return( .T. )

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    쿑t120Grava� Autor � Sergio Silveira       � Data �16/02/2001낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Gravacao da Estrutura de clientes                          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   �                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� Nenhum                                                     낢�
굇�          �                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�   DATA   � Programador   쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�07/03/2007쿘ichel W. Mosca쿍ops:120319 - Inclusao do P.E. FT120ADCLI.  낢�
굇�          �               �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function Ft120Grava()

Local aArea			:= GetArea()  							//Armazena a area
Local aRepIncGrv	:= {}									//Array com clientes incluidos no Grupo de Vendas
Local aRepExcGrv	:= {}                   				//Array com cliente excluidos do Grupo de Vendas
Local aRecno		:= {}
Local cGrpBranco	:= Space( Len( SA1->A1_GRPVEN ) )		//Codigo do Grupo de vendas em branco. Utilizado quando um cliente eh excluido
Local nLoop			:= 0                             		//Variavel utilizado em Loop
Local nLoop2		:= 0									//Variavel utilizado em Loop
Local nLoop3		:= 0									//Variavel utilizado em Loop
Local nLoop4		:= 0   									//Variavel utilizado em Loop
Local cUserExc		:= ""
Local cUserAtu		:= ""
Local cFilSA1		:= xFilial("SA1")
Local cFilACY		:= xFilial("ACY")
Local lFT120ADCLI	:= ExistBlock("FT120ADCLI")			//P.E. acionado a cada cliente incluido na estrutura de clientes

Begin Transaction
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Processa os grupos excluidos                                 �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	SA1->(DbSetOrder(6))
	ACY->(DbSetOrder(1))
	For nLoop := 1 To Len( aGrupoExc )
		cGrupoExc := aGrupoExc[ nLoop ]
		If ValType( cGrupoExc ) == "C"
			// Atualiza os usuarios excluidos
			// Obtem a lista de recnos
			aRecno := {}
			If SA1->( DbSeek( cFilSA1 + cGrupoExc ) )
				While SA1->(! Eof() ) .AND. SA1->A1_FILIAL == cFilSA1 .AND. SA1->A1_GRPVEN == cGrupoExc
					aAdd( aRecno, SA1->( Recno() ) )
					SA1->( DbSkip() )
				EndDo
			EndIf

			// Processa a lista
			For nLoop2 := 1 To Len( aRecno )
				SA1->( DbGoTo( aRecno[ nLoop2 ] ) )
				RecLock( "SA1", .F. )
				SA1->A1_GRPVEN := cGrpBranco
				SA1->( MsUnlock() )
			Next nLoop2

			// Atualiza a tabela de grupos
			If ACY->(DbSeek(cFilACY + cGrupoExc))
				RecLock( "ACY", .F. )
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
				//� Grava o grupo superior                                       �
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
				ACY->ACY_GRPSUP := cGrpBranco
				ACY->ACY_CHAVE 	:= ""
				ACY->( MsUnlock() )
				ACY->( DbSkip() )
			EndIf
		EndIf
	Next nLoop

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Processa os grupos incluidos                                 �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	ACY->(DbSetOrder(1))
	For nLoop := 1 To Len( aGrupoAtu )
		cGrupoAtu := aGrupoAtu[ nLoop, 1 ]
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Atualiza a tabela de grupos                                  �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		If ACY->(DbSeek(cFilACY + cGrupoAtu))
			RecLock( "ACY", .F. )
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Grava o grupo superior                                       �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			ACY->ACY_GRPSUP := aGrupoAtu[ nLoop, 2 ]
			ACY->ACY_CHAVE	:= aGrupoAtu[ nLoop, 6 ]
			ACY->( MsUnlock() )
			ACY->( DbSkip() )
		EndIf

		For nLoop4 := 1 To Len( aGrupoAtu[ nLoop, 3 ] )
			aAdd( aRepIncGrv, { cGrupoAtu, aGrupoAtu[ nLoop, 3, nLoop4 ] } )
		Next nLoop4

		For nLoop4 := 1 To Len( aGrupoAtu[ nLoop, 4 ] )
			aAdd( aRepExcGrv, aGrupoAtu[ nLoop, 4, nLoop4 ] )
		Next nLoop4
	Next nLoop

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Atualiza os clientes excluidos                               �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	SA1->(DbSetOrder(1))
	For nLoop2 := 1 To Len( aRepExcGrv )
		cUserExc := aRepExcGrv[ nLoop2 ]
		If ValType( cUserExc ) == "C"
			If SA1->(DbSeek(cFilSA1 + cUserExc))
				RecLock( "SA1", .F. )
				SA1->A1_GRPVEN := cGrpBranco
				SA1->( MsUnlock() )
			EndIf
		EndIf
	Next nLoop2

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Atualiza os clientes incluidos                               �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	SA1->(DbSetOrder(1))
	For nLoop3 := 1 To Len( aRepIncGrv )
		cUserAtu := aRepIncGrv[ nLoop3, 2 ]
		If ValType( cUserAtu ) == "C"
			If SA1->(DbSeek(cFilSA1 + cUserAtu))
				RecLock( "SA1", .F. )
				SA1->A1_GRPVEN := aRepIncGRv[ nLoop3, 1 ]
				SA1->( MsUnlock() )
				If lFT120ADCLI
					ExecBlock("FT120ADCLI", .F., .F., {cUserAtu, aRepIncGRv[ nLoop3, 1 ]})
				EndIf
			EndIf
		EndIf
	Next nLoop3
End Transaction

RestArea(aArea)
aSize(aArea,0)
aSize(aRecNo,0)
FwFreeArray(aRepIncGrv)
FwFreeArray(aRepExcGrv)
Return( .T. )

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    쿑T120Monta� Autor � Sergio Silveira       � Data �16/02/2001낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Faz a chamada da montagem do Tree                          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � FT120Monta( ExpO1 )                                        낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   �                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� ExpO1 ->Objeto Tree                                        낢�
굇�          �                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�   DATA   � Programador   쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�          �               �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

Function FT120Monta( oTree )

Local aRecnoACY	:= {}
Local cCargo    := ""
Local cFilACY	:= xFilial("ACY")
Local nLoop     := 0

oTree:TreeSeek( "0MA-MAINGR" )
cCargo := oTree:GetCargo()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inclui os grupos que tem este grupo como superior            �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
ACY->( DbSetOrder( 2 ) )
If ACY->(DbSeek(cFilACY + "MAINGR"))
	While ACY->(! Eof()) .AND. ACY->ACY_FILIAL == cFilACY .AND. ACY->ACY_GRPSUP == "MAINGR"
		aAdd( aRecnoACY, ACY->( RecNo() ) )
		ACY->( DbSkip() )
	EndDo
EndIf

For nLoop := 1 To Len( aRecnoACY )
	ACY->( DbGoTo( aRecnoACY[ nLoop ] ) )
	FT120MonGr( @oTree, cCargo, ACY->ACY_GRPVEN )
Next nLoop
aSize(aRecnoACY,0)
Return( .T. )

/*/{Protheus.doc} FT120MonGr
Monta o Tree na entrada

@param oTree, objeto, dbTree
@param cCargo, Caracter, Conteudo obtido do metodo GetCargo
@param cGrupoInc, Caracter, Codigo do Grupo de cliente a ser incluido

@return logico, retorno sempre verdadeiro

@author Sergio Silveira
@since 16/02/2001
@version 1.0

@obs
10/08/07 - Conrado Q. -BOPS 127675: Substitui豫o do AddItem por
		AddTree ou AddTreeItem (Dependendo do tipo
		de n�), pois esse tem uma performance
 		superior.

/*/
Function FT120MonGr( oTree, cCargo, cGrupoInc )

Local aRecnoACY  := {}
Local aUserAtu   := {}
Local cCondicao  := ""
Local cOperador  := IIf(Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX","||","+")
Local nLoop      := 0
Local cQuery     := ""
Local cAliasQry  := ""
Local cFilACY    := xFilial("ACY")
Local lOfusca    := FATPDIsObfuscate("A1_NOME")
Local cFATPDdado  :=""

ACY->( DbSetOrder( 1 ) )
If ACY->( DbSeek( cFilACY + cGrupoInc ) )

	aUserAtu := {}

	cDesc := PadR( ACY->ACY_GRPVEN + "-" + Capital( ACY->ACY_DESCRI ), 100 )

	oTree:AddTree( cDesc,, aGrupoBmp[1],aGrupoBmp[2],,,"2GR-" + ACY->ACY_GRPVEN)

	cCargo := "2GR-" + ACY->ACY_GRPVEN

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Inclui os clientes                                                �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	cAliasQry := GetNextAlias()

	cQuery := ""
	cQuery += "SELECT A1_COD, A1_LOJA, A1_NOME FROM " + RetSqlName( "SA1" ) + " SA1 "
	If nModulo == 73 .AND. ( SuperGetMv("MV_CRMESTN",.F.,.F.) )
		cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " AO4 "
		cQuery +=         "ON AO4_FILIAL='" + xFilial( "AO4" ) + "' "
		cQuery +=        "AND AO4_ENTIDA='SA1' "
		cQuery +=        "AND (A1_FILIAL " + cOperador + " A1_COD " + cOperador + " A1_LOJA) = AO4_CHVREG "
		cQuery +=        "AND AO4.D_E_L_E_T_ = ' ' "
		cCondicao := CRMXFilEnt( "SA1", .T. )
		If !Empty( cCondicao )
			cQuery += "AND "
			cQuery += cCondicao
		EndIf
	EndIf
		
	cQuery += "WHERE "
	cQuery += "A1_FILIAL='" + xFilial("SA1") + "' AND "
	cQuery += "A1_GRPVEN='" + ACY->ACY_GRPVEN  + "' AND "

	cQuery += "SA1.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY A1_COD, A1_LOJA"
	cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	While (cAliasQry)->(! Eof())
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//� Inclui no array de atuais ( ja existentes )                       �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		aAdd( aUserAtu, (cAliasQry)->A1_COD + (cAliasQry)->A1_LOJA )
		If lOfusca .AND. Empty(cFATPDdado)
			cFATPDdado := FATPDObfuscate((cAliasQry)->A1_NOME)
		EndIf
		cDesc := PadR( (cAliasQry)->A1_COD + "/" + (cAliasQry)->A1_LOJA + "-" + Iif(Empty(cFATPDdado),Capital( (cAliasQry)->A1_NOME ),cFATPDdado), 100 )
		oTree:AddTreeItem( cDesc,"BMPUSER","BMPUSER", "1US-" + (cAliasQry)->A1_COD + (cAliasQry)->A1_LOJA )
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	DbSelectArea("SA1")
	aAdd( aGrupoAtu, {ACY->ACY_GRPVEN, ACY->ACY_GRPSUP, {}, {}, aUserAtu, Alltrim(ACY->ACY_CHAVE) } )

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Inclui os grupos que tem este grupo como superior            �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cAliasQry := GetNextAlias()
	cQuery    := ""

	cQuery += "SELECT R_E_C_N_O_ ACYRECNO FROM " + RetSqlName( "ACY" ) + " "
	cQuery += "WHERE "
	cQuery += "ACY_FILIAL='" + cFilACY   + "' AND "
	cQuery += "ACY_GRPSUP='" + cGrupoInc + "' AND "
	cQuery += "D_E_L_E_T_ = ' ' ORDER BY ACY_GRPVEN"

	cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	aRecnoACY := {}
	While (cAliasQry)->(! Eof())
		aAdd( aRecnoACY, (cAliasQry)->ACYRECNO )
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	DbSelectArea("ACY")
	For nLoop := 1 To Len( aRecnoACY )
		ACY->( DbGoTo( aRecnoACY[ nLoop ] ) )
		FT120MonGr( @oTree, cCargo, ACY->ACY_GRPVEN )
	Next nLoop

	oTree:EndTree()

EndIf
aSize(aRecnoACY,0)
Return( .T. )

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿑TChaveACY튍utor  쿍runo Sobieski      튔echa �  12/04/01   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿛ega a chave do registro atual do ACY baseandose no grupo   볍�
굇�          퀂uperior.                                                   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡Arametros� aGrupos : Array com os grupos carregados                   볍�
굇�          � cGrpSup : Grupo superior ao atual                          볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP5                                                        볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function FTChaveACY(aGrupos,cGrpSup)

Local cChave	:= ""
Local nStart	:= 0
Local nX		:= 0

Asort(aGrupos,,,{|x,y| x[2]+x[6] < y[2]+y[6]})
nStart	:=	Ascan(aGrupos,{|x| x[2]==cGrpSup})
If nStart >	0
	For nX	:=	nStart	To	Len(aGrupos)
		If cGrpSup <> aGrupos[nX][2]
			Exit
		Endif
	Next
	cChave	:=	Substr(aGrupos[nX-1][6],1,Len(aGrupos[nX-1][6])-2)+Soma1(Substr(aGrupos[nX-1][6],Len(aGrupos[nX-1][6])-1,2))
Else
	nStart	:=	Ascan(aGrupos,{|x| x[1]==cGrpSup})
	If nStart == 0
		cChave	:=	"00"
	Else
		cChave	:=	aGrupos[nStart][6]+"00"
	Endif
Endif
Return	cChave
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿑TRefazACY튍utor  쿍runo Sobieski      튔echa �  12/04/01   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝efaz as chaves do ACY depois de apagar um grupo da estrutu-볍�
굇�          퀁a                                                          볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡Arametros� aGrupos : Array com os grupos carregados                   볍�
굇�          � cGrpSup : Grupo superior ao atual                          볍�
굇�          � cAnt    : Chave do grupo superior (necessaria para compor  볍�
굇�          �           a chave do grupo atual.                          볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP5                                                        볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function FtRefazACY(aGrupos,cGrpSup,cAnt)

Local cCnt		:=	"00"
Local nPosSup	:=	0

If cAnt == Nil
	cAnt	:=	""
	aSort(aGrupos,,,{|x,y| x[2]+X[1] < y[2]+y[1] })
Endif

nPosSup	:=	Ascan(aGrupos,{|x| X[2]==cGrpSup})

While nPosSup	>	0	.AND. nPosSup	<=	Len(aGrupos) .AND. aGrupos[nPosSup][2] == cGrpSup
	aGrupos[nPosSup][6]	:=	cAnt+cCnt
	cCnt	:=	Soma1(cCnt)
	FtRefazACY(aGrupos,aGrupos[nPosSup][1],aGrupos[nPosSup][6])
	nPosSup++
End

Return

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿑TISGRPOK 튍utor  쿍runo Sobieski      튔echa �  03/12/2001 볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿣erifica se o Cliente posicionado pertence ao grupo de      볍�
굇�          � vendas informado.                                          볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros� cGrpVen : Grupo base                                       볍�
굇�          � cGrpCli : Grupo que deve ser avaliado se pertence ao grupo 볍�
굇�          �           base.                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP5                                                        볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function FTISGRPOK(cGrpVen,cGrpCli)

Local cRetorno	:=	""
Local aGrupos  := {}

If Empty(cGrpVen)
	// O grupo pai esta vazio, o que indica que nao tem restricao.
	// Prioridade minima.
	cRetorno	:=	'000000'
ElseIf  cGrpVen == cGrpCli
	// O grupo pai eh o mesmo do grupo filho, prioridade maxima
	cRetorno	:=	'999999'
ElseIf !Empty(SA1->A1_GRPVEN)
	// A prioridade esta definida pelo nivel em que achado o
	// grupo pai, quanto maior o nivel, menor a prioridade.
	MaPrcStrUp( cGrpCli, @aGrupos)
	nPos	:=	Ascan(aGrupos,{|x| x[1] == cGrpVen })
	If nPos > 0
		cRetorno	:=	Str(1000000 - aGrupos[nPos][2],6)
	Endif
Endif

FwFreeArray(aGrupos)
Return cRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    쿑T120Cut  � Autor � Sergio Silveira       � Data �23/05/2002낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Recorta ( cut ) o cliente                                  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � FT120Cut( ExpC1, ExpC2 )                                   낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   � Nil                                                        낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� ExpC1 -> Cargo / ExpC2 -> Chave ( cliente )                낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�   DATA   � Programador   쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�          �               �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/

Function Ft120Cut( cCargo, cChave  )

aAdd( aTemp, { "CLI", cChave } )

FT120ExcRep( cCargo, cChave )

Return()

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    쿑T120Paste� Autor � Sergio Silveira       � Data �23/05/2002낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Cola ( Paste ) a area de trabalho                          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � FT120Paste( ExpO1 )                                        낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   � Nil                                                        낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� ExpO1 -> Objeto tree                                       낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�   DATA   � Programador   쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�          �               �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/

Function Ft120Paste( oTree )

Local cChavePaste := ""
Local cCargo      := ""
Local cDesc       := ""
Local cGrupo      := ""
Local lFound      := .F.
Local nLoop       := 0
Local lOfusca     := FATPDIsObfuscate("A1_NOME")
Local cFATPDdado  :=""

ASort( aTemp, , , { |x,y| y[1] > x[1] } )

If !( Empty( nScan := AScan( aTemp, { |x| x[1] == "CLI" } ) ) )

	For nLoop := nScan To Len( aTemp )

		If aTemp[ nLoop, 1 ] <> "CLI"
			Exit
		EndIf

		cChavePaste := aTemp[ nLoop, 2 ]

		cCargo := oTree:GetCargo()

		lFound := oTree:TreeSeek( "1US-" + cChavePaste )

		oTree:TreeSeek( cCargo )

		If lFound
			Help(" ",1,"FT120VLCLI")
		Else

			SA1->( DbSetOrder( 1 ) )

			SA1->( DbSeek( xFilial( "SA1" ) + cChavePaste ) )

			If lOfusca .AND. Empty(cFATPDdado)
				cFATPDdado := FATPDObfuscate(SA1->A1_NOME)
			EndIf

			cDesc := PadR( SA1->A1_COD + "/" + SA1->A1_LOJA + "-" + Iif(Empty(cFATPDdado),Capital( SA1->A1_NOME ),cFATPDdado), 100 )
			oTree:AddItem( cDesc, "1US-" + SA1->A1_COD + SA1->A1_LOJA,"BMPUSER","BMPUSER",,,2)
			oTree:Refresh()

			cGrupo := SubStr( cCargo, 5, Len( ACY->ACY_GRPVEN ) )

			FT120IncRep( cCargo, cChavePaste )

		EndIf

	Next nLoop

	aTemp := {}

EndIf

Return()

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao    쿑t120ClTmp� Autor � Sergio Silveira       � Data �23/05/2002낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Cola ( Paste ) a area de trabalho                          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � FT120Paste()                                               낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   � Nil                                                        낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros� Nenhum                                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�   DATA   � Programador   쿘anutencao Efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�          �               �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/

Function Ft120ClTmp()

If Aviso( STR0018, STR0019, { STR0020, STR0021 }, 2 ) == 1  //"Atencao"###"Todos os dados da area temporaria serao perdidos. Confirma ?"###"Sim"###"Nao"
	aTemp := {}
EndIf

Return()




//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa fun豫o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usu�rio utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que ser�o verificados.
    @param aFields, Array, Array com todos os Campos que ser�o verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource


//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com prote豫o de dados.
	Remover essa fun豫o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta fun豫o deve utilizada somente ap�s 
    a inicializa豫o das variaveis atravez da fun豫o FATPDLoad.
	Remover essa fun豫o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, L�gico, Retorna se o campo ser� ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa fun豫o quando n�o houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun豫o que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive() 

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
