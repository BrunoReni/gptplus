#INCLUDE "CNTA110.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "ApWizard.CH"
#INCLUDE "FWMVCDEF.CH"

//Situacoes de contrato
#DEFINE DEF_SCANC "01"//Cancelado
#DEFINE DEF_SELAB "02"//Em Elaboracao
#DEFINE DEF_SEMIT "03"//Emitido
#DEFINE DEF_SAPRO "04"//Em Aprovacao
#DEFINE DEF_SVIGE "05"//Vigente
#DEFINE DEF_SPARA "06"//Paralisado
#DEFINE DEF_SSPAR "07"//Sol Fina.
#DEFINE DEF_SFINA "08"//Finalizado
#DEFINE DEF_SREVS "09"//Revisao
#DEFINE DEF_SREVD "10"//Revisado

//Transa��es
#DEFINE DEF_TRAINC "011"//Inclusao de cronogramas
#DEFINE DEF_TRAEDT "012"//Edicao de cronogramas
#DEFINE DEF_TRAEXC "013"//Exclusao de cronogramas
#DEFINE DEF_TRAVIS "033"//Visualizacao de cronogramas

//Tipos de Revisao
#DEFINE DEF_REALI "3" //Realinhamento
#DEFINE DEF_REV_REAJU "2" //Reajuste

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    |CN110MtFsc  � Autor � Marcelo Custodio      � Data �26.12.2005���
���������������������������������������������������������������������������Ĵ��
���Descri�ao �Monta o aHeader do cronograma fisico com base no arquivo CNS  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �CN110MtFsc(aExp01)                                            ���
���������������������������������������������������������������������������Ĵ��
���Parametros� aExp01 - Array para montagem do cabecalho                    ���
���          � lExp02 - Visualiza cronograma fisico                         ���
���          � nExp03 - Numeracao de controle de incl/alter/consul          ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � CNTA110                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function CN110MtFsc(aHeadParc,lVisu,nOpcX)
//������������������������������������Ŀ
//�Campos nao exibidos                 �
//��������������������������������������
Local cCampos := "CNS_FILIAL|CNS_CONTRA|CNS_REVISA|CNS_CRONOG|CNS_PARCEL|CNS_PLANI"

Default lVisu := .F.

If lVisu
	cCampos += "|CNS_DISTSL"
EndIf

dbSelectArea("SX3")
dbSetOrder(1)

If dbSeek("CNS")
	While !Eof() .And. SX3->X3_ARQUIVO=="CNS"
		If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL) .And. !(AllTrim(SX3->X3_CAMPO) $ cCampos)
			AAdd(aHeadParc,{AllTrim(X3Titulo()),;
			AllTrim(SX3->X3_CAMPO),;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_F3,;
			SX3->X3_CONTEXT})
		EndIf
		dbSkip()
	EndDo

	//��������������������������������������������������������������Ŀ
	//� Adiciona os campos de Alias e Recno ao aHeader para WalkThru.�
	//����������������������������������������������������������������
	If nOpcX <> 3
		ADHeadRec("CNS",aHeadParc)
	EndIf
EndIf

Return


