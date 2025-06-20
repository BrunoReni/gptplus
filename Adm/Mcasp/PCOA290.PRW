#include "pcoa290.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"


/*/{Protheus.doc} PCOA290
Fun��o para cadastramento de codigo de aplica��o
@author  Totvs
@version 12.1.27
@since   02/09/2020
/*/
Function PCOA290()

Private oBrowse := BrowseDef()

A290Carga()  //Carga da tabela passado como modelo

// Ativa browser.
oBrowse:Activate()

Return


/*/{Protheus.doc} BrowseDef
Defini��o do MBrowse

@author  Totvs
@version 12.1.27
@since   02/09/2020
/*/
Static Function BrowseDef()

	Local oBrowse := FwMBrowse():New()

	oBrowse:SetAlias('AML')
	oBrowse:SetDescripton(STR0001)  // "Cadastro Codigo de Aplicacao"

Return oBrowse


/*/{Protheus.doc} MenuDef
Menu Cadastro Codigo de Aplicacao.

@author  Totvs
@version 12.1.27
@since   02/09/2020
/*/
Static Function MenuDef()
Return FWMVCMenu('PCOA290')  // Retorna as op�oes padroes de menu.



/*/{Protheus.doc} ModelDef
Modelo para cadastramento de Codigo de Aplica��o.

@author  Totvs
@version 12.1.27
@since   02/09/2020
/*/
Static Function ModelDef()

// Cria as estruturas a serem usadas no modelo de dados.
Local oStruct := FWFormStruct(1, 'AML')
Local oModel
Local bPosvld := {|x| A290VldPos(x) }
// Cria o objeto do modelo de dados.
oModel := MPFormModel():New('AMLModel', /*bPreValid*/, bPosvld/*bPosValid*/, /*bCommitPos*/, /*bCancel*/)
oModel:SetVldActivate({|oModel| ValidPre(oModel)})

// Adiciona a descri��o do modelo de dados.
oModel:SetDescription(STR0001)  //"Cadastro Codigo de Aplicacao"

// Adiciona ao modelo um componente de formulario.
oModel:AddFields('AMLMASTER', /*cOwner*/, oStruct, /*bPreValid*/, /*bPosValid*/, /*bLoad*/)
oModel:GetModel('AMLMASTER'):SetDescription(STR0001)  //"Cadastro Codigo de Aplicacao"

// Configura chave primaria.
oModel:SetPrimaryKey({"AML_FILIAL", "AML_CODFIX", "AML_CODVAR"})

// Retorna o Modelo de dados.
Return oModel


/*/{Protheus.doc} ViewDef
View para cadastramento de Codigo de Aplica��o.

@author  Totvs
@version 12.1.27
@since   02/09/2020
/*/
Static Function ViewDef()

// Cria um objeto de modelo de dados baseado no ModelDef do fonte informado.
Local oModel     := FWLoadModel('PCOA290')

// Cria as estruturas a serem usadas na View
Local oStruct    := FWFormStruct(2, 'AML')

// Cria o objeto de View
Local oView      := FWFormView():New()

// Define qual Modelo de dados sera utilizado
oView:SetModel(oModel)

// Define que a view sera fechada apos a gravacao dos dados no OK.
oView:bCloseOnOk := {|| .T.}

// Adiciona no nosso view um controle do tipo formulario (antiga enchoice).
oView:AddField('VIEW_AML', oStruct, 'AMLMASTER')

// Cria um "box" horizontal para receber cada elemento da view.
oView:CreateHorizontalBox('SUPERIOR', 100)

// Relaciona o identificador (ID) da view com o "box" para exibicao.
oView:SetOwnerView('VIEW_AML', 'SUPERIOR')

Return oView


/*/{Protheus.doc} ValidPre

@author  Totvs
@version 12.1.27
@since   02/09/2020
/*/
Static Function ValidPre(oModel)
Local lRet       := .T.
Local nOper      := oModel:getOperation()
Local cUser      := RetCodUsr()

If nOper != 1

	If nOper == 2 
		lRet := PCOAAMLUsr( 1, cUser, AML->AML_CODFIX+AML->AML_CODVAR )   //PRIMEIRO PARAMETRO 1 - SOMENTE VISUALIZAR

	ElseIf nOper == MODEL_OPERATION_UPDATE
		lRet := PCOAAMLUsr( 2, cUser, AML->AML_CODFIX+AML->AML_CODVAR )   //PRIMEIRO PARAMETRO 2 - PERMITE ALTERAR

	ElseIf nOper == MODEL_OPERATION_INSERT
		lRet := PCOAAMLUsr( 3, cUser, "" , .T. )           //PRIMEIRO PARAMETRO 3 - CONTROLE TOTAL

	ElseIf nOper == MODEL_OPERATION_DELETE
		lRet := PCOAAMLUsr( 3, cUser, AML->AML_CODFIX+AML->AML_CODVAR )   //PRIMEIRO PARAMETRO 3 - CONTROLE TOTAL

		If lRet
			lRet := PCOAAMLDEL()
		EndIf

	EndIf

EndIf

Return lRet

/*/{Protheus.doc} A290FixWhen
Somente Inclusao pode editar o campo Cod.Fixo / Gatilha codigo fixo de origem na copia

@author  Totvs
@version P12
@since   02/09/2020
/*/
Function A290FixWhen()
Local lRet := .T.
Local lCopia := .F.
Local oModel := FWModelActive()

	lCopia     := ( oModel:aControls[4] == 6 )  //qdo tiver metodo + apropriado mudar
	If lCopia
		oModel:LoadValue("AMLMASTER","AML_CODFIX", AML->AML_CODFIX )
		lRet := .F.
	Else
		lRet := Inclui
	EndIf

Return lRet

/*/{Protheus.doc} PCOAAMLUsr
Verifica os usuários que tem acesso para efetuar alteracoes referentes a��o do PPA

@author  Totvs
@version P12
@since   02/09/2020
/*/
Function PCOAAMLUsr(nOpcao, cUser, cChave, lVerSoDir)
Local lRet := .T.

