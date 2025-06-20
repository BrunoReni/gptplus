#Include 'Protheus.CH'
#Include "ApWizard.ch"
#Include "PCOA485.ch"

//旼컴컴컴컴컴컴컴컴컴컴컴컴�
//쿏EFINES DE NOPC DA ROTINA�
//읕컴컴컴컴컴컴컴컴컴컴컴컴�
#DEFINE VISUALIZAR		2
#DEFINE INCLUIR			3
#DEFINE ALTERAR			4
#DEFINE EXCLUIR			5

Static nQtdEntid := Nil

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿛COA485   튍utor  쿌lvaro Camillo Neto � Data �  19/10/10   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿎adastro de regra de distribui豫o de or�amento              볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                        볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function PCOA485()

Private cCadastro:= STR0001 //"Regras de distribui豫o Or�ament�rias"
Private aRotina  := MenuDef()

dbSelectArea("AMW")
dbSelectArea("AMZ")

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	MBrowse(6,1,22,75,"AMW")
EndIf

Return 


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿛COA485   튍utor  쿌lvaro Camillo Neto � Data �  19/10/10   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿥izard para manuten豫o do cadastro de regra                 볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � TOTVS                                                     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function PCO485Wiz(cAlias, nReg, nOpc)
Local oWizard 		:= Nil
Local lConfirma		:= .F.
Local aPBox1	 	:= {} 
Local lRet 			:= .T.
Local cLinOk  		:= "PCO485LIN()"
Local nOpcX 		:= 0
Local aHeader		:= {}
Local aCols			:= {}
Local aRecNo		:= {}
Local aAlter		:= {} 
Local aRetPer		:= Array(2) 

Private lTemOrc := .F.

Private oGetAMZ

If nOpc <> INCLUIR
	If xFilial("AMW") # AMW->AMW_FILIAL .OR. ( AMW->( Eof() ) .AND. AMW->( Bof() ) )
		Help( " ", 1, "ARQVAZIO" )
		Return
	EndIf
EndIf

If nOpc==INCLUIR .or. nOpc==ALTERAR
	EDITWIZAR := .T.
Else
	EDITWIZAR := .F.
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//쿔ncializa豫o dos array de resposta do parambox�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If nOpc==INCLUIR
	aRetPer[01] 	:= Space( TamSx3('AMW_CODIGO')[1] )
	aRetPer[02] 	:= Space( TamSx3('AMW_DESCR')[1] )
Else
	aRetPer[01] 	:= AMW->AMW_CODIGO
	aRetPer[02] 	:= AMW->AMW_DESCR
EndIf

//Primeira pagina do Wizard
aAdd(aPBox1,{ 1, "* "+STR0003,	Space(TamSx3('AMW_CODIGO')[1]),       "@!"    	 ,""                 ,""  ,"INCLUI",                          0,  .T.}) //"C�digo" 
aAdd(aPBox1,{ 1, "* "+STR0004, Space(TamSx3('AMW_DESCR')[1]),       "@!"    ,""              ,""  ,"EDITWIZAR",                          150,  .T.})//"Descri豫o"           


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿘ontagem do acols da get de modificadores�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
aCpos := {"AMZ_ITEM","AMZ_CLASSE","AMZ_OPER","AMZ_CC","AMZ_ITCTB","AMZ_CLVLR","AMZ_IDENT","AMZ_CHAVE","AMZ_UM","AMZ_PERC"}
aAlter:= {"AMZ_CLASSE","AMZ_OPER","AMZ_CC","AMZ_ITCTB","AMZ_CLVLR","AMZ_IDENT","AMZ_PERC"} 
 
PCOAPrepList (@aCpos,@aAlter)
PCOAVrfUNIORC(@aCpos,@aAlter)

aHeader := GetaHeader("AMZ",aCpos)
aCols	:= CriaAcols(aHeader,"AMZ",1,xFilial("AMZ")+AMW->AMW_CODIGO,nOpc,,'AMZ_ITEM','AMZ_FILIAL+AMZ_CODIGO' ) 

