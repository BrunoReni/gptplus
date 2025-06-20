#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA488.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA488
Cadastro MVC de Tipos de Arquivo da Reinf 

@author Henrique Pereira
@since 19/01/2018
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA488()
Local oBrw	as object

If TAFAlsInDic( "T9B" )
	oBrw := FWmBrowse():New() 
	oBrw:SetDescription( STR0001 ) //Cadastro de Tipos de Arquivo da Reinf 	
	oBrw:SetAlias( 'T9B')
	oBrw:SetMenuDef( 'TAFA488' )
	oBrw:Activate()
Else
	MsgInfo( STR0003 , STR0002 ) // "N�o � poss�vel proceder com a execu��o da Rotina, necess�rio atualiza��o de dicion�rio referente ao layout do 1.3 do Reinf" / Tabela T9B n�o existe!
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Henrique Pereira
@since 19/01/2018
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA488" )                                                                          

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Henrique Pereira
@since 19/01/2018
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	
Local oStruT9B as object
Local oModel   as object

oStruT9B := FWFormStruct( 1, 'T9B' )// Cria a estrutura a ser usada no Modelo de Dados
oModel   := MPFormModel():New('TAFA488' )

// Adiciona ao modelo um componente de formul�rio
oModel:AddFields( 'MODEL_T9B', /*cOwner*/, oStruT9B)
oModel:GetModel( 'MODEL_T9B' ):SetPrimaryKey( { 'T9B_FILIAL' , 'T9B_ID' } )

Return oModel             


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Henrique Pereira
@since 19/01/2018
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel		as object
Local oStruT9B		as object
Local oView			as object

