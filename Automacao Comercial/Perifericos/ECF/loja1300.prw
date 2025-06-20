#INCLUDE "MSOBJECT.CH" 
#INCLUDE "DEFECF.CH"                                                                                          

Function LOJA1300 ; Return  	// "dummy" function - Internal Use

//旼컴컴컴컴컴컴컴컴컴컴커
//쿔nformacoes Impressora�
//읕컴컴컴컴컴컴컴컴컴컴켸
#DEFINE _HORA 					"1"			//Obtem a Hora da Impressora
#DEFINE _DATA 					"2"			//Obtem a Data da Impressora
#DEFINE _PAPEL 					"3"			//Verifica se tem Papel
#DEFINE _CANCELAITENS			"4"   		//Verifica se eh possivel cancelar TODOS ou so o ULTIMO item registrado
#DEFINE _CUPOMFECHADO			"5"			//Se o Cupom esta Fechado
#DEFINE _VLSUPRIMENTO			"6"			//Retorna o suprimento da impressora
#DEFINE _DESCONTOITEM			"7"			//ECF permite desconto por item
#DEFINE _REDUCAOPENDENTE		"8"			//Verifica se o dia anterior foi fechado, reducaoz pendente
#DEFINE _STATUSECF 				"9"       	//Verifica o Status do ECF
#DEFINE _ITENSIMPRESSO			"10"      	//Verifica se todos os itens foram impressos
#DEFINE _EMULADOR 				"11"		//Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
#DEFINE _POSSUIFUNCOES			"12"		//Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
#DEFINE _ECFARREDONDA			"13"		//Verifica se o ECF Arredonda o Valor do Item 
#DEFINE _GAVETAABERTA			"14"		//Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
#DEFINE _DESCONTOAPOSREGITEM 	"15"		//Verifica se o ECF permite desconto apos registrar o item (0=Permite)
#DEFINE _EXTENSOCHQ 			"16"        //Verifica se exige o extenso do cheque
#DEFINE _VENDABRUTA 			"17"        //Retorna a Venda Bruta do dia
#DEFINE _GRANTOT 				"18"        //Retorna a Venda Bruta do dia
#DEFINE _DATAMOVIMENTO			"19"        //Retorna a data do movimento
#DEFINE _CNPJ 					"20"        //Retorna o CNPJ
#DEFINE _IE 					"21"        //Retorna o IE
#DEFINE _CRZ 					"22"        //Retorna o CRZ	
#DEFINE _CRO 					"23"        //Retorna o CRO
#DEFINE _MEMADICIONAL			"24"        //Retorna a letra indicativa de MF adicional
#DEFINE _TIPOECF				"25"        //Retorna Tipo de ECF
#DEFINE _MARCA					"26"        //Retorna Marca do ECF
#DEFINE _MODELO					"27"        //Retorna Modelo do ECF
#DEFINE _VERSW  				"28"		//Retorna o Vers�o atual do Software B�sico do ECF gravada na MF
#DEFINE _DATASW 				"29"		//Retorna a Data de instala豫o da vers�o atual do Software B�sico gravada na Mem�ria Fiscal do ECF
#DEFINE _HORASW 				"30"		//Retorna o Hor�rio de instala豫o da vers�o atual do Software B�sico gravada na Mem�ria Fiscal do ECF
#DEFINE _NUMECF 				"31"		//Retorna o N� de ordem seq�encial do ECF no estabelecimento usu�rio
#DEFINE _GRDTOTINI 				"32"		//Retorna o Grande Total Inicial
#DEFINE _GRDTOTFIM 				"33"		//Retorna o Grande Total Final
#DEFINE _VENDABRUT 				"34"		//Retorna a Venda Bruta Diaria
#DEFINE _CCF 					"35"		//Retorna o Contador de Cupom Fiscal CCF
#DEFINE _CNF 					"36"		//Retorna o Contador Geral de Opera豫o N�o Fiscal
#DEFINE _CRG 					"37"		//Retorna o Contador Geral de Relat�rio Gerencial
#DEFINE _CCC 					"38"		//Retorna o Contador de Comprovante de Cr�dito ou D�bito
#DEFINE _DTHRULTCF 				"39"		//Retorna a Data e Hora do ultimo Documento Armazenado na MFD
#DEFINE _CODECF	 				"40"		//Retorna o Codigo da Impressora Referente a TABELA NACIONAL DE C�DIGOS DE IDENTIFICA플O DE ECF
#DEFINE _SUBTOT	 				"42"		//Retorna o Subtotal da venda na impressora Epson
#DEFINE _CODDLLECF	 			"45"		//Busca na DLL do Fabricante o Codigo da Impressora Referente a TABELA NACIONAL DE C�DIGOS DE IDENTIFICA플O DE ECF
#DEFINE _NOMEECF	 			"46"		//Busca na DLL do Fabricante o nome composto pela: Marca + Modelo + " - V. " + Vers�o do Firmware

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튏lasse    쿗JCImpressora    튍utor  쿣endas Clientes     � Data �  05/05/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿝esponsavel em se comunicar com as impressoras fiscais             볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                        		 볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Class LJCImpressora
	
	Data oEcf																//Objeto do tipo LJIEcf
	Data oGlobal															//Objeto do tipo LJCGlobal
			
	Method New()															//Metodo construtor
	Method AbrirPorta(cModelo, cPorta, oTotvsApi)							//Abri a porta de comunicacao com o ECF
	Method LeituraX()														//Emite leituraX
	Method AbrirDia()														//Executa o inicio de dia
	Method InfoEcf(cTipo)													//Retorna um tipo de informacao do ecf
	Method Cupom()															//Retorna o numero do cupom corrente    
	Method Aliquotas()    													//Retorna as aliquotas do ecf
	Method Formas()    												     	//Retorna as formas do ecf
	Method NumeroEcf()														//Retorna o numero do ecf
	Method FechaPorta(cPorta)												//Fecha porta de comunicacao	
	Method NumSerie()														//Retorna o numero de serie
	Method AbrirCF(cCnpj, cCliente, cEndereco)								//Abri o cupom fiscal
	Method CancelaCF()														//Cancela o cupom fiscal
	Method VenderItem(cCodigo	, cDescricao, cTribut	, nAliquota	, ;
	                  nQtde		, nVlUnit	, nDesconto	, cComplemen, ;
	                  cUniMed)	                                            //Vende item
	Method DescItem(nValor)													//Desconto no item
	Method NumeroItem()														//Retorna a quantidade de numero vendidos no cupom
	Method SubTotal()														//Retorna o subtotal
	Method Pagamento(cForma, nValor)										//Efetua o pagamento
	Method FecharCF(oMensagem)												//Fecha o cupom fiscal
	Method AbrirGavet()														//Abri a gaveta
	Method CancItem(cItem		, cCodigo	, cDescricao, cTribut	, ;
					nAliquota	, nQtde		, nVlUnit	, nDesconto	, ;
	    			cUniMed)												//Cancela item
	Method DescTotal(nValor)												//Desconto no total do cupom
	Method AcresItem(nValor)												//Acrescimo no item
	Method AcresTotal(nValor)												//Acrescimo no total do cupom
	Method Sangria(oFormas)													//Efetua sangria de caixa	
	Method Suprimento(oFormas)												//Efetua suprimentro de caixa (entrada de troco)
    Method ConfVerao(cTipo)													//Faz a saida ou entrada do horario de verao
	Method ReducaoZ()														//Efetua a reducaoZ	
	Method DadosRedZ()														//Busca os dados da reducaoZ para gravar o SFI
	Method MFData(dDtInicio, dDtFim, cTipo, cTipoArq)						//Leitua da memoria fiscal por data
	Method MFReducao(cRedInicio, cRedFim, cTipo, cTipoArq)					//Leitura da memoria fiscal por reducao
	Method MFDData(dDtInicio, dDtFim)										//Leitura da memoria fita detalhe por data
   	Method MFDCoo(cCooInicio, cCooFim)										//Leitura da memoria fita detalhe por Coo
   	Method TipoEData(cDatInicio, cDatFim, cPathArq, cBinario)									//Gera arquivo com os registro Tipo E Ato Cotepe 17/04 PAF-ECF por Data
   	Method TipoECrz(cCrzInicio, cCrzFim)									//Gera arquivo com os registro Tipo E Ato Cotepe 17/04 PAF-ECF por Crz
    Method ConfigAliq(nAliq, cTipoIss)										//Configura a aliquota no ECF
    Method ConfTotNF(cNum, cDescr)										//Configura o totalizador n�o fiscal
    Method ConfigPgto(cForma)										//Configura a forma de pagamento

    Method AbrirCNFV(nValor, cForma, cTotaliz, cTotOrig)					//Abre o cupom nao fiscal vinculado
    Method FecharCNFV()														//Fecha o cupom nao fiscal vinculado
    Method ImpTxtNF(oRelatorio, lLinha)										//Imprimi texto no cupom nao fiscal
    Method ImpCodigoBarras( cCodBarras )
	Method Totaliz()    													//Retorna os totalizadores nao fiscais do ecf
	Method ImpCodBar(oCabecalho,cCodBarras, oRodape,cRelatorio,lLinha)      //Imprime um relatorio gerencial com codigo de barras
	Method ImpRelGer(oRelatorio, cRelatorio, lLinha)						//Imprime o relatorio gerencial
	Method Autenticar(cTexto)												//Autentica documento / cheque
	Method ImpCheque(cBanco	, nValor, cData    , cFavorecid , ;
					 cCidade, cTexto, cExtenso , cMoedaS    , ;
					 cMoedaP)												//Imprime cheque         
	Method LeCMC7()															//Le CMC7
	Method AbrirCNF(nValor, cForma, cTotaliz)								//Abre o cupom nao fiscal
	Method ImpPedido(cTef, oRelatorio, nValor)								//Faz a impress�o do pedido
	Method PegPathMFD()														//Retorna o caminho e nome do arquivo de Memoria Fita Detalhe
	Method PegPathMF()														//Retorna o caminho e nome do arquivo de Memoria Fiscal
	Method PegPathTipoE(cBinario)													//Retorna o caminho e nome do arquivo registro Tipo E Ato Cotepe 17/04 PAF-ECF
	Method EstNFiscVinc(cCPFCNPJ,cCliente,cEndereco,cMensagem,cCOOCCD)		//Efetua o estorno do comprovante de credito e debito
	Method PegPathMFBin()														//Captura o Path do arquivo da mem�ria gerado
	Method DownMF()	
	
	//Metodos internos
	Method CriarImp(cModelo)												//Cria o objeto da impressora
	Method TratarRet(oRetorno)                             					//Trata o retorno do ECF
	Method VeriCupAbr()														//Verifica se tem algum cupom vinculado, nao fiscal ou gerencial aberto
	Method ExibirMsg(cMensagem)												//Exibi a mensagem retornada pelo ecf
	Method GetTotPad()														//Pega totalizador padrao para ser usado caso nao esteja configurado no TOTVSAPI.INI
	Method RedZDado()															//Captura os Dados da Redu豫o Z
	Method IdCliente(cCNPJ, cNome, cEnd)
	Method DownloadMFD(cBinario,cTipo,cInicio,cFinal)
