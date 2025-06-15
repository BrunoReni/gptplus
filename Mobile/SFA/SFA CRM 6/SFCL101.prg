#INCLUDE "SFCL101.ch"
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � ClickClient()       �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcao de Selecionar o Cliente do Browse (Lista)           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aCliente, nCliente - Array e Posicao do Cliente selecionado���
��� 		 � oBrw - Browse do Cliente									  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � nCliente - Posicao do Cliente selecionado				  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function ClickClient(nCliente,aCliente,oBrw)
if len(aCliente) == 0
	nCliente:= 0
Else 
	nCliente:=GridRow(oBrw)
Endif		               

Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CLOrder()  	       �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Altera a Ordenacao do Cliente no Browse			          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aCliente, nCliente - Array e Posicao do Cliente selecionado���
��� 		 � nTop - Armazena ultima posicao(registro) da tabela		  ���
��� 		 � nCargMax - Carga Maxima por Paginacao					  ���
��� 		 � nCampo - Ordem   										  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function CLOrder(nCliente,oBrw,aCliente,nTop,nCargMax,nCampo)

Local i:=1, c3oInd:=""

dbSelectArea("HA1")
if nCampo==3 // Sera uma pesquisa por CnPj
   MsgStatus("Aguarde... criando indice")
   c3oInd:="HA1"+cEmpresa+"3"
   INDEX ON Alltrim(HA1->A1_CGC) TO c3oInd 
   ClearStatus()
endif
dbSetOrder(nCampo)
dbGoTo(nTop)
aSize(aCliente,0)

CLChangeColun(@nCliente,oBrw,nCampo)

For i := 1 to nCargMax
	aAdd(aCliente, {HA1->A1_COD,HA1->A1_LOJA,AllTrim(HA1->A1_NOME),HA1->A1_CGC })
	dbSkip()
	If Eof()
		break
	EndIf
Next
SetArray(oBrw, aCliente)

Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � PesquisaCli()       �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcao de pesquisa do cadastro de clientes                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cPesquisa - valor a ser pesquisado                         ���
���			 � aCampo, nCampo - Array do Criterio de pesquisa de clientes ���
��� 		 � aCliente, nCliente - Array e Posicao do Cliente selecionado���
��� 		 � nCargMax - Numero maximo de clientes por pagina			  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function PesquisaCli(cPesquisa, oPesquisaTx, oBrw, aCliente, nCliente, nTop, aCampo, nCampo,nCargMax)
Local nRec := 0, i := 1, cCriterio := Substr(aCampo[nCampo],1,1)
Local cAux	:=""
cPesquisa	:= Upper(cPesquisa)
SetText(oPesquisaTx,cPesquisa)
If nCampo == 2 //pesquisa por Nome
	dbSelectArea("HA1")
	dbSetOrder(2)
	dbSeek(cPesquisa)
	
	If HA1->(Found())
		nRec := HA1->(Recno())
		cPesquisa := HA1->A1_NOME
		//SetText(oPesquisaTx, cPesquisa)
		
		dbGoTo(nRec)
		aSize(aCliente,0)
		For i := 1 to nCargMax
//			aAdd(aCliente, Alltrim(HA1->A1_NOME))
			aAdd(aCliente, {HA1->A1_COD,HA1->A1_LOJA,AllTrim(HA1->A1_NOME)})
			dbSkip()
			If Eof()
			   break
			EndIf
		Next
		
		nTop := nRec // Atualiza nTop com a posicao localizada na tabela
		SetArray(oBrw, aCliente)
	Else
		MsgAlert(STR0001,STR0002) //"Cliente nao encontrado!"###"Aviso"
		cPesquisa := ""
	EndIf
	Return Nil

ElseIf nCampo=1 //Pesquisa por codigo
	dbSelectArea("HA1")
	dbSetOrder(1)
	dbSeek(cPesquisa)
	
	If HA1->(Found())
		cAux	:= HA1->A1_NOME
		//dbSelectArea("HA1")
		//dbSetOrder(2)
		//dbSeek(cAux)
	
        //if HA1->(Found())
			nRec := HA1->(Recno())
		
			dbGoTo(nRec)
			aSize(aCliente,0)
			For i := 1 to nCargMax
				aAdd(aCliente, {HA1->A1_COD,HA1->A1_LOJA,AllTrim(HA1->A1_NOME),HA1->A1_CGC})
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
		MsgAlert(STR0001,STR0002) //"Cliente nao encontrado!"###"Aviso"
		cPesquisa := ""
	EndIf
	Return

ElseIf nCampo == 3 .And. Substr(aCampo[nCampo],3,1)="P"  //Pesquisa por CnPj         
	dbSelectArea("HA1")
	dbSetOrder(3)
	dbSeek(cPesquisa)
	If HA1->(Found())
		nRec := HA1->(Recno())
		cPesquisa := HA1->A1_CGC
		dbGoTo(nRec)
		aSize(aCliente,0)
		For i := 1 to nCargMax
			aAdd(aCliente, {HA1->A1_COD,HA1->A1_LOJA,AllTrim(HA1->A1_NOME),AllTrim(HA1->A1_CGC)})
			dbSkip()
			If Eof()
			   break
			EndIf
		Next
		nTop := nRec // Atualiza nTop com a posicao localizada na tabela
		SetArray(oBrw, aCliente)
	Else
		MsgAlert(STR0003,STR0002) //"CNPJ/CPF de Cliente nao encontrado!" "###"Aviso"
		cPesquisa := ""
	EndIf 
	Return 	
EndIf

Return nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � SobeCli()           �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcao que controle o LIst de CLientes 					  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aCliente, nCliente - Array e Posicao do Cliente selecionado���
��� 		 � nCargMax - Numero maximo de clientes por pagina			  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
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
