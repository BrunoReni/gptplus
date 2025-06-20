#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA680.CH"

Static aPermissao := { { "001", STR0001 },; // "Define os grupos e permiss�es de acesso?"
                       { "002", STR0002 },; // "Pode incluir itens para aloca��o de recurso humano sem cobran�a de valor para o cliente? (Cortesia)"
                       { "003", STR0003 },; // "Pode incluir itens de material de implanta��o sem cobran�a de valor para o cliente?"
                       { "004", STR0004 },; // "Pode incluir itens de material de consumo sem cobran�a de valor para o cliente?"
                       { "005", STR0005 },; // "Pode alocar mais atendentes que a quantidade vendida (excedente)?"
                       { "006", STR0006 },; // "Pode alocar mais armamentos que a quantidade definida?"
                       { "007", STR0007 },; // "Pode movimentar armamento fora do contrato?"
                       { "008", STR0008 },; // "Edita filtro de aloca��o: Centro de Custo?"
                       { "009", STR0009 },; // "Edita filtro de aloca��o: Regi�o?"
                       { "010", STR0010 },; // "Edita filtro de aloca��o: Fun��o?"
                       { "011", STR0011 },; // "Edita filtro de aloca��o: Cargo?"
                       { "012", STR0012 },; // "Edita filtro de aloca��o: Habilidades?"
                       { "013", STR0013 },; // "Edita filtro de aloca��o: Turno?"
                       { "014", STR0014 },; // "Edita a Configura��o de Aloca��o?"
                       { "015", STR0015 },; // "Pode alocar recurso humano fora do per�odo planejado?"
                       { "016", STR0023 },; // "Edita filtro de aloca��o: Sequ�ncia de Turno?"
                       { "017", STR0024 },; // "Pode realizar aloca��es com conflito?"
                       { "018", STR0025 },; // "Pode efetuar a movimenta��o da muni��o excedendo as 3 cargas?"
                       { "019", STR0026 },; // "Edita Filtro de Aloca��o: Curso?"
                       { "020", STR0027 },; // "Edita Filtro de Aloca��o: Caracter�stica?"
                       { "021", STR0028 },; // "Define Restri��o Operacional?"
                       { "022", STR0032 },; // "Central do Cliente: Permite consultar op��es do grupo Oportunidades "
                       { "023", STR0033 },; // "Central do Cliente: Permite consultar op��es do grupo Propostas Comerciais"
                       { "024", STR0034 },; // "Central do Cliente: Permite consultar op��es do grupo Contratos"
                       { "025", STR0035 },; // "Central do Cliente: Permite consultar op��es do grupo Financeiro"
                       { "026", STR0036 },; // "Central do Cliente: Permite consultar op��es do grupo Faturamento"
                       { "027", STR0037 },; // "Central do Cliente: Permite consultar op��es do grupo Locais de Atendimento"
                       { "028", STR0038 },; // "Central do Cliente: Permite consultar op��es do grupo Equipamentos"
                       { "029", STR0039 },; // "Central do Cliente: Permite consultar op��es do grupo Recursos Humanos"
                       { "030", STR0040 },; // "Central do Cliente: Permite consultar op��es do grupo Ordens de Servico"
                       { "031", STR0041 },; // "Central do Cliente: Permite consultar op��es do grupo Armamentos"
                       { "033", STR0029 },; // "Pode incluir itens para aloca��o de recurso humano sem cobran�a de valor para o cliente? (Item Extra)"
                       { "034", STR0030 },; // "Pode incluir itens de material de implanta��o com cobran�a de valor para o cliente? (Item Extra)"
                       { "035", STR0031 },; // "Pode incluir itens de material de consumo com cobran�a de valor para o cliente? (Item Extra)"
                       { "036", STR0044 },; // "Pode incluir manualmente funcion�rio substituto?"
                       { "037", STR0045 },; // "Pode incluir manualmente funcionario?"
                       { "038", STR0046 },; // "Mesa Operacional: Pode realizar manuten��o na agenda?"
                       { "039", STR0047 },; // "Mesa Operacional: Pode projetar agenda?"
                       { "040", STR0048 },; // "Mesa Operacional: Pode gravar agenda projetada?"
                       { "041", STR0049 },; // "Mesa Operacional: Pode excluir agenda?"
                       { "042", STR0050 },; // "Mesa Operacional: Pode realizar troca de efetivo?"
                       { "043", STR0051 },; // "Mesa Operacional: Permite operar em modo multi-filial?"
                       { "044", STR0052 },; // "Mesa Operacional: Verifica fun��o/cargo/regi�o/curso/habilidade/caracter�stica ao alocar?"
                       { "045", STR0053 },; // "Gest�o de Contratos: Pode inserir cliente no contrato?"
					   { "046", STR0054 },; // "Permite aprovar revis�es com inconsist�ncias operacionais?"
					   { "047", STR0055 },; // "Gest�o de Contratos: Pode acessar Revis�o do Contrato?"
					   { "048", STR0056 },; // "Gest�o de Contratos: Pode acessar Efetiva Revis�o?" 
                       { "049", STR0057 },; // "Gest�o de Contratos: Pode acessar Aprova Revis�o?" 
                       { "050", STR0058 },; // "Gest�o de Contratos: Pode acessar Adicionar Itens Extras?"
                       { "051", STR0059 },; // "Gest�o de Contratos: Pode acessar Excluir?"
                       { "052", STR0060 },; // "Gest�o de Contratos: Pode acessar Desfazer Revis�o do Contrato?"
                       { "053", STR0061 },; // "Gest�o de Contratos: Pode acessar Memorando?"
                       { "054", STR0062 },; // "Gest�o de Contratos: Pode acessar Encerramento de Posto?"
                       { "055", STR0063 },; // "Gest�o de Contratos: Pode acessar Cancelamento?"
                       { "056", STR0064 },; // "Gest�o de Contratos: Pode acessar Manuten��o de Assistente?"
                       { "057", STR0065 },; // "Gest�o de Contratos: Pode acessar Conhecimento?"
                       { "059", STR0067 },; // "Gest�o de Contratos: Pode acessar Revis�o em Lote?"
                       { "060", STR0068 },; // "Gest�o de Contratos: Pode acessar Revis�o Planejada?"
                       { "061", STR0069 },; // "Gest�o de Contratos: Pode acessar Aplicar Revisao Planejada?"
					   { "062", STR0070 },; // "Gest�o de Contratos: Pode acessar Visualizar Or�amento?"
                       { "063", STR0071 },; // "Gest�o de Contratos: Pode acessar Visualizar Contrato"	 
					   { "064", STR0072 },; // "Gest�o de Contratos: Pode acessar Confirma��o e Coleta?"	    
					   { "065", STR0073 },; // "Gest�o de Contratos: Pode acessar Antecipar Contrato?"
					   { "066", STR0074 },; // "Gest�o de Contratos: Permite modificar a Escala do posto com aloca��es?"
					   { "067", STR0075 },; // "Gest�o de Contratos: Permite apresentar o bot�o Exportar para Excel na Planilha de Precifica��o?"	 	   
					   { "068", STR0076 },; // "Painel de Aprova��o: Pode realizar aprova��o operacional?"	 	   
					   { "069", STR0077 },;  // "Mesa Operacional: pode alterar codigo de limite de marca��es?"
					   { "070", STR0078 };  // "Ajuste de Batida Manual: pode ajustar batidas manualmente?"
					   }