DEFINE WIZARD oWizard TITLE STR0005 ;//"Este assistente lhe ajudar� a cadastrar ou dar manuten豫o nas regras para distribui豫o "
       HEADER STR0006  ; //"Regras de distribui豫o Or�ament�rias"	
       MESSAGE "";
       TEXT STR0007 ;//"Voc� dever� escolher os tipos de entidade utilizados na regra, na sequencia cadastrar as entidades os seus percentuais "
       NEXT {||.T.} ;
       FINISH {|| .T. } ;
       PANEL

	//Segunda Pagina 
   CREATE PANEL oWizard ;
          HEADER STR0008  ; //"Dados da regra de distribui豫o or�ament�ria"
          MESSAGE "";
          BACK {|| .T. } ;
          NEXT {|| Iif(nOpc <> VISUALIZAR, PCO485Next(aRetPer), .T.) } ;
          FINISH {|| .T. } ;
          PANEL

	ParamBox(aPBox1,STR0009, @aRetPer,,,,,,oWizard:GetPanel(2)) //"Par�metros..."

	//Terceira Pagina
   CREATE PANEL oWizard ;
          HEADER STR0010 ; //"Regras de Distribui豫o" 
          MESSAGE STR0011 ;//"Informe a regra de distribui豫o" 
          BACK {|| .T. } ;
          NEXT {|| .T. };
          FINISH {|| Iif(nOpc <> VISUALIZAR,PCO485TOK(@lConfirma),.T.) } ;
          PANEL
          
   If nOpc == INCLUIR .Or. nOpc == ALTERAR
   		nOpcX := GD_INSERT+GD_DELETE+GD_UPDATE 
   EndIf
     
	oGetAMZ	:= MsNewGetDados():New(0,0,90,305,nOpcX,cLinOk, ,"+AMZ_ITEM", aAlter,,,,,,oWizard:GetPanel(3),aHeader,aCols) 
	oGetAMZ:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetAMZ:AddAction("AMZ_IDENT",{||PcoIdentF3("AMZ")})

ACTIVATE WIZARD oWizard CENTERED

If lConfirma
	lRet := PCO485Grv(nOpc,aRetPer[1],aRetPer[2])	
EndIf

Return 

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿛COACompChvRegistro 튍utor  �          � Data �  19/11/11   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Valida豫o da Linha                                         볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                        볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function PCOACompChvRegistro(aCols, cChave, nX, nPosClass, nPosOper, nPosCCusto, nPosItCtb, nPosClVlr, nPosUniOrc,nPosEnt05,nPosEnt06,nPosEnt07,nPosEnt08,nPosEnt09)
Local cChav2	:= "" 								    
Local nCont
Local lRet := .F.

cChav2	:= aCols[nX][nPosClass] + aCols[nX][nPosOper] + aCols[nX][nPosCCusto] + aCols[nX][nPosItCtb] + aCols[nX][nPosClVlr] 

if lTemOrc           
	cChav2	+= aCols[nX][nPosUniOrc]
EndIf

If nQtdEntid == Nil
	If cPaisLoc == "RUS"
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	Else
		nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor.
	EndIf
EndIf

If cPaisLoc != "RUS"
	For nCont := 5 To nQtdEntid
		cChav2	+= aCols[nX][&("nPosEnt"+StrZero(nCont,2))]
	Next nCont
EndIf

	 
if AllTrim (cChave)	== AllTrim (cChav2)					    
	lRet := .T.
EndIf			

Return lRet

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿛CO485Grv 튍utor  쿌lvaro Camillo Neto � Data �  19/10/10   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Rotina de Grava豫o de regra de Distribui豫o                볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                        볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function PCO485Grv(nOpc,cCodigo,cDescricao)
Local nX			:= 0
Local nI 			:= 0
Local aCols 	   		:= oGetAMZ:aCols 
Local aHeader  		:= oGetAMZ:aHeader  
Local nPosItem		:= aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("AMZ_ITEM")})
Local lGrava		:= .F.
Local nItem			:= 1

