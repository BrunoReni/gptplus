#INCLUDE "GFEA085.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static _MVGFEAJDF	:= SuperGetMv("MV_GFEAJDF",,'1')

Static _GWONROCO	:= GFXCP12118("GWO_NROCO")

Static _lPE851		:= ExistBlock("GFEA0851")

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA085

Aprova��o Ajuste de Frete

@author Jorge Matos Valcanaia
@since 10/05/10
@version 1.0

/*/

//-------------------------------------------------------------------

Function GFEA085()
	Local cFiltro
	Local cHoraDe := ""
	Local cHoraAte := ""
	Local cCond := ""
	Private oBrowse

	if !Pergunte("GFEA085",.T.)
		Return nil
	endif

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GWO")				// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA085")		// Nome do fonte onde esta a fun��o MenuDef
	oBrowse:SetDescription("Aprova��o de Ajustes de C�lculos de Frete")	    // Descri��o do browse //"Aprova��o Ajuste de Frete"

	cHoraDe := MV_PAR06
	cHoraAte := MV_PAR07

	cHoraDe := SubStr(cHoraDe, 1, 2) + ":" + SubStr(cHoraDe, 3, 4)
	cHoraAte := SubStr(cHoraAte, 1, 2) + ":" + SubStr(cHoraAte, 3, 4)

	cFiltro := " GWO_NRROM >= '" + MV_PAR01 + "' .AND. GWO_NRROM <= '" + MV_PAR02 + "'"
	cFiltro += " .AND. GWO_DTAJUS >= STOD('" + DToS(MV_PAR04)  + "') .AND. GWO_DTAJUS <= STOD('" + DToS(MV_PAR05) + "')"
	cFiltro += " .AND. GWO_HRAJUS >= '" + cHoraDe + "' .AND. GWO_HRAJUS <= '" + cHoraAte + "'"

	If MV_PAR08 == 1
		cCond := "1"
	Elseif MV_PAR08 == 2
		cCond := "2"
	Elseif MV_PAR08 == 3
		cCond := "3"
	Elseif MV_PAR08 == 4
		cCond := "123"
	EndIf

	cFiltro += " .AND. GWO_SITAJU $ '"+cCond+"'"

	If !Empty(MV_PAR03)
		cFiltro += " .And. Lower(GWO_USRAJU) == '"+Lower(MV_PAR03)+"'"
	Endif

	//Chama a fun��o respons�vel por abrir o pergunte dentro da p�gina(F12)
	SetKey(VK_F12, {||GFEA085PAR()()})

	oBrowse:SetFilterDefault(cFiltro)

	oBrowse:Activate()

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona bot�es do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        OPERATION 1  ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.GFEA085" OPERATION 2  ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004  ACTION "GFEA085APR()"    OPERATION 10 ACCESS 0 //"Aprovar"
	ADD OPTION aRotina TITLE STR0005  ACTION "GFEA085REP()"    OPERATION 11 ACCESS 0 //"Reprovar"

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel

	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost   Code-Block de valida��o do formul�rio de edi��o
	// bCommit Code-Block de persist�ncia do formul�rio de edi��o
	// bCancel Code-Block de cancelamento do formul�rio de edi��o
	oModel := MPFormModel():New("GFEA085", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pr�-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost        Code-Block de valida��o do formul�rio de edi��o
	// bLoad        Code-Block de carga dos dados do formul�rio de edi��o
	oModel:AddFields("GFEA085_GWO", Nil, FWFormStruct(1,"GWO"),/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GWO_FILIAL", "GWO_TPITEM"})

Return oModel

Static Function ViewDef()

	Local oModel := FWLoadModel("GFEA085")
	Local oView  := Nil

	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField ir� representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,S� � necess�ri o caso estamos mundando o ID no View.
	oView:AddField( "GFEA085_GWO" , FWFormStruct(2,"GWO"), /*cLinkID*/ )	//
	// cID		  	Id do Box a ser utilizado
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. � a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas cria��es uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight � na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, � necess�rio informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView( "GFEA085_GWO" , "MASTER" )

	oView:AddUserButton("Consultar ocorr�ncia","MAGIC_BMP",{|oView|ConsOco(oView)})

Return oView

