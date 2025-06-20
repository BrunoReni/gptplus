#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH" 
#INCLUDE "PWSA540.CH"

/*******************************************************************
* Funcao: PWSA540
* Autor: Marcelo faria
* Data: 02/10/2013
* Gest�o Publica - Solicitacao de Diarias
********************************************************************/
Web Function PWSA540()
	Local cHtml   	:= ""
	Local oParam  	:= Nil

	WEB EXTENDED INIT cHtml START "InSite"	              
		HttpSession->cTypeRequest 	:= "Q"       //Vida Funcional - Diarias
		HttpGet->titulo             := STR0001 	//Solicitacao de Diarias
		HttpSession->aStructure	   	:= {}
		HttpSession->cHierarquia	:= ""
		HttpSession->cIDMENU		:= "GFP"	
		oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		WsChgURL(@oParam,"CFGDICTIONARY.APW") 

		fGetInfRotina("W_PWSA540.APW")
		GetMat()                              //Pega a Matricula e a filial do participante logado

		cHtml := ExecInPage("PWSA120A")
	WEB EXTENDED END
Return cHtml  


/*******************************************************************
* Funcao: PWSA541
* Autor: Marcelo faria
* Data: 23/08/2013
* Gest�o Publica - Consulta Solicitacao
********************************************************************/
Web Function PWSA541()
Local oRequest
Local cHtml   	:= ""
Local nIndice 	:= 0

if(valtype(HttpGet->nIndice) != "U")
   nIndice := val(HttpGet->nIndice) 
endif


WEB EXTENDED INIT cHtml START "InSite"  

   If (HttpGet->nOperacao == "1")  
      GetMat() 
   		HttpSession->DadosFunc  := HttpSession->aStructure[nIndice]
   ElseIf (HttpGet->nOperacao == "3") .Or. (HttpGet->nOperacao == "4")
		oRequest					:= HttpSession->oRequests[val(HttpGet->nIndiceSolic)]
		oDaily       				:= WSClassNew("RHVDFDaily_TVDFDaily")
		
		oDaily:cInitialDate     := PegaValores(oRequest,"TMP_DTINI")
      oDaily:cFinalDate       := PegaValores(oRequest,"TMP_DTFIM")
		
		HttpPost->Diaria   		:= oDaily
	EndIf
   cHtml := ExecInPage( "PWSA541" )  
	
WEB EXTENDED END
Return cHtml


/*******************************************************************
* Funcao: PWSA542
* Autor: Marcelo faria
* Data: 03/10/2013
* Gest�o Publica - Diarias - Gravacao
********************************************************************/
Web Function PWSA542()
Local cHtml   	:= ""
Local oWKF    
Local oOrg    
Local oOrg2    
Local cRetorno	:= ""
Local cWKFAPV   := "" 
Local nOperacao := HttpPost->nOperacao

