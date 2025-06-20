#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA212.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA212

Cadastro MVC das Categorias de Trabalhadores do eSocial
Tabela 01

@author Felipe C. Seolin
@since 06/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA212()

	Local oBrw := FwMBrowse():New()

	oBrw:SetDescription(STR0001) //"Cadastro das Categorias de Trabalhadores"
	oBrw:SetAlias("C87")
	oBrw:SetMenuDef("TAFA212")
	oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Felipe C. Seolin
@since 06/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return(xFunMnuTAF("TAFA212"))

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Felipe C. Seolin
@since 06/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruC87 := FwFormStruct(1,"C87")
	Local oModel   := MpFormModel():New("TAFA212")

	oModel:AddFields("MODEL_C87",/*cOwner*/,oStruC87)
	oModel:GetModel("MODEL_C87"):SetPrimaryKey({"C87_FILIAL","C87_ID"})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Felipe C. Seolin
@since 06/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   := FwLoadModel("TAFA212")
	Local oStruC87 := FwFormStruct(2,"C87")
	Local oView    := FwFormView():New()

	oView:SetModel(oModel)
	oView:AddField("VIEW_C87",oStruC87,"MODEL_C87")

	oView:EnableTitleView("VIEW_C87",STR0001) //"Cadastro das Categorias de Trabalhadores")
	oView:CreateHorizontalBox("FIELDSC87",100)
	oView:SetOwnerView("VIEW_C87","FIELDSC87")

