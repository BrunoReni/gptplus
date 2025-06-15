#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'TAFA609.CH'
#INCLUDE "TOPCONN.CH"

Static cIdV7C  as  character
Static cPerV7C as  character
Static __cPicPerRef := Nil 
Static __cPicVrMen  := Nil
Static __cPicVrCP   := Nil
Static __cPicVrRen  := Nil
Static __cPicVrIRF  := Nil
Static __cPicVrCR   := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA609
Informações de Contribuições Decorrentes de Processo Trabalhista

@author Alexandre de Lima/JR GOMES
@since 05/10/2022
@version 1.0
/*/
//------------------------------------------------------------------
Function TAFA609()

	Private oBrw  		as Object
	Private cEvtPosic 	as Character

	oBrw  		:= FWmBrowse():New()
	cEvtPosic 	:= ""

	If TAFAtualizado( .T. ,'TAFA609' )
		TafNewBrowse( "S-2501",,,, STR0001, , 2, 2 )
	EndIf
	
	oBrw:SetCacheView( .F. )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Alexandre de Lima/JR GOMES
@since 05/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina as array

	aRotina := {}

	If !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES") .AND. !FwIsInCallStack("xNewHisAlt")

		ADD OPTION aRotina TITLE "Visualizar" ACTION "TAF609View('V7C',RECNO())" OPERATION 2 ACCESS 0 //'Visualizar'
		ADD OPTION aRotina TITLE "Incluir"    ACTION "TAF609Inc('V7C',RECNO())"  OPERATION 3 ACCESS 0 //'Incluir'
		ADD OPTION aRotina TITLE "Alterar"    ACTION "xTafAlt('V7C', 0 , 0)"     OPERATION 4 ACCESS 0 //'Alterar'
		ADD OPTION aRotina TITLE "Imprimir"	  ACTION "VIEWDEF.TAFA609"			 OPERATION 8 ACCESS 0 //'Imprimir'

	Else

		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

		If lMenuDif
			ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA609' OPERATION 2 ACCESS 0
			aRotina	:= xMnuExtmp( "TAFA609", "V7C", .F. ) // Menu dos extemporâneos
		EndIf

	EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC
@author Alexandre de Lima/JR GOMES
@since 05/10/2022
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStruV7C 	as Object
	Local oStruV7D 	as Object
	Local oStruV7E 	as Object
	Local oStruV7F 	as Object
	Local oStruV7G 	as Object
	Local oModel	as Object

	cIdV7C  := V7C->V7C_IDPROC
	cPerV7C := V7C->V7C_PERAPU
	
	oStruV7C   := FwFormStruct( 1, "V7C" )
	oStruV7D   := FwFormStruct( 1, "V7D" )
	oStruV7E   := FwFormStruct( 1, "V7E" )
	oStruV7F   := FwFormStruct( 1, "V7F" )
	oStruV7G   := FwFormStruct( 1, "V7G" )

	oModel     := MpFormModel():New("TAFA609", , , { |oModel| SaveModel( oModel ) })
	
	oModel:AddFields('MODEL_V7C',, oStruV7C)

	oModel:GetModel( 'MODEL_V7C' ):SetPrimaryKey( { 'V7C_FILIAL' , 'V7C_IDPROC', 'V7C_PERAPU','V7C_ATIVO' } )                                                                                                                   
	
	// OBRIGATORIEDADE DE CAMPOS 
	oStruV7C:SetProperty( 'V7C_IDPROC', MODEL_FIELD_OBRIGAT , .T. )
	oStruV7D:SetProperty( 'V7D_CPFTRA', MODEL_FIELD_OBRIGAT , .T. )
	
	oModel:AddGrid("MODEL_V7D", "MODEL_V7C", oStruV7D)
	oModel:GetModel( "MODEL_V7D" ):SetOptional( .F. )
	oModel:GetModel( "MODEL_V7D" ):SetUniqueLine({"V7D_CPFTRA"})
	
	oModel:AddGrid("MODEL_V7E", "MODEL_V7D", oStruV7E)
	oModel:GetModel( "MODEL_V7E" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_V7E" ):SetUniqueLine({"V7E_PERREF"})
	oModel:GetModel( 'MODEL_V7E' ):SetMaxLine(360)
	
	oModel:AddGrid("MODEL_V7F", "MODEL_V7E", oStruV7F)
	oModel:GetModel( "MODEL_V7F" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_V7F" ):SetUniqueLine({"V7F_IDCODR"})
	oModel:GetModel( 'MODEL_V7F' ):SetMaxLine(99)
	
	oModel:AddGrid("MODEL_V7G", "MODEL_V7D", oStruV7G)
	oModel:GetModel( "MODEL_V7G" ):SetOptional( .T. )
	oModel:GetModel( "MODEL_V7G" ):SetUniqueLine({"V7G_TPCR"})
	oModel:GetModel( 'MODEL_V7G' ):SetMaxLine(99)

	oModel:SetRelation( "MODEL_V7D" , { { "V7D_FILIAL", "xFilial('V7D')" }, { "V7D_ID", "V7C_ID" }, { "V7D_VERSAO", "V7C_VERSAO" }, { "V7D_IDPROC", "V7C_IDPROC" },{ "V7D_PERAPU", "V7C_PERAPU" } }, V7D->(IndexKey(2) ) ) //V7D_FILIAL+V7D_ID+V7D_VERSAO+V7D_IDPROC+V7D_PERAPU+V7D_CPF+VD7_ATIVO
	oModel:SetRelation( "MODEL_V7E" , { { "V7E_FILIAL", "xFilial('V7E')" }, { "V7E_ID", "V7C_ID" }, { "V7E_VERSAO", "V7C_VERSAO" }, { "V7E_IDPROC", "V7C_IDPROC" },{ "V7E_PERAPU", "V7C_PERAPU" }, { "V7E_CPFTRA", "V7D_CPFTRA" } }, V7E->(IndexKey(2) ) )
	oModel:SetRelation( "MODEL_V7F" , { { "V7F_FILIAL", "xFilial('V7F')" }, { "V7F_ID", "V7C_ID" }, { "V7F_VERSAO", "V7C_VERSAO" }, { "V7F_IDPROC", "V7C_IDPROC" },{ "V7F_PERAPU", "V7C_PERAPU" }, { "V7F_CPFTRA", "V7D_CPFTRA" }, { "V7F_PERREF", "V7E_PERREF" }}, V7F->(IndexKey(2) ) )
	oModel:SetRelation( "MODEL_V7G" , { { "V7G_FILIAL", "xFilial('V7G')" }, { "V7G_ID", "V7C_ID" }, { "V7G_VERSAO", "V7C_VERSAO" }, { "V7G_IDPROC", "V7C_IDPROC" },{ "V7G_PERAPU", "V7C_PERAPU" }, { "V7G_CPFTRA", "V7D_CPFTRA" } }, V7G->( IndexKey(2) ) )
	
	//Remoção do GetSX8Num quando se tratar da Exclusão de um Evento Transmitido.
	//Necessário para não incrementar ID que não será utilizado.
	If Type( "INCLUI" ) <> "U"  .AND. !INCLUI
		oStruV7C:SetProperty( "V7C_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndiF

Return( oModel )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Alexandre de Lima/JR GOMES
@since 05/10/2022
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   		as Object
	Local oStruV7C 		as Object
	Local oStruV7D 		as Object
	Local oStruV7E 		as Object
	Local oStruV7F 		as Object
	Local oStruV7G 		as Object
	Local oProtulV7C 	as Object
	Local oView			as Object
	Local cV7C 			as Character
	Local cV7D          as Character
	Local cV7E 			as Character
	Local cV7F 			as Character
	Local cV7CProtul 	as Character
	
	oModel   	:= FWLoadModel( 'TAFA609' )
	oStruV7C 	:= Nil
    oStruV7D 	:= Nil
	oStruV7E 	:= Nil
	oStruV7F 	:= Nil
	oStruV7G 	:= Nil
	oProtulV7C 	:= Nil

	cV7C       := "V7C_IDPROC|V7C_NRPROC|V7C_PERAPU|V7C_OBS|"
	cV7D       := "V7D_CPFTRA|V7D_DCPF|"
	cV7E       := "V7E_PERREF|V7E_VRMEN|V7E_VRCP|V7E_VERREN|V7E_VRIRRF|"
	cV7F 	   := "V7F_IDCODR|V7F_DCODRE|V7F_VRCR|"
	cV7G 	   := "V7G_TPCR|V7G_DCODRE|V7G_VRCR|"
	cV7CProtul := "V7C_PROTUL|V7C_DINSIS|V7C_DTRAN|V7C_HTRANS|V7C_DTRECP|V7C_HRRECP|"
	
	oView := FWFormView():New()

	oView:SetModel( oModel )

	oStruV7C	:= FwFormStruct( 2, "V7C",{|x| AllTrim( x ) + "|" $ cV7C } )
	oStruV7D	:= FwFormStruct( 2, "V7D",{|x| AllTrim( x ) + "|" $ cV7D } )
	oStruV7E	:= FwFormStruct( 2, "V7E",{|x| AllTrim( x ) + "|" $ cV7E } )
	oStruV7F	:= FwFormStruct( 2, "V7F",{|x| AllTrim( x ) + "|" $ cV7F } )
	oStruV7G	:= FwFormStruct( 2, "V7G",{|x| AllTrim( x ) + "|" $ cV7G } )
	oProtulV7C 	:= FwFormStruct( 2, "V7C",{|x| AllTrim( x ) + "|" $ cV7CProtul } )

	oView:AddField( 'VIEW_V7C', oStruV7C, 'MODEL_V7C' )
	oView:AddField( 'VIEW_V7C_PROTUL', oProtulV7C, 'MODEL_V7C' )

	oView:AddGrid("VIEW_V7D", oStruV7D, "MODEL_V7D")
	oView:EnableTitleView("VIEW_V7D",STR0002)

	oView:AddGrid("VIEW_V7E", oStruV7E, "MODEL_V7E")
	oView:EnableTitleView("VIEW_V7E",STR0003) 

	oView:AddGrid("VIEW_V7F", oStruV7F, "MODEL_V7F")
	oView:EnableTitleView("VIEW_V7F",STR0004)

	oView:AddGrid("VIEW_V7G", oStruV7G, "MODEL_V7G")
	oView:EnableTitleView("VIEW_V7G",STR0005)

	oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )
	oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )

	oView:CreateFolder( 'FOLDER_SUPERIOR' )
	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0006 )
	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0007 )

	oView:CreateHorizontalBox( 'V7C_PAI'	  , 030,,, 'FOLDER_SUPERIOR', 'ABA01')
	oView:CreateHorizontalBox( 'V7C_V7D_FILHA', 020,,, 'FOLDER_SUPERIOR', 'ABA01')
	oView:CreateHorizontalBox( 'V7C_PROTUL'	  , 050,,, 'FOLDER_SUPERIOR', 'ABA02')

	oView:CreateHorizontalBox( 'PAINEL_PRINCIPAL', 	050,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateFolder( 'FOLDER_PRINCIPAL', 'PAINEL_PRINCIPAL' )
	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA01', STR0008 ) 
	oView:AddSheet( 'FOLDER_PRINCIPAL', 'ABA02', STR0009 )

	oView:CreateHorizontalBox( 'V7C_V7D_V7E_FILHA'		, 050,,, 'FOLDER_PRINCIPAL', 'ABA01')
	oView:CreateHorizontalBox( 'V7C_V7D_V7E_V7F_FILHA'	, 050,,, 'FOLDER_PRINCIPAL', 'ABA01')
	oView:CreateHorizontalBox( 'V7C_V7D_V7G_FILHA'		, 100,,, 'FOLDER_PRINCIPAL', 'ABA02')

	oView:SetOwnerView( 'VIEW_V7C', 'V7C_PAI' )
	oView:SetOwnerView( 'VIEW_V7C_PROTUL', 'V7C_PROTUL' )
	oView:SetOwnerView( 'VIEW_V7D', 'V7C_V7D_FILHA' )
	oView:SetOwnerView( 'VIEW_V7E', 'V7C_V7D_V7E_FILHA' )
	oView:SetOwnerView( 'VIEW_V7F', 'V7C_V7D_V7E_V7F_FILHA' )
	oView:SetOwnerView( 'VIEW_V7G', 'V7C_V7D_V7G_FILHA' )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Alexandre de Lima/JR GOMES
@Since 10/10/2022
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local cVerAnt    as character     	 
	Local cProtocolo as character  	 
	Local cVersao    as character  	 
	Local cEvento	 as character   	 
	Local cLogOpe	 as character  	 
	Local cLogOpeAnt as character
	Local cChvRegAnt as character 
	Local nV7E       as Numeric 	
	Local nV7D   	 as Numeric 
	Local nV7F       as Numeric
	Local nV7G       as Numeric
	Local nlI        as Numeric
	Local nlV7D      as Numeric
	Local nOperation as numeric	 
	Local nI         as numeric  
	Local nV7DLine   as Numeric
	Local nV7ELine   as Numeric
	Local nV7FLine   as Numeric
	Local nV7GLine   as Numeric   
	Local aGravaV7C  as Array
	Local aDataModel as Array   	 
	Local aGravaV7D  as Array
	Local aGravaV7E  as Array
	Local aGravaV7F  as Array
	Local aGravaV7G  as Array	 
	Local oModelV7C  as Object	 
	Local oModelV7D  as Object
	Local oModelV7E  as Object	 
	Local oModelV7F  as Object
	Local oModelV7G  as Object	   	 
	Local lRetorno	 as logical
	

	cVerAnt 	:= ""     	 
	cProtocolo 	:= ""  	 
	cVersao 	:= "" 	 
	cEvento		:= ""   	 
	cLogOpe		:= "" 	 
	cLogOpeAnt 	:= "" 
	cChvRegAnt  := ""
	nV7E 		:= 0 	
	nV7D   	 	:= 0 
	nV7F      	:= 0
	nV7G        := 0
	nlI         := 0
	nlV7D       := 0
	nOperation  := 0	 
	nI          := 0     
	nV7DLine    := 0
	nV7ELine  	:= 0
	nV7FLine   	:= 0
	nV7GLine   	:= 0
	aGravaV7C   := {}
	aDataModel  := {}   	 
	aGravaV7D   := {}
	aGravaV7E   := {}
	aGravaV7F   := {}
	aGravaV7G   := {}	 
	oModelV7C   := Nil	 
	oModelV7D   := Nil
	oModelV7E   := Nil	 
	oModelV7F   := Nil
	oModelV7G   := Nil	   	 

	nOperation := oModel:GetOperation()
	nI         := 0
	lRetorno   := .T.

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT
		
			TafAjustID("V7C", oModel)

			oModelV7C := oModel:GetModel( "MODEL_V7C" )

			oModel:LoadValue( "MODEL_V7C", "V7C_VERSAO", xFunGetVer() )
			oModel:LoadValue( "MODEL_V7C", "V7C_LAYOUT", "S_01_01_00" )

			TAFAltMan( 3 , 'Save' , oModel, 'MODEL_V7C', 'V7C_LOGOPE' , '2', '' )
			
			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			V7C->( DbSetOrder( 2 ) )
			If V7C->( MsSeek( xFilial( 'V7C' ) + V7C->V7C_ID + '1' ) )
			
				If V7C->V7C_STATUS $ ( "4" )
		
					oModelV7C := oModel:GetModel( "MODEL_V7C" )
					oModelV7D := oModel:GetModel( "MODEL_V7D" )
					oModelV7E := oModel:GetModel( 'MODEL_V7E' )
					oModelV7F := oModel:GetModel( 'MODEL_V7F' )
					oModelV7G := oModel:GetModel( 'MODEL_V7G' )
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao anterior do registro para gravacao do rastro³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVerAnt    := oModelV7C:GetValue ( "V7C_VERSAO" )
					cProtocolo := oModelV7C:GetValue ( "V7C_PROTUL" )
					cEvento	   := oModelV7C:GetValue ( "V7C_EVENTO" )
					cLogOpeAnt := oModelV7C:GetValue ( "V7C_LOGOPE" )

					For nI := 1 to Len( oModelV7C:aDataModel[ 1 ] )
						aAdd( aGravaV7C, { oModelV7C:aDataModel[ 1, nI, 1 ], oModelV7C:aDataModel[ 1, nI, 2 ] } )
					Next nI
					
					V7D->(DBSetOrder( 2 ) )

					If V7D->(MsSeek(xFilial("V7D")+V7C->( V7C_ID + V7C_VERSAO + V7C_IDPROC + V7C_PERAPU ) ) )
						
						For nV7D := 1 To oModel:GetModel( 'MODEL_V7D' ):Length()
							oModel:GetModel( 'MODEL_V7D' ):GoLine(nV7D)

							If !oModel:GetModel( 'MODEL_V7D' ):IsDeleted() .AND. !oModel:GetModel( 'MODEL_V7D' ):IsEmpty() 	
								aAdd (aGravaV7D ,{oModelV7D:GetValue('V7D_CPFTRA')})
							EndIf

							V7E->(DBSetOrder( 2 ) )

							If V7E->(MsSeek(xFilial("V7E")+V7D->( V7D_ID + V7D_VERSAO + V7D_IDPROC + V7D_PERAPU + V7D_CPFTRA ) ) )
						
								For nV7E := 1 To oModel:GetModel( 'MODEL_V7E' ):Length() 
									oModel:GetModel( 'MODEL_V7E' ):GoLine(nV7E)

									If !oModel:GetModel( 'MODEL_V7E' ):IsDeleted() .AND. !oModel:GetModel( 'MODEL_V7E' ):IsEmpty()		
										aAdd (aGravaV7E ,{	oModelV7D:GetValue('V7D_CPFTRA')	,;
															oModelV7E:GetValue('V7E_PERREF')	,;
															oModelV7E:GetValue('V7E_VRMEN')		,;
															oModelV7E:GetValue('V7E_VRCP')		,;
															oModelV7E:GetValue('V7E_VERREN')	,;
															oModelV7E:GetValue('V7E_VRIRRF')	})
									EndIf

									V7F->(DBSetOrder( 2 ) )

									If V7F->(MsSeek(xFilial("V7F")+V7E->(V7E_ID + V7E_VERSAO + V7E_IDPROC + V7E_PERAPU + V7E_CPFTRA + V7E_PERREF) ) )
										
										For nV7F := 1 To oModel:GetModel( 'MODEL_V7F' ):Length()
											oModel:GetModel( 'MODEL_V7F' ):GoLine(nV7F)

											If !oModel:GetModel( 'MODEL_V7F' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V7F' ):IsEmpty()	
												aAdd (aGravaV7F ,{	oModelV7D:GetValue('V7D_CPFTRA'),;
																	oModelV7E:GetValue('V7E_PERREF'),;
																	oModelV7F:GetValue('V7F_IDCODR'),;
																	oModelV7F:GetValue('V7F_VRCR') })
											EndIf
										Next
									EndIf
								Next
							EndIf

							V7G->(DBSetOrder( 2 ) )
							If V7G->(MsSeek(xFilial("V7G")+V7D->(V7D_ID + V7D_VERSAO + V7D_IDPROC + V7D_PERAPU + V7D_CPFTRA ) ) )

								For nV7G := 1 To oModel:GetModel( 'MODEL_V7G' ):Length() 
									oModel:GetModel( 'MODEL_V7G' ):GoLine(nV7G)

									If !oModel:GetModel( 'MODEL_V7G' ):IsDeleted() .AND. !oModel:GetModel( 'MODEL_V7G' ):IsEmpty()	
										aAdd (aGravaV7G ,{ 	oModelV7D:GetValue('V7D_CPFTRA'),;	
														  	oModelV7G:GetValue('V7G_TPCR'),;
															oModelV7G:GetValue('V7G_VRCR')})
									EndIf
								Next

							EndIf
						Next
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Seto o campo como Inativo e gravo a versao do novo registro³
					//³no registro anterior                                       ³
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					FAltRegAnt( "V7C", "2" )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu preciso setar a operacao do model³
					//³como Inclusao                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oModel:DeActivate()
					oModel:SetOperation( 3 )
					oModel:Activate()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Neste momento eu realizo a inclusao do novo registro ja³
					//³contemplando as informacoes alteradas pelo usuario     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nI := 1 to Len( aGravaV7C )
						oModel:LoadValue( "MODEL_V7C", aGravaV7C[ nI, 1 ], aGravaV7C[ nI, 2 ] )
					Next nI

					//Necessário Abaixo do For Nao Retirar
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V7C', 'V7C_LOGOPE' , '' , cLogOpeAnt )
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Busco a versao que sera gravada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cVersao := xFunGetVer()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oModel:LoadValue( "MODEL_V7C", "V7C_VERSAO", cVersao )
					oModel:LoadValue( "MODEL_V7C", "V7C_VERANT", cVerAnt )
					oModel:LoadValue( "MODEL_V7C", "V7C_PROTPN", cProtocolo )
					oModel:LoadValue( "MODEL_V7C", "V7C_PROTUL", "" )
					oModel:LoadValue( "MODEL_V7C", "V7C_LAYOUT", "S_01_01_00" )
					
					// Tratamento para limpar o ID unico do xml
					oModel:LoadValue( 'MODEL_V7C', 'V7C_XMLID', "" )
					
					nV7DLine := 1
					For nV7D := 1 To Len( aGravaV7D )

						oModel:GetModel( 'MODEL_V7D' ):LVALID	:= .T.

						If nV7DLine > 1
							oModel:GetModel( 'MODEL_V7D' ):AddLine()
						EndIf

						oModel:LoadValue( "MODEL_V7D", "V7D_CPFTRA",	aGravaV7D[nV7D][1] )
						
						nV7ELine := 1
						For nV7E := 1 to Len( aGravaV7E )

							If  aGravaV7E[nV7E][1] == aGravaV7D[nV7D][1]

								oModel:GetModel( 'MODEL_V7E' ):LVALID := .T.

								If nV7ELine > 1
									oModel:GetModel( "MODEL_V7E" ):AddLine()
								EndIf

								oModel:LoadValue( "MODEL_V7E", "V7E_PERREF"	, aGravaV7E[nV7E][2] )
								oModel:LoadValue( "MODEL_V7E", "V7E_VRMEN"	, aGravaV7E[nV7E][3] )
								oModel:LoadValue( "MODEL_V7E", "V7E_VRCP"	, aGravaV7E[nV7E][4] )
								oModel:LoadValue( "MODEL_V7E", "V7E_VERREN"	, aGravaV7E[nV7E][5] )
								oModel:LoadValue( "MODEL_V7E", "V7E_VRIRRF"	, aGravaV7E[nV7E][6] )

								nV7FLine := 1
								For nV7F := 1 to Len( aGravaV7F )

									If  aGravaV7F[nV7F][1] + aGravaV7F[nV7F][2] == aGravaV7E[nV7E][1] + aGravaV7E[nV7E][2] 

										oModel:GetModel( 'MODEL_V7F' ):LVALID := .T.

										If nV7FLine > 1
											oModel:GetModel( "MODEL_V7F" ):AddLine()
										EndIf

										oModel:LoadValue( "MODEL_V7F", "V7F_IDCODR"	, aGravaV7F[nV7F][3] )
										oModel:LoadValue( "MODEL_V7F", "V7F_VRCR"	, aGravaV7F[nV7F][4] )
										nV7FLine++
									EndIf
								Next
								nV7ELine++
							EndIf
						Next

						nV7GLine := 1
						For nV7G := 1 to Len( aGravaV7G )

							If  aGravaV7G[nV7G][1] == aGravaV7D[nV7D][1]

								oModel:GetModel( 'MODEL_V7G' ):LVALID := .T.

								If nV7GLine > 1
									oModel:GetModel( "MODEL_V7G" ):AddLine()
								EndIf

								oModel:LoadValue( "MODEL_V7G", "V7G_TPCR"	, aGravaV7G[nV7G][2] )
								oModel:LoadValue( "MODEL_V7G", "V7G_VRCR"	, aGravaV7G[nV7G][3] )
								nV7GLine++
							EndIf
						Next
						nV7DLine++
					Next					

					oModel:LoadValue( "MODEL_V7C", "V7C_EVENTO", "A" )
					FwFormCommit( oModel )
					TAFAltStat( 'V7C', " " )

				Else

					cLogOpeAnt := V7C->V7C_LOGOPE
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_V7C', 'V7C_LOGOPE' , '' , cLogOpeAnt )
					FwFormCommit( oModel )
					TAFAltStat( 'V7C', " " )
				
				EndIf
			EndIf
		
		ElseIf nOperation == MODEL_OPERATION_DELETE
		
			cChvRegAnt := V7C->(V7C_ID + V7C_VERANT)
			TAFAltStat( 'V7C', " " )
			FwFormCommit(oModel)

			If V7C->V7C_EVENTO == "A" .OR. V7C->V7C_EVENTO == "E"
				TAFRastro( 'V7C', 1, cChvRegAnt, .T., , IIF(Type("oBrw") == "U", Nil, oBrw) )
			EndIf
		
		EndIf

	End Transaction

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclusao do evento

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function chamada pelo TafIntegraESocial

@Return .T.

@Author Alexandre de Lima/JR GOMES
@Since 18/10/2022
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

	Local cVerAnt       as character
	Local cProtocolo    as character
	Local cVersao       as character
	Local cEvento       as character
	Local nV7C			as numeric
	Local nV7D			as numeric 
	Local nV7E	 		as numeric
	Local nV7F			as numeric 
	Local nV7G 			as numeric
	Local nI            as numeric
	Local aGrava        as numeric
	Local aGravaV7C     as array
	Local aGravaV7D     as array
	Local aGravaV7E     as array
	Local aGravaV7F     as array
	Local aGravaV7G     as array
	Local aDataModel    as array
	Local oModelV7C     as object
	Local oModelV7D     as object
	Local oModelV7E     as object
	Local oModelV7F     as object
	Local oModelV7G     as object
	Local nV7DLine      as numeric
	Local nV7ELine      as numeric
	Local nV7FLine      as numeric
	Local nV7GLine      as numeric

	cVerAnt		:= ""
	cProtocolo  := ""
	cVersao     := ""
	cEvento     := ""
	nV7C		:= 0
	nV7D		:= 0 
	nV7E	 	:= 0
	nV7F		:= 0 
	nV7G 		:= 0
	nI          := 0
	nV7DLine	:= 0     
	nV7ELine	:= 0
	nV7FLine	:= 0
	nV7GLine	:= 0
	aGrava      := {}
	aGravaV7C   := {}
	aGravaV7D   := {}
	aGravaV7E   := {}
	aGravaV7F   := {}
	aGravaV7G   := {}
	aDataModel	:= {}
	oModelV7C   := Nil
	oModelV7D   := Nil
	oModelV7E   := Nil
	oModelV7F   := Nil
	oModelV7G   := Nil

	Begin Transaction

		//Posiciona o item
		("V7C")->( DBGoTo( nRecno ) )

		oModelV7C := oModel:GetModel( 'MODEL_V7C' )
		oModelV7D := oModel:GetModel( 'MODEL_V7D' )
		oModelV7E := oModel:GetModel( 'MODEL_V7E' )
		oModelV7F := oModel:GetModel( 'MODEL_V7F' )
		oModelV7G := oModel:GetModel( 'MODEL_V7G' )

		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao anterior do registro para gravacao do rastro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVerAnt		:= oModelV7C:GetValue("V7C_VERSAO")
		cProtocolo	:= oModelV7C:GetValue("V7C_PROTUL")
		cEvento		:= oModelV7C:GetValue("V7C_EVENTO")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu gravo as informacoes que foram carregadas       ³
		//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
		//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
		//³nao devem ser consideradas neste momento                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI := 1 to Len( oModelV7C:aDataModel[ 1 ] )
			aAdd( aGravaV7C, { oModelV7C:aDataModel[ 1, nI, 1 ], oModelV7C:aDataModel[ 1, nI, 2 ] } )
		Next nI

		V7D->( DbSetOrder( 2 ) )
		If V7D->(MsSeek(xFilial("V7D")+V7C->( V7C_ID + V7C_VERSAO + V7C_IDPROC + V7C_PERAPU ) ) )
			
			For nV7D := 1 To oModel:GetModel( 'MODEL_V7D' ):Length()
				oModel:GetModel( 'MODEL_V7D' ):GoLine(nV7D)

				If !oModel:GetModel( 'MODEL_V7D' ):IsDeleted() .AND. !oModel:GetModel( 'MODEL_V7D' ):IsEmpty() 	
					aAdd (aGravaV7D ,{oModelV7D:GetValue('V7D_CPFTRA')})
				EndIf
				
				V7E->( DbSetOrder( 2 ) )
				If V7E->(MsSeek(xFilial("V7E")+V7D->( V7D_ID + V7D_VERSAO + V7D_IDPROC + V7D_PERAPU + V7D_CPFTRA ) ) )
			
					For nV7E := 1 To oModel:GetModel( 'MODEL_V7E' ):Length() 
						oModel:GetModel( 'MODEL_V7E' ):GoLine(nV7E)

						If !oModel:GetModel( 'MODEL_V7E' ):IsDeleted() .AND. !oModel:GetModel( 'MODEL_V7E' ):IsEmpty()		
							aAdd (aGravaV7E ,{	oModelV7D:GetValue('V7D_CPFTRA')	,;
												oModelV7E:GetValue('V7E_PERREF')	,;
												oModelV7E:GetValue('V7E_VRMEN')		,;
												oModelV7E:GetValue('V7E_VRCP')		,;
												oModelV7E:GetValue('V7E_VERREN')	,;
												oModelV7E:GetValue('V7E_VRIRRF')	})
						EndIf

						V7F->( DbSetOrder( 2 ) )
						If V7F->(MsSeek(xFilial("V7F")+V7E->(V7E_ID + V7E_VERSAO + V7E_IDPROC + V7E_PERAPU + V7E_CPFTRA + V7E_PERREF) ) )
							
							For nV7F := 1 To oModel:GetModel( 'MODEL_V7F' ):Length()
								oModel:GetModel( 'MODEL_V7F' ):GoLine(nV7F)

								If !oModel:GetModel( 'MODEL_V7F' ):IsDeleted() .And. !oModel:GetModel( 'MODEL_V7F' ):IsEmpty()	
									aAdd (aGravaV7F ,{	oModelV7D:GetValue('V7D_CPFTRA'),;
														oModelV7E:GetValue('V7E_PERREF'),;
														oModelV7F:GetValue('V7F_IDCODR'),;
														oModelV7F:GetValue('V7F_VRCR')})
								EndIf
							Next
						EndIf
					Next
				EndIf

				V7G->( DbSetOrder( 2 ) )
				If V7G->(MsSeek(xFilial("V7G")+V7D->(V7D_ID + V7D_VERSAO + V7D_IDPROC + V7D_PERAPU + V7D_CPFTRA ) ) )

					For nV7G := 1 To oModel:GetModel( 'MODEL_V7G' ):Length() 
						oModel:GetModel( 'MODEL_V7G' ):GoLine(nV7G)

						If !oModel:GetModel( 'MODEL_V7G' ):IsDeleted() .AND. !oModel:GetModel( 'MODEL_V7G' ):IsEmpty()	
							aAdd (aGravaV7G ,{ 	oModelV7D:GetValue('V7D_CPFTRA'),;	
												oModelV7G:GetValue('V7G_TPCR'),;
												oModelV7G:GetValue('V7G_VRCR')})
						EndIf
					Next

				EndIf
			Next
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seto o campo como Inativo e gravo a versao do novo registro³
		//³no registro anterior                                       ³
		//|                                                           |
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		FAltRegAnt( 'V7C', '2' )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu preciso setar a operacao do model³
		//³como Inclusao                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oModel:DeActivate()
		oModel:SetOperation( 3 )
		oModel:Activate()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Neste momento eu realizo a inclusao do novo registro ja³
		//³contemplando as informacoes alteradas pelo usuario     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI := 1 To Len( aGravaV7C )
			oModel:LoadValue( 'MODEL_V7C', aGravaV7C[ nI, 1 ], aGravaV7C[ nI, 2 ] )
		Next

		nV7DLine := 1
		For nV7D := 1 To Len( aGravaV7D )

			oModel:GetModel( 'MODEL_V7D' ):LVALID	:= .T.

			If nV7DLine > 1
				oModel:GetModel( 'MODEL_V7D' ):AddLine()
			EndIf

			oModel:LoadValue( "MODEL_V7D", "V7D_CPFTRA",	aGravaV7D[nV7D][1] )
			
			nV7ELine := 1 
			For nV7E := 1 to Len( aGravaV7E )

				If  aGravaV7E[nV7E][1] == aGravaV7D[nV7D][1]

					oModel:GetModel( 'MODEL_V7E' ):LVALID := .T.

					If nV7ELine > 1
						oModel:GetModel( "MODEL_V7E" ):AddLine()
					EndIf

					oModel:LoadValue( "MODEL_V7E", "V7E_PERREF"	, aGravaV7E[nV7E][2] )
					oModel:LoadValue( "MODEL_V7E", "V7E_VRMEN"	, aGravaV7E[nV7E][3] )
					oModel:LoadValue( "MODEL_V7E", "V7E_VRCP"	, aGravaV7E[nV7E][4] )
					oModel:LoadValue( "MODEL_V7E", "V7E_VERREN"	, aGravaV7E[nV7E][5] )
					oModel:LoadValue( "MODEL_V7E", "V7E_VRIRRF"	, aGravaV7E[nV7E][6] )

					nV7FLine := 1
					For nV7F := 1 to Len( aGravaV7F )

						If  aGravaV7F[nV7F][1] + aGravaV7F[nV7F][2] == aGravaV7E[nV7E][1] + aGravaV7E[nV7E][2] 

							oModel:GetModel( 'MODEL_V7F' ):LVALID := .T.

							If nV7FLine > 1
								oModel:GetModel( "MODEL_V7F" ):AddLine()
							EndIf

							oModel:LoadValue( "MODEL_V7F", "V7F_IDCODR"	, aGravaV7F[nV7F][3] )
							oModel:LoadValue( "MODEL_V7F", "V7F_VRCR"	, aGravaV7F[nV7F][4] )
							nV7FLine++
						EndIf
					Next
					nV7ELine++
				EndIf
			Next

			nV7GLine := 1
			For nV7G := 1 to Len( aGravaV7G )

				If  aGravaV7G[nV7G][1] == aGravaV7D[nV7D][1]

					oModel:GetModel( 'MODEL_V7G' ):LVALID := .T.

					If nV7GLine > 1
						oModel:GetModel( "MODEL_V7G" ):AddLine()
					EndIf

					oModel:LoadValue( "MODEL_V7G", "V7G_TPCR"	, aGravaV7G[nV7G][2] )
					oModel:LoadValue( "MODEL_V7G", "V7G_VRCR"	, aGravaV7G[nV7G][3] )
					nV7GLine++
				EndIf
			Next
			nV7DLine++
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busco a versao que sera gravada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVersao := xFunGetVer()

		/*---------------------------------------------------------
		ATENCAO -> A alteracao destes campos deve sempre estar
		abaixo do Loop do For, pois devem substituir as informacoes
		que foram armazenadas no Loop acima
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_V7C", "V7C_VERSAO", cVersao )
		oModel:LoadValue( "MODEL_V7C", "V7C_VERANT", cVerAnt )
		oModel:LoadValue( "MODEL_V7C", "V7C_PROTPN", cProtocolo )
		oModel:LoadValue( "MODEL_V7C", "V7C_PROTUL", "" )
		
		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclusão
		seta-se o novo evento como uma "nova inclusão", caso contrário o
		evento passar a ser uma alteração
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_V7C", "V7C_EVENTO"	, "E" )
		oModel:LoadValue( "MODEL_V7C", "V7C_ATIVO"	, "1" )	

		FwFormCommit(oModel)		
		TAFAltStat("V7C", "6")

	End Transaction

Return ( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF609View
Monta a View dinâmica
@Param  cAlias  -> Alias da tabela da view
@Param  nRecno  -> Numero do recno
@author  Alexandre de Lima/JR GOMES
@since   18/10/2022
@version 1
/*/
//-------------------------------------------------------------------
Function TAF609View( cAlias as character, nRecno as numeric )

	Local oNewView	as Object
	Local oExecView	as Object
	Local aArea 	as Array
	
	oNewView	:= ViewDef()
	aArea 		:= GetArea()
	oExecView	:= Nil

	DbSelectArea( cAlias )
	(cAlias)->( DbGoTo( nRecno ) )

	oExecView := FWViewExec():New()
	oExecView:setOperation( 1 )
	oExecView:setTitle( STR0001 )
	oExecView:setOK( {|| .T. } )
	oExecView:setModal(.F.)
	oExecView:setView( oNewView )
	oExecView:openView(.T.)

	RestArea( aArea )

