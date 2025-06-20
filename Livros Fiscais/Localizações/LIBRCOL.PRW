#Include "Protheus.Ch"
#Include "LIBRCOL.Ch"  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �LIBRCOL   � Autor �TOTVS                  � Data � 06.05.11 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Relat�rio de Livro Fiscal de Venda                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Colombia                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function LIBRCOL()

Local cTitulo	:= OemToAnsi(STR0001)	//"Relat�rio de Livro Fiscal de Venda"
Local cDescr1	:= OemToAnsi(STR0002)	//"Este programa tem como objetivo imprimir o relatorio de Livro Fiscal de Venda"
Local cPerg	 	:= "LIBRCOL"			//"Grupo de Perguntas"
Local cNomeProg	:= "LIBRCOL" 			//"Nome do Progaram"
Local cString	:= "SL1"				//"Alias utilizado para filtro"
Local cTamanho  := "M"					//"Tamanho considerado no relat�rio"
Local lEnd	:= .F.						//"Verifica cancelamento do relat�rio"
Local wnRel	:= ""						

Private aReturn	:= {STR0004, 1, STR0005, 2, 2, 1, "", 1} 	//"Zebrado"###"Administracao" 
Private m_pag	:= 0                   						//N�mer de paginas
Private nLastKey:= 0				   						// Ultima tecla acionada. 



	//�������������������������������������������������������Ŀ
	//�Ajusta o Grupo de Perguntas                            �
	//���������������������������������������������������������
	//AjustaSx1(cPerg) // Perguntas adicionadas no AtuSx.
	wnRel := "LIBRCOL"
	//��������������������������������������������������������������Ŀ
	//� Verifica as perguntas selecionadas 							 �
	//����������������������������������������������������������������
	Pergunte("LIBRCOL",.F.)
	//��������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros						 �
	//� mv_par01				 // Data De    						 �
	//� mv_par02				 // Data Ate   						 �
	//� mv_par03				 // Ponto De				  	     �
	//� mv_par04				 // Ponto Ate						 �
	//����������������������������������������������������������������
	
	//��������������������������������������������������������������Ŀ
	//� Envia controle para a funcao SETPRINT 				   	     �
	//����������������������������������������������������������������
	wnrel:=SetPrint(cString,wnrel,cPerg,@cTitulo,cDescr1,,,.F.,"")
	
	If  nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)         
	
	If nLastKey == 27
		Return
	Endif	
	

	
	//��������������������������������������������������������Ŀ
	//� RPTSTATUS monta janela com a regua de processamento    �
	//����������������������������������������������������������
	RptStatus({|lEnd| LIBRPrint(@lEnd,wnRel,cString,cTitulo,cNomeProg,cTamanho)},cTitulo)
	


Return Nil

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �LIBRPRINT  � Autor �Sergio S. Fuzinaka     � Data � 25.06.07 ���
��������������������������������������������������������������������������Ĵ��
���Descricao �Rotina de Impressao do Livro de Compras IVA                  ���
���          �                                                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function LIBRPrint(lEnd,wnRel,cString,cTitulo,cNomeProg,cTamanho)

