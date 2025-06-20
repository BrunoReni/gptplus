#include "QIPA070.CH"
#include "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPA070  � Autor � Marcelo Pimentel      � Data � 28.09.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Amarracao Prod.xCliente - Ensaio���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Sigaqip                                                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���Marcelo Piment�03/07/01�META  �Remodelagem da rotina podendo efetuar   ���
���              �        �      �as opcoes existentes no browse.         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� 
*/
Static Function MenuDef()

Local aRotina := {	{STR0024	,"AxPesqui"		, 0 , 1,,.F.},; //"Pesquisar"
					{STR0025	,"QP070Manu"	, 0 , 2},; //"Visualizar"
					{STR0026	,"QP070Manu"	, 0 , 3},; //"Incluir"
					{STR0027	,"QP070Manu"	, 0 , 4},; //"Alterar"
					{STR0028	,"QP070Del"		, 0 , 5 , 3 } } //"Excluir"
					
Return aRotina

Function QIPA070()
PRIVATE cCadastro:= STR0001	//"Amarra��o Produto x Cliente"
PRIVATE lFase3   := ChkFile("QQ4") 
PRIVATE __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
PRIVATE lProduto   := .F.

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa 	 �
//� ----------- Elementos contidos por dimensao ------------	 �
//� 1. Nome a aparecer no cabecalho 							 �
//� 2. Nome da Rotina associada									 �
//� 3. Usado pela rotina										 �
//� 4. Tipo de Transa��o a ser efetuada							 �
//�	 1 - Pesquisa e Posiciona em um Banco de Dados				 �
//�	 2 - Simplesmente Mostra os Campos							 �
//�	 3 - Inclui registros no Bancos de Dados					 �
//�	 4 - Altera o registro corrente								 �
//�	 5 - Remove o registro corrente do Banco de Dados			 �
//�	 6 - Nao permite inclusao na getdados						 �
//����������������������������������������������������������������
Private aRotina := MenuDef()
						
//�����������������������������������������������������������������������������������������Ŀ
//� Chama a funcao de QIPA071 que contem altera��es relacionadas a Fase3			        �
//�������������������������������������������������������������������������������������������
QIPA071()

Return NIL

Function QP070C_Top()
Return xFilial("QQ7")+"S"

Function QP070C_Bot()
Return xFilial("QQ7")+"S"
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    �QP070Del   � Autor � Marcelo Pimentel      � Data � 03/07/01 ���
��������������������������������������������������������������������������Ĵ��
���Descri�ao �Exclusao da amarracao Produto x Cliente                      ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA070                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function QP070Del(cAlias,nReg,nOpc)
Local oTempTable	:= NIL
Local oDlg
Local cXMark		:= ''
Local cArqTrab	:= ''
Local aStru		:= {}
Local cChaveQQ7	:= ''
Local aCampos		:= {}
Local aButtons  	:= {}
Private oMark

//��������������������������������������������������������Ŀ
//� Cria Arquivo de Trabalho                               �
//����������������������������������������������������������
Aadd( aStru,{ "TB_OK"   	,	"C",01,0} )
Aadd( aStru,{ "TB_OPER"		,	"C",TamSX3("QQK_OPERAC")[1]	,0} )
Aadd( aStru,{ "TB_CODREC"	,	"C",TamSX3("QQK_CODIGO")[1]	,0} )
Aadd( aStru,{ "TB_LABOR"	,	"C",TamSX3("QP7_LABOR")[1]	,0} )
Aadd( aStru,{ "TB_ENSAIO"	,	"C",TamSX3("QP7_ENSAIO")[1]	,0} )
Aadd( aStru,{ "TB_ENSOBR"	,	"C",TamSX3("QP7_ENSOBR")[1]	,0} )
Aadd( aStru,{ "TB_CERTIF"	,	"C",TamSX3("QP7_CERTIF")[1]	,0} )
Aadd( aStru,{ "TB_DESENS"	,	"C",TamSX3("QP1_DESCPO")[1]	,0} )
Aadd( aStru,{ "TB_CARTA"	,	"C",TamSX3("QP1_CARTA")[1]	,0} )
Aadd( aStru,{ "TB_CHAVE"	,	"C",TamSX3("QA2_CHAVE")[1]	,0} )
Aadd( aStru,{ "TB_CLIENTE"	,	"C",TamSX3("QQ7_CLIENT")[1]	,0} )
Aadd( aStru,{ "TB_PRODUTO"	,	"C",TamSX3("QQ7_PRODUT")[1]	,0} )
Aadd( aStru,{ "TB_LOJA"		,	"C",TamSX3("QQ7_LOJA")[1]	,0} )

oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aStru )
oTempTable:AddIndex("indice1", {"TB_OPER"} )
oTempTable:Create()

cXMark := GetMark()

//��������������������������������������������������������������Ŀ
//� Redefinicao do aCampos para utilizar no MarkBrow             �
//����������������������������������������������������������������
aCampos := {	{"TB_OK"		,""," "}		,;	//"Ok"
				{"TB_ENSAIO"	,"",STR0007	}	,;	//"Ensaio"
				{"TB_DESENS"	,"",STR0008	}	,;	//"Descricao"
				{"TB_LABOR"		,"",STR0006	}	,;	//"Laboratorio"
				{"TB_CODREC"	,"",STR0002	}	,;	//"Roteiro"
				{"TB_OPER"		,"",STR0003	}	,;	//"Operacao"
				{"TB_ENSOBR"	,"",STR0004	}	,;	//"Ensaio Obrig."
				{"TB_CERTIF"	,"",STR0005	}	,;	//"Consta Certif."
				{"TB_CARTA"		,"",STR0009	} }		//"Carta"
				
nOpca := 0
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM 150,3 TO 388,613 OF oMainWnd PIXEL		//"Amarra��o Produto x Cliente"
//Efetuado tratamento para que o aRotina esteja no modo alteracao, para mostrar os campos no QQ7 - Na visualizacao e Exclusao
If !INCLUI
	aRotina[nOpc][4] := 4
EndIf

RegToMemory("QQ7")
EnChoice("QQ7",nReg,nOpc,,,,, {  15,  1, 45, 304 })
oMark := MsSelect():New("TRB","TB_OK",,aCampos,,"x",{49,1,118,304})
oMark:bAval	:= {|| .T. }
oMark:oBrowse:Refresh()
oMark:oBrowse:SetFocus()
QP070Ens(QQ7->QQ7_PRODUT,QQ7->QQ7_CLIENT,QQ7->QQ7_LOJA)
VerifChav(QQ7->QQ7_PRODUT,QQ7->QQ7_CLIENT,QQ7->QQ7_LOJA,oDlg)

//�������������������������������������������������Ŀ
//� Cria botao para visualizacao do Documento    	�
//���������������������������������������������������          
AAdd(aButtons,{"RELATORIO",{|| qp070Texto("TRB",Recno(),nOpc)},STR0019,STR0031}) //"Observacoes..."###"Observac"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nopca:=1,If(A070Ok(M->QQ7_CLIENT,M->QQ7_LOJA),oDlg:End(),nOpca:=0)},{||nopca:=0,oDlg:End()},,aButtons)

If nOpca == 1
	cChaveQQ7 := xFilial("QQ7")+M->QQ7_PRODUT+M->QQ7_CLIENT+M->QQ7_LOJA
	Begin Transaction
	dbSelectArea('QQ7')
	dbSetOrder(1)
	If dbSeek(cChaveQQ7)
		While !EOF() .And. QQ7_FILIAL+QQ7_PRODUT+QQ7_CLIENT+QQ7_LOJA==cChaveQQ7
			RecLock("QQ7")
			dbDelete()
			MsUnlock()
			dbSkip()
		EndDo
	EndIf
	End Transaction
EndIf

oTempTable:Delete() //-- Deleta arquivo temporario

dbSelectArea("QQ7")
dbGoTop()
dbSetOrder(4)
dbGoto(nReg)
Return(.T.)
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    �QP070Manu  � Autor � Marcelo Pimentel      � Data � 28/09/98 ���
��������������������������������������������������������������������������Ĵ��
���Descri�ao �Tela de manutencao Amarracao Produto x Cliente :INC/ALT/VIS  ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA070                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function QP070Manu(cAlias,nReg,nOpc)
Local oDlg
Local cXMark		:= ''
Local aStru			:={}
Local aCampos		:={}
Local aButtons		:={}
Local oEnchoice
Local oTmpTable := Nil

