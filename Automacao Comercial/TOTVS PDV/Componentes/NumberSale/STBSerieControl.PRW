#INCLUDE "PROTHEUS.CH"
#INCLUDE "STBSERIECONTROL.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} STBNSrAval
Verifica os numeros dispon��iveis para o controle de Numero de s�rie
@author  Varejo
@version P11.8
@since   26/04/2013
@obs
@sample
/*/
//------------------------------------------------------------------- 
Function STBNSrAval()    
Local 	nI			:= 0                            // Indica quando executar a rotina de serie x PDV
Local	nMvNsrDisp	:= SuperGetMV("MV_NSRDISP",,0)	// Indica se utiliza controle de serie automatica  

If nMvNsrDisp > 0

	DbSelectArea("SL6")
	DbSetOrder(2)
	//�������������������������������������������������������
	//�Procura todas as series disponiveis para esta estacao�
	//�������������������������������������������������������
	If DbSeek( xFilial("SL6")+cEstacao+"1" )
		While SL6->( !Eof() ) .AND. SL6->L6_ESTACAO == cEstacao;
		 						  .AND. SL6->L6_STATUS  == "1"
		
			nI++
			SL6->( DbSkip() )
		End
    EndIf
    
    If nI <= nMvNsrDisp
        STFMessage("STBNSrAval", "ALERT", STR0001) //"Reserva de s�rie para esta eta��o est� chegando ao final. Favor rodar a rotina S�rie X PDV na retaguarda"
    	StfShowMessage("STBNSrAval")
    EndIf    
EndIf

Return (NIL)  

//-------------------------------------------------------------------
/*/{Protheus.doc} STBValcDoc
Realiza o incremento do n�mero de s�rie
@param 	 cDoc  Numero do Cupom Fiscal
@param   cCRO  Numero do CRO
@author  Varejo
@version P11.8
@since   26/04/2013
@obs
@sample
/*/
//------------------------------------------------------------------- 

Function STBSerieAlt( cDoc, cCRO)
Local aArea 		:= ""								// Area
Local lAuto			:= SuperGetMV("MV_LJSRAUT", ,.F.)  // Indica se utiliza incremento automatico da serie
Local cMV_LJSTSER 	:= SuperGetMV("MV_LJCTSER", , "0") //Controle para numero de serie 0 - COO, 1 - CRO, 2 - COO + CRO
Local cCOO	   		:= "999999"							// Numero maximo do COO
Local cDocAtu		:= ""								// Numero do documento com 6 digitos
Local cTamSer		:= STFGetStation("TAMSER")          //Tamanho do numero de S�rie
Local cCROStat		:= STFGetStation("CRO")             //Tamanho do CRO
Local cEstacao		:= STFGetStation("CODIGO")          //Codigo da Esta��o
Local aAreaSL6		:= SL6->(GetArea())                  //WorkArea SL6
Local lAltCOO		:= .F. //Verifica se Alterou a s�rie  //Alterou o COO
Local cPDV			:= STFGetStation("PDV")                   //Numero do PDV
Local cSerieSt		:= STFGetStation("SERIE")             //Serie da Esta��o


                                                                 
If lAuto
	aArea	:= GetArea()
	
		//�����������������������������������������������������������������������������������Ŀ
		//�Compara se o numero do cupom e o ultimo numero antes de zerar o COO.               �
		//�(l6_status == 1 -> serie disponivel pra uso. l6_status==2 -> serie utilizada.      �
		//�������������������������������������������������������������������������������������
		If cMV_LJSTSER == "2"
		   lAltCOO :=  STBAltCOO(cCRO,cDoc, cCROStat, cPDV, cSerieSt) 
		EndIf
		cDocAtu := STBValcDoc( cDoc )
		
	 	If ( Val(cDocAtu) == Val(SubStr(cCOO,1, Len(cTamSer) )) )  .OR. ;
	 		(cMV_LJSTSER == "1" .AND. Val(cCRO) <> Val(cCROStat) ) .OR. ;  
	 		(lAltCOO)
	 		
	 	
			//�������������������������������������������������������������������������������Ŀ
			//�Inativa a serie atual do PDV na tabela SL6, para reservar a proxima            �
			//���������������������������������������������������������������������������������
			DbSelectArea("SL6")
			DbSetOrder(1)
			
        	If DbSeek( xFilial("SL6")+PadR(cSerieSt, TamSx3("L6_SERIE")[1])+cEstacao )
	 	    	RecLock( "SL6", .F. )
		    		L6_STATUS	:=	'2'
		    		L6_CRO 		:= cCROStat
		    	MsUnlock() 
	 	    EndIf
                          
			//����������������������������������������������������������������������������������������Ŀ
			//�Reserva a proxima serie disponivel para a Estacao. Caso nenhuma serie estiver disponivel�
			//�para a estacao, o sistema devera informar ao usuario.                                   �
			//�Status: 1-Disponivel para uso 2- utilizado.                                             �
			//������������������������������������������������������������������������������������������
			DbSetOrder(2)
	 	    If DbSeek( xFilial("SL6")+cEstacao+"1")
	 	    		RecLock( "SL6", .F. )
  
		    			L6_CRO 		:= cCRO
		    		MsUnlock()	 	    		
		    	
		    	STFSetStat({ { "SERIE", SL6->L6_SERIE },;
	 	    				     { "CRO", cCRO} })
 
		   		STFMessage("STBSerieAlt2", "ALERT", STR0002)//"N�mero do COO foi reinicializado."
		 		STFShowMessage("STBSerieAlt1")
		 	Else
		   		STFMessage("STBSerieAlt2", "ALERT", STR0003)  //"Reserva de s�rie para esta eta��o est� chegando ao final. Favor rodar a rotina S�rie X PDV na retaguarda"
                STFShowMessage("STBSerieAlt2")
		    EndIf
		    
 
		EndIf
                                             
	RestArea(aAreaSL6)	
	RestArea(aArea)

EndIf	

Return (NIL)                                                     


//-------------------------------------------------------------------
/*/{Protheus.doc} STBValcDoc
Ajusta o campo L1_DOC
@author  Varejo
@version P11.8
@since   26/04/2013
@obs
@sample
/*/
//------------------------------------------------------------------- 
Static Function STBValcDoc( cDoc )
Local cDocAtu	:= ""		// Retorno da funcao

If TamSX3("L1_DOC")[1] == 9                     
	cDocAtu := SubStr( cDoc, 4, Len( cDoc ) )
EndIf

Return( cDocAtu )
    
//-------------------------------------------------------------------
/*/{Protheus.doc} STBAltCOO
Verifica se alterou o COO
@param   cCRO  		Numero do CRO
@param 	 cCOO  		Numero do COO
@param   cCROStat  	CRO da Esta��o
@param 	 cPDV  		Numero do PDV
@param 	 cSerieST 	Serie da Estacao
@author  Varejo
@version P11.8
@since   26/04/2013
@return lAltCOO    Houve altera��o COO
@obs
@sample
/*/
//------------------------------------------------------------------- 
Static Function STBAltCOO(cCRO, cCOO, cCROStat, cPDV, cSerieSt)
	Local aAreaSL1 := SL1->(GetArea()) //WorkArea SL1
	Local lAltCOO := .F.   //Alterou COO
	Local cUltDoc := ""    //Ultimo documento fiscal
 

	If Val(cCRO) <> Val(cCROStat)
		lAltCOO := .T. //Alterou o CRO 
		//Busca o �ltimo SL1 
		
		//Considera registros Deletados para subir cancelamentos
		SET DELETED OFF
		
		SL1->(DbSetOrder(4) ) //L1_FILIAL + L1_EMISSAO
		
		SL1->(DbSetFilter({ || L1_FILIAL == xFilial() .AND. ;
							   AllTrim(L1_PDV) == AllTrim(cPDV) .AND.  ;
							   (!Empty(L1_DOC) .OR. !Empty(L1_DOCPED)) .AND. ;
							   (AllTrim(L1_SERIE) == AllTrim(cSerieSt) .OR.;
							    AllTrim(L1_SERPED) == AllTrim(cSerieSt ) )}, ;
				" L1_FILIAL == xFilial() .AND. AllTrim(L1_PDV) == AllTrim(cPDV) .AND.  (!Empty(L1_DOC) .OR. !Empty(L1_DOCPED)) .AND. (AllTrim(L1_SERIE) == AllTrim(cSerieSt) .OR. AllTrim(L1_SERPED) == AllTrim(cSerieSt ) )"))
		
		SL1->(DbGoBottom())	
		SL1->(DbSkip(-1)) 
		
		If SL1->(!Eof())     //Verifica se n�o � final de arquivo
			//Verifica se o n�mero de s�rie � igual ao cadastrado na esta��o
			//Se for, verifica o �ltimo cupom  
			//Se for menor ou igual, mantem a numeracao
			cUltDoc  := SL1->L1_DOC
			If Empty(cUltDoc)
				cUltDoc := SL1->L1_DOCPED
			EndIf
			
			lAltCOO := Val(cUltDoc) > Val(cCOO) 
			
		EndIf 
		SL1->(DbClearFilter())  
		
		//Considera registros Deletados para apurar cancelamentos
		SET DELETED ON
		
	EndIf
	
	RestArea(aAreaSL1)   
Return lAltCOO

