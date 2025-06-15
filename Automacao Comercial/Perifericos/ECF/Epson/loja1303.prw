#INCLUDE "MSOBJECT.CH" 
#INCLUDE "DEFECF.CH"
#INCLUDE "AUTODEF.CH"

Static cTagAllFormIni := '<AT>' //Ativa todos os atributos de formata��o 
Static cTagNegrIni	:= '<AN>' //Ativa negrito
Static cTagSubliIni	:= '<AS>' //Ativa sublinhado
Static cTagLrgDuplaIni:= '<AL>' //Ativa largura dupla
Static cTagAltDuplaIni:= '<AA>' //Ativa altura Dupla
Static cTagCorInvrtIni:= '<AI>' //Ativa cor invertida
Static cTagAllFormFim := '<DT>' //Desativa todos
Static cTagNegrFim	:= '<DN>' //Desativa negrito
Static cTagSubliFim	:= '<DS>' //Desativa sublinhado
Static cTagLrgDuplaFim:= '<DL>' //Desativa largura dupla
Static cTagAltDuplaFim:= '<DA>' //Desativa altura dupla
Static cTagCorInvrtFim:= '<DI>' //Desativa cor invertida

Function LOJA1303 ; Return 	 // "dummy" function - Internal Use 

/*����������������������������������������������������������������������������������
���Classe    �LJAEpson         �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe abstrata, possui as funcoes comuns para todos os ECF'S do   ���
���			 �modelo Epson													     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
����������������������������������������������������������������������������������*/
Class LJAEpson From LJAEcf
	
	Data oFormasVen																//Formas da venda, objeto do tipo LJCFormasEcf
	Data cPathBin																	//Diretorio dos Arquivos bin�rios
		
	Method New(oTotvsApi)														//Metodo construtor

	//Metodos da interface
	Method AbrirPorta(cPorta)													//Abre a porta serial para comunicacao com o ECF
	Method FechaPorta(cPorta)													//Fechar a porta serial
	
	//Operacoes fiscais
	Method AbrirCF(cCnpj, cCliente, cEndereco)							   		//Abri o cupom fiscal
	Method CancelaCF()															//Cancela o cupom fiscal
	Method VenderItem(cCodigo	, cDescricao, cTribut	, nAliquota	, ;
	                  nQtde		, nVlUnit	, nDesconto	, cComplemen, ;
	                  cUniMed)													//Vende item no ecf
	Method CancItem(cItem		, cCodigo	, cDescricao, cTribut	, ;
					nAliquota	, nQtde		, nVlUnit	, nDesconto	, ;
	    			cUniMed)													//Cancela item no ecf
	Method DescItem(nValor)														//Aplica desconto no item do cupom
	Method DescTotal(nValor)													//Aplica desconto no total do cupom
	Method AcresItem(nValor)													//Aplica acrescimo no item do cupom
	Method AcresTotal(nValor)													//Aplica acrescimo no total do cupom
	Method EfetuaPgto(cForma, nValor)											//Efetua pagamento
	Method FecharCF(oMsgPromo)													//Fechar cupom fiscal    
	Method TotalizaCF()															//Totaliza o cupom    
    
	//Operacoes nao fiscais
	Method AbrirCNFV(cForma, nValor)											//Abre cupom nao fiscal vinculado
	Method FecharCNFV()															//Fecha cupom nao fiscal vinculado
	Method CancCNFV(cCupom, cForma, nValor)										//Cancela cupom nao fiscal vinculado			
	Method AbrirCNF(cCnpj, cCliente, cEndereco, cTotaliz, nValor)				//Abre cupom nao fiscal
	Method FecharCNF()															//Fecha cupom nao fiscal
	Method PgtoCNF(cForma, nValor)												//Efetua pagamento nao fiscal
	Method CancCNF()															//Cancela cupom nao fiscal
	Method AbrirRG(cRelatorio)													//Abri relatorio gerencial
	Method FecharRG()															//Fecha relatorio gerencial
	Method ImpCodigoBarras(cCodBar)												//Imprime codigo de barras
	Method ImpTxtNF(oRelatorio, lLinha)											//Imprimi texto em cupom nao fiscal 
	Method Sangria(oFormas, cTotaliz)								   			//Efetua sangria de caixa
	Method Suprimento(oFormas, cTotaliz)   										//Efetua suprimentro de caixa (entrada de troco)
	Method EstNFiscVinc(cCPFCNPJ,cCliente,cEndereco,cMensagem,cCOOCCD)			//Efetua o estorno do comprovante de credito e debito
	
	//Relatorios fiscais
	Method LeituraX()															//Emite uma leituraX
	Method ReducaoZ()															//Emite uma leituraX
	Method AbrirDia()															//Emite leituraX de inicio de dia
   	Method MFData(dDtInicio, dDtFim, cTipo, cTipoArq)							//Leitura da memoria fiscal por data
   	Method MFReducao(cRedInicio, cRedFim, cTipo, cTipoArq)						//Leitura da memoria fiscal por reducao
    Method MFDData(dDtInicio, dDtFim)											//Leitura da memoria fita detalhe por data
   	Method MFDCoo(cCooInicio, cCooFim)											//Leitura da memoria fita detalhe por Coo
    Method TipoEData(cDatInicio, cDatFim, cPathArq, cBinario)								//Gerar arq. Tipo E Ato Cotepe 17/04 PAF-ECF por Data
	Method TipoECrz(cCrzInicio, cCrzFim, cBinario)										//Gerar arq. Tipo E Ato Cotepe 17/04 PAF-ECF por Crz
        
	//Autenticacao e cheque
	Method Autenticar(cTexto)													//Autentica documento / cheque
	Method ImpCheque(cBanco	, nValor, cData    , cFavorecid , ;
					 cCidade, cTexto, cExtenso , cMoedaS    , ;
					 cMoedaP)													//Imprime cheque
	Method LeCMC7() 															//Efetura a leitura do CMC7
	Method DownMF()															//Efetua a leitura da mem�ria fiscal
	Method RedZDado() 														//Dados da Redu��o Z
					 
	//Configuracoes
	Method ConfigPgto( cForma)								//Configura forma de pgto
	Method ConfTotNF(cIndice, cTotaliz)							   				//Configura totalizador nao fiscal	
	Method ConfigAliq(nAliq, cTipoIss)											//Configura aliquota		
	Method ConfVerao(cTipo)														//Configura a impressora para entrada / saida do horario de verao
	Method ConfRelGer(cIndice, cRelGer)											//Configura relatario gerencial
	
	//Gaveta
	Method AbrirGavet()															//Abri a gaveta
	
	//Informacoes ECF
	Method GetFabric()															//Retorna o fabricante do ecf 
   	Method GetModelo()															//Retorna o modelo do ecf
   	Method GetVerFirm()															//Retorna a versao do firmeware
   	Method GetCNPJ()															//Retorna o CNPJ
   	Method GetInsEst()															//Retorna a inscricao estadual
   	Method GetInsMun()															//Retorna a inscricao municipal
	Method GetNumLj()															//Retorna o numero da loja
	Method GetOper()															//Retorna o operador	
	Method GetRzSoc()															//Retorna a razao social
   	Method GetFantas()															//Retorna o nome fantasia
   	Method GetEnd1()															//Retorna o endereco 1
	Method GetEnd2()															//Retorna o endereco 2
    Method GetDadRedZ()															//Retorna os dados da reducao
	Method GetMFTXT()															//Retorna se a impressora gera memoria fiscal em txt    
   	Method GetMFSer()								    						//Retorna se a impressora gera memoria fiscal serial    
   	Method GetHrVerao()															//Retorna se a impresora esta em horario de verao
	Method GetAliq()															//Retorna as aliquotas cadastradas
	Method GetFormas()															//Retorna as formas cadastradas
	Method GetTotNF()															//Retorna os totalizadores nao fiscais cadastrados
	Method GetRelGer()															//Retorna os relatorios gerenciais cadastrados
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
    Method GetVlSupr()															//Retorna o valor de suprimento
    Method GetItImp()															//Retorna se todos os itens foram impressos
    Method GetPosFunc()															//Se o ecf retorna o Subtotal e o numero de itens impressos no cupom fiscal.
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
    Method GetPathMFBin()                                                          //Retorna o caminho e nome do arquivo de Memoria Fiscal Binaria
	Method GetPathTipoE(cBinario)														//Retorna o caminho e nome do arquivo de registro Tipo E Ato Cotepe 17/04 PAF-ECF
    Method BuscInfEcf()															//Busca as informacoes para o funcionamento do sistema (aliquotas, formas de pagto, numero serie, etc...)
    Method GetISSIsen()															//Retorna o valor de isentos para ISS
    Method GetIssNTri()															//Retorna o valor de nao tributados para ISS
    Method GetIssSubs()															//Retorna o valor de substituidos para ISS
	    
	//Metodos internos                                                                              
	Method ObterEst()										//Obtem o status de execucao do ultimo comando
	Method CarregMsg()										//Carrega as mensagens de retorno do ecf	
	Method LeDadoUsu()										//Carrega o C.N.P.J, I.M e I.E
	Method LeDadImp()										//Carrega o Modelo, Fabricante, Firmware & numero de serie do ECF
	Method LeCliche()                                 		//Carrega a Razao Social, Nome Fantasia, Endereco 1 & Endereco 2
	Method LeOperador()										//Carrega o nome do Operador
	Method LeECFLoja()										//Carrega o numero da Loja e do ECF
	Method LeAliq()											//Carrega as aliquotas cadastradas no ECF
	Method LeTotNF()										//Carrega os Totalizadores Nao Fiscais cadastrados no ECF
	Method LeRelGer()										//Carrega os Relatorios Gerenciais cadastrados no ECF
	Method LeGerencias()									//Le e retorna um array com os relatorios gerenciais
	Method LeFinaliz()										//Carrega as Formas de Pagamento cadastradas no ECF
	Method LeDataJor()										//Le a data e hora de abertura da jornada
	Method LeGT()											//Le o Grand Total da impressora
	Method LeGTIni()										//Le o Grand Total da inicial da impressora
	Method LeCOO()											//Le o coo do ultimo documento impresso pela impressora
	Method LeTotCanc()										//Le o total cancelado durante a jornada
	Method LeTotCanISS()									//Le total de cancelado para ISS
	Method LeTotDesc()										//Le o total de desconto durante a jornada
	Method LeTotDesISS()									//Le total de desconto para ISS
   	Method LeTotIsent()										//Le o total isento durante a jornada
   	Method LeTotNTrib()										//Le o total nao tributado durante a jornada
   	Method LeTotIss()										//Le o total de ISS durante a jornada
	Method LeVndLiq()										//Le o total de venda liquida durante a jornada
	Method LeVndBrut()										//Le o total de venda bruta durante a jornada		
	Method LeFaseCP()										//Le a fase do cupom fiscal em andamento
	Method LeDadJorn()										//Le os dados da jornada									
	Method LeCupIni()										//Le o cupom inicial do dia
	Method HexToDec(cHex)                                   //Converte hexa para decimal
	Method BuscaAliq(cTribut, nAliquota)					//Busca a aliquota para ser enviada a impressora    
    Method InicVar()										//Inicializando variaveis
    Method GuardarPgt(cForma, nValor)						//Guarda as formas da venda
    Method TrataTags( cMensagem )							//Trata as tags enviadas para a mensagem promocional
    Method GetCodDllECF()										//Busca na DLL do Fabricante o Codigo da Impressora Referente a TABELA NACIONAL DE C�DIGOS DE IDENTIFICA��O DE ECF
	Method GetNomeECF()										//Busca na DLL do Fabricante o nome composto pela: Marca + Modelo + " - V. " + Vers�o do Firmware                                                                                                              
    Method IdCliente(cCNPJ, cNome, cEnd)
    Method DownloadMFD(cBinario,cTipo,cInicio,cFinal)
    Method LeTotISSIs()										//Le o total de iss isento durante a jornada
   	Method LeTotISSNT()										//Le o total de iss nao tributado durante a jornada
   	Method LeTotIssSu()										//Le o total de iss substituido durante a jornada
   	
   	//Metodos Genericos de execu��o   	   	
   	Method ExcTabAlq(oParams) //Executa o comando EPSON_Obter_Tabela_Aliquotas
EndClass

/*����������������������������������������������������������������������������������
���Metodo    �New   	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJAEpson.     			    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
����������������������������������������������������������������������������������*/
Method New(oTotvsApi) Class LJAEpson
   
//Executa o metodo construtor da classe pai
_Super:New(oTotvsApi)

//Inicializando variaveis
::oFormasVen := Nil  
::cPathMFD   := "C:\LeituraMFD_ESP.txt"
::cPathMF    := "C:\LeituraMF.txt"
::cPathTipoE := "C:\Cotepe1704_CTP.txt"
::cPathBin   := "C:\"

//Carrega as mensagens
::CarregMsg()
	
Return Self

/*���������������������������������������������������������������������������
���Programa  �AbrirPorta�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura da porta serial.           ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Numero da porta COM (nao utilizado)						  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method AbrirPorta(cPorta) Class LJAEpson
	
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
		
//Prepara os parametros de envio
oParams := ::PrepParam({EPSON, "EPSON_Serial_Abrir_PortaEx"})
//Envia o comando
cRetorno := ::EnviarCom(oParams)
//Trata o retorno
oRetorno := ::TratarRet(cRetorno)

If oRetorno:cAcao == OK
	//Prepara os parametros de envio
	oParams := ::PrepParam({EPSON, "EPSON_Config_Habilita_EAD", "0"})  	//Desabilita assinatura automatica pela impressora
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
	//oRetorno := ::TratarRet(cRetorno)   
EndIf
    
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �FechaPorta�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo fechamento da porta serial.         ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Numero da porta COM (nao utilizado)						  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method FechaPorta(cPorta) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
			
	//Prepara os parametros de envio
	oParams := ::PrepParam({EPSON, "EPSON_Serial_Fechar_Porta"})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �AbrirCF   �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura do cupom fiscal            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cCnpj) - C.N.P.J/C.P.F do cliente.			   	  ���
���			 �EXPC2 (2 - cCliente) - Nome do cliente.   				  ���
���			 �EXPC3 (3 - cEndereco) - Endereco do cliente.			   	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method AbrirCF(cCnpj, cCliente, cEndereco) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cEndereco1:= Space(40)	//String para gravar os primeiros 40 caracteres do endereco.
	Local cEndereco2:= Space(39)	//String para gravar os 39 caracteres posteriores aos primeiros 40 caracteres do endereco.
	
	//Inicializando variaveis
    ::InicVar()
	     
	// Quebra em 2 partes (se necessario) o endereco do cliente.
	If( Len(cEndereco) > 40 )
		cEndereco1 := SubStr(cEndereco,1,40)
		If((Len(cEndereco) - 40) > 39)
			cEndereco2 := SubStr(cEndereco,41,39)
		Else
			cEndereco2 := SubStr(cEndereco,41,(Len(cEndereco) - 40))
		EndIf
	Else
		cEndereco1 := SubStr(cEndereco,1,Len(cEndereco))
		cEndereco2 := ""
	EndIf 

	If ( Len(cCliente) > 30 )
		cCliente	:= SubStr(cCliente,1,30)	
	EndIf
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({EPSON, "EPSON_Fiscal_Abrir_Cupom", AllTrim(cCnpj), cCliente, cEndereco1, cEndereco2, "2"})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)	
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CancelaCF �Autor  �Vendas Clientes	 � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo cancelamento do cupom fiscal        ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CancelaCF() Class LJAEpson   

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	
	//Prepara os parametros de envio
	oParams := ::PrepParam({EPSON, "EPSON_Fiscal_Cancelar_Cupom"})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	//Inicializa variaveis
	::InicVar()
	
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
	    			cUniMed ) Class LJAEpson
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao		
Local cAliquota	:= ""			//String temporaria que guarda o indice da aliquota
Local cQtde		:= ""			//Qantidade
Local cVlUnit	:= ""			//Valor unitario

//Busca aliquota
cAliquota := ::BuscaAliq(cTribut, nAliquota)	

If Empty(cAliquota)
	//Aliquota nao cadastrada no ECF
	oRetorno := ::TratarRet("0521")
Else
	//Prepara os valores
	cCodigo := AllTrim(Substr(cCodigo, 1, 14))
	cQtde := AllTrim(Str(nQtde * 1000))
	cVlUnit := AllTrim(Str(nVlUnit * 1000))

	cDescricao = AllTrim(SubStr(AllTrim(cDescricao) + " " + AllTrim(cComplemen), 1, 233))
	
	//Prepara os parametros de envio
	oParams := ::PrepParam({ EPSON, "EPSON_Fiscal_Vender_Item", cCodigo, cDescricao, cQtde, ;
	  						  "3", cUniMed, cVlUnit, "3", cAliquota, "1"})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	//Efetua o desconto sobre o item.
	If( ( nDesconto > 0) .AND. ( oRetorno:cAcao == OK ) )
		oRetorno := ::DescItem(nDesconto)
	EndIf
EndIf

Return oRetorno

/*���������������������������������������������������������������������������
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
���������������������������������������������������������������������������*/
Method CancItem(cItem		, cCodigo	, cDescricao, cTribut	, ;
				nAliquota	, nQtde		, nVlUnit	, nDesconto	, ;
	    		cUniMed ) Class LJAEpson
	    			
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	

