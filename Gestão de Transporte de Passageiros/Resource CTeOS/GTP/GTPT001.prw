#include 'protheus.ch'
#include 'parmtype.ch'
#include 'totvs.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FILEIO.CH"
#INCLUDE "GTPT001.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPT001()
Transmissor de notas de transportes de passageiros
 
@sample	GTPT001()
 
@return	oBrowse  Retorna Transmissor de notas de transportes
 
@author	Fernando Amorim(Cafu)
@since		21/09/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPT001()

Local oBrowse 	:= FWMBrowse():New()
Local cQuery	:= ''
Local cAliasCa  := ''

oBrowse:SetAlias("GZH")
oBrowse:SetDescription("Notas de Transportes de Passageiros CTeOS") 
oBrowse:AddLegend("GZH_STATUS=='1'", "RED", "Pendente de Complemento") 
oBrowse:AddLegend("GZH_STATUS=='2'", "YELLOW", "Pendente de Transmissão") 
oBrowse:AddLegend("GZH_STATUS=='3'", "GREEN", "Transmitida") 
oBrowse:AddLegend("GZH_STATUS=='4'", "GRAY", "Erro de Transmissão")
oBrowse:AddLegend("GZH_STATUS=='5'", "BLUE", "Documento Impresso")
oBrowse:AddLegend("GZH_STATUS=='6'", "BR_PRETO_1", "Excluido Doc Saida")
oBrowse:AddLegend("GZH_STATUS=='7'", "BR_PRETO_2", " Transmitido Cancelamento")
oBrowse:AddLegend("GZH_STATUS=='8'", "BR_PRETO_3", " Autorizado Cancelamento")
oBrowse:AddLegend("GZH_STATUS=='9'", "BROWN", "Rejeitado Cancelamento")
oBrowse:AddLegend("GZH_STATUS=='A'", "BR_PRETO_4", "Anulado")
oBrowse:AddLegend("GZH_STATUS=='B'", "BR_PRETO_5", "Sustituto")
oBrowse:AddLegend("GZH_STATUS=='C'", "BR_PRETO_6", "Complemento") 
If GZH->(FieldPos("GZH_ORIGEM")) > 0
	oBrowse:SetFilterDefault ( 'GZH_FILIAL == "' + xFilial('GZH') + '" .AND. GZH_ORIGEM != "GTPA850" ')
Else
	oBrowse:SetFilterDefault ( 'GZH_FILIAL == "' + xFilial('GZH') + '" ' )
EndIf
cAliasCa := GetNextAlias()
cQuery := " SELECT R_E_C_N_O_ AS RECNO " +                      CRLF
cQuery += "   FROM " +	RetSqlName("GZH") + " GZH " +           CRLF
cQuery += "  WHERE GZH.GZH_FILIAL ='"  + xFilial("GZH") + "'" + CRLF
cQuery += "    AND GZH.GZH_STATUS = '6'" +                      CRLF
If ( GZH->(FieldPos("GZH_ORIGEM")) > 0  )
	cQuery += "    AND GZH.GZH_ORIGEM <> 'GTPA850'" + 			CRLF
EndIf 
cQuery += "    AND GZH.D_E_L_E_T_= ' '	"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasCa, .F., .T.)
If !(cAliasCa)->(Eof())
	Aviso("CTe OS", "Há documentos de saida excluidos que ainda não foram transmitidos para o SEFAZ, Verifique legenda de status", {'OK'}, 2)
EndIf
(cAliasCa)->(DbCloseArea())

oBrowse:DisableDetails()
If !IsBlind()
	oBrowse:Activate()
EndIf

If FindFunction('GTPANPS')
	GTPANPS()	
Endif

Return oBrowse

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Array com opções do menu
 
@author	Fernando Amorim(Cafu)
@since		21/09/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE "Legenda"              ACTION "GTPT001Leg()"    OPERATION 1 ACCESS 0 // Legenda
ADD OPTION aRotina TITLE "Visualizar"           ACTION "VIEWDEF.GTPT001" OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE "Atualizar"            ACTION "VIEWDEF.GTPT001" OPERATION 4 ACCESS 0 // Atualizar
ADD OPTION aRotina TITLE "Transmitir"           ACTION "GTPT001TRA()"    OPERATION 4 ACCESS 0 // Transmitir
ADD OPTION aRotina TITLE "Imprimir DACTE-OS"    ACTION "G001IMPRIME()"   OPERATION 4 ACCESS 0 // Imprimir DacteOS
ADD OPTION aRotina TITLE "Cancelar CTe-OS"      ACTION "G001Cancel()"    OPERATION 5 ACCESS 0 // Cancelar Cte-OS
ADD OPTION aRotina TITLE "Exportar CTEOS"       ACTION "G001EXPORTA"     OPERATION 4 ACCESS 0 // Consulta Cteos
ADD OPTION aRotina TITLE "Parametros de Conf."  ACTION "CTeOSConfig()"   OPERATION 4 ACCESS 0 // parametros de conf
ADD OPTION aRotina TITLE "Parametros Eventos."  ACTION "SpedEpecPar()"   OPERATION 4 ACCESS 0 // parametros de Eventos
ADD OPTION aRotina TITLE "Configuração TSS"     ACTION "SpedNFeCfg()"    OPERATION 4 ACCESS 0 // configuração TSS
ADD OPTION aRotina TITLE "Consulta Eventos"     ACTION "GZHConsEvento"   OPERATION 4 ACCESS 0 // Consulta Eventos
ADD OPTION aRotina TITLE "Consulta CTeOS"       ACTION "GZHCTeOSStatus()"  OPERATION 4 ACCESS 0 // configuração TSS
ADD OPTION aRotina TITLE "Carta de Correção"    ACTION "G001CCe"         OPERATION 4 ACCESS 0 // configuração TSS
ADD OPTION aRotina TITLE "Gera Anulação CTe-OS" ACTION "G001GerAnu()"    OPERATION 4 ACCESS 0 // Anula Cte-OS //OSMAR
ADD OPTION aRotina TITLE "Excesso de Bagagem"   ACTION "VLDGQ2()"        OPERATION 4 ACCESS 0 // Excesso de Bagagem
ADD OPTION aRotina TITLE "Inutilização"   		ACTION "Gtp01tInut()"   OPERATION 4 ACCESS 0 // Inutilização

//ADD OPTION aRotina TITLE "Anular CTe-OS"    ACTION "G001Anula()" OPERATION 4 ACCESS 0 // Anula Cte-OS //OSMAR
Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author	Fernando Amorim(Cafu)
@since		21/09/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruGZH  := FWFormStruct(1,"GZH") // Eventos
Local bCommit   := {|oMdl| GT001Commit(oMdl)}
Local bValid   	:= {|oMdl| ValidForm(oMdl)}
Local oModel    := NIL 

oModel := MPFormModel():New("GTPT001",/*bPreValidMdl*/, bValid/*bPosValidMdl*/,bCommit, /*bCancel*/ )

GT001Struct(oStruGZH,'M')
    
oModel:SetDescription("Complemento de Notas de Transportes de Passageiros CTeOS")  
oModel:AddFields('FIELDGZH',,oStruGZH)
oModel:SetPrimaryKey({"GZH_FILIAL","GZH_CODIGO"})
oModel:GetModel('FIELDGZH'):SetDescription("Complemento para CTeOS") 

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author	Fernando Amorim(Cafu)
@since		21/09/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel   := ModelDef()
Local oStruGZH := FWFormStruct(2, 'GZH')

GT001Struct(oStruGZH,'V')

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEWGZH', oStruGZH, 'FIELDGZH') 

oView:CreateVerticalBox( 'DIREITA' , 100)

oView:SetOwnerView('VIEWGZH','DIREITA')

oView:EnableTitleView("VIEWGZH")

If !fwisincallstack("VLDGQ2") // edição do campo caso seja Excesso de Bagagem.
	oStruGZH:SetProperty( "GZH_CODGQ2", MVC_VIEW_CANCHANGE, .F.)
EndIf

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} GT001Struct
Ajustar estrutura
@author	Fernando Amorim(Cafu)
@since		21/09/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function GT001Struct(oStruGZH,cTipo)

//Local oModel := FwModelActive()

