#Include "PROTHEUS.CH
#INCLUDE "STMEMRYFISC.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STWMemryFisc
Function emiss�o memoria fiscal
@author  Varejo
@version 	P11.8
@since   	03/07/2013
@return  	lRet - Abertura com sucesso
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWMemryFisc()

Local aArea 		:= GetArea()		// Armazena a area corrente
Local dDataIni 		:= Date()		    // Aramazena a data inicial
Local dDataFim 		:= Date()			// Aramazena a data final
Local nOpca 		:= 0				// Armazena a op��o na selecao do tipo do relatorio
Local cReducIni		:= space(6)			// Armazena o numero da reducao inicial
Local cReducFim		:= space(6)			// Armazena o numero da reducao final
Local nCheck 							// Armazena a opcao o check
Local cLock 		:= cUserName+cEstacao		// 
Local cImpressora						// Armazena o modelo da impressora fiscal 
Local nTipoRel 		:= 1				// Armazena a opcao do tipo de relatorio
Local cTipo	  		:= ""				// Tipo do download da mfd
Local cInicio		:= ""				// Parametro inicial para o download da mfd
Local cFinal 		:= ""   			// Parametro final para o download da mfd
Local lCont  		:= .T.				// Flag de execu��o
Local aDados		:= {}               //Par�metros do Strategy
Local aRet			:= {}               //Retorno da fun��o
Local oFont								// Fonte dos objetos da interface
Local lIsMDI 		:= Iif(ExistFunc("LjIsMDI"),LjIsMDI(),SetMDIChild(0)) //Verifica se acessou via SIGAMDI

cImpressora := STFGetStat("IMPFISC")

//�����������������������������������������������������������������������Ŀ
//� Faz o controle via LockByName para evitar que um usu�rio acesse       �
//� 2 vezes uma rotina que use os perif�ricos de automa��o, evitando assim�
//� a concorr�ncia dos mesmos.                                            �
//�������������������������������������������������������������������������
If lIsMDI .AND. !LockByName( cLock )
	Return Nil
Endif

// Verifica se o Caixa e de Cupom Fiscal
If !STFPROFILE(03, "",	, , , .F. , .F.)[1]
	// Para emitir o relat�rio da Mem�ria Fiscal da impres
	// deve-se estar cadastrado como usu�rio fiscal e com os par�metros da impressora corretos.
	// Aten��o
    STFMessage("STWMemryFisc", "STOP",STR0001 +;//"Para emitir o relat�rio da Mem�ria Fiscal da impressora "
    								  STR0002 ) //"deve-se estar cadastrado como usu�rio fiscal e com os par�metros da impressora corretos."
   STFShowMessage("STWMemryFisc")

	Return .F.
EndIf


STIMemryFisc(@nTipoRel,	@cReducIni,	@cReducFim,	@nCheck, ;
				@nOpca, 	@dDataIni, 	@dDataFim, 	@lCont,;
				@oFont)



If lCont
	If nTipoRel == 1
		If nOpca == 1
  
			aDados := { DtoC(dDataIni), DtoC(dDataFim),	cReducIni,	cReducFim,;
						If(nCheck=1,'I','D') }
						
			aRet := STFFireEvent(	ProcName(0) ,;		// Nome do processo
	 													  "STMemFisc"																,;		// Nome do evento
	 													  aDados )		
							
			
		Endif 
	Else  
		If Empty( dDataIni )
			cTipo	:= "2"
			cInicio	:= cReducIni
			cFinal	:= cReducFim
		Else
			cTipo	:= "1"     
			cInicio	:= DTOC( dDataIni )
			cFinal	:= DTOC( dDataFim ) 
		EndIf 
		

		aDados := {  cTipo, cInicio, cFinal }
						
		aRet := STFFireEvent(	ProcName(0) ,;		// Nome do processo
	 													  "STDownMFD"																,;		// Nome do evento
	 													   aDados)	
 	  
	Endif
	
Endif	
	
oFont:End()
RestArea(aArea)
Return Nil



