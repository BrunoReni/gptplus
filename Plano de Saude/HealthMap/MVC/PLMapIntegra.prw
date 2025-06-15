#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "PLMAPINTEGRA.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLMapIntegra
Browser de Integra��es

@author Vinicius Queiros Teixeira
@since 16/07/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Function PLMapIntegra()

	Local oBrowse := Nil
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("B7E")
	oBrowse:SetDescription(STR0001) // "Integra��es"
    
    oBrowse:AddLegend("B7E_ATIVO == '0'", "RED", STR0002) // "Integra��o Desativa"
    oBrowse:AddLegend("B7E_ATIVO == '1'", "GREEN", STR0003) // "Integra��o Ativa"

    oBrowse:SetMenuDef("PLMapIntegra")
    
	oBrowse:Activate()
		
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu de Integra��es

@author Vinicius Queiros Teixeira
@since 16/07/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.PLMapIntegra" OPERATION MODEL_OPERATION_VIEW ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.PLMapIntegra" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.PLMapIntegra" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.PLMapIntegra" OPERATION MODEL_OPERATION_DELETE ACCESS 0 // "Excluir"
    ADD OPTION aRotina TITLE STR0008 ACTION "PLMapPedidos()" OPERATION MODEL_OPERATION_VIEW ACCESS 0 // "Consultar Pedidos"
	ADD OPTION aRotina TITLE STR0011 ACTION "FwMsgRun(,{|| PLMapProcInteg()},,'"+STR0012+"')" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // "Comunicar Pedidos" ; "Comunicando com a Integra��o..."
	ADD OPTION aRotina TITLE "Comunicar Pedidos em Lote" ACTION "FwMsgRun(,{|| PLLtProcInteg()},,'"+STR0012+"')" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // "Comunicar Pedidos" ; "Comunicando com a Integra��o..."
	ADD OPTION aRotina TITLE STR0023 ACTION "FwMsgRun(,{|| PLMapPedEspGrv()},,'"+STR0024+"')" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // "Gerar Pedidos Em Massa" ; "Gerando Pedidos para a Integra��o..." 
	ADD OPTION aRotina TITLE STR0032 ACTION "FwMsgRun(,{|| PLMapPedStpGrv()},,'"+STR0024+"')" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // "Gerar Pedidos Pelo STAMP" ; "Gerando Pedidos para a Integra��o..." 
	ADD OPTION aRotina TITLE STR0036 ACTION "FwMsgRun(,{|| PLMapConStatus()},,'"+STR0037+"')" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // "Status dos Pedidos" ; ""Consultando Status dos Pedidos da Integra��o..." 

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo das Integra��es

@author Vinicius Queiros Teixeira
@since 16/07/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel := Nil
	Local oStruB7E := FWFormStruct(1, "B7E")

	oModel := MPFormModel():New("PLMapIntegra")
	oModel:SetDescription(STR0009) // "Cadastro de Integra��es"

	oModel:AddFields("MASTERB7E",, oStruB7E)
	oModel:GetModel("MASTERB7E"):SetDescription(STR0010) // "Dados da Integra��o" 
	
	oModel:SetPrimaryKey({})                                                                                                                                                                                                                              
	 
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View das Integra��es

@author Vinicius Queiros Teixeira
@since 16/07/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel("PLMapIntegra")
	Local oView := Nil
	Local oStruB7E := FWFormStruct(2, "B7E")
	
	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("FORM_INTEGRACAO", oStruB7E, "MASTERB7E") 
	oView:EnableTitleView("FORM_INTEGRACAO", STR0010) // "Dados da Integra��o" 

	oView:CreateHorizontalBox("BOX_FORM_INTEGRACAO", 100)
	oView:SetOwnerView("FORM_INTEGRACAO", "BOX_FORM_INTEGRACAO")
	
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PLMapProcInteg
Realiza a Comunica��o da Integra��o posicionada

