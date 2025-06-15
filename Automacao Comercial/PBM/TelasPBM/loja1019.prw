#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
  
User Function LOJA1019 ; Return  // "dummy" function - Internal Use

/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������ͻ��
���Classe    �LJCTelaCaptura     �Autor  �Vendas Clientes     � Data �  12/09/07   ���
����������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em exibir um text para capturar uma informacao.   ���
����������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		   ���
����������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
*/
Class LJCTelaCaptura
		
	Data cTipoCampo                         //Tipo do campo (N-NUMERICO , A-ALFANUMERICO, F-FLAG(S/N))
	Data nMinimo							//Tamanho minimo do campo (de 1 a 50)
	Data nMaximo							//Tamanho maximo do campo (de 1 a 50)
	Data cCampo								//Descricao do campo
	Data oRetSelect							//Variavel com o retorno do conteudo informado, esta definida como objeto
											//porque pode retornar tanto um numero como um caracter.
	Data cTitulo							//Descricao do titulo da tela
	Data lCancelado							//Verifica se a tela foi cancelada
	
	//Metodos externos
	Method Show()   						//Metodo responsavel em exibir a tela
	Method TelCap()		  					//Metodo construtor
	
	//Metodos internos
	Method PrepVarTel(cPicture)				//Metodo que ira formatar as variaveis da tela
	Method ValidDados()						//Metodo que ira validar o dado digitado

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �TelCap    �Autor  �Vendas Clientes     � Data �  12/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCTelaCaptura. 			      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cTitulo) - Titulo da tela.				          ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method TelCap(cTitulo) Class LJCTelaCaptura

	::cTipoCampo	:= "" 
	::nMinimo		:= 0
	::nMaximo		:= 0
	::cCampo		:= 0
	::oRetSelect 	:= Nil
	::cTitulo 		:= cTitulo
	::lCancelado	:= .F.
	
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
Method Show() Class LJCTelaCaptura

    Local oDlg		:= Nil								//Objeto dialog
	Local cPicture  := ""								//A picture que sera formatada o text
		
	//Prepara as variaveis da tela
	::PrepVarTel(@cPicture)
    	
	//Define a fonte do text
	DEFINE FONT oFontText NAME "Courier New" SIZE 09,20
	
	DEFINE MSDIALOG oDlg TITLE ::cTitulo FROM 323,412 TO 420,738 PIXEL STYLE DS_MODALFRAME STATUS
	
		@ 005, 004 TO 30, 160 LABEL ::cCampo PIXEL OF oDlg
		@ 013,007 MSGET ::oRetSelect SIZE 150,10 FONT oFontText OF oDlg PIXEL PICTURE cPicture VALID ::ValidDados()//PICTURE "@! 999999" //VALID cRet $ "SN" //WHEN .F.
		
		oDlg:lEscClose := .F.
	
		DEFINE SBUTTON FROM 35, 104 TYPE 1 ENABLE OF oDlg ACTION (oDlg:End())
		DEFINE SBUTTON FROM 35, 134 TYPE 2 ENABLE OF oDlg ACTION (::oRetSelect := "", ::lCancelado := .T., oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �PrepVarTel�Autor  �Vendas Clientes     � Data �  12/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em preparar as variaveis de controle da  ���
���			 �tela(PICTURE, TIPO DA VARIAVEL E TAMANHO).       			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method PrepVarTel(cPicture) Class LJCTelaCaptura

	If ::cTipoCampo	== "N"
		//Campo numero
		//Obs: Campo caracter que so pode ser digitado numeros
		::oRetSelect 	:= Space(::nMaximo)
		cPicture		:= "@! " + 	Repl("9", ::nMaximo)
	
	ElseIf ::cTipoCampo	== "F"
    	//Campo flag (S/N)	
		::oRetSelect 	:= Space(1)
		::cCampo		+= " (S/N)"
		cPicture		:= "@!"
		
	ElseIf ::cTipoCampo	== "A"
		//Campo alfanumerico	
		::oRetSelect 	:= Space(::nMaximo)
		cPicture		:= "@!"	

	EndIf 
	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ValidDados�Autor  �Vendas Clientes     � Data �  12/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo que ira validar o dado digitado.       			  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ValidDados() Class LJCTelaCaptura

	Local lRetorno := .F.					//Variavel de retorno do metodo
		
	If ::cTipoCampo == "A" .OR. ::cTipoCampo	== "N"
		//Campo alfanumerico
		If Len(AllTrim(::oRetSelect)) >= ::nMinimo
			lRetorno := .T. 
		EndIf
			
	ElseIf ::cTipoCampo	== "F"
    	//Campo flag (S/N)	
		If ::oRetSelect $ "SN"
			lRetorno := .T. 
		EndIf
	
	EndIf

Return lRetorno