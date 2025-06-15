#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRYEXCEPTION.CH"

Static lReprocessa  := .F.
Static dDtFis       := ""
Static oJson        := Nil 
Static nRecMhp      := 0

//--------------------------------------------------------
/*/{Protheus.doc} RmiReprocessa
Fun��o principal que executa o reprocessamento

@param 		N�o ha
@author  	Varejo
@version 	1.0
@since      22/09/2020
@return	    N�o ha
/*/
//--------------------------------------------------------
Function RmiReprocessa(cAssinante)

Local oError := Nil

Default cAssinante := ""

TRY EXCEPTION

    RmiSetRepc(.T.)
    dDtFis := RmiGetDt(cAssinante)

    If !Empty(dDtFis) .AND. Date() > dDtFis            
        CoNout("Iniciando o reprocessamento do dia " + DToS(dDtFis))
        LjGrvLog(" RmiReprocessa ", "Iniciando o reprocessamento do dia " + DToS(dDtFis))    

        //Inicia o reprocessamento
        RmiBusExec(cEmpAnt, cFilAnt, cAssinante, "REPROCESSA")   

        //Soma mais um na data para reprocessar o pr�ximo dia
        dDtFis := dDtFis + 1

        //Atualiza o objeto que cont�m o Json de envio
        oJson["UltimodiaReprocessado"] := SubStr(FWTimeStamp(1,dDtFis),1,8)
        LjGrvLog(" RmiReprocessa ", "Objeto UltimodiaReprocessado atualizado para " + oJson["UltimodiaReprocessado"])    
    
        //Atualiza o objeto para data de hoje para controle do UltimodiaReprocessado
        oJson["DataReprocessamento"] := DtoS(Date())

        LjGrvLog(" RmiReprocessa ", "Objeto DataReprocessamento atualizado para " + oJson["DataReprocessamento"])    

        //Atualiza o registro da MHQ com a atualiza��o do Json
        RmiAtlzMhp(oJson:ToJson(), nRecMhp)

        CoNout("Fim do reprocessamento!")
        LjGrvLog(" RmiReprocessa ", "Fim do reprocessamento")
    EndIf

    RmiSetRepc(.F.)
    FwFreeObj(oJson)

//Se ocorreu erro
CATCH EXCEPTION USING oError
    
    //Seta o reprocessamento para .F.
    RmiSetRepc(.F.)

    CoNout("Ocorreu um erro no reprocessamento - " + oError:DESCRIPTION)
    LjGrvLog(" RmiReprocessa ", "Ocorreu um erro no reprocessamento - " + oError:DESCRIPTION)

ENDTRY

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} RmiGetDt
Fun��o que sera executada antes de chamar a fun��o de reprocessamento,
essa fun��o tem como objetivo retornar a data inicial do reprocessamento.

