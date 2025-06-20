#include "Protheus.ch"
#include "OGX262.CH"

/** {Protheus.doc} OGX262NF

@param: 	Nil
@author: 	Bruna Fagundes Rocio
@since: 	21/01/2015
@Uso: 		SIGAAGR - Origina��o de Gr�os
**/

/***
Incluir valida��o para n�o permitir confirmar romaneios com tipo 6= (S) Devolucao de Deposito, 
caso o contrato das notas de origem possua servi�o na tabela de tarifas com fato gerador igual 
a Saldo, e tipo de cobran�a Reten��o, e n�o tenha executado o calculo at� o per�odo necess�rio 
para a data da sa�da. Incluir chamada para executar c�lculo autom�tico dos servi�os que tenham 
fato gerador Entrada ou Sa�da e o tipo de cobran�a seja Reten��o. 
***/
Function OGX262NF ()
	Local lReturn     := .t.
	Local aAreaAtu    := GetArea()
	Local cAliasNJR   := GetNextAlias()
	Local cAliasNKQ   := GetNextAlias()
	Local cAliasNJM   := GetNextAlias()
	Local cFiltroNKQ  := ""
	Local dFirstEntC := X262DTCTR( NJM->NJM_CODCTR )  

	Private aServico  := {}
	Private _cTabela  := Space(4)
	Private _cCombo1  := ""
	Private lExibe    := .F.
	Private lVazio    := .T.
	
	BeginSql Alias cAliasNJM
		SELECT NJM.*, NJJ.*
		  FROM %Table:NJM% NJM
		  INNER JOIN %Table:NJJ% NJJ 
		  ON NJJ.%notDel%
		 AND NJJ.NJJ_FILIAL  = %xFilial:NJJ%
		 AND NJJ.NJJ_CODROM  = NJM.NJM_CODROM
	   WHERE NJM.%notDel%
	     AND NJM.NJM_FILIAL  = %XFilial:NJM% 
	     AND NJM.NJM_CODROM  = %exp:NJM->NJM_CODROM%
	     AND NJM.NJM_ITEROM  = %exp:NJM->NJM_ITEROM% 			      
	EndSQL
	
	dbSelectArea(cAliasNJM)
	(cAliasNJM)->(DbGoTop())
	If ! (cAliasNJM)->( Eof() )
		
		BeginSql Alias cAliasNJR
			SELECT * 
			  FROM %Table:NJR% NJR
			 WHERE NJR.%NotDel%
			   AND NJR.NJR_FILIAL  = %xFilial:NJR%
			   AND NJR.NJR_CODCTR  = %exp:(cAliasNJM)->NJM_CODCTR% 
			   AND NJR.NJR_CODTSE <> ' ' 
		EndSQL
			
		dbSelectArea(cAliasNJR)
		(cAliasNJR)->( dbGoTop() )
		If ! (cAliasNJR)->( Eof() )
			
			BeginSql Alias cAliasNKQ
				SELECT *
				  FROM %Table:NKQ% NKQ
				 WHERE  NKQ.%notDel%
				   AND  NKQ_FILIAL  = %xFilial:NKQ%
				   AND  NKQ_CODTSE  = %exp:(cAliasNJR)->NJR_CODTSE%
				   AND  NKQ_ATIVO   = '1'
				   AND  NKQ_TIPCOB  = '1'  //Reten��o
				   AND (NKQ_FATGER  = '0'  //Entrada
				    OR  NKQ_FATGER  = '1' )//Sa�da
			EndSQL	
						
			DbSelectArea(cAliasNKQ)	
			(cAliasNKQ)->( DbGoTop() )	
			If ! (cAliasNKQ)->( Eof() )
				
				cFiltroNKQ += " AND  NKQ_TIPCOB = '1'  "
				cFiltroNKQ += " AND (NKQ_FATGER = '0'  "
				cFiltroNKQ += "  OR  NKQ_FATGER = '1') "
				cFiltroNKQ := "%" + cFiltroNKQ + "%"
				
				OGA262TARIF (cAliasNJR, cAliasNJM, dFirstEntC, dDatabase, dDatabase, cFiltroNKQ, .f., .t., )
				
			EndIf		
			(cAliasNKQ)->( DbCloseArea() )

		EndIf		
		(cAliasNJR)->( DbCloseArea() )
	EndIf
	(cAliasNJM)->( DbCloseArea() )

	RestArea( aAreaAtu )