EndClass

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇튝etodo    쿙ew   	       튍utor  쿣endas Clientes     � Data �  05/05/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿘etodo construtor da classe LJCImpressora.			    	     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                        		 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros�																	 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿚bjeto														     볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽*/
Method New() Class LJCImpressora

	::oEcf		:= Nil
	::oGlobal	:= LJCGlobal():Global()    
	
Return Self

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튝etodo    쿌brirPorta       튍utor  쿣endas Clientes     � Data �  05/05/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿝esponsavel em abrir a porta de comunicacao com o ECF.	    	 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                        		 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros쿐XPC1 (1 - cModelo) - Modelo do ecf selecionado.		   	         볍�
굇�			 쿐XPC2 (2 - cPorta) - Porta de comunicacao.  				         볍�
굇�			 쿐XPO3 (3 - oTotvsApi) - Objeto do tipo LJCTotvsApi.		         볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿚bjeto														     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Method AbrirPorta(cModelo, cPorta, oTotvsApi) Class LJCImpressora
	
	Local oRetorno  := Nil						//Retorno do metodo
	Local nRet		:= 0                        //Retorno do metodo CriarImp
	
	//Cria o objeto oEcf basedo no modelo selecionado
	nRet := ::CriarImp(cModelo, oTotvsApi)
		
	//Abre a porta serial
	If  nRet == 0
		oRetorno := ::oEcf:AbrirPorta(cPorta)
		oRetorno := ::TratarRet(oRetorno)
	EndIf
	
	//Carrega as informacoes do ecf
	If oRetorno:lRetorno
		oRetorno := ::oEcf:BuscInfEcf()	
		oRetorno := ::TratarRet(oRetorno)
	EndIf
	
	//Verifica se tem algum comprovante aberto, se sim, fecha.
	::VeriCupAbr()
		
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튝etodo    쿗eituraX         튍utor  쿣endas Clientes     � Data �  05/05/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿝esponsavel em emitir uma leituraX                     	    	 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                        		 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros�																     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿙umerico														     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Method LeituraX() Class LJCImpressora

	Local oRetorno := Nil						//Retorno do metodo
		
	//Emite leituraX
	oRetorno := ::oEcf:LeituraX() 
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    

Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튝etodo    쿌brirDia         튍utor  쿣endas Clientes     � Data �  05/05/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿝esponsavel em emitir uma leituraX de inicio de dia      	    	 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                        		 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros�																     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿚bjeto														     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Method AbrirDia() Class LJCImpressora

	Local oRetorno := Nil						//Retorno do metodo
			
	//Emite leituraX
	oRetorno := ::oEcf:AbrirDia() 
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)  

	//Verifica Reducao Z pendente			
	If oRetorno:lRetorno
		If oRetorno:oRetorno <> Nil 
			If oRetorno:oRetorno:lRedzPend
				Self:ExibirMsg("Redu豫o Z Pendente!")
			EndIf
	    EndIf
	EndIf

Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튝etodo    쿔nfoEcf          튍utor  쿣endas Clientes     � Data �  05/05/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿝esponsavel em retornar um tipo de informacao do ecf      	     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                        		 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros쿐XPC1 (1- cTipo) - Tipo da informacao 						     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿚bjeto														     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Method InfoEcf(cTipo) Class LJCImpressora
	
	Local oRetorno := Nil						//Retorno do metodo
	
	Do Case
		
		Case cTipo == _HORA					
			//Obtem a Hora da Impressora
        	oRetorno := ::oEcf:GetDatHora()		

		Case cTipo == _DATA					
			//Obtem a Data da Impressora
			oRetorno := ::oEcf:GetDatHora()
		
		Case (cTipo == _PAPEL .OR. cTipo == _GAVETAABERTA .OR. cTipo == _CUPOMFECHADO .OR. cTipo == _STATUSECF .OR. cTipo == _REDUCAOPENDENTE)
	
			//Verifica se tem Papel
			//Verifica se a Gaveta Acoplada ao ECF
			//Se o Cupom esta Fechado
			//Verifica o Status do ECF
			//Verifica se o dia anterior foi fechado, reducaoz pendente.
			oRetorno := ::oEcf:GetFlagsFi()

		Case cTipo == _CANCELAITENS 		
			//Verifica se eh possivel cancelar TODOS ou so o ULTIMO item registrado
			oRetorno := ::oEcf:GetCancIt()

		Case cTipo ==  _VLSUPRIMENTO		
			//Retorna o suprimento da impressora
			oRetorno := ::oEcf:GetVlSupr()
		
		Case (cTipo == _DESCONTOITEM .OR. cTipo == _DESCONTOAPOSREGITEM)
			
			//ECF permite desconto por item
			//Verifica se o ECF permite desconto apos registrar o item
			oRetorno := ::oEcf:GetDesItem()
		
		Case cTipo == _ITENSIMPRESSO		
			//Verifica se todos os itens foram impressos
			oRetorno := ::oEcf:GetItImp()
		
		Case cTipo == _EMULADOR 			
			//Retorna se eh um Emulador de ECF
			oRetorno := ::oEcf:GetImpFisc()
		
		Case cTipo == _POSSUIFUNCOES		
			//Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal
			oRetorno := ::oEcf:GetPosFunc()
		
		Case cTipo == _ECFARREDONDA			
			//Verifica se o ECF Arredonda o Valor do Item 
			oRetorno := ::oEcf:GetTrunAre()
		
		Case cTipo == _EXTENSOCHQ 			
			//Verifica se exige o extenso do cheque
			oRetorno := ::oEcf:GetChqExt()
		
		Case cTipo == _DATAMOVIMENTO
			//Retorna a data do movimento
			oRetorno := ::oEcf:GetDataMov()
		
		Case cTipo == _CNPJ 				
			//Retorna o CNPJ	
			oRetorno := ::oEcf:GetCNPJ()   
			
		Case cTipo == _IE
			//Retorna o IE
		    oRetorno := ::oEcf:GetInsEst()
		    
		Case cTipo == _CRZ 		    
			//Retorna o CRZ	   
		    oRetorno := ::oEcf:GetNumRedZ()
		
		Case cTipo == _CRO
			//Retorna o CRO    
		    oRetorno := ::oEcf:GetInterve()			
			
		Case cTipo == _MEMADICIONAL
			//Retorna a letra indicativa de MF adicional
		    oRetorno := ::oEcf:GetLetMem()		
			
		Case cTipo == _TIPOECF
			//Retorna Tipo de ECF
		    oRetorno := ::oEcf:GetTipEcf()

		Case cTipo == _MARCA
			//Retorna Marca do ECF
		    oRetorno := ::oEcf:GetFabric()			

		Case cTipo == _MODELO
			//Retorna Modelo do ECF
		    oRetorno := ::oEcf:GetModelo()			
			
		Case cTipo == _VERSW
			//Retorna o Vers�o atual do Software B�sico do ECF gravada na MF
		    oRetorno := ::oEcf:GetVerFirm()			
			                
		Case cTipo == _DATASW
			//Retorna a Data de instala豫o da vers�o atual do Software B�sico gravada na Mem�ria Fiscal do ECF
		    oRetorno := ::oEcf:GetDatSW()			

		Case cTipo == _HORASW
			//Retorna o Horario de instala豫o da vers�o atual do Software B�sico gravada na Mem�ria Fiscal do ECF
		    oRetorno := ::oEcf:GetHorSW()			

		Case cTipo == _NUMECF
			//Retorna o Numero de ordem seq�encial do ECF no estabelecimento usu�rio
		    oRetorno := ::oEcf:GetNumEcf() 

		Case cTipo == _GRDTOTINI
			//Retorna o Grande Total Inicial
		    oRetorno := ::oEcf:GetGrTIni()			
			
		Case cTipo == _GRDTOTFIM
			//Retorna o Grande Total Final
		    oRetorno := ::oEcf:GetGranTot()			
			
		Case cTipo == _VENDABRUT
			//Retorna a Venda Bruta Diaria
		    oRetorno := ::oEcf:GetVdBruta()			
			
		Case cTipo == _CCF
			//Retorna o Contador de Cupom Fiscal CCF
		    oRetorno := ::oEcf:GetNumCup()
			
		Case cTipo == _CNF
			//Retorna o Contador Geral de Opera豫o N�o Fiscal
		    oRetorno := ::oEcf:GetNumCnf()			
			
		Case cTipo == _CRG
			//Retorna o Contador Geral de Relat�rio Gerencial
		    oRetorno := ::oEcf:GetNumCrg()
			
		Case cTipo == _CCC
			//Retorna o Contador de Comprovante de Cr�dito ou D�bito 
		    oRetorno := ::oEcf:GetNumCcc()			

		Case cTipo == _DTHRULTCF
			//Retorna a Data e Hora do ultimo Documento Armazenado na MFD
		    oRetorno := ::oEcf:GetDtUDoc()			
			
		Case cTipo == _CODECF

			//Retorna o Codigo da Impressora Referente a TABELA NACIONAL DE C�DIGOS DE IDENTIFICA플O DE ECF
		    oRetorno := ::oEcf:GetCodEcf()	
		    
		Case cTipo == _GRANTOT
			//Retorna a Venda Bruta do dia	
			oRetorno := ::oEcf:GetGranTot()	
		    		
		Case cTipo == _VENDABRUTA 				
			//Retorna a Venda Bruta do dia	
			oRetorno := ::oEcf:GetVdBruta()
			
		Case cTipo == _SUBTOT  //42
			//Retorna o subtotal
			oRetorno := ::oEcf:GetSubTot()

		Case cTipo == _CODDLLECF 		 //45		
			//Busca na DLL do Fabricante o Codigo da Impressora Referente a TABELA NACIONAL DE C�DIGOS DE IDENTIFICA플O DE ECF	
			oRetorno := ::oEcf:GetCodDllECF()

		Case cTipo == _NOMEECF //46 				
			//Busca na DLL do Fabricante o nome composto pela: Marca + Modelo + " - V. " + Vers�o do Firmware	
			oRetorno := ::oEcf:GetNomeECF()
				
		OtherWise
		
			Return Nil        
	
	EndCase
	
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)   
	
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튝etodo    쿎upom            튍utor  쿣endas Clientes     � Data �  05/05/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿝esponsavel em retornar o numero do cupom corrente      	    	 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                        		 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros�																     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿚bjeto														     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Method Cupom() Class LJCImpressora

	Local oRetorno := Nil						//Retorno do metodo
			
	//Busca o numero do cupom corrente
	oRetorno := ::oEcf:GetNumCup() 
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    

Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튝etodo    쿑ormas           튍utor  쿣endas Clientes     � Data �  05/05/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿝esponsavel em retornar as Formas do ecf           	    	     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                        		 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros�																     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿚bjeto														     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Method Formas() Class LJCImpressora

	Local oRetorno := Nil						//Retorno do metodo
			
	//Busca as aliquotas
	oRetorno := ::oEcf:GetFormas() 
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    

