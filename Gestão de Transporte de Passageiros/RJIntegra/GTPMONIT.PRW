#Include 'Protheus.ch'
#include "fwmvcdef.ch"
#INCLUDE "FWTABLEATTACH.CH"
#include 'parmtype.ch' 

Static oBrwMonit
Static aTestDummy := {.f.,nil}

/*/{Protheus.doc} nomeFunction
    (long_description)
    @type  Function
    @author user
    @since 15/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function GTPMONBrow(oWorkArea,cFunctionLog)
    
    Local lActive       := .T.

    If ( Valtype(oBrwMonit) != "O" )

        oBrwMonit	:= FWMBrowse():New()    

        oBrwMonit:SetAlias("GYS")
        oBrwMonit:SetDoubleClick({|| GTPMVIEW() })
        oBrwMonit:setOwner( oWorkarea:GetPanel( "WDGT01" ) )
        oBrwMonit:AddButton("Reintegrar", {|| Integra(.T.) } )
        oBrwMonit:AddButton("Integrar", {|| IIf(GTPMChk(),Integra(),FwAlertHelp("Op��o n�o dispon�vel para este m�todo."))} )
        oBrwMonit:AddButton("Visualizar", {|| GTPMVIEW()} )
        oBrwMonit:SetDescription("Logs de erros")

        lActive := .F.

    EndIf
    
    oBrwMonit:Refresh()
    oBrwMonit:CleanFilter()       
    oBrwMonit:SetFilterDefault( 'GYS_ROTINA == "' + cFunctionLog + '"')
    oBrwMonit:ExecuteFilter(.T.)

    If ( !lActive )
        oBrwMonit:Activate()
    EndIf

Return()

/*/{Protheus.doc} GTPAMON
    (long_description)
    @type  Function
    @author user
    @since 15/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function GTPMONIT()
    
    Local cMsgErro  := ""
    
    If ( FindClass("GTPRJLOG") .And. GTPxVldDic("GYS",,.T.,.T.,@cMsgErro) )

        FWMsgRun( /*oComponent*/,{ || CreateWorkArea() }, "Aguarde", "Carregando �rea de trabalho" )	

        If ( ValType(oBrwMonit) == "O" )
            FreeObj(oBrwMonit)
        EndIf

    Else
        FwAlertHelp(cMsgErro)     
    EndIf

