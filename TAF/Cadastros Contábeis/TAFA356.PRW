#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA356.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA356
Cadastro MVC de Outras Informa��es

@author Denis R de Oliveira
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA356()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 )	//"Cadastro de Outras Informa��es"
oBrw:SetAlias( 'CGU')
oBrw:SetMenuDef( 'TAFA356' ) 
CGU->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Denis R de Oliveira
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {{ "" , "TAF356Vld" , "2" } }
Local aRotina := {}

aRotina	:=	xFunMnuTAF( "TAFA356" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis R de Oliveira
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCGU 	:= 	FWFormStruct( 1, 'CGU' )
LocaL oModel 	:=  MPFormModel():New( 'TAFA356' , , , {|oModel| SaveModel( oModel ) } )  

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )
	
If lVldModel
	oStruCGU:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel }) 		
EndIf

oModel:AddFields('MODEL_CGU' , /*cOwner*/, oStruCGU) 

//Define a chave �nica de grava��o das informa��es
oModel:GetModel('MODEL_CGU'):SetPrimaryKey( {'CGU_PERIOD'} ) 
             

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis R de Oliveira
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	:= 	FWLoadModel( 'TAFA356' )
Local oStruCGU 	:= 	FWFormStruct( 2, 'CGU' )
Local oView 	:= 	FWFormView():New()


/*----------------------------------------------------------------------------------
Esrutura da View
-------------------------------------------------------------------------------------*/
oView:SetModel( oModel )

oStruCGU:RemoveField('CGU_ID')
                                       
oView:AddField('VIEW_CGU' , oStruCGU,  'MODEL_CGU' ) 
oView:EnableTitleView( 'VIEW_CGU', STR0001 ) //"Cadastro de Outras Informa��es" 

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL") // CGU - Outras Informa��es

/*-----------------------------------------------------------------------------------
Amarra��o para exibi��o das informa��es
-------------------------------------------------------------------------------------*/
oView:SetOwnerView( 'VIEW_CGU', 'PAINEL_PRINCIPAL' )   

Return oView    

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis R. de Oliveira
@since 26/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation := oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
	
		//�������������������������������������������������������������Ŀ
		//�Funcao responsavel por setar o Status do registro para Branco�
		//���������������������������������������������������������������
		TAFAltStat( "CGU", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf356Vld

@author Denis R. de Oliveira
@since 26/05/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF356Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}

Default lJob := .F.

If CGU->CGU_STATUS $ ( " |1" )      

	//Valida o Periodo do lancamento     
	If Empty(CGU->CGU_PERIOD)
		Aadd( aLogErro, {"CGU_PERIOD", "000001", "CGU", nRecno}) //STR0001 - Campo Inconsistente ou Vazio
	EndIf
		
	//Valida a Ateracao no Capital      
	If !Empty(CGU->CGU_ALTCAP)

		If !(CGU->CGU_ALTCAP $ ("0|1|2"))
			AADD(aLogErro,{"CGU_ALTCAP","000002","CGU", nRecno}) //STR0002 - Conte�do do campo n�o condiz com as op��es poss�veis.
		EndIf 
		
	EndIf 
	
	//Valida a Opcao Base Neg CSLL          
	If !Empty(CGU->CGU_OBNCSL)

		If !(CGU->CGU_OBNCSL $ ("0|1|2"))
			AADD(aLogErro,{"CGU_OBNCSL","000002","CGU", nRecno}) //STR0002 - Conte�do do campo n�o condiz com as op��es poss�veis.
		EndIf 
		
	EndIf		
		
	//�������������������������������
	//�ATUALIZO O STATUS DO REGISTRO�
	//�1 = Registro Invalido        �
	//�0 = Registro Valido          �
	//�������������������������������
	If Len(aLogErro)>0
		//������������������������������������������������������������������Ŀ
		//�Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS�
		//��������������������������������������������������������������������
		RecLock("CGU",.F.)
		CGU->CGU_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CGU",.F.)
		CGU->CGU_STATUS := "0"
		MsUnlock()
	EndIf	  	    
	
	
Else
	
	AADD(aLogErro,{"CGU_ID","000017","CGU", nRecno})//STR0017 - Registro j� validado.
	
EndIf


//�������������������������������������������������������Ŀ
//�N�o apresento o alert quando utilizo o JOB para validar�
//���������������������������������������������������������
If !lJob
	VldECFLog(aLogErro)
EndIf


Return(aLogErro)