Return( 1 )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF609Inc
Monta a View dinâmica
@Param  cAlias  -> Alias da tabela da view
@Param  nRecno  -> Numero do recno
@author  Alexandre de Lima/JR GOMES
@since   20/10/2022
@version 1
/*/
//-------------------------------------------------------------------
Function TAF609Inc( cAlias as character, nRecno as numeric )

	Local oNewView	as Object
	Local oExecView	as Object
	Local aArea 	as Array
	
	oNewView	:= ViewDef()
	aArea 		:= GetArea()
	oExecView	:= Nil

	DbSelectArea( cAlias )
	(cAlias)->( DbGoTo( nRecno ) )

	oExecView := FWViewExec():New()
	oExecView:setOperation( 3 )
	oExecView:setTitle( STR0001 )
	oExecView:setOK( {|| .T. } )
	oExecView:setModal(.F.)
	oExecView:setView( oNewView )
	oExecView:openView(.T.)

	RestArea( aArea )

Return( 3 )

//-------------------------------------------------------------------
/*/{Protheus.doc} XV7CValid
Valida se a chave do registro está inserida na tabela.
@author  Alexandre de lima santos
@since   27/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function XV7CValid(cCampo as Character)

	Local lRet as Logical

	Default cCampo	:= ""

	lRet := .T.

	If AllTrim(cCampo) == "V7C_IDPROC" .AND. !Empty(FWFLDGET("V7C_IDPROC")) .AND. !Empty(FWFLDGET("V7C_PERAPU")) 
		
		If INCLUI
			V7C->( DbSetOrder( 4 ) )
			If V7C->( MsSeek( xFilial( 'V7C' ) + Padr( FWFLDGET("V7C_IDPROC"),TamSx3( "V7C_IDPROC" )[1]) + Padr( FWFLDGET("V7C_PERAPU"), TamSx3( "V7C_PERAPU" )[1] ) + '1' ) )
				Help( ,,"TAFJAGRAVADO",,, 1, 0 )
				lRet := .F.
			EndIf
		EndIf

		If  ALTERA
			If (Alltrim(FWFLDGET("V7C_IDPROC")) != Alltrim(cIdV7C) .OR. Alltrim(FWFLDGET("V7C_PERAPU")) != Alltrim( cPerV7C )) 
				If Alltrim(FWFLDGET("V7C_STATUS")) == "4" .OR. !Empty(FWFLDGET("V7C_VERANT"))
					lRet := .F.
					MsgAlert( STR0011, STR0012 )
				Else
					V7C->( DbSetOrder( 4 ) )
					If V7C->( MsSeek( xFilial( 'V7C' ) + Padr( FWFLDGET("V7C_IDPROC"),TamSx3( "V7C_IDPROC" )[1]) + Padr( FWFLDGET("V7C_PERAPU"), TamSx3( "V7C_PERAPU" )[1] ) + '1' ) )
						Help( ,,"TAFJAGRAVADO",,, 1, 0 )
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF609Grv

