#INCLUDE "MSOBJECT.CH"

Function LOJA1321 ; Return 	 // "dummy" function - Internal Use 

/*
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������ͻ��
���Classe    �LJCFlagsFiscaisEcf  �Autor  �Vendas Clientes     � Data �  05/05/08   ���
�����������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em armazenar os dados das flags fiscais do ecf            ���
�����������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		    ���
�����������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
*/
Class LJCFlagsFiscaisEcf
   	
   	Data lCFAberto											//Cupom fiscal aberto
   	Data lCVAberto											//Cupom vinculado aberto
   	Data lRGAberto											//Relatorio gerencial aberto
   	Data lNFAberto											//Cupom nao fiscal aberto
   	Data lPapelAcab											//Pouco papel   	
   	Data lFimPapel											//Fim de papel   	   	
   	Data lTampAbert											//Tampa aberta
   	Data lEcfOff											//Impressora desligada ou desconectada   	   	   	   	   	
   	Data lGavAberta											//Gaveta aberta
   	Data lIntervenc											//Impressora em modo de intervencao
   	Data lDiaFechad											//ReducaoZ ja emitida no dia
	Data lRedZPend											//ReducaoZ pendente
	Data lCFTot												//Cupom fiscal totalizado
	Data lCFPagto											//Cupom fiscal em fase de pagamento
	Data lCFItem											//Cupom fiscal em fase de venda de item
	Data lInicioDia											//Se o dia ja foi iniciado
	   	   			
	Method New()											//Metodo construtor
	
EndClass

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �New   	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCFlagsFiscaisEcf. 		    	     ���
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
Method New() Class LJCFlagsFiscaisEcf

	Self:lCFAberto	:= .F.
   	Self:lCVAberto	:= .F.
   	Self:lRGAberto	:= .F.
   	Self:lNFAberto	:= .F.
   	Self:lPapelAcab	:= .F.
   	Self:lFimPapel	:= .F.
   	Self:lTampAbert	:= .F.
   	Self:lEcfOff	:= .F.
   	Self:lGavAberta	:= .F.
   	Self:lIntervenc	:= .F.
   	Self:lDiaFechad	:= .F.
	Self:lRedZPend	:= .F.
	Self:lCFTot		:= .F.
	Self:lCFPagto	:= .F.
	Self:lCFItem	:= .F.
	Self:lInicioDia	:= .F.
	
Return Self