#INCLUDE "PROTHEUS.CH"


STATIC lLegislacao := LjAnalisaLeg(43)[1] .AND. cPaisLoc == "BRA" .AND. AliasInDic("MDL")


/*/
|| IMPORTANTE: Toda altera��o efetuada neste fonte DEVE OBRIGATORIAMENTE ser feita tamb�m no fonte LJNFISCA.PRX
/*/

/*/{Protheus.doc} LJSCNFISCA
Verifica a existencia do RDMake padr�o LJNFISCA compilado no RPO, caso n�o exista envia para a LJRUNFISCA para realizar a impress�o.
@type		Function
@author		JMM
@since1		23/12/2020
@version	12.1.27
@return 
/*/
Function LJSCNFISCA(aPARAMIXB)

If ExistBlock("LJNFISCA")
	ExecBlock("LJNFISCA" ,.F.,.F., aPARAMIXB )
Else
    LJRUNFISCA(aPARAMIXB)
EndIf

return

/*/{Protheus.doc} LJRUNFISCA
Rotina para impressao de Nota Fiscal - Via rdMake
@type	Function
@author	Elaine F. T. Beraldo
@since	08/09/94
@return
/*/
Function LJRUNFISCA(aPARAMIXB)

LOCAL nTotImps    	:= 0		//Total de impostos
LOCAL nX			:= 0		//Contador de for
LOCAL aTesImpInf  	:= {}		//TES
Local aRegSF2		:= {}		//Registros do SF2
Local aRegSL1		:= {}		//Registros do SL1
Local nY			:= {}		//Contador de For
Local nL1ValISS		:= 0		//Total ValorIss
Local nL1ValIcm		:= 0		//Total valor ICM
Local aDadosTef	  	:= {}
Local cCliImpress   := "" 		// Codigo do Cliente que foi gravado no SF2
Local nTamCupom		:= TamSx3("F2_NFCUPOM")[1]   // Guarda o tamanho do Cupom Fiscal  
Local nTamSerie 	:= TamSx3("F2_SERIE")[1]     // Guarda o tamanho da Serie do Cupom Fiscal
Local nValMerc		:= 0  
Local nVlrTot 		:= 0 
Local nServicos		:= 0


//����������������������������Ŀ
//�Release 11.5 - Chile - F1CHI�
//������������������������������
If cPaisLoc == "CHI" .AND. GetRpoRelease("R5") .AND. SuperGetMv("MV_CTRLFOL",,.F.)
	U_LjNFisChi (aPARAMIXB[5][1],aPARAMIXB[5][2],aPARAMIXB[5][3])            
	Return NIL	
ElseIf cPaisLoc == "COL" .AND. GetRpoRelease("R5") .AND. SuperGetMv("MV_CTRLFOL",,.F.) 
	U_LjNFisCol (aPARAMIXB[5][1],aPARAMIXB[5][2],aPARAMIXB[5][3])
	MS_Flush()
	Return NIL	
EndIf

If Len(aPARAMIXB) >= 4
	aDadosTef := aPARAMIXB[4]
EndIf

li := 13

