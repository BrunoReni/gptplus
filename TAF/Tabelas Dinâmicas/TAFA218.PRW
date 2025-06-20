#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA218.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA218

Cadastro MVC dos Tipos de Dependentes do eSocial

@author Felipe C. Seolin
@since 09/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA218() 

Local oBrw := FwMBrowse():New()

oBrw:SetDescription(STR0001) //"Cadastro dos Tipos de Dependentes"
oBrw:SetAlias("CMI")
oBrw:SetMenuDef("TAFA218")
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Felipe C. Seolin
@since 09/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return(xFunMnuTAF("TAFA218"))

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Felipe C. Seolin
@since 09/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCMI := FwFormStruct(1,"CMI")
Local oModel   := MpFormModel():New("TAFA218")

oModel:AddFields("MODEL_CMI",/*cOwner*/,oStruCMI)
oModel:GetModel("MODEL_CMI"):SetPrimaryKey({"CMI_FILIAL","CMI_ID"})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Felipe C. Seolin
@since 09/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel("TAFA218")
Local oStruCMI := FwFormStruct(2,"CMI")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_CMI",oStruCMI,"MODEL_CMI")

oView:EnableTitleView("VIEW_CMI",STR0001) //"Cadastro dos Tipos de Dependentes"
oView:CreateHorizontalBox("FIELDSCMI",100)
oView:SetOwnerView("VIEW_CMI","FIELDSCMI")

Return(oView)

