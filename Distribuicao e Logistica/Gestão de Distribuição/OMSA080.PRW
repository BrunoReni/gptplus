#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OMSA080.CH"

Static lAlianca := .F.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OMSA080  � Autor � Waldemiro L. Lustosa  � Data � 17.06.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Setores por Zona                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico (DISTRIBUIDORES)                                ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador    � Data   � BOPS �  Motivo da Alteracao                  ���
�������������������������������������������������������������������������Ĵ��
���Alex Egydio    �26.01.00�      �Conversao PROTHEUS ( OMSA080 )         ���
���Mauro Paladini �02/09/13�      �Conversao da rotina para o padrao MVC  ���
���Mauro Paladini �06/12/13� XXXX �Ajustes para o funcionamento do Mile   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function OMSA080()

	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias("DA6")
	oBrowse:SetDescription(STR0001) // "Cadastro de setores por Zona"
	oBrowse:SetMenuDef("OMSA080")
	oBrowse:SetCacheView(.F.) //-- Desabilita Cache da View, pois gera colunas dinamicamente
	oBrowse:Activate()

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ModelDef � Autor � Mauro Paladini        � Data �02.09.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Modelo de dados                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oModel Objeto do Modelo                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ModelDef()
Local oModel    := Nil
Local oStruCDA6 := Nil
Local oStruIDA6 := Nil
Local oStruCDA5 := Nil
Local cCposCab  := "DA6_FILIAL|DA6_PERCUR"
Local bInitDesc := FWBuildFeature(STRUCT_FEATURE_INIPAD,"Iif( !Inclui , Posicione('DA5',1,xFilial('DA5')+ DA6->DA6_PERCUR ,'DA5_DESC') , '' )")
Local bWhenDesc := FWBuildFeature(STRUCT_FEATURE_WHEN  ,".F.")
Local bWhenPerc := FWBuildFeature(STRUCT_FEATURE_WHEN  ,"Inclui")
Local bTrigger  := Nil

	oStruCDA5 := FwFormStruct( 1, "DA5" , { |cCampo|   AllTrim( cCampo ) $ "DA5_DESC" } )
	oStruCDA6 := FwFormStruct( 1, "DA6" , { |cCampo|   AllTrim( cCampo ) $ cCposCab   } ); Aadd(oStruCDA6:aFields,oStruCDA5:aFields[1])
	oStruIDA6 := FwFormStruct( 1, "DA6" , { |cCampo| !(AllTrim( cCampo ) $ cCposCab ) } )

	oStruCDA6:SetProperty("DA5_DESC"  ,MODEL_FIELD_INIT   , bInitDesc)
	oStruCDA6:SetProperty("DA5_DESC"  ,MODEL_FIELD_WHEN   , bWhenDesc)
	oStruCDA6:SetProperty("DA5_DESC"  ,MODEL_FIELD_VIRTUAL, .T.      )
	oStruCDA6:SetProperty("DA6_PERCUR",MODEL_FIELD_WHEN   , bWhenPerc) // Pode ser removido a partir da 12.1.21 (o campo n�o era chave da tabela)

	// Cria gatilho para o campo descricao da zona
	bTrigger  := { |oModel| Padr( Posicione("DA5",1,xFilial("DA5") + oModel:GetValue("DA6_PERCUR"),"DA5_DESC") ,TamSx3("DA5_DESC")[1]) }
	oStruCDA6:AddTrigger("DA6_PERCUR", "DA5_DESC", {|| .T.}, bTrigger)

	// Verifica se utiliza Alianca
	If IntTMS() .And. FindFunction("TmsAlianca") .And. TmsAlianca()
		lAlianca := .T.
	Else
		oStruIDA6:RemoveField("DA6_ALIANC")
	EndIf

	// Instancia o Model
	oModel:= MpFormMOdel():New("OMSA080",  /*bPreValid*/ , { |oMdl| PosVldMdl(oMdl) } , /*bComValid*/ ,/*bCancel*/ )
	oModel:SetDescription(STR0001)   // "Cadastro de setores por Zona"

	oModel:AddFields("MdFieldCDA6",Nil,oStruCDA6,/*prevalid*/,,/*bCarga*/)
	oModel:SetPrimaryKey({ "DA6_FILIAL" , "DA6_PERCUR" })

	oModel:AddGrid("MdGridIDA6", "MdFieldCDA6" /*cOwner*/, oStruIDA6 , /*bLinePre*/ , /*bLinePost*/ , /*bPre*/ , /*bPost*/,/*bLoad*/)
	oModel:SetRelation( "MdGridIDA6", { { "DA6_FILIAL", "xFilial('DA6')" }, { "DA6_PERCUR", "DA6_PERCUR" }   }, DA6->( IndexKey( 1 ) ) )
	oModel:GetModel( "MdGridIDA6" ):SetUniqueLine( {'DA6_ROTA'} )
	oModel:GetModel( "MdGridIDA6" ):SetMaxLine(30000)

	If !(IsInCallStack("CFG600LMdl") .Or. IsInCallStack("FWMILEIMPORT") .Or. IsInCallStack("FWMILEEXPORT"))
		oModel:SetVldActivate( { |oModel| Oma080Loc() } )
		oModel:SetDeActivate( { |oModel| MsUnLockAll() } )
	Endif

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ViewDef  � Autor � Mauro Paladini        � Data �02.09.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe browse de acordo com a estrutura                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oView do objeto oView                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function ViewDef()
Local oModel    := FwLoadModel("OMSA080")
Local oView     := Nil
Local oStruCDA6 := Nil
Local oStruIDA6 := Nil
Local oStruCDA5 := Nil
Local cCposCab  := "DA6_FILIAL|DA6_PERCUR"

	oStruCDA5 := FwFormStruct( 2, "DA5" , { |cCampo|   AllTrim( cCampo ) $ "DA5_DESC" } )
	oStruCDA6 := FwFormStruct( 2, "DA6" , { |cCampo|   AllTrim( cCampo ) $ cCposCab   } ); Aadd(oStruCDA6:aFields,oStruCDA5:aFields[1])
	oStruIDA6 := FwFormStruct( 2, "DA6" , { |cCampo| !(AllTrim( cCampo ) $ cCposCab ) } )

	If !lAlianca
		oStruIDA6:RemoveField("DA6_ALIANC")
	EndIf

	// Instancia a View
	oView := FwFormView():New()
	oView:SetModel(oModel)

	oView:AddField('VwFieldCDA6', oStruCDA6 , 'MdFieldCDA6')
	oView:AddGrid( 'VwGridIDA6', oStruIDA6 , 'MdGridIDA6')

	oView:CreateHorizontalBox("SUPERIOR",20)
	oView:CreateHorizontalBox("INFERIOR",80)

	oView:EnableTitleView('VwFieldCDA6',STR0007 ) // "Zona "
	oView:EnableTitleView('VwGridIDA6' ,STR0010 ) // "Setores"

	oView:SetOwnerView("VwFieldCDA6","SUPERIOR")
	oView:SetOwnerView("VwGridIDA6","INFERIOR")

