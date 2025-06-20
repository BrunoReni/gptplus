#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include "report.ch"
#Include 'TOTVS.ch'

Static adentes1e := {"18","17","16","15","14","13","12","11"}
Static adentes2e := {"55","54","53","52","51"}
Static adentes3e := {"85","84","83","82","81"}
Static adentes4e := {"48","47","46","45","44","43","42","41"}

Static adentes1d := {"21","22","23","24","25","26","27","28"}
Static adentes2d := {"61","62","63","64","65"}
Static adentes3d := {"71","72","73","74","75"}
Static adentes4d := {"31","32","33","34","35","36","37","38"}

Static lExisteBEC := .F.

function PLSO()

Local aCoors := FWGetDialogSize( oMainWnd )
Local oFWLayer	:= NIL
Local oDialog		:= NIL
Local nI := 0
Local aPanelUp2 := array(16)
Local aPanelUp3 := array(16)
Local aPanelUp4 := array(16)
Local aPanelUp5 := array(16)
Local aPanelDown := array(5)
Local oModelBEC := Nil //FWLoadModel( 'PLSO' )
Local aDados := {}
Local cObservacao := ''
Local cSCDP := ''
Local cATM  := ''

//BEC->(dbGoto(1)) //Teste somente
oModelBEC := FWLoadModel( 'PLSO' )
//oModelBEC:setOperation(2)
oModelBEC:Activate()

cObservacao := oModelBEC:getModel('MasterBEC'):getValue("BEC_OBSERV")

cSCDP := oModelBEC:getModel('MasterBEC'):getValue("BEC_SIDOPE")
if cSCDP == '0'
    cSCDP := 'N�o'
elseif cSCDP == '1'
    cSCDP := 'Sim'
elseIf empty(cSCDP)
    cSCDP := 'N�o Informado'
endif

cATM  := oModelBEC:getModel('MasterBEC'):getValue("BEC_ALTEMO")
if cATM == '0'
    cATM := 'N�o'
elseif cATM == '1'
    cATM := 'Sim'
elseIf empty(cATM)
    cATM := 'N�o Informado'
endif

aDados := PLSODADOS(1, @oModelBEC:getModel('MasterBEC'))

DEFINE MsDialog oDialog Title 'Situa��o inicial' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

// Cria o conteiner onde ser�o colocados os browses
oFWLayer := FWLayer():New()
oFWLayer:Init( oDialog, .F., .T. )

// Define Painel Superior
oFWLayer:AddLine( 'UP1', 10, .F. )

oFWLayer:AddLine( 'UP2', 10, .F. )

For nI := 1 To 16
    oFWLayer:AddCollumn( 'LUP2' + StrZero(nI,2), 100/16, .T., 'UP2' )
    aPanelUp2[nI] := oFWLayer:GetColPanel( 'LUP2' + StrZero(nI,2), 'UP2' )
Next

For nI := 1 TO 16
    addCoisa(@aPanelUp2[nI], aDados[1][nI][1], 1, aDados[1][nI][2])
Next

oFWLayer:AddLine( 'UP3', 10, .F. )

For nI := 1 To 16
    oFWLayer:AddCollumn( 'LUP3' + StrZero(nI,2), 100/16, .T., 'UP3' )
    aPanelUp3[nI] := oFWLayer:GetColPanel( 'LUP3' + StrZero(nI,2), 'UP3' )
Next

For nI := 4 TO 13
    addCoisa(@aPanelUp3[nI], aDados[2][nI-3][1], 1, aDados[2][nI-3][2])
Next

oFWLayer:AddLine( 'UP4', 10, .F. )

For nI := 1 To 16
    oFWLayer:AddCollumn( 'LUP4' + StrZero(nI,2), 100/16, .T., 'UP4' )
    aPanelUp4[nI] := oFWLayer:GetColPanel( 'LUP4' + StrZero(nI,2), 'UP4' )
Next

For nI := 4 TO 13
    addCoisa(@aPanelUp4[nI], aDados[3][nI-3][1], 1, aDados[3][nI-3][2])
Next

oFWLayer:AddLine( 'UP5', 10, .F. )

For nI := 1 To 16
    oFWLayer:AddCollumn( 'LUP5' + StrZero(nI,2), 100/16, .T., 'UP5' )
    aPanelUp5[nI] := oFWLayer:GetColPanel( 'LUP5' + StrZero(nI,2), 'UP5' )
