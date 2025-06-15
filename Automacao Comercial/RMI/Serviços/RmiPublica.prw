#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "RMIPUBLICA.CH"
#INCLUDE "TRYEXCEPTION.CH"

Static oError       := Nil      //Objeto que recebe a exceção que ocorreu na execução da query
Static oEnviaObj    := Nil      //Objeto para execução do metodo SetArrayFil
Static aMINAux      := Array(6) // -- Array auxiliar da Tabela MIN

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiPublica
Serviços que gera as Publicações

@type    function
@param 	 cEmpImp, Caractere, Empresa de publicação
@param 	 cFilImp, Caractere, Filial de publicação
@param 	 cPubNova, Caractere, Define se o novo controle de publicação (pelo S_T_A_M_P_) esta ativo 0=Não, 1-Sim 
@author  Rafael Tenorio da Costa
@since   26/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMIPublica(cEmpImp, cFilImp, cPubNova)
    
    Local lManual   := (cEmpImp == Nil .Or. cFilImp == Nil)
	Local lContinua := IIF(lManual, .T., .F.)
	Local cUser     := "000000"
    Local cSemaforo := "RMIPUBLICA"

    Default cPubNova := "0"

    If !lManual

        //Alterado para RPCSetType(3) para não consumir licença
        RpcSetType(3) 
        If RpcSetEnv(cEmpImp, cFilImp, , ,"LOJ", cSemaforo)
            lContinua := .T.
            __CUSERID := cUser
        EndIf

	EndIf

    lContinua := PSHChkJob() //Verifica se o Job está dentro dos parâmetros do cadastro auxiliar de CONFIGURACAO (MIH)   

	If lContinua

        LjGrvLog(cSemaforo, "Ambiente iniciado:", {cEmpImp, cFilImp, cModulo, cPubNova})

    	//Trava a execução para evitar que mais de uma sessão ao mesmo tempo
		If !LockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
            LjxjMsgErr( I18n(STR0002, {cSemaforo}) )    //"Serviço #1 já esta sendo utilizado por outra instância."
            Return Nil
		EndIf

        //Novo controle de publicação pelo S_T_A_M_P_
        If cPubNova == "1"
            SHPPrePub()
        Else
            RmiPrePub()
        EndIf

        //Libera semaforo de controle
        UnLockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
    EndIf

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} RmiPrePub
Função responsavel por buscar os processo que devem gerar publicação considerando as filiais cadastradas

@author  Rafael Tenorio da Costa
@since 	 26/09/19
@version P12.1.17
/*/
//-----------------------------------------------------------------------
Function RmiPrePub()
	
    Local aTable := {}   //Array que ira receber a tabela principal (MHN) e os filhos da tabela (MHS)
    Local nX     := 0    //Variavel de loop

    //Retorna os processos que serão publicados
    aTable := RmiProPub()

    For nX := 1 To Len(aTable)
        StartJob("RmiPubSel", GetEnvServer(), .F./*lEspera*/, cEmpAnt, cFilAnt, aTable[nX] )        
        Sleep(5000)
    Next nX

    LjGrvLog(" RmiPrePub ","Fim do Processamento" )
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiPubSel
Seleciona os registros que serão publicados

@author  Rafael Tenorio da Costa
@since   26/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiPubSel(cEmpPub, cFilPub, aProcesso)

    Local cSemaforo := cEmpPub + cFilPub + aProcesso[1]      
    Local cSelect   := ""
    Local cSelectCab:= ""
    Local cWhereCab := ""
    Local cWhere    := ""
    Local cOrder    := ""
    Local cTabela   := ""
    Local cDB       := ""
    Local cPrefixo  := IIF( SubStr( aProcesso[2], 1, 1) == "S", SubStr( aProcesso[2], 2), aProcesso[2] )
    Local cCmpExp   := cPrefixo + "_MSEXP"
    Local nFil      := 0
    Local cFilter   := ""

    If aProcesso[5] <> "TERCEIROS"
        RpcSetType(3) // Para não consumir licenças na Threads
    EndIF

    RpcSetEnv(cEmpPub, cFilPub, , ,"LOJ" , "RMIPUBSEL")

    If !LockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
        LjxjMsgErr( I18n(STR0002, {cSemaforo}) )    //"Serviço #1 já esta sendo utilizado por outra instância."
        Return Nil
    EndIf

    LjGrvLog("RMIPUBSEL", "Serviço iniciado:", {cEmpPub, cFilPub, aProcesso})  

    cDB := TcGetDB()
    LjGrvLog("RMIPUBSEL", "Conectado com banco de dados:", cDB)
    
    IIF(cDB == "MSSQL",cSelectCab := "SELECT TOP(50) R_E_C_N_O_ AS REGISTRO FROM " + RetSqlName(aProcesso[2]) + "" ,"")
    
    IIF(cDB == "ORACLE",cSelectCab := " SELECT R_E_C_N_O_ AS REGISTRO FROM " + RetSqlName(aProcesso[2]) + "","")
    IIF(cDB == "ORACLE",cWhereCab  := " AND ROWNUM <= 50 " ,"")
    
    IIF(cDB <> "ORACLE" .AND. cDB <> "MSSQL" ,cSelectCab := " SELECT R_E_C_N_O_ AS REGISTRO FROM " + RetSqlName(aProcesso[2]) + "" ,"")
    IIF(cDB <> "ORACLE" .AND. cDB <> "MSSQL" ,cOrder  := " LIMIT 50 " ,"")

    LjGrvLog(" RmiPublica ", "Job RMIPUBSEL iniciado  ")  
    LjGrvLog(" RMIPUBSEL ", "Processo:   ",aProcesso)  
   
    //Valida existencia do campo de controle de exportação
    If (aProcesso[2])->( ColumnPos(cCmpExp) ) == 0
        LjGrvLog(" RMIPUBSEL ",I18n(STR0003, {cCmpExp}))     //"Campo #1 não existe, o serviço de publicação não será executado."
    Else

        //Seleciona os registros que serão publicados inclui tambem os deletados
        cTabela := GetNextAlias()

        MHP->( DbSetOrder(1) )  //MHP_FILIAL + MHP_CASSIN + MHP_CPROCE + MHP_TIPO
        If MHP->( DbSeek( xFilial("MHP") + aProcesso[5] + Padr(aProcesso[1], TamSx3("MHP_CPROCE")[1] ) + "1" ) ) .And. MHP->MHP_ATIVO == "1"

            oEnviaObj := RmiEnviaObj():New(aProcesso[5])
            oEnviaObj:SetArrayFil()

            For nFil:=1 To Len(oEnviaObj:aArrayFil)
                cFilbkp   := cFilAnt
                oEnviaObj:nFil := nFil
                RmiFilInt(oEnviaObj:aArrayFil[nFil][2],.T.)//Atuliza cfilAnt para gerar Xfilial correto.
                
                cSelect := cSelectCab
                LjGrvLog(" RMIPUBSEL ","Query Filial: " + oEnviaObj:aArrayFil[nFil][2])
                
                // -- Publicação olha para as tabelas secundárias? 
                RmiPub4Sec(aProcesso)

                TRY EXCEPTION

                    If !Empty(xFilial(aProcesso[2]))
                        cWhere := " AND " + cPrefixo + "_FILIAL =  '" + xFilial(aProcesso[2]) + "' " 
                    EndIf

                    //Tratamento de macro execução
                    cFilter := aProcesso[4]
                    If SubStr(cFilter, 1, 1) == "&"
                        cFilter := &( AllTrim( SubStr(cFilter, 2) ) )
                    EndIf

                    cWhere  += cWhereCab
                    cSelect +=  " WHERE " + cCmpExp + " = '" + Space( TamSx3(cCmpExp)[1] ) + "'" + IIF(!Empty(cFilter), ' AND ' + AllTrim(cFilter), "") + cWhere
                    
                    // -- Deve ser sempre apos o ORDERBY  caso exista (banco Postgres)
                    cSelect += cOrder

                    LjGrvLog(" RMIPUBSEL ","QUERY Seleciona os registros que serão publicados " + cSelect)
                    DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)
                    
	                If !Empty(cFilbkp)
	                    RmiFilInt(cFilbkp,.T.)//Atuliza cfilAnt .T. 
	                EndIf
                //Se ocorreu erro
                CATCH EXCEPTION USING oError        
                    LjGrvLog(" RMIPUBSEL ","Erro ao executar a query " + AllTrim(cSelect) + ". O erro pode estar ocorrendo pois o filtro cadastrado para a tabela " + aProcesso[2] + " pode estar errado, por favor, verifique no cadastro de processo se o filtro esta cadastrado corretamente. Filtro -> " +  ' AND ' + AllTrim(cFilter))
                ENDTRY           

                //Se for igual a Nil, eh porque não deu erro na execução da query, segue o processo normal
                If oError == Nil

                    //Considera os registros deletados
                    SET DELETED OFF

                    While !(cTabela)->( Eof() )

                        DbSelectArea(aProcesso[2])
                        (aProcesso[2])->( DbGoTo( (cTabela)->REGISTRO ) )

                        If ValidaPub(aProcesso, cTabela)

                            //Grava publicação
                            RmiPubGrv(aProcesso, (cTabela)->REGISTRO, cCmpExp)
                        EndIf

                        (cTabela)->( DbSkip() )
                    EndDo
                    (cTabela)->( DbCloseArea() )

                    //Desconsidera os registros deletados
                    SET DELETED ON

                Else
                    //Se for diferente de Nil, deu erro na query e neste caso apenas limpo a variavel
                    //Essa variavel oError eh apenas uma variavel de controle
                    oError := Nil
                EndIf
            Next nFil

        EndIf

    EndIf

    UnLockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiPubGrv
Grava a publicação na tabela MHQ - Mensagens Publicadas

