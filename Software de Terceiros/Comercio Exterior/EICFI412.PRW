#INCLUDE "Average.ch"
#INCLUDE "EICFI412.ch"

/*
Programa : EICFI412.PRW
Objetivo : Integra��o EAI para compensa��o do adiantamento contra o efetivo - despesas
           nacionais (presta��o de contas)
Autor    : igor chiba 
Data     : 03/07/14
Revis�o  : WFS fev/2015 
           Altera��o do envio da ListOfCompensation para envio de uma mensagem
           por compensa��o (uma mensagem para cada despesa 9.01 usada para realiza��o
           da baixa do documento efetivo).
           Essa limita��o � divido ao retorno n�o tratar multiplas sequencias, bem como
           o tratamento de multiplos estornos (envio de v�rias sequencias) n�o estar dispon�vel
           na mensagem REVERSALACCOUNTPAYABLEDOCUMENTDISCHARGE.
           WFS abr/2015
           Altera��o para uso do valor l�quido na compensa��o.
           O valor l�quido ser� retornado pelo ERP logo ap�s a inclus�o do t�tulo da despesa.
           Deve ser levado em considera��o o uso de mais de um adiantamento para a compensa��o
           com o efetivo.
Obs.     :  
*/
*--------------------------------------------------------------------
Function EICFI412()
*--------------------------------------------------------------------
LOCAL lOk:= .T.
Local lBaixou:= .F.
Private nSldVlLiq:= 0
Private nVlCompens:= 0

   /* Para cada adiantamento usado na compensa��o/ baixa do t�tulo efetivo ser�
      enviada uma mensagem de baixa para o financeiro do ERP. */
   ADIANT->(DBGoTop())
   
   /*Armazenamento do valor l�quido original da despesa efetiva */
   SWD->(DBGoTo(ADIANT->WK_RECSWD))
   nSldVlLiq:= SWD->WD_VLLIQ
   
   /* A compensa��o prosseguir� enquanto houver saldo da despesa efetiva a ser transmitida. */
   While ADIANT->(!Eof()) .And. lOk .And. nSldVlLiq > 0

      If ADIANT->WD_VL_COMP == 0 
         ADIANT->(DBSkip())
         Loop
      EndIf  
      MsAguarde({|| lOk:= EasyEnvEAI("EICFI412")}, STR0001)//"Integra��o EAI - Baixa do t�tulo financeiro. Aguarde..."
      If lOk
         /* Se ao menos uma baixa for conclu�da, o t�tulo inclu�do pela rotina de presta��o de contas 
            n�o deve ser exclu�do. */ 
         lBaixou:= .T.
      EndIf
      ADIANT->(DBSkip())
   EndDo
   
Return lOk .Or. lBaixou


*--------------------------------------------------------------------
/* ====================================================*
* Fun��o: IntegDefK
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integra��o com Logix 
* Obs: 
* =====================================================*/
*--------------------------------------------------------------------*
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
*--------------------------------------------------------------------*
Local oEasyIntEAI
//Local cAlias:="SWD"

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.001")
	oEasyIntEAI:oMessage:SetMainAlias("SWD")
	oEasyIntEAI:SetModule("EIC",17)

	// Envio 
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "FI412SEND") //ENVIO                               (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "FI412RESP") //RESPOSTA SOBRE O ENVIO              (<-Response)
	// Envio 

	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult() 

/* ====================================================*
* Fun��o: AP110SEND(oMessage)
* Objetivo: Envio das parcelas de Cambio
* Obs: 
* =====================================================*/
*------------------------------------------------*
Function FI412SEND(oMessage) 
*------------------------------------------------* 
Local oXml             := EXml():New()
Local oBusiness        := ENode():New()
Local oRequest := ENode():New() 
Local oRec             := ENode():New()
Local aOrd             := {}
Local cBanco  := ""
Local cAgencia:= ""
Local cConta  := ""
Local cMotBx  := "004"
Local cCodERP := ""
Local cMoeda  := "R$"

aOrd := SaveOrd({"SYB","EC6","SYF"}) 
EC6->(DBSETORDER(1))//EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
SYF->(DBSETORDER(1))//YF_FILIAL+YF_MOEDA  
SYB->(DBSETORDER(1))

SYB->(DBSEEK(xFilial("SYB")+SWD->WD_DESPESA)) 
EC6->(DBSEEK(xFilial("EC6")+"IMPORT"+SYB->YB_EVENT))

