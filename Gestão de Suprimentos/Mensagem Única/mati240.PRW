#Include "PROTHEUS.CH"
#Include "FWADAPTEREAI.CH"
#Include "MATI240.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} MATI240
Programa de interpretacao da mensagem unica

@since 09/11/2012
@version P11
@param	cXML - Variavel com conteudo xml para envio/recebimento.
@param	nTypeTrans - Tipo de transacao. (Envio/Recebimento)
@param	cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc)
@return	aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno
	aRet[1] - (boolean) Indica o resultado da execu��o da fun��o
	aRet[2] - (caracter) Mensagem Xml para envio
*/
//-------------------------------------------------------------------
Function MATI240(cXML,nTypeTrans,cTypeMessage )
Local lRet		:= .T.
Local aArea		:= GetArea()
Local nCount	:= 0
Local cXMLRet	:= ""
Local cXmlErro	:= ""
Local cXmlWarn	:= ""
Local cValExt	:= ""
Local cValInt	:= ""
Local cEvento	:= "upsert"
Local oXmlMvInt	:= Nil
Local cMarca    := ""

Private oXmlInt
Private lMsErroAuto := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.

If nTypeTrans == TRANS_RECEIVE
	If cTypeMessage == EAI_MESSAGE_BUSINESS
		oXmlInt	:= XmlParser( cXML, '_', @cXmlErro, @cXmlWarn)
		If oXmlInt <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
			// Vers�o da mensagem
			If Type("oXmlInt:_TOTVSMessage:_MessageInformation:_version:Text") != "U" .And. !Empty(oXmlInt:_TOTVSMessage:_MessageInformation:_version:Text)
				cVersao := StrTokArr(oXmlInt:_TOTVSMessage:_MessageInformation:_version:Text, ".")[1]
			Else
				If Type("oXmlInt:_TOTVSMessage:_MessageInformation:_StandardVersion:Text") != "U" .And. !Empty(oXmlInt:_TOTVSMessage:_MessageInformation:_StandardVersion:Text)
					cVersao := StrTokArr(oXmlInt:_TOTVSMessage:_MessageInformation:_StandardVersion:Text, ".")[1]
				Else
					lRet    := .F.
					cXmlRet := STR0021 //"Vers�o da mensagem n�o informada!"
					Return {lRet, cXmlRet}
				Endif
			EndIf
			
			If cVersao == "1"
				aRet := v1000(cXML,nTypeTrans,cTypeMessage)
				lRet := aRet[1]
				cXmlRet := aRet[2]
			Else
				lRet := .F.
				cXmlRet := STR0021 //"Vers�o da mensagem n�o implementada."
				Return {lRet, cXmlRet}
			EndIf
		Else  
			lRet    := .F.
			cXMLRet := 	STR0017 + ' | ' +cXmlErro + ' | ' + cXmlWarn //"Xml mal formatado "
		EndIf		
	ElseIf   cTypeMessage == EAI_MESSAGE_RESPONSE
		If FindFunction("CFGA070Mnt")	
			oXmlMvInt := XmlParser(cXml, "_", @cXmlErro, @cXmlWarn)
			
			If oXmlMvInt <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
				cMarca  := oXmlMvInt:_TotvsMessage:_MessageInformation:_Product:_Name:Text
				cValInt := oXmlMvInt:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_MovementsInternal:_Destination:Text
				cValExt := oXmlMvInt:_TOTVSMessage:_ResponseMessage:_ReturnContent:_ListOfInternalId:_MovementsInternal:_Origin:Text
				oXmlMvInt := oXmlMvInt:_TotvsMessage     
				
				//-- Identifica se o processamento pelo parceiro ocorreu com sucesso
				If XmlChildEx(oXmlMvInt:_ResponseMessage:_ProcessingInformation, '_STATUS' ) <> Nil .And. ;
					Upper(oXmlMvInt:_ResponseMessage:_ProcessingInformation:_Status:Text)=='OK'
		
					If !Empty(cValExt) .And.!Empty(cValInt)
						If CFGA070Mnt(cMarca,"SD3","D3_NUMSEQ",cValExt,cValInt)
							lRet := .T.
						EndIf
					Else
						lRet := .F.
					EndIf
				Else
					lRet    := .F.
					cXmlRet := STR0019 //-- Processamento pela outra aplica��o n�o teve sucesso
					
					//-- Transforma estrutura das mensagens de erro em array para concatenar com a mensagem de retorno
					If XmlChildEx( oXmlMvInt:_ResponseMessage:_ProcessingInformation, '_LISTOFMESSAGES' ) <> Nil .And. ;
								ValType(oXmlMvInt:_ResponseMessage:_ProcessingInformation:_ListOfMessages)<>'A'
						XmlNode2Arr(oXmlMvInt:_ResponseMessage:_ProcessingInformation:_ListOfMessages, "_ListOfMessages")
					EndIf
				
					For nCount := 1 To Len( oXmlMvInt:_ResponseMessage:_ProcessingInformation:_ListOfMessages )
						If XmlChildEx( oXmlMvInt:_ResponseMessage:_ProcessingInformation:_ListOfMessages[nCount], '_MESSAGE' ) <> Nil
							cXmlRet += ' | ' + oXmlMvInt:_ResponseMessage:_ProcessingInformation:_ListOfMessages[nCount]:_Message:Text
						EndIf	
					Next nCount
					
					If InTransact()
						DisarmTransaction()
					EndIf
				EndIf
			Else
				lRet    := .F.
				cXMLRet := 	STR0017 + ' | ' +cXmlErro + ' | ' + cXmlWarn //"Xml mal formatado "
			EndIf
		EndIf
	ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
		cXMLRet := '1.000'
	EndIf
