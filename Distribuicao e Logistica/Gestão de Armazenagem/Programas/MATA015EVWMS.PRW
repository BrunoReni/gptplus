#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA015EVWMS.CH"

#DEFINE MA015WMS01 "MA015WMS01"
#DEFINE MA015WMS02 "MA015WMS02"
#DEFINE MA015WMS03 "MA015WMS03"
#DEFINE MA015WMS04 "MA015WMS04"
#DEFINE MA015WMS05 "MA015WMS05"
#DEFINE MA015WMS06 "MA015WMS06"
#DEFINE MA015WMS07 "MA015WMS07"
#DEFINE MA015WMS08 "MA015WMS08"

//-------------------------------------------------------------------
CLASS MATA015EVWMS FROM FWModelEvent
	// Atributos
	DATA nOperation
	DATa lWmsNew
	// M�todos
	METHOD New() CONSTRUCTOR
	METHOD VldActivate(oModel, cModelId)
	METHOD ModelPosVld(oModel, cModelId)
	METHOD AvalStsEnd(oModel)
ENDCLASS

METHOD New()�CLASS MATA015EVWMS
	Self:lWmsNew := SuperGetMv("MV_WMSNEW",.F.,.F.)
Return

//-------------------------------------------------------------------
// M�todo que � chamado pelo MVC nas valida��es de ativa��o do Model
//-------------------------------------------------------------------
METHOD VldActivate(oModel, cModelId) CLASS MATA015EVWMS
Local aAreaAnt  := GetArea()
Local dDataFec  := Nil
Local cAliasQry := ""
Local cQuery    := ""
Local lRet      := .T.

	Self:nOperation := oModel:GetOperation()
	
	If !(Self:nOperation == MODEL_OPERATION_DELETE)
		Return .T.
	EndIf

	If Self:lWmsNew .And. !(Empty(SBE->BE_CODZON) .And. Empty(SBE->BE_ESTFIS))
		// Busca a data do �ltimo fechamento de estoque
		dDataFec := MVUlmes()
		// Avalia os movimentos de distribui��o WMS
		cQuery := "SELECT 1 "
		cQuery +=  " FROM "+RetSqlName("D12")+" D12"
		cQuery += " WHERE D12.D12_FILIAL   = '"+xFilial("D12")+"'"
		cQuery +=   " AND ((D12.D12_LOCORI = '"+SBE->BE_LOCAL+"' AND D12_ENDORI = '"+SBE->BE_LOCALIZ+"') OR "
		cQuery +=         "(D12.D12_LOCDES = '"+SBE->BE_LOCAL+"' AND D12_ENDDES = '"+SBE->BE_LOCALIZ+"'))"
		cQuery +=   " AND D12.D12_STATUS  IN ('-','3','2','4')"
		cQuery +=   " AND D12.D_E_L_E_T_   = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T. )
		If !(cAliasQry)->(Eof())
			oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,MA015WMS01,STR0001,STR0002) // "Este endere�o n�o pode ser exclu�do, pois possui movimenta��es WMS pendentes." // "Estorne os movimentos WMS e realize uma nova tentativa."
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
		// Avalia as movimenta��es de estoque WMS
		If lRet
			cQuery := "SELECT 1"
			cQuery +=  " FROM "+RetSqlName("D13")+" D13"
			cQuery += " WHERE D13.D13_FILIAL = '"+xFilial("D13")+"'"
			cQuery +=   " AND D13.D13_LOCAL  = '"+SBE->BE_LOCAL+"'"
			cQuery +=   " AND D13.D13_ENDER  = '"+SBE->BE_LOCALIZ+"'"
			cQuery +=   " AND D13.D13_DTESTO > '"+DtoS(dDataFec)+"'"
			cQuery +=   " AND D13.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery( cQuery )
			cAliasQry := GetNextAlias()
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T. )
			If !(cAliasQry)->(Eof())
				oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,MA015WMS02,STR0003,STR0004) // "Este endere�o n�o pode ser exclu�do, pois possui movimenta��es de estoque posteriores ao �ltimo fechamento." // "Realize uma nova tentativa depois do pr�ximo fechamento de estoque."
				lRet := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
	EndIf

