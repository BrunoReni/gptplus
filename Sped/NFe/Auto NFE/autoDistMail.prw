#INCLUDE 'PROTHEUS.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"

#DEFINE LOG_ERROR 	1
#DEFINE LOG_WARNING 2
#DEFINE LOG_INFO 	3
#DEFINE LOG_PRINT	4

static __init
static __lInfo		  := GetSrvProfString("ERPLOGINFO", "0" ) == "1"
static __lWarning	  := GetSrvProfString("ERPLOGWARNING", "0" ) == "1"

/*/{Protheus.doc} DistMail
    JOB respons�vel por processar a distribui��o de danfe por email 
    para o TSS junto com a danfe gerada no protheus
    @type  Function
    @author Bruno Seiji
    @since 30/05/2019
    @version 12.1.17
/*/
main function DistMail(cSleep)

    Local cAliasProc    := ""
    Local nSleep        := 0
    Local cLock         := ""
    Local cConfig       := ""
    Local lSendCte		:= ExistFunc("ProcSendCte")
    Default cSleep := "60"

    if( !empty( cConfig := alltrim(GetPvProfString("DISTMAIL", "MODO", "",  GetAdv97()) ) ) ) .and. val(cConfig) == 1
        PRTMSG("Habilitado execucao atraves de schedule", LOG_PRINT)

    else
        If validPrinter()
            nSleep := val(cSleep) * 1000 //conversao para milisegundos

            PRTMSG("Verificando estrutura da tabela DISTMAIL", LOG_PRINT)
            createThreads()//Cria pool de Threads para processamento dos emails
            crtTblMail()//cria o banco sqlite
            startjob( "fillTblMail", getEnvserver(), .F.)//cadastro das empresas para envio de email
            cAliasProc := getNextAlias()

            while !killApp()
                
                if dbSqlExec(cAliasProc, "SELECT * FROM DISTMAIL WHERE EMPRESA != ' ' AND FILIAL != ' ' AND ENTIDADE != ' ' AND URL != ' ' AND ENABLE = 1 ", "SQLITE_SYS")
                    while !(cAliasProc)->(EOF())
                        cLock := "procSendMail-" + alltrim((cAliasProc)->EMPRESA) + alltrim((cAliasProc)->FILIAL)
                        if( !jobIsRunning( cLock ) )
                            if !ERPIPCGO("procSendMail", .F., "IPC_DISTMAIL", (cAliasProc)->EMPRESA, (cAliasProc)->FILIAL, (cAliasProc)->ENTIDADE, cLock )                      
                                smartjob( "procSendMail", getEnvserver(), .F., (cAliasProc)->EMPRESA, (cAliasProc)->FILIAL, (cAliasProc)->ENTIDADE, cLock )
                            endif
                        endif
	                    
                        If lSendCte
                            cLock := "ProcSendCte-" + AllTrim((cAliasProc)->EMPRESA) + alltrim((cAliasProc)->FILIAL)
                            If( !jobIsRunning( cLock ) )
                                If !ERPIPCGO("ProcSendCte", .F., "IPC_DISTMAIL", (cAliasProc)->EMPRESA, (cAliasProc)->FILIAL, (cAliasProc)->ENTIDADE, cLock )
                                    SmartJob( "ProcSendCte", getEnvserver(), .F., (cAliasProc)->EMPRESA, (cAliasProc)->FILIAL, (cAliasProc)->ENTIDADE, cLock )
                                EndIf
                            EndIf
                        EndIf
	                    
                        (cAliasProc)->(DbSkip())
                    end
                    sleep(nSleep)
                endif
                
                if select( (cAliasProc) ) > 0
                    (cAliasProc)->(DBCloseArea())
                endif            
            enddo

        endif
    endif

return

/*/{Protheus.doc} procSendMail
    Fun��o respons�vel por executar o processo a partir da chamada do smartjob
    @type  Function
    @author Bruno Seiji
    @since 30/05/2019
    @version 12.1.17
    @param entidade Entidade que ser� processada
/*/
function procSendMail(cEmp, cFil, cEntidade, cLock)

    local aNfe
    local lContinua :=  .T.
    local nSequencia
    local nHdl

    nHdl := jobSetRunning( cLock, .T.) 
    if(nHdl < 0 )
        PRTMSG("Falha ao alocar processo - " + cLock, LOG_ERROR)
        return
    endif

    cEmp := alltrim(cEmp)
    cFil := alltrim(cFil)
    cEntidade := alltrim(cEntidade)

    RPCSetType(3) //Nao faz consumo de licen�a
    if RPCSetEnv(cEmp, cFil, Nil, Nil, "FAT")
        while(lContinua)
            //efetua consulta das NFe que seram processadas
            PRTMSG("Consultando E-mails pendentes. Empresa: " + cEmp + " Filial: " + cFil, LOG_PRINT)
            aNfe := consNfeDnf(cEmp, cFil, @lContinua, @nSequencia)
            if !empty(aNfe)
                //processo de cria��o e distribui��o da DANFE
                PRTMSG("Excutando distribuicao dos E-mails pendentes. Empresa: " + cEmp + " Filial: " + cFil + " Total de Notas: " + alltrim(str(len(aNfe))), LOG_PRINT)
                distNfeDnf(cEmp, cFil, cEntidade, aNfe)
                //incremento para trocar "pagina" da consulta se houver mais resultados a serem consultados
            endif
        endDo

    endif

    jobSetRunning( cLock, .F., nHdl) 
    RpcClearEnv()

    DelClassIntf()  
    
