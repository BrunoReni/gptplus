#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OMSXCPL1.CH"

/*{Protheus.doc} OMSXCPL1

Fun��o que cria uma tela aonde se pode ser incluidos ou alterados os parametros que existem na base
Baseado OMSXCPL1
@author Siegklenes.Beulke
@since 30/09/2015
@version 1.0

*/

// Array de array {Servi�o do webservice,m�todo de inclus�o, m�todo de atualiza��o, m�todo de exclus�o,xmlnamespace

//#DEFINE CPL_SERVICE 1
//#DEFINE CPL_INSERT 2
//#DEFINE CPL_UPDATE 3
//#DEFINE CPL_DELETE 4
//#DEFINE CPL_XMLINS 5
//#DEFINE CPL_TABELA 6

//
Static aListaOMSX := {{"FreightRuleAcquisitionService",/*N�o utilizado*/ ,/*N�o utilizado*/ ,/*N�o utilizado*/ ,/*N�o utilizado*/,"GVA"},; // Regras de frete
						 {"VehicleAcquisitionService"            ,"createVehicles"       ,"updateVehicles"       ,               ,"vehicle"       , "DUT"},;        // Ve�culos
						 {"ProductAcquisitionService"            ,"createProducts"       ,"updateProducts"       ,               ,"product"       , "SB1"},;        // Produtos
						 {"LocalityAcquisitionService"           ,"createLocalities"     ,"updateLocalities"     ,               ,"locality"      , "SA1,DUL,DUE,SM0"},;        // Locais(Clientes e Solicitantes) 
						 {"CarrierAcquisitionService"            ,"createCarriers"       ,"updateCarriers"       ,               ,"carrier"       , "SA2, SA4"},;        // Transportadores
						 {"OrderAcquisitionService"              ,"createOrders"         ,"updateOrders"         ,"deleteOrders" ,"order"         , "DT6,DUD, SC5, SC6, SC9, SB1, SB5"},;			// Pedido, dud somente para exclus�o.
						 {"UnblockReleasedTripAcquisitionService","doUnblockReleasedTrip","doUnblockReleasedTrip",               ,"unblockRelTrip", "DJZ,DAK,DAI"}}


Function OMSXCPL1()

	FWExecView(STR0001, 'OMSXCPL1', 3, , {|| .T. },,,Nil) // "Par�metros integra��o"
Return NIL

