/*/{Protheus.doc} LOCM002.PRW
ITUP Business - TOTVS RENTAL
@type Function
@author Frank Zwarg Fuga
@since 03/12/2020
@version P12
@history 03/12/2020, Frank Zwarg Fuga, Fonte produtizado.
Antigo ponto de entrada: SF2520E.PRW
Após a exclusão da nota fiscal de saída
/*/

#Include "protheus.ch"
#Include "topconn.ch"                                                                                       
#Include "TbiConn.ch"

Function LOCM002()
Local aArea     := GetArea()
Local aAreaSC6  := SC6->(GetArea())
Local aAreaST9  := ST9->(GetArea())
Local aAreaZAG  := FPA->(GetArea())
Local aAreaZA0  := FP0->(GetArea())
Local cSerie    := SuperGetMV("MV_LOCX201" , .F. , "001") 
Local cAliasQry := GetNextAlias() 
Local cRoma     := ""
Local cFpyRoma  := ""
Local cPvAs		:= ""
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC

	dbSelectArea("SC6")
	SC6->(dbSetOrder(4))
	If SC6->(dbSeek(SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE))
		While SC6->(!Eof()) .And. SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE == SC6->C6_FILIAL + SC6->C6_NOTA + SC6->C6_SERIE
			If SuperGetMv("MV_LOCX243",.F.,.F.)
				LOCA040(SC6->C6_FILIAL , SC6->C6_NUM , SC6->C6_ITEM , , , , .T.) 
			EndIf
			SC6->(dbSkip())
		EndDo
	EndIf

	ST9->( dbSetOrder(1) )

	// Verificamos se eh NF de Remessa
	cQuery := " SELECT R_E_C_N_O_ ZAGREC  "                    + CRLF
	cQuery += " FROM "+RetSqlName("FPA")+" ZAG "               + CRLF
	cQuery += " WHERE  ZAG.FPA_FILREM = '"+SF2->F2_FILIAL+"' " + CRLF
	cQuery += "   AND  ZAG.FPA_NFREM  = '"+SF2->F2_DOC   +"' " + CRLF
	cQuery += "   AND  ZAG.FPA_SERREM = '"+SF2->F2_SERIE +"' " + CRLF
	cQuery += "   AND  ZAG.D_E_L_E_T_ = '' "
	cQuery := changequery(cQuery) 
	dbUseArea(.T. , "TOPCONN" , TCGENQRY(,,cQuery) , cAliasQry , .F. , .T.) 
	(cAliasQry)->(dbGoTop()) 

	If SF2->F2_SERIE != cSerie .Or. SF2->F2_TIPO != 'N' 
		RestArea( aArea )
		Return Nil
	EndIf

	dbSelectArea("FP0")

	While ! (cAliasQry)->( Eof() )
	
		FPA->( dbGoTo( (cAliasQry)->ZAGREC ) )
	
		If ! Empty(FPA->FPA_GRUA) .And. ST9->(dbSeek(xFilial("ST9")+FPA->FPA_GRUA))
			If !lMvLocBac
				If Select("TRBTQY") > 0
					TRBTQY->(dbCloseArea())
				EndIf
				cQuery := " SELECT   TQY_STATUS"           + CRLF
				cQuery += " FROM " + RetSqlName("TQY") + " TQY " + CRLF
				cQuery += " WHERE    TQY.TQY_STTCTR < '20' "     + CRLF
				cQuery += "   AND    TQY.D_E_L_E_T_ = '' "       + CRLF
				cQuery += " ORDER BY TQY_STTCTR DESC "
				cQuery := changequery(cQuery) 
				TcQuery cQuery New Alias "TRBTQY"
				TRBTQY->(dbGotop()) // antes era na query top 1, agora pegamos o primeiro registro
				
				If ! TRBTQY->(Eof())
					LOCXITU21(ST9->T9_STATUS,TRBTQY->TQY_STATUS,FPA->FPA_PROJET,FPA->FPA_NFREM,FPA->FPA_SERREM,.T.)
					If RecLock("ST9",.F.)
						ST9->T9_STATUS := TRBTQY->TQY_STATUS 
						ST9->(MsUnLock())
					EndIf
				EndIf
				
				TRBTQY->(dbCloseArea())
			else
				If Select("TRBFQD") > 0
					TRBFQD->(dbCloseArea())
				EndIf
				cQuery := " SELECT   FQD_STATQY"           + CRLF
				cQuery += " FROM " + RetSqlName("FQD") + " FQD " + CRLF
				cQuery += " WHERE    FQD.FQD_STAREN < '20' "     + CRLF
				cQuery += "   AND    FQD.D_E_L_E_T_ = '' "       + CRLF
				cQuery += " ORDER BY FQD_STAREN DESC "
				cQuery := changequery(cQuery) 
				TcQuery cQuery New Alias "TRBFQD"
				TRBFQD->(dbGotop()) // antes era na query top 1, agora pegamos o primeiro registro
				
				If ! TRBFQD->(Eof())
					LOCXITU21(ST9->T9_STATUS,TRBFQD->FQD_STATQY,FPA->FPA_PROJET,FPA->FPA_NFREM,FPA->FPA_SERREM,.T.)
					If RecLock("ST9",.F.)
						ST9->T9_STATUS := TRBFQD->FQD_STATQY
						ST9->(MsUnLock())
					EndIf
				EndIf
				
				TRBFQD->(dbCloseArea())
			Endif
		EndIf
	
		If RecLock("FPA", .F.)
			FPA->FPA_FILREM	:= ""
			FPA->FPA_NFREM  := ""
			FPA->FPA_SERREM	:= ""
			FPA->FPA_ITEREM	:= ""
			FPA->FPA_DNFREM := StoD("")
			FPA->FPA_PEDIDO := ""
			FPA->(MsUnLock())
		EndIf
		
		_aZAG := FPA->(GetArea())
		_aSZ1 := FQ3->(GetArea())
		SC6->(dbSetOrder(4))
		SC6->(dbSeek(xFilial("SC6")+SF2->F2_DOC+SF2->F2_SERIE))
		While !SC6->(Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->(C6_NOTA+C6_SERIE) == SF2->F2_DOC+SF2->F2_SERIE
			If lMvLocBac
				FPY->(dbSetOrder(1))
				FPY->(dbSeek(xFilial("SC6") + SC6->C6_NUM))
				FPZ->(dbSetOrder(1))
				FPZ->(dbSeek(xFilial("SC6") + SC6->C6_NUM))
				cFpyRoma:= FPY->FPY_IT_ROM
				cPvAs	:= FPZ->FPZ_AS
			Else
				cFpyRoma:= SF2->F2_IT_ROMA
				cPvAs	:= SC6->C6_XAS
			EndIf

			If !empty(cPvAs)
				FQ3->(dbSetOrder(3))
				If FQ3->(dbSeek(xFilial("FQ3")+cPvAs))
					If !empty(FQ3->fq3_NFREM) .and. FQ3->fq3_NUM = cFpyRoma
						FQ3->(RecLock("FQ3",.F.))
						FQ3->fq3_NFREM	:= ""
						FQ3->fq3_SERREM	:= ""
						FQ3->(MsUnlock())
						cRoma := FQ3->FQ3_NUM
					EndIf
				EndIf
			EndIf
			SC6->(dbSkip())
		EndDo

		If !empty(cRoma)
			FQ2->(dbSetOrder(1))
			If FQ2->(dbSeek(xFilial("FQ2")+cRoma))
				FQ2->(RecLock("FQ2",.F.))
				FQ2->FQ2_NFSER := ""
				FQ2->(MsUnlock())
			EndIF
		EndIF

		RestArea(_aZAG)
		RestArea(_aSZ1)
		
		(cAliasQry)->( dbSkip() )
	EndDo

	(cAliasQry)->( dbCloseArea() )

	RestArea( aAreaZA0 )
	RestArea( aAreaST9 )
	RestArea( aAreaZAG )
	RestArea( aAreaSC6 )
	RestArea( aArea )

Return Nil