return

/*/{Protheus.doc} crtTblMail
    Fun��o respons�vel por criar a tabela de distribui��o de danfe por email 
    @type  Function
    @author Bruno Seiji
    @since 30/05/2019
    @version 12.1.17
/*/
function crtTblMail()

    Local aStruct := {}
    Local cJobFile := "DISTMAIL"
    Local cAlias := getNextAlias()

    /*-------------------------------------------- 
        Define a estrutura da tabela DISTMAIL
    --------------------------------------------*/ 
    aAdd(aStruct,{"ENTIDADE"    ,	"C", 6, 00})
    aAdd(aStruct,{"URL"         ,	"C", 200, 00})
    aAdd(aStruct,{"ENABLE"      ,	"N", 1, 00})
    aAdd(aStruct,{"EMPRESA"     ,	"C", 15, 00})
    aAdd(aStruct,{"FILIAL"      ,	"C", 15, 00})
	    
    If !DBSqlExec(cAlias, "SELECT ENTIDADE FROM DISTMAIL", 'SQLITE_SYS')
        DBCreate( cJobFile , aStruct, 'SQLITE_SYS' )
    Else
        (cAlias)->(DBCloseArea())
    EndIf
    
    //DBUseArea( .T., 'SQLITE_SYS', cJobFile , 'DISTMAIL', .F., .F. )
    //If Select("DISTMAIL") == 0
    cAlias := getNextAlias()
    If !DBSqlExec(cAlias, "SELECT ENTIDADE FROM DISTMAIL", 'SQLITE_SYS')
         PRTMSG( "Nao foi possivel criar base de distribuicao de email(DISTMAIL), diretorio invalido informado em RootPath: '"+GetSrvProfString("RootPath","")+"' FError:"+str(FError(),4), LOG_ERROR)
         return .F.      
    EndIf
    (cAlias)->(DBCloseArea())

return .T.

