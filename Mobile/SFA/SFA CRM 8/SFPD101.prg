
#INCLUDE "SFPD101.ch"
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
Local lRet   := .F. 
Local aParam := {}

HCF->(dbSetOrder(1))
HCF->(dbSeek(RetFilial("HCF") + "MV_SFATPRO"))
If HCF->(Found()) 
	If AllTrim(HCF->HCF_VALOR) == "2" 
		//Basico
		GetPD2(@cProduto,@lRet, aPrdPrefix)
	Elseif AllTrim(HCF->HCF_VALOR) == "3" .AND. ExistBlock("SFAPD001")
		aAdd(aParam, cProduto)
	    aAdd(aParam, lRet)
	    aAdd(aParam, aPrdPrefix)
		
		//Especifico (Ponto de entrada)
		//ExecBlock("SFAPD001", .F., .F., {@cProduto,@lRet,aPrdPrefix})
		ExecBlock("SFAPD001", .F., .F., aParam)
		 
		cProduto := aParam[1]
		lRet := aParam[2]
		aAdd(aPrdPrefix,aParam[3])
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
北�          � oBrwProd  - Listbox de produto							  潮�
北�          � lPaginacao- Indica se a funcao foi chamada a partir dos	  潮�
北�          � 			   botoes de paginacao (Up ou Down)				  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function PD1Load(nTop,cGrupo,oBrwProd,lPaginacao,nOrder,cProduto)
Local i 		:=	0     
Local nCargMax	:=	GridRows(oBrwProd)
Local cPesqFabr	:=	""

DEFAULT cProduto := ""

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//砎erifica o parametro MV_SFACPRF   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
dbSelectArea("HCF")
dbSetorder(1)
If dbSeek(RetFilial("HCF") + "MV_SFACPRF")//Habilita a consulta do produto pelo codigo do produto no fabricante
	cPesqFabr := AllTrim(Upper(HCF->HCF_VALOR))
Else
	cPesqFabr := "N"
Endif

HB1->(dbSetOrder(1))
If !Empty(cProduto)
	If HB1->(dbSeek(RetFilial("HB1")+cProduto))
		If nOrder > 2
			cProduto := HB1->HB1_DESC
		EndIf
	EndIf
EndIf

If cPesqFabr == "S"
	If Select("HA5")>0
		If nOrder == 3
			cUltGrupo := ""
			If nTop == 0 
				HA5->(dbSetOrder(1))
				If HA5->(dbSeek(RetFilial("HA5")))
			    	nTop := HA5->(Recno())
			  	endif
			else
				HA5->(dbGoTo(nTop))
			endif
			aSize(aProduto,0)
			For i := 1 to nCargMax
				If !HA5->(Eof())
					If HB1->(dbSeek(RetFilial("HB1")+HA5->HA5_PRODUT))
						AADD(aProduto,{HA5->HA5_CODPRF, HB1->HB1_COD, HB1->HB1_DESC})
			   		EndIf
				Else
					break
				endif
				HA5->(dbSkip())
			Next                   
			SetArray(oBrwProd,aProduto)
		End
	EndIf
EndIf
If nOrder == 1 .Or. nOrder == 2 
	cUltGrupo := ""
//	If lPaginacao
		HB1->(dbSetOrder(nOrder))
		If nTop == 0 
			If HB1->(dbSeek(RetFilial("HB1") + cProduto))
		    	nTop := HB1->(Recno())
		  	endif
		else
			HB1->(dbGoTo(nTop))
		endif
		aSize(aProduto,0)
		For i := 1 to nCargMax
			if !HB1->(Eof())
				AADD(aProduto,{HB1->HB1_DESC,HB1->HB1_COD})
			else
				break
			endif
			HB1->(dbSkip())
		Next                   
		SetArray(oBrwProd,aProduto)
//	Endif
ElseIf nOrder != 3
	HB1->(dbSetOrder(3))
	If nTop == 0  
   	   If (HB1->HB1_GRUPO) == (cGrupo)
          HB1->(dbSeek(RetFilial("HB1") + (cGrupo) + cProduto))
          nTop := HB1->(Recno())
       Else
	      HB1->(dbSeek(RetFilial("HB1") + (cGrupo)))   
          nTop := HB1->(Recno()) 
       Endif
    Else 
       HB1->(dbGoTo(nTop))
    Endif        
	//If (Empty(cGrupo) .Or. cGrupo <> cUltGrupo) .Or. (lPaginacao == .T.)
		aSize(aProduto,0)
		For i := 1 to nCargMax
			if !HB1->(Eof()) .and. (AllTrim(HB1->HB1_GRUPO) == AllTrim(cGrupo) .Or. Empty(cGrupo))
				AADD(aProduto,{HB1->HB1_DESC,HB1->HB1_COD})
			else
				break
			endif
			HB1->(dbSkip())
		Next                   
		cUltGrupo := cGrupo 	//atualiza ult. grupo selecionado
		SetArray(oBrwProd,aProduto)
	//Endif
EndIf	
SetFocus(oBrwProd)
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
//Function PD1Down(nTop,cGrupo,aProduto,oBrwProd,nOrder)
Function PD1Down(nTop,cGrupo,oBrwProd,nOrder)
Local cPesqFabr	:=	""

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//砎erifica o parametro MV_SFACPRF   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
dbSelectArea("HCF")
dbSetorder(1)
If dbSeek(RetFilial("HCF") + "MV_SFACPRF")//Habilita a consulta do produto pelo codigo do produto no fabricante
	cPesqFabr := AllTrim(Upper(HCF->HCF_VALOR))
Else
	cPesqFabr := "N"
Endif