//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel  := Nil
	Local oStruct := FWFormModelStruct():New()
	Local aCampos := {}
	Local nCont
	Local bVldRota1 := "Vazio() .Or. (ExistCpo('DA8',PadR(M->MV_CPLROT1,Len(DTQ->DTQ_ROTA))) .And. OMSXCPL1VR('1',M->MV_CPLROT1))"
	Local bVldRota2 := "Vazio() .Or. (ExistCpo('DA8',PadR(M->MV_CPLROT2,Len(DTQ->DTQ_ROTA))) .And. OMSXCPL1VR('2',M->MV_CPLROT2))"
	Local bVldRota3 := "Vazio() .Or. (ExistCpo('DA8',PadR(M->MV_CPLROT3,Len(DTQ->DTQ_ROTA))) .And. OMSXCPL1VR('3',M->MV_CPLROT3))"
	Local cDsSerTms1 := ""
	Local cDsSerTms2 := ""
	Local cDsSerTms3 := ""
	Private cSerTms
	
	dbSelectArea("DTQ")
	
	cSerTms := "1"
	cDsSerTms1 := AllTrim( TmsValField('cSerTms',.F.) )
	cSerTms := "2"
	cDsSerTms2 := AllTrim( TmsValField('cSerTms',.F.) )
	cSerTms := "3"
	cDsSerTms3 := AllTrim( TmsValField('cSerTms',.F.) )
	
	bVldRota1 := FwBuildFeature(1,bVldRota1)
	bVldRota2 := FwBuildFeature(1,bVldRota2)
	bVldRota3 := FwBuildFeature(1,bVldRota3)

	aadd(aCampos,{"MV_CPLINT" , STR0099              , "C",  01  , 0,,{STR0066,STR0067}          ,{|| SuperGetMv("MV_CPLINT" ,.F.,"2")}, }) // "Integra��o Planejamento Viagem?" ## "1=Sim" ## "2=N�o"
	aadd(aCampos,{"MV_CPLMON" , STR0097              , "C",  01  , 0,,{STR0066,STR0067}          ,{|| SuperGetMv("MV_CPLMON" ,.F.,"2")}, }) // "Integra��o Monitoramento?" ## "1=Sim" ## "2=N�o"
	aadd(aCampos,{"MV_CPLLVA" , STR0038              , "C",  1   , 0,,{STR0066,STR0067}          ,{|| SuperGetMv("MV_CPLLVA" ,.F.,"2")}, }) // "Libera��o automatica da viagem?" ## "1=Sim" ## "2=N�o"
	aadd(aCampos,{"MV_CPLURL" , STR0039              , "C",  255 , 0,,                           ,{|| SuperGetMv("MV_CPLURL" ,.F.,"" )}, }) // "Endere�o WebService Planejamento Viagem"
	aadd(aCampos,{"MV_WSMONI" , STR0098              , "C",  255 , 0,,                           ,{|| SuperGetMv("MV_WSMONI" ,.F.,"" )}, }) // "Endere�o WebService Monitoramento"
	aadd(aCampos,{"MV_CPLREG" , STR0040              , "C",  255 , 0,,                           ,{|| SuperGetMv("MV_CPLREG" ,.F.,"" )}, }) // "Regional"
	aadd(aCampos,{"MV_CPLEMB" , STR0041              , "C",  255 , 0,,                           ,{|| SuperGetMv("MV_CPLEMB" ,.F.,"" )}, }) // "Embarcador"
	aadd(aCampos,{"MV_CPLINV" , STR0042              , "C",  255 , 0,,                           ,{|| SuperGetMv("MV_CPLINV" ,.F.,"" )}, }) // "Inv�lucro Padr�o"
	aadd(aCampos,{"MV_CPLIDS" , STR0043              , "C",  255 , 0,,                           ,{|| SuperGetMv("MV_CPLIDS" ,.F.,"" )}, }) // 'Origem dos Dados'
	aadd(aCampos,{"MV_CPLUMIT", STR0090              , "C",  1   , 0,,{STR0091,STR0092}          ,{|| SuperGetMv("MV_CPLUMIT",.F.,"1")}, }) // 'UM a considerar na integra��o dos pedidos?' ## "1� UM" ## "2� UM"
	aadd(aCampos,{"MV_CPLPELB", STR0093              , "C",  1   , 0,,{STR0066,STR0067}          ,{|| SuperGetMv("MV_CPLPELB",.F.,"2")}, }) // Permite enviar quantidades n�o liberadas?
	aadd(aCampos,{"MV_CPLDTPD", STR0104              , "C",  1   , 0,,{STR0105,STR0106}          ,{|| SuperGetMv("MV_CPLDTPD",.F.,"1")}, }) // 'Data utilizada na integra��o do pedido' ## "1=Data corrente" ## "2=Data emiss�o pedido"	
	aadd(aCampos,{"MV_CPLUMMT", STR0107              , "C",  1   , 0,,{STR0108,STR0109}          ,{|| SuperGetMv("MV_CPLUMMT",.F.,"1")}, }) // 'UM a considerar na integra��o das cargas para monitoramento?' ## "1� UM" ## "2� UM"
	aadd(aCampos,{"MV_CPLCLI" , STR0044              , "C",  1   , 0,,{STR0066,STR0067}          ,{|| SuperGetMv("MV_CPLCLI" ,.F.,"2")}, }) // 'Integrar Clientes On Line?' ## "1=Sim" ## "2=N�o"
	aadd(aCampos,{"MV_CPLFOR" , STR0045              , "C",  1   , 0,,{STR0066,STR0067}          ,{|| SuperGetMv("MV_CPLFOR" ,.F.,"2")}, }) // 'Integrar Fornecedores On Line?' ## "1=Sim" ## "2=N�o"
	aadd(aCampos,{"MV_CPLTRA" , STR0046              , "C",  1   , 0,,{STR0066,STR0067}          ,{|| SuperGetMv("MV_CPLTRA" ,.F.,"2")}, }) // 'Integrar Transportadora On Line?' ## "1=Sim" ## "2=N�o"
	aadd(aCampos,{"MV_CPLPRO" , STR0047              , "C",  1   , 0,,{STR0066,STR0067}          ,{|| SuperGetMv("MV_CPLPRO" ,.F.,"2")}, }) // 'Integrar Produtos On Line?' ## "1=Sim" ## "2=N�o"
	aadd(aCampos,{"MV_CPLTPV" , STR0048              , "C",  1   , 0,,{STR0066,STR0067}          ,{|| SuperGetMv("MV_CPLTPV" ,.F.,"2")}, }) // 'Integrar Tipos de Ve�culo On Line?' ## "1=Sim" ## "2=N�o"
	aadd(aCampos,{"MV_CPLTVO" , STR0061              , "C",  1   , 0,,{STR0075,STR0076}          ,{|| SuperGetMv("MV_CPLTVO" ,.F.,"2")}, }) // 'Tipo Ve�culo Otimiza��o?' ## "Impedir" ## "Alertar"
	aadd(aCampos,{"MV_CPLUAUT", STR0079              , "C",  255 , 0,,                           ,{|| SuperGetMv("MV_CPLUAUT",.F.," ")}, }) // "Endere�o do webservice de autentica��o" 
	aadd(aCampos,{"MV_USRCPL" , STR0083              , "C",  255 , 0,,                           ,{|| SuperGetMv("MV_USRCPL" ,.F.," ")}, }) // "Usu�rio de autentica��o do webservice"
	aadd(aCampos,{"MV_PSWCPL" , STR0084              , "C",  255 , 0,,                           ,{|| SuperGetMv("MV_PSWCPL" ,.F.," ")}, }) // "Senha de autentica��o do webservice"
	aadd(aCampos,{"MV_EXPTOK" , STR0082              , "N",  2   , 0,,                           ,{|| SuperGetMv("MV_EXPTOK" ,.F.,24 )}, }) // "Quantidade de horas para considerar que um token expirou" default 24
	aadd(aCampos,{"MV_CPLTIME" ,STR0096              , "N",  3   , 0,,                           ,{|| SuperGetMv("MV_CPLTIME",.F.,30 )}, }) // Tempo m�ximo (em segundos) de inatividade permitida para a recep��o da resposta (Timeout).
	aadd(aCampos,{"MV_CPLSOL" , STR0049              , "C",  1   , 0,,{STR0066,STR0067}          ,{|| SuperGetMv("MV_CPLSOL" ,.F.,"2")}, {||SuperGetMv("MV_INTTMS",.F.,.F.) == .T.}}) // 'Integrar Solicitantes On Line?' ## "1=Sim" ## "2=N�o"
	aadd(aCampos,{"MV_CPLSOE" , STR0050              , "C",  1   , 0,,{STR0066,STR0067}          ,{|| SuperGetMv("MV_CPLSOE" ,.F.,"2")}, {||SuperGetMv("MV_INTTMS",.F.,.F.) == .T.}}) // 'Integrar Endere�os de Solicitantes On Line?' ## "1=Sim" ## "2=N�o"
	aadd(aCampos,{"MV_CPLCAT" , STR0051              , "C",  1   , 0,,{STR0068,STR0069}          ,{|| SuperGetMv("MV_CPLCAT" ,.F.,"2")}, }) // 'Categoria de Produto?' ## "1=Grupo Produto" ## "2=Padr�o Cockpit"
	aadd(aCampos,{"MV_CPLTP1" , STR0052 + cDsSerTms1 , "C",  255 , 0,,                           ,{|| SuperGetMv("MV_CPLTP1" ,.F.,"" )}, {||SuperGetMv("MV_INTTMS",.F.,.F.) == .T.}}) // 'Tipo Pedido '
	aadd(aCampos,{"MV_CPLTP2" , STR0052 + cDsSerTms2 , "C",  255 , 0,,                           ,{|| SuperGetMv("MV_CPLTP2" ,.F.,"" )}, {||SuperGetMv("MV_INTTMS",.F.,.F.) == .T.}}) // 'Tipo Pedido '
	aadd(aCampos,{"MV_CPLTP3" , STR0052 + cDsSerTms3 , "C",  255 , 0,,                           ,{|| SuperGetMv("MV_CPLTP3" ,.F.,"" )}, {||SuperGetMv("MV_INTTMS",.F.,.F.) == .T.}}) // 'Tipo Pedido '
	aadd(aCampos,{"MV_CPLMAL" , STR0053              , "C",  255 , 0,,                           ,{|| SuperGetMv("MV_CPLMAL" ,.F.,"" )}, }) // 'E-mail administrador'
	aadd(aCampos,{"MV_CPLAUT" , STR0054              , "C",  1   , 0,,{STR0070,STR0071}          ,{|| SuperGetMv("MV_CPLAUT" ,.F.,"2")}, }) // 'Gera��o das viagens' ## "1=Autom�tico" ## "2=Manual"
	aadd(aCampos,{"MV_CPLROT1", STR0055 + cDsSerTms1 , "C", Len(DTQ->DTQ_ROTA), 0,bVldRota1,     ,{|| SuperGetMv("MV_CPLROT1",.F.,"" )}, {||SuperGetMv("MV_INTTMS",.F.,.F.) == .T.}}) // 'Rota gen�rica das viagens de '
	aadd(aCampos,{"MV_CPLROT2", STR0055 + cDsSerTms2 , "C", Len(DTQ->DTQ_ROTA), 0,bVldRota2,     ,{|| SuperGetMv("MV_CPLROT2",.F.,"" )}, {||SuperGetMv("MV_INTTMS",.F.,.F.) == .T.}}) // 'Rota gen�rica das viagens de '
	aadd(aCampos,{"MV_CPLROT3", STR0055 + cDsSerTms3 , "C", Len(DTQ->DTQ_ROTA), 0,bVldRota3,     ,{|| SuperGetMv("MV_CPLROT3",.F.,"" )}, {||SuperGetMv("MV_INTTMS",.F.,.F.) == .T.}}) // 'Rota gen�rica das viagens de '
	aadd(aCampos,{"MV_CPLSTP" , STR0056              , "C", 1    , 0,, {STR0066,STR0067}         ,{|| SuperGetMv("MV_CPLSTP" ,.F.,"2")}, {||FwFldGet("MV_CPLINT") == '1'}}) // 'Integra��o suspensa?' ## "1=Sim" ## "2=N�o"
	aadd(aCampos,{"MV_CPLENT" , STR0057              , "C", 1    , 0,, {STR0066,STR0067}         ,{|| SuperGetMv("MV_CPLENT" ,.F.,"2")}, {||SuperGetMv("MV_INTTMS",.F.,.F.) == .T.}}) // 'Considerar entregar em vez de transferir' ## "1=Sim" ## "2=N�o"
	aadd(aCampos,{"MV_CPLVRT" , STR0058              , "C", 1    , 0,, {STR0072,STR0073,STR0074} ,{|| SuperGetMv("MV_CPLVRT" ,.F.,"1")}, {||SuperGetMv("MV_INTTMS",.F.,.F.) == .T.}}) // 'Permite gerar viagens com rotas incompat�veis' ## "1=Sempre" ## "2=Nunca" ## "3=Somente manual"
	aadd(aCampos,{"MV_CPLEX"  , STR0059              , "C", 1    , 0,, {STR0066,STR0067}         ,{|| SuperGetMv("MV_CPLEX"  ,.F.,"2")}, }) // 'Integrar Localidades do Exterior?' ## "1=Sim" ## "2=N�o"
	aadd(aCampos,{"MV_CPLTVO" , STR0061              , "C", 1    , 0,, {STR0075,STR0076}         ,{|| SuperGetMv("MV_CPLTVO" ,.F.,"1")}, {||SuperGetMv("MV_INTTMS",.F.,.F.) == .T.} }) // 'Tipo Ve�culo Otimiza��o?' ## "1=Impedir" ## "2=Alertar"
	aadd(aCampos,{"MV_CPLRED" , STR0110              , "C", 1    , 0,,  {STR0066,STR0067}       ,{|| SuperGetMv("MV_CPLRED" ,.F.,"2")}, }) // "Redesp. Cli/Forn?" Padrao 2
	aadd(aCampos,{"MV_CPLCTG" , STR0062              , "C", 1    , 0,, {STR0075,STR0077,STR0078} ,{|| SuperGetMv("MV_CPLCTG" ,.F.,"1")}, {||SuperGetMv("MV_INTTMS",.F.,.F.) == .T.} }) // 'Interven��o Otimiza��o?' ## "1=Impedir" ## "2=Permitir Usu�rios" ## "3=Alertar"
	aadd(aCampos,{"MV_CPLLUS" , STR0063              , "C", 255  , 0,,                           ,{|| SuperGetMv("MV_CPLLUS" ,.F.,"" )}, {||SuperGetMv("MV_INTTMS",.F.,.F.) == .T. .And. FwFldGet("MV_CPLCTG") == "2"} }) // 'Usu�rios com Permiss�o de interven��o'
	aadd(aCampos,{"MV_CPLEST" , STR0064              , "C", 1    , 0,, {STR0075,STR0076}         ,{|| SuperGetMv("MV_CPLEST" ,.F.,"1")}, {||SuperGetMv("MV_INTTMS",.F.,.F.) == .T.} }) // 'A��o Estorno ?' ## "1=Impedir" ## "2=Alertar"
	aadd(aCampos,{"MV_CPLINT2", STR0085				, "C", 1	, 0,, {STR0086,STR0087,STR0088,STR0089}			,{|| SuperGetMv("MV_CPLINT2",.F.,"4") }, {||SuperGetMv("MV_INTTMS",.F.,.F.) == .T.} }) // Define o tipo da integra��o com o Cockpit Log�stic
	aadd(aCampos,{"MV_CPLESCG", STR0094, "C",  1   , 0,,{STR0066,STR0067}          ,{|| SuperGetMv("MV_CPLESCG",.F.,"2")}, }) // Permite estorno autom�tico da carga ao cancelar ou reprogramar viagem?
	aadd(aCampos,{"MV_CPLATVG", STR0095, "C",  1   , 0,,{STR0066,STR0067}          ,{|| SuperGetMv("MV_CPLATVG",.F.,"1")}, }) // Atualiza viagem no Cockpit ao cancelar parcialmente a integra��o do pedido?

	For nCont := 1 To Len(aCampos)
		oStruct:AddField(aCampos[nCont][2], aCampos[nCont][2], aCampos[nCont][1],aCampos[nCont][3],aCampos[nCont][4],aCampos[nCont][5],aCampos[nCont][6],aCampos[nCont][9],aCampos[nCont][7]/*@aVALUES*/,.F./*lOBRIG*/,aCampos[nCont][8]/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	Next

	oModel := MPFormModel():New("OMSXCPL1", /*bPre*/, {|oModel| OMSCPL1VLD(oModel)}/*bPost*/, {|oModel|OMSXCPLCOM(oModel)} /*bCommit*/, /*bCancel*/)
	oModel:AddFields("OMSXCPL1_01", Nil,oStruct , /*bPre*/, /*bPost*/, /*bLoad*/)
	oModel:SetDescription(STR0002) // "Par�metros Cockpit"
	oModel:GetModel("OMSXCPL1_01"):SetDescription(STR0002) // "Par�metros Cockpit"
	oModel:SetPrimaryKey({"MV_CPLINT"})

Return oModel

//------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oView   := Nil
	Local oStruct := FWFormViewStruct():New()
	Local oModel  := FWLoadModel("OMSXCPL1")
	Local aCampos
	Local aFolder
	Local nCont
	Local IntTMs := SuperGetMv("MV_INTTMS",.F.,.F.)
	
	Local cDsSerTms1 := ""
	Local cDsSerTms2 := ""
	Local cDsSerTms3 := ""
	Private cSerTms


	cSerTms := "1"
	cDsSerTms1 := AllTrim( TmsValField('cSerTms',.F.) )
	cSerTms := "2"
	cDsSerTms2 := AllTrim( TmsValField('cSerTms',.F.) )
	cSerTms := "3"
	cDsSerTms3 := AllTrim( TmsValField('cSerTms',.F.) )

	aFolder := {	{"Integ"	,STR0003	},; // "Geral"
					{"Tms"		,"SIGATMS"  }}

    If nModulo == 39
         aFolder := {	{"Integ"	,STR0003	},; // "Geral"
							{"Oms"		,"SIGAOMS"	}}
    EndIf

	For nCont := 1 to Len(aFolder)
		oStruct:AddFolder(aFolder[nCont][1],aFolder[nCont][2])
	Next nCont

	oStruct:AddGroup("GpGeral"  , STR0004, "Integ", 2) // "Integra��o"
	oStruct:AddGroup("GpTmsGeral",STR0004, "Tms"  , 2) // "Integra��o"
	oStruct:AddGroup("GpCom"   	, STR0005, "Integ", 2) // "Par�metros de conex�o"
	oStruct:AddGroup("GpInf" 	, STR0006, "Integ", 2) // "Par�metros de cadastros"
	oStruct:AddGroup("GpDoc" 	, STR0007, "Integ", 2) // "Par�metros de documentos"
	oStruct:AddGroup("GpTmsDoc" , STR0007, "Tms"  , 2) // "Par�metros de documentos"
	oStruct:AddGroup("GpViag" 	, STR0008, "Tms"  , 2) // "Par�metros de viagens"
	oStruct:AddGroup("GpDebug"  , STR0009, "Integ", 2) // "Par�metros de depura��o"
	oStruct:AddGroup("GpOmsGeral", STR0010, "Oms" , 2) // "Par�metros de libera��o"

	If nModulo == 39
		aCampos :=  {;
		{"MV_CPLINT" , STR0099, "C",    ,, "Integ", "GpGeral"   , {STR0066,STR0067}, .T.},; // "Integra��o Planejamento Viagem?" ## "1=Sim" ## "2=N�o"
		{"MV_CPLMON" , STR0097, "C",    ,, "Integ", "GpGeral"   , {STR0066,STR0067}, .T.},; // "Integra��o Monitoramento?" ## "1=Sim" ## "2=N�o"
		{"MV_CPLLVA" , STR0038, "C",    ,, "Oms"  , "GpOmsGeral", {STR0066,STR0067}, .T.},; // "Libera��o automatica da viagem?" ## "1=Sim" ## "2=N�o"
		{"MV_CPLSTP" , STR0056, "C",    ,, "Integ", "GpGeral"   , {STR0066,STR0067}, .T.},; // "Integra��o suspensa?" ## "1=Sim" ## "2=N�o"
		{"MV_CPLCLI" , STR0044, "C",    ,, "Integ", "GpGeral"   , {STR0066,STR0067}, .T.},; // 'Integrar Clientes On Line?' ## "1=Sim" ## "2=N�o"
		{"MV_CPLFOR" , STR0045, "C",    ,, "Integ", "GpGeral"   , {STR0066,STR0067}, .T.},; // 'Integrar Fornecedores On Line?' ## "1=Sim" ## "2=N�o"
		{"MV_CPLTRA" , STR0046, "C",    ,, "Integ", "GpGeral"   , {STR0066,STR0067}, .T.},; // 'Integrar Transportadora On Line?' ## "1=Sim" ## "2=N�o"
		{"MV_CPLPRO" , STR0047, "C",    ,, "Integ", "GpGeral"   , {STR0066,STR0067}, .T.},; // 'Integrar Produtos On Line?' ## "1=Sim" ## "2=N�o"
		{"MV_CPLTPV" , STR0048, "C",    ,, "Integ", "GpGeral"   , {STR0066,STR0067}, .T.},; // 'Integrar Tipos de Ve�culo On Line?' ## "1=Sim" ## "2=N�o"
		{"MV_CPLTVO" , STR0061, "C","@!",,"Integ" , "GpGeral"   , {STR0075,STR0076}, .T.},; // 'Tipo Ve�culo Otimiza��o?' ## "Impedir" ## "Alertar"
		{"MV_CPLRED" , STR0110, "C",    ,,"Integ" , "GpGeral"   , {STR0066,STR0067}   , .T.},; //"Redesp. Cli/Forn?"  Padrao 2
		{"MV_CPLURL" , STR0100, "C",    ,, "Integ", "GpCom"     ,                  , .T.},; // "Endere�o WebService Planejamento Viagem"
		{"MV_WSMONI" , STR0098, "C",    ,, "Integ", "GpCom"     ,                  , .T.},; // "Endere�o WebService Monitoramento"
		{"MV_CPLREG" , STR0040, "C",    ,, "Integ", "GpInf"     ,                  , .T.},; // "Regional"
		{"MV_CPLEMB" , STR0041, "C",    ,, "Integ", "GpInf"     ,                  , .T.},; // "Embarcador"
		{"MV_CPLCAT" , STR0051, "C",    ,, "Integ", "GpInf"     , {STR0068,STR0069}, .T.},; // 'Categoria de Produto?' ## "1=Grupo Produto" ## "2=Padr�o Cockpit"
		{"MV_CPLINV" , STR0042, "C",    ,, "Integ", "GpDoc"     ,                  , .T.},; // "Inv�lucro Padr�o"
		{"MV_CPLIDS" , STR0043, "C",    ,, "Integ", "GpDoc"     ,                  , .T.},; // 'Origem dos Dados'
		{"MV_CPLUMIT", STR0090, "C",    ,, "Integ", "GpDoc"     , {STR0091,STR0092}, .T.},; // 'UM a considerar na integra��o dos pedidos?' ## "1=1� UM" ## "2=2� UM"
		{"MV_CPLPELB", STR0093, "C",    ,, "Integ", "GpDoc"     , {STR0066,STR0067}, .T.},; // Permite enviar quantidades n�o liberadas?
		{"MV_CPLDTPD", STR0104, "C",    ,, "Integ", "GpDoc"     , {STR0105,STR0106}, .T.},; // Data utilizada na integra��o do pedido
		{"MV_CPLUMMT", STR0107, "C",    ,, "Integ", "GpDoc"     , {STR0108,STR0109}, .T.},; // 'UM a considerar na integra��o das cargas para monitoramento?' ## "1=1� UM" ## "2=2� UM"
		{"MV_CPLMAL" , STR0053, "C",    ,, "Integ", "GpDebug"   ,                  , .T.},; // 'E-mail administrador'
		{"MV_CPLAUT" , STR0054, "C",    ,, "Oms"  , "GpViag"    , {STR0070,STR0071}, .T.},; // 'Gera��o das viagens' ## "1=Autom�tico" ## "2=Manual"
		{"MV_CPLESCG", STR0094, "C",    ,, "Oms"  , "GpViag"    , {STR0066,STR0067}, .T.},; // Permite estorno autom�tico da carga ao cancelar ou reprogramar viagem?
		{"MV_CPLATVG", STR0095, "C",    ,, "Oms"  , "GpViag"    , {STR0066,STR0067}, .T.};  // Atualiza viagem no Cockpit ao cancelar parcialmente a integra��o do pedido?
		} 
	Else
		aCampos :=  {;
		{"MV_CPLINT" , STR0037             , "C",     ,      , "Integ", "GpGeral" , {STR0066,STR0067}        , .T.},; // "Integra��o Cockpit Log�stico?" ## "1=Sim" ## "2=N�o"
		{"MV_CPLSTP" , STR0056             , "C",     ,      , "Integ", "GpGeral" , {STR0066,STR0067}        , .T.},; // "Integra��o suspensa?" ## "1=Sim" ## "2=N�o"
		{"MV_CPLEX"  , STR0059             , "C",     ,      , "Integ", "GpGeral" , {STR0066,STR0067}        , .T.},; // "Integrar Localidades do Exterior?" ## "1=Sim" ## "2=N�o"
		{"MV_CPLURL" , STR0039             , "C",     ,      , "Integ", "GpCom"   ,                          , .T.},; // "Endere�o WebService"
		{"MV_CPLMAL" , STR0053             , "C",     ,      , "Integ", "GpDebug" ,                          , .T.},; // 'E-mail administrador'
		{"MV_CPLCAT" , STR0051             , "C",     ,      , "Integ", "GpInf"   , {STR0068,STR0069}        , .T.},; // 'Categoria de Produto?' ## "1=Grupo Produto" ## "2=Padr�o Cockpit"
		{"MV_CPLINV" , STR0042             , "C",     ,      , "Integ", "GpDoc"   ,                          , .T.},; // "Inv�lucro Padr�o"
		{"MV_CPLIDS" , STR0043             , "C",     ,      , "Integ", "GpDoc"   ,                          , .T.},; // 'Origem dos Dados'
		{"MV_CPLUMIT", STR0090             , "C",     ,      , "Integ", "GpDoc"   , {STR0091,STR0092}        , .T.},; // 'UM a considerar na integra��o dos pedidos?' ## "1=1� UM" ## "2=2� UM"
		{"MV_CPLDTPD", STR0104             , "C",     ,      , "Integ", "GpDoc"   , {STR0105,STR0106}        , .T.},; // 'Data utilizada na integra��o do pedido' ## "1=Data corrente" ## "2=Data emiss�o pedido"
		{"MV_CPLUMMT", STR0107             , "C",     ,      , "Integ", "GpDoc"   , {STR0108,STR0109}        , .T.},; // 'UM a considerar na integra��o das cargas para monitoramento?' ## "1=1� UM" ## "2=2� UM"
		{"MV_CPLCLI" , STR0044             , "C",     ,      , "Integ", "GpGeral" , {STR0066,STR0067}        , .T.},; // 'Integrar Clientes On Line?' ## "1=Sim" ## "2=N�o"
		{"MV_CPLFOR" , STR0045             , "C",     ,      , "Integ", "GpGeral" , {STR0066,STR0067}        , .T.},; // 'Integrar Fornecedores On Line?' ## "1=Sim" ## "2=N�o"
		{"MV_CPLTRA" , STR0046             , "C",     ,      , "Integ", "GpGeral" , {STR0066,STR0067}        , .T.},; // 'Integrar Transportadora On Line?' ## "1=Sim" ## "2=N�o"
		{"MV_CPLPRO" , STR0047             , "C",     ,      , "Integ", "GpGeral" , {STR0066,STR0067}        , .T.},; // 'Integrar Produtos On Line?' ## "1=Sim" ## "2=N�o"
		{"MV_CPLTPV" , STR0048             , "C",     ,      , "Integ", "GpGeral" , {STR0066,STR0067}        , .T.},; // 'Integrar Tipos de Ve�culo On Line?' ## "1=Sim" ## "2=N�o"
		{"MV_CPLSOL" , STR0049             , "C",     ,      , "Tms"  , "GpGeral" , {STR0066,STR0067}        , .T.},; // 'Integrar Solicitantes On Line?' ## "1=Sim" ## "2=N�o"
		{"MV_CPLSOE" , STR0050             , "C",     ,      , "Tms"  , "GpGeral" , {STR0066,STR0067}        , .T.},; // 'Integrar Endere�os Solicitantes On Line?' ## "1=Sim" ## "2=N�o"
		{"MV_CPLTP1" , STR0052 + cDsSerTms1, "C",     ,      , "Tms"  , "GpTmsDoc",                          , .T.},; // 'Tipo Pedido '
		{"MV_CPLTP2" , STR0052 + cDsSerTms2, "C",     ,      , "Tms"  , "GpTmsDoc",                          , .T.},; // 'Tipo Pedido '
		{"MV_CPLTP3" , STR0052 + cDsSerTms3, "C",     ,      , "Tms"  , "GpTmsDoc",                          , .T.},; // 'Tipo Pedido '
		{"MV_CPLENT" , STR0057             , "C",     ,      , "Tms"  , "GpTmsDoc", {STR0066,STR0067}        , .T.},; // 'Considerar entregar em vez de transferir' ## "1=Sim" ## "2=N�o"
		{"MV_CPLAUT" , STR0054             , "C",     ,      , "Tms"  , "GpViag"  , {STR0070,STR0071}        , .T.},; // 'Gera��o das viagens' ## "1=Autom�tico" ## "2=Manual"
		{"MV_CPLROT1", STR0055 + cDsSerTms1, "C", "@!", "DA8", "Tms"  , "GpViag"  ,                          , .T.},; // 'Rota gen�rica das viagens de '
		{"MV_CPLROT2", STR0055 + cDsSerTms2, "C", "@!", "DA8", "Tms"  , "GpViag"  ,                          , .T.},; // 'Rota gen�rica das viagens de '
		{"MV_CPLROT3", STR0055 + cDsSerTms3, "C", "@!", "DA8", "Tms"  , "GpViag"  ,                          , .T.},; // 'Rota gen�rica das viagens de '
		{"MV_CPLVRT" , STR0058             , "C", "@!",      , "Tms"  , "GpViag"  , {STR0072,STR0073,STR0074}, .T.},; // 'Permite gerar viagens com rotas incompat�veis'  ## "1=Sempre" ## "2=Nunca" ## "3=Somente manual"
		{"MV_CPLTVO" , STR0061             , "C", "@!",      , "Tms"  , "GpGeral" , {STR0075,STR0076}        , .T.},; // 'Tipo Ve�culo Otimiza��o?' ## "Impedir" ## "Alertar"
		{"MV_CPLCTG" , STR0062             , "C", "@!",      , "Tms"  , "GpViag"  , {STR0075,STR0077,STR0078}, .T.},; // 'Interven��o Otimiza��o?' ## "1=Impedir" ## "2=Permitir Usu�rios" ## "3=Alertar"
		{"MV_CPLLUS" , STR0063             , "C", "@!","USR" , "Tms"  , "GpViag"  ,                          , .T.},; // 'Usu�rios com Permiss�o de interven��o'
		{"MV_CPLEST" , STR0064             , "C", "@!",      , "Tms"  , "GpViag"  , {STR0075,STR0076}        , .T.}; // 'A��o Estorno ?' ## "Impedir" ## "Alertar"
		}
	EndIf

	aadd(aCampos,{"MV_CPLUAUT",STR0079, "C",,,"Integ"  , "GpCom"     ,                 , .T.}) // 'Endere�o do webservice de autentica��o'
	aadd(aCampos,{"MV_USRCPL", STR0083, "C",,,"Integ"  , "GpCom"     ,                 , .T.}) // 'Usu�rio de autentica��o do webservice'
	aadd(aCampos,{"MV_PSWCPL", STR0084, "C",,,"Integ"  , "GpCom"     ,                 , .T.}) // 'Senha de autentica��o do webservice'
	aadd(aCampos,{"MV_EXPTOK", STR0082, "N",,,"Integ"  , "GpCom"     ,                 , .T.}) // 'Quantidade de horas para considerar que um token expirou' default 24
	aadd(aCampos,{"MV_CPLTIME",STR0096, "N",,,"Integ"  , "GpCom"     ,                 , .T.}) // 'Tempo m�ximo (em segundos) de inatividade permitida para a recep��o da resposta (Timeout).'

	If IntTMs .And. DTQ->(ColumnPos("DTQ_TIPMON")) > 0
		aadd(aCampos,{"MV_CPLINT2",STR0085, "C", "@!",  , "Tms"  , "GpGeral"     , {STR0086,STR0087,STR0088,STR0089}, .T.}) // Define o tipo da integra��o com o Cockpit Log�stico ? ## 1=Planejamento; 2=Execucao;3=Ambos;4=Nao Utiliza
	EndIf 

	For nCont := 1 To Len(aCampos)
		AAdd(aCampos[nCont], OMSXCPLGTT(aCampos[nCont][1]))
	Next nCont

	For nCont := 1 to len(aCampos)
		oStruct:AddField(aCampos[nCont][1], NTOC(nCont,32,2), aCampos[nCont][2] ,aCampos[nCont][10] , , aCampos[nCont][3], aCampos[nCont][4],/*bPICTVAR*/,aCampos[nCont][5], aCampos[nCont][9] /*lCANCHANGE*/,aCampos[nCont][6]/*cFOLDER*/,aCampos[nCont][7]/*cGRUP*/,aCampos[nCont][8]/*@aCOMBOVALUES*/,/*nMAXLENCOMBO*/," ",/*lVIRTUAL*/,/*cPICTVAR*/,/*lINSERTLIN*/)
	Next nCont

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "OMSXCPL1_01" , oStruct, /*cLinkID*/ )
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:AddUserButton(STR0011, "MAGIC_BMP", {|oView| OMSXCPLWST(FwFldGet("MV_CPLURL"),,FwFldGet("MV_CPLUAUT"),FwFldGet("MV_USRCPL"),FwFldGet("MV_PSWCPL"))}, ) // "Testar Webservice Planejamento Viagem"
	oView:AddUserButton(STR0103, "MAGIC_BMP", {|oView| OMSCPLWSMN(FwFldGet("MV_WSMONI"),,FwFldGet("MV_CPLUAUT"),FwFldGet("MV_USRCPL"),FwFldGet("MV_PSWCPL"))}, ) // "Testar Webservice Monitoramento"
	oView:AddUserButton(STR0012, "MAGIC_BMP", {|oView| OMSXCPLMAL()}, ) // "Testar Envio Email"
	oView:AddUserButton(STR0013,'',{|| OMSXCPL3() }) // 'Falhas de conex�o'
	oView:AddUserButton(STR0014,'',{|| OMSXCPL4() }) // 'Falhas de transmiss�o'
	oView:SetOwnerView("OMSXCPL1_01","MASTER")