/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    |CN110VldVal � Autor � Marcelo Custodio      � Data �26.12.2005���
���������������������������������������������������������������������������Ĵ��
���Descri�ao �Valida alteracao no valor de parcela                          ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �CN110VldVal()                                                 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � CNTA100                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function CN110VldVal()

	Local aAreaAnt	:= GetArea()

	Local lReali := .F.
	Local lRet   := .T.
	Local lSaldoRec := .T.

	Local cQryCNF := ""
	Local cQuery    := ""

	Local oModel   	 := FWModelActive()
	Local oModelCNF	 := oModel:GetModel("CNFDETAIL")
	Local nValorPrev := &(Readvar())
	Local nLmtMed	 := 0

	If !IsIncallStack('CN300Rev') .And. Vazio() .And. !IsBlind()
		Help(" ",1,"CN300VLPRV")
		Return .F.
	EndIf

	If FwFldGet("CN9_SITUAC") == DEF_SREVS		
		lReali  := (Cn300RetSt('TIPREV') == DEF_REALI) .And. (GetNewPar( "MV_CNREALM", "S" ) == "S")
	EndIf

	//Query para obter o valor das parcelas ja FATURADAS no Contrato se parametro MV_CNREALM = Sim
	If lReali
		cQryCNF := GetNextAlias()

		cQuery := "SELECT CNF_CONTRA ,  CNF_REVISA, SUM(CNB.CNB_QUANT)AS QUANT , SUM(CNB.CNB_SLDREC) AS RECEBIDO "
		cQuery += "  FROM " + RetSqlName("CNB") + " CNB ," + RetSqlName("CNF") + " CNF "
		cQuery += " WHERE CNF_FILIAL     = '" + xFilial( "CNF" ) + "'"
		cQuery += "   AND CNB_FILIAL     = '" + xFilial( "CNB" ) + "'"
		cQuery += "   AND CNF.CNF_CONTRA = '"+ FwFldGet("CN9_NUMERO")+ "'"
		cQuery += "   AND CNF.CNF_REVISA = '"+ FwFldGet("CN9_REVISA")+ "'"
		cQuery += "   AND CNB.CNB_CONTRA = CNF.CNF_CONTRA "
		cQuery += "   AND CNB.CNB_REVISA = CNF.CNF_REVISA "
		cQuery += "   AND CNB.D_E_L_E_T_ = ' ' "
		cQuery += "   AND CNF.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY CNF_CONTRA ,  CNF_REVISA "

		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cQryCNF, .F., .T. )
		TCSetField( cQryCNF, "QUANT"   , "N", TamSX3("CNB_QUANT")[1] , TamSX3("CNB_QUANT")[2] )
		TCSetField( cQryCNF, "RECEBIDO", "N", TamSX3("CNB_SLDREC")[1], TamSX3("CNB_SLDREC")[2] )

		If !(cQryCNF)->(Eof())
			lSaldoRec:=(cQryCNF)->QUANT <> (cQryCNF)->RECEBIDO
		EndIf
		If Select(cQryCNF) > 0
			(cQryCNF)->( dbCloseArea() )
		EndIF

	EndIf

	If !lReali .Or. lSaldoRec

		If oModelCNF:GetValue("CNF_VLREAL") > 0
			If (nLmtMed := CN300RetSt('LMTMED')) > 0				
				nValorPrev += ( ( nValorPrev * nLmtMed ) / 100 )//Considera o limite adicional de medi��o
			EndIf

			If nValorPrev < oModelCNF:GetValue("CNF_VLREAL") //Verifica se previsao eh menor que realizado
				Help(" ",1,"CNTA110REA") //"Valor previsto n�o deve ser menor que realizado"
				lRet := .F.
			EndIf
		EndIf
	Else

		If (&(Readvar()) < (oModelCNF:GetValue("CNF_VLREAL") + oModelCNF:GetValue("CNF_SALDO")) ) .AND. ( !Empty(oModelCNF:GetValue("CNF_VLREAL")) .AND. !Empty(oModelCNF:GetValue("CNF_SALDO")) )

			lRet := .F.
			Help(" ",1,"CNTA110REP") //"Valor previsto n�o deve ser menor que a soma do realizado com o saldo parcial para a Revis�o de Realinhamento com parcelas parcialmente medidas."

		ElseIf (&(Readvar()) < oModelCNF:GetValue("CNF_VLREAL") ) .AND. ( !Empty(oModelCNF:GetValue("CNF_VLREAL")) .AND. Empty(oModelCNF:GetValue("CNF_SALDO")) )

			lRet := .F.
			Help(" ",1,"CNTA110RET") //"Valor previsto n�o deve ser menor que o realizado com o para a Revis�o de Realinhamento com parcelas totalmente medidas."

		EndIf

	EndIf

	RestArea(aAreaAnt)
	FwFreeArray(aAreaAnt)