Static Function ConsOco(oView)
	Local oModel := oView:GetModel()
	Local oModelGWO := oModel:GetModel("GFEA085_GWO")
	Local cNrOco := oModelGWO:GetValue("GWO_NROCO")

	If Empty(cNrOco)
		Help( ,, 'HELP',, "N�o h� ocorr�ncia relacionada.", 1, 0)
	Else
		GWD->(dbSetOrder(1))
		If GWD->(dbSeek(xFilial('GWD') + cNrOco))
			FwExecView(,'GFEC032')
		Else
			Help( ,, 'HELP',, "Ocorr�ncia " + cNrOco + " n�o localizada.", 1, 0)
		EndIf
	EndIf
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA085APR

Fun��o que trata a aprova��o do Ajuste feito para o c�lculo

@author Jorge Matos Valcanaia
@since 11/05/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA085APR(lAjusteMenor)
	Local lRet := .T.
	Local lCalCDoc := .F.  // Calculo com documento de frete
	Local lEncontrou := .F.
	Local lBloqueiou := .F.

	Private cMotBloq := "" //Variavel ser� utilizada no GFEA065C
	Default lAjusteMenor := .F. 

	If _GWONROCO .And. !Empty(GWO->GWO_NROCO) .And. !lAjusteMenor
		Help( ,, 'HELP',, "O ajuste de frete est� relacionado � ocorr�ncia " + GWO->GWO_NROCO + ". Para aprov�-lo, aprove a ocorr�ncia.", 1, 0)
		lRet := .F.
	EndIf

	If _MVGFEAJDF == '1'
		GW1->( dbSetOrder(9) )
		GW1->( dbSeek(xFilial("GW1") + AllTrim(GWO->GWO_NRROM)) )
		While !GW1->( Eof() ) .AND. GW1->GW1_FILIAL == xFilial("GW1") .AND. GW1->GW1_NRROM == AllTrim(GWO->GWO_NRROM)

			GW4->( dbSetOrder(2) )
			If GW4->( dbSeek(xFilial("GW4") + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC + GW1->GW1_CDTPDC) )

				GW3->( dbSetOrder(9) )
				If GW3->( dbSeek(xFilial("GW3") + GW4->GW4_SERDF + GW4->GW4_NRDF) )
					If GW3->GW3_SIT == "3" .Or. GW3->GW3_SIT == "4"
						GFEHelp("Existem documentos de frete com a situa��o "+ IF((GW3->GW3_SIT == "3"), '"Aprovado pelo Sistema"', '"Aprovado pelo Usu�rio"') +" relacionados a esse documento de carga, portanto, o ajuste n�o pode ser aprovado.","Desvincular o documento carga deste(s) documento(s) de frete.","Help")
						Return .F.
					EndIf
				EndIf
			EndIf
			GW1->( dbSkip() )
		EndDo

		If !GFEVldLotProvisao(GWO->GWO_NRCALC)
			GFEHelp("C�lculo j� relacionado � Lote de Provis�o.","Realize a exclus�o do Lote de Provis�o.","Help")
			Return .F.
		EndIf
	EndIf

	// In�cio Ponto de Entrada
	If _lPE851
		lRet :=	ExecBlock("GFEA0851",.F.,.F.)
	EndIf
	// Fim Ponto de Entrada
	//Se estiver com situa��o diferente de 1 que � Solicitado apresenta mensagem de erro
	If GWO->GWO_SITAJU <> "1"
		Help( ,, 'HELP',, STR0009, 1, 0) //"Ajuste de Frete j� foi Aprovado/Reprovado"
		lRet := .F.
	ElseIf lRet

		lCalCDoc := GFEA050CAL(GWO->GWO_NRCALC,@lEncontrou,,@lBloqueiou)


		If lBloqueiou
			Return .F.
		EndIf

		If lCalCDoc .And. _MVGFEAJDF == '1'
			Return .F.
		EndIf

		//Se estiver com situa��o 1 Altera o Registro de Solicitado para Aprovado
		RecLock("GWO",.F.)
		GWO->GWO_DTAPRP := DDATABASE
		GWO->GWO_HRAPRP := TIME()
		GWO->GWO_SITAJU	:= "2"
		GWO->GWO_USAPRP	:= cUserName
		MsUnLock("GWO")

		//Chama a fun��o para Atualiza��o de C�lculo/Movimentos do C�lculo/Rateio do C�lculo
		GFEA85ATAJ(GWO->GWO_NRCALC,GWO->GWO_VLAJUS)

		If lEncontrou
			Conferencia() //parametro igual a 2
		EndIf

	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA085REP

Fun��o que trata a Reprova��o do Ajuste feito para o c�lculo