Private cChave		:=''
Private oMark

//��������������������������������������������������������Ŀ
//� Cria Arquivo de Trabalho                               �
//����������������������������������������������������������
Aadd( aStru,{ "TB_OK"   	,	"C",01,0} )
Aadd( aStru,{ "TB_OPER"		,	"C",TamSX3("QQK_OPERAC")[1]	,0} )
Aadd( aStru,{ "TB_CODREC"	,	"C",TamSX3("QQK_CODIGO")[1]	,0} )
Aadd( aStru,{ "TB_LABOR"	,	"C",TamSX3("QP7_LABOR")[1]	,0} )
Aadd( aStru,{ "TB_ENSAIO"	,	"C",TamSX3("QP7_ENSAIO")[1]	,0} )
Aadd( aStru,{ "TB_ENSOBR"	,	"C",TamSX3("QP7_ENSOBR")[1]	,0} )
Aadd( aStru,{ "TB_CERTIF"	,	"C",TamSX3("QP7_CERTIF")[1]	,0} )
Aadd( aStru,{ "TB_DESENS"	,	"C",TamSX3("QP1_DESCPO")[1]	,0} )
Aadd( aStru,{ "TB_CARTA"	,	"C",TamSX3("QP1_CARTA")[1]	,0} )
Aadd( aStru,{ "TB_CHAVE"	,	"C",TamSX3("QA2_CHAVE")[1]	,0} )
Aadd( aStru,{ "TB_CLIENTE"	,	"C",TamSX3("QQ7_CLIENT")[1]	,0} )
Aadd( aStru,{ "TB_PRODUTO"	,	"C",TamSX3("QQ7_PRODUT")[1]	,0} )
Aadd( aStru,{ "TB_LOJA"		,	"C",TamSX3("QQ7_LOJA")[1]	,0} )

oTmpTable := FWTemporaryTable():New( "TRB" )
oTmpTable:SetFields(aStru)
oTmpTable:Create()
DbSelectArea("TRB")

cXMark := GetMark()

//��������������������������������������������������������������Ŀ
//� Redefinicao do aCampos para utilizar no MarkBrow             �
//����������������������������������������������������������������
aCampos := {	{"TB_OK"		,""," "}		,;	//"Ok"
				{"TB_ENSAIO"	,"",STR0007	}	,;	//"Ensaio"
				{"TB_DESENS"	,"",STR0008	}	,;	//"Descricao"
				{"TB_LABOR"		,"",STR0006	}	,;	//"Laboratorio"
				{"TB_CODREC"	,"",STR0002	}	,;	//"Roteiro"
				{"TB_OPER"		,"",STR0003	}	,;	//"Operacao"
				{"TB_ENSOBR"	,"",STR0004	}	,;	//"Ensaio Obrig."
				{"TB_CERTIF"	,"",STR0005	}	,;	//"Consta Certif."
				{"TB_CARTA"		,"",STR0009	} }		//"Carta"
				
nOpca := 0
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM 150,3 TO 388,613 OF oMainWnd PIXEL		//"Amarra��o Produto x Cliente"
//Efetuado tratamento para que o aRotina esteja no modo alteracao, para mostrar os campos no QQ7 - Na visualizacao e Exclusao
If !INCLUI
	aRotina[nOpc][4] := 4
EndIf
RegToMemory("QQ7",(INCLUI))
oEnchoice := Msmget():New("QQ7",nReg,nOpc,,,,, {  15,  1, 45, 304 })

oMark := MsSelect():New("TRB","TB_OK",,aCampos,,"x",{49,1,118,304})

If nOpc == 3 .Or. nOpc == 4
	oMark:oBrowse:bAllMark	:= {| | QP070MkAll(oDlg,nOpc)}
Else
	oMark:bAval				:= {|| .T. }
EndIf
oMark:oBrowse:Refresh()
oMark:oBrowse:SetFocus()

