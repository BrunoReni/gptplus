#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMIGRVMSGPUBPDVSYNCOBJ.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiGrvMsgPubPdvSyncObj
Classe responsável em gravar o Json de publicação no campo MHQ_MENSAG
    
/*/
//-------------------------------------------------------------------
Class RmiGrvMsgPubPdvSyncObj From RmiGrvMsgPubObj

    Method New()            	//Metodo construtor da Classe
    Method Especificos(cPonto)	//Efetua tratamento especificos para a publicação da MHQ_MENSAG.
    Method CarregaXml()         //Carrega o Xml da Sefaz para ficar disponivel para a publicação (oXmlSefaz).

    Method Venda()              //Efetua tratamentos especificos na publicação da venda 
    Method Inutilizacao()       //Efetua os tratamentos especificos na publicação de venda quando é uma inutilização

    Method Gravar()         	//Grava o conteudo no campo MHQ_MENSAGE

    Method AuxIniciaSL4(nSL4, oAux, nPagamento)     //Carrega dados iniciais do pagamento da venda na SL4
    Method Administradora()                         //Carrega dados iniciais do pagamento da venda na SL4

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Bruno Almeida
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cAssinante) Class RmiGrvMsgPubPdvSyncObj 
    Default cAssinante := "PDVSYNC"

    _Super:New(cAssinante)
    self:oBuscaObj  := RmiBusPdvSyncObj():New(cAssinante)

    self:oBuscaObj:oXmlSefaz  := Nil

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Especificos
Efetua tratamento especificos para a publicação da MHQ_MENSAG.

@type    Method
@param   cPonto, Caractere, Define o ponto onde esta sendo chamado o metodo.
@author  Rafael Tenorio da Costa
@version 1.0
@since   01/12/21   
/*/
//--------------------------------------------------------
Method Especificos(cPonto) Class RmiGrvMsgPubPdvSyncObj

    Local cProcesso := AllTrim(self:oBuscaObj:cProcesso)

    If cPonto == "INICIO"
    
        If cProcesso == "VENDA"
            self:CarregaXml()
            // -- Se for Inutilização simplifico o layout para os campos que serão necessarios.
            If self:oBuscaObj:cEvento == "3"
                Self:Inutilizacao()
            EndIf 
        EndIf

    ElseIf cPonto == "FIM"

        If cProcesso == "VENDA"
            self:Venda()
        EndIf

    EndIf

    _Super:Especificos(cPonto)

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} CarregaXml
Carrega o Xml da Sefaz para ficar disponivel para a publicação (oXmlSefaz).

