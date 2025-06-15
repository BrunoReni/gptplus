// -------------------------------------------------------------------------------------------
// Modulo : SIGAOMS
// Fonte  : OMSA200A
// ---------+---------------------+-----------------------------------------------------------
// Data     | Autor			  	  | Descri��o
// ---------+---------------------+-----------------------------------------------------------
// 17/08/22 | 	  | Simula��o de Calculo de Frete de Carga x Calculo GFE
// ---------+---------------------+-----------------------------------------------------------

#include 'protheus.ch'
#include 'parmtype.ch'
#include 'totvs.ch'

#define DS_MODALFRAME   128

Static lOM200A01  := ExistBlock("OM200A01")					//Ponto de entrada para usu�rio adicionar valida��o de simula��o de calculo de frete
Static lOM200A02  := ExistBlock("OM200A02")					//Ponto de entrada para usu�rio customizar o retorno do calculo de frete da carga
Static lOM200A03  := ExistBlock("OM200A03")					//Ponto de entrada para usu�rio customizar a valida��o do campo ao ser preenchido quando estiver com processo em tela
Static lOM200A04  := ExistBlock("OM200A04")					//Ponto de entrada para usu�rio validar algo antes de fechar a tela de calculo de frete quando estiver com processo em tela
Static lOM200A05  := ExistBlock("OM200A05")					//Ponto de entrada para usu�rio customizar o preenchimento das informa��es antes da abertura da tela
Static lOM200A06  := ExistBlock("OM200A06")					//Ponto de entrada para usu�rio customizar o preenchimento das informa��es antes de disparar do calculo para cada pedido de venda
Static lGFEX0101  := ExistBlock("GFEX0101")					//GFEX0101 - Controle de Apresenta��o da Tela de Resultado da Simula��o de Frete  - Padr�o GFE
Static lLibCampo  := SuperGetMV("MV_OM2CMP",.F., .T.)		//Parametro para indicar se libera os campos para edi��o: .T. Liberar os campos para Edi��o; .F. Bloquear os Campos para Edi��o
Static lOcutDeta  := SuperGetMV("MV_OM2CFR",.F., .F.)		//Parametro para indicar se Oculta a aba detalhes de Calculo: .T. Ocultar a aba detalhes de calculo; .F. Mostrar a aba de detalhe de calculo
Static cNegocia	  := SuperGetMV("MV_OM2NEG",.F., "2")		//Parametro para indicar se o calculo de frete deve considerar tabelas em negocia��o ainda: 1 - Sim,2 - Nao
Static cRateio	  := SuperGetMV("MV_OM2RAT",.F., "2222")	//Parametro para indicar se os campos relacionados a Valor de Carga, Valor de Peso, Valor de Volume e KM (Apenas quando os campos estiverem liberados) dever�o ter rateio para calculo de frete: 1 - Rateio; 2 - N�o Rateio (Isso para cada um dos 4 campos)
Static lVisCarga  := SuperGetMV("MV_OM2VIS",.F., .F.)		//Parametro para indicar se o bot�o de carga estar� visivel para abertura de telas: .T. Deixar o Bot�o Visivel; .F. Ocultar bot�o
Static lMemCalcu  := SuperGetMV("MV_OM2MEM",.F., .T.)		//Parametro para indicar se vai mostrar os dados da memoria de calculo que foi utilizado durante o calculo: .T. Mostrar Memoria de Configura��es / .F. Ocultar Memoria de Configura��es
Static lIgnCliEX  := SuperGetMV("MV_OM2CEX",.F., .T.)		//Parametro para indicar se permite chamar a tela para pedidos que seja exterior: .T. Bloquear Calculo Exterior; .F. Permitir Calculo Exterior
Static lIgnrZera  := SuperGetMV("MV_OM2ZER",.F., .T.)		//Parametro para indicar se vai mostrar os dados do calculo de frete quando retornar valor zerado: .T. Bloquear Valores Zerados / .F. Liberar Valores Zarados		
Static lIgnrPFOB  := SuperGetMV("MV_OM2FOB",.F., .T.)		//Parametro para indicar se vai considerar pedidos que sejam diferente de CIF e/ou 'Transporte Pr�prio por conta do Remetente'. Por padr�o o GFE n�o calcula Frete: .T. Bloquear Pedidos / .F. Liberar Pedidos 		
Static lIgnrNORM  := SuperGetMV("MV_OM2NOR",.F., .T.)		//Parametro para indicar se vai considerar pedidos que sejam diferente do Tipo de Pedido Normal. Por padr�o o GFE n�o calcula Frete: .T. Bloquear Pedidos / .F. Liberar Pedidos 		
Static lIgnrFATU  := SuperGetMV("MV_OM2FAT",.F., .T.) 		//Parametro para indicar se vai considerar pedidos que j� tenham sido faturados: .T. Bloquear Pedidos Faturados / .F. Liberar Pedidos j� faturados
static __nLogProc := SuperGetMV("MV_OM2GF1",.F., 0)			//Parametro para indicar se apresenta informa��es da tela de simula��o de calculo de frete do GFE: 0: N�o apresentar / 1: Somente erros / 2: Sempre
static __lHidePrg := SuperGetMV("MV_OM2GF2",.F., .T.)		//Parametro para indicar se Seta var�avel que exibe barra de progresso simula��o de calculo de frete do GFE: .T. Oculta a barra de Progresso / .F. Mostrar a barra de progresso.
Static lAtvChang  := .F. //Variavel que ser� utilizada para controlar a atualiza��o da grid

//Fun��o para calcular frete de carga quando tem integra��o com GFE
Function OMSA200A()
	Local cCodCar     := DAK->DAK_COD
	Local cSeqCar     := DAK->DAK_SEQCAR
	Local oSay 		  := NIL // CAIXA DE DI�LOGO GERADA
	Private aTabFrete := {}			//Array com as transportadora
	Private lRetorno  := .F. 		//Variavel de retorno que rotina fez o precisava
	Private lSemMsFrt := IsBlind()	//Tratamento para n�o disparar interface com usu�rio se for via execauto

	//O processo de calculo apenas ser� disparado se as configura��es com o GFE estiverem ativas.
	If !fGFEAtivo()
		IF lSemMsFrt
			OmsLogMsg("Configura��es do GFE x OMS n�o est�o ativas. Simula��o de Calculo de Frete cancelada.")
		else
			OmsHelp("Configura��es do GFE x OMS n�o est�o ativas.","Simula��o de Calculo de Frete cancelada.")
		EndIF
		Return .T.
	EndIF

	//Tratar libera��o de campo para quando for sem interface
	IF lLibCampo .AND. lSemMsFrt
		lLibCampo := .F.
	EndIF

	//Tratar Memoria de calculo para quando for sem interface
	IF lMemCalcu .AND. lSemMsFrt
		lMemCalcu := .F.
	EndIF	

	//Tratar rateio de valores no calculos
	IF Empty(cRateio) .OR. Len(cRateio) != 4
		cRateio := "2222" //Corresponde aos 4 campos que ser�o considerados Valor da Mercadoria, Valor do Peso, Valor do Volume e KM   //1 - Rateio  //2 - N�o Ratear	
	EndIF

	//GFEX0101 - Controle de Apresenta��o da Tela de Resultado da Simula��o de Frete  - Padr�o GFE //https://tdn.totvs.com/pages/releaseview.action?pageId=238036695
	If lGFEX0101
		OmsLogMsg("Existe o ponto de entrada GFEX0101.")
		__nLogProc := ExecBlock('GFEX0101',.F.,.F.)
	EndIf

	//Valida��o para ajuste relacionado do tipo de negocia��o durante o calculo.
	IF Empty(cNegocia) .OR. !(cNegocia $"1_2")
		cNegocia := "2"
	EndIF

	//Realiza chamada da tela de cria��o de estrutura
	IF !Empty(cCodCar) .AND. !Empty(cSeqCar)
		IF lSemMsFrt
			CriaTemp(cCodCar, cSeqCar)
		else
			FwMsgRun(,{ |oSay| CriaTemp(cCodCar, cSeqCar, oSay) },'Montando Tela de Simula��o de Calculo de Frete','Aguarde...')
		EndIF
	EndIF

	//Ponto de entrada para usu�rio customizar o retorno do calculo de frete da carga
	IF lOM200A02
		OmsLogMsg("Existe o ponto de entrada OM200A02.")
		ExecBlock("OM200A02",.F.,.F.,{cCodCar, cSeqCar, lRetorno, aTabFrete})//Envio: Codigo da Carga, Sequ�ncia da Carga, Tipo de Retorno e Array de Transportadora
	EndIF

Return .T.

//Fun��o para criar estruturas
Static Function CriaTemp(cTmpCar, cTmpSeq, oTexJan)
	Private aFieldTra := {}
	Private cAliasTra := GetNextAlias()
	Private oTableTra
	Private oBrowsTra
	Private aColumTra := {}
	Private aFieldRes := {}
	Private cAliasRes := GetNextAlias()
	Private oTableRes
	Private oBrowsRes
	Private aColumRes := {}
	Private aFieldPed := {}
	Private cAliasPed := GetNextAlias()
	Private oTablePed
	Private oBrowsPed
	Private aColumPed := {}
	Private lExisteEX := .F. //Variavel para validar se tem algum pedido que seja exterior.
	Private lFalhaSC5 := .F. //Variavel para validar se tem algum pedido com problema de emissor.
	Private lExistFOB := .F. //Variavel para validar se tem algum pedido com Tipo de Frete FOB.
	Private IExistNOR := .F. //Variavel para validar se tem algum pedido com Tipo de Pedido diferente de Normal.
	Private cCodDAK   := ""
	Private cSeqDAK   := ""	
	Private nQtdPedi  := 0

	default oTexJan   := Nil

	DbSelectArea("DAK")
	DAK->(DbSetOrder(1))
	IF DAK->(dbSeek(xFilial("DAK")+cTmpCar+cTmpSeq))

		cCodDAK := DAK->DAK_COD
		cSeqDAK := DAK->DAK_SEQCAR
		nQtdPedi :=  0//DAK->DAK_PTOENT

		IF lIgnrFATU .AND. DAK->DAK_FEZNF == "1"
			IF lSemMsFrt
				OmsLogMsg("Est� carga j� encontra-se faturada. Simula��o de Calculo de Frete cancelada (MV_OM2FAT).")
			else
				OmsHelp("Est� carga j� encontra-se faturada.","Simula��o de Calculo de Frete cancelada (MV_OM2FAT).")
			EndIF
			lRetorno   := .F.
			aTabFrete  := {}
			Return .T.
		EndIF

		IF !lSemMsFrt
			oTexJan:SetText("Criando estrutura de tabelas auxiliares")
		EndiF

		CriTabPed()	//Criar tabela de Pedidos
		CriTabTra()	//Criar tabela de Transportadora
		CriTabRes()	//Criar tabela de Resumo

		IF !lSemMsFrt
			oTexJan:SetText("Carregando listagem de pedidos da carga")
		EndiF

		//Fun��o para carregar tabela de pedido
		fCargPed(cTmpCar, cTmpSeq)	

		//Valida��o de Pedidos que sejam EX
		IF lIgnCliEX .AND. lExisteEX
			IF lSemMsFrt
				OmsLogMsg("Est� carga possui pedido que seu destino est� como 'Exterior' e n�o pode ser calculado o valor do frete. Simula��o de Calculo de Frete cancelada (MV_OM2CEX).")
			else
				OmsHelp("Est� carga possui pedido que seu destino est� como 'Exterior' e n�o pode ser calculado o valor do frete.","Simula��o de Calculo de Frete cancelada (MV_OM2CEX).")
			EndIF
			lRetorno   := .F.
			aTabFrete  := {}
			Return .T.
		EndIF

		//Valida��o de Pedidos, cujo Cliente Retirada est� com informa��o errada.
		IF lFalhaSC5
			lRetorno   := .F.
			aTabFrete  := {}
			Return .T.
		EndIF

		//Valida��o de Pedidos que sejam FOB
		IF lIgnrPFOB .AND. lExistFOB
			IF lSemMsFrt
				OmsLogMsg("Est� carga possui pedido que seu Tipo de Frete est� diferente de  'CIF' e/ou 'Transporte Pr�prio por conta do Remetente' e n�o pode ser calculado o valor do frete. Simula��o de Calculo de Frete cancelada (MV_OM2FOB).")
			else
				OmsHelp("Est� carga possui pedido que seu Tipo de Frete est� diferente de  'CIF' e/ou "+CRLF+"'Transporte Pr�prio por conta do Remetente' e n�o pode ser calculado o valor do frete.","Simula��o de Calculo de Frete cancelada (MV_OM2FOB).")
			EndIF
			lRetorno   := .F.
			aTabFrete  :={}
			Return .T.
		EndIF

		//Valida��o de Pedidos que sejam diferentes Normal
		IF lIgnrNORM .AND. IExistNOR
			IF lSemMsFrt
				OmsLogMsg("Est� carga possui pedido que seu Tipo de Pedido est� diferente de  'Normal' e n�o pode ser calculado o valor do frete. Simula��o de Calculo de Frete cancelada (MV_OM2NOR).")
			else
				OmsHelp("Est� carga possui pedido que seu Tipo de Frete est� diferente de  'Normal' e n�o pode ser calculado o valor do frete.","Simula��o de Calculo de Frete cancelada (MV_OM2NOR).")
			EndIF
			lRetorno   := .F.
			aTabFrete  :={}
			Return .T.
		EndIF

		//Valida��o de Carga sem ter pedidos vinculados
		IF nQtdPedi <= 0
			IF lSemMsFrt
				OmsLogMsg("Est� carga est� sem pedidos vinculados e n�o pode ser calculado o valor do frete. Simula��o de Calculo de Frete cancelada.")
			else
				OmsHelp("Est� carga est� sem pedidos vinculados e n�o pode ser calculado o valor do frete.","Simula��o de Calculo de Frete cancelada.")
			EndIF
			lRetorno   := .F.
			aTabFrete  :={}
			Return .T.		
		EndIF 

		IF !lSemMsFrt
			oTexJan:SetText("Executando calculo de frete da carga")
		EndiF

		//Chama a rotina de calculo de frete
		fPrepFret(.F., oTexJan)

		//Chamar tela se tiver interface
		IF !lSemMsFrt
			oTexJan:SetText("Montagem de Tela de Calculo de Frete")
			MontTela(cTmpCar, cTmpSeq)
		EndIF

	else
		IF lSemMsFrt
			OmsLogMsg("Carga informada n�o encontrada. Carga: "+cTmpCar+" Sequ�ncia: "+cTmpSeq+". Verifique se a carga existe.")
		else
			OmsHelp("Carga informada n�o encontrada."+CRLF+"Carga: "+cTmpCar+CRLF+"Sequ�ncia: "+cTmpSeq,"Verifique se a carga existe.")
		EndIF
		lRetorno   := .F.
		aTabFrete  :={}
		Return .T.	
	EndIF

Return .T.

//Fun��o para montar a tela de Simula��o de Calculo de Frete
Static Function MontTela(cTmpCar, cTmpSeq)
	Local aAreaAtu  := GetArea()
	Local lRetPE01  := .T.
	Local lRet      := .T.

	//Ponto de entrada para usu�rio adicionar valida��o de simula��o de calculo de frete
	IF lOM200A01 .AND. lRet
		OmsLogMsg("Existe o ponto de entrada OM200A01.")
		lRetPE01 := ExecBlock("OM200A01",.F.,.F.,{cCodDAK, cSeqDAK}) //Envio: Codigo da Carga, Sequ�ncia da Carga //Retorno: Logico se permite abrir a tela
		If ValType(lRetPE01)=="L"
			IF !lRetPE01
				lRet       := .F.
				lRetorno   := .F.
				aTabFrete  := {}
				IF lSemMsFrt
					OmsLogMsg("Executou ponto de entrada OM200A01 e seu retorno foi FALSE.") // Esta carga j� se encontra faturada.
				EndIF
			else
				lRet := lRetPE01
			EndIF
		Else
			OmsLogMsg("Retorno do ponto de entrada OM200A01 n�o est� dentro das valida��es.")
		EndIf
	EndIF

	IF lRet
		CriaTela() //Chamada para cria��o da tela com os parametros baseados na tabela posicionada
	else
		lRetorno   := .F.
		aTabFrete  := {}
	EndIF

	RestArea( aAreaAtu )
Return .T.