/*/{Protheus.doc} fillTblMail
    Fun��o responsavel por popular a tabela de controle do job de distribui��o 
    @type  Function
    @author Bruno Seiji
    @since 30/05/2019
    @version 12.1.17
/*/
function fillTblMail()

    local aFiliais  := {}
    local aParams   := {}
    local oWSParam  := nil
    local nX        := 0
    local nEnable   := 0
    local cFiliais  := ""
    local cLock     := "fillTblMail"
    local nHdl      := 0
    local cLog      := ""
    Local lMonitor  := ExistFunc("FwMonitorMsg")

    nHdl := jobSetRunning( cLock, .T.) 
    if(nHdl < 0 )
        PRTMSG("Leitura de empresas e filiais j� esta sendo realizado por outro processo.", LOG_INFO)
        return
    endif

    //abre o sigamat para ler todas empresas registradas e que n�o est�o deletadas
    PRTMSG("Realizando leitura de empresas e filiais", LOG_PRINT)
    set deleted on
    openSM0()
    aFiliais := fwLoadSM0()

    cLog := "Inicializando cadastro/atualizacao de distribuicao de email(DISTMAIL).  Total de empresas/filiais: " + alltrim(str(len(aFiliais)))
    PRTMSG(cLog, LOG_PRINT)
    If lMonitor
        FWMonitorMsg(cLog)
    EndIf

    if len(aFiliais) > 0

        while len(aFiliais) > countDISTMAIL()
            RPCSetType(3) //Nao faz consumo de licen�a
            RPCSetEnv(aFiliais[1][1], aFiliais[1][2], Nil, Nil, "FAT")
            cEmpAnt := aFiliais[1][1]
            for nX := 1 to len(aFiliais)
                //posiciona nas filias para efetuar a troca e recuperar o parametro de cada uma        
                if( !aFiliais[nX][1] == cEmpAnt )            
                    RESET ENVIRONMENT
                    RPCSetType(3)
                    RPCSetEnv(aFiliais[nX][1], aFiliais[nX][2], Nil, Nil, "FAT") 
                    cEmpAnt := aFiliais[nX][1]
                endif

                cFilAnt     := aFiliais[nX][2]
                SM0->(dbSeek(cEmpAnt + cFilAnt))

                cLog := "Cadastrando empresas/filiais: " + cEmpAnt  + "/" + cFilAnt + "."
                PRTMSG(cLog, LOG_PRINT)
                If lMonitor
                    FWMonitorMsg(cLog)
                EndIf

                cURLSPED    := getNewPar("MV_SPEDURL","", )
                cFiliais := "[" + FWJsonSerialize(aFiliais[nX]) + "]"
                
                if(empty(cURLSPED))
                    insertDist("", 0, "", cEmpAnt, cFilAnt)
                else
                    oWSParam                := WSSPEDCfgNFe():New()
                    oWSParam:cUSERTOKEN     := "TOTVS"
                    oWSParam:_URL           := AllTrim( cURLSPED ) + "/SPEDCFGNFe.apw"
                    oWSParam:CLISTFILIAIS   := cFiliais

                    if oWSParam:GETAUTODIST() 
                        if( empty(oWSParam:oWSGETAUTODISTRESULT:OWSCFGAUTODIST))
                            insertDist("", 0, "", cEmpAnt, cFilAnt)
                        else                        
                            aParams := oWSParam:oWSGETAUTODISTRESULT:OWSCFGAUTODIST
                            nEnable := iif( aParams[1]:LENABLE, 1, 0 )
                            insertDist(aParams[1]:CENTIDADE,nEnable,cURLSPED,aParams[1]:CEMPRESA, aParams[1]:CFILIAL)
                        endif
                    else
                        insertDist("", 0, "", cEmpAnt, cFilAnt)
                    endif            
                endif
            next
        end   
    endif

    fwFreeObj(aFiliais)
    fwFreeObj(aParams)
    fwFreeObj(oWSParam)
    
    PRTMSG("Finalizado cadastro/atualizacao de distribuicao de email(DISTMAIL)", LOG_PRINT)

    jobSetRunning( cLock, .F., nHdl) 

return

/*/{Protheus.doc} insertDist
    Fun��o respons�vel por incluir ou alterar o registro no 
    banco da tabela de distribui��o de danfe por email
    @type  Function
    @author Bruno Seiji
    @since 30/05/2019
    @version 12.1.17
    @param cEntidade    - Entidade a ser inserida ou atualizada no banco
    @param cDist        - Status para distrubui��o de danfe por email
/*/
function insertDist(cEntidade, nDist, cURL, cEmp, cFil)

    local cQuery        := ""
    local cAlias
    Default nDist       := 0
    Default cEntidade   := ""
    Default cURL        := ""

    if( empty(cEmp) .or. empty(cFil))
        PRTMSG( "Dados invalidos para grava gravacao: Entidade: " + cEntidade + " URL: " + cURL + " Empresa: " + cEmp + " Filal: " + cFil + CRLF + "Verifique retorno do TSS", LOG_ERROR)
        return .F.
    endif

    cEntidade   := alltrim(cEntidade)
    cURL        := alltrim(cURL)
    cEmp        := alltrim(cEmp)
    cFil        := alltrim(cFil)    
    
    cAlias        := getNextAlias()
    if DBSqlExec(cAlias, "SELECT * FROM DISTMAIL WHERE EMPRESA = '"+cEmp+"' AND FILIAL = '"+cfil+"'", 'SQLITE_SYS')
        if !(cAlias)->(EOF())            
            if !nDist = (cAlias)->ENABLE .or. !cURL == alltrim((cAlias)->URL) .or. !cEntidade == alltrim((cAlias)->ENTIDADE) 
                cQuery := "UPDATE DISTMAIL SET ENABLE="+alltrim(Str(nDist))+", URL = '" + cURL + "', ENTIDADE = '" + cEntidade + " ' WHERE EMPRESA = '"+cEmp+"' AND FILIAL = '"+cfil+"';"
                DBSqlExec('DISTMAIL', cQuery, 'SQLITE_SYS')
            endif            
        else
            cQuery := "INSERT INTO DISTMAIL(ENTIDADE, ENABLE, URL, EMPRESA, FILIAL) VALUES('"+cEntidade+"',"+alltrim(STR(nDist))+",'"+cURL+"','"+cEmp+"','"+cFil+"');"
            DBSqlExec('DISTMAIL', cQuery, 'SQLITE_SYS')
        endif    
        (cAlias)->(DBCloseArea())
    endif  

