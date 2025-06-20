STATIC __PASTAWEB := ""

#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AP5MAIL.CH"  
//#DEFINE __PASTAWEB Iif( Empty( GetPrtSkin() ),'imagens-pls',GetPrtSkin() ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} WCHtml
Classe Form.
 
@author Alexander Santos
@since 14/02/2012
@version P11
/*/
//-------------------------------------------------------------------
CLASS WCHtml

DATA lLibJs	AS STRING
DATA oObj	AS OBJECT HIDDEN
DATA cCustom AS STRING
DATA cFunction AS STRING

METHOD New() Constructor

METHOD setObj()
METHOD getObj()
METHOD getDType()
METHOD loadWC()
METHOD setFunction()
METHOD getFunction()

ENDCLASS
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Class

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD new(lAutoma) CLASS WCHtml
DEFAULT lAutoma := .F.

::lLibJs := .T.
cCustom := ""
::oObj	 := NIL
::cFunction := ""

If lAutoma
	__PASTAWEB := 'imagens-pls'
Else
	__PASTAWEB := Iif( Empty( GetPrtSkin() ),'imagens-pls',GetPrtSkin() ) 
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿑im do Methodo
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Return Self                
//-------------------------------------------------------------------
/*/{Protheus.doc} WCHtml
Seta a objeto no html

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setObj(oObj) CLASS WCHtml
::oObj := oObj
Return            
//-------------------------------------------------------------------
/*/{Protheus.doc} WCHtml
Retorna DOCType do Html

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getDType(lLibJs,lLibUser,cJsLib, cJsCode, cDtJs) CLASS WCHtml
DEFAULT lLibJs 	:= .T.
DEFAULT lLibUser 	:= .F.
DEFAULT cJsLib 	:= ""
DEFAULT cJsCode 	:= ""
DEFAULT cDtJs 	:= ""

Return( WCHtmHead(lLibJs,lLibUser, cJsLib, cJsCode, cDtJs) )
//-------------------------------------------------------------------
/*/{Protheus.doc} WCHtml
Retorna a lista de objetos do html

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getObj() CLASS WCHtml
Return(::oObj)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCHtml
Carrega html e seus obj

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD loadWC() CLASS WCHtml
Return( montWC(Self) )
//-------------------------------------------------------------------
/*/{Protheus.doc} WCHtml
Seta o nome da webfunction que chamou o wchtml para verifica豫o de campos customizados

@author Karine Riquena Limp
@since 31/03/2016
@version P12
/*/
//-------------------------------------------------------------------
METHOD setFunction(cFunction) CLASS WCHtml
DEFAULT cFunction := ""
::cFunction := cFunction
Return 
//-------------------------------------------------------------------
//-------------------------------------------------------------------
/*/{Protheus.doc} WCHtml
Retorna o nome da webfunction que chamou o wchtml para verifica豫o de campos customizados

@author Karine Riquena Limp
@since 31/03/2016
@version P12
/*/
//-------------------------------------------------------------------
METHOD getFunction() CLASS WCHtml
Return(::cFunction)
//-------------------------------------------------------------------

STATIC cCustom := "" //variavel criada para armazenar os campos customizados e criar um hidden para identific�-los na pagina

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽굇
굇쿑uncao    쿺ontWC  	� Autor � Totvs				    � Data � 30/03/10 낢굇
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙굇
굇쿏escricao � Monta formulario											  낢굇
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
/*/
Static Function montWC(oObj)
LOCAL cHTML 		:= ""    
LOCAL nI			:= 1
LOCAL lMenuFolder 	:= .f.
LOCAL aMatH 		:= {}   
LOCAL cFunction := ""
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿛ega os componentes do html
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
cFunction := oObj:getFunction()
oObj := oObj:getObj()

if existblock("PLRDWCHTML")
	oObj := execBlock("PLRDWCHTML",.F.,.F.,{ oObj, cFunction })
endIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿘Onta componentes
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
do case 
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	//쿑ormulario
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	case GetClassName(oObj) == "WCFORM"
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
		//쿞e foi informado nome ao formulario inicia a con
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
		if !empty(oObj:cName)
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
			//쿓tml,Body e Form
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
			cHTML += WCForm("A",;
							oObj:cName,;
							oObj:getAction(),;
							oObj:getMethod(),;
							oObj:getWidth(),;
							oObj:getTitle(),;
							/*oObj:getJsFClick()*/,;
							/*oObj:getJsFImp()*/,;
							/*oObj:getFBack()*/,;
							/*oObj:getNLinBtn()*/,;
							/*oObj:getAlignBtn()*/)
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
			//쿘onta campos hidden
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
			aMatH := oObj:getListFieldHidden()
			
			if len(aMatH)>0             
				for nI:=1 to len(aMatH)
					cHTML += WCFHidden( aMatH[nI,1],aMatH[nI,2] )
				next	
			endIf
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
			//쿞e existe tabela a ser montada
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
			if len(oObj:getListTables()) > 0 
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//쿎riacao das tabelas
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				for nI:=1 to len(oObj:getListTables())
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
					//퀂e vai criar o menu folder
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
					if nI == 1 .and. oObj:getIsFolder()
						lMenuFolder := .t.
					endIf
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
					//쿎ria tabela
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
					cHTML += WCFormTab( "A",;
										oObj:getIsFolder(),;
										nI,;
										lMenuFolder,;
										oObj:getListTables())
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
					//쿎riacao da Linha e seus componentes
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
					if len(oObj:aTables[nI]:aLines) > 0 
						cHTML += montLine(oObj:getListTables()[nI]:getListLine())
					endIf
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
					//퀂e vai criar o menu folder
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
					lMenuFolder := .f.
					if nI == len(oObj:getListTables()) .and. oObj:getIsFolder()
						lMenuFolder := .t.
					endIf
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
					//쿑echamento da tabela
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
					cHTML += WCFormTab( "F",;
										oObj:getIsFolder(),;
										/*nI*/,;
										lMenuFolder,;
										/*oObj:getListTables()*/)
				next
			endIf
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
			//쿑orm,Body e Html
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
			cHTML += WCForm("F",;
							oObj:cName,;
							oObj:getAction(),;
							oObj:getMethod(),;
							oObj:getWidth(),;
							oObj:getTitle(),;
							oObj:getJsFClick(),;
							oObj:getJsFImp(),;
							oObj:getFBack(),;
							oObj:getNLinBtn(),;
							oObj:getAlignBtn(),;
							oObj:getFuncLoad(),;
							oObj:getGlobalVar(),;
							oObj:getObrigat(),;
							nil,; // oObj:getFAgain()
							oObj:getACustomBtn())
		
			//hidden com os campos customizados
			cCustom := substr(cCustom, 1, (len(cCustom)-1))
			cHTML += WCFHidden("custom_fields",cCustom)
		endIf	  
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	//쿛rint
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	case GetClassName(oObj) == "WCPRINT"
		cHTML += WCPrint(oObj:cTitle,oObj:cLabel,oObj:cName,oObj:cFileName,oObj:cFuncJs,oObj:cWidth,oObj:cMsgPlug)