Return oRetorno




/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튝etodo    쿌liquotas        튍utor  쿣endas Clientes     � Data �  05/05/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿝esponsavel em retornar as aliquotas do ecf           	    	 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                        		 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros�																     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿚bjeto														     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Method Aliquotas() Class LJCImpressora

	Local oRetorno := Nil						//Retorno do metodo
			
	//Busca as aliquotas
	oRetorno := ::oEcf:GetAliq() 
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    

Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튝etodo    쿙umeroEcf        튍utor  쿣endas Clientes     � Data �  05/05/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿝esponsavel em retornar o numero do ecf	            	    	 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                        		 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros�																     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿚bjeto														     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Method NumeroEcf() Class LJCImpressora

	Local oRetorno := Nil						//Retorno do metodo
			
	//Busca as aliquotas
	oRetorno := ::oEcf:GetNumEcf() 
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    

Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튝etodo    쿑echaPorta       튍utor  쿣endas Clientes     � Data �  05/05/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿝esponsavel em fechar a porta de comunicacao com o ECF.	    	 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                        		 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros쿐XPC1 (1 - cPorta) - Porta de comunicacao.  				         볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿚bjeto														     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Method FechaPorta(cPorta) Class LJCImpressora
	
	Local oRetorno := Nil						//Retorno do metodo
				
	//Fecha a porta serial
	oRetorno := ::oEcf:FechaPorta(cPorta)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
			
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튝etodo    쿙umSerie         튍utor  쿣endas Clientes     � Data �  05/05/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿝esponsavel em retornar o numero de serie.				    	 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                        		 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros�																	 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿚bjeto														     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Method NumSerie() Class LJCImpressora
	
	Local oRetorno := Nil						//Retorno do metodo
				
	//Busca o numero de serie
	oRetorno := ::oEcf:GetNrSerie()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
			
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튝etodo    쿌brirCF          튍utor  쿣endas Clientes     � Data �  05/05/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿝esponsavel em abrir o cupom fiscal						    	 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                        		 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros쿐XPC1 (1 - ccCnpj) - Cnpj/Cpf do cliente.				   	         볍�
굇�			 쿐XPC2 (2 - cCliente) - Nome do cliente.    				         볍�
굇�			 쿐XPO3 (3 - cEndereco) - Endereco do cliente.				         볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿚bjeto														     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Method AbrirCF(cCnpj, cCliente, cEndereco) Class LJCImpressora
	
	Local oRetorno := Nil						//Retorno do metodo
	
	Default cCnpj 		:= ""
	Default cCliente 	:= ""
	Default cEndereco 	:= ""
		 			
	//Abri o cupom
	oRetorno := ::oEcf:AbrirCF(cCnpj, cCliente, cEndereco)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튝etodo    쿎ancelaCF        튍utor  쿣endas Clientes     � Data �  05/05/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿝esponsavel em cancelar o cupom fiscal						     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                        		 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros�																	 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿚bjeto														     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Method CancelaCF() Class LJCImpressora
	
	Local oRetorno := Nil						//Retorno do metodo
			 			
	//Cancela o cupom
	oRetorno := ::oEcf:CancelaCF()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튡rograma  쿣enderItem튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel pela venda de um item no cupom fiscal    볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPC1 (1 - cCodigo) - Codigo do item vendido.			   	  볍�
굇�			 쿐XPC2 (2 - cDescricao) - Descricao do item.  				  볍�
굇�			 쿐XPC3 (3 - cTribut) - Tipo da tributacao.					  볍�
굇�			 쿐XPN1 (4 - nAliquota) - Aliquota do item.			   	  	  볍�
굇�			 쿐XPN2 (5 - nQtde) - Quantidade do item vendido.	 	  	  볍�
굇�			 쿐XPN3 (6 - nVlUnit) - Valor unitario do item.			   	  볍�
굇�			 쿐XPN4 (7 - nDesconto) - Valor do desconto do item.		  볍�
굇�			 쿐XPC4 (8 - cComplemen) - Complemento da descricao.    	  볍�
굇�			 쿐XPC5 (9 - cUniMed) - Unidade de medida do item.			  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto													  볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method VenderItem(	cCodigo	, cDescricao, cTribut	, nAliquota	, ;
					nQtde	, nVlUnit	, nDesconto	, cComplemen, ;
	    			cUniMed ) Class LJCImpressora
Local oRetorno  := Nil			//Retorno do metodo
Local cUM 		:= space(2)

Default cCodigo		:= ""
Default cDescricao	:= ""
Default cTribut		:= ""
Default nAliquota	:= 0
Default nQtde		:= 0
Default nVlUnit		:= 0
Default nDesconto	:= 0
Default cComplemen	:= ""
Default cUniMed		:= Space(2)

//Limitacao do tamanho do campo pois o ECF s� aceita
//unidade de medida com 2, por�m o Protheus pode estar com mais casas
cUM := PadR(SubStr(AllTrim(cUniMed),1,2),2)

//Vende o item
oRetorno := ::oEcf:VenderItem(	cCodigo	, cDescricao, cTribut	, nAliquota	, ;
							    nQtde	, nVlUnit	, nDesconto	, cComplemen, ;
    							cUM )
//Trata o retorno
oRetorno := ::TratarRet(oRetorno)
		    			
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿏escItem  튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel pelo desconto em um item do cupom fiscal 볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPN1 (1 - nValor) - Valor do desconto.			   	  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto LJCRetornoEcf										  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/                   
Method DescItem(nValor) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Desconto no item
	oRetorno := ::oEcf:DescItem(nValor)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿙umeroItem튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel por retornar o numero do ultimo item 	  볍�
굇�          퀆endido pelo ECF.                                           볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿙enhum													  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method NumeroItem() Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Numero de itens no cupom
	oRetorno := ::oEcf:GetNumItem()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿞ubTotal  튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel por retornar o subtotal da venda    	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿙enhum													  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method SubTotal() Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Retorna o subtotal
	oRetorno := ::oEcf:GetSubTot()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿛agamento 튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel em efetuar o pagamento no cupom fiscal   볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPC1 (1 - cForma) - Forma de pagamento.			   	  	  볍�
굇튡arametros쿐XPN1 (1 - nValor) - Valor do pagamento.			   	  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto LJCRetornoEcf										  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/       
Method Pagamento(cForma, nValor) Class LJCImpressora
	
	Local oRetorno  := Nil						//Retorno do metodo
		
	//Efetua o pagamento no ecf
	oRetorno := ::oEcf:EfetuaPgto(cForma, nValor)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)

Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿑echarCF  튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel em fechar o cupom fiscal   			  볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPO1 (1 - oMensagem) - Mensagem promocional.		   	  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto LJCRetornoEcf										  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/       
Method FecharCF(oMensagem) Class LJCImpressora
	
	Local oRetorno  := Nil						//Retorno do metodo
		
	//Efetua o fechamento do cupom fiscal
	oRetorno := ::oEcf:FecharCF(oMensagem)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿌brirGavet튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel em abrir a gaveta           			  볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros�													   	  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto LJCRetornoEcf										  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/       
Method AbrirGavet() Class LJCImpressora
	
	Local oRetorno  := Nil						//Retorno do metodo
		
	//Efetua a abertura da gaveta
	oRetorno := ::oEcf:AbrirGavet()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿎ancItem  튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel pelo cancelamento item no cupom fiscal   볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPC1 (1 - cItem) - Numero do item vendido.			   	  볍�
굇�			 쿐XPC2 (2 - cCodigo) - Codigo do item vendido.				  볍�
굇�			 쿐XPC3 (3 - cDescricao) - Descricao do item.  				  볍�
굇�			 쿐XPC4 (4 - cTribut) - N/A.		  						  볍�
굇�			 쿐XPN1 (5 - nAliquota) - Aliquota do item.			   	  	  볍�
굇�			 쿐XPN2 (6 - nQtde) - Quantidade do item vendido.	 	  	  볍�
굇�			 쿐XPN3 (7 - nVlUnit) - Valor unitario do item.			   	  볍�
굇�			 쿐XPN4 (8 - nDesconto) - Valor do desconto do item.		  볍�
굇�			 쿐XPC9 (9 - cUniMed) - Unidade de medida do item.			  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto LJCRetornoEcf										  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method CancItem(cItem		, cCodigo	, cDescricao, cTribut	, ;
				nAliquota	, nQtde		, nVlUnit	, nDesconto	, ;
	    		cUniMed ) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo

	Default cItem		:= ""
	Default cCodigo		:= ""
	Default cDescricao	:= ""
	Default cTribut		:= ""
	Default nAliquota	:= 0
	Default nQtde		:= 0
	Default nVlUnit		:= 0
	Default nDesconto	:= 0
	Default cUniMed		:= ""
						 			
	//Cancela o item
	oRetorno := ::oEcf:CancItem(cItem		, cCodigo	, cDescricao, cTribut	, ;
								 nAliquota	, nQtde		, nVlUnit	, nDesconto	, ;
	    						 cUniMed)
	    						 
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
		    			
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿏escTotal 튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel pelo desconto no subtotal do cupom fiscal볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPN1 (1 - nValor) - Valor do desconto.			   	  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method DescTotal(nValor) Class LJCImpressora
    
	Local oRetorno  := Nil						//Retorno do metodo
		
	//Efetua o desconto no total do cupom
	oRetorno := ::oEcf:DescTotal(nValor)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
		
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿌cresItem 튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel pelo acrescimo em um item do  			  볍�
굇�          쿬upom fiscal                                                볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPN1 (1 - nValor) - Valor do acrescimo.			   	  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method AcresItem(nValor) Class LJCImpressora
	
	Local oRetorno  := Nil						//Retorno do metodo
		
	//Efetua o acrescimo no item
	oRetorno := ::oEcf:AcresItem(nValor)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
		
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿌cresTotal튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel pelo acrescimo no subtotal do cupom	  볍�
굇�          쿯iscal                                                	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPN1 (1 - nValor) - Valor do acrescimo.			   	  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method AcresTotal(nValor) Class LJCImpressora
    
	Local oRetorno  := Nil						//Retorno do metodo
		
	//Efetua o acrescimo no total do cupom
	oRetorno := ::oEcf:AcresTotal(nValor)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)

Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿞angria   튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel por efetuar a Sangria  				  볍�
굇�          �		                                        			  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPO1 (1 - oFormas) - LJCFORMASECF com as fomas de pagamento볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method Sangria(oFormas) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo  
	Local cTotaliz  := ""						//Totalizador da Sangria  
	Local cTotPad   := Self:GetTotPad()        //Totalizador padrao
		           
	//Captura os dados do totvsapi.ini
	cTotaliz 	:= GetPvProfString("Totalizadores", "Sangria", cTotPad, GetClientDir() + "TOTVSAPI.INI")		
		
	//Efetua a sangria
	oRetorno := ::oEcf:Sangria(oFormas, cTotaliz)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿞uprimento튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel por efetuar o Fundo de Troco.			  볍�
굇�          �		                                        			  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPO1 (1 - oFormas) - LJCFORMASECF com as fomas de pagamento볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto 													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method Suprimento(oFormas) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
	Local cTotaliz  := ""						//Totalizador do Suprimento
	Local cTotPad   := Self:GetTotPad()       	//Totalizador padrao
	
	//Captura os dados do totvsapi.ini
	cTotaliz 	:= GetPvProfString("Totalizadores", "Suprimento", cTotPad, GetClientDir() + "TOTVSAPI.INI")		
			
	//Efetua o suprimento
	oRetorno := ::oEcf:Suprimento(oFormas, cTotaliz)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)

Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿎onfVerao  튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿘etodo responsavel em efetuar a saida/entrada do horario do  볍�
굇�          퀆erao	                                        			   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                  	   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros쿐XPC1 (1 - cTipo) - E(Entrada) / S(Saida).				   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿚bjeto 													   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Method ConfVerao(cTipo) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Efetua a saida/entrada do horario de verao
	oRetorno := ::oEcf:ConfVerao(cTipo)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)

Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿝educaoZ  튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel por efetuar a Reducao Z.	  			  볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿻enhum													  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto 													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method ReducaoZ() Class LJCImpressora
	
	Local oRetorno  := Nil						//Retorno do metodo
		
	//Efetua a reducaoZ
	oRetorno := ::oEcf:ReducaoZ()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)

Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿏adosRedZ 튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel por retornar os dados capturados na  	  볍�
굇�          쿮xecucao do ultimo comando de ReducaoZ                      볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿙enhum													  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto 													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method DadosRedZ() Class LJCImpressora
	
	Local oRetorno  := Nil						//Retorno do metodo
		
	//Busca os dados da reducaoZ
	oRetorno := ::oEcf:GetDadRedZ()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿘FData    튍utor  쿣endas Clientes     � Data �  22/07/10   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel por efetuar a impressao da Leitura da    볍�
굇�          쿘emoria Fiscal por Data.                                    볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPD1 (1 - dDtInicio) - Data inicial do periodo (ddmmaaaa). 볍�
굇�			 쿐XPD2 (2 - dDtFim) - Data final do periodo (ddmmaaaa).	  볍�
굇�          쿐XPC1 (3 - cTipo) - Tipo da Leitura						  볍�
굇�			 �					  (I - impressao / A - arquivo).		  볍�
굇�			 쿐XPC2 (4 - cTipoArq) - (C - completa / S - simplificada).	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto 													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method MFData(dDtInicio, dDtFim, cTipo, cTipoArq)	Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo

	//Tipo padrao de memoria fiscal C - completa 
	If Empty(cTipoArq)
		cTipoArq := "C"
	EndIf	
		
	//Leitura da memoria fiscal por data
	oRetorno := ::oEcf:MFData(dDtInicio, dDtFim, cTipo, cTipoArq)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
    
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿘FReducao 튍utor  쿣endas Clientes     � Data �  22/07/10   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel por efetuar a impressao da Leitura da    볍�
굇�          쿘emoria Fiscal por Reducao Z.	                              볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPC1 (1 - cRedInicio) - Reducao Z inicial do periodo. 	  볍�
굇�			 쿐XPC2 (2 - cRedFim) - Reducao Z final do periodo.			  볍�
굇�          쿐XPC3 (3 - cTipo) - Tipo da Leitura						  볍�
굇�			 �					  (I- impressao / A - arquivo).			  볍�
굇�			 쿐XPC4 (4 - cTipoArq) - (C - completa / S - simplificada).	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto 													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method MFReducao(cRedInicio, cRedFim, cTipo, cTipoArq) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
	
	//Tipo padrao de memoria fiscal C - completa
	If Empty(cTipoArq)
		cTipoArq := "C"
	EndIf	
		
	//Leitura da memoria fiscal por reducao
	oRetorno := ::oEcf:MFReducao(cRedInicio, cRedFim, cTipo, cTipoArq)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
    
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿘FDData   튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel gerar a Leitura da fita detalhe por data 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPD1 (1 - dDtInicio) - Data inicial do periodo (ddmmaaaa). 볍�
굇�			 쿐XPD2 (2 - dDtFim) - Data final do periodo (ddmmaaaa).	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto 													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method MFDData(dDtInicio, dDtFim) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Leitura da memoria fita detalhe
	oRetorno := ::oEcf:MFDData(dDtInicio, dDtFim)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
    
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿘FDCoo    튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel gerar a Leitura da fita detalhe por Coo  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPC1 (1 - cCooInicio) - Coo inicial						  볍�
굇�			 쿐XPC2 (2 - cCooFim) - Coo final							  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto 													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method MFDCoo(cCooInicio, cCooFim) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Leitura da memoria fita detalhe
	oRetorno := ::oEcf:MFDCoo(cCooInicio, cCooFim)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
    
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿟ipoEData	 튍utor  쿣endas Clientes     � Data �  21/07/10   볍�
굇勁袴袴袴袴曲袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿘etodo responsavel gerar o arquivo TipoE para PAF-ECF p/Data 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                  	   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros쿐XPC1 (1 - cDatInicio) - Data inicial						   볍�
굇�			 쿐XPC2 (2 - cDatFim) - Data final							   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿚bjeto 													   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Method TipoEData(cDatInicio, cDatFim, cPathArq, cBinario) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
	Default cBinario := "0"
	Default cPathArq := ""
	//Gera arquivo de registro tipo e
	oRetorno := ::oEcf:TipoEData(cDatInicio, cDatFim, cPathArq, cBinario)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
    
Return oRetorno      

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿟ipoECrz	 튍utor  쿣endas Clientes     � Data �  21/07/10   볍�
굇勁袴袴袴袴曲袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿘etodo responsavel gerar o arquivo TipoE para PAF-ECF p/Crz  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                  	   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros쿐XPC1 (1 - cCrzInicio) - Crz inicial						   볍�
굇�			 쿐XPC2 (2 - cCrzFim) - Crz final							   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿚bjeto 													   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Method TipoECrz(cCrzInicio, cCrzFim, cBinario) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo

	Default cBinario := "0"
	
	//Gera arquivo de registro tipo e
	oRetorno := ::oEcf:TipoECrz(cCrzInicio, cCrzFim, cBinario)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
    
Return oRetorno  

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿎onfigAliq튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel por efetuar a inclusao de uma aliquota.  볍�
굇�          �								                              볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPN1 (1 - nAliq) - Valor da aliquota.			  		  볍�
굇�			 쿐XPC1 (2 - cTipoIss) - Flag que indica se a aliquota sera   볍�
굇�			 �		referente a ISS (S - Sim, N - Nao ).		  		  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto 													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method ConfigAliq(nAliq, cTipoIss) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Configura a aliquota no ecf
	oRetorno := ::oEcf:ConfigAliq(nAliq, cTipoIss)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
    
Return oRetorno    


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿎onfTotNF 튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel por efetuar a inclusao do totalizador    볍�
굇�          쿙ao Fiscal     				                              볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPN1 (1 - cNum  ) - Numero do Totalizador.		  		  볍�
굇�			 쿐XPC1 (2 - cDescr) - Descricao                              볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto 													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method ConfTotNF(cNum, cDescr) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Configura a aliquota no ecf
	oRetorno := ::oEcf:ConfTotNF(cNum, cDescr)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
    
Return oRetorno

