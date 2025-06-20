#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"     
#include "agra760.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGRA760   �Autor  �Ricardo Tomasi      � Data �  12/07/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para cadastro de balancas.                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Clientes Totvs                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AGRA760()
Local oMBrowse	:= Nil

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "DX5" )
oMBrowse:SetDescription( STR0001 )
oMBrowse:AddLegend( "DX5_STATUS=='1'", "GREEN", STR0002)
oMBrowse:AddLegend( "DX5_STATUS=='2'", "RED"  , STR0003)
oMBrowse:DisableDetails()
oMBrowse:Activate()

Return()


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  �Ricardo Tomasi      � Data �  12/07/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao auxiliar para criacao do menu do browser.            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Clientes Totvs                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0004 , 'PesqBrw'        , 0, 1, 0, .T. } )
aAdd( aRotina, { STR0005 , 'ViewDef.AGRA760', 0, 2, 0, Nil } )
aAdd( aRotina, { STR0006 , 'ViewDef.AGRA760', 0, 3, 0, Nil } )
aAdd( aRotina, { STR0007 , 'ViewDef.AGRA760', 0, 4, 0, Nil } )
aAdd( aRotina, { STR0008 , 'ViewDef.AGRA760', 0, 5, 0, Nil } )
aAdd( aRotina, { STR0009 , 'ViewDef.AGRA760', 0, 8, 0, Nil } )
aAdd( aRotina, { STR0010 , 'ViewDef.AGRA760', 0, 9, 0, Nil } )

Return aRotina


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �Ricardo Tomasi      � Data �  12/07/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �Modelo de dados da rotina						              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Clientes Totvs                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()
Local oStruDX5 := FWFormStruct( 1, 'DX5' )
Local oModel := MPFormModel():New( 'AGRA760', , { | oModel | ValModel( oModel ) } )

oModel:AddFields( 'DX5UNICO', Nil, oStruDX5 )
oModel:SetDescription( STR0011 )
oModel:GetModel( 'DX5UNICO' ):SetDescription( STR0011 )

Return oModel


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  �Ricardo Tomasi      � Data �  12/07/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �Modelo visualiza��o da rotina 				              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Clientes Totvs                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()
Local oStruDX5 := FWFormStruct( 2, 'DX5' )
Local oModel   := FWLoadModel( 'AGRA760' )
Local oView    := FWFormView():New()

oView:AddUserButton( 'Testar' , 'CLIPS', { | oModel | Testar( oModel ) } )

oView:SetModel( oModel )
oView:AddField( 'VIEW_DX5', oStruDX5, 'DX5UNICO' )
oView:CreateHorizontalBox( 'UNICO', 100 )
oView:SetOwnerView( 'VIEW_DX5', 'UNICO' )

Return oView


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValModel  �Autor  �Ricardo Tomasi      � Data �  12/07/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida��o do modelo de dados						          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Clientes Totvs                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ValModel( oModel )
Local lRetorno 	:= .t.
Local aAreaAtu	:= GetArea()
Local nOperation	:= oModel:GetOperation()
Local cAliasQry	:= ''
Local cQuery		:= ''
Local cCodBal		:= ''

If nOperation = MODEL_OPERATION_DELETE

	cCodBal		:= oModel:GetValue( 'DX5UNICO', 'DX5_CODIGO' )
	cAliasQry 	:= GetNextAlias( )
	
	cQuery 		:= "select count(*) as REGISTROS"
	cQuery 		+= " from " + RetSqlName( "DX6" ) + " DX6"
	cQuery 		+= " where D_E_L_E_T_ = ' '"
	cQuery 		+= " and DX6.DX6_FILIAL	= '" + xFilial( "DX6" ) + "' "
	cQuery 		+= " and DX6.DX6_CODBAL	= '" + cCodBal + "'"
	cQuery 		:= ChangeQuery( cQuery ) 

	dbUseArea( .t., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .f., .t. )
	dbGoTop()
	If (cAliasQry)->REGISTROS > 0
		Help( "", 1, OemToAnsi( STR0012 ), , OemToAnsi( STR0013 ), 1 )
		lRetorno := .f.
	EndIf
	(cAliasQry)->(dbCloseArea())

EndIf

RestArea( aAreaAtu )
Return( lRetorno )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Testar   �Autor  �Ricardo Tomasi      � Data �  12/07/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �Teste de conex�o com a balan�						          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Clientes Totvs                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Testar( oModel )
Local cCodigo	:= oModel:GetValue( "DX5UNICO", "DX5_CODIGO" )
Local nPeso		:= 0


AGRX003A( @nPeso, , { cCodigo, .t., .f. } )


/*
If .Not. AGRX003C( cTipPor, cTipVel, cTipPar, cNBitDa, cNBitPa, cTimOut )
	Help( , , STR0012, , STR0014, 1, 0 )
Else
	//Help( , , "Ajuda", , "Comunica��o com a balan�a bem sucedida!", 1, 0 )
	AGRX003A( @nPeso, , { cCodigo, .t., .f. } )
EndIf

*/
Return( Nil )
