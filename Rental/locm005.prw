/*/{Protheus.doc} LOCM005.PRW
ITUP Business - TOTVS RENTAL
Ponto de Entrada na Exclusão do Pedido de Vendas - GPO: Ajusta status na ZC1 e ZAG.
@type Function
@author Frank Zwarg Fuga
@since 03/12/2020
@version P12
@history 03/12/2020, Frank Zwarg Fuga, Fonte produtizado.
Antigo ponto de entrada MA410DEL
/*/

#Include "Totvs.ch"
#Include "TopConn.ch"

Function LOCM005()
Local _aAreaOld := GetArea()
Local _aAreaSC5 := SC5->(GetArea())
Local _aAreaSC6 := SC6->(GetArea())
Local _aAreaZAG := FPA->(GetArea())
Local _aAreaZA1 := FP1->(GetArea())
Local _aAreaZC1 := FPG->(GetArea())
Local _lRet     := .t.
Local _cQuery   := ""
Local _dProxFat := StoD("")
Local _dUltFat  := StoD("")
Local _nDiasTrb := 0
Local lMvLocBac := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local cXTIPFAT
Local cXEXTRA
Local cXPERLOC
Local cXAS

	dbSelectArea("FPG")
	dbSelectArea("FPA")
	dbSelectArea("FP1")
	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))	// C6_FILIAL + C6_NUM + C6_PRODUTO

	// Frank 05/11/20 - limpar os registros da tabela FQZ
	_cQuery := " SELECT FQZ.R_E_C_N_O_ FQZRECNO" + CRLF
	_cQuery += " FROM " + RetSqlName("FQZ") + " FQZ (NOLOCK)" + CRLF
	_cQuery += " WHERE  FQZ_FILIAL  = '" + xFilial("FQZ") + "'" + CRLF
	_cQuery += "  AND   FQZ_PV     = '" + SC5->C5_NUM + "'"
	_cQuery := changequery(_cQuery) 
	If Select("TRBFQZ") > 0
		TRBFQZ->( DbCloseArea() )
	EndIf
	TcQuery _cQuery New Alias "TRBFQZ"

	While TRBFQZ->(!Eof())
		FQZ->(dbGoto(TRBFQZ->FQZRECNO))
		FQZ->(RecLock("FQZ",.F.))
		FQZ->FQZ_PV := ""
		FQZ->(MsUnlock())
		TRBFQZ->(dbSkip())
	EndDo
	TRBFQZ->( DbCloseArea() )

	_cQuery := " SELECT SC6.R_E_C_N_O_ SC6RECNO" + CRLF
	_cQuery += " FROM " + RetSqlName("SC6") + " SC6 (NOLOCK)" + CRLF
	_cQuery += " WHERE  C6_FILIAL  = '" + xFilial("SC6") + "'" + CRLF
	_cQuery += "  AND   C6_NUM     = '" + SC5->C5_NUM + "'"
	If Select("TRBSC6") > 0
		TRBSC6->( DbCloseArea() )
	EndIf
	_cQuery := changequery(_cQuery) 
	TcQuery _cQuery New Alias "TRBSC6"

	While TRBSC6->(!Eof())
		SC6->(dbGoTo(TRBSC6->SC6RECNO))

		If lMvLocBac
			FPY->(dbSetOrder(1))
			FPY->(dbSeek(xFilial("FPY")+SC5->C5_NUM))
			FPZ->(dbSetOrder(1))
			FPZ->(dbSeek(xFilial("FPZ")+SC5->C5_NUM+FPY->FPY_PROJET+SC6->C6_ITEM))
		EndIF

		If SuperGetMv("MV_LOCX243",.f.,.f.)
			If !lMvLocBac
				LOCA062(xFilial("SC5"),SC5->C5_NUM,SC6->C6_ITEM,,,SC6->C6_XAS,,.t.)
			Else
				LOCA062(xFilial("SC5"),SC5->C5_NUM,SC6->C6_ITEM,,,FPZ->FPZ_AS,,.t.)
			EndIF
		EndIf

		If !lMvLocBac
			cXTIPFAT := SC5->C5_XTIPFAT
			cXEXTRA  := SC6->C6_XEXTRA
			cXPERLOC := SC6->C6_XPERLOC
			cXAS     := SC6->C6_XAS
		Else
			cXTIPFAT := FPY->FPY_TIPFAT
			cXEXTRA  := FPZ->FPZ_EXTRA
			cXPERLOC := FPZ->FPZ_PERLOC
			cXAS     := FPZ->FPZ_AS
		EndIf

		If cXTIPFAT == "P"
			If cXEXTRA == "S"
				_cQuery := " SELECT ZC1.R_E_C_N_O_ ZC1RECNO"
				_cQuery += " FROM " + RetSqlName("FPG") + " ZC1"
				_cQuery += " WHERE  FPG_FILIAL = '" + xFilial("FPG") + "'"
				_cQuery += "   AND  FPG_PVNUM  = '" + SC6->C6_NUM  + "'"
				_cQuery += "   AND  FPG_PVITEM = '" + SC6->C6_ITEM + "'"
				_cQuery += "   AND  ZC1.D_E_L_E_T_ = ''"
				_cQuery := changequery(_cQuery) 
				If Select("TRBFPG") > 0
					TRBFPG->(dbCloseArea())
				EndIf
				TcQuery _cQuery New Alias "TRBFPG"

				While TRBFPG->(!Eof())
					FPG->(dbGoTo(TRBFPG->ZC1RECNO))

					If empty(FPG->FPG_SEQ)
						_cSeq := GetSx8Num("FPG","FPG_SEQ")
						ConfirmSx8()
						If FPG->(RecLock("FPG",.F.))
							FPG->FPG_SEQ := _cSeq
							FPG->(MsUnlock())
						EndIF
					EndIf

					If RecLock("FPG",.f.)
						FPG->FPG_PVNUM  := ""
						FPG->FPG_PVITEM := ""
						FPG->FPG_STATUS := "1"	// Pendente
						FPG->(MsUnlock())
					EndIf

					TRBFPG->(dbSkip())
				EndDo

				TRBFPG->(dbCloseArea())
			Else
				If !Empty(cXAS)
					FPA->(dbSetOrder(3)) // FPA_FILIAL + FPA_AS + FPA_VIAGEM
					If FPA->(dbSeek( xFilial("FPA") + cXAS ))
						_dUltFat  := FPA->FPA_ULTFAT
						_dProxFat := FPA->FPA_DTFIM

						FP1->(dbSetOrder(1))				// FP1_FILIAL + FP1_PROJET + FP1_OBRA
						If FP1->(dbSeek( xFilial("FP1") + FPA->FPA_PROJET + FPA->FPA_OBRA ))
							If FP1->FP1_TPMES == "0"		// Mes Fechado
								_nDiasTrb := 30
								_dProxFat := MonthSub(_dProxFat,1)

								If FPA->FPA_DTINI > MonthSub(FPA->FPA_ULTFAT,1)
									_dUltFat := StoD("")
								Else
									_dUltFat := MonthSub(FPA->FPA_ULTFAT,1)
								EndIf
							Else
								_nDiasTrb := FPA->FPA_LOCDIA
								_dProxFat := _dProxFat - _nDiasTrb

								If Empty(FPA->FPA_DTSCRT)
									If FPA->FPA_DTINI > FPA->FPA_ULTFAT - _nDiasTrb
										_dUltFat := StoD("")
									Else
										_dUltFat := FPA->FPA_ULTFAT - _nDiasTrb
									EndIf
								Else
									_dProxFat := CtoD(Substr(cXPERLOC,1,10))
									_dUltFat  := _dUltFat - 1
								EndIf

								If FPA->FPA_DTINI > _dUltFat
									_dUltFat := StoD("")
								EndIf
							EndIf
						EndIf
					EndIf

					If !(FPA->FPA_TIPOSE $ "Z#O")
						If RecLock("FPA",.f.)
							FPA->FPA_DTFIM  := _dProxFat
							FPA->FPA_ULTFAT := _dUltFat
							FPA->(MsUnlock())
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		TRBSC6->(dbSkip())
	EndDo

	//Atualiza a tabela de PV x Locação 
	If lMvLocBac	
		FPY->(DbSetOrder(1)) //
		If FPY->(DbSeek(xFilial("FPY") + SC5->C5_NUM))
			If RecLock("FPY",.f.)
				FPY->FPY_STATUS  := "2" // //1=Pedido Ativo;2=Pedido Cancelado
				FPY->(MsUnlock())
			EndIf
		EndIf
	EndIF

	FPG->(RestArea( _aAreaZC1 ))
	FP1->(RestArea( _aAreaZA1 ))
	FPA->(RestArea( _aAreaZAG ))
	SC6->(RestArea( _aAreaSC6 ))
	SC5->(RestArea( _aAreaSC5 ))
	RestArea( _aAreaOld )

Return _lRet
