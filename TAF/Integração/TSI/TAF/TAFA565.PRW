#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//Instancia objeto com comando sql precompilado( FWPreparedStatement() )
Static oStatV5R := V5RPesq()
Static lV5rErp  := V5R->( FieldPos("V5R_ERPKEY") ) > 0
Static lV80AliE := V80->( FieldPos("V80_ALIERP") ) > 0

/*
Metodo respons�vel por persistir os dados enviados via JSON
@author Henrique Fabiano Pateno Pereira
@author Wesley Pinheiro
@since 01/07/2020
@version 1.0 
*/ 
function TAFA565( oHash, aObjJson, nOperation, aRetJs, cSeek, cUltStmp, aREGxV80 )
    
    Local oModel    := Nil
    Local aProperty :=  { }  

    Local nI        := 0 
    Local nY        := 0 
    Local nOrder    := 1
    Local nOpcao    := 0
    Local nPosReg   := 0

    Local cArea     := ''
    Local cField    := ''
    Local cModel    := ''
    Local cSource   := ''
    Local cChave    := ''
    Local cFunc     := ''
    Local cTagId    := ''
    Local cTagIdAux := ''
    Local cProperty := ''

    Local cKey      := ''
    Local cKeySeek  := ''
    Local cCodErro  := '' 
    Local cErro     := ''
    Local cNewStamp := ''
    Local cRegV80   := ''    
    Local lExecute    := .T.
    Local lSucessItem := .T.
    Local lC1H        := .F.

    Local lRest    := IsInCallStack( "RESTEXECUTE" ) // Variavel para controlar quando fun��o for chamada por API REST
    Local lUpdProd := .F.

    Default nOperation := 0
    Default aRetJs     := {}
    Default cSeek      := ''
    Default cUltStmp   := ''
    Default aREGxV80   := {}

    //Busca informa��es para gravacao dos dados
    hmget( oHash, "m_o_d_e_l_"  , @cModel   )
    hmget( oHash, "s_o_u_r_c_e_", @cSource  )
    hmget( oHash, "a_r_e_a_"    , @cArea    )
    hmget( oHash, "o_r_d_e_r_"  , @nOrder   ) 
    hmget( oHash, "k_e_y_"      , @cKeySeek )

    if empty(cSeek)
        hmget( oHash, "s_e_e_k_"    , @cSeek    )
    endif

    hmget( oHash, "t_a_g_i_d_"  , @cTagId   )

    //Carrega Model para grava��o
    DBSelectArea( cArea ) 
    DBSetOrder( nOrder ) 
    oModel := FwLoadModel( cSource )

    If cArea == "C1L"
        DbSelectArea( "SAH" )
        SAH->( DbSetOrder( 1 ) ) 

        DbSelectArea( "SYD" )
        SYD->( DbSetOrder( 1 ) ) 
    EndIf

    DbSelectArea( "V5R" )
    V5R->( DbSetOrder( 1 ) ) //V5R_FILIAL, V5R_CODFIL, V5R_ALIAS, V5R_REGKEY

    for nI := 1 to Len( aObjJson )

        cKey        := &cKeySeek
        lExecute    := .T.
        lUpdProd    := .F.

        /*
            Variavel utilizada para verificar se houve erro em alguma propriedade do json ( menos para a opera��o MODEL_OPERATION_DELETE - API REST )
            Caso receba .F., invalidar� a folha inteira de dados e o erro ser� retornado em aRetJs
        */
        lSucessItem := .T.

        /* 
            Caso nOperation seja igual a MODEL_OPERATION_UPDATE ou MODEL_OPERATION_DELETE,
            a fun��o TAFA565 foi chamada por verbo API REST ( PUT ou DELETE ).
            Pois para esses verbos HTTP ( PUT ou DELETE ), � necess�rio validar se o registro exite.
            Se houver falha, � retornado o erro e a chave do item que n�o foi encontraado na base.

            Para o verbo HTTP POST, a fun��o TAFA565 ter� o mesmo comportamento da integra��o PROTHEUS x TAF
        */
        if nOperation == MODEL_OPERATION_UPDATE .or. nOperation == MODEL_OPERATION_DELETE

            nOpcao := nOperation

            if !&cSeek
                lExecute := .f.

                cCodErro := 'NOTEXIST'
                cProperty := aObjJson[nI][cTagId]    
                cErro := RetErroTaf( cProperty, aObjJson[nI], cField, cCodErro, cKey )

                // grava tabela de log e alimenta o aRetJs para retorno ao rest
                AgrupaErro( cKey, cErro, aRetJs )
                putTsiV5r( cArea, cKey, aRetJs, aObjJson[nI]["stamp"] )
            endif
            
        else
            nOpcao := IIf( &cSeek, MODEL_OPERATION_UPDATE, MODEL_OPERATION_INSERT )
        endif

        If lExecute
            oModel:SetOperation( nOpcao )

            oModel:Activate( )

            if nOpcao <> MODEL_OPERATION_DELETE
                // Retorna as propriedades ( Tags ) do Json
                aProperty := aObjJson[nI]:GetNames( )

                /*
                    Pecorremos as propriedades do Json para para a posi��o nI
                */ 
                Begin Sequence

                    for nY := 1 to Len( aProperty )

                        cTagIdAux   := ""
                        
                        /*
                            Com a propriedade do json em m�os ( EX: aProperty[nY] := "itemId" )
                            Buscamos no objeto oHash o campo a ser utilizado para grava��o
                            e retornamos na vari�vel @cField.

                            Ex: Se o Hash passado como parametro for de produto:

                            hmget( oHash, "itemId", @cField )

                            cField ter� o conte�do "C1L_CODIGO"

                        */
                        If hmget( oHash, aProperty[nY], @cField ) 

                            // Retornamos o cont�udo da propriedade que ser� gravado
                            cChave := aObjJson[nI][aProperty[nY]]
                            
                            // Tratamento de-para para campos F3 
                            If "#F3#" $ cField

                                cField := SubStr( cField, 1, Len( cField ) - 4 )
                                
                                If !empty( cChave )
                                    hmget( oHash, "#F3#"+cField, @cFunc )
                                    cChave := &cFunc

                                    If "NOTFOUND" == cChave
                                        lSucessItem := .F.
                                        cChave := aObjJson[nI][aProperty[nY]]

                                        /*
                                            Caso seja enviado o cadastro de produto por API REST, � necess�rio informar cadastro n�o encontrado para UN/NCM no log V5R
                                            Por isso foi adicionado a variavel lRest.
                                            O comportamento para atualizar stamp � somente para o Protheus
                                        */
                                        
                                        HMGet( oHash, cField, @cProperty )
                                        cErro := RetErroTaf( cProperty, aObjJson[nI], cField, "NOTFOUND" )
                                        AgrupaErro( cKey, cErro, @aRetJs )
                                        if !(cSource != 'TAFA057' .or. !cField $ ('C1L_UM|C1L_CODNCM') .or. lRest)
                                            if (cField == 'C1L_UM' .and. SAH->(DbSeek(xFilial("SAH") + Alltrim(aObjJson[nI][aProperty[nY]])))) .or. ;
                                               (cField == 'C1L_CODNCM' .and. SYD->(DBSeek(xFilial("SYD") +  Alltrim(aObjJson[nI][aProperty[nY]]) ) ) )                                             
                                                //Passo como par�metro o campo da tabela e o cont�udo da propriedade que ser� alterada para grava��o do stamp
                                                VldErrInt( cField, aObjJson[nI][aProperty[nY]] )
                                                lUpdProd := .T.
                                            endIf    
                                        endif

                                    EndIf  

                                EndIf 

                            // Tratamento para campos tipo data
                            elseif "#DT#" $ cField
                                cField := SubStr( cField, 1, Len( cField ) - 4 ) 
                                if valtype( cChave ) == 'C' 
                                    cChave := ctod( cChave) 
                                    if alltrim( cvaltochar( cChave ) ) == "/  /" .or. empty( alltrim( cvaltochar( cChave ) ) )
                                        cChave  := cTod( '' )   
                                    endif
                                endif     
                            EndIf

                            /*
                                Para o verbo HTTP PUT, al�m da chave do registro ser enviado na URL( exemplo items -> itemid ), � enviado tamb�m no json.
                                Quando � enviado o id pela URL, o seek j� � enviado com o parametro para a fun��o TAFA565.
                                
                                Dessa forma, nada garante que o id enviado na URL seja igual ao id dentro do Json, exemplo:

                                Na URL:
                                /rest/api/tsi/v1/tsiitem/PROD992

                                No Json:
                                "itemid" : "PROD993"

                                O tratamento abaixo ( cTagIdAux <> cTagId ) garante que o campo chave no modelo n�o ser� alterado para um conte�do diferente do id enviado na URL.
                                OBS: caso seja definido que o PUT n�o ter� id na URL, o tratamento abaixo n�o ser� necess�rio
                            */
                            if nOpcao == MODEL_OPERATION_UPDATE
                                hmget( oHash, cField  , @cTagIdAux   ) 
                            endif

                            if cTagIdAux <> cTagId 

                                if valtype( cChave ) == "U" .or. !oModel:loadvalue( cModel, cField, cChave ) //Valida a inclus�o do campo

                                    cField    := oModel:GetErrorMessage( )[4]
                                    cCodError := oModel:GetErrorMessage( )[5]
                                    HMGet( oHash, cField, @cProperty )
                                    cErro := RetErroTaf(  cProperty, aObjJson[nI], cField, cCodError )

                                    AgrupaErro( cKey, cErro, @aRetJs )
                                    lSucessItem := .F.

                                /*
                                    Para utilizar o VldData do Model, foi necess�rio retirar o tratamento para a grava��o do conte�do json de acordo com o X3_TAMANHO.
                                    
                                    Uma vez que houve erro no model, o VldData sempre retornar� falso, 
                                    porem ao retirar o vlddata deste fonte, o commit pode ser realizado sem campos obrigatorios preenchidos.
                                    
                                    Mesmo atribuindo oModel:lValid := .T. e limpando os erros ( oModel:GetErrorMessage( .T. ) ), 
                                    o vldData n�o tem o comportamento esperado e n�o valida os campos obrigat�rios que n�o foram preenchidos.

                                    Teste efetuado para este cen�rio ( sem vldData ):

                                    Inclus�o de produto por API REST
                                    "un": "" -> campo obrig�torio vazio
                                    "description": "conteudo maior do que X3_TAMANHO do campo C1L_DESCRI"

                                    O registro foi incluido sem a informa��o de unidade de medida


                                    //Se n�o validou devido ao tamanho do campo, formata o conteudo que ser� gravado no item.
                                    if oModel:GetErrorMessage()[5] == 'FWNOWIDTH'

                                        oModel:ClearField( cModel, cField )

                                        nIndCpo := aScan( oModel:GetModelStruct(cModel)[3]:OFORMMODELSTRUCT:AFIELDS, { |x| x[3] == cField } )
                                        nTamCpo := oModel:GetModelStruct(cModel)[3]:OFORMMODELSTRUCT:AFIELDS[nIndCpo][5]
                                        lLoadOk := oModel:loadvalue( cModel, cField, left(cChave, nTamCpo ) )
                                    else
                                        lLoadOk := .F.
                                    endif

                                    if !lLoadOk
                                        //Prepara a mensagem de log/retorno
                                        cField    := oModel:GetErrorMessage( )[4]
                                        cCodError := oModel:GetErrorMessage( )[5]
                                        HMGet( oHash, cField, @cProperty )
                                        cErro := RetErroTaf(  cProperty, aObjJson[nI], cField, cCodError )

                                        AgrupaErro( cKey, cErro, @aRetJs )
                                        lSucessItem := .F.
                                    endif
                                */
                                endif
                            EndIf

                        EndIf
                    Next nY
                End Sequence
            EndIf

            BEGIN TRANSACTION
                If oModel:VldData( ) .and. lSucessItem
                    FwFormCommit( oModel )
                    aadd( aRetJs, { lSucessItem, cKey } )
                    ClearV5R( cArea, cKey )
                Else
                    DisarmTransaction( )

                    cField    := oModel:GetErrorMessage( )[4]
                    cCodError := oModel:GetErrorMessage( )[5]

                    If !Empty( cCodError )
                        HMGet( oHash, cField, @cProperty )
                        cErro := RetErroTaf(  cProperty, aObjJson[nI], cField, cCodError )
                        If Empty(cErro)
                            cErro := cCodError
                        EndIf
                        AgrupaErro( cKey, cErro, @aRetJs )
                    EndIf

                    If !Empty( aRetJs )
                        putTsiV5r( cArea, cKey, aRetJs, aObjJson[nI]["stamp"] )
                    Endif

                    If lUpdProd
                        VldErrInt( "C1L_CODIGO", cKey )
                        lUpdProd := .F.
                    EndIf
                EndIf

                lC1H := "C1H" $ cField //Ultimo campo da C1H processado eh o "C1H_STAMP" nao eh campo fake

                //Guardo o stamp para retornar ao fonte TAFA573 e gravar na V80 (Data de corte)
                cNewStamp := aObjJson[nI]["stamp"]

                if lC1H .And. lV80AliE //.And. lSucessItem (Armazenar o �ltimo independente do sucesso)
                    cRegV80 := ''
                    if !empty( cKey )
                        cRegV80 := "C1H|" + iif( SubStr(AllTrim(cKey),1,1) == 'C', 'SA1', 'SA2' )
                        nPosReg := aScan( aREGxV80 , {|x| x[1] == cRegV80 } )
                        if nPosReg > 0
                            if empty(aREGxV80[nPosReg][2]) .Or. iif(FindFunction('TsiCompStamp'),TsiCompStamp(cNewStamp,aREGxV80[nPosReg][2]), cNewStamp > aREGxV80[nPosReg][2])
                                aREGxV80[nPosReg][2] := cNewStamp
                            endif
                        endif
                    endif
                else
                    if empty(cUltStmp) .Or. iif(FindFunction('TsiCompStamp'),TsiCompStamp(cNewStamp, cUltStmp),cNewStamp > cUltStmp)
                        cUltStmp := cNewStamp
                    endif
                endif
            END TRANSACTION
            oModel:DeActivate( )
        EndIf
    Next nI

