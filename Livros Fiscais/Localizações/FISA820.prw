#INCLUDE "TOTVS.CH"
#INCLUDE "FISA820.CH"
#DEFINE ENTER CHR(13)+CHR(10)

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北勘�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪穆哪哪哪哪�	勘�
北矲un噭o    矲ISA820   砇ev.   �          � Data �22/07/2019       		潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪穆哪哪哪哪�	幢�
北�          砇otina para gerar TXT Bolivia                            		潮�
北�          �                                                         		潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪�	幢�
北砅arametros� ExpC1 = Codigo do Cliente Inicial                       		潮�
北�          � ExpC2 = Codigo da Loja Cliente Inicial                  		潮�
北�          � ExpC3 = Codigo do Cliente Final                         		潮�
北�          � ExpC4 = Codigo da Loja Cliente Final                    		潮�
北�          � ExpD1 = Data de Emissao Inicial                          	潮�
北�          � ExpD2 = Data de Emissao Final                            	潮�
北�          � ExpN1 = Opcao (1=Simplificado;2=Personas Naturales;3=Ambos) 	潮�
北�          � ExpL1 = .T. Gera TXT; .F. N鉶 gera TXT                      	潮�
北�          � ExpC5 = Pasta de destino do TXT dentro do "Startpath"       	潮�
北�          � ExpL2 = .T. Gera Relatorio de Logs                          	潮�
北�                    .F. N鉶 gera Relatorio de Logs                      	潮�
北�          � ExpN2 = Tipo de Referencia do Valor Minimo                 	潮�
北�          �         1=Novos;2=Ate Data Cadastro;3=Todos                	潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪履哪哪哪履	幢�
北砇etorno   � ExpL1 = .T. Encontrado cliente com soma Maior que MV_MONMIN  潮�
北�          �         .F. Quando n鉶 encontrado                           	潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�	幢�
北矰escri噭o 砇otina para gerar TXT Bolivia                                	潮�
北�          �                                                             	潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�	幢�
北砋so       � FISCAL INTERNACIONAL                                        	潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�	北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�	勘�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/

Function FISA820(cCliIni,cFilIni,cCliFim,cFilFim,dDataIni,dDataFim,nTipo,lGeraTxt,cPasta,lGeraRel,nMonMin)

Local lRet 		:= .F.
Local lExecuta	:= .T.
Local cPerg		:= 'FISA820'
Private lResultS :=.T.
Private lNatural  :=.T.
Private aResult   := {}

Default cCliIni := ''
Default cCliFim := ''
Default cFilIni := ''
Default cFilFim := ''
Default cPasta	:= ''
Default dDataIni:= STOD('')
Default dDataFim:= STOD('')
Default nMonMin := 2
Default lGeraTxt:= .F.
Default lGeraRel:= .F.
Default nTipo	:= 3

//Quando a funcao for chamada nao solicitar parametros
If FunName() == "FISA820"

		//-------------------------
		// FISA820
		// MV_PAR01 - Cliente de
		// MV_PAR02 - Filial de
		// MV_PAR03 - Cliente Ate
		// MV_PAR04 - Filial Ate
		// MV_PAR05 - Emissao de
		// MV_PAR06 - Emissao Ate
		// MV_PAR07 - Tipo (1=Simplificado; 2=Personas Naturales; 3=Ambos)
		// MV_PAR08 - Pasta de destino dentro do "Startpath"
		//-------------------------

	lExecuta := Pergunte(cPerg,.T.)

	cCliIni := MV_PAR01
	cFilIni := MV_PAR02
	cCliFim := MV_PAR03
	cFilFim	:= MV_PAR04
	dDataIni:= MV_PAR05
	dDataFim:= MV_PAR06
	nTipo	:= MV_PAR07
	cPasta	:= Alltrim(MV_PAR08)
	nMonMin	:= MV_PAR09
	lGeraTxt:= .T.	
	lGeraRel:= .T.		

	If lExecuta 
		Processa( {|| FISA820A(cCliIni,cFilIni,cCliFim,cFilFim,dDataIni,dDataFim,nTipo,lGeraTxt,cPasta,@aResult,@lRet,nMonMin)  }, STR0003, STR0004, .F. )			
	EndIf

Else

	FISA820A(cCliIni,cFilIni,cCliFim,cFilFim,dDataIni,dDataFim,nTipo,lGeraTxt,cPasta,@aResult,@lRet,nMonMin)

EndIf

//Gera relatorio com Log de erros
If lExecuta  .And. lGeraRel 
	FISA820R(aResult)
EndIf	

Return(lRet)

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪目北
北矲un噭o    矲ISA820A  砇ev.   �                       � Data �           潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪拇北
北�          砇otina para gerar TXT Bolivia                               潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros� ExpC1 = Codigo do Cliente Inicial                           潮�
北�          � ExpC2 = Codigo da Loja Cliente Inicial                      潮�
北�          � ExpC3 = Codigo do Cliente Final                             潮�
北�          � ExpC4 = Codigo da Loja Cliente Final                        潮�
北�          � ExpD1 = Data de Emissao Inicial                             潮�
北�          � ExpD2 = Data de Emissao Final                               潮�
北�          � ExpN1 = Opcao (1=Simplificado;2=Personas Naturales;3=Ambos) 潮�
北�          � ExpL1 = .T. Gera TXT; .F. N鉶 gera TXT                      潮�
北�          � ExpC5 = Pasta de destino do TXT dentro do "Startpath"       潮�
北�          � ExpA1 = Array com o Log da geracao dos arquivos             潮�
北�          � ExpL2 = .T. Encontrado cliente com soma Maior que MV_MONMIN潮�
北�          �         .F. Quando n鉶 encontrado                     	   潮�
北�          � ExpN2 = Tipo de Referencia do Valor Minimo                  潮�
北�          �         1=Novos;2=Ate Data Cadastro;3=Todos                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砇etorno   � ExpL1 = .T. Encontrado cliente com soma Maior que MV_MONMIN潮�
北�          �         Se n鉶 encontrado retorna .F.                       潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北矰escri噭o 砇otina para gerar TXT Bolivia                                潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       � FISCAL INTERNACIONAL                                        潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/

Static Function FISA820A(cCliIni,cFilIni,cCliFim,cFilFim,dDataIni,dDataFim,nTipo,lGeraTxt,cPasta,aResult,lRet,nMonMin,cLinArq)

Local nValLim	:= SuperGetMV("MV_MONMIN",,0)
Local nSoma		:= 0
Local cQuery	:= ''
Local cAliasSD2	:= GetNextAlias()
Local cLinhas 	:= ''
Local cMesAno	:= AllTrim(Str(Month(dDataBase)))+AllTrim(Str(Year(dDataBase)))
Local aCliAtu	:= {}
Local aCliAnt	:= {}
Local lSa1Comp  := .F.
Local cLinAcm3  := ''
Local cLinAcm7  := ''

Default cCliIni := ''
Default cCliFim := ''
Default cFilIni := ''
Default cFilFim := ''
Default cPasta	:= ''
Default dDataIni:= STOD('')
Default dDataFim:= STOD('')
Default lGeraTxt:= .F.
Default lRet	:= .F.
Default nTipo	:= 3
Default nMonMin := 2
Default aResult	:= {}
Default cLinArq :=0
    
If  Alltrim(FWModeAccess("SA1")) == "C"  //Empty(Xfilial("SA1"))
   	lSa1Comp:=.t.
EndIf
   
cQuery := "SELECT SD2.D2_CLIENTE, SD2.D2_LOJA, SA1.A1_CGC, SA1.A1_NOME, SD2.D2_QUANT, SD2.D2_COD, SB1.B1_DESC, SB1.B1_UM, "
cQuery += "SD2.D2_PRCVEN, SD2.D2_TOTAL, SA1.A1_PESSOA, SA1.A1_TIPO, SF4.F4_GERALF, SF4.F4_DUPLIC, SF2.F2_MOEDA, SF2.F2_TXMOEDA, SF2.F2_EMISSAO "
cQuery += "FROM " + RetSqlTab('SD2')

