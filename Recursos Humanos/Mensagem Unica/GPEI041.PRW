#INCLUDE 'PROTHEUS.CH'  
#INCLUDE 'FWADAPTEREAI.CH' 
#INCLUDE "FWMVCDEF.CH"

Static cVerSend 	:= "1.000"
Static nAfastEAI	:= SuperGetMV("MV_AFASEAI", , 0) // Quantidade m�nima de dias para enviar o afastamento via EAI

/*/{Protheus.doc} GPEI041
Funcao de integracao com o adapter EAI para envio e recebimento de
alteracoes no campo RA_SITFOLH do cadastro de funcion�rios (SRA)
 utilizando o conceito de mensagem unica.

@param   cXML          Variavel com conteudo xml para envio/recebimento
@param   cTypeTrans    Tipo de transacao. (Envio/Recebimento)
@param   cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)

@version P11
@since   28/12/2014
@return  aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno.
aRet[1] - (boolean) Indica o resultado da execu��o da fun��o
aRet[2] - (caracter) Mensagem Xml para envio

/*/

/*
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������Ŀ��
���Funcao    � GPEI041    �Autor  �Alberto M.         v.I         � Data �06/01/2014���
�����������������������������������������������������������������������������������Ĵ��
���Descricao � Mensagem Unica EmployeeSituation - Integracao PROTHEUS X PIMS        ���
�����������������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                             ���
�����������������������������������������������������������������������������������Ĵ��
���Uso       � GPEA240 - Inclusao de Afastamentos.                                  ���
���          � GPEM040 - Calculo de Rescisao.                                       ���
���          � GPEM630 - Calculo de Rescisao Coletiva.                              ���
���          � GPEM030 - Calculo de Ferias.                                         ���
���          � GPEM060 - Calculo de Ferias Coletivas.                               ���
���          � GPEA810 - Reintegracao de funcionario.                               ���
���          � GPEA010 - Funcionario.                                               ���
�����������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
�����������������������������������������������������������������������������������͹��
*/
Function GPEI041( cXml, nType, cTypeMsg, cVersaoMsg )

Local lRet        := .T.
Local cEvent      := ''
Local cOrigem     := ''
Local nTypeTrans  := nType
Local cXMLRet     := ''
Local cError      := ''
Local cWarning    := ''

//������������������������������������������������������������������������Ŀ
//� Variaveis para a gravacao da tabela XXF(de/para).                    	 �
//��������������������������������������������������������������������������
Local cProduct      := ''
Local cValInt       := ''
Local cValExt       := ''
Local cXmlContent   := ''
Local cAliasXXF     := 'SRA'
Local cField        := 'RA_SITFOLH'
Local oModel
Local nOperacao

Default cXml        := ''
Default nType       := 1
Default cTypeMsg    := '' 
Default cVersaoMsg  := ''

Private oGridSR8 	:= Nil
Private aCodFol		:= {}

