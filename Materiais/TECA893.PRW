#include "TECA893.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

STATIC nPosRec  := 1 // posicao do array da TFS em relacao a TFG
STATIC aDados   := {}
STATIC cRetProd	:= ""

//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Retorno Material de Implanta��o 

@Return 	model
@author 	Servi�os
@since 		17/08/2015
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel	:= Nil
Local oStrCab	:= FWFormStruct(1,"TFL")
Local oStrTFG := FWFormStruct(1,"TFG")
Local oStrTFS := FWFormStruct(1,"TFS")
Local bCommit 		:= {|oModel| At893Commit(oModel)}

aAux := FwStruTrigger("TFS_PRODUT","TFS_DPROD","At893DscPr()",.F.,Nil,Nil,Nil)
oStrTFS:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

oModel := MPFormModel():New("TECA893", /*bPreValidacao*/,/*{|oModel|at893pos(oModel)}*/,bCommit,/*bCancel*/ )

//Criando master falso para a alimenta��o dos details.
oModel:AddFields("000MASTER",/*cOwner*/,oStrCab, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:AddGrid( "TFGDETAIL", "000MASTER", oStrTFG,/*bLinePre*/,/*{|oModel| At581VlTW1(oModel)}*/,/*bPreVal*/ ,/*bPosVal*/ , {|oModel| SelecTFG(oModel) } )
oModel:SetDescription(STR0014) //"Retorno Material de Implanta��o"
 
oModel:AddGrid( "TFSDETAIL", "TFGDETAIL", oStrTFS,{|oMdlG,nLine,cAcao,cCampo,xValue,xOldValue| PreLinTFS(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue) },/*bPosValidacao*/,/*bPreVal*/ ,/*bPosVal*/ , {|oModel| SelecTFS(oModel) } )
oModel:SetRelation( "TFSDETAIL", { { "TFS_FILIAL", "xFilial('TFS')" }, { "TFS_CODTFG", "TFG_COD" } }, TFS->(IndexKey(3)) )
oModel:SetDescription(STR0014) 

oStrTFS:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)
oStrTFS:SetProperty( "TFS_PRODUT", MODEL_FIELD_OBRIGAT,.T.)
oStrTFS:SetProperty( "TFS_QUANT" , MODEL_FIELD_OBRIGAT,.T.)
oStrTFS:SetProperty( "TFS_LOCAL" , MODEL_FIELD_OBRIGAT,.T.)
oStrTFS:SetProperty( "TFS_TM"    , MODEL_FIELD_OBRIGAT,.T.)


oStrTFS:SetProperty( "TFS_CODTFL", MODEL_FIELD_INIT, {|oMdl| oMdl:GetModel():GetModel("000MASTER"):GetValue("TFL_CODIGO") } )
oStrTFS:SetProperty( "TFS_CODTFG", MODEL_FIELD_INIT, {|oMdl| oMdl:GetModel():GetModel("TFGDETAIL"):GetValue("TFG_COD") } )
oStrTFS:SetProperty( "TFS_DPROD",  MODEL_FIELD_INIT, {|| "" }  )
oStrTFS:SetProperty( "TFS_MOV"  , MODEL_FIELD_INIT, {|| "2" } ) //tipo movimento de retorno

// Pr� Valida��o de Edi��o
oStrTFS:SetProperty("TFS_TM", MODEL_FIELD_VALID,{ |oModel| At893TM(oModel,'TFS_TM')})
oStrTFS:SetProperty("TFS_QUANT", MODEL_FIELD_VALID,{ |oModel,cFld| at893pre(oModel, cFld)})

oStrTFG:SetProperty('TFG_PRCVEN',MODEL_FIELD_OBRIGAT,.F.)
oStrTFG:SetProperty('TFG_TES',MODEL_FIELD_OBRIGAT,.F.)

oModel:GetModel('TFGDETAIL'):SetOptional(.T.)
oModel:GetModel('TFSDETAIL'):SetOptional(.T.)

