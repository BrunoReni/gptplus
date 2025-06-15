#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TECXCAROL.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecFtCarol

@description Utiliza a classe ServCarol para enviar as fotos dos funcionários
que são atendentes para a plataforma Carol 

@author	Diego Bezerra
@since	18/04/2023
/*/
//------------------------------------------------------------------------------

Function TecFtCarol(aData,aDtReturn,lInvite)
    Local oServCarol := Nil
    Local aErr := {}
    Local cMsgErr := ""
    Default aData := {}

    Processa({|| conectCarol(@oServCarol)},STR0001,STR0002)//"Conectando com a plataforma Carol"#"Aguarde"
    
    If !Empty(oServCarol:getAuthKey())
        PUTMV("MV_APICLOA",ALLTRIM(oServCarol:getAuthKey()))
    EndIf

    If !oServCarol:getLError()
        processData(oServCarol,aData,lInvite)
    Else
        aErr := oServCarol:getError()
        if Len(aErr) > 0 
            cMsgErr += 'Método ' + aErr[1][1]+CRLF
            cMsgErr += 'Mensagem: ' + aErr[1][2] 
        EndIf
        Help( ,, 'Comunicação com Carol',, cMsgErr, 1, 0) 
    EndIf
Return

Static Function conectCarol(oServCarol)
    oServCarol := ServCarol():New(Alltrim(SUPERGETMV('MV_APICLO1', .F., '')))
    oServCarol:defConector(Alltrim(SUPERGETMV('MV_APICLO3', .F., '')))
    oServCarol:defOrg(Alltrim(SUPERGETMV('MV_APICLO9', .F., '')))
    oServCarol:defDomin(Alltrim(SUPERGETMV('MV_APICLO6', .F., '')))
    oServCarol:defUser(Alltrim(SUPERGETMV('MV_APICLO4', .F., '')))
    oServCarol:defPw(Alltrim(SUPERGETMV('MV_APICLO5', .F., '')))

    /* Caso cPath não seja informado, será considerado o caminho
    da api '/api/v3/oauth2/token'*/
    oServCarol:defEndpoint(/*cPath*/)

    oServCarol:auth(/*cPath*/,/*cAuthType*/,/*cParamKey*/,/*lGeraToken*/.F.,/*cTknApiEnd*/)
    
    if !oServCarol:getLError()
        /* Salvar apikey no parâmetro MV_APICLOA Caso cEndPoint não seja informado, 
            será considerado o endpoint '/api/v3/staging/intake/' */
        oServCarol:defAuthKey(/*cEndPoint*/)
    EndIf

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} processData

@description Realiza o envio de imagens para a plataforma carol, utilizando um 
objeto do tipo ServCarol, autenticado
@param oServCarol, ServCarol, objeto autenticado do tipo ServCarol
@author	Diego Bezerra
@since	18/04/2023
/*/
//------------------------------------------------------------------------------
Static Function processData(oServCarol,aData,lInvite)
    Local cPathPict		:= GetSrvProfString("Startpath","")
    Local cBmpPic       := ""
    Local aParams       := {}
    Local oSayMtr       := NIL
    Local oMeter        := Nil
    Local oDlg          := Nil
    Local nMeter        := 0
    Local aAtend        := {}
    Local cMtrTitle     := ""
    Local cMtrMsg       := ""
    Default aData       := {}
   
    If lInvite
        cMtrTitle   := "Criação de usuários Carol."
        cMtrMsg     := "Enviando convite para os usuários." 
    Else
        cMtrTitle   := STR0003
        cMtrMsg     := STR0004
    EndIf

    If !Empty(oServCarol:getAuthToken())
        If !Empty(aData)
            aAtend := aData
        Else
            aAtend := getDataToSend(aData)
        EndIf

        AADD(aParams, {'conectorId', oServCarol:getConector()})

        DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE cMtrTitle Style 128 //"Exportar fotos para a Plataforma Carol" 
            oSayMtr := tSay():New(10,10,{||cMtrMsg},oDlg,,,,,,.T.,,,220,20) //"Enviando fotos, aguarde..." 
            oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},Len(aAtend),oDlg,220,10,,.T.)
        ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnvioCarol(@oDlg,@oMeter,aAtend,cBmpPic,cPathPict,aParams,@oServCarol,lInvite))
    EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} EnvioCarol

@description Realiza o envio das fotos para a plataforma Carol
@param oDlg, objeto, representação da janela que exibirá o componente contador de progresso oMeter
@param oMeter, objeto, representa o objeto contador de progresso
@param aAtend, array, array com dados e fotos do atendente que serão enviadas
@param cBmpPic, string, nome do arquivo de foto que será criado (extraído do cadastro de funcionários)
@param cPathPict, string, caminho padrão do arquivo que será criado (geralmente pasta system)
@param aParams, array, parâmetros adicionais para o envio das fotos
@param oServCarol, objeto, objeto do tipo ServCarol utilizado para fazer a integração entre protheus e carol

@author	Diego Bezerra
@since	08/05/2023
/*/
//------------------------------------------------------------------------------
Static function EnvioCarol(oDlg, oMeter, aAtend,cBmpPic,cPathPict,aParams,oServCarol,lInvite)
Local cBase64       := ""
Local cBodyStagin   := ""
Local nX            := 1
Local lLoadBar      := !isBlind() .AND. oMeter != nil .AND. oDlg != nil
Local oFile         := Nil
Local nCount        := 0