oModel		:= FWLoadModel( 'TAFA488' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
oStruT9B	:= FWFormStruct( 2, 'T9B' )// Cria a estrutura a ser usada na View
oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_T9B', oStruT9B, 'MODEL_T9B' )

oView:EnableTitleView( 'VIEW_T9B',  STR0001 ) //Cadastro de Tipos de Arquivo da Reinf 	

oView:CreateHorizontalBox( 'FIELDST9B', 100 )

oView:SetOwnerView( 'VIEW_T9B', 'FIELDST9B' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

@Author	Henrique Pereira
@Since		19/01/2018
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp as numeric, nVerAtu as numeric )

Local aHeader			as array
Local aBody				as array
Local aRet				as array

aHeader			:=	{}
aBody			:=	{}
aRet			:=	{}

nVerAtu := 1032.12

If (nVerEmp < nVerAtu) .AND. TAFAlsInDic( "T9B" ) //TafAtualizado()
	aAdd( aHeader, "T9B_FILIAL" )
	aAdd( aHeader, "T9B_ID" )
	aAdd( aHeader, "T9B_CODIGO" )
	aAdd( aHeader, "T9B_DESCRI" )
	aAdd( aHeader, "T9B_VALIDA" )

	aAdd( aBody, { "", "75651686-1fea-ed98-d956-e18df9f8ee62", "R-1000", "INFORMA��ES DO CONTRIBUINTE", "" } )
	aAdd( aBody, { "", "4ee26989-d3e2-c2ad-f58e-85f8d4b699ec", "R-1050", "TABELA DE ENTIDADES LIGADAS", "" } )
	aAdd( aBody, { "", "78072418-024a-431e-a2fa-e96a8d6fb605", "R-1070", "TABELA DE PROCESSOS ADMINISTRATIVOS/JUDICIAIS", "" } )
	aAdd( aBody, { "", "1f300ff7-f429-9ec0-e2d3-e49b22b03bd1", "R-2010", "RETEN��O CONTRIBUI��O PREVIDENCI�RIA - SERVI�OS TOMADOS", "" } )
	aAdd( aBody, { "", "8b87a50d-c51a-81b0-2e57-a2f7dee63d49", "R-2020", "RETEN��O CONTRIBUI��O PREVIDENCI�RIA - SERVI�OS PRESTADOS", "" } )
	aAdd( aBody, { "", "e972a02e-2762-655c-f69a-009680412edd", "R-2030", "RECURSOS RECEBIDOS POR ASSOCIA��O DESPORTIVA", "" } )
	aAdd( aBody, { "", "66646f64-2bca-4b68-5584-4d6377959bcf", "R-2040", "RECURSOS REPASSADOS PARA ASSOCIA��O DESPORTIVA", "" } )
	aAdd( aBody, { "", "b54f134a-2a3f-e383-9ecc-f2d8fedf97de", "R-2050", "COMERCIALIZA��O DE PRODU��O", "" } )
	aAdd( aBody, { "", "b871fcc1-0154-cb28-955f-d39f281ce398", "R-2055", "AQUISI��O DE PRODU��O RURAL", "" } )
	aAdd( aBody, { "", "d3f7e028-47e0-a37a-7402-565b52687367", "R-2060", "CONTRIBUI��O PREVIDENCI�RIA SOBRE A RECEITA BRUTA - CPRB", "" } )
	aAdd( aBody, { "", "8013fef7-4216-330d-2985-6518618d9cb3", "R-2070", "RETEN��ES NA FONTE - IR, CSLL, COFINS, PIS/PASEP", "" } )
	aAdd( aBody, { "", "ba59be28-0869-6a4c-1799-4c528f551886", "R-2098", "REABERTURA DOS EVENTOS DA S�RIE R-2000", "" } )
	aAdd( aBody, { "", "63b3604b-b02a-3610-2afb-08ac76e9a871", "R-2099", "FECHAMENTO DOS EVENTOS DA S�RIE R-2000", "" } )
	aAdd( aBody, { "", "a33daec4-9893-14d2-2eba-cae645765c87", "R-3010", "RECEITA DE ESPET�CULO DESPORTIVO", "" } )
	aAdd( aBody, { "", "4660e0d4-41ba-e27c-033b-c22a144b41ec", "R-4010", "PAGAMENTOS/CR�DITOS A BENEFICI�RIO PESSOA F�SICA", "" } )
	aAdd( aBody, { "", "7b6b065f-f49f-9ba5-a847-df623cb35188", "R-4020", "PAGAMENTOS/CR�DITOS A BENEFICI�RIO PESSOA JUR�DICA", "" } )
	aAdd( aBody, { "", "a734e965-54ef-6508-e22f-6cfacbcd0ec1", "R-4040", "PAGAMENTOS/CR�DITOS A BENEFICI�RIOS N�O IDENTIFICADOS", "" } )
	aAdd( aBody, { "", "0c3f1fff-31a5-e649-fb22-538e701f1e8d", "R-4080", "RETEN��O NO RECEBIMENTO", "" } )
	aAdd( aBody, { "", "864f2df4-1fda-4e2f-5108-6c00bc83f7bf", "R-4099", "FECHAMENTO/REABERTURA DOS EVENTOS DA S�RIE R-4000", "" } )
	aAdd( aBody, { "", "1bbd2102-d557-dc5b-b79f-19f761413c7f", "R-5001", "INFORMA��ES DE BASES E TRIBUTOS POR EVENTO", "" } )
	aAdd( aBody, { "", "47235594-823f-e6e9-60c3-24285e28cd48", "R-5011", "INFORMA��ES DE BASES E TRIBUTOS CONSOLIDADAS POR PER�ODO DE APURA��O", "" } )
	aAdd( aBody, { "", "30e1df5a-ca6a-6b50-5ccc-4acfed513b49", "R-9000", "EXCLUS�O DE EVENTOS", "" } )
	aAdd( aBody, { "", "f0bd3345-39a0-34e4-0ee0-c106af51028d", "R-9001", "BASES E TRIBUTOS - CONTRIBUI��O PREVIDENCI�RIA", "" } )
	aAdd( aBody, { "", "eecfc490-627f-43ff-f79e-4a224c3ca73e", "R-9005", "BASES E TRIBUTOS - RETEN��ES NA FONTE ", "" } )
	aAdd( aBody, { "", "b170b34b-6b13-5afd-5ffb-88ed974957e6", "R-9011", "CONSOLIDA��O DE BASES E TRIBUTOS - CONTRIB. PREVIDENCI�RIA", "" } )
	aAdd( aBody, { "", "68fb9433-af42-494d-ff05-7853f121a535", "R-9015", "CONSOLIDA��O DAS RETEN��ES NA FONTE", "" } )
		
	aAdd( aRet, { aHeader, aBody } )

EndIf

Return( aRet )