Return Nil

/*
Metodo respons�vel por persistir os dados na tabela de log dee erros 
Respons�vel tbm por retornar erros e sucessos ao array de retorno quando a requisi��o � via rest
@author Henrique Fabiano Pateno Pereira
@since 22/07/2020
@version 1.0 
*/
function putTsiV5r( cArea, cKey, aRetJs, cStamp, cKeyErp )

Local cQuery    := ''
Local cAlias    := GetNextAlias()
Local nRegV5r   := 0
Local lNewV5R   := .T.
Local nPos      := 0
Local cErro     := ""

Default cStamp  := ''
Default cKeyErp := ''

//Passa os parametros para o objeto da query
oStatV5R:SetString( 1, xFilial( "V5R" ) )
oStatV5R:SetString( 2, xFilial( cArea ) )
oStatV5R:SetString( 3, cArea            )
oStatV5R:SetString( 4, rTrim(cKey)    )

cQuery := oStatV5R:GetFixQuery( )

DBUseArea(.t.,'TOPCONN', TCGenQry(,,cQuery), cAlias , .f., .t. )

if (cAlias)->(!eof())
    nRegV5r := (cAlias)->RECNO
    lNewV5R := .f.
endif
(cAlias)->(DbCloseArea())

/*
    obtem o erro aglutinado para gravacao
    aRetJs -> variavel alimentada pela fun��o AgrupaErro
*/
nPos := aScan(aRetJs,{|x| x[1] == .F. .And. x[2] == cKey })
if nPos > 0
    cErro := aRetJs[nPos][4]