cQuery += "INNER JOIN " + RetSqlTab('SF2')
	
If !lSa1Comp
	cQuery += "ON SF2.F2_FILIAL = '" + xFilial('SF2') + "' "
	cQuery += "AND SF2.F2_DOC = SD2.D2_DOC "
Else
	cQuery += "ON SF2.F2_DOC = SD2.D2_DOC "	
EndIf
cQuery += "AND SF2.F2_DOC = SD2.D2_DOC "
cQuery += "AND SF2.F2_SERIE = SD2.D2_SERIE "
cQuery += "AND SF2.D_E_L_E_T_ = '' "
	
cQuery += "INNER JOIN " + RetSqlTab('SA1')
If !lSa1Comp
	cQuery += "ON SA1.A1_FILIAL = '" + xFilial('SA1') + "' "
	cQuery += "AND SA1.A1_COD = SD2.D2_CLIENTE "
Else
	cQuery += "ON SA1.A1_COD = SD2.D2_CLIENTE "
EndIf
cQuery += "AND SA1.A1_LOJA = SD2.D2_LOJA "
cQuery += "AND SA1.D_E_L_E_T_ = '' "

cQuery += "INNER JOIN " + RetSqlTab('SB1')
cQuery += "ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' "
cQuery += "AND SB1.B1_COD = SD2.D2_COD "
cQuery += "AND SB1.D_E_L_E_T_ = '' "

cQuery += "INNER JOIN " + RetSqlTab('SF4')
cQuery += "ON SF4.F4_FILIAL = '" + xFilial('SF4') + "' "
cQuery += "AND SF4.F4_CODIGO = SD2.D2_TES "
cQuery += "AND SF4.D_E_L_E_T_ = '' "
	
	If !lSa1Comp
		cQuery += "WHERE SD2.D2_FILIAL = '" + xFilial('SD2') + "' "
		If TCGetDB() $ "ORACLE|POSTGRES"
			cQuery += "AND SD2.D2_CLIENTE || SD2.D2_LOJA BETWEEN '" + cCliIni + cFilIni + "' AND '" + cCliFim + cFilFim + "' "
		Else
			cQuery += "AND SD2.D2_CLIENTE + SD2.D2_LOJA BETWEEN '" + cCliIni + cFilIni + "' AND '" + cCliFim + cFilFim + "' "
		Endif
	Else
		If TCGetDB() $ "ORACLE|POSTGRES"
			cQuery += "WHERE SD2.D2_CLIENTE || SD2.D2_LOJA BETWEEN '" + cCliIni + cFilIni + "' AND '" + cCliFim + cFilFim + "' "
		Else
			cQuery += "WHERE SD2.D2_CLIENTE + SD2.D2_LOJA BETWEEN '" + cCliIni + cFilIni + "' AND '" + cCliFim + cFilFim + "' "
		Endif
	EndIf
	
cQuery += "AND SD2.D2_EMISSAO BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDataFim) + "' "
	
If nMonMin == 2			// Novos
	cQuery += "AND  SD2.D2_EMISSAO > SA1.A1_DTMONMI "
ElseIf nMonMin == 1		// Ate a data do cadastro
	cQuery += "AND  SD2.D2_EMISSAO <= SA1.A1_DTMONMI "
EndIf 
	
cQuery += "AND SD2.D_E_L_E_T_ = '' "

If nTipo == 1 
	cQuery += "AND SA1.A1_TIPO = '7' "
ElseIf nTipo == 2
	cQuery += "AND SA1.A1_TIPO = '3' " 		//RTS - R間imen Tributario Simplificado
ElseIf nTipo == 3
	cQuery += "AND (SA1.A1_TIPO = '7' "
	cQuery += "OR  SA1.A1_TIPO = '3')
EndIf

cQuery += "AND SF4.F4_GERALF = '1' "		//Considera somente os movimentos que geram Livro
cQuery += "AND SF4.F4_DUPLIC = 'S' "		//Considera somente os movimentos de vendas

