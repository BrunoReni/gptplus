#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA367.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA367
Outras Informa寤es

@author Denis R de Oliveira
@since 25/09/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA367()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 )
oBrw:SetAlias('CH9')
oBrw:SetMenuDef( 'TAFA367' )
oBrw:SetCacheView(.F.)
oBrw:Activate()  


Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Denis R. de Oliveira
@since 25/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf367Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA367" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis R de Oliveira
@since 25/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCH9 	:= FWFormStruct( 1, 'CH9' )
Local oModel	 	:= MPFormModel():New( 'TAFA367' , , , {|oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_CH9', /*cOwner*/, oStruCH9)
oModel:GetModel( 'MODEL_CH9' ):SetPrimaryKey( { "CH9_PERIOD" } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View
@return oView - Objeto da View MVC
@author Denis R de Oliveira
@since 25/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA367' )
Local 	oStruCH9 	:= 	FWFormStruct( 2, 'CH9' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_CH9', oStruCH9, 'MODEL_CH9' )

oView:EnableTitleView( 'VIEW_CH9', STR0001 ) // Outras Informa寤es
oView:CreateHorizontalBox( 'FIELDSCH9', 100 )
oView:SetOwnerView( 'VIEW_CH9', 'FIELDSCH9' )

oStruCH9:RemoveField('CH9_ID')


Return oView   

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis R. de Oliveira
@since 25/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation := oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
	
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿑uncao responsavel por setar o Status do registro para Branco�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		TAFAltStat( "CH9", " " )	
	
	EndIf

	FwFormCommit( oModel )
        

End Transaction
       

Return .T.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf367Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informac�es caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 25/09/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function Taf367Vld(cAlias,nRecno,nOpc,lJob) 

Local aLogErro	:= {}

Default lJob := .F.

If CH9->CH9_STATUS $ ( " |1" )  
	
	//---------------------
	// Campos obrigat�rios
	//---------------------
	If Empty(CH9->CH9_PERIOD)
		Aadd( aLogErro, { "CH9_PERIOD", "000003", "CH9", nRecno } ) //STR0003 - Data inconsistente ou vazia
	EndIf
	
	If Empty(CH9->CH9_ARQRTF)
		Aadd( aLogErro, { "CH9_ARQRTF", "000001", "CH9", nRecno } ) //STR0001 - Campo Inconsistente ou Vazio
	EndIf
	
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿌TUALIZO O STATUS DO REGISTRO�
	//�1 = Registro Invalido        �
	//�0 = Registro Valido          �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If Len(aLogErro)>0
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//쿢tilizo RecLock, pois o SETVALUE somente funciona em campos USADOS�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		RecLock("CH9",.F.)
		CH9->CH9_STATUS := "1"
		MsUnlock()
	Else
		RecLock("CH9",.F.)
		CH9->CH9_STATUS := "0"
		MsUnlock()
	EndIf	  	    
	
Else
	AADD(aLogErro,{"CH9_ID","000017","CH9", nRecno})//STR0017 - Registro j� validado.
	
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿙�o apresento o alert quando utilizo o JOB para validar�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !lJob
	VldECFLog(aLogErro)
EndIf

Return(aLogErro)