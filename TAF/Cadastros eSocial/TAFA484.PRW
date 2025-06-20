#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA484.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA484
Cadastro MVC de Convoca��o para Trabalho Intermitente S-2260
 
@author Jos� Rimarach�n D�az
@since 31/10/2017
@version 1.0
/*/
//--------------------------------------------------------------------
Function TAFA484()

	Private oBrw as Object

	oBrw := FwMBrowse():New()

	If FindFunction("TAFDesEven")
		TAFDesEven()
	EndIf

	// Fun��o que indica se o ambiente � v�lido para o eSocial 2.3
	If TafAtualizado()

		oBrw:SetDescription(STR0001) //"Convoca��o para Trabalho Intermitente"
		oBrw:SetAlias("T87")
		oBrw:SetMenuDef("TAFA484")

		If FindFunction('TAFSetFilter')
			oBrw:SetFilterDefault(TAFBrwSetFilter("T87","TAFA484","S-2260"))
		Else
			oBrw:SetFilterDefault( "T87_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos (1 = Ativo, 2 = Inativo)
		EndIf

		TafLegend(2,"T87",@oBrw)
		oBrw:Activate()

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Jos� Rimarach�n D�az
@since 31/10/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao as Array
	Local aRotina as Array

	aFuncao := {}
	aRotina := {}

	If FindFunction('TafXmlRet')
		Aadd( aFuncao, { "" , "TafxmlRet('TAF484Xml','2260','T87')" , "1" } )
	Else
		Aadd( aFuncao, { "" , "TAF484Xml" , "1" } )
	EndIf 

	//Chamo a Browse do Hist�rico
	If FindFunction( "xNewHisAlt" )
		Aadd( aFuncao, { "" , "xNewHisAlt( 'T87', 'TAFA484' ,,,,,,'2260','TAF484Xml' )" , "3" } )
	Else
		Aadd( aFuncao, { "" , "xFunHisAlt( 'T87', 'TAFA484' ,,,, 'TAF484XML','2260'  )" , "3" } )
	EndIf

	Aadd( aFuncao, { "" , "TAFXmlLote( 'T87', 'S-2260' , 'evtConvInterm' , 'TAF484Xml',, oBrw )" , "5" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'T87' )" , "10" } )

	lMenuDIf := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDIf )

	If lMenuDif .Or. ViewEvent('S-2260')
		ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.TAFA484' OPERATION 2 ACCESS 0 //"Visualizar"
		
		// Menu dos extempor�neos
		If  !ViewEvent('S-2260') .AND. FindFunction( "xNewHisAlt" ) .AND. FindFunction( "xTafExtmp" ) .And. xTafExtmp()
			aRotina	:= xMnuExtmp( "TAFA484", "T87" )
		EndIf
		
	Else
		aRotina	:=	xFunMnuTAF( "TAFA484" , , aFuncao)
	EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Jos� Rimarach�n D�az
@since 31/10/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

	Local oModel   as Object
	Local oStruT87 as Object

	oModel   := MpFormModel():New("TAFA484", , , {|oModel| SaveModel(oModel)})
	oStruT87 := FwFormStruct(1,"T87")

	lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

	If lVldModel
		oStruT87:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
	EndIf

	oModel:AddFields("MODEL_T87",/*cOwner*/,oStruT87)
	oModel:GetModel("MODEL_T87"):SetPrimaryKey({"T87_TRABAL","T87_CONVOC"}) //Defini�ao da chave primaria/modelo

