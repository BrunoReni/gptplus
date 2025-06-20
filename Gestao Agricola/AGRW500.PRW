#Include 'PROTHEUS.CH'
#Include 'AGRW500.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integra��o com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC

#Define MAX_FILE_LENGTH 600	//Tamanho maximo permitido para o XML gerado (em KB)


/*/{Protheus.doc} IntegDef
//O AGR500 realiza o envio de um unico fardao para ser integrado.
//IMPORTANTE: Envia o que est� posicionado na DX0
//Executa a funcao de integracao.
@author carlos.augusto
@since 27/03/2018
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
	Local aRet 		:= {}

	aRet:= AGRWI500( cXml, nTypeTrans, cTypeMessage )
	
Return aRet


/*/{Protheus.doc} AGRWI500
//Integra��o Recepcao de Materia Prima
@author carlos.augusto
@since 27/03/2018
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Function AGRWI500( cXML, nTypeTrans, cTypeMessage)
	Local aLines	:= FWSaveRows()		//Salva contexto do model ativo
	Local aArea   	:= GetArea()
	Local aRet 		  := {}				//Array de retorno da fun��o
	Local lRet 		  := .T.			//Indica o resultado da execu��o da fun��o
	Local cXMLRet	  := ''				//Xml que ser� enviado pela fun��o
	Local cError	  := ''				//Mensagem de erro do parse no xml recebido como par�metro
	Local cWarning	  := ''				//Mensagem de alerta do parse no xml recebido como par�metro

	//--- Variaveis do Retorno - Fun��o CFGA070Mnt [http://tdn.totvs.com/pages/viewpage.action?pageId=173083053]
	Local oXML			:= Nil				//Objeto com o conte�do do arquivo Xml
	Local oXMLContent	:= Nil				//Objeto com o conte�do da BusinessContent apenas
	Local cReferen    	:= ''				//Referencia. Normalmente a "marca" da mensagem: PROTHEUS / LOGIX / RM / DATASUL, etc.
	Local cValInt		:= ""
	Local cValExt		:= ""
	Local aParEntr 		:= {Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil}
	Local dDataMov
	Local dData1
	Local cHora1		:= ""
	Local dData2
	Local cHora2		:= ""
	Local cCodLoc		:= ""
	Local cCodMot		:= ""
	Local cCodOper		:= ""
	Local cCodNF		:= ""
	Local cCodSerNF		:= ""
	Local cCodFardao	:= ""
	Local nPesBruto		:= 0
	Local nPesTara		:= 0
	Local nPesDesc		:= 0
	Local cOrdCol		:= ""
	Local cCodRom		:= ""
	Local nCount
	
	Local oNJJ
	Local nQtdFardao		:= 0
	Local cCodUni		:= ""
	Local cBoletim
	Local lAlgodao		:= .F.
	
	Private _cCLTTEMP //Cria a Temp Table de Consulta de Ordem de Colheita
	Private _oModel
	Private _nOperat
	Private _cOperat
	Private _oMldDX0
	//*************************************
	// Trata o recebimento de mensagem                              
	//*************************************
	If ( nTypeTrans == TRANS_RECEIVE )

		//*********************************
		// Recebimento da Business Message
		//*********************************
		If ( cTypeMessage == EAI_MESSAGE_BUSINESS )

			//Simulacao do PIMS INICIO

			//-- Monta o XML de Retorno
//			cXmlRet := "<ProcessedOn>2018-02-03T01:13:51Z</ProcessedOn>"
//			cXmlRet += "<Status>error</Status>"

			//Um item:
			cXmlRet := "<ListOfInternalId>"
			cXmlRet +=    "<InternalId>"
			cXmlRet +=       "<Name>WeighingRawMaterials</Name>"
			cXmlRet +=       "<Origin>D MG 01 |Rom. Enviado</Origin>"
			cXmlRet += 		 "<Destination>D MG 01 |Rom. no Destino</Destination>"
			cXmlRet +=    "</InternalId>"
			cXmlRet += "</ListOfInternalId>"

			//Ou lista:
//			conout("RECEBIDO FARDAOOOOOOOOOO")
//			cXmlRet := "<ListOfInternalId>"
//			cXmlRet +=    "<InternalId>"
//			cXmlRet +=       "<Name>WeighingRawMaterials</Name>"
//			cXmlRet +=       "<Origin>D MG 01| AABB</Origin>"
//			cXmlRet += 		 "<Destination>D MG 01| ID00AABB</Destination>"
//			cXmlRet +=    "</InternalId>"
//			
//			cXmlRet +=    "<InternalId>"
//			cXmlRet +=       "<Name>WeighingRawMaterials</Name>"
//			cXmlRet +=       "<Origin>D MG 01| CCDD</Origin>"
//			cXmlRet += 		 "<Destination>D MG 01| ID00CCDD</Destination>"
//			cXmlRet +=    "</InternalId>"
//			
//			cXmlRet +=    "<InternalId>"
//			cXmlRet +=       "<Name>WeighingRawMaterials</Name>"
//			cXmlRet +=       "<Origin>D MG 01| EEFF</Origin>"
//			cXmlRet += 		 "<Destination>D MG 01| ID00EEFF</Destination>"
//			cXmlRet +=    "</InternalId>"
//			cXmlRet += "</ListOfInternalId>"

		ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )

			//--Faz o parser do XML de retorno em um objeto
			oXML := xmlParser(cXML, "_", @cError, @cWarning)
			oXMLContent := oXML:_TOTVSMessage:_ResponseMessage:_ReturnContent

			// Se n�o houve erros no parse
			If oXML <> Nil .And. Empty(cError) .And. Empty(cWarning)
			
				//-- Verifica se a marca foi informada
				If Type("oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text") = "U" .And. !Empty(oXML:_TotvsMessage:_MessageInformation:_Product:_Name:Text)
					cReferen := oXML:_TOTVSMessage:_MessageInformation:_Product:_name:Text
				Else
					lRet := .F.
					cXmlRet := STR0001 //'Erro no retorno. A Referencia/Marca � obrigat�ria!'
					//Carrega array de retorno
					aRet := {lRet, cXmlRet,  "WEIGHINGRAWMATERIALS" } 
					Return aRet
				EndIf

				If oXml:_TOTVSMessage:_ResponseMessage:_ProcessingInformation:_Status:Text = "OK"

					DefOperat()

					If ValType(oXMLContent:_ListOfInternalId) == "A" //Quando eh mais de um elemento, vem array

						For nCount := 1 To Len(oXMLContent:_ListOfInternalId:_InternalId)
							cValInt := oXMLContent:_ListOfInternalId:_InternalId[nCount]:_Origin:Text
							cValExt := oXMLContent:_ListOfInternalId:_InternalId[nCount]:_Destination:Text

							CriaDePara(cReferen, "NJJ", "NJJ_CODROM", cValExt, cValInt, _cOperat)

						Next nCount

					ElseIf ValType(oXMLContent:_ListOfInternalId) == "O" //Quando eh um elemento, vem objeto

						cValInt := oXMLContent:_ListOfInternalId:_InternalId:_Origin:Text
						cValExt := oXMLContent:_ListOfInternalId:_InternalId:_Destination:Text

						CriaDePara(cReferen, "NJJ", "NJJ_CODROM", cValExt, cValInt, _cOperat)
					EndIf
				Else
					lRet := .F.
					cXmlRet := STR0002 // "Evento do retorno inv�lido!"
				EndIf
			Else
				lRet := .F.
				cXmlRet := STR0003 //"Erro no parser do retorno!"
				Return {lRet, cXmlRet}
			EndIf

			//--------------------------------------------
			//--- RECEBIMENTO DA WHOIS   
			//--------------------------------------------			
		ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )
			cXMLRet := "1.000|1.001|1.002"
		EndIf

	ElseIf ( nTypeTrans == TRANS_SEND )

		DefOperat()
		oNJJ 	 	:= IIF(IsInCallStack("AGRA500") .Or. IsInCallStack("AGRA500POP"), _oModel:GetModel( "AGRA500_NJJ" ), _oModel:GetModel( "NJJUNICO" ))

		lAlgodao := if(Posicione("SB5",1,fwxFilial("SB5")+oNJJ:GetValue( "NJJ_CODPRO" ),"B5_TPCOMMO")== '2',.T.,.F.)
		
		_oMldDX0 	:= _oModel:GetModel( "AGRA500_DX0" ) 
		cCodFardao	:= _oMldDX0:GetValue("DX0_FARDAO")
		
		cCodUni		:= _oMldDX0:GetValue( "DX0_CODUNI" )
		nQtdFardao 	:= _oMldDX0:Length(.T.)
		
		cOrdCol	 	:= oNJJ:GetValue("NJJ_ORDCLT")
		cCodRom  	:= oNJJ:GetValue("NJJ_CODROM")
		dDataMov 	:= oNJJ:GetValue("NJJ_DATA")
		dData1	 	:= oNJJ:GetValue("NJJ_DATPS1")
		cHora1   	:= oNJJ:GetValue("NJJ_HORPS1")
		dData2	 	:= oNJJ:GetValue("NJJ_DATPS2")
		cHora2   	:= oNJJ:GetValue("NJJ_HORPS2")
		cCodLoc		:= oNJJ:GetValue("NJJ_LOCAL")
		cCodMot		:= oNJJ:GetValue("NJJ_CODMOT")
		cCodOper	:= RetCodUsr()
		cCodNF		:= oNJJ:GetValue("NJJ_DOCNUM")
		cCodSerNF	:= oNJJ:GetValue("NJJ_DOCSER")
		cPlaca		:= oNJJ:GetValue("NJJ_PLACA")
		
		nPesBruto	:= _oMldDX0:GetValue( "DX0_PSBRUT" )
		nPesTara	:= _oMldDX0:GetValue( "DX0_TARA" )
		nPesDesc	:= _oMldDX0:GetValue( "DX0_PSDESC" )
		
		If !Empty(dDataMov)
			aParEntr[3]  := SubStr(DTOS(dDataMov), 1, 4) + '-' + SubStr(DTOS(dDataMov), 5, 2) + '-' + SubStr(DTOS(dDataMov), 7, 2)	//3-Data da Movimenta��o   MovementDate
		EndIf
		If !Empty(dData1)
			aParEntr[4]	 :=	SubStr(DTOS(dData1), 1, 4) + '-' + SubStr(DTOS(dData1), 5, 2) + '-' + SubStr(DTOS(dData1), 7, 2) + 'T' + cHora1 + ":00"	//4-Data e Hora da 1.� Pesagem EntryDate
		EndIf
		If !Empty(dData2)
			aParEntr[5]	 :=	SubStr(DTOS(dData2), 1, 4) + '-' + SubStr(DTOS(dData2), 5, 2) + '-' + SubStr(DTOS(dData2), 7, 2) + 'T' + cHora2	+ ":00"//5-Data e Hora da 2.� Pesagem ExitDate
		EndIf
		
		
		If Val(_oMldDX0:GetValue("DX0_BOLETI")) = 0
			cBoletim := AGRX500IBT(cCodUni)
			_oMldDX0:SetValue( "DX0_BOLETI" ,cBoletim)
		Else
			cBoletim := _oMldDX0:GetValue("DX0_BOLETI")
		EndIf

		aParEntr[6]	 :=	cOrdCol		//6-N�mero da Ordem e Colheita - PIMS                HarvestOrderCodePIMS
		aParEntr[7]	 :=	cCodRom		//7-N�mero da Ordem e Colheita                       HarvestOrderCode
		aParEntr[12] :=	cCodLoc 	//12-Codigo do Local de Estoque(Armazem)              WarehouseCode
		aParEntr[13] :=	cCodMot		//14-C�digo do Motorista no ERP                       DriverCode
		aParEntr[14] :=	cCodOper 	//15-C�digo do Operador no ERP                        OperatorCode
		aParEntr[15] :=	cCodNF		//16-N�mero da Nota Fiscal                            InvoiceNumber
		aParEntr[16] :=	cCodSerNF	//17-N�mero da S�rie                                  InvoiceSerie
		aParEntr[17] :=	nPesBruto  	//18-Peso Bruto                                       GrossWeight
		aParEntr[18] :=	nPesTara 	//19-Peso Tara                                        TaraWeight
		aParEntr[19] :=	nPesDesc 	//20-Total Impurezas                                  ImpurityTotal
		
		If lAlgodao
			dbSelectArea( "DXL" )
			DXL->(dbSetOrder( 2 ))
			If DXL->(dbSeek( fwxFilial( "DXL" ) + cCodUni ) )  
				aParEntr[23] := DXL->DXL_PSESTI
			EndIf
			aParEntr[24] := cCodFardao					//24-N�mero do Fard�o                                 PackNumber
		EndIf

		aParEntr[25] :=	cValToChar(Val(cBoletim))		//25-N�mero do boletim da Pesagem Externa (Romaneio)  WeighingBulletinNumber
		aParEntr[26] :=	cPlaca						//13-C�digo do Equipamento no PIMSMulticultivos       EquipmentCode
		
		cXMLRet := GeraXmlEnv(aParEntr)
		
	EndIf

	aRet := {lRet, cXmlRet, "WEIGHINGRAWMATERIALS"}

	FwRestRows(aLines)
	RestArea(aArea)
