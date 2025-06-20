#INCLUDE "PROTHEUS.CH"
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 � SEA811   � Autor � Mauricio Pequim Jr.   � Data � 16.03.04  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Normaliza SEA, gravando Filial de origem do titulo para fins���
���          � de validacao da integridade referencial.                    |��
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function SEA811()
Local aSaveArea	:= GetArea()
Local cFile    := "SEA"+cEmpAnt+"UPD.log"
Local nHdlFile := 0
Local lContinua := .T.

#IFDEF TOP
	Local aStru
	Local cFiltro
	Local cAlias
	Local nX := 0
	Local nRegEmp:=SM0->(RecNo())
	Local aFiliais := {}
	Local cFilOrig := cFilAnt
	Local cChave := ""
	Local cChaveAnt := ""
#ENDIF

//-------------------------------------------------------
// Tratamento para executar somente se a versao base � 7
//-------------------------------------------------------
If _UPD811 .Or. _UPD101
	lContinua := .F.	
EndIf

If lContinua
	#IFDEF TOP
		DbSelectArea("SEA")   
		DbSetOrder(1)
		If Empty(xFilial("SEA")) .and. File(cFile)
			Return .T.				/// SE O ARQUIVO � COMPARTILHADO E O ARQUIVO LOG JA EXISTE (JA RODOU) CANCELA.
		Endif
	
		If !Empty(xFilial("SE2")) .and. !Empty(xFilial("SE1"))

			dbSelectArea("SM0")
			dbSeek(cEmpAnt)
			While !Eof() .and. M0_CODIGO == cEmpAnt
				aadd(aFiliais,{M0_CODFIL,.F.})
				dbSkip()
			Enddo		

	      dbSelectArea("SEA")
			aStru := SEA->(DbStruct())
			cFiltro := "SELECT EA_FILIAL,EA_PREFIXO,EA_NUM,EA_PARCELA,EA_TIPO,EA_FORNECE,EA_LOJA,R_E_C_N_O_ RECNO "
			cFiltro += "  FROM "+	RetSqlName("SEA")
			cFiltro += " WHERE EA_FILORIG = '"+ Space(Len(EA_FILORIG))+"'"  
			cFiltro += " ORDER BY " + SqlOrder("EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA+EA_FILIAL")
			cFiltro := ChangeQuery(cFiltro)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cFiltro), "TRBSEA", .F., .T.)
			aEval(aStru, {|e| If(e[2] != "C", TCSetField("TRBSEA", e[1], e[2],e[3],e[4]),Nil)})
			cAlias := "TRBSEA"
			UpdSet01(LastRec())
			While (cAlias)->(!Eof())
				UpdInc01("Updating SEA",.T.)
				//Posiciono SEA
				dbSelectArea("SEA")
				SEA->(DBGOTO((cAlias)->RECNO))
				lAchou := .F.
				If EA_CART == "R"  //Receber
					cChave := EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO
					cAlias2 := "SE1"
					cArq	  := "E1"
				Else	
					cChave := EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE_EA_LOJA
					cAlias2 := "SE2"
					cArq	  := "E2"
				Endif								
				If !(cChave == cChaveAnt)
					aFilVer := aClone(aFiliais)
					cChaveAnt := cChave
				Endif			
				//Tento todas as filiais
				cFilOrig := cFilAnt
				For nX := 1 to Len(aFiliais)
					If !aFilVer[nX,2] //Verifico se j� procurei nesta filial, esta chave
						cFilAnt := aFilVer[nX,1]
						dbSelectArea(cAlias2)
						If msSeek(xFilial(cAlias2)+cChave) .and. SEA->EA_NUMBOR == (cAlias2)->&(cArq+"_NUMBOR")
							lAchou := .T.
							aFilVer[nX,2] := .T.
							cFilGrv := &cArq._FILIAL
							Exit
						Endif
					Endif
				Next			
				cFilAnt := cFilOrig
			   //Gravar campos EA_FILORIG
				If lAchou .and. Reclock("SEA",.F.)
					REPLACE EA_FILORIG With cFilGrv
					MsUnLock()
					FKCOMMIT()
				ElseIf !lAchou
					RecLock("SEA")
					dbDelete()
					MsUnlock()
					FKCOMMIT()
				Endif	
				DbSelectArea(cAlias)
				DbSkip()
			EndDo 
			dbSelectArea("TRBSEA")
			dbCloseArea()
			dbSelectArea("SEA")
			dbSetOrder(1)
		Endif
	#ENDIF

	If Empty(xFilial("SEA")) .and. !File(cFile)		/// SE O SEA ESTIVER COMPARTILHADO E N�O EXISTIR O ARQUIVO DE LOG EM DISCO
		nHdlFile := MsFCreate(cFile,0)				/// CRIA O ARQUIVO DE LOG (FLAG) PARA INDICAR QUE N�O DEVE PROCESSAR NOVAMENTE.
		If nHdlFile > 0
			FWRITE(nHdlFile,"Este arquivo pode ser excluido apos a atualizacao de versao."+CHR(13)+CHR(10)+;
							"This file can be erased after the version update."+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
							"Arquivo SEA - Empresa "+cEmpAnt +" - compartilhado - concluido."+CHR(13)+CHR(10)+;
							"SEA File - Company "+cEmpAnt +" - shared - finished."+CHR(13)+CHR(10),312)
			FClose(nHdlFile)
		EndIf
	EndIf

EndIf

RestArea(aSaveArea)

Return .T.