If !(lLegislacao)

	If Type("aParamIXB[3]")=="A" .And. Len(aParamIXB[3]) > 0
		For nX := 1 To Len(aParamIXB[3])
			DbSelectArea("SF2")					
			DbSetOrder(1)						
			DbGoTo(aParamIXB[3][nX])				// Posiciona no registro referente ao Cupom Fiscal 															
			Aadd(aRegSL1,{SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_PDV, ;
							SF2->F2_BASEICM, SF2->F2_VALICM, SF2->F2_BASEISS, SF2->F2_VALISS})			
			cCliImpress := SF2->F2_CLIENTE 		// Cliente referente a Nota
    	Next nX
	Endif

	For nY := 1 To Len(aRegSL1)

		DbSelectArea("SL1")
		DbSetOrder(2)

		If DbSeek(xFilial("SL1") + aRegSL1[nY][2] + aRegSL1[nY][1] + aRegSL1[nY][5])

			nL1ValISS += SL1->L1_VALISS
			nL1ValIcm += SL1->L1_VALICM

			If nY == 1
				li := 13
				nServicos := 0
			EndIf
		
			M->L1_NUM := SL1->L1_NUM
			
			//��������������������������������������������������������������Ŀ
			//� Posiciona no arquivo de Clientes							 �
			//����������������������������������������������������������������
			DbSelectArea( "SA1" )  	// Se encontrado no SF2, procura no SA1 pelo Cliente gravado SF2                                           //Cliente   //Loja
									// A busca no SF2 e feita por xFilial("SF2") + Substr(SF2->F2_NFCUPOM,4,9) + Substr(SF2->F2_NFCUPOM,1,3) + MV_PAR03 +  MV_PAR04 
									
			// Se nao encontrou no SF2 cCliImpress igual a vazio procura na tabela SL1
			If Empty(cCliImpress)
				SA1->( DbSeek( xFilial("SA1") + SL1->L1_CLIENTE + SL1->L1_LOJA ) )
			Else
				SA1->( DbSeek( xFilial("SA1") + cCliImpress + MV_PAR04) )
			Endif					                                                                        
											
			//��������������������������������������������������������������Ŀ
			//� Posiciona no arquivo de Vendedores 							 �
			//����������������������������������������������������������������
			dbSelectArea( "SA3" )
			dbSeek( xFilial("SA3")+SL1->L1_VEND )
			
			//��������������������������������������������������������������Ŀ
			//� Posiciona no arquivo de Itens							     �
			//����������������������������������������������������������������
			dbSelectArea( "SL2" )
			SL2->(dbSetOrder(3)) // Filia+Serie+Doc
			SL2->(dbSeek( xFilial("SL2")+SL1->L1_SERIE+SL1->L1_DOC ))
			cTes := SL2->L2_TES 
			
			While !SL2->(Eof()) .AND. SL2->L2_FILIAL+SL2->L2_SERIE+SL2->L2_DOC == xFilial("SL2")+SL1->L1_SERIE+SL1->L1_DOC
				
				If SL2->L2_VLGAPRO > 0 .AND. Empty(SL2->L2_GARANT) //Caso for garantia nao deve apresentar
					SL2->(dbSkip())	    
					Loop			
				EndIf
				If cPaisLoc == "BRA"
					nServicos := nServicos + SL2->L2_VALISS
				EndIf   
				@ Li,001 PSAY L2_QUANT	  Picture "999"
				@ Li,010 PSAY L2_PRODUTO
				dbSelectArea( "SB1" )
				dbSeek( xFilial("SB1")+SL2->L2_PRODUTO)
				dbSelectArea( "SL2")
				@Li,027 PSAY SB1->B1_DESC
				@li,079 PSAY SB1->B1_UM
				If cPaisLoc == "BRA"
					@li,084 PSAY SB1->B1_CLASFIS
					@li,087 PSAY SB1->B1_ORIGEM
				EndIf   
				@Li,099 PSAY L2_VRUNIT	picture "@E 99,999.99"
				@Li,120 PSAY L2_VLRITEM picture "@E 999,999.99"
				Li:=li+1
				If cPaisLoc <> "BRA"
				   //Soma os impostos variaveis que incidem na NF
					aTesImpInf  := TesImpInf(SL2->L2_TES)
					For nX  := 1 to Len(aTesImpInf)	   
						If aTesImpInf[nX][3] == "1"  //Incide na NF			   
							nTotImps  += SL2->(FieldGet(FieldPos("L2_"+Substr(aTesImpInf[nX][2],4,7))))	         
						EndIf   
					Next nX      
				EndIf   
				
				nValMerc  += SL2->L2_QUANT * SL2->L2_PRCTAB
				nVlrTot	  += SL2->L2_VLRITEM 
				
				SL2->(dbSkip())
			End
			
			dbSelectArea( "SF4" )
			dbSeek( xFilial("SF4"+cTes) )

		EndIf

	Next nY

	dbSelectArea("SL1")
	
	If cPaisLoc == "BRA"
	   @30,066 PSAY nServicos			 Picture "@E 99,999.99"
	Else
	   @30,066 PSAY nTotImps Picture PesqPict("SL2","L2_VALIMP1")
	EndIf   
	@30,096 PSAY nValMerc	 Picture "@E 9,999,999.99"
	@30,107 PSAY nVlrTot	 Picture "@E 9,999,999.99"
	
	dbSelectArea("SA1")
	
	@31,040 PSAY Trim(A1_NOME + " " + A1_COD)	
	@32,040 PSAY Trim(A1_END)+" - "+Trim(A1_BAIRRO) + " " + A1_CEP
	@33,040 PSAY Trim(A1_MUN)+ " " +A1_EST
	@35,040 PSAY SL1->L1_COND		 Picture "999"
	@35,100 PSAY Trim(SA3->A3_NREDUZ)
	
	@37, 07 PSAY DtoC(SL1->L1_EMISNF) + " " + SM0->M0_CGC
	@37,120 PSAY SM0->M0_ESTCOB
	
	li :=38

	For nY := 1 To Len(aRegSL1)

		@li+nY, 07 PSAY aRegSL1[nY][1]

		If cPaisLoc == "BRA"
	
			@li+nY, 50 PSAY aRegSL1[nY][6] 	 Picture "@E 9,999,999.99"	 
			@li+nY,100 PSAY aRegSL1[nY][7]	Picture "@E 9,999.99" 
			li += 1 	 	
			@li+nY, 50 PSAY aRegSL1[nY][8]	 Picture "@E 9,999,999.99"
			@li+nY, 87 PSAY SB1->B1_ALIQISS	 Picture "@E 9.9"
			@li+nY,100 PSAY aRegSL1[nY][9]	Picture "@E 9,999.99"
			li += 1
			@li+nY,99 PSAY "RODOVIARIO"			
	
		EndIf	
	
	Next nY

	li += 2

Else
                                     
	aRegSF2 := aParamIXB[3]
	
	For nX := 1 To Len(aRegSF2)
		DbSelectArea("SF2")
		DbGoTo(aRegSF2[nX])
		Aadd(aRegSL1,{SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_PDV})
    Next nX

	If Len(aRegSL1) > 0
		
		DbSelectArea("SL1")
		DbSetOrder(2)
	
		For nY := 1 To Len(aRegSL1)
	
			If DbSeek(xFilial("SL1") + aRegSL1[nY][2] + aRegSL1[nY][1] + aRegSL1[nY][5])
	
				nL1ValISS += SL1->L1_VALISS
				nL1ValIcm += SL1->L1_VALICM
	
				If nY == 1
					li := 13
					nServicos := 0
					nBaseIcms := 0
				EndIf
		
				M->L1_NUM := SL1->L1_NUM
				
				//��������������������������������������������������������������Ŀ
				//� Posiciona no arquivo de Clientes							 �
				//����������������������������������������������������������������
				dbSelectArea( "SA1" )
				dbSeek( xFilial("SA1")+SL1->L1_CLIENTE )
				
				//��������������������������������������������������������������Ŀ
				//� Posiciona no arquivo de Vendedores 							 �
				//����������������������������������������������������������������
				dbSelectArea( "SA3" )
				dbSeek( xFilial("SA3")+SL1->L1_VEND )
				
				//��������������������������������������������������������������Ŀ
				//� Posiciona no arquivo de Itens							     �
				//����������������������������������������������������������������
				dbSelectArea( "SL2" )
				SL2->(dbSetOrder(3)) // Filia+Serie+Doc
				SL2->(dbSeek( xFilial("SL2")+M->L1_SERIE+M->L1_DOC ))
				cTes := SL2->L2_TES 
	
				
				While !Eof() .and. L2_FILIAL+L2_SERIE+L2_DOC == xFilial("SL2")+SL1->L1_SERIE+SL1->L1_DOC
				    
				    If cPaisLoc == "BRA"
					   nServicos := nServicos + SL2->L2_VALISS
					EndIf   
					@ Li,001 PSAY L2_QUANT	  Picture "999"
					@ Li,010 PSAY L2_PRODUTO
					dbSelectArea( "SB1" )
					dbSeek( xFilial("SB1")+SL2->L2_PRODUTO)
					dbSelectArea( "SL2")
					@Li,027 PSAY SB1->B1_DESC
					@li,079 PSAY SB1->B1_UM
					If cPaisLoc == "BRA"
					   @li,084 PSAY SB1->B1_CLASFIS
					   @li,087 PSAY SB1->B1_ORIGEM
					EndIf   
					@Li,099 PSAY L2_VRUNIT	picture "@E 99,999.99"
					@Li,120 PSAY L2_VLRITEM picture "@E 999,999.99"
					Li:=li+1
					If cPaisLoc == "BRA"
					   nBaseIcms:=nBaseIcms+L2_BASEICM
					Else   //Soma os impostos variaveis que incidem na NF
					   aTesImpInf  := TesImpInf(SL2->L2_TES)
					   For nX  := 1 to Len(aTesImpInf)	   
					      If aTesImpInf[nX][3] == "1"  //Incide na NF			   
					         nTotImps  += SL2->(FieldGet(FieldPos("L2_"+Substr(aTesImpInf[nX][2],4,7))))	         
					      EndIf   
					   Next nX      
					EndIf   
					
					nValMerc  += SL2->L2_QUANT * SL2->L2_PRCTAB
					nVlrTot	  += SL2->L2_VLRITEM 
					
				SL2->(dbSkip())
				End
				
				dbSelectArea( "SF4" )
				dbSeek( xFilial("SF4"+cTes) )
				
			EndIf
			
			DbSelectArea("SL1")
			
		Next nY
			   
				
		dbSelectArea("SL1")
		
		If cPaisLoc == "BRA"
		   @30,066 PSAY nServicos			 Picture "@E 99,999.99"
		Else
		   @30,066 PSAY nTotImps Picture PesqPict("SL2","L2_VALIMP1")
		EndIf   
		@30,096 PSAY nValMerc	Picture "@E 9,999,999.99"
		@30,107 PSAY nVlrTot    Picture "@E 9,999,999.99"
		
		dbSelectArea("SA1")
		
		@31,040 PSAY Trim(A1_NOME + " " + A1_COD)
		@32,040 PSAY Trim(A1_END)+" - "+Trim(A1_BAIRRO) + " " + A1_CEP
		@33,040 PSAY Trim(A1_MUN)+ " " +A1_EST
		@35,040 PSAY SL1->L1_COND		 Picture "999"
		@35,100 PSAY Trim(SA3->A3_NREDUZ)
		
		@37, 07 PSAY DtoC(SL1->L1_EMISNF) + " " + SM0->M0_CGC
		@37,120 PSAY SM0->M0_ESTCOB
		
		@39, 07 PSAY SL1->L1_DOC
		If cPaisLoc == "BRA"
		   @39, 50 PSAY nBaseicms	 
		   @39,100 PSAY nL1ValIcm
		   @40, 50 PSAY nServicos	 Picture "@E 9,999,999.99"
		   @40, 87 PSAY SB1->B1_ALIQISS	 Picture "@E 9.9"
		   @40,100 PSAY nL1ValISS	Picture "@E 9,999.99"
		   @41,99 PSAY "RODOVIARIO"  
		EndIf   
		
		li := 42
		
	EndIf    
	