Return oView

Function OMSXCPL1VR(cSer,cCod,cTipTra)
	Local lRet 
	Private cSerTms := cSer
	
	
	If DA8->DA8_FILIAL+DA8->DA8_COD != xFilial("DA8")+cCod
		DA8->(dbSetOrder(1))
		DA8->(dbSeek(xFilial("DA8") + cCod))
	EndIf
	
	lRet := DA8->DA8_SERTMS == cSer
	
	If !lRet .Or. (!Empty(cTipTra) .And. cTipTra != DA8->DA8_TIPTRA)
		Help(,,'HELP',,STR0015 + AllTrim( TmsValField('cSerTms',.F.) ),1,0) // 'A rota informada n�o � v�lida para o servi�o '
	EndIf
	
	If lRet .And. DA8->DA8_ATIVO == StrZero(2,Len(DA8->DA8_ATIVO))
		Help(,,'HELP',,STR0016,1,0) // "Rota n�o est� ativa no Cadastro de Rotas "
		lRet := .F.
	EndIf
	
	
Return lRet
//------------------------------------------------------------------------------------------------

Static Function OMSXCPLCOM(oModel)
	Local oModelPF  := oModel:GetModel('OMSXCPL1_01')
	Local nCont
	Local aCamposPF := oModelPF:GetStruct():GetFields()
	Local cLink := oModelPF:GetValue("MV_CPLURL")
	
	cLink := AllTrim(StrTran(AllTrim(cLink),"?wsdl",""))
	
	If Rat("/",cLink) == Len(cLink)
		cLink := SubStr(cLink,1,Len(cLink)-1)
	EndIf
	
	oModelPF:LoadValue("MV_CPLURL",cLink)

	For nCont := 1 To Len(aCamposPF)
		PUTMV(aCamposPF[nCont][3] , oModelPF:GetValue(aCamposPF[nCont][3]))
	Next nCont


