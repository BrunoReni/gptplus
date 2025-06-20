// 浜様様様曜様様様様�
// � Versao � 6      �
// 藩様様様擁様様様様�

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "OFINVW28.ch"

#define STR0024 "REAPROVEITAR"
#define STR0025 "REAPROVEITAR"
#define STR0026 "REAPROVEITAR"
#define STR0027 "REAPROVEITAR"
#define STR0028 "REAPROVEITAR"
#define STR0029 "REAPROVEITAR"
#define STR0030 "REAPROVEITAR"
#define STR0031 "REAPROVEITAR"
#define STR0032 "REAPROVEITAR"
#define STR0033 "REAPROVEITAR"
#define STR0034 "REAPROVEITAR"
#define STR0035 "REAPROVEITAR"
#define STR0036 "REAPROVEITAR"
#define STR0037 "REAPROVEITAR"
#define STR0038 "REAPROVEITAR"
#define STR0039 "REAPROVEITAR"
#define STR0040 "REAPROVEITAR"
#define STR0041 "REAPROVEITAR"
#define STR0042 "REAPROVEITAR"
#define STR0043 "REAPROVEITAR"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun艫o    | OFINVW28   | Autor | Luis Delorme          | Data | 27/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri艫o | Importa艫o do Layout referente ao Informativo de NFs Cred/Deb|##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINVW28(lEnd, cArquivo)
//
Local nCurArq
//
Local aLayoutFN0 := {}
Local aLayoutFN1 := {}
Local aLayoutFN2 := {}
  
Private nAnt    := -1 
Private nValLiq := 0
Private nVlLq   := ""
Private nValIR  := 0
Private nVlIR   := ""
  
aAdd(aLayoutFN0, {"C",3,0,001," "}) //  "TIPO DE REGISTRO"})
aAdd(aLayoutFN0, {"N",2,0,004," "}) //   "SUB-C�DIGO DO REGISTRO"})
aAdd(aLayoutFN0, {"N",6,0,006," "}) //   "N�MERO DO DN"})
aAdd(aLayoutFN0, {"C",25,0,012," "}) //  "RAZ�O SOCIAL (NOME DO DN)"})
aAdd(aLayoutFN0, {"C",40,0,037," "}) //  "ENDERE�O"})
aAdd(aLayoutFN0, {"C",20,0,077," "}) //  "COMPLEMENTO DO ENDERE�O"})
aAdd(aLayoutFN0, {"C",30,0,097," "}) //  "CIDADE"})
aAdd(aLayoutFN0, {"C",2,0,127," "}) //   "ESTADO"})
aAdd(aLayoutFN0, {"C",8,0,129," "}) //   "CEP"})
aAdd(aLayoutFN0, {"C",51,0,137," "}) //  "BRANCOS"})
aAdd(aLayoutFN0, {"N",6,0,188," "}) //   "LAYOUT VERS�O"})

aAdd(aLayoutFN1, {"C",3,0,001," "}) //   "TIPO DE REGISTRO"})
aAdd(aLayoutFN1, {"N",2,0,004," "}) //   "SUB-C�DIGO DO REGISTRO"})
aAdd(aLayoutFN1, {"C",1,0,006," "}) //   "TIPO DE NOTA"})
aAdd(aLayoutFN1, {"C",25,0,007," "}) //  "NOME"})
aAdd(aLayoutFN1, {"C",18,0,032," "}) //  "CNPJ"})
aAdd(aLayoutFN1, {"C",18,0,050," "}) //  "INSCRI巴O ESTADUAL"})
aAdd(aLayoutFN1, {"C",50,0,068," "}) //  "ENDERE�O"})
aAdd(aLayoutFN1, {"N",6,0,118," "}) //  "N�MERO"})
aAdd(aLayoutFN1, {"N",4,0,124," "}) //  "S�RIE"})
aAdd(aLayoutFN1, {"D",6,0,128," "}) //  "DATA DE EMISS�O"})
aAdd(aLayoutFN1, {"D",6,0,134," "}) //  "DATA DO VENCIMENTO"})
aAdd(aLayoutFN1, {"C",25,0,140," "}) //  "NOME DO CONTATO"})
aAdd(aLayoutFN1, {"N",4,0,165," "}) //   "N�MERO DO SETOR"})
aAdd(aLayoutFN1, {"N",11,0,169," "}) //  "N�MERO DO TELEFONE"})
aAdd(aLayoutFN1, {"N",4,0,180," "}) //   "N�MERO DA CAIXA POSTAL INTERNA"})
aAdd(aLayoutFN1, {"C",10,0,184," "}) //  "BRANCOS"})

aAdd(aLayoutFN2, {"C",3,0,001," "}) //  "TIPO DE REGISTRO (FNT)"})
aAdd(aLayoutFN2, {"N",2,0,004," "}) //  "SUB-C�DIGO DO REGISTRO"})
aAdd(aLayoutFN2, {"C",188,0,006," "}) //  "DESCRI巴O DO HIST�RICO"})

