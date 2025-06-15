#Include "GTPA903B.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA903B
Efetivação da apuração e envio para medição do contrato CNTA121
@type Function
@author 
@since 06/04/2021
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GTPA903B()
Local cCorApura := ""
Local cMsgErro  := ""
Local cMsgSol   := ""
Local lRet      := .T.

If GQR->GQR_STATUS == "2"
    FwAlertHelp(STR0005, STR0004,) //"Atenção" //"Status deve estar em apuração para gerar a medição"
    Return .F.
Endif

If !ValidaVig(GQR->GQR_CODIGO, @cMsgErro, @cMsgSol)
    FwAlertHelp(cMsgErro, cMsgSol)
    Return .F.
Endif

If !IsBlind()
    If MsgYesNo(STR0001,STR0002) //'Deseja gerar a medição da apuração' //'Atenção!'
        cCorApura := GQR->GQR_CODIGO//Deixado assim para testes

        If ValidDocs(GQR->GQR_CODIGO)
            FwMsgRun(,{|| PreparaMed(cCorApura,@lRet) },,STR0003 ) //"Gerando medição..."
            AtualContr(cCorApura,lRet)
        Endif

    EndIf
Else
    cCorApura := GQR->GQR_CODIGO//Deixado assim para testes
    FwMsgRun(,{|| PreparaMed(cCorApura,@lRet) },,STR0003 ) //"Gerando medição..."
    AtualContr(cCorApura,lRet)
EndIf

Return lRet

/*/{Protheus.doc} AtualContr
(long_description)
@type  Static Function
@author user
@since 12/04/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function AtualContr(cCorApura,lRet)
Local aArea := GetArea()

DbSelectArea("GQR")
DbSetOrder(1)
If GQR->(DbSeek(xFilial("GQR") + cCorApura))
    If lRet
        RecLock("GQR",.F.)
        GQR->GQR_STATUS := "2"
        GQR->(MsUnLock())
    Else
        RecLock("GQR",.F.)
        GQR->GQR_STATUS := "3"
        GQR->(MsUnLock())
    EndIf
EndIf
RestArea(aArea)

Return 
/*/{Protheus.doc} PreparaMed
(long_description)
@type  Static Function
@author user
@since 30/05/2023
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function PreparaMed(cCorApura,lRet)
Local cAliasTmp := ""  
Local aDados    := {}
Local nLinMed   := 0

Default cCorApura := ""
Default lRet      := .T.
     
    cAliasTmp := QueryOrc(cCorApura)

    While (cAliasTmp)->(!Eof())
        AADD(aDados,{(cAliasTmp)->G54_CODGQR,; //1
                    (cAliasTmp)->GY0_CODCN9,; //2
                    (cAliasTmp)->G54_PRODNT,; //3
                    (cAliasTmp)->G54_TIPCNR,; //4
                    (cAliasTmp)->G54_DESCRI,; //5
                    (cAliasTmp)->G54_VLFIXO,; //6
                    (cAliasTmp)->GYD_CLIENT,; //7
                    (cAliasTmp)->GYD_LOJACLI,;//8
                    (cAliasTmp)->TOTLIN,;     //9  
                    (cAliasTmp)->TOTLEXT,;    //10
                    (cAliasTmp)->G54_NUMGY0,; //11
                    (cAliasTmp)->G54_CODGI2,; //11
                    })  
        (cAliasTmp)->(DbSkip())  
    EndDo
      
    For nLinMed:= 1 To Len(aDados)
        cNumMed:= ''
        Begin Transaction
            cNumMed:= GeraMed(aDados[nLinMed]) 
            If !lRet
                DisarmTransaction()
                FwAlertHelp('Atenção','Erro ao gerar medição')
            EndIf
        End Transaction 
        If !Empty(cNumMed)  
                lRet:= AtuCont(cNumMed,aDados[nLinMed]) 
            Else
                lRet := .F.
        Endif
    Next
    

Return lRet


