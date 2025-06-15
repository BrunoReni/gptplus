#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMIBUSCA.CH"
#INCLUDE 'FWLIBVERSION.CH' 

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiBusca
Serviço que busca informações nos Assinantes

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiBusca(cEmpAmb, cFilAmb)

	Local lManual   := (cEmpAmb == Nil .Or. cFilAmb == Nil)
	Local lContinua := .T.
	Local cUser     := '000000'
    Local cSelect   := ""
    Local cTabela   := ""
	
    Default cEmpAmb := ""
	Default cFilAmb := ""

	If !lManual
		lContinua := .F.

		If !Empty(cEmpAmb) .And. !Empty(cFilAmb)
			lContinua := .T.

			//Alterado para RPCSetType(3) para não consumir licença, até identificar qual assinante deve consumir licença.
            RpcSetType(3)
			RpcSetEnv(cEmpAmb, cFilAmb, , ,'LOJ', "RMIBUSCA")
            LjGrvLog(" RmiBusca ", "Iniciou ambiente: ", {cEmpAmb,cFilAmb,cModulo})    
			__CUSERID := cUser
		Else
            LjGrvLog(" RmiBusca ", I18n(STR0001, {"RMIBUSCA"}))
		EndIf
	EndIf

    lContinua := PSHChkJob() //Verifica se o Job está dentro dos parâmetros do cadastro auxiliar de CONFIGURACAO (MIH)       

	If lContinua
	        
        //Trava a execução para evitar que mais de uma sessão faça a execução.
        If !LockByName("RMIBUSCA", .T., .T.)
            LjGrvLog(" RmiBusca ", I18n(STR0002, {"RMIBUSCA"}))
            Return Nil
        EndIf 


        //Seleciona os assinantes com a busca ativa
        cTabela := GetNextAlias()
        cSelect := " SELECT MHO_COD"
        cSelect += " FROM " + RetSqlName("MHO") + " MHO INNER JOIN " + RetSqlName("MHP") + " MHP"
        cSelect +=      " ON MHO_FILIAL = MHP_FILIAL AND MHO_COD = MHP_CASSIN AND MHP_ATIVO = '1' AND MHP_TIPO = '2' AND MHO.D_E_L_E_T_ = MHP.D_E_L_E_T_"   //1=Ativo, 2=Busca
        cSelect += " WHERE MHO_FILIAL = '" + xFilial("MHO") + "' AND MHO.D_E_L_E_T_ = ' '"
        cSelect += " GROUP BY MHO_COD"

        DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)

        While !(cTabela)->( Eof() )

	        StartJob("RmiBusExec", GetEnvServer(), .F./*lEspera*/, cEmpAnt, cFilAnt, AllTrim((cTabela)->MHO_COD), /*cReprocessa*/, /*cProcesso*/)
            Sleep(5000)            
            
            (cTabela)->( DbSkip() )
        EndDo
        (cTabela)->( DbCloseArea() )

        //Libera a execução do login
        UnLockByName("RMIBUSCA", .T., .T.)
	EndIf
    
    //Chama a funcao para o reprocessamento
    If lContinua .AND. ExistFunc("RmiReprocessa")
        RmiReprocessa("CHEF")
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiBusExec
Executa a busca

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiBusExec(cEmpEnv, cFilEnv, cAssinante, cReprocessa, cProcesso)

    Local cSemaforo := ""
    Local oBusca    := Nil
    Local lContinua := .T.
    Local oGrvMsg   := Nil //Instância da classe RmiGrvMsgPubChefObj

    Default cReprocessa := ""
    DEFAULT cProcesso   := ""

    cSemaforo := "RMIBUSEXEC" +"_"+ cEmpEnv +"_"+ cAssinante +"_"+ cProcesso + IIF(Empty(cReprocessa), "", "_" + cReprocessa)

    If cAssinante <> "TERCEIROS"
        RpcSetType(3)        
    EndIF
  
    RpcSetEnv(cEmpEnv, cFilEnv, , , "LOJ", "RmiBusca")

    //Trava a execução para evitar que mais de uma sessão faça a execução.
    If !LockByName(cSemaforo, .T., .T.)
        LjGrvLog(" RmiBusca ", I18n(STR0002, {cSemaforo}))//"Serviço #1 já esta sendo utilizado por outra instância."
        Return Nil
    EndIf

    cAssinante := AllTrim(cAssinante)

    Do Case

        Case cAssinante == "CHEF"
            oBusca := RmiBusChefObj():New()

        Case cAssinante == "LIVE"
            oBusca := RmiBusLiveObj():New()

        Case cAssinante == "PDVSYNC"
            oBusca := RmiBusPdvSyncObj():New()

        Case cAssinante == "TERCEIROS"
            oBusca := RmiBusTerceirosObj():New()
        
        Case "VENDA DIGITAL" $ cAssinante 
            oBusca := RmiBusVenDigObj():New(cAssinante)        
        
        OTherWise
            LjGrvLog("RmiBusca", I18n(STR0003, {cAssinante}))   //"Assinante #1 sem busca implementada."
            lContinua := .F.
    End Case

    //Busca os processos integrados
    If lContinua 
        oBusca:Processa()
    EndIf

    FwFreeObj(oBusca)
    Sleep(2000)

    //Efetua geração da mensagem de publicação MHQ_MENSAG
    Do Case

        Case cAssinante == "CHEF"        
            oGrvMsg := RmiGrvMsgPubChefObj():New()
            oGrvMsg:GeraMsg(cAssinante)

        Case cAssinante == "LIVE"
            oGrvMsg := RmiGrvMsgPubLiveObj():New()
            oGrvMsg:GeraMsg(cAssinante)

        Case cAssinante == "PDVSYNC"
            oGrvMsg := RmiGrvMsgPubPdvSyncObj():New()
            oGrvMsg:GeraMsg()
			
        Case "VENDA DIGITAL" $ cAssinante
            oGrvMsg := RmiGrvMsgPubVenDig():New(cAssinante)
            oGrvMsg:GeraMsg()

        Case cAssinante == "TERCEIROS"
            oGrvMsg := RmiGrvMsgPubTerceirosObj():New()
            oGrvMsg:GeraMsg()
            
        OTherWise
            LjxjMsgErr( I18n("Assinante #1 sem gravação de mensagem implementada.", {cAssinante}), /*cSolucao*/, /*cRotina*/ )
    End Case
    
    If ExistFunc("LojxMetric")
        LojxMetric("UNQ", Alltrim(cAssinante), "integracao-protheus_protheus-smart-hub_total", ".T.", dDatabase+1, Nil, "RMIBUSCA")
    EndIf
    //Limpa o objeto
    FwFreeObj(oGrvMsg)

    //Libera a execução do login
	UnLockByName(cSemaforo, .T., .T.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Função utilizada por rotina colocadas no Schedule

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SchedDef()

    Local aParam  := {}

    aParam := { "P"                 ,;  //Tipo R para relatorio P para processo
                "ParamDef"          ,;  //Pergunte do relatorio, caso nao use passar ParamDef
                /*Alias*/           ,;	
                /*Array de ordens*/ ,;
                /*Titulo*/          }

Return aParam
