#INCLUDE "LOJA2508.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"   

#DEFINE 	_L1_IFSANST_APROVADO 	"1"
#DEFINE 	_L1_IFSANST_REPROVADO 	"0"
#DEFINE 	_L1_IFSANST_MESA 		"2"   
#DEFINE 	_L1_IFSANST_OFFLINE 	"9"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA2508   �Autor  �Microsiga          � Data �  02/27/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para identificacao do fonte no repositorio.         ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function LOJA2508() ; Return NIL
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Classe    �LJCIFSRecMesa �Autor  �Protheus        � Data �  02/28/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Classe para realizar o tratamento de uma mensagem com      ���
���          � An�lise de cr�dito realizada pelo Financial Service        ���
�������������������������������������������������������������������������͹��
���Sintaxe   � LJCIFSRecMesa()                                            ���
�������������������������������������������������������������������������͹��
���Parametros� ExpO1 -> ObjXml contendo as Tags                           ���
���          �  - TotvsMessage                                            ���
���          �  - BusinessContent                                         ���
�������������������������������������������������������������������������͹��
���Uso       � LOJA2503                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Class LJCIFSRecMesa

	Data	oXml          // contem o objeto XML inicial
	Data	nAprovado     // Conteudo da Tag AnalysisStatus
	Data	cOrcamento    // Conteudo da Tag OrderNumber
	Data	cContFS       // Conteudo da Tag Contract
	Data	lValid        // atributo interno que indica a validacao dos dados = Orcamento Ok
	Data	cMsg1		  // mensagem com a explica��o da an�lise
	Data	cMsg2		  // mensagem para explica��o ao cliente 
	Data	nRetorno      // codigo a ser retornado para identificacao do processamento : 0 - nao realizado : 1 - executado
	Data	cMensagem     // descricao sobre o retorno do processamento
	
	Method	New()
	Method	Destruct()
	Method	Gravar()
	Method	GetNumRet()
	Method	GetMsgRet()
	Method	GetContrat()
	Method	ValidaOrc()
	Method	SetObjXml()
	
	// Metodos internos para processamento
	Method Iniciar()
	Method Preencher()

End Class

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Destruct  �Autor  �Protheus            � Data �  02/28/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Realiza a instancia do objeto da classe                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Sintaxe   � LJCIFSRecMesa():Destruct() -> NIL                          ���
�������������������������������������������������������������������������͹��
���Retorno   � objeto da classe LJCIFSRecMesa                             ���
�������������������������������������������������������������������������͹��
���Uso       � Classe LJCIFSRecMesa                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Destruct() Class LJCIFSRecMesa

	If ( Self:oXml <> NIL )
		
		FreeObj( Self:oXml )
		Self:oXml := NIL
	EndIf

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �NEW       �Autor  �Protheus            � Data �  02/28/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Realiza a instancia do objeto da classe                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Sintaxe   � LJCIFSRecMesa():New( ExpO1 ) -> Construtor                 ���
�������������������������������������������������������������������������͹��
���Retorno   � objeto da classe LJCIFSRecMesa                             ���
�������������������������������������������������������������������������͹��
���Parametros� ExpO1 -> ObjXml contendo as Tags                           ���
���          �  - TotvsMessage                                            ���
���          �  - BusinessRequest                                         ���
�������������������������������������������������������������������������͹��
���Uso       � Classe LJCIFSRecMesa                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New( oObjXml ) Class LJCIFSRecMesa

	Self:Iniciar()
	
	If ( oObjXml <> NIL )
		
		Self:SetObjXml( oObjXml )
	EndIf

