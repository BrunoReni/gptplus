#INCLUDE "MSOBJECT.CH" 
#INCLUDE "DEFECF.CH"                                                                                          

Function LOJA1300 ; Return  	// "dummy" function - Internal Use

//����������������������Ŀ
//�Informacoes Impressora�
//������������������������
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
#DEFINE _DATASW 				"29"		//Retorna a Data de instala��o da vers�o atual do Software B�sico gravada na Mem�ria Fiscal do ECF
#DEFINE _HORASW 				"30"		//Retorna o Hor�rio de instala��o da vers�o atual do Software B�sico gravada na Mem�ria Fiscal do ECF
#DEFINE _NUMECF 				"31"		//Retorna o N� de ordem seq�encial do ECF no estabelecimento usu�rio
#DEFINE _GRDTOTINI 				"32"		//Retorna o Grande Total Inicial
#DEFINE _GRDTOTFIM 				"33"		//Retorna o Grande Total Final
#DEFINE _VENDABRUT 				"34"		//Retorna a Venda Bruta Diaria
#DEFINE _CCF 					"35"		//Retorna o Contador de Cupom Fiscal CCF
#DEFINE _CNF 					"36"		//Retorna o Contador Geral de Opera��o N�o Fiscal
#DEFINE _CRG 					"37"		//Retorna o Contador Geral de Relat�rio Gerencial
#DEFINE _CCC 					"38"		//Retorna o Contador de Comprovante de Cr�dito ou D�bito
#DEFINE _DTHRULTCF 				"39"		//Retorna a Data e Hora do ultimo Documento Armazenado na MFD
#DEFINE _CODECF	 				"40"		//Retorna o Codigo da Impressora Referente a TABELA NACIONAL DE C�DIGOS DE IDENTIFICA��O DE ECF
#DEFINE _SUBTOT	 				"42"		//Retorna o Subtotal da venda na impressora Epson
#DEFINE _CODDLLECF	 			"45"		//Busca na DLL do Fabricante o Codigo da Impressora Referente a TABELA NACIONAL DE C�DIGOS DE IDENTIFICA��O DE ECF
#DEFINE _NOMEECF	 			"46"		//Busca na DLL do Fabricante o nome composto pela: Marca + Modelo + " - V. " + Vers�o do Firmware

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCImpressora    �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em se comunicar com as impressoras fiscais             ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
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
	Method RedZDado()															//Captura os Dados da Redu��o Z
	Method IdCliente(cCNPJ, cNome, cEnd)
	Method DownloadMFD(cBinario,cTipo,cInicio,cFinal)
EndClass

/*����������������������������������������������������������������������������������
���Metodo    �New   	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCImpressora.			    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
����������������������������������������������������������������������������������*/
Method New() Class LJCImpressora

	::oEcf		:= Nil
	::oGlobal	:= LJCGlobal():Global()    
	
Return Self

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �AbrirPorta       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em abrir a porta de comunicacao com o ECF.	    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cModelo) - Modelo do ecf selecionado.		   	         ���
���			 �EXPC2 (2 - cPorta) - Porta de comunicacao.  				         ���
���			 �EXPO3 (3 - oTotvsApi) - Objeto do tipo LJCTotvsApi.		         ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
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
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �LeituraX         �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em emitir uma leituraX                     	    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																     ���
��������������������������������������������������������������������������������͹��
���Retorno   �Numerico														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method LeituraX() Class LJCImpressora

	Local oRetorno := Nil						//Retorno do metodo
		
	//Emite leituraX
	oRetorno := ::oEcf:LeituraX() 
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    

Return oRetorno

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �AbrirDia         �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em emitir uma leituraX de inicio de dia      	    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																     ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
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
				Self:ExibirMsg("Redu��o Z Pendente!")
			EndIf
	    EndIf
	EndIf