cQuery += "ORDER BY SA1.A1_TIPO, SA1.A1_CGC, SD2.D2_CLIENTE, SD2.D2_LOJA "

cQuery := ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSD2, .F., .T.)

ProcRegua(Contar(cAliasSD2,"!Eof()"))
(cAliasSD2)->(dbGotop())

If (cAliasSD2)->(!Eof())
	aCliAnt	 := {(cAliasSD2)->(A1_TIPO),(cAliasSD2)->(A1_CGC),(cAliasSD2)->(D2_CLIENTE+D2_LOJA),(cAliasSD2)->(A1_NOME)}
	aCliAtu  := {(cAliasSD2)->(A1_TIPO),(cAliasSD2)->(A1_CGC),(cAliasSD2)->(D2_CLIENTE+D2_LOJA),(cAliasSD2)->(A1_NOME)}
EndIf

While (cAliasSD2)->(!Eof())
	IncProc(STR0004)

	//Acumula valores por A1_CGC
	If aCliAnt[2] == aCliAtu[2]

	//Modelo Simplificado
		If aCliAnt[1] == '7'

			If (cAliasSD2)->(F4_DUPLIC) == 'S'
				cLinhas += SubStr(AllTrim((cAliasSD2)->(D2_CLIENTE+D2_LOJA)),1,20) + '|'																			
				cLinhas += SubStr(AllTrim((cAliasSD2)->(A1_CGC)),1,13) + '|'																						
				cLinhas += SubStr(AllTrim((cAliasSD2)->(D2_COD)),1,50) + '|'																						
				cLinhas += SubStr(AllTrim((cAliasSD2)->(B1_DESC)),1,250) + '|'																						
				cLinhas += AllTrim(StrTran(Transform((cAliasSD2)->(D2_QUANT),PesqPict("SD2","D2_QUANT")),',','.')) + '|'  											
				cLinhas += AllTrim(StrTran(Transform(xMoeda((cAliasSD2)->(D2_PRCVEN),(cAliasSD2)->(F2_MOEDA),1,(cAliasSD2)->(F2_EMISSAO),MsDecimais(1),;
				(cAliasSD2)->(F2_TXMOEDA)) ,'@E 9999999.99'),',','.')) + '|'
				cLinhas += AllTrim(StrTran(Transform((cAliasSD2)->(D2_QUANT) * xMoeda((cAliasSD2)->(D2_PRCVEN),(cAliasSD2)->(F2_MOEDA),1,(cAliasSD2)->(F2_EMISSAO),;
				MsDecimais(1),(cAliasSD2)->(F2_TXMOEDA)) ,'@E 9999999.99'),',','.'))
				cLinhas += ENTER
			EndIf

		//Modelo Persona Natural
		ElseIf aCliAnt[1] == '3'
			If (cAliasSD2)->(F4_DUPLIC) == 'S'
				cLinhas += SubStr(AllTrim((cAliasSD2)->(D2_CLIENTE+D2_LOJA)),1,20) + '|'																			
				cLinhas += 'CI' + '|'																																
				cLinhas += SubStr(AllTrim((cAliasSD2)->(A1_CGC)),1,20) + '|'																						 
				cLinhas += SubStr(AllTrim((cAliasSD2)->(A1_NOME)),1,100) + '|'																						
				cLinhas += SubStr(AllTrim((cAliasSD2)->(D2_COD)),1,50) + '|'																						
				cLinhas += SubStr(AllTrim((cAliasSD2)->(B1_DESC)),1,250) + '|'																						
				cLinhas += AllTrim(StrTran(Transform((cAliasSD2)->(D2_QUANT),PesqPict("SD2","D2_QUANT")),',','.')) + '|'  											
				cLinhas += AllTrim(StrTran(Transform(xMoeda((cAliasSD2)->(D2_PRCVEN),(cAliasSD2)->(F2_MOEDA),1,(cAliasSD2)->(F2_EMISSAO),MsDecimais(1),;
				(cAliasSD2)->(F2_TXMOEDA)) ,'@E 9999999.99'),',','.')) + '|'
				cLinhas += AllTrim(StrTran(Transform(xMoeda((cAliasSD2)->(D2_QUANT) * (cAliasSD2)->(D2_PRCVEN),(cAliasSD2)->(F2_MOEDA),1,(cAliasSD2)->(F2_EMISSAO),;
				MsDecimais(1),(cAliasSD2)->(F2_TXMOEDA)) ,'@E 9999999.99'),',','.'))
				cLinhas += ENTER
			EndIf

		EndIf
			
		//Acumula valor para comparar com parametro
		nSoma 	+= (cAliasSD2)->(D2_QUANT * xMoeda((cAliasSD2)->(D2_PRCVEN),(cAliasSD2)->(F2_MOEDA),1,(cAliasSD2)->(F2_EMISSAO),MsDecimais(1),(cAliasSD2)->(F2_TXMOEDA)))
		
	Else

		//Verifica se a soma dos valores � maior que o definido no parametro
		If nSoma > nValLim
			//Realiza a totaliza玢o da variavel cLinhas para que
			//Todas as linhas dos Clientes do Tipo = 3 ou 7, sejam enviadas
			//De uma unica vez para grava玢o.
			If aCliAnt[1] == '3'
				cLinAcm3:= cLinAcm3+cLinhas
			Else
				cLinAcm7:= cLinAcm7+cLinhas
			EndIf	
			//Chamada da Fun玢o para realizar a atualiza玢o do cadastro
			//Dos clientes que possuem o Valor Limite superior a 136.000
			ActCli(aCliAnt[2],dDataFim,cPasta)
		EndIf

		
		
		//Modelo Simplificado
		If aCliAtu[1] == '7'

			If (cAliasSD2)->(F4_DUPLIC) == 'S'
				cLinhas := SubStr(AllTrim((cAliasSD2)->(D2_CLIENTE+D2_LOJA)),1,20) + '|'																			
				cLinhas += SubStr(AllTrim((cAliasSD2)->(A1_CGC)),1,13) + '|'																						
				cLinhas += SubStr(AllTrim((cAliasSD2)->(D2_COD)),1,50) + '|'																						
				cLinhas += SubStr(AllTrim((cAliasSD2)->(B1_DESC)),1,250) + '|'																						
				cLinhas += AllTrim(StrTran(Transform((cAliasSD2)->(D2_QUANT),PesqPict("SD2","D2_QUANT")),',','.')) + '|'  											
				cLinhas += AllTrim(StrTran(Transform(xMoeda((cAliasSD2)->(D2_PRCVEN),(cAliasSD2)->(F2_MOEDA),1,(cAliasSD2)->(F2_EMISSAO),MsDecimais(1),;
				(cAliasSD2)->(F2_TXMOEDA)) ,'@E 9999999.99'),',','.')) + '|'
				cLinhas += AllTrim(StrTran(Transform((cAliasSD2)->(D2_QUANT) * xMoeda((cAliasSD2)->(D2_PRCVEN),(cAliasSD2)->(F2_MOEDA),1,(cAliasSD2)->(F2_EMISSAO),;
				MsDecimais(1),(cAliasSD2)->(F2_TXMOEDA)) ,'@E 9999999.99'),',','.'))
				cLinhas += ENTER
			EndIf

		//Modelo Persona Natural
		ElseIf aCliAtu[1] == '3'

			If (cAliasSD2)->(F4_DUPLIC) == 'S'
				cLinhas := SubStr(AllTrim((cAliasSD2)->(D2_CLIENTE+D2_LOJA)),1,20) + '|'																			
				cLinhas += 'CI' + '|'																																
				cLinhas += SubStr(AllTrim((cAliasSD2)->(A1_CGC)),1,20) + '|'																						 
				cLinhas += SubStr(AllTrim((cAliasSD2)->(A1_NOME)),1,100) + '|'																						
				cLinhas += SubStr(AllTrim((cAliasSD2)->(D2_COD)),1,50) + '|'																						
				cLinhas += SubStr(AllTrim((cAliasSD2)->(B1_DESC)),1,250) + '|'																						
				cLinhas += AllTrim(StrTran(Transform((cAliasSD2)->(D2_QUANT),PesqPict("SD2","D2_QUANT")),',','.')) + '|'  											
				cLinhas += AllTrim(StrTran(Transform(xMoeda((cAliasSD2)->(D2_PRCVEN),(cAliasSD2)->(F2_MOEDA),1,(cAliasSD2)->(F2_EMISSAO),MsDecimais(1),;
				(cAliasSD2)->(F2_TXMOEDA)) ,'@E 9999999.99'),',','.')) + '|'
				cLinhas += AllTrim(StrTran(Transform((cAliasSD2)->(D2_QUANT) * xMoeda((cAliasSD2)->(D2_PRCVEN),(cAliasSD2)->(F2_MOEDA),1,(cAliasSD2)->(F2_EMISSAO),;
				MsDecimais(1),(cAliasSD2)->(F2_TXMOEDA)) ,'@E 9999999.99'),',','.'))					
				cLinhas += ENTER
			EndIf

		EndIf
			
		//Acumula valor para comparar com parametro
		nSoma 	:= (cAliasSD2)->(D2_QUANT * xMoeda((cAliasSD2)->(D2_PRCVEN),(cAliasSD2)->(F2_MOEDA),1,(cAliasSD2)->(F2_EMISSAO),MsDecimais(1),(cAliasSD2)->(F2_TXMOEDA)))
		
	EndIf
	
	aCliAnt	 := {(cAliasSD2)->(A1_TIPO),(cAliasSD2)->(A1_CGC),(cAliasSD2)->(D2_CLIENTE+D2_LOJA),(cAliasSD2)->(A1_NOME)}
	(cAliasSD2)->(DbSkip())
	aCliAtu  := {(cAliasSD2)->(A1_TIPO),(cAliasSD2)->(A1_CGC),(cAliasSD2)->(D2_CLIENTE+D2_LOJA),(cAliasSD2)->(A1_NOME)}

