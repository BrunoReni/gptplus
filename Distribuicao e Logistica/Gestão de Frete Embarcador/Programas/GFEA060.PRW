#INCLUDE "GFEA060.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA060
Cadastro de Componentes de Frete.
Generico.

@sample
GFEA060()

@author Felipe M., Felipe W.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA060()
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GV2")         // Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA060")   // Nome do fonte onde esta a fun��o MenuDef
	oBrowse:SetDescription(STR0001) // Descri��o do browse //"Cadastro de Componentes de Fretes"
	oBrowse:Activate()
Return Nil
//---------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	// Adiciona bot�es do browse
	ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA060" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA060" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA060" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA060" OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA060" OPERATION 9 ACCESS 0 //"Copiar"
	ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEA060" OPERATION 8 ACCESS 0 //"Imprimir"
Return aRotina
//---------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStructGV2 := FWFormStruct(1,"GV2")
	
	oStructGV2:RemoveField("GV2_DATCAL")
	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost   Code-Block de valida��o do formul�rio de edi��o
	// bCommit Code-Block de persist�ncia do formul�rio de edi��o
	// bCancel Code-Block de cancelamento do formul�rio de edi��o
	oModel := MPFormModel():New("GFEA060", /*bPre*/, /*bPost*/  {|oMod|GFEA060PS(oMod)},/*bCommit*/ , /*bCancel*/)
	//oModel:SetVldActivate ({|oMod| GFEA060VL(oMod)})
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pr�-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost        Code-Block de valida��o do formul�rio de edi��o
	// bLoad        Code-Block de carga dos dados do formul�rio de edi��o
	oModel:AddFields("GFEA060_GV2", Nil, FWFormStruct(1,"GV2"),/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GV2_FILIAL", "GV2_CDCOMP"})
Return oModel

//---------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA060")
	Local oView  := Nil
	Local oStructGV2 := FWFormStruct(2,"GV2")
	oStructGV2:RemoveField("GV2_DATCAL")
	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField ir� representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,S� � necess�ri o caso estamos mundando o ID no View.
	oView:AddField( "GFEA060_GV2" , oStructGV2, /*cLinkID*/ )	//

	// cID		  	Id do Box a ser utilizado
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. � a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas cria��es uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight � na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, � necess�rio informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.

	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView( "GFEA060_GV2" , "MASTER" )
Return oView

Function GFEA060PS(oModel)
	Local lRet      := .T.
	Local aAreaAnt  := GetArea()
	Local nOpc      := (oModel:GetOperation())
	Local cAliasQry := Nil
	
	If nOpc != MODEL_OPERATION_DELETE
		If FwFldGet("GV2_ATRCAL") == "11" .AND. FwFldGet("GV2_SERVI") == "2"
			Help( ,, 'HELP',, STR0015, 1, 0) //"Quando o componente utilizar o c�lculo sobre a Quantidade de Servi�o dever� ser selecionado o campo Servi�o"
			lRet := .F.
		EndIf
		If FwFldGet("GV2_PEDAG") == "2".AND.FwFldGet("GV2_CATVAL") == "4"
			Help( ,, 'HELP',, STR0011, 1, 0) //"Quando o campo Ped�gio for N�O, a Categoria do Valor deve ser diferente de Ped�gio"
			lRet := .F.
		EndIf
		If FwFldGet("GV2_ATRCAL") <> "8" .And. FwFldGet("GV2_VLDIAR") == "1"
			oModel:LoadValue("GFEA060_GV2","GV2_VLDIAR","2")
		Endif
		If FwFldGet("GV2_PEDAG") == "1".AND.FwFldGet("GV2_CATVAL") != "4"
			Help( ,, 'HELP',, STR0010, 1, 0) //"Quando o campo Ped�gio for SIM, a Categoria do Valor deve ser Ped�gio"
			lRet := .F.
		EndIf	
			
	Else // valida��o de relacionamento, devido a problemas de dicionario, a valida��o � feita no programa
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT 1
			FROM %Table:GUY% GUY
			WHERE GUY.GUY_CDCOMP = %Exp:GV2->GV2_CDCOMP%
			AND GUY.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			Help( ,, 'HELP',, STR0012, 1, 0) //"Este registro est� em uso em tabelas de frete (GUY) e n�o pode ser exclu�do."
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())

		If lRet
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT 1
				FROM %Table:GVB% GVB
				WHERE GVB.GVB_CDCOMP = %Exp:GV2->GV2_CDCOMP%
				AND GVB.%NotDel%
			EndSql
			If (cAliasQry)->(!Eof())
				Help( ,, 'HELP',, STR0013, 1, 0) //"Este registro est� em uso como componente de tabelas de v�nculo (GVB) e n�o pode ser exclu�do."
				lRet := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf

		If lRet
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT 1
				FROM %Table:GWI% GWI
				WHERE GWI.GWI_CDCOMP = %Exp:GV2->GV2_CDCOMP%
				AND GWI.%NotDel%
			EndSql
			If (cAliasQry)->(!Eof())
				Help( ,, 'HELP',, STR0014, 1, 0) //"Este registro est� em uso como componente do c�lculo de frete (GWI) e n�o pode ser exclu�do."
				lRet := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
	EndIf
	
	/*se o campo Servi�o estava com valor N�o e foi modificado para Sim, verificar se 
	h� tabela de frete com este componente e tamb�m com outro componente de servi�o. 
	Se existir, exibir mensagem: 
	"N�o � poss�vel alterar o campo Servi�o para Sim. Nas tabelas de frete s� � 
	permitido um componente de servi�o, e existem tabelas de frete com este componente 
	e tamb�m com outro componente de servi�o j� definido".*/
	// N�o realiza a valida��o caso o par�metro "Servi�o por tipo de Ocorr�ncia" estiver marcado
	If lRet .And. SuperGetMV("MV_SERVTO",.F.,"2") != "1"  .And. nOpc != 5 .And. FwFldGet("GV2_SERVI") == "1" .And. GV2->GV2_SERVI == "2"
	
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT GUY.GUY_CDEMIT,
					GUY.GUY_NRTAB,
					GUY.GUY_NRNEG,
					GUY.GUY_CDCOMP 
			FROM %Table:GUY% GUY
			INNER JOIN %Table:GV2% GV2
			ON GV2_CDCOMP = GUY.GUY_CDCOMP
			AND GV2.GV2_SERVI = '1'
			AND GV2.%NotDel%
			WHERE EXISTS ( SELECT 1 
							FROM %Table:GUY% GUY2
							WHERE GUY2.GUY_FILIAL = GUY.GUY_FILIAL
							AND GUY2.GUY_CDEMIT = GUY.GUY_CDEMIT
							AND GUY2.GUY_NRTAB = GUY.GUY_NRTAB
							AND GUY2.GUY_NRNEG = GUY.GUY_NRNEG
							AND GUY2.GUY_CDCOMP <> %Exp:GV2->GV2_CDCOMP%
							AND GUY2.%NotDel% )
			AND GUY.GUY_NRTAB <> ' '
			AND GUY.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			Help( ,, 'HELP',, STR0016, 1, 0) // "N�o � poss�vel alterar o campo Servi�o para Sim. Nas tabelas de frete s� � permitido um componente de servi�o, e existem tabelas de frete com este componente e tamb�m com outro componente de servi�o j� definido. Para permitir mais de um componente de servi�o por tabela de frete, altere o param�tro 'Servi�o por Tipo de Ocorr�ncia' para '1=Sim'." 
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	
	If lRet .And. nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE
		If M->GV2_ATRCAL == '11' .And. M->GV2_CALSER == '2'
			Help( ,, 'HELP',, STR0017, 1, 0) // "N�o � poss�vel salvar quando o C�lculo do Servi�o � por Romaneio e C�lculo Sobre � por Quantidade de Servi�o."
			lRet := .F. 
		EndIf
		
		If M->GV2_ATRCAL != '11' .And. M->GV2_CALSER == '1' .And. SuperGetMV("MV_SERVTO",.F.,"2") == '2' .And. M->GV2_SERVI == '1'
			Help( ,, 'HELP',, STR0018, 1, 0) // "N�o � poss�vel salvar quando o C�lculo do Servi�o � por Ocorr�ncia, C�lculo Sobre n�o � por Quantidade de Servi�o e o par�metro MV_SERVTO � igual a 2."
			lRet := .F. 
		EndIf
	EndIf
	
	RestArea(aAreaAnt)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA060DAC
