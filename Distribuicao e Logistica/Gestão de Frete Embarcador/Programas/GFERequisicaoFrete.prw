#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"

Function GFERequisicaoFrete()
Return Nil
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc}GFERequisicaoFrete()

@author Leonardo Ribas Jimenez Hernandez
@since 29/5/2018
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------
CLASS GFERequisicaoFrete FROM LongNameClass 
	
	DATA cIdReq
	DATA cCodUsu
	Data cFil
	DATA cSitRes
	DATA cMotRej
	DATA cMotCanc
	DATA cNewSitRes
	DATA lStatus
	DATA cMensagem

	METHOD New() CONSTRUCTOR
	METHOD ClearData()
	METHOD Destroy(oObject)
   
	METHOD ValNegociacao()
	METHOD validCancel()
	METHOD changeResultSituation()
	METHOD changeSituation()
	
	METHOD setIdReq(cIdReq)
	METHOD setCodUsu(cCodUsu)
	METHOD setFil(cFil)
	METHOD setSitRes(cSitRes)
	METHOD setMotRej(cMotRej)
	METHOD setMotCanc(cMotCanc)
	METHOD setNewSitRes(cNewSitRes)
   	METHOD setStatus(lStatus)
	METHOD setMensagem(cMensagem)

	METHOD getIdReq()
	METHOD getCodUsu()
	METHOD getFil()
	METHOD getSitRes()
	METHOD getMotRej()
	METHOD getMotCanc()
	METHOD getNewSitRes()
	METHOD getStatus()
	METHOD getMensagem()

ENDCLASS

METHOD New() Class GFERequisicaoFrete
   Self:ClearData()
Return

METHOD Destroy(oObject) CLASS GFERequisicaoFrete
   FreeObj(oObject)
Return

METHOD ClearData() Class GFERequisicaoFrete
	Self:setIdReq("")
	Self:setCodUsu("")
	Self:setFil("")
	Self:setSitRes("")
	Self:setMotRej("")
	Self:setNewSitRes("")
	Self:setStatus(.T.)
	Self:setMensagem("")
Return

//-----------------------------------
// M�todos de Neg�cio
//-----------------------------------
METHOD ValNegociacao() Class GFERequisicaoFrete
	If (!Empty(Self:getIdReq()))
		GXR->(dbSetOrder(1))
		If GXR->(dbSeek(xFilial("GXR") + Self:getIdReq()))
			
			If !Empty(GXR->GXR_CODUSU) .And. (AllTrim(GXR->(GXR_CODUSU)) <> Self:getCodUsu())
				Self:setStatus(.F.)
				Self:setMensagem("Esta requisi��o n�o est� vinculada ao seu usu�rio.")
				Return
			EndIf
			
			If GXR->(GXR_SIT != "4")
				Self:setStatus(.F.)
				Self:setMensagem("A requisi��o est� diferente do estado Atendida. N�o � poss�vel aceitar ou recusar essa negocia��o.")
				Return
			EndIf
			
			If GXR->(GXR_SITRES) == Self:getNewSitRes() .And. GXR->(GXR_SITRES) == "1"
				Self:setStatus(.F.)
				Self:setMensagem("A requisi��o j� foi aceita.")
				Return
			ElseIf GXR->(GXR_SITRES) == Self:getNewSitRes() .And. GXR->(GXR_SITRES) == "2"
				Self:setStatus(.F.)
				Self:setMensagem("A requisi��o j� foi recusada.")
				Return
			EndIf
			
			If GXR->(GXR_SITRES == "1")
				Self:setMensagem("Requisi��o j� foi aceita.")
				Return
			ElseIf GXR->(GXR_SITRES == "2") 
				Self:setMensagem("Requisi��o j� foi recusada.")
				Return
			EndIf
		EndIf
		
		Self:setStatus(.T.)
		Self:setMensagem("")
	EndIf	
Return