Return aRet


/*/{Protheus.doc} CriaDePara
//Grava XXF
@author carlos.augusto
@since 13/02/2018
@version undefined
@param cProduct, characters, descricao
@param cAliasTab, characters, descricao
@param cField, characters, descricao
@param cValExt, characters, descricao
@param cValInt, characters, descricao
@param cOper, characters, descricao
@type function
/*/
Static Function CriaDePara(cProduct, cAliasTab, cField, cValExt, cValInt, cOper)
	Local lRet := .T.
	Local aLines	:= FWSaveRows()		//Salva contexto do model ativo
	Local aArea   	:= GetArea()
	
	If Upper(cOper) == "UPSERT"
		// Insere / Atualiza o registro na tabela XXF (de/para)
		CFGA070Mnt(cProduct, cAliasTab, cField, cValExt, cValInt, .F.,,, "WeighingRawMaterials")
	ElseIf Upper(cOper) == "DELETE"
		// Exclui o registro na tabela XXF (de/para)
		CFGA070Mnt(cProduct, cAliasTab, cField, cValExt, cValInt, .T.,,, "WeighingRawMaterials")
	EndIf
	
	FwRestRows(aLines)
	RestArea(aArea)
Return lRet



/*/{Protheus.doc} AGRX500MPX
//Gera xml para consumir Integra��o Recepcao de Materia Prima
@author carlos.augusto
@since 09/02/2018
@version undefined
@param aDadosEnv, array, descricao
//1-C�digo da empresa                                              CompanyId
//2-C�digo da Filial                                 BranchId
//3-Data da Movimenta��o                             MovementDate
//4-Data e Hora da 1.� Pesagem                       EntryDate
//5-Data e Hora da 2.� Pesagem                       ExitDate
//6-N�mero da Ordem e Colheita - PIMS                HarvestOrderCodePIMS
//7-N�mero da Ordem e Colheita                       HarvestOrderCode
//8-C�digo da Ocupa��o do [Talh�o]                   OccupationCode
//9-C�digo da [Fazenda]                              FarmCode
//10-C�digo do [Setor]                                SectorCode
//11-C�digo do [Talh�o]                               PartOfLandCode
//12-Codigo do Local de Estoque(Armazem)              WarehouseCode
//13-C�digo do Motorista no ERP                       DriverCode
//14-C�digo do Operador no ERP                        OperatorCode
//15-N�mero da Nota Fiscal                            InvoiceNumber
//16-N�mero da S�rie                                  InvoiceSerie
//17-Peso Bruto                                       GrossWeight
//18-Peso Tara                                        TaraWeight
//19-Total Impurezas                                  ImpurityTotal
//20-Data da Ordem de Colheita                        HarvestOrderDate
//21-C�digo do Sistema de Colheita                    HarvestSystemCode
//22-�rea da Ordem de Colheita                        AreaHarvestOrder
//23-Kg/Ha Estimados                                  EstimatedWeight
//24-N�mero do Fard�o                                 PackNumber
//25-N�mero do boletim da Pesagem Externa (Romaneio)  WeighingBulletinNumber
//xx-C�digo do Equipamento no PIMSMulticultivos       EquipmentCode
@type function
/*/
Static Function GeraXmlEnv(aDadosEnv)
	Local cXMLRet := ""
	
	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>WeighingRawMaterials</Entity>'
	cXMLRet +=     '<Event>'+_cOperat+'</Event>'
	cXMLRet += '</BusinessEvent>'
	cXMLRet += '<BusinessContent>'

	If !Empty(aDadosEnv[1])
		cXMLRet +=    '<CompanyId>' + aDadosEnv[1] + '</CompanyId>'  /* Obrigatorio */
	Else
		cXMLRet +=    '<CompanyId>' + FWGrpCompany() + '</CompanyId>'  /* Obrigatorio */
	EndIf
	If !Empty(aDadosEnv[2])
		cXMLRet +=    '<BranchId>'  + aDadosEnv[2] + '</BranchId>'  /* Obrigatorio */
		cXMLRet +=    '<CompanyInternalId>' + aDadosEnv[1] + "|" + aDadosEnv[2] + '</CompanyInternalId>'
	Else
		cXMLRet +=    '<BranchId>'  + FWCodFil() + '</BranchId>'  /* Obrigatorio */
		cXMLRet +=    '<CompanyInternalId>' + FWCodEmp() + "|" + FWCodFil() + '</CompanyInternalId>'
	EndIf

	If !Empty(aDadosEnv[25])
		If !Empty(aDadosEnv[2])
			cXMLRet +=    '<InternalId>'  + aDadosEnv[2] + "|" + AllTrim(aDadosEnv[25]) + "|" + AllTrim(aDadosEnv[7]) + '</InternalId>' //26-N�mero do boletim da Pesagem Externa (Romaneio)
		Else
			cXMLRet +=    '<InternalId>'  + FWCodFil() + "|" + AllTrim(aDadosEnv[25]) + "|" + AllTrim(aDadosEnv[7]) + '</InternalId>'  /* Obrigatorio */
		EndIf
	EndIf

	If !Empty(aDadosEnv[3])
		cXMLRet +=    '<MovementDate>'  + aDadosEnv[3] + '</MovementDate>' //3-Data da Movimenta��o
	EndIf

	If !Empty(aDadosEnv[4])
		cXMLRet +=    '<EntryDate>'  + aDadosEnv[4] + '</EntryDate>' //4-Data e Hora da 1 Pesagem
	EndIf

	If !Empty(aDadosEnv[5])
		cXMLRet +=    '<ExitDate>'  + aDadosEnv[5] + '</ExitDate>' //5-Data e Hora da 2  Pesagem
	EndIf

	If !Empty(aDadosEnv[6])
		cXMLRet +=    '<HarvestOrderCodePIMS>'  + AllTrim(aDadosEnv[6]) + '</HarvestOrderCodePIMS>' //6-N�mero da Ordem e Colheita - PIMS
	EndIf

	If !Empty(aDadosEnv[7])
		cXMLRet +=    '<HarvestOrderCode>'  + AllTrim(aDadosEnv[7]) + '</HarvestOrderCode>' //7-N�mero da Ordem e Colheita
	EndIf

	If !Empty(aDadosEnv[8])
		cXMLRet +=    '<OccupationCode>'  + AllTrim(aDadosEnv[8]) + '</OccupationCode>' //8-C�digo da Ocupa��o do [Talh�o]
	EndIf

	If !Empty(aDadosEnv[9])
		cXMLRet +=    '<FarmCode>'  + AllTrim(aDadosEnv[9]) + '</FarmCode>' //9-C�digo da [Fazenda]
	EndIf

	If !Empty(aDadosEnv[10])
		cXMLRet +=    '<SectorCode>'  + AllTrim(aDadosEnv[10]) + '</SectorCode>' //10-C�digo do [Setor]
	EndIf

	If !Empty(aDadosEnv[11])
		cXMLRet +=    '<PartOfLandCode>'  + AllTrim(aDadosEnv[11]) + '</PartOfLandCode>' //11-C�digo do [Talh�o]
	EndIf

	If !Empty(aDadosEnv[12])
		cXMLRet +=    '<WarehouseCode>'  + AllTrim(aDadosEnv[12]) + '</WarehouseCode>' //12-Codigo do Local de Estoque(Armazem)
		If !Empty(aDadosEnv[2])
			cXMLRet +=    '<WarehouseInternalId>'  + aDadosEnv[2] + "|" + AllTrim(aDadosEnv[12]) + '</WarehouseInternalId>' //26-N�mero do boletim da Pesagem Externa (Romaneio)
		Else
			cXMLRet +=    '<WarehouseInternalId>'  + FWCodFil() + "|" + AllTrim(aDadosEnv[12]) + '</WarehouseInternalId>'  /* Obrigatorio */
		EndIf
	EndIf

	If !Empty(aDadosEnv[13])
		cXMLRet +=    '<DriverCode>'  + AllTrim(aDadosEnv[13]) + '</DriverCode>' //13-C�digo do Motorista no ERP
	EndIf