Return ( lReturn )

/** {Protheus.doc} X262ATUC

@param: 	pcContrato -> Contrato
			paNota     -> Nota Origem
			plSimul    -> Simula��o
@author: 	Bruna Fagundes Rocio
@since: 	21/01/2015
@Uso: 		SIGAAGR - Origina��o de Gr�os
**/

Function X262QTRET( pcContrato, paNota, plSimul)
	Local aAreaAtu   := GetArea()
	Local nQtRet     := 0
	Local nQtQuebra  := 0
	Local cAliasNKG  := GetNextAlias()
	Local cAliasNJR  := GetNextAlias()
	
	Local cFiltroNKQ := ""
	Local aDRetSimul := {}
	Local aRetSimul  := {}
	Local aAux       := {}
	Local nX         := 0
	Local cDEmis     := ""     
	Local cTrans     := ""
	Local aRetorno   := { , }
	Local dFirstEntC := X262DTCTR( pcContrato )   
			
	BeginSql Alias cAliasNKG
		SELECT *
		  FROM %Table:NKG% NKG
		 WHERE NKG.%notDel%
		   AND NKG_FILIAL = %XFilial:NKG%
		   AND NKG_CODCTR = %exp:pcContrato%
		   AND NKG_QTDRET > 0 
		   AND (NKG_STATUS = '0'  //Pendente
		    OR  NKG_STATUS = '1'  //Atualizado
		    OR  NKG_STATUS = '4') //Negoc.Pend. 
	EndSQL
	
	dbSelectArea(cAliasNKG)
	(cAliasNKG)->( dbGoTop() )
	While ! (cAliasNKG)->( Eof() )
		If   ((cAliasNKG)->NKG_FATGER $ '0|2'; // ENTRADA OU SALDO 
		.And. (cAliasNKG)->NKG_DOCNUM = paNota[2];
		.And. (cAliasNKG)->NKG_DOCSER = paNota[3]);
		.Or. ((cAliasNKG)->NKG_FATGER = '1';   // SAIDA 
		.And. (cAliasNKG)->NKG_NFORI  = paNota[2];
		.And. (cAliasNKG)->NKG_SERORI = paNota[3])
			
			If (cAliasNKG)->NKG_TIPRET = '1' //Cobran�a Reten��o 
				nQtRet    += (cAliasNKG)->NKG_QTDRET
			Else //Quebra T�cnica
				nQtQuebra += (cAliasNKG)->NKG_QTDRET 
			Endif	
		Endif
		
		(cAliasNKG)->( DbSkip() )
	EndDo
	(cAliasNKG)->( DbCloseArea() )
	
	If plSimul = .T. 
		
		BeginSql Alias cAliasNJR
			SELECT *
			  FROM %Table:NJR% NJR
			 WHERE NJR.%notDel%
			   AND NJR_FILIAL = %xFilial:NJR%
			   AND NJR_CODCTR = %exp:pcContrato% 
			   AND NJR_TIPO   = '3' //Dep�sito de 3
		EndSQL
				
		dbSelectArea(cAliasNJR)
		(cAliasNJR)->( dbGoTop() )
		While ! (cAliasNJR)->( Eof() )
			
			If Len( paNota ) > 0
				dbSelectArea('NJM')
				dbSetOrder(1)
				If dbSeek( xFilial('NJM') + paNota[14] + paNota[15])
					cTrans := DtoS(NJM->NJM_DTRANS)
				Endif
				
				cFiltroNKQ += "  AND NKQ_FATGER = '1' " //Sa�da
				cFiltroNKQ += "  AND NKQ_TIPCOB = '1' " //Reten��o
				cFiltroNKQ := "%" + cFiltroNKQ + "%"
				
				aRetSimul := {}			
				cDEmis    := DtoS(CtoD(paNota[4]))			
				aAdd( aRetSimul, { '1', paNota[2], paNota[3], cDEmis, ;
					            paNota[6], (paNota[9] - (nQtRet + nQtQuebra )), paNota[10], paNota[14],;
					            paNota[15], cTrans, 0 } )						
							
				/* Par�metros A262SIMUL
					pcAliasNJR    -> Recebe ponteiro da NJR Contrato
					nQtSimul      -> Recebe quantidade da simula��o de retirada
					dDTSimul		-> Recebe data da simula��o de retirada 
					cTCSimul		-> Recebe tipo de controle da simula��o de retirada 0=F�sico;2=Simb�lico
					dFirstEnt		-> Recebe data da primeira entrega para o contrato 
					dInicioMov		-> Recebe data inicio sele��o
					dFinalMov		-> Recebe data final  sele��o 
					cFiltroSer		-> Recebe filtros para a Tabela NKQ Tarifas de Servi�os 
					lGeraArr		-> Recebe flag indica se deve gerar array para impress�o
					lGeraNKG      -> Recebe flag indica se deve gerar NKG
					aRetSimul     -> Recebe array  
				*/			
							
				aAux := A262SIMUL(cAliasNJR , (paNota[9] - (nQtRet + nQtQuebra )),; 
				                  dDatabase , '0'       ,; 
				                  dFirstEntC, dDatabase ,; 
				                  dDatabase , cFiltroNKQ,;
				                  .f., .f.  , aRetSimul)
				      
				If Len ( aAux ) > 0
					For nX := 1 To Len ( aAux )   
						aAdd( aDRetSimul, aAux[nX])
					Next nX	
				Endif				                  
			Endif	
			
			(cAliasNJR)->( DbSkip() )	
		EndDo		
		(cAliasNJR)->( DbCloseArea() )
		
		If Len ( aDRetSimul ) > 0
			For nX := 1 to Len ( aDRetSimul )
							
				nQtRet += 	aDRetSimul[nX, 11]		
			Next nX
		Endif				
	Endif
	
	aRetorno[1] := nQtQuebra
	aRetorno[2] := nQtRet
	
	//aAdd( aRetorno, { nQtQuebra, nQtRet} )
	
	RestArea( aAreaAtu )
