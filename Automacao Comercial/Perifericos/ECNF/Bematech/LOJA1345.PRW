#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFECF.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "DEFTOTAPI.CH"

//comandos padr�es segundo manual da impressora bematech para texto formatado
Static cBNegIni		:= Chr(27)+Chr(69)
Static cBNegFim		:= Chr(27)+Chr(70)
Static cBItaIni		:= Chr(27)+Chr(52)
Static cBItaFim		:= Chr(27)+Chr(53)
Static cBCondenIni	:= Chr(15)
Static cBCondenFim	:= Chr(18)
Static cBExpanIni	:= Chr(27)+Chr(87)+Chr(1)
Static cBExpanFim	:= Chr(27)+Chr(87)+Chr(0)
Static cBDuplaAIni	:= Chr(27)+Chr(100)+Chr(1)
Static cBDuplaAFim	:= Chr(27)+Chr(100)+Chr(0)
Static cBAlinRigth	:= Chr(27)+Chr(97)+Chr(2)
Static cBSubliIni	:= Chr(27)+Chr(45)+Chr(1)
Static cBSubliFim	:= Chr(27)+Chr(45)+Chr(0)
Static cBEnfatiIni	:= Chr(27)+Chr(69)
Static cBEnfatiFim	:= Chr(27)+Chr(70)
Static cBSubEscIni	:= Chr(27)+Chr(83)+Chr(1)
Static cBSobEscIni	:= Chr(27)+Chr(83)+Chr(0)
Static cBSubSobFim	:= Chr(27)+Chr(84)
Static cBNormal		:= CHR(27)+CHR(64)
Static cBCentralizado:=  CHR(27)+CHR(97)+Chr(1)
Static cBCorteTotal  :=  Chr(27) + CHR(119)
Static cBCorteParcial:=  CHR(27) + CHR(109)

Function LOJA1345 ; Return 	 // "dummy" function - Internal Use

/*����������������������������������������������������������������������������������
���Classe    �LJANfBematech    �Autor  �Vendas Clientes     � Data �  26/03/13   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe abstrata, possui as funcoes comuns para todos os ECF'S do   ���
���			 �modelo LJANfBematech											     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
����������������������������������������������������������������������������������*/
Class LJANfBematech From LJAEcnf

Data oFormasVen																//Formas da venda, objeto do tipo LJCFormasEcf

Method New(oTotvsApi)					//Metodo construtor
Method AbrirPorta(cPorta)				//Abre a porta serial para comunicacao com o ECF
Method FechaPorta()						//Fechar a porta serial	
Method ImpTextoNf(cTexto)				//Metodo para Impress�o de Texto comum
Method TrataTexto(cTexto)				//Metodo para Tratar o texto e enviar para as fun��es caso haja formata��o
Method TrataTags(cTexto)				//Metodo para tratamento das tags enviadas
Method ImpCodeBar(cTipo,cTexto)			//Metodo para Impress�o de C�digo de Barras
Method ImpBitMap(cArquivo)				//Metodo para impressao de imagem com extensao .bmp
Method SetModelImp(cModelo)				//Metodo para setar modelo de Impressora
Method CarregMsg()
Method VerPapel()						//Metodo para verificar se tem Papel na impressora
Method ImpTxtFmt(cTexto)				//Metodo para separar o texto de forma que seja usado no negritado, italico, etc. junto com qrcode e/ou bitmap
Method Imprimir(cTexto)					//Metodo para envio de texto 
Method AbrirGavet()
Method CortaPapel()
EndClass

/*����������������������������������������������������������������������������������
���Metodo    �New   	       �Autor  �Vendas Clientes     � Data �  26/03/13   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJANfBematech.   			    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
����������������������������������������������������������������������������������*/
Method New(oTotvsApi) Class LJANfBematech

	//Executa o metodo construtor da classe pai
	_Super:New(oTotvsApi)

	//Carrega as mensagens
	::CarregMsg()

Return Self

