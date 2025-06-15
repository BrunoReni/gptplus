#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFECF.CH"
#INCLUDE "AUTODEF.CH"
 
#DEFINE _BYTESLINHANF  492	
                                                                                                              
Function LOJA1336 ; Return  // "dummy" function - Internal Use                                                
                                                                                               
/*                                                                                              
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJAIBM           �Autor  �Vendas Clientes     � Data �  20/06/11   ���              
��������������������������������������������������������������������������������͹��
���Desc.     �Classe abstrata, possui as funcoes comuns para todos os ECF'S do   ���
���			 �modelo IBM													     ���
��������������������������������������������������������������������������������͹��                              
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/                                            
Class LJAIBM From LJAEcf                                    
	
	Data oFormasVen																//Formas da venda, objeto do tipo LJCFormasEcf
		                                                    
	Method New(oTotvsApi)														//Metodo construtor   
	
	//Metodos da interface
	Method AbrirPorta(cPorta)							   						//Abre a porta serial para comunicacao com o ECF  
	Method FechaPorta(cPorta)								  					//Fechar a porta serial
	
	//Operacoes Fiscais
	Method AbrirCF(cCnpj, cCliente, cEndereco)							 		//Abri o cupom fiscal
	Method CancelaCF()															//Cancela o cupom fiscal 
	Method VenderItem(cCodigo	, cDescricao, cTribut	, nAliquota	, ;
							nQtde	, nVlUnit	, nDesconto	, cComplemen, ;
	    					cUniMed)											//Vende item no ecf
	Method CancItem(cItem		, cCodigo	, cDescricao, cTribut	, ;
					nAliquota	, nQtde		, nVlUnit	, nDesconto	, ;
	    			cUniMed)													//Cancela item no ecf
	Method DescItem(nValor)														//Aplica desconto no item do cupom
	Method DescTotal(nValor)													//Aplica desconto no total do cupom
	Method AcresItem(nValor)													//Aplica acrescimo no item do cupom
	Method AcresTotal(nValor)													//Aplica acrescimo no total do cupom
    Method IniFecha()															//Subtotaliza o cupom fiscal, permite acrescimo e desconto no mesmo
	Method EfetuaPgto(cForma, nValor)											//Efetua pagamento
	Method FecharCF(oMsgPromo)													//Fechar cupom fiscal    
	Method TotalizaCF()															//Totaliza o cupom   
	
	//Operacoes nao fiscais
	Method AbrirCNFV(cForma, nValor)											//Abre cupom nao fiscal vinculado
	Method FecharCNFV()															//Fecha cupom nao fiscal vinculado
	Method CancCNFV(cCupom, cForma, nValor)										//Cancela cupom nao fiscal vinculado	
	Method AbrirCNF(cCnpj, cCliente, cEndereco, cTotaliz, nValor)			    //Abre cupom nao fiscal
	Method FecharCNF()															//Fecha cupom nao fiscal
	Method PgtoCNF(cForma, nValor)												//Efetua pagamento nao fiscal
	Method CancCNF()															//Cancela cupom nao fiscal
	Method AbrirRG(cRelatorio)													//Abri relatorio gerencial
	Method UsarRG(cTexto)														//Usa o relatorio gerencial
	Method FecharRG()															//Fecha relatorio gerencial   
	Method ConfPGNF(nIndice, cDescr)											//Configura forma de pagamento nao fiscal
	Method ImpTxtNF(oRelatorio, lLinha)											//Imprime texto em cupom nao fiscal  
	Method TxtLivre(cTexto)														//Imprime texto livre
	Method Sangria(oFormas, cTotaliz)								   			//Efetua sangria de caixa
	Method Suprimento(oFormas, cTotaliz)   										//Efetua suprimentro de caixa (entrada de troco)
	Method ConfCodBar(nAltura, nLargura, nPosicao, nFonte, nMargem)		        //Configura o codigo de barras
	Method CodBarras(cString)													//Imprime o codigo de barras 
	Method Teste(cTotaliz, cForma, nValor)
	Method EstNFiscVinc(cCPFCNPJ,cCliente,cEndereco,cMensagem,cCOOCCD)			//Efetua o estorno do comprovante de credito e debito
			
	//Relatorios fiscais
	Method LeituraX()															//Emite uma leituraX
	Method ReducaoZ()															//Emite uma Reducao Z
	Method AbrirDia()															//Emite Abertura Dia de inicio de dia
  	Method MFData(dDtInicio, dDtFim, cTipo, cTipoArq)							//Leitura da memoria fiscal por data
	Method MFReducao(cRedInicio, cRedFim, cTipo, cTipoArq)						//Leitura da memoria fiscal por reducao
    Method MFDData(dDtInicio, dDtFim)											//Leitura da memoria fita detalhe por data
    Method MFDCoo(cCooInicio, cCooFim)											//Leitura da memoria fita detalhe por Coo  
    Method ConvArq(cArqOri, cArqDes, cTpDado, cTprel, cPar1, ;
   					cPar2, cUser) 												//Converte o arquivo MFD
    Method TipoEData(cDatInicio, cDatFim,cPathArq,cBinario)										//Gerar arq. Tipo E Ato Cotepe 17/04 PAF-ECF por Data
	Method TipoECrz(cCrzInicio, cCrzFim, cBinario)										//Gerar arq. Tipo E Ato Cotepe 17/04 PAF-ECF por Crz
    
    //Autenticacao e cheque
	Method Autenticar(cLinha, cTexto)											//Autentica documento / cheque
	Method ImpCheque(cBanco	, cValor, cData 	, cFavorecid 	, ;
					 cCidade, cTexto, cExtenso	, cMoedaS 		, ;
					 cMoedaP)													//Imprime cheque 
					 
	Method LeCMC7() 				                                            //Executa a leitura do c�digo CMC7
	Method DownMF()															//DownLoad da Mem�ria Fiscal
	Method RedZDado()															//Dados da redu��o Z
	   					
	//Configuracoes
	Method ConfigPgto(cForma, cOper)											//Configura forma de pgto
	Method ConfTotNF(cIndice, cTotaliz)							   					//Configura totalizador nao fiscal	
	Method ConfigAliq(nAliq, cTipoIss)											//Configura aliquota		
	Method ConfVerao(cTipo)												   		//Configura a impressora para entrada / saida do horario de verao
	Method ConfRelGer(cIndice, cRelGer)											//Configura relatario gerencial
	
	//Gaveta
	Method AbrirGavet()															//Abre a gaveta
	
	//Informacoes ECF
	Method GetFabric()															//Retorna o fabricante do ecf 
    Method GetModelo()															//Retorna o modelo do ecf
    Method GetVerFirm()															//Retorna a versao do firmeware
    Method GetCNPJ()															//Retorna o CNPJ
    Method GetInsEst()														  	//Retorna a inscricao estadual
    Method GetInsMun()															//Retorna a inscricao municipal
	Method GetNumLj()															//Retorna o numero da loja
	Method GetOper()															//Retorna o operador	
	Method GetRzSoc()															//Retorna a razao social
    Method GetFantas()															//Retorna o nome fantasia
    Method GetEnd1()															//Retorna o endereco 1
  	Method GetEnd2()															//Retorna o endereco 2
    Method GetDadRedZ()															//Retorna os dados da reducao
	Method GetMFTXT()															//Retorna se a impressora gera memoria fiscal em txt    
    Method GetMFSerial()														//Retorna se a impressora gera memoria fiscal serial    
    Method GetHrVerao()														  	//Retorna se a impresora esta em horario de verao
	Method GetAliq()													  		//Retorna as aliquotas cadastradas
	Method GetFormas()															//Retorna as formas cadastradas	
	Method GetTotNF()															//Retorna os totalizadores nao fiscais cadastrados
	Method GetRelGer()														  	//Retorna os relatorios gerenciais cadastrados
	Method GetNrSerie()															//Retorna o numero de serie
	Method GetNumCup()															//Retorna o numero do cupom
	Method GetNumEcf()															//Retorna o numero do ECF
	Method GetNumItem()															//Retorna a qtde de itens impressos no cupom fiscal
	Method GetSubTot()															//Retorna o SubTotal
	Method GetDatHora()															//Retorna a data e hora
	Method GetDesItem()															//Retorna se o ecf permite desconto no item
	Method GetImpFisc()															//Retorna se eh uma impressora fiscal
	Method GetTrunAre()															//Retorna se o ecf trunca ou arredonda
	Method GetChqExt()															//Retorna se o cheque necessita do extenso
	Method GetVdBruta()															//Retorna a venda bruta
	Method GetGranTot()															//Retorna o grande total
    Method GetTotDesc()															//Retorna o valor total de desconto	
  	Method GetDescIss()															//Retorna o valor total de desconto	ISS
    Method GetTotAcre()															//Retorna o valor total de acrescimos
    Method GetAcreIss()															//Retorna o valor total de acrescimos ISS
    Method GetTotCanc()															//Retorna o valor total de cancelados
	Method GetCancIss()															//Retorna o valor total de cancelados ISS
    Method GetIsentos()															//Retorna o valor de isentos
    Method GetNaoTrib()															//Retorna o valor de nao tributados
    Method GetSubstit()															//Retorna o valor de substituidos
    Method GetNumRedZ()															//Retorna o numero de reducoes
    Method GetCancela()															//Retorna o numero de documentos cancelados
	Method GetInterve()															//Retorna o numero de intervencoes CRO
	Method GetDtUltRe()															//Retorna a data da ultima reducao
	Method GetTotIss()															//Retorna o valor total de ISS
	Method GetDataMov()															//Retorna a data do movimento	
	Method GetFlagsFi()															//Retorna as flags fiscais
    Method GetCancIt()															//Retorna se pode cancelar todos os itens
    Method GetVlSupr()														  	//Retorna o valor de suprimento
    Method GetItImp()															//Retorna se todos os itens foram impressos
    Method GetPosFunc()														  	//Se o ecf retorna o Subtotal e o numero de itens impressos no cupom fiscal.
    Method GetPathMFD()                                                         //Retorna o caminho e nome do arquivo de Memoria Fita Detalhe   
    Method GetLetMem()															//Retorna a letra indicativa de MF adicional
    Method GetTipEcf()															//Retorna Tipo de ECF
    Method GetDatSW()		 													//Retorna a Data de instalacao da versao atual do Software B�sico gravada na Memoria Fiscal do ECF
	Method GetHorSW()			                                                //Retorna o Horario de instalacao da versao atual do Software B�sico gravada na Memoria Fiscal do ECF
	Method GetGrTIni()															//Retorna o Grande total incicial			
	Method GetNumCnf()															//Retorna o Contador Geral de Opera��o N�o Fiscal
	Method GetNumCrg() 															//Retorna o Contador Geral de Relat�rio Gerencial
	Method GetNumCcc()															//Retorna o Contador de Comprovante de Cr�dito ou D�bito 
	Method GetDtUDoc()															//Retorna a Data e Hora do ultimo Documento Armazenado na MFD
    Method GetCodEcf() 															//Retorna o Codigo da Impressora Referente a TABELA NACIONAL DE C�DIGOS DE IDENTIFICA��O DE ECF
    Method GetPathMF()                                                          //Retorna o caminho e nome do arquivo de Memoria Fiscal
    Method GetPathMFBin()                                                          //Retorna o caminho e nome do arquivo de Memoria Fiscal Bin�rio
   	Method GetPathTipoE(cBinario)														//Retorna o caminho e nome do arquivo de registro Tipo E Ato Cotepe 17/04 PAF-ECF
    Method BuscInfEcf()															//Busca as informacoes para o funcionamento do sistema (aliquotas, formas de pagto, numero serie, etc...) 
                                        										
	//Metodos internos                                                                              
	Method ObterEst(cRetorno)							//Obtem o status de execucao do ultimo comando
	Method CarregMsg()									//Carrega as mensagens de retorno do ecf	
	Method LeDadoUsu()									//Carrega o C.N.P.J e I.E
	Method LeModelo()                                   //Carrega o Modelo do ECF
	Method LeFrmWare()                                  //Carrega o Firmware do ECF
	Method LeInscMun()                                  //Carrega a I.M.
	Method LeDadImp()									//Carrega o N�mero de S�rie e Fabricante do ECF
	Method LeCliche()                                 	//Carrega a Razao Social, Nome Fantasia, Endereco 1 & Endereco 2
	Method LeOperador()									//Carrega o nome do Operador - NAO TEM FUNCAO IBM      
	Method LeNumLoja()									//Carrega o numero da Loja
	Method LeECFLoja()									//Carrega o numero do ECF
	Method LeAliq()										//Carrega as aliquotas cadastradas no ECF
	Method LeTotNF()									//Carrega os Totalizadores Nao Fiscais cadastrados no ECF
	Method LeRelGer()									//Carrega os Relatorios Gerenciais cadastrados no ECF
	Method LeFinaliz()									//Carrega as Formas de Pagamento cadastradas no ECF
	Method LeDataJor()								 	//Le a data e hora de abertura da jornada
	Method LeGT()										//Le o Grand Total da impressora
	Method LeCOO()									 	//Le o coo do ultimo documento impresso pela impressora
	Method LeTotCanc()									//Le o total cancelado durante a jornada
	Method LeTotCanISS()									//Le o total de cancelado para ISS
	Method LeTotDesc()								  	//Le o total de desconto durante a jornada
	Method LeTotDesISS()									//Le o total de desconto para ISS
 	Method LeTotIsent()								  	//Le o total isento durante a jornada
  	Method LeTotNTrib()									//Le o total nao tributado durante a jornada
    Method LeTotIss()									//Le o total de ISS durante a jornada
	Method LeVndLiq()									//Le o total de venda liquida durante a jornada
	Method LeVndBrut()									//Le o total de venda bruta durante a jornada		
	Method LeFaseCP() 		  							//Le a fase do cupom fiscal em andamento
	Method LeDadJorn()									//Le os dados da jornada									
	Method LeCupIni()									//Le o cupom inicial do dia
	Method HexToDec(cHex)                               //Converte hexa para decimal
	Method BuscaAliq(cTribut, nAliquota)				//Busca a aliquota para ser enviada a impressora  
 	Method InicVar()									//Inicializando variaveis
    Method GuardarPgt(cForma, nValor)					//Guarda as formas da venda 
    Method TratParam(cRetorno)								//Metodo que tira caracteres dos parametros      
    Method CorrigRet(cRetorno)                              //Metodo que corrige o retorno
	Method TrataTags( cMensagem )							//Trata as tags enviadas para a mensagem promocional
    Method GetCodDllECF()										//Busca na DLL do Fabricante o Codigo da Impressora Referente a TABELA NACIONAL DE C�DIGOS DE IDENTIFICA��O DE ECF
	Method GetNomeECF()										//Busca na DLL do Fabricante o nome composto pela: Marca + Modelo + " - V. " + Vers�o do Firmware                                                                                                              
	Method IdCliente(cCNPJ, cNome, cEnd)
EndClass

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �New   	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJAIBM.     			    	     ���
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
Method New(oTotvsApi) Class LJAIBM                                                         
   
	//Executa o metodo construtor da classe pai
	_Super:New(oTotvsApi)
	
	//Inicializando variaveis
    ::oFormasVen := Nil  
    ::cPathMFD   := "C:\RELMFD.TXT" 
    ::cPathMF    := AllTrim(GetPvProfString("Sistema", "Path", "C:\LeituraMF.txt", GetClientDir() + "IBMFI32.INI"))
    If Right(::cPathMF,1) <> "\" 
    	::cPathMF  := ::cPathMF  + "\"
    EndIf                                                         
    //Carrega as mensagens
	::CarregMsg()
	
Return Self            

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1335  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura da porta serial.           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Numero da porta COM (nao utilizado)						  		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AbrirPorta(cPorta) Class LJAIBM
	                                                                                           
/*  	Local oParams 		:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
 

	//Prepara os parametros de envio                                      
	oParams := ::PrepParam({IBM, "IBM_FI_AbrePortaSerial"})
 
    //Envia o comando                                         
    cRetorno := ::EnviarCom(oParams)                                       

    //Trata o retorno       
    oRetorno := ::TratarRet(cRetorno)   */      
    oRetorno := ::TratarRet("0000")

Return oRetorno      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo fechamento da porta serial.         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Numero da porta COM (nao utilizado)						  		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method FechaPorta(cPorta) Class LJAIBM

	Local oParams 		:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
			
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_FechaPortaSerial"})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno   
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno
  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura do cupom fiscal            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cCnpj) - C.N.P.J/C.P.F do cliente.			   	  ���
���			 �EXPC2 (2 - cCliente) - Nome do cliente.   				  ���
���			 �EXPC3 (3 - cEndereco) - Endereco do cliente.			   	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf									      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Method AbrirCF(cCnpj, cCliente, cEndereco) Class LJAIBM

	Local oParams 		:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	

	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_AbreCupomMFD", Left(cCnpj,20), Left(cCliente,30), Left(cEndereco,80)})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)	
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336  �Autor  �Vendas Clientes	 � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo cancelamento do cupom fiscal        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CancelaCF() Class LJAIBM   

	Local oParams 	 := Nil			//Objeto para passagem dos parametros
	Local cRetorno  := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno  := Nil			//Objeto que sera retornado pela funcao	

	
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_CancelaCupom"})
	
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)                 
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)

Return oRetorno
  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VenderItem�Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela venda de um item no cupom fiscal    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                    	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cCodigo) - Codigo do item vendido.			   	  ���
���			 �EXPC2 (2 - cDescricao) - Descricao do item.  			  	  ���
���			 �EXPC3 (3 - cTribut) - Tipo da tributacao.				      ���
���			 �EXPN1 (4 - nAliquota) - Aliquota do item.			   	 	  ���
���			 �EXPN2 (5 - nQtde) - Quantidade do item vendido.	 	      ���
���			 �EXPN3 (6 - nVlUnit) - Valor unitario do item.			   	  ���
���			 �EXPN4 (7 - nDesconto) - Valor do desconto do item.	      ���
���			 �EXPC4 (8 - cComplemen) - Complemento da descricao.          ���
���			 �EXPC5 (9 - cUniMed) - Unidade de medida do item.		      ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method VenderItem(cCodigo	, cDescricao, cTribut	, nAliquota	, ;
						nQtde	, nVlUnit	, nDesconto	, cComplemen, ;
	    				cUniMed ) Class LJAIBM   
					
	Local oParams 		:= Nil	//Objeto para passagem dos parametros
	Local cRetorno 	:= ""		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil	//Objeto que sera retornado pela funcao		
	Local cAliquota	:= ""		//String temporaria que guarda o indice da aliquota
	Local cQtde			:= ""		//Qantidade
	Local cVlUnit		:= ""		//Valor unitario   
	Local cTipoDesc   := Nil   //Valor do Desconto
	Local cValorDesc  := Nil   //Valor do Acrescimo      
	Local cValorAcres  := ""
	
	//Busca aliquota 
   cAliquota := ::BuscaAliq(cTribut, nAliquota)	
	
  	If Empty(cAliquota) 
		//Aliquota nao cadastrada no ECF
		oRetorno := ::TratarRet("0521")
	Else 
		//Prepara os valores
		cCodigo := AllTrim(Substr(cCodigo, 1, 14))
		cQtde := Transform(nQtde, "@E 9,999.999")
		cVlUnit := Transform(nVlUnit, "@E 99,999.99")
	
		cDescricao = AllTrim(SubStr(AllTrim(cDescricao), 1, 200 ))
		
		//Desconto ser� efetuado em outro m�todo especifico.
		cTipoDesc := "%" 
		cValorDesc := cValorAcres := "0000"
		                   
		
		//Prepara os parametros de envio
		oParams := ::PrepParam({IBM, "IBM_FI_VendeItemDepartamento", cCodigo, cDescricao, cAliquota,cVlUnit, ;
								cQtde,  cValorAcres, cValorDesc, "0",Left(cUniMed,2)})  
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)                                
		
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst(cRetorno)
		
		//Trata o retorno    
		oRetorno := ::TratarRet(cRetorno)
		
		If( ( nDesconto > 0) .AND. ( oRetorno:cAcao <> ERRO ) )				
			oRetorno := ::DescItem(nDesconto)		//Efetua o desconto sobre o item.
		EndIf
  	EndIf 
	
	/**************************************************************************/
	//DEFINO MANUALMENTE A FASE DO CF, IBM  NAO TEM ESTA FUNCAO DE RETORNO
	::oFlagsFisc:lCFItem  := .T. 
	::oFlagsFisc:lCFPagto := .F. 
	::oFlagsFisc:lCFTot   := .F. 
	oRetorno:oRetorno := ::oFlagsFisc	//Copia o valor da propriedade da classe
	/**************************************************************************/
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CancItem  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo cancelamento item no cupom fiscal   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cItem) - Numero do item vendido.			   	  ���
���			 �EXPC2 (2 - cCodigo) - Codigo do item vendido.			  	  ���
���			 �EXPC3 (3 - cDescricao) - Descricao do item.  			  	  ���
���			 �EXPC4 (4 - cTribut) - N/A.		  						  ���
���			 �EXPN1 (5 - nAliquota) - Aliquota do item.			   	 	  ���
���			 �EXPN2 (6 - nQtde) - Quantidade do item vendido.	 	      ���
���			 �EXPN3 (7 - nVlUnit) - Valor unitario do item.			   	  ���
���			 �EXPN4 (8 - nDesconto) - Valor do desconto do item.	      ���
���			 �EXPC9 (9 - cUniMed) - Unidade de medida do item.		      ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CancItem(cItem) Class LJAIBM
	    			
	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao
	Local cNItem 	:= Nil
	
	cNItem := AllTrim(cItem)
	
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_CancelaItemGenerico", cNItem})
	
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)    			

Return oRetorno


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DescItem  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo desconto em um item do cupom fiscal ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPN1 (1 - nValor) - Valor do desconto.			   	  	  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
                  
