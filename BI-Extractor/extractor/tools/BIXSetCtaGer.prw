#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXSETCTAGER.CH"

#Define CTA_PADRAO 1
#Define CTA_PERSON 2

//-------------------------------------------------------------------
/*/{Protheus.doc} wzdPnlInd
Painel para configuração de equivalência entre indicadores e visões gerenciais

@protected
@author  BI TEAM
@version P11
@since   16/12/2010
/*/
//-------------------------------------------------------------------
function cfgSetCtaGer()
	local oBrowse	:= nil
	local oGet 		:= nil
	local oSay 		:= nil
	local oBtnOk	:= nil
	local oBtnCan	:= nil
	local oDlg		:= nil
	local oRadio	:= nil
	local aColumn 	:= {}
	local aOption	:= {STR0001,STR0002} //"Valores padrões"###"Informar valores"
	local aSetOfBook:= {}
	local aInd		:= BIXLoadCtaGer()
	local cVisao	:= Space(2)
	local cBook		:= BIXBookLoad()
	local nCount	:= 0
	local nRadio	:= 2
	
	private cBIXBOOK:= cBook
	private aBkCtaGe:= {}
	private cBkBook := ""
	Private lLoadFrm:= .T. 

	if ! Empty(cBook)
		aSetOfBook	:= CTBSetOf(cBook)
		cVisao 		:= aSetOfBook[5]
	endif

	criavar("CTS_CODPLA")

	M->CTS_CODPLA := cVisao
	
	Define MSDialog oDlg Title STR0003 From 0,0 TO 320,580 Pixel  //"Configuração dos extratores para área contábil"
    
		//Modo de preenchimento.
		oSay	:= TSay():create(oDlg, {||STR0004},005,005,,,,,,.T.) //"Modo preenchimento:"
		
	    oRadio	:= TRadMenu():New (011,005,aOption,,oDlg,,,,,,,,100,12,,,,.T.)
	    oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)} 
		oRadio:bChange := {|| setCtaGer(nRadio,aInd,oBrowse,oGet)}
	
		//Livro contábil
		oSay := TSay():create(oDlg, {||STR0005},05,180,,,,,,.T.) //"Livro contábil:"
	
		oGet := TGet():Create(oDlg,,15,180,100,008,,,,,,,,.T.,,,,,,,,,"CTN",,,,,.T. )
		oGet:bSetGet :={|x| iif(PCount()>0, setBook(x, @cBook, @cVisao,aSetOfBook), cBook)}
		oGet:bValid  := {|| vldCtn(cBook)}

		//Verifica se ja existe pelo menos um item salvo na HNA
		if len(aInd) > 0 .and. HNA->(dbseek(xFilial("HNA")+aInd[1,1]))
			nRadio 		:= CTA_PERSON
		else
			nRadio 		:= CTA_PADRAO
			oGet:cText	:= "BIX"			
		endif 
	
		aColumn := {TCColumn():New( STR0006, {|| iif( len(aInd)>0, aInd[oBrowse:nAt,1], "" )},,,,"LEFT",060,.F.,.F.), ; //###"Código" //"Código"
					TCColumn():New( STR0007, {|| iif( len(aInd)>0, aInd[oBrowse:nAt,2], "" )},,,,"LEFT",100,.F.,.F.), ; //###"Indicador" //"Indicador"
					TCColumn():New( STR0008, {|| iif( len(aInd)>0, aInd[oBrowse:nAt,3], "" )},,,,"LEFT",100,.F.,.T.) } //###"Visão Gerencial" //"Visão Gerencial"
	
		// Cria Browse
		oBrowse := TCBrowse():New( 35, 05, 280, 100,,,,oDlg,,,,,,,,,,,,,,.T.)
	
		// Adiciona colunas
		for nCount := 1 to len( aColumn )
			oBrowse:AddColumn( aColumn[nCount] )
		next
	   
		// Adicionando as linhas
		oBrowse:SetArray(aInd)
	
		//Evento de duplo click na celula
		oBrowse:blDblClick := {|| BIXEditCbCell( oBrowse, aInd, nil, "BIXCTS", {|x| vldCtGer(M->CTS_CODPLA,x)})}
		
		//Botao OK
		oBtnOk := SButton():Create(oDlg)
		oBtnOk:nLeft 	:= 460
		oBtnOk:nTop   	:= oDlg:nHeight - 60
		oBtnOk:bAction	:= {|| persCtaGer(aInd,nRadio,oGet,oDlg)}		
	
		//Botao Cancelar	
		oBtnCan := SButton():Create(oDlg)
		oBtnCan:nLeft	:= 520
		oBtnCan:nTop    := oDlg:nHeight - 60
		oBtnCan:nType 	:= 2
		oBtnCan:bAction := {|| oDlg:end()}	
		
		//Executa a acao de validacao do botao  
		Eval(oRadio:bChange )
		lLoadFrm:= .F. 
		
	Activate MSDialog oDlg Center
		
return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} loadInd
Carrega os valores digitados anteriormente pelo usuario na variave aInd.