Local cFiltro	:= ""							    // Filtro que ser� utilizado quando a op��o n�o for TOPConnect 
Local dDtIni	:= mv_par01							// Par�metro utilizado para filtro do Alias  - Data de Emiss�o De
Local dDtFim	:= mv_par02							// Par�metro utilizado para filtro do Alias  - Data de Emiss�o Ate
Local cPontoDe	:= mv_par03							// Par�metro utilizado para filtro do Alias  - Ponto de Venda Inicial
Local cPontoAte	:= mv_par04							// Par�metro utilizado para filtro do Alias  - Ponto de Venda Final
Local aPdvDay	:= {}								// Array Principal utilizado para agrupamento
Local aCondPg	:= {}                               // Array de Condi��o de Pagamento utilizado para agrupamento
Local nPos		:= 0								// Variavel utilizada para retornar a posi��o do Array Principal
Local nPosCond  := 0 								// Variavel utilizada para retornar a posi��o do Array Principal
Local cAliasSL1	:= GetNextAlias()					// Proximo Alias Disponivel - Principal
Local cAliasCan	:= GetNextAlias()					// Proximo Alias Disponivel - Canceladas
Local cIndex	:= ""								// Area do Indice utilizado quando n�o for TopConnect
Local nIndex	:= 0								// Area do Indice utilizado quando n�o for TopConnect
Local cDebug	:= ""								// Var�avel utilizada para debugar a Query
Local lQuery	:= .F.                              // Flag Utilizado para verificar se a consulta principal do relat�rio ser� por Query
Local nLin		:= 0								// Controle de Linha do Relat�rio
Local cOrdem	:= ""                               // Ordem utilizado quando a op��o n�o for TopConnect
Local cSituaca	:= "OK"								// Situa��o considerada para filtro
Local cCabec1	:= ""								// Cabe�alho um utilizado para impress�o do relat�rio
Local cCabec2	:= ""								// Cabe�alho dois utilizado para impress�o do relat�rio
Local cLinha    := "###   ###########   ############  #########    #################   #################   #################   #################" //Defini��o da Linha de Impress�o Principal
Local cLinha2   := "#################" 				//Defini��o da linha de impress�o Totalizadora de registros 
Local cLinha3   := "###                #################                   #################" 	//Defini��o da linha de impress�o Totalizadora
Local cLinha40  := "########################################"									//Defini��o da linha de impress�o para 40 colunas
Local cLinha43  := "########## ############## ##############"									//Defini��o da linha de impress�o para 40 colunas 3 partes
Local bCabec 	:= {	|| Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho), ;
								nLin := 8 } 		// Bloco de c�digo para chamada da fun��o FmtLin e impress�o de cabe�alho
Local nCont		:= 0								// Variavel responsavel pela contagem de registros 								
Local nX		:= 0 								// Variavel utilizada para o La�o de Impress�o
Local aLinha	:= Array(8)                        // Variavel Totalizador do Desconto 
Local nTotDesc	:= 0								// Variavel Totalizador do Exento	
Local nTotExen	:= 0								// Variavel Totalizador do Exclu�do
Local nTotExcl	:= 0								// Variavel Totalizador do Gravado 
Local nTotGrv	:= 0 								// Array utilizado para a impress�o
Local cVazio	:= ""                               // Variavel utilizada para execu��o do Filtro 
Local lSoma		:= .F. 								// Flag para identificar se ocorrera a Somat�ria
Local aCancel	:= {}							    // Array de Notas Canceladas  
Local aAliqImp	:= {}							    // Array de Aliquotas de Imposto
Local nPosAliq  := 0                               	// Posicao da aliquota
Local nTotalReg := 0                                // Total de registros do SL1
Local lPrint40  := .F.								// Verifica no cadastro de estacao se imprime em 40 colunas      
Local nTotIVA	:= 0								// Variavel Totalizador do IVA 
Local nTotVenda := 0								// Variavel Totalizador da Venda
Local nTotGeral	:= 0								// Variavel Totalizador Geral

cCabec2 := STR0015	 				//"PDV   FECHA EMISION  DOC. INICIAL  DOC. FINAL       DESCUENTOS           EXENTOS              EXCLUIDOS          GRABADOS"
cCabec1 := "NIT: " + SM0->M0_CGC	//NIT

#IFDEF TOP
    If TcSrvType() <> "AS/400"
    	lQuery := .T.
    Endif
#ENDIF

// Se imprime em 40 colunas seta variavel como true
If (LjGetStation("LG_LARGCOL") == 40)
	lPrint40 := .T.
EndIf

SF3->(DbSetOrder(1))

If lQuery

	BeginSql Alias cAliasSL1
		Column L1_DTLIM   as DATE
		Column L1_EMISNF  as DATE
		Column L1_EMISSAO as DATE		
		SELECT *
		FROM %Table:SL1% SL1
		WHERE L1_FILIAL = %Exp:xFilial("SL1")% AND 
			L1_EMISSAO >= %Exp:dDtIni% AND 
			L1_EMISSAO <= %Exp:dDtFim% AND 
			L1_ESTACAO >= %Exp:cPontoDe% AND 
			L1_ESTACAO <= %Exp:cPontoAte% AND 			
			L1_SITUA = %Exp:cSituaca% AND 						
			L1_DOC <> %Exp:cVazio% AND 									
			SL1.%NotDel% 
		ORDER BY L1_FILIAL,L1_ESTACAO,L1_EMISSAO,L1_DOC
	EndSql 		
		
	cDebug := GetLastQuery()[2]		//Para debugar a query
	