endif

//Posiciono no registro para alteracao
if !lNewV5R; V5R->(DbGoTo(nRegV5r)); endif

RecLock( 'V5R', lNewV5R  )
    if lNewV5R // Caso seja inclus�o
        V5R->V5R_FILIAL := xFilial( "V5R" ) // Compartilhamento da tabela V5R
        V5R->V5R_CODFIL := xFilial( cArea )// Filial responsavel pelo registro, por isso utilizamos cFilAnt
        V5R->V5R_ALIAS  := cArea
        V5R->V5R_REGKEY := rTrim(cKey)
    endif
    // Campos abaixo sempre s�o atualizados
    V5R->V5R_MSGERR := cErro
    V5R->V5R_DATA   := dDataBase
    V5R->V5R_HORA   := Time( )
    V5R->V5R_STAMP  := cStamp
    if lV5rErp //Gravacao do novo campo V5R_ERPKEY, utilizado na alteracao fake da V5R para a C20.
        V5R->V5R_ERPKEY := rTrim(cKeyErp)
    endif
V5R->( MSUnlock( ) )

Return Nil

/*
Aglutina todos os erros por chave de registro
@author Wesley / Denis
@since 22/07/2020
@version 1.0 
*/
function AgrupaErro( cKey, cErro, aRetJs )

    Local nPos      := 0

    //Regra para aglutinacao de erro para nota por chave.
    nPos  := aScan( aRetJs,{|x| x[2] == cKey } )
    if nPos == 0
        aadd( aRetJs,{ .F. ,cKey, "Erro", cErro } )
    else
        if !( Alltrim( cErro ) $ aRetJs[nPos][4] )
            aRetJs[nPos][4] += " | " + cErro
        endif
    endif

