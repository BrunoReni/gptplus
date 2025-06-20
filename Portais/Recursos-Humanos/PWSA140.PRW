#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH" 
#INCLUDE "PWSA140.CH"

#DEFINE cCodUser "MSALPHA"

/*
������������������������������������ͳ��
���Data Fonte Sustenta��o� ChangeSet ���
������������������������������������ĳ��  
���    26/09/2014        �  256516   ��� 
�������������������������������������ͱ�
*/ 
/*******************************************************************
* Funcao: PWSA140
* Autor: Alex Adriano de Oliveira
* Data: 07/12/2009
* Solicitacao de Transferencia
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Uso       � RH/Portais                                                   ���
���������������������������������������������������������������������������Ĵ��
��� Atualizacoes sofridas desde a Construcao Inicial.                       ���
���������������������������������������������������������������������������Ĵ��
��� Analista     � Data   �FNC:            �Motivo da Alteracao             ��� 
���Emerson Campos�07/03/14�M_RH001/196101  �Ajustes para atender a P12      ���
���Emerson Campos|30/04/14|TPKFN9          |Replica altera��es realizadas   ���
���              |        |                |pela manuten��o at� 25/11/13    ���
���              |        |                |chamado TIA106, changeset 193109���
���              |        |                |na P11.80                       ���
���Renan Borges  �12/09/16�TVWVWI          �Ajuste ao utilizar Vis�o por    ���
���              �        �                � Departamento e realizar a soli-���
���              �        �                �ta��o para um membro da equipe, ���
���              �        �                �seja carregado o aprovador cor- ��� 
���              �        �                �retamente, quando o respons�vel ��� 
���              �        �                �pelo departamento estiver em um ��� 
���              �        �                �departamento diferente ao do so-��� 
���              �        �                �licitante.                      ��� 
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Web Function PWSA140()
Local cHtml   	:= ""
	HttpCTType("text/html; charset=ISO-8859-1")
	WEB EXTENDED INIT cHtml START "InSite"	       
	httpSession->cEmpTrans := ""         
		HttpSession->cTypeRequest 	:= "4"		// Transferencia
		HttpGet->titulo           	:= STR0002 	//"Solicitacao de Transferencia"
		HttpSession->aStructure	   	:= {}
		HttpSession->cHierarquia	:= ""
		
		fGetInfRotina("W_PWSA140.APW")
		GetMat()								//Pega a Matricula e a filial do participante logado
		
		cHtml := ExecInPage("PWSA120A")
	WEB EXTENDED END
Return cHtml

/*******************************************************************
* Funcao: PWSA141
* Autor: Alex Adriano de Oliveira
* Data: 07/12/2009
* Solicitacao de transferencia - interacao
********************************************************************/
Web Function PWSA141()

Local cHtml   	:= ""
Local nIndice 	:= 0
Local oRequest
Local lFuncTran		:= FindFunction("FuncTransf") .And. FuncTransf()

if(valtype(HttpGet->nIndice) != "U")
   nIndice := val(HttpGet->nIndice) 
endif
HttpCTType("text/html; charset=ISO-8859-1")

httpSession->cEmpTrans := ""

WEB EXTENDED INIT cHtml START "InSite"  	
	 
    GetMat() //Pega filial e matricula do participante

    oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
	WsChgURL(@oParam,"CFGDICTIONARY.APW")

	If oParam:GETPARAM( "MSALPHA", "MV_ORGCFG" )
		// Verifica se existe o parametro
		If oParam:cGETPARAMRESULT <> ".F."
			HttpSession->cOrgCfg := oParam:cGETPARAMRESULT
		else
			HttpSession->cOrgCfg := "0"
		EndIf
	EndIf
	
	if lFuncTran
		HttpSession->lFuncTran := .T.
	Else
		HttpSession->lFuncTran := .F.
	EndIf
    nIndice 		:=  val(HttpGet->nIndice) 
   	If (HttpGet->nOperacao == "1")  
   		HttpSession->DadosFunc := HttpSession->aStructure[nIndice]
   	ElseIf (HttpGet->nOperacao == "3") .Or. (HttpGet->nOperacao == "4")

		oRequest := HttpSession->oRequests[val(HttpGet->nIndiceSolic)]
		oTransf  := WSClassNew("RHREQUEST_TTransfer")
		
		oTransf:cCompany    := PegaValores(oRequest,"RE_EMPP")
		oTransf:cBranch     := PegaValores(oRequest,"RE_FILIALP")
		oTransf:cCostCenter := PegaValores(oRequest,"RE_CCP")
		HttpPost->cDescCC	:= PegaValores(oRequest,"TMP_DCCP")
		oTransf:cDepartment := PegaValores(oRequest,"RE_DEPTOP")
		HttpPost->cDescDepto:= PegaValores(oRequest,"TMP_DDEPTO")
		oTransf:cProcess	:= PegaValores(oRequest,"RE_PROCESS")
		HttpPost->cDescProc := PegaValores(oRequest,"TMP_DPROCP")
		oTransf:cPost		:= PegaValores(oRequest,"RE_POSTOP")
		HttpPost->cChangeTypeTran := PegaValores(oRequest,"TMP_TPALT")
		HttpPost->cRoleCodeTran   := PegaValores(oRequest,"TMP_FUNCAO")
		HttpPost->Transf    := oTransf
	EndIf

    cHtml := ExecInPage( "PWSA141" )  
	