endCase	                                 
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿏estroy da memoria
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
freeObj(oObj)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
return cHTML
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽굇
굇쿑uncao    쿺ontLine  � Autor � Totvs				    � Data � 30/03/10 낢굇
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙굇
굇쿏escricao � Monta Linha												  낢굇
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
/*/
Static Function montLine(oObj)
LOCAL nY 			:= 1
LOCAL nX 			:= 1
LOCAL cHTML 		:= ""
LOCAL cOldGroup	:= ""         
LOCAL cOldTitLeg	:= ""
LOCAL cOldIdLeg  	:= ""
LOCAL cTitle		:= ""
LOCAL lOpenGroup	:= .f.
LOCAL lOpenTitLeg:= .f.
LOCAL cFormatF	:= ''
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿎riacao da Linha
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
For nY:=1 To Len(oObj)        
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	//쿣erifica se o grupo ja foi criado
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	If cOldGroup <> oObj[nY]:GetGroup() 
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
		//쿑echamento do grupo
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
        If lOpenGroup
			cHTML += WCFTabGrou("F",cTitle,cOldGroup)
			lOpenGroup := .F.
        EndIf
		
		If !Empty( oObj[nY]:GetGroup() )
	        cTitle		:= oObj[nY]:GetTitle()
			cOldGroup 	:= oObj[nY]:GetGroup()
			lOpenGroup	:= .T.
			
			cHTML += WCFTabGrou("A",cTitle,cOldGroup)
		EndIf	
	EndIf           
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	//쿗inha e seus componentes
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	cHTML += WCFTabLin("A")									
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	//쿞e tem componente a ser criado
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	If Len(oObj[nY]:getListComp()) > 0 
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
		//쿎ria componente da linha
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
		For nX:=1 To Len(oObj[nY]:getListComp())     
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
			//쿣erifica se e para fechar a linha anterior e criar uma nova
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
			If oObj[nY]:getListComp()[nX]:getNewLine()
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//쿑echa linha anterior
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				cHTML += WCFTabLin("F")									
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//쿌bre linha nova
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				cHTML += WCFTabLin("A", oObj[nY]:getHGroup())									
			EndIf
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
			//쿌grupamento de componente
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
			If (!empty(oObj[nY]:getListComp()[nX]:getIdLegend()) .and. cOldIdLeg <> oObj[nY]:getListComp()[nX]:getIdLegend());
			.OR.(empty(oObj[nY]:getListComp()[nX]:getIdLegend()) .and. cOldTitLeg <> oObj[nY]:getListComp()[nX]:getTitLegend())
			
			    If lOpenTitLeg
					cHTML += WCFLegGrou("F",cFormatF,,,,,oObj[nY]:getHGroup())
					lOpenTitLeg 	:= .f.
					cFormatF		:= ''
			    EndIf
                                       
				If !Empty(oObj[nY]:getListComp()[nX]:getIdLegend()) .OR. !Empty(oObj[nY]:getListComp()[nX]:getTitLegend())
					lOpenTitLeg 	:= .t.
					cOldTitLeg		:= oObj[nY]:getListComp()[nX]:getTitLegend()
					cOldIdLeg     := oObj[nY]:getListComp()[nX]:getIdLegend()
					cFormatF		:= oObj[nY]:getListComp()[nX]:getFormatF()

					cHTML += WCFLegGrou("A",; 
										cFormatF,;
										oObj[nY]:getListComp()[nX]:getTitLegend(),;
										oObj[nY]:getListComp()[nX]:getFSWidth(),;
										oObj[nY]:getListComp()[nX]:getFSPx(),;
										oObj[nY]:getListComp()[nX]:getFSPxLeft(),;
										oObj[nY]:getHGroup(),;
										oObj[nY]:getNomeHGr(),;
										oObj[nY]:getListComp()[nX]:getIdLegend())
				EndIf    
				
			EndIf	
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
			//쿎omponente
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
			Do Case          
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//쿍otao ImG
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				Case oObj[nY]:getListComp()[nX]:cTp == 'BI'
				
					cHTML += WCButImg(oObj[nY]:getListComp()[nX]:cName,;
										oObj[nY]:getListComp()[nX]:getJsFunc(),; 
										oObj[nY]:getListComp()[nX]:getHelpBtn(),;
										oObj[nY]:getListComp()[nX]:getImgBtn(),;
										oObj[nY]:getListComp()[nX]:getDisable(),;
										oObj[nY]:getListComp()[nX]:getIsFieldSet(),;
										oObj[nY]:getListComp()[nX]:getImgWidth(),;
										oObj[nY]:getListComp()[nX]:getImgHeight())
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//쿍otao
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				Case oObj[nY]:getListComp()[nX]:cTp == 'B'
					
					cHTML += WCButton(oObj[nY]:getListComp()[nX]:cName,;
										oObj[nY]:getListComp()[nX]:cTitle,;
										oObj[nY]:getListComp()[nX]:getJsFunc(),;
										oObj[nY]:getListComp()[nX]:getDisable(),;
										oObj[nY]:getListComp()[nX]:getAlign(),;
										oObj[nY]:getListComp()[nX]:getCSS(),;
										oObj[nY]:getListComp()[nX]:getTagTDIE(),;
										oObj[nY]:getListComp()[nX]:getOpenGrp(),;
										oObj[nY]:getListComp()[nX]:getCloseGrp(),;
										oObj[nY]:getListComp()[nX]:getXS(),;
										oObj[nY]:getListComp()[nX]:getSM(),;
										oObj[nY]:getListComp()[nX]:getMD(),;
										oObj[nY]:getListComp()[nX]:getLG(),;
										oObj[nY]:getListComp()[nX]:getInlineB(),;
										oObj[nY]:getListComp()[nX]:getListOpt())
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//쿎ampo
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				Case oObj[nY]:getListComp()[nX]:cTp == 'F'
				
					cHTML += WCField(	oObj[nY]:getListComp()[nX]:cName,;
									 	oObj[nY]:getListComp()[nX]:cTitle,;
									 	oObj[nY]:getListComp()[nX]:cSize,;
									 	oObj[nY]:getListComp()[nX]:getType(),;
									 	oObj[nY]:getListComp()[nX]:getTop(),;
									 	oObj[nY]:getListComp()[nX]:getMLength(),;
									 	oObj[nY]:getListComp()[nX]:getValue(),;
									 	oObj[nY]:getListComp()[nX]:getObrigat(),;
									 	oObj[nY]:getListComp()[nX]:getReadOnly(),;
									 	oObj[nY]:getListComp()[nX]:getDisable(),;
										oObj[nY]:getListComp()[nX]:getJSKeyDown(),;
									 	oObj[nY]:getListComp()[nX]:getJSKeyPre(),;
									 	oObj[nY]:getListComp()[nX]:getJSBlur(),;
									 	oObj[nY]:getListComp()[nX]:getJSFocOut(),;
									 	oObj[nY]:getListComp()[nX]:getJsFF3(),;
										oObj[nY]:getListComp()[nX]:getJSChange(),;
									 	oObj[nY]:getListComp()[nX]:getIsFieldSet(),;
										oObj[nY]:getListComp()[nX]:getCss(),;
										oObj[nY]:getListComp()[nX]:getJsFBtn(),;
										oObj[nY]:getListComp()[nX]:getOpenGrp(),;
										oObj[nY]:getListComp()[nX]:getCloseGrp(),;
										oObj[nY]:getListComp()[nX]:getJSFocus(),;
										oObj[nY]:getListComp()[nX]:getJsFBtL(),;
										oObj[nY]:getListComp()[nX]:getJsHelp(),;
										oObj[nY]:getListComp()[nX]:getToolTip(),;
										oObj[nY]:getListComp()[nX]:lNumber,;
                                   	oObj[nY]:getListComp()[nX]:lData,;
										oObj[nY]:getListComp()[nX]:getXS(),;
									 	oObj[nY]:getListComp()[nX]:getSM(),;
									 	oObj[nY]:getListComp()[nX]:getMD(),;
									 	oObj[nY]:getListComp()[nX]:getLG(),;
									 	oObj[nY]:getListComp()[nX]:getCssDiv(),;
									 	oObj[nY]:getListComp()[nX]:getPlaceHolder(),;
									 	oObj[nY]:getListComp()[nX]:getMinValue(),;
									 	oObj[nY]:getListComp()[nX]:getMaxValue(),;
									 	oObj[nY]:getListComp()[nX]:getCustom(),;
									 	oObj[nY]:getListComp()[nX]:getTagInput())
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//쿎ombo
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				Case oObj[nY]:getListComp()[nX]:cTp == 'C'

					cHTML += WCCombo(	oObj[nY]:getListComp()[nX]:cName,;
										oObj[nY]:getListComp()[nX]:cTitle,;
									 	oObj[nY]:getListComp()[nX]:cSize,;
									 	oObj[nY]:getListComp()[nX]:getTop(),;
										oObj[nY]:getListComp()[nX]:getSession(),;
									 	oObj[nY]:getListComp()[nX]:getObrigat(),;
										oObj[nY]:getListComp()[nX]:getDig(),;    
									 	oObj[nY]:getListComp()[nX]:getDisable(),;
										oObj[nY]:getListComp()[nX]:getJSChange(),;
										oObj[nY]:getListComp()[nX]:getJSKeyDown(),;
										oObj[nY]:getListComp()[nX]:getJSKeyPre(),;
										oObj[nY]:getListComp()[nX]:getJsFBtn(),;
										oObj[nY]:getListComp()[nX]:getHelp(),;
										oObj[nY]:getListComp()[nX]:getIsFieldSet(),;
										oObj[nY]:getListComp()[nX]:getNoIte(),;
										oObj[nY]:getListComp()[nX]:getDefCB(),;
										oObj[nY]:getListComp()[nX]:getIsName(),;
										oObj[nY]:getListComp()[nX]:getArrCombo(),;
										oObj[nY]:getListComp()[nX]:getOpenGrp(),;
										oObj[nY]:getListComp()[nX]:getCloseGrp(),;
										oObj[nY]:getListComp()[nX]:getJsHelp(),;
										oObj[nY]:getListComp()[nX]:getXS(),;
									 	oObj[nY]:getListComp()[nX]:getSM(),;
									 	oObj[nY]:getListComp()[nX]:getMD(),;
									 	oObj[nY]:getListComp()[nX]:getLG(),;
									 	oObj[nY]:getListComp()[nX]:getCboxPes(),;
									 	oObj[nY]:getListComp()[nX]:getCssDiv(),;
									 	oObj[nY]:getListComp()[nX]:getMultiple(),;
									 	oObj[nY]:getListComp()[nX]:getPlaceHolder(),;
									 	oObj[nY]:getListComp()[nX]:getCss(),;
									 	oObj[nY]:getListComp()[nX]:getJSFocus(),;
									 	oObj[nY]:getListComp()[nX]:getJSBlur(),;
										oObj[nY]:getListComp()[nX]:getCustom(),;
										oObj[nY]:getListComp()[nX]:getNaoVrRep())
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//쿍w
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				Case oObj[nY]:getListComp()[nX]:cTp == 'BW'
					cHTML += WCBrwGrid(	oObj[nY]:getListComp()[nX]:cName,;
										oObj[nY]:getListComp()[nX]:cTitle,;
										oObj[nY]:getListComp()[nX]:getBrWidth(),;
										oObj[nY]:getListComp()[nX]:getBrHeight(),;
										oObj[nY]:getListComp()[nX]:getIsFieldSet(),;
										oObj[nY]:getListComp()[nX]:getJsFunc(),;
										oObj[nY]:getListComp()[nX]:getAHeader(),;
										oObj[nY]:getListComp()[nX]:getACols(),;
										oObj[nY]:getListComp()[nX]:getAltGrid(),;
										oObj[nY]:getListComp()[nX]:getDelGrid())
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//쿟extInfo
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				Case oObj[nY]:getListComp()[nX]:cTp == 'T'
					cHTML += WCTextInf(	oObj[nY]:getListComp()[nX]:getText(),;
										oObj[nY]:getListComp()[nX]:getWidthTI(),;
										oObj[nY]:getListComp()[nX]:getCss(),;
										oObj[nY]:getListComp()[nX]:getIsFieldSet())
										
				Case oObj[nY]:getListComp()[nX]:cTp == 'LEG'
					  cHTML += WcLeg( oObj[nY]:getListComp()[nX]:cName,;
					  				    oObj[nY]:getListComp()[nX]:getCss(),;
					  				    oObj[nY]:getListComp()[nX]:cTitle )									
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//쿟extArea
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				Case oObj[nY]:getListComp()[nX]:cTp == 'TA'

					cHTML += WCTextArea(	oObj[nY]:getListComp()[nX]:cName,;
									 	oObj[nY]:getListComp()[nX]:cTitle,;
									 	oObj[nY]:getListComp()[nX]:cSize,;
									 	oObj[nY]:getListComp()[nX]:getColsArea(),;
										oObj[nY]:getListComp()[nX]:getRowsArea(),;									 										 	
									 	oObj[nY]:getListComp()[nX]:getValue(),;
									 	oObj[nY]:getListComp()[nX]:getObrigat(),;
									 	oObj[nY]:getListComp()[nX]:getReadOnly(),;
									 	oObj[nY]:getListComp()[nX]:getDisable(),;									 	
									 	oObj[nY]:getListComp()[nX]:getJSKeyDown(),;
									 	oObj[nY]:getListComp()[nX]:getJSFocOut(),;
									 	oObj[nY]:getListComp()[nX]:getIsFieldSet(),;
										oObj[nY]:getListComp()[nX]:getCss(),;
										oObj[nY]:getListComp()[nX]:getJSBlur(),;
										oObj[nY]:getListComp()[nX]:getXS(),;
									 	oObj[nY]:getListComp()[nX]:getSM(),;
									 	oObj[nY]:getListComp()[nX]:getMD(),;
									 	oObj[nY]:getListComp()[nX]:getLG(),;
									 	oObj[nY]:getListComp()[nX]:getCustom())

				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//쿎odigo HTML
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴										
				Case oObj[nY]:getListComp()[nX]:cTp == 'CHTM'
					cHTML += oObj[nY]:getListComp()[nX]:getValue()				
				
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//쿝adio Button
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴		
				Case oObj[nY]:getListComp()[nX]:cTp == 'RADIO'
					  cHTML += WCRadio( 	oObj[nY]:getListComp()[nX]:cName,;
					  						oObj[nY]:getListComp()[nX]:cTitle,;
					  				    	oObj[nY]:getListComp()[nX]:getArrRadio(),;
					  				    	oObj[nY]:getListComp()[nX]:cType,;
					  				    	oObj[nY]:getListComp()[nX]:getXS(),;
									 		oObj[nY]:getListComp()[nX]:getSM(),;
									 		oObj[nY]:getListComp()[nX]:getMD(),;
									 		oObj[nY]:getListComp()[nX]:getLG(),;
									 		oObj[nY]:getListComp()[nX]:getCss(),;
									 		oObj[nY]:getListComp()[nX]:getCustom())	
			  //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
			  //쿌lert Bootstrap
			  //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴		
			   Case oObj[nY]:getListComp()[nX]:cTp == 'ABS'				
					cHTML += WCAlertBS(oObj[nY]:getListComp()[nX]:cName,;
							  oObj[nY]:getListComp()[nX]:getCss(),;
							  oObj[nY]:getListComp()[nX]:getText(),;
							  oObj[nY]:getListComp()[nX]:getDisplay())
							  
			  //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
			  //쿓elp popover Bootstrap
			  //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴				  
			  Case oObj[nY]:getListComp()[nX]:cTp == 'HPOPOVER'
			  		cHTML += WCPopOver(	oObj[nY]:getListComp()[nX]:cName,;
			  								oObj[nY]:getListComp()[nX]:cTitle,;
			  								oObj[nY]:getListComp()[nX]:getValue(),;
											oObj[nY]:getListComp()[nX]:getDisplay(),;			  											  								
					  				    		oObj[nY]:getListComp()[nX]:getXS(),;
									 		oObj[nY]:getListComp()[nX]:getSM(),;
									 		oObj[nY]:getListComp()[nX]:getMD(),;
									 		oObj[nY]:getListComp()[nX]:getLG())
			  						  			
			EndCase

	    Next
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
		//쿑echamento do agrupamento de componentes da linha
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
		If lOpenTitLeg
			cHTML += WCFLegGrou("F",,,,,,oObj[nY]:getHGroup())
			lOpenTitLeg	:= .f. 
			cFormatF	 	:= ''
		EndIf	
	EndIf
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	//쿑echamento da linha
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	cHTML += WCFTabLin("F")									
Next
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿑echamento do grupo
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
If lOpenGroup
	cHTML += WCFTabGrou("F",cTitle,cOldGroup)
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Return cHTML  
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿥CHtmHead	튍utor  쿌lexander            � Data �  11/02/12   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Abertura de html											   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/                                         
Static Function WCHtmHead(lLibJs, lUserJs,cCsLib,cJsCode, cDtJs)
LOCAL cHTML 	:= ""       
LOCAL cDtJspls := ""
LOCAL cDtJsuser := ""
LOCAL aDtJs := {}
LOCAL nPos := 0
DEFAULT lLibJs 	:= .T.
DEFAULT lUserJs 	:= .F.  
DEFAULT cJsCode	:= ""
DEFAULT cDtJs		:= ""


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿌bertura da tag
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
cHTML += "<!DOCTYPE html>"
cHTML += "<html>"
cHTML += "<head>"
cHTML += "<title>Portal do Plano de Saude</title>"
cHTML += "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
cHTML += "<meta http-equiv='X-UA-Compatible' content='IE=Edge' > "
cHTML += "<meta name='viewport' content='width=device-width, initial-scale=1' >"
cHTML += "<meta name='description' content='' >"
cHTML += "<meta name='author' content='' >"
cHTML += "<link href='" + __PASTAWEB + "/estilo.css' rel='stylesheet' type='text/css'>"
cHTML += "<script type='text/javascript' src='pplanguage.js'></script>"
cHTML += "<script type='text/javascript' src='criaobj.js'></script>"

cHTML += "<link href='" + __PASTAWEB + "/componentes/bootstrap/dist/css/bootstrap.css' rel='stylesheet'>"
cHTML += "<link href='" + __PASTAWEB + "/componentes/bootstrap-tour/bootstrap-tour.css' rel='stylesheet'>"
cHTML += "<link href='" + __PASTAWEB + "/componentes/bootstrap-tagsinput/bootstrap-tagsinput.css' rel='stylesheet'>"
cHTML += "<link href='" + __PASTAWEB + "/componentes/metisMenu/css/metisMenu.css' rel='stylesheet'>"
cHTML += "<link href='" + __PASTAWEB + "/componentes/datatables-plugins/css/dataTables.bootstrap.css' rel='stylesheet'>"
cHTML += "<link href='" + __PASTAWEB + "/componentes/datatables-responsive/css/dataTables.responsive.css' rel='stylesheet'>"
cHTML += "<link href='" + __PASTAWEB + "/componentes/layout-responsivo/css/layout-responsivo.css' rel='stylesheet'>"
cHTML += "<link href='" + __PASTAWEB + "/componentes/font-awesome/css/font-awesome.css' rel='stylesheet' type='text/css'>"
cHTML += "<link href='" + __PASTAWEB + "/componentes/jquery-ui/jquery-ui.css' rel='stylesheet' type='text/css'>"
cHTML += "<link href='" + __PASTAWEB + "/componentes/bootstrap/select2/css/select2.css' rel='stylesheet'>"
cHTML += "<link href='" + __PASTAWEB + "/componentes/spinner/spinner.css' type='text/css'>"
cHTML += "<script src='" + __PASTAWEB + "/componentes/jquery/jquery.js'></script>"
cHTML += "<script src='" + __PASTAWEB + "/componentes/jquery-ui/jquery-ui.js'></script>"
cHTML += "<script src='" + __PASTAWEB + "/componentes/jquery-base64/jquery.base64.js'></script>"

if !empty(cDtJs)
	aDtJs := Separa(cDtJs,'|',.t.)
	nPos := AScan( aDtJs , { |x| "jspls" $ x }  )
	cDtJspls :=  iif(nPos > 0,Separa(aDtJs[nPos],'@',.t.)[2], "" ) 
	nPos := AScan( aDtJs , { |x| "jsuser" $ x }  )
	cDtJsuser := iif(nPos > 0,Separa(aDtJs[nPos],'@',.t.)[2], "" ) 
endif


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿞e usa lib js
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If lUserJs
	cHTML += "<script type='text/javascript' src='" + __PASTAWEB + "/jsuser.js?"+cDtJsuser+"1'></script>"
EndIf

If lLibJs
	cHTML += "<script type='text/javascript' src='" + __PASTAWEB + "/jspls.js?"+cDtJspls+"1'></script>"
EndIf

If !Empty(cCsLib)
	cHTML += "<script type='text/javascript' src='" + __PASTAWEB + "/" + cCsLib + "'></script>"
EndIf
If !Empty(cJsCode)	
	cHTML += cJsCode		
EndIf		

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return cHTML
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿥CForm	튍utor  쿌lexander            � Data �  11/02/12      볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Abre/Fecha Formulario principal					  		     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/                                         
Static Function WCForm(cTp,cName,cAction,cMethod,cWidth,;
							cTitle,cJsFClick,cJsFImp,cFBack,;
							cNLinBtn,cAlign,cFuncLoad,aVar,aObrigat,;
							cJsFAgain, aCustomBtn)
LOCAL cHTML 		:= ""
LOCAL nI			:= 1 
LOCAL aBtnProp	:= {}   
DEFAULT cName		:= ""
DEFAULT cAction		:= ""
DEFAULT cMethod		:= "post"            
DEFAULT cWidth	 	:= ""
DEFAULT cTitle   	:= ""                 
DEFAULT cJsFClick	:= ""
DEFAULT cJsFImp  	:= ""
DEFAULT cFBack	 	:= ""                                        
DEFAULT cNLinBtn 	:= ""  
DEFAULT cAlign		:= ""
DEFAULT cFuncLoad		:= "" 
DEFAULT aObrigat		:= {}
DEFAULT aVar			:= {}
DEFAULT aCustomBtn	:= {}
Default cJsFAgain		:= ""

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿌juste aspas simples para dupla
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
cJsFClick := StrTran(cJsFClick,"'",'"')
cJsFImp   := StrTran(cJsFImp,"'",'"')
cFBack 	  := StrTran(cFBack,"'",'"')
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿘onta form e body
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Do Case
	Case cTp == 'A'
		cHTML += "</head>"
		cHTML += "<body class='space bodyResize'>"
		cHTML += "<form name='" + cName + "' action='" + cAction + "' method='" + cMethod + "'>"

		cHTML += "<div id='ModalPage'>"
		cHTML += "<div class='ModalBackground'></div>"
		cHTML += "<div id='ModalContainer' class='ModalContainer'></div>"
		cHTML += "</div>

		cHTML += "<div class='row'>"
		cHTML +=	"<div class='col-lg-12'>"
		cHTML +=		"<h3 class='page-header'>" + cTitle + "</h3>"
		cHTML +=	"</div>"
       cHTML += "</div>"
	Case cTp == 'F'		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿍otoes no final da tela
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		If !Empty(cJsFClick) .Or. !Empty(cJsFImp) .Or. !Empty(cFBack) .OR. !(Empty(cJsFAgain))
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//쿑az o alinhamento do objeto
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�		   
				cHTML += "<div class='row'>"
					cHTML += "<div class='col-xs-12 col-sm-12' col-md-12 col-lg-12>"
			   
		   if upper(cAlign) == 'LEFT'
				cHTML += "<div class='posicaoLeft'>"
			elseIf upper(cAlign) == 'RIGHT'
				cHTML += "<div class='posicaoRight'>"
	   		endIf 
			
			If !Empty(cJsFClick)
				cHTML += "<button name='bconfirma' id='bconfirma' type='button' class='btn btn-default btn-end-scr' onclick='" + cJsFClick + "return false;'>Confirmar</button>"
			EndIf	        
			
			If !(Empty(cJsFAgain))
				cHTML += "<button name='bconfirmanovo' id='bconfirmanovo' type='button' class='btn btn-default btn-end-scr' onclick='" + cJsFAgain + "location.reload();'>Confirmar e Criar Novo</button>"
			EndIF
			
			If !Empty(cJsFImp)
				cHTML += "<button name='bimprimir' id='bimprimir' type='button' class='btn btn-default btn-end-scr disabled' onclick='" + cJsFImp + "'>imprimir</button>"
				cHTML += "<script>"
				cHTML += "// <![CDATA["
				cHTML += "	setDisable('bimprimir',true);"
				cHTML += "// ]]>"
				cHTML += "</script>"
			EndIf	
			
			If !Empty(aCustomBtn)
				for nI := 1 to len(aCustomBtn)
					aBtnProp := Separa(aCustomBtn[nI], "~")
					cHTML += "<button name='" + aBtnProp[1] + "' id='" + aBtnProp[1] + "' type='button' class='btn btn-default btn-end-scr' onclick='" + aBtnProp[3] + "'>" + aBtnProp[2] + "</button>"
				next nI
			EndIf
			
			If !Empty(cFBack)
				cHTML += "<button name='bVoltar' id='bVoltar' type='button' class='btn btn-default btn-end-scr' onclick='" + cFBack + "'>voltar</button>"
			EndIf	
						
			if upper(cAlign)  == 'LEFT' .OR. upper(cAlign) == 'RIGHT'
				cHTML += "</div>"
			endif
																																		
			cHTML += "</div>"
			cHTML += "</div>"
		EndIf

		cHTML += "</form>"
		
		
		//SCRIPTS NECESS핾IOS PARA O FUNCIONAMENTO DO BOOTSTRAP E DA GRID RESPONSIVA
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/jquery/jquery.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/bootstrap/dist/js/bootstrap.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/bootstrap-tour/bootstrap-tour.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/metisMenu/js/metisMenu.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/dataTables/js/jquery.dataTables.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/dataTables/js/moment.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/dataTables/js/datetime-moment.js'></script>"	
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/datatables-plugins/js/dataTables.bootstrap.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/layout-responsivo/js/layout-responsivo.js'></script>"
	    cHTML += "<script type='text/javascript' src='" + __PASTAWEB + "/componentes/iframeResizer/js/iframeResizer.contentWindow.js'></script>"
	    cHTML += "<script type='text/javascript' src='" + __PASTAWEB + "/schemeColor.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/jquery-ui/jquery-ui.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/jquery-mask/jquery.mask.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/bootstrap/select2/js/select2.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/jquery-maskMoney/jquery.maskMoney.min.js'></script>"		
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/jquery-base64/jquery.base64.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/bootstrap-tagsinput/bootstrap-tagsinput.js'></script>"
		cHTML += "</body>"
		
		cHTML += "<script>"
				
		//script adicionado para telas que n�o s�o chamadas dentro do portal
		cHTML += " $(function() { "
		cHTML += "if (!isObject(parent.window.frames[0])){ "
		cHTML += "document.getElementsByTagName('body')[0].className = 'space'; }"
		cHTML += "}); "
		//********************************************************************//
		
		cHTML += " $(function() { "
		cHTML += "			$( '.datepicker' ).datepicker({ "         
		cHTML += "	    		dateFormat: 'dd/mm/yy', "
		cHTML += "	    		dayNames: ['Domingo','Segunda','Ter�a','Quarta','Quinta','Sexta','S�bado'], "
		cHTML += "	    		dayNamesMin: ['D','S','T','Q','Q','S','S','D'], "
		cHTML += "	    		dayNamesShort: ['Dom','Seg','Ter','Qua','Qui','Sex','S�b','Dom'], "
		cHTML += "	    		monthNames: ['Janeiro','Fevereiro','Mar�o','Abril','Maio','Junho','Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'], "
		cHTML += "	    		monthNamesShort: ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'], "
		cHTML += "	    		nextText: 'Pr�ximo', "
		cHTML += "	    		prevText: 'Anterior' "   
		cHTML += "			});	 "  
		cHTML += " 		$( '.tooltipPad' ).tooltip({ "		
       cHTML += "				content: function () { "
       cHTML += "    			return $(this).data('title').replace('|', '<br />'); "
		cHTML += "	      		} "
		cHTML += " 		}); "
		cHTML += " 		$('.compSelect2').select2({ "
		cHTML += "				language: {"
       cHTML += "					noResults: function(){"
       cHTML += "   					return 'Sem resultados para a busca...';"
       cHTML += "					}"
   		cHTML += "				}"
		cHTML += "			}); "
		
		cHTML += "		$('.dropdown-toggle').dropdown();"
		
		
		cHTML += "}); "	
					
		cHTML += "</script>"
		cHTML += "</html>"
		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
		//쿔nsere a chamada de um JS no load da p�gina
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
		If !Empty(cFuncLoad)
			cHTML += WCFuncLoad(cFuncLoad)
		EndIf
		If !Empty(aObrigat)
			cHTML += WCObrigat(aObrigat)
		else
			cHtml += " <script language='JavaScript'> "  + CRLF
				//Seta os campos obrigat�rios para a valida豫o no bot�o confirmar.
				cHTML += "var oForm = new xform( document.forms[0]) ;"  + CRLF
			cHtml += " </script> "
		EndIf
		If len(aVar) > 0
			cHTML += WCCriarVar(aVar)
		EndIf