@description Funcao de gravacao para atender o registro S-5001

@Param:
cLayout - Nome do Layout que esta sendo enviado, existem situacoes onde o mesmo fonte
          alimenta mais de um regsitro do E-Social, para estes casos serao necessarios
          tratamentos de acordo com o layout que esta sendo enviado.
nOpc   -  Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
cFilEv -  Filial do ERP para onde as informacoes deverao ser importadas
oDados -  Objeto com as informacoes a serem manutenidas ( Outras Integracoes )

@Return
lRet    - Variavel que indica se a importacao foi realizada, ou seja, se as
		  informacoes foram gravadas no banco de dados
aIncons - Array com as inconsistencias encontradas durante a importacao

@author Alexandre de L
@since 01/11/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF609Grv( cLayout as Character, nOpc as Numeric, cFilEv as Character, oXML as Object, cOwner as Character, cFilTran as Character, cPredeces as Character,;
                nTAFRecno as Numeric, cComplem as Character, cGrpTran as Character, cEmpEnv as Character, cFilEnv as Character, cXmlID as Character, cEvtOri as Character,;
				lMigrador as Logical, lDepGPE as Logical, cKey as Character, cMatrC9V as Character, lLaySmpTot as Logical, lExclCMJ as Logical, oTransf as Object, cXml as Character)
				

	Local cCmpsNoUpd	as Character 
	Local cCabec		as Character
	Local cLogOpeAnt 	as Character
	Local lRet			as Logical 
	Local oModel		as Object 
	Local aIncons		as Array 
	Local aRules		as Array 
	Local aChave		as Array 
	Local cInconMsg     as Character 
	Local nV7C          as Numeric
	Local nV7D          as Numeric
	Local nV7E          as Numeric
	Local nV7F          as Numeric
	Local nV7G          as Numeric
	Local nJ  			as Numeric 
	Local cNrProc    	as Character 
	Local cPeriodo      as Character 
	Local cV7DPath      as Character 
	Local cV7EPath      as Character 
	Local cV7FPath      as Character 
	Local cV7GPath      as Character
	Local cCpfTrb       as Character

	Private lVldModel  as Logical 
	Private oDados     as Object

	Default cLayout   	:= ""
	Default nOpc      	:= 1
	Default cFilEv    	:= ""
	Default oXML      	:= Nil
	Default lDepGPE   	:= .F.
	Default cKey      	:= ""
	Default cMatrC9V  	:= ""
	Default cOwner    	:= ""
	Default cFilTran  	:= ""
	Default cPredeces 	:= ""
	Default nTAFRecno 	:= 0
	Default cComplem  	:= ""
	Default cGrpTran  	:= ""
	Default cEmpEnv   	:= ""
	Default cFilEnv   	:= ""
	Default cXmlID    	:= ""
	Default cEvtOri   	:= ""
	Default lMigrador 	:= .F.
	Default lDepGPE   	:= .F.
	Default lLaySmpTot 	:= .F.
	Default cKey      	:= ""
	Default cMatrC9V  	:= ""
	Default lExclCMJ    := .F.
	Default oTransf     := Nil 
	Default cXml        := ""
	
	cCmpsNoUpd	:= "|V7C_FILIAL|V7C_ID|V7C_VERSAO|V7C_PROTUL|V7C_EVENTO|V7C_STATUS|V7C_ATIVO|"
	cCabec		:= "/eSocial/evtContProc/"
	cLogOpeAnt 	:= ""
	cNrProc    	:= ""
	cPeriodo    := ""
	cV7DPath    := ""
	cV7EPath    := ""
	cV7FPath    := ""
	cV7GPath    := ""
	cInconMsg   := ""
	cCpfTrb     := ""
	oModel      := Nil
	lRet		:= .F.
	aIncons		:= {}
	aRules		:= {}
	aChave		:= {}
	nV7C        := 0
	nV7D        := 0
	nV7E        := 0
	nV7F        := 0
	nV7G        := 0
	nJ  	    := 0

	oDados 	  := oXML
	lVldModel := .T.

	cNrProc   := FTafGetVal(  cCabec + "ideProc/nrProcTrab", "C", .F., @aIncons, .F. )
	cPeriodo  := FTafGetVal(  cCabec + "ideProc/perApurPgto", "C", .F., @aIncons, .F. )

	Aadd( aChave, {"C", "V7C_NRPROC", cNrProc,.T.} )

	If At("-", cPeriodo) > 0
		cPeriodo := StrTran(cPeriodo, "-", "" )
		Aadd( aChave, {"C", "V7C_PERAPU", cPeriodo,.T.} )
	Else
		Aadd( aChave, {"C", "V7C_PERAPU", cPeriodo,.T.} )
	EndIf

	V7C->( DbSetOrder( 5 ) )
	If cOwner $ "GPE" 
		If V7C->( MsSeek( xFilial( 'V7C' ) + Padr( cNrProc, TamSx3("V7C_NRPROC")[1] ) +  Padr( cPeriodo, TamSx3("V7C_PERAPU")[1] ) + '1' ) )
			nOpc := 4
		Else
			nOpc := 3
		EndIf
	EndIf

	Begin Transaction	
		//Funcao para validar se a operacao desejada pode ser realizada
		If FTafVldOpe( 'V7C', 5, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA609", cCmpsNoUpd )

			cLogOpeAnt := V7C->V7C_LOGOPE
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
			//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> 5

				oModel:LoadValue( "MODEL_V7C", "V7C_FILIAL", V7C->V7C_FILIAL )
				oModel:LoadValue( "MODEL_V7C", "V7C_LAYOUT", "S_01_01_00" )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rodo o aRules para gravar as informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				V9U->( DbSetOrder( 7 ) )
				If V9U->( MsSeek( xFilial( 'V9U' ) + Padr( cNrProc, TamSx3("V9U_NRPROC")[1] ) + '1' ) )
					oModel:LoadValue("MODEL_V7C", "V7C_IDPROC", V9U->V9U_ID )
					oModel:LoadValue("MODEL_V7C", "V7C_NRPROC", V9U->V9U_NRPROC )
				Else
					cInconMsg := STR0013
				EndIf
				
				If Len(aIncons) == 0 .AND. Empty(cInconMsg)

					oModel:LoadValue("MODEL_V7C", "V7C_PERAPU", StrTran(cPeriodo, "-", "" ) )
						
					If oDados:XPathHasNode(cCabec + "ideProc/obs")
						oModel:LoadValue("MODEL_V7C", "V7C_OBS", FTafGetVal( cCabec + "ideProc/obs"    , "C", .F., @aIncons, .T. ) )
					EndIf
									
					if nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V7C', 'V7C_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_V7C', 'V7C_LOGOPE' , '', cLogOpeAnt )
					EndIf

					nV7D := 1
					cV7DPath := cCabec + "ideTrab[" +  CVALTOCHAR(nV7D) + "]"

					If nOpc == 4 .And. oDados:XPathHasNode( cV7DPath )
						For nJ := 1 to oModel:GetModel( 'MODEL_V7D' ):Length()
							oModel:GetModel( 'MODEL_V7D' ):GoLine(nJ)
							oModel:GetModel( 'MODEL_V7D' ):DeleteLine()
						Next nJ
					EndIf

					nV7D := 1
					
					While oDados:XPathHasNode(cV7DPath)

						oModel:GetModel( 'MODEL_V7D' ):LVALID	:= .T.

						If nOpc == 4 .Or. nV7D > 1
							oModel:GetModel( 'MODEL_V7D' ):AddLine()
						EndIf

						cCpfTrb := FTafGetVal( cV7DPath, "C", .F., @aIncons, .T.,,,,,.T., "cpfTrab")

						V9U->( DbSetOrder( 6 ) )
						If V9U->( MsSeek( xFilial( 'V9U' ) + Padr( cNrProc, TamSx3("V9U_NRPROC")[1] ) + cCpfTrb + '1' ) )
							
							oModel:LoadValue("MODEL_V7D", "V7D_CPFTRA", cCpfTrb )
							
							nV7E := 1
							cV7EPath := cV7DPath + "/calcTrib[" + CVALTOCHAR(nV7E) + "]"

							If nOpc == 4 .And. oDados:XPathHasNode( cV7EPath )
								For nJ := 1 to oModel:GetModel( 'MODEL_V7E' ):Length()
									oModel:GetModel( 'MODEL_V7E' ):GoLine(nJ)
									oModel:GetModel( 'MODEL_V7E' ):DeleteLine()
								Next nJ
							EndIf

							nV7E := 1
						
							While oDados:XPathHasNode(cV7EPath)

								oModel:GetModel( 'MODEL_V7E' ):LVALID	:= .T.

								If nOpc == 4 .Or. nV7E > 1
									oModel:GetModel( 'MODEL_V7E' ):AddLine()
								EndIf

								oModel:LoadValue("MODEL_V7E", "V7E_PERREF", StrTran(FTafGetVal( cV7EPath, "C", .F., @aIncons, .T.,,,,,.T., "perRef"), "-", "" 	))
								oModel:LoadValue("MODEL_V7E", "V7E_VRMEN",  FTafGetVal( cV7EPath, "N", .F., @aIncons, .T.,,,,,.T., "vrBcCpMensal") )
								oModel:LoadValue("MODEL_V7E", "V7E_VRCP",   FTafGetVal( cV7EPath, "N", .F., @aIncons, .T.,,,,,.T., "vrBcCp13") )
								oModel:LoadValue("MODEL_V7E", "V7E_VERREN", FTafGetVal( cV7EPath, "N", .F., @aIncons, .T.,,,,,.T., "vrRendIRRF") )
								oModel:LoadValue("MODEL_V7E", "V7E_VRIRRF", FTafGetVal( cV7EPath, "N", .F., @aIncons, .T.,,,,,.T., "vrRendIRRF13") )
								//V7F

								nV7F := 1
								cV7FPath := cV7EPath + "/infoCRContrib[" + CVALTOCHAR(nV7F) + "]"

								If nOpc == 4 .And. oDados:XPathHasNode( cV7FPath )
									For nJ := 1 to oModel:GetModel( 'MODEL_V7F' ):Length()
										oModel:GetModel( 'MODEL_V7F' ):GoLine(nJ)
										oModel:GetModel( 'MODEL_V7F' ):DeleteLine()
									Next nJ
								EndIf

								nV7F := 1
							
								While oDados:XPathHasNode(cV7FPath)

									oModel:GetModel( 'MODEL_V7F' ):LVALID	:= .T.

									If nOpc == 4 .Or. nV7F > 1
										oModel:GetModel( 'MODEL_V7F' ):AddLine()
									EndIf
											
									oModel:LoadValue("MODEL_V7F", "V7F_IDCODR"	, POSICIONE("V9T",2,XFILIAL("V9T") + FTafGetVal( cV7FPath, "C", .F., @aIncons, .T.,,,,,.T., "tpCR"),"V9T_ID") )
									oModel:LoadValue("MODEL_V7F", "V7F_VRCR", FTafGetVal( cV7FPath, "N", .F., @aIncons, .T.,,,,,.T., "vrCR") )
									
									nV7F++
									cV7FPath := cV7EPath + "/infoCRContrib[" + CVALTOCHAR(nV7F) + "]"
								EndDo

								nV7E++
								cV7EPath := cV7DPath + "/calcTrib[" + CVALTOCHAR(nV7E) + "]"
							EndDo
							//V7G
							nV7G := 1
							cV7GPath := cV7DPath + "/infoCRIRRF[" + CVALTOCHAR(nV7G) + "]"

							If nOpc == 4 .And. oDados:XPathHasNode( cV7GPath )
								For nJ := 1 to oModel:GetModel( 'MODEL_V7G' ):Length()
									oModel:GetModel( 'MODEL_V7G' ):GoLine(nJ)
									oModel:GetModel( 'MODEL_V7G' ):DeleteLine()
								Next nJ
							EndIf

							nV7G := 1
						
							While oDados:XPathHasNode(cV7GPath)

								oModel:GetModel( 'MODEL_V7G' ):LVALID	:= .T.

								If nOpc == 4 .Or. nV7G > 1
									oModel:GetModel( 'MODEL_V7G' ):AddLine()
								EndIf
										
								oModel:LoadValue("MODEL_V7G", "V7G_TPCR", POSICIONE("V9T",2,XFILIAL("V9T") + FTafGetVal( cV7GPath, "C", .F., @aIncons, .T.,,,,,.T., "tpCR"),"V9T_ID") )
								oModel:LoadValue("MODEL_V7G", "V7G_VRCR", FTafGetVal( cV7GPath, "N", .F., @aIncons, .T.,,,,,.T., "vrCR") )
								
								nV7G++
								cV7GPath := cV7DPath + "/infoCRIRRF[" + CVALTOCHAR(nV7G) + "]"
							EndDo
						Else
							cInconMsg := STR0014 + cCpfTrb + STR0015 + cNrProc + ")"
						EndIf

						nV7D++
						cV7DPath := cCabec + "ideTrab[" + CVALTOCHAR(nV7D) + "]"
					EndDo
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetiva a operacao desejada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cInconMsg)
				If TafFormCommit( oModel )
					Aadd(aIncons, "ERRO19")
				Else
					lRet := .T.
				EndIf
			Else
				Aadd(aIncons, cInconMsg)
				DisarmTransaction()
			EndIf

			oModel:DeActivate()
			TafClearModel(oModel)

		EndIf
		
	End Transaction

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Zerando os arrays e os Objetos utilizados no processamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize( aRules, 0 )
	aRules := Nil

	aSize( aChave, 0 )
	aChave := Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF609Xml

