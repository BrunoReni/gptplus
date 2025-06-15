#Include "Totvs.ch"
#Include "WMSBCCRegraConvocacao.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0006
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0006()
Return Nil
// Deve fazer assim para permitir criar as TEMPs fora da transação
Static __aTemps := {Nil}
Static __nCount := 0
//------------------------------------------------------------------------------
// Crias as tabelas temporárias necessárias para o funcionamento da rotina
//------------------------------------------------------------------------------
Function WMSCTPRGCV()
	// Se não existir a tabela temporária cria nesse momento
	If __nCount == 0
		__aTemps[1] := oTmpLibD12()
	EndIf
	__nCount++
Return __aTemps
//------------------------------------------------------------------------------
// Deleta as tabelas tabelas temporárias criadas para a rotina
//------------------------------------------------------------------------------
Function WMSDTPRGCV()
	__nCount--
	If __nCount == 0
		If __aTemps[1] != Nil
			__aTemps[1]:Delete()
			FreeObj(__aTemps[1])
		EndIf
	EndIf
	If __nCount < 0
		__nCount := 0
	EndIf
Return
//------------------------------------------------------------------------------
// Retorna a referência das tabelas tabelas temporárias criadas para a rotina
//------------------------------------------------------------------------------
Function WMSGTPRGCV()
Return __aTemps
//------------------------------------------------------------------------------
Static Function oTmpLibD12()
Local oTmpLibD12 := Nil
	CriaTabTmp({{"TP1_RECD12","N",10,0}},{"TP1_RECD12"},Nil,@oTmpLibD12)
Return oTmpLibD12