EndCase
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return cHTML
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿥CPrint   튍utor  쿌lexander            � Data �  11/02/12   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Frame de impressao										   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
static Function WCPrint(cTitle,cLabel,cName,cFileName,cFuncJs,cWidth,cMsgPlug)
LOCAL cHTML	:= ""              
LOCAL lPDF	:= At( 'PDF',Upper(cFileName) ) > 0
LOCAL nI := 1
LOCAL nLines := 1
LOCAL cMsgAux := ""
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿔mpressao
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If Empty(cFileName)
	cHTML += "</head>"
	cHTML += "<script>"
	
	If !EMPTY(cMsgPlug) 
		cHTML += "alert('" + cMsgPlug + "');"
	Else
		cHTML += "alert('Nenhuma informa豫o foi encontrada para esta Consulta');"
	EndIf 
	
	cHTML += "window.close();"
	cHTML += "</script>"
Else
	cHTML += "</head>"
	cHTML += "<body style='overflow:hidden' leftmargin='0' topmargin='0' marginwidth='0' marginheight='0' class='space'>"
	cHTML += "<div class='conteiner' style='width:100%;'>"
	
	cHTML += "<table width='100%' height='100%' border='0' cellpadding='0' cellspacing='0'>"
	cHTML += "<tr><td height='30' class='TituloCab'>&raquo; " + cTitle + "</td>"
	
	If !lPDF
		cHTML += "<td align='right'><input type='button' name='button' value='" + cLabel + "' class='Botoes' onClick='" + cFuncJS + "'></td></tr>"
		cHTML += "</table>"
		cHTML += "<table style='width:100%>"
	EndIf	
	
	cHTML += "<tr><td align='center' valign='top'>"
	
	cHTML += " <div class='pdf'> "
	
	if !lPDF 
		cHTML += " 	<iframe align='left' id='" + cName + "' frameborder='0' width='100%' height='100%' src='" + __PASTAWEB + "/relatorios/" + cFileName + "'></iframe>"
	else	                    
	   
	    if(!empty(cMsgPlug))
		    nLines := MLCount( cMsgPlug )
	
			For nI := 1 to nLines
				if !(empty(memoLine(cMsgPlug,,nI)))
					cMsgAux += alltrim(strTran(strTran(memoLine(cMsgPlug,,nI), chr(10), ""), chr(13),"")) + " "
				endIf
			next nI 
			
			cMsgPlug := cMsgAux 
		endIf  
		         
		cHTML += " <script> "
		cHTML += " 	if (BrowserId.browser == 'IE' || BrowserId.browser == 'CH') { "
		cHTML += ' 		document.write("'
		cHTML += "  		<span class='TextoEnvEmail'></br>Caso n�o esteja visualizando este relat�rio : </span><a href='"  + __PASTAWEB + "/relatorios/" + lower(cFileName) + "' class='TextoCourierGreen' style='font-size: 15px;font-weight: bold'>Clique aqui.</a> </br> "  
		cHTML += 			iif(empty(cMsgPlug), "", cMsgPlug)
  		cHTML += "    		<embed type='application/pdf' src='" + __PASTAWEB + "/relatorios/" + lower(cFileName) + "' width='100%' height='100%'><noembed></noembed></embed> "
		cHTML += ' 		") '
		cHTML += " } else { "
		cHTML += ' 		document.write( "
		cHTML += " 			<object data='" + __PASTAWEB + "/relatorios/" + lower(cFileName) + "#view=fitH' type='application/pdf' width='100%' height='100%'><span class='TextoEnvEmail'></br>N�o foi poss�vel exibir o relat�rio, por favor, click no link para abrir.: </span><a href='"  + __PASTAWEB + "/relatorios/" + lower(cFileName) + "' class='TextoCourierGreen' style='font-size: 15px;font-weight: bold'>Exibir</a></object> "
		cHTML += ' 		") '
		cHTML += " } "
		cHTML += " </script> "
	endIf
	
	cHTML += " </div> "
	
	cHTML += "</td></tr>"
	cHTML += "</table> "                   
	
	cHTML += "</div>"
	cHTML += "</body>"  
	cHTML += "<script>"
    cHTML += "  parent.focus();"
  	cHTML += "</script>"	
	
	cHTML += "</html>"