/*���������������������������������������������������������������������������
���Programa  �SetModelImp�Autor  �Vendas Clientes     � Data �  26/03/13  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura da porta serial.           ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�cModelo - Modelo de Impressora Utilizado					  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
�������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������*/
Method SetModelImp(cModelo) Class LJANfBematech

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	Local cCodMod	:= "0"

	If "MP4000" $ cModelo
		cCodMod := "5"
	ElseIf "MP4200" $ cModelo
		cCodMod := "7"
	EndIf    

	//Prepara os parametros de envio 
	oParams := ::PrepParam({BEMANF,"ConfiguraModeloImpressora",cCodMod}) 

	//Envia o comando
	cRetorno := ::EnviarCom(oParams)

	//Trata o retorno
	oRetorno := ::TratarRet(cRetorno)

Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �AbrirPorta�Autor  �Vendas Clientes     � Data �  26/03/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pela abertura da porta serial.           ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Numero da porta COM (nao utilizado)						  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method AbrirPorta(cPorta) Class LJANfBematech

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao

	oParams := ::PrepParam({BEMANF,"IniciaPorta",cPorta}) 
	cRetorno := ::EnviarCom(oParams)
	oRetorno := ::TratarRet(cRetorno)

Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �FecharPorta�Autor  �Vendas Clientes     � Data �  26/03/13  ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo fechamento da porta serial.         ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�Numero da porta COM 										  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto LJCRetornoEcf										  ���
���������������������������������������������������������������������������*/
Method FechaPorta(cPorta) Class LJANfBematech

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	//Local nX 		:= 0  			// teste

	//Prepara os parametros de envio
	oParams := ::PrepParam({BEMANF,"FechaPorta"}) 

	//Envia o comando
	cRetorno := ::EnviarCom(oParams)    

	//Trata o retorno
	oRetorno := ::TratarRet(cRetorno)

Return oRetorno

/*����������������������������������������������������������������������������������
���Metodo    �ImpTextoNf       �Autor  �Vendas Clientes     � Data �  26/03/13   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel pela impress�o do texto						    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja 			                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�cTexto - Texto que ser� enviado para impress�o		   	         ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
����������������������������������������������������������������������������������*/
Method ImpTextoNf(cTexto) Class LJANfBematech
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao	

	Default cTexto	:= ""

	If !Empty(AllTrim(cTexto))
		oRetorno	:= Nil
		oRetorno	:= ::TrataTexto(cTexto)
	EndIf

Return oRetorno

/*����������������������������������������������������������������������������������
���Metodo    �TrataTexto       �Autor  �Vendas Clientes     � Data �  12/07/13   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Trata as tags enviadas por cTexto e enviar para as respectivas   	 ���
���			 �fun��es da Bematech												 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja 			                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�cTexto - Texto que ser� enviado para impress�o		   	         ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
����������������������������������������������������������������������������������*/
Method TrataTexto(cTexto) Class LJANfBematech

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao	
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local cTextoAux	:= ""			//Auxiliar para cTexto
	Local lCorte	:= .F.			//Define se foi enviado comando de corte
	Local cEOL		:= CHR(10)+CHR(13)
	Local aRet		:= {}

	Default cTexto := ""

	cTextoAux	:= cTexto

	If cTextoAux == TAG_GUIL_INI+TAG_GUIL_FIM //Tag para Corte de papel
		oRetorno	:= ::VerPapel()

		If oRetorno:cAcao == OK
			oRetorno := NIL
			//Manda um comando para avan�ar o papel e impedir que seja um corte muito rente
			oParams	:= ::PrepParam({ BEMANF,"BematechTX", cEOL + cEOL })
			cRetorno:= ::EnviarCom(oParams)
			oRetorno:= ::TratarRet(cRetorno)

			oParams	:= ::PrepParam({ BEMANF,"AcionaGuilhotina", "0" }) //Aciona o corte total
			cRetorno:= ::EnviarCom(oParams)
			oRetorno:= ::TratarRet(cRetorno)
		EndIf

		lCorte := .T.
	EndIf

	If !lCorte
		oRetorno	:= ::VerPapel()    
		If oRetorno:cAcao == OK

			oRetorno := NIL
			cTextoAux := ::TrataTags(cTextoAux)

			//Caso haja formata��o conjugada, ou seja, que contenha texto formatado + qrcode 
			//e/ou + bitmap tratar para enviar certo a impressora
			aRet := ::ImpTxtFmt(@cTextoAux)
			If aRet[1]
				oRetorno := aRet[2]
			Else
				oRetorno := ::Imprimir(cTextoAux)
			EndIf
		EndIf
	EndIf

Return oRetorno

