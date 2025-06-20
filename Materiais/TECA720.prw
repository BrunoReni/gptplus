#INCLUDE "Protheus.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA720.CH"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA720

Cadastro de Coletes - TE1
@author Servi�os
@since 28/08/13

/*/
//----------------------------------------------------------------------------------------------------------------------
Function TECA720()
Local oBrowse

Private aRotina	:= MenuDef() 
Private cCadastro	:=STR0001// Cadastro de Coletes

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('TE1')
oBrowse:SetDescription(STR0001) // Cadastro de Coletes
oBrowse:Activate()

Return
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defini��o do MenuDef
@author Servi�os
@since 20/08/13
@version P11 R9

@return ExpO:aRotina
/*/
//--------------------------------------------------------------------------------------------------------------------
Static function MenuDef()
Local aRotina :={}

ADD OPTION aRotina TITLE STR0002 	ACTION 'PesqBrw' 				OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION 'VIEWDEF.TECA720' 	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION 'VIEWDEF.TECA720' 	OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005	ACTION 'VIEWDEF.TECA720' 	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 	ACTION 'VIEWDEF.TECA720' 	OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0007	ACTION 'MSDOCUMENT'			OPERATION 7 ACCESS 0 //"Bco. Conhecimento"

Return(aRotina)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Defini��o do Model 
@author Servi�os
@since 20/08/13
@version P11 R9

@return ExpO:oModel
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStruTE1			:= FWFormStruct(1,'TE1')
Local bPosValidacao	:= {|oModel|At720Vld(oModel)}
Local aAux				:= {}
Local aAux1			:= {}
Local aAux2			:= {}
Local bCommit			:= {|oModel|At720Commit(oModel)}

If TE1->(ColumnPos("TE1_FILLOC")) > 0 .And. FindFunction("TecMtFlArm") .And. TecMtFlArm()
	oStruTE1:SetProperty('TE1_LOCAL' ,MODEL_FIELD_VALID,{|oModel| At720VldLc(oModel)})
Endif
aAux := FwStruTrigger("TE1_LOJA","TE1_NOME","At720DescFor(1),At720DescFor(2)",.F.,Nil,Nil,Nil)
oStruTE1:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

aAux1 := FwStruTrigger("TE1_CODPRO","TE1_DESPRO","At720DescPro()",.F.,Nil,Nil,Nil)
oStruTE1:AddTrigger(aAux1[1],aAux1[2],aAux1[3],aAux1[4])

aAux2 := FwStruTrigger("TE1_LOCAL","TE1_CLIDES","At720DscLoc()",.F.,Nil,Nil,Nil)
oStruTE1:AddTrigger(aAux2[1],aAux2[2],aAux2[3],aAux2[4])

oModel := MPFormModel():New('TECA720',/*bPreValidacao*/,bPosValidacao,bCommit,/*bCancel*/)
oModel:AddFields('TE1MASTER',/*cOwner*/,oStruTE1,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/,/*bFieldAbp*/)

oModel:SetPrimaryKey({"TE1_FILIAL","TE1_COD"})

Return(oModel)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Defini��o da View 
@author Servi�os
@since 20/08/13
@version P11 R9

@return ExpO:oView
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel   	:= FWLoadModel('TECA720')
Local oStruTE1 	:= Nil

oStruTE1 	:= FWFormStruct(2,'TE1',{|cCampo| !AllTrim(cCampo) $ "TE1_SINARM|TE1_DTSINA"})

oView:= FWFormView():New()
oView:SetModel(oModel)

oView:AddUserButton(STR0007, 'CLIPS',{|oView|MsDocument('TE1',TE1->(RECNO()),oModel:GetOperation() )}) //"Bco. Conhecimento"

//Adiciona o Link para Consulta do C.A
//oView:AddUserButton(STR0008,"",{|oView|coTIBrowse(oModel)},,,) //Consulta C.A

oView:AddUserButton(STR0019, 'CLIPS',{|oView| At720Ocorr(FwFldGet("TE1_CODCOL"))}) //"Ocorrencias"

oView:AddUserButton(STR0020, 'CLIPS',{|oView| At720Manut(FwFldGet("TE1_CODCOL"))}) //"Manuten��es"

oView:AddUserButton(STR0021, 'CLIPS',{|oView| At720Movim(FwFldGet("TE1_CODCOL"))}) //"Movimenta��es"

oStruTE1:RemoveField("TE1_ORIGEM")
oStruTE1:RemoveField("TE1_ENTIDA")
oStruTE1:RemoveField("TE1_PRVRET")
oStruTE1:RemoveField("TE1_CODMOV")