@param 		N�o ha
@author  	Varejo
@version 	1.0
@since      22/09/2020
@return	    N�o ha
/*/
//--------------------------------------------------------
Static Function RmiGetDt(cAssinante)

Local cQuery    := "" //Armazena a query
Local cAlias    := GetNextAlias() //Alias temporario
Local dRet      := "" //Variavel de retorno
Local dDatFis   := SuperGetMv("MV_DATAFIS",,"")

Default cAssinante := ""

cQuery := "SELECT MHP.R_E_C_N_O_ RECMHP "
cQuery += "  FROM " + RetSqlName("MHO") + " MHO "
cQuery += "       INNER JOIN " + RetSqlName("MHP") + " MHP ON MHO_FILIAL = MHP_FILIAL "
cQuery += "	                        AND MHO_COD = MHP_CASSIN "
cQuery += "							AND MHP_ATIVO = '1' "
cQuery += "							AND MHP.D_E_L_E_T_ = ' ' "
cQuery += " WHERE MHO_FILIAL = '" + xFilial("MHO") + "'"
cQuery += "   AND MHO.D_E_L_E_T_ = ' ' "
cQuery += "   AND MHP_TIPO = '2' "
cQuery += "   AND MHO_COD = '" + cAssinante + "'"
cQuery += "   AND MHP_CPROCE = 'VENDA'"

DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

If !(cAlias)->( Eof() )

    //Cria o objeto Json para receber o Json de envio
    oJson   := JsonObject():New()
    nRecMhp := (cAlias)->RECMHP 
    MHP->(dbGoto(nRecMhp))

    If !Empty(MHP->MHP_LAYENV)
        oJson:FromJson( AllTrim(MHP->MHP_LAYENV) )
        
        If oJson:hasProperty("DataReprocessamento") .and. Date() > StoD(oJson["DataReprocessamento"])

            If oJson["UltimodiaReprocessado"] == NIL
                oJson["UltimodiaReprocessado"] := DtoS(Date())
                LjGrvLog(" RmiGetDt ", "A propriedade UltimodiaReprocessado foi criada com a data de hoje " + oJson["UltimodiaReprocessado"])   
            EndIF
        
            If oJson:hasProperty("DiasRetroceder")
                dRet := StoD(oJson["UltimodiaReprocessado"]) - oJson["DiasRetroceder"]
            Else
                LjGrvLog(" RmiGetDt ", "A propriedade DiasTroceder n�o existe o default ser� 60 dias!")
                dRet := StoD(oJson["UltimodiaReprocessado"]) - 60
            EndIF                    

            //Se a data da tag for maior que a datafis eu reprocesso a partir do parametro
            If !Empty(dRet) 
                If dRet < dDatFis
                    dRet := dDatFis         
                    LjGrvLog(" RmiGetDt ", "A propriedade DataReprocessamento � maior que a data do parametro MV_DATAFIS, come�aremos apartir do parametro: " + DtoS(dDatFis))   
                EndIf             
            EndIf
        else
            dRet := StoD(oJson["UltimodiaReprocessado"])
        EndIf

    EndIf
EndIf

(cAlias)->( DbCloseArea() )

Return dRet

//--------------------------------------------------------
/*/{Protheus.doc} RmiAtlzMhp
A cada reprocessamento, entra nessa fun��o para atualizar o Json
de envio com a nova data de reprocessamento que � gravada no layout
de envia atrav�s da TAG DataReprocessamento

@param 		N�o ha
@author  	Varejo
@version 	1.0
@since      22/09/2020
@return	    N�o ha
/*/
//--------------------------------------------------------
Function RmiAtlzMhp(cJson, nRecno)

Local aArea := GetArea() //Guarda a area

Default cJson := ""

MHP->(dbGoto(nRecno))

If RecLock("MHP",.F.)
    MHP->MHP_LAYENV := cJson
    MHP->(MsUnlock())
EndIf

RestArea(aArea)

Return Nil


//--------------------------------------------------------
/*/{Protheus.doc} RmiGetRepc
Fun��o para retornar o valor da variavel lReprocessa

@param 		N�o ha
@author  	Varejo
@version 	1.0
@since      10/09/2020
@return	    N�o ha
/*/
//--------------------------------------------------------
Function RmiGetRepc()
Return lReprocessa

//--------------------------------------------------------
/*/{Protheus.doc} RmiSetRepc
Fun��o para setar valor a variavel lReprocessa

@param 		lReproc -> Conte�do a ser atribuido a variavel lReprocessa
@author  	Varejo
@version 	1.0
@since      10/09/2020
@return	    N�o ha
/*/
//--------------------------------------------------------
Function RmiSetRepc(lReproc)

Default lReproc := .F.

lReprocessa := lReproc

Return Nil


//--------------------------------------------------------
/*/{Protheus.doc} RmiGetDt
Fun��o para retornar a data a ser reprocessada

