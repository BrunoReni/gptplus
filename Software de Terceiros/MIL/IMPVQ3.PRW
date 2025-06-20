#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"

#define STR0001 "Descri��o 1" 		// TODO - Descri��o do FormBatch
#define STR0002 "Descri��o 2" 		// TODO - Descri��o do FormBatch
#define STR0003 "Descri��o 3" 		// TODO - Descri��o do FormBatch
#define STR0004 "Titulo" 			// TODO - Titulo do Assunto (Vai no relat�rio e FormBatch)
#define STR0005 "Aguarde..."
#define STR0006 "Importando arquivo texto."
#define STR0007 "Imprimindo relat�rio de erros."
#define STR0008 "Textos (TXT)"
#define STR0009 "O arquivo '"
#define STR0010 "' n�o foi encontrado."
#define STR0011 "' j� foi processado anteriormente. Deseja reprocessar?"
#define STR0012 "Aten��o"
#define STR0013 "' est� vazio. Nenhum Registro foi importado."
#define STR0014 " - ERRO NA LEITURA DA LINHA "
#define STR0015 " - ERRO NA LEITURA DO XML "
#define STR0016 "Foram encontrados erros durante a importa��o."
#define STR0017 "... ABORTADO PELO OPERADOR."
#define STR0018 "Atualizando Perguntas (SX1)..."
#define STR0019 "Relat�rio de Erros"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun��o    | IMPVQ3     | Autor | MIL                   | Data | 12/08/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri��o | Importa��o do Arquivo para o VQ3 (FERRAMENTA DE MIGRACAO)    |##
##+----------+--------------------------------------------------------------+##
##|Uso       | M I G R A C A O   A P E N A S ! ! ! ! ! ! ! ! ! !            |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function IMPVQ3()
//
Local cDesc1  := "Importa��o do VQ3 para migra��o."
Local cDesc2  := " "
Local cDesc3  := " "
Local aSay := {}
Local aButton := {}
Local nCntFor 
              
Private lB5ADDED := (SB5->(FieldPos("B5_DTADDED")) > 0 )
Private lB1GROUPC := (SB1->(FieldPos("B1_GROUPC")) > 0 )
Private cTitulo := "Importa��o VQ3 Migra��o John Deere"
Private cPerg 	:= "IMPVQ3"
Private cNomRel := ""
Private nContFil := 0
Private cDadosProd:= GetNewPar("MV_MIL0054","SBZ")

Private nTamFil := Len(xFilial("SD1"))
Private nTamFilTot := FWSizeFilial()

Private cArquivo			// Nome do Arquivo a ser importado
Private aArquivos := {}		// Vetor de arquivos (para processamento m�ltiplo)
Private aLinErros := {}		// Linhas que ser�o apresentadas no relatorio de erros

Private cErrorXML := ""
Private cWarnXML := ""

Private cTProc := "TXT"	
Private lAbort := .t.

Private aIntCab := {} // Cabe�alhos da fun��o FGX_VISINT
Private aIntIte := {} // Itens da fun��o FGX_VISINT

Private cX2ModoSB5 := "C"

If FWAliasInDic("SB5")
	cX2ModoSB5 := FWModeAccess("SB5",3)
Endif

if Alltrim(cDadosProd) != "SBZ" .and. cX2ModoSB5 == "C"
	MsgStop("SBZ/SB5 incompativeis")
	return .f.
endif