Return oView

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Oma080Loc� Autor � Mauro Paladini        � Data �02.09.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz o bloqueio dos registros para edicao                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nil                                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Oma080Loc()
Local lRet          := .T.
Local aDA6Area      := DA6->( GetArea() )
Local cCodigo       := DA6->DA6_PERCUR

	IF !INCLUI .And. !ALTERA
		Return .T.
	Endif

	DA6->( DbSetOrder(1) )
	IF DA6->( DbSeek( xFilial("DA6") + cCodigo ) )

		While DA6->( !Eof() .And.  DA6_FILIAL+DA6_PERCUR == xFilial("DA6") + cCodigo .And. lRet )

			If !( SoftLock("DA6" ) )
				lRet := .F.
			Endif
			DA6->( DbSkip() )

		End

	Endif

	If !lRet
		DA6->( MsUnLockAll() )
	Endif

	RestArea(aDA6Area)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MenuDef  � Autor � Mauro Paladini        � Data �02.09.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � MenuDef com as rotinas do Browse                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina array com as rotina do MenuDef                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002    ACTION "PesqBrw"         OPERATION 1 ACCESS 0  //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003    ACTION "VIEWDEF.OMSA080" OPERATION 2 ACCESS 0  //"Visualizar"
	ADD OPTION aRotina TITLE STR0004    ACTION "VIEWDEF.OMSA080" OPERATION 3 ACCESS 0  //"Incluir"
	ADD OPTION aRotina TITLE STR0005    ACTION "VIEWDEF.OMSA080" OPERATION 4 ACCESS 0  //"Alterar"
	ADD OPTION aRotina TITLE STR0006    ACTION "VIEWDEF.OMSA080" OPERATION 5 ACCESS 0  //"Excluir"

	//������������������������������������������������������������������������Ŀ
	//� Ponto de entrada utilizado para inserir novas opcoes no array aRotina  �
	//��������������������������������������������������������������������������
	If ExistBlock("OM080MNU")
		ExecBlock("OM080MNU",.F.,.F.)
	EndIf