//Prepara os parametros de envio
oParams := ::PrepParam({EPSON, "EPSON_Fiscal_Cancelar_Item", AllTrim(cItem)})
//Envia o comando    	
cRetorno := ::EnviarCom(oParams)
//Obtem o Estado da impressora
cRetorno := ::ObterEst()
//Trata o retorno    
oRetorno := ::TratarRet(cRetorno)    			
	    	
Return oRetorno

/*���������������������������������������������������������������������������
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
���������������������������������������������������������������������������*/                   
Method DescItem(nValor) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao			
	Local cValor	:= ""			//Valor do desconto
	
	cValor := AllTrim(Str(nValor * 100))
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({ EPSON, "EPSON_Fiscal_Desconto_Acrescimo_Item", cValor, "2", "1", "0"})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	
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
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method DescTotal(nValor) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao			
	Local cValor	:= ""			//Valor do desconto
	
	cValor := AllTrim(Str(nValor * 100))
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({ EPSON, "EPSON_Fiscal_Desconto_Acrescimo_Subtotal", cValor, "2", "1", "0"})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	
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
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AcresItem(nValor) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao			
	Local cValor	:= ""			//Valor do desconto
	
	cValor := AllTrim(Str(nValor * 100))
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({ EPSON, "EPSON_Fiscal_Desconto_Acrescimo_Item", cValor, "2", "0", "0"})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	
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
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AcresTotal(nValor) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao			
	Local cValor	:= ""			//Valor do desconto
	
	cValor := AllTrim(Str(nValor * 100))
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({ EPSON, "EPSON_Fiscal_Desconto_Acrescimo_Subtotal", cValor, "2", "0", "0"})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno
  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EfetuaPgto�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo pagamento do cupom fiscal			  ���
���          �                                                 			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cForma) - Nome da forma de pagamento utilizada.  ���
���          �EXPN1 (2 - nValor) - Valor do pagamento efetuado.   	  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method EfetuaPgto(cForma, nValor) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao		
	Local cIndice	:= ""			//String temporaria que guarda o indice da forma de pagamento
	Local cValor	:= ""			//Valor do pagamento
	                 
	//Verifica se a forma esta cadastrada no ecf
	oRetorno := ::GetForma(cForma)
	
	If oRetorno:cAcao == OK
		//Pega o indice da forma
		cIndice := oRetorno:oRetorno:cIndice
		//Prepara o valor
		cValor := AllTrim(Str(nValor * 100))
		//Prepara os parametros de envio
		oParams := ::PrepParam({ EPSON, "EPSON_Fiscal_Pagamento", cIndice, cValor, "2", "", ""})
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst()
		//Trata o retorno    
		oRetorno := ::TratarRet(cRetorno)
		
		If oRetorno:cAcao == OK
			//Guarda forma de pagto
			::GuardarPgt(cForma, nValor)
		EndIf
	EndIf
	
Return oRetorno
  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FecharCF  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo fechamento do cupom fiscal          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oMsgPromo) - Mensagem promocional				  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method FecharCF(oMsgPromo) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao		
	Local nDX		:= 1			//Contador utilizado no comando "For"
	Local nLinhas	:= 8			//Numero de linhas promocionais
	Local aLinhas 	:= {}          	//Array temporario que armazena as linhas promocionais.	
	                 	
	//Inicializa o Array 
	For nDX := 1 To nLinhas
		AADD(aLinhas,"")
	Next nDX
	                 
	//Limita o numero de linhas promocionais a 8
	If( oMsgPromo:Count() < 8)
		nLinhas := oMsgPromo:Count()
	EndIf

	//Copia as linhas recebidas pela funcao, truncando (se necessario) a linha em 56 caracteres.	
	For nDX := 1 To nLinhas
		aLinhas[nDX] := ::TrataTags( Substr(oMsgPromo:Elements(nDX), 1, 56) )
	Next nDX
	
	//Prepara os parametros de envio
	oParams := ::PrepParam({ EPSON, "EPSON_Fiscal_Imprimir_Mensagem", aLinhas[1], aLinhas[2], ;
							  aLinhas[3], aLinhas[4], aLinhas[5], aLinhas[6], aLinhas[7], aLinhas[8]})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)	
	
	If( oRetorno:cAcao == OK )
		//Prepara os parametros de envio
		oParams := ::PrepParam({ EPSON, "EPSON_Fiscal_Fechar_Cupom", "1", "0"})
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst()
		//Trata o retorno    
		oRetorno := ::TratarRet(cRetorno)
	EndIf
		
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TotalizaCF�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por totalizar o cupom.                   ���
���          �                                                            ���
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
Method TotalizaCF()Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//NOTA: As impressoras Epson nao precisam receber o comando de totalizacao de cupom.
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
Return oRetorno

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �AbrirCNFV �Autor  �Vendas Clientes     � Data �  06/03/08   	 ���
����������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura de um cupom nao fiscal     	 ���
���          �vinculado													  	 ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	 ���
����������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cForma) - Nome da forma de pagamento utilizada.  	 ���
���          �EXPN1 (2 - nValor) - Valor do pagamento efetuado.   	  	  	 ���
����������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  	 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Method AbrirCNFV(cForma, nValor) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao		
	Local cIndice	:= ""			//String temporaria que guarda o indice da forma de pagamento
	Local cValor	:= ""			//Valor do desconto

	//Verifica se a forma esta cadastrada no ecf
	oRetorno := ::GetForma(cForma)
		
	If oRetorno:cAcao == OK
		//Pega o indice da forma
		cIndice := oRetorno:oRetorno:cIndice
		//Prepara o valor
		cValor := AllTrim(Str(nValor * 100))
		//Prepara os parametros de envio
		oParams := ::PrepParam({ EPSON, "EPSON_NaoFiscal_Abrir_CCD", cIndice, cValor, "2", "1"})
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst()
		//Trata o retorno                                               
		oRetorno := ::TratarRet(cRetorno)
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
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method FecharCNFV() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao			
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({ EPSON, "EPSON_NaoFiscal_Fechar_CCD", "1"})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	//Inicializando variaveis
    ::InicVar()
	
Return oRetorno

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �CancCNFV  �Autor  �Vendas Clientes     � Data �  06/03/08      ���
����������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo cancelamento de um cupom nao fiscal    ���
���          �vinculado													     ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	     ���
����������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cCupom) - Coo do cupom fiscal relativo ao pagamento.���
���          �EXPC2 (2 - cForma) - Nome da forma de pagamento utilizada.  	 ���
���          �EXPN1 (3 - nValor) - Valor do pagamento efetuado.   	  	  	 ���
����������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  	 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Method CancCNFV(cCupom, cForma, nValor) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao		
	Local cIndice	:= ""			//String temporaria que guarda o indice da forma de pagamento
	                 
	//Verifica se a forma esta cadastrada no ecf
	oRetorno := ::GetForma(cForma)
	
	If oRetorno:cAcao == OK
		//Pega o indice da forma
		cIndice := oRetorno:oRetorno:cIndice
		//Prepara o valor
		cValor := AllTrim(Str(nValor * 100))
		//Prepara os parametros de envio
		oParams := ::PrepParam({ EPSON, "EPSON_NaoFiscal_Cancelar_CCD", cIndice, cValor, "2", "1", cCupom})
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst()
		//Trata o retorno    
		oRetorno := ::TratarRet(cRetorno)
		
		If( oRetorno:cAcao == OK )    
			//Fecha o comprovante de estorno
			oRetorno := ::FecharCNFV()	
		EndIf
		
		//Inicializando variaveis
	    ::InicVar()
	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AbrirCNF  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura de um cupom nao fiscal nao ���
���          �vinculado													  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cCnpj) - C.N.P.J do cliente.					  ���
���          �EXPC2 (2 - cCliente) - Nome do cliente.  					  ���
���          �EXPC3 (3 - cEndereco) - Endereco do cliente.   	  	  	  ���
���          �EXPC4 (4 - cTotaliz) - Totalizador nao fiscal utilizado. 	  ���
���          �EXPN1 (5 - nValor) - Valor do item nao fiscal. 	  		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AbrirCNF(cCnpj, cCliente, cEndereco, cTotaliz, nValor) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cEndereco1:= Space(40)	//String para gravar os primeiros 40 caracteres do endereco.
	Local cEndereco2:= Space(39)	//String para gravar os 39 caracteres posteriores aos primeiros 40 caracteres do endereco.
	Local cIndice	:= ""			//String temporaria que guarda o indice do totalizador nao fiscal
	Local cValor	:= ""			//Valor do cupom nao fiscal
	
	//Verifica se o totalizador esta cadastrado no ecf
	oRetorno := ::GetTotaliz(cTotaliz)
	
	If oRetorno:cAcao == OK
		//Pega o indice do totalizador
		cIndice := oRetorno:oRetorno:cIndice
		//Prepara o valor
		cValor := AllTrim(Str(nValor * 100))
		     
		// Quebra em 2 partes (se necessario) o endereco do cliente.
		If( Len(cEndereco) > 40 )
			cEndereco1 := SubStr(cEndereco,1,40)
			If((Len(cEndereco) - 40) > 39)
				cEndereco2 := SubStr(cEndereco,41,39)
			Else
				cEndereco2 := SubStr(cEndereco,41,(Len(cEndereco) - 40))
			EndIf
		Else
			cEndereco1 := SubStr(cEndereco,1,Len(cEndereco))
			cEndereco2 := ""
		EndIf
			
		//Prepara os parametros de envio
		oParams := ::PrepParam({EPSON, "EPSON_NaoFiscal_Abrir_Comprovante", AllTrim(cCnpj), cCliente, cEndereco1, cEndereco2, "2"})
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst()
		//Trata o retorno    
		oRetorno := ::TratarRet(cRetorno)	
		
		If( oRetorno:cAcao == OK )
			//Prepara os parametros de envio
			oParams := ::PrepParam({EPSON, "EPSON_NaoFiscal_Vender_Item", cIndice, cValor, "2"})
			//Envia o comando    			
			cRetorno := ::EnviarCom(oParams)
			//Obtem o Estado da impressora
			cRetorno := ::ObterEst()
			//Trata o retorno    
			oRetorno := ::TratarRet(cRetorno)	
		EndIf
	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FecharCNF �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo fechamento de um cupom nao fiscal   ���
���          �nao vinculado												  ���
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
Method FecharCNF() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao			
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({ EPSON, "EPSON_NaoFiscal_Fechar_Comprovante", "1"})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PgtoCNF   �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo pagamento do cupom nao fiscal nao   ���
���          �vinculado                                        			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cForma) - Nome da forma de pagamento utilizada.  ���
���          �EXPN1 (2 - nValor) - Valor do pagamento efetuado.   	  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method PgtoCNF(cForma, nValor) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao		
	Local cIndice	:= ""			//String temporaria que guarda o indice da forma de pagamento
	Local cValor	:= ""			//Valor do pagamento
		
	//Verifica se a forma esta cadastrada no ecf
	oRetorno := ::GetForma(cForma)
	
	If oRetorno:cAcao == OK
		//Pega o indice da forma
		cIndice := oRetorno:oRetorno:cIndice
		//Prepara o valor
		cValor := AllTrim(Str(nValor * 100))
		//Prepara os parametros de envio
		oParams := ::PrepParam({ EPSON, "EPSON_NaoFiscal_Pagamento", cIndice, cValor, "2", "", ""})
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst()
		//Trata o retorno    
		oRetorno := ::TratarRet(cRetorno)
	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CancCNF   �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo cancelamento do cupom nao fiscal    ���
���          �nao vinculado                                        		  ���
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
Method CancCNF() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao			
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({ EPSON, "EPSON_NaoFiscal_Cancelar_Comprovante"})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	//Inicializando variaveis
    ::InicVar()
   			
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AbrirRG   �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura de um relatorio gerencial  ���
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
Method AbrirRG(cRelatorio) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao		
	Local cIndice	:= ""			//String temporaria que guarda o indice do relatorio
	Local aGerencial:= {}
	Local nPos		:= 0
	                 
	cIndice := "01"

	If ( !(cRelatorio == Nil) .OR. !Empty(AllTrim(cRelatorio)) )  //Quando a impress�o � feita por titulo de relatorio gerencial
        aGerencial := ::LeGerencias()
		nPos := aScan( aGerencial , { |x| Upper(x[1]) == cRelatorio } ) //Pesquisa pelo indice do relatorio
		If nPos > 0
			cIndice := aGerencial[nPos][1]
		EndIf
	   oRetorno := Nil
	EndIf
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({ EPSON, "EPSON_NaoFiscal_Abrir_Relatorio_Gerencial", cIndice})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	//Inicializa variaveis
	::InicVar()
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FecharRG  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo fechamento do relatorio gerencial   ���
���          �                                                            ���
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
Method FecharRG() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao			
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({ EPSON, "EPSON_NaoFiscal_Fechar_Relatorio_Gerencial", "1"})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	
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
Method ImpCodigoBarras(cCodBar) Class LJAEpson
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao			
	
	//Prepara os parametros de envio
	oParams := ::PrepParam({ EPSON, "EPSON_NaoFiscal_Imprimir_Codigo_Barras", "5","100","2","2","1",cCodBar})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)	
	
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �ImpTxtNF  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelimpressao de linhas nao fiscais   	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oRelatorio) - Linhas nao fiscais.				  ���
���			 �ExpL1 (2 - lLinha) - Se vai ser impresso linha a linha.	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method ImpTxtNF(oRelatorio, lLinha) Class LJAEpson
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao		
Local nDX		:= 1			//Contador utilizado no comando "For"	
Local lPrint	:= .T.			//Flag responsavel por bloquear o envio da linha, caso tenha acontecido algum erro no comando anterior
Local aRelatorio:= {}
   
For nDX := 1 To oRelatorio:Count() //Necess�rio colocar pois quando existe algum caracter diferente o ECF n�o imprime o texto e finaliza o cupom
	Aadd( aRelatorio , oRelatorio:Elements(nDX) )
	aRelatorio[nDX] := ::TrataTags(StrTran(aRelatorio[nDX],CHR(9),""))
	aRelatorio[nDX] := ::TrataTags(StrTran(aRelatorio[nDX],CHR(10),""))
	aRelatorio[nDX] := ::TrataTags(StrTran(aRelatorio[nDX],CHR(13),""))
Next nDX

//Copia as linhas recebidas pela funcao, truncando (se necessario) a linha em 56 caracteres.	
For nDX := 1 To oRelatorio:Count()
	//Prepara os parametros de envio
	oParams := ::PrepParam({ EPSON, "EPSON_NaoFiscal_Imprimir_Linha", Substr(aRelatorio[nDX],1,56)})

	If lPrint
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst()
		//Trata o retorno    
		oRetorno := ::TratarRet(cRetorno)
		
		If( oRetorno:cAcao <> OK )
			lPrint := .F.
		EndIf
	EndIf
Next nDX

Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �Sangria   �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a Sangria  				  ���
���          �		                                        			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oFormas) - LJCFORMASECF com as fomas de pagamento���
���			 �EXPC1 (2 - cTotaliz) - Totalizador da sangria.			  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method Sangria(oFormas, cTotaliz) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao		
	Local cValor	:= ""			//Valor da sangria
	Local nCount	:= 1			//Contador utilizado no For...
	Local nValor	:= 0			//Valor total da sangria
		
	//NOTA: Independente da forma de pagamento passada como parametro, as impressoras Epson somente efetuam a Sangria em Dinheiro.
	
	//Pega o valor da sangria	
	For nCount:=1 To oFormas:Count()
		nValor += oFormas:Elements(nCount):nValor
	Next nCont
	
	cValor := AllTrim(Str(nValor * 100))
	
	//Prepara os parametros de envio
	oParams := ::PrepParam({ EPSON, "EPSON_NaoFiscal_Sangria", cValor, "2"})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	//Inicializa variaveis
	::InicVar()
	
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
���			 �EXPC1 (2 - cTotaliz) - Totalizador do suprimento.			  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Suprimento(oFormas, cTotaliz) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao		
	Local cValor	:= ""			//Valor da sangria
	Local nCount	:= 1			//Contador utilizado no For...
	Local nValor	:= 0			//Valor total da sangria

	//NOTA: Independente da forma de pagamento passada como parametro, as impressoras Epson somente efetuam o Fundo de Troco em Dinheiro.
	
	//Pega o valor do suprimento
	For nCount:=1 To oFormas:Count()
		nValor += oFormas:Elements(nCount):nValor
	Next nCont
	
	cValor := AllTrim(Str(nValor * 100))
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({ EPSON, "EPSON_NaoFiscal_Fundo_Troco", cValor, "2"})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	//Inicializa variaveis
	::InicVar()

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
Method EstNFiscVinc(cCPFCNPJ,cCliente,cEndereco,cMensagem,cCOOCCD) Class LJAEpson
Local oParams 	:= Nil		//Objeto para passagem dos parametros
Local cRetorno 	:= ""		//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil		//Objeto que sera retornado pela funcao
Local oRelatorio:= NIL		//Objeto que armazena o conteudo de cMensagem para ser impresso

oRelatorio:= PrepEpRel(cMensagem,1)
		           
