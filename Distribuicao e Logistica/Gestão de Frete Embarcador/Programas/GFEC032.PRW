#INCLUDE "GFEC032.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
 
/*/ 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GFEC032  � Autor � Luiz Fernando Soares  � Data � 25.03.10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Consulta de Ocorrencia                                  	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � GFEC032()	                                              ���
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

//-------------------------------------------------------------------
//-------------------------------------------------------------------

Function GFEC032()
	
	Local oBrowse
  Private aRotina := MenuDef()
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GWD") // Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEC032") // Nome do fonte onde esta a fun��o MenuDef
	oBrowse:SetDescription(STR0001)	// Descri��o do browse   //"Registrar Ocorr�ncia"
	
	oBrowse:AddLegend("GWD_SIT=='1'", "BLUE", STR0002) //"Pendente"
	oBrowse:AddLegend("GWD_SIT=='2'", "GREEN", STR0003) //"Aprovada"
	oBrowse:AddLegend("GWD_SIT=='3'", "RED", STR0004) //"Reprovada"
	
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
    ADD OPTION aRotina TITLE STR0005 ACTION "AxPesqui"		  OPERATION 1  ACCESS 0 //"Pesquisar"
    ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEC032" OPERATION 2  ACCESS 0 //"Visualizar"
    ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEC032" OPERATION 8  ACCESS 0 //"Imprimir"
    ADD OPTION aRotina TITLE "Visualizar Anexo" ACTION "MsDocument('GWD',GWD->(RecNo()), 2)" OPERATION 2  ACCESS 0 

Return aRotina

//-------------------------------------------------------------------//
//-------------------------Funcao ModelDEF---------------------------//
//-------------------------------------------------------------------//
Static Function ModelDef()

	Local oModel
	Local oStructGWF := FWFormStruct(1, "GWF")
	
	oStructGWF:AddField("Valor Frete", "Valor da soma dos componentes de c�lculo.", "GWF_VALFRT", "N", 9, 2/*nDECIMAL*/, /*bVALID*/, /*bWHEN*/, /*{"1","2"}*/, /*lOBRIGAT*/, ;
				{|| VLTOTFRET()}, /*lKEY*/, /*lNOUPD*/, /*lVIRTUAL*/)
	
	// cID     Identificador do modelo 
	// bPre    Code-Block de pre-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost   Code-Block de valida��o do formul�rio de edi��o
	// bCommit Code-Block de persist�ncia do formul�rio de edi��o
	// bCancel Code-Block de cancelamento do formul�rio de edi��o
	oModel := MPFormModel():New("GFEC032", /*bPre*/, /* bPost*/, {||.T.}/*bCommit*/, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pr�-edi��o do formul�rio de edi��o. Indica se a edi��o esta liberada
	// bPost        Code-Block de valida��o do formul�rio de edi��o
	// bLoad        Code-Block de carga dos dados do formul�rio de edi��o
	oModel:AddFields("GFEC032_GWD", Nil, FWFormStruct(1,"GWD"),/*bPre*/,/*bPost*/,/*bLoad*/)
	
	oModel:AddGrid("GFEC032_GWL", "GFEC032_GWD", FWFormStruct(1,"GWL"),/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEC032_GWL",{{"GWL_FILIAL", 'GWD_FILIAL'},{"GWL_NROCO", "GWD_NROCO"}}, "GWL_FILIAL+GWL_NROCO")
	
	oModel:AddGrid("GFEC032_GWF", "GFEC032_GWD", oStructGWF,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEC032_GWF",{{"GWF_FILIAL", 'GWD_FILIAL'},{"GWF_NROCO", "GWD_NROCO"}}, "GWF_FILIAL+GWF_NRCALC")
	
	oModel:GetModel("GFEC032_GWF"):SetOnlyQuery(.T.)
	oModel:SetPrimaryKey({"GWD_FILIAL", "GWD_NROCO"})

Return oModel

//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()

	Local oModel     := FWLoadModel("GFEC032")
	Local oView      := Nil
	Local oStructGWD := FWFormStruct(2, "GWD")
	Local oStructGWL := FWFormStruct(2, "GWL")
	Local oStructGWF := FWFormStruct(2, "GWF")

	oStructGWF:AddField("GWF_VALFRT", "", "Valor Frete", "", {"Valor da soma dos componentes de c�lculo."}, "GET", "@E 999,999,999.99", /*bPICTVAR*/, /*cLOOKUP*/, .F., /*"1"*/, /*cGRUP*/, /*aListaCombo*/, /*nMAXLENCOMBO*/, /*"1"*/, /*lVIRTUAL*/, /*cPICTVAR*/, /*lINSERTLIN*/) //"Valor da soma dos componentes de c�lculo."

	oStructGWD:RemoveField("GWD_NMCLI")
	
	If GFXCP12121("GWD_MAXQBR")
		oStructGWD:RemoveField("GWD_MAXQBR")
	EndIf
	
	oStructGWD:AddGroup("GrpId" , "Identifica��o", "2", 2)
	oStructGWD:AddGroup("GrpReg", "Registro", "2", 2)
	oStructGWD:AddGroup("GrpGen", "Generalidades", "2", 2)
	oStructGWD:AddGroup("GrpPP" , "P�tios e Portarias", "2", 2)
	
	oStructGWD:AddGroup("GrpGer", "Gerais", "2", 2)
	oStructGWD:AddGroup("GrpApr", "Aprova��o", "2", 2)
	
	oStructGWD:SetProperty("GWD_NROCO" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGWD:SetProperty("GWD_CDTRP" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGWD:SetProperty("GWD_NMTRP" , MVC_VIEW_GROUP_NUMBER, "GrpId")
	oStructGWD:SetProperty("GWD_ORIGEM", MVC_VIEW_GROUP_NUMBER, "GrpId")
		
	oStructGWD:SetProperty("GWD_DSOCOR", MVC_VIEW_GROUP_NUMBER, "GrpReg")
	oStructGWD:SetProperty("GWD_DSOCOR" , MVC_VIEW_ORDEM, "01")
	oStructGWD:SetProperty("GWD_CDTIPO", MVC_VIEW_GROUP_NUMBER, "GrpReg")
	oStructGWD:SetProperty("GWD_CDTIPO" , MVC_VIEW_ORDEM, "02")
	oStructGWD:SetProperty("GWD_DSTIPO", MVC_VIEW_GROUP_NUMBER, "GrpReg")
	oStructGWD:SetProperty("GWD_DSTIPO" , MVC_VIEW_ORDEM, "03")
	oStructGWD:SetProperty("GWD_CDMOT" , MVC_VIEW_GROUP_NUMBER, "GrpReg")
	oStructGWD:SetProperty("GWD_CDMOT" , MVC_VIEW_ORDEM, "04")
	oStructGWD:SetProperty("GWD_DSMOT" , MVC_VIEW_GROUP_NUMBER, "GrpReg")
	oStructGWD:SetProperty("GWD_DSMOT" , MVC_VIEW_ORDEM, "05")	
	
	If AScan(oStructGWD:aFields,{|x| x[1] == "GWD_PRESTS"}) != 0 
		oStructGWD:SetProperty("GWD_PRESTS" , MVC_VIEW_GROUP_NUMBER, "GrpReg")
		oStructGWD:SetProperty("GWD_PRESTS" , MVC_VIEW_ORDEM, "06")	
	EndIf
	If AScan(oStructGWD:aFields,{|x| x[1] == "GWD_DESPRE"}) != 0 
		oStructGWD:SetProperty("GWD_DESPRE" , MVC_VIEW_GROUP_NUMBER, "GrpReg")
		oStructGWD:SetProperty("GWD_DESPRE" , MVC_VIEW_ORDEM, "07")
	EndIf	
	oStructGWD:SetProperty("GWD_DSPROB", MVC_VIEW_GROUP_NUMBER, "GrpReg")
	oStructGWD:SetProperty("GWD_DSPROB" , MVC_VIEW_ORDEM, "08")		
	oStructGWD:SetProperty("GWD_DTOCOR", MVC_VIEW_GROUP_NUMBER, "GrpReg")
	oStructGWD:SetProperty("GWD_DTOCOR" , MVC_VIEW_ORDEM, "09")	
	oStructGWD:SetProperty("GWD_HROCOR", MVC_VIEW_GROUP_NUMBER, "GrpReg")
	oStructGWD:SetProperty("GWD_HROCOR" , MVC_VIEW_ORDEM, "10")	
	oStructGWD:SetProperty("GWD_NMCONT", MVC_VIEW_GROUP_NUMBER, "GrpReg")
	oStructGWD:SetProperty("GWD_NMCONT" , MVC_VIEW_ORDEM, "11")	

	oStructGWD:SetProperty("GWD_QTPERN", MVC_VIEW_GROUP_NUMBER, "GrpGen")
	oStructGWD:SetProperty("GWD_QTPERN" , MVC_VIEW_ORDEM, "01")
	oStructGWD:SetProperty("GWD_QTDVOL", MVC_VIEW_GROUP_NUMBER, "GrpGen")
	oStructGWD:SetProperty("GWD_QTDVOL" , MVC_VIEW_ORDEM, "02")
	
	If GFXCP12121("GWD_PESO") .And. GFXCP12121("GWD_VALIND")
		oStructGWD:SetProperty("GWD_PESO", MVC_VIEW_GROUP_NUMBER, "GrpGen")
		oStructGWD:SetProperty("GWD_PESO" , MVC_VIEW_ORDEM, "03")
		oStructGWD:SetProperty("GWD_VALIND", MVC_VIEW_GROUP_NUMBER, "GrpGen")
		oStructGWD:SetProperty("GWD_VALIND" , MVC_VIEW_ORDEM, "04")
	EndIf

	If GFXCP12121("GWD_CDREC") .And. GFXCP12121("GWD_NMREC")
		oStructGWD:SetProperty("GWD_CDREC" , MVC_VIEW_GROUP_NUMBER, "GrpReg")
		oStructGWD:SetProperty("GWD_NMREC" , MVC_VIEW_GROUP_NUMBER, "GrpReg")
	EndIf

	If GFXCP12130("GWD_URLENT")
		oStructGWD:SetProperty("GWD_URLENT", MVC_VIEW_GROUP_NUMBER, "GrpReg")
	EndIf
	
	oStructGWD:SetProperty("GWD_NRMOV" , MVC_VIEW_GROUP_NUMBER, "GrpPP")
	oStructGWD:SetProperty("GWD_CDPTCT", MVC_VIEW_GROUP_NUMBER, "GrpPP")
	
	oStructGWD:SetProperty("GWD_DTCRIA", MVC_VIEW_GROUP_NUMBER, "GrpGer")
	oStructGWD:SetProperty("GWD_HRCRIA", MVC_VIEW_GROUP_NUMBER, "GrpGer")
	oStructGWD:SetProperty("GWD_ACAODF", MVC_VIEW_GROUP_NUMBER, "GrpGer")
	oStructGWD:SetProperty("GWD_ACAODC", MVC_VIEW_GROUP_NUMBER, "GrpGer")
	oStructGWD:SetProperty("GWD_SIT"   , MVC_VIEW_GROUP_NUMBER, "GrpGer")
	oStructGWD:SetProperty("GWD_USUCRI", MVC_VIEW_GROUP_NUMBER, "GrpGer")
	
	oStructGWD:SetProperty("GWD_DSSOLU", MVC_VIEW_GROUP_NUMBER, "GrpApr")
	oStructGWD:SetProperty("GWD_DTBAI" , MVC_VIEW_GROUP_NUMBER, "GrpApr")
	oStructGWD:SetProperty("GWD_HRBAI" , MVC_VIEW_GROUP_NUMBER, "GrpApr")
	oStructGWD:SetProperty("GWD_USUBAI", MVC_VIEW_GROUP_NUMBER, "GrpApr")

	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField ir� representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,S� � necess�ri o caso estamos mundando o ID no View.
	oView:AddField("GFEC032_GWD" , oStructGWD, /*cLinkID*/ )	//
	oStructGWL:RemoveField("GWL_NROCO")
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. � a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas cria��es uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight � na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, � necess�rio informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	
	oView:AddGrid("GFEC032_GWL", oStructGWL )
	
	oView:AddGrid("GFEC032_GWF", oStructGWF )
	
	oView:CreateHorizontalBox("MASTER" , 60 )
	oView:CreateHorizontalBox("DETAIL" , 40 ) 
	
	oView:CreateFolder("IDFOLDER", "DETAIL")
	oView:AddSheet("IDFOLDER", "IDSHEET01", "Documentos de Carga") // "Documentos de Carga"
	oView:AddSheet("IDFOLDER", "IDSHEET02", "C�lculos de Frete") // "C�lculos de Frete"
	
	oView:CreateHorizontalBox("DETAILGWL", 100,,,"IDFOLDER", "IDSHEET01")
	
	oView:CreateHorizontalBox("DETAILGWF", 100,,,"IDFOLDER", "IDSHEET02")
	
	// Associa um View a um box
	oView:SetOwnerView("GFEC032_GWD" , "MASTER") 
	oView:SetOwnerView("GFEC032_GWL" , "DETAILGWL")
	oView:SetOwnerView("GFEC032_GWF" , "DETAILGWF")
	
	oView:AddUserButton("Cons. Doc. Carga", "", {|oView| GFEC32CDC(oView)}, ) // "Cons. Doc. Carga"
	oView:AddUserButton("Cons. C�lculo"   , "", {|oView| GFEC32CCL(oView)}, ) // "Cons. C�lculo"
	
Return oView

//---------------------------------------------

Function GFEC32CDC(oView)
	
	Local oModel    := oView:GetModel()
	Local oModelGWL := oModel:GetModel("GFEC032_GWL")
	Local nLine     := oModelGWL:GetLine()
	
	dbSelectArea("GW1")
	GW1->( dbSetOrder(1) )
	If GW1->( dbSeek(FwFldGet("GWL_FILDC", nLine) + FWFldGet("GWL_TPDC", nLine) + FWFldGet("GWL_EMITDC", nLine) + ;
				     FWFldGet("GWL_SERDC", nLine) + FWFldGet("GWL_NRDC", nLine)) )
				  
		FWExecView("Visualizar", "GFEC040", 1,,{|| .T.})
		
	EndIf
	
Return Nil

//---------------------------------------------

Function GFEC32CCL(oView)
	
	Local oModel    := oView:GetModel()
	Local oModelGWF := oModel:GetModel("GFEC032_GWF")
	Local nLine     := oModelGWF:GetLine()
	
	dbSelectArea("GWF")
	GWF->( dbSetOrder(1) )
	If GWF->( dbSeek(xFilial("GWF") + FWFldGet("GWF_NRCALC", nLine)) )
				  
		FWExecView("Visualiza", "GFEC080", 1,,{|| .T.})
		
	EndIf
	
Return Nil