Return oRetorno

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �InfoEcf          �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar um tipo de informacao do ecf      	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1- cTipo) - Tipo da informacao 						     ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
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
			//Retorna a Data de instala��o da vers�o atual do Software B�sico gravada na Mem�ria Fiscal do ECF
		    oRetorno := ::oEcf:GetDatSW()			

		Case cTipo == _HORASW
			//Retorna o Horario de instala��o da vers�o atual do Software B�sico gravada na Mem�ria Fiscal do ECF
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
			//Retorna o Contador Geral de Opera��o N�o Fiscal
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

			//Retorna o Codigo da Impressora Referente a TABELA NACIONAL DE C�DIGOS DE IDENTIFICA��O DE ECF
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
			//Busca na DLL do Fabricante o Codigo da Impressora Referente a TABELA NACIONAL DE C�DIGOS DE IDENTIFICA��O DE ECF	
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
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �Cupom            �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar o numero do cupom corrente      	    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																     ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method Cupom() Class LJCImpressora

	Local oRetorno := Nil						//Retorno do metodo
			
	//Busca o numero do cupom corrente
	oRetorno := ::oEcf:GetNumCup() 
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    

Return oRetorno

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �Formas           �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar as Formas do ecf           	    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																     ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method Formas() Class LJCImpressora

	Local oRetorno := Nil						//Retorno do metodo
			
	//Busca as aliquotas
	oRetorno := ::oEcf:GetFormas() 
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    

Return oRetorno




/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �Aliquotas        �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar as aliquotas do ecf           	    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																     ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method Aliquotas() Class LJCImpressora

	Local oRetorno := Nil						//Retorno do metodo
			
	//Busca as aliquotas
	oRetorno := ::oEcf:GetAliq() 
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    

Return oRetorno

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �NumeroEcf        �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar o numero do ecf	            	    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																     ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method NumeroEcf() Class LJCImpressora

	Local oRetorno := Nil						//Retorno do metodo
			
	//Busca as aliquotas
	oRetorno := ::oEcf:GetNumEcf() 
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    

Return oRetorno

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �FechaPorta       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em fechar a porta de comunicacao com o ECF.	    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cPorta) - Porta de comunicacao.  				         ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method FechaPorta(cPorta) Class LJCImpressora
	
	Local oRetorno := Nil						//Retorno do metodo
				
	//Fecha a porta serial
	oRetorno := ::oEcf:FechaPorta(cPorta)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
			
Return oRetorno

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �NumSerie         �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar o numero de serie.				    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method NumSerie() Class LJCImpressora
	
	Local oRetorno := Nil						//Retorno do metodo
				
	//Busca o numero de serie
	oRetorno := ::oEcf:GetNrSerie()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
			
Return oRetorno

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �AbrirCF          �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em abrir o cupom fiscal						    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - ccCnpj) - Cnpj/Cpf do cliente.				   	         ���
���			 �EXPC2 (2 - cCliente) - Nome do cliente.    				         ���
���			 �EXPO3 (3 - cEndereco) - Endereco do cliente.				         ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
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
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �CancelaCF        �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em cancelar o cupom fiscal						     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method CancelaCF() Class LJCImpressora
	
	Local oRetorno := Nil						//Retorno do metodo
			 			
	//Cancela o cupom
	oRetorno := ::oEcf:CancelaCF()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �VenderItem�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela venda de um item no cupom fiscal    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cCodigo) - Codigo do item vendido.			   	  ���
���			 �EXPC2 (2 - cDescricao) - Descricao do item.  				  ���
���			 �EXPC3 (3 - cTribut) - Tipo da tributacao.					  ���
���			 �EXPN1 (4 - nAliquota) - Aliquota do item.			   	  	  ���
���			 �EXPN2 (5 - nQtde) - Quantidade do item vendido.	 	  	  ���
���			 �EXPN3 (6 - nVlUnit) - Valor unitario do item.			   	  ���
���			 �EXPN4 (7 - nDesconto) - Valor do desconto do item.		  ���
���			 �EXPC4 (8 - cComplemen) - Complemento da descricao.    	  ���
���			 �EXPC5 (9 - cUniMed) - Unidade de medida do item.			  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto													  ���
���������������������������������������������������������������������������*/
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DescItem  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo desconto em um item do cupom fiscal ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPN1 (1 - nValor) - Valor do desconto.			   	  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                   
Method DescItem(nValor) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Desconto no item
	oRetorno := ::oEcf:DescItem(nValor)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NumeroItem�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o numero do ultimo item 	  ���
���          �vendido pelo ECF.                                           ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method NumeroItem() Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Numero de itens no cupom
	oRetorno := ::oEcf:GetNumItem()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SubTotal  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o subtotal da venda    	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method SubTotal() Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Retorna o subtotal
	oRetorno := ::oEcf:GetSubTot()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Pagamento �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em efetuar o pagamento no cupom fiscal   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cForma) - Forma de pagamento.			   	  	  ���
���Parametros�EXPN1 (1 - nValor) - Valor do pagamento.			   	  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/       
Method Pagamento(cForma, nValor) Class LJCImpressora
	
	Local oRetorno  := Nil						//Retorno do metodo
		
	//Efetua o pagamento no ecf
	oRetorno := ::oEcf:EfetuaPgto(cForma, nValor)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FecharCF  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em fechar o cupom fiscal   			  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oMensagem) - Mensagem promocional.		   	  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/       
Method FecharCF(oMensagem) Class LJCImpressora
	
	Local oRetorno  := Nil						//Retorno do metodo
		
	//Efetua o fechamento do cupom fiscal
	oRetorno := ::oEcf:FecharCF(oMensagem)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AbrirGavet�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em abrir a gaveta           			  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�													   	  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/       
Method AbrirGavet() Class LJCImpressora
	
	Local oRetorno  := Nil						//Retorno do metodo
		
	//Efetua a abertura da gaveta
	oRetorno := ::oEcf:AbrirGavet()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CancItem  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo cancelamento item no cupom fiscal   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cItem) - Numero do item vendido.			   	  ���
���			 �EXPC2 (2 - cCodigo) - Codigo do item vendido.				  ���
���			 �EXPC3 (3 - cDescricao) - Descricao do item.  				  ���
���			 �EXPC4 (4 - cTribut) - N/A.		  						  ���
���			 �EXPN1 (5 - nAliquota) - Aliquota do item.			   	  	  ���
���			 �EXPN2 (6 - nQtde) - Quantidade do item vendido.	 	  	  ���
���			 �EXPN3 (7 - nVlUnit) - Valor unitario do item.			   	  ���
���			 �EXPN4 (8 - nDesconto) - Valor do desconto do item.		  ���
���			 �EXPC9 (9 - cUniMed) - Unidade de medida do item.			  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DescTotal �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo desconto no subtotal do cupom fiscal���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPN1 (1 - nValor) - Valor do desconto.			   	  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method DescTotal(nValor) Class LJCImpressora
    
	Local oRetorno  := Nil						//Retorno do metodo
		
	//Efetua o desconto no total do cupom
	oRetorno := ::oEcf:DescTotal(nValor)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
		
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AcresItem �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo acrescimo em um item do  			  ���
���          �cupom fiscal                                                ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPN1 (1 - nValor) - Valor do acrescimo.			   	  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AcresItem(nValor) Class LJCImpressora
	
	Local oRetorno  := Nil						//Retorno do metodo
		
	//Efetua o acrescimo no item
	oRetorno := ::oEcf:AcresItem(nValor)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
		
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AcresTotal�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo acrescimo no subtotal do cupom	  ���
���          �fiscal                                                	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPN1 (1 - nValor) - Valor do acrescimo.			   	  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AcresTotal(nValor) Class LJCImpressora
    
	Local oRetorno  := Nil						//Retorno do metodo
		
	//Efetua o acrescimo no total do cupom
	oRetorno := ::oEcf:AcresTotal(nValor)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Sangria   �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a Sangria  				  ���
���          �		                                        			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oFormas) - LJCFORMASECF com as fomas de pagamento���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Suprimento�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar o Fundo de Troco.			  ���
���          �		                                        			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oFormas) - LJCFORMASECF com as fomas de pagamento���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �ConfVerao  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
��������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em efetuar a saida/entrada do horario do  ���
���          �verao	                                        			   ���
��������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	   ���
��������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cTipo) - E(Entrada) / S(Saida).				   ���
��������������������������������������������������������������������������͹��
���Retorno   �Objeto 													   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Method ConfVerao(cTipo) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Efetua a saida/entrada do horario de verao
	oRetorno := ::oEcf:ConfVerao(cTipo)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReducaoZ  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a Reducao Z.	  			  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ReducaoZ() Class LJCImpressora
	
	Local oRetorno  := Nil						//Retorno do metodo
		
	//Efetua a reducaoZ
	oRetorno := ::oEcf:ReducaoZ()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DadosRedZ �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar os dados capturados na  	  ���
���          �execucao do ultimo comando de ReducaoZ                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method DadosRedZ() Class LJCImpressora
	
	Local oRetorno  := Nil						//Retorno do metodo
		
	//Busca os dados da reducaoZ
	oRetorno := ::oEcf:GetDadRedZ()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MFData    �Autor  �Vendas Clientes     � Data �  22/07/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a impressao da Leitura da    ���
���          �Memoria Fiscal por Data.                                    ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPD1 (1 - dDtInicio) - Data inicial do periodo (ddmmaaaa). ���
���			 �EXPD2 (2 - dDtFim) - Data final do periodo (ddmmaaaa).	  ���
���          �EXPC1 (3 - cTipo) - Tipo da Leitura						  ���
���			 �					  (I - impressao / A - arquivo).		  ���
���			 �EXPC2 (4 - cTipoArq) - (C - completa / S - simplificada).	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MFReducao �Autor  �Vendas Clientes     � Data �  22/07/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a impressao da Leitura da    ���
���          �Memoria Fiscal por Reducao Z.	                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cRedInicio) - Reducao Z inicial do periodo. 	  ���
���			 �EXPC2 (2 - cRedFim) - Reducao Z final do periodo.			  ���
���          �EXPC3 (3 - cTipo) - Tipo da Leitura						  ���
���			 �					  (I- impressao / A - arquivo).			  ���
���			 �EXPC4 (4 - cTipoArq) - (C - completa / S - simplificada).	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MFDData   �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel gerar a Leitura da fita detalhe por data ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPD1 (1 - dDtInicio) - Data inicial do periodo (ddmmaaaa). ���
���			 �EXPD2 (2 - dDtFim) - Data final do periodo (ddmmaaaa).	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method MFDData(dDtInicio, dDtFim) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Leitura da memoria fita detalhe
	oRetorno := ::oEcf:MFDData(dDtInicio, dDtFim)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MFDCoo    �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel gerar a Leitura da fita detalhe por Coo  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cCooInicio) - Coo inicial						  ���
���			 �EXPC2 (2 - cCooFim) - Coo final							  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method MFDCoo(cCooInicio, cCooFim) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Leitura da memoria fita detalhe
	oRetorno := ::oEcf:MFDCoo(cCooInicio, cCooFim)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
    
