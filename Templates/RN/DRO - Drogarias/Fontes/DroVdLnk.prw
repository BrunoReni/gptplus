#INCLUDE "PROTHEUS.CH" 
#INCLUDE "DROVDLNK.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FRTDEF.CH"

//Definicao de variavel em objeto
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }

//Definicao do DEFAULT
#xcommand DEFAULT <uVar1> := <uVal1> ;
     	   [, <uVarN> := <uValN> ] => ;
           <uVar1> := If( <uVar1> == nil, <uVal1>, <uVar1> ) ;;
		   [ <uVarN> := If( <uVarN> == nil, <uValN>, <uVarN> ); ]
                                  
//Utilizados para conex�o RPC da TOTVSVIDA.DLL
Static oRPCServer
Static cRPCServer
Static nRPCPort
Static cRPCEnv
Static cRPCEmp 
Static cRPCFilial

/*�������������������������������������������������������������������������������������������
���Fun��o	 �DROVLGet  � Autor � VENDAS CRM	                        � Data �20/04/2005���
�����������������������������������������������������������������������������������������Ĵ��
���Descri��o � Solicita que o usuario digite o Numero da Autoriza��o. A seguir chama a    ���
���          � funcao LjDroVLCar() que faz o "Carregamento" dos dados de venda com os dados���
���          � da cota��o do VidaLink referente a este numero de autorizacao              ���
�����������������������������������������������������������������������������������������Ĵ��
���Uso		 � Front Loja com Template Drogarias                                          ���
�������������������������������������������������������������������������������������������*/
Template Function DROVLGet( nOpPbm )
LjDROVLGet( nOpPbm )
Return Nil

/*�������������������������������������������������������������������������������������������
���Fun��o	 �DROVLVen  � Autor � VENDAS CRM		                    � Data �26/04/2005���
�����������������������������������������������������������������������������������������Ĵ��
���Descri��o � Ap�s a conclus�o da venda informa ao VidaLink os produto e quantidades     ���
���          � vendidos atraves da array aVidaLinkD.                                      ���
���          � Obs. As quantidades vendidas acima da autoriza��o ou os produtos n�o auto- ���
���          �      zados n�o ser�o incluidos na array aVidaLinkD e n�o ter�o os seus     ���
���          �      pre�os sem os descontos do PBM.                                       ���
�����������������������������������������������������������������������������������������Ĵ��
���Uso		 � Front Loja com Template Drogarias                        				  ���
�������������������������������������������������������������������������������������������*/
Template Function DROVLVen( )
Local aRet := {}					// Retorno da funcao
Local _aVidaLinkC := ParamIxb[2]	// aVidalinkC
Local _aVidaLinkD := ParamIxb[3]	// aVidalinkD
Local _nVidaLink  := ParamIxb[1]	// nVidalink
Local _cDoc		  := ParamIxb[4]	// Numero do Cupom Fiscal

aRet := LjDROVLVen(_nVidaLink,_aVidaLinkC,_aVidaLinkD,_cDoc)

Return aRet
       
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DROVDLNK  �Autor  �Microsiga           � Data �  06/25/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Template Function CANPSys( )
                                                  
Local aVidaLinkD := {}

aAdd(aVidaLinkD, "" )
aAdd(aVidaLinkD, {} )
aAdd(aVidaLinkD, 0  )  
aAdd(aVidaLinkD, 0  )  
	
oTEF:Operacoes("PHARMASYSTEM_CANCELAMENTO", aVidaLinkD, , ,"")	//PharmaSystem	

Return .T.

/*/
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������Ŀ��
���Fun��o	 �DROVLImp  � Autor � VENDAS CRM		                    � Data �26/04/2005���
�����������������������������������������������������������������������������������������Ĵ��
���Descri��o � Ap�s a conclus�o da venda imprime o comprovante de venda Vidalink no ECF   ���
���          � como no exemplo abaixo:                                                    ���
���          � DEMONSTRATIVO PBM VIDALINK@No.Autorizacao.: 123456                         ���
���          �                                                                            ���
���          � Obs. Se existir pagamento com TEF, a impress�o do cupom VIDALINK se dar�   ���
���          �      junto com o cupom TEF.                                                ���
�����������������������������������������������������������������������������������������Ĵ��
���Uso		 � Front Loja com Template Drogarias                    				      ���
������������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
/*/
Template Function DROVLImp( )
Local _nVidaLink := ParamIxb[1] // nVidalink
Local aRet := {}				// Retorno da Funcao

