// 浜様様様曜様様様様�
// � Versao � 3      �
// 藩様様様擁様様様様�

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW06.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun艫o    | OFINVW06   | Autor | Luis Delorme          | Data | 20/05/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri艫o | Importa艫o VW Assunto FG1 - SGs Erradas - G & AT             |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW06(lEnd, cArquivo)
//
Local nCurArq
//
Local aLayFG1 := {}
//
aAdd(aLayFG1, {"C",3,0,1," " }) 	// "TIPO DE REGISTRO (FG1)"})
aAdd(aLayFG1, {"C",4,0,4," " }) 	// "SUBC�DIGO DO REGISTRO (Fixo:Comu)"})
aAdd(aLayFG1, {"N",6,0,8," " }) 	// "N�MERO DO DEALER (00dndn)"})
aAdd(aLayFG1, {"N",2,0,14," " }) 	// "TIPO DO REGISTRO (Fixo:01 SG's Erradas)"})
aAdd(aLayFG1, {"N",5,0,16," " }) 	// "N�MERO DA ORDEM DE SERVI�O"})
aAdd(aLayFG1, {"C",3,0,21," " }) 	// "C�DIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,24," " }) 	// "C�DIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,25," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,27," " }) 	// "C�DIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,30," " }) 	// "C�DIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,31," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,33," " }) 	// "C�DIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,36," " }) 	// "C�DIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,37," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,39," " }) 	// "C�DIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,42," " }) 	// "C�DIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,43," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,45," " }) 	// "C�DIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,48," " }) 	// "C�DIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,49," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,51," " }) 	// "C�DIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,54," " }) 	// "C�DIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,55," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,57," " }) 	// "C�DIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,60," " }) 	// "C�DIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,61," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,63," " }) 	// "C�DIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,66," " }) 	// "C�DIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,67," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,69," " }) 	// "C�DIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,72," " }) 	// "C�DIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,73," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,75," " }) 	// "C�DIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,78," " }) 	// "C�DIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,79," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,81," " }) 	// "C�DIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,84," " }) 	// "C�DIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,85," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,87," " }) 	// "C�DIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,90," " }) 	// "C�DIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,91," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,93," " }) 	// "C�DIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,96," " }) 	// "C�DIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,97," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,99," " }) 	// "C�DIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,102," " }) 	// "C�DIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,103," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,105," " }) 	// "C�DIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,108," " }) 	// "C�DIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,109," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,111," " }) 	// "C�DIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,114," " }) 	// "C�DIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,115," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,117," " }) 	// "C�DIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,120," " }) 	// "C�DIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,121," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,123," " }) 	// "C�DIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,126," " }) 	// "C�DIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,127," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,129," " }) 	// "C�DIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,132," " }) 	// "C�DIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,133," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",3,0,135," " }) 	// "C�DIGO DA MENSAGEM DE ERRO"})
aAdd(aLayFG1, {"N",1,0,138," " }) 	// "C�DIGO DO REGISTRO"})
aAdd(aLayFG1, {"C",2,0,139," " }) 	// "LINHA"})
aAdd(aLayFG1, {"C",53,0,141," " }) 	// "BRANCOS"})
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
		if Left(cStr,3)=="FG1"
			aInfo := ExtraiEDI(aLayFG1,cStr)
		endif
		// Trabalhar com aInfo gravando as informa苺es
		if Left(cStr,3) $ "FG1"
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
// Realizar as atualiza苺es necess�rias a partir das informa苺es extra�das
// fazer verifica苺es de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
Titulo := STR0004
Cabec1 := STR0005
Cabec2 := " "
NomeProg := "OFINVW06"

if li > 80
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li ++ ,1 psay " "
endif
//
if Empty(aInfo)
	@li ++ ,1 psay cArquivo + STR0001 + Alltrim(STR(nLinhArq))
endif
//

for nCntFor := 6 to 63 STEP 3
	if !Empty(aInfo[nCntFor])
		@li ++ ,1 psay STRZERO(aInfo[5],5) + space(10) +aInfo[nCntFor] + space(10)+STRZERO(aInfo[nCntFor + 1],1)+space(10) + aInfo[nCntFor + 2]
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
		if ctod(cStrTexto) == ctod("  /  /  ")
			return {}
		endif
		ncValor := ctod(cStrTexto)
	else
		ncValor := cStrTexto
	endif
	aAdd(aRet, ncValor)
next

return aRet