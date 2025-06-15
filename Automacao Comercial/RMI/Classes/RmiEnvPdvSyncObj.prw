#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRYEXCEPTION.CH"
#INCLUDE "RMIENVPDVSYNCOBJ.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiEnvLiveObj
Classe responsável pelo envio de dados ao Live

/*/
//-------------------------------------------------------------------
Class RmiEnvPdvSyncObj From RmiEnviaObj

    Data aProcessos As Array            //Armazena os processos que foi gerado o lote
    Data aMhrRec    as Array
    Data nMaxPorLote
    Data nQtdList   as Numeric
    Data cBodylist  As Character        //Corpo da mensagem que será enviada para o sistema de destino
    Data aMhpConf   as Array            //Objeto Json da MHP
    Data oPdvSync   as Object           //Objeto PdvSync
    
    Method New()                        //Metodo construtor da Classe

    Method AbreLote()                           //Método para gerar o Json de abertura do Lote
    Method FechaLote()                          //Método para gerar o Json de fechamento do Lote
    Method EnviaAbreLote(cJson)                 //Método que faz a comunicação com o PdvSync para abertura do Lote
    Method EnviaFechaLote()                     //Método que faz a comunicação com o PdvSync para fechamento do Lote
    Method TrataRetorno(cJson, nTipo)           //Trata o retorno ao abrir ou fechar um lote
    Method GrvAbertura(cProcesso, cLote, cId)   //Metodo responsavel em gravar a abertura do lote na tabela MIK
    Method GrvFechamento()                      //Metodo responsavel em gravar fechamento do lote na tabela MIK

    Method ProcessoPend(cLote)          //Verifica se há algum processo que ainda não terminou o envio antes de fechar o lote
    Method GetProcessos()               //Retorna quais os processos estão pendente de envio para geração do lote
    Method GetLote()                    //Esse metodo verifica se para um determinado processo já tem lote em aberto para seguir com o envio dos dados para o PDVSync

    Method PreExecucao()                //Metodo para gerar o token no PDV Sync
    Method PosExecucao()                //Metodo com as regras para efetuar algum tratamento depois de ser feito o envio.
    Method Envia()                      //Metodo responsavel por enviar a mensagens ao PDVSync

    Method Grava()                      //Metodo que ira atualizar a situação da distribuição e gravar o de/para
    Method Consulta()                   // -- Consulta as publicações disponiveis para o envio para um determinado processo com base nos LOTE's abertos
    Method Processa()                   //Metodo que ira controlar o processamento dos envios em lista

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Bruno Almeida
@Date    17/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cProcesso) Class RmiEnvPdvSyncObj
    
    Local cTenent       := ""
    Local cUser         := ""
    Local cPassword     := ""
    Local cClientId     := ""
    Local cClientSecret := ""
    Local nEnvironment  := 0

    _Super:New("PDVSYNC", cProcesso)
    Self:nMaxPorLote := 500

    If self:oConfAssin:hasProperty("autenticacao")  
        cTenent       := IIF( self:oConfAssin["autenticacao"]:hasProperty("tenent")         , self:oConfAssin["autenticacao"]["tenent"]         , "")
        cUser         := IIF( self:oConfAssin["autenticacao"]:hasProperty("user")           , self:oConfAssin["autenticacao"]["user"]           , "")
        cPassword     := IIF( self:oConfAssin["autenticacao"]:hasProperty("password")       , self:oConfAssin["autenticacao"]["password"]       , "")
        cClientId     := IIF( self:oConfAssin["autenticacao"]:hasProperty("clientId")       , self:oConfAssin["autenticacao"]["clientId"]       , "")
        cClientSecret := IIF( self:oConfAssin["autenticacao"]:hasProperty("clientSecret")   , self:oConfAssin["autenticacao"]["clientSecret"]   , "")
        nEnvironment  := IIF( self:oConfAssin["autenticacao"]:hasProperty("environment")    , self:oConfAssin["autenticacao"]["environment"]    , 1 )
    EndIf

    If self:lSucesso
        If FindClass("totvs.protheus.retail.rmi.classes.pdvsync.PdvSync") //Incluido dependencia automatica
            self:oPdvSync := totvs.protheus.retail.rmi.classes.pdvsync.PdvSync():New(cTenent, cUser, cPassword, cClientId, cClientSecret, nEnvironment)       
        EndIf
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AbreLote
Método para gerar o Json que fara a abertura do lote

@author  Bruno Almeida
@Date    17/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method AbreLote() Class RmiEnvPdvSyncObj

    Local cJson     := ""   //Guarda o Json para geração do lote
    Local nI        := 0    //Variavel de loop
    Local oError    := Nil  //Variavel para captura de erro
    Local cTipos    := ""   //Tipo de lotes a serem abertos

    TRY EXCEPTION
        If !LockByName("GERALOTE", .T., .T.)
            Sleep(9000)
            If Self:GetLote(Self:cProcesso)
                Self:lSucesso := .T.
                Self:cRetorno := ""
               LjGrvLog(" RmiEnvPdvSyncObj ","Existe um lote em aberto para o processo " + Self:cProcesso + "iniciando o envio dos dados para o PDVSYNC. Lote: ")  //"Serviço #1 já esta sendo utilizado por outra instância."
            Else
                // -- Voltam os essa alteração, o registro esta ficando com 6 onde deveria ser pulado
                Self:lSucesso := .F.
                Self:cRetorno := STR0001 + Self:cProcesso + STR0002 //"Não existe um lote em aberto para o processo " # ", os dados desse processo não serão enviados até que o lote em aberto seja fechado."
                LjGrvLog(" RmiEnvPdvSyncObj ", Self:cRetorno)
            EndIf
            Return Nil
        EndIf

        Self:aProcessos := {}
        
        If !Self:GetLote() // --Neste ponto não quero q tenha nenhum lote em aberto
            Self:aProcessos := Self:GetProcessos()

            If Len(Self:aProcessos) > 0

                cJson := '{"status": "InicioEnvio",'
                
                For nI := 1 To Len(Self:aProcessos)
                    cTipos += Self:aProcessos[nI][2] + ","
                Next

                cTipos := '"tipoLote": [' + SubStr(cTipos,1,Len(cTipos) - 1) + '],'

                cJson += cTipos
                cJson += '"idInquilino": "' + Self:oConfAssin["inquilino"] + '"'
                cJson += '}'

                Self:EnviaAbreLote(cJson, 0)
            EndIf

        EndIf

        UnLockByName("GERALOTE", .T., .T.)

    CATCH EXCEPTION USING oError

        UnLockByName("GERALOTE", .T., .T.)
        Self:lSucesso := .F.
        Self:cRetorno := "Ocorreu erro ao gerar lote ->  " + AllTrim(oError:Description)
        LjGrvLog(" RmiEnvPdvSyncObj ", Self:cRetorno)

    ENDTRY

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} Processos
Verifica quais os processos estão pendente de envio para geração do lote

@author  Bruno Almeida
@Date    17/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetProcessos() Class RmiEnvPdvSyncObj

    Local cQuery    := ""               //Guarda a query a ser executada
    Local aRet      := {}               //Variavel de retorno
    Local cAlias    := GetNextAlias()   //Proximo alias disponivel
    Local cAliasMhp := ""               //Pega o próximo alias para consulta da MHP
    Local oMhp      := Nil              //Objeto Json da MHP
    self:aMhpConf := IIF(Valtype(self:aMhpConf)  == 'U' ,{},self:aMhpConf)
    
        
    cQuery := "SELECT MHR_CPROCE "
    cQuery += "  FROM " + RetSqlName("MHR")
    cQuery += " WHERE MHR_CASSIN = '" + self:cAssinante + "' "
    cQuery += "   AND MHR_STATUS = '1'"
    cQuery += "   AND MHR_FILIAL = '" + xFilial("MHR") + "'"
    cQuery += "   AND D_E_L_E_T_ = ' '"
    cQuery += " GROUP BY MHR_CPROCE"

    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

    If !(cAlias)->( Eof() )
        While !(cAlias)->( Eof() )

            cQuery := "SELECT R_E_C_N_O_ "
            cQuery += "  FROM " + RetSqlName("MHP")
            cQuery += " WHERE MHP_CASSIN = '" + self:cAssinante + "' "
            cQuery += "   AND MHP_CPROCE = '" + (cAlias)->MHR_CPROCE + "'"
            cQuery += "   AND MHP_FILIAL = '" + xFilial("MHP") + "'"
            cQuery += "   AND MHP_ATIVO = '1'"      //1=Sim
            cQuery += "   AND D_E_L_E_T_ = ' '"     
            
            cAliasMhp := GetNextAlias()
            cQuery    := ChangeQuery(cQuery)
            DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasMhp, .T., .F.)

            If !(cAliasMhp)->( Eof() )
                MHP->( DbGoTo( (cAliasMhp)->R_E_C_N_O_) )
                
                oMhp := JsonObject():New()

                //Verifica se o json de configuração esta valido.
                If ValType( oMhp:FromJson( AllTrim(MHP->MHP_CONFIG) ) ) <> "C"
                    Aadd( aRet, { (cAlias)->MHR_CPROCE, oMhp["codigotipo"], oMhp["descricaotipo"] } )
                EndIf
                
            EndIf
            
            FwFreeObj(oMhp)
            (cAliasMhp)->( DbCloseArea() )
            (cAlias)->( DbSkip() )
        EndDo
    Else
        Self:lSucesso := .F.
        Self:cRetorno := STR0003 //"Não existem distribuições (processos) pendentes para o envio."
        LjGrvLog(" RmiEnvPdvSyncObj ", Self:cRetorno)
    EndIf

    (cAlias)->( DbCloseArea() )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} EnviaAbreLote
Faz a solicitação ao PDVSync para abrir lote.

@author  Bruno Almeida
@Date    17/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method EnviaAbreLote(cJson) Class RmiEnvPdvSyncObj

    Local oRest := Nil //Objeto que faz a comunicação via Rest com PDVSync para abrir ou fechar um lote

    oRest := FWRest():New("")

    //Seta a url do lote
    oRest:SetPath( Self:oConfAssin["url_lote"] )

    //Seta o corpo do Post
    oRest:SetPostParams( cJson )

    //Busca o lote
    If oRest:Post( self:aHeader )
        Self:TrataRetorno(oRest:GetResult(), 0)
    Else
        Self:lSucesso := .F.        
        Self:cRetorno := STR0004 + oRest:GetLastError() + " - " + IIF( ValType(oRest:cResult) == "C", oRest:cResult, "Detalhe do erro não retornado." ) //"Não foi possivel realizar a abertura do lote.  - "        
        LjxjMsgErr(self:cRetorno, /*cSolucao*/, /*cRotina*/) 
    EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} EnviaFechaLote