//<BusinessEvent>

   //Entity e Event
   oRequest:SetField("Operation", "EICFI412")
//capa
//<BusinessContent>
   oBusiness:SetField("CompanyId"          ,EICEmpFLogix())
   oBusiness:SetField("BranchId"           ,EICFilFLogix())
   
   oBusiness:SetField("DocumentPrefix"     ,EC6->EC6_PREFIX)  
   oBusiness:SetField("DocumentNumber"     ,SWD->WD_CTRFIN1)
   oBusiness:SetField("DocumentParcel"     ,"")
   oBusiness:SetField("DocumentTypeCode"   ,EC6->EC6_TPTIT)
   oBusiness:SetField("PaymentDate"        ,EasyTimeStamp(dDataBase,.T.,.T.))
   oBusiness:SetField("PaymentValue"       ,ADIANT->WD_VL_COMP)

   If SYF->(DBSeek(xFilial("SYF") + AvKey(cMoeda, "YF_MOEDA")))
      If EC6->EC6_TXCV == "2"
         cCodERP:= SYF->YF_CODCERP
      Else
         cCodERP:= SYF->YF_CODVERP
      EndIf
   EndIf
      
   oBusiness:SetField("CurrencyCode", cCodERP)
   oBusiness:SetField("CurrencyRate", 1)   
   oBusiness:SetField("VendorCode"  ,SWD->WD_FORN)
   oBusiness:SetField("StoreId"     ,SWD->WD_LOJA)

   If !Empty(EC6->EC6_MOTBX)
      cMotBx:= EC6->EC6_MOTBX
   EndIf
   oBusiness:SetField("PaymentMethodCode"  ,cMotBx)
   oBusiness:SetField("PaymentMeans"       ,"000")
   
   //<Bank>
   oBank:=ENode():New()

      //complemento dos dados banc�rios
      cBanco:= SWD->WD_BANCO
      cAgencia:= SWD->WD_AGENCIA
      cConta:= SWD->WD_CONTA
       
      SA6->(DBSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
      If SA6->(DBSeek(xFilial() + SWD->WD_BANCO + SWD->WD_AGENCIA + SWD->WD_CONTA))

         If !Empty(SA6->A6_DVAGE)
            cAgencia:= AllTrim(SA6->A6_AGENCIA) + "-" + SA6->A6_DVAGE 
         EndIf

         If !Empty(SA6->A6_DVCTA)
            cConta:= AllTrim(SA6->A6_NUMCON) + "-" + SA6->A6_DVCTA 
         EndIf
      EndIf
      
      oBank:SetField("BankCode"   , cBanco)
      oBank:SetField("BankAgency" , cAgencia)      
      oBank:SetField("BankAccount", cConta)

   oBusiness:SetField("Bank"      ,oBank)     
   //</Bank>                     
   
   oBusiness:SetField("FinancialCode"     ,EC6->EC6_NATFIN)  
   oBusiness:SetField("HistoryText"       ,"")

   oList:=ENode():New() 

   /* Se o valor l�quido for menor que o valor informado pelo usu�rio para a compensa��o,
      o sistema assumir� o valor l�quido. Caso contr�rio, mantem-se o valor de adiantamento
      informado pelo usu�rio. */
      If nSldVlLiq < ADIANT->WD_VL_COMP
         nVlCompens:= nSldVlLiq
         /* Finaliza o envio das compensa��es */
         nSldVlLiq:= 0
      Else
         nVlCompens:= ADIANT->WD_VL_COMP
         /* Subtrai do saldo do valor l�quido o valor baixado/ compensado com o adiantamento. */
         nSldVlLiq -= ADIANT->WD_VL_COMP
      EndIf
      //<ListOfCompensation>
         //<Compensation>
            oCompensa:=ENode():New()
            oCompensa:SetField("CompensationValuesAdvance",nVlCompens)
            oCompensa:SetField("DocumentNumber"           ,ADIANT->WD_CTRFIN1)
         //</Compensation>      
         oList:SetField("Compensation",oCompensa)
      //</ListOfCompensation>

   oBusiness:SetField("ListOfCompensation",oList)

   oRec:SetField("BusinessRequest"  ,oRequest)// OK
   oRec:SetField("BusinessContent",oBusiness) //  OK
   oXml:AddRec(oRec)
   
RestOrd(aOrd,.t.)

Return oXml


/* ====================================================*\
* Fun��o: FI412RESP(oMessage)                          *
* Objetivo: Resposta do Envio                          *
* Obs:                                                 *
\* ====================================================*/
*------------------------------------------------*
Function FI412RESP(oMessage)
*------------------------------------------------*
Local oRetCont:= oMessage:GetRetContent()
Local aOrd:= SaveOrd({"SWD"})

oProInformation:=oRetCont

/* Atualiza��o da despesa efetiva: */ 
SWD->(DBGOTO( ADIANT->WK_RECSWD))//LINHA REFERENTE A DESPESA ORIGINAL BASE ADIANTAMENTO SIM ... TODAS AS LINHAS DO ADIANT SE REFEREM A ELA
SWD->(MSUNLOCK())
SWD->(RECLOCK('SWD',.F.))

/* n�mero da �ltima sequ�ncia de baixa ocorrida com sucesso do lado Logix */
SWD->WD_CTRFIN2 := EasyGetXMLinfo( ,oProInformation,"_DischargeSequence" )  

/*totaliza o valor da compensa��o (N adiantamentos para 1 efetivo)*/
SWD->WD_VL_COMP += nVlCompens //ADIANT->WD_VL_COMP 
SWD->(MSUNLOCK())
   

/* Atualiza��o da TRB da despesa efetiva: */
TRB->(RecLock("TRB", .F.))
TRB->WD_CTRFIN2:= EasyGetXMLinfo( ,oProInformation,"_DischargeSequence" )
TRB->WD_VL_COMP += nVlCompens //SWD->WD_VL_COMP 
TRB->(MsUnlock())


/* Atualiza��o da tabela EW7: */
GerEW7()              


/* Atualiza��o da despesa de adiantamento: */
//LINHA REFERENTE A DESPESA 901, recebendo sempre o valor compensado
SWD->(DBGOTO( ADIANT->WK_RECADNT))
SWD->(RECLOCK('SWD',.F.))
SWD->WD_VL_COMP += nVlCompens //ADIANT->WD_VL_COMP
SWD->(MSUNLOCK())


/* Atualiza��o da TRB da despesa de adiantamento: */
AtuTRBAdiant(SWD->(RecNo()))

RestOrd(aOrd, .T.)
Return oMessage



*------------------------------------------------*
Static Function GerEW7()
*------------------------------------------------*

   EW7->(RECLOCK('EW7',.T.))
   EW7->EW7_FILIAL:= XFILIAL('EW7')
   EW7->EW7_TPTIT := "CP"
   EW7->EW7_HAWB  := SWD->WD_HAWB
   EW7->EW7_FORN  := SWD->WD_FORN
   EW7->EW7_LOJA  := SWD->WD_LOJA
   EW7->EW7_DESPES:= SWD->WD_DESPESA
   EW7->EW7_DT_EMI:= dDataBase //data da compensa��o
   EW7->EW7_MOEDA := IF(SWD->(FIELDPOS('WD_MOEDA')) <> 0 , SWD->WD_MOEDA , "R$" )
   EW7->EW7_VALOR := nVlCompens //ADIANT->WD_VL_COMP
   EW7->EW7_TITERP:= SWD->WD_CTRFIN1 //n�mero da despesa que foi paga (compensada)
   EW7->EW7_CTRERP:= ADIANT->WD_CTRFIN1//n�mero do adiantamento usado para compensa��o
   EW7->EW7_SEQBX := SWD->WD_CTRFIN2
 
Return .t.


/*
Funcao      : AtuTRBAdiant
Par�metros  : RecNo da despesa de adiantamento
Objetivos   : Atualizar a despesa de adiantamento do arquivo de trabalho TRB com o valor usado para a compensa��o
Retorno     : 
Autor       : WFS
Data 	     : abr/2015
Obs         :
Revis�o     :
*/
Static Function AtuTRBAdiant(nRecNo)
Local aOrd:= SaveOrd({"TRB"})
Local lAchou:= .F.

Begin Sequence

   /* Procura na TRB a despesa de adiantametno correspondente � usada na compensa��o
      da despesa efetiva (arquivo de trabalho ADIANT). */ 
   TRB->(DBGoTop())
   While TRB->(!Eof()) .And. !lAchou

      If TRB->RECNO == nRecNo
         lAchou:= .T.
      Else
         TRB->(DBSkip())
      EndIf
   EndDo

   /* Atualiza os dados da despesa de adiantamento da TRB. */
   If lAchou
      TRB->(RecLock("TRB", .F.))
      TRB->WD_VL_COMP += nVlCompens
      TRB->(MsUnlock())
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return