Return lRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    |CN100FsVls  � Autor � Marcelo Custodio      � Data �16.01.2006���
���������������������������������������������������������������������������Ĵ��
���Descri�ao �Valida quantidade do cronograma fisico                        ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � CNTA110                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function CN110FsVld(nOldValue, oModelCNS as Object)
	Local oView		:= Nil	
	Local oModelCNF	:= Nil
	Local lRet		:= .F.
	Local nPosDist	:= 0
	Local nTotItens	:= 0
	Local nx		:= 0
	Local nLine		:= 0
	Local aPropsCNF	:= {}
	Local aSaveLines:= {}
	Local lMKCRG	:= .F.
	Local nDifUltPar:= 0
	
	If FwIsInCallStack("A300AtuCrF")
		lRet := .T.
	Else
		lRet := (M->CNS_PRVQTD >= oModelCNS:GetValue("CNS_RLZQTD"))//Verifica se o valor informado < que o saldo - quantidade medida
	EndIf
	
	If lRet
		aSaveLines	:= FWSaveRows()
		oModel		:= oModelCNS:GetModel()
		oModelCNF	:= oModel:GetModel("CNFDETAIL")
		nLine		:= oModelCNS:GetLine()	
		nPosDist	:= oModelCNS:GetValue("CNS_DISTSL")
		nPosDist 	-= oModelCNS:GetValue("CNS_PRVQTD") - nOldValue
		nTotItens 	:= Cn100CFisT(oModel)
		lMKCRG		:= (FwIsInCallstack("CN300MKCRG") .Or. FwIsInCallStack("CN300AtCrs"))
		
		If A300GTPREV() <> DEF_REV_REAJU  .And. !lMKCRG //Quando campo alterado pelo usuario
			aPropsCNF	:= GetPropMdl(oModelCNF)
			CNTA300BlMd(oModelCNF,.F.,.T.)
			oModelCNF:GetStruct():SetProperty('CNF_VLPREV',MODEL_FIELD_WHEN,{||.T.})
			oModelCNF:GetStruct():SetProperty('CNF_SALDO' ,MODEL_FIELD_WHEN,{||.T.})
			
			lRet := oModelCNF:SetValue("CNF_VLPREV",nTotItens)//Atualiza valor da parcela no cronog. financeiro

			If oModelCNF:GetLine() == oModelCNF:Length() //Se for a ultima parcela
				nDifUltPar := oModel:GetValue('CNADETAIL','CNA_VLTOT') - oModel:GetValue('CALC_CNF', 'CNF_CALC')
				If nDifUltPar > 0 //Qualquer diferen�a deve ser adicionada na �ltima parcela
					nTotItens	:= Round(nTotItens+nDifUltPar, GetSx3Cache('CNF_VLPREV','X3_DECIMAL'))
					lRet 		:= oModelCNF:SetValue("CNF_VLPREV",nTotItens)
				EndIf
			EndIf

			RstPropMdl(oModelCNF, aPropsCNF)
			FwFreeArray(aPropsCNF)

			oModelCNF:GetStruct():SetProperty('CNF_VLPREV',MODEL_FIELD_WHEN, FwBuildFeature( STRUCT_FEATURE_WHEN, ".F.") )
			oModelCNF:GetStruct():SetProperty('CNF_SALDO' ,MVC_VIEW_CANCHANGE, .F.)
		EndIf
		
		If lRet		
			oModel:GetModel("CALC_CNS"):LoadValue("TCNS_VTOT",nTotItens)//Atualiza total da parcela no header		
			For nX := 1 To oModelCNF:Length() //Atualiza saldo a distribuir em todas as parcelas
				oModelCNF:GoLine(nX)
				If !oModelCNF:IsDeleted() .And. oModelCNS:Length() >= nLine
					oModelCNS:GoLine(nLine)
					oModelCNS:SetValue("CNS_DISTSL",nPosDist)
				EndIf
			Next nX
		EndIf
		
		FWRestRows(aSaveLines)
		FwFreeArray(aSaveLines)
		
		If !lMKCRG
			oView := FWViewActivate()
			If ValType(oView) == "O" .And. oView:IsActive()
				aEval({'VIEW_CNS', 'VIEW_CLC2'}, {|x| oView:Refresh(x) } )
			EndIf		
		EndIf		
	EndIf