AMW->(dbSetOrder(1)) //AMW_FILIAL+AMW_CODIGO 
AMZ->(dbSetOrder(1)) //AMZ_FILIAL+AMZ_CODIGO+AMZ_ITEM 

If nOpc == INCLUIR .Or. nOpc == ALTERAR
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿒rava o cabe�alho da tabela�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴�
	lGrava := ( AMW->(dbSeek(xFilial("AMZ")+cCodigo)) )
	RecLock("AMW",!lGrava)
	AMW->AMW_FILIAL := xFilial("AMZ")
	AMW->AMW_CODIGO := cCodigo
	AMW->AMW_DESCR	:= cDescricao
	MsUnLock()
	
	//旼컴컴컴컴컴컴컴컴컴컴컴커
	//쿒rava os Itens da Tabela�
	//읕컴컴컴컴컴컴컴컴컴컴컴켸
	For nX:= 1 to Len(aCols)
		lGrava := ( AMZ->(dbSeek(xFilial("AMZ")+cCodigo+Acols[nX,nPosItem])) )
		If Acols[nX,Len(aHeader)+1] .And. lGrava 
			RecLock("AMZ",!lGrava)
			AMZ->( dbDelete() )
			MsUnlock()
		ElseIf !Acols[nX,Len(aHeader)+1]
			RecLock("AMZ",!lGrava)
			AMZ->AMZ_FILIAL := xFilial("AMZ")
			AMZ->AMZ_CODIGO := cCodigo
			For nI:= 1 to Len(aHeader)
				If Upper(AllTrim(aHeader[nI,2])) == "AMZ_ITEM"
					AMZ->(FieldPut(FieldPos(Trim(aHeader[nI,2])),StrZero(nItem,aHeader[nI,4])))
				Else 
					AMZ->(FieldPut(FieldPos(Trim(aHeader[nI,2])),aCols[nX,nI]))
				EndIf
			Next nI
			nItem++
			MsUnLock()
		EndIf
	Next nX
	
ElseIf nOpc == EXCLUIR
	//旼컴컴컴컴컴컴컴�
	//쿏eleta os Itens�
	//읕컴컴컴컴컴컴컴�
	If AMW->(dbSeek(xFilial("AMZ")+cCodigo))
		RecLock("AMW",.F.)
		AMW->( dbDelete() )
		MsUnlock()
	EndIf
	
	AMZ->(dbSeek(xFilial("AMZ")+cCodigo))
	While AMZ->(!EOF()) .And. AMZ->(AMZ_FILIAL + AMZ_CODIGO ) == xFilial("AMZ")+cCodigo
		RecLock("AMZ",.F.)
		AMZ->( dbDelete() )
		MsUnlock()
		AMZ->(dbSkip())
	EndDo
	
EndIf

Return


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿛CO485Next튍utor  쿌lvaro Camillo Neto � Data �  19/10/10   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Valida os campos do cabe�alho da regra                     볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                        볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function PCO485Next(aRetPer)
Local lRet := .T.

If Empty(aRetPer[1]) .Or. Empty(aRetPer[2])
	HELP("  ",1,"OBRIGAT")
	lRet := .F.
EndIf

If lRet
	lRet := ExistChav("AMW", aRetPer[1], 1) 
EndIf 

Return lRet

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿛CO485LIN 튍utor  쿌lvaro Camillo Neto � Data �  19/10/10   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Valida豫o da Linha                                         볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                        볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function PCO485TOK(lConfirma) 
Local lRet		:= .T.
Local aCols		:= oGetAMZ:aCols 
Local aHeader 	:= oGetAMZ:aHeader                      
Local nPosPerc	:= aScan(aHeader , {|x| Alltrim(x[2]) == "AMZ_PERC" })
Local nX		:= 0
Local nSomaPerc := 0

Default lConfirma	:= .F.

For nX := 1 to Len(aCols)
	If aCols[nX,Len(aHeader)+1] == .F. // Nao soma os deletados
		If !PCO485LIN(nX)
			lRet := .F.
			Exit
		EndIf
		nSomaPerc += aCols[nX][nPosPerc]
	EndIf