If cTipo == 'V'
	If GZH->(FieldPos("GZH_PRODUT")) > 0 .AND. GZH->(FieldPos("GZH_QUANT")) > 0;
	 .AND. GZH->(FieldPos("GZH_VLUNIT")) > 0 .AND. GZH->(FieldPos("GZH_TES")) > 0;
	  .AND. GZH->(FieldPos("GZH_ORIGEM")) > 0
		oStruGZH:SetProperty( "GZH_PRODUT", MVC_VIEW_CANCHANGE, .F.)
		oStruGZH:SetProperty( "GZH_QUANT" , MVC_VIEW_CANCHANGE, .F.)
		oStruGZH:SetProperty( "GZH_VLUNIT", MVC_VIEW_CANCHANGE, .F.)
		oStruGZH:SetProperty( "GZH_TES"   , MVC_VIEW_CANCHANGE, .F.)
		oStruGZH:SetProperty( "GZH_ORIGEM", MVC_VIEW_CANCHANGE, .F.)
	EndIf

	If GZH->(FieldPos('GZH_ORIGEM')) > 0
		oStruGZH:RemoveField('GZH_ORIGEM')
	EndIf

	If GZH->(FieldPos('GZH_NFORI')) > 0
		oStruGZH:RemoveField('GZH_NFORI')
	EndIf

	If GZH->(FieldPos('GZH_SERORI')) > 0
		oStruGZH:RemoveField('GZH_SERORI')
	EndIf

	oStruGZH:SetProperty('GZH_STATUS' , MVC_VIEW_COMBOBOX,{'1=Pendente de Complemento','2=Pendente de transmissão',;
	'3=Transmitida','4=Erro de Transmissão','5=Documento Impresso','6=Excluido Doc Saida',;
	'7=Transmitido Cancelamento','8=Autorizado Cancelamento','9=Rejeitado Cancelamento','A=Anulado','B=Substituto','C=Complemento' } )
Endif
If cTipo == 'M'
	If GZH->(FieldPos("GZH_PRODUT")) > 0 .AND. GZH->(FieldPos("GZH_QUANT")) > 0;
	 .AND. GZH->(FieldPos("GZH_VLUNIT")) > 0 .AND. GZH->(FieldPos("GZH_TES")) > 0;
	  .AND. GZH->(FieldPos("GZH_ORIGEM")) > 0
		oStruGZH:SetProperty( "GZH_PRODUT", MODEL_FIELD_OBRIGAT, .F.)
		oStruGZH:SetProperty( "GZH_QUANT" , MODEL_FIELD_OBRIGAT, .F.)
		oStruGZH:SetProperty( "GZH_VLUNIT", MODEL_FIELD_OBRIGAT, .F.)
		oStruGZH:SetProperty( "GZH_TES"   , MODEL_FIELD_OBRIGAT, .F.)
		oStruGZH:SetProperty( "GZH_ORIGEM", MODEL_FIELD_OBRIGAT, .F.)
	EndIf

	oStruGZH:SetProperty('GZH_STATUS' , MODEL_FIELD_VALUES,{'1=Pendente de Complemento','2=Pendente de transmissão',;
	'3=Transmitida','4=Erro de Transmissão','5=Documento Impresso','6=Excluido Doc Saida',;
	'7=Transmitido Cancelamento','8=Autorizado Cancelamento','9=Rejeitado Cancelamento','A=Anulado','B=Substituto','C=Complemento' } )
Endif

If fwisincallstack("VLDGQ2") // Campo obrigatorio caso seja Excesso de Bagagem 
	oStruGZH:SetProperty("GZH_CODGQ2", MODEL_FIELD_OBRIGAT, .T.)
Endif

If cTipo == 'M' .And. fwisincallstack("GTPT001") .AND. !fwisincallstack("CTEOSIMPRESSAO")  .AND. !fwisincallstack("G001Cancel") .AND. !fwisincallstack("G001MStatus")
	
	oStruGZH:SetProperty('GZH_NOME' ,   MODEL_FIELD_INIT,{|| Posicione( "SA1", 1, xFilial('SA1') + GZH->GZH_CLIENT + GZH->GZH_LOJA , 'A1_NOME') } )
	
	oStruGZH:SetProperty( "GZH_INFQ",   MODEL_FIELD_OBRIGAT, .T. )
	oStruGZH:SetProperty( "GZH_UMUINI", MODEL_FIELD_OBRIGAT, .T. )             
	oStruGZH:SetProperty( "GZH_CMUINI", MODEL_FIELD_OBRIGAT, .T. )  
	oStruGZH:SetProperty( "GZH_UMUFIM", MODEL_FIELD_OBRIGAT, .T. )
	
	oStruGZH:SetProperty( "GZH_REGEST", MODEL_FIELD_OBRIGAT, .F.)
	oStruGZH:SetProperty( "GZH_AUTTAF", MODEL_FIELD_OBRIGAT, .F.)

	oStruGZH:SetProperty( '*'	, MODEL_FIELD_WHEN, {|oMdl,cField,xVal|  GT001X3WhenGZH(oMdl,cField,xVal) })
//	oStruGZH:SetProperty( 'GZH_REGEST'	, MODEL_FIELD_WHEN, {|oMdl,cField,xVal|  GT001X3WhenGZH(oMdl,cField,xVal) })
//	oStruGZH:SetProperty( 'GZH_AUTTAF'	, MODEL_FIELD_WHEN, {|oMdl,cField,xVal|  GT001X3WhenGZH(oMdl,cField,xVal) })
	             
	oStruGZH:SetProperty( "GZH_HSAIDA", MODEL_FIELD_VALID, {|oModel| VLDHORA(oModel)} ) 
	oStruGZH:SetProperty( "GZH_VEIC"  , MODEL_FIELD_VALID, {|oModel| VLDVEIC(oModel)} ) 
	oStruGZH:SetProperty( "GZH_CODGQ2", MODEL_FIELD_VALID, {|oModel| VLDCODGQ2(oModel)})  
	             
	oStruGZH:AddTrigger('GZH_VEIC'  , ;     // [01] Id do campo de origem
						'GZH_PLACA'  , ;     // [02] Id do campo de destino
			 			{ || .T. }    , ; 	  // [03] Bloco de codigo de validação da execução do gatilho
			 			{ ||GA0001Trig('GZH_PLACA') } ) // [04] Bloco de codigo de execução do gatilho
	             
	oStruGZH:AddTrigger('GZH_VEIC'  , ;     // [01] Id do campo de origem
						'GZH_RENAVA'  , ;     // [02] Id do campo de destino
			 			{ || .T. }    , ; 	  // [03] Bloco de codigo de validação da execução do gatilho
			 			{ ||GA0001Trig('GZH_RENAVA')} ) // [04] Bloco de codigo de execução do gatilho
		
	oStruGZH:AddTrigger('GZH_CMUINI'  , ;     // [01] Id do campo de origem
						'GZH_DMUINI'  , ;     // [02] Id do campo de destino
			 			{ || .T. }    , ; 	  // [03] Bloco de codigo de validação da execução do gatilho
			 			{ ||GA0001Trig('GZH_DMUINI') } ) // [04] Bloco de codigo de execução do gatilho
	
	oStruGZH:AddTrigger('GZH_CMUFIM'  , ;     // [01] Id do campo de origem
						'GZH_DMUFIM'  , ;     // [02] Id do campo de destino
			 			{ || .T. }    , ; 	  // [03] Bloco de codigo de validação da execução do gatilho
			 			{ ||GA0001Trig('GZH_DMUFIM') } ) // [04] Bloco de codigo de execução do gatilho
			 			
Endif

Return()

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPT001Leg()

Monta Legenda


@return nil

@author 	Fernando Amorim(Cafu) 
@since		21/09/2017
@version 12.1.17

/*/
//------------------------------------------------------------------------------------------------------
Function GTPT001Leg(lAut)
Default lAut := .F.

oLegenda := FwLegend():New()

oLegenda:Add( "", "BR_VERMELHO"	, "Pendente de Complemento" ) 
oLegenda:Add( "", "BR_AMARELO"	, "Pendente de Transmissão") 
oLegenda:Add( "", "BR_VERDE"	, "Transmitida" ) 
oLegenda:Add( "", "BR_CINZA"	, "Erro de Transmissão" ) 
oLegenda:Add( "", "BR_AZUL"		, "Documento Impresso" ) 
oLegenda:Add( "", "BR_PRETO_1"	, "Excluido Documento de saida" ) 
oLegenda:Add( "", "BR_PRETO_2"	, "Transmitido cancelamento" ) 
oLegenda:Add( "", "BR_PRETO_3"	, "Autorizado cancelamento" ) 
oLegenda:Add( "", "BR_MARROM"	, "Rejeitado Cancelamento" ) 
oLegenda:Add( "", "BR_PRETO_4"  , "Anulado")
oLegenda:Add( "", "BR_PRETO_5"  , "Sustituto")
oLegenda:Add( "", "BR_PRETO_6"  , "Complemento")

oLegenda:Activate()
if !lAut
	oLegenda:View()
EndIf
oLegenda:DeActivate()

Return(Nil)
 
 
 //-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FILCC2GZH()

Filtro da SXB CC2GZH


@return LRet

@author 	Fernando Amorim(Cafu) 
@since		22/09/2017
@version 12.1.17

/*/
//------------------------------------------------------------------------------------------------------
Function FILCC2GZH()
 