Method DescItem(nValor) Class LJAIBM

	Local oParams 	 := Nil			//Objeto para passagem dos parametros
	Local cRetorno  := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno  := Nil			//Objeto que sera retornado pela funcao			
	Local cValor	 := ""			//Valor do desconto     
	Local	cItem 	 := ""         //Descricao do item
	Local	cNumItem  := ""         //Numero do item
	Local cAcrDes   := "D"        //Se � acrescimo ou desconto
	Local cTpAcrDes := "$"        //porcentagem ou real
   

	//Busca o numero do ultimo item lan�ado
	cItem 	:= ::GetNumItem()	
	cNumItem :=  substr(cItem, 2, 3)
	
	cValor := AllTrim(Str(nValor * 100))
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_AcrescimoDescontoItemMFD", cNumItem, cAcrDes, cTpAcrDes, cValor})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DescTotal �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo desconto no subtotal do cupom fiscal���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPN1 (1 - nValor) - Valor do desconto.			   	  	  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method DescTotal(nValor) Class LJAIBM

	Local oRetorno := Nil				//Objeto que sera retornado pela funcao			
	Local	cAcre    := "D"   			//Indica se � A=Acrescimo, D=Desconto
	Local	cTpAcre  := "$"            //Indica se � Percentual(%) ou valor ($)
	Local	cValAcre := "0000"         //Valor do Acrescimo
	Local	cValDesc := Nil            //Valor do Desconto    

	cValDesc := AllTrim(Str(nValor * 100))       
	
	//Inicio o fechamento do cupom para creditar ou debitar valor 
	oRetorno := ::IniFecha(cAcre, cTpAcre, cValAcre, cValDesc)
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AcresItem �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo acrescimo em um item do  			  ���
���          �cupom fiscal                                                ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�EXPN1 (1 - nValor) - Valor do acrescimo.			   	  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AcresItem(nValor) Class LJAIBM

	Local oParams 	 := Nil			//Objeto para passagem dos parametros
	Local cRetorno  := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno  := Nil			//Objeto que sera retornado pela funcao			
	Local cValor	 := ""			//Valor do desconto     
	Local	cItem 	 := ""         //Descricao do item
	Local cNumItem  := ""         //Numero do item
	Local cAcrDes   := "A"        //Acrescimo ou Desconto
	Local cTpAcrDes := "$"        //Real ou percentual
   

	//Busca o numero do ultimo item lan�ado
	cItem := ::GetNumItem()	
	cNumItem :=  substr(cItem, 2, 3)
	
	cValor := AllTrim(Str(nValor * 100))
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_AcrescimoDescontoItemMFD", cNumItem, cAcrDes, cTpAcrDes, cValor})
	
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AcresTotal�Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo acrescimo no subtotal do cupom	  	  ���
���          �fiscal                                                	  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPN1 (1 - nValor) - Valor do acrescimo.			   	  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AcresTotal(nValor) Class LJAIBM

	Local oRetorno := Nil		//Objeto que sera retornado pela funcao			
	Local	cAcre    := "A"   	//Indica se � A=Acrescimo, D=Desconto
	Local	cTpAcre  := "$"      //Indica se � Percentual(%) ou valor ($)
	Local	cValAcre :=  Nil     //Valor do Acrescimo
	Local	cValDesc := "0000"   //Valor do Desconto

	cValAcre := AllTrim(Str(nValor * 100))       
	
	//Inicio o fechamento do cupom para creditar ou debitar valor
	oRetorno := ::IniFecha(cAcre, cTpAcre, cValAcre, cValDesc)

Return oRetorno  


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AcresTotal�Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel ppor subtotalizar o cupom fiscal		  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�																				  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method IniFecha(cAcre, cTpAcre, cValAcre, cValDesc) Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao			
   
		//Prepara os parametros de envio
		oParams := ::PrepParam({ IBM, "IBM_FI_IniciaFechamentoCupomMFD", cAcre, cTpAcre, cValAcre, cValDesc})
		
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst(cRetorno)
		
		//Trata o retorno    
		oRetorno := ::TratarRet(cRetorno)		 
		
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EfetuaPgto�Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo pagamento do cupom fiscal			  ���
���          �                                                 			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cForma) - Nome da forma de pagamento utilizada.  ���
���          �EXPN1 (2 - nValor) - Valor do pagamento efetuado.   	  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method EfetuaPgto(cForma, nValor) Class LJAIBM

	Local oParams 	 := Nil			//Objeto para passagem dos parametros
	Local cRetorno  := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno  := Nil			//Objeto que sera retornado pela funcao		
	Local cValor	 := ""			//Valor do pagamento         
	Local cParcela  := Nil      	//Numero de parcelas da forma de pagamento
	Local cDescfPg  := Nil 	  		//Descricao da forma de pagamento       
	Local cAcre     := "X" 			//Indica se haver� acresicmo(A), desconto(D) ou ambos(X) no Cupom fiscal no total
	Local cTpAcre   := "%" 			//tipo de acr�scimo ou desconto ($)valor, (%)percentual no total
	Local cValAcre  := "0000" 		//Valor do acrescimo no total
	Local cValDesc  := "0000" 		//valor do desconto no total

	//Verifica se a forma esta cadastrada no ecf                                    
	oRetorno := ::TratarRet("0000")
	
	If oRetorno:cAcao <> ERRO                                        
      
      	//Inicio o fechamento do cupom para creditar ou debitar valor
   		::IniFecha(cAcre, cTpAcre, cValAcre, cValDesc)    
   		
      If oRetorno:cAcao <> ERRO

			//cIndice := oRetorno:oRetorno:cIndice                                       
			//Prepara o valor
			cValor := AllTrim(Str(nValor * 100)) 
			
			cParcela := "1" //somente para comprovante nao fiscal vinculado
			cDescfPg := ""     
			//Prepara os parametros de envio
			oParams := ::PrepParam({ IBM, "IBM_FI_EfetuaFormaPagamentoMFD", substr(cForma, 1, 16), cValor, cParcela, cDescfPg})
			//Envia o comando    	
			cRetorno := ::EnviarCom(oParams)
			//Obtem o Estado da impressora
			cRetorno := ::ObterEst(cRetorno)
			//Trata o retorno    
			oRetorno := ::TratarRet(cRetorno)
			                                        
		EndIf
		
		If oRetorno:cAcao <> ERRO
			//Guarda forma de pagto
			::GuardarPgt(cForma, nValor)
		EndIf
	EndIf   
	
	/**************************************************************************/
	//DEFINO MANUALMENTE A FASE DO CF, IBM  NAO TEM ESTA FUNCAO DE RETORNO
	::oFlagsFisc:lCFItem  := .F. 
	::oFlagsFisc:lCFPagto := .T. 
	::oFlagsFisc:lCFTot   := .F. 
	oRetorno:oRetorno := ::oFlagsFisc	//Copia o valor da propriedade da classe
	/**************************************************************************/

Return oRetorno
  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FecharCF  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo fechamento do cupom fiscal          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oMsgPromo) - Mensagem promocional				  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method FecharCF(oMsgPromo) Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil	//Objeto que sera retornado pela funcao		
	Local nDX		:= 1			//Contador utilizado no comando "For"
	Local nLinhas	:= 8			//Numero de linhas promocionais
	Local cMsgPro  := ""	

		//Limita o numero de linhas promocionais a 8
		If( oMsgPromo:Count() < 8)
			nLinhas := oMsgPromo:Count()
		EndIf
	
		//Copia as linhas recebidas pela funcao, truncando (se necessario) a linha em 48 caracteres.	
		For nDX := 1 To nLinhas
			cMsgPro += ::TrataTags(Substr(oMsgPromo:Elements(nDX), 1, 48))
		Next nDX		
                                                                                         
		//Prepara os parametros de envio
		
		oParams := ::PrepParam({IBM, "IBM_FI_TerminaFechamentoCupom", cMsgPro})
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
	                                                    
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst(cRetorno)
	
		//Trata o retorno    
		oRetorno := ::TratarRet(cRetorno)       
		
		/**************************************************************************/
		//DEFINO MANUALMENTE A FASE DO CF, IBM  NAO TEM ESTA FUNCAO DE RETORNO
		::oFlagsFisc:lCFItem  := .F. 
		::oFlagsFisc:lCFPagto := .F. 
		::oFlagsFisc:lCFTot   := .T. 
		oRetorno:oRetorno := ::oFlagsFisc	//Copia o valor da propriedade da classe
		/**************************************************************************/
			

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por totalizar o cupom.                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													                 ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TotalizaCF()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//NOTA: As impressoras IBM nao precisam receber o comando de totalizacao de cupom.

	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
Return oRetorno

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �AbrirCNFV �Autor  �Vendas Clientes     � Data �  20/06/11  	  ���
����������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura de um cupom nao fiscal     	  ���
���          �vinculado													  	 			     ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	     ���
����������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cForma) - Nome da forma de pagamento utilizada.  	  ���
���          �EXPN1 (2 - nValor) - Valor do pagamento efetuado.   	  	  	  ���
����������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  	           ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Method AbrirCNFV(cForma, nValor) Class LJAIBM                                      '

	Local oParams 	 := Nil			//Objeto para passagem dos parametros
	Local cRetorno  := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno  := Nil			//Objeto que sera retornado pela funcao		
	Local cValor	 := ""			//Valor do desconto
	Local cNumCupom := Nil			//Numero do Cupom	
	Local cCPF 		 := space(29)  //CPF do cliente
	Local cNome		 := space(30)  //Nome do cliente
	Local cEndereco := space(80)  //Endereco do cliente  
	Local nCount    := 0

	//Verifica se a forma esta cadastrada no ecf                                      
  	oRetorno := ::TratarRet("0000")         

	//Verifica as formas da venda anterior para pegar o valor correto
	If ::oFormasVen != Nil
		For nCount := 1 To ::oFormasVen:Count()
	    	If AllTrim(Upper(::oFormasVen:Elements(nCount):cForma)) == AllTrim(Upper(cForma))
	    		nValor := ::oFormasVen:Elements(nCount):nValor
	    		Exit
	    	EndIf
		Next
	EndIf
	
	If oRetorno:cAcao <> ERRO                
	
		//Prepara o valor
		cValor := AllTrim(Str(nValor * 100)) 
		                                                 
		cNumCupom := ::GetNumCup():oRetorno       

     	//Prepara os parametros de envio
		oParams := ::PrepParam({IBM, "IBM_FI_AbreComprovanteNaoFiscalVinculadoMFD", substr(cForma, 1, 16), cValor, substr(cNumCupom, 1, 6),  cCPF, cNome, cEndereco})
	
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
	
		//Obtem o Estado da impressora                   
		cRetorno := ::ObterEst(cRetorno)                 
	
		//Trata o retorno    
		oRetorno := ::TratarRet(cRetorno)
	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FecharCNFV�Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo fechamento de um cupom nao fiscal   ���
���          �vinculado													  				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method FecharCNFV() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao			
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_FechaComprovanteNaoFiscalVinculado"})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �CancCNFV  �Autor  �Vendas Clientes     � Data �  20/06/11     ���
����������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo cancelamento de um cupom nao fiscal    ���
���          �vinculado													     			     ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     	  ���
����������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cCupom) - Coo do cupom fiscal relativo ao pagamento.���
���          �EXPC2 (2 - cForma) - Nome da forma de pagamento utilizada.  	  ���
���          �EXPN1 (3 - nValor) - Valor do pagamento efetuado.   	  	  	  ���
����������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  	 			  ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Method CancCNFV(cCupom, cForma, nValor) Class LJAIBM       

	Local oParams 		:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""		  		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao 
	Local cCPF        := space(29)
	Local cNome			:= space(30)
	Local cEndereco	:= space(80)

	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_CancelaRecebimentoNaoFiscalMFD", cCPF, cNome, cEndereco})

	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)

	//Obtem o Estado da impressora             
	cRetorno := ::ObterEst(cRetorno)

	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AbrirCNF  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura de um cupom nao fiscal nao ���
���          �vinculado													  				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cCnpj) - C.N.P.J do cliente.					  		  ���
���          �EXPC2 (2 - cCliente) - Nome do cliente.  					     ���
���          �EXPC3 (3 - cEndereco) - Endereco do cliente.   	  	  	     ���
���          �EXPC4 (4 - cTotaliz) - Totalizador nao fiscal utilizado. 	  ���
���          �EXPN1 (5 - nValor) - Valor do item nao fiscal. 	  		     ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������                 
�����������������������������������������������������������������������������
*/
Method AbrirCNF(cCnpj, cCliente, cEndereco, cTotaliz, nValor) Class LJAIBM

	Local oParams 	 := Nil			//Objeto para passagem dos parametros
	Local cRetorno  := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno  := Nil			//Objeto que sera retornado pela funcao	
	Local cCPFCNPJ	 := cCnpj
	Local cNome		 := cCliente
	Local cEnd 		 := cEndereco       
	Local cIndice   := Nil                                               
    
  	//Verifica se o totalizador esta cadastrado no ecf
	oRetorno := ::GetTotaliz(cTotaliz) 
	
	If oRetorno:cAcao == OK
		//Pega o indice do totalizador
		cIndice := oRetorno:oRetorno:cIndice
		//Prepara o valor
		cValor := AllTrim(Str(nValor * 100))
		
		//Prepara os parametros de envio
		oParams := ::PrepParam({IBM, "IBM_FI_AbreRecebimentoNaoFiscalMFD", cCPFCNPJ, cNome, cEnd})
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst(cRetorno)
		//Trata o retorno    
		oRetorno := ::TratarRet(cRetorno)	 
		
			If oRetorno:cAcao <> ERRO	                  
	
				//Prepara os parametros de envio
				oParams := ::PrepParam({IBM, "IBM_FI_EfetuaRecebimentoNaoFiscalMFD", cIndice, cValor})    
				//Envia o comando    	
				cRetorno := ::EnviarCom(oParams)
				//Obtem o Estado da impressora                
				cRetorno := ::ObterEst(cRetorno)
				//Trata o retorno    
				oRetorno := ::TratarRet(cRetorno) 
				
			EndIF
		
	EndIF

Return oRetorno

