#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE "TMSA660.ch"
#Include "PROTHEUS.CH"

//-----------------------------------------------------------------------------------------------------------
/* Feruiados Regionais  
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 	05/10/2012
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Function TMSA660(aRotAuto,nOpcAuto)

Local oMBrowse		:= Nil
Local cCadastro		:= OemToAnsi( STR0001 ) //"Feriados Municipais"
Local l660Auto 		:= (ValType(aRotAuto) == "A")

Private aRotina		:= MenuDef()
Private aAutoCab		:= {}

Default aRotAuto 		:= Nil
Default nOpcAuto 		:= 3

If !l660Auto
	oMBrowse:= FWMBrowse():New()	
	oMBrowse:SetAlias( "DV8" )
	oMBrowse:SetDescription( cCadastro )
	oMBrowse:Activate()
Else
	aAutoCab := aRotAuto
	FwMvcRotAuto( ModelDef(), "DV8", nOpcAuto, { { "TMSA660DV8", aAutoCab } } )  //Chamada da rotina automatica atrav�s do MVC
EndIf

Return Nil

//-----------------------------------------------------------------------------------------------------------
/* Modelo de Dados 
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 	05/10/2012
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel 		:= Nil
Local oStruDV8 	:= FwFormStruct( 1, "DV8" )

oModel := MpFormModel( ):New( "TMSA660", /*bPre*/, { |oModel| PosVldMdl( oModel ) }, /*bCommit*/, /*bCancel*/ )

oModel:AddFields( "TMSA660DV8", Nil, oStruDV8, /*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/ )

oModel:SetPrimaryKey( { "DV8_FILIAL", "DV8_DIAMES", "DV8_ANO", "DV8_CDRDES" } )
                                                                                                                 
oModel:SetDescription( OemToAnsi( STR0001 ) ) //"Feriados Municipais"                                                                                                   

Return( oModel )

//-----------------------------------------------------------------------------------------------------------
/* Retorna a View (tela) da rotina Cadastro de Feriados regionais
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 	05/10/2012
@return 	*/
//-----------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:= FwLoadModel( "TMSA660" )
Local oView		:= Nil
Local oStruDV8	:= FwFormStruct( 2, "DV8" )

oView := FwFormView():New()

oView:SetModel( oModel )
oView:CreateHorizontalBox( "Field", 100 )

oView:AddField( "FieldDV8", oStruDV8, "TMSA660DV8" )

oView:SetOwnerView( "FieldDV8", "Field" )

Return( oView )


//===========================================================================================================
/* Retorna as opera��es disponiveis para o Cadastro de Feriados Regionais.
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 	05/10/2012
@return 	aRotina - Array com as op�oes de Menu */                                                                                                         
//===========================================================================================================
Static Function MenuDef()

Local aArea	:= GetArea()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"          , 0, 1, 0, .T. } ) // Pesquisar
aAdd( aRotina, { STR0003, "VIEWDEF.TMSA660"  , 0, 2, 0, .F. } ) // Visualizar
aAdd( aRotina, { STR0004, "VIEWDEF.TMSA660"  , 0, 3, 0, Nil } ) // Incluir
aAdd( aRotina, { STR0005, "VIEWDEF.TMSA660"  , 0, 4, 0, Nil } ) // Alterar
aAdd( aRotina, { STR0006, "VIEWDEF.TMSA660"  , 0, 5, 3, Nil } ) // Excluir

Return( aRotina )

//===========================================================================================================
/* P�S validacao do Model
@author  	Jefferson Tomaz
@version 	P11 R11.7
@build		700120420A
@since 	05/10/2012
@return 	lRet */                                                                                                         
//===========================================================================================================
Static Function PosVldMdl( oMdl )

Local lRet     :=.T.  
Local aArea    := GetArea()
Local aAreaDV8 := DV8->(GetArea())
Local nOpcx	 := oMdl:GetOperation()
Local cDiaMes  := oMdl:GetValue('TMSA660DV8','DV8_DIAMES')
Local cAno     := oMdl:GetValue('TMSA660DV8','DV8_ANO')
Local cCdrDes  := oMdl:GetValue('TMSA660DV8','DV8_CDRDES')


DV8->(dbSetOrder(1))
If  nOpcx == MODEL_OPERATION_INSERT .And.; 
	  DV8->(MsSeek(xFilial("DV8")+cDiaMes+cAno+cCdrDes))
	  
	lRet := .F.
	Help(" ",1,"JAGRAVADO") //"Ja existe registro com esta informacao"
Endif	

RestArea(aAreaDV8)
RestArea(aArea)


Return lRet

/*                                                   								
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa  �TMSA660VLD  � Autor �  Henry Fila        � Data � 01/10/01 ���
�������������������������������������������������������������������������͹��
��� Programa  � Valida campo Dia/Mes digitado                             ���
�������������������������������������������������������������������������͹��
��� Sintaxe   � TMSA660()                                                 ���
�������������������������������������������������������������������������͹��
��� Parametros�                                          			        ���
�������������������������������������������������������������������������͹��
��� Retorno   � EXPL1 := Validacao                                        ���
�������������������������������������������������������������������������͹��
��� Uso       � TMS - Gestao de Transportes 		            	           ���
�������������������������������������������������������������������������͹��
���         Atualizacoes efetuadas desde a codificacao inicial            ���
�������������������������������������������������������������������������͹��
���Programador� Data   � BOPS �  Motivo da Alteracao                      ���
�������������������������������������������������������������������������͹��
���           �xx/xx/01�xxxxxx�                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Tmsa660Vld()

Local lRet     := .T.

Local cDataVal := ""

Do Case

	Case ReadVar() == "M->DV8_DIAMES"

		If Empty(M->DV8_ANO)
		
			cDataVal := M->DV8_DIAMES+"/"+StrZero(Year(dDatabase),4)

			If Empty(Ctod(cDataVal))
				lRet := .F.
			Endif	
					                                          
		Else					
			cDataVal := M->DV8_DIAMES+"/"+M->DV8_ANO

			If Empty(Ctod(cDataVal))
				lRet := .F.
			Endif	

		Endif
			
	Case  ReadVar() == "M->DV8_ANO"

			cDataVal := M->DV8_DIAMES+"/"+M->DV8_ANO

			If Empty(Ctod(cDataVal))
				lRet := .F.
			Endif	

	EndCase
	
Return(lRet)

