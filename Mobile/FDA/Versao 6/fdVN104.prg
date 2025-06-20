#INCLUDE "FDVN104.ch"

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � ACCrgCto            矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Carrega Array de Contatos 				 			      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cCodCLi - Cod. Cliente; cLojaCLi - Loja CLiente 			  潮�
北�			 � aContato - Array dos Contatos							  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function ACCrgCto(cCodCli,cLojaCli,aContato)
Local cFuncao:="",nTam:=0

nTam := 6 - Len(cCodCli)
dbSelectArea("HU5")
dbSetOrder(2)
If nTam > 0
	dbSeek(cCodCli+space(nTam)+cLojaCli)
Else
	dbSeek(cCodCli + cLojaCli)
Endif

While !Eof() .And. HU5->U5_CLIENTE == cCodCli .And. HU5->U5_LOJA == cLojaCli

    cFuncao:=""
	dbSelectArea("HX5")
	dbSetOrder(1)
	dbSeek("UM" + HU5->U5_FUNCAO)
	If !Eof()
		cFuncao	:=HX5->X5_DESCRI
	Endif      

	AADD(aContato,{Alltrim(HU5->U5_CODCON),AllTrim(HU5->U5_CONTAT),cFuncao})

	dbSelectArea("HU5")	
 	dbSkip()
Enddo

Return Nil   

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � AcManCon            矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Carrega Array de Contatos 				 			      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� nOpCon - Operacao (1=Inclusao, 2=Alteracao, 3=Detalhe)	  潮�
北�			 � cCodCLi - Cod. Cliente; cLojaCLi - Loja CLiente 			  潮�
北�			 � aContato - Array dos Contatos							  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function AcManCon(nOpCon, oBrwContato,aContato,cCodCli, cLojaCli)
Local cCodCon	:=space(6), cFuncao	:=""
Local nLinha:=0, nTam := 0
Local lAt	:=.F.
if !nOpCon==1
	if Len(aContato) == 0
	    MsgAlert(STR0001,STR0002) //"Nenhum contato selecionado!"###"Cad. Contato"
		Return Nil
	Endif	
	nLinha  := GridRow(oBrwContato)    
	cCodCon	:= aContato[nLinha,1]
Endif

InitContato(nOpCon,cCodCli, cLojaCli,@cCodCon,@lAt)

//Ocorreu alguma Acao no Modulo de Contatos ( Inclusao, Alteracao ou Exclusao)?
// Corpo para atualizacao do Browse de Contatos
if lAt
	nTam := 6 - Len(cCodCli)
	dbSelectArea("HU5")
	dbSetOrder(1)
	If nTam > 0
		dbSeek(cCodCli+space(nTam)+cLojaCli+cCodCon) 
	Else                                             
		dbSeek(cCodCli+cLojaCli+cCodCon) 
	Endif
	//Incluiu ou Alterou um Contato
	if HU5->(Found())
	
	    cFuncao:=""
		dbSelectArea("HX5")
		dbSetOrder(1)
		dbSeek("UM" + HU5->U5_FUNCAO)
		If !Eof()
			cFuncao	:=HX5->X5_DESCRI
		Endif      
	
	    If nOpCon==1 
			AADD(aContato,{Alltrim(HU5->U5_CODCON),AllTrim(HU5->U5_CONTAT),cFuncao})
		Else
			aContato[nLinha,2] := AllTrim(HU5->U5_CONTAT)
			aContato[nLinha,3] := cFuncao
		Endif
	//Excluiu o Contato
	Else
		aDel(aContato,nLinha)
		aSize(aContato,Len(aContato)-1)
	Endif
	SetArray(oBrwContato,aContato)

Endif	
Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � ACCrgPar        矨utor - Marcelo Vieira   � Data �15.01.04 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Carrega array dos Parametros do SFA  (So visualizacao )    潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北矨nalista    � Data   矼otivo da Alteracao                              潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function ACCrgPar(aParametro)
Local nLinhas:=0
dbSelectArea("HCF")
dbSetOrder(1)
dbGotop()
While !Eof() 
      AADD(aParametro,{HCF->CF_PARAM,HCF->CF_VALOR}) 
      dbSkip()  
Enddo
// Descobre quantos elementos contem o array
nLinhas:=Len(aParametro)

// Ordena o Array por ordem de parametro 
SortArray(aParametro, 1, nLinhas,, 1) 

Return 