@param 		N�o ha
@author  	Varejo
@version 	1.0
@since      10/09/2020
@return	    N�o ha
/*/
//--------------------------------------------------------
Function RmiGetDate()
Return dDtFis


//--------------------------------------------------------
/*/{Protheus.doc} RmiMarkSale
Fun��o responsavel em pesquisar a venda, distribui��o ou
publica��o, caso alguma dessas etapas esteja com erro,
ent�o � marcado automaticamente pare realizar o reprocessamento

@param 		N�o ha
@author  	Varejo
@version 	1.0
@since      30/09/2020
@return	    N�o ha
/*/
//--------------------------------------------------------
Function RmiMarkSale(cUuid)

Local cQuery := "" //Armazena a query
Local cAlias := "" //Guarda o proximo alias

Default cUuid := ""

If AllTrim(MHQ->MHQ_CPROCE) == "VENDA" .AND. AllTrim(MHQ->MHQ_ORIGEM) == "CHEF"
    If AllTrim(MHQ->MHQ_STATUS) == "3"
        LjGrvLog(" RmiReprocessa ", "Encontrado erro na publica��o, vai atualizar a MHQ - UUID " + cUuid)
        RmiUpdMhq()
    Else

        //Pesquisando a venda
        cAlias := GetNextAlias()

        cQuery := "SELECT R_E_C_N_O_ REC "
        cQuery += "  FROM " + RetSqlName("SL1")
        cQuery += " WHERE L1_UMOV = '" + cUuid + "'"
        cQuery += "   AND L1_SITUA IN ('IR','ER')"

        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

        If !(cAlias)->( Eof() )
            LjGrvLog(" RmiReprocessa ", "Encontrado erro na venda, vai atualizar a MHQ - UUID " + cUuid)
            RmiUpdMhq()
            (cAlias)->( DbCloseArea() )
            Return Nil
        Else        
            (cAlias)->( DbCloseArea() )
            cQuery := ""
        EndIf    

        //Pesquisando a distribui��o
        cAlias := GetNextAlias()

        cQuery := "SELECT R_E_C_N_O_ REC "
        cQuery += "  FROM " + RetSqlName("MHR")
        cQuery += " WHERE MHR_UIDMHQ = '" + cUuid + "'"
        cQuery += "   AND MHR_STATUS = '3'"

        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

        If !(cAlias)->( Eof() )
            LjGrvLog(" RmiReprocessa ", "Encontrado erro na distribui��o, vai atualizar a MHQ - UUID " + cUuid)
            RmiUpdMhq()
        EndIf

        (cAlias)->( DbCloseArea() )
    EndIf
EndIf

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} RmiUpdMhq
Fun��o responsavel em atualizar o status da MHQ para 4
para realizar o reprocessamento

@param 		N�o ha
@author  	Varejo
@version 	1.0
@since      30/09/2020
@return	    N�o ha
/*/
//--------------------------------------------------------
Function RmiUpdMhq()
Local aArea     := GetArea() 
Local aAreaMHQ  := MHQ->(GetArea())

If RecLock("MHQ",.F.)
    LjGrvLog(" RmiReprocessa ", "Vai atualizar a MHQ para status 4 para reprocessar - UUID " + MHQ->MHQ_UUID)
    MHQ->MHQ_STATUS := "4"
    MHQ->(MsUnlock())
EndIf
//Verifico se Origem � cancelamento existe Cancelamento troco para Status 4 a linha que foi gerado automaticamente pelo Grava()
If MHQ->MHQ_EVENTO = '2' .AND. MHQ->( DbSeek(MHQ->MHQ_FILIAL + MHQ->MHQ_ORIGEM + MHQ->MHQ_CPROCE +MHQ->MHQ_CHVUNI + '1') )
    If RecLock("MHQ",.F.)
        LjGrvLog(" RmiReprocessa ", "Vai atualizar a MHQ para status 4 para reprocessar - UUID " + MHQ->MHQ_UUID)
        MHQ->MHQ_STATUS := "4"
        MHQ->(MsUnlock())
    EndIf
EndIf

RestArea(aAreaMHQ)
RestArea(aArea)
Return Nil
