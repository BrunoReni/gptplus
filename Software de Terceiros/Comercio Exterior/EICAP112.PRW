#INCLUDE "Average.ch"
#Include "TOPCONN.ch"
#Include "EICAP112.ch"
/*
Programa  : EICAP112.PRW
Autor     : Jacomo 
Data      : 25/06/2014
Parametros: lEnvio  = se .T. indica se ir� enviar o XML, .F. indica que ser� recebimento
Uso       : 
*/
*--------------------------------------------------------------------*
Function EICAP112(lEnvio,nOpc,cHawb,nRecnoTRB,cTabAlias,cTipo,lVal)
*--------------------------------------------------------------------*
Local   lOk       := .T.                        
Default cTabAlias := 'SWB'
Default cTipo     := ""
Default lVal      := .F.
Private nRec      := 0    
Private cAlias    := cTabAlias   

SWB->(DBSETORDER(1))
IF lEnvio
    IF VALTYPE(nRecnoTRB) == "N" .AND. nRecnoTRB <> 0 .OR. cTabAlias == "TRB"
      nRec := nRecnoTRB
	  If Empty((cAlias)->WB_SEQBX)
	     lOk := .T.
      Else
	     lOk  := ProcIntegracao(nOpc) //EasyEnvEAI("EICAP112", nOpc) 
	  EndIf
   ELSE
      SWB->(DBSEEK(xFilial("SWB")+cHawb+"D"))
      DO WHILE SWB->(!EOF()) .AND. SWB->WB_FILIAL == xFilial("SWB") .AND. SWB->WB_HAWB == cHawb .AND. SWB->WB_PO_DI == "D"  
         IF (!EMPTY(cTipo)) .AND. Left(SWB->WB_TIPOREG,1) <> cTipo
            SWB->(DBSKIP())
            LOOP
         ENDIF
         IF lVal
            If AvFlags("EAI_PGANT_INV_NF")
            /* Se os t�tulos efetivos n�o foram integrados ou n�o foram compensados com o 608,
               n�o ser� necess�rio executar o estorno da compensa��o. Mesmo os t�tulos que foram
               baixados manualmente (evento 101) devem ser estornados, considerando que o usu�rio
               pode tentar alterar a taxa da DI/ Invoice. Caso os estornos n�o ocorram, os campos de
               taxas no processo apenas estar�o dispon�veis para altera��o ap�s execu��o das
               integra��es pendentes. */
               If Empty(SWB->WB_NUMDUP) .Or. EMPTY(SWB->WB_SEQBX)
                  SWB->(DBSKIP())
                  LOOP
               EndIf            
            EndIf
         ENDIF

         nRec := SWB->(RECNO())
         lOk  := ProcIntegracao(nOpc) //EasyEnvEAI("EICAP112",nOpc) 
         SWB->(DBSKIP())
      ENDDO
   ENDIF
ENDIF

/*Atualiza��o de status do processo de embarque/ desembara�o*/
AP110AtuStatus(cHawb)

RETURN lOk

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

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)
	
	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("SWB")
	oEasyIntEAI:SetModule("EIC",17)

	// Envio 
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "AP112SEND") //ENVIO                               (->Business)
	oEasyIntEAI:SetAdapter("RESPOND", "RESPONSE", "AP112RESP") //RESPOSTA SOBRE O ENVIO              (<-Response)
	// Envio 

	oEasyIntEAI:Execute()
	
Return oEasyIntEAI:GetResult() 
/* ====================================================*
* Fun��o: AP110SEND(oMessage)
* Objetivo: Envio das parcelas de Cambio
* Obs: 
* =====================================================*/
*------------------------------------------------*
Function AP112SEND(oMessage) 
*------------------------------------------------* 
Local oXml       := EXml():New()
Local oBusCont   := ENode():New()
Local oBusinReq  := ENode():New() 
Local oRec       := ENode():New()
Local aOrd       := {}

aOrd := SaveOrd({"SWA","SWB","SW2","EC6","SYF","SW6","SW9"}) 

EC6->(DBSETORDER(1))//EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC
EC6->(DBSEEK(xFilial("EC6")+"IMPORT"+IF((cAlias)->WB_EVENT == "608","101",(cAlias)->WB_EVENT) ))

   
oBusinReq:SetField("Operation"   ,"EICAP112")