If TE1->(ColumnPos("TE1_FILLOC")) > 0 .And. FindFunction("TecMtFlArm")
	If !TecMtFlArm()
		oStruTE1:RemoveField("TE1_FILLOC")
	Else
		oStruTE1:SetProperty("TE1_FILLOC", MVC_VIEW_ORDEM, "34")
		oStruTE1:SetProperty("TE1_LOCAL", MVC_VIEW_LOOKUP, "TERFIL")
	Endif
EndIf
oView:AddField('VIEW_CAB',oStruTE1,'TE1MASTER')
oView:CreateHorizontalBox('SUPERIOR',100)
oView:SetOwnerView( 'VIEW_CAB','SUPERIOR' )

Return(oView)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At720Imp

Inclus�o do Colete quando � adicionado uma nota Fiscal de Entrada
@author Servi�os
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na opera��o
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At720Imp(cCodCol)
Local oModel
Local oAux
Local lRet 		:= .T.
Local aAreaSD1 	:= SD1->(GetArea())
Local aAreaSA2 	:= SA2->(GetArea())
Local nQuant		:= 0
Local lAux 		:= .T.
Local lAutomato
Default cCodCol := ""

lAutomato := !EMPTY(cCodCol)

DbSelectArea('SD1')
SD1->(DbSetOrder(2)) // A1_FILIAL+A1_COD+A1_LOJA
If SD1->(DbSeek(xFilial('SD1')+ SD1->D1_COD + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA)) // Filial: 01, C�digo: 000001, Loja: 02

	DbSelectArea('SA2')
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2") + SD1->D1_FORNECE + SD1->D1_LOJA))

	For nQuant:= 1 To SD1->D1_QUANT

		oModel:=FwloadModel('TECA720')
		oModel:SetOperation(3)
		oModel:Activate()
			
		oAux:= oModel:GetModel('TE1MASTER')
		If !EMPTY(cCodCol)
			oModel:LoadValue('TE1MASTER','TE1_CODCOL',cCodCol)
		EndIf
		lAux:= oModel:SetValue('TE1MASTER','TE1_DOC',SD1->D1_DOC)
		lAux:= lAux .AND. oModel:SetValue('TE1MASTER','TE1_SERIE',SD1->D1_SERIE)
		
		//Atualiza campo _SDOC dos documentos fiscais, caso habilitado
		If SerieNFId("TE1", 3, "TE1_SERIE") != "TE1_SERIE"
			lAux:= lAux .AND. oModel:SetValue('TE1MASTER',SerieNFId("TE1", 3, "TE1_SERIE"), SerieNFId("SD1", 2, "D1_SERIE"))
		EndIf
		
		lAux:= lAux .AND. oModel:SetValue('TE1MASTER','TE1_DTNOTA',SD1->D1_EMISSAO)
		lAux:= lAux .AND. oModel:SetValue('TE1MASTER','TE1_COMPRA',SD1->D1_EMISSAO)
		lAux:= lAux .AND. oModel:SetValue('TE1MASTER','TE1_CODFOR',SD1->D1_FORNECE)
		lAux:= lAux .AND. oModel:SetValue('TE1MASTER','TE1_LOJA',SD1->D1_LOJA)
		lAux:= lAux .AND. oModel:SetValue('TE1MASTER','TE1_CODPRO',SD1->D1_COD)
		lAux:= lAux .AND. oModel:SetValue('TE1MASTER','TE1_ITEM',SD1->D1_ITEM)
		lAux:= lAux .AND. oModel:SetValue('TE1MASTER','TE1_SEQ',cValtoChar(nQuant))
		lAux:= lAux .AND. oModel:SetValue('TE1MASTER','TE1_ORIGEM',"MATA103")
		lAux:= lAux .AND. oModel:SetValue('TE1MASTER','TE1_NOME',SA2->A2_NOME)
		lAux:= lAux .AND. oModel:SetValue('TE1MASTER','TE1_CNPJ',SA2->A2_CGC)
						
		If ( lRet := ( lAux .AND. oModel:VldData() ) )
			// Se o dados foram validados faz-se a grava��o efetiva dos dados (commit)
			oModel:CommitData()
		EndIf
		
	
		If !lRet .OR. lAutomato
			// Se os dados n�o foram validados obtemos a descri��o do erro para gerar LOG ou 
			//mensagem de aviso
			aErro := oModel:GetErrorMessage()
					 
			AutoGrLog( STR0009 + ' [' + AllToChar( aErro[1] ) + ']' ) //"Id do formul�rio de origem:"
			AutoGrLog( STR0010 + ' [' + AllToChar( aErro[2] ) + ']' ) //"Id do campo de origem: "
			AutoGrLog( STR0011 + ' [' + AllToChar( aErro[3] ) + ']' ) // "Id do formul�rio de erro: "
			AutoGrLog( STR0012 + ' [' + AllToChar( aErro[4] ) + ']' ) //"Id do campo de erro: "
			AutoGrLog( STR0013 + ' [' + AllToChar( aErro[5] ) + ']' ) //"Id do erro: "
			AutoGrLog( STR0014 + ' [' + AllToChar( aErro[6] ) + ']' ) // "Mensagem do erro: "
			AutoGrLog( STR0015 + ' [' + AllToChar( aErro[7] ) + ']' ) //"Mensagem da solu��o: "
			AutoGrLog( STR0016 + ' [' + AllToChar( aErro[8] ) + ']' ) //"Valor atribu�do: "
			AutoGrLog( STR0017 + ' [' + AllToChar( aErro[9] ) + ']' )//"Valor anterior: "
			If !lAutomato
				MostraErro()
			EndIf
			// Desativamos o Model 
			oModel:DeActivate()
		EndIf
			
	Next nQuant