@author Jorge Matos Valcanaia
@since 11/05/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA085REP()
	Local oDlg
	Local cMovRep
	If _GWONROCO .And. !Empty(GWO->GWO_NROCO) .And. FunName() != "GFEA032"
		Help( ,, 'HELP',, "O ajuste de frete est� relacionado � ocorr�ncia " + GWO->GWO_NROCO + ". Para reprov�-lo, exclua ou reprove a ocorr�ncia.", 1, 0)
		Return .F.
	EndIf
	//Se o Ajuste estiver com situa��o diferente de Solicitado apresenta mensagem de erro
	If GWO->GWO_SITAJU <> "1"
		Help( ,, 'HELP',, STR0009, 1, 0) //"Ajuste de Frete j� foi Aprovado/Reprovado"
		Return .F.
	Else
		//Se a situa��o estiver como Solicitado ent�o abre a tela para se informar o motivo da reprova��o
		DEFINE MSDIALOG oDlg TITLE STR0010 From 4,0 To 16,60 OF oMainWnd //"Reprovamento Ajuste de Frete"
		@ 4, 006  SAY STR0011 SIZE 70,7 PIXEL OF oDlg //"Motivo da Reprova��o:"

		oTMultiget1 := TMultiget():New(13,06,{|u|if(Pcount()>0,cMovRep:=u,cMovRep)},oDlg,225,60,,,,,,.T.)
		oTMultiget1:EnableVScroll( .T. )
		oTMultiget1:GoEnd()

		oButtonOK :=tButton():New(75,5,'OK',oDlg,{|| if(GFEA085ROK(cMovRep),oDlg:End(),NIL)},25,10,,,,.T.)
		oButtonCanc :=tButton():New(75, 35, STR0013, oDlg, {||(oDlg:End())},25,10,,,,.T.) //"Cancelar"

		ACTIVATE MSDIALOG oDlg CENTERED
	Endif
	Return

	//-------------------------------------------------------------------
	/*/{Protheus.doc} GFEA085ROK(cMovRep)

	Fun��o do bot�o de OK da tela do motivo da reprova��o

	@Param cMovRep -> Recebe o Motivo do Reprovamento

	@author Jorge Matos Valcanaia
	@since 11/05/10
	@version 1.0
	/*/
//-------------------------------------------------------------------
Function GFEA085ROK(cMovRep)
	//Faz valida��o para que se o motivo da reprova��o n�o tenha sido informado apresente mensagem de erro
	If Empty(cMovRep)
		Help( ,, 'HELP',, STR0012, 1, 0) //"Motivo da Reprova��o deve ser informado"
		Return .F.
	Else
		//Se estiver com Motivo da Reprova��o ent�o Grava os campos abaixo
		RecLock("GWO",.F.)
		GWO->GWO_DTAPRP := DDATABASE
		GWO->GWO_HRAPRP := TIME()
		GWO->GWO_SITAJU := "3"
		GWO->GWO_USAPRP := cUserName
		GWO->GWO_MOTREP := cMovRep
		MsUnLock("GWO")
	Endif
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA085PAR

Fun��o do bot�o de parametros da tela principal do programa

@Param cMovRep -> Recebe o Motivo do Reprovamento

@author Jorge Matos Valcanaia
@since 11/05/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA085PAR()
	Local cCond := ""
	Local cFiltro := ""

	//Abre o grupo de perguntas
	If !Pergunte("GFEA085",.T.)
		return
	Else
		//Utiliza os valores do pergunte para configurar o filtro.
		cHoraDe := MV_PAR06
		cHoraAte := MV_PAR07

		cHoraDe := SubStr(cHoraDe, 1, 2) + ":" + SubStr(cHoraDe, 3, 4)
		cHoraAte := SubStr(cHoraAte, 1, 2) + ":" + SubStr(cHoraAte, 3, 4)

		cFiltro := " GWO_NRROM >= '" + MV_PAR01 + "' .AND. GWO_NRROM <= '" + MV_PAR02 + "'"
		cFiltro += " .AND. GWO_DTAJUS >= STOD('" + DToS(MV_PAR04)  + "') .AND. GWO_DTAJUS <= STOD('" + DToS(MV_PAR05) + "')"
		cFiltro += " .AND. GWO_HRAJUS >= '" + cHoraDe + "' .AND. GWO_HRAJUS <= '" + cHoraAte + "'"

		If MV_PAR08 == 1
			cCond := "1"
		Elseif MV_PAR08 == 2
			cCond := "2"
		Elseif MV_PAR08 == 3
			cCond := "3"
		Elseif MV_PAR08 == 4
			cCond := "123"
		EndIf

		cFiltro += " .AND. GWO_SITAJU $ '"+cCond+"'"

		If !Empty(MV_PAR03)
			cFiltro += " .And. Lower(GWO_USRAJU) == '"+Lower(MV_PAR03)+"'"
		Endif

		//Carrega as informa��es do filtro no oBrowse
		oBrowse:SetFilterDefault(cFiltro)

		//Acessa a Tabela novamente e posiciona no primeiro registro
		dbSelectArea("GWO")
		dbGoTop()
	Endif
	Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA85ATAJ(nNrCalc,nVlAjust,nVlFret)