If !INCLUI
	QP070Ens(QQ7->QQ7_PRODUT,QQ7->QQ7_CLIENT,QQ7->QQ7_LOJA)
	VerifChav(QQ7->QQ7_PRODUT,QQ7->QQ7_CLIENT,QQ7->QQ7_LOJA,oDlg)
EndIf

//�������������������������������������������������Ŀ
//� Cria botao para Observacao                   	�
//���������������������������������������������������
AAdd(aButtons,{"RELATORIO",{|| qp070Texto("TRB",Recno(),nOpc)},STR0019,STR0031}) //"Observacoes..."###"Observac"

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,{||nopca:=1,If(A070Ok(M->QQ7_CLIENT,M->QQ7_LOJA),oDlg:End(),nOpca:=0)},{||nopca:=0,oDlg:End()},,aButtons),;
								AlignObject(oDlg,{oEnchoice:oBox,oMark:oBrowse},1,,{60}))

If nOpca == 1
	Begin Transaction
		a070Grava(M->QQ7_PRODUT,M->QQ7_CLIENT,M->QQ7_LOJA)
	End Transaction
EndIf

//��������������������������������������������������������������Ŀ
//� Deleta Arquivo Temporario                                    �
//����������������������������������������������������������������
dbSelectArea("TRB")
dbCloseArea()
oTmpTable:Delete()

dbSelectArea("QQ7")
dbGoTop()
dbSetOrder(4)
dbGoto(nReg)
Return(.T.)
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QP070MkAll � Autor �Marcelo Pimentel     � Data � 19/01/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inverte Marcadas/Desmarcadas                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QIPA070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QP070MkAll(oDlg,nOpcao)
Local nRecno:= Recno()
dbGotop()
While !Eof()
	RecLock("TRB",.F.)
	If Empty(TRB->TB_OK)
		Replace TRB->TB_OK With "x"
	Else
		Replace TRB->TB_OK With " "
	Endif
	MsUnlock()
	dbSkip()
EndDo
dbGoto(nRecno)
oDlg:Refresh()
Return .T.
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A070Grava� Autor � Marcelo Pimentel      � Data � 30/09/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava a amarra��o dos produtos x Clientes dos ensaios      ���
���          � Selecionados.                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QIPA070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A070Grava()
Local nC		:= 0
Local nX		:= 0
Local aCpos		:= {}
Local aStructQQ7 := FWFormStruct(3,"QQ7")[3]
//��������������������������������������������Ŀ
//� Verifica campos do usuario      		   �
//����������������������������������������������
For nX := 1 to Len(aStructQQ7)
	If GetSx3Cache(aStruct[nX,1],"X3_PROPRI") == "U"
		Aadd(aCpos, GetSx3Cache(aStruct[nX,1],"X3_CAMPO"))
	EndIf
Next  

dbSelectArea("TRB")
dbGoTop()
While !Eof()
	//��������������������������������������������������������������Ŀ
	//� Verifica se ja existe o registro.                            �
	//����������������������������������������������������������������
	QQ7->(dbSetOrder(1))
	If QQ7->(dbSeek(xFilial("QQ7")+M->QQ7_PRODUT+M->QQ7_CLIENT+M->QQ7_LOJA+TRB->TB_LABOR+;
		TRB->TB_ENSAIO+TRB->TB_CODREC+TRB->TB_OPER))
		RecLock("QQ7",.F.)
		QQ7->(dbDelete())
		MsUnlock()
	EndIf

	If Empty(TRB->TB_OK)
		dbSelectArea("TRB")
		dbSkip()
		Loop
	EndIf
	
	dbSelectArea("QQ7")
	RecLock("QQ7",.T.)
	QQ7->QQ7_FILIAL		:=	xFilial("QQ7")
	QQ7->QQ7_PRODUT		:= M->QQ7_PRODUT
	QQ7->QQ7_CLIENT		:= M->QQ7_CLIENT
	QQ7->QQ7_LOJA		:= M->QQ7_LOJA
	QQ7->QQ7_LABOR		:= TRB->TB_LABOR
	QQ7->QQ7_ENSAIO		:= TRB->TB_ENSAIO
	QQ7->QQ7_OPERAC		:= TRB->TB_OPER
	QQ7->QQ7_CODREC 	:= TRB->TB_CODREC
	QQ7->QQ7_CHAVE		:= TRB->TB_CHAVE

	//��������������������������������������������Ŀ
	//� Faz a gravacao de campos de usuario        �
	//����������������������������������������������
	For nC := 1 To Len(aCpos)
		FieldPut(FieldPos(aCpos[nC]),M->&(aCpos[nC]))
	Next nC

	MsUnlock()
	dbSelectArea("TRB")
	dbSkip()