Return .T.

Static Function OMSXCPLGTT(cPar)

Return AllTrim( Posicione("SX6",1,xFilial("SX6")+cPar,"X6_DESCRIC") + ;
			    Posicione("SX6",1,xFilial("SX6")+cPar,"X6_DESC1")   + ;
			    Posicione("SX6",1,xFilial("SX6")+cPar,"X6_DESC2"))   + ;
			    " | " + Alltrim(Posicione("SX6",1,xFilial("SX6")+cPar,"X6_VAR") )

//-----------------------------------------------------

Function OMSXCPLMAL()

	Local aRetMail := GFEMail(FwFldGet("MV_CPLMAL"), STR0017, STR0018, .F., {}) // "SIGATMS - Teste de registro de falhas" ## "Teste registro de falhas OK"
	If !aRetMail[1]
		MsgInfo(STR0019 + aRetMail[2]) // "Falha no teste de envio de e-mail: "
	Else
		MsgInfo(STR0020) // "Sucesso no teste de envio de e-mail."
	EndIf
Return

Function OMSCPL1VLD(oModel)
	
	If FwFldGet("MV_CPLINT") == "1"
		
		If Empty(FwFldGet("MV_CPLURL")) 
			Help( ,, 'Help',, STR0101, 1, 0 ) // Para ativar a integra��o com o planejamento de viagens do Cockpit Log�stico � necess�rio informar o endere�o WebService (MV_CPLURL).
			Return .F.
		EndIf
		
		If Empty(FwFldGet("MV_CPLREG")) 
			Help( ,, 'Help',, STR0022, 1, 0 ) // 'Quando a Integra��o Cockpit Log�stico est� habilitada, � obrigat�rio o preenchimento da Regional.'
			Return .F.
		EndIf
		
		If Empty(FwFldGet("MV_CPLEMB")) 
			Help( ,, 'Help',, STR0023, 1, 0 ) // 'Quando a Integra��o Cockpit Log�stico est� habilitada, � obrigat�rio o preenchimento do Embarcador.'
			Return .F.
		EndIf
		
		If Empty(FwFldGet("MV_CPLIDS")) 
			Help( ,, 'Help',, STR0024, 1, 0 ) // 'Quando a Integra��o Cockpit Log�stico est� habilitada, � obrigat�rio o preenchimento da Origem dos Dados.'
			Return .F.
		EndIf
		
		If SuperGetMv("MV_INTTMS",.F.,.F.) == .T. .And. nModulo == 43
			
			If Empty(FwFldGet("MV_CPLTP1"))
				Help( ,, 'Help',, STR0025, 1, 0 ) // 'Quando a Integra��o com o TMS est� habilitada, � obrigat�rio o preenchimento da Tipo Pedido Coleta.'
				Return .F.
			EndIf
			
			If Empty(FwFldGet("MV_CPLTP2"))
				Help( ,, 'Help',, STR0026, 1, 0 ) // 'Quando a Integra��o com o TMS est� habilitada, � obrigat�rio o preenchimento da Tipo Pedido Transporte.'
				Return .F.
			EndIf
			
			If Empty(FwFldGet("MV_CPLTP3"))
				Help( ,, 'Help',, STR0027, 1, 0 ) // 'Quando a Integra��o com o TMS est� habilitada, � obrigat�rio o preenchimento da Tipo Pedido Entrega.'
				Return .F.
			EndIf
			
		EndIf
		
	EndIf
	
	If FwFldGet("MV_CPLMON") == "1".And. Empty(FwFldGet("MV_WSMONI"))
		Help( ,, 'Help',, STR0102, 1, 0 ) // Para ativar a integra��o com o monitoramento do Cockpit Log�stico � necess�rio informar o endere�o WebService (MV_WSMONI).
		Return .F.
	EndIf