Fun��o que trata o Ajuste do c�lculo/movimento do c�lculo/rateio do c�lculo

@Param nNrCalc  ->N�mero do c�lculo
@Param nVlAjust ->Valor Ajuste
@Param nVlFret  ->Valor Frete

@author Jorge Matos Valcanaia
@since 11/05/10
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA85ATAJ(nNrCalc,nVlAjust)
	Local nNovoVlAjust  := 0 	// Novo Valor Ajuste
	Local nValorImp     := 0	// Valor do Imposto
	Local nPcApli       := 0    // Percentual Aplicado Valor Frete
	Local nPcApliImp    := 0 	// Percentual Aplicado Imposto
	Local nPcApliPISCOF := 0 	// Percentual Aplicado Imposto
	Local nVlFret	    := 0
	Local lAddImp	    := .F.	// Adiciona ICMS/ISS ao valor do frete
	Local lGWF		    := .T.

	//TQRCES
	nVlFrete 	 := 0
	nVlTotAj 	 := 0
	nImpValor	 := 0
	cJustIfi     := ""
	lImpEmbutido := .F.


	GWF->(dbSetOrder(1))
	If GWF->(dbSeek(xFilial("GWF") + nNrCalc))
		IF GWF->GWF_ADICIS == "1"
			lAddImp := .T.

			If GWF->GWF_IMPOST == "1"
				nValorImp := GWF->GWF_PCICMS
			ElseIf GWF->GWF_IMPOST == "2"
				nValorImp := GWF->GWF_PCISS
			EndIf
		EndIf

		If lAddImp
			nNovoVlAjust := nVlAjust / (1 - nValorImp /100)
		Else
			nNovoVlAjust := nVlAjust
		EndIf

		nVlFret := VLTOTFRET(nNrCalc)
		nPcApli	:= (nVlFret + nNovoVlAjust) / nVlFret

		RecLock("GWF", .F.)
		// ICMS/ISS
		If _GWONROCO
			// N�o altera os campos dos impostos quando gera por ocorr�ncia pois n�o h� como restaurar os valores de impostos quando estes tornam-se 0.
			If !Empty(GWO->GWO_NROCO) 
				lGWF := .F.
			EndIf
		EndIf
		if lGWF 
			If GWF->GWF_IMPOST == "1"
				if GWF->GWF_VLICMS != 0
					nPcApliImp 		:= (GWF->GWF_BASICM + nNovoVlAjust) / GWF->GWF_BASICM
					GWF->GWF_VLICMS *= nPcApliImp
				EndIf
				GWF->GWF_BASICM += nNovoVlAjust
			ElseIf GWF->GWF_IMPOST == "2"
				If GWF->GWF_VLISS != 0
					nPcApliImp 		:= (GWF->GWF_BASISS + nNovoVlAjust) / GWF->GWF_BASISS
					GWF->GWF_VLISS *= nPcApliImp
				EndIf
				GWF->GWF_BASISS += nNovoVlAjust
			EndIf

			// PIS/COFINS
			nPcApliPISCOF	:= (GWF->GWF_BAPICO + nNovoVlAjust) / GWF->GWF_BAPICO

			If GWF->GWF_BAPICO != 0
				GWF->GWF_BAPICO += nNovoVlAjust
			EndIf

			If GWF->GWF_VLPIS != 0
				GWF->GWF_VLPIS  *= nPcApliPISCOF
			EndIf

			If GWF->GWF_VLCOFI != 0
				GWF->GWF_VLCOFI *= nPcApliPISCOF
			EndIf
		EndIf

		// Valor do Ajutes		
		GWF->GWF_VLAJUS += nNovoVlAjust
		MsUnLock("GWF")

		GFERatCal(.F.,GWF->GWF_NRCALC)
	Endif

Return