EndIf

RestArea(aAreaSD1)
RestArea(aAreaSA2)

Return lRet
		
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} coTIBrowse

Realiza a abertura do Link para verifica��o do C.A do Fornecedor
@author Servi�os
@since 20/08/13
@version P11 R9

@Param oModel,Model do Cadastro
/*/
//--------------------------------------------------------------------------------------------------------------------
/*Function coTIBrowse(oModel)
Local oDlg
Local�aSize	:=	{}
Local�oMdl		:=�oModel:GetModel("TE1MASTER")�
Local cUrl		:= SuperGetMV("MV_TECURL",,"") //"http://www3.mte.gov.br/sistemas/caepi/PesquisarCAInternetXSL.asp"	

aSize	:=	MsAdvSize()

oMainWnd:CoorsUpdate()��// Atualiza as corrdenadas da Janela MAIN
nMyWidth��:=�oMainWnd:nClientWidth�-�10
nMyHeight�:=�oMainWnd:nClientHeight�-�30

DEFINE�DIALOG�oDlg�TITLE�STR0001�From�aSize[7],00�To�nMyHeight,nMyWidth�PIXEL //"Cadastro de Coletes"

oTIBrowser�:=�TIBrowser():New(05,05,nMyHeight-250,�nMyWidth-820,cUrl,oDlg )
oTIBrowser:GoHome()

ACTIVATE�DIALOG�oDlg�CENTERED�
Return*/

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At720Vld

Pos-Valida��o do cadastro de Coletes 
@author Servi�os
@since 20/08/13
@version P11 R9

@Param oModel,Model do Cadastro
@Return ExpL: Retorna .T. quando houve sucesso na Inclus�o
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At720Vld(oModel)
Local lRet       := .T.
Local nOperation := oModel:GetOperation()
Local lMultFil	 := TE1->(ColumnPos("TE1_FILLOC")) > 0 .And. FindFunction("TecMtFlArm") .And. TecMtFlArm()
Local cFilBkp 	 := cFilAnt

//N�o permite a exclus�o quando a Situa��o for diferente de 1 ou foi alocado
If nOperation == MODEL_OPERATION_DELETE
	If FwFldGet("TE1_SITUA") <> "1" .Or. !Empty(FwFldGet("TE1_LOCAL"))
		Help( "", 1, "At720Situa" )
		lRet := .F.
	EndIf
	
	If !Empty(FwFldGet("TE1_DOC"))
	 	Help(" ", NIL, STR0029,, STR0030, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0031})//N�o � permitido excluir este armamento, pois est� vinculado a uma nota fiscal
	    lRet := .F.
    EndIf
EndIf

If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) .And. (!Empty(FwFldGet("TE1_LOCAL")))
	If !At720Status()
		Help( "", 1, "At720Status" )
		lRet := .F.	
	EndIf
EndIf

If lRet .And. lMultFil .And. (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)
	If !Empty(oModel:GetValue("TE1MASTER","TE1_LOCAL")) .And. Empty(oModel:GetValue("TE1MASTER","TE1_FILLOC"))
		Help( , , "At720Vld", , STR0032, 1, 0,,,,,,{STR0033}) //"N�o foi preenchido a filial."#"Realize o preenchimento da filial."
		lRet := .F.
	Endif

	If lRet .And. !Empty(oModel:GetValue("TE1MASTER","TE1_LOCAL"))

		If cFilAnt <> oModel:GetValue("TE1MASTER","TE1_FILLOC")
			cFilAnt := oModel:GetValue("TE1MASTER","TE1_FILLOC")
		Endif

		DbSelectArea("TER")
	 	TER->(DbSetOrder(1))
		If !TER->(DbSeek(xFilial("TER")+oModel:GetValue("TE1MASTER","TE1_LOCAL")))
			Help( , , "At720Vld", , STR0034, 1, 0,,,,,,{STR0035}) //"N�o foi encontrado o local."#"Realize o preenchimento do local corretamente."
			lRet := .F.
		Endif

		If cFilBkp <> cFilAnt
			cFilAnt := cFilBkp
		Endif

	Endif