aRet := LjDROVLImp(_nVidaLink)

Return (aRet)

/*/
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������Ŀ��
���Fun��o	 �DROVLBPro � Autor � VENDAS CRM				            � Data �12/05/2010���
�����������������������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de busca de produtos na chamada da DLL. 							  ���
�����������������������������������������������������������������������������������������Ĵ��
���Uso		 � Front Loja com Template Drogarias                        				  ���
������������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
/*/
Template Function DROVLBPro(cCodBarra, lIncProd)
	Local cRet          := ""  	// Retorno da funcao
	Local cDescrProd	:= ""  	// Descricao do produto
	Local nPrecoPMC		:= 0   	// Preco Maximo Consumidor
	Local nPrecoPromo	:= 0   	// Preco de venda do estabelecimento
	Local lEncontrou	:= .F. 	// Encontrou o produto?
	Local cCodProd	:= ""
	
	Default lIncProd := .F.
	
	DbSelectArea("SBI")
	SBI->(DbSetorder(5))
	             
	If SBI->(DbSeek(xFilial("SBI") + PADR(cCodBarra, 13)))
		cDescrProd	:= SBI->BI_DESC
		nPrecoPMC	:= SBI->BI_PRV
		nPrecoPromo	:= SBI->BI_PRV
		cCodProd	:= SBI->BI_COD
		lEncontrou	:= .T.
	EndIf
	
	If lEncontrou
		cPrecoPMC	:= PadR(AllTrim(Str(nPrecoPMC,14,2)), 11)
		cPrecoPMC	:= StrTran(cPrecoPMC, '.', '', 1)
		cPrecoPromo	:= PadR(AllTrim(Str(nPrecoPromo,14,2)), 11)
		cPrecoPromo	:= StrTran(cPrecoPromo, '.', '', 1)
		cRet := Space(7) + PadR(cDescrProd, 35) + Space(12) + cPrecoPMC + cPrecoPromo + IIF( !lIncProd, Space(1), Space(1) + cCodProd)
	Else
		cRet := ""
   EndIf
Return cRet

