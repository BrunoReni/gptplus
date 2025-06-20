#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"  
#INCLUDE "LOJA2506.CH" 
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "XMLXFUN.CH"

Function LOJA2506 ; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    |LjClXMLEai       �Autor  �Vendas Clientes     � Data �  29/02/12   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe que realiza a montagem do XML EAI                           ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LjClXMLEai  
   	
	Data cBnssMsgty                                   //Tipo da Mensagem                        
    Data cBEvtEntit                                   //Nome da Entidade                          
  	Data cBEvtEvent                                   //Nome do Evento                     
    Data cBEvtKey                                     //Chave do Evento                         
    Data cBReqOpera                                   //Operacao                          
    Data oTabs                                        //Cole��o de tabelas                      
    Data oTags                                        //Colecao de tags
    Data cXML                                         //XML
    Data cBnssTyCnt                                   //tipo da mensagem content
    Data nLstSeqTag	                                  //Ultima sequencia da tag inserida  
    Data aEAIData									  //Dados do Envio EAI  
    Data oFWEAI                                       //Objeto EAI

	Method New()                                      //Instancia o objeto
	Method Destruct()                                 //Desinstancia o objeto
	Method AddTab()                                   //Adiciona as tabelas utilizadas no XML
	Method AddTag()                                   //Adiciona as tag utilizadas no XML
	Method GerarXML()                                 //Gera o XML
	Method GerarTags()                                //Gera as tags-filhas, conforme o pai
	Method EnvelopXML()                               //Gera o envelope do tipo de mensagem EAI
	Method ReceberXML()                               //Le o XML recebido 
	Method ExibirResp()                               //Exibe a mensagem do EAI
	Method EnviaEAI()                                   //Envia a mensagem EAI
	
EndClass
/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͻ��
���Metodo    |New              �Autor  �Vendas Clientes      � Data �  29/02/12   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Metodo que Instancia o objeto                                       ���
���������������������������������������������������������������������������������͹��  
���Parametros� ExpC1 = Tipo da Mensagem                                			  ���
���          � ExpC2 = Entidade                                                	  ��� 
���          � ExpC3 = Evento                          	                          ��� 
���          � ExpC4 = Chave                          	                          ��� 
���          � ExpC5 = Operacao                        	                          ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja/SigaFRT                                             		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/

Method New(cBnssMsgTy, 		cBEvtEntit, 	cBEvtEvent,	cBEvtKey, ;
			cBReqOpera,		cBnssTyCnt)  Class LjClXMLEai       
    
	

	Self:cBnssMsgty  	:=  cBnssMsgTy                                                         //Codigo da Tag
    Self:cBEvtEntit 	:=  cBEvtEntit                                                        //Numero do Indice no SX3    
  	Self:cBEvtEvent 	:=  cBEvtEvent                                                    //Bloco de posicionamento da tabela  
    Self:cBEvtKey    	:=  cBEvtKey                                                        //Tabela resultado de uma Query SQL?
    Self:cBReqOpera  	:=  cBReqOpera                                                          //Tabela resultado de uma Query SQL?
    Self:oTabs      	:= LJCList():New()                                                        
    Self:oTags			:= LJCList():New() 
    Self:cXML			:= ""
    Self:cBnssTyCnt		:= cBnssTyCnt
    Self:nLstSeqTag		:= 0  
    
    Self:aEAIData		:= {} 
    Self:oFWEAI         := nil

Return Self      


/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͻ��
���Metodo    |Destruct         �Autor  �Vendas Clientes      � Data �  29/02/12   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Metodo que apaga o objeto                                           ���
���������������������������������������������������������������������������������͹��  
���Uso       �SigaLoja/SigaFRT                                             		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/

Method Destruct()  Class LjClXMLEai 

	If Self:oTabs <> nil
		Self:oTabs:Destruct()
		FreeObj(Self:oTabs)
		Self:oTabs:= Nil    
	EndIf
	
	If	Self:oTags <> nil
		Self:oTags:Destruct()
		FreeObj(Self:oTags)
		Self:oTags:= Nil
	EndIf  
	
	
	If	Self:oFWEAI <> nil
		FreeObj(Self:oFWEAI)
		Self:oFWEAI:= Nil
	EndIf	
	