Default lVerSoDir := .F.

	//nOpcao : 1 = Visualizar
	//         2 = Alterar
	//         3 = Controle Total
    //criar mais um parametro na funcao para ver somente direito no caso de inclusao (lVerSoDir) e neste caso a chave � em branco
	//PcoDirEnt_User(cEntidade, cChave, cUser, lMsgHelp, cPlano)
	lRet := PcoDirEnt_User("AML", cChave, cUser, .F., NIL, lVerSoDir ) >= nOpcao

	If !lRet  
		Help(,, 'NO_ACESSO_CODAPL',, STR0002, 1, 0)  // "Usuario sem acesso para manuten��o do cadastro de Codigo de Aplicacao."
	EndIf

Return ( lRet )



/*/{Protheus.doc} PCOAAMLDEL
Valida excluso de Codigo de Aplicacao.

@author  Totvs
@version P12
@since   02/09/2020
/*/
Static Function PCOAAMLDEL()

Local lRet       := .T.
Local aArea      := GetArea()
// Local cQuery     := ""
// Local cAliasTRB  := GetNextAlias()

lRet := (AML->AML_STATUS == '2')  //SOMENTE PODE EXCLUIR SE INATIVO
/*  
//ADEQUAR QUERY PARA VERIFICAR SE ACAO ESTA EM USO NO PPA
cQuery := "SELECT max(AMY_CODUNI) UNIORC "
cQuery += " FROM " + RetSqlName("AMY")
cQuery += " WHERE "
cQuery += " AMY_FILIAL  = '" + xFilial("AMY") + "' "
cQuery += " AND AMY_CODUNI = '" + XYZ->XYZ_CODIGO + "' "
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cAliasTRB, .T., .T. )

If (cAliasTRB)->(!Eof() .and. RTrim(UNIORC) <> '')
	lRet := .F.
EndIf
(cAliasTRB)->(dbCloseArea())

*/

If !lRet
	Help(,, 'NO_DEL_CODAPL',, STR0003, 1, 0)  // "C�digo de Aplica��o n�o pode ser excluida! "
EndIf

RestArea(aArea)

Return lRet

Static Function A290VldPos( oModel )
Local lRet := .T.

If Inclui
	lRet := ExistChav("AML", M->AML_CODFIX+M->AML_CODVAR)
EndIf

Return( lRet )


/*/{Protheus.doc} A290Carga
Carrega planilha modeloValida excluso de Codigo de Aplicacao.

@author  Totvs
@version P12
@since   02/09/2020
/*/
Static Function A290Carga()
Local aCodApl := {}
Local nX

dbSelectArea("AML")
dbSetOrder(1)