oModel:getModel('TFGDETAIL'):SetNoInsertLine()
oModel:getModel('TFGDETAIL'):SetNoDeleteLine()

//Desabilita a Grava��o automatica do Model 
oModel:GetModel( '000MASTER'):SetOnlyQuery ( .T. )
oModel:SetPrimarykey({})

Return(oModel)

//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View - Relacionamentos - Gest�o de Escalas 

@Return 	view
@author 	Servi�os
@since 		17/08/2015
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel	:= FWLoadModel("TECA893")
Local oStrCab	:= FWFormStruct( 2, "TFL" , {|cCpo| AllTrim(cCpo)$'TFL_CONTRT+TFL_LOCAL' }) 
Local oStrTFG	:= FWFormStruct( 2, "TFG" , /*{|cCpo| AllTrim(cCpo)$'TFG_COD+TFG_LOCAL' }*/  )
Local oStrTFS	:= FWFormStruct( 2, "TFS" , /*{|cCpo| AllTrim(cCpo)$'TFS_COD+TFSG_CODTFG' }*/ )

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddUserButton(STR0001,"",{|oView| At893Res(oModel)},,,) //"Eliminar res�duo" 
oView:AddField('FORM_FAKE',oStrCab	,'000MASTER') //Cabe�alho falso
oView:AddGrid('VIEW_TFG'	,oStrTFG ,'TFGDETAIL' ) //Retorno Material de Implanta��o
oView:AddGrid('VIEW_TFS'	,oStrTFS ,'TFSDETAIL' ) //Historico MI

oView:CreateHorizontalBox('BOXCABEC'	 , 0) //Cabe�alho
oView:CreateHorizontalBox ( 'SUPERIOR' , 30 )
oView:CreateHorizontalBox ( 'INFERIOR' , 70 )

oView:SetOwnerView('FORM_FAKE'	,'BOXCABEC' )	// Cabe�alho
oView:SetOwnerView( 'VIEW_TFG' , 'SUPERIOR' ) 
oView:SetOwnerView( 'VIEW_TFS' , 'INFERIOR' )

oStrTFG:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
oStrTFS:SetProperty('TFS_PRODUT',MVC_VIEW_CANCHANGE,.T.)
oStrTFS:SetProperty('TFS_CODTFG',MVC_VIEW_CANCHANGE,.F.)
oStrTFS:SetProperty('TFS_MOV',MVC_VIEW_CANCHANGE,.F.)
oStrTFS:SetProperty('TFS_PRODUT',MVC_VIEW_LOOKUP,'TFSRET' ) //consulta especifica

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} SelecTFG
	Fun��o que realiza a carga dos dados no grid dos itens de material de implanta��o
@sample 	SelecTFG()
@since		18/08/2015       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function SelecTFG(oModel)
Local aRet    	:= {}
Local cTmpQry  	:= GetNextAlias()
Local cCodTFL	:= FWFLDGET("TFL_CODIGO")
Local lOrcPrc
Local aArea := GetArea()
Local cRevTFL      := FWFLDGET("TFL_CONREV")

DbSelectArea("TFJ")
DBSetOrder(1)
lOrcPrc := DbSeek(xFilial("TFJ") + FWFLDGET("TFL_CODPAI")) .AND. !EMPTY(TFJ->TFJ_CODTAB)
RestArea(aArea)

aDados:={}
nPosRec:= 1

If lOrcPrc
	BeginSql Alias cTmpQry
		
		COLUMN TFG_PERINI AS DATE
		COLUMN TFG_PERFIM AS DATE
		
		SELECT  
		(Select B1_DESC FROM %Table:SB1% SB1 WHERE B1_COD = TFG_PRODUT AND SB1.%NotDel% AND %xFilial:SB1% = B1_FILIAL	) AS TFG_DESCRI,
		TFG.* 
		FROM %Table:TFL% TFL
		inner join %Table:TFG% TFG on %xFilial:TFL% = TFG_FILIAL 
				AND TFG_CODPAI = TFL_CODIGO  
				AND TFG.%NotDel% 
		WHERE	TFL.TFL_FILIAL = %xFilial:TFL% 	
		AND TFL_CODIGO =  %Exp:cCodTFL%
		AND TFG_CONREV =  %Exp:cRevTFL%
		AND TFL.%NotDel%
		AND TFG.%NotDel%
	EndSql