/*/
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������Ŀ��
���Fun��o	 �DROVLCall � Autor � VENDAS CRM				            � Data �12/05/2010���
�����������������������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina chamada apartir do VidaLink atravez de integra��o via DLL.          ���
���          � Na digita��o do codigo de barra do produto no VidaLink, ele passa este     ���
���          � codigo para a DLL TOTVSVIDA.dll que invoca esta funcao tambem passando o   ���
���          � codigo de barra como parametro, esperando como retorno um strig de 75 bytes���
���          � com o formato abaixo.                                                      ���
���          �----------------------------------------------------------------------------���
���          �Inicio|Fim |Tamanho|Conteudo                                                ���
���          �   01 | 07 | 07    | Espacos                                                ���
���          �   08 | 43 | 35    | Descricao do Produto                                   ���
���          �   44 | 54 | 11    | Espacos                                                ���
���          �   55 | 64 | 10    | PMC - Preco Maximo ao Consumidor                       ���
���          �   65 | 74 | 10    | Preco Promocional                                      ���
���          �   75 | 75 | 01    | Espaco                                                 ���
�����������������������������������������������������������������������������������������Ĵ��
���Uso		 � Front Loja com Template Drogarias                        				  ���
������������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
/*/
Template Function DROVLCall(cFuncao, uParm1, uParm2, uParm3, uParm4, uParm5, uParm6)
	Local cRet := "" // Retorno da Funcao
    Local cEAN := "" // EAN do produto
    Local nX   := 0   
    Local nFor := 0
    Local aAuxSer := {}
    Local aServers:= {}
    Local lNewConnect := .F.
    Local lConnect	  := .F.
    	
	// Conexao RPC
	cRPCServer	:= uParm1
	nRPCPort	:= uParm2
	cRPCEnv		:= uParm3
	cRPCEmp		:= uParm4
    cRPCFilial	:= uParm5  
    cEAN 		:= uParm6
	
	nFor := FrtServRpc()		// Carrega o numero de servidores disponiveis 	

	For nX := 1 To nFor         //  Carrega os dados do server
		aAuxSer	:= FrtDadoRpc() 
		If ( !Empty(aAuxSer[1]) .AND. !Empty(aAuxSer[2]) .AND. !Empty(aAuxSer[3])) 		
			Aadd(aServers,{aAuxSer[1],Val(aAuxSer[2]),aAuxSer[3]})
		EndIf
		aAuxSer := {}
	Next nX
	
	lNewConnect := .F.
	If oRPCServer == Nil
		ConOut(STR0021)				   							// "DROVLCall: Chamada ao VIDALINK"
		ConOut(STR0022) 			   							// "DROVLCall: Abrindo nova instancia RPC..."	
		oRPCServer:=FwRpc():New( cRPCServer, nRPCPort , cRpcEnv )	// Instancia o objeto de oServer	
		oRPCServer:SetRetryConnect(1)								// Tentativas de Conexoes
	
		For nX := 1 To Len(aServers)                            	// Metodo para adicionar os Servers 
			oRPCServer:AddServer( aServers[nX][1], aServers[nX][2], aServers[nX][3] )
		Next nX
	
		ConOut(STR0023) 			   							// "DROVLCall: Conectando com o servidor..."	
		lConnect := oRPCServer:Connect()							// Tenta efetuar conexao
		lNewConnect := .T.
	Else
		lConnect 	:= .T.
		lNewConnect := .F.
	EndIf
	
	If lConnect
		If lNewConnect
			oRPCServer:CallProc("RPCSetType", 3 )
			oRPCServer:SetEnv(cRPCEmp,cRPCFilial,"FRT")                 // Prepara o ambiente no servidor alvo
		EndIf

		ConOut(STR0025) 										// "DROVLCall: Buscando produto..."
	   	cRet := oRPCServer:CallProc("T_DROVLBPro", cEAN)	   
		ConOut("Retorno: #" + cRet + "#")						// Exibe o retorno da funcao, que sera enviado para a DLL

		ConOut(STR0034) 										// "DROVLCALL: Desconectando..."
   		oRPCServer:Disconnect()			

		ConOut(STR0035)											// "DROVLCall: Finalizando VIDALINK"
		oRPCServer := Nil

		ConOut(STR0035)											// "DROVLCall: Fim da chamada ao VIDALINK"        */
	EndIf	
	
Return cRet

/*/
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������Ŀ��
���Fun��o	 �DROVLATbl � Autor � VENDAS CRM							� Data �12/05/2010���
�����������������������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina usada para abrir as tabelas de produto SB0 e SBI na chamada da DLL. ���
�����������������������������������������������������������������������������������������Ĵ��
���Uso		 � Front Loja com Template Drogarias                        				  ���
������������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
/*/
Template Function DROVLATbl(cCodEmp, cCodFil)
	Local cDrvX2  := "DBFCDX"				// Driver de acesso
	Local cArqX2  := "SX2" + cCodEmp + "0"	// Nome do arquivo SX2
	Local cArqIX  := "SIX" + cCodEmp + "0"	// Nome do arquivo SXI
	Local cDriver := "DBFCDX"				// Driver de acesso

	Public cFilAnt := cCodFil		  		// Usada no Matxfuna - xFilial                  
	Public cArqTAB := ""					// Usada no Matxfuna - xFilial
	             
	SET DELETED ON
	
	#IFDEF WAXS
		cDrvX2 := "DBFCDXAX"
	#ENDIF
	
	#IFDEF WCODB
		cDrvX2 := "DBFCDXTTS"
	#ENDIF
	                
	USE &("SIGAMAT.EMP") ALIAS "SM0" SHARED NEW VIA cDrvX2
	
	If NetErr()
		UserException(STR0026) //"SM0 Open Failed"
	EndIf
	
	USE &(cArqIX) ALIAS "SIX" SHARED NEW VIA cDrvX2
	
	If NetErr()
		UserException(STR0027) //"SIX Open Failed"
	EndIf
	
	DbSetOrder(1)
	
	If Empty(IndexKey())
		UserException(STR0028) //"SIX Open Index Failed"
	EndIf
	
	USE &(cArqX2) ALIAS "SX2" SHARED NEW VIA cDrvX2
	
	If NetErr()
		UserException(STR0029) //"SX2 Open Failed"
	EndIf
	
	DbSetOrder(1)
	
	If Empty(IndexKey())
		UserException(STR0030) //"SX2 Open Index Failed"
	EndIf
	

	#IFDEF AXS
		cDriver := "DBFCDXAX"
	#ENDIF
	
	#IFDEF CTREE
		cDriver := "CTREECDX"
	#ENDIF
	
	#IFDEF BTV
		cDriver := "BTVCDX"
	#ENDIF
	
	T_DROVLAArq("SBI", cDriver)
	
	SET DELETED OFF