Else

	cAliasSL1 := "SL1"
	cIndex	:= CriaTrab(Nil,.F.)
	cFiltro	:= "L1_FILIAL == '"+ xFilial("SL1") + "' .And. "
 	cFiltro	+= "Dtos(L1_EMISSAO) >= '"+Dtos(dDtIni)+"' .And. "
	cFiltro	+= "Dtos(L1_EMISSAO) <= '"+Dtos(dDtFim)+"' .And. "                                    
 	cFiltro	+= "L1_ESTACAO >= '"+cPontoDe+"' .And. "
	cFiltro	+= "L1_ESTACAO <= '"+cPontoAte+"' .And. "                                    	
	cFiltro	+= "L1_SITUA == '"+cSituaca+"'  .And. "                                    		
	cFiltro	+= "L1_DOC <> ' '  "                                    				
	cOrdem := "L1_FILIAL+L1_ESTACAO+Dtos(L1_EMISSAO)+L1_DOC"
   
	IndRegua(cAliasSL1,cIndex,cOrdem,,cFiltro,STR0004) //"Selecionando registros..."
	nIndex := RetIndex("SL1")
	DbSetIndex(cIndex+OrdBagExt())
	DbSetOrder(nIndex+1)
	DbGoTop()	
	
Endif

DbSelectArea(cAliasSL1)
//���������������������������������������������������������������������Ŀ
//� SETREGUA -> Indica quantos registros serao processados para a regua �
//�����������������������������������������������������������������������

SetRegua((cAliasSL1)->(RecCount()))   

(cAliasSL1)->(DbGoTop())
SL2->(DbSetOrder(1))
SL4->(DbSetOrder(1))
SF3->(DbSetOrder(4))	
SF2->(DbSetOrder(2))
//�������������������������������������������������������������������������������Ŀ
//�Verifica se h� dados a imprimir, e havendo, roda o cabecalho na primeira pagina�
//���������������������������������������������������������������������������������
If (cAliasSL1)->( !EOF() )
	nLin := 8 
	If(lPrint40)
		nLin := 1
		
		FmtLin({SM0->M0_NOMECOM},cLinha40,,,@nLin,.T.)						//"NOME"   
		FmtLin({SM0->M0_FILIAL}	,cLinha40,,,@nLin,.T.)						//"NOME"
		FmtLin({cCabec1}   		,cLinha40,,,@nLin,.T.)						//"NIT"
		FmtLin({cNomeProg}		,cLinha40,,,@nLin,.T.)						//"NOME DO PROGRAMA"
		FmtLin({cTitulo} 		,cLinha40,,,@nLin,.T.)						//"TITULO"
	
	Else 
		Cabec( cTitulo , cCabec1 , cCabec2 , cNomeProg , cTamanho)
	EndIf
EndIf

