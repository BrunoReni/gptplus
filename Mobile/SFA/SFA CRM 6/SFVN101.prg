#INCLUDE "SFVN101.ch"
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � LoadRota            矨utor - Paulo Lima   � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Carrega Clientes na Rota						 			  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aRota: Array das Rotas, aRoteiro: Array dos Roteiros		  潮�
北�			 � aCLientes: Array a clientes								  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北矨nalista    � Data   矼otivo da Alteracao                              潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function LoadRota(aRota,aRoteiro,nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,ntop,nRows)
Local cStr, cCliente, i
LOcal cTitulos := ""

if Len(aRota) == 0 
    aSize(aClientes,0)
	SetArray(oCliente,aClientes)
	Return Nil
Endif

dbSelectArea("HRT")
dbSetOrder(1)
dbSeek(aRota[1,1] + aRota[2,1])
if !(HRT->(Found()))
   	aSize(aClientes,0)
	SetArray(oCliente,aClientes)
	Return Nil
Endif	

HCF->(dbSetOrder(1))
If HCF->(dbSeek("MV_SFTPTIT"))
	//Tipos de titulos que nao devem ser considerados os venctos.
	cTitulos := AllTrim(HCF->CF_VALOR)
Endif

dbSelectArea("HD7")
dbSetOrder(1)
If !dbSeek(HRT->RT_PERCUR + HRT->RT_ROTA)
	MsgStop(STR0001 + HRT->RT_ROTA) //"N鉶 foram encontrados clientes para a rota "
  	aSize(aClientes,0)
	SetArray(oCliente,aClientes)
	Return Nil
Endif	

If Len(aClientes)==0
   	nTop := Recno()
Else
   aSize(aClientes,0)
   aSize(aRoteiro,0)
   dbGoTo(nTop)
Endif   

i:=1
While i <= nRows .And. !HD7->(Eof())
	If HD7->AD7_PERCUR == HRT->RT_PERCUR .And. HD7->AD7_ROTA == HRT->RT_ROTA
		cCliente := HD7->AD7_CLI + HD7->AD7_LOJA
		HA1->(dbSetOrder(1))
		
		If !HA1->(dbSeek(cCliente))
			dbSelectArea("HD7")
			dbSkip()
			Loop
		EndIf

		If AllTrim(HD7->AD7_FLGVIS) == "1"
			cStr := "POSI"
		Elseif AllTrim(HD7->AD7_FLGVIS) == "2"
			cStr := "NPOS"
		Else
			cStr := "NVIS"
		Endif

		AADD(aClientes,{cStr,HA1->A1_NOME,HA1->A1_COD,HA1->A1_LOJA})
		AADD(aRoteiro,{HD7->AD7_PERCUR, HD7->AD7_ROTA,HD7->AD7_ORDEM})
     
		If RetStatus(HA1->A1_COD, HA1->A1_LOJA,, cTitulos) > 0
			GridSetCellColor(oCliente, Len(aClientes),1,CLR_HRED, CLR_WHITE)
			GridSetCellColor(oCliente, Len(aClientes),2,CLR_HRED, CLR_WHITE)
		Else
			GridSetCellColor(oCliente, Len(aClientes),1,CLR_WHITE, CLR_BLACK)
			GridSetCellColor(oCliente, Len(aClientes),2,CLR_WHITE, CLR_BLACK)
		EndIf 	     
		i++
	Endif
	dbSelectArea("HD7")
	dbSkip()	
Enddo
SetArray(oCliente,aClientes)
ChangeClient(@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus)
Return nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � SelectCliente       矨utor - Paulo Lima   � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Monta array com clientes de acordo com a Rota selecionada  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aRoteiro: Array dos Roteiros, aCLientes: Array a clientes  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
-北矨nalista    � Data   矼otivo da Alteracao                              潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function SelectCliente(aClientes,aRoteiro,nTop,lDown,oCliente,nRows)
Local cStr, i
Local cTitulos := ""