Next

For nI := 1 TO 16
    addCoisa(@aPanelUp5[nI], aDados[4][nI][1], 1, aDados[4][nI][2])
Next

oFWLayer:AddLine( 'UP6', 10, .F. )

// Painel Inferior
oFWLayer:AddLine( 'DOWN', 35, .F. )

For nI := 1 To 5
    oFWLayer:AddCollumn( 'DOWN' + StrZero(nI,2), 20, .T., 'DOWN' )
    aPanelDown[nI] := oFWLayer:GetColPanel( 'DOWN' + StrZero(nI,2), 'DOWN' )
Next

For nI := 2 to 4
    if nI == 4
        addCoisa(@aPanelDown[nI], "Observa��o:", 2, , , , , cObservacao)
    elseif nI == 3
        @ 1 ,2    SAY "Sinais Cl�nicos de doen�a Periodontal?" Of @aPanelDown[nI] PIXEL SIZE 100 ,30 COLOR CLR_BLUE
        @ 12 ,2   SAY cSCDP Of @aPanelDown[nI] PIXEL SIZE 36 ,13 COLOR CLR_BLUE
        @ 31 ,2   SAY "Altera��o dos tecidos moles?" Of @aPanelDown[nI] PIXEL SIZE 100 ,30 COLOR CLR_BLUE
        @ 43 ,2   SAY cATM Of @aPanelDown[nI] PIXEL SIZE 36 ,13 COLOR CLR_BLUE
    elseif nI == 2
        @ 1 ,2   SAY "Legenda" Of @aPanelDown[nI] PIXEL SIZE 100 ,13 COLOR CLR_BLUE    

        @ 12, 2 BITMAP oBmp RESNAME "ENABLE"                 oF @aPanelDown[nI] SIZE 10, 30 NOBORDER WHEN .F. PIXEL
        @ 12 ,20   SAY "Dente Possui eventos informados"     Of @aPanelDown[nI] PIXEL SIZE 100 ,13 COLOR CLR_BLUE
        @ 22, 2 BITMAP oBmp RESNAME "DISABLE"                oF @aPanelDown[nI] SIZE 10, 30 NOBORDER WHEN .F. PIXEL
        @ 22 ,20   SAY "Dente N�o possui eventos informados" Of @aPanelDown[nI] PIXEL SIZE 100 ,13 COLOR CLR_BLUE

        @ 32 ,2   SAY "A - Ausente"               Of @aPanelDown[nI] PIXEL SIZE 100 ,13 COLOR CLR_BLUE    
        @ 42 ,2   SAY "E - Extra��o indicada"     Of @aPanelDown[nI] PIXEL SIZE 100 ,13 COLOR CLR_BLUE    
        @ 52 ,2   SAY "H - H�gido"                Of @aPanelDown[nI] PIXEL SIZE 100 ,13 COLOR CLR_BLUE    
        @ 62 ,2   SAY "C - Cariado"               Of @aPanelDown[nI] PIXEL SIZE 100 ,13 COLOR CLR_BLUE    
        @ 72 ,2   SAY "R - Restaurado"            Of @aPanelDown[nI] PIXEL SIZE 100 ,13 COLOR CLR_BLUE    
        @ 82 ,2   SAY "Em branco - N�o informado" Of @aPanelDown[nI] PIXEL SIZE 100 ,13 COLOR CLR_BLUE    
    endif
next

Activate MsDialog oDialog Center

return

/*
nTipo:
0 - teste
1 - Bot�o com legenda
2 - Memo
*/
Static function addCoisa(oPanel, cLabel, nTipo, cTxtBotao, cFormula, lEnable, lBD6, cTxtMemo)
Local cHoover := ""

Default cLabel := 'X'
Default nTipo := 1
Default cTxtBotao := ""
Default cFormula := 'PLSO3(cLabel)' //'PLShowFace("BD6")'
Default lEnable := .F.
Default lBD6 := .T.
Default cTxtMemo := ''

if !lEnable .AND. lBD6
    lEnable := PLSOEVE(cLabel, .T.)
endif

