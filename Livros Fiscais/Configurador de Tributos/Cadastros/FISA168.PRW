#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA168.CH"
#Include "FWEditPanel.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA168()

Esta rotina tem objetivo de realizar cadastro dos tributos

Esta rotina estar� dispon�vel somente na vers�o 12.

@author joao.pellegrini
@since 11/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA168()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F2E")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F2E")
    oBrowse:SetDescription(STR0001) // Cadastro de Tributos
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) // Dicion�rio desatualizado, verifique as atualiza��es do motor tribut�rio fiscal.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Erick G Dias
@since 11/09/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA168" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo do cadastro de Unidade de Refer�ncia Fiscal

@author joao.pellegrini
@since 11/09/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai do cabe�alho da rotina
Local oCabecalho := FWFormStruct(1, "F2E" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA168')

//Atribuindo cabe�alho para o modelo
oModel:AddFields("FISA168",,oCabecalho)

//N�o permite alterar o conte�do do campo F2E_TRIB na edi��o
oCabecalho:SetProperty('F2E_TRIB' , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })

oModel:SetPrimaryKey( {"F2E_FILIAL","F2E_ID","F2E_TRIB"} )

//Adicionando descri��o ao modelo
oModel:SetDescription(STR0001) // Cadastro de Tributos

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta a view da rotina.

@author joao.pellegrini
@since 11/09/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA168" )

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "F2E")
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formul�rios para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho , 'FISA168' )

oCabecalho:AddGroup( 'GRUPO_TRIB' , STR0003 , '' , 2 )    //"Defini��o do Tributo"
oCabecalho:AddGroup( 'GRUPO_ID'   , STR0004 , '' , 2 )    //"Identificador - ID TOTVS"

