#INCLUDE "PLSDAO.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MSOBJECT.CH"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Define
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
#DEFINE ___cPLSLog "BA1"
#DEFINE ___cPLSNLg "BX4|BA0|BIM|BIA|BIF|BIJ|BJA|BJS|BCN|BMP|BMB|BMC|BH0"

#DEFINE IDX_FIELD_ID 1 
#DEFINE IDX_FIELD_VALUE 2 
#DEFINE IDX_FIELD_STA 3

#DEFINE IDX_INDEX_IDX 1 
#DEFINE IDX_INDEX_CHAVE 3 

/*/{Protheus.doc} PLSDAO
Persiste obj na base de dados (DAO).

@author Alexander Santos
@since 14/01/2011
@version P11
/*/

Class PLSDAO From PLSCONTR

METHOD New(oObj,aErros) Constructor
METHOD Destroy()

EndClass
//-------------------------------------------------------------------
/*/{Protheus.doc} NEW
Contrutor da classe

@author Alexander Santos
@since 14/01/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD New(oObj,aErros) Class PLSDAO                                              
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Persiste OBJ															 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
DPCRUD(oObj,Self,aErros)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Fim do Metodo
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Return Self
//-------------------------------------------------------------------
/*/ { Protheus.doc } Destroy
Libera da memoria o obj (Destroy)

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Destroy() Class PLSDAO
FreeObj(Self:self)
Return
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o	 쿏PCRUD	쿌utor  � Alexander Santos            � Data � 03.03.11 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o 쿝otina de gravacao com base no obj modelo.						낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/                   
Static Function DPCRUD(oObj,oSelf,aErros)
LOCAL aArea     := GetArea()
LOCAL nHoraBase := Seconds()
LOCAL nI		:= 0
LOCAL cChave	:= ""
LOCAL lFound	:= .F.
LOCAL cAlias	:= oObj:GetAlias()
LOCAL nOpc 		:= oObj:GetOperation() 
LOCAL nRecno	:= oObj:GetRecno()
LOCAL nIdx		:= oObj:GetIdx()
LOCAL cKey		:= oObj:GetKey()
LOCAL lLog		:= oObj:GetLog()
LOCAL lAltera   := oObj:GetlAltera()
LOCAL aData		:= oObj:GetData()
LOCAL aIndex	:= oObj:GetIndex()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicia o processo de gravacao											 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If !Empty(cAlias)

	BEGIN TRANSACTION

		Do Case
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
			//� Inclusao																 
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	 		Case nOpc==MODEL_OPERATION_INSERT
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//� Retorna chave de pesquisa												 
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				cChave := DPRetChv(cAlias,aIndex,aData,nIdx,oSelf)
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//� Seta o Idx																 
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				If (cAlias)->( IndexOrd() ) <> nIdx
					(cAlias)->( DbSetOrder(nIdx) )
				EndIf
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//� Verifica se ja existe o registro										 
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				lFound := (cAlias)->( MsSeek( xFilial(cAlias)+cChave ) )
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//� Se nao existe inclui se existir altera pois o setAlterar foi acionado 																 
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				If !lFound .Or. (lFound .And. lAltera)

					(cAlias)->( RecLock(cAlias,Iif(lFound,.F.,.T.) ) )
					
						For nI := 1 To Len(aData)
						
							If aData[nI][IDX_FIELD_STA]
								If (cAlias)->(FieldPos(aData[nI][IDX_FIELD_ID])) > 0 
									(cAlias)->( FieldPut( FieldPos(aData[nI][IDX_FIELD_ID]) , aData[nI][IDX_FIELD_VALUE] ) ) 
								EndIf
							EndIf
							
						Next nI
					
					(cAlias)->( MsUnlock() )
				Else
					FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0001+AllToChar( cChave )+"] no alias ["+cAlias+"]" , 0, 0, {}) //"Imposs�vel incluir - Chave duplicada ["
					AaDd(aErros,STR0001+AllToChar( cChave )+STR0002+cAlias+"]") //"Imposs�vel incluir - Chave duplicada ["###"] no alias ["
				EndIf	
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//� Recno do registro														 
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				oObj:SetRecno( (cAlias)->( Recno() ) )
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//� Log do sistema															 
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				If lLog
					DPLogReg(cAlias,nOpc,aData,oSelf)
				EndIf	
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
			//� Alteracao																 
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	 		Case nOpc==MODEL_OPERATION_UPDATE
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//� Posiciona no registro													 
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				If Empty(cKey)
					(cAlias)->( MsGoto( nRecno ) )
					lFound := !(cAlias)->( Eof() )
				Else
					lFound := DPFindKey(cAlias,nIdx,cKey)				
	        	EndIf
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//� Se encontrado
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				If lFound
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
					//� Log do sistema															 
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
					If lLog
						DPLogReg(cAlias,nOpc,aData,oSelf)
					EndIf	
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
					//� Alteracao																 
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
					(cAlias)->( RecLock(cAlias, .F.) )
					
						For nI := 1 To Len(aData)
						
							If aData[nI][IDX_FIELD_STA]
								If (cAlias)->(FieldPos(aData[nI][IDX_FIELD_ID])) > 0 
									(cAlias)->( FieldPut( FieldPos(aData[nI][IDX_FIELD_ID]) , aData[nI][IDX_FIELD_VALUE] ) ) 
								EndIf
							EndIf
							
						Next nI
					
					(cAlias)->( MsUnlock() )
				Else
					FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0003+cAlias+"]" , 0, 0, {}) //"Imposs�vel Alterar - Registro n�o encontrado no alias ["
					AaDd(aErros,STR0003+cAlias+"]") //"Imposs�vel Alterar - Registro n�o encontrado no alias ["
				EndIf	
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 
			//� Exclucao																 
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
			Case nOpc==MODEL_OPERATION_DELETE
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//� Posiciona no registro													 
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				If Empty(cKey)
					(cAlias)->( MsGoto( nRecno ) )
					lFound := !(cAlias)->( Eof() )
				Else
					lFound := DPFindKey(cAlias,nIdx,cKey)				
	        	EndIf
				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				//� Se encontrado
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
				If lFound
					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
					//� Deleta																	 
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
					(cAlias)->( RecLock(cAlias, .F. ) )
						(cAlias)->( DbDelete() )
					(cAlias)->( MsUnlock() )
				Else
					FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0004+cAlias+"]" , 0, 0, {}) //"Imposs�vel Exclui - Registro n�o encontrado no alias ["
					AaDd(aErros,STR0004+cAlias+"]") //"Imposs�vel Exclui - Registro n�o encontrado no alias ["
				EndIf	
				
			EndCase
		
	END TRANSACTION

EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Restaura area															 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
RestArea( aArea )                   
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Dura豫o
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oSelf:SetLog(nHoraBase)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Fim do metodo															 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Return
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o	 쿏PFindKey 쿌utor  � Alexander Santos            � Data � 03.03.11 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o 쿛osiciona na chave informada										낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/                   
Static Function DPFindKey(cAlias,nIdx,cKey)
LOCAL lFound := .F.
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Verifica se o indice existe
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
If !SIX->( DbSeek(cAlias+cValToChar(nIdx),.F.) )
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0008 + cValToChar(nIdx) + STR0009 + cAlias + "]" , 0, 0, {}) //"O indice ["##"] n�o existe no alias ["
	Return(.F.)
Endif
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Posiciona no registro													 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
If (cAlias)->( IndexOrd() ) <> nIdx
	(cAlias)->( DbSetOrder(nIdx) )
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Verifica se ja existe o registro										 
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
lFound := (cAlias)->( MsSeek( xFilial(cAlias)+cKey ) )
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Fim da Rotina
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Return(lFound)
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o	 쿏PLogReg  쿌utor  � Alexander Santos            � Data � 03.03.11 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o 쿝otina de log de campo com base no obj							낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/                   
Static Function DPLogReg(cAlias,nOpc,aData,oSelf)
LOCAL aArea     	:= GetArea()
LOCAL nHoraBase 	:= Seconds()
LOCAL nI			:= 0          
LOCAL cType			:= ""
LOCAL cSeq			:= ""
LOCAL cNomCam		:= ""
LOCAL cCodOpe 		:= Iif( cAlias $ ___cPLSNLg,"    ",PLSINTPAD() )
LOCAL bVldOpeGrv	:= { || .F. }
LOCAL lLogGrv		:= .F.
DEFAULT aData 	:= {}
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� CodeBlock para validacao do log de campo								 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If nOpc == MODEL_OPERATION_INSERT
	bVldOpeGrv := { || BIQ->BIQ_INCLUI == "1" }
ElseIf nOpc == MODEL_OPERATION_UPDATE
	bVldOpeGrv := { || BIQ->BIQ_ALTERA == "1" }
ElseIf nOpc == MODEL_OPERATION_DELETE
	bVldOpeGrv := { || BIQ->BIQ_EXCLUS == "1" }
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Verifica se o log de campo esta ligado									 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
BIQ->( DbSetOrder(1) )
lLogGrv := ( cAlias $ ___cPLSLog ) .Or. ( BIQ->( MsSeek( xFilial("BIQ")+cCodOpe+cAlias ) ) .And. Eval(bVldOpeGrv) )

