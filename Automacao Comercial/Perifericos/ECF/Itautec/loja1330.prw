#INCLUDE "MSOBJECT.CH" 
#INCLUDE "DEFECF.CH"
#INCLUDE "AUTODEF.CH"     
#INCLUDE "LOJA1330.CH"

Static cTagAllFormIni	:= '<AT>' //Ativa todos os atributos de formata��o 
Static cTagNegrIni		:= '<AN>' //Ativa negrito
Static cTagSubliIni		:= '<AS>' //Ativa sublinhado
Static cTagLrgDuplaIni	:= '<AL>' //Ativa largura dupla
Static cTagAltDuplaIni	:= '<AA>' //Ativa altura Dupla
Static cTagCorInvrtIni	:= '<AI>' //Ativa cor invertida
Static cTagAllFormFim	:= '<DT>' //Desativa todos
Static cTagNegrFim		:= '<DN>' //Desativa negrito
Static cTagSubliFim		:= '<DS>' //Desativa sublinhado
Static cTagLrgDuplaFim	:= '<DL>' //Desativa largura dupla
Static cTagAltDuplaFim	:= '<DA>' //Desativa altura dupla
Static cTagCorInvrtFim	:= '<DI>' //Desativa cor invertida

#DEFINE NAO_USADO 		""      					//Parametro nao usado
#DEFINE ENTER	   		Chr(13)+Chr(10)		 	    //Caracter de quebra de linha
#DEFINE TRUNCADO   		"1"							//Definicao pela impressora de truncar valores
#DEFINE _BYTESLINHANF  	252							//Defini quantos bytes he impresso por linha no relatorio nao fiscal

Function LOJA1330 ; Return 	 // "dummy" function - Internal Use 

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJAItautec       �Autor  �Vendas Clientes     � Data �  24/02/10   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe abstrata, possui as funcoes comuns para todos os ECF'S do   ���
���			 �modelo Itautec												     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJAItautec From LJAEcf
	
	Data oFormasVen																//Formas da venda, objeto do tipo LJCFormasEcf
	Data cTruncado  															//Indica se trunca ou arredonda valores "0" - Valor Arredondado / "1" - Valor Truncado
	Data cMsgCNF                                                            	//Mensagem promocial usada na Sangria e Suprimento
	Data dDataFimE                                                              //Data Final da Gera��o do Registro
	Data cIdModECF                                                              //Modelo do ECF
	Data dDataSW                                                                //Data de Grava��o do Software B�sico
	Data cHoraSW                                                                //Hora de grava��o do Software B�sico
		
	Method New(oTotvsApi)														//Metodo construtor

	//Metodos da interface
	Method AbrirPorta(cPorta)													//Abre a porta serial para comunicacao com o ECF
	Method FechaPorta(cPorta)													//Fechar a porta serial
	
	//Operacoes fiscais
	Method AbrirCF(cCnpj, cCliente, cEndereco)							   		//Abri o cupom fiscal
	Method CancelaCF()															//Cancela o cupom
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
	Method ImpTxtNF(oRelatorio, lLinha)											//Imprimi texto em cupom nao fiscal 
	Method Sangria(oFormas, cTotaliz)								   			//Efetua sangria de caixa
	Method Suprimento(oFormas, cTotaliz)   										//Efetua suprimentro de caixa (entrada de troco)
	Method EstNFiscVinc(cCPFCNPJ,cCliente,cEndereco,cMensagem,cCOOCCD)			//Efetua o estorno do comprovante de credito e debito
	
	//Relatorios fiscais
	Method LeituraX()															//Emite uma leituraX
	Method ReducaoZ()															//Emite uma leituraX
	Method AbrirDia()															//Emite leituraX de inicio de dia
   	Method MFData(dDtInicio, dDtFim, cTipo, cTipoArq)							//Leitura da memoria fiscal por data
   	Method MFReducao(cRedInicio, cRedFim, cTipoArq)								//Leitura da memoria fiscal por reducao	
    Method MFDData(dDtInicio, dDtFim)											//Leitura da memoria fita detalhe por data
   	Method MFDCoo(cCooInicio, cCooFim)											//Leitura da memoria fita detalhe por Coo
    Method TipoEData(cDatInicio, cDatFim, cPathArq, cBinario)										//Gerar arq. Tipo E Ato Cotepe 17/04 PAF-ECF por Data
	Method TipoECrz(cCrzInicio, cCrzFim, cBinario)										//Gerar arq. Tipo E Ato Cotepe 17/04 PAF-ECF por Crz
    Method DownMF()																			//Gerar Arquivo da mem�ria fiscal
    Method RedZDado()	
        
	//Autenticacao e cheque
	Method Autenticar(cTexto)													//Autentica documento / cheque
	Method ImpCheque(cBanco	, nValor, cData    , cFavorecid , ;
					 cCidade, cTexto, cExtenso , cMoedaS    , ;
					 cMoedaP)													//Imprime cheque
	Method LeCMC7() 															//Efetura a leitura do CMC7
					 
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
    Method GetPathMF()                                                          //Retorna o caminho e nome do arquivo de Memoria Fiscal
   	Method GetPathTipoE(cBinario)														//Retorna o caminho e nome do arquivo de registro Tipo E Ato Cotepe 17/04 PAF-ECF
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
    Method BuscInfEcf()															//Busca as informacoes para o funcionamento do sistema (aliquotas, formas de pagto, numero serie, etc...) 
    Method GetPathMFBin()                                                          //Retorna o caminho e nome do arquivo de Memoria Fiscal
	    
	//Metodos internos                                                                              
	Method CarregMsg()										//Carrega as mensagens de retorno do ecf	
	Method LeDadoUsu()										//Carrega o C.N.P.J, I.M e I.E
	Method LeDadImp()										//Carrega o Modelo, Fabricante, Firmware & numero de serie do ECF
	Method LeCliche()                                 		//Carrega a Razao Social, Nome Fantasia, Endereco 1 & Endereco 2
	Method LeOperador()										//Carrega o nome do Operador
	Method LeECFLoja()										//Carrega o numero da Loja e do ECF
	Method LeAliq()											//Carrega as aliquotas cadastradas no ECF
	Method LeTotNF()										//Carrega os Totalizadores Nao Fiscais cadastrados no ECF
	Method LeRelGer()										//Carrega os Relatorios Gerenciais cadastrados no ECF
	Method LeFinaliz()										//Carrega as Formas de Pagamento cadastradas no ECF
	Method LeDataJor()										//Le a data e hora de abertura da jornada
	Method LeGT()											//Le o Grand Total da impressora
	Method LeCOO()											//Le o coo do ultimo documento impresso pela impressora
	Method LeTotCanc()										//Le o total cancelado durante a jornada
	Method LeTotCanISS()										//Le total de cancelado para ISS
	Method LeTotDesc()										//Le o total de desconto durante a jornada
	Method LeTotDesISS()										//Le total de desconto para ISS
	Method LeTotAcre()										//Le o total de acrescimo durante a jornada
   	Method LeTotIsent()										//Le o total isento durante a jornada
   	Method LeTotNTrib()										//Le o total nao tributado durante a jornada
   	Method LeTotSTrib()										//Le o total substituicao tributaria
   	Method LeTotIss()										//Le o total de ISS durante a jornada
	Method LeVndLiq()										//Le o total de venda liquida durante a jornada
	Method LeVndBrut()										//Le o total de venda bruta durante a jornada		
	Method LeFaseCP()										//Le a fase do cupom fiscal em andamento
	Method LeCupIni()										//Le o cupom inicial do dia
	Method BuscaAliq(cTribut, nAliquota)					//Metodo responsavel buscar o indice da aliquota
    Method InicVar()										//Inicializando variaveis
    Method GuardarPgt(cForma, nValor)						//Guarda as formas da venda
    Method RegCliente(cCnpj, cCliente, cEndereco)			//Registra os dados do cliente na abertura do cupom						
    Method TransVlr(nValor)									//Converte os valores para enviar a impressora
    Method CorrigRet(cRetorno)								//Metodo que tira caracteres NULL e espacos dos retoronos 	  
    Method TratParam(cRetorno)								//Metodo que tira caracteres dos parametros
	Method TrataTags( cMensagem )							//Trata as tags enviadas para a mensagem promocional
	Method GetCodDllECF()									//Busca na DLL do Fabricante o Codigo da Impressora Referente a TABELA NACIONAL DE C�DIGOS DE IDENTIFICA��O DE ECF
	Method GetNomeECF()										//Busca na DLL do Fabricante o nome composto pela: Marca + Modelo + " - V. " + Vers�o do Firmware
	Method IdCliente(cCNPJ, cNome, cEnd)                                                                                                                  
EndClass

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �New   	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJAItautec.     			    	     ���
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
Method New(oTotvsApi) Class LJAItautec
   
	//Executa o metodo construtor da classe pai
	_Super:New(oTotvsApi)
    
    //Inicializando variaveis
    Self:oFormasVen := Nil  
    Self:cPathMFD   := "C:\LeituraMFD_ESP.txt"
    Self:cPathMF    := "C:\LeituraMF.txt"
    Self:cTruncado  := "0" 
    Self:cMsgCNF	:= ""	
    
    //Carrega as mensagens
	Self:CarregMsg()
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AbrirPorta�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura da porta serial.           ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Numero da porta COM (nao utilizado)						  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AbrirPorta(cPorta) Class LJAItautec
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	
	//Pega o numero da porta
	cPorta := AllTrim( SubStr(cPorta, 4, 1) )
			
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4Open", cPorta, NAO_USADO})
    //Envia o comando
    cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno
    oRetorno := Self:TratarRet(cRetorno)
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FechaPorta�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo fechamento da porta serial.         ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Numero da porta COM (nao utilizado)						  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method FechaPorta(cPorta) Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
			
	//Prepara os parametros de envio
	oParams  := Self:PrepParam({ITAUTEC, "E4Close"})
    //Envia o comando
    cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno
    oRetorno := Self:TratarRet(cRetorno)
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
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
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AbrirCF(cCnpj, cCliente, cEndereco) Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	
	//Inicializando variaveis
    Self:InicVar()
	                    
	//Registra os dados do cliente na abertura do cupom
	oRetorno := Self:RegCliente(cCliente, cCnpj, cEndereco)
   
	If( oRetorno:cAcao == OK )
		//Prepara os parametros de envio
		oParams  := Self:PrepParam({ITAUTEC, "E4IniCup", "2"})
	    //Envia o comando
	    cRetorno := Self:EnviarCom(oParams)
	    //Trata o retorno
	    oRetorno := Self:TratarRet(cRetorno)
	Endif    
		
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
Method CancelaCF() Class LJAItautec   

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao

	//Prepara os parametros de envio 
	oParams  := Self:PrepParam({ITAUTEC, "E4CanCup"})	
    //Envia o comando
    cRetorno := AllTrim(Self:EnviarCom(oParams))
    //Trata o retorno
    oRetorno := Self:TratarRet(cRetorno)  

	//���������������������������������������������������������������������Ŀ
	//�Caso tenha dado erro no fechamento do cupom, sera necessario enviar o�
	//�fechamento para apos tentar cancela-lo.                              �
	//�����������������������������������������������������������������������
	If oRetorno:cAcao <> OK 
 	  	//Prepara os parametros de envio 
		oParams  := Self:PrepParam({ITAUTEC, "E4FimCP", NAO_USADO, "CUPOM SERA CANCELADO."})	
    	//Envia o comando
    	cRetorno := AllTrim(Self:EnviarCom(oParams))
    	//Trata o retorno
	    oRetorno := Self:TratarRet(cRetorno)  
	    
	   	//Prepara os parametros de envio 
		oParams  := Self:PrepParam({ITAUTEC, "E4CanCup"})	
	    //Envia o comando
	    cRetorno := AllTrim(Self:EnviarCom(oParams))
	    //Trata o retorno
	    oRetorno := Self:TratarRet(cRetorno)  
    EndIf
    
   	//Inicializando variaveis
    Self:InicVar()
	