Static oBrwAcessos := Nil

//----------------------------------------------------------
/*/{Protheus.doc} TECA680()
@description	Cadastro de Grupo de acesso / perfil
@Return		nil
@author	 	Servi�os
@since			07/04/2014
/*/
//----------------------------------------------------------
Function TECA680(lAutomato)
Default lAutomato := .F.
DbSelectArea("TCT")
DbSelectArea("TIN")

At680Ajust()

//Cria a tela para o browse
oBrwAcessos	:= FwMarkBrowse():New()
oBrwAcessos:SetAlias("TIN")
oBrwAcessos:SetMenuDef("TECA680")
oBrwAcessos:DisableDetails()
oBrwAcessos:SetDescription(STR0016)  // "Cadastro de Grupo de Acesso/Perfil"
If !lAutomato
	oBrwAcessos:Activate()
EndIf
oBrwAcessos:DeActivate()
oBrwAcessos	:= NIL
Return

//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
@description	MenuDef - Cadastro de Grupo de acesso/perfil
@Return	 	MenuDef
@author	 	Servi�os
@since			07/04/2014
/*/
//----------------------------------------------------------
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina TITLE STR0017 ACTION "AxPesqui"  OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE STR0018 ACTION "At680Auto" OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE STR0019 ACTION "At680Auto" OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE STR0020 ACTION "At680Auto" OPERATION 4 ACCESS 0 // "Alterar"
ADD OPTION aRotina Title STR0021 ACTION "At680Auto" OPERATION 5 ACCESS 0 // "Excluir"
Return(aRotina)


//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
@description	Model - Cadastro de Grupo de acesso/perfil
@Return	 	model
@author	 	Servi�os
@since			07/04/2013
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStrCabec	:= FWFormStruct(1,"TIN", {|cCampo|  ( Alltrim( cCampo )$"TIN_GRUPO+TIN_NOME+TIN_MSBLQL" ) } )
Local oStrGrid	:= FWFormStruct(1,"TIN", {|cCampo| !( Alltrim( cCampo )$"TIN_NOME+TIN_MSBLQL" ) } )
Local oStruTCT	:= FWFormStruct(1,"TCT")
Local aAux			:= {}

aAux				:= FwStruTrigger("TIN_CODUSR","TIN_NOMUSR","UsrRetName(FwFldGet('TIN_CODUSR'))",.F.,Nil,Nil,Nil)
oStrGrid:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux := FwStruTrigger("TCT_PODE","SELECT","Iif(FwFldGet('TCT_PODE')=='1',.T.,.F.)",.F.,Nil,Nil,Nil)
oStruTCT:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

oStruTCT:AddField('Permite?', 'Permite?', 'SELECT', 'L', 1, 0, {|| At680Mrk()}, {|| .T.}, {}, .F., FWBuildFeature( STRUCT_FEATURE_INIPAD, "TCT->TCT_PODE=='1'"), .F., .F., .T.)

oStrGrid:SetProperty( "TIN_GRUPO" 	, MODEL_FIELD_OBRIGAT, .F. )
oStrGrid:SetProperty( "TIN_NOMUSR"	, MODEL_FIELD_INIT, {|oModel| At680Init(oModel)} )

oStruTCT:SetProperty( "TCT_GRUPO", MODEL_FIELD_OBRIGAT, .F. )

// Cria o objeto do Modelo de Dados
oModel				:= MPFormModel():New("TECA680", /*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

//Cabecalho do grupo
oModel:AddFields("TINMASTER",/*cOwner*/,oStrCabec, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//Grid detalhes do grupo
oModel:AddGrid( "TINDETAIL","TINMASTER",oStrGrid,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/, /*bPosVal*/)
oModel:SetRelation( "TINDETAIL", { { "TIN_FILIAL", "xFilial('TIN')" }, { "TIN_GRUPO", "TIN_GRUPO" } }, TIN->(IndexKey(1)) )