Return .T.

Function OMSXCPLWST(cUrl,lAvisoOK,cUrlAuth,cUsrAut,cPswAut,lMErro,cFalha)
	Local lRet := .F.
	Local nRetry := 4
	Local lBlind := IsBlind()
	Local cToken
	Private cLink := StrTran(AllTrim(cUrl),"?wsdl","")
	Private cRet
	Private cRetHtml := ""
	cRetCPLWST := "" // Uso externo
	
	Default lAvisoOK := .T.
	Default cUrlAuth := SuperGetMv("MV_CPLUAUT",,"")
	Default cUsrAut := SuperGetMv("MV_USRCPL",.F.,"")
	Default cPswAut := SuperGetMv("MV_PSWCPL",.F.,"")
	Default lMErro := .T.
	Default cFalha := ""

	cUsrAut := StrTran(cUsrAut," ","")
	cPswAut := AllTrim(cPswAut)
	
	If Rat("/",cLink) == Len(cLink)
		cLink := SubStr(cLink,1,Len(cLink)-1)
	EndIf

	If !Empty(cUrlAuth) .And. !Empty(cUsrAut) .And. !Empty(cPswAut)
		If lAvisoOK
			cToken := OMCPLBuscaToken(cUrlAuth,cUsrAut,cPswAut)
		Else
			cToken := OMGETTOKEN(lMErro,@cFalha)
		EndIf
		If Empty(cToken)
			Return .F.
		EndIf
	EndIf
	
	MsgRun(STR0029, STR0030, {|| cRetHtml:= Iif( Empty(cToken),;
												HttpGet(cLink,,20,,@cRet),;
												HttpsGet(cLink, "", "", "", "", 20, {'user.token: ' + cToken}, @cRet));
							}) // "Testando WebService..." ## "Aguarde"

	While Empty(cRetHtml) .And. nRetry > 0
		If !lBlind
			If MsgYesNo(STR0031) // "N�o foi poss�vel conectar no WebService. Tentar novamente?"
				MsgRun(STR0029, STR0030, {|| cRetHtml:= Iif( Empty(cToken),;
												HttpGet(cLink,,20,,@cRet),;
												HttpsGet(cLink, "", "", "", "", 20, {'user.token: ' + cToken}, @cRet));
							}) // "Testando WebService..." ## "Aguarde"
			Else
				Exit
			EndIf
		Else
			cRetHtml:= Iif( Empty(cToken),;
							HttpGet(cLink,,20,,@cRet),;
							HttpsGet(cLink, "", "", "", "", 20, {'user.token: ' + cToken}, @cRet))
		EndIf
		nRetry--
	EndDo
	If Empty(cRetHtml)
		cRetCPLWST := STR0032 + CRLF + "HTTPGET:" + cValToChar(cRet) // "N�o foi poss�vel conectar no WebService."
		MsgInfo(STR0032) // "N�o foi poss�vel conectar no WebService."
	ElseIf !TemServicos(@cRetHtml)
		cRetCPLWST := STR0033 + CRLF + "HTTPGET:" + cValToChar(cRet) // "O endere�o informado do webservice parece inv�lido."
		MsgInfo(STR0033) // "O endere�o informado do webservice parece inv�lido."
	Else
		If lAvisoOK
			MsgInfo(STR0034) // "Conex�o OK."
		EndIf
		lRet := .T.
	EndIf
	cRetHtml:= ""
	