Return(oModel)

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Jos� Rimarach�n D�az
@since 31/10/2017
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

	Local aCmpGrp   as Array
	Local cCmpFil   as Character
	Local cGrupo1   as Character
	Local cGrupo2   as Character
	Local cGrupo3   as Character
	Local cGrupo4   as Character
	Local cGrupo5   as Character
	Local cGrupo6   as Character
	Local nI        as Numeric
	Local oModel    as Object
	Local oStruT87a as Object
	Local oStruT87b as Object
	Local oStruT87c as Object
	Local oStruT87d as Object
	Local oStruT87e as Object
	Local oStruT87f as Object
	Local oStruT87g as Object
	Local oView     as Object

	aCmpGrp   := {}
	cCmpFil   := ""
	cGrupo1   := ""
	cGrupo2   := ""
	cGrupo3   := ""
	cGrupo4   := ""
	cGrupo5   := ""
	cGrupo6   := ""
	nI        := 0
	oModel    := FWLoadModel("TAFA484")
	oStruT87a := Nil
	oStruT87b := Nil
	oStruT87c := Nil
	oStruT87d := Nil
	oStruT87e := Nil
	oStruT87f := Nil
	oStruT87g := Nil
	oView     := FWFormView():New()

	oView:SetModel(oModel)

	//"Informa��es de Identifica��o do Trabalhador e do V�nculo"
	cGrupo1  := 'T87_ID|T87_VERSAO|T87_VERANT|T87_PROTPN|T87_EVENTO|T87_ATIVO|T87_TRABAL|T87_DTRABA|'
	cCmpFil   := cGrupo1 
	oStruT87a := FwFormStruct( 2, 'T87', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	//"Informa��es da convoca��o para trabalho intermitente"
	cGrupo2  := 'T87_CONVOC|T87_DTINIP|T87_DTFIMP|T87_DTPREV|'

	cCmpFil   := cGrupo2 
	oStruT87b := FwFormStruct( 2, 'T87', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	//"Informa��es da(s) jornada(s) di�ria(s) da presta��o de trabalho intermitente"
	cGrupo3  := 'T87_CODHOR|T87_DCODHO|T87_DTPJOR|'
	cCmpFil   := cGrupo3 
	oStruT87c := FwFormStruct( 2, 'T87', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	//"Informa��es do local da presta��o de trabalho intermitente"
	cGrupo4  := 'T87_LOCTRB|'
	cCmpFil   := cGrupo4 
	oStruT87d := FwFormStruct( 2, 'T87', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	//"Informa��es do local de trabalho intermitente"
	cGrupo5  := 'T87_UF|T87_DUF|T87_MUN|T87_DMUN|T87_TPLOGR|T87_DTPLOG|T87_LOGRAD|T87_NRLOG|T87_COMLOG|T87_BAIRRO|T87_CEP|'
	cCmpFil   := cGrupo5 
	oStruT87e := FwFormStruct( 2, 'T87', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	//"Protocolo de Transmiss�o"
	cGrupo6 := 'T87_PROTUL|'	
	cCmpFil   := cGrupo6
	oStruT87f := FwFormStruct( 2, 'T87', {|x| AllTrim( x ) + "|" $ cCmpFil } )

	If TafColumnPos('T87_DTRANS')
		cCmpFil := 'T87_DINSIS|T87_DTRANS|T87_HTRANS|T87_DTRECP|T87_HRRECP|'
		oStruT87g := FwFormStruct( 2, 'T87', {|x| AllTrim( x ) + "|" $ cCmpFil } )
	EndIf

	/*--------------------------------------------------------------------------------------------
			Grupo de campos da Convoca��o para Trabalho Intermitente
	---------------------------------------------------------------------------------------------*/
	oStruT87a:AddGroup( "GRP_IDENTIFICACAO", STR0007, "", 1 ) //"Informa��es de Identifica��o do Trabalhador e do V�nculo" 

	aCmpGrp := StrToKArr(cGrupo1,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT87a:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_IDENTIFICACAO")
	Next nI

	oStruT87b:AddGroup( "GRP_CONVOCACAO", STR0008, "", 1 ) //"Informa��es da convoca��o para trabalho intermitente"

	aCmpGrp := StrToKArr(cGrupo2,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT87b:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_CONVOCACAO")
	Next nI

	oStruT87c:AddGroup( "GRP_JORNADA", STR0009, "", 1 ) //"Informa��es da(s) jornada(s) di�ria(s) da presta��o de trabalho intermitente"

	aCmpGrp := StrToKArr(cGrupo3,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT87c:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_JORNADA")
	Next nI

	oStruT87d:AddGroup( "GRP_LOCALP", STR0010, "", 1 ) //"Informa��es do local da presta��o de trabalho intermitente"

	aCmpGrp := StrToKArr(cGrupo4,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT87d:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_LOCALP")
	Next nI

	oStruT87e:AddGroup( "GRP_LOCALT", STR0011, "", 1 ) //"Informa��es do local de trabalho intermitente"

	aCmpGrp := StrToKArr(cGrupo5,"|")
	For nI := 1 to Len(aCmpGrp)
		oStruT87e:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_LOCALT")
	Next nI

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruT87f,"T87")
	EndIf

	/*--------------------------------------------------------------------------------------------
											Esrutura da View
	---------------------------------------------------------------------------------------------*/
	oView:AddField( 'VIEW_T87a', oStruT87a, 'MODEL_T87' )
	oView:AddField( 'VIEW_T87b', oStruT87b, 'MODEL_T87' )
	oView:AddField( 'VIEW_T87c', oStruT87c, 'MODEL_T87' )
	oView:AddField( 'VIEW_T87d', oStruT87d, 'MODEL_T87' )
	oView:AddField( 'VIEW_T87e', oStruT87e, 'MODEL_T87' )
	oView:AddField( 'VIEW_T87f', oStruT87f, 'MODEL_T87' )

	If FindFunction("TafNmFolder")
		oView:EnableTitleView( 'VIEW_T87f', TafNmFolder("recibo",1) ) // "Recibo da �ltima Transmiss�o"  
	EndIf 

	If TafColumnPos('T87_DTRANS')
		oView:AddField( 'VIEW_T87g', oStruT87g, 'MODEL_T87' )
		oView:EnableTitleView( 'VIEW_T87g', TafNmFolder("recibo",2) )
	EndIf

	/*--------------------------------------------------------------------------------------------
										Estrutura do Folder
	---------------------------------------------------------------------------------------------*/
	oView:CreateHorizontalBox("PAINEL_SUPERIOR",100)
	oView:CreateFolder("FOLDER_SUPERIOR","PAINEL_SUPERIOR")

	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0001 )   //"Convoca��o para Trabalho Intermitente"

	If FindFunction("TafNmFolder")
		oView:AddSheet( 'FOLDER_SUPERIOR', "ABA02", TafNmFolder("recibo") )   //"Numero do Recibo"
	Else
		oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0012 )   //Protocolo de transmiss�o
	EndIf 

	oView:CreateHorizontalBox( 'T87a',  015,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateHorizontalBox( 'T87b',  015,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateHorizontalBox( 'T87c',  015,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateHorizontalBox( 'T87d',  010,,, 'FOLDER_SUPERIOR', 'ABA01' )
	oView:CreateHorizontalBox( 'T87e',  045,,, 'FOLDER_SUPERIOR', 'ABA01' )
	If TafColumnPos('T87_DTRANS')
		oView:CreateHorizontalBox( 'T87f',  20,,, 'FOLDER_SUPERIOR', 'ABA02' ) 
		oView:CreateHorizontalBox( 'T87g',  80,,, 'FOLDER_SUPERIOR', 'ABA02' ) 
	Else
		oView:CreateHorizontalBox( 'T87f',  100,,, 'FOLDER_SUPERIOR', 'ABA02' ) // folder do _PROTUL
	EndIf

	oView:SetOwnerView( "VIEW_T87a", "T87a")
	oView:SetOwnerView( "VIEW_T87b", "T87b")
	oView:SetOwnerView( "VIEW_T87c", "T87c")
	oView:SetOwnerView( "VIEW_T87d", "T87d")
	oView:SetOwnerView( "VIEW_T87e", "T87e")
	oView:SetOwnerView( "VIEW_T87f", "T87f")
	If TafColumnPos('T87_DTRANS')
		oView:SetOwnerView( "VIEW_T87g", "T87g")
	EndIf

	lMenuDIf := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDIf )

	oStruT87a:RemoveField( "T87_ID" )

	If !lMenuDif
		xFunRmFStr(@oStruT87a, 'T87')
		xFunRmFStr(@oStruT87b, 'T87')
		xFunRmFStr(@oStruT87c, 'T87')
		xFunRmFStr(@oStruT87d, 'T87')
		xFunRmFStr(@oStruT87e, 'T87')
		xFunRmFStr(@oStruT87f, 'T87')
		
	EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Jos� Rimarach�n D�az
@since 09/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel as Object)

	Local aGrava     as Array
	Local cChvRegAnt as Character
	Local cEvento    as Character
	Local cProtocolo as Character
	Local cVerAnt    as Character
	Local cVersao    as Character
	Local lRetorno   as Logical
	Local nlI        as Numeric
	Local nOperation as Numeric
	Local oModelT87  as Object

	Default oModel   := Nil

	aGrava     := {}
	cChvRegAnt := ""
	cEvento    := ""
	cProtocolo := ""
	cVerAnt    := ""
	cVersao    := ""
	lRetorno   := .T.
	nlI        := 0
	nOperation := oModel:GetOperation()
	oModelT87  := Nil

	//Controle se o evento � extempor�neo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		If nOperation == MODEL_OPERATION_INSERT

			TafAjustID( "T87", oModel)

			oModel:LoadValue( 'MODEL_T87', 'T87_VERSAO', xFunGetVer() )

			If Findfunction("TAFAltMan")
				TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T87', 'T87_LOGOPE' , '2', '' )
			Endif

			FwFormCommit( oModel )

		ElseIf nOperation == MODEL_OPERATION_UPDATE

			//�����������������������������������������������������������������Ŀ
			//�Seek para posicionar no registro antes de realizar as validacoes,�
			//�visto que quando nao esta pocisionado nao eh possivel analisar   �
			//�os campos nao usados como _STATUS                                �
			//�������������������������������������������������������������������
			T87->( DbSetOrder( 4 ) )
			If lGoExtemp .OR. T87->( MsSeek( xFilial( 'T87' ) + M->T87_ID + '1' ) )

				//������������������������������������������������Ŀ
				//�Se o registro ja foi transmitido com sucesso    �
				//��������������������������������������������������
				If T87->T87_STATUS ==  "4"

					oModelT87 := oModel:GetModel( 'MODEL_T87' )

					//�����������������������������������������������������������Ŀ
					//�Busco a versao anterior do registro para gravacao do rastro�
					//�������������������������������������������������������������
					cVerAnt    	:= oModelT87:GetValue( "T87_VERSAO" )
					cProtocolo 	:= oModelT87:GetValue( "T87_PROTUL" )
					cEvento		:= oModelT87:GetValue( "T87_EVENTO" )

					If TafColumnPos( "T87_LOGOPE" )
						cLogOpeAnt := oModelT87:GetValue( "T87_LOGOPE" )
					endif

					//�����������������������������������������������������������������Ŀ
					//�Neste momento eu gravo as informacoes que foram carregadas       �
					//�na tela, pois neste momento o usuario ja fez as modificacoes que �
					//�precisava e as mesmas estao armazenadas em memoria, ou seja,     �
					//�nao devem ser consideradas neste momento                         �
					//�������������������������������������������������������������������
					For nlI := 1 to Len( oModelT87:aDataModel[ 1 ] )
						Aadd( aGrava, { oModelT87:aDataModel[ 1, nlI, 1 ], oModelT87:aDataModel[ 1, nlI, 2 ] } )
					Next nlI

					//�����������������������������������������������������������Ŀ
					//�Seto o campo como Inativo e gravo a versao do novo registro�
					//�no registro anterior                                       �
					//|                                                           |
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//�������������������������������������������������������������
					FAltRegAnt( 'T87', '2' )	

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
					For nlI := 1 To Len( aGrava )
						oModel:LoadValue( 'MODEL_T87', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
					Next

					//Necess�rio Abaixo do For Nao Retirar
					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T87', 'T87_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					//�������������������������������Ŀ
					//�Busco a versao que sera gravada�
					//���������������������������������
					cVersao := xFunGetVer()

					//�����������������������������������������������������������Ŀ
					//|ATENCAO -> A alteracao destes campos deve sempre estar     |
					//|abaixo do Loop do For, pois devem substituir as informacoes|
					//|que foram armazenadas no Loop acima                        |
					//�������������������������������������������������������������
					oModel:LoadValue( 'MODEL_T87', 'T87_VERSAO', cVersao )
					oModel:LoadValue( 'MODEL_T87', 'T87_VERANT', cVerAnt )
					oModel:LoadValue( 'MODEL_T87', 'T87_PROTPN', cProtocolo )
					oModel:LoadValue( 'MODEL_T87', 'T87_PROTUL', "" )  

					oModel:LoadValue( "MODEL_T87", "T87_EVENTO", "A" )
					// Tratamento para limpar o ID unico do xml
					cAliasPai := "T87"
					If TAFColumnPos( cAliasPai+"_XMLID" )
						oModel:LoadValue( 'MODEL_'+cAliasPai, cAliasPai+'_XMLID', "" )
					EndIf

					//Gravo altera��o para o Extempor�neo
					If lGoExtemp
						TafGrvExt( oModel, 'MODEL_T87', 'T87' )			
					Endif	

					FwFormCommit( oModel )
					TAFAltStat( 'T87', " " )

				ElseIf	T87->T87_STATUS == "2"
					TAFMsgVldOp(oModel,"2")//"Registro n�o pode ser alterado. Aguardando processo da transmiss�o."
					lRetorno:= .F.
				ElseIf T87->T87_STATUS == "6"
					TAFMsgVldOp(oModel,"6")//"Registro n�o pode ser alterado. Aguardando proc. Transm. evento de Exclus�o S-3000"
					lRetorno:= .F.
				ElseIf T87->T87_STATUS == "7"
					TAFMsgVldOp(oModel,"7") //"Registro n�o pode ser alterado, pois o evento j� se encontra na base do RET"
					lRetorno:= .F.
				Else
					If TafColumnPos( "T87_LOGOPE" )
						cLogOpeAnt := T87->T87_LOGOPE
					EndIf

					//Gravo altera��o para o Extempor�neo
					If lGoExtemp
						TafGrvExt( oModel, 'MODEL_T87', 'T87' )			
					EndIf

					If Findfunction("TAFAltMan")
						TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T87', 'T87_LOGOPE' , '' , cLogOpeAnt )
					EndIf

					FwFormCommit( oModel )
					TAFAltStat( 'T87', " " )
				EndIf
			EndIf

		//Exclus�o Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_DELETE

			cChvRegAnt := T87->(T87_ID + T87_VERANT)

			If !Empty( T87->T87_VERANT )
				
				TAFAltStat( 'T87', " " )
				FwFormCommit( oModel )
				
				If T87->T87_EVENTO == "A" .Or. T87->T87_EVENTO == "E"
					TAFRastro( 'T87', 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
				EndIf

			Else

				oModel:DeActivate()
				oModel:SetOperation( 5 )
				oModel:Activate()
				FwFormCommit( oModel )
				
			EndIf

		EndIf

	End Transaction

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF484Xml
Funcao de geracao do XML para atender o registro S-2260
Quando a rotina for chamada o registro deve estar posicionado

@Param:
cAlias - Alias da Tabela
nRecno - Recno do Registro corrente
nOpc   - Operacao a ser realizada
lJob   - Informa se foi chamado por Job

@Return:
cXml - Estrutura do Xml do Layout S-2260


@author Jos� Rimarach�n D�az
@since 06/11/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF484Xml(cAlias as Character, nRecno as Numeric, nOpc as Numeric, lJob as Logical, lAutomato as Logical, cFile as Character)

	Local cLayout as Character
	Local cReg    as Character
	Local cXml    as Character
	Local lXmlVLd as Logical

	Default cAlias    := "T87"
	Default cFile     := ""
	Default lAutomato := .F.
	Default lJob      := .F.
	Default nOpc      := 1
	Default nRecno    := 1

	cLayout := "2260"
	cReg    := "ConvInterm"
	cXml    := ""
	lXmlVLd := IIF(FindFunction( 'TafXmlVLD' ),TafXmlVLD( 'TAF484XML' ),.T.)

	DBSelectArea("C9V")
	C9V->(DBSetOrder(2))

	If lXmlVLd

		cXml +=	"<ideVinculo>"

		If C9V->( MSSeek( xFilial("C9V") + T87->T87_TRABAL + "1" ) )
			cXml +=	xTafTag("cpfTrab"		,C9V->C9V_CPF)
			cXml +=	xTafTag("nisTrab"		,C9V->C9V_NIS)
			cXml +=	xTafTag("matricula"	,C9V->C9V_MATRIC)
		EndIf

		cXml +=	"</ideVinculo>"

		cXml +=	"<infoConvInterm>"
		cXml +=		xTafTag("codConv"	 	,T87->T87_CONVOC)
		cXml +=		xTafTag("dtInicio"	,T87->T87_DTINIP)
		cXml +=		xTafTag("dtFim"	 	,T87->T87_DTFIMP)
		cXml +=	    xTafTag("dtPrevPgto"	,T87->T87_DTPREV)

		cXml +=		"<jornada>"
		cXml += 			xTafTag("codHorContrat",POSICIONE("C90",1, xFilial("C90")+T87->T87_CODHOR,"C90_CODIGO"),,.T.)
		cXml += 			xTafTag("dscJornada",T87->T87_DTPJOR,,.T.)
		cXml +=		"</jornada>"

		cXml +=		"<localTrab>"
		cXml +=			xTafTag("indLocal",T87->T87_LOCTRB)

		//A fun��o FwCutOff, � usada para tratamento de caractere especial

		cUf		:= posicione( "C09" , 3 , xFilial( "C09" ) + T87->T87_UF , "C09_CODIGO" )
		cMun	:= posicione( "C07" , 3 , xFilial( "C07" ) + T87->T87_MUN , "C07_CODIGO" )

		xTafTagGroup("localTrabInterm";	
					,{{"tpLograd"	,Posicione("C06",3,xFilial("C06")+T87->T87_TPLOGR,"C06_CESOCI")		,,.F.};
					, {"dscLograd"	,SubStr(FwCutOff(T87->T87_LOGRAD, .T.), 1, 100)						,,.F.};
					, {"nrLograd"	,T87->T87_NRLOG 													,,.F.};
					, {"complem"	,FwCutOff(T87->T87_COMLOG, .T.)										,,.T.};
					, {"bairro"		,FwCutOff(T87->T87_BAIRRO, .T.)										,,.T.};
					, {"cep"		,T87->T87_CEP														,,.F.};
					, {"codMunic"	,cUf + cMun															,,.F.};
					, {"uf"			,POSICIONE("C09",3, xFilial("C09")+T87->T87_UF,"C09_UF")			,,.F.}};
					, @cXml)
			
		cXml +=		"</localTrab>"
			
		cXml +=	"</infoConvInterm>"

		//����������������������Ŀ
		//�Estrutura do cabecalho�
		//������������������������
		cXml := xTafCabXml(cXml,"T87",cLayout,cReg)

		//����������������������������Ŀ
		//�Executa gravacao do registro�
		//�����������������������������*/
		If !lJob
			If lAutomato
				xTafGerXml( cXml, cLayout,,, .F.,, @cFile )
			Else
				xTafGerXml( cXml, cLayout )
			EndIf
		EndIf
	EndIf

Return(cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF484Grv
Funcao de gravacao para atender o registro S-2260

@parametros:
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

@author Jos� Rimarach�n D�az
@since 06/11/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF484Grv( cLayout as Character, nOpc as Numeric, cFilEv as Character, oXML as Object, cOwner as Character, cFilTran as Character,;
					cPredeces as Character, nTafRecno as Numeric, cComplem as Character, cGrpTran as Character, cEmpOriGrp as Character,;
					cFilOriGrp as Character, cXmlID as Character )

	Local aChave     as Array
	Local aIncons    as Array
	Local aRules     as Array
	Local cChave     as Character
	Local cCmpsNoUpd as Character
	Local cCodEvent  as Character
	Local cInconMsg  as Character
	Local lRet       as Logical
	Local nlI        as Numeric
	Local nSeqErrGrv as Numeric
	Local oModel     as Object

	Private lVldModel  as Logical
	Private oDados     as Object

	Default cLayout    := ""
	Default nOpc       := 1
	Default cFilEv     := ""
	Default oXML       := Nil
	Default cOwner     := ""
	Default cFilTran   := ""
	Default cPredeces  := ""
	Default nTafRecno  := 0
	Default cComplem   := ""
	Default cGrpTran   := ""
	Default cEmpOriGrp := ""
	Default cFilOriGrp := ""
	Default cXmlID     := ""

	aChave     := {}
	aIncons    := {}
	aRules     := {}
	cChave     := ""
	cCmpsNoUpd := "|T87_FILIAL|T87_ID|T87_VERSAO|T87_VERANT|T87_PROTPN|T87_EVENTO|T87_STATUS|T87_ATIVO|"
	cCodEvent  := Posicione("C8E",2,xFilial("C8E")+"S-"+cLayout,"C8E->C8E_ID")
	cInconMsg  := ""
	lRet       := .F.
	nlI        := 0
	nSeqErrGrv := 0
	oModel     := Nil

	lVldModel  := .T. //Caso a chamada seja via integracao seto a variavel de controle de validacao como .T.
	oDados     := oXML

	Aadd( aChave, { "C", "T87_TRABAL", FGetIdInt("cpfTrab", "matricula","/eSocial/evtConvInterm/ideVinculo/cpfTrab",;
		"/eSocial/evtConvInterm/ideVinculo/matricula"), .T. } )
	cChave := 	AllTrim(aChave[1,3]) + Space(TamSX3("T87_TRABAL")[1] - Len(aChave[1,3]))

	Aadd( aChave, { "C", "T87_CONVOC", FTafGetVal( "/eSocial/evtConvInterm/infoConvInterm/codConv", "C", .F., @aIncons, .F. ), .T.}  )

	cChave 	+= 	AllTrim(aChave[2,3]) + Space(TamSX3("T87_CONVOC")[1] - Len(aChave[2,3]))
	nIndice 	:= 2

	//Verifica se o evento ja existe na base
	DbSelectArea("T87")
	T87->(DbSetOrder(2))
	If (T87->(DbSeek(xFilial("T87") + cChave + "1")))
		If !(T87->T87_STATUS $ "2|4|9")
			nOpc := 4
		Endif
	Endif

	Begin Transaction

		//Funcao para validar se a operacao desejada pode ser realizada
		If FTafVldOpe( 'T87', nIndice, @nOpc, cFilEv, @aIncons, aChave, @oModel, 'TAFA484', cCmpsNoUpd,1 )

			If TafColumnPos( "T87_LOGOPE" )
				cLogOpeAnt := T87->T87_LOGOPE
			EndIf

			//���������������������������������������������������������������Ŀ
			//�Carrego array com os campos De/Para de gravacao das informacoes�
			//�����������������������������������������������������������������
			aRules := TAF484Rul( cLayout, @cInconMsg, @nSeqErrGrv, cCodEvent, cOwner )

			//����������������������������������������������������������������Ŀ
			//�Quando se tratar de uma Exclusao direta apenas preciso realizar �
			//�o Commit(), nao eh necessaria nenhuma manutencao nas informacoes�
			//������������������������������������������������������������������
			If nOpc <> 5
				oModel:LoadValue( "MODEL_T87", "T87_FILIAL", T87->T87_FILIAL )

				If TAFColumnPos( "T87_XMLID" )
					oModel:LoadValue( "MODEL_T87", "T87_XMLID", cXmlID )
				EndIf			

				//����������������������������������������Ŀ
				//�Rodo o aRules para gravar as informacoes�
				//������������������������������������������
				For nlI := 1 To Len( aRules )
					oModel:LoadValue( "MODEL_T87", aRules[ nlI, 01 ], FTafGetVal( aRules[ nlI, 02 ], aRules[nlI, 03], aRules[nlI, 04], @aIncons, .F. ) )
				Next

				If Findfunction("TAFAltMan")
					If nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T87', 'T87_LOGOPE' , '1', '' )
					ElseIf nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T87', 'T87_LOGOPE' , '', cLogOpeAnt )
					EndIf
				EndIf
			EndIf

			//���������������������������Ŀ
			//�Efetiva a operacao desejada�
			//�����������������������������
			If Empty(cInconMsg) .And. Empty(aIncons)
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
		EndIf

	End Transaction

	//����������������������������������������������������������Ŀ
	//�Zerando os arrays e os Objetos utilizados no processamento�
	//������������������������������������������������������������
	aSize( aRules, 0 )
	aRules	:= Nil

	aSize( aChave, 0 )
	aChave	:= Nil
	oModel	:= Nil

Return { lRet, aIncons }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF484Rul
Regras para gravacao das informacoes do registro S-2260

@Param
nOper      - Operacao a ser realizada ( 3 = Inclusao / 4 = Alteracao / 5 = Exclusao )

@Return
aRull  - Regras para a gravacao das informacoes

@author Jos� Rimarach�n D�az
@since 31/102017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function TAF484Rul( cTagOper as Character, cInconMsg as Character, nSeqErrGrv as Numeric, cCodEvent as Character, cOwner as Character )

	Local aRull        as Array

	Default cCodEvent  := ""
	Default cInconMsg  := ""
	Default cOwner     := ""
	Default cTagOper   := ""
	Default nSeqErrGrv := 0

	aRull := {}

	// Campos da tabela T87
	If TafXNode( oDados, cCodEvent, cOwner,("matricula","/eSocial/evtConvInterm/ideVinculo/cpfTrab") ) .or. TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/ideVinculo/matricula") )
		Aadd( aRull, { "T87_TRABAL", FGetIdInt( "cpfTrab","matricula","/eSocial/evtConvInterm/ideVinculo/cpfTrab",;
			"/eSocial/evtConvInterm/ideVinculo/matricula",,,@cInconMsg, @nSeqErrGrv), "C", .T. } ) 					
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/codConv") )
		Aadd( aRull, { "T87_CONVOC", "/eSocial/evtConvInterm/infoConvInterm/codConv", "C", .F. } )											
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/dtInicio") )
		Aadd( aRull, { "T87_DTINIP", "/eSocial/evtConvInterm/infoConvInterm/dtInicio", "D", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/dtFim") )
		Aadd( aRull, { "T87_DTFIMP", "/eSocial/evtConvInterm/infoConvInterm/dtFim", "D", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/dtPrevPgto") )
		Aadd( aRull, { "T87_DTPREV", "/eSocial/evtConvInterm/infoConvInterm/dtPrevPgto", "D", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/jornada/codHorContrat") )
		Aadd( aRull, { "T87_CODHOR", FGetIdInt( "codHorContrat", "", "/eSocial/evtConvInterm/infoConvInterm/jornada/codHorContrat",,,,@cInconMsg, @nSeqErrGrv), "C", .T. } )											
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/jornada/dscJornada") )
		Aadd( aRull, { "T87_DTPJOR",  "/eSocial/evtConvInterm/infoConvInterm/jornada/dscJornada", "C", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/localTrab/indLocal") )
		Aadd( aRull, { "T87_LOCTRB",  "/eSocial/evtConvInterm/infoConvInterm/localTrab/indLocal", "C", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/tpLograd") )
		aAdd( aRull, { "T87_TPLOGR", FGetIdInt( "tpLograd", "","/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/tpLograd",,,,@cInconMsg, @nSeqErrGrv ), "C", .T. } ) 							
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/dscLograd") )
		Aadd( aRull, { "T87_LOGRAD",  "/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/dscLograd", "C", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/nrLograd") )
		Aadd( aRull, { "T87_NRLOG",  "/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/nrLograd", "C", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/complem") )
		Aadd( aRull, { "T87_COMLOG",  "/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/complem", "C", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/bairro") )
		Aadd( aRull, { "T87_BAIRRO",  "/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/bairro", "C", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("evtConvInterm","/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/cep") )
		Aadd( aRull, { "T87_CEP",  "/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/cep", "C", .F. } )									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("evtConvInterm","/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/uf") )
		Aadd( aRull,  { "T87_UF", FGetIdInt( "uf", "", "/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/uf",,,,@cInconMsg, @nSeqErrGrv) , "C", .T. } ) 									
	EndIf

	If TafXNode( oDados, cCodEvent, cOwner,("/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/codMunic") )
		Aadd( aRull, {"T87_MUN", +; 
					FGetIdInt( "codMunic", "uf", +; 
					"/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/uf", +; 
					"/eSocial/evtConvInterm/infoConvInterm/localTrab/localTrabInterm/codMunic",,,@cInconMsg, @nSeqErrGrv), "C", .T. } )								
	EndIf
	
Return ( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarEvtExc
Funcao que gera a exclus�o do evento (S-3000)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno
@Param  lRotExc -> Variavel que controla se a function � chamada pelo TafIntegraESocial

@Return .T.

@author denis.oliveira
@since 29/06/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarEvtExc( oModel as Object, nRecno as Numeric, lRotExc as Logical )

	Local aGrava     as Array
	Local cEvento    as Character
	Local cProtocolo as Character
	Local cVerAnt    as Character
	Local cVersao    as Character
	Local nlI        as Numeric
	Local nlY        as Numeric
	Local oModelT87  as Object

	Default oModel   := Nil
	Default nRecno   := 0
	Default lRotExc  := .F.

	aGrava     := {}
	cEvento    := ""
	cProtocolo := ""
	cVerAnt    := ""
	cVersao    := ""
	nlI        := 0
	nlY        := 0
	oModelT87  := Nil

	//Controle se o evento � extempor�neo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	Begin Transaction

		//Posiciona o item
		("T87")->( DBGoTo( nRecno ) )

		oModelT87	:= oModel:GetModel( 'MODEL_T87' )

		//�����������������������������������������������������������Ŀ
		//�Busco a versao anterior do registro para gravacao do rastro�
		//�������������������������������������������������������������
		cVerAnt   	:= oModelT87:GetValue( "T87_VERSAO" )
		cProtocolo	:= oModelT87:GetValue( "T87_PROTUL" )
		cEvento	:= oModelT87:GetValue( "T87_EVENTO" )

		//�����������������������������������������������������������������Ŀ
		//�Neste momento eu gravo as informacoes que foram carregadas       �
		//�na tela, pois neste momento o usuario ja fez as modificacoes que �
		//�precisava e as mesmas estao armazenadas em memoria, ou seja,     �
		//�nao devem ser consideradas neste momento                         �
		//�������������������������������������������������������������������
		For nlI := 1 To 1
			For nlY := 1 To Len( oModelT87:aDataModel[ nlI ] )
				Aadd( aGrava, { oModelT87:aDataModel[ nlI, nlY, 1 ], oModelT87:aDataModel[ nlI, nlY, 2 ] } )
			Next
		Next

		//�����������������������������������������������������������Ŀ
		//�Seto o campo como Inativo e gravo a versao do novo registro�
		//�no registro anterior                                       �
		//|                                                           |
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//�������������������������������������������������������������
		FAltRegAnt( 'T87', '2' )

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
		For nlI := 1 To Len( aGrava )
			oModel:LoadValue( 'MODEL_T87', aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
		Next

		//�������������������������������Ŀ
		//�Busco a versao que sera gravada�
		//���������������������������������
		cVersao := xFunGetVer()

		//�����������������������������������������������������������Ŀ
		//|ATENCAO -> A alteracao destes campos deve sempre estar     |
		//|abaixo do Loop do For, pois devem substituir as informacoes|
		//|que foram armazenadas no Loop acima                        |
		//�������������������������������������������������������������
		oModel:LoadValue( 'MODEL_T87', 'T87_VERSAO', cVersao )
		oModel:LoadValue( 'MODEL_T87', 'T87_VERANT', cVerAnt )
		oModel:LoadValue( 'MODEL_T87', 'T87_PROTPN', cProtocolo )
		oModel:LoadValue( 'MODEL_T87', 'T87_PROTUL', "" )

		/*---------------------------------------------------------
		Tratamento para que caso o Evento Anterior fosse de exclus�o
		seta-se o novo evento como uma "nova inclus�o", caso contr�rio o
		evento passar a ser uma altera��o
		-----------------------------------------------------------*/
		oModel:LoadValue( "MODEL_T87", "T87_EVENTO", "E" )
		oModel:LoadValue( "MODEL_T87", "T87_ATIVO" , "1" )

		//Gravo altera��o para o Extempor�neo
		If lGoExtemp
			TafGrvExt( oModel, 'MODEL_T87', 'T87' )	
		EndIf

		FwFormCommit( oModel )	
		TAFAltStat( 'T87',"6" )

	End Transaction

Return ( .T. )
