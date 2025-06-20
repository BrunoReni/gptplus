#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'

static oCmpExBZ8 := NIL
//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSA281
Tela Ficha de Matr�cula
@since 02/2020
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSA281(lAutoma)
local cFiltro   := "@(BAU_FILIAL = '" + xFilial("BAU") + "') "
local oBrowse	:= nil
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	 

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('BAU')
oBrowse:SetFilterDefault(cFiltro)
oBrowse:SetOnlyFields( { 'BAU_FILIAL', 'BAU_CODIGO', 'BAU_NOME', 'BAU_NREDUZ', 'BAU_CPFCGC', 'BAU_NFANTA'} )
oBrowse:AddLegend("BAU->BAU_CODBLO==Space(03) .Or. BAU->BAU_DATBLO > DDATABASE", "GREEN", "Autorizado" ) //Autorizado
oBrowse:AddLegend("BAU->BAU_CODBLO<>Space(03) .AND. BAU->BAU_DATBLO <= DDATABASE", "RED", "Negado" ) //Negado
oBrowse:SetDescription("Lan�amento Movimento")
iif(!lAutoma, oBrowse:Activate(), '')

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menus
@since 09/2019
@version P12 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina 	:= {}

Add Option aRotina Title "Lan�amento de Movimenta��o" Action "STATICCALL(PLSA281,PlsMid)" Operation 9 Access 0 
Add Option aRotina Title "Ficha de Matricula" Action "PLSA281Imp()" Operation MODEL_OPERATION_VIEW Access 0 

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados.
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrBZ4	:= FWFormStruct(1,'BZ4')
Local oStrBZ5	:= FWFormStruct(1,'BZ5')
Local oStrBZ8	:= FWFormStruct(1,'BZ8')
Local oStrVal	:= FWFORMMODELSTRUCT():New()
Local oStrVal2	:= FWFORMMODELSTRUCT():New()
Local oStrVal3	:= FWFORMMODELSTRUCT():New()

oModel := MPFormModel():New( 'PLSA281' , , { |oModel| PlFimConf(oModel) } , {|oModel|FWFORMCOMMIT(oModel, , { || PlComBz4(oModel) }  )} ) 
//     := MPFormModel():New( 'PLSA281' , , 			P�s Valida��o		  , {|Bloco de comite    (oModel, , { P�s Comit				  } ) 

//Campos de saldo
oStrVal:AddField('Valor_Cr�dito', 'Valor Total de Cr�dito'	, 'VLRCRED' , 'N', 16,2, , , {}, .F.,{||CarregaSaldo(oModel,"cre") } , .F., .F., .T., , )
oStrVal2:AddField('Valor_D�bito', 'Valor Total de D�bito'	, 'VLRDEBI'	, 'N', 16,2, , , {}, .F.,{||CarregaSaldo(oModel,"deb") } , .F., .F., .T., , )
oStrVal3:AddField('Valor_Saldo'	, 'Valor Saldo Final'		, 'VLRSLD'	, 'N', 16,2, , , {}, .F.,{||CarregaSaldo(oModel,"sal") } , .F., .F., .T., , )

//Campos para modo de exclus�o
oStrBZ5:AddField('Observa��o_Exclus�o'	, 'Observa��o de exclus�o'	, 'OBSEXC'				, 'C', 80	,, ,{||PlHabEdit(oModel) }, {}, .F.,, .F., .F., .T., , )
oStrBZ5:AddField('Check_Exclus�o'		, 'Check para Exclus�o'		, 'CHKEXC'				, 'L', 1	,, ,, {}, .F.,{||.F.}, .F., .F., .T., , )

//Adi��o dos campos e Grids
oModel:AddFields( 'BZ4MASTER' , /*cOwner*/  , oStrBZ4 )
oModel:AddFields( 'ValDetail' , 'BZ4MASTER' , oStrVal  ,,,{|| Load() })
oModel:AddFields( 'ValDetail2', 'BZ4MASTER' , oStrVal2 ,,,{|| Load() })
oModel:AddFields( 'ValDetail3', 'BZ4MASTER' , oStrVal3 ,,,{|| Load() })
oModel:AddGrid( 'BZ5Detail'   , 'BZ4MASTER' , oStrBZ5  ,,{||PlValBZ5(oModel)})
oModel:AddGrid( 'BZ8Detail'   , 'BZ4MASTER' , oStrBZ8  ,, ) 