EndIf	
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return cHTML
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿥CFormTab	튍utor  쿌lexander            � Data �  11/02/12   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Abre/Fecha Tabela do formulario principal				   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/       
Static Function WCFormTab(cTp,lFolder,nId,lMenuFolder,aMenuFolder)
LOCAL nI			:= 0
LOCAL nJ			:= 0
LOCAL cHTML 	 	:= ""
LOCAL liClass          := "" 
LOCAL divClass   := ""    
DEFAULT lFolder	 	:= .f.
DEFAULT lMenuFolder	:= .f.
DEFAULT nId		 	:= 0
DEFAULT aMenuFolder	:= {}
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿌bre e fecha TAG INICAL DA PAGINA
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Do Case  
	Case cTp == 'A' 		
		if lFolder
			if lMenuFolder
				cHTML += "<ul id='tabs' class='nav nav-tabs'>"
			
				for nI:=1 to len(aMenuFolder)
					liClass := IIf(nI == 1,"class='active'","")
					cHTML += "<li " + liClass + " ><a href='#id"+allTrim(cValToChar(nI))+aMenuFolder[nI]:cName+"' data-toggle='tab'>"+aMenuFolder[nI]:getTitFolder()+"</a></li>"
				next	
				
				cHTML += "</ul>"
				cHTML += "<div class='tab-content'>"	
          endIf
          
          divClass := IIf(nId == 1,"tabFC tab-pane fade in active","tabFC tab-pane fade")
			cHTML += "<div class='" + divClass + "' id='id"+allTrim(cValToChar(nId))+aMenuFolder[nId]:cName+"'>"
		endIf	
		
		cHTML += "<div class='row'>"
		
		//AQUI EU CRIO ABAS DENTRO DA TABLE
			if len(aMenuFolder[nId]:getListTables()) > 0 
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
					//쿎riacao das tabelas
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
					for nI:=1 to len(aMenuFolder[nId]:getListTables())
						//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
						//퀂e vai criar o menu folder
						//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
						if nI == 1 .and. aMenuFolder[nId]:getIsFolder()
							lMenuFolder := .t.
						endIf
						//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
						//쿎ria tabela
						//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
						cHTML += WCFormTab( "A",;
											aMenuFolder[nId]:getIsFolder(),;
											nI,;
											lMenuFolder,;
											aMenuFolder[nId]:getListTables())
						//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
						//쿎riacao da Linha e seus componentes
						//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
						if len(aMenuFolder[nId]:aTables[nI]:aLines) > 0 
							cHTML += montLine(aMenuFolder[nId]:getListTables()[nI]:getListLine())
						endIf
						//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
						//퀂e vai criar o menu folder
						//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
						lMenuFolder := .f.
						if nI == len(aMenuFolder[nId]:getListTables()) .and. aMenuFolder[nId]:getIsFolder()
							lMenuFolder := .t.
						endIf
						//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
						//쿑echamento da tabela
						//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
						cHTML += WCFormTab( "F",;
											aMenuFolder[nId]:getIsFolder(),;
											/*nI*/,;
											lMenuFolder,;
											/*oObj:getListTables()*/)
					next
			endIf			
				
	Case cTp == 'F'                  
	
		cHTML += "</div>"     
		
		if lFolder
			cHTML += "</div>"	
			
			if lMenuFolder
				cHTML += "</div>"
			endIf	
		endIf	
EndCase		
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return cHTML
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿥CFTabLin	튍utor  쿌lexander            � Data �  11/02/12   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Abre/Fecha TR de tabela e linha							   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
static function WCFTabLin(cTp, lProperties)
LOCAL cHTML 			:= ""
Default lProperties	:= .T.
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿌bre e fecha TAG TR de botoes de confirmacao da tela
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
do case  
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿌bre
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	case cTp == 'A' 
		 cHTML += "<div class='col-xs-12 col-sm-12 col-md-12 col-lg-12'>"
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿑echa
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	case cTp == 'F'       
		cHTML += "</div>"         
endCase	
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
return cHTML
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿥CFTabGrou튍utor  쿌lexander            � Data �  11/02/12   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Abre/Fecha TR de grupo campos agrupados					   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Static Function WCFTabGrou(cTp,cTitle,cNameGroup)
LOCAL cHTML 		:= "" 
DEFAULT cTitle		:= ""
DEFAULT cNameGroup 	:= ""                 
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿘onta bloco
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Do Case
	Case cTp == 'A'
		  cHTML += "<div class='panel panel-default'>"
		   cHTML += "<div class='panel-heading' style='cursor:pointer !important;' onclick="
		    	cHTML += "toggleDiv('I" + cNameGroup + "')>"
		      cHTML += "<h4 class='panel-title'>"
		           cHTML += cTitle
		      cHTML += "</h4>"
		    cHTML += "</div>"
		    
		    cHTML += "<div id='I" + cNameGroup + "' class='panel-collapse collapse in'>"
				cHTML += "<div class='panel-body'>"
	Case cTp == 'F'   
		  cHTML += "</div>"
		  cHTML += "</div>"
		  cHTML += "</div>"   
	EndCase
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return cHTML
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿥CFLegGrou튍utor  쿌lexander            � Data �  11/02/12   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Abre/Fecha Grupo formatado								   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Static Function WCFLegGrou(cTp,cFormatF,cTitle,cWidth,cPx,cPxLeft, lMaxMin,cNomeHGroup, cId)
LOCAL cHTML 			:= "" 
LOCAL cTdId			:= ""
LOCAL cHref          := ""
LOCAL cIde           := ""
                       
DEFAULT cFormatF		:= 'H'
DEFAULT cTitle		:= ""
DEFAULT lMaxMin		:= .F.
DEFAULT cNomeHGroup 	:= ""
DEFAULT cId          := ""

If Empty(cNomeHGroup)
	cNomeHGroup := SubStr( StrTran(cTitle," ","")  , 1, 12  )
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿏efine agrupamento com possibilidade de ocultar
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If lMaxMin .AND. cTp == 'A'
	cTdId		:= "'" + cNomeHGroup + "'"
	 cHTML += "<div class='panel panel-default'>"
		    cHTML += "<div class='panel-heading' style='cursor:pointer !important;' onclick="
		    	cHTML += "toggleDiv(" + cTdId + ")>"
		      cHTML += "<h4 class='panel-title'>"
		           cHTML += cTitle
		      cHTML += "</h4>"
		    cHTML += "</div>"
		    
		    cHTML += "<div id=" + cNomeHGroup + ">"
				cHTML += "<div class='panel-body'>"
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿏efine agrupamento
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Do Case 
	Case cTp == 'A'
			cHTML	+= "<fieldset" + iif(!Empty(cId), " id='" + cId + "'", "") + ">"
			cHTML	+= iif(!Empty(cTitle),"<legend" + iif(!Empty(cId), " id='" + cId+"Legend" + "'", "") + ">" + cTitle + "</legend>" , "")
	Case cTp == 'F'
		cHTML	+= "</fieldset>"
		If lMaxMin
			 cHTML	+= "</div>"
    		 cHTML	+= "</div>"
    		 cHTML	+= "</div>"
		EndIf
EndCase		
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return cHTML
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿥CCombo	튍utor  쿌lexander            � Data �  11/02/12   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Cria combobox											   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/       
Static Function WCCombo(cName,cTitle,cSize,lTop,xSession,lOb,lDig,lDisabled,cJSChange,;
							cJSKeyDown,cJSKeyPre,cJsFBtn,cHelp,lGrupFS,lNoIte,cDefault,lName,;
							aVetOpcoes,lOpenGrp,lCloseGrp,cJsHelp,cXS,cSM,cMD,cLG,lPesquisa,cCssDiv,;
							lMultiple,cPlaceHolder,cCss,cJSFocus,cJSBlur, lCustom, lNaoVrRep)