if nTipo == 0
    @ 1, 1 Button cLabel Size 36, 13 Message 'teste' Pixel Action MsgInfo("dente " + cLabel) of oPanel 
    DEFINE SBUTTON FROM 15, 5 TYPE 24 ACTION (oPanel:End()) ENABLE OF oPanel
elseif nTipo == 1
    @ 1, 2 BITMAP oBmp RESNAME IIF(lEnable,"ENABLE","DISABLE") oF oPanel SIZE 10, 30 NOBORDER WHEN .F. PIXEL
    @ 1 ,20   SAY cLabel Of oPanel PIXEL SIZE 36 ,13 COLOR CLR_BLUE
    if lEnable
        cHoover := "Clique para ver os procedimentos informados para o dente"
    else
        cHoover := "N�o foram informados procedimentos para o dente"
    endif
    @ 12, 5 Button cTxtBotao Size 36, 13 Message cHoover Pixel Action &(cFormula) of oPanel 
elseif ntipo == 2
    oMemo := Nil
    @ 1 ,2   SAY cLabel Of oPanel PIXEL SIZE 36 ,13 COLOR CLR_BLUE
    @ 12,2 Get oMemo VAR cTxtMemo Memo SIZE 130,083 OF oPanel PIXEL NO BORDER READONLY
endif

return


Static function Menudef()
Local aRotina := {}

Add Option aRotina Title 'Visualizar' Action 'VIEWDEF.PLSO' Operation 2 Access 0
Add Option aRotina Title 'Incluir'    Action 'VIEWDEF.PLSO' Operation 3 Access 0
Add Option aRotina Title 'Alterar'    Action 'VIEWDEF.PLSO' Operation 4 Access 0
Add Option aRotina Title 'Excluir'    Action 'VIEWDEF.PLSO' Operation 5 Access 0
Add Option aRotina Title 'Visualizar Ex' Action 'PLSO()' Operation 2 Access 0

return aRotina


Static function ModelDef()
Local oModel 
Local oStrBEC:= FWFormStruct(1,'BEC')

oModel := MPFormModel():New( 'PLSO', ,  )		//Cria a estrutura do Modelo de dados e Define e a fun��o que ir� Validar no "OK"
oModel:addFields('MasterBEC',/*cOwner*/,oStrBEC)								//Adiciona ao modelo um componente de formul�rio
oModel:getModel('MasterBEC')
oModel:SetDescription('Situacao Inicial')												// Adiciona a descri��o do Modelo de Dados

oModel:SetPrimaryKey( {"BEC_FILIAL", "BEC_SEQUEN"} )

Return oModel


Static function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrBEC:= FWFormStruct(2, 'BEC', )

oView := FWFormView():New()										// Cria o objeto de View
oView:SetModel(oModel)											// Define qual Modelo de dados ser� utilizado
oView:AddField('FrmBEC' , oStrBEC,'MasterBEC' ) 				// Adiciona no nosso View um controle do tipo formul�rio (antiga Enchoice)
oView:CreateHorizontalBox( 'BxBEC', 100)						// Cria o Box que ir� conter a View
oView:SetOwnerView('FrmBEC','BxBEC')							// Associa a View ao Box

Return oView

Function PLSO2()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:setMainProc("PLSO")
oBrowse:setMenuDef("PLSO")
oBrowse:SetAlias('BEC')
oBrowse:SetDescription('Situa��o inicial')
oBrowse:Activate()

Return Nil

//Fun��o auxiliar para grava��o dos campos dos dentes (serve pra todos campos, mas os dos dentes s�o o melhor uso que 52 set/load value viram um for com 3 linhas)
function PLSOGRV(oObjeto, cCampo, cValor, nDente, lLoad)
Local lRet := .F.
Local ccmpgrv := ""

Default cCampo := ""
Default nDente := 0
Default lLoad := .F.

if empty(cCampo)
    ccmpgrv := "BEC_DENT" + allTrim(Str(nDente))
else
    ccmpgrv := cCampo
endif

if lLoad
    oObjeto:getModel("MasterBEC"):LoadValue(ccmpgrv, cValor)
    lRet := .T.
else
    lRet := oObjeto:getModel("MasterBEC"):setValue(ccmpgrv, cValor)
endif

return lRet

