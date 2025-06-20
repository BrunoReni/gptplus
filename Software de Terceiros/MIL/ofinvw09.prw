// 浜様様様曜様様様様�
// � Versao � 3      �
// 藩様様様擁様様様様�

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW09.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun艫o    | OFINVW09   | Autor | Luis Delorme          | Data | 20/05/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri艫o | Importa艫o VW Assunto FG4 - C.R. / Cr�ditos/D�bitos G & AT   |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW09(lEnd, cArquivo)
//
Local nCurArq
//
Local aLayFG4 := {}
//
aAdd(aLayFG4, {"C",3,0,1," " }) 	// "TIPO DE REGISTRO (FG4)"})
aAdd(aLayFG4, {"C",4,0,4," " }) 	// "SUBC�DIGO DO REGISTRO (Fixo:Comu)"})
aAdd(aLayFG4, {"N",6,0,8," " }) 	// "N�MERO DO DEALER"})
aAdd(aLayFG4, {"N",2,0,14," " }) 	// "TIPO DO REGISTRO"})
aAdd(aLayFG4, {"N",5,0,16," " }) 	// "N�MERO DA ORDEM DE SERVI�O"})
aAdd(aLayFG4, {"N",2,0,21," " }) 	// "C�DIGO DA REVIS�O"})
aAdd(aLayFG4, {"C",17,0,23," " }) 	// "N�MERO DO CHASSIS (VIN)"})
aAdd(aLayFG4, {"N",6,0,40," " }) 	// "N�MERO DO LAN�AMENTO CR�DITO/D�BITO"})
aAdd(aLayFG4, {"D",8,0,46," " }) 	// "DATA DO LAN�AMENTO CR�DITO/D�BITO (ddmmaaaa)"})
aAdd(aLayFG4, {"N",15,3,54," " }) 	// "VALOR A SER CREDITADO/DEBITADO (em Reais)"})
aAdd(aLayFG4, {"N",2,0,69," " }) 	// "TIPO DO REGISTRO"})
aAdd(aLayFG4, {"N",5,0,71," " }) 	// "N�MERO DA ORDEM DE SERVI�O"})
aAdd(aLayFG4, {"N",2,0,76," " }) 	// "C�DIGO DA REVIS�O"})
aAdd(aLayFG4, {"C",17,0,78," " }) 	// "N�MERO DO CHASSIS (VIN)"})
aAdd(aLayFG4, {"N",6,0,95," " }) 	// "N�MERO DO LAN�AMENTO CR�DITO/D�BITO"})
aAdd(aLayFG4, {"D",8,0,101," " }) 	// "DATA DO LAN�AMENTO CR�DITO/D�BITO"})
aAdd(aLayFG4, {"N",15,3,109," " }) 	// "VALOR A SER CREDITADO/DEBITADO"})
aAdd(aLayFG4, {"N",2,0,124," " }) 	// "TIPO DO REGISTRO"})
aAdd(aLayFG4, {"N",5,0,126," " }) 	// "N�MERO DA ORDEM DE SERVI�O"})
aAdd(aLayFG4, {"N",2,0,131," " }) 	// "C�DIGO DA REVIS�O"})
aAdd(aLayFG4, {"C",17,0,133," " }) 	// "N�MERO DO CHASSIS (VIN)"})
aAdd(aLayFG4, {"N",6,0,150," " }) 	// "N�MERO DO LAN�AMENTO CR�DITO/D�BITO"})
aAdd(aLayFG4, {"D",8,0,156," " }) 	// "DATA DO LAN�AMENTO CR�DITO/D�BITO"})
aAdd(aLayFG4, {"N",15,3,164," " }) 	// "VALOR A SER CREDITADO/DEBITADO"})
aAdd(aLayFG4, {"C",15,0,179," " }) 	// "BRANCOS"})
//
// PROCESSAMENTO DOS ARQUIVOS
//
aAdd(aArquivos,cArquivo)
// La�o em cada arquivo
for nCurArq := 1 to Len(aArquivos)
	// pega o pr�ximo arquivo
	cArquivo := Alltrim(aArquivos[nCurArq])
	//
	nPos = Len(cArquivo)
	if nPos = 0
		lAbort = .t.
		return
	endif
	// Processamento para Arquivos TXT planos
	FT_FUse( cArquivo )
	//
	FT_FGotop()
	if FT_FEof()
		loop
	endif
	//
	nTotRec := FT_FLastRec()
	//
	nLinhArq := 0
	While !FT_FEof()
		cStr := FT_FReadLN()
		nLinhArq++
		// Informa苺es extra�das da linha do arquivo de importa艫o ficam no vetor aInfo
		if Left(cStr,3)=="FG4"
			aInfo := ExtraiEDI(aLayFG4,cStr)
		endif
		// Trabalhar com aInfo gravando as informa苺es
		if Left(cStr,3)=="FG4"
			GrvInfo(aInfo)
		endif

		FT_FSkip()
	EndDo
	//
	FT_FUse()
