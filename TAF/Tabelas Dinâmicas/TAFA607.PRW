#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA607.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA607
Codigos de Receita de Reclamat�ria Trabalhista - Tabela 29        

@author Daniel Marques Aguilar
@since 27/09/2022
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFA607()

    Local oBrw := FwMBrowse():New()

    If AliasIndic("V9T")
        oBrw:SetDescription(STR0001) //"Codigos de Receita de Reclamat�ria Trabalhista"
        oBrw:SetAlias("V9T")
        oBrw:SetMenuDef("TAFA607")
        oBrw:Activate()
    Else
        MsgAlert(STR0002)   //"Tabela V9T n�o existe." 
    EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC para o Menu

@author Daniel Marques Aguilar
@since 27/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF("TAFA607")

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados do Cadastro de Prazos de Envio de Eventos do eSocial

@author Daniel Marques Aguilar
@since 27/09/2022
@version 1.0
@return oModel - Objeto do Modelo MVC
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruV9T := FwFormStruct( 1, "V9T" )
Local oModel   := MpFormModel():New( "TAFA607" )

oModel:AddFields( "MODEL_V9T", /*cOwner*/, oStruV9T )
oModel:GetModel( "MODEL_V9T" ):SetPrimaryKey( { "V9T_FILIAL", "V9T_ID" } )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@Return oView - Objeto da View MVC

@Author Daniel Marques Aguilar
@Since 27/09/2022
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel( "TAFA607" )
Local oStruV9T := FwFormStruct( 2, "V9T" )
Local oView    := FwFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_V9T", oStruV9T, "MODEL_V9T" )
oView:EnableTitleView( "VIEW_V9T", STR0001 ) //Cadastro de C�digo de Conta Referencial
oView:CreateHorizontalBox( "FIELDSV9T", 100 )
oView:SetOwnerView( "VIEW_V9T", "FIELDSV9T" )

oStruV9T:RemoveField( "V9T_ID" )


