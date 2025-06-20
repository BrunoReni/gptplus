#INCLUDE "GFEA030.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 

// C�digos de mensagens padronizadas
#DEFINE GFEA030001 'GFEA030001'


/*/ 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GFEA030  � Autor � Luiz Fernando Soares  � Data � 25.03.10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cadastro de Tipos de Ocorrencia	                      	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � GFEA030()	                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��� 			 �        �XXXXXX�	                                      ��� 
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function GFEA030()
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GU5")							// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA030")				    // Nome do fonte onde esta a fun��o MenuDef
	oBrowse:SetDescription(STR0012)	// Descri��o do browse //"Cadastro de Tipos de Ocorr�ncia"
	oBrowse:Activate()                                       

Return Nil

//-------------------------------------------------------------------//
//-------------------------Funcao MenuDEF----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()

	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona bot�es do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0001 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.GFEA030" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GFEA030" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA030" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEA030" OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEA030" OPERATION 9 ACCESS 0 //"Copiar"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEA030" OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina

//-------------------------------------------------------------------//
//-------------------------Funcao ModelDEF----------------------------//
//-------------------------------------------------------------------//
Static Function ModelDef()

	Local oModel
	
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost   Code-Block de valida��o do formul�rio de edi��o
	// bCommit Code-Block de persist�ncia do formul�rio de edi��o
	// bCancel Code-Block de cancelamento do formul�rio de edi��o
	oModel := MPFormModel():New("GFEA030", /*bPre*/, {|oX| GFEA030POS(oX)} /* bPost*/, /*{|oX| GFEA030COM(oX)}bCommit*/, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pr�-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost        Code-Block de valida��o do formul�rio de edi��o
	// bLoad        Code-Block de carga dos dados do formul�rio de edi��o
	oModel:AddFields("GFEA030_GU5", Nil, FWFormStruct(1,"GU5"),/*bPre*/,/*bPost*/,/*bLoad*/)
	//oModel:SetPrimaryKey({"GU5_FILIAL", "GU5_CDTIPO"})
	
	oModel:AddGrid("GFEA030_GU4","GFEA030_GU5",FWFormStruct(1,"GU4"),/*bLinePre*/, {|oX| GFEA030BRW(oX)}/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:GetModel("GFEA030_GU4"):SetUniqueLine({"GU4_CDMOT"})
	oModel:SetRelation("GFEA030_GU4",{{"GU4_FILIAL",'xFilial("GU5")'},{"GU4_CDTIPO","GU5_CDTIPO"}},"GU4_FILIAL+GU4_CDTIPO")
	oModel:SetPrimaryKey({"GU5_FILIAL", "GU5_CDTIPO"})
	oModel:GetModel("GFEA030_GU4"):SetDelAllLine(.T.) 
	
	oModel:SetOptional("GFEA030_GU4", .T. )

Return oModel

//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()

Local oModel := FWLoadModel("GFEA030")
Local oView  := Nil
Local oStructGU4 := FWFormStruct(2,"GU4")
Local oStructGU5 := FWFormStruct(2,"GU5")
oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
// cFormModelID - Representa o ID criado no Model que essa FormField ir� representar
// oStruct - Objeto do model a se associar a view.
// cLinkID - Representa o ID criado no Model ,S� � necess�ri o caso estamos mundando o ID no View.

oStructGU5:AddGroup("GrpId" , "Gerais", "", 2)
oStructGU5:AddGroup("GrpAdic", "Adicionais", "", 2)
oStructGU5:AddGroup("GrpCan", "Cancelamentos", "", 2)
oStructGU5:AddGroup("GrpEnt", "Entrega", "", 2)
oStructGU5:AddGroup("GrpSGTMS" , "Integra��o SIGATMS", "", 2)

//Gerais
oStructGU5:SetProperty("GU5_CDTIPO" 	, MVC_VIEW_GROUP_NUMBER, "GrpId")
oStructGU5:SetProperty("GU5_DESC" 		, MVC_VIEW_GROUP_NUMBER, "GrpId")
oStructGU5:SetProperty("GU5_EVENTO" 	, MVC_VIEW_GROUP_NUMBER, "GrpId")
oStructGU5:SetProperty("GU5_SIT" 		, MVC_VIEW_GROUP_NUMBER, "GrpId")

//Adicionais
oStructGU5:SetProperty("GU5_TPCALC"		, MVC_VIEW_GROUP_NUMBER, "GrpAdic")
oStructGU5:SetProperty("GU5_RATPER" 	, MVC_VIEW_GROUP_NUMBER, "GrpAdic")
oStructGU5:SetProperty("GU5_SERV1"		, MVC_VIEW_GROUP_NUMBER, "GrpAdic")
oStructGU5:SetProperty("GU5_SERV2" 		, MVC_VIEW_GROUP_NUMBER, "GrpAdic")
oStructGU5:SetProperty("GU5_SERV3"		, MVC_VIEW_GROUP_NUMBER, "GrpAdic")
oStructGU5:SetProperty("GU5_PRESTS" 	, MVC_VIEW_GROUP_NUMBER, "GrpAdic")
oStructGU5:SetProperty("GU5_TABFRE"		, MVC_VIEW_GROUP_NUMBER, "GrpAdic")
oStructGU5:SetProperty("GU5_TPIMP" 		, MVC_VIEW_GROUP_NUMBER, "GrpAdic")

//Cancelamentos
oStructGU5:SetProperty("GU5_CANCDC" 	, MVC_VIEW_GROUP_NUMBER, "GrpCan")
oStructGU5:SetProperty("GU5_ACAODF" 	, MVC_VIEW_GROUP_NUMBER, "GrpCan")

//Entrega
If GFXCP12121("GU5_INFPES") .And. GFXCP12121("GU5_INDEN")
	oStructGU5:SetProperty("GU5_INFPES" 	, MVC_VIEW_GROUP_NUMBER, "GrpEnt")
	oStructGU5:SetProperty("GU5_INDEN" 		, MVC_VIEW_GROUP_NUMBER, "GrpEnt")
EndIf
//SIGATMS
If AScan(oStructGU5:aFields,{|x| x[1] == "GU5_INTTMS"}) != 0
	oStructGU5:SetProperty("GU5_INTTMS" 	, MVC_VIEW_GROUP_NUMBER, "GrpSGTMS")
	oStructGU5:SetProperty("GU5_OCOTMS" 	, MVC_VIEW_GROUP_NUMBER, "GrpSGTMS")
EndIf
	
If AScan(oStructGU5:aFields,{|x| x[1] == "GU5_RECOR"}) != 0
	oStructGU5:SetProperty("GU5_RECOR" 	, MVC_VIEW_GROUP_NUMBER, "GrpId")
EndIf
If AScan(oStructGU5:aFields,{|x| x[1] == "GU5_RECVAL"}) != 0
	oStructGU5:SetProperty("GU5_RECVAL" 	, MVC_VIEW_GROUP_NUMBER, "GrpId")
EndIf

If AScan(oStructGU5:aFields,{|x| x[1] == "GU5_DEVTOT"}) != 0
	oStructGU5:SetProperty("GU5_DEVTOT" 	, MVC_VIEW_GROUP_NUMBER, "GrpAdic")
	oStructGU5:SetProperty("GU5_DEVTOT", MVC_VIEW_ORDEM, Soma1(oStructGU5:GetProperty("GU5_TPCALC",MVC_VIEW_ORDEM)))
EndIf

oView:AddField("GFEA030_GU5",oStructGU5 , /*cLinkID*/)

oStructGU5:RemoveField("GU5_ACAOCA")
oStructGU4:RemoveField("GU4_CDTIPO")
oStructGU4:RemoveField("GU4_DSTIPO")

// cID		  	Id do Box a ser utilizado 
// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. � a qtd de pixel exato)
// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas cria��es uma dentro da outra.
// lFixPixel	Determina que o valor passado no nPercHeight � na verdade a qtd de pixel a ser usada.
// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, � necess�rio informar o cIDSheet
// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
oView:AddGrid( "GFEA030_GU4" , oStructGU4 )
oView:CreateHorizontalBox( "MASTER" , 55 )
oView:CreateHorizontalBox( "DETAIL" , 45 )

oView:CreateFolder("IDFOLDER","DETAIL")
oView:AddSheet("IDFOLDER","IDSHEET01",STR0008) //"Motivos" //"Motivos"

oView:CreateHorizontalBox( "DETAILBOX"  , 100,,,"IDFOLDER","IDSHEET01" )

// Associa um View a um box
oView:SetOwnerView( "GFEA030_GU5" , "MASTER" )
oView:SetOwnerView( "GFEA030_GU4" , "DETAILBOX" )   

Return oView

//--------------------------------------------------

Function GFEA030POS(oModel)
	
	Local nOpc     := oModel:GetOperation()
	Local lAltAcDF
	Local lAltAcDC
	Local aFil     := GFEGETFIL(cEmpAnt)
	Local nI
	Local oModelGU4 := oModel:GetModel("GFEA030_GU4")
	Local oModelGU5 := oModel:GetModel("GFEA030_GU5")
	Local nConta := 0
	Local cMot := ""
	
	If nOpc == MODEL_OPERATION_DELETE
		dbSelectArea("GWD")
		dbSetOrder(2)
		If dbSeek(xFilial("GWD") + GU5->GU5_CDTIPO)
			GFEMessage(5,GFEA030001,STR0013,STR0014) //"O Tipo da Ocorr�ncia j� est� relacionado a uma Ocorr�ncia","Verifique se o Tipo da Ocorr�ncia selecionado � o correto, caso seja, remova o vinculo com a Ocorr�ncia."
			Return .F.	
		EndIf	
	EndIf
	
	If (nOpc == MODEL_OPERATION_UPDATE .Or. nOpc == MODEL_OPERATION_INSERT)
		If FwFldGet('GU5_EVENTO') == "1" .And. (FwFldGet('GU5_TPCALC') == "0" .Or. Empty(FwFldGet('GU5_TPCALC')))
			Help(,,"HELP",,"Tipo de C�lculo deve ser informado quando o evento for C�lculo Adicional.",1,0)
			Return .F.
		EndIf
		If SuperGetMv("MV_TMS2GFE",.F.,.F.) .And. GfeVerCmpo({"GU5_INTTMS"})	.And. FwFldGet("GU5_INTTMS") == "2"
			If Empty(FwFldGet("GU5_OCOTMS"))	
				Help(,,"HELP",,"C�digo da ocorr�ncia do TMS � obrigat�rio quando a Integra��o do Tipo de Ocorr�ncia for 2=Integrar",1,0)
				Return .F.
			EndIf
			
			For nI := 1 to oModelGU4:Length()
				If !oModelGU4:IsDeleted(nI) .And.nConta <= 1
					nConta++
					cMot:= fwFldGet("GU4_CDMOT",nI)
				EndIf
				If nConta > 1
					Exit
				EndIf
			Next nI
			
			If nConta == 0	
				Help(,,"HELP",,"Um motivo de ocorr�ncia deve estar associado ao tipo da ocorr�ncia quando a Integra��o do Tipo de Ocorr�ncia for 2=Integrar",1,0)
				Return .F.
			ElseIf nConta > 1
				Help(,,"HELP",,"Somente um motivo de ocorr�ncia deve estar associado ao tipo da ocorr�ncia quando a Integra��o do Tipo de Ocorr�ncia for 2=Integrar",1,0)
				Return .F.
			EndIf
			dbSelectArea("GU6")
			dbSelectArea("DT2")
			If !Empty(cMot) .And. Posicione("GU6",1,xFilial("GU6") + cMot, "GU6_PROVOC") != Posicione("DT2",1,xFilial("DT2") + FwFldGet("GU5_OCOTMS"), "DT2_RESOCO")
				Help(,,"HELP",,"Aten��o � o respons�vel pela ocorr�ncia no TMS n�o condiz com o Provocador da Ocorr�ncia no GFE",1,0)
			EndIf  
		EndIf
			
		If SuperGetMV("MV_SERVTO",.F.,"2") == '1' .And. FwFldGet('GU5_TPCALC') == "3" .and. GfeVerCmpo({"GU5_SERV1"}) .and. (EMPTY(FwFldGet('GU5_SERV1')) .and. GfeVerCmpo({"GU5_SERV2"}) .and. EMPTY(FwFldGet('GU5_SERV2')) .and. GfeVerCmpo({"GU5_SERV3"}) .and. EMPTY(FwFldGet('GU5_SERV3')))
			Help(,,"HELP",,"Para Tipos de Ocorr�ncia de Servi�o deve ser informado pelo menos um Componente de Servi�o",1,0)
			Return .F.
		EndIf		
	Endif
	
	If !(FwFldGet('GU5_EVENTO') == "1" .And. FwFldGet('GU5_TPCALC') == "3") .And. FwFldGet('GU5_RATPER') != "2"
		oModel:LoadValue("GFEA030_GU5","GU5_RATPER", "2")
	EndIf
	
	If FwFldGet('GU5_EVENTO') != "2"
	
		If FwFldGet('GU5_CANCDC') != "2"
			oModel:LoadValue("GFEA030_GU5","GU5_CANCDC", "2")
		EndIf
	
		If FwFldGet('GU5_ACAODF') != "1"
			oModel:LoadValue("GFEA030_GU5","GU5_ACAODF", "1")
		EndIf
		
		If FwFldGet('GU5_ACAOCA') != "1"
			oModel:LoadValue("GFEA030_GU5","GU5_ACAOCA", "1")
		EndIf
		
		
	EndIf                                                       

	If FwFldGet('GU5_EVENTO') != "1" .And. GfeVerCmpo({"GU5_INTTMS"}) .And. FwFldGet('GU5_TPCALC') != "0"
		oModel:LoadValue("GFEA030_GU5","GU5_TPCALC", "0")
	EndIf
	
	If nOpc == MODEL_OPERATION_UPDATE
				
		lAltAcDF := oModel:IsFieldUpdated("GFEA030_GU5", "GU5_ACAODF")
		lAltAcDC := oModel:IsFieldUpdated("GFEA030_GU5", "GU5_CANCDC")
		
		If lAltAcDF .Or. lAltAcDC
			
			For nI := 1 To Len(aFil)
				
				dbSelectArea("GWD")
				GWD->( dbSetOrder(5) )
				GWD->( dbSeek(aFil[nI][1] + "1" + FwFldGet('GU5_CDTIPO')))
				While !GWD->( Eof() ) .And. GWD->GWD_FILIAL == aFil[nI][1] .And. GWD->GWD_SIT == "1";
					 .And. GWD->GWD_CDTIPO == FwFldGet('GU5_CDTIPO')
					
					RecLock("GWD", .F.)
						
						If lAltAcDF
							GWD->GWD_ACAODF := FwFldGet('GU5_ACAODF')
						EndIf
						
						If lAltAcDC
							GWD->GWD_ACAODC := FwFldGet('GU5_CANCDC')
						EndIf
						
					GWD->( MSUnlock() )
					
					GWD->( dbSkip() )	
				EndDo
				
			Next nI
			
		EndIf
	EndIf
	
	If Empty(FwFldGet('GU4_CDMOT')) .And. (nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE)
		oModel:LoadValue("GFEA030_GU5", "GU5_SIT", "2")
	EndIf
	
	If ( nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE ) .And. oModelGU5:HasField('GU5_DEVTOT')
		If FwFldGet('GU5_TPCALC') != "2" .Or. FwFldGet('GU5_EVENTO') != "1"
			oModelGU5:LoadValue('GU5_DEVTOT','2')
		EndIf
	EndIf
	
Return .T.

//--------------------------------------------------
	
Function GFEA030BRW(oModel)
    
	dbSelectArea("GU6")
	GU6->( dbSetOrder(1) )
	If GU6->( dbSeek(xFilial("GU6") + FwFldGet('GU4_CDMOT')) )
		If GU6->GU6_SIT == "2"
			PutHelp("PGFE030B",{STR0010},{STR0010},{STR0010})  //"Informe um motivo de ocorr�ncia ativo"###"Informe um motivo de ocorr�ncia ativo"###"Informe um motivo de ocorr�ncia ativo"
			HELP(" ",1,"GFE030B" )
			Return .F.					
		EndIf
	Else
		PutHelp("PGFE030C",{STR0011},{STR0011},{STR0011})  //"Informe um motivo existente"###"Informe um motivo existente"###"Informe um motivo existente"
		HELP(" ",1,"GFE030C" )
		Return .F.			
	EndIf
	If !GFE30VERIT(oModel)
		Return .F.
	EndIf
Return .T.


/*/{Protheus.doc} GFE30VERIT
	
@author siegklenes.beulke
@since 20/11/2013
@version 1.0

@param oModel, Object, Default := FWModelActive():GetModel("GFEA030_GU4")
@param lDic, Logico, Default := .F.

@description

Verifica se a integra��o com tms est� ativa e retorna o aviso.
Uso do dicion�rio
@Example	GFE30VERIT(oModel)
			GFE30VERIT()
			GFE30VERIT(,.T.)

/*/

Function GFE30VERIT(oModel,lDic)
	Local nX
	Local nConta := 0
	Default lDic := .F.
	
	If oModel == Nil
		oModel := FWModelActive()
		oModel := oModel:GetModel("GFEA030_GU4")
	EndIf
	
	For nX := 1 to oModel:Length()
		If !oModel:IsDeleted(nX) .And.nConta <= 1
			nConta++
		EndIf
		If nConta > 1
			Exit
		EndIf
	Next nX
	
	If nConta > 1 .And. SuperGetMv("MV_TMS2GFE",.F.,.F.) .And. GfeVerCmpo({"GU5_INTTMS"});
		.And. FwFldGet("GU5_INTTMS") == "2"
		If lDic
			Help(,,"HELP",,"N�o � permitido utilizar este tipo na integra��o com TMS pois h� mais de um motivo associado a ele.",1,0)
		Else
			Help(,,"HELP",,"N�o � permitido associar mais de um motivo ao tipo pois a integra��o com TMS est� ativa.",1,0)
		EndIf		
		Return .F.
	EndIf
Return .T.

//Uso do dicion�rio
Function GFE30VLDT2()
	Local lRet := .T.
	GFEExistC("DT2",,M->GU5_OCOTMS,"DT2_ATIVO == '1' .And. (DT2_SERTMS $ '2;3' .OR. Empty(DT2_SERTMS)) .And. DT2_CATOCO == '1'")
	dbSelectarea("DT2")
	DT2->(dbSetOrder(1))
	If !DT2->(dbSeek(xFilial("DT2") + M->GU5_OCOTMS))
		Help(,,"HELP",,"Ocorr�ncia deve existir no TMS",1,0)
		lRet := .F.
	Else
		If !(lRet := DT2->DT2_ATIVO == '1')
			Help(,,"HELP",,"Ocorr�ncia deve estar ativa",1,0)
			Return lRet
		EndIf
		
		If !(lRet := (DT2_SERTMS $ '2;3' .OR. Empty(DT2_SERTMS)))
			Help(,,"HELP",,"Servi�o de Transporte da Ocorr�ncia deve ser 2=Transporte ou 3=Entrega",1,0)
			Return lRet
		EndIf
		
		If !(lRet := DT2->DT2_CATOCO == '1')
			Help(,,"HELP",,"Categoria da Ocorr�ncia deve ser 1=Por Docto",1,0)
			Return lRet
		EndIf
		
		If M->GU5_EVENTO == "1" .And. M->GU5_TPCALC == "1" .And. !(lRet := AllTrim(M->GU5_OCOTMS) $ SuperGetMv("MV_OCORREE",.F.,""))
			Help(,,"HELP",,"C�digo da Ocorr�ncia deve estar presente no par�metro MV_OCORREE(C�digos das Ocorr�ncias que geram Reentrega) quando o tipo de c�lculo for 1=Reentrega",1,0)
		EndIf
		
	EndIf
	 
Return lRet

/*/{Protheus.doc} GFE30VLCLS
	
@author Leonardo Ribas Jimenez Hernandez
@since 27/02/2017
@version 1.0

@param cCdComp

@description
Verifica se c�lculo do servi�o(GV2_CALSER) �: 2-Por Romaneio, impede o v�nculo e retorna o motivo.
Uso do dicion�rio

@sample
GFE30VLCLS(cCdComp)

/*/
Function GFE30VLCLS(cCdComp)
Local lRet := .T.

dbSelectArea('GV2')
GV2->( dbSetOrder(1) )
If dbSeek(xFilial('GV2') + cCdComp)
	If GV2->GV2_CALSER == "2"
		Help(,,"HELP",,"N�o � poss�vel vincular esse componente, pois o C�lculo do Servi�o est� como: 2-Por Romaneio.",1,0)
		lRet := .F.
	EndIf	
EndIf

Return lRet
