#INCLUDE "MSOBJECT.CH"
  
User Function LOJA1034 ; Return  			// "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCServicoI      �Autor  �Vendas Clientes     � Data �  04/09/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em tratar os dados retornados no servico I. 	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCServicoI From LJAAbstrataServico

	Data aComprov								//Array com o comprovante
	Data lNovaRot								//Nova rotina
	
	Method ServicoI(cTipo)						//Metodo Construtor
	Method TratarServ(cDados)					//Metodo que ira tratar os dados do servico    

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ServicoI  �Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCServicoI.                           ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTipo) - Tipo do servico.		   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ServicoI(cTipo, lNovaRot) Class LJCServicoI

	Default lNovaRot := .F. //Nova rotina - processa o retorno da rotina

	::cTpServ 	:= cTipo
    ::aComprov 	:= {}
    ::lNovaRot 	:= lNovaRot

return Self 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TratarServ�Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo que ira tratar os dados retornados no servico.       ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cDados)   - String com os dados do servico.	  ���
���			 �ExpN1 (2 - nPosicao) - Posicao da string dos dados.		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TratarServ(cDados, nPosicao, nRedeDest) Class LJCServicoI
	
    Local nTamanho							//Tamanho do servico
    Local cServEspec                        //Dados do servico
	
	If !::lNovaRot //Tratamento antigo , estava dando erro na e-pharma
	Do While Substr(cDados, nPosicao + 1, 1) == ::cTpServ 
		
		nTamanho := Asc(SubStr(cDados, nPosicao ,1))
		cServEspec := SubStr(cDados, nPosicao + 2 , nTamanho - 1)
		nPosicao := nPosicao + nTamanho + 1
		
		AADD(::aComprov, AllTrim(cServEspec))		
	
	EndDo
	
	
	Else //Novo tratamento , processa todas as linhas do comprovante
	
		Do While Substr(cDados, nPosicao + 1, 1) == ::cTpServ 
			
			nTamanho := Asc(SubStr(cDados, nPosicao ,1))
			cServEspec := SubStr(cDados, nPosicao + 2 , nTamanho - 1)
			nPosicao := nPosicao + nTamanho + 1
			
			AADD(::aComprov, AllTrim(cServEspec))		
		
		EndDo
	
	EndIf
	nPosicao --
return