Return aRotina

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PosVldMdl � Autor � Mauro Paladini        � Data �03/09/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de validacao da model (compatibilizacao)             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPL1 - .T./.F. Logico                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�<oModel>                                                    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PosVldMdl(oMdl)
Local lRet := .T.

	If oMdl <> Nil

		IF oMdl:GetOperation() == MODEL_OPERATION_DELETE
			lRet := Oms080Del(oMdl)
		Elseif oMdl:GetOperation() == MODEL_OPERATION_INSERT .Or. oMdl:GetOperation() == MODEL_OPERATION_UPDATE
			lRet := D080TudOk(oMdl)
		Endif

	Endif

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �OMS080Del � Autor � Mauro Paladini        � Data �03/09/2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Faz a validacao na exclusao                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPL1 - .T./.F. Logico                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�<oModel>                                                    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Oms080Del( oMdl )
Local cZona     := DA6->DA6_PERCUR
Local aArea     := GetArea()
Local lRet      := .T.

	DbSelectArea("DA5")
	DA5->( dbSetOrder(1) )

	//�����������������������������������������������������������Ŀ
	//�Verifica a integridade com o cadastro de clientes por setor�
	//�������������������������������������������������������������

	If !Inclui .And. MsSeek(xFilial("DA5")+cZona)

		dbSelectArea("DA6")
		dbSetOrder(1)
		If MsSeek( xFilial("DA6")+cZona )

			While !Eof().And.DA6->DA6_FILIAL+DA6->DA6_PERCUR == xFilial("DA6")+cZona

				dbSelectArea("DA7")
				dbSetOrder(1)
				If MsSeek(xFilial("DA7")+DA6->DA6_PERCUR+DA6->DA6_ROTA )
					Help(" ",1, "OMS080DEL")
					lRet := .F.
					Exit
				Endif

				If lRet
					dbSelectArea("DA9")
					dbSetOrder(2)
					If MsSeek(xFilial("DA9")+DA6->DA6_PERCUR+DA6->DA6_ROTA )
						Help(" ",1, "OMS080DEL")
						lRet := .F.
						Exit
					Endif
				Endif

				dbSelectArea("DA6")
				dbSkip()

			Enddo

		Endif

	Endif