Faz a solicitação ao PDVSync para fechar lote

@author  Bruno Almeida
@Date    17/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method EnviaFechaLote() Class RmiEnvPdvSyncObj

    Local oRest := Nil //Objeto que faz a comunicação via Rest com PDVSync para abrir ou fechar um lote
    Local cPath := AllTrim(Self:oConfAssin["url_lote"]) //EndPoint para realizar o fechamento

    oRest := FWRest():New("")

    If SubStr(cPath,Len(cPath),1) == "/"
        cPath := SubStr(cPath, 1, Len(cPath) - 1)
    EndIf

    //Seta a url do lote
    oRest:SetPath( cPath + "/" + AllTrim(Self:oConfAssin["inquilino"]) + "/" + AllTrim(Self:cLote) )

    //Fecha o lote
    If oRest:Put( self:aHeader )
        Self:TrataRetorno(oRest:GetResult(), 1)
    Else
        LjGrvLog(" RmiEnvPdvSyncObj ", "Não foi possivel realizar o fechamento do lote: " + AllTrim(Self:cLote) + " - " + oRest:GetLastError()+" - ";
        +IIF( ValType(oRest:cResult) == "C", oRest:cResult, "Detalhe do erro não retornado." ) )
    EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataRetorno
Trata o retorno do lote, abertura ou fechamento

