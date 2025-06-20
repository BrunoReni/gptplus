#INCLUDE "FDPD101.ch"
#include "eADVPL.ch"
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � GetProduto()        矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Trata qual tela de Produto sera utilizada (basica/Avancada)潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cProduto - Codigo do Produto								  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function GetProduto(cProduto, aPrdPrefix)
Local lRet:= .F.
HCF->(dbSetOrder(1))
HCF->(dbSeek(RetFilial("HCF")+"MV_SFATPRO"))
if HCF->(Found()) 
	if AllTrim(HCF->HCF_VALOR) == "2" 
		//Basico
		GetPD2(@cProduto,@lRet, aPrdPrefix)
//    Elseif AllTrim(HCF->HCF_VALOR) == "3" 
    	// Especifico (Ponto de entrada)
	Else
    	 //Avancado (Tela Padrao de Produto)
		GetPD1(@cProduto,@lRet, aPrdPrefix)
	Endif
Else  
   	 //Avancado (Tela Padrao de Produto)
	GetPD1(@cProduto,@lRet, aPrdPrefix)
Endif
Return lRet

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � PD1Load()           矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Carrega List de Produto para a consulta avancada           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� nTop      - Posicao do registro							  潮�
北�          � cGrupo    - Codigo do grupo  							  潮�
北�          � oLbx      - Listbox de produto							  潮�
北�          � lPaginacao- Indica se a funcao foi chamada a partir dos	  潮�
北�          � 			   botoes de paginacao (Up ou Down)				  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
//Function PD1Load(nTop,cGrupo,aProduto,oLbx)
Function PD1Load(nTop,cGrupo,oLbx,lPaginacao)
Local i       
Local nCargMax:=GetListRows(oLbx)

if nTop == 0 
  HB1->(dbSetOrder(3))
  HB1->(dbSeek(RetFilial("HB1")+cGrupo))
  if !HB1->(Eof())
    nTop := HB1->(Recno())
  endif
else
  HB1->(dbGoTo(nTop))
endif        

//Alert(nTop)
If (Empty(cGrupo) .Or. cGrupo <> cUltGrupo) .Or. (lPaginacao == .T.)
	aSize(aProduto,0)
	For i := 1 to nCargMax
	   if !HB1->(Eof()) .and. (HB1->HB1_GRUPO == cGrupo .Or. Empty(cGrupo))
		  AADD(aProduto,AllTrim(HB1->HB1_DESC))
	   else
		  break
	   endif
	   HB1->(dbSkip())
	Next                   
	cUltGrupo := cGrupo 	//atualiza ult. grupo selecionado
	SetArray(oLbx,aProduto)
Endif

Return nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � PD1Down()           矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Tratamento da navegacao do List de Produto                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aProduto - Array de Produtos								  潮�
北�          � cGrupo   - Codigo do grupo  								  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
//Function PD1Down(nTop,cGrupo,aProduto,oLbx,nOrder)
Function PD1Down(nTop,cGrupo,oLbx,nOrder)

HB1->(dbGoTo(nTop))
HB1->(dbSkip(GetListRows(oLbx)))
if ( !HB1->(Eof()) .and. ( nOrder != 3 .OR. HB1->HB1_GRUPO == cGrupo) )
   nTop := HB1->(Recno())
else
   return nil
endif
//Return PD1Load(@nTop,cGrupo,aProduto,oLbx)
Return PD1Load(@nTop,cGrupo,oLbx,.T.)

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � PD1Up()             矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Tratamento da navegacao do List de Produto                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aProduto - Array de Produtos								  潮�
北�          � cGrupo   - Codigo do grupo  								  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
//Function PD1Up(nTop,cGrupo,aProduto,oLbx,nOrder)
Function PD1Up(nTop,cGrupo,oLbx,nOrder)

HB1->(dbGoTo(nTop))
HB1->(dbSkip(-GetListRows(oLbx)))
if ( !HB1->(Bof()) .And. (nOrder != 3 .OR. HB1->HB1_GRUPO == cGrupo) )
   nTop := HB1->(Recno())
else 
	If Empty(cGrupo)	
		HB1->(dbGoTop())
   		nTop := HB1->(Recno())
  	Else
  		nTop := 0	//return nil
  	Endif
endif
//Return PD1Load(@nTop,cGrupo,aProduto,oLbx)
Return PD1Load(@nTop,cGrupo,oLbx,.T.)

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � PD1Find()           矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Busca do Produto								              潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cProduto - Codigo do Produto								  潮�
北�          � aGrupo, nGrupo - Array e Posicao do grupo				  潮�
北�          � aControls - Array de Controles							  潮�
北�          � lCodigo - Busca por Codigo (T ou F) 						  潮�
北�          � aPrecos - Array de Precos								  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function PD1Find(cPesq,lCodigo,aGrupo,nGrupo,cProduto,aControls,oProd,aPrecos,oBox, aPrdPrefix)
Local nOrder := if(lCodigo,1,2)
Local cPrefixo := ""

cPesq := Upper(cPesq)    
If !Empty(aPrdPrefix[1,1]) .And. nOrder = 1
	If Empty(aPrdPrefix[1,3])
		cPrefixo := Replicate(aPrdPrefix[1,1], aPrdPrefix[1,2])
	Else
		cPrefixo := Replicate(aPrdPrefix[1,1], Val(aPrdPrefix[1,3]) - Len(cPesq))		
	EndIf
	If At(cPrefixo, cPesq) = 0
		cPesq := cPrefixo + cPesq
	EndIf
EndIf

dbSelectArea("HB1")
HB1->(dbSetOrder(nOrder)) 
HB1->(dbSeek(RetFilial("HB1")+cPesq))
if HB1->(Found())      
	//Alert(cPesq)
	//Alert(HB1->(Recno()))
	PD1Browse(aGrupo,nGrupo,@cProduto,aControls,oProd,aPrecos,oBox,HB1->(Recno()),nOrder)
else
    MsgStop(STR0001,STR0002) //"Produto n鉶 localizado!"###"Pesquisa Produto"
endif
Return nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � PD1End()            矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Atualiza o Codigo do Produto                               潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cProduto - Codigo do Produtos							  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function PD1End(lRet,cProduto)

lRet := if ( Len(cProduto) > 0 , .t., .f.)
CloseDialog()

Return nil