//Fun��o para valida��o e/ou posicionamento da tabela da situa��o inicial
function PLSOVLD(nTipo, cDado, lTela, cMsg, lrestArea)
// - fun��es de valida��o pra uso geral (com retorno com mensagem em tela e sem mensagem em tela)
// -- Valida��es:
//nTipo:
// 0 -- Exist�ncia do anexo (cDado = Sequencial da tabela BEC)
// 1 -- Exist�ncia do anexo (cDado = n�mero do anexo operadora)
// 2 -- Exist�ncia de anexo vinculado � guia (cDado = RDA + guia do prestador)
// 3 -- Exist�ncia de anexo vinculado � guia (cDado = n�mero guia na operadora)
Local lRet := .F.
Local aArea:= {}

Default lTela := .F.
Default cMsg := ""
Default lrestArea := .F.

if nTipo == 0
    if lrestArea
        aArea := BEC->(getarea())
    endif
    
    BEC->(dbsetOrder(1))
    lRet := BEC->(MsSeek(xfilial("BEC") + cDado))
    
    if !lRet
        if empty(cMsg)
            cMsg := "Anexo n�o encontrado"
        endif
        if lTela
            MsgAlert(cMsg)
        endif
    endif

    if lrestArea
        restarea(aarea)
    endif
elseif nTipo == 1
    if lrestArea
        aArea := BEC->(getarea())
    endif
    
    BEC->(dbsetOrder(3))
    lRet := BEC->(MsSeek(xfilial("BEC") + cDado))

    if !lRet
        if empty(cMsg)
            cMsg := "Anexo n�o encontrado"
        endif
        if lTela
            MsgAlert(cMsg)
        endif
    endif

    if lrestArea
        restarea(aarea)
    endif
elseif nTipo == 2
    if lrestArea
        aArea := BEC->(getarea())
    endif
    
    BEC->(dbsetOrder(2))
    lRet := BEC->(MsSeek(xfilial("BEC") + cDado))

    if !lRet
        if empty(cMsg)
            cMsg := "N�o h� anexo vinculado � chave informada"
        endif
        if lTela
            MsgAlert(cMsg)
        endif
    endif

    if lrestArea
        restarea(aarea)
    endif
elseif ntipo == 3
    if lrestArea
        aArea := BEC->(getarea())
    endif
    
    BEC->(dbsetOrder(4))
    lRet := BEC->(MsSeek(xfilial("BEC") + cDado))

    if !lRet
        if empty(cMsg)
            cMsg := "N�o h� anexo vinculado � chave informada"
        endif
        if lTela
            MsgAlert(cMsg)
        endif
    endif

    if lrestArea
        restarea(aarea)
    endif
endif

return lRet

//fun��o auxiliar para recupera��o dos dados referentes aos dentes, retorna um array em um dos 3 formatos pr� definidos
function PLSODADOS(nTipo, oObjeto)
Local aRet := {}
Local aRetAux := {}

//Formatos:
// - Array �nico
// - Array separado 'por linha'
// - array separado 'por linha e lado'
if nTipo == 0

    PLSOMNARR(@aRet,adentes1e,oObjeto)
    PLSOMNARR(@aRet,adentes1d,oObjeto)
    PLSOMNARR(@aRet,adentes2e,oObjeto)
    PLSOMNARR(@aRet,adentes2d,oObjeto)
    PLSOMNARR(@aRet,adentes3e,oObjeto)
    PLSOMNARR(@aRet,adentes3d,oObjeto)
    PLSOMNARR(@aRet,adentes4e,oObjeto)
    PLSOMNARR(@aRet,adentes4d,oObjeto)

elseif ntipo == 1

    PLSOMNARR(@aRetAux,adentes1e,oObjeto)
    PLSOMNARR(@aRetAux,adentes1d,oObjeto)
    aadd(aRet, aclone(aRetAux))
    aRetAux := {}

    PLSOMNARR(@aRetAux,adentes2e,oObjeto)
    PLSOMNARR(@aRetAux,adentes2d,oObjeto)
    aadd(aRet, aclone(aRetAux))
    aRetAux := {}

    PLSOMNARR(@aRetAux,adentes3e,oObjeto)
    PLSOMNARR(@aRetAux,adentes3d,oObjeto)
    aadd(aRet, aclone(aRetAux))
    aRetAux := {}

    PLSOMNARR(@aRetAux,adentes4e,oObjeto)
    PLSOMNARR(@aRetAux,adentes4d,oObjeto)
    aadd(aRet, aclone(aRetAux))
    aRetAux := {}

