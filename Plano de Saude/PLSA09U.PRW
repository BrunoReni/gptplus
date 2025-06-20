#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'  
#include "PLSMGER.CH" 
#INCLUDE "TCBROWSE.CH"

#DEFINE PLS_MODELO_CABECALHO	"VIEWDEF.PLSA09U"

Function PLSA09U()
Local oBrowse
	
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('BKU')

oBrowse:AddLegend( "BKU_STATUS=='1'", "BR_VERDE",	"Autorizada" )
oBrowse:AddLegend( "BKU_STATUS=='2'", "BR_LARANJA","Autorizada Parcialmente" )
oBrowse:AddLegend( "BKU_STATUS=='3'", "BR_VERMELHO",	"Nao Autorizada" )       
oBrowse:AddLegend( "BKU_STATUS=='4'", "BR_PRETO"   ,	"Aguardando finalizacao do atendimento"  )
oBrowse:AddLegend( "BKU_STATUS=='5'", "BR_MARRON_OCEAN",	"Aguardando Liq. Titulo a Receber"  )
oBrowse:AddLegend( "BKU_STATUS=='6'", "BR_AZUL",	"Em auditoria"  )
oBrowse:AddLegend( "BKU_STATUS=='7'", "BR_AMARELO",	"Solicita��o em analise"  )
oBrowse:AddLegend( "BKU_STATUS=='8'", "BR_PINK",	"Negado"  )
oBrowse:AddLegend( "BKU_STATUS=='9'", "BR_BRANCO",	"Aguardando Documento"  )
oBrowse:SetDescription('An�lise de Solicita��es de Autoriza��o')
oBrowse:Activate()
	
Return

Static Function MenuDef()

Local aRotina := {}
Local aRotina1 := {}

// Sub menu Atendimento:
aAdd( aRotina1, { 'Solic. SADT'       , 'MenuAte(BKU->BKU_STATUS,"S")'  , 0 , 3 , 0 , NIL } ) //Menu. SADT
aAdd( aRotina1, { 'Solic. Interna��o' , 'MenuAte(BKU->BKU_STATUS,"I")'  , 0 , 3 , 0 , NIL } ) //Menu. Interna��o
aAdd( aRotina1, { 'Solic. Odontologia', 'MenuAte(BKU->BKU_STATUS,"O")'  , 0 , 3 , 0 , NIL } ) //Menu. Odontologia

// Menu Principal
aAdd( aRotina, { 'Pesquisar'         , 'PesqBrw'			             , 0 , 1 , 0 , .T. } ) //Pesquisar
aAdd( aRotina, { 'Visualizar'        ,  PLS_MODELO_CABECALHO	         , 0 , 2 , 0 , NIL } ) //Visualizar
//aAdd( aRotina, { 'Incluir'	     ,  PLS_MODELO_CABECALHO	         , 0 , 3 , 0 , NIL } ) //Incluir
aAdd( aRotina, { 'Negar Solicita��o',  'PLSACANCEL(BKU->BKU_NRPRO,BKU->BKU_STATUS)'  , 0 , 4 , 0 , NIL } ) //Cancelar Solicita��o
//aAdd( aRotina, { 'Excluir'	     ,  PLS_MODELO_CABECALHO	         , 0 , 5 , 0 , NIL } ) //Excluir
//aAdd( aRotina, { 'Imprimir'	     ,  PLS_MODELO_CABECALHO	         , 0 , 8 , 0 , NIL } ) //Imprimir
aAdd( aRotina, { 'Legendas'	         , 'PLSA09LEGE() '	                 , 0 , 9 , 0 , NIL } ) //Legendas
aAdd( aRotina, { 'Vis. Anexos'       , 'PLSA0BCDoc() '	                 , 0 , 10, 0 , NIL } ) //Visualiar Anexos
aAdd( aRotina, { 'Intera��o. Benef ' , 'PLSINTEBKU(BKU->BKU_NRPRO)'      , 0 , 11, 0 , NIL } ) //Intera��o Benef.
aAdd( aRotina, { 'Menu. Atendimento' , aRotina1                          , 0 , 3 , 0 , NIL } ) //Menu. Atendimento


Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruBKU := FWFormStruct( 1, 'BKU', , )
Static oModel


// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PLSA09UMD',/*bPreValidacao*/,/*{|oModel|PLSANRCTVal(oModel) }bPosValidacao*/,/*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields( 'BKUMASTER', NIL, oStruBKU )

// Adiciona chave primaria
oModel:SetPrimaryKey({"BKU_FILIAL","BKU_NRPRO"})


// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'BKUMASTER' ):SetDescription("An�lise de Solicita��es de Autoriza��o") //"An�lise de Solicita��es"

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription('Dados da Solicita��o')//"'Dados da Autoriza��o'"

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()  

// Cria a estrutura a ser usada na View
Local oStruBKU := FWFormStruct( 2, 'BKU' )

Local oModel   := FWLoadModel( 'PLSA09U' )
Local oView    := FWFormView():New()

//As variaveis Private abaixo s�o necessarias por causa do uso da rotina MsDocument
Private aRotina 		:= {}
Private cCadastro   	:= FunDesc()

aRotina := {{'Anexos','MsDocument',0,1},{"Inclus�o R�pida",'PLSDOcs',0,3}}//"Anexos"##"Inclus�o R�pida"


// Define qual o Modelo de dados ser� utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_BKU' , oStruBKU, 'BKUMASTER'   )  


//Adiciona bot�o de conhecimento
oView:AddUserButton("Visualizar Anexo",  "CLIPS", {|| PLSA0BCDoc()   } )//Visualizar Anexo

Return oView  




//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA0BCDoc
Rotina padrao de Banco de Conhecimento
@author  PLS TEAM
@version P12
@since   06/12/2018
/*/
//-------------------------------------------------------------------
Function PLSA0BCDoc() 

Private aRotina 	:= {}
Private cCadastro 	:= FunDesc()

	aRotina := {{'Anexos','MsDocument',0,1},{"Inclus�o R�pida",'PLSDOcs',0,3}}//"Anexos"##"Inclus�o R�pida"
	MsDocument("BKU",BKU->( Recno() ),2)

Return .T.  
      



//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA09LEGE
Rotina que exibi as legendas
@author  PLS TEAM
@version P12
@since   06/12/2018
/*/
//-------------------------------------------------------------------
Function PLSA09LEGE()
Local aLegenda := {} 
aAdd( aLegenda, { "BR_VERDE"         ,	"Autorizada" }) 
aAdd( aLegenda, { "BR_LARANJA"       ,  "Autorizada Parcialmente" }) 
aAdd( aLegenda, { "BR_VERMELHO"      ,	"Nao Autorizada" }) 
aAdd( aLegenda, { "BR_PRETO "        ,	"Aguardando finalizacao do atendimento"  }) 
aAdd( aLegenda, { "BR_MARRON_OCEAN"  ,	"Aguardando Liq. Titulo a Receber" })
aAdd( aLegenda, { "BR_AZUL"          ,	"Em auditoria" })
aAdd( aLegenda, { "BR_AMARELO"       ,	"Solicita��o em analise" })
aAdd( aLegenda, { "BR_PINK"          ,	"Negado"  })
aAdd( aLegenda, { "BR_BRANCO"        ,	"Aguardando Documento"})
BrwLegenda("Legendas" ,, aLegenda )//"Legenda"

Return Nil 




//-------------------------------------------------------------------
/*/{Protheus.doc} MenuAte
// Sub menu Atendimento:
@author  PLS TEAM
@version P12
@since   06/12/2018
/*/
//-------------------------------------------------------------------
Function MenuAte(cStatus,cRotina)

Local cNunAut := BKU->BKU_NUMAUT
Local cBenef  := BKU->BKU_MATUSR