Return Nil   


/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͻ��
���Metodo    |AddTab           �Autor  �Vendas Clientes      � Data �  29/02/12   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Metodo que Instancia o Objeto na lista de tabelas                   ���
���������������������������������������������������������������������������������͹��  
���Parametros� ExpC1 = Tabela                                         			  ���
���          � ExpN2 = Indice                                                 	  ��� 
���          � ExpB2 = Bloco de posicionaento/carga                               ���
���          � ExpL1 = Tabela SQL					                              ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja/SigaFRT                                             		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/

Method AddTab(cTabela,  nIndice, bPosiciona, lSql)  Class LjClXMLEai
	Local oTab := nil //Metodo que receber� o objeto tabela

	oTab := LjClXMLTab():New(cTabela,  nIndice, bPosiciona, lSql) 

	Self:oTabs:Add(oTab) 


Return Nil  

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͻ��
���Metodo    |AddTag           �Autor  �Vendas Clientes      � Data �  29/02/12   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Metodo que Instancia o Objeto a lista de tags                       ���
���������������������������������������������������������������������������������͹��  
���Parametros� ExpC1 = Nome da tag                                      	      ���
���          � ExpN2 = Sequencia da tag                                        	  ��� 
���          � ExpC3 = Sequencia da tag                                        	  ��� 
���          � ExpC4 = Alias da Tabela                                       	  ��� 
���          � ExpB5 = Condicao para geracao da tag                            	  ��� 
���          � ExpN6 = Minimo de repeticoes                                 	  ��� 
���          � ExpC7 = Maxino de repeticoes  (Exemplo "1", "2", "N"            	  ��� 
���          � ExpB8 = Bloco de execu��o do conteudo                         	  ��� 
���          � ExpC9 = Tipo de retorno do conteudo                           	  ���
���          � ExpN10 = Tamanho do conteudo                                 	  ���
���          � ExpC11 = Mascara do conteudo                                 	  ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja/SigaFRT                                             		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/

Method AddTag(cNome, 		cNomePai, 	nSequencia,	cTabela,;
		   bCondicao, 	nMinimo,	cMaximo, 	bConteudo,;
		   cTipo,		nTamanho, 	cMascara)  Class LjClXMLEai       
		   
	Local oTag := nil //Metodo que receber� o objeto tabela    
	
	Default nSequencia := Self:nLstSeqTag + 1 //Incrementa a sequencia
	
	oTag := LjClXMLTag():New(cNome, 		cNomePai, 	nSequencia,	cTabela,;
						    bCondicao, 	nMinimo,	cMaximo, 	bConteudo,;
						    cTipo,		nTamanho, 	cMascara) 
	
	Self:nLstSeqTag := nSequencia //Atualiza a sequencia da tabela
	Self:oTags:Add(oTag)
	
Return Nil 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͻ��
���Metodo    |GerarTags        �Autor  �Vendas Clientes      � Data �  29/02/12   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Metodo que gerar� as Tags                    						  ��� 
���������������������������������������������������������������������������������͹��  
���Parametros� ExpC1 = Nome da Tag Pai                                     	      ���
���          � ExpN2 = Nivel do Pai                                        	      ��� 
���          � ExpC3 = Colecao de Tags                                        	  ��� 
���          � ExpL4 = Gerar conteudo vazio                                       ��� 
���������������������������������������������������������������������������������͹��  
���Uso       �SigaLoja/SigaFRT                                             		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/

Method GerarTags(cNomePai, nNivPai,  oTags,  lVazio)  Class LjClXMLEai
	Local cXML := ""       //XML geradi
	Local oTag := nil      //Objeto tag
	Local nC := 0          //Contador
	Local cConteudo := ""  //Conteudo 
	Local cTagFilhos := ""  //Nome da tag filho     
	Local nProcessa := 0   //Contador de repeticoes da tag    
	Local nTamTag := 0 //Tamanho das tags
	
	
	Default nNivPai := 3
	Default lVazio := .F.
	Default cNomePai := ""  
	//Default oTags := Self:oTags
	
	If oTags == Nil  
		oTags := Self:oTags
		oTags:Sort(, , "{|x,y| x:cNomePai+StrzERO(x:nSequencia,6)< y:cNomePai+StrZero(y:nSequencia,6)}")
	EndIf
	
	nC := oTags:Seek("cNomePai", cNomePai ) //Posiciona no pai
	
	If nC  > 0   
		nTamTag := oTags:Count()
		While nC <= nTamTag .AND. oTags:Elements(nC):cNomePai == cNomePai     //gera o xml do mesmo pai 
	
			oTag := oTags:Elements(nC)   
	
		   	nProcessa := 1	 		 	 
	
			If !Empty(oTag:cTabela)	 .AND. Alias() <> oTag:cTabela
		 		DbSelectArea(oTag:cTabela)
		 	EndIf 
		 		 	 				   
		   	While Eval(oTag:bCondicao) .AND. IIF( oTag:cMaximo <> "N", nProcessa <= Val( oTag:cMaximo) , .T.)  //.AND. !lVazio //enquanto //enquanto
	                        
				cConteudo := IIF(!Empty(oTag:bConteudo), oTag:Formatar( Eval(oTag:bConteudo) ),"") 
				cTagFilhos := Self:GerarTags(oTag:cNomeTag, nNivPai+1, oTags, lVazio )   
				
		   		If !Empty(cConteudo) .OR. !Empty(cTagFilhos) .OR. ( Empty(cConteudo) .AND. Empty(cTagFilhos) .AND. oTag:nMinimo > 0 .AND. nProcessa == 1) //tag obrigatoria
		   		
		   			cXml += CHR(13) + CHR(10) + space(nNivPai * 5) + "<"+ oTag:cNomeTag + ">"   
		   			
		   			If !Empty(cTagFilhos)
		   				cXML += cTagFilhos + CHR(13) + CHR(10) + space(nNivPai * 5)
		   			Else
		   				cXml += cConteudo 	   				
		   			EndIf  
		   			
		   			cXml += "</"+ oTag:cNomeTag + ">"
		   			nProcessa++ 		
		   			
		   		Else    
		   		
		   			If oTag:nMinimo == 0   				 
		   				nProcessa++ 
		   			EndIf
		   				
		   		EndIf  
		   		
		   		
		   		If !Empty(oTag:cTabela)	
		   			DbSkip(1)
		   		EndIf 
		   	
		   	End 
	
		   	While  ( !Eval(oTag:bCondicao)   )  .AND. nProcessa <= oTag:nMinimo   //enquanto 
		   		
		   		cTagFilhos := Self:GerarTags(oTag:cNomeTag, nNivPai+1, oTags, .T.)
		   		
		   		
		   		cXml += CHR(13) + CHR(10) + space(nNivPai * 5) + "<"+ oTag:cNomeTag + ">"
		   		
		   		If !Empty(cTagFilhos)
		   			cxml += cTagFilhos + CHR(13) + CHR(10) + space(nNivPai * 5)
		   		EndIf   
		   		
		   		cXml += "</"+ oTag:cNomeTag + ">"    
		   		
		   		If !Empty(oTag:cTabela)	
		   			DbSkip(1)
		   	   	EndIf  
		   	   	
		   		nProcessa++	
		   	End 
		      	 
		  	nC++	  
		End 
	EndIf
	
Return cXML   

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͻ��
���Metodo    |GerarXML         �Autor  �Vendas Clientes      � Data �  29/02/12   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Metodo que gerar� o XML                    					      ���
���������������������������������������������������������������������������������͹��  
���Uso       �SigaLoja/SigaFRT                                             		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/

Method GerarXML()  Class LjClXMLEai
	Local nCount := 0   //Variavel Contadora
	Local aArea := GetArea()    //WorkArea Ativa
	
	//Executa o m�todo de abertura/posicionamento das tabelas
	For nCount := 1 To Self:oTabs:Count()
		Self:oTabs:Elements(nCount):Abrir()
	Next nCount 
	
	//Chama o m�todo de gera��o das tags XML
	cXML := Self:GerarTags()
	
	
	//Executa o m�todo de fechamento das tabelas
	For nCount := 1 To Self:oTabs:Count()
		Self:oTabs:Elements(nCount):Fechar()
	Next nCount 
	
	If !Empty(Self:cBnssMsgty ) 
		cXML := Self:EnvelopXML(cXML)   
	EndIf
	
	Self:cXML := EncodeUTF8(cXML)  
	
	RestArea(aArea)
	
Return Self:cXML   
/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͻ��
���Metodo    |EnvelopXML       �Autor  �Vendas Clientes      � Data �  29/02/12   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Metodo que envelopara o XML                       			      ���   
���������������������������������������������������������������������������������͹��  
���Parametros� ExpC1 = XML                                      	              ���
���������������������������������������������������������������������������������͹��  
���Uso       �SigaLoja/SigaFRT                                             		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/

Method EnvelopXML(cXML)  Class LjClXMLEai    
	Local cTmp := ""        //Tag temporaria
	
	cTmp := 	space(5)+	"<"+ Self:cBnssMsgty + ">"+  CHR(13) + CHR(10) 
	
	If Self:cBnssMsgty == "BusinessRequest"
	
	   cTmp +=	space(10)+ "<Operation>" + Self:cBReqOpera + "</Operation>" + CHR(13) + CHR(10)		
	   
	ElseIf Self:cBnssMsgty == "BusinessEvent" 
	
			cTmp += space(10) + "<Entity>" + Self:cBEvtEntit + "</Entity>" + CHR(13) + CHR(10)	+;
					  space(10) + "<Event>" + Self:cBEvtEvent + "</Event>" + CHR(13) + CHR(10)
			
			If !Empty(Self:cBEvtKey) 
				 cTmp += space(10) + "<Identification>"+ CHR(13) + CHR(10)	+;
				 				space(15) + '<key name="key1">'+ Self:cBEvtKey + "</key>" + CHR(13) + CHR(10)+; 
				 			space(10) + "</Identification>"+ CHR(13) + CHR(10)
		   EndIf
		
	Else
		cTmp := ""
	EndIf 
		
	cXML := cTmp + space(5) + "</"+ Self:cBnssMsgty + ">" + CHR(13) + CHR(10) + ;
					space(5) + "<" + Self:cBnssTyCnt + ">"+;
						space(10) + cXML + CHR(13) + CHR(10) + ;
					space(5) + "</" + Self:cBnssTyCnt + ">"
			
			
Return cXML

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͻ��
���Metodo    |ReceberXML       �Autor  �Vendas Clientes      � Data �  29/02/12   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Metodo que recebera o XML                       			          ���   
���������������������������������������������������������������������������������͹��  
���Parametros� ExpC1 = XML                                      	              ���
���������������������������������������������������������������������������������͹��  
���Uso       �SigaLoja/SigaFRT                                             		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Method ReceberXML(cXML, cResp, lRet, aMsgErr, aMsgWrn) Class LjClXMLEai
	Local oXMLRec := nil //Objeto de leitura do XML
	Local cErroXML := "" //Mensagem de erro na leitura dos nodes
	Local cWarnXML := "" //Mensagem de warning na leitura dos nodes  
	Local oTag := nil //Tag Resposta
	Local oObjTmp := nil //Objeto temporario 
	Local cOpera := ""   //tipo da operacao
	Local nPosMain := 0 //Posicao do Main-Node      
	Local oTagMsg := NIl //Objeto de mensagens    
	Local nFilhos := 0   //quantidade de tags filhos
	
	Default cResp := ""
	Default lRet := .F.
	Default aMsgErr := {} //Array de mensagens de Erros
	Default aMsgWrn := {} //Array de mensagens de Warnning
	//Estrutura do arary
	//[1] - codigo da mensagem
	//[2] - texto da mensagem
	lRet := .F.
	
	oXmlRec := XmlParser( cXml, "_", @cErroXml, @cWarnXml ) 
	
	cOpera := ""    
	
	If Self:cBnssMsgty $ "BusinessRequest#BusinessEvent"
		cOpera := "_BUSINESSMESSAGE
	Else
		cOpera := "_RESPONSEMESSAGE"
	EndIf  
	
	If Valtype(oXMLRec) == "O" .AND. ( Empty(cErroXml) .AND. Empty(cWarnXml) )  .AND. ;
		XmlChildEx(oXmlRec, "_TOTVSMESSAGE") <> NIL .AND. ;
		( oObjTmp := XmlChildEx(oXmlRec:_TotvsMessage, cOpera ) ) <> NIL .AND. ;      
		(cOpera == "_RESPONSEMESSAGE" .OR.  (XmlChildEx(oObjTmp, "_" + Upper(Self:cBnssMsgty) )  <> NIL ) )
			
		Do Case
		Case Self:cBnssMsgty == "BusinessRequest" 	  
					
				If (oTagLida := XmlChildEx(oObjTmp:_BusinessRequest, "_OPERATION" ) ) <> NIL .AND. (oTag :=  XmlChildEx(oObjTmp, "_"+ Upper(Self:cBnssTyCnt) ) ) <> NIL
						
				    //Valida se a operacao � referente a recebida
				   
					If Upper(Alltrim(oTagLida:Text)) == Upper(RTrim(Self:cBReqOpera))  
						lRet := .t.				 					
					Else 
						cResp := STR0001 + Self:cBReqOpera //"XML Recebido n�ao corresponde a operacao: " 	
					EndIf
			
				Else
					cResp := STR0002 //"XML com constru��o incorreta"
				EndIf 
		Case Self:cBnssMsgty == "BusinessEvent" 	  
				If (oTagLida := XmlChildEx(oObjTmp:_BusinessEvent, "_ENTITY" ) ) <> NIL .AND. (oTag :=  XmlChildEx(oObjTmp, "_"+ Upper(Self:cBnssTyCnt) ) ) <> NIL
					If Upper(Alltrim(oTagLida:Text)) == Upper(RTrim(Self:cBEvtEntit))
						lRet := .T.
					Else 
						cResp := STR0010 + Self:cBEvtEntit 	   //"XML Recebido n�ao corresponde a Entidade: "
					EndIf
				Else
					cResp := STR0002  ////"XML com constru��o incorreta"
				EndIf 
				
		Case Self:cBnssMsgty == "ResponseMessage" 	  
				If (oTagLida := XmlChildEx(oObjTmp, "_PROCESSINGINFORMATION" ) ) <> NIL  .AND. (oTag :=  XmlChildEx(oObjTmp, "_"+ Upper(Self:cBnssTyCnt) ) ) <> NIL
					
					If (oTagLida := XmlChildEx(oTagLida, "_STATUS" ) ) <> NIL  .AND. Upper(oTagLida:Text) == "OK"
				   
						lRet := .T.
					Else 
						
						If (oTagLida := XmlChildEx(oObjTmp:_PROCESSINGINFORMATION, "_LISTOFMESSAGES" ) ) <> NIL 
						    
						    nPosMain := 0  
						    nFilhos := XMLChildCount(oTagLida)
						    
						    If Type("oTagLida:_Message") == "A"
						    	nFilhos := Len(oTagLida:_MESSAGE)
						    EndIf
						    
						    
					    	For nPosMain := 1 To nFilhos
		
								If Type("oTagLida:_Message") == "A"
									oTagMsg := oTagLida:_MESSAGE[nPosMain]
								Else
									oTagMsg := XmlGetChild(oTagLida, nPosMain)
								EndIf 
								
								If Upper(oTagMsg:RealName) == "MESSAGE" 
								
									cResp := oTagMsg:Text
								
								EndIf   
								
								If XmlChildEx(oTagMsg, "_CODE") <> NIL .AND. !Empty(oTagMsg:_Code:Text)
									cOpera := oTagMsg:_Code:Text
								End
								
								If XmlChildEx(oTagMsg, "_TYPE")<> NIL .AND. !Empty(oTagMsg:_Type:Text)
								
								    If Upper(oTagMsg:_Type:Text) == "ERROR"
								    	aAdd(aMsgErr, {cOpera, cResp})
								    Else 
								    	//Se n�o eh erro eh warnning
								    	aAdd(aMsgWrn, {cOpera, cResp})
								    EndIf
								Else
									cResp := STR0002 //"XML com constru��o incorreta"
								EndIf   
								
							Next nPosMain  
								
						Else
							cResp := STR0013	   //"XML Recebido n�ao corresponde a Entidade: "   
						EndIf
					EndIf
				Else
					cResp := STR0002  ////"XML com constru��o incorreta"
				EndIf 
		OtherWise 
			//N�o tratado as operacoes
			lRet := .T.
		EndCase 
	Else
		cResp := STR0002 + AllTrim(cErroXml) + " " +  AllTrim(cWarnXml) //"XML com constru��o incorreta"
	EndIf  
	
	If lRet //Processa a BusinessContent 
		//vALIDA A BUSINESS CONTENT 
		//Verifica se existe a tag-pai  
		If Self:oTags:Count() > 0   
		
			Self:oTags:Sort(, , "{|x,y| x:cNomePai+StrzERO(x:nSequencia,6)< y:cNomePai+StrZero(y:nSequencia,6)}")
			nPosMain := Self:oTags:Seek("cNomePai", "" ) 
			
			If nPosMain > 0  
			
			   If (oTag :=  XmlChildEx(oTag, "_"+ Upper(Self:oTags:Elements(nPosMain):cNomeTag ) ) ) == NIL
			
					cResp := STR0011 + Self:oTags:Elements(nPosMain):cNomeTag //"Node principal n�o encontrado no XML "
			
				Else
			
					lRet := .T.
			
				EndIf  
				
			Else
			
				lRet := .T.
			
			EndIf
		Else
			lRet := .T.
		EndIf
	
	EndIf
	
Return oTag 



/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͻ��
���Metodo    |ExibirResp       �Autor  �Vendas Clientes      � Data �  22/03/12   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Metodo que exibe as mensagens de erro                               ���
���������������������������������������������������������������������������������͹��  
���Parametros� ExpC1 = Tabela                                         			  ���
���          � ExpN2 = Indice                                                 	  ��� 
���          � ExpB2 = Bloco de posicionaento/carga                               ���
���          � ExpL1 = Tabela SQL					                              ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja/SigaFRT                                             		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/

Method ExibirResp(cMsgResp, aMsgErr, aMsgWrn)  Class LjClXMLEai
	Local cMsgErr := ""  //mensagem de erro
	Local cMsgWrn := ""  //mensagem de warning
	Local nCount := 0 //Variavel Contadores
	Local cMsg := ""  //variavel de retorno
	Local lClient := !IsBlind()  //Execucao pelo client 
	Local oDlg := nil //Objeto janela  
	Local oTMultiget1 := nil  //objeto multiget 1
	Local oTMultiget2 := Nil //objeto multiget  2
	Local oBmp1 := nil //Objeto Bitmap 1
	Local oBmp2 := nil //Objeto Bitmap 2       
	Local oSay := nil //Objeto say    
	Local cTitulo := "" //Titulo da janela 
	Local oTimer := nil //obejto temporizados   
	Local nMilisseg := 15000 // Disparo ser� de 15 segundos 
	
	Default cMsgResp := ""
	Default aMsgErr := {} 
	Default aMsgWrn := {}
	
	For nCount := 1 to Len(aMsgErr)  
		cMsg := ""
		If !Empty(aMsgErr[nCount,1])
			cMsg += STR0014 + aMsgErr[nCount,1] + " - " //"Codigo: "
		EndIf  
		If !Empty(aMsgErr[nCount,2])
			cMsg += aMsgErr[nCount,2]
		EndIf  
		
		If !Empty(cMsg)
			cMsgErr += cMsg + CRLF
		EndIf
	Next nCount 
	
	If Len(cMsgErr) > 0
		cMsgErr := Left(cMsgErr, Len(cMsgErr)-2)
	EndIf
	
	For nCount := 1 to Len(aMsgWrn)
		cMsg := ""
		If !Empty(aMsgWrn[nCount,1])
			cMsg += STR0014 + aMsgWrn[nCount,1] + " - "    //"Codigo: "
		EndIf  
		If !Empty(aMsgWrn[nCount,2])
			cMsg += aMsgWrn[nCount,2]
		EndIf  
		
		If !Empty(cMsg)
			cMsgWrn += cMsg + CRLF
		EndIf
	Next nCount   
	
	If Len(aMsgWrn) > 0
		cMsgWrn := Left(cMsgWrn, Len(cMsgWrn)-2)
	EndIf  
	
	cTitulo := STR0015 + Self:cBnssMsgty  //"Tipo da Mensagem : "
	
	If Self:cBnssMsgty  == "BusinessRequest"
	
	   cTitulo +=	space(5)+ STR0016 + Self:cBReqOpera     //"Opera��o: " 
	   
	ElseIf Self:cBnssMsgty == "BusinessEvent" 
	
		cTitulo += space(5) + STR0017 + Self:cBEvtEntit   //"Entidade:" 
	EndIf
	
	If lClient .AND. !Empty(cMsgWrn+cMsgErr)
	
		DEFINE DIALOG oDlg TITLE STR0018 FROM 180,180 TO 430,700 PIXEL  //"Retorno da Mensagem EAI da aplicacao destino"
			
			oSay:= TSay():New(05,05,{||cTitulo },oDlg,,,,;
	                  ,,.T.,,,300,10)
			
			oBmp1 := TBitmap():New(15,05,13,15,"UPDWARNING",,.T.,oDlg,;
	            ,,.F.,.T.,,,.F.,,.T.,,.F.)   
	            
	
		    oTMultiget1 := TMultiget():New(15,25, {|u|if(Pcount()>0,cMsgWrn:=u,cMsgWrn)},;
		                           oDlg,230,40,,.F.,,,,.T.,,,,,,.T.,,,,,.T.) 
		    oBmp1 := TBitmap():New(65,05,13,15,"UPDERROR",,.T.,oDlg,;
	            					,,.F.,.T.,,,.F.,,.T.,,.F.)   
		    oTMultiget2 := TMultiget():New(65,25,{|u|if(Pcount()>0,cMsgErr:=u,cMsgErr)},;
		                           oDlg,230,40,,.F.,,,,.T.,,,,,,.T.,,,,,.T.)
		                                                      
		    SButton():New( 110,25,01,{||  oDlg:End()},oDlg,.T.,,)      
		    
		    oTimer := TTimer():New(nMilisseg, {|| oDlg:End() }, oDlg )
	   		oTimer:Activate()
		       
		ACTIVATE DIALOG oDlg CENTERED    
		
	ElseIf !Empty(cMsgWrn+cMsgErr)
		ConOut(STR0018 + CRLF + cTitulo + CRLF +;  //"Retorno da Mensagem EAI da aplicacao destino"
		"Warning: " + cMsgWrn + CRLF +;
		"Error:" + cMsgErr )
	
	EndIf
		
Return Nil   


/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͻ��
���Metodo    |EnviaEAI         �Autor  �Vendas Clientes      � Data �  29/05/12   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Metodo que envia as mensagens EAI nao utilizando a ferramenta       ���
���������������������������������������������������������������������������������͹��  
���Parametros� ExpC1 = Nome do Adapter                                			  ���
���          � ExpN2 = Indice                                                 	  ��� 
���          � ExpB2 = Bloco de posicionaento/carga                               ���
���          � ExpL1 = Tabela SQL					                              ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja/SigaFRT                                             		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Method EnviaEAI(cFuncCode)  Class LjClXMLEai     
	
	Local lEnviado := .F. 

	Self:oFWEAI:= FWEAI():New()		

Return lEnviado