//Prepara os parametros de envio
oParams	:= ::PrepParam({EPSON, "EPSON_NaoFiscal_Cancelar_CCD", "" ,"","0","", cCOOCCD})

//Envia o comando    	
cRetorno:= ::EnviarCom(oParams)

//Obtem o Estado da impressora
cRetorno := ::ObterEst()

//Trata o retorno    
oRetorno := ::TratarRet(cRetorno)

If oRetorno:cAcao == OK
	oRetorno:= ::ImpTxtNF(oRelatorio,.F.)
	
	If oRetorno:cAcao == OK
		oRetorno := ::FecharCNFV()
	EndIf
EndIf
        
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PrepRel   � Autor � Vendas Cliente        � Data �15/07/2008���
�������������������������������������������������������������������������Ĵ��
���Descricao � Prepara o relatorio para o ecf						      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PrepEpRel(cDados, nVias)
	
Local oRetorno 	:= Nil					//Retorno da funcao do tipo LJCRelatoriosEcf
Local cDelimit 	:= CHR(10)				//Delimitador
Local cDelimit13:= CHR(13)				//Delimitador sera retirado da string 
Local lLoop		:= .T.					//Variavel de controle do While
Local cAux		:= ""				    //Variavel para guardar linha a linha do relatorio
Local nCount	:= 1					//Variavel de controle contador
Local nViasAux	:= 1					//Controla o numero de vias
Local cTexto	:= ""					//Guarda o conteudo da variavel cDados
   	
//Instancia o objeto LJCRelatoriosEcf
oRetorno := LJCRelatoriosEcf():New()
   	   			
//Retira o delimitador do inicio da string
If Substr(cDados, 1, 1) == cDelimit
	cDados := Substr(cDados, 2)
EndIf

//Retira o delimitador do fim da string
If Substr(cDados, Len(cDados), 1) == cDelimit
	cDados := Substr(cDados, 1, Len(cDados) - 1)
EndIf

//Guarda o conteudo original
cTexto := cDados

While lLoop
    //Procura o delimitador na string
	nPos := At(cDelimit, cDados)
    
    //Verifica se encontrou o delimitador
	If nPos > 0 
		cAux := Substr(cDados, 1, nPos-1)
		cDados := Substr(cDados, nPos + 1)
		
		If cAux == cDelimit .OR. cAux == cDelimit13
			oRetorno:ADD(nCount++, " ")
		Else
			//Retira esse caracter para nao apresentar erro na impressora
			cAux := Alltrim( StrTran(cAux, cDelimit13, " "))
			oRetorno:ADD(nCount++, cAux)
		Endif
	Else         
		//Retira esse caracter para nao apresentar erro na impressora
		cDados := Alltrim( StrTran(cDados, cDelimit13, " "))
	
		oRetorno:ADD(nCount++, cDados)	
		
		If nViasAux == nVias
			lLoop := .F.
		Else
			//Adiciona a proxima via
			nViasAux++
			
			oRetorno:ADD(nCount++, Space(40))
			oRetorno:ADD(nCount++, Replicate("-", 15) + AllTrim(Str(nViasAux)) + " Via" + Replicate("-", 15))
			oRetorno:ADD(nCount++, Space(40))
			
			cDados := cTexto
		EndIf
	EndIf
End
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeituraX  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar uma Leitura X impressa.	  ���
���          �                                                            ���
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
Method LeituraX() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
   			
	//Prepara os parametros de envio
	oParams := ::PrepParam({EPSON, "EPSON_RelatorioFiscal_LeituraX"})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
   	//Inicializa variaveis
	::InicVar()
    
Return oRetorno	
	
