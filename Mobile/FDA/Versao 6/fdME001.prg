#INCLUDE "FDME001.ch"
#include "eADVPL.ch"    
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � InitMercha()        矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Modulo de Merchandising   	 			                  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function InitMercha(cCodCli, cLojaCli, cCodCon)
Local oDlg, oFldCamp, oFldScr //oFldDet
Local oBrwCamp, oBrwScr, oBtnAvan, oBtnCanc //oBrwDet
Local aCamp := {}, aDet := {}, aScr := {}
Local oCol
/******************************************/
/* Excluir isso, pois nao tenho o projeto */
/* Completo por isso preciso executar isso*/
/* O fonte esta no fim desse arquivo      */
/******************************************/
//alert("Chamei TEMPRESPOST")
//TempRespost()
/******************************************/

                                       
if Empty(cCodCli)
//	InitCliente(@cCodCli,@cLojaCli)
Endif
if Empty(cCodCon)
//	InitContat(cCodCli,cLojaCli,cCodCon)
Endif         

dbSelectArea("HA1")
dbSetorder(1)
dbSeek(cCodCli+cLojaCli)

dbSelectArea("HU5")
dbSetorder(1)
dbSeek(cCodCli+cLojaCli+cCodCon)

MECrgCamp(aCamp,)

DEFINE DIALOG oDlg TITLE STR0001 //"Merchandising"

@ 15,01 SAY HA1->A1_COD + "/" + HA1->A1_LOJA + " | " + AllTrim(HA1->A1_NOME) OF oDlg
@ 27,01 SAY HU5->U5_CODCON + " | " + AllTrim(HU5->U5_CONTAT) OF oDlg

ADD FOLDER oFldCamp CAPTION STR0002  OF oDlg //"Campanhas"
@ 42,02 SAY STR0003 OF oFldCamp //"Escolha a Campanha:"
@ 54,02 BROWSE oBrwCamp SIZE 156,60 ON CLICK MEClickCamp(aCamp,oBrwCamp,aScr,oBrwScr) OF oFldCamp
SET BROWSE oBrwCamp ARRAY aCamp
ADD COLUMN oCol TO oBrwCamp ARRAY ELEMENT 1 HEADER STR0004 WIDTH 40 //"C骴."
ADD COLUMN oCol TO oBrwCamp ARRAY ELEMENT 2 HEADER STR0005 WIDTH 150 //"Descr."

ADD FOLDER oFldScr CAPTION STR0006  OF oDlg //"Pesquisa"
@ 42,02 SAY STR0007 OF oFldScr //"Escolha a Pesquisa:"
@ 54,02 BROWSE oBrwScr SIZE 156,60 OF oFldScr
SET BROWSE oBrwScr ARRAY aScr
ADD COLUMN oCol TO oBrwScr ARRAY ELEMENT 1 HEADER STR0004 WIDTH 40 //"C骴."
ADD COLUMN oCol TO oBrwScr ARRAY ELEMENT 2 HEADER STR0005 WIDTH 150 //"Descr."

/*
ADD FOLDER oFldDet CAPTION "Detalhe"  OF oDlg
@ 42,02 BROWSE oBrwDet SIZE 156,72 OF oFldDet
SET BROWSE oBrwDet ARRAY aDet
ADD COLUMN oCol TO oBrwDet ARRAY ELEMENT 1 HEADER "" WIDTH 40
ADD COLUMN oCol TO oBrwDet ARRAY ELEMENT 2 HEADER "" WIDTH 150
*/

@130,40 BUTTON oBtnCanc CAPTION  BTN_BITMAP_CANCEL SYMBOL ACTION CloseDialog() SIZE 50,12 of oDlg
@130,100 BUTTON oBtnAvan CAPTION STR0008 ACTION InitPergunta(aScr,oBrwScr) SIZE 50,12 of oDlg //"Iniciar >"

MEClickCamp(aCamp,oBrwCamp,aScr,oBrwScr)

ACTIVATE DIALOG oDlg

Return Nil      

/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矼EUnicEsc 篈utor  � Marcos Daniel      � Data �  29/01/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � MODELO DE TELA DE UNICA ESCOLHA                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � PalmTop                                                    罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/

Function MEUnicEsc(cCodScr,aPergC,nPergC,tIni,lScript, cTitle)
Local oDlg, oBtnCa, oBtnGr, oBtnAv, oBtnAn, oGetPerg, oBrw
Local aRespI 	:= {}
Local lTipo		:= .T.
Local cRespI	:=""
Local nResp		:= 1
LOCAL nCol := 0, nX := 1
Local oCol