//
// Realizar as atualiza��es necess�rias a partir das informa��es extra�das
// fazer verifica��es de erro e atualizar o vetor aIntIte ou aLinErros conforme
// o caso

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
	FormBatch( cTitulo+" v2", aSay, aButton )
	//
	If nOpc <> 1
		Return
	Endif
	//
	Pergunte(cPerg,.f.)
	//
	RptStatus( {|lEnd| ImportArq(@lEnd)},"Aguarde...","Importando arquivo texto.")
	//
	if !lAbort
		if Len(aLinErros) > 0
			RptStatus({|lEnd| ImprimeRel(@lEnd) },"Aguarde...", "Imprimindo relat�rio de erros.", .T. )
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
##|Fun��o    | ImportArq  | Autor |                       | Data |          |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri��o |                                                              |##
##+----------+--------------------------------------------------------------+##
##|Uso       |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function ImportArq()
//
Local nCurArq
//
Local aVetNome := {}
Local aVetTam := {}
Local aVetData := {}
Local aVetHora := {}
// 
Local aLayout1 := {}
//
DBSelectArea("SB1")
DBSetOrder(1)
//
if cTProc == "TXT"
	aAdd(aLayout1, {'C',3, 0, 1}) //1
	aAdd(aLayout1, {'C',18, 0, 4})//2
	aAdd(aLayout1, {'N',6, 2, 22})//3
	aAdd(aLayout1, {'N',6, 2, 28})//4
	aAdd(aLayout1, {'N',6, 2, 34})//5
	aAdd(aLayout1, {'N',6, 2, 40})//6
	aAdd(aLayout1, {'N',6, 2, 46})//7
	aAdd(aLayout1, {'N',6, 0, 52})//8
	aAdd(aLayout1, {'N',6, 2, 58})//9
	aAdd(aLayout1, {'N',6, 0, 64})//10
	aAdd(aLayout1, {'N',6, 2, 70})//11
	aAdd(aLayout1, {'C',12, 0, 76})//12
	aAdd(aLayout1, {'C',12, 0, 88})//13
	aAdd(aLayout1, {'N',13, 4, 100})//14
	aAdd(aLayout1, {'N',5, 0, 113})//15
	aAdd(aLayout1, {'C',20, 0, 118})//16
	aAdd(aLayout1, {'C',100, 0, 138})//17
	aAdd(aLayout1, {'C',1, 0, 238})//18
	aAdd(aLayout1, {'N',3, 3, 239})//19
	aAdd(aLayout1, {'N',13, 4, 242})//20
	aAdd(aLayout1, {'C',3, 0, 255})//21
	aAdd(aLayout1, {'C',1, 0, 258})//22

	aAdd(aLayout1, {'N', 6, 0, 259}) //<<<<<<<<<<------ VERSAO 1 | 23
	aAdd(aLayout1, {'N', 6, 0, 265}) //<<<<<<<<<<------ VERSAO 1 | 24
	aAdd(aLayout1, {'N',13, 4, 265}) //<<<<<<<<<<------ VERSAO 1.3 | 25

	aAdd(aLayout1, {'C',3, 0, 271})//23
	aAdd(aLayout1, {'C',100, 0, 274})//24
	aAdd(aLayout1, {'C',250, 0, 374})//25
	aAdd(aLayout1, {'C',4, 0, 624})//26
	aAdd(aLayout1, {'C',10, 0, 628})//27
	aAdd(aLayout1, {'C',20, 0, 638})//28
	aAdd(aLayout1, {'N',6, 2, 658})//29 
	aAdd(aLayout1, {'N',6, 2, 664})//30
	aAdd(aLayout1, {'N',2, 0, 666})//31
	aAdd(aLayout1, {'N',6, 0, 672})//32
	// mes 1
	aAdd(aLayout1, {'N',6, 2,678})
	aAdd(aLayout1, {'N',6, 0,684})
	aAdd(aLayout1, {'N',6, 2,690})
	aAdd(aLayout1, {'N',6, 0,696})
	// mes 2
	aAdd(aLayout1, {'N',6, 2,702})
	aAdd(aLayout1, {'N',6, 0,708})
	aAdd(aLayout1, {'N',6, 2,714})
	aAdd(aLayout1, {'N',6, 0,720})
	// mes 3
	aAdd(aLayout1, {'N',6, 2,726})
	aAdd(aLayout1, {'N',6, 0,732})
	aAdd(aLayout1, {'N',6, 2,738})
	aAdd(aLayout1, {'N',6, 0,744})
	// mes 4
	aAdd(aLayout1, {'N',6, 2,750})
	aAdd(aLayout1, {'N',6, 0,756})
	aAdd(aLayout1, {'N',6, 2,762})
	aAdd(aLayout1, {'N',6, 0,768})
	// mes 5
	aAdd(aLayout1, {'N',6, 2,774})
	aAdd(aLayout1, {'N',6, 0,780})
	aAdd(aLayout1, {'N',6, 2,786})
	aAdd(aLayout1, {'N',6, 0,792})
	// mes 6
	aAdd(aLayout1, {'N',6, 2,798})
	aAdd(aLayout1, {'N',6, 0,804})
	aAdd(aLayout1, {'N',6, 2,810})
	aAdd(aLayout1, {'N',6, 0,816})
	// mes 7
	aAdd(aLayout1, {'N',6, 2,822})
	aAdd(aLayout1, {'N',6, 0,828})
	aAdd(aLayout1, {'N',6, 2,834})
	aAdd(aLayout1, {'N',6, 0,840})
	// mes 8
	aAdd(aLayout1, {'N',6, 2,846})
	aAdd(aLayout1, {'N',6, 0,853})
	aAdd(aLayout1, {'N',6, 2,858})
	aAdd(aLayout1, {'N',6, 0,864})
	// mes 9
	aAdd(aLayout1, {'N',6, 2,870})
	aAdd(aLayout1, {'N',6, 0,876})
	aAdd(aLayout1, {'N',6, 2,882})
	aAdd(aLayout1, {'N',6, 0,888})
	// mes 10
	aAdd(aLayout1, {'N',6, 2,894})
	aAdd(aLayout1, {'N',6, 0,900})
	aAdd(aLayout1, {'N',6, 2,906})
	aAdd(aLayout1, {'N',6, 0,912})
	// mes 11
	aAdd(aLayout1, {'N',6, 2,918})
	aAdd(aLayout1, {'N',6, 0,924})
	aAdd(aLayout1, {'N',6, 2,930})
	aAdd(aLayout1, {'N',6, 0,936})
	// mes 12
	aAdd(aLayout1, {'N',6, 2,942})
	aAdd(aLayout1, {'N',6, 0,948})
	aAdd(aLayout1, {'N',6, 2,954})
	aAdd(aLayout1, {'N',6, 0,960})
	// mes 13
	aAdd(aLayout1, {'N',6, 2,966})
	aAdd(aLayout1, {'N',6, 0,972})
	aAdd(aLayout1, {'N',6, 2,978})
	aAdd(aLayout1, {'N',6, 0,984})
	// mes 14
	aAdd(aLayout1, {'N',6, 2,990})
	aAdd(aLayout1, {'N',6, 0,996})
	aAdd(aLayout1, {'N',6, 2,1002})
	aAdd(aLayout1, {'N',6, 0,1008})
	// mes 15
	aAdd(aLayout1, {'N',6, 2,1014})
	aAdd(aLayout1, {'N',6, 0,1020})
	aAdd(aLayout1, {'N',6, 2,1026})
	aAdd(aLayout1, {'N',6, 0,1032})
	// mes 16
	aAdd(aLayout1, {'N',6, 2,1038})
	aAdd(aLayout1, {'N',6, 0,1044})
	aAdd(aLayout1, {'N',6, 2,1050})
	aAdd(aLayout1, {'N',6, 0,1056})
	// mes 17
	aAdd(aLayout1, {'N',6, 2,1062})
	aAdd(aLayout1, {'N',6, 0,1070})
	aAdd(aLayout1, {'N',6, 2,1074})
	aAdd(aLayout1, {'N',6, 0,1080})
	// mes 18
	aAdd(aLayout1, {'N',6, 2,1086})
	aAdd(aLayout1, {'N',6, 0,1092})
	aAdd(aLayout1, {'N',6, 2,1098})
	aAdd(aLayout1, {'N',6, 0,1104})
	// mes 19
	aAdd(aLayout1, {'N',6, 2,1110})
	aAdd(aLayout1, {'N',6, 0,1116})
	aAdd(aLayout1, {'N',6, 2,1122})
	aAdd(aLayout1, {'N',6, 0,1128})
	// mes 20
	aAdd(aLayout1, {'N',6, 2,1134})
	aAdd(aLayout1, {'N',6, 0,1140})
	aAdd(aLayout1, {'N',6, 2,1146})
	aAdd(aLayout1, {'N',6, 0,1152})
	// mes 21
	aAdd(aLayout1, {'N',6, 2,1158})
	aAdd(aLayout1, {'N',6, 0,1164})
	aAdd(aLayout1, {'N',6, 2,1170})
	aAdd(aLayout1, {'N',6, 0,1176})
	// mes 22
	aAdd(aLayout1, {'N',6, 2,1182})
	aAdd(aLayout1, {'N',6, 0,1188})
	aAdd(aLayout1, {'N',6, 2,1194})
	aAdd(aLayout1, {'N',6, 0,1200})
	// mes 23
	aAdd(aLayout1, {'N',6, 2,1206})
	aAdd(aLayout1, {'N',6, 0,1212})
	aAdd(aLayout1, {'N',6, 2,1218})
	aAdd(aLayout1, {'N',6, 0,1224})
	// mes 24
	aAdd(aLayout1, {'N',6, 2,1230})
	aAdd(aLayout1, {'N',6, 0,1236})
	aAdd(aLayout1, {'N',6, 2,1242})
	aAdd(aLayout1, {'N',6, 0,1248})
	// mes 25
	aAdd(aLayout1, {'N',6, 2,1254})
	aAdd(aLayout1, {'N',6, 0,1260})
	aAdd(aLayout1, {'N',6, 2,1266})
	aAdd(aLayout1, {'N',6, 0,1272})
	// mes 26
	aAdd(aLayout1, {'N',6, 2,1278})
	aAdd(aLayout1, {'N',6, 0,1284})
	aAdd(aLayout1, {'N',6, 2,1290})
	aAdd(aLayout1, {'N',6, 0,1296})
	// mes 27
	aAdd(aLayout1, {'N',6, 2,1302})
	aAdd(aLayout1, {'N',6, 0,1308})
	aAdd(aLayout1, {'N',6, 2,1314})
	aAdd(aLayout1, {'N',6, 0,1320})
	// mes 28
	aAdd(aLayout1, {'N',6, 2,1302})
	aAdd(aLayout1, {'N',6, 0,1308})
	aAdd(aLayout1, {'N',6, 2,1314})
	aAdd(aLayout1, {'N',6, 0,1320})
	// mes 29
	aAdd(aLayout1, {'N',6, 2,1302})
	aAdd(aLayout1, {'N',6, 0,1308})
	aAdd(aLayout1, {'N',6, 2,1314})
	aAdd(aLayout1, {'N',6, 0,1320})
	// mes 30
	aAdd(aLayout1, {'N',6, 2,1302})
	aAdd(aLayout1, {'N',6, 0,1308})
	aAdd(aLayout1, {'N',6, 2,1314})
	aAdd(aLayout1, {'N',6, 0,1320})
	// mes 31
	aAdd(aLayout1, {'N',6, 2,1302})
	aAdd(aLayout1, {'N',6, 0,1308})
	aAdd(aLayout1, {'N',6, 2,1314})
	aAdd(aLayout1, {'N',6, 0,1320})
	// mes 32
	aAdd(aLayout1, {'N',6, 2,1302})
	aAdd(aLayout1, {'N',6, 0,1308})
	aAdd(aLayout1, {'N',6, 2,1314})
	aAdd(aLayout1, {'N',6, 0,1320})
	// mes 33
	aAdd(aLayout1, {'N',6, 2,1302})
	aAdd(aLayout1, {'N',6, 0,1308})
	aAdd(aLayout1, {'N',6, 2,1314})
	aAdd(aLayout1, {'N',6, 0,1320})
	// mes 34
	aAdd(aLayout1, {'N',6, 2,1302})
	aAdd(aLayout1, {'N',6, 0,1308})
	aAdd(aLayout1, {'N',6, 2,1314})
	aAdd(aLayout1, {'N',6, 0,1320})
	// mes 35 
	aAdd(aLayout1, {'N',6, 2,1302})
	aAdd(aLayout1, {'N',6, 0,1308})
	aAdd(aLayout1, {'N',6, 2,1314})
	aAdd(aLayout1, {'N',6, 0,1320})
	// mes 36
	aAdd(aLayout1, {'N',6, 2,1302})
	aAdd(aLayout1, {'N',6, 0,1308})
	aAdd(aLayout1, {'N',6, 2,1314})
	aAdd(aLayout1, {'N',6, 0,1320})
	// mes 33
	aAdd(aLayout1, {'N',6, 2,1302})
	aAdd(aLayout1, {'N',6, 0,1308})
	aAdd(aLayout1, {'N',6, 2,1314})
	aAdd(aLayout1, {'N',6, 0,1320})
	// mes 34
	aAdd(aLayout1, {'N',6, 2,1302})
	aAdd(aLayout1, {'N',6, 0,1308})
	aAdd(aLayout1, {'N',6, 2,1314})
	aAdd(aLayout1, {'N',6, 0,1320})
	// mes 35 
	aAdd(aLayout1, {'N',6, 2,1302})
	aAdd(aLayout1, {'N',6, 0,1308})
	aAdd(aLayout1, {'N',6, 2,1314})
	aAdd(aLayout1, {'N',6, 0,1320})
	// mes 36
	aAdd(aLayout1, {'N',6, 2,1302})
	aAdd(aLayout1, {'N',6, 0,1308})
	aAdd(aLayout1, {'N',6, 2,1314})
	aAdd(aLayout1, {'N',6, 0,1320})
endif
// 
// PROCESSAMENTO DOS ARQUIVOS
//
// Para realizar processamentos m�ltiplos deve-se popular o vetor aArquivos. 
// Para processamentos de um s� arquivo pode-se usar o cGetFile
//
// Usando GetFile:
cArquivo := cGetFile( "*.txt" , STR0008, 1, , .F., ,.T., .T. ) // TODO - Verificar par�metros do cGetFile
aAdd(aArquivos,cArquivo)
//
aFilis := {}
VE4->(DBSetOrder(1))
DBSelectArea("SX6")
DBSetOrder(1)
DBGoTop()
while !eof()
	if Alltrim(SX6->X6_VAR) == "MV_MIL0005"
		VE4->(DBSeek(SX6->X6_FIL))
		aAdd(aFilis,{SX6->X6_FIL, SX6->X6_CONTEUD,Right(Alltrim(SX6->X6_FIL),2)})
	endif
	DBSkip()
enddo
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
	//
	if cTProc == "TXT"
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
		cFilHead := ""
		lPulaFilial := .t.
		While !FT_FEof() 
			//
			cStr := FT_FReadLN()  
			nLinhArq++
			//			
			IncRegua()
			if Left(cStr,3) == "~H~"
				nContFil++
				nPosFilis := aScan(aFilis,{|x| Alltrim(x[2]) == Alltrim(subs(cStr,5,6)) } )
				if nPosFilis > 0 
					cFilHead := aFilis[nPosFilis,1]
					lPulaFilial := .f.
				else
					MsgInfo("Filial "+Alltrim(subs(cStr,5,6))+" nao encontrada.")
					lPulaFilial := .t.
				endif
			endif
			// Informa��es extra�das da linha do arquivo de importa��o ficam no vetor aInfo
			aInfo := {}
			if Left(cStr,3)=="~P~" .and. !lPulaFilial
				aInfo := ExtraiEDI(aLayout1,cStr)				
				// Trabalhar com aInfo gravando as informa��es
				if Empty(aInfo)
					aAdd(aLinErros, cArquivo + STR0014 + Alltrim(STR(nLinhArq) ))
				else
					GrvInfo(aInfo)
				endif
			endif
			FT_FSkip()
		EndDo
		//
		FT_FUse()
	else
		// Processamento para Arquivos XML
		oXml := XmlParserFile( cFile, "_", @cErrorXML, @cWarnXML )	
		if Empty(cErrorXML)
			GrvInfo(aInfo)
		else
			aAdd(aLinErros, cArquivo + STR0015)
		endif
	endif
next
//#############################################################################
//# Move o arquivo para o diretorio SALVA                                     #
//#############################################################################
if Len(aLinErros) == 0
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
##|Descri��o | Processa o resultado da importa��o                           |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function GrvInfo(aInfo)
Local nCntFor

// {ano, mes, prod, sales, hits, losts, losth}
aAnos := {}

// dDataIni := stod(STR(year(ddatabase),4)+strzero(month(ddatabase),2)+"01")-1
dDataIni := MV_PAR01

nMesAt := Month(dDataIni)
nYearAt := Year(dDataIni)

for nCntFor := 1 to 36
	aAdd(aAnos,{;
	nYearAt , ;
	nMesAt , ;
	aInfo[2] , ;
	IIF(nCntFor == 1, aInfo[7] , aInfo[ (29+3) + (nCntFor-1) * 4]) , ; // IIF(nCntFor == 1, aInfo[7], aInfo[29 + (nCntFor-1) * 4]) , ;
	IIF(nCntFor == 1, aInfo[8] , aInfo[ (30+3) + (nCntFor-1) * 4]) , ; // IIF(nCntFor == 1, aInfo[8], aInfo[30 + (nCntFor-1) * 4]) , ;
	IIF(nCntFor == 1, aInfo[9] , aInfo[ (31+3) + (nCntFor-1) * 4]) , ; // IIF(nCntFor == 1, aInfo[9], aInfo[31 + (nCntFor-1) * 4]) , ;
	IIF(nCntFor == 1, aInfo[10], aInfo[ (32+3) + (nCntFor-1) * 4]) }) // IIF(nCntFor == 1, aInfo[10], aInfo[32 + (nCntFor-1) * 4]) })
	nMesAt --
	if nMesAt == 0
		nMesAt = 12
		nYearAt --
	endif 
//
next
//
DBSelectArea("VQ3")
DBSetOrder(1)
//
cUltVda := ""
for nCntFor := 1 to 36
//	DBSeek(Left(cFilHead+space(20),TamSX3("VQ3_FILIAL")[1]) + Left(aAnos[nCntFor,3] + space(50),TamSX3("VQ3_PRODUT")[1]) +STR(aAnos[nCntFor,1],4) +STRZERO(aAnos[nCntFor,2],2)+"01")
	if aAnos[nCntFor,4] != 0 .or. aAnos[nCntFor,5] != 0 .or. aAnos[nCntFor,6] != 0 .or. aAnos[nCntFor,7] != 0 .or. nCntFor == 1
		cCriCod := ""
		if SB1->(DBSeek(xFilial("SB1")+aAnos[nCntFor,3]))
			cCriCod := SB1->B1_CRICOD                                                                                                                                                                                                                                                                                                                                                                                                 
			if lB1GROUPC
				reclock("SB1",.f.)
				SB1->B1_GROUPC := aInfo[28]
				msunlock()
			endif
		endif
		//
		cQryAl001 := GetNextAlias()

		cQuery :=  "SELECT R_E_C_N_O_ CONTVQ3 FROM " + RetSQLName("VQ3") + " VQ3 "
		cQuery +=  " WHERE VQ3.D_E_L_E_T_ = ' ' AND "
		cQuery +=  " VQ3.VQ3_FILIAL = '" + cFilHead + "' AND"
		cQuery +=  " VQ3.VQ3_PRODUT = '" + Left(aAnos[nCntFor,3],15) + "' AND"
		cQuery +=  " VQ3.VQ3_ANO    = '" + STR(aAnos[nCntFor,1],4) + "' AND"
		cQuery +=  " VQ3.VQ3_MES    = '" + STRZERO(aAnos[nCntFor,2],2) + "' AND"
		cQuery +=  " VQ3.VQ3_DIA    = '01' AND"
		cQuery +=  " VQ3.VQ3_STOCK  = ' '"
		//
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. )
		//
		DbSelectArea("VQ3")
		if ((cQryAl001)->(eof()))
			reclock("VQ3",.t.)
		else
			DbGoto((cQryAl001)->(CONTVQ3))
			reclock("VQ3",.F.)
		endif
		VQ3_FILIAL := cFilHead
		VQ3_PRODUT := Left(aAnos[nCntFor,3],15)
		VQ3_ANO := STR(aAnos[nCntFor,1],4)
		VQ3_MES := STRZERO(aAnos[nCntFor,2],2)
		VQ3_DIA := "01"
		VQ3_VDAB := aAnos[nCntFor,4] 
		VQ3_HITSB := aAnos[nCntFor,5]
		VQ3_VDPERB := aAnos[nCntFor,6]
		VQ3_HIPERB := aAnos[nCntFor,7]
		VQ3_CRICOD := cCriCod
		msunlock()

		if aAnos[nCntFor,4] > 0 .and. Empty(cUltVda)
			cUltVda := STR(aAnos[nCntFor,1],4) + STRZERO(aAnos[nCntFor,2],2) + "15"
		endif
		(cQryAl001)->(DBCloseArea())
	endif
next

while AT("-",aInfo[30]) > 0
	nChar := AT("-",aInfo[30])
	aInfo[30] := Left(aInfo[30],nChar-1)+Subs(aInfo[30],nChar+1)
enddo

if lB5ADDED .AND. AllTrim(cDadosProd) != "SBZ"
	DBSelectArea("SB5") 
	DBSetOrder(1)
	if DBSeek(Left(Left(cFilHead,nTamFil)+SPACE(nTamFilTot),nTamFilTot)+VQ3->VQ3_PRODUT)
		reclock("SB5",.f.)
		SB5->B5_DTADDED := stod(aInfo[30])
		if dtos(SB5->B5_ULTVDA) < cUltVda .and. !Empty(cUltVda)
			SB5->B5_ULTVDA := stod(cUltVda)
		endif
		msunlock()
	else 
		reclock("SB5",.t.)
		SB5->B5_FILIAL := cFilHead
		SB5->B5_COD := VQ3->VQ3_PRODUT
		SB5->B5_DTADDED := stod(aInfo[30])
		if !Empty(cUltVda)
			SB5->B5_ULTVDA := stod(cUltVda)
		endif
		msunlock()
	endif
endif
if AllTrim(cDadosProd) == "SBZ"
	DBSelectArea("SBZ")
	DBSetOrder(1)
	if DBSeek(Left(Left(cFilHead,nTamFil)+SPACE(nTamFilTot),nTamFilTot)+VQ3->VQ3_PRODUT)
		reclock("SBZ",.f.)
		SBZ->BZ_PRIENT := stod(aInfo[30])
		if dtos(SBZ->BZ_ULTVDA) < cUltVda .and. !Empty(cUltVda)
			SBZ->BZ_ULTVDA := stod(cUltVda)
		endif
		msunlock()
	else 
		reclock("SBZ",.t.)
		SBZ->BZ_FILIAL := cFilHead
		SBZ->BZ_COD := VQ3->VQ3_PRODUT
		SBZ->BZ_PRIENT := stod(aInfo[30])
		if !Empty(cUltVda)
			SBZ->BZ_ULTVDA := stod(cUltVda)
		endif
		msunlock()
	endif
	
endif
	//
return
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
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa � ExtraiEDI � Autor � Luis Delorme             � Data � 26/03/13 ���
����������������������������������������������������������������������������͹��
���Descricao� Monta vetores a partir de uma descri��o de layout e da linha de���
���         � importa��o EDI                                                 ���
����������������������������������������������������������������������������͹�� 
��� Retorno � aRet - Valores extra�dos da linha                              ���
���         �        Se der erro o vetor retorna {}                          ���
����������������������������������������������������������������������������͹��
���Parametro� aLayout[n,1] = Tipo do campo ([D]ata,[C]aracter ou [N]umerico) ���
���         � aLayout[n,2] = Tamanho do Campo                                ���
���         � aLayout[n,3] = Quantidade de Decimais do Campo                 ���
���         � aLayout[n,4] = Posi��o Inicial do Campo na Linha               ���
���         �                                                                ���
���         � cLinhaEDI    = Linha para extra��o das informa��es             ���
����������������������������������������������������������������������������͹��
���                                                                          ���
���  EXEMPLO DE PREENCHIMENTO DOS VETORES                                    ���
���                                                                          ���
���  aAdd(aLayout,{"C",10,0,1})                                              ���
���  aAdd(aLayout,{"C",20,0,11})                                             ���
���  aAdd(aLayout,{"N",5,2,31})                                              ���
���  aAdd(aLayout,{"N",4,0,36})                                              ���
���                        1         2         3                             ���
���               123456789012345678901234567890'123456789                    ���
���  cLinhaEDI = "Jose SilvaVendedor Externo    123121234                    ���
���                                                                          ���
���  No caso acima o retorno seria:                                          ���
���  aRet[1] - "Jose Silva"                                                  ���
���  aRet[2] - "Vendedor Externo"                                            ���
���  aRet[3] - 123,12                                                        ���
���  aRet[4] - 1234                                                          ���
���                                                                          ���
���                                                                          ���
���                                                                          ���
���                                                                          ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
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

	nPos := AT(chr(9),cLinhaEDI)
	cStrTexto := Subs(cLinhaEDI,1,nPos-1)
	cLinhaEDI := Subs(cLinhaEDI,nPos+1)
	ncValor := ""
	if Alltrim(cTipo) == "N"
		for nCntFor2 := 1 to Len(cStrTexto)
			if !(Subs(cStrTexto,nCntFor2,1)$"0123456789 .-+")
				return {}
			endif
		next
		ncValor = VAL(cStrTexto)// / (10 ^ nDecimal)
	elseif Alltrim(cTipo) == "D"
		if stod(cStrTexto) == stod("  /  /  ")
			return {}
		endif
		ncValor := stod(cStrTexto)
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
##|Fun��o    | CriaSX1    | Autor |  Luis Delorme         | Data | 30/05/11 |##
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

aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME" ,"X1_GRPSXG" ,"X1_HELP","X1_PICTURE"}

//��������������������������������������������������������������Ŀ
//� aAdd a Pergunta                                              �
//����������������������������������������������������������������
/*
"	MV_PAR01 - Data Inicial - DATE
"	MV_PAR02 - Data Final - DATE
"	MV_PAR03 - Envia Saldo Inicial? - Sim/N�o
"	MV_PAR04 - Envia Invent�rio? - Sim/N�o
"	MV_PAR05 - DN da concession�ria - Num�rico 4
"	MV_PAR06 - Tipos de Pedido Autopart - Caractere 200
"	MV_PAR07 - Tipos de Pedido Carro Parado - Caractere 200
"	MV_PAR08 - Atividade Oficina Frotista - Caractere 200
"	MV_PAR09 - Atividade Outro Dealer - Caractere 200
"	MV_PAR11 - Diret�rio de Gera��o do Arquivo - Caractere 200
"	MV_PAR12 - Marca
*/

aAdd(aSX1,{cPerg,"01","Data Ref Arquivo","","","MV_CH1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""})

ProcRegua(Len(aSX1))

dbSelectArea("SX1")
dbSetOrder(1)
For i:= 1 To Len(aSX1)
	If !Empty(aSX1[i][1])
		If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
			lSX1 := .T.
			RecLock("SX1",.T.)
			
			For j:=1 To Len(aSX1[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
				EndIf
			Next j
			
			dbCommit()
			MsUnLock()
			IncProc("Processando")
		EndIf
	EndIf
Next i

return