RestArea(aAreaAnt)
Return lRet

//-------------------------------------------------------------------
// M�todo que � chamado pelo MVC quando ocorrer as a��es de pos valida��o do Model
//-------------------------------------------------------------------
METHOD ModelPosVld(oModel, cModelId) CLASS MATA015EVWMS
Local oModelFld := Nil
Local cCodZon   := ""
Local cCodCfg   := ""
Local nAltura   := 0
Local nLargura  := 0
Local nComprim  := 0
Local aValNiv   := {}

	If (Self:nOperation == MODEL_OPERATION_UPDATE .And. SBE->BE_ESTFIS <> FwFldGet("BE_ESTFIS")) .Or.;
	    Self:nOperation == MODEL_OPERATION_DELETE
		// Verifica se o endere�o possui saldo na estrutura f�sica
		If WmsChkSBE(SBE->BE_LOCAL,NIL,NIL,SBE->BE_ESTFIS,NIL,NIL,NIL,Nil,NIL,,SBE->BE_LOCALIZ)
			If Self:nOperation == MODEL_OPERATION_DELETE
				oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,MA015WMS03,STR0005,STR0006) // "Este endere�o n�o pode ser exclu�do, pois possui saldo na estrutura f�sica." // "Remova o saldo do endere�o antes de continuar."
			Else
				oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,MA015WMS04,STR0007,STR0006) // "Este endere�o n�o pode ser alterado, pois possui saldo na estrutura f�sica." // "Remova o saldo do endere�o antes de continuar."
			EndIf
			Return .F.
		EndIf
	EndIf

	If Self:nOperation == MODEL_OPERATION_INSERT .Or. Self:nOperation == MODEL_OPERATION_UPDATE

		oModelFld := oModel:GetModel("MdFieldSBE")
		cCodZon   := oModelFld:GetValue("BE_CODZON" )
		cCodCfg   := oModelFld:GetValue("BE_CODCFG" )
		nAltura   := oModelFld:GetValue("BE_ALTURLC")
		nLargura  := oModelFld:GetValue("BE_LARGLC" )
		nComprim  := oModelFld:GetValue("BE_COMPRLC")

		If !Empty(cCodZon) .And. !Empty(cCodCfg) .And. (nAltura > 999 .Or. nLargura > 999 .Or. nComprim > 999)
			oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,MA015WMS05,STR0008,STR0009) // "As informa��es de Altura, Largura e Comprimento dos endere�os n�o pode ser maior do que 999 metros." // "Informe um valor v�lido para estes campos."
			Return .F.
		EndIf

		If !Self:AvalStsEnd(oModel)
			Return .F.
		EndIf

		// Na inclus�o de um novo endere�o com controle WMS ou na altera��o do mesmo, caso n�o
		// tenha feito isso inclus�o, deve calcular os valores de n�vel para os endere�os.
		If !Empty(oModel:GetModel("MdFieldSBE"):GetValue("BE_CODZON")) .And. !Empty(oModel:GetModel("MdFieldSBE"):GetValue("BE_ESTFIS"))
			aValNiv := DLXCfgEnd(oModel:GetModel("MdFieldSBE"):GetValue("BE_CODCFG"), oModel:GetModel("MdFieldSBE"):GetValue("BE_LOCALIZ"))
			oModel:GetModel("MdFieldSBE"):SetValue("BE_VALNV1",If(Len(aValNiv)> 0,Int(aValNiv[1,1]),0))
			oModel:GetModel("MdFieldSBE"):SetValue("BE_VALNV2",If(Len(aValNiv)> 1,Int(aValNiv[2,1]),0))
			oModel:GetModel("MdFieldSBE"):SetValue("BE_VALNV3",If(Len(aValNiv)> 2,Int(aValNiv[3,1]),0))
			oModel:GetModel("MdFieldSBE"):SetValue("BE_VALNV4",If(Len(aValNiv)> 3,Int(aValNiv[4,1]),0))
			oModel:GetModel("MdFieldSBE"):SetValue("BE_VALNV5",If(Len(aValNiv)> 4,Int(aValNiv[5,1]),0))
			oModel:GetModel("MdFieldSBE"):SetValue("BE_VALNV6",If(Len(aValNiv)> 5,Int(aValNiv[6,1]),0))

			If Self:nOperation == MODEL_OPERATION_INSERT
		       If WmsX312120("DC8","DC8_NRUNIT") .And. WmsX312120("SBE","BE_NRUNIT")
		          oModel:GetModel("MdFieldSBE"):SetValue("BE_NRUNIT",Posicione('DC8',1,xFilial('DC8')+oModel:GetModel("MdFieldSBE"):GetValue("BE_ESTFIS"),'DC8_NRUNIT'))
			   EndIf
			EndIf 
		EndIf

	EndIf