elseif ntipo == 2

    PLSOMNARR(@aRetAux,adentes1e,oObjeto)
    aadd(aRet, aclone(aRetAux))
    aRetAux := {}

    PLSOMNARR(@aRetAux,adentes1d,oObjeto)
    aadd(aRet, aclone(aRetAux))
    aRetAux := {}

    PLSOMNARR(@aRetAux,adentes2e,oObjeto)
    aadd(aRet, aclone(aRetAux))
    aRetAux := {}

    PLSOMNARR(@aRetAux,adentes2d,oObjeto)
    aadd(aRet, aclone(aRetAux))
    aRetAux := {}

    PLSOMNARR(@aRetAux,adentes3e,oObjeto)
    aadd(aRet, aclone(aRetAux))
    aRetAux := {}

    PLSOMNARR(@aRetAux,adentes3d,oObjeto)
    aadd(aRet, aclone(aRetAux))
    aRetAux := {}

    PLSOMNARR(@aRetAux,adentes4e,oObjeto)
    aadd(aRet, aclone(aRetAux))
    aRetAux := {}

    PLSOMNARR(@aRetAux,adentes4d,oObjeto)
    aadd(aRet, aclone(aRetAux))
    aRetAux := {}

endif

return aRet

//fun��o que busca os dados dos eventos vinculados ao dente no proc contas
Static function PLSOEVE(cDente, lFechaArea)
Local cSql := ""
Local lRet := .F.

Default lFechaArea := .T.

//BD5->(dbgoTo(32579)) //Teste somente

cSql += " Select BD6_CODPAD, BD6_CODPRO, BD6_FADENT, BD6_DATPRO From " + RetSqlName('BD6')
cSql += " Where "
cSql += " BD6_FILIAL = '" + xfilial('BD6') + "' AND "
cSql += " BD6_CODOPE = '" + BD5->BD5_CODOPE + "' AND "
cSql += " BD6_CODLDP = '" + BD5->BD5_CODLDP + "' AND "
cSql += " BD6_CODPEG = '" + BD5->BD5_CODPEG + "' AND "
cSql += " BD6_NUMERO = '" + BD5->BD5_NUMERO + "' AND "
cSql += " BD6_DENREG = '" + cDente + "' AND "
cSql += " D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSOEVE",.f.,.t.)

lRet := !(PLSOEVE->(EoF()))

if lFechaArea
    PLSOEVE->(dbcloseArea())
endif

return lRet

//Fecha �rea
Static function PLSOEVEF()
    PLSOEVE->(dbcloseArea())
return

//tela de exibi��o dos eventos do dente
Function PLSO3(cDente)

Local aCoors := FWGetDialogSize( oMainWnd )
Local oPanelUp	:= NIL
Local oFWLayer	:= NIL
Local oPanelDown	:= NIL
Local oBrowseUp		:= NIL
Local oBrowseDown	:= NIL
Local oRelac		:= NIL
Local oDialog		:= NIL
Local aColumns := {}

PLSOEVE(cDente, .F.)

//BD6_CODPAD, BD6_CODPRO, BD6_FADENT

aColumns := {}
Aadd( aColumns, { TitSX3("BD6_CODPAD")[1]	,"BD6_CODPAD"	,"C",TAMSX3("BD6_CODPAD")[1],TAMSX3("BD6_CODPAD")[2]	,GetSx3Cache( "BD6_CODPAD" , "X3_PICTURE" ) })
Aadd( aColumns, { TitSX3("BD6_CODPRO")[1]	,"BD6_CODPRO"	,"C",TAMSX3("BD6_CODPRO")[1],TAMSX3("BD6_CODPRO")[2]	,GetSx3Cache( "BD6_CODPRO" , "X3_PICTURE" ) })
Aadd( aColumns, { TitSX3("BD6_FADENT")[1]	,"BD6_FADENT"	,"C",TAMSX3("BD6_FADENT")[1],TAMSX3("BD6_FADENT")[2]	,GetSx3Cache( "BD6_FADENT" , "X3_PICTURE" ) })
//Aadd( aColumns, { TitSX3("BD6_DATPRO")[1]	,"BD6_DATPRO"	,"D",TAMSX3("BD6_DATPRO")[1],TAMSX3("BD6_DATPRO")[2]	,GetSx3Cache( "BD6_DATPRO" , "X3_PICTURE" ) })