Return Nil

/*/
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������Ŀ��
���Fun��o	 �DROVLAArq � Autor � VENDAS CRM							� Data �12/05/2010���
�����������������������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina usada para abrir as tabelas individualmente.	    				  ���
�����������������������������������������������������������������������������������������Ĵ��
���Uso		 � Front Loja com Template Drogarias                        				  ���
������������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
/*/
Template Function DROVLAArq(cAlias, cDriver)
	Local cArquivo := ""   
	
	DbSelectArea("SIX")
	DbSetOrder(1)
	DbSeek(cAlias)
	
	DbSelectArea("SX2")
	DbSetOrder(1)     
	
	If DbSeek(cAlias)
		cArquivo := AllTrim(SX2->X2_PATH) + AllTrim(SX2->X2_ARQUIVO)
	
		USE &(cArquivo) ALIAS &(cAlias) SHARED NEW VIA cDriver
		
		If NetErr()
			UserException(cAlias + STR0031) //" Open Failed"
		EndIf
		             
 		cArqTab += cAlias+SX2->X2_MODO
		DbSetOrder(1)
	
		If Empty(IndexKey())
			UserException(cAlias + STR0032) //" Open Index Failed"
		EndIf
	Else
		UserException(cAlias + STR0033) //" Not Found in SX2"
	EndIf
Return Nil

/*/
�����������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������Ŀ��
���Fun��o	 �DROVLPSet   � Autor � VENDAS CRM							  � Data �12/05/2010���
�������������������������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina usada para preencher o array aParamVL.	    				    ���
�������������������������������������������������������������������������������������������Ĵ��
���Uso		 � Front Loja com Template Drogarias                        		   		    ���
��������������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������������
/*/
Template Function DROVLPSet(	oHora			, cHora			, oDoc			, cDoc			,;
								oCupom		 	, cCupom		, nLastTotal	, nVlrTotal		,;		
								nLastItem	 	, nTotItens		, nVlrBruto		, oDesconto		,;		
								oTotItens	 	, oVlrTotal		, oFotoProd		, nMoedaCor		,;		
								cSimbCor	 	, oTemp3		, oTemp4		, oTemp5		,;		
								nTaxaMoeda	 	, oTaxaMoeda	, nMoedaCor		, cMoeda		,;		
								oMoedaCor	 	, nVlrPercIT	, cCodProd		, cProduto		,;		
								nTmpQuant	 	, nQuant		, cUnidade		, nVlrUnit		,;		
								nVlrItem		, oProduto		, oQuant		, oUnidade		,;		
								oVlrUnit	 	, oVlrItem		, lF7			, oPgtos		,; 	
								oPgtosSint	 	, aPgtos		, aPgtosSint	, cOrcam		,;
								cPDV		 	, lTefPendCS 	, aTefBKPCS		, oDlgFrt		,;
								cCliente	 	, cLojaCli		, cVendLoja		, lOcioso		,;
								lRecebe			, lLocked		, lCXAberto		, aTefDados		,;
								dDataCN			, nVlrFSD		, lDescIT		, nVlrDescTot	,;
								nValIPI			, aItens 		, nVlrMerc		, lEsc			,;
								aParcOrc	 	, cItemCOrc		, aParcOrcOld	, aKeyFimVenda	,;
								lAltVend	 	, lImpNewIT		, lFechaCup		, aTpAdmsTmp	,;
								cUsrSessionID	, cContrato		, aCrdCliente	, aContratos	,;
								aRecCrd			, aTEFPend		, aBckTEFMult	, cCodConv		,;
								cLojConv		, cNumCartConv	, uCliTPL		, uProdTPL		,;
								lDescTotal		, lDescSE4		, aVidaLinkD	, aVidaLinkc 	,; 
								nVidaLink		, cCdPgtoOrc	, cCdDescOrc	, nValTPis		,; 
								nValTCof		, nValTCsl		, lOrigOrcam	, lVerTEFPend	,;
								nTotDedIcms		, lImpOrc		, nVlrPercTot	, nVlrPercAcr	,; 
								nVlrAcreTot		, nVlrDescCPg	, nVlrPercOri	, nQtdeItOri	,;
								nNumParcs		, aMoeda		, aSimbs		, cRecCart		,; 
								cRecCPF			, cRecCont		, aImpsSL1		, aImpsSL2		,; 
								aImpsProd		, aImpVarDup	, aTotVen		, nTotalAcrs	,;
								lRecalImp		, aCols			, aHeader 		, aDadosJur		,;
								aCProva			, aFormCtrl		, nTroco		, nTroco2 		,; 
								lDescCond		, nDesconto		, aDadosCH		, lDiaFixo		,;
								aTefMult		, aTitulo		, lConfLJRec	, aTitImp		,;
								aParcelas		, oCodProd		, cItemCond		, lCondNegF5	,;
								nTxJuros		, nValorBase	, oMensagem		, oFntGet		,;
								cTipoCli		, lAbreCup		, lReserva		, aReserva  	,;
								oTimer			, lResume		, nValor 		, aRegTEF		,;
								lRecarEfet		, oOnOffLine	, nValIPIIT		, _aMult		,;
								_aMultCanc		, nVlrDescIT	, oFntMoeda		, lBscPrdON		,;
								oPDV			, aICMS			, lDescITReg)    
						