//������������������������������������������������������������������������Ŀ
//� Tratamento da recepcao das mensagens.                                  �
//��������������������������������������������������������������������������
If nTypeTrans == TRANS_RECEIVE
	Do Case

		//������������������������������������������������������������������������Ŀ
		//�Tratamento da mensagem que solicita as versoes permitidas.              �
		//��������������������������������������������������������������������������
		Case cTypeMsg == EAI_MESSAGE_WHOIS
			lRet := .T.
			cXMLRet := cVerSend

		//������������������������������������������������������������������������Ŀ
		//�                                                                        �
		//��������������������������������������������������������������������������	
		Case cTypeMsg == EAI_MESSAGE_RECEIPT


		//������������������������������������������������������������������������Ŀ
		//�Tratamento da mensagem enviada pelo PIMS.                               �
		//��������������������������������������������������������������������������
		Case cTypeMsg == EAI_MESSAGE_BUSINESS

		//������������������������������������������������������������������������Ŀ
		//�Tratamento da response message enviada pelo PIMS, verifica se houve     � 
		//algum erro na grava��o do lado do PIMS.                                  �
		//��������������������������������������������������������������������������
		Case cTypeMsg == EAI_MESSAGE_RESPONSE
		
			oXml := XmlParser(cXml, "_", @cError, @cWarning)
		
		
			//������������������������������������������������������������������������Ŀ
			//�Verifica se o Parse foi efetuado corretamente.                          �
			//��������������������������������������������������������������������������
			If(Upper(oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text) == "OK")
			
				//������������������������������������������������������������������������Ŀ
				//�Verifica��o do produto                                                  �
				//��������������������������������������������������������������������������
				If(Type("oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text") != "U" .And. ;
			   			 !Empty(oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text))
				
					cProduct := oXml:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				EndIf
			
				//������������������������������������������������������������������������Ŀ
				//Verifica��o do InternalID                                                �
				//��������������������������������������������������������������������������
				If lRet .And. (Type("oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text") != "U" .And.;
				 				      !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text))
				
					cValInt := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Origin:Text
				EndIf
			
				//������������������������������������������������������������������������Ŀ
				////Verifica��o do InternalID Destination.                                 �
				//��������������������������������������������������������������������������
				If lRet .And. (Type("oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text") != "U" .And. ;
				 					   !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text))
				
					cValExt := oXml:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_InternalId:_Destination:Text
				EndIf
			
				//������������������������������������������������������������������������Ŀ
				//Verifica��o da ContentMessage.                                           �
				//��������������������������������������������������������������������������
				If lRet .And. (Type("oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text") != "U" .And. ;
				 					   !Empty(oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text))
				
					cXmlContent := oXml:_TOTVSMessage:_ResponseMessage:_ReceivedMessage:_MessageContent:Text
				EndIf
				
				//������������������������������������������������������������������������Ŀ
				//Insere / Atualiza o registro na tabela XXF (de/para)                     �
				//��������������������������������������������������������������������������
				
				If lRet
					CFGA070Mnt(cProduct, cAliasXXF, cField, cValExt, cValInt, .F.,)
				EndIf
		
		//������������������������������������������������������������������������Ŀ
		//Tratamento para o erro no arquivo de XML recebido.                       �
		//��������������������������������������������������������������������������
		Else
			cAux := "Opera��o n�o realizada - Problemas na integra��o: "
			If IsInCallStack('GPEA240')
				lErroInt := .T.
			EndIf
			//Verifica o erro que aconteceu na integracao.
			cAux += oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_ListOfMessages:_Message:Text
			Alert(cAux)
		EndIf
		
	EndCase
	
