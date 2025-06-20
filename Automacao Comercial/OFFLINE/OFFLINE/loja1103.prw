#INCLUDE "PROTHEUS.CH"                            	
Function LOJA1103()
Return Nil

/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Classe    �LjACadastro�Autor �Vendas Clientes     � Data �  21/02/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Classe para criacao de Cadastros a partir da rotina        ���
���          � AxCadastro.                                                ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Class LjACadastro
	
	Data cAlias												//Tabela
	Data cTitle												//Titulo
	Data cValDel											//Validacao Exclusao
	Data cValOK												//Validacao Botao OK
	Data bValFim    

	Method New(cAlias, cTitle, cValDel, cValOK, ;
			   bValFim)										//Construtor
	Method Show()											//Exibe o Cadastro
	Method ValExc()											//Validacao Exclusao
	Method ValOK()											//Validacao Botao OK
	Method ProcessOff(cTabela, cChave, nIndice, cTipo, ;
					  cProcesso)						   	//Integra o processo offline
	Method ValFim()

EndClass

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Metodo�New            �Autor  �Vendas Clientes  � Data � 25/02/08     ���
������������������������������������������������������������������������͹��
���Desc. � Instancia a Classe LjACadastro                                ���
������������������������������������������������������������������������͹��
���Param.� ExpC1 - Alias para montagem do Browse                         ���
���      � ExpC2 - Titulo do Cadastro                                    ���
���      � ExpC3 - Funcao para validacao da Exclusao                     ���
���      � ExpC4 - Funcao para validacao do botao OK                     ���
���      � ExpB1 - Bloco de fim do processo'''''''''                     ���
������������������������������������������������������������������������͹��
���Uso   � LjACadastro                                                   ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method New(cAlias, cTitle, cValDel, cValOK, ;
		   bValFim) Class LjACadastro
	
	Default	cAlias	:= ""		//Tabela
	Default	cTitle	:= ""		//Titulo
	Default cValDel	:= ".T."	//Validacao para Exclusao
	Default cValOK	:= ".T."	//Validacao botao OK

	::cAlias	:= cAlias
	::cTitle	:= cTitle
	::cValDel	:= cValDel
	::cValOK	:= cValOK
	::bValFim   := bValFim

Return Self

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Metodo� Show          �Autor  �Vendas Clientes  � Data � 25/02/08     ���
������������������������������������������������������������������������͹��
���Desc. � Exibe o Browse com as opcoes Incluir, Alterar e Excluir.      ���
���      �                                                               ���
������������������������������������������������������������������������͹��
���Uso   � LjACadastro                                                   ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method Show() Class LjACadastro

	AxCadastro(::cAlias	, ::cTitle	, ::cValDel	, ::cValOK	, ;
	           NIL		, NIL		, NIL		, NIL		, ; 
	           ::bValFim)

Return Nil

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Metodo� ValExc        �Autor  �Vendas Clientes  � Data � 25/02/08     ���
������������������������������������������������������������������������͹��
���Desc. � Validacao da Exclusao.                                        ���
������������������������������������������������������������������������͹��
���Ret.  � ExpL1 - Permite ou nao a exclusao do Registro                 ���
������������������������������������������������������������������������͹��
���Uso   � LjACadastro                                                   ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method ValExc() Class LjACadastro
Return .T.

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Metodo� ValOK         �Autor  �Vendas Clientes  � Data � 25/02/08     ���
������������������������������������������������������������������������͹��
���Desc. � Validacao do botao OK.                                        ���
������������������������������������������������������������������������͹��
���Ret.  � ExpL1 - Permite ou nao a confirmacao da Alteracao ou Inclusao ���
������������������������������������������������������������������������͹��
���Uso   � LjACadastro                                                   ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method ValOK() Class LjACadastro
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Inserir   �Autor  �Vendas Clientes     � Data �  13/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em integrar os cadastros ao processo offline.   ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTabela) - Nome da tabela. 					  ���
���			 �ExpC2 (2 - cChave)  - Dados da chave.						  ���
���			 �ExpN1 (3 - nIndice) - Codigo do indice.			          ���
���			 �ExpC3 (4 - cTipo)   - Tipo de integracao do dado.	          ���
���			 �ExpC4 (5 - cProcesso)  - Codigo do processo.  	          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ProcessOff(cTabela, cChave, nIndice, cTipo, ;
				  cProcesso) Class LjACadastro
	
	Local oProcessOff := Nil				//Objeto do tipo LJCProcessoOffLine
	
	//Estancia o objeto LJCProcessoOffLine
	oProcessOff := LJCProcessoOffLine():New(cProcesso)
	
	//Insere os dados do processo (registro da tabela)
	oProcessOff:Inserir(cTabela, cChave, nIndice, cTipo)	
	
	//Processa os dados 
	oProcessOff:Processar()
		
Return Nil

/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Metodo� ValFim        �Autor  �Vendas Clientes  � Data � 25/02/08     ���
������������������������������������������������������������������������͹��
���Desc. � Validacao do fim do processo.                                 ���
������������������������������������������������������������������������͹��
���Uso   � LjACadastro                                                   ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
Method ValFim() Class LjACadastro
Return Nil