LjDROVLPSet(	@oHora			, @cHora		, @oDoc			, @cDoc			,;
				@oCupom		 	, @cCupom		, @nLastTotal	, @nVlrTotal	,;		
				@nLastItem	 	, @nTotItens	, @nVlrBruto	, @oDesconto	,;		
				@oTotItens	 	, @oVlrTotal	, @oFotoProd	, @nMoedaCor	,;		
				@cSimbCor	 	, @oTemp3		, @oTemp4		, @oTemp5		,;		
				@nTaxaMoeda	 	, @oTaxaMoeda	, @nMoedaCor	, @cMoeda		,;		
				@oMoedaCor	 	, @nVlrPercIT	, @cCodProd		, @cProduto		,;		
				@nTmpQuant	 	, @nQuant		, @cUnidade		, @nVlrUnit		,;		
				@nVlrItem		, @oProduto		, @oQuant		, @oUnidade		,;		
				@oVlrUnit	 	, @oVlrItem		, @lF7			, @oPgtos		,; 	
				@oPgtosSint	 	, @aPgtos		, @aPgtosSint	, @cOrcam		,;
				@cPDV		 	, @lTefPendCS 	, @aTefBKPCS	, @oDlgFrt		,;
				@cCliente	 	, @cLojaCli		, @cVendLoja	, @lOcioso		,;
				@lRecebe		, @lLocked		, @lCXAberto	, @aTefDados	,;
				@dDataCN		, @nVlrFSD		, @lDescIT		, @nVlrDescTot	,;
				@nValIPI		, @aItens 		, @nVlrMerc		, @lEsc			,;
				@aParcOrc	 	, @cItemCOrc	, @aParcOrcOld	, @aKeyFimVenda	,;
				@lAltVend	 	, @lImpNewIT	, @lFechaCup	, @aTpAdmsTmp	,;
				@cUsrSessionID	, @cContrato	, @aCrdCliente	, @aContratos	,;
				@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
				@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
				@lDescTotal		, @lDescSE4		, @aVidaLinkD	, @aVidaLinkc 	,; 
				@nVidaLink		, @cCdPgtoOrc	, @cCdDescOrc	, @nValTPis		,; 
				@nValTCof		, @nValTCsl		, @lOrigOrcam	, @lVerTEFPend	,;
				@nTotDedIcms	, @lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	,; 
				@nVlrAcreTot	, @nVlrDescCPg	, @nVlrPercOri	, @nQtdeItOri	,;
				@nNumParcs		, @aMoeda		, @aSimbs		, @cRecCart		,; 
				@cRecCPF		, @cRecCont		, @aImpsSL1		, @aImpsSL2		,; 
				@aImpsProd		, @aImpVarDup	, @aTotVen		, @nTotalAcrs	,;
				@lRecalImp		, @aCols		, @aHeader 		, @aDadosJur	,;
				@aCProva		, @aFormCtrl	, @nTroco		, @nTroco2 		,; 
				@lDescCond		, @nDesconto	, @aDadosCH		, @lDiaFixo		,;
				@aTefMult		, @aTitulo		, @lConfLJRec	, @aTitImp		,;
				@aParcelas		, @oCodProd		, @cItemCond	, @lCondNegF5	,;
				@nTxJuros		, @nValorBase	, @oMensagem	, @oFntGet		,;
				@cTipoCli		, @lAbreCup		, @lReserva		, @aReserva  	,;
				@oTimer			, @lResume		, @nValor 		, @aRegTEF		,;
				@lRecarEfet		, @oOnOffLine	, @nValIPIIT	, @_aMult		,;
				@_aMultCanc		, @nVlrDescIT	, @oFntMoeda	, @lBscPrdON	,;
				@oPDV			, @aICMS		, @lDescITReg) 
  						