While !(cAliasSL1)->(Eof())
	lSoma := .F. 
	//����������������������������������������Ŀ
	//� Aborta impressao                       �
	//������������������������������������������
	If lEnd
		Exit
	Endif  

	//���������������������������������������������Ŀ
	//� Efetua Filtro convforme express�o definida  �
	//�����������������������������������������������	
	If !Empty(aReturn[7]) .And. !(cAliasSL1)->(&(aReturn[7]))
		
		(cAliasSL1)->(DbSkip())
		Loop
		
	EndIf	

	If SF3->(DbSeek(xFilial("SF3")+(cAliasSL1)->L1_CLIENTE+(cAliasSL1)->L1_LOJA+(cAliasSL1)->L1_DOC+(cAliasSL1)->L1_SERIE ))  		
	
		While ! SF3->(EOF())  .And. SF3->F3_FILIAL == xFilial("SF3") .And. SF3->F3_CLIEFOR == (cAliasSL1)->L1_CLIENTE ;
							   .And. SF3->F3_LOJA == (cAliasSL1)->L1_LOJA .And. SF3->F3_NFISCAL == (cAliasSL1)->L1_DOC
							   
			//��������������������Ŀ
			//� Considera Sa�das   �
			//����������������������						        
	
	        If Substr(SF3->F3_CFO,1,1) >= "5"	                    
	        
				//���������������������������Ŀ
				//� Considera N�o Cancelados  �
				//�����������������������������						        	        
				
				If Empty(SF3->F3_DTCANC)				
	            
					//������������������������������������������������Ŀ
					//� Monta Array conforme agrupamento PDV e Data    �
					//��������������������������������������������������
					If Len(aPdvDay) == 0 .Or. (nPos := aScan(aPdvDay,{ | x | x[1] + x[2] == (cAliasSL1)->L1_ESTACAO+DTOC((cAliasSL1)->L1_EMISSAO) }) ) == 0
						aAdd(aPdvDay,{(cAliasSL1)->L1_ESTACAO,DTOC((cAliasSL1)->L1_EMISSAO),(cAliasSL1)->L1_DOC,(cAliasSL1)->L1_DOC,0,0,0,0})
						nPos := Len(aPdvDay)
					EndIf
				
					//�����������������������������������Ŀ
					//� Atualiza Documento Final		  �                                             
					//�������������������������������������    
					aPdvDay[nPos][4] := (cAliasSL1)->L1_DOC		        

		   			If SF2->(DbSeek(xFilial("SF2")+(cAliasSL1)->L1_CLIENTE+(cAliasSL1)->L1_LOJA+(cAliasSL1)->L1_DOC+(cAliasSL1)->L1_SERIE ))  		
		
						//��������������������Ŀ
						//� Atualiza Desconto  �
						//����������������������										
						If SF2->F2_DESCONT > 0 
							aPdvDay[nPos][5] += xMoeda(SF2->F2_DESCONT,SF2->F2_MOEDA,1,SF2->F2_EMISSAO)
						Endif 					
						
			        Endif   
			        
					//��������������������Ŀ
					//� Atualiza Exentos   �
					//����������������������						
					If (SF3->F3_BASIMP1 + SF3->F3_BASIMP2 + SF3->F3_BASIMP3 + SF3->F3_BASIMP4 + SF3->F3_BASIMP5 + SF3->F3_BASIMP6) > 0 .And.;
					   (SF3->F3_VALIMP1 + SF3->F3_VALIMP2 + SF3->F3_VALIMP3 + SF3->F3_VALIMP4 + SF3->F3_VALIMP5 + SF3->F3_VALIMP6) == 0
					   				
						aPdvDay[nPos][6] += SF3->F3_VALCONT 
						lSoma := .T.
						
					Else
					
						//��������������������Ŀ
						//� Atualiza Excluidos �
						//����������������������					
						If SF3->F3_EXENTAS > 0 
							aPdvDay[nPos][7] += SF3->F3_EXENTAS
							lSoma := .T.
						Else
	
							//��������������������Ŀ
							//� Atualiza Gravados  �
							//����������������������					
							If (SF3->F3_VALIMP1 + SF3->F3_VALIMP2 + SF3->F3_VALIMP3 + SF3->F3_VALIMP4 + SF3->F3_VALIMP5 + SF3->F3_VALIMP6) >  0
								aPdvDay[nPos][8] += (SF3->F3_BASIMP1 + SF3->F3_BASIMP2 + SF3->F3_BASIMP3 + SF3->F3_BASIMP4 + SF3->F3_BASIMP5 + SF3->F3_BASIMP6)
								lSoma := .T.						
								
								//����������������������������������Ŀ
								//�Grava array separado por aliquota �
								//������������������������������������
								For nX := 1 To 6													 
									nPosAliq := aScan( aAliqImp, { |x| x[1] == AllTrim(STR(SF3->&("F3_ALQIMP"+AllTrim(STR(nX))))) } )  
									If nPosAliq > 0
										aAliqImp[nPosAliq][2] += SF3->&("F3_BASIMP"+AllTrim(STR(nX)))	
										aAliqImp[nPosAliq][3] += SF3->&("F3_VALIMP"+AllTrim(STR(nX)))								
									ElseIf SF3->&("F3_ALQIMP"+AllTrim(STR(nX))) > 0
										aAdd( aAliqImp,{ AllTrim(STR(SF3->&("F3_ALQIMP"+AllTrim(STR(nX))))) , SF3->&("F3_BASIMP"+AllTrim(STR(nX))), SF3->&("F3_VALIMP"+AllTrim(STR(nX))) } )
									EndIf
								Next nX
							Endif 					
							
						Endif 					                            
						
					Endif 					                
		
				Endif 			        
				
			Endif 									   

			SF3->(DbSkip())
		End
	Endif 		

	//�����������������������������������������������������Ŀ
	//� Monta Array Totalizador Por Condicao de Pagamento   �
	//�������������������������������������������������������
	If lSoma   
		If SL4->(DbSeek(xFilial("SL4")+(cAliasSL1)->L1_NUM))
	    	While ! SL4->(EOF()) .And. SL4->L4_FILIAL == xFilial("SL4") .And. SL4->L4_NUM == (cAliasSL1)->L1_NUM
	    	
				If Len(aCondPg) == 0 .OR. (nPosCond := aScan(aCondPG,{ | z | z[1] == SubStr(AllTrim(Posicione("SX5",1,xFilial("SX5")+"24"+SL4->L4_FORMA,"X5_DESCSPA")),1,10) }  )) == 0 
					aAdd( aCondPG,{SubStr(AllTrim(Posicione("SX5",1,xFilial("SX5")+"24"+SL4->L4_FORMA,"X5_DESCSPA")),1,10),0,0})  						
					nPosCond := Len(aCondPg)
				EndIf
			 
				aCondPG[nPosCond][2] += SL4->L4_VALOR 
 				aCondPG[nPosCond][3] += 1	   	    	    	
			
				SL4->(DbSkip())			    	
	    	End
	    	
		Endif   			
	EndIf  
   	  
   	// Total de registros do SL1
	nTotalReg += 1    
   	
	(cAliasSL1)->(DbSkip())  