@author Vinicius Queiros Teixeira
@since 01/09/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Function PLMapProcInteg()

	Local cMsgFinal := ""
	Local cHoraInicial := ""

	If B7E->B7E_ATIVO <> "1"
		MsgInfo(STR0013, STR0014) // "Integra��o Desativada, n�o ser� permitido comunicar." - "Aten��o"
		Return
	EndIf

	If !MsgYesNo(STR0021, STR0022) // "Deseja realizar a comunica��o com a Integra��o para todos os pedidos pendentes?" - "Comunica��o"
		Return
	EndIf

	cHoraInicial := Time()

	aRetorno := ProcComunInteg(B7E->B7E_CODOPE, B7E->B7E_CODIGO, B7E->B7E_ALIAS)

	If aRetorno[1]
		cMsgFinal := STR0015+" <font color='green'><b>"+cValToChar(aRetorno[2])+"</b></font><br>" // "Pedidos Enviados com sucesso:"
		cMsgFinal += STR0016+" <font color='red'><b>"+cValToChar(aRetorno[3])+"</b></font>" // "Pedidos com Falha de Envio:"

		cMsgFinal += "<br><br>"+STR0017+" <b>"+cHoraInicial+"</b><br>"+STR0018+" <b>"+Time()+"</b>" // Hora Inicial: - Hora Final:
		cMsgFinal += "<br>"+STR0019+" <b>"+ElapTime(cHoraInicial, Time())+"</b>" // Tempo de Processamento:
		
		MsgInfo(cMsgFinal, STR0020) // "Resumo da Comunica��o"
	Else
		MsgInfo(STR0025, STR0014) // "N�o foi encontrado nenhum pedido pendente de envio para essa Integra��o." - "Aten��o"
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLLtProcInteg
Realiza a Comunica��o da Integra��o em formato de Lote

