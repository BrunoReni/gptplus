#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
  
User Function LOJA1018 ; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCTelaSelecao   �Autor  �Vendas Clientes     � Data �  11/09/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em exibir uma combo para selecao.      		 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCTelaSelecao
	
	Data aDadosTela										//Array com os dados que serao exibidos na combo
	Data cRetSelect										//Variavel com o retorno do conteudo selecionado
	Data cTitulo										//Descricao do titulo da tela
	Data cLabel											//Descricao do Label
	Data lCancelado										//Verifica se a tela foi cancelada
	
	//Metodos externos
	Method Show()   									//Metodo responsavel em exibir a tela
	Method TelaSelec(aDados, cTitulo, cLabel)			//Metodo construtor

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TelaSelec �Autor  �Vendas Clientes     � Data �  11/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCTelaSelecao.    			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�EXPA1 (1 - aDados)  - Array a ser exibido na combo.         ���
���          �EXPC1 (2 - cTitulo) - Titulo da tela.                       ���
���          �EXPC2 (3 - cLabel)  - Texto do label.                       ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TelaSelec(aDados, cTitulo, cLabel) Class LJCTelaSelecao

	::aDadosTela 	:= aDados
	::cRetSelect 	:= ""
	::cTitulo 		:= cTitulo
	::cLabel		:= cLabel
	::lCancelado    := .F.
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Show      �Autor  �Vendas Clientes     � Data �  11/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por exibir uma tela para selecao da      ���
���			 �informacao.                                     			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Show() Class LJCTelaSelecao

    Local oDlg		:= Nil											//Objeto dialog
	
	DEFINE MSDIALOG oDlg TITLE ::cTitulo FROM 323,412 TO 495,648 PIXEL STYLE DS_MODALFRAME STATUS
	
		@ 005, 004 TO 70, 117 LABEL ::cLabel PIXEL OF oDlg
		@ 028, 027 ComboBox ::cRetSelect Items ::aDadosTela Size 072, 010 PIXEL OF oDlg
		
		oDlg:lEscClose := .F.
	
		DEFINE SBUTTON FROM 73, 59 TYPE 1 ENABLE OF oDlg ACTION (oDlg:End())
		DEFINE SBUTTON FROM 73, 89 TYPE 2 ENABLE OF oDlg ACTION (::cRetSelect := "", ::lCancelado := .T., oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED
	
Return Nil