/*����������������������������������������������������������������������������������
���Metodo    �ImpCodeBar       �Autor  �Vendas Clientes     � Data �  26/03/13   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Faz a impress�o dos c�digos de barra e qrcode				    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja 			                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�cTipo - Tipo do C�digo de Barras, baseado nas tags do AUTODEF.CH	 ���
���			 |cTexto - Texto que ser� convertido em Cod de Barras				 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
����������������������������������������������������������������������������������*/
Method ImpCodeBar(cTipo,cTexto) Class LJANfBematech 
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao	
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local cTextoAux := ""
	Local cComando	:= ""
	Local cAux		:= ""
	Local lConfigDef:= .T.
	Local aRet		:= {}
	Local nI		:= 0
	Local lUseSat	:= IIF(ExistFunc("LjUseSat"),LjUseSat(),.F.)  //Utiliza SAT
	Local lEmitNfce	:= LjEmitNFCe()
	Local aParam	:= Array(2)
	Local cDocSaida	:= ""

	Default cTexto	:= ""
	Default cTipo	:= ""

	aRet := IsCodeBar(cTipo,@cTexto) 	//Retorno = {lRet,cTipo,lConfigDef,cComando,cTxtAux}

	For nI := 1 to Len(aRet)	

		oRetorno := ::VerPapel()

		If aRet[nI][1] .AND. oRetorno:cAcao == OK

			//{lRet,cTipo,lConfigDef,cComando,cTxtAux}
			cTipo		:= aRet[nI][2]
			lConfigDef	:= aRet[nI][3]
			cComando	:= aRet[nI][4]
			cTextoAux	:= aRet[nI][5]
			oRetorno	:= Nil	

			//Configura o c�digo de barras, conforme configura��o padr�o
			If lUseSat
				oParams	:= ::PrepParam({BEMANF,"ConfiguraCodigoBarras", '90','0','0','0','0'})
			Else
				oParams	:= ::PrepParam({BEMANF,"ConfiguraCodigoBarras", '162','1','2','0','0'})	
			EndIf
			cRetorno:= ::EnviarCom(oParams)
			oRetorno:= ::TratarRet(cRetorno)

			If !(oRetorno == NIL) .AND. (oRetorno:cAcao == OK)
				If	lConfigDef
					oParams	:= ::PrepParam({BEMANF,cComando,cTextoAux})
					cRetorno:= ::EnviarCom(oParams)
					oRetorno:= ::TratarRet(cRetorno)
				Else
					If cTipo == TAG_PDF_INI
						oParams	:= ::PrepParam({BEMANF,cComando,'4','3','2','0',cTextoAux})
						cRetorno:= ::EnviarCom(oParams)
						oRetorno:= ::TratarRet(cRetorno)

					ElseIf cTipo == TAG_QRCODE_INI
						/*
						A SIGALOJA.DLL contem a mesma instru��o e caso
						seja alterado alguma informa��o aqui, deve-se
						alterar o fonte da DLL.
						Para manter a compatibilidade das altera��es
						*/
						If ExistFunc("INFTamQrCd")

							If lUseSat
								cDocSaida := "SAT"
							ElseIf lEmitNfce
								cDocSaida := "NFCE"
							EndIf

							aParam[1] := "TOTVSAPI"
							aParam[2] := Len(cTextoAux)
							INFTamQrCd("BEMATECH",cDocSaida,@aParam)
						Else
							aParam := {}
							aParam := Array(5)
							If lUseSat					 		
								aParam[2] := '4'					 		
								aParam[4] := '20'
							Else
								aParam[2] := '6'					 		
								aParam[4] := '1'
							EndIf
							aParam[1] := '1'
							aParam[3] := '0'
							aParam[5] := '1'
						EndIf

						If !lUseSat
							cAux 	:= Chr(27) + Chr(97) + Chr(1)      // c�digo da centraliza��o
							oParams	:= ::PrepParam({BEMANF,'ComandoTX',cAux})
							cRetorno:= ::EnviarCom(oParams)
							oRetorno:= ::TratarRet(cRetorno)
						EndIf

						oParams	:= ::PrepParam({BEMANF,cComando, aParam[1],aParam[2],aParam[3],aParam[4],aParam[5],cTextoAux})
						cRetorno:= ::EnviarCom(oParams)
						oRetorno:= ::TratarRet(cRetorno)
					ElseIf cTipo == TAG_ITF
						oParams	:= ::PrepParam({BEMANF,cComando,cTextoAux})
						cRetorno:= ::EnviarCom(oParams)
						oRetorno:= ::TratarRet(cRetorno)					


					EndIf
				EndIf
			EndIf
		EndIf
	Next nI

Return oRetorno

/*����������������������������������������������������������������������������������
���Metodo    �ImpBitMap        �Autor  �Vendas Clientes     � Data �  17/07/13   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel pela impress�o da imagem .BMP					    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja 			                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�cArquivo - caminho e nome do arquivo .BMP que ser� impresso 		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
����������������������������������������������������������������������������������*/
Method ImpBitMap(cArquivo) Class LJANfBematech

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao

	Default cArquivo	:= ""

	oRetorno	:= ::VerPapel()

	If oRetorno:cAcao == OK
		oRetorno := NIL

		//cArquivo : caminho com nome do arquivo com extens�o .bmp / "0" : refere-se a orienta��o da imagem a ser impressa, neste caso retrato
		oParams		:= ::PrepParam({BEMANF,"ImprimeBitmap", cArquivo , "0"}) 		
		cRetorno 	:= ::EnviarCom(oParams)
		oRetorno	:= ::TratarRet(cRetorno)
	EndIf