Else
	BeginSql Alias cTmpQry
	
		COLUMN TFG_PERINI AS DATE
		COLUMN TFG_PERFIM AS DATE
		
		SELECT  
		(Select B1_DESC FROM %Table:SB1% SB1 WHERE B1_COD = TFG_PRODUT AND SB1.%NotDel% AND %xFilial:SB1% = B1_FILIAL	) AS TFG_DESCRI,
		TFG.* 
		FROM %Table:TFL% TFL
		inner join %Table:TFF% TFF on %xFilial:TFL% = TFF_FILIAL AND TFF_CONTRT = TFL_CONTRT AND TFF.%NotDel%
		inner join %Table:TFG% TFG on %xFilial:TFL% = TFG_FILIAL 
				AND TFG_CODPAI = TFF_COD 
				AND TFG.%NotDel% 
		WHERE	TFL.TFL_FILIAL = %xFilial:TFL% 	
		AND TFL_CODIGO = %Exp:cCodTFL%
		AND TFF_CODPAI = %Exp:cCodTFL%
		AND TFG_CONREV = %Exp:cRevTFL%
		AND TFL.%NotDel%
		AND TFG.%NotDel%
	EndSql
EndIf

aRet := FwLoadByAlias( oModel, cTmpQry )

(cTmpQry)->(DbGoTop())
(cTmpQry)->(DbEval( {|| AADD(aDados,(cTmpQry)->(R_E_C_N_O_))} ))

(cTmpQry)->(DbCloseArea())

Return aRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} SelecTFS
	Fun��o que realiza a carga dos dados no grid dos itens de material de implanta��o
@sample 	SelecTFG()
@since		18/08/2015       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function SelecTFS(oModel)

Local aRet     := {}
Local cTmpQry  := ""
Local cFields  := "%"
Local oStruTFS := Nil
Local nLenFlds := 1
Local aFields  := {}
Local nX := 0

If Len(aDados) > 0
	oStruTFS := oModel:GetStruct()
	aFields  := oStruTFS:GetFields()
	nLenFlds := Len(aFields)
	For nX := 1 To nLenFlds
		If !aFields[nX][14]//Retirada dos campos virtuais
			cFields += aFields[nX, MODEL_FIELD_IDFIELD] + ", "
		EndIf
	Next nX
	cFields += "TFS.R_E_C_N_O_ RECNO%"

	DbSelectArea("TFG")
	TFG->(DbGoto(aDados[nPosRec]))
	cTmpQry := GetNextAlias()

	BeginSql Alias cTmpQry
		
		COLUMN TFS_DTAPON AS DATE
		
		SELECT
		(SELECT B1_DESC FROM %Table:SB1% SB1 WHERE B1_COD = TFS_PRODUT AND SB1.%NotDel% AND B1_FILIAL = %xFilial:SB1%) AS TFS_DPROD, 
		%Exp:cFields%
		FROM %Table:TFS% TFS
		WHERE TFS.TFS_FILIAL = %xFilial:TFS% 	
		AND TFS_CODTFG = %Exp:TFG->TFG_COD% 
		AND TFS.TFS_MOV = '2'
		AND TFS.%NotDel%
	EndSql

	aRet := FwLoadByAlias( oModel, cTmpQry, "TFS", "RECNO", /*lCopy*/, .T. )

	(cTmpQry)->(DbCloseArea())

	nPosRec++
EndIf
Return aRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} At893F3Cn

				A consulta padr�o de produto dever� realizar um distinct dos produtos 
				apontados e enviados para o posto. 

@sample		At893F3Cn 
	
@since		20/08/2015 
@version 	P12