@author  Rafael Tenorio da Costa
@since   26/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiPubGrv(aProcesso, nRegistro, cCmpExp, lAltExp)

    Local aArea      := GetArea()
    Local aAreasSec  := {}
    Local cJson      := ""
    Local cCmpHrExp  := StrTran(cCmpExp, "_MSEXP", "_HREXP")
    Local nX         := 0                                       //Variavel de loop 
    Local cTabTemp   := ""                                      //Variavel que recebera a tabela temporaria 
    Local cJsonFilho := ""                                      //Variavel que recebera o Json das tabelas filhas 
    Local lControle  := .T.                                     //Variavel de controle do Json das tabelas filhas 
    Local aRecTabSec := {}
    Local lSecObg    := .T.
    Local cProcesso  := aProcesso[1]
    Local cTabela    := aProcesso[2]
    Local aTableFil  := aProcesso[3]
    Local cSecObg    := aProcesso[6]
    Local cChave     := StrTran( aProcesso[8], "+", "+ '|' +" )  //Retorna campos que compoem a chave da publicação

    Default cCmpExp := ""
    Default lAltExp := .T.

    LjGrvLog(" RmiPubGrv ","Grava a publicação na tabela MHQ Function RmiPubGrv",{cProcesso, cTabela, nRegistro, cCmpExp, aTableFil})
    
    (cTabela)->( DbGoTo(nRegistro) )

    If !(cTabela)->( Eof() )

        //Executa funções da etapa de Pré publicação
        If ExistFunc("RmiFunExEt")
            LjGrvLog("RmiPubGrv", "Executando funções da etapa de Pré publicação", cProcesso)
            RmiFunExEt(cProcesso, "1", .T.)
        EndIf

        //Gera publicação da tabela principal
        LjGrvLog("RmiPubGrv", "Gerando publicação da tabela principal", cTabela)
        cJson := GeraJson(cTabela, 0)

        //Executa funções da etapa de Publicação
        If ExistFunc("RmiFunExEt")        
            LjGrvLog("RmiPubGrv", "Executando funções da etapa de Publicação", cProcesso)
            cJson := SubStr(cJson, 1, Len(cJson) - 1) + "," + RmiFunExEt(cProcesso, "2", "")
        EndIf

        //Complementa o cJson com as tabelas filhas
        For nX := 1 To Len(aTableFil) 

            //Executa query da tabela secundaria
            cTabTemp := GeraQuery(cTabela, aTableFil[nX])

            //Se for igual a Nil, eh porque não deu erro na execução da query, segue o processo normal
            If oError == Nil

                lControle   := .T.
                cJsonFilho  := ""

                While !(cTabTemp)->( Eof() )

                    (aTableFil[nX][1])->( DbGoTo( (cTabTemp)->REGISTRO_FILHO ) )

                    Aadd(aRecTabSec,{aTableFil[nX][1],(aTableFil[nX][1])->(RECNO())})
                    
                    If !(aTableFil[nX][1])->(deleted())
                        LjGrvLog(" RmiPubGrv ","chamada da funcao GeraJson(",{aTableFil[nX][1],",1,",lControle})
                        cJsonFilho  += GeraJson(aTableFil[nX][1], 1, lControle, aTableFil[nX][6])
                        LjGrvLog(" RmiPubGrv ","Resultado cJsonFilho GeraJson "+cJsonFilho)
                        lControle   := .F.
                    Else
                        LjGrvLog(" RmiPubGrv ","O Registro " + cValToChar((aTableFil[nX][1])->(RECNO())) + " da tabela: " + aTableFil[nX][1] + " está deletado, por esse motivo será ignorado na geração das tabelas secundarias") 
                    EndIf

                    //Se for DA0 (Preco), entao considera apenas um item pois para o preço (DA0/DA1)
                    //as tabelas sao invertidas, o que eh filho (DA1) vira cabeçalho e o que é cabelho
                    //vira item (DA0). Fizemos isso para não estourar o tamanho de 1 MB do Json
                    If aTableFil[nX][1] == 'DA0'
                        Exit
                    EndIf
                    (cTabTemp)->( DbSkip() )
                EndDo

                If !Empty(cJsonFilho)
                    cJson := SubStr(cJson,1,Len(cJson) - 1) + ',' + SubStr(cJsonFilho,1,Len(cJsonFilho) - 1) + CRLF + "],"
                ElseIf cSecObg = "1" .And. Empty(cJsonFilho)
                    LjGrvLog(" RmiPubGrv ","Processo " +cProcesso+ " : O registro "+cValToChar(nRegistro)+" não será publicado, pois não houve registros na tabela " +aTableFil[nX][1]+ " (campo MHN_SECOBG habilitado).")                
                    lSecObg := .F.
                EndIf

                (cTabTemp)->( DbCloseArea() )   

            Else
                //Caso tenha erro, interrompe o loop e não grava a MHQ
                Exit
            EndIf        

        Next nX

        If oError == Nil 

            cJson := SubStr(cJson,1,Len(cJson) - 1) + CRLF + '}' 
            LjGrvLog(" RmiPubGrv ","Resultado Json que será gravado -> "+cJson)
            Begin Transaction
                If lSecObg

                    GravaMHQ(   cProcesso   ,;
                                cTabela     ,; 
                                (cTabela)->&(cChave) + IIF( (cTabela)->( Deleted() ), "|" + cValToChar( (cTabela)->( Recno() ) ), "")   ,; 
                                cJson       ,; 
                                "1"         )
                EndIf

                //Executa funções da etapa de Pòs publicação
                If ExistFunc("RmiFunExEt")
                    LjGrvLog("RmiPubGrv", "Executando funções da etapa de Pòs publicação", cProcesso)
                    RmiFunExEt(cProcesso, "3", .T.)
                EndIf

                If lAltExp
                    //Atualiza campos de controle de exportação da tabela principal
                    AtuCmpExp(cCmpExp, cCmpHrExp)

                    //-- Atualiza campos de controle de exportação das tabelas secundárias
                    //-- Guardo a Area de todas as tabelas secundárias que serão acessadas 
                    For nX := 1 To Len(aTableFil)
                        Aadd(aAreasSec,(aTableFil[nX][1])->(GetArea()))
                    Next
                    
                    // -- Posiciono e atualizo os campos de controle de publicação em todas as tabelas secundárias
                    For nX := 1 To Len(aRecTabSec)
                        DbSelectArea(aRecTabSec[nX][1])
                        (aRecTabSec[nX][1])->(DBGoTo(aRecTabSec[nX][2]))
                        AtuCmpExp(,,aRecTabSec[nX][1])
                    Next nX

                    // -- Retoro as alias atuais de na ordem decrescente
                    For nX := Len(aAreasSec) To 1 STEP -1
                        RestArea(aAreasSec[nX])
                    Next
                EndIf 

                //Gera os impostos referentes ao Produto.    
                If Alltrim(cProcesso) == "PRODUTO"

                    //IMPOSTO PROD
                    VLDIMPB1("XXX",(cTabela)->&(cChave))

                    //IMPOSTO VENDA
                    VLDIMPB1("YYY",(cTabela)->&(cChave))
                EndIf

            End Transaction
        Else
            //Se for diferente de Nil, deu erro na query e neste caso apenas limpo a variavel
            //Essa variavel oError eh apenas uma variavel de controle
            oError := Nil
        EndIf
    EndIf

    LjGrvLog(" RmiPubGrv ","Fim da Gravação ")
    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraJson
Função que gera o Json com os campos da tabela passada, 
no registro que esta posicionado

@author  Rafael Tenorio da Costa
@since   30/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraJson(cTabela, nTypeJson, lControle, cTipReg)

    Local cJson      := "{"
    Local cTipo      := ""
    Local cCampo     := ""
    Local xConteudo  := ""
    Local nCont      := 1
    Local aStructExp := (cTabela)->( DbStruct() )
    Local cPrefixo   := ""
    
    Default nTypeJson := 0 
    Default lControle := .F.
    Default cTipReg   := ""

    LjGrvLog(" GeraJson "," Function GeraJson(",{cTabela, nTypeJson, lControle, cTipReg})

    If cTabela == "MIL" .and. Empty(cTipReg)
        cJson := ""
        LjGrvLog(" GeraJson "," Não é possivel gerar relacionamento entre as tabela MIL, o campo MHS_TIPO não foi incluido nas tabelas secundarias. Verifique o cadastro de Processo!")
        Return cJson
    EndIf

    If lControle 
        cJson := '"' + cTabela + Iif(Empty(cTipReg),'": [', '_' + Alltrim(cTipReg) + '": [')
        cJson += CRLF + ' { ' 
    EndIf

    If !Empty(aStructExp)
        cCampo    := AllTrim(aStructExp[1][DBS_NAME] )
        cPrefixo  := SubStr(cCampo, 1, at('_',cCampo)-1)
    EndIf

    LjGrvLog(" GeraJson "," aStructExp estrutura da tabela -> ",aStructExp)
    For nCont:=1 To Len(aStructExp)
        
        cTipo     := AllTrim( aStructExp[nCont][DBS_TYPE] )
        cCampo    := AllTrim( aStructExp[nCont][DBS_NAME] )
        xConteudo := (cTabela)->&( cCampo )
        
        //Campos em exceção XXX_USERLGA e XXX_USERLGI
        If cCampo $ (cPrefixo+"_USERLGA|" + cPrefixo+"_USERLGI|" + cPrefixo+"_USERGA|" + cPrefixo+"_USERGI|")
            Loop
        EndIf

        //Trata o conteudo de cada tag
        cJson += Conteudo(cTipo, xConteudo, cCampo)
    Next nCont

    If cTabela == "MIL" .and. !Empty(cTipReg)
        Relacionamento(cTabela,aStructExp,@cJson)
    EndIF

    cJson := SubStr(cJson, 1, Len(cJson)-1)
    If nTypeJson == 1 
        cJson += "},"
    Else
        cJson += "}"
    EndIf

    aSize(aStructExp, 0)

Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraQuery
Gera a query da tabela pai com a(s) tabela(s) filha(s)

