// 浜様様様曜様様様様�
// � Versao � 4      �
// 藩様様様擁様様様様�

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW27.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun艫o    | OFINVW27   | Autor | Thiago                | Data | 01/04/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri艫o | FA4 - Extrato Conta Corrente Di�rio.                         |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW27(lEnd, cArquivo)
//
Local nCurArq
//
//
Local aLayoutFA4 := {}
//
aInfo := {}
//
aAdd(aLayoutFA4, { "C", 3 , 0, 001," "}) //  "TIPO DE REGISTRO (FA4)" })
aAdd(aLayoutFA4, { "C", 4 , 0, 004," "}) //   "TIPO DE DOCUMENTO" })
aAdd(aLayoutFA4, { "C", 40, 0, 008," "}) //   "DESCRI巴O DO TIPO DO DOCUMENTO" })
aAdd(aLayoutFA4, { "C", 10, 0, 048," "}) //   "N�MERO DO DOCUMENTO" })
aAdd(aLayoutFA4, { "D",  8, 0, 058," "}) //   "DATA DO LAN�AMENTO" })
aAdd(aLayoutFA4, { "C",  1, 0, 066," "}) //   "CR�DITO=C  ou  D�BITO=D" })
aAdd(aLayoutFA4, { "N", 15, 2, 067," "}) //   "VALOR DO LAN�AMENTO" })
aAdd(aLayoutFA4, { "C",  4, 0, 082," "}) //   "TIPO DO DOCUMENTO" })
aAdd(aLayoutFA4, { "C", 40, 0, 086," "}) //   "DESCRI巴O DO TIPO DO DOCUMENTO" })
aAdd(aLayoutFA4, { "C", 10, 0, 126," "}) //  "N�MERO DO DOCUMENTO" })
aAdd(aLayoutFA4, { "D",  8, 0, 136," "}) //   "DATA DO LAN�AMENTO" })
aAdd(aLayoutFA4, { "C",  1, 0, 144," "}) //   "CR�DITO=C  ou  D�BITO=D" })
aAdd(aLayoutFA4, { "N", 15, 2, 145," "}) //   "VALOR DO LAN�AMENTO" })
aAdd(aLayoutFA4, { "C", 28, 0, 160," "}) //   "BRANCOS" })
aAdd(aLayoutFA4, { "N",  6, 0, 188," "}) //   "VERS�O DO LAYOUT" })
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
		if Left(cStr,3)=="FA4"
			aInfo := ExtraiEDI(aLayoutFA4,cStr)
		endif
		// Trabalhar com aInfo gravando as informa苺es
		if Left(cStr,3)=="FA4"
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
##|Fun��o    | ImprimeRel | Autor | Luis Delorme          | Data | 17/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri��o | Processa o resultado da importa艫o                           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function GrvInfo(aInfo)
//
// Realizar as atualiza苺es necess�rias a partir das informa苺es extra�das
// fazer verifica苺es de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
//
Titulo := STR0029
Cabec1 := STR0030
Cabec2 := ""
NomeProg := "OFINVW27"
if li > 50
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li ++ ,1 psay " "
endif
//
if Empty(aInfo)
	@li ++ ,1 psay cArquivo + STR0020 + Alltrim(STR(nLinhArq))
	return
endif

cData := dtoc(aInfo[5])
cDt := dtoc(aInfo[11])

@li++ ,1 psay cData + space(5) + aInfo[4] +  space(5) + aInfo[2] + space(4) + aInfo[3] + space(4) + IIF(aInfo[6]=="C", Transform(aInfo[7], "@E 999,999,999,999.99") ,SPACE(18) ) + space(4) +  IIF(aInfo[6]=="D", Transform(aInfo[7], "@E 999,999,999,999.99") ,SPACE(18) )

if li > 50
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li ++ ,1 psay " "
endif
//
if !Empty(aInfo[8])
	@li++ ,1 psay cDt + space(5) + aInfo[10] +  space(5) + aInfo[8] + space(4) + aInfo[9] + space(4) + IIF(aInfo[12]=="C", Transform(aInfo[13], "@E 999,999,999,999.99") ,SPACE(18) ) + space(4) + IIF(aInfo[12]=="D", Transform(aInfo[13], "@E 999,999,999,999.99") ,SPACE(18) )
endif
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
臼�               123456789012345678901234567890'123456789                    艮�
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
//		if ctod(cStrTexto) == ctod("  /  /  ")
//			return {}    
//		endif
		ncValor := ctod(cStrTexto)
	else
		ncValor := cStrTexto
	endif
	aAdd(aRet, ncValor)
next

return aRet