//Campos que fazem parte do grupo do tributo
oCabecalho:SetProperty( 'F2E_TRIB'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_TRIB' )
oCabecalho:SetProperty( 'F2E_DESC'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_TRIB' )
oCabecalho:SetProperty( 'F2E_ESFERA'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_TRIB' )
oCabecalho:SetProperty( 'F2E_ESPECI'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_TRIB' )

oCabecalho:SetProperty( 'F2E_IDTRIB'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ID' )
oCabecalho:SetProperty( 'F2E_DIDTRB'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ID' )

//Retirando campo de ID da view.
oCabecalho:RemoveField( 'F2E_ID'  )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA168CARG

Fun��o respons�vel por efetuar a carga/atualiza��o dos ID's de
de/para dos tributos (tabela F2C).

@author joao.pellegrini
@since 23/07/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA168F2C() 

Local nX := 0
Local aTrib := {;
                    {'000001', STR0006},;//'INSS DO PRODUTOR RURAL - FUNRURAL'
                    {'000002', STR0007},;//'GILRAT - FUNRURAL'
                    {'000003', STR0008},;//'SENAR - SERVI�O NACIONAL DE APRENDIZAGEM RURAL'
                    {'000004', STR0009},;//'AFRMM - Adicional ao Frete para Renova��o da Marinha Mercante'
                    {'000005', STR0010},;//'FABOV - Fundo de Apoio a Bovinocultura de Corte'
                    {'000006', STR0011},;//'FACS - Fundo de Apoio � Cultura da Soja'
                    {'000007', STR0012},;//'FAMAD - Fundo de Apoio � Madeira'
                    {'000008', STR0013},;//'FASE/MT - Fundo Mato-Grossense de Apoio � Cultura da Semente'
                    {'000009', STR0014},;//'FETHAB - Fundo Estadual de Transporte e Habita��o'
                    {'000010', STR0015},;//'FUNDERSUL - Fundo de Desenvolvimento do Sistema Rodovi�rio do Estado de Mato Grosso do Sul'
                    {'000011', STR0016},;//'FUNDESA - Fundo de Desenvolvimento e Defesa Sanit�ria Animal'
                    {'000012', STR0017},;//'IMA/MT - Instituto Mato-Grossense do Algod�o'
                    {'000013', STR0018},;//'SEST/SENAT - Servi�o Social do Transporte/Servi�o Nacional de Aprendizagem do Transporte'
                    {'000014', STR0019},;//'TPDP - Taxa de Processamento de Despesa P�blica do Estado da Para�ba'
                    {'000015', STR0020},;//'PROGRAMA DE INTEGRA��O SOCIAL'
                    {'000016', STR0021},;//'CONTRIBUI��O PARA FINANCIAMENTO DA SEGURIDADE SOCIAL'
                    {'000017', STR0022},;//"IMPOSTO DE IMPORTA��O"
                    {'000018', STR0023},;//'IMPOSTO DE RENDA RETIDO NA FONTE'
                    {'000019', STR0024},;//'INSS'
                    {'000020', STR0025},;//'IMPOSTO SOBRE SERVI�O'
                    {'000021', STR0028},;//"ICMS - Imposto sobre Circula��o de Mercadorias e Servi�os"
                    {'000022', STR0029},;//"IPI - Imposto sobre Produtos Industrializados"
                    {'000023', STR0026},;//'CONTRIBUI��O DE INTERVEN��O NO DOM�NIO ECON�MICO'
                    {'000024', STR0031},;//"CONTRIBUI��O PREVIDENCI�RIA SOBRE A RECEITA BRUTA"
                    {'000025', STR0032},;//"FUNDO ESTADUAL DE EQUIL�BRIO FISCAL"
                    {'000026', STR0034},;//"CONTRIBUI��O SOCIAL SOBRE O LUCRO L�QUIDO"
                    {'000027', STR0035},;//"FUNDO DE PROTE��O SOCIAL DO ESTADO DE GOI�S"
                    {'000028', STR0036},;//"FUNDO MUNICIPAL DE FOMENTO � MICRO E PEQUENA EMPRESA"
                    {'000029', STR0037},;//"CR�DITO PRESUMIDO PARA ICMS"
                    {'000030', STR0038},;//"CREDITO PRESUMIDO SOBRE PRESTACAO SERVICO DE TRANSPORTE COM ICMS/ST"
                    {'000031', STR0039},;//"PRODEPE - PROGRAMA DE DESENVOLVIMENTO DO ESTADO DE PERNAMBUCO"
                    {'000032', STR0040},;//"CR�DITO PRESUMIDO PELA CARGA TRIBUT�RIA"
                    {'000033', STR0041},;//"APOSENTADORIA ESPECIAL 15 ANOS"
                    {'000034', STR0042},;//"APOSENTADORIA ESPECIAL 20 ANOS"
                    {'000035', STR0043},;//"APOSENTADORIA ESPECIAL 25 ANOS"
                    {'000036', STR0044},;//"INSS PATRONAL"
                    {'000037', STR0045},;//"DIFAL - DIFERENCIAL DE ALIQUOTA"
                    {'000038', STR0046},;//"ICMS COMPLEMENTAR"
                    {'000039', STR0047},;//"ANTECIPA��O DE ICMS"
                    {'000040', STR0048},;//"FECP ICMS - FUNDO DE COMBATE � POBREZA"
                    {'000041', STR0049},;//"FECP ICMS ST - FUNDO DE COMBATE � POBREZA"
                    {'000042', STR0050},;//"FECP ICMS COMPLEMENTAR- FUNDO DE COMBATE � POBREZA"
                    {'000043', STR0051},;//"COFINS RETEN��O - CONTRIBUI��O PARA FINANCIAMENTO DA SEGURIDADE SOCIAL"
                    {'000044', STR0052},;//"COFINS SUBSTITUI��O TRIBUTARIA - CONTRIBUI��O PARA FINANCIAMENTO DA SEGURIDADE SOCIAL"                    
                    {'000045', STR0053},;//"PIS RETEN��O - PROGRAMA DE INTEGRA��O SOCIAL"
                    {'000046', STR0054},;//"PIS SUBSTITUI��O TRIBUTARIA - PROGRAMA DE INTEGRA��O SOCIAL"
                    {'000047', STR0055},;//"ISS BITRIBUTADO - CPOM"
                    {'000048', STR0056},;//"MAJORA��O DAS AL�QUOTAS DO PIS/PASEP-IMPORTA��O"
                    {'000049', STR0057},;//"MAJORA��O DAS AL�QUOTAS DO COFINS-IMPORTA��O"
                    {'000050', STR0058},;//"DEDU��O ICMS / ISS"
                    {'000051', STR0059},;//"FRETE AUTONOMO"
                    {'000052', STR0060},;//"DESONERA��O DE ICMS POR ISEN��O DE IMPOSTO PARA ZONA FRANCA DE MANAUS"
                    {'000053', STR0061},;//"DESONERA��O DE PIS POR ISEN��O DE IMPOSTO PARA ZONA FRANCA DE MANAUS"
                    {'000054', STR0062},;//"DESONERA��O DE COFINS POR ISEN��O DE IMPOSTO PARA ZONA FRANCA DE MANAUS"                    
                    {'000055', STR0064},;//"ESTORNO DO CR�DITO E D�BITO NA APURA��O DE ICMS"
                    {'000056', STR0065},;//"ICMS SUBSTITUI��O TRIBUT�RIA"
                    {'000057', STR0066},;//"FRETE EMBARCADOR"
                    {'000058', STR0067},;//"CREDITO OUTORGADO"
                    {'000059', STR0068}; //"TRIBUTA��O MONOF�SICA DE COMBUST�VEIS COBRADA ANTERIORMENTE"
                }

dbSelectArea("F2C")
F2C->(dbSetOrder(1))

For nX := 1 to Len(aTrib)

    If !F2C->(MsSeek(xFilial('F2C') + aTrib[nX, 1]))

        RecLock("F2C", .T.)

        F2C->F2C_FILIAL := xFilial("F2C")
        F2C->F2C_CODIGO := aTrib[nX, 1]
        F2C->F2C_DESC  := aTrib[nX, 2] 

        F2C->(MsUnlock())

    EndIf

Next nX

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA168F2E

Fun��o respons�vel por efetuar a carga dos tributos tratados pelo "legado"
e atualizar os IDs dos tributos n�o preenchidos.

@author joao.pellegrini
@since 23/07/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA168F2E() 

//Posi��o 3 do array aTrib
//1=Federal;2=Estadual;3=Municipal
//Posi��o 4 do array aTrib
//1=Imposto;2=Contribui��o;3=Fundo;4=Taxa 

Local aTrib := {;
                {"FUNRUR", STR0007, "1", "3","000002"},;//'GILRAT - FUNRURAL'
                {"SENAR" , STR0008, "1", "1","000003"},;//'SENAR - SERVI�O NACIONAL DE APRENDIZAGEM RURAL'
                {"AFRMM" , STR0009, "1", "2","000004"},;//"AFRMM - Adicional ao Frete para Renova��o da Marinha Mercante"
                {"FABOV" , STR0010, "2", "3","000005"},;//"FABOV - Fundo de Apoio a Bovinocultura de Corte"
                {"FACS"  , STR0011, "2", "3","000006"},;//"FACS - Fundo de Apoio � Cultura da Soja"
                {"FAMAD" , STR0012, "2", "3","000007"},;//"FAMAD - Fundo de Apoio � Madeira"
                {"FASEMT", STR0013, "2", "3","000008"},;//"FASE/MT - Fundo Mato-Grossense de Apoio � Cultura da Semente"
                {"FETHAB", STR0014, "2", "3","000009"},;//"FETHAB - Fundo Estadual de Transporte e Habita��o"
                {"FUNDER", STR0015, "2", "3","000010"},;//"FUNDERSUL - Fundo de Desenvolvimento do Sistema Rodovi�rio do Estado de Mato Grosso do Sul"
                {"FUNDES", STR0016, "2", "3","000011"},;//"FUNDESA - Fundo de Desenvolvimento e Defesa Sanit�ria Animal"
                {"IMAMT" , STR0017, "2", "3","000012"},;//"IMA/MT - Instituto Maot-Grossense do Algod�o"                
                {"SEST"  , STR0018, "1", "2","000013"},;//"SEST/SENAT - Servi�o Social do Transporte/Servi�o Nacional de Aprendizagem do Transporte"
                {"TPDP"  , STR0019, "2", "4","000014"},;//"TPDP - Taxa de Processamento de Despesa P�blica do Estado da Para�ba"
                {"PIS"   , STR0020, "1", "2","000015"},;//"PROGRAMA DE INTEGRA��O SOCIAL"
                {"COF"   , STR0021, "1", "2","000016"},;//"CONTRIBUI��O PARA FINANCIAMENTO DA SEGURIDADE SOCIAL"
                {"II"    , STR0022, "1", "1","000017"},;//"IMPOSTO DE IMPORTA��O"
                {"IRF"    , STR0023, "1","1","000018"},;//"IMPOSTO DE RENDA RETIDO NA FONTE"
                {"INSS"  , STR0024, "1", "1","000019"},;//"INSS - INSTITUTO NACIONAL DO SEGURO SOCIAL"
                {"ISS"   , STR0025, "3", "1","000020"},;//"IMPOSTO SOBRE SERVI�O"
                {"ICMS"  , STR0028, "2", "1","000021"},;//"ICMS - Imposto sobre Circula��o de Mercadorias e Servi�os"
                {"IPI"   , STR0029, "1", "1","000022"},;//"IPI - Imposto sobre Produtos Industrializados"
                {"CIDE"  , STR0026, "1", "2","000023"},;//"CONTRIBUI��O DE INTERVEN��O NO DOM�NIO ECON�MICO"
                {"CPRB"  , STR0031, "1", "2","000024"},;//"CONTRIBUI��O PREVIDENCI�RIA SOBRE A RECEITA BRUTA"
                {"FEEF"  , STR0032, "2", "3","000025"},;//"FUNDO ESTADUAL DE EQUIL�BRIO FISCAL"
                {"CSL "  , STR0034, "1", "2","000026"},;//"CONTRIBUI��O SOCIAL SOBRE O LUCRO L�QUIDO"
                {"PROTEG", STR0035, "2", "3","000027"},;//"FUNDO DE PROTE��O SOCIAL DO ESTADO DE GOI�S"
                {"FUMIPQ", STR0036, "3", "3","000028"},;//"FUNDO MUNICIPAL DE FOMENTO � MICRO E PEQUENA EMPRESA"
                {"CRDPRE", STR0037, "2", "1","000029"},;//"CR�DITO PRESUMIDO PARA ICMS"
                {"CRPRST", STR0038, "2", "1","000030"},;//"CREDITO PRESUMIDO SOBRE PRESTACAO SERVICO DE TRANSPORTE COM ICMS/ST"
                {"CPPROD", STR0039, "2", "1","000031"},;//"PRODEPE - PROGRAMA DE DESENVOLVIMENTO DO ESTADO DE PERNAMBUCO"
                {"CRDPCT", STR0040, "2", "1","000032"},;//"CR�DITO PRESUMIDO PELA CARGA TRIBUT�RIA"
                {"SECP15", STR0041, "1", "2","000033"},;//"APOSENTADORIA ESPECIAL 15 ANOS"
                {"SECP20", STR0042, "1", "2","000034"},;//"APOSENTADORIA ESPECIAL 20 ANOS"
                {"SECP25", STR0043, "1", "2","000035"},;//"APOSENTADORIA ESPECIAL 25 ANOS"
                {"INSSPT", STR0044, "1", "2","000036"},;//"INSS PATRONAL"
                {"DIFAL" , STR0045, "2", "1","000037"},;//"DIFAL - DIFERENCIAL DE ALIQUOTA"
                {"CMP"   , STR0046, "2", "1","000038"},;//"ICMS COMPLEMENTAR"
                {"ANTEC" , STR0047, "2", "1","000039"},;//"ANTECIPA��O DE ICMS"
                {"FECPIC", STR0048, "2", "3","000040"},;//"FECP ICMS - FUNDO DE COMBATE � POBREZA"
                {"FCPST" , STR0049, "2", "3","000041"},;//"FECP ICMS ST - FUNDO DE COMBATE � POBREZA"
                {"FCPCMP", STR0050, "2", "3","000042"},;//"FECP ICMS COMPLEMENTAR- FUNDO DE COMBATE � POBREZA"
                {"COFRET", STR0051, "1", "2","000043"},;//"COFINS RETEN��O - CONTRIBUI��O PARA FINANCIAMENTO DA SEGURIDADE SOCIAL"
                {"COFST" , STR0052, "1", "2","000044"},;//"COFINS SUBSTITUI��O TRIBUTARIA - CONTRIBUI��O PARA FINANCIAMENTO DA SEGURIDADE SOCIAL"
                {"PISRET", STR0053, "1", "2","000045"},;//"PIS RETEN��O - PROGRAMA DE INTEGRA��O SOCIAL"
                {"PISST" , STR0054, "1", "2","000046"},;//"PIS SUBSTITUI��O TRIBUTARIA - PROGRAMA DE INTEGRA��O SOCIAL"
                {"ISSBI" , STR0055, "3", "1","000047"},;//"ISS BITRIBUTADO - CPOM"
                {"PISMAJ", STR0056, "1", "2","000048"},;//"MAJORA��O DAS AL�QUOTAS DO PIS/PASEP-IMPORTA��O"
                {"COFMAJ", STR0057, "1", "2","000049"},;//"MAJORA��O DAS AL�QUOTAS DO COFINS-IMPORTA��O"
                {"DED"   , STR0058, "2", "1","000050"},;//"DEDU��O ICMS / ISS"
                {"FRTAUT", STR0059, "2", "1","000051"},;//"FRETE AUTONOMO"
                {"DZFICM", STR0060, "2", "1","000052"},;//"DESONERA��O DE ICMS POR ISEN��O DE IMPOSTO PARA ZONA FRANCA DE MANAUS"
                {"DZFPIS", STR0061, "2", "1","000053"},;//"DESONERA��O DE PIS POR ISEN��O DE IMPOSTO PARA ZONA FRANCA DE MANAUS"
                {"DZFCOF", STR0062, "2", "1","000054"},;//"DESONERA��O DE COFINS POR ISEN��O DE IMPOSTO PARA ZONA FRANCA DE MANAUS"                
                {"ESTICM", STR0064, "2", "1","000055"},;//"ESTORNO DO CR�DITO E D�BITO NA APURA��O DE ICMS"
                {"ICMSST", STR0065, "2", "1","000056"},;//"ICMS SUBSTITUI��O TRIBUT�RIA"
                {"FRTEMB", STR0066, "2", "1","000057"},; //"FRETE EMBARCADOR"
                {"CRDOUT", STR0067, "2", "1","000058"},; //"CREDITO OUTORGADO"
                {'STMONO', STR0068, "2", "1","000059"}; //"TRIBUTA��O MONOF�SICA DE COMBUST�VEIS COBRADA ANTERIORMENTE"
                }

Local nX    := 0
Local cAlias:= ""

dbSelectArea("F2E")
F2E->(dbSetOrder(2))

For nX := 1 to Len(aTrib)

    If !F2E->(MsSeek(xFilial('F2E') + aTrib[nX, 1]))

        RecLock("F2E", .T.)

        F2E->F2E_FILIAL     := xFilial("F2E")
        F2E->F2E_ID         := FWUUID('F2E')
        F2E->F2E_TRIB       := aTrib[nX, 1]
        F2E->F2E_DESC       := aTrib[nX, 2]
        F2E->F2E_ESFERA     := aTrib[nX, 3]
        F2E->F2E_ESPECI    := aTrib[nX, 4]
        F2E->F2E_IDTRIB     := aTrib[nX, 5]

        F2E->(MsUnlock())
    ElseIf Empty(F2E_IDTRIB)
        RecLock("F2E", .F.)

        F2E->F2E_IDTRIB     := aTrib[nX, 5]
        
        F2E->(MsUnlock())
    EndIf

Next nX

//Atualizar os IDs que foram cadastrados e est�o em branco, porque o campo F2E_ID estava como n�o usado no dicion�rio
cAlias := PesqF2E()

DbSelectArea(cAlias)
F2E->(dbSetOrder(2))

//Caso n�o encontre finaliza o processo
If ((cAlias)->(Eof()))
    (cAlias)->(DbCloseArea())
    Return Nil
EndIf

//Percorrer os registros para inclus�o do ID
While (!(cAlias)->(Eof()))

    If F2E->(MsSeek(xFilial("F2E") + (cAlias)->F2E_TRIB))

        RecLock("F2E", .F.)
            F2E->F2E_ID := FWUUID('F2E')
        F2E->(MsUnlock())
    Endif
    (cAlias)->(dbSkip())
EndDo

//Fecha o alias da query
(cAlias)->(DbCloseArea())

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PesqF2E
Retorna registros da tabela F2E com F2E_ID branco

@author Renato Rezende
@since 09/04/2021
@version P12.1.33

/*/
//-------------------------------------------------------------------
Function PesqF2E() 
Local cAlias    := GetNextAlias()

//Retorna registros n�o encontrados em ambas as tabelas
BeginSql Alias cAlias

    SELECT
        F2E_TRIB
    FROM
        %Table:F2E% F2E
    WHERE 
        F2E.F2E_ID = ''
        AND	 F2E.%NotDel%
EndSql

Return cAlias