@author  Bruno Almeida
@since   31/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraQuery(cTb, aTb)

    Local cQuery        := ""                   //Recebe a query
    Local cCont         := GetNextAlias()       //Recebe o nome do proximo alias
    Local aCab          := Separa(aTb[3],'+')   //Variavel que ira receber a chave do cabecalho
    Local aSec          := Separa(aTb[2],'+')   //Variavel que ira receber a chave das tabelas secundarias
    Local nX            := 0                    //Variavel de loop
    Local cWhereFilha   := ""
    Local cPrefixoSec   := IIF( SubStr( aTb[1], 1, 1) == "S", SubStr( aTb[1], 2), aTb[1] ) 
    Local aAux          := {}
    Local cFilter       := ""

    cQuery := " SELECT B.R_E_C_N_O_ AS REGISTRO_FILHO"
    cQuery += " FROM " + RetSqlName(cTb) + " A"
    cQuery +=       " INNER JOIN " + RetSqlName(aTb[1]) + " B " + " ON " + RetJoin(aTb,,,cTb,aTb[1])
    cQuery += " WHERE "

    For nX := 1 To Len(aSec)
        If aSec[nX] == cPrefixoSec + "_FILIAL" .AND. xFilial(cTb) <> xFilial(aTb[1])
            cQuery += 'B.' + AllTrim(aSec[nX]) + " = '" + xFilial(aTb[1]) + "' AND " 
        Else   
            cQuery += " B." + AllTrim(aSec[nX]) + " = " + RetCont( cTb, AllTrim(aCab[nX]) ) + " AND "
        EndIf 
    Next nX

    //Concatena na query o filtro da tabela filha
    If Len(aTb) >= 4 .AND. !Empty(aTb[4])
        //Tratamento de macro execução
        cFilter := aTb[4]
        If SubStr(cFilter, 1, 1) == "&"
            cFilter := &( AllTrim( SubStr(cFilter, 2) ) )
        EndIf
        cWhereFilha := AllTrim( cFilter) + " AND "
    EndIf

    If "D_E_L_E_T_" $ cWhereFilha
        cWhereFilha := StrTran(cWhereFilha, "D_E_L_E_T_", "B.D_E_L_E_T_")
    Else
        cWhereFilha := cWhereFilha + " B.D_E_L_E_T_ = ' ' AND "
    EndIf

    // -- Tratamento para listar itens deletados das tabelas secundarias caso o campo de controle esteja em branco
    // -- Obs: somente é considerado caso a tabela secundarias seja considerada na publicação (aTb[5] == "1")
    If Len(aTb) >= 5 .AND. aTb[5] == "1"
        aAux := Separa(Alltrim(UPPER(cWhereFilha)), "AND")
        cWhereFilha := ""
        
        For nX := 1 To Len(aAux)
            If "D_E_L_E_T_" $ aAux[nx] .AND. (aTb[1])->(ColumnPos(cPrefixoSec + "_MSEXP")) > 0 
                cWhereFilha += "B.D_E_L_E_T_ = ' ' OR (B.D_E_L_E_T_ = '*' AND B." + cPrefixoSec + "_MSEXP = '" + Space(TamSx3(cPrefixoSec + "_MSEXP")[1]) + "') AND "
            Else
                If !Empty(aAux[nx])
                    cWhereFilha +=  aAux[nX] + " AND "
                EndIf
            EndIf
        Next nX

    EndIf 

    cQuery += cWhereFilha

    cQuery := SubStr(cQuery,1,Len(cQuery) - 4)
    LjGrvLog(" GeraQuery "," aquery da tabela pai com a(s) tabela(s) filha(s) -> ",cQuery)
    
    TRY EXCEPTION
        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cCont, .T., .F.)
        
    //Se ocorreu erro
    CATCH EXCEPTION USING oError        
        LjGrvLog(" RMIPUBSEL ","Erro ao executar a query " + AllTrim(cQuery) + ". O erro pode estar ocorrendo pois o filtro cadastrado para a tabela " + aTb[1] + " pode estar errado, por favor, verifique no cadastro de processo se o filtro esta cadastrado corretamente. Filtro -> " +  " AND " + AllTrim(aTb[4]))
    ENDTRY

Return cCont