EndIf


//������������������������������������Ŀ
//�Imprime detalhes da operacao com TEF�
//��������������������������������������
For nX := 1 to Len(aDadosTef)

	
	
	//����������������������������������������������Ŀ
	//�Descricao de um elemento do array aDadosTEF   �
	//�[1] - Data da transacao TEF                   �
	//�[2] - Hora da transacao TEF                   �
	//�[3] - Numero do documento                     �
	//�[4] - Autorizacao                             �
	//�[5] - Instituicao                             �
	//�[6] - NSU do TEF                              �
	//�[7] - Tipo do cartao (Magnetico/Nao magnetico)�
	//������������������������������������������������
	
	If !Empty(aDadosTef[nX][1])

		//0        1         2         3         4         5         6         7         8         9        10        
		//1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
		//Data: 99/99/9999 Hora: 99:99:99 Doc.: 999999999 Aut.: 999999 Inst.: xxxxxxxxxxxxxxxx NSU: xxxxxxxxxxxx

		@li, 01 PSAY "Data: " + DtoC(aDadosTef[nX][1])
		@li, 18 PSAY "Hora: " + Transform(aDadosTef[nX][2],"@R 99:99:99")
		@li, 33 PSAY "Doc.: " + aDadosTef[nX][3]
		@li, 49 PSAY "Aut.: " + aDadosTef[nX][4]
		@li, 62 PSAY "Inst.: "+ aDadosTef[nX][5]
		@li, 86 PSAY "NSU.: " + aDadosTef[nX][6]		

		li++

	EndIf

Next nX

Ms_Flush()

Return

/*/{Protheus.doc} LjNFisChi
Rotina para impressao de FACTURA e BOLETA - Chile - R 11.5
@type	Function
@author	Vendas CRM
@since	25/05/11
@param	cDoc,	Caracter,	Numero do documento
		cSerie,	Caracter,	Serie do documento
		aItens, Array	,	Array com RECNO (SL2) dos itens do documento
@return
/*/

Function LjNFisChi(cDoc,cSerie,aItens)

Local nTotImps  := 0						//Total de impostos da nota
Local nImpItem  := 0						//Total de impostos do item de venda
Local nX,nY		:= 0	   					//Contador de for
Local aTesImpInf:= {}						//TES
Local cDataExt	:= ""						//Data por extendo
Local cEspecie	:= "1"      				//Especie
Local cGiro		:= ""       				//Giro
Local nLinha	:= 20       				//Numero da linha                    
Local nSubTotal	:= 0	   					//Sub-total
Local nAcrescimo:= 0        				//Total de acrescimos
Local nDesconto := 0 						//Total de Descontos - Itens de Venda
Local nDescFin	:= 0 						//Total de Descontos Financeiros - Condicao de Pagamento
Local nPerAcrFin:= 0						//Percentual de acrescimo financeiro
Local nPerDesFin:= 0						//Percentual de desconto financeiro
Local nMoedaCor	:= 1						//Moeda Corrente
Local nDecimais := MsDecimais(nMoedaCor)	//Decimais
Local lPrint40  := .F.						//Verifica no cadastro de estacao se imprime em 40 colunas

Default cDoc 	:= "" 						//Numero do documento
Default cSerie	:= ""						//Numero de serie
Default aItens	:= {}						//Itens da venda

If !(cPaisLoc == "CHI" .AND. GetRpoRelease("R5") .AND. Len(aItens) > 0)
	Return Nil
EndIf

// Se imprime em 40 colunas seta variavel como true
If (SLG->(FieldPos("LG_LARGCOL")) > 0 ) .AND. (LjGetStation("LG_LARGCOL") == 40)
	lPrint40 := .T.