For nX := 1 to Len(aAtend)
    If lInvite
        oServCarol:sendUserInvite(;
                    "mdmAdminInvite",;
                    ALLTRIM(aAtend[nX][5]),;
                    oServCarol:getBaseUrl()+"/auth/register/env/"+oServCarol:getOrg()+"?",;
                    "business";
                ) 
    Else
        cBmpPic := UPPER(ALLTRIM(aAtend[nX][1]))
        If RepExtract(cBmpPic,cPathPict+cBmpPic)
            If File(cPathPict + cBmpPic+".JPG")
                oFile := FwFileReader():New(cPathPict + cBmpPic+".JPG")
                If oFile:Open()
                    cBase64 := Encode64(,oFile:CFILENAME,.F.,.F.)
                    cBase64 := "data:image/jpg;base64," + cBase64
                    cBodyStagin := '[{"imagecode":"' + aAtend[nX][2] + '","imagedata": "' + cBase64 + '","imagesequence": 1 }]'
                    oServCarol:addStagingValue(;
                        /*cTable*/"employeeimage",;
                        /*cBodyReq*/cBodyStagin,;
                        /*aParams*/aParams,;
                        /*cConector*/,;
                        /*cEndPoint*/,;
                        /*cAuth*/,;
                        /*aCustomHeaders*/;
                    )
                    setEnvCarol(aAtend[nX][4],aAtend[nX][3])
                EndIf
            EndIf
        EndIf
    EndIf
    If lLoadBar
        oMeter:Set(++nCount)
        oMeter:Refresh()
    EndIf
Next nX

If lLoadBar
    oDlg:End()
    If lInvite
        Help(" ",1,STR0005, ,"Convite para utilização enviado com sucesso.", 3, 1 )//"Integração Carol"#"Convite para utilização enviado com sucesso."
    Else
        Help(" ",1,STR0005, ,STR0006, 3, 1 )//"Integração Carol"#"Processamento de envio das fotos finalizado. "
    EndIf
EndIF

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} getDataToSend

@description Recupera o valor do campo RA_BITMAP doss atendentes que são funcionários
@param aData, Array, dados do cadastro do atendente (para exportação individual)
@return aRet, Array, array com os campos RA_BITMAP E RA_CIC dos atendentes, no formato:
    {
        {
            'RA_BITMAP',
            'RA_CIC'
        }
    }