Return .T.

//-------------------------------------------------------------------
// M�todo que avalia o status dos endere�os
//-------------------------------------------------------------------
METHOD AvalStsEnd(oModel) CLASS MATA015EVWMS
Local aAreaD14 := D14->(GetArea())
Local cStatus  := ""
local cLocal   := ""
Local cLocaliz := ""
Local cCodZon  := ""
Local cEstFis  := ""
Local lRet     := .T.

	cStatus  := oModel:GetModel("MdFieldSBE"):GetValue("BE_STATUS")
	cLocal   := oModel:GetModel("MdFieldSBE"):GetValue("BE_LOCAL")
	cLocaliz := oModel:GetModel("MdFieldSBE"):GetValue("BE_LOCALIZ")
	cCodZon  := oModel:GetModel("MdFieldSBE"):GetValue("BE_CODZON")
	cEstFis  := oModel:GetModel("MdFieldSBE"):GetValue("BE_ESTFIS")

	If cStatus $ "4|5|6"
		// Se for um endere�o do WMS Antigo ou um endere�o do Backoffice, n�o permite status 4, 5 ou 6
		If !Self:lWmsNew .Or. (Empty(cCodZon) .And. Empty(cEstFis))
			oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,MA015WMS06,STR0010,STR0011) // "Status n�o permitido para o endere�o." // "Informe status 1 - Desocupado, 2 - Ocupado ou 3 - Bloqueado."
			Return .F.
		EndIf
	EndIf

	If cStatus $ "1|2"

		If Self:lWmsNew .And. !(Empty(cCodZon) .And. Empty(cEstFis))

			D14->(DbSetorder(1)) // D14_FILIAL+D14_LOCAL+D14_ENDER
			If cStatus == '1' .And. D14->(DbSeek(xFilial('D14')+cLocal+cLocaliz))
				oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,MA015WMS07,STR0012,STR0013) // "O status n�o pode ser alterado, pois o endere�o est� ocupado." // "Desocupe o endere�o para prosseguir com esta opera��o."
				lRet := .F.
			ElseIf cStatus == '2' .And. !D14->(DbSeek(xFilial('D14')+cLocal+cLocaliz))
				oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,MA015WMS08,STR0014,STR0015) // "Somente endere�os realmente ocupados podem receber este status." // "Altere o status para 1 - Desocupado ou 3 - Bloqueado."
				lRet := .F.
			EndIf

		EndIf

	EndIf

RestArea(aAreaD14)
Return lRet
//-------------------------------------------------------------------
// Fun��o de suaviza��o,
// O objetivo � evitar error log de falta de fun��o para clientes que possuem o dicion�rio 12.1.17
//-------------------------------------------------------------------
Function MA015VldEF()
Return .T.