/*���������������������������������������������������������������������������
���Programa  �ReducaoZ  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a Reducao Z.	  			  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method ReducaoZ() Class LJAEpson
Local oParams 	:= Nil						//Objeto para passagem dos parametros
Local cRetorno 	:= ""		   				//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil		   				//Objeto que sera retornado pela funcao
Local cNumRedZ	:= Space(4)	   				//String temporaria que recupera o numero da reducao Z
Local oRedZ		:= LJCDadosReducaoZ():New()//Objeto contendo os dados da reducao Z  
Local nDX		:= 1						//Contador utilizado no comando "For"
Local cSimbolo	:= Space(2)					//String temporaria para armazenamento do simbolo da aliquota
Local cValor	:= Space(4)	   				//String temporaria para armazenamento do valor numerico da aliquota
Local cVendido	:= Space(17)				//String temporaria para armazenamento do valor vendido na aliquota	
Local nImposto	:= 0						//Valor do imposto devido.
Local cDados  	:= Space(533)  				//String que receber a tabela de aliquotas cadastradas no ECF

//Inicia o preenchimento do objeto LJCDadosReducaoZ
oRedZ:cNumEcf	:= ::cNumEcf
oRedZ:cNrSerie	:= ::cNrSerie
    
oRetorno := ::LeDataJor()

If( oRetorno:cAcao == OK )
	oRedZ:dDataMov := CTOD(oRetorno:oRetorno)
	oRetorno := ::LeGT()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:nGranTotal := Val(oRetorno:oRetorno) / 100
	oRetorno := ::LeCOO()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:cNumCupFim := oRetorno:oRetorno
	oRetorno := ::LeTotCanc()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:nTotCancel := oRetorno:oRetorno
	oRetorno := ::LeTotCanISS()
EndIf

If ( oRetorno:cAcao == OK )
	oRedZ:nTotCanISS := oRetorno:oRetorno
	oRetorno := ::LeTotDesc() 
EndIf	
   		
If( oRetorno:cAcao == OK )
	oRedZ:nTotDesc := oRetorno:oRetorno
	oRetorno := ::LeTotDesISS()
EndIf

If ( oRetorno:cAcao == OK )
	oRedZ:nTotDesISS := oRetorno:oRetorno
	oRetorno := ::LeTotIsent() 
EndIf	

If( oRetorno:cAcao == OK )
	oRedZ:nTotIsent	:= oRetorno:oRetorno
	oRetorno := ::LeTotNTrib()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:nTotNTrib := oRetorno:oRetorno
	oRetorno := ::LeTotIss()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:nTotIss := oRetorno:oRetorno
	oRetorno := ::LeVndLiq()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:nVendaLiq := oRetorno:oRetorno
	oRetorno := ::LeVndBrut()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:nVendaBrut := oRetorno:oRetorno
	oRetorno := ::GetSubstit()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:nTotSubst := oRetorno:oRetorno
	oRetorno := ::GetDatHora()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:dDataRed := CTOD(Substr(oRetorno:oRetorno, 1, 10))
	oRetorno := ::GetInterve()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:cCro := oRetorno:oRetorno
    oRetorno := ::LeCupIni()
EndIf

If( oRetorno:cAcao == OK )
	oRedZ:cNumCupIni := oRetorno:oRetorno
EndIf

oRedZ:cCoo := StrZero(Val(oRedZ:cNumCupFim) + 1, 6)
		
oRetorno := ::ExcTabAlq( @oParams )

// Caso o comando tenha sido executado com sucesso	
If oRetorno:cAcao == OK    	
	For nDX := 1 To Len(oParams:Elements(3):cParametro)
		cSimbolo := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,2))	// Copia o simbolo da aliquota
		nDX += 2															
		cValor := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,4))	// Copia o valor numerico da aliquota
		nDX += 4
		cVendido := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,17))	// Copia o valor vendido na aliquota
		nDX += 16
		//Caso o simbolo seja preenchido
		If !Empty(AllTrim(cSimbolo))			
			If SubStr(cSimbolo,1,1) $ "T|S"
				nImposto := NoRound(((Val(cValor) / 100) * (Val(cVendido) / 100)) /100, 2)
				oRedZ:AdicImp(Val(cValor) / 100, Val(cVendido) / 100, nImposto , SubStr(cSimbolo,1,1) )
			EndIf
		EndIf
	Next nDX
	
	oRetorno := ::GetISSIsen()
	oRedZ:nTotIssIse := oRetorno:oRetorno
	
	oRetorno := ::GetIssNTri()
	oRedZ:nTotIssNTr := oRetorno:oRetorno
	
	oRetorno := ::GetIssSubs()
	oRedZ:nTotIssSub := oRetorno:oRetorno
EndIf
   			
//Prepara os parametros de envio
oParams := ::PrepParam({EPSON, "EPSON_RelatorioFiscal_RZ","","","9",cNumRedZ})
cRetorno := ::EnviarCom(oParams)
cRetorno := ::ObterEst()
oRetorno := ::TratarRet(cRetorno)

If oRetorno:cAcao == OK
    oRedZ:cNumRedZ := oParams:Elements(6):cParametro
	::oDadosRedZ := oRedZ
	//Inicializa variaveis
	::InicVar()
EndIf
		
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �AbrirDia  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a Abertura do dia.			  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method AbrirDia() Class LJAEpson
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao

//Verifica as flags fiscais
oRetorno := ::GetFlagsFi()
   			
If oRetorno:cAcao == OK
	//Verifica se o o dia nao foi iniciado
	If !oRetorno:oRetorno:lInicioDia
		//Prepara os parametros de envio
		oParams := ::PrepParam({EPSON, "EPSON_RelatorioFiscal_Abrir_Dia"})
	    //Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst()
	    //Trata o retorno    
	    oRetorno := ::TratarRet(cRetorno)
	    //Inicializa variaveis
		::InicVar()
	EndIf
EndIf
	
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
���			 �					  (I- impressao / A - arquivo).			  ���
���			 �EXPC2 (4 - cTipoArq) - (C - completa / S - simplificada).	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method MFData(dDtInicio, dDtFim, cTipo, cTipoArq)	Class LJAEpson 

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	Local cDtInicio := ""			//Data inicio
	Local cDtFim 	:= ""			//Data fim        
	Local nTipoMF	:= 0			//Define o tipo do arquivo gerado
	
	cDtInicio := Padl(Day(dDtInicio), 2 , "0") + Padl(Month(dDtInicio), 2 , "0") + AllTrim(Str(Year(dDtInicio)))
	cDtFim  := Padl(Day(dDtFim), 2 , "0") + Padl(Month(dDtFim), 2 , "0") + AllTrim(Str(Year(dDtFim)))
	
 	If ( cTipoArq == "S")
		//Prepara os parametros de envio (Modo Simplificado, faixa em Data) 	
	 	nTipoMF := 3
 	Else
		//Prepara os parametros de envio (Modo Completo, faixa em Data) 	
		nTipoMF := 1
 	EndIf
			
 	If ( cTipo == "I")
		//Prepara os parametros de envio (Impressao) 
		nTipoMF += 4 
		oParams := ::PrepParam({EPSON, "EPSON_RelatorioFiscal_Leitura_MF",cDtInicio,cDtFim,cValToChar(nTipoMF),"","","",""})
	ElseIf ( cTipo == "A")
		//Prepara os parametros de envio (Arquivo)
		nTipoMF += 16
		oParams := ::PrepParam({EPSON, "EPSON_RelatorioFiscal_Leitura_MF",cDtInicio,cDtFim,cValToChar(nTipoMF),"",::cPathMF,"",""})
	EndIf
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
	//Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    //Inicializa variaveis
	::InicVar()
    
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
���          �EXPC1 (3 - cTipo) - Tipo da Leitura						  ���
���			 �					  (I- impressao / A - arquivo).			  ���
���			 �EXPC2 (4 - cTipoArq) - (C - completa / S - simplificada).	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method MFReducao(cRedInicio, cRedFim, cTipo, cTipoArq) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	Local nTipoMF	:= 0			//Define o tipo do arquivo gerado
	
 	If ( cTipoArq == "S")
		//Prepara os parametros de envio (Modo Simplificado, faixa em CRZ) 	
	 	nTipoMF := 2
 	Else
		//Prepara os parametros de envio (Modo Completo, faixa em CRZ) 	
		nTipoMF := 0
 	EndIf
			
 	If ( cTipo == "I")
		//Prepara os parametros de envio (Impressao)
		nTipoMF += 4 
		oParams := ::PrepParam({EPSON, "EPSON_RelatorioFiscal_Leitura_MF",cRedInicio,cRedFim,cValToChar(nTipoMF),"","","",""})
	ElseIf ( cTipo == "A")
		//Prepara os parametros de envio (Arquivo)
		nTipoMF += 16
		oParams := ::PrepParam({EPSON, "EPSON_RelatorioFiscal_Leitura_MF",cRedInicio,cRedFim,cValToChar(nTipoMF),"",::cPathMF,"",""})
	EndIf
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
	//Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    //Inicializa variaveis
	::InicVar()
    
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
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Autenticar(cTexto) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
   			 	
	//Prepara os parametros de envio
	oParams := ::PrepParam({EPSON, "EPSON_Autenticar_Imprimir", SubStr(cTexto,1,50)})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
	//Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    If( ( oRetorno:cAcao == ERRO ) .AND. ( cRetorno == "3006" ) )
       	//NOTA: O texto impresso na reimpressao sera igual ao texto enviado na autenticacao.
    	// 		Por isso o parametro cTexto e ignorado neste comando.
    	//Prepara os parametros de envio
		oParams := ::PrepParam({EPSON, "EPSON_Autenticar_Reimprimir"})
	 	//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst()
	   	//Trata o retorno    
    	oRetorno := ::TratarRet(cRetorno)
    EndIf

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
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ImpCheque(cBanco	, nValor, cData    , cFavorecid , ;
				 cCidade, cTexto, cExtenso , cMoedaS    , ;
				 cMoedaP) Class LJAEpson
					 
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
   	Local cValor	:= ""			//Valor do cheque
   	
   	cValor := AllTrim(Str(nValor * 100))
   			 		
	If ValType(cMoedaS) <> "C"
		cMoedaS := Space(20)
	EndIf
	If ValType(cMoedaP) <> "C"
		cMoedaP := Space(20)
	EndIf
	
	// Data no formato ddmmaaaa
	cData := SubStr(cData,7 ,2) + SubStr(cData,5 ,2) + SubStr(cData,1 ,4)
   			 		
	//Prepara os parametros de envio
	oParams := ::PrepParam({EPSON, "EPSON_Cheque_Configurar_Moeda", SubStr(cMoedaS,1,20), SubStr(cMoedaP,1,20)})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    If( oRetorno:cAcao <> ERRO )
        //NOTA: O arquivo poscheque.dat deve estar no mesmo diretorio em que se encontra o arquivo InterfaceEpson.dll	
    	//Prepara os parametros de envio
		oParams := ::PrepParam({EPSON, "EPSON_Cheque_ImprimirEX"    , SubStr(cBanco,1,3)     , SubStr(cValor,1,13) ,;
															   "2"   , SubStr(cFavorecid,1,40), SubStr(cCidade,1,30),;
															   cData , SubStr(cTexto,1,40)})
				
   	 	//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst()
    	//Trata o retorno    
    	oRetorno := ::TratarRet(cRetorno)
    EndIf
    
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
Method LeCMC7() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
   	Local cCMC7		:= Space(256)	//Valor do CMC7 lido
   	
	//Prepara os parametros de envio
	oParams := Self:PrepParam({EPSON, "EPSON_Cheque_Ler_MICR", cCMC7})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)  
     // Caso o comando tenha sido executado com sucesso, retorna o codigo do registrador
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := oParams:Elements(3):cParametro
	EndIf
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConfigPgto�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a inclusao de uma forma de	  ���
���          �pagamento.					                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cForma) - Nome da forma de pagamento.		      ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfigPgto( cForma ) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao   			
 	                                
	//Prepara os parametros de envio
	oParams := ::PrepParam({EPSON, "EPSON_Config_Forma_PagamentoEX","1", SubStr(cForma,1,15)})	

    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConfTotNF �Autor  �Vendas Clientes     � Data �  06/03/08   ���
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
Method ConfTotNF(cIndice, cTotaliz) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	Local cTInd		:= Space(10)	//String temporaria para receber o numero do totalizador cadastrado.
 	                                
	//NOTA: O indice do totalizador sera gerado pela impressora, por este motivo, o parametro cIndice e ignorado.
 	//Prepara os parametros de envio
	oParams := ::PrepParam({EPSON, "EPSON_Config_Totalizador_NaoFiscal", SubStr(cTotaliz,1,15), cTInd})	 	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
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
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfigAliq(nAliq, cTipoIss) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao   			
	Local cAliq		:= ""			//Valor da aliquota
	
	cAliq := AllTrim(Str((nAliq * 100)))
	 	                                
 	If(cTipoIss == "S")
 		//Prepara os parametros de envio
		oParams := ::PrepParam({EPSON, "EPSON_Config_Aliquota", SubStr(cAliq,1,4), "1"})
 	Else
 		//Prepara os parametros de envio
		oParams := ::PrepParam({EPSON, "EPSON_Config_Aliquota", SubStr(cAliq,1,4), "0"})
 	EndIf	
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConfVerao �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a entrada / saida do horario ���
���          �de verao.						                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cTipo) - Tipo da configuracao.			  		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfVerao(cTipo)Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao   			
 	                                
	//NOTA: Caso seja possivel, a entrada ou saida de intervencao sera feita sem a necessidade do envio de parametro.
 	//Prepara os parametros de envio
	oParams := ::PrepParam({EPSON, "EPSON_Config_Horario_Verao"})	 	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ConfRelGer�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a inclusao de um relatorio   ���
���          �gerencial.					                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cIndice) - Indice do totalizador		  		  ���
���			 �EXPC2 (2 - cRelGer) - Descricao do relatorio gerencial.  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfRelGer(cIndice, cRelGer) Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao   			
 	                                
	//NOTA: O indice do relatorio gerencial sera gerado pela impressora, por este motivo, o parametro cIndice e ignorado.
 	//Prepara os parametros de envio
	oParams := ::PrepParam({EPSON, "EPSON_Config_Relatorio_Gerencial", SubStr(cRelGer,1,15)})	 	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AbrirGavet�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a abertura da gaveta.   	  ���
���          �					                              			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum.													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AbrirGavet() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao   			
 	                                
 	//Prepara os parametros de envio
	oParams := ::PrepParam({EPSON, "EPSON_Impressora_Abrir_Gaveta"})	 	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetFabric �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o fabricante da impressora. ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf contendo o nome do fabricante		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetFabric() Class LJAEpson

	Local oRet 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRet := ::TratarRet("0000")
    
    oRet:oRetorno := ::cFabric	//Copia o valor da propriedade da classe
    
Return oRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetModelo �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o modelo da impressora.	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf contendo o nome do fabricante		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetModelo() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cModelo	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetVerFirm�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a versao do firmware		  ���
���          �da impressora.                                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetVerFirm() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cFirmWare	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetCNPJ   �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o C.N.P.J. do usuario cadas-���
���          �trado no ECF.                                               ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetCNPJ() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cCnpj	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetInsEst �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a inscicao estadual do 	  ���
���          �usuario cadastrado no ECF.                                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetInsEst() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cIE	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetInsMun �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a inscicao municipal do 	  ���
���          �usuario cadastrado no ECF.                                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetInsMun() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cIM	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetNumLj  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o numero da loja cadastrado ���
���          �no ECF.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetNumLj() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cLoja	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetOper   �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o nome do operador  		  ���
���          �cadastrado no ECF.                                          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetOper() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cOperador	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetRzSoc  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a razao social cadastrada	  ���
���          �no ECF.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetRzSoc() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cRazaoSoc	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetFantas �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o nome fantasia cadastrado  ���
���          �no ECF.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetFantas() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cFantasia	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetEnd1   �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o nome endereco 1 cadastra- ���
���          �do no ECF.                                                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetEnd1() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cEndereco1	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetEnd2   �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o nome endereco 2 cadastra- ���
���          �do no ECF.                                                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetEnd2() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cEndereco2	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetDadRedZ�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar os dados capturados na  	  ���
���          �execucao do ultimo comando de ReducaoZ                      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetDadRedZ() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::oDadosRedZ	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetMFTXT  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar um flag indicando se sera	  ���
���          �possivel gerar um arquivo a partir da leitura da MF.        ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetMFTXT() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := .T.

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetMFSer  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar um flag indicando se sera	  ���
���          �possivel gerar a leitura da MF serial.			          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetMFSer() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := .T.
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetHrVerao�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o flag que indica horario de���
���          �verao no ECF.                                               ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetHrVerao() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(1)		//String que recebera a status do horario de verao
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Estado_Horario_Verao", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := oParams:Elements(3):cParametro
	EndIf
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetAliq   �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a tabela de aliquotas cadas-���
���          �tradas no ECF.                                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetAliq() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::oAliquotas	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetFormas �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a tabela de formas de paga- ���
���          �mento cadastradas no ECF.                                   ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetFormas() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::oFormas	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetTotNF  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a tabela de totalizadores	  ���
���          �nao fiscais cadastrados no ECF.                             ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetTotNF() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::oTotsNF	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetRelGer �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a tabela de relatorios 	  ���
���          �gerenciais cadastrados no ECF.                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetRelGer() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::oGerencial	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetNrSerie�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o numero de serie do ECF.	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetNrSerie() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cNrSerie	//Copia o valor da propriedade da classe
    
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �GetNumCup �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o numero do ultimo COO.	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method GetNumCup ()Class LJAEpson
	
Local oRetorno 	:= ::LeCOO()

Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �GetNumEcf �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o numero do ECF.	 	 	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method GetNumEcf() Class LJAEpson

Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao

//Trata o retorno    
oRetorno := ::TratarRet("0000")

oRetorno:oRetorno := ::cNumEcf	//Copia o valor da propriedade da classe

Return oRetorno
  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetNumItem�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o numero do ultimo item 	  ���
���          �vendido pelo ECF.                                           ���
���          �Desconsiderar os itens cancelados.                          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetNumItem() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(3)		//String que recebera a numero do item
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Numero_Ultimo_Item", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := oParams:Elements(3):cParametro
	EndIf

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetSubTot �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o valor do subtotal do cupom���
���          �fiscal.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetSubTot() Class LJAEpson
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(13)	//String que recebera subtotal do cupom
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Fiscal_Obter_SubTotal", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == "OK")    	
		oRetorno:oRetorno := (Val(oParams:Elements(3):cParametro) / 100)
	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetDatHora�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a data e hora atual do ECF. ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf contendo a data e hora atual do ECF    ���
���			 �no formato dd/mm/aaaa hh:mm:SS (19 bytes)					  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetDatHora() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(15)	//String que recebera subtotal do cupom
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Hora_Relogio", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno :=	Substr(oParams:Elements(3):cParametro,1,2)  + "/" +;
								Substr(oParams:Elements(3):cParametro,3,2)  + "/" +;
							  	Substr(oParams:Elements(3):cParametro,5,4)  + " " +;
							  	Substr(oParams:Elements(3):cParametro,9,2)  + ":" +;
							  	Substr(oParams:Elements(3):cParametro,11,2) + ":" +;
							  	Substr(oParams:Elements(3):cParametro,13,2)
	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetDesItem�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar se o ecf permite desconto   ���
���          �sobre o item vendido.                                       ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetDesItem() Class LJAEpson
	
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    //A impressora permite, so que deixamos como falso para manter o legado.
    oRetorno:oRetorno := .F.

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetImpFisc�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por verificar se a impressora e fiscal.  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetImpFisc() Class LJAEpson
	
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := .T.

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetTrunAre�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo que verifica se a impressora trunca ou arredonda.    ���
���          �T - trunca / A - Arredonda                                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetTrunAre() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := "T"
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetChqExt �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo que verifica se a impressora necessita do valor do   ���
���          �Cheque por extenso.                                         ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetChqExt() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := .F.
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetVdBruta�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a Venda Bruta atual do ECF. ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetVdBruta() Class LJAEpson

	Local oRetorno 	:= ::LeVndBrut()

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetGranTot�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o Grand Total atual do ECF. ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetGranTot()Class LJAEpson

	Local oRetorno 	:= ::LeGT()

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetTotDesc�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o total de descontos do ECF.���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetTotDesc() Class LJAEpson

	Local oRetorno 	:= ::LeTotDesc()

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetDescIss�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o total de descontos de ISS ���
���          �do ECF.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetDescIss() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(51)	//String que recebera os totais de desconto da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Total_Descontos", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno :=	Substr(oParams:Elements(3):cParametro,18,17)
	EndIf
		
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetTotAcre�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o total de acrescimos do ECF���
���          �                                                     		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetTotAcre() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(51)	//String que recebera os totais de desconto da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Total_Acrescimos", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno :=	Val(Substr(oParams:Elements(3):cParametro,1,17)) +; 
							 	Val(Substr(oParams:Elements(3):cParametro,18,17))
	EndIf

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetAcreIss�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o total de acrescimos em ISS���
���          �do ECF.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetAcreIss() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(51)	//String que recebera os totais de desconto da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Total_Acrescimos", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno :=	Val(Substr(oParams:Elements(3):cParametro,18,17))
	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetTotCanc�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o total de cancelamentos do ���
���          �ECF.                                                        ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetTotCanc()Class LJAEpson

	Local oRetorno 	:= ::LeTotCanc()

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetCancIss�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o total de cancelamentos de ���
���          �ISS no ECF.                                                 ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetCancIss() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(51)	//String que recebera os totais cancelados da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Total_Cancelado", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Val(Substr(oParams:Elements(3):cParametro,18,17))
	EndIf
	
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �GetIsentos�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o total de Isentos do ECF.  ���
���          �		 													  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method GetIsentos() Class LJAEpson

Local oRetorno 	:= ::LeTotIsent()

Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �GetNaoTrib�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o total de nao tributados   ���
���          �do ECF.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method GetNaoTrib() Class LJAEpson

Local oRetorno 	:= ::LeTotNTrib()

Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �GetSubstit�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o total de substituicoes    ���
���          �tributarias do ECF.                                         ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method GetSubstit() Class LJAEpson
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
Local cDados  	:= Space(533)	//String que receber a tabela de aliquotas cadastradas no ECF
Local nDX		:= 1			//Contador utilizado no comando "For"
Local cSimbolo	:= Space(2)		//String temporaria para armazenamento do simbolo da aliquota
Local cValor	:= Space(4)		//String temporaria para armazenamento do valor numerico da aliquota
Local cVendido	:= Space(17)	//String temporaria para armazenamento do valor vendido na aliquota
Local nSoma		:= 0
	
oRetorno := ::ExcTabAlq( @oParams )

// Caso o comando tenha sido executado com sucesso	
If(oRetorno:cAcao == OK)    	
	For nDX := 1 To Len(oParams:Elements(3):cParametro)
		cSimbolo := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,2))	// Copia o simbolo da aliquota
		nDX += 2															
		cValor := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,4))	// Copia o valor numerico da aliquota
		nDX += 4
		cVendido := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,17))	// Copia o valor vendido na aliquota
		nDX += 16
		//Caso o simbolo seja preenchido
		If !Empty(AllTrim(cSimbolo))			
			If cSimbolo == "F"
				nSoma += Val(cVendido) / 100
			EndIf
		EndIf
	Next nDX    	
EndIf

oRetorno:oRetorno := nSoma
	
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �GetNumRedZ�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o numero da ultima reducao  ���
���          �Z executada pelo ECF.                                       ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method GetNumRedZ() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(84)	//String que recebera os contadores da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Contadores", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Substr(oParams:Elements(3):cParametro,7,6)
	EndIf
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetCancela�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o numero de cupons 		  ���
���          �cancelados pelo ECF.                                        ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetCancela() Class LJAEpson
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(84)	//String que recebera os contadores da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Contadores", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Substr(oParams:Elements(3):cParametro,49,6)
	EndIf
	
Return oRetorno
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetInterve�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o numero de intervencoes	  ���
���          �executadas no ECF.                                          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetInterve() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(84)	//String que recebera os contadores da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Contadores", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Substr(oParams:Elements(3):cParametro,13,6)
	EndIf

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetDtUltRe�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a data da ultima reducao  Z ���
���          �executada pelo ECF.                                         ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetDtUltRe() Class LJAEpson

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
���Programa  �GetTotIss �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar o total de ISS vendido pelo ���
���          �ECF.                                         				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetTotIss() Class LJAEpson

	Local oRetorno 	:= ::LeTotIss()

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetDataMov�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar a data de abertura do movi- ���
���          �mento atual do ECF.                                         ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetDataMov() Class LJAEpson
	
	Local oRetorno 	:= ::LeDataJor()	

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetFlagsFi�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar os flags fiscais do ECF.	  ���
���          �                                         				  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetFlagsFi() Class LJAEpson
    
    Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cLEstad	:= Space(20)	//String que recebera o retorno da funcao
	Local nST3  	:= 0			//String que recebera o estado da impressora	
	Local nST4  	:= 0			//String que recebera o estado da impressora	
	Local flagB09 	:= .F.
    Local flagB10 	:= .F.
	Local sRet1		:= Space(4)
	Local sRet2		:= Space(4)
	Local cJornada	:= Space(70)
	
	::oFlagsFisc	:= LJCFlagsFiscaisECF():New()
	
	//Prepara os parametros de envio
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Estado_Impressora", cLEstad})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    oRetorno := ::TratarRet(cRetorno)
    
	If ( oRetorno:cAcao == OK )
		sRet1 := SubStr(oParams:Elements(3):cParametro, 9,4)
		sRet2 := SubStr(oParams:Elements(3):cParametro,13,4)
		nST3 := ::HexToDec(sRet1)
		nST4 := ::HexToDec(sRet2)
    	//==============================================================================
        //Estado da Impressora
        //==============================================================================        
        //****************************************************************************
        //                       TRATAMENTO DO BIT 15                                *
        //****************************************************************************
        If (nST3 >= 32768)
            //Impressora(Offline) 
            ::oFlagsFisc:lEcfOff := .T.
            nST3 -= 32768
		EndIf
        //****************************************************************************
        //                       TRATAMENTO DO BIT 14                                *
        //****************************************************************************
        If (nST3 >= 16384)
            //Erro de impress�o
            nST3 -= 16384
		EndIf
        //****************************************************************************
        //                       TRATAMENTO DO BIT 13                                *
        //****************************************************************************
		If (nST3 >= 8192)
            //Tampa superior aberta
            ::oFlagsFisc:lTampAbert := .T.
            nST3 -= 8192
		EndIf
        //****************************************************************************
        //                       TRATAMENTO DO BIT 12                                *
        //****************************************************************************
		If (nST3 >= 4096)
            //Estado da gaveta = 1 
            ::oFlagsFisc:lGavAberta := .T.
            nST3 -= 4096
		EndIf
        //****************************************************************************
        //                       TRATAMENTO DOS BITS 10 E 9                          *
        //****************************************************************************
		If (nST3 >= 1024)
            flagB10 = .T.
            nST3 -= 1024
		EndIf

		If (nST3 >= 512)
            flagB09 = .T.
            nST3 -= 512
		EndIf
        
        If ((flagB10 == .F.) .AND. (flagB09 == .F.))
            //Impressora Online 
            ::oFlagsFisc:lEcfOff := .F.
		EndIf      
        //****************************************************************************
        //                       TRATAMENTO DO BIT 8                                 *
        //****************************************************************************
        If (nST3 >= 256)
            //Aguardando retirada do papel
            nST3 -= 256
		EndIf
        //****************************************************************************
        //                       TRATAMENTO DO BIT 7                                 *
        //****************************************************************************
        If (nST3 >= 128)
            //Aguardando inser��o do papel
            nST3 -= 128
		EndIf
        //****************************************************************************
        //                       TRATAMENTO DO BIT 6                                 *
        //****************************************************************************
        If (nST3 >= 64)
            //Estado do sensor inferior da esta��o de cheque = 1
            nST3 -= 64
		EndIf
        //****************************************************************************
        //                       TRATAMENTO DO BIT 5                                 *
        //****************************************************************************
        If (nST3 >= 32)
            //Estado do sensor superior da esta��o do cheque = 1
            nST3 -= 32
		EndIf
        //****************************************************************************
        //                       TRATAMENTO DO BIT 4                                 *
        //****************************************************************************
        If (nST3 >= 16)
            //Estado do sensor de autentica��o = 1
            nST3 -= 16
		EndIf
        //****************************************************************************
        //                       TRATAMENTO DO BIT 3                                 *
        //****************************************************************************
        If (nST3 >= 8)
            //Sem papel
            ::oFlagsFisc:lFimPapel := .T.
            nST3 -= 8
		EndIf
        //****************************************************************************
        //                       TRATAMENTO DO BIT 2                                 *
        //****************************************************************************
        If (nST3 >= 4)
            //Pouco papel
            ::oFlagsFisc:lPapelAcab := .T.
            nST3 -= 4
		EndIf
        //****************************************************************************
        //                       TRATAMENTO DO BIT 1                                 *
        //****************************************************************************
        If (nST3 >= 2)
            //Sem papel
            ::oFlagsFisc:lFimPapel := .T.
            nST3 -= 2
		EndIf
        //****************************************************************************
        //                       TRATAMENTO DO BIT 0                                 *
        //****************************************************************************
        If (nST3 >= 1)
            //Pouco papel
            ::oFlagsFisc:lPapelAcab := .T.
            nST3 -= 1
		EndIf
		//==============================================================================
        //Estado fiscal
        //==============================================================================        
        //****************************************************************************
        //                       TRATAMENTO DOS BITS 15 E 14                         *
        //****************************************************************************
        If (nST4 >= 32768)
            nST4 -= 32768
		EndIf

        If (nST4 >= 16384)
            nST4 -= 16384
		EndIf
        //****************************************************************************
        //                           TRATAMENTO DO BITS 12                           *
        //****************************************************************************
        If (nST4 >= 4096)
            //Modo de Interven��o T�cnica 
            ::oFlagsFisc:lIntervenc := .T.
            nST4 -= 4096			 
		Else
            //Modo de opera��o normal
            ::oFlagsFisc:lIntervenc := .F.
		EndIf
		//****************************************************************************
        //                       TRATAMENTO DOS BITS 11 E 10                         *
        //****************************************************************************
        If (nST4 >= 2048) 		
            nST4 -= 2048
		EndIf

		If (nST4 >= 1024)		
            nST4 -= 1024
		EndIf
        //****************************************************************************
        //                           TRATAMENTO DO BIT7                              *
        //****************************************************************************
        If (nST4 >= 128)
            nST4 -= 128
		EndIf

        //****************************************************************************
        //                       TRATAMENTO DOS BITS 3,2,1 E 0                       *
        //****************************************************************************
        If (nST4 == 8)
            //Comprovante N�o-Fiscal 
            ::oFlagsFisc:lNFAberto := .T.
        ElseIf (nST4 == 4)
            //Relat�rio Gerencial
            ::oFlagsFisc:lRGAberto := .T.        
        ElseIf (nST4 == 2)
            //Comprovante de Cr�dito ou D�bito
            ::oFlagsFisc:lCVAberto := .T.
        ElseIf (nST4 == 1)
            //Cupom Fiscal aberto
            ::oFlagsFisc:lCFAberto := .T.
            //Recupera a fase atual do cupom fiscal
            nFaseCupom := ::LeFaseCP()
            If (nFaseCupom == 1)
            	::oFlagsFisc:lCFItem := .T.
            ElseIf (nFaseCupom == 3)
            	::oFlagsFisc:lCFPagto := .T.
            ElseIf (nFaseCupom == 4)	
            	::oFlagsFisc:lCFTot := .T.
            EndIf            
        EndIf
        //****************************************************************************
        	    	
	    //Le os dados da jornada
	    oRetorno := ::LeDadJorn()
	    
		If ( oRetorno:cAcao == OK )
			
			cJornada := oRetorno:oRetorno
			
			//Reducao ja emitida	
			If SubStr(cJornada, 65, 1) == "0" .AND. SubStr(cJornada, 67, 1) == "0"  
				
				::oFlagsFisc:lInicioDia := .T.
            	::oFlagsFisc:lDiaFechad := .T.
            	::oFlagsFisc:lRedZPend  := .F.
				
			//Reducao pendente
			ElseIf SubStr(cJornada, 65, 1) == "1" .AND. SubStr(cJornada, 66, 1) == "1"
				
				::oFlagsFisc:lInicioDia := .T.
            	::oFlagsFisc:lDiaFechad := .F.
            	::oFlagsFisc:lRedZPend  := .T.
				
			//Necessita de inicio de dia
			ElseIf SubStr(cJornada, 65, 1) == "0" .AND. SubStr(cJornada, 67, 1) == "1"
				
				::oFlagsFisc:lInicioDia := .F.
            	::oFlagsFisc:lDiaFechad := .F.
            	::oFlagsFisc:lRedZPend  := .F.
				
			//Dia iniciado
			ElseIf SubStr(cJornada, 65, 1) == "1" .AND. SubStr(cJornada, 66, 1) == "0"
				
				::oFlagsFisc:lInicioDia := .T.
            	::oFlagsFisc:lDiaFechad := .F.
            	::oFlagsFisc:lRedZPend  := .F.
			
			EndIf
		EndIf
        	    
	Endif
		                               	
    oRetorno:oRetorno := ::oFlagsFisc	//Copia o valor da propriedade da classe
                	    	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BuscInfEcf�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em carregar as informacoes do ECF               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method BuscInfEcf() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	oRetorno:= ::LeDadoUsu()
	
	If ( oRetorno:cAcao == OK )
		oRetorno:= ::LeDadImp()	
	EndIf
		
	If ( oRetorno:cAcao == OK )
		oRetorno:= ::LeCliche()   
	EndIf
	
	If ( oRetorno:cAcao == OK )
		oRetorno:= ::LeOperador() 
	EndIf
	
	If ( oRetorno:cAcao == OK )
		oRetorno:= ::LeECFLoja()
	EndIf 
	
	If ( oRetorno:cAcao == OK )
		oRetorno:= ::LeAliq()
	EndIf
	
	If ( oRetorno:cAcao == OK )
		oRetorno:= ::LeTotNF()
	EndIf
	
	If ( oRetorno:cAcao == OK )
		oRetorno:= ::LeRelGer()
	EndIf
	
	If ( oRetorno:cAcao == OK )
		oRetorno:= ::LeFinaliz()
	EndIf
		
Return oRetorno    
     
//******************************************************************//
//						Metodos internos							//
//******************************************************************//                                                                     
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ObterEst  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em obter o estado do ecf do ECF                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ObterEst() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cLEstad	:= Space(20)	//String que recebera o retorno da funcao
	Local cEstado  	:= Space(4)		//String que recebera o estado da impressora	
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Estado_Impressora", cLEstad})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno
    oRetorno := ::TratarRet(cRetorno)
    
	If ( oRetorno:cAcao == OK )
	    cEstado := Upper(SubStr(oParams:Elements(3):cParametro,17,4))
	Else
		cEstado := "1"
	EndIf
    	
