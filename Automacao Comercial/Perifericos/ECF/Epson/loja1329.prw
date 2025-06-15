#INCLUDE "MSOBJECT.CH" 
#INCLUDE "DEFECF.CH"

Function LOJA1329 ; Return 	 // "dummy" function - Internal Use 

/*
������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������ͻ��
���Classe    �LJCEpsonTMT81FB010700  �Autor  �Vendas Clientes     � Data �  02/09/09   ���
��������������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em se comunicar com a impressora Epson TM-T81FB 01.07.00     ���
��������������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		       ���
��������������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������������
������������������������������������������������������������������������������������������
*/
Class LJCEpsonTMT81FB010700 From LJAEpson
		
	Method New(oTovsApi)										//Metodo construtor
	
	//Autenticacao e cheque
	Method Autenticar(cTexto)									//Autentica documento / cheque
	Method ImpCheque(cBanco	, cValor, cData    , cFavorecid , ;
					 cCidade, cTexto, cExtenso , cMoedaS    , ;
					 cMoedaP)									//Imprime cheque              
					 
	Method GetCodEcf() 											//Retorna codigo da impressora
					 
EndClass

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �New   	       �Autor  �Vendas Clientes     � Data �  02/09/09   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCEpsonTMT81FB010700.			     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oTotvsAPI) - Objeto do tipo LJCTotvsApi.				 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method New(oTovsApi) Class LJCEpsonTMT81FB010700

	//Executa o construtor da classe pai
	_Super:New(oTovsApi)
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Autenticar�Autor  �Vendas Clientes     � Data �  02/09/09   ���
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
Method Autenticar(cTexto) Class LJCEpsonTMT81FB010700

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpCheque �Autor  �Vendas Clientes     � Data �  02/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por efetuar a impressao de cheque.		  ���
���          �								                              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cBanco) - Numero do banco.						  ���
���			 �EXPC2 (2 - cValor) - Valor do cheque.						  ���
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
Method ImpCheque(cBanco	, cValor, cData    , cFavorecid , ;
				 cCidade, cTexto, cExtenso , cMoedaS    , ;
				 MoedaP) Class LJCEpsonTMT81FB010700

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")					 
	    
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
Method GetCodEcf() Class LJCEpsonTMT81FB010700

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0000")
    
   	oRetorno:oRetorno := "150406"	//Copia o valor da propriedade da classe

Return oRetorno