DEFINE MsDialog oDialog Title 'Procedimentos relacionados ao dente' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

// Cria o conteiner onde ser�o colocados os browses
oFWLayer := FWLayer():New()
oFWLayer:Init( oDialog, .F., .T. )

// Define Painel Superior
oFWLayer:AddLine( 'UP', 70, .F. )
oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )

// FWmBrowse Superior Candidatos
oBrowseUp:= FWmBrowse():New()
// Aqui se associa o browse ao componente de tela
oBrowseUp:SetOwner( oPanelUp )
oBrowseUp:SetDescription( "Procedimentos" )
oBrowseUp:SetAlias( "PLSOEVE" )
oBrowseUp:setfields(aColumns)
// Define de onde virao os botoes deste browse
oBrowseUp:SetMenuDef( '' )
oBrowseUp:SetProfileID( '1' )
oBrowseUp:ForceQuitButton()
oBrowseUp:DisableDetails()
oBrowseUp:Activate()

Activate MsDialog oDialog Center

PLSOEVEF()

Return

static function PLSOMNARR(aRet,aDentes, oObjeto)
Local nI := 0
    For nI := 1 To len(adentes)
        aadd(aRet, {adentes[nI], oObjeto:getValue("BEC_DENT" + adentes[nI])})
    next
return

//Grava anexo Situa��o Inicial
/*
Formato esperado do array:
[1] - n�mero do anexo no prestador
[2] - n�mero da guia principal (guia � qual o anexo est� vinculado)
[3] - n�mero do anexo na operadora (pode vir em branco)
[4] - Array dos dentes - formato { {[c�digo do dente (num�rico)],[c�digo da situa��o (caractere)]}, ... } 
[5] - informa��o sobre o campo 9 - sinais cl�nicos de doen�a periodontal
[6] - informa��o sobre o campo 10 - altera��o de tecidos moles
[7] - Observa��o
[8] - C�digo da RDA
[9] - n�mero da guia principal na operadora (guia � qual o anexo est� vinculado, mas o n�mero gerado pelo protheus) (pode vir em branco)
[10] - numero lote tiss online
lTela - indica se vai exibir caso d� erro na valida��o do Model

cMsg - Passar por par�metro, vai ser gravado mensagens �teis dependendo do que acontecer

Retorno: .T. deu certo, .F. F
*/
Function GrvAneSIni(aSituIni, lTela, cMsg)
Local lRet := .F.
Local oModel := nil
Local nI := 0
Local cSequen := ""
Local lGo := .T.

Default aSituIni := {}
Default lTela := .T.
Default cMsg := ""

verExisteBEC()

if !lExisteBEC
    cMsg := "Tabela BEC n�o existe no ambiente"
elseIf empty(aSituIni)
	cMsg := "Array de dados passado vazio"
