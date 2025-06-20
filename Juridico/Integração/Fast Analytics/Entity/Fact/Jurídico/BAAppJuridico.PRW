#INCLUDE "BADEFINITION.CH"

NEW APP JURIDIC

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAppJuridico
Modelagem da �rea de Juridico.

@author  Helio Leal
@author  henrique.cesar
@since   05/03/2018
/*/
//-------------------------------------------------------------------
Class BAAppJuridico
	Data cApp

	Method Init() CONSTRUCTOR
	Method ListEntities()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Instancia a classe de App e gera um nome �nico para a �rea. 

@author  Helio Leal
@author  henrique.cesar
@since   05/03/2018
/*/
//-------------------------------------------------------------------
Method Init() Class BAAppJuridico
	::cApp := "Jur�dico"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ListEntities
Lista as entidades (fatos e dimens�es) dispon�veis da �rea, deve ser 
necessariamente o nome das classes das entidades.

@author  Helio Leal
@author  henrique.cesar
@since   05/03/2018
/*/
//-------------------------------------------------------------------
Method ListEntities() Class BAAppJuridico

Return	{   "ANALISEPROCPEDIDOS", + ; //Fato BAAnaliseProcPedidos
			"AUDDESPESA", + ; //Fato BAAuditDespesa
			"AUDGARANTIA", + ; //Fato BAAuditGarantia
			"AUDOBJETOS", + ; //Fato BAAuditObjetos
			"AUDPEDIDOS", + ; //Fato BAAuditPedidos
			"AUDPROCESSO", + ; //Fato BAAuditProcesso
			"BENEFICIOECON", + ; //Fato BABeneficioEcon
			"PROCABERTOENCERRADO", + ; //Fato BAProcAbertosEncerrados
			"PROCANDAMENTO", + ; //Fato BAProcAndamento
			"PROCVALORES", + ; //Fato BAProcessoValores
			"PROVISACONSOLIDADA", + ; //Fato BAProvisaoConsolidada
			"COMPGARANTIA", + ; //Fato BAAuditCompGarantia
			"COMPCONTINGENCIA", + ; //Fato BACompContingencia
			"EMPRESA", + ; //Dimens�o BAEmpresa
			"FILIAL", + ; //Dimens�o BAFilial
			"ASSJURIDICO", + ; //Dimens�o BAAssuntoJuridico
			"AREASJURIDICO", + ; //Dimens�o BAAreasJuridico
			"COMARCA", + ; //Dimens�o BAComarca
			"TPDESPESA", + ; //Dimens�o BATpDespesa
			"MARCA", + ; //Dimens�o BAMarca
			"TPGARANTIA", + ; //Dimens�o BATpGarantia
			"FORMACORRECAO", + ; //Dimens�o BAFormaCorrecao
			"PROGNOSTICO", + ; //Dimens�o BAPrognostico
			"DECISAO", + ; //Dimens�o BADecisao
			"BASEDECISAO", + ; //Dimens�o BABaseDecisao
			"FUNDSOBJETO", + ; //Dimens�o BAFundsObjeto
			"CLIENTE", + ; //Dimens�o BACliente
			"CENTROCUSTO", + ; //Dimens�o BACentroCusto
			"SUBAREA", + ; //Dimens�o BASubArea
			"MOTIVENCERRAMENTO", + ; //Dimens�o BAMotivEncerramento
			"CREDENCIADO", + ; //Dimens�o BACredenciado
			"TPACAO", + ; //Dimens�o BATpAcao
			"FOROTRIBUNAL", + ; //Dimens�o BAForoTribunal
			"VARACAMARA", + ; //Dimens�o BAVaraComarca
			"CARGO", + ; //Dimens�o BACargo
			"FUNCAO", + ; //Dimens�o BAFuncao
			"LOCALTRABALHO", + ; //Dimens�o BALocalTrabalho
			"PROCESSO", + ; //Dimens�o Processo
			"OBJJURIDICO", + ; //Dimens�o ObjetoJuridico
			"PEDJURIDICO" } //Dimens�o BAPedJuridico




