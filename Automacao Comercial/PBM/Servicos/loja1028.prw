#INCLUDE "MSOBJECT.CH"
  
User Function LOJA1028 ; Return  // "dummy" function - Internal Use

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͻ��
���Classe    �LJAAbstrataServico�Autor  �Vendas Clientes     � Data �  04/09/07   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Classe abstrata que possui as propriedades e metodos comuns dos	  ���
���          �servicos.													  		  ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJAAbstrataServico

	Data nTamServ							//Tamanho do servico
	Data cCodServ							//Codigo do servico
	Data nTamDados							//Tamanho dos dados
	Data cTpDados                           //Tipo de dados
	Data cTpServ                            //Tipo do servico
	
	Method TratarServ(cDados)               //Metodo abstrato que ira tratar os dados do servico
	
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TratarServ�Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo que ira tratar os dados retornados no servico, este  ���
���			 �metodo tem que ser escrito em todas as classes de servico	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cDados)   - String com os dados do servico.	  ���
���Parametros�ExpN1 (2 - nPosicao) - Posicao da string dos dados.		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TratarServ(cDados, nPosicao) Class LJAAbstrataServico
Return