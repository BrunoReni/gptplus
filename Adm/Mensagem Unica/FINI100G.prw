#INCLUDE "Protheus.CH"
#include "TOTVS.ch"
#include "TBICONN.ch"

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
Classe de Integração com Gesplan via smartlink

@author TOTVS
@since 09/2022
@version 1.0
/*/
//-----------------------------------------------------------------------------------------
Class MOVreadXGspMessageReader from LongNameClass
 
    method New() Constructor
    method Read()
 
End Class
											

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe

@author TOTVS
@since 09/2022
@version 1.0
/*/
//-----------------------------------------------------------------------------------------
Method New() Class MOVreadXGspMessageReader
 
Return Self
 

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} Read()
Responsável pela leitura e processamento da mensagem.

@author TOTVS
@since 09/2022
@version 1.0
@param oLinkMessage, object, Instância de FwTotvsLinkMesage da mensagem
@return logical, sucesso ou falha. Determina se deve ou não retirar a mensagem da fila.
/*/
//-----------------------------------------------------------------------------------------
Method Read( oLinkMessage ) Class MOVreadXGspMessageReader

	Local nX 				As Numeric
	Local nZ 				As Numeric
	Local nPos 				As Numeric
	Local cError 			As Character
	Local cTenantId			As Character
	Local cEmp				As Character
	Local cFil				As Character
	Local aSM0				As Array
	Local aCab 				As Array
	Local aDados 			As Array
	Local aLog 				As Array
	local aJson				As Array
	Local oResp 			As Object
	Local oContent 			As Object
	Private lMsErroAuto     As Logical
	Private lMsHelpAuto		As Logical
	Private lAutoErrNoFile	As Logical

	nX 		 := 0
	nZ 		 := 0  
	nPos	 :=0	
	cError 	 := ""
	cEmp 	 := ""
	cFil 	 := ""
	aSM0	 := {}
	aCab 	 := {}
	aDados	 := {}
	aLog 	 := {}
	aJson 	 := {}
	oResp 	 := JsonObject():new()
	oContent := JsonObject():new()

    oContent:FromJSON(oLinkMessage:RawMessage())
    cTenantId 	:= oContent['tenantId']
    oContent 	:= oContent['data']
	lMsErroAuto		:= .F.
	lMsHelpAuto		:= .T.
	lAutoErrNoFile	:= .T.	

    // ConOut( oLinkMessage:RawMessage())
    // ConOut( oLinkMessage:Header():toJson())
    // ConOut( oLinkMessage:Content():toJson())
    // ConOut( oLinkMessage:Type())
    // ConOut( oLinkMessage:tenantId())
    // ConOut( oLinkMessage:requestID())
	aSM0 := AdmAbreSM0()    	

	//-- Organiza os dados da mensagem por Empresa+Filial
	For	nZ := 1 To len(oContent)
		Aadd(aDados,{	.T.,;
						oContent[nZ]:GetJsonText("COD_EMP"),; 	// 2
						oContent[nZ]:GetJsonText("E5_FILIAL"),;	// 3
						oContent[nZ]:GetJsonText("E5_VALOR"),;	// 4
						oContent[nZ]:GetJsonText("E5_MOEDA"),;	// 5
						oContent[nZ]:GetJsonText("E5_DATA"),;	// 6
						oContent[nZ]:GetJsonText("E5_NATUREZ"),;// 7
						oContent[nZ]:GetJsonText("E5_BANCO"),;	// 8
						oContent[nZ]:GetJsonText("E5_AGENCIA"),;// 9
						oContent[nZ]:GetJsonText("E5_CONTA"),;	// 10
						oContent[nZ]:GetJsonText("E5_CCUSTO"),;	// 11
						oContent[nZ]:GetJsonText("E5_BENEF"),;	// 12
						oContent[nZ]:GetJsonText("E5_HISTOR"),;	// 13
						oContent[nZ]:GetJsonText("E5_RECPAG"),;	// 14
						oContent[nZ]:GetJsonText("SYSCODE"),;	// 15
						oContent[nZ]:GetJsonText("ID"),;	// 16
						'';// Mensagem de erro
					})

		If (nPos:=aScan(aSM0,  { |x| Alltrim(x[1])+x[2] == AllTrim(aDados[Len(aDados),2]) + PadR(aDados[Len(aDados),3],x[8])  })) == 0
			aDados[Len(aDados),1]	:= .F.
			aDados[Len(aDados),17]	:= "| Empresa ou Filial não foram encontradas |"
		Else
			aDados[Len(aDados),3]:=PadR(aDados[Len(aDados),3],aSM0[nPos,8])
		EndIF
	Next nZ
	//-- Ordena para evitar chamadas do RpcSetEnv 
	aSort(aDados,,,{|x,y| x[2]+x[3] < y[2]+y[3] })


	For	nZ := 1 To Len(aDados)
		If aDados[nZ,1] //-- Empresa/Filial válidos
			cError 	:= ""
			aCab 	:= {} 
			
			If cEmp+cFil<>aDados[nZ,2] +aDados[nZ,3] //-- Mudou Empresa/Filial
				cEmp:=aDados[nZ,2]
				cFil:=aDados[nZ,3]

				RpcClearEnv()
				RpcSetEnv( cEmp, cFil,,,'FIN')				
			EndIF

			SetFunName("FINI100G") 
			aAdd(aCab, 	{'E5_VALOR'		,Val(aDados[nZ,4])	,Nil })	
			aAdd(aCab,  {'E5_MOEDA'		,aDados[nZ,5]  		,Nil })				
			aAdd(aCab, 	{'E5_DATA'		,CtoD(aDados[nZ,6])	,Nil })	
			aAdd(aCab, 	{'E5_NATUREZ'	,aDados[nZ,7] 		,Nil })				
			aAdd(aCab, 	{'E5_BANCO'		,aDados[nZ,8] 		,Nil })					
			aAdd(aCab, 	{'E5_AGENCIA'	,aDados[nZ,9] 		,Nil })				
			aAdd(aCab, 	{'E5_CONTA'		,aDados[nZ,10]		,Nil })						
			If aDados[nZ,11]<>'null'
				 aAdd(aCab,	{'E5_CCUSTO' ,aDados[nZ,11]  	,Nil }) 
			EndIf
			If aDados[nZ,12]<>'null'
				aAdd(aCab, 	{'E5_BENEF' 	,aDados[nZ,12]		,NIL})
			EndIF
			If aDados[nZ,13]<>'null'			
				aAdd(aCab, 	{'E5_HISTOR' 	,aDados[nZ,13]		,NIL})
			EndIF

			nOpc:=Iif(aDados[nZ,14]=='S',3,4) //EventType
			lMsErroAuto	:=.F.				
			MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aCab, nOpc ) //3 Pagar // 4 Receber

			// Response
			Aadd(aJson,JsonObject():new())
			aJson[Len(aJson)]["COD_EMP"] 	:= cEmp
			aJson[Len(aJson)]["E5_FILIAL"] 	:= cFil
			aJson[Len(aJson)]["SYSCODE"] 	:= aDados[nZ,15]
			aJson[Len(aJson)]["ID"] 		:= aDados[nZ,16]
			If lMsErroAuto
				aLog := GetAutoGRLog()
				For nX := 1 To Len(aLog)
					cError += alltrim(aLog[nX]) + CRLF
				Next nX				
				aJson[Len(aJson)]["error"] 		:= cError
			Else 
				aJson[Len(aJson)]["error"] 		:= ''
			EndIf
		Else
			Aadd(aJson,JsonObject():new())
			aJson[Len(aJson)]["COD_EMP"] 	:= aDados[nZ,2]
			aJson[Len(aJson)]["E5_FILIAL"] 	:= aDados[nZ,3]
			aJson[Len(aJson)]["SYSCODE"] 	:= aDados[nZ,15]
			aJson[Len(aJson)]["ID"] 		:= aDados[nZ,16]
			aJson[Len(aJson)]["error"] 		:= aDados[nZ,17]
		EndIF
			
	Next nZ

	If Len(aJson)>0//-- Envia mensagem para a fila MovRespXGsp
		oResp:set(aJson)
		RespGesplan(oResp:toJSON(), cTenantId ) 		
		FreeObj(oResp)
	EndIF

	FwFreeArray(aCab)
	FwFreeArray(aDados)
	FwFreeArray(aLog)
	FwFreeArray(aJson)

Return .T. // .T. apaga a mensagem da fila do smartlink


//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} RespGesplan()
Resposta da mensagem

@author TOTVS
@since 09/2022
@version 1.0
/*/
//-----------------------------------------------------------------------------------------
Static Function RespGesplan(oResp,cTenantId)

	Local oClient	 As Object
    Local lSuccess	 As Logical	
	Local cMessage	 As Character
	local cTimestamp As Character 

	cMessage	:= ""
	oClient		:= FwTotvsLinkClient():New()
	cTimestamp	:= FWTimeStamp(5, Date(), Time())	
	
	BeginContent Var cMessage
	{
		"specversion": "1.0",
		"time": "%Exp:cTimestamp%" ,
		"type": "MOVrespXGsp",
		"tenantId": "%Exp:cTenantId%" ,
		"data": %Exp:oResp%
	}
	EndContent

    lSuccess := oClient:SendAudience("MOVrespXGsp","LinkProxy", cMessage)
	FreeObj(oClient)

Return