Return oRetorno
  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
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
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method VenderItem(	cCodigo	, cDescricao, cTribut	, nAliquota	, ;
					nQtde	, nVlUnit	, nDesconto	, cComplemen, ;
	    			cUniMed ) Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	Local cIndice   := ""          	//Indice da aliquota na impressora
	Local cQtde     := ""			//Quantidade do produto vendido
	Local cVlUnit	:= ""			//Valor unitario
	
	//Busca Indice Aliquota
	cIndice := Self:BuscaAliq(cTribut, nAliquota)	
	
	//Prepara parametros
	cCodigo		:= SubStr(AllTrim(cCodigo), 1, 14) 
	cDescricao	:= SubStr(AllTrim(cDescricao), 1, 170) 
	cQtde       := cValToChar(nQtde)
   	cVlUnit     := Self:TransVlr(nVlUnit)
	cUniMed		:= SubStr(Alltrim(cUniMed), 1, 2)
	
	//Prepara os parametros de envio 
	oParams  := Self:PrepParam({ITAUTEC, "E4IteCFEsp2"	, cIndice, cCodigo			, cDescricao,;
										  cQtde			, cVlUnit, Self:cTruncado  })	
    //Envia o comando
    cRetorno := AllTrim(Self:EnviarCom(oParams))
    //Trata o retorno
    oRetorno := Self:TratarRet(cRetorno)
	//Efetua o desconto sobre o item.
	If nDesconto > 0 .AND. oRetorno:cAcao == OK 
		oRetorno := Self:DescItem(nDesconto)
	EndIf
	
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
	    		cUniMed ) Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	
	cItem := AllTrim(cItem)

	//Prepara os parametros de envio 
	oParams  := Self:PrepParam({ITAUTEC, "E4CanIt", NAO_USADO, cItem, NAO_USADO, NAO_USADO})	
    //Envia o comando
    cRetorno := AllTrim(Self:EnviarCom(oParams))
    //Trata o retorno
    oRetorno := Self:TratarRet(cRetorno)
	
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
Method DescItem(nValor) Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	Local cValor    := ""          	//Valor de desconto
	Local cNumItem  := ""			//Numero do ultimo item
	
	//Busca numero do item
	oRetorno := Self:GetNumItem()
                           
    // Caso o comando tenha sido executado com sucesso, retorna o codigo do registrador
    If(oRetorno:cAcao == OK)   
    	//Prepara parametros                        
    	cValor 	 := Self:TransVlr(nValor)
    	cNumItem := AllTrim(oRetorno:oRetorno)
     	
		//Prepara os parametros de envio 
		oParams  := Self:PrepParam({ITAUTEC, "E4DesIt", "0", NAO_USADO, cNumItem, cValor, NAO_USADO})	
	    //Envia o comando
	    cRetorno := AllTrim(Self:EnviarCom(oParams))
	    //Trata o retorno
	    oRetorno := Self:TratarRet(cRetorno)
    EndIf
	
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
Method DescTotal(nValor) Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	Local cValor    := ""          	//Valor de desconto
	  
   	cValor 	 := Self:TransVlr(nValor)

	//Prepara os parametros de envio 
	oParams  := Self:PrepParam({ITAUTEC, "E4DesCup", "0", cValor, NAO_USADO})	
    //Envia o comando
    cRetorno := AllTrim(Self:EnviarCom(oParams))
    //Trata o retorno
    oRetorno := Self:TratarRet(cRetorno)
	
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
Method AcresItem(nValor) Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	Local cValor    := ""          	//Valor de desconto
	Local cNumItem  := ""			//Numero do ultimo item
	
	//Busca numero do item
	oRetorno := Self:GetNumItem()

    // Caso o comando tenha sido executado com sucesso, retorna o codigo do registrador
    If(oRetorno:cAcao == OK)   
		//Prepara parametros
    	cValor 	 := Self:TransVlr(nValor)
    	cNumItem := AllTrim(oRetorno:oRetorno)

		//Prepara os parametros de envio 
		oParams  := Self:PrepParam({ITAUTEC, "E4AcrIt", "0", NAO_USADO, cNumItem, cValor, NAO_USADO})	
	    //Envia o comando
	    cRetorno := AllTrim(Self:EnviarCom(oParams))
	    //Trata o retorno
	    oRetorno := Self:TratarRet(cRetorno)
	EndIf	    
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
Method AcresTotal(nValor) Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	Local cValor    := ""          	//Valor de desconto
	
  	cValor 	 := Self:TransVlr(nValor)

	//Prepara os parametros de envio 
	oParams  := Self:PrepParam({ITAUTEC, "E4AcrCup", "0", cValor, NAO_USADO})	
    //Envia o comando
    cRetorno := AllTrim(Self:EnviarCom(oParams))
    //Trata o retorno
    oRetorno := Self:TratarRet(cRetorno)
	
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
Method EfetuaPgto(cForma, nValor) Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	Local cIndice   := ""			//Indice da forma de pagamento na impressora
	Local cValor    := ""			//Valor do pagamento

	//Verifica se a forma esta cadastrada no ecf
	oRetorno := Self:GetForma(cForma)
	
	If oRetorno:cAcao == OK    
	    //Carrega o indice da forma de pagamento
	    cIndice := oRetorno:oRetorno:cIndice
	    //Prepara valor
    	cValor 	 := Self:TransVlr(nValor)
		//Prepara os parametros de envio 
		oParams  := Self:PrepParam({ITAUTEC, "E4RegPag", cIndice, cValor})	
	    //Envia o comando
	    cRetorno := AllTrim(Self:EnviarCom(oParams))
	    //Trata o retorno
	    oRetorno := Self:TratarRet(cRetorno)
	    
   		If oRetorno:cAcao == OK
			//Guarda forma de pagto
			Self:GuardarPgt(cForma, nValor)
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
Method FecharCF(oMsgPromo) Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	Local cMsg      := ""          	//Mensagem Promocional
	Local nLinhas   := 1            //Quantidade de linhas na mensagem promocional
	Local nCont     := 1            //Contador do For...
	
	//Carrega quantidade de linhas da mensagem promocional
	nLinhas := oMsgPromo:Count()

	//Copia as linhas recebidas
	For nCont := 1 To nLinhas
		cMsg += Self:TrataTags( Self:TratParam(oMsgPromo:Elements(nCont)) )
	Next nCont

	//Trunca Mensagem em 252 caracteres, se necessario		
	cMsg := SubStr( cMsg, 1 , 252)

	//Prepara os parametros de envio 
	oParams  := Self:PrepParam({ITAUTEC, "E4FimCP", NAO_USADO, cMsg})	
    //Envia o comando
    cRetorno := AllTrim(Self:EnviarCom(oParams))
    //Trata o retorno
    oRetorno := Self:TratarRet(cRetorno)
	
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
Method TotalizaCF()Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//NOTA: As impressoras ITAUTEC nao precisam receber o comando de totalizacao de cupom.
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")

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
Method AbrirCNFV(cForma, nValor) Class LJAItautec                                      '

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao		
	Local cIndice	:= ""			//String temporaria que guarda o indice da forma de pagamento

	//Verifica se a forma esta cadastrada no ecf
	oRetorno := Self:GetForma(cForma)
	
	If oRetorno:cAcao == OK
		//Pega o indice da forma
		cIndice := oRetorno:oRetorno:cIndice
		//Prepara os parametros de envio 
		oParams  := Self:PrepParam({ITAUTEC, "E4IniCP", "17", cIndice})	
	    //Envia o comando
	    cRetorno := AllTrim(Self:EnviarCom(oParams))
	    //Trata o retorno
	    oRetorno := Self:TratarRet(cRetorno)
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
Method FecharCNFV() Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	Local cMsg      := ""		  	//Mensagem Promocional

	//Prepara os parametros de envio 
	oParams  := Self:PrepParam({ITAUTEC, "E4FimCP", NAO_USADO, cMsg})	
    //Envia o comando
    cRetorno := AllTrim(Self:EnviarCom(oParams))
    //Trata o retorno
    oRetorno := Self:TratarRet(cRetorno)
	
	//Inicializando variaveis
    Self:InicVar()
	
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
Method CancCNFV(cCupom, cForma, nValor) Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
    
	cCupom := SubStr(AllTrim(cCupom), 1, 6)

	//Prepara os parametros de envio 
	oParams  := Self:PrepParam({ITAUTEC, "E4CancelaCCD", cCupom})	
    //Envia o comando
    cRetorno := AllTrim(Self:EnviarCom(oParams))
    //Trata o retorno
    oRetorno := Self:TratarRet(cRetorno)

	//Inicializando variaveis
    Self:InicVar()
	
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
Method AbrirCNF(cCnpj, cCliente, cEndereco, cTotaliz, nValor) Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	Local cIndice   := ""          	//Recebe o indice do totalizador 
	Local cValor    := ""			//Valor da operacao
                    
	//Verifica se o totalizador esta cadastrado no ecf
	oRetorno := Self:GetTotaliz(cTotaliz)

	If( oRetorno:cAcao == OK )
		//Pega indice do totalizador
		cIndice := oRetorno:oRetorno:cIndice	

		//Registra os dados do cliente na abertura do cupom
		oRetorno := Self:RegCliente(cCliente, cCnpj, cEndereco)
		 
		//ABRE CUPOM NAO FISCAL		
		If( oRetorno:cAcao == OK )	  
			//Prepara os parametros de envio 
			oParams  := Self:PrepParam({ITAUTEC, "E4IniCup", "19"})	
		    //Envia o comando
		    cRetorno := AllTrim(Self:EnviarCom(oParams))
		    //Trata o retorno
		    oRetorno := Self:TratarRet(cRetorno)

			//REGISTRA OPERACAO NAO FISCAL
    		If( oRetorno:cAcao == OK )	  
				//Pega valor da transacao
    	    	cValor 	 := Self:TransVlr(nValor)
    		
				//Prepara os parametros de envio 
				oParams  := Self:PrepParam({ITAUTEC, "E4OpeCNF", cIndice, NAO_USADO, NAO_USADO, cValor})	
			    //Envia o comando
			    cRetorno := AllTrim(Self:EnviarCom(oParams))
			    //Trata o retorno
			    oRetorno := Self:TratarRet(cRetorno)
    		EndIf
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
Method FecharCNF() Class LJAItautec

	Local oParams 	:= Nil				//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      		//Objeto que sera retornado pela funcao
	Local cMsg      := Self:cMsgCNF		//Mensagem promocional
	
	//Prepara mensagem
	cMsg := SubStr( Self:TratParam(cMsg), 1, 252)
	
	//Prepara os parametros de envio 
	oParams  := Self:PrepParam({ITAUTEC, "E4FimCP", NAO_USADO, cMsg})	
    //Envia o comando
    cRetorno := AllTrim(Self:EnviarCom(oParams))
    //Trata o retorno
    oRetorno := Self:TratarRet(cRetorno)

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
Method PgtoCNF(cForma, nValor) Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	Local cIndice   := ""			//Indice da forma de pagamento na impressora
	Local cValor    := ""			//Valor do pagamento

	//Verifica se a forma esta cadastrada no ecf
	oRetorno := Self:GetForma(cForma)
	
	If (oRetorno:cAcao == OK )
	    //Carrega o indice da forma de pagamento
	    cIndice := oRetorno:oRetorno:cIndice
	    //Prepara valor
       	cValor 	 := Self:TransVlr(nValor)
		//Prepara os parametros de envio 
		oParams  := Self:PrepParam({ITAUTEC, "E4RegPag", cIndice, cValor})	
	    //Envia o comando
	    cRetorno := AllTrim(Self:EnviarCom(oParams))
	    //Trata o retorno
	    oRetorno := Self:TratarRet(cRetorno)
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
Method CancCNF() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	                            
    //Cancela cupom
	oRetorno := Self:CancelaCF()
	
	//Inicializando variaveis
    Self:InicVar()
	
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
Method AbrirRG(cRelatorio) Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao

	//Prepara os parametros de envio 	
	oParams  := Self:PrepParam({ITAUTEC, "E4IniCup", "20"})
    //Envia o comando
    cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno
    oRetorno := Self:TratarRet(cRetorno)
    
   	//Inicializando variaveis
    Self:InicVar()

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
Method FecharRG() Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	
	//Prepara os parametros de envio 
	oParams  := Self:PrepParam({ITAUTEC, "E4FimCup"})	
    //Envia o comando
    cRetorno := AllTrim(Self:EnviarCom(oParams))
    //Trata o retorno
    oRetorno := Self:TratarRet(cRetorno)
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
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
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ImpTxtNF(oRelatorio, lLinha) Class LJAItautec

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
                   
		oParams  := Self:PrepParam({ITAUTEC, "E4Print", Self:TratParam(oRelatorio:Elements(nCont)) })	
		                        
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
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Sangria(oFormas, cTotaliz) Class LJAItautec

	Local oRetorno 	:= Nil				//Objeto que sera retornado pela funcao   
	Local cCnpj		:= ""				//Cnpj ou Cpf do cliente
	Local cCliente  := ""				//Nome do cliente
	Local cEndereco := ""				//Endereco do cliente
	Local nCount    := 1				//Contador do For...
	Local nValor    := 0				//Valor total da sangria
	Local nFormas   := oFormas:Count() 	//Quantidade de formas de pagamento
	
	Self:cMsgCNF	:= STR0001 //"TRANSACAO DE SANGRIA"    
	
	//Pega o valor da sangria
	For nCount:=1 To nFormas
		nValor += oFormas:Elements(nCount):nValor
	Next nCont
	
	//Abre nao fiscal e registra a transacao
	oRetorno := Self:AbrirCNF(cCnpj, cCliente, cEndereco, cTotaliz, nValor)
                            
    If(oRetorno:cAcao == OK) 
       	For nCount:=1 To nFormas
			//Efetua o pagamento do cupom nao fiscal
			oRetorno := Self:PgtoCNF(oFormas:Elements(nCount):cForma, oFormas:Elements(nCount):nValor)    

		    If(oRetorno:cAcao <> OK) 	
				Exit    
		    EndIf
	    Next nCont
    EndIf
    
    If(oRetorno:cAcao == OK)    			
		//Finaliza cupom nao fiscal
		oRetorno := Self:FecharCNF()
    EndIf
    
	//Inicializando variaveis
    Self:InicVar()

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
Method Suprimento(oFormas, cTotaliz) Class LJAItautec

	Local oRetorno 	:= Nil				//Objeto que sera retornado pela funcao   
	Local cCnpj		:= ""				//Cnpj ou Cpf do cliente
	Local cCliente  := ""				//Nome do cliente
	Local cEndereco := ""				//Endereco do cliente
	Local nCount    := 1				//Contador do For...
	Local nValor    := 0				//Valor total da suprimento
	Local nFormas   := oFormas:Count() 	//Quantidade de formas de pagamento
	
	Self:cMsgCNF	:= STR0002 //"TRANSACAO DE SUPRIMENTO"    
	
	//Pega o valor do suprimento
	For nCount:=1 To nFormas
		nValor += oFormas:Elements(nCount):nValor
	Next nCont
	
	//Abre nao fiscal e registra a transacao
	oRetorno := Self:AbrirCNF(cCnpj, cCliente, cEndereco, cTotaliz, nValor)
                            
    If(oRetorno:cAcao == OK) 
       	For nCount:=1 To nFormas
			//Efetua o pagamento do cupom nao fiscal
			oRetorno := Self:PgtoCNF(oFormas:Elements(nCount):cForma, oFormas:Elements(nCount):nValor)    

		    If(oRetorno:cAcao <> OK) 	
				Exit    
		    EndIf
	    Next nCont
    EndIf
    
    If(oRetorno:cAcao == OK)    			
		//Finaliza cupom nao fiscal
		oRetorno := Self:FecharCNF()
    EndIf
    
	//Inicializando variaveis
    Self:InicVar()
	
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
Method EstNFiscVinc(cCPFCNPJ,cCliente,cEndereco,cMensagem,cCOOCCD) Class LJAItautec
Local oParams 	:= Nil		//Objeto para passagem dos parametros
Local cRetorno 	:= ""		//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil		//Objeto que sera retornado pela funcao
		           
//Prepara os parametros de envio
/*oParams := ::PrepParam({ITAUTEC, "", cCPFCNPJ,cCliente,cEndereco})

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
EndIf */