EndIf
Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At720DescFor

Realiza o preenchimento da descri��o do Fornecedor e do CNPJ do Fornecedor
@author Servi�os
@since 20/08/13
@version P11 R9

@Param nPos,Indica qual o campo que ser� preenchido
@return ExpL:Retorna .T. quando houve sucesso na opera��o
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At720DescFor(nPos)
Local cDesc		:= ""
Local oModel
Local aAreaSA2 	:= SA2->(GetArea())

Default nPos := 0

If nPos > 0
	DbSelectArea("SA2")
	SA2->(DbSetOrder(1))
	
	If SA2->(DbSeek(xFilial("SA2") + FwFldGet("TE1_CODFOR") + FwFldGet("TE1_LOJA")))
		If nPos == 1
			oModel := FWModelActive()
			oModel:setValue("TE1MASTER",'TE1_CNPJ',SA2->A2_CGC)
		ElseIf nPos == 2
			cDesc := SA2->A2_NOME
		EndIf	
	EndIf
EndIf

RestArea(aAreaSA2)
					
Return(cDesc)	

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At720DescPro

Realiza o preenchimento da descri��o do Produto
@author Servi�os
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na opera��o
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At720DescPro()
Local cDesc		:= ""
Local aAreaSB1		:= SB1->(GetArea())

cDesc := Posicione("SB1",1,xFilial("SB1") + FwFldGet("TE1_CODPRO"),"SB1->B1_DESC")

RestArea(aAreaSB1)

Return(cDesc)	

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At720DscLoc

Realiza o preenchimento da descri��o do Local Interno
@author Servi�os
@since 20/08/13
@version P11 R9

@return ExpC:Retorna a Descri��o do Local Interno
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At720DscLoc()
Local cLocal		:= ""
Local aAreaTER		:= TER->(GetArea())
Local lMultFil	 	:= TE1->(ColumnPos("TE1_FILLOC")) > 0 .And. FindFunction("TecMtFlArm") .And. TecMtFlArm()
Local cFilBkp  		:= cFilAnt

If lMultFil .And. FwFldGet("TE1_FILLOC") <> cFilAnt
	cFilAnt := FwFldGet("TE1_FILLOC")
Endif

cLocal	:= Posicione("TER",1,xFilial("TER") + FwFldGet("TE1_LOCAL"),"TER->TER_DESCRI")

If lMultFil .And. cFilBkp <> cFilAnt
	cFilAnt := cFilBkp
Endif

RestArea(aAreaTER)

Return(cLocal)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At720When

Habilita os campos Forncedor e Produto quando a Origem n�o for MATA103
@author Servi�os
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na opera��o
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At720When()
Local lRet 		:= .T.
Local oModel		:= FWModelActive() 
Local nOperation	:= oModel:GetOperation()

//N�o deixa alterar o fornecedor e o produto quando o mesmo tiver vinculo com Nota Fiscal
If nOperation == MODEL_OPERATION_UPDATE .AND. Alltrim(TE1->TE1_ORIGEM) == "MATA103"
	lRet := .F.
EndIf

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At720WLocal

Desabilita o campo de Local quando ele j� est� preenchido
@author Servi�os
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na opera��o
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At720WLocal()
Local lRet 		:= .T.
Local oModel		:= FWModelActive() 
Local nOperation	:= oModel:GetOperation()

//N�o deixa alterar o fornecedor e o produto quando o mesmo tiver vinculo com Nota Fiscal
If nOperation == MODEL_OPERATION_UPDATE .AND. !Empty(TE1->TE1_LOCAL)
	lRet := .F.
EndIf

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At720Exc

Exclui o registro do Colete, atrav�s da exclus�o da NFE
Informa ao usuario e pergunta se ele deseja continuar com a Exclus�o
@author Servi�os
@since 20/08/13
@version P11 R9

@Param cDoc,Numero do Documento de Entrada
@Param cSerie,Numero da Serie do Documento de Entrada
@Param lExc, bool, se Verdadeiro, exclui o registro na TE1. Se falso, apenas mostra um MsgYesNo

@return ExpL:Retorna .T. quando houve sucesso na opera��o
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At720Exc(cDoc,cSerie,lExc,lAutomato)
Local lRet			:= .F.
Local aAreaTE1		:= TE1->(GetArea())