/*                                   
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FecharCNF �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo fechamento de um cupom nao fiscal   ���
���          �nao vinculado											      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method FecharCNF() Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cMsg     := ""		
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_FechaRecebimentoNaoFiscalMFD", cMsg})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)           
	//Obtem o Estado da impressora                                                                      
	cRetorno := ::ObterEst(cRetorno)
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PgtoCNF   �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo pagamento do cupom nao fiscal nao   ���
���          �vinculado                                        			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cForma) - Nome da forma de pagamento utilizada.  ���
���          �EXPN1 (2 - nValor) - Valor do pagamento efetuado.   	  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method PgtoCNF(cForma, nValor) Class LJAIBM

	Local oParams 	 := Nil		 //Objeto para passagem dos parametros
	Local cRetorno  := ""		 //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno  := Nil		 //Objeto que sera retornado pela funcao		
	Local cValor	 := space(14) //Valor do pagamento  
	Local cAcrdes   := "X" 		  //acrescimo x=ambos d=desconto a=acrescimo
	Local cTpAcrDes := "%"  	  //tipo de acrescimo valor ou percentual 
	Local cValAcr   := "0000"    //valor do acrescimo
	Local cValDes   := "0000"    //valor do desconto    
	Local cParcela  := "1" 		 //somente para comprovante nao fiscal vinculado
	Local	cDescfPg  := ""  		//descricao do pagamento
		
	//Verifica se a forma esta cadastrada no ecf
	oRetorno := ::GetForma(substr(cForma, 1, 16))
	
	If oRetorno:cAcao <> ERRO		   
			
		//Prepara os parametros de envio
		oParams := ::PrepParam({IBM, "IBM_FI_IniciaFechamentoRecebimentoNaoFiscalMFD", cAcrdes, cTpAcrDes, cValAcr, cValDes})    
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		//Obtem o Estado da impressora                
		cRetorno := ::ObterEst(cRetorno)
		//Trata o retorno    
		oRetorno := ::TratarRet(cRetorno)
				
				If oRetorno:cAcao <> ERRO		      
					
					//Prepara o valor
					cValor := AllTrim(Str(nValor * 100))
					
					//Prepara os parametros de envio
					oParams := ::PrepParam({ IBM, "IBM_FI_EfetuaFormaPagamentoMFD", substr(cForma, 1, 16), cValor, cParcela, cDescfPg})
					//Envia o comando    	
					cRetorno := ::EnviarCom(oParams)
					//Obtem o Estado da impressora
					cRetorno := ::ObterEst(cRetorno)
					//Trata o retorno    
					oRetorno := ::TratarRet(cRetorno)
			
				EndIF			
	
	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CancCNF   �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo cancelamento do cupom nao fiscal    ���
���          �nao vinculado                                        		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  				     ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CancCNF() Class LJAIBM

	Local oParams 		:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil		//Objeto que sera retornado pela funcao
	Local cCpf        := space(29)			
	Local cNome       := space(30)			
	Local cEnde       := space(80)				
		                                
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_CancelaCupomMFD", cCpf,	cNome, cEnde}) 

	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
 	
 	cRetorno := ::ObterEst(cRetorno)                                           
	
	//Trata o retorno         
	oRetorno := ::TratarRet(cRetorno)  

Return oRetorno


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AbrirRG   �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura de um relatorio gerencial  ���
���          �		                                        			  		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cRelatorio) - Indice do relatorio.  				  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AbrirRG(cRelatorio) Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao		
	Local cIndice	:= ""		//String temporaria que guarda o indice do relatorio
	                 
	cIndice := "01"

	If ( !(cRelatorio == Nil) .OR. !Empty(AllTrim(cRelatorio)) )  //Quando a impress�o � feita por titulo de relatorio gerencial
		cIndice := AllTrim(cRelatorio)
	EndIf
                 
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_AbreRelatorioGerencialMFD", cIndice})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �UsaRG  �Autor  �Vendas Clientes     � Data �  20/06/11  	  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por escrever no relatorio gerencial   	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�cTexto = texto a ser impresso										  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  		     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method UsarRG(cTexto) Class LJAIBM

	Local oParams 		:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil		//Objeto que sera retornado pela funcao
	Local cTextoEnv   := Nil
	
	cTextoEnv := substr(cTexto, 1, 492) 	 		                              
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_UsaRelatorioGerencialMFD", cTextoEnv})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora                
	cRetorno := ::ObterEst(cRetorno)                   
	//Trata o retorno                                       
	oRetorno := ::TratarRet(cRetorno) 
	
	                                               
Return oRetorno                                                   


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FecharRG  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo fechamento do relatorio gerencial   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method FecharRG() Class LJAIBM                     

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao			
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_FechaRelatorioGerencial"})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno  


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FecharRG  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por configurar pagamento nao fiscal		  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfPGNF(nIndice, cDescr) Class LJAIBM                     

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao			
	                                                                                  
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_NomeiaTotalizadorNaoSujeitoIcms", nIndice, cDescr})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	//Trata o retorno                                                                              
	oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno  



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpTxtNF  �Autor  �Vendas Clientes     � Data �  20/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelimpressao de linhas nao fiscais   	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oRelatorio) - Linhas nao fiscais.			  	  ���
���			 �ExpL1 (2 - lLinha) - Se vai ser impresso linha a linha.	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf									      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ImpTxtNF(oRelatorio, lLinha) Class LJAIBM

	Local oParams 	:= Nil					//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil         			//Objeto que sera retornado pela funcao
	Local nCont     := 1           			//Contador do For...
	Local lPrint	:= .T.					//Flag responsavel por bloquear o envio da linha, caso tenha acontecido algum erro no comando anterior
	
	If !lLinha 
		oRelatorio := Self:PrepRel(oRelatorio, CHR(10), _BYTESLINHANF)
	EndIf
	
	//Copia as linhas recebidas pela funcao, truncando (se necessario) a linha em 56 caracteres.	
	For nCont := 1 To oRelatorio:Count()
                   
		oParams  := Self:PrepParam({IBM, "IBM_FI_UsaComprovanteNaoFiscalVinculado", ::TratParam(oRelatorio:Elements(nCont)) })	
		                        
		If (lPrint == .T.)
			//Envia o comando    	
			cRetorno := Self:EnviarCom(oParams)
			//Trata o retorno    
			oRetorno := Self:TratarRet(cRetorno)
			
			If( oRetorno:cAcao <> OK )
				lPrint := .F.
			EndIf
		EndIf
	Next nCont
	
Return oRetorno


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpTxtNF  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelimpressao de linhas nao fiscais   	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oRelatorio) - Linhas nao fiscais.				  	  ���
���			 �ExpL1 (2 - lLinha) - Se vai ser impresso linha a linha.	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TxtLivre(cTexto) Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""		  		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao		
	Local cDados	:= Space(492)	//Contador utilizado no comando "For"	

   cDados := Substr(cTexto,1,492)
   
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_UsaComprovanteNaoFiscalVinculado", cDados})			

	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
			                                                     
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Sangria   �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a Sangria  				  ���
���          �		                                        			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oFormas) - LJCFORMASECF com as fomas de pagamento���
���			 �EXPC1 (2 - cTotaliz) - Totalizador da sangria.			  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf			  	     			          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Sangria(oFormas, cTotaliz) Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil		//Objeto que sera retornado pela funcao		
	Local cValor	:= ""		//Valor da sangria
	Local nCount	:= 1		//Contador utilizado no For...
	Local nValor	:= 0		//Valor total da sangria
		
	//Pega o valor da sangria
	For nCount:=1 To oFormas:Count()
		nValor += oFormas:Elements(nCount):nValor
	Next nCont
	
	cValor := AllTrim(Str(nValor * 100,13,0))
	
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_Sangria", cValor})
	
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Suprimento�Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar o Fundo de Troco.			  ���
���          �		                                        			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oFormas) - LJCFORMASECF com as fomas de pagamento���
���			 �EXPC1 (2 - cTotaliz) - Totalizador da suprimento.			  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Suprimento(oFormas, cTotaliz) Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil		//Objeto que sera retornado pela funcao		
	Local cValor	:= ""		//Valor da sangria
	Local nCount	:= 1		//Contador utilizado no For...
    Local cForma    := space(16)
    Local nFormas   := oFormas:Count() 	//Quantidade de formas de pagamento       //Contador das formas de pagamento
    
    
    For nCount:=1 To nFormas
		//Efetua o pagamento do cupom nao fiscal
		cValor := AllTrim(Str(oFormas:Elements(nCount):nValor * 100,13,0 )) 
		cForma := Left(oFormas:Elements(nCount):cForma, 16)  
		oParams := ::PrepParam({IBM, "IBM_FI_Suprimento", cValor, cForma})            
		
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst(cRetorno)
		
		//Trata o retorno    
		oRetorno := ::TratarRet(cRetorno)
	    If(oRetorno:cAcao <> OK) 	
			Exit    
	    EndIf
    Next nCont   

Return oRetorno     


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por configurar o codigo de barras		  ���
���          �		                                        			  		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�EXPN1 (1 - nAltura) - Altura do codigo de barras  		     ���
���			 �EXPN2 (2 - nLargura) - Largura do codigo de barras 		     ���
���			 �EXPN3 (3 - nPosicao) - Posicao do codigo de barras 		     ���
���			 �EXPN4 (4 - nFonte) - Fonte do codigo de barras  			     ���
���			 �EXPN5 (5 - nMargem) - Margem do codigo de barras 			  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  		     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfCodBar(nAltura, nLargura, nPosicao, nFonte, nMargem) Class LJAIBM

	Local oParams 		:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil		//Objeto que sera retornado pela funcao		
 	Local cAltura  	:= Nil      //Altura do codigo de barras
   Local cLargura 	:= Nil      //Largura do codigo de barras
   Local cPosicao 	:= Nil      //Posicao do codigo de barras
   Local cFonte   	:= Nil      //Fonte do codigo de barras
   Local cMargem  	:= Nil      //Margem do codigo de barras
   
	cAltura  := AllTrim(str(nAltura))
   cLargura := AllTrim(str(nLargura))
   cPosicao := AllTrim(str(nPosicao))
   cFonte   := AllTrim(str(nFonte))
   cMargem  := AllTrim(str(nMargem))             

	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_ConfiguraCodigoBarrasMFD", cAltura, cLargura, cPosicao, cFonte, cMargem})
	
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)

Return oRetorno  


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336 �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por configurar o codigo de barras		  ���
���          �		                                        			  		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros� EXPC1 (1 - cString) - Valor do codigo de barras.  		  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/     

Method CodBarras(cString) Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao		

 	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_CodigoBarrasCODE128MFD", cString})
  
	//Envia o comando    	                                       
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)

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
Method EstNFiscVinc(cCPFCNPJ,cCliente,cEndereco,cMensagem,cCOOCCD) Class LJAIBM
Local oParams 	:= Nil		//Objeto para passagem dos parametros
Local cRetorno 	:= ""		//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil		//Objeto que sera retornado pela funcao
		           
//Prepara os parametros de envio
oParams := ::PrepParam({IBM, "IBM_FI_EstornoNaoFiscalVinculadoMFD", cCPFCNPJ,cCliente,cEndereco})

//Envia o comando    	
cRetorno := ::EnviarCom(oParams)

//Obtem o Estado da impressora
cRetorno := ::ObterEst(cRetorno)

//Trata o retorno    
oRetorno := ::TratarRet(cRetorno)

If oRetorno:cAcao == OK
	oRetorno := ::TxtLivre(cMensagem)
	
	If oRetorno:cAcao == OK
		oRetorno := ::FecharCNFV()
	EndIf
EndIf
        
Return oRetorno


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReducaoZ  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a Reducao Z.	  			  	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  		     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ReducaoZ() Class LJAIBM            

  	Local oParams 		:= Nil							 //Objeto para passagem dos parametros
	Local cRetorno 	:= ""		   					 //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil		   				 //Objeto que sera retornado pela funcao
	Local oRedZ			:= LJCDadosReducaoZ():New() //Objeto contendo os dados da reducao Z  
	Local nDX			:= 1								 //Contador utilizado no comando "For"
	Local nImposto		:= 0								 //Valor do imposto devido.
	Local cDados1  	:= Space(79)  					 //String que receber a tabela de aliquotas cadastradas no ECF
	Local cDados2  	:= Space(48)  					 //String que receber a tabela de aliquotas ISS cadastradas no ECF
	Local cDados3  	:= Space(889)  				 //String que receber a tabela de aliquotas ISS cadastradas no ECF
	Local cDados4     := Space(1278)
	Local nAliTmp   	:= 0
	Local nVlrTmp     := 0
	Local cIndAliqISS := NIL
	Local aArrAli     := {}
	Local cTotal      := Nil
	Local aArrVlr     := {}
	Local cData       := ""
	Local cHora			:= ""
	
	//Inicia o preenchimento do objeto LJCDadosReducaoZ             
	oRedZ:cNumEcf	:= ::cNumEcf                                                      
   oRedZ:cNrSerie	:= ::cNrSerie
   	    
	oRetorno := ::LeDataJor()                                                   
	
	If( oRetorno:cAcao <> ERRO )
		oRedZ:dDataMov := CTOD(oRetorno:oRetorno)            
		oRetorno := ::LeGT()    
	EndIf
	
	If( oRetorno:cAcao <> ERRO )
		oRedZ:nGranTotal := Val(oRetorno:oRetorno) / 100
		oRetorno := ::LeCOO()  
	EndIf
	
	If( oRetorno:cAcao <> ERRO )
		oRedZ:cNumCupFim := oRetorno:oRetorno
		oRetorno := ::LeTotCanc()
	EndIf
	
	If( oRetorno:cAcao <> ERRO )
		oRedZ:nTotCancel := oRetorno:oRetorno
		oRetorno := ::LeTotCanISS()
	EndIf

	If ( oRetorno:cAcao <> ERRO )
		oRedZ:nTotCanISS := oRetorno:oRetorno
		oRetorno := ::LeTotDesc() 
	EndIf
	   		
	If( oRetorno:cAcao <> ERRO )
		oRedZ:nTotDesc := oRetorno:oRetorno
		oRetorno := ::LeTotDesISS()
	EndIf

	If ( oRetorno:cAcao <> ERRO )
		oRedZ:nTotDesISS := oRetorno:oRetorno
		oRetorno := ::LeTotIsent() 
	EndIf
	
   	If( oRetorno:cAcao <> ERRO )
		oRedZ:nTotIsent	:= oRetorno:oRetorno
		oRetorno := ::LeTotNTrib()  
	EndIf
	
  	If( oRetorno:cAcao <> ERRO )
		oRedZ:nTotNTrib := oRetorno:oRetorno
		oRetorno := ::LeTotIss()    
	EndIf
	
 	If( oRetorno:cAcao <> ERRO )
		oRedZ:nTotIss := oRetorno:oRetorno
		oRetorno := ::LeVndLiq()   
	EndIf
	
	If( oRetorno:cAcao <> ERRO )
		oRedZ:nVendaLiq := oRetorno:oRetorno
		oRetorno := ::LeVndBrut()   
	EndIf
	
	If( oRetorno:cAcao <> ERRO )
		oRedZ:nVendaBrut := oRetorno:oRetorno
		oRetorno := ::GetSubstit()     
	EndIf
	
	If( oRetorno:cAcao <> ERRO )
		oRedZ:nTotSubst := oRetorno:oRetorno
		oRetorno := ::GetDatHora()    
	EndIf
    
	If( oRetorno:cAcao <> ERRO )
		oRedZ:dDataRed := CTOD(Substr(oRetorno:oRetorno, 1, 10))
		oRetorno := ::GetInterve() 
	EndIf
	
	If( oRetorno:cAcao <> ERRO )                                      
		oRedZ:cCro := oRetorno:oRetorno
	    oRetorno := ::GetNumCup() 
	EndIf

	If( oRetorno:cAcao <> ERRO )
		oRedZ:cNumCupIni := strzero((val(oRetorno:oRetorno)+1),6, 0)
	EndIf
    
	oRedZ:cCoo := StrZero(Val(oRedZ:cNumCupFim) + 1, 6)
	                                                                        
	//Tabela de totalizadores parciais		                                    
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados3})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)  
    
	     cTotal := substr(Alltrim(oParams:Elements(3):cParametro), 1, 224)
		  aArrVlr := {}   
		   
		   For nDx := 1 To 224 Step 14
		   	aAdd(aArrVlr, Val(SubStr(cTotal, nDx, 14)))
		   Next	                                          
    
		    //Todas as aliquotas cadastradas serao retornadas com "," como delimitador  
	  		//Prepara os parametros de envio 
			oParams := ::PrepParam({IBM, "IBM_FI_RetornoAliquotas", cDados1})
		
		   //Envia o comando    	
			cRetorno := ::EnviarCom(oParams)
		
			//Obtem o Estado da impressora
			cRetorno := ::ObterEst(cRetorno)
		
		    //Trata o retorno    
		    oRetorno := ::TratarRet(cRetorno)

		   If(oRetorno:cAcao <> ERRO) 
		  
		  		aArrAli := strtokarr(AllTrim(oParams:Elements(3):cParametro), ",")
		    
			    
	   	 	//Verfico as aliqutoas de ISS para serem descartadas
			   //Prepara os parametros de envio 
				oParams := ::PrepParam({IBM, "IBM_FI_VerificaIndiceAliquotasIss", cDados2})
		
		    	//Envia o comando    	
				cRetorno := ::EnviarCom(oParams)
				
				//Obtem o Estado da impressora
				cRetorno := ::ObterEst(cRetorno)
				
			    //Trata o retorno                                 
			    oRetorno := ::TratarRet(cRetorno)  
		    
		    
		    	If(oRetorno:cAcao <> ERRO) 
		    
			    	cIndAliqISS := AllTrim(oParams:Elements(3):cParametro)
			                           
    		  			For nDX := 1 To Len(aArrAli)
    			
		    			    nAliTmp := Val(aArrAli[nDx])
		    			    nVlrTmp := aArrVlr[nDx]
    			    
		    			    If nAliTmp == 0 .Or. StrZero(nDX, 2) $ cIndAliqISS
		    			    	Loop
		    			    EndIf
	    
							nImposto := NoRound(((nAliTmp / 100) * (nVlrTmp / 100)) /100, 2)
					  		oRedZ:AdicImp(nAliTmp / 100, nVlrTmp / 100, nImposto)
	    	  			Next nDX
	   	 	EndIf

  			EndIf	 
  			                                             
    EndIf                                                  

			   
	//Prepara os parametros de envio                                                                   
	 oParams := ::PrepParam({IBM, "IBM_FI_ReducaoZ", cData, cHora})
	//Envia o comando    	
    cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	 cRetorno := ::ObterEst(cRetorno)
	//Trata o retorno                                                  
    oRetorno := ::TratarRet(cRetorno) 
     
                                                                                 
	If( oRetorno:cAcao <> ERRO )
		 
		 //Prepara os parametros de envio
		 oParams := ::PrepParam({IBM, "IBM_FI_DadosUltimaReducaoMFD", cDados4})
		 
		 //Envia o comando    	
	    cRetorno := ::EnviarCom(oParams)
	 
		 //Obtem o Estado da impressora
		 cRetorno := ::ObterEst(cRetorno)
		 
		 //Trata o retorno                                              
	    oRetorno := ::TratarRet(cRetorno)    
    
	    If( oRetorno:cAcao <> ERRO )  
		    
		    aArrDados := strtokarr(AllTrim(oParams:Elements(3):cParametro), ",")
		    
    		 oRedZ:cNumRedZ := aArrDados[3]
			::oDadosRedZ := oRedZ
		
			//Inicializa variaveis
			::InicVar() 
			
		 EndIf
		                                                                                         
	EndIf                                       
		 
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AbrirDia  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a Abertura do dia.			  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AbrirDia()Class LJAIBM
	Local oRetorno := nil

	oRetorno := ::TratarRet("0000")
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MFData    �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a impressao da Leitura da    ���
���          �Memoria Fiscal por Data.                                    ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                    	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPD1 (1 - dDtInicio) - Data inicial do periodo (ddmmaaaa). ���
���			 �EXPD2 (2 - dDtFim) - Data final do periodo (ddmmaaaa).  	  ���
���          �EXPC1 (3 - cTipo) - Tipo da Leitura						  ���
���			 �					  (I- impressao / A - arquivo).			  ���
���			 �EXPC2 (4 - cTipoArq) - (C - completa / S - simplificada).	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf									      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method MFData(dDtInicio, dDtFim, cTipo, cTipoArq)	Class LJAIBM

	Local oParams 	:= Nil	//Objeto para passagem dos parametros
	Local cRetorno := ""		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil	//Objeto que sera retornado pela funcao
	Local cFlag 	:=  Right(cTipoArq, 1) 	//c=completa s=simplificada      
	Local cArquivo  := ::cPathMF + "RETORNO.TXT" //Nome do arquivo origem	 
	Local cArqDes   := "" //Arquivo de Destino
	
	
	
	If Left(cTipo,1) == "A" 
	   If FindFunction("LjxGerPath")
	   	LjxGerPath( @cArqDes ) 
	   	cArqDes += "LMF" + cFlag + ".txt" 
	   EndIf
	   oParams := ::PrepParam({IBM, "IBM_FI_LeituraMemoriaFiscalSerialDataMFD",dtoc(dDtInicio),dtoc(dDtFim),cFlag})
	Else
	
		//Prepara os parametros de envio 
		oParams := ::PrepParam({IBM, "IBM_FI_LeituraMemoriaFiscalDataMFD",dtoc(dDtInicio),dtoc(dDtFim),cFlag})
	EndIf 
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)	
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)    

	
   //Trata o retorno    
   oRetorno := ::TratarRet(cRetorno)

   
   If Left(cTipo, 1) == "A" .and. !Empty(cArqDes)
   	__CopyFile(cArquivo,cArqDes)
   EndIf
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MFReducao �Autor  �Vendas Clientes     � Data �  20/06/11  ���
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
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method MFReducao(cRedInicio, cRedFim, cTipo, cTipoArq)	 Class LJAIBM

	Local oParams 	:= Nil	//Objeto para passagem dos parametros
	Local cRetorno := ""		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil	//Objeto que sera retornado pela funcao 
	Local cFlag 	:=  Right(cTipoArq, 1) 	//c=completa s=simplificada      
	Local cArquivo  := ::cPathMF + "RETORNO.TXT" //Nome do arquivo origem
	Local cArqDes   := "" //Arquivo de Destino   

			
	If Left(cTipo,1) == "A"
		If FindFunction("LjxGerPath")
			LjxGerPath( @cArqDes ) 
	   		cArqDes += "LMF" + cFlag + ".txt"  
	    EndIf
		oParams := ::PrepParam({IBM, "IBM_FI_LeituraMemoriaFiscalSerialReducaoMFD",PadR(AllTrim(cRedInicio),4),PadR(AllTrim(cRedFim),4),cFlag})
	Else

		//Prepara os parametros de envio
		oParams := ::PrepParam({IBM, "IBM_FI_LeituraMemoriaFiscalReducaoMFD",Left(cRedInicio,4),Left(cRedFim,4),cFlag})
	EndIf
		
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora  
	cRetorno := ::ObterEst(cRetorno)    
	
   //Trata o retorno    
   	oRetorno := ::TratarRet(cRetorno)  

    If Left(cTipo, 1) == "A" .and. !Empty(cArqDes)
   		__CopyFile(cArquivo,cArqDes)
   	EndIf
	    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Autenticar�Autor  �Vendas Clientes     � Data �  20/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a autenticacao.		  	  ���
���          �								                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                   	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cTexto) - Texto a ser impresso na autenticacao.  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Autenticar(cLinha, cTexto) Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao     
   
    Default cLinha := space(2)
    Default cTexto := space(50)
   			 	
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_AutenticacaoMFD", Left(cLinha,2), Left(cTexto,50)})
				
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpCheque �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a impressao de cheque.		  ���
���          �								                              		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cBanco) - Numero do banco.						  	  ���
���			 �EXPC2 (2 - cValor) - Valor do cheque.						  	  ���
���			 �EXPC3 (3 - cData) - Data do cheque (ddmmaaaa).		 	  	  ���
���			 �EXPC4 (4 - cFavorecid) - Nome do favorecido.			   	  ���
���			 �EXPC5 (5 - cCidade) - Cidade a ser impressa no cheque.  	  ���
���			 �EXPC6 (6 - cTexto) - Texto adicional impresso no cheque.    ���
���			 �EXPC7 (7 - cExtenso) - Valor do cheque por extenso.	 	  ���
���			 �EXPC8 (8 - cMoedaS) - Moeda por extenso no singular.	  	  ���
���			 �EXPC9 (9 - cMoedaP) - Moeda por extenso no plural.	  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ImpCheque(cBanco	, nValor, cData    , cFavorecid , ;
				 cCidade, cTexto, cExtenso , cMoedaS    , ;
				 MoedaP) Class LJAIBM
					 
		Local oParams 	:= Nil			//Objeto para passagem dos parametros
		Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
		Local oRetorno := Nil		//Objeto que sera retornado pela funcao
   		Local cValor   := ""// Valor do Cheque
   		
   		cValor := AllTrim(Str(nValor,14,2))	  
   		
   		cData := Right(cData,2) + Substr(cData,5,2) + Left(cData,4)		

    	//Prepara os parametros de envio
		oParams := ::PrepParam({IBM, "IBM_FI_ImprimeChequeMFD"    , SubStr(cBanco,1,3)     , cValor ,;
															   SubStr(cFavorecid,1,45), SubStr(cCidade,1,27),;
															   cData , SubStr(cTexto,1,120), "0", "0"})
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
	
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst(cRetorno)
	
    	//Trata o retorno    
    	oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConfigPgto�Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a inclusao de uma forma de	  ���
���          �pagamento.					                              	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cVincula) - Flag que indica se a forma de		  ���
���			 �		pagamento sera vinculada (S - Sim, N - Nao ).		  	  ���
���			 �EXPC2 (2 - cForma) - Nome da forma de pagamento.			     ���
���			 �EXPC3 (3 - cIndice) - Indice da forma de pagamento.		     ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfigPgto(cForma, cOper) Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao   			
 	                                
 	DEFAULT cOper := "1"
 	                                
 	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_ProgramaFormaPagamentoMFD", SubStr(cForma,1,16), cOper})	

	//Envia o comando    	                       
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336  �Autor  �Vendas Clientes     � Data �  20/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a inclusao de um totalizador ���
���          �nao fiscal.					                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cIndice) - Indice do totalizador		  		  ���
���			 �EXPC2 (2 - cTotaliz) - Descricao do totalizador.		  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfTotNF(cIndice, cTotaliz)Class LJAIBM

	Local oParams 	 := Nil			//Objeto para passagem dos parametros
	Local cRetorno  := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno  := Nil			//Objeto que sera retornado pela funcao
 	                                
	//NOTA: O indice do totalizador sera gerado pela impressora, por este motivo, o parametro cIndice e ignorado.
 	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_NomeiaTotalizadorNaoSujeitoIcms", cIndice, Left(cTotaliz,16)})	 	

    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConfigAliq�Autor  �Vendas Clientes     � Data �  20/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a inclusao de uma aliquota.  ���
���          �								                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cAliq) - Valor da aliquota.			  		  ���
���			 �EXPN1 (2 - nTipoIss) - Flag que indica se a aliquota sera   ���
���			 �		referente a ISS (1 - Sim, 0 - Nao(ICMS) ).	 	  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf									      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                                             
Method ConfigAliq(nAliq, cTipoIss) Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao   			
	Local cAliq		:= ""			//Valor da aliquota
	
	cAliq := StrZero(nAliq*100 , 4,0)
	 	                                
 	If(cTipoIss == "S")                                                
 		cVinc := "1"
 	Else         
	 	cVinc := "0"
	EndIf
 	
 	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_ProgramaAliquota", SubStr(cAliq,1,4), cVinc})
 
   //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConfVerao �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a entrada / saida do horario ���
���          �de verao.						                              	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cTipo) - Tipo da configuracao.			  		  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfVerao(cTipo)Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao   			
 	                                
	//NOTA: Caso seja possivel, a entrada ou saida de intervencao sera feita sem a necessidade do envio de parametro.
 	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_ProgramaHorarioVerao"})	 	
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a inclusao de um relatorio   ���
���          �gerencial.					                              	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cIndice) - Indice do totalizador		  		  	  ���
���			 �EXPC2 (2 - cRelGer) - Descricao do relatorio gerencial.  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                                                                       
Method ConfRelGer(cIndice, cRelGer)Class LJAIBM

	Local oParams 		:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil		//Objeto que sera retornado pela funcao 

 	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_NomeiaRelatorioGerencialMFD", cIndice, cRelGer})	 	
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AbrirGavet�Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a abertura da gaveta.   	  ���
���          �					                              			  		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum.													  				  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AbrirGavet()Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao   			
 	                                
 	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_AcionaGaveta"})	 	
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
	                                                             
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o fabricante da impressora. ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  				     ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf contendo o nome do fabricante		  	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetFabric()Class LJAIBM

	Local oRet 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRet := ::TratarRet("0000")
    
    oRet:oRetorno := ::cFabric	//Copia o valor da propriedade da classe
    
Return oRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o modelo da impressora.	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�															  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf contendo o nome do fabricante		  	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetModelo()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cModelo	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a versao do firmware		  ���
���          �da impressora.                                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  				     ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetVerFirm()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cFirmWare	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o C.N.P.J. do usuario cadas-���
���          �trado no ECF.                                               ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetCNPJ()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cCnpj	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a inscicao estadual do 	  ���
���          �usuario cadastrado no ECF.                                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetInsEst()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cIE	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a inscicao municipal do 	  ���
���          �usuario cadastrado no ECF.                                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetInsMun()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cIM	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o numero da loja cadastrado ���
���          �no ECF.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetNumLj()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cLoja	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o nome do operador  		  ���
���          �cadastrado no ECF.                                          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  				     ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetOper()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cOperador	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a razao social cadastrada	  ���
���          �no ECF.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  				     ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetRzSoc()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cRazaoSoc	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o nome fantasia cadastrado  ���
���          �no ECF.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetFantas()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cFantasia	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o nome endereco 1 cadastra- ���
���          �do no ECF.                                                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  				     ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetEnd1()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cEndereco1	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o nome endereco 2 cadastra- ���
���          �do no ECF.                                                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetEnd2()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cEndereco2	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetDadRedZ�Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar os dados capturados na  	  ���
���          �execucao do ultimo comando de ReducaoZ                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetDadRedZ() Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::oDadosRedZ	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetMFTXT  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar um flag indicando se sera	  ���
���          �possivel gerar um arquivo a partir da leitura da MF.        ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�															  				     ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetMFTXT() Class LJAIBM
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := .T.

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetMFSerial�Autor  �Vendas Clientes     � Data �  20/06/11 ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar um flag indicando se sera	  ���
���          �possivel gerar a leitura da MF serial.			          	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetMFSerial() Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := .T.
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetHrVerao�Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o flag que indica horario de���
���          �verao no ECF.                                               ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  				     ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetHrVerao() Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(1)	//String que recebera a status do horario de verao
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_FlagsFiscais", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := oParams:Elements(3):cParametro == "4"
	EndIf
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetAliq   �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a tabela de aliquotas cadas-���
���          �tradas no ECF.                                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetAliq() Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::oAliquotas	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a tabela de formas de paga- ���
���          �mento cadastradas no ECF.                                   ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  				     ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetFormas()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::oFormas	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a tabela de totalizadores	  ���
���          �nao fiscais cadastrados no ECF.                             ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                                  
Method GetTotNF()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::oTotsNF	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a tabela de relatorios 	  ���
���          �gerenciais cadastrados no ECF.                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetRelGer()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::oGerencial	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o numero de serie do ECF.	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetNrSerie()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cNrSerie	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o numero do ultimo COO.	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetNumCup()Class LJAIBM   

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(6)	//String que recebera a status do horario de verao
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_NumeroCupom", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := substr(oParams:Elements(3):cParametro, 1, 6)
	EndIf
    
Return oRetorno
                                                 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o numero do ECF.	 	 	  	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  				     ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetNumEcf()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cNumEcf	//Copia o valor da propriedade da classe

Return oRetorno                                                                    
                                                                 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetNumItem�Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o numero do ultimo item 	  ���
���          �vendido pelo ECF.                                           ���
���          �Desconsiderar os itens cancelados.                          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetNumItem()Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(4)	//String que recebera a numero do item
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_UltimoItemVendido", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		//oRetorno:oRetorno := oParams:Elements(3):cParametro
		cRetorno := AllTrim(oParams:Elements(3):cParametro)
	EndIf

Return cRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetSubTot �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o valor do subtotal do cupom���
���          �fiscal.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetSubTot()Class LJAIBM
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(14)	//String que recebera subtotal do cupom
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_SubTotal", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := (Val(oParams:Elements(3):cParametro) / 100)
	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a data e hora atual do ECF. ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf contendo a data e hora atual do ECF    ���
���			 �no formato dd/mm/aaaa hh:mm:SS (19 bytes)					  	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetDatHora()Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cData  	:= Space(6)		//String que recebera a data do cupom
	Local cHora  	:= Space(6)		//String que recebera a hora do cupom
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_DataHoraImpressora", cData, cHora})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)                         
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno                                     
    oRetorno := ::TratarRet(cRetorno)

    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	

		oRetorno:oRetorno :=	Substr(AllTrim(oParams:Elements(3):cParametro),1,2)  + "/" +;
								Substr(Alltrim(oParams:Elements(3):cParametro),3,2)  + "/" +;
							  	"20"+Substr(AllTrim(oParams:Elements(3):cParametro),5,2)  + " " +;
							  	Substr(Alltrim(oParams:Elements(4):cParametro),1,2)  + ":" +;
							  	Substr(Alltrim(oParams:Elements(4):cParametro),3,2) + ":" +;
							  	Substr(Alltrim(oParams:Elements(4):cParametro),5,2)

	EndIf
	
Return oRetorno                          

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar se o ecf permite desconto   ���
���          �sobre o item vendido.                                       ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  		     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetDesItem()Class LJAIBM
	
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := .T.

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por verificar se a impressora e fiscal.  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetImpFisc()Class LJAIBM
	
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := .T.

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo que verifica se a impressora trunca ou arredonda.    ���
���          �T - trunca / A - Arredonda                                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetTrunAre()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := "T"
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo que verifica se a impressora necessita do valor do   ���
���          �Cheque por extenso.                                         ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�															  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetChqExt()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := .F.
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a Venda Bruta atual do ECF. ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetVdBruta()Class LJAIBM
	Local oRetorno 	:= ::LeVndBrut()
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o Grand Total atual do ECF. ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  		     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetGranTot()Class LJAIBM
	Local oRetorno 	:= ::LeGT()
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o total de descontos do ECF.���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetTotDesc()Class LJAIBM
	Local oRetorno 	:= ::LeTotDesc()
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o total de descontos de ISS ���
���          �do ECF.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													                 ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetDescIss()Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""			   //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que recebera os totais de desconto da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		
		aDados := strtokarr(oParams:Elements(3):cParametro, ",")	
	
		oRetorno:oRetorno :=	Val(aDados[11]) / 100 //ISSQN 

	EndIf
		
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o total de acrescimos do ECF���
���          �                                                     		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetTotAcre()Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""			   //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que recebera os totais de desconto da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		
		aDados := strtokarr(oParams:Elements(3):cParametro, ",")	
	
		oRetorno:oRetorno :=	Val(aDados[09]) / 100 + ; //ICMS 
								Val(aDados[12]) / 100  	  //ISSQN 

	EndIf

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o total de acrescimos em ISS���
���          �do ECF.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetAcreIss()Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que recebera os totais de desconto da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		
		aDados := strtokarr(oParams:Elements(3):cParametro, ",")	
	
		oRetorno:oRetorno := Val(aDados[12]) / 100  //ISSQN 

	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o total de cancelamentos do ���
���          �ECF.                                                        ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  				     ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetTotCanc()Class LJAIBM
	Local oRetorno 	:= ::LeTotCanc()
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o total de cancelamentos de ���
���          �ISS no ECF.                                                 ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  				     ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetCancIss()Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que recebera os totais cancelados da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		
		aDados := strtokarr(oParams:Elements(3):cParametro, ",")	
	
		oRetorno:oRetorno := Val(aDados[13]) / 100 //ISSQN 

	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o total de Isentos do ECF.  ���
���          �		 													  				     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													                 ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetIsentos()Class LJAIBM
	Local oRetorno 	:= ::LeTotIsent()
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o total de nao tributados   ���
���          �do ECF.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  				     ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetNaoTrib()Class LJAIBM
	Local oRetorno 	:= ::LeTotNTrib()
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetSubstit�Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o total de substituicoes    ���
���          �tributarias do ECF.                                         ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  				     ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetSubstit() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que receber a tabela de aliquotas cadastradas no ECF

	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
      If(oRetorno:cAcao <> ERRO)    	
		
			aDados := strtokarr(oParams:Elements(3):cParametro, ",")	
	
			oRetorno:oRetorno := Val(aDados[04]) / 100 + ;//Substituicao tribut�ria de ICMS
			   					 Val(aDados[07]) / 100    //Substituicao tribut�ria de ISSQN 

		EndIf

	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o numero da ultima reducao  ���
���          �Z executada pelo ECF.                                       ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetNumRedZ()Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(4)	//String que recebera os contadores da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_NumeroReducoes", cDados})
	                                            
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := oParams:Elements(3):cParametro
	EndIf
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o numero de cupons 		  	  ���
���          �cancelados pelo ECF.                                        ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetCancela() Class LJAIBM
	
	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(4)	//String que recebera os contadores da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_NumeroCuponsCancelados", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := oParams:Elements(3):cParametro
	EndIf
	
Return oRetorno
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetInterve�Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o numero de intervencoes	  ���
���          �executadas no ECF.                                          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetInterve() Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(4)	//String que recebera os contadores da impressora

	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_NumeroIntervencoes", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := AllTrim(oParams:Elements(3):cParametro)
	EndIf

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a data da ultima reducao  Z ���
���          �executada pelo ECF.                                         ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  				     ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetDtUltRe()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    If(::oDadosRedZ <> Nil)
    	oRetorno:oRetorno := ::oDadosRedZ:dDataMov	//Copia o valor da propriedade da classe
    EndIf
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o total de ISS vendido pelo ���
���          �ECF.                                         				  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetTotIss()Class LJAIBM
	Local oRetorno 	:= ::LeTotIss()
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetDataMov�Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a data de abertura do movi- ���
���          �mento atual do ECF.                                         ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetDataMov()Class LJAIBM
	
	Local oRetorno 	:= ::LeDataJor()	

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar os flags fiscais do ECF.	  ���
���          �                                         				  	     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetFlagsFi()Class LJAIBM
    
   Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""			   //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados1	:= Space(1)		//String que recebera o retorno da funcao 
	Local cDados2	:= Space(1)		//String que recebera o retorno da funcao 
    
   Local cAckFlag := Space(1)		//String que recebera o retorno da funcao 
   Local cST1Flag := Space(1)		//String que recebera o retorno da funcao 
   Local cST2Flag := Space(1)		//String que recebera o retorno da funcao 
   Local cST3Flag := Space(1)		//String que recebera o retorno da funcao     
   Local cStatus  := Space(1)		//String que recebera o retorno da funcao     
   Local cStatus1 := Space(1)		//String que recebera o retorno da funcao
   
    
   Local cDataMov := Space(6)		//String que recebera o retorno da funcao  
   Local cData  	:= Space(6)		//String que recebera o retorno da funcao  
   Local cHora  	:= Space(6)		//String que recebera o retorno da funcao            

	Local nRes1 	:= 0
	Local nRes2 	:= 0
	Local nRes3 	:= 0 
	Local nRes4 	:= 0 	
	Local nRes5 	:= 0 
	Local nRes6 	:= 0
	Local cDataImp := Nil
    Local nRedPend  := 0 		//Verifica o status da reducao Z Pendente
    
		::oFlagsFisc:lEcfOff    := .F.  
   	::oFlagsFisc:lCFAberto  := .F.                              
  		::oFlagsFisc:lCFItem    := .F. 
		::oFlagsFisc:lCFPagto   := .F. 
		::oFlagsFisc:lCFTot     := .F. 
		::oFlagsFisc:lCVAberto  := .F.  
		::oFlagsFisc:lFimPapel  := .F.   
		::oFlagsFisc:lNFAberto  := .F. 
		::oFlagsFisc:lPapelAcab := .F.                                             
		::oFlagsFisc:lRGAberto  := .F. 
		::oFlagsFisc:lTampAbert := .F. 
				
		/***************************************************************************/
		//TRATO O RETORNO ST1 e ST3
		//*ST1 - verifico se esta sem papel
		//*ST1 - verifico se ha pouco papel
		//*ST1 - verifico se tampa superior esta aberta (impressora com erro)
		//*ST1 - verifico se o cupom fiscal esta aberto
		//*ST3 - verifico se impressora esta off-line (retorno 13)
		//*ST3 - verifico tem reducao z pendente (retorno 66)
		//*Verifico se tem cupom fiscal Aberto
		/***************************************************************************/
		//Prepara os parametros de envio
		oParams := ::PrepParam({IBM, "IBM_FI_VerificaEstadoImpressora", cAckFlag, cST1Flag, cST2Flag, cST3Flag })
		
	   //Envia o comando
	   cRetorno := ::EnviarCom(oParams)
	    	
		  	//Retorno do ST1                                    
			nRes3 := val(oParams:Elements(4):cParametro) 
			//Retorno do ST2
			nRes4 := val(oParams:Elements(5):cParametro)  
			//Retorno do ST3
			nRes6 := val(oParams:Elements(6):cParametro)
		
		
			/***************************************************************************/
			//TRATO RETORNO DO ST1
			/***************************************************************************/	
			If (nRes3 >= 128)
				//Sem papel
				::oFlagsFisc:lFimPapel := .T. 
	   		nRes3 := nRes3 - 128
			EndIF
			
			IF (nRes3 >= 64)
	         //Pouco papel
				::oFlagsFisc:lPapelAcab := .T.  
	   		nRes3 := nRes3 - 64  
	   	EndIF
	   	
	   	IF (nRes3 >= 32)
	           //Erro no relogio 
	           nRes3 := nRes3 - 32 
		  	EndIF
		  	
		  	IF (nRes3 >= 16)
		  	
	         //Impressora em erro (Retorno da funcao)
				//Tampa superior aberta (Nao ha funcao especifica IBM para esta verificacao)
				::oFlagsFisc:lTampAbert := .T.
	          nRes3 := nRes3 - 16 
	          
	   	EndIF
	   	
	   	IF (nRes3 >= 8)
        		//Primeiro dado de cmd nao foi ESC
            nRes3 := nRes3 - 8
		  	EndIF
		  	
		  	IF (nRes3 >= 4)
	    		//Comando Inexistente
	          nRes3 := nRes3 - 4
		  	EndIF
		  	
		  	IF (nRes3 >= 2)
				//Cupom Fiscal aberto
	   		::oFlagsFisc:lCFAberto := .T. 
	          nRes3 := nRes3 - 2  
		  	EndIF
		  	
		  	IF (nRes3 >= 1)
	      	//Numero de parametro CMD Invalido
	     	EndIf   
		

		/***************************************************************************/
		//TRATO O RETORNO DO ST3
		/***************************************************************************/
		If nRes6 == 13
			//Impressora Online 
			::oFlagsFisc:lEcfOff := .T.
		EndIf

		If nRes6 == 66
			::oFlagsFisc:lInicioDia := .T.
			::oFlagsFisc:lDiaFechad := .F.                            
			::oFlagsFisc:lRedZPend  := .T.
		Else
		
			//Tratamento de bug do modelo SJ6
			//Enviar comando de verifica��o de redu��o z Pendente		
			//Prepara os parametros de envio
			oParams := ::PrepParam({IBM, "IBM_FI_VerificaZPendente", Str(nRedPend) })
		
	   		//Envia o comando
	   		cRetorno := ::EnviarCom(oParams)
	   		
	   		nRedPend := val(oParams:Elements(3):cParametro) 
	   		
	   		If nRedPend == 1
				::oFlagsFisc:lInicioDia := .T.
				::oFlagsFisc:lDiaFechad := .F.                            
				::oFlagsFisc:lRedZPend  := .T.
	   		EndIf 
	   		
		EndIf		
		
			                                                  
	/***************************************************************************/
	//TRATO O RETORNO DAS FLAGS FISCAIS
	//*Verifico se ouve reducao Z
	//*Verifico se tem cupom fiscal Aberto
	/***************************************************************************/
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_FlagsFiscais", cDados1})          
	
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    
	//Erro de comunicacao, ou seja impressora esta offline, excessao para verificar em outros modulos
    If(val(cRetorno)==0)
    	::oFlagsFisc:lEcfOff := .T.
    EndIf  
    	
  		nRes1 := val(oParams:Elements(3):cParametro)

		If (nRes1 >= 128)
         //Mem�ria fiscal sem espa�o
          nRes1 := nRes1 - 128
		EndIF
		
		IF (nRes1 >= 64)
        	//N�o utilizado 
         nRes1 := nRes1 - 64  
   	EndIF
   	
   	IF (nRes1 >= 32)
        	//Permite cancelar cupom fiscal 
         nRes1 := nRes1 - 32 
	  	EndIF
	  	
	  	IF (nRes1 >= 16)
        	//N�o utilizado 
         nRes1 := nRes1 - 16 
   	EndIF

   	IF (nRes1 >= 8)
        	//J� houve redu��o Z no dia 
         ::oFlagsFisc:lInicioDia := .T.
         ::oFlagsFisc:lDiaFechad := .T.
         ::oFlagsFisc:lRedZPend  := .F.
         nRes1 := nRes1 - 8
      EndIF
	   
	   IF (nRes1 >= 4)
        	//Hor�rio de ver�o selecionado 
   		nRes1 := nRes1 - 4
      EndIF
	   
	   IF (nRes1 >= 2)
        	//Fechamento de formas de pagamento iniciado
         nRes1 := nRes1 - 2  
      EndIF
	   
	   IF (nRes1 >= 1)
        //Cupom fiscal aberto
         ::oFlagsFisc:lCFAberto := .T.  
		 EndIf   

		/***************************************************************************/
		//TRATO O ESTADO DA GAVETA
		/***************************************************************************/   
		
	    //Prepara os parametros de envio
		 oParams := ::PrepParam({IBM, "IBM_FI_VerificaEstadoGaveta", cDados2})
		
	    //Envia o comando
	    cRetorno := ::EnviarCom(oParams)
	    	
	 	nRes2 := val(oParams:Elements(3):cParametro) 
			
			If nRes2 == 0  
				//Estado da gaveta - Aberta        
				::oFlagsFisc:lGavAberta := .T.
			Else
				//Estado da gaveta - Fechada                              
				::oFlagsFisc:lGavAberta := .F.
			EndIF

	
		/***************************************************************************/
		//TRATO RETORNO ESTENDIDO            
		/*verifico se relatorio gerencial esta aberto
		/*verifico se comprovante de credito ou debito esta aberto
		/*verifico se comprovante NAO fiscal esta aberto
		/***************************************************************************/
		//Prepara os parametros de envio
		oParams := ::PrepParam({IBM, "IBM_FI_StatusEstendidoMFD", cStatus })
		
	    //Envia o comando
	    cRetorno := ::EnviarCom(oParams)
	    	
			//Retorno do ST1
			nRes5 := val(oParams:Elements(3):cParametro) 
		
		
			If (nRes5 >= 128)
				 nRes5 := nRes5 - 128
			EndIF
			
			IF (nRes5 >= 64)
	      	//Estorno de Comprovante de D�bito ou Cr�dito permitido
				nRes5 := nRes5 - 64  
	   	EndIF
	   	
	   	IF (nRes5 >= 32)
	      	//Permite cancelamento do CNF 
	          nRes5 := nRes5 - 32 
			EndIF
			
		  	IF (nRes5 >= 16)
	          nRes5 := nRes5 - 16 
	   	EndIF
	   	
	   	IF (nRes5 >= 8)
	        	//Totalizando Cupom
         	nRes5 := nRes5 - 8
   	  	EndIF
   	  	
   	  	IF (nRes5 >= 4)
	        //Relat�rio Gerencial Aberto 
				::oFlagsFisc:lRGAberto := .T.       
	          nRes53 := nRes5 - 4
		  	EndIF
		  	
		  	IF (nRes5 >= 2)
				//Comprovante de D�bito ou Cr�dito Aberto
				::oFlagsFisc:lCVAberto := .T. 
	   		nRes5 := nRes5 - 2  
		  	EndIF
		  	
		  	IF (nRes5 >= 1)
	      	//Comprovante N�o-Fiscal Aberto
				::oFlagsFisc:lNFAberto := .T.
	      EndIf   
		
		/***************************************************************************/
		//TRATO RETORNO DA INTERVENCAO TECNICA
		/***************************************************************************/  
		
 		 //Prepara os parametros de envio
		 oParams := ::PrepParam({IBM, "IBM_FI_VerificaModoOperacao", cStatus1 })
		
	    //Envia o comando
	    cRetorno := ::EnviarCom(oParams)
	    	
	                                      
    		//Retorno do ST1
			nRes6 := val(oParams:Elements(3):cParametro) 
			
			If nRes6 == 0
				//Esta em intervencao tecnica
				::oFlagsFisc:lIntervenc := .T.
			Else
				//Esta em modo normal
				::oFlagsFisc:lIntervenc := .F.
			EndIf
			
		 /***************************************************************************/
		//TRATO RETORNO PARA VERIFICAR SE O DIA J� FOI INICIADO
		/***************************************************************************/
   		//Prepara os parametros de envio
			oParams := ::PrepParam({IBM, "IBM_FI_DataMovimento", cDataMov })
		
	    	//Envia o comando
	    	cRetorno := ::EnviarCom(oParams)
	    	
			//Obtem o Estado da impressora
			cRetorno := ::ObterEst(cRetorno)
	
			//Trata o retorno    
			oRetorno := ::TratarRet(cRetorno)
	
	   		 
    	   	cDataRet := AllTrim(oParams:Elements(3):cParametro)
			
				//Prepara os parametros de envio
				oParams := ::PrepParam({IBM, "IBM_FI_DataHoraImpressora",  cData, cHora })
		
			    //Envia o comando
	    		cRetorno := ::EnviarCom(oParams)
	    	
				cDataImp := AllTrim(oParams:Elements(3):cParametro)

			//Se a data de movimento for igual a data da impressora, o dia foi iniciado			
			If cDataRet == cDataImp

				::oFlagsFisc:lInicioDia := .T.
				::oFlagsFisc:lDiaFechad := .F.
				::oFlagsFisc:lRedZPend  := .F.

			Else
		
				::oFlagsFisc:lInicioDia := .F.
				::oFlagsFisc:lDiaFechad := .F.
				

				If  Val(cDataRet) > 0 .and. CtoD(Left(cDataRet,2) + "/" + SubsTr(cDataRet,3,2) + "/" + Right(cDataRet,2)) < CtoD(Left(cDataImp,2) + "/" + SubsTr(cDataImp,3,2) + "/" + Right(cDataImp,2))
					::oFlagsFisc:lRedZPend  := .T.  //Se a data do movimento for inferior � data do dia, redu��o z pendente
				Else
					::oFlagsFisc:lRedZPend  := .F.
                EndIf

			EndIf                                                 
			
		oRetorno:oRetorno := ::oFlagsFisc	//Copia o valor da propriedade da classe
                	    	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method BuscInfEcf() Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao       
	
	//Habilito o uso do retorno estendido ST3
   	//Prepara os parametros de envio                                                    
	oParams := ::PrepParam({IBM, "IBM_FI_HabilitaDesabilitaRetornoEstendidoMFD", "1"})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
 	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)   
    
    If(oRetorno:cAcao <> ERRO) 
	    oRetorno:= ::LeDadoUsu()
	 EndIF
	      
	 If(oRetorno:cAcao <> ERRO) 
		 oRetorno:= ::LeDadImp()	                  
	 EndIF
		 
	If(oRetorno:cAcao <> ERRO) 
		 	oRetorno:= ::LeCliche()   
	 EndIF
	 
	 If(oRetorno:cAcao <> ERRO) 
		 oRetorno:= ::LeOperador()  
	 EndIF
	 
	 If(oRetorno:cAcao <> ERRO) 
		 oRetorno:= ::LeECFLoja()                                           
	 EndIF
	 
	 If(oRetorno:cAcao <> ERRO) 
		 oRetorno:= ::LeAliq()      
	 EndIF
	 
	 If(oRetorno:cAcao <> ERRO) 
	 	 oRetorno:= ::LeTotNF()     
 	 EndIF
 	 
 	 If(oRetorno:cAcao <> ERRO) 
		 oRetorno:= ::LeRelGer()    
	 EndIF
	 
	 If(oRetorno:cAcao <> ERRO) 
		 oRetorno:= ::LeFinaliz()    
	 EndIF
	
	::oFlagsFisc:lCFItem  := .F. 
	::oFlagsFisc:lCFPagto := .F. 
	::oFlagsFisc:lCFTot   := .F.   
	oRetorno:oRetorno := ::oFlagsFisc
	