@protected
@author  BI TEAM
@version P11
@since   17/09/2010
@return .T. 
/*/
//-------------------------------------------------------------------  
function BIXLoadCtaGer()
	local nPos 		:= 0
	local aInd 		:= BIXGetIndicadores()

	for nPos := 1 to len(aInd)                                    
		if HNA->(dbseek(xFilial("HNA")+aInd[nPos,1]))
			aadd(aInd[nPos], HNA->HNA_CODVGE)
		else
			aadd(aInd[nPos], StrZero(val(aInd[nPos,1]) ,20))
		endif
	next nPos

return aInd

static function setBook(cValue, cBook, cVisao, aSetOfBook)
	cBook 			:= cValue
	aSetOfBook		:= CTBSetOf(cBook)
	cVisao 			:= aSetOfBook[5]
	M->CTS_CODPLA	:= cVisao
	
return .T.

static function vldCtn(cValue)
	local lRet := .T.

	dbSelectArea("CTN")
	CTN->(dbSetOrder(1))

	if !empty(cValue)
		lRet := CTN->( dbSeek( xFilial("CTN")+cValue) )
	endif

	if lRet
		//variável private que armazena o livro contábil
		cBIXBOOK := cValue
	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} vldCtGer
Valida a conta gerencial selecionada.

@protected
@author  BI TEAM
@version P11
@since   17/09/2010
@return .T. 
/*/
//-------------------------------------------------------------------  
static function vldCtGer(cVisao,xTypedVal)
	local lRet := .T.

	dbSelectArea("CTS")
	CTS->(dbSetOrder(2))

	if !empty(xTypedVal)
		lRet := CTS->( dbSeek( xFilial("CTS")+cVisao+xTypedVal ) )
	endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} persCtaGer
Grava os itens do indicadores das contas gerencias.
@protected
@author  BI TEAM
@version P11
@since   17/09/2010
@return .T. 
/*/
//-------------------------------------------------------------------  
static function persCtaGer(aInd,nType,oGet,oDlg)	
	local nPos 	:= 0
	local cBook := oGet:cText

	//Gravacao das contas	
	for nPos := 1 to len(aInd)                                    

		if nType == CTA_PERSON
			if HNA->(dbseek(xFilial("HNA")+aInd[nPos,1]))
				HNA->(RecLock("HNA",.F.))
			else
				HNA->(RecLock("HNA",.T.))
				HNA->HNA_FILIAL := xFilial("HNA")
				HNA->HNA_CODIND := aInd[nPos,1]
				HNA->HNA_DSCIND := aInd[nPos,2]
			endif
			HNA->HNA_CODVGE := aInd[nPos,3]
			HNA->(MsUnlock())
		else
		    if HNA->(dbseek(xFilial("HNA")+aInd[nPos,1]))
			    HNA->( RecLock("HNA") )
			    	HNA->( DbDelete() ) 
				HNA->( MsUnlock() )   
			endif
		endif
		
	next nPos
	
	//Gravacao do livro.
	if nType == CTA_PERSON	
		if HNA->(dbseek(xFilial("HNA")+"BIX_LIV_"))
			HNA->(RecLock("HNA",.F.))
		else
			HNA->(RecLock("HNA",.T.))
		endif	
		HNA->HNA_FILIAL := xFilial("HNA")
		HNA->HNA_CODIND := "BIX_LIV_"
		HNA->HNA_CODVGE := cBook
		HNA->(MsUnlock())		
	else
		if HNA->(dbseek(xFilial("HNA")+"BIX_LIV_"))
		    HNA->( RecLock("HNA") )
		    	HNA->( DbDelete() ) 
			HNA->( MsUnlock() )   
		endif
	endif
	
	msgInfo(STR0009) //"Configuração atualizada."
	oDlg:end() 
   
return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} setCtaGer
Configura a tela de acordo com o item selecionado no "radion button".
@protected
@author  BI TEAM
@version P11
@since   17/09/2010
@return .T. 
/*/
//-------------------------------------------------------------------  
static function setCtaGer(nType,aInd,oBrowse,oGet)
	local nSeek := ascan(aInd, {|x| ! empty(x[3]) })		
	
	if nType == CTA_PADRAO
		//Caso tenha valores informados, salva o array de indicador para caso o usuário retornar o valor	
		if ! lLoadFrm .And. nSeek > 0
			aBkCtaGe:= aClone(aInd)
			cBkBook	:=	oGet:cText
		endif
		
		Eval({|| aEval(aInd, {|x| x[3] := StrZero( val(x[1]) ,20)} )})
		oBrowse:lReadOnly:= .T.
		oGet:lReadOnly	 := .T.
		oGet:cText		 := "BIX"
	else
		if ! lLoadFrm 

			if len(aInd)  > 0
				oGet:cText := cBIXBOOK
			EndIf
	
			if len(aBkCtaGe) > 0
				aInd := aClone(aBkCtaGe)			
			else
				Eval( {|| aEval(aInd, {|x| x[3] := space(20)} )})
				oGet:cText := Space(03)			
			endif

		EndIf	
		
		oBrowse:lReadOnly	:= .F.				
		oGet:lReadOnly	 	:= .F.		

	endif
	
	oGet:CtrlRefresh()
	oBrowse:Refresh()

Return .T.