Return 
//------------------------------------------------------------------------------
/* /{Protheus.doc} CreateWorkArea
Fun��o responsavel pela cria��o workarea do monitor operacional
@type Function
@author gustavo.silva2
@since 11/07/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function CreateWorkArea()

Local cMenuItem     := Nil
Local oMenu         := Nil
Local oMenuItem     := Nil
Local aSize         := FWGetDialogSize( oMainWnd )
Local oDlgWA        := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], "Monitor de Integra��es", , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )
Local oWorkArea		:= FWUIWorkArea():New( oDlgWA )

oWorkarea:SetMenuWidth( 200 )

oMenu := FWMenu():New()
oMenu:Init()

//------------------------------------------------------------------------------------------------------
//  Metodos
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder("Status do Job " + CheckActiveJob() , "A") 
cMenuItem := oMenu:AddFolder("Metodos ", "A") 

oMenuItem := oMenu:GetItem( cMenuItem )

oMenuItem:AddContent( "+ Bilhetes "	                , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ115") } )
oMenuItem:AddContent( "+ Receitas e Despesas"	    , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ427") } )
oMenuItem:AddContent( "+ Horarios/Servi�os"	        , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ004") } )
oMenuItem:AddContent( "+ Trechos da Linha"	        , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ003") } )
oMenuItem:AddContent( "+ Org�o"	                    , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ000") } )
oMenuItem:AddContent( "+ Tipos de localidade"	    , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ035") } )
oMenuItem:AddContent( "+ Estado"	                , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ001A") } )
oMenuItem:AddContent( "+ Cidade"	                , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ001B") } )
oMenuItem:AddContent( "+ Localidade"	            , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ001") } )
oMenuItem:AddContent( "+ Categoria Linha"	        , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ011") } )
oMenuItem:AddContent( "+ Linhas" 	                , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ002") } )
oMenuItem:AddContent( "+ Vias"	                    , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ005") } )
oMenuItem:AddContent( "+ Colaboradores"             , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ008") } )
oMenuItem:AddContent( "+ Tipo de Ag�ncia"	        , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ711") } )
oMenuItem:AddContent( "+ Ag�ncia"	                , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ006") } )
oMenuItem:AddContent( "+ Categoria Bilhetes"	    , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ118") } )
oMenuItem:AddContent( "+ Trechos (Ped�gio)"	        , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ120") } )
oMenuItem:AddContent( "+ Tipos de Documentos "	    , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ420") } )
oMenuItem:AddContent( "+ Tipos de Venda"	        , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ050") } )
oMenuItem:AddContent( "+ Motivos de Cancelamento"	, "E", { || GTPMONBrow(oWorkArea, "GTPIRJ051") } )
oMenuItem:AddContent( "+ Impressoras (ECF)"	        , "E", { || GTPMONBrow(oWorkArea, "GTPIRJ121") } )

//------------------------------------------------------------------------------------------------------
// Reintegra��es
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder("Reintegra��es", "A") 
oMenuItem := oMenu:GetItem( cMenuItem )

//oMenuItem:AddContent( "+ Reintegra"	        , "E", { || Reintegra() } )
oMenuItem:AddContent( "+ Reintegra Todos", "E", { |z| z := time(), RunAll(), z:= ElapTime(z,Time()), FwAlertSuccess("Processamento finalizado - tempo total: " + z,"Finalizado") } )

oWorkarea:SetMenu( oMenu )

oWorkarea:CreateHorizontalBox( "LINE01" ,aSize[3], .T. )
oWorkarea:SetBoxCols( "LINE01", { "WDGT01" } )

oWorkarea:Activate()

GTPMONBrow(oWorkArea, "SEM FUNCAO - BROWSE VAZIO")  //Inicializa com org�os

oDlgWA:lEscClose := .F.	
oDlgWA:Activate( , , , , , , EnchoiceBar( oDlgWA, {|| },  { || oDlgWA:End()}, , {}, , , , , .F., .F. ) ) //Ativa a janela criando uma enchoicebar

Return

/*/{Protheus.doc} GTPAMVIEW
    (long_description)
    @type  Static Function
    @author user
    @since 15/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPMVIEW()

    FWExecView("Visualizar","GTPRJMODA",MODEL_OPERATION_VIEW,,{|| .T.})

Return 