//Insere retorno padr�o OK, pois n�o consegui achar a documenta��o
oRetorno := ::TratarRet("1")
oRetorno:cAcao		:= OK
oRetorno:lRetorno	:= .T.
        
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
Method LeituraX() Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
   			
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4IniCP", "4", "0"})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    
   	//Inicializando variaveis
    Self:InicVar()
    
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
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ReducaoZ() Class LJAItautec

	Local oParams 	:= Nil						//Objeto para passagem dos parametros
	Local cRetorno 	:= ""		   				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil		   				//Objeto que sera retornado pela funcao
	Local oRedZ		:= LJCDadosReducaoZ():New()//Objeto contendo os dados da reducao Z  
	Local nAliquota	:= 0		   				//Temporario para armazenamento do valor numerico da aliquota
	Local cVendido	:= Space(18)				//String temporaria para armazenamento do valor vendido na aliquota	
	Local nVendido	:= 0						//Temporario para armazenamento do valor vendido na aliquota	
	Local nImposto	:= 0						//Valor do imposto devido.
	Local oAliquota := Nil						//Temporaria que recebera o objeto da classe LJCAliquota
	Local nCont     := 1						//Contador utilizado no For...
	Local nAliquotas:= 0						//Temporaria que vai conter a quantidade de aliquotas cadastradas na impressora
	Local cIndice   := ""						//Temporario indice da aliquota na impressora
	Local cCRZ      := Space(18)				//Temporario Contador de Reducao Z
	
	//Inicia o preenchimento do objeto LJCDadosReducaoZ
	oRedZ:cNumEcf	:= Self:cNumEcf
   	oRedZ:cNrSerie	:= Self:cNrSerie
   	    
	oRetorno := Self:LeDataJor()
	
	If( oRetorno:cAcao == OK )
		oRedZ:dDataMov := CTOD(oRetorno:oRetorno)
		oRetorno := Self:LeGT()
	EndIf
	
	If( oRetorno:cAcao == OK )
		oRedZ:nGranTotal := Val(oRetorno:oRetorno)
		oRetorno := Self:LeCOO()
	EndIf
	
	If( oRetorno:cAcao == OK )
		oRedZ:cNumCupFim := oRetorno:oRetorno
		oRetorno := Self:LeTotCanc()
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
		oRetorno := Self:LeTotNTrib()
	EndIf

   	If( oRetorno:cAcao == OK )
		oRedZ:nTotNTrib := oRetorno:oRetorno
		oRetorno := Self:LeTotIss()
	EndIf
	
   	If( oRetorno:cAcao == OK )
		oRedZ:nTotIss := oRetorno:oRetorno
		oRetorno := Self:GetSubstit()
	EndIf		
	
	If( oRetorno:cAcao == OK )
		oRedZ:nTotSubst := oRetorno:oRetorno
		oRetorno := Self:GetDatHora()
	EndIf
    
	If( oRetorno:cAcao == OK )
		oRedZ:dDataRed := CTOD(Substr(oRetorno:oRetorno, 1, 10))
		oRetorno := Self:GetInterve()
	EndIf
	
	If( oRetorno:cAcao == OK )
		oRedZ:cCro := oRetorno:oRetorno
	    oRetorno := Self:LeCupIni()
	EndIf
    
	If( oRetorno:cAcao == OK )
		oRedZ:cNumCupIni := oRetorno:oRetorno
	EndIf

	oRedZ:cCoo := StrZero(Val(oRedZ:cNumCupFim) + 1, 6)
	
	//Carrega quantidade de aliquotas
	nAliquotas := Self:oAliquotas:Count()
	
	For nCont:= 1 To nAliquotas                      
		//Carrega aliquota usada
		oAliquota := Self:oAliquotas:Elements(nCont)
		
		//Verifica se aliquota eh ICMS                                                                                 
		If !(oAliquota:lIss)
		    cIndice  := AllTrim(oAliquota:cIndice)  	// Copia o indice da aliquota na impressora
		    
			//Prepara os parametros de envio
			oParams	 := Self:PrepParam({ITAUTEC, "E4ValAtu", cIndice, cVendido})
		    //Envia o comando    	
			cRetorno := Self:EnviarCom(oParams)
		    //Trata o retorno    
		    oRetorno := Self:TratarRet(cRetorno)
		    // Caso o comando tenha sido executado com sucesso	
		    If(oRetorno:cAcao == OK)           
				nVendido := Val(oParams:Elements(4):cParametro) / 100 			// Copia o valor vendido nessa aliquota
				nAliquota:= oAliquota:nAliquota		 						    // Copia o valor da aliquota
				
				//Verifica se tunca ou arredonda
				If Self:cTruncado == TRUNCADO
					nImposto := NoRound(((nAliquota * nVendido) / 100), 2)		// Copia o valor do imrposto dessa aliquota
				Else	                                                                        
					nImposto := Round(((nAliquota * nVendido) / 100), 2)		// Copia o valor do imrposto dessa aliquota
				EndIf

				//Adiciona totalizadores da aliquota ao objeto da reducaoZ
				oRedZ:AdicImp( nAliquota, nVendido, nImposto)
		    EndIf				
	    EndIf
    Next nCont                  

    //Emite reducao Z  
    If(oRetorno:cAcao == OK)           
		//Prepara os parametros de envio
		oParams := Self:PrepParam({ITAUTEC, "E4IniCup", "5"})
	    //Envia o comando    	
		cRetorno := Self:EnviarCom(oParams)
	    //Trata o retorno    
	    oRetorno := Self:TratarRet(cRetorno)

		//Pega CRZ da Impressora	    
        If(oRetorno:cAcao == OK)
	   		//Prepara os parametros de envio
			oParams := Self:PrepParam({ITAUTEC, "E4ValAtu", "4", cCRZ})
		    //Envia o comando    	
			cRetorno := Self:EnviarCom(oParams)
		    //Trata o retorno    
		    oRetorno := Self:TratarRet(cRetorno)
		    
            If(oRetorno:cAcao == OK)
			    oRedZ:cNumRedZ  := SubStr(AllTrim(oParams:Elements(4):cParametro), 1, 6)		// Copia o numero da reducao z
				Self:oDadosRedZ := oRedZ
				 
				//Venda bruta diaria apenas possivel pegar o valor apos a emissao da reducao z
				If( oRetorno:cAcao == OK )
					oRetorno := Self:LeVndBrut()
					oRedZ:nVendaBrut := oRetorno:oRetorno
				EndIf  
				 
				//Venda liquida diaria				      
				If( oRetorno:cAcao == OK )
					oRedZ:nVendaLiq := oRedZ:nVendaBrut - oRedZ:nTotDesc - oRedZ:nTotCancel - oRedZ:nTotIss
				EndIf

				//Inicializando variaveis
			    Self:InicVar()
			EndIf
        EndIf           
    EndIf  
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
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
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AbrirDia()Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4CorteImp", "1"}) //Habilita corte de papel automatico
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)

	If oRetorno:cAcao == OK
		//Verifica as flags fiscais
		oRetorno := Self:GetFlagsFi()
	    
		//Inicializando variaveis
	    Self:InicVar()
    EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MFData    �Autor  �Vendas Clientes     � Data �  06/03/08   ���
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
Method MFData(dDtInicio, dDtFim, cTipo, cTipoArq)	Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	Local cDataIni  := ""           //Data Inicial
	Local cDataFim  := ""           //Data Final
	
	//Prepara as datas para enviar a aplicacao
	cDataIni := Padl(Day(dDtInicio), 2 , "0") 	+ Padl(Month(dDtInicio), 2 , "0") 	+ AllTrim(Str(Year(dDtInicio)))
	cDataFim := Padl(Day(dDtFim), 2 , "0") 	+ Padl(Month(dDtFim), 2 , "0") 		+ AllTrim(Str(Year(dDtFim)))

	If Upper(cTipo) $ "I"
		//Prepara os parametros de envio
		oParams := Self:PrepParam({ITAUTEC, "E4LMF", "0", "1", cDataIni, cDataFim})
    Else
		//Prepara os parametros de envio
		oParams := Self:PrepParam({ITAUTEC, "E4LMFSerial", "0", "1", cDataIni, cDataFim, Self:cPathMF})
    EndIf
    
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    
   	//Inicializando variaveis
    Self:InicVar()
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MFReducao �Autor  �Vendas Clientes     � Data �  06/03/08   ���
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
Method MFReducao(cRedInicio, cRedFim, cTipo, cTipoArq) Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	If Upper(cTipo) $ "I"
		//Prepara os parametros de envio
		oParams := Self:PrepParam({ITAUTEC, "E4LMF", "1", "1", cRedInicio, cRedFim})
    Else
		//Prepara os parametros de envio
		oParams := Self:PrepParam({ITAUTEC, "E4LMFSerial", "1", "1", cRedInicio, cRedFim, Self:cPathMF})
    EndIf
    
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
	             
	//Inicializando variaveis
    Self:InicVar()
	
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
Method Autenticar(cTexto) Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4Aut", cTexto})
    //Envia o comando    	
	cRetorno:= Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno:= Self:TratarRet(cRetorno)
	
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
//�����������������������������������������������������������������������������������������������������������Ŀ
//�O arquivo "Cheques.ini" cont�m as informacoes do layout do cheque de cada banco e deve estar no mesmo      |
//�diretorio onde est� sendo executado o aplicativo ou programa de testes. Opcionalmente o caminho do arquivo |
//|pode ser definido dentro do arquivo "ECFBFIAPI.ini" no campo "LayoutCheque".				                  |         														               �
//�������������������������������������������������������������������������������������������������������������
Method ImpCheque(cBanco	, nValor, cData    , cFavorecid , ;
				 cCidade, cTexto, cExtenso , cMoedaS    , ;
				 MoedaP) Class LJAItautec  

	Local oParams 	:= Nil					//Objeto para passagem dos parametros
	Local cRetorno 	:= ""					//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil					//Objeto que sera retornado pela funcao
   	Local cValor	:= ""					//Valor do cheque
   	Local cLinAdi1  := ""  					//Primeira linha de dados adicionais que sera impressa no cheque.
   	Local cLinAdi2  := ""           		//Segunda linha de dados adicionais que sera impressa no cheque.
   	Local dData     := StoD("  /  /  ")		//Data temporaria para convesao
   	Local cStatus	:= Space(14)			//Pega os legs Fiscais
   	Local lTerminou := .F.					//Indica que terminou a impressao do cheque
   	           
   	dData      := StoD(PadL(AllTrim(cData),8, "20"))
	cData 	   := Padl(Day(dData), 2 , "0") + Padl(Month(dData), 2 , "0") + AllTrim(Str(Year(dData)))              
	
	cFavorecid := SubStr(cFavorecid, 1, 45)
	cCidade    := SubStr(cCidade   , 1, 20)
   	cValor 	   := Self:TransVlr(nValor)
   	cLinAdi1   := SubStr(cTexto, 1, 50)
   	cLinAdi2   := SubStr(cTexto, 51, 50)
	
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4ImpChq", 	cBanco, 	cFavorecid,;
										 	cCidade,  	 cData,     	cValor,;
										   cLinAdi1,  cLinAdi2})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)

	//Verifica se acabou a impressao do cheque    
    While(oRetorno:cAcao == OK .AND. !lTerminou) 
	    //Para 3 segundo   
	   	Sleep(3000) 
		//Prepara os parametros de envio
		oParams := Self:PrepParam({ITAUTEC, "E4Status", cStatus})
	    //Envia o comando
	    cRetorno := Self:EnviarCom(oParams)
    	//Trata o retorno                                   
	    oRetorno := Self:TratarRet(cRetorno)

		cStatus   := Self:CorrigRet(oParams:Elements(3):cParametro)
		lTerminou := IIF(SubStr(cStatus, 3, 1) == "0", .T., .F.)
    End
   
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
Method LeCMC7() Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
   	Local cCMC7		:= Space(100)	//Valor do CMC7 lido
   	
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4LeCMC7", cCMC7})
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
���Parametros�EXPC1 (1 - cVincula) - Flag que indica se a forma de		  ���
���			 �		pagamento sera vinculada (S - Sim, N - Nao ).		  ���
���			 �EXPC2 (2 - cForma) - Nome da forma de pagamento.			  ���
���			 �EXPC3 (3 - cIndice) - Indice da forma de pagamento.		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfigPgto( cForma ) Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cVincula  := "1+"										//Indica se a forma de pagamento sera vinculada 
	Local cNumRegs  := "0"                                 		//Numero do registrador criado na impressora
	
	//Descricao da Forma de Pagamento no maximo 18 caracteres
	cForma := AllTrim(SubStr(cForma, 1, 18))
	
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4RPCria", "5", cForma, cVincula, cNumRegs})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso, retorna o codigo do registrador
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := oParams:Elements(6):cParametro
	EndIf
	
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
Method ConfTotNF(cIndice, cTotaliz) Class LJAItautec

	Local oParams 	:= Nil									//Objeto para passagem dos parametros
	Local cRetorno 	:= ""									//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil									//Objeto que sera retornado pela funcao
	Local cTipoRegs := "0"  								//Indica se o registrador sera '+' Registrador Positivo (Entrada) ou '-' Registrador Negativo (Saida)
	Local cNumRegs  := "0"                                 	//Numero do registrador criado na impressora
	
	//Descricao do Totalizador n�o fiscal que sera cadastrado
	cTotaliz := AllTrim(SubStr(cTotaliz, 1, 18))
	
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4RPCria", "1", cTotaliz, cTipoRegs, cNumRegs})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso, retorna o codigo do registrador
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := oParams:Elements(6):cParametro
	EndIf
	
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
Method ConfigAliq(nAliq, cTipoIss) Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cTipoAliq := IIF(Upper(cTipoIss) $ "S", "4", "2")  	//Indica se a aliquota cadastrada vai ser ISS = 4 ou ICMS = 2
	Local cAliquota := ""										//Aliquota que sera cadastrada
	Local cNumRegs  := "0"                                 		//Numero do registrador criado na impressora
	
	cAliquota := cValToChar(nAliq)
	
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4RPCria", cTipoAliq, cAliquota, "", cNumRegs})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso, retorna o codigo do registrador
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := oParams:Elements(6):cParametro
	EndIf
	
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
���Parametros�EXPC1 (1 - cTipo) - Tipo da configuracao E- Entra / S- Sai. ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfVerao(cTipo)Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cHorVerao := IIF(cTipo $ "S", "0", "1")				//Indica se Entra "1" no horaio de verao ou Sai "0"
	
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4Verao", cHorVerao})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
	
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
Method ConfRelGer(cIndice, cRelGer) Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cNumRegs  := "0"                                 		//Numero do registrador criado na impressora
	            
	//Descricao do Relatorio Gerencial no maximo 18 caracteres
	cRelGer := AllTrim(SubStr(cRelGer, 1 , 18))
	
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4RPCria", "6", cRelGer, "", cNumRegs})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso, retorna o codigo do registrador
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := oParams:Elements(6):cParametro
	EndIf
	
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
Method AbrirGavet() Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4OpenGv"})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
	
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
Method GetFabric() Class LJAItautec

	Local oRet 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRet := Self:TratarRet("0")
    
    oRet:oRetorno := Self:cFabric	//Copia o valor da propriedade da classe
    
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
Method GetModelo() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    oRetorno:oRetorno := Self:cModelo	//Copia o valor da propriedade da classe
    
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
Method GetVerFirm() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    oRetorno:oRetorno := Self:cFirmWare	//Copia o valor da propriedade da classe
    
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
Method GetCNPJ() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    oRetorno:oRetorno := Self:cCnpj	//Copia o valor da propriedade da classe
    
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
Method GetInsEst() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    oRetorno:oRetorno := Self:cIE	//Copia o valor da propriedade da classe
    
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
Method GetInsMun() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    oRetorno:oRetorno := Self:cIM	//Copia o valor da propriedade da classe
    
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
Method GetNumLj() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    oRetorno:oRetorno := Self:cLoja	//Copia o valor da propriedade da classe
    
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
Method GetOper() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    oRetorno:oRetorno := Self:cOperador	//Copia o valor da propriedade da classe
    
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
Method GetRzSoc() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    oRetorno:oRetorno := Self:cRazaoSoc	//Copia o valor da propriedade da classe
    
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
Method GetFantas() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    oRetorno:oRetorno := Self:cFantasia	//Copia o valor da propriedade da classe
    
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
Method GetEnd1() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    oRetorno:oRetorno := Self:cEndereco1	//Copia o valor da propriedade da classe
    
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
Method GetEnd2() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    oRetorno:oRetorno := Self:cEndereco2	//Copia o valor da propriedade da classe
    
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
Method GetDadRedZ() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    oRetorno:oRetorno := Self:oDadosRedZ	//Copia o valor da propriedade da classe
    
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
Method GetMFTXT() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
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
Method GetMFSer() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
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
Method GetHrVerao() Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cData	    := Space(9)                            		//Data da ECF
	Local cHora	    := Space(5)                            		//Hora da ECF
	Local cHorVerao	:= " "                                 		//Indica se esta no horario de verao "0" - Fora / "1" Dentro
	Local cDataMov	:= Space(9)                            		//Data do movimento
	Local cReducao	:= " "                                 		//Indica se foi feito uma Reducao Z na data de movimento "0" - Nao foi feita Redu��o Z / "1" - Foi feita Redu��o Z
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4RdData", cData, cHora, cHorVerao, cDataMov, cReducao})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso, retorna o codigo do registrador
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := oParams:Elements(5):cParametro
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
Method GetAliq() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    oRetorno:oRetorno := Self:oAliquotas	//Copia o valor da propriedade da classe
    
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
Method GetFormas() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    oRetorno:oRetorno := Self:oFormas	//Copia o valor da propriedade da classe
    
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
Method GetTotNF() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    oRetorno:oRetorno := Self:oTotsNF	//Copia o valor da propriedade da classe
    
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
Method GetRelGer() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    oRetorno:oRetorno := Self:oGerencial	//Copia o valor da propriedade da classe
    
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
Method GetNrSerie() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    oRetorno:oRetorno := Self:cNrSerie	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
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
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetNumCup ()Class LJAItautec
	
	Local oRetorno 	:= Self:LeCOO()

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
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
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetNumEcf() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    oRetorno:oRetorno := Self:cNumEcf	//Copia o valor da propriedade da classe

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
Method GetNumItem() Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cNumItens	:= Space(4)                            		//Numero de itens
	Local nNumItens := 0										//Numero de itens para auxiliar
	
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4InfCup", "505", cNumItens})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso, retorna o codigo do registrador
    If(oRetorno:cAcao == OK)  
    	nNumItens := Val(oParams:Elements(4):cParametro)
    	cNumItens := cValToChar(nNumItens)
		oRetorno:oRetorno := cNumItens
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
Method GetSubTot() Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cVlrSubT	:= Space(10)                           		//Valor do SubTotal
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4InfCup", "504", cVlrSubT})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso, retorna o codigo do registrador
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := oParams:Elements(4):cParametro
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
Method GetDatHora() Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cData	    := Space(9)                            		//Data da ECF
	Local cHora	    := Space(5)                            		//Hora da ECF
	Local cHorVerao	:= " "                                 		//Indica se esta no horario de verao "0" - Fora / "1" Dentro
	Local cDataMov	:= Space(9)                            		//Data do movimento
	Local cReducao	:= " "                                 		//Indica se foi feito uma Reducao Z na data de movimento "0" - Nao foi feita Redu��o Z / "1" - Foi feita Redu��o Z
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4RdData", cData, cHora, cHorVerao, cDataMov, cReducao})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso, retorna o codigo do registrador
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno :=	Substr(oParams:Elements(3):cParametro,1,2)  + "/" +;
								Substr(oParams:Elements(3):cParametro,3,2)  + "/" +;
							  	Substr(oParams:Elements(3):cParametro,5,4)  + " " +;
							  	Substr(oParams:Elements(4):cParametro,1,2)  + ":" +;
							  	Substr(oParams:Elements(4):cParametro,3,2)  + ":" +;
								"00"
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
Method GetDesItem() Class LJAItautec
	
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
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
Method GetImpFisc() Class LJAItautec
	
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
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
Method GetTrunAre() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    If  Self:cTruncado == TRUNCADO
    	oRetorno:oRetorno := "T"
    Else
    	oRetorno:oRetorno := "A"
    EndIf
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
Method GetChqExt() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
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
Method GetVdBruta() Class LJAItautec

	Local oRetorno 	:= Self:LeVndBrut()

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
Method GetGranTot()Class LJAItautec

	Local oRetorno 	:= Self:LeGT()

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
Method GetTotDesc() Class LJAItautec

	Local oRetorno 	:= Self:LeTotDesc()

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
Method GetDescIss() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	//FALTA IMPLEMENTAR
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
Method GetTotAcre() Class LJAItautec

	Local oRetorno 	:= Self:LeTotAcre()		//Objeto que sera retornado pela funcao
	
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
Method GetAcreIss() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	//FALTA IMPLEMENTAR	
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
Method GetTotCanc()Class LJAItautec

	Local oRetorno 	:= Self:LeTotCanc()

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
Method GetCancIss() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	//FALTA INPLEMENTAR	
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
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
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetIsentos() Class LJAItautec

	Local oRetorno 	:= Self:LeTotIsent()

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
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
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetNaoTrib() Class LJAItautec

	Local oRetorno 	:= Self:LeTotNTrib()

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
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
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetSubstit() Class LJAItautec

	Local oRetorno 	:= Self:LeTotSTrib()			//Objeto que sera retornado pela funcao
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
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
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetNumRedZ() Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cValor    := Space(18)                            	//String que recebera CRZ da impressora
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4ValRed", "4", cValor})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := cValToChar(Val(oParams:Elements(4):cParametro))
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
Method GetCancela() Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cValor    := Space(18)                            	//String que recebera contador de cupons cancelados da impressora
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4ValAtu", "5", cValor})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := AllTrim(oParams:Elements(4):cParametro)
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
Method GetInterve() Class LJAItautec                                      

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cValor    := Space(18)                            	//String que recebera contador de reinicio de operacoes da impressora
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4ValAtu", "0", cValor})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := AllTrim(oParams:Elements(4):cParametro)
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
Method GetDtUltRe() Class LJAItautec

	Local oParams 	:= Nil				//Objeto para passagem dos parametros
	Local cRetorno 	:= ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil				//Objeto que sera retornado pela funcao
	Local cNumRedZ  := Space(18)		//Numero da ultima reducao Z
	Local cQtdRegs 	:= Space(20)		//Para receber os dados da reducao
	
	//Pega o ultima reducao Z	                                  
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4RegMemFisc", "0", cNumRedZ})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
	            
    If(oRetorno:cAcao == OK)    		                            
		//Carrega o numero da ultima reducao Z 
		cNumRedZ := StrZero(Val(Self:CorrigRet(oParams:Elements(4):cParametro)),4) 
		
		//Prepara os parametros de envio
		oParams	:= Self:PrepParam({ITAUTEC, "E4RegMemFisc", cNumRedZ, cQtdRegs})
	    //Envia o comando    	
		cRetorno:= Self:EnviarCom(oParams)
	    //Trata o retorno    
	    oRetorno:= Self:TratarRet(cRetorno)
		    
	    If(oRetorno:cAcao == OK)    		                            
	    	oRetorno:oRetorno := Self:CorrigRet(SubStr(oParams:Elements(4):cParametro, 1, 8))  //Copia a data da ultima reducao  Z
	    EndIf
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
Method GetTotIss() Class LJAItautec

	Local oRetorno 	:= Self:LeTotIss()

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
Method GetDataMov() Class LJAItautec
	
	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cData	    := Space(9)                            		//Data da ECF
	Local cHora	    := Space(5)                            		//Hora da ECF
	Local cHorVerao	:= " "                                 		//Indica se esta no horario de verao "0" - Fora / "1" Dentro
	Local cDataMov	:= Space(9)                            		//Data do movimento
	Local cReducao	:= " "                                 		//Indica se foi feito uma Reducao Z na data de movimento "0" - Nao foi feita Redu��o Z / "1" - Foi feita Redu��o Z
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4RdData", cData, cHora, cHorVerao, cDataMov, cReducao})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso, retorna o codigo do registrador
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno :=	Substr(oParams:Elements(3):cParametro,1,2)  + "/" +;
								Substr(oParams:Elements(3):cParametro,3,2)  + "/" +;
							  	Substr(oParams:Elements(3):cParametro,5,4)  + " " +;
							  	Substr(oParams:Elements(4):cParametro,1,2)  + ":" +;
							  	Substr(oParams:Elements(4):cParametro,3,2)  + ":" +;
								"00"
	EndIf


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
Method GetFlagsFi() Class LJAItautec   

    Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cStatus	:= Space(14)	//String que recebera o retorno da funcao       
	Local nStaCup   := 0			//Recebera o status do cupom			
	Local cStaCup   := ""			//String que recebera o status do cupom			
	Local cStaRedz  := ""			//String que recebera o status apos a Reducao Z
	Local cDataEcf  := Space(9)    	//Data da ECF
	Local cHoraEcf  := Space(5)    	//Hora da ECF
	Local cVerao	:= " "          //Indica se esta no horario de verao "0" - Fora / "1" Dentro
	Local cDataMov	:= Space(9)     //Data do movimento
	Local cReducao	:= " "          //Indica se foi feito uma Reducao Z na data de movimento "0" - Nao foi feita Redu��o Z / "1" - Foi feita Redu��o Z
	
	Self:oFlagsFisc	:= LJCFlagsFiscaisECF():New()   
	
    //Impressora(Offline) 
    Self:oFlagsFisc:lEcfOff := .F.   
	
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4Status", cStatus})
    //Envia o comando
    cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno                                   
    oRetorno := Self:TratarRet(cRetorno)
    
    //Verifica estado do equipamento
	If ( oRetorno:cAcao == OK )   
		//Carrega Status
		cStatus := SubStr(oParams:Elements(3):cParametro, 1, 14)
            
		If SubStr(cStatus, 5, 1) == "1"
            //Pouco papel
    	    Self:oFlagsFisc:lPapelAcab := .T. 
        EndIf
            
		If SubStr(cStatus, 6, 1) == "1"
        	//Sem papel
        	Self:oFlagsFisc:lFimPapel := .T.    
        EndIf

		If SubStr(cStatus, 9, 1) == "1"
            //Estado da gaveta = 1 Aberta ou nao conectar na maquina 
	        Self:oFlagsFisc:lGavAberta := .T.   
        EndIf
            
		If SubStr(cStatus, 11, 1) == "0"
            //Modo de Intervencao Tecnica 
            Self:oFlagsFisc:lIntervenc := .T.     
        EndIf
	EndIf     
	       
    //Verifica se existe cupom aberto
	If ( oRetorno:cAcao == OK )   
		//Prepara os parametros de envio
		oParams := Self:PrepParam({ITAUTEC, "E4StaECF", cStaCup, cStaRedz})
	    //Envia o comando
	    cRetorno := Self:EnviarCom(oParams)
	    //Trata o retorno                                   
	    oRetorno := Self:TratarRet(cRetorno)

		If ( oRetorno:cAcao == OK )               
			//Carrega status do cupom      
			cStaCup	 := AllTrim(oParams:Elements(3):cParametro)
			//Carrega status do cupom apos reducao z
			cStaRedz := AllTrim(oParams:Elements(4):cParametro)
			//Prepara status do cupom 
			nStaCup := Val(cStaCup)
			
			Do Case
				Case nStaCup == 13
		            //Relat�rio Gerencial
	    	        Self:oFlagsFisc:lRGAberto := .T.        
				
				Case nStaCup == 2 .OR. nStaCup == 14 .OR. nStaCup == 16
		            //Cupom Fiscal aberto
		            Self:oFlagsFisc:lCFAberto := .T. 
		                  
			         //Recupera a fase atual do cupom fiscal		            
		            If nStaCup == 14
						Self:oFlagsFisc:lCFItem  := .T.
		            	Self:oFlagsFisc:lCFPagto := .T.
		            Else
		            	Self:oFlagsFisc:lCFTot   := .T.
		            EndIf

				Case nStaCup == 17 .OR. nStaCup == 18
		            //Comprovante de Credito ou Debito
		            Self:oFlagsFisc:lCVAberto := .T.
		        
		        Case nStaCup >= 19 .AND. nStaCup <= 25 
      	            //Comprovante Nao-Fiscal 
		            Self:oFlagsFisc:lNFAberto := .T.
			End Case	
		EndIf
	EndIf  
	 
	//Verifica dados da reducao Z	        
    If(oRetorno:cAcao == OK)    		
		//Prepara os parametros de envio
		oParams  := Self:PrepParam({ITAUTEC, "E4RdData", cDataEcf, cHoraEcf, cVerao, cDataMov, cReducao})
	    //Envia o comando    	
		cRetorno := Self:EnviarCom(oParams)
	    //Trata o retorno    
	    oRetorno := Self:TratarRet(cRetorno)  
	    		
	    If(oRetorno:cAcao == OK)  
			cDataEcf  :=	SubStr(oParams:Elements(3):cParametro, 1, 2) + "/" +; 
							SubStr(oParams:Elements(3):cParametro, 3, 2) + "/" +; 
							SubStr(oParams:Elements(3):cParametro, 5, 4) 
	    	cHoraEcf  := 	SubStr(oParams:Elements(4):cParametro, 1, 2) + ":" +;
					    	SubStr(oParams:Elements(4):cParametro, 3, 2)
	    	cVerao    := AllTrim(oParams:Elements(5):cParametro)
	    	cDataMov  := 	SubStr(oParams:Elements(6):cParametro, 1, 2) + "/" +; 
							SubStr(oParams:Elements(6):cParametro, 3, 2) + "/" +; 
							SubStr(oParams:Elements(6):cParametro, 5, 4) 
	    	cReducao  := AllTrim(oParams:Elements(7):cParametro)
		    
			dDataEcf  := CtoD(cDataEcf)
			dDataMov  := CtoD(cDataMov)
			                           
			If dDataEcf >= dDataMov .AND. cReducao == "1" 	
				//Reducao ja emitida			
				Self:oFlagsFisc:lInicioDia := .T.
	            Self:oFlagsFisc:lDiaFechad := .T.
	            Self:oFlagsFisc:lRedZPend  := .F.   
	            
			ElseIf dDataEcf > dDataMov .AND. cReducao == "0" 	
				//Reducao pendente
				Self:oFlagsFisc:lInicioDia := .T. 
	            Self:oFlagsFisc:lDiaFechad := .F.
	            Self:oFlagsFisc:lRedZPend  := .T.
			
			ElseIf Empty(cDataMov)
				//Necessita de inicio de dia
				Self:oFlagsFisc:lInicioDia := .F.
	           	Self:oFlagsFisc:lDiaFechad := .F.
	           	Self:oFlagsFisc:lRedZPend  := .F.
					
			Else
				//Dia iniciado
				Self:oFlagsFisc:lInicioDia := .T.
	            Self:oFlagsFisc:lDiaFechad := .F.
	            Self:oFlagsFisc:lRedZPend  := .F.
			EndIf            	
		EndIf
	EndIf

	If cRetorno == "2683"
		//Tampa superior aberta
        Self:oFlagsFisc:lTampAbert := .T.
	EndIf  
	
    oRetorno:oRetorno := Self:oFlagsFisc	//Copia o valor da propriedade da classe      
                	    	
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
Method BuscInfEcf() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	oRetorno:= Self:LeDadoUsu()
	
	If ( oRetorno:cAcao == OK )
		oRetorno:= Self:LeDadImp()	
	EndIf
		
	If ( oRetorno:cAcao == OK )
		oRetorno:= Self:LeCliche()   
	EndIf
	
	If ( oRetorno:cAcao == OK )
		oRetorno:= Self:LeOperador() 
	EndIf
	
	If ( oRetorno:cAcao == OK )
		oRetorno:= Self:LeECFLoja()
	EndIf 
	
	If ( oRetorno:cAcao == OK )
		oRetorno:= Self:LeAliq()
	EndIf
	
	If ( oRetorno:cAcao == OK )
		oRetorno:= Self:LeTotNF()
	EndIf
	
	If ( oRetorno:cAcao == OK )
		oRetorno:= Self:LeRelGer()
	EndIf
	
	If ( oRetorno:cAcao == OK )
		oRetorno:= Self:LeFinaliz()
	EndIf
		