oBusCont:SetField("CompanyId"         ,EICEmpFLogix())
oBusCont:SetField("BranchId"          ,EICFilFLogix())
oBusCont:SetField("DocumentPrefix"    ,EC6->EC6_PREFIX)

If !Empty((cAlias)->WB_CHAVE)
   SWB->(DBSeek(xFilial() + (cAlias)->WB_CHAVE)) /* Compensa��o - estorno do pagamento antecipado. */
   oBusCont:SetField("DocumentNumber"    ,SWB->WB_NUMDUP)
Else
   oBusCont:SetField("DocumentNumber"    , (cAlias)->WB_NUMDUP)
EndIf

oBusCont:SetField("DocumentParcel"    ,(cAlias)->WB_PARCELA)
oBusCont:SetField("DocumentTypeCode"  ,EC6->EC6_TPTIT)
oBusCont:SetField("VendorCode"        ,(cAlias)->WB_FORN)   
oBusCont:SetField("StoreId"           ,(cAlias)->WB_LOJA)   
oBusCont:SetField("DischargeSequence" ,(cAlias)->WB_SEQBX)   

oRec:SetField("BusinessRequest",oBusinReq)// OK
oRec:SetField("BusinessContent",oBusCont) //  OK
oXml:AddRec(oRec)

   
RestOrd(aOrd,.t.)

Return oXml


/* ====================================================*\
* Fun��o: AP110RESP(oMessage)                          *
* Objetivo: Resposta do Envio                          *
* Obs:                                                 *
\* ====================================================*/
*------------------------------------------------*
Function AP112RESP(oMessage)
*------------------------------------------------*
Local aOrd := SaveOrd({"SWB"}) 

IF cAlias == 'SWB'
   SWB->(DBGOTO(nRec)) 
   SWB->(RecLock("SWB",.F.))
ENDIF


(cAlias)->WB_SEQBX := ""

IF cAlias == 'SWB'
  SWB->(MSUNLOCK())
ENDIF

oMessage:AddInList("RECEIVE", {"Sucesso" , "Registro Gravado no Destino" , Nil})

RestOrd(aOrd,.t.)
Return oMessage

/*
Funcao      : ProcIntegracao
Par�metros  : nOpc - opera��o (inclus�o/ altera��o/ exclus�o)
Objetivos   : Executar a integra��o com o MsAguarde
Retorno     : L�gico: integrado/ n�o integrado
Autor       : WFS
Data 	     : Jan/2015
Obs         :
Revis�o     :
*/
Static Function ProcIntegracao(nOpc)
Local lRet:= .F.
   MsAguarde({|| lRet:= EasyEnvEAI("EICAP112", nOpc)}, STR0002) //"Integra��o EAI - Estorno da baixa. Aguarde..."
Return lRet

/*
Funcao      : AP112ValidSeqBaixa
Par�metros  :
Objetivos   : Garantir que o estorno da baixa/ compensa��o do c�mbio ocorra da �ltima para a
              primeira.
              Quando for estorno apenas da liquida��o, o sistema valida o preenchimento
              da sequencia da baixa antes de disparar a integra��o.
              Apenas quando for estorno da compensa��o deve ser verificado se existem outras
              compensa��es ou uma liquida��o do residual.  
Retorno     : L�gico: .T. - permite o estorno
Autor       : WFS
Data 	     : Fev/2015
Obs         :
Revis�o     :
*/
Function AP112ValidSeqBaixa()
Local lRet:= .T.
Local aArea:= GetArea()
Local aOrd:= SaveOrd({"SWB"})
Local cChave:= ""
Local cMsg:= "", cMsgAux:= ""
Local cQuery:= ""
Local cDelete:= ""
Local aEstorno:= {}
Local nCont