//������������������������������������������������������������������������Ŀ
//� Tratamento do envio da mesagem EmployeeSituation.                      �
//��������������������������������������������������������������������������
ElseIf nTypeTrans == TRANS_SEND

	//������������������������������������������������������������������������Ŀ
	//� Verifica de onde foi chamada a FwIntegDef e se foi exclusao ou inclusao�
	//��������������������������������������������������������������������������
	If IsInCallStack('GPEM630')
		cOrigem   := 'GPEM630'
		cEvent    :=  'upsert'
			
	Else
	
		Do Case
			//Afastamento
			Case IsInCallStack('GPEA240') .OR. IsInCallStack('MDTA410')	//MDTA = ROTINA DE ATESTADO MEDIDO DO SIGAMDT
				cOrigem   	:= 'GPEA240'
				oModel 		:= FWModelActive()  
				nOperacao  	:= oModel:GetOperation()
				oGridSr8 	:= oModel:GetModel('GPEA240_SR8') 
				cEvent    	:= If(nOperacao == MODEL_OPERATION_DELETE .Or. lExcAfastPIMS , 'delete' , 'upsert' )
				If !FP_CodFol( @aCodFol , xFilial("SRV"))
					aCodFol := {}
				EndIf	
			//Rescisao
			Case IsInCallStack('GPEM040')
				cOrigem   := 'GPEM040'
				oModel := FWModelActive()  
				nOperacao  	:= oModel:GetOperation()  
				cEvent    := If(nOperacao == MODEL_OPERATION_DELETE  , 'delete' , 'upsert' )
				dbSelectArea("SRA")
				SRA->(dbSetOrder(1))
				SRA->(dbSeek(SRG->RG_FILIAL+SRG->RG_MAT))
				cFilAnt := SRA->RA_FILIAL
			//Ferias
			Case IsInCallStack('GPEM030')
				cOrigem   := 'GPEM030'
				cEvent    := If(lExcFerPIMS , 'delete' , 'upsert' )
				
			//Ferias Coletivas.
			Case IsInCallStack('GPEM060')
				cOrigem   := 'GPEM060'
				
				If Type('lExcFerPIMS') <> "U" 
					cEvent := If(lExcFerPIMS , 'delete' , 'upsert' )
				Else
					cEvent := 'upsert'
				EndIf
			
			//Reintegracao.	
			Case IsInCallStack('GPEA810')
				cOrigem   := 'GPEA810'
				cEvent    := 'upsert'
				
			//Altera��o
			Case IsInCallStack('GPEA010')
				cOrigem   := 'GPEA010'
				cEvent    := 'upsert'
			Otherwise
				cOrigem   := 'GPEM040'
				cEvent    := 'upsert'
				dbSelectArea("SRA")
				SRA->(dbSetOrder(1))
				SRA->(dbSeek(SRG->RG_FILIAL+SRG->RG_MAT))
				cFilAnt := SRA->RA_FILIAL
		EndCase
	EndIf

	If cEvent == 'delete'
	
			//Exclusao da tabela XXF(de/para)
			CFGA070Mnt(Nil,;//Marca
			 	       cAliasXXF,;//Alias
			 	       cField,;//Campo
			 	       Nil,;//Id Externo
			 	       InternalID(cOrigem),;//InternalId.
			 	       .T.)//.T. para exclusao.
	EndIf

	//������������������������������������������������������������������������Ŀ
	//�Construcao do XML de envio(Informacoes do evento).                      �
	//��������������������������������������������������������������������������	
	cXMLRet += '<BusinessEvent>'
	cXMLRet +=    '<Entity>EmployeeSituations</Entity>'
	cXMLRet +=    '<Event>' + cEvent+ '</Event>'
	cXMLRet += 	'<Identification>'
	cXMLRet += 		'<key name="InternalID"></key>' 
	cXMLRet += 	'</Identification>'
	cXMLRet += '</BusinessEvent>'
	//������������������������������������������������������������������������Ŀ
	//�Construcao do XML de envio(Conteudo do negocio).                        �
	//��������������������������������������������������������������������������
	cXMLRet += '<BusinessContent>'
	cXMLRet += '<Situation>'
	cXMLRet += 	'<ListOfEmployee>'
	cXMLRet += 		'<Employee>'
	cXMLRet += 			'<CompanyId>' + cEmpAnt + '</CompanyId>' //Empresa. 
	cXMLRet += 			'<BranchId>' + cFilAnt + '</BranchId>'//Filial.
	cXMLRet += 			'<CompanyInternalId>' + cEmpAnt + "|" + /*AllTrim*/(cFilAnt) + '</CompanyInternalId>'//InternalId da chave completa de empresa do produto.
	cXMLRet += 			'<InternalId>' + InternalID(cOrigem) + '</InternalId>'//InternalId do Code.
	cXMLRet += 			'<EmployeeCode>' + SRA->RA_MAT + '</EmployeeCode>'//C�digo do Funcion�rio.
	cXMLRet += 			'<WorkCenterCode></WorkCenterCode>'//Centro de Trabalho.
	cXMLRet += 			'<SiteCode></SiteCode>'//C�digo do Estabelecimento do Funcion�rio.
	cXMLRet += 			'<ListOfSituation>'
	cXMLRet +=				'<Situation>'
	cXMLRet += 					'<CommencementDate>' + CommencDate(cOrigem) + '</CommencementDate>'//Data de in�cio da situa��o.
	cXMLRet += 					'<SituationLastDay>' + SitLastDay(cOrigem) + '</SituationLastDay>'//Data do �ltimo dia da situa��o.
	cXMLRet += 					'<INSSPaymentCommencement>' + /*INSSPayCom(cOrigem)*/'</INSSPaymentCommencement>'
	cXMLRet += 					'<OriginSituation>' + OriginSitu(cOrigem) + '</OriginSituation>'//Origem da Situa��o.
	cXMLRet += 					'<SituationDay>' + SituatDay(cOrigem) + '</SituationDay>'//N�mero de dias em que o funcion�rio se encontra na situa��o.
	cXMLRet += 					'<SituationTime></SituationTime>'//Quantidade de horas na situa��o.
	cXMLRet += 					'<SituationScheduleEnd></SituationScheduleEnd>'//N�mero Horario Termino Situacao Afastamento.
	cXMLRet += 					'<CIDCode>' + CIDCode(cOrigem) + '</CIDCode>'//C�digo do acidente ou doen�a para as situa��es de afastamento por doen�a.
	cXMLRet += 					'<CommencementSchedule></CommencementSchedule>'//N�mero Horario Inicio Situacao Afastamento.
	cXMLRet += 					'<SituationInformation>'
	cXMLRet +=                     '<SituationCode>' + SitCode(cOrigem) + '</SituationCode>'
	cXMLRet += 						'<SituationMeaning>' + SituatMean(cOrigem,cEvent) + '</SituationMeaning>'
	cXMLRet += 						'<AbsenteeismType>' + AbseentType(cOrigem) + '</AbsenteeismType>'
	cXMLRet +=                  '</SituationInformation>'
	cXMLRet +=				'</Situation>'			
	cXMLRet += 			'</ListOfSituation>'	
	cXMLRet += 		'</Employee>'
	cXMLRet += 	'</ListOfEmployee>'
	cXMLRet += '</Situation>'
	cXMLRet += '</BusinessContent>'