LOCAL nI		 	:= 0
LOCAL cHTML		 	:= ""
LOCAL cIndObri       := ""
LOCAL cRequired      := ""
LOCAL cClassOBOP     := ""
LOCAL cClassPesq     := ""
LOCAL cMultiple      := ""
LOCAL xObjSes 	 	:= ""
LOCAL lPreTiss		:= .F.
LOCAL lAttr
DEFAULT xSession	:= ""
DEFAULT cJSChange 	:= ""
DEFAULT cJSKeyDown 	:= ""
DEFAULT cJSKeyPre	:= ""
DEFAULT cJsFBtn	 	:= ""
DEFAULT cHelp	 	:= ""
DEFAULT lTop		:= .f.
DEFAULT cDefault	:= ""
DEFAULT cJsHelp		:= ""
DEFAULT lOb		 	:= .f.                                                              
DEFAULT lDig	 	:= .f.
DEFAULT lDisabled	:= .f.
DEFAULT lGrupFS		:= .f.          
DEFAULT lNoIte		:= .f.
DEFAULT lName		:= .f.
DEFAULT lPesquisa := .F.
DEFAULT lMultiple := .F.
DEFAULT aVetOpcoes := {}
DEFAULT lOpenGrp		:= .F.
DEFAULT lCloseGrp := .F.
DEFAULT cXS    		:= "12"
DEFAULT cSM    		:= "6"
DEFAULT cMD    		:= "6"
DEFAULT cLG    		:= "4"
DEFAULT cCssDiv      := ""
DEFAULT cPlaceHolder      := ""
DEFAULT cCss         := ""
DEFAULT cJSFocus		:= ""
DEFAULT cJSBlur		:= ""
DEFAULT lCustom      := .F.
DEFAULT lNaoVrRep      := .F.

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿓ttpPost atribuido ao cDefault
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
cCustom += iif(lCustom,"combo~"+cName+"|","")
lAttr := ((!Empty(cJsFBtn)).OR.(!Empty(cJsHelp)))
If  ValType( &('HttpPost->' + cName) ) != 'U' 
	cDefault := &('HttpPost->' + cName)
EndIf	

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿘onta variavel de sessao se informada ou utiliza o array de op寤es
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !Empty(aVetOpcoes)
	xObjSes := aVetOpcoes
ElseIf !Empty(xSession)
	xObjSes := &(xSession)
EndIf	

//Verifica se o combo do prestador ir� concatenar os dados "Prestador, Local de Atendimento e Regime de Atendimento" (TISS)
lPreTiss :=  Type("lPrestTiss") <> "U" .And. xSession == "HttpSession->RDAVIEW"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿞e obrigatorio ou opcional
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If lOb
	cIndObri   := "<span style='color:red'>*</span>"
	cRequired  := " required"
	cClassOBOP := " TextoInputOB"
Else
	cIndObri   := ""
	cRequired  := ""
	cClassOBOP := " TextoInputOP"
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿞e � combo pesquisa
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
cClassPesq := IIF(lPesquisa .OR. lMultiple, " compSelect2", " ")
cMultiple := IIF(lMultiple, " multiple='multiple'", " ")
cPlaceHolder := IIF(!Empty(cPlaceHolder), iif(lPesquisa .OR. lMultiple, "data-placeholder", "placeholder")+"='" + cPlaceHolder + "' ", " ")
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿌justa funcao
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
cJsFBtn 		:= StrTran(cJsFBtn		,"'",'"')
cJSChange 		:= StrTran(cJSChange	,"'",'"')
cJSKeyDown  	:= StrTran(cJSKeyDown	,"'",'"')
cJSKeyPre   	:= StrTran(cJSKeyPre	,"'",'"')
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿏efinicao do obj
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
cXS := "col-xs-" + cXS + " " 
cSM := "col-sm-" + cSM + " "
cMD := "col-md-" + cMD + " "
cLG := "col-lg-" + cLG + " "

cHTML += "<div class='" + cXS + cSM + cMD + cLG + cCssDiv + "'>"	
cHTML += "<div class='form-group'>"
cHTML += "<label>" + cTitle + cIndObri + "</label>"

if lAttr
	cHTML += "<div class='input-group'>"
endif

cHTML += "	<select name='" + cName + "' id='" + cName + "' "

IF lDisabled
	cHTML += " disabled "
EndIf
If !Empty(cJSChange)
	cHTML +=  "onchange='" + cJSChange + "' "
EndIf
 
If !Empty(cJSKeyDown)
	cHTML +=  "onkeydown='" + cJSKeyDown + "' "
EndIf	

If !Empty(cJSKeyPre)
	cHTML +=  "onkeypress='" + cJSKeyPre + "' "
EndIf              

If !Empty(cJSFocus)
	cHTML += "onfocus='" + cJSFocus + "' "
EndIf

If !Empty(cJSBlur)
	cHTML += "onblur='" + cJSBlur + "' "
EndIf

cHTML += "class='form-control " + cClassOBOP + cClassPesq + " "  + cCss + "' " + cMultiple + cPlaceholder + iif(lDisabled, " disabled", "") + " >"

if lDisabled
	cHTML += "<script>"
	cHTML += "// <![CDATA["
	cHTML += "	setDisable('" + cName + "',true);"
	cHTML += "// ]]>"
	cHTML += "</script>"
endIf
	
If ValType(xObjSes) <> "U" .AND. !Empty(xObjSes)
	If ValType(xObjSes[1]) == "O" .And. !Empty(xSession) .And. !lPreTiss // Veio uma session
		If lDisabled .And. !lNoIte
			For nI := 1 To Len( xObjSes )
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				//쿙ao inclui registro duplicado
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				if at(allTrim(iIf(lName,xObjSes[nI]:cName,xObjSes[nI]:cDescription)),cHTML) == 0
					cHTML += "<option value='" + xObjSes[nI]:cCode + "' " + Iif( &('HttpPost->' + cName)  ==  xObjSes[nI]:cCode, "SELECTED", "" ) + "> " + iIf(lName,xObjSes[nI]:cName,xObjSes[nI]:cDescription) + " </option>"
				endIf	
			Next nI
			
		ElseIf Len( xObjSes ) >= 1
			cHTML += iif(lMultiple, "", "<option value=''>-- Selecione um Item --</option>")
					
			For nI := 1 To Len( xObjSes )
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				//쿙ao inclui registro duplicado
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				if at(allTrim(iIf(lName,xObjSes[nI]:cName,xObjSes[nI]:cDescription)),cHTML) == 0 .or. lNaoVrRep

					cHTML += "<option value='" + xObjSes[nI]:cCode + "' " + Iif( cDefault  ==  xObjSes[nI]:cCode, "SELECTED", "") + "> " + iIf(lName,xObjSes[nI]:cName,xObjSes[nI]:cDescription) + " </option>"
				endIf	
			Next nI
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿜uando esta habilitado a digitacao e pesquisa no combo.
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		ElseIf Empty( xObjSes ) .And. lDig
			cHTML += iif(lMultiple, "", "<option value=''>-- Selecione um Item --</option>")
			
		ElseIf Len( xObjSes ) > 0
			cHTML += "<option value='" + xObjSes[1]:cCode + "' SELECTED> " + iIf(lName,xObjSes[1]:cName,xObjSes[1]:cDescription) + "</option>"
			If !Empty(cJSChange)
				cHTML += "<script>"
				cHTML += "// <![CDATA["
				cHTML += cJSChange
				cHTML += "// ]]>"
				cHTML += "</script>"
			EndIf	
		EndIf
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//쿎riada opcao de envio de array para tratamento nas novas guias TISS
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	ElseIf ValType(xObjSes) == "A" // Veio um array de opcoes
		If !lPreTiss	
			If lDisabled .And. !lNoIte .and. empty(cDefault)
				For nI := 1 To Len( xObjSes )
					cGetCode := Alltrim(SubStr(xObjSes[nI], 1, At("=",xObjSes[nI])-1))
					cGetName := Alltrim(SubStr(xObjSes[nI], At("=",xObjSes[nI])+1, Len(xObjSes[nI]) ))
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					//쿙ao inclui registro duplicado
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					if At("value='"+cGetCode+"'",cHTML) == 0 .AND. At("> " + cGetName + " <",cHTML)== 0
						cHTML += "<option value='" + cGetCode + "' SELECTED> " + cGetName + " </option>"
					endIf	
				Next nI
				
			ElseIf Len( xObjSes ) > 1 .and. !Empty(cDefault)
				cHTML += iif(lMultiple,"","<option value=''>-- Selecione um Item --</option>")
							
				For nI := 1 To Len( xObjSes )
					cGetCode := Alltrim(SubStr(xObjSes[nI], 1, At("=",xObjSes[nI])-1))
					If Alltrim(cGetCode) == cDefault
						cHTML += "<option value='" + Alltrim(SubStr(xObjSes[nI], 1, At("=",xObjSes[nI])-1)) + "' SELECTED	> " + Alltrim(SubStr(xObjSes[nI], At("=",xObjSes[nI])+1, Len(xObjSes[nI]) )) + "</option>"
					Else		
						cHTML += "<option value='" + Alltrim(SubStr(xObjSes[nI], 1, At("=",xObjSes[nI])-1)) + "'> " + Alltrim(SubStr(xObjSes[nI], At("=",xObjSes[nI])+1, Len(xObjSes[nI]) )) + "</option>"									
					EndIf	
				Next nI
				
			ElseIf Len( xObjSes ) > 1 .and. Empty(cDefault)
				cHTML += iif(lMultiple,"", "<option value='SELECTED'>-- Selecione um Item --</option>")				
				
				For nI := 1 To Len( xObjSes )
					cGetCode := Alltrim(SubStr(xObjSes[nI], 1, At("=",xObjSes[nI])-1))
					cGetName := Alltrim(SubStr(xObjSes[nI], At("=",xObjSes[nI])+1, Len(xObjSes[nI]) ))
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					//쿙ao inclui registro duplicado
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					if At("value='"+cGetCode+"'",cHTML) == 0 .AND. At("> " + cGetName + " <",cHTML)== 0
						cHTML += "<option value='" + cGetCode + "'" + Iif( cDefault  ==  cGetCode, "SELECTED", "") + "> " + cGetName + " </option>"					
					endIf	
				Next nI					
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//쿜uando esta habilitado a digitacao e pesquisa no combo.
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		ElseIf Empty( xObjSes ) .And. lDig
			cHTML += iif(lMultiple, "", "<option value=''>-- Selecione um Item --</option>")
			
			ElseIf Len( xObjSes ) > 0
				cGetCode := Alltrim(SubStr(xObjSes[1], 1, At("=",xObjSes[1])-1))
				cGetName := Alltrim(SubStr(xObjSes[1], At("=",xObjSes[1])+1, Len(xObjSes[1]) ))
				
				cHTML += "<option value='" + cGetCode + "' SELECTED	> " + cGetName + "</option>"
				If !Empty(cJSChange)
					cHTML += "<script>"
					cHTML += "// <![CDATA["
					cHTML += cJSChange
					cHTML += "// ]]>"
					cHTML += "</script>"
				EndIf	
			EndIf	
		Else
			//Padr�o de item no combo prestador: "PRESTADOR, LOCAL DE ATENDIMENTO e REGIME DE ATENDIMENTO"
			If lDisabled .And. !lNoIte
				For nI := 1 To Len( xObjSes )
					cCode 		:= Alltrim(xObjSes[nI]:cCode)
					cCodLoc 	:= AllTrim(xObjSes[nI]:cCodLoc)
					cPrest		:= Alltrim(xObjSes[nI]:cName) + " - " + Alltrim(xObjSes[nI]:cDesLoc) + " - " + Alltrim(xObjSes[nI]:cRegAtend)
					//Verifica duplicidade
					if At("value='"+cCode+"|"+cCodLoc+"'",cHTML) == 0
						cHTML += "<option value='"+cCode+"|"+cCodLoc+"' SELECTED> " + cPrest + " </option>"
					endIf	
				Next nI				
			ElseIf Len( xObjSes ) >= 1
				cHTML += iif(lMultiple,"","<option value=''>-- Selecione um Item --</option>")
				For nI := 1 To Len( xObjSes )
					cCode 		:= Alltrim(xObjSes[nI]:cCode)
					cCodLoc 	:= AllTrim(xObjSes[nI]:cCodLoc)
					cPrest		:= Alltrim(xObjSes[nI]:cName) + " - " + Alltrim(xObjSes[nI]:cDesLoc) + " - " + Alltrim(xObjSes[nI]:cRegAtend)
					//Verifica duplicidade
					if At("value='"+cCode+"|"+cCodLoc+"'",cHTML) == 0
						cHTML += "<option value='"+cCode+"|"+cCodLoc+"'" + Iif( cDefault  ==  cCode, "SELECTED", "") + "> " + cPrest + " </option>"					
					endIf
				Next nI			
			EndIf	
		EndIf		
	EndIF         
