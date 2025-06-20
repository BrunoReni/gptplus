#INCLUDE "MSOBJECT.CH" 
#INCLUDE "DEFECF.CH"
#INCLUDE "LOJA1341.CH"

Function LOJA1341 ; Return  	// "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCImpNFiscal    �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em se comunicar com as impressoras fiscais             ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCImpNFiscal
	
	Data oEcf																//Objeto do tipo LJIEcf
	Data oGlobal															//Objeto do tipo LJCGlobal
			
	Method New()															//Metodo construtor
	Method InfoEcf(cTipo)													//Retorna um tipo de informacao do ecf
  	Method AbrirCNF()								//Abre o cupom nao fiscal
	Method FechaCNF()
	Method AbrirPorta(cModelo, cPorta, oTotvsApi)	
	Method FechaPorta()					
	Method ImpTxtNF(oRelatorio, lLinha)										//Imprimi texto no cupom nao fiscal
	Method CriarImp(cModelo)												//Cria o objeto da impressora
	Method TratarRet(oRetorno)                             					//Trata o retorno do ECF
	Method VeriCupAbr()														//Verifica se tem algum cupom vinculado, nao fiscal ou gerencial aberto
	Method ExibirMsg(cMensagem)												//Exibi a mensagem retornada pelo ecf
	Method ImpTextoNf(cTexto)												// Imprimi texto nao fiscal	
	Method ImpCodeBar(cTipo,cTexto)
	Method ImpBitMap(cArquivo)										//Impress�o de Arquivo .BMP
	Method SetModelImp(cModelo)	
	Method ConfVerao(cTipo)
	Method AbrirGavet()
	Method CortaPapel()
EndClass                                                                      


/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �New   	       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCImpNFiscal.			    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�																	 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method New() Class LJCImpNFiscal
	
Return Self

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �SetModelImp      �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em abrir a porta de comunicacao com o ECF.	    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cModelo) - Modelo do ecf selecionado.		   	         ���
���			 �EXPC2 (2 - cPorta) - Porta de comunicacao.  				         ���
���			 �EXPO3 (3 - oTotvsApi) - Objeto do tipo LJCTotvsApi.		         ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method SetModelImp(cModelo) Class LJCImpNFiscal
	
	Local oRetorno  := Nil						//Retorno do metodo
		
	Default oRelatorio  := Nil
	Default lLinha := .T.
	
	//Imprimi linha no cupom nao fiscal
	oRetorno := ::oEcf:SetModelImp(cModelo)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return	 oRetorno

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �AbrirPorta       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em abrir a porta de comunicacao com o ECF.	    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cModelo) - Modelo do ecf selecionado.		   	         ���
���			 �EXPC2 (2 - cPorta) - Porta de comunicacao.  				         ���
���			 �EXPO3 (3 - oTotvsApi) - Objeto do tipo LJCTotvsApi.		         ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method AbrirPorta(cModelo, cPorta, oTotvsApi) Class LJCImpNFiscal
	
	Local oRetorno  := Nil						//Retorno do metodo
	Local nRet		:= 0                        //Retorno do metodo CriarImp
	
	Default cModelo  := ""
	Default cPorta   := ""
	Default oTotvsApi := Nil
	
	//Cria o objeto oEcf basedo no modelo selecionado
	nRet := ::CriarImp(cModelo, oTotvsApi)
		
    If "BEMATECH" $ cModelo
		oRetorno := ::oEcf:SetModelImp(cModelo)
		oRetorno := ::TratarRet(oRetorno)
		
		If !oRetorno:lRetorno
			nRet := -1
		EndIf
    EndIf
    
	//Abre a porta serial	
	If  nRet == 0
		oRetorno := ::oEcf:AbrirPorta(cPorta)
		oRetorno := ::TratarRet(oRetorno)
	EndIf
	