/*/{Protheus.doc} Integra
    Fun��o para efetuar a integra��o ou reintegra��o dos servi�os REST do
    sistema TotalBus (RJ)
    @type  Static Function
    @author user
    @since 05/08/2021
    @version version
    @param lReintegra, l�gico, .T. para reintegrar, .f. para integrar
    @return lRet, L�gico, .T. processamento ocorreu bem.
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function Integra(lReintegra,cRoutine,lNoAsk)
    
    Local cServNoParams := RetServNoParams()
    Local cRotina       := ""

    Local aParams   := {}
    
    Local lRet      := .T.

    Default lReintegra  := .F.
    Default cRoutine    := oBrwMonit:GetFilterExpression()
    Default lNoAsk      := .F.

    cRotina := cRoutine
    cRotina := Iif(At("=",cRotina) >0, StrTran(Separa(cRotina,"=")[2],"'",""), cRotina)   

    Begin Transaction
    
    If ( GYS->(!Eof()) )

        //Para os servi�os sem par�metros, n�o h� busca pelos
        //par�metros utilizados no servi�os - lista de rotinas 
        //se encontra em cServNoParams
        If ( !(Alltrim(cRotina) $ cServNoParams) .And.; 
            (!Empty(GYS->GYS_URL) .And. lReintegra) )
            aParams := RJGetPars(GYS->GYS_URL,.T.)
        EndIf
        
        If ( lReintegra )
            lRet := GYS->(DeleteLog(GYS_ROTINA,GYS_PARAMS))
        EndIf

    ElseIf ( lReintegra .And. !(Alltrim(cRotina) $ cServNoParams)) 
        FWAlertError("Sem log de erro, n�o � poss�vel Reintegrar", "Sem dados")
    EndIf

    If ( lRet )
        
        If ( !FwIsInCallStack("RUNALL") )
            GTPDummyOn(,.t.)
        EndIf

        Do Case
        //Bilhetes
        Case ( "GTPIRJ115" $ cRoutine ) 
            lRet := Bilhetes(aParams)
        //Receitas e Despesas
        Case ( "GTPIRJ427" $ cRoutine ) 
            lRet := ReceitaDespesa(aParams)            
        //Hor�rios
        Case ( "GTPIRJ004" $ cRoutine ) 
            lRet := Horarios(aParams)            
        //Trechos da Linha
        Case ( "GTPIRJ003" $ cRoutine ) 
            lRet := Trechos(aParams)            
        //Org�os
        Case ( "GTPIRJ000" $ cRoutine ) 
            GTPIRJ000(,,@lRet)
        //Tipos de localidade
        Case ( "GTPIRJ035" $ cRoutine ) 
            GTPIRJ035(,,@lRet)
        //Estado
        Case ( "GTPIRJ001A" $ cRoutine ) 
            GTPIRJA001(,,@lRet)
        //Cidade
        Case ( "GTPIRJ001B" $ cRoutine ) 
            GTPIRJB001(,,@lRet)
        //Localidade
        Case ( "GTPIRJ001" $ cRoutine ) 
            GTPIRJ001(,,@lRet,lNoAsk)
        //Categoria Linha
        Case ( "GTPIRJ011" $ cRoutine ) 
            GTPIRJ011(,,@lRet)
        //Linhas
        Case ( "GTPIRJ002" $ cRoutine ) 
            GTPIRJ002(,,@lRet)
        //Vias
        Case ( "GTPIRJ005" $ cRoutine ) 
            GTPIRJ005(,,@lRet)
        //Colaboradores
        Case ( "GTPIRJ008" $ cRoutine )
            GTPIRJ008(,,@lRet)
        //Tipo de Ag�ncia
        Case ( "GTPIRJ711" $ cRoutine ) 
            GTPIRJ711(,@lRet)
        //Ag�ncia
        Case ( "GTPIRJ006" $ cRoutine ) 
            GTPIRJ006(,,@lRet)
        //Categoria Bilhetes
        Case ( "GTPIRJ118" $ cRoutine ) 
            GTPIRJ118(,@lRet)
        //Trechos (Ped�gio)
        Case ( "GTPIRJ120" $ cRoutine ) 
            GTPIRJ120(,@lRet)
        //Tipos de Documentos
        Case ( "GTPIRJ420" $ cRoutine ) 
            GTPIRJ420(,@lRet)
        //Tipos de Venda
        Case ( "GTPIRJ050" $ cRoutine ) 
            GTPIRJ050(,@lRet)
        //Motivos de Cancelamento
        Case ( "GTPIRJ051" $ cRoutine ) 
            GTPIRJ051(,@lRet)
        //Impressoras (ECF)
        Case ( "GTPIRJ121" $ cRoutine ) 
            GTPIRJ121(,@lRet)
        EndCase

        // Reintegra��o: Se deu erro no consumo do REST, ent�o, dever� fazer o 
        // rollback (DisarmTransaction) da exclus�o pr�via dos dados do log
        // Integra��o: N�o h� necessidade de DisarmTransaction, pois n�o houve 
        // exclus�o pr�via do log de erro 
        If ( !lReintegra .and. !lRet )
            lRet := .T.
        EndIf
        
        If ( !FwIsInCallStack("RUNALL") )            
            GTPDummyOff()
        EndIf

    EndIf

    If ( !lRet )
        DisarmTransaction()
    EndIf

    End Transaction
    
    If ( lRet )
        oBrwMonit:Refresh(.f.,.t.,.t.)
    EndIf

Return(lRet)

Static Function RetServNoParams()

    Local cRotinas := ""

    cRotinas += "GTPIRJ000|GTPIRJ035|GTPIRJ001|GTPIRJ001A|"
    cRotinas += "GTPIRJ001B|GTPIRJ011|GTPIRJ002|GTPIRJ005|"
    cRotinas += "GTPIRJ711|GTPIRJ006|GTPIRJ008|GTPIRJ118|GTPIRJ120|"
    cRotinas += "GTPIRJ420|GTPIRJ050|GTPIRJ051|GTPIRJ121"

Return(cRotinas)

/*/{Protheus.doc} DeleteLog
    Apaga previamente o log que fora gerado para a rotina e par�metros
    @type  Static Function
    @author user
    @since 05/08/2021
    @version version
    @param  cRotina, caractere, Identificador da rotina
            cListPas, caractere, par�metros que foi utilizado no POST do REST
    @return lRet, L�gico, .T. exclus�o ocorreu bem.
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function DeleteLog(cRotina,cListPars)

    Local cDML := ""

    Local nStat := 0

    Local lRet  := .T.

    Default cRotina     := ""
    Default cListPars   := ""
        
    If ( !Empty(cRotina) )

        cDML := "DELETE " 
        cDML += "   "  + RetSQLName("GYS") + " " + chr(13)
        cDML += "WHERE " 
        cDML += "   GYS_ROTINA = '" + Alltrim(cRotina) + "' " + chr(13)
        
        If ( !Empty(cListPars) )
            cDML += "   AND GYS_PARAMS = '" + Alltrim(cListPars) + "' " + chr(13)
        EndiF
    
        nStat := TcSQLExec(cDML)
        
        lRet := nStat >= 0

    EndIf

