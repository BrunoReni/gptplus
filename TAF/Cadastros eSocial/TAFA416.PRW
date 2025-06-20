#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA416.CH"

Static lLaySimplif	:= TafLayESoc("S_01_00_00")
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA416
Reabertura dos Eventos Peri�dicos (S-1298)

@author Paulo Santana	
@since 04/01/2016
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA416()

	Private oBrw  := FWmBrowse():New()

	oBrw:SetDescription(STR0001)    //"Reabertura dos Eventos Peri�dicos"
	oBrw:SetAlias( 'T1S')
	oBrw:SetMenuDef( 'TAFA416' )

	If FindFunction('TAFSetFilter')
		oBrw:SetFilterDefault(TAFBrwSetFilter("T1S","TAFA416","S-1298"))
	Else
		oBrw:SetFilterDefault( "T1S_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
	EndIf

	TafLegend(2,"T1S",@oBrw)
	oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Paulo Santana	
@since 04/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao := {}
	Local aRotina := {}

	Aadd( aFuncao, { "" , "TafxmlRet('TAF416Xml','1298','T1S')" 									, "1" } )
	Aadd( aFuncao, { "" , "xFunHisAlt( 'T1S', 'TAFA416' ,,,, 'TAF416XML','1298' )" 					, "3" } )
	Aadd( aFuncao, { "" , "TAFXmlLote( 'T1S', 'S-1298' , 'evtReabreEvPer' , 'TAF416Xml',, oBrw )" 	, "5" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'T1S' )" 													, "10" } )

	lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

	If lMenuDif
		ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA416' OPERATION 2 ACCESS 0
	Else
		aRotina	:=	xFunMnuTAF( "TAFA416" , , aFuncao)
	EndIf

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Paulo Santana	
@since 04/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruT1S
	Local oModel

	oStruT1S  :=  FWFormStruct( 1, 'T1S' )
	oModel    :=  MPFormModel():New( 'TAFA416' ,,,{|oModel| SaveModel(oModel)})

	If TafColumnPos("T1S_TPGUIA") .AND. !lLaySimplif 
		oStruT1S:RemoveField( "T1S_TPGUIA" )
	EndIf

	oModel:AddFields('MODEL_T1S', /*cOwner*/, oStruT1S)

	oModel:GetModel('MODEL_T1S'):SetPrimaryKey({'T1S_FILIAL', 'T1S_ID', 'T1S_VERSAO'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Paulo Santana	
@since 04/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel
	Local oStruT1S
	Local oView
	Local cCmpFil	:= ""
	Local cGrpTra1 	:= ""
	Local cGrpTra2	:= ""
	Local cGrpTra3	:= ""
	Local aCmpGrp 	:= {}
	Local nI		:= 0

	oModel   := FWLoadModel( 'TAFA416' )
	oView    := FWFormView():New()

	oView:SetModel( oModel )

	cGrpTra1 := "T1S_INDAPU|T1S_PERAPU|T1S_TPGUIA|"

	cGrpTra2 := "T1S_PROTUL|"
	If TafColumnPos("T1S_DTRANS")
		cGrpTra3 := "T1S_DINSIS|T1S_DTRANS|T1S_HTRANS|T1S_DTRECP|T1S_HRRECP|"
	EndIf

	cCmpFil := cGrpTra1 + cGrpTra2 + cGrpTra3

	oStruT1S := FwFormStruct( 2, "T1S",{ |x| AllTrim( x ) + "|" $ cCmpFil } )

	If FindFunction("TafAjustRecibo")
		TafAjustRecibo(oStruT1S,"T1S")
	EndIf

	If TafColumnPos("T1S_TPGUIA") .AND. !lLaySimplif 
		oStruT1S:RemoveField( "T1S_TPGUIA" )
	EndIf

	If TafColumnPos("T1S_DTRANS")
		oStruT1S:AddGroup( "GRP_TRABALHADOR_01", TafNmFolder("recibo",1), "", 1 ) //Recibo da �ltima Transmiss�o
		oStruT1S:AddGroup( "GRP_TRABALHADOR_02", TafNmFolder("recibo",2), "", 1 ) //Informa��es de Controle eSocial

		oStruT1S:SetProperty(Strtran(cGrpTra2,"|",""),MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_01")
		
		aCmpGrp := StrToKArr(cGrpTra3,"|")
		For nI := 1 to Len(aCmpGrp)
			oStruT1S:SetProperty(aCmpGrp[nI],MVC_VIEW_GROUP_NUMBER,"GRP_TRABALHADOR_02")
		Next nI
	EndIf                 

	oView:AddField( 'VIEW_T1S', oStruT1S, 'MODEL_T1S' )
	oView:EnableTitleView( 'VIEW_T1S', STR0001)//"Reabertura dos Eventos Peri�dicos"

	oView:CreateHorizontalBox( 'FIELDST1S', 100)  

	oView:SetOwnerView( 'VIEW_T1S', 'FIELDST1S' )

	xFunRmFStr(oStruT1S, 'T1S')//Retira campos de controle da visualiza��o da tela

	If TafColumnPos( "T1S_LOGOPE" )
		oStruT1S:RemoveField( "T1S_LOGOPE" )
	EndIf

Return oView

//-------------------------------------------------------------------	
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo	

@author Paulo Santana	
@since 04/01/2016
@version 1.0
		
@param  oModel - Modelo de dados
@return .T.
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

	Local cVerAnt       as character
	Local cProtocolo    as character
	Local cVersao       as character
	Local cEvento       as character
	Local cChvRegAnt    as character
	Local cLogOpe       as character
	Local cLogOpeAnt    as character
	Local cChave1   	as character
	Local cChave2  		as character
	Local cId       	as character
	Local nX,nY 		as numeric
	Local nInd			as numeric
	Local nOperation 	as numeric
	Local aGrava		as array
	Local oModelT1S		as object
	Local lRetorno 		as logical
	
	cVerAnt    := ""
	cProtocolo := ""
	cVersao    := ""
	cEvento    := ""
	cChvRegAnt := ""
	cLogOpe    := ""
	cLogOpeAnt := ""
	cChave1    := ""
	cChave2    := ""
	cId        := ""
	nX         := 0
	nY         := 0
	nInd       := 0
	nOperation := oModel:GetOperation()
	oModelT1S  := oModel:GetModel("MODEL_T1S")
	aGrava     := {}
	lRetorno   := .T.
	
	Begin Transaction	

		If nOperation == MODEL_OPERATION_INSERT

			cChave1 := cChave2 := xFilial( 'T1S' ) + FWFLDGET("T1S_INDAPU") + FWFLDGET("T1S_PERAPU")

			If lLaySimplif
				cChave1 += FWFLDGET("T1S_TPGUIA") +  '1'
				cChave2 += IIf(empty(FWFLDGET("T1S_TPGUIA")),"1"," ") +  '1'
				nInd := 4
			Else
				cChave1 += '1'
				nInd := 2
			EndIf

			T1S->( DbSetOrder( nInd ) )
			If T1S->( DbSeek( cChave1 ) ) .OR. T1S->( DbSeek( cChave2 ) )
			   	If T1S->T1S_STATUS == "4"

					cId  		:= T1S->T1S_ID 
					cChvRegAnt 	:= T1S->T1S_VERSAO
					cLogOpeAnt  := T1S->T1S_LOGOPE

					oModel:LoadValue( "MODEL_T1S", "T1S_ID", cId )	
					oModel:LoadValue( "MODEL_T1S", "T1S_VERANT", cChvRegAnt )
				    oModel:LoadValue( 'MODEL_T1S', 'T1S_VERSAO', xFunGetVer() )
					
					FAltRegAnt('T1S', '2')
					TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T1S', 'T1S_LOGOPE' , '2' , cLogOpeAnt )
					FwFormCommit( oModel )
					TAFAltStat( "T1S", " " )
				Else
					oModel:SetErrorMessage(, , , , , "Registro j� se encontra na base com status pendente de transmiss�o.", , , )
					lRetorno := .F.
				EndIf
			Else
				TafAjustID( "T1S", oModel)

				oModel:LoadValue( 'MODEL_T1S', 'T1S_VERSAO', xFunGetVer() )

				If Findfunction("TAFAltMan")
					TAFAltMan( 3 , 'Save' , oModel, 'MODEL_T1S', 'T1S_LOGOPE' , '2', '' )
				Endif

				FwFormCommit( oModel )
			EndIf
		
		ElseIf nOperation == MODEL_OPERATION_UPDATE
		//�����������������������������������������������������������������Ŀ
		//�Seek para posicionar no registro antes de realizar as validacoes,�
		//�visto que quando nao esta pocisionado nao eh possivel analisar   �
		//�os campos nao usados como _STATUS                                �
		//�������������������������������������������������������������������
		T1S->( DbSetOrder( 3 ) )
		If T1S->( MsSeek( xFilial( 'T1S' ) + FwFldGet("T1S_ID") + '1' ) )
					
			If T1S->T1S_STATUS == "4"
					
				oModel:SetErrorMessage(, , , , , "Registro n�o pode ser alterado, pois o evento j� se encontra na base do RET", , , )//"Registro n�o pode ser alterado, pois o evento j� se encontra na base do RET"
				lRetorno := .F.

			ElseIf T1S->T1S_STATUS == "2"

				TAFMsgVldOp( oModel, "2" )//"Registro n�o pode ser alterado. Aguardando processo da transmiss�o."
				lRetorno := .F.

			Else
				//altera��o sem transmiss�o
				If TafColumnPos( "T1S_LOGOPE" )
					cLogOpeAnt := T1S->T1S_LOGOPE
				endif
			EndIf

			If lRetorno	
				If Findfunction("TAFAltMan")
					TAFAltMan( 4 , 'Save' , oModel, 'MODEL_T1S', 'T1S_LOGOPE' , '' , cLogOpeAnt )
				EndIf
				FwFormCommit( oModel )
				TAFAltStat( 'T1S', " " )
			EndIf	
		EndIf
			
		//Exclus�o Manual do Evento
		ElseIf nOperation == MODEL_OPERATION_DELETE

			If T1S->T1S_STATUS == "4"

				oModel:SetErrorMessage(, , , , , xValStrEr("000783"), , , ) //"Registro n�o pode ser exclu�do, pois o evento j� se encontra base do RET"  
				lRetorno := .F.
			
			Else
		
				cChvRegAnt := T1S->(T1S_ID + T1S_VERANT)  	  

				TAFAltStat( 'T1S', " " )
				FwFormCommit( oModel )
				TAFRastro( 'T1S', 1, cChvRegAnt, .T. , , IIF(Type("oBrw") == "U", Nil, oBrw) )
	
			EndIf

		EndIf 

	End Transaction     

Return ( lRetorno )	 
	
//-------------------------------------------------------------------	
/*/{Protheus.doc} TAF416Xml
Retorna o Xml do Registro Posicionado 
	
@author Evandro dos Santos Oliveira
@since 28/10/2013
@version 1.0
		
@Param:
lJob - Informa se foi chamado por Job

@return
cXml - Estrutura do Xml do Layout S-1298 
/*/
//-------------------------------------------------------------------
Function TAF416Xml(cAlias,nRecno,nOpc,lJob)

	Local cXml
	Local cLayout
	Local cReg
	Local aMensal

	cXml    := ""
	cLayout := "1298"
	cReg	:= "ReabreEvPer"

	If !lLaySimplif
		If T1S->T1S_INDAPU == '1'
			aMensal := {T1S->T1S_INDAPU,substr(T1S->T1S_PERAPU,1,4) + "-" + substr(T1S->T1S_PERAPU,5,2)}
		Else
			aMensal := {T1S->T1S_INDAPU,substr(T1S->T1S_PERAPU,1,4)}
		EndIf
	Else
		If T1S->T1S_INDAPU == '1'
			aMensal := {T1S->T1S_INDAPU,substr(T1S->T1S_PERAPU,1,4) + "-" + substr(T1S->T1S_PERAPU,5,2),T1S->T1S_TPGUIA}
		Else
			aMensal := {T1S->T1S_INDAPU,substr(T1S->T1S_PERAPU,1,4),T1S->T1S_TPGUIA}
		EndIf
	EndIf

	//����������������������Ŀ
	//�Estrutura do cabecalho�
	//������������������������
	cXml := xTafCabXml(cXml,"T1S", cLayout,cReg, aMensal)

	//����������������������������Ŀ
	//�Executa gravacao do registro�
	//������������������������������
	If !lJob
		xTafGerXml(cXml,cLayout)
	EndIf
	
Return(cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF416Grv
@type			function
@description	
@author			Evandro dos Santos Oliveira
@since			25/10/2013
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
Function TAF416Grv( cLayout, nOpc, cFilEv, oXML, cOwner, cFilTran, cPredeces, nTafRecno, cComplem, cGrpTran, cEmpOriGrp, cFilOriGrp, cXmlID )

	Local cLogOpeAnt   := ""
	Local cCmpsNoUpd   := "|T1S_FILIAL|T1S_ID|T1S_VERSAO|T1S_VERANT|T1S_PROTUL|T1S_PROTPN|T1S_EVENTO|T1S_STATUS|T1S_ATIVO|"
	Local cCabec       := "/eSocial/evtReabreEvPer"
	Local lRet         := .F.
	Local aIncons      := {}
	Local aChave       := {}
	Local oModel       := Nil
	Local IndApu       := ""
	Local PerApu       := ""
	Local cIndGuia     := ""
	Local nInd         := 2
 
	Private oDados     := Nil
	Private lVldModel  := .T. //Caso a chamada seja via integra��o, seto a vari�vel de controle de valida��o como .T.

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

	oDados := oXML

	If lLaySimplif

		nInd := 4

	EndIf
	
	If nOpc <> 5

		Aadd( aChave, { "C", "T1S_INDAPU"	, cCabec + "/ideEvento/indApuracao", .F. } )
		aAdd( aChave, { "C", "T1S_PERAPU", StrTran(FTafGetVal( cCabec + "/ideEvento/perApur", "C", .F., @aIncons, .F. ),"-",""), .T. } )
		
		If lLaySimplif			
			aAdd( aChave, { "C", "T1S_TPGUIA", cCabec + "/ideEvento/indGuia", .F. } )
		EndIf
		
		//Verifica se o evento ja existe na base
		IndApu		:= FTafGetVal( aChave[ 01, 03 ], aChave[01, 01], aChave[01, 04], @aIncons, .F. )
		PerApu		:= aChave[ 02, 03 ]
		
		If lLaySimplif	
			cIndGuia	:= FTafGetVal( aChave[ 03, 03 ], aChave[03, 01], aChave[03, 04], @aIncons, .F. )
		EndIf

		If !lLaySimplif

			("T1S")->( DbSetOrder( 2 ) )
			If ("T1S")->( MsSeek( xFilial("T1S") + IndApu + PadR(PerApu, GetSx3Cache("T1S_PERAPU", "X3_TAMANHO")) + "1" ) )
				nOpc := 4
			EndIf

		Else

			("T1S")->( DbSetOrder( 4 ) )
			If ("T1S")->( MsSeek( xFilial("T1S") + IndApu + PadR(PerApu, GetSx3Cache("T1S_PERAPU", "X3_TAMANHO")) + PadR(cIndGuia, GetSx3Cache("T1S_TPGUIA", "X3_TAMANHO")) + "1" ) )
				nOpc := 4
			EndIf

		EndIf

		Begin Transaction 

			If FTafVldOpe( "T1S", nInd, @nOpc, cFilEv, @aIncons, aChave, @oModel, "TAFA416", cCmpsNoUpd )

				If TafColumnPos( "T1S_LOGOPE" )
					cLogOpeAnt := T1S->T1S_LOGOPE
				EndIf
				
				oModel:LoadValue( "MODEL_T1S", "T1S_FILIAL", T1S->T1S_FILIAL )															
				oModel:LoadValue( "MODEL_T1S", "T1S_INDAPU", IndApu )
				oModel:LoadValue( "MODEL_T1S", "T1S_PERAPU", PerApu )

				If lLaySimplif
					oModel:LoadValue( "MODEL_T1S", "T1S_TPGUIA", cIndGuia )
				EndIf

				If TAFColumnPos( "T1S_XMLID" )
					oModel:LoadValue( "MODEL_T1S", "T1S_XMLID", cXmlID )
				EndIf

				If Findfunction("TAFAltMan")

					If nOpc == 3
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T1S', 'T1S_LOGOPE' , '1', '' )
					ElseIf nOpc == 4
						TAFAltMan( nOpc , 'Grv' , oModel, 'MODEL_T1S', 'T1S_LOGOPE' , '', cLogOpeAnt )
					EndIf

				EndIf

				/*���������������������������Ŀ
				�Efetiva a operacao desejada�
				�����������������������������*/
				If Empty(aIncons)
					FWFormCommit( oModel )
					lRet := .T.
				EndIf
				
				oModel:DeActivate()
				If FindFunction('TafClearModel')
					TafClearModel(oModel)
				EndIf
		
			EndIf

		End Transaction	

	EndIf

Return { lRet, aIncons }
