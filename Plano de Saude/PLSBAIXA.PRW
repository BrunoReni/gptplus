#INCLUDE "Plsbaixa.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSBAIXA� Autor � Tulio Cesar            � Data � 17.11.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Rotina de Baixa de Titulos Generica...                     ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSBAIXA                                                   ����
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
Function PLSBAIXA()
Local nInt
//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis...                                          �
//�����������������������������������������������������������������������
PRIVATE aRotina 	:= 	MenuDef()
//���������������������������������������������������������������������Ŀ
//� Monta Titulo...                                                     �
//�����������������������������������������������������������������������
If ExistBlock("PLBX01")
   cCadastro := ExecBlock("PLBX01",.F.,.F.)
Else   
   cCadastro := STR0003 //"Recebimentos de Titulos no Caixa"
Endif
//���������������������������������������������������������������������Ŀ
//� Define ordem default...                                             �
//�����������������������������������������������������������������������
IF ExistBlock("PLBX02")
   nOrdem := ExecBlock("PLBX02",.F.,.F.)
Else   
   nOrdem := 1
Endif  
SA1->(DbSetOrder(nOrdem))
//���������������������������������������������������������������������Ŀ
//� Monta Filtro...                                                     �
//�����������������������������������������������������������������������
cFiltro := "A1_FILIAL = '"+xFilial("SA1")+"'"

If ExistBlock("PLBX03")
   cFiltro += cFiltro + " .And. "+ExecBlock("PLBX03",.F.,.F.)
Endif   
//���������������������������������������������������������������������Ŀ
//� Monta Condicao Vermelha ou Verde...                                 �
//�����������������������������������������������������������������������
If ! ExistBlock("PLBX04")
   cCondCor := ""
Else
   cCondCor := ExecBlock("PLBX04",.F.,.F.)
Endif   
//���������������������������������������������������������������������Ŀ
//� Monta mBrowse...                                                    �
//�����������������������������������������������������������������������
SA1->(DbSetFilter( {|| &cFiltro },  cFiltro ))
SA1->(dbGoTop())
SA1->(mBrowse(06,01,22,75,"SA1",,If(Empty(cCondCor),Nil,cCondFor)  ,20,,,,,, .T. ))
//���������������������������������������������������������������������Ŀ
//� Libera Filtro...                                                    �
//�����������������������������������������������������������������������
SA1->(DbClearFilter())
SA1->(RetIndex("SA1"))
//���������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal...                                          �
//�����������������������������������������������������������������������
Return Nil
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PLBAIMOV � Autor � Tulio                 � Data � 17.11.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Baixa de varios titulos ao mesmo tempo.                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PLBAIMOV(cAlias,nReg,nOpc)                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLBAIMOV(cAlias,nReg,nOpc)
Local I__f := 0
Local nInd
//���������������������������������������������������������������������Ŀ
//� Uso na enchoice...                                                  �
//�����������������������������������������������������������������������
LOCAL nOpca := 0
//���������������������������������������������������������������������Ŀ
//� Folder's...                                                         �
//�����������������������������������������������������������������������
PRIVATE oFolder 
PRIVATE oDlgFolder                                                         
//���������������������������������������������������������������������Ŀ
//� Dados da Enchoice...                                                �
//�����������������������������������������������������������������������
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE aCampos := {}
//���������������������������������������������������������������������Ŀ
//� GetDados de toda a movimentacao financeira...                       �
//�����������������������������������������������������������������������
PRIVATE oBrwFin
PRIVATE aCabFin   := {}
PRIVATE aDadFin   := {}
PRIVATE aTrbFin   := {}
//���������������������������������������������������������������������Ŀ
//� GetDados das Parcelas em Aberto...                                  �
//�����������������������������������������������������������������������
PRIVATE oBrwAbe
PRIVATE aCabAbe   := {}
PRIVATE aDadAbe   := {}
PRIVATE aTrbAbe   := {}

PRIVATE nJuros    := 0
PRIVATE nValor    := 0
PRIVATE nTotal    := 0
//���������������������������������������������������������������������Ŀ
//� Genericos...                                                        �
//�����������������������������������������������������������������������
PRIVATE nOpcx	    := nOpc                                              
PRIVATE aCols      := {}
PRIVATE aHeader    := {}
PRIVATE aDadosRef  := {}
//���������������������������������������������������������������������Ŀ
//� Monta campos usados exibidos do cliente...                          �
//�����������������������������������������������������������������������
If ExistBlock("PLBX05")
   aCampos := ExecBlock("PLBX05",.F.,.F.)
