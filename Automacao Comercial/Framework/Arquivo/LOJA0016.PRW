#INCLUDE "MSOBJECT.CH" 

User Function LOJA0016 ; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCDadosArquivo  �Autor  �Vendas Clientes     � Data �  17/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em guardar informacoes sobre o arquivo.         ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCDadosArquivo From LJCArquivo
			
	Data nTamanho              						//Tamanho do arquivo
	Data dDataMod              						//Data de modificacao do arquivo
	Data cHoraMod              						//Hora de modificacao do arquivo
	Data cAtribut									//Atributo do arquivo	
	
	Method DadosArq(cPath, cNome)					//Metodo construtor
		
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �DadosArq  �Autor  �Vendas Clientes     � Data �  17/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCDadosArquivo.       		          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cPath) - O Path do arquivo.				      ���
���			 �ExpC2 (2 - cNome) - O nome do arquivo.				      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method DadosArq(cPath, cNome) Class LJCDadosArquivo
	
	//Executa o metodo construtor da classe pai
	::Arquivo(cPath, cNome)
	
	::nTamanho	:= ""
	::dDataMod	:= Nil
	::cHoraMod	:= ""
	::cAtribut	:= ""
	
Return Self