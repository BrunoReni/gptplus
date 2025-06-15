#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
 
Static lIntGTP := SuperGetMV("MV_INTGTP",.F.,"0") == "1"
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA119
Lote de Taxas

@sample		GTPA119()

@author 		Flavio Martins	
@since 			21/03/2019
@version 		P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA119()
	
Local oBrowse		:= Nil	

Private aRotina 	:= MenuDef()

oBrowse := FWMBrowse():New()

oBrowse:SetAlias('GQ2')
oBrowse:SetDescription("Lote de Taxas")// "Lote de Taxas"
oBrowse:Activate()

Return ( oBrowse )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu

@sample		MenuDef()

@return		aRotina - Array de opções do menu

@author		Flavio Martins
@since			21/03/2019
@version		P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
	
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.GTPA119' OPERATION 2 ACCESS 0	// 'Visualizar'
ADD OPTION aRotina TITLE 'Gerar Lote' ACTION 'GA119Incl()' OPERATION 3 ACCESS 0		// 'Gerar Lote'
ADD OPTION aRotina TITLE 'Excluir' ACTION 'VIEWDEF.GTPA119' OPERATION 5 ACCESS 0	// 'Excluir'

	If !lIntGTP

		ADD OPTION aRotina TITLE 'Alterar' ACTION 'VIEWDEF.GTPA119' OPERATION 4 ACCESS 0	// 'Alterar'
	
	Endif
	
Return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo de dados.

@sample		ModelDef()

@return		oModel - Modelo de dados.

@author		Flavio Martins
@since			21/03/2019
@version		P12
/*/
//------------------------------------------------------------------------------------------

Static Function ModelDef()
Local oModel	:= Nil
Local oStruGQ2	:= FWFormStruct(1,'GQ2')
Local oStruGQ1	:= FWFormStruct(1,'GQ1')
Local bCommit		:= { |oModel| GA119Commit(oModel)}
Local bLinePost	:= { |oModel| GA119LinhaOK(oModel)}

oStruGQ1:SetProperty("*",MODEL_FIELD_OBRIGAT, .F. )

If !lIntGTP
	oStruGQ2:SetProperty("GQ2_CLIENT",MODEL_FIELD_OBRIGAT, .T. )
	oStruGQ2:SetProperty("GQ2_LOJA",MODEL_FIELD_OBRIGAT, .T. )
EndIf

oModel := MPFormModel():New('GTPA119',/*bPreValid*/,/*bPosValid*/ ,bCommit,/*bCancel*/)
	
oModel:AddFields('GQ2MASTER',/*cOwner*/,oStruGQ2)

oModel:AddGrid('GQ1DETAIL','GQ2MASTER',oStruGQ1, /*bLinePre*/, /*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )

oModel:AddCalc('CALC1', 'GQ2MASTER', 'GQ1DETAIL', 'GQ1_VALOR', 'VALTOT', 'SUM'  , { || .T. },/*bInitValue*/,"Valor Total", /*bFormula*/ )	// "Valor Total"


oModel:GetModel('GQ1DETAIL'):SetMaxLine(999999)
oModel:GetModel('GQ1DETAIL'):SetOptional(.T.)

oModel:SetDescription("Lote de Taxas")	//"Lote de Taxas"
oModel:GetModel('GQ2MASTER'):SetDescription("Lote de Taxas")	//"Lote de Taxas"
oModel:SetPrimaryKey({"GQ2_FILIAL","GQ2_CODIGO"})

oStruGQ1:SetProperty( 'GQ1_CODIGO', MODEL_FIELD_WHEN,{|| .F. } )
oStruGQ2:SetProperty( 'GQ2_VALTOT', MODEL_FIELD_WHEN,{|| .F. } )
oStruGQ2:SetProperty( 'GQ2_STATUS', MODEL_FIELD_WHEN,{|| .F. } )