Private aRotina

If(cRotina == "S")
	If cStatus $ "3,4"
		  MsgAlert("A  solicita��o esta cancelada ou nao autorizada !","Aten��o")
		  Return
	ElseIf Empty(cNunAut)
		  //PLSA090("2",.T.)
		  //PLSA090Mov(,,,,,,,,,,,,,,,,, "2",.T.)
		  PLSA090MOV("BEA",0,K_Incluir,nil,nil,nil,.F.,cBenef,nil,nil,nil,nil,nil,nil,nil,nil,nil,"2",.T.)
	Else
	      MsgAlert("J�  foi gerada uma guia para o Protocolo!","Aten��o")	
	      Return    
	EndIf
ElseIf cRotina == "I"

	If cStatus $ "3,4"
		  MsgAlert("A  solicita��o esta cancelada ou nao autorizada !","Aten��o")
		  Return
		  
	ElseIf Empty(cNunAut)			
		  //PLSA092(.T.)
		  PLSA092MOV("BE4",0,K_Incluir,cBenef, nil, nil, .T.)
	Else
	      MsgAlert("J�  foi gerada uma guia para o Protocolo!","Aten��o")
	      Return	 	 
	EndIf
Else

	If cStatus $ "3,4"
		  MsgAlert("A  solicita��o esta cancelada ou nao autorizada !","Aten��o")
		  Return
	ElseIf Empty(cNunAut)
		  //PLS090O("2",.T.)
		  PLS090OMov("B01",0,K_Incluir,nil,nil,cBenef ,NIL,NIL,NIL,NIL,NIL,NIL,NIL,nil, "2", .T.)
	Else
		  MsgAlert("J�  foi gerada uma guia para o Protocolo!","Aten��o")
		  Return	
	EndIf
EndIf


Return




//-------------------------------------------------------------------
/*/{Protheus.doc} GrvVincAut
Rotina que faz o vinculo do protocolo com o numero da autoriza��o gerado pelo usuario do sistema.
@author  PLS TEAM
@version P12
@since   06/12/2018
/*/
//-------------------------------------------------------------------
Function GrvVincAut(cNrAutWeb,cNrProWeb,cStatus,cTpAutWeb)

Local aArea     := GetArea()
Local cPesqAnex := cNrProWeb
Local cTipo     := ""

Default cNrAutWeb := ""
Default cNrProWeb := ""
Default cStatus   := ""

// Defini o Tipo de guia
Do case
      case cTpAutWeb == "O"
            
            // Odonto           
           cTipo := "4"
      case cTpAutWeb == "I"
            
            // Interna
           cTipo := "3" 
      case cTpAutWeb == "S"
              
            // Sadt
           cTipo := "2"
   Otherwise 
           cTipo := ""
EndCase


// Vinculo do protocolo com o numero da autoriza��o.
if PLSALIASEXI("BKU")
	BKU->(DbSelectArea("BKU"))

	if empty(cNrProWeb)
		BKU->(DbSetOrder(2))
		cPesqAnex := cNrAutWeb
	else 
		BKU->(DbSetOrder(1))
	endif	

	If BKU->( msSeek( xFilial("BKU") + cPesqAnex ) )
		While iif(empty(cNrProWeb), BKU->BKU_NUMAUT, BKU->BKU_NRPRO) == cPesqAnex .And. !BKU->(Eof())
			BKU->(RecLock("BKU",.F.))
			BKU->BKU_FILIAL := xFilial("BKU")
			BKU->BKU_NUMAUT := cNrAutWeb
			BKU->BKU_STATUS := cStatus
			
		   	if(!empty(cTipo)) //Se vier vazio, indica que veio a partir da Auditoria e n�o atualiza o tipo.
		    	BKU->BKU_TIPO   := cTipo
		   	endif
		   	
			BKU->(MsUnLock())
			BKU->(DbSkip())
		EndDo
		BKU->(DbCloseArea())	
	EndIf

	RestArea(aArea)
Endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSACANCEL
Cancelamento da solicita��o gerada no Portal.
@author  PLS TEAM
@version P12
@since   06/12/2018
/*/
//-------------------------------------------------------------------
Function PLSACANCEL(cNrPro,cStatus)

Local aArea     := GetArea()
Local cPesqAnex := cNrPro
Local cTexto    := ""
Local lRet      := .F.

If cStatus != "4" .And. cStatus != "3"	
	// Altera o status da solicita��o p cancelada.
	If (MsgYesNo("Deseja realmente negar a solicita��o ?","Aten��o" ))
	   cTexto := PLSA09MENO()
	   lRet := .T.
	EndIf
	
	If lRet
		BKU->(DbSelectArea("BKU"))
		BKU->(DbSetOrder(1))	
		BKU->(dBgOTOP())
		If BKU->( msSeek( xFilial("BKU") + cPesqAnex ) )
			While BKU->BKU_NRPRO == cPesqAnex .And. !BKU->(Eof())
				 BKU->(RecLock("BKU",.F.))
				   BKU->BKU_FILIAL := xFilial("BKU")
				   BKU->BKU_STATUS := "8"
				   BKU->BKU_NEGDES := cTexto
				 BKU->(MsUnLock())
				BKU->(DbSkip())
			EndDo
			BKU->(DbCloseArea())
			MsgInfo("Essa solicita��o foi negada.")	
		EndIf
	EndIF
	
	If !lRet
		Return
	EndIf
ElseIf cStatus == "4"
    MsgAlert("A solicita��o j� esta negada !","Aten��o")
	Return
Else
    MsgAlert("A solicita��o j� esta conluida !","Aten��o")
	Return	
EndIf
RestArea(aArea)
Return




//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA09MENO
Cancelamento da solicita��o gerada no Portal.
@author  PLS TEAM
@version P12
@since   06/12/2018
/*/
//-------------------------------------------------------------------
Static Function PLSA09MENO()

Local cTexto   := ""
Private oDlgM, oLbx, oTexto

DEFINE MSDIALOG oDlgM FROM	62,100 TO 280,500 TITLE "Complemeto de solicita��o de negativa" PIXEL //"Complemeto de Informe de Rendimento"

@ 015, 004 TO 085, 200 Label "Informe o motivo da negativa" OF oDlgM PIXEL
@ 025, 010 GET oTexto VAR cTexto MEMO When .T.  SIZE 178.64, 051 OF oDlgM PIXEL

DEFINE SBUTTON FROM 90,170 TYPE 1 ACTION (oDlgM:End()) ENABLE OF oDlgM

ACTIVATE MSDIALOG oDlgM CENTERED VALID IIf(Empty(Alltrim(cTexto)).OR. !R97VldTxt(cTexto),.F.,.T.)

Return(cTexto)




//-------------------------------------------------------------------
/*/{Protheus.doc} R97VldTxt
Realiza valida��o do Texto digitado 
@author  PLS TEAM
@version P12
@since   06/12/2018
/*/
//-------------------------------------------------------------------
Static Function R97VldTxt(cTexto)

Local cStr:=""
Local nPos1:=0
Local nPos2:=0
Local xValor
Local cQryAux := ""
local nLinhas   := 0
local lRet      := .T.

nLinhas := nLines := MLCount(cTexto)

if nLinhas > 20
	HS_MSGINF("A observa��o informada excede o n�mero m�ximo de linhas" + ; // //"A observa��o informada excede o n�mero m�ximo de linhas que podem ser exibidas no relat�rio (20)."
	chr(13) + chr(10) + chr(13) + chr(10) + "Ajuste o texto a ser impresso."  ; // //"Ajuste o texto a ser impresso."
	,"Valida��o Complemeto de negativas", "Aten��o")// , 			 //"Aten��o"###"Valida��o Complemeto de Informe de Rendimento"
	lRet := .F.
