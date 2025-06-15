#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "RMIDISTRIB.CH"
#INCLUDE "TRYEXCEPTION.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiDistrib
Serviços que gera as Distribuições

@author  Rafael Tenorio da Costa
@since   08/11/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiDistrib(cEmpAmb, cFilAmb)

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
            
            //Alterado para RPCSetType(3) para não consumir licença
            RpcSetType(3)
			RpcSetEnv(cEmpAmb, cFilAmb, , , "LOJ", "RMIDISTRIB")
            LjGrvLog(" RmiDistrib ", "Iniciou ambiente: ", {cEmpAmb,cFilAmb,cModulo})    
			__CUSERID := cUser
		Else
            LjGrvLog(" RmiDistrib ",I18N(STR0001, {"RmiDistrib"}) )//"Parâmetros incorretos no serviço #1."
		EndIf	
	EndIf

    lContinua := PSHChkJob() //Verifica se o Job está dentro dos parâmetros do cadastro auxiliar de CONFIGURACAO (MIH)     	

	If lContinua
	
		//Trava a execução para evitar que mais de uma sessão faça a execução.
		If !LockByName("RMIDISTRIB", .T., .T.)
            LjGrvLog(" RmiDistrib ",I18N(STR0002, {"RmiDistrib"}) ) //"Serviço #1 já esta sendo utilizado por outra instância."
            Return Nil
		EndIf

        //Seleciona os processos assinados
        cTabela := GetNextAlias()
        cSelect := " SELECT MHP_CPROCE"
        cSelect += " FROM " + RetSqlName("MHP")
        cSelect += " WHERE MHP_FILIAL = '" + xFilial("MHP") + "'"
        cSelect +=      " AND MHP_ATIVO = '1'"      //1=Sim
        cSelect +=      " AND MHP_TIPO = '1'"       //1=Envia
        cSelect +=      " AND D_E_L_E_T_ = ' '"
        cSelect += " GROUP BY MHP_CPROCE"
        
        LjGrvLog(" RmiDistrib ", "Query Seleciona os processos assinados: ", {cSelect})    
        DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)

        While !(cTabela)->( Eof() )

            StartJob("RmiDistSel", GetEnvServer(), .F./*lEspera*/, cEmpAnt, cFilAnt, (cTabela)->MHP_CPROCE )
            Sleep(5000)
            
            (cTabela)->( DbSkip() )
        EndDo
        (cTabela)->( DbCloseArea() )

        //Libera a execução do login
        UnLockByName("RMIDISTRIB", .T., .T.)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiDistSel
Seleciona os registros que serão distribuidos