Local cCampo		:= ReadVar()
Local cConteudo	:= ''

If cCampo == 'M->GZH_CMUINI'
	cConteudo := M->GZH_UMUINI
ElseIf cCampo == 'M->GZH_CMUFIM'
	cConteudo := M->GZH_UMUFIM
EndIf	

Return CC2->CC2_EST == cConteudo 


//------------------------------------------------------------------------------
/*/{Protheus.doc} GA001INIGZH
	Grava os campos iniciais da nota CTEOS na GZH
	
@param cNota    	Numero da nota	
@param cSerie    	Serie da nota
@param cCliente    	Cliente da nota
@param cLoja	    Loja da nota

@author Fernando Amorim(Cafu)
@since		22/09/2017       
@version	P12
/*/
//------------------------------------------------------------------------------

Function G001INIGZH(cNota,cSerie,cCliente,cLoja)
Local lRet  		:= .T.
Local cProduto      := ""
Local cTes          := ""
Local cOrigem       := "GTPT001"
Local nQuant        := 0
Local nVlUni        := 0
Local aArea         := GetArea()
Local oModelGZH 	
Local oMdlGZH

SC6->(DbSetOrder(4))//C6_FILIAL, C6_NOTA, C6_SERIE, R_E_C_N_O_, D_E_L_E_T_
SC6->(DBSEEK(XFILIAL("SC6")+cNota+cSerie))
cProduto := SC6->C6_PRODUTO
cTes     := SC6->C6_TES
nQuant   := SC6->C6_QTDVEN
nVlUni   := SC6->C6_PRCVEN

If TCCanOpen(RetSqlName('GZH')) .And. ChkFile('GZH')

	oModelGZH := FwLoadModel('GTPT001')

	//-----------------------------------------------------
	// Validacao para nao deixar gerar registro duplicado
	// e atualizo o Status para 1 (Pendente Complemento).
	// @autor: Douglas Parreja
	//-----------------------------------------------------
	dbSelectArea("GZH") 
	GZH->(dbSetOrder(1)) //GZH_FILIAL+GZH_NOTA+GZH_SERIE+GZH_CLIENT+GZH_LOJA
	if GZH->( dbSeek( xFilial("GZH") + cNota + cSerie ))
		GZH->( reclock( 'GZH', .F. ))
		GZH->(GZH_CLIENT)	:= cCliente
		GZH->(GZH_LOJA) 	:= cLoja
		GZH->(GZH_STATUS) 	:= "1"
		lRet				:= .F.
	else
		
		oModelGZH:SetOperation(MODEL_OPERATION_INSERT)
		
		oModelGZH:GetModel("FIELDGZH"):GetStruct():SetProperty("*", MODEL_FIELD_OBRIGAT,.F.)
		
		oModelGZH:Activate()

		oMdlGZH	:= oModelGZH:GetModel( 'FIELDGZH' ) 

		lRet := oMdlGZH:SetValue( "GZH_NOTA"	, cNota ) .And. ;
				oMdlGZH:SetValue( "GZH_SERIE"	, cSerie) .And. ;
				oMdlGZH:SetValue( "GZH_CLIENT"	, cCliente).And. ;
				oMdlGZH:SetValue( "GZH_LOJA"	, cLoja	) .And. ;
				oMdlGZH:SetValue( "GZH_OBSNF"	, SC5->C5_MENNOTA	) .And. ;
				oMdlGZH:SetValue( "GZH_STATUS"	, '1'	)	

		//Validação para adicionar os novos campos na inclusão do cteos 		
		If GZH->(FieldPos("GZH_PRODUT")) > 0 .AND. GZH->(FieldPos("GZH_QUANT")) > 0;
			.AND. GZH->(FieldPos("GZH_VLUNIT")) > 0 .AND. GZH->(FieldPos("GZH_TES")) > 0;
			.AND. GZH->(FieldPos("GZH_ORIGEM")) > 0
			
			lRet := oMdlGZH:SetValue( "GZH_PRODUT"	, cProduto	) .And. ;
				oMdlGZH:SetValue( "GZH_QUANT" 	, nQuant	) .And. ;
				oMdlGZH:SetValue( "GZH_VLUNIT"	, nVlUni	) .And. ;
				oMdlGZH:SetValue( "GZH_TES"  	, cTes	) .And. ;
				oMdlGZH:SetValue( "GZH_ORIGEM"	, cOrigem	)

			If ( lRet .And. oMdlGZH:HasField("GZH_TOTAL") )
				lRet := oMdlGZH:SetValue( "GZH_TOTAL", nVlUni * nQuant )
			EndIf
		EndIf

		if ( lRet .And. oModelGZH:VldData() )
			oModelGZH:CommitData()
		else

			lRet := .f.
			If !IsBlind()
				JurShowErro( oModelGZH:GetErrorMessage() )
			EndIf

		EndIf
		
		If Valtype(oModelGZH) = "O"
			oModelGZH:DeActivate()
			oModelGZH:Destroy()
			oModelGZH:= nil
		EndIf			

	endif

Endif

RestArea(aArea)
Return( lRet )

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA0001Trig
Função que preenche trigger

@sample	GA0001Trig()

@author	Fernando Amorim(cafu)
@since		21/09/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Function GA0001Trig(cDom)

Local oModel    := FwModelActive()
Local oFieldGZH := oModel:GetModel('FIELDGZH')
Local cRet		:= ''


	If cDom =='GZH_PLACA' .AND. !Empty(M->GZH_VEIC)
		oFieldGZH:LoadValue("GZH_PLACA" , posicione("ST9",1,xFilial('ST9')+ M->GZH_VEIC,'T9_PLACA')) 
		cRet	:= posicione("ST9",1,xFilial('ST9')+ M->GZH_VEIC,'T9_PLACA')
	ElseIf cDom =='GZH_RENAVA' .AND. !Empty(M->GZH_VEIC)
		oFieldGZH:LoadValue("GZH_RENAVA" , posicione("ST9",1,xFilial('ST9')+ M->GZH_VEIC,'T9_RENAVAM')) 
		cRet	:= posicione("ST9",1,xFilial('ST9')+ M->GZH_VEIC,'T9_RENAVAM')
	ELseIf cDom == 'GZH_DMUINI' .AND. !Empty(M->GZH_UMUINI) .AND. !Empty(M->GZH_CMUINI)
		oFieldGZH:LoadValue("GZH_DMUINI" , posicione("CC2",1,xFilial('CC2')+ M->GZH_UMUINI + M->GZH_CMUINI,'CC2_MUN'))
		cRet := posicione("CC2",1,xFilial('CC2')+ M->GZH_UMUINI + M->GZH_CMUINI,'CC2_MUN')
	ElseIf cDom == 'GZH_DMUFIM' .AND. !Empty(M->GZH_UMUFIM) .AND. !Empty(M->GZH_CMUFIM)
		oFieldGZH:LoadValue("GZH_DMUFIM" , posicione("CC2",1,xFilial('CC2')+ M->GZH_UMUFIM + M->GZH_CMUFIM,'CC2_MUN'))
		cRet	:= posicione("CC2",1,xFilial('CC2')+ M->GZH_UMUFIM + M->GZH_CMUFIM,'CC2_MUN')
	Endif

Return cRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GT001X3WhenGZH()

Rotina responsavel por habilitar a edição dos campos com base no tipo de trecho (Campo GZH_STATUS)

@sample	GT001X3WhenGZH()

@Param		oGrid - Objeto Grid  
@Param		cCampo - Nome do campo a ser avaliado.

@author	Fernando Amorim(Cafu)
@since		22/09/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function GT001X3WhenGZH(oMdl,cField,xVal,lAut)
Local cStatus := ""
Local lRet 	  := .F.

Default lAut  := .F.

cStatus := iif(lAut, '1', oMdl:GetValue("GZH_STATUS"))
If cStatus $ '1|2|4'
	lRet := .T.