/*


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿎onfTotNF 튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel por efetuar a inclusao do totalizador    볍�
굇�          쿯orma de pagamento     		                              볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPN1 (1 - cDescr  ) - cDescr             .		  		  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto 													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method ConfigPgto(cForma) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Configura a aliquota no ecf
	oRetorno := ::oEcf:ConfigPgto(cForma)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
    
Return oRetorno

/*


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿌brirCNFV 튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel em abrir um cupom vinculado.  			  볍�
굇�          �								                              볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPN1 (1 - nValor) - Valor do documento.			  		  볍�
굇�			 쿐XPC1 (2 - cForma) - Forma de pagamento.					  볍�
굇�			 쿐XPC2 (3 - cTotaliz) - Totalizador nao fiscal.			  볍�
굇�			 쿐XPC3 (4 - cTotOrig) - Totalizador original	.			  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method AbrirCNFV(nValor, cForma, cTotaliz, cTotOrig) Class LJCImpressora
	
	Local oRetorno  	:= Nil						//Retorno do metodo
	Local cTotalizIni 	:= ""						//Totalizador fiscal da recarga de celular
	Local lNaoFiscal	:= .F.						//Se ira imprimir um comprovante nao fiscal
	Local lSFinanc   	:= AliasIndic("MG8") .AND. SuperGetMV("MV_LJCSF",, .F.)	// Valida implementa豫o do Servico Financeiro
	
	Default cTotaliz := ""
	
	//Assume o totalizador como RECEBER
	If Empty(cTotaliz)
		cTotaliz := Self:GetTotPad()
	ElseIf (SuperGetMV("MV_LJVPCNF",,.F.) .Or. lSFinanc) .And. cTotaliz == "Sangria"   
		//Busca Totalizador Nao Fiscal para Servicos Financeiros
		cTotaliz := STWFindTot()
	EndIf
	
	//Busca o totalizador do ini
	cTotalizIni := GetPvProfString("Recarga Celular", "Totalizador", " ", GetClientDir() + "SIGALOJA.INI")
	
	
	//Se o totalizador for igual o da recarga, abre o nao fiscal
	lNaoFiscal := (AllTrim(Upper(cTotOrig)) == AllTrim(Upper(cTotalizIni)))
	
	
	//Verifica se tem algum comprovante aberto, se sim, fecha.
	::VeriCupAbr()
		
	//Abre cupom fiscal vinculado
	If !lNaoFiscal
		oRetorno := ::oEcf:AbrirCNFV(cForma, nValor)
	EndIf
	
	//Verifica se conseguiu abrir o cupom nao fiscal vinculado ou se eh para imprimir o nao fiscal
	If lNaoFiscal .OR. oRetorno:cAcao != OK


		//Abre o cupom nao fiscal
		oRetorno := ::oEcf:AbrirCNF("", "", "", cTotaliz, nValor)		
		//Trata o retorno
		oRetorno := ::TratarRet(oRetorno)
        
		If oRetorno:lRetorno
			//Efetua o pagamento do cupom nao fiscal
			oRetorno := ::oEcf:PgtoCNF(cForma, nValor)
			//Trata o retorno
			oRetorno := ::TratarRet(oRetorno)
		EndIf
		
		If oRetorno:lRetorno
			//Fecha o cupom nao fiscal
			oRetorno := ::oEcf:FecharCNF()
			//Trata o retorno
			oRetorno := ::TratarRet(oRetorno)
		EndIf		
		
		If oRetorno:lRetorno
			//Abre o cupom nao fiscal vinculado
			oRetorno := ::oEcf:AbrirCNFV(cForma, nValor)
			//Trata o retorno
			oRetorno := ::TratarRet(oRetorno)
		EndIf				
		
	Else
		//Trata o retorno
		oRetorno := ::TratarRet(oRetorno)
	EndIf
	
		
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿑echarCNFV튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel pelo fechamento de um cupom nao fiscal   볍�
굇�          퀆inculado													  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿻enhum													  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method FecharCNFV() Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Fecha o cupom nao fiscal vinculado
	oRetorno := ::oEcf:FecharCNFV()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿔mpTxtNF  튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel pel impressao de linhas nao fiscais   	  볍�
굇�          �                                                            볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐xpO1 (1 - oRelatorio) - Linhas nao fiscais.				  볍�
굇�			 쿐xpL1 (2 - lLinha) - Se vai ser impresso linha a linha.	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto 													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method ImpTxtNF(oRelatorio, lLinha) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Imprimi linha no cupom nao fiscal
	oRetorno := ::oEcf:ImpTxtNF(oRelatorio, lLinha)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿔mpCodigoBarras 튍utor  쿣endas Clientes  � Data � 06/03/08 볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel pela impressao de codigo de barras       볍�
굇�          �		                                        			  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPC1 (1 - cRelatorio) - Nome do relatorio.  				  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto LJCRetornoEcf										  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method ImpCodigoBarras( cCodBarras ) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Imprimi linha no cupom nao fiscal
	oRetorno := ::oEcf:ImpCodigoBarras( cCodBarras )
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튝etodo    쿟otaliz          튍utor  쿣endas Clientes     � Data �  05/05/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿝esponsavel em retornar os totalizadores nao fiscais do ecf    	 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                        		 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros�																     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿚bjeto														     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Method Totaliz() Class LJCImpressora

	Local oRetorno := Nil						//Retorno do metodo
			
	//Busca os totalizadores nao fiscais
	oRetorno := ::oEcf:GetTotNf() 
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    

Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿔mpRelGer 튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel pela abertura de um relatorio gerencial  볍�
굇�          �		                                        			  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPO1 (1 - oRelatorio) - Linhas nao fiscais. 				  볍�
굇�			 쿐XPC1 (2 - cRelatorio) - Nome do relatorio.  				  볍�
굇�			 쿐XPL1 (3 - lLinha) - Se vai ser impresso linha a linha.	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto 													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method ImpRelGer(oRelatorio, cRelatorio, lLinha) Class LJCImpressora
    
	Local oRetorno := Nil						//Retorno do metodo
   	
   	//Verifica se tem algum comprovante aberto, se sim, fecha.
	::VeriCupAbr()
	//Abre relatorio gerencial
	oRetorno := ::oEcf:AbrirRG(cRelatorio)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
    
	//Imprimi o texto nao fiscal
	If oRetorno:lRetorno
		oRetorno := ::ImpTxtNF(oRelatorio, lLinha)
	EndIf
	
	//Fecha o relatorio gerencial
	oRetorno := ::oEcf:FecharRG()                 
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
		
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿔mpCodBar 튍utor  쿣endas Clientes     � Data �  14/11/13   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel pela abertura de um relatorio gerencial  볍�
굇�          쿬ontendo um codigo de barras                   			  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPO1 (1 - oRelatorio) - Linhas nao fiscais. 				  볍�
굇�			 쿐XPC1 (2 - cRelatorio) - Nome do relatorio.  				  볍�
굇�			 쿐XPL1 (3 - lLinha) - Se vai ser impresso linha a linha.	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto 													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method ImpCodBar(oCabecalho,cCodBarras, oRodape,cRelatorio,lLinha) Class LJCImpressora
    
	Local oRetorno := Nil						//Retorno do metodo
   	
   	//Verifica se tem algum comprovante aberto, se sim, fecha.
	::VeriCupAbr()
	//Abre relatorio gerencial
	oRetorno := ::oEcf:AbrirRG(cRelatorio)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
    
	//Imprimi o texto nao fiscal
	If oRetorno:lRetorno
		oRetorno := ::ImpTxtNF(oCabecalho, lLinha)
		If oRetorno:lRetorno
			
			oRetorno := ::ImpCodigoBarras(cCodBarras)
			If oRetorno:lRetorno
				oRetorno := ::ImpTxtNF(oRodape, lLinha)
			EndIf
		EndIf
	EndIf
	
	
	//Fecha o relatorio gerencial
	oRetorno := ::oEcf:FecharRG()                 
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
		
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿌utenticar튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel por efetuar a autenticacao.			  볍�
굇�          �								                              볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPC1 (1 - cTexto) - Texto a ser impresso na autenticacao.  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto 													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method Autenticar(cTexto) Class LJCImpressora

	Local oRetorno := Nil						//Retorno do metodo
			
	//Autentica o documento
	oRetorno := ::oEcf:Autenticar(cTexto) 
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    
    
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿔mpCheque 튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel por efetuar a impressao de cheque.		  볍�
굇�          �								                              볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPC1 (1 - cBanco) - Numero do banco.						  볍�
굇�			 쿐XPC2 (2 - nValor) - Valor do cheque.						  볍�
굇�			 쿐XPC3 (3 - cData) - Data do cheque (ddmmaaaa).		 	  볍�
굇�			 쿐XPC4 (4 - cFavorecid) - Nome do favorecido.			   	  볍�
굇�			 쿐XPC5 (5 - cCidade) - Cidade a ser impressa no cheque.	  볍�
굇�			 쿐XPC6 (6 - cTexto) - Texto adicional impresso no cheque.    볍�
굇�			 쿐XPC7 (7 - cExtenso) - Valor do cheque por extenso.	  	  볍�
굇�			 쿐XPC8 (8 - cMoedaS) - Moeda por extenso no singular.	  	  볍�
굇�			 쿐XPC9 (9 - cMoedaP) - Moeda por extenso no plural.		  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto 													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method ImpCheque(cBanco	, nValor, cData    , cFavorecid , ;
				 cCidade, cTexto, cExtenso , cMoedaS    , ;
				 MoedaP) Class LJCImpressora

	Local oRetorno := Nil						//Retorno do metodo
			
	//Imprimi cheque
	oRetorno := ::oEcf:ImpCheque(cBanco	, nValor, cData    , cFavorecid , ;
								  cCidade, cTexto, cExtenso , cMoedaS    , ;
				 				  MoedaP)
				  
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)  			 
	    
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿗eCMC7	튍utor  쿣endas Clientes     � Data �  11/03/10   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel por efetuar a leitura do CMC7.			  볍�
굇�          �								                              볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros�															  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto 													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method LeCMC7() Class LJCImpressora

	Local oRetorno := Nil						//Retorno do metodo
			
	//Le o CMC7
	oRetorno := ::oEcf:LeCMC7() 
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    
    
Return oRetorno

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튡rograma  쿌brirCNF  튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel em abrir um cupom nao fiscal. 			  볍�
굇�          �								                              볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPN1 (1 - nValor) - Valor do documento.			  		  볍�
굇�			 쿐XPC1 (2 - cForma) - Forma de pagamento.					  볍�
굇�			 쿐XPC2 (3 - cTotaliz) - Totalizador nao fiscal.			  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto													  볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method AbrirCNF(nValor, cForma, cTotaliz) Class LJCImpressora
Local oRetorno  := Nil						//Retorno do metodo
Local cTotPad   := Self:GetTotPad()        	//Totalizador padrao
Local cTotaliz  := ""						//Totalizador enviar para abertuda do comprovante nao fiscal
	           
//Captura os dados do totvsapi.ini
If Empty(AllTrim(cTotaliz))
	cTotaliz 	:= GetPvProfString("Totalizadores", "RecebimentoTitulo", cTotPad, GetClientDir() + "TOTVSAPI.INI")
EndIf

//Verifica se tem algum comprovante aberto, se sim, fecha.
::VeriCupAbr()
//Abre o cupom nao fiscal
oRetorno := ::oEcf:AbrirCNF("", "", "", cTotaliz, nValor)		
//Trata o retorno
oRetorno := ::TratarRet(oRetorno)
    
If oRetorno:lRetorno
	//Efetua o pagamento do cupom nao fiscal
	oRetorno := ::oEcf:PgtoCNF(cForma, nValor)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
EndIf

If oRetorno:lRetorno
	//Fecha o cupom nao fiscal
	oRetorno := ::oEcf:FecharCNF()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
EndIf		
	
Return oRetorno

/*複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇튡rograma  쿐stNFiscVinc튍utor  쿣endas Clientes     � Data �  13/03/14 볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel em abrir um cupom nao fiscal. 			  볍�
굇�          �								                              볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPN1 (1 - cCPFCNPJ) - CPF/CNPJ do cliente		  		  볍�
굇�			 쿐XPC2 (2 - cCliente) - Nome do Cliente					  볍�
굇�			 쿐XPC3 (3 - cEndereco) - Endere�o do cliente			      볍�
굇�			 쿐XPC4 (4 - cMensagem) - Mensagem para o cupom de cancelamnto볍�
굇�			 쿐XPC5 (5 - cCOOCCD) - COO do Comprovante de Credito e Debito볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto													  볍�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�*/
Method EstNFiscVinc(cCPFCNPJ,cCliente,cEndereco,cMensagem,cCOOCCD) Class LJCImpressora
Local oRetorno  := Nil						//Retorno do metodo
		           