Default cDoc		:= ""
Default cSerie		:= ""
Default lExc	:= .F.
Default lAutomato := .F.

DbSelectArea("TE1")
DbSetOrder(2)

If TE1->(DbSeek(xFilial("TE1") + cDoc + cSerie)) .AND. Alltrim(TE1->TE1_ORIGEM) == "MATA103"
	If Empty(TE1->TE1_ENTIDA)
		If !lExc
			lRet := ( lAutomato .OR. MsgYesNo(STR0018) ) //"Essa Nota est� vinculada a um Colete Ativo no Cadastro de Coletes, Deseja Continuar?"
		Else
			While !TE1->(Eof()) .And. TE1->TE1_DOC == cDoc .And. TE1->TE1_SERIE == cSerie
				RecLock("TE1",.F.)
					TE1->( dbDelete() )
					TE1->( MsUnlock() )
				TE1->(dbSkip())
			End
		EndIf	
	Else
		Help( "", 1, "At720Mov" )	
	EndIf
EndIf

RestArea(aAreaTE1)

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At720Mov

Verifica se o Colete est� movimentado ou com o Status Frear alterado
@author Servi�os
@since 20/08/13
@version P11 R9

@Param cDoc,Numero do Documento de Entrada
@Param cSerie,Numero da Serie do Documento de Entrada

@return ExpL:Retorna .T. quando houve sucesso na opera��o
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At720Mov(cDoc,cSerie)
Local lRet			:= .T.
Local aAreaTE1		:= TE1->(GetArea())

Default cDoc		:= ""
Default cSerie		:= ""

DbSelectArea("TE1")
TE1->(DbSetOrder(2))

If TE1->(DbSeek(xFilial("TE1") + cDoc + cSerie))
	If  Alltrim(TE1->TE1_ORIGEM) == "MATA103" .AND. TE1->TE1_SITUA <> "1"
		lRet := .F.
	EndIf
EndIf

RestArea(aAreaTE1)

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At720Status

Verifica campos Obrigatorios para a troca de Status do Colete
@author Servi�os
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na opera��o
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At720Status()
Local lRet	:= .T.
Local aAreaSM0  	:= SM0->(GetArea())
Local oModel		:= FWModelActive() 
Local nOperation	:= oModel:GetOperation()

//Verifica se os campos est�o preenchidos para alterar o Status para Implantado
If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_INSERT
	If Empty(FwFldGet("TE1_NUMSER"))	
		lRet := .F.
	EndIf	
EndIf

RestArea(aAreaSM0)
Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At720VldProd

Valida o Tipo de Produto no cadastro, para n�o permitir a inclus�o de produtos que n�o
s�o do tipo Colete
@author Servi�os
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na opera��o
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At720VldProd()
Local lRet			:= .T.
Local aAreaSB5 	:= SB5->(GetArea())

DbSelectArea('SB5')
SB5->(DbSetOrder(1)) // acordo com o arquivo SIX -> A1_FILIAL+A1_COD+A1_LOJA

If SB5->(DbSeek(xFilial('SB5')+FwFldGet("TE1_CODPRO"))) // Filial: 01, C�digo: 000001, Loja: 02
			
	If SB5->B5_TPISERV <>'2' 
		Help("  ",1,"AT720Tipo")
		lRet := .F.		
	EndIf
Else
	Help("  ",1,"AT720Tipo")
	lRet := .F.		
EndIf
		
RestArea(aAreaSB5)

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At720Ocorr

Monta a Tela com todas as ocorrencias relacionadas ao Colete
@author Servi�os
@since 20/08/13
@version P11 R9

@Param cColete,Codigo do Colete
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At720Ocorr(cColete, lAutomato)
Local oPanel		:= Nil
Local oBrowse		:= Nil
Local aBckp		:= aClone(aRotina)

Default lAutomato := .F.

aRotina := {}

If !lAutomato
	DEFINE MSDIALOG oPanel TITLE STR0019 FROM 050,050 TO 500,800 PIXEL//"Ocorrencias"
	
	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPanel )   
	oBrowse:SetDescription( STR0022 ) //"Lista de Ocorrencias"
	oBrowse:SetAlias( "TES" ) 
	oBrowse:DisableDetails() 
	oBrowse:SetWalkThru(.F.)
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetProfileID("12")
	oBrowse:SetMenuDef( "  " )
	oBrowse:SetFilterDefault( "TES_CODCOL = '" + cColete + "'" ) 
	oBrowse:Activate() 
	
	//bloco de codigo para duplo click - deve ficar ap�s o activate, senao o FWMBrowse ira sobreescrever com o bloco padrao
	oBrowse:BlDblClick := {||At720VisOcor()} 
	oBrowse:Refresh()

	ACTIVATE MSDIALOG oPanel CENTERED