ElseIf nTypeTrans == TRANS_SEND
	
	If !Inclui .AND. !Altera
		cEvento	:=	"Delete"
	EndIf
	
	//Monta XML de envio de mensagem unica
	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>MovementsInternal</Entity>'
	cXMLRet +=     '<Event>' +cEvento +'</Event>'
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="Code">' +xFilial("SD3")+SD3->(D3_COD+D3_LOCAL+D3_NUMSEQ) +'</key>'
	cXMLRet +=     '</Identification>'
	cXMLRet += '</BusinessEvent>'
	
	cXMLRet += '<BusinessContent>'
	cXMLRet += '	<CompanyId>' +cEmpAnt +'</CompanyId>'
	cXMLRet += '	<BranchId>' +xFilial("SD3") +'</BranchId>'
	cXMLRet +=      '<CompanyInternalId>' +cEmpAnt  +'</CompanyInternalId>'
	cXMLRet +=      '<InternalId>' +SD3->D3_FILIAL +'</InternalId>'
	cXMLRet += '    <typeMovementCode>' +SD3->D3_TM +'</typeMovementCode>' 		// codigo do tipo de movimento interno
	cXMLRet += '    <EmissionDate>' +DToS(SD3->D3_EMISSAO) +'</EmissionDate>'          		// data de emissao
	cXMLRet += '    <ItemCode>' +xFilial("SB1") +SD3->D3_COD +'</ItemCode>'      		// item/ produto
	cXMLRet += '    <UnitOfMeasureCode>' +xFilial("SAH") +SD3->D3_UM +'</UnitOfMeasureCode>'		// unidade de medida
	cXMLRet += '    <Quantity>' +Str(SD3->D3_QUANT) +'</Quantity>'      // quantidade
	cXMLRet += '    <WarehouseCode>' +xFilial("NNR") +SD3->D3_LOCAL +'</WarehouseCode>'          // codigo do armazem
	cXMLRet += '    <LotNumber>' +SD3->D3_LOTECTL +'</LotNumber>'          // numero do lote
	cXMLRet += '    <SubLotNumber>' +SD3->D3_NUMLOTE +'</SubLotNumber>'    // numero do sub-lote
	cXMLRet += '    <LotExpirationDate>' +DToS(SD3->D3_DTVALID) +'</LotExpirationDate>'		// data valida do lote
	cXMLRet += '    <FamilyCode>' +xFilial("SBM")+SD3->D3_GRUPO +'</FamilyCode>'			// grupo do produto
	cXMLRet += '    <Address>' +SD3->D3_LOCALIZ +'</Address>'              // endere�o origem
	cXMLRet += '    <NumberSeries>' +SD3->D3_NUMSERI +'</NumberSeries>'    // numero de serie
	
	If SD3->D3_TM <= '500'
		cXMLRet += ' <InputOrOutput>E</InputOrOutput>'       // Identifica o tipo de movimento se E = Entrada, S = Saida
	ElseIf SD3->D3_TM > '500'
		cXMLRet += ' <InputOrOutput>S</InputOrOutput>'       // Identifica o tipo de movimento se E = Entrada, S = Saida
	EndIf
	
	cXMLRet += '</BusinessContent>'	
EndIf

RestArea(aArea)
Return {lRet,cXMLRet}