Return( oView ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

@Daniel Marques Aguilar
@Since		27/09/2022
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp as numeric, nVerAtu as numeric ) 

	Local aHeader as array
	Local aBody	  as array
	Local aRet	  as array

	aHeader 	:=	{}
	aBody	    :=	{}
	aRet	 	:=	{}

	nVerAtu := 1033.22

	If nVerEmp < nVerAtu
		aAdd( aHeader, "V9T_FILIAL" )
		aAdd( aHeader, "V9T_ID" )
		aAdd( aHeader, "V9T_CODIGO")
		aAdd( aHeader, "V9T_DESCRI")
		aAdd( aHeader, "V9T_ALIQUO")
		aAdd( aHeader, "V9T_VALIDA" )
		aAdd( aHeader, "V9T_ALTCON" )

		aAdd( aBody, { " ","000001","113851","CP PATRONAL A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"                                           ,"20"                     , " " } )
		aAdd( aBody, { " ","000002","164651","CP GILRAT A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"                                             ,"Vari�vel (RATX FAP)"    , " " } )
		aAdd( aBody, { " ","000003","114151","CP PARA FINANCIAMENTO DE APOSENTADORIA ESPECIAL A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"       ,"6, 9 ou 12"             , " " } )
		aAdd( aBody, { " ","000004","113852","CP ADICIONAL A CARGO DAS INSTITUI�OES FINANCEIRAS SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"                        ,"2,5"                    , " " } )
		aAdd( aBody, { " ","000005","113854","CP PATRONAL A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO CONTRIBUINTE INDIVIDUAL"                                                   ,"20"                     , " " } )
		aAdd( aBody, { " ","000006","114155","CP PARA FINANCIAMENTO DE APOSENTADORIA ESPECIAL A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO CONTRIBUINTE INDIVIDUAL"               ,"6, 9 ou 12"             , " " } )
		aAdd( aBody, { " ","000007","113855","CP ADICIONAL A CARGO DAS INSTITUI�OES FINANCEIRAS SOBRE A REMUNERA��O DO SEGURADO CONTRIBUINTE INDIVIDUAL"                                ,"2,5"                    , " " } )
		aAdd( aBody, { " ","000008","113858","CP PATRONAL A CARGO DO EMPREGADOR DOM�STICO SOBRE A REMUNERA��O DO SEGURADO EMPREGADO DOM�STICO"                                          ,"8"                      , " " } )
		aAdd( aBody, { " ","000009","164659","CP GILRAT A CARGO DO EMPREGADOR DOM�STICO SOBRE A REMUNERA��O DO SEGURADO EMPREGADO DOM�STICO"                                            ,"0,8"                    , " " } )
		aAdd( aBody, { " ","000010","113857","CP PATRONAL A CARGO DO MICROEMPREENDEDOR - MEI SOBRE A REMUNERA��O DO SEGURADO EMPREGADO"                                                 ,"3"                      , " " } )
		aAdd( aBody, { " ","000011","113853","CP PATRONAL A CARGO DA EMPRESA SIMPLES COM ATIVIDADE CONCOMITANTE SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"        ,"20"                     , " " } )
		aAdd( aBody, { " ","000012","164652","CP GILRAT A CARGO DA EMPRESA SIMPLES COM ATIVIDADE CONCOMITANTE SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"          ,"Vari�vel (RATX FAP)"    , " " } )
		aAdd( aBody, { " ","000013","114152","CP ADICIONAL GILRAT A CARGO DA EMPRESA SIMPLES COM ATIVIDADE CONCOMITANTE SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO","6, 9 ou 12"             , " " } )
		aAdd( aBody, { " ","000014","113856","CP PATRONAL A CARGO DA EMPRESA SIMPLES COM ATIVIDADE CONCOMITANTE SOBRE A REMUNERA��O DO SEGURADO CONTRIBUINTE INDIVIDUAL"                ,"20"                     , " " } )
		aAdd( aBody, { " ","000015","117051","SAL�RIO-EDUCA��O A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"                                      ,"2,5"                    , " " } )
		aAdd( aBody, { " ","000016","117651","INCRA A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"                                                 ,"0,2"                    , " " } )
		aAdd( aBody, { " ","000017","117652","INCRA (FPAS 531/795/825) A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"                              ,"2,7"                    , " " } )
		aAdd( aBody, { " ","000018","118151","SENAI A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"                                                 ,"1"                      , " " } )
		aAdd( aBody, { " ","000019","118451","SESI A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"                                                  ,"1,5"                    , " " } )
		aAdd( aBody, { " ","000020","119151","SENAC A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"                                                 ,"1"                      , " " } )
		aAdd( aBody, { " ","000021","119651","SESC A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"                                                  ,"1,5"                    , " " } )
		aAdd( aBody, { " ","000022","120051","SEBRAE A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"                                                ,"0,6"                    , " " } )
		aAdd( aBody, { " ","000023","120052","SEBRAE (FPAS 566/574/647) A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"                             ,"0,3"                    , " " } )
		aAdd( aBody, { " ","000024","120551","FDEPM A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"                                                 ,"2,5"                    , " " } )
		aAdd( aBody, { " ","000025","120951","FUNDO AEROVI�RIO A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"                                      ,"2,5"                    , " " } )
		aAdd( aBody, { " ","000026","121353","SENAR A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"                                                 ,"2,5"                    , " " } )
		aAdd( aBody, { " ","000027","121851","SEST A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO TRANSPORTADOR AUT�NOMO"                                                           ,"1,5"                    , "20230612", 1033.22 } )
		aAdd( aBody, { " ","000028","121852","SEST A CARGO DO TRABALHADOR (DESCONTADO PELO EMPRESA) SOBRE A REMUNERA��O DO SEGURADO TRANSPORTADOR AUT�NOMO"                             ,"1,5"                    , " " } )
		aAdd( aBody, { " ","000029","122151","SENAT A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO TRANSPORTADOR AUT�NOMO"                                                          ,"1"                      , "20230612", 1033.22 } )                                         
		aAdd( aBody, { " ","000030","122152","SENAT A CARGO DO TRABALHADOR (DESCONTADO PELA EMPRESA) SOBRE A REMUNERA��O DO SEGURADO TRANSPORTADOR AUT�NOMO"                            ,"1"                      , " " } )
		aAdd( aBody, { " ","000031","122551","SESCOOP A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"                                               ,"2,5"                    , " " } )
		aAdd( aBody, { " ","000032","108251","CP DO SEGURADO EMPREGADO E TRABALHADOR AVULSO"                                                                                            ,"Vari�vel"               , " " } )
		aAdd( aBody, { " ","000033","108252","CP DO SEGURADO EMPREGADO CONTRATADO POR CURTO PRAZO - LEI 11.718/2009"                                                                    ,"8"                      , " " } )
		aAdd( aBody, { " ","000034","108253","CP DO SEGURADO EMPREGADO DOM�STICO"                                                                                                       ,"Vari�vel"               , " " } )
		aAdd( aBody, { " ","000035","108254","CP DO SEGURADO EMPREGADO CONTRATADO POR CURTO PRAZO POR EMPREGADOR SEGURADO ESPECIAL - LEI 11.718/2009"                                   ,"8"                      , " " } )
		aAdd( aBody, { " ","000036","108255","CP DO SEGURADO EMPREGADO CONTRATADO POR EMPREGADOR SEGURADO ESPECIAL"                                                                     ,"Vari�vel"               , " " } )
		aAdd( aBody, { " ","000037","108257","CP DO SEGURADO EMPREGADO CONTRATADO POR EMPREGADOR MEI"                                                                                   ,"Vari�vel"               , " " } )
		aAdd( aBody, { " ","000038","109951","CP DO SEGURADO CONTRIBUINTE INDIVIDUAL - 11%"                                                                                             ,"11"                     , " " } )
		aAdd( aBody, { " ","000039","109952","CP DO SEGURADO CONTRIBUINTE INDIVIDUAL - 20%"                                                                                             ,"20"                     , " " } )
		aAdd( aBody, { " ","000040","593656","IRRF - DECIS�O DA JUSTI�A DO TRABALHO"                                                                                                    ,"Tabela Progressiva"     , "20230208" } )
		aAdd( aBody, { " ","000041","188951","IRRF - RRA - DECIS�O DA JUSTI�A DO TRABALHO"                                                                                              ,"Tabela Progressiva"     , "20230208" } )

		//NT 02/2023
		aAdd( aBody, { " ","000042","121851","SEST A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"                                                  ,"1,5"                    , " " , 1033.22} )
		aAdd( aBody, { " ","000043","122151","SENAT A CARGO DA EMPRESA SOBRE A REMUNERA��O DO SEGURADO EMPREGADO OU TRABALHADOR AVULSO"                                                 ,"1"                      , " " , 1033.22} )

		aAdd( aRet, { aHeader, aBody } )
	EndIf

Return( aRet )