If Len(AML->AML_CODFIX) == 3 .And. Len(AML->AML_CODVAR)==4
	aAdd(aCodApl,{ '100','0000','GERAL TOTAL','Recursos  da entidade de livre aplica��o.' }  )
	aAdd(aCodApl,{ '100','XXXX','GERAL - Conv�nios/Entidades/Fundos','Recursos espec�ficos para aplica��o em conv�nios, entidades ou fundos n�o vinculados a outras categorias pr�-determinadas.' }  )
	aAdd(aCodApl,{ '110','0000','GERAL','Recursos pr�prios da entidade de livre aplica��o.' }  )
	aAdd(aCodApl,{ '111','0000','REMUNERA��O DE APLICA��ES FINANCEIRAS','Recursos advindos de aplica��es financeiras dos recursos de livre movimenta��o. Utilizado apenas para a classifica��o de receitas.' }  )
	aAdd(aCodApl,{ '120','0000','ALIENA��O DE BENS','Recursos advindos de aliena��es de bens cuja aplica��o dever� ser vinculada.' }  )
	aAdd(aCodApl,{ '121','0000','REMUNERA��O DE APLICA��ES FINANCEIRAS','Recursos advindos de aplica��es financeiras dos recursos de aliena��o de bens. Utilizado apenas para a classifica��o de receitas.' }  )
	aAdd(aCodApl,{ '130','0000','CIDE-CONTRIBUI��O DE INTERVEN��O NO DOM�NIO ECON�MICO','Recursos advindos da CIDE cuja aplica��o dever� ser vinculada.' }  )
	aAdd(aCodApl,{ '130','XXXX','CIDE-CONTRIBUI��O DE INTERVEN��O NO DOM�NIO ECON�MICO - Conv�nios/Entidades/Fundos','Recursos advindos da CIDE ou de conv�nios, entidades ou fundos a ela vinculadas.' }  )
	aAdd(aCodApl,{ '131','0000','REMUNERA��O DE APLICA��ES FINANCEIRAS','Recursos advindos de aplica��es financeiras dos recursos da CIDE. Utilizado apenas para a classifica��o de receitas.' }  )
	aAdd(aCodApl,{ '140','0000','ROYALTIES DA EXPLORA��O DO PETR�LEO E G�S NATURAL','Recursos advindos das receitas provenientes  da participa��o no resultado ou da compensa��o financeira pela explora��o de petr�leo e g�s natural.' }  )
	aAdd(aCodApl,{ '141','0000','REMUNERA��O DE APLICA��ES FINANCEIRAS','Recursos advindos de aplica��es financeiras dos recursos das receitas da participa��o no resultado ou da compensa��o financeira pela explora��o de petr�leo e g�s natural.' }  )
	aAdd(aCodApl,{ '200','0000','EDUCA��O','Recursos vinculados � Educa��o.' }  )
	aAdd(aCodApl,{ '200','XXXX','EDUCA��O - Conv�nios/Entidades/Fundos','Recursos vinculados � conv�nios, entidades ou fundos da Educa��o.' }  )
	aAdd(aCodApl,{ '201','0000','OPERA��ES DE CR�DITO VINCULADAS � EDUCA��O - CRECHE ','Recursos de Opera��es e Cr�dito Vinculadas � Educa��o para aplica��o em Creches.' }  )
	aAdd(aCodApl,{ '201','XXXX','OPERA��ES DE CR�DITO VINCULADAS � EDUCA��O - CRECHE - Conv�nios/Entidades/Fundos','Recursos de Opera��es e Cr�dito Vinculadas � Educa��o para aplica��o em Creches.' }  )
	aAdd(aCodApl,{ '202','0000','OPERA��ES DE CR�DITO VINCULADAS � EDUCA��O - PR�-ESCOLA','Recursos de Opera��es e Cr�dito Vinculadas � Educa��o para aplica��o em Pr�-Escola.' }  )
	aAdd(aCodApl,{ '202','XXXX','OPERA��ES DE CR�DITO VINCULADAS � EDUCA��O - PR�-ESCOLA - Conv�nios/Entidades/Fundos','Recursos de Opera��es e Cr�dito Vinculadas � Educa��o para aplica��o em Pr�-Escola.' }  )
	aAdd(aCodApl,{ '203','0000','OPERA��ES DE CR�DITO VINCULADAS � EDUCA��O - ENSINO FUDAMENTAL','Recursos de Opera��es e Cr�dito Vinculadas � Educa��o para aplica��o no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '203','XXXX','OPERA��ES DE CR�DITO VINCULADAS � EDUCA��O - ENSINO FUDAMENTAL - Conv�nios/Entidades/Fundos','Recursos de Opera��es e Cr�dito Vinculadas � Educa��o para aplica��o no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '204','0000','ROYALTIES DO PETR�LEO DESTINADOS � EDUCA��O - CRECHE','Recursos de Royalties do Petr�leo Destinados a Educa��o para aplica��o em Creches.' }  )
	aAdd(aCodApl,{ '204','XXXX','ROYALTIES DO PETR�LEO DESTINADOS � EDUCA��O - CRECHE - Conv�nios/Entidades/Fundos','Recursos de Royalties do Petr�leo Destinados a Educa��o para aplica��o em Creches.' }  )
	aAdd(aCodApl,{ '205','0000','ROYALTIES DO PETR�LEO DESTINADOS � EDUCA��O - PR�-ESCOLA','Recursos de Royalties do Petr�leo Destinados a Educa��o para aplica��o em Pr�-Escola' }  )
	aAdd(aCodApl,{ '205','XXXX','ROYALTIES DO PETR�LEO DESTINADOS � EDUCA��O - PR�-ESCOLA - Conv�nios/Entidades/Fundos','Recursos de Royalties do Petr�leo Destinados a Educa��o para aplica��o em Pr�-Escola.' }  )
	aAdd(aCodApl,{ '206','0000','ROYALTIES DO PETR�LEO DESTINADOS � EDUCA��O - ENSINO FUNDAMENTAL','Recursos de Royalties do Petr�leo Destinados a Educa��o para aplica��o no Ensino Fundamental' }  )
	aAdd(aCodApl,{ '206','XXXX','ROYALTIES DO PETR�LEO DESTINADOS � EDUCA��O - ENSINO FUNDAMENTAL - Conv�nios/Entidades/Fundos','Recursos de Royalties do Petr�leo Destinados a Educa��o para aplica��o no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '207','0000','RECEITA PELA PRESTA��O DE SERVI�OS EDUCACIONAIS ','Recursos decorrentes de receitas da presta��o de servi�os educacionais.' }  )
	aAdd(aCodApl,{ '207','XXXX','RECEITA PELA PRESTA��O DE SERVI�OS EDUCACIONAIS - Conv�nios/Entidades/Fundos','Recursos decorrentes de receitas da presta��o de servi�os educacionais.' }  )
	aAdd(aCodApl,{ '210','0000','EDUCA��O INFANTIL','Recursos vinculados � Educa��o Infantil.' }  )
	aAdd(aCodApl,{ '210','XXXX','EDUCA��O INFANTI - Conv�nios/Entidades/Fundos','Recursos vinculados � conv�nios da Educa��o Infantil.' }  )
	aAdd(aCodApl,{ '211','0000','REMUNERA��O DE APLICA��ES FINANCEIRAS','Recursos advindos de aplica��es financeiras dos recursos vinculados da Educa��o Infantil. Utilizado apenas para a classifica��o de receitas.' }  )
	aAdd(aCodApl,{ '212','0000','EDUCA��O INFANTIL - CRECHE','Recursos vinculados � Educa��o Infantil - Creche.' }  )
	aAdd(aCodApl,{ '212','XXXX','EDUCA��O INFANTIL - CRECHE - Conv�nios/Entidades/Fundos','Recursos vinculados � conv�nios da Educa��o Infantil - Creche.' }  )
	aAdd(aCodApl,{ '213','0000','EDUCA��O INFANTIL - PR�-ESCOLA','Recursos vinculados � Educa��o Infantil - Pr�-Escola.' }  )
	aAdd(aCodApl,{ '213','XXXX','EDUCA��O INFANTIL - PR�-ESCOLA - Conv�nios/Entidades/Fundos','Recursos vinculados � conv�nios da Educa��o Infantil - Pr�-Escola.' }  )
	aAdd(aCodApl,{ '220','0000','ENSINO FUNDAMENTAL','Recursos vinculados ao Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '220','XXXX','ENSINO FUNDAMENTAL - Conv�nios/Entidades/Fundos','Recursos vinculados � conv�nios, entidades ou fundos do Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '221','0000','REMUNERA��O DE APLICA��ES FINANCEIRAS','Recursos advindos de aplica��es financeiras dos recursos vinculados do Ensino Fundamental. Utilizado apenas para a classifica��o de receitas.' }  )
	aAdd(aCodApl,{ '230','0000','ENSINO M�DIO','Recursos vinculados ao Ensino M�dio.' }  )
	aAdd(aCodApl,{ '230','XXXX','ENSINO M�DIO - Conv�nios/Entidades/Fundos','Recursos vinculados � conv�nios, entidades ou fundos do Ensino M�dio.' }  )
	aAdd(aCodApl,{ '231','0000','REMUNERA��O DE APLICA��ES FINANCEIRAS','Recursos advindos de aplica��es financeiras dos recursos vinculados do Ensino M�dio. Utilizado apenas para a classifica��o de receitas.' }  )
	aAdd(aCodApl,{ '232','0000','RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - ENSINO M�DIO','Recursos do Programa Nacional de Apoio ao Transporte Escolar para aplica��o no Ensino M�dio.' }  )
	aAdd(aCodApl,{ '232','XXXX','RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - ENSINO M�DIO - Conv�nios/Entidades/Fundos','Recursos do Programa Nacional de Apoio ao Transporte Escolar para aplica��o no Ensino M�dio.' }  )
//	aAdd(aCodApl,{ '233','0000','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTA��O ESCOLAR - PNAE - ENSINO M�DIO','Recursos do Programa Nacional de Alimenta��o Escolar para aplica��o no Ensino M�dio.' }  )
	aAdd(aCodApl,{ '233','0000','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTA��O ESCOLAR - PNAE - ENSINO M�DIO - Conv�nios/Entidades/Fundos','Recursos do Programa Nacional de Alimenta��o Escolar para aplica��o no Ensino M�dio.' }  )
	aAdd(aCodApl,{ '240','0000','EDUCA��O ESPECIAL','Recursos vinculados ao Ensino M�dio.' }  )
	aAdd(aCodApl,{ '240','XXXX','EDUCA��O ESPECIAL - Conv�nios/Entidades/Fundos','Recursos vinculados � conv�nios, entidades ou fundos do Ensino M�dio.' }  )
	aAdd(aCodApl,{ '241','0000','REMUNERA��O DE APLICA��ES FINANCEIRAS','Recursos advindos de aplica��es financeiras dos recursos vinculados do Ensino Especial. Utilizado apenas para a classifica��o de receitas.' }  )
	aAdd(aCodApl,{ '242','0000','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTA��O ESCOLAR - PNAE - EDUCA��O ESPECIAL','Recursos do Programa Nacional de Alimenta��o Escolar para aplica��o no Educa��o Especial.' }  )
	aAdd(aCodApl,{ '242','XXXX','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTA��O ESCOLAR - PNAE - EDUCA��O ESPECIAL - Conv�nios/Entidades/Fundos','Recursos do Programa Nacional de Alimenta��o Escolar para aplica��o no Educa��o Especial.' }  )
	aAdd(aCodApl,{ '243','0000','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTA��O ESCOLAR - PNAE - EJA','Recursos do Programa Nacional de Alimenta��o Escolar para aplica��o na Educa��o de Jovens e Adultos (EJA).' }  )
	aAdd(aCodApl,{ '243','XXXX','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTA��O ESCOLAR - PNAE - EJA - Conv�nios/Entidades/Fundos','Recursos do Programa Nacional de Alimenta��o Escolar para aplica��o na Educa��o de Jovens e Adultos (EJA).' }  )
	aAdd(aCodApl,{ '250','0000','EDUCA��O - FUNDEF','Recursos vinculados ao FUNDEF.' }  )
	aAdd(aCodApl,{ '251','0000','EDUCA��O - FUNDEF - MAGIST�RIO','Recursos vinculados ao FUNDEF para aplica��o no magist�rio.' }  )
	aAdd(aCodApl,{ '252','0000','EDUCA��O - FUNDEF - OUTROS','Recursos vinculados ao FUNDEF para aplica��o em outras despesas.' }  )
	aAdd(aCodApl,{ '253','0000','REMUNERA��O DE APLICA��ES FINANCEIRAS','Recursos advindos de aplica��es financeiras dos recursos vinculados do FUNDEF. Utilizado apenas para a classifica��o de receitas.' }  )
	aAdd(aCodApl,{ '260','0000','EDUCA��O - FUNDEB','Recursos vinculados ao FUNDEB.' }  )
	aAdd(aCodApl,{ '260','XXXX','EDUCA��O - FUNDEB - Conv�nios/Entidades/Fundos','Recursos vinculados � conv�nios, entidades ou fundos do FUNDEB.' }  )
	aAdd(aCodApl,{ '261','0000','EDUCA��O - FUNDEB - MAGIST�RIO','Recursos vinculados ao FUNDEB para aplica��o no magist�rio.' }  )
	aAdd(aCodApl,{ '262','0000','EDUCA��O - FUNDEB - OUTROS','Recursos vinculados ao FUNDEB para aplica��o em outras despesas.' }  )
	aAdd(aCodApl,{ '263','0000','REMUNERA��O DE APLICA��ES FINANCEIRAS','Recursos advindos de aplica��es financeiras dos recursos vinculados do FUNDEB. Utilizado apenas para a classifica��o de receitas.' }  )
	aAdd(aCodApl,{ '264','AAAA','EDUCA��O - FUNDEB - MAGIST�RIO - Ano Anterior','Recursos vinculados ao FUNDEB para aplica��o no magist�rio, advindos de exerc�cios anteriores. Identificado pelo ano de ingresso dos recursos.' }  )
	aAdd(aCodApl,{ '265','AAAA','EDUCA��O - FUNDEB - OUTROS - Ano Anterior�','Recursos vinculados ao FUNDEB para aplica��o em outras despesas, advindos de exerc�cios anteriores. Identificado pelo ano de ingresso dos recursos.' }  )
	aAdd(aCodApl,{ '266','AAAA','EDUCA��O - FUNDEB - MAGIST�RIO - Ano Anterior - CRECHE','Recursos vinculados ao FUNDEB para aplica��o no magist�rio, advindos de exerc�cios anteriores. Identificado pelo ano de ingresso dos recursos - Creche.' }  )
	aAdd(aCodApl,{ '267','AAAA','EDUCA��O - FUNDEB - MAGIST�RIO - Ano Anterior - PR�-ESCOLA','Recursos vinculados ao FUNDEB para aplica��o no magist�rio, advindos de exerc�cios anteriores. Identificado pelo ano de ingresso dos recursos - Pr�-Escola.' }  )
	aAdd(aCodApl,{ '268','AAAA','EDUCA��O - FUNDEB-OUTROS - Ano Anterior�- CRECHE','Recursos vinculados ao FUNDEB para aplica��o em outras despesas, advindos de exerc�cios anteriores. Identificado pelo ano de ingresso dos recursos - Creche.' }  )
	aAdd(aCodApl,{ '269','AAAA','EDUCA��O - FUNDEB - OUTROS - Ano Anterior�- PR�-ESCOLA','Recursos vinculados ao FUNDEB para aplica��o em outras despesas, advindos de exerc�cios anteriores. Identificado pelo ano de ingresso dos recursos - Pr�-Escola.' }  )
	aAdd(aCodApl,{ '271','0000','EDUCA��O - FUNDEB - MAGIST�RIO - CRECHE','Recursos vinculados ao FUNDEB para aplica��o no magist�rio - Creche.' }  )
	aAdd(aCodApl,{ '272','0000','EDUCA��O - FUNDEB - MAGIST�RIO�- PR�-ESCOLA','Recursos vinculados ao FUNDEB para aplica��o no magist�rio - Pr�-Escola.' }  )
	aAdd(aCodApl,{ '273','0000','EDUCA��O - FUNDEB - OUTROS�- CRECHE','Recursos vinculados ao FUNDEB para aplica��o em outras despesas - Creche.' }  )
	aAdd(aCodApl,{ '274','0000','EDUCA��O - FUNDEB - OUTROS�- PR�-ESCOLA','Recursos vinculados ao FUNDEB para aplica��o em outras despesas - Pr�-Escola.' }  )
	aAdd(aCodApl,{ '275','0000','RECURSOS COMPLEMENTA��O DO FUNDEB - MAGIST�RIO - CRECHE','Recursos vinculados ao FUNDEB decorrentes de complementa��o da Uni�o para aplica��o no magist�rio - Creche.' }  )
	aAdd(aCodApl,{ '276','0000','RECURSOS COMPLEMENTA��O DO FUNDEB - MAGIST�RIO - PR� - ESCOLA','Recursos vinculados ao FUNDEB decorrentes de complementa��o da Uni�o para aplica��o no magist�rio - Pr�-Escola.' }  )
	aAdd(aCodApl,{ '277','0000','RECURSOS COMPLEMENTA��O DO FUNDEB - MAGIST�RIO - ENSINO FUDAMENTAL','Recursos vinculados ao FUNDEB decorrentes de complementa��o da Uni�o para aplica��o no magist�rio - Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '280','0000','RECURSOS DO SAL�RIO EDUCA��O - CRECHE','Recursos do Sal�rio Educa��o para aplica��o em Creche.' }  )
	aAdd(aCodApl,{ '280','XXXX','RECURSOS DO SAL�RIO EDUCA��O - CRECHE - Conv�nios/Entidades/Fundos','Recursos do Sal�rio Educa��o para aplica��o em Creche.' }  )
	aAdd(aCodApl,{ '281','0000','RECURSOS DO SAL�RIO EDUCA��O - PR�-ESCOLA','Recursos do Sal�rio Educa��o para aplica��o em Pr� - Escola.' }  )
	aAdd(aCodApl,{ '281','XXXX','RECURSOS DO SAL�RIO EDUCA��O - PR�-ESCOLA - Conv�nios/Entidades/Fundos','Recursos do Sal�rio Educa��o para aplica��o em Pr� - Escola.' }  )
	aAdd(aCodApl,{ '282','0000','RECURSOS DO SAL�RIO EDUCA��O - ENSINO FUNDAMENTAL','Recursos do Sal�rio Educa��o para aplica��o no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '282','XXXX','RECURSOS DO SAL�RIO EDUCA��O - ENSINO FUNDAMENTAL - Conv�nios/Entidades/Fundos','Recursos do Sal�rio Educa��o para aplica��o no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '283','0000','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTA��O ESCOLAR - PNAE - CRECHE','Recursos do Programa Nacional de Alimenta��o Escolar para aplica��o em Creches.' }  )
	aAdd(aCodApl,{ '283','XXXX','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTA��O ESCOLAR - PNAE - CRECHE - Conv�nios/Entidades/Fundos','Recursos do Programa Nacional de Alimenta��o Escolar para aplica��o em Creches.' }  )
	aAdd(aCodApl,{ '284','0000','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTA��O ESCOLAR - PNAE - PR�-ESCOLA','Recursos do Programa Nacional de Alimenta��o Escolar para aplica��o em Pr�-Escola.' }  )
	aAdd(aCodApl,{ '284','XXXX','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTA��O ESCOLAR - PNAE - PR�-ESCOLA - Conv�nios/Entidades/Fundos','Recursos do Programa Nacional de Alimenta��o Escolar para aplica��o em Pr�-Escola.' }  )
	aAdd(aCodApl,{ '285','0000','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTA��O ESCOLAR - PNAE - ENSINO FUNDAMENTAL','Recursos do Programa Nacional de Alimenta��o Escolar para aplica��o no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '285','XXXX','RECURSOS DO PROGRAMA NACIONAL DE ALIMENTA��O ESCOLAR - PNAE - ENSINO FUNDAMENTAL - Conv�nios/Entidades/Fundos','Recursos do Programa Nacional de Alimenta��o Escolar para aplica��o no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '286','0000','RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - CRECHE','Recursos do Programa Nacional de Apoio ao Transporte Escolar para aplica��o em Creches.' }  )
	aAdd(aCodApl,{ '286','XXXX','RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - CRECHE - Conv�nios/Entidades/Fundos','Recursos do Programa Nacional de Apoio ao Transporte Escolar para aplica��o em Creches.' }  )
	aAdd(aCodApl,{ '287','0000','RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - PR�-ESCOLA','Recursos do Programa Nacional de Apoio ao Transporte Escolar para aplica��o em Pr�-Escola.' }  )
	aAdd(aCodApl,{ '287','XXXX','RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - PR�-ESCOLA - Conv�nios/Entidades/Fundos','Recursos do Programa Nacional de Apoio ao Transporte Escolar para aplica��o em Pr�-Escola.' }  )
	aAdd(aCodApl,{ '288','0000','RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - ENSINO FUNDAMENTAL','Recursos do Programa Nacional de Apoio ao Transporte Escolar para aplica��o no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '288','XXXX','RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - ENSINO FUNDAMENTAL - Conv�nios/Entidades/Fundos','Recursos do Programa Nacional de Apoio ao Transporte Escolar para aplica��o no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '291','0000','RECURSOS DO PROGRAMA DINHEIRO DIRETO NA ESCOLA - PDDE - CRECHE','Recursos do Programa Dinheiro Direto na Escola para aplica��o em Creche.' }  )
	aAdd(aCodApl,{ '291','XXXX','RECURSOS DO PROGRAMA DINHEIRO DIRETO NA ESCOLA - PDDE - CRECHE - Conv�nios/Entidades/Fundos','Recursos do Programa Dinheiro Direto na Escola para aplica��o em Creche.' }  )
	aAdd(aCodApl,{ '292','0000','RECURSOS DO PROGRAMA DINHEIRO DIRETO NA ESCOLA - PDDE - PR�-ESCOLA','Recursos do Programa Dinheiro Direto na Escola para aplica��o em Pr�-Escola.' }  )
	aAdd(aCodApl,{ '292','XXXX','RECURSOS DO PROGRAMA DINHEIRO DIRETO NA ESCOLA - PDDE - PR�-ESCOLA - Conv�nios/Entidades/Fundos','Recursos do Programa Dinheiro Direto na Escola para aplica��o em Pr�-Escola.' }  )
	aAdd(aCodApl,{ '293','0000','RECURSOS DO PROGRAMA DINHEIRO DIRETO NA ESCOLA - PDDE - ENSINO FUNDAMENTAL','Recursos do Programa Dinheiro Direto na Escola para aplica��o no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '293','XXXX','RECURSOS DO PROGRAMA DINHEIRO DIRETO NA ESCOLA - PDDE - ENSINO FUNDAMENTAL - Conv�nios/Entidades/Fundos','Recursos do Programa Dinheiro Direto na Escola para aplica��o no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '294','0000','OUTRAS TRANSFER�NCIAS DE RECURSOS DO FNDE - CRECHE',' Outras Transfer�ncias de Recursos do FNDE para aplica��o em Creches.' }  )
	aAdd(aCodApl,{ '294','XXXX','OUTRAS TRANSFER�NCIAS DE RECURSOS DO FNDE - CRECHE - Conv�nios/Entidades/Fundos',' Outras Transfer�ncias de Recursos do FNDE para aplica��o em Creches.' }  )
	aAdd(aCodApl,{ '295','0000','OUTRAS TRANSFER�NCIAS DE RECURSOS DO FNDE - PR�-ESCOLA',' Outras Transfer�ncias de Recursos do FNDE para aplica��o em Pr�-Escola.' }  )
	aAdd(aCodApl,{ '295','XXXX','OUTRAS TRANSFER�NCIAS DE RECURSOS DO FNDE - PR�-ESCOLA - Conv�nios/Entidades/Fundos ',' Outras Transfer�ncias de Recursos do FNDE para aplica��o em Pr�-Escola.' }  )
	aAdd(aCodApl,{ '296','0000','OUTRAS TRANSFER�NCIAS DE RECURSOS DO FNDE - ENSINO FUNDAMENTAL',' Outras Transfer�ncias de Recursos do FNDE para aplica��o no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '296','XXXX','OUTRAS TRANSFER�NCIAS DE RECURSOS DO FNDE - ENSINO FUNDAMENTAL - Conv�nios/Entidades/Fundos ',' Outras Transfer�ncias de Recursos do FNDE para aplica��o no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '297','0000','OUTROS RECURSOS DESTINADOS � EDUCA��O - CRECHE ','Outras  Recursos destinados � Educa��o para aplica��o em Pr�-Escola.' }  )
	aAdd(aCodApl,{ '297','XXXX','OUTROS RECURSOS DESTINADOS � EDUCA��O - CRECHE - Conv�nios/Entidades/Fundos','Outras  Recursos destinados � Educa��o para aplica��o em Pr�-Escola.' }  )
	aAdd(aCodApl,{ '298','0000','OUTROS RECURSOS DESTINADOS � EDUCA��O - PR�-ESCOLA','Outras  Recursos destinados � Educa��o para aplica��o em Creche.' }  )
	aAdd(aCodApl,{ '298','XXXX','OUTROS RECURSOS DESTINADOS � EDUCA��O - PR�-ESCOLA - Conv�nios/Entidades/Fundos','Outras  Recursos destinados � Educa��o para aplica��o em Creche.' }  )
	aAdd(aCodApl,{ '299','0000','OUTROS RECURSOS DESTINADOS � EDUCA��O - ENSINO FUNDAMENTAL','Outras  Recursos destinados � Educa��o para aplica��o no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '299','XXXX','OUTROS RECURSOS DESTINADOS � EDUCA��O  - ENSINO FUNDAMENTAL - Conv�nios/Entidades/Fundos','Outras  Recursos destinados � Educa��o para aplica��o no Ensino Fundamental.' }  )
	aAdd(aCodApl,{ '300','0000','SA�DE','Recursos vinculados � Sa�de.' }  )
	aAdd(aCodApl,{ '300','XXXX','SA�DE - Conv�nios/Entidades/Fundos','Recursos vinculados � conv�nios, entidades ou fundos da Sa�de.' }  )
	aAdd(aCodApl,{ '301','0000','ATEN��O B�SICA','Recursos destinados �s a��es da Aten��o B�sica.' }  )
	aAdd(aCodApl,{ '301','XXXX','ATEN��O B�SICA - Conv�nios/Entidades/Fundos','Recursos destinados � a��es da Aten��o B�sica provenientes de transfer�ncias fundo a fundo.' }  )
	aAdd(aCodApl,{ '302','0000','ATEN��O DE M�DIA E ALTA COMPLEXIDADE AMBULATORIAL E HOSPITALAR','Recursos destinados �s a��es de M�dia e Alta Complexidade Ambulatorial e Hospitalar.' }  )
	aAdd(aCodApl,{ '302','XXXX','ATEN��O DE M�DIA E ALTA COMPLEXIDADE AMBULATORIAL E HOSPITALAR - Conv�nios/Entidades/Fundos','Recursos destinados �s a��es de M�dia e Alta Complexidade Ambulatorial e Hospitalar provenientes de transfer�ncias fundo a fundo.' }  )
	aAdd(aCodApl,{ '303','0000','VIGIL�NCIA EM SA�DE','Recursos destinados �s a��es de Vigil�ncia em Sa�de.' }  )
	aAdd(aCodApl,{ '303','XXXX','VIGIL�NCIA EM SA�DE - Conv�nios/Entidades/Fundos','Recursos destinados �s a��es de Vigil�ncia em Sa�de provenientes de transfer�ncias fundo a fundo.' }  )
	aAdd(aCodApl,{ '304','0000','ASSIST�NCIA FARMAC�UTICA','Recursos destinados �s a��es de Assist�ncia Farmac�utica.' }  )
	aAdd(aCodApl,{ '304','XXXX','ASSIST�NCIA FARMAC�UTICA - Conv�nios/Entidades/Fundos','Recursos destinados �s a��es de Assist�ncia Farmac�utica provenientes de transfer�ncias fundo a fundo.' }  )
	aAdd(aCodApl,{ '305','0000','GEST�O DO SUS','Recursos destinados �s a��es de Gest�o do SUS.' }  )
	aAdd(aCodApl,{ '305','XXXX','GESTAO DO SUS - Conv�nios/Entidades/Fundos','Recursos destinados �s a��es de Gest�o do SUS provenientes de transfer�ncias fundo a fundo.' }  )
	aAdd(aCodApl,{ '307','0000','OUTROS PROGRAMAS FINANCIADOS POR TRANSFER�NCIAS FUNDO A FUNDO','Recursos destinados a Outros Programas Financiados por Transfer�ncias fundo a fundo.' }  )
	aAdd(aCodApl,{ '307','XXXX','OUTROS PROGRAMAS FINANCIADOS POR TRANSFER�NCIAS FUNDO A FUNDO - Conv�nios/Entidades/Fundos','Recursos destinados a Outros Programas Financiados por Transfer�ncias fundo a fundo provenientes de transfer�ncias fundo a fundo.' }  )
	aAdd(aCodApl,{ '308','0000','CONV�NIOS SUS','Recursos destinados a Conv�nios com o SUS.' }  )
	aAdd(aCodApl,{ '308','XXXX','CONV�NIOS SUS - Conv�nios/Entidades/Fundos','Recursos destinados a Conv�nios provenientes de conv�nios com o SUS.' }  )
	aAdd(aCodApl,{ '309','0000','SERVI�OS DE SA�DE','Recursos destinados �s a��es de Servi�os de Sa�de.' }  )
	aAdd(aCodApl,{ '309','XXXX','SERVI�OS DE SA�DE - Conv�nios/Entidades/Fundos','Recursos destinados �s a��es de Servi�os de Sa�de provenientes de transfer�ncias fundo a fundo.' }  )
	aAdd(aCodApl,{ '310','0000','SA�DE�GERAL','Recursos vinculados � Sa�de Geral.' }  )
	aAdd(aCodApl,{ '311','0000','REMUNERA��O DE APLICA��ES FINANCEIRAS','Recursos advindos de aplica��es financeiras dos recursos vinculados da Sa�de. Utilizado apenas para a classifica��o de receitas.' }  )
	aAdd(aCodApl,{ '320','0000','SA�DE - TAXAS','Recursos advindos das receitas de taxas vinculadas � Sa�de cuja aplica��o dever� ser vinculada � Sa�de.' }  )
	aAdd(aCodApl,{ '330','0000','SA�DE - SERVI�OS','Recursos advindos das receitas de servi�os vinculadas � Sa�de cuja aplica��o dever� ser vinculada � Sa�de.' }  )
	aAdd(aCodApl,{ '340','0000','SA�DE - OUTROS','Recursos advindos das outras receitas vinculadas � Sa�de cuja aplica��o dever� ser vinculada � Sa�de.' }  )
	aAdd(aCodApl,{ '350','0000','BLOCO DE CUSTEIO DAS A��ES E SERVI�OS P�BLICOS DE SA�DE','Esta codifica��o dever� ser utilizada exclusivamente nos registros cont�beis  da receita e do ativo disponivel decorrentes do ingresso de  Recursos destinados �s a��es e servi�os p�blicos de sa�de relacionados ao Bloco de Custeio.' }  )
	aAdd(aCodApl,{ '351','0000','BLOCO DE CUSTEIO DAS A��ES E SERVI�OS P�BLICOS DE SA�DE - Remunera��o de Aplica��o Financeira','Esta codifica��o dever� ser utilizada exclusivamente no registros cont�beis decorrentos  da remunera��o de aplica��o financeira dos  Recursos destinados �s a��es e servi�os p�blicos de sa�de relacionados ao Bloco de Custeio.' }  )
	aAdd(aCodApl,{ '360','0000','BLOCO DE INVESTIMENTOS NA REDE DE SERVI�OS DE SA�DE','Esta codifica��o dever� ser utilizada exclusivamente nos registros cont�beis  da receita e no ativo disponivel decorrentes do ingresso de  Recursos destinados �s a��es e servi�os p�blicos de sa�de relacionados ao Bloco de Investimentos.' }  )
	aAdd(aCodApl,{ '361','0000','BLOCO DE INVESTIMENTOS NA REDE DE SERVI�OS DE SA�DE - Remunera��o de Aplica��o Financeira','Esta codifica��o dever� ser utilizada exclusivamente no registro cont�bil da remunera��o de aplica��o financeira dos  Recursos destinados �s a��es e servi�os p�blicos de sa�de relacionados ao ao Bloco de Investimentos.' }  )
	aAdd(aCodApl,{ '400','0000','TR�NSITO','Recursos vinculados ao Tr�nsito.' }  )
	aAdd(aCodApl,{ '400','XXXX','TR�NSITO - Conv�nios/Entidades/Fundos','Recursos vinculados � conv�nios, entidades ou fundos ao Tr�nsito.' }  )
	aAdd(aCodApl,{ '410','0000','TR�NSITO - SINALIZA��O','Recursos vinculados ao Tr�nsito, para aplica��o em sinaliza��o.' }  )
	aAdd(aCodApl,{ '411','0000','REMUNERA��O DE APLICA��ES FINANCEIRAS','Recursos advindos de aplica��es financeiras dos recursos vinculados do Tr�nsito-Sinaliza��o. Utilizado apenas para a classifica��o de receitas.' }  )
	aAdd(aCodApl,{ '420','0000','TR�NSITO - ENGENHARIA DE TR�NSITO','Recursos vinculados ao Tr�nsito, para aplica��o em engenharia de tr�nsito.' }  )
	aAdd(aCodApl,{ '430','0000','TR�NSITO - ENGENHARIA DE CAMPO','Recursos vinculados ao Tr�nsito, para aplica��o em engenharia de campo..' }  )
	aAdd(aCodApl,{ '440','0000','TR�NSITO - POLICIAMENTO','Recursos vinculados ao Tr�nsito, para aplica��o em policiamento.' }  )
	aAdd(aCodApl,{ '450','0000','TR�NSITO - FISCALIZA��O','Recursos vinculados ao Tr�nsito, para aplica��o em fiscaliza��o.' }  )
	aAdd(aCodApl,{ '460','0000','TR�NSITO - EDUCA��O DE TR�NSITO','Recursos vinculados ao Tr�nsito, para aplica��o em educa��o de tr�nsito.' }  )
	aAdd(aCodApl,{ '470','0000','TR�NSITO - FUNSET','Recursos vinculados ao Tr�nsito - FUNSET.' }  )
	aAdd(aCodApl,{ '500','0000','ASSIST�NCIA SOCIAL','Recursos vinculados � Assist�ncia Social.' }  )
	aAdd(aCodApl,{ '500','XXXX','ASSIST�NCIA SOCIAL - Conv�nios/Entidades/Fundos','Recursos vinculados � conv�nios, entidades ou fundos da Assist�ncia Social.' }  )
	aAdd(aCodApl,{ '510','0000','ASSIST�NCIA SOCIAL - GERAL','Recursos vinculados � Assist�ncia Social - Geral.' }  )
	aAdd(aCodApl,{ '511','0000','REMUNERA��O DE APLICA��ES FINANCEIRAS','Recursos advindos de aplica��es financeiras dos recursos vinculados � Assist�ncia Social. Utilizado apenas para a classifica��o de receitas.' }  )
	aAdd(aCodApl,{ '600','0000','REGIME PR�PRIO DE PREVID�NCIA SOCIAL','Recursos vinculados ao RPPS.' }  )
	aAdd(aCodApl,{ '600','XXXX','RPPS - Conv�nios/Entidades/Fundos','Recursos vinculados � conv�nios, entidades ou fundos do RPPS.' }  )
	aAdd(aCodApl,{ '601','0000','REGIME PR�PRIO DE PREVID�NCIA SOCIAL - PLANO FINANCEIRO','Recursos vinculados ao RPPS - Plano Financeiro.' }  )
	aAdd(aCodApl,{ '602','0000','REGIME PR�PRIO DE PREVID�NCIA SOCIAL - PLANO PREVIDENCI�RIO','Recursos vinculados ao RPPS - Plano Previdenci�rio.' }  )
	aAdd(aCodApl,{ '610','0000','RPPS - CONTRIBUI��ES','Recursos advindos das receitas de contribui��es vinculadas ao RPPS cuja aplica��o dever� ser vinculada ao RPPS.' }  )
	aAdd(aCodApl,{ '611','0000','RPPS - CONTRIBUI��O PATRONAL','Recursos advindos das receitas de contribui��es patronais ao RPPS cuja aplica��o dever� ser vinculada ao RPPS.' }  )
	aAdd(aCodApl,{ '612','0000','RPPS - CONTRIBUI��O SEGURADOS','Recursos advindos das receitas de contribui��es dos segurados ao RPPS cuja aplica��o dever� ser vinculada ao RPPS.' }  )
	aAdd(aCodApl,{ '613','0000','RPPS - CONTRIBUI��ES - PLANO FINANCEIRO','Recursos advindos das receitas de contribui��es vinculadas ao RPPS cuja aplica��o dever� ser vinculada ao RPPS - Plano Financeiro.' }  )
	aAdd(aCodApl,{ '614','0000','RPPS - CONTRIBUI��ES - PLANO PREVIDENCI�RIO','Recursos advindos das receitas de contribui��es vinculadas ao RPPS cuja aplica��o dever� ser vinculada ao RPPS - Plano Previdenci�rio.' }  )
	aAdd(aCodApl,{ '615','0000','RPPS - CONTRIBUI��O PATRONAL - PLANO FINANCEIRO','Recursos advindos das receitas de contribui��es patronais ao RPPS cuja aplica��o dever� ser vinculada ao RPPS - Plano Financeiro.' }  )
	aAdd(aCodApl,{ '616','0000','RPPS - CONTRIBUI��O PATRONAL - PLANO PREVIDENCI�RIO','Recursos advindos das receitas de contribui��es patronais ao RPPS cuja aplica��o dever� ser vinculada ao RPPS - Plano Previdenci�rio.' }  )
	aAdd(aCodApl,{ '617','0000','RPPS - CONTRIBUI��O SEGURADOS - PLANO FINANCEIRO','Recursos advindos das receitas de contribui��es dos segurados ao RPPS cuja aplica��o dever� ser vinculada ao RPPS - Plano Financeiro.' }  )
	aAdd(aCodApl,{ '618','0000','RPPS - CONTRIBUI��O SEGURADOS - PLANO PREVIDENCI�RIO','Recursos advindos das receitas de contribui��es dos segurados ao RPPS cuja aplica��o dever� ser vinculada ao RPPS - Plano Previdenci�rio.' }  )
	aAdd(aCodApl,{ '620','0000','RPPS - COMPENSA��O PREVIDENCI�RIA','Recursos advindos das receitas de compensa��o previdenci�ria ao RPPS cuja aplica��o dever� ser vinculada ao RPPS.' }  )
	aAdd(aCodApl,{ '621','0000','RPPS - COMPENSA��O PREVIDENCI�RIA - PLANO FINANCEIRO','Recursos advindos das receitas de compensa��o previdenci�ria ao RPPS cuja aplica��o dever� ser vinculada ao RPPS - Plano Financeiro.' }  )
	aAdd(aCodApl,{ '622','0000','RPPS - COMPENSA��O PREVIDENCI�RIA - PLANO PREVIDENCI�RIO','Recursos advindos das receitas de compensa��o previdenci�ria ao RPPS cuja aplica��o dever� ser vinculada ao RPPS - Plano Previdenci�rio.' }  )
	aAdd(aCodApl,{ '700','0000','DESVINCULA��O DE RECEITAS MUNICIPAIS - DRM','Desvincula��o de 30% da receita dos munic�pios relativas a impostos, taxas, e multas conforme previsto na Emenda Constitucional n� 93/2016. Este c�digo dever� ser utilizado exclusivamente no Controle de Disponibilidade Financeira por destina��o de recursos e no registro da despesa or�ament�ria custeadas com recursos da DRM.' }  )

	For nX := 1 TO Len(aCodApl)
		If ! dbSeek(xFilial("AML")+aCodApl[nX, 1]+aCodApl[nX, 2])
			AML->( RecLock("AML", .T. ) )
			AML->AML_FILIAL := xFilial("AML")
			AML->AML_CODFIX := aCodApl[nX, 1]
			AML->AML_CODVAR := aCodApl[nX, 2]
			AML->AML_NOME   := aCodApl[nX, 3]
			AML->AML_ESPEC  := aCodApl[nX, 4]
			If aCodApl[nX, 2] != 'XXXX'
				AML->AML_STATUS := '1'
			Else
				AML->AML_STATUS := '2'
			EndIf
			AML->( MsUnLock() )
		EndIf
	Next

EndIf

Return