Return lRet


/*/{Protheus.doc} Cn100CFisT(oModel)
Fun��o respons�vel por calcular o valor total do cronograma fisico 

@author israel.escorizza
@since 24/04/2018
@return*/
Function Cn100CFisT(oModel)
	Local aSaveLines:= FwSaveRows()
	Local nX		:= 0
	Local nValor	:= 0
	Local nTamVlPrev:= 0
	Local oModelCNS	:= oModel:GetModel("CNSDETAIL")	
	Local oModelCNB := oModel:GetModel("CNBDETAIL")
	
	For nX := 1 To oModelCNS:Length()
		oModelCNS:GoLine(nX)
		If !(oModelCNS:IsDeleted())			
			nValor += oModelCNS:GetValue('CNS_PRVQTD') * oModelCNB:GetValue('CNB_VLUNIT',nX) - (oModelCNB:GetValue('CNB_VLDESC',nX)/oModelCNB:GetValue('CNB_QUANT',nX))
		EndIf
	Next nX

	If (nValor > 0)
		nTamVlPrev := GetSx3Cache('CNF_VLPREV','X3_DECIMAL')
		nValor := Round(nValor,nTamVlPrev)
	EndIf

	FWRestRows(aSaveLines)
	FwFreeArray(aSaveLines)
Return nValor


/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    |CN110VisFis � Autor � Marcelo Custodio      � Data �16.01.2006���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Exibe e permite carregar os valores previstos no cronograma  ���
���          � fisico no momento da medicao                                 ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cExp01 - Codigo do contrato                                  ���
���          � cExp02 - Codigo da revisao                                   ���
���          � cExp03 - Codigo da planilha                                  ���
���          � cExp04 - Competencia                                         ���
���          � oExp04 - Objeto getdados da medicao                          ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � CNTA130                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CN110VisFis(cContra,cRevisa,cPlan,cCompet,oGet,lVisu,cParcel)

Local oDlg
Local ogetFsc

Local lRet      := .F.

Local nx        := 0
Local ny        := 0
Local nPosCNE   := 0
Local nPosCNS   := 0
Local nPosQuant := 0
Local nPosSld   := 0
Local nPosSldMed:= 0
Local nPosItCNE := aScan(oGet:aHeader,{|x| AllTrim(x[2])=="CNE_ITEM"})
Local nOpca

Local cQuery    := ""
Local cAlias    := ""

Local aArea       := GetArea()
Local aSavaHeader := aClone(oGet:aHeader)
Local aStrucCNS   := CNS->(dbStruct())
Local aHeadParc   := {}
Local aColsParc   := {}

DEFAULT lVisu   := .F.
DEFAULT cParcel := ""

dbSelectArea("CNF")
dbSetOrder(1)

//������������������������������������Ŀ
//�Monta estrutura fisica              �
//��������������������������������������
CN110MtFsc(aHeadParc,.T.)

cAlias := GetNextAlias()
cQuery := "SELECT CNS.*,CNB.CNB_PRODUT,CNB.CNB_DESCRI,CNB.CNB_QUANT,CNB.R_E_C_N_O_ RECNOCNB "
cQuery += "  FROM "+RetSQLName("CNS")+" CNS, "+RetSQLName("CNA")+" CNA, "+RetSQLName("CNF")+" CNF , "+RetSQLName("CNB")+" CNB "
cQuery += " WHERE CNS.CNS_FILIAL = '"+xFilial("CNS")+"'"
cQuery += "   AND CNA.CNA_FILIAL = '"+xFilial("CNA")+"'"
cQuery += "   AND CNB.CNB_FILIAL = '"+xFilial("CNB")+"'"
cQuery += "   AND CNF.CNF_FILIAL = '"+xFilial("CNF")+"'"
cQuery += "   AND CNS.CNS_CONTRA = '"+cContra+"'"
cQuery += "   AND CNS.CNS_CONTRA = CNA.CNA_CONTRA "
cQuery += "   AND CNS.CNS_CONTRA = CNB.CNB_CONTRA "
cQuery += "   AND CNS.CNS_CONTRA = CNF.CNF_CONTRA "
cQuery += "   AND CNS.CNS_REVISA = '"+cRevisa+"' "
cQuery += "   AND CNS.CNS_REVISA = CNA.CNA_REVISA "
cQuery += "   AND CNS.CNS_REVISA = CNB.CNB_REVISA "
cQuery += "   AND CNS.CNS_REVISA = CNF.CNF_REVISA "
cQuery += "   AND CNA.CNA_NUMERO = '"+cPlan+"'"
cQuery += "   AND CNS.CNS_CRONOG = CNA.CNA_CRONOG "
cQuery += "   AND CNS.CNS_CRONOG = CNF.CNF_NUMERO "
cQuery += "   AND CNF.CNF_COMPET = '"+cCompet+"' AND "
If !Empty(cParcel)
	cQuery += " CNF.CNF_PARCEL = '"+cParcel+"' AND "