EndDo

//����������������������������������������������������������Ŀ
//� Grava "S" no campo MBROWS do QQ7 para mostrar na MBrowse �
//������������������������������������������������������������
QP070Mbrow(xFilial("QQ7") + M->QQ7_PRODUT + M->QQ7_CLIENT + M->QQ7_LOJA)
Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   � A070OK   � Autor � Marcelo Pimentel      � Data �02.10.98  ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o� Verifica se o cliente e a loja foram informados antes de   ���
���          � executar a grava��o.                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Qipa070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A070OK(cCli,cLoj)
Local lRet := .T.
If Empty(cCli) .Or. Empty(cLoj)
	Help(" ",1,"QA_CPOOBR")
	lRet := .F.
EndIf
Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   � VerifChav� Autor � Marcelo Pimentel      � Data �02.10.98  ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o� Verifica se existe a amarra��o Prod x Cliente              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Qipa070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VerifChav(cProd,cCliente,cLoja,oDlg)
Local cChave	:= '', nRecno := 0
dbGotop()
While !Eof()
	RecLock("TRB",.F.)
	TRB->TB_OK 			:=" "
	TRB->TB_CLIENTE		:=cCliente
	TRB->TB_LOJA		:=cLoja
	TRB->TB_PRODUTO		:=cProd
	MsUnlock()
	dbSkip()
EndDo

cChave	:= xFilial("QQ7")+cProd+cCliente+cLoja
dbSelectArea("QQ7")
dbSetOrder(1)
nRecno := Recno()
If dbSeek(cChave)
	While !Eof() .And. cChave == QQ7->QQ7_FILIAL+QQ7->QQ7_PRODUT+QQ7->QQ7_CLIENT+QQ7->QQ7_LOJA
		dbSelectArea("TRB")
		dbGoTop()
		While !Eof()
			If QQ7->QQ7_CODREC+QQ7->QQ7_OPERAC+QQ7->QQ7_LABOR+QQ7->QQ7_ENSAIO == ;
				TRB->TB_CODREC+TRB->TB_OPER+TRB->TB_LABOR+TRB->TB_ENSAIO
				RecLock("TRB",.F.)
				TRB->TB_OK	:="x"
				MsUnlock()
			EndIf
			RecLock("TRB",.F.)
			TRB->TB_CHAVE	:= QQ7->QQ7_CHAVE
			MsUnlock()
			dbSkip()
		EndDo
		dbSelectArea("QQ7")
		dbSkip()
	EndDo
EndIf
DbGoto(nRecno)
oDlg:Refresh()
dbSelectArea("TRB")
dbGoTop()
Return(.T.)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �qp070Texto� Autor � Marcelo Pimentel      � Data � 09.03.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastra Texto do Produto            					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � qp070Texto(ExpC1,ExpN1,ExpN2)	                   		  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo									  ���
���			 � ExpN1 = Numero do registro 								  ���
���			 � ExpN2 = Opcao selecionada								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QIPA010													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function qp070Texto(cAlias,nReg,nOpc)
Local cChave	:=""
Local cCabec	:=""
Local cTitulo	:= OemtoAnsi(STR0021)		//"Produto"
Local nTamLin	:= TamSX3("QA2_TEXTO")[1]
Local cEspecie	:= "QIPA070 "				//Para gravacao de textos
//���������������������������������������������������������������������Ŀ
//� Caso seja Delecao ou Visualizacao a Observacao nao serah alteravel	�
//�����������������������������������������������������������������������
Local lEditObs	:= Iif(nOpc==2.Or.nOpc==5,.F.,.T.)	//Caso seja 
Local lRetTex   := .t.