WEB EXTENDED INIT cHtml START "InSite"
              
	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFDAILY"), WSRHVDFDAILY():New())
	WsChgURL(@oOrg,"RHVDFDaily.APW")
    
   oOrg2 := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
	WsChgURL(@oOrg2,"ORGSTRUCTURE.APW")
     
	oOrg2:cParticipantID 	:= HttpSession->cParticipantID
	oOrg2:cTypeOrg       	:= ""
	oOrg2:cVision        	:= "" //Gestao Publica nao usa o conceito de visao do SIGAORG
	If HttpSession->lR7 .Or. ( ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat) )
		oOrg2:cRegistration	:= HttpSession->RHMat
	EndIf	

   If oOrg2:GetStructure()
	  //Pega filial e matricula do participante
	  GetMat() 

      oOrg:oWSREQUEST:cStarterBranch            := HttpSession->aUser[2] //Filial do solicitante
      oOrg:oWSREQUEST:cSTARTERREGISTRATION     := HttpSession->aUser[3] //Matricula do solicitante
	  oOrg:oWSREQUEST:cBRANCH 				    := HttpPost->cFilFun    
	  oOrg:oWSREQUEST:cREGISTRATION 			:= HttpPost->cMatFun    
	  oOrg:oWSREQUEST:cVISION 				    := "" //Gestao Publica nao usa o conceito de visao do SIGAORG
	  oOrg:oWSREQUEST:cOBSERVATION    		    := Alltrim(HttpPost->txtobs)

      //busca workflow do item de menu de acordo com o perfil montado do usuario
      cWKFAPV                            := alltrim(fGetWorkflow("RHVDFDAILY"))
      
      oOrg:oWSREQUEST:cWFAprov             := cWKFAPV                        //Gestao Publica - Workflow da solicitacao
      oOrg:oWSREQUEST:cWFStage             := ""                            //Gestao Publica - Etapa do Workflow
      If cWKFAPV != ""
          oOrg:oWSREQUEST:cWFStage         := "001"                         //Gestao Publica - Etapa do Workflow

          //Recupera aprovador da primeira etapa do workflow para gestao publica
          oWKF := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFJOURNEY"), WSRHVDFJOURNEY():New())
          WsChgURL(@oWKF,"RHVDFJourney.APW")

          oWKF:cEMPLOYEEFIL                := HttpPost->cFilFun
          oWKF:cREGISTRATION               := HttpPost->cMatFun
          oWKF:cStarterBranch              := HttpSession->aUser[2]
          oWKF:cStarterRegistration       := HttpSession->aUser[3]
          oWKF:cWorkflow                    := cWKFAPV
          oWKF:cStage                       := "001"
          oWKF:lCompensate                 := .F.
          If oWKF:GetWorkflowStage()
             oOrg:oWSREQUEST:cApproverBranch        := oWKF:OWSGetWorkflowStageRESULT:cResponsibleFil
             oOrg:oWSREQUEST:cApproverRegistration := oWKF:OWSGetWorkflowStageRESULT:cResponsibleReg
             oOrg:oWSREQUEST:nApproverLevel         := val(oWKF:OWSGetWorkflowStageRESULT:cApproverLevel)
          Else  
            HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" } //"Erro"
            Return ExecInPage("PWSAMSG" )
          EndIf  
      Else  
          oOrg:oWSREQUEST:cApproverBranch      := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
          oOrg:oWSREQUEST:cApproverRegistration := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
          oOrg:oWSREQUEST:nApproverLevel       := oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
      EndIF
		

		oOrg:oWSVDFDAILYREQUEST:cInitialDate		:= HttpPost->txtdataini
      oOrg:oWSVDFDAILYREQUEST:cFinalDate       := HttpPost->txtdatafim
	
		If oOrg:ADDVDFDAILYREQUEST()
			cRetorno                        := oOrg:cADDVDFDAILYREQUESTRESULT
			HttpGet->msg                    := STR0002  //"operacao realizada com sucesso"
			
			If(nOperacao == "4")
			    W_PWSA115()
			Else 
		       W_PWSA540()
		   EndIf
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" }	//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf
	Else
		HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" }	//"Erro"
		Return ExecInPage("PWSAMSG" )
	EndIf
WEB EXTENDED END

Return cHtml   


/*******************************************************************
* Funcao: PWSA543
* Autor: Marcelo Faria
* Data: 07/10/2013
* Gest�o Publica - Diarias - Aprova��o
********************************************************************/
Web Function PWSA543()
Local cHtml    	:= ""
Local nIndice   := HttpSession->nIndiceSolic
Local nOperacao := HttpSession->nOperacao
Local nNovaEtapa := 0
Local lOk       := .T.
Local cErro     := ""
Local Cod       := HttpPost->txtcod
Local oObj    
Local oOrg    