Return(oView)

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
Static Function FAtuCont( nVerEmp as numeric, nVerAtu as numeric )

	Local aHeader as array
	Local aBody   as array
	Local aRet    as array

	aHeader := {}
	aBody   := {}
	aRet    := {}

	nVerAtu := 1033.16

	If nVerEmp < nVerAtu
	
		aAdd( aHeader, "C87_FILIAL" )
		aAdd( aHeader, "C87_ID" 	)
		aAdd( aHeader, "C87_CODIGO" )
		aAdd( aHeader, "C87_DESCRI" )
		aAdd( aHeader, "C87_VALIDA" )
		aAdd( aHeader, "C87_ALTCON" )

		//Empregado e Trabalhador Tempor�rio
		aAdd( aBody, { "", "000001", "101", "EMPREGADO � GERAL INCLUSIVE O EMPREGADO P�BLICO DA ADMINISTRA��O DIRETA OU INDIRETA CONTRATADO PELA CLT.", "" } )
		aAdd( aBody, { "", "000002", "102", "EMPREGADO � TRABALHADOR RURAL POR PEQUENO PRAZO DA LEI 11.718/2008", "" } )
		aAdd( aBody, { "", "000003", "103", "EMPREGADO � APRENDIZ", "" } )
		aAdd( aBody, { "", "000004", "104", "EMPREGADO � DOM�STICO", "" } )
		aAdd( aBody, { "", "000005", "105", "EMPREGADO � CONTRATO A TERMO FIRMADO NOS TERMOS DA LEI 9601/98", "" } )
		aAdd( aBody, { "", "000006", "106", "TRABALHADOR TEMPOR�RIO - CONTRATO NOS TERMOS DA LEI 6.019/74", "" } )
		aAdd( aBody, { "", "000007", "107", "TRABALHADOR NAO VINCULADO AO RGPS COM DIREITO AO FGTS", "20191231" } )
		
		//Avulso
		aAdd( aBody, { "", "000008", "201", "TRABALHADOR AVULSO � PORTUARIO", "" } )
		aAdd( aBody, { "", "000009", "202", "TRABALHADOR AVULSO � N�O PORTU�RIO", "" } )
		aAdd( aBody, { "", "000010", "203", "TRABALHADOR AVULSO � NAO PORTUARIO (INFORMACAO DO CONTRATANTE)", "20210509" } )
		
		//Agente P�blico
		aAdd( aBody, { "", "000011", "301", "AGENTE P�BLICO � SERVIDOR P�BLICO TITULAR DE CARGO EFETIVO, MAGISTRADO, MINISTRO DE TRIBUNAL DE CONTAS, CONSELHEIRO DE TRIBUNAL DE CONTAS E MEMBRO DO MINIST�RIO P�BLICO", "" } )
		aAdd( aBody, { "", "000012", "302", "AGENTE P�BLICO � SERVIDOR P�BLICO OCUPANTE DE CARGO EXCLUSIVO EM COMISS�O", "" } )
		aAdd( aBody, { "", "000013", "303", "AGENTE P�BLICO � EXERCENTE DE MANDATO ELETIVO", "" } )
		aAdd( aBody, { "", "000014", "304", "AGENTE P�BLICO � SERVIDOR PUBLICO EXERCENTE DE MANDATO ELETIVO, INCLUSIVE COM EXERCICIO DE CARGO EM COMISSAO", "" } )
		aAdd( aBody, { "", "000015", "305", "AGENTE P�BLICO - SERVIDOR P�BLICO INDICADO PARA CONSELHO OU �RG�O DELIBERATIVO, NA CONDI��O DE REPRESENTANTE DO GOVERNO, �RG�O OU ENTIDADE DA ADMINISTRA��O P�BLICA", "" } )
		
		//Cess�o
		aAdd( aBody, { "", "000016", "401", "CESS�O - DIRIGENTE SINDICAL � EM RELACAO A REMUNERACAO RECEBIDA NO SINDICATO.", "" } )
		
		//Contribuinte Individual		
		aAdd( aBody, { "", "000017", "701", "CONTRIBUINTE INDIVIDUAL � CONTRIBUINTE INDIVIDUAL - AUT�NOMO EM GERAL, EXCETO SE ENQUADRADO EM UMA DAS DEMAIS CATEGORIAS DE CONTRIBUINTE INDIVIDUAL", "" } )
		aAdd( aBody, { "", "000018", "702", "CONTRIBUINTE INDIVIDUAL � AUTONOMO CONTRATADO POR CONTRIBUINTE INDIVIDUAL, POR PESSOA FISICA EM GERAL, OU POR MISSAO DIPLOMATICA E REPARTICAO CONSULAR DE CARREIRA ESTRANGEIRAS", "20210509" } )
		aAdd( aBody, { "", "000019", "703", "CONTRIBUINTE INDIVIDUAL � AUTONOMO CONTRATADO POR ENTIDADE BENEFICENTE DE ASSISTENCIA SOCIAL ISENTA DA COTA PATRONAL", "20210509" } )
		aAdd( aBody, { "", "000020", "704", "EXCLUIDO.", "20210509" } )
		aAdd( aBody, { "", "000021", "711", "CONTRIBUINTE INDIVIDUAL � TRANSPORTADOR AUT�NOMO DE PASSAGEIROS", "" } )
		aAdd( aBody, { "", "000022", "712", "CONTRIBUINTE INDIVIDUAL � TRANSPORTADOR AUT�MOMO DE CARGA", "" } )
		aAdd( aBody, { "", "000023", "713", "CONTRIBUINTE INDIVIDUAL � TRANSPORTADOR AUTONOMO CONTRATADO POR ENTIDADE BENEFICENTE DE ASSISTENCIA SOCIAL ISENTA DA COTA PATRONAL", "20210509" } )
		aAdd( aBody, { "", "000024", "721", "CONTRIBUINTE INDIVIDUAL � DIRETOR NAO EMPREGADO COM FGTS", "" } )
		aAdd( aBody, { "", "000025", "722", "CONTRIBUINTE INDIVIDUAL � DIRETOR NAO EMPREGADO SEM FGTS", "" } )
		aAdd( aBody, { "", "000026", "731", "CONTRIBUINTE INDIVIDUAL � COOPERADO QUE PRESTA SERVI�OS POR INTERM�DIO DE COOPERATIVA DE TRABALHO", "" } )
		aAdd( aBody, { "", "000027", "732", "CONTRIBUINTE INDIVIDUAL � COOPERADO QUE PRESTA SERVICOS A ENTIDADE BENEFICENTE DE ASSISTENCIA SOCIAL ISENTA DA COTA PATRONAL OU PARA PESSOA FISICA", "20210509" } )
		aAdd( aBody, { "", "000028", "733", "CONTRIBUINTE INDIVIDUAL � COOPERADO ELEITO PARA DIRECAO DA COOPERATIVA", "20210509" } )
		aAdd( aBody, { "", "000029", "734", "CONTRIBUINTE INDIVIDUAL � TRANSPORTADOR COOPERADO QUE PRESTA SERVI�OS POR INTERM�DIO DE COOPERATIVA DE TRABALHO", "" } )
		aAdd( aBody, { "", "000030", "735", "CONTRIBUINTE INDIVIDUAL � TRANSPORTADOR COOPERADO QUE PRESTA SERVICOS A ENTIDADE BENEFICENTE DE ASSISTENCIA SOCIAL ISENTA DA COTA PATRONAL OU PARA PESSOA FISICA", "20210509" } )
		aAdd( aBody, { "", "000031", "736", "CONTRIBUINTE INDIVIDUAL � TRANSPORTADOR COOPERADO ELEITO PARA DIRECAO DA COOPERATIVA.", "20210509" } )
		aAdd( aBody, { "", "000032", "741", "CONTRIBUINTE INDIVIDUAL � MICROEMPREENDEDOR INDIVIDUAL", "" } )
		aAdd( aBody, { "", "000033", "751", "CONTRIBUINTE INDIVIDUAL � MAGISTRADO CLASSISTA TEMPOR�RIO DA JUSTI�A DO TRABALHO OU DA JUSTI�A ELEITORAL QUE SEJA APOSENTADO DE QUALQUER REGIME PREVIDENCI�RIO", "" } )
		
		//Bolsista
		aAdd( aBody, { "", "000034", "901", "BOLSISTAS - ESTAGIARIO", "" } )
		
		//Agente P�blico
		aAdd( aBody, { "", "000035", "306", "AGENTE P�BLICO - SERVIDOR PUBLICO CONTRATADO POR TEMPO DETERMINADO, SUJEITO A REGIME ADMINISTRATIVO ESPECIAL DEFINIDO EM LEI PROPRIA", "" } )
		aAdd( aBody, { "", "000036", "307", "AGENTE P�BLICO - MILITAR", "20230208"	, 1033.16  } )
		aAdd( aBody, { "", "000037", "308", "AGENTE P�BLICO - CONSCRITO", "20230425", 1033.16  } )
		aAdd( aBody, { "", "000038", "309", "AGENTE P�BLICO - OUTROS", "" } )
		
		//Cess�o
		aAdd( aBody, { "", "000039", "410", "CESS�O - TRABALHADOR CEDIDO/EXERCICIO EM OUTRO ORGAO/JUIZ AUXILIAR - INFORMACAO PRESTADA PELO CESSIONARIO/DESTINO", "" } )
		
		//Contribuinte Individual
		aAdd( aBody, { "", "000040", "723", "CONTRIBUINTE INDIVIDUAL � EMPRES�RIOS, S�CIOS E MEMBRO DE CONSELHO DE ADMINISTRA��O OU FISCAL", "" } )
		aAdd( aBody, { "", "000041", "738", "CONTRIBUINTE INDIVIDUAL � COOPERADO FILIADO A COOPERATIVA DE PRODU��O", "" } )
		aAdd( aBody, { "", "000042", "761", "CONTRIBUINTE INDIVIDUAL � ASSOCIADO ELEITO PARA DIRE��O DE COOPERATIVA, ASSOCIA��O OU ENTIDADE DE CLASSE DE QUALQUER NATUREZA OU FINALIDADE, BEM COMO O S�NDICO OU ADMINISTRADOR ELEITO PARA EXERCER ATIVIDADE DE DIRE��O CONDOMINIAL, DESDE QUE RECEBAM REMUNERA��O", "" } )
		aAdd( aBody, { "", "000043", "771", "CONTRIBUINTE INDIVIDUAL � MEMBRO DE CONSELHO TUTELAR, NOS TERMOS DA LEI N� 8.069, DE 13 DE JULHO DE 1990", "" } )
		aAdd( aBody, { "", "000044", "781", "CONTRIBUINTE INDIVIDUAL � MINISTRO DE CONFISS�O RELIGIOSA OU MEMBRO DE VIDA CONSAGRADA, DE CONGREGA��O OU DE ORDEM RELIGIOSA", "" } )
		
		//Bolsista
		aAdd( aBody, { "", "000045", "902", "BOLSISTAS - M�DICO RESIDENTE OU RESIDENTE EM �REA PROFISSIONAL DE SA�DE", "" } )
		aAdd( aBody, { "", "000046", "903", "BOLSISTAS", "" } )
		aAdd( aBody, { "", "000047", "904", "BOLSISTAS - PARTICIPANTE DE CURSO DE FORMA��O, COMO ETAPA DE CONCURSO P�BLICO, SEM V�NCULO DE EMPREGADO/ESTATUT�RIO.", "" } )
		aAdd( aBody, { "", "000048", "905", "BOLSISTAS - ATLETA N�O PROFISSIONAL EM FORMA��O QUE RECEBA BOLSA.", "20211110" } )
		
		//Empregado e Trabalhador Tempor�rio
		aAdd( aBody, { "", "000049", "111", "EMPREGADO - CONTRATO DE TRABALHO INTERMITENTE", "" } )
		aAdd( aBody, { "", "000050", "107", "EMPREGADO - CONTRATO DE TRABALHO VERDE E AMARELO - SEM ACORDO PARA ANTECIPA��O MENSAL DA MULTA RESCIS�RIA DO FGTS", "20221231", 1033.16  } )
		aAdd( aBody, { "", "000051", "108", "EMPREGADO - CONTRATO DE TRABALHO VERDE E AMARELO - COM ACORDO PARA ANTECIPA��O MENSAL DA MULTA RESCIS�RIA DO FGTS", "20221231", 1033.16  } )

		//Simplifica��o do E-Solcial
		//Agente P�blico
		aAdd( aBody, { "", "000053", "310", "AGENTE P�BLICO - SERVIDOR PUBLICO EVENTUAL", "" } )
		aAdd( aBody, { "", "000054", "311", "AGENTE P�BLICO - MINISTROS, JUIZES, PROCURADORES, PROMOTORES OU OFICIAIS DE JUSTICA A DISPOSICAO DA JUSTICA ELEITORAL ", "" } )
		aAdd( aBody, { "", "000055", "312", "AGENTE P�BLICO - AUXILIAR LOCAL", "" } )
		aAdd( aBody, { "", "000056", "313", "AGENTE P�BLICO - SERVIDOR PUBLICO EXERCENTE DE ATIVIDADE DE INSTRUTORIA, CAPACITACAO, TREINAMENTO, CURSO OU CONCURSO, OU CONVOCADO PARA PARECERES TECNICOS OU DEPOIMENTOS", "" } )

		//NT - 02/202 - Leiaute S-1.0
		//Segurado Especial
		aAdd( aBody, { "", "000057", "501", "DIRIGENTE SINDICAL - SEGURADO ESPECIAL", "" } )

		//NOTA T�CNICA S-1.0 N� 05/2022
		//Bolsista
		aAdd( aBody, { "", "000058", "906", "BOLSISTAS - BENEFICI�RIO DO PROGRAMA NACIONAL DE PRESTA��O DE SERVI�O CIVIL VOLUNT�RIO", "", 1032.05 } )

		//NOTA T�CNICA S-1.1 N� 01/2023
		//Agente P�blico
		aAdd( aBody, { "", "000059", "307", "AGENTE P�BLICO - MILITAR DOS ESTADOS E DISTRITO FEDERAL", ""	, 1033.16 } )
		aAdd( aBody, { "", "000060", "314", "AGENTE P�BLICO - MILITAR DAS FOR�AS ARMADAS", ""				, 1033.16 } )

		aAdd( aRet, { aHeader, aBody } )

	EndIf

Return aRet