End	    

//��������������������������������Ŀ
//� Impress�o do Array Principal   �
//����������������������������������
For nX := 1 To Len(aPdvDay)
		aLinha:= Aclone(aPdvDay[nX])	
	
		nTotDesc+=  aLinha[5]
		nTotExen+=  aLinha[6]
		nTotExcl+=  aLinha[7]
		nTotGrv	+=  aLinha[8] 
			
		If lPrint40 
			nLin ++   
			FmtLin({"PDV: " + aLinha[1]}			,cLinha40,,,@nLin,.T.)		//"PDV"
			FmtLin({"FECHA EMISION: " + aLinha[2]}	,cLinha40,,,@nLin,.T.)		//"FECHA EMISION"	
			FmtLin({"DOC. INICIAL/FINAL"}			,cLinha40,,,@nLin,.T.)		//"DOC. INICIAL/FINAL"
			FmtLin({aLinha[3]+ "/" +aLinha[4]}		,cLinha40,,,@nLin,.T.)     //"DOC. INICIAL/FINAL"    	
			nLin ++	  
			
			//�������������������������������������������Ŀ
			//� Impressoes do Totalizador de IVA  	 	  �
			//���������������������������������������������
			If Len(aAliqImp) > 0 
												
				For nX := 1 To Len(aAliqImp)        
					  
					nTotVenda 	+= aAliqImp[nX][2]
					nTotIVA 	+= aAliqImp[nX][3]				
										
				Next nX                                                                      
				
				FmtLin({"TOTAL IVA: "},cLinha40,,,@nLin,.T.)					//"TOTAL IVA"
				FmtLin({nTotIVA},cLinha40,,,@nLin,.T.)
				
			Endif  
			
			FmtLin({"EXENTOS: "}					,cLinha40,,,@nLin,.T.)		//"EXENTOS"
			FmtLin({aLinha[6]}						,cLinha40,,,@nLin,.T.)
			FmtLin({"EXCLUIDOS:"}					,cLinha40,,,@nLin,.T.)		//"EXCLUIDOS"
			FmtLin({aLinha[7]}						,cLinha40,,,@nLin,.T.)	
			FmtLin({"GRABADOS: "}					,cLinha40,,,@nLin,.T.)		//"GRABADOS"
			FmtLin({aLinha[8]}						,cLinha40,,,@nLin,.T.)			
			
			FmtLin({STR0016 + ": "},cLinha40,,,@nLin,.T.)						//"TOTAL GENERAL"  
			                                         
			nTotGeral := 	( nTotExen +	nTotExcl + nTotGrv	+ nTotIVA )
			FmtLin({nTotGeral},cLinha40,,,@nLin,.T.)   
			
		Else	                                        
			FmtLin(aLinha,cLinha,,,@nLin,.T.,bCabec)	
		EndIf	
Next nX   
            