@author  Rafael Tenorio da Costa
@version 1.0
@since   01/12/21   
/*/
//--------------------------------------------------------
Method CarregaXml() Class RmiGrvMsgPubPdvSyncObj

    Local cXml := ""

    //Valida TAG VendaCustodiaXml
    If self:oBuscaObj:oRegistro:HasProperty("VendaCustodiaXml")     .And.;
       ValType(self:oBuscaObj:oRegistro["VendaCustodiaXml"]) == "A" .And.;
       Len(self:oBuscaObj:oRegistro["VendaCustodiaXml"]) > 0

        //Valida TAG Xml - SEFAZ
        If self:oBuscaObj:oRegistro["VendaCustodiaXml"][1]:HasProperty("Xml")           .And.;  
           !Empty( self:oBuscaObj:oRegistro["VendaCustodiaXml"][1]:HasProperty("Xml") )         

            cXml := DeCode64( self:oBuscaObj:oRegistro["VendaCustodiaXml"][1]["Xml"] )

            LjGrvLog( GetClassName(self), "Conteúdo da TAG VendaCustodiaXml após o DeCode64.", cXml )

            self:oBuscaObj:oXmlSefaz := RmiXmlSefaz():New(self:oBuscaObj:oRegistro["ModeloFiscal"], cXml)

            If !self:oBuscaObj:oXmlSefaz:getStatus()
                self:lSucesso := self:oBuscaObj:oXmlSefaz:getStatus()
                self:cErro    := self:oBuscaObj:oXmlSefaz:getErro()
            EndIf
        Else

            self:lSucesso := .F.
            self:cErro    := I18n(STR0001, {"[Xml] - SEFAZ", "MHQ_MSGORI"})     //"TAG #1 inválida, verifique se a TAG exite e tem conteúdo: campo #2."
        EndIf   
    Else

        self:lSucesso := .F.
        self:cErro    := I18n(STR0002, {"VendaCustodiaXml", "MHQ_MSGORI"})      //"TAG #1 inválida, verifique se a TAG tem conteúdo e o mesmo é um array: campo #2."
    EndIf

    LjGrvLog( GetClassName(self), "Processando TAG VendaCustodiaXml.", {self:lSucesso, self:cErro} )

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Venda
Efetua tratamentos especificos na publicação da venda 

@author  Rafael Tenorio da Costa
@version 1.0
@since   01/12/21   
/*/
//--------------------------------------------------------
Method Venda() Class RmiGrvMsgPubPdvSyncObj

    Local nPagamento := 0
    Local nPagItems  := 0
    Local nSL4       := 0
    Local oAux       := Nil
    Local nAux       := 0
    Local cAdminis   := ""
    Local aDadosComp := {}
    Local cForma     := ""

    self:oPublica["SL4"] := {}

    //Nao executar quando for Inutlização
    If self:oBuscaObj:cEvento != '3'

        For nPagamento:=1 To Len(self:oBuscaObj:oRegistro["VendaPagamentos"])

            cAdminis    := ""
            aDadosComp  := {}
            cForma      := LjAuxPosic('FORMA DE PAGAMENTO', 'MIH_ID', self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]['PagamentoForma']['IdRetaguarda'], 'forma')

            //Tratamento para o Vale Troca
            If Alltrim(cForma) == "CR" .OR. (self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]:HasProperty("VendaPagamentoTrocas") .And. Len(self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]["VendaPagamentoTrocas"]) > 0)

                self:oPublica["L1_CREDITO"] :=  self:oBuscaObj:AuxTrataTag("L1_CREDITO", self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]["ValorPago"])

            //Processamento de Venda\Cancelamento
            Else
            
                If Len(self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]["VendaPagamentoItems"]) == 0

                    //Carrega dados iniciais do pagamento da venda na SL4
                    self:AuxIniciaSL4(@nSL4, @oAux, nPagamento)

                    self:oPublica["SL4"][nSL4]["L4_VALOR"] := self:oBuscaObj:AuxTrataTag("L4_VALOR", oAux["ValorPago"])
                Else

                    //Carrega Administradora
                    cAdminis := self:Administradora(self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento])

                    //Carrega Dados Complementars
                    oAux := self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]["VendaPagamentoDadoComplementars"]
                    For nAux:=1 To Len(oAux)
                        
                        If oAux[nAux]:HasProperty("PagamentoDadoComplementar")

                            Aadd( aDadosComp, { AllTrim( LjAuxPosic("COMPLEM PAGAMENTO", "MIH_ID", oAux[nAux]["PagamentoDadoComplementar"]["IdRetaguarda"], "campoProtheus") ), oAux[nAux]["Conteudo"] } )
                        Else

                            self:lSucesso := .F.
                            self:cErro    := "Ops! Venda recebida com formato incorreto, atualize os serviços de integração do PDV. (TAG PagamentoDadoComplementar não encontrada)"
                            Exit
                        EndIf
                    Next nAux

                    For nPagItems:=1 To Len(self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]["VendaPagamentoItems"])

                        //Carrega dados iniciais do pagamento da venda na SL4
                        self:AuxIniciaSL4(@nSL4, @oAux, nPagamento)

                        //VendaPagamentos
                        self:oPublica["SL4"][nSL4]["L4_ADMINIS"] := cAdminis

                        //VendaPagamentoDadoComplementars
                        For nAux:=1 To Len(aDadosComp)
                            If !Empty(aDadosComp[nAux][1])
                                self:oPublica["SL4"][nSL4][aDadosComp[nAux][1]] := aDadosComp[nAux][2]
                            EndIf
                        Next nAux

                        //VendaPagamentoItems
                        oAux := self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]["VendaPagamentoItems"][nPagItems]

                        self:oPublica["SL4"][nSL4]["L4_DATA"]  := self:oBuscaObj:AuxTrataTag("L4_DATA" , oAux["DataVencimento"] )
                        self:oPublica["SL4"][nSL4]["L4_VALOR"] := self:oBuscaObj:AuxTrataTag("L4_VALOR", oAux["ValorParcela"]   )

                        //VendaPagamentoTefs - Será um array com 1 posição
                        If self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]:HasProperty("VendaPagamentoTefs")

                            oAux := self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]["VendaPagamentoTefs"]

                            If ValType(oAux) == "A" .And. Len(oAux) > 0
                                self:oPublica["SL4"][nSL4]["L4_AUTORIZ"]   := self:oBuscaObj:AuxTrataTag("L4_AUTORIZ" , oAux[1]["NumeroAutorizacao"]                                )
                                self:oPublica["SL4"][nSL4]["L4_NSUTEF"]    := StrZero( Val( self:oBuscaObj:AuxTrataTag("L4_NSUTEF", oAux[1]["NsuHost"]) ), 6                        )
                                self:oPublica["SL4"][nSL4]["L4_BANDEIR"]   := self:oBuscaObj:AuxTrataTag("L4_BANDEIR" , oAux[1]["Bandeira"]                                         )
                                self:oPublica["SL4"][nSL4]["L4_PARCTEF"]   := self:oBuscaObj:AuxTrataTag("L4_PARCTEF" , oAux[1]["NumeroParcelas"]                                   )
                                self:oPublica["SL4"][nSL4]["L4_REDEAUT"]   := self:oBuscaObj:AuxTrataTag("L4_REDEAUT" , oAux[1]["CodigoRede"]                                       )
                                self:oPublica["SL4"][nSL4]["L4_DATATEF"]   := self:oBuscaObj:AuxTrataTag("L4_DATATEF" , StrTran( Substr(oAux[1]["DataCadastro"], 1, 10), "-", "")   )
                                self:oPublica["SL4"][nSL4]["L4_HORATEF"]   := self:oBuscaObj:AuxTrataTag("L4_HORATEF" , StrTran( Substr(oAux[1]["DataCadastro"], 12, 8), ":", "")   )
                                self:oPublica["SL4"][nSL4]["L4_DOCTEF"]    := self:oBuscaObj:AuxTrataTag("L4_NSUTEF"  , oAux[1]["NsuHost"]                                          )
                            EndIf
                        EndIf

                    Next nPagItems
                EndIf
            EndIf
        Next nPagamento
    EndIf

    oAux := Nil
    FwFreeObj(oAux)
    FwFreeArray(aDadosComp)

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} AuxIniciaSL4
Carrega dados iniciais do pagamento da venda na SL4

