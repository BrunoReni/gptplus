#INCLUDE "PROTHEUS.CH"
 
Function GFEA079A(cContrato)
	Local oGerarTabelaFrete := GFEGerarTabelaFrete():New()
	Local cCompVlFix 		:= ""	
	Local cCompVlUni 		:= ""
	Local cCompVlPer 		:= ""
	Local aTrechos			:= {}
	Local cUniFai			:= ""
	Local aCompTre			:= {}
	Local cAddImp			:= ""
	Local cMVAGRORI			:= SuperGetMV("MV_AGRORI",.F.,.F.)
	Local cMVSIGAAGR		:= SuperGetMV("MV_SIGAAGR",.F.,.F.)
	Local lRetAGR001		:= .T.

	GXT->(dbSetOrder(1))
	If GXT->(dbSeek(xFilial("GXT")+cContrato))
		If GFXCP12117("GXT_TOMFRT") .And. GXT->GXT_TOMFRT == "2"
			GFEHelp("O tomador de frete deste contrato � a contratada, n�o gerando cobran�a, por este motivo n�o � poss�vel gerar tabela de frete.";
			       ,"Caso seja necess�rio gerar tabela de frete deste contrato, deve ser alterado o tomador de frete.","N�o � poss�vel gerar Tabela/Negocia��o de Frete!")
			oGerarTabelaFrete:Destroy(oGerarTabelaFrete)
			Return
		EndIf
		
		// Verificando se o contrato j� est� relacionado a uma tabela de frete
		If !Empty(GXT->GXT_NRTAB) .And. !Empty(GXT->GXT_NRNEG)
			GFEHelp("Este contrato j� est� vinculado a uma negocia��o de frete. Neste caso n�o � poss�vel gerar uma nova negocia��o.";
			       ,"A tabela vinculada a este contrato � a " + GXT->GXT_NRTAB + " e a negocia��o � " + GXT->GXT_NRNEG,"N�o � poss�vel gerar Tabela/Negocia��o de Frete!")
			oGerarTabelaFrete:Destroy(oGerarTabelaFrete)
			Return
		EndIf
		
		If Empty(GXT->GXT_DTIRET)
			GFEHelp("Para gerar tabela de frete � necess�rio preencher o campo Dt Ini Retir!";
			       ,"Para prosseguir com a gera��o preencha o  campo Dt Ini Retir com a data de In�cio  do transporte da mercadoria.","N�o � poss�vel gerar Tabela/Negocia��o de Frete!")
			oGerarTabelaFrete:Destroy(oGerarTabelaFrete)
			Return
		EndIf
		
		// Validando a exist�ncia de componentes para o tipo de valor informado
		GXU->(dbSetorder(1))
		If GXU->(dbSeek(xFilial("GXU")+cContrato))
			While(GXU->GXU_FILIAL == xFilial("GXU") .And. GXU->GXU_NRCT == cContrato)
				If !Empty(GXU->GXU_VLFIX) .And. Empty(cCompVlFix)
					oGerarTabelaFrete:VlFixBuscarComp()
					
					If oGerarTabelaFrete:getStatus() == .F.
						GFEHelp(oGerarTabelaFrete:getMensagem(),oGerarTabelaFrete:getSolucao(),"N�o � poss�vel gerar Tabela/Negocia��o de Frete!")
						oGerarTabelaFrete:Destroy(oGerarTabelaFrete)
						Return
					Else
						cCompVlFix := oGerarTabelaFrete:getComp()
					EndIf
				EndIf
			
				If !Empty(GXU->GXU_VLUNI) .And. Empty(cCompVlUni)
					oGerarTabelaFrete:VlUniBuscarComp()
					
					If oGerarTabelaFrete:getStatus() == .F.
						GFEHelp(oGerarTabelaFrete:getMensagem(),oGerarTabelaFrete:getSolucao(),"N�o � poss�vel gerar Tabela/Negocia��o de Frete!")
						oGerarTabelaFrete:Destroy(oGerarTabelaFrete)
						Return
					Else
						cCompVlUni := oGerarTabelaFrete:getComp()
					EndIf
				EndIf
				
				If GFXCP12117("GXU_FRTPES") .And. !Empty(GXU->GXU_FRTPES) .And. Empty(cCompVlUni)
					oGerarTabelaFrete:VlUniBuscarComp()
					
					If oGerarTabelaFrete:getStatus() == .F.
						GFEHelp(oGerarTabelaFrete:getMensagem(),oGerarTabelaFrete:getSolucao(),"N�o � poss�vel gerar Tabela/Negocia��o de Frete!")
						oGerarTabelaFrete:Destroy(oGerarTabelaFrete)
						Return
					Else
						cCompVlUni := oGerarTabelaFrete:getComp()
					EndIf
				EndIf
							
				GXU->(dbSkip())
			EndDo
		Else
			GFEHelp("N�o existem rotas cadastradas no contrato.",;
					"Realize o cadastro das rotas para gerar a tabela de frete atrav�s do contrato",;
					"N�o � poss�vel gerar Tabela/Negocia��o de Frete!")
			Return
		EndIf

		//chama fun��o AGRO passando filial e contrato (AGRX550E.prw)
		If cMVAGRORI .And. cMVSIGAAGR .And. FindFunction("GFEAGR001")
		   lRetAGR001 := GFEAGR001(GXT->GXT_FILIAL, GXT->GXT_NRCT, .F.)
			If !lRetAGR001
				Return .F.
			EndIf
		EndIf
	
		// Definindo os valores para cria��o da tabela de frete
		oGerarTabelaFrete:setCodTransp(GXT->GXT_CDTRP)
		oGerarTabelaFrete:setDtContrato(DToS(GXT->GXT_DTCT))
		oGerarTabelaFrete:setDsTab("TABELA REFERENTE AO CONTRATO " + cContrato)
		oGerarTabelaFrete:setTpTab("1")
		
		// Execu��o do m�todo respons�vel por criar a tabela de frete (GVA)
		oGerarTabelaFrete:TabCriaReg()
		
		If oGerarTabelaFrete:getStatus() == .F.
			GFEHelp(oGerarTabelaFrete:getMensagem(),,"N�o � poss�vel gerar Tabela/Negocia��o de Frete!")
			oGerarTabelaFrete:Destroy(oGerarTabelaFrete)
			Return
		EndIf
		
		// Definindo os valores para a cria��o das negocia��es de frete, componentes, faixa e rotas
		oGerarTabelaFrete:setCdClFr(GXT->GXT_CDCLFR)
		oGerarTabelaFrete:setCdTpOp(GXT->GXT_CDTPOP)
		oGerarTabelaFrete:setDtIniVal(DToS(GXT->GXT_DTIRET))
		oGerarTabelaFrete:setTpLota("1")
		
		If !Empty(cCompVlFix)
			oGerarTabelaFrete:setCompFreMin(cCompVlFix)
		ElseIf !Empty(cCompVlUni)
			oGerarTabelaFrete:setCompFreMin(cCompVlUni)
		Else
			oGerarTabelaFrete:setCompFreMin(cCompVlPer)
		EndIf
		
		GXU->(dbSetorder(1))
		GXU->(dbSeek(xFilial("GXU")+cContrato))
		While(GXU->GXU_FILIAL == xFilial("GXU") .And. GXU->GXU_NRCT == cContrato)
			aTrechos := {}
			
			Aadd(aTrechos,GXU->GXU_NRCIDO)
			Aadd(aTrechos,GXU->GXU_NRCIDD)
			
			oGerarTabelaFrete:setAddTrechos(aTrechos)		
			
			If Empty(cUnifai)
				If GFXCP12117("GXU_UMPESO") .And. !Empty(GXU->GXU_UMPESO)
					cUnifai := GXU->GXU_UMPESO
					oGerarTabelaFrete:setUniFai(GXU->GXU_UMPESO)
				ElseIf !Empty(GXU->GXU_UNIMED)
					cUnifai := GXU->GXU_UNIMED
					oGerarTabelaFrete:setUniFai(GXU->GXU_UNIMED)
				EndIf
			EndIf
			
			If Empty(cAddImp)
				If !Empty(GXU->GXU_IMPINC)
					cAddImp := Iif(GXU->GXU_IMPINC == "1","2","1")
					oGerarTabelaFrete:setAdiImp(cAddImp)
				EndIf
			EndIf
			GXU->(dbSkip())
		EndDo
		
		If !Empty(cCompVlFix)
			oGerarTabelaFrete:setAddComponentes(cCompVlFix)
		EndIf
		If !Empty(cCompVlUni)
			oGerarTabelaFrete:setAddComponentes(cCompVlUni)
		EndIf
		If !Empty(cCompVlPer)
			oGerarTabelaFrete:setAddComponentes(cCompVlPer)
		EndIf
		
		oGerarTabelaFrete:NegCriaReg()
		
		If oGerarTabelaFrete:getStatus() == .F.
			GFEHelp(oGerarTabelaFrete:getMensagem(),,"N�o � poss�vel gerar Tabela/Negocia��o de Frete!")
			oGerarTabelaFrete:Destroy(oGerarTabelaFrete)
			Return
		EndIf
		
		GXU->(dbSetorder(1))
		GXU->(dbSeek(xFilial("GXU")+cContrato))
		While(GXU->GXU_FILIAL == xFilial("GXU") .And. GXU->GXU_NRCT == cContrato)
			If !Empty(GXU->GXU_VLFIX)
				aCompTre := {}
				
				Aadd(aCompTre,GXU->GXU_SEQ)
				Aadd(aCompTre,cCompVlFix)
				Aadd(aCompTre,GXU->GXU_VLFIX)
				Aadd(aCompTre,"")
				Aadd(aCompTre,"")
				
				oGerarTabelaFrete:setAddCpTre(aCompTre)
			EndIf
			If !Empty(GXU->GXU_VLUNI)
				aCompTre := {}
				
				Aadd(aCompTre,GXU->GXU_SEQ)
				Aadd(aCompTre,cCompVlUni)
				Aadd(aCompTre,"")
				Aadd(aCompTre,GXU->GXU_VLUNI)
				Aadd(aCompTre,"")
				
				oGerarTabelaFrete:setAddCpTre(aCompTre)
			EndIf
			If GFXCP12117("GXU_FRTPES") .And. !Empty(GXU->GXU_FRTPES)
				aCompTre := {}
				
				Aadd(aCompTre,GXU->GXU_SEQ)
				Aadd(aCompTre,cCompVlUni)
				Aadd(aCompTre,"")
				Aadd(aCompTre,GXU->GXU_FRTPES)
				Aadd(aCompTre,"")
				
				oGerarTabelaFrete:setAddCpTre(aCompTre)
			EndIf
			
			GXU->(dbSkip())
		EndDo
		
		// Definindo os valores para a cria��o da Tarifa e dos componentes da tarifa
		oGerarTabelaFrete:TarifCriaReg()
		
		If oGerarTabelaFrete:getStatus() == .F.
			GFEHelp(oGerarTabelaFrete:getMensagem(),,"N�o � poss�vel gerar Tabela/Negocia��o de Frete!")
			oGerarTabelaFrete:Destroy(oGerarTabelaFrete)
			Return
		EndIf
		
		RecLock("GXT",.F.)
			GXT->GXT_NRTAB := oGerarTabelaFrete:getNrTab()
			GXT->GXT_NRNEG := oGerarTabelaFrete:getNrNeg()
		GXT->(MsUnlock())
		
		If lRetAGR001 .And. !Empty(GXT->GXT_NRTAB) .And. !Empty(GXT->GXT_NRNEG) .And. cMVAGRORI .And. cMVSIGAAGR .And. FindFunction("GFEAGR001")
			GFEAGR001(GXT->GXT_FILIAL, GXT->GXT_NRCT, .T.)
		EndIF
		
		
		MsgInfo("Foi gerada a tabela " + oGerarTabelaFrete:getNrTab() + " e a negocia��o " + oGerarTabelaFrete:getNrNeg() + " para este Contrato.","Tabela de Frete Gerada com sucesso!")
	EndIf
	
	oGerarTabelaFrete:Destroy(oGerarTabelaFrete)
Return