EndIF

M->L1_NUM := SL1->L1_NUM

//��������������������������������������������������������������������������������������������������������������������������Ŀ
//�                                              CABECALHO                                                                   �
//����������������������������������������������������������������������������������������������������������������������������
@01,IIf(lPrint40,015,040) PSAY SM0->M0_CGC											//RUT ESTABELECIMENTO
@02,IIf(lPrint40,015,040) PSAY SM0->M0_ENDCOB										//ENDERECO ESTABELECIMENTO
@03,IIf(lPrint40,015,040) PSAY SM0->M0_BAIRCOB										//COMUNA/BARIO ESTABELECIMENTO
@04,IIf(lPrint40,015,040) PSAY Trim(SM0->M0_CIDCOB) + "," + Trim(SM0->M0_ESTCOB)	//CIDADE e REGIAO ESTABELECIMENTO

DbSelectArea("SL1")
@05,IIf(lPrint40,001,110) PSAY cDoc													//FACTURA/BOLETA

//���������������������������Ŀ
//� Controle de Formul�rios	  �
//�����������������������������  
DbSelectArea( "SFP" )                 
If DbSeek( xFilial("SFP")+SL1->L1_FILIAL+SL1->L1_SERIE)
	cEspecie:= SFP->FP_ESPECIE
	@06,IIf(lPrint40,001,110) PSAY Rtrim(SFP->FP_CAI)						   		//NUMERO DA RESOLUCION
	@07,IIf(lPrint40,001,110) PSAY AllTrim(SFP->FP_DTAVAL)		   					//DATA DA RESOLUCION			
EndIf

cDataExt := Trim(SM0->M0_CIDCOB) + "," + Transform(Day(dDataBase),'99') + " de " + MesExtenso(dDataBase) + " de " + Transform(Year(dDataBase),'9999') 
@08,IIf(lPrint40,001,005) PSAY cDataExt												//DATA POR EXTENSO

//���������Ŀ
//�Cliente  �
//�����������
DbSelectArea( "SA1" )
DbSeek( xFilial("SA1")+SL1->L1_CLIENTE )

@10,IIf(lPrint40,001,010) PSAY A1_NOME            									//SENOR(ES)
@11,IIf(lPrint40,025,110) PSAY Trim(A1_CGC) PICTURE PesqPict("SA1","A1_CGC")     	//RUT
@12,IIf(lPrint40,001,010) PSAY Trim(A1_END) 										//DIRECION
@13,IIf(lPrint40,001,010) PSAY Trim(A1_BAIRRO) 								    //COMUNA
@13,IIf(lPrint40,025,050) PSAY Trim(A1_MUN) 		   								//CIUDAD
@13,IIf(lPrint40,001,010) PSAY A1_TEL  	PICTURE PesqPict("SA1","A1_TEL")	   		//TELEFONO 


//����������������������Ŀ
//� Segmentos do Mercado �
//������������������������
cGiro:= Posicione("SX5",1,xFilial("SX5")+"T3"+SA1->A1_SATIV1,"X5_DESCRI")

@14,IIf(lPrint40,001,010) PSAY cGiro	 												//GIRO

//������������������������Ŀ
//� Condicao de pagamento  �
//��������������������������
DbSelectArea( "SE4" )
If DbSeek( xFilial("SE4")+SL1->L1_CONDPG )
	nPerAcrFin := SE4->E4_ACRSFIN 
	nPerDesFin := SE4->E4_DESCFIN
	@15,IIf(lPrint40,001,010) PSAY Rtrim(SE4->E4_DESCRI) 							//CONDICION VENTA
EndIf

//��������������������������������������������������������������Ŀ                                                            
//� ITENS                                                        �
//� Posiciona no arquivo de Itens de acordo com a quebra de nota �
//����������������������������������������������������������������
DbSelectArea( "SL2" )
For nY:= 1 To Len(aItens) 	
	
	SL2->(DbGoto(aItens[nY]))
    
	//��������Ŀ
	//�PRODUCTO�
	//���������� 
	
	// Impressora 40 colunas
	If lPrint40
		@ nLinha,001 PSAY L2_QUANT	  Picture "999" 		   	   		  				//CANTIDAD
		
		@ nLinha,009 PSAY Left(L2_PRODUTO, 16)					  		  				//CODIGO
		
		DbSelectArea( "SB1" )                                       
		DbSeek( xFilial("SB1")+SL2->L2_PRODUTO)						
		DbSelectArea( "SL2")
		
		@nLinha,025 PSAY Left(Rtrim(SB1->B1_DESC),15)         		   	 				//DESCRICAO
		
		@nLinha,039 PSAY Trim(SB1->B1_UM)                          						//UNIDADE
		
		// Os valores serao impressos em outra linha
		nLinha++
		
		@nLinha,001 PSAY SL2->L2_VRUNIT ;
				PICTURE PesqPict("SL2","L2_VRUNIT",,nMoedaCor)							//VALOR UNITARIO
				
		@nLinha,020 PSAY SL2->L2_VLRITEM ;
				PICTURE PesqPict("SL2","L2_VLRITEM",,nMoedaCor)							//VALOR TOTAL        
			
    Else
    	// Impressora comum   
    			
		@ nLinha,004 PSAY L2_QUANT	  Picture "999" 		   	   						//CANTIDAD
		
		@ nLinha,014 PSAY L2_PRODUTO   							   						//CODIGO
		
		DbSelectArea( "SB1" )                                       
		DbSeek( xFilial("SB1")+SL2->L2_PRODUTO)						
		DbSelectArea( "SL2")
		
		@nLinha,022 PSAY Rtrim(SB1->B1_DESC)                	 						//DESCRICAO
		
		@nLinha,090 PSAY Trim(SB1->B1_UM)                        					  	//UNIDADE
		
		@nLinha,092 PSAY SL2->L2_VRUNIT	 ;
				PICTURE PesqPict("SL2","L2_VRUNIT",,nMoedaCor)	   						//VALOR UNITARIO
				
		@nLinha,110 PSAY SL2->L2_VLRITEM ;
				PICTURE PesqPict("SL2","L2_VLRITEM",,nMoedaCor)	  						//VALOR TOTAL    
				
	EndIf			     
	
	// Inclementa para nova linha
	nLinha++
	
	//��������������������Ŀ
	//�Controle de impostos�
	//����������������������
	aTesImpInf  := TesImpInf(SL2->L2_TES)
   	For nX  := 1 to Len(aTesImpInf)	   
    	If aTesImpInf[nX][3] == "1"  //Incide na NF			   
     		nTotImps  += SL2->(FieldGet(FieldPos("L2_"+Substr(aTesImpInf[nX][2],4,7))))
     		nImpItem  += SL2->(FieldGet(FieldPos("L2_"+Substr(aTesImpInf[nX][2],4,7))))         
      	EndIf   
   	Next nX     
	
	//��������������������Ŀ
	//�Controle de Desconto�
	//����������������������
	nDesconto += SL2->L2_VALDESC + SL2->L2_DESCPRO
	
	If nPerDesFin > 0
		nDescFin += Round(((SL2->L2_VLRITEM + nImpItem) * nPerDesFin)/100,nDecimais)
	EndIf
	
		
	//���������������������Ŀ
	//�Controle de Acrescimo�
	//����������������������� 
   
	If nPerAcrFin > 0
   		nAcrescimo += Round(((SL2->L2_VLRITEM + nImpItem) * nPerAcrFin)/100,nDecimais)
 	Else
		nAcrescimo += Round(((SL2->L2_VLRITEM + nImpItem )* SL1->L1_JUROS)/100,nDecimais) 	
	EndIf 
	
	//���������������������Ŀ
	//�Controle de Sub-Total�
	//�����������������������
    nSubTotal += SL2->L2_VLRITEM   

	//Zerar impostos do item
	nImpItem := 0
   	