WEB EXTENDED END
Return cHtml
 
 
/*******************************************************************
* Funcao: PWSA142
* Autor: Alex Adriano de Oliveira
* Data: 08/12/2009
* Solicitacao de transferencia - Gravacao
********************************************************************/
Web Function PWSA142()
Local cHtml   	:= ""
Local oOrg    
Local cRetorno	:= "" 
Local nOperacao := HttpSession->nOperacao
HttpCTType("text/html; charset=ISO-8859-1")
WEB EXTENDED INIT cHtml START "InSite"
    httpSession->cEmpTrans := ""     
	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
	WsChgURL(@oOrg,"RHREQUEST.APW")
    
    oOrg2 := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
	WsChgURL(@oOrg2,"ORGSTRUCTURE.APW")
     
	oOrg2:cParticipantID 	:= HttpSession->aStructure[val(HttpPost->nIndice)]:cParticipantID
	oOrg2:cTypeOrg       	:= ""
	oOrg2:cVision        	:= HttpSession->aInfRotina:cVisao
	oOrg2:cRegistration		:= HttpSession->aStructure[val(HttpPost->nIndice)]:cRegistration
	oOrg2:cEmployeeSolFil	:= HttpSession->aUser[2]
	oOrg2:cRegistSolic		:= HttpSession->aUser[3]		

	If oOrg2:GetStructure()	   
	    GetMat()  //Pega filial e matricula do participante
	
		oOrg:oWSREQUEST:cApproverBranch		   		:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
		oOrg:oWSREQUEST:cApproverRegistration  		:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
		oOrg:oWSREQUEST:nApproverLevel		   		:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
	    oOrg:oWSREQUEST:cEmpresaAPR	 				:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupEmpresa
		oOrg:oWSREQUEST:cSTARTERREGISTRATION	 	:= HttpSession->aUser[3]	//Matricula do solicitante
		oOrg:oWSREQUEST:cStarterBranch				:= HttpSession->aUser[2] 	//Filial do solicitante
		oOrg:oWSREQUEST:cBRANCH 					:= HttpPost->cFilFun 		//filial 
		oOrg:oWSREQUEST:cREGISTRATION 				:= HttpPost->cMatFun 		//matricula 
		oOrg:oWSREQUEST:cVISION 					:= HttpSession->aInfRotina:cVisao
		oOrg:oWSREQUEST:cOBSERVATION    			:= Alltrim(HttpPost->txtobs)
		oOrg:oWSREQUEST:cEmpresa	 				:= GetEmpFun()
		oOrg:oWSREQUEST:cDepartAPR	 				:= oOrg2:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cDepartAprovador
	
		oOrg:oWSTRANSFERREQUEST:cCOMPANY			:= HttpPost->txtgrpemp
	    
	    if (ValType(HttpPost->txtfilial) == "C")
			oOrg:oWSTRANSFERREQUEST:cBRANCH			:= HttpPost->txtfilial
		else
			oOrg:oWSTRANSFERREQUEST:cBRANCH			:= oOrg:oWSREQUEST:cBRANCH 
		Endif	
	
		oOrg:oWSTRANSFERREQUEST:cREGISTRATION   	:= HttpPost->cMatFun
		oOrg:oWSTRANSFERREQUEST:cNAME           	:= HttpPost->cNome
		oOrg:oWSTRANSFERREQUEST:cCOSTCENTER			:= HttpPost->txtcc
		
		If ValType(HttpPost->txtdepto) != "U" 
			oOrg:oWSTRANSFERREQUEST:cDEPARTMENT		:= HttpPost->txtdepto
		Else
			oOrg:oWSTRANSFERREQUEST:cDEPARTMENT		:= ""
		EndIf
		
		oOrg:oWSTRANSFERREQUEST:cPROCESS		:= HttpPost->txtprocesso
	
		If (HttpSession->cOrgCfg == "1")
			oOrg:oWSTRANSFERREQUEST:cPOST	  		:= HttpPost->txtposto
		else
			oOrg:oWSTRANSFERREQUEST:cPOST	  		:= ""
	    EndIf
	
		If ValType(HttpPost->txtfuncao) != "U" 
			oOrg:oWSTRANSFERREQUEST:cChangeTypeTran	:= HttpPost->txtalteracao						//Tipo da altera��o
			oOrg:oWSTRANSFERREQUEST:cRoleCodeTran	:= HttpPost->txtfuncao							//Fun��o
		Else
			oOrg:oWSTRANSFERREQUEST:cChangeTypeTran	:= ""
			oOrg:oWSTRANSFERREQUEST:cRoleCodeTran	:= ""
		Endif
		If oOrg:ADDTRANSFERREQUEST()
			cRetorno := oOrg:cADDTRANSFERREQUESTRESULT
			HttpGet->msg := STR0003 // "operacao realizada com sucesso"
			
			If(nOperacao == "4")
			    W_PWSA115()
			Else 
		        W_PWSA140()
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
* Funcao: PWSA143
* Autor: Alex Adriano Oliveira
* Data: 08/12/09
* Aprovacao de transferencia
********************************************************************/
Web Function PWSA143()