Return(lRet)

/*/{Protheus.doc} Bilhetes
    Integra/Reintegra o servi�o de Bilhetes
    @type  Static Function
    @author user
    @since 05/08/2021
    @version version
    @param  aParams, array, parametros utilizados para a reintegra��o do 
            servi�o de Bilhetes
            
    @return lMonitOk, L�gico, .F. servi�o REST esta fora do ar
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function Bilhetes(aParams)
    
    Local aFunPars  := {}
    
    Local lMonitOk  := .T.

    Default aParams := {}
    
    aFunPars := SetDefPar(aParams,7)
    
    GTPIRJ115(,aFunPars,@lMonitOk)    

Return(lMonitOk)

/*/{Protheus.doc} ReceitaDespesa
    Integra/Reintegra o servi�o de ReceitaDespesa
    @type  Static Function
    @author user
    @since 05/08/2021
    @version version
    @param  aParams, array, parametros utilizados para a reintegra��o do 
            servi�o de ReceitaDespesa
            
    @return lMonitOk, L�gico, .F. servi�o REST esta fora do ar
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ReceitaDespesa(aParams)
    
    Local aFunPars  := {}
    
    Local lMonitOk  := .T.

    Default aParams := {}
    
    aFunPars := SetDefPar(aParams,7)

    GTPIRJ427(,aFunPars,@lMonitOk) 

Return(lMonitOk)

/*/{Protheus.doc} Horarios
    Integra/Reintegra o servi�o de Horarios
    @type  Static Function
    @author user
    @since 05/08/2021
    @version version
    @param  aParams, array, parametros utilizados para a reintegra��o do 
            servi�o de Horarios
            
    @return lMonitOk, L�gico, .F. servi�o REST esta fora do ar
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function Horarios(aParams)
    
    Local aFunPars  := {}
    
    Local lMonitOk  := .T.

    Default aParams := {}
    
    aFunPars := SetDefPar(aParams,5)

    GTPIRJ004(,,aFunPars,@lMonitOk) 

Return(lMonitOk)

/*/{Protheus.doc} Trechos
    Integra/Reintegra o servi�o de Trechos
    @type  Static Function
    @author user
    @since 05/08/2021
    @version version
    @param  aParams, array, parametros utilizados para a reintegra��o do 
            servi�o de Trechos
            
    @return lMonitOk, L�gico, .F. servi�o REST esta fora do ar
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function Trechos(aParams)
    
    Local aFunPars  := {}
    
    Local lMonitOk  := .T.

    Default aParams := {}
    
    aFunPars := SetDefPar(aParams)

    GTPIRJ003(,,aFunPars,@lMonitOk) 

