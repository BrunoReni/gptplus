#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM040A.CH"

/*/
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
������������������������������������������������������������������������������������Ŀ��
���          ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                       ���
������������������������������������������������������������������������������������Ĵ��
���Programador  � Data   � FNC            �  Motivo da Alteracao                     ���
������������������������������������������������������������������������������������Ĵ��
���Leandro Dr.  �08/01/14�M12RH01         �Unificacao das Folhas. Projeto Versao 12  ���
���             �        �REQ.: 001973    �Criacao do Fonte. Funcoes de calculo      ���
���             �        �                �utilizadas na rescisao localizados        ���
�������������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������
*/

/*
��������������������������������������������������������������������������������Ŀ
�Fun��o      � fDesPerAnt � Autor � Kelly Soares           � Data �  20/06/2006  �
��������������������������������������������������������������������������������Ĵ
�Descri��o   � Gera verba de desconto dos dias pagos a maior no periodo anterior �
��������������������������������������������������������������������������������Ĵ
�Sintaxe     � fDesPerAnt()                   						   		  	 �
��������������������������������������������������������������������������������Ĵ
�Retorno     � aRetorno { Verba , Referencia , Valor }					         �
����������������������������������������������������������������������������������*/
Static Function fDesPerAnt()
                                        
Local aArea		:= GetArea()

Local nX
Local nValProv	:= 0
Local cRotAux	:= ""
Local cQuery	:= ""
Local cTabela	:= ""
Local cPrefixo	:= ""
Local cCpoVerba	:= ""
Local cCpoValor	:= ""
Local cFil		:= SRA->RA_FILIAL
Local cMat  	:= SRA->RA_MAT
Local cChave	:= ""
Local cCondSrv	:= ""       
Local cIndice	:= ""
Local cVerbaPro	:= ""
Local cCodiNova := aCodFol[648][1]
Local cDescNova := ""
Local cTipoNova	:= ""
Local aAberto	:= {}
Local aFechado	:= {}
Local aTodos 	:= {}
Local aRetorno	:= {}
Local aPerAux	:= {}
Local bCondSrv  := { || NIL }
                     
PosSrv(cCodiNova,xFilial("RCH"))
cDescNova := SRV->RV_DESC
cTipoNova := SRV->RV_TIPO

//������������������������������������������������������������Ŀ
//� Obtem periodos referentes ao mes e ano de demissao.        �
//��������������������������������������������������������������
fRetPerComp( 	StrZero(Month(dDataDem1),2)	,;		// Mes
				StrZero(Year(dDataDem1),4)	,;		// Ano
				xFilial("RCH")				,;		// Filial
				cProcesso					,;		// Processo
				NIL							,;		// Roteiro
				@aAberto					,;		// Periodos Abertos
				@aFechado					,;		// Periodos Fechados
				@aPerAux    				)		// Periodos Abertos e Fechados em Ordem Crescente
		
//������������������������������������������������������������Ŀ
//� Ignora periodos com roteiro diferente de FOL ou branco     �
//��������������������������������������������������������������
For nX := 1 to len(aPerAux)			 
	If ( aPerAux[nX][8] == fGetCalcRot('1') ) .or. ( Empty(aPerAux[nX][8] ) )
		aAdd( aTodos , aPerAux[nX] )
	EndIf
Next nX