endif

While (nPos1 := At("[", cTexto)) > 0
	If (nPos2 := At("]", cTexto)) > 0
		cStr   := Substr(cTexto, nPos1 + 1 , nPos2 - nPos1 - 1 )
		xValor := &(cStr)
		cQryAux := "'" + xValor + "'"

		cTexto := StrTran(cTexto, "[" + cStr, cQryAux,,1)
		cTexto := StrTran(cTexto, "]", "",,1)
		skip
	EndIf
End

Return(lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} PLSINTEBKU
Visualizar Intera��o
@type function
@version 1.0
/*/
//-------------------------------------------------------------------
Function PLSINTEBKU(cChavePro)

	Static objCENFUNLGP := CENFUNLGP():New()

Local oDlg			:= nil
Local aArea         := GetArea()
Local cCadastro		:= 'Intera��o da analise de solicita��es autoriza��es'
local cTpPublico	:= ''
local cParecer		:= ''
local dData 	    := dDataBase
local aButtons 		:= {}
local oList			:= nil
local cF3 			:= 'BBP'
local cCampoMot 	:= Space(03)
local nOpca			:= 0
local aDadH 		:= {}
local aSize 		:= {}
local lSelecionado 	:= .F.
local nLinhaIni		:= 0
local nColunaIni	:= 0
local cSetor		:= ''
local cAlteraPublico:= ''
local cCodOpe		:= ''
local cSelecionar	:= 'Selecione o Tipo'
local cAlias		:= 'BKU'


Private cObsMotPad	 	:= ""
Private cDesMotPad	 	:= ""
Private cDesMotPadVis	:= ""
Private cObsMotPadVis	:= ""



//Buscando o Setor e a Permiss�o para Alterar o P�blico
DbSelectArea("BX4")
BX4->(DbSetOrder(1))
cChave := xFilial("BX4") + RETCODUSR() + PLSINTPAD()

If BX4->(DbSeek(cChave))
	cSetor 		 := BX4->BX4_CODDEP
	cAlteraPublico := alltrim(BX4->BX4_ALTPUB)
	cCodOpe 		 := BX4->BX4_CODOPE
endif

aSize := MsAdvSize()

nLinhaIni := aSize[1]   + 005  //005
nColunaIni := aSize[2]  + 005 //035

aSize[3] := aSize[3]
aSize[4] := Round(aSize[4] * 0.92,50)
aSize[5] := Round(aSize[5] * 0.57, 0)
aSize[6] := Round(aSize[6] * 0.75, 0)
aSize[7] := Round(aSize[7] * 0.92, 0)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] of oMainWnd PIXEL


@ nColunaIni + 20, nLinhaIni SAY "Intera��o para analise de solicita��es" SIZE 100,010 PIXEL OF oDlg //Desc. Espec
oPanel  := TPanel():New( nColunaIni + 30, nLinhaIni, "",, , .F., , ,, aSize[5]*0.49, 120,.T., .F. )//*0.49

@ 010, 010 SAY oSay3 PROMPT "P�blico:" SIZE 025, 007 OF oPanel PIXEL
@ 017, 010 MSCOMBOBOX oParecer VAR cTpPublico ITEMS {"", "Benefici�rio"} SIZE 055, 010 OF oPanel;
	WHEN cAlteraPublico = '1' ON CHANGE IF(!PlVldInt(,cTpPublico, @cParecer,),cTpPublico := "",)  PIXEL OF oPanel

@ 010, 070 SAY oSay4 PROMPT "Resposta Prest." SIZE 025, 007 OF oPanel PIXEL
@ 017, 070 MSCOMBOBOX oParecer VAR cParecer ITEMS {"N�o","Sim"}  SIZE 030, 010 OF oPanel;
	WHEN /*.T.*/ cTpPublico == "Benefici�rio"  PIXEL OF oPanel