Else
   aCampos := {}
Endif   
//���������������������������������������������������������������������Ŀ
//� Monta Dialogo...                                                    �
//�����������������������������������������������������������������������
DEFINE MSDIALOG oDlgFolder TITLE cCadastro FROM 008.2,010.3 TO 035,100.3 OF GetWndDefault()
//���������������������������������������������������������������������Ŀ
//� Monta Folder Principal...                                           �
//�����������������������������������������������������������������������
@ 030,003 FOLDER oFolder SIZE 348,151 OF oDlgFolder PIXEL	PROMPTS	STR0004,STR0005,STR0006 //"Dados do Cliente"###"Historico Financeiro"###"Parcelas em Aberto"
//���������������������������������������������������������������������Ŀ
//� ENCHOICE (SA1)                                                      �
//�����������������������������������������������������������������������
If nOpcx == K_Incluir
   Copy "SA1" TO Memory Blank
Else
   //���������������������������������������������������������������������Ŀ
   //� Copia o contrato atual para a memoria...                            �
   //�����������������������������������������������������������������������
   Copy "SA1" TO Memory
Endif
//���������������������������������������������������������������������Ŀ
//� MSMGET -> CONTRATO                                                  �
//�����������������������������������������������������������������������
cAlias:="SA1";nReg:=SA1->(RecNo());oEncSA1 := MSMGet():New(cAlias,nReg,nOpcx,,,,If(Empty(aCampos),Nil,aCampos),{005,005,131,339},aCampos,,,,,oFolder:aDialogs[1],,,.F.)
//���������������������������������������������������������������������Ŀ
//� HISTORICO FINANCIERO                                                �
//�����������������������������������������������������������������������
If ExistBlock("PLBX06")
   cCampos := ExecBlock("PLBX06",.F.,.F.)
   Store Header "SE1" TO aCabFin For SX3->X3_ORDEM >= "02" .And. SX3->X3_CAMPO $ cCampos
Else
   Store Header "SE1" TO aCabFin For SX3->X3_ORDEM >= "02"
Endif   
SX3->(DbSetOrder(2))
SX3->(DbSeek("E1_SALDO  "))
AaDd(aCabFin,{trim(X3TITULO()),SX3->X3_CAMPO,;
     SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,;
     SX3->X3_TIPO,nil,SX3->X3_CONTEXT})

If nOpcx == K_Incluir
   Store COLS Blank "SE1" TO aDadFin FROM aCabFin
Else
   SE1->(DbSetOrder(2))
   If ! SE1->(DbSeek(xFilial("SE1")+SA1->A1_COD))
      Store COLS Blank "SE1" TO aDadFin FROM aCabFin
   Else
      Store COLS "SE1" TO aDadFin FROM aCabFin VETTRAB aTrbFin While xFilial("SE1") == SE1->E1_FILIAL .And. SA1->A1_COD == SE1->E1_CLIENTE
   Endif
Endif
//���������������������������������������������������������������������Ŀ
//� PARCELAS EM ABERTO...                                               �
//�����������������������������������������������������������������������
If ExistBlock("PLBX06")
   cCampos := ExecBlock("PLBX06",.F.,.F.)
   Store Header "SE1" TO aCabAbe For SX3->X3_ORDEM >= "02" .And. SX3->X3_CAMPO $ cCampos
Else
   Store Header "SE1" TO aCabAbe For SX3->X3_ORDEM >= "02" 
Endif   
SX3->(DbSetOrder(2))
SX3->(DbSeek("E1_SALDO  "))
AaDd(aCabAbe,{trim(X3TITULO()),SX3->X3_CAMPO,;
        SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,;
        SX3->X3_TIPO,nil,SX3->X3_CONTEXT})

If nOpcx == K_Incluir
   Store COLS Blank "SE1" TO aDadAbe FROM aCabAbe
Else
   SE1->(DbSetOrder(2))
   If ! SE1->(DbSeek(xFilial("SE1")+SA1->A1_COD))
      Store COLS Blank "SE1" TO aDadAbe FROM aCabAbe
   Else
      Store COLS "SE1" TO aDadAbe FROM aCabAbe VETTRAB aTrbAbe While xFilial("SE1") == SE1->E1_FILIAL .And. SA1->A1_COD == SE1->E1_CLIENTE For SE1->E1_SALDO > 0 .And. !Empty(SE1->E1_PLNUCOB)

      nInd := 1
      For nInd := 1 To Len(aDadAbe)        
          nPos  := PLRETPOS("E1_VENCREA",aCabAbe)
          dVenc := aDadAbe[nInd,nPos]

          If ! (dtos(dVenc) >= dtos(dDataBase))
             aDadAbe[nInd,Len(aCabAbe)+1] := .T.
          Endif   
      Next
      
      If Empty(aDadAbe)
         Store COLS Blank "SE1" TO aDadAbe FROM aCabAbe
      Endif
   Endif