Return oRetorno

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
Method CarregMsg() Class LJAItautec

	Self:AdicMsgECF("1"	,	STR0003, ERRO) 	//"Erro de comunicacao"
	Self:AdicMsgECF("0"	,	STR0004, OK)   	//"Sucesso" 
	Self:AdicMsgECF("998",	STR0129, ERRO)   	//"Data final de Emiss�o do ultimo cupom n�o encontrada."
	Self:AdicMsgECF("999",	STR0130, ERRO)   	//"Fun��o n�o suportada pelo modelo de ECF utilizado." 		
	Self:AdicMsgECF("2049", STR0005, ERRO) 	//"Parametro invalido."
	Self:AdicMsgECF("2560", STR0006, ERRO)	//"Erro interno (verifique se o arquivo cheques.ini esta no diretorio corrente da aplicacao)."
	Self:AdicMsgECF("2561", STR0007, ERRO)	//"Funcao invalida."
	Self:AdicMsgECF("2563", STR0008, ERRO) 	//"Funcao invalida com jumper de intervencao aberto."
	Self:AdicMsgECF("2564", STR0009, ERRO) 	//"Funcao invalida com jumper de intervencao fechado."
	Self:AdicMsgECF("2565", STR0010, ERRO) 	//"Dispositivo de impress�o invalido para execucao desta funcao."
	Self:AdicMsgECF("2566", STR0011, ERRO)	//"Funcao invalida fora do estado de pos reducao."
	Self:AdicMsgECF("2567", STR0012, ERRO) 	//"Parametro invalido, quando a funcao tiver um unico parametro, ou entao indica que uma string que deveria ter apenas dados ASCII, apresenta caracteres invalidos."
	Self:AdicMsgECF("2570", STR0013, ERRO)	//"Erro ao tentar gravar dados na Memoria Fiscal."
	Self:AdicMsgECF("2573", STR0014, ERRO)	//"Parametro data invalido."
	Self:AdicMsgECF("2574", STR0015, ERRO) 	//"Par�metro data � anterior � �ltima data gravada na mem�ria fiscal ou data do rel�gio � anterior � �ltima data gravada na mem�ria fiscal."
	Self:AdicMsgECF("2576", STR0016, ERRO)	//"Fun��o entra ou sai de hor�rio de ver�o inv�lida, pois j� se encontra no estado pedido."
	Self:AdicMsgECF("2578", STR0017, ERRO)	//"Fun��o define identifica��o do usu�rio inv�lida, pois a �rea reservada j� se encontra esgotada."
	Self:AdicMsgECF("2579", STR0018, ERRO)	//"Fun��o inv�lida, pois �rea reservada para grava��o de registros na Mem�ria Fiscal j� se encontra esgotada."
	Self:AdicMsgECF("2580", STR0019, ERRO)	//"Erro ao tentar endere�ar a Mem�ria Fiscal."
	Self:AdicMsgECF("2582", STR0020, ERRO)	//"Par�metro n�mero de registrador parcial inv�lido."
	Self:AdicMsgECF("2583", STR0021, ERRO)	//"Par�metro legenda do registrador parcial inv�lida."
	Self:AdicMsgECF("2585", STR0022, ERRO)	//"Registrador parcial j� definido (redefini��o inv�lida)."
	Self:AdicMsgECF("2592", STR0023, ERRO) 	//"Data do rel�gio inv�lida."
	Self:AdicMsgECF("2595", STR0024, ERRO)	//"Erro fim de papel (esgotou linhas permitidas ap�s sensor de pouco papel ou sensor de fim de papel indicando)."
	Self:AdicMsgECF("2600", STR0025, ERRO)	//"Comando de impress�o inv�lido."
	Self:AdicMsgECF("2602", STR0026, ERRO)	//"N�mero inv�lido de line feeds entre opera��es de venda, j� alcan�ou o n�mero m�ximo (8)ou N�mero inv�lido de line feeds entre opera��es fiscais (5 linhas) ou n�o fiscais (2 linhas)."
	Self:AdicMsgECF("2609", STR0027, ERRO)	//"Fun��o inv�lida, pois clich� n�o foi definido."
	Self:AdicMsgECF("2610", STR0028, ERRO)	//"Fun��o inv�lida dentro de cupom."
	Self:AdicMsgECF("2611", STR0029, ERRO)	//"Fun��o inv�lida fora de cupom."
	Self:AdicMsgECF("2612", STR0030, ERRO) 	//"Comando de venda (cupom ou comprovante) inv�lido ap�s as 2:00 do dia posterior a data de movimento. Fazer uma redu��o Z."
	Self:AdicMsgECF("2613", STR0031, ERRO)	//"J� foi feita uma redu��o nesta data de movimento. Nova venda (cupom ou comprovante) somente no dia seguinte."
	Self:AdicMsgECF("2614", STR0032, ERRO)	//"Fun��o inv�lida, pois ainda n�o totalizou."
	Self:AdicMsgECF("2615", STR0033, ERRO)	//"Fun��o inv�lida, pois j� totalizou."
	Self:AdicMsgECF("2616", STR0034, ERRO)	//"Identificador de par�metros de venda inv�lido."
	Self:AdicMsgECF("2619", STR0035, ERRO)	//"Par�metro quantidade de item inv�lido. O valor da quantidade de item devia ser (1,000), pois a coluna do pre�o unit�rio foi 0, ou seja, foi pedido para o mesmo n�o ser impresso."
	Self:AdicMsgECF("2623", STR0036, ERRO)	//"Falta par�metros obrigat�rias na venda de item."
	Self:AdicMsgECF("2624", STR0037, ERRO) 	//"Erro par�metro n�o caracter ASCII."
	Self:AdicMsgECF("2625", STR0038, ERRO)	//"Erro par�metro n�o d�gito num�rico ASCII."
	Self:AdicMsgECF("2626", STR0039, ERRO)	//"Numero de d�gitos do par�metro inv�lido."
	Self:AdicMsgECF("2628", STR0040, ERRO)	//"Overflow em opera��o de item. Mais de 10 d�gitos."
	Self:AdicMsgECF("2629", STR0041, ERRO)	//"Opera��o com valor 0,00."
	Self:AdicMsgECF("2634", STR0042, ERRO)	//"Valor do subtotal igual a 0."
	Self:AdicMsgECF("2635", STR0043, ERRO)	//"Erro divis�o por 0."
	Self:AdicMsgECF("2636", STR0044, ERRO)	//"Valor do desconto ao subtotal ou do acr�scimo financeiro maior ou igual a 100%."
	Self:AdicMsgECF("2639", STR0045, ERRO)	//"Cancelamento de cupom de venda inv�lido."
	Self:AdicMsgECF("2640", STR0046, ERRO)	//"Tipo de comprovante n�o fiscal inv�lido."
	Self:AdicMsgECF("2648", STR0047, ERRO)	//"Erro de comunica��o entre a IF e o micro."
	Self:AdicMsgECF("2653", STR0048, ERRO)	//"N�mero do item inv�lido: 0 ou maior que o do �ltimo item vendido."
	Self:AdicMsgECF("2655", STR0049, ERRO)	//"Item j� cancelado n�o pode anular, dar desconto ou cancelar."
	Self:AdicMsgECF("2656", STR0050, ERRO)	//"Desconto inv�lido: 0 ou valor do desconto maior que o da venda de item."
	Self:AdicMsgECF("2657", STR0051, ERRO)	//"Anula desconto inv�lido pois n�o ocorreu desconto no item."
	Self:AdicMsgECF("2661", STR0052, ERRO)	//"Opera��o inv�lida ap�s opera��es com subtotal ( desconto em subtotal ou acr�scimo financeiro)."
	Self:AdicMsgECF("2663", STR0053, ERRO)	//"Line Feed inv�lido pois j� imprimiu o n�mero m�ximo de linhas por opera��o (entre vendas, dentro de cupons)."
	Self:AdicMsgECF("2666", STR0054, ERRO)	//"Fim de papel."
	Self:AdicMsgECF("2670", STR0055, ERRO)	//"Problema no carro de impress�o."
	Self:AdicMsgECF("2683", STR0056, ERRO)	//"Tampa Aberta"
	Self:AdicMsgECF("2690", STR0057, ERRO) //"Erro de sequ�ncia de comando. Estado atual do ECF n�o permite a execu��o do comando."
	Self:AdicMsgECF("2691", STR0058, ERRO)	//"Comando mal formatado. Erro de parametro."
	Self:AdicMsgECF("2693", STR0059, ERRO)	//"Total pago ainda menor que subtotal."
	Self:AdicMsgECF("2698", STR0060, ERRO)	//"Acr�scimo no item j� efetuado."
	Self:AdicMsgECF("2701", STR0061, ERRO)	//"Sem registrador de forma de pagamento definido ou sem registrador n�o fiscal definido"
	Self:AdicMsgECF("2702", STR0062, ERRO)	//"Acr�scimo em item inv�lido."
	Self:AdicMsgECF("2703", STR0063, ERRO)	//"Cupom n�o fiscal vinculado inv�lido."
	Self:AdicMsgECF("2706", STR0064, ERRO)	//"Tamanho do c�digo invalido."
	Self:AdicMsgECF("2707", STR0065, ERRO)	//"Leitura X de in�cio de dia obrigat�ria."
	Self:AdicMsgECF("2724", STR0066, ERRO)	//"Cheque: erro no campo Data."
	Self:AdicMsgECF("2740", STR0067, ERRO)	//"N�o foi encontrado nenhum cartucho de dados vazio para ser inicializado."
	Self:AdicMsgECF("2741", STR0068, ERRO)	//"Cartucho com o n�mero de s�rie informado nao foi encontrado."
	Self:AdicMsgECF("2742", STR0069, ERRO)	//"N�mero de serie do ECF eh invalido na inicializa��o."
	Self:AdicMsgECF("2743", STR0070, ERRO)	//"Cartucho de MFD desconectado ou com problemas."
	Self:AdicMsgECF("2744", STR0071, ERRO)	//"Erro de escrita no dispositivo de MFD."
	Self:AdicMsgECF("2745", STR0072, ERRO)	//"Erro na tentativa de posicionar ponteiro de leitura."
	Self:AdicMsgECF("2746", STR0073, ERRO)	//"Endere�o do Bad Sector informado � inv�lido."
	Self:AdicMsgECF("2747", STR0074, ERRO)	//"Erro de leitura na MFD."
	Self:AdicMsgECF("2748", STR0075, ERRO)	//"Tentativa de leitura al�m dos limites da MFD."
	Self:AdicMsgECF("2749", STR0076, ERRO)	//"MFD n�o possui mais espa�o para escrita."
	Self:AdicMsgECF("2750", STR0077, ERRO)	//"Leitura da MFD serial e interrompida por comando diferente de LeImpressao."
	Self:AdicMsgECF("2751", STR0078, ERRO)	//"Erro Cancelamento Relatorio Gerencial."
	Self:AdicMsgECF("2819", STR0079, ERRO)	//"Porta serial inv�lida."
	Self:AdicMsgECF("2820", STR0080, ERRO)	//"Tipo do reset inv�lido."
	Self:AdicMsgECF("2821", STR0081, ERRO)	//"Opcao ver�o inv�lida."
	Self:AdicMsgECF("2822", STR0082, ERRO)	//"Op��o de hor�rio da redu��o Z inv�lida."
	Self:AdicMsgECF("2823", STR0083, ERRO)	//"Op��o de cupom inv�lida."
	Self:AdicMsgECF("2824", STR0084, ERRO)	//"Op��o de desconto do item inv�lida."
	Self:AdicMsgECF("2827", STR0085, ERRO)	//"Op��o de acr�scimo no cupom inv�lida."
	Self:AdicMsgECF("2828", STR0086, ERRO)	//"Tipo da Leitura da Mem�ria Fiscal inv�lido."
	Self:AdicMsgECF("2829", STR0087, ERRO)	//"Op��o da Leitura da Mem�ria Fiscal inv�lida."
	Self:AdicMsgECF("2830", STR0088, ERRO)	//"Op��o de desconto do item inv�lida."
	Self:AdicMsgECF("2838", STR0089, ERRO)	//"Informa��o solicitada n�o est� dispon�vel na vers�o do firmware do ECF."
	Self:AdicMsgECF("2839", STR0090, ERRO)	//"Registrador inv�lido na fun��o ValAtu."
	Self:AdicMsgECF("2840", STR0091, ERRO)	//"Registrador inv�lido na fun��o ValRed."
	Self:AdicMsgECF("2841", STR0092, ERRO)	//"Registrador inv�lido na fun��o ValImp."
	Self:AdicMsgECF("2842", STR0093, ERRO)	//"Categoria inv�lida na fun��o RPCria."
	Self:AdicMsgECF("2843", STR0094, ERRO)	//"Categoria inv�lida na fun��o RPPrim."
	Self:AdicMsgECF("2844", STR0095, ERRO)	//"Categoria inv�lida na fun��o RPProx."
	Self:AdicMsgECF("2845", STR0096, ERRO)	//"Redu��o inicial da Leitura da Mem�ria Fiscal inv�lida."
	Self:AdicMsgECF("2846", STR0097, ERRO)	//"Redu��o final da Leitura da Mem�ria Fiscal inv�lida."
	Self:AdicMsgECF("2847", STR0098, ERRO)	//"Redu��o inicial maior do que a Redu��o Final da Leitura da Mem�ria Fiscal."
	Self:AdicMsgECF("2848", STR0099, ERRO)	//"Data inicial da Leitura da Mem�ria Fiscal inv�lida."
	Self:AdicMsgECF("2849", STR0100, ERRO)	//"Data final da Leitura da Mem�ria Fiscal inv�lida."
	Self:AdicMsgECF("2850", STR0101, ERRO)	//"Data inicial maior do que a data Final da Leitura da Mem�ria Fiscal."
	Self:AdicMsgECF("2851", STR0102, ERRO)	//"Quantidade do item inv�lida."
	Self:AdicMsgECF("2852", STR0103, ERRO)	//"Pre�o unit�rio do item inv�lido."
	Self:AdicMsgECF("2854", STR0104, ERRO)	//"C�digo do item inv�lido."
	Self:AdicMsgECF("2855", STR0105, ERRO)	//"Descri��o do item inv�lida."
	Self:AdicMsgECF("2856", STR0106, ERRO)	//"Registrador Parcial inv�lido na fun��o OpeCNF."
	Self:AdicMsgECF("2858", STR0107, ERRO)	//"Modelo de ECF desconhecido."
	Self:AdicMsgECF("2859", STR0108, ERRO)	//"Erro no envio de pacotes para o ECF."
	Self:AdicMsgECF("2860", STR0109, ERRO)	//"Erro na recep��o de pacotes do ECF."
	Self:AdicMsgECF("2862", STR0110, ERRO)	//"Cupom ou comprovante em andamento n�o pode ser encerrado."
	Self:AdicMsgECF("2863", STR0111, ERRO)	//"Sinal inv�lido na fun��o OpeCNF."
	Self:AdicMsgECF("2864", STR0112, ERRO)	//"Sinal inv�lido na fun��o RPCria."
	Self:AdicMsgECF("2865", STR0113, ERRO)	//"Quantidade de registradores na Categoria excedida."
	Self:AdicMsgECF("2866", STR0114, ERRO)	//"ECF n�o se encontra em estado de p�s-redu��o."
	Self:AdicMsgECF("2867", STR0115, OK)	//"Final da lista de registradores na Categoria."
	Self:AdicMsgECF("2868", STR0116, ERRO)	//"J� foi realizada com sucesso a fun��o E4Open."
	Self:AdicMsgECF("2869", STR0117, ERRO)	//"Ainda n�o foi realizada com sucesso a fun��o E4Open."
	Self:AdicMsgECF("2870", STR0118, ERRO)	//"ECF n�o aceita documentos."
	Self:AdicMsgECF("2871", STR0119, ERRO)	//"N�o existe documento inserido."
	Self:AdicMsgECF("2872", STR0120, ERRO)	//"Existe documento inserido."
	Self:AdicMsgECF("2873", STR0121, ERRO)	//"Medida do cheque inv�lida."
	Self:AdicMsgECF("2880", STR0122, ERRO)	//"Banco n�o cadastrado."
	Self:AdicMsgECF("2881", STR0123, ERRO)	//"Valor do cheque inv�lido."
	Self:AdicMsgECF("2898", STR0124, ERRO)	//"Bobina acabando."
	Self:AdicMsgECF("2900", STR0125, ERRO)	//"Erro ao carregar DLL de protocolo."
	Self:AdicMsgECF("2902", STR0126, ERRO)	//"Erro ao abrir arquivo."
	Self:AdicMsgECF("2903", STR0127, ERRO)	//"Erro ao ler do arquivo."
	Self:AdicMsgECF("2904", STR0128, ERRO)	//"Erro ao escrever no arquivo."
	Self:AdicMsgECF("1182548",	" ", OK)   	//"Erro no fechamento da porta nao necessita de tratamento" 
	 
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
Method LeDadoUsu() Class LJAItautec

	Local oParams 	:= Nil					//Objeto para passagem dos parametros
	Local cRetorno 	:= ""					//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil					//Objeto que sera retornado pela funcao
	Local cSerie    := Space(22)			//Numero de serie de fabricacao do ECF		
	Local cCnpj     := Space(20)        	//CGC/CNPJ do proprietario atual do ECF
	Local cInsE     := Space(20)           	//Inscricao Estadual
	Local cInsM     := Space(20)			//Inscricao Municipal
	Local cCliche   := Space(255)			//Cliche definido na inicializacao
	Local cFirmWare	:= Space(6)				//Versao de firmware
	Local cSeq     	:= Space(6)				//Numero de sequencia do ECF
	Local cModelo   := Space(1)				//Modelo do ECF
	
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4InfECF",		cSerie, 	  cCnpj,        cInsE,;
														 cInsM,		cCliche, 	cFirmWare,;
														  cSeq, 	cModelo})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso, retorna o codigo do registrador
    If(oRetorno:cAcao == OK)    	
		Self:cCnpj	:= Self:CorrigRet(oParams:Elements(4):cParametro)		// Copia o C.N.P.J da impressora
		Self:cIE 	:= Self:CorrigRet(oParams:Elements(5):cParametro)	 	// Copia o I.E da impressora
		Self:cIM 	:= Self:CorrigRet(oParams:Elements(6):cParametro)		// Copia o I.M da impressora	
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
Method LeDadImp() Class LJAItautec

	Local oParams 	:= Nil					//Objeto para passagem dos parametros
	Local cRetorno 	:= ""					//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil					//Objeto que sera retornado pela funcao
	Local cSerie    := Space(21)			//Numero de serie de fabricacao do ECF		
	Local cCnpj     := Space(20)        	//CGC/CNPJ do proprietario atual do ECF
	Local cInsE     := Space(20)           	//Inscricao Estadual
	Local cInsM     := Space(20)			//Inscricao Municipal
	Local cCliche   := Space(255)			//Cliche definido na inicializacao
	Local cFirmWare	:= Space(6)				//Versao de firmware
	Local cSeq     	:= Space(6)				//Numero de sequencia do ECF
	Local cModelo   := Space(1)				//Modelo do ECF
	
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4InfECF",		cSerie, 	  cCnpj,        cInsE,;
														 cInsM,		cCliche, 	cFirmWare,;
														  cSeq, 	cModelo})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso, retorna o codigo do registrador
    If(oRetorno:cAcao == OK)    	
		Self:cNrSerie	:= Self:CorrigRet(oParams:Elements(3):cParametro)		// Copia o Numero de serie da impressora	
		Self:cFabric 	:= "ITAUTEC"									 		// Copia o Fabricante da impressora
		Self:cFirmWare	:= Self:CorrigRet(oParams:Elements(8 ):cParametro)		// Copia a Versao do Firmware da impressora
		cModelo		 	:= Self:CorrigRet(oParams:Elements(10):cParametro)		// Copia o Modelo da impressora
		
		Do Case
			Case cModelo == "4"
				Self:cModelo := "Itautec Infoway 1E T2"
				
			Case cModelo == "5" 
				Self:cModelo := "KUBUS 1EF"
			
			Case cModelo == "6"  
				Self:cModelo := "QW PRINTER 6000 MT2"
		End Case
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
Method LeCliche() Class LJAItautec

	Local oParams 	:= Nil					//Objeto para passagem dos parametros
	Local cRetorno 	:= ""					//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil					//Objeto que sera retornado pela funcao
	Local cCliche   := Space(255)			//Cliche definido na inicializacao
	Local cCliAux   := ""					//Variavel que contem o cliche

	//Prepara os parametros de envio    
	oParams := Self:PrepParam({ITAUTEC, "E4InfEspECF", "2", cCliche})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso, retorna o codigo do registrador
    If(oRetorno:cAcao == OK)     
    	//Carrega Cliche	
	    cCliche	:= Self:CorrigRet(oParams:Elements(4):cParametro)

		//Verifica se exixte mais que uma linha
		nPosStr := AT(ENTER, cCliche)	    
		
	    //Razao Social 
	    If nPosStr > 0
		    Self:cRazaoSoc := SubStr(cCliche, 1, nPosStr)
  	    	Self:cRazaoSoc := Self:CorrigRet(Self:cRazaoSoc)
		    nPosStr += Len(ENTER)
   		    cCliAux := cCliche
		    cCliche := SubStr(cCliAux, nPosStr, Len(cCliAux) - nPosStr)
   			nPosStr := AT(ENTER, cCliche)	    		    
	    EndIf
	                  
	    //Nome Fantasia
	    If nPosStr > 0
   		    Self:cFantasia := SubStr(cCliche, 1, nPosStr)
   		    Self:cFantasia := Self:CorrigRet(Self:cFantasia)		    
   		    nPosStr += Len(ENTER)
		    cCliAux := cCliche
		    cCliche := SubStr(cCliAux, nPosStr, Len(cCliAux) - nPosStr)
   			nPosStr := AT(ENTER, cCliche)	    		    
	    EndIf

	    //Endereco1   	
	    If nPosStr > 0
   		    Self:cEndereco1 := SubStr(cCliche, 1, nPosStr)
   	    	Self:cEndereco1 := Self:CorrigRet(Self:cEndereco1)		    
   		    nPosStr += Len(ENTER)
		    cCliAux := cCliche
		    cCliche := SubStr(cCliAux, nPosStr, Len(cCliAux) - nPosStr)
	    EndIf
	    
   	    //Endereco2
   		Self:cEndereco2 := Self:CorrigRet(cCliche)
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
Method LeOperador() Class LJAItautec

	Local oRetorno 	:= Nil					//Objeto que sera retornado pela funcao
	
    //Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
	Self:cOperador := ""
		
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
Method LeECFLoja() Class LJAItautec	

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cEcf  	:= ""//Space(310)	//Numero de Sequencia do ECF
	
	//Prepara os parametros de envio 
	oParams := Self:PrepParam({ITAUTEC, "E4InfEspECF", "5", cEcf})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao == OK)    	
    	Self:cNumEcf := Self:CorrigRet(oParams:Elements(4):cParametro)		    // Copia o numero do ECF
		Self:cLoja 	 := "0001"													// Copia o numero da Loja
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
Method LeAliq() Class LJAItautec
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cIndice	:= Space(2)		//String temporaria para armazenamento do numero do registrador lido
	Local cValor	:= Space(18)	//String temporaria para armazenamento do valor numerico da aliquota
	Local cTipo     := ""          	//Tipo do registrador lido
	                       
	//��������������������������Ŀ
	//�Carrega aliquotas de ICMS.�
	//����������������������������
	cTipo 	 := "2" //ICMS 
	//Prepara os parametros de envio - POSICIONA NO PRIMEIRO REGISTRADOR DE ICMS	    
	oParams	:= Self:PrepParam({ITAUTEC, "E4RPPrim", cTipo})
    //Envia o comando    	
	cRetorno:= AllTrim(Self:EnviarCom(oParams))
	//Trata o retorno    
    oRetorno:= Self:TratarRet(cRetorno)
    
    //Le Aliquotas de ICMS
    While (oRetorno:cAcao == OK .AND. cRetorno == "0")    	
		//Prepara os parametros de envio    
		oParams	:= Self:PrepParam({ITAUTEC, "E4RPLe", cTipo, cValor, "", cIndice})
	    //Envia o comando    	
		cRetorno:= Self:EnviarCom(oParams)
		//Trata o retorno    
	    oRetorno:= Self:TratarRet(cRetorno)
	    
	    //Verifica execucao correta e se nao eh fim de registrador de ICMS
        If(oRetorno:cAcao == OK .AND. cRetorno <> "2867")    
   			cValor := Self:CorrigRet(oParams:Elements(4):cParametro)		// Copia o valor numerico da aliquota	
   			cIndice:= Self:CorrigRet(oParams:Elements(6):cParametro)		// Copia o numero do indice do registrado na impressora
			Self:AdicAliq(cIndice, Val(cValor), .F.) 						// Insere na tabela a aliquota como I.C.M.S
        EndIf             
        //Inicializa Variaveis
		cIndice	:= Space(2)
		cValor	:= Space(18)
    End
            
	//��������������������������Ŀ
	//�Carrega aliquotas de ISS. �
	//����������������������������
	cTipo 	 := "4" //ISS 
	cValor   := Space(18)
	cIndice  := Space(2)	
	//Prepara os parametros de envio - POSICIONA NO PRIMEIRO REGISTRADOR DE ISS
	oParams	:= Self:PrepParam({ITAUTEC, "E4RPPrim", cTipo})
    //Envia o comando    	
	cRetorno:= AllTrim(Self:EnviarCom(oParams))
	//Trata o retorno    
    oRetorno:= Self:TratarRet(cRetorno)
    
    //Le Aliquotas de ISS
    While (oRetorno:cAcao == OK .AND. cRetorno == "0")    	
		//Prepara os parametros de envio    
		oParams	:= Self:PrepParam({ITAUTEC, "E4RPLe", cTipo, cValor, "", cIndice})
	    //Envia o comando    	
		cRetorno:= Self:EnviarCom(oParams)
		//Trata o retorno    
	    oRetorno:= Self:TratarRet(cRetorno)

	    //Verifica execucao correta e se nao eh fim de registrador de ISS
        If(oRetorno:cAcao == OK .AND. cRetorno <> "2867") 
   			cValor := Self:CorrigRet(oParams:Elements(4):cParametro)		// Copia o valor numerico da aliquota	   	
   			cIndice:= Self:CorrigRet(oParams:Elements(6):cParametro)		// Copia o numero do indice do registrado na impressora
			Self:AdicAliq(cIndice, Val(cValor), .T.)			   			// Insere na tabela a aliquota como I.S.S
        EndIf 
        //Inicializa Variaveis
		cIndice	:= Space(2)
		cValor	:= Space(18)
    End
	