Return cEstado
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CarregMsg �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo carregamento das mensagens de    	  ���
���          �resposta possiveis da impressora.			  		  	  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �nenhum													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CarregMsg() Class LJAEpson
	
	::AdicMsgECF("1", "Erro de comunica��o", ERRO)
	::AdicMsgECF("0", "Sucesso", OK)
	::AdicMsgECF("999", "Fun��o n�o suportada por este modelo de ECF", ERRO)
	::AdicMsgECF("0000", "Resultado sem erro", OK)
	::AdicMsgECF("0001", "Erro interno", ERRO)
	::AdicMsgECF("0002", "Erro de inicia��o do equipamento", ERRO)
	::AdicMsgECF("0003", "Erro de processo interno", ERRO)
	::AdicMsgECF("0101", "Comando inv�lido para o estado atual", ERRO)
	::AdicMsgECF("0102", "Comando inv�lido para o documento atual", ERRO)
	::AdicMsgECF("0106", "Comando aceito apenas fora de interven��o", ERRO)
	::AdicMsgECF("0107", "Comando aceito apenas dentro de interven��o", ERRO)
	::AdicMsgECF("0108", "Comando inv�lido durante processo de scan", ERRO)
	::AdicMsgECF("0109", "Excesso de interven��es", ERRO)
	::AdicMsgECF("0201", "Comando com frame inv�lido", ERRO)
	::AdicMsgECF("0202", "Comando inv�lido", ERRO)
	::AdicMsgECF("0203", "Campos em excesso", ERRO)
	::AdicMsgECF("0204", "Campos em falta", ERRO)
	::AdicMsgECF("0205", "Campo n�o opcional", ERRO)
	::AdicMsgECF("0206", "Campo alfanum�rico inv�lido", ERRO)
	::AdicMsgECF("0207", "Campo alfab�tico inv�lido", ERRO)
	::AdicMsgECF("0208", "Campo num�rico inv�lido", ERRO)
	::AdicMsgECF("0209", "Campo bin�rio inv�lido", ERRO)
	::AdicMsgECF("020A", "Campo imprim�vel inv�lido", ERRO)
	::AdicMsgECF("020B", "Campo hexadecimal inv�lido", ERRO)
	::AdicMsgECF("020C", "Campo data inv�lido", ERRO)
	::AdicMsgECF("020D", "Campo hora inv�lido", ERRO)
	::AdicMsgECF("020E", "Campo com atributos de impress�o inv�lidos", ERRO)
	::AdicMsgECF("020F", "Campo booleano inv�lido", ERRO)
	::AdicMsgECF("0210", "Campo com tamanho inv�lido", ERRO)
	::AdicMsgECF("0211", "Extens�o de comando inv�lida", ERRO)
	::AdicMsgECF("0212", "C�digo de barra n�o permitido", ERRO)
	::AdicMsgECF("0213", "Atributos de impress�o n�o permitidos", ERRO)
	::AdicMsgECF("0214", "Atributos de impress�o inv�lidos", ERRO)
	::AdicMsgECF("0215", "C�digo de barras incorretamente definido", ERRO)
	::AdicMsgECF("0217", "Comando invalido para a porta selecionada", ERRO)
	::AdicMsgECF("0301", "Erro de hardware", ERRO)
	::AdicMsgECF("0302", "Impressora n�o est� pronta", ERRO)
	::AdicMsgECF("0303", "Erro de Impress�o", ERRO)
	::AdicMsgECF("0304", "Falta de papel", ERRO)
	::AdicMsgECF("0305", "Pouco papel dispon�vel", ERRO)
	::AdicMsgECF("0306", "Erro em carga ou expuls�o do papel", ERRO)
	::AdicMsgECF("0307", "Caracter�stica n�o suportada pela impressora", ERRO)
	::AdicMsgECF("0308", "Erro de display", ERRO)
	::AdicMsgECF("0309", "Seq��ncia de scan inv�lida", ERRO)
	::AdicMsgECF("030A", "N�mero de �rea de recorte inv�lido", ERRO)
	::AdicMsgECF("030B", "Scanner n�o preparado", ERRO)
	::AdicMsgECF("030C", "Qualidade de Logotipo n�o suportada pela impressora", ERRO)
	::AdicMsgECF("030E", "Erro de leitura do microc�digo", ERRO)
	::AdicMsgECF("0401", "N�mero de s�rie inv�lido", ERRO)
	::AdicMsgECF("0402","Requer dados de fiscaliza��o j� configurados", ERRO)
	::AdicMsgECF("0501", "Data / Hora n�o configurada", ERRO)
	::AdicMsgECF("0502", "Data inv�lida", ERRO)
	::AdicMsgECF("0503", "Data em intervalo inv�lido", ERRO)
	::AdicMsgECF("0504", "Nome operador inv�lido", ERRO)
	::AdicMsgECF("0505", "N�mero de caixa inv�lido", ERRO)
	::AdicMsgECF("0508", "Dados de Cabe�alho ou rodap� inv�lidos", ERRO)
	::AdicMsgECF("0509", "Excesso de fiscaliza��o", ERRO)
	::AdicMsgECF("050C", "N�mero m�ximo de meios de pagamento j� definidos", ERRO)
	::AdicMsgECF("050D", "Meio de pagamento j� definido", ERRO)
	::AdicMsgECF("050E", "Meio de pagamento inv�lido", ERRO)
	::AdicMsgECF("050F", "Descri��o do meio de pagamento inv�lido", ERRO)
	::AdicMsgECF("0510", "Valor m�ximo de desconto inv�lido", ERRO)
	::AdicMsgECF("0513", "Logotipo do usu�rio inv�lido", ERRO)
	::AdicMsgECF("0514", "Seq��ncia de logotipo inv�lido", ERRO)
	::AdicMsgECF("0515", "Configura��o de display inv�lida", ERRO)
	::AdicMsgECF("0516", "Dados do MICR inv�lidos", ERRO)
	::AdicMsgECF("0517", "Campo de endere�o inv�lido", ERRO)
	::AdicMsgECF("0518", "Nome da loja n�o definido", ERRO)
	::AdicMsgECF("0519", "Dados fiscais n�o definidos", ERRO)
	::AdicMsgECF("051A", "N�mero seq�encial do ECF inv�lido", ERRO)
	::AdicMsgECF("051B", "Simbologia do GT inv�lida, devem ser todos diferentes", ERRO)
	::AdicMsgECF("051C", "N�mero de CNPJ inv�lido", ERRO)
	::AdicMsgECF("051D", "Senha de fiscaliza��o inv�lida", ERRO)
	::AdicMsgECF("051E", "�ltimo documento deve ser uma redu��o Z", ERRO)
	::AdicMsgECF("051F", "S�mbolo da moeda igual ao atualmente cadastrado", ERRO)
	::AdicMsgECF("0520", "Identifica��o da al�quota n�o cadastrada", ERRO)
	::AdicMsgECF("0521", "Al�quota n�o cadastrada", ERRO)
	::AdicMsgECF("0601", "Mem�ria de Fita-detalhe esgotada", ERRO)
	::AdicMsgECF("0605", "N�mero de s�rie invalido para a Mem�ria de Fita-detalhe", ERRO)
	::AdicMsgECF("0606", "Mem�ria de Fita-detalhe n�o iniciada", ERRO)
	::AdicMsgECF("0607", "Mem�ria de Fita-detalhe n�o pode estar iniciada", ERRO)
	::AdicMsgECF("0608", "N�mero de s�rie da Mem�ria de Fita-detalhe n�o confere", ERRO)
	::AdicMsgECF("0609", "Erro Interno na Mem�ria de Fita-detalhe", ERRO)
	::AdicMsgECF("0701", "Valor inv�lido para o n�mero do registro", ERRO)
	::AdicMsgECF("0702", "Valor inv�lido para o n�mero do item", ERRO)
	::AdicMsgECF("0703", "Intervalo inv�lido para a leitura da MFD", ERRO)
	::AdicMsgECF("0704", "N�mero de usu�rio inv�lido para MFD", ERRO)
	::AdicMsgECF("0801", "Comando inv�lido com jornada fiscal fechada", ERRO)
	::AdicMsgECF("0802", "Comando inv�lido com jornada fiscal aberta", ERRO)
	::AdicMsgECF("0803", "Mem�ria Fiscal esgotada", ERRO)
	::AdicMsgECF("0804", "Jornada fiscal deve ser fechada", ERRO)
	::AdicMsgECF("0805", "N�o h� meios de pagamento definidos", ERRO)
	::AdicMsgECF("0806", "Excesso de meios de pagamento utilizados na jornada fiscal", ERRO)
	::AdicMsgECF("0807", "Jornada fiscal sem movimento de vendas", ERRO)
	::AdicMsgECF("0808", "Intervalo de jornada fiscal inv�lido", ERRO)
	::AdicMsgECF("0809", "Existem mais dados para serem lidos", ERRO)
	::AdicMsgECF("080A", "N�o existem mais dados para serem lidos", ERRO)
	::AdicMsgECF("080B", "N�o pode abrir jornada fiscal", ERRO)
	::AdicMsgECF("080C", "N�o pode fechar jornada fiscal", ERRO)
	::AdicMsgECF("080D", "Limite m�ximo do per�odo fiscal atingido", ERRO)
	::AdicMsgECF("080E", "Limite m�ximo do per�odo fiscal n�o atingido", ERRO)
	::AdicMsgECF("080F", "Abertura da jornada fiscal n�o permitida", ERRO)
	::AdicMsgECF("0901", "Valor muito grande", ERRO)
	::AdicMsgECF("0902", "Valor muito pequeno", ERRO)
	::AdicMsgECF("0903", "Itens em excesso", ERRO)
	::AdicMsgECF("0904", "Al�quotas em excesso", ERRO)
	::AdicMsgECF("0905", "Desconto ou acr�scimos em excesso", ERRO)
	::AdicMsgECF("0906", "Meios de pagamento em excesso", ERRO)
	::AdicMsgECF("0907", "Item n�o encontrado", ERRO)
	::AdicMsgECF("0908", "Meio de pagamento n�o encontrado", ERRO)
	::AdicMsgECF("0909", "Total nulo", ERRO)
	::AdicMsgECF("090C", "Tipo de pagamento n�o definido", ERRO)
	::AdicMsgECF("090F", "Al�quota n�o encontrada", ERRO)
	::AdicMsgECF("0910", "Al�quota inv�lida", ERRO)
	::AdicMsgECF("0911", "Excesso de meios de pagamento com CDC", ERRO)
	::AdicMsgECF("0912", "Meio de pagamento com CDC j� emitido", ERRO)
	::AdicMsgECF("0913", "Meio de pagamento com CDC ainda n�o emitido", ERRO)
	::AdicMsgECF("0914", "Leitura da Mem�ria Fiscal � intervalo CRZ inv�lido", ERRO)
	::AdicMsgECF("0915", "Leitura da Mem�ria Fiscal � intervalo de data inv�lido", ERRO)
	::AdicMsgECF("0A01", "Opera��o n�o permitida ap�s desconto / acr�scimo", ERRO)
	::AdicMsgECF("0A02", "Opera��o n�o permitida ap�s registro de pagamentos", ERRO)
	::AdicMsgECF("0A03", "Tipo de item inv�lido", ERRO)
	::AdicMsgECF("0A04", "Linha de descri��o em branco", ERRO)
	::AdicMsgECF("0A05", "Quantidade muito pequena", ERRO)
	::AdicMsgECF("0A06", "Quantidade muito grande", ERRO)
	::AdicMsgECF("0A07", "Total do item com valor muito alto", ERRO)
	::AdicMsgECF("0A08", "Opera��o n�o permitida antes do registro de pagamentos", ERRO)
	::AdicMsgECF("0A09", "Registro de pagamento incompleto", ERRO)
	::AdicMsgECF("0A0A", "Registro de pagamento finalizado", ERRO)
	::AdicMsgECF("0A0B", "Valor pago inv�lido", ERRO)
	::AdicMsgECF("0A0C", "Valor de desconto ou acr�scimo n�o permitido", ERRO)
	::AdicMsgECF("0A0E", "Valor n�o pode ser zero", ERRO)
	::AdicMsgECF("0A0F", "Opera��o n�o permitida antes do registro de itens", ERRO)
	::AdicMsgECF("0A11", "Cancelamento de desconto e acr�scimo somente para item atual", ERRO)
	::AdicMsgECF("0A12", "N�o foi poss�vel cancelar �ltimo Cupom Fiscal", ERRO)
	::AdicMsgECF("0A13", "�ltimo Cupom Fiscal n�o encontrado", ERRO)
	::AdicMsgECF("0A14", "�ltimo Comprovante N�o-Fiscal n�o encontrado", ERRO)
	::AdicMsgECF("0A15", "Cancelamento de CDC necess�ria", ERRO)
	::AdicMsgECF("0A16", "N�mero de item em Cupom Fiscal inv�lido", ERRO)
	::AdicMsgECF("0A17", "Opera��o somente permitida ap�s subtotaliza��o", ERRO)
	::AdicMsgECF("0A18", "Opera��o somente permitida durante a venda de itens", ERRO)
	::AdicMsgECF("0A19", "Opera��o n�o permitida em item com desconto ou acr�scimo", ERRO)
	::AdicMsgECF("0A1A", "D�gitos de quantidade inv�lidos", ERRO)
	::AdicMsgECF("0A1B", "D�gitos de valor unit�rio inv�lido", ERRO)
	::AdicMsgECF("0A1C", "N�o h� desconto ou acr�scimo a cancelar", ERRO)
	::AdicMsgECF("0A1D", "N�o h� item para cancelar", ERRO)
	::AdicMsgECF("0A1E", "Desconto ou acr�scimo somente no item atual", ERRO)
	::AdicMsgECF("0A1F", "Desconto ou acr�scimo j� efetuado", ERRO)
	::AdicMsgECF("0A20", "Desconto ou acr�scimo nulo n�o permitido", ERRO)
	::AdicMsgECF("0A21", "Valor unit�rio inv�lido", ERRO)
	::AdicMsgECF("0A22", "Quantidade inv�lida", ERRO)
	::AdicMsgECF("0A23", "C�digo de item inv�lido", ERRO)
	::AdicMsgECF("0A24", "Descri��o inv�lida", ERRO)
	::AdicMsgECF("0A25", "Opera��o de desconto ou acr�scimo n�o permitida", ERRO)
	::AdicMsgECF("0A26", "Mensagem promocional j� impressa", ERRO)
	::AdicMsgECF("0A27", "Linhas adicionais n�o podem ser impressas", ERRO)
	::AdicMsgECF("0A28", "Dados do consumidor j� impresso", ERRO)
	::AdicMsgECF("0A29", "Dados do consumidor somente no fim do documento", ERRO)
	::AdicMsgECF("0A2A", "Dados do consumidor somente no inicio do documento", ERRO)
	::AdicMsgECF("0A2B", "Comando Inv�lido para o item", ERRO)
	::AdicMsgECF("0E01", "N�mero de linhas em documento excedido", ERRO)
	::AdicMsgECF("0E02", "N�mero do relat�rio inv�lido", ERRO)
	::AdicMsgECF("0E03", "Opera��o n�o permitida ap�s registro de itens", ERRO)
	::AdicMsgECF("0E04", "Registro de valor nulo n�o permitido", ERRO)
	::AdicMsgECF("0E05", "N�o h� desconto a cancelar", ERRO)
	::AdicMsgECF("0E06", "N�o h� acr�scimo a cancelar", ERRO)
	::AdicMsgECF("0E07", "Opera��o somente permitida ap�s subtotaliza��o", ERRO)
	::AdicMsgECF("0E08", "Opera��o somente permitida durante registro de itens", ERRO)
	::AdicMsgECF("0E09", "Opera��o n�o-fiscal inv�lida", ERRO)
	::AdicMsgECF("0E0A", "�ltimo comprovante N�o-Fiscal n�o encontrado", ERRO)
	::AdicMsgECF("0E0B", "Meio de pagamento n�o encontrado", ERRO)
	::AdicMsgECF("0E0C", "N�o foi poss�vel imprimir nova via", ERRO)
	::AdicMsgECF("0E0D", "N�o foi poss�vel realizar reimpress�o", ERRO)
	::AdicMsgECF("0E0E", "N�o foi poss�vel imprimir nova parcela", ERRO)
	::AdicMsgECF("0E0F", "N�o h� mais parcelas a imprimir", ERRO)
	::AdicMsgECF("0E10", "Registro de item N�o-Fiscal inv�lido", ERRO)
	::AdicMsgECF("0E11", "Desconto ou acr�scimo j� efetuado", ERRO)
	::AdicMsgECF("0E12", "Valor de desconto ou acr�scimo inv�lido", ERRO)
	::AdicMsgECF("0E13", "N�o foi poss�vel cancelar o item", ERRO)
	::AdicMsgECF("0E14", "Itens em excesso", ERRO)
	::AdicMsgECF("0E15", "Opera��o N�o-Fiscal n�o cadastrada", ERRO)
	::AdicMsgECF("0E16", "Excesso de relat�rios / opera��es n�o-fiscais cadastradas", ERRO)
	::AdicMsgECF("0E17", "Relat�rio n�o encontrado", ERRO)
	::AdicMsgECF("0E18", "Comando n�o permitido", ERRO)
	::AdicMsgECF("0E19", "Comando n�o permitido em opera��es n�o-fiscais para movimento de monet�rio", ERRO)
	::AdicMsgECF("0E1A", "Comando permitido apenas em opera��es n�o-fiscais para movimento de monet�rio", ERRO)
	::AdicMsgECF("0E1B", "N�mero de parcelas inv�lido para a emiss�o de CCD", ERRO)
	::AdicMsgECF("0E1C", "Opera��o n�o fiscal j� cadastrada", ERRO)
	::AdicMsgECF("0E1D", "Relat�rio gerencial j� cadastrado", ERRO)
	::AdicMsgECF("0E1E", "Relat�rio Gerencial Inv�lido", ERRO)
	::AdicMsgECF("3001", "Configura��o de cheque n�o registrada", ERRO)
	::AdicMsgECF("3002", "Configura��o de cheque n�o encontrada", ERRO)
	::AdicMsgECF("3003", "Valor do cheque j� impresso", ERRO)
	::AdicMsgECF("3004", "Nominal ao cheque j� impresso", ERRO)
	::AdicMsgECF("3005", "Linhas adicionais no cheque j� impresso", ERRO)
	::AdicMsgECF("3006", "Autentica��o j� impressa", ERRO)
	::AdicMsgECF("3007", "N�mero m�ximo de autentica��es j� impresso", ERRO)
	::AdicMsgECF("FFFF", "Erro desconhecido", ERRO)
	 
Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeDadoUsu �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura e preenchimento dos dados   ���
���          �do usuario cadastrado na impressora.			  		  	  ���
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
Method LeDadoUsu() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(48)	//String que receber os dados do usuario da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Dados_Usuario", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
	
	// Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao == OK)    	
		::cCnpj := AllTrim(SubStr(oParams:Elements(3):cParametro,1,18))	// Copia o C.N.P.J da impressora
		::cIE := AllTrim(SubStr(oParams:Elements(3):cParametro,19,15)) 	// Copia o I.E da impressora
		::cIM := AllTrim(SubStr(oParams:Elements(3):cParametro,34,15))		// Copia o I.M da impressora	
	EndIf
    	
