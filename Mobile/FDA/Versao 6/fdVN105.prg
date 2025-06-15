#INCLUDE "FDVN105.ch"

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CrgProxCon          �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega o codigo do Proximo contato                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cCodCon: codigo do contato					 			  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function CrgProxCon(cCodCon)
Local nCodCon	:=0
Local lEncontrou	:= .T.

// Va ate o ultimo Registro da Tabela Cliente, seguindo o Indice, Ordem Codigo + Loja
dbSelectArea("HU5")
dbSetOrder(1)
dbGoBottom()
If !Bof()
	if !Empty(HU5->U5_CODCON)
		nCodCon:=Val(HU5->U5_CODCON)
	Endif
Endif    
//Incrementa mais um no Codigo do Contato
nCodCon++

//Verifica se esse Codigo ja existe. O Loop, sera finalizado quando ele encontrar um Codigo
// nao existente na Tabela.
lEncontrou := .T.
While lEncontrou == .T.
	cCodCon :=StrZero(nCodCon,6)
	
	dbSelectArea("HU5")
	dbSetOrder(1)
	dbSeek(cCodCon)
	If HU5->(Found())		
		nCodCon++
    else
		lEncontrou := .F.	
    Endif       
    
Enddo
cCodCon :=StrZero(nCodCon,6)
Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CrgFuncao           �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega o array de funcao                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aCargo: Array de funcoes     				 			  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function CrgFuncao(aCargo)

dbSelectArea("HX5")
dbSetOrder(1)
dbSeek("UM")

While !Eof() .And. HX5->X5_TABELA == "UM" 
	AADD(aCargo,AllTrim(HX5->X5_CHAVE) + "-" + AllTrim(HX5->X5_DESCRI))
	dbSkip()
Enddo

Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � ProcFuncao          �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � busca uma funcao no array                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aFuncao: Array de funcoes, cPesq: Valor de busca			  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function ProcFuncao(aFuncao,cPesq)
Local nContador :=0
For nContador:=1 To len(aFuncao)
	If cPesq = Substr(aFuncao[nContador],1,at("-",aFuncao[nContador])-1) 
		break
	Endif
Next
if nContador > len(aFuncao)
	nContador :=1
EndIf
Return nContador

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � DtNasc              �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � permite selecao de uma data								  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� dDtaNasc: Data selecionada								  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function DtNasc(oDtNasc,dDtNasc)
Local dData :=date()
//dDtNasc := SelectDate("Sel.Data Nascimento",if(dDtNasc=Nil, dData, dDtNasc))
if !Empty(dDtNasc) .And. !dDtNasc=Nil 
	dDtNasc := SelectDate(STR0001,dDtNasc) //"Sel.Data Nascimento"
else
	dDtNasc := SelectDate(STR0001,dData) //"Sel.Data Nascimento"
Endif

SetText(oDtNasc,dDtNasc)
Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � GrvContato          �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Grava contato             				 			      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cCodCLi - Cod. Cliente; cLojaCLi - Loja CLiente 			  ���
���			 � nOpCon: Operacao (1-Inclusao, 2-Alteracaoa, 3 Detalhes	  ���
���			 � Contato - Array dos Contatos							      ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function GrvContato(nOpCon,cCodCli,cLojaCli,cCodCon, cContat,cCpf,aFuncao,nFuncao,cFone,cCelular,cEmail,dDtNasc,lAt)
Local cFuncao	:="", nTam:=0

if Len(aFuncao) > 0
	cFuncao:= Substr(aFuncao[nFuncao],1,at("-",aFuncao[nFuncao])-1)
Endif
cCodCli 	:= Alltrim(cCodCli)
cLojacli	:= AllTrim(cLojaCli)    
cCodCon		:= AllTrim(cCodCon)
cContat		:= Upper(AllTrim(cContat))
cCpf		:= AllTrim(cCpf)
cFuncao		:= AllTrim(cFuncao)
cFone		:= AllTrim(cFone)
cCelular	:= AllTrim(cCelular)
cEmail		:= Upper(AllTrim(cEmail))

if Empty(cContat)
	MsgStop(STR0002,STR0003) //"Escreva o Nome do Contato!"###"Verifica Contato"
	Return Nil
Endif

dbSelectArea("HU5")
dbSetOrder(1)
If nOpCon == 1
	dbAppend()	 
	HU5->U5_CODCON 	:= cCodCon		
	HU5->U5_CLIENTE	:= cCodCli
	HU5->U5_LOJA	:= cLojaCli
	HU5->U5_STATUS	:= "N"
Else
	nTam := 6 - Len(cCodCli)
	If nTam > 0 
		dbSeek(cCodCli+space(nTam)+cLojaCli+cCodCon)	           
	Else
	dbSeek(cCodCli + cLojaCli + cCodCon)
	Endif
	If HU5->U5_STATUS <> "N"
		HU5->U5_STATUS	:= "A"
	Endif
Endif
HU5->U5_CONTAT	:= cContat		
HU5->U5_CPF		:= cCpf
HU5->U5_FUNCAO	:= cFuncao		
HU5->U5_FONE	:= cFone
HU5->U5_CELULAR := cCelular	
HU5->U5_EMAIL	:= cEmail 
if !Empty(dDtNasc)
	HU5->U5_DTNASC	:= dDtNasc		
Endif
dbCommit()

Alert(STR0004) //"Contato de Cliente Gravado com Sucesso!"
lAt := .T.
CloseDialog()

Return Nil

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � ExcContato          �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Exclui contato             				 			      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cCodCLi - Cod. Cliente; cLojaCLi - Loja CLiente 			  ���
���			 � Contato - Array dos Contatos							      ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function ExcContato(cCodCli,cLojaCli,cCodCon, lAt)
Local cResp	:= "", nTam:=0
cResp:= if(MsgYesOrNo(STR0005,STR0006),"Sim","N�o") //"Voc� deseja Excluir o Contato Selecionado?"###"Cancelar"
If cResp="Sim"            
	nTam := 6 - Len(cCodCli)
	dbSelectArea("HU5")
	dbSetOrder(1)      
	If nTam > 0
		dbSeek(cCodCli+space(nTam)+cLojaCli+cCodCon)
	Else
		dbSeek(cCodCli + cLojaCli + cCodCon)
	Endif
	If HU5->(Found()) 
		dbDelete()
		dbSkip()
		Alert(STR0007) //"Contato de Cliente Exclu�do com Sucesso!"
		lAt	:= .T.
	Endif
	CloseDialog()	
Endif
Return Nil