EndIf

If lAut .or. (cField == 'GZH_EVENTO' .AND. oMdl:GetValue("GZH_EVENTO") == '02')
	lRet := .T.
EndIf

//Do Case
//	Case cField == "GZH_AUTTAF"
//		IF oMdl:GetValue("GZH_TPFRET") == '01'
//			lRet := .T. 
//		ELse
//			lRet := .F.
//		EndIf
//	Case cField == "GZH_REGEST"	
//		IF oMdl:GetValue("GZH_TPFRET") == '02'
//			lRet := .T. 
//		ELse
//			lRet := .F.
//		EndIf
//EndCase

Return (lRet)


/*/{Protheus.doc} GT001Commit   
    Executa o bloco Commit do MVC
    @type  Static Function
    @author Fernando Amorim(Cafu)
    @since 22/09/2017
    @version version
    @param oModel, objeto, instância da Classe FwFormModel
    @return lRet, lógico, .t. - Efetuou o Commit com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GT001Commit(oModel, lAut)
Local lRet 		:= .F.
Local oMdlGZH	:= oModel:GetModel("FIELDGZH")

Default lAut    := .F.

If lAut .or. oModel:VldData() 
 	If fwisincallstack("GTPT001") .AND. !fwisincallstack("CTeOSRemessa") .AND. !fwisincallstack("CTEOSIMPRESSAO") .AND. !fwisincallstack("CTEOSCONSULTA")
 		If oMdlGZH:GetValue( "GZH_STATUS" ) == '1'
 			lRet := oMdlGZH:SetValue( "GZH_STATUS"	, '2'	)						
 		Else		 	
 			lRet := .T.
 		Endif
 	Else
 		lRet := .T.
 	Endif
	If lRet
		lRet := FWFormCommit(oModel)
		If lRet
			if !lAut
				AtualiSF2(oMdlGZH)
				//Aqui ----
			EndIf
		Endif	
	Endif		
Endif

Return(lRet)


/*/{Protheus.doc} GTPT001TRA   
    chama o wizard de transmissão
    @type  Static Function
    @author Fernando Amorim(Cafu)
    @since 22/09/2017
    @version version
   
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPT001TRA()

Local cStatus	:= GZH->GZH_STATUS

If cStatus $ '2|4'

    if(!GZHConsulta()[1])
        If GZH->GZH_EVENTO=='01' //Anula
    		GZHRemessa(,,,'A')
    	ElseIf GZH->GZH_EVENTO=='02' //SUBSTITUI
    		GZHRemessa(,,,'S')
    	ElseIf GZH->GZH_EVENTO=='03' //Complementar	
    		GZHRemessa(,,,'C')
    	Else
	    	GZHRemessa()
		endif	
	endif	
	
Else
	FwAlertHelp("STATUS","Apenas CTEOS pendentes de transmissão ou que irão ser retransmitidos podem utilizar essa função.") 		
Endif

Return()



//------------------------------------------------------------------------------
/*/{Protheus.doc} G001MStatus
	Grava os campos que validam os status da CTEOS
	
@param cStatus    	status	

@author Fernando Amorim(Cafu)
@since		23/09/2017       
@version	P12
/*/
//------------------------------------------------------------------------------

Function G001MStatus(cCampo,cStatus)

Local lRet  		:= .T.

Local oModelGZH 	:= FWLOADModel('GTPT001')
Local oMdlGZH

oModelGZH:SetOperation(MODEL_OPERATION_UPDATE)
oModelGZH:Activate()

oMdlGZH	 	:= oModelGZH:GetModel( 'FIELDGZH' ) 

lRet := oMdlGZH:SetValue( cCampo	, cStatus	)
AtualiSF3(oMdlGZH,cStatus)

If ( lRet .And. oModelGZH:VldData() )
	oModelGZH:CommitData()
EndIf
If Valtype(oModelGZH) = "O"
	oModelGZH:DeActivate()
	oModelGZH:Destroy()
	oModelGZH:= nil
EndIf											

Return(lRet)

/*/{Protheus.doc} GTPTSTATUS
Atualiza o status da GZH de forma simplificada
@type  Function
@author user
@since 28/03/2022
@version version
@param cStatus, caracter, status atual do cteos
@return lRet
@example
(examples)
@see (links_or_references)
/*/
Function GTPTSTATUS(cStatus)

Local lRet := .F.
Local aArea		:= GetArea()
DEFAULT cStatus := ""

If !(Empty(cStatus))
	GZH->(RecLock(("GZH"),.F.))
	GZH->GZH_STATUS:= cStatus
	GZH->(MsUnlock())

	lRet := .T.
EndIf

RestArea(aArea)

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} G001GetRet()
	Pega e grava o retorno da transmissão
	
@param cXML   			xml enviado para sefaz
@param lAutorizado   	variavel logica que diz se foi autorizado ou não	
@param cRetorno   		msg de retorno		

@author Fernando Amorim(Cafu)
@since		23/09/2017       
@version	P12
/*/
//------------------------------------------------------------------------------

Function G001GetRet(cTp,cXML,lAutorizado,cRetorno,cChaveCte, cProtocolo, cSerie, cNota, cCliente, cLoja, cEvento, cStat)

Local lRet  		:= .T.

Local cTpMov		:= 'S'
Local cStatus		:= ''

Default cEvento := ''
Default cStat := ''

cStatus := GetStatus(cEvento)

If cEvento == 'A'
	GZH->(DbSetOrder(1))
	GZH->(DbSeek(xFilial('GZH')+PadR(cNota,TamSx3('F2_DOC')[1])+PadR(cSerie,TamSx3('F2_SERIE')[1])+cCliente+cLoja))
	cTpMov := 'E'
EndIf	

If cTp =='1'
	If lAutorizado

		GZH->(RecLock(("GZH"),.F.))
		GZH->GZH_XMLCTE := cXML		
		GZH->GZH_XMLAUT := cRetorno
		GZH->GZH_XMLERR := ' '
		GZH->GZH_STATUS := cStatus
		GZH->(MsUnlock())
		If ( lRet )
			
			If ( cEvento <> 'A' )
				GZH->(RecLock(("GZH"),.F.))
				GZH->GZH_CHVCTE := cChaveCte
				GZH->(MsUnlock())

			Else
				GZH->(RecLock(("GZH"),.F.))
				GZH->GZH_CHVANU := cChaveCte
				GZH->GZH_PROTCA := cProtocolo
				GZH->(MsUnlock())

			EndIf

		EndIf

	Else
		GZH->(RecLock(("GZH"),.F.))
		GZH->GZH_XMLCTE := cXML		
		GZH->GZH_XMLERR := cRetorno	
		GZH->GZH_STATUS := '4'		
		GZH->(MsUnlock())
	Endif
Else
	If lAutorizado
		GZH->(RecLock(("GZH"),.F.))
		GZH->GZH_XMLCTE := cXML		
		GZH->GZH_XMLAUT := cRetorno
		GZH->GZH_XMLERR := ' '		
		GZH->GZH_CHVCTE := cChaveCte
		GZH->GZH_STATUS := '3'		
		GZH->(MsUnlock())
	Endif

Endif

If lAutorizado

	SF3->(DbSetOrder(4))
	If SF3->( DbSeek(xFilial("SF3") + cCliente + padr(cLoja,tamSX3("F3_LOJA")[1] ) + PadR(cNota,TamSx3('F2_DOC')[1]) + PadR(cSerie,TamSx3('F2_SERIE')[1])) )
		reclock("SF3")
		SF3->F3_CHVNFE := cChaveCte
		SF3->F3_PROTOC := cProtocolo
		SF3->F3_CODRSEF := ALLTRIM(cStat)
		SF3->( msunLock() )
	EndIf
	SFT->(DbSetOrder(1))
	
	if(SFT->( DbSeek(xFilial("SFT")+cTpMov+PadR(cSerie,TamSx3('F2_SERIE')[1])+PadR(cNota,TamSx3('F2_DOC')[1])+cCliente + padr(cLoja,tamSX3("F3_LOJA")[1] ) ) ) )
		reclock("SFT")
		SFT->FT_CHVNFE := cChaveCte	
		SFT->(msUnLock())
	EndIf

	If SF2->(MsSeek(xFilial("SF2") + cNota + cSerie + cCliente + cLoja,.T.))
		RecLock("SF2",.F.)
		SF2->F2_CHVNFE := cChaveCte
        SF2->(MsUnlock())
	EndIf	

EndIf				


Return

/*/{Protheus.doc} GTPT001TRA   
    chama o wizard de transmissão
    @type  Static Function
    @author Fernando Amorim(Cafu)
    @since 22/09/2017
    @version version
   
    @example
    (examples)
    @see (links_or_references)