EndDo

(cAliasSD2)->(DbCloseArea())

	//Verifica se a soma dos valores � maior que o definido no parametro
If  nSoma > nValLim
	//Realiza a totaliza玢o da variavel cLinhas para que
	//Todas as linhas dos Clientes do Tipo = 3 ou 7, sejam enviadas
	//De uma unica vez para grava玢o.
	If aCliAtu[1] == '3'
		cLinAcm3:= cLinAcm3+cLinhas 
	Else
		cLinAcm7:= cLinAcm7+cLinhas
	EndIf
	//Chamada da Fun玢o para realizar a atualiza玢o do cadastro
	//Dos clientes que possuem o Valor Limite superior a 136.000	
	ActCli(aCliAtu[2],dDataFim,cPasta)
EndIf

If !Empty(cLinAcm3) 
		FNGERARQ("3",cLinAcm3,aCliAnt[2],aCliAnt[3],aCliAnt[4],cMesAno,cPasta,@aResult,dDataFim)		
EndIf

If !Empty(cLinAcm7) 
		FNGERARQ("7",cLinAcm7,aCliAnt[2],aCliAnt[3],aCliAnt[4],cMesAno,cPasta,@aResult,dDataFim)		
EndIf

	lRet := .T.


cLinhas 	:= ''
nSoma		:= 0