RestArea(aArea)
Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � D080TUDOK� Autor � Henry Fila            � Data � 24.06.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacoes no TudoOk da Grid                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � APDL                                                       ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador    � Data   � BOPS �  Motivo da Alteracao                  ���
�������������������������������������������������������������������������Ĵ��
���Alex Egydio    �26.01.00�      �Conversao PROTHEUS ( OMSA080 )         ���
���Mauro Paladini �03/09/13�      �Conversao da rotina para o padrao MVC  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function D080TudOk( oMld )
Local aArea       := GetArea()
Local lRet        := .T.
Local oModel      := FWModelActive()
Local oModelIDA6  := oModel:GetModel( "MdGridIDA6" )
Local nI          := 0
Local aSaveLines  := FWSaveRows()

	IF oModel:GetOperation() == MODEL_OPERATION_INSERT .And. !ExistChav("DA6",M->DA6_PERCUR)
		lRet := .F.
	Endif

	If lRet

		For nI := 1 To oModelIDA6:Length()

			oModelIDA6:GoLine( nI )

			If oModelIDA6:IsDeleted()

				dbSelectArea("DA7")
				dbSetOrder(1)
				If MsSeek(xFilial("DA7") + M->DA6_PERCUR + oModelIDA6:GetValue("DA6_ROTA") )
					lRet:= .F.
					Exit
				Endif

				If lRet
					dbSelectArea("DA9")
					dbSetOrder(2)
					If MsSeek(xFilial("DA9") + M->DA6_PERCUR + oModelIDA6:GetValue("DA6_ROTA") )
						lRet:= .F.
						Exit
					EndIf
				EndIf

			EndIf
		Next

		If !lRet
			Help(" ",1, "OMS080DEL")
		EndIf

		FWRestRows( aSaveLines )

	Endif

RestArea(aArea)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �OMSA080VLD�Autor  �Henry Fila          � Data �  04/24/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao da rota na digitacao                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Oms080Vld(oDesc)
Local cZona := IIf (!Inclui,DA6->DA6_PERCUR,M->DA6_PERCUR )
Local lRet  := .T.
Local aArea := GetArea()

	dbSelectArea("DA6")
	dbSetOrder(1)
	If MsSeek(xFilial("DA6")+cZona)
		Help(" ",1,"OMS080ZONA") //Zona ja existe no cadastro de setores por zona, altere a mesma desejada.
		lRet := .F.
	Else
		dbSelectArea("DA5")
		dbSetOrder(1)
		If MsSeek(xFilial("DA5")+cZona)
			cDesc := DA5->DA5_DESC
			oDesc:Refresh()
		Else
			Help(" ",1,"REGNOIS") //Zona ja existe no cadastro de setores por zona, altere a mesma desejada.
			lRet := .F.
		Endif
	Endif

RestArea(aArea)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �OMSA080VLD�Autor  �Henry Fila          � Data �  04/24/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Validacao da rota na digitacao                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Oms080Vld2()
Local cZona     := IIf (!Inclui,DA6->DA6_PERCUR,M->DA6_PERCUR )
Local aArea     := GetArea()
Local aAreaDA5  := DA5->(GetArea())
Local aAreaDAA  := DAA->(GetArea())
Local lRet      := .T.

	DA5->(dbSetOrder(1))
	If DA5->(MsSeek(xFilial("DA5")+cZona))
		If !Empty(DA5->DA5_CODCAL)
			lRet := OmsVldCal(DA5->DA5_CODCAL,M->DA6_CODCAL)
			If !lRet
				Help(" ",1,"OMS080CAL")
			Endif
		Endif
	Endif

RestArea(aAreaDAA)
RestArea(aAreaDA5)
RestArea(aArea)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Oms080When�Autor  � Robson Alves       � Data �  11.08.2003 ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se o campo pode ser editado.                      ���
�������������������������������������������������������������������������͹��
���Uso       � OMS                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Oms080When( cCampo )
Local lRet      := .T.
Local aAreaDA7  := DA7->( GetArea() )
Local oModel    := FWModelActive()
Local cZona     := M->DA6_PERCUR
Local cSetorOri := oModel:GetValue( "MdGridIDA6" , "DA6_ROTA" )

DEFAULT cCampo  := ReadVar()

	If "DA6_ROTA" $ cCampo
		DA7->( dbSetOrder( 1 ) )
		If DA7->( MsSeek( xFilial("DA7") + cZona + cSetorOri ) )
			Help(" ",1, "OMS080ALT") // Jah existe um relacionamento deste setor com clientes. Alteracao nao permitida.
			lRet := .F.
		EndIf
	EndIf

RestArea( aAreaDA7 )
Return lRet
