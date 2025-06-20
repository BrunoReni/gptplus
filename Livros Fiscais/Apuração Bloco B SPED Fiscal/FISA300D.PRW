#Include "FISA300D.ch"
#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA300D()

Esta rotina tem objetivo de realizar o cadastro das informa��es da sociedade
Uniprofissionais, para tratar o ISS fixo.

@author Erick G. Dias
@since 11/06/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function FISA300D()

Local   oBrowse := Nil

//Verifico se a tabela existe antes de prosseguir
IF AliasIndic('F1S')
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F1S")
    oBrowse:SetDescription(STR0001) //"Cadastro da Sociedade Uniprofissional"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) //"Dicion�rio desatualizado, favor verificar atualiza��es da apura��o de ISS referente ao Bloco B da EFD ICMS/IPI."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao respons�vel por gerar o menu.

@author Erick G Dias
@since 11/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA300D" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Fun��o que criar� o modelo da rotina de cadastro

@author Erick G Dias
@since 11/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Cria��o do objeto do modelo de dados
Local oModel := Nil

//Estrutura da tabela F1S
Local oUniprofissional := FWFormStruct(1, "F1S" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA300D',/*Pre-Validacao*/,{|oModel|VALIDACAO(oModel) })

//N�o permite alterar o CPF e data inicial de habilita��o
oUniprofissional:SetProperty('F1S_CPF'    , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })
oUniprofissional:SetProperty('F1S_INIHAB' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })

//Atribuindo cabe�alho para o modelo
oModel:AddFields("FISA300D",,oUniprofissional)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o que monta a view da rotina.

@author Erick G Dias
@since 11/06/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Cria��o do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA300D" )

//Cria��o da estrutura de dados utilizada na interface do cadastro
Local oUniprofissional := FWFormStruct(2, "F1S")
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Retiro o ID da view
oUniprofissional:RemoveField('F1S_ID')

//Atribuindo formul�rios para interface
oView:AddField( 'VIEW_ABA' , oUniprofissional , 'FISA300D' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} VldVigencia
Fun��o que realiza a valida��o de vig�ncia do s�cio.

@author Erick G Dias
@since 02/07/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function VldVigencia(cCPF, dDtIni, dDtFim, lEdit)

Local lRet      := .F.
Local cSelect	:= ""
Local cFrom	    := ""
Local cWhere	:= ""
Local cAliasQry	:= ""

//Query filtrando o CPF
cSelect := "F1S.F1S_CPF"
cFrom   += RetSQLName("F1S") + " F1S "
cWhere  += "F1S.F1S_FILIAL = " + ValToSQL(xFilial("F1S")) + " AND "
cWhere  += "F1S.F1S_CPF = " + ValToSQL(cCPF) + " AND "

cWhere  += "( "

//Verifica se est� compreendido em cadastro somente com data inicial preenchida
cWhere  += "( " + ValToSQL(dDtIni) + " >= F1S.F1S_INIHAB  AND F1S.F1S_FIMHAB = ' ' ) OR"
//Verifica se a data inicial est� compreenchida em algum cadastro como data inicial e final informados
cWhere  += "( " + ValToSQL(dDtIni) + " >= F1S.F1S_INIHAB  AND " + ValToSQL(dDtIni) + " <= F1S.F1S_FIMHAB ) "

//Tratamento para data final
IF Empty(dDtFim)
    //Se no cadastro n�o foi informado a data final, ent�o verificar� se j� existe no cadastro alguma linha sem data final preenchida
    cWhere  += " OR ( F1S.F1S_FIMHAB = ' ' ) "
ElseIf !Empty(dDtFim)
    //Caso a data final seja informada ent�o verificaremos se est�comprendida em algum cadastro com data inicial e final preenchidos.
    cWhere  += " OR ( " + ValToSQL(dDtFim) + " >= F1S.F1S_INIHAB  AND " + ValToSQL(dDtFim) + " <= F1S.F1S_FIMHAB ) "
    cWhere  += " OR ( " + ValToSQL(dDtFim) + " >= F1S.F1S_INIHAB  AND F1S.F1S_FIMHAB = ' ') "
EndIF

cWhere  += " ) AND " 

If lEdit
    //Se for edi��o desconsiderarei a linha editada, para n�o entrar em conflito com ela mesma
    cWhere  += " F1S.R_E_C_N_O_ <> " + ValtoSql(F1S->(recno())) + " AND "
EndIF

cWhere  += "F1S.D_E_L_E_T_ = ' '"		
cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + "%"

cAliasQry := GetNextAlias()

BeginSQL Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%

EndSQL

IF !(cAliasQry)->(Eof())
    //j� existe regra cadastrada para esta vig�ncia
    lRet    := .T.
EndIF

dbSelectArea(cAliasQry)
dbCloseArea()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VALIDACAO
Valida��o do modelo

@author Erick G Dias
@since 02/07/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function VALIDACAO(oModel)

Local lRet          := .T.
Local cCpf          := oModel:GetValue ('FISA300D',"F1S_CPF" )
Local dDtIni        := oModel:GetValue ('FISA300D',"F1S_INIHAB" )
Local dDtFim        := oModel:GetValue ('FISA300D',"F1S_FIMHAB" )
Local nOperation    := oModel:GetOperation()

//Verifica se o CPF j� est� cadastrado com mesma data de vig�ncia
IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

    If VldVigencia(cCPF, dDtIni, dDtFim, nOperation == MODEL_OPERATION_UPDATE)
        lRet:= .F.
        Help( ,, 'Help',, STR0003 , 1, 0 ) //"CPF j� cadastrado para vig�ncia informada"
    EndIF

EndiF

Return lRet
 