dbSelectArea("HUP")
dbSetOrder(2)
dbSeek(cCodScr+aPergC[nPergC,1])

While !EOF() .And. Alltrim(HUP->UP_CODSCRI) == Alltrim(cCodScr) .And. Alltrim(HUP->UP_IDTREE) == Alltrim(aPergC[nPergC,1])
	Aadd(aRespI, {HUP->UP_CODPERG, HUP->UP_DESC, HUP->UP_SCORE})
	dbSkip()
Enddo
Aadd(aRespI, {"","",0})

DEFINE DIALOG oDlg TITLE cTitle

@ 015, 005 GET oGetPerg VAR aPergC[nPergC,2] MULTILINE READONLY SIZE 155, 030 OF oDlg

@ 040, 005 BROWSE oBrw SIZE 148, 090 OF oDlg

SET BROWSE oBrw ARRAY aRespI

ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0009	WIDTH 150 //"Respostas"


dbSelectArea("HRE")
dbSetOrder(1)

HRE->(dbSeek(aPergC[nPergC,1]))
If HRE->(!EOF())
	For nX:=1 to Len(aRespI)
		If HRE->RE_CODRESP == aRespI[nX,1]
			GridSetRow(oBrw, nX)
		ElseIF Empty(HRE->RE_CODRESP)
			GridSetRow(oBrw, Len(aRespI))
		Endif
	Next
Endif

nCol := Len(Alltrim(Str(nPergC)) + "/" + Alltrim(Str(Len(aPergC))))
@135,144 -(nCol*3.33) SAY Alltrim(Str(nPergC)) + "/" + Alltrim(Str(Len(aPergC))) BOLD OF oDlg

@ 145, 005	BUTTON oBtnCa	CAPTION BTN_BITMAP_CANCEL SYMBOL ACTION MECancResp(@lScript)	OF oDlg 
@ 145, 060	BUTTON oBtnGr	CAPTION BTN_BITMAP_GRAVAR SYMBOL ACTION CloseDialog()	OF oDlg 

If nPergC != 1
//   nPergC += 1
   @ 145, 120 BUTTON oBtnAn CAPTION Chr(3) SYMBOL 	ACTION MEAntPerg(cCodScr,aPergC,@nPergC,tIni,aRespI,cRespI,oBrw,lScript) OF oDlg
EndIf

If Len(aPergC) != nPergC
   @ 145, 140 BUTTON oBtnAv CAPTION Chr(4) SYMBOL 	ACTION MEProxPerg(cCodScr,aPergC,@nPergC,tIni,aRespI,cRespI,oBrw,lScript)	OF oDlg
EndIf


ACTIVATE DIALOG oDlg

Return Nil
           


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矼EMULTESC 篈utor  矼ONAEL P. RIBEIRO   � Data �  01/29/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Desenha a tela do tipo Multiescolha para exibir a pergunta 罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篠intaxe   �  void MEDMULTESC(cCodSrc, aPergC, nPergC, cTime, cTitle)   罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � MERCHANDISING - DJARUM                                     罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/
Function MEMultEsc(cCodScr, aPergC, nPergC, tIni,lScript, cTitle)

LOCAL oDlg
LOCAL oBtnCa
LOCAL oBtnGr
LOCAL oBtnAv
LOCAL oBtnAn

LOCAL oBrw
LOCAL oGetP
LOCAL oCol
LOCAL aPergI := {}
LOCAL aRespI := {}
LOCAL nCol := 0
LOCAL aMark := {}
Local cRespI	:=""
Local j := 1, k := 1

dbSelectArea("HUP")            
dbSetOrder(2)

dbSeek(cCodScr + aPergC[nPergC,1])

While !EOF() .AND. cCodScr == HUP->UP_CODSCRI .AND. Alltrim(HUP->UP_IDTREE) == Alltrim(aPergC[nPergC,1])
		// adicione-o no array
      Aadd(aRespI, {HUP->UP_CODPERG, AllTrim(HUP->UP_DESC), HUP->UP_SCORE, .F.}) 
      dbSkip() 
EndDo

dbSelectArea("HRE")
dbSetOrder(1)

if dbSeek(aPergC[nPergC,1])
   While !EOF() .AND. HRE->RE_CODPERG == aPergC[nPergC,1]
         Aadd(aMark, {aPergC[nPergC,1], HRE->RE_CODRESP})
         dbSkip()
   EndDo
   
   For j:=1 To Len(aMark)
       For k:=1 To Len(aRespI)
           // HUP->UP_CODPERG == HRE->RE_CODRESP and HUP->UP_IDTREE == HUP->UP_CODPERG da Pergunta
           if aRespI[k,1] == aMark[j,2] .AND. aPergC[nPergC,1] == aMark[j,1]
              // esta marcado
              aRespI[k,4] := .T.
           EndIf
       Next
   Next
   