//Relacionamentos
oModel:SetRelation( 'BZ5Detail', { ;
	{ 'BZ5_FILIAL'	, 'xFilial( "BZ5" )' },;
	{ 'BZ5_CODIGO'	, 'BZ4_CODIGO'		 },;
	{ 'BZ5_FICMAT'	, 'BZ4_FICMAT'		 }},;
	BZ5->( IndexKey(2) ) )
oModel:SetRelation( 'BZ8Detail', { ;
	{ 'BZ8_FILIAL'	, 'xFilial( "BZ8" )' },;
	{ 'BZ8_CODIGO'	, 'BZ4_CODIGO'		 }})

//Propriedades especificas de campo
oStrBZ5:setProperty( "BZ5_CODIGO" , MODEL_FIELD_INIT, { || BAU->BAU_CODIGO} )
oStrBZ5:setProperty( "BZ5_FICMAT" , MODEL_FIELD_INIT, { || oModel:getModel("BZ4MASTER"):getValue("BZ4_FICMAT")} )
oStrBZ5:SetProperty( 'BZ5_VLRLCT' , MODEL_FIELD_VALID, { || ValidaVlrlct (oModel) } )
oStrBZ5:setProperty( "BZ5_CODLCT" , MODEL_FIELD_OBRIGAT, .F. )

//Restri��es de CRUD
oModel:GetModel( 'BZ5Detail' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'BZ8Detail' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'BZ8Detail' ):SetNoInsertLine( .T. )
oModel:GetModel( 'BZ8Detail' ):SetNoUpdateLine( .T. )

//Apenas BZ4 � obrigat�rio
oModel:GetModel( 'BZ5Detail' ):setOptional(.T.)
oModel:GetModel( 'BZ8Detail' ):setOptional(.T.)
oModel:GetModel( 'ValDetail' ):setOptional(.T.)
oModel:GetModel( 'ValDetail2'):setOptional(.T.)
oModel:GetModel( 'ValDetail3'):setOptional(.T.)

//Descri��o
oModel:GetModel( 'BZ4MASTER' ):SetDescription( "Ficha de Matr�cula"	 	)
oModel:GetModel( 'BZ5Detail' ):SetDescription( "Lan�amentos"			)
oModel:GetModel( 'BZ8Detail' ):SetDescription( "Hist�rico de Exclus�o"	)
oModel:GetModel( 'ValDetail' ):SetDescription( "Resumo de Totais" 		)
oModel:GetModel( 'ValDetail2'):SetDescription( "Resumo de Totais"		)
oModel:GetModel( 'ValDetail3'):SetDescription( "Resumo de Totais"		)

//alimentar a vari�vel est�tica oCmpExBZ8, para n�o chamar FieldPos v�rias vezes
PlExsBZ8()
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o da interface.
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView 
Local oModel	:= FWLoadModel( 'PLSA281' )
Local oStrBZ4	:= FWFormStruct(2,'BZ4',{ |cCampo| FilExibe(cCampo) })
Local oStrBZ5	:= FWFormStruct(2,'BZ5')
Local oStrBZ8	:= FWFormStruct(2,'BZ8')
Local oStrVal	:= FWFORMVIEWSTRUCT():New()
Local oStrVal2	:= FWFORMVIEWSTRUCT():New()
Local oStrVal3	:= FWFORMVIEWSTRUCT():New()

oView := FWFormView():New()
oView:SetModel( oModel )

//Vistas Principais
oView:AddField( 'VIEW_BZ4', oStrBZ4, 'BZ4MASTER')
oView:AddGrid( 'VIEW_BZ5', oStrBZ5, 'BZ5Detail' )
oView:AddGrid( 'VIEW_BZ8', oStrBZ8, 'BZ8Detail' )
oView:AddField( 'VIEW_VAL', oStrVal, 'ValDetail')
oView:AddField( 'VIEW_VAL2', oStrVal2, 'ValDetail2')
oView:AddField( 'VIEW_VAL3', oStrVal3, 'ValDetail3')