Return(lMonitOk)

/*/{Protheus.doc} SetDefPar
    Monta a lista de par�metros que ser�o enviados para o REST dos 
    servi�os reintegrados
    @type  Static Function
    @author user
    @since 05/08/2021
    @version version
    @param  aParams, array, parametros utilizados para a reintegra��o do 
            servi�o de Horarios
            nQtdPar, num�rico, quantidade de par�metros utilizados
    @return aFunPars, Array, lista de par�metros convertidos em um vetor
            para o uso nas chamadas das fun��es que consomem o REST de servi�os
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function SetDefPar(aParams,nQtdPar)
    
    Local cValue    := ""
    Local nI        := 0
    Local aFunPars  := {}

    Default aParams := {}
    Default nQtdPar := 1

    If ( Len(aParams) > 0 )
        
        aFunPars := Array(nQtdPar)
        AFill(aFunPars, "")
        
        For nI := 1 to Len(aParams)

            cValue := Iif( Valtype(aParams[nI,2]) == "A" .And. Len(aParams[nI,2]) > 1, aParams[nI,2][2], "")

            If ( "empresa" $ Lower(aParams[nI,1]) )
                aFunPars[1] := cValue
            ElseIf ( "data" $ Lower(aParams[nI,1]) )
                
                If ( "inicial" $ Lower(aParams[nI,1]) ) 
                    
                    If ( nQtdPar >= 2 )
                    
                        aFunPars[2] := SToD("20"+SubStr(cValue,1,6))
                    
                        If ( nQtdPar >= 3 )
                            aFunPars[3] := SubStr(cValue,7)
                        EndIf    

                    EndIf

                ElseIf ( "vigencia" $ Lower(aParams[nI,1]) )
                    aFunPars[1] := SToD(cValue)
                Else

                    If ( nQtdPar >= 4 )
                
                        aFunPars[4] := SToD("20"+SubStr(cValue,1,6))
                
                        If ( nQtdPar >= 5 )
                            aFunPars[5] := SubStr(cValue,7)
                        EndIf
                    
                    EndIf

                EndIf
            
            ElseIf ( "agencia" $ Lower(aParams[nI,1])  )

                If ( "inicio" $ Lower(aParams[nI,1]) )
                    
                    If ( nQtdPar >= 6 )
                        aFunPars[6] := cValue
                    EndIf

                Else

                    If ( nQtdPar >= 7 )
                        aFunPars[7] := cValue
                    EndIf
                    
                EndIf

            EndIf

        Next nI

    EndIf

Return(aFunPars)

/*/{Protheus.doc} RunAll
    Reintegra todos os servi�os TotalBus
    @type  Static Function
    @author user
    @since 16/08/2021
    @version version
    @param  
    @return 
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function RunAll()

    Local aOrdemGTPI    := {}
    Local aSeek         := {}
    Local aResult       := {{"GYS_ROTINA","GYS_PARAMS"}}
    Local nI            := 0
    Local cLista        := "GTPIRJ115|GTPIRJ427|GTPIRJ004|GTPIRJ003"
    Local lRet          := .T.

    aOrdemGTPI := GetAllRoutine()

    GTPDummyOn(,.t.)
    
    For nI := 1 to Len(aOrdemGTPI)

        lRet := .T.

        If ( aOrdemGTPI[nI,1] $ cLista )
            
            aSeek := {}
            Aadd(aSeek, {"GYS_ROTINA",aOrdemGTPI[nI,1]})
            
            lRet := ( GTPSeekTable("GYS",aSeek,aResult,.t.,"R_E_C_N_O_ DESC",.T.) )
        
        EndIf

        If ( lRet )
            Integra(.t.,aOrdemGTPI[nI,1],(Alltrim(aOrdemGTPI[nI,1]) == "GTPIRJ001"))        
        EndIf

    Next nI
    
    GTPDummyOff()
    
Return()