Return oRetorno

//******************************************************************//
//						Metodos internos										    //                 
//******************************************************************//                                                                     
Method ObterEst(cRetorno) Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local oRetorno	:= Nil			//Objeto que sera retornado pela funcao	
	//(06h ou 6d) NAK=(15h ou 21d)
	Local cEstado  := "1"   
	Local cMsg	   := space(200)
	Local cCodErr  := space(3) 

	//SE FOR RETORNO ESTENDIDO	                
	If	(val(cRetorno) == -27 .or. val(cRetorno) == 0) //Erro de Comunica��o	                                        
			
		//Prepara os parametros de envio


		//Trata outo estado da impressora 
		oParams := ::PrepParam({IBM, "IBM_FI_RetornoImpressoraPadraoIBM", cCodErr,  cMsg}) 
			
		cRetorno := ::EnviarCom(oParams)		  

		oRetorno := ::TratarRet(cRetorno)    
			 
		cCodErr :=  AllTrim(::CorrigRet(oParams:Elements(3):cParametro))
			    	
    	If ( oRetorno:cAcao <> ERRO ) 
    	       
    	   If !Empty( cCodErr)
    	   
    	   		cEstado := "IBM-" +  cCodErr
    	   Else
    	   		cEstado := "-99" //ST1=0;ST2=0;ST3=0 Executou com sucesso	
    	   
    	   EndIf    
    	   
    	EndIf   

	
   Else
       
    	cEstado := cRetorno
    
   EndIF	                                            