//Campos criados
oStrVal:AddField( 'VLRCRED'	, '97' , ''	, 'Valor Total de Cr�dito'	,, 'N' ,'@E 999,999,999,999.99',,,.F.,,,,,,.T.,,, )
oStrVal2:AddField( 'VLRDEBI', '98' , ''	, 'Valor Total de D�bito'	,, 'N' ,'@E 999,999,999,999.99',,,.F.,,,,,,.T.,,, )
oStrVal3:AddField( 'VLRSLD', '99' , ''	, 'Valor Saldo Final'		,, 'N' ,'@E 999,999,999,999.99',,,.F.,,,,,,.T.,,, )
oStrBZ5:AddField( 'OBSEXC'	, '96' , 'Observa��o de Exclus�o'	, 'Observa��o de Exclus�o'	,, 'C' ,,,,,,,,,,.T.,, 	 )
oStrBZ5:AddField( 'CHKEXC'	, '95' , 'Exclus�o'					, 'Exclus�o'				,, 'L' ,,,,.T.,,,,,,.T.,,)

//Divis�o das Vistas
oView:CreateHorizontalBox( 'SUPERIOR' , 40 )
oView:CreateHorizontalBox( 'BAIXO'	  , 60 )
oView:CreateVerticalBox( 'BAIXOESQ'	, 60 , 'BAIXO' )
oView:CreateVerticalBox( 'BAIXODIR' , 40 , 'BAIXO' )
oView:CreateHorizontalBox( 'RESSUPERIOR' , 30 ,'BAIXODIR' )
oView:CreateHorizontalBox( 'RESCENTRAL'  , 30 ,'BAIXODIR' )
oView:CreateHorizontalBox( 'RESBAIXO'    , 40 ,'BAIXODIR' )

//Folders
oView:CreateFolder( 'ABA', 'BAIXOESQ' )
oView:CreateHorizontalBox( 'A1' , 100 ,,, 'ABA' , 'V1' )
oView:CreateHorizontalBox( 'A2' , 100 ,,, 'ABA' , 'V2' )
oView:AddSheet( 'ABA', 'V1' ,"Lan�amento de Movimentos") 
oView:AddSheet( 'ABA', 'V2', "Hist�rico de Exclus�o" ) 

//Vistas
oView:SetOwnerView('VIEW_BZ5' , 'A1'		 )
oView:SetOwnerView('VIEW_BZ8' , 'A2' 		 )	
oView:SetOwnerView('VIEW_BZ4' , 'SUPERIOR'	 )
oView:SetOwnerView('VIEW_VAL' , 'RESSUPERIOR')
oView:SetOwnerView('VIEW_VAL2', 'RESCENTRAL' )
oView:SetOwnerView('VIEW_VAL3', 'RESBAIXO' 	 )

//Desabilita para edi��o o campo Ficha de Matricula (possui inicializador no SX3)
oStrBZ4:setProperty( "BZ4_FICMAT" , MVC_VIEW_CANCHANGE, .F. )

//T�tulos
oView:EnableTitleView('VIEW_BZ4' , "Ficha de Matr�cula"	     ) 
oView:EnableTitleView('VIEW_BZ5' , "Lan�amento de Movimentos") 
oView:EnableTitleView('VIEW_BZ8' , "Hist�rico de Exclus�o" 	 )
oView:EnableTitleView('VIEW_VAL' , "Valor Total de Cr�dito"	 ) 
oView:EnableTitleView('VIEW_VAL2', "Valor Total de D�bito"	 ) 
oView:EnableTitleView('VIEW_VAL3', "Valor Saldo Final"	 	 ) 

//Atualiza Saldo no grid
oView:SetFieldAction('BZ5_VLRLCT', { |oView| CarregaSaldo(oModel) } ) 

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsMid
Carrega tela de Inclus�o ou Altera��o
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
static function PlsMid()
local aButtons 	:= {{.f.,Nil},{.f.,Nil},{.f.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,"Confirmar"},{.t.,'Cancelar'},{.t.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.f.,nil}}	
BZ4->(dbsetorder(1))
If ( BZ4->(dbSeek(xFilial("BZ4") + BAU->BAU_CODIGO)) )
	FWExecView('Lan�amento de Movimentos','PLSA281', 4,,,,,aButtons ) 