Endif
//���������������������������������������������������������������������Ŀ
//� LABELS TOTALIZADORES...                                             �
//�����������������������������������������������������������������������
@ 172, 010 SAY STR0007 SIZE 060,010 OF oDlgFolder PIXEL  //"VALOR"
@ 172, 130 SAY STR0008 SIZE 060,010 OF oDlgFolder PIXEL  //"JUROS"
@ 172, 240 SAY STR0009 SIZE 060,010 OF oDlgFolder PIXEL  //"TOTAL"

@ 182, 010 MSGET oValor VAR nValor SIZE 060,010 OF oDlgFolder PIXEL PICTURE "@E 999,999.99" WHEN .F.
@ 182, 130 MSGET oJuros VAR nJuros SIZE 060,010 OF oDlgFolder PIXEL PICTURE "@E 999,999.99" WHEN .F.
@ 182, 240 MSGET oTotal VAR nTotal SIZE 060,010 OF oDlgFolder PIXEL PICTURE "@E 999,999.99" WHEN .F.
//���������������������������������������������������������������������Ŀ
//� PARCELAS EM ABERTO...                                               �
//�����������������������������������������������������������������������
oBrwAbe := TPLSBrw():New(015,005,335,115,nil,oFolder:aDialogs[3],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabAbe,aDadAbe,.F.,"SE1",K_Visualizar,STR0006,nil,nil,.T.,"PLBMARK(oBrwAbe)") //"Parcelas em Aberto"

lCheck := .F.

@ 003, 005 CHECKBOX oCheck VAR lCheck PROMPT STR0010 OF oFolder:aDialogs[3] SIZE 050,010 PIXEL //"Marca/Desmarca Todos"
oCheck:bChange := {|| PLMARKALL(lCheck,oBrwAbe) }
//���������������������������������������������������������������������Ŀ
//� HISTORICO FINANCEIRO...                                             �
//�����������������������������������������������������������������������
oBrwFin := TPLSBrw():New(005,005,335,125,nil,oFolder:aDialogs[2],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabFin,aDadFin,.T.,"SE1",K_Visualizar,STR0011,{{"E1_SALDO","<=",0}}) //"Movimentacao Financeira"
//���������������������������������������������������������������������Ŀ
//� Ponto de Entrada. Botoes na enchoicebar...                          �
//�����������������������������������������������������������������������
If ExistBlock("PLBX07")
   aButtons := ExecBlock("PLBX07",.F.,.F.)
Else
   aButtons := {}
Endif   
//���������������������������������������������������������������������Ŀ
//� Ativa Dialog                                                        �
//�����������������������������������������������������������������������
ACTIVATE MSDIALOG oDlgFolder ON INIT Eval( {|| EnchoiceBar(oDlgFolder,{|| nOpca := 1, oDlgFolder:End() },{|| nOpca :=2 , oDlgFolder:End() },K_MsgDel,aButtons), PLBMARK(oBrwAbe) } )
//���������������������������������������������������������������������Ŀ
//� Inicio da Rotina de Gravacao dos Dados...                           �
//�����������������������������������������������������������������������
If 	nOpca == K_OK
   
      nOrdA1 := SA1->(IndexOrd())
      nOrdE1 := SE1->(IndexOrd())
      
      For nInd := 1 To Len(oBrwAbe:aCols)                 
          If oBrwAbe:aCols[nInd,Len(oBrwAbe:aHeader)+1]
             nCol01    := PLRETPOS("E1_PREFIXO",oBrwAbe:aHeader)
             cPrefixo  := oBrwAbe:aCols[nInd,nCol01]
             nCol02    := PLRETPOS("E1_NUMERO",oBrwAbe:aHeader)
             cNumero   := oBrwAbe:aCols[nInd,nCol02]
             nCol03    := PLRETPOS("E1_PARCELA",oBrwAbe:aHeader)
             cParcela  := oBrwAbe:aCols[nInd,nCol03]
      
             PLBXE1(cPrefixo,cNumero,cParcela)
          Endif
      Next

     SA1->(DbSetOrder(nOrdA1))
     SE1->(DbSetOrder(nOrdE1))
     
     If ExistBlock("PLBX08")
        ExecBlock("PLBX08",.F.,.F.)
     Endif   
