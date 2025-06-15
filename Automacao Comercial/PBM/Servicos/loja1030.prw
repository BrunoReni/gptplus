#INCLUDE "MSOBJECT.CH"
  
User Function LOJA1030 ; Return  // "dummy" function - Internal Use

/*
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������ͻ��
���Classe    �LJCServicoXOperadora�Autor  �Vendas Clientes     � Data �  04/09/07   ���
�����������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em tratar os dados retornados no servicoX 		    ���
���			 �operadora. 	 													    ���
�����������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		    ���
�����������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
*/
Class LJCServicoXOperadora From LJAAbstrataServico

	Data oOperadors									//Objeto que ira armazenar os dados das operadoras
	
	Method ServicoXOp(cTipo)						//Metodo construtor
	Method TratarServ(cDados)                  		//Metodo que ira tratar os dados do servico
	Method BuscarOper()								//Metodo que ira retornar os dados da operadora    

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ServicoXOp�Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCServicoXOperadora.                  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTipo) - Tipo do servico.		   				  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ServicoXOp(cTipo) Class LJCServicoXOperadora

	::cTpServ 		:= cTipo
	::oOperadors 	:= Nil

Return Self 

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
Method TratarServ(cDados, nPosicao) Class LJCServicoXOperadora

	Local oOperadora   	:= Nil				//Objeto que ira armazenar cada operadora
	Local nPos	 		:= 1                //Posicao inicial da string cDados
	Local nQtdeOpera 	:= 0                //Quantidade da operadoras retornadas
	Local nCount 		:= 0				//Variavel de controle contador
	
	::oOperadors := LJCOperadoras():Operadoras()
	
	::cTpDados := SubStr(cDados, nPos, 1)
	nPos ++

	nQtdeOpera := Val(SubStr(cDados, nPos, 2))
	nPos += 2
	
	For nCount := 1 To nQtdeOpera
	
		oOperadora := LJCOperadora():Operadora()
		
		oOperadora:cCodOperad := SubStr(cDados, nPos, 3)
		nPos += 3		
		
		oOperadora:cNomeOpera := AllTrim(SubStr(cDados, nPos, 20))
		nPos += 20
		
		::oOperadors:Add(oOperadora:cCodOperad, oOperadora)
								
	Next
				
return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �BuscarOper�Autor  �Vendas Clientes     � Data �  04/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo que ira retornar as operadoras.			          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method BuscarOper() Class LJCServicoXOperadora
Return ::oOperadors 