dbSelectArea("HA1")
dbSetOrder(2)
if Len(aClientes) > 0 
   dbGoTo(nTop)
else
   dbGoTop()
   nTop	:=HA1->(RecNo())
endif

HCF->(dbSetOrder(1))
If HCF->(dbSeek("MV_SFTPTIT"))
	//Tipos de titulos que nao devem ser considerados os venctos.
	cTitulos := AllTrim(HCF->CF_VALOR)
Endif

Asize(aClientes,0)
Asize(aRoteiro,0)

For i := 1 to nRows

  if HA1->A1_FLGVIS == "1"
    cStr := "POSI"
  elseif HA1->A1_FLGVIS == "2"
    cStr := "NPOS"
  else
    cStr := "NVIS"
  endif
//  cStr += "|"
//  cStr += HA1->A1_NOME

//  AADD(aClientes,cstr)
  AADD(aClientes,{cStr,HA1->A1_NOME,HA1->A1_COD,HA1->A1_LOJA})
  If RetStatus(HA1->A1_COD, HA1->A1_LOJA,, cTitulos) > 0
  	GridSetCellColor(oCliente, Len(aClientes),1,CLR_HRED, CLR_WHITE)
  	GridSetCellColor(oCliente, Len(aClientes),2,CLR_HRED, CLR_WHITE)
  Else
  	GridSetCellColor(oCliente, Len(aClientes),1, CLR_WHITE, CLR_BLACK)
  	GridSetCellColor(oCliente, Len(aClientes),2, CLR_WHITE, CLR_BLACK)
  EndIf
  HA1->(dbSkip())
  if HA1->(Eof())
     break
  endif
Next

if (oCliente != nil)
  SetArray(oCliente, aClientes)
endif

Return nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � ClientDown          矨utor - Paulo Lima   � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � PageDown no ListBox de Clientes							  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aRota: Array das Rotas, aRoteiro: Array dos Roteiros		  潮�
北�			 � aCLientes: Array a clientes								  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北矨nalista    � Data   矼otivo da Alteracao                              潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function ClientDown(nShow, oRota, oDia, oPesquisar, nCliente,oCliente, aClientes, aRota, aRoteiro, oCod,oEnd,oCGC,oLoja,oTel,oStatus,nTop,nRows)
Local nRec := HA1->(Recno()), i, nOldTop := nTop, bLoad := .t.
if Len(aClientes) == 0
	Return Nil
Endif

if nShow == 1
   dbSelectArea("HA1")
   dbSetOrder(2)
   dbGoTo(nTop)
   dbSkip(nRows)
   if !Eof()
      nTop := HA1->(Recno())
      SelectCliente(aClientes,aRoteiro,@nTop,.t.,oCliente,nRows)
      ChangeClient(@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus)
   else
     HA1->(dbGoTo(nRec))
   endif
else
	 
//   HRT->(dbSetOrder(2))
//   HRT->(dbSeek(aRota[nDia]))
	HRT->(dbSetOrder(1))
	HRT->(dbSeek(aRota[1,1] + aRota[2,1]))
 	dbSelectArea("HD7")
	dbSetOrder(1)
 	dbGoTo(nTop)

	for i := 1 to nRows
    	dbSelectArea("HD7")
      	dbSkip()
      	if !Eof() .AND. HD7->AD7_PERCUR == HRT->RT_PERCUR .And. HD7->AD7_ROTA == HRT->RT_ROTA
        	nTop := HD7->(Recno())
      	else
        	nTop := nOldTop
         	bLoad := .f.
        	break
      	endif
	next
   	if (bLoad)
//      aSize(aClientes,0)
//      aSize(aRoteiro,0)
		LoadRota(aRota,aRoteiro,@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,@ntop,nRows)
	endif