Return

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪目北
北矲un噭o    矲NGERARQ  砇ev.   �                        � Data �          潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪拇北
北�          砇otina para gerar TXT Bolivia                                潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros� ExpC1 = Pessoa F-Simplificado ou J-Persona Natural          潮�
北砅arametros� ExpC2 = Dados do arquivo a ser gerado                       潮�
北�          � ExpC3 = Codigo do NIT do CLiente                            潮�
北�          � ExpC4 = Codigo do Cliente                                   潮�
北�          � ExpC5 = MesAno                                              潮�
北�          � ExpC6 = Pasta de destino do TXT dentro do "Startpath"       潮�
北�          � ExpA1 = Array com o Log da geracao dos arquivos             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砇etorno   �                                                             潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北矰escri噭o 砇otina para gerar TXT Bolivia                                潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       � FISCAL INTERNACIONAL                                        潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/

Static Function FNGERARQ(cPessoa,cArquivo,cNIT,cCliente,cNomCli,cMesAno,cPasta,aResult,dDataFim)

Local nHdlSimp 	:= 0
Local nHdlPN 	:= 0

Default cPessoa		:= ''
Default cArquivo 	:= ''
Default cNIT		:= ''
Default cCliente	:= ''
Default cMesAno		:= ''
Default cPasta		:= ''
Default cNomCli		:= ''
Default aResult		:= {}
Default dDataFim:= STOD('')