oModel:SetRelation( 'GQ1DETAIL', { { 'GQ1_FILIAL', 'xFilial( "GQ1" )' }, { 'GQ1_CODGQ2', 'GQ2_CODIGO' } }, GQ1->(IndexKey(2)))
	
Return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface.

@sample		ViewDef()

@return		oView - Retorna a View

@author		Flavio Martins
@since			21/03/2019
@version		P12
/*/
//------------------------------------------------------------------------------------------

Static Function ViewDef()
	
Local oModel		:= ModelDef()
Local oView		:= FWFormView():New()
Local oStruGQ2	:= FWFormStruct(2, 'GQ2')
Local oStruGQ1	:= FWFormStruct(2, 'GQ1')

oStruGQ2:SetProperty('GQ2_CODIGO', MVC_VIEW_CANCHANGE, .F.)

oView:SetModel(oModel)

oView:SetDescription("Lote de Taxas")	//"Lote de Taxas"

oView:AddField('VIEW_GQ2' ,oStruGQ2,'GQ2MASTER')

oView:AddGrid('VIEW_GQ1' ,oStruGQ1,'GQ1DETAIL')

oView:CreateHorizontalBox('HEADER', 30)
oView:CreateHorizontalBox('DETAIL', 70)
oView:SetOwnerView('VIEW_GQ2','HEADER')
oView:SetOwnerView('VIEW_GQ1','DETAIL')

oStruGQ1:RemoveField("GQ1_DESCRI")	
oStruGQ1:RemoveField("GQ1_TIPDOC")	
oStruGQ1:RemoveField("GQ1_DTPDOC")	
oStruGQ1:RemoveField("GQ1_MSBLQL")	
oStruGQ1:RemoveField("GQ1_CODGQ2")	
oStruGQ1:RemoveField("GQ1_DESCRI")	

oStruGQ2:RemoveField("GQ2_FILNF")	
oStruGQ2:RemoveField("GQ2_NOTA")	
oStruGQ2:RemoveField("GQ2_SERIE")	
oStruGQ2:RemoveField("GQ2_STATUS")	

	If !lIntGTP
		oStruGQ2:RemoveField("GQ2_AGENCI")	
		oStruGQ2:RemoveField("GQ2_DESAGE")	
		oStruGQ2:RemoveField("GQ2_TIPDOC")	
		oStruGQ2:RemoveField("GQ2_DSCDOC")			
	Else
		oStruGQ2:RemoveField("GQ2_CLIENT")	
		oStruGQ2:RemoveField("GQ2_LOJA")		
	Endif

Return ( oView )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA119Incl()
Definição da interface.

@sample		ViewDef()

@return		oView - Retorna a View

@author		Flavio Martins
@since			21/03/2019
@version		P12
/*/
//------------------------------------------------------------------------------------------