Else
	FWExecView('Lan�amento de Movimentos','PLSA281', 3,,,,,aButtons ) 
Endif 	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FilExibe
Function para ocultar os campos que n�o podem ser exibidos em tela
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
static function FilExibe(cCampo)
Local lRet := .T.

if alltrim(cCampo) $ "BZ4_CDMEM1,BZ4_CDMEM2"
	lRet := .F.
endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PlValBZ5
Valida se todos os campos obrigat�rios est�o preenchidos
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
static function PlValBZ5(oModel)

local nFor 		:= 0
local aCmpVld	:= {"BZ5_DATLCT","BZ5_CODLCT","BZ5_DESLCT","BZ5_VLRLCT","BZ5_TIPLCT","BZ5_TIPCLA"}
local lRet		:= .T.
Local oBZ5		:= oModel:getmodel("BZ5Detail")

//Verifica se campos est�o preenchidos
For nFor := 1 to Len(aCmpVld)
	If empty (oBZ5:getValue(aCmpVld[nFor]))
		lRet := .F.
		Help(nil, nil , "Aviso" , nil, "O campo " + aCmpVld[nFor] + " � obrigat�rio.", 1, 0, NIL, NIL, NIL, NIL, NIL, )
		Exit
	Endif
Next

//Atualiza saldos
If lRet
	PlHabEdit(oModel) //Apaga campo observa��o de exclus�o caso o item n�o esteja marcado como 'excluir'
	PlSaldoGr(oModel)
Endif

Iif(lRet,CriaNumLct(oBZ5),) //Insere campo NumLct em uma linha validada

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PlSaldoBZ5
Atualiza saldo dos lan�amentos de movimento ao carregar o grid
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PlSaldoBZ5(oModel)

Local aSaldo 	:= {0, 0}
Local nSaldo 	:= 0 
Local nReg 		:= BZ5->(Recno())

BZ5->(dbSetOrder(1))

If !Empty(BZ4->BZ4_CODIGO+BZ4->BZ4_FICMAT)
	If BZ5->(dbSeek(xFilial("BZ4")+BZ4->BZ4_CODIGO+BZ4->BZ4_FICMAT))
		While BZ5->(!Eof() .And. BZ5_FILIAL+BZ5->BZ5_CODIGO+BZ5->BZ5_FICMAT == xFilial("BZ4")+BZ4->BZ4_CODIGO+BZ4->BZ4_FICMAT)
																		
			nSaldo += ( BZ5->BZ5_VLRLCT * IIF(BZ5->BZ5_TIPLCT == "1", 1, -1))
			If BZ5->BZ5_TIPLCT=="1"
				aSaldo[1] += BZ5->BZ5_VLRLCT
			Else
				aSaldo[2] += BZ5->BZ5_VLRLCT
			EndIf

			BZ5->(dbSkip())
		End
	Endif
Endif
BZ5->(dbGoto(nReg)) //Reposiciona na BZ5

Return aSaldo