Return oRetorno

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �TipoEData	 �Autor  �Vendas Clientes     � Data �  21/07/10   ���
��������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel gerar o arquivo TipoE para PAF-ECF p/Data ���
��������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	   ���
��������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cDatInicio) - Data inicial						   ���
���			 �EXPC2 (2 - cDatFim) - Data final							   ���
��������������������������������������������������������������������������͹��
���Retorno   �Objeto 													   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �TipoECrz	 �Autor  �Vendas Clientes     � Data �  21/07/10   ���
��������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel gerar o arquivo TipoE para PAF-ECF p/Crz  ���
��������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	   ���
��������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cCrzInicio) - Crz inicial						   ���
���			 �EXPC2 (2 - cCrzFim) - Crz final							   ���
��������������������������������������������������������������������������͹��
���Retorno   �Objeto 													   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConfigAliq�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a inclusao de uma aliquota.  ���
���          �								                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPN1 (1 - nAliq) - Valor da aliquota.			  		  ���
���			 �EXPC1 (2 - cTipoIss) - Flag que indica se a aliquota sera   ���
���			 �		referente a ISS (S - Sim, N - Nao ).		  		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfigAliq(nAliq, cTipoIss) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Configura a aliquota no ecf
	oRetorno := ::oEcf:ConfigAliq(nAliq, cTipoIss)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
    
Return oRetorno    


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConfTotNF �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a inclusao do totalizador    ���
���          �Nao Fiscal     				                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPN1 (1 - cNum  ) - Numero do Totalizador.		  		  ���
���			 �EXPC1 (2 - cDescr) - Descricao                              ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConfTotNF �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a inclusao do totalizador    ���
���          �forma de pagamento     		                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPN1 (1 - cDescr  ) - cDescr             .		  		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AbrirCNFV �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em abrir um cupom vinculado.  			  ���
���          �								                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPN1 (1 - nValor) - Valor do documento.			  		  ���
���			 �EXPC1 (2 - cForma) - Forma de pagamento.					  ���
���			 �EXPC2 (3 - cTotaliz) - Totalizador nao fiscal.			  ���
���			 �EXPC3 (4 - cTotOrig) - Totalizador original	.			  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AbrirCNFV(nValor, cForma, cTotaliz, cTotOrig) Class LJCImpressora
	
	Local oRetorno  	:= Nil						//Retorno do metodo
	Local cTotalizIni 	:= ""						//Totalizador fiscal da recarga de celular
	Local lNaoFiscal	:= .F.						//Se ira imprimir um comprovante nao fiscal
	Local lSFinanc   	:= AliasIndic("MG8") .AND. SuperGetMV("MV_LJCSF",, .F.)	// Valida implementa��o do Servico Financeiro
	
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FecharCNFV�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo fechamento de um cupom nao fiscal   ���
���          �vinculado													  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method FecharCNFV() Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Fecha o cupom nao fiscal vinculado
	oRetorno := ::oEcf:FecharCNFV()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpTxtNF  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pel impressao de linhas nao fiscais   	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oRelatorio) - Linhas nao fiscais.				  ���
���			 �ExpL1 (2 - lLinha) - Se vai ser impresso linha a linha.	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ImpTxtNF(oRelatorio, lLinha) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Imprimi linha no cupom nao fiscal
	oRetorno := ::oEcf:ImpTxtNF(oRelatorio, lLinha)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpCodigoBarras �Autor  �Vendas Clientes  � Data � 06/03/08 ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela impressao de codigo de barras       ���
���          �		                                        			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cRelatorio) - Nome do relatorio.  				  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ImpCodigoBarras( cCodBarras ) Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
		
	//Imprimi linha no cupom nao fiscal
	oRetorno := ::oEcf:ImpCodigoBarras( cCodBarras )
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �Totaliz          �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em retornar os totalizadores nao fiscais do ecf    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																     ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method Totaliz() Class LJCImpressora

	Local oRetorno := Nil						//Retorno do metodo
			
	//Busca os totalizadores nao fiscais
	oRetorno := ::oEcf:GetTotNf() 
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpRelGer �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura de um relatorio gerencial  ���
���          �		                                        			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oRelatorio) - Linhas nao fiscais. 				  ���
���			 �EXPC1 (2 - cRelatorio) - Nome do relatorio.  				  ���
���			 �EXPL1 (3 - lLinha) - Se vai ser impresso linha a linha.	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpCodBar �Autor  �Vendas Clientes     � Data �  14/11/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura de um relatorio gerencial  ���
���          �contendo um codigo de barras                   			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oRelatorio) - Linhas nao fiscais. 				  ���
���			 �EXPC1 (2 - cRelatorio) - Nome do relatorio.  				  ���
���			 �EXPL1 (3 - lLinha) - Se vai ser impresso linha a linha.	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Autenticar�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a autenticacao.			  ���
���          �								                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cTexto) - Texto a ser impresso na autenticacao.  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Autenticar(cTexto) Class LJCImpressora

	Local oRetorno := Nil						//Retorno do metodo
			
	//Autentica o documento
	oRetorno := ::oEcf:Autenticar(cTexto) 
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpCheque �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a impressao de cheque.		  ���
���          �								                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cBanco) - Numero do banco.						  ���
���			 �EXPC2 (2 - nValor) - Valor do cheque.						  ���
���			 �EXPC3 (3 - cData) - Data do cheque (ddmmaaaa).		 	  ���
���			 �EXPC4 (4 - cFavorecid) - Nome do favorecido.			   	  ���
���			 �EXPC5 (5 - cCidade) - Cidade a ser impressa no cheque.	  ���
���			 �EXPC6 (6 - cTexto) - Texto adicional impresso no cheque.    ���
���			 �EXPC7 (7 - cExtenso) - Valor do cheque por extenso.	  	  ���
���			 �EXPC8 (8 - cMoedaS) - Moeda por extenso no singular.	  	  ���
���			 �EXPC9 (9 - cMoedaP) - Moeda por extenso no plural.		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeCMC7	�Autor  �Vendas Clientes     � Data �  11/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a leitura do CMC7.			  ���
���          �								                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeCMC7() Class LJCImpressora

	Local oRetorno := Nil						//Retorno do metodo
			
	//Le o CMC7
	oRetorno := ::oEcf:LeCMC7() 
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    
    
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �AbrirCNF  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em abrir um cupom nao fiscal. 			  ���
���          �								                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPN1 (1 - nValor) - Valor do documento.			  		  ���
���			 �EXPC1 (2 - cForma) - Forma de pagamento.					  ���
���			 �EXPC2 (3 - cTotaliz) - Totalizador nao fiscal.			  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto													  ���
���������������������������������������������������������������������������*/
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

/*���������������������������������������������������������������������������
���Programa  �EstNFiscVinc�Autor  �Vendas Clientes     � Data �  13/03/14 ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em abrir um cupom nao fiscal. 			  ���
���          �								                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPN1 (1 - cCPFCNPJ) - CPF/CNPJ do cliente		  		  ���
���			 �EXPC2 (2 - cCliente) - Nome do Cliente					  ���
���			 �EXPC3 (3 - cEndereco) - Endere�o do cliente			      ���
���			 �EXPC4 (4 - cMensagem) - Mensagem para o cupom de cancelamnto���
���			 �EXPC5 (5 - cCOOCCD) - COO do Comprovante de Credito e Debito���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto													  ���
���������������������������������������������������������������������������*/
Method EstNFiscVinc(cCPFCNPJ,cCliente,cEndereco,cMensagem,cCOOCCD) Class LJCImpressora
Local oRetorno  := Nil						//Retorno do metodo
		           
//Abre o cupom nao fiscal
oRetorno := ::oEcf:EstNFiscVinc(cCPFCNPJ,cCliente,cEndereco,cMensagem,cCOOCCD)

//Trata o retorno
oRetorno := ::TratarRet(oRetorno)
        
Return oRetorno
	    			
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpPedido �Autor  �Vendas Clientes     � Data �  09/12/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em imprimir o pedido.		 			  ���
���          �								                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cTef) - Valor do documento.			  		  ���
���			 �EXPO1 (2 - oRelatorio) - Relatorio a ser impresso.		  ���
���			 �EXPN1 (3 - nValor) - Valor do cupom nao fiscal.			  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PegPathMFD�Autor  �Vendas Clientes     � Data �  10/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o caminho e nome do arquivo de Memoria Fita Detalhe.���
���          �								                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method PegPathMFD() Class LJCImpressora	 

	Local oRetorno := Nil						//Retorno do metodo
			
	//Busca o path e nome do arquivo de Memoria Fita Detalhe
	oRetorno := ::oEcf:GetPathMFD() 
	
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    