@ 010, 105 SAY oSay5 PROMPT "Motivo Padr�o:" SIZE 040, 007 OF oPanel PIXEL
@ 017, 105 MSGET cCampoMot VAR cSelecionar F3 cF3 VALID ValMotPad(cSelecionar, 'I')  /*VAR cCadastro PICTURE "@!" WHEN .T.*/ SIZE 140,010 PIXEL OF oPanel

@ 017, 250 MSGET cDesMotPad /*VAR cCadastro PICTURE "@!" WHEN .T.*/WHEN .F. SIZE aSize[5]*0.23 /*180*/,010 PIXEL OF oPanel

@ 040,010 SAY "Obs.:" SIZE 100,010 PIXEL OF oPanel //Desc. Espec
@ 047,010 GET cObsMotPad Memo SIZE 200,040 PIXEL OF oPanel


@ nColunaIni + 150, nLinhaIni SAY "Hist�rico de Intera��es de solicita��es" SIZE 100,010 PIXEL OF oDlg //Desc. Espec


oListHist := TCBROWSE():New(nColunaIni + 160,nLinhaIni,aSize[5]*0.49 ,120 ,,;
	{},{40,40},;
	oDlg,,,,, {||},, ,,,,,.F.,,.T.,,.F.,,, )

oListHist:AddColumn(TcColumn():New('Setor',{ || aDadH[oListHist:nAt, 1] },"@C",nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))
oListHist:AddColumn(TcColumn():New('Data Intera��o'  ,{ || aDadH[oListHist:nAt, 2] },"@C",nil,nil,nil,045,.F.,.F.,nil,nil,nil,.F.,nil))
oListHist:AddColumn(TcColumn():New('Mot. Padr�o'   ,{ || aDadH[oListHist:nAt, 3] },"@C",nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))
oListHist:AddColumn(TcColumn():New('Observa��o'   ,{ || aDadH[oListHist:nAt, 4] },"@C",nil,nil,nil,080,.F.,.F.,nil,nil,nil,.F.,nil))

oListHist:BLDBLCLICK := { || if( len(aDadH) > 0, PLSAVISINT(aDadH[oListHist:nAt, 5], cAlteraPublico), ) /*, oList:Refresh()*/ } 

oListHist:bChange :=  {|| oListHist:SetArray(FILITERAR(cChavePro, aDadH, cAlias)), oListHist:Refresh()}

//-------------------------------------------------------------------
//  LGPD
//-------------------------------------------------------------------
	if objCENFUNLGP:isLGPDAt()
		aCampos := {"BBR_SETOR","BBR_DTITER","BBP_DESMOT","BBR_OBSERV"}
		aBls := objCENFUNLGP:getTcBrw(aCampos)

		oListHist:aObfuscatedCols := aBls
	endif

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg ,{|| nOpca := 1,If(CHKSELECT(cDesMotPad, cObsMotPad ),oDlg:End(),nOpca := 2),.F.}, {|| oDlg:End()},.F.,aButtons) Centered

