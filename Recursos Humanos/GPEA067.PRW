#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GPEA067.CH'
#INCLUDE 'TopConn.CH'

/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������Ŀ��
���Fun��o    �GPEA067   � Autor � Leandro Drumond                   � Data � 20/02/2014 ���
���������������������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao de Beneficios                                                  ���
���������������������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                                          ���
���������������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                                 ���
���������������������������������������������������������������������������������������Ĵ��
���                ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL                     ���
���������������������������������������������������������������������������������������Ĵ��
���Programador � Data     � FNC            �  Motivo da Alteracao                       ���
���������������������������������������������������������������������������������������Ĵ��
���Christiane V�08/04/2015�    PCREQ-2683  �Cria��o dos campos para informar as verbas  ���
���            �          �                �para pagamento/desconto do benef�cio.       ���
���            �          �                �                                            ���
���Flavio C.   �06/07/2015�TSROAD          �Corre��o chave unica					    ���
���Gabriel A.  �14/07/2016�TVKROM          �Ajuste para que antes da montagem do browser���
���            �          �                �/grid seja verificado se os registros da    ���
���            �          �                �tabela S011 j� foram vinculados.            ���
���Paulo O I   �13/04/2017�DRHPAG-239      �Melhoria -  remo��o de dependencias do ctree���
����������������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
/*/
Function GPEA067()

Local aCampos	:= {}
Local aSeek		:= {}
Local oBrwTMP

Private oTmpTable := Nil
Private cAliasTmp := "TABAUX"

If !fCriaTmp(@aCampos,@aSeek)
	Return Nil
EndIf

oBrwTMP := FWmBrowse():New()
oBrwTMP:SetAlias( cAliasTmp )
oBrwTMP:SetFields(aCampos)
oBrwTMP:SetDescription(STR0001)	//"Definicao de Beneficios"
oBrwTMP:SetSeek(.T., aSeek)
oBrwTMP:DisableDetails()

oBrwTMP:Activate()

oTmpTable:Delete()

Return


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef    � Autor � Marcelo Silveira      � Data �31/01/2014���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Menu Funcional                                               ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE OemToAnsi(STR0003)  ACTION 'VIEWDEF.GPEA067' 	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE OemToAnsi(STR0004)  ACTION 'GPE067MNT()'	 	OPERATION 4 ACCESS 0 //"Manuten��o"

Return( aRotina )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ModelDef    � Autor � Leandro Drumond       � Data �20/02/2014���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Modelo de dados e Regras de Preenchimento para a Definicao de ���
���          �Outros Beneficios (RIS)                                       ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ModelDef()                                                   ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ModelDef()

Local aAux			:= {}

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruTMP 		:= DefStrModel( )
Local oStruRIS 		:= FWFormStruct(1, 'RIS', /*bAvalCampo*/,/*lViewUsado*/)
Local oModel

// Blocos de codigo do modelo
Local bLinePos		:= {|oMdl| Gp067LinePos(oMdl)}

If Empty(oStruTMP)
	Return Nil
EndIf

//Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('GPEA067', /*bPreValid*/ , /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oStruRIS:SetProperty("RIS_FILIAL", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD,'xFilial("RIS")'))
oStruRIS:SetProperty("RIS_FUNCD", MODEL_FIELD_VALID, { |oModel| Gp67FunDVld(oModel) })
oStruRIS:SetProperty("RIS_TPDESC", MODEL_FIELD_VALID, { |oModel| Gp67TpDescVld(oModel) })

oStruRIS:SetProperty("RIS_EMP", MODEL_FIELD_WHEN, { |oModel| Gp67EmpWhen(oModel) })

//Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields('TMPMASTER', /*cOwner*/, oStruTMP, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)

//Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
oModel:AddGrid( 'RISDETAIL', 'TMPMASTER', oStruRIS, /*bLinePre*/, bLinePos, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

aAux := FwStruTrigger('RIS_PD','RIS_DESCPD','SRV->RV_DESC',.T.,'SRV',1,'xFilial("SRV",SRA->RA_FILIAL) + M->RIS_PD','.T.')
oStruRIS:AddTrigger( aAux[1] , aAux[2] , aAux[3] , aAux[4] )

aAux := FwStruTrigger('RIS_PD1','RIS_DESC1','SRV->RV_DESC',.T.,'SRV',1,'xFilial("SRV",SRA->RA_FILIAL) + M->RIS_PD1','.T.')
oStruRIS:AddTrigger( aAux[1] , aAux[2] , aAux[3] , aAux[4] )

aAux := FwStruTrigger('RIS_PD2','RIS_DESC2','SRV->RV_DESC',.T.,'SRV',1,'xFilial("SRV",SRA->RA_FILIAL) + M->RIS_PD2','.T.')
oStruRIS:AddTrigger( aAux[1] , aAux[2] , aAux[3] , aAux[4] )


//Faz relaciomaneto entre os compomentes do model
oModel:SetRelation('RISDETAIL', {{'RIS_TPBENE', 'TAB_COD'},{'RIS_FILIAL', 'xFilial("RIS")'}}, RIS->(IndexKey(1)))

oModel:GetModel('RISDETAIL'):SetUniqueLine({'RIS_FILIAL','RIS_TPBENE','RIS_COD','RIS_SALATE','RIS_SALMIN'})
oModel:SetPrimaryKey({'RIS_FILIAL','RIS_TPBENE','RIS_COD','RIS_SALATE','RIS_SALMIN'})

//Permite grid sem dados
oModel:GetModel('RISDETAIL'):SetOptional(.T.)

oModel:GetModel('TMPMASTER'):SetOnlyView(.T.)
oModel:GetModel('TMPMASTER'):SetOnlyQuery(.T.)

//Adiciona a descricao do Modelo de Dados
oModel:SetDescription(OemToAnsi(STR0001))  //"Defini��o de Beneficios"

Return( oModel )

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ViewDef     � Autor � Leandro Drumond       � Data �20/02/2014���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Visualizador de dados da Definicao de Beneficios (RIS)        ���
���          �                                                              ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � ViewDef()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �                                                              ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Static Function ViewDef()

Local oView

//Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel('GPEA067')

//Cria a estrutura a ser usada na View
Local oStruTMP := DefStrView()
Local oStruRIS := FWFormStruct(2, 'RIS')

//Cria o objeto de View
oView := FWFormView():New()

//Remove campos da estrutura e ajusta ordem dos campos na view
oStruRIS:RemoveField('RIS_TPBENE')

//Define qual o Modelo de dados ser� utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VIEW_TMP', oStruTMP, 'TMPMASTER')

oStruTMP:SetNoFolder()

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid('VIEW_RIS', oStruRIS, 'RISDETAIL')

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 10)
oView:CreateHorizontalBox('INFERIOR', 90)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_TMP', 'SUPERIOR')
oView:SetOwnerView('VIEW_RIS', 'INFERIOR')

Return( oView )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �DefStrModel  	� Autor � Leandro Drumond   � Data � 20.02.14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta estrutura temporaria								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function DefStrModel( )

Local aArea    := GetArea()
Local bValid   := { || }
Local bWhen    := { || }
Local bRelac   := { || }

Local aCampos	:= {}
Local aSeek		:= {}

If type("cAliasTmp") == "U"

	Private cAliasTmp := "TABAUX"

	If !fCriaTmp(@aCampos,@aSeek)
		Return Nil
	EndIf

EndIf

oStruct := FWFormModelStruct():New()

//-------------------------------------------------------------------
// Tabela
//-------------------------------------------------------------------
oStruct:AddTable( 	cAliasTmp		               				, ;	// [01] Alias da tabela
					StrTokArr( "TAB_COD+TAB_FORN", ' + ' ) 		, ;	// [02] Array com os campos que correspondem a primary key
					STR0001 )               					// [03] Descri��o da tabela