//Grid permissoes do grupo
oModel:AddGrid( "TCTDETAIL","TINMASTER",oStruTCT,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/, /*bPosVal*/)
oModel:SetRelation( "TCTDETAIL", { { "TCT_FILIAL", "xFilial('TCT')" }, { "TCT_GRUPO", "TIN_GRUPO" } }, TCT->(IndexKey(1)) )

oModel:SetPrimaryKey( {} )
oModel:SetDescription(STR0016) // Cadastro de Grupo de acesso/perfil

oModel:SetActivate( {|oModel| InitDados( oModel ) } )
Return(oModel)


//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
@description	View - Cadastro de Lista de emails
@Return		view
@author		Servi�os
@since			09/09/2013
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel		:= FWLoadModel("TECA680")
Local oStrCabec	:= FWFormStruct( 2,"TIN", {|cCampo|  ( Alltrim( cCampo )$"TIN_GRUPO+TIN_NOME+TIN_MSBLQL" ) } )
Local oStrGrid	:= FWFormStruct( 2,"TIN", {|cCampo| !( Alltrim( cCampo )$"TIN_GRUPO+TIN_NOME+TIN_MSBLQL" ) } )
Local oStruTCT	:= FWFormStruct( 2,"TCT")

oStrGrid:RemoveField( "TIN_GRUPO" )
oStruTCT:RemoveField( "TCT_GRUPO" )

oStruTCT:SetProperty( "TCT_ACESSO", MVC_VIEW_WIDTH, 900 )

oStruTCT:AddField( 'SELECT','01','Permite?','Permite?',{"Marcar para permitir acesso."}, 'Check', "@!", Nil, Nil, .T., '', Nil, Nil, Nil, Nil, .T., Nil )

oView				:= FWFormView():New()

oView:SetModel( oModel )
oView:SetDescription( STR0016 ) // "Cadastro de Grupo de acesso/perfil"
oView:SetCloseOnOk({|| .T. } )

