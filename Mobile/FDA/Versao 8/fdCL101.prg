#INCLUDE "FDCL101.ch"
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � ClickClient()       矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Funcao de Selecionar o Cliente do Browse (Lista)           潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aCliente, nCliente - Array e Posicao do Cliente selecionado潮�
北� 		 � oBrw - Browse do Cliente									  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   � nCliente - Posicao do Cliente selecionado				  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function ClickClient(nCliente,aCliente,oBrw)
if len(aCliente) == 0
	nCliente:= 0
Else 
	nCliente:=GridRow(oBrw)
Endif		               

Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � CLOrder()  	       矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Altera a Ordenacao do Cliente no Browse			          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aCliente, nCliente - Array e Posicao do Cliente selecionado潮�
北� 		 � nTop - Armazena ultima posicao(registro) da tabela		  潮�
北� 		 � nCargMax - Carga Maxima por Paginacao					  潮�
北� 		 � nCampo - Ordem   										  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function CLOrder(nCliente,oBrw,aCliente,nTop,nCargMax,nCampo)
Local i:=1, c3oInd:=""

dbSelectArea("HA1") 

//01/06/2004
if nCampo==3 // Sera uma pesquisa por CnPj
   MsgStatus(STR0001) //"Aguarde... criando indice"
   c3oInd:="HA1"+cEmpresa+"3"
   INDEX ON Alltrim(HA1->HA1_CGC) TO c3oInd 
   ClearStatus()
endif
//01/06/2004

dbSetOrder(nCampo)
dbGoTo(nTop)
aSize(aCliente,0)

CLChangeColun(@nCliente,oBrw,nCampo)

For i := 1 to nCargMax
	aAdd(aCliente, {HA1->HA1_COD,HA1->HA1_LOJA,AllTrim(HA1->HA1_NOME),HA1->HA1_CGC })
	dbSkip()
	If Eof()
		break
	EndIf
Next
SetArray(oBrw, aCliente)

Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � PesquisaCli()       矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Funcao de pesquisa do cadastro de clientes                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cPesquisa - valor a ser pesquisado                         潮�
北�			 � aCampo, nCampo - Array do Criterio de pesquisa de clientes 潮�
北� 		 � aCliente, nCliente - Array e Posicao do Cliente selecionado潮�
北� 		 � nCargMax - Numero maximo de clientes por pagina			  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function PesquisaCli(cPesquisa, oPesquisaTx, oBrw, aCliente, nCliente, nTop, aCampo, nCampo,nCargMax)
Local nRec := 0, i := 1, cCriterio := Substr(aCampo[nCampo],1,1)
Local cAux	:=""
cPesquisa	:= Upper(cPesquisa)
SetText(oPesquisaTx,cPesquisa)
If nCampo == 2 //pesquisa por Nome
	dbSelectArea("HA1")
	dbSetOrder(2)
	dbSeek(RetFilial("HA1")+cPesquisa)
	
	If HA1->(Found())
		nRec := HA1->(Recno())
		cPesquisa := HA1->HA1_NOME
		//SetText(oPesquisaTx, cPesquisa)
		
		dbGoTo(nRec)
		aSize(aCliente,0)
		For i := 1 to nCargMax
//			aAdd(aCliente, Alltrim(HA1->HA1_NOME))
			aAdd(aCliente, {HA1->HA1_COD,HA1->HA1_LOJA,AllTrim(HA1->HA1_NOME)})
			dbSkip()
			If Eof()
			   break
			EndIf
		Next
		
		nTop := nRec // Atualiza nTop com a posicao localizada na tabela
		SetArray(oBrw, aCliente)
	Else
		MsgAlert(STR0002,STR0003) //"Cliente nao encontrado!"###"Aviso"
		cPesquisa := ""
	EndIf
	Return Nil

ElseIf nCampo=1 //Pesquisa por codigo
	dbSelectArea("HA1")
	dbSetOrder(1)
	dbSeek(RetFilial("HA1")+cPesquisa)
	
	If HA1->(Found())
		cAux	:= HA1->HA1_NOME
		//dbSelectArea("HA1")
		//dbSetOrder(2)
		//dbSeek(cAux)
	
        //if HA1->(Found())
			nRec := HA1->(Recno())
		
			dbGoTo(nRec)
			aSize(aCliente,0)
			For i := 1 to nCargMax
				aAdd(aCliente, {HA1->HA1_COD,HA1->HA1_LOJA,AllTrim(HA1->HA1_NOME),HA1->HA1_CGC})
				dbSkip()
				If Eof()
				   break
				EndIf
			Next
			
			nTop := nRec // Atualiza nTop com a posicao localizada na tabela
			SetArray(oBrw, aCliente)
		//Else
		//	MsgAlert(STR0001,STR0002) //"Cliente nao encontrado!"
		//	cPesquisa := ""
		//	cAux	  :=""
		//Endif
	Else
		MsgAlert(STR0002,STR0003) //"Cliente nao encontrado!"###"Aviso"
		cPesquisa := ""
	EndIf
	Return

ElseIf nCampo == 3 .And. Substr(aCampo[nCampo],3,1)="P"  //Pesquisa por CnPj         
	dbSelectArea("HA1")
	dbSetOrder(3)
	dbSeek(RetFilial("HA1")+cPesquisa)
	If HA1->(Found())
		nRec := HA1->(Recno())
		cPesquisa := HA1->HA1_CGC
		dbGoTo(nRec)
		aSize(aCliente,0)
		For i := 1 to nCargMax
			aAdd(aCliente, {HA1->HA1_COD,HA1->HA1_LOJA,AllTrim(HA1->HA1_NOME),AllTrim(HA1->HA1_CGC)})
			dbSkip()
			If Eof()
			   break
			EndIf
		Next
		nTop := nRec // Atualiza nTop com a posicao localizada na tabela
		SetArray(oBrw, aCliente)
	Else
		MsgAlert(STR0004,STR0003) //"CNPJ/CPF de Cliente nao encontrado!"###"Aviso"
		cPesquisa := ""
	EndIf 
	Return 	
EndIf

Return nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � SobeCli()           矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Funcao que controle o LIst de CLientes 					  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aCliente, nCliente - Array e Posicao do Cliente selecionado潮�
北� 		 � nCargMax - Numero maximo de clientes por pagina			  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function SobeCli(aCliente, nCliente, oBrw, nTop,nCargMax,nCampo)
Local nRec := HA1->(Recno())
nCliente:=1

HA1->(dbGoTop())
If HA1->(Recno()) == nTop
	return
EndIf
HA1->(dbGoTo(nTop))
HA1->(dbSkip(-nCargMax))
nTop := HA1->(Recno())
ListaCli(@nTop, aCliente, nCliente, oBrw,nCargMax,nCampo)

Return nil