Return	oRetorno

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �ConfVerao  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
��������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel em efetuar a saida/entrada do horario do  ���
���          �verao	                                        			   ���
��������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	   ���
��������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cTipo) - E(Entrada) / S(Saida).				   ���
��������������������������������������������������������������������������͹��
���Retorno   �Objeto 													   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Method ConfVerao(cTipo) Class LJCImpNFiscal

	Local oRetorno  := Nil						//Retorno do metodo
	
	Default cTipo := Nil
		
	//Efetua a saida/entrada do horario de verao
	oRetorno := ::oEcf:ConfVerao(cTipo)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)

Return oRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ImpTxtNF  �Autor  �Vendas Clientes     � Data �  06/03/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel pel impressao de linhas nao fiscais   	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�ExpO1 (1 - oRelatorio) - Linhas nao fiscais.				  ���
���			 �ExpL1 (2 - lLinha) - Se vai ser impresso linha a linha.	  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto 													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ImpTxtNF(oRelatorio, lLinha) Class LJCImpNFiscal

	Local oRetorno  := Nil						//Retorno do metodo
		
	Default oRelatorio  := Nil
	Default lLinha := .T.
	
	//Imprimi linha no cupom nao fiscal
	oRetorno := ::oEcf:ImpTxtNF(oRelatorio, lLinha)
	//Trata o retorno
	oRetorno := ::TratarRet(oRetorno)
	
Return oRetorno

	 	    			
/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �CriarImp         �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em criar o objeto da impressora         	    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (1 - cModelo) - Modelo do ecf selecionado.		   	         ���
���			 �EXPO1 (3 - oTotvsApi) - Objeto do tipo LJCTotvsApi.		         ���
��������������������������������������������������������������������������������͹��
���Retorno   �Numerico														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method CriarImp(cModelo, oTotvsApi) Class LJCImpNFiscal
   	
	Local nRet		:= 0			//Retorno do metodo
   	Local cClasse	:= "" 		    //Nome da classe da impressora
   	
   	Default cModelo 	:= ""
   	Default oTotvsApi   := Nil
   	
   	Private oTot := oTotvsApi     //Variavel criada para execucao da macro
   	
   	//Busca o nome da classe responsavel
   	cClasse := oTot:oEcNf:ElementKey(Upper(AllTrim(cModelo))):cClasse 
   	
   	//Instancia a classe por macro
    ::oEcf := &(cClasse + "():New(oTot)")
		
Return nRet

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �TratarRet        �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em tratar o retorno do ECF                   	    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPO1 (1 - oRetorno) - Objeto do tipo LJCRetornoEcf.	   	         ���
��������������������������������������������������������������������������������͹��
���Retorno   �Numerico														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method TratarRet(oRetorno) Class LJCImpNFiscal
	
	Local oRet 		:= Nil                 	//Retorno do metodo, objeto do tipo LJCRetImpressora
	Local lRetorno 	:= .T.					//Utilizada para indicar se o comando foi executado		
	
	Default oRetorno := Nil

	//Instancia o objeto LJCRetImpressora
	oRet := LJCRetImpressora():New()
	
	If oRetorno:cAcao == ALERTA
		::ExibirMsg(oRetorno:cCodigo + " - " + oRetorno:cMensagem)
	ElseIf oRetorno:cAcao == ERRO
		::ExibirMsg(oRetorno:cCodigo + " - " + oRetorno:cMensagem)
		lRetorno := .F.
	ElseIf oRetorno:cAcao == REPETIR
		::ExibirMsg(oRetorno:cCodigo + " - " + oRetorno:cMensagem)
	EndIf
	
	//Define se o comando foi executado com sucesso
	oRet:lRetorno := lRetorno
	//Atribui o valor do retorno
	oRet:oRetorno := oRetorno:oRetorno
			
Return oRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ExibirMsg �Autor  �Vendas Clientes     � Data �  12/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em exibir a mensagem retorna pelo ECF.          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�ExpC1 (1 - cMensagem) - Mensagem.				    		  ���
�������������������������������������������������������������������������͹��
���Retorno   �Objeto                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ExibirMsg(cMensagem) Class LJCImpNFiscal	
	
	//Exibi a mensagem
	oFrmMsgEcf := LJCFrmMensagemEcf():New(STR0001, "", "", cMensagem) // "Impressora n�o fiscal"
		