return .T.

/*/{Protheus.doc} getURLEnt
    Fun��o respons�vel retornar a URL do TSS da entidade 
    que esta sendo solicitada
    @type  Function
    @author Bruno Seiji
    @since 30/05/2019
    @version 12.1.17
    @param cEntidade    - Entidade a ser pesquisada
    @return cURL        - URL do TSS
/*/
static function getURLEnt(cEmp, cFil)

    local cURL          := ""
    local cAlias        := getNextAlias()

    if DBSqlExec(cAlias, "SELECT * FROM DISTMAIL WHERE EMPRESA = '" + cEmp  + "' AND FILIAL = '" + cFil + "'", 'SQLITE_SYS')
        if !(cAlias)->(EOF())
            cURL := alltrim((cAlias)->URL)
        endif    
        (cAlias)->(DBCloseArea())
    endif
    
return cURL

/*/{Protheus.doc} consNfeDnf
    Fun��o respons�vel por consultar as NFe's que seram 
    necess�rias a gera��o da danfe
    @type  Function
    @author Bruno Seiji
    @since 30/05/2019
    @version 12.1.17
    @param 
    @return 
/*/
static function consNfeDnf(cEmp, cFil, lContinua, nSequencia)
    local aRet          := {}
    local oWs           := nil
    local cAlias        := getNextAlias()

    Default cEmp        := ""
    Default cFil        := ""
    Default nSequencia  := 1

    begin sequence

    if !DBSqlExec(cAlias, "SELECT * FROM DISTMAIL WHERE EMPRESA = '" + cEmp + "' AND FILIAL = '" + cFil + "'", 'SQLITE_SYS')    
        break
    endif

    if( (cAlias)->(EOF()) ) .or. empty((cAlias)->URL) .or. empty((cAlias)->ENTIDADE)
        break
    endif
        
    oWS := WSNFESBRA():new()
    oWS:_URL := alltrim( (cAlias)->URL )+"/NFESBRA.apw"
    oWS:cUSERTOKEN := "TOTVS"
    oWS:cID_ENT := (cAlias)->ENTIDADE
    oWS:oWSSTATUSDISTMAIL:cMODELO := "55"
    oWS:oWSSTATUSDISTMAIL:nSEQUENCIA := nSequencia
    oWS:oWSSTATUSDISTMAIL:nSTATUS := 0

    if !oWS:STATUSDISTRIBUICAODEDOCUMENTOS()
        break
    endif
        
    lContinua := oWS:oWSSTATUSDISTRIBUICAODEDOCUMENTOSRESULT:LCONTINUA    
    if(lContinua)
        nSequencia := oWS:oWSSTATUSDISTRIBUICAODEDOCUMENTOSRESULT:nSequencia
    endif   

    aRet := oWS:oWSSTATUSDISTRIBUICAODEDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSTATUSDOCMAIL

    end sequence

    (cAlias)->(DBCloseArea())

    lContinua := len(aRet) > 0

return aRet

/*/{Protheus.doc} distNfeDnf
    Fun��o respons�vel por enviar ao TSS as NFe's com as danfes
    geradas no protheus
    @type  Function
    @author Bruno Seiji
    @since 30/05/2019
    @version 12.1.17
    @param cEntidade        Entidade a ser processada
    @param aNfe             Array da consulta do TSS ou Retransmiss�o do Prothues
    @return lExec
/*/