@author  Rafael Tenorio da Costa
@since   08/11/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiDistSel(cEmpDist, cFilDist, cProcesso)

    Local cSemaforo  := "RMIDISTSEL" +"_"+ cEmpDist +"_"+ AllTrim(cProcesso)
    Local cSelect    := ""
    Local cTabela    := "" 
    Local aAssinante := {}
    Local nAssi      := 0
    Local cFilPub    := ""
    Local aFilPro    := {}

    RpcSetType(3)
    RpcSetEnv(cEmpDist, cFilDist, /*cEnvUser*/, /*cEnvPass*/, "LOJA", "RmiDistSel")
    
    //Trava a execução para evitar que mais de uma sessão faça a execução.
    If !LockByName(cSemaforo, .T., .T.)
        LjGrvLog(" RmiDistrib ",I18N(STR0002, {cSemaforo}) )  //"Serviço #1 já esta sendo utilizado por outra instância."
        Return Nil
    EndIf

    LjGrvLog(" RmiDistrib ", "Seleciona os registros que serão distribuidos")
    //Carrega Assinantes do Processo
    aAssinante := RmiXSql("SELECT MHP_CASSIN, MHP_FILPRO FROM " + RetSqlName("MHP") +;
                         " WHERE MHP_FILIAL = '" + xFilial("MHP") + "' AND MHP_CPROCE = '" + cProcesso +  "' AND MHP_ATIVO = '1' AND MHP_TIPO = '1' AND D_E_L_E_T_ = ' '", "*", /*lCommit*/, /*aReplace*/)

    LjGrvLog(" RmiDistrib ", "Carrega Assinantes do Processo",{aAssinante})
    //Seleciona as publicações de um determinado processo, para serem distribuidas
    cTabela := GetNextAlias()
    cSelect := " SELECT R_E_C_N_O_ AS REGISTRO, MHQ_ORIGEM, MHQ_IDEXT"
    cSelect += " FROM " + RetSqlName("MHQ") 
    cSelect += " WHERE MHQ_FILIAL = '" + xFilial("MHQ") + "' AND MHQ_CPROCE = '" + cProcesso + "' AND MHQ_STATUS = '1' AND D_E_L_E_T_ = ' '"
    
    LjGrvLog(" RmiDistrib ", "Seleciona as publicações de um determinado processo, para serem distribuidas",{cSelect})
    DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)

    While !(cTabela)->( Eof() )

        Begin Transaction

            For nAssi := 1 To Len(aAssinante)

                cFilPub := AllTrim( (cTabela)->MHQ_IDEXT )

                //Avalia a filial do regisro publicado pelo PROTHEUS para distribuir
                If AllTrim( (cTabela)->MHQ_ORIGEM ) == "PROTHEUS" .And. !Empty(cFilPub)

                    aFilPro := StrTokArr( AllTrim(aAssinante[nAssi][2]), ";" )

                    If aScan(aFilPro, {|x| SubStr(x, 1, Len(cFilPub)) == cFilPub}) == 0
                        LjGrvLog(" RmiDistrib ", "Publicação do PROTHEUS não distribuida para o assinante, filial do registro não contemplada.", {cFilPub, cProcesso, (cTabela)->REGISTRO, aAssinante[nAssi]})
                        Loop
                    EndIf
                EndIf

                //Grava distribuição
                RmiDistGrv(aAssinante[nAssi][1], cProcesso, (cTabela)->REGISTRO)

            Next nAssi

        End Transaction

        (cTabela)->( DbSkip() )
    EndDo
    (cTabela)->( DbCloseArea() )

    aSize(aAssinante, 0)
    FwFreeArray(aFilPro)

    //Libera a execução do login
	UnLockByName(cSemaforo, .T., .T.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiDistGrv
Grava a distribuição na tabela MHR - Mensagens Distribuidas
Feito em Function para possibilitar a chamada de outros fontes.

@author  Rafael Tenorio da Costa
@since   08/11/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiDistGrv(cAssinante, cProcesso, nRecnoPub)

    Local aArea := GetArea()
    Local oError:= Nil
    Local cTipo := ""

    MHQ->( DbGoTo(nRecnoPub) )

    //Não distribui publicação onde a origem é igual ao destino
    TRY EXCEPTION
        If !MHQ->( Eof() ) .And. AllTrim(MHQ->MHQ_ORIGEM) <> AllTrim(cAssinante)
            //Gera distribuição
            RecLock("MHR", .T.)

                MHR->MHR_FILIAL := xFilial("MHR")
                MHR->MHR_CPROCE := cProcesso
                MHR->MHR_CASSIN := cAssinante
                MHR->MHR_RECPUB := nRecnoPub        //Antigo relacionamento entre Publicação x Distribuição, foi mantido para não dar erro na chave única.
                MHR->MHR_TENTAT := "0"
                MHR->MHR_STATUS := "1"              //1=A Processar;2=Processada;3=Erro
                MHR->MHR_UIDMHQ := MHQ->MHQ_UUID    //Id unico da MHQ para relacionamento com MHR.

            MHR->( MsUnLock() )
            
            //Atualiza publicação
            RecLock("MHQ", .F.)

                MHQ->MHQ_STATUS := "2"              //1=A Processar;2=Processada;3=Erro
                MHQ->MHQ_DATPRO := Date()
                MHQ->MHQ_HORPRO := Time()

            MHQ->( MsUnLock() )
        EndIf
    CATCH EXCEPTION USING oError
        
        If 'CHAVE DUPLICADA' $ UPPER(oError:Description) .OR. 'DUPLICATE KEY' $ UPPER(oError:Description)
            //Atualiza publicação
            cTipo := MHQ->MHQ_UUID
            LjGrvLog("RmiDistGrv", "RmiDistGrv -> Ocorreu erro ao atualizar MHR, Chave UUID ja existe.", oError:Description)
            
            RecLock("MHQ", .F.)
            MHQ->MHQ_STATUS := "1"              //1=A Processar;2=Processada;3=Erro
            MHQ->MHQ_DATPRO := Date()
            MHQ->MHQ_HORPRO := Time()
            MHQ->MHQ_UUID   := FwUUID("DISTRIB" + AllTrim(cProcesso))    //Gera nova chave unica
            MHQ->( MsUnLock() )
            //Log de Ratriamento
            LjGrvLog("RmiDistGrv", "atualizando Chave unica de: "+cTipo+" para -> "+MHQ->MHQ_UUID)
            
        Else
            //Atualiza publicação
            RecLock("MHQ", .F.)
            MHQ->MHQ_STATUS := "3"              //1=A Processar;2=Processada;3=Erro
            MHQ->MHQ_DATPRO := Date()
            MHQ->MHQ_HORPRO := Time()
            MHQ->( MsUnLock() )
            
            RMIGRVLOG(  "IR"          , "MHQ"           , MHQ->(Recno())    , "DISTRIB" ,;
                oError:Description ,                 ,                   ,               ,;
                .F.           , 1               , MHQ->MHQ_CHVUNI            , MHQ->MHQ_CPROCE,;
                MHQ->MHQ_ORIGEM, MHQ->MHQ_UUID )
        EndIf
        
    ENDTRY
    
    RestArea(aArea)
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