Endif

DEFINE DIALOG oDlg TITLE cTitle 

@015,005 GET oGetP VAR aPergC[nPergC,2] MULTILINE READONLY SIZE 155, 030 OF oDlg 
@040,005 BROWSE oBrw SIZE 155,090 OF oDlg
SET BROWSE oBrw ARRAY aRespI
//campo logico do Array
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 4 HEADER "" WIDTH 10 MARK      
//campo descricao da resposta do array   
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0010 WIDTH 50    //"Resposta"

nCol := Len(Alltrim(Str(nPergC)) + "/" + Alltrim(Str(Len(aPergC))))
@135,144 -(nCol*3.33) SAY Alltrim(Str(nPergC)) + "/" + Alltrim(Str(Len(aPergC))) BOLD OF oDlg

@145,05 BUTTON oBtnCa CAPTION  BTN_BITMAP_CANCEL SYMBOL  ACTION MECancResp(@lScript) OF oDlg 
@145,60 BUTTON oBtnGr CAPTION BTN_BITMAP_GRAVAR SYMBOL ACTION MEGrvResp(cCodScr,aPergC,tIni,@lScript) OF oDlg 

If nPergC != 1
//   nPergC+=1 
   @145,120 BUTTON oBtnAn CAPTION Chr(3) SYMBOL ACTION MEAntPerg(cCodScr, aPergC, @nPergC, tIni, aRespI,cRespI,oBrw,lScript) OF oDlg
EndIf

If Len(aPergC) != nPergC
   @145,140 BUTTON oBtnAv CAPTION Chr(4) SYMBOL ACTION MEProxPerg(cCodScr, aPergC, @nPergC, tIni, aRespI,cRespI,oBrw,lScript) OF oDlg
EndIf

ACTIVATE DIALOG oDlg

Return NIL                    


/*
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矼EDISSERT 篈utor  矼ONAEL P. RIBEIRO   � Data �  01/29/03   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � Desenha a tela do tipo dissertativa para exibir a pergunta 罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篠intaxe   �  void MEDISSERT(cCodScr, aPergC, nPergC, tIni, cTitle)     罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � MERCHANDISING - DJARUM                                     罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
*/

Function MEDISSERT(cCodScr, aPergC, nPergC, tIni,lScript, cTitle)

LOCAL oDlg
LOCAL oGetP
LOCAL oGetR
LOCAL oBtnCa
LOCAL oBtnGr
LOCAL oBtnAv
LOCAL oBtnAn
Local cRespI := space(Len(HUK->UK_RESMEMO))
Local aRespI
Local oBrw
Local nCol := 0

//Aadd(aRespI, space(Len(HUK->UK_RESMEMO)))
//Aadd(aRespI, "")

dbSelectArea("HRE")
dbSetOrder(1)
if dbSeek(aPergC[nPergC,1])
   cRespI := AllTrim(HRE->RE_RESMEMO)
EndIf

DEFINE DIALOG oDlg TITLE cTitle

@15,05 GET oGetP VAR aPergC[nPergC,2] READONLY MULTILINE SIZE 155, 030 OF oDlg
@40,05 GET oGetR VAR cRespI MULTILINE VSCROLL SIZE 155,090 OF oDlg

nCol := Len(Alltrim(Str(nPergC)) + "/" + Alltrim(Str(Len(aPergC))))
@135,144 -(nCol*3.33) SAY Alltrim(Str(nPergC)) + "/" + Alltrim(Str(Len(aPergC))) BOLD OF oDlg

@145,005 BUTTON oBtnCa CAPTION  BTN_BITMAP_CANCEL SYMBOL  ACTION MECancResp(@lScript) OF oDlg 
@145,060 BUTTON oBtnGr CAPTION BTN_BITMAP_GRAVAR SYMBOL ACTION MEGrvResp(cCodScr,aPergC,tIni,@lScript) OF oDlg 

If nPergC != 1
  @145,120 BUTTON oBtnAn CAPTION Chr(3) SYMBOL	ACTION MEAntPerg(cCodScr, aPergC, @nPergC, tIni, aRespI, cRespI,oBrw,lScript) OF oDlg
EndIf

If Len(aPergC) != nPergC
   @145,140 BUTTON oBtnAv CAPTION Chr(4) SYMBOL	ACTION MEProxPerg(cCodScr, aPergC, @nPergC, tIni, aRespI, cRespI,oBrw,lScript) OF oDlg
EndIf


ACTIVATE DIALOG oDlg

Return NIL