@author	Diego Bezerra
@since	18/04/2023
/*/
//------------------------------------------------------------------------------
Function getDataToSend(aData)

Local aRet      := {}
Local cQry      := ""
Local cAlias    := GetNextAlias()

Default aData := {}

If Len(aData) > 0
    cQry += "SELECT RA_BITMAP,RA_CIC,AA1_CODTEC,AA1_FILIAL,AA1_EMAIL FROM " + RetSqlName('AA1') + " AA1 "
    cQry += "INNER JOIN " + RetSqlName('SRA') + " SRA "
    cQry += "ON SRA.RA_MAT = AA1.AA1_CDFUNC AND "
    cQry += "SRA.RA_FILIAL = '" + xFilial('SRA') + "' AND "
    cQry += "AA1.AA1_FILIAL = '" + xFilial('AA1') + "' "
    cQry += "WHERE SRA.RA_BITMAP <> ''"

    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry), cAlias, .F., .T.)

    While (cAlias)->(!EOF())
        AADD(aRet,{(cAlias)->RA_BITMAP,(cAlias)->RA_CIC,(cAlias)->AA1_CODTEC,(cAlias)->AA1_FILIAL,(cAlias)->AA1_EMAIL })
        (cAlias)->(DbSkip())
    End
    (cAlias)->(dBCloseArea())
Else
    aRet := aData
EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} qryBrw

@description Responsável por fazer a query utilizada na montagem do mark browse
@param cMark, string, restorna query, alias e colunas que serão exibidas no mark browse
@param cCodtec, string, código do técnico que será exportado. Parâmetro não obrigatório. 

@return aRet, array, {query<string>, alias<string>, colunas<array>}
@author	Diego Bezerra
@since	08/05/2023
/*/
//------------------------------------------------------------------------------
Static Function qryBrw(cMark,cCodTec,lInvite)

Local cQry      := ''
Local aCampos   := {}
Local aRetCol   := {}
Local cAlias    := GetNextAlias()
Local nX        := 1
Local aTmpFld   := {}
Local nReg      := 0
Local aRet      := {}

Default cMark   := 'C'
Default cCodTec := ''
aAdd(aCampos, 'AA1_CODTEC')
aAdd(aCampos, 'AA1_NOMTEC')
//aAdd(aCampos, 'RA_CIC')

If lInvite
    aAdd(aCampos, 'AA1_EMAIL')
EndIf

cQry += "SELECT '' OK, AA1_FILIAL,AA1_CODTEC, AA1_NOMTEC, AA1_EMAIL, AA1_ICAROL, RA_CIC, RA_BITMAP FROM " + RetSqlName('AA1') + " AA1 "
cQry += "INNER JOIN " + RetSqlName('SRA') + " SRA "
cQry += "ON SRA.RA_MAT = AA1.AA1_CDFUNC AND "
cQry += "SRA.RA_FILIAL = '" + xFilial('SRA') + "' AND "
cQry += "AA1.AA1_FILIAL = '" + xFilial('AA1') + "' "
cQry += "WHERE SRA.RA_BITMAP <> '' "

If !Empty(cCodTec)
    cQry += "AND AA1.AA1_CODTEC = '"+ ALLTRIM(cCodTec)+"' "
EndIf

If lInvite
    cQry += "AND AA1.AA1_EMAIL <> ''"
EndIf
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry), cAlias, .F., .T.)
	
While !(cAlias)->(Eof()) 
    nReg++
    (cAlias)->(DbSkip())
End
(cAlias)->(DbGoTop())
If nReg > 0
    For nX := 1 to Len(aCampos)
        aTmpFld := retInfFld(aCampos[nX])

        aAdd(aRetCol, FWBrwColumn():New())
        aRetCol[nX]:SetData( &("{||" + aCampos[nX] + "}"))
        aRetCol[nX]:SetTitle(aTmpFld[1])
        aRetCol[nX]:SetSize(aTmpFld[3])
        aRetCol[nX]:SetDecimal(aTmpFld[4])
        aRetCol[nX]:SetPicture(aTmpFld[5])
    Next nX
    aRet := {cQry,cAlias,aRetCol}
EndIf
Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} attToCarol

@description Abrir browse para exibir os atendentes, que são funcionários e serão exportados para a Carol
@param oView, objeto, objeto de view passado via chamada da view def do teca020, quando chamado do menu da view