//-------------------------------------------------------------------
/*{Protheus.doc} v1000
Programa de interpretacao da mensagem unica

@since 09/11/2012
@version P11
@param	cXML - Variavel com conteudo xml para envio/recebimento.
@param	nTypeTrans - Tipo de transacao. (Envio/Recebimento)
@param	cTypeMessage - Tipo de mensagem. (Business Type, WhoIs, etc)
@return	aRet - Array contendo o resultado da execucao e a mensagem Xml de retorno
	aRet[1] - (boolean) Indica o resultado da execu��o da fun��o
	aRet[2] - (caracter) Mensagem Xml para envio
*/
//-------------------------------------------------------------------
Static Function v1000(cXML,nTypeTrans,cTypeMessage)
	Local lRet      := .T.
	Local aErroAuto := {}
	Local aMovInt   := {}
	Local aMovInt2  := {}
	Local aTRt      := {}
	Local aArea     := GetArea()
	Local dtEmiss   := CToD("")
	Local dtValLot  := CToD("")
	Local nQuant    := 0
	Local nCount    := 0
	Local nOpcx     := 0
	Local nI        := 0
	Local nPos      := 0
	Local cMarca    := ""
	Local cXMLRet   := ""
	Local cXmlErro  := ""
	Local cXmlWarn  := ""
	Local cValExt   := ""
	Local cValInt   := ""
	Local cLogErro  := ""
	Local cTpMov    := ""
	Local cProd     := ""
	Local cUnMed    := ""
	Local cArmzm    := ""
	Local cLote     := ""
	Local cSubLote  := ""
	Local cGrpPrd   := ""
	Local cEnd      := ""
	Local cNumSer   := ""
	Local cProdExt  := ""
	Local cArmzmExt := ""
	Local cGrpExt   := ""
	Local cEvento   := "upsert"
	//Local cNumOp    := "" Definida como Private no WSPCP.prw
	//Local cOperacao := "" Definida como Private no WSPCP.prw
	Local cRoteiro  := ""
	Local cQuery    := ""
	Local cNewAlias := GetNextAlias()
	Local cAliasTRT := GetNextAlias()
	Local cAliasTRT2:= GetNextAlias()
	Local aMovAux   := {}
	Local lOp       := .F.
	Local nSaldoTRT := 0
	Local nX        := 1
	Local oXmlBusin

	Private oXmlMvInt
	Private nRegSD3 := 0

	oXmlMvInt	:= XmlParser( cXML, '_', @cXmlErro, @cXmlWarn)
	If oXmlMvInt <> Nil .And. Empty(cXmlErro) .And. Empty(cXmlWarn)
		cMarca := oXmlMvInt:_TotvsMessage:_MessageInformation:_Product:_Name:Text
		oXmlBusin := oXmlMvInt:_TotvsMessage:_BusinessMessage
		If XmlChildEx(oXmlBusin, '_BUSINESSEVENT') <> Nil .And. XmlChildEx(oXmlBusin:_BusinessEvent, '_EVENT' ) <> Nil
			If XmlChildEx(oXmlBusin:_BusinessEvent, '_IDENTIFICATION') <> Nil .And. XmlChildEx(oXmlBusin:_BusinessEvent:_Identification, '_KEY') <> Nil
				If ValType(oXmlBusin:_BusinessEvent:_Identification:_Key) == "O"
					cValExt := oXmlBusin:_BusinessEvent:_Identification:_Key:Text
				ElseIf ValType(oXmlBusin:_BusinessEvent:_Identification:_Key) == "A"
					For nI := 1 To Len(oXmlBusin:_BusinessEvent:_Identification:_Key)
						If ! AllTrim(Upper(oXmlBusin:_BusinessEvent:_Identification:_Key[nI]:_Name:Text)) $ "IDPCFACTORY|REPROCESS"
							If AllTrim(Upper(cMarca)) == "PPI" .And. AllTrim(Upper(oXmlBusin:_BusinessEvent:_Identification:_Key[nI]:_Name:Text)) == "ESTORNO"
								cValExt := oXmlBusin:_BusinessEvent:_Identification:_Key[nI]:Text
								Exit
							Else
								cValExt := oXmlBusin:_BusinessEvent:_Identification:_Key[nI]:Text
								Exit
							EndIf
						EndIf
					Next nI
				EndIf
			EndIf
			
			If AllTrim(Upper(cMarca)) == "PPI"
				If !PCPIntgPPI()
					lRet := .F.
					cXmlRet := STR0022 //"Integra��o com o TOTVS MES desativada. Processamento n�o permitido."
					Return {lRet, cXMLRet}
				EndIf
			EndIf
			
			If XmlChildEx(oXmlBusin:_BusinessContent, '_INPUTOROUTPUT') <> NIL
				If AllTrim(Upper(cMarca)) == "PPI"
					dbSelectArea("SOE")
					SOE->(dbSetOrder(1))
					If SOE->(dbSeek(xFilial("SOE")+"SF5"))
						If (oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_InputOrOutput:Text) == "E"
							If SOE->(ColumnPos("OE_VAR4"))
								cTpMov := SOE->OE_VAR4
							EndIf
						ElseIf (oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_InputOrOutput:Text) == "S"
							cTpMov := SOE->OE_VAR2
						Else
							lRet := .F.
							cXmlRet := STR0023 //"InputOrOutput n�o � v�lido. Valores v�lidos: 'E'=Entrada, 'S'=Sa�da."
							Return {lRet, cXmlRet}
						EndIf
						If Empty(cTpMov)
							lRet := .F.
							cXmlRet := STR0024 //"Tipo de movimenta��o n�o cadastrado nos par�metros do TOTVS MES (PCPA109)."
							Return {lRet, cXmlRet}
						EndIf
					Else
						lRet := .F.
						cXmlRet := STR0024 //"Tipo de movimenta��o n�o cadastrado nos par�metros do TOTVS MES (PCPA109)."
						Return {lRet, cXmlRet}
					EndIf
				Else
					If (oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_InputOrOutput:Text) == "E"
						cTpMov	:= SuperGetMv('MV_MTI241E',.F.,"")
					ElseIf (oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_InputOrOutput:Text) == "S"
						cTpMov	:= SuperGetMv('MV_MTI241S',.F.,"")
					EndIf
				EndIf
		
				If Valtype(cTpMov) <> 'C' .Or. Empty(cTpMov)
					lRet := .F.
					If AllTrim(Upper(cMarca)) == "PPI"
						cXmlRet := "Tipo de movimenta��o n�o cadastrado nos par�metros do TOTVS MES (PCPA109)." //"Tipo de movimenta��o n�o cadastrado nos par�metros do TOTVS MES (PCPA109)."
					Else
						cXmlRet := STR0018 + "MV_MTI241E | MV_MTI241S" // "O Tipo de movimenta��o n�o foi cadastrado nos par�metros "
					EndIf
				Else
					aAdd(aMovInt,{"D3_TM",cTpMov,})
				EndIf
			Else 
				lRet := .F.
				cXMLRet := STR0001 //"N�o existe a Tag InputOrOutput"
			EndIf
			
			If lRet .And. FindFunction("CFGA070INT")
				If AllTrim(Upper(cMarca)) == "PPI"
					cValInt := cValExt
				Else
					cValInt := CFGA070INT(cMarca,'SD3','D3_NUMSEQ',cValExt)
				EndIf
				
				If lRet
					If XmlChildEx(oXmlBusin:_BusinessContent, '_ITEMCODE') <> NIL
						//cProdExt := oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text
						//cProd := CFGA070INT( cMarca, 'SB1', 'B1_COD', cProdExt )
						cProd := PadR(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_ItemCode:Text,Len(SB1->B1_COD))
						If Type("lRunPPI") == "L" .And. lRunPPI
							cProduto := cProd //(cProduto) definida no WSPCP.prw. Utilizada para gerar a tabela SOG
						EndIf
						/*If SB1->(dbSeek(xFilial("SB1")+cProd))
							cProd := SB1->B1_COD*/
							aAdd(aMovInt,{"D3_COD",PadR(cProd,TamSX3("D3_COD")[1]),})
						/*Else
							lRet := .F.
							cXMLRet := STR0002 //'N�o encontrado o Produto'
						EndIf*/
					Else
						lRet := .F.
						cXMLRet := STR0003 //'N�o existe a Tag ItemCode'
					EndIf
				EndIf
				
				If lRet
					If XmlChildEx(oXmlBusin:_BusinessContent, '_UNITOFMEASURECODE') <> NIL
						cUnMed := oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_UnitOfMeasureCode:Text
						aAdd(aMovInt,{"D3_UM",cUnMed,})
					Else
						lRet := .F.
						cXMLRet := STR0004 //'N�o existe a Tag UnitOfMeasure'
					EndIf
				EndIf
				
				If lRet
					If XmlChildEx(oXmlBusin:_BusinessContent, '_WAREHOUSECODE') <> NIL
						//cArmzmExt := oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text
						//cArmzm := CFGA070INT( cMarca, 'NNR', 'NNR_CODIGO', cArmzmExt )
						cArmzm := PadR(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_WarehouseCode:Text,Len(NNR->NNR_CODIGO))
						/*If NNR->(dbSeek(xFilial("NNR")+cArmzm))
							cArmzm := NNR->NNR_CODIGO*/
							aAdd(aMovInt,{"D3_LOCAL",PadR(cArmzm,TamSX3("D3_LOCAL")[1]),})
						/*Else
							lRet := .F.
							cXMLRet := STR0005 //'N�o encontrado o Armazem'
						EndIf*/
					Else
						lRet := .F.
						cXMLRet := STR0006 //'N�o existe a Tag "WarehouseCode"'
					EndIf
				EndIf
				
				If lRet
					If XmlChildEx(oXmlBusin:_BusinessContent, '_QUANTITY') <> NIL
						nQuant := VAL(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_Quantity:Text)
						aAdd(aMovInt,{"D3_QUANT",nQuant,})
						If Type("lRunPPI") == "L" .And. lRunPPI
							nQtdSOG := nQuant //(nQtdSOG) definida no WSPCP.prw. Utilizada para gerar a tabela SOG
						EndIf
					Else
						lRet := .F.
						cXMLRet := STR0007 //'N�o exite a Tag "Quantity"'
					EndIf
				EndIf
				
				If lRet
					If XmlChildEx(oXmlBusin:_BusinessContent, '_EMISSIONDATE') <> NIL    ///EmissionDate
						dtEmiss := StrTran(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_EmissionDate:Text, '-', '')
						dtEmiss := STOD( dtEmiss )
						aAdd(aMovInt,{"D3_EMISSAO",dtEmiss,})
					Else
						lRet := .F.
						cXMLRet := STR0008 //'N�o existe a Tag "Date"'
					EndIf
				EndIf
				
				If SuperGetMv("MV_RASTRO",.F.,"N") == "S" .And. Rastro(cProd) 
					If XmlChildEx(oXmlBusin:_BusinessContent, '_LOTNUMBER') <> NIL 
						cLote		:= oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_LotNumber:Text
						aAdd(aMovInt,{"D3_LOTECTL",cLote,})
					Else
						lRet := .F.
						cXMLRet := STR0009 //'N�o existe a Tag "LotNumber"'
					EndIf
					
					If lRet .And. Rastro(cProd,"S") .And. XmlChildEx(oXmlBusin:_BusinessContent, '_SUBLOTNUMBER') <> NIL
						SD5->(dbSetOrder(2)) //D5_FILIAL+D5_PRODUTO+D5_LOCAL+D5_LOTECTL+D5_NUMLOTE+D5_NUMSEQ
						If dbSeek(xFilial("SD5")+cProd+cArmzm+cLote+oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_SubLotNumber:Text)
							cSubLote	:= oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_SubLotNumber:Text
							aAdd(aMovInt,{"D3_NUMLOTE",cSubLote,})
						EndIf
					EndIf
					
					If lRet
						If XmlChildEx(oXmlBusin:_BusinessContent, '_LOTEXPIRATIONDATE') <> NIL
							dtValLot 	:= StrTran( oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_LotExpirationDate:Text, '-', '')
							dtValLot	:= STOD( dtValLot )
							aAdd(aMovInt,{"D3_DTVALID",dtValLot,})
						Else
							lRet := .F.
							cXMLRet := STR0011 //'N�o existe a Tag "LotExpirationDate"'
						EndIf
					EndIf						
				EndIf
				
				//Quando � integra��o com o TOTVS MES n�o utiliza o FAMILICODE
				If lRet .And. AllTrim(Upper(cMarca)) != "PPI"
					If XmlChildEx(oXmlBusin:_BusinessContent, '_FAMILYCODE') <> NIL
						//cGrpExt	:= oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_FamilyCode:Text
						//cGrpPrd	:= CFGA070INT( cMarca, 'SBM', 'BM_GRUPO', cGrpExt )
						cGrpPrd	:= PadR(oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_FamilyCode:Text,Len(SBM->BM_GRUPO))
						/*If SBM->(dbSeek(xFilial("SBM")+cGrpPrd))
							cGrpPrd := SBM->BM_GRUPO*/
							aAdd(aMovInt,{"D3_GRUPO",cGrpPrd,})
						/*Else
							lRet := .F.
							cXMLRet := STR0012 //'N�o encontrado o "Grupo de Produto"'
						EndIf*/
					Else
						lRet := .F.
						cXMLRet := STR0013 //'N�o existe a Tag "GroupCode"'
					EndIf
				EndIf
				
				If lRet
					If XmlChildEx(oXmlBusin:_BusinessContent, '_ADDRESS') <> NIL
						cEnd	:= oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_Address:Text
						aAdd(aMovInt,{"D3_LOCALIZ",cEnd,})
					Else
						lRet := .F.
						cXMLRet := STR0014 //'N�o existe a Tag "Address"'
					EndIf
				EndIf
				
				If lRet
					If XmlChildEx(oXmlBusin:_BusinessContent, '_NUMBERSERIES') <> NIL
						cNumSer	:= oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_NumberSeries:Text
						aAdd(aMovInt,{"D3_NUMSERI",cNumSer,})
					Else
						lRet := .F.
						cXMLRet := STR0015 //'N�o existe a Tag "NumberSeries"'
					EndIf
				EndIf
				
				If Upper(oXmlMvInt:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_Event:Text) == "UPSERT"
					Inclui	:= .T.
					nOpcx	:= 3	// Inclusao
				Else
					nOpcx	:= 5	// Estorno
					If AllTrim(Upper(cMarca)) == "PPI"
						SD3->(dbSetOrder(3))
						If SD3->(dbSeek(cValInt))
							aAdd(aMovInt,{"D3_NUMSEQ",SD3->D3_NUMSEQ,Nil})
							aAdd(aMovInt,{"INDEX",3,Nil})
							nRegSD3 := SD3->(Recno())
						EndIf
					Else
						aAdd(aMovInt,{"D3_NUMSEQ",Substr(cValInt,26,6),})
						aAdd(aMovInt,{"INDEX",7,})
					EndIf
				EndIf
			Else
				If lRet
					lRet   := .F.
					cXMLRet := STR0016 //"Atualize EAI"
				EndIf
			EndIf
			
			If lRet .And. AllTrim(Upper(cMarca)) == "PPI"
				aAdd(aMovInt,{"D3_OBSERVA","TOTVSMES",Nil})
			EndIf
			
			If lRet
				If XmlChildEx(oXmlBusin:_BusinessContent, '_PRODUCTIONORDERNUMBER') <> NIL
					cNumOp := oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_ProductionOrderNumber:Text
					If !Empty(cNumOp)
						dbSelectArea("SC2")
						SC2->(dbSetOrder(1))
						If SC2->(dbSeek(xFilial("SC2")+AllTrim(cNumOp))) 
							//Trata para caso o n�mero do documento seja apenas uma parte de uma OP, que encontra no Seek.
							If AllTrim(SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)) == AllTrim(cNumOp)
								aAdd(aMovInt,{"D3_OP" ,PadR(cNumOp,TamSX3("D3_OP")[1]),Nil})
								lOp := .T.
							Else
								aAdd(aMovInt,{"D3_DOC",cNumOp,Nil})
							EndIf
						Else
							aAdd(aMovInt,{"D3_DOC",cNumOp,Nil})
						EndIf
						
						If XmlChildEx(oXmlBusin:_BusinessContent, '_SCRIPTCODE') <> NIL
							cRoteiro := oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_ScriptCode:Text
						EndIf
						If XmlChildEx(oXmlBusin:_BusinessContent, '_ACTIVITYCODE') <> NIL
							cOperacao := oXmlMvInt:_TotvsMessage:_BusinessMessage:_BusinessContent:_ActivityCode:Text
						EndIf
						
						//Se foi informado roteiro/opera��o, realiza a valida��o na SD4.
						If lOp .And. !Empty(cRoteiro) .And. !Empty(cOperacao) .And. SD4->(FieldPos("D4_ROTEIRO")) > 0
							cQuery := " SELECT COUNT(*) TOTAL "
							cQuery +=   " FROM " + RetSqlName("SD4") + " SD4 "
							cQuery +=  " WHERE SD4.D4_FILIAL  = '" + xFilial("SD4") + "' "
							cQuery +=    " AND SD4.D_E_L_E_T_ = ' ' "
							cQuery +=    " AND SD4.D4_COD     = '" + cProd + "' "
							cQuery +=    " AND SD4.D4_OP      = '" + cNumOp + "' "
							cQuery +=    " AND SD4.D4_ROTEIRO = '" + cRoteiro + "' "
							cQuery +=    " AND SD4.D4_OPERAC  = '" + cOperacao + "' "
							
							cQuery := ChangeQuery(cQuery)
							
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNewAlias,.T.,.T.)
							If (cNewAlias)->(TOTAL) < 1
								lRet := .F.
								cXmlRet := STR0025 //"Roteiro/Opera��o inv�lido para esta ordem de produ��o/produto."
								(cNewAlias)->(dbCloseArea())
								Return {lRet,cXmlRet}
							EndIf
							(cNewAlias)->(dbCloseArea())
						EndIf
					EndIf
				EndIf
			EndIf
			
			If lRet 	
				//Cria o campo D3_TRT 
				aAdd(aMovInt,{"D3_TRT"," ",Nil})

				//Faz query na SDC se n�o houver registro produra na SD4 

				cQuery := " SELECT SDC.DC_TRT TRT,  SDC.DC_QUANT QUANT"
				cQuery +=   " FROM " + RetSqlName("SDC") + " SDC "
				cQuery +=  " WHERE SDC.DC_FILIAL  = '" + xFilial("SDC") + "' "
				cQuery +=    " AND SDC.D_E_L_E_T_ = ' ' "
				cQuery +=    " AND SDC.DC_PRODUTO      = '" + cProd    + "' "
				cQuery +=    " AND SDC.DC_OP           = '" + cNumOp   + "' "
				cQuery +=    " AND SDC.DC_LOCAL        = '" + cArmzm   + "' "
				cQuery +=    " AND SDC.DC_LOTECTL      = '" + cLote    + "' "
				cQuery +=    " AND SDC.DC_NUMLOTE      = '" + cSubLote + "' "
				cQuery +=    " AND SDC.DC_LOCALIZ      = '" + cEnd     + "' "
				cQuery +=    " AND SDC.DC_NUMSERI      = '" + cNumSer  + "' "

				cQuery := ChangeQuery(cQuery)
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRT,.T.,.T.)
				(cAliasTRT)->(DbGoTop())
				If (cAliasTRT)->(!Eof())
					nSaldoTRT := nQuant
					While  (cAliasTRT)->(!Eof())
						//Quando a qtd requisita � menor que a quantidade dispon�ver nessa sequencia/TRT
						If nSaldoTRT <=  (cAliasTRT)->QUANT 
							aAdd(aTRT,{(cAliasTRT)->TRT,nSaldoTRT})
							nSaldoTRT := nSaldoTRT - (cAliasTRT)->QUANT 
							Exit	
						ElseIf (cAliasTRT)->QUANT > 0
						//Quando a qtd requisitada � maior que a qtd dispon�vel utiliza a
						// quantidade total do TRT e continua procurando o saldo. 												
							aAdd(aTRT,{(cAliasTRT)->TRT,(cAliasTRT)->QUANT})
							nSaldoTRT := nSaldoTRT - (cAliasTRT)->QUANT 							
						EndIf
						(cAliasTRT)->(DbSkip())
					EndDo
					//Se j� pesquisou em toda SDC e n�o existe mais saldo dispon�vel, � uma 
					// requisi��o maior do que os empenhos vai utilizar o primeiro dispon�vel. 
					If nSaldoTRT > 0 
						(cAliasTRT)->(DbGoTop()) 
						aAdd(aTRT,{(cAliasTRT)->TRT,nSaldoTRT})
					EndIf 
					(cAliasTRT)->(dbCloseArea())	
				Else 
					cQuery := " SELECT SD4.D4_TRT TRT, SD4.D4_QUANT QUANT"
					cQuery +=   " FROM " + RetSqlName("SD4") + " SD4 "
					cQuery +=  " WHERE SD4.D4_FILIAL  = '" + xFilial("SD4") + "' "
					cQuery +=    " AND SD4.D_E_L_E_T_ = ' ' "
					cQuery +=    " AND SD4.D4_COD     = '" + cProd    + "' "
					cQuery +=    " AND SD4.D4_OP      = '" + cNumOp   + "' "
					cQuery +=    " AND SD4.D4_LOTECTL = '" + cLote    + "' "
					cQuery +=    " AND SD4.D4_NUMLOTE = '" + cSubLote + "' "

					cQuery := ChangeQuery(cQuery)
					
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRT2,.T.,.T.)

					If (cAliasTRT2)->(!Eof())
						nSaldoTRT := nQuant
						While  (cAliasTRT2)->(!Eof())
							If nSaldoTRT <=  (cAliasTRT2)->QUANT 
								aAdd(aTRT,{(cAliasTRT2)->TRT,nSaldoTRT})
								nSaldoTRT := nSaldoTRT - (cAliasTRT2)->QUANT 
								Exit	
							ElseIf (cAliasTRT2)->QUANT > 0												
								aAdd(aTRT,{(cAliasTRT2)->TRT,(cAliasTRT2)->QUANT})
								nSaldoTRT := nSaldoTRT - (cAliasTRT2)->QUANT 							
							EndIf
							(cAliasTRT2)->(DbSkip())
						EndDo	
						//Se j� pesquisou em toda SDC e n�o existe mais saldo dispon�vel, � uma 
						// requisi��o maior do que os empenhos vai utilizar o primeiro dispon�vel. 
						If nSaldoTRT > 0 
							(cAliasTRT2)->(DbGoTop()) 
							aAdd(aTRT,{(cAliasTRT2)->TRT,nSaldoTRT})
						EndIf 					
					EndIf 
					(cAliasTRT2)->(dbCloseArea())		
					(cAliasTRT)->(dbCloseArea())			
				EndIf				
			EndIf
		EndIf
		
		
		// PE MATI240CRG
		If lRet .And. ExistBlock('MATI240CRG')
			aMovAux := ExecBlock('MATI240CRG',.F.,.F.,aMovInt)
			For nCount := 1 To Len(aMovAux)
				//Verifica se o campo j� existe no array aMovInt. Se j� existir, substitui o valor.
				nPos := aScan(aMovInt,{|x| Upper(AllTrim(x[1])) == Upper(AllTrim(aMovAux[nCount,1])) })
				If nPos == 0
					aAdd(aMovInt, {aMovAux[nCount,1],aMovAux[nCount,2], Nil})
				Else
					aMovInt[nPos,2] := aMovAux[nCount,2]
				EndIf
			Next nCount
		EndIf
		
		If lRet
			If len(aTRT) > 0 
				aMovInt2 := aClone(aMovInt)
				Begin Transaction
					For nX := 1 to len(aTRT)
						aMovInt := aMovInt2 

						//Preenche o D3_QUANT de acordo com a quantidade dispon�vel no TRT 
						nPosQtd := aScan(aMovInt ,{|x| x[1] == 'D3_QUANT'}) 
						If nPosQtd > 0 
							aMovInt[nPosQtd,2] := aTRT[nX,2]
						EndIf 
						//Preenche o TRT 
						nPosTrt := aScan(aMovInt ,{|x| x[1] == 'D3_TRT'}) 
						If nPosTrt > 0 
							aMovInt[nPosTrt,2] := aTRT[nX,1]
						EndIf

						MsExecAuto({|x,y| MATA240(x,y)}, aMovInt, nOpcx)  
					
						If lMsErroAuto
							aErroAuto := GetAutoGRLog()
							cLogErro := getMsgErro(aErroAuto) 
							lRet	 := .F.
							cXMLRet := EncodeUTF8( cLogErro )					
						Else
							If nOpcx == 3
								cValInt := xFilial("SD3")+SD3->(D3_COD+D3_LOCAL+D3_NUMSEQ)
								CFGA070Mnt(cMarca,"SD3","D3_NUMSEQ",cValExt,cValInt)
							Else
								CFGA070Mnt(,"SD3","D3_NUMSEQ",,cValInt,.T.)
							EndIf
							
							//-- Dados ok para grava��o
							cXMLRet := '<ListOfInternalId>'
							cXMLRet += 	'<MovementsInternal>'
							cXMLRet += 		'<Origin>'     + cValExt +'</Origin>'
							cXMLRet += 		'<Destination>'+ cValInt +'</Destination>'
							cXMLRet += 	'</MovementsInternal>'
							cXMLRet += '</ListOfInternalId>'
						EndIf
					
					Next nX
				End Transaction
			Else 
				MsExecAuto({|x,y| MATA240(x,y)}, aMovInt, nOpcx)  
			
				If lMsErroAuto
					aErroAuto := GetAutoGRLog()
					cLogErro := getMsgErro(aErroAuto) 
					lRet	 := .F.
					cXMLRet := EncodeUTF8( cLogErro )					
				Else
					If nOpcx == 3
						cValInt := xFilial("SD3")+SD3->(D3_COD+D3_LOCAL+D3_NUMSEQ)
						CFGA070Mnt(cMarca,"SD3","D3_NUMSEQ",cValExt,cValInt)
					Else
						CFGA070Mnt(,"SD3","D3_NUMSEQ",,cValInt,.T.)
					EndIf
					
					//-- Dados ok para grava��o
					cXMLRet := '<ListOfInternalId>'
					cXMLRet += 	'<MovementsInternal>'
					cXMLRet += 		'<Origin>'     + cValExt +'</Origin>'
					cXMLRet += 		'<Destination>'+ cValInt +'</Destination>'
					cXMLRet += 	'</MovementsInternal>'
					cXMLRet += '</ListOfInternalId>'
				EndIf
			EndIf
		EndIf
	Else
		lRet    := .F.
		cXMLRet := 	STR0017 + ' | ' +cXmlErro + ' | ' + cXmlWarn //"Xml mal formatado "
	EndIf
