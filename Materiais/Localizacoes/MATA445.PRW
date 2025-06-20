#include "protheus.ch"
#include "fwmvcdef.ch"
#include "rwmake.ch"
#include "mata445.ch"
/*
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������ͻ��
���Programa  � MATA445  �Autor  �   Marco Augusto Gonzalez    � Data � 23/02/2016    ���
������������������������������������������������������������������������������������͹��
���Desc.     � Registro de Impuestos de Importacion (MEX)                            ���
������������������������������������������������������������������������������������͹��
���Uso       � Generico                                                              ���
������������������������������������������������������������������������������������͹��
���                  ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               ���
������������������������������������������������������������������������������������͹��
���Programador� Data     �    BOPS/FNC    | Motivo da Alteracao                      ���
������������������������������������������������������������������������������������͹��
��� Marco A.  �20/10/2017� TSSERMI01-219  �Se modifica funcion MATA445Pos(), para    ���
���           �          �                �ejecucion de scripts de Automatizacion.   ���
������������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������*/
Function MATA445()

	Local oBrowse

	oBrowse	:= FWMBrowse():New()
	oBrowse:SetAlias("RSA")
	oBrowse:SetDescription(STR0001) // "Impuestos de Importacion"
	oBrowse:Activate()

Return NIL

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � MenuDef    � Autor � Marco Augusto Glz     � Data �23/02/2016���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Definicion del menu para Registro de Impuestos de Importacion���
���          � (MEX)                                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � MATA445                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function MenuDef()

	Local aRotina	:= {}

	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.MATA445" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.MATA445" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.MATA445" OPERATION 4 ACCESS 0 // "Modificar"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.MATA445" OPERATION 5 ACCESS 0 // "Eliminar"

Return aRotina

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ModelDef   � Autor � Marco Augusto Glz     � Data �23/02/2016���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Creacion del Modelo para Registro de Impuestos de Importacion���
���          � (MEX)                                                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � MATA445                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function ModelDef()

	Local oStruRSA	:= FWFormStruct(1, "RSA")
	Local oModel

	oModel := MPFormModel():New("RSA001M", /*bPreValidacao*/, {|oMdl| MATA445Pos(oMdl)}, /*bCommit*/, /*bCancel*/ ) // Creacion del Modelo
	oModel:AddFields("RSAMASTER", /*cOwner*/, oStruRSA)
	oModel:SetPrimaryKey({"RSA_CODIGO"})
	oModel:SetDescription(STR0006) // "Impuestos de Importacion"
	oModel:GetModel("RSAMASTER"):SetDescription(STR0007) // "Datos de Impuestos de Importacion"

Return oModel

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun�ao    � ViewDef    � Autor � Marco Augusto Glz     � Data �23/02/2016 ���
����������������������������������������������������������������������������Ĵ��
���Descri�ao � Creacion de la Vista para Registro de Impuestos de Importacion���
���          � (MEX)                                                         ���
����������������������������������������������������������������������������Ĵ��
��� Uso      � MATA445                                                       ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function ViewDef()

	Local oModel		:= FWLoadModel("MATA445")
	Local oStruRSA	:= FWFormStruct(2, "RSA")
	Local oView

	oView	:= FWFormView():New()// Creacion de la Vista
	oView:SetModel(oModel)
	oView:AddField("VIEW_RSA", oStruRSA, "RSAMASTER")
	oView:CreateHorizontalBox("TELA", 100)
	oView:SetOwnerView("VIEW_RSA", "TELA")

Return oView

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun�ao    � MTA445Pos     � Autor � Marco Augusto Glz     � Data �25/02/2016���
������������������������������������������������������������������������������Ĵ��
���Descri�ao � Definicion de la logica para PosValidacion de Impuestos de      ���
���          � Importacion (MEX)                                               ���
������������������������������������������������������������������������������Ĵ��
��� Uso      � MATA445                                                         ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function MATA445Pos(oModel)

	Local lRet			:= .T.
	Local aArea			:= GetArea()
	Local nOperation	:= oModel:GetOperation() // Se obtiene la operacion seleccionada por el usuario
	Local lAutomato		:= IsBlind()

	If nOperation  == MODEL_OPERATION_DELETE

		DbSelectArea("RSH")
		DbSelectArea("RSD")

		RSH->(dbSetOrder(3)) // RSH_FILIAL+RSH_IMPUES

		If RSH->(DBSeek(xFilial("RSH") + RSA->RSA_CODIGO)) // Se verifica si hay un registro relacionado en Impuestos
			lRet := .F.
		Else
			RSD->(dbSetOrder(2)) // RSD_FILIAL+RSD_CODIMP
			If RSD->(DBSeek(xFilial("RSD") + RSA->RSA_CODIGO)) // Se verifica si hay un registro relacionado en Impuestos Nivel Pedimento
				lRet := .F.
			EndIf
		EndIf

		If !lRet
			If !lAutomato
				Help("",1,"IMPUSADO",,STR0008,1,0) // "El impuesto esta siendo utilizado por un Pedimento. No es posible eliminarlo."
			Else
				Help("",,"Auto01",,STR0008,1,0 )
			Endif
		Else
			If !lAutomato
				If MsgYesNo(STR0009) // "�Desea confirmar la eliminacion?"
					lRet := .T.
				Else
					lRet := .F.
				EndIf
			Else
				If FindFunction( "GetParAuto" )
					aRetAuto := GetParAuto( "MATA445TESTCASE" )	
					lRet := aRetAuto[1]
				EndIf 
			EndIf
		EndIf
		
	EndIf

	RestArea(aArea)