@author	Diego Bezerra
@since	08/05/2023
/*/
//------------------------------------------------------------------------------
Function attToCarol(lUnic,cCod,lInvite)
Local aRetQry       := {} 
Local oMark         := FWMarkBrowse():New()
Local cTabAlias     := getNextAlias()
Local cMsg          := ""
Local cCodTec       := ""
Local cBwTitle      := ""
Local cBwDesc       := ""
Local cBtnTitle     := ""
Default cAlias      := ""
Default lInvite     := .F.

If !Valtype(lInvite) == 'L'
    lInvite := .F.
EndIf

If lInvite
    cBwTitle    := STR0021 //"Convidar usuários para o app meu posto by carol."
    cBwDesc     := STR0022 //"Enviar Convites"
    cBtnTitle   := STR0023 //"Enviar"
Else
    cBwTitle := STR0007
    cBwDesc  := STR0009
    cBtnTitle := STR0008
EndIf
If Valtype(lUnic) == 'L' .AND. lUnic
    cCodTec := cCod
EndIf

If AA1->(ColumnPos('AA1_ICAROL')) > 0
    If !Empty(cCodTec)
        sendDataCarol(,cCodTec,lInvite)
    Else
        aRetQry := qryBrw('C',,lInvite)
        If Len(aRetQry) > 0
            If !IsBlind()
                DEFINE MSDIALOG oDlg TITLE cBwTitle From 300,0 To 700,1000 PIXEL //"Exportação de atendentes x Plataforma Carol"
                    oMark:SetOwner(oDlg)
                    oMark:SetDataQuery(.T.)
                    oMark:AddButton(cBtnTitle,{||sendDataCarol(oMark,,lInvite),oDlg:End()},,3,)
                    oMark:AddButton("Marcar todos",{||oMark:AllMark()})			
                    oMark:setDescription(cBwDesc) 
                    oMark:setAlias(cTabAlias)
                    oMark:setQuery(aRetQry[1])
                    oMark:setColumns(aRetQry[3])
                    oMark:setFieldMark('OK')
                    oMark:setAllMark({|| oMark:AllMark() })
                    oMark:DisableReport()
                    oMark:SetMenuDef("")
                    oMark:Activate()
                    markReg(oMark)
                ACTIVATE MSDIALOG oDlg CENTERED
            EndIf
        Else
            Help(" ",1,STR0010, ,STR0011, 3, 1 )//"Integração Carol"#"Não existem atendentes com fotos para serem exportadas."
        EndIf
    EndIf
Else
    // Exibe mensagem de erro caso não exista o campo AA1_ICAROL criado
    cMsg += STR0012 + CRLF //'É necessário a criação do campo'
    cMsg += STR0013 + ' AA1_ICAROL'+CRLF //"Nome: "
    cMsg += STR0014 + CRLF //' Titulo: Int. Carol'
    cMsg += STR0015 + CRLF //' Tipo: Numérico'
    cMsg += STR0016 + CRLF //' Tamanho: 1'
    cMsg += STR0017 // ' Formato: 9'
    IF !ISBLIND()
        AtShowLog(cMsg, STR0018,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.)  //'Necessidade de ajustes na base de dados'
    EndIf
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} markReg

@description Realiza a marcação dos registros elegíveis para exportação de fotos
@param oMark, objeto, objeto que representa o markbrowse

@author	Diego Bezerra
@since	08/05/2023
/*/
//------------------------------------------------------------------------------
Static function markReg(oMark,lInvites)

Local nX        := 1
Local nLimite   := 1
Local cAlias    := oMark:Alias()
Local nOpt      := 0

If lInvites
    nOpt := 3
Else
    nOpt := 2
EndIf

oMark:GoBottom(.F.)
nLimite := oMark:At()
oMark:GoTop()

For nX := 1 to nLimite
    IF (cAlias)->AA1_ICAROL <> nOpt
        oMark:MarkRec()
    EndIf
    oMark:GoDown()
Next nX
oMark:Refresh(.T.)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} retInfFld

@description Retorna a estrutura de um determinado campo, do dicionário de dados
@param cCampo, string, nome do campo