Return oRetorno

/*���������������������������������������������������������������������������
���Programa  �CarregMsg �Autor  �Vendas Clientes     � Data �  26/03/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pelo carregamento das mensagens de    	  ���
���          �resposta possiveis da impressora.			  		  	  	  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�nenhum													  ���
�������������������������������������������������������������������������͹��
���Retorno   �nenhum													  ���
���������������������������������������������������������������������������*/
Method CarregMsg() Class LJANfBematech
	::AdicMsgECF("0", "Problemas ao abrir porta de comunicacao", ERRO)
	::AdicMsgECF("1", "Resultado sem erro", OK)
	::AdicMsgECF("2", "Impressora sem papel", ERRO)
	::AdicMsgECF("3","Erro desconhecido",ERRO)
	::AdicMsgECF("-1", "Erro de execucao na funcao", ERRO)
	::AdicMsgECF("-2", "Parametro Invalido", ERRO)
	::AdicMsgECF("-3", "Erro na leitura do arquivo ou arquivo invalido", ERRO)
Return Nil

/*���������������������������������������������������������������������������
���Programa  �TrataTags �Autor  �Vendas Clientes     � Data �  17/06/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �M�todo responsavel pelo tratamento das tags enviadas        ���
���          �altera para as tags que a bematech interpreta				  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�cTexto - Texto com conteudo para impress�o 			   	  ���
�������������������������������������������������������������������������͹��
���Retorno   �cMsg									  					  ���
���������������������������������������������������������������������������*/
Method TrataTags( cTexto ) Class LJANfBematech
	Local cMsg	:= ""

	DEFAULT cTexto := ""

	cMsg := cTexto

	While At(TAG_NORMAL_INI, cMsg) > 0
		cMsg := RemoveChar(cMsg,TAG_NORMAL_INI,cBNormal)
		cMsg := RemoveChar(cMsg,TAG_NORMAL_FIM,cBNormal)
	EndDo

	while At(TAG_NEGRITO_INI, cMsg) > 0
		cMsg := RemoveChar(cMsg,TAG_NEGRITO_INI, cBNegIni)
		cMsg := RemoveChar(cMsg,TAG_NEGRITO_FIM, cBNegFim)
	enddo

	while At(TAG_EXPAN_INI,cMsg) > 0
		cMsg := RemoveChar(cMsg,TAG_EXPAN_INI, cBExpanIni)
		cMsg := RemoveChar(cMsg,TAG_EXPAN_FIM, cBExpanFim)
	enddo

	While At(TAG_ITALICO_INI,cMsg) > 0
		cMsg := RemoveChar(cMsg,TAG_ITALICO_INI, cBItaIni)
		cMsg := RemoveChar(cMsg,TAG_ITALICO_FIM, cBItaFim)
	enddo

	while At(TAG_CONDEN_INI,cMsg) > 0
		cMsg := RemoveChar(cMsg,TAG_CONDEN_INI, cBCondenIni)
		cMsg := RemoveChar(cMsg,TAG_CONDEN_FIM, cBCondenFim)
	enddo

	//A Tag TAG_CONDEN_FIM n�o estava sendo removida por inteiro
	While At(TAG_CONDEN_FIM,cMsg) > 0
		cMsg := RemoveChar(cMsg,TAG_CONDEN_FIM,cBCondenFim)
	EndDo

	While At(TAG_ELITE_INI,cMsg) > 0
		cMsg := RemoveChar(cMsg,TAG_ELITE_INI, cBDuplaAIni)
		cMsg := RemoveChar(cMsg,TAG_ELITE_FIM, cBDuplaAFim)
	enddo

	While At(TAG_SUBLI_INI,cMsg) > 0
		cMsg := RemoveChar(cMsg,TAG_SUBLI_INI, cBSubliIni)
		cMsg := RemoveChar(cMsg,TAG_SUBLI_FIM, cBSubliFim)
	endDo

	While At(TAG_TXTEXGG_INI,cMsg) > 0
		cMsg := RemoveChar(cMsg,TAG_TXTEXGG_INI, cBEnfatiIni)
		cMsg := RemoveChar(cMsg,TAG_TXTEXGG_FIM, cBEnfatiFim)
	EndDo

	While At(TAG_CENTER_INI,cMsg) > 0
		cMsg := RemoveChar(cMsg,TAG_CENTER_INI, cBCentralizado)
		cMsg := RemoveChar(cMsg,TAG_CENTER_FIM, cBNormal)
	EndDo

	While At(TAG_GUIL_INI,cMsg) > 0
		cMsg := RemoveChar(cMsg,TAG_GUIL_INI, cBCorteTotal)
		cMsg := RemoveChar(cMsg,TAG_GUIL_FIM, "")
	EndDo

	//Caso o qrcode/bitmap esteja inserido no meio do texto deve 
	//tratar para imprimir separadamente por isso deve proteger os comandos
	cMsg := AltCodeBar("B",cMsg)

	//Efetua a remo��o das tags "desconhecidas" pela bematech
	cMsg := RemoveTags( cMsg )

