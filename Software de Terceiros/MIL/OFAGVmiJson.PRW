#include "protheus.ch"

function OFAGVmiJson()
return .t.

/*/{Protheus.doc} mil_ver()
		Versao do fonte modelo novo

		@author Vinicius Gati
		@since  23/03/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "1"

/*/{Protheus.doc} OFAGVmiJson
	Ser� usada para persistir o json na tabela VB6 e al�m disso vai poder recriar o json
	atrav�s dos parametros recebidos para gera��o do mesmo.

	//TODO: documentar a engenharia reversa dos jsons gerados

	@author Vinicius Gati
	@since 12/06/2017
/*/
Class OFAGVmiJson
	Data aMapValid
	Data oJsonHelper
	Data oLog
	Data lDebug

	Method New() CONSTRUCTOR
	Method Persist()
	Method Exist()
EndClass

Method New() Class OFAGVmiJson
	::oJsonHelper := DMS_VmiJson():New()
	::oLog        := DMS_Logger():New("DEBUG_VMI_"+DTOS(DATE())+"_"+STRTRAN(TIME(), ":", "")+".LOG")
	::lDebug      := "VMI" $ GetNewPar("MV_MILDBG", "NAO")
return self

/*/{Protheus.doc} Persist
	Ser� usada para criar o VB6 dos jsons que dever�o ser enviados
	@author Vinicius Gati
	@since 19/06/2017
	@param cInterface, String , Representa��o da interface
	@param oParams, DMS_DataContainer, Parametros usados para gera��o dos JSONs<br>
		poder� ser usado para gerar novamente o JSON em caso de erros
/*/
Method Persist(cInterface, oParams, aJsons, cNumContr) class OFAGVmiJson
	Local cQuery := ""
	Local nIdx := 1
	Local cJsonInt := ""
	Local cVB6_CODIGO := ""
	Local oVmi := OFAGVmi():New()
	Local lEnvia := ( GetNewPar("MV_MIL0171","0") == "1" ) // Envia automaticamente o VMI no momento da execu��o dos processos. 1=Sim / 0=Nao
	default cNumContr := '0'

	dbSelectArea('VB6')
	if cNumContr == '0'
		cNumContr := Soma1(FM_SQL("SELECT MAX(VB6_NCONTR) FROM "+RetSqlName('VB6')+" WHERE VB6_FILIAL = '"+xFilial('VB6')+"' AND D_E_L_E_T_ = ' '")) // �nico para todos os aJsons que ser�o salvos
	end
	cHora    := SUBSTR(time(), 1, 2)
	cMinutos := SUBSTR(time(), 4, 2)
	cJson    := self:oJsonHelper:toJson(oParams)

	if self:lDebug
		self:oLog:Log({""}) // pular linha
	end

	for nIdx := 1 to LEN(aJsons)
		oJson := aJsons[nIdx]
		oJson := DMS_DataContainer():New({{'data', oJson}}) // todos os endpoints tem o atributo data

		cJsonInt := self:oJsonHelper:toJson(oJson)

		if self:lDebug
			self:oLog:Log({"TIMESTAMP", cJsonInt})
		end

		cQuery := "SELECT COUNT(VB6_CONTRO) "
		cQuery += "  FROM " + RetSqlName('VB6') 
		cQuery += " WHERE VB6_FILIAL = '"+xFilial('VB6')+"' "
		cQuery += "   AND VB6_CONTRO = '"+cJson+"' "
		cQuery += "   AND VB6_FLGENV = '0' "
		cQuery += "   AND D_E_L_E_T_ = ' ' "
		If FM_SQL(cQuery) == 0 // N�o incluir Registro Igual se nao enviou ainda

			cVB6_CODIGO := Soma1(FM_SQL("SELECT MAX(VB6_CODIGO) FROM "+RetSqlName('VB6')+" WHERE VB6_FILIAL = '"+xFilial('VB6')+"' AND D_E_L_E_T_ = ' '"))

			reclock("VB6", .T.)
			VB6->VB6_FILIAL  := xFilial('VB6')
			VB6->VB6_CODIGO  := cVB6_CODIGO
			VB6->VB6_DATA    := DATE()
			VB6->VB6_HORA    := VAL(cHora+cMinutos)
			VB6->VB6_INTERF  := cInterface
			VB6->VB6_ORIGEM  := oParams:GetValue('ORIGEM', "ND")
			VB6->VB6_JSON    := cJsonInt
			VB6->VB6_FLGENV  := '0'
			VB6->VB6_CONTRO  := cJson
			VB6->VB6_NCONTR  := cNumContr // usado para saber quais jsons foram gerados em conjunto
			VB6->VB6_IMPEDI  := '0'
			VB6->(msunlock())

			VB6->(dbGoTo(VB6->(Recno())))

			If lEnvia // Envia automaticamente o VMI no momento da execu��o dos processos.
				oVmi:Enviar({{ "RECNO" , VB6->(Recno()) }}) // Enviar VMI
			EndIf

		EndIf

	next
	if self:lDebug
		self:oLog:Log({""}) // pular linha
	end
Return cNumContr

/*/{Protheus.doc} Exist
	Verifica se a informa��o que ser� gerada j� existe na base e est� pendente de envio a agco

	@type function
	@author Vinicius Gati
	@since 05/02/2019
/*/
Method Exist(oParams) Class OFAGVmiJson
	local cContro := self:oJsonHelper:toJson(oParams)
	local cQuery  := ""
	cQuery += "SELECT COUNT(VB6_FILIAL) "
	cQuery += "  FROM " + RetSqlName('VB6') 
	cQuery += " WHERE VB6_FILIAL = '"+xFilial('VB6')+"' "
	cQuery += "   AND VB6_CONTRO = '"+cContro+"' "
	cQuery += "   AND D_E_L_E_T_ = ' ' "
Return FM_SQL(cQuery) > 0