Next nY

//����������������������Ŀ
//�Acrescimos / Descontos�
//������������������������ 
If lPrint40     
	nLinha := nLinha + 2  	// Pula 2 linhas
		
	@nLinha,001 PSAY "Acrescimos :" 
	@nLinha,013 PSAY nAcrescimo Picture PesqPict("SL1","L1_VALMERC",,nMoedaCor) 
	
	nLinha++
	
	@nLinha,001 PSAY "Descuentos :" 
	@nLinha,013 PSAY (nDesconto + nDescFin) Picture PesqPict("SL1","L1_VALMERC",,nMoedaCor) 
Else
	@68,022 PSAY "Acrescimos :" 
	@68,035 PSAY nAcrescimo Picture PesqPict("SL1","L1_VALMERC",,nMoedaCor) 
	
	@69,022 PSAY "Descuentos :" 
	@69,035 PSAY (nDesconto + nDescFin) Picture PesqPict("SL1","L1_VALMERC",,nMoedaCor) 
EndIf

//����������Ŀ
//� Vendedor �
//������������
DbSelectArea( "SA3" )
DbSeek( xFilial("SA3")+SL1->L1_VEND) 

If lPrint40     
	nLinha := nLinha + 2  	// Pula 2 linhas

	@nLinha++,001 PSAY "Atencion de :" + SA3->A3_NOME
	@nLinha,001 PSAY "Caja :" + SL1->L1_OPERADO
Else
	@72,022 PSAY "Atencion de :" + SA3->A3_NOME
	@73,022 PSAY "Caja :" + SL1->L1_OPERADO
EndIf                                                              

//�����������������������������������������������������������������������������������������Ŀ
//�                                              RODAPE                                     �
//�������������������������������������������������������������������������������������������

If lPrint40     
	nLinha := nLinha + 2  	// Pula 2 linhas
	
	@nLinha++,001 PSAY nSubTotal ;
			Picture PesqPict("SL1","L1_VALMERC",,nMoedaCor)			//SUB-TOTAL  
			
	@nLinha++,001 PSAY nTotImps  ;
			Picture PesqPict("SL1","L1_VALMERC",,nMoedaCor)			//TOTAL IVA  
			
	@nLinha,001 PSAY nSubTotal + nTotImps  + nAcrescimo - nDescFin ;	 	
			Picture PesqPict("SL1","L1_VALMERC",,nMoedaCor)			//TOTAL   			
	
Else
	@76,105 PSAY nSubTotal ;
			Picture PesqPict("SL1","L1_VALMERC",,nMoedaCor)			//SUB-TOTAL  
			
	@77,105 PSAY nTotImps  ;
			Picture PesqPict("SL1","L1_VALMERC",,nMoedaCor)			//TOTAL IVA  
			
	@78,105 PSAY nSubTotal + nTotImps  + nAcrescimo - nDescFin ;	 	
			Picture PesqPict("SL1","L1_VALMERC",,nMoedaCor)			//TOTAL 	
EndIf
		
//�����������������������������������������������Ŀ
//�Impressao exclusiva para Boleta e Boleta Exenta�
//�������������������������������������������������  
If cEspecie $ "3|4" 

	If lPrint40     
		nLinha := nLinha + 2  	// Pula 2 linhas
		@nLinha,001 PSAY "BOLETA DE VENTA AUTORIZADA POR EL SII" 
	Else
   		@083,040 PSAY "BOLETA DE VENTA AUTORIZADA POR EL SII" 
	EndIf
	
EndIf

Ms_Flush()

Return()

/*/{Protheus.doc} LjNFisCol
Rotina para impressao de FACTURA  - Colombia - R 11.5  
@type	Function
@author	Jo�o Paulo T Silva
@since	12/04/11
@param	cDoc,	Caracter,	Numero do documento
		cSerie,	Caracter,	Serie do documento
		aItens, Array	,	Array com RECNO (SL2) dos itens do documento
@return
/*/
Function LjNFisCol(cDoc,cSerie,aItens)

Local nTotImps  := 0						//Total de impostos da nota
Local nImpItem  := 0						//Total de impostos do item de venda
Local nX		:= 0						//Contador de for
local nY		:= 0	   					//Contador de for
Local aTesImpInf:= {}						//TES
Local cDataExt	:= ""						//Data por extendo
Local cEspecie	:= "1"      				//Especie
Local cGiro		:= ""       				//Giro
Local nLinha	:= 20       				//Numero da linha                    
Local nSubTotal	:= 0	   					//Sub-total
Local nAcrescimo:= 0        				//Total de acrescimos
Local nDesconto := 0 						//Total de Descontos - Itens de Venda
Local nDescFin	:= 0 						//Total de Descontos Financeiros - Condicao de Pagamento
Local nPerAcrFin:= 0						//Percentual de acrescimo financeiro
Local nPerDesFin:= 0						//Percentual de desconto financeiro
Local nMoedaCor	:= 1						//Moeda Corrente
Local nDecimais := MsDecimais(nMoedaCor)	//Decimais
Local cPagto    := ""                
Local lPrint40  := .F.						//Verifica no cadastro de estacao se imprime em 40 colunas        
Local cIndImp	:= ""                      	//Indicador do Indice do imposto
Local nExento	:= 0                        //Total Exento
Local nGravado	:= 0                        //Total Gravado
Local nExcluido	:= 0                        //Total Excluido
Local aAliqImp	:= {}					    //Array de Aliquotas de Imposto
Local nPosAliq  := 0                       	//Posicao da aliquota