//-------------------------------------------------------------------
/*/{Protheus.doc} RetJoin
Retorna o relacionamento entre as tabelas

@author  Bruno Almeida
@since   01/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetJoin(aTb,cCab,cSec,cTabCab,cTabSec)

    Local cRet  := ""       //Variavel de retorno
    Local nX    := 0        //Variavel de loop
    Local lNotMatch :=  .F. // -- Indica se as duas tabelas tem o compartilhamento diferente
    Local cPrefixoSec := "" // -- Prefixo da tabela secundarias

    Local aCab  := IIF(Empty(cCab), Separa(aTb[3],'+'), Separa(cCab,'+')) //Variavel que ira receber a chave do cabecalho
    Local aSec  := IIF(Empty(cSec), Separa(aTb[2],'+'), Separa(cSec,'+')) //Variavel que ira receber a chave das tabelas secundarias
    
    Default cTabCab  := ""
    Default cTabSec  := ""

    If !Empty(cTabCab) .AND. !Empty(cTabSec)
        If lNotMatch := xFilial(cTabCab) <> xFilial(cTabSec)
            cPrefixoSec := IIF( SubStr( cTabSec, 1, 1) == "S", SubStr( cTabSec, 2), cTabSec ) 
        EndIf   
    EndIf 

    For nX := 1 To Len(aCab)

        //Tratamento para chave do cabeçalho com mais campos que as tabelas secundarias
        If nX > Len(aSec)
            Exit
        EndIf

        If lNotMatch .AND. aSec[nX] == cPrefixoSec + "_FILIAL"
            cRet += 'B.' + AllTrim(aSec[nX]) + " = '" + xFilial(cTabSec) + "' AND "   
        Else
            cRet += 'B.' + AllTrim(aSec[nX]) + ' = ' + 'A.' + AllTrim(aCab[nX]) + ' AND '
        EndIf 
    Next nX 

    cRet := SubStr(cRet,1,Len(cRet) - 4)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetValor
Retorna o conteudo do campo que é passado como parametro

@author  Bruno Almeida
@since   01/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetCont(cTb,cCampo)

    Local cTipo     := TamSx3(cCampo)[3] //Pega o tipo do campo
    Local xConteudo := (cTb)->&( cCampo ) //Pega o conteudo do campo

    Do Case
        Case cTipo $ "C|M|L"
            xConteudo := "'" + xConteudo + "'"

        Case cTipo $ "N"
            xConteudo := cValToChar(xConteudo)

        Case cTipo == "D"
            xConteudo := "'" + DtoS(xConteudo) + "'"
        
    End Case

Return xConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} VLDIMPB1
Retorna se existe assinante para imposto do produto

@author  Everson S P Junior
@since   06/01/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static function VLDIMPB1(cTab,cChave)

    Local lRet      := .F.
    Local cTabela   := ""
    Local aFilProc  := {}
    Local nX        := 0
    Local cJsonImp  := ""
    Local cProcesso := IIF(cTab == "XXX", "IMPOSTO PROD", "IMPOSTO VENDA")

    LjGrvLog(" RMIPUBLICA "," Static VLDIMPB1 verifica se existe assinante para imposto do produto ")

    cTabela := GetNextAlias()
    cSelect := " SELECT MHN_COD, MHN_TABELA, MHN_CHAVE, MHS_TABELA, MHS_CHAVE,MHP_FILPRO "
    cSelect += " FROM " + RetSqlName("MHN") + " MHN INNER JOIN " + RetSqlName("MHP") + " MHP"
    cSelect +=      " ON MHN_FILIAL = MHP_FILIAL AND MHN_COD = MHP_CPROCE AND MHN.D_E_L_E_T_ = MHP.D_E_L_E_T_ AND MHN_TABELA = '" + cTab + "' "
    cSelect += " LEFT JOIN " + RetSqlName("MHS") + " MHS "
    cSelect +=      " ON MHS_FILIAL = MHN_FILIAL AND MHS_CPROCE = MHN_COD AND MHS.D_E_L_E_T_ = ' '"
    cSelect += " WHERE MHN.D_E_L_E_T_ = ' ' "
    cSelect += " AND MHP_ATIVO = '1'"      //1=Sim
    cSelect += " AND MHP_TIPO = '1'"       //1=Envia
    cSelect += " GROUP BY MHN_COD, MHN_TABELA, MHN_CHAVE, MHS_TABELA, MHS_CHAVE,MHP_FILPRO"
    DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)

    LjGrvLog(" RMIPUBLICA "," VLDIMPB1 Query para buscar assinante de Imposto Prod -> ",cSelect)

    If !(cTabela)->(Eof())
        LjGrvLog(" RMIPUBLICA ","VLDIMPB1 Gerando Array de Filial do Imposto ")
        aFilProc := StrToKarr( Alltrim((cTabela)->MHP_FILPRO), ";")
        LjGrvLog(" RMIPUBLICA ","VLDIMPB1 Impostos serão gerados para as filiais : ->  ",aFilProc)
        For nX := 1 To Len(aFilProc)

            //Adicionado Sleep para nao gerar chave duplicada(MHQ) mundando o time()
            Sleep(1000)

            JsonImp(@cJsonImp, "", "", aFilProc[nX])//Função para geração de impostos no forma Json

            GravaMHQ(   cProcesso   ,;
                        cTabela     ,; 
                        cChave      ,; 
                        cJsonImp    ,; 
                        "9"         ,;
                        aFilProc[nX])

            LjGrvLog(" RMIPUBLICA ","VLDIMPB1 Gerado Imposto para filial ->  "+aFilProc[nX])
        next    
        
    EndIf

    (cTabela)->( DbCloseArea()) 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiValSf2
Valida se é uma nota de saída de uma venda vinda do Live

@author  Bruno Almeida
@since   14/10/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RmiValSf2(nRecSf2)

    Local aAreaSF2  := SF2->( GetArea() )
    Local lRet      := .F.  //Variavel de retorno
    Local cQuery    := ""   //Armazena a query
    Local cAlias    := ""   //Armazena o próximo alias
    Local cAliasMhq := ""   //Armazena o próximo alias da MHQ

    SF2->(DbGoTo(nRecSf2))

    If SF2->(Recno()) == nRecSf2
        cAlias := GetNextAlias()

        cQuery := "SELECT L1_UMOV "
        cQuery += "     , R_E_C_N_O_"
        cQuery += "  FROM " + RetSqlName("SL1")
        cQuery += " WHERE L1_FILIAL = '" + SF2->F2_FILIAL + "'"
        cQuery += "   AND L1_DOC = '" + SF2->F2_DOC + "'"
        cQuery += "   AND L1_SERIE = '" + SF2->F2_SERIE + "'"

        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)
        If !(cAlias)->(Eof()) .AND. !Empty((cAlias)->L1_UMOV)

            cAliasMhq := GetNextAlias()

            cQuery := ""
            cQuery += "SELECT MHQ_ORIGEM"
            cQuery += "     , R_E_C_N_O_"
            cQuery += "  FROM " + RetSqlName("MHQ")
            cQuery += " WHERE MHQ_UUID = '" + (cAlias)->L1_UMOV + "'"

            DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasMhq, .T., .F.)
            If !(cAlias)->(Eof()) .AND. AllTrim((cAliasMhq)->MHQ_ORIGEM) == "LIVE"
                //Para os Registro de integração sera atualizado o campo _MSEXP
                //Para que não sejam recuperado nas proximas Querys. 
                lRet := .F.
                RecLock("SF2",.F.)
                    SF2->F2_MSEXP := DtoS(dDataBase) 
                SF2->(MsUnLock())
            Else
                lRet := .T.
            EndIf
            (cAliasMhq)->( DbCloseArea())
        Else
            lRet := .T.
        EndIf
        (cAlias)->( DbCloseArea())

    EndIf

    RestArea(aAreaSF2)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaPub
Centraliza as validações que definem se a publicação será gerada.

@author  Rafael Tenorio da Costa
@since   05/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidaPub(aProcesso, cTabela)

    Local aArea    := GetArea()
    Local lRetorno := .T.

    Do Case

        //Valida se é uma nota de saída de uma venda vinda do Live
        Case aProcesso[1] == "NOTA DE SAIDA" .And. aProcesso[2] == "SF2"

            lRetorno := RmiValSf2( (cTabela)->REGISTRO )

        //Valida se a nota fiscal de saida já foi publicada, para publicar o cancelamento de nota fiscal de saida
        Case aProcesso[1] == "NOTA SAIDA CANC"
            lRetorno := ValNfsPub()

    End Case

    RestArea(aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} ValNfsPub
Valida se a nota fiscal de saida já foi publicada, para publicar o cancelamento da nota fiscal de saida

@author  Rafael Tenorio da Costa
@since   05/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValNfsPub()

    Local lRetorno  := .F.
    Local cOrigem   := PadR("PROTHEUS", TamSx3("MHQ_ORIGEM")[1])
    Local cProcesso := PadR("NOTA DE SAIDA", TamSx3("MHQ_CPROCE")[1])
    Local cChaveUni := SF2->&( StrTran( Posicione("MHN", 1, xFilial("MHN") + cProcesso, "MHN_CHAVE"), "+", "+ '|' +" ) )

    MHQ->( DbSetOrder(1) )  //MHQ_FILIAL + MHQ_ORIGEM + MHQ_CPROCE + MHQ_CHVUNI + MHQ_EVENTO + DTOS(MHQ_DATGER) + MHQ_HORGER
    If MHQ->( DbSeek( xFilial("MHQ") + cOrigem + cProcesso + cChaveUni ) )

        lRetorno := .T.
    Else

        //Atualiza campos de controle de exportação
        AtuCmpExp("F2_MSEXP", "F2_HREXP")
        lRetorno  := .F.        
    EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuCmpExp
Atualiza campos de controle de exportação, onde a tabela já deve estar posicionada.

@author  Rafael Tenorio da Costa
@since   05/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuCmpExp(cCmpExp, cCmpHrExp, cTabela)
    
    Local cPrefixo     := ""

    Default cTabela   := FwTabPref(cCmpExp)
    
    // -- Caso não seja enviado os campos monto com base na tabela
    If Empty(cCmpExp) .Or. Empty(cCmpHrExp)
        cPrefixo  := IIF( SubStr( cTabela, 1, 1) == "S", SubStr( cTabela, 2), cTabela )
        cCmpExp   := cPrefixo + "_MSEXP"
        cCmpHrExp := cPrefixo + "_HREXP"
    EndIf 

    RecLock(cTabela, .F.)
        If (cTabela)->( ColumnPos(cCmpExp) ) > 0
            (cTabela)->&( cCmpExp ) := DtoS( Date() )
        EndIf

        If (cTabela)->( ColumnPos(cCmpHrExp) ) > 0
            (cTabela)->&( cCmpHrExp ) := Time()
        EndIf
    (cTabela)->( MsUnLock() )

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

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RmiPub4Sec
Função responsavel por verificar se houve alteração nas tabelas secundárias e caso houver realiza a limpeza do campo _MSEXP

@type       Static Function
@author     Lucas Novais (lnovais@)
@since      14/07/2021
@version    12.1.33
@param aProcesso, Array, processo representado nas tabelas MHN990 e MHS990

@return Nil,Nulo
/*/
//-------------------------------------------------------------------------------------
Static Function RmiPub4Sec(aProcesso)
    
    Local nTabSec   := 0    // -- Variavel de controle (FOR)
    Local cPrefixoS := ""   // -- Prefixo da tabela secundária
    Local cPrefixoP := ""   // -- Prefixo da tabela primaria
    Local cCmpExpS  := ""   // -- Campo de controle da tabela secundária
    Local cCmpExpP  := ""   // -- Campo de controle da tabela primaria
    Local cTabela   := ""   // -- Alias temporario
    Local cCmpsGrp  := ""   // -- Group By utilizado na query
    Local cSelect   := ""   // -- Query completa
    Local aRecsOK   := {}   // -- Variavel que armazenas os recnos já processados
    local lMSEXP    := .F.  // -- Indica se tem o campo de controle 
    Local cFilter   := ""
   

    For nTabSec := 1 To Len(aProcesso[3])

        If aProcesso[3][nTabSec][5] $ "1|3" // -- Indica que é para considerar a secundárias para a publicação
            
            cPrefixoS := IIF( SubStr( aProcesso[3][nTabSec][1], 1, 1) == "S", SubStr( aProcesso[3][nTabSec][1], 2), aProcesso[3][nTabSec][1] )
            cPrefixoP := IIF( SubStr( aProcesso[2], 1, 1) == "S", SubStr( aProcesso[2], 2), aProcesso[2] )
            
            cCmpExpS  := cPrefixoS + "_MSEXP"
            cCmpExpP  := cPrefixoP + "_MSEXP"

            //Tratamento de macro execução
            cFilter := aProcesso[3][nTabSec][4]
            If SubStr(cFilter, 1, 1) == "&"
                cFilter := &( AllTrim( SubStr(cFilter, 2) ) )
            EndIf

            IF !Empty(cFilter)
                cFilter := " AND " + cFilter
            Endif

            lMSEXP := (aProcesso[3][nTabSec][1])->(ColumnPos(cCmpExpS)) > 0

            If lMSEXP

                TRY EXCEPTION
                    cTabela  := GetNextAlias()
                    cCmpsGrp := "A." + StrTran(aProcesso[3][nTabSec][2],"+",", A.")
                    
                    BeginContent var cSelect
                    
                        SELECT TOP(50) B.R_E_C_N_O_ AS RECNO_PRINCIPAL 
                        FROM %Exp:RetSqlName(aProcesso[3][nTabSec][1])% AS A
                        INNER JOIN %Exp:RetSqlName(aProcesso[2])% AS B
                        ON %Exp:RetJoin(,aProcesso[3][nTabSec][2],aProcesso[3][nTabSec][3],aProcesso[3][nTabSec][1],aProcesso[2])%
                        WHERE A.%Exp:cCmpExpS% = '%Exp:Space(TamSx3(cCmpExpS)[1])%' 
                        AND A.%Exp:cPrefixoS%_FILIAL = '%Exp:xFilial(aProcesso[3][nTabSec][1])%'
                        %Exp:cFilter%
                        GROUP BY %Exp:cCmpsGrp% ,B.R_E_C_N_O_

                    EndContent

                    DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)
                    LjGrvLog(" RmiPub4Sec ","QUERY Seleciona os registros secundárias que serão publicados " + cSelect)

                CATCH EXCEPTION USING oError
                    LjGrvLog(" RmiPub4Sec ","Erro ao executar a query " + AllTrim(cSelect))
                    LjGrvLog(" RmiPub4Sec ","ERROR " + AllTrim(oError:Description))
                ENDTRY
            Else
                LjGrvLog(" RmiPub4Sec ","Campo [" + cCmpExpS  + "] não criado na tabela [" + aProcesso[3][nTabSec][1] + "]. Tabela não será considerada na geração da publicação." )
                LjGrvLog(" RmiPub4Sec ","Com isso, caso a tabela [" + aProcesso[3][nTabSec][1] + "] sofra alteração não será gerada publicação por meio dela." )
            EndIf 

            If oError == Nil .And. lMSEXP
                //Considera os registros deletados
                SET DELETED OFF
                While !(cTabela)->( Eof() )
                    
                    If (aScan(aRecsOK,(cTabela)->RECNO_PRINCIPAL)) == 0 

                        DbSelectArea(aProcesso[3][nTabSec][1])
                        (aProcesso[2])->(DBGoTo((cTabela)->RECNO_PRINCIPAL))
                        
                        If !Empty((aProcesso[2])->&(cCmpExpP))
                            RecLock(aProcesso[2], .F.)
                                REPLACE (aProcesso[2])->&(cCmpExpP) WITH ""
                            (aProcesso[2])->(MsUnLock())
                        EndIf 

                        // -- Armazeno o recno processado para evitar duplo processamento 
                        aAdd(aRecsOK,(cTabela)->RECNO_PRINCIPAL)

                    EndIf 
                    (cTabela)->( DbSkip() )
                EndDo
                (cTabela)->( DbCloseArea() )

                //Desconsidera os registros deletados
                SET DELETED ON

            EndIf 
        Else
            LjGrvLog(" RmiPub4Sec "," A Tabela: [" + aProcesso[3][nTabSec][1] + "] Não é considerada para a publicação do processo: [" +  aProcesso[1] + "]")
        EndIf 

    Next nTabSec

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CampoJson
Publica o um campo memo com conteudo em json.