/*/
Function G001IMPRIME()

Local cStatus	:= GZH->GZH_STATUS

If cStatus $ 'A|B|C|3|5'
	GZHIMPRESSAO()
Else
	FwAlertHelp("STATUS","Apenas CTEOS transmitidas podem imprimir o DACTE-OS.")
Endif

Return()

/*/{Protheus.doc} G001ConsCTEOS   
    Consulta do estatus da CTEOS junto ao sefaz
    @type  Static Function
    @author Fernando Amorim(Cafu)
    @since 25/09/2017
    @version version
   
    @example
    (examples)
    @see (links_or_references)
/*/
Function G001ConsCTEOS(lAut)
Local aRetorno := {}

Default lAut   := .F.

aRetorno := GZHConsulta()

if !lAut
	viewCTeOS(aRetorno[1], aRetorno[2])	
EndIf

Return()


/*/{Protheus.doc} G001Cancel   
    Cancela  CTEOS junto ao sefaz
    @type  Static Function
    @author Fernando Amorim(Cafu)
    @since 02/10/2017
    @version version
   
    @example
    (examples)
    @see (links_or_references)
/*/
Function G001Cancel()


Local cStatus	:= GZH->GZH_STATUS
Local cProtoc	:= GZH->GZH_PROTCA

If cStatus $ '|6|9' .And. Empty(cProtoc)

	GZHCancelamento()	
	
Else
	FwAlertHelp("CANCELAMENTO","Apenas CTEOS com documento de saida excluido e que ainda não tenha sido enviado o cancelamento podem ser transmitido o cancelamento.") 		
Endif

Return()

/*/{Protheus.doc} G001CCe   
    Carta de correção de CTEOS
    @type  Static Function
    @author Fernando Amorim(Cafu)
    @since 02/10/2017
    @version version
   
    @example
    (examples)
    @see (links_or_references)
/*/
Function G001CCE()

Local cStatus	:= GZH->GZH_STATUS
Local cRet	:= ''

If cStatus $ '3-5'

	cRet := GZHCCe()	

Else
	FwAlertHelp("CCE","Apenas CTEOS Autorizado podem ser corrigidos.") 		
Endif

Return()

/*/{Protheus.doc} G001CCe   
    Carta de correção de CTEOS
    @type  Static Function
    @author Fernando Amorim(Cafu)
    @since 02/10/2017
    @version version
   
    @example
    (examples)
    @see (links_or_references)
/*/
Function G001EXPORTA()

Local aAreaGZH := GZH->(GetArea())
local cPath := ""
local lPos     := iif(!IsBlind(),FwAlertYesNo(STR0001,STR0002), .F.) //"Deseja exportar apenas o registro posicionado?"##"Atenção!!"
Local cAliasTmp	:= ''
Local cFiltro	:= ''
Local cMsgRet	:= ''

if !IsBlind()
	cPath := cGetFile ( "*.xml", STR0003, 1, "", .F., nOr(GETF_LOCALHARD,GETF_RETDIRECTORY), .F. , .T. ) //   "Arquivo XML"
EndIf

If lPos

	If( GZH->GZH_STATUS $ '3-5' )
		If !empty(GZH->GZH_XMLCTE)
			GZHExporta(cPath,lPos,@cMsgRet)
		Else
			FwAlertHelp("Arquivo XML","Informações do arquivo XML gerado não se encontra no campo.")
		EndIf
	Else
		FwAlertHelp("Status do registro",STR0004) 		//"Apenas CTEOS Autorizado podem ser Exportados."
	Endif

Else
	If PERGUNTE('GTPT001',.T.)

		If !Empty(MV_PAR01) .OR. !Empty(MV_PAR03)
			cFiltro += "AND GZH.GZH_CLIENT BETWEEN '"+MV_PAR01+"' AND '" + MV_PAR03 + "' "
		EndIf

		If !Empty(MV_PAR02) .OR. !Empty(MV_PAR04)
			cFiltro += "AND GZH.GZH_LOJA BETWEEN '"+MV_PAR02+"' AND '" + MV_PAR04 + "' "
		EndIf

		If !Empty(MV_PAR05) .OR. !Empty(MV_PAR06)
			cFiltro += "AND GZH.GZH_SERIE BETWEEN '"+MV_PAR05+"' AND '" + MV_PAR06 + "' "
		EndIf

		If !Empty(MV_PAR07) .OR. !Empty(MV_PAR08)
			cFiltro += "AND GZH.GZH_NOTA BETWEEN '"+MV_PAR07+"' AND '" + MV_PAR08 + "' "
		EndIf	

		cFiltro:="%"+cFiltro+"%"

		cAliasTmp	:= GetNextAlias()

		BeginSql Alias cAliasTmp
			SELECT 
				R_E_C_N_O_ RECNO
			FROM 
				%Table:GZH% GZH
			WHERE 
				GZH.%notdel%
				AND GZH.GZH_FILIAL = %xfilial:GZH%
				AND GZH.GZH_STATUS IN ('3','5','B')
				AND GZH.GZH_XMLCTE <> ' '
				%exp:cFiltro%
				ORDER BY GZH.GZH_CLIENT,GZH.GZH_LOJA,GZH.GZH_SERIE,GZH.GZH_NOTA,GZH.GZH_DSAIDA
		EndSql

		While !(cAliasTmp)->(EOF())
			
			GZH->(DbGoTo((cAliasTmp)->RECNO))
			
			GZHExporta(cPath,lPos,@cMsgRet)
			
			(cAliasTmp)->(DbSkip())
		EndDo
		(cAliasTmp)->(DBCloseArea())

		If !EMPTY(Alltrim(cMsgRet))
			Aviso("CTeOS - "+STR0005, cMsgRet, {'OK'}, 3)  //"Exportação de CTeOS"
		else
			FwAlertSuccess(STR0006,STR0005)   //'Exportação concluida.'
		EndIf

	EndIf

	
	
EndIf


RestArea(aAreaGZH)

Return()

//OSMAR
/*/{Protheus.doc} G001GerAnu
//TODO Descrição auto-gerada.
@author osmar.junior
@since 25/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function G001GerAnu()
	Local aArea     := GetArea()
	Local lRet  	:= .T.
	Local oModelGZH := FWLOADModel('GTPT001')
	Local oMdlGZH   := Nil
	Local cDocAux	:= ''
	Local cSerieAux	:= ''
	Local cAliasTmp := GetNextAlias()

	If BuscaNFE(@cDocAux, @cSerieAux)
	
		// verificando se registro já gerado para evitar errorlog de chave duplicada
		BeginSql alias cAliasTmp
			SELECT * FROM %table:GZH% GZH
			WHERE GZH_FILIAL = %xFilial:GZH% AND
				  GZH_NOTA   = %Exp:cDocAux% AND
				  GZH_SERIE  = %Exp:cSerieAux% AND
				  GZH_CLIENT = %Exp:GZH->GZH_CLIENT% AND
				  GZH_LOJA   = %Exp:GZH->GZH_LOJA% AND 
				  GZH.%notDel%
		EndSql 
		
		If (cAliasTmp)->(Eof())
			oModelGZH:SetOperation(MODEL_OPERATION_INSERT)
			oModelGZH:Activate()
		
			oMdlGZH	:= oModelGZH:GetModel( 'FIELDGZH' ) 
		
			lRet := oMdlGZH:LoadValue( "GZH_NOTA"	, cDocAux ) .And. ;
					oMdlGZH:LoadValue( "GZH_SERIE"	, cSerieAux) .And. ;
					oMdlGZH:LoadValue( "GZH_CLIENT"	, GZH->GZH_CLIENT) .And. ;
					oMdlGZH:LoadValue( "GZH_LOJA"	, GZH->GZH_LOJA) .And. ;
					oMdlGZH:LoadValue( "GZH_EVENTO"	, '01'	) .And. ;
					oMdlGZH:LoadValue( "GZH_UMUINI" , GZH->GZH_UMUINI  ) .And. ;
					oMdlGZH:LoadValue( "GZH_CMUINI" , GZH->GZH_CMUINI  ) .And. ;
					oMdlGZH:LoadValue( "GZH_DMUINI" , GZH->GZH_DMUINI  ) .And. ;
					oMdlGZH:LoadValue( "GZH_UMUFIM" , GZH->GZH_UMUFIM  ) .And. ;
					oMdlGZH:LoadValue( "GZH_CMUFIM" , GZH->GZH_CMUFIM  ) .And. ;
					oMdlGZH:LoadValue( "GZH_DMUFIM" , GZH->GZH_DMUFIM  ) .And. ;
					oMdlGZH:LoadValue( "GZH_VEIC"   , GZH->GZH_VEIC    ) .And. ;
					oMdlGZH:LoadValue( "GZH_PLACA"  , GZH->GZH_PLACA   ) .And. ;
					oMdlGZH:LoadValue( "GZH_RENAVA" , GZH->GZH_RENAVA  ) .And. ;
					oMdlGZH:LoadValue( "GZH_UFVEI"  , GZH->GZH_UFVEI   ) .And. ;
					oMdlGZH:LoadValue( "GZH_INFQ"   , GZH->GZH_INFQ    ) .And. ;
					oMdlGZH:LoadValue( "GZH_UFPER"	, GZH->GZH_UFPER   ) .And. ;						
					oMdlGZH:LoadValue( "GZH_PEDIDO" , GZH->GZH_PEDIDO  ) .And. ;
					oMdlGZH:LoadValue( "GZH_COMPVL"	, GZH->GZH_COMPVL  ) .And. ;
					oMdlGZH:LoadValue( "GZH_DSAIDA" , GZH->GZH_DSAIDA  ) .And. ;
					oMdlGZH:LoadValue( "GZH_HSAIDA" , GZH->GZH_HSAIDA  ) .And. ;
					oMdlGZH:LoadValue( "GZH_REGEST" , GZH->GZH_REGEST  ) .And. ;
					oMdlGZH:LoadValue( "GZH_MODAL"  , GZH->GZH_MODAL  ) .And. ;
					oMdlGZH:LoadValue( "GZH_TPFRET" , GZH->GZH_TPFRET  ) .And. ;
					oMdlGZH:LoadValue( "GZH_CODGQ2" , GZH->GZH_CODGQ2  ) .And. ;
					oMdlGZH:LoadValue( "GZH_STATUS"	, '1'	)	
			
			//Validação para adicionar os novos campos na inclusão do cteos 		
			If GZH->(FieldPos("GZH_PRODUT")) > 0 .AND. GZH->(FieldPos("GZH_QUANT")) > 0;
				.AND. GZH->(FieldPos("GZH_VLUNIT")) > 0 .AND. GZH->(FieldPos("GZH_TES")) > 0;
				.AND. GZH->(FieldPos("GZH_ORIGEM")) > 0
				
				lRet := oMdlGZH:LoadValue( "GZH_PRODUT"	, GZH->GZH_PRODUT	) .And. ;
					oMdlGZH:LoadValue( "GZH_QUANT" 	, GZH->GZH_QUANT	) .And. ;
					oMdlGZH:LoadValue( "GZH_VLUNIT"	, GZH->GZH_VLUNIT	) .And. ;					
					oMdlGZH:LoadValue( "GZH_TES"  	, GZH->GZH_TES	) .And. ;
					oMdlGZH:LoadValue( "GZH_ORIGEM"	, GZH->GZH_ORIGEM	)

				If ( lRet .And. oMdlGZH:HasField("GZH_TOTAL") )
					lRet := oMdlGZH:LoadValue( "GZH_TOTAL"	, GZH->(GZH_VLUNIT * GZH_QUANT)	)
				EndIf

			EndIf

			If !Empty(oMdlGZH:GetValue( "GZH_CODGQ2"))
				lRet := .F.
				FwAlertHelp("ANULACAO","Não é possível gerar anulação de uma nota do tipo Excesso de Bagagem.") 	
			Endif
			
			If ( lRet .And. oModelGZH:VldData() )
				lRet := oModelGZH:CommitData()
				If lRet
					FwAlertSuccess("ANULACAO",'Gerado CTE de anulação Série:'+cSerieAux+'  Número:'+cDocAux) 
				EndIf 
			EndIf
		else
			FwAlertWarning("ANULACAO",'CTE de anulação já gerado, Série:'+cSerieAux+'  Número:'+cDocAux) 
		EndIf
		(cAliasTmp)->(DbCloseArea())

	else
			FwAlertHelp("ANULACAO",'Documento de entrada não encontrado com NF de origem: '+GZH->GZH_NOTA+'  e Série:'+GZH->GZH_SERIE) 			
	EndIf

	If Valtype(oModelGZH) = "O"
		oModelGZH:DeActivate()
		oModelGZH:Destroy()
		oModelGZH:= nil
	EndIf
	
	RestArea(aArea)