@param		
/*/
//-------------------------------------------------------------------------------
Function At893F3Cn()

Local aCmpTFS		:= {}
Local cCampo1		:= ""
Local lOk			:= .F.
Local oDlgTFS 		//Dialog
Local oPanel 		//Objeto Panel
Local oFooter		//Rodap�
Local oListBox		//Grid campos
Local oOk			//Objeto Confirma 
Local oCancel		//Objeto Cancel
Local tmpTFS 		:= ""
Local oModel 		:= FWModelActive()
Local oViewTFS		:= FWViewActive()
Local oMdlTFG 		:= oModel:Getmodel("TFGDETAIL")
Local oMdlTFS		:= oModel:Getmodel("TFSDETAIL")
Local cCodTFG		:= oMdlTFG:GetValue("TFG_COD")

//A consulta padr�o de produto dever� realizar um distinct dos produtos apontados e 
//enviados para o posto. Para identificar estes produtos dever� ser utilizado o campo TFS_CODTFG 
//que deve ter o mesmo conte�do do campo TFG_COD (grid superior) e o campo TFS_MOV diferente de '2'. 
//Essa consulta dever� ser espec�fica e ser� a partir do campo TFS_PRODUT. 
//Os campos que devem ser exibidos para o usu�rio s�o: c�digo do produto, 
//descri��o do produto, unidade de medida e o total enviado.

//montar query
tmpTFS:=GetNextAlias()
BeginSql Alias tmpTFS
SELECT TFS_PRODUT,
    (SELECT B1_DESC FROM %table:SB1% SB1 
    	WHERE %xFilial:SB1% = B1_FILIAL 
	    	AND SB1.%NotDel%
	    	AND B1_COD = TFS_PRODUT) AS B1_DESC,
    (SELECT B1_UM FROM %table:SB1% SB1 
    	WHERE %xFilial:SB1% = B1_FILIAL 
	    	AND SB1.%NotDel% 
	    	AND B1_COD = TFS_PRODUT) AS B1_UM,
        TFS_QUANT
	FROM %Table:TFS% TFS
	INNER JOIN  %table:TFG% TFG ON %xFilial:TFG% = TFG_FILIAL
		AND TFG.TFG_COD = TFS.TFS_CODTFG
		AND TFS.TFS_CODTFG = %exp:cCodTFG%
	WHERE TFS.TFS_FILIAL = %xFilial:TFS%
	  AND TFS.TFS_MOV <> '2'
	  AND TFG.TFG_RESRET = 0
	  AND TFS.%NotDel%
EndSql

DbSelectArea(tmpTFS)
DbGoTop(tmpTFS)
While !EOF()
		AADD(aCmpTFS,{(tmpTFS)->TFS_PRODUT,; //produto
			 (tmpTFS)->B1_DESC,;        	  //descricao produto
			 (tmpTFS)->B1_UM ,; 		         // unidade de medida
			 (tmpTFS)->TFS_QUANT ,;		      //quantidade
			  })
	dBSkip()
Enddo
(tmpTFS)->(DbCloseArea())

If len(aCmpTFS) > 0
//	Cria a tela para a pesquisa dos campos e define a area a ser utilizada na tela 
	Define MsDialog oDlgTFS FROM 000, 000 To 200, 600 Pixel
		
	//Cria o panel principal
	@ 000, 000 MsPanel oPanel Of oDlgTFS Size 250, 350 // Coordenada para o panel
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
	aHeader:={STR0015,STR0016,STR0017,STR0018} // 'Produto','Descri��o','UM','Qtde Enviada'
	//cCampos:=""
	// Cria��o do grid para o panel	
	oListBox := TWBrowse():New( 40,05,204,100, ,aHeader,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,) // Campo#Descricao	  
	oListBox:SetArray(aCmpTFS) // Atrela os dados do grid com a matriz
	oListBox:bLine := { ||{aCmpTFS[oListBox:nAT][1],aCmpTFS[oListBox:nAT][2],aCmpTFS[oListBox:nAT][3],aCmpTFS[oListBox:nAT][4]}} // Indica as linhas do grid
	oListBox:bLDblClick := { ||Eval(oOk:bAction), oDlgTFS:End()} // Duplo clique executa a a��o do objeto indicado
	oListBox:Align := CONTROL_ALIGN_ALLCLIENT //Indica o preenchimento e alinhamento do browse
	
	// Cria o panel para os botoes	
	@ 000, 000 MsPanel oFooter Of oDlgTFS Size 000, 010 // Corrdenada para o panel dos botoes (size)
	oFooter:Align   := CONTROL_ALIGN_BOTTOM //Indica o preenchimento e alinhamento do panel (nao necessita das coordenadas)
		
	// Botoes para o grid auxiliar	
	@ 000, 000 Button oCancel Prompt STR0019  Of oFooter Size 030, 000 Pixel //Cancelar 
	oCancel:bAction := { || lOk := .F., oDlgTFS:End() }
	oCancel:Align   := CONTROL_ALIGN_RIGHT
	
	@ 000, 000 Button oOk     Prompt STR0020 Of oFooter Size 030, 000 Pixel //Confirmar  
	oOk:bAction     := { || lOk := .T.,(cCampo1:=aCmpTFS[oListBox:nAT][1]),oDlgTFS:End() } // Acao ao clicar no botao
	oOk:Align       := CONTROL_ALIGN_RIGHT // Alinhamento do botao referente ao panel
	// Ativa a tela exibindo conforme a coordenada
	Activate MsDialog oDlgTFS Centered		
	
	If lOk
		cRetProd := cCampo1
	EndIf	
Else
	lOk := .F.	
	Aviso( STR0002, STR0003, { STR0004 }, 2 )		//"Aten��o", "N�o existem itens para retornar"
Endif
Return lOk 

//-------------------------------------------------------------------
/*/{Protheus.doc} At893F3Ret 

			Retornar o c�digo do item selecionado na funacao consulta  
			itens para retorno material de implantacao