Return cEstado  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo carregamento das mensagens de    	  ���
���          �resposta possiveis da impressora.			  		  	  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                   	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum												      ���
�������������������������������������������������������������������������͹��
���Retorno   �nenhum													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CarregMsg() Class LJAIBM
	
	//FUNCOES
	::AdicMsgECF("0000", "Resultado sem erro", OK)     
	::AdicMsgECF("0521", "Al�quota n�o cadastrada no sistema.", ERRO)     
	::AdicMsgECF("-997", "Forma de Pagamento Cadastrada", OK)     
	::AdicMsgECF("-998", "Forma de Pagamento n�o Cadastrada", ERRO)   
	::AdicMsgECF("0066", "N�o dispon�vel op��o em Disco", ERRO)  
	::AdicMsgECF("999", "Fun��o n�o dispon�vel para este modelo de ECF", ERRO)  
	  
	
	//RETORNO PADRAO
	::AdicMsgECF("0", "Erro de comunica��o.", ERRO)
	::AdicMsgECF("1", "Comando OK", OK)
	::AdicMsgECF("-2", "Par�metro inv�lido na fun��o.", ERRO)
	::AdicMsgECF("-3", "Al�quota n�o programada.", ERRO)
	::AdicMsgECF("-4", "O arquivo de inicializa��o BemaFI32.ini n�o foi encontrado no diret�rio de sistema do Windows.", ERRO)
	::AdicMsgECF("-5", "Erro ao abrir a porta de comunica��o.", ERRO)
	::AdicMsgECF("-7", "Banco n�o localizado no arquivo de configura��o BemaFi32.ini.", ERRO)
	::AdicMsgECF("-8", "Erro ao criar ou gravar no arquivo STATUS.TXT ou RETORNO.TXT.", ERRO)    
	::AdicMsgECF("-9", "Time-out na leitura do cheque.", ERRO)
	::AdicMsgECF("-27", "Status da impressora diferente de 6,0,0,0 (ACK, ST1, ST2 e ST3)", ERRO)
	::AdicMsgECF("-99", "Erro ao tratar retorno.", ERRO) 
	
	//RETORNO FUNCAO IBM
	::AdicMsgECF("IBM-1", "Overflow inesperado.", ERRO)
	::AdicMsgECF("IBM-2", "Overflow inesperado.", ERRO)
	::AdicMsgECF("IBM-22", "Pagamento nao permitido.", ERRO)
	::AdicMsgECF("IBM-23", "Operacao Nao Fiscal nao permitida.", ERRO)
	::AdicMsgECF("IBM-24", "Total = 0 nao permitido.", ERRO)
	::AdicMsgECF("IBM-29", "Pagamento nao finalizado.", ERRO)
	::AdicMsgECF("IBM-30", "Operacao nao permitida.", ERRO)
	::AdicMsgECF("IBM-31", "Operacao CDC nao permitida.", ERRO)
	::AdicMsgECF("IBM-32", "Retorno de Pagamento NF nao permitido.", ERRO)
	::AdicMsgECF("IBM-33", "Cupom Adicional nao permitido.", ERRO)
	::AdicMsgECF("IBM-37", "Alcancado numero maximo de relatorio de MFD em intervencao tecnica.", ERRO)
	::AdicMsgECF("IBM-38", "Numero Max de itens atingido.", ERRO)
	::AdicMsgECF("IBM-42", "Aliquota nao permitida.", ERRO)
	::AdicMsgECF("IBM-44", "Categoria de Aliquota desabilitada.", ERRO)
	::AdicMsgECF("IBM-53", "Data/Hora invalida.", ERRO)
	::AdicMsgECF("IBM-54", "Cancelamento da ultima transacao nao permitido.", ERRO)
	::AdicMsgECF("IBM-55", "Tamanho de comando muito pequeno ou invalido.", ERRO)
	::AdicMsgECF("IBM-56", "Overflow di�rio.", ERRO)
	::AdicMsgECF("IBM-59", "Valor da transa��o muito pequeno.", ERRO)
	::AdicMsgECF("IBM-60", "Estouro do contador de Transacao.", ERRO)
	::AdicMsgECF("IBM-61", "Estouro do Contador Diario.", ERRO)
	::AdicMsgECF("IBM-62", "Necessario emitir Reducao Z.", ERRO)
	::AdicMsgECF("IBM-63", "Contribuinte n�o cadastrado.", ERRO)
	::AdicMsgECF("IBM-64", "Estouro de transa��o.", ERRO)
	::AdicMsgECF("IBM-65", "Comando invalido.", ERRO)
	::AdicMsgECF("IBM-66", "Extensao de comando invalido", ERRO)
	::AdicMsgECF("IBM-67", "Comando OK.", ERRO)
	::AdicMsgECF("IBM-68", "Numero ECF nao programado.", ERRO)
	::AdicMsgECF("IBM-69", "Atingido numero maximo de Linhas de Impressao.", ERRO)
	::AdicMsgECF("IBM-70", "Codificacao do GT nao programada.", ERRO)
	::AdicMsgECF("IBM-71", "Impressao de linhas nao permitida.", ERRO)
	::AdicMsgECF("IBM-72", "Impressao de Codigo de Barras nao permitida.", ERRO)
	::AdicMsgECF("IBM-77", "Grafico corrompido.", ERRO)
	::AdicMsgECF("IBM-78", "Grafico com mesmo numero ja carregado na flash.", ERRO)
	::AdicMsgECF("IBM-79", "Sequencia invalida no download grafico.", ERRO)
	::AdicMsgECF("IBM-80", "Logo nao abaixado.", ERRO)
	::AdicMsgECF("IBM-82", "Comprovante Nao Fiscal nao aberto.", ERRO)
	::AdicMsgECF("IBM-84", "Erro MFD/Pegue o erro extendido para apurar o erro.", ERRO)
	::AdicMsgECF("IBM-86", "Senha Invalida.", ERRO)
	::AdicMsgECF("IBM-88", "Operacao invalida de habilitar/desabilitar porta de comunicacao.", ERRO)
	::AdicMsgECF("IBM-89", "Memoria Fiscal Cheia - Favor substituir.", ERRO)
	::AdicMsgECF("IBM-90", "CRZ nao encontrado.", ERRO)
	::AdicMsgECF("IBM-96", "Dados invalidos - Caracteres nao permitidos.", ERRO)
	::AdicMsgECF("IBM-98", "Modo de interven��o tecnica nao necessario.", ERRO)
	::AdicMsgECF("IBM-99", "Memoria Fiscal Cheia - Favor usar dados da ultima MF.", ERRO)
	::AdicMsgECF("IBM-100", "Erro leitura MF.", ERRO)
	::AdicMsgECF("IBM-101", "Erro escrita MF.", ERRO)
	::AdicMsgECF("IBM-103", "Dados fora do intervalo permitido.", ERRO)
	::AdicMsgECF("IBM-104", "Dados de c�digo de barras deve ser terminados por NULL.", ERRO)
	::AdicMsgECF("IBM-105", "C�digo de barras/tamanho do gr�fico inv�lido.", ERRO)
	::AdicMsgECF("IBM-107", "Comprovante CDC nao aberto.", ERRO)
	::AdicMsgECF("IBM-108", "Comprovante CDC aberto.", ERRO)
	::AdicMsgECF("IBM-109", "Memoria Fiscal desconectada.", ERRO)
	::AdicMsgECF("IBM-111", "Programacao Horario Verao invalida.", ERRO)
	::AdicMsgECF("IBM-112", "Reinicio da impressora fiscal.", ERRO)
	::AdicMsgECF("IBM-113", "Erro fatal na impressora.", ERRO)
	::AdicMsgECF("IBM-114", "Erro de comunicao com impressora fiscal.", ERRO)
	::AdicMsgECF("IBM-116", "Movimento nao pode ser aberto.", ERRO)
	::AdicMsgECF("IBM-118", "Parametro de Relatorio / Indice Nao Fiscal / Pagamento invalido.", ERRO)
	::AdicMsgECF("IBM-119", "Dados invalidos - valor nao permitido.", ERRO)
	::AdicMsgECF("IBM-120", "Tempo limite excedido.", ERRO)
	::AdicMsgECF("IBM-124", "Faltam informacoes do cheque.", ERRO)
	::AdicMsgECF("IBM-125", "Nao ha Relatorio Gerencial aberto.", ERRO)
	::AdicMsgECF("IBM-126", "Relatorio Gerencial aberto.", ERRO)
	::AdicMsgECF("IBM-127", "MFD ja inicializada.", ERRO)
	::AdicMsgECF("IBM-128", "Memoria Fiscal nao serializada.", ERRO)
	::AdicMsgECF("IBM-129", "MFD nao inicializada.", ERRO)
	::AdicMsgECF("IBM-130", "Autenticacao nao permitida.", ERRO)
	::AdicMsgECF("IBM-134", "ECF nao esta pronto.", ERRO)
	::AdicMsgECF("IBM-140", "Cupom Fiscal nao aberto.", ERRO)
	::AdicMsgECF("IBM-141", "Fora do modo de pagamento.", ERRO)
	::AdicMsgECF("IBM-142", "Cupom Fiscal/Nao Fiscal nao pode ser cancelado.", ERRO)
	::AdicMsgECF("IBM-145", "Necess�rio Modo de Interven��o T�cnica.", ERRO)
	::AdicMsgECF("IBM-146", "Inicio de Interven��o Tecnica em curso.", ERRO)
	::AdicMsgECF("IBM-158", "Data e hora nao programadas.", ERRO)
	::AdicMsgECF("IBM-167", "Comando nao aceito com Dia Aberto.", ERRO)
	::AdicMsgECF("IBM-172", "Cupom Fiscal Aberto.", ERRO)
	::AdicMsgECF("IBM-184", "Comprovante Nao Fiscal Aberto.", ERRO)
	::AdicMsgECF("IBM-186", "Nao ha Estorno do meio de pagamento aberto.", ERRO)
	::AdicMsgECF("IBM-187", "Estorno do meio de pagamento aberto.", ERRO)
	::AdicMsgECF("IBM-188", "Impressao de cheque nao esta sendo realizada.", ERRO)
	::AdicMsgECF("IBM-189", "Impressao de cheque esta sendo realizada.", ERRO)
	::AdicMsgECF("IBM-192", "Erro de placa l�gica da impressora.", ERRO)
	::AdicMsgECF("IBM-194", "Erro de posicionamento da cabeca de impressao.", ERRO)
	::AdicMsgECF("IBM-200", "Tampa aberta ou sem papel.", ERRO)
	::AdicMsgECF("IBM-203", "Tampa da estacao de cheque aberta.", ERRO)
	::AdicMsgECF("IBM-204", "Erro interno impressora.", ERRO)
	::AdicMsgECF("IBM-205", "Botao do ECF pressionado.", ERRO)
	::AdicMsgECF("IBM-207", "Problema na geracao do PDF417.", ERRO)
	::AdicMsgECF("IBM-208", "Download Logo/grafico/conjunto de caracteres esta corrompido.", ERRO)
	::AdicMsgECF("IBM-210", "Alavanca automatica esta aberta.", ERRO)
	::AdicMsgECF("IBM-214", "Erro ao avan�ar papel.", ERRO)
	::AdicMsgECF("IBM-235", "Erro na carga da EPROM.", ERRO)       

	
	//RETORNO ST1
	::AdicMsgECF("ST1-128", "Fim de papel.", ERRO)
	::AdicMsgECF("ST1-64", "Pouco papel.", ALERTA)                                        
	::AdicMsgECF("ST1-32", "Erro no rel�gio.", ERRO)
	::AdicMsgECF("ST1-16", "Impressora sem erro.", OK)
	::AdicMsgECF("ST1-8", "Primeiro dado de cmd n�o foi esc(1bh).", ERRO)
	::AdicMsgECF("ST1-4", "Comando inexistente.", ERRO)
	::AdicMsgECF("ST1-2", "Cupom fiscal aberto.", ERRO)
	::AdicMsgECF("ST1-1", "Numero de par�metro de cmd invalido.", ERRO)
	
	//RETORNO ST2
	::AdicMsgECF("ST2-128", "Tipo de par�metro de cmd invalido.", ERRO)
	::AdicMsgECF("ST2-64", "Mem�ria fiscal lotada.", ERRO)
	::AdicMsgECF("ST2-32", "Erro na mem�ria RAM cmos n�o vol�til.", ERRO)
	::AdicMsgECF("ST2-16", "Al�quota n�o programada.", ERRO)
	::AdicMsgECF("ST2-8", "Capacidade de al�quotas esgotadas.", ERRO)
	::AdicMsgECF("ST2-4", "Cancelamento n�o permitido.", ERRO)
	::AdicMsgECF("ST2-2", "CNPJ/ie do propriet�rio n�o programado.", ERRO)
	::AdicMsgECF("ST2-1", "Comando n�o executado.", ERRO)
	
	//RETORNO ST3
	::AdicMsgECF("ST3-0","COMANDO OK", OK)
	::AdicMsgECF("ST3-1","COMANDO INV�LIDO", ERRO)
	::AdicMsgECF("ST3-2","ERRO DESCONHECIDO", ERRO)
	::AdicMsgECF("ST3-3","N�MERO DE PAR�METRO INV�LIDO", ERRO)
	::AdicMsgECF("ST3-4","TIPO DE PAR�METRO INV�LIDO", ERRO)
	::AdicMsgECF("ST3-5","TODAS AL�QUOTAS J� PROGRAMADAS", ERRO)
	::AdicMsgECF("ST3-6","TOTALIZADOR N�O FISCAL J� PROGRAMADO", ERRO)
	::AdicMsgECF("ST3-7","CUPOM FISCAL ABERTO", ERRO)
	::AdicMsgECF("ST3-8","CUPOM FISCAL FECHADO", ERRO)
	::AdicMsgECF("ST3-9","ECF OCUPADO", ERRO)
	::AdicMsgECF("ST3-10","IMPRESSORA EM ERRO", ERRO)
	::AdicMsgECF("ST3-11","IMPRESSORA SEM PAPEL", ERRO)
	::AdicMsgECF("ST3-12","IMPRESSORA COM CABE�A LEVANTADA", ERRO)
	::AdicMsgECF("ST3-13","IMPRESSORA OFF LINE", ERRO)
	::AdicMsgECF("ST3-14","AL�QUOTA N�O PROGRAMADA", ERRO)
	::AdicMsgECF("ST3-15","TERMINADOR DE STRING FALTANDO", ERRO)
	::AdicMsgECF("ST3-16","ACR�SCIMO OU DESCONTO MAIOR QUE O TOTAL DO CUPOM FISCAL", ERRO)
	::AdicMsgECF("ST3-17","CUPOM FISCAL SEM ITEM VENDIDO", ERRO)
	::AdicMsgECF("ST3-18","COMANDO N�O EFETIVADO", ERRO)
	::AdicMsgECF("ST3-19","SEM ESPA�O PARA NOVAS FORMAS DE PAGAMENTO", ERRO)
	::AdicMsgECF("ST3-20","FORMA DE PAGAMENTO N�O PROGRAMADA", ERRO)
	::AdicMsgECF("ST3-21","�NDICE MAIOR QUE N�MERO DE FORMA DE PAGAMENTO", ERRO)
	::AdicMsgECF("ST3-22","FORMAS DE PAGAMENTO ENCERRADAS", ERRO)
	::AdicMsgECF("ST3-23","CUPOM N�O TOTALIZADO", ERRO)
	::AdicMsgECF("ST3-24","COMANDO MAIOR QUE 7Fh (127d)", ERRO)
	::AdicMsgECF("ST3-25","CUPOM FISCAL ABERTO E SEM �TEM", ERRO)
	::AdicMsgECF("ST3-26","CANCELAMENTO N�O IMEDIATAMENTE AP�S", ERRO)
	::AdicMsgECF("ST3-27","CANCELAMENTO J� EFETUADO", ERRO)
	::AdicMsgECF("ST3-28","COMPROVANTE DE CR�DITO OU D�BITO N�O PERMITIDO OU J� EMITIDO", ERRO)
	::AdicMsgECF("ST3-29","MEIO DE PAGAMENTO N�O PERMITE TEF", ERRO)
	::AdicMsgECF("ST3-30","SEM COMPROVANTE N�O FISCAL ABERTO", ERRO)
	::AdicMsgECF("ST3-31","COMPROVANTE DE CR�DITO OU D�BITO J� ABERTO", ERRO)
	::AdicMsgECF("ST3-32","REIMPRESS�O N�O PERMITIDA", ERRO)
	::AdicMsgECF("ST3-33","COMPROVANTE N�O FISCAL J� ABERTO", ERRO)
	::AdicMsgECF("ST3-34","TOTALIZADOR N�O FISCAL N�O PROGRAMADO", ERRO)
	::AdicMsgECF("ST3-35","CUPOM N�O FISCAL SEM �TEM VENDIDO", ERRO)
	::AdicMsgECF("ST3-36","ACR�SCIMO E DESCONTO MAIOR QUE TOTAL CNF", ERRO)
	::AdicMsgECF("ST3-37","MEIO DE PAGAMENTO N�O INDICADO", ERRO)
	::AdicMsgECF("ST3-38","MEIO DE PAGAMENTO DIFERENTE DO TOTAL DO RECEBIMENTO", ERRO)
	::AdicMsgECF("ST3-39","N�O PERMITIDO MAIS DE UMA SANGRIA OU SUPRIMENTO", ERRO)
	::AdicMsgECF("ST3-40","RELAT�RIO GERENCIAL J� PROGRAMADO", ERRO)
	::AdicMsgECF("ST3-41","RELAT�RIO GERENCIAL N�O PROGRAMADO", ERRO)
	::AdicMsgECF("ST3-42","RELAT�RIO GERENCIAL N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-43","MFD N�O INICIALIZADA", ERRO)
	::AdicMsgECF("ST3-44","MFD AUSENTE", ERRO)
	::AdicMsgECF("ST3-45","MFD SEM N�MERO DE S�RIE", ERRO)
	::AdicMsgECF("ST3-46","MFD J� INICIALIZADA", ERRO)
	::AdicMsgECF("ST3-47","MFD LOTADA", ERRO)
	::AdicMsgECF("ST3-48","CUPOM N�O FISCAL ABERTO", ERRO)
	::AdicMsgECF("ST3-49","MEM�RIA FISCAL DESCONECTADA", ERRO)
	::AdicMsgECF("ST3-50","MEM�RIA FISCAL SEM N�MERO DE S�RIE DA MFD", ERRO)
	::AdicMsgECF("ST3-51","MEM�RIA FISCAL LOTADA", ERRO)
	::AdicMsgECF("ST3-52","DATA INICIAL INV�LIDA", ERRO)
	::AdicMsgECF("ST3-53","DATA FINAL INV�LIDA", ERRO)
	::AdicMsgECF("ST3-54","CONTADOR DE REDU��O Z INICIAL INV�LIDO", ERRO)
	::AdicMsgECF("ST3-55","CONTADOR DE REDU��O Z FINAL INV�LIDO", ERRO)
	::AdicMsgECF("ST3-56","ERRO DE ALOCA��O", ERRO)
	::AdicMsgECF("ST3-57","DADOS DO RTC INCORRETOS", ERRO)
	::AdicMsgECF("ST3-58","DATA ANTERIOR AO �LTIMO DOCUMENTO EMITIDO", ERRO)
	::AdicMsgECF("ST3-59","FORA DE INTERVEN��O T�CNICA", ERRO)
	::AdicMsgECF("ST3-60","EM INTERVEN��O T�CNICA", ERRO)
	::AdicMsgECF("ST3-61","ERRO NA MEM�RIA DE TRABALHO", ERRO)
	::AdicMsgECF("ST3-62","J� HOUVE MOVIMENTO NO DIA", ERRO)
	::AdicMsgECF("ST3-63","BLOQUEIO POR RZ", ERRO)
	::AdicMsgECF("ST3-64","FORMA DE PAGAMENTO ABERTA", ERRO)
	::AdicMsgECF("ST3-65","AGUARDANDO PRIMEIRO PROPRIET�RIO", ERRO)
	::AdicMsgECF("ST3-66","AGUARDANDO RZ", ALERTA)
	::AdicMsgECF("ST3-67","ECF OU LOJA IGUAL A ZERO", ERRO)
	::AdicMsgECF("ST3-68","CUPOM ADICIONAL N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-69","DESCONTO MAIOR QUE TOTAL VENDIDO EM ICMS", ERRO)
	::AdicMsgECF("ST3-70","RECEBIMENTO N�O FISCAL NULO N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-71","ACR�SCIMO OU DESCONTO MAIOR QUE TOTAL N�O FISCAL", ERRO)
	::AdicMsgECF("ST3-72","MEM�RIA FISCAL LOTADA PARA NOVO CARTUCHO", ERRO)
	::AdicMsgECF("ST3-73","ERRO DE GRAVA��O NA MF", ERRO)
	::AdicMsgECF("ST3-74","ERRO DE GRAVA��O NA MFD", ERRO)
	::AdicMsgECF("ST3-75","DADOS DO RTC ANTERIORES AO �LTIMO DOC ARMAZENADO", ERRO)
	::AdicMsgECF("ST3-76","MEM�RIA FISCAL SEM ESPA�O PARA GRAVAR LEITURAS DA MFD", ERRO)
	::AdicMsgECF("ST3-77","MEM�RIA FISCAL SEM ESPA�O PARA GRAVAR VERSAO DO SB", ERRO)
	::AdicMsgECF("ST3-78","DESCRI��O IGUAL A DEFAULT N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-79","EXTRAPOLADO N�MERO DE REPETI��ES PERMITIDAS", ERRO)
	::AdicMsgECF("ST3-80","SEGUNDA VIA DO COMPROVANTE DE CR�DITO OU D�BITO N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-81","PARCELAMENTO FORA DA SEQU�NCIA", ERRO)
	::AdicMsgECF("ST3-82","COMPROVANTE DE CR�DITO OU D�BITO ABERTO", ERRO)
	::AdicMsgECF("ST3-83","TEXTO COM SEQU�NCIA DE ESC INV�LIDA", ERRO)
	::AdicMsgECF("ST3-84","TEXTO COM SEQU�NCIA DE ESC INCOMPLETA", ERRO)
	::AdicMsgECF("ST3-85","VENDA COM VALOR NULO", ERRO)
	::AdicMsgECF("ST3-86","ESTORNO DE VALOR NULO", ERRO)
	::AdicMsgECF("ST3-87","FORMA DE PAGAMENTO DIFERENTE DO TOTAL DA SANGRIA", ERRO)
	::AdicMsgECF("ST3-88","REDU��O N�O PERMITIDA EM INTERVEN��O T�CNICA", ERRO)
	::AdicMsgECF("ST3-89","AGUARDANDO RZ PARA ENTRADA EM INTERVEN��O T�CNICA", ERRO)
	::AdicMsgECF("ST3-90","FORMA DE PAGAMENTO COM VALOR NULO N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-91","ACR�SCIMO E DESCONTO MAIOR QUE VALOR DO �TEM", ERRO)
	::AdicMsgECF("ST3-92","AUTENTICA��O N�O PERMITIDA", ERRO)
	::AdicMsgECF("ST3-93","TIMEOUT NA VALIDA��O", ERRO)
	::AdicMsgECF("ST3-94","COMANDO N�O EXECUTADO EM IMPRESSORA BILHETE DE PASSAGEM", ERRO)
	::AdicMsgECF("ST3-95","COMANDO N�O EXECUTADO EM IMPRESSORA DE CUPOM FISCAL", ERRO)
	::AdicMsgECF("ST3-96","CUPOM N�O FISCAL FECHADO", ERRO)
	::AdicMsgECF("ST3-97","PAR�METRO N�O ASCII EM CAMPO ASCII", ERRO)
	::AdicMsgECF("ST3-98","PAR�METRO N�O ASCII NUM�RICO EM CAMPO ASCII NUM�RICO", ERRO)
	::AdicMsgECF("ST3-99","TIPO DE TRANSPORTE INV�LIDO", ERRO)
	::AdicMsgECF("ST3-100","DATA E HORA INV�LIDA", ERRO)
	::AdicMsgECF("ST3-101","SEM RELAT�RIO GERENCIAL OU COMPROVANTE DE CR�DITO OU D�BITO ABERTO", ERRO)
	::AdicMsgECF("ST3-102","N�MERO DO TOTALIZADOR N�O FISCAL INV�LIDO", ERRO)
	::AdicMsgECF("ST3-103","PAR�METRO DE ACR�SCIMO OU DESCONTO INV�LIDO", ERRO)
	::AdicMsgECF("ST3-104","ACR�SCIMO OU DESCONTO EM SANGRIA OU SUPRIMENTO N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-105","N�MERO DO RELAT�RIO GERENCIAL INV�LIDO", ERRO)
	::AdicMsgECF("ST3-106","FORMA DE PAGAMENTO ORIGEM N�O PROGRAMADA", ERRO)
	::AdicMsgECF("ST3-107","FORMA DE PAGAMENTO DESTINO N�O PROGRAMADA", ERRO)
	::AdicMsgECF("ST3-108","ESTORNO MAIOR QUE FORMA PAGAMENTO", ERRO)
	::AdicMsgECF("ST3-109","CARACTER NUM�RICO NA CODIFICA��O GT N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-110","ERRO NA INICIALIZA��O DA MF", ERRO)
	::AdicMsgECF("ST3-111","NOME DO TOTALIZADOR EM BRANCO N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-112","DATA E HORA ANTERIORES AO �LTIMO DOC ARMAZENADO", ERRO)
	::AdicMsgECF("ST3-113","PAR�METRO DE ACR�SCIMO OU DESCONTO INV�LIDO", ERRO)
	::AdicMsgECF("ST3-114","�TEM ANTERIOR AOS TREZENTOS �LTIMOS", ERRO)
	::AdicMsgECF("ST3-115","�TEM N�O EXISTE OU J� CANCELADO", ERRO)
	::AdicMsgECF("ST3-116","C�DIGO COM ESPA�OS N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-117","DESCRICAO SEM CARACTER ALFAB�TICO N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-118","ACR�SCIMO MAIOR QUE VALOR DO �TEM", ERRO)
	::AdicMsgECF("ST3-119","DESCONTO MAIOR QUE VALOR DO �TEM", ERRO)
	::AdicMsgECF("ST3-120","DESCONTO EM ISS N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-121","ACR�SCIMO EM �TEM J� EFETUADO", ERRO)
	::AdicMsgECF("ST3-122","DESCONTO EM �TEM J� EFETUADO", ERRO)
	::AdicMsgECF("ST3-123","ERRO NA MEM�RIA FISCAL CHAMAR CREDENCIADO", ERRO)
	::AdicMsgECF("ST3-124","AGUARDANDO GRAVA��O NA MEM�RIA FISCAL", ERRO)
	::AdicMsgECF("ST3-125","CARACTER REPETIDO NA CODIFICA��O DO GT", ERRO)
	::AdicMsgECF("ST3-126","VERS�O J� GRAVADA NA MEM�RIA FISCAL", ERRO)
	::AdicMsgECF("ST3-127","ESTOURO DE CAPACIDADE NO CHEQUE", ERRO)
	::AdicMsgECF("ST3-128","TIMEOUT NA LEITURA DO CHEQUE", ERRO)
	::AdicMsgECF("ST3-129","M�S INV�LIDO", ERRO)
	::AdicMsgECF("ST3-130","COORDENADA INV�LIDA", ERRO)
	::AdicMsgECF("ST3-131","SOBREPOSI��O DE TEXTO", ERRO)
	::AdicMsgECF("ST3-132","SOBREPOSI��O DE TEXTO NO VALOR", ERRO)
	::AdicMsgECF("ST3-133","SOBREPOSI��O DE TEXTO NO EXTENSO", ERRO)
	::AdicMsgECF("ST3-134","SOBREPOSI��O DE TEXTO NO FAVORECIDO", ERRO)
	::AdicMsgECF("ST3-135","SOBREPOSI��O DE TEXTO NA LOCALIDADE", ERRO)
	::AdicMsgECF("ST3-136","SOBREPOSI��O DE TEXTO NO OPCIONAL", ERRO)
	::AdicMsgECF("ST3-137","SOBREPOSI��O DE TEXTO NO DIA", ERRO)
	::AdicMsgECF("ST3-138","SOBREPOSI��O DE TEXTO NO M�S", ERRO)
	::AdicMsgECF("ST3-139","SOBREPOSI��O DE TEXTO NO ANO", ERRO)
	::AdicMsgECF("ST3-140","USANDO MFD DE OUTRO ECF", ERRO)
	::AdicMsgECF("ST3-141","PRIMEIRO DADO DIFERENTE DE ESC OU 1C", ERRO)
	::AdicMsgECF("ST3-142","N�O PERMITIDO ALTERAR SEM INTERVEN��O T�CNICA", ERRO)
	::AdicMsgECF("ST3-143","DADOS DA �LTIMA RZ CORROMPIDOS", ERRO)
	::AdicMsgECF("ST3-144","COMANDO N�O PERMITIDO NO MODO INICIALIZA��O", ERRO)
	::AdicMsgECF("ST3-145","AGUARDANDO ACERTO DE REL�GIO", ERRO)
	::AdicMsgECF("ST3-146","MFD J� INICIALIZADA PARA OUTRA MF", ERRO)
	::AdicMsgECF("ST3-147","AGUARDANDO ACERTO DO REL�GIO OU DESBLOQUEIO PELO TECLADO", ERRO)
	::AdicMsgECF("ST3-148","VALOR FORMA DE PAGAMENTO MAIOR QUE M�XIMO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-149","RAZ�O SOCIAL EM BRANCO", ERRO)
	::AdicMsgECF("ST3-150","NOME DE FANTASIA EM BRANCO", ERRO)
	::AdicMsgECF("ST3-151","ENDERE�O EM BRANCO", ERRO)
	::AdicMsgECF("ST3-152","ESTORNO DE CDC N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-153","DADOS DO PROPRIET�RIO IGUAIS AO ATUAL", ERRO)
	::AdicMsgECF("ST3-154","ESTORNO DE FORMA DE PAGAMENTO N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-155","DESCRI��O FORMA DE PAGAMENTO IGUAL J� PROGRAMADA", ERRO)
	::AdicMsgECF("ST3-156","ACERTO DE HOR�RIO DE VER�O S� IMEDIATAMENTE AP�S RZ", ERRO)
	::AdicMsgECF("ST3-157","IT N�O PERMITIDA MF RESERVADA PARA RZ", ERRO)
	::AdicMsgECF("ST3-158","SENHA CNPJ INV�LIDA", ERRO)
	::AdicMsgECF("ST3-159","TIMEOUT NA INICIALIZA��O DA NOVA MF", ERRO)
	::AdicMsgECF("ST3-160","N�O ENCONTRADO DADOS NA MFD", ERRO)
	::AdicMsgECF("ST3-161","SANGRIA OU SUPRIMENTO DEVEM SER �NICOS NO CNF", ERRO)
	::AdicMsgECF("ST3-162","�NDICE DA FORMA DE PAGAMENTO NULO N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-163","UF DESTINO INV�LIDA", ERRO)
	::AdicMsgECF("ST3-164","TIPO DE TRANSPORTE INCOMPAT�VEL COM UF DESTINO", ERRO)
	::AdicMsgECF("ST3-165","DESCRI��O DO PRIMEIRO �TEM DO BILHETE DE PASSAGEM DIFERENTE DE TARIFA", ERRO)
	::AdicMsgECF("ST3-166","AGUARDANDO IMPRESS�O DE CHEQUE OU AUTENTICA��O", ERRO)
	::AdicMsgECF("ST3-167","N�O PERMITIDO PROGRAMA�AO CNPJ IE COM ESPA�OS EM BRANCO", ERRO)
	::AdicMsgECF("ST3-168","N�O PERMITIDO PROGRAMA��O UF COM ESPA�OS EM BRANCO", ERRO)
	::AdicMsgECF("ST3-169","N�MERO DE IMPRESS�ES DA FITA DETALHE NESTA INTERVEN��O T�CNICA ESGOTADO", ERRO)
	::AdicMsgECF("ST3-170","CF J� SUBTOTALIZADO", ERRO)
	::AdicMsgECF("ST3-171","CUPOM N�O SUBTOTALIZADO", ERRO)
	::AdicMsgECF("ST3-172","ACR�SCIMO EM SUBTOTAL J� EFETUADO", ERRO)
	::AdicMsgECF("ST3-173","DESCONTO EM SUBTOTAL J� EFETUADO", ERRO)
	::AdicMsgECF("ST3-174","ACR�SCIMO NULO N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-175","DESCONTO NULO N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-176","CANCELAMENTO DE ACR�SCIMO OU DESCONTO EM SUBTOTAL N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-177","DATA INV�LIDA", ERRO)
	::AdicMsgECF("ST3-178","VALOR DO CHEQUE NULO N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-179","VALOR DO CHEQUE INV�LIDO", ERRO)
	::AdicMsgECF("ST3-180","CHEQUE SEM LOCALIDADE N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-181","CANCELAMENTO ACR�SCIMO EM �TEM N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-182","CANCELAMENTO DESCONTO EM �TEM N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-183","N�MERO M�XIMO DE �TENS ATINGIDO", ERRO)
	::AdicMsgECF("ST3-184","N�MERO DE �TEM NULO N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-185","MAIS QUE DUAS AL�QUOTAS DIFERENTES NO BILHETE DE PASSAGEM N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-186","ACR�SCIMO OU DESCONTO EM ITEM N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-187","CANCELAMENTO DE ACR�SCIMO OU DESCONTO EM ITEM N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-188","CLICHE J� IMPRESSO", ERRO)
	::AdicMsgECF("ST3-189","TEXTO OPCIONAL DO CHEQUE EXCEDEU O M�XIMO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-190","IMPRESS�O AUTOM�TICA NO VERSO N�O PERMITIDO NESTE EQUIPAMENTO", ERRO)
	::AdicMsgECF("ST3-191","TIMEOUT NA INSER��O DO CHEQUE", ERRO)
	::AdicMsgECF("ST3-192","OVERFLOW NA CAPACIDADE DE TEXTO DO COMPROVANTE DE CR�DITO OU D�BITO", ERRO)
	::AdicMsgECF("ST3-193","PROGRAMA��O DE ESPA�OS ENTRE CUPONS MENOR QUE O M�NIMO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-194","EQUIPAMENTO N�O POSSUI LEITOR DE CHEQUE", ERRO)
	::AdicMsgECF("ST3-195","PROGRAMA��O DE AL�QUOTA COM VALOR NULO N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-196","PAR�METRO BAUD RATE INV�LIDO", ERRO)
	::AdicMsgECF("ST3-197","CONFIGURA��O PERMITIDA SOMENTE PELA PORTA DOS FISCO", ERRO)
	::AdicMsgECF("ST3-198","VALOR TOTAL DO ITEM EXCEDE 11 D�GITOS", ERRO)
	::AdicMsgECF("ST3-199","PROGRAMA��O DA MOEDA COM ESPA�OS EM BRACO N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-200","CASAS DECIMAIS DEVEM SER PROGRAMADAS COM 2 OU 3", ERRO)
	::AdicMsgECF("ST3-201","N�O PERMITE CADASTRAR USU�RIOS DIFERENTES NA MESMA MFD", ERRO)
	::AdicMsgECF("ST3-202","IDENTIFICA��O DO CONSUMIDOR N�O PERMITIDA PARA SANGRIA OU SUPRIMENTO", ERRO)
	::AdicMsgECF("ST3-203","CASAS DECIMAIS EM QUANTIDADE MAIOR DO QUE A PERMITIDA", ERRO)
	::AdicMsgECF("ST3-204","CASAS DECIMAIS DO UNIT�RIO MAIOR DO QUE O PERMITIDA", ERRO)
	::AdicMsgECF("ST3-205","POSI��O RESERVADA PARA ICMS", ERRO)
	::AdicMsgECF("ST3-206","POSI��O RESERVADA PARA ISS", ERRO)
	::AdicMsgECF("ST3-207","TODAS AS AL�QUOTAS COM A MESMA VINCULA��O N�O PERMITIDO", ERRO)
	::AdicMsgECF("ST3-208","DATA DE EMBARQUE ANTERIOR A DATA DE EMISS�O", ERRO)
	::AdicMsgECF("ST3-209","AL�QUOTA DE ISS N�O PERMITIDA SEM INSCRI��O MUNICIPAL", ERRO)
	::AdicMsgECF("ST3-210","RETORNO PACOTE CLICHE FORA DA SEQU�NCIA", ERRO)
	::AdicMsgECF("ST3-211","ESPA�O PARA ARMAZENAMENTO DO CLICHE ESGOTADO", ERRO)
	::AdicMsgECF("ST3-212","CLICHE GR�FICO N�O DISPON�VEL PARA CONFIRMA��O", ERRO)
	::AdicMsgECF("ST3-213","CRC DO CLICHE GR�FICO DIFERENTE DO INFORMADO", ERRO)
	::AdicMsgECF("ST3-214","INTERVALO INV�LIDO", ERRO)
	::AdicMsgECF("ST3-215","USU�RIO J� PROGRAMADO", ERRO)
	::AdicMsgECF("ST3-217","DETECTADA ABERTURA DO EQUIPAMENTO", ERRO) 
	::AdicMsgECF("ST3-218","CANCELAMENTO DE ACR�SCIMO/DESCONTO N�O PERMITIDO", ERRO)

	 