Return oRetorno 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
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
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeTotNF() Class LJAItautec
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros.
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial.
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao.
	Local cDesc		:= Space(18)	//String temporaria para armazenamento da descricao do totalizador.
	Local cSinal    := " "         	//String temporaria para armazenamento do sinal do registrador "+" ou "-".
	Local cIndice	:= Space(2)		//String temporaria para armazenamento do indice do totalizador.
	
	cTipo 	 := "1" //Registradores nao fiscais   
	
	//Prepara os parametros de envio - POSICIONA NO PRIMEIRO REGISTRADOR NAO FISCAL
	oParams	:= Self:PrepParam({ITAUTEC, "E4RPPrim", cTipo})
    //Envia o comando    	
	cRetorno:= AllTrim(Self:EnviarCom(oParams))
	//Trata o retorno    
    oRetorno:= Self:TratarRet(cRetorno)
    
    //Le Registradores nao fiscais
    While (oRetorno:cAcao == OK .AND. cRetorno == "0")    	
		//Prepara os parametros de envio    
		oParams	:= Self:PrepParam({ITAUTEC, "E4RPLe", cTipo, cDesc, cSinal, cIndice})
	    //Envia o comando    	
		cRetorno:= Self:EnviarCom(oParams)
		//Trata o retorno    
	    oRetorno:= Self:TratarRet(cRetorno)

	    //Verifica execucao correta e se nao eh fim de registrador de n�o fiscais
        If(oRetorno:cAcao == OK .AND. cRetorno <> "2867")    
   			cDesc 	:= Self:CorrigRet(oParams:Elements(4):cParametro)		// Copia a descricao do totalizador
   			cSinal	:= Self:CorrigRet(oParams:Elements(5):cParametro)		// Copia o sinal do registrador "+" ou "-"
   			cIndice	:= Self:CorrigRet(oParams:Elements(6):cParametro)		// Copia o indice do totalizador
			Self:AdicTotNf(cIndice,cDesc,"E","") 			   				// Insere o totalizador nao fiscal na tabela.
        EndIf 
        //Inicializa variaveis
       	cDesc	:= Space(18)
		cSinal  := " "      
		cIndice	:= Space(2)	
    End

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
Method LeRelGer() Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros.
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial.
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao.
	Local cDesc		:= Space(18)	//String temporaria para armazenamento da descricao do relatorio.
	Local cSinal    := " "         	//Nao ha retorno para relatorio gerencial.
	Local cIndice	:= Space(2)		//String temporaria para armazenamento do indice do relatorio.
	
	cTipo 	 := "6" //Relatorios gerenciais
	
	//Prepara os parametros de envio - POSICIONA NO PRIMEIRO RELATORIO GERENCIAL
	oParams	:= Self:PrepParam({ITAUTEC, "E4RPPrim", cTipo})
    //Envia o comando    	
	cRetorno:= Self:EnviarCom(oParams)
	//Trata o retorno    
    oRetorno:= Self:TratarRet(cRetorno)
    
    //Le os Relatorios
    While (oRetorno:cAcao == OK .AND. cRetorno == "0")    	
		//Prepara os parametros de envio    
		oParams	:= Self:PrepParam({ITAUTEC, "E4RPLe", cTipo, cDesc, cSinal, cIndice})
	    //Envia o comando    	
		cRetorno:= Self:EnviarCom(oParams)
		//Trata o retorno    
	    oRetorno:= Self:TratarRet(cRetorno)
	    
	    //Verifica execucao correta e se nao eh fim de registrador de relatorio gerencial
        If(oRetorno:cAcao == OK .AND. cRetorno <> "2867")    
   			cDesc 	:= Self:CorrigRet(oParams:Elements(4):cParametro)		// Copia a descricao do totalizador
   			cIndice	:= Self:CorrigRet(oParams:Elements(6):cParametro)		// Copia o indice do totalizador
			Self:AdicGerenc(cIndice, cDesc)	   					 			// Insere o relatorio gerencial na tabela.
        EndIf   
        //Inicializa variaveis
    	cDesc	:= Space(18)
		cSinal  := " "      
		cIndice	:= Space(2)	
    End
    
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
Method LeFinaliz() Class LJAItautec

	Local oParams 	:= Nil			//Objeto para passagem dos parametros.
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial.
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao.
	Local cDesc		:= Space(18)	//String temporaria para armazenamento da descricao do relatorio.
	Local cVincula  := " "         	//String temporaria para armazenamento da indicacao de finalizadora vinculada "0" Nao permite CCD / "1" Permite CCD.
	Local cIndice	:= Space(2)		//String temporaria para armazenamento do indice do relatorio.
	Local lVincula  := .F.         	//Indica se a forma de pagamento eh vinculada ou nao
	
	cTipo 	 := "5" //Formas de pagamento
	
	//Prepara os parametros de envio - POSICIONA NA PRIMEIRA FORMA DE PAGAMENTO
	oParams	:= Self:PrepParam({ITAUTEC, "E4RPPrim", cTipo})
    //Envia o comando    	
	cRetorno:= Self:EnviarCom(oParams)
	//Trata o retorno    
    oRetorno:= Self:TratarRet(cRetorno)
    
    //Le as Formas de Pagamento
    While (oRetorno:cAcao == OK .AND. cRetorno == "0")    	
		//Prepara os parametros de envio    
		oParams	:= Self:PrepParam({ITAUTEC, "E4RPLe", cTipo, cDesc, cVincula, cIndice})
	    //Envia o comando    	
		cRetorno:= Self:EnviarCom(oParams)
		//Trata o retorno    
	    oRetorno:= Self:TratarRet(cRetorno)
	    
	    //Verifica execucao correta e se nao eh fim de registrador de forma de pagamento
        If(oRetorno:cAcao == OK .AND. cRetorno <> "2867")    
   			cDesc 	:= Self:CorrigRet(oParams:Elements(4):cParametro)		// Copia a descricao da forma de pagamento
   			cVincula:= Self:CorrigRet(oParams:Elements(5):cParametro)		// Copia a indicacao de finalizadora vinculada.
   			cIndice	:= Self:CorrigRet(oParams:Elements(6):cParametro)		// Copia o indice da forma de pagamento
   			
   			//Carrega parametro para indicar se forma de pagamento eh vinculada
   			lVincula:= IIF(cVincula == "1", .T., .F.)
   			
			Self:AdicForma(cIndice, cDesc, lVincula)				// Insere a finalizadora vinculada na tabela.
        EndIf 
        //Inicializa variaveis
		cDesc		:= Space(18)
		cVincula  	:= " "      
		cIndice		:= Space(2)	
		lVincula  	:= .F.      
    End