@sample		At893F3Ret
	
@since		20/08/2015 
@version 	P12

@param		
/*/
Function At893F3Ret()

Return cRetProd

//-------------------------------------------------------------------
/*/{Protheus.doc} At893DscPr 

			Retornar o descri��o do produto 

@sample		At893DscPr
	
@since		21/08/2015 
@version 	P12

@param		
/*/
//-------------------------------------------------------------------
Function At893DscPr()

Local oModel		:= FWModelActive()
Local oModelTFS	:= oModel:GetModel("TFSDETAIL")
Local cDesc:= ""
Local cPRod:= ""

cProd:=  oModelTFS:GetValue("TFS_PRODUT")
cDesc := Posicione("SB1",1,xFilial("SB1") + cProd ,"SB1->B1_DESC")

Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} At893TM(oModel,cCampo) 

			Validar tipo de movimento 

@sample		At893DscPr
	
@since		21/08/2015 
@version 	P12

@param		
/*/
Function At893TM(oModel,cCampo)

Local oModel		:= FWModelActive()
Local oModelTFS	:= oModel:GetModel("TFSDETAIL")
Local cCampo:=""
Local lRet:= .F.
Local cTipo:=""

//verificar se e tipo movimento de retorno

cTipo:=Posicione("SF5",1,xFilial("SF5")+oModelTFS:GetValue("TFS_TM"),"F5_TIPO")

If cTipo <> "D"
	lRet:= .F.
	Aviso( STR0005, STR0006,;
		 { 	STR0007 }, 2 )// "Retorno Material de Implanta��o", "Favor informar co�digo com tipo de movimento de Devolu��o " # "OK" 
Else
	lRet:= .T.
Endif

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At893Commit

Realiza a Grava��o dos Dados utilizando o Model
@sample   
@author  Servi�os
@since 	  24/08/15
@version P12
@param ExpO:Modelo de Dados da Tela Material de de Locais de Atendimento

