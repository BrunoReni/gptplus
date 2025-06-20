#include "eADVPL.ch"    
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � MECrgCamp()         矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Modulo de Merchandising   	 			                  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function MECrgCamp(aCamp,oBrwCamp)
aSize(aCamp,0)
dbSelectArea("HUO")
dbSetOrder(1)
dbGoTop()
While !Eof()
	AADD(aCamp,{HUO->UO_CODCAMP	,AllTrim(HUO->UO_DESC)})
	dbSkip()
Enddo
 
if oBrwCamp<>Nil
	SetArray(oBrwCamp,aCamp)
Endif

Return Nil


/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � MECrgScr()          矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Modulo de Merchandising   	 			                  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function MECrgScr(cCodCamp,aScr,oBrwScr)
aSize(aScr,0)
dbSelectArea("HUW")
dbSetOrder(1)
dbSeek(cCodCamp)

While !Eof() .And. AllTrim(HUW->UW_CODCAMP) == AllTrim(cCodCamp)
    HUZ->(dbSetOrder(1))
    if HUZ->(dbSeek(HUW->UW_CODSCRI))
		AADD(aScr,{HUW->UW_CODSCRI	,AllTrim(HUZ->UZ_DESC)})
	endif
	dbSelectArea("HUW")
	dbSkip()
Enddo
SetArray(oBrwScr,aScr) 
Return Nil    


/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � MEClickCamp()       矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Modulo de Merchandising   	 			                  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function MEClickCamp(aCamp,oBrwCamp,aScr,oBrwScr)
Local nLinha:=0
if Len(aCamp) == 0
	Return Nil
Endif
nLinha:=GridRow(oBrwCamp)

dbSelectArea("HUW")
dbSetOrder(1)
dbSeek(aCamp[nLinha,1])

MECrgScr(aCamp[nLinha,1],aScr,oBrwScr)

Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � InitPergunta()      矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Modulo de Merchandising   	 			                  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/                                                
Function InitPergunta(aScr,oBrwScr)
Local aPergC := {}
Local cCodScr:="",cSep:="0000000" ,cTipo:=""
Local nLinha:=0, nPergC:=1
// Hora Inicial da Pesquisa
Local tIni
Local lScript := .T.
Local cTitle := "" // <===== COLOQUE AQUI O TITULO
if Len(aScr) == 0
	Return Nil
Endif
nLinha:=GridRow(oBrwScr)
cCodScr:=AllTrim(aScr[nLinha,1])
cTitle:=AllTrim(aScr[nLinha,2])
dbSelectArea("HUP")
dbSetOrder(2)
dbSeek(cCodScr+cSep)
While !Eof() .And. HUP->UP_CODSCRI == cCodScr .And. HUP->UP_IDTREE == cSep
	AADD(aPergC,{HUP->UP_CODPERG , HUP->UP_DESC , HUP->UP_TIPOOBJ})	
	dbSkip()
Enddo

if Len(aPergC) == 0 
	Return Nil
Endif

tIni:=Time()
nPergC:=1  
While lScript
	//Carrega a pergunta
	cTipo:=aPergC[nPergC,3]     
	if cTipo == "1"
			// Unica Escolha	
			MEUnicEsc(cCodScr,aPergC,@nPergC,tIni,@lScript, cTitle) 
	Elseif cTipo == "2"
			// Multipla Escolha	
			MEMultEsc(cCodScr,aPergC,@nPergC,tIni,@lScript, cTitle)
	Elseif cTipo == "3"
			// Dissertativa
			MEDissert(cCodScr,aPergC,@nPergC,tIni,@lScript, cTitle)
	Endif
Enddo	

Return Nil                  




Function MEProxPerg(cCodScr,aPergC,nPergC,tIni,aRespI,cRespI,oBrw,lScript)
// Grava a Resposta Selecionada da Pergunta Selecionada
MEGrvTmpResp(aPergC,nPergC,aRespI, cRespI,oBrw)

//Verifica se eh a ultima Pergunta
if nPergC > Len(aPergC)
	Return Nil
Endif                                 

nPergC:=nPergC+1 

//Fecha a Tela Atual da Pergunta Atual
CloseDialog()       
//Retorna para a Funcao InitPerg()
Return Nil

Function MEAntPerg(cCodScr,aPergC,nPergC,tIni,aRespI,cRespI,oBrw,lScript)
// Grava a Resposta Selecionada da Pergunta Selecionada                          
MEGrvTmpResp(aPergC,nPergC,aRespI, cRespI,oBrw)

//Verifica se eh a Primeira Pergunta
if nPergC == 1
	Return Nil
Endif

nPergC:=nPergC-1 
//Fecha a Tela Atual da Pergunta Atual
CloseDialog()      
//Retorna para a Funcao InitPerg()
Return Nil



/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � MEGrvTmpResp()      矨utor: Paulo Amaral  � Data �30/01/03 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Grava Temporariamente as Respostas da Pergunta Corrente    潮�
北滥哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北砅arametros� aPergC -> Array das Perguntas do Script					  潮�
北�			 � [nPergC,1] -> Codigo da Pergunta							  潮�
北�			 � [nPergC,2] -> Descricao da Pergunta						  潮�
北�			 � [nPergC,3] -> Tipo da Pergunta (1-Un. Escolha, 			  潮�
北�			 � 2-Mult. Escolha,  3-Dissertativa)						  潮�
北� 		 � nPergC -> Pergunta Selecionada							  潮�
北�			 � aRespI -> Array das Respostas							  潮�
北�			 � [nRespI,1] -> Codigo da Resposta							  潮�
北�			 � [nRespI,2] -> Resposta Dissertativa 						  潮�
北�			 � [nRespI,3] -> Score (Pontuacao desse Item Selecionado)	  潮�
北�			 � Se Tipo == 3 											  潮�
北�			 � 		[nRespI,4] -> Indicacao(Flag)de Item(s)selecionado(s) 潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/     
Function MEGrvTmpResp(aPergC,nPergC,aRespI,cRespI,oBrw)
Local cTipo:=aPergC[nPergC,3], nRespI:=1      