@author  Bruno Almeida
@Date    17/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method TrataRetorno(cJson, nTipo) Class RmiEnvPdvSyncObj

    Local oRet  := JsonObject():New()
    Local nI    := 0 //Variavel de loop
    Local nCod  := 0 //Código do processo

    oRet:FromJson( DeCodeUTF8(cJson) )

    If oRet["success"]

        //0 Abertura
        If nTipo == 0 
            If oRet["data"]:hasProperty("status") .and. oRet["data"]["status"] == 0
                For nI := 1 To Len(oRet["data"]["tipoLote"])
                    nCod := aScan(Self:aProcessos, {|x| x[2] == cValToChar(oRet["data"]["tipoLote"][nI])})
                    If nCod > 0                    
                        Self:GrvAbertura(Self:aProcessos[nCod][1],oRet["data"]["loteOrigem"],oRet["data"]["id"])
                    EndIf
                Next nI
            EndIf

        //1 Fechamento            
        Else
            If oRet["data"]:hasProperty("status") .and. oRet["data"]["status"] == 1
                Self:GrvFechamento()
            EndIf
        EndIf

    Else

        self:lSucesso := .F.
        self:cRetorno := oRet["message"]
        LjxjMsgErr(self:cRetorno, /*cSolucao*/, /*cRotina*/) 
    EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvAbertura
Faz a gravação dos lotes gerados na tabela MIK

@author  Bruno Almeida
@Date    17/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method GrvAbertura(cProcesso, cLote, cId) Class RmiEnvPdvSyncObj

    Self:cLote := cLote

    RecLock("MIK",.T.)
    MIK->MIK_FILIAL := xFilial("MIK")
    MIK->MIK_LOTE := cLote
    MIK->MIK_CPROCE := cProcesso
    MIK->MIK_DTABE := Date()
    MIK->MIK_HRABE := Time()
    MIK->MIK_IDLOTE := cId
    MIK->( MsUnLock() )
  
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvFechamento
Faz a atualização do fechamento do lote

@author  Bruno Almeida
@Date    24/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method GrvFechamento() Class RmiEnvPdvSyncObj

    Local cQuery := "" //Query a ser executada
    Local cAlias := GetNextAlias() //Proximo alias disponivel

    cQuery := "SELECT R_E_C_N_O_ "
    cQuery += "  FROM " + RetSqlName("MIK")
    cQuery += " WHERE MIK_FILIAL = '" + xFilial("MIK") + "'"
    cQuery += "   AND MIK_LOTE = '" + Self:cLote + "'"
    cQuery += "   AND D_E_L_E_T_ = ' '"

    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

    If !(cAlias)->( Eof() )
        While !(cAlias)->( Eof() )
            MIK->(DbGoTo((cAlias)->R_E_C_N_O_))
            RecLock("MIK",.F.)
            MIK->MIK_DTFECH := Date()
            MIK->MIK_HRFECH := Time()  
            MIK->( MsUnLock() )
            (cAlias)->( DbSkip() )
        EndDo
    Else
        LjGrvLog(" RmiEnvPdvSyncObj ", "Lote (" + Self:cLote + ") não encontrado na tabela para atualizar os campos de Data e Hora de fechamento")
    EndIf

    (cAlias)->( DbCloseArea() )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetLote
Esse metodo verifica se para um determinado processo já tem lote em
aberto para seguir com o envio dos dados para o PDVSync

@author  Bruno Almeida
@Date    17/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetLote(cProcesso) Class RmiEnvPdvSyncObj

    Local cQuery    := "" //Armazena a query
    Local cAlias1   := GetNextAlias() //Proximo alias disponivel
    Local lExiste   := .F. //Se existe ou nao um lote já aberto
       
    cQuery := " SELECT MIK_LOTE "
    cQuery += " FROM " + RetSqlName("MIK")
    cQuery += " WHERE MIK_DTFECH = ' ' "
    
    If !Empty(cProcesso)
        cQuery += " AND MIK_CPROCE = '" + cProcesso + "'"
    EndIF 

    cQuery += " AND MIK_FILIAL = '" + xFilial("MIK") + "' "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    
    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias1, .T., .F.)

    If !(cAlias1)->( Eof() )
        lExiste     := .T.    
        Self:cLote  := AllTrim((cAlias1)->MIK_LOTE)
    Else
	    lExiste     := .F.
        Self:cLote  := ""
    EndIf

    (cAlias1)->( DbCloseArea() )