//-------------------------------------------------------------------
/*/{Protheus.doc} PlSaldoGr
Atualiza saldo dos lan�amentos de movimento dinamicamente (aciona ao mudar de linha)
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PlSaldoGr(oModel)

Local oBZ5		:= oModel:getmodel("BZ5Detail")
Local aSaldo	:= {0,0}
Local nSaldo	:= 0
Local nI		:= 0
Local nValorCota:= 0
Local nLnAtual	:= 0
Local cTipclt	:= ""

nLnAtual := oBZ5:GetLine()

For nI := 1 to oBZ5:Length()
	oBZ5:GoLine(nI)
	nValorCota := oBZ5:getValue("BZ5_VLRLCT")
	cTipclt	:= oBZ5:getValue("BZ5_TIPLCT")
	If !(Empty(nValorCota) .And. !(Empty(cTipclt))) //Se n�o houver valores a serem somados ou a dire��o, n�o � somado o saldo. 
		nSaldo += ( nValorCota * IIF(cTipclt == "1", 1, -1))
		If cTipclt == "1"
			aSaldo[1] += nValorCota
		Else
			aSaldo[2] += nValorCota
		Endif
		oModel:getModel("BZ5Detail"):loadvalue("BZ5_SALDO",nSaldo)
	Endif
Next

oBZ5:GoLine(nLnAtual) //Restaura posi��o no grid

Return aSaldo

//-------------------------------------------------------------------
/*/{Protheus.doc} CarregaSaldo
Carrega o saldo dos valores em cota
Obs: Deve ser usado o parametro 'cTipo' para realizar o primeiro carregamento da tela. Os m�todos MVC n�o funcionam neste ponto.
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
Function CarregaSaldo(oModel,cTipo)

Local aSaldo	:= {}
Local nSaldo 	:= 0
Local oViewAtiva:= Nil

//Altera saldo no carregamento da tela
If !Empty(cTipo)
	aSaldo := PlSaldoBZ5(oModel)
	If cTipo == "cre"
		nSaldo := aSaldo[1]
	ElseIf cTipo == "deb"
		nSaldo := aSaldo[2]
	ElseIf cTipo == "sal"
		nSaldo := aSaldo[1]-aSaldo[2]
	Endif

//Altera saldo dinamicamente
Else
	oViewAtiva:= FWViewActive()
	aSaldo := PlSaldoGr(oModel)

	oModel:getModel("ValDetail" ):loadvalue("VLRCRED",aSaldo[1]				)
	oModel:getModel("ValDetail2"):loadvalue("VLRDEBI",aSaldo[2]				)
	oModel:getModel("ValDetail3"):loadvalue("VLRSLD" ,aSaldo[1]-aSaldo[2]	)
	oViewAtiva:Refresh()
	Return
Endif

Return nSaldo

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaVlrlct
Valida se o campo C�digo de Lan�amento j� foi preenchido para que possa inserir um valor em cotas
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
Function ValidaVlrlct (oModel)

Local lRet := .T.
Local cTipclt	:= oModel:getmodel("BZ5Detail"):getValue("BZ5_TIPLCT")

If Empty(cTipclt)
	Help(nil, nil , 'Aten��o' , nil, 'Insira um c�digo de lan�amento antes de inserir um valor', 1, 0, nil, nil, nil, nil, nil, {""} )
	lRet := .F.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Load
Carrega os campos sem estruturas
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Load()
Local aLoad := {}
   aAdd(aLoad, {""}) //dados
   aAdd(aLoad, 0) //recno  
Return aLoad