If nOpca == K_OK
	
	if BKU->BKU_STATUS == "7" .or. BKU->BKU_STATUS == "9" 
	
		BBR->(DbSelectArea("BBR"))
	    BBR->(DbSetOrder(4))
		Begin Transaction
			cSeq := PLSBKUSeq(Nil,Nil,BKU->BKU_NRPRO)
			BBR->(RecLock("BBR",.T.))
	
			If empty(cTpPublico)
				BBR->BBR_TPDIRP := Space(TamSx3("BBR_TPDIRP")[1])
			Else
				BBR->BBR_TPDIRP := 'B'
			EndIf
	
			//Altera��o necess�ria pois no momento de anexar um arquivo pelo portal
			//do benefici�rio, n�o existe vinculo direto entre o registrocorrente da intera��o e o procedimento.
			//Desta forma, dificultou muito a altera��o do status no momento ap�s anexar um arquivo.
			If cParecer = "Sim"
				BBR->BBR_RESPRE := .T.
			Else
				BBR->BBR_RESPRE := .F.
			EndIf
	
			BBR->BBR_FILIAL  := xfilial("BBR")
			BBR->BBR_SETOR  := Posicione("SX5",1,xFilial("SX5")+"BL"+cSetor/*BX4->BX4_CODDEP*/,"X5_DESCRI")
			BBR->BBR_CODUSU := cCodOpe
			BBR->BBR_SEQMOP := cSelecionar
			BBR->BBR_DTITER := dData
			BBR->BBR_HRITER := TIME()
	        BBR->BBR_NRPRO  := cChavePro
			BBR->BBR_TPGUIA := "PR"   // Indentifica��o do Protocolo
			BBR->BBR_OBSERV := cObsMotPad
			BBR->BBR_ALIMOV := cAlias
			BBR->BBR_NUMAUT := Substr(cChavePro,13,8) //PADL(CVALTOCHAR(aCampos[4][2]), TamSx3(aCampos[4][1])[1],"0") //BE4_NUMINT
			BBR->BBR_SEQUEN := cSeq
			BBR->(MsUnLock())
	
			MsgInfo('Intera��o salva com sucesso.')  // STR0085 'Intera��o salva com sucesso.'
		End Transaction
	else
		MsgInfo('S� � poss�vel inserir intera��o no protocolo enquanto n�o existe guia gerada.')  
	endif
EndIf


// Altera o Status para a intera��o de acordo com a analise
//-------------------------------------------------------------------
if BKU->BKU_STATUS == "7" .or. BKU->BKU_STATUS == "9"
	If cParecer = "Sim"
		BKU->(DbSelectArea("BKU"))
		BKU->(DbSetOrder(1))	
		BKU->(dBgOTOP())
		If BKU->( msSeek( xFilial("BKU") + cChavePro ))
			 BKU->(RecLock("BKU",.F.))
			   BKU->BKU_FILIAL := xFilial("BKU")
			   BKU->BKU_STATUS := "9"
			 BKU->(MsUnLock())
		EndIf
	EndIf
endif

RestArea(aArea)
Return .T.



//-------------------------------------------------------------------
/*/{Protheus.doc} ValMotPad
Carregar Descri��o e observa��o do motivo padr�o.
@type function
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValMotPad(cSequen, cTpTela)
local lRet := .F.


if cTpTela = 'I'   // Testa se � a tela de inclus�o de intera��o
	cDesMotPad := Posicione("BBP",1,xFilial("BBP")+cSequen,"BBP_DESMOT")
	cObsMotPad := Posicione("BBP",1,xFilial("BBP")+cSequen,"BBP_OBSERV")
else // Se for a tela de visualiza��o da intera��o
	cDesMotPadVis := Posicione("BBP",1,xFilial("BBP")+cSequen,"BBP_DESMOT")
	cObsMotPadVis := BBR->BBR_OBSERV
endIf

If Empty(cSequen)
	lRet := .T.
else
	if Empty(alltrim(cDesMotPad)) .and. Empty(alltrim(cDesMotPadVis))
		lRet := .F.
		alert("Necess�rio selecionar o tipo do motivo!")
	else
		lRet := .T.
	endIf
endIf

Return(lRet)




//-------------------------------------------------------------------
/*/{Protheus.doc} PlVldInt
Valida��o para n�o permitir incluir intera��es direcionadas ao benefici�rio
enquanto existir uma intera��o com o status de aguardando anexo
@type function
/*/
//-------------------------------------------------------------------
Static Function PlVldInt(nPosFlag, cTpPubli, cParecer,oList)
Local lRet  := .T.
Local lFlag := .F.

If lFlag .And. cTpPubli == "Benefici�rio"
	/*
	BBR->(dbSetOrder(1))
	If BBR->(MSSEEK(xFilial("BBR") + B53->B53_NUMGUI))
		
		While BBR->(BBR_CODOPE + BBR_ANOAUT + BBR_MESAUT + BBR_NUMAUT) == B53->B53_NUMGUI
			
			If BBR->BBR_TPDIRP == "B"
				
				lRet := .F.
				/*MarcaLinha(nPosFlag,aDadProc,.F.)
				oList:Refresh()
				MsgAlert(STR0089,;//"Existe uma intera��o aguardando a resposta do benefici�rio. Apenas intera��es internas s�o permitidas.
				STR0028)//"Aten��o"
				
				EXIT
			EndIf
			
			BBR->(DbSkip())
		EndDo
	EndIf
	*/