Return lExiste

//-------------------------------------------------------------------
/*/{Protheus.doc} PreExecucao
Metodo para gerar o token no PDV Sync

@author  Bruno Almeida
@Date    21/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method PreExecucao() Class RmiEnvPdvSyncObj
    
    Local aMensagem := {}

    If (aMensagem := self:oPdvSync:Token())[1]
        self:aHeader := self:oPdvSync:getHeader()
    else
        self:lSucesso := aMensagem[1]
        self:cRetorno := aMensagem[2]
    EndIf

    If self:lSucesso
        self:AbreLote()    
    Else
        LjxjMsgErr(self:cRetorno, /*cSolucao*/, /*cRotina*/)    
    EndIf

Return self:lSucesso


//-------------------------------------------------------------------
/*/{Protheus.doc} Envia
Metodo responsavel por enviar a mensagens ao PDVSync

@author  Bruno Almeida
@Date    21/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method Envia() Class RmiEnvPdvSyncObj

    //Inteligencia poderá ser feita na classe filha - default em Rest com Json
    If Self:lSucesso

        //Inteligencia poderá ser feita na classe filha - default em Rest com Json    
        If Self:oEnvia == Nil
            Self:oEnvia := FWRest():New("")
        EndIf

        Self:oEnvia:SetPath( Self:oConfProce["url"] )

        Self:cBody := "[" + Self:cBody + "]"

        Self:oEnvia:SetPostParams(EncodeUTF8(Self:cBody))
        LjGrvLog(" RmiEnvPdvSyncObj ", "Method Envia() no oEnvia:SetPostParams(cBody) " ,{Self:cBody})

        If Self:oEnvia:Post( self:aHeader )
            Self:lSucesso := .T.
            Self:cRetorno := Self:oEnvia:oResponseH:cStatusCode
        Else
            Self:lSucesso := .F.
            Self:cRetorno := Self:oEnvia:GetLastError() + " - [" + Self:oConfProce["url"] + "]" + CRLF
            Self:cRetorno += IIF( ValType(self:oEnvia:CRESULT) == "C", self:oEnvia:CRESULT, "Detalhe do erro não retornado." )
            LjGrvLog(" RmiEnvPdvSyncObj ", "Não teve sucesso retorno => " ,{Self:cRetorno}) 
        EndIf
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FechaLote
Método para gerar o Json que fara o fechamento do lote

@author  Bruno Almeida
@Date    21/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method FechaLote() Class RmiEnvPdvSyncObj

    If !Self:ProcessoPend()
        Self:EnviaFechaLote()
    EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcessosPend
Verifica se há algum processo que ainda não terminou o envio
antes de fechar o lote

@author  Bruno Almeida
@Date    21/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method ProcessoPend() Class RmiEnvPdvSyncObj              

    Local cQuery    := "" //Query de processos pendentes
    Local cAliasMik := GetNextAlias() //Proximo alias disponivel
    Local cAliasMhr := GetNextAlias() //Proximo alias disponivel
    Local lRet      := .F. //Variavel de retorno
    Local cAuxIn    := ""

    cQuery := "SELECT MIK_CPROCE, MIK_LOTE"
    cQuery += "  FROM " + RetSqlName("MIK")

    If !Empty(Self:cLote)
        cQuery += " WHERE MIK_LOTE = '" + Self:cLote + "'"
    Else
        cQuery += " WHERE MIK_CPROCE = '" + Self:cProcesso + "'"
        cQuery += "   AND MIK_DTFECH = ' '"
    EndIf

    cQuery += "   AND MIK_FILIAL = '" + xFilial("MIK") + "'"
    cQuery += "   AND D_E_L_E_T_ = ' '"

    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasMik, .T., .F.)

    If !(cAliasMik)->( Eof() )
        
        If Empty(Self:cLote)
            Self:cLote := AllTrim((cAliasMik)->MIK_LOTE)
        EndIf

        cQuery := " SELECT COUNT(*) REGISTROS_ENVIADOS "
        cQuery += " FROM " + RetSqlName("MHR")
        cQuery += " WHERE MHR_FILIAL = '" + xFilial("MHR") + "' "
        cQuery += " AND MHR_LOTE = '" + Self:cLote + "' "
        cQuery += " AND MHR_STATUS <> '1' "
        cQuery += " AND D_E_L_E_T_ = ' ' "

        cAliasMhr := GetNextAlias() 
        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasMhr, .T., .F.)
        
        nRecEnviados := (cAliasMhr)->REGISTROS_ENVIADOS
        
        (cAliasMhr)->( DbCloseArea() )
        
        If nRecEnviados > Self:nMaxPorLote
            lRet := .F. 
            LjGrvLog(" RmiEnvPdvSyncObj ", "LOTE  [" + Self:cLote + "] sera fechado pois execedeu o limite de: " + cValToChar(Self:nMaxPorLote) + " envios por LOTE")
        Else

            While !(cAliasMik)->( Eof() )
                cAuxIn += " '" + (cAliasMik)->MIK_CPROCE +  "',"
                (cAliasMik)->( DbSkip() )
            EndDo 

            cAuxIn := SUBSTR(cAuxIn,1, Len(cAuxIn) - 1)

            cQuery := "SELECT COUNT(*) REGISTROS_PENDENTE"
            cQuery += "  FROM " + RetSqlName("MHR")
            cQuery += " WHERE MHR_CPROCE In (" + cAuxIn + ")"
            cQuery += "   AND MHR_STATUS = '1'"
            cQuery += "   AND MHR_FILIAL = '" + xFilial("MHR") + "'"
            cQuery += "   AND D_E_L_E_T_ = ' '"

            cAliasMhr := GetNextAlias() 
            DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasMhr, .T., .F.)

            If (cAliasMhr)->REGISTROS_PENDENTE > 0
                lRet := .T.
                LjGrvLog(" RmiEnvPdvSyncObj ", "Lote (" + Self:cLote + ") não sera encerrado pois consta MHR_STATUS = 1 para o processo " + AllTrim((cAliasMik)->MIK_CPROCE))
            EndIf

            (cAliasMhr)->( DbCloseArea() )

        EndIf 
        
    Else
        lRet := .T.
    EndIf
    
    (cAliasMik)->( DbCloseArea() )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Metodo que ira atualizar a situação da distribuição e gravar o de/para

@author  Bruno Almeida
@Date    15/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method Grava() Class RmiEnvPdvSyncObj              
    _Super:Grava(IIF(Self:lSucesso,"6","3"))
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PosExecucao
Metodo com as regras para efetuar algum tratamento depois de ser feito o envio.

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method PosExecucao() Class RmiEnvPdvSyncObj
    self:FechaLote()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Consulta
Metodo que efetua consulta das distribuições a enviar

@author  Lucas Novais (lNovais)
@version 1.0
/*/
//-------------------------------------------------------------------
Method Consulta() Class RmiEnvPdvSyncObj

    // -- Se tiver LOTE em aberto para o processo atual faço a consulta. 
    If Self:GetLote(Self:cProcesso) .OR. !Self:GetLote()

        LjGrvLog(" RmiEnviaObj ", "Antes da chamada do metodo consulta", FWTimeStamp(2))
        
        //Carrega a distribuições que devem ser enviadas
        _Super:Consulta()

        LjGrvLog(" RmiEnviaObj ", "Apos executar a query do metodo consulta", FWTimeStamp(2))
    Else   
        LjGrvLog("Consulta","AVISO: " + STR0001 + Self:cProcesso + STR0002)  //"Não existe um lote em aberto para o processo " # ", os dados desse processo não serão enviados até que o lote em aberto seja fechado."
    EndIf

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} Processa
Metodo que ira controlar o processamento dos envios em lista

