#INCLUDE "Protheus.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "CTBI102G.CH"
#INCLUDE "TOTVS.ch"
#INCLUDE "TBICONN.ch"

//+++++++INTEGRA��O PROTHEUS GESPLAN LAN�AMENTO CONT�BIL CTBA102 ++++++++//

Class CT2readXGspMessageReader from LongNameClass

	method New()
	method Read()

EndClass

/*/{Protheus.doc} CT2readXGspMessageReader::New
construtor
@type method
@author Thiago Bussolin
/*/
method New() Class CT2readXGspMessageReader

return self

/*/{Protheus.doc} CT2readXGspMessageReader::Read
Respons�vel pela leitura e processamento da mensagem.
@type method
@author Thiago Bussolin
@param oLinkMessage, object, Inst�ncia de FwTotvsLinkMesage da mensagem
@return logical, sucesso ou falha. Determina se deve ou n�o retirar a mensagem da fila.
/*/
method Read( oLinkMessage ) Class CT2readXGspMessageReader
	// Local oContent := oLinkMessage:Content()
	Local oContent := JsonObject():new()
	Local aCab := {}
	Local aItens := {}
	Local aItensJson := {}
	Local aValid := {}
	Local cError := ""
	Local aLog := {}
	Local oResp := JsonObject():new()
	Local nX := 0
	Local nY := 0
	Local nZ := 0
	Local nW := 0
	Local nQtdCoHist := 0
	local aJson :={}
	Local nPos := 0
	Local nTamHist := 0
	Local cHist := ""
	Local cLinha := ""
	Local _nQuantas := 0
	Local cTenantId := ""
	Local cEmpJson 
	Local cFilJson
	Local cLote     := ""
	Local cSubLote  := ""
	Local dDatLan   := StoD("")
	Local cCt2key := ""

	Private lMsErroAuto     := .F.
	Private lMsHelpAuto		:= .T.
	Private lAutoErrNoFile	:= .T.

	oContent:FromJSON(oLinkMessage:RawMessage())
	cTenantId := oContent['tenantId']
	oContent := oContent['data']

	// ConOut( oLinkMessage:RawMessage())
	// ConOut( oLinkMessage:Header():toJson())
	// ConOut( oLinkMessage:Content():toJson())
	// ConOut( oLinkMessage:Type())
	// ConOut( oLinkMessage:tenantId())
	// ConOut( oLinkMessage:requestID())

	If len(oContent) > 0
		For	nZ := 1 To len(oContent)
			
			cEmpJson 	:= oContent[nZ]:GetJsonText("COD_EMP")
			cFilJson 	:= oContent[nZ]["CT2_FILIAL"] 
			aItensJson 	:= oContent[nZ]['ITENS']

			aValid := ValidData(oContent[nZ],@cEmpJson,@cFilJson,aItensJson,@cCt2key)

			If aValid[1]
				cError := ""
				aCab := {}
				aItens := {}
				// Pr� valida��o do Lan�amento ok, preparo o ambiente para chamada do execauto
				RpcClearEnv()
				// PREPARE ENVIRONMENT EMPRESA "T2" FILIAL "D MG 01 " MODULO "CTB" TABLES "CT2"
				RpcSetEnv( cEmpJson, cFilJson ,,,'CTB')

				_nQuantas := CtbMoedas()

				SetFunName("PROJETOGESPLAN") // Necess�rio para grava��o dos campos CT2_ROTINA e CT2_KEY
							
				nTamHist := TamSx3("CT2_HIST")[1]
				cLote 	 := "008950" //Lote padr�o Gesplan
				cSubLote := StrZero( 1,TamSx3("CT2_SBLOTE")[1] )
				dDatLan  := IIf(Empty(oContent[nZ]["CT2_DATA"]),dDataBase,CtoD(oContent[nZ]:GetJsonText("CT2_DATA")))

				aAdd(aCab, {'DDATALANC' , dDatLan  	,NIL} )	//CAMPO OBRIGAT�RIO
				aAdd(aCab, {'CLOTE' 	, cLote    	,NIL} )	//CAMPO OBRIGAT�RIO
				aAdd(aCab, {'CSUBLOTE' 	, cSubLote 	,NIL} )	//CAMPO OBRIGAT�RIO				
				aAdd(aCab, {'CPADRAO' 	, '' 		,NIL} )	//CAMPO DEFAULT
				aAdd(aCab, {'NTOTINF' 	, 0 		,NIL} )	//CAMPO DEFAULT
				aAdd(aCab, {'NTOTINFLOT', 0 		,NIL} )	//CAMPO DEFAULT
				
				For nW := 1 to len(aItensJson)
					
					If nW == 1
						cLinha := StrZero( 1,TamSx3("CT2_LINHA")[1] )
					Else
						cLinha := Soma1(cLinha)
					EndIf

					cHist := IIf(Empty(aItensJson[nW]["CT2_HIST"]), '', DecodeUtf8(aItensJson[nW]:GetJsonText("CT2_HIST")))
					
					aAdd(aItens,;  
						{ {'CT2_FILIAL' , cFilJson , NIL},; //CAMPO OBRIGAT�RIO
						{'CT2_LINHA' 	, cLinha , NIL},; //CAMPO OBRIGAT�RIO
						{'CT2_MOEDLC' 	, "01" , NIL},;				//CAMPO OBRIGAT�RIO
						{'CT2_DC' 		, aItensJson[nW]["CT2_DC"] , NIL},;						//CAMPO OBRIGAT�RIO
						{'CT2_HIST'     , cHist , NIL},; //CAMPO OBRIGAT�RIO
						IiF(Empty(aItensJson[nW]["CT2_DEBITO"]),{'CT2_DEBITO' ,'' , NIL},{'CT2_DEBITO' , aItensJson[nW]:GetJsonText("CT2_DEBITO") , NIL}),; //CAMPO OPCIONAL/OBRIGAT�RIO DE ACORDO COM O TIPO DE LAN�AMENTO
						IiF(Empty(aItensJson[nW]["CT2_CREDIT"]),{'CT2_CREDIT' ,'' , NIL},{'CT2_CREDIT' , aItensJson[nW]:GetJsonText("CT2_CREDIT") , NIL}),; //CAMPO OPCIONAL/OBRIGAT�RIO DE ACORDO COM O TIPO DE LAN�AMENTO
						{'CT2_VALOR' 	, aItensJson[nW]["CT2_VALOR"] , NIL},;							//CAMPO OBRIGAT�RIO
						{'CT2_ROTINA' 	, aItensJson[nW]["CT2_ROTINA"] , NIL},;							//CAMPO OBRIGAT�RIO
						IiF(Empty(aItensJson[nW]["CT2_CCD"]),{'CT2_CCD' ,'' , NIL},{'CT2_CCD' , aItensJson[nW]:GetJsonText("CT2_CCD") , NIL}),;				//CAMPO OPCIONAL
						IiF(Empty(aItensJson[nW]["CT2_CCC"]),{'CT2_CCC' ,'' , NIL},{'CT2_CCC' , aItensJson[nW]:GetJsonText("CT2_CCC") , NIL}),;				//CAMPO OPCIONAL
						{'CT2_ORIGEM' 	,'GESPLAN' , NIL},;															//CAMPO DEFAULT
						{'CT2_HP' ,'' 	, NIL},;													//CAMPO DEFAULT
						IiF(Empty(aItensJson[nW]["CT2_CONVER"]),{'CT2_CONVER' ,'1' , NIL},IIf(len(aItensJson[nW]:GetJsonText("CT2_CONVER")) > _nQuantas ,  {'CT2_CONVER' , SubStr(aItensJson[nW]:GetJsonText("CT2_CONVER"),1,_nQuantas) , NIL},{'CT2_CONVER' , SubStr(aItensJson[nW]:GetJsonText("CT2_CONVER"),1,len(aItensJson[nW]:GetJsonText("CT2_CONVER"))) , NIL}   ) ),; //CAMPO OPCIONAL
						{'CT2_TPSALD' 	, "1"/*oContent[nZ]:GetJsonText("CT2_TPSALD")*/ , NIL} ,; //CAMPO DEFAULT						
						{'CT2_KEY' 		, aItensJson[nW]:GetJsonText("CT2_KEY") , NIL} ,;					//CAMPO OBRIGAT�RIO
						{'CT2_EMPORI' 	, aItensJson[nW]:GetJsonText("CT2_EMPORI") , NIL} ,;			//CAMPO OBRIGAT�RIO
						IiF(Empty(aItensJson[nW]["CT2_ITEMD"]),{'CT2_ITEMD' ,'' , NIL},{'CT2_ITEMD' , aItensJson[nW]:GetJsonText("CT2_ITEMD") , NIL}),;		//CAMPO OPCIONAL
						IiF(Empty(aItensJson[nW]["CT2_ITEMC"]),{'CT2_ITEMC' ,'' , NIL},{'CT2_ITEMC' , aItensJson[nW]:GetJsonText("CT2_ITEMC") , NIL}),;		//CAMPO OPCIONAL
						IiF(Empty(aItensJson[nW]["CT2_CLVLDB"]),{'CT2_CLVLDB' ,'' , NIL},{'CT2_CLVLDB' , aItensJson[nW]:GetJsonText("CT2_CLVLDB") , NIL}),;	//CAMPO OPCIONAL
						IiF(Empty(aItensJson[nW]["CT2_CLVLCR"]),{'CT2_CLVLCR' ,'' , NIL},{'CT2_CLVLCR' , aItensJson[nW]:GetJsonText("CT2_CLVLCR") , NIL}),;	//CAMPO OPCIONAL
						IiF(Empty(aItensJson[nW]["CT2_EC05DB"]),{'CT2_EC05DB' ,'' , NIL},{'CT2_EC05DB' , aItensJson[nW]:GetJsonText("CT2_EC05DB") , NIL}),;	//CAMPO OPCIONAL
						IiF(Empty(aItensJson[nW]["CT2_EC05CR"]),{'CT2_EC05CR' ,'' , NIL},{'CT2_EC05CR' , aItensJson[nW]:GetJsonText("CT2_EC05CR") , NIL}),;	//CAMPO OPCIONAL
						IiF(Empty(aItensJson[nW]["CT2_EC06DB"]),{'CT2_EC06DB' ,'' , NIL},{'CT2_EC06DB' , aItensJson[nW]:GetJsonText("CT2_EC06DB") , NIL}),;	//CAMPO OPCIONAL
						IiF(Empty(aItensJson[nW]["CT2_EC06CR"]),{'CT2_EC06CR' ,'' , NIL},{'CT2_EC06CR' , aItensJson[nW]:GetJsonText("CT2_EC06CR") , NIL}),;	//CAMPO OPCIONAL
						IiF(Empty(aItensJson[nW]["CT2_EC07DB"]),{'CT2_EC07DB' ,'' , NIL},{'CT2_EC07DB' , aItensJson[nW]:GetJsonText("CT2_EC07DB") , NIL}),;	//CAMPO OPCIONAL
						IiF(Empty(aItensJson[nW]["CT2_EC07CR"]),{'CT2_EC07CR' ,'' , NIL},{'CT2_EC07CR' , aItensJson[nW]:GetJsonText("CT2_EC07CR") , NIL}),;	//CAMPO OPCIONAL
						IiF(Empty(aItensJson[nW]["CT2_EC08DB"]),{'CT2_EC08DB' ,'' , NIL},{'CT2_EC08DB' , aItensJson[nW]:GetJsonText("CT2_EC08DB") , NIL}),;	//CAMPO OPCIONAL
						IiF(Empty(aItensJson[nW]["CT2_EC08CR"]),{'CT2_EC08CR' ,'' , NIL},{'CT2_EC08CR' , aItensJson[nW]:GetJsonText("CT2_EC08CR") , NIL}),;	//CAMPO OPCIONAL
						IiF(Empty(aItensJson[nW]["CT2_EC09DB"]),{'CT2_EC09DB' ,'' , NIL},{'CT2_EC09DB' , aItensJson[nW]:GetJsonText("CT2_EC09DB") , NIL}),;	//CAMPO OPCIONAL
						IiF(Empty(aItensJson[nW]["CT2_EC09CR"]),{'CT2_EC09CR' ,'' , NIL},{'CT2_EC09CR' , aItensJson[nW]:GetJsonText("CT2_EC09CR") , NIL}),;	//CAMPO OPCIONAL
						{'CT2_FILORI' 	, aItensJson[nW]:GetJsonText("CT2_FILORI") , NIL} } )			//CAMPO OBRIGAT�RIO

					If Len(cHist) > nTamHist // Tratamento para continua��o de hist�rico
						//inteiro primeiro hist � gravado restando resultado da divis�o menos 1
						//decimal primeiro hist � gravado restando para grava��o resultado da divis�o
						IIf (((Len(cHist) / nTamHist) % 1 == 0),nQtdCoHist := (Len(cHist) / nTamHist) -1 ,nQtdCoHist := Len(cHist) / nTamHist)

						For nY := 1 to nQtdCoHist //adiciono no array a quantidade de linhas necess�ria para grava��o da continua��o de hist�rico
							cLinha := Soma1(cLinha)
							aAdd(aItens,  { {'CT2_FILIAL' , oContent[nZ]:GetJsonText("CT2_FILIAL") , NIL},; //CAMPO OBRIGAT�RIO
								{'CT2_LINHA' , cLinha , NIL},;			//CAMPO OBRIGAT�RIO
								{'CT2_MOEDLC' , "01" , NIL},;
								{'CT2_DC' , "4", NIL},;
								{'CT2_DEBITO' ,'' , NIL},;
								{'CT2_CREDIT' ,'' , NIL},;
								{'CT2_VALOR' , 0 , NIL},;
								{'CT2_ROTINA' , aItensJson[nW]["CT2_ROTINA"] , NIL},;							//CAMPO OBRIGAT�RIO
								{'CT2_ORIGEM' , "GESPLAN", NIL},;											//CAMPO DEFAULT
								{'CT2_CCD' ,'' , NIL},;
								{'CT2_CCC' ,'' , NIL},;
								{'CT2_ITEMD' ,'' , NIL},;
								{'CT2_ITEMC' ,'' , NIL},;
								{'CT2_CLVLDB' ,'' , NIL},;
								{'CT2_CLVLCR' ,'' , NIL},;
								{'CT2_AGLUT' ,'2' , NIL},;
								{'CT2_HP' ,'' , NIL},;
								{'CT2_CONVER' ,'5' , NIL},;
								{'CT2_TPSALD' , "1", NIL} ,;
								{'CT2_HIST' ,SubStr( cHist, (nY * nTamHist) + 1 , (nY * nTamHist) + nTamHist + 1 )  , NIL} ,;
								{'CT2_KEY' , aItensJson[nW]:GetJsonText("CT2_KEY") , NIL} ,;
								{'CT2_EMPORI' , aItensJson[nW]:GetJsonText("CT2_EMPORI") , NIL} ,;
								{'CT2_FILORI' , aItensJson[nW]:GetJsonText("CT2_FILORI") , NIL} } )
						Next nY
					EndIf
				Next nW
				lMsErroAuto := .F.
				MSExecAuto({|x, y,z| CTBA102(x,y,z)}, aCab ,aItens, 3)

				If lMsErroAuto
					aLog := GETAUTOGRLOG()
					If Len(aLog) > 0
						For nX := 1 To Len(aLog)
							cError += alltrim(aLog[nX]) + CRLF
						Next nX
					EndIf
					Aadd(aJson,JsonObject():new())
					nPos := Len(aJson)
					IiF(Empty(oContent[nZ]["ID"]),aJson[nPos]["ID"]:= 'Empty',aJson[nPos]["ID"]:= oContent[nZ]:GetJsonText("ID"))
					IiF(Empty(oContent[nZ]["EST"]),aJson[nPos]["EST"]:= 'Empty',aJson[nPos]["EST"]:= oContent[nZ]:GetJsonText("EST"))
					aJson[nPos]["COD_EMP"] := cEmpJson 
					aJson[nPos]["CT2_FILIAL"] := cFilJson
					aJson[nPos]["CT2_DOC"] := IIF(Empty(oContent[nZ]["CT2_DOC"]),"",oContent[nZ]["CT2_DOC"])
					aJson[nPos]["CT2_KEY"] := cCt2key
					aJson[nPos]["error"] := cError
				else
					Aadd(aJson,JsonObject():new())
					nPos := Len(aJson)
					IiF(Empty(oContent[nZ]["ID"]),aJson[nPos]["ID"]:= 'Empty',aJson[nPos]["ID"]:= oContent[nZ]:GetJsonText("ID"))
					IiF(Empty(oContent[nZ]["EST"]),aJson[nPos]["EST"]:= 'Empty',aJson[nPos]["EST"]:= oContent[nZ]:GetJsonText("EST"))
					aJson[nPos]["COD_EMP"] := cEmpJson 
					aJson[nPos]["CT2_FILIAL"] := cFilJson
					aJson[nPos]["CT2_DOC"] := CT2->CT2_DOC
					aJson[nPos]["CT2_KEY"] := cCt2key
					aJson[nPos]["error"] := ""
				EndIf
			Else
				Aadd(aJson,JsonObject():new())
				nPos := Len(aJson)
				IiF(Empty(oContent[nZ]["ID"]),aJson[nPos]["ID"]:= 'Empty',aJson[nPos]["ID"]:= oContent[nZ]:GetJsonText("ID"))
				IiF(Empty(oContent[nZ]["EST"]),aJson[nPos]["EST"]:= 'Empty',aJson[nPos]["EST"]:= oContent[nZ]:GetJsonText("EST"))
				aJson[nPos]["COD_EMP"] := cEmpJson 
				aJson[nPos]["CT2_FILIAL"] := cFilJson
				aJson[nPos]["CT2_DOC"] := IIF(Empty(oContent[nZ]["CT2_DOC"]),"",oContent[nZ]["CT2_DOC"])
				aJson[nPos]["CT2_KEY"] := cCt2key
				aJson[nPos]["error"] := aValid[2]
			EndIF

		Next nZ
	EndIf
	oResp:set(aJson)
	RespGesplan(oResp:toJSON(),cTenantId)
	FreeObj(oResp)
	aSize(aJson,0)
	aJson := nil
	aSize(aCab,0)
	aCab := nil
	aSize(aItens,0)
	aItens := nil
	aSize(aLog,0)
	aLog := nil
	aSize(aValid,0)
	aValid := nil
	aSize(aItensJson,0)
	aItensJson := nil

