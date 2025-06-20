#INCLUDE "AGRA500.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//===================================================================================
/*****  Fun��es relacionadas a sa�da por transfer�ncia - Romaneios  *****/
//===================================================================================


/*/{Protheus.doc} AX500SaiTr
//TODO Descri��o auto-gerada.
@author silvana.torres
@since 21/05/2018
@version undefined
@param cFilCli, characters, descricao
@param cFilOri, characters, descricao
@param cRomDest, characters, descricao
@param lAlgodao, logical, descricao
@param cNumOP, characters, descricao

@type function
/*/
Function AX500SaiTr(cFilCli, cFilOri, cRomDest, lAlgodao, cNumOP, oModel, lEfet)
	Local lRet		:= .T.
	Local cTpMovto  := SuperGetMV("MV_TPMVTRF",.F.,'') //Tipo de movimento para Transfer�ncia entre filiais
	Local cRomPar	:= ''
	
	Private _cIdMV := ""  //usada para gravar movimenta��o (AGRX500H.prw)

	//Verifica se saida foi originada por um romaneio de entrada
	If NJJ->NJJ_TIPO = "B" .AND. SUBSTRING(NJJ->NJJ_OBS,1,17) = "Filial de origem:"
	   //se saida foi criada por entrada j� foi gravada movimenta��o no mesmo ID, ent�o n�o faz nada
	Else
		//sen�o grava movimenta��o saida por transfer�ncia no OG (OGA440) 
		If !Empty(cTpMovto) 
		   lRet := A500GrvMov(cTpMovto, NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM)
		EndIf
	EndIf	
	
	if .Not. lAlgodao
		//Verifica se Lan�a produ��o (flag no tipo de opera��o)
		if AGRX500LP(NJJ->NJJ_TOETAP)
		
			IF .NOT. Empty(NJJ->NJJ_CODPRO) .AND. .NOT. Empty(NJJ->NJJ_PSLIQU) .AND. .NOT. Empty(NJJ->NJJ_LOCAL)
			
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
	
	if lRet
		//Verifica se Gera Pr�-romaneio(flag no tipo de opera��o)
		if AGRX500GPR(NJJ->NJJ_TOETAP)
			IF .NOT. Empty(NJJ->NJJ_CODPRO) .AND. .NOT. Empty(NJJ->NJJ_PSLIQU) .AND. .NOT. Empty(NJJ->NJJ_LOCAL)
				
				//--Se algod�o - Gera peso l�quido nos fard�es vinculados
				//--Sen�o passa verdadeiro pois � semente
				lRet := If(lAlgodao, AGRX500DXL(NJJ->NJJ_PSLIQU), .T.) 
				
				If lRet
			
					//verifica se a produ��o � de outra filial
					cFilCli := AGRX500POF(NJJ->NJJ_CODENT, NJJ->NJJ_LOJENT)
					
					if trim(cFilCli) <> ""
						//--ALTERA A FILIAL CORRENTE PARA A FILIAL DA ENTIDADE
						//================================
						cFilAnt := cFilCli			
						//================================
						
						//--Funcao na rotina AGRX500
						if .NOT. A500GerRom(NJJ->NJJ_TIPO, NJJ->NJJ_TOETAP, cFilOri, .F., lAlgodao, @cRomPar, oModel)
							lRet := .F.
						endIf

						//Verifica se saida foi originada por um romaneio de entrada
						If NJJ->NJJ_TIPO = "B" .AND. SUBSTRING(NJJ->NJJ_OBS,1,17) = "Filial de origem:"
						   //se saida foi criada por entrada j� foi gravada movimenta��o no mesmo ID, ent�o n�o faz nada
						Else
							//grava movimenta��o entrada por transfer�ncia no OG (OGA440) 
							If lRet .And. !Empty(cTpMovto) 
							   lRet := A500GrvMov(cTpMovto, cFilCli, NJJ->NJJ_CODROM)
							EndIf
						EndIf	
						
						/*//--Se processo de transferencia criar romaneios pelo GFE
						//--Deve-se tratar com a variavel criada de parametro
						//--Pois o erp se perde e retorna o posicionamento do romaneio de origem
						If FwIsInCallStack("GFEA523")*/
						cRomDest := cRomPar
						/*Else
							cRomDest   := NJJ->NJJ_CODROM
						EndIf*/
						cFilCli	   := ""
						
						//--RETORNA COM A FILIAL DE ORIGEM 
						//================================
						cFilAnt := cFilOri
						//================================
						
						If lRet
							//Efetua a transfer�ncia entre filiais. Funcao na rotina AGRX500B
							Processa({|| lRet := AGRX500TRE(M->NJJ_PSLIQU,NJJ->NJJ_CODSAF,M->NJJ_CODENT, M->NJJ_LOJENT,M->NJJ_CODPRO, "", "", .F., "", {{M->NJJ_CODROM,01,cFilAnt}})}, STR0100, STR0040 ) //"Movimentando Ordem de Produ��o..."###"Aguarde"
						EndIf
						
						//Efetiva transfer�ncia entre filiais
						If lRet
						   Processa({|| lRet := AGRX500EFT()}, STR0129, STR0040 ) //"Efetivando transfer�ncia..."###"Aguarde"
						   lEfet := lRet
						EndIf
					endIf
				endIf
			endIf
		Else
			//N�o gera pr�-romaneio. Ent�o, gera somente pedido de venda e a nota.								
			lRet := AGRX500PED(NJJ->NJJ_CODROM)
		endIf									
	endif
	
	//inicializa variavel do tipo de movimento -- fun��o A500GrvMov()
	_cIdMV := ""	
		
Return lRet
