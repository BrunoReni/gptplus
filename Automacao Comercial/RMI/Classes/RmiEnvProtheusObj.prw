#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMIENVPROTHEUSOBJ.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiEnvProtheusObj
Classe que processa as distribui��es do Protheus
/*/
//-------------------------------------------------------------------
Class RmiEnvProtheusObj From RmiEnviaObj

    Data aExecAuto  As Array                    //Array com o conteudo utilizado na manipula��o de dados MsExecAuto

    Method New()                                //Metodo construtor da Classe

    Method PreExecucao()                        //Metodo com as regras para efetuar conex�o com o sistema de destino

    Method CarregaBody()                        //Metodo que carrega o corpo da mensagem que ser� enviada

    Method Envia()                              //Metodo responsavel por enviar a mensagens ao sistema de destino

    Method NotaEntrada()                        //Metodo com tratamentos especificos para gera��o da nota de entrada

    Method Pedido()                             //Metodo com tratamentos especificos para gera��o do Pedido

    //Metodos auxiliares para tratamento interno da classe
    Method AuxExecAuto(bMsExecAuto, cChave)     //Metodo para efetuar a execu��o da MsExecAuto, dependendo os par�metros passados
    
    Method GravaReserva()                       //Metodo para efetuar a reserva especifico para o processo Pedido 
    Method ConfirmaPagto()                      //Metodo para efetuar a confirma��o de pagamento no Pedido 
    Method CancReserva()                        //Metodo para efetuar a cancelamento da reserva

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo construtor da Classe

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cProcesso) Class RmiEnvProtheusObj
    
    _Super:New("PROTHEUS",cProcesso)

    self:aExecAuto := {}

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PreExecucao
Metodo com as regras para efetuar conex�o com o sistema de destino
Exemplo obter um token

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method PreExecucao() Class RmiEnvProtheusObj
    //Como ja estamos no protheus n�o temos que efetuar nenhum procedimento
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CarregaBody
Metodo que carrega a propriedade self:aExecAuto com os dados que ser�o atualizado na base do Protheus

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method CarregaBody() Class RmiEnvProtheusObj

    Local aTags      := {}
    Local nTag       := 0
    Local aTagsSec   := {}
    Local nTagSec    := 0
    Local nTabelaSec := 0
    Local nItem      := 0   
    Local aItem      := {}
    Local xConteudo  := ""
    Local cSetFil    := ''

    //Inicializa o array que ira conter os dados de grava��o
    Asize(self:aExecAuto, 0)
    Aadd( self:aExecAuto, {})

    If self:oPublica:hasProperty("configPSH")
        self:oPublica:DelName("configPSH")
    EndIf

    //Retorno o nome das tags do objeto publica
    aTags := self:oPublica:GetNames()
    If UPPER(Alltrim(self:cProcesso)) == "INVENTARIO" 
        Aadd(self:aSecundaria, "SB7")  //Para Ajustar a tabela cabe�alho e item de uma mesma tabela Modelo 2 
    EndIf
    
    For nTag := 1 To Len(aTags)

        //Carrega as tabelas secundarias do processo
        If Ascan(self:aSecundaria, aTags[nTag]) > 0

            //Verifica se veio algum item
            If self:oPublica[ aTags[nTag] ] == Nil .Or. Len( self:oPublica[ aTags[nTag] ] ) == 0
                Aadd(self:aExecAuto, {})
            Else

                //Para cada tabela secundaria ser� criado um novo item no aExecAuto
                Aadd(self:aExecAuto, {})
                nTabelaSec := Len(self:aExecAuto)

                For nItem:=1 To Len(self:oPublica[ aTags[nTag] ])

                    //Pega o nome das tags da tabela secundaria, carrega por item porque cada item pode ter tags diferentes
                    aTagsSec := self:oPublica[ aTags[nTag] ][nItem]:GetNames()

                    //Carrega campos
                    For nTagSec:=1 To Len(aTagsSec)

                        xConteudo := self:oPublica[ aTags[nTag] ][nItem][ aTagsSec[nTagSec] ]

                        If GetSX3Cache(aTagsSec[nTagSec], "X3_TIPO") == "D"
                            xConteudo := StoD(xConteudo)
                        EndIf
                        //Quando o xConteudo == NIL gera erro.log ERROR: Tipos permitidos: STRING, DATE, NUMERIC, LOGICAL
                        If xConteudo == NIL //Tratamento para n�o adicionar Nil ao conteudo do campo.
                            If GetSX3Cache(aTagsSec[nTagSec], "X3_TIPO") == "N"
                                xConteudo := 0
                            EndIf
                            If GetSX3Cache(aTagsSec[nTagSec], "X3_TIPO") == "C"
                                xConteudo := ""
                            EndIf    
                        EndIf 
                        Aadd(aItem, {aTagsSec[nTagSec], xConteudo, Nil} )
                    Next nTagSec

                    //Carrega item
                    Aadd(self:aExecAuto[nTabelaSec], aClone(aItem) )
                    aSize(aItem, 0)

                Next nItem

            EndIf

        //Carrega tabela principal do processo
        Else

            xConteudo := self:oPublica[ aTags[nTag] ]
            cSetFil := IIF('_FILIAL' $ Alltrim(aTags[nTag]),self:oPublica[ aTags[nTag] ],'')
            
            If !Empty(cSetFil)
                RmiFilInt(cSetFil,.T.)//Atuliza cfilAnt .T. 
            EndIf    
            
            If GetSX3Cache(aTags[nTag], "X3_TIPO") == "D"
                xConteudo := StoD(xConteudo)
            EndIf

            Aadd(self:aExecAuto[1], {aTags[nTag], xConteudo, Nil} )
        EndIf

    Next nTag

    //Atualiza o body para ser gravado no distribui��o MHR_ENVIO
    self:cBody := VarInfo("self:aExecAuto", self:aExecAuto, Nil, .F., .F.)

    Asize(aTags   , 0)
    Asize(aTagsSec, 0)
    aSize(aItem   , 0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Envia
Grava as informa��es recebidas na distribui��o no protheus

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Envia() Class RmiEnvProtheusObj

    Local aAux          := {}
    Local nPos          := 0
    Local cEvento       := ""
    Local cProcesso     := AllTrim(self:cProcesso)
    Local bErrorBlock   := Nil
    Local lErrorBlock   := .F.
    Local cErrorBlock   := ""


    LjGrvLog("RMIENVPROTHEUSOBJ", "Envia() - Iniciada grava��o do processo " + cProcesso + " no Protheus")

    //Condi��o que pode dar erro
    bErrorBlock := ErrorBlock( {|oErro| RmiErroBlock(oErro, @lErrorBlock, @cErrorBlock)} )
    Begin Sequence
        
        Do Case 

            Case cProcesso == "VENDA"
                
                If MHQ->(ColumnPos("MHQ_UUID")) > 0
                    Aadd(self:aExecAuto[1],{"L1_UMOV",MHQ->MHQ_UUID,NIL})//Adiciona o Rastreio UUID na venda.
                Else
                    LjGrvLog("RMIENVPROTHEUSOBJ","Campo MHQ_UUID n�o consta na base. Efetue o seu cadastro via SIGACFG ou aplica��o de UPDDSTR")
                EndIf

                //Tratamento de Venda\Cancelamento para processamento do RmiRetailJob
                nPos := Ascan(self:aExecAuto[1], {|x| x[1] == "L1_SITUA"})
                cEvento := IIF(self:cEvento == "1", "IP", "IC") //1=Upsert, 2=Delete, 3=Inutilizacao
                If nPos > 0
                    self:aExecAuto[1][nPos][2] := cEvento                 
                Else
                    Aadd(self:aExecAuto[1], {"L1_SITUA", cEvento , Nil} )
                EndIf
                //Para evitar que seja criado SL1 Duplicada.
                If self:cEvento == "1" //Nao validar para cancelamento e Inutiliza��o.
                    aAux := RmiVldVend(MHQ->MHQ_UUID,self:aExecAuto[1])//Valida se a venda j� existe na SL1.    
                else
                    aAux := {.T.,""} //Nao validar para cancelamento e Inutiliza��o.
                EndIf    
                
                If aAux[1] //Retorna .F. para Valida se a venda j� existe na SL1.
                    //Chama grava��o de venda\cancelamento  e inutiliza��o utilizada pelo RMI
                    aAux := RsGrvVenda(self:aExecAuto[1], IIF(Len(self:aExecAuto) >= 2,self:aExecAuto[2],{}), IIF(Len(self:aExecAuto) >= 3,self:aExecAuto[3],{}), 3)

                    If aAux[1]

                        self:lSucesso       := .T.
                        self:cChaveExterna  := self:cChaveUnica
                        self:cChaveUnica    := SL1->L1_FILIAL + "|" + SL1->L1_NUM
                        self:cRetorno       := I18n(STR0001, {self:cChaveUnica})    //"Venda gerada #1"
                    Else

                        self:lSucesso := .F.
                        self:cRetorno := aAux[2]
                    EndIf
                Else
                    self:lSucesso := .F.
                    self:cRetorno := aAux[2]
                EndIf
            Case cProcesso == "CLIENTE"

                //Dentro da funcao RmiGrvCli chama o ExecAuto do MATA030
                aAux := RmiGrvCli(self:aExecAuto)

                If aAux[1]
                    LjGrvLog("RMIENVPROTHEUSOBJ", "Cliente gravado com sucesso na base do Protheus (SA1)",SA1->A1_FILIAL + "|" + SA1->A1_COD+"|" + SA1->A1_LOJA)
                    self:lSucesso       := .T.
                    self:cChaveExterna  := self:cChaveUnica
                    self:cChaveUnica    := SA1->A1_FILIAL + "|" + SA1->A1_COD +"|" + SA1->A1_LOJA
                    self:cRetorno       := I18n(STR0003, {aAux[1]})    //"Cliente gerado #1"
                Else
                    self:lSucesso       := .F.
                    self:cRetorno       := aAux[2]
                    LjGrvLog("RMIENVPROTHEUSOBJ", "Erro ao Gravar o cliente na base do Protheus (SA1)",self:cRetorno)
                EndIf

            Case cProcesso == "OPERADOR CAIXA"
                
                aAux := RmiGrvOpe(self:aExecAuto, self:cOrigem)

                If ValType(aAux) == 'A' .AND. Len(aAux) > 1
                    If aAux[1]
                        self:lSucesso       := .T.
                        self:cChaveExterna  := self:cChaveUnica
                        self:cChaveUnica    := SA6->A6_FILIAL + "|" + SA6->A6_COD
                        self:cRetorno       := I18n("", {aAux[1]})
                        LjGrvLog("RMIENVPROTHEUSOBJ", "Operador de caixa gravado com sucesso na base do Protheus (SA6)",SA6->A6_FILIAL + "|" + SA6->A6_COD)
                    Else
                        self:lSucesso       := .F.
                        self:cRetorno       := aAux[2]
                        LjGrvLog("RMIENVPROTHEUSOBJ", "Erro ao Gravar o operador de caixa na base do Protheus (SA6)",self:cRetorno)
                    EndIf
                EndIf
            
            Case cProcesso == "INVENTARIO"
                
                aAux := RmiGrvInv(self:aExecAuto, self:cOrigem)

                If ValType(aAux) == 'A' .AND. Len(aAux) > 1
                    If aAux[1]
                        self:lSucesso       := .T.
                        self:cChaveExterna  := self:cChaveUnica //B7_FILIAL+B7_DOC+B7_COD+B7_LOCAL                                                                                                                                
                        self:cChaveUnica    := SB7->B7_FILIAL+"|"+SB7->B7_DOC+"|"+SB7->B7_COD+"|"+SB7->B7_LOCAL
                        self:cRetorno       := I18n(STR0004, {aAux[1]})    //"Operador gerado #1"
                        LjGrvLog("RMIENVPROTHEUSOBJ", "Inventario gravado com sucesso na base do Protheus (SB7)",SB7->B7_FILIAL+"|"+SB7->B7_DOC+"|"+SB7->B7_COD+"|"+SB7->B7_LOCAL)
                    Else
                        self:lSucesso       := .F.
                        self:cRetorno       := aAux[2]
                        LjGrvLog("RMIENVPROTHEUSOBJ", "Erro ao Gravar o Inventario na base do Protheus (SB7)",self:cRetorno)
                    EndIf
                EndIf    
            
            Case cProcesso == "ADMINISTRADORA"
                
                aAux := RmiGrvAdm(self:aExecAuto, self:cChaveUnica)

                If ValType(aAux) == 'A' .AND. Len(aAux) > 1            
                    If aAux[1]
                        self:lSucesso       := .T.
                        self:cChaveExterna  := self:cChaveUnica 
                        self:cChaveUnica    := SAE->AE_FILIAL +"|"+SAE->AE_COD
                        self:cRetorno       := I18n(STR0005, {SAE->AE_FILIAL +"|"+SAE->AE_COD})    //"Adm Financeira gerada #1"
                        LjGrvLog("RMIENVPROTHEUSOBJ", "Adm Financeira gravada com sucesso na base do Protheus (SAE)",SAE->AE_FILIAL +"|"+SAE->AE_COD)
                    Else
                        self:lSucesso       := .F.
                        self:cRetorno       := aAux[2]
                        LjGrvLog("RMIENVPROTHEUSOBJ", "Erro ao Gravar a Adm Financeira na base do Protheus (SAE)",self:cRetorno)
                    EndIf
                EndIf

            Case cProcesso $ "SANGRIA|SUPRIMENTO"
                
                aAux := GrvCXSan(self:aExecAuto)
                
                If ValType(aAux) == 'A' .AND. Len(aAux) > 1            
                    If aAux[1]
                        self:lSucesso       := .T.
                        self:cChaveExterna  := self:cChaveUnica 
                        self:cChaveUnica    := SE5->E5_FILIAL+"|"+dTos(SE5->E5_DATA)+"|"+SE5->E5_BANCO+"|"+SE5->E5_AGENCIA+"|"+SE5->E5_CONTA+"|"+SE5->E5_IDMOVI
                        self:cRetorno       := I18n( STR0006, { AllTrim(self:cProcesso), self:cChaveUnica } )    //"#1 gerado(a): #2"
                    Else
                        self:lSucesso       := .F.
                        self:cRetorno       := aAux[2]
                    EndIf

                    LjGrvLog("RMIENVPROTHEUSOBJ", "Retorno do processamento do(a) " + cProcesso, self:cRetorno)
                EndIf

            Case cProcesso == "NOTA DE ENTRADA"
            
                self:NotaEntrada()
            
            Case cProcesso == "PEDIDO"                            
            
                self:Pedido()

            Case cProcesso == "CONFIRMA PAGTO"

                Begin Transaction
                    If self:aExecAuto[1][Ascan(self:aExecAuto[1], {|x| x[1] == "L1_PAGAMENTO"})][2]
                        self:ConfirmaPagto()   
                    else
                        self:CancReserva()            
                    endIf
                End Transaction

            OTherWise
                self:lSucesso := .F.
                self:cRetorno := I18n(STR0002, {cProcesso, self:cAssinante})   //"Envio de #1 n�o implmentado para o assinante #2"
        End Case

        //Caso tenha algum erro capturado pelo ErrorBlock for�a a saida para o Recover
        If lErrorBlock
            Break
        EndIf

    //Se ocorreu erro
    Recover
        
        self:lSucesso := .F.
        self:cRetorno := I18n(STR0007, {cProcesso}) + CRLF + cErrorBlock    //"N�o foi poss�vel efetuar a grava��o do processo #1 no Protheus."

    End Sequence
    ErrorBlock(bErrorBlock)

    Asize(aAux, 0)

    LjGrvLog("RMIENVPROTHEUSOBJ", "Envia() - Finalizada grava��o do processo " + cProcesso + " no Protheus - Retorno: " + self:cRetorno)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AuxExecAuto
Metodo auxiliar para executar rotinas automaticas

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method AuxExecAuto(bMsExecAuto, cChave)  Class RmiEnvProtheusObj

    Local aErro := {}
    Local cErro := ""
    Local nCont := 0
    Local aArea := GetArea()

	Private lMsHelpAuto     := .T.
	Private lMsErroAuto		:= .F.
    Private lAutoErrNoFile  := .T.  //Define que retorna o erro do MsExecAuto para o array

    //Executa a MsExecAuto
    Eval(bMsExecAuto)

    If lMsErroAuto
        aErro := GetAutoGrLog()

        For nCont := 1 To Len(aErro)
            cErro += AllTrim( aErro[nCont] ) + CRLF
        Next nCont

        self:lSucesso       := .F.
        self:cTipoRet       := "ENVIA"
        self:cRetorno       := cErro
    Else

        self:lSucesso       := .T.
        self:cTipoRet       := ""
        self:cChaveExterna  := self:cChaveUnica
        self:cChaveUnica    := &( cChave )
        self:cRetorno       := I18n( STR0006, { AllTrim(self:cProcesso), self:cChaveUnica } )    //"#1 gerado(a): #2"
    EndIf

    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} NotaEntrada
Metodo com tratamentos especificos para gera��o da nota de entrada

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method NotaEntrada()  Class RmiEnvProtheusObj

    Local aArea    := GetArea()
    Local aAreaSFT := SFT->( GetArea() )
    Local aAreaSF3 := SF3->( GetArea() )
    Local nPos     := Ascan( self:aExecAuto[1], {|x| x[1] == "F1_CHVNFE"} )
    Local cCodRSef := ""

    If nPos > 0 
        cChaveNFE := self:aExecAuto[1][nPos][2]

        If !Empty(cChaveNFE)
            cCodRSef := "100"   //Para gravar o campo F3_CODRET, retorno da SEFAZ 100|Autorizado o uso da NF-e
        EndIf
    EndIf

    //MATA103(xAutoCab,xAutoItens,nOpcAuto,lWhenGet,xAutoImp,xAutoAFN,xParamAuto,xRateioCC,lGravaAuto,xCodRSef,xCodRet,xAposEsp,xNatRend,xAutoPFS)
    bMsExecAuto := { || MsExecAuto( {|x,y,z| MATA103(x,y,z) }, self:aExecAuto[1], self:aExecAuto[2], 3,,,,,,, cCodRSef) } 
    cChave      := "SF1->F1_FILIAL + '|' + SF1->F1_DOC + '|' + SF1->F1_SERIE"
    
    //Chama metodo auxiliar para executar rotinas automaticas
    self:AuxExecAuto(bMsExecAuto, cChave)

    If self:lSucesso .And. !Empty(cChaveNFE)

        LjGrvLog("RmiEnvProtheusObj", "Ajustando SF1 para o SPED adicionando chave.", {"NotaEntrada", cChaveNFE})

        RecLock('SF1', .F.)
            SF1->F1_CHVNFE := cChaveNFE         
        SF1->( MsUnlock() )
        
        SF3->( DbSetOrder(6) )  //F3_FILIAL, F3_NFISCAL, F3_SERIE
        If SF3->( DbSeek(SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE) )

            LjGrvLog("RmiEnvProtheusObj", "Ajustando SF3 para o SPED adicionando chave", {"NotaEntrada", cChaveNFE})

            RecLock('SF3', .F.)
                SF3->F3_CHVNFE := cChaveNFE
                SF3->F3_CODRET = 'M'         
            SF1->( MsUnlock() )
            
            SFT->( DbSetOrder(6) )
            SFT->( DbSeek(SF3->F3_FILIAL + 'E' + SF3->F3_NFISCAL + SF3->F3_SERIE) )   //FT_FILIAL+FT_TIPOMOV+FT_NFISCAL+FT_SERIE    
            While !SFT->( Eof() )                    .And. SFT->FT_FILIAL == SF3->F3_FILIAL .And. SFT->FT_TIPOMOV == "E" .And.;
                  SFT->FT_NFISCAL == SF3->F3_NFISCAL .And. SFT->FT_SERIE == SF3->F3_SERIE

                LjGrvLog("RmiEnvProtheusObj", "Ajustando SFT para o SPED adicionando chave", {"NotaEntrada", cChaveNFE})

                RecLock('SFT', .F.)
                    SFT->FT_CHVNFE := cChaveNFE         
                SFT->( MsUnlock() )
                
                SFT->( DbSkip() )
            EndDo
        Else

            self:lSucesso := .F.
            self:cTipoRet := "ENVIA"
            self:cRetorno := "N�o foi encontrado registro no Livro verificar RmiEnvProtheusObj Ajuste temporario"
            LjGrvLog("RmiEnvProtheusObj", self:cRetorno, {"NotaEntrada", cChaveNFE})
        EndIf
    EndIf

    RestArea(aAreaSF3)
    RestArea(aAreaSFT)
    RestArea(aArea) 

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Pedido
Metodo com tratamentos especificos para gera��o do Pedido

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Pedido() Class RmiEnvProtheusObj

    Local aArea     := GetArea()
    Local aAux      := {}
    Local nPos      := 0
    Local cEvento   := ""
    Local oJson     := Nil

    Aadd(self:aExecAuto[1],{"L1_UMOV",MHQ->MHQ_UUID,NIL})//Adiciona o Rastreio UUID na venda.
    
    //Tratamento de Venda\Cancelamento para processamento do RmiRetailJob
    nPos := Ascan(self:aExecAuto[1], {|x| x[1] == "L1_SITUA"})
    cEvento := IIF(self:cEvento == "1", "PP", "IC") //1=Upsert, 2=Delete, PP = Pagamento Pendente
    If nPos > 0
        self:aExecAuto[1][nPos][2] := cEvento                 
    Else
        Aadd(self:aExecAuto[1], {"L1_SITUA", cEvento , Nil} )
    EndIf
    
    Begin Transaction
        
        If self:cEvento == "1" 
            aAux := self:GravaReserva()//Grava a reserva para gera��o da venda
        else
            aAux := {.T.,""} //Fun��o n�o implementada para cancelamento da reserva
        EndIf    
        
        If aAux[1] 

            //Incluo o cliente no execauto para chamada da grava��o
            self:aExecAuto[1][Ascan(self:aExecAuto[1], {|x| x[1] == "L1_CLIENTE"})][2]  := aAux[3][2]
            self:aExecAuto[1][Ascan(self:aExecAuto[1], {|x| x[1] == "L1_LOJA"})][2]     := aAux[3][3]
            
            // Faz o calculo reverso de IPI antes de gravar a venda
            LjTaxEAI(@self:aExecAuto[1], @self:aExecAuto[2], .F.)

            //Chama grava��o de pedido\cancelamento utilizada pelo RMI
            aAux := RsGrvVenda(self:aExecAuto[1], self:aExecAuto[2], IIF(Len(self:aExecAuto) >= 3,self:aExecAuto[3],{}), 3)

            If aAux[1] .AND. self:lSucesso
                self:lSucesso       := .T.
                self:cChaveExterna  := self:cChaveUnica
                self:cChaveUnica    := SL1->L1_FILIAL + "|" + SL1->L1_NUM
                self:cRetorno       := I18n(STR0001, {self:cChaveUnica})    //"Venda gerada #1"
            EndIf
        EndIf

        If !aAux[1]
            DisarmTransaction()
            self:lSucesso := .F.
            self:cRetorno := aAux[2]
        EndIf

        //Publica Status do Pedido
        If ExistFunc("RmiExeGat")
            oJson := JsonObject():New()

            oJson["filial"]       := xFilial("SL1")
            oJson["pedidoOrigem"] := self:aExecAuto[1][Ascan(self:aExecAuto[1], {|x| x[1] == "L1_ECPEDEC"})][2]
            oJson["status"]       := IIF(self:lSucesso, "reserved", "error")
            oJson["detalhe"]      := JsonObject():New()

            oJson["detalhe"]["mensagem"] := self:cRetorno
        
            RmiExeGat("STATUSPEDIDO", "2", {oJson})

            FwFreeObj(oJson)
        EndIf

    End Transaction

    RestArea(aArea) 

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} GeraReser
Quando estiver processando um pedido, entao prepara os dados
para chamar a rotina de reserva.

@author Bruno Almeida
@since  22/03/2022
@return { .T. }
@uso    RetailSales.prw
/*/
//--------------------------------------------------------
Method GravaReserva()  Class RmiEnvProtheusObj