//---------------------------------------------
/*/{Protheus.doc} WMSBCCRegraConvocacao
Classe para analise e definição das regras de convocação
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
CLASS WMSBCCRegraConvocacao FROM LongNameClass
	// Data
	DATA cArmazem
	DATA cRecHumano
	DATA cServico
	DATA cFuncao
	DATA cSeqPriAnt
	DATA lRetAtiv
	DATA lDocExc
	DATA oEstFis
	DATA oOrdServ
	DATA oMovimento
	DATA oMovServic
	DATA oMovTarefa
	DATA oMovPrdLot
	DATA oMovEndOri
	DATA oMovEndDes
	DATA nCount
	DATA aLibD12   AS array
	DATA aLibRegra AS array
	DATA aRetRegra AS array
	DATA oTmpLibD12 AS object
	// Method
	METHOD New() CONSTRUCTOR
	METHOD SetArmazem(cArmazem)
	METHOD SetRecHum(cRecHumano)
	METHOD SetServico(cServico)
	METHOD SetFuncao(cFuncao)
	METHOD SetRetAtiv(lRetAtiv)
	METHOD SetDocExc(lDocExc)
	METHOD GetArmazem()
	METHOD GetRecHum()
	METHOD GetServico()
	METHOD LawExecute()
	METHOD LawRecHum() // WmsRegra('1')
	METHOD LawLimit()  // WmsRegra('2')
	METHOD LawChkRua() // WmsRegra('3')
	METHOD LawLibRua() // WmsRegra('4')
	METHOD LawSequen() // WmsRegra('5')
	METHOD LawLibTar() // WmsRegra('6')
	METHOD LawGeraSeq()// WmsRegra('7')
	METHOD LawRefSeq() // WmsRegra('8')
	METHOD LawRefDoc() // WmsRegra('9')
	METHOD RedoLawLim(cAntRecHum) 
	METHOD IniArrLib()
	METHOD GetArrLib()
	METHOD GetArrReg()
	METHOD ArrayToDB()
	METHOD Destroy()
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS WMSBCCRegraConvocacao
	Self:oEstFis    := WMSDTCEstruturaFisica():New()
	Self:oMovimento := WMSDTCMovimentosServicoArmazem():New()
	Self:oOrdServ   := Self:oMovimento:oOrdServ
	Self:oMovServic := Self:oMovimento:oMovServic
	Self:oMovTarefa := Self:oMovimento:oMovTarefa
	Self:oMovPrdLot := Self:oMovimento:oMovPrdLot
	Self:oMovEndOri := Self:oMovimento:oMovEndOri
	Self:oMovEndDes := Self:oMovimento:oMovEndDes
	Self:aLibD12    := {}
	Self:aLibRegra  := {}
	Self:aRetRegra  := {}
	Self:oTmpLibD12 := __aTemps[1]
	Self:lDocExc    := .T.
	Self:cSeqPriAnt := PadR("", TamSx3("D12_SEQPRI")[1])
	Self:cArmazem   := PadR("", TamSx3("D12_LOCORI")[1])
	Self:cRecHumano := PadR("", TamSx3("D12_RECHUM")[1])
	Self:cServico   := PadR("", TamSx3("D12_SERVIC")[1])
	Self:cFuncao    := PadR("", TamSx3("D12_RHFUNC")[1])
Return

METHOD Destroy() CLASS WMSBCCRegraConvocacao
	Self:oTmpLibD12 := Nil
Return

METHOD SetArmazem(cArmazem) CLASS WMSBCCRegraConvocacao
	Self:cArmazem := PadR(cArmazem, Len(Self:cArmazem))
Return

METHOD SetRecHum(cRecHumano) CLASS WMSBCCRegraConvocacao
	Self:cRecHumano := PadR(cRecHumano, Len(Self:cRecHumano))
Return

METHOD SetServico(cServico) CLASS WMSBCCRegraConvocacao
	Self:cServico := PadR(cServico, Len(Self:cServico))
Return

METHOD SetFuncao(cFuncao) CLASS WMSBCCRegraConvocacao
	Self:cFuncao := PadR(cFuncao, Len(Self:cFuncao))
Return

METHOD SetRetAtiv(lRetAtiv) CLASS WMSBCCRegraConvocacao
	Self:lRetAtiv := lRetAtiv
Return

METHOD SetDocExc(lDocExc) CLASS WMSBCCRegraConvocacao
	Self:lDocExc := lDocExc
Return

METHOD GetArmazem() CLASS WMSBCCRegraConvocacao
Return Self:cArmazem

METHOD GetRecHum() CLASS WMSBCCRegraConvocacao
Return Self:cRecHumano

METHOD GetServico() CLASS WMSBCCRegraConvocacao
Return Self:cServico

METHOD IniArrLib() CLASS WMSBCCRegraConvocacao
Return Self:aLibD12 := {}

METHOD GetArrLib() CLASS WMSBCCRegraConvocacao
Return Self:aLibD12

METHOD GetArrReg() CLASS WMSBCCRegraConvocacao
Return Self:aRetRegra

METHOD LawExecute() CLASS WMSBCCRegraConvocacao
Local lOk       := .F.
Local aAreaD12  := D12->(GetArea())
Local cPriori   := StrZero(0,2) // Inicia neste ponto
Local n1Cnt     := 0
Local lWmsRegSt := ExistBlock('WMSREGST')
Local lWmsALibX := ExistBlock('WMSALIBX')
Local cRetPE    := ""
Local aRetLibD12  := {}

	If !Empty(Self:aLibD12)
		// Cria tabela temporária
		WMSCTPRGCV()
		// Carrega na temporária os registros da D12 que estão no array
		Self:ArrayToDB()
		// Refaz regra de sequencia caso execucao de servico anterior interrompido.
		Self:LawRefSeq()
		// Somente ordena o array de movimentoS, após todos os movimentos terem sido adicionados ao mesmo.
		// Pois podem ter serviços diferentes no meio do array e se adicionar os documento só no final
		// gera erro no momento de sequenciar o mesmo documento, pois fica na ordem errada no array
		aSort(Self:aLibD12,,, {|x,y| x[3]+x[4]+Str(x[2])<+y[3]+y[4]+Str(y[2])})
		// Executa regras para convocacao do servico
		Self:aLibRegra := {}
		For n1Cnt := 1 To Len(Self:aLibD12)
			//Valida regra por armazem e servico
			//Inicializa os controles
			Self:SetArmazem(Self:aLibD12[n1Cnt,3])
			Self:SetServico(Self:aLibD12[n1Cnt,4])

			AAdd(Self:aLibRegra,Self:aLibD12[n1Cnt])
			If n1Cnt == Len(Self:aLibD12) .OR. Self:aLibD12[n1Cnt+1,3]+Self:aLibD12[n1Cnt+1,4] <> Self:cArmazem+Self:cServico
				lOk := .T.
			EndIf
			If lOk
				// Passa por referência, pois não deve reiniciar quando muda a ordenação de Armazém+Serviço
				// Pois isso fazia com que quando um mesmo documento fosse separado em armazéns diferentes
				// com os mesmos endereços a convocação ficasse alteranando entre os armazéns
				Self:LawSequen(@cPriori)
				If !(Empty(Self:aLibRegra))
					Self:LawGeraSeq(@cPriori)
				EndIf
				lOk := .F.
				Self:aLibRegra := {}
			EndIf
		Next
		
		//Ponto de Entrada para manipular os registros da D12, gerados no momento da execução do serviço
		If lWmsALibX
			aRetLibD12 := ExecBlock('WMSALIBX',.F.,.F.,{Self:aLibD12})
			If ValType(aRetLibD12) == "A"
				Self:aLibD12 := aRetLibD12
			EndIf
		EndIf

		// Ordena liberação conforme prioridade
		aSort(Self:aLibD12,,, {|x,y| Iif(Len(x)>4 .And. Len(y)>4,x[5]+Str(x[2])<y[5]+Str(y[2]),.T.)})
		// Disponibiliza registros do D12 para convocacao

		Begin Transaction
			For n1Cnt := 1 To Len(Self:aLibD12)
				D12->(dbGoTo(Self:aLibD12[n1Cnt,2]))
				If D12->(!Eof())
					If lWmsRegSt
						cRetPE := ExecBlock('WMSREGST',.F.,.F.,{Self:aLibD12[n1Cnt,1]})
						If ValType(cRetPE) == "C"
							Self:aLibD12[n1Cnt,1] := cRetPE
						EndIf
					EndIf
					RecLock('D12',.F.)
					D12->D12_STATUS := Self:aLibD12[n1Cnt,1]
					D12->(MsUnlock())
				EndIf
			Next
			// Refaz regra de limite (DCQ_DOCEXC)
			// caso execucao de servico anterior interrompido.
			Self:LawRefDoc()
		End Transaction

		// Destroy tabela temporária
		WMSDTPRGCV()
	EndIf
	RestArea(aAreaD12)
Return

METHOD LawRecHum() CLASS WMSBCCRegraConvocacao
Local lRet      := .F.
Local cRecVazio := PadR("",TamSx3("D12_RECHUM")[1])
Local lDocaOri  := .F.
Local lDocaDes  := .F.
Local aAreaSBE  := SBE->(GetArea())
Local cCodZon   := ""
Local cSerOrig  := Self:oMovServic:GetServico()
Local cTarOrig  := Self:oMovTarefa:GetTarefa()
Local cAtiOrig  := Self:oMovTarefa:GetAtivid()
Local cSerVazio := Space(TamSx3("D12_SERVIC")[1])
Local cTarVazio := Space(TamSx3("D12_TAREFA")[1])
Local cAtiVazio := Space(TamSx3("D12_ATIVID")[1])
Local aRegra    := {}
Local n1Cnt     := 0
Local cCodCfg   := ""
Local cEndAux   := ""
Local cAliasDCQ := ""

	// Verifica se existe o arquivo de regra
	If SIX->(MsSeek('DCQ1')) .And. AllTrim(SIX->CHAVE)=='DCQ_FILIAL+DCQ_TPREGR+DCQ_STATUS+DCQ_LOCAL+DCQ_CODFUN+DCQ_CODZON+DCQ_SERVIC+DCQ_TAREFA+DCQ_ATIVID'
		// Analise combinatoria para busca da regra de convocacao
		//              Zona + Servico + Tarefa + Atividade
		// Regra 01     ----              Zona do endereco em branco          + Servico em branco  + Tarefa em branco   + Atividade em branco
		// Regra 02     -X--              Zona do endereco em branco          + Servico            + Tarefa em branco   + Atividade em branco
		// Regra 03     -XX-              Zona do endereco em branco          + Servico            + Tarefa             + Atividade em branco
		// Regra 04     -XXX              Zona do endereco em branco          + Servico            + Tarefa             + Atividade

		// Regra 05     X---              Zona do endereco origem             + Servico em branco  + Tarefa em branco   + Atividade em branco
		// Regra 06     XX--              Zona do endereco origem             + Servico            + Tarefa em branco   + Atividade em branco
		// Regra 07     XXX-              Zona do endereco origem             + Servico            + Tarefa             + Atividade em branco
		// Regra 08     XXXX              Zona do endereco origem             + Servico            + Tarefa             + Atividade

		// Regra 09     X---              Zona do endereco destino            + Servico em branco  + Tarefa em branco   + Atividade em branco
		// Regra 10     XX--              Zona do endereco destino            + Servico            + Tarefa em branco   + Atividade em branco
		// Regra 11     XXX-              Zona do endereco destino            + Servico            + Tarefa             + Atividade em branco
		// Regra 12     XXXX              Zona do endereco destino            + Servico            + Tarefa             + Atividade

		// Analise combinatoria para busca da regra de convocacao por documento exclusivo apenas
		// Regra 13     -XXX              Zona do endereco em branco          + Servico            + Tarefa             + Atividade
		// Regra 14     -XX-              Zona do endereco em branco          + Servico            + Tarefa             + Atividade em branco
		// Regra 15     -X--              Zona do endereco em branco          + Servico            + Tarefa em branco   + Atividade em branco
		// Regra 16     ----              Zona do endereco em branco          + Servico em branco  + Tarefa em branco   + Atividade em branco
		// DCQ_FILIAL+DCQ_TPREGR+DCQ_STATUS+DCQ_LOCAL+DCQ_CODFUN+DCQ_CODZON+DCQ_SERVIC+DCQ_TAREFA+DCQ_ATIVID
		
		//Após todas as buscas e efetuado uma busca desconsiderando o campo ZONA no select, para encontrar os cadastros onde e informado uma zona especifica.
		
		DCQ->(DbSetOrder(1))
		cCodZon := Space(TamSx3("DCQ_CODZON")[1])
		// Nao precisa avaliar a zona do endereco origem / destino, pois esta procurando zonas em branco
		// Regra 01
		AAdd(aRegra,cCodZon+cSerVazio+cTarVazio+cAtiVazio)
		// Regra 02
		AAdd(aRegra,cCodZon+cSerOrig+cTarVazio+cAtiVazio)
		// Regra 03
		AAdd(aRegra,cCodZon+cSerOrig+cTarOrig+cAtiVazio)
		// Regra 04
		AAdd(aRegra,cCodZon+cSerOrig+cTarOrig+cAtiOrig)

		For n1Cnt := 1 To Len(aRegra)
			If DCQ->(MsSeek(xFilial('DCQ')+'1'+'1'+Self:cArmazem+Self:cRecHumano+aRegra[n1Cnt]))
				// O recurso humano sera convocado
				lRet := .T.
				Exit
			EndIf
		Next
		If !lRet
			aRegra   := {}
		EndIf
		lDocaOri := .F.
		lDocaDes := .F.
		// endereco origem
		Self:oEstFis:SetEstFis(Self:oMovEndOri:GetEstFis())
		Self:oEstFis:LoadData()
		If Self:oEstFis:GetTipoEst() == "5"
			lDocaOri := .T.
		EndIf
		// endereco destino
		Self:oEstFis:SetEstFis(Self:oMovEndDes:GetEstFis())
		Self:oEstFis:LoadData()
		If Self:oEstFis:GetTipoEst() == "5"
			lDocaDes := .T.
		EndIf
		// Zona do endereco origem
		If !lDocaOri .Or. (lDocaOri .And. lDocaDes)
			If !lRet
				cCodZon := Self:oMovEndOri:GetCodZona()
				// Regra 05
				AAdd(aRegra,cCodZon+cSerVazio+cTarVazio+cAtiVazio)
				// Regra 06
				AAdd(aRegra,cCodZon+cSerOrig+cTarVazio+cAtiVazio)
				// Regra 07
				AAdd(aRegra,cCodZon+cSerOrig+cTarOrig+cAtiVazio)
				// Regra 08
				AAdd(aRegra,cCodZon+cSerOrig+cTarOrig+cAtiOrig)
			EndIf
			cCodCfg := Self:oMovEndOri:GetCodCfg()
			cEndAux := Self:oMovEndOri:GetEnder()
		EndIf
		// Zona do endereco destino
		If !lDocaDes .Or. (lDocaOri .And. lDocaDes)
			If !lRet .And. Self:oMovEndDes:GetCodZona() != cCodZon
				cCodZon := Self:oMovEndDes:GetCodZona()
				// Regra 09
				AAdd(aRegra,cCodZon+cSerVazio+cTarVazio+cAtiVazio)
				// Regra 10
				AAdd(aRegra,cCodZon+cSerOrig+cTarVazio+cAtiVazio)
				// Regra 11
				AAdd(aRegra,cCodZon+cSerOrig+cTarOrig+cAtiVazio)
				// Regra 12
				AAdd(aRegra,cCodZon+cSerOrig+cTarOrig+cAtiOrig)
			EndIf
			cCodCfg := Self:oMovEndDes:GetCodCfg()
			cEndAux := Self:oMovEndDes:GetEnder()
		EndIf
		// Verifica se ha regra definida para zona do endereco origem e destino
		If !lRet
			For n1Cnt := 1 To Len(aRegra)
				If DCQ->(MsSeek(xFilial('DCQ')+'1'+'1'+Self:cArmazem+Self:cRecHumano+aRegra[n1Cnt]))
					lRet := .T.
					Exit
				EndIf
			Next
		EndIf
		// Verifica se ha regra definida para o Servico/Tarefa/Atividade. Exemplo: Limitou a execucao da atividade RF para um operador (DCQ_DOCEXC).
		If !lRet
		   cCodZon := Space(TamSx3("DCQ_CODZON")[1])
			// Regra 13
			AAdd(aRegra,cSerOrig+cTarOrig+cAtiOrig)
			// Regra 14
			AAdd(aRegra,cSerOrig+cTarOrig+cAtiVazio)
			// Regra 15
			AAdd(aRegra,cSerOrig+cTarVazio+cAtiVazio)
			// Regra 16
			AAdd(aRegra,cSerVazio+cTarVazio+cAtiVazio)
			For n1Cnt := 1 To Len(aRegra)
				If DCQ->(MsSeek(xFilial('DCQ')+'1'+'1'+Self:cArmazem+cRecVazio+cCodZon+aRegra[n1Cnt]) .And. DCQ_DOCEXC<>"2")
					lRet := .T.
					Exit
				EndIf
			Next
			If !lRet
				aRegra := {}
			EndIf
		EndIf
		//Fazer uma busca desconsiderando o campo ZONA no select, para encontrar os cadastros onde e informado uma zona especifica.
		If !lRet
			cCodZon := Space(TamSx3("DCQ_CODZON")[1])
			AAdd(aRegra,{cSerOrig, cTarOrig, cTarOrig})
			AAdd(aRegra,{cSerOrig,cTarOrig,cAtiVazio})
			AAdd(aRegra,{cSerOrig,cTarVazio,cAtiVazio})
			AAdd(aRegra,{cSerVazio,cTarVazio,cAtiVazio})
			For n1Cnt := 1 To Len(aRegra)
				cAliasDCQ := GetNextAlias()
				BeginSql Alias cAliasDCQ
					SELECT DCQ.R_E_C_N_O_ as RECNODCQ
					FROM %Table:DCQ% DCQ
					WHERE DCQ.DCQ_FILIAL = %xFilial:DCQ%
					AND DCQ_TPREGR = '1'
					AND DCQ_STATUS = '1'
					AND DCQ_LOCAL = %Exp:Self:cArmazem%
					AND DCQ_CODFUN = %Exp:Self:cRecHumano%
					AND DCQ_SERVIC = %Exp:aRegra[n1Cnt,1]%
					AND DCQ_TAREFA = %Exp:aRegra[n1Cnt,2]%
					AND DCQ_ATIVID = %Exp:aRegra[n1Cnt,3]%
					AND DCQ.%NotDel%
				EndSql
				If (cAliasDCQ)->(!Eof())
					DCQ->(DbGoTo((cAliasDCQ)->RECNODCQ))
					lRet := .T.
					Exit
				EndIf
				(cAliasDCQ)->(dbCloseArea())
			Next
			If !lRet
				aRegra := {}
			EndIf
		EndIf
				
		If lRet
			// Retorno da regra, para acao no dlgv001
			AAdd(Self:aRetRegra,Self:cArmazem)     // 01 Armazem
			AAdd(Self:aRetRegra,Self:cRecHumano)   // 02 Recurso Humano
			AAdd(Self:aRetRegra,DCQ->DCQ_CODZON)   // 03 Zona de Armazenagem indicada como limitacao
			AAdd(Self:aRetRegra,DCQ->DCQ_SERVIC)   // 04 Servico
			AAdd(Self:aRetRegra,DCQ->DCQ_TAREFA)   // 05 Tarefa
			AAdd(Self:aRetRegra,DCQ->DCQ_ATIVID)   // 06 Atividade
			AAdd(Self:aRetRegra,DCQ->DCQ_ENDINI)   // 07 Endereco Inicial
			AAdd(Self:aRetRegra,DCQ->DCQ_ENDFIM)   // 08 Endereco Final
			AAdd(Self:aRetRegra,DCQ->DCQ_RESEND)   // 09 Reserva o Endereco
			AAdd(Self:aRetRegra,DCQ->DCQ_LIBEND)   // 10 Como o endereco sera liberado se DCQ_RESEND igual a 1
			AAdd(Self:aRetRegra,DCQ->DCQ_LOCALI)   // 11 Endereco Reservado
			AAdd(Self:aRetRegra,cCodCfg)           // 12 Configuracao do codigo do endereco
			AAdd(Self:aRetRegra,cEndAux)           // 13 Endereco
			AAdd(Self:aRetRegra,DCQ->DCQ_CARGA)    // 14 Cargas que usam a regra
			AAdd(Self:aRetRegra,DCQ->(Recno()))    // 15 Nr.do registro da regra encontrada
			AAdd(Self:aRetRegra,cCodZon)           // 16 Zona de Armazenagem do endereco ( endereco no D12 ). Observacao: Se esta zona for diferente de DCQ_CODZON o recurso humano ficara limitado a trabalhar na zona indicada em DCQ_CODZON
			AAdd(Self:aRetRegra,DCQ->DCQ_DOCEXC)   // 17 Execucao das atividades RF ficara limitado a um unico operador.
		EndIf
	EndIf
	RestArea(aAreaSBE)
Return lRet

METHOD LawLimit() CLASS WMSBCCRegraConvocacao
Local lRet      := .T.
Local lAtribuiRH:= .F.
Local lConvNReg := SuperGetMV("MV_WMSNREG", .F., .F.)
Local aAreaD12  := D12->(GetArea())
Local aRegra    := {}
Local aRegraBkp := Self:aRetRegra
Local cAliasD12 := GetNextAlias()
Local cWhere    := ""
Local cTrava    := ""
Local cRecAux   := Self:cRecHumano
Local cSerOrig  := Self:oMovServic:GetServico()
Local cTarOrig  := Self:oMovTarefa:GetTarefa()
Local cAtiOrig  := Self:oMovTarefa:GetAtivid()
Local cServico  := PadR("", Len(cSerOrig))
Local cTarefa   := PadR("", Len(cTarOrig))
Local cAtividade:= PadR("", Len(cAtiOrig))
Local cRecVazio := PadR("", Len(cRecAux))
Local cEndAux   := ""
Local cCodCfg   := ""
Local n1Cnt     := 0
Local lWmsDocEx := ExistBlock('WMSDOCEX')

	// Analisa regra de convocacao de limitacao
	// Verifica se limitou a regra a alguma Carga
	If !Empty(Self:aRetRegra[14])
		lRet := (Self:oMovimento:oOrdServ:GetCarga()$Self:aRetRegra[14])
	EndIf

	// Verifica se houve limitacao de endereco para convocacao (Preenchimento dos campos DCQ_ENDINI e DCQ_ENDFIM)
	If lRet .And. !Empty(Self:aRetRegra[8]) .And. !Empty(Self:aRetRegra[12])
		cEndAux := Self:aRetRegra[13]
		lRet := (cEndAux >= Self:aRetRegra[7] .And. cEndAux <= Self:aRetRegra[8])
	EndIf

	// Verifica esta limitado a alguma zona de armazenagem
	If lRet .And. !Empty(Self:aRetRegra[3])
		lRet := (Self:aRetRegra[3]==Self:aRetRegra[16])
	EndIf

	// Verifica se exec. atividade RF esta limitado a um unico operador
	If lRet .And. Self:lDocExc
		// Inclui trava para uso exclusivo desta carga / documento
		If	lRet := WMSTrava(1,@cTrava,Self:oMovimento:oOrdServ:GetCarga(),Self:oMovimento:oOrdServ:GetDocto(),"")
			If Self:aRetRegra[17]<>"2" //DCQ_DOCEXC = 2 - Nao
				// Parâmetro Where
				cWhere := "%"
				If !Empty(Self:aRetRegra[4])
					cWhere += " AND D12.D12_SERVIC = '"+Self:aRetRegra[4]+"'"
				EndIf
				If !Empty(Self:aRetRegra[5])
					cWhere += " AND D12.D12_TAREFA = '"+Self:aRetRegra[5]+"'"
				EndIf
				If !Empty(Self:aRetRegra[6])
					cWhere += " AND D12.D12_ATIVID = '"+Self:aRetRegra[6]+"'"
				EndIf
				If !Empty(Self:oMovimento:oOrdServ:GetCarga()) .And. Self:aRetRegra[17]=="1" //DCQ_DOCEXC = 1 - Docto. ou Carga
					cWhere += " AND D12.D12_CARGA = '"+Self:oMovimento:oOrdServ:GetCarga()+"'"
				Else
					cWhere += " AND D12.D12_DOC = '"+Self:oMovimento:oOrdServ:GetDocto()+"'"
					cWhere += " AND D12.D12_CLIFOR = '"+Self:oMovimento:oOrdServ:GetCliFor()+"'"
					cWhere += " AND D12.D12_LOJA = '"+Self:oMovimento:oOrdServ:GetLoja()+"'"
				EndIf
				
				//Ponto de Entrada para manipular o uso exclusivo desta carga/documento
				If lWmsDocEx
					cQueryPE := ExecBlock('WMSDOCEX',.F.,.F.,{cWhere,Self:oMovimento,"1"})
					If ValType(cQueryPE) == "C" .And. !Empty(cQueryPE) 
						cWhere := cQueryPE
					EndIf
				EndIf

				cWhere += "%"
				BeginSql Alias cAliasD12
					SELECT D12.R_E_C_N_O_ RECNOD12
					FROM       %Table:D12% D12
					INNER JOIN %Table:DCI% DCI
					ON DCI.DCI_FILIAL = %xFilial:DCI%
					AND DCI.DCI_CODFUN = %Exp:cRecAux%
					AND DCI.DCI_FUNCAO = D12.D12_RHFUNC
					AND DCI.%NotDel%
					WHERE D12.D12_FILIAL = %xFilial:D12%
					AND D12.D12_LOCORI = %Exp:Self:aRetRegra[1]%
					AND D12.D12_STATUS IN ('-','2','4')
					// Se existe alguma atividade sem rec.humano
					AND D12.D12_RECHUM = %Exp:cRecVazio%
					AND D12.%NotDel%
					%Exp:cWhere%
				EndSql
				Do While (cAliasD12)->(!Eof())
					Self:oMovimento:GoToD12((cAliasD12)->RECNOD12)
					// Verifica se ha regras para convocacao para estas atividades.
					lAtribuiRH := .F.
					Self:aRetRegra := {}
					// Recurso humano
					Self:SetRecHum(cRecAux)
					Self:SetDocExc(.F.)
					Self:SetArmazem(Self:oMovimento:oMovEndOri:GetArmazem())
					If Self:LawRecHum()
						// Analisa se convocao ou nao
						If Self:LawLimit()
							lAtribuiRH := .T.
						EndIf
					ElseIf !lConvNReg
						lAtribuiRH := .T.
					EndIf
					// Grava unico recurso nas atividades pendentes
					If lAtribuiRH
						Self:oMovimento:SetRecHum(cRecAux)
						Self:oMovimento:UpdateD12()
					EndIf
					(cAliasD12)->(dbSkip())
				EndDo
				(cAliasD12)->(dbCloseArea())
				RestArea(aAreaD12)
			EndIf
			// Retira trava para liberar uso desta carga / documento
			WMSTrava(0,cTrava)
		EndIf
		// O recurso humano deve reservar o endereco (DCQ_RESEND=='1')
		Self:aRetRegra := aRegraBkp
		If lRet .And. Self:aRetRegra[9]=='1' .And. !Empty(Self:aRetRegra[12])
			cEndAux := Self:aRetRegra[13]
			cCodCfg := Self:aRetRegra[12]
			aAreaDC7 := DC7->(GetArea())
			DC7->(DbSetOrder(1))
			If DC7->(MsSeek(xFilial('DC7')+cCodCfg))
				cEndAux := PadR(Substr(cEndAux,1,DC7->DC7_POSIC),Len(DCQ->DCQ_LOCALI))
			EndIf
			RestArea(aAreaDC7)
			Self:cArmazem  := Self:aRetRegra[1]
			cCodZon    := PadR("", TamSx3("DCQ_CODZON")[1])
			cServico   := PadR("", Len(cServico))
			cTarefa    := PadR("", Len(cTarefa))
			cAtividade := PadR("", Len(cAtividade))
			// Nao precisa avaliar a zona do endereco origem / destino, pois esta procurando zonas em branco
			// Regra 01
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
			// Regra 02
			cServico  := cSerOrig
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
			// Regra 03
			cTarefa   := cTarOrig
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
			// Regra 04
			cAtividade := cAtiOrig
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)

			cCodZon := Self:aRetRegra[16]
			cServico  := PadR("", Len(cServico))
			cTarefa   := PadR("", Len(cTarefa))
			cAtividade:= PadR("", Len(cAtividade))
			// Regra 05
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
			// Regra 06
			cServico := cSerOrig
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
			// Regra 07
			cTarefa  := cTarOrig
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
			// Regra 08
			cAtividade  := cAtiOrig
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)

			aAreaDCQ := DCQ->(GetArea())
			// DCQ_FILIAL+DCQ_TPREGR+DCQ_STATUS+DCQ_LOCAL+DCQ_LOCALI+DCQ_CODZON+DCQ_SERVIC+DCQ_TAREFA+DCQ_ATIVID+DCQ_CODFUN
			DCQ->(DbSetOrder(2))
			// Verifica se algum recurso humano reservou o endereco
			For n1Cnt := 1 To Len(aRegra)
				If DCQ->(MsSeek(xFilial('DCQ')+'1'+'1'+Self:cArmazem+cEndAux+aRegra[n1Cnt]))
					lRet := (DCQ->DCQ_CODFUN == cRecAux)
					Exit
				EndIf
			Next
			RestArea(aAreaDCQ)

			If lRet
				// Este recurso humano reserva a rua
				RecLock('DCQ',.F.)
				DCQ->DCQ_LOCALI := cEndAux
				MsUnLock()
			EndIf
		EndIf
	EndIf
	//Após chamada recursiva, restaura valor padrão da variável
	Self:SetDocExc(.T.)
	If !lRet .And. !Empty(Self:aRetRegra)
		Self:aRetRegra := {}
	EndIf
Return lRet

METHOD LawChkRua() CLASS WMSBCCRegraConvocacao
Local lRet      := .T.
Local aAreaDC7  := ""
Local aAreaDCQ  := ""
Local aAreaSBE  := ""
Local cCodZon   := ""
Local cServico  := ""
Local cTarefa   := ""
Local cAtividade:= ""
Local cEndAux   := ""
Local cCodCfg   := ""
Local aRegra    := {}
Local n1Cnt     := 0
	// Apesar de o operador(A) nao ter regra definida, preciso analisar se outro operador(B) reservou a rua,
	// se o operador(B) ja reservou a rua o operador(A) nao sera convocado ate que a rua seja liberada.
	cCodZon   := PadR("", TamSx3("DCQ_CODZON")[1])
	cServico  := PadR("", TamSx3("D12_SERVIC")[1])
	cTarefa   := PadR("", TamSx3("D12_TAREFA")[1])
	cAtividade:= PadR("", TamSx3("D12_ATIVID")[1])
	// Nao precisa avaliar a zona do endereco origem / destino, pois esta procurando zonas em branco
	// Regra 01
	AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
	// Regra 02
	cServico := Self:oMovServic:GetServico()
	AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
	// Regra 03
	cTarefa  := Self:oMovTarefa:GetTarefa()
	AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
	// Regra 04
	cAtividade := Self:oMovTarefa:GetAtivid()
	AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
	//
	aAreaSBE := SBE->(GetArea())
	SBE->(DbSetOrder(1))
	Self:oEstFis:SetEstFis(Self:oMovEndOri:GetEstFis())
	Self:oEstFis:LoadData()
	If Self:oEstFis:GetTipoEst() != "5"
		If SBE->(MsSeek(xFilial('SBE')+Self:cArmazem+Self:oMovEndOri:GetEnder()+Self:oMovEndOri:GetEstFis()))
			cCodZon := Self:oMovEndOri:GetCodZona()
			cServico   := PadR("", Len(cServico))
			cTarefa    := PadR("", Len(cTarefa))
			cAtividade := PadR("", Len(cAtividade))
			// Regra 05
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
			// Regra 06
			cServico  := Self:oMovServic:GetServico()
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
			// Regra 07
			cTarefa   := Self:oMovTarefa:GetTarefa()
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
			// Regra 08
			cAtividade:= Self:oMovTarefa:GetAtivid()
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
			cCodCfg := SBE->BE_CODCFG
			cEndAux := Self:oMovEndOri:GetEnder()
		EndIf
	EndIf
	// Zona do endereco destino
	Self:oEstFis:SetEstFis(Self:oMovEndDes:GetEstFis())
	Self:oEstFis:LoadData()
	If Self:oEstFis:GetTipoEst() != "5"
		If SBE->(MsSeek(xFilial('SBE')+Self:cArmazem+Self:oMovEndDes:GetEnder()+Self:oMovEndDes:GetEstFis()))
			If Self:oMovEndDes:GetCodZona() != cCodZon
				cCodZon    := Self:oMovEndDes:GetCodZona()
				cServico   := PadR("", Len(cServico))
				cTarefa    := PadR("", Len(cTarefa))
				cAtividade := PadR("", Len(cAtividade))
				// Regra 09
				AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
				// Regra 10
				cServico  := Self:oMovServic:GetServico()
				AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
				// Regra 11
				cTarefa   := Self:oMovTarefa:GetTarefa()
				AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
				// Regra 12
				cAtividade:= Self:oMovTarefa:GetAtivid()
				AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
			EndIf
			cCodCfg := SBE->BE_CODCFG
			cEndAux := Self:oMovEndDes:GetEnder()
		EndIf
	EndIf
	RestArea(aAreaSBE)
	aAreaDC7 := DC7->(GetArea())
	DC7->(DbSetOrder(1))
	If !Empty(cCodCfg) .And. DC7->(MsSeek(xFilial('DC7')+cCodCfg))
		cEndAux := PadR(Substr(cEndAux,1,DC7->DC7_POSIC),Len(DCQ->DCQ_LOCALI))
		aAreaDCQ := DCQ->(GetArea())
		// DCQ_FILIAL+DCQ_TPREGR+DCQ_STATUS+DCQ_LOCAL+DCQ_LOCALI+DCQ_CODZON+DCQ_SERVIC+DCQ_TAREFA+DCQ_ATIVID+DCQ_CODFUN
		DCQ->(DbSetOrder(2))
		// Verifica se algum recurso humano reservou o endereco
		For n1Cnt := 1 To Len(aRegra)
			If DCQ->(MsSeek(xFilial('DCQ')+'1'+'1'+Self:cArmazem+cEndAux+aRegra[n1Cnt]))
				// O endereco esta reservado
				lRet:=.F.
				Exit
			EndIf
		Next
		RestArea(aAreaDCQ)
	EndIf
	RestArea(aAreaDC7)
Return lRet

METHOD LawLibRua() CLASS WMSBCCRegraConvocacao
Local lRet     := .F.
Local aAreaD12 := D12->(GetArea())
Local aAreaDCQ := DCQ->(GetArea())
Local cAliasD12:= GetNextAlias()
Local cWhere   := "" 
	// Libera a RUA ao finalizar cada atividade
	If Self:aRetRegra[10]=='1'
		lRet := .T.
		// Libera a RUA quando todo o servico / tarefa / atividade forem executados
	ElseIf Self:aRetRegra[10]=='2'
		If Self:lRetAtiv
			// Nao ha servicos, libera a rua
			lRet := .T.
			// Parâmetro Where
			cWhere := "%"
			If !Empty(Self:aRetRegra[4])
				cWhere += " AND D12.D12_SERVIC = '"+Self:aRetRegra[4]+"'"
			EndIf
			If !Empty(Self:aRetRegra[5])
				cWhere += " AND D12.D12_TAREFA = '"+Self:aRetRegra[5]+"'"
			EndIf
			If !Empty(Self:aRetRegra[6])
				cWhere += " AND D12.D12_ATIVID = '"+Self:aRetRegra[6]+"'"
			EndIf
			cWhere += "%"
			BeginSql Alias cAliasD12
				SELECT D12.D12_CARGA,
						D12.R_E_C_N_O_ RECNOD12
				FROM %Table:D12% D12
				WHERE D12.D12_FILIAL = %xFilial:D12%
				AND D12.D12_LOCORI  = %Exp:Self:aRetRegra[1]%
				AND D12.D12_STATUS = '4'
				AND D12.D12_RHFUNC = %Exp:Self:cFuncao%
				AND D12.%NotDel%
				%Exp:cWhere%
			EndSql
			Do While (cAliasD12)->(!Eof())
				// Verifica se limitou a regra a alguma Carga
				If !Empty(Self:aRetRegra[14])
					If !Empty((cAliasD12)->DB_CARGA) .And. !((cAliasD12)->DB_CARGA$Self:aRetRegra[14])
						(cAliasD12)->(DbSkip())
						Loop
					EndIf
				EndIf
				// Encontrou servicos para a carga definida, nao libera a rua
				lRet := .F.
				// Verifica se houve limitacao de endereco para convocacao (Preenchimento dos campos DCQ_ENDINI e DCQ_ENDFIM)
				cEndAux := ''
				If !Empty(Self:aRetRegra[8]) .And. !Empty(Self:aRetRegra[12]) .And. !Empty(Self:aRetRegra[13])
					Self:oMovimento:GoToD12((cAliasD12)->RECNOD12)
					Self:oEstFis:SetEstFis(Self:oMovEndOri:GetEstFis())
					Self:oEstFis:LoadData()
					If Self:oEstFis:GetTipoEst() != "5"
						cEndAux := Self:oMovEndOri:GetEnder()
					Else
						Self:oEstFis:SetEstFis(Self:oMovEndDes:GetEstFis())
						Self:oEstFis:LoadData()
						If Self:oEstFis:GetTipoEst() != "5"
							cEndAux := Self:oMovEndDes:GetEnder()
						EndIf
					EndIf
					If !Empty(cEndAux)
						// Se o endereco nao estiver entre a faixa definida, libera a rua
						lRet := .T.
						cEndAux := PadR(Substr(cEndAux,1,Len(AllTrim(Self:aRetRegra[13]))),Len(DCQ->DCQ_LOCALI))
						If (cEndAux >= Self:aRetRegra[7] .And. cEndAux <= Self:aRetRegra[8])
							// Encontrou servicos num endereco entre a faixa definida, nao libera a rua
							lRet := .F.
							Exit
						EndIf
					EndIf
				EndIf
				(cAliasD12)->(dbSkip())
			EndDo
			(cAliasD12)->(dbCloseArea())
			RestArea(aAreaD12)
		Else
			lRet := .T.
		EndIf
		// O operador libera a RUA atraves do coletor de RF
	ElseIf Self:aRetRegra[10]=='3'
		If Self:lRetAtiv
			lRet := (WMSVTAviso('LAWLIBRUA',STR0001, {STR0002,STR0003}) == 1) // Libera a RUA ? // Sim // Nao
		Else
			lRet := .T.
		EndIf
	EndIf
	If lRet
		dbSelectArea('DCQ')
		DCQ->(dbSetOrder(1))
		DCQ->(MsGoTo(Self:aRetRegra[15]))
		// Se o recurso humano reservou a rua, retira a reserva
		RecLock('DCQ',.F.)
		DCQ->DCQ_LOCALI := Space(Len(DCQ->DCQ_LOCALI))
		MsUnLock()
	EndIf
	//Restaura
	RestArea(aAreaDCQ)
	RestArea(aAreaD12)
Return lRet

METHOD LawSequen(cPriori) CLASS WMSBCCRegraConvocacao
Local aAreaDCQ  := DCQ->(GetArea())
Local aAreaD12  := D12->(GetArea())
Local lRet      := .F.
Local aRegra    := {}
Local aSrv1     := {}
Local aSrv2     := {}
Local aSrv3     := {}
Local aSrv4     := {}
Local cEndAux   := ""
Local n1Cnt     := 0
Local n1Cnt1    := 0
Local cServico  := ""
Local cTarefa   := ""
Local cAtividade:= ""
Local cGrvPri   := ""
Local nPosD12   := 0
Local cSequencia:= "00"
Local nTamServic:= TamSx3("D12_SERVIC")[1]
Local nTamTarefa:= TamSx3("D12_TAREFA")[1]
Local nTamAtivid:= TamSx3("D12_ATIVID")[1]
Local cRegraPrio := SuperGetMV('MV_WMSPRIO', .F., '' ) // Prioridade de convocacao no WMS.
Local lHasRegra  := .F.
Local cPriorAux  := ""

Local cAntServic := ""
Local cAntTarefa := ""
Local cAntAtivid := ""
Local nRegraUso  := 0
Local aRegrasUso := {}

	// Verifica se existe o arquivo de regra
	// Analisa regra de convocacao de sequenciamento
	aAreaDCQ := DCQ->(GetArea())
	aAreaD12 := D12->(GetArea())
	For n1Cnt := 1 To Len(Self:aLibRegra)
		D12->(DbGoTo(Self:aLibRegra[n1Cnt,2]))
		//Variaveis de controle
		cServico  := Space(nTamServic)
		cTarefa   := Space(nTamTarefa)
		cAtividade:= Space(nTamAtivid)
		lHasRegra := .F.
		//Verifica se a regra mudou, caso contrário, não pesquisa de novo
		If nRegraUso == 4
			If cAntServic+cAntTarefa+cAntAtivid != D12->D12_SERVIC+D12->D12_TAREFA+D12->D12_ATIVID
				aRegrasUso := {}
			EndIf
		ElseIf nRegraUso == 3
			If cAntServic+cAntTarefa != D12->D12_SERVIC+D12->D12_TAREFA
				aRegrasUso := {}
			EndIf
		ElseIf nRegraUso == 2
			If cAntServic != D12->D12_SERVIC
				aRegrasUso := {}
			EndIf
		EndIf
		//-- Se mudou o serviço, carrega as informações do mesmo
		If cAntServic != D12->D12_SERVIC
			Self:oMovServic:SetServico(D12->D12_SERVIC)
			Self:oMovServic:SetOrdem(D12->D12_ORDTAR)
			Self:oMovServic:LoadData()
		EndIf
		//Se limpou as regras de uso, deve buscar uma nova
		If Empty(aRegrasUso)
			aRegra  := {}
			lRet    := .F.
			// Regra 01
			AAdd(aRegra,cServico+cTarefa+cAtividade)
			// Regra 02
			cServico   := D12->D12_SERVIC
			AAdd(aRegra,cServico+cTarefa+cAtividade)
			// Regra 03
			cTarefa    := D12->D12_TAREFA
			AAdd(aRegra,cServico+cTarefa+cAtividade)
			// Regra 04
			cAtividade := D12->D12_ATIVID
			AAdd(aRegra,cServico+cTarefa+cAtividade)

			DCQ->(DbSetOrder(3))
			// Aplica regras da mais abrangente para mais aberta
			For n1Cnt1 := Len(aRegra) To 1 Step -1
				If DCQ->(MsSeek(cSeekDCQ:=xFilial('DCQ')+'2'+'1'+Self:cArmazem+aRegra[n1Cnt1])) .And. !Empty(DCQ->DCQ_ORDEM)
					lRet:=.T.
					Exit
				EndIf
			Next

			If lRet
				While DCQ->(!Eof() .And. DCQ->DCQ_FILIAL+DCQ->DCQ_TPREGR+DCQ->DCQ_STATUS+DCQ->DCQ_LOCAL+DCQ->DCQ_SERVIC+DCQ->DCQ_TAREFA+DCQ->DCQ_ATIVID==cSeekDCQ)
					// Regra de sequencia para permitir priorizar blocos de enderecos.
					If Empty(DCQ->DCQ_PRIORI)
						cSequencia := Soma1(cSequencia,2)
						RecLock('DCQ',.F.)
						DCQ->DCQ_PRIORI := cSequencia
						MsUnLock()
					Else
						cSequencia := DCQ->DCQ_PRIORI
					EndIf
					AAdd(aRegrasUso,{DCQ->DCQ_PRIORI,DCQ->DCQ_ORDEM,AllTrim(DCQ->DCQ_ENDINI),AllTrim(DCQ->DCQ_ENDFIM)})
					DCQ->(DbSkip())
				EndDo
			EndIf

			cAntServic := cServico
			cAntTarefa := cTarefa
			cAntAtivid := cAtividade
			nRegraUso  := n1Cnt1
		EndIf

		If lRet
			If Self:oMovServic:GetTipo() $ "2|3"
				cEndAux := D12->D12_ENDORI
			Else
				cEndAux := D12->D12_ENDDES
			EndIf
			For n1Cnt1 := 1 To Len(aRegrasUso)
				If Empty(aRegrasUso[n1Cnt1,4]) .Or. ;
				((Substr(cEndAux,1,Len(aRegrasUso[n1Cnt1,3])) >= aRegrasUso[n1Cnt1,3]) .And.;
				(Substr(cEndAux,1,Len(aRegrasUso[n1Cnt1,4])) <= aRegrasUso[n1Cnt1,4]))
					If Self:oMovServic:ChkConfer()
						AAdd(aSrv3,{cEndAux,D12->D12_SERVIC,D12->D12_ORDTAR,D12->D12_ORDATI,D12->D12_CARGA, D12->(Recno()),Iif(Self:oMovServic:GetTipo()=='1',Replicate('0',2),Replicate('Z',2)),'',D12->D12_DOC,D12->D12_CLIFOR, D12->D12_LOJA})
					Else
						If aRegrasUso[n1Cnt1,2]=='1'
							AAdd(aSrv1,{cEndAux,D12->D12_SERVIC,D12->D12_ORDTAR,D12->D12_ORDATI,D12->D12_CARGA,D12->(Recno()),'',aRegrasUso[n1Cnt1,1], D12->D12_DOC, D12->D12_CLIFOR, D12->D12_LOJA})
						Else
							AAdd(aSrv2,{cEndAux,D12->D12_SERVIC,D12->D12_ORDTAR,D12->D12_ORDATI,D12->D12_CARGA,D12->(Recno()),'',aRegrasUso[n1Cnt1,1], D12->D12_DOC, D12->D12_CLIFOR, D12->D12_LOJA})
						EndIf
					EndIf
					lHasRegra := .T.
					Exit
				EndIf
			Next
		EndIf
		AAdd(Self:aLibRegra[n1Cnt],lHasRegra)
	Next
	aSrv4 := {}
	// Esta variável é uma auxiliar só para ordenação temporária para as faixas das regras
	cPriorAux := StrZero(0,2)

	If !Empty(aSrv1)
		ASort(aSrv1,,,{|x,y|x[1]+x[2]+x[3]+x[4] < y[1]+y[2]+y[3]+y[4]})
		// A T E N C A O : Nao altere o conteudo de cPriori pois o valor obtido no For/Next do vetor aSrv1 sera utilizado no For/Next feito no vetor aSrv2
		cChave := ''
		For n1Cnt := 1 To Len(aSrv1)
			If aSrv1[n1Cnt,1]+aSrv1[n1Cnt,2]+aSrv1[n1Cnt,3]!=cChave
				cPriorAux := Soma1(cPriorAux,2)
				cChave  := aSrv1[n1Cnt,1]+aSrv1[n1Cnt,2]+aSrv1[n1Cnt,3]
			EndIf
			AAdd(aSrv4,{aSrv1[n1Cnt,1],aSrv1[n1Cnt,2],aSrv1[n1Cnt,3],aSrv1[n1Cnt,4],aSrv1[n1Cnt,5],aSrv1[n1Cnt,6],cPriorAux,aSrv1[n1Cnt,8],aSrv1[n1Cnt,9],aSrv1[n1Cnt,10],aSrv1[n1Cnt,11]})
		Next
	EndIf
	If !Empty(aSrv2)
		ASort(aSrv2,,,{|x,y|x[1]+x[2]+x[3]+x[4] < y[1]+y[2]+y[3]+y[4]})
		// A T E N C A O : Neste ponto a variavel cPriorAux esta preenchida e sera utilizada pela funcao soma1() no For/Next abaixo.
		cChave := ''
		For n1Cnt := Len(aSrv2) To 1 Step -1
			If aSrv2[n1Cnt,1]+aSrv2[n1Cnt,2]+aSrv2[n1Cnt,3]!=cChave
				cPriorAux := Soma1(cPriorAux,2)
				cChave  := aSrv2[n1Cnt,1]+aSrv2[n1Cnt,2]+aSrv2[n1Cnt,3]
			EndIf
			aSrv2[n1Cnt,7]:=cPriorAux
		Next
		For n1Cnt := 1 To Len(aSrv2)
			AAdd(aSrv4,{aSrv2[n1Cnt,1],aSrv2[n1Cnt,2],aSrv2[n1Cnt,3],aSrv2[n1Cnt,4],aSrv2[n1Cnt,5],aSrv2[n1Cnt,6],aSrv2[n1Cnt,7],aSrv2[n1Cnt,8],aSrv2[n1Cnt,9],aSrv2[n1Cnt,10],aSrv2[n1Cnt,11]})
		Next
	EndIf
	// Ordena pela prioridade de faixa de enderecos
	If !Empty(aSrv4)
		cChave := ""
		// --- DB_FILIAL+DB_LOCAL+(DB_LOCALIZ ou DB_ENDDES)+DB_SERVIC+DB_ORDTARE+DB_ORDATIV
		ASort(aSrv4,,,{|x,y| x[8]+x[7]+x[1]+x[2]+x[3]+x[4] < y[8]+y[7]+y[1]+y[2]+y[3]+y[4] })
		For n1Cnt := 1 To Len(aSrv4)
			// ---
			If aSrv4[n1Cnt,8]+aSrv4[n1Cnt,7]+aSrv4[n1Cnt,1]+aSrv4[n1Cnt,2]+aSrv4[n1Cnt,3]!=cChave
				cPriori := Soma1(cPriori,2)
				cChave  := aSrv4[n1Cnt,8]+aSrv4[n1Cnt,7]+aSrv4[n1Cnt,1]+aSrv4[n1Cnt,2]+aSrv4[n1Cnt,3]
			EndIf
			D12->(DbGoTo(aSrv4[n1Cnt,6]))
			If D12->(!Eof())
				If Empty(D12->D12_PRIORI)
					cGrvPri := 'ZZ'
				Else
					cGrvPri := SubStr(D12->D12_PRIORI,1,2)
				EndIf
				Reclock('D12', .F.)
				D12->D12_PRIORI := cGrvPri+Iif(Empty(cRegraPrio),'',&(cRegraPrio))+cPriori
				D12->(MsUnLock())
				// Inclui no aLibD12 a prioridade
				nPosD12 := AScan(Self:aLibD12,{|x| x[2] == D12->(Recno())})
				Self:aLibD12[nPosD12,5] := D12->D12_PRIORI
			EndIf
		Next
	EndIf
	If !Empty(aSrv3)
		// Ordena por D12_CARGA/D12_DOC/D12_CLIFOR/D12_LOJA
		ASort(aSrv3,,,{|x,y| x[5]+x[9]+x[10]+x[11] < y[5]+y[9]+y[10]+y[11] })
		For n1Cnt := 1 To Len(aSrv3)
			D12->(DbGoTo(aSrv3[n1Cnt,6]))
			If D12->(!Eof())
				If Empty(D12->D12_PRIORI)
					cGrvPri := 'ZZ'
				Else
					cGrvPri := SubStr(D12->D12_PRIORI,1,2)
				EndIf
				// Chave controle
				Reclock('D12', .F.)
				D12->D12_PRIORI := cGrvPri+Iif(Empty(cRegraPrio),'',&(cRegraPrio))+aSrv3[n1Cnt,7]
				D12->(MsUnLock())
				// Inclui no aLibD12 a prioridade
				nPosD12 := AScan(Self:aLibD12,{|x| x[2] == D12->(Recno())})
				Self:aLibD12[nPosD12,5] := D12->D12_PRIORI
			EndIf
		Next
	EndIf
	// Elimina os movimentos que tem regra para não serem sequenciados novamente
	For n1Cnt := Len(Self:aLibRegra) To 1 Step -1
		// Se encontrou regra elimina do array para não processar novamente
		If Self:aLibRegra[n1Cnt,Len(Self:aLibRegra[n1Cnt])]
			ADel(Self:aLibRegra,n1Cnt)
			ASize(Self:aLibRegra,Len(Self:aLibRegra)-1)
		EndIf
	Next
	// Restaura
	RestArea(aAreaDCQ)
	RestArea(aAreaD12)
Return lRet

METHOD LawLibTar() CLASS WMSBCCRegraConvocacao
Local aAreaDCQ := DCQ->(GetArea())
	// Verifica se existe os indices do arquivo de regras
	// Libera o endereco se estiver travado pelo recurso humano, ao reiniciar a tarefa/atividade.
	If SIX->(MsSeek('DCQ1')) .And. AllTrim(SIX->CHAVE)=='DCQ_FILIAL+DCQ_TPREGR+DCQ_STATUS+DCQ_LOCAL+DCQ_CODFUN+DCQ_CODZON+DCQ_SERVIC+DCQ_TAREFA+DCQ_ATIVID'
		aAreaDCQ := DCQ->(GetArea())
		DCQ->(DbSetOrder(1))
		If DCQ->(MsSeek(cSeekDCQ:=xFilial('DCQ')+'1'+'1'+Self:cArmazem+Self:cRecHumano))
			While DCQ->(!Eof() .And. DCQ->DCQ_FILIAL+DCQ->DCQ_TPREGR+DCQ->DCQ_STATUS+DCQ->DCQ_LOCAL+DCQ->DCQ_CODFUN==cSeekDCQ)
				// Se o recurso humano reservou a rua, retira a reserva
				RecLock('DCQ',.F.)
				DCQ->DCQ_LOCALI := Space(Len(DCQ->DCQ_LOCALI))
				MsUnLock()
				DCQ->(DbSkip())
			EndDo
		EndIf
	EndIf
	RestArea(aAreaDCQ)
Return

METHOD LawGeraSeq(cPriori) CLASS WMSBCCRegraConvocacao
Local aAreaD12:= D12->(GetArea())
Local cEndAux := ""
Local cChave  := ""
Local cGrvPri := ""
Local n1Cnt   := 0
Local nPosD12 := 0
Local cRegraPrio := SuperGetMV('MV_WMSPRIO', .F., '' ) // Prioridade de convocacao no WMS.
Local cAntServic := ""

Default cPriori := StrZero(0,2)
	// Gerar sequencia quando encontrar Regra.
	// Verifica se existe os indices do arquivo de regras
	For n1Cnt := 1 To Len(Self:aLibRegra)
		D12->(DbGoTo(Self:aLibRegra[n1Cnt,2]))
		If D12->(!Eof())
			If cAntServic != D12->D12_SERVIC
				Self:oMovServic:SetServico(D12->D12_SERVIC)
				Self:oMovServic:SetOrdem(D12->D12_ORDTAR)
				Self:oMovServic:LoadData()
				cAntServic := D12->D12_SERVIC
			EndIf
			If Empty(D12->D12_PRIORI)
				cGrvPri := 'ZZ'
			Else
				cGrvPri := SubStr(D12->D12_PRIORI,1,2)
			EndIf
			If Self:oMovServic:GetTipo() $ "2|3"
				cEndAux := D12->D12_ENDORI
			Else
				cEndAux := D12->D12_ENDDES
			EndIf
			If cEndAux <> cChave
				cPriori := Soma1(cPriori,2)
				cChave   := cEndAux
			EndIf
			// Chave de controle
			// Grava a Sequencia de prioridade de convocacao
			Reclock('D12', .F.)
			D12->D12_PRIORI := cGrvPri+Iif(Empty(cRegraPrio),'',&(cRegraPrio))+cPriori
			D12->(MsUnLock())
			// Inclui no aLibD12 a prioridade
			nPosD12 := AScan(Self:aLibD12,{|x| x[2] == D12->(Recno())})
			Self:aLibD12[nPosD12,5] := D12->D12_PRIORI
		EndIf
	Next n1Cnt
	RestArea(aAreaD12)
Return

METHOD LawRefSeq() CLASS WMSBCCRegraConvocacao
Local aAreaD12   := D12->(GetArea())
Local cAliasQry  := Nil
Local cAliasD12  := Nil
Local cTmpLibD12 := "%"+Self:oTmpLibD12:GetRealName()+"%"
Local cTrava     := ""
Local cCargaAnt  := ""

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DISTINCT D12.D12_CARGA,
				D12.D12_DOC,
				D12.D12_CLIFOR,
				D12.D12_LOJA
		FROM %Exp:cTmpLibD12% TP1
		INNER JOIN %Table:D12% D12
		ON D12.R_E_C_N_O_ = TP1.TP1_RECD12
		WHERE D12_FILIAL = %xFilial:D12%
		AND D12.%NotDel%
	EndSql
	Do While (cAliasQry)->(!Eof())
		If !WmsCarga((cAliasQry)->D12_CARGA) .Or. (WmsCarga((cAliasQry)->D12_CARGA) .And. (cAliasQry)->D12_CARGA <> cCargaAnt)
			// Inclui trava para uso exclusivo desta carga / documento
			If WMSTrava(1,@cTrava,(cAliasQry)->D12_CARGA,(cAliasQry)->D12_DOC,"")
				cAliasD12 := GetNextAlias()
				If WmsCarga((cAliasQry)->D12_CARGA)
					BeginSql Alias cAliasD12
						SELECT D12_LOCORI,
								D12_SERVIC,
								D12_STATUS,
								DC5_BLQSRV,
								D12.R_E_C_N_O_ RECNOD12
						FROM %Table:D12% D12
						INNER JOIN %Table:DC5% DC5
						ON DC5_FILIAL = %xFilial:DC5%
						AND DC5_SERVIC = D12_SERVIC
						AND DC5_ORDEM = D12_ORDTAR
						AND DC5.%NotDel%
						WHERE D12_FILIAL = %xFilial:D12%
						AND D12_CARGA  = %Exp:(cAliasQry)->D12_CARGA%
						AND D12_STATUS IN ('-','2','4')
						AND D12.%NotDel%
						AND NOT EXISTS (SELECT 1 
										FROM %Exp:cTmpLibD12% TP1
										WHERE TP1.TP1_RECD12 = D12.R_E_C_N_O_ )
					EndSql
				Else
					BeginSql Alias cAliasD12
						SELECT D12_LOCORI,
								D12_SERVIC,
								D12_STATUS,
								DC5_BLQSRV,
								D12.R_E_C_N_O_ RECNOD12
						FROM %Table:D12% D12
						INNER JOIN %Table:DC5% DC5
						ON DC5_FILIAL = %xFilial:DC5%
						AND DC5_SERVIC = D12_SERVIC
						AND DC5_ORDEM = D12_ORDTAR
						AND DC5.%NotDel%
						WHERE D12_FILIAL = %xFilial:D12%
						AND D12_DOC = %Exp:(cAliasQry)->D12_DOC%
						AND D12_CLIFOR = %Exp:(cAliasQry)->D12_CLIFOR%
						AND D12_LOJA = %Exp:(cAliasQry)->D12_LOJA%
						AND D12_STATUS IN ('-','2','4')
						AND D12.%NotDel%
						AND NOT EXISTS (SELECT 1 
										FROM %Exp:cTmpLibD12% TP1
										WHERE TP1.TP1_RECD12 = D12.R_E_C_N_O_ )
					EndSql
				EndIf
				Do While (cAliasD12)->(!Eof())
					//-- Para ganho de performance não usa o objeto
					If (cAliasD12)->D12_STATUS == '-'
						If aScan(Self:aLibD12,{|x| x[1]+cValToChar(x[2])+x[3]+x[4] == Iif((cAliasD12)->DC5_BLQSRV=='1','2','4')+cValToChar((cAliasD12)->RECNOD12)+(cAliasD12)->D12_LOCORI+(cAliasD12)->D12_SERVIC}) == 0
							aAdd(Self:aLibD12,{Iif((cAliasD12)->DC5_BLQSRV=='1','2','4'),(cAliasD12)->RECNOD12,(cAliasD12)->D12_LOCORI,(cAliasD12)->D12_SERVIC,""})
						EndIf
					Else
						aAdd(Self:aLibD12,{(cAliasD12)->D12_STATUS,(cAliasD12)->RECNOD12,(cAliasD12)->D12_LOCORI,(cAliasD12)->D12_SERVIC,""})
						D12->(DbGoTo((cAliasD12)->RECNOD12))
						RecLock("D12",.F.)
						D12->D12_STATUS := "-"
						D12->(MsUnLock())
					EndIf
					(cAliasD12)->(dbSkip())
				EndDo
				(cAliasD12)->(dbCloseArea())
				// Retira trava para liberar uso desta carga / documento
				WMSTrava(0,cTrava)
				(cAliasQry)->(dbSkip())
			EndIf
		Else
			(cAliasQry)->(dbSkip())		
		EndIf

		cCargaAnt := (cAliasQry)->D12_CARGA
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaD12)
Return

METHOD LawRefDoc() CLASS WMSBCCRegraConvocacao
Local aAreaD12   := D12->(GetArea())
Local cAliasQry  := Nil
Local cAliasD12  := Nil
Local cTmpLibD12 := "%"+Self:oTmpLibD12:GetRealName()+"%"
Local cRecVazio  := PadR("",TamSx3("D12_RECHUM")[1])
Local aRegraBkp  := Self:aRetRegra 
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DISTINCT D12.D12_LOCORI,
				D12.D12_SERVIC,
				D12.D12_CARGA,
				D12.D12_DOC,
				D12.D12_CLIFOR,
				D12.D12_LOJA,
				D12.D12_IDDCF
		FROM %Exp:cTmpLibD12% TP1
		INNER JOIN %Table:D12% D12
		ON D12.R_E_C_N_O_ = TP1.TP1_RECD12
		WHERE D12_FILIAL  = %xFilial:D12%
		AND D12.%NotDel%
	EndSql
	Do While (cAliasQry)->(!Eof())
		cAliasD12 := GetNextAlias()
		If WmsCarga((cAliasQry)->D12_CARGA)
			BeginSql Alias cAliasD12
				SELECT D12.R_E_C_N_O_ RECNOD12
				FROM %Table:D12% D12
				WHERE D12.D12_FILIAL = %xFilial:D12%
				AND D12.D12_SERVIC = %Exp:(cAliasQry)->D12_SERVIC%
				AND D12.D12_LOCORI = %Exp:(cAliasQry)->D12_LOCORI%
				AND D12.D12_STATUS IN ('2','3','4','1')
				AND D12.D12_RECHUM <> %Exp:cRecVazio%
				AND D12.D12_CARGA = %Exp:(cAliasQry)->D12_CARGA%
				AND NOT EXISTS (SELECT 1
								FROM %Table:DCD% DCD
								WHERE DCD.DCD_FILIAL = %xFilial:DCD%
								AND DCD.DCD_CODFUN = D12.D12_RECHUM
								AND DCD.DCD_STATUS = '3' // Ausente
								AND DCD.%NotDel% )
				AND D12.%NotDel%
			EndSql
		Else
			BeginSql Alias cAliasD12
				SELECT D12.R_E_C_N_O_ RECNOD12
				FROM %Table:D12% D12
				WHERE D12.D12_FILIAL = %xFilial:D12%
				AND D12.D12_SERVIC = %Exp:(cAliasQry)->D12_SERVIC%
				AND D12.D12_LOCORI = %Exp:(cAliasQry)->D12_LOCORI%
				AND D12.D12_STATUS IN ('2','3','4','1')
				AND D12.D12_RECHUM <> %Exp:cRecVazio%
				AND D12.D12_DOC = %Exp:(cAliasQry)->D12_DOC%
				AND D12.D12_CLIFOR = %Exp:(cAliasQry)->D12_CLIFOR%
				AND D12.D12_LOJA = %Exp:(cAliasQry)->D12_LOJA%
				AND D12.D12_IDDCF = %Exp:(cAliasQry)->D12_IDDCF%
				AND NOT EXISTS (SELECT 1
								FROM %Table:DCD% DCD
								WHERE DCD.DCD_FILIAL = %xFilial:DCD%
								AND DCD.DCD_CODFUN = D12.D12_RECHUM
								AND DCD.DCD_STATUS = '3' // Ausente
								AND DCD.%NotDel% )
				AND D12.%NotDel%
			EndSql
		EndIf
		Do While (cAliasD12)->(!Eof())
			Self:oMovimento:GoToD12((cAliasD12)->RECNOD12)
			// Verifica se ha regras para convocacao para estas atividades.
			Self:aRetRegra := {}
			Self:SetArmazem(Self:oMovimento:oMovPrdLot:GetArmazem())
			Self:SetRecHum(Self:oMovimento:GetRecHum())
			If Self:LawRecHum()
				// Analisa se convocao ou nao
				Self:LawLimit()
			EndIf
			(cAliasD12)->(DbSkip())
		EndDo
		(cAliasD12)->(DbCloseArea())
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaD12)
	Self:aRetRegra := aRegraBkp
Return

METHOD RedoLawLim(cAntRecHum) CLASS WMSBCCRegraConvocacao
Local lRet      := .T.
Local lAtribuiRH:= .F.
Local lConvNReg := SuperGetMV("MV_WMSNREG", .F., .F.)
Local aAreaD12  := D12->(GetArea())
Local cAliasD12 := GetNextAlias()
Local cWhere    := ""
Local cWhereAux := ""
Local cTrava    := ""
Local cRecAux   := Self:cRecHumano
Local cSerOrig  := Self:oMovServic:GetServico()
Local cTarOrig  := Self:oMovTarefa:GetTarefa()
Local cAtiOrig  := Self:oMovTarefa:GetAtivid()
Local cServico  := PadR("", Len(cSerOrig))
Local cTarefa   := PadR("", Len(cTarOrig))
Local cAtividade:= PadR("", Len(cAtiOrig))
Local cRecVazio := PadR("", Len(cRecAux))
Local cEndVazio := PadR("",TamSx3("D12_ENDORI")[1])
Local cEndAux   := ""
Local cCodCfg   := ""
Local aRegra    := {}
Local aRegraBkp := Self:aRetRegra
Local n1Cnt     := 0
Local lWmsDocEx := ExistBlock('WMSDOCEX')
Local cQueryPE  := ""

	// Analisa regra de convocacao de limitacao
	// Verifica se limitou a regra a alguma Carga
	If !Empty(Self:aRetRegra[14])
		lRet := (Self:oMovimento:oOrdServ:GetCarga()$Self:aRetRegra[14])
	EndIf

	// Verifica se houve limitacao de endereco para convocacao (Preenchimento dos campos DCQ_ENDINI e DCQ_ENDFIM)
	If lRet .And. !Empty(Self:aRetRegra[8]) .And. !Empty(Self:aRetRegra[12])
		cEndAux := Self:aRetRegra[13]
		lRet := (cEndAux >= Self:aRetRegra[7] .And. cEndAux <= Self:aRetRegra[8])
	EndIf

	// Verifica esta limitado a alguma zona de armazenagem
	If lRet .And. !Empty(Self:aRetRegra[3])
		lRet := (Self:aRetRegra[3]==Self:aRetRegra[16])
	EndIf

	// Verifica se exec. atividade RF esta limitado a um unico operador
	If lRet .And. Self:lDocExc
		// Inclui trava para uso exclusivo desta carga / documento
		If	lRet := WMSTrava(1,@cTrava,Self:oMovimento:oOrdServ:GetCarga(),Self:oMovimento:oOrdServ:GetDocto(),"")
			If Self:aRetRegra[17]<>"2" //DCQ_DOCEXC = 2 - Nao
				// Parâmetro Where
				cWhere := "%"
				If !Empty(Self:aRetRegra[4])
					cWhere += " AND D12.D12_SERVIC = '"+Self:aRetRegra[4]+"'"
				EndIf
				If !Empty(Self:aRetRegra[5])
					cWhere += " AND D12.D12_TAREFA = '"+Self:aRetRegra[5]+"'"
				EndIf
				If !Empty(Self:aRetRegra[6])
					cWhere += " AND D12.D12_ATIVID = '"+Self:aRetRegra[6]+"'"
				EndIf
				If !Empty(Self:oMovimento:oOrdServ:GetCarga()) .And. Self:aRetRegra[17]=="1" //DCQ_DOCEXC = 1 - Docto. ou Carga
					cWhere += " AND D12.D12_CARGA = '"+Self:oMovimento:oOrdServ:GetCarga()+"'"
				Else
					cWhere += " AND D12.D12_DOC = '"+Self:oMovimento:oOrdServ:GetDocto()+"'"
					cWhere += " AND D12.D12_CLIFOR = '"+Self:oMovimento:oOrdServ:GetCliFor()+"'"
					cWhere += " AND D12.D12_LOJA = '"+Self:oMovimento:oOrdServ:GetLoja()+"'"
				EndIf
	
				//Ponto de Entrada para manipular o uso exclusivo desta carga/documento
				If lWmsDocEx
					cQueryPE := ExecBlock('WMSDOCEX',.F.,.F.,{cWhere,Self:oMovimento,"2"})
					If ValType(cQueryPE) == "C" .And. !Empty(cQueryPE) 
						cWhere := cQueryPE
					EndIf
				EndIf

				cWhere += "%"
				// Parâmetro WhereAux
				cWhereAux := "%"
				If !Empty(Self:aRetRegra[4])
					cWhereAux += " AND D12A.D12_SERVIC = D12.D12_SERVIC"
				EndIf
				If !Empty(Self:aRetRegra[5])
					cWhereAux += " AND D12A.D12_TAREFA = D12.D12_TAREFA"
				EndIf
				If !Empty(Self:aRetRegra[6])
					cWhereAux += " AND D12A.D12_ATIVID = D12.D12_ATIVID"
				EndIf
				If !Empty(Self:oMovimento:oOrdServ:GetCarga()) .And. Self:aRetRegra[17]=="1" //DCQ_DOCEXC = 1 - Docto. ou Carga
					cWhereAux += " AND D12A.D12_CARGA = D12.D12_CARGA"
				Else
					cWhereAux += " AND D12A.D12_DOC = D12.D12_DOC"
					cWhereAux += " AND D12A.D12_CLIFOR = D12.D12_CLIFOR"
					cWhereAux += " AND D12A.D12_LOJA = D12.D12_LOJA"
				EndIf

				//Ponto de Entrada para manipular o uso exclusivo desta carga/documento
				If lWmsDocEx
					cQueryPE := ExecBlock('WMSDOCEX',.F.,.F.,{cWhereAux,Self:oMovimento,"3"})
					If ValType(cQueryPE) == "C" .And. !Empty(cQueryPE) 
						cWhereAux := cQueryPE
					EndIf
				EndIf

				cWhereAux += "%"
				BeginSql Alias cAliasD12
					SELECT D12.R_E_C_N_O_ RECNOD12
					FROM       %Table:D12% D12
					INNER JOIN %Table:DCI% DCI
					ON DCI.DCI_FILIAL = %xFilial:DCI%
					AND DCI.DCI_CODFUN = %Exp:cRecAux%
					AND DCI.DCI_FUNCAO = D12_RHFUNC
					AND DCI.%NotDel%
					WHERE D12.D12_FILIAL = %xFilial:D12%
					AND D12.D12_LOCORI = %Exp:Self:aRetRegra[1]%
					// Se existe alguma atividade com o rec.humano
					AND D12.D12_RECHUM = %Exp:cRecAux%
					AND NOT EXISTS (SELECT 1
									FROM %Table:D12% D12A
									WHERE D12A.D12_FILIAL = %xFilial:D12%
									AND D12A.D12_LOCORI = D12.D12_LOCORI
									AND D12A.D12_RECHUM = D12.D12_RECHUM
									%Exp:cWhereAux%
									AND D12A.D12_STATUS IN ('1','2')
									OR (D12A.D12_STATUS IN ('3') 
									AND D12A.D12_QTDLID > 0)
									AND D12A.%NotDel% )
					%Exp:cWhere%
					AND D12.%NotDel%
				EndSql
				Do While (cAliasD12)->(!Eof())
				    Self:oMovimento:GoToD12((cAliasD12)->RECNOD12)
					// Verifica se ha regras para convocacao para estas atividades.
					lAtribuiRH := .F.
					Self:aRetRegra := {}
					// Recurso humano
					Self:SetRecHum(cRecAux)
					Self:SetDocExc(.F.)
					Self:SetArmazem(Self:oMovimento:oMovEndOri:GetArmazem())
					If Self:LawRecHum()
						// Analisa se convocao ou nao
						If Self:LawLimit()
							lAtribuiRH := .T.
						EndIf
					ElseIf !lConvNReg
						lAtribuiRH := .T.
					EndIf
					// Grava unico recurso nas atividades pendentes
					If lAtribuiRH
						Self:oMovimento:SetRecHum(cRecVazio)
						Self:oMovimento:UpdateD12()
					EndIf
					(cAliasD12)->(dbSkip())
				EndDo
				(cAliasD12)->(dbCloseArea())
				RestArea(aAreaD12)
			EndIf
			// Retira trava para liberar uso desta carga / documento
			WMSTrava(0,cTrava)
		EndIf
		// O recurso humano deve reservar o endereco (DCQ_RESEND=='1')
		Self:aRetRegra := aRegraBkp
		If lRet .And. Self:aRetRegra[9]=='1' .And. !Empty(Self:aRetRegra[12])
			cEndAux := Self:aRetRegra[13]
			cCodCfg := Self:aRetRegra[12]
			aAreaDC7 := DC7->(GetArea())
			DC7->(DbSetOrder(1))
			If DC7->(MsSeek(xFilial('DC7')+cCodCfg))
				cEndAux := PadR(Substr(cEndAux,1,DC7->DC7_POSIC),Len(DCQ->DCQ_LOCALI))
			EndIf
			RestArea(aAreaDC7)
			Self:cArmazem  := Self:aRetRegra[1]
			cCodZon    := PadR("", TamSx3("DCQ_CODZON")[1])
			cServico   := PadR("", Len(cServico))
			cTarefa    := PadR("", Len(cTarefa))
			cAtividade := PadR("", Len(cAtividade))
			// Nao precisa avaliar a zona do endereco origem / destino, pois esta procurando zonas em branco
			// Regra 01
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
			// Regra 02
			cServico  := cSerOrig
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
			// Regra 03
			cTarefa   := cTarOrig
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
			// Regra 04
			cAtividade := cAtiOrig
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)

			cCodZon := Self:aRetRegra[16]
			cServico   := PadR("", Len(cServico))
			cTarefa    := PadR("", Len(cTarefa))
			cAtividade := PadR("", Len(cAtividade))
			// Regra 05
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
			// Regra 06
			cServico := cSerOrig
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
			// Regra 07
			cTarefa  := cTarOrig
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)
			// Regra 08
			cAtividade  := cAtiOrig
			AAdd(aRegra,cCodZon+cServico+cTarefa+cAtividade)

			aAreaDCQ := DCQ->(GetArea())
			// DCQ_FILIAL+DCQ_TPREGR+DCQ_STATUS+DCQ_LOCAL+DCQ_LOCALI+DCQ_CODZON+DCQ_SERVIC+DCQ_TAREFA+DCQ_ATIVID+DCQ_CODFUN
			DCQ->(DbSetOrder(2))
			// Verifica se algum recurso humano reservou o endereco
			For n1Cnt := 1 To Len(aRegra)
				If DCQ->(MsSeek(xFilial('DCQ')+'1'+'1'+Self:cArmazem+cEndAux+aRegra[n1Cnt]))
					lRet := (DCQ->DCQ_CODFUN == cRecVazio)
					Exit
				EndIf
			Next
			RestArea(aAreaDCQ)

			If lRet
				// Este recurso humano reserva a rua
				RecLock('DCQ',.F.)
				DCQ->DCQ_LOCALI := cEndVazio
				MsUnLock()
			EndIf
		EndIf
	EndIf
Return lRet

METHOD ArrayToDB() CLASS WMSBCCRegraConvocacao
Local aRecD12 := {}
	// Configura tabela LibD12
	If Self:oTmpLibD12 == Nil
		Self:oTmpLibD12 := __aTemps[1]
	EndIf
	// Atualiza dados
	If Self:oTmpLibD12 != Nil
		AEval(Self:aLibD12,{|x| AAdd(aRecD12,{x[2]})})
		MntCargDad(Self:oTmpLibD12:GetAlias(),aRecD12,{"TP1_RECD12"},,.F.)
	EndIf
Return