EndIf

aRotina := aBckp
aBckp := {}

Return
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At720VisOcor

A��o do Duplo-click na Ocorrencias, abrindo o cadastro de ocorrencia no modo 
Visualiza��o
@author Servi�os
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na opera��o
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At720VisOcor(lAutomato)
Local aArea		:= GetArea()

Default lAutomato := .F.

DbSelectArea("TE4")
TE4->(DbSetOrder(1))
	
If TE4->(DbSeek(xFilial("TE4")+TES->TES_CDOCOR)) .AND. !lAutomato
	FWExecView(Upper(STR0003),"VIEWDEF.TECA750",MODEL_OPERATION_VIEW,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)	
EndIf

RestArea(aArea)

Return (.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At720Commit

Commit do cadastro de coletes, onde ser� gravado a data de aloca��o no cofre
@author Servi�os
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na opera��o
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At720Commit(oModel)
Local lRet	:= .T.
Local nOperation	:= oModel:GetOperation()

If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) .And. (!Empty(FwFldGet("TE1_LOCAL")))
	oModel:setValue("TE1MASTER",'TE1_DTALOC',dDataBase)
	oModel:setValue("TE1MASTER",'TE1_ENTIDA',"TER")		
EndIf

FWModelActive( oModel )
FWFormCommit( oModel )	

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At720Manut

Monta a Tela com todas as ocorrencias relacionadas a Arma
@author Servi�os
@since 20/08/13
@version P11 R9

@Param cArma,Codigo da Arma 
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At720Manut(cColete, lAutomato)
Local oPanel		:= Nil
Local oBrowse		:= Nil
Local aBckp		:= aClone(aRotina)
Default lAutomato := .F.
aRotina := {}

If !lAutomato
	DEFINE MSDIALOG oPanel TITLE STR0020 FROM 050,050 TO 500,800 PIXEL//"Manuten��es"
	
	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPanel )   
	oBrowse:SetDescription( STR0023 ) //"Lista de Manuten��es"
	oBrowse:SetAlias( "TEU" ) 
	oBrowse:DisableDetails() 
	oBrowse:SetWalkThru(.F.)
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetProfileID("13")
	oBrowse:SetMenuDef( "  " )
	oBrowse:SetFilterDefault( "TEU_TPARMA = '2' .AND. TEU_CDARM = '" + cColete + "' " ) 
	oBrowse:Activate() 
	
	//bloco de codigo para duplo click - deve ficar ap�s o activate, senao o FWMBrowse ira sobreescrever com o bloco padrao
	oBrowse:BlDblClick := {||At720VisManut()} 
	oBrowse:Refresh()

	ACTIVATE MSDIALOG oPanel CENTERED
EndIf

aRotina := aBckp
aBckp := {}

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At720VisManut

A��o do Duplo-click na Ocorrencias, abrindo o cadastro de ocorrencia no modo 
Visualiza��o
@author Servi�os
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na opera��o
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At720VisManut(lAutomato)
Local aArea		:= GetArea()
Default lAutomato := .F.
DbSelectArea("TEU")
TEU->(DbSetOrder(1))
	
If TEU->(DbSeek(xFilial("TEU")+TEU->TEU_CODIGO)) .AND. !lAutomato
	FWExecView(Upper(STR0003),"VIEWDEF.TECA780",MODEL_OPERATION_VIEW,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)	
EndIf

RestArea(aArea)

Return (.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At720Movim

Monta a Tela com todas as movimenta��es relacionadas a arma
@author Servi�os
@since 20/08/13
@version P11 R9

@Param cColete,Codigo da Arma 
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At720Movim(cColete, lAutomato)
Local oPanel		:= Nil
Local oBrowse		:= Nil
Local cAlias        := GetNextAlias()
Local aBckp		    := aClone(aRotina)
Local cQry 	        := At720qry(cColete)
Local aColumns      := fColumns()
Default lAutomato := .F.
aRotina := {}

If !lAutomato

	DEFINE MSDIALOG oPanel TITLE STR0021 FROM 050,050 TO 500,800 PIXEL//"Movimenta��es"
	
	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPanel )   
	oBrowse:SetDescription( STR0024 ) 
	oBrowse:SetColumns( aColumns )
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetQuery( cQry )
	oBrowse:SetAlias( cAlias )
	oBrowse:DisableDetails() 
	oBrowse:SetWalkThru(.F.)
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetProfileID("14")
	oBrowse:SetMenuDef( "  " )
	
	oBrowse:Activate() 
	
	oBrowse:BlDblClick := {|| At720VisMovim(.F.,(cAlias)->TFQ_CODIGO)} 
	oBrowse:Refresh()
	ACTIVATE MSDIALOG oPanel CENTERED

