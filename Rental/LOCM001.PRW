#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "LOCM001.ch"

/*/{Protheus.doc} LOCM001.PRW
ITUP Business - TOTVS RENTAL
@type Function
@author Frank Zwarg Fuga
@since 03/12/2020
@version P12
@history 03/12/2020, Jose Eulálio, Fonte produtizado.
Antigo ponto de entrada: MNTA400FSF2520E.PRW
Após a confirmação da tela de finalização da OS
/*/  

Function LOCM001()
Local _aAreaOLD := GetArea()
Local _aAreaST9 := ST9->(GetArea())
Local _aAreaSTL := STL->(GetArea())
Local _aAreaZC1 := FPG->(GetArea())
Local _aAreaST1 := ST1->(GetArea())
Local _cQrySTL  := "" 
Local cLocx061  := SuperGetMV("MV_LOCX061",.F., "")
Local cAliasSTL := GetNextAlias()
Local _lGerCE   := SuperGetMV("MV_LOCX007",.F.,.F.)	// Parametro que define se gera Custo Extra na OS 
Local _lRet     := .T.

	//Gera Custo Extra na OS
	If _lGerCE 

		_cQrySTL := "Select TL_FILIAL  , TL_ORDEM , TL_PLANO , TL_TAREFA , TL_TIPOREG , TL_CODIGO , TL_SEQRELA , TL_SEQTARE , "
		_cQrySTL += " TL_QUANTID , TL_CUSTO , STL.R_E_C_N_O_ As STL_RECNO_ "
		//03/08/2022 - Jose Eulalio - SIGALOC94-314 - MNT - Incorporação dos pontos de entrada - Manunteção de ativos
		If STL->(FieldPos("TL_AS")) > 0 
			_cQrySTL += " , TL_AS "
		EndIf
		_cQrySTL += "From "+RetSqlName("STL")+" STL (NoLock) "
		_cQrySTL += "Where STL.D_E_L_E_T_ <> '*'  And  STL.TL_FILIAL = '"+xFilial("STL")+"'  And  STL.TL_ORDEM = '"+M->TJ_ORDEM+"' " 
		_cQrySTL += "  And STL.TL_SEQRELA >  '0  ' " 
		If STL->(FieldPos("TL_AS")) > 0 
			_cQrySTL += " And STL.TL_AS = 'S' "
		EndIf
		_cQrySTL += "Order By TL_FILIAL , TL_ORDEM , TL_PLANO , TL_TAREFA , TL_TIPOREG , TL_CODIGO , TL_SEQRELA , TL_SEQTARE "
		_cQrySTL := ChangeQuery(_cQrySTL)
		DBUSEAREA(.T. , "TOPCONN" , TCGENQRY(,,_cQrySTL) , cAliasSTL , .F. , .T.) 

		//Gera FPG
		If (cAliasSTL)->(!Eof()) 																						// --> 'STL->' 
			//roda resultados na STL
			While (cAliasSTL)->(!Eof()) .And. xFilial("STL") = (cAliasSTL)->TL_FILIAL .And. M->TJ_ORDEM = (cAliasSTL)->TL_ORDEM // --> 'STL->' 
				//somente se for Frete
				If (cAliasSTL)->TL_TIPOREG <> "F"
					//Insere registro na FPG
					If RecLock("FPG",.T.) 	
						// --> Estava: .F. 
						//gera numeração nova
						_cSeq := GetSx8Num("FPG","FPG_SEQ")
						ConfirmSx8()

						//popula os campos
						FPG->FPG_FILIAL := xFilial("FPG") 
						If STJ->(FieldPos("TJ_PROJETO")) > 0  .And.  STJ->(FieldPos("TJ_OBRA")) > 0  .And.  STJ->(FieldPos("TJ_AS")) > 0 
							FPG->FPG_PROJET := M->TJ_PROJETO
							FPG->FPG_OBRA   := M->TJ_OBRA 
							FPG->FPG_NRAS   := M->TJ_AS 
						EndIf

						//caso seja mão de obra
						If (cAliasSTL)->TL_TIPOREG == "M"																	// --> 'STL->' 
							//Localiza Produto de Mão de Obra na ST1 (Funcionários)
							ST1->(DbSetOrder(1)) //T1_FILIAL+T1_CODFUNC
							If ST1->(DbSeek(xFilial("ST1") + (cAliasSTL)->TL_CODIGO)) .And. !Empty(ST1->T1_PRODMO )
								FPG->FPG_PRODUTO := ST1->T1_PRODMO 
							Else
								FPG->FPG_PRODUTO := cLocx061 
							EndIf
						ElseIf (cAliasSTL)->TL_TIPOREG == "P"
							FPG->FPG_PRODUTO := (cAliasSTL)->TL_CODIGO  														// --> 'STL->' 
						EndIf
						
						FPG->FPG_DESCRI      := Posicione("SB1",1,xFilial("SB1")+FPG->FPG_PRODUTO,"B1_DESC") 
						FPG->FPG_QUANT       := (cAliasSTL)->TL_QUANTID 														// --> 'STL->' 
						FPG->FPG_VLUNIT      := Posicione("SB1",1,xFilial("SB1")+FPG->FPG_PRODUTO,"B1_PRV1") 			// --> B1_UPRC 
						If FPG->FPG_VLUNIT < (cAliasSTL)->TL_CUSTO 															// --> 'STL->' 
							FPG->FPG_VLUNIT  := (cAliasSTL)->TL_CUSTO / FPG->FPG_QUANT										// --> 'STL->' 
						EndIf 
						FPG->FPG_VALOR       := FPG->FPG_QUANT * FPG->FPG_VLUNIT 
						FPG->FPG_VALTOT      := FPG->FPG_VALOR 
						FPG->FPG_STATUS      := "1" 
						FPG->FPG_COBRA       := " " 																	// "S" 
						FPG->FPG_DTENT       := dDataBase 
						FPG->FPG_TIPO        := "4" 
						FPG->FPG_JUNTO       := "S" 
						FPG->FPG_CUSTO       := "MNTA400" //STR0001 //"ORDEM DE SERVIÇO" 
						FPG->FPG_CODDES      := ST9->T9_CODBEM 
						FPG->FPG_DESPES      := ST9->T9_NOME 
						FPG->FPG_DOCORI      := M->TJ_ORDEM 
						FPG->FPG_RECORI      := (cAliasSTL)->STL_RECNO_ 														// --> 'STL->(Recno())' 
						FPG->FPG_SEQ         := _cSeq
						FPG->(MsUnLock())
					EndIf
				EndIf	
				(cAliasSTL)->(dbSkip()) 																					// --> 'STL->' 
			EndDo
		Else 
			//MsgAlert( 	STR0002 + " ["+M->TJ_ORDEM+"] " + STR0003 + " [" + xFilial("STL") + "] " + Chr(13) + Chr(10) + ; // "A Ordem de Servico" + " ["+M->TJ_ORDEM+"] " + "da Filial" + " [" + xFilial("STL") + "] "
			//			STR0004 + Chr(13) + Chr(10) + ; // "não foi localizada na tabela Ordens de Serviço de Manutenção (STL)."
			//         	STR0005 , "LOCM001" ) //"Para a correta gravação do Custo Extra, é necessário Salvar a Ordem de serviço antes de Finalizar !"
			_lRet := .T.  // Frank em 19/01/23 estava retornando .F.
		EndIf 
		(cAliasSTL)->(DbCloseArea())
	EndIf 

	RestArea( _aAreaZC1 )
	RestArea( _aAreaSTL )
	RestArea( _aAreaST9 )
	RestArea( _aAreaOLD )
	RestArea( _aAreaST1 )

Return _lRet 