else
    if PLSOVLD(2, aSituIni[8] + aSituIni[2], .F., nil, .F.)
        lGo := .F.
        cMsg := "Anexo j� existe para a guia informada"
        if lTela
            MsgAlert(cMsg)
        endif
    endif

    if lGo
        oModel := FWLoadModel( 'PLSO' )
        oModel:setOperation(3)
        oModel:activate()

        cSequen := GETSXENUM("BEC","BEC_SEQUEN")

        BEC->(dbsetorder(1))
        while BEC->(MsSeek(xFilial("BEC") + cSequen)) // para garantir que n�o vai gerar um sequencial de transa��o duplicado
            cSequen := GetSXeNum("BEC","BEC_SEQUEN")
            BEC->(confirmSX8())
        Enddo

        PLSOGRV(oModel , "BEC_SEQUEN", cSequen, , .T.)

        PLSOGRV(oModel , "BEC_GUIPRE", aSituIni[1], , .T.)
        PLSOGRV(oModel , "BEC_GUIPRI", aSituIni[2], , .T.)

        //N�o gravamos o n�mero do anexo na operadora, com o que foi informado, s� usamos pra busca, caso necess�rio
        //Grvando o mesmo que o sequen, mas pode ser alterado pra outro padr�o sem nenhum problema, pq o sequen que � a chave da tabela
        PLSOGRV(oModel , "BEC_GUIOPE", cSequen, , .T.)

        For nI := 1 to Len(aSituIni[4])
            PLSOGRV(oModel , , aSituIni[4][nI][2], aSituIni[4][nI][1], .T.)
        next

        PLSOGRV(oModel , "BEC_SIDOPE", aSituIni[5], , .T.)
        PLSOGRV(oModel , "BEC_ALTEMO", aSituIni[6], , .T.)
        PLSOGRV(oModel , "BEC_OBSERV", aSituIni[7], , .T.)
        PLSOGRV(oModel , "BEC_CODRDA", aSituIni[8], , .T.)
        if len(aSituIni) >= 10 .and. BEC->(fieldpos("BEC_LOTGUI")) > 0
            PLSOGRV(oModel , "BEC_LOTGUI", aSituIni[10], , .T.)
        endif

        PLSOGRV(oModel , "BEC_DATINC", dDataBase, , .T.)

        If (oModel:VldData() )
            // Se o dados foram validados faz-se a grava��o efetiva dos dados (commit)
            oModel:CommitData()
            lret := .T.
        else
            // Se os dados n�o foram validados obtemos a descri��o do erro para gerar LOG ou mensagem de aviso
            aErro := oModel:GetErrorMessage()
            // A estrutura do vetor com erro �:
            // [1] identificador (ID) do formul�rio de origem
            // [2] identificador (ID) do campo de origem
            // [3] identificador (ID) do formul�rio de erro
            // [4] identificador (ID) do campo de erro
            // [5] identificador (ID) do erro
            // [6] mensagem do erro
            // [7] mensagem da solu��o
            // [8] Valor atribu�do
            // [9] Valor anterior
            AutoGrLog( "Id do formul�rio de origem:" + ' [' + AllToChar( aErro[1] ) + ']' )
            AutoGrLog( "Id do campo de origem: " + ' [' + AllToChar( aErro[2] ) + ']' )
            AutoGrLog( "Id do formul�rio de erro: " + ' [' + AllToChar( aErro[3] ) + ']' )
            AutoGrLog( "Id do campo de erro: " + ' [' + AllToChar( aErro[4] ) + ']' )
            AutoGrLog( "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' )
            AutoGrLog( "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' )
            AutoGrLog( "Mensagem da solu��o: " + ' [' + AllToChar( aErro[7] ) + ']' )
            AutoGrLog( "Valor atribu�do: " + ' [' + AllToChar( aErro[8] ) + ']' )
            AutoGrLog( "Valor anterior: " + ' [' + AllToChar( aErro[9] ) + ']')

            cMsg := "erro na grava��o do Model no campo [ " + AllToChar( aErro[2] ) + " ]"

            if lTela
                MostraErro()
            endif

            lRet := .F.
        EndIf
    endif
endif

return lRet

//fun��o de exemplo, essa aqui pode ser usada no proc contas (ou outra tela com BD5 posicionado) para trazer a tela do anexo de situa��o inicial
function PLSO4()
//Desafio: Criar bot�o no proc contas que traga as informa��es do anexo usando informa��es dispon�veis e as fun��es criadas aqui
Local cGuia := ""
Local cRDA := ""

cRDa := BD5->BD5_CODRDA
cGuia := BD5->BD5_NUMIMP
if !empty(cGuia)
    //Posicionar BEC -> Essa etapa � necess�ria, se n�o achar anexo, n�o pode tentar abrir a tela pq vai dar erro.
    if PLSOVLD(2, cRDA + cGuia, .T., "N�o existe anexo de situa��o inicial para essa guia", .F.) //BEC->(dbgoTo(1))
        //O BD5 j� vai estar posicionado
        //Chamar a tela
        PLSO()
    endif
else
    MsgInfo('Guia de refer�ncia ao anexo n�o informada (Campo BD5_NUMIMP)')
endif

return

Static function verExisteBEC()

if !lExisteBEC
    lExisteBEC := FWAliasInDic("BEC")
endif

return lExisteBEC

/*
Pend�ncias:

fun��o com Query para eventos nas guias do atendimento (Usando BEA e BE2)
criar vis�o do dente com as faces com procedimentos marcadas na tela que lista os procedimentos

*/