Function GA119Incl()
Local lRet 		:= .T.
Local oModel
Local oMdlGQ2
Local oMdlGQ1
Local cAliasQry	:= GetNextAlias()
Local cFilGI6		:= ""
Local dDataIni	
Local dDataFim
Local dDataEmi
Local cTipoDoc	:= ""

	If lIntGTP
	
		If (Pergunte("GTPA119",.T.)) .And. VldPerg()
		
			oModel 	:= FwLoadModel("GTPA119")
			oMdlGQ2	:= oModel:GetModel('GQ2MASTER')
			oMdlGQ1	:= oModel:GetModel('GQ1DETAIL')
			
			cTipoDoc	:= mv_par01
			dDataIni	:= mv_par02
			dDataFim	:= mv_par03
			dDataEmi	:= mv_par04
		
			BeginSQL Alias cAliasQry
		
				SELECT G57.G57_CODIGO,
						G57.G57_AGENCI,
						G57.G57_TIPO,
				       G57.G57_SERIE,
				       G57.G57_SUBSER,
				       G57.G57_NUMCOM,
				       G57.G57_VALOR,
				       G57.G57_EMISSA,
				       GI6.GI6_FILRES
				FROM %Table:G57% G57
				INNER JOIN %Table:GI6% GI6 ON GI6.GI6_FILIAL = G57.G57_FILIAL
				AND GI6.GI6_CODIGO = G57.G57_AGENCI
				AND GI6.%NotDel%	
				INNER JOIN %Table:GYA% GYA ON GYA.GYA_CODIGO = G57.G57_TIPO
				AND GYA.%NotDel%	
				WHERE G57.G57_FILIAL = %xFilial:G57%
	  			AND G57.%NotDel%	
	  			AND G57.G57_TIPO = %Exp:cTipoDoc%
	  			AND G57.G57_EMISSA BETWEEN %Exp:dDataIni% AND %Exp:dDataFim%
	  			AND G57.G57_CONFER = '1'	
	  			AND G57.G57_CODGQ1 = ''
	  			
	  			ORDER BY G57.G57_FILIAL, GI6.GI6_FILRES, G57.G57_EMISSA	
	  			
	  		EndSql
	  		
	  		If (cAliasQry)->(Eof())
	  		
	  			FwAlertHelp('Não existem dados para os parâmetros informados.','Verifique se os parâmetros informados estão corretos','Operação não realizada')
	  			
	  			Return
	  		
	  		Endif
	
			While (cAliasQry)->(!Eof())
			
				If cFilGI6 != (cAliasQry)->GI6_FILRES
				
					If !(Empty(cFilGI6))
					
				       If oModel:VldData()
					       	oModel:CommitData()
						Endif
				       	oModel:DeActivate()
					
					Endif
					
					cFilGI6 := (cAliasQry)->GI6_FILRES
					
					oModel:SetOperation(MODEL_OPERATION_INSERT)
			       oModel:Activate() 
	       
			       oMdlGQ2:SetValue('GQ2_AGENCI',(cAliasQry)->G57_AGENCI)
			       oMdlGQ2:SetValue('GQ2_TIPDOC',(cAliasQry)->G57_TIPO)
			       oMdlGQ2:SetValue('GQ2_DTINI',dDataIni)
			       oMdlGQ2:SetValue('GQ2_DTFIM',dDataFim)
			       oMdlGQ2:SetValue('GQ2_DTEMI',dDataEmi)
			       oMdlGQ2:LoadValue('GQ2_STATUS','1')
				   If oMdlGQ1:HasField('GQ1_TABELA') 
						ExcessoGZT(oModel,dDataIni,dDataFim)
				   EndIf

				
				Endif
				
				If !Empty(oMdlGQ1:GetValue("GQ1_TIPDOC")) .Or. oMdlGQ1:IsDeleted() 
				
					oMdlGQ1:AddLine()
				
				Endif
				
				oMdlGQ1:SetValue('GQ1_TIPDOC',(cAliasQry)->G57_TIPO)
				oMdlGQ1:SetValue('GQ1_SERIE',(cAliasQry)->G57_SERIE)
				oMdlGQ1:SetValue('GQ1_SUBSER',(cAliasQry)->G57_SUBSER)
				oMdlGQ1:SetValue('GQ1_NUMCOM',(cAliasQry)->G57_NUMCOM)
				oMdlGQ1:SetValue('GQ1_NUMDOC',(cAliasQry)->G57_CODIGO)
				oMdlGQ1:SetValue('GQ1_VALOR',(cAliasQry)->G57_VALOR)
				oMdlGQ1:SetValue('GQ1_DTEMI',StoD((cAliasQry)->G57_EMISSA))
				oMdlGQ1:SetValue('GQ1_CODGQ2',oMdlGQ2:GetValue('GQ2_CODIGO'))
				If oMdlGQ1:HasField('GQ1_TABELA') 
					oMdlGQ1:SetValue('GQ1_TABELA','G57')
				Endif
				
		       oMdlGQ2:LoadValue('GQ2_VALTOT', oMdlGQ2:GetValue('GQ2_VALTOT') + oMdlGQ1:GetValue('GQ1_VALOR'))
				
				(cAliasQry)->(dbSkip())
			
			EndDo
			
			If !(Empty(cFilGI6))
			
		       If oModel:VldData()
	       
		       	oModel:CommitData()
				       	
		       	oModel:DeActivate()
	            
				Endif
					
			Endif
		
		Endif
	
	Else
	
		FWExecView("Lote de Taxas", "GTPA119", MODEL_OPERATION_INSERT,,{|| .T.},,,,,,,) // "Lote de Taxas"
	
	Endif
	
