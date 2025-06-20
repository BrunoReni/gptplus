#INCLUDE "AGRA500.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//===================================================================================
/*****  Fun��es relacionadas a entrada por transfer�ncia - Romaneios  *****/
//===================================================================================


/*/{Protheus.doc} A500EntTra
Realiza a entrada por transfer�ncia com gera��o de romaneio de sa�da automaticamente
@author silvana.torres
@since 27/03/2018
@version undefined
@param cFilCli, characters, descricao
@param cFilOri, characters, descricao
@param cRomOri, characters, descricao
@param lAlgodao, logical, descricao
@param cNumOP, characters, descricao
@type function
/*/
Function A500EntTra(cFilCli, cFilOri, cRomOri, lAlgodao, cNumOP, oModel, lEfet)
	Local cRomPar	 := ""	//--Para o processo de transferencia criar romaneios pelo GFE
	Local aMsgHist	 := {}
	Local lRet		 := .T.
	Local cTpMovto   := SuperGetMV("MV_TPMVTRF",.F.,'') //Tipo de movimento para Transfer�ncia entre filiais
	Local cTesEnt	 := ""
	Local cLocalEnt	 := ""
	Local cFil		 := ""
	Local cDesPro	 := ""
	
	Private _cIdMV := ""  //usada para gravar movimenta��o (AGRX500H.prw)

	//Verifica se entrada foi originada por um romaneio de sa�da
	If NJJ->NJJ_TIPO = "A" .AND. SUBSTRING(NJJ->NJJ_OBS,1,17) = "Filial de origem:"
	   //se entrada foi criada por sa�da j� foi gravada movimenta��o no mesmo ID, ent�o n�o faz nada
	Else
		//sen�o grava movimenta��o entrada por transfer�ncia no OG (OGA440) 
		If lRet .And. !Empty(cTpMovto) 
		   	lRet := A500GrvMov(cTpMovto, NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM)
		EndIf
	EndIf	
							
	IF .NOT. Empty(NJJ->NJJ_CODPRO) .AND. .NOT. Empty(NJJ->NJJ_PSLIQU) .AND. .NOT. Empty(NJJ->NJJ_CODSAF) .AND. ;
	   .NOT. Empty(NJJ->NJJ_CODENT) .AND. .NOT. Empty(NJJ->NJJ_LOJENT) .AND. .NOT. Empty(NJJ->NJJ_TES) 
	    	   	    	   
	   cTesEnt 		:= NJJ->NJJ_TES
	   cLocalEnt	:= NJJ->NJJ_LOCAL
	    	   	    	   
       //Verifica se Gera Pr�-romaneio(flag no tipo de opera��o)
	   if AGRX500GPR(NJJ->NJJ_TOETAP)
	   
	   		if lAlgodao
		    	lRet := AGRX500DXL(NJJ->NJJ_PSLIQU, .T., cNumOP) //Atualiza peso l�quido nos fard�es vinculados ao romaneio.
		    endIf
		    
			IF lRet .AND. .NOT. Empty(NJJ->NJJ_CODPRO) .AND. .NOT. Empty(NJJ->NJJ_PSLIQU) .AND. .NOT. Empty(NJJ->NJJ_LOCAL)
				//verifica se a produ��o � de outra filial
				cFilCli := AGRX500POF(NJJ->NJJ_CODENT, NJJ->NJJ_LOJENT)
				
				if trim(cFilCli) <> ""
				
					//--ALTERA A FILIAL CORRENTE PARA A FILIAL DA ENTIDADE
					//================================
					cFilAnt := cFilCli			
					//================================
					
					//gera romaneio pendente de aprova��o
					if .NOT. A500GerRom(NJJ->NJJ_TIPO, NJJ->NJJ_TOETAP, cFilOri, .T., lAlgodao, @cRomPar, oModel)
						lRet := .F.
					endIf

					//Verifica se entrada foi originada por um romaneio de sa�da
					If NJJ->NJJ_TIPO = "A" .AND. SUBSTRING(NJJ->NJJ_OBS,1,17) = "Filial de origem:"
					   //se entrada foi criada por sa�da j� foi gravada movimenta��o no mesmo ID, ent�o n�o faz nada
					Else
						//sen�o grava movimenta��o saida por transfer�ncia no OG (OGA440) 
						If lRet .And. !Empty(cTpMovto) 
						   	lRet := A500GrvMov(cTpMovto, cFilCli, NJJ->NJJ_CODROM)
						EndIf
					EndIf	
					
					//----- a partir daqui a NJJ est� posicionada no novo romaneio criado na origem ---
					cRomOri    := NJJ->NJJ_CODROM 
					
					//aprovar romaneio
					aAdd(aMsgHist, STR0090) /*Aprova��o autom�tica de romaneio.*/
					aAdd(aMsgHist, 'A') 
					A500Aprov(cRomOri, .F., aMsgHist, .T.)
					
					//gera produ��o
					//Verifica se Lan�a produ��o (flag no tipo de opera��o)
				   	if AGRX500LP(NJJ->NJJ_TOETAP)
					
						IF .NOT. Empty(NJJ->NJJ_CODPRO) .AND. .NOT. Empty(NJJ->NJJ_PSLIQU) .AND. .NOT. Empty(NJJ->NJJ_LOCAL)
							if .Not. lAlgodao
								if Empty(cNumOP)
									//-- Gera ordem de produ��o
									Processa({|| lRet := A500GERAOP(@cNumOP, NJJ->NJJ_CODPRO, NJJ->NJJ_PSLIQU, NJJ->NJJ_LOCAL, 3) }, STR0041 , STR0040 )	//"Gerando Ordem de Produ��o..."###"Aguarde"
								endIf
									
								//-- Realiza o apontamento da OP 
								If lRet
									Processa({|| lRet := A500APROD(cNumOP, NJJ->NJJ_CODROM, NJJ->NJJ_CODPRO, NJJ->NJJ_PSLIQU, NJJ->NJJ_LOCAL, 3) }, STR0039, STR0040 ) //"Movimentando Ordem de Produ��o..."###"Aguarde"
								EndIf
							endIf
						endIf
					endIf
					
					//Efetua a transfer�ncia entre filiais.
					If lRet
					   Processa({|| lRet := AGRX500TRE(NJJ->NJJ_PSLIQU,NJJ->NJJ_CODSAF,NJJ->NJJ_CODENT, NJJ->NJJ_LOJENT,NJJ->NJJ_CODPRO, NJJ->NJJ_TES, cLocalEnt, .T., cTesEnt, {{NJJ->NJJ_CODROM,01,cFilAnt}})}, STR0100, STR0040 ) //"Movimentando Ordem de Produ��o..."###"Aguarde"
					EndIf   
					
					//Efetiva transfer�ncia entre filiais
					If lRet
					   Processa({|| lRet := AGRX500EFT()}, STR0129, STR0040 ) //"Efetivando transfer�ncia..."###"Aguarde"
					   lEfet := lRet
					EndIf
					
					If lRet .AND. lAlgodao
						If !(Empty(NJJ->NJJ_PSLIQU))
							//Atualiza status dos fard�es vinculados e do rateia o peso liquido nos fard�es.
							lRet := AGRX500DXL(NJJ->NJJ_PSLIQU)
						EndIf
					EndIf

					
					//--RETORNA COM A FILIAL DE ORIGEM 
					//================================
					cFilAnt := cFilOri
					//================================
				endIf
			EndIf   
		else
		
			if lAlgodao
		    	lRet := AGRX500DXL(NJJ->NJJ_PSLIQU, .F., cNumOP) //Atualiza peso l�quido nos fard�es vinculados ao romaneio.
		    endIf
		    
			if lRet .AND. .NOT. Empty(NJJ->NJJ_QTDFIS) 							   
				if lAlgodao
					//gera pend�ncia de diferen�a entre peso fiscal e peso l�quido - algod�o 
					If NJJ->NJJ_PSLIQU <> NJJ->NJJ_QTDFIS
					   lRet := AGRX500PFA(NJJ->NJJ_CODROM, NJJ->NJJ_CODSAF, NJJ->NJJ_CODENT, NJJ->NJJ_LOJENT, NJJ->NJJ_PSLIQU, NJJ->NJJ_QTDFIS, NJJ->NJJ_TOETAP)
					EndIf   
				else
					//gera pend�ncia de diferen�a entre peso fiscal e peso l�quido - granel
					If NJJ->NJJ_PSLIQU <> NJJ->NJJ_QTDFIS
					   lRet := AGRX500PFG(NJJ->NJJ_CODROM, NJJ->NJJ_CODSAF, NJJ->NJJ_CODENT, NJJ->NJJ_LOJENT, NJJ->NJJ_PSLIQU, NJJ->NJJ_QTDFIS, NJJ->NJJ_TOETAP)
					EndIf   
					
					if lRet
						if .NOT. A500NFLRec(NJJ->NJJ_DOCNUM, NJJ->NJJ_DOCSER, NJJ->NJJ_CODENT, NJJ->NJJ_LOJENT)
																	
							//-- Lan�a NF no recebimento
							Processa({|| lRet := A500LancNF(NJJ->NJJ_CODROM, NJJ->NJJ_TIPO  , NJJ->NJJ_DOCNUM, ;
							                                NJJ->NJJ_DOCSER, NJJ->NJJ_CODENT, NJJ->NJJ_LOJENT, ;
							                                NJJ->NJJ_DOCEMI, NJJ->NJJ_DOCESP, NJJ->NJJ_CHVNFE, ;
							                                NJJ->NJJ_PLACA , NJJ->NJJ_CODTRA, NJJ->NJJ_TPFRET, ;
						                                	NJJ->NJJ_PSLIQU, NJJ->NJJ_PSSUBT ) }, STR0071 , STR0040 )	//"Gerando Nota Fiscal de Entrada..."###"Aguarde"
						endIF
					endIf
				endIf
			endIf
		endIf
	endIf
	
	If lRet
		//somente resolve pend�ncias se for romaneio de entrada gerado por uma sa�da
		if SUBSTRING(NJJ->NJJ_OBS,1,17) = "Filial de origem:"
			//soluciona pend�ncia de diferen�a entre peso fiscal e peso l�quido - algod�o
			If NJJ->NJJ_PSLIQU <> NJJ->NJJ_QTDFIS
				if !(EMPTY(N9C->N9C_ITEM))
					//Solu��o autom�tica de pend�ncias
					DbSelectArea('N92')
					N92->(DbSetOrder(1))
					
					if N92->(MsSeek(FWxFilial('N92')+NJJ->NJJ_TOETAP))
						If N92->N92_AUTPEN			
							// Fun��o AGRX500SPA esta no fonte AGRX500B
							lRet := AGRX500SPA(N9C->N9C_TPPEN)	
							If !(lRet)
								Help( ,, STR0048,, STR0128, 1, 0)	//"Ajuda" "N�o foi poss�vel ajustar automaticamente as pend�ncias."
							EndIf
						Else
							If N9C->N9C_QTDPEN < 0 //devolu��o
								cFil := N9C->N9C_FILORI //Filial origem da pend�ncia
							Else //complemento
								cFil := N9C->N9C_FILROM //Filial do romaneio de origem da transfer�ncia
							EndIf
							
							cDesPro := Posicione("SB1",1,FWxFilial("SB1")+NJJ->NJJ_CODPRO,"B1_DESC")
							
							MsgInfo(STR0139 + AllTrim(NJJ->NJJ_CODPRO) + " - " + AllTrim(cDesPro) + STR0140 + AllTrim(cFil) + ".") //"Foi gerada uma pend�ncia fiscal para o produto " //" na filial " 
						EndIf
					EndIF	
					N92->(dbCloseArea())
				EndIf
			EndIf
		EndIf			
	EndIf
	
	//inicializa variavel do tipo de movimento -- fun��o A500GrvMov()
	_cIdMV := ""	
		
Return lRet