Return ( aRetorno )

/** {Protheus.doc} X262ATUC

@param: 	pcContrato -> Contrato
			paSelNfs   -> Notas origem marcadas
@author: 	Bruna Fagundes Rocio
@since: 	21/01/2015
@Uso: 		SIGAAGR - Origina��o de Gr�os
**/

Function OGX262VAL( pcContrato, paSelNfs)
	Local lReturn   := .f.
	Local cAliasNKQ := GetNextAlias()
	Local cAliasNKG := GetNextAlias()
	Local cMessage  := ""
	Local dPrevCal  
	Local dLastCalc

	dbSelectArea('NJR')
	dbSetOrder(1)
	If dbSeek( xFilial('NJR') + pcContrato )
		
		BeginSql Alias cAliasNKQ		
			SELECT *
			  FROM %Table:NKQ% NKQ
			 WHERE NKQ.%notDel%
			   AND NKQ_FILIAL  = %xFilial:NKQ%
			   AND NKQ_CODTSE  = %exp:NJR->NJR_CODTSE% // tabela do contrato do parametro
			   AND NKQ_ATIVO   = '1' 
			   AND NKQ_FATGER  = '2' //Saldo 
			   AND NKQ_TIPCOB  = '1' //Reten��o
			 ORDER BY NKQ_ORDEM		   
		EndSQL
		
		dbSelectArea(cAliasNKQ)	
		(cAliasNKQ)->( dbGoTop() )		
		While ! (cAliasNKQ)->( Eof() )
						
			BeginSql Alias cAliasNKG
				SELECT MAX(NKG_DATFIM) AS dQLastCalc
					 FROM %Table:NKG% NKG
					WHERE NKG.%notDel%
					  AND NKG_FILIAL = %xFilial:NKG%
					  AND NKG_CODROM = %exp:paSelNfs[8]%
					  AND NKG_ITEROM = %exp:paSelNfs[9]%
					  AND NKG_CODTSE = %exp:(cAliasNKQ)->NKQ_CODTSE%
					  AND NKG_ITETSE = %exp:(cAliasNKQ)->NKQ_ITETSE%
			EndSQL
							
			dbSelectArea(cAliasNKG)
			(cAliasNKG)->( dbGoTop() )
			dLastCalc := Nil		
			If 	!Empty((cAliasNKG)->dQLastCalc)
				dLastCalc := (cAliasNKG)->dQLastCalc
			EndIf
			(cAliasNKG)->( DbCloseArea() )
			
			dbSelectArea(cAliasNKQ)
			If    ( cAliasNKQ )->NKQ_PERCOB = '0'; // di�rio
			.And. (Empty(dLastCalc) .Or. StoD(dLastCalc) < dDataBase)
				cMessage := STR0001 + paSelNfs[2] + ". " + STR0002 + ( cAliasNKQ )->NKQ_CODDES //"Necess�rio c�lculo servi�os para o Documento: "####"Servi�o: "####
				Help( , , STR0003, , cMessage, 1, 0 ) //"Ajuda"
				lReturn = .t. 
			Elseif ( cAliasNKQ )->NKQ_PERCOB $ '1|2'
				// quinzenal ou mensal
				// verificar a �ltima data de c�lculo que deveria ter sido executado 
			
				If   ((( cAliasNKQ )->NKQ_PERCOB = '2') ;
				.Or.  (( cAliasNKQ )->NKQ_PERCOB = '1') ;
				.And.  (Day(dDataBase) <= 15) )
					// quinzenal <= 15 ou mensal -> �ltimo dia do m�s anterior */
					dPrevCal := CtoD('01/' + STR(MONTH(dDataBase),2) + '/' + STR(YEAR(dDataBase),4))
				Else
					// quinzenal > 15 dia 16
					dPrevCal := CtoD( '16/' + STR(MONTH(dDataBase),2) + '/' + STR(YEAR(dDataBase),4))
				Endif
				
				dPrevCal -= 1 // deve ficar com a data do �ltimo calculo necess�rio
								
				If     dPrevCal >= paSelNfs[4] ; 
				.And. (Empty(dLastCalc) .Or. StoD(dLastCalc) < dPrevCal)
					cMessage := STR0001 + paSelNfs[2] + ". " + STR0002 + ( cAliasNKQ )->NKQ_CODDES //"Necess�rio c�lculo servi�os para o Documento: "####"Servi�o: "####
					Help( , , STR0003, , cMessage, 1, 0 ) //"Ajuda"
					lReturn := .t.	
				Endif
			Endif
			
			(cAliasNKQ)->( DbSkip() )
		EndDo	
		(cAliasNKQ)->( DbCloseArea() )
		
	EndIf
	