Return(.T.)

/*/
��������������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������������Ŀ��
���Fun��o	 �DROVLPGet      � Autor � VENDAS CRM				             � Data �12/05/2010���
����������������������������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina usada para retornar o array aParamVL.	    				        	   ���
����������������������������������������������������������������������������������������������Ĵ��
���Uso		 � Front Loja com Template Drogarias                        		   		       ���
�����������������������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������������
/*/
Template Function DROVLPGet()
Return(LjDROVLPGet())

/*/
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������Ŀ��
���Fun��o	 �DROVLPVal � Autor � Vendas CRM                            � Data �13/10/2008���
�����������������������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se o valor do item da venda do VidaLink e maior ou menor,         ���
���          � para assumir o menor valor                                                 ���
���          � Recalcula o valor do desconto e percentual quando utiliza o valor do       ���
���          � do VidaLink                                                                ���
�����������������������������������������������������������������������������������������Ĵ��
���Uso		 � Venda assistida e Front Loja com Template Drogarias                        ���
������������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
/*/
Template Function DROVLPVal(aVidaLinkD , aVidaLinkc , nVidaLink , cCodProd   ,;
                            nVlrDescIT , nTmpQuant  , nVlrItem  , nVlrPercIT ,;
                            nVlrUnit   , aVidaLinkD , nNumItem  , uProdTPL   ,;
                            uCliTPL	, lImpOrc	   , cDoc		 , cSerie )
                            
Local aRetorno   := {}

aRetorno := LjDROVLPVal(aVidaLinkD 	, aVidaLinkc , nVidaLink , cCodProd   ,;
                     	nVlrDescIT 	, nTmpQuant  , nVlrItem  , nVlrPercIT ,;
                     	nVlrUnit   	, aVidaLinkD , nNumItem  , uProdTPL   ,;
                     	uCliTPL		, lImpOrc	 , cDoc		 , cSerie )
Return(aRetorno)


/*/{Protheus.doc} RetPharma
Retorna codigo PBM PharmaSys

@param      	
@author  Varejo
@version P11.80
@since   22/05/2015
@return  .T. se a parcela digitada for v�lida / .F. Se a parcela digitada N�O for v�lida.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function RetPharma()

	T_DROVLGet(540)
	
Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} DrSScrExMC
Seta o valor da vari�vel est�tica se cancelou ou n�o 
a tela de medicamentos controlados
@author  julio.nery
@version P12.1.17
@since   01/02/2019
@return  lRet, L�gico
/*/
//-------------------------------------------------------------------
Template Function DrSScrExMC( lSet )
Local lRet := .F.
lRet := LjDrSScrExMC(lSet)
Return lRet