Retorna a informa��o descritiva do atributo para c�lculo
Fun��o utilizada para exibir no browse a descri��o do atributo de c�lculo.
Uso Geral.

@author Lidiomar Fernando dos S. Machado
@since 29/04/13
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA060DAC()
	Local aDsCbox  := RetSx3Box(Posicione('SX3',2,'GV2_ATRCAL','X3CBox()'),,,1)
	Local cAtrCalc := GV2->GV2_ATRCAL
	Local cDesCalc := ""
	Local nPos     := 0

	If !Empty(aDsCbox) .And.(nPos := aScan(aDsCbox,{|x| Alltrim(cAtrCalc) $ x[2] })) > 0
		cDesCalc := aDsCbox[nPos,3]
	EndIf
Return cDesCalc
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA060AUT
Rotina para realizar Valida��es de habilita��o do campo GV2_CATVAL, GV2_IDVLRC
Uso Geral.

@author Ana Claudia da Silva
@since 08/10/13
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA060AUT()
Local lRet := .T.

	// O campo "Agrupa por" deve ficar desabilitado quando Categoria for igual a 4=Ped�gio e quando "Valor p/RC" for igual a 2=N�o
	If !(M->GV2_CATVAL == "4").AND.(M->GV2_IDVLRC == "1")
		lRet := .T.
	Else
		lRet := .F.
	EndIf
Return lRet