//Fun��o para criar a tela da Simula��o 
Static Function CriaTela()
	Local lCntrAbrt   := .F.
	Local aRetPE05    := {}
	Local oRelacPed   := Nil

	//Variaveis relacionadas a carga posicionada
	Private cEdtCarg  := DAK->DAK_COD //Codigo da Carga
	Private cEdtSeq   := DAK->DAK_SEQCAR //Sequencia da Carga
	Private dEdtData  := DAK->DAK_DATA //Data da Carga
	Private cEdtVei01 := IIF(!Empty(DAK->DAK_CAMINH),DAK->DAK_CAMINH, Space(TamSX3("DAK_CAMINH")[1]) ) //Veiculo 01
	Private nEdtPeso  := DAK->DAK_PESO //Peso da Carga
	Private nEdtVlrMe := DAK->DAK_VALOR //Valor da Mercadoria
	Private cEdtVolCa := DAK->DAK_CAPVOL //Volume da Carga
	Private cEdtMoto  := IIF(!Empty(DAK->DAK_MOTORI),DAK->DAK_MOTORI, Space(TamSX3("DAK_MOTORI")[1]) ) //Codigo do Motorista
	Private cEdtDMot  := IIF(!Empty(cEdtMoto), Alltrim(Posicione("DA4",1,xFilial("DA4")+cEdtMoto,"DA4_NOME")), Space(TamSX3("DA4_NOME")[1]) ) //Descri��o do Motorista
	Private cEdtTran  := IIF(!Empty(DAK->DAK_TRANSP),DAK->DAK_TRANSP, Space(TamSX3("DAK_TRANSP")[1]) ) //Codigo da Transportadora
	Private cEdtDTra  := IIF(!Empty(cEdtTran), Alltrim(Posicione("SA4",1,xFilial("SA4")+cEdtTran,"A4_NOME")), Space(TamSX3("A4_NOME")[1]) ) //Descri��o da Transportadora
	//Variaveis relacionadas as configura��es para calculo da carga
	Private nEdtValor := nEdtVlrMe //Valor da Mercadoria
	Private nEdtPes   := nEdtPeso //Peso da Carga
	Private nEdtVolu  := cEdtVolCa //Volume da Carga
	Private nEdtKM    := 0 //Distancia da Carga
	Private cEdtTipo  := avKey(IIF(!Empty(DAK->DAK_CDTPOP ),Alltrim(DAK->DAK_CDTPOP), SuperGetMv("MV_CDTPOP",.F.,"") ) ,"DAK_CDTPOP" ) //Codigo do Tipo de Opera��o
	Private cEdtDTip  := avKey(IIF(!Empty(cEdtTipo ),Alltrim(Posicione("GV4",1,xFilial("GV4")+cEdtTipo,"GV4_DSTPOP")),"" ) ,"GV4_DSTPOP" ) //Descri��o do Tipo de Opera��o
	Private cEdtClas  := avKey(IIF(!Empty(DAK->DAK_CDCLFR ),Alltrim(DAK->DAK_CDCLFR), SuperGetMv("MV_CDCLFR",.F.,"") ) ,"DAK_CDCLFR" ) //Codigo da Classifica��o de Frete
	Private cEdtDCla  := avKey(IIF(!Empty(cEdtClas ),Alltrim(Posicione("GUB",1,xFilial("GUB")+cEdtClas,"GUB_DSCLFR")),"" ) ,"GUB_DSCLFR" ) //Descri��o da Classifica��o de Frete
	Private cEdtTVei  := avKey(IIF(!Empty(cEdtVei01 ),Alltrim(Posicione("DA3",1,xFilial("DA3")+cEdtVei01,"DA3_TIPVEI")),"" ) ,"GWU_CDTPVC" ) //Codigo do Tipo de Veiculo
	Private cEdtDTVe  := avKey(IIF(!Empty(cEdtTVei ),Alltrim(Posicione("DUT",1,FWxFilial("DUT")+cEdtTVei,"DUT_DESCRI")),"" ) ,"DUT_DESCRI" ) //Descri��o do Tipo de Veiculo
	Private cEdtTra   := avKey(IIF(!Empty(cEdtTran ) .AND. fVlSA4GU3(cEdtTran, .F.), Alltrim(cEdtTran),"" ) ,"DAK_TRANSP" ) //Codigo da Transportadora
	Private cEdtDTr   := avKey(IIF(!Empty(cEdtTra ),Alltrim(Posicione("SA4",1,FWxFilial("SA4")+cEdtTra,"A4_NOME")),"" ) ,"A4_NOME" ) //Descri��o da Transportadora
	Private cCmbNego  := "" //Aceita Negocia��o

	Private aTmpRotin := {}

	IF Empty(cEdtDTip)
		cEdtTipo := avKey("" ,"DAK_CDTPOP"	)
	EndIF
	IF Empty(cEdtDCla)
		cEdtClas := avKey("" ,"DAK_CDCLFR"	)
	EndIF
	IF Empty(cEdtDTVe)
		cEdtTVei := avKey("" ,"GWU_CDTPVC"	)
	EndIF
	IF Empty(cEdtDTr)
		cEdtTra := avKey("" ,"DAK_TRANSP"	)
	EndIF

	//Ponto de entrada para usu�rio customizar o preenchimento das informa��es antes da abertura da tela
	IF lOM200A05
		OmsLogMsg("Existe o ponto de entrada OM200A05.")
		aRetPE05 := ExecBlock("OM200A05",.F.,.F.,{cCodDAK, cSeqDAK, nEdtValor, nEdtPes, nEdtVolu, nEdtKM, cEdtTipo, cEdtClas, cEdtTVei, cEdtTra}) //Envio: Codigo da Carga, Sequ�ncia da Carga, Variaveis da Tela de Calculo // Retorno: Array com as variaveis que ser�o usadas na tela.
		If ValType(aRetPE05)=="A" .AND. aRetPE05[1] == 8
			IF ValType(aRetPE05[1,1])=="N" .AND. aRetPE05[1,1] >= 0
				nEdtValor := aRetPE05[1,1]
			EndIF
			IF ValType(aRetPE05[1,2])=="N" .AND. aRetPE05[1,2] >= 0
				nEdtPes := aRetPE05[1,2]
			EndIF
			IF ValType(aRetPE05[1,3])=="N" .AND. aRetPE05[1,3] >= 0
				nEdtVolu := aRetPE05[1,3]
			EndIF
			IF ValType(aRetPE05[1,4])=="N" .AND. aRetPE05[1,4] >= 0
				nEdtKM := aRetPE05[1,4]
			EndIF

			IF ValType(aRetPE05[1,5])=="C"
				cEdtTipo := avKey(IIF(!Empty(aRetPE05[1,5])	,Alltrim(aRetPE05[1,5]), SuperGetMv("MV_CDTPOP",.F.,"")						) ,"DAK_CDTPOP"	)	//Codigo do Tipo de Opera��o
				cEdtDTip := avKey(IIF(!Empty(cEdtTipo)		,Alltrim(Posicione("GV4",1,xFilial("GV4")+cEdtTipo,"GV4_DSTPOP")),""		) ,"GV4_DSTPOP"	)	//Descri��o do Tipo de Opera��o
				IF Empty(cEdtDTip)
					cEdtTipo := avKey("" ,"DAK_CDTPOP"	)
				EndIF
			EndIF

			IF ValType(aRetPE05[1,6])=="C"
				cEdtClas := avKey(IIF(!Empty(aRetPE05[1,6]	),Alltrim(aRetPE05[1,6]), SuperGetMv("MV_CDCLFR",.F.,"")					) ,"DAK_CDCLFR"	)	//Codigo da Classifica��o de Frete
				cEdtDCla := avKey(IIF(!Empty(cEdtClas		),Alltrim(Posicione("GUB",1,xFilial("GUB")+cEdtClas,"GUB_DSCLFR")),""		) ,"GUB_DSCLFR"	)	//Descri��o do Tipo de Opera��o
				IF Empty(cEdtDCla)
					cEdtClas := avKey("" ,"DAK_CDCLFR"	)
				EndIF
			EndIF

			IF ValType(aRetPE05[1,7])=="C"
				cEdtTVei := avKey(IIF(!Empty(aRetPE05[1,7]	),Alltrim(Posicione("DA3",1,xFilial("DA3")+aRetPE05[1,7],"DA3_TIPVEI")),""	) ,"GWU_CDTPVC"	)	//Codigo do Tipo de Veiculo
				cEdtDTVe := avKey(IIF(!Empty(cEdtTVei		),Alltrim(Posicione("DUT",1,FWxFilial("DUT")+cEdtTVei,"DUT_DESCRI")),""		) ,"DUT_DESCRI"	)	//Descri��o do Tipo de Veiculo
				IF Empty(cEdtDTVe)
					cEdtTVei := avKey("" ,"GWU_CDTPVC"	)
				EndIF
			EndIF

			IF ValType(aRetPE05[1,8])=="C"
				cEdtTra := avKey(IIF(!Empty(aRetPE05[1,8]	),Alltrim(aRetPE05[1,8]),""													) ,"DAK_TRANSP"	)	//Codigo da Transportadora
				cEdtDTr := avKey(IIF(!Empty(cEdtTra			),Alltrim(Posicione("SA4",1,FWxFilial("SA4")+cEdtTra,"A4_NOME")),""			) ,"A4_NOME"	)	//Descri��o da Transportadora
				IF Empty(cEdtDTr)
					cEdtTra := avKey("" ,"DAK_TRANSP"	)
				EndIF
			EndIF

		Else
			OmsLogMsg("Retorno do ponto de entrada OM200A05 n�o est� dentro das valida��es.")
		EndIF
	EndIF

	// Habilita a skin padr�o dos componentes visuais
	SetSkinDefault()

	// Declara��o de Variaveis Private dos Objetos
	SetPrvt("oJanSimul"	,"oGpCarga"	,"oEdtCarg"	,"oEdtCarg"	,"oEdtData"	,"oEdtVei01"	,"oEdtPeso"	,"oEdtVlrMe"	,"oEdtVoCar"	)
	SetPrvt("oEdtMoto"	,"oEdtDMot"	,"oEdtTran"	,"oEdtDTra"	,"oBtnSair"	,"oBtnCalc"		,"oBtnVisu"	,"oPnlCentro"	,"oFolder"		)
	SetPrvt("oEdtValor"	,"oEdtPes"	,"oEdtVolu"	,"oEdtKM"	,"oCmbNego"	,"oEdtTipo"		,"oEdtDTip"	,"oEdtClas"		,"oEdtDCla"		)
	SetPrvt("oEdtTVei"	,"oEdtDTVe"	,"oEdtTra"	,"oEdtDTr"	,"oGpResu"	,"oGrpPed"		,"oGpFrete"	,"oDivisor"		,"oPnlDvSu"		)
	SetPrvt("oPnlDvIn"	,"oRelacGrd"																								)

	//Definicao do Dialog e todos os seus componentes.
	//oJanSimul  := MSDialog():New( 185,2591,700,3386," Simula��o de Frete de Carga (OMS x GFE) ",,,.F.,,,,,,.T.,,,.T. )
	DEFINE MsDialog oJanSimul From 185,2591 To 690,3386 Title " Simula��o de Frete de Carga (OMS x GFE) " Pixel Style DS_MODALFRAME

	//Componentes do Grupo de Configura��o de Carga
	oGpCarga   := TGroup():New( 000,000,052,392," Informa��es da Carga ",oJanSimul,CLR_HRED,CLR_WHITE,.T.,.F. )
	oGpCarga:align:= CONTROL_ALIGN_TOP
	oEdtCarg   := TGet():New( 010,004,{|u| If(PCount()>0,cEdtCarg:=u,cEdtCarg)}     ,oGpCarga,032,008,PESQPICT("DAK","DAK_COD")		,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cEdtCarg"    ,   ,   ,   ,   ,   ,   ,"Carga"                ,1  ,   ,   ,   ,   ,.T.    )
	oEdtCarg:Disable()
	oEdtSeq    := TGet():New( 010,040,{|u| If(PCount()>0,cEdtSeq:=u,cEdtSeq)}       ,oGpCarga,020,008,PESQPICT("DAK","DAK_SEQCAR")	,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cEdtSeq"     ,   ,   ,   ,   ,   ,   ,"Seq."                 ,1  ,   ,   ,   ,   ,.T.    )
	oEdtSeq:Disable()
	oEdtData   := TGet():New( 010,070,{|u| If(PCount()>0,dEdtData:=u,dEdtData)}     ,oGpCarga,040,008,PESQPICT("DAK","DAK_DATA")	,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dEdtData"    ,   ,   ,   ,   ,   ,   ,"Dt. Carga"            ,1  ,   ,   ,   ,   ,.T.    )
	oEdtData:Disable()
	oEdtVei01  := TGet():New( 010,118,{|u| If(PCount()>0,cEdtVei01:=u,cEdtVei01)}   ,oGpCarga,045,008,PESQPICT("DAK","DAK_CAMINH")	,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cEdtVei01"   ,   ,   ,   ,   ,   ,   ,"Veiculo 1"            ,1  ,   ,   ,   ,   ,.T.    )
	oEdtVei01:Disable()
	oEdtVlrMe  := TGet():New( 010,172,{|u| If(PCount()>0,nEdtVlrMe:=u,nEdtVlrMe)}   ,oGpCarga,050,008,PESQPICT("DAK","DAK_VALOR")	,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nEdtVlrMe"   ,   ,   ,   ,   ,   ,   ,"Vlr. Mercadoria"      ,1  ,   ,   ,   ,   ,.T.    )
	oEdtVlrMe:Disable()
	oEdtPeso   := TGet():New( 010,230,{|u| If(PCount()>0,nEdtPeso:=u,nEdtPeso)}     ,oGpCarga,050,008,PESQPICT("DAK","DAK_PESO")	,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nEdtPeso"    ,   ,   ,   ,   ,   ,   ,"Peso Carga"           ,1  ,   ,   ,   ,   ,.T.    )
	oEdtPeso:Disable()
	oEdtVoCar   := TGet():New( 010,287,{|u| If(PCount()>0,cEdtVolCa:=u,cEdtVolCa)}	,oGpCarga,050,008,PESQPICT("DAK","DAK_CAPVOL")	,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cEdtVolCa"    ,   ,   ,   ,   ,   ,   ,"Volume Carga"		,1  ,   ,   ,   ,   ,.T.    )
	oEdtVoCar:Disable()
	oEdtMoto   := TGet():New( 030,004,{|u| If(PCount()>0,cEdtMoto:=u,cEdtMoto)}     ,oGpCarga,025,008,PESQPICT("DAK","DAK_MOTORI")	,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cEdtMoto"    ,   ,   ,   ,   ,   ,   ,"Motorista"            ,1  ,   ,   ,   ,   ,.T.    )
	oEdtMoto:Disable()
	oEdtDMot   := TGet():New( 037,028,{|u| If(PCount()>0,cEdtDMot:=u,cEdtDMot)}     ,oGpCarga,140,008,PESQPICT("DA4","DA4_NOME")	,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cEdtDMot"    ,   ,   ,   ,   ,   ,   ,""                     ,1  ,   ,   ,   ,   ,.T.    )
	oEdtDMot:Disable()
	oEdtTran   := TGet():New( 030,173,{|u| If(PCount()>0,cEdtTran:=u,cEdtTran)}     ,oGpCarga,025,008,PESQPICT("DAK","DAK_TRANSP")	,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cEdtTran"    ,   ,   ,   ,   ,   ,   ,"Transportadora"       ,1  ,   ,   ,   ,   ,.T.    )
	oEdtTran:Disable()
	oEdtDTra   := TGet():New( 037,197,{|u| If(PCount()>0,cEdtDTra:=u,cEdtDTra)}     ,oGpCarga,140,008,PESQPICT("SA4","A4_NOME")		,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cEdtDTra"    ,   ,   ,   ,   ,   ,   ,""                     ,1  ,   ,   ,   ,   ,.T.    )
	oEdtDTra:Disable()

	//Componentes de bot�o
	oBtnSair   := TButton():New( 005,345,"&Fechar"      ,oGpCarga,{||fFechar()}			,052,014,,,,.T.,,"",,,,.F. )
	IF lLibCampo
		oBtnCalc   := TButton():New( 020,345,"&Calcular"    ,oGpCarga,{||fCalFr()}    ,052,014,,,,.T.,,"",,,,.F. )
	EndIF
	IF lVisCarga
		oBtnVisu   := TButton():New( 035,345,"&Visualizar"  ,oGpCarga,{||fVisCarga()}  ,052,014,,,,.T.,,"",,,,.F. )
	EndIF

	//Componentes da Parte de Baixo
	oPnlCentro := TPanel():New( 044,000,"",oJanSimul,,.F.,.F.,,,392,236,.T.,.F. )
	oPnlCentro:align:= CONTROL_ALIGN_ALLCLIENT
	oFolder    := TFolder():New( 000,000,{"Configura��o do Calculo","Detalhe do Calculo"},{},oPnlCentro,,,,.T.,.F.,392,232,)
	oFolder:align:= CONTROL_ALIGN_ALLCLIENT
	oFolder:bChange := { |nFolder| AtualBrw(nFolder) }

	IF lOcutDeta
		oFolder:HidePage(2)
	EndIF

	//Componentes da Aba Configura��o do Calculo
	oEdtValor  := TGet():New( 003,003,{|u| If(PCount()>0,nEdtValor:=u,nEdtValor)}   ,oFolder:aDialogs[1],059,008,PESQPICT("GW8","GW8_VALOR")    ,{||fValCmp(1, nEdtValor,lCntrAbrt)}	,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,""	,"nEdtValor"    ,   ,   ,   ,.T.,.F.,.F.,"Vlr. Mercadoria"		,1  ,   ,   ,   ,   ,.T.    )
	oEdtPes    := TGet():New( 003,067,{|u| If(PCount()>0,nEdtPes:=u,nEdtPes)}       ,oFolder:aDialogs[1],059,008,PESQPICT("GW8","GW8_PESOR")    ,{||fValCmp(2, nEdtPes,lCntrAbrt)}		,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,""	,"nEdtPes"      ,   ,   ,   ,.T.,.F.,.F.,"Peso Carga"           ,1  ,   ,   ,   ,   ,.T.    )
	oEdtVolu   := TGet():New( 003,131,{|u| If(PCount()>0,nEdtVolu:=u,nEdtVolu)}     ,oFolder:aDialogs[1],059,008,PESQPICT("GW8","GW8_VOLUME")   ,{||fValCmp(3, nEdtVolu,lCntrAbrt)}		,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,""	,"nEdtVolu"     ,   ,   ,   ,.T.,.F.,.F.,"Volume Carga"         ,1  ,   ,   ,   ,   ,.T.    )
	oEdtKM     := TGet():New( 003,200,{|u| If(PCount()>0,nEdtKM:=u,nEdtKM)}         ,oFolder:aDialogs[1],030,008,PESQPICT("GWN","GWN_DISTAN")   ,{||fValCmp(4, nEdtKM,lCntrAbrt)}		,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,""	,"nEdtKM"       ,   ,   ,   ,.T.,.F.,.F.,"Dist�ncia(KM)"        ,1  ,   ,   ,   ,   ,.T.    )
	oCmbNego   := TComboBox():New( 003,260,{|u| If(PCount()>0,cCmbNego:=u,cCmbNego)},{"1 - Sim","2 - Nao"},073,010,oFolder:aDialogs[1],,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,cCmbNego,"Considerar Negocia��o? "  ,1  ,   ,   )
	oCmbNego:nAt := IIF(cNegocia == "1",1,2)
	oCmbNego:Disable()

	oEdtTipo   := TGet():New( 023,003,{|u| If(PCount()>0,cEdtTipo:=u,cEdtTipo)}     ,oFolder:aDialogs[1],040,008,PESQPICT("GWN","GWN_CDTPOP")   ,{||fValCmp(5, cEdtTipo,lCntrAbrt)}		,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"GV4"	,"cEdtTipo"     ,   ,   ,   ,.T.,.F.,.F.,"Tipo Opera��o"        ,1  ,   ,   ,   ,   ,.T.    )
	oEdtDTip   := TGet():New( 030,043,{|u| If(PCount()>0,cEdtDTip:=u,cEdtDTip)}     ,oFolder:aDialogs[1],145,008,PESQPICT("GV4","GV4_DSTPOP")   ,										,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,""	,"cEdtDTip"     ,   ,   ,   ,   ,   ,   ,""                     ,1  ,   ,   ,   ,   ,.T.    )
	oEdtDTip:Disable()
	oEdtClas   := TGet():New( 023,200,{|u| If(PCount()>0,cEdtClas:=u,cEdtClas)}     ,oFolder:aDialogs[1],040,008,PESQPICT("GWN","GWN_CDCLFR")   ,{||fValCmp(6, cEdtClas,lCntrAbrt)}		,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"GUB"	,"cEdtClas"     ,   ,   ,   ,.T.,.F.,.F.,"Classifica��o"        ,1  ,   ,   ,   ,   ,.T.    )
	oEdtDCla   := TGet():New( 030,240,{|u| If(PCount()>0,cEdtDCla:=u,cEdtDCla)}     ,oFolder:aDialogs[1],152,008,PESQPICT("GUB","GUB_DSCLFR")   ,										,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,""	,"cEdtDCla"     ,   ,   ,   ,   ,   ,   ,""                     ,1  ,   ,   ,   ,   ,.T.    )
	oEdtDCla:Disable()
	oEdtTVei   := TGet():New( 043,003,{|u| If(PCount()>0,cEdtTVei:=u,cEdtTVei)}     ,oFolder:aDialogs[1],040,008,PESQPICT("DUT","DUT_TIPVEI")   ,{||fValCmp(7, cEdtTVei,lCntrAbrt)}		,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"DUT"	,"cEdtTVei"     ,   ,   ,   ,.T.,.F.,.F.,"Tipo Veiculo"         ,1  ,   ,   ,   ,   ,.T.    )
	oEdtDTVe   := TGet():New( 050,043,{|u| If(PCount()>0,cEdtDTVe:=u,cEdtDTVe)}     ,oFolder:aDialogs[1],145,008,PESQPICT("DUT","DUT_DESCRI")   ,										,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,""	,"cEdtDTVe"     ,   ,   ,   ,   ,   ,   ,""                     ,1  ,   ,   ,   ,   ,.T.    )
	oEdtDTVe:Disable()
	oEdtTra    := TGet():New( 043,200,{|u| If(PCount()>0,cEdtTra:=u,cEdtTra)}       ,oFolder:aDialogs[1],040,008,PESQPICT("SA4","A4_COD")		,{||fValCmp(8, cEdtTra,lCntrAbrt)}		,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SA4"	,"cEdtTra"      ,   ,   ,   ,.T.,.F.,.F.,"Transportadora"       ,1  ,   ,   ,   ,   ,.T.    )
	oEdtDTr    := TGet():New( 050,240,{|u| If(PCount()>0,cEdtDTr:=u,cEdtDTr)}       ,oFolder:aDialogs[1],152,008,PESQPICT("SA4","A4_NOME")		,										,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,""	,"cEdtDTr"      ,   ,   ,   ,   ,   ,   ,""                     ,1  ,   ,   ,   ,   ,.T.    )
	oEdtDTr:Disable()

	TrvCamp(lLibCampo)

	lCntrAbrt := .T.

	aTmpRotin := aRotina
	aRotina := {}
	oGpResu    := TGroup():New( 092,000,205,384," Resumo de Calculo ",oFolder:aDialogs[1],CLR_HBLUE,CLR_WHITE,.T.,.F. )
	oGpResu:align:= CONTROL_ALIGN_BOTTOM
	oBrowsRes := FwBrowse():New()
	oBrowsRes:DisableFilter()
	oBrowsRes:DisableConfig()
	oBrowsRes:DisableReport()
	oBrowsRes:DisableSeek()
	oBrowsRes:DisableSaveConfig()
	oBrowsRes:SetAlias(cAliasRes)
	oBrowsRes:SetDataTable()
	oBrowsRes:SetInsert(.F.)
	oBrowsRes:SetDelete(.F., { || .F. })
	oBrowsRes:lHeaderClick := .F.
	oBrowsRes:SetColumns(aColumRes)
	oBrowsRes:SetOwner(oGpResu)
	oBrowsRes:SetLineHeight(09)
	oBrowsRes:Activate()

	aRotina :=aTmpRotin

	//Componentes da Aba Detalhe do Calculo

	//Divis�o da Aba de Detalhe de Calculo
	oDivisor := tSplitter():New( 01,01,oFolder:aDialogs[2],260,184 )
	oDivisor:align:= CONTROL_ALIGN_ALLCLIENT
	oDivisor:SetOrient(1)
	oDivisor:setOpaqueResize(.T.)

	oPnlDvSu  := TPanel():New( 000,000,"",oDivisor,,.F.,.F.,,,460,300,.T.,.F. )
	oPnlDvSu:align:= CONTROL_ALIGN_ALLCLIENT

	oPnlDvIn  := TPanel():New(001,001,"",oDivisor,,.F.,.F.,,,460,050,.T.,.F. )
	oPnlDvIn:align:= CONTROL_ALIGN_ALLCLIENT

	//Grid de Pedidos
	oGrpPed    := TGroup():New( 000,000,096,388," Listagem de Pedidos ",oPnlDvSu,CLR_HBLUE,CLR_WHITE,.T.,.F. )
	oGrpPed:align:= CONTROL_ALIGN_ALLCLIENT
	// Painel de pedidos
	oBrowsPed := FwBrowse():New()
	//oBrowsPed:DisableFilter()
	oBrowsPed:DisableConfig()
	oBrowsPed:DisableReport()
	oBrowsPed:DisableSeek()
	oBrowsPed:DisableSaveConfig()
	oBrowsPed:SetAlias(cAliasPed)
	oBrowsPed:SetDataTable()
	oBrowsPed:SetInsert(.F.)
	oBrowsPed:SetDelete(.F., { || .F. })
	oBrowsPed:lHeaderClick := .F.
	oBrowsPed:SetColumns(aColumPed)
	oBrowsPed:SetOwner(oGrpPed)
	oBrowsPed:SetLineHeight(09)
	oBrowsPed:SetChange({|| fRefrTran()})
	oBrowsPed:Activate()


	//Grid de Transportadora
	oGpFrete   := TGroup():New( 100,000,200,388," Transportadoras disponiveis por Pedido ",oPnlDvIn,CLR_HBLUE,CLR_WHITE,.T.,.F. )
	oGpFrete:align:= CONTROL_ALIGN_ALLCLIENT
	oBrowsTra := FwBrowse():New()
	oBrowsTra:DisableFilter()
	oBrowsTra:DisableConfig()
	oBrowsTra:DisableReport()
	oBrowsTra:DisableSeek()
	oBrowsTra:DisableSaveConfig()
	oBrowsTra:SetAlias(cAliasTra)
	oBrowsTra:SetDataTable()
	oBrowsTra:SetInsert(.F.)
	oBrowsTra:SetDelete(.F., { || .F. })
	oBrowsTra:lHeaderClick := .F.
	oBrowsTra:SetColumns(aColumTra)
	oBrowsTra:SetOwner(oGpFrete)
	oBrowsTra:SetLineHeight(09)
	oBrowsTra:SetFilterDefault("(cAliasPed)->nLinPFili = (cAliasTra)->nLinTFili .And. (cAliasPed)->nLinPNume = (cAliasTra)->nLinTNume")
	oBrowsTra:Activate()
	
	oJanSimul:lEscClose	:= .F. //Nao permite sair ao se pressionar a tecla ESC.
	oJanSimul:lCentered	:= .T.
	oJanSimul:Activate(,,,.T.)

	//Teste
	/*oRelacPed:= FWBrwRelation():New()
	oRelacPed:AddRelation(oBrowsTra,oBrowsPed,{{"(cAliasPed)->nLinPFili","(cAliasTra)->nLinTFili"},{"(cAliasPed)->nLinPNume","(cAliasTra)->nLinTNume"},{"(cAliasPed)->nLinPClie","(cAliasTra)->nLinTClie"}})
	oRelacPed:Activate()*/
/*	//Teste
	oRelacPed:= FWBrwRelation():New()
	oRelacPed:AddRelation(oBrowsTra,oBrowsPed,{{"(cAliasPed)->nLinPFili","(cAliasTra)->nLinTFili"},{"(cAliasPed)->nLinPNume","(cAliasTra)->nLinTNume"}})
	oRelacPed:Activate() */

Return .T.

//Fun��o para gerar o Log no console
Static Function OmsLogMsg(cMsg)
	FWLogMsg("INFO", "", "BusinessObject", "OMSA200A", "", "", cMsg, 0, 0)
Return

//Fun��o para chamar o calculo de frete com tela aberta
Static Function fCalFr()
	Local oSay 		  := NIL // CAIXA DE DI�LOGO GERADA
	FwMsgRun(,{ |oSay| fPrepFret(.T.,oSay) },'Executando calculo de frete da carga','Aguarde...')
Return .T.

//Fun��o para carregar a listagem de pedidos que est� na carga
Static Function fCargPed(cNumCar, cNumSeq)
	Local aAreaDAI  := DAI->(GetArea())
	Local aAreaSC5  := SC5->(GetArea())
	Local aAreaSA1  := SA1->(GetArea())
	Local aAreaSA2  := SA2->(GetArea())
	Local cCdEmis   := OMSM011COD(,,,.T.,xFilial("SF2"))
	Local cCdRem    := ""
	Local cCdDest   := ""
	Local cCnpj     := ""
	Local cUFCli    := ""
	Local cCidCli   := ""
	Local aItem     := {}
	Local nVlrCarga := 0
	Local cTranspor := Alltrim(Posicione("DAK",1,xFilial("DAK")+ cNumCar+cNumSeq,"DAK_TRANSP"))
	Local cPlacaVei := Alltrim(Posicione("DAK",1,xFilial("DAK")+ cNumCar+cNumSeq,"DAK_CAMINH"))
	Local cClassDAK := Alltrim(Posicione("DAK",1,xFilial("DAK")+ cNumCar+cNumSeq,"DAK_CDCLFR"))
	Local cOperaDAK := Alltrim(Posicione("DAK",1,xFilial("DAK")+ cNumCar+cNumSeq,"DAK_CDTPOP"))
	Local cTpDoc	:= ""

	IF Empty(cClassDAK)
		cClassDAK   := avKey(IIF(!Empty(DAK->DAK_CDTPOP	),Alltrim(DAK->DAK_CDTPOP), SuperGetMv("MV_CDTPOP",.F.,"")	) ,"DAK_CDTPOP"	)	//Codigo do Tipo de Opera��o
	EndIF
	IF Empty(cOperaDAK)
		cOperaDAK   := avKey(IIF(!Empty(DAK->DAK_CDCLFR	),Alltrim(DAK->DAK_CDCLFR), SuperGetMv("MV_CDCLFR",.F.,"")	) ,"DAK_CDCLFR"	)	//Codigo da Classifica��o de Frete
	EndIF

	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))

	DbSelectArea("SA2")
	SA2->(dbSetOrder(1))

	DbSelectArea("SA1")
	SA1->(dbSetOrder(1))

	DbSelectArea("DAI")
	DAI->(dbSetOrder(1))
	If DAI->(MsSeek(xFilial("DAI")+cNumCar+cNumSeq))
		While DAI->(!Eof()) .And. DAI->DAI_FILIAL == xFilial("DAI") .And. DAI->DAI_COD == cNumCar .And. DAI->DAI_SEQCAR == cNumSeq

			If  SC5->(DbSeek(xFilial("SC5",DAI->DAI_FILIAL)+DAI->DAI_PEDIDO))

				nQtdPedi += 1

				If !SC5->C5_TIPO $ "DB"
					SA1->( dbSeek( xFilial("SA1")+SC5->C5_CLIENT+SC5->C5_LOJAENT ) )
					cCnpj	:=  SA1->A1_CGC
					cUFCli	:=  SA1->A1_EST
					cCidCli	:=  SA1->A1_MUN
				Else
					SA2->( dbSeek( xFilial("SA2")+SC5->C5_CLIENT+SC5->C5_LOJAENT ) )
					cCnpj	:=  SA2->A2_CGC
					cUFCli	:=  SA2->A2_EST
					cCidCli	:=  SA2->A2_MUN				
				EndIF		

				cCdDest := IIF(MTA410ChkEmit(cCnpj),cCnpj, OMSM011COD(SC5->C5_CLIENT,SC5->C5_LOJAENT,1,,) )

				If SC5->(ColumnPos("C5_CLIRET")) > 0 .And. SC5->(ColumnPos("C5_LOJARET")) > 0 .And. !Empty(SC5->C5_CLIRET) .And. !Empty(SC5->C5_LOJARET)

					If !SC5->C5_TIPO $ "DB"
						SA1->( dbSeek( xFilial("SA1")+SC5->C5_CLIRET+SC5->C5_LOJARET ) )
					Else
						SA2->( dbSeek( xFilial("SA2")+SC5->C5_CLIRET+SC5->C5_LOJARET ) )
					EndIF

					//Verifica primeiro se existe a chave "NS" cadastrada, se n�o busca a chave "N". Mesmo tratamento utilizado no OMSM011.
					cTpDoc	:= AllTrim(Posicione("SX5",1,xFilial("SX5")+"MQ"+SC5->C5_TIPO+"S","X5_DESCRI"))
					If Empty(cTpDoc)
						cTpDoc := Posicione("SX5",1,xFilial("SX5")+"MQ"+SC5->C5_TIPO,"X5_DESCRI")
					EndIf

					cCdRem 	:= OMSM011COD(SC5->C5_CLIRET,SC5->C5_LOJARET,1)
					//Valida o remetente que ser� utilizado no Doc. de Carga, conforme o sentido configurado na rotina de Tipos de Documentos de Carga.
					If ( Posicione("GV5", 1, xFilial("GV5") + cTpDoc, "GV5_SENTID") == "2" .And. Posicione("GU3", 1, xFilial("GU3") + cCdRem, "GU3_EMFIL") == "2" )

						IF lSemMsFrt
							OmsLogMsg("O sentido (GV5_SENTID) do tipo de Documento: "+Alltrim(cTpDoc)+", est� configurado como sa�da."+CRLF+;
								"Dever� ser informado no campo 'Cli. Retirada' (C5_CLIRET) um remetente do tipo filial (GU3_EMFIL)."+;
								"Verifique o Pedido de Venda Nr.: "+Alltrim(SC5->C5_NUM) )
						else
							OmsHelp("O sentido (GV5_SENTID) do tipo de Documento: "+Alltrim(cTpDoc)+", est� configurado como sa�da."+CRLF+;
								"Dever� ser informado no campo 'Cli. Retirada' (C5_CLIRET) um remetente do tipo filial (GU3_EMFIL).",;
								"Verifique o Pedido de Venda Nr.: "+Alltrim(SC5->C5_NUM) )
						EndIF

						lFalhaSC5 := .T.
						Exit
					EndIf

				Else
					cCdRem := cCdEmis
				EndIf

				aItem := {}
				
				nVlrCarga := fTrazVlr(SC5->C5_FILIAL, cNumCar, cNumSeq, SC5->C5_NUM) //Trazer o valor do pedido

				Reclock(cAliasPed,.T.)
				(cAliasPed)->nLinPFili	:= SC5->C5_FILIAL
				(cAliasPed)->nLinPNume	:= SC5->C5_NUM
				(cAliasPed)->nLinPTipo 	:= SC5->C5_TIPO
				(cAliasPed)->nLinPClie 	:= SC5->C5_CLIENTE
				(cAliasPed)->nLinPLoja	:= SC5->C5_LOJACLI
				(cAliasPed)->nLinPValo	:= nVlrCarga
				(cAliasPed)->nLinPPeso 	:= DAI->DAI_PESO
				(cAliasPed)->nLinPVolu	:= DAI->DAI_CAPVOL
				(cAliasPed)->nLinPCOri 	:= Posicione("GU3",1,xFilial("GU3") + cCdRem	,"GU3_NRCID")
				(cAliasPed)->nLinPMOri	:= FWSM0Util():GetSM0Data(cEmpAnt , cFilAnt, { "M0_CIDCOB" } )[1][2]
				(cAliasPed)->nLinPEOri	:= FWSM0Util():GetSM0Data(cEmpAnt , cFilAnt, { "M0_ESTCOB" } )[1][2]
				(cAliasPed)->nLinPCDes	:= Posicione("GU3",1,xFilial("GU3") + cCdDest	,"GU3_NRCID")
				(cAliasPed)->nLinPMDes	:= cCidCli
				(cAliasPed)->nLinPEDes	:= cUFCli
				(cAliasPed)->nLinPEmit	:= cCdRem
				(cAliasPed)->nLinPDest	:= cCdDest
				(cAliasPed)->nLinPTran	:= cTranspor
				(cAliasPed)->nLinPPlac	:= cPlacaVei
				(cAliasPed)->nLinPClas	:= cClassDAK
				(cAliasPed)->nLinPOper	:= cOperaDAK
				(cAliasPed)->nLinPNego	:= cNegocia
				(cAliasPed)->nLinPTpVe	:= IIF(Empty(cPlacaVei), "", POSICIONE("DA3",1,xFilial("DA3")+cPlacaVei,"DA3_TIPVEI"))
				(cAliasPed)->nLinPKM	:= 0
				(cAliasPed)->nLinPTFre	:= SC5->C5_TPFRETE
				(cAliasPed)->(MsUnlock())

				IF cUFCli == "EX"
					lExisteEX := .T.
				EndIF
				
				IF (SC5->C5_TPFRETE != "C" .AND. SC5->C5_TPFRETE != "R")
					lExistFOB := .T.
				EndIF

				IF Alltrim(SC5->C5_TIPO) != "N"
					IExistNOR := .T.	
				EndIF

			EndIF
			DAI->(dbSkip())
		Enddo
	EndIF

	RestArea( aAreaSA1 )
	RestArea( aAreaSA2 )
	RestArea( aAreaDAI )
	RestArea( aAreaSC5 )

Return .T.


//Fun��o para criar a Tabela Resumo
Static Function CriTabRes()
	Local oColumn
	Local nAtual := 0
	aColumRes    := {}

	aAdd( aFieldRes	,{"nLinRCodi"	,TAMSX3("A4_COD")[3]	    ,TamSX3("A4_COD")[1]     	,TAMSX3("A4_COD")[2]	    ,FWX3Titulo("A4_COD")		,PESQPICT("SA4","A4_COD")	    ,.F.,""} )
	aAdd( aFieldRes	,{"nLinRNome"	,TAMSX3("A4_NOME")[3]		,TAMSX3("A4_NOME")[1]	    ,TAMSX3("A4_NOME")[2]		,FWX3Titulo("A4_NOME")		,PESQPICT("SA4","A4_NOME")		,.F.,""} )
	aAdd( aFieldRes	,{"nLinRValo"	,TAMSX3("GW8_VALOR")[3]  	,TamSX3("GW8_VALOR")[1]		,TAMSX3("GW8_VALOR")[2]    	,FWX3Titulo("GW8_VALOR")	,PESQPICT("GW8","GW8_VALOR")   	,.F.,""} )
	aAdd( aFieldRes	,{"nLinRQtde"	,"N"						,4   						,0							,"Qtde Ped."				,"9999"   						,.F.,""} )
	aAdd( aFieldRes	,{"nLinREmit"	,TAMSX3("GU3_CDEMIT")[3]  	,TamSX3("GU3_CDEMIT")[1]	,TAMSX3("GU3_CDEMIT")[2]    ,"Emitente GFE"				,PESQPICT("GU3","GU3_CDEMIT")   ,.F.,""} )

	oTableRes := FWTemporaryTable():New( cAliasRes )
	oTableRes:SetFields( aFieldRes )
	oTableRes:AddIndex("TRB_RES", {"nLinRCodi"} )
	oTableRes:Create()

	//Percorrendo e criando as colunas
	For nAtual := 1 To Len(aFieldRes)
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&("{|| " + cAliasRes + "->" + aFieldRes[nAtual][1] +"}"))
		oColumn:SetTitle(aFieldRes[nAtual][5])
		oColumn:SetType(aFieldRes[nAtual][2])
		oColumn:SetSize(aFieldRes[nAtual][3])
		oColumn:SetDecimal(aFieldRes[nAtual][4])
		oColumn:SetPicture(aFieldRes[nAtual][6])
		oColumn:SetAlign( If(aFieldRes[nAtual][2] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )
		oColumn:SetEdit( .F. )
		aAdd(aColumRes, oColumn)
	Next nAtual

Return

//Fun��o para criar a Tabela Pedido
Static Function CriTabPed()
	Local oColumn
	Local nAtual
	aColumPed := {}

	aAdd( aFieldPed	,{"nLinPFili"	,TAMSX3("C5_FILIAL")[3]		,TamSX3("C5_FILIAL")[1]		,TAMSX3("C5_FILIAL")[2]		,FWX3Titulo("C5_FILIAL")	,PESQPICT("SC5","C5_FILIAL")	,.F.,""} )
	aAdd( aFieldPed	,{"nLinPNume"	,TAMSX3("C5_NUM")[3]	    ,TamSX3("C5_NUM")[1]     	,TAMSX3("C5_NUM")[2]	    ,FWX3Titulo("C5_NUM")		,PESQPICT("SC5","C5_NUM")	    ,.F.,""} )
	aAdd( aFieldPed	,{"nLinPTipo"	,TAMSX3("C5_TIPO")[3]		,TAMSX3("C5_TIPO")[1]	    ,TAMSX3("C5_TIPO")[2]		,FWX3Titulo("C5_TIPO")		,PESQPICT("SC5","C5_TIPO")		,.F.,""} )
	aAdd( aFieldPed	,{"nLinPClie"	,TAMSX3("C5_CLIENTE")[3]  	,TamSX3("C5_CLIENTE")[1]	,TAMSX3("C5_CLIENTE")[2]    ,FWX3Titulo("C5_CLIENTE")	,PESQPICT("SC5","C5_CLIENTE")   ,.F.,""} )
	aAdd( aFieldPed	,{"nLinPLoja"	,TAMSX3("C5_LOJACLI")[3]	,TamSX3("C5_LOJACLI")[1]    ,TAMSX3("C5_LOJACLI")[2]    ,FWX3Titulo("C5_LOJACLI")	,PESQPICT("SC5","C5_LOJACLI")   ,.F.,""} )
	aAdd( aFieldPed	,{"nLinPValo"	,TAMSX3("DAK_VALOR")[3]   	,TamSX3("DAK_VALOR")[1]		,TAMSX3("DAK_VALOR")[2]     ,"Valor Pedido"				,PESQPICT("DAK","DAK_VALOR")    ,.F.,""} )
	aAdd( aFieldPed	,{"nLinPPeso"	,TAMSX3("DAK_PESO")[3]		,TamSX3("DAK_PESO")[1]		,TAMSX3("DAK_PESO")[2]		,FWX3Titulo("DAK_PESO")		,PESQPICT("DAK","DAK_PESO")		,.F.,""} )
	aAdd( aFieldPed	,{"nLinPVolu"	,TAMSX3("DAI_CAPVOL")[3]	,TamSX3("DAI_CAPVOL")[1]	,TAMSX3("DAI_CAPVOL")[2]	,FWX3Titulo("DAI_CAPVOL")	,PESQPICT("DAI","DAI_CAPVOL")	,.F.,""} )
	aAdd( aFieldPed	,{"nLinPCOri"   ,TAMSX3("GU3_NRCID")[3]   	,TamSX3("GU3_NRCID")[1]		,TAMSX3("GU3_NRCID")[2]     ,"IBGE Orig."				,PESQPICT("GU3","GU3_NRCID")    ,.F.,""} )
	aAdd( aFieldPed	,{"nLinPMOri"	,TAMSX3("A1_MUN")[3]      	,TamSX3("A1_MUN")[1]     	,TAMSX3("A1_MUN")[2]        ,"Cidade Orig."				,PESQPICT("SA1","A1_MUN")       ,.F.,""} )
	aAdd( aFieldPed	,{"nLinPEOri"	,TAMSX3("A1_EST")[3]      	,TamSX3("A1_EST")[1]        ,TAMSX3("A1_EST")[2]        ,"UF. Origem"				,PESQPICT("SA1","A1_EST")       ,.F.,""} )
	aAdd( aFieldPed	,{"nLinPCDes"   ,TAMSX3("GU3_NRCID")[3]   	,TamSX3("GU3_NRCID")[1]		,TAMSX3("GU3_NRCID")[2]     ,"IBGE Dest."				,PESQPICT("GU3","GU3_NRCID")    ,.F.,""} )
	aAdd( aFieldPed	,{"nLinPMDes"	,TAMSX3("A1_MUN")[3]      	,TamSX3("A1_MUN")[1]		,TAMSX3("A1_MUN")[2]        ,"Cidade Dest."				,PESQPICT("SA1","A1_MUN")       ,.F.,""} )
	aAdd( aFieldPed	,{"nLinPEDes"	,TAMSX3("A1_EST")[3]      	,TamSX3("A1_EST")[1]        ,TAMSX3("A1_EST")[2]        ,"UF. Desti."				,PESQPICT("SA1","A1_EST")       ,.F.,""} )
	aAdd( aFieldPed	,{"nLinPEmit"	,TAMSX3("GU3_CDEMIT")[3]  	,TamSX3("GU3_CDEMIT")[1]	,TAMSX3("GU3_CDEMIT")[2]    ,"Remetente GFE"			,PESQPICT("GU3","GU3_CDEMIT")   ,.F.,""} )
	aAdd( aFieldPed	,{"nLinPDest"	,TAMSX3("GU3_CDEMIT")[3]  	,TamSX3("GU3_CDEMIT")[1]    ,TAMSX3("GU3_CDEMIT")[2]    ,"Destinatario GFE"			,PESQPICT("GU3","GU3_CDEMIT")   ,.F.,""} )
	aAdd( aFieldPed	,{"nLinPTran"	,TAMSX3("DAK_TRANSP")[3]	,TamSX3("DAK_TRANSP")[1]	,TAMSX3("DAK_TRANSP")[2]	,FWX3Titulo("DAK_TRANSP")	,PESQPICT("DAK","DAK_TRANSP")	,.F.,""} )
	aAdd( aFieldPed	,{"nLinPPlac"	,TAMSX3("DAK_CAMINH")[3]	,TamSX3("DAK_CAMINH")[1]	,TAMSX3("DAK_CAMINH")[2]	,FWX3Titulo("DAK_CAMINH")	,PESQPICT("DAK","DAK_CAMINH")	,.F.,""} )
	aAdd( aFieldPed	,{"nLinPClas"	,TAMSX3("DAK_CDCLFR")[3]	,TamSX3("DAK_CDCLFR")[1]	,TAMSX3("DAK_CDCLFR")[2]	,FWX3Titulo("DAK_CDCLFR")	,PESQPICT("DAK","DAK_CDCLFR")	,.F.,""} )
	aAdd( aFieldPed	,{"nLinPOper"	,TAMSX3("DAK_CDTPOP")[3]	,TamSX3("DAK_CDTPOP")[1]	,TAMSX3("DAK_CDTPOP")[2]	,FWX3Titulo("DAK_CDTPOP")	,PESQPICT("DAK","DAK_CDTPOP")	,.F.,""} )
	aAdd( aFieldPed	,{"nLinPNego"	,"C"						,1							,0							,"Negocia��o"				,"@!"							,.F.,""} )
	aAdd( aFieldPed	,{"nLinPTpVe"	,TAMSX3("DA3_TIPVEI")[3]	,TamSX3("DA3_TIPVEI")[1]	,TAMSX3("DA3_TIPVEI")[2]	,FWX3Titulo("DA3_TIPVEI")	,PESQPICT("DA3","DA3_TIPVEI")	,.F.,""} )
	aAdd( aFieldPed	,{"nLinPKM"		,TAMSX3("GWN_DISTAN")[3]	,TamSX3("GWN_DISTAN")[1]	,TAMSX3("GWN_DISTAN")[2]	,FWX3Titulo("GWN_DISTAN")	,PESQPICT("GWN","GWN_DISTAN")	,.F.,""} )
	aAdd( aFieldPed	,{"nLinPTFre"	,TAMSX3("C5_TPFRETE")[3]	,TamSX3("C5_TPFRETE")[1]	,TAMSX3("C5_TPFRETE")[2]	,FWX3Titulo("C5_TPFRETE")	,PESQPICT("SC5","C5_TPFRETE")	,.F.,""} )

	oTablePed := FWTemporaryTable():New( cAliasPed )
	oTablePed:SetFields( aFieldPed )
	oTablePed:AddIndex("TRB_PED", {"nLinPFili", "nLinPNume", "nLinPClie","nLinPLoja", "nLinPTipo"} )
	oTablePed:Create()

	//Percorrendo e criando as colunas
	For nAtual := 1 To Len(aFieldPed)
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&("{|| " + cAliasPed + "->" + aFieldPed[nAtual][1] +"}"))
		oColumn:SetTitle(aFieldPed[nAtual][5])
		oColumn:SetType(aFieldPed[nAtual][2])
		oColumn:SetSize(aFieldPed[nAtual][3])
		oColumn:SetDecimal(aFieldPed[nAtual][4])
		oColumn:SetPicture(aFieldPed[nAtual][6])
		oColumn:SetAlign( If(aFieldPed[nAtual][2] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )
		oColumn:SetEdit( .F. )
		aAdd(aColumPed, oColumn)
	Next nAtual

Return

//Fun��o para criar a Headers Transportadora
Static Function CriTabTra()
	Local oColumn
	Local nAtual
	aColumTra := {}

	aAdd( aFieldTra	,{"nLinTCodi"	,TAMSX3("A4_COD")[3]	    ,TamSX3("A4_COD")[1]     	,TAMSX3("A4_COD")[2]	    ,FWX3Titulo("A4_COD")		,PESQPICT("SA4","A4_COD")	    ,.F.,""} )
	aAdd( aFieldTra	,{"nLinTNome"	,TAMSX3("A4_NOME")[3]		,TAMSX3("A4_NOME")[1]	    ,TAMSX3("A4_NOME")[2]		,FWX3Titulo("A4_NOME")		,PESQPICT("SA4","A4_NOME")		,.F.,""} )
	aAdd( aFieldTra	,{"nLinTValo"	,TAMSX3("GW8_VALOR")[3]  	,TamSX3("GW8_VALOR")[1]		,TAMSX3("GW8_VALOR")[2]    	,FWX3Titulo("GW8_VALOR")	,PESQPICT("GW8","GW8_VALOR")   	,.F.,""} )
	aAdd( aFieldTra	,{"nLinTQtde"	,TAMSX3("DAK_DATA")[3]  	,TamSX3("DAK_DATA")[1]		,TAMSX3("DAK_DATA")[2]    	,"Prev. Entrega" 			,PESQPICT("DAK","DAK_DATA")   	,.F.,""} )
	aAdd( aFieldTra	,{"nLinTFili"	,TAMSX3("C5_FILIAL")[3]		,TamSX3("C5_FILIAL")[1]		,TAMSX3("C5_FILIAL")[2]		,FWX3Titulo("C5_FILIAL")	,PESQPICT("SC5","C5_FILIAL")	,.F.,""} )
	aAdd( aFieldTra	,{"nLinTNume"	,TAMSX3("C5_NUM")[3]	    ,TamSX3("C5_NUM")[1]     	,TAMSX3("C5_NUM")[2]	    ,FWX3Titulo("C5_NUM")		,PESQPICT("SC5","C5_NUM")	    ,.F.,""} )
	aAdd( aFieldTra	,{"nLinTTipo"	,TAMSX3("C5_TIPO")[3]		,TAMSX3("C5_TIPO")[1]	    ,TAMSX3("C5_TIPO")[2]		,FWX3Titulo("C5_TIPO")		,PESQPICT("SC5","C5_TIPO")		,.F.,""} )
	aAdd( aFieldTra	,{"nLinTClie"	,TAMSX3("C5_CLIENTE")[3]  	,TamSX3("C5_CLIENTE")[1]	,TAMSX3("C5_CLIENTE")[2]    ,FWX3Titulo("C5_CLIENTE")	,PESQPICT("SC5","C5_CLIENTE")   ,.F.,""} )
	aAdd( aFieldTra	,{"nLinTLoja"	,TAMSX3("C5_LOJACLI")[3]	,TamSX3("C5_LOJACLI")[1]    ,TAMSX3("C5_LOJACLI")[2]    ,FWX3Titulo("C5_LOJACLI")	,PESQPICT("SC5","C5_LOJACLI")   ,.F.,""} )
	aAdd( aFieldTra	,{"nLinTGU3"	,TAMSX3("GU3_CDEMIT")[3]  	,TamSX3("GU3_CDEMIT")[1]    ,TAMSX3("GU3_CDEMIT")[2]    ,"Emitente GFE"				,PESQPICT("GU3","GU3_CDEMIT")   ,.F.,""} )

	oTableTra := FWTemporaryTable():New( cAliasTra )
	oTableTra:SetFields( aFieldTra )
	oTableTra:AddIndex("TRB_TRA"	, {"nLinTCodi"} )
	oTableTra:AddIndex("TRB_TRAP"	, {"nLinTFili", "nLinTNume", "nLinTClie", "nLinTLoja"} )
	oTableTra:Create()

	//Percorrendo e criando as colunas
	For nAtual := 1 To Len(aFieldTra)
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&("{|| " + cAliasTra + "->" + aFieldTra[nAtual][1] +"}"))
		oColumn:SetTitle(aFieldTra[nAtual][5])
		oColumn:SetType(aFieldTra[nAtual][2])
		oColumn:SetSize(aFieldTra[nAtual][3])
		oColumn:SetDecimal(aFieldTra[nAtual][4])
		oColumn:SetPicture(aFieldTra[nAtual][6])
		oColumn:SetAlign( If(aFieldTra[nAtual][2] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )
		oColumn:SetEdit( .F. )

		aAdd(aColumTra, oColumn)
	Next nAtual

Return

//Fun��o para travar os bot�es referente as configura��es de calculo.
Static Function TrvCamp(lLiberar)
	IF lLiberar
		oEdtValor:Enable()
		oEdtPes:Enable()
		oEdtVolu:Enable()
		oEdtKM:Enable()
		oEdtTipo:Enable()
		oEdtClas:Enable()
		oEdtTVei:Enable()
		oEdtTra:Enable()
		oCmbNego:Enable()
	else
		oEdtValor:Disable()
		oEdtPes:Disable()
		oEdtVolu:Disable()
		oEdtKM:Disable()
		oEdtTipo:Disable()
		oEdtClas:Disable()
		oEdtTVei:Disable()
		oEdtTra:Disable()
		oCmbNego:Disable()
	EndIF

Return .T.

//Fun��o para valida��o de Campos
Static Function fValCmp(nCampo, cConteudo, lTelAbert)
	Local lRetVld  := .T.
	Local aRetPE01 := .T.
	Local cTmpVld  := ""
	Local aAreaAtu := GetArea()

	Default lTelAbert := .F.

	//Valida��o apenas se campos estiverem abertos e se n�o for na abertura da tela.
	IF lLibCampo .AND. lTelAbert
		//Realiza as valida��es padr�es
		Do Case
		Case nCampo == 1 //Valor da Mercadoria
			IF cConteudo < 0
				IF lSemMsFrt
					OmsLogMsg("Valor da Mercadora n�o pode ser valor negativo. Verificar conteudo do Campo de Valor de Mercadoria.")
				else
					OmsHelp("Valor da Mercadora n�o pode ser valor negativo.","Verificar conteudo do Campo de Valor de Mercadoria.")
				EndIF
				lRetVld := .F.
			EndIF

		Case nCampo == 2 //Peso da Carga
			IF cConteudo < 0
				IF lSemMsFrt
					OmsLogMsg("Peso da Carga n�o pode ser valor negativo. Verificar conteudo do Campo de Peso da Carga.")
				else
					OmsHelp("Peso da Carga n�o pode ser valor negativo.","Verificar conteudo do Campo de Peso da Carga.")
				EndIF
				lRetVld := .F.				
			EndIF
			
		Case nCampo == 3 //Volume da Carga
			IF cConteudo < 0
				IF lSemMsFrt
					OmsLogMsg("Volume da Carga n�o pode ser valor negativo. Verificar conteudo do Campo de Volume da Carga.")
				else
					OmsHelp("Volume da Carga n�o pode ser valor negativo.","Verificar conteudo do Campo de Volume da Carga.")
				EndIF
				lRetVld := .F.
			EndIF			

		Case nCampo == 4 //KM da Carga
			IF cConteudo < 0
				IF lSemMsFrt
					OmsLogMsg("Percurso (KM) da Carga n�o pode ser valor negativo. Verificar conteudo do Campo de Percurso (KM) da Carga.")
				else
					OmsHelp("Percurso (KM) da Carga n�o pode ser valor negativo.","Verificar conteudo do Campo de Percurso (KM) da Carga.")
				EndIF
				lRetVld := .F.
			EndIF
			
		Case nCampo == 5 //Tipo de Opera��o

			cConteudo := avKey(Alltrim(cConteudo) ,"GV4_CDTPOP"	) //Igualar campo para pesquisar corretamente na tabela

			IF !Empty(cConteudo)
				If !fVldTabe("GV4", cConteudo)
					IF lSemMsFrt
						OmsLogMsg("Tipo de Opera��o n�o existe (GV4). Verificar conteudo do Campo de Tipo de Opera��o.")
					else
						OmsHelp("Tipo de Opera��o n�o existe (GV4).","Verificar conteudo do Campo de Tipo de Opera��o.")
					EndIF
					lRetVld := .F.
				else

					cTmpVld := POSICIONE("GV4",1,xFilial("GV4")+cConteudo,"GV4_SIT")

					IF cTmpVld != "1"
						IF lSemMsFrt
							OmsLogMsg("Tipo de Opera��o est� com Situa��o Bloqueada. Verificar conteudo do Campo de Tipo de Opera��o.")
						else
							OmsHelp("Tipo de Opera��o est� com Situa��o Bloqueada.","Verificar conteudo do Campo de Tipo de Opera��o.")
						EndIF
						lRetVld := .F.
					EndIF

				EndIf
			EndIF

		Case nCampo == 6 //Classifica��o de Frete

			cConteudo := avKey(Alltrim(cConteudo) ,"GUB_CDCLFR"	) //Igualar campo para pesquisar corretamente na tabela

			IF !Empty(cConteudo)
				If !fVldTabe("GUB", cConteudo)
					IF lSemMsFrt
						OmsLogMsg("Classifica��o de Frete n�o existe (GUB). Verificar conteudo do Campo de Classifica��o de Frete.")
					else
						OmsHelp("Classifica��o de Frete n�o existe (GUB).","Verificar conteudo do Campo de Classifica��o de Frete.")
					EndIF
					lRetVld := .F.
				else

					cTmpVld := POSICIONE("GUB",1,xFilial("GUB")+cConteudo,"GUB_SIT")

					IF cTmpVld != "1"
						IF lSemMsFrt
							OmsLogMsg("Classifica��o de Frete est� com Situa��o Bloqueada. Verificar conteudo do Campo de Classifica��o de Frete.")
						else
							OmsHelp("Classifica��o de Frete est� com Situa��o Bloqueada.","Verificar conteudo do Campo de Classifica��o de Frete.")
						EndIF
						lRetVld := .F.
					EndIF

				EndIf
			EndIF

		Case nCampo == 7 //Tipo de Veiculo

			cConteudo := avKey(Alltrim(cConteudo) ,"DUT_TIPVEI"	) //Igualar campo para pesquisar corretamente na tabela

			IF !Empty(cConteudo)
				If !fVldTabe("DUT", cConteudo)
					IF lSemMsFrt
						OmsLogMsg("Tipo de Veiculo n�o existe (DUT). Verificar conteudo do Campo de Tipo de Veiculo.")
					else
						OmsHelp("Tipo de Veiculo n�o existe (DUT).","Verificar conteudo do Campo de Tipo de Veiculo.")
					EndIF
					lRetVld := .F.
				else

					cConteudo := avKey(Alltrim(cConteudo) ,"GV3_CDTPVC"	) //Igualar campo para pesquisar corretamente na tabela
					If !fVldTabe("GV3", cConteudo)
						IF lSemMsFrt
							OmsLogMsg("Tipo de Veiculo n�o integrado com GFE (GV3). Verificar conteudo do Campo de Tipo de Veiculo.")
						else
							OmsHelp("Tipo de Veiculo n�o integrado com GFE (GV3).","Verificar conteudo do Campo de Tipo de Veiculo.")
						EndIF
						lRetVld := .F.
					else
						cTmpVld := POSICIONE("GV3",1,xFilial("GV3")+cConteudo,"GV3_SIT")

						IF cTmpVld != "1"
							IF lSemMsFrt
								OmsLogMsg("Tipo de Veiculo est� com Situa��o Bloqueada no GFE. Verificar situa��o do Campo de Tipo de Veiculo dentro do GFE.")
							else
								OmsHelp("Tipo de Veiculo est� com Situa��o Bloqueada no GFE.","Verificar situa��o do Campo de Tipo de Veiculo dentro do GFE.")
							EndIF
							lRetVld := .F.
						EndIF
					EndIF
				EndIf
			EndIF

		Case nCampo == 8 //Transportadora de Veiculo

			cConteudo := avKey(Alltrim(cConteudo) ,"A4_COD"	) //Igualar campo para pesquisar corretamente na tabela

			IF !Empty(cConteudo)
				If !fVldTabe("SA4", cConteudo)
					IF lSemMsFrt
						OmsLogMsg("Transportadora n�o existe (SA4). Verificar conteudo do Campo de Transportadora.")
					else
						OmsHelp("Transportadora n�o existe (SA4).","Verificar conteudo do Campo de Transportadora.")
					EndIF
					lRetVld := .F.
				else
					IF SA4->(FieldPos("A4_MSBLQL") > 0)
                        cTmpVld := POSICIONE("SA4",1,xFilial("SA4")+cConteudo,"A4_MSBLQL")
                    Else
                        cTmpVld := "2"
                    EndIF
					IF cTmpVld == "1"
						IF lSemMsFrt
							OmsLogMsg("Transportadora est� com Situa��o Bloqueada. Verificar conteudo do Campo de Transportadora.")
						else
							OmsHelp("Transportadora est� com Situa��o Bloqueada.","Verificar conteudo do Campo de Transportadora.")
						EndIF
						lRetVld := .F.
					Else

						cConteudo := avKey(Alltrim(cConteudo) ,"GU3_CDTERP"	) //Igualar campo para pesquisar corretamente na tabela
						lRetVld := fVlSA4GU3(cConteudo, .T.)

					EndIF
				EndIf
			EndIF

		EndCase

		//Somente entra no PE se retorno padr�o for verdadeiro
		//Ponto de entrada para usu�rio customizar a valida��o do campo ao ser preenchido quando estiver com processo em tela
		IF lOM200A03 .AND. lRetVld .AND. lLibCampo .AND. lTelAbert
			OmsLogMsg("Existe o ponto de entrada OM200A03.")
			aRetPE01 := ExecBlock("OM200A03",.F.,.F.,{cCodDAK, cSeqDAK, nCampo, cConteudo}) //Envio: Codigo da Carga, Sequ�ncia da Carga, Nr. do Campo de Valida��o e Conteudo do Campo // Retorno: Array contendo se a valida��o est� correta e o conteudo do campo
			If ValType(aRetPE01)=="A" .AND. aRetPE01[1] == 2
				IF ValType(aRetPE01[1,1])=="L"
					lRetVld		:= aRetPE01[1,1]
				Else
					IF lSemMsFrt
						OmsLogMsg("Executou ponto de entrada OM200A03 e o retorno do array veio fora do padr�o: Esperava ser L�gico o primeiro item do array.") // Esta carga j� se encontra faturada.
					EndIF
					lRetVld   := .F.
				EndIF

				cConteudo	:= aRetPE01[1,2]
			Else
				OmsLogMsg("Retorno do ponto de entrada OM200A03 n�o est� dentro das valida��es.")
			EndIf
		EndIF

		//Preencho o campo quando necess�rio, se retorno for falso limpa o campo
		Do Case
		Case nCampo == 1 //Valor da Mercadoria
			nEdtValor := IIF(lRetVld .OR. ValType(cConteudo) =="N",cConteudo,nEdtVlrMe)
			IF nEdtValor < 0
				nEdtValor := 0
			EndIF
			oEdtValor:Refresh()

		Case nCampo == 2 //Peso da Carga
			nEdtPes := IIF(lRetVld .OR. ValType(cConteudo) =="N" ,cConteudo,nEdtPeso)
			IF nEdtPes < 0
				nEdtPes := 0
			EndIF
			oEdtPes:Refresh()

		Case nCampo == 3 //Volume da Carga
			nEdtVolu := IIF(lRetVld .OR. ValType(cConteudo) =="N",cConteudo,cEdtVolCa)
			IF nEdtVolu < 0
				nEdtVolu := 0
			EndIF
			oEdtVolu:Refresh()

		Case nCampo == 4 //KM da Carga
			nEdtKM := IIF(lRetVld .OR. ValType(cConteudo) =="N",cConteudo,0)
			IF nEdtKM < 0
				nEdtKM := 0
			EndIF
			oEdtKM:Refresh()

		Case nCampo == 5 //Tipo de Opera��o
			cEdtTipo := IIF(lRetVld .OR. ValType(cConteudo) =="C",cConteudo,"")
			cEdtDTip := IIF(lRetVld,Alltrim(POSICIONE("GV4",1,xFilial("GV4")+cEdtTipo,"GV4_DSTPOP") ),"")
			IF Empty(cEdtDTip)
				cEdtDTip := ""
				cEdtTipo := avKey("" ,"DAK_CDTPOP"	)
			EndIF
			oEdtTipo:Refresh()
			oEdtDTip:Refresh()

		Case nCampo == 6 //Classifica��o de Frete
			cEdtClas := IIF(lRetVld .OR. ValType(cConteudo) =="C",cConteudo,"")
			cEdtDCla := IIF(lRetVld,Alltrim(POSICIONE("GUB",1,xFilial("GUB")+cEdtClas,"GUB_DSCLFR") ),"")
			IF Empty(cEdtDCla)
				cEdtDCla := ""
				cEdtClas := avKey("" ,"DAK_CDCLFR"	)
			EndIF
			oEdtClas:Refresh()
			oEdtDCla:Refresh()

		Case nCampo == 7 //Tipo de Veiculo
			cEdtTVei := IIF(lRetVld .OR. ValType(cConteudo) =="C" ,cConteudo,"")
			cEdtDTVe := IIF(lRetVld,Alltrim(POSICIONE("DUT",1,xFilial("DUT")+cEdtTVei,"DUT_DESCRI") ),"")
			IF Empty(cEdtDTVe)
				cEdtDTVe := ""
				cEdtTVei := avKey("" ,"GWU_CDTPVC"	)
			EndIF
			oEdtTVei:Refresh()
			oEdtDTVe:Refresh()

		Case nCampo == 8 //Transportadora de Veiculo
			cEdtTra := IIF(lRetVld .OR. ValType(cConteudo) =="C" ,cConteudo,"")
			cEdtDTr := IIF(lRetVld,Alltrim(POSICIONE("SA4",1,xFilial("SA4")+cEdtTra,"A4_NOME") ),"")
			IF Empty(cEdtDTr)
				cEdtDTr := ""
				cEdtTra := avKey("" ,"DAK_TRANSP"	)
			EndIF
			oEdtTra:Refresh()
			oEdtDTr:Refresh()

		EndCase

	EndIF

	RestArea( aAreaAtu )

Return lRetVld

//Fun��o para validar se a transportadora est� OK no GFE
Static Function fVlSA4GU3(cTmpSA4, lMsgAvs)
	Local lRetVld := .T.
	Local lAchou  := .F.
	Local aAreaGU3 := GU3->(GetArea())

	Default lMsgAvs := .T.
	
	// Pode existir mais de um emitente referenciando o mesmo transportador no ERP
	DbSelectArea("GU3")
	GU3->( dbSetOrder(13) )
	If GU3->( dbSeek( xFilial("GU3")+cTmpSA4 ) )
		lAchou := .F.

		While !GU3->(Eof()) .And. GU3->GU3_FILIAL+GU3->GU3_CDTERP == xFilial("GU3")+cTmpSA4
			IF (GU3->GU3_TRANSP == '1' .OR. GU3->GU3_AUTON == '1') .AND. GU3->GU3_FORN == "1"
				If GU3->GU3_SIT != "1"
					IF lMsgAvs
						IF lSemMsFrt
							OmsLogMsg("Transportadora est� com Situa��o Bloqueada no GFE. Verificar situa��o do Campo de Transportadora.")
						else
							OmsHelp("Transportadora est� com Situa��o Bloqueada no GFE.","Verificar situa��o do Campo de Transportadora.")
						EndIF
					EndIF
					lRetVld := .F.
					Exit

				EndIF

				lAchou := .T.
			EndIf
			GU3->(DbSkip())
		EndDo

		IF !lAchou
			IF lMsgAvs
				IF lSemMsFrt
					OmsLogMsg("Transportadora vinculada no GFE est� incorreta. Verificar situa��o da Transportadora dentro do GFE.")
				else
					OmsHelp("Transportadora vinculada no GFE est� incorreta.","Verificar situa��o da Transportadora dentro do GFE.")
				EndIF
			EndIF
			lRetVld := .F.
		EndIF

	Else
		IF lMsgAvs
			IF lSemMsFrt
				OmsLogMsg("Transportadora n�o est� integrada no GFE. Verificar integra��o da Transportadora no GFE.")
			else
				OmsHelp("Transportadora n�o est� integrada no GFE.","Verificar integra��o da Transportadora no GFE.")
			EndIF
		EndIF
		lRetVld := .F.
	EndIf

	RestArea( aAreaGU3 )

Return lRetVld

//Fun��o para validar os registros em tabelas para n�o dispara mensagem que campo n�o existe.
Static Function fVldTabe(cCodTab, cContTab)
	Local lRetVld 	:= .T.
	Local aArea		:= GetArea()
	Local aAreaTab	:= {}

	Do Case
	Case cCodTab == "GV4"
		aAreaTab	:= GV4->( GetArea() )
		
		dbSelectArea("GV4")
		GV4->(dbSetOrder(1))
		If GV4->(!MsSeek(xFilial("GV4")+cContTab) )
			lRetorna := .F.
		EndIf 

		RestArea(aAreaTab)

	Case cCodTab == "GUB"

		aAreaTab	:= GUB->( GetArea() )

		dbSelectArea("GUB")
		GUB->(dbSetOrder(1))
		If GUB->(!MsSeek(xFilial("GUB")+cContTab) )
			lRetorna := .F.
		EndIf 

		RestArea(aAreaTab)

	Case cCodTab == "DUT"

		aAreaTab	:= DUT->( GetArea() )

		dbSelectArea("DUT")
		DUT->(dbSetOrder(1))
		If DUT->(!MsSeek(xFilial("DUT")+cContTab) )
			lRetorna := .F.
		EndIf 

		RestArea(aAreaTab)

	Case cCodTab == "GV3"

		aAreaTab	:= GV3->( GetArea() )

		dbSelectArea("GV3")
		GV3->(dbSetOrder(1))
		If GV3->(!MsSeek(xFilial("GV3")+cContTab) )
			lRetorna := .F.
		EndIf 

		RestArea(aAreaTab)

	Case cCodTab == "SA4"

		aAreaTab	:= SA4->( GetArea() )

		dbSelectArea("SA4")
		SA4->(dbSetOrder(1))
		If SA4->(!MsSeek(xFilial("SA4")+cContTab) )
			lRetorna := .F.
		EndIf 	

		RestArea(aAreaTab)

	Otherwise
		lRetVld := .F.
	EndCase

	RestArea(aArea)
Return lRetVld

//Fun��o para fechar tela
Static function fFechar()
	Local lRet      := .T.
	Local aPE00A04  := .F. //Variavel de retorno do Ponto de Entrada
	Local lPE00A04	:= .F. //Variavel de retorno do Ponto de Entrada que vai gerenciar se pode fechar a tela
	Local lRet00A04 := .F. //Variavel de retorno do Ponto de Entrada que vai assumir a variavel lRetorno
	Local aRet00A04 := {} //Variavel de retorno do Ponto de Entrada que vai assumir a variavel aTabFrete

	//Ponto de entrada para usu�rio validar algo antes de fechar a tela de calculo de frete quando estiver com processo em tela
	IF lOM200A04
		OmsLogMsg("Existe o ponto de entrada OM200A04.")
		aPE00A04 := ExecBlock("OM200A04",.F.,.F.,{cCodDAK, cSeqDAK, lRetorno, aTabFrete}) //Envio: Codigo da Carga, Sequ�ncia da Carga, Variavel de Retorno da Rotina e Tabelas de Fretes do Calculo // Retorno: Array com a valida��o de fechamento da tela, valida��o de calculo e tabelas de frete.
		If ValType(aPE00A04)=="A" .AND. aPE00A04[1] == 3
			IF ValType(aPE00A04[1,1]) == "L" .AND. ValType(aPE00A04[1,2]) == "L" .AND. ValType(aPE00A04[1,2]) == "A" 
				lPE00A04 	:= aPE00A04[1,1]			
				lRet00A04	:= aPE00A04[1,2]
				aRet00A04	:= aPE00A04[1,3]

				IF lPE00A04
					lRetorno	:= lRet00A04
					aTabFrete	:= aRet00A04
				Else
					lRet	:= .F.
					IF lSemMsFrt
						OmsLogMsg("Executou ponto de entrada OM200A04 e seu retorno foi FALSE.") // Esta carga j� se encontra faturada.
					EndIF

					Return .T.

				EndIF

			EndIF
		Else
			OmsLogMsg("Retorno do ponto de entrada OM200A04 n�o est� dentro das valida��es.")
		EndIf
	EndIF

	IF lRet
		oJanSimul:End()
	EndIF

Return .T.

//Fun��o para visualizar a carga posicionada
Static Function fVisCarga()

	Private bFiltraBrw := {|| Nil}
	Private cCadastro  := OemtoAnsi("Visualiza��o Carga")
	Private n          := 1
	Private aArrayCli  := {}
	Private nIndice    := 5
	Private aRotAuto   := {}
	Private aAutoItens := {}
	Private xArrCarga  := {}
	Private aVisErr    := {}
	Os200Visual("DAK",DAK->(recno())) // Visualiza��o Carga

Return .T.

//Fun��o para trazer o valor do pedido
Static Function fTrazVlr(cFilSC9, cCarSC9, cSeqSC9, cNumPed)
	Local nRetVlr := 0
	Local cAliasQry := GetNextAlias()

	BeginSql Alias cAliasQry
		SELECT SUM(C9_QTDLIB * C9_PRCVEN) AS VALOR
		FROM %Table:SC9% SC9
		WHERE SC9.C9_FILIAL  = %Exp:cFilSC9%
		AND SC9.C9_CARGA = %Exp:cCarSC9%
		AND SC9.C9_SEQCAR = %Exp:cSeqSC9%
		AND SC9.C9_PEDIDO = %Exp:cNumPed%
		AND SC9.%NotDel%
	EndSql
	Do While !(cAliasQry)->(Eof())
		nRetVlr += (cAliasQry)->VALOR
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

Return nRetVlr

//Fun��o para preparar o calculo de cada pedido
Static Function fPrepFret(lBotao, oTexCal)
	Local cNomTra    := oTableTra:GetRealName()
	Local cDelTra    := "DELETE FROM " + cNomTra

	Local cNomRes    := oTableRes:GetRealName()
	Local cDelRes    := "DELETE FROM " + cNomRes

	Local cAliaTmp   := oTablePed:GetAlias()
	Local aItemPed   := {}

	Local nTmpVlr    := 0
	Local nTmpPes    := 0
	Local nTmpVol    := 0
	Local nTmpKM     := 0

	Local aRetPE06   := {}
	Local lTelPE06   := IIF(lLibCampo .AND. lBotao, .T., .F.) //Indica se os Campos est�o liberados e se foi a partir do clique do bot�o de Calcular

	Local aInfoFont  := fDadFonts() //Fun��o para trazer os fontes que est�o envolvidos 

	Local nFazLista	 := 0
	Local cMsgMemo	 := ""
	Local nFazMemo   := 0
	Private aMemoria := {}
	Private aLisResu := {}

	Default lBotao   := .F.
	Default oTexCal  := NIL

	lAtvChang := .F. //Desativar change da grid

	//Apagar registros da tabela de Transportadora
	if TCSqlExec(cDelTra) < 0
		Return
	endif

	//Apagar registros da tabela de Resumo
	if TCSqlExec(cDelRes) < 0
		Return
	endif

	aTabFrete := {}
	lRetorno   := .F.

	If Valtype(oBrowsPed) == "O" 
		oBrowsPed:Refresh(.t.)//Atualizando o browse do Pedido
	EndIF
	If Valtype(oBrowsTra) == "O" 
		oBrowsTra:Refresh(.t.)//Atualizando o browse do Transportadora
	EndiF
	If Valtype(oBrowsRes) == "O" 
		oBrowsRes:Refresh(.t.)//Atualizando o browse do Resumo
	EndIF

	//Percorrer a tabela de Pedidos para calcular frete
	DBSelectArea(cAliaTmp)
	(cAliaTmp)->(DbSetOrder(1))
	(cAliaTmp)->(dbGoTOp())
	While (cAliaTmp)->(!Eof())
		aItemPed	:= {}

		IF lLibCampo .AND. lBotao

			//Valor de Rateio para Mercadoria
			IF Substr(cRateio,1,1) == "1"
				IF (cAliaTmp)->nLinPValo > 0 .AND. nEdtValor > 0
					nTmpVlr := ROUND((cAliaTmp)->nLinPValo * ROUND((nEdtValor / (cAliaTmp)->nLinPValo),2),2)
				ElseIF (cAliaTmp)->nLinPValo == 0 .AND. nEdtValor > 0
					nTmpVlr := nEdtValor
				ElseIF (cAliaTmp)->nLinPValo > 0 .AND. nEdtValor == 0
					nTmpVlr := (cAliaTmp)->nLinPValo
				Else
					nTmpVlr := 0
				EndIF
			Else
				nTmpVlr := nEdtValor
			EndIF

			//Valor de Rateio para Peso
			IF Substr(cRateio,2,1) == "1"
				IF (cAliaTmp)->nLinPPeso > 0 .AND. nEdtPes > 0
					nTmpPes := ROUND((cAliaTmp)->nLinPPeso * ROUND((nEdtPes / (cAliaTmp)->nLinPPeso),2),2)
				ElseIF (cAliaTmp)->nLinPPeso == 0 .AND. nEdtPes > 0
					nTmpPes := nEdtPes
				ElseIF (cAliaTmp)->nLinPPeso > 0 .AND. nEdtPes == 0
					nTmpPes := (cAliaTmp)->nLinPPeso
				Else
					nTmpPes := 0
				EndIF
			Else
				nTmpPes := nEdtPes
			EndIF

			//Valor de Rateio para Volume
			IF Substr(cRateio,3,1) == "1"
				IF (cAliaTmp)->nLinPVolu > 0 .AND. nEdtVolu > 0
					nTmpVol := ROUND((cAliaTmp)->nLinPVolu * ROUND((nEdtVolu / (cAliaTmp)->nLinPVolu),2),2)
				ElseIF (cAliaTmp)->nLinPVolu == 0 .AND. nEdtVolu > 0
					nTmpVol := nEdtVolu
				ElseIF (cAliaTmp)->nLinPVolu > 0 .AND. nEdtVolu == 0
					nTmpVol := (cAliaTmp)->nLinPVolu
				Else
					nTmpVol := 0
				EndIF
			Else
				nTmpVol := nEdtVolu
			EndIF

			//Valor de Rateio para KM
			IF Substr(cRateio,4,1) == "1"
				IF (cAliaTmp)->nLinPKM > 0 .AND. nEdtKM > 0
					nTmpKM := ROUND((cAliaTmp)->nLinPKM * ROUND((nEdtKM / (cAliaTmp)->nLinPKM),2),2)
				ElseIF (cAliaTmp)->nLinPKM == 0 .AND. nEdtKM > 0
					nTmpKM := nEdtKM
				ElseIF (cAliaTmp)->nLinPKM > 0 .AND. nEdtKM == 0
					nTmpKM := (cAliaTmp)->nLinPKM
				Else
					nTmpKM := 0
				EndIF
			Else
				nTmpKM := nEdtKM
			EndIF

			aadd(aItemPed, (cAliaTmp)->nLinPFili)	//Filial do Pedido de Venda
			aadd(aItemPed, (cAliaTmp)->nLinPNume)	//Numero do Pedido de Venda
			aadd(aItemPed, (cAliaTmp)->nLinPTipo)	//Tipo do Pedido de Venda
			aadd(aItemPed, (cAliaTmp)->nLinPClie)	//Codigo do Cliente do Pedido de Venda
			aadd(aItemPed, (cAliaTmp)->nLinPLoja)	//Codigo da Loja do Pedido de Venda
			aadd(aItemPed, nTmpVlr				)	//Valor do Pedido de Venda
			aadd(aItemPed, nTmpPes				)	//Peso do pedido de venda
			aadd(aItemPed, nTmpVol				)	//Volume do pedido de venda
			aadd(aItemPed, (cAliaTmp)->nLinPCOri)	//Codigo do IBGE da Cidade de Origem
			aadd(aItemPed, (cAliaTmp)->nLinPMOri) 	//Nome do Municipio de Origem
			aadd(aItemPed, (cAliaTmp)->nLinPEOri) 	//Estado do Municipio de Origem
			aadd(aItemPed, (cAliaTmp)->nLinPCDes)	//Codigo do IBGE da Cidade de Destino
			aadd(aItemPed, (cAliaTmp)->nLinPMDes) 	//Nome do Municipio de Destino
			aadd(aItemPed, (cAliaTmp)->nLinPEDes) 	//Estado do Municipio de Destino
			aadd(aItemPed, (cAliaTmp)->nLinPEmit)	//Codigo do Remetente		( referencia da GU3)
			aadd(aItemPed, (cAliaTmp)->nLinPDest)	//Codigo do Destinatario	( referencia da GU3)
			aadd(aItemPed, cEdtTra				)	//Codigo da Transportadora do Pedido de Venda
			aadd(aItemPed, ""					)	//Codigo da Placa do Veiculo
			aadd(aItemPed, cEdtClas				)	//Codigo da Classifica��o de Frete
			aadd(aItemPed, cEdtTipo				)	//Codigo da Opera��o de Frete
			aadd(aItemPed, oCmbNego:nAt			)	//Controle se aceita tabelas de negocia��o de frete 1 - Sim,2 - Nao
			aadd(aItemPed, cEdtTVei				)	//Tipo de Veiculo associado a Placa
			aadd(aItemPed, nTmpKM				)	//KM associado ao pedido de venda
		Else

			IF !lSemMsFrt .AND. ValType(oTexCal) == "O"
				oTexCal:SetText("Calculando Pedido: "+cValToChar((cAliaTmp)->nLinPNume) )
			EndiF

			aadd(aItemPed, (cAliaTmp)->nLinPFili)	//Filial do Pedido de Venda
			aadd(aItemPed, (cAliaTmp)->nLinPNume)	//Numero do Pedido de Venda
			aadd(aItemPed, (cAliaTmp)->nLinPTipo)	//Tipo do Pedido de Venda
			aadd(aItemPed, (cAliaTmp)->nLinPClie)	//Codigo do Cliente do Pedido de Venda
			aadd(aItemPed, (cAliaTmp)->nLinPLoja)	//Codigo da Loja do Pedido de Venda
			aadd(aItemPed, (cAliaTmp)->nLinPValo)	//Valor do Pedido de Venda
			aadd(aItemPed, (cAliaTmp)->nLinPPeso)	//Peso do pedido de venda
			aadd(aItemPed, (cAliaTmp)->nLinPVolu)	//Volume do pedido de venda
			aadd(aItemPed, (cAliaTmp)->nLinPCOri)	//Codigo do IBGE da Cidade de Origem
			aadd(aItemPed, (cAliaTmp)->nLinPMOri) 	//Nome do Municipio de Origem
			aadd(aItemPed, (cAliaTmp)->nLinPEOri) 	//Estado do Municipio de Origem
			aadd(aItemPed, (cAliaTmp)->nLinPCDes)	//Codigo do IBGE da Cidade de Destino
			aadd(aItemPed, (cAliaTmp)->nLinPMDes) 	//Nome do Municipio de Destino
			aadd(aItemPed, (cAliaTmp)->nLinPEDes) 	//Estado do Municipio de Destino
			aadd(aItemPed, (cAliaTmp)->nLinPEmit)	//Codigo do Remetente		( referencia da GU3)
			aadd(aItemPed, (cAliaTmp)->nLinPDest)	//Codigo do Destinatario	( referencia da GU3)
			aadd(aItemPed, (cAliaTmp)->nLinPTran)	//Codigo da Transportadora do Pedido de Venda
			aadd(aItemPed, (cAliaTmp)->nLinPPlac)	//Codigo da Placa do Veiculo
			aadd(aItemPed, (cAliaTmp)->nLinPClas)	//Codigo da Classifica��o de Frete
			aadd(aItemPed, (cAliaTmp)->nLinPOper)	//Codigo da Opera��o de Frete
			aadd(aItemPed, (cAliaTmp)->nLinPNego)	//Controle se aceita tabelas de negocia��o de frete
			aadd(aItemPed, (cAliaTmp)->nLinPTpVe)	//Tipo de Veiculo associado a Placa
			aadd(aItemPed, (cAliaTmp)->nLinPKM  )	//KM associado ao pedido de venda
		EndIF

		//Ponto de entrada para usu�rio customizar o preenchimento das informa��es antes de disparar do calculo para cada pedido de venda
		IF lOM200A06
			OmsLogMsg("Existe o ponto de entrada OM200A06.")
			aRetPE06 := ExecBlock("OM200A06",.F.,.F.,{cCodDAK, cSeqDAK, aItemPed, lTelPE06 })  //Envio: Codigo da Carga, Sequencia da Carga, Array com os Itens do Calculo e Variavel se o Calculo est� sendo via bot�o com campos liberados. //Retorno: Array com os Itens para Disparar o Calculo.
			If ValType(aRetPE06)=="A" .AND. Len(aRetPE06[1]) == Len(aItemPed)

				//aItemPed[1] := ""					//Filial do Pedido de Venda
				//aItemPed[2] := ""					//Numero do Pedido de Venda
				//aItemPed[3] := ""					//Tipo do Pedido de Venda
				//aItemPed[4] := ""					//Codigo do Cliente do Pedido de Venda
				//aItemPed[5] := ""					//Codigo da Loja do Pedido de Venda
				IF ValType(aRetPE05[1,6])=="N" .AND. aRetPE05[1,6] >= 0
					aItemPed[6] := aRetPE05[1,6]	//Valor do Pedido de Venda
				EndIF
				IF ValType(aRetPE05[1,7])=="N" .AND. aRetPE05[1,7] >= 0
					aItemPed[7] := aRetPE05[1,7]	//Peso do pedido de venda
				EndIF
				IF ValType(aRetPE05[1,8])=="N" .AND. aRetPE05[1,8] >= 0
					aItemPed[8] := aRetPE05[1,8]	//Volume do pedido de venda
				EndIF
				IF ValType(aRetPE05[1,9])=="C"
					aItemPed[9] := aRetPE05[1,9]														//Codigo do IBGE da Cidade de Origem		
					aItemPed[10] := Alltrim(POSICIONE("GU7",1,XFILIAL("GU7")+aItemPed[9],"GU7_NMCID"))	//Nome do Municipio de Origem
					aItemPed[11] := Alltrim(POSICIONE("GU7",1,XFILIAL("GU7")+aItemPed[9],"GU7_CDUF"))	//Estado do Municipio de Origem
				EndIF
				IF ValType(aRetPE05[1,12])=="C"
					aItemPed[12] := aRetPE05[1,12]	//Codigo do IBGE da Cidade de Destino
					aItemPed[10] := Alltrim(POSICIONE("GU7",1,XFILIAL("GU7")+aItemPed[12],"GU7_NMCID"))	//Nome do Municipio de Destino
					aItemPed[11] := Alltrim(POSICIONE("GU7",1,XFILIAL("GU7")+aItemPed[12],"GU7_CDUF"))	//Estado do Municipio de Destino					
				EndIF
				IF ValType(aRetPE05[1,15])=="C"
					aItemPed[15] := aRetPE05[1,15]	//Codigo do Remetente		( referencia da GU3)
				EndIF
				IF ValType(aRetPE05[1,16])=="C"
					aItemPed[16] := aRetPE05[1,16]	//Codigo do Destinatario	( referencia da GU3)
				EndIF
				IF ValType(aRetPE05[1,17])=="C"
					aItemPed[17] := aRetPE05[1,17]	//Codigo da Transportadora do Pedido de Venda
				EndIF
				IF ValType(aRetPE05[1,18])=="C"
					aItemPed[18] := aRetPE05[1,18]	//Codigo da Placa do Veiculo
				EndIF
				IF ValType(aRetPE05[1,19])=="C"
					aItemPed[19] := aRetPE05[1,19]	//Codigo da Classifica��o de Frete
				EndIF
				IF ValType(aRetPE05[1,20])=="C"
					aItemPed[20] := aRetPE05[1,20]	//Codigo da Opera��o de Frete
				EndIF
				IF ValType(aRetPE05[1,21])=="C" .OR. (ValType(aRetPE05[1,21])=="N" .AND. aRetPE05[1,21] > 0 )
					aItemPed[21] := aRetPE05[1,21]	//Controle se aceita tabelas de negocia��o de frete
				EndIF
				IF ValType(aRetPE05[1,22])=="C"
					aItemPed[22] := aRetPE05[1,22]	//Tipo de Veiculo associado a Placa
				EndIF
				IF ValType(aRetPE05[1,23])=="N" .AND. aRetPE05[1,23] >= 0
					aItemPed[23] := aRetPE05[1,23]	//KM associado ao pedido de venda
				EndIF
			Else
				OmsLogMsg("Retorno do ponto de entrada OM200A06 n�o est� dentro das valida��es.")
			EndIF
		EndIF

		fCalcFret(aItemPed)

		(cAliaTmp)->(DBSkip())
	Enddo

	IF Len(aLisResu) > 0
		for nFazLista := 1 to Len(aLisResu)
			RecLock(cAliasRes,.T.)
			(cAliasRes)->nLinRCodi := aLisResu[nFazLista,2]
			(cAliasRes)->nLinRNome := aLisResu[nFazLista,3]
			(cAliasRes)->nLinRValo := aLisResu[nFazLista,4]
			(cAliasRes)->nLinRQtde := aLisResu[nFazLista,5]
			(cAliasRes)->nLinREmit := aLisResu[nFazLista,1]
			(cAliasRes)->(MsUnlock())

			aadd(aTabFrete,	{aLisResu[nFazLista,2],	aLisResu[nFazLista,3], aLisResu[nFazLista,4], aLisResu[nFazLista,5], aLisResu[nFazLista,1] } )		

		next nFazLista

		lRetorno   := .T.

	EndIF

	If Valtype(oBrowsPed) == "O" 
		oBrowsPed:Refresh(.t.)//Atualizando o browse do Pedido
	EndIF
	If Valtype(oBrowsTra) == "O" 
		oBrowsTra:Refresh(.t.)//Atualizando o browse do Transportadora
	EndiF
	If Valtype(oBrowsRes) == "O" 
		oBrowsRes:Refresh(.t.)//Atualizando o browse do Resumo
	EndIF

	lAtvChang := .T.
	(cAliaTmp)->(dbGoTOp())

	IF lMemCalcu .AND. Len(aMemoria) > 0
		For nFazMemo:= 1 to Len(aMemoria)
			cMsgMemo += aMemoria[nFazMemo]+CRLF
		Next nFazMemo

		cMsgMemo += ""+CRLF
		cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> ---------------------------------------------- "+CRLF
		cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> Parametros da tela de Calculo de Frete         "+CRLF
		cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> ---------------------------------------------- "+CRLF
		cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> MV_OM2CMP : "+cValToChar(lLibCampo)	+CRLF	
		cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> MV_OM2CFR : "+cValToChar(lOcutDeta)	+CRLF
		cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> MV_OM2NEG : "+cValToChar(cNegocia)		+CRLF
		cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> MV_OM2RAT : "+cValToChar(cRateio)		+CRLF
		cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> MV_OM2VIS : "+cValToChar(lVisCarga)	+CRLF
		cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> MV_OM2MEM : "+cValToChar(lMemCalcu)	+CRLF
		cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> MV_OM2CEX : "+cValToChar(lIgnCliEX)	+CRLF
		cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> MV_OM2ZER : "+cValToChar(lIgnrZera)	+CRLF
		cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> MV_OM2FOB : "+cValToChar(lIgnrPFOB)	+CRLF
		cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> MV_OM2NOR : "+cValToChar(lIgnrNORM)	+CRLF
		cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> MV_OM2FAT : "+cValToChar(lIgnrFATU)	+CRLF		
		cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> ---------------------------------------------- "+CRLF

		IF Len(aInfoFont) > 0
			cMsgMemo += ""+CRLF
			cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> ---------------------------------------------- "+CRLF
			cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> Fontes da tela de Calculo de Frete             "+CRLF
			cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> ---------------------------------------------- "+CRLF		
			For nFazMemo:= 1 to Len(aInfoFont)
				cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> "+aInfoFont[nFazMemo]+CRLF
			Next nFazMemo
			cMsgMemo += OEMToANSI(FWTimeStamp(2)) + " >> ---------------------------------------------- "+CRLF
		EndIF

		EecView(cMsgMemo,"Calculo de Frete", "Carga: " +cCodDAK+" Seq.: "+ cSeqDAK,/*aButtons*/, /*bValid*/, /*lQuebraLinha*/, .T.)	  //EECView(xMsg,cTitulo,cLabel, aButtons, bValid, lQuebraLinha, lSoExibeMsg) 

	EndIF
	

Return .T.


//Fun��o para calcular o frete por pedido
Static Function fCalcFret(aCalFre)
	Local lRet       := .T.
	Local oModelSim  := FWLoadModel("GFEX010")
	Local oModelNeg  := oModelSim:GetModel("GFEX010_01")
	Local oModelAgr  := oModelSim:GetModel("DETAIL_01") // oModel do grid "Agrupadores"
	Local oModelDC   := oModelSim:GetModel("DETAIL_02") // oModel do grid "Doc Carga"
	Local oModelIt   := oModelSim:GetModel("DETAIL_03") // oModel do grid "Item Carga"
	Local oModelTr   := oModelSim:GetModel("DETAIL_04") // oModel do grid "Trechos"
	Local oModelInt  := oModelSim:GetModel("SIMULA")
	Local oModelCal1 := oModelSim:GetModel("DETAIL_05")
	Local oModelCal2 := oModelSim:GetModel("DETAIL_06")
	Local cPedTipo   := ""
	Local cPedTVeic	 := "" 
	Local cPedTran   := ""
	Local nCont      := 0

	//Variaveis recebidas via vetor
	Local cPedFil    := aCalFre[01] //Filial do Pedido de Venda
	Local cPedNume   := aCalFre[02] //Numero do Pedido de Venda
	Local cPedTpP    := aCalFre[03] //Tipo do Pedido de Venda
	Local cPedCli    := aCalFre[04] //Codigo do Cliente do Pedido de Venda
	Local cPedLoja   := aCalFre[05] //Codigo da Loja do Pedido de Venda
	Local nPedValo   := aCalFre[06] //Valor do Pedido de Venda
	Local nPedPeso   := aCalFre[07] //Peso do pedido de venda
	Local nPedVolu   := aCalFre[08] //Volume do pedido de venda
	Local cPedCidO   := aCalFre[09] //Codigo do IBGE da Cidade de Origem
	Local cPedMunO   := aCalFre[10] //Nome do Municipio de Origem
	Local cPedEstO   := aCalFre[11] //Estado do Municipio de Origem
	Local cPedCidD   := aCalFre[12] //Codigo do IBGE da Cidade de Destino
	Local cPedMunD   := aCalFre[13] //Nome do Municipio de Destino
	Local cPedEstD   := aCalFre[14] //Estado do Municipio de Destino
	Local cPedReme   := aCalFre[15] //Codigo do Remetente		( referencia da GU3)
	Local cPedDest   := aCalFre[16] //Codigo do Destinatario	( referencia da GU3)
	Local cPedSA4    := aCalFre[17] //Codigo da Transportadora do Pedido de Venda
	Local cPedPlac   := aCalFre[18] //Codigo da Placa do Veiculo
	Local cPedClas   := aCalFre[19] //Codigo da Classifica��o de Frete
	Local cPedOper   := aCalFre[20] //Codigo da Opera��o de Frete
	Local nPedRadi   := IIF(Valtype(aCalFre[21]) == "N", aCalFre[21], Val(aCalFre[21]) ) //Controle se aceita tabelas de negocia��o de frete
	Local cPedTpVe   := aCalFre[22] //Tipo de Veiculo do Pedido de Venda
	Local nPedDist   := aCalFre[23] //Distancia em KM do Pedido de Venda

	//Variaveis dentro das transportadora do calculo	
	Local cTmpSA4 := ""
	Local cTmpNom := ""
	Local nTmpFre := 0
	Local dTmpDat 
	Local cTmpGU3 := ""

	Local nPosResu := 0

	If !Empty(cPedPlac)
		cPedTVeic := Alltrim(POSICIONE("DA3",1,xFilial("DA3")+cPedPlac,"DA3_TIPVEI"))
	ElseIF Empty(cPedPlac) .AND.  !Empty(cPedTpVe)
		cPedTVeic := cPedTpVe
	Endif

	IF Len(aMemoria) > 0
		aadd(aMemoria,"" )
	EndIF
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> ---------------------------------------------- "						)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Inicio de Calculo de Frete por Pedido Venda"							)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> ---------------------------------------------- "						)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Variaveis recebidas para Calculo Frete"									)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Filial do Pedido de Venda....................: "+ cValToChar(cPedFil)	)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Numero do Pedido de Venda....................: "+ cValToChar(cPedNume)	)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Tipo do Pedido de Venda......................: "+ cValToChar(cPedTpP)	)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Codigo do Cliente do Pedido de Venda.........: "+ cValToChar(cPedCli)	)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Codigo da Loja do Pedido de Venda............: "+ cValToChar(cPedLoja)	)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Valor do Pedido de Venda.....................: "+ Alltrim(TRANSFORM(nPedValo, PESQPICT("DAK","DAK_VALOR")))		)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Peso do pedido de venda......................: "+ Alltrim(TRANSFORM(nPedPeso, PESQPICT("DAK","DAK_PESO")))		)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Volume do pedido de venda....................: "+ Alltrim(TRANSFORM(nPedVolu, PESQPICT("DAK","DAK_CAPVOL"))) 	)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Codigo do IBGE da Cidade de Origem...........: "+ cValToChar(cPedCidO)	)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Nome do Municipio de Origem..................: "+ cValToChar(cPedMunO)	)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Estado do Municipio de Origem................: "+ cValToChar(cPedEstO)	)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Codigo do IBGE da Cidade de Destino..........: "+ cValToChar(cPedCidD)	)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Nome do Municipio de Destino.................: "+ cValToChar(cPedMunD)	)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Estado do Municipio de Destino...............: "+ cValToChar(cPedEstD)	)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Codigo do Remetente(referencia da GU3).......: "+ cValToChar(cPedReme)	)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Codigo do Destinatario (referencia da GU3)...: "+ cValToChar(cPedDest)	)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Codigo da Transportadora do Pedido de Venda..: "+ cValToChar(cPedSA4)	)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Codigo da Placa do Veiculo...................: "+ cValToChar(cPedPlac)	)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Codigo da Classifica��o de Frete.............: "+ cValToChar(cPedClas)	)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Codigo da Opera��o de Frete..................: "+ cValToChar(cPedOper)	)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Aceita tabelas de negocia��o de frete........: "+ cValToChar(nPedRadi)	)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Tipo de Veiculo do Pedido de Venda...........: "+ cValToChar(cPedTpVe)	)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Distancia em KM do Pedido de Venda...........: "+ cValToChar(nPedDist)	)
	
	//Verificar qual � tipo de documento correspondente no GFE
	cPedTipo := Alltrim(Posicione("SX5",1,xFilial("SX5")+"MQ"+AllTrim(cPedTpP)+"S","X5_DESCRI"))
	If Empty(cPedTipo)
		cPedTipo := Alltrim(Posicione("SX5",1,xFilial("SX5")+"MQ"+AllTrim(cPedTpP),"X5_DESCRI"))
	EndIf

	cPedTipo := PadR(cPedTipo,TamSx3("GW1_CDTPDC")[1])
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Tipo de Pedido Equiv. no GFE (GW1_CDTPDC)....: "+ cValToChar(cPedTipo)	)

	// N�o mostra a tela de Log do processamento
	GFEX010Slg(__nLogProc)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Variavel de Tela de Log de Processamento.....: "+ cValToChar(__nLogProc))

	// N�o mostra a barra de progresso
	GFEX010SBr(__lHidePrg)
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Variavel de N�o Mostrar Barra de Progresso...: "+ cValToChar( __lHidePrg))

	//simula como inclus�o
	oModelSim:SetOperation(3)
	oModelSim:Activate()

	oModelNeg:LoadValue('CONSNEG', cValToChar(nPedRadi) )// 1=Considera Tab.Frete em Negociacao; 2=Considera apenas Tab.Frete Aprovadas
	//Agrupadores
	oModelAgr:LoadValue('GWN_NRROM' , "01" )
	oModelAgr:LoadValue('GWN_CDCLFR', Alltrim(cPedClas))
	oModelAgr:LoadValue('GWN_CDTPOP', Alltrim(cPedOper))
	oModelAgr:LoadValue('GWN_DOC'   , "ROMANEIO")
	oModelAgr:LoadValue('GWN_DISTAN', nPedDist)
	//Documento de Carga
	oModelDC:LoadValue('GW1_EMISDC', Alltrim(cPedReme))
	oModelDC:LoadValue('GW1_NRDC'  , "00001")
	oModelDC:LoadValue('GW1_CDTPDC', Alltrim(cPedTipo))
	oModelDC:LoadValue('GW1_CDREM' , Alltrim(cPedReme))
	oModelDC:LoadValue('GW1_CDDEST', Alltrim(cPedDest))
	oModelDC:LoadValue('GW1_TPFRET', "1")
	oModelDC:LoadValue('GW1_ICMSDC', "2")
	oModelDC:LoadValue('GW1_USO'   , "1")
	oModelDC:LoadValue('GW1_NRROM' , "01")
	oModelDC:LoadValue('GW1_QTUNI' , 1)
	//Trechos
	oModelTr:LoadValue('GWU_EMISDC', Alltrim(cPedReme))
	oModelTr:LoadValue('GWU_NRDC'  , "00001")
	oModelTr:LoadValue('GWU_CDTPDC', Alltrim(cPedTipo))
	oModelTr:LoadValue('GWU_SEQ'   , "01")

	//Codigo da Cidade de Origem
	If !Empty(cPedCidO)
		oModelTr:LoadValue('GWU_NRCIDO', cPedCidO) 
		aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Adicionando codigo da Cidade Origem (GFE)....: "+ cValToChar(cPedCidO)	)
	Else
		aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Codigo da Cidade Origem (GFE) n�o informado..: "+ cValToChar(cPedCidO)	)
	EndIf

	//Codigo da Cidade de Destino
	If !Empty(cPedCidD)
		oModelTr:LoadValue('GWU_NRCIDD', cPedCidD) 
		aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Adicionando codigo da Cidade Destino (GFE)...: "+ cValToChar(cPedCidD)	)
	Else
		//Codigo da Cidade de Destino a partir do Destinat�rio
		IF !Empty(cPedDest)
			oModelTr:LoadValue('GWU_NRCIDD', POSICIONE("GU3",1,xFilial("GU3")+cPedDest,"GU3_NRCID")) 
			aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Adicionando codigo da Cidade Destino (GFE)...: "+ cValToChar(POSICIONE("GU3",1,xFilial("GU3")+cPedDest,"GU3_NRCID"))	)
			aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Usando Codigo do Destinatario (GU3)..........: "+ cValToChar(cPedDest)	)
		EndIF
	EndIf

	// adiciona o transportador
	IF !Empty(cPedSA4) .AND. fVlSA4GU3(cPedSA4, .F.)
		cPedTran := Alltrim(POSICIONE("GU3",13,xFilial("GU3")+cPedSA4,"GU3_CDEMIT"))
		If !Empty(cPedTran)
			oModelTr:LoadValue('GWU_CDTRP', cPedTran	) 
			aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Transportadora Equivalente GFE. (GU3)........: "+ cValToChar(cPedTran)	)
		EndIf
	Else
		aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Transportadora (SA4) n�o existe no GFE.......: "+ cValToChar(cPedSA4)	)
	EndIF

	// adiciona o tipo do ve�culo para c�lculo do frete
	IF !Empty(cPedTVeic)
		oModelTr:LoadValue('GWU_CDTPVC', cPedTVeic ) 
		aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Tipo de Veiculo Equiv. GFE (GWU_CDTPVC)......: "+cValToChar(cPedTVeic)	)
	Else
		oModelTr:LoadValue('GWU_CDTPVC', SPACE(TamSX3("GWU_CDTPVC")[1]) ) 
		aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Tipo de Veiculo Equiv. GFE (GWU_CDTPVC)......: n�o tem informa��es no campo")
	EndIF

	//Itens
	oModelIt:LoadValue('GW8_EMISDC', Alltrim(cPedReme))
	oModelIt:LoadValue('GW8_NRDC'  , "00001")
	oModelIt:LoadValue('GW8_CDTPDC', Alltrim(cPedTipo))
	oModelIt:LoadValue('GW8_ITEM'  , "ItemA"  )
	oModelIt:LoadValue('GW8_DSITEM', "Item Generico")
	oModelIt:LoadValue('GW8_CDCLFR', Alltrim(cPedClas))
	oModelIt:LoadValue('GW8_PESOR' , nPedPeso)
	oModelIt:LoadValue('GW8_VALOR' , nPedValo)
	oModelIt:LoadValue('GW8_VOLUME', nPedVolu)
	oModelIt:LoadValue('GW8_TRIBP' , "1")
	// Dispara a simula��o
	oModelInt:SetValue("INTEGRA", "A")

	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> ---------------------------------------------- ")
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Resultado do Calculo de Frete ")
	aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> ---------------------------------------------- ")	

	//Verifica se tem linhas no modelo do calculo, se nao tem linhas significa que o calculo falhou e retorna zero
	If oModelCal1:GetQtdLine() > 1 .Or. !Empty( oModelCal1:GetValue('C1_NRCALC'  ,1) )
		//Percorre o grid, cada linha corresponde a um calculo diferente

		For nCont := 1 to oModelCal1:GetQtdLine()
			oModelCal1:GoLine( nCont )
			
			cTmpSA4 := POSICIONE("GU3",1,xFilial("GU3")+oModelCal2:GetValue('C2_CDEMIT',1 ),"GU3_CDTERP")
			cTmpNom := POSICIONE("GU3",1,xFilial("GU3")+oModelCal2:GetValue('C2_CDEMIT',1 ),"GU3_NMEMIT")
			nTmpFre := oModelCal1:GetValue('C1_VALFRT'  ,nCont)
			dTmpDat := oModelCal1:GetValue('C1_DTPREN'  ,nCont)
			cTmpGU3 := oModelCal2:GetValue('C2_CDEMIT'  ,1 )


			IF nCont > 1
				aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> ---------------------------------------------- ")	
			EndIF

			aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Codigo do Transportadora (SA4)................: "+ cValToChar(Alltrim(cTmpSA4))								)
			aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Codigo do Emitente Transportadora GFE (GU3)...: "+ cValToChar(Alltrim(cTmpGU3)) 							)
			aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Nome do Emitente Transportadora GFE (GU3).....: "+ cValToChar(Alltrim(cTmpNom))								)
			aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Valor Frete Calculo Transportadora GFE (GU3)..: "+ Alltrim(TRANSFORM(nTmpFre, PESQPICT("GW8","GW8_VALOR")))	)
			aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Data de Previs�o de Entrega GFE...............: "+ cValToChar(dTmpDat)										)		

			IF Empty(cTmpSA4)
				aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Transportadora possui tabela de Frete.........: Cadastro est� incorreto no Emitente (GU3) ")
			EndIF

			IF lIgnrZera .AND. nTmpFre <= 0
				Loop
			EndIF

			IF !Empty(cPedTran)

				If cPedSA4 == cTmpSA4

					RecLock(cAliasTra,.T.)
					(cAliasTra)->nLinTCodi	:= cTmpSA4
					(cAliasTra)->nLinTNome	:= cTmpNom
					(cAliasTra)->nLinTValo	:= nTmpFre
					(cAliasTra)->nLinTQtde	:= dTmpDat
					(cAliasTra)->nLinTFili	:= cPedFil
					(cAliasTra)->nLinTNume	:= cPedNume
					(cAliasTra)->nLinTTipo	:= cPedTpP
					(cAliasTra)->nLinTClie	:= cPedCli
					(cAliasTra)->nLinTLoja	:= cPedLoja
					(cAliasTra)->nLinTGU3	:= cTmpGU3
					(cAliasTra)->(MsUnlock())

					nPosResu := aScan(aLisResu,{|x| AllTrim(x[1]) == Alltrim(cTmpGU3) })
					IF nPosResu > 0
						aLisResu[nPosResu,4] += nTmpFre
						aLisResu[nPosResu,5] += 1
					Else
						aadd(aLisResu,{Alltrim(cTmpGU3), Alltrim(cTmpSA4), Alltrim(cTmpNom), nTmpFre, 1})
					EndIF

					EXIT
				Endif
			Else

				RecLock(cAliasTra,.T.)
				(cAliasTra)->nLinTCodi	:= cTmpSA4
				(cAliasTra)->nLinTNome	:= cTmpNom
				(cAliasTra)->nLinTValo	:= nTmpFre
				(cAliasTra)->nLinTQtde	:= dTmpDat
				(cAliasTra)->nLinTFili	:= cPedFil
				(cAliasTra)->nLinTNume	:= cPedNume
				(cAliasTra)->nLinTTipo	:= cPedTpP
				(cAliasTra)->nLinTClie	:= cPedCli
				(cAliasTra)->nLinTLoja	:= cPedLoja
				(cAliasTra)->nLinTGU3	:= cTmpGU3
				(cAliasTra)->(MsUnlock())

				nPosResu := aScan(aLisResu,{|x| AllTrim(x[1]) == Alltrim(cTmpGU3) })
				IF nPosResu > 0
					aLisResu[nPosResu,4] += nTmpFre
					aLisResu[nPosResu,5] += 1
				Else
					aadd(aLisResu,{Alltrim(cTmpGU3), Alltrim(cTmpSA4), Alltrim(cTmpNom), nTmpFre, 1})
				EndIF

			EndIF

		Next nCont
	Else
		aadd(aMemoria, OEMToANSI(FWTimeStamp(2)) + " >> Dados informados n�o trouxe nenhuma refer�ncia")
		lRet := .F. //Para indicar que para o pedido n�o calculou nada
	EndIf