Else
	cHTML += iif(lMultiple,"", "<option value=''>-- Selecione um Item --</option>")
EndIf
	
cHTML += "</select>"

if lAttr
	cHTML += "<span class='input-group-btn'>"
endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿎ria bot�o de plus
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !Empty(cJsFBtn)
	cHTML += "<button type ='button' name='B" + cName + "' id='B" + cName + "' class='btn btn-default' onclick='" + cJsFBtn + "'><i class='fa fa-plus'></i></button>"
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿎ria bot�o de help que chama pop
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !Empty(cHelp)	
		cHTML += "<button type ='button' name='" + cHelp + "' id='" + cHelp + "' class='btn btn-default' title='Ajuda' onclick='fAbre(" + '"W_PPLSHELP.APW"' + ")'><i class='fa fa-question-circle'></i></button>"
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿎ria bot�o de help
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !Empty(cJsHelp)
	cHTML += "<button type ='button' name='B" + cName + "' id='B" + cName + "' class='btn btn-default' onclick='" + strtran(cJsHelp,"'",'"') + "'><i class='fa fa-question-circle'></i></button>"
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑echa o input-group
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
if lAttr
	cHTML += "</span>"
	cHTML += "</div>"
endif

cHTML += "</div>"
cHTML += "</div>"     
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return cHTML                                          
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿥CField	튍utor  쿌lexander            � Data �  11/02/12   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Cria campo												   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Static Function WCField(cName,cTitle,cSize,cTp,lTop,cMLength,cValue,lOb,lRO,lDi,;
							cJSKeyDown,cJSKeyPre,cJSBlur,cJSFocOut,cJsFF3,cJSChange,;
							lGrupFS,cCss,cJsFBtn,lOpenGrp,lCloseGrp, cJSFocus,cJsFBtL,;
							cJsHelp,cToolTip ,lNumber,lData, cXS,cSM,cMD,cLG, cCssDiv,;
							cPlaceHolder, nMinValue, nMaxValue, lCustom, lTagInput)
							
LOCAL cHTML			:= ""
LOCAL cReadOnly		:= ""
LOCAL cIndObri       := ""
LOCAL cRequired      := ""
LOCAL cClassOBOP     := ""
LOCAL cClassData     := ""
LOCAL cClassHint     := ""
LOCAL lAttr          := .F.
LOCAL cMinValue      := ""
LOCAL cMaxValue      := ""
DEFAULT cTitle 		:= "&nbsp;"
DEFAULT cSize    		:= ""
DEFAULT cXS    		:= "12"
DEFAULT cSM    		:= "6"
DEFAULT cMD    		:= "6"
DEFAULT cLG    		:= "4"
DEFAULT cTp			:= "text"
DEFAULT cValue		:= ""
DEFAULT cMLength  	:= "0"
DEFAULT lRO   		:= .F.
DEFAULT lDi			:= .F.                                
DEFAULT lOb			:= .F.                                                 
DEFAULT cJSKeyPre		:= ""   
DEFAULT cJSKeyDown	:= ""
DEFAULT cJSBlur		:= ""             
DEFAULT cJSFocOut		:= ""       
DEFAULT cJSChange		:= ""
DEFAULT cJsFF3		:= ""
DEFAULT cJsFBtL		:= ""
DEFAULT cJsHelp		:= ""
DEFAULT lGrupFS		:= .F.     
DEFAULT lTop			:= .f.
DEFAULT cJsFBtn		:= ""
DEFAULT lOpenGrp		:= .F.
DEFAULT lCloseGrp		:= .F.
DEFAULT cToolTip		:= ''
DEFAULT lNumber		:= SubStr(cName,1,1) == "n"	
DEFAULT lData  		:=  .F.
DEFAULT cCssDiv      := ""	
DEFAULT cPlaceHolder := ""
DEFAULT cCss			:= ""
DEFAULT lCustom      := .F.
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿝eadOnly, Disabled, Css, FocusOut e JsFunc
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
cCustom += iif(lCustom,"text~"+cName+"|","")
cReadOnly 	:= Iif(lRO,"READONLY","")
cClassData := Iif(lData," datepicker","")
cClassHint := Iif(!Empty(cToolTip), " tooltipPad", "")
cPlaceHolder := IIF(!Empty(cPlaceHolder), " placeholder='" + cPlaceHolder + "' ", " ")
If lOb
	cIndObri   := "<span style='color:red'>*</span>"
	cRequired  := " required"
	cClassOBOP := " TextoInputOB"
Else
	cIndObri   := ""
	cRequired  := ""
	cClassOBOP := " TextoInputOP"
EndIf
cJSKeyPre	:= StrTran(cJSKeyPre,"'",'"')
cJSKeyDown	:= StrTran(cJSKeyDown,"'",'"')
cJSBlur		:= StrTran(cJSBlur,"'",'"')
cJSFocOut	:= StrTran(cJSFocOut,"'",'"')
cJSFF3		:= StrTran(cJsFF3,"'",'"')
cJSChange	:= StrTran(cJSChange,"'",'"')
cJsFBtn 		:= StrTran(cJsFBtn		,"'",'"')
lAttr      := ((!Empty(cJsFF3)).OR.(!Empty(cJsFBtn)).OR.(!Empty(cJsFBtl)).OR.(!Empty(cJsHelp)))

cXS := "col-xs-" + cXS + " " 
cSM := "col-sm-" + cSM + " "
cMD := "col-md-" + cMD + " "
cLG := "col-lg-" + cLG + " "


cHTML += "<div class='" + cXS + cSM + cMD + cLG + " " + cCssDiv + "'>"	
cHTML += "<div class='form-group'>"

//If cName <> "cProExe"
	cHTML += Iif(cName == "cProExe" ,"", "<label>" + cTitle + cIndObri + "</label>")
//EndIf

if lAttr .OR. lNumber
	cHTML += "<div class='input-group'>"
endif

If lNumber
	cHTML += "<span class='input-group-btn'>"
	If nMinValue+nMaxValue <> 0 
		cMinValue += "controlNumberVal(this," + ALLTRIM(STR(nMinValue)) + ", " + ALLTRIM(STR(nMaxValue)) + ")"
	Else
		cMinValue += "controlNumberVal(this, 0, 0)"
	EndIf
	cHTML += 	"<button type ='button' name='sub" + cName + "' onclick='" + cMinValue + "' class='btn btn-default'><i class='fa fa-minus'></i></button>"
	cHTML += "</span>"
EndIf

//Adiciona as m�scaras nos campos BA1_CPFUSR, BA1_CEPUSR, BA1_TELEFO no portal. 
Do Case

	Case cName == "cBA1_CPFUSR" .Or. cName == "cBA1_CEPUSR" 
		cValue := Trans(cValue, PesqPict("BA1", SubStr(cName,2,len(cName)))) 

	Case cName == "cBA1_TELEFO"  
		cValue := Transform(cValue, "@E 9999-99999")

EndCase

cHTML += "<input name='" + cName + "' id='" + cName + "' type='" + Iif(cName == "cProExe", "Hidden", cTp) + "' class='form-control " + cClassOBOP + cClassData + cClassHint + " " + cCss+ "'" + cPlaceHolder + " value='" + cValue + "' size='" + cSize + "' maxlength='" + cMLength +"' " + cReadOnly + cRequired + iif(lDi, " " + cReadOnly, "") + iif(lTagInput, " data-role='tagsinput'", "")
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿖eyPress
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !Empty(cJSKeyPre)     
	cHTML	+= " onKeyPress='" + cJSKeyPre + "'" 
EndIf	                         
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿖eyDown
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !Empty(cJSKeyDown)
	cHTML +=  "onkeydown='" + cJSKeyDown + "' "
EndIf	
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿍lur
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !Empty(cJSBlur) 
	cHTML	+= " onblur='" + cJSBlur + "'"
EndIf	
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿎hange
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !Empty(cJSChange)
	cHTML	+= " onchange='" + cJSChange + "'"
EndIf          
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑ocus
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !Empty(cJSFocus)
	cHTML	+= " onfocus='" + cJSFocus + "'"
EndIf 

//quando tem a lupa e a funcao de validacao eh a fChKBTQ, eu faco tooltip. (essa funcao eh responsavel por mexer no atributo da descricao	                                          
If !Empty(cJsFF3) .and. cToolTip == '1'
	cHTML +=  " placeholder='Selecione uma op豫o' "
ElseIf Empty(cJsFF3) .and. cToolTip <> '1' .and. !Empty(cToolTip) 
	cHTML +=  " title=' " + cTooltip + " ' " 
ElseIf !Empty(cTooltip)
	cHTML +=  " title=' " + cTooltip + " ' " 
Endif    

cHTML += "/>"
//BOTAO MAIS

If lNumber
	cHTML += "<span class='input-group-btn'>"
	If nMinValue+nMaxValue <> 0 
		cMaxValue += "controlNumberVal(this, " + ALLTRIM(STR(nMinValue)) + ", " + ALLTRIM(STR(nMaxValue)) + ")"
	Else
		cMaxValue += "controlNumberVal(this, 0, 0)"
	EndIf
	cHTML += 	"<button type ='button' name='add" + cName + "' onclick='"+ cMaxValue +"' class='btn btn-default'><i class='fa fa-plus'></i></button>"
EndIf

if lAttr .AND. !lNumber //se for lnumber, j� abri o grupo span acima no BOT홒 MAIS
	cHTML += "<span class='input-group-btn'>"
endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿏isable
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
if lDi
	cHTML += "<script>"
	cHTML += "// <![CDATA["
	cHTML += "	setDisable('"+cName+"',true);"
	cHTML += "// ]]>"
	cHTML += "</script>"
endIf	
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿎ria botao de F3
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !Empty(cJsFF3)
	cHTML += "<button type ='button' name='B" + cName + "' id='B" + cName + "' class='btn btn-default' onclick='if(!this.disabled)" + cJsFF3 + "'><i class='fa fa-search'></i></button>"
EndIf	

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿎ria bot�o de plus
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !Empty(cJsFBtn)
	cHTML += "<button type ='button' name='B" + cName + "' id='Ba" + cName + "' class='btn btn-default' onclick='" + cJsFBtn + "'><i class='fa fa-plus'></i></button>"
EndIf
  
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿎ria botao de refresh
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !Empty(cJsFBtL)
	cHTML += "<button  type ='button' name='B" + cName + "' id='Br" + cName + "' class='btn btn-default' onclick='" + cJsFBtL + "'><i class='fa fa-refresh'></i></button>"
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿎ria bot�o de help
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !Empty(cJsHelp)
	cHTML += "<button type ='button' name='B" + cName + "' id='B" + cName + "' class='btn btn-default' onclick='" + cJsHelp + "'><i class='fa fa-question-circle'></i></button>"
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑echa o input-group
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
if lAttr .OR. lNumber
	cHTML += "</span>"
	cHTML += "</div>"
endif
cHTML += "</div>"
cHTML += "</div>"
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return cHTML
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿥CButton	튍utor  쿌lexander            � Data �  11/02/12   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Cria botao												   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Static Function WCButton(cName,cTitle,cJsFunc,lDi,cAlign,cCssClass, lTdIE,lOpenGrp,lCloseGrp,cXS,cSM,cMD,cLG,lInline,aListOpt)
LOCAL cHTML		:= ""
LOCAL cNameD		:= ""
Local nCont	:= 0
DEFAULT lDi	    := .F.                     
DEFAULT cAlign		:= ""
DEFAULT cCssClass		:= ""
DEFAULT lTdIE			:= .T.
DEFAULT lOpenGrp			:= .F.
DEFAULT lCloseGrp			:= .F.
DEFAULT cXS    		:= "12"
DEFAULT cSM    		:= "12"
DEFAULT cMD    		:= "12"
DEFAULT cLG    		:= "12"
DEFAULT lInline       	:= .F.
DEFAULT aListOpt       := {}
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿛ara controle o disabled deve ter um asterisco no nome
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
if lDi
	cNameD 	:= "*"                