nLin ++
If Len(aPdvDay) > 1 
	If lPrint40
		nLin ++	 
		FmtLin({"--------------------"}	,cLinha40,,,@nLin,.T.)				//"-"		
		FmtLin({STR0016}   		,cLinha40,,,@nLin,.T.)						//"TOTAL GENERAL"
		nLin ++
		FmtLin({"DESCUENTOS: "}	,cLinha40,,,@nLin,.T.)						//"DESCUENTOS"
		FmtLin({nTotDesc}		,cLinha40,,,@nLin,.T.)
		FmtLin({"EXENTOS: "}	,cLinha40,,,@nLin,.T.)						//"EXENTOS"
		FmtLin({nTotExen}		,cLinha40,,,@nLin,.T.)
		FmtLin({"EXCLUIDOS:"}	,cLinha40,,,@nLin,.T.)						//"EXCLUIDOS"
		FmtLin({nTotExcl}		,cLinha40,,,@nLin,.T.)	
		FmtLin({"GRABADOS: "}	,cLinha40,,,@nLin,.T.)						//"GRABADOS"
		FmtLin({nTotGrv}		,cLinha40,,,@nLin,.T.)	
	Else
		aLinha[01] := ""
		aLinha[02] := ""
		aLinha[03] := ""
		aLinha[04] := ""		
		aLinha[05] := "      -----------"
		aLinha[06] := "      -----------"
		aLinha[07] := "      -----------"
		aLinha[08] := "      -----------"
		FmtLin(aLinha,cLinha,,,@nLin,.T.,bCabec)		
	
		aLinha[01] := STR0016
		aLinha[02] := ""
		aLinha[03] := ""
		aLinha[04] := ""		
		aLinha[05] := nTotDesc
		aLinha[06] := nTotExen
		aLinha[07] := nTotExcl
		aLinha[08] := nTotGrv			                
		FmtLin(aLinha,cLinha,,,@nLin,.T.,bCabec)  
	EndIf		

Endif   

//�����������������������������������Ŀ
//� Impress�o do Totalizador - Forma  �
//�������������������������������������
nLin += 3
If Len(aCondPG) > 0  
	If lPrint40 
		FmtLin({STR0017 + Space(10) + STR0018 + Space(10) + "N.TRAN"},cLinha40,,,@nLin,.T.)		// "FORMA" ### "VALOR" ### "N.TRAN"	
	Else
		FmtLin({STR0017,STR0018,"N.TRAN"},cLinha3,,,@nLin,.T.,bCabec)								// "FORMA" ### "VALOR" ### "N.TRAN"
	EndIf
	
	For nX := 1 To Len(aCondPG)
		
		aLinha:= Aclone(aCondPG[nX]) 
		If lPrint40
			FmtLin(aLinha,cLinha43,,,@nLin,.T.)	
	    Else
	    	FmtLin(aLinha,cLinha3,,,@nLin,.T.,bCabec)	
	    EndIf
	
	Next nX
Endif 

//�������������������������������������������Ŀ
//� Impressoes do Totalizador - Aliquota 	  �
//���������������������������������������������
nLin += 3
If Len(aAliqImp) > 0 
	If lPrint40
		FmtLin({"% IVA" + Space(10) + "VENTAS" + Space(10) + "VALOR IVA"},cLinha40,,,@nLin,.T.)		
	Else 
		FmtLin({"% IVA","VENTAS","VALOR IVA"},cLinha3,,,@nLin,.T.,bCabec)			
	EndIf
	
	For nX := 1 To Len(aAliqImp)        
		
		aLinha:= Aclone(aAliqImp[nX])
		If lPrint40		
			FmtLin(aLinha,cLinha43,,,@nLin,.T.)	
		Else
			FmtLin(aLinha,cLinha3,,,@nLin,.T.,bCabec)	
		EndIf		
	
	Next nX  
	
	nLin++
	
	If lPrint40		
		FmtLin({"TOTAL:",nTotVenda,nTotIVA},cLinha43,,,@nLin,.T.)	
	Else
		FmtLin({"TOTAL:",nTotVenda,nTotIVA},cLinha3,,,@nLin,.T.,bCabec)	
	EndIf
	
	
Endif  
 
//�������������������������������������������Ŀ
//� Impressoes do Total de registros    	  �
//���������������������������������������������
nLin += 3
FmtLin({"REGISTROS PROCESSADOS"},cLinha2,,,@nLin,.T.,IIf(lPrint40,,bCabec))		
aLinha:= { STR(nTotalReg)	}
FmtLin(aLinha,cLinha2,,,@nLin,.T.,IIf(lPrint40,,bCabec))	
 

