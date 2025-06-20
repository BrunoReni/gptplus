#INCLUDE "Plsm030.ch"
#include "PLSMGER.CH"
#include "PROTHEUS.CH"
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSM030 � Autor � Tulio Cesar            � Data � 01.12.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Consulta log de registros a nivel de campo.                ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSM030()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus 5.07                                     ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial.                              ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSM030()
//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis...                                          �
//�����������������������������������������������������������������������
PRIVATE aRotina 	  := MenuDef()	
		                  
PRIVATE cCadastro 	:= OemtoAnsi(STR0003) //"Consultar Log de Arquivos"

BIQ->(DbSetOrder(1))
BIQ->(MsSeek(xFilial("BIQ")))
BIQ->(mBrowse(06,01,22,75,"BIQ",nil,nil,nil,nil,2))

Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSM030MOV � Autor � Tulio Cesar         � Data � 01.12.00 ����
��������������������������������������������������������������������������Ĵ���
���Descricao � Consulta log de registros a nivel de campo.                ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial.                              ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function PLSM030Mov(cAlias,nReg,nOpc)

cAlias := BIQ->BIQ_ALIAS

BX1->(DbSetOrder(1))
BX1->(MsSeek(xFilial("BX1")+cAlias))

If ! BX1->(Found())
   MsgStop(STR0011) //"nao existe log para este arquivo"
   Return
Endif    

SX2->(MsSeek(cAlias))
//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis...                                          �
//�����������������������������������������������������������������������
PRIVATE aRotina 	:= 	{ { STR0001   ,'AxPesqui' , 0 ,K_Pesquisar },; //"Pesquisar"
                        	 { STR0004,'AxVisual' , 0 ,K_Visualizar},; //"Visualizar"
         			    	 { STR0005,'PLM030MV' , 0 ,K_Incluir   } } //"Consultar"

PRIVATE cCadastro 	:= STR0012+AllTrim(X2Nome()) //"Log de Registros - Arquivo "
//���������������������������������������������������������������������Ŀ
//� Monta IndRegua buscando somente os A2_PLGRUPO <> "GEN"               �
//�����������������������������������������������������������������������
DbSelectArea(cAlias)
//���������������������������������������������������������������������Ŀ
//� Chama funcao de Browse...                                           �
//�����������������������������������������������������������������������

mBrowse(06,01,22,75,cAlias,,,,"!Deleted()")

//���������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal...                                          �
//�����������������������������������������������������������������������
Return Nil
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PLM030MV � Autor � Tulio                 � Data � 01.12.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Consultar log de registros...                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PLM030MOV(cAlias,nReg,nOpc)                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLM030MV(cAlias,nReg,nOpc)         

LOCAL nOpca	 := 2
LOCAL cRec
LOCAL cOpe
LOCAL bOK      := {|| nOpca := 1,oDlg:End()}
LOCAL bCancel  := {|| oDlg:End()}
LOCAL aButtons := {}
LOCAL oDlg

Private oBox
Private cFiltro  	:= ""
Private aOrigDados 	:= {}
Private aDados	 	:= {}

DEFAULT cAlias := If(Subs(READVAR(),1,1)=="M",Subs(READVAR(),4,3),Subs(READVAR(),1,3))
DEFAULT nReg   := 0

If nReg == 0 .And. ChkFile(Subs(cAlias,1,3)) 
   DbSelectArea(cAlias)
   nReg := Recno()
Endif   
//���������������������������������������������������������������������Ŀ
//� Busca todas as ocorrencias para o registro...                       �
//�����������������������������������������������������������������������
cRec   := StrZero(nReg,Len(BX1->BX1_RECNO))
cOpe   := ""                                      

//���������������������������������������������������������������������Ŀ
//� Adiciona o botao de filtro...                                       �
//�����������������������������������������������������������������������
aadd(aButtons,{"FILTRO"   ,{|| uFiltro(cAlias,cRec,oDlg), lRefresh := .T. },OemtoAnsi(STR0007)} )