//-------------------------------------------------------------------
// Indices
//-------------------------------------------------------------------
oStruct:AddIndex( 	1	      						, ;     // [01] Ordem do indice
					"01"   							, ;     // [02] ID
					"TAB_COD+TAB_FORN"			    , ;     // [03] Chave do indice
					STR0007 + " + " + STR0009	 	, ;     // [04] Descri��o do indice
					""       						, ;    	// [05] Express�o de lookUp dos campos de indice (SIX_F3)
					"" 								, ;    	// [06] Nickname do indice
					.T. )      								// [07] Indica se o indice pode ser utilizado pela interface

//-------------------------------------------------------------------
// Campos
//-------------------------------------------------------------------
				//Titulo ,ToolTip,Id do Field	,Tipo	,Tamanho		,Decimal,Valid,When	,Combo	,Obrigatorio	,Init	,Chave	,Altera	,Virtual
oStruct:AddField(STR0007,STR0007,'TAB_COD' 		,'C'	,2				,0		,Nil,Nil	,{}		,.F.			,Nil	,NIL	,NIL	,.F.)   //Codigo
oStruct:AddField(STR0008,STR0008,'TAB_DESC'		,'C'	,30				,0		,Nil,Nil	,{}		,.F.			,Nil	,NIL	,NIL	,.F.)	//Descricao
oStruct:AddField(STR0009,STR0009,'TAB_FORN'	 	,'C'	,3				,0		,Nil,Nil	,{}		,.F.			,Nil	,NIL	,NIL	,.F.)	//Fornecedor

RestArea( aArea )

Return oStruct

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �DefStrView  	� Autor � Leandro Drumond   � Data � 20.02.14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Monta estrutura temporaria								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function DefStrView()
Local oStruct   := FWFormViewStruct():New()
               //Campo			,Ordem	,Titulo		,Descricao	,Help,Tipo 	,Picture               	,PictVar,F3,Editavel,Folder	,Group	,Combo	,Tam.Combo 	, Init. , Virtual