aAdd(aIntCab,{STR0023,"C",145,"@!"})
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
		if Left(cStr,5)=="FNT00"
			aInfo := ExtraiEDI(aLayoutFN0,cStr)
		elseif Left(cStr,5)=="FNT01"
			aInfo := ExtraiEDI(aLayoutFN1,cStr)
		elseif Left(cStr,5)=="FNT02"
			aInfo := ExtraiEDI(aLayoutFN2,cStr)
		endif
		// Trabalhar com aInfo gravando as informa苺es
		if Left(cStr,5) $ "FNT00.FNT01.FNT02"
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
//
// Realizar as atualiza苺es necess�rias a partir das informa苺es extra�das
// fazer verifica苺es de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso
Local Tamanho := "P"
Titulo := STR0001
Cabec1 := " "
Cabec2 := ""
NomeProg := "OFINVW28"

if li > 60
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li ++ ,1 psay " "
endif
//
if Empty(aInfo)
	@li ++ ,1 psay cArquivo + STR0015 + Alltrim(STR(nLinhArq))
endif
//
if aInfo[2] == 0
	If li > 6 //Para sempre imprimir no inicio da pagina.
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	EndIf
	@li++ ,1 psay STR0009 + STRZERO(aInfo[3],6)
	@li++ ,1 psay STR0010 + Alltrim(aInfo[4])
	@li++ ,1 psay STR0011 + Alltrim(aInfo[5]) + " - " + Alltrim(aInfo[6])
	@li++ ,1 psay STR0012+Alltrim(aInfo[7]) + SPACE(9)+ STR0013 + Alltrim(aInfo[8])+"   "+STR0014+Transform(aInfo[9],"@R 99999-999")
	li++
elseif aInfo[2] == 1
	li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	@li ++ ,1 psay " "
	@li++ ,1 psay STR0008 + aInfo[3] + " - " + IIF(aInfo[3] == "C",STR0016,STR0017)
	li++
	@li++ ,1 psay STR0002 + Alltrim(aInfo[4])
	@li++ ,1 psay STR0003 + AllTrim(aInfo[5])
	@li++ ,1 psay STR0004 + Alltrim(aInfo[6])
	@li++ ,1 psay STR0005 + Alltrim(aInfo[7])
	@li++
	@li++ ,1 psay STR0018+Alltrim(STR(aInfo[8])) + " / " + Alltrim(STR(aInfo[9]))
	@li++ ,1 psay STR0006 + dtoc(aInfo[10])
	@li++ ,1 psay STR0007 + dtoc(aInfo[11])
	@li++
	@li++ ,1 psay STR0019 + Alltrim(aInfo[12])
	@li++ ,1 psay STR0020 + Alltrim(STR(aInfo[13]))
	@li++ ,1 psay STR0021 + AllTrim(STR(aInfo[14]))
	@li++ ,1 psay STR0022 + Alltrim(STR(aInfo[15]))
	@li++
elseif aInfo[2] == 2
	@li++ ,1 psay "    | "+Left(aInfo[3]+space(80),73) + "|"
endif
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
		cStrTexto := Left(cStrTexto,2)+"/"+subs(cStrTexto,3,2)+"/"+Right(cStrTexto,2)
		if ctod(cStrTexto) == ctod("  /  /  ")                         
			return {}
		endif
		ncValor := ctod(cStrTexto)
	else
		ncValor := cStrTexto
	endif

   if cTipo = "C"
	
		if "IR  SOBRE COMISSOES" $ ncValor
	
			lPriIR := .T.
			cPosIR := ""
			for nCntFor2 := 1 to Len(cStrTexto)
				if Subs(cStrTexto,nCntFor2,1)$"0123456789"
			   	if lPriIR
				   	cPosIR := nCntFor2
					   lPriIR := .F.
					endif   
					nVlIR += Subs(cStrTexto,nCntFor2,1)
				endif
			next                      
		
      	nValIR := VAL(nVlIR) / 100
      
		endif
	


   	if "TOTAL LIQUIDO" $ ncValor
   
			lPriTL := .T.
			cPosTL := ""
			for nCntFor2 := 1 to Len(cStrTexto)
				if Subs(cStrTexto,nCntFor2,1)$"0123456789"
			   	if lPriTL
				   	cPosTL := nCntFor2
					   lPriTL := .F.
					endif   
					nVlLq += Subs(cStrTexto,nCntFor2,1)
				endif
			next                      
		
      	nValLiq := VAL(nVlLq) / 100
   
	      nValLiq := nValLiq - nValIR
 
   	   ncValor := left(cStrTexto,cPosTL-1) + transform(nValLiq,"@E 999,999.99")
      
      	nValIR  := 0
	      nVlIR   := ""
   	   lPriIR  := .T.
   	   nValLiq :=0
   	   nVlLq   := "" 
     	   lPriTL  := .T.     
     	   
	   endif

   endif

	aAdd(aRet, ncValor)

next

return aRet