Retur lRet


/*/{Protheus.doc} BuscaNFE
//TODO Descrição auto-gerada.
@author osmar.junior
@since 25/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function BuscaNFE(cDocAux,cSerieAux)
	Local lRet		:= .F.
	Local aAreaSD1 	:= SD1->(GetArea())
	Local cNota 	:= GZH->GZH_NOTA
	Local cSerie 	:= GZH->GZH_SERIE
	Local cCliFor 	:= GZH->GZH_CLIENT
	Local cLoja		:= GZH->GZH_LOJA
 
	SD1->(DbSetOrder(19))
	If SD1->(DbSeek(xFilial('SD1')+PadR(cNota,TamSx3('F2_DOC')[1])+PadR(cSerie,TamSx3('F2_SERIE')[1])+cCliFor+PadR(cLoja,TamSx3('F2_LOJA')[1])))
		lRet	:= .T.
		cDocAux	:= SD1->D1_DOC
		cSerieAux	:= SD1->D1_SERIE
	EndIf

RestArea(aAreaSD1)

Return lRet

Function G001Anula()

Local cStatus	:= GZH->GZH_STATUS
Local cProtoc	:= GZH->GZH_PROTCA
Local cEvento	:= 'A'

If cStatus $ '2' .And. Empty(cProtoc) .AND. GZH->GZH_EVENTO == '01'

	GZHRemessa(,,,cEvento)
	
Else
	FwAlertHelp("Anulação","Apenas CTEOS com documento de saida que tenha sido enviado podem ser transmitido a anulação.") 		
Endif

Return()


Static Function GetStatus(cEvento)
Local cStatus := ''

	If cEvento=='A'
		cStatus := 'A'
	ElseIf cEvento=='S'
		cStatus := 'B'
	ElseIf cEvento=='C'
		cStatus := 'C'
	Else
		cStatus := '3'
	EndIf
	
Return cStatus

// Chama a View da rotina GTPT001.PRW para validação do campo GZH_CODGQ2
Function VLDGQ2()

FWExecView("Excesso de Bagagem","VIEWDEF.GTPT001", MODEL_OPERATION_UPDATE,,{|| .T.})

Return 

// Validação do campos Hora saida
Static Function VLDHORA(oModel, lAut)
Local lRet    := .F.
Local cHsaida := ''
Local cHor    := ''
Local cMin    := ''
Local cSeg    := ''
Local cHorPad := "24"
Local cMinPad := "60"
Local cSegPad := "60"  

Default lAut  := .F.

cHsaida := iif(lAut, '22:00', oModel:GetValue("GZH_HSAIDA"))
cHor    := Left(cHsaida, 3)
cMin    := Left(Right(cHsaida, 5), 3)
cSeg    := Right(cHsaida, 2) 

iF (cHor > cHorPad) .or. (cMin > cMinPad) .or. (cSeg > cSegPad)
	lRet := .F.
Else
	lRet := .T.
EndIf

Return lRet 

// Validação do campo Veiculo
Static Function VLDVEIC(oModel, lAut)
Local lRet  := .F.
Local cVeic := '' 

Default lAut := .F.

cVeic := iif(lAut, 'GTP001', oModel:GetValue("GZH_VEIC"))

If ExistCpo("ST9", cVeic)
	lRet := .T.
Else
	lRet := .F.
EndIf

Return lRet

// Validação do campo Codigo GQ2
Static Function VLDCODGQ2(oModel, lAut)
Local lRet    := .F.
Local cCodGq2 := ''

Default lAut := .F.

cCodGq2 := iif(lAut, '000001', oModel:GetValue("GZH_CODGQ2"))

If ExistCpo("GQ2", cCodGq2)
	lRet := .T.
Else
	lRet := .F.
EndIf

Return lRet



Function GTP001EXC(cNumero,cSerie,cCliente,cLoja,cEspecie,cTipo,cPrefixo,dDtdigit)
Local lRet := .T.
Local nSpedExc 		:= GetNewPar("MV_SPEDEXC",24)
Local aAreaAux:= GetArea() 
Local cStrProtoc := ""
Local dDtEmissao := NIL
Local cHoraEmiss := ""
Local nHrsDif	:= 0

  
GZH->(DbSetOrder(1))
If GZH->( DbSeek(xFilial('GZH')+cNumero+cSerie+cCliente+cLoja) ) .AND. !EMPTY(GZH->GZH_XMLAUT)
	cStrProtoc := SUBSTR(GZH->GZH_XMLAUT,AT('Recebimento',GZH->GZH_XMLAUT)+13,25)
	dDtEmissao := CTOD(StrTokArr2(SUBSTR(cStrProtoc,1,10),'-')[3]+'-'+StrTokArr2(SUBSTR(cStrProtoc,1,10),'-')[2]+'-'+StrTokArr2(SUBSTR(cStrProtoc,1,10),'-')[1])
	cHoraEmiss := SUBSTR(cStrProtoc,12,8)
	nHrsDif := SubtHoras(dDtEmissao, cHoraEmiss, dDataBase, substr(Time(),1,2)+":"+substr(Time(),4,2) )

	If nHrsDif > nSpedExc
		lRet := .F.
		If !IsBlind()
			MsgAlert("Não foi possivel excluir a(s) nota(s), pois o prazo para o cancelamento da(s) CTe-OS é de " + Alltrim(STR(nSpedExc)) +" horas")
		EndIf
	EndIf	

Endif 

RestArea(aAreaAux)

Return lRet

Function GTP1ExcGZH(cNota,cSerie,cCliente,cLoja)

	Local aArea:= GetArea()  
	
	GZH->(DbSetOrder(1))
	If GZH->(DbSeek(xFilial('GZH')+PadR(cNota,TamSx3('F2_DOC')[1])+PadR(cSerie,TamSx3('F2_SERIE')[1])+cCliente+cLoja)) 
		// muda status  pra cancelado	
		GTPTSTATUS('6')
	Endif  
				
	RestArea(aArea) 

Return 

/*/{Protheus.doc} AtualiSF2   
    Atualiza SF2 com dados dos municipios
    @type  Static Function
    @author GTP
    @since 30/07/2020
    @version version
    @param oModel, objeto, instância da Classe FwFormModel
    @return lRet, lógico, .t. - Efetuou o Commit com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function AtualiSF2(oMdlGZH, lAut)