next
//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun��o    | GrvInfo    | Autor | Luis Delorme          | Data | 17/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri��o | Processa o resultado da importa艫o                           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function GrvInfo(aInfo)
Local nCntFor
Titulo := STR0009
Cabec1 := STR0010
Cabec2 := " "
NomeProg := "OFINVW09"
// Realizar as atualiza苺es necess�rias a partir das informa苺es extra�das
// fazer verifica苺es de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
if li > 65
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li ++ ,1 psay " "
endif
//
for nCntFor := 4 to 18 STEP 7
	if !Empty(aInfo[nCntFor + 3])
		cTipReg := STR0001
		cTipReg := IIF(aInfo[nCntFor] == 5,STR0002,cTipReg)
		cTipReg := IIF(aInfo[nCntFor] == 6,STR0003,cTipReg)
		@ li++,1 psay dtoc(aInfo[nCntFor+5]) + SPACE(5) +;
		strzero(aInfo[nCntFor+4],6) + SPACE(5) +;
		strzero(aInfo[nCntFor+1],5) + SPACE(5) +;
		STRZERO(aInfo[nCntFor+2],2) + SPACE(5) +;
		aInfo[nCntFor+3] + SPACE(5) +;
		Transform(aInfo[nCntFor+6],"@E 999,999,999,99.999") + SPACE(5) + cTipReg
	endif
next
//
return
/*
樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛樛
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
臼浜様様様様冤様様様様様僕様様様冤様様様様様様様様様様様様曜様様様冤様様様様融臼
臼�Programa � ExtraiEDI � Autor � Luis Delorme             � Data � 26/03/13 艮�
臼麺様様様様慷様様様様様瞥様様様詫様様様様様様様様様様様様擁様様様詫様様様様郵臼
臼�Descricao� Monta vetores a partir de uma descri艫o de layout e da linha de艮�
臼�         � importa艫o EDI                                                 艮�
臼麺様様様様慷様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様郵臼
臼� Retorno � aRet - Valores extra�dos da linha                              艮�
臼�         �        Se der erro o vetor retorna {}                          艮�
臼麺様様様様慷様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様郵臼
臼�Parametro� aLayout[n,1] = Tipo do campo ([D]ata,[C]aracter ou [N]umerico) 艮�
臼�         � aLayout[n,2] = Tamanho do Campo                                艮�
臼�         � aLayout[n,3] = Quantidade de Decimais do Campo                 艮�
臼�         � aLayout[n,4] = Posi艫o Inicial do Campo na Linha               艮�
臼�         �                                                                艮�
臼�         � cLinhaEDI    = Linha para extra艫o das informa苺es             艮�
臼麺様様様様慷様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様郵臼
臼�                                                                          艮�
臼�  EXEMPLO DE PREENCHIMENTO DOS VETORES                                    艮�
臼�                                                                          艮�
臼�  aAdd(aLayout,{"C",10,0,1})                                              艮�
臼�  aAdd(aLayout,{"C",20,0,11})                                             艮�
臼�  aAdd(aLayout,{"N",5,2,31})                                              艮�
臼�  aAdd(aLayout,{"N",4,0,36})                                              艮�
臼�                        1         2         3                             艮�
臼�               123456789012345678901234567890'123456789                   艮�
臼�  cLinhaEDI = "Jose SilvaVendedor Externo    123121234                    艮�
臼�                                                                          艮�
臼�  No caso acima o retorno seria:                                          艮�
臼�  aRet[1] - "Jose Silva"                                                  艮�
臼�  aRet[2] - "Vendedor Externo"                                            艮�
臼�  aRet[3] - 123,12                                                        艮�
臼�  aRet[4] - 1234                                                          艮�
臼�                                                                          艮�
臼�                                                                          艮�
臼�                                                                          艮�
臼�                                                                          艮�
臼藩様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様夕臼
臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼臼
*/
Static Function ExtraiEDI(aLayout, cLinhaEDI)
Local aRet := {}
Local nCntFor, nCntFor2

for nCntFor = 1 to Len(aLayout)
	//
	cTipo := aLayout[nCntFor,1]
	nTamanho := aLayout[nCntFor,2]
	nDecimal := aLayout[nCntFor,3]
	nPosIni := aLayout[nCntFor,4]
	//
	if nPosIni + nTamanho - 1 > Len(cLinhaEDI)
		return {}
	endif
	cStrTexto := Subs(cLinhaEDI,nPosIni,nTamanho)
	ncValor := ""
	if Alltrim(cTipo) == "N"
		for nCntFor2 := 1 to Len(cStrTexto)
			if !(Subs(cStrTexto,nCntFor2,1)$"0123456789 ")
				return {}
			endif
		next
		ncValor = VAL(cStrTexto) / (10 ^ nDecimal)
	elseif Alltrim(cTipo) == "D"
		cStrTexto := Left(cStrTexto,2)+"/"+subs(cStrTexto,3,2)+"/"+Right(cStrTexto,4)
		if ctod(cStrTexto) == ctod("  /  /  ")
			ncValor := ctod(cStrTexto)
		endif
		ncValor := ctod(cStrTexto)
	else
		ncValor := cStrTexto
	endif
	aAdd(aRet, ncValor)
next

return aRet