If lQuery

	BeginSql Alias cAliasCan
		SELECT F3_SERIE,F3_NFISCAL
		FROM %Table:SF3% SF3
		WHERE F3_FILIAL = %Exp:xFilial("SF3")% AND 
			F3_EMISSAO >= %Exp:dDtIni% AND 
			F3_EMISSAO <= %Exp:dDtFim% AND 
			F3_PDV >= %Exp:cPontoDe% AND 
			F3_PDV <= %Exp:cPontoAte% AND 			
			F3_DTCANC <> %Exp:cVazio% AND 									
			SF3.%NotDel% 
		ORDER BY F3_FILIAL,F3_PDV,F3_EMISSAO,F3_NFISCAL
	EndSql 		
		
	cDebug := GetLastQuery()[2]		//Para debugar a query
	
Else

	cAliasCan := "SF3"
	cIndex	:= CriaTrab(Nil,.F.)
	cFiltro	:= "F3_FILIAL == '"+ xFilial("SF3") + "' .And. "
 	cFiltro	+= "Dtos(F3_EMISSAO) >= '"+Dtos(dDtIni)+"' .And. "
	cFiltro	+= "Dtos(F3_EMISSAO) <= '"+Dtos(dDtFim)+"' .And. "                                    
 	cFiltro	+= "F3_PDV >= '"+cPontoDe+"' .And. "
	cFiltro	+= "F3_PDV <= '"+cPontoAte+"' .And. "                                    	
	cFiltro	+= "F3_DTCANC <> ' '  "                                    				
	cOrdem := "F3_FILIAL+F3_PDV+Dtos(F3_EMISSAO)+F3_NFICAL"
   
	IndRegua(cAliasCan,cIndex,cOrdem,,cFiltro,STR0004) //"Selecionando registros..."
	nIndex := RetIndex("SF3")
	DbSetIndex(cIndex+OrdBagExt())
	DbSetOrder(nIndex+1)
	DbGoTop()	
	
Endif

//�����������������������������������Ŀ
//� Selecao das Nfs Canceladas        �
//�������������������������������������                                      
While !(cAliasCan)->(EOF())

	If Len(aCancel) == 0 .Or. (nPos := aScan(aCancel,{ | z | z[1]+z[2] == (cAliasCan)->F3_SERIE+(cAliasCan)->F3_NFISCAL }  )) == 0 
		aAdd( aCancel,{(cAliasCan)->F3_SERIE,(cAliasCan)->F3_NFISCAL})
	Endif 

	(cAliasCan)->(DbSkip())
	
End
//�����������������������������������Ŀ
//� Impress�o das Nfs Canceladas      �
//�������������������������������������                                      
nLin += 3
If Len(aCancel) > 0    
	aLinha	:= Array(3)
	FmtLin({STR0019,STR(Len(aCancel))},cLinha2,,,@nLin,.T.,IIf(lPrint40,,bCabec))		//"Factura(s) Cancelada(s)....."
	
	If lPrint40
		FmtLin({STR0020,STR0021,""},cLinha43,,,@nLin,.T.)		        //"Serie"/"Documento"
	Else
		FmtLin({STR0020,STR0021},cLinha2,,,@nLin,.T.,bCabec)      		//"Serie"/"Documento"
	EndIf
	
	For nX:= 1 to Len(aCancel)         
	    aLinha[01] := aCancel[nx][1]
	  	aLinha[02] := aCancel[nx][2]  
	  	aLinha[03] := ""
	  	If lPrint40
			FmtLin(aLinha,cLinha43,,,@nLin,.T.)	
		Else 
			FmtLin(aLinha,cLinha2,,,@nLin,.T.,bCabec)	
		EndIf
    Next nX
Endif 
If lQuery
	(cAliasSL1)->(DbCloseArea())
	(cAliasCan)->(DbCloseArea())	
Else
  	DbSelectArea("SL1")
	RetIndex("SL1")
	DbClearFilter()
	Ferase(cIndex+OrdBagExt())

  	DbSelectArea("SF3")
	RetIndex("SF3")
	dbClearFilter()
	Ferase(cIndex+OrdBagExt())	
Endif
	
If aReturn[5] == 1
   dbCommitAll()
   Set Printer To
   OurSpool(wnRel)
Endif

MS_FLUSH()
	
Return Nil