@param   cJson, Caractere, Json em string que será publicado
@return  Caractere, Conteudo Json em string no formuto da publicação  
@author  Rafael Tenorio da Costa
@since   13/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CampoJson(cJson)

    Local cRetorno  := ""
    Local cTag      := ""
    Local xConteudo := Nil
    Local oJson     := JsonObject():New()
    Local nCont     := 0

    //Carrega configurações do tipo do cadastro        
    oJson:FromJson(cJson)  

    For nCont:=1 To Len(oJson["Components"])

        cTag      := oJson["Components"][nCont]["IdComponent"]
        xConteudo := oJson["Components"][nCont]["ComponentContent"]
        cTipo     := AllTrim( Upper( oJson["Components"][nCont]["ContentType"] ) )
        cTipo     := IIF( cTipo == "NUMBER", "N", IIF(cTipo == "LOGICAL", "L", "C") )

        //Trata o conteudo de cada tag
        cRetorno += Conteudo(cTipo, xConteudo, cTag)
    Next nCont

    FwFreeObj(oJson)

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} Conteudo
Trata o conteudo de cada tag que será publicado.

@param   cTipo, Caractere, Tipo que o conteudo deve ter para ser publicado
@param   xConteudo, Indefinido, Conteudo da tag que será publicado 
@param   cTag, Caractere, Indentificador da Tag
@return  Caractere, Tag com o Conteudo que será publicado formatada   
@author  Rafael Tenorio da Costa
@since   13/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Conteudo(cTipo, xConteudo, cTag)

    Local cRetorno := ""

    Default cTag   := ""

    Do Case

        Case cTipo == "C"

            //Retira as "" ou '', pois ocorre erro ao realizar o Parse do Json
            xConteudo := StrTran(xConteudo,'"','')
            xConteudo := StrTran(xConteudo,"'","")
            
            xConteudo := '"' + AllTrim(xConteudo) + '"'
    
            cRetorno  := '"' + AllTrim(cTag) + '":' + xConteudo + ","

        Case cTipo == "M"

            xConteudo := AllTrim(xConteudo)
            If SubStr(xConteudo, 1, 1) == "{" .And. SubStr(xConteudo, Len(xConteudo), 1) == "}"
                cRetorno  := CampoJson(xConteudo)
            Else

                //Retira as "" ou '', pois ocorre erro ao realizar o Parse do Json
                xConteudo := StrTran(xConteudo,'"','')
                xConteudo := StrTran(xConteudo,"'","")
                
                xConteudo := '"' + AllTrim(xConteudo) + '"'
        
                cRetorno  := '"' + AllTrim(cTag) + '":' + xConteudo + ","
            EndIf       

        Case cTipo == "N"
            xConteudo := cValToChar(xConteudo)
            cRetorno  := '"' + AllTrim(cTag) + '":' + xConteudo + ","

        Case cTipo == "D"
            xConteudo := '"' + DtoS(xConteudo) + '"'
            cRetorno  := '"' + AllTrim(cTag) + '":' + xConteudo + ","

        Case cTipo == "L"
            xConteudo := IIF(xConteudo, "true", "false")
            cRetorno  := '"' + AllTrim(cTag) + '":' + xConteudo + ","

        OTherWise
            xConteudo := '"' + STR0004 + '"'    //"Tipo do campo inválido"
            cRetorno  := '"' + AllTrim(cTag) + '":' + xConteudo + ","

    End Case

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} Relacionameno
Inclui no json de publicação as tags que não fazem parte da tabela MIL

@param   cTabela, Caractere, Tabela do nó publicado
@param   aStructExp, Array, Estrutura da tabela do nó publicado
@param   cJson, Caractere, Json para publicação
@return  cJson, Json com o Conteudo alterado para publicação
@author  Danio Rodrigues
@since   29/11/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Relacionamento(cTabela,aStructExp,cJson)

    Local oJson         := JsonObject():new()
    Local nPosTip       := 0
    Local nPosSai       := 0
    Local nItem         := 0
    Local cContSai      := ""
    Local cContTip      := ""
    Local cTipo         := ""
    Local cCampo        := ""
    Local xConteudo     := ""

    Default aStructExp  := {}
    Default cTabela     := ""
    Default cJson       := ""

    nPosTip := aScan(aStructExp, {|x| x[1] == "MIL_TIPREL"} ) 
    nPosSai := aScan(aStructExp, {|x| x[1] == "MIL_SAIDA"} )

    cContTip := (cTabela)->&( aStructExp[nPosTip][1] )
    cContSai := (cTabela)->&( aStructExp[nPosSai][1] )

    DbSelectArea("MIH")
    MIH->(DbSetOrder(01))
    If MIH->(Dbseek(xFilial("MIH") + PadR(cContTip,TamSX3("MIH_TIPCAD")[1]) + cContSai ))
        oJson:fromJson(MIH->MIH_CONFIG)
        For nItem := 1 to Len(oJson["Components"])           

            cTipo     := Valtype(oJson["Components"][nItem]["ComponentContent"])
            cCampo    := oJson["Components"][nItem]["IdComponent"]
            xConteudo := oJson["Components"][nItem]["ComponentContent"]
        
            //Trata o conteudo de cada tag
            cJson += Conteudo(cTipo, xConteudo, cCampo)

        Next nItem
    Else
        LjGrvLog(" Relacionamento ", "Tipo de cadastro (" + cContTip + "), e tipo de Saida (" + cContSai + ")  não encontrado, favor verificar se o processo de cadastro auxiliar foi realizado!")
    EndIF    

Return cJson

//-----------------------------------------------------------------------
/*/{Protheus.doc} SHPPrePub
Função responsavel encontrar os processos habilidados e iniciar a publicação dos registros

@author  Lucas Novais (lnovais@)
@since 	 28/04/2022
@version P12.1.2210

@param 	 cEmpPub, Caractere, Empresa de publicação
@param 	 cFilPub, Caractere, Filial de publicação

/*/
//-----------------------------------------------------------------------
Function SHPPrePub()

    Local nX         := 0   // -- Variavel de controle
    Local nI         := 0   // -- Variavel de controle
    Local aFilsPub   := {}  // -- Array com as filiais que irão ser publicadas

    //Retorna os processos que serão publicados
    aTable := RmiProPub()

    For nX := 1 To Len(aTable)

        aFilsPub := STRTOKARR(aTable[nX][9], ';' )

        For nI := 1 To len(aFilsPub)

            // -- Utilizado para testar mono-thread
            //SHPPubSel(cEmpAnt,aFilsPub[nI],aTable[nX])

            StartJob("SHPPubSel", GetEnvServer(), .F./*lEspera*/, cEmpAnt, aFilsPub[nI], aTable[nX] )

            Sleep(5000)
        Next 

    Next nX

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} SHPPubSel
Função responsavel por buscar os processo que devem gerar publicação considerando as filiais cadastradas

@author  Lucas Novais (lnovais@)
@since 	 28/04/2022
@version P12.1.2210

@param 	 cEmpPub, Caractere, Empresa de publicação
@param 	 cFilPub, Caractere, Filial de publicação
@param 	 aProcesso, Array, Array com os dados do processo que será publicadi