Return Self


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �SetObjXml �Autor  �Protheus            � Data �  02/28/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Realiza a instancia do objeto da classe                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Sintaxe   � LJCIFSRecMesa():New( ExpO1 )                               ���
�������������������������������������������������������������������������͹��
���Retorno   � objeto da classe LJCIFSRecMesa                             ���
�������������������������������������������������������������������������͹��
���Parametros� ExpO1 -> ObjXml contendo as Tags                           ���
���          �  - TotvsMessage                                            ���
���          �  - BusinessRequest                                         ���
�������������������������������������������������������������������������͹��
���Uso       � Classe LJCIFSRecMesa                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method SetObjXml( oObjXml ) Class LJCIFSRecMesa

	If ( oObjXml <> NIL )
		
		Self:oXml := oObjXml
		Self:Preencher()

	EndIf

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Iniciar   �Autor  �Protheus            � Data �  02/28/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Inicializa os atributos da classe com os valores           ���
���          �'default' conforme o tipo de vari�vel.                      ���
�������������������������������������������������������������������������͹��
���Sintaxe   � LJCIFSRecMesa():Iniciar()                                  ���
�������������������������������������������������������������������������͹��
���Retorno   � sem retorno                                                ���
�������������������������������������������������������������������������͹��
���Uso       � Classe LJCIFSRecMesa                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Iniciar() Class LJCIFSRecMesa

	Self:oXml           := NIL
	Self:nAprovado      := 0
	Self:cOrcamento     := " "
	Self:cContFS        := " "
	Self:nRetorno       := 0
	Self:cMensagem      := " "
	Self:lValid	        := .F.
	Self:cMsg1          := " "
	Self:cMsg2          := " "

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Preencher �Autor  �Protheus            � Data �  02/28/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Associa as tags do Xml aos atributos da classe             ���
�������������������������������������������������������������������������͹��
���Sintaxe   � LJCIFSRecMesa():Preencher()                                ���
�������������������������������������������������������������������������͹��
���Retorno   � sem retorno                                                ���
�������������������������������������������������������������������������͹��
���Uso       � Classe LJCIFSRecMesa                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Preencher() Class LJCIFSRecMesa

	Local oXmlTemp := NIL		// Objeto Temporario do XML como atalho para o BusinessRequest e BusinessContent
	Local lXmlOper := .F.		// Identifica ser a operacao de "MESACREDITO"
	
	If ( ValType(Self:oXml) == "O" )
		
		If ( XmlChildEx( Self:oXml, "_TOTVSMESSAGE") <> NIL .AND. XmlChildEx( Self:oXml:_TotvsMessage, "_BUSINESSMESSAGE") <> NIL .AND. ;
			XmlChildEx( Self:oXml:_TotvsMessage:_BusinessMessage, "_BUSINESSREQUEST") <> NIL .AND.;
			XmlChildEx( Self:oXml:_TotvsMessage:_BusinessMessage:_BusinessRequest, "_OPERATION" ) <> NIL )
	
			oXmlTemp := Self:oXml:_TotvsMessage:_BusinessMessage:_BusinessRequest:_Operation
			
			If ( Upper(Alltrim(oXmlTemp:Text)) == "MESACREDITO" )
				
				lXmlOper := .T.
				
			Else
				
				Self:nRetorno := 0 
				Self:cMensagem  := STR0001  // "Opera��o diferente de 'MESACREDITO'" 
				
			EndIf
	
		EndIf
		// verifica a existencia das tags superiores ao BusinessContent
		If ( lXmlOper .AND. XmlChildEx( Self:oXml:_TotvsMessage:_BusinessMessage, "_BUSINESSCONTENT") <> NIL ) .AND. ;
		     XmlChildEx( Self:oXml:_TotvsMessage:_BusinessMessage:_BusinessContent, "_RETURNANALYSISSTATUS") <> NIL
			
			oXmlTemp := Self:oXml:_TotvsMessage:_BusinessMessage:_BusinessContent:_ReturnAnalysisStatus
	
			If ( XmlChildEx( oXmlTemp, "_CONTRACT" ) <> NIL )  // --> CONTRACT = contrato para o XML de retorno
				
				Self:cContFS := Alltrim(oXmlTemp:_Contract:Text)
				
			EndIf
			
			If ( XmlChildEx( oXmlTemp, "_ANALYSISSTATUS" ) <> NIL )  // --> AnalysisStatus = Aprovacao/Reprovacao do Orcamento
				
				Self:nAprovado := Val( Alltrim(oXmlTemp:_AnalysisStatus:Text) )
				
			EndIf
	
			If ( XmlChildEx( oXmlTemp, "_ORDERNUMBER" ) <> NIL )  // --> OrderNumber = Numero do Orcamento
				
				Self:cOrcamento := Alltrim(oXmlTemp:_OrderNumber:Text)
				
			EndIf

			If ( XmlChildEx( oXmlTemp, "_MESSAGE1" ) <> NIL )  // --> Message1 = Numero do Orcamento
				
				Self:cMsg1 := Alltrim(oXmlTemp:_Message1:Text)
				
			EndIf

			If ( XmlChildEx( oXmlTemp, "_MESSAGE2" ) <> NIL )  // --> Message2 = Numero do Orcamento
				
				Self:cMsg2 := Alltrim(oXmlTemp:_Message2:Text)
				
			EndIf
	
		EndIf
	Else

		Self:nRetorno   := 0
		Self:cMensagem	:= STR0002		// "XML nao pode ser identificado"

	EndIf

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetContrat �Autor  �Protheus           � Data �  02/28/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para obter o numero do contrato vindo pelo XML      ���
�������������������������������������������������������������������������͹��
���Sintaxe   � LJCIFSRecMesa():GetContrat()                               ���
�������������������������������������������������������������������������͹��
���Retorno   � cRet --> Codigo do Or�amento                               ���
�������������������������������������������������������������������������͹��
���Uso       � Classe LJCIFSRecMesa                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetContrat() Class LJCIFSRecMesa