/*/{Protheus.doc} GetAllRoutine
    Retorna todas as rotinas que integram com os servi�os
    da TotalBus
    @type  Static Function
    @author user
    @since 16/08/2021
    @version version
    @param  
    @return aOrdemGTPI, array, cont�m o nome da rotina do Protheus, 
        tabela e descri��o do servi�o
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GetAllRoutine()

    Local aOrdemGTPI := {}
     
    Aadd(aOrdemGTPI,{"GTPIRJ000", "GIO"		,"Org�o"})                     
    Aadd(aOrdemGTPI,{"GTPIRJ035", "G9V"		,"Tipos de localidade"})       
    Aadd(aOrdemGTPI,{"GTPIRJ001A", "SX5"	,"Estado"})                    
    Aadd(aOrdemGTPI,{"GTPIRJ001B", "CC2"	,"Cidade"})                    
    Aadd(aOrdemGTPI,{"GTPIRJ001", "GI1"		,"Localidade"})                
    Aadd(aOrdemGTPI,{"GTPIRJ011", "GYR"		,"Categoria linha"})           
    Aadd(aOrdemGTPI,{"GTPIRJ002", "GI2/G5I"	,"Linhas"})                    
    Aadd(aOrdemGTPI,{"GTPIRJ003", "GI4"		,"Trechos da linha"})     
    Aadd(aOrdemGTPI,{"GTPIRJ004", "GID/GIE"	,"Horarios/Servi�os"})          
    Aadd(aOrdemGTPI,{"GTPIRJ005", "G9U"		,"Vias"})
	Aadd(aOrdemGTPI,{"GTPIRJ008", "GYG"		,"Colaboradores"})
    Aadd(aOrdemGTPI,{"GTPIRJ711", "GI5"		,"Tipo de ag�ncia"})           
    Aadd(aOrdemGTPI,{"GTPIRJ006", "GI6"		,"Ag�ncia"})                   
    Aadd(aOrdemGTPI,{"GTPIRJ118", "G9B"		,"Categoria bilhetes"})        
    Aadd(aOrdemGTPI,{"GTPIRJ120", "G9T"		,"Trechos (ped�gio)"})         
    Aadd(aOrdemGTPI,{"GTPIRJ420", "GZC"		,"Tipos de documentos"})       
    Aadd(aOrdemGTPI,{"GTPIRJ050", "GYB"		,"Tipos de venda"})            
    Aadd(aOrdemGTPI,{"GTPIRJ051", "GYC"		,"Motivos de cancelamento"})   
    Aadd(aOrdemGTPI,{"GTPIRJ115", "GIC/GZP"	,"Bilhetes"})                  
    Aadd(aOrdemGTPI,{"GTPIRJ121", "SLG"		,"Impressoras (ECF)"})         
    Aadd(aOrdemGTPI,{"GTPIRJ427", "GZT/GZP"	,"Receitas e despesas"})

Return(aClone(aOrdemGTPI))

/*/{Protheus.doc} GTPDummyOn
    Fun��o respons�vel por "ligar" o teste Dummy, onde o usu�rio 
    poder� informar a quantidade m�xima de registros que ser�
    executada em cada uma das integra��es.
    @type  Static Function
    @author user
    @since 16/08/2021
    @version version
    @param  nVal, num�rico, valor m�ximo para a quantidade de registros
    @return 
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPDummyOn(nVal,lParam)
    
    Local aParamBox := {}
    Local aPergRet  := {}
    
    Default nVal    := -1
    Default lParam  := .F.

    If ( RuleDummy() )    

        aTestDummy[1] := .t.

        If ( nVal < 0 .Or. lParam )
            
            aTestDummy[2] := 0
            
            aAdd(aParamBox, {1, 'Max. Registros Leitura ',aTestDummy[2], "@e 999999" ,,,, 6, .F.} )	
            
            If ( ParamBox(aParamBox, "Test Dummy On: Defina valor m�ximo de registros", aPergRet) )
                aTestDummy[2] := aPergRet[1]
            EndIf

        Else
            aTestDummy[2] := nVal
        EndIf
    
    Else
        GTPDummyOff()
    EndIf

Return()