EndIf
cQuery += "       CNS.CNS_PARCEL = CNF.CNF_PARCEL "
cQuery += "   AND CNS.CNS_ITEM   = CNB.CNB_ITEM   "
cQuery += "   AND CNA.CNA_NUMERO = CNB.CNB_NUMERO "
cQuery += "   AND CNS.D_E_L_E_T_ = ' ' "
cQuery += "   AND CNA.D_E_L_E_T_ = ' ' "
cQuery += "   AND CNB.D_E_L_E_T_ = ' ' "
cQuery += "   AND CNF.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY CNS.CNS_ITEM "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

For nx:=1 to len(aStrucCNS)
	if (cAlias)->(FieldPos(aStrucCNS[nx,1])) > 0 .And. aStrucCNS[nx,2] <> "C"
		TCSetField( cAlias, aStrucCNS[nx,1], aStrucCNS[nx,2], aStrucCNS[nx,3], aStrucCNS[nx,4] )
	endif
Next
TCSetField(cAlias,"CNB_QUANT"  ,"N",TamSX3("CNB_QUANT")[1],TamSX3("CNB_QUANT")[2])

//��������������������������������������������������������������Ŀ
//� Adiciona os campos de Alias e Recno ao aHeader para WalkThru.�
//����������������������������������������������������������������
ADHeadRec("CNB",aHeadParc)

//��������������������������������������Ŀ
//�Preenche os itens do cronograma fisico�
//����������������������������������������
While !(cAlias)->(Eof())
	For ny:=1 to len(oGet:aCols)
		If (cAlias)->CNS_ITEM == oGet:aCols[ny,nPosItCNE]
			aAdd(aColsParc,Array(len(aHeadParc)+1))

			For nx:=1 to len(aHeadParc)
				If	IsHeadRec(aHeadParc[nX,2])
					aColsParc[len(aColsParc),nx] := (cAlias)->RECNOCNB
				ElseIf IsHeadAlias(aHeadParc[nX,2])
					aColsParc[len(aColsParc),nx] := "CNB"
				ElseIf aHeadParc[nx,10] != "V"
					aColsParc[len(aColsParc),nx] := (cAlias)->&(aHeadParc[nX,2])
				Else
					Do Case
						Case aHeadParc[nx,2] == "CNS_PRODUT"//Preenche o codigo do produto
							aColsParc[len(aColsParc),nx] := (cAlias)->CNB_PRODUT
						Case aHeadParc[nx,2] == "CNS_DESCRI"//Preenche a descricao do produto
							aColsParc[len(aColsParc),nx] := (cAlias)->CNB_DESCRI
						Case aHeadParc[nx,2] == "CNS_TOTQTD"//Preenche a quantidade total
							aColsParc[len(aColsParc),nx] := (cAlias)->CNB_QUANT
						OtherWise
							aColsParc[len(aColsParc),nx] := CriaVar(aHeadParc[nx,2])
					EndCase
				EndIf
			Next
			aColsParc[len(aColsParc),(len(aHeadParc)+1)] := .F.
		EndIf
	Next

	(cAlias)->(dbSkip())