//-------------------------------------------------------------------
/*/{Protheus.doc} SlvObsBZ4
Salva nas tabelas os campos de observa��o da BZ4 (Modelo antigo de salvamento)
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function SlvObsBZ4(oBZ4)

If !Empty(oBZ4:getValue("BZ4_OBSADM"))
	MSMM(,TamSx3("BZ4_OBSADM")[1],,oBZ4:getValue("BZ4_OBSADM"),1,,,"BZ4","BZ4_CDMEM1")	
Endif

If !Empty(oBZ4:getValue("BZ4_OBSDEM"))
	MSMM(,TamSx3("BZ4_OBSDEM")[1],,oBZ4:getValue("BZ4_OBSDEM"),1,,,"BZ4","BZ4_CDMEM2")	
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaNumLct
Insere o registro de n�mero de lan�amento em linhas criadas
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function CriaNumLct(oBZ5)

If Empty(oBZ5:getValue("BZ5_NUMLCT"))
	oBZ5:loadvalue("BZ5_NUMLCT",GETSX8Num("BZ5","BZ5_NUMLCT",,2))
	BZ5->(ConfirmSX8())
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PlFimConf
Fun��o que realizaos processos de valida��es e procedimentos finais da tela 
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function PlFimConf(oModel)

Local oBZ5		:= oModel:getmodel("BZ5Detail")
Local aValidBZ8	:= {}
Local nLnAtual	:= 0
Local nI		:= 0
Local lBZ8ok	:= .T. //Permite excluir os itens da BZ5 e incluir na BZ8
Local lHaExc	:= .F. //Flag que avisa se haver� exclus�o
Local lRet		:= .T.

nLnAtual := oBZ5:GetLine()

For nI := 1 To oBZ5:Length()
	oBZ5:GoLine(nI)
	CriaNumLct(oBZ5) //Cria um n�mero de lan�amento caso ainda n�o tenha
	aadd(aValidBZ8,VldBZ5BZ8(oBZ5,@lBZ8ok,@lHaExc)) //Verifica e valida linhas para excluir - {{nLinha,lMarcadoExcluit,lCampoObserva��o}}
Next

//Exclui linhas da BZ5 e grava na BZ8
If lHaExc
	If lBZ8ok
		PlExcLanc(oBZ5,aValidBZ8) //Exclui da BZ5 e inclui na BZ8
	Else
		Help(nil, nil , "Aviso" , nil, 'Para excluir um lan�amento � obrigat�rio preencher o campo "Observa��o de Exclus�o"', 1, 0, NIL, NIL, NIL, NIL, NIL,{'Insira uma "Observa��o de Exclus�o" ou desmarque a op��o de "Excluir"'} )
		lRet := PlListErro(aValidBZ8) //Exibe campos com erros
	Endif
Endif

//Retorna para linha que estava
oBZ5:GoLine(nLnAtual)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PlExcLanc
Exclui lan�amentos da BZ5, Inclui em registros exclu�dos na BZ8 e SYP
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function PlExcLanc(oBZ5,aValidBZ8)

Local nI	:= 0
//Verifico se o objeto oCmpExBZ8 est� preenchido, se n�o, carrego
PlExsBZ8()

For nI := 1 To len(aValidBZ8)

	oBZ5:GoLine(aValidBZ8[nI][1])
	If aValidBZ8[nI][2]

		//Grava dados na BZ8
		dbSelectArea("BZ8")
   		BZ8->(RecLock("BZ8",.T.)) 
			BZ8->BZ8_FILIAL := xFilial("BZ5")
			BZ8->BZ8_CODIGO := oBZ5:getValue("BZ5_CODIGO")
			BZ8->BZ8_NUMLCT := oBZ5:getValue("BZ5_NUMLCT")
			BZ8->BZ8_CODLCT := oBZ5:getValue("BZ5_CODLCT")
			
			//Campos existem no cliente, mas n�o no ATUSX ou compatibilizador......
			iif(oCmpExBZ8["FICMAT"], BZ8->BZ8_FICMAT := oBZ5:getValue("BZ5_FICMAT"), "")
			iif(oCmpExBZ8["DATLCT"], BZ8->BZ8_DATLCT := oBZ5:getValue("BZ5_DATLCT"), "")
			iif(oCmpExBZ8["VLRLCT"], BZ8->BZ8_VLRLCT := oBZ5:getValue("BZ5_VLRLCT"), "")
			iif(oCmpExBZ8["TIPLCT"], BZ8->BZ8_TIPLCT := oBZ5:getValue("BZ5_TIPLCT"), "")
			iif(oCmpExBZ8["SALDO" ], BZ8->BZ8_SALDO  := oBZ5:getValue("BZ5_SALDO") , "")
			iif(oCmpExBZ8["TIPCLA"], BZ8->BZ8_TIPCLA := oBZ5:getValue("BZ5_TIPCLA"), "")
		BZ8->(MsUnLock())
		//Registra campo na SYP
		MSMM(,TamSx3("BZ8_OBSEXC")[1],,oBZ5:getValue("OBSEXC")  ,1,,,"BZ8","BZ8_CODMEM")

		//Deleta registro no grid da BZ5
		oBZ5:SetNoDeleteLine( .F. )
		oBZ5:DeleteLine()
		oBZ5:SetNoDeleteLine( .T. )

	Endif
Next

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldBZ5BZ8
Valida se o campo observa��o de exclus�o foi preenchido e armazena 
linhas que dever�o ser deletadas. Caso haja erros, devolver� uma 
lista com os itens cr�ticados 
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function VldBZ5BZ8(oBZ5,lBZ8ok,lHaExc)

Local aRetorno 	:= {,,,}	//Estrutura de retorno {nLinha,lMarcadoExcluit,lCampoObserva��o}
Local nLinhaExe	:= 0 	//Linha que est� sendo tratada
Local cObserExcl:= ""	//Campo observa��o de exclus�o
Local lExcluir	:= .F.	//CheckBox de Excluir
Local lValidOk	:= .F. 	//Campo de observa��o preenchido corretamente
Local cNumLct	:= ""

nLinhaExe	:= oBZ5:GetLine()
cObserExcl	:= oBZ5:getValue("OBSEXC")
lExcluir	:= oBZ5:getValue("CHKEXC")
cNumLct		:= oBZ5:getValue("BZ5_NUMLCT")

//Verifica se o campo de observa��o foi preenchido
If lExcluir
	lHaExc := .T.
	If !Empty(cObserExcl)
		lValidOk := .T.
	Else
		lBZ8ok := .F. //Se h� pelo menos um item errado, n�o chamar� a fun��o que exclui lan�amentos
	Endif
Endif

aRetorno := {nLinhaExe,lExcluir,lValidOk,cNumLct}

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} PlListErro
Lista linhas com problemas
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function PlListErro(aValidBZ8)

Local aErros	:= {}
Local nI 		:= 0

For nI := 1 To len(aValidBZ8)
	
	If !aValidBZ8[nI][3] .And. aValidBZ8[nI][2]
		aadd(aErros,{aValidBZ8[nI][1],aValidBZ8[nI][4],"Campo 'Observa��o de Exclus�o' obrigat�rio para excluir."})
	Endif
Next

PLSCRIGEN(aErros,{ {"Linha","@N",3},{"Num. Lan�amento","@C",10},{"Descri��o","@C",60} },"N�o foi poss�vel excluir os itens selecionados devido aos seguintes erros")

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} PlHabEdit
Habilita para edi��o o campo de observa��o de exlus�o
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------

Static Function PlHabEdit(oModel)

Local oBZ5		:= oModel:getmodel("BZ5Detail")
Local lChkExc	:= oBZ5:getValue("CHKEXC")

If lChkExc == .T.
	Return .T.
Else
	oBZ5:loadvalue("OBSEXC","")
	Return .F.
Endif

//-------------------------------------------------------------------
/*/{Protheus.doc} PlComBz4
Commita o modelo e invoca as fun��es que dependem de um commit antes.
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function PlComBz4(oModel)