else
	cNameD 	:= cName
endIf

cXS := "col-xs-" + cXS + " " 
cSM := "col-sm-" + cSM + " "
cMD := "col-md-" + cMD + " "
cLG := "col-lg-" + cLG + " "


If lOpenGrp
	cHTML += "<div class='" + cXS + cSM + cMD + cLG + iif(lInline, "buttons-inline'", "'") + ">"	
	cHTML += iif(lInline, "<div class='buttons-inline-2'>", '')	
EndIf
	                                         
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿌justes nos parametros enviados para jsFunc
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
cJsFunc := strTran(cJsFunc,"'",'"')
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿌linhamento do componente
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
if upper(cAlign) == 'LEFT'
	cHTML += "<div class='posicaoLeft'>"
elseIf upper(cAlign) == 'RIGHT'
	cHTML += "<div class='posicaoRight'>"
endIf    

If Len(aListOpt) > 0
	cHtml += "<div class='btn-group'>"
	cHTML += "<button name='" + cNameD + "' id='" + cName + "' class='btn btn-default dropdown-toggle " + cCssClass + "' type='button' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'>" + cTitle + "</button>"
    
	cHTML += "<ul class='dropdown-menu' role='menu'>"
	For nCont := 1 To Len(aListOpt)
		cHTML += "  <li role='presentation'><a class='dropdown-item' href=javascript:" + aListOpt[nCont,2] + ">" + aListOpt[nCont,1] + "</a></li>"   
	Next nCont
	cHTML += " </ul>"
	
	cHtml += "</div>"
Else
	cHtml += "<button name='" + cNameD + "' id='" + cName + "' type='button' class='btn btn-default " + cCssClass + "' onclick='" + cJsFunc + "' style='margin-right:10px;' >" + cTitle + "</button>"
EndIf

if !(empty(cAlign))
	cHTML += "</div>"
endIf

if lDi
	cHTML += "<script>"
	cHTML += "// <![CDATA["
	cHTML += "	setDisable('"+cName+"',true);"
	cHTML += "// ]]>"
	cHTML += "</script>"
endIf

If lCloseGrp
	cHTML += iif(lInline, "</div>", '')	
	cHTML += "</div>"
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return cHTML                  
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿥CButImg	튍utor  쿌lexander            � Data �  11/02/12   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Cria botao com img										   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Static Function WCButImg(cName,cJsFunc,cHelp,cImg,lDi,lGrupFS, cWidth, cHeight)
LOCAL cHTML		:= ""
DEFAULT cImg 		:= "/chk.gif"
DEFAULT cHelp 		:= "Pesquisa"
DEFAULT lDi	    := .F.                     
DEFAULT lGrupFS 	:= .F.
DEFAULT cWidth	:= "18"
DEFAULT cHeight	:= "18"
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿌justes nos parametros enviados para jsFunc
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
cJsFunc := StrTran(cJsFunc,"'",'"')
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿎ria campo
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !lGrupFS
	cHTML += "<td><img src='" + __PASTAWEB + cImg +"' id='" + cName + "' name='" + cName + "'  title='" + cHelp + "' width='" + cWidth + "' height='" + cHeight + "' border='0' align='top' class='img' onClick='" + cJsFunc + "' /></td>"
Else
	cHTML += "<img src='" + __PASTAWEB + cImg +"' id='" + cName + "' name='" + cName + "'  title='" + cHelp + "' width='" + cWidth + "' height='" + cHeight + "' border='0' class='img' onClick='" + cJsFunc + "' />"
EndIf	    
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿏isabled
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
if lDi
	cHTML += "<script>"
	cHTML += "// <![CDATA["
	cHTML += "	setDisable('"+cName+"',true);"
	cHTML += "// ]]>"
	cHTML += "</script>"
endIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return cHTML
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿥CTextInf	튍utor  쿌lexander            � Data �  11/02/12   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Texto informtivo											   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Static Function WCTextInf(cText,cWidth,cCss,lGrupFS)
LOCAL cHTML	:= ""
LOCAL cCssFS	:= "box"
LOCAL cCssDiv	:= cCss
LOCAL aCSS		:= {}

If "|" $ cCss // pode ser passado com pipe para determinar o CSS da FieldSet junto
	aCSS := StrToArray(cCss, "|")
	cCssFS := aCSS[1]
	cCssDiv := aCSS[2]
EndIf

cHTML += "<fieldset class='" + cCssFS + "' style='width: " + cWidth + "px;'>"
cHTML += "<div class= '" + cCssDiv + "' style='display: inline-block;white-space: normal;border:none;' >" + cText + "</div>"
cHTML += "</fieldset>"
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return cHTML
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽굇
굇쿑uncao    쿥CBrwGrid � Autor � Totvs					� Data � 05/02/12 낢굇
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙굇
굇쿏escricao � Grid de dados - trabalha em conjunto com a gridData (JS)	  낢굇
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Static Function WCBrwGrid(cName,cTitulo,cWidth,cHeight,lGrupFS,cJsFunc, aHeader, aCols, lAltGrid, lDelGrid)
LOCAL cHTML			:= ""
LOCAL nI := 0
LOCAL nJ := 0
DEFAULT lGrupFS 	:= .F.
DEFAULT aHeader  := {}
DEFAULT aCols  := {}
DEFAULT lAltGrid := .T.
DEFAULT lDelGrid := .T.
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿎onteiner para o Brw
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
cName := alltrim(cName)
cHTML += "<div class='row'>"
cHTML += "<div class='col-xs-12 col-sm-12 col-md-12 col-lg-12' style='overflow-x:auto; width:98%; /*margin-left:20px;*/'>"            
cHTML += "<div id='"+ cName +"' class='dataTable_wrapper'>"

	If  len(aHeader) > 0 .AND. len(aCols) > 0
		cHTML += "<table id='tab" + cName + "' class='table table-striped table-bordered table-hover dt-responsive' cellspacing='0' cellpadding='0' style='width: 100%;'>"
		cHTML += "		<thead class='cabacalho'>"
		cHTML += "				<tr>"
		cHTML += "					<th>Item</th>"
		If lAltGrid
			cHTML += "					<th>Alterar</th>"
		EndIf
		If lDelGrid	
			cHTML += "					<th>Excluir</th>"
		EndIf
		
									For nI := 1 to len(aHeader)
			if "CMPSEQ" $ aHeader[nI]
				cHTML += "<th style='display: none'>" + aHeader[nI] + "</th>"
			else
										cHTML += "<th>" + aHeader[nI] + "</th>"
			EndIf
									Next nI
		
		cHTML += "				</tr>"
		cHTML += "		</thead>"
		cHTML += "		<tbody class='conteudo'>"    //para cada registro
		
						For nI := 1 to len(aCols)
		cHTML += "				<tr id='Linha" + cName + alltrim(str(nI)) + "' bgcolor='#FFFFFF'>"
		cHTML += "					<th id='Cont" + cName + alltrim(str(nI)) + "'>" + alltrim(str(nI)) + "</th>"
		If lAltGrid
			cHTML += "					<td>"																																	
			cHTML += "						<center><img id='btn" + cName + alltrim(str(nI - 1)) +  "' class='colBtn' src='imagens-pls/refresh.gif' onclick='fVisRecGen(" + alltrim(str(nI))/*alltrim(STR(aCols[nI][len(aCols[nI])]))*/ + "," + cName + ".id,4)' alt='Alterar'></center>"
			cHTML += "					</td>"
		EndIf
		
		If lDelGrid
			cHTML += "					<td>"																																	
			cHTML += "						<center><img id='btn" + cName + alltrim(str(nI - 1)) +  "' class='colBtn' src='imagens-pls/004.gif' onclick='fGetDadGen(" + alltrim(str(nI))/*alltrim(STR(aCols[nI][len(aCols[nI])]))*/  + "," + cName + ".id,5,true,&quot;&quot; ,&quot;&quot; ,cCampoDefault)' alt='Excluir'></center>"
			cHTML += "					</td>"
		EndIf							
								
			For nJ := 1 to (len(aCols[nI]))
				if "CMPSEQ" $ aHeader[nJ]
					cHTML += "<td style='display: none !important'>" + aCols[nI][nJ] + '<mark class="markInv"> *CMPSEQ </mark>' + "</td>"
				else
					cHTML += "<td>" + aCols[nI][nJ] + "</td>"
				EndIf
										Next nJ
			
		cHTML += "				</tr>"
						Next nI
		cHTML += "		</tbody>"
		cHTML += "	</table>" 
	EndIf

cHTML += "</div>"
cHTML += "<div id='Rodape"+ cName +"' class='row'>"

If  len(aHeader) > 0 .AND. len(aCols) > 0
	cHTML += "				<div id='" + cName + "Pagination' class='infoBarBottom left col-xs-12 col-sm-12 col-md-12 col-lg-12'>"
	cHTML += "					<div id='" + cName + "DivGroupPage' class='input-group'>"
	cHTML += "						<span id='" + cName + "SpanGroupPage1' class='input-group-btn'>"
	cHTML += "							<button id='" + cName + "first' type='button' class='btn btn-default' disabled='' onclick=" + "navGridDat('" + cName + "','','first')>Primeiro</button>"
	cHTML += "							<button id='" + cName + "prev' type='button' class='btn btn-default' disabled='' onclick=" + "navGridDat('" + cName + "','','prev')>Anterior</button>"
	cHTML += "							<button id='" + cName + "next' type='button' class='btn btn-default' onclick=" + "navGridDat('" + cName + "','','next')>Pr�ximo</button>"
	cHTML += "							<button id='" + cName + "last' type='button' class='btn btn-default' onclick=" + "navGridDat('" + cName + "','','last')>�ltimo</button>"
	cHTML += "						</span>"
	cHTML += "						<input id='" + cName + "pageNum' type='text' class='form-control' placeholder='N�' style='max-width: 100px; min-width: 70px;'>"
	cHTML += "						<span id='" + cName + "SpanGroupPage2' class='input-group-page-ok'>"
	cHTML += "							<button id='" + cName + "SetPage' type='button' class='btn btn-default' onclick=" + "navGridDat('" + cName + "','','pageNum')>OK</button>"
	cHTML += "						</span>"
	cHTML += "					</div>"
	cHTML += "				</div>"
	cHTML += "				<div id='" + cName + "Page' class='infoBarBottom left col-xs-12 col-sm-12 col-md-12 col-lg-12'>P�gina: 1 de </div>"
	cHTML += "				<div id='" + cName + "RegTot' class='infoBarBottom right col-xs-12 col-sm-12 col-md-12 col-lg-12'>Total de Registro(s) : </div>"
	cHTML += "				<input id='" + cName + "nPagina' type='hidden' value='1'>"
	cHTML += "				<input id='" + cName + "nQtdPag' type='hidden' value=''>"
	cHTML += "				<input id='" + cName + "nQtdReg' type='hidden' value=''>"
EndIf



cHTML += "</div>"
cHTML += "</div>"
cHTML += "</div>"   
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return cHTML
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿥CFHidden 튍utor  쿌lexander            � Data �  11/02/12   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Cria botao												   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Static Function WCFHidden(cName,cValue)
LOCAL cHTML		:= ""     
DEFAULT cValue	:= ""

If ValType(cValue) == "C"
	cHTML += "<input type='hidden' name='" + cName + "' id='" + cName + "' value='" + cValue + "'>"
ElseIf ValType(cValue) == "N"
	cHTML += "<input type='hidden' name='" + cName + "' id='" + cName + "' value='" + cValToChar(cValue) + "'>"
ElseIf ValType(cValue) == "D"
	cHTML += "<input type='hidden' name='" + cName + "' id='" + cName + "' value='" + DToS(cValue) + "'>"