METHOD validCancel() Class GFERequisicaoFrete
	If (!Empty(Self:getIdReq()))
		GXR->(dbSetOrder(1))
		If GXR->(dbSeek(xFilial("GXR") + Self:getIdReq()))
		
			// Como a fun��o � executada pela pr�pria rotina, o registro j� est� posicionado.
			// quando a fun��o for chamada externamente, dever� posicionar no registro para depois executar a a��o.
			If !Empty(Self:getFil())
				GXR->(dbSetOrder(1))
				If !GXR->(dbSeek(Self:getFil() + Self:getIdReq()))
					Self:setMensagem("Requisi��o de Negocia��o de Frete n�o existe na base de dados! Verifique os dados informados. Filial:("+ Self:getFil() +") Requisi��o:("+ Self:getIdReq() +") ")
					Self:setStatus(.F.)
					Return
				EndIf
			EndIf
			
			If GXR->GXR_SIT == '5' //cancelada
				Self:setMensagem("Requisi��o de Negocia��o de Frete n�o pode ser cancelada, pois j� se encontra nesta situa��o.")
				Self:setStatus(.F.)
				Return
			EndIf
			
			If GXR->GXR_SIT != "3" .And. GXR->GXR_SIT != "2" //em negocia��o e requisitada
				Self:setMensagem("A Requisi��o de Negocia��o de Frete n�o pode ser cancelada, pois somente requisi��es Em Negocia��o ou Requisitada podem ser canceladas.")
				Self:setStatus(.F.)
				Return
			EndIf
		EndIf
		Self:setStatus(.T.)
		Self:setMensagem("")
	EndIf	
Return

METHOD changeResultSituation() Class GFERequisicaoFrete
	GXR->(dbSetOrder(1))
	If GXR->(dbSeek(xFilial("GXR") + Self:getIdReq()))
		RecLock("GXR", .F.)
			GXR->GXR_SITRES	:= Self:getSitRes()
			GXR->GXR_MOTREJ 	:= Self:getMotRej()
		GXR->(MsUnlock())	
	EndIf
Return

METHOD changeSituation() Class GFERequisicaoFrete
	GXR->(dbSetOrder(1))
	If GXR->(dbSeek(xFilial("GXR") + Self:getIdReq()))
		RecLock("GXR", .F.)
			GXR->GXR_SIT		:= Self:getSitRes()
			GXR->GXR_MOTCAN 	:= Self:getMotCanc()
		GXR->(MsUnlock())	
	EndIf
Return

//-----------------------------------
//Setters
//-----------------------------------
METHOD setIdReq(cIdReq) CLASS GFERequisicaoFrete
   Self:cIdReq := cIdReq
Return

METHOD setCodUsu(cCodUsu) CLASS GFERequisicaoFrete
   Self:cCodUsu := cCodUsu
Return

METHOD setFil(cFil) CLASS GFERequisicaoFrete
	Self:cFil := cFil
Return

METHOD setSitRes(cSitRes) CLASS GFERequisicaoFrete
   Self:cSitRes := cSitRes
Return

METHOD setMotRej(cMotRej) CLASS GFERequisicaoFrete
   Self:cMotRej := cMotRej
Return

METHOD setMotCanc(cMotCanc) CLASS  GFERequisicaoFrete
	Self:cMotCanc := cMotCanc
Return

METHOD setNewSitRes(cNewSitRes) CLASS GFERequisicaoFrete
   Self:cNewSitRes := cNewSitRes
Return

METHOD setStatus(lStatus) CLASS GFERequisicaoFrete
   Self:lStatus := lStatus
Return

METHOD setMensagem(cMensagem) CLASS GFERequisicaoFrete
   Self:cMensagem := cMensagem
Return

//-----------------------------------
//Getters
//-----------------------------------
METHOD getIdReq() CLASS GFERequisicaoFrete
Return Self:cIdReq

METHOD getCodUsu() CLASS GFERequisicaoFrete
Return Self:cCodUsu

METHOD getFil() CLASS GFERequisicaoFrete
Return Self:cFil

METHOD getSitRes() CLASS GFERequisicaoFrete
Return Self:cSitRes

METHOD getMotRej() CLASS GFERequisicaoFrete
Return Self:cMotRej

METHOD getMotCanc() CLASS GFERequisicaoFrete
Return Self:cMotCanc

METHOD getNewSitRes() CLASS GFERequisicaoFrete
Return Self:cNewSitRes

METHOD getStatus() CLASS GFERequisicaoFrete
Return Self:lStatus

METHOD getMensagem() CLASS GFERequisicaoFrete
Return Self:cMensagem