Funcao de geracao do XML para atender o registro S-2500
Quando a rotina for chamada o registro deve estar posicionado

@Param:
cAlias		-	Alias da tabela
nRecno		-	Recno do registro corrente
nOpc		-	Operação a ser realizada
lJob		-	Informa se foi chamado por job
lRemEmp		-	Exclusivo do Evento S-1000
cSeqXml		-	Número sequencial para composição da chave ID do XML
lInfoRPT	-	Indica se a geração de XML deve gerar informações na tabela de relatório

@Return:
cXml - Estrutura do Xml do Layout S-2501

@author Alexandre de Lima/JR GOMES
@since 06/10/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF609Xml( cAlias as Character, nRecno as Numeric, nOpc as Numeric, lJob as Logical,; 
					lRemEmp as Logical, cSeqXml as Character )
					
	Local cXml      as character
    Local cLayout   as character
	Local cReg      as character
	Local cFilBkp   as character
    Local nRecnoSM0 as numeric

	Default cALias  := ""
    Default cSeqXml := ""
	Default nRecno  := V7C->(Recno())
	Default nOpc    := 0
	Default lRemEmp := .F.
	Default lJob    := .F.
	
	cReg   	  := "ContProc"
	cXml      := ""
	cLayout   := "2501"
	nRecnoSM0 := SM0->(Recno())
	cFilBkp   := cFilAnt

	("V7C")->( DBGoTo( nRecno ) )

	If IsInCallStack("TafNewBrowse") .And. ( V7C->V7C_FILIAL <> cFilAnt ).AND.!Empty(V7C->V7C_FILIAL)
        cFilAnt := V7C->V7C_FILIAL
    EndIf
	
	
	If __cPicVrMen == Nil
		__cPicPerRef := PesqPict( "V7E", "V7E_PERREF", 7 )
	EndIf

	cXml    := "<ideProc>"
	cXml    +=      xTafTag( "nrProcTrab"   , Posicione( "V9U", 1, xFilial( "V9U" ) + V7C->V7C_IDPROC, "V9U_NRPROC" ),, .F.)
	cXml    +=      xTafTag( "perApurPgto"  , Transform( V7C->V7C_PERAPU, __cPicPerRef) ,, .F.)
	cXml    +=      xTafTag( "obs"          , V7C->V7C_OBS,, .T.)
	cXml    += "</ideProc>"
	
	V7D->( DBSetOrder(2) )
	If V7D->( MsSeek( xFilial("V7D") + V7C->( V7C_ID + V7C_VERSAO + V7C_IDPROC + V7C_PERAPU) ) )
		While V7D->( !Eof() ) .and. V7D->(V7D_FILIAL + V7D_ID + V7D_VERSAO + V7D_IDPROC + V7D_PERAPU) == xFilial("V7C") + V7C->(V7C_ID + V7C_VERSAO  + V7C->V7C_IDPROC + V7C->V7C_PERAPU)
			
			cXml += '<ideTrab cpfTrab="' + V7D->V7D_CPFTRA + '">'

			V7E->( DBSetOrder(2) )
			If V7E->( MsSeek( xFilial("V7E") + V7D->( V7D_ID + V7D_VERSAO + V7D_IDPROC + V7D_PERAPU + V7D_CPFTRA ) ) )

				If __cPicVrMen == Nil
					__cPicVrMen  := PesqPict( "V7E", "V7E_VRMEN" )
					__cPicVrCP   := PesqPict( "V7E", "V7E_VRCP" )
					__cPicVrRen  := PesqPict( "V7E", "V7E_VERREN" )
					__cPicVrIRF  := PesqPict( "V7E", "V7E_VRIRRF" )
					__cPicVrCR   := PesqPict( "V7F", "V7F_VRCR" )
				EndIf

				While V7E->( !Eof() ) .and. V7E->(V7E_FILIAL + V7E_ID + V7E_VERSAO + V7E_IDPROC + V7E_PERAPU + V7E_CPFTRA ) == xFilial("V7D") + V7D->(V7D_ID + V7D_VERSAO + V7D_IDPROC + V7D_PERAPU + V7D_CPFTRA)

					cXml    += "<calcTrib"
					cXml    +=      xTafTag( "perRef"       , Transform( V7E->V7E_PERREF   , __cPicPerRef ) ,             , .F.,,.F.,.T.)
					cXml    +=      xTafTag( "vrBcCpMensal" , V7E->V7E_VRMEN                                , __cPicVrMen , .F.,,.T.,.T.)
					cXml    +=      xTafTag( "vrBcCp13"     , V7E->V7E_VRCP                                 , __cPicVrCP  , .F.,,.T.,.T.)
					cXml    +=      xTafTag( "vrRendIRRF"   , V7E->V7E_VERREN                               , __cPicVrRen , .F.,,.T.,.T.)
					cXml    +=      xTafTag( "vrRendIRRF13" , V7E->V7E_VRIRRF                               , __cPicVrIRF , .F.,,.T.,.T.)
					cXml    += ">"

					V7F->( DBSetOrder(2) )
					If V7F->( MsSeek( xFilial("V7F") + V7E->( V7E_ID + V7E_VERSAO + V7E_IDPROC + V7E_PERAPU + V7E_CPFTRA + V7E_PERREF) ) )

						While V7F->( !Eof() ) .and. V7F->(V7F_FILIAL + V7F_ID + V7F_VERSAO + V7F_IDPROC + V7F_PERAPU + V7F_CPFTRA + V7F_PERREF) == xFilial("V7E") + V7E->(V7E_ID + V7E_VERSAO + V7E_IDPROC + V7E_PERAPU + V7E_CPFTRA + V7E_PERREF)
							cXml    +="<infoCRContrib"
							cXml    +=      xTafTag( "tpCR" , POSICIONE("V9T",1, xFilial("V9T")+V7F->V7F_IDCODR,"V9T_CODIGO"),           , .F.,,   ,.T.)
							cXml    +=      xTafTag( "vrCR" , V7F->V7F_VRCR                                                  , __cPicVrCR, .F.,,.T.,.T.)
							cXml    +="/>"

							V7F->( DbSkip())
						EndDo
					EndIf

					cXml    += "</calcTrib>"

					V7E->( DbSkip())

				EndDo
			EndIf
			
			V7G->( DBSetOrder(2) )
			If V7G->( MsSeek( xFilial("V7G") + V7D->( V7D_ID + V7D_VERSAO + V7D_IDPROC + V7D_PERAPU + V7D_CPFTRA) ) )
				
				While V7G->( !Eof() ) .and. V7G->(V7G_FILIAL + V7G_ID + V7G_VERSAO + V7G_IDPROC + V7G_PERAPU + V7G_CPFTRA ) == xFilial("V7D") + V7D->(V7D_ID + V7D_VERSAO + V7D_IDPROC + V7D_PERAPU + V7D_CPFTRA)
					cXml    +="<infoCRIRRF"
					cXml    +=      xTafTag( "tpCR" , POSICIONE("V9T",1, xFilial("V9T")+V7G->V7G_TPCR,"V9T_CODIGO"),           , .F.,,   ,.T.)
					cXml    +=      xTafTag( "vrCR" , V7G->V7G_VRCR                                                , __cPicVrCR, .F.,,.T.,.T.)
					cXml    +="/>"

					V7G->( DbSkip())
				EndDo
			EndIf
		
			cXml += "</ideTrab>"

			V7D->( DbSkip())
		EndDo			
	EndIf

    If nRecnoSM0 > 0
        SM0->(dbGoto(nRecnoSM0))
    EndIf

    cXml := xTafCabXml(cXml,"V7C", cLayout,cReg,,cSeqXml)

    If !lJob
        xTafGerXml(cXml,cLayout)
    EndIf

	cFilAnt := cFilBkp
	
Return( cXml )
