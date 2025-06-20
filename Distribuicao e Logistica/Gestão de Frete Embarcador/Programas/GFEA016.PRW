#INCLUDE "GFEA016.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA016

Gera��o de Pr�-faturas

@author Jorge Matos Valcanaia
@since 27/10/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA016()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GUW")												// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA016")										// Nome do fonte onde esta a fun��o MenuDef
	oBrowse:SetDescription("Manuten��o de Calend�rio de Transporte")  	// Descri��o do browse //"Calend�rio"

	oBrowse:AddLegend( "GUW_TPDIA =='1'", "BLUE", STR0001)  // Legenda //"�til"
	oBrowse:AddLegend( "GUW_TPDIA =='2'", "RED", STR0002 )  // Legenda //"N�o-�til"

	oBrowse:Activate()                                       

Return(Nil)

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	//-------------------------------------------------------------------
	// Adiciona bot�es do browse
	//-------------------------------------------------------------------
	ADD OPTION aRotina TITLE STR0003 ACTION "AxPesqui"        OPERATION 1  ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA016" OPERATION 2  ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0005 ACTION "GFEA15CLD"       OPERATION 3  ACCESS 0 //"Gerar"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA016" OPERATION 4  ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA016" OPERATION 8  ACCESS 0   //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStructGUW := FWFormStruct(1,"GUW")

	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost   Code-Block de valida��o do formul�rio de edi��o
	// bCommit Code-Block de persist�ncia do formul�rio de edi��o
	// bCancel Code-Block de cancelamento do formul�rio de edi��o
	oModel := MPFormModel():New("GFEA016", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pr�-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost        Code-Block de valida��o do formul�rio de edi��o
	// bLoad        Code-Block de carga dos dados do formul�rio de edi��o
	oModel:AddFields("GFEA016_GUW", Nil, oStructGUW,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GUW_FILIAL", "GUW_DATA"})
	oModel:SetDescription("Calend�rio de Transporte")

Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA016")
	Local oView  := Nil

	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField ir� representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,S� � necess�ri o caso estamos mundando o ID no View.
	oView:AddField( "GFEA016_GUW" , FWFormStruct(2,"GUW"), /*cLinkID*/ )	//
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. � a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas cria��es uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight � na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, � necess�rio informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	// Associa um View a um box
	oView:SetOwnerView( "GFEA016_GUW" , "MASTER" )

Return oView  

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA016

Fun��o que executa a cria��o do Calend�rio do ano

@author Jorge Matos Valcanaia
@since 27/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
         
Function GFEA15PROC()
	Local lGera
	Local dCorrent := CTOD("01/01/" + MV_PAR01)

    DbSelectArea("GUW")
    DbSetOrder(1)

    If DbSeek(xFilial("GUW") + DTOS(dCorrent))
    	msgInfo(STR0008+MV_PAR01+STR0009)       	 //"Calend�rio referente ao ano de "###" j� foi cadastrado."
    Else
    	ProcRegua(365)
    	While Year(dCorrent) = Val(MV_PAR01)
    		IncProc()

			lGera := .F.

			If (MV_PAR02 == 1 .AND. DOW(dCorrent) == 2) .Or. (MV_PAR03 == 1 .AND. DOW(dCorrent) == 3);
														.Or. (MV_PAR04 == 1 .AND. DOW(dCorrent) == 4);
														.Or. (MV_PAR05 == 1 .AND. DOW(dCorrent) == 5);
														.Or. (MV_PAR06 == 1 .AND. DOW(dCorrent) == 6);
														.Or. (MV_PAR07 == 1 .AND. DOW(dCorrent) == 7);
														.Or. (MV_PAR08 == 1 .AND. DOW(dCorrent) == 1)
				lGera := .T.
	        EndIf

			DbSelectArea("GUW")
			RecLock("GUW", .T.)
			GUW->GUW_FILIAL := xFilial("GUW")
			GUW->GUW_DATA   := dCorrent
			GUW->GUW_TPDIA  := Iif(lGera,"1","2")
			GUW->GUW_DSDNU  := DiaExtenso(dCorrent)
			MsUnLocK("GUW")

			dCorrent ++
		EndDo

		msgInfo(STR0010)	 //"Calend�rio criado com sucesso."
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA15CLD

Fun��o que mostra em tela o procassamento do Calend�rio

@author Jorge Matos Valcanaia
@since 20/11/09
@version 1.0 
/*/                                        
//-------------------------------------------------------------------

Function GFEA15CLD()

	If Pergunte("GFEA015",.T.)
		Processa({|lEnd| GFEA15PROC()},STR0011,STR0012) //"Gerando Calend�rio..."###"Aguarde"
	EndIf

Return