If Len(aTodos) > 0                                                        

	#IFDEF TOP      
			
		For nX := 1 to len(aTodos)

			cRotAux := aTodos[nX][8]
			If Empty(cRotAux)
				cRotAux := fGetCalcRot('1')
			EndIf
			
		//������������������������������������������������������������Ŀ
		//� Determina tabela a ser utilizada, de acordo com data de    �
		//� fechamento do periodo.                                     �
		//��������������������������������������������������������������		
			If Ascan( aAberto , { |x| x[1] == aTodos[nX][1] } ) > 0
				cTabela  := "SRC"
				cPrefixo := "SRC.RC_"
			Else
				cTabela  := "SRD"
				cPrefixo := "SRD.RD_"
			EndIf						
			
		//������������������������������������������������������������Ŀ
		//� Seleciona apenas verbas de provento.                       �
		//��������������������������������������������������������������		
			cQuery := " SELECT SUM(" + cPrefixo + "VALOR) AS TOTAL "
			cQuery += " FROM " + RetSqlName(cTabela) + " " + cTabela
			cQuery += " INNER JOIN " + RetSqlName("SRV") + " SRV ON "
			cQuery += " ( " + cPrefixo + "PD = SRV.RV_COD AND SRV.RV_TIPOCOD = '1' AND "
			cQuery += " NOT SRV.RV_REFFER = 'S' AND NOT SRV.RV_REF13 = 'S' ) "
			cQuery += " WHERE " + cPrefixo + "FILIAL  = '" + cFil          + "' AND "
			cQuery += 			  cPrefixo + "MAT     = '" + cMat          + "' AND "
			cQuery += 			  cPrefixo + "PROCES  = '" + cProcesso     + "' AND "
			cQuery += 			  cPrefixo + "PERIODO = '" + aTodos[nX][1] + "' AND "
			cQuery += 			  cPrefixo + "SEMANA  = '" + aTodos[nX][2] + "' AND "
			cQuery += 			  cPrefixo + "ROTEIR  = '" + cRotAux       + "' AND "
			cQuery +=             cTabela  + ".D_E_L_E_T_ <> '*' "
	
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QRY', .F., .T.)			

		//������������������������������������������������������������Ŀ
		//� Acumula valor total de proventos do periodo.               �
		//��������������������������������������������������������������		
			nValProv += QRY->TOTAL

			dbCloseArea()
			
		Next nX

	#Else   
		
		//������������������������������������������������������������Ŀ
		//� Alimenta variavel "cVerbaPro" com verbas do tipo 1 - Prov. �
		//��������������������������������������������������������������		
		bCondSrv := { |e| If (ValType(e) = "C",&(e),If (ValType(e) = "B",Eval(e),.F.)) }
		cCondSrv := "SRV->RV_TIPOCOD == '1' .And. SRV->RV_REFFER != 'S' .And. SRV->RV_REF13 != 'S'"
		SRV->(dBeval({||cVerbaPro+=SRV->RV_COD+"/"},{||Eval(bCondSrv,cCondSrv)} ))
		
		For nX := 1 to len(aTodos)
		
			cRotAux := aTodos[nX][8]
			If Empty(cRotAux)
				cRotAux := fGetCalcRot('1')
			EndIf		

			//������������������������������������������������������������Ŀ
			//� Determina tabela a ser utilizada, de acordo com data de    �
			//� fechamento do periodo.                                     �
			//��������������������������������������������������������������		
			If Ascan( aAberto , { |x| x[1] == aTodos[nX][1] } ) > 0
				cTabela   := "SRC"
				cPrefixo  := "SRC.RC_"
				cIndice   := "RC_FILIAL + RC_MAT + RC_PROCES + RC_ROTEIR + RC_PERIODO + RC_SEMANA"
				cCpoVerba := "SRC->RC_PD"
				cCpoValor := "SRC->RC_VALOR"
			Else
				cTabela   := "SRD"
				cPrefixo  := "SRD.RD_"
				cIndice   := "RD_FILIAL + RD_MAT + RD_PROCES + RD_ROTEIR + RD_PERIODO + RD_SEMANA"
				cCpoVerba := "SRD->RD_PD"
				cCpoValor := "SRD->RD_VALOR"
			EndIf						
					
			//������������������������������������������������������������Ŀ
			//� Acumula valor total de proventos do periodo.               �
			//��������������������������������������������������������������
			DbSelectArea(cTabela)
			DbSetOrder( RetOrder( cTabela, cIndice ) )   
			cChave := cFil + cMat + cProcesso + cRotAux + aTodos[nX][1] + aTodos[nX][2]
			If DbSeek( cChave )	
				While !Eof() .and. &(cTabela + "->(" + cIndice + ")") == cChave
					If &(cCpoVerba) $ cVerbaPro
						nValProv += &(cCpoValor)
					EndIf
					DbSkip()
				Enddo		
			EndIf
		
		Next nX

	#EndIf   
	
	//������������������������������������������������������������Ŀ
	//� Proporcionaliza valor total de proventos de acordo com     �
	//� dias pagos a maior.                                        �
	//��������������������������������������������������������������
	If nValProv > 0  
		nDiasDesc := 30 - Day(dDataDem1)
		If ( nValProv := ( nValProv / 30 ) * nDiasDesc ) > 0
			aAdd( aRetorno , cCodiNova )
			aAdd( aRetorno , cDescNova )
			aAdd( aRetorno , cTipoNova )
			aAdd( aRetorno , nDiasDesc )
			aAdd( aRetorno , nValProv  )
		EndIf
	EndIf