Return  lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldPerg()
Validação do Pergunte

@sample		ViewDef()

@return		oView - Retorna a View

@author		Flavio Martins
@since			21/03/2019
@version		P12
/*/
//------------------------------------------------------------------------------------------
Static Function VldPerg()
Local dDataIni := mv_par02
Local dDataFim := mv_par03
Local dDataEmi := mv_par04

	If Empty(dDataIni) 
	
		FwAlertHelp('Data inicial do parâmetro inválida')
		
		Return .F.
	
	Endif

	If Empty(dDataFim) .Or. dDataFim < dDataIni
	
		FwAlertHelp('Data final do parâmetro inválida')
		
		Return .F.
	
	Endif

	If Empty(dDataEmi) .Or. dDataEmi < dDataFim
	
		FwAlertHelp('Data de emissão do parâmetro inválida')
		
		Return .F.
	
	Endif

Return .T.



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA119Commit()
Commit do Model

@sample		ViewDef()

@return		oView - Retorna a View

@author		Flavio Martins
@since			21/03/2019
@version		P12
/*/
//------------------------------------------------------------------------------------------

Static Function GA119Commit(oModel)
Local lRet 		:= .T.
Local aAreaG57	:= G57->(GetArea())
Local oMdlGQ1		:= oModel:GetModel('GQ1DETAIL')
Local oMdlG57	
Local nX			:= 0
Local cTipDoc		:= ""
Local cSerie		:= ""
Local cSubSer		:= ""
Local cNumCom		:= ""
Local cNumDoc		:= ""

	If lIntGTP
	
		oMdlG57 := FwLoadModel("GTPA117")

		dbSelectArea('G57')
		G57->(dbSetOrder(3))

		dbSelectArea('GZT')
		If GZT->(FieldPos("GZT_SERIE")) > 0
			GZT->(dbSetOrder(2))
		EndIf

		For nX := 1 To oMdlGQ1:Length()
			
			oMdlGQ1:GoLine(nX)
			
			cTipDoc	:= oMdlGQ1:GetValue('GQ1_TIPDOC')
			cSerie		:= oMdlGQ1:GetValue('GQ1_SERIE')
			cSubSer	:= oMdlGQ1:GetValue('GQ1_SUBSER')
			cNumCom	:= oMdlGQ1:GetValue('GQ1_NUMCOM')
			cNumDoc	:= oMdlGQ1:GetValue('GQ1_NUMDOC')
			
			If G57->(dbSeek(xFilial('G57')+cTipDoc+cSerie+cSubSer+cNumCom+cNumDoc))
				
				oMdlG57:SetOperation(MODEL_OPERATION_UPDATE)
				oMdlG57:Activate() 

				If oModel:GetOperation() == MODEL_OPERATION_DELETE
					oMdlG57:GetModel('G57MASTER'):ClearField('G57_CODGQ1')
				Else					
					oMdlG57:GetModel('G57MASTER'):SetValue('G57_CODGQ1', oMdlGQ1:GetValue('GQ1_CODIGO'))
				Endif
					
				If oMdlG57:VldData()				
					oMdlG57:CommitData()						
				Endif
					
				oMdlG57:DeActivate() 
			elseif GZT->(dbSeek(xFilial('GZT')+cSerie+cNumDoc))
				oMdlGZT:= FwLoadModel("GTPA427")
				oMdlGZT:SetOperation(MODEL_OPERATION_UPDATE)
				oMdlGZT:Activate() 
				If oModel:GetOperation() == MODEL_OPERATION_DELETE
					oMdlGZT:GetModel('GZTMASTER'):ClearField('GZT_CODGQ1')
				Else					
					oMdlGZT:GetModel('GZTMASTER'):SetValue('GZT_CODGQ1', oMdlGQ1:GetValue('GQ1_CODIGO'))
				Endif
				If oMdlGZT:VldData()				
					oMdlGZT:CommitData()						
				Endif
					
			Endif
			
		Next nX
			
		RestArea(aAreaG57)
		
	Endif

		FwFormCommit(oModel)