Local oBZ4 := oModel:getmodel("BZ4MASTER")

SlvObsBZ4(oBZ4)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PlExsBZ8
Verifica se existe os campos abaixo na BZ8, pois os campos existem na base do cliente, mas no ATUSX e compatibilizadores n�o, 
mas em hist�rico de fontes, encontramos men��o....
Ent�o, fazemos fieldpos, se existir, vai gravar.....
@since 07/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function PlExsBZ8()
local oDados := JsonObject():New()

if (oCmpExBZ8 == NIL )	
	oDados["FICMAT"] := BZ8->(FieldPos('BZ8_FICMAT')) > 0
	oDados["DATLCT"] := BZ8->(FieldPos('BZ8_DATLCT')) > 0
	oDados["VLRLCT"] := BZ8->(FieldPos('BZ8_VLRLCT')) > 0
	oDados["TIPLCT"] := BZ8->(FieldPos('BZ8_TIPLCT')) > 0
	oDados["SALDO"]  := BZ8->(FieldPos('BZ8_SALDO'))  > 0
	oDados["TIPCLA"] := BZ8->(FieldPos('BZ8_TIPCLA')) > 0
	oCmpExBZ8 := oDados
endif	
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA281Imp

//Imprime a ficha de matricula com o Layout antigo

@since 07/2022
@version P12
/*/
//-------------------------------------------------------------------

Function PLSA281Imp()
Local cCdOper := PLSINTPAD()
PLSR261(cCdOper, BAU->BAU_CODIGO, BAU->BAU_CODIGO, dDataBase)
Return