Return oRetorno
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeDadImp  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura e preenchimento dos dados   ���
���          �cadastrados na impressora.			  		  			  ���
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
Method LeDadImp() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(108)	//String que receber os dados da impressora
	Local cVersaoSB := Space(9)		//Versao Software Basico
	Local cDataIns	:= Space(9)		//Data de Instalacao SB
	Local cHoraIns	:= Space(7)		//Hora de Instalacao SB
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Dados_Impressora", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao == OK)    	
		::cNrSerie 	:= AllTrim(SubStr(oParams:Elements(3):cParametro,1,20))		// Copia o Numero de serie da impressora	
		::cFabric 	:= AllTrim(SubStr(oParams:Elements(3):cParametro,41,20))		// Copia o Fabricante da impressora
		::cModelo 	:= AllTrim(SubStr(oParams:Elements(3):cParametro,61,20))		// Copia o Modelo da impressora
		::cTipo   	:= AllTrim(SubStr(oParams:Elements(3):cParametro,81,20))		// Copia o Tipo da impressora
		::cFirmWare	:= AllTrim(SubStr(oParams:Elements(3):cParametro,101,8))		// Copia a Versao do Firmware da impressora
		
		//Verifica o estado do cupom (0 = Cupom nao aberto)
		If ::LeFaseCP() == 0 		
			//Prepara os parametros de envio 
			oParams := ::PrepParam({EPSON, "EPSON_Obter_Versao_SWBasicoEX", cVersaoSB, cDataIns, cHoraIns})
		    //Envia o comando    	
			cRetorno := ::EnviarCom(oParams)
			//Obtem o Estado da impressora
			cRetorno := ::ObterEst()
		    //Trata o retorno    
		    oRetorno := ::TratarRet(cRetorno)

		    // Caso o comando tenha sido executado com sucesso	    
			If(oRetorno:cAcao == OK)    	
				::cDataIns 	:= AllTrim(SubStr(oParams:Elements(4):cParametro,1,10))		// Copia a Data de Instalacao do Software Basico da impressora
				::cHoraIns 	:= AllTrim(SubStr(oParams:Elements(5):cParametro,1,8))			// Copia a Hora de Instalacao do Software Basico da impressora
	        EndIf
	        	        
		End If
	EndIf
	
Return oRetorno
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeCliche  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
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
Method LeCliche() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(160)	//String que receber o cliche da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Cliche_Usuario", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao == OK)    	
		::cRazaoSoc := SubStr(oParams:Elements(3):cParametro,1,40)			// Copia Razao Social da impressora
		::cFantasia := SubStr(oParams:Elements(3):cParametro,41,40)		// Copia o Nome Fantasia da impressora
		::cEndereco1 := SubStr(oParams:Elements(3):cParametro,81,40)		// Copia o Endereco 1 da impressora
		::cEndereco2 := SubStr(oParams:Elements(3):cParametro,121,40)		// Copia o Endereco 2 da impressora
	EndIf	 
	
Return oRetorno
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeOperador�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura e preenchimento do nome do  ���
���          �operador cadastrado na impressora.				  		  ���
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
Method LeOperador() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(20)	//String que receber o nome do operador da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Operador", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		::cOperador := AllTrim(oParams:Elements(3):cParametro)			// Copia o nome do operador da impressora
	EndIf
	
Return oRetorno
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeECFLoja �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura e preenchimento do numero   ���
���          �da loje e do ECF cadastrados na impressora.				  ���
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
Method LeECFLoja() Class LJAEpson	

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(7)		//String que receber o numero da loja e do ECF
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Numero_ECF_Loja", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao == OK)    	
    	::cNumEcf := AllTrim(SubStr(oParams:Elements(3):cParametro,1,3))	// Copia o numero do ECF
		::cLoja := AllTrim(SubStr(oParams:Elements(3):cParametro,4,4))		// Copia o numero da Loja
	EndIf	
	
Return oRetorno 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeAliq    �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura e preenchimento da tabela   ���
���          �de aliquotas cadastradas na impressora.				  	  ���
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
Method LeAliq() Class LJAEpson
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
Local nDX		:= 1			//Contador utilizado no comando "For"
Local cSimbolo	:= Space(2)		//String temporaria para armazenamento do simbolo da aliquota
Local cValor	:= Space(4)		//String temporaria para armazenamento do valor numerico da aliquota
Local cVendido	:= Space(17)	//String temporaria para armazenamento do valor vendido na aliquota

oRetorno := ::ExcTabAlq( @oParams )

// Caso o comando tenha sido executado com sucesso	
If (oRetorno:cAcao == OK)
	For nDX := 1 To Len(oParams:Elements(3):cParametro)
		cSimbolo := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,2))	// Copia o simbolo da aliquota
		nDX += 2															
		cValor := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,4))	// Copia o valor numerico da aliquota
		nDX += 4
		cVendido := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,17))	// Copia o valor vendido na aliquota
		nDX += 16
		//Caso o simbolo seja preenchido
		If !Empty(AllTrim(cSimbolo))			
			If SubStr(cSimbolo,1,1) == "T" //.OR. ( cSimbolo == "F" ) .OR. ( cSimbolo == "I" ) .OR. ( cSimbolo == "N" ) )
				::AdicAliq(cSimbolo,Val(cValor) / 100, .F.)// Insere na tabela a aliquota como I.C.M.S
			ElseIf SubStr(cSimbolo,1,1) == "S"
				::AdicAliq(cSimbolo,Val(cValor) / 100, .T.)// Insere na tabela a aliquota como I.S.S
			EndIf
		EndIf
	Next nDX    	
EndIf
	
Return oRetorno 

/*���������������������������������������������������������������������������
���Programa  �LeTotNF   �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura e preenchimento da tabela   ���
���          �de totalizadores nao fiscais cadastrados na impressora.	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method LeTotNF() Class LJAEpson
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros.
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial.
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao.
	Local cDados  	:= Space(681)	//String que receber a tabela de Totalizadores Nao Fiscais.
	Local nDX		:= 1			//Contador utilizado no comando "For".
	Local cIndice	:= Space(2)		//String temporaria para armazenamento do indice do totalizador.
	Local cDesc		:= Space(15)	//String temporaria para armazenamento da descricao do totalizador.
	Local cVendido	:= Space(17)	//String temporaria para armazenamento do valor acumulado no totalizador.
		    	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Tabela_NaoFiscais", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao == OK)    	
    	For nDX := 1 To Len(oParams:Elements(3):cParametro)
			cIndice := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,2))	// Copia o indice do totalizador.
			nDX += 2
			cDesc := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,15))	// Copia a descricao do totalizador.
			nDX += 15
			cVendido := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,17))	// Copia o valor acumulado no totalizador.
			nDX += 16
			//Caso a descricao seja preenchida
			If( cDesc != "")				
				::AdicTotNf(cIndice,cDesc,"E","") //Insere o totalizador nao fiscal na tabela.
			EndIf
		Next nDX    	
	EndIf

Return oRetorno 

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �LeRelGer  �Autor  �Vendas Clientes     � Data �  06/03/08      ���
����������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura e preenchimento da tabela   	 ���
���          �de relatorios gerenciais cadastrados na impressora.		  	 ���
����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	 ���
����������������������������������������������������������������������������͹��
���Parametros�nenhum												  		 ���
����������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  	 ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Method LeRelGer() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(421)	//String que receber a tabela de relatorios gerenciais cadastradas no ECF
	Local nDX		:= 1			//Contador utilizado no comando "For"
	Local cIndice	:= Space(2)		//String temporaria para armazenamento do indice do relatorio
	Local cDesc		:= Space(15)	//String temporaria para armazenamento da descricao do relatorio
	Local cContador	:= Space(4)		//String temporaria para armazenamento do contador de emissao do relatorio
		    	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Tabela_Relatorios_Gerenciais", cDados})
    //Envia o comando
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno
    oRetorno := ::TratarRet(cRetorno)

	// Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao == OK)    	
    	For nDX := 1 To Len(oParams:Elements(3):cParametro)
			cIndice := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,2))	// Copia o indice do relatorio.
			nDX += 2
			cDesc := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,15))	// Copia a descricao do relatorio.
			nDX += 15
			cContador := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,4))	// Copia o contador de emissao do relatorio.
			nDX += 3
			
			//Caso a descricao seja preenchida
			If( cDesc != "")				
				::AdicGerenc(cIndice,cDesc)		//Insere o relatorio gerencial na tabela.
			EndIf
		Next nDX    	
	EndIf

Return oRetorno 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeFinaliz �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura e preenchimento da tabela   ���
���          �de finalizadoras cadastradas na impressora.				  ���
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
Method LeFinaliz() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(881)	//String que receber a tabela de finalizadoras cadastradas no ECF
	Local nDX		:= 1			//Contador utilizado no comando "For"
	Local cIndice	:= Space(2)		//String temporaria para armazenamento do indice da finalizadora
	Local cDesc		:= Space(15)	//String temporaria para armazenamento da descricao da finalizadora
	Local cVendido	:= Space(26)	//String temporaria para armazenamento do valor recebido pela finalizadora
	Local cVinculado:= Space(1)		//String temporaria para armazenamento da indicacao de finalizadora vinculada
		    	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Tabela_Pagamentos", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
    	For nDX := 1 To Len(oParams:Elements(3):cParametro)
			cIndice := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,2))		// Copia o indice do relatorio.
			nDX += 2
			cDesc := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,15))		// Copia a descricao da finalizadora.
			nDX += 15
			cVendido := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,26))		// Copia o valor recebido pela finalizadora.
			nDX += 26
			cVinculado := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,1))	// Copia a indicacao de finalizadora vinculada.
			
			//Caso a descricao seja preenchida
			If( cDesc != "")
				If ( cVinculado == "S" )
					::AdicForma(cIndice,cDesc,.T.)		//Insere a finalizadora vinculada na tabela.
				Else
					::AdicForma(cIndice,cDesc,.F.)		//Insere a finalizadora nao vinculada na tabela.
				EndIf
			EndIf
		Next nDX    	
	EndIf

Return oRetorno 

/*���������������������������������������������������������������������������
���Programa  �LeDataJor �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura da data de abertura da	  ���
���          �jornada.													  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf contendo a data e hora do movimento do ���
���			 �ecf no formato dd/mm/aaaa hh:mm:SS (19 bytes)				  ���
���������������������������������������������������������������������������*/
Method LeDataJor() Class LJAEpson

Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
Local cDados  	:= Space(14)	//String que recebera a data e hora de abertura da jornada

//Prepara os parametros de envio 
oParams := ::PrepParam({EPSON, "EPSON_Obter_Data_Hora_Jornada", cDados})
//Envia o comando    	
cRetorno := ::EnviarCom(oParams)
//Obtem o Estado da impressora
cRetorno := ::ObterEst()
//Trata o retorno    
oRetorno := ::TratarRet(cRetorno)