/*/
//-------------------------------------------------------------------------

Function SHPPubSel(cEmpPub, cFilPub, aProcesso)
    
    Local cSemaforo    := cEmpPub + cFilPub + aProcesso[1]                                                      // -- Controle de execução
    Local cQuery       := ""                                                                                    // -- Variavel utilizada para armazenar Query
    Local cWhere       := ""                                                                                    // -- Variavel utilizada para armazenar where da Query
    Local cTabela      := ""                                                                                    // -- Armazena alias da query que será executada
    Local cTabelaMIN   := ""                                                                                    // -- Armazena alias da query que será executada
    Local cDB          := ""                                                                                    // -- Banco de dados atual
    Local cPrefixo     := IIF( SubStr( aProcesso[2], 1, 1) == "S", SubStr( aProcesso[2], 2), aProcesso[2] )     // -- Prefixo da tabela 
    Local nMaxbloco    := 1000                                                                                  // -- Numero maximo de registros na query  
    Local cMsgError    := ""                                                                                    // -- Mensagem de erro          
    Local oUltRecno    := JsonObject():New()                                                                    // -- Json com ultimos recnos
    Local aAreaMin     := {}                                                                                    // -- Area da tabela MIN
    Local nUltimoRecno := 0
    Local nRecno       := 0
    Local cFilter      := ""
    Local cCmpExp   := cPrefixo + "_MSEXP"  //Ajuste loop

    If aProcesso[5] <> "TERCEIROS"
        RpcSetType(3) // Para não consumir licenças na Threads
    EndIF

    RpcSetEnv(cEmpPub, cFilPub, , ,"LOJ", "SHPPubSel")

    If !LockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
        LjxjMsgErr( I18n(STR0002, {cSemaforo}) )    //"Serviço #1 já esta sendo utilizado por outra instância."
        Return Nil
    EndIf

    LjGrvLog(" SHPPubSel ", "Job SHPPubSel iniciado  ")  
    LjGrvLog(" SHPPubSel ", "Processo:   ",aProcesso) 
    
    // -- Verifico se o campo de controle existe.
    If Ascan(TCStruct(RetSqlName(aProcesso[2])), {|x| x[1] == 'S_T_A_M_P_'}) > 0

        // -- Query que retorna data da ultima publicação para o processo
        cTabelaMIN := GetNextAlias()
        cQuery := " SELECT R_E_C_N_O_ RECNO FROM " + RetSqlName("MIN")
        cQuery += " WHERE MIN_CPROCE = '" + aProcesso[1] + "' "
        cQuery += " AND MIN_FILPUB = '" + IIF(Empty(xFilial(aProcesso[2])),xFilial(aProcesso[2]),cFilPub) + "' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery := ChangeQuery(cQuery)

        LjGrvLog(" SHPPubSel ","Query que lista a ultima publicação do proceso/filial atual atual: "+ cQuery)
        DbUseArea(.T., "TOPCONN", TcGenQry ( , , cQuery), cTabelaMIN, .T., .F.)

        // -- Se for  EOF indica que não existe ainda o controle do processo atual para a filial de publicação atual
        // -- e caso não exista preenche o Array aMINAux para que o processo/filial seja criado na tabela de controle  MIN
        If !(cTabelaMIN)->( Eof() )
            aAreaMin     := MIN->(GetArea())
            
            DbSelectArea("MIN")
            MIN->(DBGoTo((cTabelaMIN)->RECNO))

            oUltRecno:FromJSON(MIN->MIN_ULTREC)
            
            aMINAux[1] := MIN->MIN_FILPUB
            aMINAux[2] := MIN->MIN_CPROCE
            aMINAux[3] := AllTrim(MIN->MIN_ULTPUB)
            aMINAux[4] := oUltRecno 
            aMINAux[5] := IIF(GetUltRec(aProcesso[2]) == 0,.T.,.F.)
            aMINAux[6] := .T.

            RestArea(aAreaMin)
        Else
            aMINAux[1] := IIF(Empty(xFilial(aProcesso[2])),xFilial(aProcesso[2]),cFilPub)
            aMINAux[2] := aProcesso[1]
            aMINAux[3] := ""
            aMINAux[4] := oUltRecno  
            aMINAux[5] := .T.
            aMINAux[6] := .T.
        EndIf 

        (cTabelaMIN)->(DbCloseArea())
           
        cUltPublic := aMINAux[3]                // -- Ultima Publicação    
        nUltREC    := GetUltRec(aProcesso[2])   // -- Ultimo recno da tabela principal

        // -- Verifico tabelas secundária
        SHPPub4Sec(aProcesso,cUltPublic,nMaxbloco)

        // -- Query que retorna data da ultima Alteração ja na tabela que será publicada
        cTabela := GetNextAlias()
    
        cDB := TcGetDB()
     
        LjGrvLog(" RmiEnvObj ", "Conectado com banco de dados: " + cDB )
        If cDB == "MSSQL" 
            cQuery := " SELECT convert(varchar(23),MAX(S_T_A_M_P_), 21 ) UltimaAlteracao FROM " + RetSqlName(aProcesso[2])
        ElseIf cDB == "POSTGRES" 
            cQuery := " SELECT to_char(MAX(S_T_A_M_P_),'YYYY-MM-DD HH:MI:SS.MS') UltimaAlteracao FROM " + RetSqlName(aProcesso[2])
        ElseIf cDB == "ORACLE" 
            cQuery := " SELECT to_char(MAX(S_T_A_M_P_),'YYYY-MM-DD HH24:MI:SS.FF') UltimaAlteracao FROM " + RetSqlName(aProcesso[2])
        EndIf 
        
        cQuery += " WHERE " + cPrefixo + "_FILIAL =  '" + xFilial(aProcesso[2]) + "' " 
        //Tratamento de macro execução
        cFilter := aProcesso[4]
        If SubStr(cFilter, 1, 1) == "&"
           cFilter := &( AllTrim( SubStr(cFilter, 2) ) )
        EndIf

        cQuery += IIF(!Empty(cFilter), ' AND ' + AllTrim(cFilter), "")
        cQuery := ChangeQuery(cQuery)

        LjGrvLog(" SHPPubSel ","Query que lista a ultima ateração do proceso/filial atual: "+ cQuery)
        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabela, .T., .F.)

        If !(cTabela)->( Eof() ) .AND. !Empty((cTabela)->(UltimaAlteracao))

            cUltAltera := (cTabela)->(UltimaAlteracao)
            (cTabela)->(DbCloseArea())

            If cUltAltera > cUltPublic                 
                // -- Query que retorna a quantidade de registros a ser processados 
                cTabela := GetNextAlias()
                // -- Conto os registros para saber se o processamento terá mais de um bloco de 50 (Definido na variavel nMaxbloco)
                cQuery := " SELECT COUNT(R_E_C_N_O_) QTDREGISTRO FROM " + RetSqlName(aProcesso[2])
                cWhere := " WHERE " + cPrefixo + "_FILIAL =  '" + xFilial(aProcesso[2]) + "' "  
                cWhere += IIF(!Empty(cFilter), ' AND ' + AllTrim(cFilter), "")
                
                // -- Não deve pegar os campos S_T_A_M_P_ Nulos, somente os que foram alterados apos a criação dele.
                If cDB == "MSSQL" 
                    cWhere += " AND convert(varchar(23),S_T_A_M_P_, 21 ) > '"
                ElseIf cDB == "POSTGRES" 
                    cWhere += " AND to_char(S_T_A_M_P_,'YYYY-MM-DD HH:MI:SS.MS') > '"
                ElseIf cDB == "ORACLE" 
                    cWhere += " AND to_char(S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.FF') > '"
                EndIf 

                cWhere += cUltPublic + "' "

                 //Valida existencia do campo de controle de exportação
                If (aProcesso[2])->( ColumnPos(cCmpExp) ) > 0
                    cWhere += " AND "+cCmpExp+ " != 'PSH-INTE' " 
                Else
                    LjGrvLog(" SHPPubSel ","Campo não existe -> "+cCmpExp +" <- Caso seu cadastro de assinante esteja utilizando Busca e Envio..") 
                    LjGrvLog(" de um mesmo processo pode ocorrer um loop de envio e recebimento do mesmo registro")
                    LjGrvLog(" Exemplo: 'Busca Cliente' e 'Envia Cliente' para o mesmo Assiante")
                EndIf
                // -- Se é um processamento maior que 50 e o primeiro bloco já foi processado, inicia do ultimo recno + 1 
                If !aMINAux[5]
                    cWhere += " AND R_E_C_N_O_ > " + cValToChar(nUltREC)
                EndIf 

                cQuery += cWhere

                cQuery += " ORDER BY QTDREGISTRO "

                cQuery := ChangeQuery(cQuery) 

                LjGrvLog(" SHPPubSel ","Query que lista a quantidade de registros a gerar publicação: "+ cQuery)
                DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabela, .T., .F.)
                
                LjGrvLog(" SHPPubSel ","Quantidade de registros a processar: " + cValToChar((cTabela)->QTDREGISTRO))
                LjGrvLog(" SHPPubSel ","limite atual de processamento: " + cValToChar(nMaxbloco))
                LjGrvLog(" SHPPubSel ","Caso o limite seja excedido o processamento ocorrerá em blocos")
                
                // -- Verifico se é o ultimo bloco de 50 registros para a Filial e processo atual 
                If (cTabela)->QTDREGISTRO > nMaxbloco 
                    aMINAux[5] := .F. 
                Else 
                    aMINAux[5] := .T.
                EndIf 

                (cTabela)->(DbCloseArea())

                // -- Query que retorna a lista de registros para publicação
                cTabela := GetNextAlias()
                If cDB == "MSSQL" 
                    cQuery := " SELECT TOP(" + cValtochar(nMaxbloco) + ") R_E_C_N_O_ REGISTRO  FROM " + RetSqlName(aProcesso[2])
                Else
                    cQuery := " SELECT R_E_C_N_O_ REGISTRO FROM " + RetSqlName(aProcesso[2])
                EndIf 
                
                cQuery += cWhere
                
                If cDB == "ORACLE" 
                    cQuery  += " AND ROWNUM <= " + cValtochar(nMaxbloco)  
                EndIf 

                cQuery += " ORDER BY REGISTRO "

                If cDB == "POSTGRES"
                    cQuery  += " LIMIT " + cValtochar(nMaxbloco)
                EndIf 

                cQuery := ChangeQuery(cQuery)
                
                LjGrvLog(" RMIPUBSEL ","Query que lista os registros disponiveis para publicação: "+ cQuery)
                DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabela, .T., .F.)

                SET DELETED OFF

                While !(cTabela)->( Eof() )

                    DbSelectArea(aProcesso[2])
                    (aProcesso[2])->( DbGoTo( (cTabela)->REGISTRO ) )

                    If ValidaPub(aProcesso, cTabela)
                        // -- Grava publicação
                        RmiPubGrv(aProcesso, (cTabela)->REGISTRO,"",.F.)
                    EndIf

                    nUltimoRecno := (cTabela)->REGISTRO
                    (cTabela)->( DbSkip() )
                EndDo

                (cTabela)->( DbCloseArea() )

                // -- Desconsidera os registros deletados
                SET DELETED ON

                //-- Atualizo ultima publicação com a data da ultima atalização e ultimo recno processado
                aMINAux[3] := cUltAltera

                // -- Se o bloco for inferior ao maximo não é necessario guardar o ultimo recno
                Iif(aMINAux[5] .AND. aMINAux[6] ,nRecno := 0,nRecno := nUltimoRecno )
                SetUltRec(aProcesso[2],nRecno)

                SHPSetUltAlt(IIF(Empty(xFilial(aProcesso[2])),xFilial(aProcesso[2]),cFilPub), aProcesso[1])
            Else
                cMsgError := "O Processo:" + aProcesso[1] + " na tabela: " + aProcesso[2] + " Não tem alterações com data superior a: " + cUltPublic
                LjGrvLog(" SHPPubSel ",cMsgError)
            EndIf
        Else
            cMsgError := " A tabela: " + aProcesso[2] + " Não tem nenhum S_T_A_M_P alimentado."
            LjGrvLog(" SHPPubSel ",cMsgError)
        EndIf  

    Else 
        cMsgError := "Campo de controle S_T_A_M_P_ não esta presente na tabela: " + aProcesso[2]
        LjGrvLog(" SHPPubSel ",cMsgError)
        
    EndIf 

    If !Empty(cMsgError)
        LjGrvLog(" SHPPubSel ","Por esse motivo, não haverá publicação do Processo: " + aProcesso[1] + " Tabela: " + aProcesso[2])
    EndIf

    LjGrvLog(" SHPPubSel ", "Job SHPPubSel Finalizado")  
    UnLockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)

return

//-----------------------------------------------------------------------
/*/{Protheus.doc} SHPPub4Sec
Função responsavel por buscar se existem registros nas tabelas se secundária com S_T_A_M_P maior que o ultimo publicado, 
se existir deverá atualizar o S_T_A_M_P da tabela  principal 

@author  Lucas Novais (lnovais@)
@since 	 28/04/2022
@version P12.1.2210

@param 	 aProcesso, Array, Array com os dados do processo que será publicado
@param 	 cUltPublic, Caractere, Data  S_T_A_M_P da ultima publicação