Local nX            := 0    //Variavel de loop
Local aArea         := GetArea() //Guarda area
Local aCliente      := {} //Recebe o retorno do cadastro de cliente
Local aCabReser     := {} //Recebe campos do cabe�alho da reserva
Local aGridReser    := {} //Recebe campos dos itens da reserva
Local aRet          := {.F.,"",{}}   //Variavel de retorno
Local cResRet       := "" //Recebe o retorno da reserva
Local cReserv       := "" //Codigo da reserva
Local cErro         := "" //Monta mensagem de erro para ser apresentado na reserva de produto
Local nL2FilRes     := Ascan(self:aExecAuto[2][1], {|x| x[1]  == "L2_FILRES"})
Local nL2Prod       := Ascan(self:aExecAuto[2][1], {|x| x[1]  == "L2_PRODUTO"})
Local nL2Local      := Ascan(self:aExecAuto[2][1], {|x| x[1]  == "L2_LOCAL"})
Local nL2Quant      := Ascan(self:aExecAuto[2][1], {|x| x[1]  == "L2_QUANT"})

Local oJson     := JsonObject():New() //Recebe o Json de origem

oJson:FromJson(MHQ->MHQ_MSGORI)

Private nOpcx := 1 //Essa variavel foi declarada como private pois � utilizada dentro do LJGeraSC0 (LOJA701E)

    //Gerando o cadastro de cliente
    aCliente := RsGrvCli(MHQ->MHQ_MSGORI)

    If aCliente[1]        

        For nX := 1 To Len(self:aExecAuto[2])                        

            //Cabe�alho da reserva
            Aadd(aCabReser,{"C0_TIPO","LJ",NiL})
            Aadd(aCabReser,{"C0_DOCRES",MHQ->MHQ_CHVUNI,NiL})
            Aadd(aCabReser,{"C0_SOLICIT",MHQ->MHQ_ORIGEM,NiL})
            Aadd(aCabReser,{"C0_FILRES",self:aExecAuto[2][nX][nL2FilRes][2],NiL})

            //Itens da reserva
            Aadd(aGridReser,{})
            Aadd(aGridReser[1],{"C0_PRODUTO",Padr(self:aExecAuto[2][nX][nL2Prod][2],Tamsx3("B1_COD")[1]),NiL})
            Aadd(aGridReser[1],{"C0_LOCAL",self:aExecAuto[2][nX][nL2Local][2],NiL})
            Aadd(aGridReser[1],{"C0_QUANT",self:aExecAuto[2][nX][nL2Quant][2],NiL})
            Aadd(aGridReser[1],{"C0_VALIDA",dDataBase,NiL})
            Aadd(aGridReser[1],{"C0_EMISSAO",Date(),NiL})
            Aadd(aGridReser[1],{"C0_LOTECTL","",NiL})
            Aadd(aGridReser[1],{"C0_NUMLOTE","",NiL})
            Aadd(aGridReser[1],{"C0_NUMSERI","",NiL})
            Aadd(aGridReser[1],{"C0_LOCALIZ","",NiL})
            Aadd(aGridReser[1],{"C0_OBS","",NiL})
            Aadd(aGridReser[1],{"C0_FILIAL",xFilial("SC0"),NiL})

            cReserv := LOJA704(aCabReser, aGridReser, 1, @cResRet)

            aCabReser   := {}
            aGridReser  := {}

            If Empty(cReserv)
                cErro += STR0008 + " " + AllTrim(self:aExecAuto[2][nX][nL2Prod][2]) + STR0009 + " " + cResRet + " - " + STR0010 + " " + cValToChar(RsSaldoPrd(self:aExecAuto[2][nX][nL2Prod][2])) + CRLF //"N�o foi possivel realizar a reserva para o produto" # ", motivo:" # "Saldo em Estoque:"
            else                                       
                Aadd(self:aExecAuto[2][nX], {"L2_RESERVA",cReserv,""})                    
            EndIf
            
        Next nX

    Else        
        cErro += aCliente[5] + CRLF
    EndIf


