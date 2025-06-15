#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMIENVIA.CH"
#INCLUDE 'FWLIBVERSION.CH' 

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiEnvia
Serviços que ira enviar as distribuições para os destinos

@author  Rafael Tenorio da Costa
@since   
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiEnvia(cEmpAmb, cFilAmb)

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

			//Normalmente utiliza-se RPCSetType(3) para informar ao Server que a RPC não consumirá licenças
            RpcSetType(3) // Para não consumir licenças nas Threads
			RpcSetEnv(cEmpAmb, cFilAmb, , ,"LOJ", "RMIENVIA")
            LjGrvLog(" RmiEnvia ", "Iniciou ambiente: ", {cEmpAmb,cFilAmb,cModulo})
			__CUSERID := cUser
		Else
            LjGrvLog(" RMIENVIA ",I18N(STR0001, {"RMIENVIA"}) )//"Parâmetros incorretos no serviço #1."
		EndIf
	EndIf

	LjGrvLog(" RmiEnvia ","Iniciando: "+" cEmpImp = " + cEmpAmb+" cFilImp = "+cFilAmb )
    
    lContinua := PSHChkJob() //Verifica se o Job está dentro dos parâmetros do cadastro auxiliar de CONFIGURACAO (MIH)   

	If lContinua
        LjGrvLog(" RmiEnvia ","lContinua: .T. ")
		//Trava a execução para evitar que mais de uma sessão faça a execução.
		If !LockByName("RMIENVIA", .T., .T.)
            LjGrvLog(" RMIENVIA ",I18N(STR0002, {"RMIENVIA"}) ) //"Serviço #1 já esta sendo utilizado por outra instância."
            Return Nil
		EndIf

        //Seleciona os assinantes
        cTabela := GetNextAlias()
        cSelect := " SELECT MHO_COD,MHP_CPROCE"
        cSelect += " FROM " + RetSqlName("MHO") + " MHO INNER JOIN " + RetSqlName("MHP") + " MHP"
        cSelect +=      " ON MHO_FILIAL = MHP_FILIAL AND MHO_COD = MHP_CASSIN AND MHP_ATIVO = '1' AND MHP_TIPO = '1' AND MHO.D_E_L_E_T_ = MHP.D_E_L_E_T_"   //1=Ativo, 1=Envia
        cSelect += " WHERE MHO_FILIAL = '" + xFilial("MHO") + "' AND MHO.D_E_L_E_T_ = ' '"
        
        LjGrvLog(" RMIENVIA ", "Antes do While QUERY Seleciona os assinantes: "+cSelect )    
        DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)
        
        While !(cTabela)->( Eof() )
            
	        StartJob("RmiEnvExec", GetEnvServer(), .F./*lEspera*/, cEmpAnt, cFilAnt, AllTrim((cTabela)->MHO_COD),AllTrim((cTabela)->MHP_CPROCE))            
            Sleep(5000)
            
            If FindFunction("RMISTAEXE") .AND. AllTrim((cTabela)->MHO_COD) == 'LIVE'  //Apenas faz a chamada o Tratamento de execução está dentro do RMISTAEXE
                LjGrvLog(" RMIENVIA ", "Vai executar (RMISTAEXE) com o Processo: " +  AllTrim((cTabela)->MHP_CPROCE))
                StartJob("RMISTAEXE", GetEnvServer(), .F./*Não lEspera*/, cEmpAnt, cFilAnt, AllTrim((cTabela)->MHP_CPROCE))
                Sleep(5000)
            EndIf

            (cTabela)->( DbSkip() )
        EndDo
   
        (cTabela)->( DbCloseArea() )

        //Atualiza status de envio caso exista assinante PDVSYNC
        MHO->( DbSetOrder(1) )  //MHO_FILIAL + MHO_COD
        If ExistFunc("RmiStsPdvS") .And. MHO->( DbSeek(xFilial("MHO") + "PDVSYNC") )
            LjGrvLog(" RMIENVIA ", "Vai executar (RmiStsPdvS) " )
            StartJob("RmiStsPdvS", GetEnvServer(), .F./*Não lEspera*/, cEmpAnt, cFilAnt)
        EndIf

        //Libera a execução do login
        UnLockByName("RMIENVIA", .T., .T.)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiEnvExec
Executa o envio

@author  Rafael Tenorio da Costa
@since   
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiEnvExec(cEmpEnv, cFilEnv, cAssinante,cProcesso)

    Local cSemaforo := "RMIENVEXEC" +"_"+ cEmpEnv +"_"+ cAssinante+"_"+cProcesso
    Local oEnvio    := Nil
    Local lContinua := .T.


    If cAssinante <> "TERCEIROS"
        RpcSetType(3)        
    EndIF
   
    RpcSetEnv(cEmpEnv, cFilEnv, , ,"LOJ", "RmiEnvExec")
    
    LjGrvLog(" RmiEnvExec ", "Iniciou ambiente para Empresa, filial e Assinante : ", {cEmpEnv,cFilEnv,cAssinante})
    //Trava a execução para evitar que mais de uma sessão faça a execução.
    If !LockByName(cSemaforo, .T., .T.)
        LjGrvLog(" RmiEnvExec ", I18n(STR0002, {cSemaforo}))  //"Serviço #1 já esta sendo utilizado por outra instância."
        Return Nil
    EndIf
    ConOut("RmiEnvExec - thread start : "+cSemaforo)
    cAssinante := AllTrim(cAssinante)

    Do Case

        Case cAssinante == "CHEF"
            LjGrvLog(" RmiEnvExec ", "Assinante igual a CHEF cria objeto-> oEnvio : ")
            oEnvio := RmiEnvChefObj():New(cProcesso)

        Case cAssinante == "LIVE"
            LjGrvLog(" RmiEnvExec ", "Assinante igual a LIVE cria objeto-> oEnvio : ")
            oEnvio := RmiEnvLiveObj():New(cProcesso)//Passado para Metod New RmiEnvLiveObj iniciar o processo para Live

        Case cAssinante == "PROTHEUS"
            LjGrvLog(" RmiEnvExec ", "Assinante igual a PROTHEUS cria objeto-> oEnvio : ")
            oEnvio := RmiEnvProtheusObj():New(cProcesso)
        
        Case cAssinante == "PDVSYNC"
            LjGrvLog(" RmiEnvExec ", "Assinante igual a PDVSYNC cria objeto-> oEnvio : ")
            oEnvio := RmiEnvPdvSyncObj():New(cProcesso)

        Case "VENDA DIGITAL" $ cAssinante
            LjGrvLog(" RmiEnvExec ", "Assinante igual a VENDA DIGITAL cria objeto-> oEnvio : ")
            oEnvio := RmiEnvVendaDigitalObj():New(cProcesso,cAssinante)

        Case cAssinante == "MOTOR PROMOCOES"
            LjGrvLog(" RmiEnvExec ", "Assinante igual a MOTOR PROMOCOES cria objeto-> oEnvio : ")
            oEnvio := RmiEnvMotorObj():New(cProcesso)

        OTherWise
            LjGrvLog(" RmiEnvExec ", I18n(STR0003, {cAssinante}))//"Assinante #1 sem envio implementado."
            lContinua := .F.

    End Case

    //Envia as distribuições ao assinante
    If lContinua 
    
        If oEnvio:GetSucesso()
            LjGrvLog(" RmiEnvExec ", " executado o oEnvio:GetSucesso() = .T. e vai executar a rotina oEnvio:Processa() ")
            oEnvio:Processa()
        EndIf

        //Gera log de erro
        If !oEnvio:getSucesso()
            LjGrvLog(" RmiEnvExec ", " executado o oEnvio:GetSucesso() = .F. e Vai recuperar o erro ")
            oEnvio:getRetorno()
            LjGrvLog(" RmiEnvExec ",oEnvio:getRetorno())
        EndIf
    EndIf
    
    If ExistFunc("LojxMetric")
        LojxMetric("UNQ", Alltrim(cAssinante), "integracao-protheus_protheus-smart-hub_total", ".T.", dDatabase+1, Nil, "RMIENVIA")
    EndIf
    
    FwFreeObj(oEnvio)

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