EndIf

RestArea(aArea)

Return ( aRetorno )

/*
��������������������������������������������������������������������������������Ŀ
�Fun��o      � fMontSeqRes� Autor � Kelly Soares           � Data �  20/07/2006  �
��������������������������������������������������������������������������������Ĵ
�Descri��o   � Monta sequencia de verbas na rescisao                             �
��������������������������������������������������������������������������������Ĵ
�Sintaxe     � fMontSeqRes()                  						   		  	 �
��������������������������������������������������������������������������������Ĵ
�Retorno     � LOGICO                                     				         �
����������������������������������������������������������������������������������*/
Function fMontSeqRes()
                                
Local aSRRCols		:= ( oGet:aCols )
Local aColsAnt		:= aClone( aSRRCols )
Local aColsCopy		:= aClone( aSRRCols )
Local cNumSeq		:= ""
Local cStrCols 		:= ""
Local cStrCopy		:= ""
Local lRet			:= .T.
Local nX			:= 0
Local nSeq			:= 0
Local nPosOrd		:= 0
Local nPosCc		:= GdFieldPos( "RR_CC" 		)
Local nPosSe		:= GdFieldPos( "RR_SEMANA"	)
Local nPosSq		:= GdFieldPos( "RR_SEQ"		)
Local nPosPd		:= GdFieldPos( "RR_PD"		)
Local nPosMat		:= GdFieldPos( "RR_MAT"		)
Local nPosDeleted	:= GdFieldPos( "GDDELETED"	)
Local nLenCols		:= Len( aSRRCols )
Local nSvn			:= n
Local cCod			:= aSRRCols[ n , nPosPd ]

cNumSeq		:= PosSrv( aSRRCols[ n , nPosPD ] , SRA->RA_FILIAL, "RV_QTDLANC" )
cStrCols 	:= aSRRCols[ n , nPosPd ] + aSRRCols[ n , nPosCc ] + aSRRCols[ n , nPosSe ]

/*
��������������������������������������������������������������Ŀ
�O Numero Minimo de Lancamentos Permitidos e sempre "1"        �
����������������������������������������������������������������*/
// Se a verba tem a opcao de lancamento diario, nao tratar sequencia.
// So podera ter um lancamento da verba por dia.
cLcto := PosSRV(cCod , cFilial , "RV_LCTODIA" )

// Foi desativado a validacao de Lancamento diario pois nao existe o campo de Data de Referencia
If ( Empty( cNumSeq ) .or. ( cNumSeq == "1" ) .or. Empty( cCod ) )  
	If Val(cNumSeq) <= 1 
		If ( cLcto == "S" )
			aCposKey := { "RR_PD" , "RR_DATA"}
		Else
			aCposKey := { "RR_PD" , "RR_CC" , "RR_SEQ", "RR_DATA" }
		EndIf
		
		If !( GdCheckKey( aCposKey , 4 ) )
			Return( .F. )
		EndIf
	EndIf
EndIf	

/*
��������������������������������������������������������������Ŀ
�Salva Sequencia inicial de aCols para poder restaura-la na mes�
�ma ordem.                                                     �
����������������������������������������������������������������*/
For nX := 1 To nLenCols
	aAdd( aColsCopy[ nX ] , StrZero( nX , 4 ) )
Next nX

/*
��������������������������������������������������������������Ŀ
�Posicao da Ordem de Entrada								   �
����������������������������������������������������������������*/
nPosOrd := Len( aColsCopy[ nX - 1 ] )