Local cHtml   	:= ""
Local nIndice 	:= HttpSession->nIndiceSolic
Local nOperacao := HttpSession->nOperacao
Local Cod     	:= HttpPost->txtcod
Local lOk       := .T.
Local cErro     := ""
Local oObj    
Local oOrg        
HttpCTType("text/html; charset=ISO-8859-1")
WEB EXTENDED INIT cHtml START "InSite"
	//busca filial e matricula do paritipante logado
	GetMat()

	oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
   	WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
   	                  
	oOrg:cVision         := HttpSession->oRequests[val(nIndice)]:CVISION
	oOrg:cEmployeeFil    := HttpSession->oRequests[val(nIndice)]:CBRANCH
	oOrg:cRegistration   := HttpSession->oRequests[val(nIndice)]:CREGISTRATION
	oOrg:cEmployeeSolFil := HttpSession->aUser[2]
	oOrg:cRegistSolic	 := HttpSession->aUser[3]
	oOrg:cRequestType	 := HttpSession->cTypeRequest 

	If (lOk:= oOrg:GetStructure())
		If HttpPost->lPontoRH == ".T."
			aRetorno := ExecBlock("PontoRH",.F.,.F.,{"3", HttpSession->oRequests[1]:CBRANCH, Cod, HttpPost->txtvisao,nil,nil,HttpPost->txtobs,HttpSession->aUser[2],HttpSession->aUser[3]})
			If !aRetorno[1]
				lOk   := .F.
				cErro := aRetorno[2]
			EndIf
		Else
	
	        oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
			WsChgURL(@oObj, "RHREQUEST.APW") 			
			
			GetMat()//busca filial e matricula do paritipante logado
	        
			oObj:oWsRequest	             			:= RHREQUEST_TREQUEST():New()
			oObj:oWsRequest:cBranch      			:= HttpSession->oRequests[val(nIndice)]:cBranch
			oObj:oWsRequest:cRegistration			:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
			oObj:oWsRequest:cCode        			:= HttpSession->oRequests[val(nIndice)]:cCode
			oObj:oWsRequest:cObservation 			:= Alltrim(HttpPost->txtobs)
			oObj:oWsRequest:cApproverBranch		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
			oObj:oWsRequest:cApproverRegistration  	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
			oObj:oWsRequest:nApproverLevel		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
			oObj:oWSREQUEST:cEmpresaAPR	 		    := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupEmpresa
					
			If oObj:ApproveRequest()
		   		lOk := .T.
		 	Else
		    	cErro := PWSGetWSError()
		    	lOk := .F.
		  	EndIf
		EndIf    
	EndIf    
	If lOk
    	HttpGet->nIndice := nIndice
        HttpGet->msg := STR0004 // "Aprovacao Gravada com sucesso"

        If(nOperacao == "4")
		    W_PWSA115()
		Else 
	        W_PWSA140()
	    EndIf
	Else
		HttpSession->_HTMLERRO := {STR0001, PWSGetWSError(), "W_PWSA00C.APW"} //"Erro" 
		Return ExecInPage("PWSAMSG" )
	EndIf 

WEB EXTENDED END

Return cHtml 