@type    Method
@param   nSL4, Numerico, Quantidade de itens já incluidos na SL4
@param   oAux, JsonObject, Com o conteudo da TAG["VendaPagamentos"]
@param   nPagamento, Numerico, Numero do pagamento

@author  Rafael Tenorio da Costa
@version 1.0
@since   22/12/21   
/*/
//--------------------------------------------------------
Method AuxIniciaSL4(nSL4, oAux, nPagamento) Class RmiGrvMsgPubPdvSyncObj

    Aadd(self:oPublica["SL4"], JsonObject():New())
    nSL4 := Len(self:oPublica["SL4"])

    self:oPublica["SL4"][nSL4]["L4_FILIAL"] := self:oPublica["L1_FILIAL"]

    //VendaPagamentos
    oAux := self:oBuscaObj:oRegistro["VendaPagamentos"][nPagamento]
    
    self:oPublica["SL4"][nSL4]["L4_FORMA"] := self:oBuscaObj:AuxTrataTag("L4_FORMA" , LjAuxPosic('FORMA DE PAGAMENTO', 'MIH_ID', oAux['PagamentoForma']['IdRetaguarda'], 'forma'))
    self:oPublica["SL4"][nSL4]["L4_TROCO"] := self:oBuscaObj:AuxTrataTag("L4_TROCO" , oAux["ValorTroco"])

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Gravar
Grava o conteudo no campo MHQ_MENSAGE

@author  Rafael Tenorio da Costa
@version 1.0
@since   01/12/21   
/*/
//--------------------------------------------------------
Method Gravar() Class RmiGrvMsgPubPdvSyncObj

    _Super:Gravar()

    FwFreeObj(self:oBuscaObj:oXmlSefaz)
    self:oBuscaObj:oXmlSefaz := Nil

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Inutilizacao
Metodo responsavel por fornecer a origem dos dados que serão necessarios para uma inutilização