WEB EXTENDED INIT cHtml START "InSite"
	//busca filial e matricula do paritipante logado
	GetMat()

	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
   	WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
   	                  
	oOrg:cParticipantID	  := HttpSession->cParticipantID
	oOrg:cVision          := HttpSession->oRequests[1]:CVISION 
   	If HttpSession->lR7 .Or. ( ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat) )
    	oOrg:cRegistration  := HttpSession->RHMat
	EndIf   

	If (lOk:= oOrg:GetStructure())
		If HttpPost->lPontoRH == ".T."
			aRetorno := ExecBlock("PontoRH",.F.,.F.,{"3", HttpSession->oRequests[1]:CBRANCH, Cod, HttpPost->txtvisao,nil,nil,HttpPost->txtobs,oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cEmployeeFilial,oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration})
			If !aRetorno[1]
				lOk   := .F.
				cErro := aRetorno[2]
			EndIf
		Else
		   oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WsRhRequest"), WsRhRequest():New())
			WsChgURL(@oObj, "RHREQUEST.APW")   
		
			oObj:oWsRequest                     := RHREQUEST_TREQUEST():New()
			oObj:oWsRequest:cBranch              := HttpSession->oRequests[val(nIndice)]:cBranch
			oObj:oWsRequest:cRegistration        := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
			oObj:oWsRequest:cCode               := HttpSession->oRequests[val(nIndice)]:cCode
			oObj:oWsRequest:cObservation         := HttpPost->txtobs

         //Avalia aprovadores  
         oObj:oWSREQUEST:cWFAprov             := HttpSession->oRequests[val(nIndice)]:cWFAprov //Gestao Publica - Workflow da solicitacao
         oObj:oWSREQUEST:cWFStage             := HttpSession->oRequests[val(nIndice)]:cWFStage //Gestao Publica - Etapa do Workflow

         If alltrim(oObj:oWSREQUEST:cWFAprov) != ""
             nNovaEtapa             := val(oObj:oWSREQUEST:cWFStage) + 1
             oObj:oWSREQUEST:cWFStage := STRZERO(nNovaEtapa, 3) //Gestao Publica - Nova Etapa do Workflow
    
              //Recupera aprovador da etapa do workflow para gestao publica
              oWKF := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHVDFJOURNEY"), WSRHVDFJOURNEY():New())
              WsChgURL(@oWKF,"RHVDFJourney.APW")
    
              oWKF:cEMPLOYEEFIL                := HttpSession->oRequests[val(nIndice)]:cBranch
              oWKF:cREGISTRATION               := HttpSession->oRequests[val(nIndice)]:cRegistration
              oWKF:cWorkflow                    := oObj:oWSREQUEST:cWFAprov
              oWKF:cStage                       := oObj:oWSREQUEST:cWFStage
              oWKF:cStarterBranch              := HttpSession->oRequests[val(nIndice)]:cStarterBranch
              oWKF:cStarterRegistration       := HttpSession->oRequests[val(nIndice)]:cStarterRegistration
              oWKF:lCompensate                 := .F.
              If oWKF:GetWorkflowStage()
                 oObj:oWSREQUEST:cApproverBranch      := oWKF:OWSGetWorkflowStageRESULT:cResponsibleFil
                 oObj:oWSREQUEST:cApproverRegistration := oWKF:OWSGetWorkflowStageRESULT:cResponsibleReg
                 oObj:oWSREQUEST:nApproverLevel       := val(oWKF:OWSGetWorkflowStageRESULT:cApproverLevel)
              Else  
                HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA000.APW" } //"Erro"
                Return ExecInPage("PWSAMSG" )
              EndIf  
         Else  
            oObj:oWsRequest:cApproverBranch        := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
            oObj:oWsRequest:cApproverRegistration   := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
            oObj:oWsRequest:nApproverLevel         := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
         EndIF

			If oObj:ApproveRequest()
	    		lOk := .T.
	    	Else
	    		cErro := PWSGetWSError()
	    		lOk := .F.
	    	EndIf
		EndIf
	EndIf
		
	If lOk
	   	HttpGet->msg := STR0003 //"Aprovacao Gravada com sucesso"
	      	
	    If(nOperacao == "4")
		    W_PWSA115()
		Else 
	       W_PWSA540()
	    EndIf
	Else
		HttpSession->_HTMLERRO := {STR0001, cErro, "W_PWSA00C.APW"}		//"Erro" 
		Return ExecInPage("PWSAMSG" )
	EndIf 
	
WEB EXTENDED END

Return cHtml 


/*******************************************************************
* Funcao: PWSA544
* Autor: Marcelo Faria
* Data: 07/10/2013
* Gest�o Publica - Diarias - Reprova��o
********************************************************************/
Web Function PWSA544()
Local cHtml   	:= ""
Local oObj    
Local oOrg    
Local nIndice 	:= HttpSession->nIndiceSolic
Local nOperacao	:= HttpSession->nOperacao

WEB EXTENDED INIT cHtml START "InSite"
	//busca filial e matricula do paritipante logado
	GetMat()

	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
    WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
     	
    oOrg:cParticipantID 	:= HttpSession->cParticipantID
    oOrg:cVision				:= HttpSession->aInfRotina:cVisao                       	
    If HttpSession->lR7 .Or. ( ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat) )
        oOrg:cRegistration := HttpSession->RHMat
    EndIf   

    If oOrg:GetStructure()       
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WsRhRequest"), WsRhRequest():New())
		WsChgURL(@oObj, "RHREQUEST.APW")   

		oObj:oWsRequest	                  	:= RHREQUEST_TREQUEST():New()
		oObj:oWsRequest:cBranch             	:= HttpSession->oRequests[val(nIndice)]:cBranch
		oObj:oWsRequest:cRegistration        	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
		oObj:oWsRequest:cCode               	:= HttpSession->oRequests[val(nIndice)]:cCode
		oObj:oWsRequest:cObservation         	:= HttpPost->txtobs
		oObj:oWsRequest:cApproverBranch		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
		oObj:oWsRequest:cApproverRegistration 	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
		oObj:oWsRequest:nApproverLevel		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
				
		If oObj:ReproveRequest()
        	HttpGet->msg := STR0004 //"Reprovacao Gravada com sucesso"	    

		    If(nOperacao == "4")
			    W_PWSA115()
			Else 
		        W_PWSA540()
		    EndIf 
		    
		Else
			HttpSession->_HTMLERRO := {STR0001, PWSGetWSError(), "W_PWSA00C.APW"}		//"Erro" 
			Return ExecInPage("PWSAMSG" )
		EndIf 
	Else
		HttpSession->_HTMLERRO := {STR0001, PWSGetWSError(), "W_PWSA00C.APW"}		//"Erro" 
		Return ExecInPage("PWSAMSG" )
	EndIf 			

WEB EXTENDED END

Return cHtml 