// Caso o comando tenha sido executado com sucesso	
If(oRetorno:cAcao == OK)    	
	oRetorno:oRetorno :=	Substr(oParams:Elements(3):cParametro,1,2)  + "/" +;
							Substr(oParams:Elements(3):cParametro,3,2)  + "/" +;
						  	Substr(oParams:Elements(3):cParametro,5,4)  + " " +;
						  	Substr(oParams:Elements(3):cParametro,9,2)  + ":" +;
						  	Substr(oParams:Elements(3):cParametro,11,2) + ":" +;
						  	Substr(oParams:Elements(3):cParametro,13,2)
EndIf
	
Return oRetorno
  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeGT      �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do GT da impressora.		  ���
���          �															  ���
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
Method LeGT() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(18)	//String que recebera GT da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_GT", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Substr(oParams:Elements(3):cParametro,1,18)
	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeGTIni   �Autor  �Vendas Clientes     � Data �  21/07/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do GT inicial da impressora.���
���          �															  ���
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
Method LeGTIni() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(1167)	//String que recebera os dados da ultimoa RZ da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Dados_Ultima_RZ", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Substr(oParams:Elements(3):cParametro,87,18)
	EndIf
	
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �LeCOO     �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do ultimo COO impresso.     ���
���          � 															  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method LeCOO() Class LJAEpson

Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
Local cDados  	:= Space(84)	//String que recebera os contadores da impressora

//Prepara os parametros de envio 
oParams := ::PrepParam({EPSON, "EPSON_Obter_Contadores", cDados})
//Envia o comando    	
cRetorno := ::EnviarCom(oParams)
//Obtem o Estado da impressora
cRetorno := ::ObterEst()
//Trata o retorno    
oRetorno := ::TratarRet(cRetorno)

// Caso o comando tenha sido executado com sucesso	
If(oRetorno:cAcao == OK)    	
	oRetorno:oRetorno := Substr(oParams:Elements(3):cParametro,1,6)
EndIf
	
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �LeTotCanc �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio dos    		  ���
���          �cancelamentos executados na impressora ( ICMS )  	          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method LeTotCanc() Class LJAEpson
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(51)	//String que recebera os totais cancelados da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Total_Cancelado", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno :=	Val(Substr(oParams:Elements(3):cParametro,1,17)) / 100
	EndIf
	
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �LeTotCanISS �Autor  �Vendas Clientes     � Data �  06/03/08 ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio dos    		  ���
���          �cancelamentos executados na impressora (  ISS )  	  		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method LeTotCanISS() Class LJAEpson
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(51)	//String que recebera os totais cancelados da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Total_Cancelado", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno :=	Val(Substr(oParams:Elements(3):cParametro,18,17)) / 100
	EndIf
	
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �LeTotDesc �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio dos    		  ���
���          �descontos executados na impressora ( ICMS  )  		  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method LeTotDesc() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(51)	//String que recebera os totais de desconto da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Total_Descontos", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno :=	Val(Substr(oParams:Elements(3):cParametro,1,17)) / 100
	EndIf

Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �LeTotDesIss �Autor  �Vendas Clientes     � Data �  17/06/13 ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio dos    		  ���
���          �descontos executados na impressora ( ISS )  	  	  		   ��
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method LeTotDesISS() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(51)	//String que recebera os totais de desconto da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Total_Descontos", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno :=	Val(Substr(oParams:Elements(3):cParametro,18,17)) / 100
	EndIf

Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �LeTotIsent�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio das vendas	  ���
���          �Isentas executadas na impressora ( I + IS )  				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method LeTotIsent() Class LJAEpson
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
Local nDX		:= 1			//Contador utilizado no comando "For"
Local cSimbolo	:= Space(2)		//String temporaria para armazenamento do simbolo da aliquota
Local cValor	:= Space(4)		//String temporaria para armazenamento do valor numerico da aliquota
Local cVendido	:= Space(17)	//String temporaria para armazenamento do valor vendido na aliquota
Local nSoma		:= 0
	
oRetorno := ::ExcTabAlq( @oParams )

// Caso o comando tenha sido executado com sucesso	
If oRetorno:cAcao == OK
	For nDX := 1 To Len(oParams:Elements(3):cParametro)
		cSimbolo := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,2))	// Copia o simbolo da aliquota
		nDX += 2
		cValor := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,4))	// Copia o valor numerico da aliquota
		nDX += 4
		cVendido := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,17))	// Copia o valor vendido na aliquota
		nDX += 16
		//Caso o simbolo seja preenchido
		If !Empty(AllTrim(cSimbolo))
			If cSimbolo == "I"
				nSoma += Val(cVendido) / 100
			EndIf
		EndIf
	Next nDX
EndIf

oRetorno:oRetorno := nSoma
	
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �LeTotNTrib�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio dos    		  ���
���          �nao tributados vendidos na impressora ( ICMS + ISS  )  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method LeTotNTrib() Class LJAEpson
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
Local cDados  	:= Space(533)	//String que receber a tabela de aliquotas cadastradas no ECF
Local nDX		:= 1			//Contador utilizado no comando "For"
Local cSimbolo	:= Space(2)		//String temporaria para armazenamento do simbolo da aliquota
Local cValor	:= Space(4)		//String temporaria para armazenamento do valor numerico da aliquota
Local cVendido	:= Space(17)	//String temporaria para armazenamento do valor vendido na aliquota
Local nSoma		:= 0
	
oRetorno := ::ExcTabAlq( @oParams )

// Caso o comando tenha sido executado com sucesso	
If(oRetorno:cAcao == OK)    	
	For nDX := 1 To Len(oParams:Elements(3):cParametro)
		cSimbolo := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,2))	// Copia o simbolo da aliquota
		nDX += 2															
		cValor := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,4))	// Copia o valor numerico da aliquota
		nDX += 4
		cVendido := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,17))	// Copia o valor vendido na aliquota
		nDX += 16
		//Caso o simbolo seja preenchido
		If !Empty(AllTrim(cSimbolo))
			If cSimbolo == "N"
				nSoma += Val(cVendido) / 100
			EndIf
		EndIf
	Next nDX    	
EndIf

oRetorno:oRetorno := nSoma

Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �LeTotIss  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
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
Method LeTotIss() Class LJAEpson
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
Local cDados  	:= Space(51)	//String que recebera os totais de desconto da impressora

//Prepara os parametros de envio 
oParams := ::PrepParam({EPSON, "EPSON_Obter_Total_Aliquotas", cDados})
//Envia o comando    	
cRetorno := ::EnviarCom(oParams)
//Obtem o Estado da impressora
cRetorno := ::ObterEst()
//Trata o retorno    
oRetorno := ::TratarRet(cRetorno)

// Caso o comando tenha sido executado com sucesso	
If(oRetorno:cAcao == OK)
	oRetorno:oRetorno := Val(Substr(oParams:Elements(3):cParametro,18,17)) / 100
EndIf
	
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �LeVndLiq  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
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
Method LeVndLiq() Class LJAEpson                                          
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

/*���������������������������������������������������������������������������
���Programa  �LeVndBrut �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura da Venda Bruta Atual.		  ���
���          �															  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method LeVndBrut() Class LJAEpson	

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados1  	:= Space(15)	//String que recebera a venda bruta atual da impressora
	Local cDados2  	:= Space(15)	//String que recebera a venda bruta anterior da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Venda_Bruta", cDados1, cDados2})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Val(Substr(oParams:Elements(3):cParametro,1,15)) / 100
	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeFaseCP  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em verificar o estado do cupom.		  ���
���          �															  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Numerico		    										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeFaseCP() Class LJAEpson	

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(56)	//String que recebera a venda bruta atual da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Estado_Cupom", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Val(Substr(oParams:Elements(3):cParametro,55,2))
	EndIf
	
Return oRetorno:oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetCancIt �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar se pode cancelar todos os 	  ���
���          �itens														  ���
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
Method GetCancIt() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
   	oRetorno:oRetorno := "TODOS"

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetVlSupr �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar o valor do suprimento   	  ���
���          �itens														  ���
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
Method GetVlSupr() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
   	oRetorno:oRetorno := 0
   	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetItImp  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar se todos os itens foram   	  ���
���          �impressos													  ���
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
Method GetItImp() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
   	oRetorno:oRetorno := .T.
   	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetPosFunc�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar se ecf retorna o Subtotal e o���
���          �numero de itens impressos no cupom fiscal.				  ���
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
Method GetPosFunc() Class LJAEpson

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
   	oRetorno:oRetorno := .F.
   	
Return oRetorno  

/*���������������������������������������������������������������������������
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
���������������������������������������������������������������������������*/
Method GetPathMFD() Class LJAEpson

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
   	oRetorno:oRetorno := ::cPathMFD //Copia o valor da propriedade da classe
   	
Return oRetorno  

/*���������������������������������������������������������������������������
���Programa  �GetPathMFBin�Autor  �Vendas Clientes     � Data �  10/09/09 ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar o caminho e nome do arquivo  ���
���          �de Memoria Fiscal Binario.                   				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method GetPathMFBin() Class LJAEpson
Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao

oRetorno := ::TratarRet("0000")
oRetorno:oRetorno := ::cPathBin + "mfiscal.bin" //Copia o valor da propriedade da classe
   	
Return oRetorno  

/*���������������������������������������������������������������������������
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
���������������������������������������������������������������������������*/
Method GetPathMF() Class LJAEpson
Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao

oRetorno := ::TratarRet("0000")
oRetorno:oRetorno := ::cPathMF  //Copia o valor da propriedade da classe
   	
Return oRetorno

/*������������������������������������������������������������������������������
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
������������������������������������������������������������������������������*/
Method GetPathTipoE(cBinario) Class LJAEpson
Local oRetorno 	:= Nil			 	//Objeto que sera retornado pela funcao

Default cBinario	:= "0"				//Gera��o do Arquivo Bin�rio

oRetorno := ::TratarRet("0000")
oRetorno:oRetorno := IIF( cBinario == "1", ::cPathBin+"Download.bin" , ::cPathTipoE)  //Copia o valor da propriedade da classe
   	
Return oRetorno   

/*���������������������������������������������������������������������������
���Programa  �GetLetMem �Autor  �Vendas Clientes     � Data �  10/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a letra indicativa de MF adicional  				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method GetLetMem() Class LJAEpson
Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao

oRetorno := Self:TratarRet("0000")
oRetorno:oRetorno := ""			 //Copia o valor da propriedade da classe

Return oRetorno
    
/*���������������������������������������������������������������������������
���Programa  �GetTipEcf	�Autor  �Vendas Clientes     � Data �  10/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna Tipo de ECF  										  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method GetTipEcf() Class LJAEpson
Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao

oRetorno := Self:TratarRet("0000")
oRetorno:oRetorno := ::cTipo	 //Copia o valor da propriedade da classe

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
Method GetDatSW() Class LJAEpson

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0000")
    
   	oRetorno:oRetorno := ""			 //Copia o valor da propriedade da classe

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
Method GetHorSW() Class LJAEpson

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0000")
    
   	oRetorno:oRetorno := ""			 //Copia o valor da propriedade da classe

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
Method GetGrTIni() Class LJAEpson

	Local oRetorno	:= ::LeGtIni()
   	
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
Method GetNumCnf() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(84)	//String que recebera os contadores da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Contadores", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Substr(oParams:Elements(3):cParametro,19,6)
	EndIf

Return oRetorno  
	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetNumCrg �Autor  �Vendas Clientes     � Data �  10/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o Contador Geral de Relatorio Gerencial			  ���
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
Method GetNumCrg() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(84)	//String que recebera os contadores da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Contadores", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Substr(oParams:Elements(3):cParametro,37,6)
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
Method GetNumCcc() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(84)	//String que recebera os contadores da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Contadores", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Substr(oParams:Elements(3):cParametro,25,6)
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
Method GetDtUDoc() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(30)	//String que recebera os contadores da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Informacao_Ultimo_Documento", cDados})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Substr(oParams:Elements(3):cParametro,3,8) 	//Copia o valor da data do ultimo documento
		oRetorno:oRetorno += Substr(oParams:Elements(3):cParametro,11,6)	//Copia o valor da hora do ultimo documento
	EndIf

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
Method GetCodEcf() Class LJAEpson

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cCodEcf  	:= Space(7)		//String que recebera o codigo nacional do ECF
	Local cNomeArq 	:= Space(33)	//String que recebera o nome do arquivo para o PAf-ECF
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Codigo_Nacional_ECF", cCodEcf, cNomeArq})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Substr(oParams:Elements(3):cParametro,1,6) 	//Copia o valor do codigo nacional do ECF
	EndIf

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeDadJorn �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em ler os dados da jornada				  ���
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
Method LeDadJorn() Class LJAEpson
	    
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cJornada	:= Space(70)	//Dados da jornada
	
	//Prepara os parametros de envio
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Dados_Jornada", cJornada})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno
    oRetorno := ::TratarRet(cRetorno)
	
	// Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := oParams:Elements(3):cParametro
	EndIf
	
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �LeCupIni  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em ler o cupom inicial do dia  		  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method LeCupIni() Class LJAEpson
	
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	
oRetorno := ::LeDadJorn()

// Caso o comando tenha sido executado com sucesso	
If(oRetorno:cAcao == OK)    	
	oRetorno:oRetorno := SubStr(oRetorno:oRetorno, 29, 6)
EndIf
				
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �MFDData   �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel gerar a Leitura da fita detalhe por data ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPD1 (1 - dDtInicio) - Data inicial do periodo (ddmmaaaa). ���
���			 �EXPD2 (2 - dDtFim) - Data final do periodo (ddmmaaaa).	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method MFDData(dDtInicio, dDtFim) Class LJAEpson
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
Local cDtInicio := ""			//Data inicio
Local cDtFim 	:= ""			//Data fim

cDtInicio := Padl(Day(dDtInicio), 2 , "0") + Padl(Month(dDtInicio), 2 , "0") + AllTrim(Str(Year(dDtInicio)))
cDtFim  := Padl(Day(dDtFim), 2 , "0") + Padl(Month(dDtFim), 2 , "0") + AllTrim(Str(Year(dDtFim)))
		
oParams := ::PrepParam({EPSON, "EPSON_Obter_Dados_MF_MFD", cDtInicio, cDtFim, "0", "65535", "0", "0", "C:\LeituraMFD"})
cRetorno := ::EnviarCom(oParams)
cRetorno := ::ObterEst()
oRetorno := ::TratarRet(cRetorno)
::InicVar() //Inicializa variaveis
    
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �MFDCoo    �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel gerar a Leitura da fita detalhe por Coo  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cCooInicio) - Coo inicial						  ���
���			 �EXPC2 (2 - cCooFim) - Coo final							  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method MFDCoo(cCooInicio, cCooFim) Class LJAEpson
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
		
oParams := ::PrepParam({EPSON, "EPSON_Obter_Dados_MF_MFD", cCooInicio, cCooFim, "2", "65535", "0", "0", "C:\LeituraMFD"})
cRetorno := ::EnviarCom(oParams)
cRetorno := ::ObterEst()
oRetorno := ::TratarRet(cRetorno)
::InicVar() //Inicializa variaveis
    
Return oRetorno

/*��������������������������������������������������������������������������������������
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
��������������������������������������������������������������������������������������*/
Method TipoEData(cDatInicio, cDatFim, cPathArq, cBinario) Class LJAEpson
Local oParams 	:= Nil					//Objeto para passagem dos parametros
Local cRetorno 	:= ""					//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil					//Objeto que sera retornado pela funcao
Local dDtInicio	:= CtoD(cDatInicio)		//Variavel para auxiliar na formatacao da data                     
Local dDtFim	:= CtoD(cDatFim)		//Variavel para auxiliar na formatacao da data
                     
Default cBinario := "0"				//Gera��o do Arquivo Bin�rio                    	
Default cPathArq := "C:\Cotepe1704.TXT"	//Path+Arquivo de saida

cPathArq 	:= SubStr(cPathArq,1,Len(cPathArq)-4)	//Ajusta nome do arquivo, epson nao recebe extens�o		              
cDatInicio	:= Padl(Day(dDtInicio), 2 , "0") + Padl(Month(dDtInicio), 2 , "0") + AllTrim(Str(Year(dDtInicio)))
cDatFim		:= Padl(Day(dDtFim), 2 , "0") + Padl(Month(dDtFim), 2 , "0") + AllTrim(Str(Year(dDtFim)))

/*Prepara os parametros de envio e processamento do arquivo Cotepe 17/04 (Registros E01...E21, alguns 
somente s�o gerados se houver dados Exemplo E03 - Identificacao dos prestadores de servico cadastrados no ECF)*/                                                                                
oParams	:= ::PrepParam({EPSON, "EPSON_Obter_Dados_MF_MFD", cDatInicio, cDatFim, "0", "0", "10", "0", cPathArq})
cRetorno:= ::EnviarCom(oParams)
cRetorno:= ::ObterEst()
oRetorno:= ::TratarRet(cRetorno)
//Inicializa variaveis
::InicVar()
    
Return oRetorno  