Return oRetorno 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
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
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeDataJor() Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cData	    := Space(9)                            		//Data da ECF
	Local cHora	    := Space(5)                            		//Hora da ECF
	Local cHorVerao	:= " "                                 		//Indica se esta no horario de verao "0" - Fora / "1" Dentro
	Local cDataMov	:= Space(9)                            		//Data do movimento
	Local cReducao	:= " "                                 		//Indica se foi feito uma Reducao Z na data de movimento "0" - Nao foi feita Redu��o Z / "1" - Foi feita Redu��o Z
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4RdData", cData, cHora, cHorVerao, cDataMov, cReducao})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso, retorna o codigo do registrador
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno :=	Substr(oParams:Elements(6):cParametro,1,2)  + "/" +;
								Substr(oParams:Elements(6):cParametro,3,2)  + "/" +;
							  	Substr(oParams:Elements(6):cParametro,5,4)  + " " +;
							  	"00"										 + ":" +;
							  	"00"										 + ":" +;
                                "00"
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
Method LeGT() Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cValor    := Space(18)                            	//String que recebera GT da impressora
	Local nValor    := 0										//Temporario com o grande total
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4ValAtu", "1", cValor})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)
	   	nValor := Val(oParams:Elements(4):cParametro) / 100
		oRetorno:oRetorno := cValToChar(nValor)
	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
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
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method LeCOO() Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cCoo      := Space(18)                            	//String que recebera os contadores da impressora
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4ValAtu", "3", cCoo})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := AllTrim(Substr(oParams:Elements(4):cParametro, 1, 6))
	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeTotCanc �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio dos    		  ���
���          �cancelamentos executados na impressora ( ICMS + ISS )  	  ���
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
Method LeTotCanc() Class LJAItautec
	
	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cCancel   := Space(18)                            	//String que recebera os totais cancelados da impressora
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4ValAtu", "7", cCancel})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Val(AllTrim(oParams:Elements(4):cParametro)) / 100
	EndIf
	
Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �LeTotCanIss �Autor  �Vendas Clientes     � Data �  17/06/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio dos    		  ���
���          �cancelamentos executados na impressora ( ISS )  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method LeTotCanIss() Class LJAItautec
	
	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cCancel   	:= Space(18)                           //String que recebera os totais cancelados da impressora
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4ValAtuEsp2", "88", cCancel}) //Indice 88 - Total de Cancelamentos ISSQN do dia
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
    //Pelos comandos somente � retornado os valores somados portanto retorna com valor igual a 0	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Val(AllTrim(oParams:Elements(4):cParametro)) / 100
	EndIf
		
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeTotDesc �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio dos    		  ���
���          �descontos executados na impressora ( ICMS + ISS )  	  	  ���
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
Method LeTotDesc() Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cDescont  := Space(18)                            	//String que recebera os totais de desconto da impressora
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4ValAtu", "8", cDescont})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Val(AllTrim(oParams:Elements(4):cParametro)) / 100
	EndIf

Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �LeTotDesIss�Autor  �Vendas Clientes     � Data �  06/03/08   ���
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
Method LeTotDesIss() Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cDescont  := Space(18)                            	//String que recebera os totais de desconto da impressora
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4ValAtuEsp2", "89", cDescont}) //Indice 89 - Total de Descontos ISS
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Val(AllTrim(oParams:Elements(4):cParametro)) / 100
	EndIf

Return oRetorno


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeTotAcre �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio dos    		  ���
���          �descontos executados na impressora ( ICMS + ISS )  	  	  ���
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
Method LeTotAcre() Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cAcresci  := Space(18)                            	//String que recebera os totais de acrescimo da impressora
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4ValAtu", "9", cAcresci})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Val(AllTrim(oParams:Elements(4):cParametro)) / 100
	EndIf

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeTotIsent�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio das vendas	  ���
���          �Isentas executadas na impressora ( I )	  				  ���
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
Method LeTotIsent() Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cIsenta   := Space(18)                            	//String que recebera os totais de Isentos
	            
	//Prepara os parametros de envio
	oParams	:= Self:PrepParam({ITAUTEC, "E4ValAtu", "12", cIsenta})
    //Envia o comando    	
	cRetorno:= Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno:= Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Val(AllTrim(oParams:Elements(4):cParametro)) /100
	EndIf
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeTotNTrib�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio dos    		  ���
���          �nao tributados vendidos na impressora ( N )			  	  ���
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
Method LeTotNTrib() Class LJAItautec
	
	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cNInciden := Space(18)                            	//String que recebera os totais de Nao incidencia
	            
	//Prepara os parametros de envio
	oParams	:= Self:PrepParam({ITAUTEC, "E4ValAtu", "13", cNInciden})
    //Envia o comando    	
	cRetorno:= Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno:= Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Val(AllTrim(oParams:Elements(4):cParametro)) / 100
	EndIf

Return oRetorno 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeTotSTrib�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio dos    		  ���
���          �substituicao tributaria ( F )			  	  				  ���
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
Method LeTotSTrib() Class LJAItautec
	
	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cSTribut  := Space(18)                            	//String que recebera os totais de Substituicao tributaria
	            
	//Prepara os parametros de envio
	oParams	:= Self:PrepParam({ITAUTEC, "E4ValAtu", "11", cSTribut})
    //Envia o comando    	
	cRetorno:= Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno:= Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Val(AllTrim(oParams:Elements(4):cParametro)) / 100
	EndIf

Return oRetorno 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeTotIss  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura do somatorio dos    		  ���
���          �tributados por aliquota sujeitos ao ISS.					  ���
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
Method LeTotIss() Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local nAliquotas:= 0
	Local nCont     := 1
	Local cIndice   := ""  
	Local cValor    := ""  
	Local nTotal    := 0
	
	//Carrega quantidade de aliquotas
	nAliquotas := Self:oAliquotas:Count()
	
	If nAliquotas > 0
		//Carrega os valores das aliquotas de ISS
		For nCont:=1 To nAliquotas  
			If (Self:oAliquotas:Elements(nCont):lIss)
				//Pega o indice da aliquota
				cIndice := Self:oAliquotas:Elements(nCont):cIndice
				//Prepara variavel para receber o valor				
				cValor 	:= Space(18)           
				//Prepara os parametros de envio
				oParams	:= Self:PrepParam({ITAUTEC, "E4ValAtu", cIndice, cValor})
			    //Envia o comando    	
				cRetorno:= Self:EnviarCom(oParams)
			    //Trata o retorno    
			    oRetorno:= Self:TratarRet(cRetorno)
			    // Caso o comando tenha sido executado com sucesso	
			    If(oRetorno:cAcao == OK)    	
			    	nTotal += Val(AllTrim(oParams:Elements(4):cParametro)) / 100
				EndIf
			Else
				//Caso nao exista aliquotas de ISS
				oRetorno:= Self:TratarRet("0")
				nTotal := 0
			EndIf
		Next nCont
		
		//Carrega retorno
	    If(oRetorno:cAcao == OK)    	
			oRetorno:oRetorno := nTotal
		EndIf
	Else
		//Caso nao exista aliquotas
		oRetorno:= Self:TratarRet("0")
		oRetorno:oRetorno := 0
	EndIf

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeVndLiq  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura da venda liquida    		  ���
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
Method LeVndLiq() Class LJAItautec                                          
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
���Programa  �LeVndBrut �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela leitura da Venda Bruta Atual.		  ���
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
Method LeVndBrut() Class LJAItautec	

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cDados    := Space(20)  								//String temporaria para pegar o retorno
	Local cNumRz    := Space(18)								//Numero da ultima reducao z
	Local cData     := ""                                      	//Data da reducao
	Local cHora     := ""										//Hora da reducao	
	Local cVendaBru := ""                                      	//Valor da venda bruta 

	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4RegMemFisc", "0", cNumRz})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
	            
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)  
    	//Retorna a quantidade de reducoes Z 
		cNumRz := cValToChar(Val(oParams:Elements(4):cParametro))
		//Prepara os parametros de envio
		oParams	:= Self:PrepParam({ITAUTEC, "E4RegMemFisc", cNumRz, cDados})
	    //Envia o comando    	
		cRetorno:= Self:EnviarCom(oParams)
	    //Trata o retorno    
	    oRetorno:= Self:TratarRet(cRetorno)

	    // Caso o comando tenha sido executado com sucesso		    
        If(oRetorno:cAcao == OK)   
        	cData     := AllTrim(SubStr(oParams:Elements(4):cParametro, 1, 8))
			cHora     := AllTrim(SubStr(oParams:Elements(4):cParametro, 9, 4))
			cVendaBru := AllTrim(SubStr(oParams:Elements(4):cParametro,13, 8))
			
			oRetorno:oRetorno := Val(cVendaBru) / 100
        EndIf
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
Method LeFaseCP() Class LJAItautec	

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cCupom	:= Space(2) 	                           	//String que recebera o status do cupom
	Local cStatRz	:= " "		                            	//String que recebera o status do cupom apos a ultima reduca z
	            
	//Prepara os parametros de envio
	oParams	:= Self:PrepParam({ITAUTEC, "E4StaECF", cCupom, cStatRz})
    //Envia o comando    	
	cRetorno:= Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno:= Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := Val(AllTrim(oParams:Elements(3):cParametro))
	EndIf
	
Return oRetorno

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
Method GetCancIt() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
   	oRetorno:oRetorno := "TODOS"

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetVlSupr �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar o valor do suprimento   	  ���
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
Method GetVlSupr() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
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
Method GetItImp() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
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
Method GetPosFunc() Class LJAItautec

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
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
Method GetPathMFD() Class LJAItautec

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
   	oRetorno:oRetorno := Self:cPathMFD //Copia o valor da propriedade da classe
   	
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
Method GetPathMF() Class LJAItautec

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
   	oRetorno:oRetorno := Self:cPathMF  //Copia o valor da propriedade da classe
   	
