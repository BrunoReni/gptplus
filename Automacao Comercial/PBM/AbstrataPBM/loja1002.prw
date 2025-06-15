#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1002.CH"
  
User Function LOJA1002 ; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJAAbstrataPBM   �Autor  �Vendas Clientes     � Data �  04/09/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe abstrata que possui as propriedades e metodos comuns das	 ���
���          �PBMS. 													  		 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJAAbstrataPBM

	Data cData								//Data da transacao
	Data cHora								//Hora da transacao
	Data cNumCupom							//Numero do cupom da transacao
	Data nCodOper							//Codigo do operador
	Data oProdAutor							//Objeto do tipo LJCPRODUTOSAUTORIZADOS
	Data oProdVend							//Objeto do tipo LJCPRODUTOSVENDIDOS
	Data oComprova							//Objeto do tipo LJCCOMPROVANTE
	Data oMensagem							//Objeto do tipo LJCMENSAGEM
	Data nRedeDest							//Rede de destino
	Data nIndTrans							//Indicador da transacao
	Data nNumAutori							//Numero da autorizacao
	Data oGlobal							//Objeto do tipo LJCGlobal
	
	Method AbstratPBM()						//Metodo construtor
	Method CapDadTela(cTitulo, cTpCampo, nMin, nMax, ;				
                  	  cCampo, oRet)			//Metodo para capturar dados solicitados ao operador    
	Method GrvArqTef()						//Metodo para gravar o arquivo de controle do tef						    
	Method ApagArqTef()						//Metodo para apagar o arquivo de controle do tef
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �AbstratPBM�Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJAAbstrataPBM.                        ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros� 											   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method AbstratPBM() Class LJAAbstrataPBM
	
	::oGlobal		:= LJCGlobal():Global()
	::cData			:= Str(Year(Date()),4) + StrZero(Month(Date()),2) + StrZero(Day(Date()),2)
	::cHora			:= SubStr(Time(),1,2) + SubStr(Time(),4,2) + SubStr(Time(),7,2)
	::cNumCupom		:= ""
	::nCodOper		:= 0
	::oProdAutor 	:= LJCProdutosAutorizados():ProdAutori()
	::oProdVend 	:= LJCProdutosVendidos():ProdVend()
	::oComprova		:= LJCComprovantePBM():ComprovPBM()
	::oMensagem 	:= LJCMensagem():Mensagem()
	::nRedeDest		:= 0
	::nIndTrans		:= 0
	::nNumAutori	:= 0
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �CapDadTela�Autor  �Vendas Clientes     � Data �  13/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel capturar dados solicitados ao operador.         ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTitulo)  - Titulo da tela.					  ���
���			 �ExpC2 (2 - cTpCampo) - Tipo do campo, A-alfanumerico,		  ���
���			 �						 N-numerico e F-flag(S/N).   		  ���
���			 �ExpN1 (3 - nMin) 	   - Tamanho minimo do campo.			  ���
���			 �ExpN2 (4 - nMax) 	   - Tamanho maximo do campo.			  ���
���			 �ExpC3 (5 - cCampo)   - Nome do campo.			              ���
���			 �ExpO1 (6 - oRet)     - Retorno do conteudo digitado no campo���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CapDadTela(cTitulo, cTpCampo, nMin, nMax, ;
                  cCampo, oRet) Class LJAAbstrataPBM
      
	Local oTela		:= Nil					//Objeto da tela onde sera capturado os dados da tela
	Local lRetorno 	:= .F.					//Variavel de retorno da funcao
		
	//Estancia o objeto LJCTelaCaptura
	oTela := LJCTelaCaptura():TelCap(cTitulo)
		
	oTela:cTipoCampo 	:= cTpCampo
	oTela:nMinimo 		:= nMin
	oTela:nMaximo 		:= nMax
	oTela:cCampo 		:= cCampo
            
	//Chama a tela
	oTela:Show()
        
	//Verifica se a tela (processo) foi cancelado
	If oTela:lCancelado == .F.
		lRetorno := .T.	
		oRet := oTela:oRetSelect
	EndIf

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GrvArqTef �Autor  �Vendas Clientes     � Data �  18/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em gravar o arquivo de controle do tef.         ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �		                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GrvArqTef() Class LJAAbstrataPBM
	
	Local lRetorno := .F.							//Retorno do metodo	
	
	//Grava o arquivo de controle
	lRetorno := ::oGlobal:GravarArq():TransTef(::cData, ::cHora):_Gravar(::cNumCupom + "/" + ::cData + "/" + ::cHora)

	//Grava log
	If lRetorno
		::oGlobal:GravarArq():Log():Tef():_Gravar("Arquivo de controle PBM gravado com sucesso (Cupom: " + ::cNumCupom + " ; Data: " + ::cData + " ; Hora: " + ::cHora + ")")
	Else
		::oGlobal:GravarArq():Log():Tef():_Gravar("Arquivo de controle PBM nao foi gravado (Cupom: " + ::cNumCupom + " ; Data: " + ::cData + " ; Hora: " + ::cHora + ")")
	EndIf
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ApagArqTef�Autor  �Vendas Clientes     � Data �  18/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em apagar o arquivo de controle do tef.         ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �				                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ApagArqTef() Class LJAAbstrataPBM						
	
	Local lRetorno := .F.							//Verifica se o arquivo foi apagado
	
	//Apaga o arquivo de controle
	lRetorno := ::oGlobal:GravarArq():TransTef(::cData, ::cHora):Apagar()
    
    //Grava log
	If lRetorno
		::oGlobal:GravarArq():Log():Tef():_Gravar("Arquivo de controle PBM apagado com sucesso (" + "Data: " + ::cData + " - Hora: " + ::cHora + ")")
	Else
		::oGlobal:GravarArq():Log():Tef():_Gravar("Arquivo de controle PBM nao foi apagado (" + "Data: " + ::cData + " - Hora: " + ::cHora + ")")	
	EndIf 

Return Nil