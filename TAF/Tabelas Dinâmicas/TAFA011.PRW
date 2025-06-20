#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA011.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA011
Cadastro de C�digos de Servi�o (LCF 116/2003) 

@author Marcio Nunes
@since 04/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA011()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de C�digos de Servi�o (LCF 116/2003)
oBrw:SetAlias( 'C0B')
oBrw:SetMenuDef( 'TAFA011' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Marcio Nunes
@since 04/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA011" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 04/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC0B 	:= 	FWFormStruct( 1, 'C0B' )
Local oModel 	:= 	MPFormModel():New( 'TAFA011' )

oModel:AddFields('MODEL_C0B', /*cOwner*/, oStruC0B)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcio Nunes
@since 04/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA011' )
Local 	oStruC0B 	:= 	FWFormStruct( 2, 'C0B' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C0B', oStruC0B, 'MODEL_C0B' )

oView:EnableTitleView( 'VIEW_C0B', STR0001 ) //Cadastro de C�digos de Servi�o (LCF 116/2003)
oView:CreateHorizontalBox( 'FIELDSC0B', 100 )
oView:SetOwnerView( 'VIEW_C0B', 'FIELDSC0B' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1026.62

If nVerEmp < nVerAtu
	aAdd( aHeader, "C0B_FILIAL" )
	aAdd( aHeader, "C0B_ID" )
	aAdd( aHeader, "C0B_CODIGO" )
	aAdd( aHeader, "C0B_DESCRI" )
	aAdd( aHeader, "C0B_VALIDA" )

	aAdd( aBody, { "", "000009", "1001", "AGENCIAMENTO, CORRETAGEM OU INTERMEDIACAO DE CAMBIO, DE SEGUROS, DE CARTOES DE CREDITO, DE PLANOS DE SAUDE E DE PLANOS DE PREVIDENCIA PRIVADA.", "" } )
	aAdd( aBody, { "", "000010", "1002", "AGENCIAMENTO, CORRETAGEM OU INTERMEDIACAO DE TITULOS EM GERAL, VALORES MOBILIARIOS E CONTRATOS QUAISQUER.", "" } )
	aAdd( aBody, { "", "000011", "1003", "AGENCIAMENTO, CORRETAGEM OU INTERMEDIACAO DE DIREITOS DE PROPRIEDADE INDUSTRIAL, ARTISTICA OU LITERARIA.", "" } )
	aAdd( aBody, { "", "000012", "1004", "AGENCIAMENTO, CORRETAGEM OU INTERMEDIACAO DE CONTRATOS DE ARRENDAMENTO MERCANTIL (LEASING), DE FRANQUIA (FRANCHISING) E DE FATURIZACAO (FACTORING).", "" } )
	aAdd( aBody, { "", "000013", "1005", "AGENCIAMENTO, CORRETAGEM OU INTERMEDIACAO DE BENS MOVEIS OU IMOVEIS, NAO ABRANGIDOS EM OUTROS ITENS OU SUBITENS, INCLUSIVE AQUELES REALIZADOS NO AMBITO DE BOLSAS DE MERCADORIAS E FUTUROS, POR QUAISQUER MEIOS.", "" } )
	aAdd( aBody, { "", "000014", "1006", "AGENCIAMENTO MARITIMO.", "" } )
	aAdd( aBody, { "", "000015", "1007", "AGENCIAMENTO DE NOTICIAS.", "" } )
	aAdd( aBody, { "", "000016", "1008", "AGENCIAMENTO DE PUBLICIDADE E PROPAGANDA, INCLUSIVE O AGENCIAMENTO DE VEICULACAO POR QUAISQUER MEIOS.", "" } )
	aAdd( aBody, { "", "000017", "1009", "REPRESENTACAO DE QUALQUER NATUREZA, INCLUSIVE COMERCIAL.", "" } )
	aAdd( aBody, { "", "000001", "101", "ANALISE E DESENVOLVIMENTO DE SISTEMAS.", "" } )
	aAdd( aBody, { "", "000018", "1010", "DISTRIBUICAO DE BENS DE TERCEIROS.", "" } )
	aAdd( aBody, { "", "000002", "102", "PROGRAMACAO.", "" } )
	aAdd( aBody, { "", "000003", "103", "PROCESSAMENTO, ARMAZENAMENTO OU HOSPEDAGEM DE DADOS, TEXTOS, IMAGENS, V�DEOS, P�GINAS ELETR�NICAS, APLICATIVOS E SISTEMAS DE INFORMA��O, ENTRE OUTROS FORMATOS, E CONG�NERES.", "" } )
	aAdd( aBody, { "", "000004", "104", "ELABORA��O DE PROGRAMAS DE COMPUTADORES, INCLUSIVE DE JOGOS ELETR�NICOS, INDEPENDENTEMENTE DA ARQUITETURA CONSTRUTIVA DA M�QUINA EM QUE O PROGRAMA SER� EXECUTADO, INCLUINDO TABLETS, SMARTPHONES E CONG�NERES.", "" } )
	aAdd( aBody, { "", "000005", "105", "LICENCIAMENTO OU CESSAO DE DIREITO DE USO DE PROGRAMAS DE COMPUTACAO.", "" } )
	aAdd( aBody, { "", "000006", "106", "ASSESSORIA E CONSULTORIA EM INFORMATICA.", "" } )
	aAdd( aBody, { "", "000007", "107", "SUPORTE TECNICO EM INFORMATICA, INCLUSIVE INSTALACAO, CONFIGURACAO E MANUTENCAO DE PROGRAMAS DE COMPUTACAO E BANCOS DE DADOS.", "" } )
	aAdd( aBody, { "", "000008", "108", "PLANEJAMENTO, CONFECCAO, MANUTENCAO E ATUALIZACAO DE PAGINAS ELETRONICAS.", "" } )
	aAdd( aBody, { "", "000019", "1101", "GUARDA E ESTACIONAMENTO DE VEICULOS TERRESTRES AUTOMOTORES, DE AERONAVES E DE EMBARCACOES.", "" } )
	aAdd( aBody, { "", "000020", "1102", "VIGIL�NCIA, SEGURAN�A OU MONITORAMENTO DE BENS, PESSOAS E SEMOVENTES.", "" } )
	aAdd( aBody, { "", "000021", "1103", "ESCOLTA, INCLUSIVE DE VEICULOS E CARGAS.", "" } )
	aAdd( aBody, { "", "000022", "1104", "ARMAZENAMENTO, DEPOSITO, CARGA, DESCARGA, ARRUMACAO E GUARDA DE BENS DE QUALQUER ESPECIE.", "" } )
	aAdd( aBody, { "", "000023", "1201", "ESPETACULOS TEATRAIS.", "" } )
	aAdd( aBody, { "", "000024", "1202", "EXIBICOES CINEMATOGRAFICAS.", "" } )
	aAdd( aBody, { "", "000025", "1203", "ESPETACULOS CIRCENSES.", "" } )
	aAdd( aBody, { "", "000026", "1204", "PROGRAMAS DE AUDITORIO.", "" } )
	aAdd( aBody, { "", "000027", "1205", "PARQUES DE DIVERSOES, CENTROS DE LAZER E CONGENERES.", "" } )
	aAdd( aBody, { "", "000028", "1206", "BOATES, TAXI-DANCING E CONGENERES.", "" } )
	aAdd( aBody, { "", "000029", "1207", "SHOWS, BALLET, DANCAS, DESFILES, BAILES, OPERAS, CONCERTOS, RECITAIS, FESTIVAIS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000030", "1208", "FEIRAS, EXPOSICOES, CONGRESSOS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000031", "1209", "BILHARES, BOLICHES E DIVERSOES ELETRONICAS OU NAO.", "" } )
	aAdd( aBody, { "", "000032", "1210", "CORRIDAS E COMPETICOES DE ANIMAIS.", "" } )
	aAdd( aBody, { "", "000033", "1211", "COMPETICOES ESPORTIVAS OU DE DESTREZA FISICA OU INTELECTUAL, COM OU SEM A PARTICIPACAO DO ESPECTADOR.", "" } )
	aAdd( aBody, { "", "000034", "1212", "EXECUCAO DE MUSICA.", "" } )
	aAdd( aBody, { "", "000035", "1213", "PRODUCAO, MEDIANTE OU SEM ENCOMENDA PREVIA, DE EVENTOS, ESPETACULOS, ENTREVISTAS, SHOWS, BALLET, DANCAS, DESFILES, BAILES, TEATROS, OPERAS, CONCERTOS, RECITAIS, FESTIVAIS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000036", "1214", "FORNECIMENTO DE MUSICA PARA AMBIENTES FECHADOS OU NAO, MEDIANTE TRANSMISSAO POR QUALQUER PROCESSO.", "" } )
	aAdd( aBody, { "", "000037", "1215", "DESFILES DE BLOCOS CARNAVALESCOS OU FOLCLORICOS, TRIOS ELETRICOS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000038", "1216", "EXIBICAO DE FILMES, ENTREVISTAS, MUSICAIS, ESPETACULOS, SHOWS, CONCERTOS, DESFILES, OPERAS, COMPETICOES ESPORTIVAS, DE DESTREZA INTELECTUAL OU CONGENERES.", "" } )
	aAdd( aBody, { "", "000039", "1217", "RECREACAO E ANIMACAO, INCLUSIVE EM FESTAS E EVENTOS DE QUALQUER NATUREZA.", "" } )
	aAdd( aBody, { "", "000040", "1302", "FONOGRAFIA OU GRAVACAO DE SONS, INCLUSIVE TRUCAGEM, DUBLAGEM, MIXAGEM E CONGENERES.", "" } )
	aAdd( aBody, { "", "000041", "1303", "FOTOGRAFIA E CINEMATOGRAFIA, INCLUSIVE REVELACAO, AMPLIACAO, COPIA, REPRODUCAO, TRUCAGEM E CONGENERES.", "" } )
	aAdd( aBody, { "", "000042", "1304", "REPROGRAFIA, MICROFILMAGEM E DIGITALIZACAO.", "" } )
	aAdd( aBody, { "", "000043", "1305", "COMPOSI��O GR�FICA, INCLUSIVE CONFEC��O DE IMPRESSOS GR�FICOS, FOTOCOMPOSI��O, CLICHERIA, ZINCOGRAFIA, LITOGRAFIAE FOTOLITOGRAFIA, EXCETO SE DESTINADOS A POSTERIOR OPERA��O DE COMERCIALIZA��O OU INDUSTRIALIZA��O, AINDA QUE", "" } )
	aAdd( aBody, { "", "000044", "1401", "LUBRIFICACAO, LIMPEZA, LUSTRACAO, REVISAO, CARGA E RECARGA, CONSERTO, RESTAURACAO, BLINDAGEM, MANUTENCAO E CONSERVACAO DE MAQUINAS, VEICULOS, APARELHOS, EQUIPAMENTOS, MOTORES, ELEVADORES OU DE QUALQUER OBJETO (EXCETO PE", "" } )
	aAdd( aBody, { "", "000045", "1402", "ASSISTENCIA TECNICA.", "" } )
	aAdd( aBody, { "", "000046", "1403", "RECONDICIONAMENTO DE MOTORES (EXCETO PECAS E PARTES EMPREGADAS, QUE FICAM SUJEITAS AO ICMS).", "" } )
	aAdd( aBody, { "", "000047", "1404", "RECAUCHUTAGEM OU REGENERACAO DE PNEUS.", "" } )
	aAdd( aBody, { "", "000048", "1405", "RESTAURA��O, RECONDICIONAMENTO, ACONDICIONAMENTO, PINTURA, BENEFICIAMENTO, LAVAGEM, SECAGEM, TINGIMENTO, GALVANOPLASTIA, ANODIZA��O, CORTE, RECORTE, PLASTIFICA��O, COSTURA, ACABAMENTO, POLIMENTO E CONG�NERES DE OBJETOS Q", "" } )
	aAdd( aBody, { "", "000049", "1406", "INSTALACAO E MONTAGEM DE APARELHOS, MAQUINAS E EQUIPAMENTOS, INCLUSIVE MONTAGEM INDUSTRIAL, PRESTADOS AO USUARIO FINAL, EXCLUSIVAMENTE COM MATERIAL POR ELE FORNECIDO.", "" } )
	aAdd( aBody, { "", "000050", "1407", "COLOCACAO DE MOLDURAS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000051", "1408", "ENCADERNACAO, GRAVACAO E DOURACAO DE LIVROS, REVISTAS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000052", "1409", "ALFAIATARIA E COSTURA, QUANDO O MATERIAL FOR FORNECIDO PELO USUARIO FINAL, EXCETO AVIAMENTO.", "" } )
	aAdd( aBody, { "", "000053", "1410", "TINTURARIA E LAVANDERIA.", "" } )
	aAdd( aBody, { "", "000054", "1411", "TAPECARIA E REFORMA DE ESTOFAMENTOS EM GERAL.", "" } )
	aAdd( aBody, { "", "000055", "1412", "FUNILARIA E LANTERNAGEM.", "" } )
	aAdd( aBody, { "", "000056", "1413", "CARPINTARIA E SERRALHERIA.", "" } )
	aAdd( aBody, { "", "000057", "1501", "ADMINISTRACAO DE FUNDOS QUAISQUER, DE CONSORCIO, DE CARTAO DE CREDITO OU DEBITO E CONGENERES, DE CARTEIRA DE CLIENTES, DE CHEQUES PRE-DATADOS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000058", "1502", "ABERTURA DE CONTAS EM GERAL, INCLUSIVE CONTA-CORRENTE, CONTA DE INVESTIMENTOS E APLICACAO E CADERNETA DE POUPANCA, NO PAIS E NO EXTERIOR, BEM COMO A MANUTENCAO DAS REFERIDAS CONTAS ATIVAS E INATIVAS.", "" } )
	aAdd( aBody, { "", "000059", "1503", "LOCACAO E MANUTENCAO DE COFRES PARTICULARES, DE TERMINAIS ELETRONICOS, DE TERMINAIS DE ATENDIMENTO E DE BENS E EQUIPAMENTOS EM GERAL.", "" } )
	aAdd( aBody, { "", "000060", "1504", "FORNECIMENTO OU EMISSAO DE ATESTADOS EM GERAL, INCLUSIVE ATESTADO DE IDONEIDADE, ATESTADO DE CAPACIDADE FINANCEIRA E CONGENERES.", "" } )
	aAdd( aBody, { "", "000061", "1505", "CADASTRO, ELABORACAO DE FICHA CADASTRAL, RENOVACAO CADASTRAL E CONGENERES, INCLUSAO OU EXCLUSAO NO CADASTRO DE EMITENTES DE CHEQUES SEM FUNDOS CCF OU EM QUAISQUER OUTROS BANCOS CADASTRAIS.", "" } )
	aAdd( aBody, { "", "000062", "1506", "EMISSAO, REEMISSAO E FORNECIMENTO DE AVISOS, COMPROVANTES E DOCUMENTOS EM GERAL; ABONO DE FIRMAS; COLETA E ENTREGA DE DOCUMENTOS, BENS E VALORES; COMUNICACAO COM OUTRA AGENCIA OU COM A ADMINISTRACAO CENTRAL; LICENCIAMEN", "" } )
	aAdd( aBody, { "", "000063", "1507", "ACESSO, MOVIMENTACAO, ATENDIMENTO E CONSULTA A CONTAS EM GERAL, POR QUALQUER MEIO OU PROCESSO, INCLUSIVE POR TELEFONE, FAC-SIMILE, INTERNET E TELEX, ACESSO A TERMINAIS DE ATENDIMENTO, INCLUSIVE VINTE E QUATRO HORAS; ACE", "" } )
	aAdd( aBody, { "", "000064", "1508", "EMISSAO, REEMISSAO, ALTERACAO, CESSAO, SUBSTITUICAO, CANCELAMENTO E REGISTRO DE CONTRATO DE CREDITO; ESTUDO, ANALISE E AVALIACAO DE OPERACOES DE CREDITO; EMISSAO, CONCESSAO, ALTERACAO OU CONTRATACAO DE AVAL, FIANCA, ANU", "" } )
	aAdd( aBody, { "", "000065", "1509", "ARRENDAMENTO MERCANTIL (LEASING) DE QUAISQUER BENS, INCLUSIVE CESSAO DE DIREITOS E OBRIGACOES, SUBSTITUICAO DE GARANTIA, ALTERACAO, CANCELAMENTO E REGISTRO DE CONTRATO, E DEMAIS SERVICOS RELACIONADOS AO ARRENDAMENTO MER", "" } )
	aAdd( aBody, { "", "000066", "1510", "SERVICOS RELACIONADOS A COBRANCAS, RECEBIMENTOS OU PAGAMENTOS EM GERAL, DE TITULOS QUAISQUER, DE CONTAS OU CARNES, DE CAMBIO, DE TRIBUTOS E POR CONTA DE TERCEIROS, INCLUSIVE OS EFETUADOS POR MEIO ELETRONICO, AUTOMATICO", "" } )
	aAdd( aBody, { "", "000067", "1511", "DEVOLUCAO DE TITULOS, PROTESTO DE TITULOS, SUSTACAO DE PROTESTO, MANUTENCAO DE TITULOS, REAPRESENTACAO DE TITULOS, E DEMAIS SERVICOS A ELES RELACIONADOS.", "" } )
	aAdd( aBody, { "", "000068", "1512", "CUSTODIA EM GERAL, INCLUSIVE DE TITULOS E VALORES MOBILIARIOS.", "" } )
	aAdd( aBody, { "", "000069", "1513", "SERVICOS RELACIONADOS A OPERACOES DE CAMBIO EM GERAL, EDICAO, ALTERACAO, PRORROGACAO, CANCELAMENTO E BAIXA DE CONTRATO DE CAMBIO; EMISSAO DE REGISTRO DE EXPORTACAO OU DE CREDITO; COBRANCA OU DEPOSITO NO EXTERIOR; EMISSA", "" } )
	aAdd( aBody, { "", "000070", "1514", "FORNECIMENTO, EMISSAO, REEMISSAO, RENOVACAO E MANUTENCAO DE CARTAO MAGNETICO, CARTAO DE CREDITO, CARTAO DE DEBITO, CARTAO SALARIO E CONGENERES.", "" } )
	aAdd( aBody, { "", "000071", "1515", "COMPENSACAO DE CHEQUES E TITULOS QUAISQUER; SERVICOS RELACIONADOS A DEPOSITO, INCLUSIVE DEPOSITO IDENTIFICADO, A SAQUE DE CONTAS QUAISQUER, POR QUALQUER MEIO OU PROCESSO, INCLUSIVE EM TERMINAIS ELETRONICOS E DE ATENDIME", "" } )
	aAdd( aBody, { "", "000072", "1516", "EMISSAO, REEMISSAO, LIQUIDACAO, ALTERACAO, CANCELAMENTO E BAIXA DE ORDENS DE PAGAMENTO, ORDENS DE CREDITO E SIMILARES, POR QUALQUER MEIO OU PROCESSO; SERVICOS RELACIONADOS A TRANSFERENCIA DE VALORES, DADOS, FUNDOS, PAGA", "" } )
	aAdd( aBody, { "", "000073", "1517", "EMISSAO, FORNECIMENTO, DEVOLUCAO, SUSTACAO, CANCELAMENTO E OPOSICAO DE CHEQUES QUAISQUER, AVULSO OU POR TALAO.", "" } )
	aAdd( aBody, { "", "000074", "1518", "SERVICOS RELACIONADOS A CREDITO IMOBILIARIO, AVALIACAO E VISTORIA DE IMOVEL OU OBRA, ANALISE TECNICA E JURIDICA, EMISSAO, REEMISSAO, ALTERACAO, TRANSFERENCIA E RENEGOCIACAO DE CONTRATO, EMISSAO E REEMISSAO DO TERMO DE Q", "" } )
	aAdd( aBody, { "", "000075", "1601", "SERVI�OS DE TRANSPORTE COLETIVO MUNICIPAL RODOVI�RIO, METROVI�RIO, FERROVI�RIO E AQUAVI�RIO DE PASSAGEIROS.", "" } )
	aAdd( aBody, { "", "000076", "1701", "ASSESSORIA OU CONSULTORIA DE QUALQUER NATUREZA, NAO CONTIDA EM OUTROS ITENS DESTA LISTA; ANALISE, EXAME, PESQUISA, COLETA, COMPILACAO E FORNECIMENTO DE DADOS E INFORMACOES DE QUALQUER NATUREZA, INCLUSIVE CADASTRO E SIMI", "" } )
	aAdd( aBody, { "", "000077", "1702", "DATILOGRAFIA, DIGITACAO, ESTENOGRAFIA, EXPEDIENTE, SECRETARIA EM GERAL, RESPOSTA AUDIVEL, REDACAO, EDICAO, INTERPRETACAO, REVISAO, TRADUCAO, APOIO E INFRA-ESTRUTURA ADMINISTRATIVA E CONGENERES.", "" } )
	aAdd( aBody, { "", "000078", "1703", "PLANEJAMENTO, COORDENACAO, PROGRAMACAO OU ORGANIZACAO TECNICA, FINANCEIRA OU ADMINISTRATIVA.", "" } )
	aAdd( aBody, { "", "000079", "1704", "RECRUTAMENTO, AGENCIAMENTO, SELECAO E COLOCACAO DE MAO-DE-OBRA.", "" } )
	aAdd( aBody, { "", "000080", "1705", "FORNECIMENTO DE MAO-DE-OBRA, MESMO EM CARATER TEMPORARIO, INCLUSIVE DE EMPREGADOS OU TRABALHADORES, AVULSOS OU TEMPORARIOS, CONTRATADOS PELO PRESTADOR DE SERVICO.", "" } )
	aAdd( aBody, { "", "000081", "1706", "PROPAGANDA E PUBLICIDADE, INCLUSIVE PROMOCAO DE VENDAS, PLANEJAMENTO DE CAMPANHAS OU SISTEMAS DE PUBLICIDADE, ELABORACAO DE DESENHOS, TEXTOS E DEMAIS MATERIAIS PUBLICITARIOS.", "" } )
	aAdd( aBody, { "", "000082", "1708", "FRANQUIA (FRANCHISING).", "" } )
	aAdd( aBody, { "", "000083", "1709", "PERICIAS, LAUDOS, EXAMES TECNICOS E ANALISES TECNICAS.", "" } )
	aAdd( aBody, { "", "000084", "1710", "PLANEJAMENTO, ORGANIZACAO E ADMINISTRACAO DE FEIRAS, EXPOSICOES, CONGRESSOS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000085", "1711", "ORGANIZACAO DE FESTAS E RECEPCOES; BUFE (EXCETO O FORNECIMENTO DE ALIMENTACAO E BEBIDAS, QUE FICA SUJEITO AO ICMS).", "" } )
	aAdd( aBody, { "", "000086", "1712", "ADMINISTRACAO EM GERAL, INCLUSIVE DE BENS E NEGOCIOS DE TERCEIROS.", "" } )
	aAdd( aBody, { "", "000087", "1713", "LEILAO E CONGENERES.", "" } )
	aAdd( aBody, { "", "000088", "1714", "ADVOCACIA.", "" } )
	aAdd( aBody, { "", "000089", "1715", "ARBITRAGEM DE QUALQUER ESPECIE, INCLUSIVE JURIDICA.", "" } )
	aAdd( aBody, { "", "000090", "1716", "AUDITORIA.", "" } )
	aAdd( aBody, { "", "000091", "1717", "ANALISE DE ORGANIZACAO E METODOS.", "" } )
	aAdd( aBody, { "", "000092", "1718", "ATUARIA E CALCULOS TECNICOS DE QUALQUER NATUREZA.", "" } )
	aAdd( aBody, { "", "000093", "1719", "CONTABILIDADE, INCLUSIVE SERVICOS TECNICOS E AUXILIARES.", "" } )
	aAdd( aBody, { "", "000094", "1720", "CONSULTORIA E ASSESSORIA ECONOMICA OU FINANCEIRA.", "" } )
	aAdd( aBody, { "", "000095", "1721", "ESTATISTICA.", "" } )
	aAdd( aBody, { "", "000096", "1722", "COBRANCA EM GERAL.", "" } )
	aAdd( aBody, { "", "000097", "1723", "ASSESSORIA, ANALISE, AVALIACAO, ATENDIMENTO, CONSULTA, CADASTRO, SELECAO, GERENCIAMENTO DE INFORMACOES, ADMINISTRACAO DE CONTAS A RECEBER OU A PAGAR E EM GERAL, RELACIONADOS A OPERACOES DE FATURIZACAO (FACTORING).", "" } )
	aAdd( aBody, { "", "000098", "1724", "APRESENTACAO DE PALESTRAS, CONFERENCIAS, SEMINARIOS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000099", "1801", "SERVICOS DE REGULACAO DE SINISTROS VINCULADOS A CONTRATOS DE SEGUROS; INSPECAO E AVALIACAO DE RISCOS PARA COBERTURA DE CONTRATOS DE SEGUROS; PREVENCAO E GERENCIA DE RISCOS SEGURAVEIS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000100", "1901", "SERVICOS DE DISTRIBUICAO E VENDA DE BILHETES E DEMAIS PRODUTOS DE LOTERIA, BINGOS, CARTOES, PULES OU CUPONS DE APOSTAS, SORTEIOS, PREMIOS, INCLUSIVE OS DECORRENTES DE TITULOS DE CAPITALIZACAO E CONGENERES.", "" } )
	aAdd( aBody, { "", "000102", "2001", "SERVICOS PORTUARIOS, FERROPORTUARIOS, UTILIZACAO DE PORTO, MOVIMENTACAO DE PASSAGEIROS, REBOQUE DE EMBARCACOES, REBOCADOR ESCOTEIRO, ATRACACAO, DESATRACACAO, SERVICOS DE PRATICAGEM, CAPATAZIA, ARMAZENAGEM DE QUALQUER NA", "" } )
	aAdd( aBody, { "", "000103", "2002", "SERVICOS AEROPORTUARIOS, UTILIZACAO DE AEROPORTO, MOVIMENTACAO DE PASSAGEIROS, ARMAZENAGEM DE QUALQUER NATUREZA, CAPATAZIA, MOVIMENTACAO DE AERONAVES, SERVICOS DE APOIO AEROPORTUARIOS, SERVICOS ACESSORIOS, MOVIMENTACAO", "" } )
	aAdd( aBody, { "", "000104", "2003", "SERVICOS DE TERMINAIS RODOVIARIOS, FERROVIARIOS, METROVIARIOS, MOVIMENTACAO DE PASSAGEIROS, MERCADORIAS, INCLUSIVE     SUAS OPERACOES, LOGISTICA E CONGENERES.", "" } )
	aAdd( aBody, { "", "000101", "201",  "SERVICOS DE PESQUISAS E DESENVOLVIMENTO DE QUALQUER NATUREZA.", "" } )
	aAdd( aBody, { "", "000105", "2101", "SERVICOS DE REGISTROS PUBLICOS, CARTORARIOS E NOTARIAIS.", "" } )
	aAdd( aBody, { "", "000106", "2201", "SERVICOS DE EXPLORACAO DE RODOVIA MEDIANTE COBRANCA DE PRECO OU PEDAGIO DOS USUARIOS, ENVOLVENDO EXECUCAO DE SERVICOS DE CONSERVACAO, MANUTENCAO, MELHORAMENTOS PARA ADEQUACAO DE CAPACIDADE E SEGURANCA DE TRANSITO, OPERA", "" } )
	aAdd( aBody, { "", "000107", "2301", "SERVICOS DE PROGRAMACAO E COMUNICACAO VISUAL, DESENHO INDUSTRIAL E CONGENERES.", "" } )
	aAdd( aBody, { "", "000108", "2401", "SERVICOS DE CHAVEIROS, CONFECCAO DE CARIMBOS, PLACAS, SINALIZACAO VISUAL, BANNERS, ADESIVOS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000109", "2501", "FUNERAIS, INCLUSIVE FORNECIMENTO DE CAIXAO, URNA OU ESQUIFES; ALUGUEL DE CAPELA; TRANSPORTE DO CORPO CADAVERICO; FORNECIMENTO DE FLORES, COROAS E OUTROS PARAMENTOS; DESEMBARACO DE CERTIDAO DE OBITO; FORNECIMENTO DE VEU,", "" } )
	aAdd( aBody, { "", "000110", "2502", "TRANSLADO INTRAMUNICIPAL E CREMA��O DE CORPOS E PARTES DE CORPOS CADAV�RICOS.", "" } )
	aAdd( aBody, { "", "000111", "2503", "PLANOS OU CONVENIO FUNERARIOS.", "" } )
	aAdd( aBody, { "", "000112", "2504", "MANUTENCAO E CONSERVACAO DE JAZIGOS E CEMITERIOS.", "" } )
	aAdd( aBody, { "", "000113", "2601", "SERVICOS DE COLETA, REMESSA OU ENTREGA DE CORRESPONDENCIAS, DOCUMENTOS, OBJETOS, BENS OU VALORES, INCLUSIVE PELOS CORREIOS E SUAS AGENCIAS FRANQUEADAS; COURRIER E CONGENERES.", "" } )
	aAdd( aBody, { "", "000114", "2701", "SERVICOS DE ASSISTENCIA SOCIAL.", "" } )
	aAdd( aBody, { "", "000115", "2801", "SERVICOS DE AVALIACAO DE BENS E SERVICOS DE QUALQUER NATUREZA.", "" } )
	aAdd( aBody, { "", "000116", "2901", "SERVICOS DE BIBLIOTECONOMIA.", "" } )
	aAdd( aBody, { "", "000121", "3001", "SERVICOS DE BIOLOGIA, BIOTECNOLOGIA E QUIMICA.", "" } )
	aAdd( aBody, { "", "000117", "302", "CESSAO DE DIREITO DE USO DE MARCAS E DE SINAIS DE PROPAGANDA.", "" } )
	aAdd( aBody, { "", "000118", "303", "EXPLORACAO DE SALOES DE FESTAS, CENTRO DE CONVENCOES, ESCRITORIOS VIRTUAIS, STANDS, QUADRAS ESPORTIVAS, ESTADIOS, GINASIOS, AUDITORIOS, CASAS DE ESPETACULOS, PARQUES DE DIVERSOES, CANCHAS E CONGENERES, PARA REALIZACAO D", "" } )
	aAdd( aBody, { "", "000119", "304", "LOCACAO, SUBLOCACAO, ARRENDAMENTO, DIREITO DE PASSAGEM OU PERMISSAO DE USO, COMPARTILHADO OU NAO, DE FERROVIA, RODOVIA, POSTES, CABOS, DUTOS E CONDUTOS DE QUALQUER NATUREZA.", "" } )
	aAdd( aBody, { "", "000120", "305", "CESSAO DE ANDAIMES, PALCOS, COBERTURAS E OUTRAS ESTRUTURAS DE USO TEMPORARIO.", "" } )
	aAdd( aBody, { "", "000122", "3101", "SERVICOS TECNICOS EM EDIFICACOES, ELETRONICA, ELETROTECNICA, MECANICA, TELECOMUNICACOES E CONGENERES.", "" } )
	aAdd( aBody, { "", "000123", "3201", "SERVICOS DE DESENHOS TECNICOS.", "" } )
	aAdd( aBody, { "", "000124", "3301", "SERVICOS DE DESEMBARACO ADUANEIRO, COMISSARIOS, DESPACHANTES E CONGENERES.", "" } )
	aAdd( aBody, { "", "000125", "3401", "SERVICOS DE INVESTIGACOES PARTICULARES, DETETIVES E CONGENERES.", "" } )
	aAdd( aBody, { "", "000126", "3501", "SERVICOS DE REPORTAGEM, ASSESSORIA DE IMPRENSA, JORNALISMO E RELACOES PUBLICAS.", "" } )
	aAdd( aBody, { "", "000127", "3601", "SERVICOS DE METEOROLOGIA.", "" } )
	aAdd( aBody, { "", "000128", "3701", "SERVICOS DE ARTISTAS, ATLETAS, MODELOS E MANEQUINS.", "" } )
	aAdd( aBody, { "", "000129", "3801", "SERVICOS DE MUSEOLOGIA.", "" } )
	aAdd( aBody, { "", "000130", "3901", "SERVICOS DE OURIVESARIA E LAPIDACAO (QUANDO O MATERIAL FOR FORNECIDO PELO TOMADOR DO SERVICO).", "" } )
	aAdd( aBody, { "", "000154", "4001", "OBRAS DE ARTE SOB ENCOMENDA.", "" } )
	aAdd( aBody, { "", "000131", "401", "MEDICINA E BIOMEDICINA.", "" } )
	aAdd( aBody, { "", "000132", "402", "ANALISES CLINICAS, PATOLOGIA, ELETRICIDADE MEDICA, RADIOTERAPIA, QUIMIOTERAPIA, ULTRA-SONOGRAFIA, RESSONANCIA MAGNETICA, RADIOLOGIA, TOMOGRAFIA E CONGENERES.", "" } )
	aAdd( aBody, { "", "000133", "403", "HOSPITAIS, CLINICAS, LABORATORIOS, SANATORIOS, MANICOMIOS, CASAS DE SAUDE, PRONTOS-SOCORROS, AMBULATORIOS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000134", "404", "INSTRUMENTACAO CIRURGICA.", "" } )
	aAdd( aBody, { "", "000135", "405", "ACUPUNTURA.", "" } )
	aAdd( aBody, { "", "000136", "406", "ENFERMAGEM, INCLUSIVE SERVICOS AUXILIARES.", "" } )
	aAdd( aBody, { "", "000137", "407", "SERVICOS FARMACEUTICOS.", "" } )
	aAdd( aBody, { "", "000138", "408", "TERAPIA OCUPACIONAL, FISIOTERAPIA E FONOAUDIOLOGIA.", "" } )
	aAdd( aBody, { "", "000139", "409", "TERAPIAS DE QUALQUER ESPECIE DESTINADAS AO TRATAMENTO FISICO, ORGANICO E MENTAL.", "" } )
	aAdd( aBody, { "", "000140", "410", "NUTRICAO.", "" } )
	aAdd( aBody, { "", "000141", "411", "OBSTETRICIA.", "" } )
	aAdd( aBody, { "", "000142", "412", "ODONTOLOGIA.", "" } )
	aAdd( aBody, { "", "000143", "413", "ORTOPTICA.", "" } )
	aAdd( aBody, { "", "000144", "414", "PROTESES SOB ENCOMENDA.", "" } )
	aAdd( aBody, { "", "000145", "415", "PSICANALISE.", "" } )
	aAdd( aBody, { "", "000146", "416", "PSICOLOGIA.", "" } )
	aAdd( aBody, { "", "000147", "417", "CASAS DE REPOUSO E DE RECUPERACAO, CRECHES, ASILOS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000148", "418", "INSEMINACAO ARTIFICIAL, FERTILIZACAO IN VITRO E CONGENERES.", "" } )
	aAdd( aBody, { "", "000149", "419", "BANCOS DE SANGUE, LEITE, PELE, OLHOS, OVULOS, SEMEN E CONGENERES.", "" } )
	aAdd( aBody, { "", "000150", "420", "COLETA DE SANGUE, LEITE, TECIDOS, SEMEN, ORGAOS E MATERIAIS BIOLOGICOS DE QUALQUER ESPECIE.", "" } )
	aAdd( aBody, { "", "000151", "421", "UNIDADE DE ATENDIMENTO, ASSISTENCIA OU TRATAMENTO MOVEL E CONGENERES.", "" } )
	aAdd( aBody, { "", "000152", "422", "PLANOS DE MEDICINA DE GRUPO OU INDIVIDUAL E CONVENIOS PARA PRESTACAO DE ASSISTENCIA MEDICA, HOSPITALAR, ODONTOLOGICA E CONGENERES.", "" } )
	aAdd( aBody, { "", "000153", "423", "OUTROS PLANOS DE SAUDE QUE SE CUMPRAM ATRAVES DE SERVICOS DE TERCEIROS CONTRATADOS, CREDENCIADOS, COOPERADOS OU APENAS PAGOS PELO OPERADOR DO PLANO MEDIANTE INDICACAO DO BENEFICIARIO.", "" } )
	aAdd( aBody, { "", "000155", "501", "MEDICINA VETERINARIA E ZOOTECNIA.", "" } )
	aAdd( aBody, { "", "000156", "502", "HOSPITAIS, CLINICAS, AMBULATORIOS, PRONTOS-SOCORROS E CONGENERES, NA AREA VETERINARIA.", "" } )
	aAdd( aBody, { "", "000157", "503", "LABORATORIOS DE ANALISE NA AREA VETERINARIA.", "" } )
	aAdd( aBody, { "", "000158", "504", "INSEMINACAO ARTIFICIAL, FERTILIZACAO IN VITRO E CONGENERES.", "" } )
	aAdd( aBody, { "", "000159", "505", "BANCOS DE SANGUE E DE ORGAOS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000160", "506", "COLETA DE SANGUE, LEITE, TECIDOS, SEMEN, ORGAOS E MATERIAIS BIOLOGICOS DE QUALQUER ESPECIE.", "" } )
	aAdd( aBody, { "", "000161", "507", "UNIDADE DE ATENDIMENTO, ASSISTENCIA OU TRATAMENTO MOVEL E CONGENERES.", "" } )
	aAdd( aBody, { "", "000162", "508", "GUARDA, TRATAMENTO, AMESTRAMENTO, EMBELEZAMENTO, ALOJAMENTO E CONGENERES.", "" } )
	aAdd( aBody, { "", "000163", "509", "PLANOS DE ATENDIMENTO E ASSISTENCIA MEDICO-VETERINARIA.", "" } )
	aAdd( aBody, { "", "000164", "601", "BARBEARIA, CABELEIREIROS, MANICUROS, PEDICUROS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000165", "602", "ESTETICISTAS, TRATAMENTO DE PELE, DEPILACAO E CONGENERES.", "" } )
	aAdd( aBody, { "", "000166", "603", "BANHOS, DUCHAS, SAUNA, MASSAGENS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000167", "604", "GINASTICA, DANCA, ESPORTES, NATACAO, ARTES MARCIAIS E DEMAIS ATIVIDADES FISICAS.", "" } )
	aAdd( aBody, { "", "000168", "605", "CENTROS DE EMAGRECIMENTO, SPA E CONGENERES.", "" } )
	aAdd( aBody, { "", "000169", "701", "ENGENHARIA, AGRONOMIA, AGRIMENSURA, ARQUITETURA, GEOLOGIA, URBANISMO, PAISAGISMO E CONGENERES.", "" } )
	aAdd( aBody, { "", "000170", "702", "EXECUCAO, POR ADMINISTRACAO, EMPREITADA OU SUBEMPREITADA, DE OBRAS DE CONSTRUCAO CIVIL, HIDRAULICA OU ELETRICA E DE OUTRAS OBRAS SEMELHANTES, INCLUSIVE SONDAGEM, PERFURACAO DE POCOS, ESCAVACAO, DRENAGEM E IRRIGACAO, TER", "" } )
	aAdd( aBody, { "", "000171", "703", "ELABORACAO DE PLANOS DIRETORES, ESTUDOS DE VIABILIDADE, ESTUDOS ORGANIZACIONAIS E OUTROS, RELACIONADOS COM OBRAS E SERVICOS DE ENGENHARIA; ELABORACAO DE ANTEPROJETOS, PROJETOS BASICOS E PROJETOS EXECUTIVOS PARA TRABALHO", "" } )
	aAdd( aBody, { "", "000172", "704", "DEMOLICAO.", "" } )
	aAdd( aBody, { "", "000173", "705", "REPARACAO, CONSERVACAO E REFORMA DE EDIFICIOS, ESTRADAS, PONTES, PORTOS E CONGENERES (EXCETO O FORNECIMENTO DE MERCADORIAS PRODUZIDAS PELO PRESTADOR DOS SERVICOS, FORA DO LOCAL DA PRESTACAO DOS SERVICOS, QUE FICA SUJEIT", "" } )
	aAdd( aBody, { "", "000174", "706", "COLOCACAO E INSTALACAO DE TAPETES, CARPETES, ASSOALHOS, CORTINAS, REVESTIMENTOS DE PAREDE, VIDROS, DIVISORIAS, PLACAS DE GESSO E CONGENERES, COM MATERIAL FORNECIDO PELO TOMADOR DO SERVICO.", "" } )
	aAdd( aBody, { "", "000175", "707", "RECUPERACAO, RASPAGEM, POLIMENTO E LUSTRACAO DE PISOS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000176", "708", "CALAFETACAO.", "" } )
	aAdd( aBody, { "", "000177", "709", "VARRICAO, COLETA, REMOCAO, INCINERACAO, TRATAMENTO, RECICLAGEM, SEPARACAO E DESTINACAO FINAL DE LIXO, REJEITOS E OUTROS RESIDUOS QUAISQUER.", "" } )
	aAdd( aBody, { "", "000178", "710", "LIMPEZA, MANUTENCAO E CONSERVACAO DE VIAS E LOGRADOUROS PUBLICOS, IMOVEIS, CHAMINES, PISCINAS, PARQUES, JARDINS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000179", "711", "DECORACAO E JARDINAGEM, INCLUSIVE CORTE E PODA DE ARVORES.", "" } )
	aAdd( aBody, { "", "000180", "712", "CONTROLE E TRATAMENTO DE EFLUENTES DE QUALQUER NATUREZA E DE AGENTES FISICOS, QUIMICOS E BIOLOGICOS.", "" } )
	aAdd( aBody, { "", "000181", "713", "DEDETIZACAO, DESINFECCAO, DESINSETIZACAO, IMUNIZACAO, HIGIENIZACAO, DESRATIZACAO, PULVERIZACAO E CONGENERES.", "" } )
	aAdd( aBody, { "", "000182", "716", "FLORESTAMENTO, REFLORESTAMENTO, SEMEADURA, ADUBA��O, REPARA��O DE SOLO, PLANTIO, SILAGEM, COLHEITA, CORTE E DESCASCAMENTO DE �RVORES, SILVICULTURA, EXPLORA��O FLORESTAL E DOS SERVI�OS CONG�NERES INDISSOCI�VEIS DA FORMA��", "" } )
	aAdd( aBody, { "", "000183", "717", "ESCORAMENTO, CONTENCAO DE ENCOSTAS E SERVICOS CONGENERES.", "" } )
	aAdd( aBody, { "", "000184", "718", "LIMPEZA E DRAGAGEM DE RIOS, PORTOS, CANAIS, BAIAS, LAGOS, LAGOAS, REPRESAS, ACUDES E CONGENERES.", "" } )
	aAdd( aBody, { "", "000185", "719", "ACOMPANHAMENTO E FISCALIZACAO DA EXECUCAO DE OBRAS DE ENGENHARIA, ARQUITETURA E URBANISMO.", "" } )
	aAdd( aBody, { "", "000186", "720", "AEROFOTOGRAMETRIA (INCLUSIVE INTERPRETACAO), CARTOGRAFIA, MAPEAMENTO, LEVANTAMENTOS TOPOGRAFICOS, BATIMETRICOS, GEOGRAFICOS, GEODESICOS, GEOLOGICOS, GEOFISICOS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000187", "721", "PESQUISA, PERFURACAO, CIMENTACAO, MERGULHO, PERFILAGEM, CONCRETACAO, TESTEMUNHAGEM, PESCARIA, ESTIMULACAO E OUTROS SERVICOS RELACIONADOS COM A EXPLORACAO E EXPLOTACAO DE PETROLEO, GAS NATURAL E DE OUTROS RECURSOS MINERA", "" } )
	aAdd( aBody, { "", "000188", "722", "NUCLEACAO E BOMBARDEAMENTO DE NUVENS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000189", "801", "ENSINO REGULAR PRE-ESCOLAR, FUNDAMENTAL, MEDIO E SUPERIOR.", "" } )
	aAdd( aBody, { "", "000190", "802", "INSTRUCAO, TREINAMENTO, ORIENTACAO PEDAGOGICA E EDUCACIONAL, AVALIACAO DE CONHECIMENTOS DE QUALQUER NATUREZA.", "" } )
	aAdd( aBody, { "", "000191", "901", "HOSPEDAGEM DE QUALQUER NATUREZA EM HOTEIS, APART-SERVICE CONDOMINIAIS, FLAT, APART-HOTEIS, HOTEIS RESIDENCIA, RESIDENCE-SERVICE, SUITE SERVICE, HOTELARIA MARITIMA, MOTEIS, PENSOES E CONGENERES; OCUPACAO POR TEMPORADA CO", "" } )
	aAdd( aBody, { "", "000192", "902", "AGENCIAMENTO, ORGANIZACAO, PROMOCAO, INTERMEDIACAO E EXECUCAO DE PROGRAMAS DE TURISMO, PASSEIOS, VIAGENS, EXCURSOES, HOSPEDAGENS E CONGENERES.", "" } )
	aAdd( aBody, { "", "000193", "903", "GUIAS DE TURISMO.", "" } )
	aAdd( aBody, { "", "000194", "1602", "OUTROS SERVI�OS DE TRANSPORTE DE NATUREZA MUNICIPAL.", "" } ) 
	aAdd( aBody, { "", "000195", "1301", "FONOGRAFIA OU GRAVA��O DE SONS, INCLUSIVE TRUCAGEM, DUBLAGEM, MIXAGEM E CONG�NERES. ", "" } )
	aAdd( aBody, { "", "000196", "1414", "GUINCHO INTRAMUNICIPAL, GUINDASTE E I�AMENTO.", "" } )
	aAdd( aBody, { "", "000197", "109",  "DISPONIBILIZA��O, SEM CESS�O DEFINITIVA, DE CONTE�DOS DE �UDIO, V�DEO, IMAGEM E TEXTO POR MEIO DA INTERNET, RESPEITADA A IMUNIDADE DE LIVROS, JORNAIS E PERI�DICOS (EXCETO A DISTRIBUI��O DE CONTE�DOS PELAS PRESTADORAS DE", "" } )
	aAdd( aBody, { "", "000198", "606",  "APLICA��O DE TATUAGENS, PIERCINGS E CONG�NERES.", "" } )
	aAdd( aBody, { "", "000199", "1725", "INSER��O DE TEXTOS, DESENHOS E OUTROS MATERIAIS DE PROPAGANDA E PUBLICIDADE, EM QUALQUER MEIO (EXCETO EM LIVROS, JORNAIS, PERI�DICOS E NAS MODALIDADES DE SERVI�OS DE RADIODIFUS�O SONORA E DE SONS E IMAGENS DE RECEP��O LI", "" } )
	aAdd( aBody, { "", "000200", "2505", "CESS�O DE USO DE ESPA�OS EM CEMIT�RIOS PARA SEPULTAMENTO.", "" } )
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet ) 