/*/{Protheus.doc} GTPDummyOn
    Fun��o respons�vel por "ligar" o teste Dummy, onde o usu�rio 
    poder� informar a quantidade m�xima de registros que ser�
    executada em cada uma das integra��es.
    @type  Static Function
    @author user
    @since 16/08/2021
    @version version
    @param  nVal, num�rico, valor m�ximo para a quantidade de registros
    @return 
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPDummyVal()

Return(aTestDummy[2])

/*/{Protheus.doc} GTPDummyOn
    Fun��o respons�vel por "ligar" o teste Dummy, onde o usu�rio 
    poder� informar a quantidade m�xima de registros que ser�
    executada em cada uma das integra��es.
    @type  Static Function
    @author user
    @since 16/08/2021
    @version version
    @param  nVal, num�rico, valor m�ximo para a quantidade de registros
    @return 
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPDummyOff()
    
    aTestDummy[1] := .f.
    aTestDummy[2] := Nil

Return()

/*/{Protheus.doc} GTPDummyOn
    Fun��o respons�vel por "ligar" o teste Dummy, onde o usu�rio 
    poder� informar a quantidade m�xima de registros que ser�
    executada em cada uma das integra��es.
    @type  Static Function
    @author user
    @since 16/08/2021
    @version version
    @param  nVal, num�rico, valor m�ximo para a quantidade de registros
    @return 
    @example
    (examples)
    @see (links_or_references)
/*/
Function GTPDummyRunning()
    
Return (aTestDummy[1] .and. Valtype(aTestDummy[2]) == "N" )

/*/{Protheus.doc} RuleDummy
    Integra/Reintegra o servi�o de Trechos
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 30/08/2021
    @version version
    @param 
    @return lMonitOk, L�gico, .F. servi�o REST esta fora do ar
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function RuleDummy()
    
    Local lRet  := .F.

    //Cadastrar: GTPSetRules("SETDUMMYON","3","",".F.", "GTPMONIT","Teste Dummy ligado?","")
    lRet := RetCodUsr() == "000000" .And. GTPGetRules("SETDUMMYON",,,.f.)

Return(lRet)

/*/{Protheus.doc} CheckActiveJob
    Verifica se o Job e Agente est�o ativados ou n�o
    @type  Static Function
    @author user
    @since 16/08/2021
    @version version
    @param  
    @return cActive, caractere, texto com a mensagem de schedule ativo ou n�o 
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function CheckActiveJob()

    Local cSchdId   := FWSchdByFunction("GTPJOBRJINTEG")    
    //Local cAlias    := GetNextAlias()
    Local cActive   := ""
                
    If ( FindFunction("GTPJOBRJINTEG") .and. !Empty(cSchdId) )

        If FwAlertYesNo("Deseja consultar o status do schedule GTPJOBRJINTEG ?")
            cActive := GTPSchedGet("GTPJOBRJINTEG")
        Else
            cActive := " n�o verificado"
        Endif

    Else
        cActive := "(Sched. GTPJobRjInteg n�o cadastrado)"
    EndIf

Return(cActive)


/*/{Protheus.doc} GTPMChk
    Verifca se o m�todo escolhido pelo menu lateral possui par�metros. 
    Se n�o possui par�metros, n�o h� necessidade de funcionamento do bot�o
    Integrar, somente a op��o Reintegrar
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 02/09/2021
    @version version
    @param  
    @return lRet, l�gico, .t. - Permite acesso ao bot�o Integrar.
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GTPMChk()

    Local lRet  := .T.

    Local cFunction := oBrwMonit:GetFilterExpression()
 
    cFunction := Iif(At("=",cFunction) > 0, StrTran(Separa(cFunction,"=")[2],"'",""), cFunction)

    If ( Alltrim(cFunction) $ RetServNoParams() )
        lRet := .F.
    Else
        lRet := .T.
    EndIf

Return(lRet)

/*/{Protheus.doc} GTPMainJob
    Verifica se o Job e Agente est�o ativados ou n�o
    @type  Main Function
    @author Fernando Radu Muscalu
    @since 16/08/2021
    @version version
    @param  
    @return
    @example
    (examples)
    @see (links_or_references)
/*/
Main Function GTPMainJob()
    GTPJOBRJINTEG({"T1","D MG 01 "})
Return()

