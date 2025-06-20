#INCLUDE 'Dlga200.ch'
#INCLUDE 'FiveWin.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DLGA200   �Autor  �Fernando J. Siquini � Data �  11/01/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �Possibilita a visualizacao de todos os Enderecos onde o     ���
���          �Produto se encontra                                         ���
�������������������������������������������������������������������������͹��
���Uso       � AP7                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function DlgA200()

Local aPosObj    := {}
Local aObjects   := {}
Local aSize      := {}
Local aInfo      := {}
Local aButtons   := {{'pesquisa', {|| GdSeek(oGetD, OemtoAnsi(STR0001))}, OemtoAnsi(STR0004)}} //'Pesquisa Enderecos'###'Pesquisar'
Local oDlgEsp
Local aNoFields  := {'BF_PRODUTO'}

Private aRotina    := {{'', 'AxPesqui', 0, 1}, ;
	{'', 'AxVisual', 0, 2}, ;
	{'', 'AxInclui', 0, 3}, ;
	{'', 'AxAltera', 0, 4}, ;
	{'', 'AxDeleta', 0, 5}}
Private aHeader     := {}
Private aCols       := {}
Private cProduto    := CriaVar('B1_COD', .F.)
Private cDescProd   := CriaVar('B1_DESC', .F.)
Private oDlg
Private oGetD

If SuperGetMv("MV_WMSNEW",.F.,.F.)
	Return WMSA200()
EndIf

//��������������������������������������������Ŀ
//� Montagem do AHEADER e ACOLS para GetDados  �
//����������������������������������������������
FillGetDados(2,'SBF',,,,,aNoFields,,,,,.T.,,,)

//��������������������������������������������������������������Ŀ
//� Dimensoes Padrao                                             �
//����������������������������������������������������������������
aSize   := MsAdvSize()
aAdd(aObjects, {100, 020, .T., .F.})
aAdd(aObjects, {100, 100, .T., .T.})
aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 5, 5}
aPosObj := MsObjSize(aInfo, aObjects)

DEFINE MSDIALOG oDlgEsp TITLE OemToAnsi(STR0002) FROM  aSize[7],0 To aSize[6],aSize[5] PIXEL //'Localizacao dos Produtos'
@ aPosObj[1,1]+7, 009 SAY AllTrim(RetTitle('B1_COD')) SIZE 041, 09 OF oDlgEsp PIXEL
@ aPosObj[1,1]+5, 033 MSGET cProduto Picture PesqPict('SB1', 'B1_COD') VALID DLA200Prod(cProduto) SIZE 050, 09 F3 'SB1' OF oDlgEsp PIXEL

@ aPosObj[1,1]+7, 089 SAY AllTrim(RetTitle('B1_DESC')) SIZE 041, 09 OF oDlgEsp PIXEL
@ aPosObj[1,1]+5, 118 MSGET cDescProd WHEN .F. SIZE 100, 09 OF oDlgEsp PIXEL

oGetD := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],2,'AllWaysTrue','AllWaysTrue')

ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||DLA200Pesq(cProduto)},{||oDlgEsp:End()},,aButtons )

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �DLA200Prod�Autor  �Fernando J. Siquini � Data �  11/01/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida o Produto, preenche a Descricao e atualiza o aCols   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP7                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function DLA200Prod(cProduto)
Local lRet := .T.
cDescProd := ''
SB1->(dbSetOrder(1))
If	SB1->(lRet:=MsSeek(xFilial("SB1")+cProduto))
	cDescProd := SB1->B1_DESC
	DLA200Pesq(cProduto)
EndIf
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �DLA200PESQ�Autor  �Fernando J. Siquini � Data �  11/01/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �Mostra uma tela enquanto monta a pesquisa nos Enderecos     ���
���          �Chama a funcao que realiza a pesquisa                       ���
�������������������������������������������������������������������������͹��
���Uso       � AP7                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function DLA200Pesq(cProduto)

MsgRun(STR0003, '', {|| CursorWait(), _DLA200Pesq(cProduto), CursorArrow()}) //'Pesquisando...'

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �_DLA200Pes�Autor  �Fernando J. Siquini � Data �  11/01/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza a pesquisa do produto no arquivo de Saldos por      ���
���          �Endereco                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP7                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function _DLA200Pesq(cProduto)
Local cSeekSBF   := xFilial('SBF')+cProduto
Local cWhile     := 'SBF->BF_FILIAL+SBF->BF_PRODUTO'
Local aNoFields  := {'BF_PRODUTO'}
Local cQuery     := ''
Local cAliasQry  := ''

aHeader  := {}
aCols    := {}

#IFDEF TOP	
	cAliasQry  := GetNextAlias()
	cQuery := "SELECT BF_FILIAL,"
	cQuery += "BF_LOCAL,"  
	cQuery += "BF_PRIOR,"
	cQuery += "BF_LOCALIZ,"
	cQuery += "BF_NUMSERI,"
	cQuery += "BF_LOTECTL,"
	cQuery += "BF_NUMLOTE,"
	cQuery += "BF_QUANT,"
	cQuery += "BF_EMPENHO,"
	cQuery += "BF_QEMPPRE,"
	cQuery += "BF_QTSEGUM,"
	cQuery += "BF_EMPEN2 ,"
	cQuery += "BF_QEPRE2 ,"
	cQuery += "BF_ESTFIS ,"
	cQuery += "BF_DINVENT,"
	cQuery += "R_E_C_N_O_"
	cQuery += " FROM " +RetSqlName("SBF")
	cQuery += " WHERE BF_FILIAL = '"+xFilial("SBF")+"' AND D_E_L_E_T_ = '' AND BF_PRODUTO = '"+cProduto+"'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
#ENDIF
//������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
//� Sintaxe da FillGetDados(/*nOpcX*/,/*Alias*/,/*nOrdem*/,/*cSeek*/,/*bSeekWhile*/,/*uSeekFor*/,/*aNoFields*/,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/) |
//��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������	
FillGetDados(2,'SBF',5,cSeekSBF,{|| &cWhile },,aNoFields,,,cQuery)

oGetD:oBrowse:Refresh()

Return Nil