return Nil

/*
Funcao responsavel por criar um objeto FWPreparedStatement() e setar a query de pesquisa
@author Carlos Eduardo Nonato da Silva
@since 24/11/2020
@version 1.0 
*/ 
Static Function V5RPesq()
Local cQuery := ''
Local oStatPesq := Nil

cQuery := " SELECT "
cQuery += "     R_E_C_N_O_ RECNO"
cQuery += " FROM " + RetSqlName('V5R')
cQuery += " WHERE D_E_L_E_T_ = ' ' "
cQuery += " 	AND V5R_FILIAL = ? " //1
cQuery += " 	AND V5R_CODFIL = ? " //2
cQuery += " 	AND V5R_ALIAS  = ? " //3
cQuery += " 	AND V5R_REGKEY = ? " //4

oStatPesq := FWPreparedStatement():New()
oStatPesq:SetQuery(cQuery)

return oStatPesq

/*
Funcao responsavel por verificar se o erro retornado na integra��o pode ser corrigido automaticamente pela rotina.
Caso seja poss�vel faz uma aletra��o fake na tabela\registro do erp para alimentar o campo S_T_A_M_P_ e atualizar o TAF.
@author Carlos Eduardo Nonato da Silva
@since 29/12/2020
@version 1.0 
*/ 
Static Function VldErrInt(cField, cCondQry)
Local lRet := .t.
Local cQryUpd := ''

if cField == 'C1L_UM'
     //Altera unidade de medida
    cQryUpd := " UPDATE " + RetSqlName('SAH') + " SET D_E_L_E_T_ = ' ' WHERE D_E_L_E_T_ = ' ' AND AH_FILIAL = '" + xFilial('SAH') + "' AND AH_UNIMED = '" + cCondQry + "' "
elseif cField == 'C1L_CODNCM'
    //Altera NCM
    cQryUpd := " UPDATE " + RetSqlName('SYD') + " SET D_E_L_E_T_ = ' ' WHERE D_E_L_E_T_ = ' ' AND YD_FILIAL = '" + xFilial('SYD') + "' AND YD_TEC = '" + cCondQry + "' "
elseIf cField == "C1L_CODIGO"   
    //For�a update no produto para integrar novamente, caso na primeira integra��o nao tenha unidade ou ncm
    cQryUpd := " UPDATE " + RetSqlName('SB1') + " SET D_E_L_E_T_ = ' ' WHERE D_E_L_E_T_ = ' ' AND B1_FILIAL = '" + xFilial('SB1') + "' AND B1_COD = '" + cCondQry + "' "
endif    

TcSqlExec(cQryUpd)

return lRet