Return oRetorno  

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �GetPathTipoE �Autor  �Vendas Clientes     � Data �  21/07/09   ���
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
Method GetPathTipoE(cBinario) Class LJAItautec

	Local oRetorno 	:= Nil			 	//Objeto que sera retornado pela funcao
	Local cPath     := ""   
	Local cNomeArq  := ""           
	Local xDia		:= nil             //dia da Geracao do Arquivo
	Local xMes		:= nil             //Mes da Gera��o do Arquivo
	Local xAno		:= nil             //Ano da Gera��o do Arquivo
	Local dData		:= Date()			//Data de Gera��o do Arquivo         
	
	//Pega o Diretorio de Gravacao do arquivo Gerado

	Default cBinario := "0"
	
	If cBinario <> "1"
	 
		cPath := GetPvProfString("RFD", "Caminho", "C:\", GetClientDir() + "RFD.INI") 
		cPath := AllTrim(cPath)  
		
		dData := Self:dDataFimE   
		
		xDia := Day(dData)
		xMes := Month(dData)
		xAno := Year(dData)    
		
		If xDia < 10
			xDia := Str(xDia,1,0)
		Else     
			xDia := Chr(xDia-10+65)
		EndIf
		
		If xMes < 10
			xMes := Str(xMes,1,0)
		Else 
			xMes := Chr(xMes-10+65)
		EndIf  
		
		If xAno < 2010
			xAno := Str(xAno-2000,1)
		Else
		    xAno := Chr(xAno-2010+65)
		EndIf  
		
		
		
		//Pega o nome do arquivo gerado, considerando que a vers�ao do ato cotepe � o 08/07
		cNomeArq := "IT" +; //Fabricante 
					Self:cIdModECF+;//Identifica��o do Modelo do ECF alterado pelo m�todo construtor da classe filho
					Right(Self:cNrSerie,5) +;//5 �ltimos digitos do numero de Serie
					"."+;
					xDia+;//Dia da Gera��o do Arquivo
					xMes+;//Mes da Gera��o do Arquivo
					xAno //Ano da Gera��o do Arquivo
	    
	   	//Trata o retorno    
	    oRetorno := Self:TratarRet("0")     
	   
	    oRetorno:oRetorno := cPath + cNomeArq				//Copia o valor da propriedade da classe
	Else
		oRetorno := Self:TratarRet("0")  
	EndIf   	


   	
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
Method GetLetMem() Class LJAItautec

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    oRetorno:oRetorno := " "

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
Method GetTipEcf() Class LJAItautec

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
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
Method GetDatSW() Class LJAItautec

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    oRetorno:oRetorno := Self:dDataSW 
    

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
Method GetHorSW() Class LJAItautec

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
    oRetorno:oRetorno := Self:cHoraSW 

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
Method GetGrTIni() Class LJAItautec

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
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
Method GetNumCnf() Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cCNF    := Space(18)                            	//String que recebera contador de reinicio de operacoes da impressora
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4ValAtu", "2", cCNF})
       //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
       //Trata o retorno    
       oRetorno := Self:TratarRet(cRetorno)
       // Caso o comando tenha sido executado com sucesso	
       If(oRetorno:cAcao == OK)    	
     	  oRetorno:oRetorno := Self:CorrigRet(oParams:Elements(4):cParametro)
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
Method GetNumCrg() Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cCRG    := Space(18)                            	//String que recebera contador de reinicio de operacoes da impressora
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4ValAtu", "103", cCRG})
       //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
      //Trata o retorno    
      oRetorno := Self:TratarRet(cRetorno)
      // Caso o comando tenha sido executado com sucesso	
      If(oRetorno:cAcao == OK)    	
         oRetorno:oRetorno := Self:CorrigRet(oParams:Elements(4):cParametro)  
      EndIf
	

Return oRetorno  
	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetPathMFD�Autor  �Vendas Clientes     � Data �  10/09/09   ���
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
Method GetNumCcc() Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cCCC    := Space(18)                            	//String que recebera contador de reinicio de operacoes da impressora
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4ValAtu", "133", cCCC})
       //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
       //Trata o retorno    
       oRetorno := Self:TratarRet(cRetorno)
      //Caso o comando tenha sido executado com sucesso	
      If(oRetorno:cAcao == OK)    	
	oRetorno:oRetorno := Self:CorrigRet(oParams:Elements(4):cParametro)             
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
Method GetDtUDoc() Class LJAItautec

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
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
Method GetCodEcf() Class LJAItautec

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0")
    
   	oRetorno:oRetorno := "222101"	//Copia o valor da propriedade da classe

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LeCupIni  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em ler o cupom inicial do dia  		  ���
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
Method LeCupIni() Class LJAItautec
	
	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cValor    := Space(18)                            	//String que recebera numero do cupom
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4ValAtu", "80", cValor})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao == OK)    	
		oRetorno:oRetorno := StrZero( Val(oParams:Elements(4):cParametro) ,6)
	EndIf
		
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
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method MFDData(dDtInicio, dDtFim) Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	Local cDtInicio := ""										//Data inicio
	Local cDtFim 	:= ""		   								//Data fim
	
	cDtInicio := Padl(Day(dDtInicio), 2 , "0") + Padl(Month(dDtInicio), 2 , "0") + AllTrim(Str(Year(dDtInicio)))
	cDtFim  := Padl(Day(dDtFim), 2 , "0") + Padl(Month(dDtFim), 2 , "0") + AllTrim(Str(Year(dDtFim)))
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4LeMFD", "0", cDtInicio, cDtFim, Self:cPathMFD})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
	//Inicializando variaveis
    Self:InicVar()
    
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
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method MFDCoo(cCooInicio, cCooFim) Class LJAItautec

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
	            
	//Prepara os parametros de envio
	oParams := Self:PrepParam({ITAUTEC, "E4LeMFD", "1", cCooInicio, cCooFim, Self:cPathMFD})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)
	//Inicializando variaveis
    Self:InicVar()
			
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
Method TipoEData(cDatInicio, cDatFim, cPathArq, cBinario) Class LJAItautec

	Local oRetorno 	:= Nil			 	//Objeto que sera retornado pela funcao
	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
    Local dData		:= Ctod("")                                  //Convers�o de datas
    Local cTipo	    := "2"

	Default cPathArq := ""
	Default cBinario := "0" //Gera arquivo bin�rio?	
	
	If cBinario <> "1"
	
		dData := CtoD(cDatInicio)
		cDatInicio := StrZero(Day(dData),2)+StrZero(Month(dData),2)+StrZero(Year(dData),4)
		dData := CtoD(cDatFim)       
		Self:dDataFimE := dData  
		cDatFim  :=  StrZero(Day(dData),2)+StrZero(Month(dData),2)+StrZero(Year(dData),4)
		            
		//Prepara os parametros de envio
		oParams := Self:PrepParam({ITAUTEC, "E4GenRFD", cTipo, cDatInicio, cDatFim})
	       //Envia o comando    	
		cRetorno := Self:EnviarCom(oParams)
	       //Trata o retorno    
	       oRetorno := Self:TratarRet(cRetorno)
		//Inicializando variaveis
	       Self:InicVar()
    Else
    	 oRetorno := Self:TratarRet("999")
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
���Parametros�EXPC1 (1 - cCOOnicio) - COO inicial						 			 ���
���			 �EXPC2 (2 - cCOOFim) - COO final							 			 ���
������������������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										 			 ���
������������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
*/
Method TipoECrz(cCOOInicio, cCOOFim, cBinario) Class LJAItautec

	Local oRetorno 	:= Nil			 	//Objeto que sera retornado pela funcao
	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local cTipo	    := "2"
	Local dData		:= Ctod("")
	Local cSeriePDV   := "" //N�mero de Serie do PDV
	Local lProcessa := .T.
	Local dDataRedZ  := Ctod("")   
	Local cPDV       := ""
	Local dDtRz      := Ctod("")
     		                            

	Default cBinario := "0" //Gera arquivo bin�rio?	
	If cBinario <> "1"

		//Prepara para buscar data final do Coo
		//Primeiramente busca no SFI
		//Caso nao encontre, vai retrocedendo a mem�ria da impressora ate encontrar     
		oRetorno := Self:GetDataMov() 
		dData := CtoD(Substr(oRetorno:oRetorno,1,10))
		cCOOInicio := StrZero(Val(cCOOInicio),6)
		cCOOFim := StrZero(Val(cCOOFim),6) 
		cPDV    :=  Self:cNumEcf   
	    
		oRetorno := Self:GetDtUltRe()
		dDtRz   := Substr(oRetorno:oRetorno,5,4)+Substr(oRetorno:oRetorno,3,2) +Substr(oRetorno:oRetorno,1,2)
	
	    
		DbSelectArea("SFI")
		DbSetOrder(1)
		lProcessa := DbSeek(xFilial("SFI")+ dDtRz+cPDV,.T.)	  //Posiciona na ultima reducao Z 
		cSeriePDV := Alltrim(Self:cNrSerie) 
	
		Do While !SFI->(Bof()) .and. lProcessa  
			If  cSeriePDV = Alltrim(SFI->FI_SERPDV) //Guarda os dados da �tima redu�ao processada
				If Val(cCOOFim) <= (Val(SFI->FI_NUMFIM)+1) //So alimenta as vari�veis se o COO for menor igual ao registrado na redu��o Z
				   
					If Val(cCOOFim) < (Val(SFI->FI_NUMFIM)+1)
				    	 SFI->(DbSkip(-1) )
					EndIf 
					
					dDataRedZ := SFI->FI_DTMOVTO  
					lProcessa := .F.  
					Loop
		    	Else
		    		dDataRedZ := SFI->FI_DTMOVTO
		    		lProcessa := .F.
		    	EndIf
		    EndIf 
		    SFI->(DbSkip(-1) )
		EndDo 
		
		If !Empty(dDataRedZ) 
		
		  Self:dDataFimE  := dDataRedZ  
		 //Prepara os parametros de envio
		  oParams := Self:PrepParam({ITAUTEC, "E4GenRFD_COO", cTipo, cCOOInicio, cCOOFim})
		//Envia o comando    	
		  cRetorno := Self:EnviarCom(oParams)
		//Trata o retorno    
		oRetorno := Self:TratarRet(cRetorno)
		//Inicializando variaveis    
		Self:InicVar()
	    Else 
	        
	        oRetorno := Self:TratarRet("998")    //"Data final de Emiss�o do ultimo cupom n�o encontrada." 	    
	 	 	oRetorno:oRetorno := ""				//Copia o valor da propriedade da classe
	    EndIf
    Else
		oRetorno := Self:TratarRet("999")
    EndIf
    
Return oRetorno  

/*���������������������������������������������������������������������������
���Programa  �BuscaAliq �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel buscar o indece da aliquota              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cTribut) - Tributacao          			   	  ���
���			 �EXPN1 (2 - nAliquota) - Valor da aliquota   				  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method BuscaAliq(cTribut, nAliquota) Class LJAItautec
Local cRetorno 	:= ""     			//Retorno do metodo
Local nCount	:= 0				//Variavel de controle contador
Local oAliquota := Nil				//Objeto com os dados da aliquota

If SubsTr(cTribut,1,2) $ "FS|IS|NS"
	
	If SubsTr(cTribut,1,2) == "FS"
		cRetorno := "IS" + "1"
	ElseIf SubsTr(cTribut,1,2) == "IS"
		cRetorno := "IS" + "2"
	ElseIf SubsTr(cTribut,1,2) == "NS"
		cRetorno := "IS" + "3"
	EndIf
	
ElseIf SubsTr(cTribut,1,1) == "F"
	//Substituido
	cRetorno := "11"
	
ElseIf SubsTr(cTribut,1,1) == "I"
	//Isento	
	cRetorno := "12"
	
ElseIf SubsTr(cTribut,1,1) == "N"
    //Nao tributado
	cRetorno := "13"	
	
Else
	//Tributados ICMS / ISS
	For nCount := 1 To Self:oAliquotas:Count()
		
		oAliquota := Self:oAliquotas:Elements(nCount)
		
		If SubsTr(cTribut,1,1) == "T" 
   			//Tributado
   			If !(oAliquota:lIss) .AND. oAliquota:nAliquota == nAliquota
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

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
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
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method InicVar() Class LJAItautec

	Self:oFormasVen := Nil  
	Self:cMsgCNF 	:= ""

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
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
���Retorno   �Nil														  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GuardarPgt(cForma, nValor) Class LJAItautec

	Local oForma := Nil								//Objeto do tipo LJCFormaEcf

	If Self:oFormasVen == Nil
		//Instancia o objeto LJCFormasECF
		Self:oFormasVen := LJCFormasECF():New()	
	EndIf 
    
    //Instancia o objeto LJCFormaEcf
	oForma := LJCFormaEcf():New(Nil, cForma, Nil, nValor)
	//Adiciona a forma na colecao
	Self:oFormasVen:ADD(1, oForma, .T.)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GuardarPgt�Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Registra os dados do cliente na abertura do cupom           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cCnpj) - C.N.P.J/C.P.F do cliente.			   	  ���
���			 �EXPC2 (2 - cCliente) - Nome do cliente.   				  ���
���			 �EXPC3 (3 - cEndereco) - Endereco do cliente.			   	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method RegCliente(cCliente, cCnpj, cEndereco) Class LJAItautec		

	Local oParams 	:= Nil										//Objeto para passagem dos parametros
	Local cRetorno 	:= ""										//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil										//Objeto que sera retornado pela funcao
    
    If !Empty(cCnpj) .OR. !Empty(cCliente) .OR. !Empty(cEndereco)
	   	cCliente := SubStr(cCliente	  , 1, 30)
		cCnpj    := SubStr(cCnpj	  , 1, 26)
		cEndereco:= SubStr(cEndereco  , 1, 80)
		                                
		//Prepara os parametros de envio 
		oParams  := Self:PrepParam({ITAUTEC, "E4Cons", cCliente, cCnpj, cEndereco})	
	    //Envia o comando
	    cRetorno := AllTrim(Self:EnviarCom(oParams))
	    //Trata o retorno
	    oRetorno := Self:TratarRet(cRetorno)     
    Else
	    //Trata o retorno
	    oRetorno := Self:TratarRet("0")     
    EndIf
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TransVlr  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em transformar o valor, enviado para     ���
���          �a impressora.                                               ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPN1 - Valor a ser convertido							  ���
�������������������������������������������������������������������������͹��
���Retorno   �String cValor												  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TransVlr(nValor) Class LJAItautec

	Local cValAux:= ""
	Local cValor := ""                                                     
	Local nPos   := 0
	
    cValor 	:= cValToChar(nValor)
    cValor	:= StrTran(cValor, ".", ",")    
    
    nPos	:= At(",", cValor)
        
    If nPos > 0
	    cValAux  := SubStr(cValor, nPos)
	    cValAux  := Padr(cValAux, 3, "0")
	    cValor	 := SubStr(cValor, 1, nPos-1) + cValAux
    EndIf
    
Return cValor

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
Method CorrigRet(cRetorno) Class LJAItautec

	Local cRet := ""
	
	cRetorno := AllTrim(cRetorno)    
	
	cRetorno := StrTran(cRetorno, Chr(13), "")
	
	cRetorno := StrTran(cRetorno, Chr(10), "")
	
	cRet := LjAsc2Hex(cRetorno)

	cRet := StrTran(cRet, "00")
	
	cRet := LjHex2Asc(cRet)
	
	cRet := AllTrim(cRet)
	
Return cRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TratParam �Autor  �Vendas Clientes     � Data �  06/03/08   ���
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
Method TratParam(cRetorno) Class LJAItautec

	Local cRet := ""
	                          
	cRet := StrTran(cRetorno, Chr(13), Chr(10))
	
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
Method TrataTags( cMensagem ) Class LJAItautec
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
Method GetCodDllECF() Class LJAItautec       

	Local oRetorno := Nil		 //Objeto que sera retornado pela funcao	
    oRetorno := ::TratarRet("0")
    
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
Method GetNomeECF() Class LJAItautec       

    Local cMarca := space(15)  
    Local cModelo := space(20)
    Local cFirmWare := ""
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cBuffer  	:= Space(255)	//Numero de Sequencia do ECF
	
	//Prepara os parametros de envio 
	//oParams := Self:PrepParam({ITAUTEC, "E4InfEspECF", "6", cBuffer})   //Marca
    //Envia o comando    	
	//cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    //oRetorno := Self:TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
    //If(oRetorno:cAcao == OK)    	
    	cMarca := "ITAUTEC"		    // Copia o numero do ECF													// Copia o numero da Loja
        
	 //	cBuffer := space(255)
		 
		//Modelo 
		oParams := Self:PrepParam({ITAUTEC, "E4InfEspECF", "7", cBuffer})   //Modelo
	    //Envia o comando    	
		cRetorno := Self:EnviarCom(oParams)
	    //Trata o retorno    
	    oRetorno := Self:TratarRet(cRetorno)
	    
	    // Caso o comando tenha sido executado com sucesso
	    If(oRetorno:cAcao == OK)    	
		    cModelo := Self:CorrigRet(oParams:Elements(4):cParametro)
	
			//FirmWare 
			oParams := Self:PrepParam({ITAUTEC, "E4InfEspECF", "8", cBuffer})   //Vers�o firmware
		    //Envia o comando    	
			cRetorno := Self:EnviarCom(oParams)
		    //Trata o retorno    
		    oRetorno := Self:TratarRet(cRetorno)
		   
		   	If(oRetorno:cAcao == OK)    
		   			cFirmWare := Self:CorrigRet(oParams:Elements(4):cParametro)
		   	EndIf
			
			oRetorno:oRetorno := AllTrim(cMarca) + " " + ;
									AllTrim(cModelo) + " - V. "+;
									AllTrim(cFirmWare)
         
		EndIf

//	EndIf	
	
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetPathMFBin �Autor  �Vendas Clientes     � Data � 10/12/13 ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em retornar o caminho e nome do arquivo  ���
���          �de Memoria Fiscal Binaria.		                   		    ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  	���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  			���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  		���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetPathMFBin() Class LJAItautec

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("999")
    
   	
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
Method DownMF() Class LJAItautec

	Local oRetorno := Nil			  //Objeto que sera retornado pela funcao   
	
    //Trata o retorno    
    oRetorno := ::TratarRet("999")    
    
Return oRetorno  


/* 
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������ͻ��
���Programa  �RedZDado  �Autor  �Vendas Clientes     � Data �  10//12/2013 			 ���
������������������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por retornar os dados da Redu��o                             .���
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
Method RedZDado() Class LJAItautec

	//Local oParams  := Nil			  //Objeto para passagem dos parametros
	//Local cRetorno := ""			  //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			  //Objeto que sera retornado pela funcao   
	//Local oRedZ := NIL			  	//Dados da �ltima redu��o
	
	
	oRetorno := ::TratarRet("0")     
    
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
Method IdCliente(cCnpj, cNome, cEnd) Class LJAItautec
Local oRetorno := Nil		 //Objeto que sera retornado pela funcao	
oRetorno := ::TratarRet("0")

Return oRetorno
