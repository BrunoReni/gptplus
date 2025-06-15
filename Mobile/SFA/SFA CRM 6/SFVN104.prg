#INCLUDE "SFVN104.ch"
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � ACCrgCto            �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega Array de Contatos 				 			      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cCodCLi - Cod. Cliente; cLojaCLi - Loja CLiente 			  ���
���			 � aContato - Array dos Contatos							  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function ACCrgCto(cCodCli,cLojaCli,aContato)
Local cFuncao:="",nTam:=0

nTam := 6 - Len(cCodCli)
dbSelectArea("HU5")
dbSetOrder(2)
If nTam > 0
	dbSeek(cCodCli+space(nTam)+cLojaCli)
Else
	dbSeek(cCodCli + cLojaCli)
Endif

While !Eof() .And. HU5->U5_CLIENTE == cCodCli .And. HU5->U5_LOJA == cLojaCli

    cFuncao:=""
	dbSelectArea("HX5")
	dbSetOrder(1)
	dbSeek("UM" + HU5->U5_FUNCAO)
	If !Eof()
		cFuncao	:=HX5->X5_DESCRI
	Endif      
    
	AADD(aContato,{Alltrim(HU5->U5_CODCON),AllTrim(HU5->U5_CONTAT),cFuncao})

	dbSelectArea("HU5")	
 	dbSkip()
Enddo

Return Nil   

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � AcManCon            �Autor: Paulo Amaral  � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega Array de Contatos 				 			      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nOpCon - Operacao (1=Inclusao, 2=Alteracao, 3=Detalhe)	  ���
���			 � cCodCLi - Cod. Cliente; cLojaCLi - Loja CLiente 			  ���
���			 � aContato - Array dos Contatos							  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function AcManCon(nOpCon, oBrwContato,aContato,cCodCli, cLojaCli)
Local cCodCon	:=space(6), cFuncao	:=""
Local nLinha:=0, nTam := 0
Local lAt	:=.F.
if !nOpCon==1
	if Len(aContato) == 0
	    MsgAlert(STR0001,STR0002) //"Nenhum contato selecionado!"###"Cad. Contato"
		Return Nil
	Endif	
	nLinha  := GridRow(oBrwContato)    
	cCodCon	:= aContato[nLinha,1]
Endif

InitContato(nOpCon,cCodCli, cLojaCli,@cCodCon,@lAt)

//Ocorreu alguma Acao no Modulo de Contatos ( Inclusao, Alteracao ou Exclusao)?
// Corpo para atualizacao do Browse de Contatos
if lAt
	nTam := 6 - Len(cCodCli)
	dbSelectArea("HU5")
	dbSetOrder(1)
	If nTam > 0
		dbSeek(cCodCli+space(nTam)+cLojaCli+cCodCon) 
	Else                                             
		dbSeek(cCodCli+cLojaCli+cCodCon) 
	Endif
	//Incluiu ou Alterou um Contato
	if HU5->(Found())
	
	    cFuncao:=""
		dbSelectArea("HX5")
		dbSetOrder(1)
		dbSeek("UM" + HU5->U5_FUNCAO)
		If !Eof()
			cFuncao	:=HX5->X5_DESCRI
		Endif      
	
	    If nOpCon==1 
			AADD(aContato,{Alltrim(HU5->U5_CODCON),AllTrim(HU5->U5_CONTAT),cFuncao})
		Else
			aContato[nLinha,2] := AllTrim(HU5->U5_CONTAT)
			aContato[nLinha,3] := cFuncao
		Endif
	//Excluiu o Contato
	Else
		aDel(aContato,nLinha)
		aSize(aContato,Len(aContato)-1)
	Endif
	SetArray(oBrwContato,aContato)

Endif	
Return Nil