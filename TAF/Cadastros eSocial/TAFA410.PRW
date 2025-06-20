#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TAFA410.CH"

Static lLaySimplif  := taflayEsoc("S_01_00_00")

//----------------------------------------------------------------------
/*/{Protheus.doc} TAFA410

Informa��es Complementares aos Eventos Peri�dicos - Evento S-1280

@author Mick William da Silva
@since 15/12/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFA410()

	Private oBrw 

	oBrw := FwMBrowse():New()

	If TafAtualizado()

		oBrw:SetDescription(STR0008) //"Informa��es Complementares aos Eventos Peri�dicos"
		oBrw:SetAlias("T3V")
		oBrw:SetMenuDef("TAFA410")

		If FindFunction('TAFSetFilter')
			oBrw:SetFilterDefault(TAFBrwSetFilter("T3V","TAFA410","S-1280"))
		Else
			oBrw:SetFilterDefault( "T3V_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos (1 = Ativo, 2 = Inativo)
		EndIf

		TafLegend(2,"T3V",@oBrw)
		oBrw:Activate()

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Mick William da Silva
@since 15/12/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {}  
	Local aRotina := {}  

	Aadd( aFuncao, { "" , "TafxmlRet('TAF410Xml','1280','T3V')" 									, "1" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'T3V' )" 													, "10"} )
	Aadd( aFuncao, { "" , "xNewHisAlt( 'T3V', 'TAFA410' ,,,,,,'1280','TAF410Xml')" 					, "3" } )
	Aadd( aFuncao, { "" , "TAFXmlLote( 'T3V', 'S-1280' , 'evtInfoComplPer' , 'TAF410Xml',, oBrw )" 	, "5" } )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif
		ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.TAFA410' OPERATION 2 ACCESS 0 //"Visualizar"		
		aRotina	:= xMnuExtmp( "TAFA410", "T3V", .F. )
	Else
		aRotina	:=	xFunMnuTAF( "TAFA410" , , aFuncao)
	EndIf

Return aRotina 

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mick William da Silva
@since 15/12/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oStruT3V  
	Local oStruT3X  
	Local oModel    

	oStruT3V := FwFormStruct(1,"T3V")
	oStruT3X := FwFormStruct(1,"T3X")

	If lLaySimplif
		oStruT3X:RemoveField("T3X_IDCNPJ")
		oStruT3X:RemoveField("T3X_CNPJOP")
	Else
		If TafColumnPos("T3X_CODLOT")
			oStruT3X:RemoveField("T3X_CODLOT")
			oStruT3X:RemoveField("T3X_DCODLO")
		EndIf
	EndIf

	If !TAFNT0421(lLaySimplif) .And. TafColumnPos("T3V_T11096")
		oStruT3V:RemoveField("T3V_T11096")
	EndIf

	oModel   := MpFormModel():New("TAFA410",,,{|oModel| SaveModel(oModel)})// Modelo de dados que ser� constru�do

	// Adiciona ao modelo um componente de formul�rio
	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruT3V:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	//Remo��o do GetSX8Num quando se tratar da Exclus�o de um Evento Transmitido.
	//Necess�rio para n�o incrementar ID que n�o ser� utilizado.
	If Upper( ProcName( 2 ) ) == Upper( "GerarExclusao" )
		oStruT3V:SetProperty( "T3V_ID", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "" ) )
	EndIf

	oModel:AddFields("MODEL_T3V",/*cOwner*/,oStruT3V)

	oModel:AddGrid("MODEL_T3X", "MODEL_T3V", oStruT3X)
	oModel:GetModel( "MODEL_T3X" ):SetOptional( .T. )

	If lLaySimplif
		oModel:GetModel( "MODEL_T3X" ):SetUniqueLine( { "T3X_CODLOT" } )
	Else
		oModel:GetModel( "MODEL_T3X" ):SetUniqueLine( { "T3X_IDCNPJ" } )
	EndIf

	oModel:SetRelation("MODEL_T3X",{ {"T3X_FILIAL","xFilial('T3X')"}, {"T3X_ID","T3V_ID"}, {"T3X_VERSAO","T3V_VERSAO"} },T3X->(IndexKey(1)) )
	oModel:GetModel('MODEL_T3X'):SetMaxLine(9999) 

	oModel:GetModel("MODEL_T3V"):SetPrimaryKey({"T3V_ID","T3V_VERSAO"})

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mick William da Silva
@since 15/12/2015
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local oModel	:= FWLoadModel( 'TAFA410' ) 
	Local oStruT3Va	:= Nil  
	Local oStruT3Vb := Nil
	Local oStruT3Vc := Nil
	Local oStruT3Vd := Nil 
	Local oStruT3Ve	:= Nil
	Local oStruT3X 	:= FWFormStruct(2,'T3X' )  
	Local oView	    := FWFormView():New()
	Local cGrp1		:= ''	   
	Local cGrp2	    := ''
	Local cGrp3 	:= ''
	Local cGrp4	    := ''
	Local cGrp5	    := ''
	Local cCmpFil	:= ''
	Local nT3XHBox	:= 55 
	Local nI		:= 0  

	If lLaySimplif
		oStruT3X:RemoveField("T3X_IDCNPJ")
		oStruT3X:RemoveField("T3X_CNPJOP")
	Else
		If TafColumnPos("T3X_CODLOT")
			oStruT3X:RemoveField("T3X_CODLOT")
			oStruT3X:RemoveField("T3X_DCODLO")
		EndIf
	EndIf

	oView:SetModel(oModel)

	//Informa��es de Apura��o 
	cGrp1 		:= "T3V_INDAPU|T3V_PERAPU|"

	If lLaySimplif
		cGrp1 += "T3V_TPGUIA|"
	EndIf

	cCmpFil	:= cGrp1
	oStruT3Va	:= FwFormStruct(2,"T3V",{|x| AllTrim(x) + "|" $ cCmpFil } )

	//Informa��es Substitui��o Patronal
	cGrp2 		:= "T3V_INDPAT|T3V_PRCONT|"
	cCmpFil	:= cGrp2
	oStruT3Vb	:= FwFormStruct(2,"T3V",{|x| AllTrim(x) + "|" $ cCmpFil } ) 

	//Informa��es infoAtiv. Concom.
	cGrp3		:= "T3V_FATMES|T3V_FAT13|"
	cCmpFil 	:= cGrp3
	oStruT3Vc	:= FwFormStruct(2,"T3V",{|x| AllTrim(x) + "|" $ cCmpFil } ) 

	//Protocolo de Transmiss�o
	cGrp4 := "T3V_PROTUL|"
	cCmpFil := cGrp4
	oStruT3Vd := FwFormStruct(2,"T3V",{|x| AllTrim(x) + "|" $ cCmpFil } )  

	//Sociedade de Fins Lucrativos 11096/2005
	If TAFNT0421(lLaySimplif) .And. TafColumnPos("T3V_T11096")
		cGrp5 		:= "T3V_T11096|"
		cCmpFil 	:= cGrp5
		oStruT3Vf 	:= FwFormStruct(2, "T3V", {|x| AllTrim(x) + "|" $ cCmpFil})  
	EndIf

	If TafColumnPos("T3V_DTRANS")
		cCmpFil := "T3V_DINSIS|T3V_DTRANS|T3V_HTRANS|T3V_DTRECP|T3V_HRRECP|"
		oStruT3Ve := FwFormStruct(2,"T3V",{|x| AllTrim(x) + "|" $ cCmpFil } )
	EndIf

	/*-----------------------------------------------------------------------------------
	Grupo de campos
	-------------------------------------------------------------------------------------*/
	oStruT3Va:AddGroup("GRP_INFO_APURA",		STR0005, "", 1) //Informa��es de Apura��o
	oStruT3Vb:AddGroup("GRP_INFO_PATRONAL", 	STR0006, "", 1) //Informa��es Substitui��o Patronal
	oStruT3Vc:AddGroup("GRP_INFO_ATIVCONCOM", 	STR0007, "", 1) //Informa��es Ativ. Concom.
	
	If TAFNT0421(lLaySimplif) .And. TafColumnPos("T3V_T11096")
		oStruT3Vf:AddGroup("GRP_INFO_SOCFILUC", STR0008, "", 1) //Sociedade de Fins Lucrativos 11096/2005.
	EndIf

	aCmpGrp := StrToKArr(cGrp1,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT3Va:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_INFO_APURA")
	Next nI

	aCmpGrp := StrToKArr(cGrp2,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT3Vb:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_INFO_PATRONAL")
	Next nI

	aCmpGrp := StrToKArr(cGrp3,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT3Vc:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_INFO_ATIVCONCOM")
	Next nI

	If TAFNT0421(lLaySimplif) .And. TafColumnPos("T3V_T11096")
		aCmpGrp := StrToKArr(cGrp5, "|")
		
		For nI := 1 To Len(aCmpGrp)
			oStruT3Vf:SetProperty(aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_INFO_SOCFILUC")
		Next nI
	EndIf	

	/*-----------------------------------------------------------------------------------
	Propriedade de campos
	-------------------------------------------------------------------------------------*/
	oStruT3Vb:SetProperty('T3V_INDPAT',	MVC_VIEW_GROUP_NUMBER, 'GRP_INFO_PATRONAL')
	oStruT3Vb:SetProperty('T3V_PRCONT', MVC_VIEW_GROUP_NUMBER, 'GRP_INFO_PATRONAL')
	oStruT3Vc:SetProperty('T3V_FATMES', MVC_VIEW_GROUP_NUMBER, 'GRP_INFO_ATIVCONCOM')
	oStruT3Vc:SetProperty('T3V_FAT13' , MVC_VIEW_GROUP_NUMBER, 'GRP_INFO_ATIVCONCOM')

	If FindFunction('TafAjustRecibo')
		TafAjustRecibo(oStruT3Vd,"T3V")	
	EndIf

	/*-----------------------------------------------------------------------------------
	Esrutura da View
	-------------------------------------------------------------------------------------*/
	oView:AddField('VIEW_T3Va', oStruT3Va, 'MODEL_T3V')
	oView:AddField('VIEW_T3Vb', oStruT3Vb, 'MODEL_T3V')
	oView:AddField('VIEW_T3Vc', oStruT3Vc, 'MODEL_T3V')
	oView:AddField('VIEW_T3Vd', oStruT3Vd, 'MODEL_T3V')
	
	If FindFunction('TafNmFolder')
		oView:EnableTitleView( 'VIEW_T3Vd', TafNmFolder("recibo",1) ) // "Recibo da �ltima Transmiss�o"  
	EndIf 

	If TafColumnPos("T3V_DTRANS")
		oView:AddField( 'VIEW_T3Ve' , oStruT3Ve, 'MODEL_T3V' )
		oView:EnableTitleView( 'VIEW_T3Ve', TafNmFolder("recibo",2) )
	EndIf

	If TAFNT0421(lLaySimplif) .And. TafColumnPos("T3V_T11096")
		oView:AddField("VIEW_T3Vf", oStruT3Vf, "MODEL_T3V")
	EndIf

	oView:AddGrid ( 'VIEW_T3X' , oStruT3X, 'MODEL_T3X' )
	oView:EnableTitleView("VIEW_T3X",	STR0010) //Informa��es Substitui��o Patronal Operadores Portu�rios

	/*-----------------------------------------------------------------------------------
	Estrutura do Folder
	-------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )
	oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )

	//Abas
	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0008 )   //"Informa��es Complementares aos Eventos Peri�dicos"

	If FindFunction('TafNmFolder')
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0009 )   //"Protocolo de Transmiss�o" 
	EndIf

	//Aba1
	oView:CreateHorizontalBox( 'T3Va',  015,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateHorizontalBox( 'T3Vb',  015,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateHorizontalBox( 'T3Vc',  015,,, 'FOLDER_SUPERIOR', 'ABA01' )

	If TAFNT0421(lLaySimplif) .And. TafColumnPos("T3V_T11096")
		nT3XHBox := 40

		oView:CreateHorizontalBox("T3Vf", 015,,, "FOLDER_SUPERIOR", "ABA01")
	EndIf

	oView:CreateHorizontalBox("T3X", nT3XHBox,,, "FOLDER_SUPERIOR", "ABA01")

	//Aba2
	If TafColumnPos("T3V_DTRANS")
		oView:CreateHorizontalBox( 'T3Vd',  20,,, 'FOLDER_SUPERIOR', 'ABA02' )
		oView:CreateHorizontalBox( 'T3Ve',  80,,, 'FOLDER_SUPERIOR', 'ABA02' )
	Else
		oView:CreateHorizontalBox( 'T3Vd',  100,,, 'FOLDER_SUPERIOR', 'ABA02' )
	EndIf

	/*-----------------------------------------------------------------------------------
	Amarra��o para exibi��o das informa��es
	-------------------------------------------------------------------------------------*/
	oView:SetOwnerView( 'VIEW_T3Va' , 'T3Va')
	oView:SetOwnerView( 'VIEW_T3Vb' , 'T3Vb')
	oView:SetOwnerView( 'VIEW_T3Vc' , 'T3Vc')
	oView:SetOwnerView( 'VIEW_T3Vd' , 'T3Vd')

	If TAFNT0421(lLaySimplif) .And. TafColumnPos("T3V_T11096")
		oView:SetOwnerView("VIEW_T3Vf", "T3Vf")
	EndIf

	If TafColumnPos("T3V_DTRANS")
		oView:SetOwnerView( 'VIEW_T3Ve' , 'T3Ve')
	EndIf
	oView:SetOwnerView( 'VIEW_T3X'  , 'T3X' )


	///Tratamento para que alguns campos de controle interno n�o sejam exibidos na tela
	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If !lMenuDif
		xFunRmFStr(@oStruT3Va,"T3V")
	Endif

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param oModel -> Modelo de dados

@Return .T.

@Author Felipe C. Seolin
@Since 29/10/2013
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

	Local cVerAnt    	 
	Local cProtocolo 	 
	Local cVersao    	 
	Local cEvento	  	 
	Local cLogOpe		 
	Local cLogOpeAnt	 
	Local nOperation 	 
	Local nI         	 
	Local aGrava     	 
	Local aGravaT3X  	 
	Local oModelT3V  	 
	Local oModelT3X  	 
	Local lRetorno	 

	cVerAnt    := ""
	cProtocolo := ""
	cVersao    := ""
	cEvento    := ""
	cLogOpe    := ""
	cLogOpeAnt := ""
	nOperation := oModel:GetOperation()
	nI         := 0
	aGrava     := {}
	aGravaT3X  := {}
	oModelT3V  := Nil
	oModelT3X  := Nil
	lRetorno   := .T.

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT
		
			TafAjustID(�"T3V", oModel)
			
			oModelT3V := oModel:GetModel( "MODEL_T3V" )
			
			oModel:LoadValue( "MODEL_T3V", "T3V_VERSAO", xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T3V', 'T3V_LOGOPE' , '2', '' )
			Endif

			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			//�����������������������������������������������������������������Ŀ
			//�Seek para posicionar no registro antes de realizar as validacoes,�
			//�visto que quando nao esta pocisionado nao eh possivel analisar   �
			//�os campos nao usados como _STATUS                                �
			//�������������������������������������������������������������������
			T3V->( DbSetOrder( 3 ) )
			If T3V->( MsSeek( xFilial( 'T3V' ) + T3V->T3V_ID + '1' ) )
			
				//��������������������������������Ŀ
				//�Se o registro ja foi transmitido�
				//����������������������������������
				If T3V->T3V_STATUS $ ( "4" )
		
					oModelT3V := oModel:GetModel( "MODEL_T3V" )
					oModelT3X := oModel:GetModel( "MODEL_T3X" )
				
					//�����������������������������������������������������������Ŀ
					//�Busco a versao anterior do registro para gravacao do rastro�
					//�������������������������������������������������������������
					cVerAnt    := oModelT3V:GetValue ( "T3V_VERSAO" )
					cProtocolo := oModelT3V:GetValue( "T3V_PROTUL" )
					cEvento	 := oModelT3V:GetValue ( "T3V_EVENTO" )

					If TafColumnPos( "T3V_LOGOPE" )
						cLogOpeAnt := oModelT3V:GetValue( "T3V_LOGOPE" )
					endif

					//�����������������������������������������������������������������Ŀ
					//�Neste momento eu gravo as informacoes que foram carregadas       �
					//�na tela, pois neste momento o usuario ja fez as modificacoes que �
					//�precisava e as mesmas estao armazenadas em memoria, ou seja,     �
					//�nao devem ser consideradas neste momento                         �
					//�������������������������������������������������������������������
					For nI := 1 to Len( oModelT3V:aDataModel[ 1 ] )
						aAdd( aGrava, { oModelT3V:aDataModel[ 1, nI, 1 ], oModelT3V:aDataModel[ 1, nI, 2 ] } )
					Next nI
										
					For nI := 1 to oModel:GetModel( "MODEL_T3X" ):Length()
						oModel:GetModel( "MODEL_T3X" ):GoLine(nI)

						If lLaySimplif
							If  !oModel:GetModel( "MODEL_T3X" ):IsDeleted()
								aAdd(aGravaT3X,{oModelT3X:GetValue("T3X_CODLOT")})
							EndIf
						Else
							If !oModel:GetModel( "MODEL_T3X" ):IsDeleted()
								aAdd(aGravaT3X,{oModelT3X:GetValue("T3X_IDCNPJ")})
							EndIf
						EndIf

					Next nI
					
					//�����������������������������������������������������������Ŀ
					//�Seto o campo como Inativo e gravo a versao do novo registro�
					//�no registro anterior                                       �
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//�������������������������������������������������������������
					FAltRegAnt( "T3V", "2" )

					//��������������������������������������������������Ŀ
					//�Neste momento eu preciso setar a operacao do model�
					//�como Inclusao                                     �
					//����������������������������������������������������
					oModel:DeActivate()
					oModel:SetOperation( 3 )
					oModel:Activate()

					//�������������������������������������������������������Ŀ
					//�Neste momento eu realizo a inclusao do novo registro ja�
					//�contemplando as informacoes alteradas pelo usuario     �
					//���������������������������������������������������������
					For nI := 1 to Len( aGrava )
						oModel:LoadValue( "MODEL_T3V", aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
					Next nI

					//Necess�rio Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T3V', 'T3V_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					For nI := 1 to Len( aGravaT3X )
					
						oModel:GetModel( 'MODEL_T3X' ):LVALID	:= .T.

						If nI > 1
							oModel:GetModel( "MODEL_T3X" ):AddLine()
						EndIf

						If lLaySimplif
							oModel:LoadValue( "MODEL_T3X", "T3X_CODLOT", aGravaT3X[nI][1] )
						Else
							oModel:LoadValue( "MODEL_T3X", "T3X_IDCNPJ", aGravaT3X[nI][1] )
						EndIf

					Next nI
					
					//�������������������������������Ŀ
					//�Busco a versao que sera gravada�
					//���������������������������������
					cVersao := xFunGetVer()

					//�����������������������������������������������������������Ŀ
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//�������������������������������������������������������������
					oModel:LoadValue( "MODEL_T3V", "T3V_VERSAO", cVersao )
					oModel:LoadValue( "MODEL_T3V", "T3V_VERANT", cVerAnt )
					oModel:LoadValue( "MODEL_T3V", "T3V_PROTPN", cProtocolo )
					oModel:LoadValue( "MODEL_T3V", "T3V_PROTUL", "" )
					
					// Tratamento para limpar o ID unico do xml
					cAliasPai := "T3V"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf

					If nOperation == MODEL_OPERATION_DELETE
						oModel:LoadValue( "MODEL_T3V", "T3V_EVENTO", "E" )
					Else
						If cEvento == "E"
							oModel:LoadValue( "MODEL_T3V", "T3V_EVENTO", "I" )
						Else
							oModel:LoadValue( "MODEL_T3V", "T3V_EVENTO", "A" )
						EndIf
					Endif
					
					FwFormCommit( oModel )
					TAFAltStat( 'T3V', " " )

				ElseIf T3V->T3V_STATUS == ( "2" )
					TAFMsgVldOp(oModel,"2")//"Registro n�o pode ser alterado. Aguardando processo da transmiss�o."
					lRetorno := .F.
				Elseif T3V->T3V_STATUS == ( "6" )
					TAFMsgVldOp(oModel,"6")//"Registro n�o pode ser alterado. Aguardando proc. Transm. evento de Exclus�o S-3000"
					lRetorno := .F.
				Elseif T3V->T3V_STATUS == "7"
					TAFMsgVldOp(oModel,"7") //"Registro n�o pode ser alterado, pois o evento j� se encontra na base do RET"
					lRetorno:= .F.
				Else
					If TafColumnPos( "T3V_LOGOPE" )
						cLogOpeAnt := T3V->T3V_LOGOPE
					endif

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T3V', 'T3V_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )
					TAFAltStat( 'T3V', " " )
				EndIf
			EndIf
		
		ElseIf nOperation == MODEL_OPERATION_DELETE
		
			If T3V->T3V_STATUS == "4" .AND. T3V->T3V_EVENTO == "E"
				TAFMsgVldOp(oModel,"4")//"Registro n�o pode ser exclu�do, pois o evento de exclus�o j� se encontra base do RET"
				lRetorno := .F.
			
			ElseIf T3V->T3V_STATUS == "7" .AND. T3V->T3V_EVENTO == "E"
				TAFMsgVldOp(oModel,"4")//"Registro n�o pode ser exclu�do, pois o evento de exclus�o j� se encontra base do RET"
				lRetorno := .F.
			Else
				oModel:DeActivate()
				oModel:SetOperation( 5 )
				oModel:Activate()
				FwFormCommit( oModel )
			EndIf
		
		EndIf

	End Transaction

Return ( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF410Rul
Regras para gravacao das informacoes do registro S-1280 do E-Social

@Param

@Return
aRull - Regras para a gravacao das informacoes

@author Mick William da Silva
@since 17/12/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF410Rul( cCodEvent, cOwner )

	Local aRull	 
	Local cCabec 	 

	Default cCodEvent := ""
	Default cOwner    := ""

	aRull	:= {}
	cCabec	:= "/eSocial/evtInfoComplPer/"

	//�����������������Ŀ
	//�Chave do registro�
	//�������������������
	If TafXNode( oDados, cCodEvent, cOwner,(cCabec + "ideEvento/indApuracao"	) )
		aAdd( aRull, {"T3V_INDAPU", cCabec + "ideEvento/indApuracao", "C", .F.} )
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,(cCabec + "infoSubstPatr/indSubstPatr" ))
		aAdd( aRull, {"T3V_INDPAT", cCabec + "infoSubstPatr/indSubstPatr", "C", .F.} )
	EndIf
		
	If TafXNode( oDados, cCodEvent, cOwner,(cCabec + "infoSubstPatr/percRedContrib" ) )
		aAdd( aRull, {"T3V_PRCONT", cCabec + "infoSubstPatr/percRedContrib", "N", .F.} )
	EndIf
		
	If TafXNode( oDados, cCodEvent, cOwner,(cCabec + "infoAtivConcom/fatorMes" ) )
		aAdd( aRull, {"T3V_FATMES", cCabec + "infoAtivConcom/fatorMes", "N", .F.} )
	EndIf
		
	If TafXNode( oDados, cCodEvent, cOwner,(cCabec + "infoAtivConcom/fator13" ) )
		aAdd( aRull, {"T3V_FAT13" , cCabec + "infoAtivConcom/fator13", "N", .F.} )
	EndIf

	If TAFNT0421(lLaySimplif) .And. TafColumnPos("T3V_T11096")
		If TafXNode(oDados, cCodEvent, cOwner, cCabec + "infoPercTransf11096/percTransf")
			aAdd(aRull, {"T3V_T11096", cCabec + "infoPercTransf11096/percTransf", "C", .F.})
		EndIf
	EndIf

	If lLaySimplif
		If TafXNode( oDados , cCodEvent, cOwner, "ideEvento/indGuia")
			aAdd( aRull, {"T3V_TPGUIA", "ideEvento/indGuia", "C", .F.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, "ideEvento/perApur")
			aAdd( aRull, {"T3V_PERAPU", "ideEvento/perApur", "C", .F.} )
		EndIf
	EndIf

Return aRull 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF410Grv
@type			function
@description	Fun��o de grava��o para atender o registro S-2800.
@author			Felipe C. Seolin
@since			29/10/2013
@version		1.0
@param			cLayout		-	Nome do Layout que est� sendo enviado
@param			nOpc		-	Op��o a ser realizada ( 3 = Inclus�o, 4 = Altera��o, 5 = Exclus�o )
@param			cFilEv		-	Filial do ERP para onde as informa��es dever�o ser importadas
@param			oXML		-	Objeto com as informa��es a serem manutenidas ( Outras Integra��es )
@param			cOwner
@param			cFilTran
@param			cPredeces
@param			nTafRecno
@param			cComplem
@param			cGrpTran
@param			cEmpOriGrp
@param			cFilOriGrp
@param			cXmlID		-	Atributo Id, �nico para o XML do eSocial. Utilizado para importa��o de dados de clientes migrando para o TAF
@return			lRet		-	Vari�vel que indica se a importa��o foi realizada, ou seja, se as informa��es foram gravadas no banco de dados
@param			aIncons		-	Array com as inconsist�ncias encontradas durante a importa��o
/*/
//-------------------------------------------------------------------
Function TAF410Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

	Local cCmpsNoUpd	:=	"|T3V_FILIAL|T3V_ID|T3V_VERSAO|T3V_VERANT|T3V_PROTUL|T3V_PROTPN|T3V_EVENTO|T3V_STATUS|T3V_ATIVO|"
	Local cCabec		:=	"/eSocial/evtInfoComplPer/"
	Local cT3XPath		:=	""
	Local cInconMsg		:=	""
	Local cPeriodo		:=	""
	Local cChave		:=	""
	Local cCodEvent		:=	Posicione( "C8E", 2, xFilial( "C8E" ) + "S-" + cLayout, "C8E->C8E_ID" )
	Local cLogOpeAnt	:=	""
	Local nI			:=	0
	Local nX			:=	0
	Local nSeqErrGrv	:=	0
	Local lRet			:=	.F.
	Local aIncons		:=	{}
	Local aRules		:=	{}
	Local aChave		:=	{}
	Local oModel		:=	Nil
	Local cIndGuia		:= " "
	Local nT3VOrder		:= IIF(lLaySimplif,5,4)

	Private lVldModel	:=	.T. //Caso a chamada seja via integra��o, seto a vari�vel de controle de valida��o como .T.
	Private oDados		:=	oXML

	Default cLayout		:=	""
	Default nOpc		:=	1
	Default cFilEv		:=	""
	Default oXML		:=	Nil
	Default cOwner		:=	""
	Default cFilTran	:=	""
	Default cPredeces	:=	""
	Default nTafRecno	:=	0
	Default cComplem	:=	""
	Default cGrpTran	:=	""
	Default cEmpOriGrp	:=	""
	Default cFilOriGrp	:=	""
	Default cXmlID		:=	""

	//Para o cadastro de complemento de empresa a chave de busca         
	//de informacoes na tabela eh o codigo da filial, nao se considera a 
	//data inicial e final constante no layout do E-Social               

	//Chave do Registro
	cPeriodo	:= FTafGetVal( cCabec + "ideEvento/perApur", "C", .F., @aIncons, .F. )

	Aadd( aChave, {"C", "T3V_INDAPU", FTafGetVal( cCabec + "ideEvento/indApuracao", "C", .F., @aIncons, .F. )  , .T.} ) 
	cChave := Padr( aChave[ 1, 3 ], Tamsx3( aChave[ 1, 2 ])[1])
			
	If At("-", cPeriodo) > 0
		Aadd( aChave, {"C", "T3V_PERAPU", StrTran(cPeriodo, "-", "" ),.T.} )
		cChave += Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1])	
	Else
		Aadd( aChave, {"C", "T3V_PERAPU", cPeriodo  , .T.} ) 
		cChave += Padr( aChave[ 2, 3 ], Tamsx3( aChave[ 2, 2 ])[1])		
	EndIf

	If lLaySimplif
		cIndGuia	:= FTafGetVal( cCabec + "ideEvento/indGuia", "C", .F., @aIncons, .F. )

		Aadd( aChave, {"C", "T3V_TPGUIA", cIndGuia  , .T.} ) 
		cChave += Padr( aChave[ 3, 3 ], Tamsx3( aChave[ 3, 2 ])[1])	
	EndIf
		
	//Verifica se o evento ja existe na base
	("T3V")->( DbSetOrder( nT3VOrder ) )

	If ("T3V")->( MsSeek( FTafGetFil( cFilEv , @aIncons , "T3V" ) + cChave + "1" ) )
		nOpc := 4
	EndIf
			
	Begin Transaction

		//Funcao para validar se a operacao desejada pode ser realizada
		If FTafVldOpe( 'T3V', nT3VOrder, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA410", cCmpsNoUpd , , , ,	)

			If TafColumnPos( "T3V_LOGOPE" )
				cLogOpeAnt := T3V->T3V_LOGOPE
			endif

			//���������������������������������������������������������������Ŀ
			//�Carrego array com os campos De/Para de gravacao das informacoes�
			//�����������������������������������������������������������������
			aRules := TAF410Rul( cCodEvent, cOwner )

			//����������������������������������������������������������������Ŀ
			//�Quando se tratar de uma Exclusao direta apenas preciso realizar �
			//�o Commit(), nao eh necessaria nenhuma manutencao nas informacoes�
			//������������������������������������������������������������������
			If nOpc <> 5

				oModel:LoadValue( "MODEL_T3V", "T3V_PERAPU", StrTran(cPeriodo, "-", "" ) )
				oModel:LoadValue( "MODEL_T3V", "T3V_FILIAL", T3V->T3V_FILIAL )

				If lLaySimplif
					oModel:LoadValue( "MODEL_T3V", "T3V_TPGUIA", cIndGuia )
				EndIf

				If TAFColumnPos( "T3V_XMLID" )
					oModel:LoadValue( "MODEL_T3V", "T3V_XMLID", cXmlID )
				EndIf

				//����������������������������������������Ŀ
				//�Rodo o aRules para gravar as informacoes�
				//������������������������������������������
				For nI := 1 to Len( aRules )
					oModel:LoadValue( "MODEL_T3V", aRules[ nI, 01 ], FTafGetVal( aRules[ nI, 02 ], aRules[nI, 03], aRules[nI, 04], @aIncons, .F. ) )
				Next nI

				If Findfunction("TAFAltMan")
					if nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T3V', 'T3V_LOGOPE' , '1', '' )
					elseif nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T3V', 'T3V_LOGOPE' , '', cLogOpeAnt )
					EndIf
				EndIf

				//����������������������������������������������������������������Ŀ
				//�Quando se trata de uma alteracao, deleto todas as linhas do Grid�
				//������������������������������������������������������������������
				
				nX := 1
				cT3XPath := cCabec + "infoSubstPatrOpPort[" + AllTrim(Str(nX)) + "]"

				If nOpc == 4
					For nX := 1 to oModel:GetModel( "MODEL_T3X" ):Length()
						oModel:GetModel( "MODEL_T3X" ):GoLine(nX)
						oModel:GetModel( "MODEL_T3X" ):DeleteLine()
					Next nX
				EndIf
				
				nX := 1
				While oDados:XPathHasNode(cT3XPath)

					If nOpc == 4 .Or. nX > 1
						oModel:GetModel( "MODEL_T3X" ):lValid:= .T.
						oModel:GetModel( "MODEL_T3X" ):AddLine()
					EndIf
					
					If lLaySimplif
						If oDados:XPathHasNode(cT3XPath + "/codLotacao"	)
							oModel:LoadValue( "MODEL_T3X", "T3X_CODLOT", FGetIdInt( "codLotacao", "", cT3XPath + "/codLotacao" ,,,,@cInconMsg, @nSeqErrGrv))
						EndIf
					
					ElseIf oDados:XPathHasNode(cT3XPath + "/cnpjOpPortuario"	)
						oModel:LoadValue( "MODEL_T3X", "T3X_IDCNPJ", FGetIdInt( "cnpjOpPortuario", "", cT3XPath + "/cnpjOpPortuario" ,,,,@cInconMsg, @nSeqErrGrv))
					EndIf
										
					nX++
					cT3XPath := cCabec + "infoSubstPatrOpPort[" + AllTrim(Str(nX)) + "]"
				EndDo
				
			EndIf

			//���������������������������Ŀ
			//�Efetiva a operacao desejada�
			//�����������������������������
			If Empty(cInconMsg)	.And. Empty(aIncons)
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
			If FindFunction('TafClearModel')
				TafClearModel(oModel)
			EndIf
			
		Endif
		
	End Transaction

	//����������������������������������������������������������Ŀ
	//�Zerando os arrays e os Objetos utilizados no processamento�
	//������������������������������������������������������������
	aSize( aRules, 0 )
	aRules := Nil

	aSize( aChave, 0 )
	aChave := Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF410Xml
Funcao de geracao do XML para atender o registro S-1280
Quando a rotina for chamada o registro deve estar posicionado

@Param:
cAlias - Alias da Tabela
nRecno - Recno do Registro corrente
nOpc   - Operacao a ser realizada
lJob   - Informa se foi chamado por Job
lRemEmp - Exclusivo do Evento S-1000
cSeqXml - Numero sequencial para composi��o da chave ID do XML

@Return:
cXml - Estrutura do Xml do Layout S-2800

@author Mick William da Silva
@since 16/12/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF410Xml(cAlias,nRecno,nOpc,lJob,lRemEmp,cSeqXml)

	Local cXml     
	Local cLayout  
	Local cReg     
	Local aMensal  
	Local lUsePic  

	Default lJob    := .F.
	Default cSeqXml := ""

	cXml    := ""
	cLayout := "1280"
	cReg    := "InfoComplPer"
	aMensal := {}

	Default lJob  := .F.

	DBSelectArea("T3V")
	T3V->(DBSetOrder(1))

	DBSelectArea("T3X")
	T3X->(DBSetOrder(1))

	AADD(aMensal,T3V->T3V_INDAPU) 
		
	If Len(Alltrim(T3V->T3V_PERAPU)) <= 4
		AADD(aMensal,T3V->T3V_PERAPU)  
	Else
		AADD(aMensal,substr(T3V->T3V_PERAPU, 1, 4) + '-' + substr(T3V->T3V_PERAPU, 5, 2) )
	EndIf 
		
	lUsePic := !Empty(T3V->T3V_PRCONT)
		
	xTafTagGroup("infoSubstPatr"	,{{"indSubstPatr"  ,T3V->T3V_INDPAT 		,,.F.};
										, {"percRedContrib",T3V->T3V_PRCONT,IIf(lUsePic,PesqPict("T3V","T3V_PRCONT"),Nil),.F.,,.T.}};
										, @cXml)	

	If T3X->(MsSeek(xFilial("T3X") + T3V->(T3V_ID + T3V_VERSAO)))
		While T3X->(!Eof()) .and. T3X->(T3X_FILIAL + T3X_ID + T3X_VERSAO) == xFilial("T3X") + T3V->(T3V_ID + T3V_VERSAO)

			If lLaySimplif
				cXml +=	"<infoSubstPatrOpPort>"
					cXml +=	xTafTag("codLotacao"		, Posicione("C99",4,xFilial("C99")+T3X->T3X_CODLOT+"1","C99_CODIGO"),)
				cXml +=	"</infoSubstPatrOpPort>"
			Else
				cXml +=	"<infoSubstPatrOpPort>"
					cXml +=	xTafTag("cnpjOpPortuario"		, Posicione("C8W",6,xFilial("C8W")+T3X->T3X_IDCNPJ+"1","C8W_CNPJOP"),)
				cXml +=	"</infoSubstPatrOpPort>"
			EndIf
				
		T3X->(DBSkip())
		EndDo
	EndIf

	xTafTagGroup("infoAtivConcom"	,{{"fatorMes",T3V->T3V_FATMES 		,PesqPict("T3V","T3V_FATMES"),.F.};
										, {"fator13", T3V->T3V_FAT13	,PesqPict("T3V","T3V_FAT13 "),.F.}};
										, @cXml)	

	If TAFNT0421(lLaySimplif) .And. TafColumnPos("T3V_T11096")
		xTafTagGroup("infoPercTransf11096", {{"percTransf", T3V->T3V_T11096, PesqPict("T3V", "T3V_T11096"), .F.}}, @cXml)	
	EndIf								

	//����������������������Ŀ
	//�Estrutura do cabecalho�
	//������������������������
	cXml := xTafCabXml(cXml,"T3V",cLayout,cReg,aMensal,cSeqXml)

	T3V->(DbCloseArea())
	T3X->(DbCloseArea())
	//����������������������������Ŀ
	//�Executa gravacao do registro�
	//������������������������������
	If !lJob
		xTafGerXml(cXml,cLayout)
	EndIf

Return cXml	

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclus�o do evento (S-3000)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function � chamada pelo TafIntegraESocial

@Return .T.

@Author Mick William da Silva
@Since 16/12/2015
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel, nRecno, lRotExc )

	Local cVerAnt    	 
	Local cProtocolo 	 
	Local cVersao    	 
	Local cEvento		 
	Local nI         	 
	Local aGrava     	 
	Local aGravaT3X  	 
	Local oModelT3V  	 
	Local oModelT3X  	 

	cVerAnt    := ""
	cProtocolo := ""
	cVersao    := ""
	cEvento    := ""
	nI         := 0
	aGrava     := {}
	aGravaT3X  := {}
	oModelT3V  := Nil
	oModelT3X  := Nil

	Begin Transaction

		//Posiciona o item
		("T3V")->( DBGoTo( nRecno ) )
		
		//Carrego a Estrutura dos Models a serem gravados
		oModelT3V := oModel:GetModel( "MODEL_T3V"  )
		oModelT3X := oModel:GetModel( "MODEL_T3X"  )

		//�����������������������������������������������������������Ŀ
		//�Busco a versao anterior do registro para gravacao do rastro�
		//�������������������������������������������������������������
		cVerAnt    := oModelT3V:GetValue ( "T3V_VERSAO" )
		cProtocolo := oModelT3V:GetValue( "T3V_PROTUL" )
		cEvento	 := oModelT3V:GetValue ( "T3V_EVENTO" )
		
		//�����������������������������������������������������������������Ŀ
		//�Neste momento eu gravo as informacoes que foram carregadas       �
		//�na tela, pois neste momento o usuario ja fez as modificacoes que �
		//�precisava e as mesmas estao armazenadas em memoria, ou seja,     �
		//�nao devem ser consideradas neste momento                         �
		//�������������������������������������������������������������������
		For nI := 1 to Len( oModelT3V:aDataModel[ 1 ] )
			aAdd( aGrava, { oModelT3V:aDataModel[ 1, nI, 1 ], oModelT3V:aDataModel[ 1, nI, 2 ] } )
		Next nI
		
		For nI := 1 to oModel:GetModel( "MODEL_T3X" ):Length()
			oModel:GetModel( "MODEL_T3X" ):GoLine(nI)
		
			If lLaySimplif .And. !oModel:GetModel( "MODEL_T3X" ):IsDeleted()
				aAdd(aGravaT3X,{oModelT3X:GetValue("T3X_CODLOT")})
			Else
				aAdd(aGravaT3X,{oModelT3X:GetValue("T3X_IDCNPJ")})
			EndIf
		Next nI
		
		//�����������������������������������������������������������Ŀ
		//�Seto o campo como Inativo e gravo a versao do novo registro�
		//�no registro anterior                                       �
		//|                                                           |
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//�������������������������������������������������������������
		FAltRegAnt( "T3V", "2" )
		
		//��������������������������������������������������Ŀ
		//�Neste momento eu preciso setar a operacao do model�
		//�como Inclusao                                     �
		//����������������������������������������������������
		oModel:DeActivate()
		oModel:SetOperation( 3 )
		oModel:Activate()
		
		//�������������������������������������������������������Ŀ
		//�Neste momento eu realizo a inclusao do novo registro ja�
		//�contemplando as informacoes alteradas pelo usuario     �
		//���������������������������������������������������������
		For nI := 1 to Len( aGrava )
			oModel:LoadValue( "MODEL_T3V", aGrava[ nI, 1 ], aGrava[ nI, 2 ] )
		Next nI
		
		For nI := 1 to Len( aGravaT3X )
			
			oModel:GetModel( 'MODEL_T3X' ):LVALID	:= .T.
		
			If nI > 1
				oModel:GetModel( "MODEL_T3X" ):AddLine()
			EndIf
		
			If lLaySimplif
				oModel:LoadValue( "MODEL_T3X", "T3X_CODLOT", aGravaT3X[nI][1] )
			Else
				oModel:LoadValue( "MODEL_T3X", "T3X_IDCNPJ", aGravaT3X[nI][1] )
			EndIf
			
		Next nI
						
		//�������������������������������Ŀ
		//�Busco a versao que sera gravada�
		//���������������������������������
		cVersao := xFunGetVer()

		//�����������������������������������������������������������Ŀ
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//�������������������������������������������������������������
		oModel:LoadValue( "MODEL_T3V", "T3V_VERSAO", cVersao )
		oModel:LoadValue( "MODEL_T3V", "T3V_VERANT", cVerAnt )
		oModel:LoadValue( "MODEL_T3V", "T3V_PROTPN", cProtocolo )
		oModel:LoadValue( "MODEL_T3V", "T3V_PROTUL", "" )

		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclus�o
		seta-se o novo evento como uma "nova inclus�o", caso contr�rio o
		evento passar a ser uma altera��o
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_T3V", "T3V_EVENTO", "E" )
		oModel:LoadValue( "MODEL_T3V", "T3V_ATIVO", "1" )

		FwFormCommit( oModel )
		TAFAltStat( 'T3V',"6" )

	End Transaction
		
Return ( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF410Inic
Funcao chamada pelo inicializador padr�o

@Param  cCpo  -> campo que chamou a fun��o

@Return cRet  -> Inicializador utilizado

@Author Aline.Ven�ncio / Almeida.Veronica
@Since 22/02/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAF410Inic(cCpo)

	Local cRet := ""

	If cCpo == 'T3X_CNPJOP' .And. !taflayEsoc("S_01_00_00")
		cRet := IIF(!INCLUI .AND. !EMPTY(T3X->T3X_IDCNPJ), POSICIONE("C8W",6,XFILIAL("C8W")+T3X->T3X_IDCNPJ+"1","C8W_CNPJOP"),"")
	ElseIf cCpo == 'T3X_DCODLO' .And. taflayEsoc("S_01_00_00")
		C99->(DBGOTOP())
		cRet := IIF(!INCLUI .AND. !EMPTY(T3X->T3X_CODLOT), POSICIONE("C99",4,XFILIAL("C99") + T3X->T3X_CODLOT + "1","C99_CODIGO") ,"")
	EndIf

Return cRet