Return Self:cContFS

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetNumRet  �Autor  �Protheus           � Data �  02/28/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna o resultado do metodo de validacao dos dados       ���
���          �do XML.                                                     ���
�������������������������������������������������������������������������͹��
���Sintaxe   � LJCIFSRecMesa():GetNumRet()                                ���
�������������������������������������������������������������������������͹��
���Retorno   � nRet --> Aprovacao                                         ���
���          �     0 = Orcamento nao alterado                             ���
���          �     1 = Orcamento atualizado                               ���
�������������������������������������������������������������������������͹��
���Uso       � Classe LJCIFSRecMesa                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetNumRet() Class LJCIFSRecMesa

Return Self:nRetorno


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �GetMsgRet �Autor  �Protheus            � Data �  02/28/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna o resultado do metodo de validacao dos dados       ���
���          �do XML.                                                     ���
�������������������������������������������������������������������������͹��
���Sintaxe   � LJCIFSRecMesa():GetMsgRet()                                ���
�������������������������������������������������������������������������͹��
���Retorno   � cMensagem = Descricao da mensagem de retorno para o EAI.   ���
���          �   Essa mensagem estara no XML de retorno.                  ���
�������������������������������������������������������������������������͹��
���Uso       � Classe LJCIFSRecMesa                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetMsgRet() Class LJCIFSRecMesa