@return ExpL: Retorna .T. quando houve sucesso na Grava��o
/*/
//--------------------------------------------------------------------------------------------------------------------

Function At893Commit(oModel)

Local lRetorno 	:= .T.
Local lConfirm 
Local nOperation	:= oModel:GetOperation()
//verificar se e inclusao, exclusao

lRetorno := At893ExcAt(oModel)


Return( lRetorno )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At893ExcAt

Realiza a Grava��o dos dados utilizando a ExecAuto MATA240 para inclus�o e estorno de retorno material implanta��o.
no Modulo Estoque
@sample  At893ExcAt() 
@author  Servi�os
@since 	  24/08/15
@version P12
@param ExpO:Modelo de Dados da Tela de Retorno Material de Implanta��o
@return ExpL: Retorna .T. quando houve sucesso na ExecAuto
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At893ExcAt(oModel)

Local aLinha		:= {}						// array que ser� passado com os valores no execauto para preencher a tabela 
Local lRetorno	:= .T.						// Validador de retorno, caso ocorra algum erro, ele retorna false, evitando que seja adicionado dados na tabela ABV
Local lAlter		:= .F.						// Ser� quem definir� se houve ou n�o altera��o em alguma linha do grid
Local xI			:= 1
Local xY			:= 1
Local aArea		:= GetArea()				// Pega posi��o GetArea()
Local aSaveLines	:= FWSaveRows()
Local aDados		:= {}
Local oModelTFS	:= oModel:GetModel("TFSDETAIL")
Local oModelTFG	:= oModel:GetModel('TFGDETAIL')
Local cProduto	:= ""
Local cArmazem	:= ""

Private l185			:= .F.				 	// necessario para chamar a funcao de estorno MATA240
Private l240Auto		:= .T. 					// necessario para chamar a funcao de estorno MATA240
Private cCusMed			:= GetMv("MV_CUSMED") 	// necessario para chamar a funcao de estorno MATA240
Private lMsHelpAuto		:= .T. 	// Controle interno do ExecAuto
Private lMsErroAuto		:= .F. 	// Informa a ocorr�ncia de erros no ExecAuto
Private lAutoErrNoFile	:= .F.

// Verificar se � inclusao ou estorno

Begin Transaction

For xY	:= 1 To oModelTFG:Length()
	oModelTFG:GoLine(xY)
	For xI := 1 To oModelTFS:Length()			//	Percorrer� todo grid do retorno material de implanta��o
		aLinha:={}
		oModelTFS:GoLine(xI)				
		aSaveLines	:= FWSaveRows()
		If !oModelTFS:IsDeleted() 				//	Verifica se � uma linha deletada
			// Verifica o tipo de movimento retorno = 2 e se ainda nao gerou execauto
			If oModelTFS:GetValue("TFS_MOV") == '2' .And. Empty(oModelTFS:GetValue("TFS_NUMMOV")) .And. oModelTFS:GetValue("TFS_QUANT") > 0
				// Cria Saldos no Armazem (SB2) se nao existir
				cProduto := oModelTFS:GetValue("TFS_PRODUT")
				cArmazem := oModelTFS:GetValue("TFS_LOCAL")
				SB2->(DbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
				If !SB2->(MsSeek(xFilial("SB2")+cProduto+cArmazem))
					CriaSB2(cProduto,cArmazem)
				EndIf
				// aLinha array que ser� enviado pelo execauto MATA240
				aadd(aLinha,{"D3_FILIAL"    ,xFilial("SD3")						,NIL})
				aadd(aLinha,{"D3_TM"        ,oModelTFS:GetValue("TFS_TM")		,NIL})
				aadd(aLinha,{"D3_COD"       ,oModelTFS:GetValue("TFS_PRODUT")	,NIL})
				aadd(aLinha,{"D3_QUANT"     ,oModelTFS:GetValue("TFS_QUANT")	,NIL})
				aadd(aLinha,{"D3_LOCAL"     ,oModelTFS:GetValue("TFS_LOCAL") 	,NIL})
				aadd(aLinha,{"D3_LOCALIZ"   ,oModelTFS:GetValue("TFS_LOCALI")	,NIL})
				aadd(aLinha,{"D3_CC"        ,oModelTFS:GetValue("TFS_CC")		,NIL})
				aadd(aLinha,{"D3_LOTECTL"   ,oModelTFS:GetValue("TFS_LOTECT")	,NIL})
				aadd(aLinha,{"D3_NUMLOTE"   ,oModelTFS:GetValue("TFS_NUMLOT")	,NIL})
				aadd(aLinha,{"D3_NUMSERI"   ,oModelTFS:GetValue("TFS_NUMSER")	,NIL})
				lMSErroAuto := .F.
				lMSHelpAuto := .T.
				MSEXECAUTO({|x|MATA240(x)},aLinha, 3)
				lMSHelpAuto := .F.
				If !lMsErroAuto
					lRetorno	:=	.T.
					// Atualiza numero do movimento
					oModelTFS:LoadValue("TFS_NUMMOV",SD3->D3_NUMSEQ)
					oModelTFG:LoadValue("TFG_SLD",(oModelTFG:GetValue("TFG_SLD") + oModelTFS:GetValue("TFS_QUANT")))
				Else
					DisarmTransaction()
					MostraErro()
					lRetorno	:=	.F.
					Exit
				EndIf
			Endif
		Elseif oModelTFS:IsDeleted() 		//	Verifica se � uma linha deletada
			// Fazer estorno do lancamento
			// Posicionar na SD3 e atualizar campo de estorno
			DbSelectArea("SD3") //D3_FILIAL+D3_NUMSEQ+D3_CHAVE+D3_COD
			DbSetOrder(4)
			If dbSeek(xFilial("SD3")+ oModelTFS:GetValue("TFS_NUMMOV"))
				nReg := SD3->(Recno())
				a240Estorn("SD3",nReg,5)
			Else
				MsgStop(STR0021) // "Registro n�o encontrado"
			Endif
		Endif		
	Next xI
Next xY

End Transaction

If lRetorno
	FWFormCommit(oModel)
EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  At893Res(oModel)

Fun��o para usu�rio eliminar residuo do iem selecionado
	
@sample  At893Res(oModel)
@author  Servi�os
@since 	  25/08/15
@version P12
@param 
@return ExpL: Retorna .T. quando houve sucesso 
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At893Res(oModel)

Local lRet				:= .F.
Local oModelTFG		:= oModel:GetModel("TFGDETAIL")
Local oModelTFS		:= oModel:GetModel("TFSDETAIL")
Local nQuant			:= oModelTFG:GetValue("TFG_QTDVEN")
Local nResiduo		:= 0
Local nQtTFS			:= 0
Local nTotQtde		:= 0
Local xI				:= 0
Local oView			:= FWViewActive()

//Para os casos em que o retorno n�o a
//contecer� e � necess�rio assumir a perda 
//pela prestadora do servi�o, deve ser criada a op��o para eliminar res�duo no bot�o outras a��es. 
//Esta op��o ir� utilizar a linha posicionada no grid superior e questionar o usu�rio se 
//realmente deseja lan�ar o saldo n�o retornado como res�duo. A pergunta deve ser semelhante a: 
//"Tem certeza que deseja lan�ar a quantidade xx como res�duo? Esse lan�amento n�o poder� ser desfeito.", 
//com a confirma��o do usu�rio o valor deve ser inserido no campo "Res�duo Eliminado" e 
//posteriormente gravado na tabela TFG campo TFG_RESRET.

If oModelTFG:GetValue("TFG_RESRET") == 0
	If oModelTFG:Length() = 0
		If MsgYesNo(STR0008 + Ltrim(str(nQuant)) + STR0009,STR0010)		//"Tem certeza que deseja lan�ar a quantidade xx como res�duo? Esse lan�amento n�o poder� ser desfeito." # "Confirma?" 
			lRet:= .T.
			oModelTFG:SetValue("TFG_RESRET",nQuant)
			oView:Refresh()
			MsgInfo(STR0022) // "Res�duo eliminado com sucesso"
		EndIf
	Else
		//verificar a quantidade a ser devolvida
		For xI:= 1 to oModelTFS:Length()
				oModelTFS:GoLine(xI)
				nQtTFS:=oModelTFS:GetValue("TFS_QUANT")
				nTotQtde:= nTotQtde +  nQtTFS
		Next xI
		nResiduo:= nQuant - nTotQtde
		If MsgYesNo(STR0011 + Ltrim(str(nResiduo)) + STR0012 ,STR0013)	//"Exite(m) item(ns) retornados anteriormente. Deseja mesmo assim eliminar o residuo? Esse lan�amento n�o poder� ser desfeito." ,"Confirma?") 	
			lRet:= .T.
			//somar a quantide de retorno
			oModelTFG:SetValue("TFG_RESRET",nResiduo)
			oView:Refresh()
		Endif
	Endif	
Else 
	MsgStop(STR0023)  //"Item com res�duo ja eliminado"  
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} at893pre 

Valida a quantidade dos valores para retorno, impedindo 
que sejam retornados mais quantidade do que foi apontado
			
@sample	at893pre
@since		24/04/2018
@version 	P12

@author	Diego A. Bezerra

/*/
//-------------------------------------------------------------------
Static Function at893pre(oModelTFS,cFld)