Return ( lReturn )

/** {Protheus.doc} X262NOTA

@param: 	
@author: 	Bruna Fagundes Rocio
@since: 	23/01/2015
@Uso: 		SIGAAGR - Origina��o de Gr�os
**/
/*/{Protheus.doc} X262NOTA
Retorna array de dados com NKG de reten��o
@type function
@version  P12
@author Bruna Fagundes Rocio
@since 23/01/2015
@param pcContrato, character, codigo do contrato
@param pcDocto, character, numero NF NKG que gerou reten��o
@param pcSerie, character, serie NF NKG que gerou reten��o
@param lNFRet, logical, se traz reten��o NKG confirmada com NF gerada
@return array, array de dados
/*/
Function X262NOTA( pcContrato, pcDocto, pcSerie, lNFRet)
	Local aNotas    := {}
	Local cAliasNKG := GetNextAlias()
	Local cFiltNKG	:= "%%"
	Default lNFRet 	:= .T. //PADR�O

	If .NOT. lNFRet  
		//cFiltNKG FILTRA NKG COM STATUS CONFIRMADO, MAS N�O TRAZ NKG CONFIRMADA COM NF(SD2) DE RETEN��O GERADA
		//NKG PODE ESTAR COM STATUS CONFIRMADO, COM ROMANEIO GERADO MAS SEM ESTAR CONFIRMADO, OU SEJA, N�O GEROU NF(SD2) DE RETEN��O AINDA
		cFiltNKG := "% AND  (SELECT COUNT(D2_DOC) FROM " + RetSqlName("NKS") + " NKS " 
		cFiltNKG += " INNER JOIN " + RetSqlName("NJJ") + " NJJ ON NJJ.D_E_L_E_T_='' AND NJJ_FILIAL = '"+FWxFilial('NJJ') +"' AND NJJ_CODROM=NKS_CODROM "
		cFiltNKG += " INNER JOIN " + RetSqlName("NJM") + " NJM ON NJM.D_E_L_E_T_='' AND NJM_FILIAL = '"+FWxFilial('NJM') +"' AND NJM_CODROM=NJJ_CODROM AND NJM_DOCNUM <> '' "
		cFiltNKG += " INNER JOIN " + RetSqlName("SD2") + " SD2 ON SD2.D_E_L_E_T_='' AND D2_FILIAL  = '"+FWxFilial('SD2') +"' AND D2_DOC = NJM_DOCNUM AND D2_SERIE = NJM_DOCSER "
		cFiltNKG += " WHERE NKS.D_E_L_E_T_ = '' AND NKS_FILIAL = '"+FWxFilial('NKS') +"' AND NKS_FECSER = NKG_FECSER ) = 0  "
		cFiltNKG += "%"
	EndIf
	
	BeginSql Alias cAliasNKG
		SELECT *
		  FROM %Table:NKG% NKG
		 WHERE  NKG.%notDel%
		   AND  NKG_FILIAL = %xFilial:NKG%
		   AND  NKG_CODCTR = %exp:pcContrato%
		   AND  NKG_QTDRET > 0 
		   AND (NKG_STATUS = '0'  //Pendente	
		    OR  (NKG_STATUS = '2' %Exp:cFiltNKG% )  //Confirmado	    
		    OR  NKG_STATUS = '1'  //Atualizado
		    OR  NKG_STATUS = '4') //Negoc.Pend.
	EndSQL 
	
	dbSelectArea(cAliasNKG)
	(cAliasNKG)->( dbGoTop() )
	While ! (cAliasNKG)->( Eof() )
		If   ((cAliasNKG)->NKG_FATGER $ '0|2'; // ENTRADA OU SALDO 
		.And. (cAliasNKG)->NKG_DOCNUM = pcDocto;
		.And. (cAliasNKG)->NKG_DOCSER = pcSerie);
		.Or. ((cAliasNKG)->NKG_FATGER = '1';   // SAIDA 
		.And. (cAliasNKG)->NKG_NFORI  = pcDocto;
		.And. (cAliasNKG)->NKG_SERORI = pcSerie)
			
			aAdd( aNotas, { (cAliasNKG)->NKG_DATFIM, (cAliasNKG)->NKG_QTDRET, (cAliasNKG)->NKG_CODDES} )
			
		Endif
		(cAliasNKG)->( DbSkip() )
	EndDo
	(cAliasNKG)->( DbCloseArea() )
	