oView:AddField("TIN_CABEC", oStrCabec, "TINMASTER" )
oView:AddGrid( "TIN_GRID" , oStrGrid , "TINDETAIL" )
oView:AddGrid( "TCT_GRID" , oStruTCT , "TCTDETAIL" )

//--------------------------------------
//		Cria os Box's
//--------------------------------------
oView:CreateHorizontalBox( "TOP"   , 12 )
oView:CreateHorizontalBox( "MIDDLE", 48 )
oView:CreateHorizontalBox( "DOWN"  , 40 )

//--------------------------------------
//		Associa os componentes ao Box
//--------------------------------------
oView:SetOwnerView( "TIN_CABEC", "TOP" 	)
oView:SetOwnerView( "TIN_GRID" , "MIDDLE" )
oView:SetOwnerView( "TCT_GRID" , "DOWN" 	)

// Incrementa automaticamente o campo ao incluir uma nova linha
oView:AddIncrementField( "TIN_GRID", "TIN_ITEM" )

oView:SetAfterViewActivate({|oView| ConfigHeader(oView)})

Return(oView)

//--------------------------------------------------------------------------------
/*/{Protheus.doc} ConfigHeader

@description Configurar clique da header (checkbox)
@author flavio.vicco
@since  09/05/2023
/*/
//--------------------------------------------------------------------------------
Static Function ConfigHeader(oView)
Local bHeaderClick := {|| SetMark(oView) }
If Valtype(oView) == "O"
	oView:GetViewObj("TCT_GRID")[3]:oBrowse:GetColumn(1):bHeaderClick := bHeaderClick //{|| SELF:TGRIDORDERCOLUMN()}
EndIf
Return .T.

//--------------------------------------------------------------------------------
/*/{Protheus.doc} SetMark

@description Marca / Desmcarca Todas linhas
@author flavio.vicco
@since  09/05/2023
/*/
//--------------------------------------------------------------------------------
Static Function SetMark(oView) 
Local aSaveRows := FwSaveRows()
Local oGrid     := oView:GetModel("TCTDETAIL")
Local nI        := 0
Local nAt       := oGrid:GetLine()
Local lDesmark  := oGrid:SeekLine({{"SELECT",.T.}})
If oView:GetModel():GetOperation() == MODEL_OPERATION_INSERT .Or. ;
	oView:GetModel():GetOperation() == MODEL_OPERATION_UPDATE
	For nI := 1 to oGrid:Length()
		oGrid:GoLine(nI)          
		oGrid:SetValue("SELECT",!lDesmark)
	Next nI
	oView:GoLine("TCTDETAIL",nAt)   //GOLINE	CIDSUBMODEL,NLINE,LEVALCHANGES
	oView:Refresh("TCT_GRID")
	FwRestRows( aSaveRows )
EndIf
Return .T.


//--------------------------------------------------------------------------------
/*/{Protheus.doc} At680Mrk

@description Marcar / Desmarcar Item
@author flavio.vicco
@since  09/05/2023
/*/
//--------------------------------------------------------------------------------
Static Function At680Mrk()
Local oModel  := FwModelActive()
Local oMdlGRD := oModel:GetModel("TCTDETAIL")
Local lMark   := .F.
lMark := oMdlGRD:GetValue("SELECT")
oMdlGRD:LoadValue("TCT_PODE",IIf(lMark,"1","2"))
Return .T.


//----------------------------------------------------------
/*/{Protheus.doc} InitDados()
@description	Inicializa as informa��es do cadastro de grupo/acessps
@sample	 	InitDados()
@param			oModel, Objeto, objeto geral do model que ser� alterado
@author	 	Servi�os
@since			09/09/2013
/*/
//----------------------------------------------------------
Static Function InitDados(oModel)

Local aSaveRows	:= {}
Local oMdlTCT 	:= oModel:GetModel("TCTDETAIL")
Local nTotPermi 	:= Len(aPermissao)
Local nI	 		:= 0

aSaveRows			:= FwSaveRows()

If oModel:GetOperation() == MODEL_OPERATION_INSERT

	For nI:=1 To nTotPermi

		If nI > 1
			oMdlTCT:AddLine()
		EndIf

		oMdlTCT:SetValue( "TCT_ITEM", aPermissao[nI][1] )
		oMdlTCT:SetValue( "TCT_ACESSO", aPermissao[nI][2] )

	Next nI

EndIf

FwRestRows( aSaveRows )