EndIf	
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return cHTML
/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴커굇
굇쿑un뇙o    쿥CArrPost   쿌utor  � Alexander             � Data �16.06.2006 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴캑굇
굇�          쿝otina de recuperacao do header das estruturas 				 낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
/*/                
Function WCArrPost(oObj)
LOCAL nI := 0                           
LOCAL nX := 0
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿘onta Estrutura iniciar do obj de dados genericos
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
oObj := PLSXINC_ARRAYOFSDADFIELD():New()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿐nviados via post
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
For nI:=1 To Len(HttpPost->aPost)

	If At( 'field', Lower(HttpPost->aPost[nI]) ) > 0                   
	
		AaDd( oObj:oWSSDADFIELD, PLSXINC_SDADFIELD():New() )
		
		nX := Len(oObj:oWSSDADFIELD)
		
		oObj:OWSSDADFIELD[nX]:cFIELD := HttpPost->aPost[nI]
		oObj:oWSSDADFIELD[nX]:cVALUE := &("HttpPost->" + HttpPost->aPost[nI])
		
	EndIf	
	
Next
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return oObj
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿥CTextArea	튍utor  쿞aude                � Data �  18/03/13   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Cria TEXTAREA (Memo)   										     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽

*/

Static Function WCTextArea(cName,cTitle,cSize,cCols, cRows,cValue,lOb,lRO,lDi,cJSKeyDown,cJSFocOut,lGrupFS,cCss,cJSBlur,cXS,cSM,cMD,cLG, lCustom)
LOCAL cHTML			:= ""
LOCAL cIndObri       := ""
LOCAL cClassOBOP     := ""
//LOCAL cReadOnly		:= ""
LOCAL cDisabled 		:= ""
LOCAL cCssObri		:= ""  
DEFAULT cSize    		:= ""
DEFAULT cXS    		:= "12"
DEFAULT cSM    		:= "6"
DEFAULT cMD    		:= "6"
DEFAULT cLG    		:= "4"
DEFAULT cValue		:= ""
DEFAULT lRO   		:= .F.
DEFAULT lDi			:= .F.                                
DEFAULT lOb			:= .F.                                                 
DEFAULT cJSKeyDown	:= ""
DEFAULT cJSFocOut		:= ""       
DEFAULT lGrupFS		:= .F.     
//DEFAULT cWidth		:= ""
DEFAULT cCols			:= "50"
DEFAULT cRows			:= "4" 
DEFAULT cJSBlur			:= ""
DEFAULT lCustom      := .F.
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿝eadOnly, Disabled, Css, FocusOut e JsFunc
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
cCustom += iif(lCustom,"textarea~"+cName+"|","")
cDisabled 	:= Iif(lDi,"DISABLED","")
If lOb
	cIndObri   := "<span style='color:red'>*</span>"
	cClassOBOP := " TextoInputOB"
Else
	cIndObri   := ""
	cClassOBOP := " TextoInputOP"
EndIf
cJSKeyDown	:= StrTran(cJSKeyDown,"'",'"')
cJSFocOut	:= StrTran(cJSFocOut,"'",'"')        
cJSBlur		:= StrTran(cJSBlur,"'",'"')
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿎ria campo
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
cXS := "col-xs-" + cXS + " " 
cSM := "col-sm-" + cSM + " "
cMD := "col-md-" + cMD + " "
cLG := "col-lg-" + cLG + " "

cHTML += "<div class='" + cXS + cSM + cMD + cLG + "'>"	
cHTML += "<div class='form-group'>"
cHTML += "<label>" + cTitle + cIndObri + "</label>"
cHTML	+= "<textarea class='form-control" + cClassOBOP + '" name=' + cName + "' id='" + cName  + "' cols='" + cCols + "' rows='" + cRows + "'  value='" + cValue + "' size='" + cSize + "' " + cDisabled + " maxlength='"+ cSize +"'"  //></textarea>
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿖eyDown
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If lRO
	cHTML +=  " readonly='Yes' "
EndIf	
                      
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿖eyDown
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !Empty(cJSKeyDown)
	cHTML +=  " onkeydown='" + cJSKeyDown + "' "
EndIf	

If !Empty(cJSBlur) 
	cHTML	+= " onblur='" + cJSBlur + "'"
EndIf	

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑ocusOut
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
If !Empty(cJSFocOut)
	cHTML	+= " onfocusout='" + cJSFocOut + "'"
EndIf          

cHTML	+= " />"

cHTML	+= cValue // Atribuindo valor DEFAULT.
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑echa lebal pois o input vai ficar abaixo do label
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
cHTML	+= "</textarea>"
cHTML  += "</div>"
cHTML  += "</div>"
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return cHTML
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿥CTextArea	튍utor  쿞aude                � Data �  18/03/13   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Cria TEXTAREA (Memo)   										     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽

*/

Static Function WCFuncLoad(cFuncLoad)
LOCAL cHTML			:= ""

cHtml += " <script language='JavaScript'> "
cHtml +=  cFuncLoad
cHtml += " </script> "
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return cHTML

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿥CTextArea	튍utor  쿞aude                � Data �  18/03/13   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Cria TEXTAREA (Memo)   										     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽

*/

Static Function WCObrigat(aObrigat)
LOCAL cHTML			:= ""
LOCAL nI				:= 0
LOCAL nLen				:= 0
DEFAULT aObrigat 		:= {}

cHtml += " <script language='JavaScript'> "  + CRLF
//Seta os campos obrigat�rios para a valida豫o no bot�o confirmar.
cHTML += "var oForm = new xform( document.forms[0]) ;"  + CRLF

nLen := len(aObrigat)

If nLen > 0
	For nI := 1 to nLen
		If Len(aObrigat[nI]) > 1
			If Empty(aObrigat[nI][2])	
				cHTML += "oForm.add( document.forms[0]." +aObrigat[nI][1] + ",'tudo', false , false);"	+ CRLF		
			Else
				cHTML += "oForm.add( document.forms[0]." +aObrigat[nI][1] + ",'onkeypress', false , false);"	+ CRLF		
			Endif
		Else
			cHTML += "oForm.add( document.forms[0]." +aObrigat[nI] + ",'tudo', false , false);"	+ CRLF
		EndIf
	Next nI
EndIf

cHtml += " </script> "
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return cHTML

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿥CTextArea	튍utor  쿞aude                � Data �  18/03/13   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Cria TEXTAREA (Memo)   										     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽

*/

Static Function WCCriarVar(aVar)
LOCAL cHTML			:= ""
LOCAL nI				:= 0
LOCAL nLen				:= 0
cHtml += " <script language='JavaScript'> "
nLen := len(aVar)
For nI := 1 to nLen
	cHtml += aVar[nI] + " = '';" + CRLF
next nI
cHtml += " </script> "

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//쿑im da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return cHTML

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿥CLeg	튍utor  쿖arine Riquena Limp     � Data �  11/05/15   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Cria Legenda                                                볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
   		cCSS � o nome da class css que vai representar a cor da legenda     볍�
   		Cores disponiveis:                                                  볍�
      |    Class    |   Cor     |                                          볍�
      ---------------------------                                          볍�
      | icon-white  | branco    |                                          볍�
      | icon-yellow | amarelo   |                                          볍�
      | icon-orange | laranja   |                                          볍�
      | icon-green  | verde     |                                          볍�
      | icon-black  | preto     |                                          볍�
      | icon-red    | vermelho  |                                          볍�
   		                                                                    볍�
   		Para adicionar uma nova cor, basta criar outra classe no arquivo    볍� 
   		estilo.css, e nesta, usar a propriedade color do css                볍�
   		                                                                    볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/

Static Function WCLeg(cName, cCSS, cTitle)
LOCAL cHTML 	 := "" 
DEFAULT cName  := ""
DEFAULT cCSS   := ""
DEFAULT cTitle := ""
					cHTML += "<label name='" + cName + "'>"
					cHTML += "<i class='fa fa-circle graph-captions " + cCSS + "'></i>
					cHTML += "&nbsp;&nbsp;&nbsp;" + cTitle + "&nbsp;&nbsp;&nbsp;</label>"
Return cHTML

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿥CRadio	튍utor  쿝odrigo Morgon      � Data �  17/08/15   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Cria radiobutton		     							            볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/       
Static Function WCRadio(cName,cTitle,aOpcoes,cInLine, cXS, cSM, cMD, cLG, cCss, lCustom)

LOCAL nI		 	:= 0
LOCAL cHTML		:= ""

DEFAULT cName		:= ""
DEFAULT cTitle	:= ""
DEFAULT cInLine	:= ""
DEFAULT aOpcoes 	:= {}
DEFAULT cXS    	:= "12"
DEFAULT cSM    	:= "6"
DEFAULT cMD    	:= "6"
DEFAULT cLG    	:= "4"
DEFAULT cCss 		:= ""
DEFAULT lCustom      := .F.

cCustom += iif(lCustom,"radiobutton~"+cCss+"|","")
cXS := "col-xs-" + cXS + " " 
cSM := "col-sm-" + cSM + " "
cMD := "col-md-" + cMD + " "
cLG := "col-lg-" + cLG + " "

cHTML += "<div class='" + cXS + cSM + cMD + cLG + "'>"	
cHTML += "<div class='form-group'>"
cHTML += "<label>" + cTitle + "</label>"
cHTML += "<div class='input-group'>"

if cInLine == "inline"		
	//Disposicao inline
	For nI := 1 to Len(aOpcoes)
		cHTML += "<label class='radio-inline'>"
		cHTML += "<input type='radio' " + iif(empty(cCss), "" ," class='" + cCss + "'" ) + " name='" + cName + "' value='" + alltrim(Str(nI)) + "' "
		cHTML += IIf( nI == 1, "checked='checked'", "") + ">" + aOpcoes[nI] + "</label>"
	Next	
else
	//Disposicao vertical
	For nI := 1 to Len(aOpcoes)
		cHTML += "<div class='radio'>"
	  	cHTML += "<label><input type='radio' class='" + cCss + "' name='" + cName + "' value='" + alltrim(Str(nI)) + "' "
	  	cHTML += IIf( nI == 1, "checked='checked'", "") + ">" + aOpcoes[nI] + "</label>"
	  	cHTML += "</div>"
	Next
endif

cHTML += "</div>"
cHTML += "</div>"
cHTML += "</div>" 
  
Return cHTML   
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿥CAlertBS	튍utor  쿖arine Riquena Limp      � Data �  11/09/15   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     � Cria alert do bootstrap	     							            볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/       

Static Function WCAlertBS(cName,cCss,cText,lDisplay) 
LOCAL cHTML		:= ""
LOCAL cDisplay	:= ""

DEFAULT lDisplay  := .F.

cDisplay := IIF(lDisplay == .T., 'style="display:block;margin-top:10px;"' , 'style="display:none;margin-top:10px;"')

cHTML += '<div class="alert alert-' +cCss+ ' alert-dismissible" id="' + cName + '" role="alert" ' + cDisplay + '>'
cHTML +=' <button type="button" class="close" aria-label="Close" onclick='"
cHTML += "$('#" + cName + "').hide()><span aria-hidden='true'>&times;</span></button>"
cHTML += cText
cHTML += '</div>'

Return cHTML  
    
//-------------------------------------------------------------------
/*/{Protheus.doc} WCPopOver
Fun豫o que cria o componente popover do bootstrap.
Para customiza豫o via javascript, ver documenta豫o em: http://getbootstrap.com/javascript/#popovers

@author Rodrigo Morgon
@since 13/10/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function WCPopOver(cName,cTitle,cValue,lDisplay,cXS,cSM,cMD,cLG)

LOCAL cHTML		:= ""
LOCAL cDisplay 	:= ""
DEFAULT cXS    	:= "1"
DEFAULT cSM    	:= "1"
DEFAULT cMD    	:= "1"
DEFAULT cLG    	:= "1"
DEFAULT lDisplay  := .T.

cDisplay := IIF(lDisplay == .T., "style='display:block'" , "style='display:none'")	

cXS := "col-xs-" + cXS + " " 
cSM := "col-sm-" + cSM + " "
cMD := "col-md-" + cMD + " "
cLG := "col-lg-" + cLG + " "

cHTML += "<div class='" + cXS + cSM + cMD + cLG + "' >"
cHTML += '<br><span id="' + cName + '" class="glyphicon glyphicon-question-sign" data-original-title="' + cTitle + '"
cHTML += ' data-toggle="popover" data-trigger="hover" data-html="true" data-content="'
cHTML += cValue
cHTML += '" ' + cDisplay + '></span></div>'

Return cHTML 

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽굇
굇쿑uncao    �__WCHtml	    � Autor � Totvs			    � Data � 30/03/10 낢굇
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙굇
굇쿏escricao � Somente para compilar a class							  낢굇
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
/*/
Function __WCHtml
Return