/*/
//-----------------------------------------------------------------------

Static Function SHPPub4Sec(aProcesso,cUltPublic,nMaxbloco)
    Local nTabSec    := 0           // -- Variavel de controle (FOR)
    Local cPrefixoS  := ""          // -- Prefixo da tabela secundária
    Local cPrefixoP  := ""          // -- Prefixo da tabela primaria
    Local cTabela    := ""          // -- Alias temporario
    Local cCmpsGrp   := ""          // -- Group By utilizado na query
    Local cSelect    := ""          // -- Query completa
    Local cAuxSelect := ""
    Local aRecsOK    := {}          // -- Variavel que armazenas os recnos já processados
    Local cDB        := TcGetDB()   // -- Banco de dados atual
    Local nUltRecnoS := 0           // -- Ultimo recno da tabela secundária
    Local lUltBloco  := .T.
    Local cFilter    := ""

    For nTabSec := 1 To Len(aProcesso[3])

        If aProcesso[3][nTabSec][5] $ "1|3" // -- Indica que é para considerar as secundárias para a publicação
            
            cPrefixoP := IIF( SubStr( aProcesso[2], 1, 1) == "S", SubStr( aProcesso[2], 2), aProcesso[2] )
            cPrefixoS := IIF( SubStr( aProcesso[3][nTabSec][1], 1, 1) == "S", SubStr( aProcesso[3][nTabSec][1], 2), aProcesso[3][nTabSec][1] )

            If Ascan(TCStruct(RetSqlName(aProcesso[3][nTabSec][1])), {|x| x[1] == 'S_T_A_M_P_'}) > 0

                // -- Query que retorna a quantidade de registros a ser processados 
                cTabela := GetNextAlias()

                // -- Conto os registros para saber se o processamento terá mais de um bloco de 50 (Definido na variavel nMaxbloco)
                cSelect := " SELECT COUNT(A.R_E_C_N_O_) REGISTROS "
                
                cAuxSelect := " FROM " + RetSqlName(aProcesso[3][nTabSec][1]) + "  A "  
                
                cAuxSelect  += " INNER JOIN " +  RetSqlName(aProcesso[2]) + "  B " 
                
                // -- Controle, caso ja tenha processado um bloco começa aparir dele.
    
                cAuxSelect += " ON " 
                cAuxSelect += RetJoin(,aProcesso[3][nTabSec][2],aProcesso[3][nTabSec][3],aProcesso[3][nTabSec][1],aProcesso[2])
                
                If cDB == "MSSQL" 
                    cAuxSelect += " WHERE convert(varchar(23),A.S_T_A_M_P_, 21 ) > '"
                ElseIf cDB == "POSTGRES" 
                    cAuxSelect += " WHERE to_char(A.S_T_A_M_P_,'YYYY-MM-DD HH:MI:SS.MS') > '"
                ElseIf cDB == "ORACLE" 
                    cAuxSelect += " WHERE to_char(A.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.FF') > '"
                EndIf 

                // -- Não deve pegar os campos S_T_A_M_P_ Nulos, somente os que foram alterados apos a criação dele.
                cAuxSelect += cUltPublic + "' "

                cAuxSelect += " AND A." + cPrefixoS + "_FILIAL = '" + xFilial(aProcesso[3][nTabSec][1]) + "' "

                //Tratamento de macro execução
                cFilter := aProcesso[3][nTabSec][4]
                If SubStr(cFilter, 1, 1) == "&"
                    cFilter := &( AllTrim( SubStr(cFilter, 2) ) )
                EndIf
                // -- Filtro da tabela se
                IF !Empty(cFilter)
                    cAuxSelect += " AND " + cFilter
                Endif
                
                // -- Se o S_T_A_M_P_ da A for menor que o da B indica que a tabela PAI ja estará na fila, não sendo necessario a atualização.
                cAuxSelect += " AND ( A.S_T_A_M_P_ > B.S_T_A_M_P_ OR B.S_T_A_M_P_ IS NULL ) "
                cAuxSelect += " AND B.D_E_L_E_T_ = ' ' "

                cSelect += cAuxSelect

                cSelect := ChangeQuery(cSelect) 

                LjGrvLog(" SHPPub4Sec ","Query que lista a quantidade de registros a processar da tabela secundária: "+ cSelect)
                DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)
                
                LjGrvLog(" SHPPub4Sec ","Quantidade de registros a processar: " + cValToChar((cTabela)->REGISTROS))
                LjGrvLog(" SHPPub4Sec ","limite atual de processamento: " + cValToChar(nMaxbloco))
                LjGrvLog(" SHPPub4Sec ","Caso o limite seja excedido o processamento ocorrerá em blocos")
                
                // -- Verifico se é o ultimo bloco de 50 registros para a Filial e processo secundária atual 
                lUltBloco := (cTabela)->REGISTROS <= nMaxbloco
                If !lUltBloco .Or. !aMINAux[6] // -- Se em alguma tabela secundária tem mais que o nMaxbloco então indica que não é o ultimo bloco
                    aMINAux[6] := .F. 
                Else 
                    aMINAux[6] := .T.
                EndIf 
                
                (cTabela)->(DbCloseArea())  
                  
                cTabela  := GetNextAlias()
                cCmpsGrp := "A." + StrTran(aProcesso[3][nTabSec][2],"+",", A.")
                
                
                If cDB == "MSSQL" 
                    cSelect := " SELECT TOP(" + cValtochar(nMaxbloco) + ") B.R_E_C_N_O_ RECNO_PRINCIPAL, A.R_E_C_N_O_ RECNO_SECUNDARIA "
                Else
                    cSelect := " SELECT B.R_E_C_N_O_  RECNO_PRINCIPAL, A.R_E_C_N_O_  RECNO_SECUNDARIA "
                EndIf 
                
                cSelect += cAuxSelect
                
                If cDB == "ORACLE" 
                    cSelect  += " AND ROWNUM <= " + cValtochar(nMaxbloco)  
                EndIf 
                
                cSelect += " GROUP BY " +  cCmpsGrp +  ",B.R_E_C_N_O_,A.R_E_C_N_O_  "
                cSelect += " ORDER BY RECNO_PRINCIPAL  "
                
                If cDB == "POSTGRES"
                    cSelect  += " LIMIT " + cValtochar(nMaxbloco)
                EndIf 
                
                LjGrvLog(" SHPPub4Sec ","QUERY que seleciona os registros das tabelas secundárias que serão publicados " + cSelect)
                DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)
                
                // -- Considera os registros deletados
                SET DELETED OFF
                While !(cTabela)->( Eof() )
                    
                    If (aScan(aRecsOK,(cTabela)->RECNO_PRINCIPAL)) == 0 

                        DbSelectArea(aProcesso[2])
                        (aProcesso[2])->(DBGoTo((cTabela)->RECNO_PRINCIPAL))
                        
                        // -- Deleto e retorno o registro principal para que o campo S_T_A_M_P_ seja atualizado, 
                        // -- assim gerando a publicação de toda a cadeia (principais e secundárias)
                        // -- Protegido por transação, ou seja somente conclui caso consiga "deletar" e "desdeletar" o registro.
                        Begin Transaction
                            RecLock(aProcesso[2], .F.)
                                (aProcesso[2])->(DBDelete())
                            (aProcesso[2])->(MsUnLock())    
                            
                            RecLock(aProcesso[2], .F.)   
                                (aProcesso[2])->(DBRecall())
                            (aProcesso[2])->(MsUnLock())
                        End Transaction        
                        
                        // -- Armazeno o recno processado para evitar duplo processamento 
                        aAdd(aRecsOK,(cTabela)->RECNO_PRINCIPAL)

                    EndIf 
                    nUltRecnoS := (cTabela)->RECNO_SECUNDARIA
                    (cTabela)->( DbSkip() )
                EndDo

                (cTabela)->( DbCloseArea() )

                // -- Desconsidera os registros deletados
                SET DELETED ON

            Else
                LjGrvLog(" SHPPub4Sec ","Campo de controle S_T_A_M_P_ não esta presente na tabela: " + aProcesso[3][nTabSec][1] )
                LjGrvLog(" SHPPub4Sec ","Não será gerada publicação para o processo: " + aProcesso[1] + " considerando a tabela secundária: " + aProcesso[3][nTabSec][1])
            EndIf 

        Else
            LjGrvLog(" SHPPub4Sec "," A Tabela: [" + aProcesso[3][nTabSec][1] + "] Não é considerada para a publicação do processo: [" +  aProcesso[1] + "]")
        EndIf 
    Next nTabSec

return

//-----------------------------------------------------------------------
/*/{Protheus.doc} SHPSetUltAlt
Função responsavel por a alteração da tabela MIN (tabelas responsavel por controlar a ultima publicação para o proceso|filial )

@author  Lucas Novais (lnovais@)
@since 	 28/04/2022
@version P12.1.2210

@param 	 cFilPub, Caractere, Filial de publicação
@param 	 cProcesso, Caractere, processo publicado

/*/
//-----------------------------------------------------------------------

Function SHPSetUltAlt(cFilPub, cProcesso)
    Local  lInclui := Nil // -- Indica se é uma inclusão ou alteração na tabela MIN

    DbSelectArea("MIN")
    MIN->(DbSetOrder(1)) // -- MIN_FILIAL+MIN_CPROCE+MIN_FILPUB
    lInclui := !MIN->(Dbseek(xFilial("MIN") + PadR(cProcesso,TamSX3("MIN_CPROCE")[1]) + cFilPub ))

    RecLock("MIN", lInclui)

        If lInclui
            REPLACE MIN->MIN_FILPUB WITH cFilPub
            REPLACE MIN->MIN_CPROCE WITH cProcesso
        EndIf         
        
        If aMINAux[5] .AND. aMINAux[6] // -- Se for o ultimo bloco atualizo a data da ultima publicação
            REPLACE MIN->MIN_ULTPUB WITH aMINAux[3]   
        EndIf 

        REPLACE MIN->MIN_ULTREC WITH aMINAux[4]:toJSON()

    MIN->(MsUnLock())

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} SetUltRec
Função responsavel por setar (atualizar) um numero de recno a key (tabela do processo) atual

@author  Lucas Novais (lnovais@)
@since 	 28/04/2022
@version P12.1.2210

@param 	 cKey, Caractere, Chave (Tabela do processo)
@param 	 nRecno, numerico, recno

/*/
//-----------------------------------------------------------------------

Static Function SetUltRec(cKey,nRecno)
    cKey := Alltrim(cKey)
    aMINAux[4][cKey] := nRecno
Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} SHPSetUltAlt
Função responsavel por devolver um numero de recno da key (tabela do processo) atual
@author  Lucas Novais (lnovais@)
@since 	 28/04/2022
@version P12.1.2210