Return lRet

/*{Protheus.doc} OMSCPLWSMN

Verifica se a url informada para o endere�o webservice de monitoramento � v�lida.
@author amanda.vieira
@since 05/08/2019
@version 1.0

*/
Function OMSCPLWSMN(cUrl,lAvisoOK,cUrlAuth,cUsrAut,cPswAut)
Local lRet := .F.
Local nRetry := 4
Local lBlind := IsBlind()
Local cToken := ""
Local cSoapSend := ""
Private cLink := StrTran(AllTrim(cUrl),"?wsdl","")
Private cRet
Private cRetHtml := ""
cRetCPLWST := "" // Uso externo

Default lAvisoOK := .T.
Default cUrlAuth := SuperGetMv("MV_CPLUAUT",,"")
Default cUsrAut := SuperGetMv("MV_USRCPL",.F.,"")
Default cPswAut := SuperGetMv("MV_PSWCPL",.F.,"")
	
	cUsrAut := StrTran(cUsrAut," ","")
	cPswAut := AllTrim(cPswAut)
	
	If Rat("/",cLink) == Len(cLink)
		cLink := SubStr(cLink,1,Len(cLink)-1)
	EndIf

	If !Empty(cUrlAuth) .And. !Empty(cUsrAut) .And. !Empty(cPswAut)
		If lAvisoOK
			cToken := OMCPLBuscaToken(cUrlAuth,cUsrAut,cPswAut)
		Else
			cToken := OMGETTOKEN()
		EndIf
		If Empty(cToken)
			Return .F.
		EndIf
	EndIf
	
	cSoapSend := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">'
	cSoapSend += '<soapenv:Header/>' 
	cSoapSend += '<soapenv:Body>'
	cSoapSend += '<mon:request xmlns:mon="http://www.neolog.com.br/cpl/acquisition/monitoring/monitorable/">'
	cSoapSend += '</mon:request>'
	cSoapSend +='</soapenv:Body>'
	cSoapSend +='</soapenv:Envelope>'
	
	MsgRun(STR0029, STR0030, {|| cRetHtml:= HTTPSPost(cLink, "", "", "", "", cSoapSend, 20, {'user.token: ' + cToken}, @cRet) })
												
	While Empty(cRetHtml) .And. nRetry > 0
		If !lBlind
			If MsgYesNo(STR0031) // "N�o foi poss�vel conectar no WebService. Tentar novamente?"
				MsgRun(STR0029, STR0030, {|| cRetHtml:= HTTPSPost(cLink, "", "", "", "", cSoapSend, 20, {'user.token: ' + cToken}, @cRet) })
			Else
				Exit
			EndIf
		Else
			cRetHtml:= HTTPSPost(cLink, "", "", "", "", cSoapSend, 20, {'user.token: ' + cToken}, @cRet)
		EndIf
		nRetry--
	EndDo
	If Empty(cRetHtml)
		cRetCPLWST := STR0032 + CRLF + "HTTPPOST:" + cValToChar(cRet) // "N�o foi poss�vel conectar no WebService."
		MsgInfo(STR0032) // "N�o foi poss�vel conectar no WebService."
	ElseIf !("monitorable" $ cRetHtml)
		cRetCPLWST := STR0033 + CRLF + "HTTPPOST:" + cValToChar(cRet) // "O endere�o informado do webservice parece inv�lido."
		MsgInfo(STR0033) // "O endere�o informado do webservice parece inv�lido."
	Else
		If lAvisoOK
			MsgInfo(STR0034) // "Conex�o OK."
		EndIf
		lRet := .T.
	EndIf
	cRetHtml:= ""
	