Return ( aNotas )

/** {Protheus.doc} X262DTCTR

@param: 	
@author: 	Bruna Fagundes Rocio
@since: 	30/01/2015
@Uso: 		SIGAAGR - Origina��o de Gr�os
**/
Function X262DTCTR( pcContrato )

	Local cAliasNJM  := GetNextAlias()
	Local dFirstEntC 

	BeginSql Alias cAliasNJM
		SELECT NJM.*, NJJ.*
		  FROM %Table:NJM% NJM
		  INNER JOIN %Table:NJJ% NJJ 
		  ON NJJ.%notDel%
		 AND NJJ.NJJ_FILIAL  = %xFilial:NJJ%
		 AND NJJ.NJJ_CODROM  = NJM.NJM_CODROM
		 AND NJJ.NJJ_STATUS  = '3' //Confirmado
	   WHERE NJM.%notDel%
	     AND NJM.NJM_FILIAL  = %XFilial:NJM% 
	     AND NJM.NJM_CODCTR  = %exp:pcContrato%		
	     ORDER BY NJM.NJM_DTRANS, NJM.NJM_CODROM 	      
	EndSQL
	
	dbSelectArea(cAliasNJM)
	(cAliasNJM)->( DbGoTop() )
	If ! (cAliasNJM)->( Eof() )
		dFirstEntC := ( cAliasNJM )->NJM_DTRANS
	EndIf	
	(cAliasNJM)->( DbCloseArea() )
	