@author Gabriel Mucciolo
@since 18/01/2023
@version Protheus 12
/*/
//-------------------------------------------------------------------
Function PLLtProcInteg()

	Local cMsgFinal := ""
	Local cHoraInicial := ""

	If B7E->B7E_ATIVO <> "1"
		MsgInfo(STR0013, STR0014) // "Integra��o Desativada, n�o ser� permitido comunicar." - "Aten��o"
		Return
	EndIf

	cHoraInicial := Time()

	aRetorno := ProcLtComunInteg()

	If aRetorno[1]
		//cMsgFinal := STR0015+" <font color='green'><b>"+cValToChar(aRetorno[2])+"</b></font><br>" // "Pedidos Enviados com sucesso:"
		//cMsgFinal += STR0016+" <font color='red'><b>"+cValToChar(aRetorno[3])+"</b></font>" // "Pedidos com Falha de Envio:"
		cMsgFinal := ""+aRetorno[2]+"<br>"
		cMsgFinal += "<br><br>"+STR0017+" <b>"+cHoraInicial+"</b><br>"+STR0018+" <b>"+Time()+"</b>" // Hora Inicial: - Hora Final:
		cMsgFinal += "<br>"+STR0019+" <b>"+ElapTime(cHoraInicial, Time())+"</b>" // Tempo de Processamento:
		
		MsgInfo(cMsgFinal, STR0020) // "Resumo da Comunica��o"
	Else
		MsgInfo(STR0025, STR0014) // "N�o foi encontrado nenhum pedido pendente de envio para essa Integra��o." - "Aten��o"
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcComunInteg
Processa a Comunica��o de todos os pedidos pendentes de envio da
Integra��o

@author Vinicius Queiros Teixeira
@since 13/09/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function ProcComunInteg(cCodOperadora, cCodIntegra, cAliasIntegra, aAutomacao)

	Local cAliasTemp := ""
    Local cQuery := ""
	Local nQtdEnviado := 0
	Local nQtdFalhou := 0
	Local lProcess := .F.

	Default cCodOperadora := ""
	Default cCodIntegra := ""
	Default cAliasIntegra := ""
	Default aAutomacao := {}

	cAliasTemp := GetNextAlias()
    cQuery := "SELECT B7F.R_E_C_N_O_ RECNO FROM "+RetSQLName("B7F")+" B7F "

    cQuery += " INNER JOIN "+RetSQLName("B7E")+" B7E " 	
	cQuery += "	    ON B7E.B7E_FILIAL = '"+xFilial("B7E")+"'" 
	cQuery += "	    AND B7E.B7E_CODOPE =  '"+cCodOperadora+"' "
	cQuery += "	    AND B7E.B7E_CODIGO = '"+cCodIntegra+"' "
	cQuery += "	    AND B7E.B7E_ALIAS = '"+cAliasIntegra+"' " 
	cQuery += "	    AND B7E.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE B7F.B7F_FILIAL = '"+xFilial("B7F")+"'"
	cQuery += "	  AND B7F.B7F_CODOPE = B7E.B7E_CODOPE"
	cQuery += "	  AND B7F.B7F_CODIGO = B7E.B7E_CODIGO"
    cQuery += "	  AND (B7F.B7F_STATUS = '0' OR B7F.B7F_STATUS = '2')" // Pendente de Envio e Erro de Envio
	cQuery += "   AND B7F.D_E_L_E_T_ = ' ' "

	dbUseArea(.T., "TOPCONN", tcGenQry(,,cQuery), cAliasTemp, .F., .T.)
    
    If !(cAliasTemp)->(Eof())
		lProcess := .T.

        While !(cAliasTemp)->(Eof())
            B7F->(MsGoTo((cAliasTemp)->RECNO))

			If PLMapConnect(.F., .F., aAutomacao)[1]
				nQtdEnviado++
			Else
				nQtdFalhou++
			EndIf

            (cAliasTemp)->(DbSkip())
        EndDo
    EndIf

    (cAliasTemp)->(DbCloseArea())

Return {lProcess, nQtdEnviado, nQtdFalhou}

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcLtComunInteg
Processa a Comunica��o do Lote de pedidos pendentes de envio da 
Integra��o

@author Gabriel Mucciolo
@since 18/01/2023
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function ProcLtComunInteg(aAutomacao)

	Local aRet := {}
	Default aAutomacao := {}

	aRet := PLLtConnect(.F., aAutomacao)
	//lProcess, cMsg
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLMapPedEspGrv
Realiza a Grava��o em massa dos pedidos 

@author Vinicius Queiros Teixeira
@since 10/09/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Function PLMapPedEspGrv()

	Local cMsgFinal := ""
	Local cHoraInicial := ""
	Local aRetorno := {}
	Local cCodOperadora := Alltrim(B7E->B7E_CODOPE)
	Local cCodIntegra := Alltrim(B7E->B7E_CODIGO)
	Local cClasseStamp := Alltrim(B7E->B7E_CLASTP)
	Local cPergunte := Alltrim(B7E->B7E_PERGGE)

	cHoraInicial := Time()

	aRetorno := GravaPedPerg(cCodOperadora, cCodIntegra, cClasseStamp, cPergunte)

	If aRetorno[1]
		cMsgFinal := STR0026+" <font color='green'><b>"+cValToChar(aRetorno[3][1])+"</b></font><br>" // "Pedidos Gerados:"
		cMsgFinal += STR0027+" <font color='orange'><b>"+cValToChar(aRetorno[3][2])+"</b></font><br>" // "Pedidos j� Existente:"
		cMsgFinal += STR0028+" <font color='red'><b>"+cValToChar(aRetorno[3][3])+"</b></font>" // "Falha na Gera��o:"

		cMsgFinal += "<br><br>"+STR0017+" <b>"+cHoraInicial+"</b><br>"+STR0018+" <b>"+Time()+"</b>" // Hora Inicial: - Hora Final:
		cMsgFinal += "<br>"+STR0019+" <b>"+ElapTime(cHoraInicial, Time())+"</b>" // Tempo de Processamento:
				
		MsgInfo(cMsgFinal, STR0029) // "Resumo da Gera��o"
	Else
		If !Empty(aRetorno[2])
			MsgInfo(aRetorno[2], STR0014) // "Aten��o"
		EndIf
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GravaPedPerg
Grava os pedidos da Integra��o de Acordo com os par�metros do pergunte

@author Vinicius Queiros Teixeira
@since 01/09/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function GravaPedPerg(cCodOperadora, cCodIntegra, cClasseStamp, cPergunte)

	Local lGravacao := .T.
	Local cMsgInfo := ""
	Local oPergunte	:= Nil
	Local aPergunte := {}
	Local aResultado := {}
	Local oIntegration := Nil

	Default cCodOperadora := ""
	Default cCodIntegra := ""
	Default cClasseStamp := ""
	Default cPergunte := ""

	If !Empty(cPergunte) .And. !Empty(cClasseStamp)

		oPergunte := FwSx1Util():New()
		oPergunte:AddGroup(cPergunte)
		oPergunte:SearchGroup()
		aPergunte := oPergunte:GetGroup(cPergunte)

		If !Empty(aPergunte[2])
			If Pergunte(cPergunte, .T.)

				oIntegration := &(cClasseStamp+"():New()")
				oIntegration:Setup(cCodOperadora, cCodIntegra,, .F.)
				oIntegration:SetDadosEsp(.T.)			
				oIntegration:ProcessDados()            
				
				aResultado := oIntegration:GetResult()

				FreeObj(oIntegration)
        		oIntegration := Nil
			Else
				lGravacao := .F.
			EndIf
		Else
			lGravacao := .F.
			cMsgInfo := STR0030 // "Pergunte informado invalido, verifique o cadastro da Integra��o."
		EndIf

		FreeObj(oPergunte)
        oPergunte := Nil
	Else
		lGravacao := .F.
		cMsgInfo := STR0031 // "Para gerar os pedidos da Integra��o, � obrigat�rio informar o Pergunte e a Classe Stamp no Cadastro!"
	EndIf

Return {lGravacao, cMsgInfo, aResultado}


//-------------------------------------------------------------------
/*/{Protheus.doc} PLMapPedStpGrv
Realiza a Grava��o pelo STAMP dos Pedidos