oModel:GetModel("TCTDETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("TCTDETAIL"):SetNoDeleteLine(.T.)
Return(Nil)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At680DesPerm
@description	Retorna a descri��o da regra cadastrada
@author	 	Servi�os
@since 			08/04/2014
@version	 	P12
@return		cRet - Retorna a descri��o da regra cadastrada
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At680DesPerm(cCodItem)

Local cRet		:= ""
Local nPos		:= aScan( aPermissao, { |x| x[1] == cCodItem } )

If nPos > 0
	cRet	:= aPermissao[nPos][2]
EndIf
Return(cRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At680Auto
@description	Rotinas para utilizar o posicionamento da tabela a ser chamada
@author	 	Servi�os
@since 			08/04/2014
@version	 	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At680Auto( cAlias, nReg, nOpcx )

Local cTitulo		:= ""
Local lRet			:= (nOpcx == 3)
Local nTINRecNo	:= TIN->(RecNo())
Local cTINGrupo	:= ""
Local nOpeMnu

If nOpcx == 2
	cTitulo	:= STR0018 //"Visualizar"
	nOpeMnu	:= MODEL_OPERATION_VIEW
ElseIf nOpcx == 3
	cTitulo	:= STR0019 // "Incluir"
	nOpeMnu	:= MODEL_OPERATION_INSERT
ElseIf nOpcx == 4
	cTitulo	:= STR0020 //"Alterar"
	nOpeMnu	:= MODEL_OPERATION_UPDATE
ElseIf nOpcx == 5
	cTitulo	:= STR0021 //"Excluir"
	nOpeMnu	:= MODEL_OPERATION_DELETE
EndIf

If TIN->(DbSeek(xFilial('TIN'))) .And. !At680Perm( , __cUserId, '001' )
	lRet	:= .F.
	Help( ,, 'AT680ACESSO',, STR0022, 1, 0) // 'Usu�rio sem permiss�o para acesso a essas informa��es.'
Else
	lRet	:= .T.
EndIf

If lRet .And. nOpcx <> 3
	DbSelectArea("TIN")
	DbSetOrder(1) //TIN_FILIAL+TIN_GRUPO+TIN_ITEM
	If	nTINRecNo > 0
		TIN->(dBGoTo(nTINRecNo))
		cTINGrupo	:= TIN->TIN_GRUPO
		lRet		:= TIN->(dbSeek(xFilial("TIN")+cTINGrupo))
	Else
		lRet		:= .F.
	EndIf
EndIf

If lRet .And. !( Empty(cTitulo) )
	FWExecView(cTitulo,"VIEWDEF.TECA680",nOpeMnu,/*oDlg*/,{||.T.}/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)
	oBrwAcessos:Data():DeActivate()
	oBrwAcessos:Data():Activate()
	oBrwAcessos:GoTo( 1, .T.)
	oBrwAcessos:Refresh(.T.)
EndIf
Return(Nil)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At680Perm
@description	Rotina para a consulta ou valida��o dos acessos do grupo/usuario
@param			cGrupo, String, grupo qual deseja consulta ou verificar o acesso
@param		 	cUsuario, String, usuario qual deseja consulta ou verificar o acesso
@param			cRegra, String, regra qual deseja verificar o acesso
@author		Servi�os
@since			10/04/2014
@version		P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At680Perm( cGrupo, cIdUsuario, cRegra, uDefRet )

Local xRet  		:= .F.
Local aArea 		:= GetArea()
Local cSeek 		:= ""
Local lNegPerm		:= SuperGetMv("MV_GSNPERM", .F., .F.)

Default cGrupo 		:= ""
Default cIdUsuario 	:= ""
Default cRegra 		:= ""
Default uDefRet		:= .F.

If ValType(xRet) == "L" .And. !xRet
	xRet	:= (cIdUsuario == "000000")
EndIf

dbSelectArea("TIN")
TIN->(dbSetOrder(3))

If !xRet .And. TIN->(DbSeek( xFilial('TIN')))
	// Verifica qual grupo o usuario pertence
	If Empty(cGrupo) .And. !( Empty(cIdUsuario) )
		If TIN->(dbSeek(xFilial("TIN")+cIdUsuario))
			cGrupo		:= TIN->TIN_GRUPO
		EndIf
	EndIf

	// Verifica a regra ou verifica a lista de acessos
	If !( Empty(cGrupo) )

		dbSelectArea("TCT")
		TCT->(dbSetOrder(1))

		cSeek	:= xFilial("TCT")+cGrupo

		If !( Empty(cRegra) )
			cSeek	+= cRegra
		EndIf

		If TCT->(dbSeek(cSeek))
			If !( Empty(cRegra) )
				xRet	:= (TCT->TCT_PODE == "1")
			Else
				xRet	:= {}
				// Bloco para carregar os acessos
				While TCT->(! Eof()) .And. (TCT->TCT_FILIAL + TCT->TCT_GRUPO == cSeek)
					aAdd( xRet, { TCT->TCT_ITEM, TCT->TCT_PODE } )
					TCT->(dbSkip())
				EndDo
			EndIf
		ElseIf uDefRet
			xRet := !lNegPerm
		EndIf
	ElseIf uDefRet
		xRet := !lNegPerm
	EndIf
ElseIf !cIdUsuario == "000000"
	// Quando n�o tem grupo de acesso configurado
	// n�o considera as permiss�es
		xRet	:= !lNegPerm
EndIf

RestArea(aArea)
Return(xRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At680Init
@description	Inicializa o campo de nome do usuario
@author	 	Servi�os
@since			27/01/2015
@version	 	P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At680Init(oModel)

Local nOper	:= oModel:GetOperation()
Local cRet		:= ""

If nOper <> MODEL_OPERATION_INSERT
	If oModel:GetLine() == 0
		cRet	:= UsrRetName(TIN->TIN_CODUSR)
	EndIf
EndIf
Return(cRet)

//----------------------------------------------------------
/*/{Protheus.doc} At680Ajust
@description 	Realiza os ajustes adicionando os itens que n�o existem ainda no banco de dados
@author 		josimar.assuncao
@since 			2017.02.15
@version 		P12
/*/
//----------------------------------------------------------
Static Function At680Ajust()

Local cQryTemp 	:= GetNextAlias()
Local nMaxPerms 	:= Len( aPermissao )
Local aArea 		:= GetArea()
Local aAreaTCT 	:= TCT->(GetArea())
Local aAreaTIN 	:= TIN->(GetArea())
Local cFilTIN 	:= xFilial("TIN")
Local cFilTCT 	:= xFilial("TCT")
Local oModel 		:= FWLoadModel( "TECA680" )
Local oMdlTCT 	:= Nil
Local nI 			:= 0

BeginSQL Alias cQryTemp
	SELECT DISTINCT TIN_GRUPO
	  FROM %Table:TIN% TIN
	 WHERE TIN.TIN_FILIAL = %xFilial:TCT%
	   AND TIN.%NotDel%
	   AND %Exp:nMaxPerms% > ( SELECT COUNT( TCTIN.TCT_ITEM )
	                             FROM %Table:TCT% TCTIN
	                            WHERE TCTIN.TCT_FILIAL = %xFilial:TCT%
	                              AND TCTIN.%NotDel%
	                              AND TCTIN.TCT_GRUPO = TIN.TIN_GRUPO
	                         )
EndSQL

DbSelectArea("TCT")
TCT->( DbSetOrder( 1 ) ) // TCT_FILIAL+TCT_GRUPO+TCT_ITEM

DbSelectArea("TIN")
TIN->( DbSetOrder( 1 ) ) // TIN_FILIAL+TIN_GRUPO+TIN_ITEM

While (cQryTemp)->(! Eof())
	TIN->( DbSeek( cFilTIN + (cQryTemp)->TIN_GRUPO ) )
	TCT->( DbSeek( cFilTCT + (cQryTemp)->TIN_GRUPO ) )

	oModel:SetOperation( MODEL_OPERATION_UPDATE )
	oModel:Activate()

	oMdlTCT	:= oModel:GetModel("TCTDETAIL")
	oMdlTCT:SetNoInsertLine(.F.)

	If nMaxPerms > oMdlTCT:Length()
		For nI := 1 To nMaxPerms
			// quando n�o encontrar a permiss�o, realiza a inclus�o.
			If !(oMdlTCT:SeekLine( { { "TCT_ITEM", aPermissao[nI][1] } } ) )
				oMdlTCT:AddLine()
				oMdlTCT:SetValue( "TCT_ITEM", aPermissao[nI][1] )
				oMdlTCT:SetValue( "TCT_ACESSO", aPermissao[nI][2] )
			EndIf
		Next nI
	EndIf

	oModel:VldData()
	oModel:CommitData()

	oModel:DeActivate()

	(cQryTemp)->(DbSkip())
EndDo

oModel:Destroy()
(cQryTemp)->(DbCloseArea())

RestArea(aAreaTIN)
RestArea(aAreaTCT)
RestArea(aArea)
Return