EndDo

(cAlias)->(dbCloseArea())
//������������������������������������Ŀ
//�Monta Dialog                        �
//��������������������������������������
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0072) FROM 009,000 TO 025,060 OF oMainWnd//"Cronograma Fisico"

@ 005, 005 SAY OemToAnsi(STR0081) PIXEL // "Cronograma Fisico"

ogetFsc := MsNewGetDados():New(013,005,100,232,0,,,,,,,,,,oDlg,aHeadParc,aColsParc)

If !lVisu
	@ 105,172 BUTTON OemToAnsi(STR0079) SIZE 29 ,13  ACTION (nOpca:=1,oDlg:End()) OF oDlg PIXEL//"Carregar"
EndIf
@ 105,203 BUTTON OemToAnsi(STR0080) SIZE 29 ,13  ACTION (nOpca:=2,oDlg:End()) OF oDlg PIXEL//"Fechar"

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca==1
	//������������������������������������Ŀ
	//�Atualiza aCols da medicao           �
	//��������������������������������������
	aCols     := oGet:aCols
	nPosQuant := aScan(oGet:aHeader,{|x| AllTrim(x[2])=="CNE_QUANT"})
	nPosSld   := aScan(aHeadParc,{|x| AllTrim(x[2]) == "CNS_SLDQTD"})
	nPosSldMed:= aScan(oGet:aHeader,{|x| AllTrim(x[2])=="CNE_QTAMED"})
	For nx:=1 to len(aColsParc)
		If aColsParc[nx,nPosSld] <= oGet:aCols[nx,nPosSldMed]
			oGet:aCols[nx,nPosQuant] := If((aColsParc[nx,nPosSld]>0),aColsParc[nx,nPosSld],0)
		Else
			oGet:aCols[nx,nPosQuant] := oGet:aCols[nx,nPosSldMed]
		EndIf
		RunTrigger(2,nx,,,"CNE_QUANT ")
	Next
	oGet:aCols := aCols

	lRet := .T.
EndIf


oGet:aHeader:= aClone(aSavaHeader)
RestArea(aArea)
Return lRet

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CN110VldDt� Autor � Marcelo Custodio      � Data �11/12/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida data prevista                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CN110VldDt()

Local oModel		:= FWModelActive()
Local oModelCNF	:= oModel:GetModel("CNFDETAIL")

Local lRet			:= .T.
Local lVldVige		:= GetNewPar("MV_CNFVIGE","N") == "N"
Local lDtCompet		:= SuperGetMV("MV_CNFDTCP",.F.,.T.)

Local nTot			:= oModelCNF:Length()
Local nAtual		:= oModelCNF:nLine

Local cCampo		:= Readvar()

Local dData		:= &(Readvar())
Local dInicio		:= FwFldGet("CN9_DTINIC")
Local dFim			:= FwFldGet("CN9_DTFIM")

Local aSaveLines	:= FWSaveRows()

//�������������������������������������������������������������������������������������������Ŀ
//�Se a valida��o for por compet�ncia, aponta para o 1� dia do mes para fazer as compara��es. �
//���������������������������������������������������������������������������������������������
If cCampo == "M->CNF_COMPET"
	dData    :=	CtoD("01/"+dData)
	dInicio  := CtoD("01/"+StrZero(Month(dInicio),2)+"/"+StrZero(Year(dInicio),4))
	dFim	 := CtoD("01/"+StrZero(Month(dFim),2)+"/"+StrZero(Year(dFim),4))
EndIf

//���������������������������������������������������������������Ŀ
//�Verifica se a previsao ultrapassa a proxima parcela se houver  �
//�����������������������������������������������������������������
If (nAtual < nTot )
	//��������������������������Ŀ
	//�Verifica a proxima parcela�
	//����������������������������
	oModelCNF:GoLine(nAtual+1)

	If 	( oModelCNF:GetValue("CNF_PRUMED") <= dData )
	  	lRet := .F.
	ElseIf ( oModelCNF:GetValue("CNF_DTVENC") <= dData )
	  	lRet := .F.
	ElseIf ( cCampo == "M->CNF_COMPET" .AND. CtoD("01/" + oModelCNF:GetValue("CNF_COMPET") ) < dData)
	  	lRet := .F.
	ElseIf lVldVige .AND. ( (dData < dInicio) .Or. (dData > dFim) )
	  	lRet := .F.
  	EndIf

 	oModelCNF:GoLine(nAtual)
 EndIf