@author Vinicius Queiros Teixeira
@since 21/10/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Function PLMapPedStpGrv()

	Local cMsgFinal := ""
	Local cHoraInicial := ""
	Local aRetorno := {}
	Local cCodIntegra := Alltrim(B7E->B7E_CODIGO)
	Local cClasseStamp := Alltrim(B7E->B7E_CLASTP)

	cHoraInicial := Time()

	aRetorno := GravaPedStamp(cCodIntegra, cClasseStamp)

	If aRetorno[1]
		cMsgFinal := STR0026+" <font color='green'><b>"+cValToChar(aRetorno[3][1])+"</b></font><br>" // "Pedidos Gerados:"
		cMsgFinal += STR0027+" <font color='orange'><b>"+cValToChar(aRetorno[3][2])+"</b></font><br>" // "Pedidos j� Existente:"
		cMsgFinal += STR0028+" <font color='red'><b>"+cValToChar(aRetorno[3][3])+"</b></font>" // "Falha na Gera��o:"

		cMsgFinal += "<br><br>"+STR0017+" <b>"+cHoraInicial+"</b><br>"+STR0018+" <b>"+Time()+"</b>" // Hora Inicial: - Hora Final:
		cMsgFinal += "<br>"+STR0019+" <b>"+ElapTime(cHoraInicial, Time())+"</b>" // Tempo de Processamento:
				
		MsgInfo(cMsgFinal, STR0029) // "Resumo da Gera��o"
	Else
		If !Empty(aRetorno[2])
			MsgInfo(aRetorno[2], STR0014) // "Aten��o"
		EndIf
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GravaPedStamp
Grava os pedidos da Integra��o de Acordo com o STAMP das Tabelas

@author Vinicius Queiros Teixeira
@since 21/10/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function GravaPedStamp(cCodIntegra, cClasseStamp)

	Local lGravacao := .T.
	Local cMsgInfo := ""
	Local cCodOperadora := ""
	Local cDataStamp := ""
	Local oPergunte	:= Nil
	Local aPergunte := {}
	Local aResultado := {}
	Local oIntegration := Nil
	Local cPergunte := "PLRMPSTAMP"

	Default cCodIntegra := ""
	Default cClasseStamp := ""

	If !Empty(cClasseStamp)

		oPergunte := FwSx1Util():New()
		oPergunte:AddGroup(cPergunte)
		oPergunte:SearchGroup()
		aPergunte := oPergunte:GetGroup(cPergunte)

		If !Empty(aPergunte[2])
			If Pergunte(cPergunte, .T.)

				cCodOperadora := MV_PAR01
				cDataStamp := IIf(Empty(MV_PAR02), "", DToS(MV_PAR02))

				If !Empty(cCodOperadora) .And. !Empty(cDataStamp)
					oIntegration := &(cClasseStamp+"():New()")
					oIntegration:Setup(cCodOperadora, cCodIntegra, cDataStamp)	
					oIntegration:ProcessDados()      
					
					aResultado := oIntegration:GetResult()

					FreeObj(oIntegration)
					oIntegration := Nil
				Else
					lGravacao := .F.
					cMsgInfo := STR0033 // "Operadora ou data STAMP n�o informados nos par�metros do pergunte."
				EndIf
			Else
				lGravacao := .F.
			EndIf
		Else
			lGravacao := .F.
			cMsgInfo := STR0034 // "Pergunte 'PLRMPSTAMP' n�o cadastrado no dicion�rio de dados (SX1)."
		EndIf

		FreeObj(oPergunte)
        oPergunte := Nil
	Else
		lGravacao := .F.
		cMsgInfo := STR0035 // "Para gerar os pedidos da Integra��o, � obrigat�rio informar a Classe Stamp no Cadastro!"
	EndIf

