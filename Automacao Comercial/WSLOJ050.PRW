#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH" 
#INCLUDE "WSLOJ050.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � WSLOJ050 �Autor  �Venda Clientes      � Data �  02/02/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � Web Service de consulta de estoque por filial              ���
�������������������������������������������������������������������������͹��
���Uso       � SigaLoja/FrontLoja                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function WSLOJ050
Return (Nil)  

WSSTRUCT WSRetEtq
	WSDATA cFil  		AS String			//01 - Filial	
	WSDATA cProduto		AS String           //02 - Codigo do produto
	WSDATA cLocalProd	AS String           //03 - Local do produto				 
	WSDATA cUnidade		AS String           //04 - Unidade de medida do Produto		
	WSDATA cGrupo		AS String           //05 - Grupo do produto
	WSDATA cDescri		AS String           //06 - Descricao do produto 
	WSDATA nInicial		AS Float            //07 - Quantidade inicial do produto	
	WSDATA nAtual		AS Float            //08 - Saldo atual do produto 
	WSDATA nPreco1		AS Float            //09 - Preco 1 
	WSDATA nPreco2		AS Float            //10 - Preco 2 
	WSDATA nPreco3		AS Float            //11 - Preco 3 
	WSDATA nPreco4		AS Float            //12 - Preco 4 
	WSDATA nPreco5		AS Float            //13 - Preco 5 
	WSDATA nPreco6		AS Float            //14 - Preco 6 
	WSDATA nPreco7		AS Float            //15 - Preco 7 
	WSDATA nPreco8		AS Float            //16 - Preco 8 
	WSDATA nPreco9		AS Float            //17 - Preco 9 
ENDWSSTRUCT

WSSTRUCT WSRetFil
	WSDATA cCodFil 		AS String			//01 - Codigo da Filial	
	WSDATA cNameFil		AS String           //02 - Nome Filial
	WSDATA cCidEnt  	AS String           //03 - Codigo municipio				 
ENDWSSTRUCT 

WSSERVICE LojEstoque    DESCRIPTION STR0001		// "Servico de consulta de estoque por filial"
    
	WSMETHOD VlLink   	DESCRIPTION STR0002		// "Valida conexao com Web Service" 
	WSMETHOD ConEstoque DESCRIPTION STR0003		// "Consulta estoque por filial" 
	WSMETHOD ConFiliais DESCRIPTION STR0004		// "Consulta Filiais" 
	
	WSDATA cEmpPDV	    AS String OPTIONAL      // Empresa
	WSDATA cFilPDV	    AS String OPTIONAL      // Filial
	WSDATA cConn		AS String               // Connection
	WSDATA lSend		AS Boolean OPTIONAL	    // Status ws
	WSDATA aProdEst	    AS Array OF WSRetEtq    // Array para retorno do estoque do produto
	WSDATA cFil			AS String               // Codigo da filial
	WSDATA cProduto		AS String               // Codigo do produto
	WSDATA cLocalProd	AS String               // Codigo do Local
	WSDATA aFil	    	AS Array OF WSRetFil    // Array para retorno das filiais

ENDWSSERVICE

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Metodo	 � VlLink   � Autor � Venda Clientes        � Data �02/02/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se existe conexao com webservice					  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Connection		                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � ExpL1 - Retorna se a conexao esta ativa (.T.) ou nao (.F.) ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SigaLoja/FrontLoja										  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD VlLink WSRECEIVE cConn WSSEND lSend WSSERVICE LojEstoque

//������������������������������������Ŀ
//�Retorna que o Web service esta ativo�
//��������������������������������������
Self:lSend := (.T.)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Metodo	 �ConEstoque� Autor � Venda Clientes        � Data �02/02/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta estoque por filial								  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Codigo da filial                                   ���
���          � ExpC2 - Codigo do produto                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � ExpA1 - Estrutura contendo o estoque do produto			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SigaLoja/FrontLoja										  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD ConEstoque WSRECEIVE cEmpPDV, cFilPDV ,cFil, cProduto, cLocalProd WSSEND aProdEst WSSERVICE LojEstoque

Local aArea	    	:= GetArea() 		// Guarda area atual
Local aRetorno		:={}			    // Retorno de funcao

Private lMsErroAuto := .F.      	    // Controle de mensagem de erro

If FindFunction('LjPreparaWs')
	LjPreparaWs(Self:cEmpPDV,Self:cFilPDV)
EndIf