EndIf

aRotina := aBckp
aBckp := {}

Return
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At720VisMovim

A��o do Duplo-click na Movimenta��o, abrindo o cadastro de movimentaadmin��es no modo 
Visualiza��o
@author Servi�os
@since 20/08/13
@version P11 R9

@return ExpL:Retorna .T. quando houve sucesso na opera��o
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At720VisMovim(lAutomato, cTFOCdMov)
Local aArea		:= GetArea()
Default lAutomato := .F.
Default cTFOCdMov := TFO->TFO_CDMOV

DbSelectArea("TFQ")
TFQ->(DbSetOrder(1))

If TFQ->(DbSeek(xFilial("TFQ")+cTFOCdMov)) .AND. !lAutomato
	FWExecView(Upper(STR0003),"VIEWDEF.TECA880",MODEL_OPERATION_VIEW,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)	
EndIf

RestArea(aArea)

Return (.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TecFilCol

Retorna a consulta especifica para coletes.

@author Rebeca Facchinato Asun��o
@since 25/08/2017
@version P12.1.17
@return Nil
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TecFilCol(nOpc)

Local lRet := .F.

	lRet:= TxProdArm(2)

Return lRet	

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At720qry

Realiza uma consulta a qual ser� inserida no browse da Rotina de Colete

@author Junior Geraldo Dos Santos
@since 12/02/2019
@version P12.1.17
@return cQuery 
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At720qry(cColete)
Local cQuery		:= ""
Local lMultFil 		:= TFQ->(ColumnPos("TFQ_FILORI")) .And. TFQ->(ColumnPos("TFQ_FILDES")) .And. FindFunction("TecMtFlArm") .And. TecMtFlArm()

cQuery := "SELECT TFO_FILIAL,TFO_ITMOV,TFO_PRODUT,"
cQuery += " TFO_CARGA,TFO_QTDE,TFO_LGUIA,  TFO_NRGUIA,TFO_LRET,TFO_DTRET,  TFO_DATA,TFO_ITCOD, TFQ_CODIGO, TFQ_ORIGEM, TFQ_DESTIN, TFQ_ENTORI, TFQ_ENTDES"
If lMultFil
	cQuery += " , TFQ.TFQ_FILORI, TFQ.TFQ_FILDES "
Endif
cQuery += " FROM "+RetSQlName("TFO")+" TFO"
cQuery += " INNER JOIN "+RetSQlName("TFQ")+" TFQ ON TFQ_FILIAL = '"+xFilial("TFQ")+"'"
cQuery += 						" AND TFQ_CODIGO = TFO_CDMOV"
cQuery += 						" AND TFQ.D_E_L_E_T_ = ' '"
cQuery += " WHERE TFO.TFO_FILIAL = '"+xFilial("TFO")+"'"
cQuery += " AND TFO.D_E_L_E_T_=' '"
cQuery += " AND TFO_ITMOV = '2' 
cQuery += " AND TFO_ITCOD = '" + cColete + "'"
cQuery := ChangeQuery(cQuery)

Return cQuery

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} fColumns

cria a estrutura do Browse da TFO e TFQ.

@author Junior Geraldo Dos Santos
@since 12/02/2019
@version P12.1.17
@return aColumns 
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function fColumns()

Local aColumns	:= {}
Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->( GetArea() )
Local nI        := 0
Local aCampos 	:= {}
Local lMultFil 	:= TFQ->(ColumnPos("TFQ_FILORI")) .And. TFQ->(ColumnPos("TFQ_FILDES")) .And. FindFunction("TecMtFlArm") .And. TecMtFlArm()

If lMultFil
	aCampos := {"TFO_FILIAL","TFO_ITMOV","TFO_PRODUT", "TFO_CARGA","TFO_QTDE","TFO_LGUIA","TFO_NRGUIA","TFO_LRET","TFO_DTRET","TFO_DATA","TFO_ITCOD","TFQ_CODIGO","TFQ_FILORI","TFQ_ORIGEM","DESCORI","TFQ_FILDES","TFQ_DESTIN","DESCDEST"}
Else
	aCampos := {"TFO_FILIAL","TFO_ITMOV","TFO_PRODUT", "TFO_CARGA","TFO_QTDE","TFO_LGUIA","TFO_NRGUIA","TFO_LRET","TFO_DTRET","TFO_DATA","TFO_ITCOD","TFQ_CODIGO","TFQ_ORIGEM","DESCORI","TFQ_DESTIN","DESCDEST"}