dbSelectArea("HRE")
dbSetOrder(1)
if dbSeek(aPergc[nPergC,1])
	While !Eof() .And. HRE->RE_CODPERG == aPergc[nPergC,1]
		dbDelete()
		dbCommit()
		dbSkip()
	Enddo
Endif

if cTipo == "1"                               
	if !Empty(aRespI[nRespI,2])
		nRespI:=GridRow(oBrw)              
		dbAppend()
		HRE->RE_CODPERG := aPergc[nPergC,1]
		HRE->RE_CODRESP := aRespI[nRespI,1]
//		HRE->RE_RESMEMO	:= aRespI[nRespI,2]
		HRE->RE_SCORE	:= aRespI[nRespI,3]
		dbCommit()
	Endif
Elseif cTipo == "2"
	For nI:=1 to Len(aRespI)	
		// Se o Item foi escolhido
		if aRespI[nI,4] != .F.
			dbAppend()
			HRE->RE_CODPERG := aPergc[nPergC,1]
			HRE->RE_CODRESP := aRespI[nI,1]
//			HRE->RE_RESMEMO	:= aRespI[nRespI,2]
			HRE->RE_SCORE	:= aRespI[nI,3]	
			dbCommit()
		Endif
	Next
Elseif cTipo == "3"
	if !Empty(cRespI)
   	    dbAppend()
		HRE->RE_CODPERG := aPergc[nPergC,1]
		HRE->RE_RESMEMO	:= Alltrim(cRespI)
		dbCommit()
	Endif
Endif
Return Nil

Function MECancResp(lScript)
lScript:= .F.
CloseDialog()
Return Nil
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � MEGrvResp()         矨utor: Paulo Amaral  � Data �30/01/03 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Grava as Respostas na Base de Dados					      潮�
北滥哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北砅arametros� cCodScr -> Script					  					  潮�
北�			 � aPergC -> Array das Perguntas do Script					  潮�
北�			 � [nPergC,1] -> Codigo da Pergunta							  潮�
北�			 � [nPergC,2] -> Descricao da Pergunta						  潮�
北�			 � [nPergC,3] -> Tipo da Pergunta (1-Un. Escolha, 			  潮�
北�			 � 2-Mult. Escolha,  3-Dissertativa)						  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/  
Function MEGrvResp(cCodScr,aPergC,tIni,lScript)
Local cCodigo:= "",cIte:="0"
dbSelectArea("HUC")
dbSetOrder(1)
dbGoTop()
cCodigo:=StrZero(Val(HUC->UC_CODIGO)+1,Len(HUC->UC_CODIGO))
For nI:=1 to Len(aPergC)
	// TelemarketC
	dbSelectArea("HRE")
	dbSetOrder(1)
	if dbSeek(aPergc[nI,1])
		HUC->(dbAppend())
		HUC->UC_CODIGO		:=cCodigo
		HUC->UC_CODCAMP		:=HUW->UW_CODCAMP
		HUC->UC_CLIENTE 	:=HA1->A1_COD
		HUC->UC_LOJA		:=HA1->A1_LOJA
		HUC->UC_CODCONT		:=HU5->U5_CODCON
		HUC->UC_DATA		:=Date()
		HUC->UC_INICIO      :=tIni
		HUC->UC_FIM			:=Time()
		HUC->(dbCommit())
		dbSelectArea("HRE")
		While !Eof() .And. HRE->RE_CODPERG == aPergc[nI,1]	
			// TelemarketI
			HUK->(dbAppend())
			cIte:= StrZero(Val(cIte)+1,Len(HUK->UK_ITEM))
			HUK->UK_CODIGO  	:= cCodigo
			HUK->UK_ITEM		:= cIte
			HUK->UK_CODSCRI    	:= cCodScr
			HUK->UK_CODPERG		:= HRE->RE_CODPERG 
			HUK->UK_CODRESP     := HRE->RE_CODRESP
			HUK->UK_RESMEMO 	:= HRE->RE_RESMEMO
			HUK->UK_SCORE 		:= HRE->RE_SCORE
			HUK->(dbCommit())
			dbSelectArea("HRE")
			dbSkip()		
		Enddo
	Endif
	cCodigo:=StrZero(Val(cCodigo)+1,Len(HUC->UC_CODIGO))
Next

MECancResp(@lScript)

Return Nil





/************************* AQUI **********************/
/*
Function TempRespost()
Local aRespI:= {}

//AADD(aRespI, { "RE_CODSCRI", "C", 6, 0 } )
AADD(aRespI, { "RE_CODPERG", "C", 7, 0 } )
AADD(aRespI, { "RE_CODRESP", "C", 7, 0 } )
AADD(aRespI, { "RE_RESMEMO", "C", 90, 0 } )
AADD(aRespI, { "RE_SCORE", "N", 6, 0 } )

dbCreate("HRE010", aRespI, "LOCAL" )
USE HRE010 ALIAS HRE SHARED NEW VIA "LOCAL"
INDEX ON RE_CODPERG + RE_CODRESP TO HRE0101
dbClearIndex()
dbSetIndex("HRE0101")

/*dbAppend()
HRE->RE_CODPERG := "0000018"
HRE->RE_CODRESP := "0000018"
HRE->RE_RESMEMO := "SE ISSO APARECER A PARTE DISSERTATIVA FUNCIONOU"
HRE->RE_SCORE   := 50
dbCommit()*/

//Return Nil