Default cDoc 	:= "" 						//Numero do documento
Default cSerie	:= ""						//Numero de serie
Default aItens	:= {}						//Itens da venda

If !(cPaisLoc == "COL" .AND. GetRpoRelease("R5") .AND. Len(aItens) > 0 )
	Return Nil
EndIf	

// Se imprime em 40 colunas seta variavel como true
If (SLG->(FieldPos("LG_LARGCOL")) > 0 ) .AND. (LjGetStation("LG_LARGCOL") == 40)
	lPrint40 := .T.
EndIF

M->L1_NUM := SL1->L1_NUM

//��������������������������������������������������������������������������������������������������������������������������Ŀ
//�                                              CABECALHO                                                                   �
//����������������������������������������������������������������������������������������������������������������������������
@01,IIf(lPrint40,015,040) PSAY AlLTrim(SM0->M0_NOMECOM)								//NOME ESTABELECIMENTO
@02,IIf(lPrint40,015,040) PSAY SM0->M0_CGC											//RUT ESTABELECIMENTO
@03,IIf(lPrint40,015,040) PSAY SM0->M0_ENDCOB										//ENDERECO ESTABELECIMENTO
@04,IIf(lPrint40,015,040) PSAY SM0->M0_BAIRCOB										//COMUNA/BARIO ESTABELECIMENTO
@05,IIf(lPrint40,015,040) PSAY Trim(SM0->M0_CIDCOB) + "," + Trim(SM0->M0_ESTCOB)	//CIDADE e REGIAO ESTABELECIMENTO

DbSelectArea("SL1")
@06,IIf(lPrint40,001,040) PSAY "Factura de venta No: " + cDoc						//FACTURA/BOLETA

//���������������������������Ŀ
//� Controle de Formularios	  �
//�����������������������������  
DbSelectArea( "SFP" )                 
If DbSeek( xFilial("SFP")+SL1->L1_FILIAL+SL1->L1_SERIE)
	cEspecie:= SFP->FP_ESPECIE
	@07,IIf(lPrint40,001,040) PSAY "Resolucon DIAN " + Rtrim(SFP->FP_CAI) + " " + 	DtoC(SFP->FP_DTAINI)		// NUMERO DA RESOLUCION + DATA DA RESOLUCION
	@08,IIf(lPrint40,001,040) PSAY "Rango " + AllTrim(SFP->FP_NUMINI) + "-" + AllTrim(SFP->FP_NUMFIM) 	// INTERVALO DE CTRL DE FORM.			
EndIf	
 
//���������������������������Ŀ
//� Regime Fiscal			  �
//����������������������������� 
@09,IIf(lPrint40,001,040) PSAY "IVA REG. COMUM"						    		// REG. COMUM"
@10,IIf(lPrint40,001,040) PSAY "NO SOMOS AUTORETENEDORES ENTIDAD SIN"         	// AUTORETENEDORES
@11,IIf(lPrint40,001,040) PSAY "ANIMO SE LUCRO"

cDataExt := Trim(SM0->M0_CIDCOB) + "," + Transform(Day(dDataBase),'99') + " de " + MesExtenso(dDataBase) + " de " + Transform(Year(dDataBase),'9999') 
@12,IIf(lPrint40,001,005) PSAY cDataExt												//DATA POR EXTENSO

//���������Ŀ
//�Cliente  �
//�����������
DbSelectArea( "SA1" )
DbSeek( xFilial("SA1")+SL1->L1_CLIENTE )

@13,IIf(lPrint40,001,010) PSAY A1_NOME            									//SENOR(ES)
@14,IIf(lPrint40,025,010) PSAY Trim(A1_CGC) PICTURE PesqPict("SA1","A1_CGC")     	//RUT
@15,IIf(lPrint40,001,010) PSAY Trim(A1_END) 										//DIRECION
@16,IIf(lPrint40,001,010) PSAY Trim(A1_BAIRRO) 								    //COMUNA
@16,IIf(lPrint40,025,050) PSAY Trim(A1_MUN) 		   								//CIUDAD
@16,IIf(lPrint40,001,010) PSAY A1_TEL  	PICTURE PesqPict("SA1","A1_TEL")	   		//TELEFONO 

//����������������������Ŀ
//� Segmentos do Mercado �
//������������������������
cGiro:= Posicione("SX5",1,xFilial("SX5")+"T3"+SA1->A1_SATIV1,"X5_DESCRI")

@17,IIf(lPrint40,001,010) PSAY cGiro	 												//GIRO

//������������������������Ŀ
//� Condicao de pagamento  �
//��������������������������
DbSelectArea( "SE4" )
If DbSeek( xFilial("SE4")+SL1->L1_CONDPG )
	nPerAcrFin := SE4->E4_ACRSFIN 
	nPerDesFin := SE4->E4_DESCFIN
	@18,IIf(lPrint40,001,010) PSAY Rtrim(SE4->E4_DESCRI) 							//CONDICION VENTA
EndIf

