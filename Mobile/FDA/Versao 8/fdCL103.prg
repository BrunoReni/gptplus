#INCLUDE "FDCL103.ch"
/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � VrfCliente()        矨utor: Paulo Amaral  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Valida dados do CLiente 									  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� cCodCli - Codigo do Cliente, cLojaCLi - Loja do CLiente    潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪牧哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function VrfCliente(cCodCli,cLojaCli,cTipo,cRazao,cFantasia,cEndereco,cBairro,cCep,cCidade,cUF,cTel,cCGC,cIE,cEmail)
Local cMsg := "", lCGCRet

cCodCli 	:= Alltrim(cCodCli)
cLojacli	:= AllTrim(cLojaCli)
cTipo		:= AllTrim(cTipo)
cRazao		:= AllTrim(cRazao)
cRazao		:= Upper(cRazao)
cFantasia	:= AllTrim(cFantasia)
cFantasia	:= Upper(cFantasia)
cEndereco	:= AllTrim(cEndereco)
cEndereco	:= Upper(cEndereco)
cBairro		:= AllTrim(cBairro)
cBairro		:= Upper(cBairro)
cCep		:= AllTrim(cCep)
cCidade		:= AllTrim(cCidade)
cCidade		:= Upper(cCidade)
cUF			:= AllTrim(cUF)
cUF			:= Upper(cUF)
cTel		:= AllTrim(cTel)
cCGC		:= AllTrim(cCGC)
cIE  		:= AllTrim(cIE)
cEmail		:= AllTrim(cEmail)

if Empty(cCodcli)
	MsgStop(STR0001,STR0002) //"Escreva o C骴igo do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cLojacli)
	MsgStop(STR0003,STR0002) //"Escreva a Loja do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cTipo)
	MsgStop(STR0004,STR0002) //"Escolha o Tipo do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cRazao)		
	MsgStop(STR0005,STR0002) //"Escreva a Raz鉶 Social do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cFantasia)		
	MsgStop(STR0006,STR0002) //"Escreva o Nome Fantasia do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cEndereco)		
	MsgStop(STR0007,STR0002) //"Escreva o Endere鏾 do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cBairro)		
	MsgStop(STR0008,STR0002) //"Escreva o Bairro do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cCep)		
	MsgStop(STR0009,STR0002) //"Escreva o Cep do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cCidade)		
	MsgStop(STR0010,STR0002) //"Escreva a Cidade do Endere鏾 do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cUF)		
	MsgStop(STR0011,STR0002) //"Escreva o UF do Endere鏾 do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cTel)		
	MsgStop(STR0012,STR0002) //"Escreva o Telefone do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif Empty(cCGC)
	MsgStop(STR0013,STR0002) //"Escreva o CGC do Cliente!"###"Verifica Cliente"
	Return .F.
Elseif !Empty(cCGC)
	If Len(cCGC) <= 11  // Tamanho do CPF
		lCGCRet := ValidCPF(cCGC)
		cMsg := STR0014 //"CPF"
	Else
		lCGCRet := ValidCGC(cCGC)
		cMsg := STR0015 //"CGC"
	EndIf
	If !lCGCRet
		MsgStop(cMsg + STR0016,STR0002) //" Inv醠ido!"###"Verifica Cliente"
		Return .F.
	EndIf
Endif	

Return .T.

Function ExcCliente(cCodCli, cLojaCli,nTop,aCliente,nCliente,oBrw,nCargMax,nCampo)
Local cResp	:= ""
cResp:= if(MsgYesOrNo(STR0017,STR0018),"Sim","N鉶") //"Voc� deseja Excluir o Cliente Selecionado?"###"Cancelar"
If cResp="Sim"
	dbSelectArea("HC5")
	dbSetOrder(2)
	dbSeek( RetFilial("HC5")+cCodCli+cLojaCli,.f. )
	While !Eof() .and. HC5->HC5_FILIAL == RetFilial("HC5") .and. HC5->HC5_CLI == cCodCli .and. HC5->HC5_LOJA == cLojaCli
		If HC5->HC5_STATUS = "N"
			MsgAlert(STR0019,STR0020) //"N鉶 ser� poss韛el excluir, existem pedidos para este Cliente!"###"Aviso"
			return nil
		Endif
		dbSkip()
	Enddo   

	dbSelectArea("HU5")
	dbSetOrder(2)
	dbSeek( RetFilial("HU5")+cCodCli+cLojaCli,.f. )
	While !Eof() .And. HU5->HU5_FILIAL == RetFilial("HU5") .And. HU5->HU5_CLIENTE == cCodCli .And. HU5->HU5_LOJA == cLojaCli
		If HU5->HU5_STATUS = "N"
			MsgAlert(STR0021,STR0020) //"N鉶 ser� poss韛el excluir, existem novos contatos para este Cliente!"###"Aviso"
			return nil
		Endif
		dbSkip()
	Enddo   
	dbSelectArea("HA1")
	dbSetOrder(1)
	dbSeek(RetFilial("HA1")+cCodCli + cLojaCli)
	If HA1->(Found()) 
		dbDelete()
		dbSkip()
		MsgAlert(STR0022,STR0020) //"Cliente Exclu韉o com Sucesso!"###"Aviso"
	Endif
	CloseDialog()	

	//Atualiza o Browse do Cliente
	dbSelectArea("HA1")
	dbSetOrder(nCampo)
	dbGoTop()
	nTop := HA1->(Recno())
	ListaCli(@nTop, aCliente, nCliente, oBrw,nCargMax,nCampo)	
Endif

Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � LoadUF()        	   矨utor: Fabio Garbin  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Carrega as UFs do Brasil       	 			     		  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function LoadUF(aUF, nUf, cUf)
Local cAlias  := Alias()
Local cTabela := "UF"

dbSelectArea("HX5")  
dbSetOrder(1)
If dbSeek(RetFilial("HX5")+cTabela)
	While !Eof() .And. HX5->HX5_FILIAL == RetFilial("HX5") .And. HX5->HX5_TABELA == cTabela
		AADD(aUf, AllTrim(HX5->HX5_CHAVE) + "-"	+ AllTrim(HX5->HX5_DESCRI))
		If HX5->HX5_CHAVE = cUf
			nUf := Len(aUf)
		EndIf
		dbSkip()
	Enddo
EndIf
Return Nil

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪勘�
北矲un嘺o    � AtualUf()           矨utor: Fabio Garbin  � Data �         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪幢�
北矰escri嘺o � Seleciona a UF											  潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
*/
Function AtualUf(aUf, cUf, nUf)
cUf := SubStr(aUf[nUf],1,2)
Return Nil