//Cria a pasta caso nao exista
If !ExistDir(cPasta)

	If MakeDir(cPasta) != 0
		MsgAlert(STR0002 + cValToChar(FError()))
		Return
	EndIf

EndIf

//Verifica se ha dados para criar o arquivo SIMPLIFICADO_MMAAA_NIT.TXT
If cPessoa == '7'

	nHdlSimp 	:= FCREATE(cPasta + "\SIMPLIFICADO_" + cMesAno + "_" + AllTrim(SM0->M0_CGC) + ".TXT")
	If nHdlSimp > 0
		FWrite(nHdlSimp, cArquivo)

		FClose(nHdlSimp)
	EndIf

	//Verifica se ha dados para criar o arquivo PERSONASNATURALES_MMAAAA_NIT.TXT
ElseIf cPessoa == '3'

	nHdlPN 	:= FCREATE(cPasta + "\PERSONASNATURALES_" + cMesAno + "_" + AllTrim(SM0->M0_CGC) + ".TXT")
	If nHdlPN > 0
		FWrite(nHdlPN, cArquivo)
		
		FClose(nHdlPN)
	EndIf

EndIf

Return

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪目北
北矲un噭o    矲ISA820R  砇ev.   �                       � Data �           潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪拇北
北�          砇otina para gerar relatorio com Logs de exportacao do TXT    潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros� ExpA1 = Array com o Log da geracao dos arquivos             潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砇etorno   �                                                             潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北矰escri噭o 砇otina para gerar relatorio com Logs de exportacao do TXT    潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       � FISCAL INTERNACIONAL                                        潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Static Function FISA820R(aResult)

Local oReport

Default aResult := {}

oReport := ReportDef(aResult)
oReport:PrintDialog()

Return

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪目北
北矲un噭o    砇EPORTDEF 砇ev.   �                       � Data �           潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪拇北
北�          砇otina para gerar relatorio com Logs de exportacao do TXT    潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros� ExpA1 = Array com o Log da geracao dos arquivos             潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砇etorno   �                                                             潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北矰escri噭o 砇otina para gerar relatorio com Logs de exportacao do TXT    潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       � FISCAL INTERNACIONAL                                        潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Static Function ReportDef(aResult)

Local oReport
Local oSection1    
Local lPixel		:= .T.
Local lAutoSize		:= .T.
Local cAlign		:= 'LEFT'
Local cHeaderAlign	:= 'LEFT'
Local cCodCli		:= '' 
Local cNomCli		:= ''	
Local cNIT			:= '' 	
Local cArquivo		:= '' 	
Local cStatus		:= ''	

Default aResult := {}

oReport := TReport():New('FISA820R',STR0007,'FISA820R',{|oReport| PrintReport(oReport,aResult,@cCodCli,@cNomCli,@cNIT,@cArquivo,@cStatus)},"")
oReport:SetPortrait() 
oReport:SetTotalInLine(.T.)
oReport:HideParamPage() 

oSection1 := TRSection():New(oReport,OemToAnsi(STR0007),{})
oSection1:SetAutoSize(.T.)