/*/{Protheus.doc} GeraMed
Função para gerar a medição com base na apuração passada
@type  Static Function
@author user
@since 08/04/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GeraMed(aDados)
Local oModel    := Nil
Local cNumMed   := ""
Local aMsgDeErro:= {}
Local lRet      := .F. 

CN9->(DbSetOrder(1))
If CN9->(DbSeek(xFilial("CN9") + aDados[2]))//Posicionar na CN9 para realizar a inclusão
    oModel := FWLoadModel("CNTA121")
    
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    If(oModel:CanActivate())           
        oModel:Activate()
        oModel:SetValue("CNDMASTER","CND_CONTRA"    ,CN9->CN9_NUMERO)
        oModel:SetValue("CNDMASTER","CND_RCCOMP"    ,"1")//Selecionar competência
        oModel:SetValue("CNRDETAIL1","CNR_TIPO"     , aDados[4])//1=Multa/2=Bonificação
        oModel:SetValue("CNRDETAIL1","CNR_DESCRI"   , aDados[5])
        oModel:SetValue("CNRDETAIL1","CNR_VALOR"    , aDados[6])

        oModel:GetModel('CXNDETAIL'):Goline(1)
        If oModel:GetModel('CXNDETAIL'):SeekLine({{'CXN_FORCLI',aDados[7]},{'CXN_LOJA',aDados[8]}})
            If  oModel:GetModel('CXNDETAIL'):GetValue('CXN_CONTRA') == aDados[2]
                oModel:SetValue("CXNDETAIL","CXN_CHECK" , .T.)
                oModel:GetModel('CNEDETAIL'):LoadValue('CNE_ITEM', PadL(1, CNE->(Len(CNE_ITEM)), "0"))//Adiciona um item a planilha           
                oModel:SetValue( 'CNEDETAIL' , 'CNE_PRODUT' , aDados[3])
                oModel:SetValue( 'CNEDETAIL' , 'CNE_QUANT'  , 1) // Qtd. deve ser sempre 1, pq o agrupamento de linhas pode conter linhas com unidades e valores 
                oModel:SetValue( 'CNEDETAIL' , 'CNE_VLUNIT' , aDados[9])
            EndIf
            If !(EMPTY(aDados[8]))//Quando tiver valor extra adicionar mais uma linha com o mesmo produto
                If !oModel:GetModel('CNEDETAIL'):IsEmpty() 
                    oModel:GetModel('CNEDETAIL'):AddLine()
                EndIf
                oModel:GetModel('CNEDETAIL'):LoadValue('CNE_ITEM', PadL(2, CNE->(Len(CNE_ITEM)), "0"))//Adiciona um item a planilha           
                oModel:SetValue( 'CNEDETAIL' , 'CNE_PRODUT' , aDados[3])
                oModel:SetValue( 'CNEDETAIL' , 'CNE_QUANT'  , 1) // Qtd. deve ser sempre 1, pq o agrupamento de linhas pode conter linhas com unidades e valores 
                oModel:SetValue( 'CNEDETAIL' , 'CNE_VLUNIT' , aDados[10])
            EndIf
        EndIf
      
        If (oModel:VldData()) /*Valida o modelo como um todo*/
            oModel:CommitData()
        EndIf
    EndIf
    
    If(oModel:HasErrorMessage())
        aMsgDeErro := oModel:GetErrorMessage()
        FwAlertHelp(aMsgDeErro[5], aMsgDeErro[6])
    Else
        cNumMed := CND->CND_NUMMED
        //Adicionar o código da medição no contrato          
        oModel:DeActivate()        
        lRet := CN121Encerr(.T.) //Realiza o encerramento da medição                   
    EndIf
EndIf  

Return cNumMed

