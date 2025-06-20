#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA540.CH" 

/*/{Protheus.doc} TAFA540
MVC DA TABELA AUTOCONTIDA "V4E-Tipo de isen��o" 

@author Katielly Feitosa Rezende
@since 15/07/2019
@version 1.0
/*/

Function TAFA540()
Local	oBrw		:=	FWmBrowse():New()

If AliasIndic("V4E")
    oBrw:SetDescription(STR0001) //"Cadastros dos Tipos de Isen��es" 
    oBrw:SetAlias( 'V4E')
    oBrw:SetMenuDef( 'TAFA540' )
    V4E->(DbSetOrder(1))
    oBrw:Activate()
Else
	Alert(STR0002) //"Tabela V4E n�o existe"
EndIF

Return

/*/{Protheus.doc} MenuDef
Funcao generica MVC para o menu

@author Katielly Feitosa Rezende
@since 15/07/2019
@version 1.0
/*/

Static Function MenuDef()
Return XFUNMnuTAF( "TAFA540" )

/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Katielly Feitosa Rezende
@since 15/07/2019
@version 1.0
/*/    

Static Function ModelDef()
Local oStrucV4E := FWFormStruct(1, 'V4E')
Local oModel    := MPFormModel():New('TAFA540')

oModel:AddFields('MODEL_V4E', /*cOwner*/, oStrucV4E)
oModel:GetModel('MODEL_V4E'):SetPrimaryKey({'V4E_FILIAL','V4E_ID'})
Return oModel

/*/{Protheus.doc} ViewDef
Funcao generica MVC do View
@return oView - Objeto da View MVC
@author Katielly Feitosa Rezende
@since 15/07/2019
@version 1.0
/*/

Static Function ViewDef()
Local oModel   := FWLoadModel('TAFA540')
Local oStruV4E := FWFormStruct( 2, 'V4E' )
Local oView    := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_V4E', oStruV4E, 'MODEL_V4E' )

oView:EnableTitleView( 'VIEW_V4E', STR0003 )//"Tipo de Isen��o" 
oView:CreateHorizontalBox( 'FIELDSV4E', 100 )
oView:SetOwnerView( 'VIEW_V4E', 'FIELDSV4E' )

Return oView	

/*/{Protheus.doc} FAtuCont
Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )
@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

@Autor Katielly Feitosa Rezende
@Since		15/07/2019
@Version	1.0
/*/

Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1032.12

If AliasIndic("V4E")
	If nVerEmp < nVerAtu 
        aAdd( aHeader, "V4E_FILIAL" )
        aAdd( aHeader, "V4E_ID")  
        aAdd( aHeader, "V4E_CODIGO")
        aAdd( aHeader, "V4E_DESCRI")
        
        aAdd( aBody, {"", "000001", "1",  "Parcela Isenta 65 anos;" })
        aAdd( aBody, {"", "000002", "2",  "Di�rio de viagem;" })
        aAdd( aBody, {"", "000003", "3",  "Indeniza��o e rescis�o de contrato, inclusive a t�tulo de PDV e acidentes de trabalho;" })
        aAdd( aBody, {"", "000004", "4",  "Abono pecuni�rio;" })
        aAdd( aBody, {"", "000005", "5",  "Valores pagos a titular ou s�cio de microempresa ou empresa de pequeno porte, exceto pr�-labore e alugueis;" })
        aAdd( aBody, {"", "000006", "6",  "Pens�o, aposentadoria ou reforma por mol�stia grave ou acidente em servi�o;" })
        aAdd( aBody, {"", "000007", "7",  "Complementa��o de aposentadoria, correspondente �s contribui��es efetuadas no per�odo de 01/01/1989 a 31/12/1995;" })
        aAdd( aBody, {"", "000008", "8",  "Ajuda de custo;" })
        aAdd( aBody, {"", "000009", "9",  "Rendimentos pagos sem reten��o do IR na fonte - Lei 10.833/2003;" })
        aAdd( aBody, {"", "000099", "99", "Outros (especificar)." })

       aAdd( aRet, { aHeader, aBody } )
    EndIf  
EndIf  

Return( aRet )