TRCell():New(oSection1,'cArquivo',/*cAlias*/,STR0010,'@!',60,lPixel,{|| cArquivo },cAlign,/*lLineBreak*/,cHeaderAlign,/*lCellBreak*/,/*nColSpace*/,lAutoSize,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
TRCell():New(oSection1,'cStatus' ,/*cAlias*/,STR0011,'@!',20,lPixel,{|| cStatus } ,cAlign,/*lLineBreak*/,cHeaderAlign,/*lCellBreak*/,/*nColSpace*/,lAutoSize,/*nClrBack*/,/*nClrFore*/,/*lBold*/)

Return oReport

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪目北
北矲un噭o    砅RINTREPORT砇ev.   �                      � Data �           潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪拇北
北�          砇otina para gerar relatorio com Logs de exportacao do TXT    潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros� ExpO1 = Objeto oReport                                      潮�
北�          � ExpA1 = Array com o Log da geracao dos arquivos             潮�
北�          � ExpC1 = Codigo do Cliente                                   潮�
北�          � ExpC2 = Codigo do NIT do CLiente                            潮�
北�          � ExpC3 = Nome do arquivo TXT gerado                          潮�
北�          � ExpC4 = Status da operacao                                  潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砇etorno   �                                                             潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北矰escri噭o 砇otina para gerar relatorio com Logs de exportacao do TXT    潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       � FISCAL INTERNACIONAL                                        潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/
Static Function PrintReport(oReport,aResult,cCodCli,cNomCli,cNIT,cArquivo,cStatus)

Local oSection1	:= oReport:Section(1)
Local nDados := 0

Default aResult := {}

oSection1:Init()

For nDados := 1 to Len(aResult)

	cArquivo 	:= aResult[nDados,1]
	cStatus 	:= aResult[nDados,2]
	oSection1:PrintLine()

Next nDados

oSection1:Finish()

Return 

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪目北
北矲un噭o    矨CTCLI砇ev.   �                      � Data �11/12/2019      潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪拇北
北�          砇otina para realizar a atualiza玢o                           潮�
北�			  dos Cadastros dos Clientes que possuem o Valor Limite        潮�
北�			  de suas Transa珲es, superiores a 136.000                     潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砅arametros� ExpO1 = Cuit do Cliente                                     潮�
北�          � ExpA1 = Data informada na pergunta MV_PAR06                 潮�
北�          � ExpC1 = Pasta onde ser鉶 gerados os arquivos .txt           潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砇etorno   �                                                             潮�
北�          �                                                             潮�                                                           
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北矰escri噭o � Rotina para realizar a atualiza玢o                          潮�
北�			 � dos Cadastros dos Clientes que possuem o Valor Limite       潮�
北�			 � de suas Transa珲es, superiores a 136.000                    潮�
北�          �                                                             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       � FISCAL INTERNACIONAL                                        潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
*/

Static Function ActCli(cNit,dDataFim,cPasta)

Local aArea:=GetArea()
Local lPri :=.T.
Local cMesAno	:= AllTrim(Str(Month(dDataBase)))+AllTrim(Str(Year(dDataBase)))

Default cNit :=" "
Default dDataFim := dDataBase
Default cPasta:= ''

DbSelectArea('SA1')
DbSetOrder(3) //A1_FILIAL + A1_CGC

If DbSeek(xFilial('SA1')+cNIT)
	While AllTrim(SA1->A1_CGC) == AllTrim(cNIT)
		If Empty(SA1->A1_DTMONMI)  .or. Year(SA1->A1_DTMONMI) <> Year(dDataFim)
			RecLock('SA1',.F.)
			SA1->A1_DTMONMI := dDataFim
			MsUnlock()
		EndIf	
		If lPri
			If SA1->A1_TIPO == '3'   
			     If lNatural  
					aAdd(aResult,{cPasta + "\PERSONASNATURALES_" + cMesAno + "_" + AllTrim(SM0->M0_CGC) + ".TXT",STR0006}) //   A1_TIPO == 3
					lNatural  :=.F.
				EndIf
			Else        
				If lResultS
					aAdd(aResult,{cPasta + "\SIMPLIFICADO_" + cMesAno + "_" + AllTrim(SM0->M0_CGC) + ".TXT",STR0006})      //   A1_TIPO == 7
					lResultS :=.F.
				EndIf
			Endif
			lPri:=.F.
		EndIf
		DbSkip()
	EndDo

EndIf
RestArea(aArea)

Return()