//��������������������������������������������������������������Ŀ                                                            
//� ITENS                                                        �
//� Posiciona no arquivo de Itens de acordo com a quebra de nota �
//����������������������������������������������������������������
DbSelectArea( "SL2" )
For nY:= 1 To Len(aItens) 	
	
	SL2->(DbGoto(aItens[nY]))
        
    //��������������������Ŀ
	//�Controle de impostos�
	//����������������������
	aTesImpInf  := TesImpInf(SL2->L2_TES) 
	If	Len(aTesImpInf) > 0
	   	For nX  := 1 to Len(aTesImpInf)	   
	    	If aTesImpInf[nX][3] == "1"  //Incide na NF	           
	    	
	    		cIndImp := Substr("L2_"+Substr(aTesImpInf[nX][2],4,7),Len("L2_"+Substr(aTesImpInf[nX][2],4,7)),1)		   
	    		
	     		nTotImps  += SL2->(FieldGet(FieldPos("L2_"+Substr(aTesImpInf[nX][2],4,7))))
	     		nImpItem  += SL2->(FieldGet(FieldPos("L2_"+Substr(aTesImpInf[nX][2],4,7))))         
	
				//�������������������������������Ŀ
				//�Saber se tem valores "Gravados"�
				//���������������������������������
			   	If SL2->&("L2_BASIMP"+cIndImp) > 0 .AND. SL2->&("L2_VALIMP"+cIndImp) > 0
			   		nGravado += SL2->L2_VLRITEM
			  	EndIf
	
				//������Ŀ
				//�Exento�
				//��������
			   	If !SL2->&("L2_BASIMP"+cIndImp) > 0 .AND. !SL2->&("L2_VALIMP"+cIndImp) > 0
					nExento += SL2->L2_VLRITEM
			  	EndIf	
	             
				//����������������������������������Ŀ
				//�Grava array separado por aliquota �
				//������������������������������������
				For nX := 1 To 6													 
					nPosAliq := aScan( aAliqImp, { |x| x[1] == AllTrim(STR(SL2->&("L2_ALQIMP"+AllTrim(STR(nX))))) } )  
					If nPosAliq > 0
						aAliqImp[nPosAliq][2] += ( SL2->&("L2_BASIMP"+AllTrim(STR(nX))) + SL2->&("L2_VALIMP"+AllTrim(STR(nX))) )
						aAliqImp[nPosAliq][3] += SL2->&("L2_VALIMP"+AllTrim(STR(nX)))								
					ElseIf SL2->&("L2_ALQIMP"+AllTrim(STR(nX))) > 0
						aAdd( aAliqImp,{ AllTrim(STR(SL2->&("L2_ALQIMP"+AllTrim(STR(nX))))) , ( SL2->&("L2_BASIMP"+AllTrim(STR(nX))) + SL2->&("L2_VALIMP"+AllTrim(STR(nX))) ), SL2->&("L2_VALIMP"+AllTrim(STR(nX))) } )
					EndIf
				Next nX
	
	      	EndIf   
	   	Next nX 
	Else
		//��������Ŀ
		//�Excluido�
		//����������
	 	If !SL2->&("L2_BASIMP"+cIndImp) > 0 .AND. !SL2->&("L2_VALIMP"+cIndImp) > 0
			nExcluido += SL2->L2_VLRITEM
	  	EndIf	
	EndIf  
    
	//��������Ŀ
	//�PRODUCTO�
	//���������� 
	
	// Impressora 40 colunas
	If lPrint40
		@ nLinha,001 PSAY L2_QUANT	  Picture "999" 		   	   		  				//CANTIDAD
		
		@ nLinha,009 PSAY Left(L2_PRODUTO, 16)					  		  				//CODIGO
		
		DbSelectArea( "SB1" )                                       
		DbSeek( xFilial("SB1")+SL2->L2_PRODUTO)						
		DbSelectArea( "SL2")
		
		@nLinha,025 PSAY Left(Rtrim(SB1->B1_DESC),15)         		   	 				//DESCRICAO
		
		@nLinha,039 PSAY Trim(SB1->B1_UM)                          						//UNIDADE
		
		// Os valores serao impressos em outra linha
		nLinha++
			
		@nLinha,001 PSAY SL2->L2_VRUNIT ; 
			  	PICTURE "@E 99,999,999.99"												//VALOR UNITARIO
				
		@nLinha,020 PSAY SL2->L2_VLRITEM + SL2->&("L2_VALIMP"+cIndImp) ;
				PICTURE "@E 99,999,999.99"												//VALOR TOTAL COM IMPOSTO     				
	
    Else
    	// Impressora comum   
    			
		@ nLinha,004 PSAY L2_QUANT	  Picture "999" 		   	   						//CANTIDAD
		
		@ nLinha,014 PSAY L2_PRODUTO   							   						//CODIGO
		
		DbSelectArea( "SB1" )                                       
		DbSeek( xFilial("SB1")+SL2->L2_PRODUTO)						
		DbSelectArea( "SL2")
		
		@nLinha,022 PSAY Rtrim(SB1->B1_DESC)                	 						//DESCRICAO
		
		@nLinha,090 PSAY Trim(SB1->B1_UM)                        					  	//UNIDADE
		
		@nLinha,092 PSAY SL2->L2_VRUNIT	 ;
				PICTURE PesqPict("SL2","L2_VRUNIT",,nMoedaCor)	   						//VALOR UNITARIO
				
		@nLinha,110 PSAY SL2->L2_VLRITEM + SL2->&("L2_VALIMP"+cIndImp) ;
				PICTURE PesqPict("SL2","L2_VLRITEM",,nMoedaCor)	  						//VALOR TOTAL    
				
	EndIf			     
	
	// Inclementa para nova linha
	nLinha++
	
	//��������������������Ŀ
	//�Controle de Desconto�
	//����������������������
	nDesconto += SL2->L2_VALDESC + SL2->L2_DESCPRO
	
	If nPerDesFin > 0
		nDescFin += Round(((SL2->L2_VLRITEM + nImpItem) * nPerDesFin)/100,nDecimais)
	EndIf	
		
	//���������������������Ŀ
	//�Controle de Acrescimo�
	//����������������������� 
   
	If nPerAcrFin > 0
   		nAcrescimo += Round(((SL2->L2_VLRITEM + nImpItem) * nPerAcrFin)/100,nDecimais)
 	Else
		nAcrescimo += Round(((SL2->L2_VLRITEM + nImpItem )* SL1->L1_JUROS)/100,nDecimais) 	
	EndIf 
	
	//���������������������Ŀ
	//�Controle de Sub-Total�
	//�����������������������
    nSubTotal += SL2->L2_VLRITEM   

	//Zerar impostos do item
	nImpItem := 0
   	
Next nY      

//��������������������������������������������������Ŀ
//�Posiciona na tabela SL4 para gravar forma de pagto�
//����������������������������������������������������
DbSelectArea( "SL4" )
DbSetOrder(1) // Filial + Numero + Origem
If dbSeek(xFilial("SL4")+SL1->L1_NUM)
	cPagto:= Posicione("SX5",1,xFilial("SX5")+"24"+SL4->L4_FORMA,"X5_DESCRI")