/*/{Protheus.doc} AtuCont
Query para retornar os dados da apuração e orçamento para a medição
@type  Static Function
@author user
@since 08/04/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function AtuCont(cNumMed,aDados)
Local aArea := GetArea()
Local lRet  := .F.

If Len(aDados) > 0 
    DbSelectArea("G54")
    DbSetOrder(1)
    If !Empty(cNumMed)
        If G54->(DbSeek(xFilial("G54") + aDados[1] + aDados[11] +  aDados[12]))
            RecLock("G54",.F.)
            G54->G54_CODCND := cNumMed
            G54->(MsUnLock())
            lRet:= .T.
        EndIf
    EndIf
EndIf

RestArea(aArea)
Return lRet

/*/{Protheus.doc} QueryOrc
Query para retornar os dados da apuração e orçamento para a medição
@type  Static Function
@author user
@since 08/04/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function QueryOrc(cCorApura)
Local cAliasAUX := ''

Default cCorApura := ''

cAliasAUX := GetNextAlias()

    BeginSQL alias cAliasAUX
  SELECT        GYD.GYD_CLIENT,
                GYD.GYD_LOJACL,
                GY0.GY0_CODCN9, 
                G54.G54_CODGQR, 
                G54.G54_NUMGY0,
                G54.G54_TIPCNR,
        	    G54.G54_DESCRI,
        	    G54.G54_PRODNT,
                G54.G54_VLFIXO,
                G54.G54_CODGI2,
                ((G54.G54_QTDCON * G54.G54_VLRCON) + G54.G54_VLRACO) AS TOTLIN,
                ((G54.G54_QTDEXT * G54.G54_VLREXT)) AS TOTLEXT
        FROM
            %Table:GQR% GQR
            INNER JOIN
                %Table:G9W% G9W
                ON
                    G9W.G9W_FILIAL     = GQR.GQR_FILIAL
                    AND G9W.G9W_CODGQR = GQR.GQR_CODIGO
                    AND G9W.%NotDel%
            INNER JOIN
                %Table:G54% G54
                ON
                    G54.G54_FILIAL     = GQR.GQR_FILIAL
                    AND G54.G54_CODGQR = G9W.G9W_CODGQR
                    AND G54.G54_NUMGY0 = G9W.G9W_NUMGY0
                    AND G54.G54_REVISA = G9W.G9W_REVISA
                    AND G54.%NotDel%
            INNER JOIN 
                %Table:GY0% GY0
                ON
                    GY0.GY0_FILIAL      = G54.G54_FILIAL
                    AND GY0.GY0_NUMERO  = G54.G54_NUMGY0 
                    AND GY0.GY0_REVISA  = G54.G54_REVISA
                    AND GY0.%NotDel%
            INNER JOIN 
                %Table:GYD% GYD
                ON
                    GYD.GYD_FILIAL      = G54.G54_FILIAL
                    AND GYD.GYD_NUMERO  = G54.G54_NUMGY0 
                    AND GYD.GYD_CODGI2  = G54.G54_CODGI2
                    AND GYD.%NotDel%
        WHERE
            GQR.GQR_FILIAL     = %xFilial:GQR%
            AND GQR.GQR_CODIGO = %exp:cCorApura%
            AND GQR.%NotDel%
    EndSql

Return cAliasAUX



/*/{Protheus.doc} ValidDocs(codApura)	
Valida pendência de checklist dos documentos operacionais do contrato
@author flavio.martins
@since 30/08/2022
@version 1.0
@return lógico
@type function
/*/
Static Function ValidDocs(codApura)
Local lRet 	:= .T.

Default codApura := ''

UpdateDocs(GQR->GQR_CODIGO)

If ExistDocs(codApura)

	If FwAlertYesNo(STR0009, STR0004) // "Encontrado documentos obrigatórios para a apuração. Deseja realizar o checklist agora ? ", "Atenção"
		GTPA903D()
	Endif

	If ExistDocs(codApura)
		lRet := .F.
		FwAlertWarning(STR0010) // "A medição não poderá ser realizada até que os documentos exigidos sejam validados.", "Atenção"
	Endif

Endif

Return lRet