//---------------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//---------------------------------------------------------------------------
Static Function FAtuCont( nVerEmp as numeric, nVerAtu as numeric )

	Local aHeader as array
	Local aBody   as array
	Local aRet    as array
	
	aHeader := {}
	aBody   := {}
	aRet    := {}
	
	nVerAtu := 1033.16
	
	If nVerEmp < nVerAtu
	
		aAdd( aHeader, "CMI_FILIAL" )
		aAdd( aHeader, "CMI_ID" 	)
		aAdd( aHeader, "CMI_CODIGO" )
		aAdd( aHeader, "CMI_DESCRI" )
		aAdd( aHeader, "CMI_VALIDA" )
		aAdd( aHeader, "CMI_ALTCON" )
	
		aAdd( aBody, { "", "000001", "01", "CONJUGE OU COMPANHEIRO(A) COM O(A) QUAL TENHA FILHO OU VIVA HA MAIS DE 5 (CINCO) ANOS.", "20150628" } )
		aAdd( aBody, { "", "000002", "02", "FILHO(A) OU ENTEADO(A) ATE 21 (VINTE E UM) ANOS.", "20150628" } )
		aAdd( aBody, { "", "000003", "03", "FILHO(A) OU ENTEADO(A) UNIVERSITARIO(A) OU CURSANDO ESCOLA TECNICA DE 2� GRAU, ATE 24 (VINTE E QUATRO) ANOS.", "20150628" } )
		aAdd( aBody, { "", "000004", "04", "FILHO(A) OU ENTEADO(A) EM QUALQUER IDADE, QUANDO INCAPACITADO FISICA E/OU MENTALMENTE PARA O TRABALHO.", "20150628" } )
		aAdd( aBody, { "", "000005", "05", "IRMAO(A), NETO(A) OU BISNETO(A) SEM ARRIMO DOS PAIS, DO(A) QUAL DETENHA A GUARDA JUDICIAL, ATE 21 (VINTE E UM) ANOS.", "20150628" } )
		aAdd( aBody, { "", "000006", "06", "IRMAO(A), NETO(A) OU BISNETO(A) SEM ARRIMO DOS PAIS, COM IDADE ATE 24 ANOS, SE AINDA ESTIVER CURSANDO ESTABELEC. DE NIVEL SUPERIOR OU ESCOLA TECNICA DE 2� GRAU, DESDE QUE TENHA DETIDO SUA GUARDA JUDICIAL ATE OS 21 ANOS", "20150628" } )
		aAdd( aBody, { "", "000007", "07", "IRMAO(A), NETO(A) OU BISNETO(A) SEM ARRIMO DOS PAIS, DO(A) QUAL DETENHA A GUARDA JUDICIAL, EM QUALQUER IDADE, QUANDO INCAPACITADO FISICA E/OU MENTALMENTE PARA O TRABALHO.", "20150628" } )
		aAdd( aBody, { "", "000008", "08", "PAIS, AVOS E BISAVOS.", "20150628" } )
		aAdd( aBody, { "", "000009", "09", "MENOR POBRE, ATE 21 (VINTE E UM) ANOS, QUE CRIE E EDUQUE E DO QUAL DETENHA A GUARDA JUDICIAL.", "20150628" } )
		aAdd( aBody, { "", "000010", "10", "A PESSOA ABSOLUTAMENTE INCAPAZ, DA QUAL SEJA TUTOR OU CURADOR.", "20150628" } )
		aAdd( aBody, { "", "000011", "01", "CONJUGE", "20170101" } )
		aAdd( aBody, { "", "000012", "02", "COMPANHEIRO(A) COM O(A) QUAL TENHA FILHO OU VIVA HA MAIS DE 5 (CINCO) ANOS", "20170101" } )
		aAdd( aBody, { "", "000013", "03", "FILHO(A) OU ENTEADO(A) ATE 21 (VINTE E UM) ANOS", "20170101" } )
		aAdd( aBody, { "", "000014", "04", "FILHO(A) OU ENTEADO(A) UNIVERSITARIO(A) OU CURSANDO ESCOLA TECNICA DE 2� GRAU, ATE 24 (VINTE E QUATRO) ANOS", "20170101" } )
		aAdd( aBody, { "", "000015", "05", "FILHO(A) OU ENTEADO(A) EM QUALQUER IDADE, QUANDO INCAPACITADO FISICA E/OU MENTALMENTE PARA O TRABALHO", "20170101" } )
		aAdd( aBody, { "", "000016", "06", "IRMAO(A), NETO(A) OU BISNETO(A) SEM ARRIMO DOS PAIS, DO(A) QUAL DETENHA A GUARDA JUDICIAL, ATE 21 (VINTE E UM) ANOS", "20170101" } )
		aAdd( aBody, { "", "000017", "07", "IRMAO(A), NETO(A) OU BISNETO(A) SEM ARRIMO DOS PAIS, COM IDADE ATE 24 ANOS, SE AINDA ESTIVER CURSANDO ESTABELECIMENTO DE NIVEL SUPERIOR OU ESCOLA TECNICA DE 2� GRAU, DESDE QUE TENHA DETIDO SUA GUARDA JUDICIAL ATE OS 21 A", "20170101" } )
		aAdd( aBody, { "", "000018", "08", "IRMAO(A), NETO(A) OU BISNETO(A) SEM ARRIMO DOS PAIS, DO(A) QUAL DETENHA A GUARDA JUDICIAL, EM QUALQUER IDADE, QUANDO INCAPACITADO FISICA E/OU MENTALMENTE PARA O TRABALHO", "20170101" } )
		aAdd( aBody, { "", "000020", "09", "PAIS, AVOS E BISAVOS", "20170101" } )
		aAdd( aBody, { "", "000021", "10", "MENOR POBRE, ATE 21 (VINTE E UM) ANOS, QUE CRIE E EDUQUE E DO QUAL DETENHA A GUARDA JUDICIAL", "20170101" } )
		aAdd( aBody, { "", "000022", "11", "A PESSOA ABSOLUTAMENTE INCAPAZ, DA QUAL SEJA TUTOR OU CURADOR", "20170101" } )
		aAdd( aBody, { "", "000023", "12", "EX-CONJUGE QUE RECEBA PENSAO DE ALIMENTOS. VALIDACAO: NAO PODE HAVER MAIS DE UM DEPENDENTE COM O MESMO CONJUNTO {TPDEP}, {NMDEP} E {DTNASCTO} PARA O MESMO TRABALHADOR", "20170101" } )
	
		//Tabela Conforme layout do e-Social, vers�o 2.2 oficial
		aAdd( aBody, { "", "000024", "01", "C�njuge", "20180101" } )
		aAdd( aBody, { "", "000025", "02", "Companheiro(a) com o(a) qual tenha filho ou viva h� mais de 5 (cinco) anos ou possua Declara��o de Uni�o Est�vel", "20180101" } )
		aAdd( aBody, { "", "000026", "03", "Filho(a) ou enteado(a)", "20180101" } )
		aAdd( aBody, { "", "000027", "04", "Irm�o(�), neto(a) ou bisneto(a) sem arrimo dos pais, do(a) qual detenha a guarda judicial", "20180101" } )
		aAdd( aBody, { "", "000028", "05", "Pais, av�s e bisav�s", "20180101" } )
		aAdd( aBody, { "", "000029", "06", "Menor pobre do qual detenha a guarda judicial", "20180101" } )
		aAdd( aBody, { "", "000030", "07", "A pessoa absolutamente incapaz, da qual seja tutor ou curador", "20180101" } )
		aAdd( aBody, { "", "000031", "08", "Filho(a) ou enteado(a) universit�rio(a) ou cursando escola t�cnica de 2� grau, at� 24 (vinte e quatro) anos", "20180101" } )
		aAdd( aBody, { "", "000032", "15", "Ex-C�njuge", "20180101" } )
		aAdd( aBody, { "", "000033", "99", "Agregado/Outros", "20180101" } )	
		
		//Tabela Conforme layout do e-Social, vers�o 2.4.1 oficial
		aAdd( aBody, { "", "000034", "01", "C�njuge", "" } ) 
		aAdd( aBody, { "", "000035", "02", "Companheiro(a) com o(a) qual tenha filho ou viva h� mais de 5 (cinco) anos ou possua Declara��o de Uni�o Est�vel", "" } )
		aAdd( aBody, { "", "000036", "03", "Filho(a) ou enteado(a)", "" } )
		aAdd( aBody, { "", "000037", "04", "Filho(a) ou enteado(a), universit�rio(a) ou cursando escola t�cnica de 2� grau", "20230425", 1033.16 } )
		aAdd( aBody, { "", "000038", "06", "Irm�o(�), neto(a) ou bisneto(a) sem arrimo dos pais, do(a) qual detenha a guarda judicial", "" } )
		aAdd( aBody, { "", "000039", "07", "Irm�o(�), neto(a) ou bisneto(a) sem arrimo dos pais, universit�rio(a) ou cursando escola t�cnica de 2� grau, do(a) qual detenha a guarda judicial", "20230425", 1033.16 } )
		aAdd( aBody, { "", "000040", "09", "Pais, av�s e bisav�s", "" } )
		aAdd( aBody, { "", "000041", "10", "Menor pobre do qual detenha a guarda judicial", "" } )
		aAdd( aBody, { "", "000042", "11", "A pessoa absolutamente incapaz, da qual seja tutor ou curador", "" } )
		aAdd( aBody, { "", "000043", "12", "Ex-C�njuge", "" } )
		aAdd( aBody, { "", "000044", "99", "Agregado/Outros", "" } )
		
		aAdd( aRet, { aHeader, aBody } )
	
	EndIf

Return( aRet )