endif

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � ClientUp            矨utor - Paulo Lima   � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � PageUp no ListBox de Clientes							  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aRota: Array das Rotas, aRoteiro: Array dos Roteiros		  潮�
北�			 � aCLientes: Array a clientes								  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北矨nalista    � Data   矼otivo da Alteracao                              潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function ClientUp(nShow, oRota, oDia, oPesquisar, nCliente,oCliente, aClientes, aRota, aRoteiro, oCod,oEnd,oCGC,oLoja,oTel,oStatus,nTop,nRows)
Local nRec := HA1->(Recno()),i, nOldTop := nTop, bLoad := .t.

if Len(aClientes) == 0
	Return Nil
Endif

if nShow == 1
   HA1->(dbSetOrder(2))
   HA1->(dbGoTop())
   //if HA1->(Recno()) == nTop
   if HA1->(Bof())
      return
   endif
   HA1->(dbGoTo(nTop))
   HA1->(dbSkip(nRows*-1))
   nTop := HA1->(Recno())
   SelectCliente(aClientes,aRoteiro,@nTop,.f.,oCliente,nRows)
   ChangeClient(@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus)
else

//   HRT->(dbSetOrder(2))
//   HRT->(dbSeek(aRota[nDia]))
	HRT->(dbSetOrder(1))
	HRT->(dbSeek(aRota[1,1] + aRota[2,1]))

  HD7->(dbGoTo(nTop))
   for i := 1 to nRows
      HD7->(dbSkip(-1))
      if !HD7->(Bof()) .AND. HD7->AD7_PERCUR == HRT->RT_PERCUR .And. HD7->AD7_ROTA == HRT->RT_ROTA
         nTop := HD7->(Recno())
      else
         nTop := nOldTop
         bLoad := .f.
         break
      endif
   next
   if (bLoad)
//      aSize(aClientes,0)
//      aSize(aRoteiro,0)
	  LoadRota(aRota,aRoteiro,@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,@ntop,nRows)
   endif
endif

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � FindCustomer        矨utor - Paulo Lima   � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Busca por um determinado Cliente							  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aRota: Array das Rotas, aRoteiro: Array dos Roteiros		  潮�
北�			 � aCLientes: Array a clientes, cPesqName:conteudo da pesquisa潮�
北�			 � nPesqOrd: Ordem da pesquisa 								  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北矨nalista    � Data   矼otivo da Alteracao                              潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function FindCustomer(oPesqName,cPesqName,nPesqOrd,oRota, oDia, oPesquisar, nCliente,oCliente, aClientes,aRoteiro, aRota, oCod,oEnd,oCGC,oLoja,oTel,oStatus,nTop,nRows)

cPesqName	:= Upper(cPesqName)
SetText(oPesqName,cPesqName)

HA1->(dbSetOrder(nPesqOrd))
HA1->(dbSeek(AllTrim(cPesqName)))
if HA1->(Found())
   nTop := HA1->(Recno())
   SelectCliente(aClientes,aRoteiro,@nTop,.f.,oCliente,nRows)
   ChangeClient(@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus)
else
   Alert(STR0002) //"Cliente n鉶 localizado!"
endif

Return nil


/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � ZerarVisCli         矨utor - Paulo Lima   � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Zera visitas de cliente 									  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北矨nalista    � Data   矼otivo da Alteracao                              潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function ZerarVisCli()
Local cResp	:=""
cResp:=if(MsgYesOrNo(STR0003,STR0004),STR0005,STR0006) //"Voc� realmente deseja Zerar as Visitas dos Clientes?"###"Cancelar"###"Sim"###"N鉶"
if cResp=STR0006 //"N鉶"
	Return Nil
endif      
MsgStatus(STR0007) //"Zerando Visitas do Cliente..."
dbSelectArea("HA1")
dbSetOrder(1)
dbGoTop()
While !Eof()
	HA1->A1_FLGVIS	:= ""
	HA1->A1_OCO		:= ""
	dbCommit()
	dbSkip()
Enddo 
ClearStatus()
Return Nil