Return Nil 



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura e preenchimento dos dados   ���
���          �do usuario cadastrado na impressora.			  		  	  		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  		     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeDadoUsu() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cCNPJ  	:= Space(20)	//String que receber o CNPj
	Local cIE  		:= Space(20)	//String que receber a IE
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_CNPJ_IE", cCNPJ, cIE})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)

	// Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao <> ERRO)    	
		::cCnpj := AllTrim(oParams:Elements(3):cParametro)	// Copia o C.N.P.J da impressora
		::cIE := AllTrim(oParams:Elements(4):cParametro) 	// Copia o I.E da impressora
	EndIf
    	
Return oRetorno 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do modelo do ECF   		  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  		     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeModelo() Class LJAIBM 

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cModelo  := Space(10)	//String que receber os dados da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_ModeloImpressora", cModelo})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao <> ERRO)    	
		::cModelo := AllTrim(oParams:Elements(3):cParametro)		// Copia o Numero de serie da impressora	
	EndIf
	
Return oRetorno


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do modelo do ECF   		  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeFrmWare() Class LJAIBM 

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cFrmWare  := Space(6)	//String que receber os dados da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VersaoFirmwareMFD", cFrmWare})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao <> ERRO)    	
		::cFirmWare := AllTrim(oParams:Elements(3):cParametro)		// Copia o Numero de serie da impressora	
	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura da Inscricao Municiapal 	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeInscMun() Class LJAIBM 

	Local oParams 	:= Nil		 //Objeto para passagem dos parametros
	Local cRetorno := ""			 //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		 //Objeto que sera retornado pela funcao	
	Local cInsMun  := Space(20) //String que receber os dados da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_InscricaoMunicipalMFD", cInsMun})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao <> ERRO)    	
		::cIM := AllTrim(oParams:Elements(3):cParametro)		// Copia o Numero de serie da impressora	
	EndIf
	
Return oRetorno          


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura e preenchimento dos dados   ���
���          �cadastrados na impressora.			  		  			  			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeDadImp() Class LJAIBM
	
	Local oParams 	:= Nil			 //Objeto para passagem dos parametros
	Local cRetorno := ""			 //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		 //Objeto que sera retornado pela funcao	
	Local cNserie  := Space(20) //String que receber os dados da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_NumeroSerieMFD", cNserie})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
   If(oRetorno:cAcao <> ERRO)    	
		::cNrSerie := AllTrim(oParams:Elements(3):cParametro)		// Copia o Numero de serie da impressora
		
		//Efetua o corte em 20 caracteres pois pode vir uma sujeira e gerar problema na valida��o do LOJA420
		::cNrSerie := SubStr(::cNrSerie,1,20)
	
		::cFabric := AllTrim(substr(oParams:Elements(3):cParametro, 1, 2))		// Copia o Fabricante da impressora, verificar.
	EndIf
	