Local aArea := GetArea()
Local aAreaSf2 := SF2->(GetArea())

Default lAut   := .F.

	If !fwisincallstack("MA521MARKB") 
		dbSelectArea("SF2")
		dbSetOrder(1)  //F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE
		if !lAut
			If MsSeek(xFilial("SF2")+oMdlGZH:GetValue("GZH_NOTA")+oMdlGZH:GetValue("GZH_SERIE")+oMdlGZH:GetValue("GZH_CLIENT")+oMdlGZH:GetValue("GZH_LOJA"))
				If SF2->F2_CMUNOR <> ALLTRIM(oMdlGZH:GetValue("GZH_CMUINI")) .OR. SF2->F2_CMUNDE <> ALLTRIM(oMdlGZH:GetValue("GZH_CMUFIM"))
					RecLock("SF2")
						SF2->F2_UFORIG := oMdlGZH:GetValue("GZH_UMUINI")
						SF2->F2_CMUNOR := ALLTRIM(oMdlGZH:GetValue("GZH_CMUINI"))
						SF2->F2_UFDEST := oMdlGZH:GetValue("GZH_UMUFIM")
						SF2->F2_CMUNDE := ALLTRIM(oMdlGZH:GetValue("GZH_CMUFIM"))
					SF2->(MsUnlock())
				EndIf						
			EndIf

			If (oMdlGZH:GetValue("GZH_UMUINI") <> oMdlGZH:GetValue("GZH_UMUFIM")) .AND. oMdlGZH:GetValue("GZH_UMUFIM") != "EX"
				AtualizaCfop(oMdlGZH)
			EndIf
		EndIf
	EndIf
RestArea(aAreaSf2)
RestArea(aArea)
Return 

/*/{Protheus.doc} AtualizaCfop
(long_description)
@type  Static Function
@author user
@since 02/03/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function AtualizaCfop(oMdlGZH, lAut)
Local cCfo := ""
Local aDadosCfo := {}
Local aArea := GetArea()
Local aAreaSa1 := SA1->(GetArea())
Local aAreaSF3 := SF3->(GetArea())
Local aAreaSFT := SFT->(GetArea())

Default lAut   := .F.

DbSelectArea("SA1")
DbSetOrder(1)

If lAut .or. DbSeek(xFilial("SA1") + oMdlGZH:GetValue("GZH_CLIENT")+oMdlGZH:GetValue("GZH_LOJA"))
	AAdd( aDadosCfo, { "OPERNF", "S" } )
	AAdd( aDadosCfo, { "TPCLIFOR", SA1->A1_TIPO } )
	AAdd( aDadosCfo, { "UFDEST", iif(lAut, '01', oMdlGZH:GetValue("GZH_UMUFIM")) } )
	AAdd( aDadosCfo, { "INSCR", SA1->A1_INSCR } )

EndIf

DbSelectArea("SF3")
DbSetOrder(4)
If lAut .or. DbSeek(xFilial("SF3") + oMdlGZH:GetValue("GZH_CLIENT")+oMdlGZH:GetValue("GZH_LOJA")+oMdlGZH:GetValue("GZH_NOTA")+oMdlGZH:GetValue("GZH_SERIE"))
	cCfo := SF3->F3_CFO
	cCfo := MaFisCfo( NIL, cCfo, aDadosCfo )
	If !EMPTY(cCfo)
		RecLock("SF3",.F.)
			SF3->F3_CFO := ALLTRIM(cCfo)
		SF3->( MsUnlock() )
	EndIf
EndIf

If !EMPTY(cCfo)
	DbSelectArea("SFT")
	DbSetOrder(15)
	If lAut .or. DbSeek(xFilial("SFT")+oMdlGZH:GetValue("GZH_NOTA")+oMdlGZH:GetValue("GZH_SERIE") + oMdlGZH:GetValue("GZH_CLIENT")+oMdlGZH:GetValue("GZH_LOJA"))
		
		RecLock("SFT",.F.)
			SFT->FT_CFOP := ALLTRIM(cCfo)
		SFT->( MsUnlock() )
	EndIf
EndIf

aDadosCfo := {}

RestArea(aAreaSFT)
RestArea(aAreaSF3)
RestArea(aAreaSa1)
RestArea(aArea)
Return 

/*/{Protheus.doc} AtualiSF3   
    Atualiza SF3 com ret da sefaz
    @type  Static Function
    @author GTP
    @since 30/07/2020
    @version version
    @param oModel, objeto, instância da Classe FwFormModel
    @return lRet, lógico, .t. - Efetuou o Commit com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function AtualiSF3(oMdlGZH,cStatus, lAut)
Local cStatusF3 := GetTipoSt(cStatus)

Default lAut    := .F.

If cStatus $ '8|A|B|C'
	SF3->(DbSetOrder(4)) //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
	if !lAut
		If SF3->( DbSeek(xFilial("SF3")+oMdlGZH:GetValue("GZH_CLIENT")+oMdlGZH:GetValue("GZH_LOJA")+oMdlGZH:GetValue("GZH_NOTA")+oMdlGZH:GetValue("GZH_SERIE")))
			RecLock("SF3")
				SF3->F3_CODRSEF := ALLTRIM(cStatusF3)
			SF3->( MsUnlock() )
		EndIf
	EndIf
EndIf
	
Return 

/*/{Protheus.doc} GetTipoSt   
    Retorna de/para tss
    @type  Static Function
    @author GTP
    @since 30/07/2020
    @version version
    @param oModel, objeto, instância da Classe FwFormModel
    @return lRet, lógico, .t. - Efetuou o Commit com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GetTipoSt(cStatus)
Local cTipoStat := ''

Do Case
	Case cStatus == "3"
		cTipoStat := "100"
	Case cStatus == "8"
		cTipoStat := "101"
	Case cStatus == "A"
		cTipoStat := "100"
	Case cStatus == "B"
		cTipoStat := "100"
	Case cStatus == "C"
		cTipoStat := "100"		
END Case

Return cTipoStat


/*/{Protheus.doc} GetInfCTEO   
    Retorna de/para tss
    @type  Static Function
    @author GTP
    @since 31/07/2020
    @version version
    @param cFilialAux, caracter, codigo da filial
	@param cDocumento, caracter, codigo da documento
	@param cSerie, caracter, codigo da serie
	@param cCliente, caracter, codigo do cliente
	@param cLoja, caracter, codigo da loja
    @return aDados, array, contendo (UF-Inicio,Munic-Inicio,UF-Final,Munic-Final,Status,Evento)
    @example
    (examples)
    @see (links_or_references)