Next nX

If lRet 
	If nSomaPerc != 100
		HELP("   ",1,"PC485PERC",,STR0014  ,1,0) //" Percentual Inv�lido "
		lRet := .F.		
	EndIf	
EndIf

lConfirma := lRet 

Return lRet

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿛CO485LIN 튍utor  쿌lvaro Camillo Neto � Data �  19/10/10   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     � Valida豫o da Linha                                         볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � AP                                                        볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Function PCO485LIN(nAt)
Local lRet 		:= .T.         
Local aCols 		:= oGetAMZ:aCols 
Local aHeader 	:= oGetAMZ:aHeader
Local nPosClass	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_CLASSE" })
Local nPosOper	:= aScan(aHeader , {|x| AllTrim(x[2]) == 'AMZ_OPER' })
Local nPosCCusto:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_CC" })
Local nPosItCtb	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_ITCTB" })
Local nPosClVlr	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_CLVLR" })
Local nPosPerc	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_PERC" })
Local nPosItem	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_ITEM" })
Local nPosIdent	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_IDENT" })
Local nPosUM	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_UM" })
Local nPosUniOrc:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_UNIORC" })
Local nPos		:= 0
Local nX		:= 0
Local nSomaPerc := 0
Local aArea		:= GetArea()
Local cChave	:= ""   
Local nCont     := 0
Local bFunfun := {||}

Private nPosEnt05	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_ENT05" })
Private nPosEnt06	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_ENT06" })
Private nPosEnt07	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_ENT07" })
Private nPosEnt08	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_ENT08" })
Private nPosEnt09	:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_ENT09" })

Default nAt := oGetAMZ:nAt  

cChave	:= aCols[nAt][nPosClass] + aCols[nAt][nPosOper] + aCols[nAt][nPosCCusto] + aCols[nAt][nPosItCtb] + aCols[nAt][nPosClVlr]     

if lTemOrc           
	cChave	+= aCols[nAt][nPosUniOrc]
EndIf
	
If nQtdEntid == Nil
	If cPaisLoc == "RUS" 
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	Else
		nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	EndIf
EndIf

If cPaisLoc != "RUS"
	For nCont := 5 To nQtdEntid
		cChave	+= aCols[nAt][&("nPosEnt"+StrZero(nCont,2))]
	Next nCont
EndIf

If lRet
	lRet := MaCheckCols(aHeader,aCols,nAt) 
EndIf

AK6->(dbSetOrder(1))
AK6->(MsSeek(xFilial("AK6")+aCols[nAt][nPosClass]))

aCols[nAt][nPosUM] := &(AK6->AK6_UM)
oGetAMZ:Refresh()

If AK6->AK6_OBRIGA=="1" .And. Empty(aCols[nAt][nPosIdent])
	HELP("  ",1,"PCONOCHAVE")
	lRet	:= .F.
EndIf

If lRet .And. AK6->AK6_OPER=="1" .And. Empty(aCols[nAt][nPosOper])
	HELP("  ",1,"PCONOOPER")
	lRet	:= .F.
EndIf

If lRet
	For nX := 1 to Len(aCols)
		If aCols[nX,Len(aHeader)+1] == .F. // Nao soma os deletados
			If nX != nAt .And. ;
			    PCOACompChvRegistro(aCols, cChave, nX, nPosClass, nPosOper, nPosCCusto, nPosItCtb, nPosClVlr, ;
								    nPosUniOrc,nPosEnt05,nPosEnt06,nPosEnt07,nPosEnt08,nPosEnt09)
				HELP("   ",1,"PC485LINDUP",,STR0013+ aCols[nX][nPosItem]  ,1,0)// "Linha Duplicada no Item " 
				lRet := .F.
				Exit 
			EndIf
			nSomaPerc += aCols[nX][nPosPerc]
		EndIf
	Next nX
EndIf

If lRet 
	If nSomaPerc > 100
		HELP("   ",1,"PC485MAX",,STR0014 ,1,0)//" Percentual Inv�lido "
		lRet := .F.		
	EndIf	