Return oRetorno
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura e preenchimento do cliche   ���
���          �cadastrado na impressora.				  		 	 		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeCliche() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(186)	//String que receber o cliche da impressora
	//Local aDados 	:= {}
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_ClicheProprietario", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao <> ERRO)    	 
        
    	
    	//aDados := strtokarr(oParams:Elements(3):cParametro, chr(13)+chr(10))	
    	
		::cRazaoSoc  := AllTrim(Left(oParams:Elements(3):cParametro, 48))			// Copia Razao Social da impressora
		//oParams:Elements(3):cParametro := Alltrim(Substr( oParams:Elements(3):cParametro, At(oParams:Elements(3):cParametro, " ") ) )
		::cFantasia  := AllTrim(Substr(oParams:Elements(3):cParametro, 49, 48)	)			   // Copia o Nome Fantasia da impressora
		::cEndereco1 := AllTrim(Substr(oParams:Elements(3):cParametro, 97, 48)	)	   // Copia o Endereco 1 da impressora
		::cEndereco2 := AllTrim(Substr(oParams:Elements(3):cParametro, 146) )		// Copia o Endereco 2 da impressora
	
	EndIf	 
	
Return oRetorno
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura e preenchimento do nome do  ���
���          �operador cadastrado na impressora.				  		  		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/      

Method LeOperador() Class LJAIBM 

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
   
		//IBM NAO TEM FUNCAO QUE RETORNA O OPERADOR CADASTRADO NA IMPRESSORA
    	oRetorno    := ::TratarRet("0000")
		::cOperador := ""			// Copia o nome do operador da impressora

Return oRetorno         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do numero da loja 		  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeNumLoja() Class LJAIBM	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cLoja  	:= Space(4)		//String que receber o numero da loja e do ECF
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_NumeroLoja", cLoja})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao <> ERRO)    	
    	::cLoja := AllTrim(oParams:Elements(3):cParametro)		// Copia o numero da Loja
	EndIf	
	
Return oRetorno 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do numero do ECF   		  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  		     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeECFLoja() Class LJAIBM	
	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cNCaixa  := Space(4)	//String que receber o numero da loja e do ECF
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_NumeroCaixa", cNCaixa})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)

    If(oRetorno:cAcao <> ERRO) 
	  	::cNumEcf := ::CorrigRet(oParams:Elements(3):cParametro)	// Copia o numero do ECF
    EndIF

	
Return oRetorno 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do valor percentual da 	  ���
���          �aliquotas.												  			     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeAliq() Class LJAIBM
	
	Local oParams 		:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados1  	:= Space(79)	//String que receber a tabela de aliquotas cadastradas no ECF
	Local cDados2  	:= Space(48)	//String que receber o indice das aliquotas cadastradas no ECF ISS
	Local aDados  		:= {}				//Array que receber� todas as aliquotas da string de retorno 
	Local cSimbolo  	:= Nil			//String que retorna o simbolo da aliquota - Nao tem funcao que retorne o simbolo
	Local cIndAliqISS := Nil			//String que receber� as aliquotas de ISS
	Local nDx 			:= 0


	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_RetornoAliquotas", cDados1})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	 
    
	    //Todas as aliquotas cadastradas serao retornadas com "," como delimitador  
	    aDados := strtokarr(oParams:Elements(3):cParametro, ",")
	         
	    	//Verfico as aliqutoas de ISS
		   	//Prepara os parametros de envio 
			oParams := ::PrepParam({IBM, "IBM_FI_VerificaIndiceAliquotasIss", cDados2})
		
	    	//Envia o comando    	
			cRetorno := ::EnviarCom(oParams)
			
			//Obtem o Estado da impressora
			cRetorno := ::ObterEst(cRetorno)
			
		    //Trata o retorno    
		    oRetorno := ::TratarRet(cRetorno)    
		    
		    If(oRetorno:cAcao <> ERRO) 
		    
			    cIndAliqISS := AllTrim(oParams:Elements(3):cParametro)
			                           
    			For nDX := 1 To Len(aDados)
	    
	    	    	 cValor   :=  AllTrim(aDados[nDX]) 
	    	    	 //indice sequencial
	    	    	 cSimbolo := strzero(nDX, 2, 0)
	    	    	 
	    	    	 If (cSimbolo $ cIndAliqISS)
						::AdicAliq(cSimbolo,Val(cValor) / 100, .T.) //Por enquanto insiro como ISS
					 Else
						::AdicAliq(cSimbolo,Val(cValor) / 100, .F.) //Por enquanto insiro como ICMS	    	    	 
			    	 EndIf  
	    	    	 
	    		Next nDX
	   	 EndIf
	    
	EndIf	
	
Return oRetorno  


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura e preenchimento da tabela   ���
���          �de totalizadores nao fiscais cadastrados na impressora.	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeTotNF() Class LJAIBM
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros.
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial.
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao.
	Local cDados  	:= Space(599)	//String que receber a tabela de Totalizadores Nao Fiscais.
	Local nDX		:= 1				//Contador utilizado no comando "For".
	Local aDados	:= {}				//String temporaria para armazenamento do indice do totalizador.
	Local cIndice 	:= 0

	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresNaoFiscaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao <> ERRO)    
		
		//Transformo em array os dados de retorno    
	    aDados := strtokarr(oParams:Elements(3):cParametro, ",")
    	 
    	//Para cada totalizados, seleciono o valor e insiro na tabela
   	For nDX := 1 To Len(aDados)   
    	     
	    	If( Alltrim(aDados[nDX]) != "")				
		    	
		    	cIndice := strzero(nDX, 2, 0)
				::AdicTotNf(cIndice,aDados[nDX],"E","") //Insere o totalizador nao fiscal na tabela.
				
			EndIf    
    	
		Next nDX    	
		
	EndIf      
	
Return oRetorno 
/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11     ���
����������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura e preenchimento da tabela   	  ���
���          �de relatorios gerenciais cadastrados na impressora.		  	 	  ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	 	  ���
����������������������������������������������������������������������������͹��
���Parametros�nenhum												  		 				     ���
����������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  	 			  ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Method LeRelGer() Class LJAIBM
	Local oParams 	 := Nil			//Objeto para passagem dos parametros
	Local cRetorno  := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno  := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	 := Space(659)	//String que receber a tabela de relatorios gerenciais cadastradas no ECF
	Local nDX		 := 1				//Contador utilizado no comando "For"
	Local cIndice	 := 0				//String temporaria para armazenamento do indice do relatorio
	Local cDesc		 := Space(17)	//String temporaria para armazenamento da descricao do relatorio
	Local cContador := Space(4)	//String temporaria para armazenamento do contador de emissao do relatorio 
	Local aDados 	 := {}
		    	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaRelatorioGerencialMFD", cDados})
	
    //Envia o comando
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno
    oRetorno := ::TratarRet(cRetorno)

	// Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao <> ERRO)    	
    	
    	//Transformo em array os dados de retorno    
	    aDados := strtokarr(oParams:Elements(3):cParametro, ",")
    	 
    	//Para cada totalizados, seleciono o valor e insiro na tabela
    	For nDX := 1 To Len(aDados)   
    	
    		cDesc     := AllTrim(substr(aDados[nDX], 5))
    	    cContador := AllTrim(substr(aDados[nDX], 1, 4))
    	    
	    	//Caso a descricao seja preenchida
			If( AllTrim(cDesc) != "") 
	
				cIndice := strzero(nDX, 2, 0)
				::AdicGerenc(cIndice,cDesc)		//Insere o relatorio gerencial na tabela.
				
			EndIf   
			
		Next nDX    	 	
		
	EndIf
Return oRetorno 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura e preenchimento da tabela   ���
���          �de finalizadoras cadastradas na impressora.				  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                                                                   
Method LeFinaliz() Class LJAIBM
	Local oParams 	  := Nil				//Objeto para passagem dos parametros
	Local cRetorno   := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno   := Nil				//Objeto que sera retornado pela funcao	
	Local cDados  	  := Space(3016)	//String que receber a tabela de finalizadoras cadastradas no ECF
	Local nDX		  := 1				//Contador utilizado no comando "For"
	Local cIndice	  := 0				//String temporaria para armazenamento do indice da finalizadora
	Local cDesc		  := Space(16)		//String temporaria para armazenamento da descricao da finalizadora
	Local cVendido	  := Space(14)		//String temporaria para armazenamento do valor recebido pela finalizadora
	Local cVinculado := Space(1)		//String temporaria para armazenamento da indicacao de finalizadora vinculada TEF
	Local aDados  	  := {}
		    	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaFormasPagamentoMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno                                   
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
    
    	//Transformo em array os dados de retorno    
	    aDados := strtokarr(oParams:Elements(3):cParametro, ",") 
    	 
    	//Para cada totalizados, seleciono o valor e insiro na tabela
    	For nDX := 1 To Len(aDados)   
    	                                          
    		  
    	    cDesc      := AllTrim(substr(aDados[nDX], 1, 16))
    	    cVendido   := AllTrim(substr(aDados[nDX], 31, 14))                    
    	    cVinculado := AllTrim(substr(aDados[nDX], 45)) 

    	    //Caso a descricao seja preenchida
    	    If(AllTrim(cDesc) != "")    

				cIndice := strzero(nDX, 2, 0)
				
				If cVinculado == "1" 				
					::AdicForma(cIndice,cDesc,.T.)		//Insere a finalizadora vinculada na tabela.
				Else
					::AdicForma(cIndice,cDesc,.F.)		//Insere a finalizadora NAO vinculada na tabela.
				EndIF
				
			EndIf

		Next nDX    	 	
	EndIf
Return oRetorno 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeDataJor �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura da data de abertura da	  	  ���
���          �jornada.													  				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf contendo a data e hora do movimento do ���
���			 �ecf no formato dd/mm/aaaa hh:mm:SS (19 bytes)				  	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeDataJor() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cData  	:= Space(6)		//String que recebera a data de abertura da jornada
	Local cHora  	:= Space(6)		//String que recebera a hora de abertura da jornada
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_DataHoraImpressora", cData, cHora})
	
	 //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
	//Trata o retorno                                 
    oRetorno := ::TratarRet(cRetorno)
   
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	

		oRetorno:oRetorno := substr((oParams:Elements(3):cParametro), 1,2)  + "/" +;
									substr((oParams:Elements(3):cParametro), 3,2)  + "/" +;
									"20" + substr((oParams:Elements(3):cParametro), 5,2)  + " " +;
									substr((oParams:Elements(4):cParametro), 1,2)  + ":" +;
									substr((oParams:Elements(4):cParametro), 3,2)  + ":" +;
									substr((oParams:Elements(4):cParametro), 5,2)


	EndIf
	
Return oRetorno
  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do GT da impressora.		  ���
���          �															  					  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeGT() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(18)	//String que recebera GT da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_GrandeTotal", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := Substr(oParams:Elements(3):cParametro,1,18)
	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do ultimo COO impresso.     ���
���          � 															  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                 	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf									      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeCOO() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cCOOIni  := Space(6)		//String que recebera o contador inicial
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_NumeroCupom", cCOOIni})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	                                                  
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := AllTrim(oParams:Elements(3):cParametro)
	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeTotCanc �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio dos    		  ���
���          �cancelamentos executados na impressora ( ICMS + ISS )  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeTotCanc() Class LJAIBM
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""		  		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que recebera os totais cancelados da impressora
	Local aDados 	:= {}				//Array que recebera a string delimitada por ","
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)
	    aDados := strtokarr(oParams:Elements(3):cParametro, ",")
		oRetorno:oRetorno :=	Val(aDados[10]) / 100   //ICMS
	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeTotCanc �Autor  �Vendas Clientes     � Data �  17/06/13  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio dos    		  ���
���          �cancelamentos executados na impressora ( ISS )  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
���������������������������������������������������������������������������*/
Method LeTotCanIss() Class LJAIBM
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""		  		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que recebera os totais cancelados da impressora
	Local aDados 	:= {}				//Array que recebera a string delimitada por ","
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)
		aDados := strtokarr(oParams:Elements(3):cParametro, ",")
		oRetorno:oRetorno :=	Val(aDados[13]) / 100     //ISSQN
	EndIf
	
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �LeTotDesc �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio dos    		  ���
���          �descontos executados na impressora ( ICMS + ISS )  	  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method LeTotDesc() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que recebera os totais de desconto da impressora 
	Local aDados 	:= {}          //Array que recebera a string delimitada por ","
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	

	 	aDados := strtokarr(oParams:Elements(3):cParametro, ",")	
	
		oRetorno:oRetorno :=	Val(aDados[08]) / 100   //ICMS
	EndIf

Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �LeTotDesIss �Autor  �Vendas Clientes     � Data �  17/06/13 ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio dos    		  ���
���          �descontos executados na impressora ( ISS )  	  	  	      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										 ���
���������������������������������������������������������������������������*/
Method LeTotDesIss() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que recebera os totais de desconto da impressora 
	Local aDados 	:= {}          //Array que recebera a string delimitada por ","
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)
	 	aDados := strtokarr(oParams:Elements(3):cParametro, ",")
		oRetorno:oRetorno :=	Val(aDados[11]) / 100     //ISSQN
	EndIf

Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �LeTotIsent�Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio das vendas	  ���
���          �Isentas executadas na impressora ( I + IS )  				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	 ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method LeTotIsent() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que receber a tabela de aliquotas cadastradas no ECF
	Local aDados 	:= {}          //Array que recebera a string delimitada por ","
		
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno                                                       
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	

	 	aDados := strtokarr(oParams:Elements(3):cParametro, ",")	
	
		oRetorno:oRetorno :=	Val(aDados[02]) / 100 +;   //Isencao ICMS
							 	Val(aDados[05]) / 100     //Isencao ISSQN
	EndIf
	

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeTotNTrib�Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio dos    		  ���
���          �nao tributados vendidos na impressora ( ICMS + ISS  )  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeTotNTrib() Class LJAIBM
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que receber a tabela de aliquotas cadastradas no ECF  
	Local aDados    := {}           //Array contendo os dados da impressora
		
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)   
                                   
    	aDados := strtokarr(oParams:Elements(3):cParametro, ",")
    	oRetorno:oRetorno :=  Val(aDados[03]) / 100 +;   //ICMS
							 	Val(aDados[06]) / 100     //ISSQN
       				
	EndIf

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeTotIss  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio dos    		  ���
���          �cancelamentos executados na impressora ( ICMS + ISS + NF )  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeTotIss() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que recebera os totais de desconto da impressora    
	Local cTotal    := ""           
	Local aArrVlr   := {}    
	Local nDx		:= 0 
	Local aArrAli   := {}
	Local cIndAliqISS := {}    
	Local nTotISS   := 0   
	
	
	//Tabela de totalizadores parciais		                                    
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)  
    
	     cTotal := substr(Alltrim(oParams:Elements(3):cParametro), 1, 224)
		  aArrVlr := {}   
		   
		   For nDx := 1 To 224 Step 14
		   	aAdd(aArrVlr, Val(SubStr(cTotal, nDx, 14)))
		   Next	                                          
    
		    //Todas as aliquotas cadastradas serao retornadas com "," como delimitador  
	  		//Prepara os parametros de envio 
	  		cDados := space(79)
			oParams := ::PrepParam({IBM, "IBM_FI_RetornoAliquotas", cDados})
		
		   //Envia o comando    	
			cRetorno := ::EnviarCom(oParams)
		
			//Obtem o Estado da impressora
			cRetorno := ::ObterEst(cRetorno)
		
		    //Trata o retorno    
		    oRetorno := ::TratarRet(cRetorno)

		   If(oRetorno:cAcao <> ERRO) 
		  
		  		aArrAli := strtokarr(AllTrim(oParams:Elements(3):cParametro), ",")
		    
			    
	   	 	//Verfico as aliqutoas de ISS para serem descartadas
			   //Prepara os parametros de envio      
			    cDados := space(79)
				oParams := ::PrepParam({IBM, "IBM_FI_VerificaIndiceAliquotasIss", cDados})
		
		    	//Envia o comando    	
				cRetorno := ::EnviarCom(oParams)
				
				//Obtem o Estado da impressora
				cRetorno := ::ObterEst(cRetorno)
				
			    //Trata o retorno                                 
			    oRetorno := ::TratarRet(cRetorno)  
		    
		    
		    	If(oRetorno:cAcao <> ERRO) 
		    
			    	cIndAliqISS := AllTrim(oParams:Elements(3):cParametro)
			                           
    		  			For nDX := 1 To Len(aArrAli)
    			    
		    			    If Val(aArrAli[nDx]) == 0 .Or. !StrZero(nDX, 2) $ cIndAliqISS
		    			    	Loop
		    			    EndIf
	    
							nTotISS += aArrVlr[nDx]/100
	    	  			Next nDX
	   	 	     EndIf

  			EndIf	 
  			                                             
    EndIf                                                  

    oRetorno:oRetorno := nTotISS
	
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �LeVndLiq  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio dos    		  ���
���          �cancelamentos executados na impressora ( ICMS + ISS + NF )  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method LeVndLiq() Class LJAIBM                                          
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
Local nVB 	:= 0
Local nDesc := 0
Local nCanc := 0
Local nVIss := 0
Local nCanIss := 0
Local nDesIss := 0
	
oRetorno := ::LeVndBrut()

If(oRetorno:cAcao == OK)
	nVB := oRetorno:oRetorno
	oRetorno := ::LeTotCanc()
EndIf

If(oRetorno:cAcao == OK)
	nCanc := oRetorno:oRetorno
	oRetorno := ::LeTotIss()
EndIf

If(oRetorno:cAcao == OK)
	nVIss := oRetorno:oRetorno
	oRetorno := ::LeTotDesc()
EndIf

If(oRetorno:cAcao == OK)
	nDesc := oRetorno:oRetorno
	oRetorno := ::LeTotDesISS()
EndIf

If(oRetorno:cAcao == OK)
	nDesIss := oRetorno:oRetorno 
	oRetorno:= ::LeTotCanISS()
EndIf

If oRetorno:cAcao == OK
	nCanIss := oRetorno:oRetorno
	oRetorno:oRetorno := nVB - nDesc - nCanc - nVIss - nDesIss - nCanIss
EndIf
		
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeVndBrut �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura da Venda Bruta Atual.		  ���
���          �															  				     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  				     ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  		     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeVndBrut() Class LJAIBM	

	Local oParams 	:= Nil		 //Objeto para passagem dos parametros
	Local cRetorno := ""			 //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		 //Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(18) //String que recebera a venda bruta atual da impressora

	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VendaBruta", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := Val(Substr(oParams:Elements(3):cParametro,1,18)) / 100
	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA1336_ �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura da Venda Bruta Atual.		  ���
���          �															  					  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  				     ���
�������������������������������������������������������������������������͹��
���Retorno   �Numerico		    										  			     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  

Method LeFaseCP() Class LJAIBM	

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
	
Return oRetorno
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetCancIt �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar se pode cancelar todos os 	  ���
���          �itens														  				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetCancIt() Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := "TODOS"

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetVlSupr �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar o valor do suprimento   	  ���
���          �itens														  				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  				     ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetVlSupr()  Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
     oRetorno:oRetorno := 0
   	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetItImp  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar se todos os itens foram   	  ���
���          �impressos													  				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  				     ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetItImp() Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
   	oRetorno:oRetorno := .T.
   	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetPosFunc�Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar se ecf retorna o Subtotal e o���
���          �numero de itens impressos no cupom fiscal.				  		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetPosFunc() Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
 	 oRetorno:oRetorno := .F.
   	
Return oRetorno   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetPathMFD�Autor  �Vendas Clientes     � Data �  10/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar o caminho e nome do arquivo  ���
���          �de Memoria Fita Detalhe.                   				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetPathMFD() Class LJAIBM

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
   	oRetorno:oRetorno := ::cPathMFD //Copia o valor da propriedade da classe
   	
Return oRetorno  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetPathMF �Autor  �Vendas Clientes     � Data �  10/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar o caminho e nome do arquivo  ���
���          �de Memoria Fiscal.		                   				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetPathMF() Class LJAIBM

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
   	oRetorno:oRetorno := ::cPathMF  //Copia o valor da propriedade da classe
   	
Return oRetorno   

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �GetPathTipoE �Autor  �Vendas Clientes     � Data �  21/07/10   ���
����������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar o caminho e nome do arquivo  	 ���
���          �registro Tipo E Ato Cotepe 17/04 PAF-ECF.		   			  	 ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	 ���
����������������������������������������������������������������������������͹��
���Parametros�nenhum													  	 ���
����������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  	 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Method GetPathTipoE(cBinario) Class LJAIBM

	Local oRetorno 	:= Nil			 		//Objeto que sera retornado pela funcao
	
	Default cBinario := "0"
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
   	oRetorno:oRetorno := ::cPathMF + IIF(cBinario <> "1", "COTEPE1704.txt", "download.bin")				 	//Copia o valor da propriedade da classe
   	
Return oRetorno   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetLetMem �Autor  �Vendas Clientes     � Data �  10/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a letra indicativa de MF adicional  				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetLetMem() Class LJAIBM

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0000")
    
   	oRetorno:oRetorno := " "			 //Copia o valor da propriedade da classe

Return oRetorno
    
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetTipEcf	�Autor  �Vendas Clientes     � Data �  10/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna Tipo de ECF  										  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetTipEcf() Class LJAIBM

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0000")
    
    oRetorno:oRetorno := "ECF-IF"			 //Copia o valor da propriedade da classe