/*/{Protheus.doc} ExistDocs(codApura)	
Verifica se existem documentos pendentes de checklist
@author flavio.martins
@since 30/08/2022
@version 1.0
@return lógico
@type function
/*/
Static Function ExistDocs(codApura)
Local lRet 		:= .T.
Local cAliasTmp	:= GetNextAlias()

Default codApura := ''

BeginSql Alias cAliasTmp 

    SELECT COALESCE(COUNT(H69_NUMERO), 0) AS TOTREG
    FROM %Table:G9W% G9W
    INNER JOIN %Table:H69% H69 ON H69.H69_FILIAL = %xFilial:H69%
    AND H69.H69_NUMERO = G9W.G9W_NUMGY0
    AND H69.H69_REVISA = G9W.G9W_REVISA
    AND H69.H69_EXIGEN IN ('2','3')
    AND H69.H69_CHKLST = 'F'
    AND H69.%NotDel%
    WHERE G9W.G9W_FILIAL = %xFilial:G9W%
      AND G9W.G9W_CODGQR = %Exp:codApura%
      AND G9W.%NotDel%

EndSql

lRet := (cAliasTmp)->TOTREG > 0

(cAliasTmp)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} ValidaVig()
Verifica se a medição está dentro da vigência do contrato
@author flavio.martins
@since 16/02/2023
@version 1.0
@return lógico
@type function
/*/
Static Function ValidaVig(cCodApura, cMsgErro, cMsgSol)
Local lRet := .T.
Local cAliasTmp := GetNextAlias()

BeginSql Alias cAliasTmp

    SELECT G9W_CONTRA
    FROM %Table:G9W%
    WHERE G9W_FILIAL = %xFilial:G9W%
      AND G9W_CODGQR = %Exp:cCodApura%
      AND %NotDel%

EndSql

dbSelectArea('CN9')
CN9->(dbSetOrder(7))

While ((cAliasTmp)->(!Eof()))

    If CN9->(dbSeek(xFilial('CN9')+(cAliasTmp)->G9W_CONTRA+'05'))

        lRet := ((dDataBase >= CN9->CN9_DTINIC) .And. (dDataBase <= CN9->CN9_DTFIM))

    Endif

    If !lRet
  		cMsgErro := I18n(STR0011, {(cAliasTmp)->G9W_CONTRA}) // "Data atual do sistema fora da vigência do contrato #1"
  		cMsgSol  := STR0012                                  // "Altere a data do sistema para uma data dentro da vigência do contrato"
        Exit
    Endif

    (cAliasTmp)->(dbSkip())

EndDo

(cAliasTmp)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} UpdateDocs(codApura)
Atualiza os status dos documentos exigidos na apuração
@author flavio.martins
@since 16/02/2023
@version 1.0
@return lógico
@type function
/*/
Static Function UpdateDocs(codApura)
Local cAliasTmp	:= GetNextAlias()

Default codApura := ''

BeginSql Alias cAliasTmp 

    SELECT H69.R_E_C_N_O_ as RECNO
    FROM %Table:G9W% G9W
    INNER JOIN %Table:H69% H69 ON H69.H69_FILIAL = %xFilial:H69%
    AND H69.H69_NUMERO = G9W.G9W_NUMGY0
    AND H69.H69_REVISA = G9W.G9W_REVISA
    AND H69.H69_EXIGEN IN ('2','3')
    AND H69.%NotDel%
    WHERE G9W.G9W_FILIAL = %xFilial:G9W%
      AND G9W.G9W_CODGQR = %Exp:codApura%
      AND G9W.%NotDel%

EndSql

dbSelectArea('H69')

While (cAliasTmp)->(!Eof())
    H69->(dbGoto((cAliasTmp)->RECNO))
    RecLock('H69', .F.)
        H69->H69_CHKLST := .F.
    H69->(MsUnLock())
    (cAliasTmp)->(dbSkip())

EndDo

(cAliasTmp)->(dbCloseArea())

Return