EndIf

RestArea(aArea)
Return lRet

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿎riaAcols 튍utor  쿌lvaro Camillo Neto � Data �  19/10/10   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿑unc�a que cria Acols                                       볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿪Header : aHeader aonde o aCOls ser� baseado                볍�
굇�          쿬Alias  : Alias da tabela                                   볍�
굇�          쿻Indice : Indice da tabela que sera usado para              볍�
굇�          쿬Comp   : Informacao dos Campos para ser comparado no While 볍�
굇�          쿻Opc    : Op豫o do Cadastro                                 볍�
굇�          쿪Cols   : Opcional caso queira iniciar com algum elemento   볍�
굇�          쿬CPO_ITEM: Opcional Campo de item a ser inicializado com '001'굇
굇�          쿬INDICE : Chave de compara豫o da tabela de item             볍�
굇�          쿬CPOMemo: Opcional Nome do campo de c�digo do MEMO          볍�
굇�          쿬Memo   : Nome do campo memo virtual                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       � GENERICO                                                   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Static Function CriaAcols(aHeader,cAlias,nIndice,cComp,nOpc,aCols,cCPO_ITEM,cINDICE,cCPOMemo,cMemo)
Local nX			:= 0
Local nCols		      := 0
Local aArea			:= GetArea()   
Local nPosChave		:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_CHAVE" })
Local nPosClass		:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_CLASSE" }) 
Local nPosIdent		:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_IDENT" }) 
Local nPosUM		:= aScan(aHeader , {|x| AllTrim(x[2]) == "AMZ_UM" }) 

DEFAULT aCols		:= {} 
DEFAULT cCPO_ITEM		:= ""
DEFAULT cCPOMemo		:= ""
DEFAULT cMemo		:= ""

IF nOpc == INCLUIR
	aAdd(aCols,Array(Len(aHeader)+1))
	For nX := 1 To Len(aHeader)
		If Alltrim(aHeader[nX][2]) == cCPO_ITEM
			aCols[1][nX] := STRZERO(1,TamSX3(cCPO_ITEM)[1])
		Else
			aCols[1][nX] := CriaVar(aHeader[nX][2])
		EndIF
	Next nX
	aCols[1][Len(aHeader)+1] := .F.
Else
	(cAlias)->(dbSetOrder(nIndice))
	(cAlias)->(dbSeek(cComp))
	While (cAlias)->(!Eof()) .And. ALLTRIM((cAlias)->(&(cINDICE))) == ALLTRIM(cComp)
		aAdd(aCols,Array(Len(aHeader)+1))
		nCols ++
		For nX := 1 To Len(aHeader)
			If ( aHeader[nX][10] != "V")
				aCols[nCols][nX] := (cAlias)->(FieldGet(FieldPos(aHeader[nX][2])))
			ElseIf (aHeader[nX][8] == "M") // Campo Memo
				aCols[nCols][nX] := MSMM((cAlias)->(&(cCPOMemo)), TamSX3(cMemo)[1] )
			Else
				aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)
			Endif
		Next nX
		
		If !Empty( aCols[nCols][nPosClass] ) .And. !Empty(aCols[nCols][nPosChave])
		
			AK6->(DbSetOrder(1))
			If AK6->(MsSeek( xFilial("AK6") + aCols[nCols][nPosClass] ))
				dbSelectArea(Substr(aCols[nCols][nPosChave],1,3))
				dbSetOrder(If(!Empty(Substr(aCols[nCols][nPosChave] ,4,2)), Val(Substr(	aCols[nCols][nPosChave],4,2)), 1))
				dbSeek(Substr(	aCols[nCols][nPosChave],6,Len(	aCols[nCols][nPosChave] )))
				
				If !Empty(AK6->AK6_VISUAL)
					aCols[nCols][nPosIdent] := &(AK6->AK6_VISUAL)
				EndIf
			EndIF
	
		EndIf		
		aCols[nCols][Len(aHeader)+1] := .F.

		AK6->(DbSetOrder(1))
		If AK6->(MsSeek( xFilial("AK6") + aCols[nCols][nPosClass] )) 
			If !Empty(AllTrim(AK6->AK6_UM))
				aCols[nCols][nPosUM] :=  &(AK6->AK6_UM)
			EndIf
		EndIf

		(cAlias)->(dbSkip())
	End
