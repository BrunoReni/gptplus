#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA216.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA216

Cadastro MVC dos Graus de Instrucao do eSocial

@author Felipe C. Seolin
@since 09/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA216()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription(STR0001) //"Cadastro dos Graus de Instru��o"
oBrw:SetAlias("CMH")
oBrw:SetMenuDef("TAFA216")
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Felipe C. Seolin
@since 09/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return(xFunMnuTAF("TAFA216"))

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Felipe C. Seolin
@since 09/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCMH := FwFormStruct(1,"CMH")
Local oModel   := MpFormModel():New("TAFA216")

oModel:AddFields("MODEL_CMH",/*cOwner*/,oStruCMH)
oModel:GetModel("MODEL_CMH"):SetPrimaryKey({"CMH_FILIAL","CMH_ID"})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Felipe C. Seolin
@since 09/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel("TAFA216")
Local oStruCMH := FwFormStruct(2,"CMH")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_CMH",oStruCMH,"MODEL_CMH")

oView:EnableTitleView("VIEW_CMH",STR0001) //"Cadastro do Grau de Instru��o"
oView:CreateHorizontalBox("FIELDSCMH",100)
oView:SetOwnerView("VIEW_CMH","FIELDSCMH")

Return(oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1005

If nVerEmp < nVerAtu
	aAdd( aHeader, "CMH_FILIAL" )
	aAdd( aHeader, "CMH_ID" )
	aAdd( aHeader, "CMH_CODIGO" )
	aAdd( aHeader, "CMH_DESCRI" )
	aAdd( aHeader, "CMH_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "ANALFABETO", "20150625" } )
	aAdd( aBody, { "", "000002", "02", "ATE A 4� SERIE INCOMPLETA DO ENSINO FUNDAMENTAL (ANTIGO 1� GRAU OU PRIMARIO), OU QUE TENHA SE ALFABETIZADO SEM TER FREQUENTADO ESCOLA REGULAR.", "20150625" } )
	aAdd( aBody, { "", "000003", "03", "4� SERIA COMPLETA DO ENSINO FUNDAMENTAL (ANTIGO 1� GRAU OU PRIMARIO)", "20150625" } )
	aAdd( aBody, { "", "000004", "04", "DA 5� A 8� SERIE DO ENSINO FUNDAMENTAL (ANTIGO 1� GRAU OU GINASIO)", "20150625" } )
	aAdd( aBody, { "", "000005", "05", "ENSINO FUNDAMENTAL COMPLETO (ANTIGO 1� GRAU, PRIMARIO OU GINASIO)", "20150625" } )
	aAdd( aBody, { "", "000006", "06", "ENSINO MEDIO INCOMPLETO (ANTIGO 2� GRAU, SECUNDARIO OU COLEGIAL)", "20150625" } )
	aAdd( aBody, { "", "000007", "07", "ENSINO MEDIO COMPLETO (ANTIGO 2� GRAU, SECUNDARIO OU COLEGIAL)", "20150625" } )
	aAdd( aBody, { "", "000008", "08", "EDUCACAO SUPERIOR INCOMPLETA", "20150625" } )
	aAdd( aBody, { "", "000009", "09", "EDUCACAO SUPERIOR COMPLETA", "20150625" } )
	aAdd( aBody, { "", "000010", "10", "POS GRADUACAO", "20150625" } )
	aAdd( aBody, { "", "000011", "11", "MESTRADO", "20150625" } )
	aAdd( aBody, { "", "000012", "12", "DOUTORADO", "20150625" } )
	aAdd( aBody, { "", "000013", "01", "ANALFABETO, INCLUSIVE O QUE, EMBORA TENHA RECEBIDO INSTRUCAO, NAO SE ALFABETIZOU", "" } )
	aAdd( aBody, { "", "000014", "02", "ATE O 5� ANO INCOMPLETO DO ENSINO FUNDAMENTAL (ANTIGA 4� SERIE) OU QUE SE TENHA ALFABETIZADO SEM TER FREQUENTADO ESCOLA REGULAR", "" } )
	aAdd( aBody, { "", "000015", "03", "5� ANO COMPLETO DO ENSINO FUNDAMENTAL", "" } )
	aAdd( aBody, { "", "000016", "04", "DO 6� AO 9� ANO DO ENSINO FUNDAMENTAL INCOMPLETO (ANTIGA 5� A 8� SERIE)", "" } )
	aAdd( aBody, { "", "000017", "05", "ENSINO FUNDAMENTAL COMPLETO", "" } )
	aAdd( aBody, { "", "000018", "06", "ENSINO MEDIO INCOMPLETO", "" } )
	aAdd( aBody, { "", "000019", "07", "ENSINO MEDIO COMPLETO", "" } )
	aAdd( aBody, { "", "000020", "08", "EDUCACAO SUPERIOR INCOMPLETA", "" } )
	aAdd( aBody, { "", "000021", "09", "EDUCACAO SUPERIOR COMPLETA", "" } )
	aAdd( aBody, { "", "000022", "10", "POS-GRADUACAO COMPLETA", "" } )
	aAdd( aBody, { "", "000023", "11", "MESTRADO COMPLETO", "" } )
	aAdd( aBody, { "", "000024", "12", "DOUTORADO COMPLETO", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )