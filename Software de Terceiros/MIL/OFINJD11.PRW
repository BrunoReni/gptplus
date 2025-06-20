// 浜様様様曜様様様様�
// � Versao � 002    �
// 藩様様様擁様様様様�

#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"   
#include "OFINJD11.CH"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun艫o    | OFINJD11   | Autor | Luis Delorme          | Data | 26/08/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri艫o |DPMSCHED - Importa艫o de Informa苺es de Agendam. de Extra苺es |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFINJD11()
//
Local cDesc1  := STR0001
Local cDesc2  := STR0002
Local cDesc3  := STR0003
Local aSay := {}
Local aButton := {}

Private cTitulo := STR0004
Private cPerg 	:= "" 
Private cNomRel := "OFINJD11"


Private cArquivo			// Nome do Arquivo a ser importado
Private aArquivos := {}		// Vetor de arquivos (para processamento m�ltiplo)
Private aLinErros := {}		// Linhas que ser�o apresentadas no relatorio de erros

Private cErrorXML := ""
Private cWarnXML := ""

Private cTProc := "TXT"		// TODO - Indica se o arquivo � texto plano ('TXT') ou XML ('XML')
Private lAbort := .t.

Private aIntCab := {} // Cabe�alhos da fun艫o FGX_VISINT
Private aIntIte := {} // Itens da fun艫o FGX_VISINT
//
CriaSX1()
//
aAdd( aSay, cDesc1 ) 
aAdd( aSay, cDesc2 ) 
aAdd( aSay, cDesc3 ) 
//
aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
//
while lAbort
	//
	lAbort := .f.
	nOpc := 0
	//
	FormBatch( cTitulo, aSay, aButton )
	//
	If nOpc <> 1
		Return
	Endif
	//
	Pergunte(cPerg,.f.)
	//
	RptStatus( {|lEnd| ImportArq(@lEnd)},STR0005,STR0006)
	//
	if !lAbort
		if Len(aLinErros) > 0
			RptStatus({|lEnd| ImprimeRel(@lEnd) },STR0005, STR0007, .T. )
		else
			FGX_VISINT(cNomRel , cTitulo , aIntCab , aIntIte , .f. )
		endif
		//
	endif
enddo
//
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun艫o    | ImportArq  | Autor | Luis Delorme          | Data | 16/08/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri艫o | Importa arquivo texto com os Pedidos de Pe�a                 |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
=============================================================================== \                             
*/
Static Function ImportArq()
//
Local nCurArq, nCntFor
//
Local aVetNome := {}
Local aVetTam := {}
Local aVetData := {}
Local aVetHora := {}
// 
Local aLayout := {}
//
if cTProc == "TXT"
	aAdd(aLayout, { "C", 2, 0, 1, " " } ) // "Type of Extract"} )
	aAdd(aLayout, { "C", 3,  0, 3, " " } ) // "Day of Week 1"} )
	aAdd(aLayout, { "C", 4, 0, 6, " " } ) // "Time of Day 1" } )
	aAdd(aLayout, { "C", 3,  0, 10, " " } ) // "Day of Week 2"} )
	aAdd(aLayout, { "C", 4, 0, 13, " " } ) // "Time of Day 2" } )
	aAdd(aLayout, { "C", 3,  0, 17, " " } ) // "Day of Week 3"} )
	aAdd(aLayout, { "C", 4, 0, 20, " " } ) // "Time of Day 3" } )
	aAdd(aLayout, { "C", 3,  0, 24, " " } ) // "Day of Week 4"} )
	aAdd(aLayout, { "C", 4, 0, 27, " " } ) // "Time of Day 4" } )
	aAdd(aLayout, { "C", 3,  0, 31, " " } ) // "Day of Week 5"} )
	aAdd(aLayout, { "C", 4, 0, 34, " " } ) // "Time of Day 5" } )
	aAdd(aLayout, { "C", 3,  0, 38, " " } ) // "Day of Week 6"} )
	aAdd(aLayout, { "C", 4, 0, 41, " " } ) // "Time of Day 6" } )
	aAdd(aLayout, { "C", 3,  0, 45, " " } ) // "Day of Week 7"} )
	aAdd(aLayout, { "C", 4, 0, 48, " " } ) // "Time of Day 7" } )
	aAdd(aLayout, { "C", 3,  0, 52, " " } ) // "Day of Week 8"} )
	aAdd(aLayout, { "C", 4, 0, 55, " " } ) // "Time of Day 8" } )
	//
	aAdd(aIntCab,{STR0020,aLayout[1,1],45,"@!"})
	aAdd(aIntCab,{STR0021,aLayout[2,1],55,"@!"})
	aAdd(aIntCab,{STR0022,aLayout[3,1],55,"@!"})
endif
// 
// PROCESSAMENTO DOS ARQUIVOS
//
// Para realizar processamentos m�ltiplos deve-se popular o vetor aArquivos. 
// Para processamentos de um s� arquivo pode-se usar o cGetFile
//
// Usando GetFile:
cArquivo := cGetFile( "JD2DLR_DPMSCHED*.*" , STR0008, 1, , .F., ,.T., .T. ) // TODO - Verificar par�metros do cGetFile
aAdd(aArquivos,cArquivo)
//
// La�o em cada arquivo
for nCurArq := 1 to Len(aArquivos)
	// pega o pr�ximo arquivo
	cArquivo := Alltrim(aArquivos[nCurArq])
	// Se o usu�rio clicar no X no cGetFile ent�o cArquivo fica vazio e devemos abortar o processo
	nPos = Len(cArquivo)
	if nPos = 0
		lAbort = .t.
		return
	endif
	// verifica exist�ncia do arquivo somente para garantia
	if !File(cArquivo)
		aAdd(aLinErros,STR0009 + cArquivo + STR0010)
		loop
	endif
	// extrai  diret�rio e verifica se ele j� foi processado e est� no salva
	while nPos != 0 .and. Subs(cArquivo,nPos,1) != "\" 
		nPos--
	enddo
	cDir := Subs(cArquivo,1,nPos)
	cArq := Subs(cArquivo,nPos+1)
	if aDir( cDir + "SALVA\" + cArq , aVetNome, aVetTam, aVetData, aVetHora) > 0
		if !MsgYesNo(STR0009+cArquivo+STR0011,STR0012)
			loop
		endif
	endif	
	// Processamento para Arquivos TXT planos
	FT_FUse( cArquivo )
	//
	FT_FGotop()
	if FT_FEof()
		aAdd(aLinErros,STR0009 + cArquivo + STR0013)
		loop
	endif
	//
	nTotRec := FT_FLastRec() 
	SetRegua(nTotRec)
	//
	nLinhArq := 0
	While !FT_FEof() 
		//
		cStr := FT_FReadLN()
		nLinhArq++
		//			
		IncRegua()
		// Informa苺es extra�das da linha do arquivo de importa艫o ficam no vetor aInfo
		aInfo := ExtraiEDI(aLayout,cStr)
		// Trabalhar com aInfo gravando as informa苺es
		if Empty(aInfo)
			aAdd(aLinErros, cArquivo + STR0014 + Alltrim(STR(nLinhArq) ))
		else
			GrvInfo(aInfo)
		endif
		FT_FSkip()
	EndDo
	//
	FT_FUse()
next
//
DBSelectArea("VQ5")
If TCCanOpen(RetSqlName("VQ5"))
	cString := "DELETE FROM " + RetSqlName("VQ5")
	TCSqlExec(cString)
endif
//
lCriaIni := .f.
for nCntFor := 1 to Len(aIntIte)
	if Alltrim(aIntIte[nCntFor,1]) != "D"
		lCriaIni := .t.
	endif
	cDia :="T"
	cDia := IIF(Alltrim(aIntIte[nCntFor,2]) == STR0023,"D",cDia)
	cDia := IIF(Alltrim(aIntIte[nCntFor,2]) == STR0024,"2",cDia)
	cDia := IIF(Alltrim(aIntIte[nCntFor,2]) == STR0025,"3",cDia)
	cDia := IIF(Alltrim(aIntIte[nCntFor,2]) == STR0026,"4",cDia)
	cDia := IIF(Alltrim(aIntIte[nCntFor,2]) == STR0027,"5",cDia)
	cDia := IIF(Alltrim(aIntIte[nCntFor,2]) == STR0028,"6",cDia)
	cDia := IIF(Alltrim(aIntIte[nCntFor,2]) == STR0029,"S",cDia)
	//
	reclock("VQ5",.t.)
	VQ5->VQ5_FILIAL := xFilial("VQ5")
	VQ5->VQ5_CODIGO := STRZERO(nCntFor,6)
	VQ5->VQ5_DIA := cDia
	VQ5->VQ5_HORA := Left(aIntIte[nCntFor,3],2)+Right(aIntIte[nCntFor,3],2)
	VQ5->VQ5_TIPO := "D"
	msunlock()
	//
next
if lCriaIni
	reclock("VQ5",.t.)
	VQ5->VQ5_FILIAL := xFilial("VQ5")
	VQ5->VQ5_CODIGO := STRZERO(0,6)
	msunlock()
endif
//
//#############################################################################
//# Move o arquivo para o diretorio SALVA                                     #
//#############################################################################
if Len(aLinErros) == 0
	OJD19LOG("DPMSCHED", STR0030)
	for nCurArq := 1 to Len(aArquivos)
		cArquivo := Alltrim(aArquivos[nCurArq])
		Copy File &(cArquivo) to &(cDir + "SALVA\" + cArq)
		Dele File &(cArquivo)
	next
else
	MsgInfo(STR0016,STR0012)
	return
endif
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
Function ONJD11CWF()

DBSelectArea("VQ5")
DBSetOrder(1)
DBSeek(xFilial("VQ5"))
if eof() 
	return
endif

if Val(VQ5->VQ5_CODIGO) == 0
	reclock("VQ5",.f.,.t.)
	dbdelete()
	msunlock()
	OFINJD06(.t., "I")
	return
endif

dDOW := DOW(DDATABASE)

cDow := ""
cDow := IIF(dDow == 1,"D",cDow)
cDow := IIF(dDow == 2,"2",cDow)
cDow := IIF(dDow == 3,"3",cDow)
cDow := IIF(dDow == 4,"4",cDow)
cDow := IIF(dDow == 5,"5",cDow)
cDow := IIF(dDow == 6,"6",cDow)
cDow := IIF(dDow == 7,"S",cDow)

cTimeAtu := Left(Time(),2) + Subs(Time(),4,2)

while xFilial("VQ5") == VQ5->VQ5_FILIAL
	if (cDow == VQ5->VQ5_DIA .or. VQ5->VQ5_DIA == "T") .and. VQ5->VQ5_DIAULT != ddatabase .and. cTimeAtu > VQ5->VQ5_HORA
		reclock("VQ5",.f.)
		VQ5->VQ5_DIAULT := ddatabase
		msunlock()
		OFINJD06(.t., "D")
		return
	endif
	DBSkip()
enddo

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
Local nCntFor

cTipo := aInfo[1]
for nCntFor := 2 to 16 step 2
	if aInfo[nCntFor] $ "All|Su |M  |T  |W  |Th |F  |S  "
		cDia :="TODOS"
		cDia := IIF(Alltrim(aInfo[nCntFor])=="Su",STR0023,cDia)
		cDia := IIF(Alltrim(aInfo[nCntFor])=="M",STR0024,cDia)
		cDia := IIF(Alltrim(aInfo[nCntFor])=="T",STR0025,cDia)
		cDia := IIF(Alltrim(aInfo[nCntFor])=="W",STR0026,cDia)
		cDia := IIF(Alltrim(aInfo[nCntFor])=="Th",STR0027,cDia)
		cDia := IIF(Alltrim(aInfo[nCntFor])=="F",STR0028,cDia)
		cDia := IIF(Alltrim(aInfo[nCntFor])=="S",STR0029,cDia)
		aAdd(aIntIte,{cTipo,cDia, Left(aInfo[nCntFor + 1],2)+":"+Right(aInfo[nCntFor + 1],2)})
	endif
next
//
return                                                                                                  '
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun��o    | ImprimeRel | Autor | Luis Delorme          | Data | 27/03/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri��o | Imprime o relat�rio de erros                                 |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ImprimeRel()

Local nCntFor

Local cDesc1  := STR0019
Local cDesc2  := ""
Local cDesc3  := ""

Private cString  := ""
Private Tamanho  := "M"
Private aReturn  := { "Zebrado",2,"Administracao",2,2,1,"",1 }
Private wnrel    := "ERROSEDI" // TODO
Private NomeProg := "ERROSEDI" // TODO
Private nLastKey := 0
Private Limite   := 132
Private Titulo   := cTitulo+" ("+cArquivo+")"+" - " + dtoc(ddatabase)
Private nTipo    := 0
Private cbCont   := 0
Private cbTxt    := " "
Private Li       := 80
Private m_pag    := 1
Private aOrd     := {}
Private Cabec1   := " "
Private Cabec2   := " "
Private cPerg := ""
//+-------------------------------------------------------------------------------
//| Solicita ao usuario a parametrizacao do relatorio.
//+-------------------------------------------------------------------------------
wnrel := SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,.F.,.F.)
//+-------------------------------------------------------------------------------
//| Se teclar ESC, sair
//+-------------------------------------------------------------------------------
If nLastKey == 27
	Return
Endif
//+-------------------------------------------------------------------------------
//| Estabelece os padroes para impressao, conforme escolha do usuario
//+-------------------------------------------------------------------------------
SetDefault(aReturn,cString)
//+-------------------------------------------------------------------------------
//| Verificar se sera reduzido ou normal
//+-------------------------------------------------------------------------------
nTipo := Iif(aReturn[4] == 1, 15, 18)
//+-------------------------------------------------------------------------------
//| Se teclar ESC, sair
//+-------------------------------------------------------------------------------
If nLastKey == 27
	Return
Endif
//+-------------------------------------------------------------------------------
//| Chama funcao que processa os dados
//+-------------------------------------------------------------------------------
for nCntFor = 1 to Len(aLinErros)
	
	If Li > 55
		li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		li++
	Endif
	//
	@ Li++, 1   PSay aLinErros[nCntFor]
	//+-------------------------------------------------------------------------------
	//| Se teclar ESC, sair
	//+-------------------------------------------------------------------------------
	If nLastKey == 27
		@ Li++ , 1 psay STR0017
		exit
	Endif
next
//
If Li <> 80
	Roda(cbCont,cbTxt,Tamanho)
Endif
//
If aReturn[5] == 1
	Set Printer TO
	dbCommitAll()
	OurSpool(wnrel)
EndIf
//
Ms_Flush()
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

cLinhaEDI := cLinhaEDI + space(1000)

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

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun艫o    | CriaSX1    | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function CriaSX1()
Local aSX1    := {}
Local aEstrut := {}
Local i       := 0
Local j       := 0
Local lSX1	  := .F.

if cPerg == ""
	return 
endif

aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME"}

//敖陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳朕
//� aAdd a Pergunta                                              �
//青陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳陳潰
// TODO
// aAdd(aSX1,{cPerg,"01","Par�metro 1","","","MV_CH1","C",40,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"})
// aAdd(aSX1,{cPerg,"02","Par�metro 2","","","MV_CH2","C",40,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"})
// aAdd(aSX1,{cPerg,"03","Par�metro 3","","","MV_CH3","C",40,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S"})

ProcRegua(Len(aSX1))

dbSelectArea("SX1")
dbSetOrder(1)
For i:= 1 To Len(aSX1)
	If !Empty(aSX1[i][1])
		If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
			IncProc(STR0018)
			lSX1 := .T.
			RecLock("SX1",.T.)
			For j:=1 To Len(aSX1[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
				EndIf
			Next j
			dbCommit()
			MsUnLock()
		EndIf
	EndIf
Next i

return