EndIf	

Return({lRet,cXMLRet})


/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � InternalID � Autor � Alberto M.           � Data � 31/12/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Preenchimento da tag <InternalID> da mensagem               ���
���          � EmployeeSituation.                                          ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.���
��������������������������������������������������������������������������Ĵ��
��� Uso      � GPEI041                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function InternalID (cOrigem)

Local cTag := ''
Default cOrigem := ''

Do Case
	Case cOrigem == 'GPEA240'//Afastamento.
		cTag := cEmpAnt + '|' + xFilial("SR8") + '|' + SR8->R8_MAT + '|' + SituatMean (cOrigem) + '|' + CommencDate(cOrigem, .T.) + '|' + oGridSr8:GetValue("R8_SEQ")
	Case cOrigem == 'GPEM040'//Rescis�o.
		cTag := cEmpAnt + '|' + xFilial("SRG") + '|' + SRG->RG_MAT + '|' + SituatMean (cOrigem) + '|' + CommencDate(cOrigem, .T.) + '|' + '1'
	Case cOrigem == 'GPEM630'//Rescis�o Coletiva.
		cTag := cEmpAnt + '|' + xFilial("SRA") + '|' + SRA->RA_MAT + '|' + SituatMean (cOrigem) + '|' + CommencDate(cOrigem, .T.) + '|' + '1'
	Case cOrigem == 'GPEM030'//F�rias.
		cTag := cEmpAnt + '|' + xFilial("SRH") + '|' + SRH->RH_MAT + '|' + SituatMean (cOrigem) + '|' + CommencDate(cOrigem, .T.) + '|' + SR8->R8_SEQ
	Case cOrigem == 'GPEM060'//F�rias Coletivas.
		cTag := cEmpAnt + '|' + xFilial("SRH") + '|' + SRH->RH_MAT + '|' + SituatMean (cOrigem) + '|' + CommencDate(cOrigem, .T.) + '|' + SR8->R8_SEQ
	Case cOrigem == 'GPEA810'//Reintegra��o.
		cTag := cEmpAnt + '|' + xFilial("SRA") + '|' + SRA->RA_MAT + '|' + SituatMean (cOrigem) + '|' + CommencDate(cOrigem, .T.) + '|' + '1'
	Case cOrigem == 'GPEA010'//Altera��o.
		cTag := cEmpAnt + '|' + xFilial("SRA") + '|' + SRA->RA_MAT + '|' + SituatMean (cOrigem) + '|' + CommencDate(cOrigem, .T.) + '|' + '1'