If cPesqFabr == "S"
    If Select("HA5")>0 
		If nOrder == 3
			HA5->(dbGoTo(nTop))
			HA5->(dbSkip(GridRows(oBrwProd)))
			if !HA5->(Eof()) 
			   nTop := HA5->(Recno())
			else
			   return nil
			endif
		End  
	EndIf	
EndIf
If nOrder == 1 .Or. nOrder == 2
	HB1->(dbGoTo(nTop))
	HB1->(dbSkip(GridRows(oBrwProd)))
	if !HB1->(Eof())
	   nTop := HB1->(Recno())
	else
	   return nil
	endif
ElseIf nOrder != 3
	HB1->(dbsetOrder(3))
	HB1->(dbGoTo(nTop))
	HB1->(dbSkip(GridRows(oBrwProd)))
	if ( !HB1->(Eof()) .and. HB1->HB1_GRUPO == cGrupo )
	   nTop := HB1->(Recno())
	else
	   return nil
	endif	
EndIf
//Return PD1Load(@nTop,cGrupo,aProduto,oBrwProd)
Return PD1Load(@nTop,cGrupo,oBrwProd,.T.,nOrder)

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
//Function PD1Up(nTop,cGrupo,aProduto,oBrwProd,nOrder)
Function PD1Up(nTop,cGrupo,oBrwProd,nOrder)
Local cPesqFabr	:=	""

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//砎erifica o parametro MV_SFACPRF   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
dbSelectArea("HCF")
dbSetorder(1)
If dbSeek(RetFilial("HCF") + "MV_SFACPRF")//Habilita a consulta do produto pelo codigo do produto no fabricante
	cPesqFabr := AllTrim(Upper(HCF->HCF_VALOR))
Else
	cPesqFabr := "N"
Endif

If cPesqFabr == "S"
	If Select("HA5")>0	
		If nOrder == 3
			HB1->(dbSetOrder(3))
			HA5->(dbGoTo(nTop))
			HA5->(dbSkip(-GridRows(oBrwProd)))
			If !HA5->(Bof()) 
			   nTop := HA5->(Recno())
			Else
				HA5->(dbSeek(RetFilial("HA5")))
				nTop := HA5->(Recno())
			EndIf
		End
	EndIf
EndIf
If  nOrder == 1 .Or. nOrder == 2
	HB1->(dbSetOrder(nOrder))
	HB1->(dbGoTo(nTop))
	HB1->(dbSkip(-GridRows(oBrwProd)))
	If !HB1->(Bof())
	   nTop := HB1->(Recno())
	Else 
		HB1->(dbSeek(RetFilial("HB1")))
		nTop := HB1->(Recno())
	Endif
ElseIf nOrder != 3
	HB1->(dbsetOrder(3))
	HB1->(dbGoTo(nTop))
	HB1->(dbSkip(-GridRows(oBrwProd)))
	if ( !HB1->(Bof()) .and. HB1->HB1_GRUPO == cGrupo )
	   nTop := HB1->(Recno())
	Else
	   	HB1->(dbSeek(RetFilial("HB1")+cGrupo))
		nTop := HB1->(Recno())
	endif	
EndIf
//Return PD1Load(@nTop,cGrupo,aProduto,oBrwProd)
Return PD1Load(@nTop,cGrupo,oBrwProd,.T.,nOrder)

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
Function PD1Find(cPesq,nOrder,aGrupo,nGrupo,cProduto,aControls,oProd,aPrecos,oBox, aPrdPrefix)
Local cPrefixo := ""
Local cPesqFabr	:=	""

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//砎erifica o parametro MV_SFACPRF   �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
dbSelectArea("HCF")
dbSetorder(1)
If dbSeek(RetFilial("HCF") + "MV_SFACPRF")//Habilita a consulta do produto pelo codigo do produto no fabricante
	cPesqFabr := AllTrim(Upper(HCF->HCF_VALOR))
Else
	cPesqFabr := "N"
Endif

cPesq := Upper(cPesq)    

If !Empty(aPrdPrefix[1,1]) .And. nOrder == 1
	If Empty(aPrdPrefix[1,3])
		cPrefixo := Replicate(aPrdPrefix[1,1], aPrdPrefix[1,2])
	Else
		cPrefixo := Replicate(aPrdPrefix[1,1], Val(aPrdPrefix[1,3]) - Len(cPesq))		
	EndIf
	If At(cPrefixo, cPesq) = 0
		cPesq := cPrefixo + cPesq
	EndIf
EndIf
HB1->(dbSetOrder(1))
If nOrder == 3
	If !Empty(cPesq) 
		If cPesqFabr == "S"
			If Select("HA5")>0
				HA5->(dbSetOrder(1))
				If HA5->(dbSeek(RetFilial("HA5")+cPesq))
					cPesq := HA5->HA5_PRODUT
				Else
					cPesq := ""	
				EndIf
			EndIf	
		EndIf
	EndIf
Else
	HB1->(dbSetOrder(nOrder)) 
EndIf

dbSelectArea("HB1")
HB1->(dbSeek(RetFilial("HB1") + cPesq))
if HB1->(Found()) .And. !Empty(cPesq)      
	If nOrder == 3 
		If cPesqFabr == "S"
			If Select("HA5")>0
				PD1Browse(aGrupo,nGrupo,@cProduto,aControls,oProd,aPrecos,oBox,HA5->(Recno()),nOrder)
			EndIf
		EndIf
	Else
		PD1Browse(aGrupo,nGrupo,@cProduto,aControls,oProd,aPrecos,oBox,HB1->(Recno()),nOrder)
	EndiF
Else
    MsgStop(STR0001,STR0002) //"Produto n鉶 localizado!"###"Pesquisa Produto"
Endif
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