/*
��������������������������������������������������������������Ŀ
�Ordena aColsCopy com as Chaves Respectivas                    �
����������������������������������������������������������������*/
aSort(aColsCopy, NIL, NIL, { |x,y|	x[nPosPd] + x[nPosCc] + x[nPosSe] + IIF(Empty(x[nPosSq]), Replicate("Z", aHeader[nPosSq, 4]), x[nPosSq]) + x[nPosOrd] <;
						 			y[nPosPd] + y[nPosCc] + y[nPosSe] + IIF(Empty(y[nPosSq]), Replicate("Z", aHeader[nPosSq, 4]), y[nPosSq]) + y[nPosOrd];
							} )

/*
��������������������������������������������������������������Ŀ
�Renumera Sequencia de Lancamentos                             �
����������������������������������������������������������������*/
cStrCols:= "*"
For nX := 1 To nLenCols				
	If (aColsCopy[nX, nPosDeleted] )
		aColsCopy[nX, nPosSq] := Space(aHeader[nPosSq, 4] )
		Loop
	EndIf
		
	cStrCopy := aColsCopy[nX, nPosPd] + aColsCopy[nX, nPosCc] + aColsCopy[nX, nPosSe]			
		
	If (nX == 1) .OR. cStrCopy != cStrCols
		cStrCols:= cStrCopy
		cNumSeq	:= PosSrv(aColsCopy[nX, nPosPd], SRA->RA_FILIAL, "RV_QTDLANC")
		nSeq	:= 0
	EndIf		

	nSeq++
			
	If (nSeq <= Val(cNumSeq) )
		If (((nX == nLenCols) .OR. (cStrCopy != aColsCopy[nX+1, nPosPd] + aColsCopy[nX+1, nPosCc] + aColsCopy[nX+1, nPosSe])) .AND.;
			 (nSeq == 1))
			aColsCopy[nX, nPosSq] := Space(aHeader[nPosSq, 4])		
		Else
			aColsCopy[nX, nPosSq] := StrZero(nSeq, aHeader[nPosSq, 4] )
		EndIf
	Else
		Help(" ", 1, "A090MAXSEQ")
		Return .F. 
	EndIf
Next nX

/*
��������������������������������������������������������������Ŀ
�Restaura Sequencia original de aColsCopy                      �
����������������������������������������������������������������*/
aSort( aColsCopy ,,, { |x,y| x[ nPosOrd  ] < y[ nPosOrd  ] } )

/*
��������������������������������������������������������������Ŀ
�Atualiza a Sequencia de Lancamentos                           �
����������������������������������������������������������������*/
For nX := 1 To Len( aSRRCols )
	//T// Ajuste devido a loopping
	If len(aColsOld) == Len( aSRRCols )
		aColsOld[ nX , nPosSq ] := aColsCopy[ nX , nPosSq ]
	EndIf
	aSRRCols[ nX , nPosSq ] := aColsCopy[ nX , nPosSq ]
Next nX

/*
��������������������������������������������������������������Ŀ
�Verifica se Existe o Objeto oGet:oBrowse para o Refresh()	   �
����������������������������������������������������������������*/
If ( Type("oGet:oBrowse") == "O" )
	/*
	��������������������������������������������������������������Ŀ
	�Compara o Conteudo para verificar se Houve Alteracao          �
	����������������������������������������������������������������*/
	If !ArrayCompare( aColsAnt , aSRRCols )
		/*
		��������������������������������������������������������������Ŀ
		�Repintando o Browse da GetDados							   �
		����������������������������������������������������������������*/
		oGet:oBrowse:Refresh()
		/*
		��������������������������������������������������������������Ŀ
		�Restaura Posicao de n Apos Refresh do Browse da GetDados	   �
		����������������������������������������������������������������*/
		n := nSvn
	EndIf	
EndIf
	
Return( lRet )

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � M040ResM2		�Autor� Mauricio Takakura � Data �25/03/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao de Calculo Rescisao para o Modelo 2 Folha Mexico     �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEM040                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Function M040ResM2(cAlias,nReg,nOpcx)
                  
Local cProces
Local cRoteir  	:= fGetCalcRot('4')	// Rescisao
Local nPosStatus  
Private lResM2 := .F.