static function distNfeDnf(cEmp, cFil, cEntidade, aNfe, lTransmitir)

    local oWs           := nil
    local cBarra        := if(isSrvUnix(),"/","\")
    local cFilePath     := ""
    local cNFE_ID       := ""
    local cPath         := cBarra+"danfetemp"+cBarra
    local cPdf          := ""
    local nBuffer       := 0
    local nHdl          := 0
    local nX            := 0

    local lExec         := .F.
    local aDir          := {}
    local nPos          := 0
    local nTamanho      := 0 

    Default cEntidade   := ""
    Default lTransmitir := .F.

    if !criaDir(@cPath,cEmp,cFil,cBarra)
        return .F.
    endif

    for nX := 1 to len(aNfe)

        //tratamento para quando vier via JOB ou manual
        if ValType(aNfe[1]) == "A"
            cNFE_ID := aNfe[nX][1]
        else    
            cNFE_ID := aNfe[nX]:CDOC_ID  
        endif            
        
        cFilePath := cPath + lower(cNFE_ID + ".pdf")
        if !file(cFilePath)
            //gerar pdf
            createDanfe(cEmp, cFil,aNfe[nX])
        endif

        aDir := directory(cPath + "*.pdf")
        nPos := aScan(aDir, {|X| alltrim(lower(X[1])) == alltrim(lower(cNFE_ID + ".pdf")) })
        nTamanho := 0
        if nPos > 0
            nTamanho := aDir[nPos,2]
        endif

        if file(cFilePath) 
            nHdl := FOpen(cFilePath, 0)
            if nHdl >= 0
                nBuffer := fSeek(nHdl, 0,2)
                fSeek(nHdl,0,0)
                FRead(nHdl,@cPdf,nBuffer)  
                fClose(nHdl)
                fErase(cFilePath)
            endif

            if !empty(cPdf)
                if nTamanho <= 687 // pdf em branco gerou com esse tamanho ( 687 em bytes)
                    PRTMSG( "Tamanho do arquivo menor ou igual que 687 bytes: " + cFilePath + " / nota: " + alltrim(cNFE_ID), LOG_ERROR )
                else
                    oWS				                    := WSNFESBRA():new()
                    oWS:_URL		                    := getURLEnt(cEmp, cFil)+"/NFESBRA.apw"
                    oWS:cUSERTOKEN	                    := "TOTVS"
                    oWS:cID_ENT		                    := cEntidade
                    oWS:oWSDISTEMAIL:oWSLISTADOCUMENTOS := NFESBRA_ARRAYOFDOCUMENTOS():new()
                    oWS:oWSDISTEMAIL:cMODELO            := "55"

                    aadd(oWS:oWSDISTEMAIL:oWSLISTADOCUMENTOS:oWSDOCUMENTOS, NFESBRA_DOCUMENTOS():new())
                    atail(oWS:oWSDISTEMAIL:oWSLISTADOCUMENTOS:oWSDOCUMENTOS):cNFE_ID         := alltrim(cNFE_ID)
                    atail(oWS:oWSDISTEMAIL:oWSLISTADOCUMENTOS:oWSDOCUMENTOS):cPDF            := cPdf
                    atail(oWS:oWSDISTEMAIL:oWSLISTADOCUMENTOS:oWSDOCUMENTOS):lRETRANSMITIR   := lTransmitir
                    // oWS:DISTEMAIL:oWSLISTADOCUMENTOS[n]:cTIPOCOMPRESSAO := "zip"

                    if oWS:DISTRIBUICAODEDOCUMENTOS()
                        lExec := .T.
                    endif

                    oWS := nil
                endif
                cPdf := ""
            endif
        endif

    next
    
return lExec

/*/{Protheus.doc} createDanfe
    Fun��o respons�vel por gerar a danfe em background
    @type  Function
    @author Bruno Seiji
    @since 30/05/2019
    @version 12.1.17
    @param aNfe         Array com as informa��es da Nfe para gerar a DANFE
    @param cEntidade    Entidade a ser processada
    @return 
/*/
static function createDanfe(cEmp, cFil, aNfe)

    local oDanfe        := nil
    local oSetup        := nil    
    local cAlias        := getNextAlias()
    local cBarra        := if(isSrvUnix(),"/","\")
    local cPath         := cBarra + "danfetemp" + cBarra
    local cDoc          := ""
    local cSerie        := ""
    local lFile         := .F.
    local lIsLoja       := .F. 
    local cProg		    := iif(existBlock("DANFEProc"),"U_DANFEProc",iif(isRdmPad("DANFEProc"),"DANFEProc", ""))
    Local lDanfe        := !empty(cProg)
    local nTimes        := 0
    local aPerg         := {}
    local lExistNfe     := .F.

    Default aNfe        := {}

    if DBSqlExec(cAlias, "SELECT * FROM DISTMAIL WHERE EMPRESA = '" + cEmp  + "' AND FILIAL = '" + cFil + "'", 'SQLITE_SYS')

        cPath := cPath+cEmp+RTRIM(cFil)+cBarra

        if !(cAlias)->(EOF())
            if ValType(aNfe) == "A"
                cNFE_ID := aNfe[1]
            else    
                cNFE_ID := aNfe:CDOC_ID  
            endif  

            cDoc := subStr(cNFE_ID,4,len(cNFE_ID))
            cSerie := subStr(cNFE_ID,1,3)

            oDANFE := FWMSPrinter():New(alltrim(cNFE_ID), IMP_PDF, .F. /*lAdjustToLegacy*/,cPath/*cPathInServer*/,.T.,/*lTReport*/,/*oPrintSetup*/,/*cPrinter*/,/*lServer*/,/*lPDFAsPNG*/,/*lRaw*/,.F.,/*nQtdCopy*/)
            oDanfe:SetResolution(78)
            oDanfe:SetPortrait()
            oDanfe:SetPaperSize(DMPAPER_A4)
            oDanfe:SetMargin(60,60,60,60)
            oDanfe:lServer := .T.
            oDanfe:nDevice := IMP_PDF
            oDanfe:cPathPDF := cPath
            oDANFE:SetCopies( 1 )
                        
            //alimenta parametros da tela de configuracao da impressao da DANFE
            aPerg := {}
            Pergunte("NFSIGW", .F.,,,,, @aPerg)
            MV_PAR01 := cDoc
            MV_PAR02 := cDoc
            MV_PAR03 := cSerie
            MV_PAR04 := 0 //[Operacao] NF de Entrada / Saida
            MV_PAR05 := 2 //[Frente e Verso] Nao
            MV_PAR06 := 2 //[DANFE simplificado] Nao
            if ValType(aNfe) == "O"
                MV_PAR07 := ctod("") // aNfe:DDATA //[Data] Inicio
                MV_PAR08 := ctod("") // aNfe:DDATA //[Data] Fim
            endif
            __SaveParam("NFSIGW", aPerg)

            oDanfe:lInJob := .T.
            If !lDanfe
                PRTMSG( "Fonte de impressao de DANFE nao compilado! Acesse o portal do cliente, baixe os fontes DANFEII.PRW, DANFEIII.PRW e compile em seu ambiente", LOG_ERROR )
                return .T.
            Else
                &cProg.(@oDanfe, nil, (cAlias)->ENTIDADE, nil, nil, @lExistNfe, lIsLoja)
                if !oDanfe:Preview()
                    PRTMSG( "Nao foi possivel gerar a DANFE para Empresa: "+ (cAlias)->EMPRESA + (cAlias)->FILIAL + " nota: " + alltrim(cNFE_ID), LOG_PRINT )
                    return .F.
                EndIf
                if !lExistNfe
                    PRTMSG( "Nao foi gerado a DANFE para Empresa: "+ (cAlias)->EMPRESA + (cAlias)->FILIAL + " nota: " + alltrim(cNFE_ID), LOG_ERROR )
                    return .F.
                endif
            EndIf

            while( !lFile.or. nTimes < 10)
                lFile := file(cPath+alltrim(cNFE_ID)+".pdf")
                if(!lFile)
                    nTimes++
                    sleep(500)
                else
                    exit
                endif    
            end
        endif

        fwFreeObj(oSetup)
        fwFreeObj(oDanfe)
        oSetup := nil
        oDanfe := nil
        
        (cAlias)->(DBCloseArea())
    endif        

return .T.

/*/{Protheus.doc} countDISTMAIL
    Contagem de registros da tabela DISTMAIL
    @type  Function
    @author Renato Nagib
    @since 19/03/2020
    @version 12.1.27
    @param nil
    @param nCount  Quantidade de regisrtos
    @return 
/*/
static function countDISTMAIL()

    local cAliasProc    := getNextAlias()
    local nCount
    DBSqlExec(cAliasProc, "SELECT count(*) COUNT FROM DISTMAIL", 'SQLITE_SYS')
    nCount := (cAliasProc)->COUNT
    (cAliasProc)->(DBCloseArea())

return nCount


//-------------------------------------------------------------------
/*/{Protheus.doc} PRTMSG()

Executa um Print padronizado 
  

@param 	cMensagem    mensagem a ser printada no console  
@param 	nTypeMsg     Tipo do Conout 

@return nil

@author 	Renato Nagib 
@since		28/11/2016
@version	12.1.15

/*/
//-------------------------------------------------------------------
static function PRTMSG(cMensagem, nTypeMsg)

	local cDelConout := replicate("-", 78 )

	default nTypeMsg	:= 1
	
	if(nTypeMsg == LOG_ERROR)
		ConOut(CRLF + cDelConout + CRLF + "[ ERROR: " + UPPER(procName(1)) + "] " + (StrZero(ProcLine(1), 4)) + " [Thread: " + alltrim(str(ThreadId())) + "] " + "[" + dtoc(date()) +" "+ time() + "] " + CRLF + "[" + cMensagem + "] " + CRLF + cDelConout)
	elseif( nTypeMsg == LOG_PRINT)
		ConOut(CRLF + cDelConout + CRLF + "[ LOG: " + UPPER(procName(1)) + "] " + (StrZero(ProcLine(1), 4)) + " [Thread: " + alltrim(str(ThreadId())) + "] " + "[" + dtoc(date()) +" "+ time() + "] "  + CRLF +  "[" + cMensagem + "] " + CRLF + cDelConout)
	elseif(nTypeMsg == LOG_WARNING .and. __lWarning )
		ConOut(CRLF + cDelConout + CRLF + "[ WARNING: " + UPPER(procName(1)) + "] " + (StrZero(ProcLine(1), 4)) + " [Thread: " + alltrim(str(ThreadId())) + "] " + "[" + dtoc(date()) +" "+ time() + "] "  + CRLF +  "[" + cMensagem + "] " + CRLF + cDelConout)
	elseif(nTypeMsg == LOG_INFO .and. __lInfo )
		ConOut(CRLF + cDelConout + CRLF + "[ INFO: " + UPPER(procName(1)) + "] " + (StrZero(ProcLine(1), 4)) + " [Thread: " + alltrim(str(ThreadId())) + "] " + "[" + dtoc(date()) +" "+ time() + "] "  + CRLF +  "[" + cMensagem + "] " + CRLF + cDelConout)
	endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} createThreads()

Cria pool de Threads para processamento de email
  
@param 	ni

@return nil

@author 	Renato Nagib 
@since		20/03/2020
@version	12.1.27

/*/
//-------------------------------------------------------------------
static function createThreads()

	Local cEnv := ""
    local cAmbiente := ""

	if( __init == nil )

		cEnv :=  GetAdv97()

        if( empty( GetPvProfString("DISTMAIL", "ExpirationTime", "",  cEnv ) ) )
			WritePProString ( "DISTMAIL", "ExpirationTime", "300",  cEnv)
		endif

        if( empty( GetPvProfString("DISTMAIL", "ExpirationDelta", "",  cEnv ) ) )
			WritePProString ( "DISTMAIL", "ExpirationDelta", "1",  cEnv)
		endif
		
        if( empty( GetPvProfString("IPC_DISTMAIL", "main", "",  cEnv ) ) )
			WritePProString ( "IPC_DISTMAIL", "main", "prepareIPCWAIT",  cEnv)
		endif

        if( empty( GetPvProfString("IPC_DISTMAIL", "environment", "",  cEnv ) ) )
            cAmbiente := GetPvProfString("DISTMAIL", "environment", "",  cEnv )
			WritePProString ( "IPC_DISTMAIL", "environment", cAmbiente,  cEnv)
		endif
		
        if( empty( GetPvProfString("IPC_DISTMAIL", "instances", "",  cEnv ) ) )
			WritePProString ( "IPC_DISTMAIL", "instances", "1, 10, 1, 1",  cEnv)
		endif

		if( empty( GetPvProfString("IPC_DISTMAIL", "ExpirationTime", "",  cEnv ) ) )
			WritePProString ( "IPC_DISTMAIL", "ExpirationTime", "120",  cEnv)
		endif

        if( empty( GetPvProfString("IPC_DISTMAIL", "ExpirationDelta", "",  cEnv ) ) )
			WritePProString ( "IPC_DISTMAIL", "ExpirationDelta", "1",  cEnv)
		endif

        cJobs := GetPvProfString('ONSTART','JOBS','', cEnv)
        
        if( getSrvProfString("ACTIVATE","") == "") //Ativa IPCGO        
            WriteSrvProfString("ACTIVATE", "ON")
        endif    
		
        if(!"IPC_DISTMAIL" $ cJobs)
			if(!empty(cJobs))
				cJobs += ","
			endif
			cJobs += "IPC_DISTMAIL"
			WritePProString ( "ONSTART", "JOBS", cJobs,  GetAdv97())
		endif
		__init := .T.

	endif

return

/*/{Protheus.doc} AutDstMail
    Fun��o de distribui��o de envio de email de danfe customizado
    para que seja executado via schedule do protheus

/*/
function AutDstMail(aParam)
    local cEmpParam  := ""
    local cFilParam  := ""
    local cEnv       := ""
    local cConfig    := ""
    local cAliasProc := ""
    local cEmpMail   := ""
    local cFilMail   := ""
    local cEntMail   := ""
    local cIdGlobal  := ""
    local dAutDist   := nil
    local cLog       := ""
    Local lMonitor   := ExistFunc("FWMonitorMsg")

    default aParam := {}

    begin sequence

    cEnv := GetAdv97()
    if( empty( cConfig := alltrim(GetPvProfString("DISTMAIL", "MODO", "",  cEnv ) )) )
        WritePProString( "DISTMAIL", "MODO", "1",  cEnv) 
        // Vazio ou 2 - IPC (padr�o)
        // 1 - Schedule 
    elseif val(cConfig) == 2
        PRTMSG("Processo sendo configurado para IPC_DISTMAIL.", LOG_PRINT)
        break
    endif

    If !validPrinter()
        break
    EndIf

    cEmpParam := aParam[1]
    cFilParam := aParam[2]

    PRTMSG("Processo sendo executado via schedule pela empresa/filial - " + alltrim(cEmpParam) + "/" + alltrim(cFilParam) + ".", LOG_INFO)

    crtTblMail()//cria o banco sqlite

	varSetUID("AUTODISTMAIL", .T.)
	cIdGlobal := "filltblmail"

	if !varGetXD("AUTODISTMAIL", cIdGlobal, @dAutDist) .or. !valtype(dAutDist) == "D" .or. date() > dAutDist 
        startjob( "fillTblMail", getEnvserver(), .F.)//cadastro das empresas para envio de email
        dAutDist := date()
        varSetXD("AUTODISTMAIL", cIdGlobal, dAutDist)
    endif

    cAliasProc := getNextAlias()
    if dbSqlExec(cAliasProc, "SELECT * FROM DISTMAIL WHERE EMPRESA = '" + alltrim(cEmpParam) + "' AND FILIAL = '" + alltrim(cFilParam) + "' AND ENTIDADE != ' ' AND URL != ' ' AND ENABLE = 1 ", "SQLITE_SYS")
        if !(cAliasProc)->(EOF())
            cEmpMail := (cAliasProc)->EMPRESA
            cFilMail := (cAliasProc)->FILIAL
            cEntMail := (cAliasProc)->ENTIDADE
        endif
    endif
    (cAliasProc)->(DbCloseArea())

    if !empty( cEmpMail ) .and. !empty( cFilMail ) .and. !empty( cEntMail )
        cLog := "Inicializando o processo de envio de email de danfe customizado para a empresa/filial - " + alltrim(cEmpMail) + " / " + alltrim(cFilParam) + " - Entidade:" + alltrim(cEntMail) + "." 
        PRTMSG(cLog, LOG_INFO)
        If lMonitor
            FWMonitorMsg(cLog)
        EndIf

        procSendMail( cEmpMail , cFilMail , cEntMail , "procSendMail-" + alltrim(cEmpMail) + alltrim(cFilMail) )

        cLog := "Finalizando o processo de envio de email de danfe customizado para a empresa/filial - " + alltrim(cEmpMail) + " / "+ alltrim(cFilParam) + " - Entidade:" + alltrim(cEntMail) + "." 
        PRTMSG(cLog, LOG_INFO)
        If lMonitor
            FWMonitorMsg(cLog)
        EndIf
    else
        PRTMSG("A empresa/filial '" + alltrim(cEmpParam) + " / " + alltrim(cFilParam) + "' nao foi encontrada ou nao esta habilitada para execucao do envio de danfe customizado.", LOG_ERROR)
    endif

    end sequence

return

/*/{Protheus.doc} validPrinter
    Fun��o respons�vel por verificar se o usuario possui
    o artefato printer presente na pasta do servidor
    @type  Function
    @author Renan Franco
    @since 28/01/2022
    @version 12.1.33
    @return Logical     
/*/
static function validPrinter()

    Local cDirServer    := ""
    Local cFunc         := "getAppPath"
    Local lPrinter      := .F.
    Local lUnix         := IsSrvUnix()

    If &cFunc.(@cDirServer) == 0
        lPrinter := If(lUnix, File( cDirServer + "/printer", 1) .And. File( cDirServer + "/pdfprinter", 1) , File( cDirServer + "\printer.exe", 1) )
    EndIf

    If !lPrinter
        PRTMSG("Nao foi encontrado o artefato printer para impressao do danfe." + CHR(13) + CHR(10) +;
        if(lUnix, cDirServer + "/printer" + CHR(13) + CHR(10) + cDirServer + "/pdfprinter", cDirServer + "\printer.exe"), LOG_ERROR)
    EndIf

return lPrinter

/*/{Protheus.doc} criaDir
    Fun��o respons�vel por criar o diret�rio
    onde os pdfs serao salvos
    @type  Function
    @author Leonardo Barbosa
    @since 04/08/20222
    @version 12.1.33
    @return Logical     
/*/
static function criaDir(cPath,cEmp,cFil,cBarra)

    local lVal := .T.

    if !ExistDir(cPath) .and. MakeDir(cPath) <> 0
        PRTMSG( "Diretorio nao pode ser criado, verifique as permissoes da pasta protheus_data do ambiente. Erro: " + cValToChar( FError() ), LOG_PRINT )
        lVal := .F.
    endIf

    if lVal
        cPath := cPath+cEmp+cFil+cBarra
        if !ExistDir(cPath) .and. MakeDir(cPath) <> 0
            PRTMSG( "Diretorio nao pode ser criado, verifique as permissoes da pasta danfetemp do ambiente. Erro: " + cValToChar( FError() ), LOG_PRINT )        
            lVal := .F.
        endif       
    endif

return lVal