Return lRet

Static Function TemServicos(cRetHtml)
	Local lTemTodos := .T.
	Local nX
	
	For nX := 1 to Len(aListaOMSX)
		If !(aListaOMSX[nX][1] $ cRetHtml)
			lTemTodos := .F.
			Exit 
		EndIf
	Next nX
	
Return lTemTodos

Function OMSXCPLLIST()
Return aListaOMSX

/*/{Protheus.doc} OMSXCPL1AT
Retorna se a integra��o est� ativa. Recebe se foi uma itera��o do usu�rio que necesita o retorno
@author siegklenes.beulke
@since 18/10/2016
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function OMSXCPL1AT(lUsuario)
	
	Default lUsuario := .F.
	
	If SuperGetMv("MV_CPLINT",.F.,"2") != "1"
		MsgInfo(STR0035) // "Integra��o com o Cockpit Log�stico est� inativa."
		Return .F.
	EndIf
	
	If !lUsuario .And. SuperGetMv("MV_CPLSTP",.F.,"2") == "1"
		MsgInfo(STR0036) // "Integra��o com o Cockpit Log�stico est� suspensa."
		Return .F.
	EndIf
	
Return .T.

//===========================================================================================================
/* Fun��o OmsXCplVld - Fun��o de Valida��o de campo X3_VALID
@author  	Rafael Souza
@version 	P12.1.17
@build		
@since 	15/12/2017
@return 	lRet 
*/
//===========================================================================================================
Function OmsXCplVld(cCampo)

Local lRet     := .T.
Default cCampo := ReadVar()

If	cCampo $ 'M->C6_DATAEMB'
	If GDFieldGet("C6_DATAEMB",n) > GDFieldGet("C6_ENTREG",n)
		Help("",1,"OMSXCPLA1") //--"Data de Embarque n�o pode ser maior que a data de entrega"
		lRet := .F.
	EndIf 
EndIf 

Return (lRet) 