//Verificar se esta com Calculo de Finiquito ou calculo de Aplicacion de Finiquito
DbSelectArea("SRC")
DbSetOrder(RetOrdem("SRC","RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO+RC_SEMANA"))
DbSeek(SRA->(RA_FILIAL+RA_MAT+RA_PROCES)+cRoteir, .F.)
If SRC->(Eof())
  	cSvRoteir := cRoteir 
  	cRoteir := fGetCalcRot('A')	// Aplicacao de Rescisao
   	DbSeek(SRA->(RA_FILIAL+RA_MAT+RA_PROCES)+cRoteir, .F.)
   	If SRC->(Eof())
   	   cRoteir := cSvRoteir
   	EndIf
EndIf
              
If nOpcx == 2
	cProces   := SRA->RA_PROCES  
	nPosStatus:= If( SRA->RA_SITFOLH = 'D', 2, 1)
  	If fGetTipoRot( cRoteir ) == "4"	
		GPEM022(cProces, cRoteir, nPosStatus, .T., SRA->RA_MAT,,,, .T.)
	Else
		cHelp := OemToAnsi( STR0004 ) + CRLF + OemToAnsi( STR0005 ) // "Ja existe um calculo de Aplica�ao"  ##  "de Rescisao para esse Funcionario!"
		Help(' ',1,"GPM040CAL",, cHelp , 1 , 0)
	EndIf

ElseIf nOpcx == 3 .Or. nOpcx == 4

	/*������������������������������������������������������������������������Ŀ
	  � Inicializa o filtro utilizando a funcao FilBrowse, Faltara um filtro   �
	  � da tabela SRC que sera executado depois do dbSetOrder pois o dbSetOrder|
	  � elimina o filtro do FilBrowse                                          |
	  �������������������������������������������������������������������������� */
  	aArray := {"SRA", "SRV", "SRC" }
	lResM2:= .T.
	Gpea090Mnt( cAlias, nReg, nOpcx-1,, cRoteir, 2, .T. )
	lResM2:= .F.
EndIf
Return()

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �fRotOrdPer�Autor�Gisele Varandas            �Data�29/07/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Verificar existencia de periodo para roteiro ordinario		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �GPEM040				     				             	   	�
�������������������������������������������������������������������������/*/
Function fRotOrdPer( cProcesso, cPeriodo, cNumPag, cRotOrdinar )

Local aArea		:= GetArea()
Local cFilRCH
Local lRet 		:= .F.

Begin Sequence

 	If Empty( cProcesso ) 
 		lRet := .F.
		Break
	EndIf

	cFilRCH	:= xFilial("RCH")
	DbSelectArea("RCH")
	RCH->( dbsetOrder( Retorder( "RCH" , "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR" ) ) )
	RCH->( dbSeek( cFilRCH + cProcesso + cPeriodo + cNumPag, .F. ) )

	While RCH->( !Eof() .and. ((RCH_FILIAL + RCH_PROCES + RCH_PER + RCH_NUMPAG) == (cFilRCH + cProcesso + cPeriodo + cNumPag )))	
			If RCH->(( RCH_ROTEIR == cRotOrdinar .and. Empty( RCH_DTFECH )) .Or.;
						(Empty( RCH_ROTEIR ) .and. Empty( RCH_DTFECH )))
				lRet := .T.
				Exit
			EndIf
			RCH->( dbSkip() )
	EndDo

End Sequence

RestArea( aArea )
		
Return( lRet )  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LiqResAnt �Autor  �Microsiga           � Data �  07/01/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LiqResAnt()

Local nRegAnt		:= 0

If !Empty(nRegSrg)
	nRegAnt	:= SRG->(Recno())
	SRG->(DbGoTo(nRegSrg))
	SRR->(DbSetOrder(1)) //RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA)+RR_PD+RR_CC
EndIf

If SRR->(DbSeek(SRG->RG_FILIAL + SRG->RG_MAT + "R" + DtoS(SRG->RG_DTGERAR) + aCodFol[303,1] ))
    fo_ADD(@oSRR,{"RR_PD", "RR_VALOR"}, { fGetCodFol("0303") , SRR->RR_VALOR } )                                                                                           
EndIf

If !Empty(nRegAnt)
	SRG->(DbGoTo(nRegAnt))
EndIf

Return(.T.) 