EndCase

Return(cTag)

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � CommencDate � Autor � Alberto M.          � Data � 31/12/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Preenchimento da tag <CommencementDate> da mensagem         ���
���          � EmployeeSituation, tambem possui tratamento para auxiliar na���
���          � construcao da tag <InternalID>                              ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.���
���          � lInternalID = Caso seja preenchimento da tag<InternalID> vem���
���          � como verdadeiro(.T.), caso nao sera falso(.F.)              ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � GPEI041                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static function CommencDate (cOrigem, lInternalID)

Local cTag          := ''
Local cAux          := ''

Default lInternalID := .F.
Default cOrigem     := ''

Do Case

	//Afastamento.
	Case cOrigem == 'GPEA240'
	
		If !Empty(oGridSr8:GetValue("R8_DATAINI"))
			
			If nAfastEAI > 0
				cAux := DToS(BuscaIni(oGridSr8, oGridSr8:GetLine()))
			Else
				cAux  := DtoS(oGridSr8:GetValue("R8_DATAINI"))
			EndIf
			
			//InternalID informa data sem as barras.		
			If lInternalID 
				cTag := Substr(cAux,7,2) + Substr(cAux,5,2) + Substr(cAux,1,4)
			//Caso seja TAG CommencDate informa data com barras.
			Else 
				cTag := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2)
			EndIf
		Else
			cTag := cAux
		EndIf

	//Rescisao.
	Case cOrigem == 'GPEM040'
	
		If !Empty(SRG->RG_DATADEM)
			cAux := DtoS(SRG->RG_DATADEM)
			//InternalID informa data sem as barras.
			If lInternalID
				cTag := Substr(cAux,7,2) + Substr(cAux,5,2) + Substr(cAux,1,4)
			//Caso seja TAG CommencDate informa data com barras.
			Else
				cTag := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2)
			EndIf
			
		Else
			cTag := cAux
		EndIf
		 
	//Rescisao Coletiva.
	Case cOrigem == 'GPEM630'
	
		If !Empty(SRA->RA_DEMISSA)
			cAux := DtoS(SRA->RA_DEMISSA)
			//InternalID informa data sem as barras.
			If lInternalID
				cTag := Substr(cAux,7,2) + Substr(cAux,5,2) + Substr(cAux,1,4)
			//Caso seja TAG CommencDate informa data com barras.
			Else
				cTag := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2)
			EndIf
		Else
			cTag := cAux
		EndIf
	
	//Ferias.
	Case cOrigem == 'GPEM030'
	
		If !Empty(SRH->RH_DATAINI)
			cAux := DtoS(SRH->RH_DATAINI)
			//InternalID informa data sem as barras.
			If lInternalID 
				cTag := Substr(cAux,7,2) + Substr(cAux,5,2) + Substr(cAux,1,4)
			//Caso seja TAG CommencDate informa data com barras.
			Else 
				cTag := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2)
			EndIf
		Else
			cTag := cAux
		EndIf
	
	//Ferias Coletivas.
	Case cOrigem == 'GPEM060'
		If !Empty(SRH->RH_DATAINI)
			cAux := DtoS(SRH->RH_DATAINI)
			//InternalID informa data sem as barras.
			If lInternalID
				cTag := Substr(cAux,7,2) + Substr(cAux,5,2) + Substr(cAux,1,4)
			//Caso seja TAG CommencDate informa data com barras.
			Else
				cTag := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2)
			EndIf
		Else
			cTag := cAux
		EndIf
	
	//Reintegracao.
	Case cOrigem == 'GPEA810'
	
		If !Empty(SRA->RA_FECREI)
			cAux := DtoS(SRA->RA_FECREI)
			 //InternalID informa data sem as barras.
			If lInternalID
				cTag := Substr(cAux,7,2) + Substr(cAux,5,2) + Substr(cAux,1,4)
			 //Caso seja TAG CommencDate informa data com barras.
			Else
				cTag := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2)
			EndIf
		Else
			cTag := cAux
		EndIf
	
	
	Case cOrigem == 'GPEA010'//Altera��o.
		cAux := DtoS(Date())
		
		If lInternalID //InternalID informa data sem as barras.
			cTag := Substr(cAux,7,2) + Substr(cAux,5,2) + Substr(cAux,1,4)
		Else //Caso seja TAG CommencDate informa data com barras.
			cTag := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2)
		EndIf