Return .T.

/*/
	�������������������������������������������������������������������������Ŀ��
	���Programa  �  RespGesplan � Autor �THIAGO BUSSOLIN    � Data � 22/08/2022 ���
	�������������������������������������������������������������������������Ĵ��
	���Descri��o � ENVIO DE RESPOSTA PARA GESPLAN AP�S EXECAUTO			      ���
	�������������������������������������������������������������������������Ĵ��
/*/
Static Function RespGesplan(oResp,cTenantId)
	Local oClient as object
	Local cMessage as character
	Local lSuccess as logical
	local cTimestamp := FWTimeStamp(5, DATE(), TIME())
	oClient := FwTotvsLinkClient():New()

	BeginContent Var cMessage
	{
	"specversion": "1.0",
	"time": "%Exp:cTimestamp%" ,
	"type": "CT2respXGsp",
	"tenantId": "%Exp:cTenantId%" ,
	"data": %Exp:oResp%
	}
	EndContent
	cMessage := FWhttpEncode(cMessage)
	lSuccess := oClient:SendAudience("CT2respXGsp","LinkProxy", cMessage)

Return


/*/
	�������������������������������������������������������������������������Ŀ��
	���Programa  �  ValidData � Autor �THIAGO BUSSOLIN    � Data � 22/08/2022 ���
	�������������������������������������������������������������������������Ĵ��
	��� Descri��o � Pr� valida campos obrigat�rios e tipos					  ���
	��� para a chamada do execauto  										  ���
	�������������������������������������������������������������������������Ĵ��
/*/
Static Function ValidData(oContent,cEmpJson,cFilJson,aItensJson,cCt2key)
	Local lRet := .T.
	Local cMsg := ""
	Local aSM0 := {}
	Local nY := 0

	//Valida��o de campos obrigat�rios
	//Capa do Lote
	IIf( Empty(oContent["COD_EMP"]),cMsg := STR0001 +"COD_EMP"+ STR0002,) 		//"| Campo " + " obrigat�rio |"
	IIf( Empty(oContent["CT2_FILIAL"]),cMsg += STR0001 +"CT2_FILIAL"+ STR0002,) //"| Campo " + " obrigat�rio |"
	IIf( Empty(oContent["CT2_DATA"]),cMsg   += STR0001 +"CT2_DATA"+ STR0002,)	//"| Campo " + " obrigat�rio |"
	
	//Itens
	If VALTYPE(aItensJson) == 'A'
		For nY := 1 to len(aItensJson)
			IIf( Empty(aItensJson[nY]["CT2_DC"]),cMsg += STR0001 +"CT2_DC"+ STR0002,IIF(aItensJson[nY]["CT2_DC"]=='1' .and. Empty(aItensJson[nY]["CT2_DEBITO"]),cMsg += STR0001 +"CT2_DEBITO"+ STR0002,; //"| Campo " + " obrigat�rio |"
			IIf(aItensJson[nY]["CT2_DC"]=='2' .and. Empty(aItensJson[nY]["CT2_CREDIT"]),cMsg += STR0001 +"CT2_CREDIT"+ STR0002,IIF(aItensJson[nY]["CT2_DC"]=='3' .and.(Empty(aItensJson[nY]["CT2_DEBITO"]).or. Empty(aItensJson[nY]["CT2_CREDIT"])),; //"| Campo " + " obrigat�rio |"
			cMsg += STR0001 +"CT2_CREDIT"+ STR0007 +"CT2_DEBITO" + STR0003,)))) //"| Campo " +  " e " +" obrigat�rio para Partida Dobrada|"

			IIf( Empty(aItensJson[nY]["CT2_VALOR"]),cMsg += STR0001 +"CT2_VALOR"+ STR0002,)   //"| Campo " + " obrigat�rio |"
			IIf( Empty(aItensJson[nY]["CT2_HIST"]),cMsg += STR0001 +"CT2_HIST"+ STR0002,)	    //"| Campo " + " obrigat�rio |"
			IIf( Empty(aItensJson[nY]["CT2_EMPORI"]),cMsg += STR0001 +"CT2_EMPORI"+ STR0002,) //"| Campo " + " obrigat�rio |"
			IIf( Empty(aItensJson[nY]["CT2_FILORI"]),cMsg += STR0001 +"CT2_FILORI"+ STR0002,) //"| Campo " + " obrigat�rio |"
			IIf( Empty(aItensJson[nY]["CT2_KEY"]),cMsg += STR0001 +"CT2_KEY"+ STR0002,)		//"| Campo " + " obrigat�rio |"
			IIf( Empty(aItensJson[nY]["CT2_ROTINA"]),cMsg += STR0001 +"CT2_ROTINA"+ STR0004,) //"| Campo " + " obrigat�rio. Enviar: WFNFIN ou WFNCASH ou WFNLEAS |"
		NEXT ny
		cCt2key := aItensJson[1]:GetJsonText("CT2_KEY")
	Else
		cMsg += STR0001 + "ITENS" + STR0002 //"| Campo " + " obrigat�rio. 
	EndIf

	If Empty(cMsg)
		//Valida��o de tipos
		//Capa do Lote
		IIf( VALTYPE(oContent["COD_EMP"])=="C",,cMsg += STR0001 +"COD_EMP"+ STR0005) 	   //"| Campo " + " tipo inv�lido|"
		IIf( VALTYPE(oContent["CT2_FILIAL"])=="C",,cMsg += STR0001 +"CT2_FILIAL"+ STR0005) //"| Campo " + " tipo inv�lido|"
		IIf( VALTYPE(oContent["CT2_DATA"])=="C",,cMsg   += STR0001 +"CT2_DATA"+ STR0005)   //"| Campo " + " tipo inv�lido|"
		
		//Itens
		For nY := 1 to len(aItensJson)
			IIf(!VALTYPE(aItensJson[nY]["CT2_DC"])=="C",cMsg += STR0001 +"CT2_DC"+ STR0005,IIF(aItensJson[nY]["CT2_DC"]=='1' .and. !VALTYPE(aItensJson[nY]["CT2_DEBITO"])=="C",cMsg += STR0001 +"CT2_DEBITO"+ STR0005,; //"| Campo " + " tipo inv�lido|"
			IIf(aItensJson[nY]["CT2_DC"]=='2' .and. !VALTYPE(aItensJson[nY]["CT2_CREDIT"])=="C",cMsg += STR0001 +"CT2_CREDIT"+ STR0005,IIF(aItensJson[nY]["CT2_DC"]=='3' .and.(!VALTYPE(aItensJson[nY]["CT2_DEBITO"]) == "C".or. !VALTYPE(aItensJson[nY]["CT2_CREDIT"])=="C"),; //"| Campo " + " tipo inv�lido|"
			cMsg += STR0001 +"CT2_CREDIT"+ STR0006 +"CT2_DEBITO"+ STR0005,)))) //"| Campo " + " ou " + " tipo inv�lido|"

			IIf( VALTYPE(aItensJson[nY]["CT2_VALOR"])=="N",,cMsg += STR0001 +"CT2_VALOR"+ STR0005)	//"| Campo " + " tipo inv�lido|"
			IIf( VALTYPE(aItensJson[nY]["CT2_HIST"])=="C",,cMsg += STR0001 +"CT2_HIST"+ STR0005)		//"| Campo " + " tipo inv�lido|"
			IIf( VALTYPE(aItensJson[nY]["CT2_EMPORI"])=="C",,cMsg += STR0001 +"CT2_EMPORI"+ STR0005)  //"| Campo " + " tipo inv�lido|"
			IIf( VALTYPE(aItensJson[nY]["CT2_FILORI"])=="C",,cMsg += STR0001 +"CT2_FILORI"+ STR0005)  //"| Campo " + " tipo inv�lido|"
			IIf( VALTYPE(aItensJson[nY]["CT2_KEY"])=="C",,cMsg += STR0001 +"CT2_KEY"+ STR0005)		//"| Campo " + " tipo inv�lido|"
			IIf( VALTYPE(aItensJson[nY]["CT2_ROTINA"])=="C",,cMsg += STR0001 +"CT2_ROTINA"+ STR0005)	//"| Campo " + " tipo inv�lido|"

		NEXT ny
		
	EndIf

	If Empty(cMsg)

		If !validSM0(@cEmpJson,@cFilJson)
			lRet := .F.
			// ConOut(STR0008+' '+cEmpJson+' | '+cFilJson +' |')
			cMsg := STR0008+' '+cEmpJson+' | '+cFilJson +' |'//"| Empresa ou Filial n�o foram encontradas |"
		EndIf
	Else
		lRet := .F.
	EndIf

	aSize(aSM0,0)
	aSM0 := nil

Return {lRet,cMsg}

/*/{Protheus.doc} validSM0
Fun��o auxiliar para valida��o do grupo de empresa + filial
@type  Function
@author Nilton Rodrigues
@since 08/05/2023
@version 1.0
@param cEmpJson, Char, C�digo da empresa/grupo
@param cFilJson, Char, C�digo da filial
@return lOk, logical, retorna true na sua exist�ncia e falso n�o existindo
/*/
static function validSM0(cEmpJson,cFilJson)
	local aAreaSM0 as array
	local cWorkarea as char
	local lOk as logical

	if !FWDbConnectionManagement():HasConnection()
		FWDbConnectionManagement():Connect()
	endif

	cWorkarea := Alias()

	OpenSM0()

	aAreaSM0 := SM0->(FWGetArea())

	SM0->(DBSetOrder(1))
	cEmpJson := Padr(cEmpJson,Len(SM0->M0_CODIGO))
	cFilJson := Padr(cFilJson,Len(SM0->M0_CODFIL))
	
	lOk      := SM0->(DBSeek(cEmpJson+cFilJson))

	FWRestArea(aAreaSM0)
	FWRestAlias(cWorkarea)

return lOk