If lLogGrv
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Nova Sequencia															 �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cSeq := PLBX1NEW()
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Log de Inclusao ou Alteracao...                                          �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	BX1->( RecLock("BX1",.T.) )
		BX1->BX1_FILIAL   := xFilial("BX1")
		BX1->BX1_SEQUEN   := cSeq
		BX1->BX1_ALIAS    := cAlias
		BX1->BX1_RECNO    := StrZero( &(cAlias+"->(Recno())") ,Len(BX1->BX1_RECNO))
		
		If nOpc == MODEL_OPERATION_INSERT
			BX1->BX1_TIPO := "I"
		ElseIf nOpc == MODEL_OPERATION_UPDATE
			BX1->BX1_TIPO := "A"
		ElseIf nOpc == MODEL_OPERATION_DELETE
			BX1->BX1_TIPO := "E"
		EndIf
		
		BX1->BX1_USUARI   := Upper(PLRETOPE())
		BX1->BX1_DATA     := Date()
		BX1->BX1_HORA     := Time()
		BX1->BX1_ESTTRB   := GetComputerName()
		
		If BX1->(FieldPos("BX1_ROTINA")) > 0
			BX1->BX1_ROTINA := FunName()
		EndIf
	BX1->( MsUnLock() )
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Log de Alteracao campos													 �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If nOpc == MODEL_OPERATION_UPDATE
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Campos 																	 �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		For nI := 1 To Len(aData)
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Somente campos alterados												 �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If !aData[nI][IDX_FIELD_STA]
				Loop
			EndIf
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Nome do Campo															 �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			cNomCam := aData[nI,IDX_FIELD_ID]
	        cType   := ValType(cNomCam)
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Verifica tipo de dado													 �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			Do Case
				Case cType == "C"
					cContOld := (cAlias)->&cNomCam
					cContNew := aData[nI,IDX_FIELD_VALUE]
				Case cType == "N"
					cContOld := AllTrim( Str( (cAlias)->&cNomCam ,17,4 ) )
					cContNew := AllTrim( Str( aData[nI,IDX_FIELD_VALUE],17,4 ) )
				Case cType == "D"
					cContOld := DtoC( (cAlias)->&cNomCam )
					cContNew := DtoC(aData[nI,IDX_FIELD_VALUE])
			EndCase
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Gravacao																 �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If cContOld <> cContNew
			
				BX2->( RecLock("BX2",.T.) )
					BX2->BX2_FILIAL   := xFilial("BX2")
					BX2->BX2_SEQUEN   := BX1->BX1_SEQUEN
					BX2->BX2_CAMPO    := AllTrim(cNomCam)
					BX2->BX2_TITULO   := Posicione("SX3",2,AllTrim(cNomCam),"X3_TITULO")
					BX2->BX2_ANTVAL   := cContOld
					BX2->BX2_NOVVAL   := cContNew
				BX2->( MsUnLock() )
				
			EndIf	
		Next
	EndIf
EndIf	
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Restaura area															 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
RestArea( aArea )                   
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Dura豫o
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oSelf:SetLog(nHoraBase)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Fim da rotina...                                                         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Return
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o	 쿏PRetChv  쿌utor  � Alexander Santos            � Data � 03.03.11 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o 쿝etorna chave de pesquisa com base no idx unico ou da aindex		낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/                   
Static Function DPRetChv(cAlias,aIndex,aData,nIdx,oSelf)
LOCAL nHoraBase := Seconds()
LOCAL nI, nX 	:= 0
LOCAL nPos		:= 0                                       
LOCAL nTamCampo	:= 0
LOCAL cChave 	:= ""
LOCAL cConteudo	:= ""
LOCAL aRet		:= {}
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Monta a chave de pesquisa com base na matriz de index					 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
For nI:=1 To Len(aIndex)
	// devido a release 25 com dicionario no banco a fun豫o FWFormStruct(PLSSTRUC) n�o utilizar mais
	// a primeira posi豫o do array aIndex, trocamos para utilizar a segunda, necessario cValToChar pois
	// todas as chamadas passam o nIdx como num�rico
	// If aIndex[nI,IDX_INDEX_IDX] == nIdx	
	If aIndex[nI,2] == cValToChar(nIdx)
			
		aRet := oSelf:Split("+", StrTran( StrTran( StrTran( StrTran( Upper(AllTrim(aIndex[nI,3] ) ),'DTOS',''), ')','' ),'(',''),'DTOS','') )
		
		For nX:=1 To Len(aRet)
			If ( nPos := Ascan(aData,{ |x| x[IDX_FIELD_ID] == aRet[nX]}) ) > 0 .And. aData[nPos,IDX_FIELD_STA] .And. At("_FILIAL",aData[nPos,IDX_FIELD_ID]) == 0

				nTamCampo := TamSx3( aData[nPos,IDX_FIELD_ID])[1]
				
				If ValType(aData[nPos,IDX_FIELD_VALUE]) == 'D'
					cConteudo := AllTrim( DtoS( aData[nPos,IDX_FIELD_VALUE] ) )
					cChave    += cConteudo + Space( nTamCampo - Len(cConteudo) )
				Else          
					cConteudo := AllTrim( cValToChar( aData[nPos,IDX_FIELD_VALUE] ) )						
					cChave 	  += cConteudo + Space( nTamCampo - Len(cConteudo) )
				EndIf	
			EndIf
		Next
		
	EndIf
	
Next         
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Erro																	 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If Empty(cChave)
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0005+AllToChar( nIdx )+STR0006+cAlias+STR0007 , 0, 0, {}) //"Imposs�vel criar chave com o IDX ["###"] do alias ["###"] informado"
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//� Dura豫o
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oSelf:SetLog(nHoraBase)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Fim da Funcao															 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Return(cChave)
/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽굇
굇쿑uncao    쿛LSDAO    � Autor � Totvs				    � Data � 30/03/10 낢굇
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙굇
굇쿏escricao � Somente para compilar a class							  낢굇
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
/*/
Function PLSDAO
Return