Return Self:cMensagem

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �ValidaOrc �Autor  �Protheus           � Data �  02/28/12    ���
�������������������������������������������������������������������������͹��
���Desc.     � Realiza a consulta a tabela SL1 e verifica:                ���
���		     �  - a existencia do orcamento                               ���
���		     �  - a validade --> L1_DTLIM >= database                     ���
���          �  - seu status de aprovacao                                 ���
�������������������������������������������������������������������������͹��
���Sintaxe   � LJCIFSRecMesa():ValidaOrc()                                ���
�������������������������������������������������������������������������͹��
���Retorno   � .T. = Orcamento Ok funcao de gravacao pode ser chamada     ���
���          � .F. = Orcamento                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Classe LJCIFSRecMesa                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Method  ValidaOrc() Class LJCIFSRecMesa

	Local lOrcam 	:= .F.	                                         // indica se o Orcamento est� Ok para processamento
	Local aSave		:= GetArea()                                    // guarda a area posicionada
	Local lSaveSL1 	:= ( Select("SL1")<>0 )                        // verifica se a tabela SL1 esta aberta
	Local aSaveSL1 	:= IIF( lSaveSL1, SL1->(GetArea()), {} )      // guarda o posicionamento especifico da tabela SL1
	
	//Verifica par�metro que verifica se o modulo sigaloja esta integrado com o Financial Services
	Local lMvLjIntFS := GetRpoRelease("R5") .AND. SuperGetMV("MV_LJINTFS",,.F.) .AND. IIF(FindFunction("LjUpd90Ok"),LjUpd90Ok(),.F.) 
	
	DbSelectArea("SL1")
	SL1->(DbSetOrder(1))	// Ordem 1 ==> L1_FILIAL + L1_NUM
	
	//�����������������������������������������������������Ŀ
	//� O resultado do DbSeek e a validade do Orcamento     �
	//� indicarao se ha necessidade de alteracao do registro�
	//�������������������������������������������������������
	If ( lMvLjIntFS .AND. SL1->( DbSeek( Self:cOrcamento) ) ) 
		
		// verifica o prazo de validade do orcamento
		If ( SL1->L1_DTLIM >= dDataBase )
			
			lOrcam := .T.
			
		Else
			
			lOrcam := .F.
			Self:nRetorno := 0
			Self:cMensagem := STR0003	// "Or�amento fora do prazo validade"
			
		EndIf
	Else

		lOrcam := .F.
		Self:nRetorno := 0
		
		If ( !lMvLjIntFS ) 
			
			Self:cMensagem := STR0004	// "Integra��o Protheus e Financial Service n�o habilitada"
			
		Else
			
			Self:cMensagem := STR0005	// "Or�amento n�o localizado"
			
		EndIf
	EndIf
	
	// restaura a area salva da tabela SL1 
	If ( lSaveSL1 .AND. Len(aSaveSL1) > 0 )
		
		RestArea( aSaveSL1 )
		
	EndIf
	
	RestArea( aSave )
	
	Self:lValid := lOrcam