Begin Sequence

   SWB->(DBSetOrder(1)) //WB_FILIAL + WB_HAWB + WB_PO_DI + WB_INVOICE + WB_FORN + WB_LOJA + WB_LINHA   
   /* Verificar se � processo de c�mbio da fase de embarque/ desembara�o e se � um c�mbio
      antecipado usado para compensa��o. */
   If TRB->WB_PO_DI == "D" .And. Left(TRB->WB_TIPOREG,1) == "P"
   
      /* Uma vez que a integra��o via EAI ocorra, os dados s�o atualizados na base de dados.
         Desta forma, � poss�vel realizar as consultas diretamente na tabela. */
      /* Verificar se a parcela principal possui baixa n�o estornada. */
      SWB->(DBSeek(xFilial() + TRB->WB_CHAVE)) //WB_HAWB + WB_PO_DI + WB_INVOICE + WB_FORN + WB_LOJA + WB_LINHA

      If !Empty(SWB->WB_SEQBX)
         cMsg += MontaMsg(SWB->WB_EVENT, SWB->WB_CA_DT, SWB->WB_INVOICE, SWB->WB_NUMDUP, SWB->WB_PARCELA)
      EndIf

      /* Verificar se existem outras parcelas de adiantamento usadas na compensa��o da 
         parcela principal, com sequencia de baixa maior que a sequencia da parcela em
         processamento de estorno. */      
      If TcSrvType() <> "AS/400"
         cDelete:= "And WB.D_E_L_E_T_ <> '*'"
      EndIf
      cQuery:= "Select WB_SEQBX, WB_EVENT, WB_CA_DT, WB_INVOICE, WB_NUMDUP, WB_PARCELA " +;
               "From " + RetSqlName("SWB") + " WB " +;
               "Where WB_FILIAL = '" + SWB->(xFilial()) + "' " + cDelete + " " +;
               "And WB_CHAVE = '" + TRB->WB_CHAVE + "' And WB_SEQBX > '" + AllTrim(TRB->WB_SEQBX) + "'"

      cQuery:= ChangeQuery(cQuery)
   
      TcQuery cQuery Alias "LIQ" New
      TcSetField("LIQ", "WB_CA_DT", "D")
      
      /* Organizar em ordem decrescente. */
      LIQ->(DBGoTop())
      While LIQ->(!Eof())
         AAdd(aEstorno, {Val(LIQ->WB_SEQBX), LIQ->WB_EVENT, LIQ->WB_CA_DT, LIQ->WB_INVOICE, LIQ->WB_NUMDUP, LIQ->WB_PARCELA})
         LIQ->(DBSkip()) 
      EndDo
      LIQ->(DBCloseArea())
      If Len(aEstorno) > 0
         aSort(aEstorno,,, {|x, y| x[1] > y[1] })
      EndIf

      /* Montar a mensagem para o usu�rio. */
      For nCont:= 1 To Len(aEstorno)
         cMsg += MontaMsg(aEstorno[nCont][2], aEstorno[nCont][3], aEstorno[nCont][4], aEstorno[nCont][5], aEstorno[nCont][6])
      Next 

      If !Empty(cMsg)
         cMsgAux:= STR0003 + ENTER //"O estorno desta parcela n�o pode ser executado. Existem outras parcelas do fornecedor #### liquidadas/ compensadas que precisam ser estornadas antes. Verifique as parcelas:"
         cMsg:= StrTran(cMsgAux, "####", AllTrim(TRB->WB_FORN)) + cMsg
         MsgStop(cMsg, STR0001) //"Aten��o"
         lRet:= .F.
         Break
      EndIf 

   EndIf

End Sequence

RestArea(aArea)
RestOrd(aOrd, .T.)
Return lRet

/*
Funcao      : MontaMsg
Par�metros  : 1 - Evento, 2 - Data (no formado data), 3 - Invoice, 4  T�tulo, 5 - Parcela
Objetivos   : Gerar a estrutura da mensagem de retorno
Retorno     : cRet
Autor       : WFS
Data 	     : Mar/2015
Obs         :
Revis�o     :
*/
Static Function MontaMsg(cEvento, dData, cInvoice, cTitulo, cParcela)
Local cRet:= ""         
   
   cRet:= STR0004 //"- Evento: ####, data da liquida��o: $$$$, invoice: %%%%, t�tulo: &&&&, parcela: ****."
   cRet:= StrTran(cRet, "####", AllTrim(cEvento))
   cRet:= StrTran(cRet, "$$$$", DtoC(dData))
   cRet:= StrTran(cRet, "%%%%", AllTrim(cInvoice))
   cRet:= StrTran(cRet, "&&&&", AllTrim(cTitulo))
   cRet:= StrTran(cRet, "****", AllTrim(cParcela))
   cRet += ENTER

Return cRet