Return lRet

Static Function GA119LinhaOK(oModel)
Local nValtot := oModel:GetValue("CALC1" , "VALTOT")

	//oModel:GetModel('GQ2MASTER'):SetValue('GQ2_VALTOT', nValTot)


Return .T.


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExcessoGZT()
Commit do Model
@sample		ViewDef()
@author		Osmar Cioni
@since			21/08/2020
@version		P12
/*/
//------------------------------------------------------------------------------------------
Static Function ExcessoGZT(oModel,dDataIni,dDataFim)
Local cAgencia	:= oModel:GetModel('GQ2MASTER'):GetValue('GQ2_AGENCI')
Local cAliasQry	:= GetNextAlias()

	BeginSQL Alias cAliasQry

		SELECT GZT.GZT_CODIGO,
		GZT.GZT_AGENCI,
		GZT.GZT_CODGZC,
		GZT.GZT_SERIE,
		GZT.GZT_DOC,  
		GZT.GZT_VALOR, 
		GZT.GZT_DTVEND 
		FROM %Table:GZT% GZT		
		WHERE GZT.GZT_FILIAL = %xFilial:GZT%
		AND GZT.%NotDel%		
		AND GZT.GZT_DTVEND BETWEEN %Exp:dDataIni% AND %Exp:dDataFim%
		AND GZT.GZT_SERIE  <> ''	
		AND GZT.GZT_DOC    <> ''		
		ORDER BY GZT.GZT_DTVEND, GZT.GZT_SERIE, GZT.GZT_DOC	
		
	EndSql

	While (cAliasQry)->(!Eof())
		
		If !Empty(oModel:GetModel('GQ1DETAIL'):GetValue("GQ1_SERIE")) .Or. oModel:GetModel('GQ1DETAIL'):IsDeleted() 				
			oModel:GetModel('GQ1DETAIL'):AddLine()				
		Endif
		oModel:GetModel('GQ1DETAIL'):SetValue('GQ1_SERIE',(cAliasQry)->GZT_SERIE)			
		oModel:GetModel('GQ1DETAIL'):SetValue('GQ1_NUMDOC',(cAliasQry)->GZT_DOC)
		oModel:GetModel('GQ1DETAIL'):SetValue('GQ1_VALOR',(cAliasQry)->GZT_VALOR)
		oModel:GetModel('GQ1DETAIL'):SetValue('GQ1_DTEMI',StoD((cAliasQry)->GZT_DTVEND))
		oModel:GetModel('GQ1DETAIL'):SetValue('GQ1_CODGQ2',oModel:GetModel('GQ2MASTER'):GetValue('GQ2_CODIGO'))
		oModel:GetModel('GQ1DETAIL'):SetValue('GQ1_TABELA','GZT')

		oModel:GetModel('GQ2MASTER'):LoadValue('GQ2_VALTOT', oModel:GetModel('GQ2MASTER'):GetValue('GQ2_VALTOT') + oModel:GetModel('GQ1DETAIL'):GetValue('GQ1_VALOR'))
			
		(cAliasQry)->(dbSkip())

	EndDo

	If !Empty(oModel:GetModel('GQ1DETAIL'):GetValue("GQ1_SERIE")) .Or. oModel:GetModel('GQ1DETAIL'):IsDeleted() 				
			oModel:GetModel('GQ1DETAIL'):AddLine()				
	Endif

Return

