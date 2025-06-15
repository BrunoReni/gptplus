#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJA1328 ; Return 	 // "dummy" function - Internal Use

/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������ͻ��
���Classe    �LJCFrmMensagemEcf  �Autor  �Vendas Clientes     � Data �  04/08/08   ���
����������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em exibir a mensagem retornada pelo ecf.		   ���
����������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		   ���
����������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
*/
Class LJCFrmMensagemEcf
		
	Data cFabricante                        					//Fabricante do ECF
	Data cModelo												//Modelo do ECF
	Data cVersao												//Versao do firmware
	Data cMensagem												//Mensagem do ECF
	
	//Metodos externos
	Method New(cFabricante, cModelo, cVersao, cMensagem)		//Metodo construtor
	
	//Metodo interno	
	Method Show()   					   						//Metodo responsavel em exibir a tela

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  12/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCFrmMensagemEcf.		      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cFabricante) - Fabricante.					      ���
���			 �ExpC2 (2 - cModelo) - Modelo.							      ���
���			 �ExpC3 (3 - cVersao) - Versao firmware.				      ���
���			 �ExpC4 (4 - cMensagem) - Mensagem.				    		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(cFabricante, cModelo, cVersao, cMensagem) Class LJCFrmMensagemEcf

	::cFabricante 	:= AllTrim(cFabricante)
	::cModelo		:= AllTrim(cModelo)
	::cVersao		:= AllTrim(cVersao)
	::cMensagem 	:= AllTrim(cMensagem)
	
	//Exibe a mensagem
	::Show()
	
Return Self

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Show      �Autor  �Vendas Clientes     � Data �  12/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por exibir uma tela para capturar uma    ���
���			 �informacao.                                     			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Show() Class LJCFrmMensagemEcf

	Local oDlg		:= Nil								//Objeto dialog
	local oFontText	:= Nil								//Fonte do fabricante, modelo e versao do ecf
	Local oFntMsg	:= Nil								//Fonte da mensagem
	Local cEcf		:= ""							//Dados do ECF	
	
	cEcf := ::cFabricante + " " + ::cModelo + " - Vers�o: " + ::cVersao
	
	//Define as fontes
	DEFINE FONT oFontText NAME "Courier New" SIZE 09,20 BOLD
	DEFINE FONT oFntMsg NAME "Arial" SIZE 10, 20 
	
	DEFINE MSDIALOG oDlg TITLE "Mensagem Impressora Fiscal" FROM 323,412 TO 560,798 PIXEL STYLE DS_MODALFRAME STATUS
			
		@ 005, 005 TO 30, 189 LABEL "" PIXEL OF oDlg  
		@ 013, 007 SAY cEcf PIXEL SIZE 180,015 FONT oFontText CENTERED
				
		oDlg:lEscClose := .F.
				                                                    	
		@ 035,005 GET oMsgDet VAR ::cMensagem FONT oFntMsg MEMO SIZE 184,65 PIXEL WHEN .F.
	
		DEFINE SBUTTON FROM 105, 164 TYPE 1 ENABLE OF oDlg ACTION (oDlg:End())
	
	ACTIVATE MSDIALOG oDlg CENTERED    
	
Return Nil