//	If !Empty(aDadosEnv[14])
//		cXMLRet +=    '<OperatorCode>'  + AllTrim(aDadosEnv[14]) + '</OperatorCode>' //14-C�digo do Operador no ERP
//	EndIf

	If !Empty(aDadosEnv[15])
		cXMLRet +=    '<InvoiceNumber>'  + AllTrim(aDadosEnv[15]) + '</InvoiceNumber>' //15-N�mero da Nota Fiscal
	EndIf

	If !Empty(aDadosEnv[16])
		cXMLRet +=    '<InvoiceSerie>'  + AllTrim(aDadosEnv[16]) + '</InvoiceSerie>' //16-N�mero da S�rie
	EndIf

	If !Empty(aDadosEnv[17])
		cXMLRet +=    '<GrossWeight>'  + cValToChar(aDadosEnv[17]) + '</GrossWeight>' //17-Peso Bruto
	EndIf

	If !Empty(aDadosEnv[18])
		cXMLRet +=    '<TaraWeight>'  + cValToChar(aDadosEnv[18]) + '</TaraWeight>' //18-Peso Tara
	EndIf

	If !Empty(aDadosEnv[19])
		cXMLRet +=    '<ImpurityTotal>'  + cValToChar(aDadosEnv[19]) + '</ImpurityTotal>' //19-Total Impurezas
	EndIf

	If !Empty(aDadosEnv[20])
		cXMLRet +=    '<HarvestOrderDate>'  + AllTrim(aDadosEnv[20]) + '</HarvestOrderDate>' //20-Data da Ordem de Colheita
	EndIf

	If !Empty(aDadosEnv[21])
		cXMLRet +=    '<HarvestSystemCode>'  + AllTrim(aDadosEnv[21]) + '</HarvestSystemCode>' //21-C�digo do Sistema de Colheita
	EndIf

	If !Empty(aDadosEnv[22])
		cXMLRet +=    '<AreaHarvestOrder>'  + cValToChar(aDadosEnv[22]) + '</AreaHarvestOrder>' //22-�rea da Ordem de Colheita
	EndIf

	If !Empty(aDadosEnv[23])
		cXMLRet +=    '<EstimatedWeight>'  + cValToChar(aDadosEnv[23]) + '</EstimatedWeight>' //23-Kg/Ha Estimados
	EndIf

	If !Empty(aDadosEnv[24])
		cXMLRet +=    '<PackNumber>'  + AllTrim(aDadosEnv[24]) + '</PackNumber>' //24-N�mero do Fard�o
	EndIf

	If !Empty(aDadosEnv[25])
		cXMLRet +=    '<WeighingBulletinNumber>'  + AllTrim(aDadosEnv[25]) + '</WeighingBulletinNumber>' //25-N�mero do boletim da Pesagem Externa (Romaneio)
	EndIf

	If !Empty(aDadosEnv[26])
		cXMLRet +=    '<EquipmentCode>'  + AllTrim(aDadosEnv[26]) + '</EquipmentCode>' //xx-C�digo do Equipamento no PIMSMulticultivos
	EndIf

	cXMLRet += '</BusinessContent>'

	Return cXMLRet   
	
	
/*/{Protheus.doc} DefOperat
//Indica a operation do Modelo e envia para a variavel do XML
@author carlos.augusto
@since 07/05/2018
@version undefined
@type function
/*/
Static Function DefOperat()
	_oModel 		:= FwModelActive()
	_nOperat		:= _oModel:GetOperation()
	_oMldDX0 		:= _oModel:GetModel( "AGRA500_DX0" )

	If _nOperat == MODEL_OPERATION_DELETE .Or. (_oMldDX0:IsDeleted() .And. Val(_oMldDX0:GetValue("DX0_BOLETI")) != 0)
		_cOperat := "DELETE"
	ElseIf _nOperat == MODEL_OPERATION_UPDATE .Or. _nOperat == MODEL_OPERATION_INSERT
		_cOperat := "UPSERT"
	EndIf
	
Return