/*******************************************************************
* Funcao: PWSA144
* Autor: Alex Adriano Oliveira
* Data: 08/12/09
* Reprovacao de transferencia
********************************************************************/
Web Function PWSA144()

Local cHtml   	:= ""
Local oObj    
Local oOrg    
Local nIndice 	:= HttpSession->nIndiceSolic
Local nOperacao := HttpSession->nOperacao
HttpCTType("text/html; charset=ISO-8859-1")
WEB EXTENDED INIT cHtml START "InSite"

        oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHREQUEST"), WSRHREQUEST():New())
		WsChgURL(@oObj, "RHREQUEST.APW")   
		
		oOrg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
	    WsChgURL(@oOrg,"ORGSTRUCTURE.APW")
	     	
	    oOrg:cParticipantID 	:= HttpSession->cParticipantID
	    oOrg:cVision			:= HttpSession->aInfRotina:cVisao                       	
	    If ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat)
	        oOrg:cRegistration := HttpSession->RHMat
	    EndIf   

		If oOrg:GetStructure() 			
			GetMat()//busca filial e matricula do participante logado
	        
			oObj:oWsRequest	             			:= RHREQUEST_TREQUEST():New()
			oObj:oWsRequest:cBranch      			:= HttpSession->oRequests[val(nIndice)]:cBranch
			oObj:oWsRequest:cRegistration			:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cRegistration
			oObj:oWsRequest:cCode   	    		:= HttpSession->oRequests[val(nIndice)]:cCode
			oObj:oWsRequest:cObservation 			:= Alltrim(HttpPost->txtobs)
			oObj:oWsRequest:cApproverBranch		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupFilial
			oObj:oWsRequest:cApproverRegistration  	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupRegistration
			oObj:oWsRequest:nApproverLevel		   	:= oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:nLevelSup
			oObj:oWSREQUEST:cEmpresaAPR	 		    := oOrg:OWSGETSTRUCTURERESULT:oWSLISTOFEMPLOYEE:OWSDATAEMPLOYEE[1]:cSupEmpresa
					
			If oObj:ReproveRequest()
			    	HttpGet->nIndice := nIndice
		        	HttpGet->msg := STR0005 //"Reprovacao Gravada com sucesso"
		    
			    If(nOperacao == "4")
				    W_PWSA115()
				Else 
			        W_PWSA140()
			    EndIf
			Else
				HttpSession->_HTMLERRO := {STR0001, PWSGetWSError(), "W_PWSA00C.APW"} //"Erro" 
				Return ExecInPage("PWSAMSG" )
			EndIf 
		Else
			HttpSession->_HTMLERRO := {STR0001, PWSGetWSError(), "W_PWSA00C.APW"}		//"Erro" 
			Return ExecInPage("PWSAMSG" )
		EndIf 		

WEB EXTENDED END

Return cHtml 
Function FuncTransf()
	Local cFile  	:= "GpeCpoCompl.fch"
	Local cBuffer	:= ""
	Local cString	:= ""
	Local n			:= 0
	Local nHdl		:= 0
	Local nFor 		:= 0
	Local nPos 		:= 0
	Local nTamArq 	:= 0
	Local nBytes 	:= 0
	Local aNotCmp	:= {}
	Local lRet		:= .F.

	aAdd( aNotCmp , "RA_CODFUNC" )

	If File("GpeCpoCompl.fch")

		//��������������������������������������������Ŀ
		//� Le arquivo texto - Nro total de linhas     �
		//����������������������������������������������
		nHdl    := Fopen(cfile,64)				//Abertura e gravacao e compartilhamento

		If Ferror() # 0 .or. nHdl < 0
		    Help(" ",1,"A210NOPEN")
		    Break
		EndIf

		cString		:= FReadStr(nHdl,64)
		nBytes := (At( CHR(13)+CHR(10),cString )) + 1

		nTamArq 	:= fSeek(nHdl,0,2)
		fSeek(nHdl,0,0)
		nFor 		:= nTamArq / nBytes
		cBuffer		:= space(nBytes)
		FRead(nHdl,@cBuffer,nBytes)

		For n:=1 to nFor
		  nPos := Ascan(aNotCmp,{|x| ALLTRIM(x) == ALLTRIM(Substr(cBuffer,36,10)) .And. Substr(cBuffer,29,1) == "X" })  
		  If nPos >  0
				lRet := .T.
				Exit
			EndIf
			cBuffer		:= space(nBytes)
			FRead(nHdl,@cBuffer,nBytes)
		Next n

		FClose(nHdl)
	EndIf
	
Return lRet