@param 	 cKey, Caractere, Chave (Tabela do processo)

/*/
//-----------------------------------------------------------------------

Static Function GetUltRec(cKey)
    Local nRecno := 0

    cKey := Alltrim(cKey)

    If aMINAux[4]:hasProperty(cKey)
        nRecno := aMINAux[4][cKey]
    Else
        aMINAux[4][cKey] := 0
    EndIf 

Return nRecno

//-----------------------------------------------------------------------
/*/{Protheus.doc} RmiProPub
Retorna os processos que serão publicados, com toda a estrutura necessária para a publicação.

@type    Function
@author  Rafael Tenorio da Costa
@since   20/07/22
@version 12.1.33
/*/
//-----------------------------------------------------------------------
Function RmiProPub()
	
    Local cSelect       := "" 
    Local cTabela       := ""
    Local aProcesso     := {}
    Local aTabSec       := {}     
    Local nPos          := 0 
    Local lFields       := MHN->( ColumnPos("MHN_FILTRO") ) > 0 .AND. MHS->( ColumnPos("MHS_FILTRO") ) > 0
    Local lFieldPub     := MHS->( ColumnPos("MHS_CONPUB") ) > 0
    Local lFldSecOb     := MHN->( ColumnPos("MHN_SECOBG") ) > 0
    Local lFieldTipo    := MHS->( ColumnPos("MHS_TIPO")   ) > 0
    Local cTamTab       := Space( TamSx3("MHN_TABELA")[1] )

    //Seleciona os processos assinados
    cTabela := GetNextAlias()
    cSelect := " SELECT MHN_COD, MHN_TABELA, MHN_CHAVE, MHS_TABELA, MHS_CHAVE, MHP_CASSIN, MHP_FILPRO"
    cSelect += IIF(lFldSecOb    , ", MHN_SECOBG"            , "")
    cSelect += IIF(lFields      , ", MHN_FILTRO, MHS_FILTRO", "") 
    cSelect += IIF(lFieldPub    , ", MHS_CONPUB"            , "") 
    cSelect += IIF(lFieldTipo   , ", MHS_TIPO"              , "")

    cSelect += " FROM " + RetSqlName("MHN") + " MHN INNER JOIN " + RetSqlName("MHP") + " MHP"
    cSelect +=      " ON MHN_FILIAL = MHP_FILIAL AND MHN_COD = MHP_CPROCE AND MHN.D_E_L_E_T_ = MHP.D_E_L_E_T_ AND MHN_TABELA NOT IN ('XXX','YYY','" + cTamTab + "')"
    cSelect += " LEFT JOIN " + RetSqlName("MHS") + " MHS"
    cSelect +=      " ON MHS_FILIAL = MHN_FILIAL AND MHS_CPROCE = MHN_COD AND MHS.D_E_L_E_T_ = ' '"

    cSelect += " WHERE MHN.D_E_L_E_T_ = ' '"
    cSelect += " AND MHP_ATIVO = '1'"           //1=Sim
    cSelect += " AND MHP_TIPO = '1'"            //1=Envia
    cSelect += " AND MHP_CASSIN <> 'PROTHEUS'"  //Não gerar MHQ para Assinante Protheus em caso do tipo ser 1=Envia.

    cSelect += " GROUP BY MHN_COD, MHN_TABELA, MHN_CHAVE, MHS_TABELA, MHS_CHAVE, MHP_CASSIN, MHP_FILPRO"
    cSelect += IIF(lFldSecOb    , ", MHN_SECOBG"            , "")
    cSelect += IIF(lFields      , ", MHN_FILTRO, MHS_FILTRO", "")
    cSelect += IIF(lFieldPub    , ", MHS_CONPUB"            , "")
    cSelect += IIF(lFieldTipo   , ", MHS_TIPO"              , "")

    cSelect := ChangeQuery(cSelect)

    LjGrvLog("RmiProPub", "Query executada para retornar os processos que serão publicados:", cSelect)
    DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)

    While !(cTabela)->( Eof() )
        
        //Verifico no array aProcesso se determinada tabela do cabeçalho ja existe no array
        nPos := aScan(aProcesso,{|x| AllTrim(x[1]) == AllTrim( (cTabela)->MHN_COD ) })

        aTabSec := {    AllTrim( (cTabela)->MHS_TABELA  )               ,;
                        AllTrim( (cTabela)->MHS_CHAVE   )               ,;
                        (cTabela)->MHN_CHAVE                            ,;
                        IIF(lFields     , (cTabela)->MHS_FILTRO , "" )  ,;
                        IIF(lFieldPub   , (cTabela)->MHS_CONPUB , "2")  ,;
                        IIF(lFieldTipo  , (cTabela)->MHS_TIPO   , "" )  }

        //Caso a tabela ainda nao existe no array, entao é add no array a tabela principal mais as filhas
        If nPos == 0
            Aadd(aProcesso ,;   
                        {   AllTrim( (cTabela)->MHN_COD     )               ,;
                            AllTrim( (cTabela)->MHN_TABELA  )               ,;
                            {}                                              ,;
                            IIF(lFields     , (cTabela)->MHN_FILTRO, "" )   ,;
                            (cTabela)->MHP_CASSIN                           ,;
                            IIF(lFldSecOb   , (cTabela)->MHN_SECOBG, "2")   ,;
                            IIF(lFieldTipo  , (cTabela)->MHS_TIPO  ,  "")   ,;
                            (cTabela)->MHN_CHAVE                            ,;
                            AllTrim( (cTabela)->MHP_FILPRO )                 }   )

            nPos := Len(aProcesso)
        EndIf

        If !Empty( (cTabela)->MHS_TABELA )
            Aadd(aProcesso[nPos][3], aTabSec)
        EndIf

        (cTabela)->( DbSkip() )
    EndDo
       
    (cTabela)->( DbCloseArea() )

    LjGrvLog("RmiProPub", "Processos que serão publicados:", aProcesso)

Return aProcesso
//-------------------------------------------------------------------
/*/{Protheus.doc} RmiPubMix
Grava a publicação na tabela MHQ - Mensagens Publicadas do Mix de Produto

@author  Everson S P Junior
@since   14/03/23
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiPubMix(aProcesso, nRegistro)

    Local aArea      := GetArea()
    Local cJson      := ""
    Local lSecObg    := .T.
    Local cProcesso  := aProcesso[1]
    Local cTabela    := aProcesso[2]
    Local cFilPro    := aProcesso[9]
    Local cChave     := aProcesso[8]  //Retorna campos que compoem a chave da publicação

    Default cCmpExp := ""
    Default lAltExp := .T.

    LjGrvLog(" RmiPubGrv ","Grava a publicação na tabela MHQ Function RmiPubGrv",{cProcesso, cTabela, nRegistro})
    
    (cTabela)->( DbGoTo(nRegistro) )

    If !(cTabela)->( Eof() )

        //Gera publicação da tabela principal
        LjGrvLog("RmiPubGrv", "Gerando publicação da tabela principal", cTabela)
        cJson := GeraJson(cTabela, 0)
        cJson := StrTran(cJson,'"B1_FILIAL": "'+Space(Tamsx3('B1_FILIAL')[1])+'"','"B1_FILIAL": "'+cFilPro+'"')//Verifica se vem com espaço 
        cJson := StrTran(cJson,'"B1_FILIAL":"'+Space(Tamsx3('B1_FILIAL')[1])+'"','"B1_FILIAL": "'+cFilPro+'"')//Verifica se vem com espaço 
        cJson := StrTran(cJson,'"B1_FILIAL": ""','"B1_FILIAL":"'+cFilPro+'"')//Verifica se vem sem espaço
        cJson := StrTran(cJson,'"B1_FILIAL":""','"B1_FILIAL":"'+cFilPro+'"')//Verifica se vem sem espaço
        If oError == Nil 

            cJson := SubStr(cJson,1,Len(cJson) - 1) + CRLF + '}' 
            LjGrvLog(" RmiPubGrv ","Resultado Json que será gravado -> "+cJson)
            Begin Transaction
                If lSecObg

                    GravaMHQ(   cProcesso   ,;
                                cTabela     ,; 
                                cFilPro+'|'+(cTabela)->&(cChave) + IIF( (cTabela)->( Deleted() ), "|" + cValToChar( (cTabela)->( Recno() ) ), "")   ,; 
                                cJson       ,; 
                                "1"         )

                EndIf

            End Transaction
        EndIf
    EndIf

    LjGrvLog(" RmiPubGrv ","Fim da Gravação Mix de Produto")
    RestArea(aArea)

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} GravaMHQ
Centraliza a gravação da tabela MHQ

@type    Function
@param 	 cProcesso  , Caractere, Processo da publicação
@param 	 cTabela    , Caractere, Tabela da publicação
@param 	 cChave     , Caractere, Chave unica da publicação
@param 	 cJson      , Caractere, Json da publicação
@param 	 cStatus    , Caractere, Status da publicação
@param 	 cFilReg    , Caractere, Filial do registro publicado
@author  Rafael Tenorio da Costa
@since   19/05/23
@version 12.1.2210
/*/
//-----------------------------------------------------------------------
Static Function GravaMHQ(cProcesso, cTabela, cChave, cJson, cStatus,;
                         cFilReg )

    Local cHora     := IIF( TamSx3("MHQ_HORGER")[1] >= 12, TimeFull(), Time() )

    Default cFilReg := xFilial(cTabela)

    RecLock("MHQ", .T.)
        MHQ->MHQ_FILIAL := xFilial("MHQ")
        MHQ->MHQ_ORIGEM := "PROTHEUS"
        MHQ->MHQ_CPROCE := cProcesso
        MHQ->MHQ_EVENTO := IIF( (cTabela)->( Deleted() ), "2", "1" )
        MHQ->MHQ_CHVUNI := cChave
        MHQ->MHQ_MENSAG := cJson
        MHQ->MHQ_DATGER := Date()
        MHQ->MHQ_HORGER := cHora
        MHQ->MHQ_STATUS := cStatus      //1=A Processar;9=Aguardando confirmação do produto
        MHQ->MHQ_UUID   := FwUUID("PUBLICA" + AllTrim(cProcesso))
        MHQ->MHQ_IDEXT  := cFilReg
    MHQ->( MsUnLock() )

Return Nil