Return oRetorno     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PegPathMF �Autor  �Vendas Clientes     � Data �  10/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o caminho e nome do arquivo de Memoria Fiscal.	  ���
���          �								                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method PegPathMF() Class LJCImpressora	 

	Local oRetorno := Nil						//Retorno do metodo
			
	//Busca o path e nome do arquivo de Memoria Fita Detalhe
	oRetorno := ::oEcf:GetPathMF() 
	
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    

Return oRetorno
	    			
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �PegPathTipoE�Autor  �Vendas Clientes     � Data �  21/07/10   ���
���������������������������������������������������������������������������͹��
���Desc.     �Retorna o caminho e nome do arquivo registro Tipo E			���
���          �Ato Cotepe 17/04 PAF-ECF.		                              	���
���������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	���
���������������������������������������������������������������������������͹��
���Retorno   �Objeto													  	���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Method PegPathTipoE() Class LJCImpressora	 

	Local oRetorno := Nil						//Retorno do metodo
			
	//Busca o path e nome do arquivo registro Tipo E Ato Cotepe 17/04 PAF-ECF.
	oRetorno := ::oEcf:GetPathTipoE() 
	
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)    

Return oRetorno  
	 	    			
/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �CriarImp         �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em criar o objeto da impressora         	    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cModelo) - Modelo do ecf selecionado.		   	         ���
���			 �EXPO1 (3 - oTotvsApi) - Objeto do tipo LJCTotvsApi.		         ���
��������������������������������������������������������������������������������͹��
���Retorno   �Numerico														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
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
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �TratarRet        �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em tratar o retorno do ECF                   	    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oRetorno) - Objeto do tipo LJCRetornoEcf.	   	         ���
��������������������������������������������������������������������������������͹��
���Retorno   �Numerico														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VeriCupAbr�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em verifica se tem algum cupom vinculado ���
���          �nao fiscal ou gerencial aberto                   			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �		 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ExibirMsg �Autor  �Vendas Clientes     � Data �  12/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em exibir a mensagem retorna pelo ECF.          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cMensagem) - Mensagem.				    		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetTotPad �Autor  �Vendas Clientes     � Data �  15/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Pega totalizador padrao para ser usado caso                 ���
���			 �nao esteja configurado no TOTVSAPI.INI.			          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetTotPad() Class LJCImpressora

	Local cTotPadrao  := "RECEBER"

Return cTotPadrao


/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �DownMF	 �Autor  �Vendas Clientes     � Data �  26/07/2014 ���
��������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel gerar o arquivo TipoE para PAF-ECF p/Data ���
��������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	   ���
��������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cDatInicio) - Data inicial						   ���
���			 �EXPC2 (2 - cDatFim) - Data final							   ���
��������������������������������������������������������������������������͹��
���Retorno   �Objeto 													   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Method DownMF() Class LJCImpressora

	Local oRetorno  := Nil						//Retorno do metodo
	//Gera arquivo de registro tipo e
	oRetorno := ::oEcf:DownMF()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
    
Return oRetorno         



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RedZDado  �Autor  �Vendas Clientes     � Data �  26072014  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar os dados capturados na  	  ���
���          �execucao do ultimo comando de ReducaoZ                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method RedZDado() Class LJCImpressora
	
	Local oRetorno  := Nil						//Retorno do metodo
		
	//Busca os dados da reducaoZ
	oRetorno := ::oEcf:RedZDado()
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PegPathMFB�Autor  �Vendas Clientes     � Data �  26072014   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar os dados capturados na  	  ���
���          �execucao do ultimo comando de ReducaoZ                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