EndCase

Return(cTag)

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � SitLastDay � Autor � Alberto M.           � Data � 31/12/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Preenchimento da tag <SituationLastDay> da mensagem         ���
���          � EmployeeSituation.                                          ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.���
��������������������������������������������������������������������������Ĵ��
��� Uso      � GPEI041                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static function SitLastDay (cOrigem)

Local cTag := ''
Local cAux := ''

Do Case
	Case cOrigem == 'GPEA240'//Afastamento.
	
		If !Empty(oGridSr8:GetValue("R8_DATAFIM"))
			cAux := DtoS(oGridSr8:GetValue("R8_DATAFIM"))
			cAux := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2)
		EndIf
		
		cTag := cAux
		 
	Case cOrigem == 'GPEM040'//Rescis�o.
		cTag := cAux
	Case cOrigem == 'GPEM630'//Rescis�o Coletiva.
		cTag := cAux
	Case cOrigem == 'GPEM030'//F�rias.
	
		If !Empty(SRH->RH_DATAFIM)
			cAux := DtoS(SRH->RH_DATAFIM)
			cAux := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2)
		EndIf
	
		cTag := cAux
		
	Case cOrigem == 'GPEM060'//F�rias Coletivas.
	
		If !Empty(SRH->RH_DATAFIM)
			cAux := DtoS(SRH->RH_DATAFIM)
			cAux := Substr(cAux,1,4) + '-' + Substr(cAux,5,2) + '-' + Substr(cAux,7,2)
		EndIf

		cTag := cAux
		
	Case cOrigem == 'GPEA810'//Reintegra��o.
		cTag := ''
	Case cOrigem == 'GPEA010'//Altera��o.
		cTag := ''
EndCase

Return(cTag)
/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � INSSPayCom � Autor � Alberto M.           � Data � 31/12/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Preenchimento da tag <INSSPaymentCommencement> da mensagem  ���
���          � EmployeeSituation.                                          ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.���
��������������������������������������������������������������������������Ĵ��
��� Uso      � GPEI041                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
//Preenchimento da TAG <INSSPaymentCommencement>.
Static function INSSPayCom (cOrigem)

Local cTag    := ''


Do Case
	Case cOrigem == 'GPEA240'//Afastamento.
		cTag := ''
	Case cOrigem == 'GPEM040'//Rescis�o.
		cTag := ''
	Case cOrigem == 'GPEM630'//Rescis�o Coletiva.
		cTag := ''
	Case cOrigem == 'GPEM030'//F�rias.
		cTag := ''
	Case cOrigem == 'GPEM060'//F�rias Coletivas.
		cTag := ''
	Case cOrigem == 'GPEA810'//Reintegra��o.
		cTag := ''
	Case cOrigem == 'GPEA010'//Altera��o.
		cTag := ''
	
EndCase

Return(cTag)
/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � OriginSitu � Autor � Alberto M.           � Data � 31/12/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Preenchimento da tag <OriginSituation> da mensagem          ���
���          � EmployeeSituation.                                          ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.���
��������������������������������������������������������������������������Ĵ��
��� Uso      � GPEI041                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
//Preenchimento da TAG <OriginSituation>.
Static function OriginSitu (cOrigem)

Local cTag := ''

Do Case
	Case cOrigem == 'GPEA240'//Afastamento.
		cTag := '1'
	Case cOrigem == 'GPEM040'//Rescis�o.
		cTag := '2'
	Case cOrigem == 'GPEM630'//Rescis�o Coletiva.
		cTag := '2'
	Case cOrigem == 'GPEM030'//F�rias.
		cTag := '2'
	Case cOrigem == 'GPEM060'//F�rias Coletivas.
		cTag := '2'
	Case cOrigem == 'GPEA810'//Reintegra��o.
		cTag := '1'
	Case cOrigem == 'GPEA010'//Altera��o.
		cTag := '1'