axtextos := {}								//Vetor que contem os textos dos Produtos
cCabec	:= OemtoAnsi(STR0022)				//"Texto do Produto"

//����������������������������������������������������������Ŀ
//� Gera/obtem a chave de ligacao com o texto do Produto/Rv  �
//������������������������������������������������������������
dbSelectArea("TRB")
If Empty(TRB->TB_CHAVE)
	cChave := QA_CvKey(xFilial("QQ7")+M->QQ7_PRODUT+M->QQ7_CLIENT+M->QQ7_LOJA,"QQ7", 1)
	//����������������������������������������������������������Ŀ
	//� Efetua a gravacao da chave em todo a arquivo tempor�rio  �
	//������������������������������������������������������������
	a070grvChv(cChave)
Else
	cChave := TRB->TB_CHAVE
EndIf

//����������������������������������������������������������Ŀ
//� Digita o Texto do Produto    							 �
//������������������������������������������������������������
lRetTex := QA_TEXTO(cChave,cEspecie,nTamlin,cTitulo,STR0021+": "+AllTrim(M->QQ7_PRODUT)+"  - "+STR0023+M->QQ7_CLIENT+"-"+M->QQ7_LOJA,@axtextos,1,cCabec,lEditObs)		//"Produto"###"Cliente : "

//����������������������������������������������������������Ŀ
//� Grava Texto do Produto no QA2							 �
//������������������������������������������������������������
If lRetTex
	QA_GrvTxt(cChave,cEspecie,1,@axtextos)
EndIf
dbselectArea("TRB")
Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   �a070GrvChv� Autor � Marcelo Pimentel      � Data �02.10.98  ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o� Efetua a gravacao da chave observacao no arquivo temporario���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Qipa070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function a070GrvChv(cChave)
LOCAL nRecno	:= 0
dbSelectArea("TRB")
nRecno	:=Recno()
dbGotop()
While !Eof()
	RecLock("TRB",.F.)
	TRB->TB_CHAVE	:= cChave
	MsUnlock()
	dbSkip()
EndDo
dbGoto(nRecno)
Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   �QP070Ens  � Autor � Marcelo Pimentel      � Data �02.10.98  ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o�Carrega o arquivo temporario sobre os ensaios               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Qipa070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QP070Ens(cProdut,cCliente,cLoja)
Local aARea	:= GetArea()
Local lRet  := .T.
Local cRevi := QA_UltRevEsp(cProdut,dDataBase,,,"QIP") 
				

If !Empty(cCliente) .Or. !Empty(cLoja)
	If ReadVar() = "M->QQ7_CLIENT" .And. Empty(cLoja)
		lRet := ExistCpo("SA1", cCliente)
	Else
		lRet := ExistCpo("SA1", cCliente + cLoja)
	Endif