/*��������������������������������������������������������������������������������������
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
��������������������������������������������������������������������������������������*/
Method TipoECrz(cCrzInicio, cCrzFim, cPathArq, cBinario) Class LJAEpson
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
Local cArquivo	:= ""			//Local de grava��o do arquivo bin�rio

Default cBinario := "0"				//Gera��o do Arquivo Bin�rio
Default cPathArq := "C:\Cotepe1704.TXT"	//Path+Arquivo de saida

cPathArq 	:= SubStr(cPathArq,1,Len(cPathArq)-4)	//Ajusta nome do arquivo, epson nao recebe extens�o		
oParams	:= ::PrepParam({EPSON, "EPSON_Obter_Dados_MF_MFD", cCrzInicio, cCrzFim, "1", "0", "10", "0", cPathArq})
cRetorno:= ::EnviarCom(oParams)
cRetorno:= ::ObterEst()
oRetorno:= ::TratarRet(cRetorno)
//Inicializa variaveis
::InicVar()
    
Return oRetorno  

/*���������������������������������������������������������������������������
���Programa  �HexToDec  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em converte Hexadecimal p/ Decimal       ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cHex) - valor hexadecimal						  ���
�������������������������������������������������������������������������͹��
���Retorno   �Numerico													  ���
���������������������������������������������������������������������������*/
Method HexToDec(cHex) Class LJAEpson
Local nDec := 0
Local nMul := 0
Local cDig
Local nPos
Local nRet := 0

For nPos := Len(cHex) To 1 Step -1
	cDig := Upper(SubStr(cHex,nPos,1))
	nDec += IIF(cDig $ "ABCDEF", Asc(cDig)-55, Val(cDig)) * (16^nMul)
	nMul ++
next

nRet := Int(nDec) 

Return nRet

/*���������������������������������������������������������������������������
���Programa  �BuscaAliq �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel buscar aliquota                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cTribut) - Tributacao          			   	  ���
���			 �EXPN1 (2 - nAliquota) - Valor da aliquota   				  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method BuscaAliq(cTribut, nAliquota) Class LJAEpson
Local cRetorno 	:= ""     			//Retorno do metodo
Local nCount	:= 0				//Variavel de controle contador
Local oAliquota := Nil				//Objeto com os dados da aliquota

If SubsTr(cTribut,1,2) $ "FS|IS|NS"
	cRetorno := SubsTr(cTribut,1,2) 

ElseIf SubsTr(cTribut,1,1) == "F"
	//Substituido
	cRetorno := "F"
	
ElseIf SubsTr(cTribut,1,1) == "I"
	//Isento
	cRetorno := "I"
	
ElseIf SubsTr(cTribut,1,1) == "N"
    //Nao tributado
	cRetorno := "N"
	
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
���Programa  �InicVar   �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em inicializar variaveis                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method InicVar() Class LJAEpson

::oFormasVen := Nil

Return Nil

/*���������������������������������������������������������������������������
���Programa  �GuardarPgt�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura do cupom fiscal            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cForma) - Descricao da forma      			   	  ���
���			 �EXPN1 (2 - nValor) - Valor da forma   				  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method GuardarPgt(cForma, nValor) Class LJAEpson
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

/*���������������������������������������������������������������������������
���Programa  �LeGerencias�Autor  �Vendas Clientes     � Data �  06/11/12  ���
�������������������������������������������������������������������������͹��
���Desc.     � 													          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cForma) - Descricao da forma      			   	  ���
���			 �EXPN1 (2 - nValor) - Valor da forma   				  	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method LeGerencias() Class LJAEpson
Local aRet 		:= {} 			//Array contendo os relatorios gerenciais
Local cInd		:= ""			//Indice do relat�rio no ECF
Local cDesc		:= ""           //Descri��o do relat�rio no ECF
Local cContador := ""			//Contador do rel gerencial
Local cDados  	:= Space(421)	//String que receber a tabela de relatorios gerenciais cadastradas no ECF
Local nDX       := 0
Local oParams  := Nil

//Prepara os parametros de envio 
oParams := ::PrepParam({EPSON, "EPSON_Obter_Tabela_Relatorios_Gerenciais", cDados})
//Envia o comando
cRetorno := ::EnviarCom(oParams)
//Obtem o Estado da impressora
cRetorno := ::ObterEst()
//Trata o retorno
oRetorno := ::TratarRet(cRetorno)
// Caso o comando tenha sido executado com sucesso
If oRetorno:cAcao == "OK"
	For nDX := 1 To Len(oParams:Elements(3):cParametro)
		cInd  := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,2))	// Copia o indice do relatorio.
		nDX += 2
		cDesc := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,15))	// Copia a descricao do relatorio.
		nDX += 15
		cContador := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,4))	// Copia o contador de emissao do relatorio.
		nDX += 3
		If !Empty(AllTrim(cDesc))
			Aadd(aRet,{cInd,cDesc,cContador})
		EndIf	
	Next nDX    	
EndIf

Return aRet

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
Method TrataTags( cMensagem ) Class LJAEpson
Local cMsg := ""

DEFAULT cMensagem := ""

cMsg := cMensagem

While At(TAG_NORMAL_INI, cMsg) > 0
   cMsg := StrTran(cMsg,TAG_NORMAL_INI,cTagAllFormFim)
   cMsg := StrTran(cMsg,TAG_NORMAL_FIM,cTagAllFormFim)
EndDo

While At(TAG_NEGRITO_INI, cMsg) > 0
   cMsg := StrTran(cMsg,TAG_NEGRITO_INI,cTagNegrIni)
   cMsg := StrTran(cMsg,TAG_NEGRITO_FIM,cTagNegrFim)
EndDo

While At(TAG_SUBLI_INI, cMsg) > 0
   cMsg := StrTran(cMsg,TAG_SUBLI_INI,cTagSubliIni)
   cMsg := StrTran(cMsg,TAG_SUBLI_FIM,cTagSubliFim)
EndDo

While At(TAG_EXPAN_INI, cMsg) > 0
   cMsg := StrTran(cMsg,TAG_EXPAN_INI,cTagLrgDuplaIni)
   cMsg := StrTran(cMsg,TAG_EXPAN_FIM,cTagLrgDuplaFim)
EndDo

cMsg := RemoveTags(cMsg)

Return cMsg

/*�������������������������������������������������������������������������������
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
�������������������������������������������������������������������������������*/
Method GetCodDllECF() Class LJAEpson       
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cCodEcf  	:= Space(7)		//String que recebera o codigo nacional do ECF
	Local cNomeArq 	:= Space(33)	//String que recebera o nome do arquivo para o PAf-ECF
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({EPSON, "EPSON_Obter_Codigo_Nacional_ECF", cCodEcf, cNomeArq})
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst()
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Substr(oParams:Elements(3):cParametro,1,6) 	//Copia o valor do codigo nacional do ECF
	EndIf

Return oRetorno
 
/*�������������������������������������������������������������������������������
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
�������������������������������������������������������������������������������*/
Method GetNomeECF() Class LJAEpson       
Local cMarca := space(15)  
Local cModelo := space(20)
Local cFirmWare := ""
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local oRetorno 	:= ::TratarRet("0000")			//Objeto que sera retornado pela funcao	

//AbrirPorta traz as informa��es
oRetorno:oRetorno := ""	//Copia o valor da propriedade da classe
If !Empty(::cFabric) .AND. !Empty(::cModelo)  
	oRetorno:oRetorno := ::cFabric + " " + ;
						::cModelo + " - V. "+;
						::cFirmWare
EndIf
	
Return oRetorno 

/*�������������������������������������������������������������������������������
���Programa  �DownMF		�Autor  �Vendas Clientes     � Data �  10/12/2013 ���
�����������������������������������������������������������������������������͹��
���Desc.     �Realiza o Download da Mem�ria fiscal no formato bin�rio		  ���
���          �+ " - V. " + Vers�o do Firmware                                 ���
�����������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                      	  ���
�����������������������������������������������������������������������������͹��
���Parametros�nenhum											    		  ���
�����������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf											  ���
�������������������������������������������������������������������������������*/
Method DownMF() Class LJAEpson  
Local oParams 	:= Nil					//Objeto para passagem dos parametros
Local cRetorno 	:= ""					//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil					//Objeto que sera retornado pela funcao
Local cArquivo		:= ""				//Nome do arquivo gerado

oParams := ::GetPathMFBin()
cArquivo := AllTrim(oParams:oRetorno)    
If Empty(cArquivo)
	cArquivo := "C:\mfiscal.bin"
EndIf

oParams := ::PrepParam({EPSON, "EPSON_Obter_Arquivo_Binario_MF", cArquivo})
cRetorno := ::EnviarCom(oParams)
cRetorno := ::ObterEst()
oRetorno := ::TratarRet(cRetorno)	
   
Return oRetorno

/*��������������������������������������������������������������������������������������
���Programa  �RedZDado  �Autor  �Vendas Clientes     � Data �  10//12/2013 			 ���
������������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar os dados da Redu��o                   .���
������������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  			 ���
������������������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										 			 ���
��������������������������������������������������������������������������������������*/
Method RedZDado() Class LJAEpson
Local oRetorno := Nil			  //Objeto que sera retornado pela funcao   
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
Method IdCliente(cCnpj, cNome, cEnd) Class LJAEpson
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
Local cEndereco1:= Space(40)	//String para gravar os primeiros 40 caracteres do endereco.
Local cEndereco2:= Space(39)	//String para gravar os 39 caracteres posteriores aos primeiros 40 caracteres do endereco.

//Inicializando variaveis
::InicVar()
     
// Quebra em 2 partes (se necessario) o endereco do cliente.
If Len(cEnd) > 30
	cEndereco1 := SubStr(cEnd,1,30)
	If (Len(cEnd) - 30) > 39
		cEndereco2 := SubStr(cEnd,41,39)
	Else
		cEndereco2 := SubStr(cEnd,41,(Len(cEnd) - 40))
	EndIf
Else
	cEndereco1 := SubStr(cEnd,1,Len(cEnd))
	cEndereco2 := ""
EndIf 

If Len(cNome) > 30
	cNome	:= SubStr(cNome,1,30)	
EndIf
	
oParams := ::PrepParam({EPSON, "EPSON_Fiscal_Dados_Consumidor", AllTrim(cCnpj), cNome, cEndereco1, cEndereco2, "3"})
cRetorno := ::EnviarCom(oParams)
cRetorno := ::ObterEst()
oRetorno := ::TratarRet(cRetorno)	
	
Return oRetorno

//--------------------------------------------------------
/*/{Protheus.doc} DownloadMFD
Abre o cupom fiscal
@param1		cTipo -
@param2		cInicio -  
@param3		cFinal - 
@author  	Varejo
@version 	P12
@since   	14/03/2018
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
/*/
//--------------------------------------------------------
Method DownloadMFD(cBinario,cTipo,cInicio,cFinal) Class LJAEpson
Local oRetorno := Nil			  //Objeto que sera retornado pela funcao   

oRetorno := ::TratarRet("0000")
LjGrvLog(Nil,"Esse modelo n�o executa esse comando, retorno OK")

Return oRetorno

//----------------------------------------------------------
/*{Protheus.doc} GetISSIsen
Captura total de iss isento do ECF
@author  	Julio.Nery
@version 	P12
@since   	22/10/2019
*/
//--------------------------------------------------------
Method GetISSIsen() Class LJAEpson

Local oRetorno 	:= ::LeTotISSIs()

Return oRetorno

//----------------------------------------------------------
/*{Protheus.doc} GetIssNTri
Captura total de iss nao tributado do ECF
@author  	Julio.Nery
@version 	P12
@since   	22/10/2019
*/
//--------------------------------------------------------
Method GetIssNTri() Class LJAEpson

Local oRetorno 	:= ::LeTotISSNT()

Return oRetorno

//----------------------------------------------------------
/*{Protheus.doc} GetIssSubs
Captura total de iss substituido do ECF
@author  	Julio.Nery
@version 	P12
@since   	22/10/2019
*/
//--------------------------------------------------------
Method GetIssSubs() Class LJAEpson

Local oRetorno 	:= ::LeTotIssSu()

Return oRetorno

//----------------------------------------------------------
/*{Protheus.doc} LeTotISSIs
Le o total de ISS Isento
@author  	Julio.Nery
@version 	P12
@since   	22/10/2019
*/
//--------------------------------------------------------
Method LeTotISSIs() Class LJAEpson
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
Local nDX		:= 1			//Contador utilizado no comando "For"
Local cSimbolo	:= Space(2)		//String temporaria para armazenamento do simbolo da aliquota
Local cValor	:= Space(4)		//String temporaria para armazenamento do valor numerico da aliquota
Local cVendido	:= Space(17)	//String temporaria para armazenamento do valor vendido na aliquota
Local nSoma		:= 0
	
oRetorno := ::ExcTabAlq( @oParams )

// Caso o comando tenha sido executado com sucesso	
If oRetorno:cAcao == OK
	For nDX := 1 To Len(oParams:Elements(3):cParametro)
		cSimbolo := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,2))	// Copia o simbolo da aliquota
		nDX += 2
		cValor := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,4))	// Copia o valor numerico da aliquota
		nDX += 4
		cVendido := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,17))	// Copia o valor vendido na aliquota
		nDX += 16
		//Caso o simbolo seja preenchido
		If !Empty(AllTrim(cSimbolo)) .And. (cSimbolo == "IS")
			nSoma += Val(cVendido) / 100
		EndIf
	Next nDX    	
EndIf

oRetorno:oRetorno := nSoma
	
Return oRetorno

//----------------------------------------------------------
/*{Protheus.doc} LeTotISSNT
Le o total de valor de iss n�o tributado
@author  	Julio.Nery
@version 	P12
@since   	22/10/2019
*/
//--------------------------------------------------------
Method LeTotISSNT() Class LJAEpson
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
Local nDX		:= 1			//Contador utilizado no comando "For"
Local cSimbolo	:= Space(2)		//String temporaria para armazenamento do simbolo da aliquota
Local cValor	:= Space(4)		//String temporaria para armazenamento do valor numerico da aliquota
Local cVendido	:= Space(17)	//String temporaria para armazenamento do valor vendido na aliquota
Local nSoma		:= 0
	
oRetorno := ::ExcTabAlq( @oParams )

// Caso o comando tenha sido executado com sucesso	
If oRetorno:cAcao == OK
	For nDX := 1 To Len(oParams:Elements(3):cParametro)
		cSimbolo := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,2))	// Copia o simbolo da aliquota
		nDX += 2
		cValor := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,4))	// Copia o valor numerico da aliquota
		nDX += 4
		cVendido := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,17))	// Copia o valor vendido na aliquota
		nDX += 16
		//Caso o simbolo seja preenchido
		If !Empty(AllTrim(cSimbolo)) .And. (cSimbolo == "NS")
			nSoma += Val(cVendido) / 100
		EndIf
	Next nDX
EndIf

oRetorno:oRetorno := nSoma
	
Return oRetorno

//----------------------------------------------------------
/*{Protheus.doc} LeTotIssSu
Le o total de ISS Substituido 
@author  	Julio.Nery
@version 	P12
@since   	22/10/2019
*/
//--------------------------------------------------------
Method LeTotIssSu() Class LJAEpson
Local oParams 	:= Nil			//Objeto para passagem dos parametros
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
Local nDX		:= 1			//Contador utilizado no comando "For"
Local cSimbolo	:= Space(2)		//String temporaria para armazenamento do simbolo da aliquota
Local cValor	:= Space(4)		//String temporaria para armazenamento do valor numerico da aliquota
Local cVendido	:= Space(17)	//String temporaria para armazenamento do valor vendido na aliquota
Local nSoma		:= 0
	
oRetorno := ::ExcTabAlq( @oParams )

// Caso o comando tenha sido executado com sucesso	
If oRetorno:cAcao == OK
	For nDX := 1 To Len(oParams:Elements(3):cParametro)
		cSimbolo := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,2))	// Copia o simbolo da aliquota
		nDX += 2
		cValor := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,4))	// Copia o valor numerico da aliquota
		nDX += 4
		cVendido := AllTrim(SubStr(oParams:Elements(3):cParametro,nDX,17))	// Copia o valor vendido na aliquota
		nDX += 16
		//Caso o simbolo seja preenchido
		If !Empty(AllTrim(cSimbolo)) .And. (cSimbolo == "FS")
			nSoma += Val(cVendido) / 100
		EndIf
	Next nDX
EndIf

oRetorno:oRetorno := nSoma
	
Return oRetorno

//----------------------------------------------------------
/*{Protheus.doc} ExcTabAlq
Execu��o Generica de comandos
Executa o comando EPSON_Obter_Tabela_Aliquotas
@author  	Julio.Nery
@version 	P12
@since   	22/10/2019
*/
//--------------------------------------------------------
Method ExcTabAlq( oParams ) Class LJAEpson
Local oRetorno	:= Nil
Local cDados  	:= Space(533)	//String que receber a tabela de aliquotas cadastradas no ECF
Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial

//Prepara os parametros de envio 
oParams := ::PrepParam({EPSON, "EPSON_Obter_Tabela_Aliquotas", cDados})
//Envia o comando    	
cRetorno := ::EnviarCom(oParams)
//Obtem o Estado da impressora
cRetorno := ::ObterEst()
//Trata o retorno    
oRetorno := ::TratarRet(cRetorno)

Return oRetorno