Return

/*����������������������������������������������������������������������������������
���Metodo    �ImpTextoNf       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em abrir a porta de comunicacao com o ECF.	    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (cTexto) - Modelo do ecf selecionado.		   	             ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
����������������������������������������������������������������������������������*/
Method ImpTextoNf(cTexto) Class LJCImpNFiscal 
	
	Local oRetorno  := Nil	//Retorno do metodo
	
	Default cTexto := ""
	
	//Abre a porta serial
	oRetorno := ::oEcf:ImpTextoNf(cTexto)
	oRetorno := ::TratarRet(oRetorno)

Return oRetorno

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �FechaPorta       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em abrir a porta de comunicacao com o ECF.	    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (cTexto) - Modelo do ecf selecionado.		   	             ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
Method FechaPorta() Class LJCImpNFiscal
	Local oRetorno  := Nil						//Retorno do metodo
		
	oRetorno := ::oEcf:FechaPorta()
	oRetorno := ::TratarRet(oRetorno)

Return oRetorno

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �AbrirCNF         �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em abrir a porta de comunicacao com o ECF.	    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (cTexto) - Modelo do ecf selecionado.		   	             ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method AbrirCNF()	Class LJCImpNFiscal  

	Local oRetorno  := Nil						//Retorno do metodo
	
	oRetorno := ::oEcf:AbrirCNF()
	oRetorno := ::TratarRet(oRetorno)

Return oRetorno				

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �FechaCNF         �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em abrir a porta de comunicacao com o ECF.	    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (cTexto) - Modelo do ecf selecionado.		   	             ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method FechaCNF() Class LJCImpNFiscal  

	Local oRetorno  := Nil						//Retorno do metodo
	
	oRetorno := ::oEcf:FechaCNF()
	oRetorno := ::TratarRet(oRetorno)

Return oRetorno		
/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �ImpBitMap        �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em abrir a porta de comunicacao com o ECF.	    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (cTexto) - Modelo do ecf selecionado.		   	             ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
Method ImpBitMap(cArquivo) Class LJCImpNFiscal

	Local oRetorno  := Nil						//Retorno do metodo

	DEFAULT cArquivo := ""
	
	oRetorno := ::oEcf:ImpBitMap(cArquivo)
	oRetorno := ::TratarRet(oRetorno)

Return oRetorno

/*����������������������������������������������������������������������������������
���Metodo    �ImpCodeBar       �Autor  �Vendas Clientes     � Data �  05/05/08   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Responsavel em abrir a porta de comunicacao com o ECF.	    	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPC1 (cTexto) - Modelo do ecf selecionado.		   	             ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
����������������������������������������������������������������������������������*/
Method ImpCodeBar(cTipo,cTexto) Class LJCImpNFiscal 
	
	Local oRetorno  := Nil	//Retorno do metodo
	
	Default cTexto := ""
	
	//Abre a porta serial
	oRetorno := ::oEcf:ImpCodeBar(cTipo,cTexto)
	oRetorno := ::TratarRet(oRetorno)

Return oRetorno

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
Method AbrirGavet() Class LJCImpNFiscal
Local oRetorno := Nil

oRetorno := ::oEcf:AbrirGavet()
oRetorno := ::TratarRet(oRetorno)

Return oRetorno

//--------------------------------------------------------
/*/
Efetua o envio do comando de corte de papel
@param   Sem parametro
@author  Varejo
@version P11.8
@since   30/03/2016
@return  oRetorno
/*/
//-------------------------------------------------------
Method CortaPapel() Class LJCImpNFiscal
Local oRetorno := Nil

oRetorno := ::oEcf:CortaPapel()
oRetorno := ::TratarRet(oRetorno)

Return oRetorno