@author	Diego Bezerra
@since	08/05/2023
/*/
//------------------------------------------------------------------------------
Static Function retInfFld( cCampo )

Local aArea	:= GetArea()
Local aDados	:= {}

DbSelectArea('SX3')		//Campos da tabela
SX3->( DbSetOrder(2) )	//X3_CAMPO
SX3->( DbGoTop() )

If ( SX3->( MsSeek( cCampo ) ) )

	AAdd( aDados, X3Titulo() )			//Retorna título do campo no X3
	AAdd( aDados, X3Descric() )			//Retorna descrição do campo no X3
	AAdd( aDados, TamSX3(cCampo)[1] )	//Retorna tamanho do campo
	AAdd( aDados, TamSX3(cCampo)[2] )	//Retorna quantidade de casas decimais do campo
	AAdd( aDados, X3Picture(cCampo) )	//Retorna a picture do campo

EndIf

RestArea( aArea )

Return aDados

//------------------------------------------------------------------------------
/*/{Protheus.doc} setEnvCarol

@description Atualiza o registro da tabela AA1 para sinalizar que este teve a foto enviada para a plataforma Carol
@param cFil, string, filial
@param cCodTec, string, código do técnico que será enviado

@author	Diego Bezerra
@since	08/05/2023
/*/
//------------------------------------------------------------------------------
Static Function setEnvCarol(cFil,cCodTec)

Local aAreaAA1 := AA1->(GetArea())

AA1->(DbSetOrder(1))
AA1->(DbSeek(cFil+cCodTec))
AA1->(RecLock("AA1",.F.))
AA1->AA1_ICAROL := 2
AA1->(MsUnlock())

RestArea(aAreaAA1)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} sendDataCarol

@description Realiza a exportação das fotos para a plataforma carol
@param oMark, objeto, objeto que representa o markbrowse
@param cCodTec, string, código do técnico que será enviado

@author	Diego Bezerra
@since	08/05/2023
/*/
//------------------------------------------------------------------------------
Static Function sendDataCarol(oMark,cCodTec,lInvite)

Local nX        := 1
Local nLimite   := 1
Local cAlias    := ''
Local aData     := {}
Local aAux      := {}
Local aDtReturn := {}

Default lInvite    := .F.
Default oMark      := Nil
/* 
Array com dados do processamento
Posições:
 1-Array com erros
 2-Contador de registros que serão processados (numérico)
 3-Contador de registros que tiveram problemas no envio
*/

Default cCodTec := ""

If !Empty(cCodTec)
    aAux := qryBrw(,cCodTec,lInvite)
    If Len(aAux) > 0
        cAlias := aAux[2]
        aAdd(aData,{(cAlias)->RA_BITMAP,(cAlias)->RA_CIC,(cAlias)->AA1_CODTEC,(cAlias)->AA1_FILIAL,(cAlias)->AA1_EMAIL}) 
        TecFtCarol(aData,@aDtReturn,lInvite)
    Else
        Help(" ",1,STR0005, ,STR0019, 3, 1 )//"Integração Carol"#//"O atendente não tem fotos para exportar.""O atendente não tem fotos para exportar."
    EndIf
Else
    cAlias := oMark:Alias()
    aAdd(aDtReturn,{{},0})
    oMark:GoBottom(.F.)
    nLimite := oMark:At()
    oMark:GoTop()
    aDtReturn[1][2] := nLimite

    For nX := 1 to nLimite
        If oMark:isMark()
            aAdd(aData,{(cAlias)->RA_BITMAP,(cAlias)->RA_CIC,(cAlias)->AA1_CODTEC,(cAlias)->AA1_FILIAL,(cAlias)->AA1_EMAIL}) 
        EndIf
        oMark:GoDown()
    Next nX

    oMark:GoTop()
    If Len(aData) > 0
        TecFtCarol(aData,@aDtReturn, lInvite)
    Else
        Help(" ",1,STR0005, , STR0020, 3, 1 ) //"Integração Carol"#"Não foram selecionados registros para serem processados. Tente novamente."
    EndIf
EndIf

Return

Function tecInvUsers(lUnic,cCod)

Default lUnic   := .F.
Default cCod    := ""

    If ValType(lUnic) == 'L' .AND. lUnic
        attToCarol(lUnic,cCod,.T.)
    Else
        attToCarol(.F.,,.T.)
    EndIf
Return 

Function gsIntCarol()
    Local oCarol := FwCarolWizard():new()

    oCarol:Activate()
Return