Return cMsg

/*����������������������������������������������������������������������������������
���Metodo    �VerPapel         �Autor  �Vendas Clientes     � Data �  16/07/2013 ���
��������������������������������������������������������������������������������͹��
���Desc.     �verifica papel na impressora    				                     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �oRetorno												             ���
����������������������������������������������������������������������������������*/
Method VerPapel() Class LJANfBematech
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial

	//Verifica se tem papel pra prosseguir com o comando
	oParams	:= ::PrepParam({BEMANF,"VerificaPapelPresenter"}) //Aciona o corte total
	cRetorno:= ::EnviarCom(oParams)
	oRetorno:= ::TratarRet(cRetorno)

Return oRetorno

/*����������������������������������������������������������������������������������
���Metodo    �Imprimir         �Autor  �Vendas Clientes     � Data �  13/11/2013 ���
��������������������������������������������������������������������������������͹��
���Desc.     �Manda o texto simples para impress�o    				             ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �oRetorno												             ���
����������������������������������������������������������������������������������*/
Method Imprimir( cTexto ) Class LJANfBematech
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local cCmdAux	:= ""

	//cTextoAux += cBNormal	//Retorna a formata��o default
	cCmdAux := "  " + CHR(10)		//A impressora armazena buffer e para limpar utilizar este comando
	cCmdAux += CHR(3)				//Encerra o buffer
	cCmdAux += CHR(2)				//Limpa o buffer
	oParams	:= ::PrepParam({BEMANF,"BematechTX", cTexto })
	cRetorno:= ::EnviarCom(oParams)
	oRetorno:= ::TratarRet(cRetorno)

Return oRetorno

/*����������������������������������������������������������������������������������
���Metodo    �ImpTxtFmt        �Autor  �Vendas Clientes     � Data �  13/11/2013 ���
��������������������������������������������������������������������������������͹��
���Desc.     �Efetua a impress�o de texto formatado com qrcode/bitmap            ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �oRetorno												             ���
����������������������������������������������������������������������������������*/
Method ImpTxtFmt( cTexto ) Class LJANfBematech
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
	Local cI		:= ""
	Local cAux		:= ""
	Local cLinha	:= ""
	Local aTags		:= {}
	Local nI		:= 0
	Local nF		:= 0
	Local nPos		:= 0
	Local lRetorno	:= .F.

	DEFAULT cTexto	:= ""

	cAux := AltCodeBar("",cTexto)

	aTags	:= {TAG_EAN13_INI, TAG_EAN8_INI,TAG_UPCA_INI,TAG_CODE39_INI,TAG_CODE93_INI,TAG_CODABAR_INI,;
	TAG_MSI_INI,TAG_CODE11_INI,TAG_PDF_INI,TAG_COD128_INI,TAG_I2OF5_INI,TAG_S2OF5_INI,;
	TAG_QRCODE_INI,TAG_ITF,TAG_ISBN,TAG_PLESSEY,TAG_BMP_INI,TAG_GUIL_INI}


	//Neste momento somente avalia a exist�ncia de Tag de Codigo de Barras/QrCode e Bitmap, pois o resto j� foi removido
	nPos := At("<",cAux)
	While nPos > 0      
		nF := At(">",cAux)
		cI := Substr(cAux,nPos,(nF-nPos)+1) //Extrai a Tag
		nI := Ascan(aTags,cI)

		//Valida se � uma tag v�lida
		If nI > 0
			If nPos == 1
				nF := At(Stuff(cI,2,0,"/"),cAux)
				cLinha	:= Substr(cAux,1,nF+Len(Stuff(cI,2,0,"/"))-1)
				cAux	:= RemoveChar(cAux,cLinha,"")

				//Remove da cLinha as tags
				cLinha	:= RemoveChar(cLinha,cI,"")
				cLinha	:= RemoveChar(cLinha,Stuff(cI,2,0,"/"),"")

				If cI == TAG_BMP_INI
					oRetorno:= ::ImpBitMap(cLinha)
				ElseIf cI == TAG_GUIL_INI
					oRetorno:= ::CortaPapel()
				Else
					oRetorno:= ::ImpCodeBar(cI,cLinha)
				EndIf

			ElseIf nPos > 0
				cLinha	:= Substr(cAux,1,nPos-1)
				cAux	:= RemoveChar(cAux,cLinha,"")
				oRetorno:= ::Imprimir(cLinha)

			Else
				//Altera aqui para tentar evitar looping infinito
				cAux := RemoveChar(cAux,"<","")
			EndIf

			nPos	:= At("<",cAux)
			lRetorno:= .T.
		EndIf
	EndDo

	//Se ainda houver texto imprime o restante como texto comum
	If lRetorno .AND. !Empty(AllTrim(cAux))
		oRetorno:= ::Imprimir(cAux)
	EndIf