Return lRet

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun�ao    � MTA445ProdVld  � Autor � Marco Augusto Glz     � Data �23/02/2016���
�������������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcion creada para validar que en la tabla RSA, no existan      ���
���          � registros con Codigo de Producto repetido. (MEX)                 ���
�������������������������������������������������������������������������������Ĵ��
��� Uso      � En X3_VALID del campo RSA_CODPRD                                 ���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
Function MTA445ProdVld()

	Local lRet		:= .F.
	Local aArea	:= GetArea()

	If !Empty(M->RSA_CODPRD)
		If ExistCpo("SB1", M->RSA_CODPRD)
			DbSelectArea("RSA")
			dbSetOrder(4) // RSA_FILIAL+RSA_CODPRD
			If !DbSeek(xFilial("RSA") + M->RSA_CODPRD)
				lRet := .T.
			ElseIf RSA->RSA_FILIAL == M->RSA_FILIAL .AND. RSA->RSA_CODIGO == M->RSA_CODIGO
				lRet := .T.
			Else
				MsgInfo(STR0010) // "El Codigo de Producto ya esta relacionado a otro Impuesto. Seleccione otro Codigo de Producto."
			EndIf
		EndIF
	EndIf

	RestArea(aArea)

Return lRet

/*
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun�ao    � MTA445AranVld  � Autor � Marco Augusto Glz     � Data �23/02/2016���
�������������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcion creada para validar que en la tabla RSA, no exista mas de���
���          � un registro con Fraccion arancelaria aplicada. (MEX)             ���
�������������������������������������������������������������������������������Ĵ��
��� Uso      � En X3_VALID del campo RSA_USOFRA                                 ���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
*/
Function MTA445AranVld()

	Local lRet := .T.

	DbSelectArea("RSA")
	dbSetOrder(3) // RSA_FILIAL+RSA_USOFRA

	If DbSeek(xFilial("RSA") + M->RSA_USOFRA) .And. M->RSA_USOFRA == "1"
		lRet := .F.
		MsgInfo(STR0011) // "La Fraccion Arancelaria ya esta relacionada a un Impuesto. Seleccione otra opcion."
	EndIf

Return lRet

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun�ao    � MTA445FuncExist  � Autor � Marco Augusto Glz     � Data �23/02/2016���
���������������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcion creada para validar que la funcion ingresada en el campo   ���
���          � RSA_FUNC, exista en el RPO. (MEX)                                  ���
���������������������������������������������������������������������������������Ĵ��
��� Uso      � En X3_VALID del campo RSA_FUNC                                     ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Function MTA445FuncExist()

	Local cFunc	:=	ALLTRIM(readvar())
	Local lRet 	:=  .F.

	If ExistBlock(&cFunc, .T.)
		lRet := .T.
	Else
		MsgInfo(STR0012) // "La funcion ingresada debe existir en el RPO"
	EndIf

Return lRet

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun�ao    � MTA445CodVld  � Autor � Marco Augusto Glz     � Data �23/02/2016���
������������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcion creada para validar el campo RSA_CODIGO cuando se       ���
���          � utiliza la opcion incluir. (MEX)                                ���
������������������������������������������������������������������������������Ĵ��
��� Uso      � En X3_VALID del campo RSA_CODIGO                                ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Function MTA445CodVld()

	Local lRet	:=	.T.

	If !(NaoVazio()) .Or. !(ExistChav("RSA")) .Or. !(FreeForUse("RSA", M->RSA_CODIGO))
		lRet	:=	.F.
	EndIf

Return lRet