Return lRet

//Fun��o para filtrar a transportadora conforme o pedido
Static Function fRefrTran()
	Local cFiltro := ""

	IF lAtvChang
		cFiltro += "(cAliasTra)->nLinTFili == '"+(cAliasPed)->nLinPFili+"' "
		cFiltro += " .AND. (cAliasTra)->nLinTNume == '"+(cAliasPed)->nLinPNume+"' "
		cFiltro += " .AND. (cAliasTra)->nLinTTipo == '"+(cAliasPed)->nLinPTipo+"' "
		cFiltro += " .AND. (cAliasTra)->nLinTClie == '"+(cAliasPed)->nLinPClie+"' "
		cFiltro += " .AND. (cAliasTra)->nLinTLoja == '"+(cAliasPed)->nLinPLoja+"' "

		If Valtype(oBrowsTra) == "O" 
			oBrowsTra:CleanFilter()
			oBrowsTra:SetFilterDefault( cFiltro )
			oBrowsTra:Refresh(.t.)
		EndIF
	EndIF
	
Return .T.

//Fun��o para validar se o GFE est� ativo
Static Function fGFEAtivo()
	Local lRetGFE   := .F.
	Local lIntGFE   := SuperGetMv("MV_INTGFE",.F.,.F.)
	Local cIntGFE2  := SuperGetMv("MV_INTGFE2",.F.,"2")
	Local cIntCarga := SuperGetMv("MV_GFEI12",.F.,"2")

	lRetGFE :=  lIntGFE .And. cIntGFE2 $ "1" .And. cIntCarga == "1"

Return lRetGFE

//Fun��o para trazer os dados dos fontes que est�o envolvidos no processo.
Static Function fDadFonts()
	Local aRetFont := {}
	local aFontes  :={'OMSA200.PRW', 'OMSA200A.PRW', 'GFEX011.PRW', 'GFEX010.PRW','OMSM011.PRW'}
	local aInfo    := {}
	local nX       := 1

	for nX := 1 to Len(aFontes)
		aInfo := GetApoInfo(aFontes[nX])
		aadd(aRetFont, "Vers�o Fonte " + cValToChar(Trim(aFontes[nX])) + ":" + cValToChar(aInfo[4]) + " " + "Hora" + ":" + cValToChar(aInfo[5]) )
	next nX

Return aRetFont


Static Function AtualBrw(nFolder)

Default nFolder := 1
/*
Do Case
	Case nFolder == 1
		oBrowsePed:Refresh()
	Case nFolder == 2
		oBrowseTra:Refresh()
EndCase */

		oBrowsPed:Refresh()

		oBrowsTra:Refresh()

Return .T.