oStruct:AddField('TAB_COD'		,'01'	,STR0007	,STR0007	,NIL ,'C'	,'@!'					,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TAB_DESC'		,'02'	,STR0008	,STR0008	,NIL ,'C'	,'@!'					,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
oStruct:AddField('TAB_FORN'		,'03'	,STR0009	,STR0009	,NIL ,'C'	,'@!'					,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)

Return oStruct

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fCriaTmp    	� Autor � Leandro Drumond   � Data � 20.02.14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cria arquivo temporario									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fCriaTmp(aCampos,aSeek)

Local aColumns	 := {}
Local aTabBenef	 := {}
Local cArqTmp	 := ""
Local lRet		 := .F.
Local nX		 := 0

If Select(cAliasTmp) > 0
	DbSelectArea(cAliasTmp)
	dbclosearea()
EndIf

Begin Sequence

	fCarrTab( @aTabBenef   , "S011", Nil)

	//Verifica se o benef�cio j� est� vinculado na tabela SRN ou RFO para n�o apresentar.
	If Len(aTabBenef) > 0
		fVerVinc(@aTabBenef)
	EndIf

	If Empty(aTabBenef)
		Help(,,STR0005,, STR0006, 1, 0 )  // "Nenhum tipo de beneficio foi cadastrado na tabela S011. Efetue o cadastramento." # "Atencao"
		Break
	EndIf

	lRet := .T.

	aAdd( aColumns, { "TAB_COD"		,"C",02,00 })
	aAdd( aColumns, { "TAB_DESC"	,"C",30,00 })
	aAdd( aColumns, { "TAB_FORN"	,"C",03,00 })

	aAdd( aCampos, { STR0007 , { || (cAliasTmp)->(TAB_COD)  } , "C" , "@!" , 0 , 02 , 0 , , , , , , , } )
	aAdd( aCampos, { STR0008 , { || (cAliasTmp)->(TAB_DESC) } , "C" , "@!" , 0 , 30 , 0 , , , , , , , } )
	aAdd( aCampos, { STR0009 , { || (cAliasTmp)->(TAB_FORN) } , "C" , "@!" , 0 , 03 , 0 , , , , , , , } )

	Aadd( aSeek, {STR0007, {{"","C",2,0,STR0007,}},1,.T. } )
	Aadd( aSeek, {STR0008, {{"","C",30,0,STR0008,}},2,.T. } )

	oTmpTable := FWTemporaryTable():New(cAliasTmp)
	oTmpTable:SetFields( aColumns )
	oTmpTable:AddIndex( "Codigo", {"TAB_COD"} )
	oTmpTable:AddIndex( "Descricao", {"TAB_DESC"} )
	oTmpTable:Create()

	DbSelectArea(cAliasTmp)

	For nX := 1 to Len(aTabBenef)
		lRet := .T.

		RecLock(cAliasTmp,.T.)

		(cAliasTmp)->TAB_COD 	:= aTabBenef[nX,5]
		(cAliasTmp)->TAB_DESC 	:= aTabBenef[nX,6]
		(cAliasTmp)->TAB_FORN 	:= aTabBenef[nX,7]

		MsUnLock()

	Next nX

End Sequence



Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Gp067LinePos	� Autor � Leandro Drumond   � Data � 20.02.14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �VALIDACAO DE LINHA										  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Gp067LinePos(oGrid)
Local lRet		:= .T.

If Empty(oGrid:GetValue("RIS_SALATE")) .and. Empty(oGrid:GetValue("RIS_SALMIN"))
	Help(,,STR0005,, STR0010, 1, 0 )  // "Campo Sal�rio At� deve ser informado." # "Atencao"
	lRet := .F.
ElseIf Empty(oGrid:GetValue("RIS_DESC"))
	Help(,,STR0005,, STR0011, 1, 0 )  // "Campo Descri��o deve ser informado." # "Atencao"
	lRet := .F.
ElseIf Empty(oGrid:GetValue("RIS_TPREF"))
	Help(,,STR0005,, STR0012, 1, 0 )  // "Campo Tipo Ref. deve ser informado." # "Atencao"
	lRet := .F.
ElseIf Empty(oGrid:GetValue("RIS_REF"))
	Help(,,STR0005,, STR0013, 1, 0 )  // "Campo Refer�ncia deve ser informado." # "Atencao"
	lRet := .F.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Gp067SalWhen	� Autor � Leandro Drumond   � Data � 23.04.14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �When dos capos RIS_SALATE e RIS_SALMIN					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Gp067SalWhen(nTipo)
Local lRet 		:= .F.
Local oModel 	:= FWModelActive()
Local oGrid 	:= oModel:GetModel('RISDETAIL')

If nTipo == 1 //Salario Ate
	If Empty(oGrid:GetValue("RIS_SALMIN"))
		lRet := .T.
	EndIf
Else
	If Empty(oGrid:GetValue("RIS_SALATE"))
		lRet := .T.
	EndIf
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Gp67EmpWhen	� Autor � Leandro Drumond   � Data � 29.05.14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �When do campo RIS_EMP										  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Gp67EmpWhen(oGrid)
Local lRet		:= .F.

If oGrid:GetValue("RIS_TPDESC") == "1"
	lRet := .T.
Else
	lRet := .F.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Gp67TpDescVld	� Autor � Leandro Drumond   � Data � 29.05.14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valid do campo RIS_TPDESC									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Gp67TpDescVld(oGrid)

cVar := &(ReadVar())

If cVar <> "1"
	oGrid:LoadValue("RIS_EMP", 0)
Else
	If oGrid:GetValue("RIS_FUNCD") > 0
		oGrid:LoadValue("RIS_EMP", 100 - oGrid:GetValue("RIS_FUNCD"))
	EndIf
EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Gp67FunDVld	� Autor � Leandro Drumond   � Data � 29.05.14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valid do campo RIS_FUNCD              					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Gp67FunDVld(oGrid)

Local nVar		:= &(ReadVar())

If oGrid:GetValue("RIS_TPDESC") == "1"
	oGrid:SetValue("RIS_EMP", 100 - nVar)
Else
	oGrid:LoadValue("RIS_EMP", 0)
EndIf

Return .T.


/*/{Protheus.doc} GPE067MNT
Rotina que permite realizar manuten��o no benef�cio posicionado.
@type function
@author Victor Andrade
@since 20/04/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Function GPE067MNT()

Local cTitulo 	 := "Manuten��o de Benef�cios"
Local cPrograma	 := "GPEA067"
Local nOperation := MODEL_OPERATION_UPDATE
Local nRet  	 := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } , /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ )

Return

/*/{Protheus.doc}fVerVinc
Fun��o para eliminar as posi��es do array aTabBenef que j� possuem v�nculos na tabela SRN ou FRO.
@author Victor Andrade
@since 13/07/2016
@version 1.0
/*/
Function fVerVinc(aTabBenef)

	Local i 	 	:= 0
	Local aPosDel 	:= {}
	Local aBenef 	:= {}

	For i:= 1 To Len(aTabBenef)
		If !(fVerRFO(aTabBenef[i][5]) .Or. fVerSRN(aTabBenef[i][5]))
			Aadd(aBenef, aTabBenef[i])
		EndIf
	Next i

	aTabBenef := AClone(aBenef)

Return

/*/{Protheus.doc} fVerRFO
Fun��o que retorna se h� ou n�o registro vinculado na tabela RFO
@author Victor Andrade
@since 13/07/2016
/*/
Static Function fVerRFO(cCod)

	Local lRet 		 := .F.
	Local cQuery	 := ""
	Local cAliasRFO	 := "TMPRFO"

	cQuery := "SELECT RFO_CODIGO FROM " + RetSQLName("RFO") + " RFO "
	cQuery += "WHERE D_E_L_E_T_ = ' ' "
	cQuery += "AND RFO_TPBEN = '" + cCod + "' "
	cQuery += "AND RFO_FILIAL = '" + FWxFilial("RFO") + "' "

	If Select(cAliasRFO) > 0
		DbSelectArea(cAliasRFO)
		(cAliasRFO)->(DbCloseArea())
	EndIf

	TCQuery cQuery New Alias (cAliasRFO)

	(cAliasRFO)->(DbGoTop())

	If (cAliasRFO)->( !Eof() )
		lRet := .T.
	EndIf

Return(lRet)

/*/{Protheus.doc} fVerSRN
Fun��o que retorna se h� ou n�o registro vinculado na tabela SRN
@author Victor Andrade
@since 13/07/2016
@version 1.0
/*/
Static Function fVerSRN(cCod)

	Local lRet 		 := .F.
	Local cQuery	 := ""
	Local cAliasSRN	 := "TMPSRN"

	cQuery := "SELECT RN_COD FROM " + RetSQLName("SRN") + " SRN "
	cQuery += "WHERE D_E_L_E_T_ = ' ' "
	cQuery += "AND RN_TPBEN = '" + cCod + "' "
	cQuery += "AND RN_FILIAL = '" + FWxFilial("SRN") + "' "

	If Select(cAliasSRN) > 0
		DbSelectArea(cAliasSRN)
		(cAliasSRN)->(DbCloseArea())
	EndIf

	TCQuery cQuery New Alias (cAliasSRN)

	(cAliasSRN)->(DbGoTop())

	If (cAliasSRN)->( !Eof() )
		lRet := .T.
	EndIf

Return(lRet)