/*/
Function GetInfCTEO(cFilialAux,cDocumento,cSerie,cCliente,cLoja)
Local aDados := {}
Local cAliasTmp	:= GetNextAlias()

	If TCCanOpen(RetSqlName('GZH')) .And. ChkFile('GZH')

		BeginSql Alias cAliasTmp
			SELECT 
				GZH_UMUINI,GZH_CMUINI,GZH_UMUFIM,GZH_CMUFIM,GZH_STATUS,GZH_EVENTO
			FROM 
				%Table:GZH% GZH
			WHERE 
				GZH.%notdel%
				AND GZH.GZH_FILIAL = %exp:cFilialAux%
				AND GZH.GZH_NOTA =  %exp:cDocumento%
				AND GZH.GZH_SERIE =  %exp:cSerie%
				AND GZH.GZH_CLIENT =  %exp:cCliente%
				AND GZH.GZH_LOJA =  %exp:cLoja%
				ORDER BY GZH.GZH_FILIAL,GZH.GZH_NOTA,GZH.GZH_SERIE,GZH_CLIENT,GZH.GZH_LOJA
		EndSql
		
		While !(cAliasTmp)->(EOF())
			
			AAdd( aDados, { (cAliasTmp)->GZH_UMUINI, ALLTRIM((cAliasTmp)->GZH_CMUINI),(cAliasTmp)->GZH_UMUFIM,ALLTRIM((cAliasTmp)->GZH_CMUFIM),GetTPSta( (cAliasTmp)->GZH_STATUS ), GetTPEve( (cAliasTmp)->GZH_EVENTO )} )
			
			(cAliasTmp)->(DbSkip())
		EndDo
		
		(cAliasTmp)->(DBCloseArea())

	Endif
	
Return aDados

/*/{Protheus.doc} GetTPSta   
    Retorna de/para tss
    @type  Static Function
    @author GTP
    @since 31/07/2020
    @version version
    @param cStatus, caracter, codigo do status
    @return cStatConve, caracter, contendo (De/Para do Status)
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GetTPSta(cStatus)
Local cStatConve := ''

Do Case
	Case cStatus =='3' 		//"100"-Documento regular (Normal/Anulada/Substituida/Complemento)
		cStatConve := "00"
	Case cStatus =='5' 		//"100"-Documento regular (Normal/Anulada/Substituida/Complemento)
		cStatConve := "00"	
	Case cStatus == '8'		//"101"-Cancelada
		cStatConve := "02"
	Case cStatus == 'A'		//"100"-Anulada
		cStatConve := "00"
	Case cStatus == 'B'		//"100"-Substituta
		cStatConve := "00"
	Case cStatus == 'C'		//"100"-Complementar(Valor/ICM)
		cStatConve := "06"
	//Itens não implementados na rotina		
	//Case cStatus == ''		//"102"-Numeração inutilizada
	//	cStatConve := "05"
	//Case cStatus == ''		//"110"-Denegado
	//	cStatConve := "04"
		
END Case

Return cStatConve

/*/{Protheus.doc} GetTPEve   
    Retorna de/para tss
    @type  Static Function
    @author GTP
    @since 31/07/2020
    @version version
    @param cEvento, caracter, codigo da evento
    @return cEvenConve, caracter, contendo (de/para do evento)
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GetTPEve(cEvento)
Local cEvenConve := ''

Do Case
	Case cEvento =='01' 		//"100"-Documento regular (Anulada)
		cEvenConve := "ANULADA"
	Case cEvento =='02' 		//"100"-Documento regular (Substituta)
		cEvenConve := "SUBSTITUTA"	
	Case cEvento == '03'		//"100"-Documento regular (Complementar)
		cEvenConve := "COMPLEMENTAR"	
END Case
                                                                                       
Return cEvenConve

/*/{Protheus.doc} Gtp01tInut   
    Valida e realizada a chamada para inutilização do CTe-OS
    @type  Static Function
    @author flavio.martins
    @since 05/08/2022
    @version version
    @param Nil
    @return Nil
    @example
    (examples)
    @see (links_or_references)
/*/
Function Gtp01tInut()
Local lRet		:= .T.
Local aAutoExec := {}
Local cSerie	:= ''
Local cNota		:= '' 
Local cModelo	:= 'CT-e OS'
Local cRotina	:= 'GTPT001'
Local aArea		:= GetArea()

If Pergunte('GTPT001A',.T.)

	If Empty(MV_PAR01) .Or. Empty(MV_PAR02)
		FwAlertWarning(STR0007, STR0002) //'Preencha todos os parâmetros antes de prosseguir com a inutilização', 'Atenção'
		Return
	Endif

	cSerie 	:= MV_PAR01
	cNota	:= MV_PAR02
	
	If A460Especie(cSerie) != 'CTEOS'
		FwAlertWarning(STR0008, STR0002) //'A série informada deve estar vinculada a espécie CTEOS', 'Atenção'
		Return
	Endif

	dbSelectArea('GZH')
	GZH->(dbSetOrder(1))

	If GZH->(dbSeek(xFilial('GZH')+cNota+cSerie))

		If GZH->GZH_STATUS == '8'
			FwAlertWarning(STR0009, STR0002) //'O documento já foi inutilizado', 'Atenção'
			Return
		Endif

		If GZH->GZH_STATUS != '6'
			FwAlertWarning(STR0010, STR0002) // 'Antes de inutilizar o CTe-OS é necessário excluir o documento da saída', 'Atenção'
			Return
		Endif

		dbSelectArea('SF3')
		SF3->(dbSetOrder(6))

		If SF3->(dbSeek(xFilial("SF3")+cNota+cSerie))
			FwAlertWarning(STR0011, STR0002) //'Antes de inutilizar o CTe-OS é necessário excluir as informações de livros fiscais do documento da saída', 'Atenção'
			Return
		Endif
	
	Else
		lRet := FwAlertYesNo(STR0012, STR0002) //'O documento não foi encontrado no cadastro de CTe-OS. Deseja inutilizar o número mesmo assim ?'
	Endif

	If lRet .And. FwAlertYesNo(STR0014 + CRLF + STR0015, STR0002) //'Após este processo o número da nota será registrado no SEFAZ e não poderá mais ser utilizado.' + CRLF +
																 //'Confirma a inutilização da numeração ?', 'Atenção')
		aAutoExec := {cSerie, cNota, cNota, cModelo, cRotina, .F.}
		FwMsgRun(, {|| SpedNfeInut(,,,, aAutoExec)}, , STR0013) //'Aguarde, processando a inutilização...'
	Endif

Endif

RestArea(aArea)

Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Esta função é responsável por validações do formulário.
Uma das validações está relacionada com o tamanho do campo de observações
(GZH_OBSNF)
@param	oModel, objeto, Instância da classe FwFormModel()
@return	lRet, lógico, .T. Retorno válido; .F. Retorno inválido
@author  Fernando Radu Muscalu
@since   06/09/2022
/*/
//-----------------------------------------------------------------------------
Static Function ValidForm(oModel)

	Local lRet			:= .t.
	
	Local cMsgErro 		:= ""
	Local cMsgSolu 		:= ""

	Local nCaracteres	:= 0

	If ( oModel:GetOperation() == MODEL_OPERATION_UPDATE )

		If ( !Empty(oModel:GetModel("FIELDGZH"):GetValue("GZH_OBSNF")) )

			nCaracteres := Len(oModel:GetModel("FIELDGZH"):GetValue("GZH_OBSNF"))

			If ( nCaracteres > 1832 )
				
				lRet := .f.
				
				cMsgErro := "O campo de observação possui muitos caracteres 
				cMsgErro += "(total de " + cValToChar(nCaracteres) + ")."
				cMsgSolu := "O tamanho máximo de caracteres é 1.832 "
				cMsgSolu += "(um mil oitocentos e trinta e dois). "
				cMsgSolu += "Isto se dá para que o texto de observação não fique cortado "
				cMsgSolu += "na caixa de observações do DACTEOS"

				oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","ValidForm",cMsgErro,cMsgSolu)
				
			EndIf	

		EndIf

	EndIf

Return(lRet)