Endif
If lRet .And. !Empty(cProdut) .And. !Empty(cCliente) .And. !Empty(cLoja)
	If Inclui
		QQ7->(dbSetOrder(1))
		If QQ7->(dbSeek(xFilial("QQ7")+cProdut+cCliente+cLoja))
			Help(" ",1,"QP070TCHV")	//Existe amarracao Produto x Cliente ja cadastrada.
			lRet := .F.
		EndIf
	EndIf
	
	If lRet .And. (ReadVar() = "M->QQ7_PRODUT" .Or. TRB->(LastRec()) = 0)
		If TRB->(LastRec())	 > 0
			TRB->(__DbZap())
		Endif
		QP7->(dbSeek(xFilial("QP7")+cProdut+cRevi))
		While !QP7->(Eof()) .And.QP7->QP7_FILIAL+QP7->QP7_PRODUT+QP7->QP7_REVI ==	xFilial("QP7")+cProdut+cRevi
			QP1->(dbSeek(xFilial("QP1")+QP7->QP7_ENSAIO))
			dbSelectArea("TRB")
			RecLock("TRB",.T.)
			TB_LABOR	:=QP7->QP7_LABOR
			TB_CODREC	:=QP7->QP7_CODREC
			TB_OPER		:=QP7->QP7_OPERAC
			TB_ENSAIO	:=QP7->QP7_ENSAIO
			TB_ENSOBR	:=Iif(QP7->QP7_ENSOBR=='S',STR0029,STR0030) //'Sim'###'Nao'
			TB_CERTIF   :=Iif(QP7->QP7_CERTIF=='S',STR0029,STR0030) //'Sim'###'Nao'
			TB_DESENS   :=QP1->QP1_DESCPO
			TB_CARTA	:=QP1->QP1_CARTA
			TB_FORMUL	:=QP7->QP7_FORMUL
			MsUnLock()
			QP7->(dbSkip())
		EndDo
		QP8->(dbSeek(xFilial("QP8")+cProdut+cRevi))
		While !QP8->(Eof()) .And. QP8->QP8_FILIAL+QP8->QP8_PRODUTO+QP8->QP8_REVI ==xFilial("QP8")+cProdut+cRevi
			QP1->(dbSeek(xFilial("QP1")+QP8->QP8_ENSAIO))
			dbSelectArea("TRB")
			RecLock("TRB",.T.)
			TB_LABOR	:=	QP8->QP8_LABOR
			TB_CODREC	:=	QP8->QP8_CODREC
			TB_OPER		:=	QP8->QP8_OPERAC
			TB_ENSAIO	:=	QP8->QP8_ENSAIO
			TB_ENSOBR	:=	Iif(QP8->QP8_ENSOBR=='S',STR0029,STR0030) //'Sim'###'Nao'
			TB_CERTIF	:=	Iif(QP8->QP8_CERTIF=='S',STR0029,STR0030) //'Sim'###'Nao'
			TB_DESENS	:=	QP1->QP1_DESCPO
			TB_CARTA	:=	QP1->QP1_CARTA
			MsUnLock()
			QP8->(dbSkip())
		EndDo
		
		dbSelectArea("TRB")
		dbGoTop()
		If BOF() .And. EOF()
			HELP(" ",1,"QP070NTENS")	//Nao existe especificacao de produtos cadastrado.
		EndIf
		oMark:oBrowse:Refresh()
		oMark:oBrowse:SetFocus()
	EndIf
EndIf
RestArea(aArea)
Return(lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �QP070Mbrow� Autor � Marcelo Pimentel      � Data �04/6/2001 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao que define qual sera o registro que contem "S" para  ���
���			 �que na tela Mbrowse do Cadastro Amarracao Produto x Cliente ���
���			 �mostrando somente o 1o. registro para melhor visualizacao.  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�1 - <ExpC1> - Registro para pesquisa no QQ7				  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 �Nil 														  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 �Qipa070.prw												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function QP070Mbrow( cChave )
Local aArea 	:= GetArea()
Local lFirst	:= .F.
Default cChave := ""

dbSelectArea("QQ7")
dbSetOrder(1)
If Empty(cChave)
	dbGoTop()
	cChave := QQ7_FILIAL+QQ7_PRODUT+QQ7_CLIENT+QQ7_LOJA
EndIf
If dbSeek( cChave )
	While !Eof() .And. cChave ==	QQ7->QQ7_FILIAL+QQ7->QQ7_PRODUT+QQ7->QQ7_CLIENT+QQ7->QQ7_LOJA
		If !lFirst
			cConteudo := "S"
			lFirst := .T.
		Else
			cConteudo := " "
		EndIf
		RecLock("QQ7",.F.)
		QQ7->QQ7_MBROWS := cConteudo
		MsUnLock()
		dbSkip()
	EndDo
Endif
RestArea(aArea)
Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   �QP070Chv  � Autor � Marcelo Pimentel      � Data �04.06.01  ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o�Validacao dos campos chave                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Qipa070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QP070Chv()
Local lRet := .T.
If !Empty(M->QQ7_PRODUT) .and. !Empty(M->QQ7_CLIENT) .and. !Empty(M->QQ7_LOJA)
   dbSelectArea("QQ7")
   dbSetOrder(1)
   If dbSeek( xFilial() + M->QQ7_PRODUT + M->QQ7_CLIENT + M->QQ7_LOJA )
      Help( " ", 1, "JAGRAVADO" )
      lRet := .F.
   Endif
EndIf
Return(lRet)