EndIf
RestArea(aArea)
Return(aCols) 

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿛rograma  쿘enuDef   � Autor � Alvaro Camillo Neto   � Data �19/10/2010낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Utilizacao de menu Funcional                               낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿝etorno   쿌rray com opcoes da rotina.                                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿛arametros쿛arametros do array a Rotina:                               낢�
굇�          �1. Nome a aparecer no cabecalho                             낢�
굇�          �2. Nome da Rotina associada                                 낢�
굇�          �3. Reservado                                                낢�
굇�          �4. Tipo de Transa뇙o a ser efetuada:                        낢�
굇�          �	  1 - Pesquisa e Posiciona em um Banco de Dados           낢�
굇�          �    2 - Simplesmente Mostra os Campos                       낢�
굇�          �    3 - Inclui registros no Bancos de Dados                 낢�
굇�          �    4 - Altera o registro corrente                          낢�
굇�          �    5 - Remove o registro corrente do Banco de Dados        낢�
굇�          �5. Nivel de acesso                                          낢�
굇�          �6. Habilita Menu Funcional                                  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�   DATA   � Programador   쿘anutencao efetuada                         낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�          �               �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Static Function MenuDef()
Private aRotina :=  {}

aAdd(aRotina , { STR0015	,"AxPesqui", 	1, 1} ) //'Pesquisar'
aAdd(aRotina , { STR0016 	,"PCO485Wiz", 	2, 2} ) //'Visualizar'
aAdd(aRotina , { STR0017		,"PCO485Wiz", 	3, 3} ) //'Incluir'
aAdd(aRotina , { STR0018 		,"PCO485Wiz", 	4, 4} ) //'Alterar'
aAdd(aRotina , { STR0019 		,"PCO485Wiz", 	5, 5} ) //'Excluir'


Return(aRotina)                       


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿛rograma  PCOAPrepList       |                       � Data �11/11/2011낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o 쿘onta Lista de nomes de campos das entidades novas          낢�
굇�          �                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇�          �               �                                            낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
static function PCOAPrepList(aArray1, aArray2)                                                        
Local nCont                                                                                     
Local cCampo
Local aAreaAK2		:= GetArea()

If nQtdEntid == Nil
	If cPaisLoc == "RUS" 
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	Else
		nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	EndIf
EndIf           

for nCont := 5 to  nQtdEntid
	if nCont < 10
		cCampo := "AMZ_ENT0" + AllTrim(STR(nCont))
	else
		cCampo := "AMZ_ENT"  + AllTrim(STR(nCont))
	EndIf
                    
	aadd (aArray1, cCampo)     
	aadd (aArray2, cCampo)   
next                 

return 

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컫컴컴컴쩡컴컴컴컴커굇
굇쿑un뇚o    쿛COAVrfUNIORC �                                � Data �02/11/2011낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컨컴컴컴좔컴컴컴컴캑굇
굇쿏escri뇚o 쿣erifica habilita豫o de acesso do usu�rio a UNIDADE OR�AMENT핾IA 낢�
굇�          �                                                                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇쿞intaxe   �                                                                 낢�
굇�          �                                                                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑굇
굇�          �                                                                 낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Static Function PCOAVrfUNIORC(aArray1, aArray2)
Local aAreaAMZ		:= GetArea()
Local cUnidOrc := ''
                
dbSelectArea("AMZ")
dbSetOrder(1)                        

lTemOrc   :=  .F.      

if FieldPos("AMZ_UNIORC") > 0
	lTemOrc := .T.
	aadd (aArray1, "AMZ_UNIORC")     
	aadd (aArray2, "AMZ_UNIORC")     
EndIf 

AMZ->(dbCloseArea())

RestArea(aAreaAMZ)
Return 