Return ( dFirstEntC )

/** {Protheus.doc} OGX262QTEC

@param: 	Nil
@author: 	Bruna Fagundes Rocio
@since: 	30/01/2015
@Uso: 		SIGAAGR - Origina��o de Gr�os
**/

/***
Incluir valida��o para n�o permitir confirmar romaneios com tipo 6= (S) Devolucao de Deposito, 
caso o contrato das notas de origem possua servi�o na tabela de tarifas com fato gerador igual 
a Saldo, e tipo de cobran�a Reten��o, e n�o tenha executado o calculo at� o per�odo necess�rio 
para a data da sa�da. Incluir chamada para executar c�lculo autom�tico dos servi�os que tenham 
fato gerador Entrada ou Sa�da e o tipo de cobran�a seja Reten��o. 
***/
Function OGX262QTEC (cAliasNJM)
	Local lReturn     := .T.
	Local aAreaAtu    := GetArea()
	Local cAliasNJR   := GetNextAlias()
	Local cAliasNKQ   := GetNextAlias()
	Local cAliasNKG   := GetNextAlias()
	Local aCalculado  := {}
	Local nX          := 0
		
	BeginSql Alias cAliasNJR
		SELECT * 
		  FROM %Table:NJR% NJR
		 WHERE NJR.%NotDel%
		   AND NJR.NJR_FILIAL  = %xFilial:NJR%
		   AND NJR.NJR_CODCTR  = %exp:(cAliasNJM)->NJM_CODCTR% 
		   AND NJR.NJR_CODTSE <> ' ' 
	EndSQL
	
	dbSelectArea(cAliasNJR)
	(cAliasNJR)->( dbGoTop() )
	While ! (cAliasNJR)->( Eof() )
		
		BeginSql Alias cAliasNKQ
			SELECT *
			  FROM %Table:NKQ% NKQ
			 WHERE NKQ.%notDel%
			   AND NKQ_FILIAL  = %xFilial:NKQ%
			   AND NKQ_CODTSE  = %exp:(cAliasNJR)->NJR_CODTSE%
			   AND NKQ_ATIVO   = '1'
			   AND NKQ_TIPCOB  = '1'  //Reten��o
			   AND NKQ_FATGER  = '2'  //Saldo
		EndSQL	
					
		DbSelectArea(cAliasNKQ)	
		(cAliasNKQ)->( DbGoTop()	)
		While ! (cAliasNKQ)->( Eof() )
		
			BeginSql Alias cAliasNKG
				SELECT *
				  FROM %Table:NKG% NKG
				 WHERE NKG.%notDel%
				   AND NKG.NKG_FILIAL = %xFilial:NKG%
				   AND NKG.NKG_CODCTR = %exp:(cAliasNJR)->NJR_CODCTR%	
				 ORDER BY NKG_FILIAL, NKG_CODCTR, NKG.NKG_ITEMOV DESC
			EndSQL
			
			dbSelectArea(cAliasNKG)
			(cAliasNKG)->( dbGoTop() )
			While ! (cAliasNKG)->( Eof() )
				
				If Len(aCalculado) > 0
					For nX := 1 to Len(aCalculado)
						
						If    aCalculado[nX, 1] = (cAliasNKG)->NKG_FILIAL ;
						.And. aCalculado[nx, 2] = (cAliasNKG)->NKG_CODCTR ;
						.And. aCalculado[nX, 3] = (cAliasNKG)->NKG_CODROM ;
						.And. aCalculado[nX, 4] = (cAliasNKG)->NKG_DOCSER ;
						.And. aCalculado[nX, 5] = (cAliasNKG)->NKG_DOCNUM
							(cAliasNKG)->( DbSkip() )
							Loop
						Endif
						
					Next nX
				Endif
				
				If    (cAliasNKG)->NKG_PERCOB  = '2'  ; //Mensal
				.And. Month( StoD( (cAliasNKG)->NKG_DATCAL ) ) < Month( dDatabase ) ;
				.And. StoD( (cAliasNKG)->NKG_DATCAL ) < dDatabase
					lReturn := .f.
					Exit
					
				ElseIf (cAliasNKG)->NKG_PERCOB  = '1' ; //Quinzenal
				.And. ( (StoD((cAliasNKG)->NKG_DATCAL)  < dDatabase ;
				   .And. Day(StoD((cAliasNKG)->NKG_DATCAL)) < 15 ;
				   .And. Day(dDatabase) > 15) ;
				   .Or. (StoD((cAliasNKG)->NKG_DATCAL) < dDatabase ;
				   .And. Day(StoD((cAliasNKG)->NKG_DATCAL)) > 15 ;
				   .And. Day(dDatabase) < 15 ;
				   .And. Month(dDatabase) > Month(StoD((cAliasNKG)->NKG_DATCAL)) ) )
						lReturn := .f.
						Exit
					
				ElseIf (cAliasNKG)->NKG_PERCOB = '0' ; //Di�rio
				.And. 	 StoD((cAliasNKG)->NKG_DATCAL) < dDatabase 
					lReturn := .f.
					Exit
					
				EndIf 
				
				aAdd( aCalculado, { (cAliasNKG)->NKG_FILIAL, ; 
					                 (cAliasNKG)->NKG_CODCTR, ; 
					                 (cAliasNKG)->NKG_CODROM, ; 
					                 (cAliasNKG)->NKG_DOCSER, ; 
					                 (cAliasNKG)->NKG_DOCNUM })
					                 
				(cAliasNKG)->( DbSkip() )
			EndDo
			(cAliasNKG)->( DbCloseArea() )
			
			If !lReturn
				Exit
			Endif
			
			(cAliasNKQ)->( DbSkip() )
		EndDo		
		(cAliasNKQ)->( DbCloseArea() )
		
		If !lReturn
			Exit
		Endif
		
		(cAliasNJR)->( DbSkip() )
	EndDo			
	(cAliasNJR)->( DbCloseArea() )

	If !lReturn
		Help( , , STR0003, , STR0004, 1, 0 ) //"Ajuda"###"Execute o c�lculo de servi�os para o contrato do romaneio."
	Endif
	
	RestArea( aAreaAtu )
Return ( lReturn )