EndIf

//���������������������������������������Ŀ
//�Acrescimos / Descontos / Forma de Pagto�
//�����������������������������������������  

//����������������������Ŀ
//�Forma de Pagto		 �
//������������������������ 
If lPrint40     
	nLinha := nLinha + 2  	// Pula 2 linhas
	@nLinha++,001 PSAY "Forma de Pagamento :" 
	@nLinha,013 PSAY cPagto
Else
	@67,022 PSAY "Forma de Pagamento :" 
	@67,045 PSAY cPagto
EndIf	

//����������������������Ŀ
//�Acrescimos / Descontos�
//������������������������ 
If lPrint40     
	nLinha := nLinha + 2  	// Pula 2 linhas
		
	@nLinha,001 PSAY "Acrescimos :" 
	@nLinha,013 PSAY nAcrescimo Picture PesqPict("SL1","L1_VALMERC",,nMoedaCor) 
	
	nLinha++
	
	@nLinha,001 PSAY "Descuentos :" 
	@nLinha,013 PSAY (nDesconto + nDescFin) Picture PesqPict("SL1","L1_VALMERC",,nMoedaCor) 
Else
	@68,022 PSAY "Acrescimos :" 
	@68,035 PSAY nAcrescimo Picture PesqPict("SL1","L1_VALMERC",,nMoedaCor) 
	
	@69,022 PSAY "Descuentos :" 
	@69,035 PSAY (nDesconto + nDescFin) Picture PesqPict("SL1","L1_VALMERC",,nMoedaCor) 
EndIf

//����������Ŀ
//� Vendedor �
//������������
DbSelectArea( "SA3" )
DbSeek( xFilial("SA3")+SL1->L1_VEND) 

If lPrint40     
	nLinha := nLinha + 2  	// Pula 2 linhas

	@nLinha++,001 PSAY "Atencion de :" + SA3->A3_NOME
	@nLinha,001 PSAY "Caja :" + SL1->L1_OPERADO
Else
	@72,022 PSAY "Atencion de :" + SA3->A3_NOME
	@73,022 PSAY "Caja :" + SL1->L1_OPERADO
EndIf                                                              

//�����������������������������������������������������������������������������������������Ŀ
//�                                              RODAPE                                     �
//�������������������������������������������������������������������������������������������

If lPrint40     
	nLinha := nLinha + 1  	// Pula 2 linhas
	
	nLinha++	
	@nLinha,001 PSAY  "Gravadas: "	
	@nLinha,015 PSAY  nGravado ;
			Picture PesqPict("SL1","L1_VLRTOT",,nMoedaCor)			//TOTAL GRAVADO 
	
	nLinha++	
	@nLinha,001 PSAY  "Iva: "		
	@nLinha,015 PSAY nTotImps  ;
			Picture PesqPict("SL1","L1_VLRTOT",,nMoedaCor)			//TOTAL IVA  
	
	nLinha++	
	@nLinha,001 PSAY  "Exentos: "		                           
	@nLinha,015 PSAY  nExento  ;
			Picture PesqPict("SL1","L1_VLRTOT",,nMoedaCor)			//TOTAL EXENTO 
			  
	nLinha++	
	@nLinha,001 PSAY  "Excluidos: "		
	@nLinha,015 PSAY  nExcluido ;
			Picture PesqPict("SL1","L1_VLRTOT",,nMoedaCor)			//TOTAL EXCLUIDO  
				
	nLinha++	
	@nLinha,001 PSAY  "Sub-Total: "			                                                   
	@nLinha,015 PSAY nSubTotal ;
			Picture PesqPict("SL1","L1_VLRTOT",,nMoedaCor)			//SUB-TOTAL 
			
	nLinha++	
	@nLinha,001 PSAY  "Total: "	
	@nLinha,015 PSAY nSubTotal + nTotImps  + nAcrescimo - nDescFin ;	 	
			Picture PesqPict("SL1","L1_VLRTOT",,nMoedaCor)			//TOTAL 

Else
			
	@75,001 PSAY  "Gravadas: "	
	@75,015 PSAY  nGravado ;
			Picture PesqPict("SL1","L1_VLRTOT",,nMoedaCor)			//TOTAL GRAVADO 
	
	@76,001 PSAY  "Iva: "		
	@76,015 PSAY nTotImps  ;
			Picture PesqPict("SL1","L1_VLRTOT",,nMoedaCor)			//TOTAL IVA  
	
	@77,001 PSAY  "Exentos: "		                           
	@77,015 PSAY  nExento  ;
			Picture PesqPict("SL1","L1_VLRTOT",,nMoedaCor)			//TOTAL EXENTO   

	@78,001 PSAY  "Excluidos: "		
	@78,015 PSAY  nExcluido ;
			Picture PesqPict("SL1","L1_VLRTOT",,nMoedaCor)			//TOTAL EXCLUIDO  	
	
	@79,001 PSAY  "Sub-Total: "			                                                   
	@79,015 PSAY nSubTotal ;
			Picture PesqPict("SL1","L1_VLRTOT",,nMoedaCor)			//SUB-TOTAL 

	@80,001 PSAY  "Total: "	
	@80,015 PSAY nSubTotal + nTotImps  + nAcrescimo - nDescFin ;	 	
			Picture PesqPict("SL1","L1_VLRTOT",,nMoedaCor)			//TOTAL  
	
EndIf

//����������������������Ŀ
//�Total Impostos		 �
//������������������������                                                                  
If Len(aAliqImp) > 0
	nLinha += 1	
	@nLinha,001 PSAY  "DISCRIMINACION IVA "	
	nLinha++
	@nLinha,001 PSAY  "% IVA          VENTAS         VALOR IVA"
	
	For nX := 1 To Len(aAliqImp)
		nLinha++		
		@nLinha,001 PSAY aAliqImp[nX][1] 	 	    // % IVA
		@nLinha,011 PSAY aAliqImp[nX][2] ;	 	
				Picture "@E 99,999,999.99"			// VENTAS
		@nLinha,026 PSAY aAliqImp[nX][3] ;	 	
				Picture "@E 99,999,999.99"			// VALOR IVA
    Next nX 
EndIf  

@00,00 psay "."

Return