Return {lRet, cXmlRet}

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getMsgErro

Transforma o array com as informa��es de um erro em uma string para ser retornada.

@param aErro - Array com a mensagem de erro, obtido atrav�s da fun��o GetAutoGRLog

@return cMsg - Mensagem no formato String

@author  Lucas Konrad Fran�a
@version P12
@since   07/03/2018
/*/
//-------------------------------------------------------------------------------------------------
Static Function getMsgErro(aErro)
	Local cMsg   := ""
	Local nCount := 0
	
	For nCount := 1 To Len(aErro)
		If AT(':=',aErro[nCount]) > 0 .And. AT('< --',aErro[nCount]) < 1
			Loop
		EndIf
		If AT("------", aErro[nCount]) > 0
			Loop
		EndIf
		//Retorna somente a mensagem de erro (Help) e o valor que est� inv�lido, sem quebras de linha e sem tags '<>'
		If !Empty(cMsg)
			cMsg += " "
		EndIf
		cMsg += AllTrim(StrTran( StrTran( StrTran( StrTran( StrTran( aErro[nCount], "/", "" ), "<", "" ), ">", "" ), CHR(10), " "), CHR(13), "") + ("|"))
	Next nCount
	
	If Empty(cMsg) .And. Len(aErro) > 0
		For nCount := 1 To Len(aErro)
			If !Empty(cMsg)
				cMsg += " "
			EndIf
			cMsg += AllTrim(StrTran( StrTran( StrTran( StrTran( StrTran( aErro[nCount], "/", "" ), "<", "" ), ">", "" ), CHR(10), " "), CHR(13), "") + ("|"))
		Next nCount
	EndIf

Return cMsg