@author  Lucas Novais (lnovais@)
@version 1.0
@since   19/07/22 
/*/
//--------------------------------------------------------

Method Inutilizacao() Class RmiGrvMsgPubPdvSyncObj
    //Prepara os dados e envia para a classe PAI

      nPos :=  Ascan(self:oBuscaObj:oRegistro['VendaCustodiaXml'], {|x| x['TipoXml'] == 3})

        If nPos > 0

            _Super:Inutilizacao("&self:oRegistro['Loja']['IdRetaguarda']",;
                                "&self:oRegistro['Ccf']",;
                                "&self:LayEstAuto('LG_SERIE')",;
                                "&LjAuxPosic('OPERADOR DE LOJA', 'MIH_ID', self:oRegistro['Operador']['IdRetaguarda'], 'banco')",;
                                "IC",;
                                "&self:oRegistro['VendaCustodiaXml'][" + cValToChar(nPos) + "]['DataAutorizacao']",;
                                "&self:oRegistro['VendaCustodiaXml'][" + cValToChar(nPos) + "]['NumeroAutorizacao']",;
                                "&self:oRegistro['VendaCustodiaXml'][" + cValToChar(nPos) + "]['ChaveAcesso']",;
                                "&self:oRegistro['VendaCustodiaXml'][" + cValToChar(nPos) + "]['DescricaoRetorno']",;
                                "&self:oRegistro['VendaCustodiaXml'][" + cValToChar(nPos) + "]['CodigoRetorno']",;
                                "&self:LayEstAuto('LG_PDV')")
        EndIf 

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Administradora
Retorna a administradora da venda

@type    Method
@param   oVendaPagamentos, JsonObjeto, Json da venda a aprtir do nó VendaPagamentos
@return  Caractere, Código da Administradora
@author  Rafael Tenorio da Costa
@version 1.0
@since   22/12/21   
/*/
//--------------------------------------------------------
Method Administradora(oVendaPagamentos) Class RmiGrvMsgPubPdvSyncObj

    Local cRetorno  := ""
    Local cSql      := ""
    Local aSql      := {}

    Do Case

        Case oVendaPagamentos:HasProperty("PagamentoOperadora") .And. oVendaPagamentos["PagamentoOperadora"] <> Nil
            cRetorno := oVendaPagamentos["PagamentoOperadora"]["IdRetaguarda"]

        Case oVendaPagamentos:HasProperty("PagamentoCondicao") .And. oVendaPagamentos["PagamentoCondicao"] <> Nil
            cRetorno := oVendaPagamentos["PagamentoCondicao"]["IdRetaguarda"]

        Case oVendaPagamentos:HasProperty("VendaPagamentoTefs") .And. Len(oVendaPagamentos["VendaPagamentoTefs"]) > 0 

            cSql    := " SELECT AE_COD, AE_DESC"
            cSql    += " FROM " + RetSqlName("MDE") + " MDE INNER JOIN " + RetSqlName("SAE") + " AE"
            cSql    +=      " ON MDE_FILIAL = AE_FILIAL AND MDE_CODIGO = AE_ADMCART"
            cSql    += " WHERE MDE_FILIAL = '" + xFilial("MDE") + "'"
            cSql    +=      " AND MDE_CODSIT = '" + oVendaPagamentos["VendaPagamentoTefs"][1]["Bandeira"] + "'"
            cSql    +=      " AND MDE.D_E_L_E_T_ = ' '"
            cSql    +=      " AND AE.D_E_L_E_T_ = ' '"

            aSql := RmiXSql(cSql, "*", /*lCommit*/, /*aReplace*/)

            If Len(aSql) > 0 
                cRetorno := AllTrim(aSql[1][1])
            Else
                self:lSucesso := .F.
                self:cErro    := "Administrador Financeira não localizada a partir do VendaPagamentoTefs, verifique as tabelas SAE e MDE. (" + cSql + ")"
            EndIf
    EndCase

Return cRetorno