EndCase

Return(cTag)
/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � SituatDay � Autor � Alberto M.           � Data � 31/12/14  ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Preenchimento da tag <SituationDay> da mensagem             ���
���          � EmployeeSituation.                                          ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.���
��������������������������������������������������������������������������Ĵ��
��� Uso      � GPEI041                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
//Preenchimento da TAG <SituationDay>.
Static function SituatDay (cOrigem)

Local cTag 	:= ''
Local nDias := 0

Do Case
	Case cOrigem == 'GPEA240'//Afastamento.
		If ! Empty(nAfastEAI)
			BuscaIni(oGridSr8, oGridSr8:getLine(), @nDias)
			cTag := AllTrim(Str(nDias))
		Else
			cTag := If( Empty(oGridSr8:GetValue("R8_DATAFIM")) , '0' , AllTrim(Str(oGridSr8:GetValue("R8_DURACAO"))) )
		EndIf
	Case cOrigem == 'GPEM040'//Rescis�o.
		cTag := '0'
	Case cOrigem == 'GPEM630'//Rescis�o Coletiva.
		cTag := '0'
	Case cOrigem == 'GPEM030'//F�rias.
		cTag := AllTrim(Str(SRH->RH_DFERIAS))
	Case cOrigem == 'GPEM060'//F�rias Coletivas.
		cTag := AllTrim(Str(SRH->RH_DFERIAS))
	Case cOrigem == 'GPEA810'//Reintegra��o.
		cTag := '0'
	Case cOrigem == 'GPEA010'//Altera��o.
		cTag := '0'
EndCase

Return(cTag)
/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � CIDCode    � Autor � Alberto M.           � Data � 31/12/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Preenchimento da tag <CIDCode> da mensagem                  ���
���          � EmployeeSituation.                                          ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.���
��������������������������������������������������������������������������Ĵ��
��� Uso      � GPEI041                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
//Preenchimento da TAG <CIDCode>.
Static function CIDCode (cOrigem)

Local cTag := ''

	If cOrigem == 'GPEA240'//Afastamento.
	
		If !Empty(oGridSr8:GetValue("R8_CID"))
			cTag := oGridSr8:GetValue("R8_CID")
		Else
			cTag := ''
		EndIf
	
	//'GPEM040' - 'GPEM630' - 'GPEM030' - 'GPEM060' - 'GPEA810' - 'GPEA010'
	Else
		cTag := ''
	EndIf

Return(cTag)

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � SituatMean � Autor � Alberto M.           � Data � 31/12/14 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Preenchimento da tag <SituationMeaning> da mensagem         ���
���          � EmployeeSituation.                                          ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.���
��������������������������������������������������������������������������Ĵ��
��� Uso      � GPEI041                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static function SituatMean (cOrigem,cEvent)

Local cTag := ''
Local cAux := ''
Default cEvent:= ''

	Do Case
		//Afastamento.
		Case cOrigem == 'GPEA240' 
			cAux := gp240RetCont("RCM", 1, xFilial("RCM") + oGridSr8:GetValue("R8_TIPOAFA"), "RCM_TIPOAF")
			cAux := If (cAux == '4', '5' , '2')
		
		//Rescisao ou Rescisao Coletiva.
		Case cOrigem == 'GPEM040' .Or. cOrigem == 'GPEM630'
			If !cEvent == 'delete'
				cAux := '6'
			Else
				cAux := '1'
			EndIf
		//Ferias ou Ferias Coletivas.
		Case cOrigem == 'GPEM030' .Or. cOrigem == 'GPEM060'
			cAux := '5' 
		
		//Reintegra�ao.
		Case cOrigem == 'GPEA810'
			cAux := '1'
		
		Case cOrigem == 'GPEA010'//Altera��o.
			Do Case
				Case SRA->RA_SITFOLH == ' '
					cAux := '1'
				Case SRA->RA_SITFOLH == 'A'
					cAux := '2'
				Case SRA->RA_SITFOLH == 'D'
					cAux := '6'
				Case SRA->RA_SITFOLH == 'F'
					cAux := '5'
				Case SRA->RA_SITFOLH == 'T'
					cAux := '6'
			EndCase		
	EndCase

	cTag := cAux