//Abre o cupom nao fiscal
oRetorno := ::oEcf:EstNFiscVinc(cCPFCNPJ,cCliente,cEndereco,cMensagem,cCOOCCD)

//Trata o retorno
oRetorno := ::TratarRet(oRetorno)
        
Return oRetorno
	    			
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿔mpPedido 튍utor  쿣endas Clientes     � Data �  09/12/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel em imprimir o pedido.		 			  볍�
굇�          �								                              볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐XPC1 (1 - cTef) - Valor do documento.			  		  볍�
굇�			 쿐XPO1 (2 - oRelatorio) - Relatorio a ser impresso.		  볍�
굇�			 쿐XPN1 (3 - nValor) - Valor do cupom nao fiscal.			  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method ImpPedido(cTef, oRelatorio, nValor) Class LJCImpressora
	
	Local cTotPedido 	:= ""								//Totalizador nao fiscal utilizado para impressao do pedido
	Local cTotTefPed	:= ""                             	//Totalizador nao fiscal utilizado para impressao do tef pedido
	Local cFormaPgto	:= ""								//Forma de pagamento utilizada no cupom nao fiscal
	Local oRetorno  	:= Nil								//Retorno do metodo
	
	//Verifica se tem algum comprovante aberto, se sim, fecha.
	::VeriCupAbr()
	
	//Captura os dados do totvsapi.ini
	cTotPedido 	:= GetPvProfString("Microsiga", "TotalizadorPedido", "RECEBER", GetClientDir() + "TOTVSAPI.INI")
	cTotTefPed 	:= GetPvProfString("Microsiga", "TotalizadorTefPedido", "RECEBER", GetClientDir() + "TOTVSAPI.INI")
	cFormaPgto 	:= GetPvProfString("Microsiga", "FormaPgto", "A VISTA", GetClientDir() + "TOTVSAPI.INI")
	
	//Abre comprovante nao fiscal 
	oRetorno := ::AbrirCNF(nValor, cFormaPgto, cTotPedido)	
	
	If oRetorno:lRetorno
		//Abre o cupom nao fiscal vinculado
		oRetorno := ::oEcf:AbrirCNFV(cFormaPgto, nValor)
		//Trata o retorno
		oRetorno := ::TratarRet(oRetorno)	
		
		If oRetorno:lRetorno
			//Imprime texto nao fiscal
			oRetorno := ::ImpTxtNF(oRelatorio, .F.)
		
			//Fecha cupom nao fiscal vinculado
			oRetorno := ::FecharCNFV()
			
			If oRetorno:lRetorno
				If Upper(AllTrim(cTef)) == "S"
                	//Abre comprovante nao fiscal 
					oRetorno := ::AbrirCNF(nValor, cFormaPgto, cTotTefPed)
				EndIf
			EndIf
		EndIf
	EndIf
	
Return oRetorno

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿛egPathMFD튍utor  쿣endas Clientes     � Data �  10/09/09   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝etorna o caminho e nome do arquivo de Memoria Fita Detalhe.볍�
굇�          �								                              볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method PegPathMFD() Class LJCImpressora	 

	Local oRetorno := Nil						//Retorno do metodo
			
	//Busca o path e nome do arquivo de Memoria Fita Detalhe
	oRetorno := ::oEcf:GetPathMFD() 
	
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    

Return oRetorno     

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿛egPathMF 튍utor  쿣endas Clientes     � Data �  10/09/09   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝etorna o caminho e nome do arquivo de Memoria Fiscal.	  볍�
굇�          �								                              볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method PegPathMF() Class LJCImpressora	 

	Local oRetorno := Nil						//Retorno do metodo
			
	//Busca o path e nome do arquivo de Memoria Fita Detalhe
	oRetorno := ::oEcf:GetPathMF() 
	
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    

Return oRetorno
	    			
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿛egPathTipoE튍utor  쿣endas Clientes     � Data �  21/07/10   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝etorna o caminho e nome do arquivo registro Tipo E			볍�
굇�          쿌to Cotepe 17/04 PAF-ECF.		                              	볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  	볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto													  	볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method PegPathTipoE() Class LJCImpressora	 

	Local oRetorno := Nil						//Retorno do metodo
			
	//Busca o path e nome do arquivo registro Tipo E Ato Cotepe 17/04 PAF-ECF.
	oRetorno := ::oEcf:GetPathTipoE() 
	
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    

Return oRetorno  
	 	    			
/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튝etodo    쿎riarImp         튍utor  쿣endas Clientes     � Data �  05/05/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿝esponsavel em criar o objeto da impressora         	    	     볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                        		 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros쿐XPC1 (1 - cModelo) - Modelo do ecf selecionado.		   	         볍�
굇�			 쿐XPO1 (3 - oTotvsApi) - Objeto do tipo LJCTotvsApi.		         볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿙umerico														     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Method CriarImp(cModelo, oTotvsApi) Class LJCImpressora
   	
	Local nRet		:= 0			//Retorno do metodo
   	Local cClasse	:= "" 		    //Nome da classe da impressora
   	
   	Private oTot := oTotvsApi     //Variavel criada para execucao da macro
   	
   	//Busca o nome da classe responsavel
   	cClasse := oTot:oEcf:ElementKey(Upper(AllTrim(cModelo))):cClasse 
   	
   	//Instancia a classe por macro
    ::oEcf := &(cClasse + "():New(oTot)")
		