If ( cCampo == "M->CNF_PRUMED" ) .And. lRet
	
	//������������������������������������������������������Ŀ
	//�Atualiza data de vencimento e competencia da parcela  �
	//��������������������������������������������������������
	
	If lDtCompet
		FWFldPut("CNF_DTVENC" , dData )
	EndIf
	
	If Empty(oModelCNF:GetValue("CNF_COMPET")) .Or. lDtCompet
		oModelCNF:LoadValue("CNF_COMPET" , StrZero(Month(dData),2)+"/"+StrZero(Year(dData),4) )
	EndIf
		
EndIf

FWRestRows(aSaveLines)
Return lRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    |CN110VldRlz � Autor � Felipe Bittar         � Data �22.08.2008���
���������������������������������������������������������������������������Ĵ��
���Descri�ao �Valida alteracao no valor realizado da parcela                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �CN110VldRlz()                                                 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � CNTA100 >>> X3_VALID do campo CNF_VLREAL                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function CN110VldRlz()
Local lRet := .T.
Local oModel	:= FwModelactive()
Local oModelCNF	:= oModel:GetModel("CNFDETAIL")

//����������������������������������������������Ŀ
//�Verifica se previsao e menor que realizado    �
//������������������������������������������������
If oModelCNF:GetValue('CNF_VLREAL') > oModelCNF:GetValue('CNF_VLPREV')
	lRet := .F.
	Aviso(STR0033,STR0082,{"OK"})//"Atencao"#"O valor realizado n�o pode ser maior do que o valor previsto!"
EndIf

Return lRet

/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Funcao    �CalcAvanco� Autor � Felipe Toledo Bittar  � Data �17/09/2008    ���
�����������������������������������������������������������������������������Ĵ��
���Descricao � Calcula quantidade de dias para avancar e obter a proxima      ���
���          � data prevista                                                  ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   � nExp01 - Dias de avanco                                        ���
�����������������������������������������������������������������������������Ĵ��
���Parametros� dExp01 - Data da parcela atual                                 ���
��� 	     � lExp02 - Ajusta data para o final quando passar no mes 02      ���
���          � lExp03 - Ajusta deslocamento do dia 29 quando passar no mes 02 ���
��� 	     � nExp04 - Data da primeira parcela							  ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/
Function CalcAvanco(dPrevista,lAjFim,lAjFev,nDia)
Local nMes      := 0
Local nAno      := 0
Local dDtAux

DEFAULT nDia    := Day(dPrevista)
DEFAULT lAjFim  := .F.
DEFAULT lAjFev  := .F.

//�����������������������������������������������������������������������������Ŀ
//�Se dia da data prevista n�o for 1� (exceto se a primeira parcela for dia 1�),�
//� avan�a para o m�s seguinte.                                                 �
//�������������������������������������������������������������������������������
If Day(dPrevista)<>1 .Or. nDia == 1
    nMes := (Month(dPrevista)+1)
Else
	nMes := Month(dPrevista)
EndIf

nAno := year (dPrevista)

If nMes == 13
	nMes := 1
	nAno += 1
EndIf

dDtAux := cTod(strzero(nDia,2)+"/"+strzero(nMes,2)+"/"+str(nAno,4),"ddmmyyyy")

If Empty(dDtAux)  //Se data estiver vazia, obt�m os primeiro dia do m�s seguinte.
	If lAjFim
		nAvanco   := LastDay(CtoD("01/"+strzero(nMes,2)+"/"+str(nAno,4),"ddmmyyyy"))-dPrevista
	Else
		nAvanco   := LastDay(CtoD("01/"+strzero(nMes,2)+"/"+str(nAno,4),"ddmmyyyy"))+1-dPrevista
	EndIf
