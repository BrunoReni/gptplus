#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'CTBA020.ch'

Class CTBA020EVPER FROM FWModelEvent

	Method New()
	Method FieldPosVld(oModel, cModelId)

End Class

Method New() Class CTBA020EVPER

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FieldPosVld
M�todo que � chamado pelo MVC quando ocorrer a a��o de p�s valida��o do Field

@author TOTVS
@version P12
/*/
//-------------------------------------------------------------------
Method FieldPosVld(oModel, cModelId) Class CTBA020EVPER
	Local lRet			:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local aArea			:= {}
	Local aCT1			:= {}

	If oModel:GetValue("CT1_LCCMPL") == "1"
		If Empty(oModel:GetValue("CT1_CTPART")) .Or. Empty(oModel:GetValue("CT1_CTCPAR"))
			lRet := .F.
			Help(" ",1,"CT1CRIA",,STR0046 + "." + STR0047 + ".",1,0)//"Para o uso de lan�amentos complementares, s�o necess�rias as contas de partida e contra-partida"###"Informe-as nos campos correspondetes"
		Else
			aArea := GetArea()
			DbSelectArea("CT1")
			aCT1 := GetArea()
			CT1->(DbSetOrder(1))
			cFilCT1 := xFilial("CT1")
			/* verificando a conta de partida para o lancamento complementar */
			If DbSeek(cFilCT1 + oModel:GetValue("CT1_CTPART"))
				If CT1->CT1_CLASSE == "1"	/* conta sintetica */
					lRet := .F.
					Help(" ",1,"CT1CRIA2",,STR0048 + "." + STR0049 + ".",1,0)//"As contas para lan�amentos complementares devem ser de classe anal�tica"###"Informe uma conta v�lida"
				Else
					If CT1->CT1_LCCMPL == "1"
						lRet := .F.
						Help(" ",1,"CT1CRIA3",,STR0050 + "." + STR0049 + ".",1,0)//"As conta para lan�amentos complementares n�o podem exigir lan�amento complementar"
					EndIf
				EndIf
			Else
				lRet := .F.
				Help(" ",1,"CT1CRIA4",,STR0051 + "." + STR0049 + ".",1,0)//"A conta de partida para o lan�amento complementar n�o foi encontrada"
			EndIf
			/* verificando a conta de partida para o lancamento complementar */
			If lRet
				If DbSeek(cFilCT1 + oModel:GetValue("CT1_CTCPAR"))
					If CT1->CT1_CLASSE == "1"	/* conta sintetica */
						lRet := .F.
						Help(" ",1,"CT1CRIA5",,STR0048 + "." + STR0049 + ".",1,0) //"As contas para lan�amentos complementares devem ser de classe anal�tica"###"Informe uma conta v�lida"
					Else
						If CT1->CT1_LCCMPL == "1"
							lRet := .F.
							Help(" ",1,"CT1CRIA6",,STR0050 + "." + STR0049 + ".",1,0) //"As conta para lan�amentos complementares n�o podem exigir lan�amento complementar"
						EndIf
					EndIf
				Else
					lRet := .F.
					Help(" ",1,"CT1CRIA7",,STR0052 + "." + STR0049 + ".",1,0) //"A conta de contra-partida para o lan�amento complementar n�o foi encontrada"
				EndIf
			EndIf
			RestArea(aCT1)
			RestArea(aArea)
		EndIf
	Else
		oModel:SetValue("CT1_CTPART","")
		oModel:SetValue("CT1_CTCPAR","")
	EndIf

Return lRet