Return oRetorno
    
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetDatSW	�Autor  �Vendas Clientes     � Data �  10/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a Data de instalacao da versao atual do Software    ���
���          �B�sico gravada na Memoria Fiscal do ECF.    				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetDatSW() Class LJAIBM

	Local oParams 	:= Nil		 //Objeto para passagem dos parametros
	Local cRetorno := ""			 //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		 //Objeto que sera retornado pela funcao	
	Local cDados1  	:= Space(06) //String que recebera a Data/Hora Usu�rio
	Local cDados2  	:= Space(06) //String que recebera a Data/Hora SW

	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_DataHoraSoftwareBasico", cDados1,cDados2})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := PadR(oParams:Elements(3):cParametro,10)
	EndIf
	
Return oRetorno
    
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetHorSW	�Autor  �Vendas Clientes     � Data �  10/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a Hora de instalacao da versao atual do Software    ���
���          �B�sico gravada na Memoria Fiscal do ECF.    				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetHorSW() Class LJAIBM

	Local oParams 	:= Nil		 //Objeto para passagem dos parametros
	Local cRetorno := ""			 //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		 //Objeto que sera retornado pela funcao	
	Local cDados1  	:= Space(06) //String que recebera a Data/Hora Usu�rio
	Local cDados2  	:= Space(06) //String que recebera a Data/Hora SW

	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_DataHoraSoftwareBasico", cDados1,cDados2})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := oParams:Elements(4):cParametro

	EndIf
	
Return oRetorno
	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetGrTIni �Autor  �Vendas Clientes     � Data �  10/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o Grande total incicial							  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetGrTIni() Class LJAIBM

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0000")
    
   	oRetorno:oRetorno := ""			 //Copia o valor da propriedade da classe
   	
Return oRetorno  
	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetNumCnf �Autor  �Vendas Clientes     � Data �  10/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o Contador Geral de Opera��o N�o Fiscal			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetNumCnf() Class LJAIBM
  
	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(6)	//String que recebera a status do horario de verao
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_NumeroOperacoesNaoFiscais ", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := substr(oParams:Elements(3):cParametro, 1, 6)
	EndIf
    


Return oRetorno  
	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetNumCrg �Autor  �Vendas Clientes     � Data �  10/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o Contador Geral de Relat�rio Gerencial			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetNumCrg() Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(6)	//String que recebera a status do horario de verao
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_ContadorRelatoriosGerenciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := substr(oParams:Elements(3):cParametro, 1, 6)
   	EndIf
   	
   	

Return oRetorno  
	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetNumCcc �Autor  �Vendas Clientes     � Data �  10/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o Contador de Comprovante de Cr�dito ou D�bito 	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetNumCcc() Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(6)	//String que recebera a status do horario de verao
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_ContadorComprovantesCreditoMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := substr(oParams:Elements(3):cParametro, 1, 4)
   	EndIf

Return oRetorno  
	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetDtUDoc �Autor  �Vendas Clientes     � Data �  10/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a Data e Hora do ultimo Documento Armazenado na MFD ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetDtUDoc() Class LJAIBM

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0000")
    
   	oRetorno:oRetorno := ""			 //Copia o valor da propriedade da classe

Return oRetorno  
	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetCodEcf �Autor  �Vendas Clientes     � Data �  10/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o Codigo da Impressora Referente a 				  ���
���          �TABELA NACIONAL DE C�DIGOS DE IDENTIFICA��O DE ECF		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetCodEcf() Class LJAIBM

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0000")
    
   	oRetorno:oRetorno := "      "	//Esta fun��o dever� ser sobrescrita na classe a impressora fiscal

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeDadJorn �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em ler os dados da jornada				  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/              

Method LeDadJorn() Class LJAIBM
	    
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	

	//Prepara os parametros de envio
	oRetorno := ::TratarRet("0000")
	
Return oRetorno     



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeCupIni  �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em ler o cupom inicial do dia  		  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  		     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeCupIni() Class LJAIBM
	
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cUltCup 		:= Nil
	
	oRetorno := ::LeDadJorn()
	
	 // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)   
	 	
	 	cUltCup := ::GetNumCup():oRetorno
	 	oRetorno:oRetorno := str(strzero((val(cUltCup)+1),6, 0))

	 EndIf	

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MFDData   �Autor  �Vendas Clientes     � Data �  20/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel gerar a Leitura da fita detalhe por data ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPD1 (1 - dDtInicio) - Data inicial do periodo (ddmmaaaa). ���
���			 �EXPD2 (2 - dDtFim) - Data final do periodo (ddmmaaaa).	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method MFDData(dDtInicio, dDtFim) Class LJAIBM

	Local oParams 	:= Nil				//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil				//Objeto que sera retornado pela funcao
	Local cArqOri  := ::cPathMF + "RELMFDDATA.MFD"  //Nome do arquivo origem
	Local cArqDes  := ::cPathMFD  		//Nome do arquivo destino (TXT)
    Local cDatInicio := DtoC(dDtInicio)				//Data Inicio
    Local cDatFim	 :=	DtoC(dDtFim)				//Data Final
	
	
	
	cDatInicio := Left(cDatInicio, 6) + "20" + Right(cDatInicio,2) 
	cDatInicio := StrTran(cDatInicio, "/", "") 
	cDatFim := Left(cDatFim, 6) + "20" + Right(cDatFim,2) 
	cDatFim := StrTran(cDatFim, "/","")
			
 	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_DownloadMFD", cArqOri, "1", cDatInicio, cDatFim, "01"})
	
    //Envia o comando    	                       
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)  
    
	::ConvArq( cArqOri, cArqDes, "0", "1", cDatInicio, cDatFim, "")   
	
	
 Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MFDCoo    �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel gerar a Leitura da fita detalhe por Coo  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cCooInicio) - Coo inicial						  ���                                  
���			 �EXPC2 (2 - cCooFim) - Coo final							  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��           
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method MFDCoo(cCooInicio, cCooFim) Class LJAIBM                                  

	Local oParams  := Nil			  //Objeto para passagem dos parametros
	Local cRetorno := ""			  //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			  //Objeto que sera retornado pela funcao   
	Local cArqOri  := ::cPathMF + "RELMFDCOO.MFD" //Nome do arquivo origem
	Local cArqDes  := ::cPathMFD 	  //Nome do arquivo destino (TXT)
			
 	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_DownloadMFD", cArqOri, "2", cCooInicio, cCooFim, "01"})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)    
    
  	::ConvArq(cArqOri, cArqDes, "0", "2", cCooInicio, cCooFim, "")
    
Return oRetorno

/* 
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������ͻ��
���Programa  �TipoEData �Autor  �Vendas Clientes     � Data �  21/07/10  			 ���
������������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel gerar arq. Tipo E Ato Cotepe 17/04 PAF-ECF por Data.���
������������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  			 ���
������������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cDatInicio) - Data inicial						 			 ���
���			 �EXPC2 (2 - cDatFim) - Data final							 			 ���
������������������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										 			 ���
������������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
*/
Method TipoEData(cDatInicio, cDatFim, cPathArq, cBinario) Class LJAIBM

	Local oParams  := Nil			  //Objeto para passagem dos parametros
	Local cRetorno := ""			  //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			  //Objeto que sera retornado pela funcao   
	Local cArqOri  := space(200) //Nome do arquivo origem
	Local cArqDes  := ""	  //Nome do arquivo destino (TXT)
                    
	Default cBinario := "0"
	Default cPathArq := ""
		
	If cBinario <> "1"
		
		cDatInicio := Left(cDatInicio, 6) + "20" + Right(cDatInicio,2) 
		cDatInicio := StrTran(cDatInicio, "/", "") 
		cDatFim := Left(cDatFim, 6) + "20" + Right(cDatFim,2) 
		cDatFim := StrTran(cDatFim, "/","")
		
		If FindFunction("LjxGerPath")
		   	LjxGerPath( @cArqDes ) 
		  	cArqDes := cArqDes + "ARQ MFD\cotepe1704.txt" 
	  	EndIf
	
		oParams := ::PrepParam({IBM, "IBM_FI_GeraAtoCotepe1704", "1",cDatInicio, cDatFim, cArqOri})
	
	    //Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst(cRetorno)
		
	    //Trata o retorno    
	    oRetorno := ::TratarRet(cRetorno)
	    
	 
	   	//Trata o retorno      
	   	//Obtem o Estado da impressora
	   	cArqOri :=  RTrim(oParams:Elements(3):cParametro) 

	   	
	   	::FechaPorta()
   	
   	Else
   		cArqOri  := "REGTIPOE.MFD" //Nome do arquivo origem
 		oParams := ::PrepParam({IBM, "IBM_FI_GeraAtoCotepe1704", "1",cDatInicio, cDatFim, cArqOri})
   		cArqOri  := ::cPathMF  + "REGTIPOE.MFD" //Nome do arquivo origem
   			
	    //Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst(cRetorno)
		
	    //Trata o retorno    
	    oRetorno := ::TratarRet(cRetorno)
	    
	    //Trata o retorno    
	    oRetorno := ::TratarRet(cRetorno)    
	      
		oParams := ::GetPathTipoE(cBinario)	
								
		cArqDes := AllTrim(oParams:oRetorno)    
		If Empty(cArqDes)
			cArqDes := "C:\Download.bin"
		EndIf   		
   	
   	EndIf
   	
   	If !Empty(cArqDes)
   		__CopyFile(cArqOri,cArqDes)
   	EndIf 
 	     	 
Return oRetorno  

/*
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������ͻ��
���Programa  �TipoECrz  �Autor  �Vendas Clientes     � Data �  21/07/10  			 ���
������������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel gerar arq. Tipo E Ato Cotepe 17/04 PAF-ECF por Crz. ���
������������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  			 ���
������������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cCrzInicio) - Crz inicial						 			 ���
���			 �EXPC2 (2 - cCrzFim) - Crz final							 			 ���
������������������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										 			 ���
������������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
*/
Method TipoECrz(cCrzInicio, cCrzFim, cBinario) Class LJAIBM

	Local oParams  := Nil			  //Objeto para passagem dos parametros
	Local cRetorno := ""			  //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			  //Objeto que sera retornado pela funcao   
	Local cArqOri  := space(200) //Nome do arquivo origem
	Local cArqDes  := ""	  //Nome do arquivo destino (TXT)                   

	Default cBinario := "0"
	
	If cBinario <> "1"

		If FindFunction("LjxGerPath")
		   	LjxGerPath( @cArqDes ) 
		  	cArqDes := cArqDes + "ARQ MFD\cotepe1704.txt" 
	  	EndIf
	
		oParams := ::PrepParam({IBM, "IBM_FI_GeraAtoCotepe1704", "5",Left(cCrzInicio,4), Left(cCrzFim,4), cArqOri})
	
	    //Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst(cRetorno)
		
	    //Trata o retorno    
	    oRetorno := ::TratarRet(cRetorno)
	    
	
	    //Trata o retorno      
	    //Obtem o Estado da impressora
	    cArqOri :=  RTrim(oParams:Elements(3):cParametro)
	
	    If !Empty(cArqDes)
	    	__CopyFile(cArqOri,cArqDes)
	    EndIf
	    
	    ::FechaPorta()
	
	Else
		oRetorno := ::TratarRet("999")
	EndIf
     	 
    

Return oRetorno  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConvArq   �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel gerar a Leitura da fita detalhe por Coo  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cCooInicio) - Coo inicial  					  ���                                  
���			 �EXPC2 (2 - cCooFim) - Coo final		 			  		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf							  			  ���
�������������������������������������������������������������������������ͼ��           
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConvArq(cArqOri, cArqDes, cTpDado, cTprel, cPar1, cPar2, cUser) Class LJAIBM                                  

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao   
	
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_FormatoDadosMFD", cArqOri, cArqDes, cTpDado, cTprel, cPar1, cPar2, cUser})

    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno



Method HexToDec(cHex) Class LJAIBM
local nDec := 0
local nMul := 0
local cDig
local nPos
Local xRet 
	
for nPos := Len(cHex) to 1 step -1
	cDig := Upper(SubStr(cHex,nPos,1))
	nDec += if(cDig $ "ABCDEF", Asc(cDig)-55, Val(cDig)) * (16^nMul)
	nMul ++
next
xRet := Int(nDec)
Return xRet

/*���������������������������������������������������������������������������
���Programa  �BuscaAliq �Autor  �Vendas Clientes     � Data �  20/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura do cupom fiscal            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cTribut) - Tributacao          			   	  ���
���			 �EXPN1 (2 - nAliquota) - Valor da aliquota   				  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method BuscaAliq(cTribut, nAliquota) Class LJAIBM
Local cRetorno  := ""     		//Retorno do metodo
Local nCount	 := 0				//Variavel de controle contador
Local oAliquota := Nil			//Objeto com os dados da aliquota

If SubsTr(cTribut,1,2) $ "FS|IS|NS"
	cRetorno := SubsTr(cTribut,1,2) + "1"	

ElseIf SubsTr(cTribut,1,1) == "F"
	//Substituido
	cRetorno := "FF"                                                       
	
ElseIf SubsTr(cTribut,1,1) == "I"
	//Isento	
	cRetorno := "II"
	
ElseIf SubsTr(cTribut,1,1) == "N"
    //Nao tributado
	cRetorno := "NN"	
	
Else
	For nCount := 1 To ::oAliquotas:Count()
		
		oAliquota := ::oAliquotas:Elements(nCount)
		
		If SubsTr(cTribut,1,1) == "T" 
   			//Tributado
   			If !oAliquota:lIss .AND. oAliquota:nAliquota == nAliquota
   				cRetorno := oAliquota:cIndice
   				Exit
   			EndIf
		Else
			//Servico
			If oAliquota:lIss .AND. oAliquota:nAliquota == nAliquota
   				cRetorno := oAliquota:cIndice
   				Exit
   			EndIf
		EndIf
	Next
EndIf

Return cRetorno

/*���������������������������������������������������������������������������
���Programa  �LeituraX �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar uma Leitura X impressa.	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method LeituraX() Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao
 
	//Prepara os parametros de envio                                                    
	oParams := ::PrepParam({IBM, "IBM_FI_LeituraX"})
	             
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
 	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno	
	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �InicVar   �Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em inicializar variaveis                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method InicVar() Class LJAIBM
                                                                            
	::oFormasVen := Nil

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GuardarPgt�Autor  �Vendas Clientes     � Data �  20/06/11  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura do cupom fiscal            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cForma) - Descricao da forma      			   	  ���
���			 �EXPN1 (2 - nValor) - Valor da forma   				  	  		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  			  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GuardarPgt(cForma, nValor) Class LJAIBM
    
	Local oForma := Nil								//Objeto do tipo LJCFormaEcf

	If ::oFormasVen == Nil
		//Instancia o objeto LJCFormasECF
		::oFormasVen := LJCFormasECF():New()	
	EndIf 
    
    //Instancia o objeto LJCFormaEcf
	oForma := LJCFormaEcf():New(Nil, cForma, Nil, nValor)
	//Adiciona a forma na colecao
	::oFormasVen:ADD(1, oForma, .T.)

Return Nil
                                          
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeCMC7	�Autor  �Vendas Clientes     � Data �  10/06/11   ���
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
Method LeCMC7() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
   	Local cCMC7		:= Space(36)	//Valor do CMC7 lido
   	
	//Prepara os parametros de envio
	oParams := Self:PrepParam({IBM, "IBM_FI_LeituraCheque", cCMC7})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)  
     // Caso o comando tenha sido executado com sucesso, retorna o codigo do registrador
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := substr(oParams:Elements(3):cParametro, 1, 36)
	EndIf	
	
    
Return oRetorno                                                      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TratParam �Autor  �Vendas Clientes     � Data �  20/06/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo que trata os parametros a serem enviado.		 	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cRetorno) - String com o conteudo analisado	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Numerico													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TratParam(cRetorno) Class LJAIBM

	Local cRet := ""
	                          
	cRet := StrTran(cRetorno, Chr(13), Chr(10))
	
Return cRet    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CorrigRet �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo que tira caracteres NULL e espacos dos retoronos 	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cRetorno) - String com o conteudo analisado	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Numerico													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CorrigRet(cRetorno) Class LJAIBM

	Local cRet := ""
	
	cRetorno := AllTrim(cRetorno)    
	
	cRetorno := StrTran(cRetorno, Chr(13), "")
	
	cRetorno := StrTran(cRetorno, Chr(10), "")
	
	cRet := LjAsc2Hex(cRetorno)

	cRet := StrTran(cRet, "00")
	
	cRet := LjHex2Asc(cRet)
	
	cRet := AllTrim(cRet)
	
Return cRet                                                


/*���������������������������������������������������������������������������
���Programa  �TrataTags�Autor  �Vendas Clientes     � Data �  17/06/13  ���
�������������������������������������������������������������������������͹��
���Desc.     � 													          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cMensagem) - Mensagem Promocional 			   	  ���
�������������������������������������������������������������������������͹��
���Retorno   �cMsg									  ���
���������������������������������������������������������������������������*/
Method TrataTags( cMensagem ) Class LJAIBM
Local cMsg := ""

DEFAULT cMensagem := ""

cMsg := cMensagem

//Nao foi encontrado manual para tratar tags

cMsg := RemoveTags( cMsg )

Return cMsg

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  �GetCodDllECF	�Autor  �Vendas Clientes     � Data �  31/05/2013 ���
�����������������������������������������������������������������������������͹��
���Desc.     �Retorna a vers�o de instalacao da versao atual do Software      ���
���          �B�sico gravada na Memoria Fiscal do ECF.    			     	  ���
�����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                      	  ���
�����������������������������������������������������������������������������͹��
���Parametros�nenhum											    		  ���
�����������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf											  ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method GetCodDllECF() Class LJAIBM       

	Local oRetorno := Nil		 //Objeto que sera retornado pela funcao	
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ""	//Copia o valor da propriedade da classe
	
Return oRetorno
              
 
/*
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  �GetNomeECF	�Autor  �Vendas Clientes     � Data �  31/05/2013 ���
�����������������������������������������������������������������������������͹��
���Desc.     �Busca na DLL do Fabricante o nome composto pela: Marca + Modelo ���
���          �+ " - V. " + Vers�o do Firmware                                 ���
�����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                      	  ���
�����������������������������������������������������������������������������͹��
���Parametros�nenhum											    		  ���
�����������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf											  ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Method GetNomeECF() Class LJAIBM       

��� Local oRetorno	:= Nil			//Objeto que sera retornado pela funcao����������
��� Local cMarca	:= space(15)��	//Fabricante do ECF
����Local cModelo	:= space(20) 	//Modelo do ECF
��� Local oRet		:= ::LeModelo()	//M�todo que retornar� o modelo do ECF
��� Local cFirmWare	:= ""			//Vers�o do Firmware

    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ""	//Copia o valor da propriedade da classe


    
    If oRet <> NIL .AND. Valtype(oRet:oRetorno) == "C" 
    
	    cMarca := ::cFabric
	    cModelo :=  oRetorno:oRetorno 
	     

		oRet := ::LeFrmWare()
	    If oRet <> NIL 
	    	oRet := ::GetVerFirm() 
	    	cFirmWare := IIF(oRet <> NIL .AND. Valtype(oRet:oRetorno) == "C" , oRet:oRetorno, "")
	    EndIf	

		
		oRetorno:oRetorno := AllTrim(cMarca) + " " + ;
								AllTrim(cModelo) + " - V. "+;
								AllTrim(cFirmWare)

	
	EndIf

	 
	   
Return oRetorno

//LeModelo() - chamar m�todo
//lefabric() //LeDadImp() :cFabric
//LeFrmWare() - chamar m�todo                                            

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetPathMFBin�Autor  �Vendas Clientes     � Data �  10/12/13 ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar o caminho e nome do arquivo  ���
���          �de Memoria Fiscal.		                   				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetPathMFBin() Class LJAIBM

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
   	oRetorno:oRetorno := ::cPathMF + "mfiscal.bin" //Copia o valor da propriedade da classe
    

   	
Return oRetorno                                            



/* 
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������ͻ��
���Programa  �DonwMF     �Autor  �Vendas Clientes     � Data �  10//12/2013 			 ���
������������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel gerar arq. MF Bin�rio                              .���
������������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  			 ���
������������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cDatInicio) - Data inicial						 			 ���
���			 �EXPC2 (2 - cDatFim) - Data final							 			 ���
������������������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										 			 ���
������������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
*/
Method DownMF() Class LJAIBM

	Local oParams  := Nil			  //Objeto para passagem dos parametros
	Local cRetorno := ""			  //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			  //Objeto que sera retornado pela funcao   
	Local cArqOri  := "mfiscal.bin" //Nome do arquivo origem
			
 	//Prepara os parametros de envio
	oParams := ::PrepParam({BEMATECH, "IBM_FI_DownloadMF", cArqOri})
	
    //Envia o comando    	                       
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)    
    
Return oRetorno  


/* �������������������������������������������������������������������������������������
���Programa  �RedZDado  �Autor  �Vendas Clientes     � Data �  10//12/2013 			 ���
������������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar os dados da Redu��o                   .���
������������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  			 ���
������������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cDatInicio) - Data inicial						 			 ���
���			 �EXPC2 (2 - cDatFim) - Data final							 			 ���
������������������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										 			 ���
��������������������������������������������������������������������������������������*/
Method RedZDado() Class LJAIBM

	//Local oParams  := Nil			  //Objeto para passagem dos parametros
	//Local cRetorno := ""			  //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			  //Objeto que sera retornado pela funcao   
	//Local oRedZ := NIL			  	//Dados da �ltima redu��o
	
	
	oRetorno := ::TratarRet("0000")     
    
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
/*/
//--------------------------------------------------------
Method IdCliente(cCnpj, cNome, cEnd) Class LJAIBM
Local oRetorno := Nil		 //Objeto que sera retornado pela funcao	
oRetorno := ::TratarRet("0000")

Return oRetorno