//��������������������������������������������������������������Ŀ
//�Executa funcao de consulta estoque por filial e retornar array�
//����������������������������������������������������������������
If FindFunction('LJXPosEst')
	aRetorno := LJXPosEst(Self:cFil, Self:cProduto, Self:cLocalProd)
EndIf

//����������������������������������������Ŀ
//�Retorna o array com estoque do produto  �
//������������������������������������������
Self:aProdEst		:={}  // Retorno de funcao
If Len(aRetorno) > 0
		AAdd( Self:aProdEst, WSClassNew("WSRetEtq") )	
		Self:aProdEst[1]:cFil  			:= aRetorno[1][1]			 //01 - Filial	
		Self:aProdEst[1]:cProduto		:= aRetorno[1][2]           //02 - Codigo do produto
		Self:aProdEst[1]:cLocalProd		:= aRetorno[1][3]           //03 - Local do produto				 
		Self:aProdEst[1]:cUnidade		:= aRetorno[1][4]           //04 - Unidade de medida do Produto		
		Self:aProdEst[1]:cGrupo			:= aRetorno[1][5]           //05 - Grupo do produto
		Self:aProdEst[1]:cDescri		:= aRetorno[1][6]           //06 - Descricao do produto 
		Self:aProdEst[1]:nInicial		:= aRetorno[1][7]           //07 - Quantidade inicial do produto	
		Self:aProdEst[1]:nAtual			:= aRetorno[1][8]           //08 - Saldo atual do produto 
		Self:aProdEst[1]:nPreco1		:= aRetorno[1][9]           //09 - Preco 1 
		Self:aProdEst[1]:nPreco2		:= aRetorno[1][10]		 	 //10 - Preco 2 
		Self:aProdEst[1]:nPreco3		:= aRetorno[1][11]          //11 - Preco 3 
		Self:aProdEst[1]:nPreco4		:= aRetorno[1][12]          //12 - Preco 4 
		Self:aProdEst[1]:nPreco5		:= aRetorno[1][13]          //13 - Preco 5 
		Self:aProdEst[1]:nPreco6		:= aRetorno[1][14]          //14 - Preco 6 
		Self:aProdEst[1]:nPreco7		:= aRetorno[1][15]          //15 - Preco 7 
		Self:aProdEst[1]:nPreco8		:= aRetorno[1][16]          //16 - Preco 8 
		Self:aProdEst[1]:nPreco9		:= aRetorno[1][17]          //17 - Preco 9 
EndIf

//����������������������Ŀ
//�Restaura area anterior�
//������������������������
RestArea( aArea )
	
Return (.T.)      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Metodo	 �ConFiliais� Autor � Venda Clientes        � Data �02/02/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta filiais											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Codigo da empresa                                  ���
���          � ExpC2 - Codigo da filial                                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � ExpA1 - Retorna Estrutura contendo as filiais			  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SigaLoja/FrontLoja										  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD ConFiliais WSRECEIVE cEmpPDV, cFilPDV WSSEND aFil WSSERVICE LojEstoque

Local aArea	    	:= GetArea() 		// Guarda area atual
Local aRetorno		:={}			    // Retorno de funcao
Local nX			:= 0				// Controle de laco

Private lMsErroAuto := .F.      	    // Controle de mensagem de erro

If FindFunction('LjPreparaWs')
	LjPreparaWs(Self:cEmpPDV,Self:cFilPDV)
EndIf

//������������������������������������������������������Ŀ
//�Executa funcao de consulta de filiais e retorna array �
//��������������������������������������������������������
If FindFunction('LJXGetFil')
	aRetorno := LJXGetFil()
EndIf

//��������������������������������Ŀ
//�Retorna o array com as Filiais  �
//����������������������������������
Self:aFil		:={}  // Retorno de funcao
If Len(aRetorno) > 0
	For nX := 1 To Len(aRetorno)
		AAdd( Self:aFil, WSClassNew("WSRetFil") )	
		Self:aFil[nX]:cCodFil		:= aRetorno[nX][1]			  //01 - Codigo da Filial	
		Self:aFil[nX]:cNameFil		:= aRetorno[nX][2]           //02 - Nome Filial
		Self:aFil[nX]:cCidEnt		:= aRetorno[nX][3]           //03 - Codigo municipio				 
	Next nX		
EndIf

//����������������������Ŀ
//�Restaura area anterior�
//������������������������
RestArea( aArea )
	
Return (.T.)       
 