Return nRet

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튝etodo    쿟ratarRet        튍utor  쿣endas Clientes     � Data �  05/05/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿝esponsavel em tratar o retorno do ECF                   	    	 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                        		 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros쿐XPO1 (1 - oRetorno) - Objeto do tipo LJCRetornoEcf.	   	         볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿙umerico														     볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Method TratarRet(oRetorno) Class LJCImpressora
	
	Local oRet 		:= Nil                 	//Retorno do metodo, objeto do tipo LJCRetImpressora
	Local lRetorno 	:= .T.					//Utilizada para indicar se o comando foi executado		

	//Instancia o objeto LJCRetImpressora
	oRet := LJCRetImpressora():New()
	
	If oRetorno:cAcao == ALERTA
		::ExibirMsg(oRetorno:cCodigo + " - " + oRetorno:cMensagem)
	
	ElseIf oRetorno:cAcao == ERRO
		::ExibirMsg(oRetorno:cCodigo + " - " + oRetorno:cMensagem)
		lRetorno := .F.
	
	ElseIf oRetorno:cAcao == REPETIR
		::ExibirMsg(oRetorno:cCodigo + " - " + oRetorno:cMensagem)
	
	EndIf
	
	//Define se o comando foi executado com sucesso
	oRet:lRetorno := lRetorno
	//Atribui o valor do retorno
	oRet:oRetorno := oRetorno:oRetorno
			
Return oRet

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿣eriCupAbr튍utor  쿣endas Clientes     � Data �  06/03/08   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel em verifica se tem algum cupom vinculado 볍�
굇�          쿻ao fiscal ou gerencial aberto                   			  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros�															  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   �		 													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method VeriCupAbr() Class LJCImpressora

	Local oRetorno := Nil						//Retorno do metodo
			
	//Busca as flags fiscais
	oRetorno := ::oEcf:GetFlagsFi()	
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
    
    //Verifica se o comando foi executado
	If oRetorno:lRetorno
		If oRetorno:oRetorno:lCVAberto
			//Fecha o cupom vinculado aberto
			::FecharCNFV()
		ElseIf oRetorno:oRetorno:lNFAberto
			//Cancela cupom nao fiscal aberto
			::oEcf:CancCNF()
		ElseIf oRetorno:oRetorno:lRGAberto
			//Fecha o relatorio gerencial
			::oEcf:FecharRG()
		EndIf	
	EndIf

Return Nil

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튝etodo    쿐xibirMsg 튍utor  쿣endas Clientes     � Data �  12/09/07   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿝esponsavel em exibir a mensagem retorna pelo ECF.          볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿐xpC1 (1 - cMensagem) - Mensagem.				    		  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto                                                      볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method ExibirMsg(cMensagem) Class LJCImpressora
	
	Local oFrmMsgEcf 	:= Nil					//Objeto do tipo LJCFrmMensagemEcf
	Local cFabricante	:= ""					//Fabricante do ecf
	Local cModelo		:= ""					//Modelo do ecf
	Local cVerFirm		:= ""					//Versao do firmware
	Local oRetorno		:= Nil					//Retorno do ecf
	
	oRetorno := ::oEcf:GetFabric()
   	cFabricante := oRetorno:oRetorno
   	
   	oRetorno := ::oEcf:GetModelo()														
   	cModelo := oRetorno:oRetorno
   	
   	oRetorno := ::oEcf:GetVerFirm()	
	cVerFirm := oRetorno:oRetorno
	
	//Exibi a mensagem
	oFrmMsgEcf := LJCFrmMensagemEcf():New(cFabricante, cModelo, cVerFirm, cMensagem)
	//Grava log
	::oGlobal:GravarArq():Log():Ecf():Gravar(cMensagem) 
		
Return

/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튝etodo    쿒etTotPad 튍utor  쿣endas Clientes     � Data �  15/03/10   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿛ega totalizador padrao para ser usado caso                 볍�
굇�			 쿻ao esteja configurado no TOTVSAPI.INI.			          볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                        볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto                                                      볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method GetTotPad() Class LJCImpressora

	Local cTotPadrao  := "RECEBER"

Return cTotPadrao


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
굇�袴袴袴袴袴佶袴袴袴袴袴箇袴袴袴佶袴袴袴袴袴袴袴袴袴藁袴袴袴佶袴袴袴袴袴袴뺑�
굇튡rograma  쿏ownMF	 튍utor  쿣endas Clientes     � Data �  26/07/2014 볍�
굇勁袴袴袴袴曲袴袴袴袴袴菰袴袴袴賈袴袴袴袴袴袴袴袴袴袴姦袴袴賈袴袴袴袴袴袴攷굇
굇튒esc.     쿘etodo responsavel gerar o arquivo TipoE para PAF-ECF p/Data 볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튧so       쿞igaLoja / FrontLoja                                  	   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튡arametros쿐XPC1 (1 - cDatInicio) - Data inicial						   볍�
굇�			 쿐XPC2 (2 - cDatFim) - Data final							   볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴攷굇
굇튣etorno   쿚bjeto 													   볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴暠굇
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽
*/
Method DownMF() Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
	//Gera arquivo de registro tipo e
	oRetorno := ::oEcf:DownMF()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
    
Return oRetorno         



/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿝edZDado  튍utor  쿣endas Clientes     � Data �  26072014  볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel por retornar os dados capturados na  	  볍�
굇�          쿮xecucao do ultimo comando de ReducaoZ                      볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿙enhum													  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto 													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method RedZDado() Class LJCImpressora
	
	Local oRetorno  := Nil						//Retorno do metodo
		
	//Busca os dados da reducaoZ
	oRetorno := ::oEcf:RedZDado()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno 


/*
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇�袴袴袴袴袴佶袴袴袴袴藁袴袴袴錮袴袴袴袴袴袴袴袴袴袴箇袴袴錮袴袴袴袴袴袴敲굇
굇튡rograma  쿛egPathMFB튍utor  쿣endas Clientes     � Data �  26072014   볍�
굇勁袴袴袴袴曲袴袴袴袴袴姦袴袴袴鳩袴袴袴袴袴袴袴袴袴菰袴袴袴鳩袴袴袴袴袴袴묽�
굇튒esc.     쿘etodo responsavel por retornar os dados capturados na  	  볍�
굇�          쿮xecucao do ultimo comando de ReducaoZ                      볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튧so       쿞igaLoja / FrontLoja                                  	  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튡arametros쿙enhum													  볍�
굇勁袴袴袴袴曲袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴묽�
굇튣etorno   쿚bjeto 													  볍�
굇훤袴袴袴袴賈袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴선�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
*/
Method PegPathMFBin() Class LJCImpressora
Local oRetorno  := Nil						//Retorno do metodo
	
//Busca os dados da reducaoZ
oRetorno := ::oEcf:GetPathMFBin()
//Trata o retorno
oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

//--------------------------------------------------------
/*/{Protheus.doc} IdCliente
Abre o cupom fiscal
@param1		cCNPJ - Indica o cliente do cupom fiscal
@param2		cNome - Nome
@param3		cEnd - Endereco
@author  	Varejo
@version 	P11.8
@since   	28/04/2016
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample  	Nil
/*/
//--------------------------------------------------------
Method IdCliente(cCNPJ, cNome, cEnd) Class LJCImpressora
Local oRetorno  := Nil	//Retorno do metodo
Local cAuxEnd	:= ""
Local cAuxNom	:= ""

Default cCNPJ	:= ""
Default cNome	:= ""
Default cEnd	:= ""

cAuxEnd := StrTran(AllTrim(cEnd),",")
cAuxNom := StrTran(AllTrim(cNome),",")

oRetorno := ::oEcf:IdCliente(AllTrim(cCNPJ), cAuxNom, cAuxEnd)
oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno 

//--------------------------------------------------------
/*/{Protheus.doc} DownloadMFD
Download do arquivo MFD 
@param1		cBinario - gera bin�rio (SIM/NAO)
@param2		cTipo - string - tipo da pesquisa (Data/CRZ/COO/Total)
@param3		cInicio - string - periodo inicial 
@param4		cFinal - string - periodo final
@author  	Varejo
@version 	P12
@since   	19/03/2018
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample  	Nil
/*/
//--------------------------------------------------------
Method DownloadMFD(cBinario,cTipo,cInicio,cFinal) Class LJCImpressora
Local oRetorno  := Nil	//Retorno do metodo

Default cBinario:= ""
Default cTipo	:= ""
Default cInicio	:= ""
Default cFinal	:= ""

oRetorno := ::oEcf:DownloadMFD(cBinario,cTipo,cInicio,cFinal)
oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno 