@author  totvs
@version 1.0
/*/
//-------------------------------------------------------------------
Method Processa() Class RmiEnvPdvSyncObj
    Local nX      := 0
    
    self:cBodyList := ''
    self:aMhrRec  := {}
    self:aMhpConf := {}
    
    //Carrega a distribuições que devem ser enviadas
    self:Consulta()
    self:SetaProcesso(self:cProcesso)
    self:nQtdList := IIF(self:oConfProce:hasProperty("qtdEnvio") ,self:oConfProce['qtdEnvio'],1)
    
    //Adicionando Limite de itens na Lista 
    self:nQtdList := IIF(self:nQtdList>1000,1000,self:nQtdList)

    If self:lSucesso .And. !Empty(self:cAliasQuery)
    
        While !(self:cAliasQuery)->( Eof() ) //500        

            If !self:PreExecucao()
                Exit
            EndIf            
            
            If Self:lSucesso
                
                While !(self:cAliasQuery)->( Eof() ) .AND. Len(self:aMhrRec) < self:nQtdList
                    
                    self:lSucesso := .T.
                    self:cRetorno := ""
                    self:cBody    := ""
                    //Posiciona na publicação
                    MHQ->( DbSetOrder(1) )  //MHQ_FILIAL + MHQ_ORIGEM + MHQ_CPROCE
                    MHQ->( DbGoTo( (self:cAliasQuery)->RECNO_PUB ) )                                        
                    

                    self:cOrigem     := MHQ->MHQ_ORIGEM
                    self:cEvento     := MHQ->MHQ_EVENTO //1=Upsert, 2=Delete, 3=Inutilização
                    self:cChaveUnica := MHQ->MHQ_CHVUNI
                    
                    //Carrega o layout com os dados da publicação
                    If self:lSucesso                            
                        //Carrega a publicação que será distribuida
                        self:cPublica := AllTrim(MHQ->MHQ_MENSAG)
                        If self:oPublica == Nil
                            self:oPublica := JsonObject():New()
                        EndIf
                        If !Empty(Alltrim(self:cPublica))
                            self:oPublica:FromJson(self:cPublica)                                
                            self:CarregaBody()
                        Else
                            self:lSucesso := .F.
                            self:cRetorno := "campo MHQ_MENSAG em branco MHQ_UUID -> "+ MHQ->MHQ_UUID    
                        EndIf    
                    EndIf
                    //Cria Lista
                    self:cBodyList    += IIF(Empty(self:cBodyList),self:cBody,","+self:cBody)
                    Aadd(self:aMhrRec, {(self:cAliasQuery)->RECNO_DIS,self:cBody,Self:cIdRetaguarda,self:lSucesso,self:cRetorno})
                    self:nMhrRec := (self:cAliasQuery)->RECNO_DIS
                    
                    (self:cAliasQuery)->( DbSkip() )
                    
                EndDo
            EndIf
            
            If (self:cAliasQuery)->( Eof() ) .AND. self:nQtdList > 1
                self:Consulta()
            Endif
            
            If (self:cAliasQuery)->( Eof() ) .OR. Len(self:aMhrRec) >= self:nQtdList 
                
                If self:lSucesso .AND. !Empty(self:cBodyList)
                    self:cBody := self:cBodyList                            
                    self:Envia()
                EndIf    
                
                MHR->( DbSetOrder(1) )  //MHR_FILIAL + MHR_CASSIN + MHR_CPROCE
                For nX := 1 To Len(self:aMhrRec)
                    MHR->( DbGoTo(self:aMhrRec[nX][1] ))
                    self:cBody          := self:aMhrRec[nX][2] // Grava Body na linha MHR
                    Self:cIdRetaguarda  := self:aMhrRec[nX][3]//adiciona ID Retaguarda processado no RmiEnviaObj
                    If !self:aMhrRec[nX][4]
                        self:lSucesso := self:aMhrRec[nX][4] // Se estiver com erro gravar o motivo.   
                    EndIf
                    IIF(!Empty(self:aMhrRec[nX][5]),self:cRetorno:=self:aMhrRec[nX][5],"")// Gravar o motivo do erro
                    If !MHR->(Eof())                        
                        self:Grava()
                    EndIf
                Next
                LjGrvLog("RmiEnvPdvSyncObj", "Executa PosExecucao ")
                self:PosExecucao()
                self:aMhrRec := {}
                self:cBodyList := ""
                self:lSucesso  := .T. 
            endif    
        EndDo

        (self:cAliasQuery)->( DbCloseArea() )

        self:PosExecucao()  //caso o lote estiver aberto fechar.
    EndIf   

Return Nil
