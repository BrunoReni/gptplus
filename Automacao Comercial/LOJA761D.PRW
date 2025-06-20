#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJA761D; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCRetPagMn      �Autor  �Vendas Clientes     � Data �  15/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em manipular um arquivo.                   	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCRetPagMn From LJCColecao
	
	Method New()

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCRetPagMn				              ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�	  			                                              ���
���          �          			                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New( ) Class LJCRetPagMn
	_Super:New()
Return Self


/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCRePaCon       �Autor  �Vendas Clientes     � Data �  15/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em manipular um arquivo.                   	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCRePaCon

	Data nSeq
	Data cTipo
	Data oPags
	Data nCres
	Data nValorPar
	Data cFm
	Data nTotPrz
    Data nQtdPac
    Data nTotVlFin
    Data nVlrEnt
	Data nValNcc
	Data nVParDesc
	Data nDif
	
	Method New(nSeq, cTipo, oPags, nCres, nValorPar, cFm, nTotPrz, nQtdPac, nTotVlFin, nVlrEnt,nValNcc,nVParDesc, nDif)

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCRePaCon. 				              ���
�������������������������������������������������������������������������͹��
���Parametros�nExp1 - SequenciaTipo          							  ���
���          �cExp2 - Tipo        				  						  ��� 
���          �oExp3 - Pagamentos			  						  	  ��� 
���          �nExp4 - Valor do Acrescima			  					  ��� 
���          �nExp5 - Valor da Parcela 						  			  ��� 
���          �cExp6 - Forma de pagamento 						  		  ��� 
���          �nExp7 - Total a prqzo  			  						  ��� 
���          �nExp8 - QUatidade de parcela						  		  ��� 
���          �nExp9 - Valor financiados	  							  	  ��� 
���          �nExp10 - Valor da entrada		  							  ��� 
���          �nExp11 - Valor da ncc            							  ��� 
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Method New(	nSeq		, cTipo		, oPags		, nCres		, ;
			nValorPar	, cFm		, nTotPrz	, nQtdPac, ;
			nTotVlFin	, nVlrEnt	, nValNcc	, nVParDesc	,nDif  ) Class LJCRePaCon
	
	Default nSeq		:= 0
	Default cTipo 		:= "PAR"
	Default oPags		:= Nil
	Default nCres		:= 0
	Default nValorPar 	:= 0
	Default cFm			:= ""
	Default nTotPrz		:= 0
	Default nQtdPac		:= 0
	Default nVlrEnt		:= 0
	Default nValNcc		:= 0
	Default nVParDesc		:= 0
	Default nDif		:= 0
	
	Self:nSeq 		:= nSeq
	Self:cTipo 		:= cTipo
	Self:oPags		:= oPags
	Self:nCres		:= nCres
	Self:nValorPar 	:= nValorPar
	Self:cFm		:= cFm
	Self:nTotPrz	:= nTotPrz
	Self:nQtdPac	:= nQtdPac
	Self:nTotVlFin	:= nTotVlFin
	Self:nVlrEnt	:= nVlrEnt
	Self:nValNcc	:= nValNcc
	Self:nVParDesc	:= nVParDesc
	Self:nDif		:= nDif
Return()