Endif
//���������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal de Movimentacao                             �
//�����������������������������������������������������������������������
Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PLBMARK  � Autor � Tulio                 � Data � 17.11.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Totaliza dados.                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLBMARK(oBrowse)
Local nInd

nInd   := 0           
nValor := 0
nTotal := 0      
nJuros := 0

For nInd   := 1 To Len(oBrowse:aCols)

    If oBrowse:aCols[nInd,Len(oBrowse:aHeader)+1]

       nCol   := PLRETPOS("E1_SALDO",oBrowse:aHeader)
       nValor := nValor + oBrowse:aCols[nInd,nCol]
       
       nPos  := PLRETPOS("E1_VENCTO",aCabAbe)
       dVenc := aDadAbe[nInd,nPos]
       If ! (dtos(dVenc) >= dtos(dDataBase))
          nPos   := PLRETPOS("E1_VENCTO",oBrowse:aHeader)
          nDias  := dDataBase-oBrowse:aCols[nInd,nPos]   
          nPos   := PLRETPOS("E1_VALJUR",oBrowse:aHeader)
          
          If oBrowse:aCols[nInd,nPos] > 0
             nJuros += (oBrowse:aCols[nInd,nPos]*nDias)
          Else
             nPos   := PLRETPOS("E1_PORCJUR",oBrowse:aHeader)
             
             If oBrowse:aCols[nInd,nCol] > 0
                nAuxJur:= ((oBrowse:aCols[nInd,nCol]*oBrowse:aCols[nInd,nPos])*nDias)/100
                nJuros += nAuxJur 
             Endif   
          Endif   
       Endif   

       nTotal := nValor+nJuros
    Endif   

Next

oBrowse:Atualiza()

oValor:Refresh()       
oJuros:Refresh()                     
oTotal:Refresh()

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PLBXE1   � Autor � Tulio                 � Data � 17.11.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Baixa um titulo.                                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLBXE1(cPrefixo,cNumero,cParcela)
//��������������������������������������������������������������������������Ŀ
//� Define dados para manter conpatibilidade com Financeiro...               �
//����������������������������������������������������������������������������
PRIVATE oFontLbl ; DEFINE FONT oFontLbl NAME "Arial" SIZE 6, 15 BOLD
PRIVATE nTotAGer   := 0
PRIVATE nTotADesc  := 0
PRIVATE nTotAMul   := 0
PRIVATE nTotAJur   := 0
PRIVATE nTotADesp  := 0
PRIVATE cLoteFin   := Space (4 )
PRIVATE cMarca     := GetMark()
PRIVATE cOld       := cCadastro
PRIVATE aCampos    := {}   
PRIVATE cLote      := ""      
PRIVATE aCaixaFin  := xCxFina()
PRIVATE lF070Auto  := .F.
PRIVATE lFini055   := IsInCallStack("FINI055")
PRIVATE lValidou   := .F. //	Incluido para n�o dar erro no FINA070

//��������������������������������������������������������������������������Ŀ
//� Busca parametros da rotina do financeiro...                              �
//����������������������������������������������������������������������������
Pergunte("FIN070",.F.)

SE1->(DbSetOrder(1))
If ! SE1->(DbSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela))
   Help("",1,"PLBXE1")
Else
   FA070Tit("SE1",0,SE1->(Recno()))
Endif       
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina...                                                         �
//����������������������������������������������������������������������������
Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PLMARKALL� Autor � Tulio                 � Data � 06.12.00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Marca/Descmarca todos os registros...                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLMARKALL(lCheck,oBrowse)
LOCAL nInd

For nInd := 1 To Len(oBrowse:aCols)
    oBrowse:aCols[nInd,Len(oBrowse:aHeader)+1] := If(lCheck,.T.,.F.)
Next                                            

oBrowse:Atualiza()


Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Darcio R. Sporl       � Data �08/01/2007���
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
Local nInt
Private aRotina := {	{ STR0001	,'AxPesqui' , 0 ,K_Pesquisar , 0, .F.},; //"Pesquisar"
						{ STR0002	,'PLBAIMOV' , 0 ,K_Visualizar, 0, Nil} } //"Consultar"
If ExistBlock("PLBX09")
   aVets := ExecBlock("PLBX09",.F.,.F.)
   nInt  := 0
   For nInt := 1 To Len(aVets)
       aadd(aRotina,aVets[nInt])
   Next    
Endif                              
Return(aRotina)