Return { lRetorno , oRetorno }

/*����������������������������������������������������������������������������������
���Metodo    �IsCodeBar        �Autor  �Vendas Clientes     � Data �  13/11/2013 ���
��������������������������������������������������������������������������������͹��
���Desc.     �Verifica se no texto h� c�digos  				                     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �aRet - {lRet,cTipo,lConfigDef,cComando,cTxtAux}		             ���
����������������������������������������������������������������������������������*/
Static Function IsCodeBar(cTipo,cTexto) 
	Local aRet			:= {}
	Local cTxtAux		:= ""
	Local cComando		:= ""
	Local nLen			:= 0
	Local nPos			:= 0
	Local lRet			:= .F.
	Local lConfigDef	:= .T.
	Local lUseSat		:= 	IIF(ExistFunc("LjUseSat"),LjUseSat(),.F.)  //Utiliza SAT

	DEFAULT cTipo := ""
	DEFAULT cTexto:= ""

	//Valida cTipo pois se ela vier setada, a origem foi um comando direto e n�o um texto com v�rias formata��es
	If !Empty(AllTrim(cTipo))

		//Formata como se fosse uma tag comum
		cTexto := cTipo + cTexto + Stuff(cTipo,2,0,"/")
	EndIf

	//Como depois desta fun��o ser� removida todas as tags nao utilizadas
	//� necess�rio mudar as tags
	nPos := At(TAG_COD128_INI,cTexto)
	If nPos > 0

		cTipo	:= TAG_COD128_INI
		cComando:= "ImprimeCodigoBarrasCODE128"

		//Como a largura padr�o � 1, a qtde de caracteres do codbar � 28
		cTxtAux := Substr(cTexto,nPos+Len(TAG_COD128_INI),At(TAG_COD128_FIM,cTexto)-Len(TAG_COD128_FIM))
		If Len(cTxtAux) > 28 .AND. !lUseSat
			cTxtAux := Substr(cTxtAux,1,28)
		EndIf

		lRet := .T.

		Aadd( aRet , {lRet,cTipo,lConfigDef,cComando,cTxtAux} )
	EndIf

	nPos := At(TAG_UPCA_INI,cTexto)
	If nPos > 0
		cTipo 	 := TAG_UPCA_INI
		cComando := "ImprimeCodigoBarrasUPCA"

		//Altera a tag no vari�vel cTexto
		cTxtAux := Substr(cTexto,nPos+Len(TAG_UPCA_INI),At(TAG_UPCA_FIM,cTexto)-Len(TAG_UPCA_FIM))

		lRet := .T.

		Aadd( aRet , {lRet,cTipo,lConfigDef,cComando,cTxtAux} )
	EndIf

	nPos := At(TAG_EAN13_INI,cTexto)
	If nPos > 0
		cTipo := TAG_EAN13_INI
		cComando := "ImprimeCodigoBarrasEAN13"

		cTxtAux := Substr(cTexto,nPos+Len(TAG_EAN13_INI),At(TAG_EAN13_FIM,cTexto)-Len(TAG_EAN13_FIM))

		//Como a largura padr�o � 1, a qtde de caracteres do codbar � 9
		nLen	:= Len(cTxtAux)
		If nLen > 12
			cTxtAux := Substr(cTxtAux,1,12)
		EndIf

		lRet := .T.

		Aadd( aRet , {lRet,cTipo,lConfigDef,cComando,cTxtAux} )
	EndIf

	nPos := At(TAG_EAN8_INI,cTexto)
	If nPos > 0
		cTipo := TAG_EAN8_INI
		cComando := "ImprimeCodigoBarrasEAN8"

		cTxtAux := Substr(cTexto,nPos+Len(TAG_EAN8_INI),At(TAG_EAN8_FIM,cTexto)-Len(TAG_EAN8_FIM))

		//Como a largura padr�o � 1, a qtde de caracteres do codbar � 7
		nLen	:= Len(cTxtAux)
		If nLen > 7
			cTxtAux := Substr(cTxtAux,1,7)
		EndIf

		lRet := .T.

		Aadd( aRet , {lRet,cTipo,lConfigDef,cComando,cTxtAux} )
	EndIf


	nPos := At(TAG_CODE39_INI,cTexto)
	If nPos > 0
		cTipo := TAG_CODE39_INI	
		cComando := "ImprimeCodigoBarrasCODE39"

		cTxtAux := Substr(cTexto,nPos+Len(TAG_CODE39_INI),At(TAG_CODE39_FIM,cTexto)-Len(TAG_CODE39_FIM))

		//Como a largura padr�o � 1, a qtde de caracteres do codbar � 9
		nLen	:= Len(cTxtAux)
		If nLen > 9
			cTxtAux := Substr(cTxtAux,1,9)
		EndIf

		lRet := .T.

		Aadd( aRet , {lRet,cTipo,lConfigDef,cComando,cTxtAux} )
	EndIf

	nPos := At(TAG_CODE93_INI,cTexto)
	If nPos > 0
		cTipo := TAG_CODE93_INI
		cComando := "ImprimeCodigoBarrasCODE93"

		cTxtAux := Substr(cTexto,nPos+Len(TAG_CODE93_INI),At(TAG_CODE93_FIM,cTexto)-Len(TAG_CODE93_FIM))

		//Como a largura padr�o � 1, a qtde de caracteres do codbar � 9
		nLen	:= Len(cTxtAux)
		If nLen > 9
			cTxtAux := Substr(cTxtAux,1,9)
		EndIf

		lRet := .T.

		Aadd( aRet , {lRet,cTipo,lConfigDef,cComando,cTxtAux} )
	EndIf

	//Segundo o boletim para este comando n�o tem tag que encerra o texto portanto 
	//tudo que vier ap�s o comando ser� considerado como c�digo ITF, recomenda-se imprimir este c�digo separadamente de outros textos
	nPos := At(TAG_ITF,cTexto)	
	If nPos > 0
		cTipo		:= TAG_ITF
		cComando	:= "ImprimeCodigoBarrasITF"
		lConfigDef	:= .F.

		cTxtAux := Substr(cTexto,nPos+Len(TAG_ITF),At("</itf>",cTexto)-Len("</itf>"))

		lRet := .T.

		Aadd( aRet , {lRet,cTipo,lConfigDef,cComando,cTxtAux} )	
	EndIf

	nPos := At(TAG_CODABAR_INI,cTexto)	
	If nPos > 0
		cTipo := TAG_CODABAR_INI
		cComando:= "ImprimeCodigoBarrasCODABAR"

		cTxtAux := Substr(cTexto,nPos+Len(TAG_CODABAR_INI),At(TAG_CODABAR_FIM,cTexto)-Len(TAG_CODABAR_FIM))

		//Como a largura padr�o � 1, a qtde de caracteres do codbar � 12
		nLen	:= Len(cTxtAux)
		If nLen > 12
			cTxtAux := Substr(cTxtAux,1,12)
		EndIf

		lRet := .T.

		Aadd( aRet , {lRet,cTipo,lConfigDef,cComando,cTxtAux} )
	EndIf

	//Segundo o boletim para este comando n�o tem tag que encerra o texto portanto 
	//tudo que vier ap�s o comando ser� considerado como c�digo ISBN, recomenda-se imprimir este c�digo separadamente de outros textos
	nPos := At(TAG_ISBN,cTexto)	
	If nPos > 0
		cTipo := TAG_ISBN
		cComando := "ImprimeCodigoBarrasISBN"

		cTxtAux := Substr(cTexto,nPos+Len(TAG_ISBN),Len(cTexto))

		lRet := .T.
		Aadd( aRet , {lRet,cTipo,lConfigDef,cComando,cTxtAux} )
	EndIf

	nPos := At(TAG_MSI_INI,cTexto)
	If nPos > 0
		cTipo := TAG_MSI_INI
		cComando := "ImprimeCodigoBarrasMSI"

		cTxtAux := Substr(cTexto,nPos+Len(TAG_MSI_INI),At(TAG_MSI_FIM,cTexto)-Len(TAG_MSI_FIM))

		//Como a largura padr�o � 1, a qtde de caracteres do codbar � 10
		nLen	:= Len(cTxtAux)
		If nLen > 10
			cTxtAux := Substr(cTxtAux,1,10)
		EndIf

		lRet := .T.

		Aadd( aRet , {lRet,cTipo,lConfigDef,cComando,cTxtAux} )	
	EndIf

	//Segundo o boletim para este comando n�o tem tag que encerra o texto portanto 
	//tudo que vier ap�s o comando ser� considerado como c�digo PLESSEY, recomenda-se imprimir este c�digo separadamente de outros textos
	nPos := At(TAG_PLESSEY,cTexto)	
	If nPos > 0	
		cTipo := TAG_PLESSEY
		cComando := "ImprimeCodigoBarrasPLESSEY"

		cTxtAux := Substr(cTexto,nPos+Len(TAG_PLESSEY),Len(cTexto))

		lRet := .T.
		Aadd( aRet , {lRet,cTipo,lConfigDef,cComando,cTxtAux} )
	EndIf

	nPos := At(TAG_QRCODE_INI,cTexto)
	If nPos > 0
		cTipo		:= TAG_QRCODE_INI
		cComando	:= "ImprimeCodigoQRCODE"
		lConfigDef	:= .F.

		cTxtAux := Substr(cTexto,nPos+Len(TAG_QRCODE_INI),At(TAG_QRCODE_FIM,cTexto)-Len(TAG_QRCODE_FIM))

		lRet := .T.

		Aadd( aRet , {lRet,cTipo,lConfigDef,cComando,cTxtAux} )		
	EndIf

	nPos := At(TAG_PDF_INI,cTexto)
	If nPos > 0
		cTipo		:= TAG_PDF_INI
		cComando	:= "ImprimeCodigoBarrasPDF147"
		lConfigDef	:= .F.

		cTxtAux := Substr(cTexto,nPos+Len(TAG_PDF_INI),At(TAG_PDF_FIM,cTexto)-Len(TAG_PDF_FIM))

		lRet := .T.

		Aadd( aRet , {lRet,cTipo,lConfigDef,cComando,cTxtAux} )	
	EndIf

	If Len(aRet) == 0
		Aadd(aRet , {.F.,"",.F.,"",""})
	EndIf

