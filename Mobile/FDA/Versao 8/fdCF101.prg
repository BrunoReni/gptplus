#include "eADVPL.ch"                                                        
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � CFCons()            矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Funcao que determina o tipo de consulta/inclusao para	  潮�
北�			 � produtos e pedido.                	 			          潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function CFCons(aCbx,nCbx,oChk1,lChk1,oChk2,lChk2,oChk3,lChk3)
Local cOpcao:=""
dbSelectArea("HCF")
dbSetOrder(1)
if nCbx == 1 
	dbSeek(RetFilial("HCF")+"MV_SFATPRO")
Elseif nCbx == 2 
	dbSeek(RetFilial("HCF")+"MV_SFATPED")
Endif
if Found()
	cOpcao := AllTrim(HCF->HCF_VALOR)
else
	Return Nil
Endif

if cOpcao == "1"
	lChk1:= .T.
	lChk2:= .F.
	lChk3:= .F.
Elseif cOpcao == "2"
	lChk1:= .F.
	lChk2:= .T.
	lChk3:= .F.
else
	lChk1:= .F.
	lChk2:= .F.
	lChk3:= .T.
Endif
SetText(oChk1,lChk1)	          
SetText(oChk2,lChk2)	          
SetText(oChk3,lChk3)	          

Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � CFGravar()          矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Funcao que grava o tipo de consulta/inclusao para	      潮�
北�			 � produtos e pedido.                	 			          潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/

Function CFGravar(cOpcao,aCbx,nCbx,oChk1,lChk1,oChk2,lChk2,oChk3,lChk3)

dbSelectArea("HCF")
dbSetOrder(1)
if nCbx == 1 
	dbSeek(RetFilial("HCF")+"MV_SFATPRO")
Elseif nCbx == 2 
	dbSeek(RetFilial("HCF")+"MV_SFATPED")
Endif
if Found()
	HCF->HCF_VALOR := cOpcao
	dbCommit()
Else
	if nCbx == 1 
		dbAppend()
		HCF->HCF_FILIAL := RetFilial("HCF")
		HCF->HCF_PARAM := "MV_SFATPRO"  
		HCF->HCF_VALOR := cOpcao
		dbCommit()
	Elseif nCbx == 2 
		dbAppend()
		HCF->HCF_FILIAL := RetFilial("HCF")
		HCF->HCF_PARAM := "MV_SFATPED"  
		HCF->HCF_VALOR := cOpcao
		dbCommit()
	Endif
Endif	

if cOpcao == "1"
	lChk2:= .F.
	lChk3:= .F.
	SetText(oChk2,lChk2)	          
	SetText(oChk3,lChk3)	          
Elseif cOpcao == "2"
	lChk1:= .F.
	lChk3:= .F.
	SetText(oChk1,lChk1)	          
	SetText(oChk3,lChk3)	          
else
	lChk1:= .F.
	lChk2:= .F.
	SetText(oChk1,lChk1)	          
	SetText(oChk2,lChk2)	          
Endif

Return Nil   

Function GetParam(cParametro,cRetorno)
Local cRet :=cRetorno
HCF->(dbSetOrder(1))
if HCF->(dbSeek(RetFilial("HCF")+cParametro))
	cRet := AllTrim(HCF->HCF_VALOR)
Endif               
Return cRet