Return lOrcam

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �Gravar    �Autor  �Protheus           � Data �  02/28/12    ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para realizar a gravacao dos dados do XML na tabela ���
���          � SL1 - Or�amento  :: L1_IFSANST => 0 || 1                   ���
�������������������������������������������������������������������������͹��
���Sintaxe   � LJCIFSRecMesa():Gravar()                                   ���
�������������������������������������������������������������������������͹��
���Retorno   � .T. = Or�amento alterado com sucesso                       ���
���          � .F. = Or�amento n�o alterado                               ���
�������������������������������������������������������������������������͹��
���Uso       � Classe LJCIFSRecMesa                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Method Gravar() Class LJCIFSRecMesa

	Local lGrava	:= .F.	                                        // tera conteudo de retorno da fun��o com sinalizacao da grava��o
	Local aSave		:= GetArea() 									// guarda a area posicionada
	Local lSaveSL1	:= ( Select("SL1")<>0 )  						// verifica se a tabela SL1 esta aberta para guardar  o posicionamento
	Local aSaveSL1 	:= IIF( lSaveSL1, SL1->(GetArea()), {} )  	// guarda o posicionamento especifico da tabela SL1
	Local cAuxStat 	:= " "										    // recebera o valor aprovado/reprovado para retorno do Xml
	Local cAuxFlag 	:= _L1_IFSANST_MESA 										    // valor do flag para gravacao do campo
	Local cAntMsg1	:= " "										    // armazena o conte�do do Campo MEMO para a Mensagem 1
	Local cAntMsg2	:= " "										    // armazena o conte�do do Campo MEMO para a Mensagem 2
	
	// Verifica os dados Orcamento e a existencia do Orcamento 
	If ( Self:lValid .AND. SL1->(DbSeek( Self:cOrcamento ) ) )
		
		If ( SL1->L1_IFSANST <> cAuxFlag .OR. !Empty(SL1->L1_USRST) )
			
			lGrava := .F.
			Self:nRetorno := 0
			
			// avalia se foi aprovado ou reprovado
			If ( SL1->L1_IFSANST == _L1_IFSANST_REPROVADO ) //0
				
				cAuxStat := STR0006	// "reprovado"
			ElseIf ( SL1->L1_IFSANST == _L1_IFSANST_APROVADO ) //1
				
				cAuxStat := STR0007	// "aprovado"
			Else
				
				cAuxStat := STR0008	// "avaliado"
			EndIf
			
			// monta a mensagem de retorno que estara no XML
			If !Empty(cAuxStat) .AND. !Empty(SL1->L1_USRST)
				
				Self:cMensagem := STR0009 + cAuxStat + STR0010 + SL1->L1_USRST	// "Or�amento " #### " manualmente pelo usu�rio " ####
			Else
				
				Self:cMensagem := STR0011 + cAuxStat + STR0012		// "Or�amento j� " #### " anteriormente"
			EndIf
		Else
			
			lGrava := .T.
			Self:nRetorno := 1
			
			If ( Self:nAprovado == 1 )
				
				cAuxFlag := _L1_IFSANST_APROVADO //1
			ElseIf ( Self:nAprovado == 0 )
				
				cAuxFlag := _L1_IFSANST_REPROVADO//2
			EndIf
			
			// realiza a alteracao do Status do Orcamento -> L1_IFSANST
			Reclock( "SL1", .F.)
			
			REPLACE L1_IFSANST WITH cAuxFlag
			
			SL1->(MsUnlock())
			
			// Recebe o conte�do atual dos campos Memo para as Mensagens 1 e 2
			If !Empty(L1_IFSCDM1)
				
				cAntMsg1 := AllTrim(MSMM(L1_IFSCDM1,255))
			EndIf 
			
			If !Empty(L1_IFSCDM2)
			
				cAntMsg2 := AllTrim(MSMM(L1_IFSCDM2,255))
			EndIf

			// Grava��o das Mensagens ( 1 e 2 ) Campos MEMO			
			// verifica a exist�ncia de conte�do para exibi��o alterar ou incluir o novo conte�do da Mensagem 1
			If !Empty(Self:cMsg1) .AND. !(cAntMsg1 == Self:cMsg1) 
			
				MSMM( L1_IFSCDM1, 255 , NIL, Self:cMsg1, 1, NIL , NIL, "SL1", "L1_IFSCDM1" ) 
			
			ElseIf Empty(Self:cMsg1) .AND. !Empty(cAntMsg1) 
			
				MSMM( L1_IFSCDM1, 255 , NIL, Self:cMsg1, 2 , NIL , NIL, "SL1" , "L1_IFSCDM1" ) 
			
			EndIf

			// verifica a exist�ncia de conte�do para exibi��o alterar ou incluir o novo conte�doda Mensagem 2			
			If !Empty(Self:cMsg2) .AND. !(cAntMsg2 == Self:cMsg2) 
			
				MSMM( L1_IFSCDM2, 255 , NIL, Self:cMsg2, 1, NIL, NIL, "SL1", "L1_IFSCDM2" )
			
			ElseIf Empty(Self:cMsg2) .AND. !Empty(cAntMsg2)
			
				MSMM( L1_IFSCDM2, 255 , NIL, Self:cMsg2, 2, NIL, NIL, "SL1", "L1_IFSCDM2" ) 
			
			EndIf

		EndIf
	Else
		
		Self:ValidaOrc()
		If Self:lValid
			lGrava := Self:Gravar() 
		EndIf
		
	EndIf
	
	If ( lSaveSl1 .AND. Len(aSaveSL1)>0 )
		RestArea( aSaveSL1 )
	EndIf
	
	RestArea( aSave )

Return lGrava