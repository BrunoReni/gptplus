#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "GFEX020.CH"

// C�digos de mensagens padronizadas
#DEFINE GFEX020001 'GFEX020001'
#DEFINE GFEX020002 'GFEX020002'
//-----------------------------------------------------------------------------------
/*/{Protheus.doc} GFEX020
Exce��o Integra��o GFE com TOTVS Colabora��o
@type  Function
@author Squad GFE
@since 10/06/2020
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-----------------------------------------------------------------------------------
Function GFEX020()
Local oBrwGZX := Nil

	If !GFXTB12130("GZX")
		GFEMessage(5,"Aten��o","Funcionalidade n�o dispon�vel!","Atualizar o documento t�cnico : 'DT Exce��o de integra��o do GFE com TOTVS Colabora��o (GFEX020)'")
	Else
		oBrwGZX := FWMBrowse():New()
		oBrwGZX:SetAlias('GZX')
		oBrwGZX:SetMenuDef('GFEX020')
		oBrwGZX:SetProfileID('1')
		oBrwGZX:DisableDetails()
		oBrwGZX:SetDescription(STR0001) // Exce��o Integra��o GFE com TOTVS Colabora��o
		oBrwGZX:DisableDetails()
		oBrwGZX:Activate()
	EndIf
Return Nil
//-----------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model de dados
@since 10/06/2020
@version 1.0
@return oModel, object, Modelo de dados
@example
(examples)
/*/
//-----------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel     := Nil
Local oStructGZX := FWFormStruct(1,"GZX")
	
	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost   Code-Block de valida��o do formul�rio de edi��o
	// bCommit Code-Block de persist�ncia do formul�rio de edi��o
	// bCancel Code-Block de cancelamento do formul�rio de edi��o
	oModel := MPFormModel():New("GFEX020", /*bPre*/, {|oModel| GFEX020VAL(oModel)}/*bPost*/,/*bCommit*/ , /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pr�-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost        Code-Block de valida��o do formul�rio de edi��o
	// bLoad        Code-Block de carga dos dados do formul�rio de edi��o
	oModel:AddFields("GFEX020_GZX", Nil, oStructGZX,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GZX_FILIAL","GZX_FILCTE","GZX_CTEDE","GZX_CTEAT"})
Return oModel
//-----------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Visualiza��o dos dados
@since 10/06/2020
@version 1.0
@return oView, object , Visuliza��o dos dados da estrutura
@example
(examples)
@see (links_or_references)
/*/
//-----------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel     := FWLoadModel("GFEX020")
Local oView      := Nil
Local oStructGZX := FWFormStruct(2,"GZX")
	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField ir� representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,S� � necess�ri o caso estamos mundando o ID no View.
	oView:AddField( "GFEX020_GZX" , oStructGZX, /*cLinkID*/ )	//

	// cID          Id do Box a ser utilizado
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. � a qtd de pixel exato)
	// cIdOwner     Id do Box Vertical pai. Podemos fazer diversas cria��es uma dentro da outra.
	// lFixPixel    Determina que o valor passado no nPercHeight � na verdade a qtd de pixel a ser usada.
	// cIDFolder    Id da folder onde queremos criar o o box se passado esse valor, � necess�rio informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView( "GFEX020_GZX" , "MASTER" )
Return oView
//-----------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu
@type Static Function
@author Squad GFE
@since 10/06/2020
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-----------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina	:= {}
	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.GFEX020" OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEX020" OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEX020" OPERATION 5 ACCESS 0 // Excluir
Return aRotina
//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEX020VAL(oModel)
Valida��es
@type  Function
@author Squad GFEF
@since 11/06/2020
@version 1.0
@param oModel, object, Modelo de dados
@example
(examples)
@see (links_or_references)
/*/
//---------------------------------------------------------------------------------------------
Function GFEX020VAL(oModel)
Local lRet       := .T.
Local oModelGZX  := oModel:GetModel("GFEX020_GZX") //Recebe o model do Grid
Local cFilCTE    := oModelGZX:GetValue("GZX_FILCTE")
Local cCFOPDE    := oModelGZX:GetValue("GZX_CFOPDE")
Local cCFOPAT    := oModelGZX:GetValue("GZX_CFOPAT")
Local cAliasGZX  := Nil
Local cWhere     := ""
Local nOperation := oModel:GetOperation()
	If nOperation <> MODEL_OPERATION_DELETE
		If (cCFOPAT < cCFOPDE)
			GFEMessage(5,GFEX020001,GFEMsgFmt(STR0006,{{"[VAR01]",cCFOPAT},{"[VAR02]",cCFOPDE}}),STR0007)
			lRet := .F.
		EndIf
		If lRet
			cWhere := ""
			If nOperation == MODEL_OPERATION_UPDATE
				cWhere += " AND GZX.R_E_C_N_O_ <> "+ GZX->(Recno())
			EndIf
			cWhere := "%"+cWhere+"%"
			// Verifica se a faixa informada j� est� cadastrada
			cAliasGZX := GetNextAlias()
			BeginSql Alias cAliasGZX
				SELECT 1
				FROM %Table:GZX% GZX
				WHERE GZX.GZX_FILIAL = %xFilial:GZX%
				AND GZX.GZX_FILCTE = %Exp:cFilCTE%
				AND (%Exp:AllTrim(cCFOPDE)% BETWEEN GZX.GZX_CFOPDE AND GZX.GZX_CFOPAT
					OR %Exp:AllTrim(cCFOPAT)% BETWEEN GZX.GZX_CFOPDE AND GZX.GZX_CFOPAT)
				%Exp:cWhere%
				AND GZX.%NotDel%
			EndSql
			If (cAliasGZX)->(!Eof())
				GFEMessage(5,GFEX020002,GFEMsgFmt(STR0008,{{"[VAR01]",cCFOPDE},{"[VAR02]",cCFOPAT},{"[VAR03]",IIf(Empty(cFilCTE),"'  '",cFilCTE)}}),STR0007)
				lRet := .F.
			EndIf
			(cAliasGZX)->(dbCloseArea())
		EndIf
	EndIf
Return lRet