Return {lGravacao, cMsgInfo, aResultado}


//-------------------------------------------------------------------
/*/{Protheus.doc} PLMapConStatus
Consulta o status do pedidos da Integra��o

@author Vinicius Queiros Teixeira
@since 03/11/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Function PLMapConStatus()

	Local cMsgFinal := ""
	Local cHoraInicial := ""
	Local aRetorno := {}
	Local cCodOperadora := Alltrim(B7E->B7E_CODOPE)
	Local cCodIntegra := Alltrim(B7E->B7E_CODIGO)

	cHoraInicial := Time()

	aRetorno := GetStatusIntegra(cCodOperadora, cCodIntegra)
	                                                        
	cMsgFinal := STR0038+": <font color='blue'><b>"+cValToChar(aRetorno[1])+"</b></font><br>" // "Pendente de Envio"
	cMsgFinal += STR0039+": <font color='green'><b>"+cValToChar(aRetorno[2])+"</b></font><br>" // "Envio Realizado"
	cMsgFinal += STR0040+": <font color='red'><b>"+cValToChar(aRetorno[3])+"</b></font><br>" // "Erro de Envio"
	cMsgFinal += STR0041+": <font color='red'><b>"+cValToChar(aRetorno[4])+"</b></font>" // "Envio Cancelado"

	cMsgFinal += "<br><br>"+STR0017+" <b>"+cHoraInicial+"</b><br>"+STR0018+" <b>"+Time()+"</b>" // Hora Inicial: - Hora Final:
	cMsgFinal += "<br>"+STR0019+" <b>"+ElapTime(cHoraInicial, Time())+"</b>" // Tempo de Processamento:
				
	MsgInfo(cMsgFinal, STR0042) // "Resumo da Consulta"
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetStatusIntegra
Retorna os Status dos Pedidos da Integra��o

@author Vinicius Queiros Teixeira
@since 03/11/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function GetStatusIntegra(cCodOperadora, cCodIntegra)

	Local aStatus := {0, 0, 0, 0} // 0=Pendente de Envio;1=Envio Realizado;2=Erro de Envio;3=Envio Cancelado
	Local cQuery := ""
	Local cAliasTemp := ""

	cAliasTemp := GetNextAlias()
    cQuery := " SELECT B7F.B7F_STATUS, COUNT(B7F.B7F_CODPED) QTD_PEDIDOS FROM "+RetSQLName("B7F")+" B7F "
	cQuery += "  WHERE B7F.B7F_FILIAL = '"+xFilial("B7F")+"'"
	cQuery += "	   AND B7F.B7F_CODOPE = '"+cCodOperadora+"'"
    cQuery += "	   AND B7F.B7F_CODIGO = '"+cCodIntegra+"'"
	cQuery += "    AND B7F.D_E_L_E_T_= ' ' "
	cQuery += " GROUP BY B7F_STATUS"

	dbUseArea(.T., "TOPCONN", tcGenQry(,,cQuery), cAliasTemp, .F., .T.)
	        
	If !(cAliasTemp)->(Eof())
		While !(cAliasTemp)->(Eof())

			Do Case
				Case (cAliasTemp)->B7F_STATUS == "0"
					aStatus[1] += (cAliasTemp)->QTD_PEDIDOS

				Case (cAliasTemp)->B7F_STATUS == "1"
					aStatus[2] += (cAliasTemp)->QTD_PEDIDOS

				Case (cAliasTemp)->B7F_STATUS == "2"
					aStatus[3] += (cAliasTemp)->QTD_PEDIDOS

				Case (cAliasTemp)->B7F_STATUS == "3"
					aStatus[4] += (cAliasTemp)->QTD_PEDIDOS
			EndCase

            (cAliasTemp)->(DbSkip())
        EndDo				
    EndIf

    (cAliasTemp)->(DbCloseArea())

Return aStatus


//-------------------------------------------------------------------
/*/{Protheus.doc} PLMapIntAviso
Realiza a grava��o e comunica��o do pedido da Integra��o de Aviso
de Interna��o