Return(cTag)

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � AbseentType � Autor � Alberto M.           � Data � 31/12/14���
��������������������������������������������������������������������������Ĵ��
���Descricao � Preenchimento da tag <AbsenteeismType> da mensagem          ���
���          � EmployeeSituation.                                          ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.���
��������������������������������������������������������������������������Ĵ��
��� Uso      � GPEI041                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
//Preenchimento da TAG <AbsenteeismType>.
Static function AbseentType (cOrigem)

Local cTag := ''
Local cAux := '1'
Local cTipo := ""
Local cVerba := ""

	//Afastamento.
	If cOrigem == 'GPEA240'
		cTipo := gp240RetCont("RCM", 1, xFilial("RCM") + oGridSr8:GetValue("R8_TIPOAFA"), "RCM_CODSEF")
		cVerba := gp240RetCont("RCM", 1, xFilial("RCM") + oGridSr8:GetValue("R8_TIPOAFA"), "RCM_PD")
		cAux := Y240TIPO1(cTipo,cVerba)
	EndIf

	cTag := cAux

Return(cTag)

/*����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � SitCode � Autor � Alberto M.           � Data � 31/12/14���
��������������������������������������������������������������������������Ĵ��
���Descricao � Preenchimento da tag <SitCode> da mensagem          ���
���          � EmployeeSituation.                                          ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cOrigem = Nome do fonte que a funcao FwIntegDef foi chamada.���
��������������������������������������������������������������������������Ĵ��
��� Uso      � GPEI041                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static function SitCode (cOrigem)

Local cTag := ''
Local cAux := '2'
Local cTipo := ""
Local cVerba := ""

	//Afastamento.
	If cOrigem == 'GPEA240'
		cTipo := gp240RetCont("RCM", 1, xFilial("RCM") + oGridSr8:GetValue("R8_TIPOAFA"), "RCM_CODSEF")
		cVerba := gp240RetCont("RCM", 1, xFilial("RCM") + oGridSr8:GetValue("R8_TIPOAFA"), "RCM_PD")
		cAux := Y240TIPO2(cTipo,cVerba)
	ElseIf cOrigem == 'GPEA810'
		cAux := '1'
	EndIf

	cTag := cAux

Return(cTag)

Static Function Y240TIPO1(cTipo,cVerba)
Local cAux := "1"
Local aTipoXml := { "2", "3", "4", "4", "4", "4","6","8"}
Local aTipo :=    {"P1","O1","Q1","Q4","Q5","Q6","R","X2"}
Local nPos := 0

If cAux == "1" .And. cVerba == aCodFol[103,1] //Licen�a Remunerada
	cAux := "7"
Endif

nPos := Ascan(aTipo,{|x| Alltrim(x)==alltrim(cTipo)})
If nPos > 0 
	cAux := aTipoXml[nPos]
EndIf

Return cAux

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Y240TIPO2�    Autor �Christiane Vieira � Data �  02/12/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     �De/Para do campo Situation Code                             ���
�������������������������������������������������������������������������͹��
���Sintaxe   �cTipo => C�digo SEFIP - Protheus V12                        ���
���          �cVerb => C�digo Verba                                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Y240TIPO2(cTipo, cVerba)
Local cAux := "A"
Local aTipoXml := {"P",  "O", "Q", "B", "6", "7","R","X"}
Local aTipo :=    {"P1","O1","Q1","Q4","Q5","Q6","R","X"}
Local nPos := 0

If cAux == "A" .And. cVerba == aCodFol[103,1] //Licen�a Remunerada
	cAux := "8"
Endif

nPos := Ascan(aTipo,{|x| Alltrim(x)==alltrim(cTipo)})
If nPos > 0 
	cAux := aTipoXml[nPos]
EndIf

Return cAux