If !Empty(cErro)
    LjGrvLog("RmiEnvProtheusObj", cErro, "GravaReserva")
    aRet[1] := .F.
    aRet[2] := cErro
    aRet[3] := aCliente
else
    aRet[1] := .T.
    aRet[2] := cResRet
    aRet[3] := aCliente
EndIF

RestArea(aArea)

Return aRet
//--------------------------------------------------------
/*/{Protheus.doc} ConfirmaPagto
Confirma Pagamento na SL1 ou Cancela a Reserva.

@author Everson S P Junior
@since  22/03/2022
@return { .T. }

/*/
//--------------------------------------------------------
Method ConfirmaPagto()  Class RmiEnvProtheusObj
Local cNumPed_e := self:aExecAuto[1][Ascan(self:aExecAuto[1], {|x| x[1] == "L1_ECPEDEC"})][2]
Local cFilPed   := self:aExecAuto[1][Ascan(self:aExecAuto[1], {|x| x[1] == "L1_FILIAL"})][2] 
Local cQuery    := "" //Armazena a query a ser executada
Local cAlias    := GetNextAlias() //Pega o proximo alias


cQuery := "SELECT R_E_C_N_O_ REC, L1_NUM "
cQuery += "  FROM " + RetSqlName("SL1")
cQuery += " WHERE L1_ECPEDEC = '" + cNumPed_e + "'"
cQuery += "   AND D_E_L_E_T_ <> '*'"
cQuery += "   AND L1_FILIAL = '" + cFilPed + "'"
cQuery += "   AND L1_SITUA = 'PP'"

DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)
LjGrvLog("Confirma Pagamento","[Atualiza Pedido de Venda para 'IP'] Query executada ->",(cAlias)->L1_NUM)
If !(cAlias)->( Eof() )
    SL1->(dbGoto((cAlias)->REC))
    RecLock("SL1",.F.)
    SL1->L1_SITUA := "IP"
    SL1->( MsUnLock() )
EndIf           

(cAlias)->( DbCloseArea() )
Return 
//--------------------------------------------------------
/*/{Protheus.doc} CancReserva
Cancela Reserva e Deleta os Registros da SL1,SL2,SL4

@author Bruno Almeida
@since  22/03/2022
@return { .T. }
@uso    RetailSales.prw
/*/
//--------------------------------------------------------
Method CancReserva()  Class RmiEnvProtheusObj
Local cNumPed_e := self:aExecAuto[1][Ascan(self:aExecAuto[1], {|x| x[1] == "L1_ECPEDEC"})][2]
Local cFilPed   := self:aExecAuto[1][Ascan(self:aExecAuto[1], {|x| x[1] == "L1_FILIAL"})][2] 
Local cQuery    := "" //Armazena a query a ser executada
Local cAlias    := GetNextAlias() //Pega o proximo alias
Local aReserva  := {}


cQuery := "SELECT R_E_C_N_O_ REC, L1_NUM "
cQuery += "  FROM " + RetSqlName("SL1")
cQuery += " WHERE L1_ECPEDEC = '" + cNumPed_e + "'"
cQuery += "   AND D_E_L_E_T_ <> '*'"
cQuery += "   AND L1_FILIAL = '" + cFilPed + "'"
cQuery += "   AND L1_SITUA = 'PP'"

DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)
LjGrvLog("Cancela Reserva ","[Atualiza Pedido de Venda] Cancelamento do Pedido e Reserva ->",(cAlias)->L1_NUM)

If !(cAlias)->( Eof() )
    SL1->(dbGoto((cAlias)->REC))
    LjGrvLog(" Cancelar Reserva ", "Cancelando a reserva e deletando SL1 SL2 SL4 " +;
                                AllTrim(SL1->L1_UMOV) + ". Excluindo a venda L1_FILIAL = " + AllTrim(SL1->L1_FILIAL) +;
                                " L1_NUM = " + AllTrim(SL1->L1_NUM)) 

    RecLock("SL1",.F.)    
    
    //Inicia a exclusao da SL2
    dbSelectArea("SL2")
    SL2->(dbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
    If SL2->(dbSeek(SL1->L1_FILIAL + SL1->L1_NUM))
        While SL2->(!Eof()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == SL1->L1_FILIAL + SL1->L1_NUM
            aReserva := { {SL2->L2_RESERVA ,SL2->L2_LOCAL , SL2->L2_PRODUTO , SL2->L2_LOCAL ,SL2->L2_FILIAL ,"" } }
            Lj7CancRes( aReserva , .T.) //Inicia a exclusao da reserva
            RecLock("SL2",.F.)
            SL2->( DbDelete() )
            SL2->( MsUnLock() )
            SL2->( DbSkip() )
        EndDo
    EndIf
    
    //Inicia a exclusao da SL4
    dbSelectArea("SL4")
    SL4->(dbSetOrder(1)) //L4_FILIAL+L4_NUM+L4_ORIGEM
    If SL4->(dbSeek(SL1->L1_FILIAL + SL1->L1_NUM))
        While SL4->(!Eof()) .AND. SL4->L4_FILIAL + SL4->L4_NUM == SL1->L1_FILIAL + SL1->L1_NUM
            RecLock("SL4",.F.)
            SL4->( DbDelete() )
            SL4->( MsUnLock() )
            SL4->( DbSkip() )
        EndDo
    EndIf

    SL1->( DbDelete() )
    SL1->( MsUnLock() )       
    LjGrvLog(" RmiBuscaObj ", "Reprocessamento da publica��o (MHQ_UUID) " + AllTrim(SL1->L1_UMOV) + ". Venda excluida com sucesso. L1_FILIAL = " + AllTrim(SL1->L1_FILIAL) + "L1_NUM = " + AllTrim(SL1->L1_NUM))  
EndIf

Return