Return aRet

/*����������������������������������������������������������������������������������
���Metodo    �AltCodeBar       �Autor  �Vendas Clientes     � Data �  13/11/2013 ���
��������������������������������������������������������������������������������͹��
���Desc.     �Efetua a prote��o e a corre��o para as tags de c�digo de barras 	 ���
��� 		 �e bmp que ser�o impressas posteriormente							 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Retorno   �cTexto												             ���
����������������������������������������������������������������������������������*/
Static Function AltCodeBar(cTipo,cMsg)
	Local nI	:= 0  
	Local cTexto:= cMsg
	Local cIndic:= "B"
	Local aTags	:= {TAG_EAN13_INI, TAG_EAN8_INI,TAG_UPCA_INI,TAG_CODE39_INI,TAG_CODE93_INI,TAG_CODABAR_INI,;
	TAG_MSI_INI,TAG_CODE11_INI,TAG_PDF_INI,TAG_COD128_INI,TAG_I2OF5_INI,TAG_S2OF5_INI,;
	TAG_QRCODE_INI,TAG_ITF,TAG_ISBN,TAG_PLESSEY,TAG_BMP_INI,TAG_GUIL_INI}

	//QUANDO PASSADO "B" SERVE PARA PROTECAO DA TAG, em Branco indica a remo��o da mesma
	If cTipo == "B"
		cIndic := ""
	Else
		cIndic := "B"
	EndIf

	For nI := 1 to Len(aTags)
		While At(Stuff(aTags[nI],2,0,cIndic),cTexto) > 0
			cTexto := RemoveChar(cTexto,Stuff(aTags[nI],2,0,cIndic), Stuff(aTags[nI],2,0,cTipo))
			cTexto := RemoveChar(cTexto,Stuff(aTags[nI],2,0,"/"+cIndic), Stuff(aTags[nI],2,0,"/"+cTipo))
		EndDo
	Next nI

Return cTexto

//--------------------------------------------------------
/*/
Efetua o envio do comando de abrir gaveta
@param   Sem parametro
@author  Varejo
@version P11.8
@since   09/12/2014
@return  oRetorno
/*/
//-------------------------------------------------------
Method AbrirGavet() Class LJANfBematech
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao	
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local cConteudo := ""

	cConteudo := Chr(27) + Chr(118) + Chr(140)  //Comando para abertura de gaveta
	oParams	:= ::PrepParam({BEMANF,"ComandoTX", cConteudo })
	cRetorno:= ::EnviarCom(oParams)
	oRetorno:= ::TratarRet(cRetorno)

Return oRetorno

//--------------------------------------------------------
/*/
Efetua o envio do corte de papel
@param   Sem parametro
@author  Varejo
@version P11.8
@since   29/03/2016
@return  oRetorno
/*/
//-------------------------------------------------------
Method CortaPapel() Class LJANfBematech
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao	
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial

	oParams	:= ::PrepParam({ BEMANF,"AcionaGuilhotina", "0" }) //Aciona o corte total
	cRetorno:= ::EnviarCom(oParams)
	oRetorno:= ::TratarRet(cRetorno)

Return oRetorno