Local nSldApt	:= 0
Local nSldGrd	:= 0
Local nQuant	:= 0
Local cTpMov	:= ""
Local nX		:= 1
Local lRet		:= .F.
Local cCodTFG 	:= ""

If cFld == "TFS_QUANT"
	If POSITIVO(oModelTFS:GetValue("TFS_QUANT"))

		nSldApt := 0
		nSldGrd := 0
		cCodTFG := oModelTFS:GetValue("TFS_CODTFG")
	
		For nX := 1 To oModelTFS:Length()
			oModelTFS:GoLine(nX)
			If !oModelTFS:IsDeleted()
				nSldGrd := nSldGrd + oModelTFS:GetValue("TFS_QUANT")
			EndIf
		Next nX
	
		//montar query
		tmpQry1 := GetNextAlias()
		BeginSql Alias tmpQry1
			SELECT  TFS.TFS_PRODUT, TFS.TFS_QUANT, TFS.TFS_MOV
			FROM %Table:TFS% TFS
			WHERE TFS.TFS_FILIAL = %xFilial:TFS%
			AND TFS_CODTFG = %Exp:cCodTFG%
			AND TFS.%NotDel%
		EndSql
	
		While (tmpQry1)->(!EOF())
			//verificar saldo
			nQuant:= (tmpQry1)->TFS_QUANT
			cTpMov:= (tmpQry1)->TFS_MOV
			If cTpMov == "1"
				nSldApt := nSldApt + nQuant
			Endif
			(tmpQry1)->(DbSkip())
		Enddo
		(tmpQry1)->(DbCloseArea())
		lRet :=	nSldGrd <= nSldApt
		If !lRet
			Help(,,"at893pre",,STR0025,1,0) // "Saldo insuficiente para esta quantidade!"
		Endif
	EndIf
EndIf
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTFS
@description Fun��o de Prevalidacao da grade de retorno de MI
@sample 	PreLinTFL(oMdlG, nLine, cAcao, cCampo, xValor, xValorAnt)
@param		[oMdlG],objeto,Representando o modelo de dados.
@param		[nLine],numerico,Numero da linha em edi��o
@param		[cAcao],Caractere,A��o sendo executada.
@param		[cCampo],Caractere,Campo onde o cursor est� posicionado.
@param		[xValor],Indefinido,Novo valor inserido no campo.
@param		[xValorAnt],Indefinido,Antigo valor do campo.

@since	19/04/2023
@author	flavio.vicco
/*/
//------------------------------------------------------------------------------
Function PreLinTFS(oMdlG, nLine, cAcao, cCampo, xValue, xOldValue)
Local aArea      := GetArea()
Local aSaveLines := FWSaveRows()
Local lRet       := .T.

FWModelActive(oMdlG)

If cAcao == "CANSETVALUE"
	If !Empty(oMdlG:GetValue("TFS_NUMMOV"))
		lRet := .F.
	EndIf
EndIf

FWRestRows( aSaveLines )
RestArea(aArea)
Return lRet