Else
	nAvanco   := dDtAux - dPrevista
EndIf

Return nAvanco

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CN110VlVnc� Autor � Aline Sebrian         � Data �22/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida data de vencimento                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CN110VlVnc()
Local lRet			:= .T.
Local lVldVige		:= GetNewPar("MV_CNFVIGE","N") == "N"

Local nPosDtVct	:= 0
Local nTot			:= 0
Local nAtual		:= 0

Local dData		:= &(Readvar())
Local dInicio		:= CtoD("")
Local dFim			:= CtoD("")

Local oModel		:= FWModelActive()
Local oModelCNF	:= Nil
Local lMVC			:= ValType(oModel) <> "U"

Local aSaveLines	:= FWSaveRows()

If !lMVC
	nPosDtVct	:= aScan(oGetDados:aHeader,{ |x|  UPPER(AllTrim(x[2])) == "CNF_DTVENC"})
	nTot		:= len(oGetDados:aCols)
	nAtual     := oGetDados:OBROWSE:NAT
	dInicio	:= CN9->CN9_DTINIC
	dFim		:= CN9->CN9_DTFIM

Else
	oModelCNF	:= oModel:GetModel("CNFDETAIL")

	dInicio	:= FwFldGet("CN9_DTINIC")
	dFim		:= FwFldGet("CN9_DTFIM")
	nAtual		:= oModelCNF:nLine
	nTot		:= oModelCNF:Length()
EndIf

//���������������������������������������������������������������Ŀ
//�Verifica se a previsao ultrapassa a proxima parcela se houver  �
//�����������������������������������������������������������������
If lVldVige
	If (dData < dInicio)
		Aviso(OemToAnsi(STR0033),OemToAnsi(STR0097),{"Ok"})
		lRet := .F.
	EndIf

	If lRet .And. (dData > dFim)
		Aviso(OemToAnsi(STR0033),OemToAnsi(STR0098),{"Ok"})
		lRet := .F.
	EndIf

	If lRet .And. (nAtual < nTot)
		If !lMVC .AND.(oGetDados:aCols[nAtual+1,nPosDtVct] <= dData)
			Aviso(OemToAnsi(STR0033),OemToAnsi(STR0099),{"Ok"})
			lRet := .F.
		ElseIf lMVC
			//��������������������������Ŀ
			//�Verifica a proxima parcela�
			//����������������������������
			oModelCNF:GoLine(nAtual+1)

			If !oModelCNF:IsDeleted() .And. oModelCNF:GetValue("CNF_DTVENC") <= dData
			  	lRet := .F.
			  	Aviso(OemToAnsi(STR0033),OemToAnsi(STR0099),{"Ok"})
		  	EndIf

		  	oModelCNF:GoLine(nAtual)
		EndIf
	EndIf
EndIf

FWRestRows(aSaveLines)
Return lRet

/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Funcao    �CalcDiaCom� Autor � Aline S Damasceno     � Data �24/02/2012    ���
�����������������������������������������������������������������������������Ĵ��
���Descricao �Define o dia para a competencia								  ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   � nExp01 - Dias de avanco                                        ���
�����������������������������������������������������������������������������Ĵ��
���Parametros� dExp01 - Data da parcela atual                                 ���
��� 	     � cExp02 - Competencia	atual									  ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/
Function CalcDiaCom(dPrevista,cCompete)
Local dDtAux

//�����������������������������������������������������������������������������Ŀ
//�Se o ultimo dia da data prevista for diferente da competenciaa, aponta para  �
//� o ultimo dia da competencia.                                                �
//�������������������������������������������������������������������������������
If LastDay(dPrevista) <> LastDay(CtoD("01/"+cCompete,"ddmmyy"))
    dDtAux := LastDay(CtoD("01/"+cCompete,"ddmmyy"))
Else
	dDtAux := CTOD(Str(Day(dPrevista))+"/"+cCompete)
EndIf


Return dDtAux