EndIf

return lRet





//-------------------------------------------------------------------
/*/{Protheus.doc} CHKSELECT
Checa se alguma linha foi selecionada.
@type function
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CHKSELECT(cMotivoPadrao, cMemoObs)

local lSelecionado := .T.

if lSelecionado
	If ( Empty(alltrim(cMotivoPadrao)) .And. Empty(alltrim(cMemoObs)) )
		MsgAlert('� necess�rio preecher o campo Motivo Padr�o ou Observa��o, pois ambos n�o podem ficar vazios.')  //'� necess�rio preecher o campo Motivo Padr�o.'
		lSelecionado := .F.
	endif
endif
	
return(lSelecionado)





//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBKUSeq
Proximo sequencial para a intera��o
@type function
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PLSBKUSeq(cCodOpe,cRotGen, cChave)

Local cSeq   
Local aArea     := GetArea()
Local cMaior := 0

Default cRotGen	:= "0"
Default cChave	:= ""


BBR->(DbSelectArea("BBR"))
BBR->(DbSetOrder(4))	
BBR->(dBgOTOP())
If BBR->(MsSeek(xFilial("BBR") + cChave ))
	
	While !BBR->(Eof()) .And. ((BBR->(IndexOrd())== 4 .and. xFilial("BBR") + cChave == BBR->(BBR_FILIAL+BBR_NRPRO)))
	
		if cMaior <  Val(BBR->BBR_SEQUEN)
			cMaior := Val(BBR->BBR_SEQUEN)
		endif
		
		BBR->(DbSkip())
	Enddo
	cSeq := StrZero(cMaior+1,3)
else
	cSeq := "001"
Endif
RestArea(aArea)
Return(cSeq)




/*/{Protheus.doc} FILLITERA
Carrega Din�micamente Hist�rico
@type function
@version 1.0
/*/
Static Function FILITERAR(cChave, aDadH, cAliasPro)
local nFor
local cMotPadrao
local aTrbHist

aDadH := {}

//BBR_FILIAL+BBR_NRPRO
BBR->( DbSetOrder(4) )
Store Header "BBR" TO aCabHist For .T.
If BBR->( MsSeek( xFilial("BBR")+cChave))
	Store COLS "BBR" TO aDadHist FROM aCabHist VETTRAB aTrbHist While xFilial("BBR")+cChave == BBR->(BBR_FILIAL+BBR_NRPRO)
Else
	Store COLS Blank "BBR" TO aDadHist FROM aCabHist
EndIf

for nFor := 1 to  len(aDadHist)
	cMotPadrao 	:= Posicione("BBP",1,xFilial("BBP")+aDadHist[nFor, 2],"BBP_DESMOT")
	cNomUsr		:= UsrFullName(aDadHist[nFor, 4])
	aadd(aDadH, {aDadHist[nFor, 5], aDadHist[nFor, 6], cMotPadrao, aDadHist[nFor, 16], cChave + aDadHist[nFor, 17], aDadHist[nFor, 7], cNomUsr})
Next

aDadH := ASORT(aDadH,,, { |Intera1,Intera2| DtoS(Intera1[2])+Intera1[6] > DtoS(Intera2[2])+Intera2[6] } )  //Organizar por data+hora a Intera��o. 
	
return aDadH

