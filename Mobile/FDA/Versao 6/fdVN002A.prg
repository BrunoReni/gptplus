#INCLUDE "FDVN002A.ch"

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � switch              矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Alterna a visualizacao entre Roteiro e Clientes 			  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function switch(nShow, oRota,oDia, oPesquisar, nCliente, oCliente, aClientes, aRota, aRoteiro, oCod,oEnd,oCGC,oLoja,oTel,oStatus,nTop,nRows,oAniver)

aSize(aClientes,0)
aSize(aRoteiro,0)
if (nShow == 1 )
  HideControl(oRota)
  HideControl(oDia)  
  HideControl(oAniver)  
  ShowControl(oPesquisar)
  SelectCliente(aClientes,aRoteiro,@nTop,.t.,oCliente,nRows)
  ChangeClient(@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,oAniver)
else
  HideControl(oPesquisar)
  ShowControl(oRota)
  ShowControl(oDia)

  LoadRota(aRota,aRoteiro,@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,@ntop,nRows,oAniver)
endif
HCF->(dbSeek("MV_SFAVIEW"))
HCF->(dbSetOrder(1))
HCF->CF_VALOR := if ( nShow == 1, "C","R")

Return nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � ChangeClient        矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Apresenta dados do cliente selecionado       			  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function ChangeClient(nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,oAniver)	
Local cStCli:=""

if Len(aClientes) == 0 
   	SetText(oCod,Space(Len(HA1->A1_COD)))
   	SetText(oEnd,Space(Len(HA1->A1_END)))
   	SetText(oCGC,Space(Len(HA1->A1_CGC)))
   	SetText(oLoja,Space(Len(HA1->A1_LOJA)))
	SetText(oTel,Space(Len(HA1->A1_TEL)))
	SetText(oStatus,cStCli)
	nCliente:=0
	Return Nil
Endif
nCliente:=GridRow(oCliente)

dbSelectArea("HA1")
dbSetOrder(1)
dbGoTop()

//dbSeek(Substr(aClientes[nCliente],6),.f.)
dbSeek(aClientes[nCliente,3]+aClientes[nCliente,4],.f.)

SetText(oCod,HA1->A1_COD)
SetText(oEnd,HA1->A1_END)
SetText(oCGC,HA1->A1_CGC)
SetText(oLoja,HA1->A1_LOJA)
SetText(oTel,HA1->A1_TEL)

if oAniver<>Nil
  if Month(HA1->A1_DTNASC) == Month(Date())  
    ShowControl(oAniver)
  else
    HideControl(oAniver)   
  endif
endif

dbSelectArea("HX5")
dbSetOrder(1)
if dbSeek("SC" + HA1->A1_RISCO)
	cStCli:=AllTrim(HX5->X5_DESCRI)
else
	cStCli:=AllTrim(HA1->A1_RISCO)
Endif
SetText(oStatus,cStCli)

Return nil
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � SwitchRota          矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Seleciona Rota ativa						      			  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function SwitchRota(cRota, oDia, aRota,aRoteiro, nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,ntop,nRows,oAniver)

//Function ChangeRota(cRota, oDia, aRota,aRoteiro,nDia,nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,ntop,nRows)
Local aFldRota := {}, aIndRota := {}
Local cVar := ""

//Consulta Transportadora
Aadd(aFldRota,{STR0001,HRT->(FieldPos("RT_PERCUR")),40}) //"Percurso"
Aadd(aFldRota,{STR0002,HRT->(FieldPos("RT_ROTA")),40}) //"Rota"
Aadd(aFldRota,{STR0003,HRT->(FieldPos("RT_DESCR")),100}) //"Descricao"
Aadd(aIndRota,{STR0001,1}) //"Percurso"

SFConsPadrao("HRT", cRota, oDia, aFldRota, aIndRota, aRota)

//Exibe cod. da rota (19/02/2004)
If Len(aRota) > 0
	SetText(oDia,aRota[2,1])
Endif
aSize(aClientes,0)
aSize(aRoteiro,0)
LoadRota(aRota,aRoteiro,@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,@ntop,nRows,oAniver)
          
//aSize(aClientes,0)
//aSize(aRoteiro,0)
//LoadRota(aRota,aRoteiro,nDia,@nCliente,oCliente,aClientes,oCod,oEnd,oCGC,oLoja,oTel,oStatus,@ntop,nRows)

Return nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � ActivateSearch      矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Ativa busca de Clientes					      			  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function ActivateSearch(oCodLbl,oCod,oPesquisar,oEnd,oCGCLbl,oCGC,oLojaLbl,oLoja,oTelLbl,oTel,oStatusLbl,oStatus,oCbx,oPesqLbl,oPesqName,oPesqBtn,oPesqClose,oPesqOrd)

HideControl(oCodLbl)
HideControl(oCod)
HideControl(oPesquisar)
HideControl(oEnd)
HideControl(oCGCLbl)
HideCOntrol(oCGC)
HideControl(oLojaLbl)
HideCOntrol(oLoja)
hideControl(oTelLbl)
HideCOntrol(oTel)
HideControl(oStatusLbl)
HideControl(oStatus)
HideControl(oCbx)
ShowControl(oPesqLbl)
ShowControl(oPesqName)
ShowControl(oPesqBtn)
ShowControl(oPesqClose)
ShowControl(oPesqOrd)
SetFocus(oPesqName)
Return nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � DeActivateSearch    矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Destiva busca de Clientes				      			  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function DeActivateSearch(oCodLbl,oCod,oPesquisar,oEnd,oCGCLbl,oCGC,oLojaLbl,oLoja,oTelLbl,oTel,oStatusLbl,oStatus,oCbx,oPesqLbl,oPesqName,oPesqBtn,oPesqClose,oPesqOrd)

HideControl(oPesqLbl)
HideControl(oPesqName)
HideControl(oPesqBtn)
HideControl(oPesqClose)
HideControl(oPesqOrd)
ShowControl(oCodLbl)
ShowControl(oCod)
ShowControl(oPesquisar)
ShowControl(oEnd)
ShowControl(oCGCLbl)
ShowControl(oCGC)
ShowControl(oLojaLbl)
ShowControl(oLoja)
ShowControl(oTelLbl)
ShowControl(oTel)
ShowControl(oStatusLbl)
ShowControl(oStatus)
ShowControl(oCbx)
          	
Return nil
