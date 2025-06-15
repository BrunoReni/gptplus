#include "TOTVS.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenMoCodFi
    Classe abstrata para execu��o de comandos
    @type  Class
    @author renan.almeida
    @since 20200204
/*/
//------------------------------------------------------------------------------------------
Class CenMoCodFi
    
    Data oHash

    Method New() Constructor
    Method loadCodes()

EndClass

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New 
    Metodo construtor da classe proGuiaAPI
    @type  Class
    @author renan.almeida
    @since 20200204
/*/
//------------------------------------------------------------------------------------------
Method New(oExecutor) Class CenMoCodFi
    
    self:oHash := HMNew()
    self:loadCodes()

Return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} loadCodes
    Carrega os codigos
    @type  Class
    @author renan.almeida
    @since 20200204
/*/
//------------------------------------------------------------------------------------------
Method loadCodes() Class CenMoCodFi
    
    //Guia Monitoramento
    HMSet(self:oHash, '001', '-Tipo de transacao')
    HMSet(self:oHash, '002', 'BKW_NUMLOT-Numero do lote')
    HMSet(self:oHash, '003', 'BKW_CMPLOT-Competencia dos dados')
    HMSet(self:oHash, '004', '-Data de registro da transacao')
    HMSet(self:oHash, '005', '-Hora de registro da transacao')
    HMSet(self:oHash, '006', 'BKW_SUSEP-Registro ANS')
    HMSet(self:oHash, '007', 'BKW_VERSAO-Versao do componente de comunicacao para o envio de dados para a ANS')
    HMSet(self:oHash, '008', '-Codigo do motivo de inexistencia de movimento na competencia')
    HMSet(self:oHash, '009', 'BKR_TPRGMN-Indicador do tipo de registro')
    HMSet(self:oHash, '010', 'BKR_VTISPR-Vers�o do componente de comunica��o utilizada pelo prestador')
    HMSet(self:oHash, '011', 'BKR_FORENV-Indicador da forma de envio')
    HMSet(self:oHash, '012', 'BKR_CNES-C�digo no Cadastro Nacional de Estabelecimentos de Sa�de do executante')
    HMSet(self:oHash, '013', 'BKR_IDEEXC-Tipo da identifica��o do prestador executante')
    HMSet(self:oHash, '014', 'BKR_CPFCNP-N�mero de cadastro do prestador executante na Receita Federal')
    HMSet(self:oHash, '015', 'BKR_CDMNEX-Munic�pio de localiza��o do prestador executante')
    HMSet(self:oHash, '016', 'B3K_CNS-Cart�o Nacional de Sa�de')
    HMSet(self:oHash, '017', 'B3K_SEXO-Sexo do benefici�riO')
    HMSet(self:oHash, '018', 'B3K_DATNAS-Data de nascimento do benefici�rio')
    HMSet(self:oHash, '019', 'B3K_CODMUN-Munic�pio de resid�ncia do benefici�rio')
    HMSet(self:oHash, '020', 'B3K_SUSEP-N�mero de identifica��o do plano do benefici�rio na ANS')
    HMSet(self:oHash, '021', 'BKR_TPEVAT-Tipo de guia')
    HMSet(self:oHash, '022', 'BKR_OREVAT-Origem da guia')
    HMSet(self:oHash, '023', 'BKR_NMGPRE-N�mero da guia no prestador')
    HMSet(self:oHash, '024', 'BKR_NMGOPE-N�mero da guia atribu�do pela operadora')
    HMSet(self:oHash, '025', 'BKR_IDEREE-Identifica��o do reembolso na operadora')
    HMSet(self:oHash, '026', 'BKR_SOLINT-N�mero da guia de solicita��o de interna��o')
    HMSet(self:oHash, '027', 'BKR_DATSOL-Data da solicita��o')
    HMSet(self:oHash, '028', 'BKR_DATAUT-Data da autoriza��o')
    HMSet(self:oHash, '029', 'BKR_DATREA-Data de realiza��o ou data inicial do per�odo de atendimento')
    HMSet(self:oHash, '030', 'BKR_DTINFT-Data de in�cio do faturamento')
    HMSet(self:oHash, '031', 'BKR_DTFIFT-Data final do per�odo de atendimento ou data do fim do faturamento')
    HMSet(self:oHash, '032', 'BKR_DTPROT-Data do protocolo da cobran�a')
    HMSet(self:oHash, '033', 'BKR_DTPAGT-Data do pagamento')
    HMSet(self:oHash, '034', 'BKR_TIPCON-Tipo de consulta')
    HMSet(self:oHash, '035', 'BKR_CBOS-C�digo na Classifica��o Brasileira de Ocupa��es do executante')
    HMSet(self:oHash, '036', 'BKR_INAVIV-Indicador de atendimento ao rec�m-nato')
    HMSet(self:oHash, '037', 'BKR_INDACI-Indica��o de acidente ou doen�a relacionada')
    HMSet(self:oHash, '038', 'BKR_TIPADM-Car�ter do atendimento')
    HMSet(self:oHash, '039', 'BKR_TIPINT-Tipo de Interna��o')
    HMSet(self:oHash, '040', 'BKR_REGINT-Regime de interna��o')
    HMSet(self:oHash, '041', 'BKR_CDCID1-Diagn�stico principal')
    HMSet(self:oHash, '042', 'BKR_CDCID2-Diagn�stico secund�rio')
    HMSet(self:oHash, '043', 'BKR_CDCID3-Terceiro diagn�stico')
    HMSet(self:oHash, '044', 'BKR_CDCID4-Quarto diagn�stico')
    HMSet(self:oHash, '045', 'BKR_TIPATE-Tipo de atendimento')
    HMSet(self:oHash, '046', 'BKR_TIPFAT-Tipo de faturamento')
    HMSet(self:oHash, '047', 'BKR_DIAACP-N�mero de di�rias de acompanhante')
    HMSet(self:oHash, '048', 'BKR_DIAUTI-N�mero de di�rias de UTI')
    HMSet(self:oHash, '049', 'BKR_MOTSAI-Motivo de encerramento')
    HMSet(self:oHash, '050', 'BKR_VLTINF-Valor informado da guia')
    HMSet(self:oHash, '051', 'BKR_VLTPRO-Valor processado da guia')
    HMSet(self:oHash, '052', 'BKR_VLTPGP-Valor total pago de procedimentos')
    HMSet(self:oHash, '053', 'BKR_VLTDIA-Valor total pago de di�rias')
    HMSet(self:oHash, '054', 'BKR_VLTTAX-Valor total pago de taxas e alugu�is')
    HMSet(self:oHash, '055', 'BKR_VLTMAT-Valor total pago de materiais')
    HMSet(self:oHash, '056', 'BKR_VLTOPM-Valor total pago de OPME')
    HMSet(self:oHash, '057', 'BKR_VLTMED-Valor total pago de medicamentos')
    HMSet(self:oHash, '058', 'BKR_VLTGLO-Valor total de glosa')
    HMSet(self:oHash, '059', 'BKR_VLTGUI-Valor total pago')
    HMSet(self:oHash, '060', 'BKR_VLTFOR-Valor total pago diretamente aos fornecedores')
    HMSet(self:oHash, '061', 'BKR_VLTTBP-Valor total pago em tabela pr�pria da operadora')
    HMSet(self:oHash, '062', 'BN0_DECNUM-N�mero da Declara��o de Nascido Vivo')
    HMSet(self:oHash, '063', 'BN0_DECNUM-N�mero da Declara��o de �bito')
    HMSet(self:oHash, '064', 'BKS_CODTAB-Tabela de refer�ncia do procedimento ou item assistencial realizado')
    HMSet(self:oHash, '065', 'BKS_CODGRU-C�digo do grupo do procedimento ou item assistencial')
    HMSet(self:oHash, '066', 'BKS_CODPRO-C�digo do procedimento realizado ou item assistencial utilizado')
    HMSet(self:oHash, '067', 'BKS_CDDENT-Identifica��o do dente')
    HMSet(self:oHash, '068', 'BKS_CDREGI-Identifica��o da regi�o da boca')
    HMSet(self:oHash, '069', 'BKS_CDFACE-Identifica��o da face do dente')
    HMSet(self:oHash, '070', 'BKS_QTDINF-Quantidade informada de procedimentos ou itens assistenciais')
    HMSet(self:oHash, '071', 'BKS_VLRINF-Valor informado de procedimentos ou itens assistenciais')
    HMSet(self:oHash, '072', 'BKS_QTDPAG-Quantidade paga de procedimentos ou itens assistenciais')
    HMSet(self:oHash, '073', 'BKS_VLPGPR-Valor pago ao prestador executante ou reembolsado ao benefici�rio.')
    HMSet(self:oHash, '074', 'BKS_VLRPGF-Valor pago diretamente ao fornecedor')
    HMSet(self:oHash, '075', 'BKS_CNPJFR-N�mero de cadastro do fornecedor na Receita Federal')
    HMSet(self:oHash, '076', 'BKS_VLRCOP-Valor de coparticipa��o')
    HMSet(self:oHash, '077', 'BKT_CDTBIT-Tabela de refer�ncia do procedimento ou item assistencial realizado que comp�e o pacote')
    HMSet(self:oHash, '078', 'BKT_CDPRIT-C�digo do procedimento realizado ou item assistencial utilizado que comp�e o pacote')
    HMSet(self:oHash, '079', 'BKT_QTPRPC-Quantidade paga de procedimentos ou itens assistenciais que comp�e o pacote')
    HMSet(self:oHash, '080', 'BKR_DTPRGU-Data do processamento da guia')
    HMSet(self:oHash, '081', 'BKR_RGOPIN-Registro ANS da operadora intermedi�ria')
    HMSet(self:oHash, '082', 'BKR_IDCOPR-Identificador de contrata��o por valor pr�-estabelecido')
    HMSet(self:oHash, '083', 'BKR_NMGPRI-N�mero da guia principal de SP/SADT ou de Tratamento Odontol�gico')
    HMSet(self:oHash, '084', 'BKR_VLTCOP-Valor total de coparticipa��o')
    //Valor Pre-estabelecido
    HMSet(self:oHash, '086', 'B9T_TPRGMN-Indicador do tipo de registro')
    HMSet(self:oHash, '088', 'B9T_CNES-C�digo no Cadastro Nacional de Estabelecimentos de Sa�de do executante')
    HMSet(self:oHash, '089', 'B9T_IDEPRE-Tipo da identifica��o do prestador executante')
    HMSet(self:oHash, '090', 'B9T_CPFCNP-N�mero de cadastro do prestador executante na Receita Federal')
    HMSet(self:oHash, '091', 'B9T_CDMNPR-Munic�pio de localiza��o do prestador executante')
    HMSet(self:oHash, '092', 'B9T_RGOPIN-Registro ANS da operadora intermedi�ria')
    HMSet(self:oHash, '093', 'B9T_IDVLRP-Identificador de contrata��o por valor pr�-estabelecido')
    HMSet(self:oHash, '094', 'B9T_VLRPRE-Valor da cobertura contratada na compet�ncia')
    //Fornecimento Direto
    HMSet(self:oHash, '095', 'BVQ_TPRGMN-Indicador do tipo de registro')
    HMSet(self:oHash, '096', 'B3K_CNS-Cart�o Nacional de Sa�de')
    HMSet(self:oHash, '097', 'B3K_SEXO-Sexo do benefici�rio')
    HMSet(self:oHash, '098', 'B3K_DATNAS-Data de nascimento do benefici�rio')
    HMSet(self:oHash, '099', 'B3K_CODMUN-Munic�pio de resid�ncia do benefici�rio')
    HMSet(self:oHash, '100', 'B3K_SUSEP-N�mero de identifica��o do plano do benefici�rio na ANS')
    HMSet(self:oHash, '101', 'BVQ_NMGPRE-Identificador da opera��o de fornecimento de materiais e medicamentos')
    HMSet(self:oHash, '102', 'BVQ_DTPRGU-Data do fornecimento')
    HMSet(self:oHash, '103', 'BVQ_VLTGUI-Valor total dos itens fornecidos')
    HMSet(self:oHash, '104', 'BVQ_VLTTBP-Valor total em tabela pr�pria da operadora')
    HMSet(self:oHash, '105', 'BVQ_VLTCOP-Valor total de coparticipa��o')
    HMSet(self:oHash, '106', 'BVT_CODTAB-Tabela de refer�ncia do item assistencial fornecido')
    HMSet(self:oHash, '107', 'BVT_CODGRU-C�digo do grupo do procedimento ou item assistencial')
    HMSet(self:oHash, '108', 'BVT_CODPRO-C�digo do item assistencial fornecido')
    HMSet(self:oHash, '109', 'BVT_QTDINF-Quantidade informada de itens assistenciais')
    HMSet(self:oHash, '110', 'BVT_VLPGPR-Valor do item assistencial fornecido')
    HMSet(self:oHash, '111', 'BVT_VLRCOP-Valor de coparticipa��o')
    //Outras formas de remuneracao
    HMSet(self:oHash, '112', 'BVZ_TPRGMN-Indicador do tipo de registro')
    HMSet(self:oHash, '113', 'BVZ_DTPROC-Data do processamento')
    HMSet(self:oHash, '114', 'BVZ_IDEREC-Tipo da identifica��o do recebedor ')
    HMSet(self:oHash, '115', 'BVZ_CPFCNP-N�mero de cadastro do recebedor na Receita Federal')
    HMSet(self:oHash, '116', 'BVZ_VLTINF-Valor total informado')
    HMSet(self:oHash, '117', 'BVZ_VLTGLO-Valor total de glosa')
    HMSet(self:oHash, '118', 'BVZ_VLTPAG-Valor total pago')
    HMSet(self:oHash, '119', 'B9T_COMCOB-Compet�ncia da cobertura contratada')
    HMSet(self:oHash, '120', 'B3K_CODMUN-Munic�pio de resid�ncia do benefici�rio')

Return