BX1->(DbSetOrder(1))
If BX1->(MsSeek(xFilial("BX1")+cAlias+cRec))
   While ! BX1->(Eof()) .And. BX1->(BX1_FILIAL+BX1_ALIAS+BX1->BX1_RECNO) == xFilial("BX1")+cAlias+cRec 
         
         If     BX1->BX1_TIPO == "I"
                cOpe := OemtoAnsi(STR0008) //"Inclusao"
         ElseIf BX1->BX1_TIPO == "A"   
                cOpe := OemtoAnsi(STR0009) //"Alteracao"
         ElseIf BX1->BX1_TIPO == "E"
                cOpe := OemtoAnsi(STR0010) //"Exclusao"
         Endif       
         
         aadd(aDados,{BX1->BX1_SEQUEN,cOpe,BX1->BX1_USUARI,BX1->BX1_DATA,BX1->BX1_HORA})
   BX1->(DbSkip())
   Enddo
Endif   

If Empty(aDados)
   MsgStop(STR0006) //"Nao existem registros de log"
   Return
Endif                            

// Para quando limpar o filtro...
aOrigDados := Aclone(aDados)

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0013)+cAlias+OemtoAnsi(STR0014)+AllTrim(Str(nReg,12)) FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault() //"Modificacoes no Arquivo "###" Registro "

@ 001,001 LISTBOX oBox FIELDS HEADER  OemtoAnsi(STR0015),OemtoAnsi(STR0016),OemtoAnsi(STR0017),OemtoAnsi(STR0018),OemtoAnsi(STR0019) COLSIZES 100,060,060,060,060 SIZE  338,165 OF oDlg //"Sequencia"###"Operacao"###"Usuario"###"Data"###"Hora"

oBox:SetArray(aDados)
oBox:bLine   := { || { aDados[oBox:nAt,1] ,aDados[oBox:nAt,2], aDados[oBox:nAt,3], aDados[oBox:nAt,4] , aDados[oBox:nAt,5] } }
oBox:BLDBLCLICK := {|| M030Vis(aDados[oBox:nAt,1] ) }

//SButton():New(180 , 005 , 01 , { || oDlg:End() }, oDlg, .T. )

ACTIVATE DIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,aButtons)

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � M030VIS  � Autor � Tulio                 � Data � 01.12.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Consultar log de registros...                              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function M030Vis(cSeq)
Local I__f := 0
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]

BX2->(DbSetOrder(1))

If ! BX2->(MsSeek(xFilial("BX2")+cSeq))
   Return
Endif

aLogs := {}
While ! BX2->(Eof()) .And. BX2->(BX2_FILIAL+BX2_SEQUEN) == xFilial("BX2")+cSeq
      aadd(aLogs,{BX2->BX2_CAMPO,BX2->BX2_TITULO,BX2->BX2_ANTVAL,BX2->BX2_NOVVAL})
BX2->(DbSkip())
Enddo

DEFINE MSDIALOG oDlgLog TITLE OemtoAnsi(STR0020) FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault() //"Logs no Registro"

BX1->(DbSetOrder(2))
BX1->(MsSeek(xFilial("BX1")+cSeq))

Copy "BX1" TO Memory

Zero();MsMGet():New("BX1",BX1->(Recno()),K_Visualizar,,,,,{005,005,055,349},,,,,,oDlgLog,,,.F.)

@ 005,001 LISTBOX oBoxLog FIELDS HEADER  OemtoAnsi(STR0021),OemtoAnsi(STR0022),OemtoAnsi(STR0023),OemtoAnsi(STR0024) COLSIZES 050,050,150,150 SIZE  343,100 OF oDlgLog //"Campo"###"Descricao"###"Valor Antigo"###"Valor Novo"

oBoxLog:SetArray(aLogs)
oBoxLog:bLine   := { || { aLogs[oBoxLog:nAt,1] ,aLogs[oBoxLog:nAt,2], aLogs[oBoxLog:nAt,3], aLogs[oBoxLog:nAt,4] } }

SButton():New(180 , 005 , 01 , { || oDlgLog:End() }, oDlgLog, .T. )

ACTIVATE DIALOG oDlgLog

Return
   
   
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �uFiltro   �Autor  �Geraldo Felix Jr.   � Data �  08/14/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �Executa um filtro no log do arquivo...                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Visualizacao do Log do Arquivo... SIGAPLS.                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function uFiltro(cAlias,cRec,oDlg)
Local cOp, luFiltro := .F.
//���������������������������������������������������������������������Ŀ
//� Acrescenta a variavel cfiltro o filtro do usuario.                  �
//�����������������������������������������������������������������������
cFiltro  := BuildExpr("BX1",oDlg,cFiltro)
ccFiltro :=	"BX1_FILIAL== '"+xFilial('BX1')+"' .AND. "+; 
			"BX1_ALIAS== '"+cAlias+"' .AND. BX1_RECNO== '"+cRec+"' .AND. "+cFiltro

If Empty(cFiltro)
	BX1->(DbClearFilter())
	aDados := Aclone(aOrigDados)
Else
	aArea := Getarea()
	dbSelectArea("BX1")
	Set Filter To &ccFiltro
	BX1->(dbGotop())
	
	If !BX1->(Eof())
		//�������������Ŀ
		//�Reset aDados �
		//���������������
		aDados := {}
		luFiltro := .T.
		
		While ! BX1->(Eof()) .And. BX1->(BX1_FILIAL+BX1_ALIAS+BX1->BX1_RECNO) == xFilial("BX1")+cAlias+cRec
			
			If     BX1->BX1_TIPO == "I"
				cOpe := "Inclusao"
			ElseIf BX1->BX1_TIPO == "A"
				cOpe := "Alteracao"
			ElseIf BX1->BX1_TIPO == "E"
				cOpe := "Exclusao"
			Endif
			
			aadd(aDados,{BX1->BX1_SEQUEN,cOpe,BX1->BX1_USUARI,BX1->BX1_DATA,BX1->BX1_HORA})
			BX1->(DbSkip())
		Enddo
	Endif
	If Empty(aDados) .or. !luFiltro
	   MsgStop(OemtoAnsi(STR0006)) //"Nao existem registros de log"
	   aDados := {}
	Endif   
           
	BX1->(DbClearFilter())	
Endif

oBox:SetArray(aDados)
oBox:bLine   := { || { aDados[oBox:nAt,1] ,aDados[oBox:nAt,2], aDados[oBox:nAt,3], aDados[oBox:nAt,4] , aDados[oBox:nAt,5] } }
oBox:BLDBLCLICK := {|| M030Vis(aDados[oBox:nAt,1] ) }
oBox:Refresh()                                          

Return(NIL)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSVSLOG  �Autor  �Geraldo Felix Jr.   � Data �  08/15/02   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ativado pelo botao de log. Reconhece o ALIAS e prepara a   ���
���          �visualizacao do LOG de campo.                               ���
�������������������������������������������������������������������������͹��
���Uso       � Visualizacao de Log de Campo... SIGAPLS                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                                    
Function PLSVSLOG 
Local cReadVar :=  ""

//�������������������������������������������������Ŀ
//�Extrai o alias do arquivo a ter o log consultado,�
//�apartir do nome da variavel M->??? da vida.      �
//���������������������������������������������������
cReadVar := Substr(READVAR(),4,3)


Return(NIL)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Darcio R. Sporl       � Data �09/01/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Private aRotina := {	{ STR0001  ,'AxPesqui'   , 0 ,K_Pesquisar , 0, .F.},; //"Pesquisar"
		                { STR0002  ,'PLSM030MOV' , 0 ,K_Visualizar, 0, Nil} } //"Verificar Log"   
Return(aRotina)