@author Vinicius Queiros Teixeira
@since 06/10/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Function PLMapIntAviso(cOpeInt, cAnoInt, cMesInt, cNumInt, lComunica, aAutomacao,cAliasInt)

	Local lGravacao := .F.
	Local lEnvio := .F.
	Local nX := 0
	Local cClasseStamp := ""
	Local cCodIntegra := ""
	Local aIntegraInt := {}
	Local oIntegration := Nil

	Default aAutomacao := {}
	Default lComunica := .T.
	Default cAliasInt := "BE4"

	If PLSAliasExi("B7E")

		aIntegraInt := PLMapGetIntegra(cOpeInt, cAliasInt)

		If Len(aIntegraInt) > 0
			
			B7E->(DbSetOrder(1))
			For nX := 1 To Len(aIntegraInt)
				cCodIntegra := aIntegraInt[nX]

				If B7E->(MsSeek(xFilial("B7E")+cOpeInt+cCodIntegra)) .And. !Empty(B7E->B7E_CLASTP)

					cClasseStamp := Alltrim(B7E->B7E_CLASTP)

					oIntegration := &(cClasseStamp+"():New()")
					oIntegration:Setup(cOpeInt, cCodIntegra,, .F.)
					oIntegration:SetDadosEsp(.F., cAnoInt, cMesInt, cNumInt)
					oIntegration:ProcessDados() // Grava Pedido para o Aviso de Interna��o

					lGravacao := oIntegration:GetResult()[1] > 0 .Or. oIntegration:GetResult()[2] > 0   
					
					If lGravacao .And. !Empty(B7E->B7E_CLACOM) .And. lComunica
						// Comunica pedido com a Integra��o
						If PLMapConnect(.F., .F., aAutomacao)[1]
							lEnvio := .T.
						EndIf
					EndIf

					FreeObj(oIntegration)
					oIntegration := Nil

				EndIf
			Next nX

		EndIf

	EndIf

Return {lGravacao, lEnvio}


//-------------------------------------------------------------------
/*/{Protheus.doc} PLMapGetIntegra
Retorna as Integra��es de acordo os par�metros

@author Vinicius Queiros Teixeira
@since 06/10/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Function PLMapGetIntegra(cOperadora, cAlias)

	Local aIntegracoes := {}
    Local cQuery := ""
    Local cAliasTemp := ""

	Default cOperadora := ""
	Default cAlias := ""

    cAliasTemp := GetNextAlias()
    cQuery := "SELECT B7E.B7E_CODIGO FROM "+RetSQLName("B7E")+" B7E "
	cQuery += " WHERE B7E.B7E_FILIAL = '"+xFilial("B7E")+"'"
	cQuery += "	  AND B7E.B7E_CODOPE = '"+cOperadora+"'"
    cQuery += "	  AND B7E.B7E_ALIAS = '"+cAlias+"'"
    cQuery += "	  AND B7E.B7E_ATIVO = '1'"
	cQuery += "   AND B7E.D_E_L_E_T_= ' ' "

	dbUseArea(.T., "TOPCONN", tcGenQry(,,cQuery), cAliasTemp, .F., .T.)
	        
	If !(cAliasTemp)->(Eof())
		While !(cAliasTemp)->(Eof())

			aAdd(aIntegracoes, (cAliasTemp)->B7E_CODIGO)

            (cAliasTemp)->(DbSkip())
        EndDo				
    EndIf

    (cAliasTemp)->(DbCloseArea())

Return aIntegracoes