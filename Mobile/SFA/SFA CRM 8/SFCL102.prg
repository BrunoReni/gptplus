#INCLUDE "SFCL102.ch"
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � DesceCli()          矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Funcao que controle o LIst de CLientes 			          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aCliente, nCliente - Array e Posicao do Cliente selecionado潮�
北� 		 � nCargMax - Numero maximo de clientes por pagina	          潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function DesceCli(aCliente, nCliente, oBrw, nTop,nCargMax,nCampo)

Local nRec := HA1->(Recno())
nCliente:=1

HA1->(dbGoTo(nTop))
HA1->(dbSkip(nCargMax))
If !Eof()
   nTop := HA1->(Recno())
   ListaCli(@nTop, aCliente, nCliente, oBrw,nCargMax,nCampo)
Else
   HA1->(dbGoTo(nRec))
EndIf

Return nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � ListaCli()          矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Funcao que atualiza o LIst de CLientes 					          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� aCliente, nCliente - Array e Posicao do Cliente selecionado潮�
北� 		 � nCargMax - Numero maximo de clientes por pagina			          潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function ListaCli(nTop, aCliente, nCliente, oBrw,nCargMax,nCampo)

Local i := 0

dbSelectArea("HA1")
dbSetOrder(nCampo)

if Len(aCliente) > 0 
   dbGoTo(nTop)
else
   //dbGoTop()
   dbSeek(RetFilial("HA1"))
endif                       

aSize(aCliente,0)
For i := 1 to nCargMax
    aAdd(aCliente, {HA1->HA1_COD,HA1->HA1_LOJA,AllTrim(HA1->HA1_NOME),HA1->HA1_CGC})
	dbSkip()
	If Eof()
	   break
	EndIf
Next

If (oBrw != nil)
	SetArray(oBrw, aCliente)
EndIf

Return nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � CrgProxCli()        矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Busca o proximo codigo para inclusao de Cliente			      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cCodCli - Codigo do Cliente                                潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function CrgProxCli(cCodCli)
Local nCodCli		:=0
Local lEncontrou	:= .F.

dbSelectArea("HA3")
dbSeek(RetFilial("HA3"))
//dbGoTop()

if Val(HA3->HA3_PROCLI) > Val(HA3->HA3_CLIFIM)
	MsgAlert(STR0001) //"A Faixa de C骴igo Cliente excedeu. Solicite a Retaguarda para encaminhar uma nova Faixa de C骴igo de Cliente"
	Return .F.
Endif

cCodCli	:=	AllTrim(HA3->HA3_PROCLI)

// -------------------------------------------------------------------------
// --> Faca ateh encontrar um Codigo Valido (Codigo nao existente na Tabeba) 
//     ou ter excedido a Faixa de Codigos.
// -------------------------------------------------------------------------
While lEncontrou == .F.
	dbSelectArea("HA1")
	dbSetOrder(1)
	dbSeek(RetFilial("HA1") + cCodCli)      
	if Found()
		nCodCli := Val(cCodCli)+1
		cCodCli	:= StrZero(nCodCli,6)	
		//Estorou a Faixa, sai da Funcao, sem permissao de Cadastrar o Cliente
		if nCodCli > Val(HA3->HA3_CLIFIM)
			MsgAlert(STR0001) //"A Faixa de C骴igo Cliente excedeu. Solicite a Retaguarda para encaminhar uma nova Faixa de C骴igo de Cliente"
			Return .F.
		Endif
	Else
		lEncontrou :=.T.
	Endif
Enddo

Return .T.

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � AtuaProxCli()       矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Atualiza o proximo codigo para inclusao de Cliente	      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cCodCli - Codigo do Cliente                                潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function AtuaProxCli(cCodCli)
//Atualiza o Prox. Cliente no HA3
Local nCodCli:=0
dbSelectArea("HA3")
//dbGoTop()
dbSeek(RetFilial("HA3"))
nCodCli:=Val(cCodCli) + 1
cCodCli:=StrZero(nCodCli,6)
HA3->HA3_PROCLI :=cCodCli
dbCommit()

Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � GrvCliente()        矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Grava dados do CLiente 					                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� nOpCli - Operacao (1 - Inclusao, 2 Alteracao)			  潮�
北�			 � cCodCli - Codigo do Cliente, cLojaCLi - Loja do CLiente 	  潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function GrvCliente(nOpCli,aCliCtrl,aCliObj,nTop,aCliente,nCliente,oBrw,nCargMax,nCampo)
Local nLc :=0.00

Local nPosCOD	 := ScanArray(aCliCtrl,"HA1_COD",,,1)
Local nPosLOJA	 := ScanArray(aCliCtrl,"HA1_LOJA",,,1)

If !VrfCliente(nOpCli, @aCliCtrl, @aCliObj)
	Return Nil
Endif

if nOpCli ==1 
	dbSelectArea("HCF")
  	dbSetOrder(1)
	dbSeek(RetFilial("HCF") + "MV_SFAPLC")
	if HCF->(Found())
		if !Empty(HCF->HCF_VALOR)
			nLc		:=Val(HCF->HCF_VALOR)
		else
			nLc		:=0.00  
		Endif
	else
		nLc		:=0.00
	Endif   
Endif

dbSelectArea("HA1")
dbSetOrder(1)

If nOpCli == 1
	dbAppend()
	HA1->HA1_FILIAL := RetFilial("HA1")
	HA1->HA1_COD	:=	aCliCtrl[nPosCOD,2]
	HA1->HA1_LOJA	:=	aCliCtrl[nPosLOJA,2]
	HA1->HA1_LC		:= 	nLc
	HA1->HA1_RISCO	:=	"B"
	HA1->HA1_STATUS	:=	"N"
Else
	dbSeek(RetFilial("HA1") + aCliCtrl[nPosCOD,2] + aCliCtrl[nPosLOJA,2] )
	If HA1->HA1_STATUS <>"N"
		HA1->HA1_STATUS	:="A"
	Endif
Endif

For nI:=3 to Len(aCliCtrl) // A partir do 3o item do array, desprezando Cliente e Loja pois ja foram gravados
	HA1->(FieldPut(HA1->(FieldPos(aCliCtrl[nI,1])), aCliCtrl[nI,2]))
Next 

HA1->HA1_VEND	:=	HA3->HA3_COD

dbCommit()

MsgAlert(STR0002 + aCliCtrl[nPosCOD,2] + STR0003) //"Cliente "###" gravado com sucesso"
CloseDialog()

//Atualiza o ListBox do Cliente
if nOpCli == 1
	dbSelectArea("HA1")
	dbSetOrder(2)
	dbSeek(RetFilial("HA1"))
	//dbGoTop()
	nTop := HA1->(Recno())    
	
	AtuaProxCli(aCliCtrl[nPosCOD,2])
Endif

ListaCli(@nTop, aCliente, nCliente, oBrw,nCargMax,nCampo)

Return Nil
