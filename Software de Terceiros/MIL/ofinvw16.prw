// 浜様様様曜様様様様�
// � Versao � 3      �
// 藩様様様擁様様様様�

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW16.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun艫o    | OFINVW16   | Autor | Luis Delorme          | Data | 20/05/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri艫o | Importa艫o VW Assunto F10 - Dados Globais de Bordero         |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW16(lEnd, cArquivo)
//
Local nCurArq
//
Local aLayF1000 := {}
Local aLayF1001 := {}
Private cPedAnt := "inicial"
//
aAdd(aLayF1000, {"C",3,0,1,"TIPO DE REGISTRO (F10)"})
aAdd(aLayF1000, {"N",2,0,4,"SUBCODIGO DO REGISTRO (00)"})
aAdd(aLayF1000, {"C",6,0,6,"NUMERO DO DN"})
aAdd(aLayF1000, {"N",7,0,12,"NUMERO DO BORDERO"})
aAdd(aLayF1000, {"N",15,2,19,"VALOR TOTAL DO BORDERO"})
aAdd(aLayF1000, {"D",10,0,34,"DATA DO BORDERO (dd.mm.aaaa)"})
aAdd(aLayF1000, {"C",144,0,44,"BRANCOS"})
aAdd(aLayF1000, {"N",6,0,188,"DATA DA VERS�O (FIXO:110199)"})
//
aAdd(aLayF1001, {"C",3,0,1,"TIPO DE REGISTRO (F10)"})
aAdd(aLayF1001, {"N",2,0,4,"SUBCODIGO DO REGISTRO (01)"})
aAdd(aLayF1001, {"C",6,0,6,"NUMERO DO DN"})
aAdd(aLayF1001, {"N",7,0,12,"NUMERO DO BORDERO"})
aAdd(aLayF1001, {"C",6,0,19,"N�MERO DA NOTA FISCAL"})
aAdd(aLayF1001, {"N",15,2,25,"VALOR DA NOTA FISCAL"})
aAdd(aLayF1001, {"D",10,0,40,"DATA DA NOTA FISCAL (dd.mm.aaaa)"})
aAdd(aLayF1001, {"C",6,0,50,"N�MERO DA NOTA FISCAL"})
aAdd(aLayF1001, {"N",15,2,56,"VALOR DA NOTA FISCAL"})
aAdd(aLayF1001, {"D",10,0,71,"DATA DA NOTA FISCAL (dd.mm.aaaa)"})
aAdd(aLayF1001, {"C",6,0,81,"N�MERO DA NOTA FISCAL"})
aAdd(aLayF1001, {"N",15,2,87,"VALOR DA NOTA FISCAL"})
aAdd(aLayF1001, {"D",10,0,102,"DATA DA NOTA FISCAL (dd.mm.aaaa)"})
aAdd(aLayF1001, {"C",6,0,112,"N�MERO DA NOTA FISCAL"})
aAdd(aLayF1001, {"N",15,2,118,"VALOR DA NOTA FISCAL"})
aAdd(aLayF1001, {"D",10,0,133,"DATA DA NOTA FISCAL (dd.mm.aaaa)"})
aAdd(aLayF1001, {"C",6,0,143,"N�MERO DA NOTA FISCAL"})
aAdd(aLayF1001, {"N",15,2,149,"VALOR DA NOTA FISCAL"})
aAdd(aLayF1001, {"D",10,0,164,"DATA DA NOTA FISCAL (dd.mm.aaaa)"})
aAdd(aLayF1001, {"C",14,0,174,"BRANCOS"})
aAdd(aLayF1001, {"N",6,0,188,"DATA DA VERS�O (FIXO:110199)"})
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
		if Left(cStr,5) == "F1000"
			aInfo := ExtraiEDI(aLayF1000,cStr)
		endif
		if Left(cStr,5) == "F1001"
			aInfo := ExtraiEDI(aLayF1001,cStr)
		endif
		// Trabalhar com aInfo gravando as informa苺es
		if Left(cStr,5) $ "F1000.F1001"
			GrvInfo(aInfo)
		endif
		//
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
// Realizar as atualiza苺es necess�rias a partir das informa苺es extra�das
// fazer verifica苺es de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
if li > 55
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li++ ,1 psay " "
endif
//
if (aInfo[2] = 0)
	@li++ ,1 psay STR0001 + STRZERO(aInfo[4],7)
	@li++ ,1 psay STR0002 + dtoc(aInfo[6])
	@li++ ,1 psay STR0003 + AllTrim(Transform(aInfo[5],"@E 999,999,999,999.99"))
else
	for nCntFor := 5 to 17 step 3
		@li++ ,10 psay aInfo[nCntFor]+"   "+Transform(aInfo[nCntFor+1],"@E 999,999,999,999.99")+ "    " + dtoc(aInfo[nCntFor+2])
	next
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
臼�               123456789012345678901234567890123456789                    艮�
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
		cStrTexto := Left(cStrTexto,2)+"/"+subs(cStrTexto,4,2)+"/"+Right(cStrTexto,4)
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