Endif
DbSelectArea('SX3')
SX3->( DbSetOrder(2) )	

FOR nI := 1 TO LEN(aCampos)
	
	If SX3->(DBSEEK(aCampos[nI]))
		
		Aadd( aColumns, FWBrwColumn():New() )

		cX3Campo := AllTrim(SX3->X3_CAMPO)

		If SX3->X3_TIPO == "D"
			Atail(aColumns):SetData( &("{||StoD(" + cX3Campo + ")}") )
		Else
			Atail(aColumns):SetData( &("{||" + cX3Campo + "}") )
		EndIf

		Atail(aColumns):SetSize( SX3->X3_TAMANHO )
		Atail(aColumns):SetDecimal( SX3->X3_DECIMAL )
		Atail(aColumns):SetTitle( X3Titulo() )		
		Atail(aColumns):SetPicture( SX3->X3_PICTURE )

		If SX3->X3_TIPO == "N"
			Atail(aColumns):SetAlign( CONTROL_ALIGN_RIGHT )
		Else
			Atail(aColumns):SetAlign( CONTROL_ALIGN_LEFT )
		EndIf
	ElseIf aCampos[nI]=="DESCORI"
		Aadd( aColumns, FWBrwColumn():New() )
		If lMultFil
			Atail(aColumns):SetData( {|| At720DscOD("1",lMultFil,TFQ_ENTORI,TFQ_FILORI,TFQ_ORIGEM) })
		Else
			Atail(aColumns):SetData( {|| At720DscOD("1",lMultFil,TFQ_ENTORI,"",TFQ_ORIGEM) })		
		Endif	
		Atail(aColumns):SetSize( 50 )
		Atail(aColumns):SetDecimal( )
		Atail(aColumns):SetTitle( STR0027 )		
		Atail(aColumns):SetPicture( )
		Atail(aColumns):SetAlign( CONTROL_ALIGN_RIGHT )
		
	ElseIf aCampos[nI]=="DESCDEST"
		Aadd( aColumns, FWBrwColumn():New() )
		If lMultFil
			Atail(aColumns):SetData( {|| At720DscOD("2",lMultFil,TFQ_ENTDES,TFQ_FILDEST,TFQ_DESTIN) })
		Else	
			Atail(aColumns):SetData( {|| At720DscOD("2",lMultFil,TFQ_ENTDES,"",TFQ_DESTIN) })		
		Endif
		
		Atail(aColumns):SetSize( 50 )
		Atail(aColumns):SetDecimal( )
		Atail(aColumns):SetTitle( STR0028 )		
		Atail(aColumns):SetPicture( )			
		Atail(aColumns):SetAlign( CONTROL_ALIGN_RIGHT )
			
	EndIf

NEXT nI

RestArea(aAreaSX3)
RestArea(aArea)

Return aColumns
//-------------------------------------------------------------------
/*/{Protheus.doc} At720VldLc

@description Valida��o de local multi-filial.
@author	Kaique Schiller
@since	28/12/2020
/*/
//-------------------------------------------------------------------
Static Function At720VldLc(oModel)
Local lRet := .T.
Local cFilBkp := cFilAnt

If oModel:GetValue("TE1_FILLOC") <> cFilAnt
	cFilAnt := oModel:GetValue("TE1_FILLOC")
Endif
lRet := ExistCpo("TER")
If cFilBkp <> cFilAnt
	cFilAnt := cFilBkp
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At720DscOD

@description Posiciona na descri��o de origem e destino conforme a filial.
@author	Kaique Schiller
@since	14/01/2020
/*/
//-------------------------------------------------------------------
Static Function At720DscOD(cTipo,lMultFil,cTpEnt,cFilLoc,cLocIn)
Local cRetDesc := ""
Local cFilBkp  := cFilAnt

If lMultFil .And. cFilLoc <> cFilAnt
	cFilAnt := cFilLoc
Endif

//Origem
If cTipo == "1" 
	If cTpEnt == '1'
		cRetDesc := Posicione("TER",1,xFilial("TER") +  cLocIn ,"TER_DESCRI")
	Else
		cRetDesc := Posicione("ABS",1,xFilial("ABS") +  cLocIn ,"ABS_DESCRI")
	EndIf
Else //Destino
	If cTpEnt == '2' 
		cRetDesc := Posicione("TER",1,xFilial("TER") +  cLocIn ,"TER_DESCRI")
	Else
		cRetDesc := Posicione("ABS",1,xFilial("ABS") +  cLocIn ,"ABS_DESCRI")
	EndIf
Endif

If lMultFil .And. cFilBkp <> cFilAnt
	cFilAnt := cFilBkp
Endif

Return cRetDesc
